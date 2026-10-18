// #249: el cuerpo conserva el combate del Zupay, sin identidad de jefe.
class CaelumSummonedZupay : CaelumZupayColossus
{
    CaelumSummoningEffect Binding;
    double SummonPower;
    bool AwaitingPlacement;

    override bool IsSewerBoss(){return false;}
    override bool IsRetreatBoss(){return false;}

    override void PostBeginPlay()
    {
        Super.PostBeginPlay();
        // La inicialización nativa ocurre antes del primer Tick. La potencia
        // se captura al lanzar, no se recalcula al guardar o cambiar de mapa.
        InitializeUniformFolkloreProfile(int(CaelumConstants.ZUPAY_ATTRIBUTE_LEVEL*SummonPower+0.5));
        ConfigureCombatMagicalRange();
    }

    override void Tick()
    {
        if(Binding==null || Binding.Body!=self || !Binding.Alive())
        {Destroy();return;}
        if(AwaitingPlacement)return;
        if(target!=null && IsFriend(target)){target=null;LastEnemy=null;}
        Super.Tick();
        // A_Look no entra en See sin un enemigo. El seguimiento amistoso
        // nativo vive en A_Chase; despertarlo desde las poses de espera.
        if(!bDestroyed && health>0 && target==null && ForcedSleepTics<=0
            && CombatLucidityPhysicalStunRemaining<=0 && RecoveryPhase==0
            && (InStateSequence(CurState,SpawnState)
                || InStateSequence(CurState,FindState("IdleBreathing"))))SetStateLabel("See");
    }

    override void Die(Actor source,Actor inflictor,int flags,Name mod)
    {
        // No emitir muerte narrativa, botín ni recompensa de aliado caído.
        Destroy();
    }

    bool CanAffect(Actor victim)
    {return Binding!=null && CaelumSummoning.Enemy(CaelumPlayer(Binding.Owner),victim);}

    bool FollowCaster()
    {
        if(target!=null)return false;
        A_Look();if(target!=null)return false;
        if(master==null)return true;
        vector2 delta=master.Pos.XY-Pos.XY;double distance=delta.Length();
        double gap=distance-Radius-master.Radius;
        if(gap<=Speed)return true;
        Angle=AngleTo(master);
        // El paso conserva velocidad, colisión y contabilidad térmica propias.
        // Ante obstáculos, la navegación nativa busca una dirección libre.
        if(!ThermalTryMove(Pos.XY+delta/distance*Min(Speed,gap)))ThermalChase(null,null);
        return true;
    }

    override int DoSpecialDamage(Actor victim,int damage,Name mod)
    {return CanAffect(victim)?Super.DoSpecialDamage(victim,damage,mod):0;}

    override void OnDestroy()
    {
        if(Binding!=null && Binding.Body==self)Binding.Body=null;
        Super.OnDestroy();
    }

    void HideForPlacement()
    {
        AwaitingPlacement=true;bInvisible=true;bShootable=false;bSolid=false;bNoInteraction=true;
        A_ChangeLinkFlags(1,1);Vel=(0,0,0);target=null;LastEnemy=null;
    }

    void Place(vector3 point)
    {
        SetOrigin(point,false);A_ChangeLinkFlags(0,0);FindFloorCeiling();ClearInterpolation();
        bInvisible=false;bShootable=true;bSolid=true;bNoInteraction=false;AwaitingPlacement=false;
    }

    Default { Tag "$CA_SUMMON_ZUPAY_NAME"; +FRIENDLY -COUNTKILL }
}

// Un inventario del lanzador conserva identidad y reloj. El cuerpo y sus
// existencias viajan como los actores nativos, sin reconstruir ni curar al NPC.
class CaelumSummoningEffect : Inventory
{
    int Revision,RemainingTics;
    double Range,Power;
    CaelumSummonedZupay Body;

    bool Alive()
    {return Revision==CaelumSummoning.REVISION && Owner!=null && Owner.health>0
        && RemainingTics>0 && Body!=null && Body.health>0;}

