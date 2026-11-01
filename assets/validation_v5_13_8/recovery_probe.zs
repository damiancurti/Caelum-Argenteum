class CA601MatchProbe : StaticEventHandler
{
    bool Done;
    void Check(bool ok,String label){Console.Printf("CA601 %s %s",ok?"PASS":"FAIL",label);}
    override void WorldTick()
    {
        let m=CaelumStandaloneMatch.View();if(Done || m==null || m.Hunt==null)return;
        let h=m.Hunt;let a=CaelumPlayer(players[0].mo);h.Hunter.bDormant=true;
        Check(m.Mode==4 && level.MapName=="CAHUNT","saved hunt mode restores without launch CVar");
        Check(h.Collected==2 && h.Found[0] && h.Found[1],"recovery preserves distinct collection");
        Check(h.Captive(0) && a.health==321 && a.CurrentAir==123,"recovery preserves captive resources");
        h.Rescue(0);Check(!h.Captive(0) && a.health==321,"saved captive can be rescued");
        for(int i=0;i<4;i++)h.CapturePlayer(CaelumPlayer(players[i].mo));
        h.Tick(m);Check(m.Finished && m.Winner==-1,"all four captured lose together");
        Console.Printf("CA601 RESULT hunt");Done=true;
    }
}
