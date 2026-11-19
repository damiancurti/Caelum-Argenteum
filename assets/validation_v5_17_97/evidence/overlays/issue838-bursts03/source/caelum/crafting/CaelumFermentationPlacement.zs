// Registro propio: conserva las instalaciones y guardados anteriores de Química.
class CaelumFermentationRoster : Actor
{
    int Revision;
    bool Issued;
    CaelumFermentationStation PendingStation;
    Default { +NOINTERACTION }
}

class CaelumFermentationEvents : StaticEventHandler
{
    bool Prepared;
    CaelumFermentationRoster Roster;
    override void WorldLoaded(WorldEvent e)
    {
        Prepared=false;
        Roster=null;
    }
    void CA838Body_CaelumFermentationEvents_WorldTick()
    {
        if(!CaelumFermentationData.Supports(level.MapName))return;
        if(!Prepared)
        {
            Prepared=true;
            // Una consulta tipada por carga: un registro de barril por mapa.
            let iterator=ThinkerIterator.Create("CaelumFermentationRoster");
            Roster=CaelumFermentationRoster(iterator.Next());
            if(Roster==null)Roster=CaelumFermentationRoster(Actor.Spawn("CaelumFermentationRoster",(0,0,0),NO_REPLACE));
        }
        if(Roster==null || Roster.Issued)return;
        let station=Roster.PendingStation;
        if(station!=null)
        {
            if(station.DimensionsRevision<2)return;
            if(station.TestMobjLocation() && Abs(station.FloorZ-station.Pos.Z)<=1)
            {
                Roster.Issued=true;
                Roster.Revision=CaelumFermentationData.REVISION;
                Roster.PendingStation=null;
                return;
            }
            station.Destroy();
            Roster.PendingStation=null;
        }
        // Reintento local una vez por segundo, sin desplazar actores existentes.
        if(level.Time%TICRATE!=0)return;
        station=CaelumFermentationStation(Actor.Spawn("CaelumFermentationStation",
            CaelumBarracasData.CurrentPortPoint(CaelumFermentationData.Position(level.MapName)),NO_REPLACE));
        if(station==null)return;
        station.CraftingRoomGroup=CaelumFermentationData.Group(level.MapName);
        station.Angle=CaelumBarracasData.CurrentPortAngle(CaelumFermentationData.Angle(level.MapName));
        Roster.PendingStation=station;
    }

    override void WorldTick()
    {
        CA838BurstProfile probe=null;
        if(level.time>=3599 && level.time<4299)probe=CA838BurstProfile(StaticEventHandler.Find('CA838BurstProfile'));
        if(probe!=null)probe.Begin(5);
        CA838Body_CaelumFermentationEvents_WorldTick();
        if(probe!=null)probe.End();
    }
}
