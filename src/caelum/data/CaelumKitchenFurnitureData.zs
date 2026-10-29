// #410: generated from kitchen_stations/DATA.json; dimensions and placements.
class CaelumKitchenFurnitureData : Object
{
    const REVISION=1;
    const COUNT=3;
    static clearscope Name ActorClass(int id)
    {return id==0?'CaelumKitchenStoveStation':id==1?'CaelumKitchenOvenStation':'CaelumKitchenCounterStation';}
    static clearscope Vector3 Position(int id)
    {return id==0?(1460,336,0):id==1?(1532,336,0):(1652,336,0);}
    static clearscope double Facing(int id)
    {return id==0?90:id==1?90:90;}
    static clearscope double Radius(int id)
    {return id==0?11.2:id==1?11.2:28.8;}
    static clearscope double Height(int id)
    {return id==0?34.56:id==1?34.56:33.6;}
    static clearscope double MassKg(int id)
    {return id==0?175.997:id==1?175.997:89.295;}
}
