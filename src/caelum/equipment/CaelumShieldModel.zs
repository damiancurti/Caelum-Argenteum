// Provisional shield data used by the blocking test. The documented values are
// tier 2; tier 1 subtracts ten points and tier 3 adds ten points.
class CaelumShieldModel : Object
{
    int ShieldType;
    int Tier;
    int Size;
    int Durability;
    bool Equipped;
    bool EquippedStateInitialized;
    bool Initialized;

    void InitializeDefaults()
    {
        if (Initialized) { return; }
        ShieldType = CaelumConstants.SHIELD_TYPE_BUCKLER;
        Tier = 1;
        Size = CaelumConstants.EQUIPMENT_SIZE_M;
        Durability = GetMaximumDurability();
        Equipped = true;
        EquippedStateInitialized = true;
        Initialized = true;
    }

    void EnsureEquippedStateInitialized()
    {
        if (EquippedStateInitialized) { return; }
        Equipped = true;
        EquippedStateInitialized = true;
    }

    double GetBaseTierOneWeight(int shieldType)
    {
        switch (Clamp(shieldType, 0, CaelumConstants.SHIELD_TYPE_COUNT - 1))
        {
            case CaelumConstants.SHIELD_TYPE_MAGIC: return 4.0;
            case CaelumConstants.SHIELD_TYPE_BUCKLER: return 8.0;
            case CaelumConstants.SHIELD_TYPE_KITE: return 12.0;
            default: return 16.0;
        }
    }

    double GetWeightFor(int shieldType, int tier, int equipmentSize)
    {
        return CaelumEquipmentRules.CalculateTieredEquipmentWeight(
            GetBaseTierOneWeight(shieldType), tier, equipmentSize
        );
    }

    double GetWeight()
    {
        if (!Equipped) { return 0.0; }
        return GetWeightFor(ShieldType, Tier, Size);
    }

    int GetCoverageDegrees()
    {
        if (!Equipped) { return 0; }
        switch (ShieldType)
        {
            case CaelumConstants.SHIELD_TYPE_KITE: return 140;
            case CaelumConstants.SHIELD_TYPE_TOWER: return 160;
            default: return 120;
        }
    }

    int GetBasePhysicalDefense()
    {
        switch (ShieldType)
        {
            case CaelumConstants.SHIELD_TYPE_BUCKLER: return 60;
            case CaelumConstants.SHIELD_TYPE_KITE: return 80;
            case CaelumConstants.SHIELD_TYPE_TOWER: return 90;
            default: return 50;
        }
    }

    int GetBaseMagicalDefense()
    {
        if (ShieldType == CaelumConstants.SHIELD_TYPE_MAGIC) { return 90; }
        return GetBasePhysicalDefense();
    }

    int GetDefense(int damageKind)
    {
        if (!Equipped || Durability <= 0) { return 0; }
        int tierTwoDefense = damageKind == CaelumConstants.SHIELD_DAMAGE_MAGICAL
            ? GetBaseMagicalDefense() : GetBasePhysicalDefense();
        int tierOffset = (Clamp(Tier, 1, 3) - 2) * 10;
        return Max(0, tierTwoDefense + tierOffset);
    }

    int GetBaseDurability()
    {
        switch (ShieldType)
        {
            case CaelumConstants.SHIELD_TYPE_BUCKLER: return 80;
            case CaelumConstants.SHIELD_TYPE_KITE: return 150;
            case CaelumConstants.SHIELD_TYPE_TOWER: return 250;
            default: return 100;
        }
    }

    int GetMaximumDurability()
    {
        return GetMaximumDurabilityFor(ShieldType, Tier, Size);
    }

    int GetMaximumDurabilityFor(int shieldType, int tier, int equipmentSize)
    {
        int baseDurability = 100;
        switch (Clamp(shieldType, 0, CaelumConstants.SHIELD_TYPE_COUNT - 1))
        {
            case CaelumConstants.SHIELD_TYPE_BUCKLER: baseDurability = 80; break;
            case CaelumConstants.SHIELD_TYPE_KITE: baseDurability = 150; break;
            case CaelumConstants.SHIELD_TYPE_TOWER: baseDurability = 250; break;
        }
        int multiplier = 1;
        if (tier == 2) { multiplier = 3; }
        else if (tier >= 3) { multiplier = 9; }
        return CaelumEquipmentRules.ScaleDurabilityForSize(
            baseDurability * multiplier,
            equipmentSize
        );
    }

    void CycleType()
    {
        Equipped = true;
        ShieldType = (ShieldType + 1) % CaelumConstants.SHIELD_TYPE_COUNT;
        Durability = GetMaximumDurability();
    }

    void CycleTier()
    {
        Equipped = true;
        Tier++;
        if (Tier > 3) { Tier = 1; }
        Durability = GetMaximumDurability();
    }

    void CycleSize()
    {
        Equipped = true;
        Size = (Size + 1) % CaelumConstants.EQUIPMENT_SIZE_COUNT;
        Durability = GetMaximumDurability();
    }

    void Repair() { Durability = GetMaximumDurability(); }
}
