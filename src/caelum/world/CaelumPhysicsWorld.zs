// Marcador serializado por mapa: la gravedad se convierte una sola vez,
// incluso al volver a un hub o cargar una partida anterior.
class CaelumPhysicsMapState : Actor
{
    int Revision;
    double OriginalGravity;
    int AltitudeRevision;
    double AltitudeBaseMeters;
    Default { +NOINTERACTION +NOGRAVITY }
    States { Spawn: TNT1 A -1; Stop; }
}

class CaelumPhysicsWorld : Object play
{
    static void Initialize()
    {
        let iterator=ThinkerIterator.Create("CaelumPhysicsMapState");
        let mapState=CaelumPhysicsMapState(iterator.Next());
        if(mapState==null)mapState=CaelumPhysicsMapState(Actor.Spawn("CaelumPhysicsMapState",(0,0,0)));
        if(mapState==null)return;
        if(mapState.Revision<CaelumPhysicsUnits.WORLD_GRAVITY_REVISION)
        {
            mapState.OriginalGravity=level.gravity;
            level.gravity*=CaelumPhysicsUnits.GRAVITY_RATIO;
            mapState.Revision=CaelumPhysicsUnits.WORLD_GRAVITY_REVISION;
        }
        // #413: revisión independiente; cargar un mapa anterior no vuelve
        // a convertir su gravedad. Se reutiliza la única búsqueda tipada existente.
        if(mapState.AltitudeRevision<CaelumAltitudeData.REVISION)
        {
            mapState.AltitudeBaseMeters=level.Sectors.Size()>0 ? level.Sectors[0].GetUDMFFloat('user_ca_altitude_base_m') : 0;
            mapState.AltitudeRevision=CaelumAltitudeData.REVISION;
        }
        let ticker=CaelumWorldClockTicker(StaticEventHandler.Find("CaelumWorldClockTicker"));
        if(ticker!=null)ticker.AltitudeMap=mapState;
    }
}
