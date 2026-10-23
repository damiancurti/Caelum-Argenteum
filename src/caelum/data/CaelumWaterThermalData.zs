// #409: datos térmicos aprobados; no dependen de Destreza ni de eficiencia artesanal.
class CaelumWaterThermalData : Object
{
    const REVISION=1;
    const PI=3.141592653589793;
    const BOILING_C=100.0;
    const DRINK_MAX_C=85.0;
    const WATER_CP=4180.0;
    const GLASS_CP=830.0;
    const LEATHER_CP=1500.0;
    const GLASS_K=1.1;
    const LEATHER_K=0.14;
    const LEATHER_WALL_M=0.006;
    // Vidrio común aprobado por el autor el 2026-10-23.
    const GLASS_DENSITY_KG_M3=2500.0;
    const VESSEL_KG=1.0;
    const USEFUL_POWER_W=1000.0;
    const EFFICIENCY=0.25;
    const COAL_J_KG=28000000.0;
    const BOIL_SECONDS=60.0;
    const VAPORIZATION_J_KG=2257000.0;

    static clearscope double Seconds(double liters,double temperature)
    {return ((Max(0,liters)*WATER_CP+VESSEL_KG*GLASS_CP)
        *Max(0,BOILING_C-temperature))/USEFUL_POWER_W+BOIL_SECONDS;}
    static clearscope int Fuel(double liters,double temperature)
    {return int(Ceil(Seconds(liters,temperature)*USEFUL_POWER_W
        /EFFICIENCY/COAL_J_KG/CaelumConstants.MATERIAL_UNIT_WEIGHT));}
    static clearscope double Output(double liters)
    {return Max(0,liters-USEFUL_POWER_W*BOIL_SECONDS/VAPORIZATION_J_KG);}
    static clearscope double Mix(double firstLiters,double firstC,double addedLiters,double addedC)
    {return firstLiters+addedLiters>0 ? (firstLiters*firstC+addedLiters*addedC)/(firstLiters+addedLiters) : addedC;}
    static clearscope double Cool(double temperature,double ambient,double wind,double seconds,
        double liters,double capacity,bool leather)
    {
        if(seconds<=0 || liters<=0 || capacity<=0)return temperature;
        double radius=(capacity/1000*3/(4*PI))**(1.0/3.0);
        double area=4*PI*radius*radius;
        double mass=CaelumConstants.SPECIAL_ITEM_DEFAULT_WEIGHT;
        double wall=leather ? LEATHER_WALL_M
            : (radius*radius*radius+mass/Max(1,GLASS_DENSITY_KG_M3)*3/(4*PI))**(1.0/3.0)-radius;
        double film=CaelumThermalRules.AirConvection(wind)+CaelumThermalData.REFERENCE_RADIATION;
        double conductance=area/(wall/(leather?LEATHER_K:GLASS_K)+1/film);
        double heatCapacity=liters*WATER_CP+mass*(leather?LEATHER_CP:GLASS_CP);
        return ambient+(temperature-ambient)*Exp(-conductance*seconds/heatCapacity);
    }
}
