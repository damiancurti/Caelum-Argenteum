// Recetas estructurales 4.12. Cada arma usa un componente de tier y uno
// básico. Ambos se calculan por peso y se redondean hacia arriba por separado.
class CaelumCraftingRules : Object
{
    static int ResolveStationType(int stationType)
    {
        if (stationType < 0 || stationType >= CaelumConstants.CRAFTING_STATION_COUNT)
        {
            return CaelumConstants.CRAFTING_STATION_NONE;
        }
        return stationType;
    }

    static int GetStationRecipeCount(int stationType)
    {
        switch (ResolveStationType(stationType))
        {
            case CaelumConstants.CRAFTING_STATION_FORGE:
                return CaelumConstants.CRAFTING_FORGE_RECIPE_COUNT;
            case CaelumConstants.CRAFTING_STATION_RANGED_WORKSHOP:
                return CaelumConstants.CRAFTING_RANGED_WORKSHOP_RECIPE_COUNT;
            case CaelumConstants.CRAFTING_STATION_WORKBENCH:
                // El Banco de Trabajo es el catálogo unificado de las siete
                // familias. Los filtros nunca crean transacciones paralelas.
                return CaelumConstants.CRAFTING_NETWORK_PLAYABLE_RECIPE_COUNT;
            default:
                return 0;
        }
    }

    static int GetStationRecipeWeapon(int stationType, int recipeIndex)
    {
        int resolvedStation = ResolveStationType(stationType);
        if (resolvedStation == CaelumConstants.CRAFTING_STATION_FORGE)
        {
            switch (Clamp(recipeIndex, 0, CaelumConstants.CRAFTING_FORGE_RECIPE_COUNT - 1))
            {
                case 0: return CaelumConstants.CATALOGUE_WEAPON_DAGGER;
                case 1: return CaelumConstants.CATALOGUE_WEAPON_HATCHET;
                case 2: return CaelumConstants.CATALOGUE_WEAPON_MACHETE;
                case 3: return CaelumConstants.CATALOGUE_WEAPON_JAVELIN;
                case 4: return CaelumConstants.CATALOGUE_WEAPON_SWORD;
                case 5: return CaelumConstants.CATALOGUE_WEAPON_AXE;
                case 6: return CaelumConstants.CATALOGUE_WEAPON_FLAIL;
                case 7: return CaelumConstants.CATALOGUE_WEAPON_SPEAR;
                case 8: return CaelumConstants.CATALOGUE_WEAPON_GREATSWORD;
                case 9: return CaelumConstants.CATALOGUE_WEAPON_WAR_AXE;
                case 10: return CaelumConstants.CATALOGUE_WEAPON_HALBERD;
                default: return CaelumConstants.CATALOGUE_WEAPON_GIANT_GAUNTLETS;
            }
        }
        if (resolvedStation == CaelumConstants.CRAFTING_STATION_RANGED_WORKSHOP)
        {
            switch (Clamp(
                recipeIndex, 0,
                CaelumConstants.CRAFTING_RANGED_WORKSHOP_RECIPE_COUNT - 1
            ))
            {
                case 0: return CaelumConstants.CATALOGUE_WEAPON_STANDARD_BOW;
                case 1: return CaelumConstants.CATALOGUE_WEAPON_CARBINE;
                case 2: return CaelumConstants.CATALOGUE_WEAPON_LONGBOW;
                default: return CaelumConstants.CATALOGUE_WEAPON_CROSSBOW;
            }
        }
        if (resolvedStation == CaelumConstants.CRAFTING_STATION_WORKBENCH)
        {
            int unifiedIndex = Clamp(
                recipeIndex, 0,
                CaelumConstants.CRAFTING_NETWORK_PLAYABLE_RECIPE_COUNT - 1
            );
            if (unifiedIndex < CaelumConstants.CRAFTING_FORGE_RECIPE_COUNT)
            {
                return GetStationRecipeWeapon(
                    CaelumConstants.CRAFTING_STATION_FORGE, unifiedIndex
                );
            }
            return GetStationRecipeWeapon(
                CaelumConstants.CRAFTING_STATION_RANGED_WORKSHOP,
                unifiedIndex - CaelumConstants.CRAFTING_FORGE_RECIPE_COUNT
            );
        }
        return -1;
    }

    static bool CanStationCraftWeapon(int stationType, int weaponId)
    {
        int recipeCount = GetStationRecipeCount(stationType);
        for (int i = 0; i < recipeCount; i++)
        {
            if (GetStationRecipeWeapon(stationType, i)
                == CaelumWeaponCatalogue.ResolveWeapon(weaponId))
            {
                return true;
            }
        }
        return false;
    }

    static int GetStationCapabilityBit(int stationType)
    {
        int resolved = ResolveStationType(stationType);
        if (resolved == CaelumConstants.CRAFTING_STATION_NONE) { return 0; }
        return 1 << resolved;
    }

    static bool NetworkHasStation(int capabilities, int stationType)
    {
        int bit = GetStationCapabilityBit(stationType);
        return bit != 0 && (capabilities & bit) != 0;
    }

    static int GetWeaponPrimaryStation(int weaponId)
    {
        int resolved = CaelumWeaponCatalogue.ResolveWeapon(weaponId);
        if (CanStationCraftWeapon(CaelumConstants.CRAFTING_STATION_FORGE, resolved))
        {
            return CaelumConstants.CRAFTING_STATION_FORGE;
        }
        if (CanStationCraftWeapon(
            CaelumConstants.CRAFTING_STATION_RANGED_WORKSHOP, resolved
        ))
        {
            return CaelumConstants.CRAFTING_STATION_RANGED_WORKSHOP;
        }
        return CaelumConstants.CRAFTING_STATION_NONE;
    }

    static int GetWeaponTierTwoStation(int weaponId)
    {
        int primary = GetWeaponPrimaryStation(weaponId);
        if (primary == CaelumConstants.CRAFTING_STATION_FORGE)
        {
            return CaelumConstants.CRAFTING_STATION_ANVIL;
        }
        if (primary == CaelumConstants.CRAFTING_STATION_RANGED_WORKSHOP)
        {
            return CaelumConstants.CRAFTING_STATION_SAWMILL;
        }
        return CaelumConstants.CRAFTING_STATION_NONE;
    }

    static int GetMissingNetworkStation(
        int capabilities, int craftingTier, int weaponId
    )
    {
        if (!NetworkHasStation(
            capabilities, CaelumConstants.CRAFTING_STATION_WORKBENCH
        ))
        {
            return CaelumConstants.CRAFTING_STATION_WORKBENCH;
        }

        int primary = GetWeaponPrimaryStation(weaponId);
        if (primary == CaelumConstants.CRAFTING_STATION_NONE
            || !NetworkHasStation(capabilities, primary))
        {
            return primary;
        }

        if (craftingTier >= 2)
        {
            int tierTwo = GetWeaponTierTwoStation(weaponId);
            if (tierTwo == CaelumConstants.CRAFTING_STATION_NONE
                || !NetworkHasStation(capabilities, tierTwo))
            {
                return tierTwo;
            }
        }

        if (craftingTier >= 3
            && !NetworkHasStation(
                capabilities, CaelumConstants.CRAFTING_STATION_MASTER_BENCH
            ))
        {
            return CaelumConstants.CRAFTING_STATION_MASTER_BENCH;
        }

        return CaelumConstants.CRAFTING_STATION_NONE;
    }

    static bool CanNetworkCraftWeapon(
        int capabilities, int craftingTier, int weaponId
    )
    {
        return GetMissingNetworkStation(
            capabilities, craftingTier, weaponId
        ) == CaelumConstants.CRAFTING_STATION_NONE;
    }

