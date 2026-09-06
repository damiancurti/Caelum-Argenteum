// Economía base 4.32.0a-r4. Las monedas son objetos físicos nominales del
// inventario; no pueden fundirse ni acuñarse por el jugador. Los valores de
// manufactura se derivan de las recetas autoritativas. Las funciones que
// inspeccionan instancias vivas de Inventory se declaran en ámbito play.
class CaelumCurrencyItem : CaelumSpecialInventoryItem
{
    Default
    {
        Tag "$CA_CURRENCY_COPPER_COIN";
        Inventory.Icon "graphics/caelum/icons/currency/ca_coin_copper.png";
        Inventory.PickupMessage "$CA_PICKUP_CURRENCY_COPPER";
        Inventory.MaxAmount 2147483647;
        Inventory.InterHubAmount 2147483647;
    }

    override int GetSpecialCategory()
    {
        return CaelumConstants.EQUIPMENT_KIND_CURRENCY;
    }

    override double GetUnitWeight()
    {
        return CaelumConstants.CURRENCY_UNIT_WEIGHT;
    }

    virtual int GetCurrencyType()
    {
        return CaelumConstants.CURRENCY_COPPER;
    }

    override int GetSpecialType()
    {
        return GetCurrencyType();
    }

    int GetFaceValue()
    {
        return CaelumEconomyRules.GetCurrencyFaceValue(GetCurrencyType());
    }

    int GetNominalDenomination()
    {
        return CaelumEconomyRules.GetCurrencyDenomination(GetCurrencyType());
    }

    int GetCurrencyMetalType()
    {
        return CaelumEconomyRules.GetCurrencyMetalType(GetCurrencyType());
    }

    override String PickupMessage()
    {
        String messageKey = "CA_PICKUP_CURRENCY_COPPER";
        if (GetCurrencyMetalType() == CaelumConstants.CURRENCY_METAL_SILVER)
        {
            messageKey = "CA_PICKUP_CURRENCY_SILVER";
        }
        else if (GetCurrencyMetalType()
            == CaelumConstants.CURRENCY_METAL_GOLD)
        {
            messageKey = "CA_PICKUP_CURRENCY_GOLD";
        }
        return String.Format(
            StringTable.Localize(messageKey, false),
            Amount, GetNominalDenomination()
        );
    }

    // Cada denominación conserva una pila independiente. La suma sigue la
    // misma protección contra overflow que los materiales apilables.
    override bool HandlePickup(Inventory incoming)
    {
        CaelumCurrencyItem currency = CaelumCurrencyItem(incoming);
        if (currency == null
            || currency.GetCurrencyType() != GetCurrencyType())
        {
            return false;
        }
        if (Amount < MaxAmount
            || (sv_unlimited_pickup && !incoming.ShouldStay()))
        {
            if (Amount > 0 && Amount + incoming.Amount < 0)
            {
                Amount = 2147483647;
            }
            else
            {
                Amount += incoming.Amount;
            }
            if (Amount > MaxAmount && !sv_unlimited_pickup)
            {
                Amount = MaxAmount;
            }
            incoming.bPickupGood = true;
        }
        return true;
    }
}

class CaelumCopperCoin : CaelumCurrencyItem
{
    Default
    {
        Tag "$CA_CURRENCY_COPPER_COIN";
        Inventory.Icon "graphics/caelum/icons/currency/ca_coin_copper.png";
        Inventory.PickupMessage "$CA_PICKUP_CURRENCY_COPPER";
    }

    override int GetCurrencyType()
    {
        return CaelumConstants.CURRENCY_COPPER;
    }

    States { Spawn: CCOP A -1; Stop; }
}

class CaelumCopperCoin5 : CaelumCopperCoin
{
    Default { Tag "$CA_CURRENCY_COPPER_COIN_5"; }
    override int GetCurrencyType()
    {
        return CaelumConstants.CURRENCY_COPPER_FIVE;
    }
}

class CaelumCopperCoin20 : CaelumCopperCoin
{
    Default { Tag "$CA_CURRENCY_COPPER_COIN_20"; }
    override int GetCurrencyType()
    {
        return CaelumConstants.CURRENCY_COPPER_TWENTY;
    }
}

class CaelumCopperCoin50 : CaelumCopperCoin
{
    Default { Tag "$CA_CURRENCY_COPPER_COIN_50"; }
    override int GetCurrencyType()
    {
        return CaelumConstants.CURRENCY_COPPER_FIFTY;
    }
}

