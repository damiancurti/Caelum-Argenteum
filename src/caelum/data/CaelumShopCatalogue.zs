// Generado desde SHOP_CATALOGUE.json, CITY.json y NATIVE_DOORS.json.
class CaelumShopCatalogue : Object
{
    const REVISION=1;
    const LIBRARY=6;
    const CLOTHING=7;
    const BOOK_STOCK=10;
    const RESTOCK_REVISION=1;
    const RESTOCK_INCLUDE_COMPONENTS=1;
    static int Category(int identity)
    {
        if(identity==34)return 6;
        if(identity==35)return 7;
        return identity%CaelumCityData.SHOP_CATEGORIES;
    }
    static int SignCategory(vector3 position,int original)
    {
        if(position.X==-2428 && position.Y==-1792)return 6;
        if(position.X==-892 && position.Y==-1792)return 7;
        return original;
    }
}