    static int GetUnifiedRecipeKind(int recipeIndex)
    {
        int resolved = Clamp(recipeIndex, 0,
            CaelumConstants.CRAFTING_NETWORK_PLAYABLE_RECIPE_COUNT - 1);
        int armorStart = CaelumConstants.CRAFTING_NETWORK_PHYSICAL_RECIPE_COUNT;
        int essenceStart = armorStart + CaelumConstants.CRAFTING_NETWORK_ARMOR_RECIPE_COUNT;
        int amuletStart = essenceStart + CaelumConstants.CRAFTING_NETWORK_ESSENCE_RECIPE_COUNT;
        int sealStart = amuletStart + CaelumConstants.CRAFTING_NETWORK_AMULET_RECIPE_COUNT;
        int shieldStart = sealStart + CaelumConstants.CRAFTING_NETWORK_SEAL_RECIPE_COUNT;
        int processingStart = shieldStart
            + CaelumConstants.CRAFTING_NETWORK_SHIELD_RECIPE_COUNT;
        int componentStart = processingStart
            + CaelumConstants.CRAFTING_NETWORK_PROCESSING_RECIPE_COUNT;
        if (resolved < armorStart) return CaelumConstants.CRAFTING_RECIPE_KIND_PHYSICAL_WEAPON;
        if (resolved < essenceStart) return CaelumConstants.CRAFTING_RECIPE_KIND_ARMOR;
        if (resolved < amuletStart) return CaelumConstants.CRAFTING_RECIPE_KIND_ESSENCE_WEAPON;
        if (resolved < sealStart) return CaelumConstants.CRAFTING_RECIPE_KIND_AMULET;
        if (resolved < shieldStart) return CaelumConstants.CRAFTING_RECIPE_KIND_SEAL;
        if (resolved < processingStart) return CaelumConstants.CRAFTING_RECIPE_KIND_SHIELD;
        if (resolved < componentStart) return CaelumConstants.CRAFTING_RECIPE_KIND_PROCESSING;
        return CaelumConstants.CRAFTING_RECIPE_KIND_COMPONENT;
    }

    static int ResolveRecipeFilter(int recipeFilter)
    {
        return Clamp(
            recipeFilter,
            CaelumConstants.CRAFTING_RECIPE_FILTER_ALL,
            CaelumConstants.CRAFTING_RECIPE_FILTER_COUNT - 1
        );
    }

    static bool RecipeMatchesFilter(int recipeIndex, int recipeFilter)
    {
        int resolvedFilter = ResolveRecipeFilter(recipeFilter);
        if (resolvedFilter == CaelumConstants.CRAFTING_RECIPE_FILTER_ALL)
        {
            return true;
        }
        return GetUnifiedRecipeKind(recipeIndex) == resolvedFilter - 1;
    }

    static int GetFirstRecipeMatchingFilter(int recipeFilter)
    {
        for (int recipeIndex = 0;
            recipeIndex < CaelumConstants.CRAFTING_NETWORK_PLAYABLE_RECIPE_COUNT;
            recipeIndex++)
        {
            if (RecipeMatchesFilter(recipeIndex, recipeFilter))
            {
                return recipeIndex;
            }
        }
        return 0;
    }

    static int GetUnifiedPhysicalRecipeIndex(int recipeIndex)
    {
        return Clamp(
            recipeIndex, 0,
            CaelumConstants.CRAFTING_NETWORK_PHYSICAL_RECIPE_COUNT - 1
        );
    }

    static int FindUnifiedPhysicalRecipeIndex(int weaponId)
    {
        int resolvedWeapon = CaelumWeaponCatalogue.ResolveWeapon(weaponId);
        for (int recipeIndex = 0;
            recipeIndex < CaelumConstants.CRAFTING_NETWORK_PHYSICAL_RECIPE_COUNT;
            recipeIndex++)
        {
            if (GetStationRecipeWeapon(
                    CaelumConstants.CRAFTING_STATION_WORKBENCH,
                    recipeIndex
                ) == resolvedWeapon)
            {
                return recipeIndex;
            }
        }
        return -1;
    }

    static int GetUnifiedArmorRecipeIndex(int recipeIndex)
    {
        return Clamp(
            recipeIndex - CaelumConstants.CRAFTING_NETWORK_PHYSICAL_RECIPE_COUNT,
            0, CaelumConstants.CRAFTING_NETWORK_ARMOR_RECIPE_COUNT - 1
        );
    }

    static int GetUnifiedArmorType(int recipeIndex)
    {
        return GetUnifiedArmorRecipeIndex(recipeIndex)
            / CaelumConstants.ARMOR_SLOT_COUNT;
    }

    static int GetUnifiedArmorSlot(int recipeIndex)
    {
        return GetUnifiedArmorRecipeIndex(recipeIndex)
            % CaelumConstants.ARMOR_SLOT_COUNT;
    }

    static int GetUnifiedEssenceRecipeIndex(int recipeIndex)
    {
        return Clamp(
            recipeIndex
                - CaelumConstants.CRAFTING_NETWORK_PHYSICAL_RECIPE_COUNT
                - CaelumConstants.CRAFTING_NETWORK_ARMOR_RECIPE_COUNT,
            0, CaelumConstants.CRAFTING_NETWORK_ESSENCE_RECIPE_COUNT - 1
        );
    }

    static int GetUnifiedEssenceWeaponType(int recipeIndex)
    {
        int group = GetUnifiedEssenceRecipeIndex(recipeIndex)
            / CaelumConstants.ESSENCE_TYPE_COUNT;
        switch (group)
        {
            case 0: return CaelumConstants.WEAPON_TYPE_STAFF;
            case 1: return CaelumConstants.WEAPON_TYPE_BELL;
            case 2: return CaelumConstants.WEAPON_TYPE_BOOK;
            default: return CaelumConstants.WEAPON_TYPE_STATUETTE;
        }
    }

    static int GetUnifiedEssenceType(int recipeIndex)
    {
        return GetUnifiedEssenceRecipeIndex(recipeIndex)
            % CaelumConstants.ESSENCE_TYPE_COUNT;
    }

    static int GetUnifiedAmuletType(int recipeIndex)
    {
        return Clamp(recipeIndex
            - CaelumConstants.CRAFTING_NETWORK_PHYSICAL_RECIPE_COUNT
            - CaelumConstants.CRAFTING_NETWORK_ARMOR_RECIPE_COUNT
            - CaelumConstants.CRAFTING_NETWORK_ESSENCE_RECIPE_COUNT,
            0, CaelumConstants.AMULET_TYPE_COUNT - 1);
    }

    static int GetUnifiedSealType(int recipeIndex)
    {
        return Clamp(recipeIndex
            - CaelumConstants.CRAFTING_NETWORK_PHYSICAL_RECIPE_COUNT
            - CaelumConstants.CRAFTING_NETWORK_ARMOR_RECIPE_COUNT
            - CaelumConstants.CRAFTING_NETWORK_ESSENCE_RECIPE_COUNT
            - CaelumConstants.CRAFTING_NETWORK_AMULET_RECIPE_COUNT,
            0, CaelumConstants.SEAL_TYPE_COUNT - 1);
    }

    static int GetUnifiedShieldRecipeIndex(int recipeIndex)
    {
        return Clamp(
            recipeIndex - CaelumConstants.CRAFTING_NETWORK_LEGACY_RECIPE_COUNT,
            0, CaelumConstants.CRAFTING_NETWORK_SHIELD_RECIPE_COUNT - 1
        );
    }

    static int GetUnifiedShieldType(int recipeIndex)
    {
        return GetUnifiedShieldRecipeIndex(recipeIndex);
    }

    static int GetProcessingRecipeStart()
    {
        return CaelumConstants.CRAFTING_NETWORK_LEGACY_RECIPE_COUNT
            + CaelumConstants.CRAFTING_NETWORK_SHIELD_RECIPE_COUNT;
    }

    static int GetUnifiedProcessingRecipeIndex(int recipeIndex)
    {
        return Clamp(
            recipeIndex - GetProcessingRecipeStart(),
            0, CaelumConstants.CRAFTING_NETWORK_PROCESSING_RECIPE_COUNT - 1
        );
    }

    static int GetProcessingBatchMultiplier(int batchIndex)
    {
        switch (Clamp(
            batchIndex, 0,
            CaelumConstants.CRAFTING_PROCESSING_BATCH_OPTION_COUNT - 1
        ))
        {
            case 1: return 10;
            case 2: return 100;
            case 3: return 1000;
            default: return 1;
        }
    }

