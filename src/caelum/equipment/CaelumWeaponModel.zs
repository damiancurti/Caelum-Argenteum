// Modelo de la mano habil. La mano secundaria continua representada por el
// escudo y determina si AltFire bloquea o queda disponible para el arma.
class CaelumWeaponModel : Object
{
    int WeaponType;
    int Tier;
    int Size;
    int Durability;
    bool Equipped;
    bool Initialized;

    void InitializeDefaults()
    {
        if (Initialized) { return; }
        WeaponType = CaelumConstants.WEAPON_TYPE_SWORD;
        Tier = 1;
        Size = CaelumConstants.EQUIPMENT_SIZE_M;
        Durability = GetMaximumDurability();
        Equipped = true;
        Initialized = true;
    }

    double GetTierDamageMultiplierFor(int tier)
    {
        if (tier <= 1) { return 1.0; }
        if (tier == 2) { return 1.2; }
        return 1.5;
    }

    double GetTierOneWeightFor(int weaponType)
    {
        switch (Clamp(weaponType, 0, CaelumConstants.WEAPON_TYPE_COUNT - 1))
        {
            case CaelumConstants.WEAPON_TYPE_STAFF:
                return CaelumConstants.WEAPON_STAFF_TIER_ONE_WEIGHT;
            case CaelumConstants.WEAPON_TYPE_CARBINE:
                return CaelumConstants.WEAPON_CARBINE_TIER_ONE_WEIGHT;
            default:
                return CaelumConstants.WEAPON_SWORD_TIER_ONE_WEIGHT;
        }
    }

    double GetWeightFor(int weaponType, int tier, int equipmentSize)
    {
        return CaelumEquipmentRules.CalculateTieredEquipmentWeight(
            GetTierOneWeightFor(weaponType), tier, equipmentSize
        );
    }

    double GetWeight()
    {
        if (!Equipped) { return 0.0; }
        return GetWeightFor(WeaponType, Tier, Size);
    }

    double GetTierOneDamageFor(int weaponType)
    {
        switch (Clamp(weaponType, 0, CaelumConstants.WEAPON_TYPE_COUNT - 1))
        {
            case CaelumConstants.WEAPON_TYPE_STAFF:
                return CaelumConstants.DEBUG_STAFF_BASE_DAMAGE;
            case CaelumConstants.WEAPON_TYPE_CARBINE:
                return CaelumConstants.CARBINE_TIER_ONE_DAMAGE;
            default:
                return CaelumConstants.DEBUG_SWORD_BASE_DAMAGE;
        }
    }

    double GetDamageFor(int weaponType, int tier)
    {
        return GetTierOneDamageFor(weaponType)
            * GetTierDamageMultiplierFor(tier);
    }

    double GetDamage()
    {
        return GetDamageFor(WeaponType, Tier);
    }

    int GetBaseDurabilityFor(int weaponType)
    {
        switch (Clamp(weaponType, 0, CaelumConstants.WEAPON_TYPE_COUNT - 1))
        {
            case CaelumConstants.WEAPON_TYPE_STAFF:
                return CaelumConstants.WEAPON_STAFF_BASE_DURABILITY;
            case CaelumConstants.WEAPON_TYPE_CARBINE:
                return CaelumConstants.WEAPON_CARBINE_BASE_DURABILITY;
            default:
                return CaelumConstants.WEAPON_SWORD_BASE_DURABILITY;
        }
    }

    int GetMaximumDurabilityFor(int weaponType, int tier, int equipmentSize)
    {
        int tierMultiplier = 1;
        if (tier == 2) { tierMultiplier = 3; }
        else if (tier >= 3) { tierMultiplier = 9; }
        return CaelumEquipmentRules.ScaleDurabilityForSize(
            GetBaseDurabilityFor(weaponType) * tierMultiplier,
            equipmentSize
        );
    }

    int GetMaximumDurability()
    {
        return GetMaximumDurabilityFor(WeaponType, Tier, Size);
    }

    int GetAttackTicsFor(int weaponType)
    {
        switch (Clamp(weaponType, 0, CaelumConstants.WEAPON_TYPE_COUNT - 1))
        {
            case CaelumConstants.WEAPON_TYPE_STAFF:
                return CaelumConstants.DEBUG_STAFF_CAST_TICS;
            case CaelumConstants.WEAPON_TYPE_CARBINE:
                return CaelumConstants.CARBINE_TIER_ONE_FIRE_TICS;
            default:
                return CaelumConstants.WEAPON_SWORD_ATTACK_TICS;
        }
    }

    int GetAttackTics()
    {
        return GetAttackTicsFor(WeaponType);
    }

    double GetAirCostFor(int weaponType)
    {
        if (weaponType == CaelumConstants.WEAPON_TYPE_SWORD)
        {
            return CaelumConstants.DEBUG_SWORD_PRIMARY_AIR_COST;
        }
        if (weaponType == CaelumConstants.WEAPON_TYPE_CARBINE)
        {
            return -CaelumConstants.CARBINE_AIR_CHANGE;
        }
        return 0.0;
    }

    double GetAnimaCostFor(int weaponType)
    {
        return weaponType == CaelumConstants.WEAPON_TYPE_STAFF
            ? CaelumConstants.DEBUG_STAFF_ANIMA_COST : 0.0;
    }

    bool IsMagical()
    {
        return WeaponType == CaelumConstants.WEAPON_TYPE_STAFF;
    }
}
