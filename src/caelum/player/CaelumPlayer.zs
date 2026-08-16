// CaelumPlayer is the base class for every playable character.
//
// It currently inherits DoomPlayer so that Doom II's temporary weapons,
// animations, sounds, and inventory remain usable during early development.
// These inherited resources will be replaced by original assets later.
class CaelumPlayer : DoomPlayer
{
    // This object owns the twelve primary attributes for this player.
    // Each player receives a separate instance, including in multiplayer.
    CaelumAttributes Attributes;

    // Raza, dos clases, sexo y altura se guardan en un unico perfil.
    CaelumCharacterProfile CharacterProfile;

    // Stores the four layer points and thirty individual points.
    CaelumCharacterAllocation CharacterAllocation;

    // Derived values are recalculated whenever primary creation data changes.
    CaelumDerivedStats DerivedStats;
    bool DebugAttributesAt75;
    int DebugPanelPage;

    // Four independently configured armor pieces provide uniform defense by
    // armor type/tier, slot-specific reinforcement, bonuses, and durability.
    CaelumArmorModel ArmorModel;
    CaelumShieldModel ShieldModel;
    double ArmorDurabilityDamageMultiplier;
    bool ArmorDurabilityMultiplierInitialized;
    bool DebugArmorCriticalHit;
    int LastArmorVulnerabilityGrade;
    double LastArmorVulnerabilityMultiplier;
    double LastArmorPreDefenseDamage;
    double LastArmorAbsorbedDamage;
    double LastArmorPostDefenseDamage;
    double LastToughnessDamageMultiplier;
    int LastArmorHealthDamage;
    int LastArmorDurabilityLoss;
    double LastArmorDurabilityChancePercent;
    double LastArmorDurabilityRollPercent;
    double LastLocalizedLucidityLoss;
    bool LastArmorHitWasCritical;
    bool LastIncomingActorCriticalHit;
    double LastIncomingActorCriticalChancePercent;
    double LastIncomingActorCriticalRollPercent;
    bool DebugShieldBlocking;
    int DebugShieldDamageKind;
    int DebugShieldIncomingAngleOffset;
    bool LastShieldWithinCoverage;
    double LastShieldAbsorbedDamage;
    int LastShieldHealthDamage;
    int LastShieldDurabilityLoss;
    double LastShieldDurabilityChancePercent;
    double LastShieldDurabilityRollPercent;
    double CurrentShieldAirCostPerSecond;
    int LastAdrenalineEvent;
    double LastAdrenalineBaseGain;
    double LastAdrenalineFinalGain;

    // CaelumMaximumHealth is the integer gameplay maximum calculated from
    // Constitution. GZDoom damage still changes the inherited health field.
    int CaelumMaximumHealth;
    bool HealthResourceInitialized;
    int HealthState;
    double HealthRawPerformanceMultiplier;
    double HealthPatienceMitigationMultiplier;
    double HealthPatienceMitigatedPerformanceMultiplier;
    double HealthPerformanceMultiplier;
    double HealthPainMultiplier;
    double HealthAdrenalineGainMultiplier;

    // Stored diagnostic values expose the latest real-damage pain calculation
    // without changing its result. They also survive saves with the player.
    double LastHealthLossPercent;
    double LastPainChancePercent;
    bool LastPainTriggered;

    // Latest isolated melee test data shown by the development panel.
    double LastMeleeCalculatedDamage;
    int LastMeleeActualDamage;
    bool LastMeleeHit;
    int LastMeleeHitLocation;
    int LastMeleeVulnerabilityGrade;
    double LastMeleeHitHeightRatio;
    double LastMeleeLocationMultiplier;
    double LastMeleeAirCost;
    bool LastMeleeHadEnoughAir;
    bool LastMeleeCriticalAttempted;
    bool LastMeleeCriticalHit;
    double LastMeleeCriticalChancePercent;
    double LastMeleeCriticalRollPercent;
    double LastMeleeAccuracyPercent;
    double LastMeleeMovementAccuracyMultiplier;
    double LastMeleeCrouchCriticalMultiplier;
    bool LastStaffHit;
    bool LastStaffCriticalAttempted;
    bool LastStaffCriticalHit;
    bool LastStaffInsufficientAnima;
    double LastStaffCalculatedDamage;
    int LastStaffActualDamage;
    double LastStaffCriticalChancePercent;
    double LastStaffCriticalRollPercent;
    double LastStaffAccuracyPercent;
    double LastStaffYawOffset;
    double LastStaffPitchOffset;
    double LastStaffLocationMultiplier;
    int LastStaffVulnerabilityGrade;
    double StaffCastCooldownRemaining;
    double LastMeleeYawOffset;
    double LastMeleePitchOffset;

    // El Anima es un recurso persistente separado para magia y armas magicas.
    double CurrentAnima;
    bool AnimaResourceInitialized;

    // Adrenaline begins empty and persists with the player. The combat timer
    // stores how long remains before its automatic decay may begin.
    double CurrentAdrenaline;
    double CombatTimeRemaining;
    bool AdrenalineResourceInitialized;

    // Lucidity is stored independently from health and begins at its fixed
    // maximum. LucidityState is cached so UI code never calls play functions.
    double CurrentLucidity;
    bool LucidityResourceInitialized;
    int LucidityState;
    double LucidityPhysicalStunRemaining;
    double LuciditySleepDebuffMultiplier;
    double LucidityAccuracyMultiplier;
    double EffectivePhysicalAccuracyPercent;
    double EffectiveMagicalAccuracyPercent;
    bool IsCrouching;
    double CrouchAccuracyMultiplier;
    double CrouchCriticalChanceMultiplier;
    double CrouchStealthMultiplier;
    double PainImmobilizationRemaining;
    double LastPainAnimationDuration;

    // Survival values represent the percentage remaining, not accumulated
    // need. All three begin full and decay according to the world-time rules.
    double CurrentHunger;
    double CurrentThirst;
    double CurrentSleep;
    bool SurvivalResourcesInitialized;
    int HungerState;
    int ThirstState;
    int SleepState;
    double SurvivalPerformanceMultiplier;
    double SurvivalRawPerformanceMultiplier;
    double EffectiveOffensiveDamageMultiplier;
    double AdrenalinePenaltyIgnoreRatio;
    double SurvivalDamageAccumulator;
    double NaturalHealthRegenerationAccumulator;

    // CurrentAir is the first live Caelum resource. It is stored on the player
    // actor so ordinary GZDoom saves preserve it automatically.
    double CurrentAir;
    bool AirResourceInitialized;
    int AirState;
    double AirStatePerformanceMultiplier;
    double EffectiveEvasionChance;
    bool LastEvasionAttempted;
    bool LastEvasionSucceeded;
    double LastEvasionChancePercent;
    double LastEvasionRollPercent;
    double EffectiveMovementPercent;
    double EffectiveJumpHeightPercent;

    // Stored in play scope so the UI can report the real running state without
    // calling gameplay functions from UI scope.
    bool IsSpendingRunningAir;

    // Jump tracking detects one grounded-to-rising transition. It prevents a
    // held jump key from spending air repeatedly on consecutive game tics.
    bool JumpTrackingInitialized;
    bool WasGroundedLastTick;

    // Temporary state for the step-by-step character creation interface.
    bool CreationWizardOpen;
    int CreationWizardPage;

    // These backups preserve the last confirmed state while the wizard edits
    // the live preview values.
    CaelumCharacterProfile CreationProfileBackup;
    CaelumCharacterAllocation CreationAllocationBackup;
    bool CharacterCreationComplete;

    Default
    {
        // The $ prefix means that GZDoom obtains the visible name from LANGUAGE.
        // This prevents user-facing text from being hard-coded in ZScript.
        Player.DisplayName "$CA_PLAYER_DISPLAY_NAME";

        // Caelum performs one custom pain roll after engine mitigation. This
        // disables DoomPlayer's independent native roll and prevents duplicates.
        PainChance 0;
    }

    // PostBeginPlay runs after this player actor has entered the game world.
    // It is a suitable place for first-time initialization of owned objects.
    override void PostBeginPlay()
    {
        Super.PostBeginPlay();

        // Create the attribute container only when it does not already exist.
        // This guard helps prevent accidental replacement of stored data.
        if (Attributes == null)
        {
            // new creates a generic Object, and the explicit cast confirms that
            // the new object is specifically a CaelumAttributes container.
            Attributes = CaelumAttributes(new("CaelumAttributes"));
        }

        if (CharacterProfile == null)
        {
            CharacterProfile = CaelumCharacterProfile(new("CaelumCharacterProfile"));
            CharacterProfile.InitializeDefaultTestProfile();
        }

        if (CharacterAllocation == null)
        {
            CharacterAllocation = CaelumCharacterAllocation(new("CaelumCharacterAllocation"));
            CharacterAllocation.ResetAllocations();
        }

        if (DerivedStats == null)
        {
            DerivedStats = CaelumDerivedStats(new("CaelumDerivedStats"));
        }

        if (ArmorModel == null)
        {
            ArmorModel = CaelumArmorModel(new("CaelumArmorModel"));
        }

        if (ShieldModel == null)
        {
            ShieldModel = CaelumShieldModel(new("CaelumShieldModel"));
            ShieldModel.InitializeDefaults();
        }
        ArmorModel.InitializeDefaults();
        if (!ArmorDurabilityMultiplierInitialized)
        {
            // Reserved hook for future durability-loss mitigation effects.
            ArmorDurabilityDamageMultiplier = 1.0;
            ArmorDurabilityMultiplierInitialized = true;
        }

        ApplyCharacterProfile();

        if (!HealthResourceInitialized)
        {
            // A newly created or respawned player begins at full calculated
            // health. Existing saved players keep their stored current value.
            CaelumMaximumHealth = Max(1, int(DerivedStats.MaximumHealth));
            health = CaelumMaximumHealth;

            if (player != null)
            {
                player.health = health;
            }

            HealthResourceInitialized = true;
        }

        if (!AirResourceInitialized)
        {
            RefillAir();
            AirResourceInitialized = true;
        }

        if (!AnimaResourceInitialized)
        {
            RefillAnima();
            AnimaResourceInitialized = true;
        }

        if (!AdrenalineResourceInitialized)
        {
            CurrentAdrenaline = 0.0;
            CombatTimeRemaining = 0.0;
            AdrenalineResourceInitialized = true;
        }

        if (!LucidityResourceInitialized)
        {
            CurrentLucidity = CaelumConstants.MAXIMUM_LUCIDITY;
            LucidityResourceInitialized = true;
        }

        UpdateLucidityState();
        UpdateHealthStateEffects();

        if (!SurvivalResourcesInitialized)
        {
            RefillSurvivalResources();
            SurvivalResourcesInitialized = true;
        }

        UpdateAirStateEffects();

        if (player != null)
        {
            WasGroundedLastTick = player.onground;
            JumpTrackingInitialized = true;
        }

        // Report the current calculated sum. It begins at 108 before allocating
        // free points and increases as the player customizes the character.
        Console.Printf(
            "[Caelum] Character creation values loaded. Attribute total: %d",
            Attributes.GetTotalPrimaryLevels()
        );

        // Un personaje nuevo debe completar el creador antes de jugar.
        // El indicador queda guardado junto al actor y evita reabrirlo al cargar.
        if (!CharacterCreationComplete && !CreationWizardOpen)
        {
            BeginCreationWizard();
        }
    }

    // GZDoom calls this virtual function when health pickups and other engine
    // systems need the player's current maximum. Returning the Constitution
    // value makes ordinary Doom healing respect Caelum's dynamic limit.
    override int GetMaxHealth(bool withupgrades) const
    {
        if (CaelumMaximumHealth > 0)
        {
            return CaelumMaximumHealth;
        }

        return Super.GetMaxHealth(withupgrades);
    }

    // Directed combat damage now uses the complete Caelum defensive order.
    // Environmental and unclassified damage stays on GZDoom's native route.
    override int DamageMobj(
        Actor inflictor,
        Actor source,
        int damage,
        Name mod,
        int flags,
        double angle
    )
    {
        // El mundo no puede dañar al personaje antes de confirmar su creación.
        if (CreationWizardOpen && !CharacterCreationComplete)
        {
            return 0;
        }

        LastEvasionAttempted = false;
        LastEvasionSucceeded = false;
        LastEvasionChancePercent = 0.0;
        LastEvasionRollPercent = 0.0;

        if (IsEvadableDamage(inflictor, source, damage, mod, flags))
        {
            LastEvasionAttempted = true;
            LastEvasionChancePercent = Clamp(EffectiveEvasionChance, 0.0, 100.0);
            int evasionRoll = Random[CaelumEvasion](0, 999999);
            LastEvasionRollPercent = evasionRoll / 10000.0;
            if (LastEvasionRollPercent < LastEvasionChancePercent)
            {
                LastEvasionSucceeded = true;
                AddCombatAdrenaline(
                    CaelumConstants.ADRENALINE_GAIN_ON_EVASION,
                    CaelumConstants.ADRENALINE_EVENT_EVASION
                );
                MarkCombatActivity();
                return 0;
            }
        }

        if (IsDirectedCombatDamage(inflictor, source, damage, mod, flags))
        {
            return ApplyRealCombatDefense(
                inflictor,
                source,
                damage,
                mod,
                flags,
                angle
            );
        }

        int healthBeforeDamage = health;
        double adrenalineRatioBeforeDamage = 0.0;
        if (DerivedStats != null && DerivedStats.MaximumAdrenaline > 0.0)
        {
            adrenalineRatioBeforeDamage = Clamp(
                CurrentAdrenaline / DerivedStats.MaximumAdrenaline,
                0.0,
                1.0
            );
        }
        int result = Super.DamageMobj(
            inflictor,
            source,
            damage,
            mod,
            flags,
            angle
        );

        if (health < healthBeforeDamage)
        {
            int actualHealthLost = healthBeforeDamage - health;
            UpdateHealthStateEffects();
            CalculateAndTriggerPain(
                actualHealthLost,
                adrenalineRatioBeforeDamage
            );
            AddCombatAdrenaline(
                CaelumConstants.ADRENALINE_GAIN_ON_DAMAGE,
                CaelumConstants.ADRENALINE_EVENT_DAMAGE
            );
            MarkCombatActivity();
        }

        return result;
    }