    static int GetCraftingEfficiencyPercent(int efficiencyIndex)
    {
        switch (Clamp(
            efficiencyIndex, 0,
            CaelumConstants.CRAFTING_EFFICIENCY_OPTION_COUNT - 1
        ))
        {
            case 1:
                return CaelumConstants.CRAFTING_EFFICIENCY_CAREFUL_PERCENT;
            case 2:
                return CaelumConstants.CRAFTING_EFFICIENCY_PERFECT_PERCENT;
            default:
                return CaelumConstants.CRAFTING_EFFICIENCY_FAST_PERCENT;
        }
    }

    static double GetCraftingEfficiencyTimeFactor(int efficiencyIndex)
    {
        switch (Clamp(
            efficiencyIndex, 0,
            CaelumConstants.CRAFTING_EFFICIENCY_OPTION_COUNT - 1
        ))
        {
            case 1:
                return CaelumConstants.CRAFTING_EFFICIENCY_CAREFUL_TIME_FACTOR;
            case 2:
                return CaelumConstants.CRAFTING_EFFICIENCY_PERFECT_TIME_FACTOR;
            default:
                return CaelumConstants.CRAFTING_EFFICIENCY_FAST_TIME_FACTOR;
        }
    }

    static double GetPrecisionTaskSeconds(
        double baseSeconds, double timeFactor = 1.0
    )
    {
        // Compatibilidad con llamadas antiguas: 4.30.0e calcula el tiempo
        // autoritativo con GetMaterialWorkSeconds y la Destreza del jugador.
        return Max(0.0, baseSeconds) * Max(0.0, timeFactor);
    }

    static int GetEfficiencyAdjustedInputUnits(
        int theoreticalUnits, int efficiencyIndex
    )
    {
        if (theoreticalUnits <= 0) { return 0; }
        // En objetos indivisibles la eficiencia representa merma: el resultado
        // sigue siendo una pieza completa y cada material se redondea arriba.
        return Max(1, int(Ceil(
            theoreticalUnits * 100.0
                / Max(1, GetCraftingEfficiencyPercent(efficiencyIndex))
            - 0.0000001
        )));
    }

    static double GetMaterialWorkSeconds(
        int employedMaterialUnits, int complexityTics,
        double typeOneDexterityPercent, int efficiencyIndex
    )
    {
        double baseTics = Max(0, employedMaterialUnits)
            * Clamp(
                complexityTics,
                CaelumConstants.CRAFTING_SIMPLE_TICS_PER_MATERIAL,
                CaelumConstants.CRAFTING_COMPLEX_TICS_PER_MATERIAL
            );
        return baseTics
            * GetCraftingEfficiencyTimeFactor(efficiencyIndex) / TICRATE
            * 100.0 / Max(100.0, typeOneDexterityPercent);
    }

    static int GetPhysicalWeaponComplexityTics(int weaponId)
    {
        switch (CaelumWeaponCatalogue.ResolveWeapon(weaponId))
        {
            case CaelumConstants.CATALOGUE_WEAPON_FLAIL:
            case CaelumConstants.CATALOGUE_WEAPON_STANDARD_BOW:
            case CaelumConstants.CATALOGUE_WEAPON_LONGBOW:
                return CaelumConstants.CRAFTING_NORMAL_TICS_PER_MATERIAL;
            case CaelumConstants.CATALOGUE_WEAPON_GIANT_GAUNTLETS:
            case CaelumConstants.CATALOGUE_WEAPON_CROSSBOW:
                return CaelumConstants.CRAFTING_DETAILED_TICS_PER_MATERIAL;
            case CaelumConstants.CATALOGUE_WEAPON_CARBINE:
                return CaelumConstants.CRAFTING_COMPLEX_TICS_PER_MATERIAL;
            default:
                // Dagas, hachas, machetes y todas las armas de filo o asta.
                return CaelumConstants.CRAFTING_SIMPLE_TICS_PER_MATERIAL;
        }
    }

    static int GetRecipeComplexityTics(int recipeIndex)
    {
        int recipeKind = GetUnifiedRecipeKind(recipeIndex);
        if (recipeKind == CaelumConstants.CRAFTING_RECIPE_KIND_PHYSICAL_WEAPON)
        {
            return GetPhysicalWeaponComplexityTics(
                GetStationRecipeWeapon(
                    CaelumConstants.CRAFTING_STATION_WORKBENCH,
                    GetUnifiedPhysicalRecipeIndex(recipeIndex)
                )
            );
        }
        if (recipeKind == CaelumConstants.CRAFTING_RECIPE_KIND_ARMOR
            || recipeKind == CaelumConstants.CRAFTING_RECIPE_KIND_SHIELD)
        {
            return CaelumConstants.CRAFTING_DETAILED_TICS_PER_MATERIAL;
        }
        if (recipeKind == CaelumConstants.CRAFTING_RECIPE_KIND_ESSENCE_WEAPON
            || recipeKind == CaelumConstants.CRAFTING_RECIPE_KIND_AMULET
            || recipeKind == CaelumConstants.CRAFTING_RECIPE_KIND_SEAL)
        {
            return CaelumConstants.CRAFTING_COMPLEX_TICS_PER_MATERIAL;
        }
        if (recipeKind == CaelumConstants.CRAFTING_RECIPE_KIND_COMPONENT)
        {
            int materialType = GetComponentOutputMaterial(recipeIndex);
            if (IsEssenceComponent(materialType)
                || IsJewelryComponent(materialType))
            {
                return CaelumConstants.CRAFTING_COMPLEX_TICS_PER_MATERIAL;
            }
        }
        // Fundición, aleaciones, madera, fibras, cueros y componentes
        // estructurales sencillos usan un tic por unidad empleada.
        return CaelumConstants.CRAFTING_SIMPLE_TICS_PER_MATERIAL;
    }

    static int GetEquipmentComplexityTics(
        int equipmentKind, int itemType, bool essenceWeapon
    )
    {
        if (equipmentKind == CaelumConstants.EQUIPMENT_KIND_ARMOR
            || equipmentKind == CaelumConstants.EQUIPMENT_KIND_SHIELD)
        {
            return CaelumConstants.CRAFTING_DETAILED_TICS_PER_MATERIAL;
        }
        if (essenceWeapon)
        {
            return CaelumConstants.CRAFTING_COMPLEX_TICS_PER_MATERIAL;
        }
        int catalogueWeapon = GetCatalogueWeaponForPlayableType(itemType);
        return catalogueWeapon >= 0
            ? GetPhysicalWeaponComplexityTics(catalogueWeapon)
            : CaelumConstants.CRAFTING_SIMPLE_TICS_PER_MATERIAL;
    }

    static int ApplyOutputEfficiency(int theoreticalUnits, int efficiencyIndex)
    {
        double exact = Max(0, theoreticalUnits)
            * GetCraftingEfficiencyPercent(efficiencyIndex) / 100.0;
        // Todo lo que recibe el jugador se redondea hacia abajo a 0,001.
        return Max(0, int(Floor(exact + 0.0000001)));
    }

    static int GetComponentRecipeStart()
    {
        return GetProcessingRecipeStart()
            + CaelumConstants.CRAFTING_NETWORK_PROCESSING_RECIPE_COUNT;
    }

    static int GetUnifiedComponentRecipeIndex(int recipeIndex)
    {
        return Clamp(
            recipeIndex - GetComponentRecipeStart(),
            0, CaelumConstants.CRAFTING_NETWORK_COMPONENT_RECIPE_COUNT - 1
        );
    }

    // Los materiales 18/19/42 son bases procesadas (tejido, cuero y madera),
    // no componentes. El orden salta esos tres IDs sin alterar 0..78.
    static int GetComponentOutputMaterial(int recipeIndex)
    {
        int componentIndex = GetUnifiedComponentRecipeIndex(recipeIndex);
        if (componentIndex < 17) { return componentIndex + 1; }
        if (componentIndex < 39) { return componentIndex + 3; }
        return componentIndex + 4;
    }

