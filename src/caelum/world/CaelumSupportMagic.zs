// #479: estado por receptor; cuatro clases independientes, sin recorrer el mapa.
class CaelumSupportStatus : Inventory
{
    int Revision;
    CaelumSupportEffectState Effects[4];
    Actor Sources[4];
    double HealthFraction[4],PulseSeconds[4];
    bool AnyActive;

    void Apply(int role,Actor caster,double attribute)
    {
        if(!CaelumSupportImplementData.ValidRole(role))return;
        if(Revision==0)Revision=CaelumSupportImplementData.MIGRATION_REVISION;
        if(Revision!=CaelumSupportImplementData.MIGRATION_REVISION)return;
        if(Effects[role]==null)Effects[role]=new("CaelumSupportEffectState");
        if(!Effects[role].Active())PulseSeconds[role]=0;
        Effects[role].Apply(attribute);Sources[role]=caster;AnyActive=true;
    }

    double Factor(int role)
    {
        if(Effects[role]==null || !Effects[role].Active())return 1;
        double retention=CaelumSupportImplementData.Beneficial(role)?1:CaelumSupportMagic.CurseRetention(Owner);
        return 1+Effects[role].IntensityPercent*retention/100.0;
    }

    override void Tick()
    {
        Super.Tick();
        if(Owner==null || Owner.health<=0){Destroy();return;}
        if(!AnyActive || Revision!=CaelumSupportImplementData.MIGRATION_REVISION)return;
        AnyActive=false;
        for(int role=0;role<CaelumSupportImplementData.ROLE_COUNT;role++)
        {
            let effect=Effects[role];if(effect==null || !effect.Active())continue;
            bool benefit=CaelumSupportImplementData.Beneficial(role);
            double step=Min(1.0/TICRATE,effect.RemainingSeconds);
            double retention=benefit?1:CaelumSupportMagic.CurseRetention(Owner);
            // Integrar la intensidad antes de vencer evita perder el modificador en el ?ltimo pulso.
            double damageFactor=benefit?1:CaelumSupportMagic.DamageFactor(Owner,Sources[role]);
            HealthFraction[role]+=effect.Advance(step,CaelumSupportMagic.MaximumHealth(Owner))*retention*damageFactor;
            PulseSeconds[role]+=step;
            bool deliver=PulseSeconds[role]+CaelumSupportEffectState.TIME_EPSILON>=1 || !effect.Active();
            if(deliver)
            {
                PulseSeconds[role]=Max(0,PulseSeconds[role]-1);
                int whole=int(HealthFraction[role]+CaelumSupportEffectState.TIME_EPSILON);
                HealthFraction[role]=Max(0,HealthFraction[role]-whole);
                if(whole>0)
                {
                    if(benefit)CaelumSupportMagic.Heal(Owner,whole);
                    else
                    {
                        int before=Owner.health;
                        Owner.DamageMobj(self,Sources[role],whole,'CaelumQuintessenceDOT',DMG_NO_ARMOR,0);
                        let user=CaelumPlayer(Owner);
                        if(user!=null)CaelumRestSafety.PeriodicLoss(user,Max(0,before-Owner.health));
                    }
                }
                if(benefit && Owner.health>=CaelumSupportMagic.MaximumHealth(Owner))HealthFraction[role]=0;
            }
            if(Owner.health<=0){Destroy();return;}
            AnyActive=AnyActive || effect.Active();
        }
    }
    override void OwnerDied(){Destroy();}
    Default { Inventory.MaxAmount 1; +INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE }
    States { Spawn: TNT1 A -1; Stop; }
}

class CaelumSupportAreaOrigin : Actor
{
    Default { Radius 1; Height 1; +NOINTERACTION +NOBLOCKMAP +NOSECTOR +NOGRAVITY +INVISIBLE }
    States { Spawn: TNT1 A -1; Stop; }
}

