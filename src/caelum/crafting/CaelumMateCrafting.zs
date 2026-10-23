// #472: las tres vasijas reutilizan fabricación, reservas y aprendizaje existentes.
class CaelumMateCrafting : Object
{
    static clearscope String Icon(int variant)
    {return variant==0?"graphics/caelum/icons/mate/gourd.png":variant==1?"graphics/caelum/icons/mate/silver.png":"graphics/caelum/icons/mate/gold.png";}
    static double Value(int variant)
    {
        double inputs=CaelumMateData.PrimaryGrams(variant)*CaelumEconomyRules.GetMaterialUnitBaseValue(CaelumMateData.PrimaryMaterial(variant),1)
            +CaelumMateData.SecondaryGrams(variant)*CaelumEconomyRules.GetMaterialUnitBaseValue(CaelumMateData.SecondaryMaterial(variant),1)
            +CaelumMateData.BronzeGrams(variant)*CaelumEconomyRules.GetMaterialUnitBaseValue(CaelumConstants.MATERIAL_BRONZE_INGOT,1);
        return CaelumEconomyRules.FinishManufacturedObjectValue(inputs,CaelumMateData.EmptyMass(variant),1);
    }
    static int MissingStation(int variant,int capabilities)
    {
        if(!CaelumCraftingRules.NetworkHasStation(capabilities,CaelumConstants.CRAFTING_STATION_WORKBENCH))return CaelumConstants.CRAFTING_STATION_WORKBENCH;
        if(!CaelumCraftingRules.NetworkHasStation(capabilities,CaelumConstants.CRAFTING_STATION_FINE_TOOLS_BENCH))return CaelumConstants.CRAFTING_STATION_FINE_TOOLS_BENCH;
        if(variant>0 && !CaelumCraftingRules.NetworkHasStation(capabilities,CaelumConstants.CRAFTING_STATION_JEWELER_BENCH))return CaelumConstants.CRAFTING_STATION_JEWELER_BENCH;
        return CaelumConstants.CRAFTING_STATION_NONE;
    }
    static play void Preview(CaelumPlayer user)
    {
        int variant=user.CraftingSelectionRecipe-CaelumMateData.FIRST_RECIPE;
        user.CraftingSelectionTier=1;user.CraftingFinalWeight=CaelumMateData.EmptyMass(variant);
        user.CraftingBasicMaterialType=CaelumMateData.PrimaryMaterial(variant);user.CraftingBasicMaterialTier=1;
        user.CraftingTierMaterialType=CaelumMateData.SecondaryMaterial(variant);user.CraftingTierMaterialTier=1;
        user.CraftingBasicRequired=CaelumMateData.PrimaryGrams(variant);
        user.CraftingTierRequired=CaelumMateData.SecondaryGrams(variant);
        user.CraftingSilverRequired=CaelumMateData.BronzeGrams(variant);user.CraftingGoldRequired=0;
        user.CraftingMissingStationType=MissingStation(variant,user.CraftingNetworkCapabilities);
    }
}
