// Las reservas nativas conservan desperdicio, Destreza, aprendizaje y cancelación.
class CaelumRestFurnitureCrafting : Object
{
    static double Value(int variant)
    {
        double cost=0;
        for(int s=0;s<3;s++)cost+=CaelumRestFurnitureData.Grams(variant,s)*CaelumEconomyRules.GetMaterialUnitBaseValue(CaelumRestFurnitureData.Material(s),CaelumRestFurnitureData.Tier(s));
        return CaelumEconomyRules.FinishManufacturedObjectValue(cost,CaelumRestFurnitureData.Mass(variant),1);
    }
    static play void Preview(CaelumPlayer u)
    {
        int v=u.CraftingSelectionRecipe-CaelumRestFurnitureData.FIRST_RECIPE;
        u.CraftingSelectionTier=1;u.CraftingFinalWeight=CaelumRestFurnitureData.Mass(v);
        u.CraftingBasicMaterialType=CaelumRestFurnitureData.Material(0);u.CraftingBasicMaterialTier=CaelumRestFurnitureData.Tier(0);
        u.CraftingTierMaterialType=CaelumRestFurnitureData.Material(1);u.CraftingTierMaterialTier=CaelumRestFurnitureData.Tier(1);
        u.CraftingBasicRequired=CaelumRestFurnitureData.Grams(v,0);u.CraftingTierRequired=CaelumRestFurnitureData.Grams(v,1);
        u.CraftingSilverRequired=CaelumRestFurnitureData.Grams(v,2);u.CraftingGoldRequired=0;
        u.CraftingMissingStationType=CaelumConstants.CRAFTING_STATION_NONE;
        for(int s=0;s<3;s++)if(!CaelumCraftingRules.NetworkHasStation(u.CraftingNetworkCapabilities,CaelumRestFurnitureData.Station(s)))
        {u.CraftingMissingStationType=CaelumRestFurnitureData.Station(s);break;}
    }
}
