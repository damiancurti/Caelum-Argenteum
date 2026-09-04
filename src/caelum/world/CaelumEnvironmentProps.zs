// Objetos físicos originales para poblar los biomas. En esta etapa son
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
    Default
    {
        Tag "$CA_ROCK_GRANITE";
        Radius 28;
        Height 42;
    }
    States
    {
        Spawn: CARK A -1; Stop;
    }
}

class CaelumRockGraniteHalf : CaelumRockGranite
{
    Default
    {
        Radius 14;
        Height 21;
    }
}

class CaelumRockGraniteHalf2 : CaelumRockGranite
{
    Default
    {
        Radius 10.5;
        Height 15.75;
    }
}

class CaelumRockGraniteHalf3 : CaelumRockGranite
{
    Default
    {
        Radius 17.5;
        Height 26.25;
    }
}

class CaelumRockGranite2 : CaelumRockGranite
{
    Default
    {
        Radius 21;
        Height 31.5;
    }
}

class CaelumRockGranite3 : CaelumRockGranite
{
    Default
    {
        Radius 35;
        Height 52.5;
    }
}

class CaelumRockGraniteDouble : CaelumRockGranite
{
    Default
    {
        Radius 56;
        Height 84;
    }
}

class CaelumRockGraniteDouble2 : CaelumRockGranite
{
    Default
    {
        Radius 42;
        Height 63;
    }
}

class CaelumRockGraniteDouble3 : CaelumRockGranite
{
    Default
    {
        Radius 70;
        Height 105;
    }
}

class CaelumRockGraniteGiant : CaelumRockGranite
{
    Default
    {
        Radius 140;
        Height 210;
    }
}

class CaelumRockGraniteGiant2 : CaelumRockGranite
{
    Default
    {
        Radius 105;
        Height 157.5;
    }
}

class CaelumRockGraniteGiant3 : CaelumRockGranite
{
    Default
    {
        Radius 175;
        Height 262.5;
    }
}

class CaelumRockGraniteColossal : CaelumRockGranite
{
    Default
    {
        Radius 560;
        Height 840;
    }
}

class CaelumRockGraniteColossal2 : CaelumRockGranite
{
    Default
    {
        Radius 420;
        Height 630;
    }
}

class CaelumRockGraniteColossal3 : CaelumRockGranite
{
    Default
    {
        Radius 700;
        Height 1050;
    }
}

class CaelumRockSandstone : CaelumEnvironmentProp
{
    Default
    {
        Tag "$CA_ROCK_SANDSTONE";
        Radius 44;
        Height 38;
    }
    States
    {
        Spawn: CARK B -1; Stop;
    }
}

class CaelumRockSandstoneHalf : CaelumRockSandstone
{
    Default
    {
        Radius 22;
        Height 19;
    }
}

class CaelumRockSandstoneHalf2 : CaelumRockSandstone
{
    Default
    {
        Radius 16.5;
        Height 14.25;
    }
}

class CaelumRockSandstoneHalf3 : CaelumRockSandstone
{
    Default
    {
        Radius 27.5;
        Height 23.75;
    }
}

class CaelumRockSandstone2 : CaelumRockSandstone
{
    Default
    {
        Radius 33;
        Height 28.5;
    }
}

class CaelumRockSandstone3 : CaelumRockSandstone
{
    Default
    {
        Radius 55;
        Height 47.5;
    }
}

class CaelumRockSandstoneDouble : CaelumRockSandstone
{
    Default
    {
        Radius 88;
        Height 76;
    }
}

class CaelumRockSandstoneDouble2 : CaelumRockSandstone
{
    Default
    {
        Radius 66;
        Height 57;
    }
}

class CaelumRockSandstoneDouble3 : CaelumRockSandstone
{
    Default
    {
        Radius 110;
        Height 95;
    }
}

class CaelumRockSandstoneGiant : CaelumRockSandstone
{
    Default
    {
        Radius 220;
        Height 190;
    }
}

class CaelumRockSandstoneGiant2 : CaelumRockSandstone
{
    Default
    {
        Radius 165;
        Height 142.5;
    }
}

