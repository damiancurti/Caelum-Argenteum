// Test-only instrumentation: input still passes through native player commands.
class CA260Player : CaelumPlayer
{
    int InputTics, TestMass, TestLoad, Mode, Samples;
    bool Audit;
    double PeakSpeedError, PeakDistanceError, PeakFactorError, PreviousSpeed, PreviousFactor;
    vector3 PreviousPosition;
    bool SnapshotEnabled, ExternalProbe;
    double SavedFactor, SavedStep, SavedSeconds, PeakExternalError, JumpFactor, ActualMovementMps;
    override void Tick()
    {
        vector3 before=Pos;
        Super.Tick();
        vector3 travelled=Pos-before;
        ActualMovementMps=CaelumPhysicsUnits.VelocitySI(travelled.XY.Length());
        if(SnapshotEnabled)
        {SavedFactor=MovementAccelerationFactor;SavedStep=MovementAccelerationStep;SavedSeconds=MovementAccelerationSeconds;}
    }
    override void MovePlayer()
    {
        double factor=MovementAccelerationFactor;
        vector3 before=Vel;
        Super.MovePlayer();
        if(ExternalProbe)PeakExternalError=Max(PeakExternalError,Abs(Vel.Y-before.Y));
        if(Audit && (player.cmd.forwardmove || player.cmd.sidemove))
        {
            InputTics++;
            double friction, moveFactor;[friction,moveFactor]=GetFriction();
            double command=Sqrt(double(player.cmd.forwardmove)**2+double(player.cmd.sidemove)**2)/6400;
            double steady=4*command*player.crouchfactor*EffectiveMovementPercent/100*CaelumThermalEffects.Speed(self);
            if(bNOGRAVITY && bFLY)steady*= (1-0.90625)/(1-friction);
            else if(WaterLevel>=2)steady*=0.5;
            double expectedFactor=Min(1.0,double(InputTics-1)/(3*(TestMass+TestLoad)/100.0*TICRATE));
            double speed=CaelumPhysicsUnits.VelocitySI(Vel.XY.Length());
            PeakSpeedError=Max(PeakSpeedError,Abs(speed-steady*factor));
            PeakFactorError=Max(PeakFactorError,Abs(factor-expectedFactor));
            vector3 travelled=Pos-PreviousPosition;
            if(InputTics>1)
                PeakDistanceError=Max(PeakDistanceError,Abs(CaelumPhysicsUnits.VelocitySI(travelled.XY.Length())-PreviousSpeed));
            PreviousPosition=Pos;PreviousSpeed=speed;PreviousFactor=factor;Samples++;
            if(InputTics<=4 || InputTics%26==0 || InputTics>=104 && InputTics<=108 || InputTics==211 || InputTics==260)
                Console.Printf("CA260 TRACE input=%d factor=%.9f step=%.9f v=%.9f before=%.9f x=%.9f fwd=%.9f side=%.9f mass=%.6f",
                    InputTics,factor,MovementAccelerationStep,CaelumPhysicsUnits.VelocitySI(Vel.XY.Length()),
                    CaelumPhysicsUnits.VelocitySI(before.XY.Length()),Pos.X,ForwardMove1,SideMove1,DerivedStats.TotalMass);
        }
    }
}
class CA260Probe : StaticEventHandler
{
    int Age,Passed,Failed;
    bool Active;
    void Check(bool ok,String label)
    {if(ok)Passed++;else Failed++;Console.Printf("CA260 %s %s",ok?"PASS":"FAIL",label);}
    override void WorldLoaded(WorldEvent e)
    {
        if(!e.IsSaveGame)return;
        let u=CA260Player(players[0].mo);Active=true;u.Audit=false;
        Check(u!=null && u.SavedFactor>0 && u.SavedFactor<1,"copied save contains an unfinished ramp");
        Check(Abs(u.SavedFactor-u.MovementAccelerationFactor)<0.00000001,"save/load retains the exact ramp fraction");
        Check(Abs(u.SavedSeconds-u.MovementAccelerationSeconds)<0.00000001,"save/load retains elapsed simulation seconds");
        Check(u.MovementAccelerationRevision==0 || Abs(u.SavedStep-u.MovementAccelerationStep)<0.00000001,"current saves retain next-tic compensation");
    }
    override void UiTick(){if(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();}
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CA260Player(players[0].mo);
        if(e.Name=="c260_setup")
        {
            Active=true;u.CreationWizardOpen=false;u.CharacterCreationComplete=true;
            u.TestMass=e.Args[0]>0?e.Args[0]:100;u.TestLoad=e.Args[1];u.Mode=e.Args[2];
            u.bInvulnerable=true;u.bNOTARGET=true;u.CombatBlockModeActive=false;u.ShieldModel.Equipped=false;
            u.LucidityPhysicalStunRemaining=0;u.PainImmobilizationRemaining=0;u.ForcedSleepTics=0;
            u.SetOrigin((0,0,u.Mode==1?200:0),false);u.Vel=(0,0,0);u.Angle=0;u.Pitch=0;
            u.bNOGRAVITY=u.Mode==1;u.bFLY=u.Mode==1;
            u.MovementAccelerationFactor=0;u.MovementAccelerationStep=0;u.InputTics=0;
            u.PeakSpeedError=0;u.PeakDistanceError=0;u.PeakFactorError=0;u.Samples=0;u.Audit=true;
            Console.Printf("CA260 CASE body=%d load=%d medium=%d",u.TestMass,u.TestLoad,u.Mode);
        }
        if(e.Name=="c260_check")
        {
            Console.Printf("CA260 ERRORS speed=%.9f distance=%.9f factor=%.9f samples=%d",u.PeakSpeedError,u.PeakDistanceError,u.PeakFactorError,u.Samples);
            Check(u.Samples>=220,"native input recorded a complete ramp and steady interval");
            Check(u.PeakSpeedError<0.00001,"actual velocity is linear and retains the native steady cap");
            Check(u.PeakDistanceError<0.00001,"actual world displacement follows the previous command velocity");
            Check(u.PeakFactorError<0.00001,"mass controls 25/50/75/100 percent with one input-tic startup");
            Check(u.Mode!=2 || u.WaterLevel==3,"water scenario uses real underwater geometry");
            u.Audit=false;
        }
        if(e.Name=="c260_stopped")Check(u.Vel.XY.Length()<0.00001 && u.MovementAccelerationFactor==0,"native friction stops and released input resets ramp");
        if(e.Name=="c260_dynamic")
        {u.Audit=false;u.SavedStep=u.MovementAccelerationStep;u.TestLoad=100;}
        if(e.Name=="c260_dynamic_check")
        {
            Console.Printf("CA260 DYNAMIC old=%.12f new=%.12f mass=%.6f factor=%.6f immobilized=%d",u.SavedStep,u.MovementAccelerationStep,u.DerivedStats.TotalMass,u.MovementAccelerationFactor,u.IsPhysicallyImmobilized());
            Check(Abs(u.MovementAccelerationStep-u.SavedStep/2)<0.00000001,"adding load mid-ramp immediately halves its increment");
        }
        if(e.Name=="c260_push")
        {u.Audit=false;u.ExternalProbe=true;u.PeakExternalError=0;u.Vel.Y+=2;}
        if(e.Name=="c260_push_check")
        {Check(u.Vel.Y>0 && u.PeakExternalError<0.00000001,"forward compensation preserves the external sideways impulse");u.ExternalProbe=false;}
        if(e.Name=="c260_airborne")
        {u.Audit=false;u.SetOrigin((0,0,2000),false);u.Vel.Z=0;u.JumpFactor=u.MovementAccelerationFactor;}
        if(e.Name=="c260_airborne_check")Check(u.Pos.Z>u.FloorZ && u.Vel.Z<0 && Abs(u.JumpFactor-u.MovementAccelerationFactor)<0.00000001,"ordinary airborne movement keeps falling and freezes ramp progress");
        if(e.Name=="c260_snapshot"){u.Audit=false;u.SnapshotEnabled=true;}
        if(e.Name=="c260_revision")
        {
            u.MovementAccelerationRevision=0;u.MovementAccelerationFactor=0.4;
            u.UpdateMovementAcceleration();double once=u.MovementAccelerationFactor;
            u.UpdateMovementAcceleration();
            Check(u.MovementAccelerationRevision==1 && Abs(u.MovementAccelerationFactor-once-u.MovementAccelerationStep)<0.00000001,"revision-one migration preserves progress and subsequent calls advance normally");
        }
        if(e.Name=="c260_inventory")
        {
            Active=false;u.Audit=false;u.DerivedStats.DebugWeight=0;u.GrantMagicBoxFromPalomo(false);
            u.RefreshCarriedInventorySummary();double original=u.DerivedStats.TotalMass;
            double oldBox=u.HUDMagicBoxTotalWeight;
            let equipped=CaelumEquipmentItem(Actor.Spawn("CaelumEquipmentItem"));
            let personal=CaelumEquipmentItem(Actor.Spawn("CaelumEquipmentItem"));
            let boxed=CaelumEquipmentItem(Actor.Spawn("CaelumEquipmentItem"));
            equipped.PickupDataInitialized=true;equipped.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_WEAPON;
            equipped.UnitWeight=20;equipped.Amount=1;equipped.Equipped=true;equipped.AttachToOwner(u);
            personal.PickupDataInitialized=true;personal.UnitWeight=10;personal.Amount=1;personal.AttachToOwner(u);
            boxed.PickupDataInitialized=true;boxed.UnitWeight=40;boxed.Amount=1;boxed.InMagicBox=true;boxed.AttachToOwner(u);
            u.RefreshCarriedInventorySummary();double boxedMass=u.DerivedStats.TotalMass;
            double boxDelta=u.HUDMagicBoxTotalWeight-oldBox;
            Check(Abs(boxedMass-original-30-boxDelta)<0.0000001,"authoritative total counts equipped and personal items plus reduced Box content once");
            u.MovementAccelerationFactor=0.2;u.UpdateMovementAcceleration();
            Check(Abs(u.MovementAccelerationStep-100.0/(3*TICRATE*boxedMass))<0.0000001,"ramp consumes authoritative native inventory mass");
            boxed.InMagicBox=false;u.RefreshCarriedInventorySummary();
            Check(Abs(u.DerivedStats.TotalMass-boxedMass-40+boxDelta)<0.0000001,"moving content out of Box updates total weight without duplication");
            double beforeRemove=u.DerivedStats.TotalMass;equipped.Destroy();u.RefreshCarriedInventorySummary();
            Check(Abs(u.DerivedStats.TotalMass-beforeRemove+20)<0.0000001,"removing equipped weight updates the same total");
            personal.Destroy();boxed.Destroy();
        }
        if(e.Name=="c260_done")Console.Printf("CA260 DONE failures=%d passes=%d",Failed,Passed);
    }
    override void WorldTick()
    {
        Age++;
        let u=CA260Player(players[0].mo);if(!Active || u==null || u.DerivedStats==null)return;
        u.Attributes.SetAllForDebug(0);u.DerivedStats.Recalculate(u.Attributes,u.CharacterProfile);
        let d=u.DerivedStats;
        d.BaseMass=u.TestMass;d.CarriedItemWeight=0;d.DebugWeight=u.TestLoad;d.RefreshCarriedWeightTotals();d.LoadRatio=0;
        u.health=u.CaelumMaximumHealth;u.player.health=u.health;
        u.CurrentHunger=100;u.CurrentThirst=100;u.CurrentSleep=100;
        u.SurvivalPerformanceMultiplier=1;u.HealthPerformanceMultiplier=1;u.CurrentAir=d.MaximumAir;
        CaelumThermalBody.Get(u,true).Exposure=0;
        u.UpdateAirStateEffects();u.ApplyPhysicalMovement();
    }
    override void RenderOverlay(RenderEvent e)
    {
        let u=CA260Player(players[consoleplayer].mo);if(u==null || !Active)return;
        String line=String.Format("#260 (parcial) | F6: 50 kg | F7: 100 kg | F8: 200 kg");
        Screen.DrawText(SmallFont,Font.CR_WHITE,60,8,line,DTA_VIRTUALWIDTHF,640.0,DTA_VIRTUALHEIGHTF,360.0);
        line=String.Format("Masa %.1f kg | rampa %.1f %% | avance %.2f m/s",u.DerivedStats.TotalMass,u.MovementAccelerationFactor*100,u.ActualMovementMps);
        Screen.DrawText(SmallFont,Font.CR_WHITE,60,20,line,DTA_VIRTUALWIDTHF,640.0,DTA_VIRTUALHEIGHTF,360.0);
    }
}
