// Calor y combustible del campamento: segundos del mundo, sin depender de FPS.
class CaelumCampPhysics : Object
{
    static clearscope double FuelGrams(double seconds)
    {return Max(0,seconds)*CaelumCampData.FIRE_WATTS/CaelumCampData.WOOD_J_KG/CaelumConstants.MATERIAL_UNIT_WEIGHT;}
    static clearscope double SecondsFromFuel(double grams)
    {return Max(0,grams)*CaelumConstants.MATERIAL_UNIT_WEIGHT*CaelumCampData.WOOD_J_KG/CaelumCampData.FIRE_WATTS;}
    static clearscope double HeatCapacity(double liters)
    {return Max(0,liters)*CaelumWaterThermalData.WATER_CP+CaelumCampData.POT_KG*CaelumCampData.IRON_CP;}
    static clearscope double BoilingSeconds(double liters,double temperature)
    {return HeatCapacity(liters)*Max(0,CaelumWaterThermalData.BOILING_C-temperature)/CaelumCampData.USEFUL_WATTS+CaelumWaterThermalData.BOIL_SECONDS;}
    static clearscope double Cool(double temperature,double ambient,double wind,double seconds,double liters)
    {
        if(seconds<=0 || liters<=0)return temperature;
        double r=CaelumCampData.POT_DIAMETER_M/2,pi=CaelumWaterThermalData.PI;
        double sides=2*pi*r*CaelumCampData.PotDepth()+pi*r*r;
        double film=CaelumThermalRules.AirConvection(Max(0,wind))+CaelumThermalData.REFERENCE_RADIATION;
        double conductance=sides/(CaelumCampData.POT_WALL_M/CaelumCampData.IRON_K+1/film)+pi*r*r*film;
        return ambient+(temperature-ambient)*Exp(-conductance*seconds/HeatCapacity(liters));
    }
}

// Lo posee cada fogata; no cobra combustible mediante tiempo del sistema.
class CaelumCampFireState : Object play
{
    int Revision;
    bool Lit;
    double FuelGrams,ElapsedSeconds;
    void Ensure(){if(Revision<CaelumCampData.REVISION)Revision=CaelumCampData.REVISION;}
    double Advance(double seconds)
    {
        Ensure();if(!Lit || seconds<=0)return 0;
        double burning=Min(seconds,CaelumCampPhysics.SecondsFromFuel(FuelGrams));
        FuelGrams=Max(0,FuelGrams-CaelumCampPhysics.FuelGrams(burning));
        ElapsedSeconds+=burning;
        if(FuelGrams<=0.0000001){FuelGrams=0;Lit=false;}
        return burning;
    }
    void LeaveMap(){Lit=false;}
}
