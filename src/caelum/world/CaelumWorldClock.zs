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
    // Revisión 1: réplicas del reloj de campaña en los inventarios viajeros.
    // Elegir por plaza nativa, nunca por consoleplayer, mantiene todos los peers
    // iguales. Una réplica ya sincronizada prevalece sobre un personaje nuevo.
    int SharedRevision;
    int CooperativeSerial;
    CaelumCooperativeTime TimeVote;
    CaelumCooperativeTravel TravelVote;
    CaelumCooperativeQuests CampaignQuests;

    void CopyShared(CaelumWorldClock source)
    {
        if (source == null || source == self) return;
        CompletedDays=source.CompletedDays;DayTics=source.DayTics;
        LimboSubTics=source.LimboSubTics;LocalClockRevision=source.LocalClockRevision;
        LimboDays=source.LimboDays;LimboDayTics=source.LimboDayTics;
        SharedRevision=1;
        CooperativeSerial=source.CooperativeSerial;TimeVote=source.TimeVote;TravelVote=source.TravelVote;
        CampaignQuests=source.CampaignQuests;
    }

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
    CaelumM00FoolEssence ArcanaSources[CaelumConstants.TAROT_CARD_COUNT];
    int ArcanaSourcesReadyAfter;
    CaelumPhysicsMapState AltitudeMap;
    CaelumConnectedWaterMap WaterMap;
    CaelumTarotWaterMap TarotWaterMap;
    Array<CaelumClimateRegion> ClimateMarkers;
    // El handler ya existe en saves anteriores; su nueva implementación
    // alcanza también esos mapas sin depender de registrar otro handler.
    override void WorldLoaded(WorldEvent e)
    {
        // Cada esencia se registra en su propio Tick tras cargar. Esperar un
        // ciclo completo impide crear un duplicado antes de recibir ese registro.
        for(int card=0;card<CaelumConstants.TAROT_CARD_COUNT;card++)ArcanaSources[card]=null;
        ArcanaSourcesReadyAfter=level.time+1;
        CaelumPhysicsWorld.Initialize();CaelumConnectedWaterMap.Initialize();
        CaelumTarotWaterMap.Initialize();
        // Un censo tipado por carga restaura marcadores de mapas/save antiguos.
        // El coste posterior es O(1) por consulta y altas/bajas por evento.
        ClimateMarkers.Clear();
        let it=ThinkerIterator.Create("CaelumClimateRegion");CaelumClimateRegion marker;
        while((marker=CaelumClimateRegion(it.Next()))!=null)ClimateMarkers.Push(marker);
    }

    override void WorldThingSpawned(WorldEvent e)
    {
        CaelumArcanaSources.Register(CaelumM00FoolEssence(e.Thing));
        let marker=CaelumClimateRegion(e.Thing);if(marker==null)return;
        for(int i=0;i<ClimateMarkers.Size();i++)if(ClimateMarkers[i]==marker)return;
        ClimateMarkers.Push(marker);
    }
    override void WorldThingDestroyed(WorldEvent e)
    {
        CaelumArcanaSources.Forget(CaelumM00FoolEssence(e.Thing));
        if(!(e.Thing is 'CaelumClimateRegion'))return;
        for(int i=0;i<ClimateMarkers.Size();i++)if(ClimateMarkers[i]==e.Thing)
        {ClimateMarkers.Delete(i);return;}
    }
    static CaelumClimateRegion ClimateMarker()
    {
        let ticker=CaelumWorldClockTicker(StaticEventHandler.Find('CaelumWorldClockTicker'));
        return ticker!=null && ticker.ClimateMarkers.Size()>0?ticker.ClimateMarkers[0]:null;
    }

    static bool Ready(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanMutate(user) || !user.CharacterCreationComplete
            || user.CreationWizardOpen) return false;
        let record=user.GetPersistentCharacterState(false);
        if(record==null || !record.ProfileCommitted)return false;
        // La identidad legal existente es estable al exportar/reimportar el
        // perfil. Su creación es idempotente y sólo toca a este participante.
        if(record.LawfulIdentity==null)CaelumLockRules.Character(user,true);
        return true;
    }

    static CaelumPlayer CampaignOwner()
    {
        CaelumPlayer first;
        // O(MAXPLAYERS): el padrón de red es acotado; no recorre actores.
        for(int i=0;i<MAXPLAYERS;i++)
        {
            if(!playeringame[i])continue;
            let user=CaelumPlayer(players[i].mo);
            if(!Ready(user))continue;
            if(first==null)first=user;
            let clock=CaelumWorldClock.Get(user);
            if(clock!=null && clock.SharedRevision>=1)return user;
        }
        return first;
    }

    static void Mirror(CaelumPlayer source)
    {
        let clock=CaelumWorldClock.Get(source);
        let calendar=CaelumCalendarState.Get(source);
        let weather=CaelumWeatherState.Get(source);
        if(clock==null || calendar==null)return;
        clock.SharedRevision=1;
        for(int i=0;i<MAXPLAYERS;i++)
        {
            if(!playeringame[i])continue;
            let user=CaelumPlayer(players[i].mo);
            if(user==source || !Ready(user))continue;
            CaelumWorldClock.Get(user,true).CopyShared(clock);
            let peerCalendar=CaelumCalendarState.Get(user,true);
            peerCalendar.Configured=calendar.Configured;
            peerCalendar.CampaignRevision=calendar.CampaignRevision;
            peerCalendar.AnchorSerial=calendar.AnchorSerial;
            peerCalendar.AnchorClockDays=calendar.AnchorClockDays;
            peerCalendar.AnchorClockTics=calendar.AnchorClockTics;
            peerCalendar.AnchorCivilTics=calendar.AnchorCivilTics;
            // Las fechas de diagnóstico personales no sustituyen la campaña.
            if(weather!=null && weather.Seed!=0)
            {
                let peerWeather=CaelumWeatherState.Get(user,true);
                if(peerWeather.Seed!=weather.Seed)
                {peerWeather.Seed=weather.Seed;peerWeather.Revision=0;}
            }
        }
    }

    override void WorldTick()
    {
        CaelumPlayer user=CampaignOwner();
        int participants = 0;
        for (int i = 0; i < MAXPLAYERS; i++)
        {
            if (!playeringame[i]) continue;
            participants++;
        }
        if (user == null) return;
        let clock = CaelumWorldClock.Get(user, true);
        if (clock == null) return;
        // También una campaña individual conserva sus objetivos en el mundo,
        // antes de que un perfil pueda trasladarse a una campaña diferente.
        if(clock.CampaignQuests==null || clock.CampaignQuests.Revision<2)CaelumCooperativeQuests.Get(user);
        // Inicializa también en MAP01 y al cargar una partida anterior.
        // El anclaje civil se fija antes de consumir el primer tic exterior.
        let calendar = CaelumCalendarState.Get(user, true);
        if (calendar == null || !calendar.EnsureCampaign(clock)) return;
        if(participants==1)CaelumTimeSkipState.PrepareStep(user);
        else Mirror(user);
        clock.AdvanceOnMap(level.MapName);
        if(WaterMap!=null)WaterMap.Sync(clock);
        CaelumShopRestock.UpdateActive(user);
        CaelumWeatherState.Sync(user, clock, calendar);
        if(participants>1)
        {
            Mirror(user);
            for(int i=0;i<MAXPLAYERS;i++)
            {
                if(!playeringame[i])continue;
                let peer=CaelumPlayer(players[i].mo);
                if(peer==user || !Ready(peer))continue;
                CaelumScheduleState.Sync(peer);
                CaelumWeatherState.Sync(peer,CaelumWorldClock.Get(peer),CaelumCalendarState.Get(peer));
            }
        }
        // WorldTick sigue la simulación nativa. Las conversaciones de Caelum
        // continúan; la pausa voluntaria y la carga no se compensan con tiempo
        // del sistema operativo.
    }
}
