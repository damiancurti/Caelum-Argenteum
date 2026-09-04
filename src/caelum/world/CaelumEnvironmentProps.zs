// Objetos físicos originales para poblar los biomas. En 4.31.0c son sólo
// geometría sólida y convocable: la recolección, herramientas, cantidades y
// regeneración se definirán cuando exista el sistema de nodos de recursos.
class CaelumEnvironmentProp : Actor
{
    Default
    {
        Mass 10000;
        +SOLID
        +CANNOTPUSH
        +DONTTHRUST
        RenderStyle "Normal";
    }
}

class CaelumRockGranite : CaelumEnvironmentProp
{
    Default { Tag "$CA_ROCK_GRANITE"; Radius 28; Height 42; }
    States { Spawn: CARK A -1; Stop; }
}

class CaelumRockSandstone : CaelumEnvironmentProp
{
    Default { Tag "$CA_ROCK_SANDSTONE"; Radius 44; Height 38; }
    States { Spawn: CARK B -1; Stop; }
}

class CaelumRockBasalt : CaelumEnvironmentProp
{
    Default { Tag "$CA_ROCK_BASALT"; Radius 28; Height 86; }
    States { Spawn: CARK C -1; Stop; }
}

class CaelumRockQuartz : CaelumEnvironmentProp
{
    Default { Tag "$CA_ROCK_QUARTZ"; Radius 32; Height 70; }
    States { Spawn: CARK D -1; Stop; }
}

class CaelumRockCoastal : CaelumEnvironmentProp
{
    Default { Tag "$CA_ROCK_COASTAL"; Radius 45; Height 34; }
    States { Spawn: CARK E -1; Stop; }
}

class CaelumTreeDesertCardon : CaelumEnvironmentProp
{
    Default { Tag "$CA_TREE_DESERT_CARDON"; Radius 24; Height 220; }
    States { Spawn: CAVT A -1; Stop; }
}

class CaelumTreeDesertChurqui : CaelumEnvironmentProp
{
    Default { Tag "$CA_TREE_DESERT_CHURQUI"; Radius 16; Height 118; }
    States { Spawn: CAVT B -1; Stop; }
}

class CaelumTreeDesertChanar : CaelumEnvironmentProp
{
    Default { Tag "$CA_TREE_DESERT_CHANAR"; Radius 18; Height 138; }
    States { Spawn: CAVT C -1; Stop; }
}

class CaelumTreeJungleLapacho : CaelumEnvironmentProp
{
    Default { Tag "$CA_TREE_JUNGLE_LAPACHO"; Radius 24; Height 238; }
    States { Spawn: CAVT D -1; Stop; }
}

class CaelumTreeJunglePaloRosa : CaelumEnvironmentProp
{
    Default { Tag "$CA_TREE_JUNGLE_PALO_ROSA"; Radius 20; Height 310; }
    States { Spawn: CAVT E -1; Stop; }
}

class CaelumTreeJungleTimbo : CaelumEnvironmentProp
{
    Default { Tag "$CA_TREE_JUNGLE_TIMBO"; Radius 32; Height 210; }
    States { Spawn: CAVT F -1; Stop; }
}

class CaelumTreeTundraLenga : CaelumEnvironmentProp
{
    Default { Tag "$CA_TREE_TUNDRA_LENGA"; Radius 20; Height 178; }
    States { Spawn: CAVT G -1; Stop; }
}

class CaelumTreeTundraNire : CaelumEnvironmentProp
{
    Default { Tag "$CA_TREE_TUNDRA_NIRE"; Radius 22; Height 112; }
    States { Spawn: CAVT H -1; Stop; }
}

class CaelumTreeTundraGuindo : CaelumEnvironmentProp
{
    Default { Tag "$CA_TREE_TUNDRA_GUINDO"; Radius 14; Height 206; }
    States { Spawn: CAVT I -1; Stop; }
}

class CaelumTreeMountainPehuen : CaelumEnvironmentProp
{
    Default { Tag "$CA_TREE_MOUNTAIN_PEHUEN"; Radius 18; Height 286; }
    States { Spawn: CAVT J -1; Stop; }
}

class CaelumTreeMountainCypress : CaelumEnvironmentProp
{
    Default { Tag "$CA_TREE_MOUNTAIN_CYPRESS"; Radius 14; Height 226; }
    States { Spawn: CAVT K -1; Stop; }
}

class CaelumTreeMountainCoihue : CaelumEnvironmentProp
{
    Default { Tag "$CA_TREE_MOUNTAIN_COIHUE"; Radius 20; Height 254; }
    States { Spawn: CAVT L -1; Stop; }
}

class CaelumTreePlainsOmbu : CaelumEnvironmentProp
{
    Default { Tag "$CA_TREE_PLAINS_OMBU"; Radius 35; Height 196; }
    States { Spawn: CAVT M -1; Stop; }
}

class CaelumTreePlainsTala : CaelumEnvironmentProp
{
    Default { Tag "$CA_TREE_PLAINS_TALA"; Radius 20; Height 148; }
    States { Spawn: CAVT N -1; Stop; }
}

class CaelumTreePlainsEspinillo : CaelumEnvironmentProp
{
    Default { Tag "$CA_TREE_PLAINS_ESPINILLO"; Radius 16; Height 106; }
    States { Spawn: CAVT O -1; Stop; }
}

class CaelumTreeCoastCoronillo : CaelumEnvironmentProp
{
    Default { Tag "$CA_TREE_COAST_CORONILLO"; Radius 18; Height 142; }
    States { Spawn: CAVT P -1; Stop; }
}

class CaelumTreeCoastWillow : CaelumEnvironmentProp
{
    Default { Tag "$CA_TREE_COAST_WILLOW"; Radius 20; Height 178; }
    States { Spawn: CAVT Q -1; Stop; }
}

class CaelumTreeCoastCeibo : CaelumEnvironmentProp
{
    Default { Tag "$CA_TREE_COAST_CEIBO"; Radius 24; Height 158; }
    States { Spawn: CAVT R -1; Stop; }
}

class CaelumTreeCityJacaranda : CaelumEnvironmentProp
{
    Default { Tag "$CA_TREE_CITY_JACARANDA"; Radius 20; Height 196; }
    States { Spawn: CAVT S -1; Stop; }
}

class CaelumTreeCityTipa : CaelumEnvironmentProp
{
    Default { Tag "$CA_TREE_CITY_TIPA"; Radius 26; Height 226; }
    States { Spawn: CAVT T -1; Stop; }
}

class CaelumTreeCityPlane : CaelumEnvironmentProp
{
    Default { Tag "$CA_TREE_CITY_PLANE"; Radius 20; Height 244; }
    States { Spawn: CAVT U -1; Stop; }
}