    static bool IsWoodComponent(int componentType)
    {
        return componentType == CaelumConstants.MATERIAL_SHAFT
            || componentType == CaelumConstants.MATERIAL_FRAME
            || componentType == CaelumConstants.MATERIAL_LONG_FRAME
            || componentType == CaelumConstants.MATERIAL_HILT
            || componentType == CaelumConstants.MATERIAL_LONG_HILT
            || componentType == CaelumConstants.MATERIAL_HANDLE
            || componentType == CaelumConstants.MATERIAL_LONG_HANDLE
            || componentType == CaelumConstants.MATERIAL_STAFF_BASE
            || componentType == CaelumConstants.MATERIAL_STATUETTE_BASE;
    }

    static bool IsFiberComponent(int componentType)
    {
        return componentType == CaelumConstants.MATERIAL_BOWSTRING
            || componentType == CaelumConstants.MATERIAL_REINFORCED_BOWSTRING
            || componentType == CaelumConstants.MATERIAL_BOOK_BASE;
    }

    static bool IsLeatherComponent(int componentType)
    {
        return componentType == CaelumConstants.MATERIAL_STRAP
            || componentType == CaelumConstants.MATERIAL_REINFORCED_STRAP;
    }

    static bool IsEssenceComponent(int componentType)
    {
        return componentType >= CaelumConstants.MATERIAL_FIRE_ESSENCE
            && componentType <= CaelumConstants.MATERIAL_QUINTESSENCE;
    }

    static bool IsJewelryComponent(int componentType)
    {
        return componentType >= CaelumConstants.MATERIAL_SILVER_CHAIN
            && componentType <= CaelumConstants.MATERIAL_OPAL_BROOCH;
    }

    static int GetTierMetalIngot(int tier)
    {
        if (tier <= 1) { return CaelumConstants.MATERIAL_BRONZE_INGOT; }
        if (tier == 2) { return CaelumConstants.MATERIAL_IRON_INGOT; }
        return CaelumConstants.MATERIAL_STEEL_INGOT;
    }

    static int GetRawGemForElementalComponent(int componentType)
    {
        switch (componentType)
        {
            case CaelumConstants.MATERIAL_WATER_ESSENCE:
            case CaelumConstants.MATERIAL_SAPPHIRE_PENDANT:
            case CaelumConstants.MATERIAL_SAPPHIRE_GEM:
                return CaelumConstants.MATERIAL_RAW_SAPPHIRE;
            case CaelumConstants.MATERIAL_EARTH_ESSENCE:
            case CaelumConstants.MATERIAL_EMERALD_PENDANT:
            case CaelumConstants.MATERIAL_EMERALD_GEM:
                return CaelumConstants.MATERIAL_RAW_EMERALD;
            case CaelumConstants.MATERIAL_WIND_ESSENCE:
            case CaelumConstants.MATERIAL_TOPAZ_PENDANT:
            case CaelumConstants.MATERIAL_TOPAZ_GEM:
                return CaelumConstants.MATERIAL_RAW_TOPAZ;
            case CaelumConstants.MATERIAL_QUINTESSENCE:
            case CaelumConstants.MATERIAL_OPAL_BROOCH:
                return CaelumConstants.MATERIAL_RAW_OPAL;
            default:
                return CaelumConstants.MATERIAL_RAW_RUBY;
        }
    }

    static int GetComponentBaseMaterial(int componentType, int componentTier)
    {
        if (IsWoodComponent(componentType))
        {
            return CaelumConstants.MATERIAL_WOOD;
        }
        if (IsFiberComponent(componentType))
        {
            return CaelumConstants.MATERIAL_PLANT_FIBER;
        }
        if (IsLeatherComponent(componentType))
        {
            return CaelumConstants.MATERIAL_LEATHER;
        }
        if (IsEssenceComponent(componentType)
            || (componentType >= CaelumConstants.MATERIAL_RUBY_PENDANT
                && componentType <= CaelumConstants.MATERIAL_OPAL_BROOCH))
        {
            return GetRawGemForElementalComponent(componentType);
        }
        if (componentType == CaelumConstants.MATERIAL_SILVER_CHAIN)
        {
            return CaelumConstants.MATERIAL_SILVER_INGOT;
        }
        return GetTierMetalIngot(componentTier);
    }

    static int GetComponentBaseTier(int componentType, int componentTier)
    {
        if (IsLeatherComponent(componentType)) { return 1; }
        if (IsFiberComponent(componentType)
            || componentType == CaelumConstants.MATERIAL_SILVER_CHAIN)
        {
            return 1;
        }
        int baseMaterial = GetComponentBaseMaterial(
            componentType, componentTier
        );
        return CaelumMaterialRules.ResolveTier(baseMaterial, componentTier);
    }

    static int GetComponentOutputTier(int componentType, int componentTier)
    {
        if (IsLeatherComponent(componentType)
            || componentType == CaelumConstants.MATERIAL_SILVER_CHAIN)
        {
            return 1;
        }
        return CaelumMaterialRules.ResolveTier(componentType, componentTier);
    }

    static int GetComponentInputUnits(int batchIndex)
    {
        return 2 * GetProcessingBatchMultiplier(batchIndex);
    }

    static int GetComponentOutputUnits(int batchIndex, int efficiencyIndex)
    {
        return ApplyOutputEfficiency(
            GetComponentInputUnits(batchIndex), efficiencyIndex
        );
    }

    static int FindComponentRecipeForOutput(int materialType)
    {
        for (int recipeIndex = GetComponentRecipeStart();
            recipeIndex < CaelumConstants.CRAFTING_NETWORK_PLAYABLE_RECIPE_COUNT;
            recipeIndex++)
        {
            if (GetComponentOutputMaterial(recipeIndex) == materialType)
            {
                return recipeIndex;
            }
        }
        return -1;
    }

    static int GetProcessingInputOneMaterial(int recipeIndex)
    {
        switch (GetUnifiedProcessingRecipeIndex(recipeIndex))
        {
            case CaelumConstants.CRAFTING_PROCESSING_TIN_INGOT:
                return CaelumConstants.MATERIAL_RAW_TIN;
            case CaelumConstants.CRAFTING_PROCESSING_IRON_INGOT:
                return CaelumConstants.MATERIAL_RAW_IRON;
            case CaelumConstants.CRAFTING_PROCESSING_SILVER_INGOT:
                return CaelumConstants.MATERIAL_RAW_SILVER;
            case CaelumConstants.CRAFTING_PROCESSING_GOLD_INGOT:
                return CaelumConstants.MATERIAL_RAW_GOLD;
            case CaelumConstants.CRAFTING_PROCESSING_BRONZE_ALLOY:
                return CaelumConstants.MATERIAL_COPPER_INGOT;
            case CaelumConstants.CRAFTING_PROCESSING_STEEL_ALLOY:
                return CaelumConstants.MATERIAL_IRON_INGOT;
            case CaelumConstants.CRAFTING_PROCESSING_WOOL_FABRIC:
                return CaelumConstants.MATERIAL_WOOL;
            case CaelumConstants.CRAFTING_PROCESSING_COTTON_FABRIC:
                return CaelumConstants.MATERIAL_COTTON;
            case CaelumConstants.CRAFTING_PROCESSING_SILK_FABRIC:
                return CaelumConstants.MATERIAL_RAW_SILK;
            case CaelumConstants.CRAFTING_PROCESSING_ROPE:
                return CaelumConstants.MATERIAL_PLANT_FIBER;
            case CaelumConstants.CRAFTING_PROCESSING_COW_LEATHER:
                return CaelumConstants.MATERIAL_COW_HIDE;
            case CaelumConstants.CRAFTING_PROCESSING_PREDATOR_LEATHER:
                return CaelumConstants.MATERIAL_PREDATOR_HIDE;
            case CaelumConstants.CRAFTING_PROCESSING_MONSTER_LEATHER:
                return CaelumConstants.MATERIAL_MONSTER_HIDE;
            default:
                return CaelumConstants.MATERIAL_RAW_COPPER;
        }
    }

