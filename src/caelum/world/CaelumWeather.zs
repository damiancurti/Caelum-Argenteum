// Estado ambiental común. Los perfiles numéricos son de ensayo hasta definir
// el clima autoral de cada región; no representan datos meteorológicos reales.
class CaelumWeatherRules : Object
{
    const REVISION = 1;
    const PROFILE_NONE = 0;
    const PROFILE_LIMBO = 1;
    const PROFILE_SEWERS = 2;
    const PROFILE_RESERVOIR = 3;
    const PROFILE_MAINTENANCE = 4;
    const PROFILE_TEMPERATE_TRIAL = 5;

    static clearscope int ProfileForLocation(int location)
    {
        if (location == CaelumWorldCatalogue.LOCATION_MANSION) return PROFILE_LIMBO;
        if (location == CaelumWorldCatalogue.LOCATION_SEWERS
            || location == CaelumWorldCatalogue.LOCATION_TAROT_CHAMBERS) return PROFILE_SEWERS;
        if (location == CaelumWorldCatalogue.LOCATION_RESERVOIR) return PROFILE_RESERVOIR;
        if (location == CaelumWorldCatalogue.LOCATION_MAINTENANCE) return PROFILE_MAINTENANCE;
        return PROFILE_NONE;
    }

    static clearscope bool IsProfile(int profile)
    { return profile >= PROFILE_LIMBO && profile <= PROFILE_TEMPERATE_TRIAL; }

