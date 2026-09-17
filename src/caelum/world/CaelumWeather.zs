// Ambiente regional basado en normales SMN recientes; microclima aproximado.
// Datos observados y supuestos de simulación se distinguen en SYSTEMS.md.
class CaelumWeatherRules : Object
{
    const REVISION=2;
    const PROFILE_NONE=0;
    const PROFILE_LIMBO=1;
    const PROFILE_SEWERS=2;
    const PROFILE_RESERVOIR=3;
    const PROFILE_MAINTENANCE=4;
    const PROFILE_TEMPERATE_TRIAL=5;
    const OPEN=0;
    const CANOPY=1;
    const INDOOR=2;
    const UNDERGROUND=3;
    const LIMBO=4;

    static clearscope int ProfileForLocation(int location)
    {
        if(location==1)return PROFILE_LIMBO;
        if(location==2 || location==4)return PROFILE_SEWERS;
        if(location==3)return PROFILE_RESERVOIR;
        if(location==5)return PROFILE_MAINTENANCE;
        if(location==CaelumWorldCatalogue.LOCATION_PORT || location==CaelumWorldCatalogue.LOCATION_COAST)
            return PROFILE_TEMPERATE_TRIAL;
        return PROFILE_NONE;
    }
    static clearscope bool IsProfile(int profile) { return profile>=1 && profile<=5; }
    static clearscope String ProfileKey(int profile)
    {
        if(profile==1)return "CA_WEATHER_LIMBO";
        if(profile==2)return "CA_WEATHER_SEWERS";
        if(profile==3)return "CA_WEATHER_RESERVOIR";
        if(profile==4)return "CA_WEATHER_MAINTENANCE";
        return "CA_WEATHER_TEMPERATE";
    }
    static clearscope String RegionKey(int region)
    { return CaelumClimateNormals.Valid(region)?String.Format("CA_CLIMATE_REGION_%d",region):"CA_WEATHER_LIMBO"; }
    static clearscope String ShelterKey(int shelter)
    {
        if(shelter==CANOPY)return "CA_CLIMATE_CANOPY";
        if(shelter==INDOOR)return "CA_CLIMATE_INDOOR";
        if(shelter==UNDERGROUND)return "CA_WEATHER_SEWERS";
        if(shelter==LIMBO)return "CA_WEATHER_LIMBO";
        return "CA_CLIMATE_OPEN";
    }
    static clearscope double Mix(double a,double b,double fraction) { return a+(b-a)*fraction; }
    // NWS: presión de saturación (hPa), temperatura en Celsius.
    static clearscope double Saturation(double temperature)
    { return 6.11*10.0 ** (7.5*temperature/(237.3+temperature)); }
    static clearscope double Smooth(double fraction)
    { return fraction*fraction*(3-2*fraction); }
    static clearscope double Normal(int region,int serial,double hour,int metric)
    {
        int year=CaelumCalendarRules.YearForSerial(serial);
        int month=CaelumCalendarRules.MonthForSerial(serial);
        int days=CaelumCalendarRules.DaysInMonth(year,month);
        double day=CaelumCalendarRules.DayForSerial(serial)-1+hour/24.0;
        int other;double blend;
        if(day<days/2.0)
        {
            other=month==1?12:month-1;
            int length=CaelumCalendarRules.DaysInMonth(month==1?Max(1,year-1):year,other);
            blend=(length/2.0+day)/(length/2.0+days/2.0);
            return CaelumWeatherRules.Mix(CaelumClimateNormals.Value(region,other,metric),CaelumClimateNormals.Value(region,month,metric),blend);
        }
        other=month==12?1:month+1;
        int length=CaelumCalendarRules.DaysInMonth(month==12?Min(9999,year+1):year,other);
        blend=(day-days/2.0)/(days/2.0+length/2.0);
        return CaelumWeatherRules.Mix(CaelumClimateNormals.Value(region,month,metric),CaelumClimateNormals.Value(region,other,metric),blend);
    }
    // Ruido reproducible por fecha/semilla/canal, sin consumir RNG de combate
    // ni repetir pasos para reconstruir las horas pasadas en mapas descargados.
    static clearscope double Noise(int slot, int seed, int channel)
    {
        int value = (slot % 65521 + seed + channel * 983) % 65521;
        value = (value * 251 + 13849) % 65521;
        int folded = value % 32749;
        value = (folded * folded + value * 73 + 109) % 65521;
        return value / 65520.0;
    }