    static int GetProcessingInputTwoMaterial(int recipeIndex)
    {
        switch (GetUnifiedProcessingRecipeIndex(recipeIndex))
        {
            case CaelumConstants.CRAFTING_PROCESSING_BRONZE_ALLOY:
                return CaelumConstants.MATERIAL_TIN_INGOT;
            case CaelumConstants.CRAFTING_PROCESSING_STEEL_ALLOY:
                return CaelumConstants.MATERIAL_COAL;
            default:
                return -1;
        }
    }

    static int GetProcessingInputOneTier(int recipeIndex)
    {
        return GetUnifiedProcessingRecipeIndex(recipeIndex)
            == CaelumConstants.CRAFTING_PROCESSING_STEEL_ALLOY ? 2 : 1;
    }

    static int GetProcessingInputTwoTier(int recipeIndex)
    {
        return 1;
    }

    static int GetProcessingOutputMaterial(int recipeIndex)
    {
        switch (GetUnifiedProcessingRecipeIndex(recipeIndex))
        {
            case CaelumConstants.CRAFTING_PROCESSING_TIN_INGOT:
                return CaelumConstants.MATERIAL_TIN_INGOT;
            case CaelumConstants.CRAFTING_PROCESSING_IRON_INGOT:
                return CaelumConstants.MATERIAL_IRON_INGOT;
            case CaelumConstants.CRAFTING_PROCESSING_SILVER_INGOT:
                return CaelumConstants.MATERIAL_SILVER_INGOT;
            case CaelumConstants.CRAFTING_PROCESSING_GOLD_INGOT:
                return CaelumConstants.MATERIAL_GOLD_INGOT;
            case CaelumConstants.CRAFTING_PROCESSING_BRONZE_ALLOY:
                return CaelumConstants.MATERIAL_BRONZE_INGOT;
            case CaelumConstants.CRAFTING_PROCESSING_STEEL_ALLOY:
                return CaelumConstants.MATERIAL_STEEL_INGOT;
            case CaelumConstants.CRAFTING_PROCESSING_WOOL_FABRIC:
            case CaelumConstants.CRAFTING_PROCESSING_COTTON_FABRIC:
            case CaelumConstants.CRAFTING_PROCESSING_SILK_FABRIC:
                return CaelumConstants.MATERIAL_FABRIC;
            case CaelumConstants.CRAFTING_PROCESSING_ROPE:
                return CaelumConstants.MATERIAL_ROPE;
            case CaelumConstants.CRAFTING_PROCESSING_COW_LEATHER:
            case CaelumConstants.CRAFTING_PROCESSING_PREDATOR_LEATHER:
            case CaelumConstants.CRAFTING_PROCESSING_MONSTER_LEATHER:
                return CaelumConstants.MATERIAL_LEATHER;
            default:
                return CaelumConstants.MATERIAL_COPPER_INGOT;
        }
    }

    static int GetProcessingOutputTier(int recipeIndex)
    {
        switch (GetUnifiedProcessingRecipeIndex(recipeIndex))
        {
            case CaelumConstants.CRAFTING_PROCESSING_IRON_INGOT:
            case CaelumConstants.CRAFTING_PROCESSING_COTTON_FABRIC:
            case CaelumConstants.CRAFTING_PROCESSING_PREDATOR_LEATHER:
                return 2;
            case CaelumConstants.CRAFTING_PROCESSING_STEEL_ALLOY:
            case CaelumConstants.CRAFTING_PROCESSING_SILK_FABRIC:
            case CaelumConstants.CRAFTING_PROCESSING_MONSTER_LEATHER:
                return 3;
            default:
                return 1;
        }
    }

    static int GetProcessingInputOneUnits(int recipeIndex, int batchIndex)
    {
        int units = 2;
        switch (GetUnifiedProcessingRecipeIndex(recipeIndex))
        {
            case CaelumConstants.CRAFTING_PROCESSING_BRONZE_ALLOY:
                units = CaelumConstants.CRAFTING_BRONZE_COPPER_UNITS;
                break;
            case CaelumConstants.CRAFTING_PROCESSING_STEEL_ALLOY:
                units = CaelumConstants.CRAFTING_STEEL_IRON_UNITS;
                break;
        }
        return units * GetProcessingBatchMultiplier(batchIndex);
    }

    static int GetProcessingInputTwoUnits(int recipeIndex, int batchIndex)
    {
        int units = 0;
        switch (GetUnifiedProcessingRecipeIndex(recipeIndex))
        {
            case CaelumConstants.CRAFTING_PROCESSING_BRONZE_ALLOY:
                units = CaelumConstants.CRAFTING_BRONZE_TIN_UNITS;
                break;
            case CaelumConstants.CRAFTING_PROCESSING_STEEL_ALLOY:
                units = CaelumConstants.CRAFTING_STEEL_COAL_UNITS;
                break;
        }
        return units * GetProcessingBatchMultiplier(batchIndex);
    }

    static int GetProcessingOutputUnits(int recipeIndex, int batchIndex)
    {
        // Esta es la salida teórica al 100 %. La eficiencia 50/75/100 se
        // aplica después al lote completo; 2 entradas producen 1/1/2 unidades.
        int units = 2;
        switch (GetUnifiedProcessingRecipeIndex(recipeIndex))
        {
            case CaelumConstants.CRAFTING_PROCESSING_BRONZE_ALLOY:
                units = CaelumConstants.CRAFTING_BRONZE_OUTPUT_UNITS;
                break;
            case CaelumConstants.CRAFTING_PROCESSING_STEEL_ALLOY:
                units = CaelumConstants.CRAFTING_STEEL_OUTPUT_UNITS;
                break;
        }
        return units * GetProcessingBatchMultiplier(batchIndex);
    }

    static int GetProcessingOutputUnitsAtEfficiency(
        int recipeIndex, int batchIndex, int efficiencyIndex
    )
    {
        return ApplyOutputEfficiency(
            GetProcessingOutputUnits(recipeIndex, batchIndex),
            efficiencyIndex
        );
    }

    static int FindProcessingRecipeForOutput(
        int materialType, int materialTier
    )
    {
        int resolvedTier = CaelumMaterialRules.ResolveTier(
            materialType, materialTier
        );
        for (int recipeIndex = GetProcessingRecipeStart();
            recipeIndex < GetComponentRecipeStart(); recipeIndex++)
        {
            if (GetProcessingOutputMaterial(recipeIndex) == materialType
                && CaelumMaterialRules.ResolveTier(
                    materialType,
                    GetProcessingOutputTier(recipeIndex)
                ) == resolvedTier)
            {
                return recipeIndex;
            }
        }
        return -1;
    }

    static int GetMissingProcessingStation(int capabilities, int recipeIndex)
    {
        if (!NetworkHasStation(
            capabilities, CaelumConstants.CRAFTING_STATION_WORKBENCH
        ))
        {
            return CaelumConstants.CRAFTING_STATION_WORKBENCH;
        }
        int processingIndex = GetUnifiedProcessingRecipeIndex(recipeIndex);
        int station = processingIndex
            <= CaelumConstants.CRAFTING_PROCESSING_STEEL_ALLOY
                ? CaelumConstants.CRAFTING_STATION_FORGE
                : CaelumConstants.CRAFTING_STATION_SEWING_MACHINE;
        if (!NetworkHasStation(capabilities, station)) { return station; }
        return CaelumConstants.CRAFTING_STATION_NONE;
    }