    bool IsDirectedCombatDamage(
        Actor inflictor,
        Actor source,
        int damage,
        Name mod,
        int flags
    )
    {
        if (health <= 0 || damage <= 0 || (flags & DMG_EXPLOSION))
        {
            return false;
        }
        if (inflictor != null && inflictor.bMissile) { return true; }
        return source != null
            && (mod == 'Melee'
                || mod == 'Hitscan'
                || mod == 'Bullet'
                || mod == 'CaelumMeleeTest'
                || mod == 'CaelumRangedTest'
                || mod == 'CaelumMagicTest');
    }

    int ApplyRealCombatDefense(
        Actor inflictor,
        Actor source,
        int incomingDamage,
        Name mod,
        int flags,
        double damageAngle
    )
    {
        // Invulnerability must reject the complete hit before block rewards or
        // custom durability are calculated.
        if (bInvulnerable)
        {
            return Super.DamageMobj(
                inflictor,
                source,
                incomingDamage,
                mod,
                flags,
                damageAngle
            );
        }
        double damageAfterShield = ResolveRealShieldDamage(
            inflictor,
            source,
            incomingDamage,
            mod
        );
        bool incomingActorCritical = ResolveIncomingActorCritical(
            inflictor,
            source
        );
        PrepareRealArmorDamage(damageAfterShield, incomingActorCritical);

        double adrenalineRatioBeforeDamage = 0.0;
        if (DerivedStats != null && DerivedStats.MaximumAdrenaline > 0.0)
        {
            adrenalineRatioBeforeDamage = Clamp(
                CurrentAdrenaline / DerivedStats.MaximumAdrenaline,
                0.0,
                1.0
            );
        }

        int healthBeforeDamage = health;
        int finalDamage = Max(0, LastArmorHealthDamage);
        int result = 0;
        if (finalDamage > 0)
        {
            result = Super.DamageMobj(
                inflictor,
                source,
                finalDamage,
                mod,
                flags | DMG_NO_ARMOR,
                damageAngle
            );
        }

        CommitRealShieldDurability();
        CommitRealArmorDurability();

        if (health < healthBeforeDamage)
        {
            int actualHealthLost = healthBeforeDamage - health;
            LastArmorHealthDamage = actualHealthLost;
            ApplyLocalizedLucidityLoss(
                GetBaseVulnerabilityForArmorSlot(ArmorModel.SelectedSlot),
                LastArmorVulnerabilityGrade,
                incomingActorCritical,
                Clamp(ArmorModel.GetDefense(ArmorModel.SelectedSlot) / 100.0, 0.0, 1.0)
            );
            UpdateHealthStateEffects();
            CalculateAndTriggerPain(actualHealthLost, adrenalineRatioBeforeDamage);
            AddCombatAdrenaline(
                CaelumConstants.ADRENALINE_GAIN_ON_DAMAGE,
                CaelumConstants.ADRENALINE_EVENT_DAMAGE
            );
            MarkCombatActivity();
        }
        return result;
    }

    // Melee actors deliver their pending critical synchronously. Projectiles
    // carry an immutable copy because the shooter may launch another attack
    // before the first missile reaches its target.
    bool ResolveIncomingActorCritical(Actor inflictor, Actor source)
    {
        LastIncomingActorCriticalHit = false;
        LastIncomingActorCriticalChancePercent = 0.0;
        LastIncomingActorCriticalRollPercent = 0.0;

        CaelumActorProjectile actorProjectile = CaelumActorProjectile(inflictor);
        CaelumCombatActor attacker = CaelumCombatActor(source);
        if (actorProjectile != null)
        {
            LastIncomingActorCriticalHit = actorProjectile.CaelumCriticalHit;
            if (attacker != null)
            {
                LastIncomingActorCriticalChancePercent =
                    attacker.LastCombatAttackCriticalChancePercent;
                LastIncomingActorCriticalRollPercent =
                    attacker.LastCombatAttackCriticalRollPercent;
            }
            return LastIncomingActorCriticalHit;
        }

        if (attacker != null)
        {
            LastIncomingActorCriticalChancePercent =
                attacker.LastCombatAttackCriticalChancePercent;
            LastIncomingActorCriticalRollPercent =
                attacker.LastCombatAttackCriticalRollPercent;
            LastIncomingActorCriticalHit =
                attacker.ConsumePendingCombatCritical();
        }
        return LastIncomingActorCriticalHit;
    }

    double ResolveRealShieldDamage(
        Actor inflictor,
        Actor source,
        double incomingDamage,
        Name mod
    )
    {
        LastShieldAbsorbedDamage = 0.0;
        LastShieldHealthDamage = Max(0, int(incomingDamage + 0.5));
        LastShieldDurabilityLoss = 0;
        LastShieldDurabilityChancePercent = 0.0;
        LastShieldDurabilityRollPercent = 0.0;

        Actor attacker = source != null ? source : inflictor;
        double incomingOffset = 180.0;
        if (attacker != null)
        {
            incomingOffset = Abs(DeltaAngle(Angle, AngleTo(attacker)));
        }
        DebugShieldIncomingAngleOffset = int(incomingOffset + 0.5);
        LastShieldWithinCoverage = ShieldModel != null
            && incomingOffset <= ShieldModel.GetCoverageDegrees() / 2.0;
        bool shieldCanBlock = ShieldModel != null
            && DebugShieldBlocking
            && ShieldModel.Durability > 0
            && LastShieldWithinCoverage;
        if (!shieldCanBlock) { return incomingDamage; }

        int damageKind = mod == 'CaelumMagicTest'
            ? CaelumConstants.SHIELD_DAMAGE_MAGICAL
            : CaelumConstants.SHIELD_DAMAGE_PHYSICAL;
        double defenseRatio = Clamp(
            ShieldModel.GetDefense(damageKind) / 100.0,
            0.0,
            1.0
        );
        LastShieldAbsorbedDamage = incomingDamage * defenseRatio;
        LastShieldHealthDamage = Max(
            0,
            int(incomingDamage - LastShieldAbsorbedDamage + 0.5)
        );
        if (LastShieldAbsorbedDamage > 0.0)
        {
            AddCombatAdrenaline(
                CaelumConstants.ADRENALINE_GAIN_ON_SHIELD_BLOCK,
                CaelumConstants.ADRENALINE_EVENT_SHIELD_BLOCK
            );
            MarkCombatActivity();
        }
        CalculateRealShieldDurabilityLoss();
        return LastShieldHealthDamage;
    }

    void CalculateRealShieldDurabilityLoss()
    {
        double eligibleDamage = LastShieldAbsorbedDamage
            * Max(0.0, ArmorDurabilityDamageMultiplier);
        LastShieldDurabilityLoss = int(
            eligibleDamage
                / CaelumConstants.ARMOR_ABSORBED_DAMAGE_PER_GUARANTEED_DURABILITY
        );
        double remainder = eligibleDamage
            - LastShieldDurabilityLoss
                * CaelumConstants.ARMOR_ABSORBED_DAMAGE_PER_GUARANTEED_DURABILITY;
        LastShieldDurabilityChancePercent = Clamp(
            remainder / CaelumConstants.ARMOR_DAMAGE_PER_DURABILITY_CHANCE_PERCENT,
            0.0,
            100.0
        );
        int roll = Random[CaelumShieldDurability](0, 999999);
        LastShieldDurabilityRollPercent = roll / 10000.0;
        if (LastShieldDurabilityRollPercent < LastShieldDurabilityChancePercent)
        {
            LastShieldDurabilityLoss++;
        }
    }

    void CommitRealShieldDurability()
    {
        if (ShieldModel == null || LastShieldDurabilityLoss <= 0) { return; }
        LastShieldDurabilityLoss = Min(
            LastShieldDurabilityLoss,
            ShieldModel.Durability
        );
        ShieldModel.Durability -= LastShieldDurabilityLoss;
        if (ShieldModel.Durability <= 0) { DebugShieldBlocking = false; }
    }

    void PrepareRealArmorDamage(double incomingDamage, bool criticalHit)
    {
        LastLocalizedLucidityLoss = 0.0;
        LastArmorPreDefenseDamage = 0.0;
        LastArmorAbsorbedDamage = 0.0;
        LastArmorPostDefenseDamage = 0.0;
        LastArmorHealthDamage = 0;
        LastArmorDurabilityLoss = 0;
        LastArmorDurabilityChancePercent = 0.0;
        LastArmorDurabilityRollPercent = 0.0;
        LastArmorHitWasCritical = criticalHit && incomingDamage > 0.0;
        if (ArmorModel == null || incomingDamage <= 0.0) { return; }

        int slot = ArmorModel.SelectedSlot;
        LastArmorVulnerabilityGrade = GetEffectiveArmorVulnerability(slot);
        LastArmorVulnerabilityMultiplier = GetVulnerabilityMultiplier(
            LastArmorVulnerabilityGrade,
            criticalHit
        );
        LastArmorPreDefenseDamage = incomingDamage
            * LastArmorVulnerabilityMultiplier;
        double defenseRatio = Clamp(
            ArmorModel.GetDefense(slot) / 100.0,
            0.0,
            1.0
        );
        LastArmorAbsorbedDamage = LastArmorPreDefenseDamage * defenseRatio;
        LastArmorPostDefenseDamage = Max(
            0.0,
            LastArmorPreDefenseDamage - LastArmorAbsorbedDamage
        );
        LastToughnessDamageMultiplier = DerivedStats != null
            ? Clamp(DerivedStats.DamageResistanceMultiplier, 0.0, 1.0)
            : 1.0;
        LastArmorHealthDamage = Max(
            0,
            int(LastArmorPostDefenseDamage
                * LastToughnessDamageMultiplier + 0.5)
        );

        double eligibleDamage = LastArmorAbsorbedDamage
            * Max(0.0, ArmorDurabilityDamageMultiplier);
        LastArmorDurabilityLoss = int(
            eligibleDamage
                / CaelumConstants.ARMOR_ABSORBED_DAMAGE_PER_GUARANTEED_DURABILITY
        );
        double remainder = eligibleDamage
            - LastArmorDurabilityLoss
                * CaelumConstants.ARMOR_ABSORBED_DAMAGE_PER_GUARANTEED_DURABILITY;
        LastArmorDurabilityChancePercent = Clamp(
            remainder / CaelumConstants.ARMOR_DAMAGE_PER_DURABILITY_CHANCE_PERCENT,
            0.0,
            100.0
        );
        int roll = Random[CaelumArmorDurability](0, 999999);
        LastArmorDurabilityRollPercent = roll / 10000.0;
        if (LastArmorDurabilityRollPercent < LastArmorDurabilityChancePercent)
        {
            LastArmorDurabilityLoss++;
        }
    }

    void CommitRealArmorDurability()
    {
        if (ArmorModel == null || LastArmorDurabilityLoss <= 0) { return; }
        int slot = ArmorModel.SelectedSlot;
        LastArmorDurabilityLoss = Min(
            LastArmorDurabilityLoss,
            ArmorModel.Durability[slot]
        );
        ArmorModel.Durability[slot] -= LastArmorDurabilityLoss;
        if (ArmorModel.Durability[slot] <= 0) { ApplyCharacterProfile(); }
    }

    // Only directed physical attacks enter the current evasion roll. Missiles,
    // hitscan fire, and melee qualify. Explosions, hazards, floors, drowning,
    // telefrags, and other unclassified damage deliberately bypass evasion.
    bool IsEvadableDamage(
        Actor inflictor,
        Actor source,
        int damage,
        Name mod,
        int flags
    )
    {
        if (health <= 0
            || player == null
            || player.playerstate != PST_LIVE
            || damage <= 0
            || (flags & DMG_EXPLOSION))
        {
            return false;
        }

        if (inflictor != null && inflictor.bMissile)
        {
            return true;
        }

        return source != null
            && (mod == 'Melee'
                || mod == 'Hitscan'
                || mod == 'Bullet'
                || mod == 'CaelumMeleeTest'
                || mod == 'CaelumRangedTest'
                || mod == 'CaelumMagicTest');
    }

