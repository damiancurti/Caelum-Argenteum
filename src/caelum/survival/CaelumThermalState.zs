// Estado personal serializado. El jugador lo conserva en su registro viajero;
// cada NPC soportado posee su propia instancia, nunca la de otro personaje.
class CaelumThermalState : Object play
{
    int Revision;
    transient CaelumThermalCoefficients Coefficients;
    double Exposure,Acclimation,ActivityWatts,DamageRemainder;
    double AcclimationMultiplier;
    double BaseWaterKg[4];
    double ActorWaterKg[4];
    double Coverage[4];
    int Material[4];
    double WorkWaterKg[4];
    bool Bare;
    // En jugador Hydration sólo es copia de trabajo; CurrentThirst es su dueño.
    // En NPC esta reserva persistente no tiene reposición automática.
    bool Sweats;
    bool CanBreathe;
    double BreathingAirRatio,RespirationJoules;
    transient bool BreathAudioKnown,BreathAudioActive;
    transient Sound BreathAudioCue;
    transient int NextBreathSoundTic;
    double Hydration,SweatKg,SweatRunoffKg,SweatRateKgHour;
    double SubmergedCoverage[4];
    double SubmergedTemperatureC[4];
    double WaterRowC[16];
    int WaterRowMask,LastWaterRowMask;
    double BodyMassKg,HeightMeters,MovedMassKg,ComfortC,Toughness,LastBodyRadius;
    double LastSubmergedFraction;
    double LastWorldStamp;
    bool RuntimeReady;
    int NextUpdateTic,LastWaterLevel,EnvironmentDate,EnvironmentMinute;
    String RuntimeMap;
    double ReferenceJumpHeat,ActivityJoules,ActionJoules;
    vector3 LastPosition;
    vector2 PropelledVelocity;
    double PendingActivityJoules,LocalMotionMps,FireWatts;
    bool MotionInitialized;
    double DrinkOffset,DrinkRemaining;
    double AirC,Humidity,WindMps,RainMmHour,WaterC,ClimateC;
    double WetnessPercent,Conductance,Imbalance,SurfaceArea,Inertia;
    double AbsorbedImpactJoules,AbsorbedContinuousJoules,EvaporatedKg,EvaporationJoules;
    double AppliedDamageHP;
    double LastOriginalAir,LastTotalAir;
    int Severity,LastRealTic,LastEnvironmentTic,NextSampleTic;
    String SourceMap;
    bool Available,Roof,WindSheltered;

    CaelumThermalState CopyForForecast()
    {
        let copy=new("CaelumThermalState");
        copy.Revision=Revision;
        copy.Exposure=Exposure;
        copy.Acclimation=Acclimation;
        copy.AcclimationMultiplier=AcclimationMultiplier;
        copy.ActivityWatts=ActivityWatts;
        copy.DamageRemainder=DamageRemainder;
        for(int i=0;i<4;i++)copy.BaseWaterKg[i]=BaseWaterKg[i];
        for(int i=0;i<4;i++)copy.ActorWaterKg[i]=ActorWaterKg[i];
        for(int i=0;i<4;i++)copy.Coverage[i]=Coverage[i];
        for(int i=0;i<4;i++)copy.Material[i]=Material[i];
        for(int i=0;i<4;i++)copy.WorkWaterKg[i]=WorkWaterKg[i];
        copy.Bare=Bare;
        copy.Sweats=Sweats;copy.Hydration=Hydration;copy.SweatKg=SweatKg;
        copy.CanBreathe=CanBreathe;copy.BreathingAirRatio=BreathingAirRatio;copy.RespirationJoules=RespirationJoules;
        copy.SweatRunoffKg=SweatRunoffKg;copy.SweatRateKgHour=SweatRateKgHour;
        for(int i=0;i<4;i++)
        {copy.SubmergedCoverage[i]=SubmergedCoverage[i];copy.SubmergedTemperatureC[i]=SubmergedTemperatureC[i];}
        for(int i=0;i<16;i++)copy.WaterRowC[i]=WaterRowC[i];
        copy.WaterRowMask=WaterRowMask;copy.LastWaterRowMask=LastWaterRowMask;
        copy.BodyMassKg=BodyMassKg;
        copy.HeightMeters=HeightMeters;
        copy.MovedMassKg=MovedMassKg;
        copy.ComfortC=ComfortC;
        copy.Toughness=Toughness;
        copy.LastSubmergedFraction=LastSubmergedFraction;
        copy.ReferenceJumpHeat=ReferenceJumpHeat;
        copy.ActivityJoules=ActivityJoules;
        copy.ActionJoules=ActionJoules;
        copy.LastPosition=LastPosition;
        copy.MotionInitialized=MotionInitialized;
        copy.DrinkOffset=DrinkOffset;
        copy.DrinkRemaining=DrinkRemaining;
        copy.AirC=AirC;
        copy.Humidity=Humidity;
        copy.WindMps=WindMps;
        copy.RainMmHour=RainMmHour;
        copy.WaterC=WaterC;
        copy.ClimateC=ClimateC;
        copy.WetnessPercent=WetnessPercent;
        copy.Conductance=Conductance;
        copy.Imbalance=Imbalance;
        copy.SurfaceArea=SurfaceArea;
        copy.Inertia=Inertia;
        copy.AbsorbedImpactJoules=AbsorbedImpactJoules;
        copy.AbsorbedContinuousJoules=AbsorbedContinuousJoules;
        copy.EvaporatedKg=EvaporatedKg;
        copy.EvaporationJoules=EvaporationJoules;
        copy.LastOriginalAir=LastOriginalAir;
        copy.LastTotalAir=LastTotalAir;
        copy.Severity=Severity;
        copy.LastRealTic=LastRealTic;
        copy.LastEnvironmentTic=LastEnvironmentTic;
        copy.NextSampleTic=NextSampleTic;
        copy.SourceMap=SourceMap;
        copy.Available=Available;
        copy.Roof=Roof;
        copy.WindSheltered=WindSheltered;
        return copy;
    }

