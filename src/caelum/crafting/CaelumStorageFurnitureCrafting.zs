// Dos reservas nativas, merma/tiempo normales y precios derivados, sin cartera paralela.
class CaelumStorageFurnitureCrafting : Object
{
    static double Value(int variant)
    {
        double inputs=CaelumStorageFurnitureData.Grams(variant,0)*CaelumEconomyRules.GetMaterialUnitBaseValue(CaelumConstants.MATERIAL_WOOD,1)
            +CaelumStorageFurnitureData.Grams(variant,1)*CaelumEconomyRules.GetMaterialUnitBaseValue(CaelumConstants.MATERIAL_IRON_INGOT,2);
        return CaelumEconomyRules.FinishManufacturedObjectValue(inputs,CaelumStorageFurnitureData.Mass(variant),1);
    }
    static int MissingStation(int capabilities)
    {
        if(!CaelumCraftingRules.NetworkHasStation(capabilities,CaelumConstants.CRAFTING_STATION_WORKBENCH))return CaelumConstants.CRAFTING_STATION_WORKBENCH;
        if(!CaelumCraftingRules.NetworkHasStation(capabilities,CaelumConstants.CRAFTING_STATION_FINE_TOOLS_BENCH))return CaelumConstants.CRAFTING_STATION_FINE_TOOLS_BENCH;
        return CaelumConstants.CRAFTING_STATION_NONE;
    }
    static play void Preview(CaelumPlayer user)
    {
        int variant=user.CraftingSelectionRecipe-CaelumStorageFurnitureData.FIRST_RECIPE;
        user.CraftingSelectionTier=1;user.CraftingFinalWeight=CaelumStorageFurnitureData.Mass(variant);
        user.CraftingBasicMaterialType=CaelumConstants.MATERIAL_WOOD;user.CraftingBasicMaterialTier=1;
        user.CraftingTierMaterialType=CaelumConstants.MATERIAL_IRON_INGOT;user.CraftingTierMaterialTier=2;
        user.CraftingBasicRequired=CaelumStorageFurnitureData.Grams(variant,0);
        user.CraftingTierRequired=CaelumStorageFurnitureData.Grams(variant,1);
        user.CraftingSilverRequired=0;user.CraftingGoldRequired=0;
        user.CraftingMissingStationType=MissingStation(user.CraftingNetworkCapabilities);
    }
}