    static int GetMissingComponentStation(
        int capabilities, int craftingTier, int componentType
    )
    {
        if (componentType >= CaelumConstants.MATERIAL_ROUND_PLATE
            && componentType <= CaelumConstants.MATERIAL_MAGIC_PLATE)
        {
            return GetMissingShieldStation(capabilities, craftingTier);
        }
        if (componentType == CaelumConstants.MATERIAL_PLATE)
        {
            return GetMissingArmorStation(
                capabilities, craftingTier,
                CaelumConstants.ARMOR_TYPE_HEAVY
            );
        }
        if (componentType == CaelumConstants.MATERIAL_CHAINMAIL
            || componentType == CaelumConstants.MATERIAL_STRAP)
        {
            return GetMissingArmorStation(
                capabilities, craftingTier,
                CaelumConstants.ARMOR_TYPE_LIGHT
            );
        }
        if (componentType == CaelumConstants.MATERIAL_REINFORCED_STRAP)
        {
            return GetMissingNetworkStation(
                capabilities, craftingTier,
                CaelumConstants.CATALOGUE_WEAPON_GIANT_GAUNTLETS
            );
        }
        if (IsEssenceComponent(componentType)
            || (componentType >= CaelumConstants.MATERIAL_STAFF_BASE
                && componentType <= CaelumConstants.MATERIAL_STATUETTE_BASE))
        {
            return GetMissingEssenceStation(capabilities, craftingTier);
        }
        if (IsJewelryComponent(componentType))
        {
            return GetMissingJewelryStation(capabilities, craftingTier);
        }
        if (componentType == CaelumConstants.MATERIAL_FRAME
            || componentType == CaelumConstants.MATERIAL_BOWSTRING)
        {
            return GetMissingNetworkStation(
                capabilities, craftingTier,
                CaelumConstants.CATALOGUE_WEAPON_STANDARD_BOW
            );
        }
        if (componentType == CaelumConstants.MATERIAL_LONG_FRAME)
        {
            return GetMissingNetworkStation(
                capabilities, craftingTier,
                CaelumConstants.CATALOGUE_WEAPON_LONGBOW
            );
        }
        if (componentType == CaelumConstants.MATERIAL_REINFORCED_BOWSTRING)
        {
            return GetMissingNetworkStation(
                capabilities, craftingTier,
                CaelumConstants.CATALOGUE_WEAPON_CROSSBOW
            );
        }
        if (componentType == CaelumConstants.MATERIAL_BARREL
            || componentType == CaelumConstants.MATERIAL_MECHANISM)
        {
            return GetMissingNetworkStation(
                capabilities, craftingTier,
                CaelumConstants.CATALOGUE_WEAPON_CARBINE
            );
        }
        return GetMissingNetworkStation(
            capabilities, craftingTier,
            CaelumConstants.CATALOGUE_WEAPON_DAGGER
        );
    }

    static int GetRequiredSilverDetailUnits(double finalWeight, int tier)
    {
        if (tier <= 1) { return 0; }
        double ratio = tier == 2
            ? CaelumConstants.CRAFTING_SILVER_DETAIL_TIER_TWO_RATIO
            : CaelumConstants.CRAFTING_SILVER_DETAIL_TIER_THREE_RATIO;
        return GetRoundedMaterialUnits(finalWeight, ratio);
    }

    static int GetRequiredGoldDetailUnits(double finalWeight, int tier)
    {
        if (tier < 3) { return 0; }
        return GetRoundedMaterialUnits(
            finalWeight,
            CaelumConstants.CRAFTING_GOLD_DETAIL_TIER_THREE_RATIO
        );
    }

    static double GetJewelryWeight(int tier)
    {
        if (tier <= 1) return CaelumConstants.JEWELRY_TIER_ONE_WEIGHT;
        if (tier == 2) return CaelumConstants.JEWELRY_TIER_TWO_WEIGHT;
        return CaelumConstants.JEWELRY_TIER_THREE_WEIGHT;
    }

    static int GetAmuletTierMaterial(int t)
    {
        if (t == CaelumConstants.AMULET_SAPPHIRE) return CaelumConstants.MATERIAL_SAPPHIRE_PENDANT;
        if (t == CaelumConstants.AMULET_EMERALD) return CaelumConstants.MATERIAL_EMERALD_PENDANT;
        if (t == CaelumConstants.AMULET_TOPAZ) return CaelumConstants.MATERIAL_TOPAZ_PENDANT;
        return CaelumConstants.MATERIAL_RUBY_PENDANT;
    }

    static int GetSealTierMaterial(int t)
    {
        if (t == CaelumConstants.SEAL_WATER) return CaelumConstants.MATERIAL_SAPPHIRE_GEM;
        if (t == CaelumConstants.SEAL_EARTH) return CaelumConstants.MATERIAL_EMERALD_GEM;
        if (t == CaelumConstants.SEAL_AIR) return CaelumConstants.MATERIAL_TOPAZ_GEM;
        if (t == CaelumConstants.SEAL_QUINTESSENCE) return CaelumConstants.MATERIAL_OPAL_BROOCH;
        return CaelumConstants.MATERIAL_RUBY_GEM;
    }

    static int GetRequiredAmuletBaseUnits(double w)
    { return GetRoundedMaterialUnits(w, CaelumConstants.CRAFTING_AMULET_BASE_WEIGHT_RATIO); }
    static int GetRequiredAmuletTierUnits(double w)
    { return GetRoundedMaterialUnits(w, 1.0 - CaelumConstants.CRAFTING_AMULET_BASE_WEIGHT_RATIO); }
    static int GetRequiredSealBaseUnits(double w)
    { return GetRoundedMaterialUnits(w, CaelumConstants.CRAFTING_SEAL_BASE_WEIGHT_RATIO); }
    static int GetRequiredSealTierUnits(double w)
    { return GetRoundedMaterialUnits(w, 1.0 - CaelumConstants.CRAFTING_SEAL_BASE_WEIGHT_RATIO); }

    static int GetArmorTierMaterial(int armorType)
    {
        // Las dieciséis recetas usan cuero del tier del objeto. El tipo de
        // armadura conserva peso, defensa y estaciones, no cambia el recurso.
        return CaelumConstants.MATERIAL_LEATHER;
    }

    static double GetArmorTierWeightRatio(int armorSlot)
    {
        if (armorSlot == CaelumConstants.ARMOR_SLOT_HEAD
            || armorSlot == CaelumConstants.ARMOR_SLOT_BODY)
        {
            return 0.80;
        }
        return 0.40;
    }

    static double GetArmorBaseWeightRatio(int armorSlot)
    {
        return 1.0 - GetArmorTierWeightRatio(armorSlot);
    }

    static int GetRequiredArmorTierUnits(int armorSlot, double finalWeight)
    {
        return GetRoundedMaterialUnits(
            finalWeight, GetArmorTierWeightRatio(armorSlot)
        );
    }

    static int GetRequiredArmorBaseUnits(int armorSlot, double finalWeight)
    {
        return GetRoundedMaterialUnits(
            finalWeight, GetArmorBaseWeightRatio(armorSlot)
        );
    }

    static int GetShieldPlateMaterial(int shieldType)
    {
        switch (Clamp(
            shieldType, 0, CaelumConstants.SHIELD_TYPE_COUNT - 1
        ))
        {
            case CaelumConstants.SHIELD_TYPE_BUCKLER:
                return CaelumConstants.MATERIAL_ROUND_PLATE;
            case CaelumConstants.SHIELD_TYPE_KITE:
                return CaelumConstants.MATERIAL_KITE_PLATE;
            case CaelumConstants.SHIELD_TYPE_TOWER:
                return CaelumConstants.MATERIAL_TOWER_PLATE;
            default:
                return CaelumConstants.MATERIAL_MAGIC_PLATE;
        }
    }

    static int GetRequiredShieldPlateUnits(double finalWeight)
    {
        return GetRoundedMaterialUnits(
            finalWeight,
            CaelumConstants.CRAFTING_DEFAULT_TIER_WEIGHT_RATIO
        );
    }

    static int GetRequiredShieldStrapUnits(double finalWeight)
    {
        return GetRoundedMaterialUnits(
            finalWeight,
            1.0 - CaelumConstants.CRAFTING_DEFAULT_TIER_WEIGHT_RATIO
        );
    }

    static int GetEssenceBaseMaterial(int weaponType)
    {
        switch (weaponType)
        {
            case CaelumConstants.WEAPON_TYPE_STAFF:
                return CaelumConstants.MATERIAL_STAFF_BASE;
            case CaelumConstants.WEAPON_TYPE_BELL:
                return CaelumConstants.MATERIAL_BELL_BASE;
            case CaelumConstants.WEAPON_TYPE_BOOK:
                return CaelumConstants.MATERIAL_BOOK_BASE;
            default:
                return CaelumConstants.MATERIAL_STATUETTE_BASE;
        }
    }

