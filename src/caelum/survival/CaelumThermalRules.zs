// Matemática compartida sin estado de jugador; E no es temperatura corporal.
class CaelumThermalRules : Object
{
    static clearscope double ShiveringExtraMet(double exposure)
    {return (CaelumThermalData.SHIVER_MAX_MET-1)*Clamp(-exposure/CaelumThermalData.SHIVER_FULL_COLD_EXPOSURE,0.0,1.0);}

    static clearscope double HydrationPointsPerKg(double massKg)
    {
        return CaelumConstants.WATER_RECOVERY_PER_LITER_PER_PULSE
            *CaelumConstants.CONSUMABLE_REGENERATION_SECONDS/Max(0.001,massKg);
    }

    static clearscope double SweatRate(double exposure,double area,double hydration)
    {
        double reference=Area(CaelumThermalData.REFERENCE_MASS_KG,CaelumThermalData.REFERENCE_HEIGHT_METERS);
        return CaelumThermalData.SWEAT_MAX_KG_HOUR*Max(0.0,area)/reference
            *Clamp(exposure/CaelumThermalData.SWEAT_FULL_EXPOSURE,0.0,1.0)
            *Clamp(hydration/CaelumThermalData.SWEAT_HYDRATION_FADE,0.0,1.0);
    }

    static clearscope String StateKey(double exposure,double toughness)
    {
        int severity=Severity(exposure,toughness);
        if(severity==0)return "CA_THERMAL_SAFE";
        if(exposure<0)return severity==1 ? "CA_THERMAL_COLD" : severity==2 ? "CA_THERMAL_HYPO" : "CA_THERMAL_EXTREME_COLD";
        return severity==1 ? "CA_THERMAL_HEAT" : severity==2 ? "CA_THERMAL_HYPER" : "CA_THERMAL_EXTREME_HEAT";
    }

    static clearscope double Area(double massKg,double heightMeters)
    { return 0.202*Max(0.001,massKg)**0.425*Max(0.001,heightMeters)**0.725; }

    static clearscope double AirConvection(double velocityMps)
    { return CaelumThermalData.CONVECTION_FACTOR
        *Max(CaelumThermalData.NATURAL_WIND_MPS,velocityMps)**CaelumThermalData.CONVECTION_EXPONENT; }

    static clearscope double ConductancePerArea(double clo,double film)
    { return film>0 ? 1.0/(CaelumThermalData.CLO_RESISTANCE*Max(0.0,clo)+1.0/film) : 0; }

    static clearscope double ReferenceConductance(double area)
    { return area*ConductancePerArea(CaelumThermalData.Clo(CaelumThermalData.LIGHT_CLOTH),
        AirConvection(CaelumThermalData.NATURAL_WIND_MPS)+CaelumThermalData.REFERENCE_RADIATION); }

    // Corrección del autor: sólo masa biológica. La altura afecta G, no C.
    static clearscope double Inertia(double massKg)
    {
        double referenceArea=Area(CaelumThermalData.REFERENCE_MASS_KG,CaelumThermalData.REFERENCE_HEIGHT_METERS);
        return CaelumThermalData.REFERENCE_SECONDS*ReferenceConductance(referenceArea)
            *Max(0.001,massKg)/CaelumThermalData.REFERENCE_MASS_KG;
    }

    static clearscope double Comfort(int race,bool demon=false)
    {
        if(demon)return CaelumThermalData.DEMON_COMFORT_C;
        return race==CaelumConstants.RACE_BEAST_MAN || race==CaelumConstants.RACE_CAELITH
            ? CaelumThermalData.FURRED_COMFORT_C : CaelumThermalData.HUMAN_COMFORT_C;
    }

    static clearscope double ThresholdScale(double toughness)
    { return 1.0+CaelumArmorRules.ToughnessReductionPercent(toughness)/100.0; }

    static clearscope double Threshold(int tier,double toughness)
    {return CaelumThermalData.ExposureThreshold(tier)*ThresholdScale(toughness);}

    static clearscope double DamageResistance(double toughness)
    { return Clamp(CaelumArmorRules.ToughnessReductionPercent(toughness)/100.0,0.0,1.0); }

