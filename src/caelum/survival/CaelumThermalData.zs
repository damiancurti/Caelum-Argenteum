// #130: calibración jugable aprobada; unidades SI salvo exposición equivalente.
// Procedencia física y decisiones del autor en SYSTEMS, sección V5.1 térmica.
class CaelumThermalData : Object
{
    const REVISION=7;
    static clearscope double ExposureThreshold(int tier)
    {return tier==1 ? 10.0 : tier==2 ? 20.0 : 30.0;}
    const LIGHT_CLOTH=0;
    const THICK_CLOTH=1;
    const LEATHER=2;
    const THICK_LEATHER=3;
    const METAL_CLOTH=4;
    const HUMAN_COMFORT_C=22.0;
    const FURRED_COMFORT_C=17.0;
    const DEMON_COMFORT_C=32.0;
    const CLO_RESISTANCE=0.155;
    const NATURAL_WIND_MPS=0.137;
    const CONVECTION_FACTOR=8.6;
    const CONVECTION_EXPONENT=0.53;
    const REFERENCE_RADIATION=4.7;
    const WATER_CONVECTION=100.0;
    const MET_WATTS_M2=58.2;
    // #140: esfuerzo total aprobado; el reposo de 1 MET ya está en el balance.
    const CARBINE_FIRE_MET=2.0;
    const CARBINE_RELOAD_MET=2.5;
    // #136: natación moderada/intensa, independiente del salto aumentado.
    const SWIM_MET=6.0;
    const SWIM_FAST_MET=10.0;
    const PUSH_MET=6.0;
    const SHIVER_MAX_MET=5.0;
    const SHIVER_FULL_COLD_EXPOSURE=5.0;
    const REFERENCE_SECONDS=1200.0;
    const REFERENCE_MASS_KG=80.0;
    const REFERENCE_HEIGHT_METERS=1.75;
    // Referencia histórica para fixtures antiguos; el runtime ya no usa cola.
    const ACTIVITY_HALF_LIFE_SECONDS=120.0;
    const POSITIVE_WORK_EFFICIENCY=0.25;
    const OXYGEN_JOULES_PER_ML=20.1;
    const WALK_OXYGEN_SPEED=0.1;
    const WALK_OXYGEN_GRADE=1.8;
    const RUN_OXYGEN_SPEED=0.2;
    const RUN_OXYGEN_GRADE=0.9;
    // Minetti et al. 2002, DOI 10.1152/japplphysiol.01177.2001.
    // Sólo pendientes dentro del dominio publicado; fuera se retiene el borde.
    const MINETTI_MINIMUM_GRADE=-0.45;
    static clearscope double DownhillCostRatio(double grade,bool running)
    {
        double i=Clamp(grade,MINETTI_MINIMUM_GRADE,0.0);
        if(running)return (((((155.4*i-30.4)*i-43.3)*i+46.3)*i+19.5)*i+3.6)/3.6;
        return (((((280.5*i-58.7)*i-76.8)*i+51.9)*i+19.6)*i+2.5)/2.5;
    }
    const WET_EXCHANGE_PER_PERCENT=0.02;
    const RAIN_PERCENT_PER_MINUTE_MM=2.0;
    const ACCLIMATION_C_PER_DAY=1.0;
    const ACCLIMATION_LIMIT_C=5.0;
    const WORLD_DAY_SECONDS=86400.0;
    const DRINK_SECONDS=10.0;
    const DRINK_OFFSET_C=10.0;
    const FIRE_RADIATIVE_FRACTION=0.35;
    const FIRE_ABSORPTIVITY=0.95;
    const FIRE_VISIBILITY_SAMPLES=4;
    const CIRCLE_PI=3.141592653589793;
    // Lewis: 2,2 K/Torr a nivel del mar, convertido una sola vez a K/kPa.
    // EnergyPlus v25.1.0 ThermalComfort.cc; evaporación de agua ~2,45 MJ/kg.
    const LEWIS_K_PER_KPA=16.5013576;
    const LATENT_J_PER_KG=2450000.0;
    // #133: sudor humano de referencia, aprobado por el autor; horas del mundo.
    const SWEAT_MAX_KG_HOUR=2.0;
    const BREATHING_MODERATE=1.5;
    const BREATHING_HIGH=2.0;
    const BREATHING_LITERS_MINUTE=6.0;
    const AIR_DENSITY_KG_M3=1.2;
    const AIR_SPECIFIC_HEAT_J_KG_K=1005.0;
    const SWEAT_FULL_EXPOSURE=5.0;
    const SWEAT_HYDRATION_FADE=20.0;
    // Resolución numérica del acoplamiento no lineal, no duración de balance.
    const SWEAT_STEP_SECONDS=2.0;
    // Tolerancias numéricas, no bandas nuevas de balance.
    const THRESHOLD_EPSILON=0.000000001;
    const DRY_PERCENT_TOLERANCE=0.0001;
    const SURFACE_SAMPLES=16;
    const ENVIRONMENT_SAMPLE_TICS=TICRATE;
    // Conserva el alcance local del detector de refugio existente; ocho rayos
    // distinguen paredes conectadas incluso si el recinto está girado.
    const SHELTER_RANGE_MU=1024.0;
    const SHELTER_RAYS=8;

    static clearscope double Clo(int material)
    {
        if(material<0)return 0;
        if(material==THICK_CLOTH)return 1.0;
        if(material==LEATHER)return 1.2;
        if(material==THICK_LEATHER)return 1.8;
        if(material==METAL_CLOTH)return 0.6;
        return 0.5;
    }
    static clearscope double Permeability(int material)
    {
        if(material<0)return 1;
        if(material==THICK_CLOTH)return 0.75;
        if(material==LEATHER)return 0.45;
        if(material==THICK_LEATHER)return 0.30;
        if(material==METAL_CLOTH)return 0.60;
        return 0.90;
    }
    // Ajuste acoplado a 80 kg/1,75 m, E=0, 22 C, HR50 y 1 m/s.
    // Derivación reproducible: validation_510/calibrate_drying.py.
    static clearscope double WaterCapacityKgPerArea(int material)
    {
        if(material==THICK_CLOTH)return 0.332367940848569;
        if(material==LEATHER)return 0.346983535001855;
        if(material==THICK_LEATHER)return 0.420869697057457;
        return 0.192336119324285;
    }

    static clearscope double DryingSeconds(int material)
    {
        if(material==THICK_CLOTH)return 120*60;
        if(material==LEATHER)return 180*60;
        if(material==THICK_LEATHER)return 300*60;
        // El metal no almacena agua: la humedad pertenece a su ropa ligera.
        return 60*60;
    }
    static clearscope int MaterialForArmor(int armorType)
    {
        if(armorType==CaelumConstants.ARMOR_TYPE_MAGIC)return THICK_CLOTH;
        if(armorType==CaelumConstants.ARMOR_TYPE_LIGHT)return LEATHER;
        if(armorType==CaelumConstants.ARMOR_TYPE_MEDIUM
            || armorType==CaelumConstants.ARMOR_TYPE_HEAVY)return METAL_CLOTH;
        return LIGHT_CLOTH;
    }
    static clearscope double FireWatts(int profile)
    {
        if(profile==1)return 1000;
        if(profile==2)return 5000;
        if(profile==3)return 20000;
        if(profile==4)return 80000;
        return 0;
    }
}