class CaelumSupportMagic : Object play
{
    static CaelumSupportStatus Status(Actor body)
    {return body==null?null:CaelumSupportStatus(body.FindInventory("CaelumSupportStatus"));}
    static double CurseRetention(Actor body)
    {return CaelumSealResistance.ForEssence(body,CaelumConstants.ESSENCE_QUINTESSENCE);}
    static double Factor(Actor body)
    {
        let effect=Status(body);if(effect==null || body.health<=0)return 1;
        return effect.Factor(CaelumSupportImplementData.STATUETTE)/effect.Factor(CaelumSupportImplementData.EFFIGY);
    }
    static double DamageFactor(Actor victim,Actor source)
    {return (source!=victim?Factor(source):1)/Factor(victim);}
    static int MaximumHealth(Actor body)
    {
        let user=CaelumPlayer(body);let npc=CaelumCombatActor(body);
        return user!=null?user.CaelumMaximumHealth:npc!=null?npc.CombatMaximumHealth:0;
    }
    static void Heal(Actor body,int amount)
    {
        if(body==null || body.health<=0 || amount<=0)return;
        body.health=Min(MaximumHealth(body),body.health+amount);
        let user=CaelumPlayer(body);let npc=CaelumCombatActor(body);
        if(user!=null){user.player.health=body.health;user.UpdateHealthStateEffects();}
        else if(npc!=null)npc.UpdateCombatHealthEffects();
    }
    static bool Eligible(CaelumPlayer caster,Actor body,int role)
    {
        if(caster==null || body==null || caster.health<=0 || body.health<=0
            || !CaelumSupportImplementData.ValidRole(role)
            || (CaelumPlayer(body)==null && CaelumCombatActor(body)==null)
            || CaelumRedemption.Pending(body))return false;
        let summoned=CaelumSummonedZupay(body);if(summoned!=null && summoned.AwaitingPlacement)return false;
        return CaelumSupportImplementData.Beneficial(role)?CaelumRedemption.Allied(caster,body):CaelumSummoning.Enemy(caster,body);
    }
    static bool Apply(CaelumPlayer caster,Actor body,int role)
    {
        if(!Eligible(caster,body,role) || caster.Attributes==null)return false;
        let status=Status(body);
        if(status==null)status=CaelumSupportStatus(body.GiveInventoryType("CaelumSupportStatus"));
        if(status==null)return false;
        status.Apply(role,caster,CaelumSupportImplementData.Beneficial(role)?caster.Attributes.Empathy:caster.Attributes.Charisma);
        return true;
    }
    static bool InArea(Actor body,vector3 point,double radius)
    {
        double horizontal=Max(0,(body.Pos.XY-point.XY).Length()-body.Radius);
        double vertical=Max(0,Max(body.Pos.Z-point.Z,point.Z-body.Pos.Z-body.Height));
        return horizontal*horizontal+vertical*vertical<=radius*radius;
    }
    static int ApplyArea(CaelumPlayer caster,vector3 point,int role,double radius)
    {
        let origin=Actor.Spawn("CaelumSupportAreaOrigin",point,NO_REPLACE);if(origin==null)return 0;
        int applied=0;
        let nearby=BlockThingsIterator.Create(origin,radius);
        while(nearby.Next())
        {
            let body=nearby.thing;
            if(!Eligible(caster,body,role) || !InArea(body,point,radius)
                || !origin.CheckSight(body,SF_IGNOREVISIBILITY))continue;
            if(Apply(caster,body,role))applied++;
        }
        origin.Destroy();return applied;
    }
    static bool Release(CaelumPlayer caster,int weaponType,bool selfTarget)
    {
        int role=CaelumSupportImplementData.RoleForWeapon(weaponType);
        if(!CaelumPlayerAuthority.CanMutate(caster) || caster.DerivedStats==null || !CaelumSupportImplementData.ValidRole(role))return false;
        if(selfTarget && !CaelumSupportImplementData.Beneficial(role))return false;
        Actor body;vector3 point;
        if(selfTarget){body=caster;point=caster.Pos+(0,0,caster.Height/2);}
        else
        {
            let trace=new("CaelumTargetTrace");
            vector3 origin=caster.Pos+(0,0,caster.ViewHeight);
            vector3 direction=(Cos(caster.Angle)*Cos(caster.Pitch),Sin(caster.Angle)*Cos(caster.Pitch),-Sin(caster.Pitch));
            double range=CaelumConstants.ESSENCE_BASE_RANGE_MAP_UNITS*caster.DerivedStats.AbilityRangePercent/100.0;
            bool hit=trace.Trace(origin,level.PointInSector(origin.XY),direction,range,TRACE_PortalRestrict,
                Line.ML_BLOCKING|Line.ML_BLOCKEVERYTHING|Line.ML_BLOCKHITSCAN,false,caster);
            if(!hit)return false;
            point=trace.Results.HitPos;
            if(trace.Results.HitType==TRACE_HitActor)body=CaelumTargetInfo.CanonicalActor(trace.Results.HitActor);
        }
        if(CaelumSupportImplementData.Area(role))
            return ApplyArea(caster,point,role,CaelumSupportImplementData.BaseRadius()*caster.DerivedStats.AbilityRangePercent/100.0)>0;
        return Apply(caster,body,role);
    }
}
