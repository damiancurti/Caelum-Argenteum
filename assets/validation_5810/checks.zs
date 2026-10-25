// Prueba de la barrera, no de acceso multijugador ni de la geometría del saco.
class CA412Checks : CA411DeployChecks
{
    void Guard(CaelumPlayer u)
    {
        Setup(u);let item=Give(u);
        Check(CaelumCampTask.BeginSetup(u,item),"approved tent assembly starts");Finish(u);
        let tent=CaelumDeployedTent(item.Owner);
        Check(tent!=null && tent.Ready,"production tent and original item deployed");
        if(tent==null)return;
        Check(!tent.HasRestingOccupant(),"unoccupied tent remains packable");
        double height=u.Height;u.A_SetSize(u.Radius,height/2,false);u.SetOrigin(tent.Pos,false);
        Check(tent.Covers(u) && u.TestMobjLocation(),"existing crouched collision fits under accepted tent");
        let rest=CaelumRestState.Get(u,true);rest.OriginMap=level.MapName;
        rest.Status=CaelumRestRules.STATUS_ACTIVE;rest.Mode=CaelumRestRules.MODE_WAIT;
        Check(tent.HasRestingOccupant(),"normal seated rest reserves tent");
        Check(!CaelumCampTask.BeginPack(u,tent) && !u.CraftingTaskActive && item.Owner==tent,"rejected packing preserves deployed original item");
        rest.Mode=CaelumRestRules.MODE_SLEEP;
        Check(tent.HasRestingOccupant(),"normal sleeping reserves tent");
        rest.OriginMap="OTHER";Check(!tent.HasRestingOccupant(),"stale other-map rest does not reserve tent");
        rest.Status=CaelumRestRules.STATUS_CANCELLED;
        let skip=CaelumTimeSkipState.Get(u,true);skip.OriginMap=level.MapName;skip.Active=true;skip.Sleeping=true;
        Check(tent.HasRestingOccupant(),"accelerated sleeping reserves tent");
        skip.Sleeping=false;Check(tent.HasRestingOccupant(),"active accelerated waiting reserves tent");
        skip.OriginMap="OTHER";Check(!tent.HasRestingOccupant(),"stale other-map time skip does not reserve tent");
        skip.OriginMap=level.MapName;u.SetOrigin(tent.Pos+(256,0,0),false);
        Check(!tent.HasRestingOccupant(),"resting outside does not reserve this tent");
        skip.Active=false;u.SetOrigin(tent.Pos,false);
        Check(CaelumCampTask.BeginPack(u,tent),"packing begins after occupant finishes");
        double remaining=u.CraftingTaskRemainingSeconds;
        // Inyección controlada de un descanso tardío: cubre la carrera entre inicio y final.
        rest.OriginMap=level.MapName;rest.Status=CaelumRestRules.STATUS_ACTIVE;rest.Mode=CaelumRestRules.MODE_WAIT;
        Check(!CaelumCampTask.Attended(u),"late occupant prevents packing progress");
        u.UpdateCraftingTask();Check(Near(remaining,u.CraftingTaskRemainingSeconds),"late occupancy preserves remaining packing work");
        Check(!CaelumCampTask.Complete(u) && item.Owner==tent && tent.Ready,"completion rechecks occupancy atomically");
        rest.Status=CaelumRestRules.STATUS_CANCELLED;
        Check(CaelumCampTask.Attended(u),"packing resumes after rest ends");
        Finish(u);Check(item.Owner==u && !u.CraftingTaskActive,"original item returned once after safe completion");
        u.A_SetSize(u.Radius,height,false);u.SetOrigin((64,128,0),false);
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!='ca412_guard'){Super.NetworkProcess(e);return;}
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        Guard(u);Console.Printf("CA412 RESULT passes=%d failures=%d",Passed,Failed);
    }
}
