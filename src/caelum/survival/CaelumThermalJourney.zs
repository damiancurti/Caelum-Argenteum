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

    CaelumPlayer Traveler;
    int Mode,End,Elapsed,ChunkEnd,OriginRegion,DestinationRegion,Serial,Civil,Hour,Day,Moving,WeatherSeed;
    double SpeedKmh,Effort;
    bool Sheltered,Sleeping;
    CaelumWeatherSample OriginSample,DestinationSample,Outside,Local;

    bool Begin(CaelumPlayer user,int mode,int elapsedTics,double speedKmh,int destinationRegion=-1,CaelumJourneyModel supplies=null,int limitTics=0)
    {
        Result=CaelumThermalService.CaptureForecast(user);Failure="";WorstExposure=0;
        if(Result!=null)CaelumThermalSurface.Clear(Result);
        let weather=CaelumWeatherState.Get(user);let clock=CaelumWorldClock.Get(user);
        let calendar=CaelumCalendarState.Get(user);
        Serial=calendar!=null?calendar.DateSerial(clock):-1;
        if(Result==null || weather==null || weather.Region<=0 || Serial<0)
        {Failure="CA_JOURNEY_THERMAL_UNKNOWN";return false;}
        if(destinationRegion==-1)destinationRegion=weather.Region;
        if(!CaelumClimateNormals.Valid(destinationRegion))
        {Failure="CA_JOURNEY_THERMAL_UNKNOWN";return false;}
        if(CaelumThermalRules.Severity(Result.Exposure,Result.Toughness)>0)
        {Failure=Result.Exposure<0?"CA_JOURNEY_COLD":"CA_JOURNEY_HEAT";return false;}
        Traveler=user;self.Mode=mode;self.SpeedKmh=speedKmh;OriginRegion=weather.Region;
        self.DestinationRegion=destinationRegion;WeatherSeed=weather.Seed;
        Sheltered=mode==CaelumJourneyState.MODE_CART || mode==CaelumJourneyState.MODE_SHIP;
        Civil=calendar.CivilDayTics(clock);Hour=CaelumWorldClock.TicsPerHour();Day=CaelumWorldClock.TicsPerDay();
        OriginSample=new('CaelumWeatherSample');DestinationSample=new('CaelumWeatherSample');
        Outside=new('CaelumWeatherSample');Local=new('CaelumWeatherSample');
        Moving=CaelumJourneyRules.MovingTics(elapsedTics,mode);
        Result.Roof=Sheltered;Result.WindSheltered=Sheltered;Result.Available=true;
        for(int i=0;i<4;i++)Result.SubmergedCoverage[i]=0;
        Result.DirtyWaterRowMask=0;Result.CleanWaterRowMask=0;Result.DynamicContactWater=false;Result.WaterRowMask=0;
        for(int i=0;i<4;i++){Result.DirtyWaterCoverage[i]=0;Result.CleanWaterCoverage[i]=0;}
        if(supplies!=null && supplies.Contamination!=null)supplies.Contamination.ClearImmersion();
        Elapsed=0;ChunkEnd=0;End=limitTics>0?Min(elapsedTics,limitTics):elapsedTics;
        return true;
    }
    bool Next(CaelumJourneyModel supplies=null)
    {
        if(Elapsed>=End)return true;
        if(Elapsed==ChunkEnd)
        {
            int phase=Elapsed%(24*Hour);Sleeping=phase>=CaelumJourneyRules.WALK_HOURS*Hour;
            int boundary=(Sleeping?24*Hour:CaelumJourneyRules.WALK_HOURS*Hour)-phase;
            int step=Min(End-Elapsed,Min(boundary,Hour/60));ChunkEnd=Elapsed+step;
            int midpoint=Elapsed+step/2,timestamp=Civil+midpoint;
            OriginSample.EvaluateRegion(OriginRegion,Serial+timestamp/Day,timestamp%Day,WeatherSeed);
            DestinationSample.EvaluateRegion(DestinationRegion,Serial+timestamp/Day,timestamp%Day,WeatherSeed);
            double progress=Moving>0?double(CaelumJourneyRules.MovingTics(midpoint,Mode))/Moving:0;
            BlendRoute(Outside,OriginSample,DestinationSample,progress);
            if(!Outside.Available){Failure="CA_JOURNEY_THERMAL_UNKNOWN";return false;}
            Local.ApplyShelter(Outside,Sheltered?CaelumWeatherRules.INDOOR:CaelumWeatherRules.OPEN,
                CaelumWeatherRules.PROFILE_TEMPERATE_TRIAL);
            double speed=!Sheltered && !Sleeping?SpeedKmh/3.6:0;
            Result.AirC=Local.AirTemperatureC;Result.ClimateC=Local.AirTemperatureC;
            Result.Humidity=Local.RelativeHumidityPercent;Result.RainMmHour=Sheltered?0:Local.PrecipitationMmPerHour;
            Result.WindMps=Sqrt(Local.WindSpeedKmh*Local.WindSpeedKmh/12.96+speed*speed);
            Result.WaterC=Local.GroundTemperatureC;
            Effort=CaelumThermalRules.LocomotionHeat(Result.MovedMassKg,speed,0,false,CaelumThermalMotion.Gravity(Traveler),Result.MuscularEfficiency);
        }
        // La misma muestra por minuto, ahora con cursor para avanzar al grupo
        // al unísono sin cambiar la integración ni mutar cuerpos en la previsión.
        int step=supplies!=null?1:ChunkEnd-Elapsed;double seconds=double(step)*3600.0/Hour;
        if(supplies!=null)
        {
            Result.Hydration=supplies.Thirst;Result.BreathingAirRatio=supplies.MaxAir>0?supplies.Air/supplies.MaxAir:1;
            Result.ShiveringHunger=supplies.Hunger;
            Result.ShiveringHungerPerMetSecond=supplies.HungerLoss*Hour/3600.0/supplies.Comfort(Sleeping);
        }
        CaelumThermalService.Integrate(Result,seconds,0,Effort,0,0,seconds);
        if(Abs(Result.Exposure)>Abs(WorstExposure))WorstExposure=Result.Exposure;
        if(Result.Severity>0){Failure=Result.Exposure<0?"CA_JOURNEY_COLD":"CA_JOURNEY_HEAT";return false;}
        if(supplies!=null)
        {
            supplies.Thirst=Result.Hydration;supplies.ThermalExposure=Result.Exposure;
            supplies.Hunger=Result.ShiveringHunger;supplies.ThermalToughness=Result.Toughness;
            if(supplies.FoodInventory!=null)supplies.FoodInventory.Advance(seconds,Result.AirC,Result.Humidity);
            if(supplies.Contamination!=null)
                supplies.Contamination.Advance(supplies.FoodIllness,CaelumContaminationRules.Environment(
                    CaelumContaminationData.NATURAL_REFERENCE,Result.AirC,Result.Humidity),seconds);
            supplies.Step(Sleeping);supplies.WalkTics+=int(!Sleeping || Mode==CaelumJourneyState.MODE_SHIP);
            supplies.SleepTics+=int(Sleeping);Result.Hydration=supplies.Thirst;Result.ShiveringHunger=supplies.Hunger;
        }
        Elapsed+=step;return true;
    }
    bool Forecast(CaelumPlayer user,int mode,int elapsedTics,double speedKmh,int destinationRegion=-1,CaelumJourneyModel supplies=null,int limitTics=0)
    {
        if(!Begin(user,mode,elapsedTics,speedKmh,destinationRegion,supplies,limitTics))return false;
        while(Elapsed<End && (supplies==null || supplies.Health>0))if(!Next(supplies))return false;
        return true;
    }
}
