// Previsión aislada: no muta equipo, recursos, reloj ni fracciones de daño.
class CaelumThermalJourney : Object play
{
    CaelumThermalState Result;
    String Failure;
    double WorstExposure;

    bool Forecast(CaelumPlayer user,int mode,int elapsedTics,double speedKmh)
    {
        Result=CaelumThermalService.CaptureForecast(user);Failure="";WorstExposure=0;
        let weather=CaelumWeatherState.Get(user);
        let clock=CaelumWorldClock.Get(user);
        let calendar=CaelumCalendarState.Get(user);
        int serial=calendar!=null ? calendar.DateSerial(clock) : -1;
        if(Result==null || weather==null || weather.Region<=0 || serial<0)
        {Failure="CA_JOURNEY_THERMAL_UNKNOWN";return false;}
        if(CaelumThermalRules.Severity(Result.Exposure,Result.Toughness)>0)
        {Failure=Result.Exposure<0 ? "CA_JOURNEY_COLD" : "CA_JOURNEY_HEAT";return false;}
        bool sheltered=mode==CaelumJourneyState.MODE_CART || mode==CaelumJourneyState.MODE_SHIP;
        int civil=calendar.CivilDayTics(clock);
        int hour=CaelumWorldClock.TicsPerHour(),day=CaelumWorldClock.TicsPerDay();
        let outside=new("CaelumWeatherSample");let local=new("CaelumWeatherSample");
        Result.Roof=sheltered;Result.WindSheltered=sheltered;Result.Available=true;
        for(int i=0;i<4;i++)Result.SubmergedCoverage[i]=0;
        int elapsed=0;
        while(elapsed<elapsedTics)
        {
            int phase=elapsed%(24*hour);
            bool sleeping=phase>=CaelumJourneyRules.WALK_HOURS*hour;
            int boundary=(sleeping ? 24*hour : CaelumJourneyRules.WALK_HOURS*hour)-phase;
            int step=Min(elapsedTics-elapsed,Min(boundary,hour/60));
            int timestamp=civil+elapsed;
            outside.EvaluateRegion(weather.Region,serial+timestamp/day,timestamp%day,weather.Seed);
            local.ApplyShelter(outside,sheltered ? CaelumWeatherRules.INDOOR : CaelumWeatherRules.OPEN,
                CaelumWeatherRules.PROFILE_TEMPERATE_TRIAL);
            double speed=!sheltered && !sleeping ? speedKmh/3.6 : 0;
            Result.AirC=local.AirTemperatureC;Result.ClimateC=local.AirTemperatureC;
            Result.Humidity=local.RelativeHumidityPercent;
            Result.RainMmHour=sheltered ? 0 : local.PrecipitationMmPerHour;
            Result.WindMps=Sqrt(local.WindSpeedKmh*local.WindSpeedKmh/12.96+speed*speed);
            Result.WaterC=local.GroundTemperatureC;
            double seconds=double(step)*3600.0/hour;
            double effort=CaelumThermalRules.LocomotionHeat(Result.MovedMassKg,speed,0,false,CaelumThermalMotion.Gravity(user));
            // Segundos lógicos de esfuerzo explícitos; dr permanece cero.
            CaelumThermalService.Integrate(Result,seconds,0,effort,0,0,seconds);
            if(Abs(Result.Exposure)>Abs(WorstExposure))WorstExposure=Result.Exposure;
            if(Result.Severity>0)
            {Failure=Result.Exposure<0 ? "CA_JOURNEY_COLD" : "CA_JOURNEY_HEAT";return false;}
            elapsed+=step;
        }
        return true;
    }
}
