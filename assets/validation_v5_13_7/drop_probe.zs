class CA600MatchProbe : StaticEventHandler
{
    bool Done;
    void Check(bool ok,String label){Console.Printf("CA600 %s %s",ok?"PASS":"FAIL",label);}
    override void WorldTick()
    {
        let m=CaelumStandaloneMatch.View();if(Done || m==null || m.Capture==null || level.time!=175)return;
        let f=m.Capture;let a=CaelumPlayer(players[0].mo);let b=CaelumPlayer(players[1].mo);
        a.SetOrigin(f.Objectives[1].Pos,false);f.TouchObjective(m,a,1);
        a.SetOrigin((192,192,0),false);a.DamageMobj(b,b,10000000,'None',DMG_FORCED|DMG_NO_ARMOR,0);
        Check(f.Dropped[1] && f.ReturnAt[1]==1225,"native drop schedules original return deadline");
        Console.Printf("CA600 RESULT deathmatch");Done=true;
    }
}