class CaelumRockSandstoneGiant3 : CaelumRockSandstone
{
    Default
    {
        Radius 275;
        Height 237.5;
    }
}

class CaelumRockSandstoneColossal : CaelumRockSandstone
{
    Default
    {
        Radius 880;
        Height 760;
    }
}

class CaelumRockSandstoneColossal2 : CaelumRockSandstone
{
    Default
    {
        Radius 660;
        Height 570;
    }
}

class CaelumRockSandstoneColossal3 : CaelumRockSandstone
{
    Default
    {
        Radius 1100;
        Height 950;
    }
}

class CaelumRockBasalt : CaelumEnvironmentProp
{
    Default
    {
        Tag "$CA_ROCK_BASALT";
        Radius 28;
        Height 86;
    }
    States
    {
        Spawn: CARK C -1; Stop;
    }
}

class CaelumRockBasaltHalf : CaelumRockBasalt
{
    Default
    {
        Radius 14;
        Height 43;
    }
}

class CaelumRockBasaltHalf2 : CaelumRockBasalt
{
    Default
    {
        Radius 10.5;
        Height 32.25;
    }
}

class CaelumRockBasaltHalf3 : CaelumRockBasalt
{
    Default
    {
        Radius 17.5;
        Height 53.75;
    }
}

class CaelumRockBasalt2 : CaelumRockBasalt
{
    Default
    {
        Radius 21;
        Height 64.5;
    }
}

class CaelumRockBasalt3 : CaelumRockBasalt
{
    Default
    {
        Radius 35;
        Height 107.5;
    }
}

class CaelumRockBasaltDouble : CaelumRockBasalt
{
    Default
    {
        Radius 56;
        Height 172;
    }
}

class CaelumRockBasaltDouble2 : CaelumRockBasalt
{
    Default
    {
        Radius 42;
        Height 129;
    }
}

class CaelumRockBasaltDouble3 : CaelumRockBasalt
{
    Default
    {
        Radius 70;
        Height 215;
    }
}

class CaelumRockBasaltGiant : CaelumRockBasalt
{
    Default
    {
        Radius 140;
        Height 430;
    }
}

class CaelumRockBasaltGiant2 : CaelumRockBasalt
{
    Default
    {
        Radius 105;
        Height 322.5;
    }
}

class CaelumRockBasaltGiant3 : CaelumRockBasalt
{
    Default
    {
        Radius 175;
        Height 537.5;
    }
}

class CaelumRockBasaltColossal : CaelumRockBasalt
{
    Default
    {
        Radius 560;
        Height 1720;
    }
}

class CaelumRockBasaltColossal2 : CaelumRockBasalt
{
    Default
    {
        Radius 420;
        Height 1290;
    }
}

class CaelumRockBasaltColossal3 : CaelumRockBasalt
{
    Default
    {
        Radius 700;
        Height 2150;
    }
}

class CaelumRockQuartz : CaelumEnvironmentProp
{
    Default
    {
        Tag "$CA_ROCK_QUARTZ";
        Radius 32;
        Height 70;
    }
    States
    {
        Spawn: CARK D -1; Stop;
    }
}

class CaelumRockQuartzHalf : CaelumRockQuartz
{
    Default
    {
        Radius 16;
        Height 35;
    }
}

class CaelumRockQuartzHalf2 : CaelumRockQuartz
{
    Default
    {
        Radius 12;
        Height 26.25;
    }
}

class CaelumRockQuartzHalf3 : CaelumRockQuartz
{
    Default
    {
        Radius 20;
        Height 43.75;
    }
}

class CaelumRockQuartz2 : CaelumRockQuartz
{
    Default
    {
        Radius 24;
        Height 52.5;
    }
}

class CaelumRockQuartz3 : CaelumRockQuartz
{
    Default
    {
        Radius 40;
        Height 87.5;
    }
}

class CaelumRockQuartzDouble : CaelumRockQuartz
{
    Default
    {
        Radius 64;
        Height 140;
    }
}

