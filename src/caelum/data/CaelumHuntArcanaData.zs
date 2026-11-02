// #616: generado desde assets/hunt/ARCANA.json.
class CaelumHuntArcanaData : Object
{
    static clearscope bool Present(){return level.MapName=="CAHUNT" && level.Sectors.Size()>0 && level.Sectors[0].GetUDMFInt("user_ca_hunt_arcana")==1;}
    const WHEEL_ROOM=22;
    const WHEEL_WATER=47;
    static clearscope vector3 Center(int card){switch(card){
        case 0:return (384,320,0);
        case 1:return (2432,320,0);
        case 2:return (384,2368,0);
        case 3:return (2432,2368,0);
        case 4:return (1024,320,0);
        case 5:return (3072,320,0);
        case 6:return (512,2688,0);
        case 7:return (3072,2368,0);
        case 8:return (1664,320,0);
        case 9:return (3712,320,0);
        case 10:return (1664,2368,0);
        case 11:return (3712,2368,0);
        case 12:return (384,1088,0);
        case 13:return (2432,1088,0);
        case 14:return (384,3136,0);
        case 15:return (2432,3136,0);
        case 16:return (1024,1088,0);
        case 17:return (3072,1088,0);
        case 18:return (1024,3136,0);
        case 19:return (3072,3136,0);
        case 20:return (1664,1088,0);
        case 21:return (3712,1088,0);
    }return (0,0,0);}
    static clearscope vector3 Door(int card){return Center(card)+(-CaelumHuntData.CELL/2,CaelumHuntData.CELL/2,0);}
    static clearscope vector3 Marker(int card){double offset=CaelumHuntData.CELL*(card==10?2.5:1.5);return Center(card)+(-offset,-offset,0);}
}
