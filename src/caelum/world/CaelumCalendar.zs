// Calendario civil derivado del reloj único. Inicio autoral de campaña:
// 3 de noviembre de 1889, 09:00. La depuración usa un anclaje separado.
class CaelumCalendarRules : Object
{
    const MAX_YEAR = 9999;
    const MAX_SERIAL = 3652058; // 31/12/9999; 01/01/0001 corresponde a cero.
    const CAMPAIGN_START_YEAR = 1889;
    const CAMPAIGN_START_MONTH = 11;
    const CAMPAIGN_START_DAY = 3;
    const CAMPAIGN_START_HOUR = 9;
    const SEASON_SUMMER = 0;
    const SEASON_AUTUMN = 1;
    const SEASON_WINTER = 2;
    const SEASON_SPRING = 3;

    static clearscope bool IsLeapYear(int year)
    {
        if (year < 1 || year > MAX_YEAR) return false;
        return year % 4 == 0 && (year % 100 != 0 || year % 400 == 0);
    }

    static clearscope int DaysInMonth(int year, int month)
    {
        if (year < 1 || year > MAX_YEAR || month < 1 || month > 12) return 0;
        if (month == 2) return IsLeapYear(year) ? 29 : 28;
        if (month == 4 || month == 6 || month == 9 || month == 11) return 30;
        return 31;
    }

    static clearscope int DaysBeforeYear(int year)
    {
        int previous = year - 1;
        return previous * 365 + previous / 4 - previous / 100 + previous / 400;
    }

    static clearscope int ToSerial(int year, int month, int day)
    {
        int length = DaysInMonth(year, month);
        if (length == 0 || day < 1 || day > length) return -1;
        int serial = DaysBeforeYear(year) + day - 1;
        for (int m = 1; m < month; m++) serial += DaysInMonth(year, m);
        return serial;
    }

    static clearscope int YearForSerial(int serial)
    {
        if (serial < 0 || serial > MAX_SERIAL) return 0;
        // Búsqueda acotada: no recorre todos los años de un guardado largo.
        int low = 1;
        int high = MAX_YEAR;
        while (low < high)
        {
            int middle = (low + high + 1) / 2;
            if (DaysBeforeYear(middle) <= serial) low = middle;
            else high = middle - 1;
        }
        return low;
    }

    static clearscope int MonthForSerial(int serial)
    {
        int year = YearForSerial(serial);
        if (year == 0) return 0;
        int remaining = serial - DaysBeforeYear(year);
        int month = 1;
        while (remaining >= DaysInMonth(year, month))
        {
            remaining -= DaysInMonth(year, month);
            month++;
        }
        return month;
    }

    static clearscope int DayForSerial(int serial)
    {
        int year = YearForSerial(serial);
        if (year == 0) return 0;
        int remaining = serial - DaysBeforeYear(year);
        int month = 1;
        while (remaining >= DaysInMonth(year, month))
        {
            remaining -= DaysInMonth(year, month);
            month++;
        }
        return remaining + 1;
    }

    static clearscope int SouthernSeasonForMonth(int month)
    {
        // Convención mensual de prueba: no calcula equinoccios ni el clima.
        if (month < 1 || month > 12) return -1;
        if (month == 12 || month <= 2) return SEASON_SUMMER;
        if (month <= 5) return SEASON_AUTUMN;
        if (month <= 8) return SEASON_WINTER;
        return SEASON_SPRING;
    }

    static clearscope String SeasonKey(int season)
    {
        if (season == SEASON_SUMMER) return "CA_CALENDAR_SUMMER";
        if (season == SEASON_AUTUMN) return "CA_CALENDAR_AUTUMN";
        if (season == SEASON_WINTER) return "CA_CALENDAR_WINTER";
        if (season == SEASON_SPRING) return "CA_CALENDAR_SPRING";
        return "CA_CALENDAR_UNSET";
    }
}

class CaelumCalendarState : Inventory
{
    bool Configured;
    bool TrialDate;
    int AnchorSerial;
    int AnchorClockDays;
    int AnchorClockTics;
    int AnchorCivilTics;
    // Cero identifica los calendarios de 0b, que sólo tenían fecha de prueba.
    int CampaignRevision;
    int TrialAnchorSerial;
    int TrialAnchorClockDays;
    int TrialAnchorClockTics;
    int TrialAnchorCivilTics;

    static CaelumCalendarState Get(CaelumPlayer user, bool create = false)
    {
        if (user == null) return null;
        let calendar = CaelumCalendarState(user.FindInventory("CaelumCalendarState"));
        if (calendar == null && create)
            calendar = CaelumCalendarState(user.GiveInventoryType("CaelumCalendarState"));
        return calendar;
    }

