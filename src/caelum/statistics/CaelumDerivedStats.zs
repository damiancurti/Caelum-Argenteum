// Calcula las estadisticas derivadas del perfil 4.0 y sus doce atributos.
class CaelumDerivedStats : Object
{
    double MaximumHealth;
    double MaximumAnima;
    double AnimaRegenerationPercent;
    double AnimaRegenerationPerSecond;
    double AnimaCostReductionPercent;
    double StaffAnimaCost;
    double CastingSpeedPercent;
    double CastingDurationMultiplier;
    double AbilityRangePercent;
    double DebuffPowerPercent;
    double BuffPowerPercent;
    double InterruptionResistancePercent;
    double DialogueSkillPercent;
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
    double AttackSpeedPercent;
    double AttackDurationMultiplier;
    double MagicalAccuracyPercent;
    double PhysicalCriticalChance;
    double MagicalCriticalChance;
    double StaffCriticalChance;
    double LucidityLossMultiplier;
    double HungerThirstLossMultiplier;
    double SleepLossMultiplier;
    double CarryCapacity;
    int MagicBoxCapacity;

    int MassTier;
    int SizeTier;
    int BaseMass;
    double BaseMassMultiplier;
    double BodyHeightMeters;
    double ActorHeight;
    double ActorRadius;
    double PhysicalPushMultiplier;
    double MagicalPushMultiplier;
    double ArmorWeight;
    double ShieldWeight;
    double WeaponWeight;
    double DebugWeight;
    double EquippedWeight;
    double InventoryWeight;
    double CarriedItemWeight;
    double CarriedWeight;
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

    double CalculateType1Percent(int level)
    {
        return 100.0 + level * (level + 1) / 2.0;
    }

    double CalculateType4Percent(int level)
    {
        return 100.0 + 2.0 * level * (level + 1) / 101.0;
    }

    double CalculateType2Percent(int level)
    {
        return level * (level + 1) / 101.0;
    }

    int GetMassForTier(int tier)
    {
        switch (Clamp(tier, 1, 10))
        {
            case 1: return 50;
            case 2: return 55;
            case 3: return 60;
            case 4: return 70;
            case 5: return 80;
            case 6: return 100;
            case 7: return 120;
            case 8: return 140;
            case 9: return 170;
            default: return 200;
        }
    }

    double GetHeightMetersForTier(int tier)
    {
        return 1.0 + 0.2 * Clamp(tier, 1, 7);
    }

    void SetEquipmentWeights(
        double newArmorWeight,
        double newShieldWeight,
        double newWeaponWeight
    )
    {
        ArmorWeight = Max(0.0, newArmorWeight);
        ShieldWeight = Max(0.0, newShieldWeight);
        WeaponWeight = Max(0.0, newWeaponWeight);
        EquippedWeight = ArmorWeight + ShieldWeight + WeaponWeight;
        CarriedItemWeight = EquippedWeight + InventoryWeight;
        RefreshCarriedWeightTotals();
    }

    void SetInventoryWeight(double newInventoryWeight)
    {
        InventoryWeight = Max(0.0, newInventoryWeight);
        EquippedWeight = ArmorWeight + ShieldWeight + WeaponWeight;
        CarriedItemWeight = EquippedWeight + InventoryWeight;
        RefreshCarriedWeightTotals();
    }

    // El inventario nativo es la fuente autoritativa: todo objeto que no esta
    // en la Caja Magica cuenta una sola vez, equipado o no.
    void SetCarriedLoadBreakdown(
        double newArmorWeight,
        double newShieldWeight,
        double newWeaponWeight,
        double newInventoryWeight,
        double newCarriedItemWeight
    )
    {
        ArmorWeight = Max(0.0, newArmorWeight);
        ShieldWeight = Max(0.0, newShieldWeight);
        WeaponWeight = Max(0.0, newWeaponWeight);
        EquippedWeight = ArmorWeight + ShieldWeight + WeaponWeight;
        InventoryWeight = Max(0.0, newInventoryWeight);
        CarriedItemWeight = Max(
            Max(0.0, newCarriedItemWeight),
            EquippedWeight + InventoryWeight
        );
        RefreshCarriedWeightTotals();
    }