    void Initialize()
    {
        if(Revision>=CaelumThermalData.REVISION)return;
        if(Revision<1)
        {
            LastEnvironmentTic=-TICRATE;
            LastSubmergedFraction=-1;
            LastRealTic=level.maptime;
            SourceMap=level.MapName;
        }
        // Revisión 2: sólo añade una proyección derivada. No reinicia reservas,
        // exposición ni la aclimatación ganada bajo el contrato anterior.
        if(Revision<2)AcclimationMultiplier=1;
        // Revisión 3: la nueva reserva NPC empieza llena una sola vez.
        // El adaptador del jugador siempre recupera su Sed existente.
        if(Revision<3)Hydration=CaelumConstants.SURVIVAL_MAXIMUM;
        // Revisión 4: no migra reservas; sólo invalida proyecciones derivadas.
        if(Revision<4){Coefficients=null;CanBreathe=true;BreathingAirRatio=1;}
        Revision=CaelumThermalData.REVISION;
    }

}

// Un único balance de masa y calor: sólo la masa evaporada retira calor latente.
class CaelumThermalMoisture : Object
{
    static clearscope double VaporKpa(double temperatureC)
    { return CaelumWeatherRules.Saturation(Clamp(temperatureC,-80.0,100.0))/10.0; }

    static clearscope double EvaporationKgPerAreaSecond(int material,double surfaceC,
        double airC,double humidity,double velocityMps)
    {
        double gradient=Max(0.0,VaporKpa(surfaceC)-VaporKpa(airC)*Clamp(humidity,0.0,100.0)/100.0);
        return CaelumThermalData.Permeability(material)*CaelumThermalData.LEWIS_K_PER_KPA
            *CaelumThermalRules.AirConvection(velocityMps)*gradient/CaelumThermalData.LATENT_J_PER_KG;
    }

    // La masa de saturación reproduce el secado con exposición y evaporación
    // acopladas; no presupone una superficie de ropa fija a 22 C.
    static clearscope double CapacityPerArea(int material)
    { return CaelumThermalData.WaterCapacityKgPerArea(material); }

    static clearscope double WetPercent(double waterKg,double area,int material)
    {
        double capacity=area*CapacityPerArea(material);
        return capacity>0 ? Clamp(100.0*waterKg/capacity,0.0,100.0) : 0;
    }

    static clearscope double Evaporated(double availableKg,double area,int material,
        double surfaceC,double airC,double humidity,double velocityMps,double seconds)
    {
        return Min(Max(0.0,availableKg),Max(0.0,area)*Max(0.0,seconds)
            *EvaporationKgPerAreaSecond(material,surfaceC,airC,humidity,velocityMps));
    }
}
