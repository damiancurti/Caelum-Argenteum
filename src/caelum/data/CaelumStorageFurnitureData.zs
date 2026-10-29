// #410: abastecimiento aprobado; reutiliza las masas y materiales documentados.
class CaelumStorageFurnitureData : Object
{
    const REVISION=1;
    const FIRST_RECIPE=CaelumMealData.FIRST_RECIPE+CaelumMealData.COUNT;
    const FIRST_KEY=CaelumHygieneData.CLOTH_KEY+1;
    const COUNT=2;
    const SHOP_STOCK=3;
    const BOOK_STOCK=10;
    const CUPBOARD_DISPLAY=5;
    const CUPBOARD_WOOD_GRAMS=62333;
    const CUPBOARD_IRON_GRAMS=300;
    static clearscope bool IsRecipe(int recipe){return recipe>=FIRST_RECIPE && recipe<FIRST_RECIPE+COUNT;}
    static clearscope bool IsKey(int key){return key>=FIRST_KEY && key<FIRST_KEY+COUNT;}
    static clearscope bool IsItem(Inventory item){return item is 'CaelumStorageFurnitureItem';}
    static clearscope Name ItemClass(int variant){return variant==0?'CaelumWardrobeItem':'CaelumCupboardItem';}
    static clearscope Name BodyClass(int variant){return variant==0?'CaelumWardrobe':'CaelumPortableCupboard';}
    static clearscope String NameKey(int variant){return variant==0?"CA_FURNITURE_WARDROBE":"CA_KITCHEN_CUPBOARD";}
    static clearscope String Icon(int variant){return variant==0?"graphics/caelum/icons/furniture/wardrobe.png":"graphics/caelum/icons/kitchen_stations/cupboard.png";}
    static clearscope double Mass(int variant){return variant==0?CaelumWardrobeData.EMPTY_KG:CaelumKitchenFixtureData.CUPBOARD_KG;}
    static clearscope double Radius(int variant){return variant==0?CaelumWardrobeData.RADIUS:CaelumKitchenFixtureData.CUPBOARD_RADIUS;}
    static clearscope double Height(int variant){return variant==0?CaelumWardrobeData.HEIGHT:CaelumKitchenFixtureData.CUPBOARD_HEIGHT;}
    static clearscope int Grams(int variant,int slot)
    {return variant==0?(slot==0?CaelumWardrobeData.WOOD_GRAMS:CaelumWardrobeData.IRON_GRAMS):(slot==0?CUPBOARD_WOOD_GRAMS:CUPBOARD_IRON_GRAMS);}
}
