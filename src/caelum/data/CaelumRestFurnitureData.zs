// #410: recetas derivadas de la construcción histórica ya documentada.
class CaelumRestFurnitureData : Object
{
    const REVISION=3;
    const FIRST_RECIPE=CaelumStorageFurnitureData.FIRST_RECIPE+CaelumStorageFurnitureData.COUNT;
    const FIRST_KEY=CaelumStorageFurnitureData.FIRST_KEY+CaelumStorageFurnitureData.COUNT;
    const FIRST_BASIC_VARIANT=2;
    const FIRST_SOFA_VARIANT=4;
    const COUNT=6;
    const SHOP_STOCK=CaelumStorageFurnitureData.SHOP_STOCK;
    const BOOK_STOCK=CaelumStorageFurnitureData.BOOK_STOCK;
    const PARKED_STAT=Thinker.STAT_FIRST_THINKING-2;
    static clearscope bool IsRecipe(int r){return r>=FIRST_RECIPE && r<FIRST_RECIPE+COUNT;}
    static clearscope bool IsKey(int k){return k>=FIRST_KEY && k<FIRST_KEY+COUNT;}
    static clearscope Name ItemClass(int v){if(v>=FIRST_SOFA_VARIANT)return v==FIRST_SOFA_VARIANT?'CaelumTwoSeatSofaItem':'CaelumThreeSeatSofaItem';return v==0?'CaelumLuxuryChairItem':v==1?'CaelumLuxuryBedItem':v==2?'CaelumBasicChairItem':'CaelumBasicBedItem';}
    static clearscope Name BodyClass(int v){if(v>=FIRST_SOFA_VARIANT)return v==FIRST_SOFA_VARIANT?'CaelumTwoSeatSofa':'CaelumThreeSeatSofa';return v==0?'CaelumLuxuryChair':v==1?'CaelumLuxuryBed':v==2?'CaelumRestChair':'CaelumRestBed';}
    static clearscope String NameKey(int v){if(v>=FIRST_SOFA_VARIANT)return v==FIRST_SOFA_VARIANT?"CA_SOFAS_TWO":"CA_SOFAS_THREE";return v==0?"CA_LUXURY_CHAIR":v==1?"CA_LUXURY_BED":v==2?"CA_BASIC_CHAIR":"CA_BASIC_BED";}
    static clearscope String Icon(int v){if(v>=FIRST_SOFA_VARIANT)return v==FIRST_SOFA_VARIANT?"sprites/caelum/rest_furniture/CSF2A0.png":"sprites/caelum/rest_furniture/CSF3A0.png";return v==0?"sprites/caelum/rest_furniture/CLICA0.png":v==1?"sprites/caelum/rest_furniture/CLIBA0.png":v==2?"sprites/caelum/rest_furniture/CBICA0.png":"sprites/caelum/rest_furniture/CBIBA0.png";}
    static clearscope double Mass(int v){if(v>=FIRST_SOFA_VARIANT)return CaelumSofaData.Weight(v-FIRST_SOFA_VARIANT);return v<FIRST_BASIC_VARIANT?CaelumLuxuryData.Weight(v):v==2?CaelumBasicRestData.CHAIR_MASS:CaelumBasicRestData.BED_MASS;}
    static clearscope double Radius(int v)
    {
        if(v>=FIRST_SOFA_VARIANT){int k=v-FIRST_SOFA_VARIANT;double w=CaelumSofaData.Width(k),d=CaelumSofaData.Depth(k);return Sqrt(w*w+d*d)/2;}
        if(v>=FIRST_BASIC_VARIANT)return v==2?CaelumBasicRestData.CHAIR_RADIUS:CaelumBasicRestData.BED_RADIUS;
        double w=CaelumLuxuryData.Width(v),d=CaelumLuxuryData.Depth(v);return Sqrt(w*w+d*d)/2;
    }
    static clearscope double Height(int v){if(v>=FIRST_SOFA_VARIANT)return CaelumSofaData.Height(v-FIRST_SOFA_VARIANT);return v<FIRST_BASIC_VARIANT?CaelumLuxuryData.Height(v):v==2?CaelumBasicRestData.CHAIR_HEIGHT:CaelumBasicRestData.BED_HEIGHT;}
    static clearscope int Material(int slot){return slot==0?CaelumConstants.MATERIAL_WOOD:slot==1?CaelumConstants.MATERIAL_IRON_INGOT:CaelumConstants.MATERIAL_FABRIC;}
    static clearscope int Tier(int slot){return slot==0?1:2;}
    static clearscope int Grams(int v,int slot)
    {
        if(v>=FIRST_SOFA_VARIANT){int k=v-FIRST_SOFA_VARIANT;return slot==0?CaelumSofaData.Wood(k):slot==1?CaelumSofaData.Iron(k):slot==2?CaelumSofaData.Cloth(k):0;}
        if(v>=FIRST_BASIC_VARIANT){int k=v-FIRST_BASIC_VARIANT;return slot==0?CaelumBasicRestData.Wood(k):slot==1?CaelumBasicRestData.Iron(k):slot==2?CaelumBasicRestData.Cloth(k):0;}
        return slot==0?CaelumLuxuryData.Wood(v):slot==1?CaelumLuxuryData.Iron(v):slot==2?CaelumLuxuryData.Cloth(v):0;
    }
    static clearscope bool NeedsStation(int v,int slot){return slot<2 || Grams(v,2)>0;}
    static clearscope int Station(int slot){return slot==0?CaelumConstants.CRAFTING_STATION_WORKBENCH:slot==1?CaelumConstants.CRAFTING_STATION_FINE_TOOLS_BENCH:CaelumConstants.CRAFTING_STATION_SEWING_MACHINE;}
}
