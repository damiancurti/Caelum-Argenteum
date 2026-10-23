// #383: el comercio conserva libros como stock nativo; el jugador recibe hojas.
class CaelumRecipeOffer : Inventory
{
    int Recipe,Tier;
    double BaseValue;
    Default
    {
        Inventory.MaxAmount 2147483647; Inventory.InterHubAmount 2147483647;
        +INVENTORY.UNDROPPABLE -INVENTORY.INVBAR
    }
    States { Spawn: TNT1 A -1; Stop; }
}

class CaelumLibrary : Object play
{
    // Consultar las mismas fórmulas que fabricación/valoración sin crear objetos
    // ni recorrer el inventario cientos de veces al abrir el catálogo completo.
    static double ProductValue(CaelumPlayer user,int recipe,int requestedTier)
    {
        if(CaelumMateData.IsRecipe(recipe))return CaelumMateCrafting.Value(recipe-CaelumMateData.FIRST_RECIPE);
        if(CaelumSupportImplementData.RetiredRecipe(recipe))return 0;
        int tier=CaelumRecipeLearning.Tier(recipe,requestedTier);
        int size=CaelumConstants.EQUIPMENT_SIZE_XL;
        int kind=CaelumCraftingRules.GetUnifiedRecipeKind(recipe);
        int potion=CaelumChemistryData.OutputConsumable(recipe);
        if(potion>=0)return CaelumEconomyRules.GetConsumableUnitBaseValue(potion);
        if(CaelumClothingData.IsRecipe(recipe))return CaelumClothingData.Value(recipe-CaelumClothingData.FIRST_RECIPE,size);
        if(CaelumLockRules.IsRecipe(recipe))
        {
            int item=CaelumLockRules.RecipeItem(recipe);
            return CaelumLockRules.Value(item)+(item<3 ? CaelumLockRules.Value(item+3) : 0.0);
        }
        if(CaelumUtilityCrafting.IsRecipe(recipe))
        {
            double weight=CaelumUtilityCrafting.Weight(recipe);
            double value=CaelumCraftingRules.GetRoundedMaterialUnits(weight,CaelumOnboardingCatalogue.LEATHER_SHARE)
                *CaelumEconomyRules.GetMaterialUnitBaseValue(CaelumConstants.MATERIAL_LEATHER,1)
                +CaelumCraftingRules.GetRoundedMaterialUnits(weight,CaelumOnboardingCatalogue.ROPE_SHARE)
                *CaelumEconomyRules.GetMaterialUnitBaseValue(CaelumConstants.MATERIAL_ROPE,1);
            return CaelumEconomyRules.FinishManufacturedObjectValue(value,weight,tier);
        }
        if(kind==CaelumConstants.CRAFTING_RECIPE_KIND_AMMUNITION)
            return CaelumEconomyRules.GetAmmunitionUnitBaseValue(CaelumCraftingRules.GetRecipeAmmunitionType(recipe));
        if(kind==CaelumConstants.CRAFTING_RECIPE_KIND_PROCESSING)
            return CaelumEconomyRules.GetMaterialUnitBaseValue(CaelumCraftingRules.GetProcessingOutputMaterial(recipe),tier);
        if(kind==CaelumConstants.CRAFTING_RECIPE_KIND_COMPONENT)
            return CaelumEconomyRules.GetMaterialUnitBaseValue(CaelumCraftingRules.GetComponentOutputMaterial(recipe),tier);
        double weight=0;int item=0,slot=0,essence=0,equipmentKind=-1;
        if(kind==CaelumConstants.CRAFTING_RECIPE_KIND_PHYSICAL_WEAPON)
        {
            int catalogue=CaelumCraftingRules.GetStationRecipeWeapon(CaelumConstants.CRAFTING_STATION_WORKBENCH,
                CaelumCraftingRules.GetUnifiedPhysicalRecipeIndex(recipe));
            item=CaelumCraftingRules.GetPlayableWeaponType(catalogue);equipmentKind=CaelumConstants.EQUIPMENT_KIND_WEAPON;
            weight=CaelumCraftingRules.GetCraftedWeaponWeight(CaelumCraftingRules.GetPlayableTierOneWeight(catalogue),tier,size);
        }
        else if(kind==CaelumConstants.CRAFTING_RECIPE_KIND_ESSENCE_WEAPON)
        {
            item=CaelumCraftingRules.GetUnifiedEssenceWeaponType(recipe);essence=CaelumCraftingRules.GetUnifiedEssenceType(recipe);
            equipmentKind=CaelumConstants.EQUIPMENT_KIND_WEAPON;
            weight=CaelumCraftingRules.GetCraftedWeaponWeight(CaelumCraftingRules.GetEssenceTierOneWeight(item),tier,size);
        }
        else if(kind==CaelumConstants.CRAFTING_RECIPE_KIND_ARMOR && user.ArmorModel!=null)
        {
            item=CaelumCraftingRules.GetUnifiedArmorType(recipe);slot=CaelumCraftingRules.GetUnifiedArmorSlot(recipe);
            equipmentKind=CaelumConstants.EQUIPMENT_KIND_ARMOR;weight=user.ArmorModel.GetWeightFor(slot,item,tier,size);
        }
        else if(kind==CaelumConstants.CRAFTING_RECIPE_KIND_SHIELD && user.ShieldModel!=null)
        {
            item=CaelumCraftingRules.GetUnifiedShieldType(recipe);equipmentKind=CaelumConstants.EQUIPMENT_KIND_SHIELD;
            weight=user.ShieldModel.GetWeightFor(item,tier,size);
        }
        else if(kind==CaelumConstants.CRAFTING_RECIPE_KIND_AMULET || kind==CaelumConstants.CRAFTING_RECIPE_KIND_SEAL)
        {
            bool amulet=kind==CaelumConstants.CRAFTING_RECIPE_KIND_AMULET;
            item=amulet ? CaelumCraftingRules.GetUnifiedAmuletType(recipe) : CaelumCraftingRules.GetUnifiedSealType(recipe);
            equipmentKind=amulet ? CaelumConstants.EQUIPMENT_KIND_AMULET : CaelumConstants.EQUIPMENT_KIND_SEAL;
            weight=CaelumCraftingRules.GetJewelryWeight(tier);
        }
        return CaelumEconomyRules.GetEquipmentBaseValueFor(equipmentKind,item,slot,tier,essence,weight);
    }
    static double BookValue(CaelumPlayer user,int recipe,int tier)
    {return ProductValue(user,recipe,tier)*(!CaelumLockRules.IsRecipe(recipe) && CaelumRecipeLearning.Consumable(recipe)
        ? CaelumRecipeLearning.CONSUMABLE_PRICE_UNITS : CaelumRecipeLearning.EQUIPMENT_PRICE_RATIO);}

