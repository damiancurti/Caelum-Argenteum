// Isolated native-command instrumentation; production owns gesture and payment.
class CA260ImpulsePlayer : CA260Player
{
    int Impulses;
    double ImpulseAir,ImpulseAnima,ImpulseError,DebitError,LastImpulseSpeed;
    double ImpulseDistanceError;
    bool MeasureImpulse;
    vector2 ExpectedImpulseMove;
    override void Tick()
    {
        vector3 before=Pos;
        bool measure=MeasureImpulse;MeasureImpulse=false;
        vector2 expected=ExpectedImpulseMove;
        Super.Tick();
        if(measure)ImpulseDistanceError=Max(ImpulseDistanceError,(Pos.XY-before.XY-expected).Length());
    }
    override void MovePlayer()
    {
        double air=CurrentAir,anima=CurrentAnima;
        double expectedCost=2*DerivedStats.AirConsumptionMultiplier*CaelumThermalEffects.HeatCost(self)
            *3*DerivedStats.TotalMass/100;
        bool substitution=CaelumAirPayment.Substituting(self);
        double expectedAnima=CaelumAirPayment.AnimaCost(self,expectedCost);
        Super.MovePlayer();
        double spent=air-CurrentAir,animaSpent=anima-CurrentAnima;
        if(spent>0.00000001 || animaSpent>0.00000001)
        {
            Impulses++;ImpulseAir+=spent;ImpulseAnima+=animaSpent;
            DebitError=Max(DebitError,Abs((substitution?animaSpent:spent)-(substitution?expectedAnima:expectedCost)));
            double friction,moveFactor;[friction,moveFactor]=GetFriction();
            double command=Sqrt(double(player.cmd.forwardmove)**2+double(player.cmd.sidemove)**2)/6400;
            double steady=4*command*player.crouchfactor*EffectiveMovementPercent/100*CaelumThermalEffects.Speed(self);
            if(bNOGRAVITY && bFLY)steady*= (1-0.90625)/(1-friction);
            else if(WaterLevel>=2)steady*=0.5;
            LastImpulseSpeed=CaelumPhysicsUnits.VelocitySI(Vel.XY.Length());
            ImpulseError=Max(ImpulseError,Abs(LastImpulseSpeed-steady));
            MeasureImpulse=true;ExpectedImpulseMove=Vel.XY;
            Console.Printf("CA260 IMPULSE count=%d air=%.9f anima=%.9f speed=%.9f cap=%.9f mass=%.3f mode=%d water=%d",Impulses,spent,animaSpent,LastImpulseSpeed,steady,DerivedStats.TotalMass,Mode,WaterLevel);
        }
    }
}
class CA260ImpulseProbe : CA260Probe
{
    double PinnedAir;
    bool PinAir, Breathing;
    override void WorldLoaded(WorldEvent e)
    {
        if(!e.IsSaveGame)return;
        Active=true;
        let u=CA260ImpulsePlayer(players[0].mo);u.Audit=false;
        Check(u.MovementTapPending==0 && !u.MovementTapReady && u.MovementTapTimes[0]==0,
            "loading discards pending and half-finished gesture fields");
        Check(u.Impulses==0 && u.MovementAccelerationFactor>0 && u.MovementAccelerationFactor<1,
            "save retains ordinary progress without inventing an impulse");
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CA260ImpulsePlayer(players[0].mo);
        Super.NetworkProcess(e);
        if(e.Name=="c260_setup")
        {
            u.Audit=false;u.Impulses=0;u.ImpulseAir=0;u.ImpulseAnima=0;u.ImpulseError=0;u.DebitError=0;u.ImpulseDistanceError=0;
            PinAir=false;Breathing=false;CaelumRacialAbilityRules.Deactivate(u);CaelumMovementImpulse.Clear(u);
        }
        if(e.Name=="c260i_air"){PinAir=true;PinnedAir=e.Args[0];}
        if(e.Name=="c260i_check")
        {
            Check(u.Impulses==e.Args[0],String.Format("gesture has exactly %d payments (observed %d)",e.Args[0],u.Impulses));
            Check(u.DebitError<0.0000001,"each impulse pays the full mass-based running equivalent exactly once");
            Check(u.ImpulseError<0.00001,"impulse reaches current native mode/direction cap without stacking");
            Check(u.ImpulseDistanceError<0.00001,"native physical displacement matches the impulse velocity");
        }
        if(e.Name=="c260i_menu")u.EquipmentMenuOpen=e.Args[0]!=0;
        if(e.Name=="c260i_stun")u.PainImmobilizationRemaining=e.Args[0]!=0?2:0;
        if(e.Name=="c260i_fall"){u.SetOrigin((0,0,2000),false);u.Vel=(0,0,0);}
        if(e.Name=="c260i_turn")u.Angle=e.Args[0];
        if(e.Name=="c260i_turn_check")Check(Abs(u.Vel.X)<0.000001 && u.Vel.Y>0,"forward impulse follows current facing");
        if(e.Name=="c260i_jump_check")Check(u.Pos.Z>u.FloorZ && u.Impulses==0,"native jump starts without a simultaneous paid impulse");
        if(e.Name=="c260i_wall")u.SetOrigin((30000-u.Radius-1,0,0),false);
        if(e.Name=="c260i_wall_check")Check(u.Pos.X+u.Radius<=30000 && u.Impulses==1,"native wall blocks a paid impulse without teleportation");
        if(e.Name=="c260i_breathing")
        {
            Breathing=true;u.CharacterProfile.Race=CaelumConstants.RACE_CAELITH;
            u.CurrentAnima=100;u.RacialAbilityInputLatched=false;
            Check(CaelumRacialAbilityRules.Begin(u),"real Supernatural Breathing activation");
        }
        if(e.Name=="c260i_breathing_check")
            Check(u.ImpulseAir==0 && u.ImpulseAnima>0 && u.DebitError<0.0000001,"impulse uses only Anima with all current cost modifiers");
        if(e.Name=="c260i_prediction")
        {
            int old=u.player.cheats;double air=u.CurrentAir,factor=u.MovementAccelerationFactor;
            u.MovementTapPending=1;u.player.cheats|=CF_PREDICTING;
            CaelumMovementImpulse.Observe(u,false);
            Check(!CaelumMovementImpulse.Begin(u) && u.CurrentAir==air && u.MovementAccelerationFactor==factor
                && u.MovementTapPending==1,"prediction guard cannot consume the real gesture, resources or ramp");
            u.player.cheats=old;CaelumMovementImpulse.Clear(u);
        }
        if(e.Name=="c260i_disarm")CaelumMovementImpulse.Clear(u);
        if(e.Name=="c260i_external")
        {
            u.Vel=(0,20,0);u.MovementTapPending=1;
            u.player.cmd.forwardmove=6400;u.player.cmd.sidemove=0;
            bool activated=CaelumMovementImpulse.Begin(u);
            CaelumMovementImpulse.Finish(u,(0.1,0,0));
            Check(activated && u.Vel==(0,20,0),"already faster external momentum is preserved and receives no stacked impulse");
            u.player.cmd.forwardmove=0;
        }
        if(e.Name=="c260i_snapshot")
            Console.Printf("CA260 SNAPSHOT count=%d air=%.9f factor=%.9f speed=%.9f mask=%d pending=%d",u.Impulses,u.CurrentAir,u.MovementAccelerationFactor,CaelumPhysicsUnits.VelocitySI(u.Vel.XY.Length()),u.MovementTapMask,u.MovementTapPending);
    }
    override void WorldTick()
    {
        Super.WorldTick();
        let u=CA260ImpulsePlayer(players[0].mo);
        if(!Active || u==null)return;
        if(Breathing)u.DerivedStats.AnimaCostReductionPercent=50;
        if(PinAir){u.CurrentAir=PinnedAir;u.UpdateAirStateEffects();u.ApplyPhysicalMovement();}
    }
    override void RenderOverlay(RenderEvent e)
    {
        let u=CA260ImpulsePlayer(players[consoleplayer].mo);if(u==null || !Active)return;
        String line="#260 impulso | F6/F7/F8: 50/100/200 kg | F9: sin Aire";
        Screen.DrawText(SmallFont,Font.CR_WHITE,60,8,line,DTA_VIRTUALWIDTHF,640.0,DTA_VIRTUALHEIGHTF,360.0);
        line=String.Format("%.0f kg | avance %.2f m/s | impulsos %d | coste ultimo %.2f Aire",u.DerivedStats.TotalMass,u.ActualMovementMps,u.Impulses,u.Impulses>0?u.ImpulseAir/u.Impulses:0);
        Screen.DrawText(SmallFont,Font.CR_WHITE,60,20,line,DTA_VIRTUALWIDTHF,640.0,DTA_VIRTUALHEIGHTF,360.0);
    }
}
