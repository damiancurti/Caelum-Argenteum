// Tiempo global registrado. Desde 0c sólo avanza fuera del Limbo; los
// contadores anteriores se conservan para no reescribir las marcas de viaje.
class CaelumWorldClock : Inventory
{
    int CompletedDays;
    int DayTics;

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
    }

    void AdvanceOnMap(String mapName)
    {
        if (CaelumWorldCatalogue.IsTimelessMap(mapName)) return;
        AdvanceOneTic();
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
        Console.Printf("[Caelum 4.35.0d] Reloj global: registro=%d mapa=%s detenido por Limbo=%d",
            clock != null, level.MapName, CaelumWorldCatalogue.IsTimelessMap(level.MapName));
        if (clock == null) return;
        Console.Printf("Tiempo registrado=%s jornadas=%d tics del día=%d/%d",
            FormatStamp(clock.CompletedDays, clock.DayTics, true),
            clock.CompletedDays, clock.DayTics, TicsPerDay());
        Console.Printf("Escala: 1 hora de juego = %.0f segundos de simulación; %d tics por hora.",
            CaelumConstants.REAL_SECONDS_PER_GAME_HOUR, TicsPerHour());
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
        clock.AdvanceOnMap(level.MapName);
        // WorldTick sigue la simulación nativa. Las conversaciones de Caelum
        // continúan; la pausa voluntaria y la carga no se compensan con tiempo
        // del sistema operativo.
    }
}
