// #410: recetas derivadas de la construcción histórica ya documentada.
class CaelumRestFurnitureData : Object
{
    const REVISION=1;
    const FIRST_RECIPE=CaelumStorageFurnitureData.FIRST_RECIPE+CaelumStorageFurnitureData.COUNT;
    const FIRST_KEY=CaelumStorageFurnitureData.FIRST_KEY+CaelumStorageFurnitureData.COUNT;
    const COUNT=2;
    const SHOP_STOCK=CaelumStorageFurnitureData.SHOP_STOCK;
    const BOOK_STOCK=CaelumStorageFurnitureData.BOOK_STOCK;
    const PARKED_STAT=Thinker.STAT_FIRST_THINKING-2;
    static clearscope bool IsRecipe(int r){return r>=FIRST_RECIPE && r<FIRST_RECIPE+COUNT;}
    static clearscope bool IsKey(int k){return k>=FIRST_KEY && k<FIRST_KEY+COUNT;}
    static clearscope Name ItemClass(int v){return v==0?'CaelumLuxuryChairItem':'CaelumLuxuryBedItem';}
    static clearscope Name BodyClass(int v){return v==0?'CaelumLuxuryChair':'CaelumLuxuryBed';}
    static clearscope String NameKey(int v){return v==0?"CA_LUXURY_CHAIR":"CA_LUXURY_BED";}
    static clearscope String Icon(int v){return v==0?"sprites/caelum/rest_furniture/CLICA0.png":"sprites/caelum/rest_furniture/CLIBA0.png";}
    static clearscope double Mass(int v){return CaelumLuxuryData.Weight(v);}
    static clearscope double Radius(int v){double w=CaelumLuxuryData.Width(v),d=CaelumLuxuryData.Depth(v);return Sqrt(w*w+d*d)/2;}
    static clearscope double Height(int v){return CaelumLuxuryData.Height(v);}
    static clearscope int Material(int slot){return slot==0?CaelumConstants.MATERIAL_WOOD:slot==1?CaelumConstants.MATERIAL_IRON_INGOT:CaelumConstants.MATERIAL_FABRIC;}
    static clearscope int Tier(int slot){return slot==0?1:2;}
    static clearscope int Grams(int v,int slot){return slot==0?CaelumLuxuryData.Wood(v):slot==1?CaelumLuxuryData.Iron(v):slot==2?CaelumLuxuryData.Cloth(v):0;}
    static clearscope int Station(int slot){return slot==0?CaelumConstants.CRAFTING_STATION_WORKBENCH:slot==1?CaelumConstants.CRAFTING_STATION_FINE_TOOLS_BENCH:CaelumConstants.CRAFTING_STATION_SEWING_MACHINE;}
}
