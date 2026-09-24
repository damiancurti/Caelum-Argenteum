// Registro del último traslado, transportado y serializado por el motor.
// Las rutas con distancia definida consultan un plan antes de confirmar.
// Los eventos narrativos concretos aún requieren contenido autoral.
class CaelumJourneyState : Inventory
{
    const MODE_FOOT = 1;
    const MODE_CARAVAN = 2;
    const MODE_CART = 3;
    const MODE_SHIP = 4;
    const STATUS_NONE = 0;
    const STATUS_DEPARTED = 1;
    const STATUS_ARRIVED = 2;
    const STATUS_INTERRUPTED = 3;
    int Sequence;
    int ConnectionId;
    int TravelMode;
    int Status;
    int Arrivals;
    int Interruptions;
    double DistanceKm;
    double WalkingKmh;
    int WalkTics;
    int SleepTics;
    int FoodConsumed;
    int WaterConsumed;
    double ContainerLitersConsumed;
    bool HasDepartureTime;
    int DepartureDays;
    int DepartureDayTics;
    bool HasArrivalTime;
    int ArrivalDays;
    int ArrivalDayTics;

    void RecordDepartureTime(CaelumPlayer user)
    {
        HasDepartureTime = false; HasArrivalTime = false;
        DepartureDays = 0; DepartureDayTics = 0;
        ArrivalDays = 0; ArrivalDayTics = 0;
        let clock = CaelumWorldClock.Get(user, true);
        if (clock == null) return;
        HasDepartureTime = true;
        DepartureDays = clock.CompletedDays; DepartureDayTics = clock.DayTics;
    }

    static CaelumJourneyState Get(CaelumPlayer user, bool create = false)
    {
        if (user == null) return null;
        let journey = CaelumJourneyState(user.FindInventory("CaelumJourneyState"));
        if (journey == null && create)
            journey = CaelumJourneyState(user.GiveInventoryType("CaelumJourneyState"));
        return journey;
    }

    static void Update(CaelumPlayer user, bool loaded = false)
    {
        let journey = Get(user);
        if (journey == null || journey.Status != STATUS_DEPARTED) return;
        let record = user.GetPersistentCharacterState(false);
        if (record == null) return;
        int id = journey.ConnectionId;
        int here = CaelumWorldCatalogue.LocationForMap(level.MapName);
        bool valid = CaelumWorldCatalogue.IsSewerConnection(id);
        if (valid && here == CaelumWorldCatalogue.ConnectionOrigin(id)
            && record.WorldPendingConnection == id && !loaded) return;
        // Resolver antes de WorldProgress: sólo acredita el destino esperado
        // con su salida pendiente. Otra llegada o cargar aún en origen aborta.
        if (valid && here == CaelumWorldCatalogue.ConnectionDestination(id)
            && record.WorldPendingConnection == id)
        {
            journey.Status = STATUS_ARRIVED;
            journey.Arrivals = Min(journey.Arrivals, 2147483646) + 1;
            // Una llegada antigua sin salida fechada conserva esa ausencia.
            let clock = CaelumWorldClock.Get(user);
            if (journey.HasDepartureTime && clock != null)
            {
                journey.HasArrivalTime = true;
                journey.ArrivalDays = clock.CompletedDays;
                journey.ArrivalDayTics = clock.DayTics;
            }
        }
        else
        {
            journey.Status = STATUS_INTERRUPTED;
            journey.HasArrivalTime = false;
            journey.Interruptions = Min(journey.Interruptions, 2147483646) + 1;
            if (record.WorldPendingConnection == id) record.WorldPendingConnection = 0;
        }
    }

    static clearscope String StatusKey(int state)
    {
        if (state == STATUS_DEPARTED) return "CA_JOURNEY_DEPARTED";
        if (state == STATUS_ARRIVED) return "CA_JOURNEY_ARRIVED";
        if (state == STATUS_INTERRUPTED) return "CA_JOURNEY_INTERRUPTED";
        return "CA_JOURNEY_NONE";
    }

    static void Report(CaelumPlayer user)
    {
        let journey = Get(user);
        Console.Printf("[Caelum 4.35.0p] Viajes: registro=%d mapa=%s", journey != null, level.MapName);
        if (journey == null) return;
        Console.Printf("Secuencia=%d conexión=%d modo=%d estado=%d llegadas=%d interrupciones=%d",
            journey.Sequence, journey.ConnectionId, journey.TravelMode, journey.Status,
            journey.Arrivals, journey.Interruptions);
        Console.Printf("Distancia=%.3f km marcha=%.6f km/h movimiento=%d dormir=%d tics comida=%d agua=%d recipientes=%.3f L",
            journey.DistanceKm, journey.WalkingKmh, journey.WalkTics, journey.SleepTics,
            journey.FoodConsumed, journey.WaterConsumed, journey.ContainerLitersConsumed);
        if (journey.HasDepartureTime)
            Console.Printf("Salida registrada: %s", CaelumWorldClock.FormatStamp(journey.DepartureDays, journey.DepartureDayTics, true));
        else Console.Printf("Salida sin marca temporal registrada.");
        if (journey.HasArrivalTime)
            Console.Printf("Llegada registrada: %s", CaelumWorldClock.FormatStamp(journey.ArrivalDays, journey.ArrivalDayTics, true));
    }