    static clearscope int Severity(double exposure,double toughness)
    {
        double d=Abs(exposure)/ThresholdScale(toughness);
        double epsilon=CaelumThermalData.THRESHOLD_EPSILON;
        if(d>CaelumThermalData.ExposureThreshold(3)+epsilon)return 3;
        if(d+epsilon>=CaelumThermalData.ExposureThreshold(2))return 2;
        if(d+epsilon>=CaelumThermalData.ExposureThreshold(1))return 1;
        return 0;
    }

    static clearscope double HeatCost(double exposure,double toughness)
    { return exposure>0 ? 1.0+Severity(exposure,toughness) : 1.0; }

    static clearscope double ColdAttack(double exposure,double toughness,bool blunt)
    {
        int severity=exposure<0 ? Severity(exposure,toughness) : 0;
        double scale=1.5**severity;
        return blunt ? scale : 1.0+(scale-1.0)/2.0;
    }

    static clearscope double Speed(double exposure,double toughness)
    { return 1.0/ColdAttack(exposure,toughness,false); }

    // ACSM neto: el reposo ya está equilibrado en el término ambiental.
    // Bajadas: forma de Minetti normalizada al coste ACSM llano, sin salto
    // al cruzar pendiente cero. Aproximación aprobada; no se aplica a caídas.
    static clearscope double LocomotionHeat(double movedMassKg,double speedMetersSecond,
        double grade,bool running,double gravityMetersSecondSquared)
    {
        double speed=Max(0.0,speedMetersSecond);
        double mass=Max(0.0,movedMassKg);
        double horizontal=running ? CaelumThermalData.RUN_OXYGEN_SPEED : CaelumThermalData.WALK_OXYGEN_SPEED;
        if(grade<0)return horizontal*speed*mass*CaelumThermalData.OXYGEN_JOULES_PER_ML
            *CaelumThermalData.DownhillCostRatio(grade,running);
        double ascent=running ? CaelumThermalData.RUN_OXYGEN_GRADE : CaelumThermalData.WALK_OXYGEN_GRADE;
        double metabolic=(horizontal+ascent*grade)*speed*mass*CaelumThermalData.OXYGEN_JOULES_PER_ML;
        double external=mass*Max(0.0,gravityMetersSecondSquared)*speed*grade;
        return Max(0.0,metabolic-external);
    }

    static clearscope double PositiveWorkHeat(double workJoules)
    { return Max(0.0,workJoules)*(1.0/CaelumThermalData.POSITIVE_WORK_EFFICIENCY-1.0); }

    static clearscope double JumpHeat(double movedMassKg,double previousUpSpeed,double launchUpSpeed)
    {
        double before=Max(0.0,previousUpSpeed),after=Max(0.0,launchUpSpeed);
        return PositiveWorkHeat(Max(0.0,movedMassKg)*Max(0.0,after*after-before*before)/2.0);
    }

    // Decisión del autor: perfiles sin trabajo medido proporcionales al coste
    // nominal de Aire y anclados al salto. No leer Aire restante ni recargos.
    static clearscope double ProfiledActionHeat(double referenceJumpJoules,
        double actionAirCost,double jumpAirCost)
    {
        return jumpAirCost>0 ? Max(0.0,referenceJumpJoules)*Max(0.0,actionAirCost)/jumpAirCost : 0;
    }

    // Adaptadores del contrato anterior, usados por diagnósticos históricos.
    // Desde #136 no hay cola: sólo importa el esfuerzo actual, no el pico previo.
    static clearscope double ActivityPower(double previous,double target,double worldSeconds)
    {
        return Max(0.0,target);
    }

    static clearscope double AverageActivityPower(double previous,double target,double worldSeconds)
    {
        return Max(0.0,target);
    }

