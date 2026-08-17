// Recetas estructurales 4.12. Cada arma usa un componente de tier y uno
// básico. Ambos se calculan por peso y se redondean hacia arriba por separado.
class CaelumCraftingRules : Object
{
    static int GetPrimaryMaterial(int weaponId)
    {
        switch (CaelumWeaponCatalogue.ResolveWeapon(weaponId))
        {
            case CaelumConstants.CATALOGUE_WEAPON_DAGGER: return CaelumConstants.MATERIAL_SMALL_BLADE;
            case CaelumConstants.CATALOGUE_WEAPON_HATCHET: return CaelumConstants.MATERIAL_SMALL_WEAPON_HEAD;
            case CaelumConstants.CATALOGUE_WEAPON_MACHETE: return CaelumConstants.MATERIAL_CURVED_BLADE;
            case CaelumConstants.CATALOGUE_WEAPON_JAVELIN:
            case CaelumConstants.CATALOGUE_WEAPON_SPEAR: return CaelumConstants.MATERIAL_SHAFT;
            case CaelumConstants.CATALOGUE_WEAPON_SWORD: return CaelumConstants.MATERIAL_BLADE;
            case CaelumConstants.CATALOGUE_WEAPON_AXE: return CaelumConstants.MATERIAL_WEAPON_HEAD;
            case CaelumConstants.CATALOGUE_WEAPON_FLAIL: return CaelumConstants.MATERIAL_ROUND_HEAD;
            case CaelumConstants.CATALOGUE_WEAPON_GREATSWORD:
            case CaelumConstants.CATALOGUE_WEAPON_HALBERD: return CaelumConstants.MATERIAL_LONG_BLADE;
            case CaelumConstants.CATALOGUE_WEAPON_WAR_AXE: return CaelumConstants.MATERIAL_BROAD_BLADE;
            case CaelumConstants.CATALOGUE_WEAPON_GIANT_GAUNTLETS: return CaelumConstants.MATERIAL_LARGE_PLATE;
            case CaelumConstants.CATALOGUE_WEAPON_STANDARD_BOW:
            case CaelumConstants.CATALOGUE_WEAPON_CROSSBOW: return CaelumConstants.MATERIAL_FRAME;
            case CaelumConstants.CATALOGUE_WEAPON_CARBINE: return CaelumConstants.MATERIAL_BARREL;
            default: return CaelumConstants.MATERIAL_LONG_FRAME;
        }
    }

    static int GetSecondaryMaterial(int weaponId)
    {
        switch (CaelumWeaponCatalogue.ResolveWeapon(weaponId))
        {
            case CaelumConstants.CATALOGUE_WEAPON_DAGGER:
            case CaelumConstants.CATALOGUE_WEAPON_SWORD: return CaelumConstants.MATERIAL_HILT;
            case CaelumConstants.CATALOGUE_WEAPON_HATCHET:
            case CaelumConstants.CATALOGUE_WEAPON_MACHETE:
            case CaelumConstants.CATALOGUE_WEAPON_AXE: return CaelumConstants.MATERIAL_HANDLE;
            case CaelumConstants.CATALOGUE_WEAPON_JAVELIN:
            case CaelumConstants.CATALOGUE_WEAPON_SPEAR: return CaelumConstants.MATERIAL_POINT;
            case CaelumConstants.CATALOGUE_WEAPON_FLAIL: return CaelumConstants.MATERIAL_CHAIN;
            case CaelumConstants.CATALOGUE_WEAPON_GREATSWORD: return CaelumConstants.MATERIAL_LONG_HILT;
            case CaelumConstants.CATALOGUE_WEAPON_WAR_AXE: return CaelumConstants.MATERIAL_LONG_HANDLE;
            case CaelumConstants.CATALOGUE_WEAPON_HALBERD: return CaelumConstants.MATERIAL_SHAFT;
            case CaelumConstants.CATALOGUE_WEAPON_GIANT_GAUNTLETS: return CaelumConstants.MATERIAL_REINFORCED_STRAP;
            case CaelumConstants.CATALOGUE_WEAPON_STANDARD_BOW:
            case CaelumConstants.CATALOGUE_WEAPON_LONGBOW: return CaelumConstants.MATERIAL_BOWSTRING;
            case CaelumConstants.CATALOGUE_WEAPON_CARBINE: return CaelumConstants.MATERIAL_MECHANISM;
            default: return CaelumConstants.MATERIAL_REINFORCED_BOWSTRING;
        }
    }

