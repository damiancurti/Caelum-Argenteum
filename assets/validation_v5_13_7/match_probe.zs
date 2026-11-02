class CA600MatchProbe : StaticEventHandler
{
    bool Done,Restart;int Respawns;
    override void PlayerRespawned(PlayerEvent e){Respawns++;}
    void Check(bool ok,String label){Console.Printf("CA600 %s %s",ok?"PASS":"FAIL",label);}
    void Move(CaelumPlayer user,vector3 point)
    {user.Vel=(0,0,0);user.SetOrigin(point,false);user.TryMove(point.XY+(0.1,0),false);}
    override void WorldTick()
    {
        let m=CaelumStandaloneMatch.View();if(Done || m==null || m.Capture==null)return;
        let f=m.Capture;
        let a=CaelumStandalonePlayer(players[0].mo);let b=CaelumStandalonePlayer(players[1].mo);
        let c=CaelumStandalonePlayer(players[2].mo);let d=CaelumStandalonePlayer(players[3].mo);
        if(level.time==120){Move(a,(192,192,0));a.Angle=225;}
        if(Restart)
        {
            if(m.Finished)return;
            Check(m.Mode==3 && m.TeamScore(0)==0 && m.TeamScore(1)==0,"rematch resets capture score and preserves mode");
            Check(f.Home(0) && f.Home(1) && f.Carrying(0)<0,"rematch restores two home objectives");
            Check(a.health>0 && b.health>0 && c.health>0 && d.health>0,"rematch restores all four participants");
            Console.Printf("CA600 RESULT deathmatch");Done=true;return;
        }
        if(level.time==175)
        {
            Check(m.Members==15 && m.Mode==3,"four peers share capture mode");
            Check(f.Home(0) && f.Home(1),"both objectives start at home");
            Check(f.Bases[0].Pos==CaelumArenaData.Start(0,0) && f.Bases[1].Pos==CaelumArenaData.Start(0,4),"bases use approved opposite starts");
            Move(a,f.Objectives[1].Pos);
        }
        if(level.time==180)
        {
            Check(f.Carrier[1]==0,"native contact steals opposing objective");
            Move(c,a.Pos);
            f.TouchObjective(m,c,1);Check(f.Carrier[1]==0,"second pickup cannot replace the existing carrier");
            Move(c,(320,64,0));
            Move(b,f.Objectives[0].Pos);
        }
        if(level.time==185)
        {
            Check(f.Carrier[0]==1 && f.Carrier[1]==0,"both teams can carry opposing objectives");
            Move(b,(192,192,0));Move(a,f.Bases[0].Pos);
        }
        if(level.time==195)
            Check(m.TeamScore(0)==0 && f.Carrier[1]==0,"capture denied while own objective is missing");
        if(level.time==230)
        {
            b.DamageMobj(c,c,10000000,'None',DMG_FORCED|DMG_NO_ARMOR,0);
            Check(f.Dropped[0] && f.Carrier[0]<0 && f.ReturnAt[0]==level.time+1050,"carrier death drops objective with thirty-second deadline");
            Check(m.Score[2]==0 && m.TeamScore(1)==0,"kills do not change capture score");
        }
        if(level.time==240)Move(c,f.Objectives[0].Pos);
        if(level.time==245)
        {
            Check(f.Home(0) && f.Home(1) && m.Score[0]==1,"defender return enables waiting carrier capture");
            f.TouchBase(m,a,0);f.TouchBase(m,a,0);
            Check(m.TeamScore(0)==1,"repeated base contacts cannot score twice");
            Move(c,(192,192,0));Move(a,f.Objectives[1].Pos);
        }
        if(level.time==250)
        {
            Check(f.Carrier[1]==0,"returned enemy objective can be stolen again");
            Move(a,(192,64,0));a.DamageMobj(d,d,10000000,'None',DMG_FORCED|DMG_NO_ARMOR,0);
            Check(f.Dropped[1] && m.TeamScore(0)==1,"second carrier death preserves capture score");
        }
        if(level.time==255)Move(c,f.Objectives[1].Pos);
        if(level.time==260)
        {
            Check(f.Carrier[1]==2 && !f.Dropped[1],"teammate continues carrying dropped enemy objective");
            Move(c,f.Bases[0].Pos);
        }
        if(level.time==265)
        {
            Check(m.TeamScore(0)==2 && m.Score[2]==1,"second carrier receives one capture contribution");
            Move(c,f.Objectives[1].Pos);
        }
        if(level.time==270)
        {
            Move(c,(192,192,0));c.DamageMobj(d,d,10000000,'None',DMG_FORCED|DMG_NO_ARMOR,0);
            Check(f.Dropped[1] && f.ReturnAt[1]==level.time+1050,"automatic return timer starts on drop");
            // Probar la frontera del plazo sin consumir treinta segundos por corrida.
            f.ReturnAt[1]=level.time+2;
        }
        if(level.time==274)Check(f.Home(1) && f.ReturnAt[1]==0,"uncollected objective returns at its deadline");
        if(level.time==400)
        {
            Check(Respawns==3 && a.health>0 && b.health>0 && c.health>0,"native preset respawn remains available in capture mode");
            Move(a,f.Objectives[1].Pos);
        }
        if(level.time==405)Move(a,f.Bases[0].Pos);
        if(level.time==410)
        {
            Check(m.Finished && m.Winner==0 && m.TeamScore(0)==3,"third capture wins once for the whole team");
            f.TouchBase(m,a,0);Check(m.TeamScore(0)==3,"finished round rejects later score");
            m.VoteRematch(0);m.VoteRematch(1);m.VoteRematch(2);
            Check(!m.Restarting,"capture rematch still requires all votes");
        }
        if(level.time==450){Restart=true;m.VoteRematch(3);}
    }
}