    static clearscope String WindKey(double fromDegrees)
    {
        int direction = int((fromDegrees + 22.5) / 45.0) % 8;
        if (direction == 0) return "CA_WEATHER_N";
        if (direction == 1) return "CA_WEATHER_NE";
        if (direction == 2) return "CA_WEATHER_E";
        if (direction == 3) return "CA_WEATHER_SE";
        if (direction == 4) return "CA_WEATHER_S";
        if (direction == 5) return "CA_WEATHER_SW";
        if (direction == 6) return "CA_WEATHER_W";
        return "CA_WEATHER_NW";
    }
}


// Marcador optativo por mapa: región 1..9, hábitat 0=superficie, 2..4=subsuelo.
// Un mapa sin catálogo ni marcador sigue explícitamente sin perfil.
class CaelumClimateRegion : Actor
{
    Default { Radius 0; Height 0; +NOGRAVITY +NOBLOCKMAP +NOINTERACTION }
    States { Spawn: TNT1 A -1; Stop; }
}

class CaelumWeatherShelter : Object play
{
    static int Resolve(CaelumPlayer user,int profile)
    {
        if(profile==CaelumWeatherRules.PROFILE_LIMBO)return CaelumWeatherRules.LIMBO;
        FLineTraceData hit;
        double z=user.Pos.Z+Min(48.0,user.Height*0.75);
        // Traza geométrica: ignora actores, respeta techos, pendientes y pisos 3D.
        bool roof=user.LineTrace(0,65536,-90,TRF_THRUACTORS|TRF_ABSPOSITION|TRF_NOSKY,z,user.Pos.X,user.Pos.Y,hit);
        if(!roof || hit.HitType==FLineTraceData.TRACE_HasHitSky)return CaelumWeatherRules.OPEN;
        if(profile>=2 && profile<=4)return CaelumWeatherRules.UNDERGROUND;
        int walls=0;
        for(int i=0;i<4;i++)
            if(user.LineTrace(i*90,1024,0,TRF_THRUACTORS|TRF_ABSPOSITION|TRF_NOSKY,z,user.Pos.X,user.Pos.Y,hit))walls++;
        return walls>=3?CaelumWeatherRules.INDOOR:CaelumWeatherRules.CANOPY;
    }
}

class CaelumWeatherSample : Object
{
    bool Available;
    double AirTemperatureC,RelativeHumidityPercent,WindSpeedKmh,WindFromDegrees,PrecipitationMmPerHour;
    double NormalMeanC,AnnualMeanC,GroundTemperatureC,CloudFraction;