    static clearscope double Acclimation(double previous,double climateC,double originalCenter,double worldSeconds,double multiplier=1)
    {
        double factor=Max(1.0,multiplier);
        double limit=CaelumThermalData.ACCLIMATION_LIMIT_C*factor;
        double target=Clamp(climateC-originalCenter,-limit,limit);
        double step=Max(0.0,worldSeconds)*CaelumThermalData.ACCLIMATION_C_PER_DAY*factor/CaelumThermalData.WORLD_DAY_SECONDS;
        // Si baja Resiliencia, cambia el destino y la velocidad; el estado
        // previo vuelve gradualmente en lugar de recortarse instantáneamente.
        return previous+Clamp(target-previous,-step,step);
    }

    static clearscope double Advance(double exposure,double imbalanceWatts,double conductance,
        double inertia,double worldSeconds,double realSeconds=0,double magicWatts=0)
    {
        if(inertia<=0)return exposure;
        double dw=Max(0.0,worldSeconds),dr=Max(0.0,realSeconds);
        if(dw<=0)return exposure+magicWatts*dr/inertia;
        double power=imbalanceWatts+magicWatts*dr/dw;
        if(conductance<=0)return exposure+power*dw/inertia;
        double equilibrium=power/conductance;
        return equilibrium+(exposure-equilibrium)*Exp(-conductance*dw/inertia);
    }

    // Integra los tramos de severidad: atravesar un umbral no equivale a haber
    // sufrido el estado final durante todo el intervalo real.
    static clearscope double SeveritySeconds(double before,double imbalanceWatts,double conductance,
        double inertia,double worldSeconds,double realSeconds,double toughness,double magicWatts=0)
    {
        if(realSeconds<=0 || inertia<=0)return 0;
        double after=Advance(before,imbalanceWatts,conductance,inertia,worldSeconds,realSeconds,magicWatts);
        return SeverityBetween(before,after,imbalanceWatts,conductance,inertia,worldSeconds,realSeconds,toughness,magicWatts);
    }

    static clearscope double SeverityBetween(double before,double after,double imbalanceWatts,double conductance,
        double inertia,double worldSeconds,double realSeconds,double toughness,double magicWatts=0)
    {
        if(realSeconds<=0 || inertia<=0)return 0;
        // La solución de coeficientes constantes es monótona. Sin cruzar un
        // umbral, su dosis es exactamente la misma durante todo el intervalo.
        int first=Severity(before,toughness),last=Severity(after,toughness);
        if(first==last && (first==0 || before*after>=0))return realSeconds*first;
        double low=Min(before,after),high=Max(before,after);
        double thresholdScale=ThresholdScale(toughness);
        double fractions[8];int count=1;fractions[0]=0;
        for(int sign=-1;sign<=1;sign+=2)
            for(int tier=1;tier<=3;tier++)
            {
                double boundary=sign*CaelumThermalData.ExposureThreshold(tier)*thresholdScale;
                if(boundary<=low || boundary>=high)continue;
                double fraction;
                if(worldSeconds<=0 || conductance<=0)
                    fraction=(boundary-before)/(after-before);
                else
                {
                    double equilibrium=(imbalanceWatts+magicWatts*realSeconds/worldSeconds)/conductance;
                    fraction=-inertia/conductance*Log((boundary-equilibrium)/(before-equilibrium))/worldSeconds;
                }
                fractions[count++]=Clamp(fraction,0.0,1.0);
            }
        fractions[count++]=1;
        for(int i=1;i<count;i++)
            for(int j=i;j>0 && fractions[j]<fractions[j-1];j--)
            { double swap=fractions[j];fractions[j]=fractions[j-1];fractions[j-1]=swap; }
        double seconds=0;
        for(int i=1;i<count;i++)
        {
            double middle=(fractions[i]+fractions[i-1])/2.0;
            double value=Advance(before,imbalanceWatts,conductance,inertia,
                worldSeconds*middle,realSeconds*middle,magicWatts);
            seconds+=(fractions[i]-fractions[i-1])*realSeconds*Severity(value,toughness);
        }
        return seconds;
    }

    static clearscope double FireFlux(double watts,double distanceMeters,double flameRadiusMeters)
    {
        double r=Max(distanceMeters,Max(0.001,flameRadiusMeters));
        return CaelumThermalData.FIRE_RADIATIVE_FRACTION*Max(0.0,watts)/(4.0*CaelumThermalData.CIRCLE_PI*r*r);
    }
}
