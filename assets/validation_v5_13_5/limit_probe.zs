class CA598MatchProbe : StaticEventHandler
{
    bool Done;
    override void UiTick()
    {if(Done && gamestate==GS_LEVEL && menuactive==0)Menu.SetMenu('CaelumStandaloneScoreMenu');}
    void Check(bool ok,String label){Console.Printf("CA598 %s %s",ok?"PASS":"FAIL",label);}
    override void WorldTick()
    {
        let match=CaelumStandaloneMatch.View();if(Done || match==null || !match.Started)return;
        let first=CaelumStandalonePlayer(players[0].mo);let second=CaelumStandalonePlayer(players[1].mo);
        if(level.time==175)
        {
            Check(first.Pos!=second.Pos && first.health>0 && second.health>0,"arena has separate valid starts");
            match.Score[0]=CaelumStandaloneData.FRAG_LIMIT-1;
            second.DamageMobj(first,first,10000000,'None',DMG_FORCED|DMG_NO_ARMOR,0);
        }
        if(level.time==178)
        {
            Check(match.Finished && match.Winner==0 && match.Score[0]==20,"twentieth frag ends the match");
            Check(match.Elapsed<CaelumStandaloneData.TIME_LIMIT_TICS,"frag victory precedes time limit");
            Check((first.player.cheats&CF_TOTALLYFROZEN)!=0,"winner is stopped after resolution");
            Console.Printf("CA598 RESULT deathmatch");Done=true;
        }
    }
}
