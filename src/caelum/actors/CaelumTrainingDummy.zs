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
        Mass 10000;
        PainChance 0;
        Speed 0;
        +SOLID
        +SHOOTABLE
        +NOBLOOD
        +NODAMAGETHRUST
        +NOTELEPORT
        +DONTSPLASH
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
