// Rellenos visuales exclusivos del campo masivo de MAP02. Conservan actor,
// render y estados heredados, pero no ocupan el blockmap: la prueba 4.29.0r
// separa así el coste de dibujar 15.000 cuerpos del coste de consultar 13.125
// obstáculos pasivos durante cada movimiento nativo A_Chase.
class CaelumPassiveRulo : CaelumRulo
{
    Default
    {
        +NOBLOCKMAP
    }

    override void PostBeginPlay()
    {
        CaelumDiagnosticPassiveAI = true;
        Super.PostBeginPlay();
    }

    States
    {
    Spawn: RULO A -1; Stop;
    See: RULO A -1; Stop;
    LucidityStun: TNT1 A 0; Goto See;
    Melee: TNT1 A 0; Goto See;
    Missile: TNT1 A 0; Goto See;
    }
}

class CaelumPassiveArgento : CaelumArgento
{
    Default
    {
        +NOBLOCKMAP
    }

    override void PostBeginPlay()
    {
        CaelumDiagnosticPassiveAI = true;
        Super.PostBeginPlay();
    }

    States
    {
    Spawn: ARGO A -1; Stop;
    See: ARGO A -1; Stop;
    LucidityStun: TNT1 A 0; Goto See;
    Melee: TNT1 A 0; Goto See;
    Missile: TNT1 A 0; Goto See;
    }
}

class CaelumPassiveCaella : CaelumCaella
{
    Default
    {
        +NOBLOCKMAP
    }

    override void PostBeginPlay()
    {
        CaelumDiagnosticPassiveAI = true;
        Super.PostBeginPlay();
    }

    States
    {
    Spawn: CAEL A -1; Stop;
    See: CAEL A -1; Stop;
    LucidityStun: TNT1 A 0; Goto See;
    Melee: TNT1 A 0; Goto See;
    Missile: TNT1 A 0; Goto See;
    }
}

class CaelumPassiveRonnie : CaelumRonnie
{
    Default
    {
        +NOBLOCKMAP
    }

    override void PostBeginPlay()
    {
        CaelumDiagnosticPassiveAI = true;
        Super.PostBeginPlay();
    }

    States
    {
    Spawn: RONI A -1; Stop;
    See: RONI A -1; Stop;
    LucidityStun: TNT1 A 0; Goto See;
    Melee: TNT1 A 0; Goto See;
    Missile: TNT1 A 0; Goto See;
    }
}

class CaelumPassiveBull : CaelumBull
{
    Default
    {
        +NOBLOCKMAP
    }

    override void PostBeginPlay()
    {
        CaelumDiagnosticPassiveAI = true;
        Super.PostBeginPlay();
    }

    States
    {
    Spawn: BULL A -1; Stop;
    See: BULL A -1; Stop;
    LucidityStun: TNT1 A 0; Goto See;
    Melee: TNT1 A 0; Goto See;
    Missile: TNT1 A 0; Goto See;
    }
}

class CaelumPassiveGiantRat : CaelumGiantRat
{
    Default
    {
        +NOBLOCKMAP
    }

    override void PostBeginPlay()
    {
        CaelumDiagnosticPassiveAI = true;
        Super.PostBeginPlay();
    }

    States
    {
    Spawn: RATG A -1; Stop;
    See: RATG A -1; Stop;
    LucidityStun: TNT1 A 0; Goto See;
    Melee: TNT1 A 0; Goto See;
    Missile: TNT1 A 0; Goto See;
    }
}
