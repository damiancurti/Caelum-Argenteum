// Identidades de categoría y presentación; no definen reglas de descubrimiento.
class CaelumPoiData : Object
{
    const REVISION = 1;
    const BED = 1;
    const STATION = 2;
    const MERCHANT = 3;
    const EXIT = 4;
    const TRANSPORT = 5;
    const ICON_SIZE = 12.0;

    static bool ValidCategory(int category) { return category>=BED && category<=TRANSPORT; }
    static String CategoryKey(int category)
    {
        switch(category)
        {
        case BED: return "CA_POI_BED";
        case STATION: return "CA_POI_STATION";
        case MERCHANT: return "CA_POI_MERCHANT";
        case EXIT: return "CA_POI_EXIT";
        case TRANSPORT: return "CA_POI_TRANSPORT";
        }
        return "";
    }
    static String IconPath(int category)
    {
        switch(category)
        {
        case BED: return "graphics/caelum/ui/hud/icons/ca_hud_icon_sleep.png";
        case STATION: return "graphics/caelum/ui/journal/icons/ca_ui_nav_crafts.png";
        case MERCHANT: return "graphics/caelum/icons/currency/ca_coin_gold.png";
        case EXIT: return "graphics/caelum/ui/journal/icons/ca_ui_action_use.png";
        case TRANSPORT: return "graphics/caelum/ui/journal/icons/ca_ui_nav_world.png";
        }
        return "";
    }
}