    // Los setters de peso pueden ejecutarse desde la vista previa del menú,
    // fuera de un recálculo completo. Mantener estos cuatro valores atómicos
    // evita que el HUD quede mostrando una carga anterior indefinidamente.
    void RefreshCarriedWeightTotals()
    {
        EquippedWeight = ArmorWeight + ShieldWeight + WeaponWeight;
        CarriedWeight = CarriedItemWeight + DebugWeight;
        TotalMass = BaseMass + CarriedWeight;
        LoadRatio = CarryCapacity > 0.0 ? CarriedWeight / CarryCapacity : 0.0;
    }

    void AddDebugWeight(double amount)
    {
        DebugWeight = Max(0.0, DebugWeight + amount);
        RefreshCarriedWeightTotals();
    }

    void ResetDebugWeight()
    {
        DebugWeight = 0.0;
        RefreshCarriedWeightTotals();
    }
    bool HasOverload() { return LoadRatio >= CaelumConstants.OVERLOAD_THRESHOLD; }
    bool HasExceededCapacity() { return LoadRatio >= 1.0; }

    double CalculateLoadAirMultiplier(double loadRatio)
    {
        double threshold = CaelumConstants.OVERLOAD_THRESHOLD;
        if (loadRatio <= threshold) return 1.0 + loadRatio;
        return 1.0 + threshold + 2.0 * (loadRatio - threshold);
    }

