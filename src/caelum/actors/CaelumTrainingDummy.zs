// A stationary, extremely durable target for repeatable combat tests.
class CaelumTrainingDummy : Actor
{
    Default
    {
        Health 1000000;
        // Diameter 42 matches the opaque sprite silhouette inside its
        // 48-pixel canvas; Height matches the full 72-pixel visual canvas.
        Radius 21;
        Height 72;
        Mass 0x7fffffff;
        PainChance 0;
        Speed 0;
        +SOLID
        +SHOOTABLE
        +NOBLOOD
        +NODAMAGETHRUST
        +CANNOTPUSH
        +NOTELEPORT
        +DONTSPLASH
    }

    override void Tick()
    {
        Super.Tick();
        // Preserve vertical gravity so a dummy spawned above a lower floor can
        // settle normally, while guaranteeing that attacks never move it
        // horizontally.
        Vel = (0.0, 0.0, Vel.Z);
    }

    States
    {
    Spawn:
        CDMY A -1;
        Stop;
    Death:
        CDMY A -1;
        Stop;
    }
}