    clearscope bool HasValidAnchor(CaelumWorldClock clock, bool trial = false)
    {
        int length = CaelumWorldClock.TicsPerDay();
        int serial = trial ? TrialAnchorSerial : AnchorSerial;
        int days = trial ? TrialAnchorClockDays : AnchorClockDays;
        int tics = trial ? TrialAnchorClockTics : AnchorClockTics;
        int civilTics = trial ? TrialAnchorCivilTics : AnchorCivilTics;
        return Configured && (!trial || TrialDate) && clock != null && serial >= 0
            && serial <= CaelumCalendarRules.MAX_SERIAL
            && days >= 0 && clock.CompletedDays >= days
            && tics >= 0 && tics < length
            && civilTics >= 0 && civilTics < length
            && clock.DayTics >= 0 && clock.DayTics < length
            && (clock.CompletedDays > days || clock.DayTics >= tics);
    }

    // Las consultas normales siempre devuelven la fecha de campaña.
    // Sólo la presentación diagnóstica pide explícitamente trial=true.
    clearscope int DateSerial(CaelumWorldClock clock, bool trial = false)
    {
        if (!HasValidAnchor(clock, trial)) return -1;
        int serial = trial ? TrialAnchorSerial : AnchorSerial;
        int days = clock.CompletedDays - (trial ? TrialAnchorClockDays : AnchorClockDays);
        int tics = clock.DayTics - (trial ? TrialAnchorClockTics : AnchorClockTics)
            + (trial ? TrialAnchorCivilTics : AnchorCivilTics);
        if (tics < 0) days--;
        // Comprobar antes de sumar para no desbordar un reloj muy antiguo.
        if (days > CaelumCalendarRules.MAX_SERIAL - serial) return -1;
        if (tics >= CaelumWorldClock.TicsPerDay()) days++;
        if (days < 0 || days > CaelumCalendarRules.MAX_SERIAL - serial) return -1;
        return serial + days;
    }

    clearscope int CivilDayTics(CaelumWorldClock clock, bool trial = false)
    {
        if (DateSerial(clock, trial) < 0) return -1;
        int length = CaelumWorldClock.TicsPerDay();
        return (clock.DayTics - (trial ? TrialAnchorClockTics : AnchorClockTics)
            + (trial ? TrialAnchorCivilTics : AnchorCivilTics) + length) % length;
    }

    clearscope String FormatDate(CaelumWorldClock clock, bool trial = false)
    {
        int serial = DateSerial(clock, trial);
        if (serial < 0) return "";
        int tics = CivilDayTics(clock, trial);
        int hour = tics / CaelumWorldClock.TicsPerHour();
        int minute = (tics % CaelumWorldClock.TicsPerHour()) * 60
            / CaelumWorldClock.TicsPerHour();
        return String.Format("%02d/%02d/%04d %02d:%02d",
            CaelumCalendarRules.DayForSerial(serial),
            CaelumCalendarRules.MonthForSerial(serial),
            CaelumCalendarRules.YearForSerial(serial), hour, minute);
    }

    bool SetAnchor(CaelumWorldClock clock, int serial, int civilTics, bool trial)
    {
        if (clock == null || serial < 0 || serial > CaelumCalendarRules.MAX_SERIAL
            || civilTics < 0 || civilTics >= CaelumWorldClock.TicsPerDay()
            || clock.CompletedDays < 0 || clock.DayTics < 0
            || clock.DayTics >= CaelumWorldClock.TicsPerDay()
            || (trial && !Configured)) return false;
        if (trial)
        {
            TrialAnchorSerial = serial;
            TrialAnchorClockDays = clock.CompletedDays;
            TrialAnchorClockTics = clock.DayTics;
            TrialAnchorCivilTics = civilTics;
        }
        else
        {
            AnchorSerial = serial;
            AnchorClockDays = clock.CompletedDays;
            AnchorClockTics = clock.DayTics;
            AnchorCivilTics = civilTics;
            Configured = true;
        }
        TrialDate = trial;
        return true;
    }

    bool EnsureCampaign(CaelumWorldClock clock)
    {
        if (CampaignRevision >= 1) return Configured;
        // Un save de 0a/0b no distingue tiempo del Limbo del tiempo exterior.
        // Anclar una sola vez a su contador actual conserva viajes y progreso,
        // sin convertir una fecha de prueba antigua en cronología narrativa.
        int serial = CaelumCalendarRules.ToSerial(CaelumCalendarRules.CAMPAIGN_START_YEAR,
            CaelumCalendarRules.CAMPAIGN_START_MONTH, CaelumCalendarRules.CAMPAIGN_START_DAY);
        int tics = CaelumCalendarRules.CAMPAIGN_START_HOUR * CaelumWorldClock.TicsPerHour();
        if (!SetAnchor(clock, serial, tics, false)) return false;
        CampaignRevision = 1;
        return true;
    }

    void DisableTrial()
    {
        // La campaña siguió avanzando durante la prueba; no se vuelve a 09:00.
        TrialDate = false;
    }