    static int GetTierMaterial(int weaponId)
    {
        int resolved = CaelumWeaponCatalogue.ResolveWeapon(weaponId);
        if (resolved == CaelumConstants.CATALOGUE_WEAPON_JAVELIN
            || resolved == CaelumConstants.CATALOGUE_WEAPON_SPEAR)
        {
            return CaelumConstants.MATERIAL_POINT;
        }
        return GetPrimaryMaterial(resolved);
    }

    static int GetBasicMaterial(int weaponId)
    {
        int resolved = CaelumWeaponCatalogue.ResolveWeapon(weaponId);
        int tierMaterial = GetTierMaterial(resolved);
        int primaryMaterial = GetPrimaryMaterial(resolved);
        return primaryMaterial == tierMaterial
            ? GetSecondaryMaterial(resolved) : primaryMaterial;
    }

    static double GetTierWeightRatio(int weaponId)
    {
        int resolved = CaelumWeaponCatalogue.ResolveWeapon(weaponId);
        if (resolved == CaelumConstants.CATALOGUE_WEAPON_JAVELIN
            || resolved == CaelumConstants.CATALOGUE_WEAPON_SPEAR
            || resolved == CaelumConstants.CATALOGUE_WEAPON_HALBERD)
        {
            return CaelumConstants.CRAFTING_POLEARM_TIER_WEIGHT_RATIO;
        }
        if (resolved == CaelumConstants.CATALOGUE_WEAPON_HATCHET
            || resolved == CaelumConstants.CATALOGUE_WEAPON_AXE
            || resolved == CaelumConstants.CATALOGUE_WEAPON_WAR_AXE)
        {
            return CaelumConstants.CRAFTING_AXE_TIER_WEIGHT_RATIO;
        }
        if (CaelumWeaponCatalogue.GetFamily(resolved)
            == CaelumConstants.CATALOGUE_FAMILY_RANGED)
        {
            return CaelumConstants.CRAFTING_RANGED_TIER_WEIGHT_RATIO;
        }
        return CaelumConstants.CRAFTING_DEFAULT_TIER_WEIGHT_RATIO;
    }

    static double GetBasicWeightRatio(int weaponId)
    {
        return 1.0 - GetTierWeightRatio(weaponId);
    }

    static int GetRoundedMaterialUnits(double finalWeaponWeight, double ratio)
    {
        double exactUnits = Max(0.0, finalWeaponWeight)
            * Clamp(ratio, 0.0, 1.0)
            / CaelumConstants.MATERIAL_UNIT_WEIGHT;
        // El margen solo neutraliza error binario sobre un entero exacto.
        return Max(0, int(Ceil(exactUnits - 0.0000001)));
    }

    static int GetRequiredTierMaterialUnits(
        int weaponId, double finalWeaponWeight
    )
    {
        return GetRoundedMaterialUnits(
            finalWeaponWeight, GetTierWeightRatio(weaponId)
        );
    }

    static int GetRequiredBasicMaterialUnits(
        int weaponId, double finalWeaponWeight
    )
    {
        return GetRoundedMaterialUnits(
            finalWeaponWeight, GetBasicWeightRatio(weaponId)
        );
    }

    static int GetRequiredPhysicalMaterialUnits(
        int weaponId, double finalWeaponWeight
    )
    {
        return GetRequiredTierMaterialUnits(weaponId, finalWeaponWeight)
            + GetRequiredBasicMaterialUnits(weaponId, finalWeaponWeight);
    }

    static double GetCraftedWeaponWeight(
        double tierOneBaseWeight, int tier, int equipmentSize
    )
    {
        return CaelumEquipmentRules.CalculateTieredEquipmentWeight(
            tierOneBaseWeight, tier, equipmentSize
        );
    }