class CaelumCopperCoin100 : CaelumCopperCoin
{
    Default { Tag "$CA_CURRENCY_COPPER_COIN_100"; }
    override int GetCurrencyType()
    {
        return CaelumConstants.CURRENCY_COPPER_HUNDRED;
    }
}

class CaelumSilverCoin : CaelumCurrencyItem
{
    Default
    {
        Tag "$CA_CURRENCY_SILVER_COIN";
        Inventory.Icon "graphics/caelum/icons/currency/ca_coin_silver.png";
        Inventory.PickupMessage "$CA_PICKUP_CURRENCY_SILVER";
    }

    override int GetCurrencyType()
    {
        return CaelumConstants.CURRENCY_SILVER;
    }

    States { Spawn: CSIL A -1; Stop; }
}

class CaelumSilverCoin5 : CaelumSilverCoin
{
    Default { Tag "$CA_CURRENCY_SILVER_COIN_5"; }
    override int GetCurrencyType()
    {
        return CaelumConstants.CURRENCY_SILVER_FIVE;
    }
}

class CaelumSilverCoin20 : CaelumSilverCoin
{
    Default { Tag "$CA_CURRENCY_SILVER_COIN_20"; }
    override int GetCurrencyType()
    {
        return CaelumConstants.CURRENCY_SILVER_TWENTY;
    }
}

class CaelumSilverCoin50 : CaelumSilverCoin
{
    Default { Tag "$CA_CURRENCY_SILVER_COIN_50"; }
    override int GetCurrencyType()
    {
        return CaelumConstants.CURRENCY_SILVER_FIFTY;
    }
}

class CaelumSilverCoin100 : CaelumSilverCoin
{
    Default { Tag "$CA_CURRENCY_SILVER_COIN_100"; }
    override int GetCurrencyType()
    {
        return CaelumConstants.CURRENCY_SILVER_HUNDRED;
    }
}

class CaelumGoldCoin : CaelumCurrencyItem
{
    Default
    {
        Tag "$CA_CURRENCY_GOLD_COIN";
        Inventory.Icon "graphics/caelum/icons/currency/ca_coin_gold.png";
        Inventory.PickupMessage "$CA_PICKUP_CURRENCY_GOLD";
    }

    override int GetCurrencyType()
    {
        return CaelumConstants.CURRENCY_GOLD;
    }

    States { Spawn: CGOL A -1; Stop; }
}

class CaelumGoldCoin5 : CaelumGoldCoin
{
    Default { Tag "$CA_CURRENCY_GOLD_COIN_5"; }
    override int GetCurrencyType()
    {
        return CaelumConstants.CURRENCY_GOLD_FIVE;
    }
}

class CaelumGoldCoin20 : CaelumGoldCoin
{
    Default { Tag "$CA_CURRENCY_GOLD_COIN_20"; }
    override int GetCurrencyType()
    {
        return CaelumConstants.CURRENCY_GOLD_TWENTY;
    }
}

class CaelumGoldCoin50 : CaelumGoldCoin
{
    Default { Tag "$CA_CURRENCY_GOLD_COIN_50"; }
    override int GetCurrencyType()
    {
        return CaelumConstants.CURRENCY_GOLD_FIFTY;
    }
}

class CaelumGoldCoin100 : CaelumGoldCoin
{
    Default { Tag "$CA_CURRENCY_GOLD_COIN_100"; }
    override int GetCurrencyType()
    {
        return CaelumConstants.CURRENCY_GOLD_HUNDRED;
    }
}

class CaelumEconomyRules : Object
{
    // Catálogo mínimo de Palomo. Los valores provienen de las anclas ya
    // autorizadas y se mantienen enteros para que todo pago sea físico.
    static clearscope int GetPalomoMerchantBaseValue(int merchantItem)
    {
        switch (merchantItem)
        {
            case CaelumConstants.PALOMO_MERCHANT_ITEM_FOOD:
                return CaelumConstants.ECONOMY_FOOD_RATION_VALUE;
            case CaelumConstants.PALOMO_MERCHANT_ITEM_WATER:
                return CaelumConstants.ECONOMY_WATER_RATION_VALUE;
            case CaelumConstants.PALOMO_MERCHANT_ITEM_WOOD:
                return 2;
            case CaelumConstants.PALOMO_MERCHANT_ITEM_RAW_COPPER:
            case CaelumConstants.PALOMO_MERCHANT_ITEM_RAW_TIN:
                return 5;
            default:
                return 0;
        }
    }

