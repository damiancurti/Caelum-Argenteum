// #410: datos aprobados por el autor; índices internos, no IDs de inventario.
class CaelumFoodData : Object
{
    const REVISION = 1;
    const MAX_CONTAMINATION = 100.0;
    const ILLNESS_THRESHOLD = 50.0;
    const DAMAGE_MAX_LIFE_PER_DEGREE_SECOND = 0.001;
    const REFERENCE_BODY_KG = 80.0;
    const REFERENCE_PORTION_G = 100.0;
    const REFERENCE_KCAL = 240.0;
    const HUNGER_MASS_FACTOR = 800.0;
    const REFERENCE_CELSIUS = 20.0;
    const DOUBLING_CELSIUS = 10.0;
    const HUMIDITY_BASE_FACTOR = 0.5;
    const FREEZE_CELSIUS = -18.0;
    const HOT_HOLD_CELSIUS = 60.0;
    const RAW_FISH = 0;
    const RAW_BEEF = 1;
    const ROAST_FISH = 2;
    const ROAST_BEEF = 3;
    const PUCHERO = 4;
    const BREAD = 5;
    const VEGETABLES = 6;
    const RATION = 7;
    const FLOUR = 8;
    const KIND_COUNT = 9;

    static clearscope double FreshHours(int kind)
    {
        switch(kind)
        {
            case RAW_FISH: return 6;
            case RAW_BEEF: case ROAST_FISH: return 12;
            case ROAST_BEEF: case PUCHERO: return 24;
            case BREAD: case VEGETABLES: return 72;
            case RATION: return 168;
            case FLOUR: return 720;
        }
        return 0;
    }
    static clearscope double PortionKcal(int kind)
    {
        switch(kind)
        {
            case RAW_BEEF: return 170;
            case RAW_FISH: return 81;
            case VEGETABLES: return 60;
            case BREAD: return 268;
            case ROAST_BEEF: return 230;
            case ROAST_FISH: return 110;
            case PUCHERO: return 80;
        }
        return 0;
    }
}
