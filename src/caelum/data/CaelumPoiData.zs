// Identidades de categoría y presentación; no definen reglas de descubrimiento.
class CaelumPoiData : Object
{
    const REVISION = 2;
    const BED = 1;
    const STATION = 2;
    const MERCHANT = 3;
    const EXIT = 4;
    const TRANSPORT = 5;
    const ROOM = 6;
    const TOWER = 7;
    const GRATE = 8;
    const ACCESS_UNKNOWN = 0;
    const ACCESS_CLOSED = 1;
    const ACCESS_OPEN = 2;
    const ICON_SIZE = 12.0;

    static bool ValidCategory(int category) { return category>=BED && category<=GRATE; }
    static String CategoryKey(int category)
    {
        switch(category)
        {
        case BED: return "CA_POI_BED";
        case STATION: return "CA_POI_STATION";
        case MERCHANT: return "CA_POI_MERCHANT";
        case EXIT: return "CA_POI_EXIT";
        case TRANSPORT: return "CA_POI_TRANSPORT";
        case ROOM: return "CA_POI_ROOM";
        case TOWER: return "CA_POI_TOWER";
        case GRATE: return "CA_POI_GRATE";
        }
        return "";
    }
    static String IconPath(int category,int observedAccess=ACCESS_UNKNOWN)
    {
        // El icono sigue el hecho observado, nunca el estado remoto del acceso.
        if(category==GRATE || (category==EXIT && observedAccess!=ACCESS_UNKNOWN))
            return observedAccess==ACCESS_OPEN
                ?"graphics/caelum/ui/journal/icons/ca_ui_action_unlocked.png"
                :"graphics/caelum/ui/journal/icons/ca_ui_action_locked.png";
        switch(category)
        {
        case BED: return "graphics/caelum/ui/hud/icons/ca_hud_icon_sleep.png";
        case STATION: return "graphics/caelum/ui/journal/icons/ca_ui_nav_crafts.png";
        case MERCHANT: return "graphics/caelum/icons/currency/ca_coin_gold.png";
        case EXIT: return "graphics/caelum/ui/journal/icons/ca_ui_action_use.png";
        case TRANSPORT: return "graphics/caelum/ui/journal/icons/ca_ui_nav_world.png";
        case ROOM: return "graphics/caelum/ui/journal/icons/ca_ui_nav_reputation.png";
        case TOWER: return "graphics/caelum/ui/journal/icons/ca_ui_category_shields.png";
        case GRATE: return "graphics/caelum/ui/journal/icons/ca_ui_action_locked.png";
        }
        return "";
    }
}
