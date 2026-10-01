// Generado desde assets/map06_port/LAYOUT.json.
class CaelumPortData : Object play
{
    const ISSUE = 16;
    const REVISION = 1;
    const MANDINGAS = 1000;
    const DEFENDERS = 100;
    const DEFENDER_ATTRIBUTE = 18;
    const DEFENDER_HEIGHT_M = 1.8;
    const DEFENDER_MASS_KG = 80;
    const EQUIPMENT_TIER = 1;
    const GATE_Y = 3584;
    const WALL_SOUTH_Y = 3520;
    const WALL_HEIGHT = 128;
    const RAM_START_Y = 4096;
    const ATTACKING_GUN_Y = 4736;
    const DEFENDING_GUN_Y = 3328;
    const DEFENDING_GUN_Z = 128;
    const DEFENDING_GUN_DX = 256;
    const OPERATOR_SIDE = 90;
    const GUARD_Y = 3440;
    const GUARD_SPACING = 40;
    const FORMATION_X = -2496;
    const FORMATION_Y = 5632;
    const FORMATION_COLUMNS = 40;
    const FORMATION_SPACING = 128;
    const EXIT_Y = 11520;
    const ROUTE_RADIUS = 96;
    const COMMAND_LINK_RADIUS = 1024;
    const COMMAND_UPDATE_TICS = 35;
    const TARGET_UPDATE_TICS = 8;
    const DEFENDER_HEIGHT = 57.6;
    static double GateX(int i)
    {
        if(i==0)return -2560;
        if(i==1)return -1536;
        if(i==2)return -512;
        if(i==3)return 512;
        if(i==4)return 1536;
        if(i==5)return 2560;
        return 0;
    }
    static vector3 BossPosition(){return (0,9216,0);}
    static vector3 BedPosition(){return (-768,1664,0);}
    static vector3 WorkbenchPosition(){return (-768,1472,0);}
    static vector3 CompletionPosition(){return (384,1856,0);}
    static bool IsCurrent(){return level.MapName=="MAP06" && ActorIterator.Create(46000,"CaelumPortSiege").Next()!=null;}
}