    Default
    {
        Inventory.MaxAmount 1;
        Inventory.InterHubAmount 1;
        +INVENTORY.UNDROPPABLE
        -INVENTORY.INVBAR
    }
    States { Spawn: TNT1 A -1; Stop; }
}

class CaelumTravelService : Object play
{
    static bool CanDepart(CaelumPlayer user, int id)
    {
        if (user == null || user.player == null || !user.CharacterCreationComplete
            || user.CreationWizardOpen || user.health <= 0 || user.player.playerstate != PST_LIVE
            || (user.player.cheats & CF_PREDICTING) || !CaelumWorldCatalogue.IsSewerConnection(id)
            || CaelumWorldCatalogue.ConnectionOrigin(id) != CaelumWorldCatalogue.LocationForMap(level.MapName)) return false;
        if (!CaelumSewerMaze.CanLeave(user)) return false;
        if (user.HasActiveConversation() || user.PalomoMerchantMenuOpen || user.CraftingMenuOpen
            || user.CraftingTaskActive || user.EquipmentMenuOpen || user.CombatChannelModeActive
            || CaelumRestState.IsActive(user)
            || (user.player.cheats & CF_TOTALLYFROZEN))
        { CaelumNotifications.Notify(user,StringTable.Localize("CA_SEWER_TRAVEL_BUSY", false)); return false; }
        for (int i = 0; i < MAXPLAYERS; i++)
            if (playeringame[i] && players[i].mo != user)
            { CaelumNotifications.Notify(user,StringTable.Localize("CA_M01_RETURN_SOLO", false)); return false; }
        String destination = CaelumWorldCatalogue.MapForLocation(CaelumWorldCatalogue.ConnectionDestination(id));
        if (destination == "MAP01" || !LevelInfo.MapExists(destination))
        { CaelumNotifications.Notify(user,StringTable.Localize("CA_SEWER_TRAVEL_MISSING", false)); return false; }
        let record = user.GetPersistentCharacterState(false);
        let journey = CaelumJourneyState.Get(user);
        return record != null && record.ProfileCommitted && record.WorldPendingConnection == 0
            && (journey == null || journey.Status != CaelumJourneyState.STATUS_DEPARTED);
    }

    static bool Begin(CaelumPlayer user, int id, int travelMode)
    {
        if (!CaelumJourneyRules.ValidMode(id, travelMode) || !CanDepart(user, id)) return false;
        if (CaelumJourneyRules.DistanceKm(id) > 0) return CaelumJourneyPlan.Preview(user, id, travelMode);
        CaelumJourneyPlan.Cancel(user);
        return Commit(user, id, travelMode);
    }

    static bool Commit(CaelumPlayer user, int id, int travelMode, CaelumJourneyPlan plan = null)
    {
        if (!CaelumJourneyRules.ValidMode(id, travelMode) || !CanDepart(user, id)) return false;
        // Las rutas medidas nunca admiten la antigua salida sin presupuesto.
        if (CaelumJourneyRules.DistanceKm(id) > 0
            && (plan == null || !plan.Open || plan.ConnectionId != id || plan.TravelMode != travelMode
                || plan.Available == null || !plan.VehicleAvailable(user))) return false;
        let journey = CaelumJourneyState.Get(user, true);
        if (journey == null) return false;
        let record = user.GetPersistentCharacterState(false);
        // Una sola escritura de salida tras validar; ninguna copia, limpieza,
        // tarifa ni reposición del inventario. El regreso narrativo es aparte.
        user.CancelCombatBlockMode(); user.CancelRangedAim(); user.CancelRangedReload();
        user.CancelWeaponCharge(); user.CancelPendingStaffCast(false);
        user.Vel = (0,0,0);
        journey.Sequence = Min(journey.Sequence, 2147483646) + 1;
        journey.ConnectionId = id; journey.TravelMode = travelMode;
        journey.Status = CaelumJourneyState.STATUS_DEPARTED;
        journey.RecordDepartureTime(user);
        journey.DistanceKm = CaelumJourneyRules.DistanceKm(id);
        journey.WalkingKmh = plan == null ? 0 : plan.SpeedKmh;
        journey.WalkTics = plan == null ? 0 : plan.Available.WalkTics;
        journey.SleepTics = plan == null ? 0 : plan.Available.SleepTics;
        journey.FoodConsumed = plan == null ? 0 : plan.Available.FoodSpent;
        journey.WaterConsumed = plan == null ? 0 : plan.Available.WaterSpent;
        journey.ContainerLitersConsumed = plan == null ? 0 : plan.Available.ContainerSpent;
        if (plan != null) plan.Apply(user);
        if (user.health <= 0)
        {
            journey.Status = CaelumJourneyState.STATUS_INTERRUPTED;
            journey.Interruptions = Min(journey.Interruptions, 2147483646) + 1;
            user.PersistCharacterState();
            user.Die(user, user, 0, 'CaelumSurvival');
            return true;
        }
        record.WorldConnectionKnown[id] = true;
        record.WorldPendingConnection = id;
        user.PersistCharacterState();
        Level.ChangeLevel(CaelumWorldCatalogue.MapForLocation(CaelumWorldCatalogue.ConnectionDestination(id)),
            CaelumWorldCatalogue.ConnectionDestination(id)==CaelumWorldCatalogue.LOCATION_SEWERS ? 1 : 0, CHANGELEVEL_NOINTERMISSION);
        return true;
    }
}
