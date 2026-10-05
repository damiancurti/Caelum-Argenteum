// #103: una sola ilustración original para la introducción y la despedida.
// Las medidas de composición no modifican los píxeles ni recortan la imagen.
class CaelumNarrativeArtwork : Object
{
    const IMAGE = "graphics/caelum/narrative/intermission_exit.png";
    const INTRO_MUSIC = "CA_MUS01";
    const CANVAS_HEIGHT = 600;
    const TEXT_TOP = 76;
    const TEXT_BOTTOM = 534;
    // Valores predeterminados de FIntermissionActionTextscreen en GZDoom 4.14.2.
    const TEXT_DELAY_TICS = 10;
    const TEXT_CHARACTER_TICS = 2;

    static ui String L(String key) { return StringTable.Localize(key, false); }

    static ui double CanvasWidth()
    {
        return double(Screen.GetWidth()) * CANVAS_HEIGHT / Screen.GetHeight();
    }

    static ui void DrawBackground()
    {
        double width = Screen.GetWidth(), height = Screen.GetHeight();
        Screen.Dim(0, 1, 0, 0, int(width), int(height));
        let texture = TexMan.CheckForTexture(IMAGE, TexMan.Type_MiscPatch);
        if (!texture.IsValid()) return;
        let size = TexMan.GetScaledSize(texture);
        double scale = Min(width / size.X, height / size.Y);
        Screen.DrawTexture(texture, false, (width - size.X * scale) / 2,
            (height - size.Y * scale) / 2,
            DTA_DestWidthF, size.X * scale, DTA_DestHeightF, size.Y * scale);
    }

    static ui void Rect(double x, double y, double width, double height,
        Color color, double opacity)
    {
        double scale = double(Screen.GetHeight()) / CANVAS_HEIGHT;
        Screen.Dim(color, opacity, int(x * scale), int(y * scale),
            int(width * scale), int(height * scale));
    }

    static ui void Text(Font font, int color, double x, double y, String value, double scale = 1)
    {
        Screen.DrawText(font, color, x, y, value,
            DTA_VirtualWidthF, CanvasWidth(), DTA_VirtualHeightF, double(CANVAS_HEIGHT),
            DTA_KeepRatio, true, DTA_Shadow, true, DTA_Localize, false,
            DTA_ScaleX, scale, DTA_ScaleY, scale);
    }

    static ui double Paragraph(Font font, int color, double x, double y,
        double width, String value)
    {
        let lines = font.BreakLines(value, int(width));
        for (int i = 0; i < lines.Count(); i++)
        {
            Text(font, color, x, y, lines.StringAt(i));
            y += font.GetHeight() + 4;
        }
        lines.Destroy();
        return y;
    }
}

// Sólo reconoce el texto propio de Salir. Las demás confirmaciones mantienen
// su implementación nativa y su callback; tampoco se sustituye CreditPage.
class CaelumNarrativeMessageBox : MessageBoxMenu
{
    bool IsCaelumExit;
    bool Farewell;
    bool FarewellDrawn;

    override void Init(Menu parent, String message, int messagemode,
        bool playsound, Name cmd, voidptr native_handler)
    {
        Super.Init(parent, message, messagemode, playsound, cmd, native_handler);
        IsCaelumExit = messagemode == 0 && native_handler != null
            && message == CaelumNarrativeArtwork.L("CA_EXIT_CONFIRM");
        if (IsCaelumExit) { DontDim = true; DontBlur = true; }
    }

    override void Drawer()
    {
        if (!IsCaelumExit) { Super.Drawer(); return; }
        CaelumNarrativeArtwork.DrawBackground();
        if (!Farewell)
        {
            // Conserva las opciones, teclas y coordenadas de la pregunta nativa.
            Screen.Dim(0x080D15, 0.65, 0, Screen.GetHeight() / 3,
                Screen.GetWidth(), Screen.GetHeight() / 3);
            Super.Drawer();
            return;
        }
        let font = Font.GetFont("CaelumSmall");
        String prompt = StringTable.Localize("TXT_QUITENDOOM", false);
        double width = CaelumNarrativeArtwork.CanvasWidth();
        CaelumNarrativeArtwork.Rect(0, 552, width, 48, 0x080D15, 0.86);
        CaelumNarrativeArtwork.Text(font, Font.CR_GOLD,
            (width - font.StringWidth(prompt)) / 2, 569, prompt);
        FarewellDrawn = true;
    }

    override void HandleResult(bool result)
    {
        if (IsCaelumExit && result && !Farewell)
        {
            Farewell = true;
            FarewellDrawn = false;
            return;
        }
        Super.HandleResult(result);
    }

    void FinishExit()
    {
        // El motor conserva QuitSound, su espera y el cierre normal. ENDOOM
        // queda vacío en GameInfo para no mostrar después la placa de Doom II.
        if (FarewellDrawn) Super.HandleResult(true);
    }

    override bool OnUIEvent(UIEvent ev)
    {
        if (!Farewell) return Super.OnUIEvent(ev);
        if (ev.Type == UIEvent.Type_KeyDown || ev.Type == UIEvent.Type_LButtonDown) FinishExit();
        return true;
    }

    override bool OnInputEvent(InputEvent ev)
    {
        if (!Farewell) return Super.OnInputEvent(ev);
        if (ev.Type == InputEvent.Type_KeyDown) FinishExit();
        return true;
    }

    override bool MenuEvent(int mkey, bool fromcontroller)
    {
        if (!Farewell) return Super.MenuEvent(mkey, fromcontroller);
        FinishExit();
        return true;
    }

    override bool MouseEvent(int type, int x, int y)
    {
        if (!Farewell) return Super.MouseEvent(type, x, y);
        if (type == MOUSE_Click) FinishExit();
        return true;
    }
}