    void Clear()
    {
        Available=false;AirTemperatureC=0;RelativeHumidityPercent=0;WindSpeedKmh=0;
        WindFromDegrees=0;PrecipitationMmPerHour=0;NormalMeanC=0;AnnualMeanC=0;GroundTemperatureC=0;CloudFraction=0;
    }
    void EvaluateRegion(int region,int serial,int civilTics,int seed)
    {
        Clear();
        if(!CaelumClimateNormals.Valid(region) || serial<0 || serial>CaelumCalendarRules.MAX_SERIAL
            || civilTics<0 || civilTics>=CaelumWorldClock.TicsPerDay() || seed<1 || seed>32748)return;
        Available=true;
        double hour=double(civilTics)/CaelumWorldClock.TicsPerHour();
        int regionalSeed=(seed+region*1877)%32748+1;
        int year=CaelumCalendarRules.YearForSerial(serial);
        int month=CaelumCalendarRules.MonthForSerial(serial);
        int days=CaelumCalendarRules.DaysInMonth(year,month);
        int dayOfYear=serial-CaelumCalendarRules.DaysBeforeYear(year);
        NormalMeanC=CaelumWeatherRules.Normal(region,serial,hour,0);
        AnnualMeanC=CaelumClimateNormals.AnnualMeanFor(region);
        double tmax=CaelumWeatherRules.Normal(region,serial,hour,1);
        double tmin=CaelumWeatherRules.Normal(region,serial,hour,2);
        double rh=CaelumWeatherRules.Normal(region,serial,hour,3);
        double rainTotal=CaelumWeatherRules.Normal(region,serial,12,4);
        double rainDays=CaelumWeatherRules.Normal(region,serial,12,5);
        double normalCloud=CaelumWeatherRules.Normal(region,serial,hour,6)/8.0;
        double normalWind=CaelumWeatherRules.Normal(region,serial,hour,7);
        int slot=serial*4+int(hour/6.0);
        double blend=CaelumWeatherRules.Smooth((hour%6.0)/6.0);
        double front=CaelumWeatherRules.Mix(CaelumWeatherRules.Noise(slot,regionalSeed,1),CaelumWeatherRules.Noise(slot+1,regionalSeed,1),blend);
        double moisture=CaelumWeatherRules.Mix(CaelumWeatherRules.Noise(slot,regionalSeed,2),CaelumWeatherRules.Noise(slot+1,regionalSeed,2),blend);

        // Un episodio suave por día húmedo; volumen esperado ligado a mm/mes.
        // Siempre vuelve a cero antes de medianoche: sin discontinuidad diaria.
        double wet=0;
        if(rainDays>0 && rainTotal>0 && CaelumWeatherRules.Noise(serial,regionalSeed,3)<rainDays/days)
        {
            double duration=6+6*CaelumWeatherRules.Noise(serial,regionalSeed,6);
            double center=6+12*CaelumWeatherRules.Noise(serial,regionalSeed,7);
            double phase=(hour-center)/(duration/2);
            if(Abs(phase)<1)wet=(1+Cos(180*phase))/2;
            PrecipitationMmPerHour=wet*2*rainTotal/rainDays/duration
                *(0.5+CaelumWeatherRules.Noise(serial,regionalSeed,8));
        }
        CloudFraction=Clamp(normalCloud+(moisture-0.5)*0.5,0,1);
        CloudFraction=CaelumWeatherRules.Mix(CloudFraction,1.0,wet);
        // Aproximación solar por latitud/longitud; reloj civil argentino UTC-3.
        double declination=23.44*Sin(360.0*(dayOfYear+hour/24.0-80)/(CaelumCalendarRules.IsLeapYear(year)?366:365));
        double latitude=CaelumClimateNormals.LatitudeFor(region);
        double halfDay=ACos(Clamp(-Tan(latitude)*Tan(declination),-1.0,1.0))/15.0;
        double noon=12-(CaelumClimateNormals.LongitudeFor(region)+45)/15.0;
        double dawn=noon-halfDay;double peak=noon+3;
        double elapsed=(hour-dawn+24)%24;
        double warming=peak-dawn;
        double cycle=elapsed<=warming?-Cos(180*elapsed/warming):Cos(180*(elapsed-warming)/(24-warming));
        double daily=cycle*(cycle>=0?tmax-NormalMeanC:NormalMeanC-tmin);
        double anomaly=(front-0.5)*12;
        AirTemperatureC=NormalMeanC+daily*(1-0.35*(CloudFraction-normalCloud))+anomaly-2.5*wet;
        double vapor=CaelumWeatherRules.Saturation(NormalMeanC+anomaly*0.5)*rh/100*(0.9+0.2*moisture);
        RelativeHumidityPercent=Clamp(vapor/CaelumWeatherRules.Saturation(AirTemperatureC)*100,0,100);
        RelativeHumidityPercent=CaelumWeatherRules.Mix(RelativeHumidityPercent,Max(95.0,RelativeHumidityPercent),wet);
        int previous=Max(0,serial-30);
        GroundTemperatureC=AnnualMeanC+0.15*(CaelumWeatherRules.Normal(region,previous,hour,0)-AnnualMeanC)
            +0.05*(AirTemperatureC-NormalMeanC);
        // Dirección y frentes sintéticos; la rapidez se ancla al dato mensual.
        double directionA=CaelumWeatherRules.Noise(slot,regionalSeed,4)*360;
        double directionB=CaelumWeatherRules.Noise(slot+1,regionalSeed,4)*360;
        if(region==6 || region==7 || region==9)
        { directionA=230+directionA/4;directionB=230+directionB/4; }
        double speedA=normalWind*(0.25+1.5*CaelumWeatherRules.Noise(slot,regionalSeed,5));
        double speedB=normalWind*(0.25+1.5*CaelumWeatherRules.Noise(slot+1,regionalSeed,5));
        vector2 wind=(CaelumWeatherRules.Mix(Sin(directionA)*speedA,Sin(directionB)*speedB,blend),CaelumWeatherRules.Mix(Cos(directionA)*speedA,Cos(directionB)*speedB,blend));
        WindSpeedKmh=wind.Length()*(1+0.5*wet);
        WindFromDegrees=WindSpeedKmh<0.000001?0:(VectorAngle(wind.Y,wind.X)+360)%360;
    }
    void ApplyShelter(CaelumWeatherSample outside,int shelter,int profile)
    {
        Clear();if(outside==null || !outside.Available)return;
        Available=true;NormalMeanC=outside.NormalMeanC;AnnualMeanC=outside.AnnualMeanC;
        GroundTemperatureC=outside.GroundTemperatureC;CloudFraction=outside.CloudFraction;
        AirTemperatureC=outside.AirTemperatureC;WindSpeedKmh=outside.WindSpeedKmh;
        WindFromDegrees=outside.WindFromDegrees;PrecipitationMmPerHour=outside.PrecipitationMmPerHour;
        double vapor=CaelumWeatherRules.Saturation(AirTemperatureC)*outside.RelativeHumidityPercent/100;
        if(shelter==CaelumWeatherRules.LIMBO)
        { AirTemperatureC=20;RelativeHumidityPercent=55;WindSpeedKmh=0;WindFromDegrees=0;PrecipitationMmPerHour=0;return; }
        if(shelter==CaelumWeatherRules.CANOPY)
        { AirTemperatureC=NormalMeanC+(AirTemperatureC-NormalMeanC)*0.95;WindSpeedKmh*=0.65; }
        if(shelter==CaelumWeatherRules.INDOOR)
        { AirTemperatureC=NormalMeanC+(AirTemperatureC-NormalMeanC)*0.45;WindSpeedKmh*=0.1; }
        if(shelter==CaelumWeatherRules.UNDERGROUND)
        { AirTemperatureC=GroundTemperatureC;WindSpeedKmh=0;WindFromDegrees=0; }
        RelativeHumidityPercent=Clamp(vapor/CaelumWeatherRules.Saturation(AirTemperatureC)*100,0,100);
        if(shelter==CaelumWeatherRules.UNDERGROUND)
        {
            double dampness=profile==3?0.85:profile==2?0.65:0.25;
            RelativeHumidityPercent=CaelumWeatherRules.Mix(RelativeHumidityPercent,Max(95.0,RelativeHumidityPercent),dampness);
        }
        if(shelter!=CaelumWeatherRules.OPEN)PrecipitationMmPerHour=0;
    }
    // Compatibilidad de diagnósticos 0k; perfiles 2..5 usan referencia Pampa.
    void Evaluate(int profile,int serial,int civilTics,int seed)
    {
        if(!CaelumWeatherRules.IsProfile(profile)){Clear();return;}
        let outside=new("CaelumWeatherSample");outside.EvaluateRegion(1,serial,civilTics,seed);
        ApplyShelter(outside,profile==1?4:profile==5?0:3,profile);
    }
}