    static bool MatchesCategory(int recipe,int category)
    {return CaelumLockRules.IsRecipe(recipe) ? category==0 || category==10
        : CaelumCraftingRules.RecipeMatchesFilter(recipe,category);}

    static String NameFor(CaelumRecipeOffer offer)
    {return String.Format(StringTable.Localize("CA_LIBRARY_BOOK",false),CaelumCraftingBrowser.RecipeName(offer.Recipe,offer.Tier),offer.Tier);}
}

// Plan transitorio de capacidad; las hojas y el dinero sólo cambian al confirmar
// juntos en InventoryService, nunca al cotizar, dibujar o cambiar de categoría.
class CaelumLibraryPurchase : Object play
{
    CaelumRecipeQuote Quote;
    CaelumRecipeBook Book;
    int ExtraPages;
    double AddedWeight;
    void Build(CaelumPlayer user,CaelumRecipeOffer offer)
    {
        Quote=new("CaelumRecipeQuote");Quote.Build(user,offer.Recipe,offer.Tier);
        Book=CaelumRecipeBook(user.FindInventory("CaelumRecipeBook"));ExtraPages=0;
        for(int i=0;i<Quote.Sheets.Size();i++)if(Book==null || !Book.Sheets[Quote.Sheets[i]])ExtraPages++;
        AddedWeight=ExtraPages*CaelumRecipeLearning.SHEET_KG+(Book==null ? CaelumRecipeLearning.BOOK_KG : 0.0);
    }
    bool Capacity(CaelumPlayer user,int price)
    {
        user.RefreshCarriedInventorySummary();
        for(int moneyRoute=0;moneyRoute<2;moneyRoute++)
        {
            if(!user.BuildPalomoCurrencyPaymentPlan(price))return false;
            if(moneyRoute==1){if(!user.MagicBoxOwned)continue;user.RoutePalomoCurrencyGainsToMagicBox();}
            for(int route=0;route<(Book==null?2:1);route++)
            {
                bool box=Book==null ? route==1 : Book.InMagicBox;
                if(box && !user.MagicBoxOwned)continue;
                double personal=user.GetPalomoCurrencyPlanPersonalWeightDelta(),raw=user.GetPalomoCurrencyPlanBoxRawWeightDelta();
                int slots=user.GetPalomoCurrencyPlanBoxSlotDelta();
                if(box){raw+=AddedWeight;if(Book==null)slots++;}else personal+=AddedWeight;
                if(user.PalomoTransactionCapacityFits(personal,raw,slots))
                {user.PalomoIncomingItemInMagicBox=box;return true;}
            }
        }
        return false;
    }
}
