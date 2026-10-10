// Marcador serializado por mapa: la gravedad se convierte una sola vez,
// incluso al volver a un hub o cargar una partida anterior.
class CaelumPhysicsMapState : Actor
{
    int Revision;
    double OriginalGravity;
    Default { +NOINTERACTION +NOGRAVITY }
    States { Spawn: TNT1 A -1; Stop; }
}

class CaelumPhysicsWorld : Object play
{
    static void Initialize()
    {
        let iterator=ThinkerIterator.Create("CaelumPhysicsMapState");
        let mapState=CaelumPhysicsMapState(iterator.Next());
        if(mapState!=null && mapState.Revision>=CaelumPhysicsUnits.WORLD_GRAVITY_REVISION)return;
        if(mapState==null)mapState=CaelumPhysicsMapState(Actor.Spawn("CaelumPhysicsMapState",(0,0,0)));
        if(mapState==null)return;
        mapState.OriginalGravity=level.gravity;
        level.gravity*=CaelumPhysicsUnits.GRAVITY_RATIO;
        mapState.Revision=CaelumPhysicsUnits.WORLD_GRAVITY_REVISION;
    }
}