class CaelumRockQuartzDouble2 : CaelumRockQuartz
{
    Default
    {
        Radius 48;
        Height 105;
    }
}

class CaelumRockQuartzDouble3 : CaelumRockQuartz
{
    Default
    {
        Radius 80;
        Height 175;
    }
}

class CaelumRockQuartzGiant : CaelumRockQuartz
{
    Default
    {
        Radius 160;
        Height 350;
    }
}

class CaelumRockQuartzGiant2 : CaelumRockQuartz
{
    Default
    {
        Radius 120;
        Height 262.5;
    }
}

class CaelumRockQuartzGiant3 : CaelumRockQuartz
{
    Default
    {
        Radius 200;
        Height 437.5;
    }
}

class CaelumRockQuartzColossal : CaelumRockQuartz
{
    Default
    {
        Radius 640;
        Height 1400;
    }
}

class CaelumRockQuartzColossal2 : CaelumRockQuartz
{
    Default
    {
        Radius 480;
        Height 1050;
    }
}

class CaelumRockQuartzColossal3 : CaelumRockQuartz
{
    Default
    {
        Radius 800;
        Height 1750;
    }
}

class CaelumRockCoastal : CaelumEnvironmentProp
{
    Default
    {
        Tag "$CA_ROCK_COASTAL";
        Radius 45;
        Height 34;
    }
    States
    {
        Spawn: CARK E -1; Stop;
    }
}

class CaelumRockCoastalHalf : CaelumRockCoastal
{
    Default
    {
        Radius 22.5;
        Height 17;
    }
}

class CaelumRockCoastalHalf2 : CaelumRockCoastal
{
    Default
    {
        Radius 16.875;
        Height 12.75;
    }
}

class CaelumRockCoastalHalf3 : CaelumRockCoastal
{
    Default
    {
        Radius 28.125;
        Height 21.25;
    }
}

class CaelumRockCoastal2 : CaelumRockCoastal
{
    Default
    {
        Radius 33.75;
        Height 25.5;
    }
}

class CaelumRockCoastal3 : CaelumRockCoastal
{
    Default
    {
        Radius 56.25;
        Height 42.5;
    }
}

class CaelumRockCoastalDouble : CaelumRockCoastal
{
    Default
    {
        Radius 90;
        Height 68;
    }
}

class CaelumRockCoastalDouble2 : CaelumRockCoastal
{
    Default
    {
        Radius 67.5;
        Height 51;
    }
}

class CaelumRockCoastalDouble3 : CaelumRockCoastal
{
    Default
    {
        Radius 112.5;
        Height 85;
    }
}

class CaelumRockCoastalGiant : CaelumRockCoastal
{
    Default
    {
        Radius 225;
        Height 170;
    }
}

class CaelumRockCoastalGiant2 : CaelumRockCoastal
{
    Default
    {
        Radius 168.75;
        Height 127.5;
    }
}

class CaelumRockCoastalGiant3 : CaelumRockCoastal
{
    Default
    {
        Radius 281.25;
        Height 212.5;
    }
}

class CaelumRockCoastalColossal : CaelumRockCoastal
{
    Default
    {
        Radius 900;
        Height 680;
    }
}

class CaelumRockCoastalColossal2 : CaelumRockCoastal
{
    Default
    {
        Radius 675;
        Height 510;
    }
}

class CaelumRockCoastalColossal3 : CaelumRockCoastal
{
    Default
    {
        Radius 1125;
        Height 850;
    }
}

class CaelumTreeDesertCardon : CaelumEnvironmentProp
{
    Default
    {
        Tag "$CA_TREE_DESERT_CARDON";
        Radius 24;
        Height 220;
    }
    States
    {
        Spawn: CAVT A -1; Stop;
    }
}

class CaelumTreeDesertCardon2 : CaelumTreeDesertCardon
{
    Default
    {
        Radius 18;
        Height 165;
    }
}

class CaelumTreeDesertCardon3 : CaelumTreeDesertCardon
{
    Default
    {
        Radius 30;
        Height 275;
    }
}