    static int GetEssenceMaterial(int essenceType)
    {
        switch (Clamp(
            essenceType, 0, CaelumConstants.ESSENCE_TYPE_COUNT - 1
        ))
        {
            case CaelumConstants.ESSENCE_WATER:
                return CaelumConstants.MATERIAL_WATER_ESSENCE;
            case CaelumConstants.ESSENCE_EARTH:
                return CaelumConstants.MATERIAL_EARTH_ESSENCE;
            case CaelumConstants.ESSENCE_WIND:
                return CaelumConstants.MATERIAL_WIND_ESSENCE;
            case CaelumConstants.ESSENCE_QUINTESSENCE:
                return CaelumConstants.MATERIAL_QUINTESSENCE;
            default:
                return CaelumConstants.MATERIAL_FIRE_ESSENCE;
        }
    }

    static double GetEssenceTierOneWeight(int weaponType)
    {
        switch (weaponType)
        {
            case CaelumConstants.WEAPON_TYPE_STAFF:
                return CaelumConstants.WEAPON_STAFF_TIER_ONE_WEIGHT;
            case CaelumConstants.WEAPON_TYPE_BELL:
                return CaelumConstants.WEAPON_BELL_TIER_ONE_WEIGHT;
            case CaelumConstants.WEAPON_TYPE_BOOK:
                return CaelumConstants.WEAPON_BOOK_TIER_ONE_WEIGHT;
            default:
                return CaelumConstants.WEAPON_STATUETTE_TIER_ONE_WEIGHT;
        }
    }

    static int GetArmorPrimaryStation(int armorType)
    {
        if (armorType == CaelumConstants.ARMOR_TYPE_MEDIUM
            || armorType == CaelumConstants.ARMOR_TYPE_HEAVY)
        {
            return CaelumConstants.CRAFTING_STATION_FORGE;
        }
        return CaelumConstants.CRAFTING_STATION_ARMOR_WORKSHOP;
    }

    static int GetArmorTierTwoStation(int armorType)
    {
        if (armorType == CaelumConstants.ARMOR_TYPE_MEDIUM
            || armorType == CaelumConstants.ARMOR_TYPE_HEAVY)
        {
            return CaelumConstants.CRAFTING_STATION_ANVIL;
        }
        return CaelumConstants.CRAFTING_STATION_SEWING_MACHINE;
    }

    static int GetMissingStationForBranch(
        int capabilities, int craftingTier, int primary, int tierTwo
    )
    {
        if (!NetworkHasStation(
            capabilities, CaelumConstants.CRAFTING_STATION_WORKBENCH
        ))
        {
            return CaelumConstants.CRAFTING_STATION_WORKBENCH;
        }
        if (!NetworkHasStation(capabilities, primary)) { return primary; }
        if (craftingTier >= 2
            && !NetworkHasStation(capabilities, tierTwo))
        {
            return tierTwo;
        }
        if (craftingTier >= 3
            && !NetworkHasStation(
                capabilities, CaelumConstants.CRAFTING_STATION_MASTER_BENCH
            ))
        {
            return CaelumConstants.CRAFTING_STATION_MASTER_BENCH;
        }
        return CaelumConstants.CRAFTING_STATION_NONE;
    }

    static int GetMissingArmorStation(
        int capabilities, int craftingTier, int armorType
    )
    {
        return GetMissingStationForBranch(
            capabilities, craftingTier,
            GetArmorPrimaryStation(armorType),
            GetArmorTierTwoStation(armorType)
        );
    }

    static int GetMissingShieldStation(int capabilities, int craftingTier)
    {
        if (!NetworkHasStation(
            capabilities, CaelumConstants.CRAFTING_STATION_WORKBENCH
        ))
        {
            return CaelumConstants.CRAFTING_STATION_WORKBENCH;
        }
        if (!NetworkHasStation(
            capabilities, CaelumConstants.CRAFTING_STATION_FORGE
        ))
        {
            return CaelumConstants.CRAFTING_STATION_FORGE;
        }
        // Todo escudo, incluido tier 1, necesita conformado sobre yunque.
        if (!NetworkHasStation(
            capabilities, CaelumConstants.CRAFTING_STATION_ANVIL
        ))
        {
            return CaelumConstants.CRAFTING_STATION_ANVIL;
        }
        if (craftingTier >= 3
            && !NetworkHasStation(
                capabilities, CaelumConstants.CRAFTING_STATION_MASTER_BENCH
            ))
        {
            return CaelumConstants.CRAFTING_STATION_MASTER_BENCH;
        }
        return CaelumConstants.CRAFTING_STATION_NONE;
    }

    static int GetMissingEssenceStation(
        int capabilities, int craftingTier
    )
    {
        return GetMissingStationForBranch(
            capabilities, craftingTier,
            CaelumConstants.CRAFTING_STATION_ESSENCE_ALTAR,
            CaelumConstants.CRAFTING_STATION_GLOBE
        );
    }
    static int GetMissingJewelryStation(int capabilities, int craftingTier)
    {
        return GetMissingStationForBranch(
            capabilities, craftingTier,
            CaelumConstants.CRAFTING_STATION_JEWELER_BENCH,
            CaelumConstants.CRAFTING_STATION_FINE_TOOLS_BENCH);
    }


    static int GetPlayableRecipeWeapon(int recipeIndex)
    {
        return CaelumWeaponCatalogue.ResolveWeapon(recipeIndex);
    }

    static int GetPlayableWeaponType(int weaponId)
    {
        int resolved = CaelumWeaponCatalogue.ResolveWeapon(weaponId);
        switch (resolved)
        {
            case CaelumConstants.CATALOGUE_WEAPON_DAGGER: return CaelumConstants.WEAPON_TYPE_DAGGER;
            case CaelumConstants.CATALOGUE_WEAPON_HATCHET: return CaelumConstants.WEAPON_TYPE_HATCHET;
            case CaelumConstants.CATALOGUE_WEAPON_MACHETE: return CaelumConstants.WEAPON_TYPE_MACHETE;
            case CaelumConstants.CATALOGUE_WEAPON_JAVELIN: return CaelumConstants.WEAPON_TYPE_JAVELIN;
            case CaelumConstants.CATALOGUE_WEAPON_SWORD: return CaelumConstants.WEAPON_TYPE_SWORD;
            case CaelumConstants.CATALOGUE_WEAPON_AXE: return CaelumConstants.WEAPON_TYPE_AXE;
            case CaelumConstants.CATALOGUE_WEAPON_FLAIL: return CaelumConstants.WEAPON_TYPE_FLAIL;
            case CaelumConstants.CATALOGUE_WEAPON_SPEAR: return CaelumConstants.WEAPON_TYPE_SPEAR;
            case CaelumConstants.CATALOGUE_WEAPON_GREATSWORD: return CaelumConstants.WEAPON_TYPE_GREATSWORD;
            case CaelumConstants.CATALOGUE_WEAPON_WAR_AXE: return CaelumConstants.WEAPON_TYPE_WAR_AXE;
            case CaelumConstants.CATALOGUE_WEAPON_HALBERD: return CaelumConstants.WEAPON_TYPE_HALBERD;
            case CaelumConstants.CATALOGUE_WEAPON_GIANT_GAUNTLETS: return CaelumConstants.WEAPON_TYPE_GIANT_GAUNTLETS;
            case CaelumConstants.CATALOGUE_WEAPON_STANDARD_BOW: return CaelumConstants.WEAPON_TYPE_STANDARD_BOW;
            case CaelumConstants.CATALOGUE_WEAPON_CARBINE: return CaelumConstants.WEAPON_TYPE_CARBINE;
            case CaelumConstants.CATALOGUE_WEAPON_LONGBOW: return CaelumConstants.WEAPON_TYPE_LONGBOW;
            default: return CaelumConstants.WEAPON_TYPE_CROSSBOW;
        }
    }

