// Previsión aislada: no muta equipo, recursos, reloj ni fracciones de daño.
class CaelumThermalJourney : Object play
{
    CaelumThermalState Result;
    String Failure;
    double WorstExposure;

    // Dos climas evaluados en el mismo instante; la mezcla avanza por distancia.
    static void BlendRoute(CaelumWeatherSample result,CaelumWeatherSample origin,
        CaelumWeatherSample destination,double progress)
    {
        result.Clear();if(!origin.Available || !destination.Available)return;
        double p=Clamp(progress,0,1);result.Available=true;
        result.AirTemperatureC=CaelumWeatherRules.Mix(origin.AirTemperatureC,destination.AirTemperatureC,p);
        result.RelativeHumidityPercent=CaelumWeatherRules.Mix(origin.RelativeHumidityPercent,destination.RelativeHumidityPercent,p);
        result.WindSpeedKmh=CaelumWeatherRules.Mix(origin.WindSpeedKmh,destination.WindSpeedKmh,p);
        result.PrecipitationMmPerHour=CaelumWeatherRules.Mix(origin.PrecipitationMmPerHour,destination.PrecipitationMmPerHour,p);
        result.NormalMeanC=CaelumWeatherRules.Mix(origin.NormalMeanC,destination.NormalMeanC,p);
        result.AnnualMeanC=CaelumWeatherRules.Mix(origin.AnnualMeanC,destination.AnnualMeanC,p);
        result.GroundTemperatureC=CaelumWeatherRules.Mix(origin.GroundTemperatureC,destination.GroundTemperatureC,p);
        result.CloudFraction=CaelumWeatherRules.Mix(origin.CloudFraction,destination.CloudFraction,p);
    }

    bool Forecast(CaelumPlayer user,int mode,int elapsedTics,double speedKmh,int destinationRegion=-1,CaelumJourneyModel supplies=null)
    {
        Result=CaelumThermalService.CaptureForecast(user);Failure="";WorstExposure=0;
        let weather=CaelumWeatherState.Get(user);
        let clock=CaelumWorldClock.Get(user);
        let calendar=CaelumCalendarState.Get(user);
        int serial=calendar!=null ? calendar.DateSerial(clock) : -1;
        if(Result==null || weather==null || weather.Region<=0 || serial<0)
        {Failure="CA_JOURNEY_THERMAL_UNKNOWN";return false;}
        if(destinationRegion==-1)destinationRegion=weather.Region;
        if(!CaelumClimateNormals.Valid(destinationRegion))
        {Failure="CA_JOURNEY_THERMAL_UNKNOWN";return false;}
        if(CaelumThermalRules.Severity(Result.Exposure,Result.Toughness)>0)
        {Failure=Result.Exposure<0 ? "CA_JOURNEY_COLD" : "CA_JOURNEY_HEAT";return false;}
        bool sheltered=mode==CaelumJourneyState.MODE_CART || mode==CaelumJourneyState.MODE_SHIP;
        int civil=calendar.CivilDayTics(clock);
        int hour=CaelumWorldClock.TicsPerHour(),day=CaelumWorldClock.TicsPerDay();
        let origin=new("CaelumWeatherSample");let destination=new("CaelumWeatherSample");
        let outside=new("CaelumWeatherSample");let local=new("CaelumWeatherSample");
        int moving=CaelumJourneyRules.MovingTics(elapsedTics,mode);
        Result.Roof=sheltered;Result.WindSheltered=sheltered;Result.Available=true;
        for(int i=0;i<4;i++)Result.SubmergedCoverage[i]=0;
        int elapsed=0;
        while(elapsed<elapsedTics)
        {
            int phase=elapsed%(24*hour);
            bool sleeping=phase>=CaelumJourneyRules.WALK_HOURS*hour;
            int boundary=(sleeping ? 24*hour : CaelumJourneyRules.WALK_HOURS*hour)-phase;
            int step=Min(elapsedTics-elapsed,Min(boundary,hour/60));
            int midpoint=elapsed+step/2;
            int timestamp=civil+midpoint;
            origin.EvaluateRegion(weather.Region,serial+timestamp/day,timestamp%day,weather.Seed);
            destination.EvaluateRegion(destinationRegion,serial+timestamp/day,timestamp%day,weather.Seed);
            double progress=moving>0 ? double(CaelumJourneyRules.MovingTics(midpoint,mode))/moving : 0;
            BlendRoute(outside,origin,destination,progress);
            if(!outside.Available){Failure="CA_JOURNEY_THERMAL_UNKNOWN";return false;}
            local.ApplyShelter(outside,sheltered ? CaelumWeatherRules.INDOOR : CaelumWeatherRules.OPEN,
                CaelumWeatherRules.PROFILE_TEMPERATE_TRIAL);
            double speed=!sheltered && !sleeping ? speedKmh/3.6 : 0;
            Result.AirC=local.AirTemperatureC;Result.ClimateC=local.AirTemperatureC;
            Result.Humidity=local.RelativeHumidityPercent;
            Result.RainMmHour=sheltered ? 0 : local.PrecipitationMmPerHour;
            Result.WindMps=Sqrt(local.WindSpeedKmh*local.WindSpeedKmh/12.96+speed*speed);
            Result.WaterC=local.GroundTemperatureC;
            double seconds=double(step)*3600.0/hour;
            double effort=CaelumThermalRules.LocomotionHeat(Result.MovedMassKg,speed,0,false,CaelumThermalMotion.Gravity(user),Result.MuscularEfficiency);
            // Segundos lógicos de esfuerzo explícitos; dr permanece cero.
            int substeps=supplies!=null ? step : 1;
            for(int t=0;t<substeps;t++)
            {
                if(supplies!=null)
                {
                    Result.Hydration=supplies.Thirst;Result.BreathingAirRatio=supplies.MaxAir>0 ? supplies.Air/supplies.MaxAir : 1;
                    Result.ShiveringHunger=supplies.Hunger;
                    Result.ShiveringHungerPerMetSecond=supplies.HungerLoss*hour/3600.0/supplies.Comfort(sleeping);
                }
                CaelumThermalService.Integrate(Result,seconds/substeps,0,effort,0,0,seconds/substeps);
                if(Abs(Result.Exposure)>Abs(WorstExposure))WorstExposure=Result.Exposure;
                if(Result.Severity>0)
                {Failure=Result.Exposure<0 ? "CA_JOURNEY_COLD" : "CA_JOURNEY_HEAT";return false;}
                if(supplies!=null)
                {
                    // Como AdvancePersonalTimeTic: primero el balance térmico,
                    // luego provisiones y recuperación. Nunca cobrar dos veces.
                    supplies.Thirst=Result.Hydration;supplies.ThermalExposure=Result.Exposure;
                    supplies.Hunger=Result.ShiveringHunger;
                    supplies.ThermalToughness=Result.Toughness;supplies.Step(sleeping);
                    supplies.WalkTics+=int(!sleeping || mode==CaelumJourneyState.MODE_SHIP);
                    supplies.SleepTics+=int(sleeping);Result.Hydration=supplies.Thirst;Result.ShiveringHunger=supplies.Hunger;
                    if(supplies.Health<=0)return true;
                }
            }
            elapsed+=step;
        }
        return true;
    }
}