    // El margen se aplica una sola vez al lote completo. Comprar a Palomo
    // redondea hacia arriba; venderle redondea hacia abajo.
    static clearscope int GetPalomoMerchantLotPrice(
        int merchantItem, int quantity, int merchantMode,
        bool negotiatedDiscount = false
    )
    {
        int baseLot = GetPalomoMerchantBaseValue(merchantItem)
            * Max(0, quantity);
        if (merchantMode == CaelumConstants.PALOMO_MERCHANT_MODE_SELL)
        {
            int sellPercent = negotiatedDiscount
                ? CaelumConstants.PALOMO_DISCOUNT_SELL_PERCENT : 50;
            return baseLot * sellPercent / 100;
        }
        int buyPercent = negotiatedDiscount
            ? CaelumConstants.PALOMO_DISCOUNT_BUY_PERCENT : 150;
        return (baseLot * buyPercent + 99) / 100;
    }

    static clearscope int ResolveCurrencyType(int currencyType)
    {
        return Clamp(
            currencyType, 0, CaelumConstants.CURRENCY_TYPE_COUNT - 1
        );
    }

    static clearscope int GetCurrencyMetalType(int currencyType)
    {
        int resolvedType = ResolveCurrencyType(currencyType);
        if (resolvedType >= CaelumConstants.CURRENCY_GOLD)
        {
            return CaelumConstants.CURRENCY_METAL_GOLD;
        }
        if (resolvedType >= CaelumConstants.CURRENCY_SILVER)
        {
            return CaelumConstants.CURRENCY_METAL_SILVER;
        }
        return CaelumConstants.CURRENCY_METAL_COPPER;
    }

    static clearscope int GetCurrencyDenomination(int currencyType)
    {
        switch (ResolveCurrencyType(currencyType)
            % CaelumConstants.CURRENCY_DENOMINATION_COUNT)
        {
            case 1: return 5;
            case 2: return 20;
            case 3: return 50;
            case 4: return 100;
            default: return 1;
        }
    }

    static clearscope int GetCurrencyMetalUnitValue(int currencyMetalType)
    {
        if (currencyMetalType == CaelumConstants.CURRENCY_METAL_GOLD)
        {
            return CaelumConstants.CURRENCY_GOLD_VALUE;
        }
        if (currencyMetalType == CaelumConstants.CURRENCY_METAL_SILVER)
        {
            return CaelumConstants.CURRENCY_SILVER_VALUE;
        }
        return CaelumConstants.CURRENCY_COPPER_VALUE;
    }

    static clearscope int GetCurrencyFaceValue(int currencyType)
    {
        return GetCurrencyDenomination(currencyType)
            * GetCurrencyMetalUnitValue(GetCurrencyMetalType(currencyType));
    }

    static Name GetCurrencyClassName(int currencyType)
    {
        switch (ResolveCurrencyType(currencyType))
        {
            case CaelumConstants.CURRENCY_COPPER_FIVE:
                return 'CaelumCopperCoin5';
            case CaelumConstants.CURRENCY_COPPER_TWENTY:
                return 'CaelumCopperCoin20';
            case CaelumConstants.CURRENCY_COPPER_FIFTY:
                return 'CaelumCopperCoin50';
            case CaelumConstants.CURRENCY_COPPER_HUNDRED:
                return 'CaelumCopperCoin100';
            case CaelumConstants.CURRENCY_SILVER:
                return 'CaelumSilverCoin';
            case CaelumConstants.CURRENCY_SILVER_FIVE:
                return 'CaelumSilverCoin5';
            case CaelumConstants.CURRENCY_SILVER_TWENTY:
                return 'CaelumSilverCoin20';
            case CaelumConstants.CURRENCY_SILVER_FIFTY:
                return 'CaelumSilverCoin50';
            case CaelumConstants.CURRENCY_SILVER_HUNDRED:
                return 'CaelumSilverCoin100';
            case CaelumConstants.CURRENCY_GOLD:
                return 'CaelumGoldCoin';
            case CaelumConstants.CURRENCY_GOLD_FIVE:
                return 'CaelumGoldCoin5';
            case CaelumConstants.CURRENCY_GOLD_TWENTY:
                return 'CaelumGoldCoin20';
            case CaelumConstants.CURRENCY_GOLD_FIFTY:
                return 'CaelumGoldCoin50';
            case CaelumConstants.CURRENCY_GOLD_HUNDRED:
                return 'CaelumGoldCoin100';
            default: return 'CaelumCopperCoin';
        }
    }