    static int GetRequiredTierUnitsForConfiguration(
        int weaponId, double tierOneBaseWeight, int tier, int equipmentSize
    )
    {
        return GetRequiredTierMaterialUnits(
            weaponId,
            GetCraftedWeaponWeight(tierOneBaseWeight, tier, equipmentSize)
        );
    }

    static int GetRequiredBasicUnitsForConfiguration(
        int weaponId, double tierOneBaseWeight, int tier, int equipmentSize
    )
    {
        return GetRequiredBasicMaterialUnits(
            weaponId,
            GetCraftedWeaponWeight(tierOneBaseWeight, tier, equipmentSize)
        );
    }

    static int GetRequiredEssenceUnits(double finalWeaponWeight)
    {
        return GetRoundedMaterialUnits(
            finalWeaponWeight,
            CaelumConstants.CRAFTING_ESSENCE_TIER_WEIGHT_RATIO
        );
    }

    static int GetRequiredEssenceBaseUnits(double finalWeaponWeight)
    {
        return GetRoundedMaterialUnits(
            finalWeaponWeight,
            1.0 - CaelumConstants.CRAFTING_ESSENCE_TIER_WEIGHT_RATIO
        );
    }

    static double GetMaterialWeightForUnits(int materialUnits)
    {
        return Max(0, materialUnits) * CaelumConstants.MATERIAL_UNIT_WEIGHT;
    }

    static bool IsMaterialUsedByWeaponRecipe(int materialType)
    {
        for (int weaponId = 0;
            weaponId < CaelumConstants.CATALOGUE_PHYSICAL_WEAPON_COUNT;
            weaponId++)
        {
            if (GetPrimaryMaterial(weaponId) == materialType
                || GetSecondaryMaterial(weaponId) == materialType)
            {
                return true;
            }
        }
        return false;
    }

    static bool IsMaterialUsedByAnyRecipe(int materialType)
    {
        if (materialType < CaelumConstants.MATERIAL_FIRST_ACTIVE
            || materialType >= CaelumConstants.MATERIAL_TYPE_COUNT)
        {
            return false;
        }
        if (IsMaterialUsedByWeaponRecipe(materialType)) { return true; }

        // Armaduras, escudos y armas de esencia ya documentados.
        switch (materialType)
        {
            case CaelumConstants.MATERIAL_PLATE:
            case CaelumConstants.MATERIAL_ROUND_PLATE:
            case CaelumConstants.MATERIAL_KITE_PLATE:
            case CaelumConstants.MATERIAL_TOWER_PLATE:
            case CaelumConstants.MATERIAL_MAGIC_PLATE:
            case CaelumConstants.MATERIAL_CHAINMAIL:
            case CaelumConstants.MATERIAL_FABRIC:
            case CaelumConstants.MATERIAL_LEATHER:
            case CaelumConstants.MATERIAL_FIRE_ESSENCE:
            case CaelumConstants.MATERIAL_WATER_ESSENCE:
            case CaelumConstants.MATERIAL_EARTH_ESSENCE:
            case CaelumConstants.MATERIAL_WIND_ESSENCE:
            case CaelumConstants.MATERIAL_QUINTESSENCE:
            case CaelumConstants.MATERIAL_STRAP:
            case CaelumConstants.MATERIAL_STAFF_BASE:
            case CaelumConstants.MATERIAL_BELL_BASE:
            case CaelumConstants.MATERIAL_BOOK_BASE:
            case CaelumConstants.MATERIAL_STATUETTE_BASE:
                return true;
            default: return false;
        }
    }

    static int CountUnusedActiveMaterials()
    {
        int unused = 0;
        for (int materialType = CaelumConstants.MATERIAL_FIRST_ACTIVE;
            materialType < CaelumConstants.MATERIAL_TYPE_COUNT;
            materialType++)
        {
            if (!IsMaterialUsedByAnyRecipe(materialType)) { unused++; }
        }
        return unused;
    }
}
