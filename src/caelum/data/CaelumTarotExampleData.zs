// #440: generado desde assets/tarot_examples; sin búsquedas geométricas por tic.
class CaelumTarotExampleData : Object
{
    const REVISION=1;
    const ROOM=7754;
    const THRESHOLD=7758;
    const WATER=7759;
    const DEPTH=64;
    const LIGHT_DRY=192;
    const LIGHT_WET=32;
    static vector3 Controller(){return (-27776,-30448,0);}
    static vector3 Door(int index) {
        if(index==0)return (-28736,-30712,0);
        if(index==1)return (-28352,-30712,0);
        if(index==2)return (-28032,-30712,0);
        if(index==3)return (-27520,-30712,0);
        return (0,0,0);}
    static int Slide(int index){
        if(index==0)return 1;
        if(index==1)return 1;
        if(index==2)return -1;
        if(index==3)return 1;
        return 0;}
    static vector3 Portal(int index){
        return index==0?(368,112,0.5):(-29568,-30784,0.5);}
    static vector3 Arrival(int index){
        return index==0?(-29440,-30784,0):(368,176,0);}
    static double Facing(int index){
        return index==0?90:90;}
    static bool Present(){return level.MapName=="MAP01" && level.Sectors.Size()>WATER
        && level.Sectors[ROOM].GetUDMFInt("user_ca_tarot_room")==1;}
}
