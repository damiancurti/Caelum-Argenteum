// #410: el horno consume masa ya leudada; el precio del pan conserva la receta
// original aprobada, sin aplicar dos veces el margen de elaboración.
class CaelumCookingData : Object
{
    const REVISION=1;
    const DOUGH=113;
    const DOUGH_GRAMS=1141;
    static play bool IsStation(Actor source)
    {
        let station=CaelumCraftingStation(source);
        if(station==null)return false;
        int kind=station.GetCraftingStationType();
        return kind>=CaelumConstants.CRAFTING_STATION_STOVE && kind<=CaelumConstants.CRAFTING_STATION_COUNTER;
    }
    static double DoughUnitValue()
    {
        double cost=CaelumMealData.WaterLiters(CaelumMealData.BREAD)
            *CaelumConstants.ECONOMY_WATER_RATION_VALUE/CaelumConstants.WATER_RATION_LITERS;
        for(int slot=0;slot<3;slot++)cost+=CaelumMealData.InputGrams(CaelumMealData.BREAD,slot)
            *CaelumEconomyRules.GetMaterialUnitBaseValue(CaelumMealData.InputMaterial(CaelumMealData.BREAD,slot),1);
        return CaelumEconomyRules.ApplyMarkup(cost,CaelumConstants.ECONOMY_PROCESSING_MARKUP_PERCENT)/DOUGH_GRAMS;
    }
    static clearscope int Meal(int recipe)
    {return CaelumMealData.IsRecipe(recipe)?CaelumMealData.FIRST_CONSUMABLE+recipe-CaelumMealData.FIRST_RECIPE:-1;}
    static clearscope int Station(int recipe)
    {return Meal(recipe)==CaelumMealData.BREAD?CaelumConstants.CRAFTING_STATION_OVEN:CaelumConstants.CRAFTING_STATION_STOVE;}
    static clearscope int InputMaterial(int recipe,int slot)
    {
        int meal=Meal(recipe);if(meal<0)return -1;
        if(meal==CaelumMealData.BREAD)return slot==0?DOUGH:slot==1?CaelumConstants.MATERIAL_COAL:-1;
        return CaelumMealData.InputMaterial(meal,slot);
    }
    static clearscope int InputGrams(int recipe,int slot)
    {
        int meal=Meal(recipe);if(meal<0)return 0;
        if(meal==CaelumMealData.BREAD)return slot==0?DOUGH_GRAMS:slot==1?CaelumMealData.CoalGrams(meal):0;
        return CaelumMealData.InputGrams(meal,slot);
    }
    static clearscope double WaterLiters(int recipe)
    {return Meal(recipe)==CaelumMealData.BREAD?0:CaelumMealData.WaterLiters(Meal(recipe));}
    static clearscope double Seconds(int recipe)
    {return CaelumMealData.CookSeconds(Meal(recipe));}
    static clearscope int MissingStation(int capabilities,int recipe)
    {int station=Station(recipe);return CaelumCraftingRules.NetworkHasStation(capabilities,station)?CaelumConstants.CRAFTING_STATION_NONE:station;}
}
