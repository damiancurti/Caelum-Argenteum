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

    static String BackPath()
    {
        return BACK_PATH;
    }

    static String NameKey(int card)
    {
        if (card == CaelumConstants.TAROT_THE_FOOL) return "CA_TAROT_FOOL_NAME";
        if (card == CaelumConstants.TAROT_CUPS_ACE) return "CA_MAZE_CUPS_ACE";
        return "";
    }
}
