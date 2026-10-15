// Actores de prueba aislados; nunca se incluyen en src/.
class CA241Body : CaelumCombatActor
{
    int Actions;
    void Act(){Actions++;}
    Default { +SOLID +SHOOTABLE +NOBLOOD Mass 66; Radius 16; Height 96; Health 10000; }
    States { Spawn: TNT1 A 1 {Act();} Loop; }
}
class CA241Prop : CaelumMovableProp
{
    override double GetRequiredPhysicalPower(){return 1;}
    Default { Mass 100; Radius 16; Height 96; }
    States { Spawn: TNT1 A -1; Stop; }
}
class CA241Probe : StaticEventHandler
{
    CaelumPlayer User;
    Actor Body;
    int Passed,Failed,ActionsBefore;
    double BeforeAnima;
    Vector3 BeforePosition;
    bool Pin,Manual,Strong;

    void Check(bool ok,String label)
    {if(ok)Passed++;else Failed++;Console.Printf("CA241 %s %s",ok?"PASS":"FAIL",label);}
    void Reset()
    {
        CaelumRacialAbilityRules.Deactivate(User);CaelumSleepRules.Wake(User);
        if(Body!=null)Body.Destroy();
        User.CharacterProfile.Race=CaelumConstants.RACE_GOBLIN;
        User.CharacterCreationComplete=true;User.CreationWizardOpen=false;
        User.ApplyCharacterProfile();User.CurrentAnima=10000;User.CurrentAir=1000;
        User.CurrentLucidity=100;User.CurrentSleep=100;User.UpdateLucidityState();
        User.health=User.CaelumMaximumHealth;User.player.health=User.health;
        User.player.playerstate=PST_LIVE;User.bInvulnerable=true;
        User.LucidityPhysicalStunRemaining=0;User.PainImmobilizationRemaining=0;
        User.RacialAbilityInputLatched=false;User.CombatChannelModeActive=false;
        User.EquipmentMenuOpen=false;CaelumClassAbilityRules.Cancel(User);
        User.SetOrigin((0,0,0),false);User.Angle=0;User.Pitch=0;User.Vel=(0,0,0);
        Pin=true;Stats();
        Body=Actor.Spawn("CA241Body",(256,0,0),NO_REPLACE);Body.ChangeTid(241);
        BeforeAnima=User.CurrentAnima;
    }
    void Stats()
    {
        User.DerivedStats.AnimaCostReductionPercent=0;
        User.DerivedStats.AbilityRangePercent=100;
        User.DerivedStats.MagicalPowerMultiplier=Strong?8:1.7;
        User.DerivedStats.AirRegenerationPerSecond=0;
        User.DerivedStats.AnimaRegenerationPerSecond=0;
        User.DerivedStats.HealthRegenerationPerSecond=0;
        if(Manual)User.DerivedStats.MaximumAnima=10000;
    }
    void Activate()
    {
        Check(CaelumRacialAbilityRules.Begin(User),"Duende factory acquires aimed body");
        CaelumRacialAbilityRules.Advance(User);
        Check(CaelumTelekinesisRules.Held(Body),"first paid step binds target");
    }
    void Contracts()
    {
        Reset();Activate();let effect=CaelumTelekinesisEffect(User.RacialAbility);
        Check(effect!=null && effect.HoldRevision==1,"saved effect revision");
        Check(Abs(CaelumTelekinesisRules.MassKg(Body)-66)<1e-8,"actual body mass");
        Check(Abs(User.CurrentAnima-(10000-66.0/35))<1e-7,"one kg costs one Anima per second");
        User.DerivedStats.AnimaCostReductionPercent=50;
        Check(Abs(CaelumRacialAbilityRules.TicCost(User,effect)-33.0/35)<1e-8,"normal cost reduction once");
        Body.SetOrigin((256,0,80),false);Body.Vel=(0,0,0);User.Angle=90;
        effect.MoveBody();double acceleration=1700.0/66*32/(35*35);
        Check(Abs(Body.Vel.Length()-acceleration)<1e-6,"1000 N times 1.70 divided by actual kg");
        Body.Mass=132;Body.Vel=(0,0,0);effect.MoveBody();
        Check(Abs(Body.Vel.Length()-acceleration/2)<1e-6,"double mass halves acceleration");
        Check(Abs(effect.BaseAnimaPerSecond(User)-132)<1e-8,"live mass doubles consumption");
        vector3 releaseVelocity=Body.Vel;CaelumRacialAbilityRules.Deactivate(User);
        Check(!CaelumTelekinesisRules.Held(Body) && Body.Vel==releaseVelocity
            && !Body.bNOGRAVITY && Body.bSOLID,"release preserves native velocity gravity collision");
        Reset();User.CurrentAnima=0.01;
        Check(!CaelumRacialAbilityRules.Begin(User) && User.CurrentAnima==0.01
            && !CaelumTelekinesisRules.Held(Body),"unaffordable first instant does not bind or spend");
        Reset();User.Angle=180;
        Check(!CaelumRacialAbilityRules.Begin(User) && User.CurrentAnima==10000,"empty aim rejects without payment");
        Reset();Activate();Body.SetOrigin((1500,0,0),false);CaelumRacialAbilityRules.Guard(User);
        Check(User.RacialAbility==null,"range loss releases target");
        Reset();Activate();Body.SetOrigin((1100,0,0),false);CaelumRacialAbilityRules.Guard(User);
        Check(User.RacialAbility==null,"wall obstruction within range releases target");
        Reset();Activate();Body.Destroy();CaelumRacialAbilityRules.Guard(User);
        Check(User.RacialAbility==null,"removed target releases safely");
        Reset();Activate();Body.health=0;CaelumRacialAbilityRules.Guard(User);
        Check(User.RacialAbility==null,"dead target releases");
        Reset();Activate();User.PainImmobilizationRemaining=1;CaelumRacialAbilityRules.Guard(User);
        Check(User.RacialAbility==null && !CaelumTelekinesisRules.Held(Body),"caster immobilization releases target");
        Reset();Body.Destroy();Body=Actor.Spawn("CA241Prop",(256,0,0),NO_REPLACE);Activate();
        Check(effect!=User.RacialAbility && CaelumTelekinesisRules.MassKg(Body)==100,"movable scenery uses same ownership and mass contract");
        CaelumRacialAbilityRules.Deactivate(User);
    }
    void RealBody(int kind)
    {
        Reset();Body.Destroy();
        static const Name kinds[]={ 'CaelumMandinga','CaelumGiantRat','CaelumBull','CaelumRockGraniteHalf2' };
        Body=Actor.Spawn(kinds[Clamp(kind,0,3)],(256,0,0),NO_REPLACE);
        Body.ChangeTid(241);
        vector3 ray=Body.Pos+(0,0,Body.Height/2)-CaelumTelekinesisRules.Eye(User);
        User.Pitch=-VectorAngle(ray.XY.Length(),ray.Z);
        if(Manual)
        {
            User.bInvulnerable=true;
            CaelumNotifications.Notify(User,String.Format("Telequinesis: %.1f kg; %.1f Anima/s; %.0f N",
                CaelumTelekinesisRules.MassKg(Body),CaelumTelekinesisRules.MassKg(Body),Strong?8000:1700));
            Console.Printf("CA241 MANUAL target=%s mass=%.3f force=%.0f",Body.GetClassName(),CaelumTelekinesisRules.MassKg(Body),Strong?8000:1700);
        }
    }
    void RealContracts(int kind)
    {
        RealBody(kind);Activate();
        let npc=CaelumCombatActor(Body);
        if(npc!=null)
        {
            Check(npc.PrepareActorOutgoingDamage(100,false)==0 && npc.PrepareActorOutgoingDamage(100,true)==0,"real actor cannot deliver physical or magical attacks");
            CaelumDemonService.UpdateBreath(npc);
            Check(npc.DemonBreath==null,"real demon breath is stopped while held");
            vector3 origin=Body.Pos;Check(!npc.ThermalTryMove((origin.X+10,origin.Y)) && Body.Pos==origin,"real voluntary movement is blocked");
            let bull=CaelumBull(Body);
            if(bull!=null)Check(bull.BullChargeInterrupted(),"real bull cannot charge while held");
        }
        double mass=CaelumTelekinesisRules.MassKg(Body);
        Check(mass>0 && Abs(CaelumTelekinesisEffect(User.RacialAbility).BaseAnimaPerSecond(User)-mass)<1e-8,"real body and carried load define consumption");
        CaelumRacialAbilityRules.Deactivate(User);
    }
    override void WorldTick()
    {
        User=CaelumPlayer(players[0].mo);
        if(Pin && User!=null && User.DerivedStats!=null)Stats();
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        User=CaelumPlayer(players[e.Player].mo);if(User==null)return;
        if(e.Name=="c241_setup")Reset();
        if(e.Name=="c241_contract")Contracts();
        if(e.Name=="c241_real")RealContracts(e.Args[0]);
        if(e.Name=="c241_gravity_seed")
        {
            Reset();Activate();Body.Mass=e.Args[0];Body.SetOrigin((256,0,80),false);
            Body.Vel=(0,0,0);User.Pitch=-45;BeforePosition=Body.Pos;
        }
        if(e.Name=="c241_gravity_check")
        {
            Check(CaelumTelekinesisRules.Held(Body),"gravity scenario remains held");
            Check(Body.Mass>500?Body.Pos.Z<BeforePosition.Z:Body.Pos.Z>BeforePosition.Z,
                Body.Mass>500?"native gravity defeats insufficient lifting force":"native force lifts affordable light body");
            Check(!Body.bNOGRAVITY && Body.bSOLID,"native gravity and collision flags unchanged");
        }
        if(e.Name=="c241_return")
        {
            Body=ActorIterator.Create(241).Next();
            Check(User.RacialAbility==null && !User.RacialAbilityActive,"return from rollback stays inactive");
            Check(Body!=null && !CaelumTelekinesisRules.Held(Body) && Body.tics>=0,"return from rollback has mobile original target");
        }
        if(e.Name=="c241_manual")
        {Manual=true;RealBody(e.Args[0]);Console.Printf("CA241 DONE failures=0 MANUAL_SEED_ONLY");}
        if(e.Name=="c241_strong"){Strong=!Strong;Stats();CaelumNotifications.Notify(User,Strong?"8000 N (Int 100)":"1700 N (Int 25)");}
        if(e.Name=="c241_low")User.CurrentAnima=0.01;
        if(e.Name=="c241_on")
        {
            Check(CaelumTelekinesisRules.Held(Body),"native User1 press/hold activates once");
            Check(User.CurrentAnima<BeforeAnima,"native held time consumes Anima");
            let npc=CaelumCombatActor(Body);
            Check(npc!=null && npc.PrepareActorOutgoingDamage(50,false)==0,"held body cannot attack");
        }
        if(e.Name=="c241_move")
        {BeforePosition=Body.Pos;ActionsBefore=CA241Body(Body).Actions;User.Angle=40;}
        if(e.Name=="c241_moved")
        {
            Check((Body.Pos-BeforePosition).Length()>10 && Body.Pos.Y>BeforePosition.Y,"native physics follows changed aim");
            Check(CA241Body(Body).Actions==ActionsBefore,"native actor state actions remain suspended");
        }
        if(e.Name=="c241_off")Check(User.RacialAbility==null && !User.RacialAbilityActive,"native release/map travel clears effect");
        if(e.Name=="c241_exhaust")User.CurrentAnima=0.01;
        if(e.Name=="c241_exhausted")Check(User.RacialAbility==null && User.CurrentAnima==0.01 && !CaelumTelekinesisRules.Held(Body),"exhaustion retains unaffordable remainder and releases");
        if(e.Name=="c241_save_seed"){User.CurrentAnima=777;Console.Printf("CA241 SAVE seeded");}
        if(e.Name=="c241_loaded")
        {
            Pin=true;Stats();let effect=CaelumTelekinesisEffect(User.RacialAbility);
            Body=effect==null?null:effect.Body;
            Check(effect!=null && CaelumTelekinesisRules.Held(Body),"active save restores same live binding");
            Check(User.CurrentAnima<777 && User.CurrentAnima>700,"reload resumes payment without reset");
            let it=ActorIterator.Create(241);int count=0;while(it.Next()!=null)count++;
            Check(count==1,"save has exactly one original target");
        }
        if(e.Name=="c241_hub")
        {
            Body=ActorIterator.Create(241).Next();
            Check(Body!=null && !CaelumTelekinesisRules.Held(Body) && Body.tics>=0,"hub target returns without frozen state");
        }
        if(e.Name=="c241_done")Console.Printf("CA241 DONE failures=%d passed=%d",Failed,Passed);
    }
}
