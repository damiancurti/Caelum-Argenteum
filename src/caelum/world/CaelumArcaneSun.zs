// #246: datos aprobados y distribución esférica determinista.
class CaelumArcaneSunRules : Object
{
    const REVISION=1;
    const SIZE_FACTOR=10.0;
    const DAMAGE_FACTOR=10.0;
    const BURST_COUNT=25;
    const SHOT_TICS=TICRATE;

    static Vector3 BurstDirection(int index)
    {
        double z=1.0-2.0*index/(BURST_COUNT-1);
        double ring=Sqrt(Max(0.0,1.0-z*z));
        double angle=index*180.0*(3.0-Sqrt(5.0));
        return (ring*Cos(angle),ring*Sin(angle),z);
    }

    static play bool Enemy(Actor caster,Actor body)
    {
        let user=CaelumPlayer(caster);
        return user!=null && body!=null && body!=caster && body.health>0
            && body.bShootable && CaelumSleepRules.Enemy(user,body);
    }

    static play Actor Nearest(Actor shot,double range)
    {
        Actor best;double distance=range;
        let it=ThinkerIterator.Create("Actor");Actor body;
        while((body=Actor(it.Next()))!=null)
        {
            if(!Enemy(shot.Target,body))continue;
            double next=(body.Pos+(0,0,body.Height/2)-shot.Pos).Length();
            if(next<=distance && shot.CheckSight(body,SF_IGNOREVISIBILITY)){best=body;distance=next;}
        }
        return best;
    }
}

// Metadatos ofensivos comunes: ningún arma equipada se desgasta al usar la clase.
class CaelumArcaneSunShot : CaelumPlayerMagicProjectile
{
    int Revision;
    bool Homing;
    double SeekRange;

    bool CanAffect(Actor body){return CaelumArcaneSunRules.Enemy(Target,body);}

    override int SpecialMissileHit(Actor victim)
    {return CanAffect(victim)?Super.SpecialMissileHit(victim):MHIT_PASS;}

    override int DoSpecialDamage(Actor victim,int damage,Name damageType)
    {return CanAffect(victim)?Super.DoSpecialDamage(victim,damage,damageType):0;}

    override void Tick()
    {
        if(bMissile && Homing)
        {
            double remaining=Max(0.0,CaelumMaximumTravelDistance-CaelumTravelledDistance);
            if(!CanAffect(Tracer) || !CheckSight(Tracer,SF_IGNOREVISIBILITY)
                || (Tracer.Pos+(0,0,Tracer.Height/2)-Pos).Length()>Min(SeekRange,remaining))
                Tracer=CaelumArcaneSunRules.Nearest(self,Min(SeekRange,remaining));
            if(Tracer!=null)A_SeekerMissile(10,30);
        }
        Super.Tick();
    }
    Default { +SEEKERMISSILE +INTERPOLATEANGLES }
}

class CaelumArcaneSunOrb : CaelumArcaneSunShot
{
    int RemainingTics, ShotTics, NormalDamage, BurningDamage;
    int DirectedShots, BurstShots, Explosions, DirectHits;
    double AreaRadius, ChildRange, BurnDuration, BurnPower;
    bool Finished;
    Array<Actor> HitBodies;

    Default { Radius 40; Height 40; Scale 10; }

    override int SpecialMissileHit(Actor victim)
    {
        if(!Finished && CanAffect(victim) && HitBodies.Find(victim)>=HitBodies.Size())
        {
            // Registrar antes de entregar daño evita reentradas o impactos por tic.
            HitBodies.Push(victim);DirectHits++;
            victim.DamageMobj(self,Target,CaelumPreparedDamage,'CaelumMagicTest',0,Angle);
        }
        return MHIT_PASS;
    }

    void BurnNearby()
    {
        let it=ThinkerIterator.Create("Actor");Actor body;
        while((body=Actor(it.Next()))!=null)
        {
            if(!CanAffect(body) || (body.Pos+(0,0,body.Height/2)-Pos).Length()>AreaRadius
                || !CheckSight(body,SF_IGNOREVISIBILITY))continue;
            let status=CaelumElementalStream.Status(body);if(status==null)continue;
            CaelumBolas.FireContact(body);
            status.ApplyDamageOverTime(CaelumConstants.ELEMENTAL_EFFECT_BURN,
                BurnDuration,BurnPower,BurningDamage,Target,body);
        }
    }

    CaelumArcaneSunShot SpawnChild(Vector3 direction,Actor enemy=null)
    {
        let child=CaelumArcaneSunShot(Spawn("CaelumArcaneSunShot",Pos+(0,0,Height/2),NO_REPLACE));
        if(child==null)return null;
        child.Revision=CaelumArcaneSunRules.REVISION;child.Target=Target;
        child.Angle=VectorAngle(direction.X,direction.Y);
        child.Pitch=-ATan2(direction.Z,direction.XY.Length());
        child.Vel=direction*CaelumConstants.PROJECTILE_SPEED_NORMAL;
        child.StoreCaelumAttackResult(NormalDamage,true,false,true,CaelumPushMultiplier);
        child.StoreCaelumElementalPayload(CaelumConstants.ESSENCE_FIRE,false,CaelumDebuffPowerPercent,CaelumBuffPowerPercent);
        child.StoreCaelumCriticalRoll(CaelumCriticalBaseChance,Random[CaelumArcaneSunCritical](0,999999)/10000.0);
        child.CaelumHunterEligible=CaelumHunterEligible;
        child.CaelumIdeologyPenetration=CaelumIdeologyPenetration;
        child.ConfigureCaelumTravelDistance(ChildRange);
        child.SeekRange=AreaRadius;child.Homing=enemy!=null;child.Tracer=enemy;
        child.UpdateCaelumElementalWorldSprite();
        return child;
    }