    // La cantidad de estaciones crece con el tier de la receta: la red T1
    // aplica 25 %, la ampliación T2 50 % y la mesa maestra T3 100 %.
    static int GetManufacturingMarkupPercent(int craftingTier)
    {
        if (craftingTier <= 1)
        {
            return CaelumConstants.ECONOMY_TIER_ONE_MARKUP_PERCENT;
        }
        if (craftingTier == 2)
        {
            return CaelumConstants.ECONOMY_TIER_TWO_MARKUP_PERCENT;
        }
        return CaelumConstants.ECONOMY_TIER_THREE_MARKUP_PERCENT;
    }

    static double ApplyMarkup(double inputValue, int markupPercent)
    {
        return Max(0.0, inputValue)
            * (100.0 + Max(0, markupPercent)) / 100.0;
    }

    // Anclas económicas autorizadas para materias primas. Las fuentes siguen
    // usando sus reglas físicas de dureza y abundancia; esas reglas determinan
    // obtención, no vuelven a sobrescribir estos precios de diseño.
    static double GetRawMaterialUnitValue(int materialType)
    {
        switch (materialType)
        {
            case CaelumConstants.MATERIAL_WOOD: return 2.0;
            case CaelumConstants.MATERIAL_PLANT_FIBER: return 3.0;
            case CaelumConstants.MATERIAL_WOOL: return 2.0;
            case CaelumConstants.MATERIAL_COTTON: return 4.0;
            case CaelumConstants.MATERIAL_RAW_SILK: return 8.0;
            case CaelumConstants.MATERIAL_COW_HIDE: return 3.0;
            case CaelumConstants.MATERIAL_PREDATOR_HIDE: return 4.0;
            case CaelumConstants.MATERIAL_MONSTER_HIDE: return 8.0;
            case CaelumConstants.MATERIAL_COAL: return 5.0;
            case CaelumConstants.MATERIAL_RAW_COPPER: return 5.0;
            case CaelumConstants.MATERIAL_RAW_IRON: return 7.0;
            case CaelumConstants.MATERIAL_RAW_TIN: return 5.0;
            case CaelumConstants.MATERIAL_RAW_SILVER: return 100.0;
            case CaelumConstants.MATERIAL_RAW_GOLD: return 1000.0;
            case CaelumConstants.MATERIAL_RAW_OPAL: return 500.0;
            case CaelumConstants.MATERIAL_RAW_TOPAZ: return 500.0;
            case CaelumConstants.MATERIAL_RAW_EMERALD: return 500.0;
            case CaelumConstants.MATERIAL_RAW_SAPPHIRE: return 500.0;
            case CaelumConstants.MATERIAL_RAW_RUBY: return 500.0;
            default: return 2.0;
        }
    }

    static double GetProcessingMaterialUnitValue(int recipeIndex)
    {
        int inputOne = CaelumCraftingRules.GetProcessingInputOneMaterial(
            recipeIndex
        );
        int inputOneTier =
            CaelumCraftingRules.GetProcessingInputOneTier(recipeIndex);
        int inputOneUnits = CaelumCraftingRules.GetProcessingInputOneUnits(
            recipeIndex, 0
        );
        double inputValue = GetMaterialUnitBaseValue(
            inputOne, inputOneTier
        ) * inputOneUnits;

        int inputTwo = CaelumCraftingRules.GetProcessingInputTwoMaterial(
            recipeIndex
        );
        int inputTwoUnits = CaelumCraftingRules.GetProcessingInputTwoUnits(
            recipeIndex, 0
        );
        if (inputTwo >= 0 && inputTwoUnits > 0)
        {
            inputValue += GetMaterialUnitBaseValue(
                inputTwo,
                CaelumCraftingRules.GetProcessingInputTwoTier(recipeIndex)
            ) * inputTwoUnits;
        }

        int outputUnits =
            CaelumCraftingRules.GetProcessingOutputUnitsAtEfficiency(
                recipeIndex,
                0,
                CaelumConstants.ECONOMY_REFERENCE_EFFICIENCY_INDEX
            );
        if (outputUnits <= 0) { return 0.0; }
        return ApplyMarkup(
            inputValue,
            CaelumConstants.ECONOMY_PROCESSING_MARKUP_PERCENT
        ) / outputUnits;
    }

