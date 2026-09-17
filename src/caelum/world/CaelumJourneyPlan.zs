// Planificación sin actores, inventarios ni reloj mutados. La confirmación
// vuelve a calcular el mismo modelo y aplica una sola transacción de viaje.
class CaelumJourneyRules : Object play
{
    const MAP_UNITS_PER_METER = 32.0;
    const WALK_HOURS = 16;
    const SLEEP_HOURS = 8;
    // Límite técnico explícito del planificador; nunca trunca una ruta.
    const MAX_WALK_HOURS = 24 * 30;

    static clearscope double DistanceKm(int id)
    {
        if (id == 8 || id == 9) return 10.0;
        if (id == 10 || id == 11) return 500.0;
        return 0.0;
    }

    static clearscope int SleepCount(int walkTics)
    { return walkTics > 0 ? (walkTics - 1) / (WALK_HOURS * CaelumWorldClock.TicsPerHour()) : 0; }

    static clearscope String Duration(int tics)
    {
        int minutes = int(Ceil(double(tics) * 60 / CaelumWorldClock.TicsPerHour()));
        return String.Format("%d d %02d h %02d min", minutes / 1440, (minutes / 60) % 24, minutes % 60);
    }

    static double WalkingMUPerTic(CaelumPlayer user)
    {
        if (user == null || user.DerivedStats == null || user.IsPhysicallyImmobilized()) return 0;
        // Marcha sostenida en suelo normal, de pie, sin correr ni diagonales.
        // TweakSpeeds: entrada normal * ForwardMove1 * Speed / 256.
        // El desplazamiento incluye el impulso anterior a la fricción nativa.
        // No usar Vel ni la aceleración inicial: parado no significa incapaz.
        double factor = CaelumConstants.GZDOOM_BASE_MOVEMENT
            * Max(0.0, user.EffectiveMovementPercent / 100.0);
        if (user.ElementalStatus != null) factor *= user.ElementalStatus.GetMovementMultiplier();
        if (!user.Alternative)
            for (Inventory item = user.Inv; item != null; item = item.Inv)
                factor *= item.GetSpeedFactor();
        return gameinfo.normforwardmove[0] * factor * user.Speed
            * Actor.ORIG_FRICTION_FACTOR / (1.0 - Actor.ORIG_FRICTION);
    }

    static double WalkingKmh(CaelumPlayer user)
    { return WalkingMUPerTic(user) * TICRATE * 3.6 / MAP_UNITS_PER_METER; }

    static String BlockReason(CaelumPlayer user)
    {
        if (user.DerivedStats == null || user.Attributes == null || user.IsPhysicallyImmobilized()
            || user.CombatTimeRemaining > 0 || user.WaterLevel != 0 || !user.player.onground
            || user.StaffCastPending || user.WeaponChargeActive || user.WeaponChargedStateActive
            || user.RangedReloadActive || user.CombatBlockModeActive
            || user.UnderwaterAirRecoveryDebt > 0 || user.UnderwaterAirRecoveryTicsRemaining > 0)
            return "CA_JOURNEY_BUSY";
        let s = user.ElementalStatus;
        if (s != null && (s.BurnRemaining > 0 || s.CutRemaining > 0 || s.PoisonRemaining > 0
            || s.FreezeRemaining > 0 || s.DazzleRemaining > 0 || s.EarthPenaltyRemaining > 0
            || s.LightningStunRemaining > 0)) return "CA_JOURNEY_BUSY";
        // No extender, borrar ni simular arbitrariamente efectos externos.
        for (Inventory item = user.Inv; item != null; item = item.Inv)
            if (Powerup(item) != null) return "CA_JOURNEY_EFFECT";
        return "";
    }
}

// Copia de valores exclusivamente numérica. Ambas previsiones recorren las
// mismas tasas y pulsos de un tic; una usa provisiones ilimitadas para calcular
// lo necesario y la otra sólo lo que el personaje lleva fuera de la Caja.
class CaelumJourneyModel : Object play
{
    double Hunger, Thirst, Sleep, Air, Anima, Lucidity, Adrenaline;
    double HealingFraction, DamageFraction, Stun;
    int Health, MaxHealth, ElapsedTics, WalkTics, SleepTics;
    int FoodSpent, WaterSpent, FoodStock, WaterStock;
    double ContainerStock, ContainerSpent;
    int FoodEffectTics, FoodPulseTics, WaterEffectTics, WaterPulseTics;
    double FoodPulse, WaterPulse, Mass;
    double HungerLoss, ThirstLoss, SleepLoss, Consumption;
    double HealthRate, AirRate, AnimaRate, MaxAir, MaxAnima, MaxAdrenaline, HealthPenalty;
    bool Unlimited, Bag;

