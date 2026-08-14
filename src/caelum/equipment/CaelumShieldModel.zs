// Provisional shield data used by the blocking test. The documented values are
// tier 2; tier 1 subtracts ten points and tier 3 adds ten points.
class CaelumShieldModel : Object
{
    int ShieldType;
    int Tier;
    int Durability;
    bool Initialized;

    void InitializeDefaults()
    {
        if (Initialized) { return; }
        ShieldType = CaelumConstants.SHIELD_TYPE_BUCKLER;
        Tier = 1;
        Durability = GetMaximumDurability();
        Initialized = true;
    }

    int GetWeight()
    {
        switch (ShieldType)
        {
            case CaelumConstants.SHIELD_TYPE_BUCKLER: return 8;
            case CaelumConstants.SHIELD_TYPE_KITE: return 14;
            case CaelumConstants.SHIELD_TYPE_TOWER: return 18;
            default: return 6;
        }
    }

    int GetCoverageDegrees()
    {
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
        if (Durability <= 0) { return 0; }
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
        int multiplier = 1;
        if (Tier == 2) { multiplier = 3; }
        else if (Tier >= 3) { multiplier = 9; }
        return GetBaseDurability() * multiplier;
    }

    void CycleType()
    {
        ShieldType = (ShieldType + 1) % CaelumConstants.SHIELD_TYPE_COUNT;
        Durability = GetMaximumDurability();
    }

    void CycleTier()
    {
        Tier++;
        if (Tier > 3) { Tier = 1; }
        Durability = GetMaximumDurability();
    }

    void Repair() { Durability = GetMaximumDurability(); }
}
