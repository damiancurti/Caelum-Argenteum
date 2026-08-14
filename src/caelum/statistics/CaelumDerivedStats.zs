// Calculates gameplay statistics derived from primary attributes and profile.
// Values remain separate from Doom's native health/ammo until their formulas
// have been verified in the debug panel.
class CaelumDerivedStats : Object
{
    double MaximumHealth;
    double MaximumMana;
    double ManaRegenerationPercent;
    double ManaRegenerationPerSecond;
    double HealthRegenerationPercent;
    double HealthRegenerationPerSecond;
    double MaximumAir;
    double MaximumAdrenaline;
    double PainChanceMultiplier;
    double DamageResistanceMultiplier;
    double HealthPenaltyMultiplier;
    double MeleeDamagePercent;
    double DebugSwordDamage;
    double DebugStaffDamage;
    double PhysicalAccuracyPercent;
    double MagicalAccuracyPercent;
    double PhysicalCriticalChance;
    double MagicalCriticalChance;
    double StaffCriticalChance;
    double LucidityLossMultiplier;
    double HungerThirstLossMultiplier;
    double SleepLossMultiplier;
    double CarryCapacity;
    int BaseMass;

    // EquippedWeight is provisional until the equipment system supplies the
    // real sum. Keeping it here lets us verify every mass formula first.
    double EquippedWeight;
    double TotalMass;
    double LoadRatio;
    double PushResistance;
    double KnockbackMultiplier;
    double MovementMultiplier;
    double AirConsumptionMultiplier;
    double AirRegenerationPerSecond;
    double EvasionMassMultiplier;
    double BaseEvasionChance;
    double MassAdjustedEvasionChance;
    double BaseMovementPercent;
    double MassAdjustedMovementPercent;
    double BaseJumpHeightPercent;
    double MassAdjustedJumpHeightPercent;

    // Type 1: 100% + [level * (level + 1) / 2]%.
    double CalculateType1Percent(int level)
    {
        return 100.0 + (level * (level + 1) / 2.0);
    }

    // Type 4: 100% + 2 * [level * (level + 1) / 101]%.
    // Its reference endpoint is exactly 300% at attribute level 100.
    double CalculateType4Percent(int level)
    {
        return 100.0 + (2.0 * level * (level + 1) / 101.0);
    }

    // Type 2: level * (level + 1) / 101 percent.
    double CalculateType2Percent(int level)
    {
        return level * (level + 1) / 101.0;
    }

    int GetIdentityBaseMass(int identity)
    {
        switch (identity)
        {
            case CaelumConstants.IDENTITY_FEDERAL: return 70;
            case CaelumConstants.IDENTITY_UNITARIAN: return 65;
            case CaelumConstants.IDENTITY_BEAST: return 85;
            default: return 60;
        }
    }

    int GetClassMassModifier(int characterClass)
    {
        switch (characterClass)
        {
            case CaelumConstants.CLASS_WARRIOR: return 10;
            case CaelumConstants.CLASS_EXPLORER: return 0;
            case CaelumConstants.CLASS_PRIEST: return -5;
            default: return -10;
        }
    }

    // Add a non-negative amount of temporary equipped weight.
    void AddDebugWeight(double amount)
    {
        EquippedWeight = Max(0.0, EquippedWeight + amount);
    }

    // Remove all provisional equipment so the character returns to base mass.
    void ResetDebugWeight()
    {
        EquippedWeight = 0.0;
    }

    bool HasOverload()
    {
        return LoadRatio > CaelumConstants.OVERLOAD_THRESHOLD;
    }

    bool HasExceededCapacity()
    {
        return LoadRatio > 1.0;
    }

    // Air use increases by the carried-load percentage up to 75% capacity.
    // Above 75%, only the excess grows at twice the normal rate.
    // Examples: 50% = x1.50, 75% = x1.75, 80% = x1.85, 100% = x2.25.
    double CalculateAirConsumptionMultiplier(double loadRatio)
    {
        double threshold = CaelumConstants.OVERLOAD_THRESHOLD;

        if (loadRatio <= threshold)
        {
            return 1.0 + loadRatio;
        }

        return 1.0 + threshold + 2.0 * (loadRatio - threshold);
    }

