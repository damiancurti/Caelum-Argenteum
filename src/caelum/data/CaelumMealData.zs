// #410: porciones y lotes aprobados; no renumera consumibles anteriores.
class CaelumMealData : Object
{
    const REVISION=1;
    const FIRST_CONSUMABLE=21;
    const COUNT=4;
    const BREAD=21;
    const ROAST_BEEF=22;
    const ROAST_FISH=23;
    const PUCHERO=24;
    const FIRST_RECIPE=205;
    const PORTION_KG=0.1;
    const BATCH_PORTIONS=10;
    const YEAST=98;
    const PROOF_SECONDS=7200.0;
    static clearscope bool IsMeal(int kind){return kind>=BREAD && kind<=PUCHERO;}
    static clearscope bool IsRecipe(int recipe){return recipe>=FIRST_RECIPE && recipe<FIRST_RECIPE+COUNT;}
    static clearscope int FoodKind(int kind)
    {return kind==BREAD?CaelumFoodData.BREAD:kind==ROAST_BEEF?CaelumFoodData.ROAST_BEEF:kind==ROAST_FISH?CaelumFoodData.ROAST_FISH:CaelumFoodData.PUCHERO;}
    static clearscope Name ItemClass(int kind)
    {return kind==BREAD?'CaelumBread':kind==ROAST_BEEF?'CaelumRoastBeef':kind==ROAST_FISH?'CaelumRoastFish':'CaelumPuchero';}
    static clearscope String NameKey(int kind)
    {return kind==BREAD?"CA_MEAL_BREAD":kind==ROAST_BEEF?"CA_MEAL_ROAST_BEEF":kind==ROAST_FISH?"CA_MEAL_ROAST_FISH":"CA_MEAL_PUCHERO";}
    static clearscope String Icon(int kind)
    {return "graphics/caelum/icons/meals/"..(kind==BREAD?"bread":kind==ROAST_BEEF?"roast_beef":kind==ROAST_FISH?"roast_fish":"puchero")..".png";}
    static clearscope class<CaelumDiningDisplay> TableDisplay(int kind)
    {return kind==BREAD?"CaelumDiningBread":kind==ROAST_BEEF?"CaelumDiningRoastBeef":kind==ROAST_FISH?"CaelumDiningRoastFish":"CaelumDiningPuchero";}
    static clearscope double CookSeconds(int kind)
    {return kind==BREAD?2700.0:kind==ROAST_BEEF?3600.0:kind==ROAST_FISH?1800.0:5400.0;}
    static clearscope double WaterLiters(int kind){return kind==BREAD?0.42:kind==PUCHERO?0.5:0;}
    static clearscope int CoalGrams(int kind){return kind==BREAD?772:kind==ROAST_BEEF?1029:kind==ROAST_FISH?515:1543;}
    static clearscope int InputMaterial(int kind,int slot)
    {
        if(slot==0)return kind==BREAD?CaelumKitchenData.FLOUR:kind==ROAST_FISH?CaelumKitchenData.RAW_FISH:CaelumKitchenData.RAW_BEEF;
        if(slot==1)return kind==PUCHERO?CaelumKitchenData.VEGETABLES:CaelumKitchenData.SALT;
        if(slot==2)return kind==BREAD?YEAST:kind==PUCHERO?CaelumKitchenData.SALT:CaelumConstants.MATERIAL_COAL;
        if(slot==3 && (kind==BREAD || kind==PUCHERO))return CaelumConstants.MATERIAL_COAL;
        return -1;
    }
    static clearscope int InputGrams(int kind,int slot)
    {
        if(slot==0)return kind==BREAD?700:kind==ROAST_BEEF?1250:kind==ROAST_FISH?1330:300;
        if(slot==1)return kind==BREAD?14:kind==PUCHERO?500:10;
        if(slot==2 && kind==BREAD)return 7;
        if(slot==2 && kind==PUCHERO)return 10;
        return InputMaterial(kind,slot)==CaelumConstants.MATERIAL_COAL?CoalGrams(kind):0;
    }
    static double UnitValue(int kind)
    {
        double cost=WaterLiters(kind)*CaelumConstants.ECONOMY_WATER_RATION_VALUE/CaelumConstants.WATER_RATION_LITERS;
        for(int slot=0;InputMaterial(kind,slot)>=0;slot++)
            cost+=InputGrams(kind,slot)*CaelumEconomyRules.GetMaterialUnitBaseValue(InputMaterial(kind,slot),1);
        return CaelumEconomyRules.ApplyMarkup(cost,CaelumConstants.ECONOMY_PROCESSING_MARKUP_PERCENT)/BATCH_PORTIONS;
    }
}
