// #132: datos de la prueba optativa; no modifica el encuentro ya guardado.
class CaelumReinforcementData : Object
{
    const REVISION = 1;
    const GROUP_SIZE = 100;
    const LIVING_CAP = 2000;
    const TOTAL = 6000;
    const INTERVAL = 350;
}

class CaelumSiegeCrewSlot : Object play
{
    Actor Machine;
    vector3 Position, Offset;
    int Lane;
}

// Una sola autoridad por puerto. Todos los campos se guardan con el mapa.
class CaelumSiegeReinforcements : Object play
{
    int Revision, Successful, Living, Remaining, Pending, GroupStart;
    int NextOpportunity, PlacementCursor, PlacementFailures, Opportunities;
    bool Enabled, Stopped, Registering;
    bool Placed[100];
    Array<CaelumSiegeCrewSlot> InitialCrew;

    void Initialize(CaelumPortSiege port, bool fresh)
    {
        if(Revision>=CaelumReinforcementData.REVISION)return;
        Enabled=fresh && CaelumPortData.IsSouth()
            && CVar.GetCVar("ca_test_siege_reinforcements").GetBool();
        if(!fresh)
            for(int i=0;i<port.Attackers.Size();i++)
                if(port.Attackers[i]!=port.Boss)Successful++;
        Remaining=Enabled ? CaelumReinforcementData.TOTAL : 0;
        NextOpportunity=level.time; // Primer grupo al desplegar; luego 350 tics.
        Revision=CaelumReinforcementData.REVISION;
        RefreshLiving(port);
    }

    void QueueCrew(Actor machine, vector3 position, vector3 offset, int lane)
    {
        let slot=new("CaelumSiegeCrewSlot");
        slot.Machine=machine;slot.Position=position;slot.Offset=offset;slot.Lane=lane;
        InitialCrew.Push(slot);
    }

    void RefreshLiving(CaelumPortSiege port)
    {
        Living=0;
        for(int i=0;i<port.Attackers.Size();i++)
        {
            let e=port.Attackers[i];
            if(e.Body!=null && e.Body is "CaelumMandinga" && e.Body.health>0 && !e.Exited)Living++;
        }
    }

    bool Fits(CaelumMandinga body)
    {
        if(!body.TestMobjLocation() || Abs(body.Pos.Z-body.FloorZ)>1)return false;
        // TestMobjLocation cubre sólidos/geometría. También se evitan cuerpos
        // no sólidos en el suelo sin cambiar su ciclo de vida ni eliminarlos.
        let nearby=BlockThingsIterator.Create(body,body.Radius);
        while(nearby.Next())
        {
            let other=nearby.thing;
            if(other==body || !(other is "CaelumCombatActor"))continue;
            if((other.Pos.XY-body.Pos.XY).Length()<other.Radius+body.Radius
                && other.Pos.Z<(body.Pos.Z+body.Height) && (other.Pos.Z+other.Height)>body.Pos.Z)return false;
        }
        return true;
    }

    bool Place(CaelumPortSiege port, int slot)
    {
        int ordinal=GroupStart+slot;
        CaelumSiegeCrewSlot crew=ordinal<InitialCrew.Size() ? InitialCrew[ordinal] : null;
        vector3 position=crew!=null ? crew.Position : CaelumPortData.FormationPosition(PlacementCursor);
        if(crew==null)PlacementCursor=(PlacementCursor+1)%CaelumReinforcementData.TOTAL;
        let body=CaelumMandinga(Actor.Spawn("CaelumMandinga",position,NO_REPLACE));
        if(body==null){PlacementFailures++;return false;}
        if(!Fits(body))
        {
            body.Destroy();PlacementFailures++;
            // El puesto original puede estar ocupado. La misma identidad entra
            // por la formación y camina a su máquina con la IA ya existente.
            if(crew==null)return false;
            position=CaelumPortData.FormationPosition(PlacementCursor);
            PlacementCursor=(PlacementCursor+1)%CaelumReinforcementData.TOTAL;
            body=CaelumMandinga(Actor.Spawn("CaelumMandinga",position,NO_REPLACE));
            if(body==null)return false;
            if(!Fits(body)){body.Destroy();PlacementFailures++;return false;}
        }
        Registering=true;
        let entry=port.RegisterAttacker(body);
        Registering=false;
        if(entry==null){body.Destroy();PlacementFailures++;return false;}
        entry.Lane=crew!=null ? crew.Lane : port.NearestLane(position.X);
        entry.ExitNode=port.Exits[entry.Lane];
        if(crew!=null)
        {
            entry.CrewOffset=crew.Offset;
            if(crew.Machine is "CaelumBatteringRam")CaelumBatteringRam(crew.Machine).AssignCrew(entry);
            else if(crew.Machine is "CaelumCannon")CaelumCannon(crew.Machine).AssignOperator(body);
        }
        Placed[slot]=true;Successful++;Living++;Remaining--;Pending--;
        port.CommandDirty=true;
        return true;
    }

    void Tick(CaelumPortSiege port)
    {
        if(!Enabled)return;
        RefreshLiving(port);
        if(Stopped)return;
        if(port.Victory){Stopped=true;return;}
        if(Remaining==0 || level.time<NextOpportunity)return;
        // No se acumulan oportunidades, tampoco después de cargar o viajar.
        NextOpportunity=level.time+CaelumReinforcementData.INTERVAL;Opportunities++;
        if(Pending==0)
        {
            if(Living>CaelumReinforcementData.LIVING_CAP-CaelumReinforcementData.GROUP_SIZE
                || Remaining<CaelumReinforcementData.GROUP_SIZE)return;
            GroupStart=Successful;Pending=CaelumReinforcementData.GROUP_SIZE;
            for(int i=0;i<CaelumReinforcementData.GROUP_SIZE;i++)Placed[i]=false;
        }
        for(int i=0;i<CaelumReinforcementData.GROUP_SIZE;i++)
            if(!Placed[i] && Living<CaelumReinforcementData.LIVING_CAP)Place(port,i);
    }
}