    override void Tick()
    {
        Super.Tick();
        if(!Alive()){Destroy();return;}
        if(Body.AwaitingPlacement && RemainingTics%TICRATE==0)
        {
            let place=CaelumSummoning.FindPlace(CaelumPlayer(Owner),Owner.Pos,Range);
            if(place.Found)Body.Place(place.Point);
        }
        if(--RemainingTics<=0)Destroy();
    }

    override void PreTravelled()
    {
        if(!Alive())return;
        CaelumDemonService.StopBreath(Body,false,false);
        CaelumBreathing.StopAudio(Body);
        Body.A_StopSound(CHAN_7);
        if(Body.RecoveryGoal!=null){Body.RecoveryGoal.Destroy();Body.RecoveryGoal=null;}
        Body.HideForPlacement();
        Body.ChangeStatNum(STAT_TRAVELLING);
        for(Inventory item=Body.Inv;item!=null;item=item.Inv)
        {item.UnlinkFromWorld();item.ChangeStatNum(STAT_TRAVELLING);}
    }

    override void Travelled()
    {
        if(Body==null)return;
        Body.ResetMaintenanceForTravel();
        Body.ChangeStatNum(STAT_DEFAULT);
        Body.SetOrigin(Owner.Pos,false);Body.FindFloorCeiling();
        for(Inventory item=Body.Inv;item!=null;item=item.Inv)
        {item.ChangeStatNum(STAT_INVENTORY);item.SetOrigin(Body.Pos,false);}
        // Los blancos y la geometría del mapa anterior ya no son válidos.
        Body.SetStateLabel("Spawn");Body.target=null;Body.LastEnemy=null;
        if(Alive())
        {
            let place=CaelumSummoning.FindPlace(CaelumPlayer(Owner),Owner.Pos,Range);
            if(place.Found)Body.Place(place.Point);
        }
    }

    override void OnDestroy()
    {
        let old=Body;Body=null;if(old!=null)old.Destroy();
        Super.OnDestroy();
    }
    Default { Inventory.MaxAmount 1; +INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE }
    States { Spawn: TNT1 A -1; Stop; }
}

// Sonda transitoria: volumen del Zupay real, sin IA, inventario ni recursos.
class CaelumSummoningProbe : Actor
{
    Default { +SOLID +NOGRAVITY +INVISIBLE -COUNTKILL }
    States { Spawn: TNT1 A -1; Stop; }
}

class CaelumSummoningPlace : Object { bool Found; Vector3 Point; }

class CaelumSummoning : Object play
{
    const REVISION=1;
    // Resolución geométrica de búsqueda, no una distancia de juego nueva.
    const PLACEMENT_PRECISION=0.125;

    static clearscope CaelumSummoningEffect Status(CaelumPlayer user)
    {return user==null?null:CaelumSummoningEffect(user.FindInventory("CaelumSummoningEffect"));}

    static bool Enemy(CaelumPlayer user,Actor body)
    {return user!=null && body!=null && body!=user && body.health>0
        && body.bShootable && CaelumSleepRules.Enemy(user,body);}

    static void AdvanceJourney(CaelumPlayer user,int elapsed)
    {
        let effect=Status(user);if(effect==null || elapsed<=0)return;
        effect.RemainingTics=Max(0,effect.RemainingTics-elapsed);
        if(!effect.Alive())effect.Destroy();
    }

    static bool Candidate(CaelumPlayer user,CaelumSummoningProbe probe,vector3 trial,
        double range)
    {
        probe.SetOrigin(trial,false);probe.FindFloorCeiling();
        vector3 point=(trial.X,trial.Y,probe.FloorZ);
        probe.SetOrigin(point,false);probe.FindFloorCeiling();
        if((point-user.Pos).Length()>range || !probe.TestMobjLocation())return false;
        return user.CheckSight(probe,SF_IGNOREVISIBILITY);
    }