    // Pain uses the percentage of maximum health actually lost after armor,
    // invulnerability, and every other engine mitigation. Ten times that
    // percentage is reduced multiplicatively by Dureza Type 3 and by the
    // adrenaline percentage that existed before this hit.
    void CalculateAndTriggerPain(
        int actualHealthLost,
        double adrenalineRatioBeforeDamage
    )
    {
        LastHealthLossPercent = 0.0;
        LastPainChancePercent = 0.0;
        LastPainTriggered = false;

        if (actualHealthLost <= 0
            || CaelumMaximumHealth <= 0
            || DerivedStats == null
            || health <= 0)
        {
            return;
        }

        LastHealthLossPercent = 100.0
            * actualHealthLost / CaelumMaximumHealth;
        LastPainChancePercent = Clamp(
            10.0 * LastHealthLossPercent
                * DerivedStats.PainChanceMultiplier
                * HealthPainMultiplier
                * (1.0 - adrenalineRatioBeforeDamage),
            0.0,
            100.0
        );

        // Use a dedicated deterministic random stream for network-safe play.
        int painRoll = Random[CaelumPain](0, 999999);
        if (painRoll < int(LastPainChancePercent * 10000.0))
        {
            State painState = FindState('Pain');
            if (painState != null)
            {
                LastPainAnimationDuration = CalculatePainAnimationDuration(painState);
                PainImmobilizationRemaining = Max(
                    PainImmobilizationRemaining,
                    LastPainAnimationDuration
                );
                SetState(painState);
                LastPainTriggered = true;
                AddCombatAdrenaline(
                    CaelumConstants.ADRENALINE_GAIN_ON_PAIN,
                    CaelumConstants.ADRENALINE_EVENT_PAIN
                );
            }
        }
    }

    // Sum the finite states from Pain until the sequence returns to Spawn.
    // DoomPlayer uses two four-tic pain frames, so its live duration is 8/35 s.
    // Future player actors can use a different animation without duplicating a
    // hard-coded control-lock duration here.
    double CalculatePainAnimationDuration(State painState)
    {
        if (painState == null) { return 0.0; }

        State spawnState = FindState('Spawn');
        State cursor = painState;
        int totalTics = 0;
        for (int stateCount = 0; stateCount < 64; stateCount++)
        {
            if (cursor == null || cursor == spawnState) { break; }
            if (cursor.Tics < 0) { break; }
            totalTics += Max(0, cursor.Tics);
            cursor = cursor.NextState;
        }
        return totalTics / double(TICRATE);
    }

    // Bloquea las acciones normales mientras el creador ocupa la pantalla.
    // Los comandos del creador viajan por eventos de red independientes.
    override void PlayerThink()
    {
        if (CreationWizardOpen && player != null)
        {
            UserCmd creationCommand = player.cmd;
            creationCommand.forwardmove = 0;
            creationCommand.sidemove = 0;
            creationCommand.upmove = 0;
            creationCommand.buttons = 0;
            Vel.X = 0.0;
            Vel.Y = 0.0;
        }

        Super.PlayerThink();
    }

    // Tick runs once per game tic. GZDoom uses 35 tics per second, so dividing
    // the documented per-second rate by TICRATE produces frame-independent
    // regeneration that also pauses when the game itself is paused.
    override void Tick()
    {
        Super.Tick();

        // La creación inicial pausa necesidades, regeneraciones y costes.
        if (CreationWizardOpen)
        {
            IsSpendingRunningAir = false;
            return;
        }

        UpdateHealthStateEffects();

        IsSpendingRunningAir = IsRunningOnGround();
        UpdateCrouchEffects();

        // El Anima se regenera de forma continua segun Paciencia.
        if (AnimaResourceInitialized
            && DerivedStats != null
            && CurrentAnima < DerivedStats.MaximumAnima)
        {
            CurrentAnima = Min(
                DerivedStats.MaximumAnima,
                CurrentAnima + DerivedStats.AnimaRegenerationPerSecond / TICRATE
            );
        }

        UpdateAdrenalineDecay();
        UpdateLucidityPhysicalStun();
        UpdatePainImmobilization();
        StaffCastCooldownRemaining = Max(
            0.0,
            StaffCastCooldownRemaining - 1.0 / TICRATE
        );

        if (LucidityResourceInitialized
            && CurrentLucidity < CaelumConstants.MAXIMUM_LUCIDITY)
        {
            CurrentLucidity = Min(
                CaelumConstants.MAXIMUM_LUCIDITY,
                CurrentLucidity
                    + CaelumConstants.MAXIMUM_LUCIDITY
                    / CaelumConstants.LUCIDITY_FULL_RECOVERY_SECONDS
                    / TICRATE
            );
            UpdateLucidityState();
        }


        UpdateSurvivalResources();
        ApplyCriticalSurvivalDamage();
        ApplyNaturalHealthRegeneration();

        ApplyAirRegeneration();

        UpdateAirStateEffects();
        ApplyPhysicalMovement();
        DetectAndChargePhysicalJump();
        ConsumeRunningAir();
        ConsumeShieldBlockingAir();
    }

    // GZDoom exposes the effective run state through BT_RUN after combining
    // the physical speed key with the player's Always Run option. Requiring
    // directional input and ground contact keeps all non-running states free.
    bool IsRunningOnGround()
    {
        if (player == null
            || player.playerstate != PST_LIVE
            || !player.onground
            || IsPhysicallyImmobilized())
        {
            return false;
        }

        bool hasMovementInput = player.cmd.forwardmove != 0
            || player.cmd.sidemove != 0;
        bool runIsActive = (player.cmd.buttons & BT_RUN) != 0;

        return hasMovementInput && runIsActive;
    }

    void UpdateCrouchEffects()
    {
        IsCrouching = player != null && player.crouchfactor < 0.99;
        CrouchAccuracyMultiplier = IsCrouching
            ? CaelumConstants.CROUCH_ACCURACY_MULTIPLIER
            : 1.0;
        CrouchCriticalChanceMultiplier = IsCrouching
            ? CaelumConstants.CROUCH_CRITICAL_CHANCE_MULTIPLIER
            : 1.0;
        CrouchStealthMultiplier = IsCrouching
            ? CaelumConstants.CROUCH_STEALTH_MULTIPLIER
            : 1.0;
    }

    void SpawnDebugTrainingDummy()
    {
        if (player == null || player.playerstate != PST_LIVE) { return; }
        Vector3 spawnPos = Pos + (
            Cos(Angle) * 128.0,
            Sin(Angle) * 128.0,
            0.0
        );
        Actor dummy = Spawn("CaelumTrainingDummy", spawnPos, NO_REPLACE);
        if (dummy != null)
        {
            dummy.Angle = Angle + 180.0;
            if (!dummy.TestMobjLocation()) { dummy.Destroy(); }
        }
    }

    void SpawnDebugArgento()
    {
        if (player == null || player.playerstate != PST_LIVE) { return; }
        Vector3 spawnPos = Pos + (
            Cos(Angle) * 192.0,
            Sin(Angle) * 192.0,
            0.0
        );
        Actor argento = Spawn("CaelumArgento", spawnPos, NO_REPLACE);
        if (argento != null)
        {
            argento.Angle = Angle + 180.0;
            if (!argento.TestMobjLocation()) { argento.Destroy(); }
        }
    }

    void SpawnDebugCaella()
    {
        if (player == null || player.playerstate != PST_LIVE) { return; }
        Vector3 spawnPos = Pos + (
            Cos(Angle) * 192.0,
            Sin(Angle) * 192.0,
            0.0
        );
        Actor caella = Spawn("CaelumCaella", spawnPos, NO_REPLACE);
        if (caella != null)
        {
            caella.Angle = Angle + 180.0;
            if (!caella.TestMobjLocation()) { caella.Destroy(); }
        }
    }

    void SpawnDebugRulo()
    {
        if (player == null || player.playerstate != PST_LIVE) { return; }
        Vector3 spawnPos = Pos + (
            Cos(Angle) * 224.0,
            Sin(Angle) * 224.0,
            0.0
        );
        Actor rulo = Spawn("CaelumRulo", spawnPos, NO_REPLACE);
        if (rulo != null)
        {
            rulo.Angle = Angle + 180.0;
            if (!rulo.TestMobjLocation()) { rulo.Destroy(); }
        }
    }

    void SpawnDebugRonnie()
    {
        if (player == null || player.playerstate != PST_LIVE) { return; }
        Vector3 spawnPos = Pos + (
            Cos(Angle) * 192.0,
            Sin(Angle) * 192.0,
            0.0
        );
        Actor ronnie = Spawn("CaelumRonnie", spawnPos, NO_REPLACE);
        if (ronnie != null)
        {
            ronnie.Angle = Angle + 180.0;
            if (!ronnie.TestMobjLocation()) { ronnie.Destroy(); }
        }
    }

    // Functional straight-line staff test. Its trace distance and temporary
    // puff are presentation scaffolding; documented damage, Anima, timing,
    // Intelligence, Insight, critical, and status multipliers are live.
    void PerformDebugStaffAttack()
    {
        LastStaffHit = false;
        LastStaffCriticalAttempted = false;
        LastStaffCriticalHit = false;
        LastStaffInsufficientAnima = false;
        LastStaffActualDamage = 0;
        LastStaffCriticalRollPercent = 0.0;
        LastStaffLocationMultiplier = 1.0;
        LastStaffVulnerabilityGrade = CaelumConstants.VULNERABILITY_NEUTRAL_POINT;
        if (DerivedStats == null
            || player == null
            || player.playerstate != PST_LIVE
            || IsPhysicallyImmobilized()
            || StaffCastCooldownRemaining > 0.0)
        {
            return;
        }

        LastStaffCalculatedDamage = DerivedStats.DebugStaffDamage
            * EffectiveOffensiveDamageMultiplier;
        if (CurrentAnima < DerivedStats.StaffAnimaCost)
        {
            LastStaffInsufficientAnima = true;
            return;
        }

        CurrentAnima -= DerivedStats.StaffAnimaCost;
        StaffCastCooldownRemaining = CaelumConstants.DEBUG_STAFF_CAST_TICS
            * DerivedStats.CastingDurationMultiplier / double(TICRATE);
        UpdateLucidityAccuracyEffects();
        UpdateCrouchEffects();
        LastStaffAccuracyPercent = Max(
            1.0,
            EffectiveMagicalAccuracyPercent * CrouchAccuracyMultiplier
        );
        double maximumAimError = CaelumConstants.DEBUG_SWORD_BASE_INACCURACY_DEGREES
            * 100.0 / LastStaffAccuracyPercent;
        LastStaffYawOffset = Random[CaelumStaffAccuracyYaw](-100000, 100000)
            / 100000.0 * maximumAimError;
        LastStaffPitchOffset = Random[CaelumStaffAccuracyPitch](-100000, 100000)
            / 100000.0 * maximumAimError;
        double attackAngle = Angle + LastStaffYawOffset;
        double attackPitch = Pitch + LastStaffPitchOffset;

        FTranslatedLineTarget targetData;
        Actor detectionPuff;
        int ignoredDamage;
        [detectionPuff, ignoredDamage] = LineAttack(
            attackAngle,
            CaelumConstants.DEBUG_STAFF_TRACE_RANGE,
            attackPitch,
            0,
            'CaelumMagicTest',
            'BulletPuff',
            LAF_NOINTERACT | LAF_NORANDOMPUFFZ,
            targetData
        );
        LastStaffHit = targetData.linetarget != null;
        if (!LastStaffHit) { return; }

        int savedMeleeLocation = LastMeleeHitLocation;
        int savedMeleeGrade = LastMeleeVulnerabilityGrade;
        double savedMeleeHeight = LastMeleeHitHeightRatio;
        double savedMeleeMultiplier = LastMeleeLocationMultiplier;
        CalculateDebugMeleeHitLocation(targetData.linetarget, attackAngle, attackPitch);
        LastStaffVulnerabilityGrade = LastMeleeVulnerabilityGrade;
        LastMeleeHitLocation = savedMeleeLocation;
        LastMeleeVulnerabilityGrade = savedMeleeGrade;
        LastMeleeHitHeightRatio = savedMeleeHeight;
        LastMeleeLocationMultiplier = savedMeleeMultiplier;
        LastStaffCriticalAttempted = true;
        LastStaffCriticalChancePercent = Clamp(
            DerivedStats.StaffCriticalChance * CrouchCriticalChanceMultiplier,
            0.0,
            100.0
        );
        int criticalRoll = Random[CaelumMagicalCritical](0, 999999);
        LastStaffCriticalRollPercent = criticalRoll / 10000.0;
        LastStaffCriticalHit = LastStaffCriticalRollPercent
            < LastStaffCriticalChancePercent;
        CaelumCombatActor staffCombatTarget = CaelumCombatActor(
            targetData.linetarget
        );
        if (staffCombatTarget != null)
        {
            staffCombatTarget.RegisterPendingCriticalHit(
                LastStaffCriticalHit
            );
        }
        LastStaffLocationMultiplier = GetVulnerabilityMultiplier(
            LastStaffVulnerabilityGrade,
            LastStaffCriticalHit
        );
        LastStaffCalculatedDamage = DerivedStats.DebugStaffDamage
            * EffectiveOffensiveDamageMultiplier
            * LastStaffLocationMultiplier;
        int integerDamage = Max(1, int(LastStaffCalculatedDamage + 0.5));

        Actor puff;
        int actualStaffDamage;
        [puff, actualStaffDamage] = LineAttack(
            attackAngle,
            CaelumConstants.DEBUG_STAFF_TRACE_RANGE,
            attackPitch,
            integerDamage,
            'CaelumMagicTest',
            'BulletPuff',
            0,
            targetData
        );
        LastStaffActualDamage = actualStaffDamage;
        if (LastStaffActualDamage > 0)
        {
            AddCombatAdrenaline(
                CaelumConstants.ADRENALINE_GAIN_ON_MAGIC_DAMAGE,
                CaelumConstants.ADRENALINE_EVENT_MAGIC_DAMAGE
            );
            MarkCombatActivity();
        }
    }

