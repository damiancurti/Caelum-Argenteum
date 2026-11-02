// #614: generado desde assets/powerups/DATA.json.
class CaelumPowerupData : Object
{
    const REST=0;
    const REPLENISH=1;
    const WEAPONS=2;
    const ARMOR=3;
    const SLEEP=4;
    const UPGRADE=5;
    const COMMON_PERCENT=90;
    const RESPAWN_TICS=2100;
    const REST_SECONDS=180;
    const SLEEP_SECONDS=360;
    const MAX_TIER=3;
    const ANIMA_FRACTION=0.5;
    static clearscope int PointCount(){return level.MapName=="CASEWER"?8:level.MapName=="CAHUNT"?16:0;}
    static clearscope String Key(int kind){static const String keys[]={"REST","REPLENISH","WEAPONS","ARMOR","SLEEP","UPGRADE"};return kind>=0 && kind<6?keys[kind]:"REST";}
    static clearscope vector3 Point(int index){switch((level.MapName=="CAHUNT"?8:0)+index){
        case 0:return (992,992,0);
        case 1:return (224,32,0);
        case 2:return (2016,928,0);
        case 3:return (1120,32,0);
        case 4:return (992,1632,0);
        case 5:return (32,1120,0);
        case 6:return (2016,2016,0);
        case 7:return (1120,1120,0);
        case 8:return (2016,1824,0);
        case 9:return (480,32,0);
        case 10:return (96,1888,0);
        case 11:return (1888,352,0);
        case 12:return (4064,1824,0);
        case 13:return (2144,160,0);
        case 14:return (2272,2016,0);
        case 15:return (3936,96,0);
        case 16:return (2016,3872,0);
        case 17:return (32,2272,0);
        case 18:return (1824,2080,0);
        case 19:return (224,4064,0);
        case 20:return (4064,3616,0);
        case 21:return (2080,2272,0);
        case 22:return (2272,4064,0);
        case 23:return (3680,2080,0);
    }return (0,0,0);}
}