    static CaelumSummoningPlace FindPlace(CaelumPlayer user,vector3 desired,double range,
        double bodyRadius=0,double bodyHeight=0)
    {
        let result=CaelumSummoningPlace(new("CaelumSummoningPlace"));
        if(user==null || range<=0)return result;
        let probe=CaelumSummoningProbe(Actor.Spawn("CaelumSummoningProbe",desired,NO_REPLACE));
        if(probe==null)return result;
        let shape=GetDefaultByType("CaelumZupayColossus");
        probe.A_SetSize(bodyRadius>0?bodyRadius:shape.Radius,bodyHeight>0?bodyHeight:shape.Height);
        bool found=Candidate(user,probe,desired,range);vector3 point=probe.Pos;
        double best=found?(point-desired).Length():1e30;
        double step=probe.Radius;
        // Anillos ordenados por distancia al punto elegido; el cilindro de
        // colisión determina el muestreo. La refinación final evita saltos
        // visibles al buscar junto a paredes y cuerpos.
        for(double radius=step;!found && radius<=range*2+step;radius+=step)
        {
            int count=Max(8,int(Ceil(8*radius/step)));
            for(int i=0;i<count;i++)
            {
                double angle=360.0*i/count;
                if(Candidate(user,probe,desired+(Cos(angle)*radius,Sin(angle)*radius,0),range)
                    && (probe.Pos-desired).Length()<best)
                {point=probe.Pos;best=(probe.Pos-desired).Length();found=true;}
            }
        }
        if(found)
        {
            for(double refine=step/2;refine>=PLACEMENT_PRECISION;refine/=2)
            {
                bool improved=true;
                while(improved)
                {
                    improved=false;vector3 center=point;
                    for(int i=0;i<8;i++)
                    {
                        double angle=45.0*i;
                        if(Candidate(user,probe,center+(Cos(angle)*refine,Sin(angle)*refine,0),range)
                            && (probe.Pos-desired).Length()+PLACEMENT_PRECISION<best)
                        {point=probe.Pos;best=(probe.Pos-desired).Length();improved=true;}
                    }
                }
            }
        }
        probe.Destroy();result.Found=found;result.Point=point;return result;
    }

    static bool Release(CaelumPlayer user)
    {
        if(!CaelumPlayerAuthority.CanMutate(user) || user.health<=0 || user.DerivedStats==null)return false;
        double range=CaelumClassAbilityRules.Radius(user);
        vector3 eye=CaelumTelekinesisRules.Eye(user);FLineTraceData hit;
        if(!user.LineTrace(user.Angle,range,user.Pitch,TRF_ABSPOSITION|TRF_THRUACTORS,
            eye.Z,eye.X,eye.Y,hit) || hit.HitType!=FLineTraceData.TRACE_HitFloor)
        {CaelumNotifications.Notify(user,StringTable.Localize("CA_SUMMON_INVALID",false));return false;}
        let effect=Status(user);let previous=effect!=null?effect.Body:null;
        bool hidden=previous!=null && previous.AwaitingPlacement;
        // Reemplazar admite el espacio ocupado por la propia invocación.
        if(previous!=null)previous.A_ChangeLinkFlags(1,1);
        let place=FindPlace(user,hit.HitLocation,range);
        if(previous!=null && !hidden)previous.A_ChangeLinkFlags(0,0);
        if(!place.Found)
        {CaelumNotifications.Notify(user,StringTable.Localize("CA_SUMMON_INVALID",false));return false;}
        let body=CaelumSummonedZupay(Actor.Spawn("CaelumSummonedZupay",place.Point,NO_REPLACE));
        if(body==null)return false;
        if(effect==null)effect=CaelumSummoningEffect(user.GiveInventoryType("CaelumSummoningEffect"));
        if(effect==null){body.Destroy();return false;}
        effect.Revision=REVISION;effect.Range=range;
        effect.Power=CaelumClassAbilityRules.BeneficialPower(user);
        effect.RemainingTics=int(CaelumClassAbilityRules.EFFECT_SECONDS*effect.Power*TICRATE+0.5);
        effect.Body=body;body.Binding=effect;body.SummonPower=effect.Power;
        body.master=user;body.SetFriendPlayer(user.player);body.Angle=user.Angle;
        if(previous!=null)previous.Destroy();
        CaelumNotifications.Notify(user,StringTable.Localize("CA_SUMMON_CAST",false));return true;
    }
}
