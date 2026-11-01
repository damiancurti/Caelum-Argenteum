class CA601MatchProbe : StaticEventHandler
{
    bool Done;
    void Check(bool ok,String label){Console.Printf("CA601 %s %s",ok?"PASS":"FAIL",label);}
    void Move(CaelumPlayer p,vector3 point){p.Vel=(0,0,0);p.SetOrigin(point,false);p.TryMove(point.XY+(0.1,0),false);}
    override void WorldTick()
    {
        let m=CaelumStandaloneMatch.View();if(Done || m==null || m.Hunt==null)return;
        let h=m.Hunt;h.Hunter.bDormant=true;
        let a=CaelumStandalonePlayer(players[0].mo);let b=CaelumStandalonePlayer(players[1].mo);let c=CaelumStandalonePlayer(players[2].mo);
        if(level.time==100)
        {
            Check(h.Traps[0].Kind==0 && h.Traps[1].Kind==1 && h.Traps[2].Kind==2,"three mechanisms repeat across four quarters");
            Move(a,h.Traps[0].Pos-(0,0,0.5));Move(b,h.Traps[1].Pos-(0,0,0.5));Move(c,h.Traps[2].Pos-(0,0,0.5));
        }
        if(level.time==110)
        {
            for(int i=0;i<3;i++)Check(h.Traps[i].Spent && h.Traps[i].RearmAt>=2200 && h.Traps[i].RearmAt<=2205,"native pressure schedules sixty-second rearm");
            Check(h.Traps[0].CurSector.PlaneMoving(Sector.ceiling),"timed door moves native ceiling");
            Check(h.Traps[1].CurSector.floorplane.ZatPoint(h.Traps[1].Pos.XY)==-160,"falling floor lowers by existing pit depth");
            Check(h.Traps[2].StartedPanels==1,"crusher uses one isolated native panel");
            Move(a,CaelumHuntData.Start(0));Move(b,CaelumHuntData.Start(1));Move(c,CaelumHuntData.Start(2));
        }
        if(level.time==190)
        {
            Check(h.Traps[2].CurSector.ceilingplane.ZatPoint(h.Traps[2].Pos.XY)==160,"native crusher returns to original height");
            // El plazo aprobado ya se comprobó; probar el borde sin esperar 60s.
            h.Traps[1].RearmAt=level.time+3;h.Traps[2].RearmAt=level.time+3;
        }
        if(level.time==192)Check(h.Traps[1].Spent && h.Traps[2].Spent,"traps remain spent before deadline");
        if(level.time==200)
        {
            Check(!h.Traps[1].Spent && !h.Traps[2].Spent,"floor and crusher rearm at deadline");
            Check(h.Traps[1].CurSector.floorplane.ZatPoint(h.Traps[1].Pos.XY)==0,"falling floor returns without stranding survivor");
            Move(b,h.Traps[1].Pos-(0,0,0.5));Move(c,h.Traps[2].Pos-(0,0,0.5));
        }
        if(level.time==210)
        {
            Check(h.Traps[1].ActivationCount==2 && h.Traps[2].ActivationCount==2,"floor and crusher can trigger again");
            Move(b,CaelumHuntData.Start(1));Move(c,CaelumHuntData.Start(2));
            // La puerta usa su espera nativa completa, sin acortar el rearme.
        }
        if(level.time==2208)
        {
            Check(!h.Traps[0].Spent && h.Traps[0].RearmAt==0,"timed door rearms after full sixty active seconds");
            Check(!h.Traps[0].CurSector.PlaneMoving(Sector.ceiling),"timed door completed its close-wait-open cycle");
            Move(a,h.Traps[0].Pos-(0,0,0.5));
        }
        if(level.time==2220)
        {
            Check(h.Traps[0].ActivationCount==2,"timed door triggers a second native cycle");
            Console.Printf("CA601 RESULT hunt");Done=true;
        }
    }
}
