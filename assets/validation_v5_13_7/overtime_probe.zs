class CA600MatchProbe : StaticEventHandler
{
    bool Done;
    void Check(bool ok,String label){Console.Printf("CA600 %s %s",ok?"PASS":"FAIL",label);}
    override void UiTick(){if(Done && menuactive==0)Menu.SetMenu('CaelumStandaloneScoreMenu');}
    override void WorldTick()
    {
        let m=CaelumStandaloneMatch.View();if(Done || m==null || m.Capture==null)return;
        let f=m.Capture;let a=CaelumPlayer(players[0].mo);let b=CaelumPlayer(players[1].mo);
        if(level.time==175)
        {
            Check(f.Bases[0].Pos==CaelumArenaData.Start(1,0) && f.Bases[1].Pos==CaelumArenaData.Start(1,4),"maze bases use approved opposite starts");
            m.Score[0]=m.Score[1]=1;m.Elapsed=CaelumStandaloneData.TIME_LIMIT_TICS;m.Evaluate();
            Check(!m.Finished,"equal capture totals enter overtime");
            b.SetOrigin(f.Objectives[0].Pos,false);f.TouchObjective(m,b,0);
            b.SetOrigin(f.Bases[1].Pos,false);f.TouchBase(m,b,1);f.TouchBase(m,b,1);
        }
        if(level.time==178)
        {
            Check(m.Finished && m.Winner==1 && m.TeamScore(1)==2,"next single capture wins overtime");
            Check(m.Score[0]==1 && m.Score[1]==2,"duplicate simultaneous capture callback awards one point");
            Console.Printf("CA600 RESULT deathmatch");Done=true;
        }
    }
}