    // Convert the documented per-second running cost into a per-tic cost.
    // Regeneration pauses during these tics so the displayed rate is exact.
    void ConsumeRunningAir()
    {
        if (!IsSpendingRunningAir || DerivedStats == null)
        {
            return;
        }

        double finalCostPerSecond = CaelumConstants.RUN_AIR_COST_PER_SECOND
            * DerivedStats.AirConsumptionMultiplier;
        CurrentAir = Max(0.0, CurrentAir - finalCostPerSecond / TICRATE);
        UpdateAirStateEffects();
    }

    void UpdateShieldAirCost()
    {
        CurrentShieldAirCostPerSecond = 0.0;
        if (ShieldModel == null || DerivedStats == null) { return; }
        CurrentShieldAirCostPerSecond = ShieldModel.GetWeight()
            * CaelumConstants.SHIELD_AIR_WEIGHT_RATIO_PER_SECOND
            * DerivedStats.AirConsumptionMultiplier;
    }

    void ConsumeShieldBlockingAir()
    {
        UpdateShieldAirCost();
        if (!DebugShieldBlocking || ShieldModel == null
            || ShieldModel.Durability <= 0) { return; }
        if (CurrentAir <= 0.0)
        {
            DebugShieldBlocking = false;
            return;
        }
        CurrentAir = Max(0.0, CurrentAir - CurrentShieldAirCostPerSecond / TICRATE);
        if (CurrentAir <= 0.0) { DebugShieldBlocking = false; }
        UpdateAirStateEffects();
    }

    void CycleDebugShieldType()
    {
        if (ShieldModel != null) { ShieldModel.CycleType(); ApplyCharacterProfile(); UpdateShieldAirCost(); }
    }

    void CycleDebugShieldTier()
    {
        if (ShieldModel != null) { ShieldModel.CycleTier(); ApplyCharacterProfile(); }
    }

    void ToggleDebugShieldBlock()
    {
        if (ShieldModel == null || ShieldModel.Durability <= 0 || CurrentAir <= 0.0)
        {
            DebugShieldBlocking = false;
            return;
        }
        DebugShieldBlocking = !DebugShieldBlocking;
        UpdateShieldAirCost();
    }

    void ToggleDebugShieldDamageKind()
    {
        DebugShieldDamageKind = DebugShieldDamageKind == CaelumConstants.SHIELD_DAMAGE_PHYSICAL
            ? CaelumConstants.SHIELD_DAMAGE_MAGICAL
            : CaelumConstants.SHIELD_DAMAGE_PHYSICAL;
    }

    void CycleDebugShieldIncomingAngle()
    {
        DebugShieldIncomingAngleOffset += 10;
        if (DebugShieldIncomingAngleOffset > 180)
        {
            DebugShieldIncomingAngleOffset = 0;
        }
    }

    void RepairDebugShield()
    {
        if (ShieldModel != null) { ShieldModel.Repair(); }
    }

    void ApplyDebugShieldHit()
    {
        LastShieldAbsorbedDamage = 0.0;
        LastShieldHealthDamage = int(CaelumConstants.DEBUG_SHIELD_HIT_DAMAGE);
        LastShieldDurabilityLoss = 0;
        LastShieldDurabilityChancePercent = 0.0;
        LastShieldDurabilityRollPercent = 0.0;
        LastShieldWithinCoverage = ShieldModel != null
            && Abs(DebugShieldIncomingAngleOffset)
                <= ShieldModel.GetCoverageDegrees() / 2.0;
        bool shieldCanBlock = ShieldModel != null
            && DebugShieldBlocking
            && ShieldModel.Durability > 0
            && LastShieldWithinCoverage;
        if (shieldCanBlock)
        {
            double defenseRatio = Clamp(
                ShieldModel.GetDefense(DebugShieldDamageKind) / 100.0,
                0.0, 1.0
            );
            LastShieldAbsorbedDamage = CaelumConstants.DEBUG_SHIELD_HIT_DAMAGE
                * defenseRatio;
            LastShieldHealthDamage = int(
                CaelumConstants.DEBUG_SHIELD_HIT_DAMAGE
                    - LastShieldAbsorbedDamage + 0.5
            );
            if (LastShieldAbsorbedDamage > 0.0)
            {
                AddCombatAdrenaline(
                    CaelumConstants.ADRENALINE_GAIN_ON_SHIELD_BLOCK,
                    CaelumConstants.ADRENALINE_EVENT_SHIELD_BLOCK
                );
                MarkCombatActivity();
            }

            double eligibleDamage = LastShieldAbsorbedDamage
                * Max(0.0, ArmorDurabilityDamageMultiplier);
            LastShieldDurabilityLoss = int(
                eligibleDamage
                    / CaelumConstants.ARMOR_ABSORBED_DAMAGE_PER_GUARANTEED_DURABILITY
            );
            double remainder = eligibleDamage
                - LastShieldDurabilityLoss
                    * CaelumConstants.ARMOR_ABSORBED_DAMAGE_PER_GUARANTEED_DURABILITY;
            LastShieldDurabilityChancePercent = Clamp(
                remainder / CaelumConstants.ARMOR_DAMAGE_PER_DURABILITY_CHANCE_PERCENT,
                0.0, 100.0
            );
            int roll = Random[CaelumShieldDurability](0, 999999);
            LastShieldDurabilityRollPercent = roll / 10000.0;
            if (LastShieldDurabilityRollPercent < LastShieldDurabilityChancePercent)
            {
                LastShieldDurabilityLoss++;
            }
            LastShieldDurabilityLoss = Min(
                LastShieldDurabilityLoss,
                ShieldModel.Durability
            );
            ShieldModel.Durability -= LastShieldDurabilityLoss;
            if (ShieldModel.Durability <= 0) { DebugShieldBlocking = false; }
        }

        // The damage not stopped by the shield now enters the selected body
        // region's complete armor, health, lucidity, and pain test pipeline.
        ApplyDebugArmorPipeline(LastShieldHealthDamage);
    }

    // Charge air only after GZDoom confirms a real takeoff: the player was on
    // the ground, is now airborne, is rising, and pressed the jump control.
    // The prediction guard prevents client-side prediction from charging the
    // persistent resource in addition to the authoritative game tic.
    void DetectAndChargePhysicalJump()
    {
        if (player == null || player.playerstate != PST_LIVE)
        {
            return;
        }

        bool isGroundedNow = player.onground;

        if (!JumpTrackingInitialized)
        {
            WasGroundedLastTick = isGroundedNow;
            JumpTrackingInitialized = true;
            return;
        }

        bool jumpPressed = (player.cmd.buttons & BT_JUMP) != 0;
        bool startedRising = WasGroundedLastTick
            && !isGroundedNow
            && Vel.Z > 0.0;

        if (startedRising
            && jumpPressed
            && !(player.cheats & CF_PREDICTING))
        {
            ConsumeJumpAir();
        }

        WasGroundedLastTick = isGroundedNow;
    }

    // Apply the verified effective values to GZDoom's real movement fields.
    // Forward/backward, sideways, swimming, and flight share this movement.
    void ApplyPhysicalMovement()
    {
        double movementFactor = Max(0.0, EffectiveMovementPercent / 100.0);
        double jumpFactor = Max(0.0, EffectiveJumpHeightPercent / 100.0);

        // Crossing the critical lucidity threshold causes one two-second
        // physical stun. Zeroing horizontal velocity prevents residual sliding
        // while movement and jumping are disabled.
        if (IsPhysicallyImmobilized())
        {
            movementFactor = 0.0;
            jumpFactor = 0.0;
            Vel.X = 0.0;
            Vel.Y = 0.0;
        }

        ForwardMove1 = CaelumConstants.GZDOOM_BASE_MOVEMENT * movementFactor;
        ForwardMove2 = CaelumConstants.GZDOOM_BASE_MOVEMENT * movementFactor;
        SideMove1 = CaelumConstants.GZDOOM_BASE_MOVEMENT * movementFactor;
        SideMove2 = CaelumConstants.GZDOOM_BASE_MOVEMENT * movementFactor;
        JumpZ = CaelumConstants.GZDOOM_BASE_JUMP_Z * jumpFactor;
    }

    bool IsPhysicallyImmobilized()
    {
        return LucidityPhysicalStunRemaining > 0.0
            || PainImmobilizationRemaining > 0.0;
    }

    // Recalculate base attributes whenever a debug profile choice changes.
    void ApplyCharacterProfile()
    {
        if (Attributes != null
            && CharacterProfile != null
            && CharacterAllocation != null
            && DerivedStats != null)
        {
            Attributes.InitializeFromCreation(CharacterProfile, CharacterAllocation);
            if (ArmorModel != null)
            {
                ArmorModel.ApplyAttributeBonuses(Attributes);
            }
            if (DebugAttributesAt75)
            {
                // The probability-test override is deliberately the final
                // value; equipment bonuses remain active only in normal play.
                Attributes.SetAllForDebug(CaelumConstants.DEBUG_ALL_ATTRIBUTES_LEVEL);
            }
            DerivedStats.SetEquipmentWeights(
                ArmorModel != null ? ArmorModel.GetTotalWeight() : 0.0,
                ShieldModel != null ? ShieldModel.GetWeight() : 0.0
            );
            DerivedStats.Recalculate(Attributes, CharacterProfile);
            // Radius es readonly en ZScript; A_SetSize actualiza ambas medidas
            // y vuelve a enlazar correctamente al jugador en el mundo.
            A_SetSize(
                DerivedStats.ActorRadius,
                DerivedStats.ActorHeight,
                false
            );
            UpdateLucidityAccuracyEffects();

            // Recalculation never grants free healing. Increasing the maximum
            // leaves current health unchanged; decreasing it only clamps an
            // amount that no longer fits under the new maximum.
            if (HealthResourceInitialized)
            {
                CaelumMaximumHealth = Max(1, int(DerivedStats.MaximumHealth));
                health = Min(health, CaelumMaximumHealth);

                if (player != null)
                {
                    player.health = health;
                }
            }

            // Profile changes never refill Anima for free; they only enforce a
            // newly reduced capacity, matching the health and air behavior.
            if (AnimaResourceInitialized)
            {
                CurrentAnima = Min(CurrentAnima, DerivedStats.MaximumAnima);
            }

            if (AdrenalineResourceInitialized)
            {
                CurrentAdrenaline = Min(
                    CurrentAdrenaline,
                    DerivedStats.MaximumAdrenaline
                );
            }

            // A profile change may lower maximum air. Never leave the current
            // resource above its newly calculated maximum.
            if (AirResourceInitialized)
            {
                CurrentAir = Min(CurrentAir, DerivedStats.MaximumAir);
            }
        }
    }

    // Spend one provisional action cost after applying the current load
    // multiplier. This validates the resource before real actions use it.
    void ConsumeDebugAir()
    {
        if (DerivedStats == null)
        {
            return;
        }

        double finalCost = CaelumConstants.DEBUG_AIR_ACTION_COST
            * DerivedStats.AirConsumptionMultiplier;
        CurrentAir = Max(0.0, CurrentAir - finalCost);
        UpdateAirStateEffects();
    }

    // Consume un costo de Anima de prueba ya expresado en la escala actual.
    void ConsumeDebugAnima()
    {
        CurrentAnima = Max(
            0.0,
            CurrentAnima - CaelumConstants.DEBUG_ANIMA_ACTION_COST
        );
    }

    // Restaura Anima solo mediante el control de desarrollo explicito.
    void RefillAnima()
    {
        if (DerivedStats != null)
        {
            CurrentAnima = DerivedStats.MaximumAnima;
        }
    }

    // Agrega una cantidad positiva sin superar el maximo derivado de Resiliencia.
    void AddAdrenaline(double amount)
    {
        if (DerivedStats != null)
        {
            CurrentAdrenaline = Clamp(
                CurrentAdrenaline + Max(0.0, amount),
                0.0,
                DerivedStats.MaximumAdrenaline
            );
        }
    }

