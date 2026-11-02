class CA600MatchProbe : StaticEventHandler
{
    bool Done,Checked;
    void Check(bool ok,String label){Console.Printf("CA600 %s %s",ok?"PASS":"FAIL",label);}
    override void WorldTick()
    {
        let m=CaelumStandaloneMatch.View();if(Done || m==null || m.Capture==null)return;
        let f=m.Capture;
        if(!Checked)
        {
            Checked=true;
            Check(m.Mode==3 && m.Members==15,"save restores capture mode without launch CVar");
            Check(f.Revision==1 && f.Carrier[0]==1 && f.Carrier[1]==0,"save retains both objective carriers");
            Check(!f.Home(0) && !f.Home(1) && m.TeamScore(0)==0,"save preserves denied capture and score");
            int count=0;let it=ThinkerIterator.Create('CaelumCaptureObjective');while(it.Next()!=null)count++;
            Check(count==2,"recovery does not duplicate objective actors");
        }
        if(level.time==240)
        {
            let b=CaelumPlayer(players[1].mo);let c=CaelumPlayer(players[2].mo);
            b.DamageMobj(c,c,10000000,'None',DMG_FORCED|DMG_NO_ARMOR,0);
            Check(f.Dropped[0] && f.Carrier[0]<0,"recovered carrier death drops its original objective");
            f.ReturnHome(0);
        }
        if(level.time==245)
        {
            Check(f.Home(0) && f.Home(1) && m.TeamScore(0)==1,"recovered waiting carrier captures once after return");
            Console.Printf("CA600 RESULT deathmatch");Done=true;
        }
    }
}
