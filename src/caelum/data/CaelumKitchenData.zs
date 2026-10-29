// #410: ingredientes aprobados; cantidades nativas en gramos, sin porciones
// ficticias que obliguen a redondear la materia prima de una receta.
class CaelumKitchenData : Object
{
    const REVISION=1;
    const FLOUR=108;
    const RAW_BEEF=109;
    const RAW_FISH=110;
    const VEGETABLES=111;
    const SALT=112;
    const PORTION_GRAMS=100;
    static clearscope bool IsMaterial(int id){return id>=FLOUR && id<=SALT;}
    static clearscope bool Edible(int id){return id>=RAW_BEEF && id<=VEGETABLES;}
    static clearscope int FoodKind(int id)
    {
        if(id==FLOUR)return CaelumFoodData.FLOUR;
        if(id==RAW_BEEF)return CaelumFoodData.RAW_BEEF;
        if(id==RAW_FISH)return CaelumFoodData.RAW_FISH;
        if(id==VEGETABLES)return CaelumFoodData.VEGETABLES;
        return -1;
    }
    static clearscope String Slug(int id)
    {return id==FLOUR?"flour":id==RAW_BEEF?"beef":id==RAW_FISH?"fish":id==VEGETABLES?"vegetables":"salt";}
    static clearscope String NameKey(int id)
    {return id==FLOUR?"CA_KITCHEN_FLOUR":id==RAW_BEEF?"CA_KITCHEN_BEEF":id==RAW_FISH?"CA_KITCHEN_FISH":id==VEGETABLES?"CA_KITCHEN_VEGETABLES":"CA_KITCHEN_SALT";}
    static clearscope String Icon(int id)
    {return "graphics/caelum/icons/kitchen/"..Slug(id)..".png";}
    static clearscope double Price(int id)
    {return id==FLOUR?0.02:id==RAW_BEEF?0.08:id==RAW_FISH?0.06:id==VEGETABLES?0.03:0.01;}
    static clearscope int Stock(int id)
    {return id==SALT?1000:id==RAW_FISH?5000:10000;}
}
