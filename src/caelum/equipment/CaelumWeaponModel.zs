// Modelo de la mano habil. La mano secundaria continua representada por el
// escudo y determina si AltFire bloquea o queda disponible para el arma.
class CaelumWeaponModel : Object
{
    int WeaponType;
    int Tier;
    int Size;
    int Durability;
    int EssenceType;
    bool Equipped;
    bool Initialized;

    void InitializeDefaults()
    {
        if (Initialized) { return; }
        WeaponType = CaelumConstants.WEAPON_TYPE_SWORD;
        Tier = 1;
        Size = CaelumConstants.EQUIPMENT_SIZE_M;
        Durability = GetMaximumDurability();
        EssenceType = CaelumConstants.ESSENCE_FIRE;
        Equipped = false;
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
            case CaelumConstants.WEAPON_TYPE_SWORD: return CaelumConstants.WEAPON_SWORD_TIER_ONE_WEIGHT;
            case CaelumConstants.WEAPON_TYPE_STAFF: return CaelumConstants.WEAPON_STAFF_TIER_ONE_WEIGHT;
            case CaelumConstants.WEAPON_TYPE_CARBINE: return CaelumConstants.WEAPON_CARBINE_TIER_ONE_WEIGHT;
            case CaelumConstants.WEAPON_TYPE_DAGGER: return CaelumConstants.WEAPON_DAGGER_TIER_ONE_WEIGHT;
            case CaelumConstants.WEAPON_TYPE_HATCHET: return CaelumConstants.WEAPON_HATCHET_TIER_ONE_WEIGHT;
            case CaelumConstants.WEAPON_TYPE_MACHETE: return CaelumConstants.WEAPON_MACHETE_TIER_ONE_WEIGHT;
            case CaelumConstants.WEAPON_TYPE_JAVELIN: return CaelumConstants.WEAPON_JAVELIN_TIER_ONE_WEIGHT;
            case CaelumConstants.WEAPON_TYPE_AXE: return CaelumConstants.WEAPON_AXE_TIER_ONE_WEIGHT;
            case CaelumConstants.WEAPON_TYPE_FLAIL: return CaelumConstants.WEAPON_FLAIL_TIER_ONE_WEIGHT;
            case CaelumConstants.WEAPON_TYPE_SPEAR: return CaelumConstants.WEAPON_SPEAR_TIER_ONE_WEIGHT;
            case CaelumConstants.WEAPON_TYPE_GREATSWORD: return CaelumConstants.WEAPON_GREATSWORD_TIER_ONE_WEIGHT;
            case CaelumConstants.WEAPON_TYPE_WAR_AXE: return CaelumConstants.WEAPON_WAR_AXE_TIER_ONE_WEIGHT;
            case CaelumConstants.WEAPON_TYPE_HALBERD: return CaelumConstants.WEAPON_HALBERD_TIER_ONE_WEIGHT;
            case CaelumConstants.WEAPON_TYPE_GIANT_GAUNTLETS: return CaelumConstants.WEAPON_GIANT_GAUNTLETS_TIER_ONE_WEIGHT;
            case CaelumConstants.WEAPON_TYPE_STANDARD_BOW: return CaelumConstants.WEAPON_STANDARD_BOW_TIER_ONE_WEIGHT;
            case CaelumConstants.WEAPON_TYPE_LONGBOW: return CaelumConstants.WEAPON_LONGBOW_TIER_ONE_WEIGHT;
            case CaelumConstants.WEAPON_TYPE_CROSSBOW: return CaelumConstants.WEAPON_CROSSBOW_TIER_ONE_WEIGHT;
            case CaelumConstants.WEAPON_TYPE_BELL: return CaelumConstants.WEAPON_BELL_TIER_ONE_WEIGHT;
            case CaelumConstants.WEAPON_TYPE_BOOK: return CaelumConstants.WEAPON_BOOK_TIER_ONE_WEIGHT;
            default: return CaelumConstants.WEAPON_STATUETTE_TIER_ONE_WEIGHT;
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
        int catalogueWeapon = CaelumCraftingRules.GetCatalogueWeaponForPlayableType(
            weaponType
        );
        if (catalogueWeapon >= 0)
        {
            return CaelumWeaponCatalogue.GetPrimaryDamage(catalogueWeapon);
        }
        switch (weaponType)
        {
            case CaelumConstants.WEAPON_TYPE_BELL:
                return CaelumConstants.WEAPON_BELL_BASE_DAMAGE;
            case CaelumConstants.WEAPON_TYPE_BOOK: return 120.0;
            case CaelumConstants.WEAPON_TYPE_STATUETTE: return 140.0;
            default: return CaelumConstants.DEBUG_STAFF_BASE_DAMAGE;
        }
    }