    static clearscope String ProfileKey(int profile)
    {
        if (profile == PROFILE_LIMBO) return "CA_WEATHER_LIMBO";
        if (profile == PROFILE_SEWERS) return "CA_WEATHER_SEWERS";
        if (profile == PROFILE_RESERVOIR) return "CA_WEATHER_RESERVOIR";
        if (profile == PROFILE_MAINTENANCE) return "CA_WEATHER_MAINTENANCE";
        if (profile == PROFILE_TEMPERATE_TRIAL) return "CA_WEATHER_TEMPERATE";
        return "CA_WEATHER_UNAVAILABLE";
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

// Muestra serializable y sin efectos sobre el jugador. El resolvedor también
// sirve a consultas diagnósticas, sin modificar la muestra de campaña.
class CaelumWeatherSample : Object
{
    bool Available;
    double AirTemperatureC;
    double RelativeHumidityPercent;
    double WindSpeedKmh;
    double WindFromDegrees;
    double PrecipitationMmPerHour;

    void Evaluate(int profile, int serial, int civilTics, int seed)
    {
        Available = false;
        AirTemperatureC = 0; RelativeHumidityPercent = 0;
        WindSpeedKmh = 0; WindFromDegrees = 0; PrecipitationMmPerHour = 0;
        if (!CaelumWeatherRules.IsProfile(profile) || serial < 0
            || serial > CaelumCalendarRules.MAX_SERIAL || civilTics < 0
            || civilTics >= CaelumWorldClock.TicsPerDay() || seed < 1 || seed > 32748) return;
        Available = true;
        if (profile == CaelumWeatherRules.PROFILE_LIMBO)
        {
            // La mansión no hereda estaciones terrestres por tener un reloj.
            AirTemperatureC = 20; RelativeHumidityPercent = 55;
            return;
        }

        double hour = double(civilTics) / CaelumWorldClock.TicsPerHour();
        int year = CaelumCalendarRules.YearForSerial(serial);
        int yearStart = CaelumCalendarRules.ToSerial(year, 1, 1);
        int yearDays = CaelumCalendarRules.IsLeapYear(year) ? 366 : 365;
        double annual = Cos(360.0 * (serial-yearStart + hour/24.0 - 14.0) / yearDays);
        double daily = Cos(360.0 * (hour-15.0) / 24.0);
        int slot = serial * 4 + int(hour / 6.0);
        double blend = (hour % 6.0) / 6.0;
        blend = blend * blend * (3.0-2.0*blend);
        double front = CaelumWeatherRules.Noise(slot,seed,1) * (1-blend)
            + CaelumWeatherRules.Noise(slot+1,seed,1) * blend;
        double moisture = CaelumWeatherRules.Noise(slot,seed,2) * (1-blend)
            + CaelumWeatherRules.Noise(slot+1,seed,2) * blend;

        if (profile != CaelumWeatherRules.PROFILE_TEMPERATE_TRIAL)
        {
            double baseTemperature = profile == CaelumWeatherRules.PROFILE_MAINTENANCE ? 18
                : profile == CaelumWeatherRules.PROFILE_RESERVOIR ? 15 : 16;
            double baseHumidity = profile == CaelumWeatherRules.PROFILE_MAINTENANCE ? 75
                : profile == CaelumWeatherRules.PROFILE_RESERVOIR ? 92 : 85;
            AirTemperatureC = baseTemperature + annual * 2 + daily * 0.25 + (front-0.5)*0.5;
            RelativeHumidityPercent = Clamp(baseHumidity + (moisture-0.5)*4, 0.0, 100.0);
            // Perfiles subterráneos: humedad ambiental sin lluvia ni viento.
            return;
        }

        // Perfil exterior exclusivo de ensayo: interpolación de frentes cada
        // seis horas, con ciclo diario/anual. No se asigna a mapas desconocidos.
        double rainA = Max(0.0, (CaelumWeatherRules.Noise(slot,seed,3)-0.65)/0.35)*8;
        double rainB = Max(0.0, (CaelumWeatherRules.Noise(slot+1,seed,3)-0.65)/0.35)*8;
        PrecipitationMmPerHour = rainA*(1-blend) + rainB*blend;
        AirTemperatureC = 17 + annual*9 + daily*4 + (front-0.5)*6
            - PrecipitationMmPerHour*0.25;
        RelativeHumidityPercent = Clamp(45 + moisture*25 + PrecipitationMmPerHour*4, 0.0, 100.0);
        double angleA = CaelumWeatherRules.Noise(slot,seed,4)*360;
        double angleB = CaelumWeatherRules.Noise(slot+1,seed,4)*360;
        double speedA = CaelumWeatherRules.Noise(slot,seed,5)*24;
        double speedB = CaelumWeatherRules.Noise(slot+1,seed,5)*24;
        vector2 wind = (Sin(angleA)*speedA, Cos(angleA)*speedA)*(1-blend)
            + (Sin(angleB)*speedB, Cos(angleB)*speedB)*blend;
        WindSpeedKmh = wind.Length();
        WindFromDegrees = (VectorAngle(wind.Y,wind.X)+360.0) % 360.0;
    }
}

class CaelumWeatherState : Inventory
{
    int Revision;
    int Seed;
    int LocationId;
    int Profile;
    String SourceMap;
    int SampleDate;
    int SampleMinute;
    CaelumWeatherSample Current;

    static CaelumWeatherState Get(CaelumPlayer user, bool create = false)
    {
        if (user == null) return null;
        let weather = CaelumWeatherState(user.FindInventory("CaelumWeatherState"));
        if (weather == null && create)
            weather = CaelumWeatherState(user.GiveInventoryType("CaelumWeatherState"));
        return weather;
    }

    static void Sync(CaelumPlayer user, CaelumWorldClock clock, CaelumCalendarState calendar)
    {
        if (user == null || clock == null || calendar == null) return;
        let weather = Get(user, true);
        if (weather == null) return;
        if (weather.Seed == 0) weather.Seed = Random[CaelumWeatherSeed](1,32748);
        // Siempre campaña: una vista de fecha de prueba no altera el mundo.
        int serial = calendar.DateSerial(clock);
        int civilTics = calendar.CivilDayTics(clock);
        int minute = civilTics < 0 ? -1 : civilTics / (CaelumWorldClock.TicsPerHour()/60);
        int location = CaelumWorldCatalogue.LocationForMap(level.MapName);
        int profile = CaelumWeatherRules.ProfileForLocation(location);
        if (weather.Current != null && weather.Revision == CaelumWeatherRules.REVISION
            && weather.SourceMap == level.MapName && weather.Profile == profile
            && weather.SampleDate == serial && weather.SampleMinute == minute) return;
        if (weather.Current == null) weather.Current = new("CaelumWeatherSample");
        weather.SourceMap = level.MapName; weather.LocationId = location;
        weather.Profile = profile; weather.SampleDate = serial; weather.SampleMinute = minute;
        weather.Current.Evaluate(profile, serial, minute * (CaelumWorldClock.TicsPerHour()/60), weather.Seed);
        weather.Revision = CaelumWeatherRules.REVISION;
    }

    static void PrintSample(CaelumWeatherSample sample)
    {
        if (sample == null || !sample.Available)
        { Console.Printf("Clima local no definido para esta ubicación/fecha."); return; }
        Console.Printf("Temperatura=%.4f C humedad=%.4f%% viento=%.4f km/h desde %.2f grados precipitación=%.4f mm/h",
            sample.AirTemperatureC, sample.RelativeHumidityPercent, sample.WindSpeedKmh,
            sample.WindFromDegrees, sample.PrecipitationMmPerHour);
    }

    static void Report(CaelumPlayer user)
    {
        let weather = Get(user);
        Console.Printf("[Caelum 4.35.0k] Clima local: registro=%d mapa=%s", weather != null, level.MapName);
        if (weather == null) return;
        Console.Printf("Perfil=%d semilla=%d revisión=%d fecha serial=%d minuto=%d origen=%s",
            weather.Profile, weather.Seed, weather.Revision, weather.SampleDate, weather.SampleMinute, weather.SourceMap);
        PrintSample(weather.Current);
    }

    // Consulta optativa y sin escrituras: perfil, desplazamiento de días y hora.
    // Permite comprobar lluvia/viento exterior sin convertir las alcantarillas
    // en exteriores ni modificar reloj, necesidades, campaña o estado actual.
    static void DebugSample(CaelumPlayer user, int profile, int dayOffset, int hour)
    {
        let weather = Get(user);
        let clock = CaelumWorldClock.Get(user);
        let calendar = CaelumCalendarState.Get(user);
        int serial = calendar == null ? -1 : calendar.DateSerial(clock);
        if (weather == null || serial < 0 || !CaelumWeatherRules.IsProfile(profile)
            || hour < 0 || hour > 23 || dayOffset < -serial
            || dayOffset > CaelumCalendarRules.MAX_SERIAL-serial)
        { Console.Printf("Uso: netevent ca_debug_weather_sample PERFIL(1..5) DIAS_RELATIVOS HORA(0..23). Requiere campaña iniciada."); return; }
        serial += dayOffset;
        let sample = new("CaelumWeatherSample");
        sample.Evaluate(profile, serial, hour*CaelumWorldClock.TicsPerHour(), weather.Seed);
        Console.Printf("[Caelum 4.35.0k] Consulta climática de prueba: perfil=%d %02d/%02d/%04d %02d:00; sin cambiar campaña.",
            profile, CaelumCalendarRules.DayForSerial(serial), CaelumCalendarRules.MonthForSerial(serial),
            CaelumCalendarRules.YearForSerial(serial), hour);
        PrintSample(sample);
    }

    Default
    {
        Inventory.Amount 1; Inventory.MaxAmount 1; Inventory.InterHubAmount 1;
        +INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE +INVENTORY.KEEPDEPLETED -INVENTORY.INVBAR
    }
    States { Spawn: TNT1 A -1; Stop; }
}
