// Isolated collision reproduction, NOT traversal acceptance. Coordinates come
// from route-control-a's final log; fresh resources separate geometry from fatigue.
class CA133Replay : EventHandler
{
    override void WorldTick()
    {
        let p=CaelumPortSiege.Get();if(p==null)return;
        if(level.time==90)
        {
            p.Deploy(true);p.RosterSealed=true;p.Victory=true;
            for(int i=0;i<p.Defenders.Size();i++)
            {
                let b=p.Defenders[i];b.SetOrigin(CA133ReplayData.Position(i,b.Station),false);
                b.DeploymentStep=CA133ReplayData.Step(i);b.DeploymentComplete=CA133ReplayData.Complete(i);
            }
        }
        if(level.time==100 || level.time==450)
        {
            for(int i=0;i<p.Defenders.Size();i++)
            {
                let b=p.Defenders[i];if(b.DeploymentComplete)continue;
                vector3 goal=CaelumCityRoutes.Point(i,b.DeploymentStep-3);
                vector3 original=b.Pos;vector2 delta=goal.XY-b.Pos.XY;
                if(level.time==450 && delta.Length()>0)b.TryMove(b.Pos.XY+delta.Unit()*Min(b.Speed,delta.Length()),0);
                String blocker="none";if(b.BlockingMobj!=null)blocker=b.BlockingMobj.GetClassName();
                Console.Printf("CA133 COLLISION tic=%d id=%d step=%d pos=%.1f,%.1f,%.1f goal=%.1f,%.1f,%.1f blocker=%s line=%d speed=%.3f sleep=%d recovery=%d air=%.1f",level.time,i,b.DeploymentStep,b.Pos.X,b.Pos.Y,b.Pos.Z,goal.X,goal.Y,goal.Z,blocker,b.BlockingLine==null ? -1 : b.BlockingLine.Index(),b.Speed,b.ForcedSleepTics,b.RecoveryPhase,b.CurrentCombatAir);
                if(b.BlockingMobj!=null)Console.Printf("CA133 BLOCK_BODY id=%d blocker_pos=%.1f,%.1f,%.1f",i,b.BlockingMobj.Pos.X,b.BlockingMobj.Pos.Y,b.BlockingMobj.Pos.Z);
                b.SetOrigin(original,false);
            }
        }
        if(level.time==451)Console.Printf("CA133 REPLAY_COMPLETE");
    }
}