    void Recalculate(
        CaelumAttributes attributes,
        CaelumCharacterProfile profile
    )
    {
        // Type 1 percentages are now applied to a 1000-point base scale.
        MaximumHealth = CaelumConstants.HEALTH_MANA_DAMAGE_SCALE
            * CalculateType1Percent(attributes.Constitution);
        MaximumMana = CaelumConstants.HEALTH_MANA_DAMAGE_SCALE
            * CalculateType1Percent(attributes.Patience);

        HealthRegenerationPercent = CalculateType4Percent(attributes.Resilience);
        HealthRegenerationPerSecond = MaximumHealth
            / CaelumConstants.HEALTH_BASE_RECOVERY_REAL_SECONDS
            * HealthRegenerationPercent / 100.0;

        // Adrenaline uses the ten-times 1000-point base and Resilience Type 4.
        // Level zero gives 1000; level one hundred gives exactly 3000.
        MaximumAdrenaline = 100.0
            * CaelumConstants.ADRENALINE_CAPACITY_SCALE
            * CalculateType4Percent(attributes.Resilience) / 100.0;

        // Fuerza Type 1 multiplies the weapon's base melee damage. The first
        // live test uses the documented sword primary value before location.
        MeleeDamagePercent = CalculateType1Percent(attributes.Strength);
        DebugSwordDamage = CaelumConstants.DEBUG_SWORD_BASE_DAMAGE
            * MeleeDamagePercent / 100.0;
        DebugStaffDamage = CaelumConstants.DEBUG_STAFF_BASE_DAMAGE
            * CalculateType1Percent(attributes.Intelligence) / 100.0;

        // Physical and magical accuracy use their documented Type 1 sources.
        // Temporary states multiply these shared values in CaelumPlayer so
        // later melee cones, projectiles, and spells can reuse one pipeline.
        PhysicalAccuracyPercent = CalculateType1Percent(attributes.Dexterity);
        MagicalAccuracyPercent = CalculateType1Percent(attributes.Insight);

        // Every critical roll begins at five percent. Physical attacks use
        // Dexterity Type 2; magical attacks reserve the same rule for Insight.
        PhysicalCriticalChance = Clamp(
            CaelumConstants.BASE_CRITICAL_CHANCE_PERCENT
                + CalculateType2Percent(attributes.Dexterity),
            0.0,
            100.0
        );
        MagicalCriticalChance = Clamp(
            CaelumConstants.BASE_CRITICAL_CHANCE_PERCENT
                + CalculateType2Percent(attributes.Insight),
            0.0,
            100.0
        );
        StaffCriticalChance = Clamp(
            CaelumConstants.DEBUG_STAFF_BASE_CRITICAL_CHANCE_PERCENT
                + CalculateType2Percent(attributes.Insight),
            0.0,
            100.0
        );

        // Dureza Type 3 reduces both pain chance and classified lucidity loss.
        // It falls from x1 at level zero to x0 at level one hundred.
        PainChanceMultiplier = 1.0
            - attributes.Toughness * (attributes.Toughness + 1) / 10100.0;
        PainChanceMultiplier = Clamp(PainChanceMultiplier, 0.0, 1.0);
        DamageResistanceMultiplier = PainChanceMultiplier;
        LucidityLossMultiplier = PainChanceMultiplier;

        // Patience reduces the detrimental part of wounded/badly-wounded
        // states with Type 3. It does not reduce their beneficial adrenaline gain.
        HealthPenaltyMultiplier = 1.0
            - attributes.Patience * (attributes.Patience + 1) / 10100.0;
        HealthPenaltyMultiplier = Clamp(HealthPenaltyMultiplier, 0.0, 1.0);

        // Constitution slows hunger and thirst; Resilience slows sleep loss.
        // Type 3 reaches a zero multiplier at attribute level 100.
        HungerThirstLossMultiplier = 1.0
            - attributes.Constitution * (attributes.Constitution + 1) / 10100.0;
        SleepLossMultiplier = 1.0
            - attributes.Resilience * (attributes.Resilience + 1) / 10100.0;
        HungerThirstLossMultiplier = Clamp(HungerThirstLossMultiplier, 0.0, 1.0);
        SleepLossMultiplier = Clamp(SleepLossMultiplier, 0.0, 1.0);

        // Patience controls mana twice: Type 1 sets capacity and Type 4
        // multiplies the documented base eight-minute recovery speed.
        ManaRegenerationPercent = CalculateType4Percent(attributes.Patience);
        ManaRegenerationPerSecond = MaximumMana
            / CaelumConstants.MANA_FULL_RECOVERY_SECONDS
            * ManaRegenerationPercent / 100.0;

        // Convert Type 4's percentage into an amount based on 1000 air.
        // Level 0 gives 1000 and level 100 gives 3000.
        MaximumAir = CaelumConstants.BASE_AIR_CAPACITY
            * CalculateType4Percent(attributes.Resilience) / 100.0;

        // The design defines a base carry capacity of 100 units.
        // Strength modifies that base value according to Type 1 growth.
        CarryCapacity = CalculateType1Percent(attributes.Strength);

        BaseMass = GetIdentityBaseMass(profile.Identity)
            + GetClassMassModifier(profile.CharacterClass);

        // Document 14: total mass combines the body and equipped items.
        TotalMass = BaseMass + EquippedWeight;

        // Ratio 1.0 means the player is carrying exactly the maximum capacity.
        LoadRatio = EquippedWeight / CarryCapacity;

        // These factors remain data-only in this version. A later version will
        // connect them to movement, air consumption, evasion, and knockback.
        PushResistance = TotalMass / 100.0;
        KnockbackMultiplier = 100.0 / (TotalMass + 50.0);
        MovementMultiplier = 100.0 / (TotalMass / 2.0 + 50.0);
        // Air consumption depends on equipped load, not on the character's
        // natural body mass. At zero equipment weight the factor remains x1.
        AirConsumptionMultiplier = CalculateAirConsumptionMultiplier(LoadRatio);

        // A larger Resilience-derived air pool regenerates proportionally
        // faster, so a complete refill always takes the documented 8 minutes.
        AirRegenerationPerSecond = MaximumAir
            / CaelumConstants.AIR_FULL_RECOVERY_SECONDS;
        EvasionMassMultiplier = MovementMultiplier;

        // Agility supplies the base chance. Mass modifies it before temporary
        // resource states such as tired or breathless are applied by the player.
        BaseEvasionChance = CalculateType2Percent(attributes.Agility);
        MassAdjustedEvasionChance = BaseEvasionChance * EvasionMassMultiplier;

        // Agility Type 4 applies to ground, swimming, and flight movement.
        // JumpZ deliberately uses a 100% base plus Type 2, reaching 200% at
        // level 100 because geometric jump height grows approximately with
        // the square of the vertical launch velocity.
        BaseMovementPercent = CalculateType4Percent(attributes.Agility);
        MassAdjustedMovementPercent = BaseMovementPercent * MovementMultiplier;
        BaseJumpHeightPercent = 100.0 + CalculateType2Percent(attributes.Agility);
        MassAdjustedJumpHeightPercent = BaseJumpHeightPercent * MovementMultiplier;
    }
}