class CaelumTreeDesertChurqui : CaelumEnvironmentProp
{
    Default
    {
        Tag "$CA_TREE_DESERT_CHURQUI";
        Radius 16;
        Height 118;
    }
    States
    {
        Spawn: CAVT B -1; Stop;
    }
}

class CaelumTreeDesertChurqui2 : CaelumTreeDesertChurqui
{
    Default
    {
        Radius 12;
        Height 88.5;
    }
}

class CaelumTreeDesertChurqui3 : CaelumTreeDesertChurqui
{
    Default
    {
        Radius 20;
        Height 147.5;
    }
}

class CaelumTreeDesertChanar : CaelumEnvironmentProp
{
    Default
    {
        Tag "$CA_TREE_DESERT_CHANAR";
        Radius 18;
        Height 138;
    }
    States
    {
        Spawn: CAVT C -1; Stop;
    }
}

class CaelumTreeDesertChanar2 : CaelumTreeDesertChanar
{
    Default
    {
        Radius 13.5;
        Height 103.5;
    }
}

class CaelumTreeDesertChanar3 : CaelumTreeDesertChanar
{
    Default
    {
        Radius 22.5;
        Height 172.5;
    }
}

class CaelumTreeJungleLapacho : CaelumEnvironmentProp
{
    Default
    {
        Tag "$CA_TREE_JUNGLE_LAPACHO";
        Radius 24;
        Height 238;
    }
    States
    {
        Spawn: CAVT D -1; Stop;
    }
}

class CaelumTreeJungleLapacho2 : CaelumTreeJungleLapacho
{
    Default
    {
        Radius 18;
        Height 178.5;
    }
}

class CaelumTreeJungleLapacho3 : CaelumTreeJungleLapacho
{
    Default
    {
        Radius 30;
        Height 297.5;
    }
}

class CaelumTreeJunglePaloRosa : CaelumEnvironmentProp
{
    Default
    {
        Tag "$CA_TREE_JUNGLE_PALO_ROSA";
        Radius 20;
        Height 310;
    }
    States
    {
        Spawn: CAVT E -1; Stop;
    }
}

class CaelumTreeJunglePaloRosa2 : CaelumTreeJunglePaloRosa
{
    Default
    {
        Radius 15;
        Height 232.5;
    }
}

class CaelumTreeJunglePaloRosa3 : CaelumTreeJunglePaloRosa
{
    Default
    {
        Radius 25;
        Height 387.5;
    }
}

class CaelumTreeJungleTimbo : CaelumEnvironmentProp
{
    Default
    {
        Tag "$CA_TREE_JUNGLE_TIMBO";
        Radius 32;
        Height 210;
    }
    States
    {
        Spawn: CAVT F -1; Stop;
    }
}

class CaelumTreeJungleTimbo2 : CaelumTreeJungleTimbo
{
    Default
    {
        Radius 24;
        Height 157.5;
    }
}

class CaelumTreeJungleTimbo3 : CaelumTreeJungleTimbo
{
    Default
    {
        Radius 40;
        Height 262.5;
    }
}

class CaelumTreeTundraLenga : CaelumEnvironmentProp
{
    Default
    {
        Tag "$CA_TREE_TUNDRA_LENGA";
        Radius 20;
        Height 178;
    }
    States
    {
        Spawn: CAVT G -1; Stop;
    }
}

class CaelumTreeTundraLenga2 : CaelumTreeTundraLenga
{
    Default
    {
        Radius 15;
        Height 133.5;
    }
}

class CaelumTreeTundraLenga3 : CaelumTreeTundraLenga
{
    Default
    {
        Radius 25;
        Height 222.5;
    }
}

class CaelumTreeTundraNire : CaelumEnvironmentProp
{
    Default
    {
        Tag "$CA_TREE_TUNDRA_NIRE";
        Radius 22;
        Height 112;
    }
    States
    {
        Spawn: CAVT H -1; Stop;
    }
}

