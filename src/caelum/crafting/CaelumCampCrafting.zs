// La receta usa las cuatro reservas existentes; no agrega una segunda cartera.
class CaelumCampCrafting : Object
{
    static double Value(int variant)
    {
        double inputs=0;
        for(int slot=0;slot<4;slot++)
            if(CaelumCampData.Grams(variant,slot)>0)
                inputs+=CaelumCampData.Grams(variant,slot)*CaelumEconomyRules.GetMaterialUnitBaseValue(
                    CaelumCampData.Material(variant,slot),CaelumCampData.MaterialTier(variant,slot));
        return CaelumEconomyRules.FinishManufacturedObjectValue(inputs,CaelumCampData.Mass(variant),1);
    }
    static int MissingStation(int variant,int capabilities)
    {
        int first=variant==0?CaelumConstants.CRAFTING_STATION_WORKBENCH:CaelumConstants.CRAFTING_STATION_FORGE;
        int second=variant==0?CaelumConstants.CRAFTING_STATION_SEWING_MACHINE:CaelumConstants.CRAFTING_STATION_ANVIL;
        if(!CaelumCraftingRules.NetworkHasStation(capabilities,first))return first;
        if(!CaelumCraftingRules.NetworkHasStation(capabilities,second))return second;
        if(variant==0 && !CaelumCraftingRules.NetworkHasStation(capabilities,CaelumConstants.CRAFTING_STATION_FINE_TOOLS_BENCH))
            return CaelumConstants.CRAFTING_STATION_FINE_TOOLS_BENCH;
        return CaelumConstants.CRAFTING_STATION_NONE;
    }
    static play void Preview(CaelumPlayer user)
    {
        int variant=user.CraftingSelectionRecipe-CaelumCampData.FIRST_RECIPE;
        user.CraftingSelectionTier=1;user.CraftingFinalWeight=CaelumCampData.Mass(variant);
        user.CraftingBasicMaterialType=CaelumCampData.Material(variant,0);
        user.CraftingBasicMaterialTier=CaelumCampData.MaterialTier(variant,0);
        user.CraftingTierMaterialType=CaelumCampData.Material(variant,1);
        user.CraftingTierMaterialTier=CaelumCampData.MaterialTier(variant,1);
        user.CraftingBasicRequired=CaelumCampData.Grams(variant,0);
        user.CraftingTierRequired=CaelumCampData.Grams(variant,1);
        user.CraftingSilverRequired=CaelumCampData.Grams(variant,2);
        user.CraftingGoldRequired=CaelumCampData.Grams(variant,3);
        user.CraftingMissingStationType=MissingStation(variant,user.CraftingNetworkCapabilities);
    }
}
