// #117: operaciones sin estado propio; el jugador conserva los datos serializados.
// El coordinador mantiene el orden de llamadas y la inicialización explícita.
class CaelumPlayerResources : Object play
{
    static void AddAdrenaline(CaelumPlayer user, double amount)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return;
        if (user.DerivedStats != null)
        {
            user.CurrentAdrenaline = Clamp(
                user.CurrentAdrenaline + Max(0.0, amount),
                0.0,
                user.DerivedStats.MaximumAdrenaline
            );
        }
    }

    static void AddCombatAdrenaline(CaelumPlayer user, double amount, int eventType = CaelumConstants.ADRENALINE_EVENT_OTHER)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return;
        user.LastAdrenalineEvent = eventType;
        user.LastAdrenalineBaseGain = Max(0.0, amount);
        user.LastAdrenalineFinalGain = user.LastAdrenalineBaseGain
            * user.HealthAdrenalineGainMultiplier;
        user.AddAdrenaline(user.LastAdrenalineFinalGain);
    }

    static void MarkCombatActivity(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return;
        CaelumRestState.Interrupt(user, "CA_REST_COMBAT");
        user.CombatTimeRemaining = CaelumConstants.COMBAT_TIMEOUT_SECONDS;
    }

    static void UpdateAdrenalineDecay(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return;
        if (!user.AdrenalineResourceInitialized)
        {
            user.CombatTimeRemaining = Max(0.0, user.CombatTimeRemaining);
            return;
        }

        if (user.CombatTimeRemaining > 0.0)
        {
            user.CombatTimeRemaining = Max(
                0.0,
                user.CombatTimeRemaining - 1.0 / TICRATE
            );
            return;
        }

        if (user.CurrentAdrenaline <= 0.0) { return; }
        user.CurrentAdrenaline = Max(
            0.0,
            user.CurrentAdrenaline
                - CaelumConstants.ADRENALINE_DECAY_PER_SECOND / TICRATE
        );
    }

    static void ApplyConsumableRegenerationPulse(CaelumPlayer user, int consumableType, double foodRecovery = -1)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return;
        if (user.player == null || user.player.playerstate != PST_LIVE
            || user.DerivedStats == null)
        {
            return;
        }
        double pulseRatio =
            CaelumConstants.CONSUMABLE_REGENERATION_PERCENT_PER_SECOND;
        switch (consumableType)
        {
            case CaelumConstants.CONSUMABLE_LIFE_POTION:
            {
                int healing = Max(1, int(user.CaelumMaximumHealth * pulseRatio + 0.5));
                user.health = Min(user.CaelumMaximumHealth, user.health + healing);
                user.player.health = user.health;
                user.UpdateHealthStateEffects();
                break;
            }
            case CaelumConstants.CONSUMABLE_ANIMA_POTION:
                user.CurrentAnima = Min(
                    user.DerivedStats.MaximumAnima,
                    user.CurrentAnima + user.DerivedStats.MaximumAnima * pulseRatio
                );
                break;
            case CaelumConstants.CONSUMABLE_ENERGY_DRINK:
                user.CurrentAir = Min(
                    user.DerivedStats.MaximumAir,
                    user.CurrentAir + user.DerivedStats.MaximumAir * pulseRatio
                );
                user.CurrentSleep = Min(
                    CaelumConstants.SURVIVAL_MAXIMUM,
                    user.CurrentSleep
                        + CaelumConstants.SURVIVAL_MAXIMUM * pulseRatio
                );
                user.UpdateAirStateEffects();
                user.UpdateSurvivalStates();
                break;
            case CaelumConstants.CONSUMABLE_FOOD_RATION:
            {
                // El Powerup guarda la dosis al empezar; llamadas directas
                // nuevas usan la misma referencia de masa que una ración.
                if (foodRecovery < 0) foodRecovery = CaelumConstants.SURVIVAL_MAXIMUM
                    * pulseRatio * CaelumConstants.RATION_REFERENCE_MASS / Max(1, user.DerivedStats.BaseMass);
                double recovered=Min(CaelumConstants.SURVIVAL_MAXIMUM-user.CurrentHunger,
                    foodRecovery);
                recovered=Max(0.0,recovered);
                user.CurrentHunger+=recovered;
                // Digestión: sólo el hambre efectivamente saciada tiene coste.
                user.CurrentSleep=Max(0.0,user.CurrentSleep-recovered/4.0);
                if(user.CurrentHunger>=CaelumConstants.SURVIVAL_MAXIMUM)CaelumDiningSession.Sated(user,false);
                user.UpdateSurvivalStates();
                break;
            }
            case CaelumConstants.CONSUMABLE_WATER_RATION:
                user.CurrentThirst = Min(
                    CaelumConstants.SURVIVAL_MAXIMUM,
                    user.CurrentThirst
                        + CaelumConstants.SURVIVAL_MAXIMUM * pulseRatio
                );
                user.UpdateSurvivalStates();
                break;
        }
        user.PersistCharacterState();
    }

    static void ApplyLocalizedLucidityLoss(CaelumPlayer user, int naturalVulnerabilityGrade, int effectiveVulnerabilityGrade, bool criticalHit, double defenseRatio)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return;
        user.LastLocalizedLucidityLoss = 0.0;
        if (naturalVulnerabilityGrade != CaelumConstants.VULNERABILITY_CRITICAL_POINT
            || user.DerivedStats == null)
        {
            return;
        }

        double criticalFactor = 1.0;
        if (criticalHit)
        {
            double normalMultiplier = user.GetVulnerabilityMultiplier(
                effectiveVulnerabilityGrade,
                false
            );
            double criticalMultiplier = user.GetVulnerabilityMultiplier(
                effectiveVulnerabilityGrade,
                true
            );
            if (normalMultiplier > 0.0)
            {
                criticalFactor = criticalMultiplier / normalMultiplier;
            }
        }

        user.LastLocalizedLucidityLoss = Min(
            user.CurrentLucidity,
            CaelumConstants.CRITICAL_POINT_BASE_LUCIDITY_LOSS
                * criticalFactor
                * (1.0 - Clamp(defenseRatio, 0.0, 1.0))
                * user.DerivedStats.LucidityLossMultiplier
                * user.GetLuciditySleepDebuffMultiplier()
        );
        user.CurrentLucidity = Max(0.0, user.CurrentLucidity - user.LastLocalizedLucidityLoss);
        user.UpdateLucidityState();
    }

    static double GetLuciditySleepDebuffMultiplier(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanRead(user)) return 0;
        double rawMultiplier = 1.0;
        if (user.SleepState == CaelumConstants.SURVIVAL_STATE_CRITICAL)
        {
            rawMultiplier = CaelumConstants.LUCIDITY_SLEEP_CRITICAL_INTENSITY_MULTIPLIER;
        }
        else if (user.SleepState == CaelumConstants.SURVIVAL_STATE_LOW)
        {
            rawMultiplier = CaelumConstants.LUCIDITY_SLEEP_LOW_INTENSITY_MULTIPLIER;
        }

        double patienceMultiplier = 1.0;
        if (user.DerivedStats != null)
        {
            patienceMultiplier = user.DerivedStats.HealthPenaltyMultiplier;
        }
        return 1.0 + (rawMultiplier - 1.0) * patienceMultiplier;
    }

    static void UpdateLucidityState(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return;
        int previousState = user.LucidityState;
        double ratio = user.CurrentLucidity / CaelumConstants.MAXIMUM_LUCIDITY;

        if (ratio <= CaelumConstants.LUCIDITY_STUNNED_THRESHOLD)
        {
            user.LucidityState = CaelumConstants.LUCIDITY_STATE_STUNNED;
        }
        else if (ratio <= CaelumConstants.LUCIDITY_DIZZY_THRESHOLD)
        {
            user.LucidityState = CaelumConstants.LUCIDITY_STATE_DIZZY;
        }
        else
        {
            user.LucidityState = CaelumConstants.LUCIDITY_STATE_NORMAL;
        }

        user.UpdateLucidityAccuracyEffects();

        // Trigger once only when entering the critical state from above. The
        // timer does not restart merely because lucidity remains at or below
        // ten percent, and it persists through ordinary saves with the player.
        if (previousState != CaelumConstants.LUCIDITY_STATE_STUNNED
            && user.LucidityState == CaelumConstants.LUCIDITY_STATE_STUNNED)
        {
            user.LucidityPhysicalStunRemaining =
                CaelumConstants.LUCIDITY_PHYSICAL_STUN_SECONDS
                    * user.GetLuciditySleepDebuffMultiplier();
        }
    }

    static void UpdateLucidityAccuracyEffects(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return;
        user.LucidityAccuracyMultiplier = user.LucidityState
            == CaelumConstants.LUCIDITY_STATE_NORMAL
            ? 1.0
            : CaelumConstants.LUCIDITY_DIZZY_ACCURACY_MULTIPLIER;

        if (user.DerivedStats == null)
        {
            user.EffectivePhysicalAccuracyPercent = 0.0;
            user.EffectiveMagicalAccuracyPercent = 0.0;
            return;
        }

        user.EffectivePhysicalAccuracyPercent = user.DerivedStats.PhysicalAccuracyPercent
            * user.LucidityAccuracyMultiplier
            * (user.ElementalStatus != null
                ? user.ElementalStatus.GetAccuracyMultiplier() : 1.0);
        user.EffectiveMagicalAccuracyPercent = user.DerivedStats.MagicalAccuracyPercent
            * user.LucidityAccuracyMultiplier
            * (user.ElementalStatus != null
                ? user.ElementalStatus.GetAccuracyMultiplier() : 1.0);
    }

    static void UpdateLucidityPhysicalStun(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return;
        if (user.LucidityPhysicalStunRemaining > 0.0)
        {
            user.LucidityPhysicalStunRemaining = Max(
                0.0,
                user.LucidityPhysicalStunRemaining - 1.0 / TICRATE
            );
        }
    }

    static void UpdatePainImmobilization(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return;
        if (user.PainImmobilizationRemaining > 0.0)
        {
            user.PainImmobilizationRemaining = Max(
                0.0,
                user.PainImmobilizationRemaining - 1.0 / TICRATE
            );
        }
    }

    static int CalculateSurvivalState(CaelumPlayer user, double currentValue)
    {
        double ratio = currentValue / CaelumConstants.SURVIVAL_MAXIMUM;
        if (ratio <= CaelumConstants.SURVIVAL_CRITICAL_THRESHOLD)
        {
            return CaelumConstants.SURVIVAL_STATE_CRITICAL;
        }
        if (ratio <= CaelumConstants.SURVIVAL_LOW_THRESHOLD)
        {
            return CaelumConstants.SURVIVAL_STATE_LOW;
        }
        return CaelumConstants.SURVIVAL_STATE_NORMAL;
    }

    static double GetSurvivalStateMultiplier(CaelumPlayer user, int state)
    {
        if (state == CaelumConstants.SURVIVAL_STATE_CRITICAL)
        {
            return CaelumConstants.SURVIVAL_CRITICAL_PERFORMANCE_MULTIPLIER;
        }
        if (state == CaelumConstants.SURVIVAL_STATE_LOW)
        {
            return CaelumConstants.SURVIVAL_LOW_PERFORMANCE_MULTIPLIER;
        }
        return 1.0;
    }

    static bool IsSubmergedInPotableWater(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanRead(user)) return false;
        return user.WaterLevel >= 3
            && user.CurSector != null
            && user.CurSector.GetUDMFInt('user_ca_potable_water') != 0;
    }

    static void UpdateSurvivalResources(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return;
        if (!user.SurvivalResourcesInitialized || user.DerivedStats == null)
        {
            return;
        }

        // Corrige también los factores serializados de partidas anteriores,
        // sin reiniciar reservas ni reconstruir el perfil completo.
        user.DerivedStats.RefreshSurvivalLossMultipliers(user.Attributes);
        CaelumRestState.Validate(user);
        double restFactor = CaelumRestState.ResourceFactor(user);
        user.CurrentHunger = Max(0.0, user.CurrentHunger
            - CaelumConstants.SURVIVAL_MAXIMUM
            / (CaelumConstants.HUNGER_EMPTY_GAME_HOURS
                * CaelumWorldClock.SecondsPerGameHour(level.MapName))
            * user.DerivedStats.HungerThirstLossMultiplier / restFactor / TICRATE);
        // La piscina hidrata directamente y permite llevar agua en recipientes.
        for (Inventory cursor = user.Inv; cursor != null; cursor = cursor.Inv)
        {
            let container = CaelumWaterContainer(cursor);
            if (container != null) container.ObserveImmersion(user);
        }
        if (user.IsSubmergedInPotableWater())
        {
            user.CurrentThirst = Min(
                CaelumConstants.SURVIVAL_MAXIMUM,
                user.CurrentThirst
                    + CaelumConstants.SURVIVAL_MAXIMUM
                    * CaelumConstants.POTABLE_WATER_THIRST_RECOVERY_RATIO_PER_SECOND
                    / TICRATE
            );
        }
        else
        {
            user.CurrentThirst = Max(0.0, user.CurrentThirst
                - CaelumConstants.SURVIVAL_MAXIMUM
                / (CaelumConstants.THIRST_EMPTY_GAME_HOURS
                    * CaelumWorldClock.SecondsPerGameHour(level.MapName))
                * user.DerivedStats.HungerThirstLossMultiplier / restFactor / TICRATE);
        }
        // Dormir reemplaza la pérdida pasiva de Sueño por recuperación neta.
        // Esperar conserva la pérdida de Sueño; el soporte sólo modifica hambre/sed.
        CaelumRestState.Validate(user);
        if (CaelumSleepRules.IsSleeping(user))
        {
            if (user.ForcedSleepTics > 0 || CaelumRestState.HasPendingTic(user))
                user.CurrentSleep = CaelumRestRules.RecoverSleep(user.CurrentSleep, CaelumWorldClock.MapTimeScale(level.MapName));
        }
        else
            user.CurrentSleep = Max(0.0, user.CurrentSleep
                - CaelumConstants.SURVIVAL_MAXIMUM
                / (CaelumConstants.SLEEP_EMPTY_GAME_HOURS
                    * CaelumWorldClock.SecondsPerGameHour(level.MapName))
                * user.DerivedStats.SleepLossMultiplier / TICRATE);
        user.UpdateSurvivalStates();
    }

    static void UpdateSurvivalStates(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return;
        user.HungerState = user.CalculateSurvivalState(user.CurrentHunger);
        user.ThirstState = user.CalculateSurvivalState(user.CurrentThirst);
        user.SleepState = user.CalculateSurvivalState(user.CurrentSleep);
        user.LuciditySleepDebuffMultiplier = user.GetLuciditySleepDebuffMultiplier();

        user.SurvivalRawPerformanceMultiplier = user.GetSurvivalStateMultiplier(user.HungerState)
            * user.GetSurvivalStateMultiplier(user.ThirstState)
            * user.GetSurvivalStateMultiplier(user.SleepState);

        // Adrenaline ignores the same percentage of the missing performance
        // as its current share of maximum. Example: raw x0.50 with 50%
        // adrenaline becomes x0.75.
        user.AdrenalinePenaltyIgnoreRatio = 0.0;
        if (user.DerivedStats != null && user.DerivedStats.MaximumAdrenaline > 0.0)
        {
            user.AdrenalinePenaltyIgnoreRatio = Clamp(
                user.CurrentAdrenaline / user.DerivedStats.MaximumAdrenaline,
                0.0,
                1.0
            );
        }
        user.SurvivalPerformanceMultiplier = user.SurvivalRawPerformanceMultiplier
            + (1.0 - user.SurvivalRawPerformanceMultiplier)
            * user.AdrenalinePenaltyIgnoreRatio;
        user.UpdateEffectiveOffensiveDamageMultiplier();
    }

    static void UpdateHealthStateEffects(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return;
        double healthRatio = 1.0;
        if (user.CaelumMaximumHealth > 0)
        {
            healthRatio = Clamp(double(user.health) / user.CaelumMaximumHealth, 0.0, 1.0);
        }

        double rawIntensityMultiplier = 1.0;
        if (healthRatio <= CaelumConstants.HEALTH_BADLY_WOUNDED_THRESHOLD)
        {
            user.HealthState = CaelumConstants.HEALTH_STATE_BADLY_WOUNDED;
            user.HealthRawPerformanceMultiplier =
                CaelumConstants.HEALTH_BADLY_WOUNDED_PERFORMANCE_MULTIPLIER;
            rawIntensityMultiplier =
                CaelumConstants.HEALTH_BADLY_WOUNDED_INTENSITY_MULTIPLIER;
        }
        else if (healthRatio <= CaelumConstants.HEALTH_WOUNDED_THRESHOLD)
        {
            user.HealthState = CaelumConstants.HEALTH_STATE_WOUNDED;
            user.HealthRawPerformanceMultiplier =
                CaelumConstants.HEALTH_WOUNDED_PERFORMANCE_MULTIPLIER;
            rawIntensityMultiplier =
                CaelumConstants.HEALTH_WOUNDED_INTENSITY_MULTIPLIER;
        }
        else
        {
            user.HealthState = CaelumConstants.HEALTH_STATE_NORMAL;
            user.HealthRawPerformanceMultiplier = 1.0;
        }

        double adrenalineRatio = 0.0;
        if (user.DerivedStats != null && user.DerivedStats.MaximumAdrenaline > 0.0)
        {
            adrenalineRatio = Clamp(
                user.CurrentAdrenaline / user.DerivedStats.MaximumAdrenaline,
                0.0,
                1.0
            );
        }

        user.HealthPatienceMitigationMultiplier = 1.0;
        if (user.DerivedStats != null)
        {
            user.HealthPatienceMitigationMultiplier =
                user.DerivedStats.HealthPenaltyMultiplier;
        }
        user.HealthPatienceMitigatedPerformanceMultiplier = 1.0
            - (1.0 - user.HealthRawPerformanceMultiplier)
                * user.HealthPatienceMitigationMultiplier;
        user.HealthPerformanceMultiplier = user.HealthPatienceMitigatedPerformanceMultiplier
            + (1.0 - user.HealthPatienceMitigatedPerformanceMultiplier)
                * adrenalineRatio;
        user.HealthPainMultiplier = 1.0
            + (rawIntensityMultiplier - 1.0)
                * user.HealthPatienceMitigationMultiplier
                * (1.0 - adrenalineRatio);
        user.HealthAdrenalineGainMultiplier = rawIntensityMultiplier;
        user.UpdateEffectiveOffensiveDamageMultiplier();
    }

    static void UpdateEffectiveOffensiveDamageMultiplier(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return;
        user.EffectiveOffensiveDamageMultiplier = Clamp(
            user.HealthPerformanceMultiplier * user.SurvivalPerformanceMultiplier,
            0.0,
            1.0
        );
    }

    static void ApplyCriticalSurvivalDamage(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return;
        if (user.player == null || user.player.playerstate != PST_LIVE || user.health <= 0)
        {
            return;
        }

        int criticalResourceCount = 0;
        if (user.HungerState == CaelumConstants.SURVIVAL_STATE_CRITICAL) criticalResourceCount++;
        if (user.ThirstState == CaelumConstants.SURVIVAL_STATE_CRITICAL) criticalResourceCount++;
        // La fatiga deja de producir daño mientras se duerme; hambre y sed
        // siguen siendo peligrosas. Los demás efectos críticos no se borran.
        if (user.SleepState == CaelumConstants.SURVIVAL_STATE_CRITICAL
            && !CaelumSleepRules.IsSleeping(user)) criticalResourceCount++;
        if (criticalResourceCount <= 0)
        {
            // Recuperar las reservas elimina también el daño parcial pendiente.
            user.SurvivalDamageAccumulator = 0.0;
            return;
        }

        double baseDamagePerSecond = user.CaelumMaximumHealth
            / CaelumConstants.HEALTH_BASE_RECOVERY_REAL_SECONDS;
        user.SurvivalDamageAccumulator += baseDamagePerSecond
            * criticalResourceCount / TICRATE;
        int wholeDamage = int(user.SurvivalDamageAccumulator);
        if (wholeDamage <= 0) return;

        user.SurvivalDamageAccumulator -= wholeDamage;
        user.health -= wholeDamage;
        user.player.health = user.health;
        CaelumRestState.Interrupt(user, "CA_REST_NEEDS");

        // Direct health loss deliberately bypasses armor and this class's
        // ordinary-damage adrenaline gain. Death still uses GZDoom's pipeline.
        if (user.health <= 0)
        {
            user.health = 0;
            user.player.health = 0;
            user.Die(user, user, 0, 'CaelumSurvival');
        }
    }

    static void ApplyNaturalHealthRegeneration(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return;
        if (user.player == null
            || user.player.playerstate != PST_LIVE
            || user.health <= 0
            || user.health >= user.CaelumMaximumHealth
            || user.DerivedStats == null)
        {
            user.NaturalHealthRegenerationAccumulator = 0.0;
            return;
        }

        if (user.HungerState == CaelumConstants.SURVIVAL_STATE_CRITICAL
            || user.ThirstState == CaelumConstants.SURVIVAL_STATE_CRITICAL
            || user.SleepState == CaelumConstants.SURVIVAL_STATE_CRITICAL)
        {
            user.NaturalHealthRegenerationAccumulator = 0.0;
            return;
        }

        // Constitución divide también el coste por vida recuperada. No se
        // reaplica la masa: el coste base ya es proporcional a la vida máxima.
        double restFactor = CaelumRestState.ResourceFactor(user);
        // Recuperar F veces más y gastar 1/F por tiempo requiere coste por
        // unidad recuperada dividido por F²; las reservas siguen limitando.
        double consumptionMultiplier =
            user.DerivedStats.GetHungerThirstConsumptionMultiplier(user.Attributes)
                / (restFactor * restFactor);
        double hungerCostPerHealth = 100.0 * consumptionMultiplier / user.CaelumMaximumHealth;
        double thirstCostPerHealth = 50.0 * consumptionMultiplier / user.CaelumMaximumHealth;
        double affordableHealth = Min(
            user.CurrentHunger / hungerCostPerHealth,
            user.CurrentThirst / thirstCostPerHealth
        );
        if (affordableHealth <= 0.0) return;

        user.NaturalHealthRegenerationAccumulator += Min(
            user.DerivedStats.HealthRegenerationPerSecond * restFactor / TICRATE,
            affordableHealth
        );
        int wholeHealing = int(user.NaturalHealthRegenerationAccumulator);
        wholeHealing = Min(wholeHealing, Min(user.CaelumMaximumHealth - user.health, int(Floor(affordableHealth))));
        if (wholeHealing <= 0) return;

        user.NaturalHealthRegenerationAccumulator -= wholeHealing;
        user.health += wholeHealing;
        user.player.health = user.health;
        user.CurrentHunger = Max(0.0, user.CurrentHunger - wholeHealing * hungerCostPerHealth);
        user.CurrentThirst = Max(0.0, user.CurrentThirst - wholeHealing * thirstCostPerHealth);
        user.UpdateSurvivalStates();
    }

    static void ApplyAirRegeneration(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return;
        if (!user.AirResourceInitialized
            || user.DerivedStats == null
            || user.WaterLevel >= 3
            || user.UnderwaterAirRecoveryDebt > 0.0
            || user.UnderwaterAirRecoveryTicsRemaining > 0
            || user.UnderwaterAirRecoveryAppliedThisTick
            || user.IsSpendingRunningAir
            || user.DebugShieldBlocking
            || user.CurrentAir >= user.DerivedStats.MaximumAir
            || user.DerivedStats.MaximumAir <= 0.0)
        {
            return;
        }

        double restFactor = CaelumRestState.ResourceFactor(user);
        // Recuperar F veces más y gastar 1/F por tiempo requiere coste por
        // unidad recuperada dividido por F²; las reservas siguen limitando.
        double consumptionMultiplier =
            user.DerivedStats.GetHungerThirstConsumptionMultiplier(user.Attributes)
                / (restFactor * restFactor);
        double hungerCostPerAir =
            CaelumConstants.AIR_FULL_RECOVERY_HUNGER_COST
            * consumptionMultiplier / user.DerivedStats.MaximumAir;
        double thirstCostPerAir =
            CaelumConstants.AIR_FULL_RECOVERY_THIRST_COST
            * consumptionMultiplier / user.DerivedStats.MaximumAir * CaelumThermalEffects.HeatCost(user);
        double affordableAir = Min(
            user.CurrentHunger / hungerCostPerAir,
            user.CurrentThirst / thirstCostPerAir
        );
        if (affordableAir <= 0.0) return;

        double recoveredAir = Min(
            user.DerivedStats.AirRegenerationPerSecond
                * user.HealthPerformanceMultiplier * restFactor / TICRATE,
            user.DerivedStats.MaximumAir - user.CurrentAir
        );
        recoveredAir = Min(recoveredAir, affordableAir);
        if (recoveredAir <= 0.0) return;

        user.CurrentAir += recoveredAir;
        CaelumMainM00RonnieTrial.RecordAirLesson(user, recoveredAir, false);
        user.CurrentHunger = Max(
            0.0,
            user.CurrentHunger - recoveredAir * hungerCostPerAir
        );
        user.CurrentThirst = Max(
            0.0,
            user.CurrentThirst - recoveredAir * thirstCostPerAir
        );
        user.UpdateSurvivalStates();
    }

    static bool HasUnderwaterAirExemption(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanRead(user)) return false;
        return user.bInvulnerable
            || user.player == null
            || (user.player.cheats & (CF_GODMODE | CF_NOCLIP2))
            || (user.player.cheats & CF_GODMODE2);
    }

    static double GetUnderwaterBaseAirCostPerSecond(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanRead(user)) return 0;
        int completedSeconds = Max(0, (user.UnderwaterNoBreathTics - 1) / TICRATE);
        return Min(
            CaelumConstants.UNDERWATER_AIR_MAX_COST_PER_SECOND,
            CaelumConstants.UNDERWATER_AIR_INITIAL_COST_PER_SECOND
                + completedSeconds
                * CaelumConstants.UNDERWATER_AIR_COST_INCREASE_PER_SECOND
        );
    }

    static void RecoverUnderwaterAirDebt(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return;
        user.UnderwaterAirRecoveryAppliedThisTick = false;
        if (user.UnderwaterAirRecoveryDebt <= 0.0
            || user.UnderwaterAirRecoveryTicsRemaining <= 0
            || user.DerivedStats == null
            || user.CurrentAir >= user.DerivedStats.MaximumAir)
        {
            if (user.UnderwaterAirRecoveryDebt <= 0.0
                || user.CurrentAir >= user.DerivedStats.MaximumAir)
            {
                user.UnderwaterAirRecoveryDebt = 0.0;
                user.UnderwaterAirRecoveryTicsRemaining = 0;
            }
            return;
        }

        // El descanso también acelera la recuperación respiratoria pendiente.
        // El contador conserva unidades de la tasa base para poder cancelar
        // o cambiar de soporte sin reiniciar ni inventar aire por devolver.
        int restFactor = CaelumRestState.ResourceFactor(user);
        double recoveredAir = Min(user.UnderwaterAirRecoveryDebt, Min(
            user.UnderwaterAirRecoveryDebt * restFactor
                / Max(1, user.UnderwaterAirRecoveryTicsRemaining),
            user.DerivedStats.MaximumAir - user.CurrentAir
        ));
        user.CurrentAir += recoveredAir;
        user.UnderwaterAirRecoveryDebt = Max(
            0.0, user.UnderwaterAirRecoveryDebt - recoveredAir
        );
        user.UnderwaterAirRecoveryTicsRemaining = Max(0, user.UnderwaterAirRecoveryTicsRemaining-restFactor);
        user.UnderwaterAirRecoveryAppliedThisTick = recoveredAir > 0.0;

        if (user.UnderwaterAirRecoveryTicsRemaining <= 0
            || user.UnderwaterAirRecoveryDebt <= 0.000001
            || user.CurrentAir >= user.DerivedStats.MaximumAir)
        {
            user.UnderwaterAirRecoveryDebt = 0.0;
            user.UnderwaterAirRecoveryTicsRemaining = 0;
        }
        CaelumMainM00RonnieTrial.RecordSwimLesson(user, recoveredAir, false);
    }

    static void UpdateUnderwaterAirForState(CaelumPlayer user, bool withoutOxygen)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return;
        if (!user.AirResourceInitialized
            || user.DerivedStats == null
            || user.player == null
            || user.player.playerstate != PST_LIVE)
        {
            user.UnderwaterWithoutOxygen = false;
            user.UnderwaterAirRecoveryAppliedThisTick = false;
            user.UnderwaterNoBreathTics = 0;
            user.UnderwaterDrowningTics = 0;
            user.UnderwaterCurrentBaseCostPerSecond =
                CaelumConstants.UNDERWATER_AIR_INITIAL_COST_PER_SECOND;
            return;
        }

        user.UnderwaterWithoutOxygen = withoutOxygen;
        if (!user.UnderwaterWithoutOxygen)
        {
            user.UnderwaterNoBreathTics = 0;
            user.UnderwaterDrowningTics = 0;
            user.UnderwaterCurrentBaseCostPerSecond =
                CaelumConstants.UNDERWATER_AIR_INITIAL_COST_PER_SECOND;

            if (user.UnderwaterAirRecoveryDebt > 0.0
                && user.UnderwaterAirRecoveryTicsRemaining <= 0)
            {
                user.UnderwaterAirRecoveryTicsRemaining =
                    CaelumConstants.UNDERWATER_AIR_RECOVERY_SECONDS * TICRATE;
            }
            user.RecoverUnderwaterAirDebt();
            return;
        }

        // Volver a sumergirse pausa la devolución; la deuda acumulada se
        // conserva y se suma a cualquier pérdida submarina nueva.
        user.UnderwaterAirRecoveryAppliedThisTick = false;
        user.UnderwaterAirRecoveryTicsRemaining = 0;

        if (user.HasUnderwaterAirExemption())
        {
            user.UnderwaterNoBreathTics = 0;
            user.UnderwaterDrowningTics = 0;
            user.UnderwaterCurrentBaseCostPerSecond =
                CaelumConstants.UNDERWATER_AIR_INITIAL_COST_PER_SECOND;
            return;
        }

        user.UnderwaterNoBreathTics++;
        user.UnderwaterCurrentBaseCostPerSecond =
            user.GetUnderwaterBaseAirCostPerSecond();

        if (user.CurrentAir > 0.0)
        {
            double underwaterAirCost =
                user.UnderwaterCurrentBaseCostPerSecond
                * user.DerivedStats.AirConsumptionMultiplier
                / TICRATE;
            double removedAir = Min(user.CurrentAir, underwaterAirCost);
            user.CurrentAir -= removedAir;
            user.UnderwaterAirRecoveryDebt += removedAir;
            user.UnderwaterDrowningTics = 0;
            CaelumMainM00RonnieTrial.RecordSwimLesson(user, removedAir, true);
            return;
        }

        user.UnderwaterDrowningTics++;
        if ((user.UnderwaterDrowningTics
                % CaelumConstants.DROWNING_DAMAGE_INTERVAL_TICS) != 0)
        {
            return;
        }

        int drowningSecond = Max(1, user.UnderwaterDrowningTics / TICRATE);
        double drowningHealthPercent = Min(
            CaelumConstants.DROWNING_MAX_HEALTH_PERCENT_PER_SECOND,
            CaelumConstants.DROWNING_INITIAL_HEALTH_PERCENT_PER_SECOND
                + (drowningSecond - 1)
                    * CaelumConstants.DROWNING_HEALTH_PERCENT_INCREASE_PER_SECOND
        );
        int drowningDamage = Max(
            1,
            int(user.CaelumMaximumHealth * drowningHealthPercent / 100.0 + 0.5)
        );
        user.DamageMobj(
            null,
            null,
            drowningDamage,
            'Drowning',
            DMG_NO_ARMOR,
            user.Angle
        );
    }

    static void UpdateUnderwaterAir(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return;
        user.UpdateUnderwaterAirForState(user.WaterLevel >= 3);
    }

    static void ConsumeJumpAir(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return;
        if (user.DerivedStats == null)
        {
            return;
        }

        double finalCost = CaelumConstants.JUMP_AIR_COST
            * user.DerivedStats.AirConsumptionMultiplier;
        user.CurrentAir = Max(0.0, user.CurrentAir - finalCost * CaelumThermalEffects.HeatCost(user));
        user.UpdateAirStateEffects();
    }

    static double GetAirRatio(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanRead(user)) return 0;
        if (user.DerivedStats == null || user.DerivedStats.MaximumAir <= 0.0)
        {
            return 0.0;
        }

        return user.CurrentAir / user.DerivedStats.MaximumAir;
    }

    static void UpdateAirStateEffects(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return;
        double ratio = user.GetAirRatio();

        if (ratio <= CaelumConstants.AIR_BREATHLESS_THRESHOLD)
        {
            user.AirState = CaelumConstants.AIR_STATE_BREATHLESS;
            user.AirStatePerformanceMultiplier = CaelumConstants.BREATHLESS_PERFORMANCE_MULTIPLIER;
        }
        else if (ratio <= CaelumConstants.AIR_TIRED_THRESHOLD)
        {
            user.AirState = CaelumConstants.AIR_STATE_TIRED;
            user.AirStatePerformanceMultiplier = CaelumConstants.TIRED_PERFORMANCE_MULTIPLIER;
        }
        else
        {
            user.AirState = CaelumConstants.AIR_STATE_NORMAL;
            user.AirStatePerformanceMultiplier = 1.0;
        }

        // El texto "sin oxígeno" describe la imposibilidad de respirar. Las
        // penalizaciones de rendimiento continúan dependiendo del Aire real.
        if (user.UnderwaterWithoutOxygen)
        {
            user.AirState = CaelumConstants.AIR_STATE_NO_OXYGEN;
        }

        if (user.DerivedStats != null)
        {
            // La penalización de carga depende únicamente del porcentaje de
            // capacidad usado. 0% = 100% rendimiento; 50% = 50%;
            // 100% o más = 0%. La masa corporal absoluta no interviene.
            double loadPerformanceMultiplier = 1.0 - Clamp(
                user.DerivedStats.LoadRatio, 0.0, 1.0
            );

            user.EffectiveEvasionChance = user.DerivedStats.BaseEvasionChance
                * loadPerformanceMultiplier
                * user.AirStatePerformanceMultiplier
                * user.HealthPerformanceMultiplier;

            user.EffectiveMovementPercent = user.DerivedStats.BaseMovementPercent
                * loadPerformanceMultiplier
                * user.AirStatePerformanceMultiplier
                * user.SurvivalPerformanceMultiplier
                * user.HealthPerformanceMultiplier;

            // El salto mantiene sqrt(Tipo 1 de Agilidad), pero la penalización
            // por carga usa la misma regla porcentual nueva que el movimiento.
            double jumpAgilityTypeOnePercent =
                user.DerivedStats.CalculateType1Percent(user.Attributes.Agility);
            double jumpAgilityFactor = Sqrt(
                Max(0.0, jumpAgilityTypeOnePercent / 100.0)
            );
            user.EffectiveJumpHeightPercent = 100.0
                * jumpAgilityFactor
                * loadPerformanceMultiplier
                * user.AirStatePerformanceMultiplier
                * user.SurvivalPerformanceMultiplier
                * user.HealthPerformanceMultiplier;
        }
    }

}
