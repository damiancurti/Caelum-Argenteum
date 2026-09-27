// Acceso central a las ilustraciones aprobadas del Tarot. La colección no
// inventa nombres ni otorga cartas: solo resuelve rutas de arte verificadas.
class CaelumTarotArt : Object
{
    const FRONT_DIRECTORY = "graphics/caelum/tarot/";
    const BACK_PATH = "graphics/caelum/icons/ca_tarot_back.png";

    static String FrontPath(int card)
    {
        if (card == CaelumConstants.TAROT_THE_FOOL)
        {
            return FRONT_DIRECTORY .. "ca_tarot_fool.png";
        }
        return FRONT_DIRECTORY .. String.Format("ca_tarot_%02d.png", card);
    }

    static String FrontSprite(int card)
    {
        if (card == CaelumConstants.TAROT_CUPS_ACE) return "CACU";
        if (card == CaelumConstants.TAROT_WANDS_KNIGHT) return "CAWK";
        return "CFLF";
    }

    static int ConversationId(int card)
    {
        if (card == CaelumConstants.TAROT_CUPS_ACE) return CaelumConstants.ARCANA_CUPS_CONVERSATION_ID;
        if (card == CaelumConstants.TAROT_WANDS_KNIGHT) return CaelumConstants.ARCANA_WANDS_CONVERSATION_ID;
        return CaelumConstants.MAIN_M00_FOOL_CONVERSATION_ID;
    }

    static String BackPath()
    {
        return BACK_PATH;
    }

    static String NameKey(int card)
    {
        if (card == CaelumConstants.TAROT_THE_FOOL) return "CA_TAROT_FOOL_NAME";
        if (card == CaelumConstants.TAROT_CUPS_ACE) return "CA_MAZE_CUPS_ACE";
        if (card == CaelumConstants.TAROT_WANDS_KNIGHT) return "CA_TAROT_WANDS_KNIGHT_NAME";
        return "";
    }
}
