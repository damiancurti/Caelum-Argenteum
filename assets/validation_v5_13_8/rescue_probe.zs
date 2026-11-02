class CA601MatchProbe : StaticEventHandler
{
    bool Done;
    void Check(bool ok,String label){Console.Printf("CA601 %s %s",ok?"PASS":"FAIL",label);}
    override void WorldTick()
    {
        let m=CaelumStandaloneMatch.View();if(Done || m==null || m.Hunt==null)return;
        let h=m.Hunt;h.Hunter.bDormant=true;
        let a=CaelumPlayer(players[0].mo);let b=CaelumPlayer(players[1].mo);
        if(level.time==100)
        {a.CurrentAir=123;h.CapturePlayer(a);b.SetOrigin(a.Pos+(48,0,0),false);b.Angle=180;}
        if(level.time==150)Check(h.Captive(0) && h.RescueProgress[1]>0 && h.RescueProgress[1]<105,"native held Use accumulates partial rescue");
        if(level.time==175)Check(h.Captive(0) && h.RescueProgress[1]==0,"native Use release discards partial progress");
        if(level.time==260)Check(h.Captive(0),"rescue requires a full uninterrupted three seconds");
        if(level.time==295)
        {
            Check(!h.Captive(0) && CaelumPlayerAuthority.CanMutate(a),"native held Use frees teammate after three seconds");
            Check(a.CurrentAir>=123 && a.health>0,"rescued teammate keeps resources and resumes physiology");
            Console.Printf("CA601 RESULT hunt");Done=true;
        }
    }
}
