// Blanco inmóvil y resistente para repetir las prácticas de combate.
class CaelumTrainingDummy : Actor
{
    Default
    {
        Health 1000000;
        // Colisión histórica independiente del modelo 3D y del sprite de respaldo.
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