    // Health state multiplies only gameplay-earned adrenaline. The manual
    // development fill control remains exact so resource testing stays useful.
    void AddCombatAdrenaline(
        double amount,
        int eventType = CaelumConstants.ADRENALINE_EVENT_OTHER
    )
    {
        LastAdrenalineEvent = eventType;
        LastAdrenalineBaseGain = Max(0.0, amount);
        LastAdrenalineFinalGain = LastAdrenalineBaseGain
            * HealthAdrenalineGainMultiplier;
        AddAdrenaline(LastAdrenalineFinalGain);
    }

    // Every confirmed combat event restarts the entire thirty-second timer.
    void MarkCombatActivity()
    {
        CombatTimeRemaining = CaelumConstants.COMBAT_TIMEOUT_SECONDS;
    }

    // Wait until combat ends, then remove ten points per second. TICRATE keeps
    // the result independent of rendering speed and pauses it with the game.
    void UpdateAdrenalineDecay()
    {
        if (!AdrenalineResourceInitialized || CurrentAdrenaline <= 0.0)
        {
            CombatTimeRemaining = Max(0.0, CombatTimeRemaining);
            return;
        }

        if (CombatTimeRemaining > 0.0)
        {
            CombatTimeRemaining = Max(
                0.0,
                CombatTimeRemaining - 1.0 / TICRATE
            );
            return;
        }

        CurrentAdrenaline = Max(
            0.0,
            CurrentAdrenaline
                - CaelumConstants.ADRENALINE_DECAY_PER_SECOND / TICRATE
        );
    }

    // Temporary helpers make capacity and timing easy to verify before Tarot
    // cards and the remaining combat event types are programmed.
    void AddDebugAdrenaline()
    {
        AddAdrenaline(CaelumConstants.DEBUG_ADRENALINE_GAIN);
        MarkCombatActivity();
    }

    void ClearDebugAdrenaline()
    {
        CurrentAdrenaline = 0.0;
        CombatTimeRemaining = 0.0;
    }

    void HealDebugHealth()
    {
        if (player == null
            || player.playerstate != PST_LIVE
            || CaelumMaximumHealth <= 0)
        {
            return;
        }

        health = CaelumMaximumHealth;
        player.health = health;
        if (DerivedStats != null)
        {
            CurrentAnima = DerivedStats.MaximumAnima;
            CurrentAir = DerivedStats.MaximumAir;
        }
        NaturalHealthRegenerationAccumulator = 0.0;
        UpdateHealthStateEffects();
        UpdateAirStateEffects();
    }

    void CycleDebugPanelPage()
    {
        DebugPanelPage = (DebugPanelPage + 1) % 6;
    }

    void GrantEnemyKillAdrenaline()
    {
        AddCombatAdrenaline(
            CaelumConstants.ADRENALINE_GAIN_ON_ENEMY_KILL,
            CaelumConstants.ADRENALINE_EVENT_ENEMY_KILL
        );
        MarkCombatActivity();
    }

    void GrantNearbyAllyDeathAdrenaline()
    {
        AddCombatAdrenaline(
            CaelumConstants.ADRENALINE_GAIN_ON_NEARBY_ALLY_DEATH,
            CaelumConstants.ADRENALINE_EVENT_ALLY_DEATH
        );
        MarkCombatActivity();
    }

    // Apply a non-lethal loss equal to five percent of maximum health. Direct
    // subtraction deliberately bypasses provisional Doom armor, then routes
    // through the exact same Caelum pain and adrenaline calculation as a real
    // mitigated hit. Keeping one health point makes repeated testing convenient.
    void ApplyDebugPainDamage()
    {
        if (player == null
            || player.playerstate != PST_LIVE
            || health <= 1
            || CaelumMaximumHealth <= 0)
        {
            return;
        }

        double adrenalineRatioBeforeDamage = 0.0;
        if (DerivedStats != null && DerivedStats.MaximumAdrenaline > 0.0)
        {
            adrenalineRatioBeforeDamage = Clamp(
                CurrentAdrenaline / DerivedStats.MaximumAdrenaline,
                0.0,
                1.0
            );
        }

        int testDamage = Max(
            1,
            int(CaelumMaximumHealth
                * CaelumConstants.DEBUG_PAIN_HEALTH_LOSS_RATIO + 0.5)
        );
        testDamage = Min(testDamage, health - 1);
        health -= testDamage;
        player.health = health;

        UpdateHealthStateEffects();
        CalculateAndTriggerPain(testDamage, adrenalineRatioBeforeDamage);
        AddCombatAdrenaline(
            CaelumConstants.ADRENALINE_GAIN_ON_DAMAGE,
            CaelumConstants.ADRENALINE_EVENT_DAMAGE
        );
        MarkCombatActivity();
    }

    // Cycle exact health thresholds without simulating an impact. This keeps
    // pain and adrenaline diagnostics separate while testing state penalties.
    void CycleDebugHealthState()
    {
        if (player == null || player.playerstate != PST_LIVE || CaelumMaximumHealth <= 0)
        {
            return;
        }

        if (HealthState == CaelumConstants.HEALTH_STATE_NORMAL)
        {
            health = Max(1, int(CaelumMaximumHealth * 0.50));
        }
        else if (HealthState == CaelumConstants.HEALTH_STATE_WOUNDED)
        {
            health = Max(1, int(CaelumMaximumHealth * 0.10));
        }
        else
        {
            health = CaelumMaximumHealth;
        }
        player.health = health;
        UpdateHealthStateEffects();
        UpdateAirStateEffects();
    }

    // Sends a small directed test hit through DamageMobj so the exact live
    // evasion gate can be repeated without waiting for a monster to attack.
    void ApplyDebugEvasionAttack()
    {
        if (player == null || player.playerstate != PST_LIVE || health <= 1)
        {
            return;
        }

        int testDamage = Max(
            1,
            int(CaelumMaximumHealth * CaelumConstants.DEBUG_EVASION_DAMAGE_RATIO + 0.5)
        );
        DamageMobj(self, self, testDamage, 'Hitscan', DMG_NO_ARMOR, Angle);
    }

    // Perform the documented sword primary attack with simplified localization.
    // LineAttack supplies the actor actually reached and the damage remaining
    // after the target's current engine mitigation. The physical critical roll
    // is live; status effects and the final Caelum armor stage remain separate.
    void PerformDebugSwordAttack()
    {
        LastMeleeCalculatedDamage = 0.0;
        LastMeleeActualDamage = 0;
        LastMeleeHit = false;
        LastMeleeHitLocation = CaelumConstants.HIT_LOCATION_NONE;
        LastMeleeVulnerabilityGrade = CaelumConstants.VULNERABILITY_NEUTRAL_POINT;
        LastMeleeHitHeightRatio = 0.0;
        LastMeleeLocationMultiplier = 0.0;
        LastMeleeAirCost = 0.0;
        LastMeleeHadEnoughAir = false;
        LastMeleeCriticalAttempted = false;
        LastMeleeCriticalHit = false;
        LastMeleeCriticalChancePercent = 0.0;
        LastMeleeCriticalRollPercent = 0.0;
        LastMeleeAccuracyPercent = 0.0;
        LastMeleeMovementAccuracyMultiplier = 1.0;
        LastMeleeCrouchCriticalMultiplier = 1.0;
        LastMeleeYawOffset = 0.0;
        LastMeleePitchOffset = 0.0;

        if (player == null
            || player.playerstate != PST_LIVE
            || DerivedStats == null
            || IsPhysicallyImmobilized())
        {
            return;
        }

        LastMeleeAirCost = CaelumConstants.DEBUG_SWORD_PRIMARY_AIR_COST
            * DerivedStats.AirConsumptionMultiplier;
        if (CurrentAir < LastMeleeAirCost)
        {
            return;
        }

        LastMeleeHadEnoughAir = true;
        CurrentAir = Max(0.0, CurrentAir - LastMeleeAirCost);
        UpdateAirStateEffects();

        LastMeleeCalculatedDamage = DerivedStats.DebugSwordDamage
            * EffectiveOffensiveDamageMultiplier;
        FTranslatedLineTarget targetData;
        UpdateLucidityAccuracyEffects();
        // Running applies after attributes and lucidity, retaining 25% of the
        // accuracy available at the instant the attack begins. Walking and
        // standing do not add a movement penalty.
        UpdateCrouchEffects();
        LastMeleeMovementAccuracyMultiplier = IsCrouching
            ? CrouchAccuracyMultiplier
            : (IsRunningOnGround()
                ? CaelumConstants.RUNNING_ACCURACY_MULTIPLIER
                : 1.0);
        LastMeleeAccuracyPercent = Max(
            1.0,
            EffectivePhysicalAccuracyPercent
                * LastMeleeMovementAccuracyMultiplier
        );
        double maximumAimError = CaelumConstants.DEBUG_SWORD_BASE_INACCURACY_DEGREES
            * 100.0 / LastMeleeAccuracyPercent;
        LastMeleeYawOffset = Random[CaelumSwordAccuracyYaw](-100000, 100000)
            / 100000.0 * maximumAimError;
        LastMeleePitchOffset = Random[CaelumSwordAccuracyPitch](-100000, 100000)
            / 100000.0 * maximumAimError;
        double attackAngle = Angle + LastMeleeYawOffset;
        double attackPitch = Pitch + LastMeleePitchOffset;

        // First trace detects the actor under the crosshair without changing it.
        // Using the player's real pitch makes vertical aiming select body zones.
        Actor detectionPuff;
        int ignoredDamage;
        [detectionPuff, ignoredDamage] = LineAttack(
            attackAngle,
            CaelumConstants.DEBUG_SWORD_RANGE,
            attackPitch,
            0,
            'CaelumMeleeTest',
            'BulletPuff',
            LAF_ISMELEEATTACK | LAF_NOINTERACT | LAF_NORANDOMPUFFZ,
            targetData
        );

        LastMeleeHit = targetData.linetarget != null;
        if (!LastMeleeHit)
        {
            return;
        }

        CalculateDebugMeleeHitLocation(
            targetData.linetarget,
            attackAngle,
            attackPitch
        );
        LastMeleeCriticalAttempted = true;
        LastMeleeCrouchCriticalMultiplier = CrouchCriticalChanceMultiplier;
        LastMeleeCriticalChancePercent = Clamp(
            DerivedStats.PhysicalCriticalChance
                * LastMeleeCrouchCriticalMultiplier,
            0.0,
            100.0
        );
        int criticalRoll = Random[CaelumPhysicalCritical](0, 999999);
        LastMeleeCriticalRollPercent = criticalRoll / 10000.0;
        LastMeleeCriticalHit = LastMeleeCriticalRollPercent
            < LastMeleeCriticalChancePercent;
        CaelumCombatActor meleeCombatTarget = CaelumCombatActor(
            targetData.linetarget
        );
        if (meleeCombatTarget != null)
        {
            meleeCombatTarget.RegisterPendingCriticalHit(
                LastMeleeCriticalHit
            );
        }
        LastMeleeLocationMultiplier = GetVulnerabilityMultiplier(
            LastMeleeVulnerabilityGrade,
            LastMeleeCriticalHit
        );
        LastMeleeCalculatedDamage = DerivedStats.DebugSwordDamage
            * LastMeleeLocationMultiplier
            * EffectiveOffensiveDamageMultiplier;
        int integerDamage = Max(1, int(LastMeleeCalculatedDamage + 0.5));

        Actor puff;
        int actualDamage;
        [puff, actualDamage] = LineAttack(
            attackAngle,
            CaelumConstants.DEBUG_SWORD_RANGE,
            attackPitch,
            integerDamage,
            'CaelumMeleeTest',
            'BulletPuff',
            LAF_ISMELEEATTACK,
            targetData
        );
        LastMeleeActualDamage = actualDamage;

        if (LastMeleeHit && LastMeleeActualDamage > 0)
        {
            AddCombatAdrenaline(
                CaelumConstants.ADRENALINE_GAIN_ON_MELEE_DAMAGE,
                CaelumConstants.ADRENALINE_EVENT_MELEE
            );
            MarkCombatActivity();
        }
    }