    static double GetComponentMaterialUnitValue(
        int materialType, int materialTier
    )
    {
        int baseMaterial = CaelumCraftingRules.GetComponentBaseMaterial(
            materialType, materialTier
        );
        int baseTier = CaelumCraftingRules.GetComponentBaseTier(
            materialType, materialTier
        );
        int inputUnits = CaelumCraftingRules.GetComponentInputUnits(0);
        int outputUnits = CaelumCraftingRules.GetComponentOutputUnits(
            0, CaelumConstants.ECONOMY_REFERENCE_EFFICIENCY_INDEX
        );
        if (outputUnits <= 0) { return 0.0; }
        double inputValue = GetMaterialUnitBaseValue(
            baseMaterial, baseTier
        ) * inputUnits;
        return ApplyMarkup(
            inputValue, GetManufacturingMarkupPercent(materialTier)
        ) / outputUnits;
    }

    // Valor recursivo por unidad de 0,001 kg. El orden procesamiento ->
    // componente -> materia prima reproduce exactamente las capas de receta.
    static double GetMaterialUnitBaseValue(
        int materialType, int materialTier = 1
    )
    {
        int resolvedType = Clamp(
            materialType,
            CaelumConstants.MATERIAL_FIRST_ACTIVE,
            CaelumConstants.MATERIAL_TYPE_COUNT - 1
        );
        int resolvedTier = CaelumMaterialRules.ResolveTier(
            resolvedType, materialTier
        );

        int processingRecipe = CaelumCraftingRules.FindProcessingRecipeForOutput(
            resolvedType, resolvedTier
        );
        if (processingRecipe >= 0)
        {
            return GetProcessingMaterialUnitValue(processingRecipe);
        }

        int componentRecipe =
            CaelumCraftingRules.FindComponentRecipeForOutput(resolvedType);
        if (componentRecipe >= 0)
        {
            return GetComponentMaterialUnitValue(
                resolvedType, resolvedTier
            );
        }
        return GetRawMaterialUnitValue(resolvedType);
    }

    static double AddPreciousDetailValue(
        double materialValue, double finalWeight, int craftingTier
    )
    {
        int silverUnits = CaelumCraftingRules.GetRequiredSilverDetailUnits(
            finalWeight, craftingTier
        );
        int goldUnits = CaelumCraftingRules.GetRequiredGoldDetailUnits(
            finalWeight, craftingTier
        );
        return materialValue
            + silverUnits * GetMaterialUnitBaseValue(
                CaelumConstants.MATERIAL_SILVER_INGOT, 1
            )
            + goldUnits * GetMaterialUnitBaseValue(
                CaelumConstants.MATERIAL_GOLD_INGOT, 1
            );
    }

    static double FinishManufacturedObjectValue(
        double materialValue, double finalWeight, int craftingTier
    )
    {
        return ApplyMarkup(
            AddPreciousDetailValue(
                materialValue, finalWeight, craftingTier
            ),
            GetManufacturingMarkupPercent(craftingTier)
        );
    }

    static double GetPhysicalWeaponBaseValue(
        int weaponType, int craftingTier, double finalWeight
    )
    {
        int weaponId = CaelumCraftingRules.GetCatalogueWeaponForPlayableType(
            weaponType
        );
        if (weaponId < 0) { return 0.0; }
        int basicMaterial = CaelumCraftingRules.GetBasicMaterial(weaponId);
        int tierMaterial = CaelumCraftingRules.GetTierMaterial(weaponId);
        double materialValue =
            CaelumCraftingRules.GetRequiredBasicMaterialUnits(
                weaponId, finalWeight
            ) * GetMaterialUnitBaseValue(basicMaterial, 1)
            + CaelumCraftingRules.GetRequiredTierMaterialUnits(
                weaponId, finalWeight
            ) * GetMaterialUnitBaseValue(
                tierMaterial, craftingTier
            );
        return FinishManufacturedObjectValue(
            materialValue, finalWeight, craftingTier
        );
    }

