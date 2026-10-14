// Datos de presentación; las categorías manuales nunca registran servicios.
class CaelumMapNoteData : Object
{
    const REVISION=1;
    const NOTE=0;
    const CREATE=1;
    const EDIT=2;
    const REMOVE=3;
    // DEM_ZSC_CMD serializa el tamaño del buffer en un entero de 16 bits.
    // Cuatro enteros, tres doubles y dos terminadores de cadena: 42 bytes.
    const NETWORK_BYTES=65535;
    const REQUEST_BYTES=42;
    static bool ValidCategory(int category)
    {return category==NOTE || CaelumPoiData.ValidCategory(category);}
    static String CategoryKey(int category)
    {return category==NOTE?"CA_NOTE_CATEGORY":CaelumPoiData.CategoryKey(category);}
    static String IconPath()
    {return "graphics/caelum/ui/journal/icons/ca_ui_nav_quests.png";}
    static bool FitsRequest(String mapId,String text)
    {return mapId.Length()+text.Length()+REQUEST_BYTES<=NETWORK_BYTES;}
}