    void Capture(CaelumPlayer user, bool useUnlimitedSupplies)
    {
        Unlimited = useUnlimitedSupplies;
        let d = user.DerivedStats;
        Mass = Max(1, d.BaseMass); FoodPulse = 80.0 / Mass;
        Hunger = user.CurrentHunger; Thirst = user.CurrentThirst; Sleep = user.CurrentSleep;
        Air = user.CurrentAir; Anima = user.CurrentAnima; Lucidity = user.CurrentLucidity;
        Adrenaline = user.CurrentAdrenaline; Stun = user.LucidityPhysicalStunRemaining;
        Health = user.health; MaxHealth = user.CaelumMaximumHealth;
        HealingFraction = user.NaturalHealthRegenerationAccumulator;
        DamageFraction = user.SurvivalDamageAccumulator;
        Consumption = d.GetHungerThirstConsumptionMultiplier(user.Attributes);
        double passive = d.BaseMassMultiplier * Consumption;
        HungerLoss = 100.0 * passive / (CaelumConstants.HUNGER_EMPTY_GAME_HOURS * CaelumWorldClock.TicsPerHour());
        ThirstLoss = 100.0 * passive / (CaelumConstants.THIRST_EMPTY_GAME_HOURS * CaelumWorldClock.TicsPerHour());
        SleepLoss = 100.0 * (100.0 / d.CalculateType4Percent(Max(0.0, user.Attributes.Resilience)))
            / (CaelumConstants.SLEEP_EMPTY_GAME_HOURS * CaelumWorldClock.TicsPerHour());
        HealthRate = d.HealthRegenerationPerSecond / TICRATE;
        AirRate = d.AirRegenerationPerSecond / TICRATE;
        AnimaRate = d.AnimaRegenerationPerSecond / TICRATE;
        MaxAir = d.MaximumAir; MaxAnima = d.MaximumAnima; MaxAdrenaline = d.MaximumAdrenaline;
        HealthPenalty = d.HealthPenaltyMultiplier;
        for (Inventory item = user.Inv; item != null; item = item.Inv)
        {
            let ration = CaelumConsumableItem(item);
            if (ration != null && !ration.InMagicBox && ration.Amount > 0)
            {
                let container = CaelumWaterContainer(ration);
                if (container != null) ContainerStock += Max(0.0, container.WaterLiters);
                else if (ration.GetConsumableType() == CaelumConstants.CONSUMABLE_FOOD_RATION)
                    FoodStock += Min(ration.Amount, 1000000000 - FoodStock);
                else if (ration.GetConsumableType() == CaelumConstants.CONSUMABLE_WATER_RATION)
                    WaterStock += Min(ration.Amount, 1000000000 - WaterStock);
            }
            let ownedBag = CaelumSleepingBag(item);
            if (ownedBag != null && !ownedBag.InMagicBox && ownedBag.Amount > 0) Bag = true;
        }
    }

    void BeginServings()
    {
        // No desperdiciar una porción por encima del máximo. Se come durante
        // la marcha y antes/después de acampar; no se empieza a comer dormido.
        if (FoodEffectTics == 0 && Hunger <= 100.0 - Min(100.0, FoodPulse * 10)
            && (Unlimited || FoodSpent < FoodStock))
        { FoodSpent++; FoodEffectTics = 10 * TICRATE; FoodPulseTics = 0; }
        if (WaterEffectTics != 0) return;
        double dose = FoodPulse * 10;
        bool ration = Unlimited || WaterSpent < WaterStock;
        double liters = ration ? 0 : Min(Mass / 500.0, ContainerStock - ContainerSpent);
        if (!ration) dose = liters * 5000.0 / Mass;
        if (dose <= 0.000001 || Thirst > 100.0 - Min(100.0, dose)) return;
        if (ration) WaterSpent++;
        else ContainerSpent += liters;
        WaterPulse = dose / 10; WaterEffectTics = 10 * TICRATE; WaterPulseTics = 0;
    }

    void Pulses()
    {
        if (FoodEffectTics > 0)
        {
            FoodPulseTics++;
            if (FoodPulseTics >= TICRATE)
            {
                FoodPulseTics = 0;
                double gained = Min(FoodPulse, 100.0 - Hunger);
                Hunger += gained; Sleep = Max(0.0, Sleep - gained / 4.0);
            }
            FoodEffectTics--;
        }
        if (WaterEffectTics > 0)
        {
            WaterPulseTics++;
            if (WaterPulseTics >= TICRATE)
            { WaterPulseTics = 0; Thirst = Min(100.0, Thirst + WaterPulse); }
            WaterEffectTics--;
        }
    }