    void Recalculate(CaelumAttributes attributes, CaelumCharacterProfile profile)
    {
        MassTier = profile.GetMassTier();
        SizeTier = profile.GetSizeTier();
        BaseMass = GetMassForTier(MassTier);
        BaseMassMultiplier = BaseMass / 100.0;
        BodyHeightMeters = GetHeightMetersForTier(SizeTier);
        double sizeFactor = BodyHeightMeters / 1.8;
        ActorHeight = 56.0 * sizeFactor;
        ActorRadius = 16.0 * sizeFactor;

        MaximumHealth = CaelumConstants.HEALTH_ANIMA_DAMAGE_SCALE
            * CalculateType1Percent(attributes.Constitution)
            * BaseMassMultiplier;
        MaximumAnima = CaelumConstants.HEALTH_ANIMA_DAMAGE_SCALE
            * CalculateType1Percent(attributes.Patience);

        HealthRegenerationPercent = CalculateType4Percent(attributes.Resilience);
        HealthRegenerationPerSecond = MaximumHealth
            / CaelumConstants.HEALTH_BASE_RECOVERY_REAL_SECONDS
            * HealthRegenerationPercent / 100.0;
        MaximumAdrenaline = 100.0 * CaelumConstants.ADRENALINE_CAPACITY_SCALE
            * CalculateType4Percent(attributes.Resilience) / 100.0;

        MeleeDamagePercent = CalculateType1Percent(attributes.Strength);
        // El empuje fisico usa Fuerza y masa corporal; el magico usa
        // Inteligencia sin masa corporal, pero ambos enfrentan la misma
        // resistencia del receptor.
        PhysicalPushMultiplier = MeleeDamagePercent / 100.0
            * BaseMassMultiplier;
        MagicalPushMultiplier = CalculateType1Percent(attributes.Intelligence)
            / 100.0;
        DebugSwordDamage = CaelumConstants.DEBUG_SWORD_BASE_DAMAGE
            * MeleeDamagePercent / 100.0 * BaseMassMultiplier;
        DebugStaffDamage = CaelumConstants.DEBUG_STAFF_BASE_DAMAGE
            * CalculateType1Percent(attributes.Intelligence) / 100.0;

        PhysicalAccuracyPercent = CalculateType1Percent(attributes.Dexterity);
        AttackSpeedPercent = CalculateType4Percent(attributes.Dexterity);
        AttackDurationMultiplier = 100.0 / Max(1.0, AttackSpeedPercent);
        MagicalAccuracyPercent = CalculateType1Percent(attributes.Insight);
        PhysicalCriticalChance = Clamp(CaelumConstants.BASE_CRITICAL_CHANCE_PERCENT
            + CalculateType2Percent(attributes.Dexterity), 0.0, 100.0);
        MagicalCriticalChance = Clamp(CaelumConstants.BASE_CRITICAL_CHANCE_PERCENT
            + CalculateType2Percent(attributes.Insight), 0.0, 100.0);
        StaffCriticalChance = Clamp(CaelumConstants.DEBUG_STAFF_BASE_CRITICAL_CHANCE_PERCENT
            + CalculateType2Percent(attributes.Insight), 0.0, 100.0);

        PainChanceMultiplier = Clamp(1.0
            - attributes.Toughness * (attributes.Toughness + 1) / 10100.0,
            0.0, 1.0);
        DamageResistanceMultiplier = PainChanceMultiplier;
        LucidityLossMultiplier = PainChanceMultiplier;
        HealthPenaltyMultiplier = Clamp(1.0
            - attributes.Patience * (attributes.Patience + 1) / 10100.0,
            0.0, 1.0);

        HungerThirstLossMultiplier = Clamp(1.0
            - attributes.Constitution * (attributes.Constitution + 1) / 10100.0,
            0.0, 1.0) * BaseMassMultiplier;
        SleepLossMultiplier = Clamp(1.0
            - attributes.Resilience * (attributes.Resilience + 1) / 10100.0,
            0.0, 1.0);

        AnimaRegenerationPercent = CalculateType4Percent(attributes.Patience);
        AnimaRegenerationPerSecond = MaximumAnima
            / CaelumConstants.ANIMA_FULL_RECOVERY_SECONDS
            * AnimaRegenerationPercent / 100.0;
        AnimaCostReductionPercent = Clamp(CalculateType2Percent(attributes.Eloquence), 0.0, 100.0);
        StaffAnimaCost = CaelumConstants.DEBUG_STAFF_ANIMA_COST
            * (1.0 - AnimaCostReductionPercent / 100.0);
        CastingSpeedPercent = CalculateType4Percent(attributes.Eloquence);
        CastingDurationMultiplier = 100.0 / CastingSpeedPercent;
        AbilityRangePercent = CastingSpeedPercent;
        DebuffPowerPercent = CalculateType4Percent(attributes.Charisma);
        BuffPowerPercent = CalculateType4Percent(attributes.Empathy);
        InterruptionResistancePercent = Clamp(
            CalculateType2Percent(attributes.Patience), 0.0, 100.0
        );
        DialogueSkillPercent = CalculateType2Percent(attributes.Eloquence);

        MaximumAir = CaelumConstants.BASE_AIR_CAPACITY
            * CalculateType4Percent(attributes.Resilience) / 100.0;
        // La masa base es la capacidad a Fuerza 0; el Tipo 4 la lleva a x3 en
        // nivel 100. Ejemplo: masa 200 produce capacidad 200 y luego 600.
        CarryCapacity = BaseMass
            * CalculateType4Percent(attributes.Strength) / 100.0;
        MagicBoxCapacity = 2 + int(
            CalculateType1Percent(attributes.Intelligence) / 50.0
        );
        RefreshCarriedWeightTotals();
        PushResistance = TotalMass / 100.0;
        KnockbackMultiplier = 100.0 / (TotalMass + 50.0);
        MovementMultiplier = 100.0 / (TotalMass / 2.0 + 50.0);
        AirConsumptionMultiplier = BaseMassMultiplier
            * CalculateLoadAirMultiplier(LoadRatio);
        AirRegenerationPerSecond = MaximumAir / CaelumConstants.AIR_FULL_RECOVERY_SECONDS;
        EvasionMassMultiplier = MovementMultiplier;
        BaseEvasionChance = CalculateType2Percent(attributes.Agility);
        MassAdjustedEvasionChance = BaseEvasionChance * EvasionMassMultiplier;
        BaseMovementPercent = CalculateType4Percent(attributes.Agility);
        MassAdjustedMovementPercent = BaseMovementPercent * MovementMultiplier;
        BaseJumpHeightPercent = CalculateType1Percent(attributes.Agility);
        MassAdjustedJumpHeightPercent = BaseJumpHeightPercent * MovementMultiplier;
    }
}