class CaelumTreeTundraNire2 : CaelumTreeTundraNire
{
    Default
    {
        Radius 16.5;
        Height 84;
    }
}

class CaelumTreeTundraNire3 : CaelumTreeTundraNire
{
    Default
    {
        Radius 27.5;
        Height 140;
    }
}

class CaelumTreeTundraGuindo : CaelumEnvironmentProp
{
    Default
    {
        Tag "$CA_TREE_TUNDRA_GUINDO";
        Radius 14;
        Height 206;
    }
    States
    {
        Spawn: CAVT I -1; Stop;
    }
}

class CaelumTreeTundraGuindo2 : CaelumTreeTundraGuindo
{
    Default
    {
        Radius 10.5;
        Height 154.5;
    }
}

class CaelumTreeTundraGuindo3 : CaelumTreeTundraGuindo
{
    Default
    {
        Radius 17.5;
        Height 257.5;
    }
}

class CaelumTreeMountainPehuen : CaelumEnvironmentProp
{
    Default
    {
        Tag "$CA_TREE_MOUNTAIN_PEHUEN";
        Radius 18;
        Height 286;
    }
    States
    {
        Spawn: CAVT J -1; Stop;
    }
}

class CaelumTreeMountainPehuen2 : CaelumTreeMountainPehuen
{
    Default
    {
        Radius 13.5;
        Height 214.5;
    }
}

class CaelumTreeMountainPehuen3 : CaelumTreeMountainPehuen
{
    Default
    {
        Radius 22.5;
        Height 357.5;
    }
}

class CaelumTreeMountainCypress : CaelumEnvironmentProp
{
    Default
    {
        Tag "$CA_TREE_MOUNTAIN_CYPRESS";
        Radius 14;
        Height 226;
    }
    States
    {
        Spawn: CAVT K -1; Stop;
    }
}

class CaelumTreeMountainCypress2 : CaelumTreeMountainCypress
{
    Default
    {
        Radius 10.5;
        Height 169.5;
    }
}

class CaelumTreeMountainCypress3 : CaelumTreeMountainCypress
{
    Default
    {
        Radius 17.5;
        Height 282.5;
    }
}

class CaelumTreeMountainCoihue : CaelumEnvironmentProp
{
    Default
    {
        Tag "$CA_TREE_MOUNTAIN_COIHUE";
        Radius 20;
        Height 254;
    }
    States
    {
        Spawn: CAVT L -1; Stop;
    }
}

class CaelumTreeMountainCoihue2 : CaelumTreeMountainCoihue
{
    Default
    {
        Radius 15;
        Height 190.5;
    }
}

class CaelumTreeMountainCoihue3 : CaelumTreeMountainCoihue
{
    Default
    {
        Radius 25;
        Height 317.5;
    }
}

class CaelumTreePlainsOmbu : CaelumEnvironmentProp
{
    Default
    {
        Tag "$CA_TREE_PLAINS_OMBU";
        Radius 35;
        Height 196;
    }
    States
    {
        Spawn: CAVT M -1; Stop;
    }
}

class CaelumTreePlainsOmbu2 : CaelumTreePlainsOmbu
{
    Default
    {
        Radius 26.25;
        Height 147;
    }
}

class CaelumTreePlainsOmbu3 : CaelumTreePlainsOmbu
{
    Default
    {
        Radius 43.75;
        Height 245;
    }
}

class CaelumTreePlainsTala : CaelumEnvironmentProp
{
    Default
    {
        Tag "$CA_TREE_PLAINS_TALA";
        Radius 20;
        Height 148;
    }
    States
    {
        Spawn: CAVT N -1; Stop;
    }
}

class CaelumTreePlainsTala2 : CaelumTreePlainsTala
{
    Default
    {
        Radius 15;
        Height 111;
    }
}

class CaelumTreePlainsTala3 : CaelumTreePlainsTala
{
    Default
    {
        Radius 25;
        Height 185;
    }
}

