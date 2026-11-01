class CA617Probe : StaticEventHandler
{
    bool Done;
    void Check(bool value,String name){Console.Printf("CA617 %s %s",value?"PASS":"FAIL",name);}
    override void WorldTick()
    {
        let m=CaelumStandaloneMatch.View();if(m==null || !m.Started || m.Hunt==null || Done)return;
        int slot=m.PlayerPalomo-1;
        Check(slot>=0 && slot<MAXPLAYERS,"saved role survives launch CVar reset");if(slot<0){Done=true;return;}
        Check(CaelumTarotHunt.HumanHunter(CaelumPlayer(players[slot].mo)) && m.Hunt.Hunter==null,"saved body and no AI duplicate");
        Check(CaelumPlayer(players[slot].mo).AirState==CaelumConstants.AIR_STATE_NORMAL,"saved Palomo Air is displayed as normal");
        Check(m.Hunt.Captive((slot+1)%4) && !m.Hunt.Captive(slot),"saved capture mask excludes hunter");
        for(int i=0;i<MAXPLAYERS;i++)if(m.Seeker(i))m.Hunt.CapturePlayer(CaelumPlayer(players[i].mo));
        m.Hunt.Tick(m);
        Check(m.Finished && m.Winner==-1,"hunter wins when every seeker is captive");
        Console.Printf("CA617 RESULT hunter");Done=true;
    }
}
