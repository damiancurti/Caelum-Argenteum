class CA617Probe : StaticEventHandler
{
    bool Done;
    override void WorldTick()
    {
        let m=CaelumStandaloneMatch.View();if(m==null || !m.Started || m.Hunt==null || Done)return;
        bool good=m.PlayerPalomo==0 && m.Hunt.Hunter!=null;
        for(int i=0;i<MAXPLAYERS;i++)if(m.Member(i))good=good && m.Seeker(i) && !CaelumTarotHunt.HumanHunter(CaelumPlayer(players[i].mo));
        Console.Printf("CA617 %s fewer than four actual participants retain NPC Palomo",good?"PASS":"FAIL");
        m.Hunt.Hunter.bDormant=true;Console.Printf("CA617 RESULT hunter");Done=true;
    }
}
