// #454: los cuatro accesos son identidades unicas; los seis puestos de maquinas
// se agrupan por pares. Solo la geometria nueva adopta estas rutas.
class CaelumBarracasAssault : Object play
{
    static vector3 GateForLane(int lane)
    {return CaelumBarracasFrontData.GatePoint(CaelumBarracasFrontData.GateForLane(lane));}

    static int NearestLane(vector3 point)
    {
        int result=0;double best=1e30;
        for(int lane=0;lane<CaelumBarracasFrontData.RAM_COUNT;lane+=2)
        {
            vector3 gate=GateForLane(lane);
            double distance=(gate.XY-point.XY).Length();
            if(distance<best){best=distance;result=lane;}
        }
        return result;
    }

    static void PrepareGates(CaelumPortSiege port)
    {
        // No recrear actores guardados ni reinterpretar un acceso anterior.
        if(port.Gates.Size()>0)return;
        for(int i=0;i<CaelumBarracasFrontData.GATE_COUNT;i++)
        {
            let gate=CaelumBreakableGate(Actor.Spawn("CaelumBreakableGate",CaelumBarracasFrontData.GatePoint(i),NO_REPLACE));
            gate.Angle=CaelumBarracasFrontData.GateOutward(i)+90;
            gate.args[1]=CaelumBarracasFrontData.GateMaterial(i);gate.args[2]=1;
            gate.InitializeGate();port.Gates.Push(gate);
        }
        for(int lane=0;lane<CaelumBarracasFrontData.RAM_COUNT;lane++)
        {
            let node=CaelumSiegeRouteNode(Actor.Spawn("CaelumSiegeRouteNode",CaelumBarracasFrontData.ExitPoint(lane),NO_REPLACE));
            node.IsExit=true;node.A_SetSize(CaelumPortData.ROUTE_RADIUS,1);port.Exits.Push(node);
        }
    }

    static CaelumBatteringRam AddRam(CaelumPortSiege port,int lane)
    {
        int index=CaelumBarracasFrontData.GateForLane(lane);
        let ram=CaelumBatteringRam(Actor.Spawn("CaelumBatteringRam",CaelumBarracasFrontData.RamStart(lane),NO_REPLACE));
        ram.Angle=CaelumBarracasFrontData.RamStartAngle(lane);
        ram.Large=CaelumBarracasFrontData.RamLarge(lane);ram.InitializeRam();ram.UseBarracasCrewLayout();
        port.RegisterMachine(ram);
        for(int crew=0;crew<ram.RequiredCrew;crew++)
        {
            vector3 station=ram.CrewPosition(crew);
            if(port.Reinforcements.Enabled)port.Reinforcements.QueueCrew(ram,station,station-ram.Pos,lane);
            else {let entry=port.AddDemon(station,lane);if(entry!=null)ram.AssignCrew(entry);}
        }
        double outward=CaelumBarracasFrontData.GateOutward(index);
        ram.SetRoute(port.Gates[index],outward+180,true);
        for(int i=0;i<CaelumBarracasFrontData.RamPointCount(lane);i++)ram.AddRoutePoint(CaelumBarracasFrontData.RamPoint(lane,i));
        ram.AddRoutePoint(GateForLane(lane)+(Cos(outward),Sin(outward),0)*CaelumRamData.TRIAL_CONTACT_DISTANCE*ram.SizeFactor);
        return ram;
    }

    static void UpdateReserves(CaelumPortSiege port)
    {
        if(!port.RosterSealed || port.Machines.Size()<CaelumBarracasFrontData.RAM_COUNT)return;
        // Tres pares tipados, en la cadencia del mando. La falta temporal de
        // tripulantes o un sabotaje reparable no consume la reserva.
        for(int pair=0;pair<CaelumBarracasFrontData.RAM_COUNT/2;pair++)
        {
            let first=CaelumBatteringRam(port.Machines[pair*2]);
            let reserve=CaelumBatteringRam(port.Machines[pair*2+1]);
            if(first==null || reserve==null)continue;
            if(!port.RamReserveReleased[pair] && first.ObjectiveNeutralized())port.RamReserveReleased[pair]=true;
            let selected=port.RamReserveReleased[pair]?reserve:first;
            if(selected.OwnerFaction==CaelumMachineData.ENEMY_OWNER && !selected.Enabled && selected.Operational())selected.ActivateRam();
        }
        port.RamReserveRevision=CaelumBarracasFrontData.REVISION;
    }
}