    bool IsRangedPhysicalType(int weaponType)
    {
        return weaponType == CaelumConstants.WEAPON_TYPE_STANDARD_BOW
            || weaponType == CaelumConstants.WEAPON_TYPE_LONGBOW
            || weaponType == CaelumConstants.WEAPON_TYPE_CROSSBOW
            || weaponType == CaelumConstants.WEAPON_TYPE_CARBINE;
    }

    double GetRangedTierMultiplierFor(int tier)
    {
        if (tier <= 1) { return 1.0; }
        if (tier == 2) { return 1.60; }
        return 2.50;
    }

    double GetDamageFor(int weaponType, int tier)
    {
        double tierMultiplier = IsRangedPhysicalType(weaponType)
            ? GetRangedTierMultiplierFor(tier)
            : GetTierDamageMultiplierFor(tier);
        return GetTierOneDamageFor(weaponType) * tierMultiplier;
    }

    double GetDamage()
    {
        return GetDamageFor(WeaponType, Tier);
    }

    int GetBaseDurabilityFor(int weaponType)
    {
        if (weaponType == CaelumConstants.WEAPON_TYPE_CARBINE)
        {
            return CaelumConstants.WEAPON_CARBINE_BASE_DURABILITY;
        }
        if (IsMagicalType(weaponType))
        {
            return CaelumConstants.WEAPON_ESSENCE_BASE_DURABILITY;
        }
        return CaelumConstants.WEAPON_PHYSICAL_BASE_DURABILITY;
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
        int catalogueWeapon = CaelumCraftingRules.GetCatalogueWeaponForPlayableType(
            weaponType
        );
        if (catalogueWeapon >= 0)
        {
            return CaelumWeaponCatalogue.GetAttackTics(catalogueWeapon);
        }
        switch (weaponType)
        {
            case CaelumConstants.WEAPON_TYPE_BELL: return 22;
            case CaelumConstants.WEAPON_TYPE_BOOK: return 16;
            case CaelumConstants.WEAPON_TYPE_STATUETTE: return 24;
            default: return CaelumConstants.DEBUG_STAFF_CAST_TICS;
        }
    }

    int GetAttackTics()
    {
        return GetAttackTicsFor(WeaponType);
    }

    double GetAirCostFor(int weaponType)
    {
        int catalogueWeapon = CaelumCraftingRules.GetCatalogueWeaponForPlayableType(
            weaponType
        );
        if (catalogueWeapon >= 0)
        {
            return CaelumWeaponCatalogue.GetPrimaryAirCost(catalogueWeapon);
        }
        return 0.0;
    }

    double GetAnimaCostFor(int weaponType)
    {
        switch (weaponType)
        {
            case CaelumConstants.WEAPON_TYPE_STAFF: return 500.0;
            case CaelumConstants.WEAPON_TYPE_BELL:
                return CaelumConstants.WEAPON_BELL_ANIMA_COST;
            case CaelumConstants.WEAPON_TYPE_BOOK: return 700.0;
            case CaelumConstants.WEAPON_TYPE_STATUETTE: return 1000.0;
            default: return 0.0;
        }
    }

    double GetBaseCriticalChanceFor(int weaponType)
    {
        switch (weaponType)
        {
            case CaelumConstants.WEAPON_TYPE_BELL: return 5.0;
            case CaelumConstants.WEAPON_TYPE_BOOK: return 12.0;
            case CaelumConstants.WEAPON_TYPE_STAFF:
            case CaelumConstants.WEAPON_TYPE_STATUETTE:
                return 8.0;
            default: return CaelumConstants.BASE_CRITICAL_CHANCE_PERCENT;
        }
    }

    double GetMaximumSpreadFor(int weaponType)
    {
        int catalogueWeapon =
            CaelumCraftingRules.GetCatalogueWeaponForPlayableType(weaponType);
        if (catalogueWeapon >= 0)
        {
            return CaelumWeaponCatalogue.GetMaximumSpread(catalogueWeapon);
        }
        switch (weaponType)
        {
            case CaelumConstants.WEAPON_TYPE_BOOK: return 10.0;
            case CaelumConstants.WEAPON_TYPE_STATUETTE: return 30.0;
            case CaelumConstants.WEAPON_TYPE_BELL: return 130.0;
            default: return 70.0;
        }
    }

    double GetMinimumSpreadFor(int weaponType)
    {
        return GetMaximumSpreadFor(weaponType) * 0.10;
    }

    bool IsMagical()
    {
        return IsMagicalType(WeaponType);
    }

    bool IsMagicalType(int weaponType)
    {
        return weaponType == CaelumConstants.WEAPON_TYPE_STAFF
            || weaponType == CaelumConstants.WEAPON_TYPE_BELL
            || weaponType == CaelumConstants.WEAPON_TYPE_BOOK
            || weaponType == CaelumConstants.WEAPON_TYPE_STATUETTE;
    }
}