    static bool CanConfigureTrial(CaelumPlayer user)
    {
        int participants = 0;
        for (int i = 0; i < MAXPLAYERS; i++) if (playeringame[i]) participants++;
        if (participants != 1 || user == null || user.player == null || user.health <= 0
            || !user.CharacterCreationComplete || user.CreationWizardOpen
            || (user.player.cheats & CF_PREDICTING)) return false;
        let record = user.GetPersistentCharacterState(false);
        return record != null && record.ProfileCommitted && CaelumWorldClock.Get(user) != null;
    }

    static void ConfigureTrial(CaelumPlayer user, int year, int month, int day)
    {
        int serial = CaelumCalendarRules.ToSerial(year, month, day);
        if (serial < 0)
        {
            Console.Printf("[Caelum 4.35.0d] Fecha inválida. Usá: netevent ca_debug_calendar_set AÑO MES DÍA (años 1–9999). No se modificó el calendario.");
            return;
        }
        if (!CanConfigureTrial(user))
        {
            Console.Printf("[Caelum 4.35.0d] El calendario de prueba requiere una partida individual y un personaje confirmado vivo.");
            return;
        }
        let clock = CaelumWorldClock.Get(user);
        let calendar = Get(user, true);
        if (calendar == null || !calendar.EnsureCampaign(clock)
            || !calendar.SetAnchor(clock, serial, calendar.CivilDayTics(clock), true)) return;
        Console.Printf("[Caelum 4.35.0d] Fecha de prueba fijada; la fecha de campaña y el reloj se conservan.");
        Report(user);
    }

    static void PrepareMidnightTrial(CaelumPlayer user)
    {
        if (!CanConfigureTrial(user)) return;
        let calendar = Get(user);
        let clock = CaelumWorldClock.Get(user);
        if (calendar == null || !calendar.TrialDate || calendar.DateSerial(clock, true) < 0)
        {
            Console.Printf("[Caelum 4.35.0d] Primero fijá una fecha con ca_debug_calendar_set AÑO MES DÍA.");
            return;
        }
        int serial = calendar.DateSerial(clock, true);
        // Sólo cambia el anclaje de prueba, nunca adelanta el reloj global.
        calendar.SetAnchor(clock, serial, CaelumWorldClock.TicsPerDay()
            - int(12*TICRATE*CaelumWorldClock.MapTimeScale(level.MapName)), true);
        Console.Printf("[Caelum 4.35.0j] Medianoche del calendario de prueba en unos 12 segundos de simulación. Cerrá la consola y mirá TAB > Mundo.");
        Report(user);
    }

    static void ClearTrial(CaelumPlayer user)
    {
        if (!CanConfigureTrial(user)) return;
        let calendar = Get(user);
        if (calendar != null) calendar.DisableTrial();
        Console.Printf("[Caelum 4.35.0d] Fecha de prueba retirada; Mundo muestra la fecha actual de campaña.");
    }

    static void Report(CaelumPlayer user)
    {
        let calendar = Get(user);
        let clock = CaelumWorldClock.Get(user);
        int serial = calendar == null ? -1 : calendar.DateSerial(clock);
        Console.Printf("[Caelum 4.35.0d] Calendario: configurado=%d prueba=%d mapa=%s",
            calendar != null && calendar.Configured, calendar != null && calendar.TrialDate, level.MapName);
        if (serial < 0)
        {
            Console.Printf("Calendario de campaña pendiente de inicializar, o fuera del intervalo civil admitido.");
            return;
        }
        int year = CaelumCalendarRules.YearForSerial(serial);
        int month = CaelumCalendarRules.MonthForSerial(serial);
        Console.Printf("Campaña=%s serial=%d bisiesto=%d estación=%s (convención mensual austral de prueba)",
            calendar.FormatDate(clock), serial, CaelumCalendarRules.IsLeapYear(year),
            StringTable.Localize(CaelumCalendarRules.SeasonKey(
                CaelumCalendarRules.SouthernSeasonForMonth(month)), false));
        Console.Printf("Anclaje: fecha=%d reloj=%d d + %d tics; hora civil inicial=%d tics. El clima usa la fecha de campaña.",
            calendar.AnchorSerial, calendar.AnchorClockDays, calendar.AnchorClockTics, calendar.AnchorCivilTics);
        Console.Printf("Revisión de campaña=%d escala 1:1 del Limbo=%d",
            calendar.CampaignRevision, CaelumWorldCatalogue.IsLimboMap(level.MapName));
        if (calendar.TrialDate)
            Console.Printf("Vista de prueba=%s (no modifica la campaña)", calendar.FormatDate(clock, true));
    }

    Default
    {
        Inventory.Amount 1;
        Inventory.MaxAmount 1;
        Inventory.InterHubAmount 1;
        +INVENTORY.UNDROPPABLE
        +INVENTORY.UNCLEARABLE
        +INVENTORY.KEEPDEPLETED
        -INVENTORY.INVBAR
    }
    States { Spawn: TNT1 A -1; Stop; }
}