    static int GetCatalogueWeaponForPlayableType(int weaponType)
    {
        switch (weaponType)
        {
            case CaelumConstants.WEAPON_TYPE_DAGGER: return CaelumConstants.CATALOGUE_WEAPON_DAGGER;
            case CaelumConstants.WEAPON_TYPE_HATCHET: return CaelumConstants.CATALOGUE_WEAPON_HATCHET;
            case CaelumConstants.WEAPON_TYPE_MACHETE: return CaelumConstants.CATALOGUE_WEAPON_MACHETE;
            case CaelumConstants.WEAPON_TYPE_JAVELIN: return CaelumConstants.CATALOGUE_WEAPON_JAVELIN;
            case CaelumConstants.WEAPON_TYPE_SWORD: return CaelumConstants.CATALOGUE_WEAPON_SWORD;
            case CaelumConstants.WEAPON_TYPE_AXE: return CaelumConstants.CATALOGUE_WEAPON_AXE;
            case CaelumConstants.WEAPON_TYPE_FLAIL: return CaelumConstants.CATALOGUE_WEAPON_FLAIL;
            case CaelumConstants.WEAPON_TYPE_SPEAR: return CaelumConstants.CATALOGUE_WEAPON_SPEAR;
            case CaelumConstants.WEAPON_TYPE_GREATSWORD: return CaelumConstants.CATALOGUE_WEAPON_GREATSWORD;
            case CaelumConstants.WEAPON_TYPE_WAR_AXE: return CaelumConstants.CATALOGUE_WEAPON_WAR_AXE;
            case CaelumConstants.WEAPON_TYPE_HALBERD: return CaelumConstants.CATALOGUE_WEAPON_HALBERD;
            case CaelumConstants.WEAPON_TYPE_GIANT_GAUNTLETS: return CaelumConstants.CATALOGUE_WEAPON_GIANT_GAUNTLETS;
            case CaelumConstants.WEAPON_TYPE_STANDARD_BOW: return CaelumConstants.CATALOGUE_WEAPON_STANDARD_BOW;
            case CaelumConstants.WEAPON_TYPE_CARBINE: return CaelumConstants.CATALOGUE_WEAPON_CARBINE;
            case CaelumConstants.WEAPON_TYPE_LONGBOW: return CaelumConstants.CATALOGUE_WEAPON_LONGBOW;
            case CaelumConstants.WEAPON_TYPE_CROSSBOW: return CaelumConstants.CATALOGUE_WEAPON_CROSSBOW;
            default: return -1;
        }
    }

    static int GetRecoveredMaterialUnits(
        int requiredUnits, double remainingDurabilityFraction = 1.0
    )
    {
        return Max(0, int(Floor(
            Max(0, requiredUnits)
                * CaelumConstants.CRAFTING_DISMANTLE_RECOVERY_RATIO
                * Clamp(remainingDurabilityFraction, 0.0, 1.0)
                + 0.0000001
        )));
    }

    static int GetProportionalInputUnits(
        int fullRecipeUnits, double requiredFraction
    )
    {
        double exact = Max(0, fullRecipeUnits)
            * Clamp(requiredFraction, 0.0, 1.0);
        // Todo coste se redondea hacia arriba a la unidad 0,001.
        return Max(0, int(Ceil(exact - 0.0000001)));
    }

    static double GetPlayableTierOneWeight(int weaponId)
    {
        switch (CaelumWeaponCatalogue.ResolveWeapon(weaponId))
        {
            case CaelumConstants.CATALOGUE_WEAPON_DAGGER: return CaelumConstants.WEAPON_DAGGER_TIER_ONE_WEIGHT;
            case CaelumConstants.CATALOGUE_WEAPON_HATCHET: return CaelumConstants.WEAPON_HATCHET_TIER_ONE_WEIGHT;
            case CaelumConstants.CATALOGUE_WEAPON_MACHETE: return CaelumConstants.WEAPON_MACHETE_TIER_ONE_WEIGHT;
            case CaelumConstants.CATALOGUE_WEAPON_JAVELIN: return CaelumConstants.WEAPON_JAVELIN_TIER_ONE_WEIGHT;
            case CaelumConstants.CATALOGUE_WEAPON_SWORD: return CaelumConstants.WEAPON_SWORD_TIER_ONE_WEIGHT;
            case CaelumConstants.CATALOGUE_WEAPON_AXE: return CaelumConstants.WEAPON_AXE_TIER_ONE_WEIGHT;
            case CaelumConstants.CATALOGUE_WEAPON_FLAIL: return CaelumConstants.WEAPON_FLAIL_TIER_ONE_WEIGHT;
            case CaelumConstants.CATALOGUE_WEAPON_SPEAR: return CaelumConstants.WEAPON_SPEAR_TIER_ONE_WEIGHT;
            case CaelumConstants.CATALOGUE_WEAPON_GREATSWORD: return CaelumConstants.WEAPON_GREATSWORD_TIER_ONE_WEIGHT;
            case CaelumConstants.CATALOGUE_WEAPON_WAR_AXE: return CaelumConstants.WEAPON_WAR_AXE_TIER_ONE_WEIGHT;
            case CaelumConstants.CATALOGUE_WEAPON_HALBERD: return CaelumConstants.WEAPON_HALBERD_TIER_ONE_WEIGHT;
            case CaelumConstants.CATALOGUE_WEAPON_GIANT_GAUNTLETS: return CaelumConstants.WEAPON_GIANT_GAUNTLETS_TIER_ONE_WEIGHT;
            case CaelumConstants.CATALOGUE_WEAPON_STANDARD_BOW: return CaelumConstants.WEAPON_STANDARD_BOW_TIER_ONE_WEIGHT;
            case CaelumConstants.CATALOGUE_WEAPON_CARBINE: return CaelumConstants.WEAPON_CARBINE_TIER_ONE_WEIGHT;
            case CaelumConstants.CATALOGUE_WEAPON_LONGBOW: return CaelumConstants.WEAPON_LONGBOW_TIER_ONE_WEIGHT;
            default: return CaelumConstants.WEAPON_CROSSBOW_TIER_ONE_WEIGHT;
        }
    }

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

        // Todo componente cuenta tanto por ser una salida fabricable como
        // por el material base único que consume en cualquiera de sus tiers.
        // Así la auditoría deriva del catálogo persistente 4.30 y no de una
        // segunda lista manual propensa a quedar desactualizada.
        for (int recipeIndex = GetComponentRecipeStart();
            recipeIndex
                < CaelumConstants.CRAFTING_NETWORK_PLAYABLE_RECIPE_COUNT;
            recipeIndex++)
        {
            int componentType = GetComponentOutputMaterial(recipeIndex);
            if (componentType == materialType) { return true; }
            for (int tier = 1; tier <= 3; tier++)
            {
                if (GetComponentBaseMaterial(componentType, tier)
                    == materialType)
                {
                    return true;
                }
            }
        }

        // Armaduras, escudos y armas de esencia ya documentados.
        switch (materialType)
        {
            case CaelumConstants.MATERIAL_IRON_INGOT:
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
            case CaelumConstants.MATERIAL_COPPER_INGOT:
            case CaelumConstants.MATERIAL_TIN_INGOT:
            case CaelumConstants.MATERIAL_COAL:
            case CaelumConstants.MATERIAL_RAW_COPPER:
            case CaelumConstants.MATERIAL_RAW_TIN:
            case CaelumConstants.MATERIAL_RAW_IRON:
            case CaelumConstants.MATERIAL_RAW_SILVER:
            case CaelumConstants.MATERIAL_RAW_GOLD:
            case CaelumConstants.MATERIAL_BRONZE_INGOT:
            case CaelumConstants.MATERIAL_STEEL_INGOT:
            case CaelumConstants.MATERIAL_SILVER_INGOT:
            case CaelumConstants.MATERIAL_GOLD_INGOT:
            case CaelumConstants.MATERIAL_WOOL:
            case CaelumConstants.MATERIAL_COTTON:
            case CaelumConstants.MATERIAL_RAW_SILK:
            case CaelumConstants.MATERIAL_PLANT_FIBER:
            case CaelumConstants.MATERIAL_ROPE:
            case CaelumConstants.MATERIAL_COW_HIDE:
            case CaelumConstants.MATERIAL_PREDATOR_HIDE:
            case CaelumConstants.MATERIAL_MONSTER_HIDE:
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