class CaelumWeatherState : Inventory
{
    int Revision,Seed,LocationId,Profile,SampleDate,SampleMinute;
    int Region,Shelter,GeometryCheckedTic;
    vector3 SamplePosition;
    CaelumClimateRegion RegionMarker;
    int MarkerCheckedTic;
    String SourceMap;
    CaelumWeatherSample Current,Outside;
    static CaelumWeatherState Get(CaelumPlayer user,bool create=false)
    {
        if(user==null)return null;
        let weather=CaelumWeatherState(user.FindInventory("CaelumWeatherState"));
        if(weather==null && create)weather=CaelumWeatherState(user.GiveInventoryType("CaelumWeatherState"));
        return weather;
    }
    static void Sync(CaelumPlayer user,CaelumWorldClock clock,CaelumCalendarState calendar)
    {
        if(user==null || clock==null || calendar==null)return;
        let weather=Get(user,true);if(weather==null)return;
        if(weather.Seed==0)weather.Seed=Random[CaelumWeatherSeed](1,32748);
        int serial=calendar.DateSerial(clock);int civilTics=calendar.CivilDayTics(clock);
        int minute=civilTics<0?-1:civilTics/(CaelumWorldClock.TicsPerHour()/60);
        int location=CaelumWorldCatalogue.LocationForMap(level.MapName);
        int profile=CaelumWeatherRules.ProfileForLocation(location);
        int region=profile>1?1:0;
        // Limbo conserva su excepción; los otros mapas admiten asignación explícita.
        if(profile!=1)
        {
            if(weather.Revision!=CaelumWeatherRules.REVISION || weather.SourceMap!=level.MapName
                || level.maptime-weather.MarkerCheckedTic>=TICRATE || weather.MarkerCheckedTic>level.maptime)
            {
                let it=ThinkerIterator.Create("CaelumClimateRegion");
                weather.RegionMarker=CaelumClimateRegion(it.Next());weather.MarkerCheckedTic=level.maptime;
            }
            let marker=weather.RegionMarker;
            if(marker!=null)
            {
                region=marker.args[0];profile=marker.args[1]>=2 && marker.args[1]<=4?marker.args[1]:5;
                if(!CaelumClimateNormals.Valid(region)){region=0;profile=0;}
            }
        }
        bool changed=weather.Revision!=CaelumWeatherRules.REVISION || weather.SourceMap!=level.MapName
            || weather.Profile!=profile || weather.Region!=region || weather.Outside==null || weather.Current==null;
        bool sampleChanged=changed || weather.SampleDate!=serial || weather.SampleMinute!=minute;
        bool positionChanged=changed || weather.SamplePosition!=user.Pos
            || level.maptime-weather.GeometryCheckedTic>=TICRATE || weather.GeometryCheckedTic>level.maptime;
        if(!sampleChanged && !positionChanged)return;
        if(weather.Current==null)weather.Current=new("CaelumWeatherSample");
        if(weather.Outside==null)weather.Outside=new("CaelumWeatherSample");
        if(sampleChanged)
        {
            if(profile==1)weather.Outside.Evaluate(1,serial,minute*105,weather.Seed);
            else weather.Outside.EvaluateRegion(region,serial,minute*105,weather.Seed);
        }
        if(positionChanged)
        {
            weather.Shelter=CaelumWeatherShelter.Resolve(user,profile);
            weather.SamplePosition=user.Pos;weather.GeometryCheckedTic=level.maptime;
        }
        weather.Current.ApplyShelter(weather.Outside,weather.Shelter,profile);
        weather.SourceMap=level.MapName;weather.LocationId=location;weather.Profile=profile;weather.Region=region;
        weather.SampleDate=serial;weather.SampleMinute=minute;weather.Revision=CaelumWeatherRules.REVISION;
    }
    static void PrintSample(CaelumWeatherSample sample)
    {
        if(sample==null || !sample.Available){Console.Printf("Clima local no definido para esta ubicación/fecha.");return;}
        Console.Printf("Temperatura=%.4f C humedad=%.4f%% viento=%.4f km/h desde %.2f grados precipitación=%.4f mm/h",
            sample.AirTemperatureC,sample.RelativeHumidityPercent,sample.WindSpeedKmh,sample.WindFromDegrees,sample.PrecipitationMmPerHour);
    }
    static void Report(CaelumPlayer user)
    {
        let w=Get(user);Console.Printf("[Caelum 4.35.0m] Clima local: registro=%d mapa=%s",w!=null,level.MapName);if(w==null)return;
        Console.Printf("Perfil=%d región=%d cobertura=%d semilla=%d revisión=%d fecha=%d minuto=%d",w.Profile,w.Region,w.Shelter,w.Seed,w.Revision,w.SampleDate,w.SampleMinute);
        Console.Printf("Ambiente local:");PrintSample(w.Current);Console.Printf("Referencia regional exterior:");PrintSample(w.Outside);
    }
    static void DebugSample(CaelumPlayer user,int id,int dayOffset,int hour,bool regional=false)
    {
        let w=Get(user);let clock=CaelumWorldClock.Get(user);let calendar=CaelumCalendarState.Get(user);
        int serial=calendar==null?-1:calendar.DateSerial(clock);
        if(w==null || serial<0 || (regional?!CaelumClimateNormals.Valid(id):!CaelumWeatherRules.IsProfile(id))
            || hour<0 || hour>23 || dayOffset< -serial || dayOffset>CaelumCalendarRules.MAX_SERIAL-serial)
        {Console.Printf("Uso: ca_debug_weather_sample PERFIL(1..5) DIAS HORA, o ca_debug_climate_sample REGION(1..9) DIAS HORA(0..23), mediante netevent.");return;}
        serial+=dayOffset;let sample=new("CaelumWeatherSample");
        if(regional)sample.EvaluateRegion(id,serial,hour*CaelumWorldClock.TicsPerHour(),w.Seed);
        else sample.Evaluate(id,serial,hour*CaelumWorldClock.TicsPerHour(),w.Seed);
        Console.Printf("[Caelum 4.35.0m] Consulta %s=%d %02d/%02d/%04d %02d:00; sin cambiar campaña.",regional?"región":"perfil",id,
            CaelumCalendarRules.DayForSerial(serial),CaelumCalendarRules.MonthForSerial(serial),CaelumCalendarRules.YearForSerial(serial),hour);
        PrintSample(sample);
        if(regional)for(int shelter=1;shelter<=3;shelter++)
        {let local=new("CaelumWeatherSample");local.ApplyShelter(sample,shelter,2);Console.Printf("Cobertura %d:",shelter);PrintSample(local);}
    }
    Default
    {
        Inventory.Amount 1;Inventory.MaxAmount 1;Inventory.InterHubAmount 1;
        +INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE +INVENTORY.KEEPDEPLETED -INVENTORY.INVBAR
    }
    States { Spawn:TNT1 A -1;Stop; }
}