    void Step(bool sleeping)
    {
        if (!sleeping) BeginServings();
        Pulses();
        // Los factores de comodidad coinciden con la bolsa real. No se crean
        // camas ni suministros: sin bolsa se duerme en el suelo (factor 1).
        double comfort = sleeping && Bag && Hunger > 10 && Thirst > 10 ? 3.0 : 1.0;
        Hunger = Max(0.0, Hunger - HungerLoss / comfort);
        Thirst = Max(0.0, Thirst - ThirstLoss / comfort);
        Sleep = sleeping ? Min(100.0, Sleep + 100.0 / (8 * CaelumWorldClock.TicsPerHour()))
            : Max(0.0, Sleep - SleepLoss);
        Stun = Max(0.0, Stun - 1.0 / TICRATE);
        double oldLucidity = Lucidity;
        Lucidity = sleeping ? Max(0.0, Lucidity - CaelumSleepRules.LUCIDITY_PER_SECOND / TICRATE)
            : Min(100.0, Lucidity + 100.0 / CaelumConstants.LUCIDITY_FULL_RECOVERY_SECONDS / TICRATE);
        if (oldLucidity > 10 && Lucidity <= 10)
            Stun = CaelumConstants.LUCIDITY_PHYSICAL_STUN_SECONDS
                * (1.0 + ((Sleep <= 10 ? 4.0 : Sleep <= 50 ? 2.0 : 1.0) - 1.0) * HealthPenalty);
        Adrenaline = Max(0.0, Adrenaline - CaelumConstants.ADRENALINE_DECAY_PER_SECOND / TICRATE);
        Anima = Min(MaxAnima, Anima + AnimaRate);
        int critical = int(Hunger <= 10) + int(Thirst <= 10) + int(Sleep <= 10 && !sleeping);
        if (critical == 0) DamageFraction = 0;
        else
        {
            DamageFraction += double(MaxHealth) / CaelumConstants.HEALTH_BASE_RECOVERY_REAL_SECONDS / TICRATE * critical;
            int damage = int(DamageFraction); DamageFraction -= damage; Health = Max(0, Health - damage);
        }
        if (Health <= 0) { ElapsedTics++; return; }
        double costs = Consumption / (comfort * comfort);
        if (Health >= MaxHealth || Hunger <= 10 || Thirst <= 10 || Sleep <= 10) HealingFraction = 0;
        else
        {
            double foodCost = 100.0 * costs / MaxHealth, waterCost = 50.0 * costs / MaxHealth;
            double affordable = Min(Hunger / foodCost, Thirst / waterCost);
            HealingFraction += Min(HealthRate * comfort, affordable);
            int healing = Min(int(HealingFraction), Min(MaxHealth - Health, int(Floor(affordable))));
            HealingFraction -= healing; Health += healing;
            Hunger = Max(0.0, Hunger - healing * foodCost); Thirst = Max(0.0, Thirst - healing * waterCost);
        }
        if (Air < MaxAir && MaxAir > 0)
        {
            double raw = double(Health) / MaxHealth <= CaelumConstants.HEALTH_BADLY_WOUNDED_THRESHOLD
                ? CaelumConstants.HEALTH_BADLY_WOUNDED_PERFORMANCE_MULTIPLIER
                : double(Health) / MaxHealth <= CaelumConstants.HEALTH_WOUNDED_THRESHOLD
                ? CaelumConstants.HEALTH_WOUNDED_PERFORMANCE_MULTIPLIER : 1.0;
            double performance = 1.0 - (1.0 - raw) * HealthPenalty;
            performance += (1.0 - performance) * (MaxAdrenaline > 0 ? Adrenaline / MaxAdrenaline : 0.0);
            double foodCost = CaelumConstants.AIR_FULL_RECOVERY_HUNGER_COST * costs / MaxAir;
            double waterCost = CaelumConstants.AIR_FULL_RECOVERY_THIRST_COST * costs / MaxAir;
            double gained = Min(Min(AirRate * performance * comfort, MaxAir - Air), Min(Hunger / foodCost, Thirst / waterCost));
            Air += gained; Hunger = Max(0.0, Hunger - gained * foodCost); Thirst = Max(0.0, Thirst - gained * waterCost);
        }
        ElapsedTics++;
    }