    static double GetEssenceWeaponBaseValue(
        int weaponType, int essenceType, int craftingTier,
        double finalWeight
    )
    {
        int baseMaterial = CaelumCraftingRules.GetEssenceBaseMaterial(
            weaponType
        );
        int essenceMaterial = CaelumCraftingRules.GetEssenceMaterial(
            essenceType
        );
        double materialValue =
            CaelumCraftingRules.GetRequiredEssenceBaseUnits(finalWeight)
                * GetMaterialUnitBaseValue(baseMaterial, 1)
            + CaelumCraftingRules.GetRequiredEssenceUnits(finalWeight)
                * GetMaterialUnitBaseValue(
                    essenceMaterial, craftingTier
                );
        return FinishManufacturedObjectValue(
            materialValue, finalWeight, craftingTier
        );
    }

    static double GetArmorBaseValue(
        int armorType, int armorSlot, int craftingTier,
        double finalWeight
    )
    {
        int tierMaterial = CaelumCraftingRules.GetArmorTierMaterial(
            armorType
        );
        double materialValue =
            CaelumCraftingRules.GetRequiredArmorBaseUnits(
                armorSlot, finalWeight
            ) * GetMaterialUnitBaseValue(
                CaelumConstants.MATERIAL_STRAP, 1
            )
            + CaelumCraftingRules.GetRequiredArmorTierUnits(
                armorSlot, finalWeight
            ) * GetMaterialUnitBaseValue(
                tierMaterial, craftingTier
            );
        return FinishManufacturedObjectValue(
            materialValue, finalWeight, craftingTier
        );
    }

    static double GetShieldBaseValue(
        int shieldType, int craftingTier, double finalWeight
    )
    {
        int plateMaterial = CaelumCraftingRules.GetShieldPlateMaterial(
            shieldType
        );
        double materialValue =
            CaelumCraftingRules.GetRequiredShieldStrapUnits(finalWeight)
                * GetMaterialUnitBaseValue(
                    CaelumConstants.MATERIAL_STRAP, 1
                )
            + CaelumCraftingRules.GetRequiredShieldPlateUnits(finalWeight)
                * GetMaterialUnitBaseValue(
                    plateMaterial, craftingTier
                );
        return FinishManufacturedObjectValue(
            materialValue, finalWeight, craftingTier
        );
    }

    static double GetAmuletBaseValue(
        int amuletType, int craftingTier, double finalWeight
    )
    {
        double materialValue =
            CaelumCraftingRules.GetRequiredAmuletBaseUnits(finalWeight)
                * GetMaterialUnitBaseValue(
                    CaelumConstants.MATERIAL_SILVER_CHAIN, 1
                )
            + CaelumCraftingRules.GetRequiredAmuletTierUnits(finalWeight)
                * GetMaterialUnitBaseValue(
                    CaelumCraftingRules.GetAmuletTierMaterial(amuletType),
                    craftingTier
                );
        return FinishManufacturedObjectValue(
            materialValue, finalWeight, craftingTier
        );
    }

    static double GetSealBaseValue(
        int sealType, int craftingTier, double finalWeight
    )
    {
        double materialValue =
            CaelumCraftingRules.GetRequiredSealBaseUnits(finalWeight)
                * GetMaterialUnitBaseValue(
                    CaelumConstants.MATERIAL_SEAL_BASE, craftingTier
                )
            + CaelumCraftingRules.GetRequiredSealTierUnits(finalWeight)
                * GetMaterialUnitBaseValue(
                    CaelumCraftingRules.GetSealTierMaterial(sealType),
                    craftingTier
                );
        return FinishManufacturedObjectValue(
            materialValue, finalWeight, craftingTier
        );
    }

    static bool IsEssenceWeaponType(int weaponType)
    {
        return weaponType == CaelumConstants.WEAPON_TYPE_STAFF
            || weaponType == CaelumConstants.WEAPON_TYPE_BELL
            || weaponType == CaelumConstants.WEAPON_TYPE_BOOK
            || weaponType == CaelumConstants.WEAPON_TYPE_STATUETTE;
    }