    // Estimates the ray's contact point on the target cylinder, then asks an
    // original actor's reusable anatomy profile to classify that normalized
    // impact. Other actors retain the humanoid fallback used by the dummy.
    void CalculateDebugMeleeHitLocation(
        Actor target,
        double attackAngle,
        double attackPitch
    )
    {
        if (target == null || target.Height <= 0.0)
        {
            LastMeleeHitLocation = CaelumConstants.HIT_LOCATION_TORSO;
            LastMeleeVulnerabilityGrade = CaelumConstants.VULNERABILITY_SENSITIVE_POINT;
            LastMeleeHitHeightRatio = 0.5;
            LastMeleeLocationMultiplier = GetVulnerabilityMultiplier(LastMeleeVulnerabilityGrade, false);
            return;
        }

        Vector2 toTarget = target.Pos.XY - Pos.XY;
        Vector2 forward = AngleToVector(attackAngle, 1.0);
        Vector2 right = AngleToVector(attackAngle + 90.0, 1.0);
        double forwardDistance = Max(0.0, toTarget.X * forward.X + toTarget.Y * forward.Y);
        double sideOffset = Abs(toTarget.X * right.X + toTarget.Y * right.Y);
        double radius = Max(1.0, target.Radius);
        double radiusForward = Sqrt(Max(0.0, radius * radius - sideOffset * sideOffset));
        double impactDistance = Max(0.0, forwardDistance - radiusForward);
        double impactZ = Pos.Z + ViewHeight - Tan(attackPitch) * impactDistance;
        LastMeleeHitHeightRatio = Clamp((impactZ - target.Pos.Z) / target.Height, 0.0, 1.0);

        double lateralRatio = Clamp(sideOffset / radius, 0.0, 1.0);
        CaelumCombatActor combatTarget = CaelumCombatActor(target);
        if (combatTarget != null)
        {
            LastMeleeVulnerabilityGrade = combatTarget.RegisterAnatomyImpact(
                LastMeleeHitHeightRatio,
                lateralRatio
            );
            LastMeleeHitLocation = combatTarget.LastAnatomyLocation;
        }
        else if (LastMeleeHitHeightRatio >= CaelumConstants.HIT_HEAD_MINIMUM_RATIO)
        {
            LastMeleeHitLocation = CaelumConstants.HIT_LOCATION_HEAD;
            LastMeleeVulnerabilityGrade = CaelumConstants.VULNERABILITY_CRITICAL_POINT;
        }
        else if (LastMeleeHitHeightRatio >= CaelumConstants.HIT_ARMS_MINIMUM_RATIO
            && LastMeleeHitHeightRatio <= CaelumConstants.HIT_ARMS_MAXIMUM_RATIO
            && lateralRatio >= CaelumConstants.HIT_ARMS_LATERAL_RATIO)
        {
            LastMeleeHitLocation = CaelumConstants.HIT_LOCATION_ARMS;
            LastMeleeVulnerabilityGrade = CaelumConstants.VULNERABILITY_WEAK_POINT;
        }
        else if (LastMeleeHitHeightRatio >= CaelumConstants.HIT_TORSO_MINIMUM_RATIO)
        {
            LastMeleeHitLocation = CaelumConstants.HIT_LOCATION_TORSO;
            LastMeleeVulnerabilityGrade = CaelumConstants.VULNERABILITY_SENSITIVE_POINT;
        }
        else
        {
            LastMeleeHitLocation = CaelumConstants.HIT_LOCATION_LEGS;
            LastMeleeVulnerabilityGrade = CaelumConstants.VULNERABILITY_NEUTRAL_POINT;
        }

        LastMeleeLocationMultiplier = GetVulnerabilityMultiplier(
            LastMeleeVulnerabilityGrade,
            false
        );
    }

    double GetVulnerabilityMultiplier(int grade, bool criticalHit)
    {
        double normalMultiplier = CaelumConstants.VULNERABILITY_NEUTRAL_MULTIPLIER;
        switch (Clamp(grade, 0, CaelumConstants.VULNERABILITY_GRADE_COUNT - 1))
        {
            case CaelumConstants.VULNERABILITY_CRITICAL_POINT:
                normalMultiplier = CaelumConstants.VULNERABILITY_CRITICAL_MULTIPLIER;
                break;
            case CaelumConstants.VULNERABILITY_SENSITIVE_POINT:
                normalMultiplier = CaelumConstants.VULNERABILITY_SENSITIVE_MULTIPLIER;
                break;
            case CaelumConstants.VULNERABILITY_WEAK_POINT:
                normalMultiplier = CaelumConstants.VULNERABILITY_WEAK_MULTIPLIER;
                break;
            case CaelumConstants.VULNERABILITY_STRONG_POINT:
                normalMultiplier = CaelumConstants.VULNERABILITY_STRONG_MULTIPLIER;
                break;
            case CaelumConstants.VULNERABILITY_HARD_POINT:
                normalMultiplier = CaelumConstants.VULNERABILITY_HARD_MULTIPLIER;
                break;
            case CaelumConstants.VULNERABILITY_ARMORED_POINT:
                normalMultiplier = CaelumConstants.VULNERABILITY_ARMORED_MULTIPLIER;
                break;
        }

        // This interpolation reproduces every endpoint of the original
        // critical ranges while accepting the newly fixed normal values.
        if (criticalHit)
        {
            return normalMultiplier * (normalMultiplier + 1.0);
        }
        return normalMultiplier;
    }

    int GetBaseVulnerabilityForArmorSlot(int slot)
    {
        switch (slot)
        {
            case CaelumConstants.ARMOR_SLOT_HEAD:
                return CaelumConstants.VULNERABILITY_CRITICAL_POINT;
            case CaelumConstants.ARMOR_SLOT_BODY:
                return CaelumConstants.VULNERABILITY_SENSITIVE_POINT;
            case CaelumConstants.ARMOR_SLOT_HANDS:
                return CaelumConstants.VULNERABILITY_WEAK_POINT;
            default:
                return CaelumConstants.VULNERABILITY_NEUTRAL_POINT;
        }
    }

    int GetEffectiveArmorVulnerability(int slot)
    {
        if (ArmorModel == null)
        {
            return GetBaseVulnerabilityForArmorSlot(slot);
        }
        return Min(
            CaelumConstants.VULNERABILITY_ARMORED_POINT,
            GetBaseVulnerabilityForArmorSlot(slot) + ArmorModel.GetReinforcement(slot)
        );
    }

    void CycleDebugArmorSlot()
    {
        if (ArmorModel != null) { ArmorModel.CycleSelectedSlot(); }
    }

    void CycleDebugArmorType()
    {
        if (ArmorModel == null) { return; }
        ArmorModel.CycleSelectedType();
        ApplyCharacterProfile();
    }

    void CycleDebugArmorTier()
    {
        if (ArmorModel == null) { return; }
        ArmorModel.CycleSelectedTier();
        ApplyCharacterProfile();
    }

    void ToggleDebugArmorCritical()
    {
        DebugArmorCriticalHit = !DebugArmorCriticalHit;
    }

    void RepairDebugArmor()
    {
        if (ArmorModel != null)
        {
            ArmorModel.RepairSelectedPiece();
            ApplyCharacterProfile();
        }
    }

    // Applies one confirmed 1000-point hit to the selected humanoid region.
    // Vulnerability and reinforcement resolve first, defense absorbs its
    // percentage next, and only post-defense health loss enters pain logic.
    void ApplyDebugArmorHit()
    {
        ApplyDebugArmorPipeline(CaelumConstants.DEBUG_ARMOR_HIT_DAMAGE);
    }

    void ApplyDebugArmorPipeline(double incomingDamage)
    {
        LastLocalizedLucidityLoss = 0.0;
        LastArmorPreDefenseDamage = 0.0;
        LastArmorAbsorbedDamage = 0.0;
        LastArmorPostDefenseDamage = 0.0;
        LastToughnessDamageMultiplier = DerivedStats != null
            ? DerivedStats.DamageResistanceMultiplier : 1.0;
        LastArmorHealthDamage = 0;
        LastArmorDurabilityLoss = 0;
        LastArmorDurabilityChancePercent = 0.0;
        LastArmorDurabilityRollPercent = 0.0;
        LastArmorHitWasCritical = DebugArmorCriticalHit;
        if (ArmorModel == null
            || player == null
            || player.playerstate != PST_LIVE
            || health <= 1
            || incomingDamage <= 0.0)
        {
            return;
        }

        int slot = ArmorModel.SelectedSlot;
        LastArmorVulnerabilityGrade = GetEffectiveArmorVulnerability(slot);
        LastArmorVulnerabilityMultiplier = GetVulnerabilityMultiplier(
            LastArmorVulnerabilityGrade,
            DebugArmorCriticalHit
        );
        LastArmorPreDefenseDamage = incomingDamage
            * LastArmorVulnerabilityMultiplier;

        double defenseRatio = Clamp(ArmorModel.GetDefense(slot) / 100.0, 0.0, 1.0);
        LastArmorAbsorbedDamage = LastArmorPreDefenseDamage * defenseRatio;
        LastArmorPostDefenseDamage = Max(
            0.0,
            LastArmorPreDefenseDamage - LastArmorAbsorbedDamage
        );
        LastToughnessDamageMultiplier = DerivedStats != null
            ? Clamp(DerivedStats.DamageResistanceMultiplier, 0.0, 1.0)
            : 1.0;
        int calculatedHealthDamage = Max(
            0,
            int(LastArmorPostDefenseDamage
                * LastToughnessDamageMultiplier + 0.5)
        );
        LastArmorHealthDamage = Min(calculatedHealthDamage, health - 1);

        double durabilityEligibleDamage = LastArmorAbsorbedDamage
            * Max(0.0, ArmorDurabilityDamageMultiplier);
        LastArmorDurabilityLoss = int(
            durabilityEligibleDamage
                / CaelumConstants.ARMOR_ABSORBED_DAMAGE_PER_GUARANTEED_DURABILITY
        );
        double remainder = durabilityEligibleDamage
            - LastArmorDurabilityLoss
                * CaelumConstants.ARMOR_ABSORBED_DAMAGE_PER_GUARANTEED_DURABILITY;
        LastArmorDurabilityChancePercent = Clamp(
            remainder / CaelumConstants.ARMOR_DAMAGE_PER_DURABILITY_CHANCE_PERCENT,
            0.0,
            100.0
        );
        int durabilityRoll = Random[CaelumArmorDurability](0, 999999);
        LastArmorDurabilityRollPercent = durabilityRoll / 10000.0;
        if (LastArmorDurabilityRollPercent < LastArmorDurabilityChancePercent)
        {
            LastArmorDurabilityLoss++;
        }
        LastArmorDurabilityLoss = Min(
            LastArmorDurabilityLoss,
            ArmorModel.Durability[slot]
        );
        ArmorModel.Durability[slot] -= LastArmorDurabilityLoss;

        double adrenalineRatioBeforeDamage = 0.0;
        if (DerivedStats != null && DerivedStats.MaximumAdrenaline > 0.0)
        {
            adrenalineRatioBeforeDamage = Clamp(
                CurrentAdrenaline / DerivedStats.MaximumAdrenaline,
                0.0,
                1.0
            );
        }

        if (LastArmorHealthDamage > 0)
        {
            health -= LastArmorHealthDamage;
            player.health = health;
            ApplyLocalizedLucidityLoss(
                GetBaseVulnerabilityForArmorSlot(slot),
                LastArmorVulnerabilityGrade,
                DebugArmorCriticalHit,
                defenseRatio
            );
            UpdateHealthStateEffects();
            CalculateAndTriggerPain(LastArmorHealthDamage, adrenalineRatioBeforeDamage);
            AddCombatAdrenaline(
                CaelumConstants.ADRENALINE_GAIN_ON_DAMAGE,
                CaelumConstants.ADRENALINE_EVENT_DAMAGE
            );
            MarkCombatActivity();
        }

        if (ArmorModel.Durability[slot] <= 0)
        {
            ApplyCharacterProfile();
        }
    }

    // Any confirmed damage type can call this shared localized rule. Natural
    // anatomy decides eligibility even after reinforcement. Defense absorbs
    // the same percentage of lucidity, while reinforcement reduces a critical
    // hit's relative multiplier through the effective vulnerability grade.
    void ApplyLocalizedLucidityLoss(
        int naturalVulnerabilityGrade,
        int effectiveVulnerabilityGrade,
        bool criticalHit,
        double defenseRatio
    )
    {
        LastLocalizedLucidityLoss = 0.0;
        if (naturalVulnerabilityGrade != CaelumConstants.VULNERABILITY_CRITICAL_POINT
            || DerivedStats == null)
        {
            return;
        }

        double criticalFactor = 1.0;
        if (criticalHit)
        {
            double normalMultiplier = GetVulnerabilityMultiplier(
                effectiveVulnerabilityGrade,
                false
            );
            double criticalMultiplier = GetVulnerabilityMultiplier(
                effectiveVulnerabilityGrade,
                true
            );
            if (normalMultiplier > 0.0)
            {
                criticalFactor = criticalMultiplier / normalMultiplier;
            }
        }

        LastLocalizedLucidityLoss = Min(
            CurrentLucidity,
            CaelumConstants.CRITICAL_POINT_BASE_LUCIDITY_LOSS
                * criticalFactor
                * (1.0 - Clamp(defenseRatio, 0.0, 1.0))
                * DerivedStats.LucidityLossMultiplier
                * GetLuciditySleepDebuffMultiplier()
        );
        CurrentLucidity = Max(0.0, CurrentLucidity - LastLocalizedLucidityLoss);
        UpdateLucidityState();
    }

