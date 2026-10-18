// #320: geometría de prueba; no introduce valores de balance de producción.
class CA320Target : CaelumCombatActor
{
    override void Tick() {}
    Default { Radius 16; Height 56; Health 1000000; Mass 100; +SHOOTABLE; +SOLID; +NOGRAVITY; +INVULNERABLE; }
    States { Spawn: TNT1 A -1; Stop; }
}
class CA320Mandinga : CaelumMandinga
{
    override void Tick() {}
    States { ProbeFire: TNT1 A 0 A_CaelumSpawnTierOneMagicProjectile("CaelumActorSimpleElementalProjectile",0.65,CaelumConstants.WEAPON_TYPE_STAFF,CaelumConstants.ESSENCE_FIRE,false); TNT1 A -1; Stop; }
}
class CA320Zupay : CaelumZupayColossus
{
    override void Tick() {}
    States { ProbeFire: TNT1 A 0 A_CaelumSpawnTierOneMagicProjectile("CaelumActorExplosiveElementalProjectile",0.65,CaelumConstants.WEAPON_TYPE_STATUETTE,CaelumConstants.ESSENCE_EARTH,true); TNT1 A -1; Stop; }
}
class CA320Control : CaelumCombatActor
{
    override void Tick() {}
    Default { Radius 16; Height 56; Health 1000; +SHOOTABLE; +NOGRAVITY; }
    States { Spawn: TNT1 A -1; Stop; ProbeFire: TNT1 A 0 A_CaelumSpawnTierOneMagicProjectile("CaelumActorSimpleElementalProjectile",0.65,CaelumConstants.WEAPON_TYPE_STAFF,CaelumConstants.ESSENCE_FIRE,false); TNT1 A -1; Stop; }
}
class CA320Probe : CA282Probe
{
    Array<CaelumCombatActor> NativeShooters;
    Array<Actor> Dummies;
    CaelumCombatActor Victim;
    int NativeShots;
    bool Observe;
    double MaxError,MinError;
    CaelumCombatActor Make(Name kind,vector3 pos)
    {
        let actor=CaelumCombatActor(Actor.Spawn(kind,pos));actor.PostBeginPlay();
        actor.CurrentCombatAnima=100000;actor.CurrentCombatAir=100000;
        actor.CombatLucidityPhysicalStunRemaining=0;actor.bNoGravity=true;
        return actor;
    }
    CaelumActorProjectile FindShot(Actor owner)
    {
        let it=ThinkerIterator.Create("CaelumActorProjectile");CaelumActorProjectile shot;
        while((shot=CaelumActorProjectile(it.Next()))!=null)
            if(shot.Target==owner && !shot.bDestroyed)return shot;
        return null;
    }
    vector3 Reference(CaelumCombatActor shooter,bool stone)
    {
        let ref=shooter.A_SpawnProjectile(stone ? "CaelumActorExplosiveElementalProjectile" : "CaelumActorSimpleElementalProjectile",shooter.Height*0.65);
        vector3 velocity=ref.Vel;ref.Destroy();return velocity;
    }
    void Matrix()
    {
        bool baseline=CVar.GetCVar("ca320_baseline").GetBool();
        double distances[]={128,512,1500};double elevations[]={-48,0,128};
        double lucidity[]={100,25,5};double directions[]={0,90,210};
        MinError=100000;MaxError=0;
        Victim=Make("CA320Target",(-1536,-2048,128));
        for(int kind=0;kind<3;kind++)
        {
            bool stone=kind==1;bool spread=baseline || kind==2;
            let shooter=Make(kind==0?"CA320Mandinga":kind==1?"CA320Zupay":"CA320Control",(-2048,-2048,128));
            shooter.Target=Victim;
            int weapon=stone?CaelumConstants.WEAPON_TYPE_STATUETTE:CaelumConstants.WEAPON_TYPE_STAFF;
            for(int d=0;d<3;d++)for(int z=0;z<3;z++)for(int m=0;m<2;m++)for(int l=0;l<3;l++)
            {
                double heading=directions[d];
                Victim.SetOrigin(shooter.Pos+(Cos(heading)*distances[d],Sin(heading)*distances[d],elevations[z]),false);
                shooter.Angle=shooter.AngleTo(Victim);
                if(m!=0)Victim.SetOrigin(Victim.Pos+(32,48,24),false);
                shooter.CurrentCombatLucidity=lucidity[l];shooter.UpdateActorLucidityState();shooter.CombatLucidityPhysicalStunRemaining=0;
                shooter.CurrentCombatAnima=100000;double cost=shooter.GetTierOneMagicAnimaCost(weapon);
                vector3 expected=Reference(shooter,stone);
                shooter.SetState(shooter.FindState("ProbeFire"));let shot=FindShot(shooter);
                String label=String.Format("kind%d range%d height%d moved%d lucidity%d",kind,int(distances[d]),int(elevations[z]),m,int(lucidity[l]));
                Check(shot!=null,"launch "+label);
                if(shot==null)continue;
                double error=(shot.Vel-expected).Length();
                if(kind<2){MinError=Min(MinError,error);MaxError=Max(MaxError,error);}
                Check(spread ? error>0.00001 : error<0.00001,"direction "+label);
                Check(Abs(shot.Vel.Length()-expected.Length())<0.00001
                    && Abs(shooter.CurrentCombatAnima-(100000-cost))<0.00001
                    && shot.CaelumAttackPrepared && shot.CaelumMagicalAttack
                    && shot.CaelumElementalPayloadPrepared
                    && shot.CaelumEssenceType==(stone?CaelumConstants.ESSENCE_EARTH:CaelumConstants.ESSENCE_FIRE)
                    && shot.CaelumPreparedDamage==shooter.LastCombatAttackFinalDamage
                    && shot.MaximumTravelDistance==shooter.GetCombatAbilityRange(),"payload speed cost range "+label);
                shot.Destroy();
            }
            shooter.Destroy();
        }
        Victim.Destroy();Victim=null;
        Console.Printf("CA320 MATRIX baseline=%d demonVelocityErrorMin=%.9f max=%.9f",baseline,MinError,MaxError);
    }
    void Native(bool dense)
    {
        Victim=Make("CA320Target",(-512,-2048,0));
        for(int n=0;n<2;n++)
        {
            let actor=Make(n==0?"CaelumMandinga":"CaelumZupayColossus",(-2048,-2304+n*512,0));
            actor.Target=Victim;actor.SetState(actor.SeeState);NativeShooters.Push(actor);
        }
        if(dense)for(int n=0;n<500;n++)
            Dummies.Push(Make("CA320Target",(1024+(n%20)*64,1024+(n/20)*64,0)));
        let population=CaelumPopulationState.Get();population.Refresh();
        Check(population.HighDensity==dense,"native population path");
        NativeShots=0;Observe=true;
    }
    override void WorldTick()
    {
        if(!Observe)return;
        for(int n=0;n<NativeShooters.Size();n++)
        {
            let shooter=NativeShooters[n];if(shooter==null)continue;
            let shot=FindShot(shooter);if(shot==null)continue;
            vector3 expected=Reference(shooter,shooter is "CaelumZupayColossus");
            Check((shot.Vel-expected).Length()<0.00001,"native chase / windup / release aim");
            NativeShots++;shot.Destroy();shooter.Destroy();NativeShooters[n]=null;
        }
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        Super.NetworkProcess(e);
        if(e.Name=="c320_matrix")Matrix();
        if(e.Name=="c320_native")Native(false);
        if(e.Name=="c320_dense")Native(true);
        if(e.Name=="c320_native_done"){Observe=false;Check(NativeShots==2,"both native actors fired");}
        if(e.Name=="c320_save")
        {
            Victim=Make("CA320Target",(-512,-2048,128));
            for(int n=0;n<2;n++)
            {
                let actor=Make(n==0?"CA320Mandinga":"CA320Zupay",(-2048,-2048+n*256,128));
                actor.Target=Victim;actor.ChangeTid(3200+n);actor.SetState(actor.FindState("ProbeFire"));
                let shot=FindShot(actor);shot.ChangeTid(3210+n);shot.Vel=(0,0,0);
                Check(shot.CaelumAttackPrepared,"save retains prepared projectile");
            }
        }
        if(e.Name=="c320_load")
        {
            for(int n=0;n<2;n++)
            {
                let actor=CaelumCombatActor(ActorIterator.Create(3200+n).Next());
                let shot=CaelumActorProjectile(ActorIterator.Create(3210+n).Next());
                Check(actor!=null && shot!=null && shot.Target==actor && shot.CaelumAttackPrepared && shot.Vel.Length()==0,"loaded identity / existing trajectory retained");
                if(actor==null || shot==null)continue;
                shot.Destroy();vector3 expected=Reference(actor,n==1);actor.SetState(actor.FindState("ProbeFire"));shot=FindShot(actor);
                Check(shot!=null && (shot.Vel-expected).Length()<0.00001,"loaded actor uses new aim on next launch");
            }
        }
        if(e.Name=="c320_manual")
        {
            Manual=true;User.SetOrigin((-1400,-1800,0),false);User.Angle=180;User.Pitch=0;
            for(int n=0;n<2;n++)
            {
                let actor=Make(n==0?"CaelumMandinga":"CaelumZupayColossus",(-2600,-2100+n*600,0));
                actor.Target=User;actor.SetState(actor.SeeState);
            }
        }
    }
}