    play static double GetEquipmentItemBaseValue(CaelumEquipmentItem item)
    {
        if (item == null) { return 0.0; }
        int tier = Clamp(item.Tier, 1, 3);
        double finalWeight = Max(0.0, item.UnitWeight);
        if (item.EquipmentKind == CaelumConstants.EQUIPMENT_KIND_WEAPON)
        {
            if (IsEssenceWeaponType(item.ItemType))
            {
                return GetEssenceWeaponBaseValue(
                    item.ItemType, item.EssenceType, tier, finalWeight
                );
            }
            return GetPhysicalWeaponBaseValue(
                item.ItemType, tier, finalWeight
            );
        }
        if (item.EquipmentKind == CaelumConstants.EQUIPMENT_KIND_ARMOR)
        {
            return GetArmorBaseValue(
                item.ItemType, item.ArmorSlot, tier, finalWeight
            );
        }
        if (item.EquipmentKind == CaelumConstants.EQUIPMENT_KIND_SHIELD)
        {
            return GetShieldBaseValue(
                item.ItemType, tier, finalWeight
            );
        }
        if (item.EquipmentKind == CaelumConstants.EQUIPMENT_KIND_AMULET)
        {
            return GetAmuletBaseValue(
                item.ItemType, tier, finalWeight
            );
        }
        if (item.EquipmentKind == CaelumConstants.EQUIPMENT_KIND_SEAL)
        {
            return GetSealBaseValue(
                item.ItemType, tier, finalWeight
            );
        }
        return 0.0;
    }

    static double GetConsumableUnitBaseValue(int consumableType)
    {
        if (consumableType == CaelumConstants.CONSUMABLE_FOOD_RATION)
        {
            return CaelumConstants.ECONOMY_FOOD_RATION_VALUE;
        }
        if (consumableType == CaelumConstants.CONSUMABLE_WATER_RATION)
        {
            return CaelumConstants.ECONOMY_WATER_RATION_VALUE;
        }
        return 0.0;
    }

    play static double GetInventoryUnitBaseValue(Inventory item)
    {
        if (item == null) { return 0.0; }
        CaelumCurrencyItem currency = CaelumCurrencyItem(item);
        if (currency != null) { return currency.GetFaceValue(); }
        CaelumConsumableItem consumable = CaelumConsumableItem(item);
        if (consumable != null)
        {
            return GetConsumableUnitBaseValue(consumable.GetConsumableType());
        }
        CaelumEquipmentItem equipment = CaelumEquipmentItem(item);
        if (equipment != null)
        {
            return GetEquipmentItemBaseValue(equipment);
        }
        CaelumSpecialInventoryItem specialItem =
            CaelumSpecialInventoryItem(item);
        if (specialItem != null
            && specialItem.GetSpecialCategory()
                == CaelumConstants.EQUIPMENT_KIND_MATERIAL)
        {
            return GetMaterialUnitBaseValue(
                specialItem.GetSpecialType(), specialItem.GetSpecialTier()
            );
        }
        // Munición, llaves y objetos clave quedan fuera del comercio hasta
        // contar con una receta o un valor base autorizado.
        return 0.0;
    }

    play static double GetInventoryStackBaseValue(Inventory item)
    {
        if (item == null || item.Amount <= 0) { return 0.0; }
        return GetInventoryUnitBaseValue(item) * item.Amount;
    }

    static int RoundCopperDown(double value)
    {
        return int(Floor(
            Clamp(value, 0.0, 2147483647.0) + 0.0000001
        ));
    }

    static int RoundCopperUp(double value)
    {
        return int(Ceil(
            Clamp(value, 0.0, 2147483647.0) - 0.0000001
        ));
    }

    static int GetBasePrice(double unitBaseValue, int amount = 1)
    {
        return RoundCopperUp(Max(0, amount) * Max(0.0, unitBaseValue));
    }

    // El margen se calcula después de sumar el lote. Así dos objetos de valor
    // 1 pueden venderse al NPC por 1 cobre sin crear fracciones monetarias.
    static int GetPricePaidByMerchant(
        double unitBaseValue, int amount = 1
    )
    {
        return RoundCopperDown(
            Max(0, amount) * Max(0.0, unitBaseValue)
                * CaelumConstants.ECONOMY_MERCHANT_PAYS_MULTIPLIER
        );
    }

    static int GetPriceChargedByMerchant(
        double unitBaseValue, int amount = 1
    )
    {
        return RoundCopperUp(
            Max(0, amount) * Max(0.0, unitBaseValue)
                * CaelumConstants.ECONOMY_MERCHANT_CHARGES_MULTIPLIER
        );
    }
}