    // Low sleep doubles and critical sleep quadruples lucidity loss and stun
    // duration. Patience Type 3 mitigates only the harmful amount above x1.
    double GetLuciditySleepDebuffMultiplier()
    {
        double rawMultiplier = 1.0;
        if (SleepState == CaelumConstants.SURVIVAL_STATE_CRITICAL)
        {
            rawMultiplier = CaelumConstants.LUCIDITY_SLEEP_CRITICAL_INTENSITY_MULTIPLIER;
        }
        else if (SleepState == CaelumConstants.SURVIVAL_STATE_LOW)
        {
            rawMultiplier = CaelumConstants.LUCIDITY_SLEEP_LOW_INTENSITY_MULTIPLIER;
        }

        double patienceMultiplier = 1.0;
        if (DerivedStats != null)
        {
            patienceMultiplier = DerivedStats.HealthPenaltyMultiplier;
        }
        return 1.0 + (rawMultiplier - 1.0) * patienceMultiplier;
    }

    // Provisional loss validates regeneration and thresholds. Dureza is shown
    // in the panel but will be applied only to classified real loss sources.
    void LoseDebugLucidity()
    {
        CurrentLucidity = Max(
            0.0,
            CurrentLucidity - CaelumConstants.DEBUG_LUCIDITY_LOSS
        );
        UpdateLucidityState();
    }

    void RefillLucidity()
    {
        CurrentLucidity = CaelumConstants.MAXIMUM_LUCIDITY;
        UpdateLucidityState();
    }

    // Select the exact thresholds needed to inspect accuracy and visual state
    // without waiting for recovery or pressing the ten-point loss key repeatedly.
    void CycleDebugLucidityState()
    {
        if (LucidityState == CaelumConstants.LUCIDITY_STATE_NORMAL)
        {
            CurrentLucidity = CaelumConstants.MAXIMUM_LUCIDITY
                * CaelumConstants.LUCIDITY_DIZZY_THRESHOLD;
        }
        else if (LucidityState == CaelumConstants.LUCIDITY_STATE_DIZZY)
        {
            CurrentLucidity = CaelumConstants.MAXIMUM_LUCIDITY
                * CaelumConstants.LUCIDITY_STUNNED_THRESHOLD;
        }
        else
        {
            CurrentLucidity = CaelumConstants.MAXIMUM_LUCIDITY;
        }
        UpdateLucidityState();
    }

    void UpdateLucidityState()
    {
        int previousState = LucidityState;
        double ratio = CurrentLucidity / CaelumConstants.MAXIMUM_LUCIDITY;

        if (ratio <= CaelumConstants.LUCIDITY_STUNNED_THRESHOLD)
        {
            LucidityState = CaelumConstants.LUCIDITY_STATE_STUNNED;
        }
        else if (ratio <= CaelumConstants.LUCIDITY_DIZZY_THRESHOLD)
        {
            LucidityState = CaelumConstants.LUCIDITY_STATE_DIZZY;
        }
        else
        {
            LucidityState = CaelumConstants.LUCIDITY_STATE_NORMAL;
        }

        UpdateLucidityAccuracyEffects();

        // Trigger once only when entering the critical state from above. The
        // timer does not restart merely because lucidity remains at or below
        // ten percent, and it persists through ordinary saves with the player.
        if (previousState != CaelumConstants.LUCIDITY_STATE_STUNNED
            && LucidityState == CaelumConstants.LUCIDITY_STATE_STUNNED)
        {
            LucidityPhysicalStunRemaining =
                CaelumConstants.LUCIDITY_PHYSICAL_STUN_SECONDS
                    * GetLuciditySleepDebuffMultiplier();
        }
    }

    // Lucidity owns one reusable accuracy factor. Both dizzy and stunned
    // states retain 50%; the critical state additionally has its finite
    // physical immobilization when the threshold is crossed.
    void UpdateLucidityAccuracyEffects()
    {
        LucidityAccuracyMultiplier = LucidityState
            == CaelumConstants.LUCIDITY_STATE_NORMAL
            ? 1.0
            : CaelumConstants.LUCIDITY_DIZZY_ACCURACY_MULTIPLIER;

        if (DerivedStats == null)
        {
            EffectivePhysicalAccuracyPercent = 0.0;
            EffectiveMagicalAccuracyPercent = 0.0;
            return;
        }

        EffectivePhysicalAccuracyPercent = DerivedStats.PhysicalAccuracyPercent
            * LucidityAccuracyMultiplier;
        EffectiveMagicalAccuracyPercent = DerivedStats.MagicalAccuracyPercent
            * LucidityAccuracyMultiplier;
    }

    void UpdateLucidityPhysicalStun()
    {
        if (LucidityPhysicalStunRemaining > 0.0)
        {
            LucidityPhysicalStunRemaining = Max(
                0.0,
                LucidityPhysicalStunRemaining - 1.0 / TICRATE
            );
        }
    }

    void UpdatePainImmobilization()
    {
        if (PainImmobilizationRemaining > 0.0)
        {
            PainImmobilizationRemaining = Max(
                0.0,
                PainImmobilizationRemaining - 1.0 / TICRATE
            );
        }
    }

    int CalculateSurvivalState(double currentValue)
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

    double GetSurvivalStateMultiplier(int state)
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

    // Apply base depletion time and the appropriate Type 3 loss multiplier.
    void UpdateSurvivalResources()
    {
        if (!SurvivalResourcesInitialized || DerivedStats == null)
        {
            return;
        }

        CurrentHunger = Max(0.0, CurrentHunger
            - CaelumConstants.SURVIVAL_MAXIMUM
            / (CaelumConstants.HUNGER_EMPTY_GAME_HOURS
                * CaelumConstants.REAL_SECONDS_PER_GAME_HOUR)
            * DerivedStats.HungerThirstLossMultiplier / TICRATE);
        CurrentThirst = Max(0.0, CurrentThirst
            - CaelumConstants.SURVIVAL_MAXIMUM
            / (CaelumConstants.THIRST_EMPTY_GAME_HOURS
                * CaelumConstants.REAL_SECONDS_PER_GAME_HOUR)
            * DerivedStats.HungerThirstLossMultiplier / TICRATE);
        CurrentSleep = Max(0.0, CurrentSleep
            - CaelumConstants.SURVIVAL_MAXIMUM
            / (CaelumConstants.SLEEP_EMPTY_GAME_HOURS
                * CaelumConstants.REAL_SECONDS_PER_GAME_HOUR)
            * DerivedStats.SleepLossMultiplier / TICRATE);
        UpdateSurvivalStates();
    }

    void UpdateSurvivalStates()
    {
        HungerState = CalculateSurvivalState(CurrentHunger);
        ThirstState = CalculateSurvivalState(CurrentThirst);
        SleepState = CalculateSurvivalState(CurrentSleep);
        LuciditySleepDebuffMultiplier = GetLuciditySleepDebuffMultiplier();

        SurvivalRawPerformanceMultiplier = GetSurvivalStateMultiplier(HungerState)
            * GetSurvivalStateMultiplier(ThirstState)
            * GetSurvivalStateMultiplier(SleepState);

        // Adrenaline ignores the same percentage of the missing performance
        // as its current share of maximum. Example: raw x0.50 with 50%
        // adrenaline becomes x0.75.
        AdrenalinePenaltyIgnoreRatio = 0.0;
        if (DerivedStats != null && DerivedStats.MaximumAdrenaline > 0.0)
        {
            AdrenalinePenaltyIgnoreRatio = Clamp(
                CurrentAdrenaline / DerivedStats.MaximumAdrenaline,
                0.0,
                1.0
            );
        }
        SurvivalPerformanceMultiplier = SurvivalRawPerformanceMultiplier
            + (1.0 - SurvivalRawPerformanceMultiplier)
            * AdrenalinePenaltyIgnoreRatio;
        UpdateEffectiveOffensiveDamageMultiplier();
    }

    // Patience first mitigates the harmful part of wounded states. Adrenaline
    // then restores the same share of the remaining penalty and suppresses
    // pain intensity. Beneficial adrenaline gains remain x2/x4.
    void UpdateHealthStateEffects()
    {
        double healthRatio = 1.0;
        if (CaelumMaximumHealth > 0)
        {
            healthRatio = Clamp(double(health) / CaelumMaximumHealth, 0.0, 1.0);
        }

        double rawIntensityMultiplier = 1.0;
        if (healthRatio <= CaelumConstants.HEALTH_BADLY_WOUNDED_THRESHOLD)
        {
            HealthState = CaelumConstants.HEALTH_STATE_BADLY_WOUNDED;
            HealthRawPerformanceMultiplier =
                CaelumConstants.HEALTH_BADLY_WOUNDED_PERFORMANCE_MULTIPLIER;
            rawIntensityMultiplier =
                CaelumConstants.HEALTH_BADLY_WOUNDED_INTENSITY_MULTIPLIER;
        }
        else if (healthRatio <= CaelumConstants.HEALTH_WOUNDED_THRESHOLD)
        {
            HealthState = CaelumConstants.HEALTH_STATE_WOUNDED;
            HealthRawPerformanceMultiplier =
                CaelumConstants.HEALTH_WOUNDED_PERFORMANCE_MULTIPLIER;
            rawIntensityMultiplier =
                CaelumConstants.HEALTH_WOUNDED_INTENSITY_MULTIPLIER;
        }
        else
        {
            HealthState = CaelumConstants.HEALTH_STATE_NORMAL;
            HealthRawPerformanceMultiplier = 1.0;
        }

        double adrenalineRatio = 0.0;
        if (DerivedStats != null && DerivedStats.MaximumAdrenaline > 0.0)
        {
            adrenalineRatio = Clamp(
                CurrentAdrenaline / DerivedStats.MaximumAdrenaline,
                0.0,
                1.0
            );
        }

        HealthPatienceMitigationMultiplier = 1.0;
        if (DerivedStats != null)
        {
            HealthPatienceMitigationMultiplier =
                DerivedStats.HealthPenaltyMultiplier;
        }
        HealthPatienceMitigatedPerformanceMultiplier = 1.0
            - (1.0 - HealthRawPerformanceMultiplier)
                * HealthPatienceMitigationMultiplier;
        HealthPerformanceMultiplier = HealthPatienceMitigatedPerformanceMultiplier
            + (1.0 - HealthPatienceMitigatedPerformanceMultiplier)
                * adrenalineRatio;
        HealthPainMultiplier = 1.0
            + (rawIntensityMultiplier - 1.0)
                * HealthPatienceMitigationMultiplier
                * (1.0 - adrenalineRatio);
        HealthAdrenalineGainMultiplier = rawIntensityMultiplier;
        UpdateEffectiveOffensiveDamageMultiplier();
    }

    // One stored result keeps every present and future offensive action on the
    // same rule. Health and survival are independent penalties, so they multiply.
    void UpdateEffectiveOffensiveDamageMultiplier()
    {
        EffectiveOffensiveDamageMultiplier = Clamp(
            HealthPerformanceMultiplier * SurvivalPerformanceMultiplier,
            0.0,
            1.0
        );
    }

    // Each critical resource inverts the base natural-health recovery rate.
    // Fractional damage is accumulated because GZDoom health is integer-based.
    void ApplyCriticalSurvivalDamage()
    {
        if (player == null || player.playerstate != PST_LIVE || health <= 0)
        {
            return;
        }

        int criticalResourceCount = 0;
        if (HungerState == CaelumConstants.SURVIVAL_STATE_CRITICAL) criticalResourceCount++;
        if (ThirstState == CaelumConstants.SURVIVAL_STATE_CRITICAL) criticalResourceCount++;
        if (SleepState == CaelumConstants.SURVIVAL_STATE_CRITICAL) criticalResourceCount++;
        if (criticalResourceCount <= 0)
        {
            // Do not carry a partial damage point across recovery from every
            // critical state.
            SurvivalDamageAccumulator = 0.0;
            return;
        }

        double baseDamagePerSecond = CaelumMaximumHealth
            / CaelumConstants.HEALTH_BASE_RECOVERY_REAL_SECONDS;
        SurvivalDamageAccumulator += baseDamagePerSecond
            * criticalResourceCount / TICRATE;
        int wholeDamage = int(SurvivalDamageAccumulator);
        if (wholeDamage <= 0) return;

        SurvivalDamageAccumulator -= wholeDamage;
        health -= wholeDamage;
        player.health = health;

        // Direct health loss deliberately bypasses armor and this class's
        // ordinary-damage adrenaline gain. Death still uses GZDoom's pipeline.
        if (health <= 0)
        {
            health = 0;
            player.health = 0;
            Die(self, self, 0, 'CaelumSurvival');
        }
    }

