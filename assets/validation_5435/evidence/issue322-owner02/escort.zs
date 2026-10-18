// Reproducción aislada del giro y de la distancia recorrida por el acompañante.
class CA322Probe : CA282Probe
{
    CaelumAnchoredResident Body;
    bool Measuring;
    int Age, Turns, Frames, SeeFrames;
    double PreviousAngle, Turning, Distance;
    Vector3 Previous;
    State PreviousState;

    void ResetTrace()
    {
        Age=0;Turns=0;Frames=0;SeeFrames=0;Turning=0;Distance=0;
        Previous=Body.Pos;PreviousAngle=Body.Angle;PreviousState=Body.CurState;
        Measuring=true;
    }
    void Report()
    {
        Console.Printf("CA322 TRACE age=%d distance=%.6f turning=%.6f turns=%d states=%d see=%d base=%.6f speed=%.6f hp=%d max=%d thermal=%.6f pos=(%.3f,%.3f) angle=%.3f",
            Age,Distance,Turning,Turns,Frames,SeeFrames,Body.CombatBaseSpeed,Body.Speed,
            Body.health,Body.CombatMaximumHealth,CaelumThermalEffects.Speed(Body),Body.Pos.X,Body.Pos.Y,Body.Angle);
    }
    override void WorldTick()
    {
        if(!Measuring || Body==null)return;
        Age++;
        double turn=abs(Body.DeltaAngle(PreviousAngle,Body.Angle));
        if(turn>0.001)Turns++;
        Turning+=turn;Distance+=(Body.Pos-Previous).Length();
        if(Body.CurState!=PreviousState)Frames++;
        if(Body.InStateSequence(Body.CurState,Body.FindState("See")))SeeFrames++;
        if(Age<=8)Console.Printf("CA322 STEP age=%d x=%.4f y=%.4f angle=%.4f vel=(%.4f,%.4f) frame=%d target=%s",
            Age,Body.Pos.X,Body.Pos.Y,Body.Angle,Body.Vel.X,Body.Vel.Y,Body.Frame,Body.Target==null?'none':Body.Target.GetClassName());
        Previous=Body.Pos;PreviousAngle=Body.Angle;PreviousState=Body.CurState;
        if(Age%35==0)Report();
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        Super.NetworkProcess(e);
        if(e.Name=="c322_seed")
        {
            Setup();User.SetOrigin((0,0,0),false);User.Vel=(0,0,0);
            User.SetPlayerPrisonerRescueState(0,CaelumConstants.PRISONER_STATE_CAPTIVE);
            Body=CaelumAnchoredResident(Actor.Spawn("CaelumPrisonerUnitario",(80,0,0),NO_REPLACE));
            Body.ChangeTid(322);
        }
        if(e.Name=="c322_trace") {Body.ReleaseEscortPrisoner(User);ResetTrace();}
        if(e.Name=="c322_far") {Report();User.SetOrigin((-512,0,0),false);ResetTrace();}
        if(e.Name=="c322_noise") {Report();User.SetOrigin((0,0,0),false);Body.SetOrigin((80,40,0),false);User.SoundAlert(User);ResetTrace();}
        if(e.Name=="c322_done") {Measuring=false;Check(Body!=null && Body.health>0,"released follower remains present");Console.Printf("CA282 DONE passes=%d failures=%d",Passed,Failed);}
    }
}
