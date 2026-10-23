// El objeto final idéntico tiene un único precio: la variante autorizada más barata.
class CaelumChemistryEconomy : Object
{
    static double LegacySealedSetValue(int ammunition)
    {return CaelumConstants.CRAFTING_CARTRIDGE_BATCH*CaelumConstants.CARTRIDGE_KIT_VALUE_RATIO
        *CaelumEconomyRules.LegacyAmmunitionUnitBaseValue(ammunition);}
    static double RecipeUnitValue(int recipe)
    {
        double input=CaelumChemistryData.WaterLiters(recipe)
            *CaelumConstants.ECONOMY_WATER_RATION_VALUE/CaelumConstants.WATER_RATION_LITERS;
        for(int slot=0;CaelumChemistryData.InputMaterial(recipe,slot)>=0;slot++)
            input+=CaelumChemistryData.InputUnits(recipe,slot)
                *CaelumEconomyRules.GetMaterialUnitBaseValue(CaelumChemistryData.InputMaterial(recipe,slot),1);
        return CaelumEconomyRules.ApplyMarkup(input,CaelumConstants.ECONOMY_PROCESSING_MARKUP_PERCENT)
            /Max(1,CaelumChemistryData.OutputUnits(recipe));
    }
    static double ConsumableValue(int kind)
    {
        double result=-1;
        for(int recipe=CaelumChemistryData.FIRST_RECIPE;
            recipe<CaelumChemistryData.FIRST_RECIPE+CaelumChemistryData.RECIPE_COUNT;recipe++)
            if(CaelumChemistryData.OutputConsumable(recipe)==kind)
            {double value=RecipeUnitValue(recipe);result=result<0?value:Min(result,value);}
        return result;
    }
    static int ConsumableRecipe(Name itemClass)
    {
        int result=-1;double cheapest=0;
        for(int recipe=CaelumChemistryData.FIRST_RECIPE;
            recipe<CaelumChemistryData.FIRST_RECIPE+CaelumChemistryData.RECIPE_COUNT;recipe++)
        {
            int kind=CaelumChemistryData.OutputConsumable(recipe);
            if(kind<0 || CaelumPotionRules.ItemClass(kind)!=itemClass)continue;
            double value=RecipeUnitValue(recipe);
            if(result<0 || value<cheapest){result=recipe;cheapest=value;}
        }
        return result;
    }
}
