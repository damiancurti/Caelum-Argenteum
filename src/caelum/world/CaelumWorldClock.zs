// Reloj único: el Limbo usa escala 1:1 y el exterior conserva 20:1.
// La unidad guardada sigue siendo la anterior; no se reescriben fechas/viajes.
class CaelumWorldClock : Inventory
{
    int CompletedDays;
    int DayTics;
    int LimboSubTics;
    // Revisión 1: tiempo local separado, sin reconstruir ni borrar el pasado.
    int LocalClockRevision;
    int LimboDays;
    int LimboDayTics;

    void EnsureLocalClock()
    {
        if (LocalClockRevision >= 1) return;
        // Conserva la hora que mostraba un guardado antiguo dentro del Limbo.
        if (CaelumWorldCatalogue.IsLimboMap(level.MapName))
        { LimboDays = CompletedDays; LimboDayTics = DayTics; }
        LocalClockRevision = 1;
    }

    clearscope int LocalDays()
    { return LocalClockRevision >= 1 ? LimboDays : CompletedDays; }
    clearscope int LocalTics()
    { return LocalClockRevision >= 1 ? LimboDayTics : DayTics; }

    static clearscope double SecondsPerGameHour(String mapName)
    {
        return CaelumWorldCatalogue.IsLimboMap(mapName) ? 3600.0
            : CaelumConstants.REAL_SECONDS_PER_GAME_HOUR;
    }

    static clearscope double MapTimeScale(String mapName)
    { return CaelumConstants.REAL_SECONDS_PER_GAME_HOUR / SecondsPerGameHour(mapName); }

    static clearscope int TicsPerHour()
    {
        return int(CaelumConstants.REAL_SECONDS_PER_GAME_HOUR * TICRATE);
    }

    static clearscope int TicsPerDay()
    {
        return TicsPerHour() * int(CaelumConstants.GAME_HOURS_PER_DAY);
    }

    static CaelumWorldClock Get(CaelumPlayer user, bool create = false)
    {
        if (user == null) return null;
        let clock = CaelumWorldClock(user.FindInventory("CaelumWorldClock"));
        if (clock == null && create)
            clock = CaelumWorldClock(user.GiveInventoryType("CaelumWorldClock"));
        return clock;
    }

    void AdvanceOneTic()
    {
        // Contadores enteros: no acumula redondeos de segundos fraccionarios.
        // Separar jornadas evita desbordar un total de tics de larga duración.
        int last = TicsPerDay() - 1;
        if (CompletedDays == 2147483647 && DayTics >= last) return;
        if (DayTics >= last) { CompletedDays++; DayTics = 0; }
        else DayTics++;
        CaelumScheduleState.Sync(CaelumPlayer(Owner));
    }

    // El viaje ya expresa su duración en unidades del reloj exterior.
    // Suma por jornadas sin un total absoluto que pueda desbordar.
    void AdvanceTics(int count)
    {
        if (count <= 0) return;
        int length = TicsPerDay();
        int days = count / length;
        int remainder = DayTics + count % length;
        if (remainder >= length) { days++; remainder -= length; }
        if (CompletedDays > 2147483647 - days)
        { CompletedDays = 2147483647; DayTics = length - 1; return; }
        CompletedDays += days; DayTics = remainder;
        CaelumScheduleState.Sync(CaelumPlayer(Owner));
    }