    void FireNearest()
    {
        Actor enemy=CaelumArcaneSunRules.Nearest(self,AreaRadius);
        if(enemy==null)return;
        vector3 direction=enemy.Pos+(0,0,enemy.Height/2)-(Pos+(0,0,Height/2));
        if(direction.Length()==0)direction=(Cos(Angle),Sin(Angle),0);
        if(SpawnChild(direction.Unit(),enemy)!=null)DirectedShots++;
    }

    void Finish()
    {
        if(Finished)return;
        Finished=true;RemainingTics=0;bMissile=false;Vel=(0,0,0);Explosions++;
        // El motor conserva la caída radial y la oclusión de la estatuilla.
        A_Explode(CaelumActorExplosionDamage,CaelumActorExplosionRadius,0,false);
        for(int i=0;i<CaelumArcaneSunRules.BURST_COUNT;i++)
            if(SpawnChild(CaelumArcaneSunRules.BurstDirection(i))!=null)BurstShots++;
    }

    override void Tick()
    {
        if(!Finished && bMissile)
        {
            BurnNearby();
            if(--ShotTics<=0){ShotTics=CaelumArcaneSunRules.SHOT_TICS;FireNearest();}
            if(--RemainingTics<=0){Finish();SetStateLabel("Death");return;}
        }
        Super.Tick();
    }

    action void A_CaelumSunFinish(){invoker.Finish();}
    States
    {
    Death:
        XFIR A 0 A_CaelumSunFinish;
        XFIR A 2 Bright A_CaelumShowElementalImpact;
        Stop;
    }
}

class CaelumArcaneSun : Object play
{
    static bool AllowsDamage(Actor inflictor,Actor victim)
    {let shot=CaelumArcaneSunShot(inflictor);return shot==null || shot.CanAffect(victim);}

    static bool Release(CaelumPlayer user)
    {
        if(!CaelumPlayerAuthority.CanMutate(user) || user.health<=0 || user.DerivedStats==null)return false;
        vector3 direction=(Cos(user.Pitch)*Cos(user.Angle),Cos(user.Pitch)*Sin(user.Angle),-Sin(user.Pitch));
        let orb=CaelumArcaneSunOrb(Actor.Spawn("CaelumArcaneSunOrb",user.Pos+(0,0,user.Height*0.65),NO_REPLACE));
        if(orb==null)return false;
        orb.Revision=CaelumArcaneSunRules.REVISION;orb.Target=user;orb.Angle=user.Angle;orb.Pitch=user.Pitch;
        orb.Vel=direction*CaelumConstants.PROJECTILE_SPEED_NORMAL;
        double power=CaelumClassAbilityRules.HarmfulPower(user);
        orb.RemainingTics=int(CaelumClassAbilityRules.EFFECT_SECONDS*power*TICRATE+0.5);
        orb.ShotTics=CaelumArcaneSunRules.SHOT_TICS;
        orb.AreaRadius=CaelumClassAbilityRules.Radius(user);
        orb.ChildRange=CaelumConstants.ESSENCE_BASE_RANGE_MAP_UNITS*user.DerivedStats.AbilityRangePercent/100.0;
        orb.NormalDamage=Max(1,int(user.DerivedStats.DebugStaffDamage*user.EffectiveOffensiveDamageMultiplier+0.5));
        int damage=int(orb.NormalDamage*CaelumArcaneSunRules.DAMAGE_FACTOR);
        orb.BurningDamage=Max(1,int(damage*power+0.5));
        orb.BurnDuration=CaelumConstants.ELEMENTAL_BASE_DURATION_SECONDS*power;
        orb.BurnPower=CaelumArcaneSunRules.DAMAGE_FACTOR*power;
        orb.StoreCaelumAttackResult(damage,true,false,true,user.DerivedStats.MagicalPushMultiplier);
        orb.StoreCaelumElementalPayload(CaelumConstants.ESSENCE_FIRE,false,user.DerivedStats.DebuffPowerPercent,user.DerivedStats.BuffPowerPercent);
        orb.StoreCaelumCriticalRoll(user.MagicalCriticalChanceFor(CaelumConstants.WEAPON_TYPE_STAFF),Random[CaelumArcaneSunCritical](0,999999)/10000.0);
        orb.CaelumActorExplosionDamage=damage;
        orb.CaelumActorExplosionRadius=CaelumConstants.ESSENCE_EXPLOSION_BASE_RADIUS
            *CaelumArcaneSunRules.SIZE_FACTOR*user.DerivedStats.AbilityRangePercent/100.0;
        orb.UpdateCaelumElementalWorldSprite();
        user.MarkCombatActivity();CaelumNotifications.Notify(user,StringTable.Localize("CA_ARCANE_SUN_CAST",false));
        return true;
    }
}
