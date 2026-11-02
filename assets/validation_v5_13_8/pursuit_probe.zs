class CA601MatchProbe : StaticEventHandler
{
    bool Done;vector3 Before;vector3 Remembered;
    void Check(bool ok,String label){Console.Printf("CA601 %s %s",ok?"PASS":"FAIL",label);}
    override void WorldTick()
    {
        let m=CaelumStandaloneMatch.View();if(Done || m==null || m.Hunt==null)return;
        let h=m.Hunt;let a=CaelumPlayer(players[0].mo);let palomo=h.Hunter;
        if(level.time==80)
        {
            Before=palomo.Pos;Check(palomo.Route.Size()>0,"hunter builds bounded walkable patrol route");
        }
        if(level.time==100)
        {
            Check((palomo.Pos-Before).Length()>1,"hunter moves using existing speed");
            palomo.SetOrigin((32,512,0),false);palomo.Angle=270;palomo.Speed=0;
            a.SetOrigin((32,256,0),false);a.EffectiveStealthPercent=0;
            for(int i=1;i<4;i++)CaelumPlayer(players[i].mo).SetOrigin(CaelumHuntData.HunterStart(),false);
        }
        if(level.time>100 && level.time<180){a.EffectiveStealthPercent=0;palomo.Angle=270;}
        if(level.time>=110 && level.time<=180 && level.time%10==0)
            Console.Printf("CA601 DIAG tic=%d watch=%f last=%d seen=%d sight=%d distance=%f range=%f stealth=%f pos=%f,%f",level.time,palomo.Watch[0],palomo.LastSeen[0],CaelumVisualPerception.CanSee(palomo,a),palomo.CheckSight(a),palomo.Distance2D(a),CaelumVisualPerception.Range(palomo,a),a.EffectiveStealthPercent,palomo.Pos.X,palomo.Pos.Y);
        if(level.time==130)Check(palomo.LastSeen[0]==0,"partial sight does not identify instantly");
        if(level.time==180)
        {
            Check(palomo.LastSeen[0]>0 && palomo.Focus==0,"two-second observation identifies a player");
            Remembered=palomo.Remembered[0];a.SetOrigin(CaelumHuntData.HunterStart(),false);
        }
        if(level.time==185)
        {
            Check(palomo.Remembered[0]==Remembered && palomo.Focus==0,"hidden player does not update remembered position");
            palomo.LastSeen[0]=level.time-int(CaelumPerceptionMemoryData.LIFETIME_SECONDS*TICRATE);
        }
        if(level.time==187)
        {
            Check(palomo.Focus<0,"expired memory stops tracking hidden player");
            a.SetOrigin(palomo.Pos+(16,0,0),false);
        }
        if(level.time==190)
        {
            Check(h.Captive(0) && a.health>0,"actual hunter body contact captures instead of damage");
            h.Rescue(0);
            palomo.SetOrigin((32,512,0),false);palomo.Vel=(0,0,0);palomo.Angle=270;
            palomo.Route.Clear();palomo.RouteGoal=-1;palomo.NextRoute=0;
            a.SetOrigin((32,352,0),false);a.Vel=(0,0,0);
            palomo.LastSeen[0]=level.time;palomo.Remembered[0]=a.Pos;
        }
        if(level.time==225)
        {
            Check(h.Captive(0),"hunter reaches contact by native movement without overlapping teleport");
            Console.Printf("CA601 RESULT hunt");Done=true;
        }
    }
}
