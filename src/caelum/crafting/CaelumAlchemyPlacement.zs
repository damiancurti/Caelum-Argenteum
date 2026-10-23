// Autoridad persistente del mapa: una estación autorizada, sin reponerla
// si se retira después de su instalación. Revisión 1, migración idempotente.
class CaelumAlchemyRoster : Actor
{
    int Revision;
    bool Issued;
    CaelumAlchemyStation PendingStation;
    Default { +NOINTERACTION }
}

// El coordinador estático existe también al cargar partidas anteriores.
class CaelumAlchemyEvents : StaticEventHandler
{
    bool Prepared;
    CaelumAlchemyRoster Roster;
    override void WorldLoaded(WorldEvent e)
    {
        Prepared=false;
        Roster=null;
    }
    override void WorldTick()
    {
        if(!CaelumAlchemyData.Supports(level.MapName))return;
        if(!Prepared)
        {
            Prepared=true;
            // Una consulta tipada al cargar: como máximo un registro por mapa.
            let iterator=ThinkerIterator.Create("CaelumAlchemyRoster");
            Roster=CaelumAlchemyRoster(iterator.Next());
            if(Roster==null)Roster=CaelumAlchemyRoster(Actor.Spawn("CaelumAlchemyRoster",(0,0,0),NO_REPLACE));
        }
        if(Roster==null || Roster.Issued)return;
        let station=Roster.PendingStation;
        if(station!=null)
        {
            // Validar después de PostBeginPlay: dimensiones y suelo nativos.
            if(station.DimensionsRevision<2)return;
            if(station.TestMobjLocation() && Abs(station.FloorZ-station.Pos.Z)<=1)
            {
                Roster.Issued=true;
                Roster.Revision=CaelumAlchemyData.REVISION;
                Roster.PendingStation=null;
                return;
            }
            station.Destroy();
            Roster.PendingStation=null;
        }
        // Si un actor ocupa el lugar aprobado, esperar sin moverlo ni recorrer
        // todos los actores. El siguiente intento conserva la misma posición.
        if(level.Time%TICRATE!=0)return;
        station=CaelumAlchemyStation(Actor.Spawn("CaelumAlchemyStation",
            CaelumAlchemyData.Position(level.MapName),NO_REPLACE));
        if(station==null)return;
        station.CraftingRoomGroup=CaelumAlchemyData.Group(level.MapName);
        station.Angle=CaelumAlchemyData.Angle(level.MapName);
        Roster.PendingStation=station;
    }
}