    void Simulate(int remainingWalkTics)
    {
        int day = CaelumJourneyRules.WALK_HOURS * CaelumWorldClock.TicsPerHour();
        int night = CaelumJourneyRules.SLEEP_HOURS * CaelumWorldClock.TicsPerHour();
        while (remainingWalkTics > 0 && Health > 0)
        {
            int leg = Min(day, remainingWalkTics);
            for (int t = 0; t < leg && Health > 0; t++) { Step(false); WalkTics++; }
            remainingWalkTics -= leg;
            if (remainingWalkTics <= 0 || Health <= 0) break;
            for (int t = 0; t < night && Health > 0; t++) { Step(true); SleepTics++; }
        }
    }
}

class CaelumJourneyPlan : Inventory
{
    bool Open;
    int ConnectionId, TravelMode, PlannedWalkTics, PlannedSleepTics;
    double SpeedKmh;
    String OriginMap;
    vector3 OriginPosition;
    CaelumJourneyModel Needed, Available;

    static CaelumJourneyPlan Get(CaelumPlayer user, bool create = false)
    {
        if (user == null) return null;
        let plan = CaelumJourneyPlan(user.FindInventory("CaelumJourneyPlan"));
        if (plan == null && create) plan = CaelumJourneyPlan(user.GiveInventoryType("CaelumJourneyPlan"));
        return plan;
    }

    bool Calculate(CaelumPlayer user, int id, int mode)
    {
        double speed = CaelumJourneyRules.WalkingKmh(user);
        double hours = speed > 0 ? CaelumJourneyRules.DistanceKm(id) / speed : 0;
        if (speed <= 0 || hours <= 0 || hours > CaelumJourneyRules.MAX_WALK_HOURS)
        { user.A_Print(StringTable.Localize("CA_JOURNEY_PACE", false)); return false; }
        ConnectionId = id; TravelMode = mode; SpeedKmh = speed; OriginMap = level.MapName;
        OriginPosition = user.Pos;
        PlannedWalkTics = Max(1, int(Ceil(hours * CaelumWorldClock.TicsPerHour() - 0.0000001)));
        PlannedSleepTics = CaelumJourneyRules.SleepCount(PlannedWalkTics) * 8 * CaelumWorldClock.TicsPerHour();
        Needed = new("CaelumJourneyModel"); Needed.Capture(user, true); Needed.Simulate(PlannedWalkTics);
        Available = new("CaelumJourneyModel"); Available.Capture(user, false); Available.Simulate(PlannedWalkTics);
        return true;
    }

    static bool Preview(CaelumPlayer user, int id, int mode)
    {
        String reason = CaelumJourneyRules.BlockReason(user);
        if (reason.Length() != 0) { user.A_Print(StringTable.Localize(reason, false)); return false; }
        let plan = Get(user, true);
        if (plan == null || !plan.Calculate(user, id, mode)) return false;
        plan.Open = true;
        user.Vel = (0,0,0);
        return true;
    }

    static void Cancel(CaelumPlayer user)
    { let plan = Get(user); if (plan != null) { plan.Open = false; plan.Needed = null; plan.Available = null; } }

    static bool Confirm(CaelumPlayer user)
    {
        let plan = Get(user);
        if (plan == null || !plan.Open || plan.Available == null || plan.OriginMap != level.MapName
            || (user.Pos - plan.OriginPosition).Length() > 64
            || !CaelumTravelService.CanDepart(user, plan.ConnectionId)) { Cancel(user); return false; }
        String reason = CaelumJourneyRules.BlockReason(user);
        if (reason.Length() != 0) { user.A_Print(StringTable.Localize(reason, false)); Cancel(user); return false; }
        // Ni un guardado ni el tiempo dedicado a leer permiten confirmar una
        // previsión obsoleta. Cambios materiales exigen ver los nuevos valores.
        let fresh = CaelumJourneyPlan(Actor.Spawn("CaelumJourneyPlan", user.Pos, NO_REPLACE));
        if (fresh == null) return false;
        if (!fresh.Calculate(user, plan.ConnectionId, plan.TravelMode)) { fresh.Destroy(); Cancel(user); return false; }
        bool changed = fresh.PlannedWalkTics != plan.PlannedWalkTics
            || fresh.Available.FoodSpent != plan.Available.FoodSpent
            || fresh.Available.WaterSpent != plan.Available.WaterSpent
            || Abs(fresh.Available.ContainerSpent - plan.Available.ContainerSpent) > 0.000001
            || (fresh.Available.Health <= 0) != (plan.Available.Health <= 0)
            || fresh.Available.FoodStock != plan.Available.FoodStock
            || fresh.Available.WaterStock != plan.Available.WaterStock
            || Abs(fresh.Available.ContainerStock - plan.Available.ContainerStock) > 0.000001;
        plan.SpeedKmh = fresh.SpeedKmh; plan.PlannedWalkTics = fresh.PlannedWalkTics; plan.PlannedSleepTics = fresh.PlannedSleepTics;
        plan.Needed = fresh.Needed; plan.Available = fresh.Available; fresh.Destroy();
        if (changed) { user.A_Print(StringTable.Localize("CA_JOURNEY_REVISED", false)); return false; }
        return CaelumTravelService.Commit(user, plan.ConnectionId, plan.TravelMode, plan);
    }