class CaelumTreePlainsEspinillo : CaelumEnvironmentProp
{
    Default
    {
        Tag "$CA_TREE_PLAINS_ESPINILLO";
        Radius 16;
        Height 106;
    }
    States
    {
        Spawn: CAVT O -1; Stop;
    }
}

class CaelumTreePlainsEspinillo2 : CaelumTreePlainsEspinillo
{
    Default
    {
        Radius 12;
        Height 79.5;
    }
}

class CaelumTreePlainsEspinillo3 : CaelumTreePlainsEspinillo
{
    Default
    {
        Radius 20;
        Height 132.5;
    }
}

class CaelumTreeCoastCoronillo : CaelumEnvironmentProp
{
    Default
    {
        Tag "$CA_TREE_COAST_CORONILLO";
        Radius 18;
        Height 142;
    }
    States
    {
        Spawn: CAVT P -1; Stop;
    }
}

class CaelumTreeCoastCoronillo2 : CaelumTreeCoastCoronillo
{
    Default
    {
        Radius 13.5;
        Height 106.5;
    }
}

class CaelumTreeCoastCoronillo3 : CaelumTreeCoastCoronillo
{
    Default
    {
        Radius 22.5;
        Height 177.5;
    }
}

class CaelumTreeCoastWillow : CaelumEnvironmentProp
{
    Default
    {
        Tag "$CA_TREE_COAST_WILLOW";
        Radius 20;
        Height 178;
    }
    States
    {
        Spawn: CAVT Q -1; Stop;
    }
}

class CaelumTreeCoastWillow2 : CaelumTreeCoastWillow
{
    Default
    {
        Radius 15;
        Height 133.5;
    }
}

class CaelumTreeCoastWillow3 : CaelumTreeCoastWillow
{
    Default
    {
        Radius 25;
        Height 222.5;
    }
}

class CaelumTreeCoastCeibo : CaelumEnvironmentProp
{
    Default
    {
        Tag "$CA_TREE_COAST_CEIBO";
        Radius 24;
        Height 158;
    }
    States
    {
        Spawn: CAVT R -1; Stop;
    }
}

class CaelumTreeCoastCeibo2 : CaelumTreeCoastCeibo
{
    Default
    {
        Radius 18;
        Height 118.5;
    }
}

class CaelumTreeCoastCeibo3 : CaelumTreeCoastCeibo
{
    Default
    {
        Radius 30;
        Height 197.5;
    }
}

class CaelumTreeCityJacaranda : CaelumEnvironmentProp
{
    Default
    {
        Tag "$CA_TREE_CITY_JACARANDA";
        Radius 20;
        Height 196;
    }
    States
    {
        Spawn: CAVT S -1; Stop;
    }
}

class CaelumTreeCityJacaranda2 : CaelumTreeCityJacaranda
{
    Default
    {
        Radius 15;
        Height 147;
    }
}

class CaelumTreeCityJacaranda3 : CaelumTreeCityJacaranda
{
    Default
    {
        Radius 25;
        Height 245;
    }
}

class CaelumTreeCityTipa : CaelumEnvironmentProp
{
    Default
    {
        Tag "$CA_TREE_CITY_TIPA";
        Radius 26;
        Height 226;
    }
    States
    {
        Spawn: CAVT T -1; Stop;
    }
}

class CaelumTreeCityTipa2 : CaelumTreeCityTipa
{
    Default
    {
        Radius 19.5;
        Height 169.5;
    }
}

class CaelumTreeCityTipa3 : CaelumTreeCityTipa
{
    Default
    {
        Radius 32.5;
        Height 282.5;
    }
}

class CaelumTreeCityPlane : CaelumEnvironmentProp
{
    Default
    {
        Tag "$CA_TREE_CITY_PLANE";
        Radius 20;
        Height 244;
    }
    States
    {
        Spawn: CAVT U -1; Stop;
    }
}

class CaelumTreeCityPlane2 : CaelumTreeCityPlane
{
    Default
    {
        Radius 15;
        Height 183;
    }
}

class CaelumTreeCityPlane3 : CaelumTreeCityPlane
{
    Default
    {
        Radius 25;
        Height 305;
    }
}