    void AdvanceOnMap(String mapName)
    {
        EnsureLocalClock();
        int previousDay = LimboDays;
        if (CaelumWorldCatalogue.IsLimboMap(mapName))
        {
            // Una fracción entera guardada evita perder tiempo al cargar o
            // alternar T. Veinte pasos del Limbo equivalen a un tic del reloj.
            LimboSubTics++;
            int divisor = int(SecondsPerGameHour(mapName) / CaelumConstants.REAL_SECONDS_PER_GAME_HOUR);
            if (LimboSubTics < divisor) return;
            LimboSubTics -= divisor;
            if (LimboDayTics >= TicsPerDay()-1)
            { if (LimboDays < 2147483647) { LimboDays++; LimboDayTics=0; } }
            else LimboDayTics++;
            // El contador heredado sigue monótono para descansos y reservas.
            // Desplazar ambos anclajes congela la fecha civil, no el reloj local.
            let calendar = CaelumCalendarState.Get(CaelumPlayer(Owner));
            if (calendar != null) calendar.ExcludeLimboTic();
        }
        AdvanceOneTic();
        if (LimboDays != previousDay) SyncLocalDay();
    }

    void SyncLocalDay()
    {
        if (!CaelumWorldCatalogue.IsLimboMap(level.MapName)) return;
        let it=ThinkerIterator.Create("CaelumDiningTable"); CaelumDiningTable table;
        while ((table=CaelumDiningTable(it.Next()))!=null) table.SyncLocalDay(LocalDays());
    }

    static clearscope String FormatStamp(int days, int tics, bool seconds = false)
    {
        int hour = tics / TicsPerHour();
        int minute = (tics % TicsPerHour()) * 60 / TicsPerHour();
        if (seconds)
            return String.Format("%d d %02d:%02d:%02d", days, hour, minute,
                ((tics % TicsPerHour()) * 3600 / TicsPerHour()) % 60);
        return String.Format("%d d %02d:%02d", days, hour, minute);
    }

    static void Report(CaelumPlayer user)
    {
        let clock = Get(user);
        Console.Printf("[Caelum 4.35.0j] Reloj global: registro=%d mapa=%s escala real del Limbo=%d",
            clock != null, level.MapName, CaelumWorldCatalogue.IsLimboMap(level.MapName));
        if (clock == null) return;
        Console.Printf("Tiempo registrado=%s jornadas=%d tics del día=%d/%d",
            FormatStamp(clock.CompletedDays, clock.DayTics, true),
            clock.CompletedDays, clock.DayTics, TicsPerDay());
        Console.Printf("Escala: 1 hora de juego = %.0f segundos de simulación; %d tics por hora.",
            SecondsPerGameHour(level.MapName), int(SecondsPerGameHour(level.MapName)*TICRATE));
        Console.Printf("Fracción del Limbo conservada=%d/20", clock.LimboSubTics);
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

// Un observador estático también existe al cargar guardados anteriores.
// No conserva una copia del reloj: siempre consulta el Inventory viajero.
class CaelumWorldClockTicker : StaticEventHandler
{
    override void WorldTick()
    {
        // La base de mundo y viajes actual es individual. No crear relojes
        // divergentes para una sesión compartida aún pendiente de V5.
        CaelumPlayer user;
        int participants = 0;
        for (int i = 0; i < MAXPLAYERS; i++)
        {
            if (!playeringame[i]) continue;
            participants++;
            user = CaelumPlayer(players[i].mo);
        }
        if (participants != 1 || user == null || user.player == null
            || !user.CharacterCreationComplete || user.CreationWizardOpen
            || (user.player.cheats & CF_PREDICTING)) return;
        let record = user.GetPersistentCharacterState(false);
        if (record == null || !record.ProfileCommitted) return;
        let clock = CaelumWorldClock.Get(user, true);
        if (clock == null) return;
        // Inicializa también en MAP01 y al cargar una partida anterior.
        // El anclaje civil se fija antes de consumir el primer tic exterior.
        let calendar = CaelumCalendarState.Get(user, true);
        if (calendar == null || !calendar.EnsureCampaign(clock)) return;
        CaelumTimeSkipState.PrepareStep(user);
        clock.AdvanceOnMap(level.MapName);
        CaelumWeatherState.Sync(user, clock, calendar);
        // WorldTick sigue la simulación nativa. Las conversaciones de Caelum
        // continúan; la pausa voluntaria y la carga no se compensan con tiempo
        // del sistema operativo.
    }
}