    // Natural recovery is stopped by any critical survival state. Healing uses
    // Resiliencia Tipo 4 y gasta hambre/sed segun la vida restaurada.
    void ApplyNaturalHealthRegeneration()
    {
        if (player == null
            || player.playerstate != PST_LIVE
            || health <= 0
            || health >= CaelumMaximumHealth
            || DerivedStats == null)
        {
            NaturalHealthRegenerationAccumulator = 0.0;
            return;
        }

        if (HungerState == CaelumConstants.SURVIVAL_STATE_CRITICAL
            || ThirstState == CaelumConstants.SURVIVAL_STATE_CRITICAL
            || SleepState == CaelumConstants.SURVIVAL_STATE_CRITICAL)
        {
            NaturalHealthRegenerationAccumulator = 0.0;
            return;
        }

        double hungerCostPerHealth = 100.0 / CaelumMaximumHealth;
        double thirstCostPerHealth = 50.0 / CaelumMaximumHealth;
        double affordableHealth = Min(
            CurrentHunger / hungerCostPerHealth,
            CurrentThirst / thirstCostPerHealth
        );
        if (affordableHealth <= 0.0) return;

        NaturalHealthRegenerationAccumulator += Min(
            DerivedStats.HealthRegenerationPerSecond / TICRATE,
            affordableHealth
        );
        int wholeHealing = int(NaturalHealthRegenerationAccumulator);
        wholeHealing = Min(wholeHealing, CaelumMaximumHealth - health);
        if (wholeHealing <= 0) return;

        NaturalHealthRegenerationAccumulator -= wholeHealing;
        health += wholeHealing;
        player.health = health;
        CurrentHunger = Max(0.0, CurrentHunger - wholeHealing * hungerCostPerHealth);
        CurrentThirst = Max(0.0, CurrentThirst - wholeHealing * thirstCostPerHealth);
        UpdateSurvivalStates();
    }

    // Air recovery consumes survival resources proportionally: restoring one
    // percent of maximum air costs 0.1% hunger and 0.2% thirst. If either
    // resource cannot afford the whole tic, recovery is limited to what it can
    // support instead of allowing a negative survival value.
    void ApplyAirRegeneration()
    {
        if (!AirResourceInitialized
            || DerivedStats == null
            || IsSpendingRunningAir
            || DebugShieldBlocking
            || CurrentAir >= DerivedStats.MaximumAir
            || DerivedStats.MaximumAir <= 0.0)
        {
            return;
        }

        double hungerCostPerAir =
            CaelumConstants.AIR_FULL_RECOVERY_HUNGER_COST
            / DerivedStats.MaximumAir;
        double thirstCostPerAir =
            CaelumConstants.AIR_FULL_RECOVERY_THIRST_COST
            / DerivedStats.MaximumAir;
        double affordableAir = Min(
            CurrentHunger / hungerCostPerAir,
            CurrentThirst / thirstCostPerAir
        );
        if (affordableAir <= 0.0) return;

        double recoveredAir = Min(
            DerivedStats.AirRegenerationPerSecond
                * HealthPerformanceMultiplier / TICRATE,
            DerivedStats.MaximumAir - CurrentAir
        );
        recoveredAir = Min(recoveredAir, affordableAir);
        if (recoveredAir <= 0.0) return;

        CurrentAir += recoveredAir;
        CurrentHunger = Max(
            0.0,
            CurrentHunger - recoveredAir * hungerCostPerAir
        );
        CurrentThirst = Max(
            0.0,
            CurrentThirst - recoveredAir * thirstCostPerAir
        );
        UpdateSurvivalStates();
    }

    void LoseDebugHunger() { CurrentHunger = Max(0.0, CurrentHunger - CaelumConstants.DEBUG_SURVIVAL_LOSS); UpdateSurvivalStates(); }
    void LoseDebugThirst() { CurrentThirst = Max(0.0, CurrentThirst - CaelumConstants.DEBUG_SURVIVAL_LOSS); UpdateSurvivalStates(); }
    void LoseDebugSleep() { CurrentSleep = Max(0.0, CurrentSleep - CaelumConstants.DEBUG_SURVIVAL_LOSS); UpdateSurvivalStates(); }

    void RefillSurvivalResources()
    {
        CurrentHunger = CaelumConstants.SURVIVAL_MAXIMUM;
        CurrentThirst = CaelumConstants.SURVIVAL_MAXIMUM;
        CurrentSleep = CaelumConstants.SURVIVAL_MAXIMUM;
        UpdateSurvivalStates();
    }

    // A successful jump spends five base air units. It uses the same load
    // multiplier as every other physical air-consuming action.
    void ConsumeJumpAir()
    {
        if (DerivedStats == null)
        {
            return;
        }

        double finalCost = CaelumConstants.JUMP_AIR_COST
            * DerivedStats.AirConsumptionMultiplier;
        CurrentAir = Max(0.0, CurrentAir - finalCost);
        UpdateAirStateEffects();
    }

    // Keep the temporary debug control routed through the exact same function
    // so it remains useful when testing air costs without repeatedly jumping.
    void ConsumeDebugJumpAir()
    {
        ConsumeJumpAir();
    }

    // Restore the current resource to the calculated maximum.
    void RefillAir()
    {
        if (DerivedStats != null)
        {
            CurrentAir = DerivedStats.MaximumAir;
            UpdateAirStateEffects();
        }
    }

    double GetAirRatio()
    {
        if (DerivedStats == null || DerivedStats.MaximumAir <= 0.0)
        {
            return 0.0;
        }

        return CurrentAir / DerivedStats.MaximumAir;
    }

    // Store the state and effective evasion in play scope. The UI reads these
    // fields directly, avoiding forbidden play-to-UI function calls.
    void UpdateAirStateEffects()
    {
        double ratio = GetAirRatio();

        if (ratio <= CaelumConstants.AIR_BREATHLESS_THRESHOLD)
        {
            AirState = CaelumConstants.AIR_STATE_BREATHLESS;
            AirStatePerformanceMultiplier = CaelumConstants.BREATHLESS_PERFORMANCE_MULTIPLIER;
        }
        else if (ratio <= CaelumConstants.AIR_TIRED_THRESHOLD)
        {
            AirState = CaelumConstants.AIR_STATE_TIRED;
            AirStatePerformanceMultiplier = CaelumConstants.TIRED_PERFORMANCE_MULTIPLIER;
        }
        else
        {
            AirState = CaelumConstants.AIR_STATE_NORMAL;
            AirStatePerformanceMultiplier = 1.0;
        }

        if (DerivedStats != null)
        {
            EffectiveEvasionChance = DerivedStats.MassAdjustedEvasionChance
                * AirStatePerformanceMultiplier
                * HealthPerformanceMultiplier;
            EffectiveMovementPercent = DerivedStats.MassAdjustedMovementPercent
                * AirStatePerformanceMultiplier
                * SurvivalPerformanceMultiplier
                * HealthPerformanceMultiplier;
            EffectiveJumpHeightPercent = DerivedStats.MassAdjustedJumpHeightPercent
                * AirStatePerformanceMultiplier
                * SurvivalPerformanceMultiplier
                * HealthPerformanceMultiplier;
        }
    }

    void CycleRace()
    {
        CharacterProfile.CycleRace();
        CharacterAllocation.ResetAllocations();
        ApplyCharacterProfile();
    }

    void CycleFirstClass() { CharacterProfile.CycleFirstClass(); CharacterAllocation.ResetAllocations(); ApplyCharacterProfile(); }
    void CycleSecondClass() { CharacterProfile.CycleSecondClass(); CharacterAllocation.ResetAllocations(); ApplyCharacterProfile(); }
    void CycleSex() { CharacterProfile.CycleSex(); ApplyCharacterProfile(); }
    void CycleHeightChoice() { CharacterProfile.CycleHeight(); ApplyCharacterProfile(); }

    void CycleAllocationLayer()
    {
        CharacterAllocation.CycleSelectedLayer();
    }

    void CycleAllocationAttribute()
    {
        CharacterAllocation.CycleSelectedAttribute();
    }

    void AddSelectedLayerPoint()
    {
        if (CharacterAllocation.TryAddSelectedLayerPoint(CharacterProfile))
        {
            ApplyCharacterProfile();
        }
    }

    void AddSelectedAttributePoint()
    {
        if (CharacterAllocation.TryAddSelectedAttributePoint(CharacterProfile))
        {
            ApplyCharacterProfile();
        }
    }

    void ResetCreationAllocations()
    {
        CharacterAllocation.ResetAllocations();
        ApplyCharacterProfile();
    }

    // Toggle a reversible development override. The normal creation profile
    // and point allocation remain untouched and return when toggled off.
    void ToggleDebugAttributes75()
    {
        DebugAttributesAt75 = !DebugAttributesAt75;
        ApplyCharacterProfile();
        UpdateAirStateEffects();
    }

    // Add five provisional weight units and refresh all derived mass values.
    void AddDebugEquipmentWeight()
    {
        if (DerivedStats == null)
        {
            return;
        }

        DerivedStats.AddDebugWeight(CaelumConstants.DEBUG_WEIGHT_STEP);
        ApplyCharacterProfile();
    }

    // Clear provisional equipment weight without changing character creation.
    void ResetDebugEquipmentWeight()
    {
        if (DerivedStats == null)
        {
            return;
        }

        DerivedStats.ResetDebugWeight();
        ApplyCharacterProfile();
    }

    void BeginCreationWizard()
    {
        if (CreationWizardOpen)
        {
            // El creador inicial es obligatorio y no puede cerrarse sin confirmar.
            if (CharacterCreationComplete)
            {
                CancelCreationWizard();
            }
            return;
        }

        CreationProfileBackup = CaelumCharacterProfile(new("CaelumCharacterProfile"));
        CreationProfileBackup.CopyFrom(CharacterProfile);

        CreationAllocationBackup = CaelumCharacterAllocation(new("CaelumCharacterAllocation"));
        CreationAllocationBackup.CopyFrom(CharacterAllocation);

        CreationWizardPage = CaelumConstants.CREATION_PAGE_RACE;
        CreationWizardOpen = true;
    }

    void CancelCreationWizard()
    {
        if (!CharacterCreationComplete)
        {
            return;
        }

        if (CreationProfileBackup != null && CreationAllocationBackup != null)
        {
            CharacterProfile.CopyFrom(CreationProfileBackup);
            CharacterAllocation.CopyFrom(CreationAllocationBackup);
            ApplyCharacterProfile();
        }

        CreationWizardOpen = false;
    }

    // Change the choice represented by the current wizard page.
    void CycleCurrentCreationChoice()
    {
        switch (CreationWizardPage)
        {
            case CaelumConstants.CREATION_PAGE_RACE:
                CycleRace();
                break;
            case CaelumConstants.CREATION_PAGE_FIRST_CLASS:
                CycleFirstClass();
                break;
            case CaelumConstants.CREATION_PAGE_SECOND_CLASS:
                CycleSecondClass();
                break;
            case CaelumConstants.CREATION_PAGE_SEX:
                CycleSex();
                break;
            case CaelumConstants.CREATION_PAGE_HEIGHT:
                CycleHeightChoice();
                break;
            case CaelumConstants.CREATION_PAGE_LAYERS:
                CycleAllocationLayer();
                break;
            case CaelumConstants.CREATION_PAGE_ATTRIBUTES:
                CycleAllocationAttribute();
                break;
        }
    }

    void AddCurrentCreationPoint()
    {
        if (CreationWizardPage == CaelumConstants.CREATION_PAGE_LAYERS)
        {
            AddSelectedLayerPoint();
        }
        else if (CreationWizardPage == CaelumConstants.CREATION_PAGE_ATTRIBUTES)
        {
            AddSelectedAttributePoint();
        }
    }

    void AdvanceCreationWizard()
    {
        if (!CreationWizardOpen)
        {
            return;
        }

        // Every one of the four free layer points must be assigned.
        if (CreationWizardPage == CaelumConstants.CREATION_PAGE_LAYERS
            && CharacterAllocation.GetRemainingLayerPoints() > 0)
        {
            return;
        }

        // Every one of the thirty individual points must be assigned.
        if (CreationWizardPage == CaelumConstants.CREATION_PAGE_ATTRIBUTES
            && CharacterAllocation.GetRemainingAttributePoints() > 0)
        {
            return;
        }

        if (CreationWizardPage < CaelumConstants.CREATION_PAGE_SUMMARY)
        {
            CreationWizardPage++;
            return;
        }

        // Confirmar por primera vez inicia todos los recursos con el perfil final.
        bool firstConfirmation = !CharacterCreationComplete;
        CharacterCreationComplete = true;
        CreationProfileBackup = null;
        CreationAllocationBackup = null;
        CreationWizardOpen = false;
        ApplyCharacterProfile();

        if (firstConfirmation)
        {
            CaelumMaximumHealth = Max(1, int(DerivedStats.MaximumHealth));
            health = CaelumMaximumHealth;
            if (player != null) { player.health = health; }
            CurrentAnima = DerivedStats.MaximumAnima;
            CurrentAir = DerivedStats.MaximumAir;
            CurrentAdrenaline = 0.0;
            CurrentLucidity = CaelumConstants.MAXIMUM_LUCIDITY;
            RefillSurvivalResources();
            HealthResourceInitialized = true;
            AnimaResourceInitialized = true;
            AirResourceInitialized = true;
            AdrenalineResourceInitialized = true;
            LucidityResourceInitialized = true;
            UpdateHealthStateEffects();
            UpdateAirStateEffects();
            UpdateLucidityState();
        }
    }

    void GoBackCreationWizard()
    {
        if (!CreationWizardOpen)
        {
            return;
        }

        if (CreationWizardPage > CaelumConstants.CREATION_PAGE_RACE)
        {
            CreationWizardPage--;
        }
        else
        {
            // En la creación inicial la primera página es el límite de retroceso.
            if (CharacterCreationComplete)
            {
                CancelCreationWizard();
            }
        }
    }
}
