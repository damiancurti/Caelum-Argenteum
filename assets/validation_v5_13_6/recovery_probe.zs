class CA599MatchProbe : StaticEventHandler
{
    bool Done,Checked,Restart;int Respawns;
    override void PlayerRespawned(PlayerEvent e){Respawns++;}
    void Check(bool ok,String label){Console.Printf("CA599 %s %s",ok?"PASS":"FAIL",label);}
    override void WorldTick()
    {
        let m=CaelumStandaloneMatch.View();if(Done || m==null || !m.Started)return;
        if(Restart && !m.Finished)
        {
            Check(m.Mode==2 && m.Members==15,"recovered mode survives rematch despite launch mode zero");
            Check(m.Team[0]==0 && m.Team[1]==1 && m.Team[2]==0 && m.Team[3]==1,"recovered rematch retains team assignment");
            Check(m.TeamScore(0)==0 && m.TeamScore(1)==0,"recovered rematch clears score");
            Console.Printf("CA599 RESULT deathmatch");Done=true;return;
        }
        if(!Checked)
        {
            Checked=true;
            Check(m.Mode==2 && m.Revision==2 && m.Members==15,"save supplies authoritative team mode");
            Check(m.Team[0]==0 && m.Team[1]==1 && m.Team[2]==0 && m.Team[3]==1,"save preserves balanced membership");
            Check(m.TeamScore(0)==0 && m.TeamScore(1)==-1,"save preserves scored penalties");
            Check(m.RespawnAt[1]==280 && m.RespawnAt[2]==280 && m.RespawnAt[3]==280,"save preserves all respawn deadlines");
        }
        if(level.time==340)
        {
            Check(Respawns==3,"recovery respawns three deaths once");
            Check(m.TeamScore(0)==0 && m.TeamScore(1)==-1,"recovery does not rescore deaths");
            m.Score[0]=20;m.Evaluate();
            for(int i=0;i<4;i++)m.VoteRematch(i);Restart=true;
        }
    }
}
