class CA599MatchProbe : StaticEventHandler
{
    bool Done;
    override void UiTick(){if(Done && menuactive==0)Menu.SetMenu('CaelumStandaloneScoreMenu');}
    void Check(bool ok,String label){Console.Printf("CA599 %s %s",ok?"PASS":"FAIL",label);}
    override void WorldTick()
    {
        let m=CaelumStandaloneMatch.View();if(Done || m==null || !m.Started)return;
        if(level.time==175)
        {
            m.Score[0]=3;m.Score[1]=1;m.Score[2]=-1;m.Score[3]=1;
            m.Elapsed=CaelumStandaloneData.TIME_LIMIT_TICS;m.Evaluate();
            Check(!m.Finished && m.TeamScore(0)==m.TeamScore(1),"equal team totals enter overtime despite individual lead");
            let a=CaelumStandalonePlayer(players[0].mo);let c=CaelumStandalonePlayer(players[2].mo);
            c.DamageMobj(a,a,10000000,'None',DMG_FORCED|DMG_NO_ARMOR,0);
        }
        if(level.time==178)
        {
            Check(m.Finished && m.Winner==1,"overtime teamkill awards victory to other team");
            Check(m.TeamScore(0)==1 && m.TeamScore(1)==2,"teamkill changes only responsible score");
            Check((players[0].cheats&CF_TOTALLYFROZEN)!=0 && (players[3].cheats&CF_TOTALLYFROZEN)!=0,"shared result stops both teams");
            Console.Printf("CA599 RESULT deathmatch");Done=true;
        }
    }
}
