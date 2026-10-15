// Isolated instrumentation: production owns input, payment, movement and defense.
class CA247Player : CaelumPlayer
{
    int DrivenTics, Starts, Impulses;
    double SpeedError, DistanceError, DirectionError, ImpulseDebit, RunningDebit;
    bool Measuring, WasDriving;
    vector2 ExpectedMove, FirstDirection;
    double ActualMps;
    override void MovePlayer()
    {
        double air=CurrentAir,anima=CurrentAnima;
        bool previous=CaelumFormationBreaker.Dashing(self);
        if(MovementTapPending!=0)
        {
            let pending=CaelumFormationBreaker.Status(self);
            Console.Printf("CA247 GESTURE bits=%d effect=%d remaining=%d ground=%d water=%d nogravity=%d fly=%d height=%.3f floor=%.3f",
                MovementTapPending,pending!=null,pending==null?0:pending.RemainingTics,
                CaelumFormationBreaker.Grounded(self),WaterLevel,bNOGRAVITY,bFLY,Pos.Z,FloorZ);
        }
        Super.MovePlayer();
        double debit=air-CurrentAir+anima-CurrentAnima;
        if(debit>1e-8)Impulses++;
        bool active=CaelumFormationBreaker.Dashing(self);
        if(active)
        {
            if(!previous){Starts++;FirstDirection=CaelumFormationBreaker.Status(self).Direction;}
            DrivenTics++;ImpulseDebit+=debit;
            let effect=CaelumFormationBreaker.Status(self);
            double command=Sqrt(double(player.cmd.forwardmove)**2+double(player.cmd.sidemove)**2)/6400;
            double expected=4*command*EffectiveMovementPercent/100*CaelumThermalEffects.Speed(self)*effect.DashSpeed;
            SpeedError=Max(SpeedError,Abs(CaelumPhysicsUnits.VelocitySI(Vel.XY.Length())-expected));
            DirectionError=Max(DirectionError,(effect.Direction-FirstDirection).Length());
            ExpectedMove=Vel.XY;Measuring=true;
        }
        WasDriving=active;
    }
    override void Tick()
    {
        vector3 before=Pos;double air=CurrentAir;
        bool measure=Measuring;Measuring=false;
        Super.Tick();
        vector3 travelled=Pos-before;
        ActualMps=CaelumPhysicsUnits.VelocitySI(travelled.XY.Length());
        if(measure)
        {
            if(BlockingMobj==null && BlockingLine==null && MovementBlockingLine==null)
                DistanceError=Max(DistanceError,(travelled.XY-ExpectedMove).Length());
            RunningDebit+=air-CurrentAir;
        }
    }
}
class CA247Body : CaelumCombatActor
{
    override void Tick(){Super.Tick();}
    Default { Radius 32; Height 96; Mass 100; Health 100000; +SOLID +SHOOTABLE +ISMONSTER }
    States { Spawn: TNT1 A -1; Stop; }
}
class CA247Camera : Actor
{
    Default { +NOINTERACTION +NOGRAVITY }
    States { Spawn: TNT1 A -1; Stop; }
}
class CA247Probe : StaticEventHandler
{
    int Passed,Failed,Power,Mode,MaxGhosts;
    bool Active,Manual;
    double SnapshotAir,SnapshotAnima;
    int SnapshotTics;
    CA247Body ContactBody;
    int BeforeContactCount;
    bool AwaitingContact;
    void Check(bool ok,String label)
    {if(ok)Passed++;else Failed++;Console.Printf("CA247 %s %s",ok?"PASS":"FAIL",label);}
    void Stats(CA247Player u)
    {
        u.Attributes.SetAllForDebug(0);u.Attributes.Toughness=25;
        u.DerivedStats.Recalculate(u.Attributes,u.CharacterProfile);
        let d=u.DerivedStats;d.BaseMass=100;d.DebugWeight=0;d.CarriedItemWeight=0;
        d.RefreshCarriedWeightTotals();d.LoadRatio=0;d.BuffPowerPercent=Power;
        d.AnimaCostReductionPercent=0;d.MaximumAnima=10000;d.AnimaRegenerationPerSecond=0;
        d.AirRegenerationPerSecond=0;d.AirConsumptionMultiplier=1;
        u.CurrentHunger=u.CurrentThirst=u.CurrentSleep=100;
        u.SurvivalPerformanceMultiplier=u.HealthPerformanceMultiplier=1;
        CaelumThermalBody.Get(u,true).Exposure=0;
        u.UpdateAirStateEffects();u.ApplyPhysicalMovement();
    }
    void Setup(int scenario,int beneficialPercent)
    {
        let u=CA247Player(players[0].mo);Active=true;
        Power=beneficialPercent>0?beneficialPercent:100;Mode=scenario;
        let effect=CaelumFormationBreaker.Status(u);if(effect!=null)effect.Destroy();
        CaelumClassAbilityRules.Cancel(u);u.ClassPreparationTics=0;u.ClassSleepCooldownRemaining=0;
        u.CharacterCreationComplete=true;u.CreationWizardOpen=false;
        u.CharacterProfile.FirstClass=CaelumConstants.CLASS_WARRIOR;
        u.CharacterProfile.SecondClass=CaelumConstants.CLASS_EXPLORER;
        u.ApplyCharacterProfile();u.bInvulnerable=true;u.bNOTARGET=true;
        u.CombatBlockModeActive=false;u.ShieldModel.Equipped=false;
        u.LucidityPhysicalStunRemaining=u.PainImmobilizationRemaining=0;u.ForcedSleepTics=0;
        u.SetOrigin((0,0,Mode==2?200:0),false);u.Vel=(0,0,0);u.Angle=0;u.Pitch=0;
        u.bNOGRAVITY=u.bFLY=Mode==2;u.MovementAccelerationFactor=0;u.MovementAccelerationStep=0;
        u.EquipmentMenuOpen=false;CaelumMovementImpulse.Clear(u);
        u.DrivenTics=u.Starts=u.Impulses=0;u.SpeedError=u.DistanceError=u.DirectionError=0;
        u.ImpulseDebit=u.RunningDebit=0;u.Measuring=false;MaxGhosts=0;
        Stats(u);u.CurrentAnima=1000;u.CurrentAir=u.DerivedStats.MaximumAir;
        u.health=u.CaelumMaximumHealth;u.player.health=u.health;
        if(Mode!=1)
        {
            bool released=CaelumFormationBreaker.Release(u);
            let created=CaelumFormationBreaker.Status(u);
            Console.Printf("CA247 SETUP released=%d health=%d effect=%d remaining=%d power=%.3f",released,u.health,
                created!=null,created==null?0:created.RemainingTics,created==null?0:created.Power);
        }
        Console.Printf("CA247 CASE mode=%d power=%d",Mode,Power);
    }
    override void UiTick(){if(!Manual && Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();}
    override void WorldTick()
    {
        let u=CA247Player(players[0].mo);if(!Active || u==null)return;Stats(u);
        let it=ThinkerIterator.Create("CaelumFormationAfterimage");int ghosts=0;
        while(it.Next()!=null)ghosts++;MaxGhosts=Max(MaxGhosts,ghosts);
        if(AwaitingContact && u.ImpactDiagnosticUniquePairTicks>BeforeContactCount && ContactBody!=null)
        {
            AwaitingContact=false;
            Check(u.LastImpactReceivedJoules>0 && Abs(u.LastImpactReceivedJoules-ContactBody.LastImpactReceivedJoules)<1e-6,
                "native bilateral collision delivers the same pre-defense energy to both bodies");
            double expected=CaelumToughnessRules.Reduction(CaelumToughnessRules.NaturalMass(ContactBody),CaelumToughnessRules.Effective(ContactBody));
            Check(Abs(ContactBody.LastImpactToughnessPercent*ContactBody.GetImpactMaximumHealth()/100-expected)<1e-6,
                "other body retains its own ordinary Toughness reduction");
        }
    }
    override void WorldLoaded(WorldEvent e)
    {
        if(!e.IsSaveGame)return;
        Active=true;Power=100;
        let u=CA247Player(players[0].mo);let effect=CaelumFormationBreaker.Status(u);
        if(u.ClassCastActive)
        {
            Check(u.ClassCastProfession==CaelumConstants.PROFESSION_MERCENARY && effect==null,
                "saved preparation retains Mercenary identity without early release");
            Check(u.ClassCastPaid>0 && u.ClassCastPaid<1000,"saved preparation retains its partial progressive payment");
            return;
        }
        Check(effect!=null && effect.Revision==1 && effect.DashTics>0,"save restores an active revision-one traversal");
        if(effect!=null)
        {
            SnapshotTics=effect.DashTics;
            Check(effect.Direction.LengthSquared()>0 && effect.DashSpeed==4 && effect.DashDefense==10,"save restores direction and captured factors");
        }
        Check(u.MovementTapPending==0 && !u.MovementTapReady,"load clears partial native gestures");
        SnapshotAir=u.CurrentAir;SnapshotAnima=u.CurrentAnima;
    }
    void Defense(CA247Player u)
    {
        let effect=CaelumFormationBreaker.Status(u);
        effect.DashTics=35;effect.DashMap=level.MapName;effect.DashDefense=10;
        double baseline=u.GetBiologicalLandingAbsorptionSpeed();
        Check(Abs(u.GetImpactAgilityAbsorptionSpeed(CaelumConstants.IMPACT_KIND_ACTOR)-baseline*10)<1e-8,
            "moving body receives the full biological factor");
        Check(Abs(u.GetImpactAgilityAbsorptionSpeed(CaelumConstants.IMPACT_KIND_WALL)-baseline*10)<1e-8,
            "wall cushioning multiplies final biological allowance");
        double ordinary=CaelumToughnessRules.Reduction(100,25);
        Check(Abs(ordinary-170)<1e-8,"ordinary family-three Toughness reduction stays 170");
        u.ReceiveCaelumImpact(0,CaelumConstants.IMPACT_KIND_ACTOR,null,1,100,100,1,1,0,1,false,3000);
        double reduced=u.LastImpactToughnessPercent*u.GetImpactMaximumHealth()/100;
        Check(Abs(reduced-ordinary*10)<1e-6,"collision subtracts ten times final Toughness instead of scaling raw attribute");
        Check(u.Attributes.Toughness==25 && CaelumToughnessRules.Reduction(100,25)==ordinary,"other damage retains unmodified Toughness");
        u.ReceiveCaelumImpact(0,CaelumConstants.IMPACT_KIND_CRUSH,null,1,100,100,1,1,0,1,false,3000);
        Check(Abs(u.LastImpactToughnessPercent*u.GetImpactMaximumHealth()/100-ordinary)<1e-6,
            "sustained crushing retains the separate ordinary contract");
        effect.DashTics=0;
        u.ReceiveCaelumImpact(0,CaelumConstants.IMPACT_KIND_ACTOR,null,1,100,100,1,1,0,1,false,3000);
        Check(Abs(u.LastImpactToughnessPercent*u.GetImpactMaximumHealth()/100-ordinary)<1e-6,
            "collision reduction returns to normal immediately");
        Check(u.GetImpactAgilityAbsorptionSpeed(CaelumConstants.IMPACT_KIND_ACTOR)==0,
            "moving bodies lose the temporary biological allowance");
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CA247Player(players[0].mo);if(u==null)return;
        if(e.Name=="c247_setup")Setup(e.Args[0],e.Args[1]);
        if(e.Name=="c247_check")
        {
            Console.Printf("CA247 METRICS starts=%d tics=%d speederror=%.9f distanceerror=%.9f directionerror=%.9f activation=%.9f running=%.9f ghosts=%d",u.Starts,u.DrivenTics,u.SpeedError,u.DistanceError,u.DirectionError,u.ImpulseDebit,u.RunningDebit,MaxGhosts);
            Check(u.Starts==1 && u.DrivenTics==e.Args[0],"one native forward gesture drives the exact scaled duration");
            Check(u.SpeedError<1e-6 && u.DistanceError<1e-6,"boosted velocity and physical displacement match native running maximum times full factor");
            Check(u.DirectionError<1e-8,"traversal retains its initial world direction");
            Check(u.ImpulseDebit==0 && u.Impulses==0,"empowered gesture has no activation Air or Anima debit");
            Check(u.RunningDebit>0,"ordinary running still consumes Air during traversal");
            Check(!CaelumFormationBreaker.Dashing(u) && CaelumPhysicsUnits.VelocitySI(u.Vel.XY.Length())<=8.01,
                "end removes defense and caps speed to normal running");
            Check(MaxGhosts>0,"native movement creates expiring appearance afterimages");
        }
        if(e.Name=="c247_expiry")CaelumFormationBreaker.Status(u).RemainingTics=1;
        if(e.Name=="c247_turn")u.Angle=90;
        if(e.Name=="c247_camera")
        {let camera=Actor.Spawn("CA247Camera",(400,-300,120));camera.Angle=90;camera.Pitch=12;u.player.camera=camera;}
        if(e.Name=="c247_roof")
        {let sector=u.CurSector;sector.MoveCeiling(4096,sector.ceilingplane.PointToDist(u.Pos.XY,u.FullHeight*0.75),-1,-1,false);}
        if(e.Name=="c247_denied")
        {Console.Printf("CA247 CEILING starts=%d paid=%d crouch=%.3f height=%.3f full=%.3f clearance=%.3f",u.Starts,u.Impulses,u.player.crouchfactor,u.Height,u.FullHeight,u.CeilingZ-u.Pos.Z);
         Check(u.Starts==0 && u.Impulses==0 && u.player.crouchfactor<1,"low ceiling denies activation without payment or standing");}
        if(e.Name=="c247_trail")
        {
            let it=ThinkerIterator.Create("CaelumFormationAfterimage");CaelumFormationAfterimage ghost;
            CaelumFormationAfterimage body;bool aligned=true;int pairs=0;
            while((ghost=CaelumFormationAfterimage(it.Next()))!=null)
            {
                Console.Printf("CA247 GHOST x=%.3f y=%.3f age=%d alpha=%.6f sprite=%d frame=%d",ghost.Pos.X,ghost.Pos.Y,ghost.Age,ghost.Alpha,ghost.sprite,ghost.frame);
                if(body==null)body=ghost;
                else{aligned=aligned && (body.Pos-ghost.Pos).Length()<1e-6 && body.Age==ghost.Age;body=null;pairs++;}
            }
            Check(pairs>0 && aligned,"every frozen head stays aligned with its body snapshot");
        }
        if(e.Name=="c247_prediction")
        {
            let effect=CaelumFormationBreaker.Status(u);int saved=effect.DashTics;
            int cheats=u.player.cheats;u.player.cheats|=CF_PREDICTING;
            CaelumFormationBreaker.Guard(u,true);CaelumFormationBreaker.AfterPhysics(u,u.Pos);
            Check(effect.DashTics==saved,"prediction cannot consume or cancel authoritative traversal");
            u.player.cheats=cheats;
        }
        if(e.Name=="c247_wall")u.SetOrigin((30000-u.Radius-200,0,0),false);
        if(e.Name=="c247_body")
        {ContactBody=CA247Body(Actor.Spawn("CA247Body",u.Pos+(200,0,0)));ContactBody.Vel.X=-1;
         ContactBody.bBuddha=true;BeforeContactCount=u.ImpactDiagnosticUniquePairTicks;AwaitingContact=true;}
        if(e.Name=="c247_blocked")
        {Console.Printf("CA247 CONTACT starts=%d driven=%d active=%d x=%.3f vx=%.3f",u.Starts,u.DrivenTics,CaelumFormationBreaker.Dashing(u),u.Pos.X,u.Vel.X);
         Check(u.Starts==1 && u.DrivenTics<35 && !CaelumFormationBreaker.Dashing(u),"native solid contact stops traversal early");
         Check(u.LastImpactToughnessPercent*u.GetImpactMaximumHealth()/100>=1299.9,"terminating collision retains boosted Toughness");}
        if(e.Name=="c247_interrupt")
        {
            if(e.Args[0]==1)u.PainImmobilizationRemaining=2;
            if(e.Args[0]==2)u.SetOrigin(u.Pos+(0,0,128),false);
            if(e.Args[0]==3)u.EquipmentMenuOpen=true;
        }
        if(e.Name=="c247_stopped")Check(!CaelumFormationBreaker.Dashing(u),"interruption removes the traversal immediately");
        if(e.Name=="c247_dead"){u.health=0;u.player.health=0;}
        if(e.Name=="c247_death_check")Check(CaelumFormationBreaker.Status(u)==null,"death removes the owned effect");
        if(e.Name=="c247_hub")
        {let effect=CaelumFormationBreaker.Status(u);
         Check(!CaelumFormationBreaker.Dashing(u),"hub arrival does not continue an old-map traversal");
         Check(effect!=null && effect.RemainingTics>0,"hub travel retains the owned class window");}
        if(e.Name=="c247_renew")
        {
            let effect=CaelumFormationBreaker.Status(u);effect.RemainingTics=500;
            u.DerivedStats.BuffPowerPercent=200;CaelumFormationBreaker.Release(u);
            Check(effect.Power==2 && effect.RemainingTics==700,"renewal uses new power and greater duration without stacking");
            u.DerivedStats.BuffPowerPercent=100;CaelumFormationBreaker.Release(u);
            Check(effect.Power==1 && effect.RemainingTics==700,"weaker renewal keeps greater remaining duration");
        }
        if(e.Name=="c247_manual_wall"){Manual=true;Setup(0,100);u.SetOrigin((30000-u.Radius-300,0,0),false);}
        if(e.Name=="c247_normal")Check(u.Starts==0 && u.Impulses==1,"unempowered or flying gesture retains ordinary paid impulse");
        if(e.Name=="c247_water")Check(u.WaterLevel==3,"fallback was exercised in native swimmable geometry");
        if(e.Name=="c247_defense")Defense(u);
        if(e.Name=="c247_clean")
        {let it=ThinkerIterator.Create("CaelumFormationAfterimage");Check(it.Next()==null,"afterimages expire without persistent actors");}
        if(e.Name=="c247_partial")Check(u.ClassCastActive && u.ClassCastPaid>0 && u.ClassCastPaid<1000,"native User4 prepares and progressively pays");
        if(e.Name=="c247_cancel")Check(!u.ClassCastActive && u.ClassSleepCooldownRemaining==0 && u.CurrentAnima<1000,"cancel retains spending without cooldown");
        if(e.Name=="c247_released")Check(!u.ClassCastActive && CaelumFormationBreaker.Status(u)!=null
            && u.ClassSleepCooldownRemaining>59 && Abs(u.ClassCastPaid-1000)<1e-6,"native preparation releases Mercenary effect and starts cooldown");
        if(e.Name=="c247_loaded")Check(!CaelumFormationBreaker.Dashing(u) && u.Starts==1
            && u.CurrentAnima==SnapshotAnima,"loaded traversal finishes without another activation or payment");
        if(e.Name=="c247_manual"){Manual=true;Setup(1,100);}
        if(e.Name=="c247_done")Console.Printf("CA247 DONE failures=%d passes=%d",Failed,Passed);
    }
    override void RenderOverlay(RenderEvent e)
    {
        if(!Manual)return;let u=CA247Player(players[consoleplayer].mo);if(u==null)return;
        let effect=CaelumFormationBreaker.Status(u);
        String line=String.Format("#247 | F: lanzar/cancelar | F6: reiniciar | doble W: impulso | C: tercera persona");
        Screen.DrawText(SmallFont,Font.CR_WHITE,35,8,line,DTA_VIRTUALWIDTHF,640.0,DTA_VIRTUALHEIGHTF,360.0);
        line=String.Format("Avance %.1f m/s | ventana %.1fs | impulso %.2fs | impulsos %d",u.ActualMps,
            effect==null?0:effect.RemainingTics/35.0,effect==null?0:effect.DashTics/35.0,u.Starts);
        Screen.DrawText(SmallFont,Font.CR_WHITE,35,20,line,DTA_VIRTUALWIDTHF,640.0,DTA_VIRTUALHEIGHTF,360.0);
    }
}
