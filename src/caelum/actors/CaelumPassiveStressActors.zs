// Variantes exclusivas de MAP02 para separar cantidad/render/física de IA.
// Conservan estadísticas, anatomía, solidez, daño, Pain y Death de cada actor,
// pero ningún estado ejecuta A_Look, A_Chase, apuntado ni ataques.
class CaelumPassiveRulo : CaelumRulo
{
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
    States
    {
    Spawn: RATG A -1; Stop;
    See: RATG A -1; Stop;
    LucidityStun: TNT1 A 0; Goto See;
    Melee: TNT1 A 0; Goto See;
    Missile: TNT1 A 0; Goto See;
    }
}
