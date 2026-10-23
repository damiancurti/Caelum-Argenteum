// Generado desde mate_vessels.json; geometría y tabla aprobadas (#472).
class CaelumMateData : Object
{
    const REVISION=1;
    const FIRST_RECIPE=198;
    const FIRST_CONSUMABLE=17;
    const COUNT=3;
    const DRY_GOURD=104;
    const HOT_MIN_C=60;
    const HOT_MAX_C=85;
    const HOT_USES=20;
    const RESOURCE_RATIO=0.1;
    const DRY_GOURD_VALUE=2;
    const DRY_GOURD_STOCK=1000;
    const MATE_STOCK=3;
    const BOOK_STOCK=10;
    static clearscope bool IsRecipe(int recipe){return recipe>=FIRST_RECIPE && recipe<FIRST_RECIPE+COUNT;}
    static clearscope bool IsConsumable(int kind){return kind>=FIRST_CONSUMABLE && kind<FIRST_CONSUMABLE+COUNT;}
    static clearscope double Capacity(int variant)
    {
        switch(variant)
        {
            case 0: return 0.1;
            case 1: return 0.25;
            case 2: return 0.5;
            default: return 0.1;
        }
    }
    static clearscope double WaterCapacity(int variant)
    {
        switch(variant)
        {
            case 0: return 0.06;
            case 1: return 0.15;
            case 2: return 0.3;
            default: return 0.06;
        }
    }
    static clearscope int YerbaGrams(int variant)
    {
        switch(variant)
        {
            case 0: return 20;
            case 1: return 50;
            case 2: return 100;
            default: return 20;
        }
    }
    static clearscope double Radius(int variant)
    {
        switch(variant)
        {
            case 0: return 0.0362783167859781;
            case 1: return 0.0492372510921348;
            case 2: return 0.06203504908994;
            default: return 0.0362783167859781;
        }
    }
    static clearscope double Wall(int variant)
    {
        switch(variant)
        {
            case 0: return 0.005;
            case 1: return 0.006;
            case 2: return 0.006;
            default: return 0.005;
        }
    }
    static clearscope double Conductivity(int variant)
    {
        switch(variant)
        {
            case 0: return 0.07;
            case 1: return 0.17;
            case 2: return 0.17;
            default: return 0.07;
        }
    }
    static clearscope double CoatingWall(int variant)
    {
        switch(variant)
        {
            case 0: return 0;
            case 1: return 0.0001;
            case 2: return 0.0001;
            default: return 0;
        }
    }
    static clearscope double CoatingConductivity(int variant)
    {
        switch(variant)
        {
            case 0: return 1;
            case 1: return 429;
            case 2: return 318;
            default: return 1;
        }
    }
    static clearscope double BodyHeatCapacity(int variant)
    {
        switch(variant)
        {
            case 0: return 8.799175670292;
            case 1: return 122.136034723377;
            case 2: return 189.1541193267;
            default: return 8.799175670292;
        }
    }
    static clearscope double EmptyMass(int variant)
    {
        switch(variant)
        {
            case 0: return 0.025866117113528;
            case 1: return 0.118414467444864;
            case 2: return 0.197481901644168;
            default: return 0.025866117113528;
        }
    }
    static clearscope String NameKey(int variant)
    {
        switch(variant)
        {
            case 0: return "CA_MATE_GOURD";
            case 1: return "CA_MATE_SILVER";
            case 2: return "CA_MATE_GOLD";
            default: return "CA_MATE_GOURD";
        }
    }
    static clearscope Name ItemClass(int variant)
    {
        switch(variant)
        {
            case 0: return 'CaelumMateGourd';
            case 1: return 'CaelumMateSilver';
            case 2: return 'CaelumMateGold';
            default: return 'CaelumMateGourd';
        }
    }
    static clearscope int PrimaryMaterial(int variant)
    {
        switch(variant)
        {
            case 0: return 104;
            case 1: return CaelumConstants.MATERIAL_WOOD;
            case 2: return CaelumConstants.MATERIAL_WOOD;
            default: return 104;
        }
    }
    static clearscope int PrimaryGrams(int variant)
    {
        switch(variant)
        {
            case 0: return 6;
            case 1: return 79;
            case 2: return 122;
            default: return 6;
        }
    }
    static clearscope int SecondaryMaterial(int variant)
    {
        switch(variant)
        {
            case 0: return CaelumConstants.MATERIAL_BRONZE_INGOT;
            case 1: return CaelumConstants.MATERIAL_SILVER_INGOT;
            case 2: return CaelumConstants.MATERIAL_GOLD_INGOT;
            default: return CaelumConstants.MATERIAL_BRONZE_INGOT;
        }
    }
    static clearscope int SecondaryGrams(int variant)
    {
        switch(variant)
        {
            case 0: return 20;
            case 1: return 21;
            case 2: return 57;
            default: return 20;
        }
    }
    static clearscope int BronzeGrams(int variant)
    {
        switch(variant)
        {
            case 0: return 0;
            case 1: return 20;
            case 2: return 20;
            default: return 0;
        }
    }
}
