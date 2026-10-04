// Datos de presentación #87: norte del mapa = +Y, este = +X.
// La aguja usa el ángulo renderizado de la cámara, nunca la velocidad.
class CaelumCompassLayout : Object
{
    const CANVAS_WIDTH = 1280.0;
    const CANVAS_HEIGHT = 720.0;
    const MARGIN = 8.0;
    const CENTER_X = 48.0;
    const CENTER_Y = 48.0;
    const ROSE_SIZE = 60.0;
    const NEEDLE_LENGTH = 21.0;
    const LABEL_RADIUS = 41.0;
    const HEADING_Y = 116.0;
    // Centro visible de las letras cardinales de CaelumMono respecto a su
    // celda de 9x14: (5.5, 6.5). Medicion conservada en SPEC.json.
    const FONT_INK_OFFSET_X = 1.0;
    const FONT_INK_OFFSET_Y = -0.5;
    const NOTIFY_LEFT = 112.0;
    const NOTIFY_RIGHT = 580.0;
    const NATIVE_NOTIFY_LINE = 18.0;
}

class CaelumCompass : Object ui
{
    static double Bearing(double angle)
    {
        double result = (90.0 - angle) % 360.0;
        return result < 0.0 ? result + 360.0 : result;
    }
    static int Sector(double angle)
    { return int(Floor((Bearing(angle) + 22.5) / 45.0)) % 8; }
    static String Direction(int sector)
    {
        static const String keys[] = { "CA_COMPASS_N", "CA_COMPASS_NE",
            "CA_COMPASS_E", "CA_COMPASS_SE", "CA_COMPASS_S", "CA_COMPASS_SW",
            "CA_COMPASS_W", "CA_COMPASS_NW" };
        return StringTable.Localize(keys[sector % 8], false);
    }
    static double Scale()
    {
        // Respetar los controles nativos de escala; limitar al espacio evita
        // recortes en ventanas pequeñas o escalas manuales muy grandes.
        double fit = Min(Screen.GetWidth() / CaelumCompassLayout.CANVAS_WIDTH,
            Screen.GetHeight() / CaelumCompassLayout.CANVAS_HEIGHT);
        let factor = CVar.GetCVar("hud_scalefactor");
        let manual = CVar.GetCVar("hud_scale");
        double chosen = manual != null && manual.GetInt() > 0 ? manual.GetInt() * 0.5 : fit;
        return Clamp(chosen * (factor == null ? 1.0 : factor.GetFloat()), fit * 0.5, fit * 2.0);
    }
    static bool Visible(CaelumPlayer user)
    {
        if (user == null || user.player == null || user.health <= 0 || menuactive != 0
            || gamestate != GS_LEVEL || user.CraftingMenuOpen
            || user.player.ConversationNPC != null) return false;
        let journal = CVar.GetCVar("ca_journal_open", players[consoleplayer]);
        return journal == null || !journal.GetBool();
    }
    static double NotificationLeft(CaelumPlayer user)
    {
        if (!Visible(user)) return 40.0;
        double fit = Min(Screen.GetWidth() / CaelumCompassLayout.CANVAS_WIDTH,
            Screen.GetHeight() / CaelumCompassLayout.CANVAS_HEIGHT);
        return CaelumCompassLayout.NOTIFY_LEFT * Scale() / Max(0.01, fit);
    }
    static void Text(Font font, double x, double y, String value, double scale, int color)
    {
        scale *= 2.0;
        // StringWidth incluye el kerning final, que no es parte del dibujo.
        double width = font.StringWidth(value) - font.GetDefaultKerning();
        Screen.DrawText(font, color,
            x - (width * 0.5 + CaelumCompassLayout.FONT_INK_OFFSET_X) * scale,
            y - (font.GetHeight() * 0.5 + CaelumCompassLayout.FONT_INK_OFFSET_Y) * scale, value,
            DTA_SCALEX, scale, DTA_SCALEY, scale, DTA_SHADOW, true);
    }
    static void Draw(RenderEvent event, CaelumPlayer user, Font font)
    {
        if (!Visible(user) || font == null) return;
        double scale = Scale();
        double x = (CaelumCompassLayout.MARGIN + CaelumCompassLayout.CENTER_X) * scale;
        double top = CaelumCompassLayout.MARGIN;
        // Reservar las filas de avisos nativos si están habilitadas. El buzón
        // propio reserva una columna independiente y no pierde sus 20 entradas.
        let notifyTime = CVar.GetCVar("con_notifytime");
        let notifyLines = CVar.GetCVar("con_notifylines");
        if (notifyTime != null && notifyTime.GetFloat() > 0 && notifyLines != null)
        {
            double fit = Min(Screen.GetWidth() / CaelumCompassLayout.CANVAS_WIDTH,
                Screen.GetHeight() / CaelumCompassLayout.CANVAS_HEIGHT);
            // Reducir la brujula no reduce las letras de la consola nativa.
            top += Clamp(notifyLines.GetInt(), 0, 4) * CaelumCompassLayout.NATIVE_NOTIFY_LINE
                * Max(1.0, fit / scale);
        }
        double y = (top + CaelumCompassLayout.CENTER_Y) * scale;
        let rose = TexMan.CheckForTexture("graphics/caelum/ui/ca_compass_rose.png", TexMan.Type_Any);
        double size = CaelumCompassLayout.ROSE_SIZE * scale;
        Screen.DrawTexture(rose, true, x - size * 0.5, y - size * 0.5,
            DTA_DESTWIDTHF, size, DTA_DESTHEIGHTF, size);
        for (int i = 0; i < 4; i++)
            Text(font, x + Sin(i * 90.0) * CaelumCompassLayout.LABEL_RADIUS * scale,
                y - Cos(i * 90.0) * CaelumCompassLayout.LABEL_RADIUS * scale,
                Direction(i * 2), scale, Font.CR_GRAY);
        double bearing = Bearing(event.ViewAngle);
        double dx = Sin(bearing), dy = -Cos(bearing);
        double tipX = x + dx * CaelumCompassLayout.NEEDLE_LENGTH * scale;
        double tipY = y + dy * CaelumCompassLayout.NEEDLE_LENGTH * scale;
        Screen.DrawThickLine(x - dx * 10 * scale, y - dy * 10 * scale,
            tipX, tipY, Max(1.0, 2.0 * scale), 0xEAC76B);
        Screen.DrawThickLine(tipX, tipY, tipX - (dx * 7 + dy * 4) * scale,
            tipY - (dy * 7 - dx * 4) * scale, Max(1.0, scale), 0xEAC76B);
        Screen.DrawThickLine(tipX, tipY, tipX - (dx * 7 - dy * 4) * scale,
            tipY - (dy * 7 + dx * 4) * scale, Max(1.0, scale), 0xEAC76B);
        Text(font, x, (top + CaelumCompassLayout.HEADING_Y) * scale,
            String.Format("%s %03d", Direction(Sector(event.ViewAngle)),
                int(Floor(bearing + 0.5)) % 360), scale, Font.CR_GOLD);
    }
}
