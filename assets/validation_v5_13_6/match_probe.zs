class CA599MatchProbe : StaticEventHandler
{
    bool Done,RematchRequested;int Respawns;
    override void PlayerRespawned(PlayerEvent e){Respawns++;}
    void Check(bool ok,String label){Console.Printf("CA599 %s %s",ok?"PASS":"FAIL",label);}
    override void WorldTick()
    {
        let m=CaelumStandaloneMatch.View();if(Done || m==null || !m.Started)return;
        let a=CaelumStandalonePlayer(players[0].mo);let b=CaelumStandalonePlayer(players[1].mo);
        let c=CaelumStandalonePlayer(players[2].mo);let d=CaelumStandalonePlayer(players[3].mo);
        if(RematchRequested)
        {
            if(m.Finished)return;
            Check(m.Mode==2 && m.Members==15 && m.Revision==2,"rematch preserves mode and roster");
            Check(m.Team[0]==0 && m.Team[1]==1 && m.Team[2]==0 && m.Team[3]==1,"rematch preserves balanced entry-order teams");
            Check(m.TeamScore(0)==0 && m.TeamScore(1)==0 && m.Elapsed<35,"rematch resets both teams and time");
            Check(a.health>0 && b.health>0 && c.health>0 && d.health>0,"rematch restores all participants");
            Console.Printf("CA599 RESULT deathmatch");Done=true;return;
        }
        if(level.time==175)
        {
            Check(m.Mode==2 && m.Members==15 && m.Revision==2,"four real peers share team mode");
            Check(m.Team[0]==0 && m.Team[1]==1 && m.Team[2]==0 && m.Team[3]==1,"entry order yields balanced teams");
            Check(CaelumTarotLovers.AlliedPlayers(a,c) && CaelumRedemption.Allied(a,c),"support recognizes actual teammate");
            Check(!CaelumTarotLovers.AlliedPlayers(a,b) && CaelumMajorTargets.Enemy(a,b),"support and offense distinguish opposing team");
            int hp=c.health;c.DamageMobj(a,a,1000,'None',DMG_NO_ARMOR,0);
            Check(c.health<hp,"unforced native damage permits friendly fire");
            b.DamageMobj(a,a,10000000,'None',DMG_FORCED|DMG_NO_ARMOR,0);
            Check(m.Score[0]==1 && m.TeamScore(0)==1,"enemy kill credits player and team once");
            c.DamageMobj(a,a,10000000,'None',DMG_FORCED|DMG_NO_ARMOR,0);
            Check(m.Score[0]==0 && m.Score[2]==0 && m.TeamScore(0)==0,"teamkill penalizes responsible player and team");
            d.DamageMobj(d,d,10000000,'None',DMG_FORCED|DMG_NO_ARMOR,0);
            Check(m.Score[3]==-1 && m.TeamScore(1)==-1,"suicide penalizes responsible team");
            m.RecordDeath(c,a);Check(m.Score[0]==0 && m.Deaths[2]==1,"duplicate teammate death cannot penalize twice");
        }
        if(level.time==340)
        {
            Check(Respawns==3 && b.health>0 && c.health>0 && d.health>0,"three native deaths respawn after their delay");
            Check(m.Team[1]==1 && m.Team[2]==0 && m.Team[3]==1,"body replacement preserves teams");
            Check(b.StandalonePreset==1 && c.StandalonePreset==2 && d.StandalonePreset==3,"respawn retains each resident preset");
            Check(m.TeamScore(0)==0 && m.TeamScore(1)==-1,"respawn does not reset score");
        }
        if(level.time==520)
        {
            m.Score[0]=10;m.Score[2]=9;
            b.DamageMobj(c,c,10000000,'None',DMG_FORCED|DMG_NO_ARMOR,0);
        }
        if(level.time==522)
        {
            Check(m.Finished && m.Winner==0 && m.TeamScore(0)==20,"combined twentieth frag wins for team");
            Check(m.Score[0]==10 && m.Score[2]==10,"no individual needs twenty frags");
            Check(m.Elapsed<CaelumStandaloneData.TIME_LIMIT_TICS,"frag victory precedes clock limit");
            m.VoteRematch(0);m.VoteRematch(1);m.VoteRematch(2);
            Check(!m.Restarting,"three of four votes cannot restart");
        }
        if(level.time==560){RematchRequested=true;m.VoteRematch(3);}
    }
}
