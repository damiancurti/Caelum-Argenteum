// #411: valores aprobados el 24-10-2026; no son constantes de ajuste ocultas.
class CaelumCampData : Object
{
    const REVISION=1;
    const CATALOGUE_REVISION=2;
    const FIRST_RECIPE=201;
    const COUNT=2;
    const TENT_KEY=12;
    const POT_CONSUMABLE=20;
    const TENT_KG=18.8;
    const TENT_WIDTH_M=4.0;
    const TENT_LENGTH_M=3.0;
    const TENT_GEOMETRY_REVISION=2;
    const TENT_LEGACY_WIDTH_M=2.0;
    const TENT_LEGACY_LENGTH_M=2.0;
    const TENT_COLLISION_CELL_M=0.25;
    const TENT_HEIGHT_M=1.8;
    const TENT_WIND_FACTOR=0.1;
    const SETUP_SECONDS=600.0;
    const PACK_SECONDS=300.0;
    const IGNITE_SECONDS=60.0;
    const DISMANTLE_SECONDS=60.0;
    const FIRE_CAPACITY_G=10000;
    const POT_KG=5.5;
    const POT_LITERS=20.0;
    const POT_DIAMETER_M=0.36;
    const POT_WALL_M=0.002;
    const IRON_DENSITY=7870.0;
    const IRON_CP=450.0;
    const IRON_K=80.0;
    const FIRE_WATTS=8000.0;
    const USEFUL_WATTS=2000.0;
    const FIRE_EFFICIENCY=0.25;
    const WOOD_J_KG=15000000.0;
    const FIRE_DIAMETER_M=0.60;
    const FIRE_HEIGHT_M=0.50;
    const SHOP_STOCK=3;
    const BOOK_STOCK=10;
    static clearscope bool IsRecipe(int recipe){return recipe>=FIRST_RECIPE && recipe<FIRST_RECIPE+COUNT;}
    static clearscope bool IsItem(Inventory item){return item is 'CaelumCampTent' || item is 'CaelumCampPot';}
    static clearscope Name ItemClass(int variant){return variant==0?'CaelumCampTent':'CaelumCampPot';}
    static clearscope String NameKey(int variant){return variant==0?"CA_CAMP_TENT":"CA_CAMP_POT";}
    static clearscope String Icon(int variant){return variant==0?"graphics/caelum/icons/camp/tent.png":"graphics/caelum/icons/camp/iron_pot.png";}
    static clearscope double Mass(int variant){return variant==0?TENT_KG:POT_KG;}
    static clearscope int Material(int variant,int slot)
    {
        if(variant==1)return slot==0?CaelumConstants.MATERIAL_IRON_INGOT:-1;
        switch(slot)
        {
            case 0:return CaelumConstants.MATERIAL_FABRIC;
            case 1:return CaelumConstants.MATERIAL_WOOD;
            case 2:return CaelumConstants.MATERIAL_IRON_INGOT;
            case 3:return CaelumConstants.MATERIAL_ROPE;
        }
        return -1;
    }
    static clearscope int MaterialTier(int variant,int slot)
    {return (variant==1 && slot==0) || (variant==0 && (slot==0 || slot==2))?2:1;}
    static clearscope int Grams(int variant,int slot)
    {
        if(variant==1)return slot==0?5500:0;
        switch(slot){case 0:return 13500;case 1:return 4100;case 2:return 600;case 3:return 600;}
        return 0;
    }
    static clearscope double PotDepth()
    {double r=POT_DIAMETER_M/2;return POT_LITERS/1000/(CaelumWaterThermalData.PI*r*r);}
}