    void Apply(CaelumPlayer user)
    {
        Open = false;
        let model = Available;
        int food = model.FoodSpent, water = model.WaterSpent;
        double liters = model.ContainerSpent;
        Inventory item = user.Inv;
        while (item != null)
        {
            Inventory next = item.Inv;
            let ration = CaelumConsumableItem(item);
            if (ration != null && !ration.InMagicBox)
            {
                let container = CaelumWaterContainer(ration);
                if (container != null)
                {
                    double amount = Min(liters, container.WaterLiters);
                    container.WaterLiters -= amount; liters -= amount;
                }
                else
                {
                    int kind = ration.GetConsumableType();
                    int count = kind == CaelumConstants.CONSUMABLE_FOOD_RATION ? Min(food, ration.Amount)
                        : kind == CaelumConstants.CONSUMABLE_WATER_RATION ? Min(water, ration.Amount) : 0;
                    if (kind == CaelumConstants.CONSUMABLE_FOOD_RATION) food -= count;
                    if (kind == CaelumConstants.CONSUMABLE_WATER_RATION) water -= count;
                    if (count > 0) { ration.Amount -= count; if (ration.Amount == 0) ration.Destroy(); }
                }
            }
            item = next;
        }
        user.CurrentHunger = model.Hunger; user.CurrentThirst = model.Thirst; user.CurrentSleep = model.Sleep;
        user.CurrentAir = model.Air; user.CurrentAnima = model.Anima; user.CurrentLucidity = model.Lucidity;
        user.CurrentAdrenaline = model.Adrenaline; user.health = model.Health; user.player.health = model.Health;
        user.NaturalHealthRegenerationAccumulator = model.HealingFraction;
        user.SurvivalDamageAccumulator = model.DamageFraction;
        double seconds = double(model.ElapsedTics) / TICRATE;
        user.IlluminationRemaining = Max(0.0, user.IlluminationRemaining - seconds);
        user.StaffCastCooldownRemaining = Max(0.0, user.StaffCastCooldownRemaining - seconds);
        user.EquippedWeaponCooldownRemaining = Max(0.0, user.EquippedWeaponCooldownRemaining - seconds);
        user.ClassSleepCooldownRemaining = Max(0.0, user.ClassSleepCooldownRemaining - seconds);
        user.CombatChannelCooldownRemaining = Max(0.0, user.CombatChannelCooldownRemaining - seconds);
        user.HUDAbilitySuccessRemaining = Max(0.0, user.HUDAbilitySuccessRemaining - seconds);
        user.PainImmobilizationRemaining = Max(0.0, user.PainImmobilizationRemaining - seconds);
        user.UpdateSurvivalStates(); user.UpdateHealthStateEffects(); user.UpdateLucidityState();
        user.LucidityPhysicalStunRemaining = model.Stun;
        // Una porción comenzada casi al llegar conserva sus pulsos pendientes.
        if (model.Health > 0 && model.FoodEffectTics > 0)
        {
            let power = CaelumRegenerationPower(user.GiveInventoryType("CaelumHungerRegeneration"));
            if (power != null) { power.EffectTics = model.FoodEffectTics; power.PulseTics = model.FoodPulseTics; power.FoodRecoveryPerPulse = model.FoodPulse; }
        }
        if (model.Health > 0 && model.WaterEffectTics > 0)
        {
            let power = CaelumRegenerationPower(user.GiveInventoryType("CaelumThirstRegeneration"));
            if (power != null) { power.EffectTics = model.WaterEffectTics; power.PulseTics = model.WaterPulseTics; power.WaterRecoveryPerPulse = model.WaterPulse; }
        }
        user.OnNativeInventoryChanged();
        CaelumWorldClock.Get(user, true).AdvanceTics(model.ElapsedTics);
        CaelumWeatherState.Sync(user, CaelumWorldClock.Get(user), CaelumCalendarState.Get(user));
    }

    Default
    {
        Inventory.MaxAmount 1; Inventory.InterHubAmount 1;
        +INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE -INVENTORY.INVBAR
    }
    States { Spawn: TNT1 A -1; Stop; }
}
