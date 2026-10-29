// #410: geometría delegada y reservas aprobadas; fuente DATA.json.
class CaelumWaterFurnitureData : Object
{
    const REVISION=1;
    static clearscope double EmptyKg(int kind){return kind==0?240.447633269:342.976533957;}
    static clearscope double Radius(int kind){return kind==0?16.960000000:23.871924933;}
    static clearscope double Height(int kind){return kind==0?41.487466447:36.352000000;}
    static clearscope double ThermalArea(int kind){return kind==0?2.053333333:6.000000000;}
    static clearscope double IronGrams(int kind){return kind==0?240448.000000000:342977.000000000;}
    const WALL_M=0.006;
    static clearscope double Capacity(int kind){return kind==0?200:1000;}
    static clearscope double Refill(int kind){return kind==0?1:0;}
    static clearscope double Facing(int kind){return kind==0?90:90;}
    static clearscope double InitialLiters(int kind){return kind==0?Capacity(kind):0;}
    static clearscope vector3 Position(int kind){return kind==0?(1024,-768,0):(896,-768,0);}
}
