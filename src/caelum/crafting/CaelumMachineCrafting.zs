class CaelumMachineCrafting : Object
{
    static int MissingStation(int kind,int capabilities)
    {
        if(!CaelumCraftingRules.NetworkHasStation(capabilities,CaelumConstants.CRAFTING_STATION_WORKBENCH))return CaelumConstants.CRAFTING_STATION_WORKBENCH;
        if(kind==CaelumMachineData.CANNON)
        {
            if(!CaelumCraftingRules.NetworkHasStation(capabilities,CaelumConstants.CRAFTING_STATION_FORGE))return CaelumConstants.CRAFTING_STATION_FORGE;
            if(!CaelumCraftingRules.NetworkHasStation(capabilities,CaelumConstants.CRAFTING_STATION_ANVIL))return CaelumConstants.CRAFTING_STATION_ANVIL;
        }
        return CaelumConstants.CRAFTING_STATION_NONE;
    }
    static play void Preview(CaelumPlayer user)
    {
        int kind=user.CraftingSelectionRecipe-CaelumMachineData.FIRST_RECIPE;
        user.CraftingSelectionTier=1;user.CraftingFinalWeight=CaelumMachineData.Mass(kind);
        user.CraftingBasicMaterialType=CaelumConstants.MATERIAL_WOOD;user.CraftingBasicMaterialTier=1;
        user.CraftingTierMaterialType=CaelumConstants.MATERIAL_IRON_INGOT;user.CraftingTierMaterialTier=1;
        user.CraftingBasicRequired=CaelumMachineData.Grams(kind,0);
        user.CraftingTierRequired=CaelumMachineData.Grams(kind,1);
        user.CraftingSilverRequired=0;user.CraftingGoldRequired=0;
        user.CraftingMissingStationType=MissingStation(kind,user.CraftingNetworkCapabilities);
    }
    static play double Seconds(CaelumPlayer user,int recipe,int efficiency)
    {
        let record=user.GetPersistentCharacterState(false);int slot=CaelumRecipeLearning.Slot(recipe,1);
        return CaelumMachineData.Seconds(recipe-CaelumMachineData.FIRST_RECIPE)
            *CaelumRecipeLearning.TimeFactor(record==null?0:record.RecipeRereadings[slot],
                record==null?0:record.RecipePractice[slot],recipe,efficiency)
            *100.0/user.GetCraftingDexterityPercent();
    }
    static play double Radius(int kind)
    {return kind==CaelumMachineData.BARRICADE?CaelumMachineData.BARRICADE_WIDTH/2:
        Max(CaelumCannonData.TRAIL,CaelumCannonData.MUZZLE_X);}
    static play double Height(int kind)
    {return kind==CaelumMachineData.BARRICADE?CaelumMachineData.BARRICADE_HEIGHT:
        CaelumCannonData.PIVOT_Z+CaelumCannonData.WHEEL_RADIUS;}
    static play bool Fits(CaelumPlayer user,int kind,vector3 point)
    {return CaelumPlacementGeometry.Fits(user,point,Radius(kind),Height(kind));}
}
