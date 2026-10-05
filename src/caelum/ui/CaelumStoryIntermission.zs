// Se conserva el registro estático para partidas anteriores. #103 añade una
// introducción desde el creador, sin nuevos datos guardados.
// #31 mantiene CA_MUS02 en MAP01; #16 conserva CA_MUS01 al finalizar el puerto.
class CaelumStoryIntermission : StaticEventHandler
{
    override void WorldLoaded(WorldEvent e)
    {
        if (e.IsSaveGame && consoleplayer >= 0)
            EventHandler.SendInterfaceEvent(consoleplayer, "ca_intro_discard_loaded");
    }

    override void InterfaceProcess(ConsoleEvent e)
    {
        if (e.Name != "ca_intro_discard_loaded") return;
        // La carga por consola no cierra menús como lo hace LoadMenu. Sólo
        // descartamos esta cadena si contenía una introducción pendiente.
        Menu current = Menu.GetCurrentMenu();
        while (current != null && CaelumIntroductionMenu(current) == null)
            current = current.mParentMenu;
        if (current == null) return;
        while (Menu.GetCurrentMenu() != null) Menu.GetCurrentMenu().Close();
        let draft = CVar.GetCVar("ca_newchar_ready", players[consoleplayer]);
        if (draft != null) draft.SetInt(0);
    }
}

class CaelumIntroductionMenu : ListMenu
{
    bool Started;
    bool Revealed;
    bool FullTextDrawn;
    int ElapsedTics;
    int VisibleCharacters;
    String FullText;
    Font TitleFont;
    Font TextFont;
    Font SmallTextFont;

    override void Init(Menu parent, ListMenuDescriptor desc)
    {
        Super.Init(parent, desc);
        DontDim = true;
        DontBlur = true;
        TitleFont = Font.GetFont("CaelumDisplay");
        TextFont = Font.GetFont("CaelumText");
        SmallTextFont = Font.GetFont("CaelumSmall");
        FullText = Body();
        // El autor pidió la antigua música de MAP01 para esta presentación.
        // StartGameDirect deja que MAPINFO elija CA_MUS02 al entrar al mapa.
        S_ChangeMusic(CaelumNarrativeArtwork.INTRO_MUSIC);
    }

    String BoundKeys(String command)
    {
        int first, second;
        [first, second] = Bindings.GetKeysForCommand(command);
        return first == 0 && second == 0
            ? CaelumNarrativeArtwork.L("CA_INTRO_UNBOUND")
            : KeyBindings.NameKeys(first, second);
    }

    String Body()
    {
        return CaelumNarrativeArtwork.L("CA_INTRO_WELCOME") .. "\n\n"
            .. String.Format(CaelumNarrativeArtwork.L("CA_INTRO_MOVEMENT"),
                BoundKeys("+forward"), BoundKeys("+back"), BoundKeys("+moveleft"),
                BoundKeys("+moveright"), BoundKeys("+jump"), BoundKeys("+speed"), BoundKeys("+use")) .. "\n"
            .. String.Format(CaelumNarrativeArtwork.L("CA_INTRO_TOOLS"),
                BoundKeys("+attack"), BoundKeys("+altattack"), BoundKeys("+reload"),
                BoundKeys("+zoom"), BoundKeys("ca_journal_toggle"), BoundKeys("ca_time_skip")) .. "\n\n"
            .. CaelumNarrativeArtwork.L("CA_INTRO_SURVIVAL") .. "\n\n"
            .. CaelumNarrativeArtwork.L("CA_INTRO_AWAKENING");
    }

    double PanelWidth()
    {
        return Min(920.0, CaelumNarrativeArtwork.CanvasWidth() - 64);
    }

    override void Ticker()
    {
        if (Revealed || FullTextDrawn) return;
        ElapsedTics++;
        VisibleCharacters = Max(0, (ElapsedTics - CaelumNarrativeArtwork.TEXT_DELAY_TICS)
            / CaelumNarrativeArtwork.TEXT_CHARACTER_TICS);
    }

    // El corte recorre puntos Unicode, sin partir tildes ni otros caracteres.
    String FirstCharacters(String value, int count)
    {
        int offset = 0, codepoint;
        for (int i = 0; i < count && offset < int(value.Length()); i++)
            [codepoint, offset] = value.GetNextCodePoint(offset);
        return value.Left(offset);
    }

    double TextScale()
    {
        // Busca la mayor letra legible que deja el texto completo en una página.
        double scale = 1.6;
        while (scale > 0.8)
        {
            let lines = TextFont.BreakLines(FullText, int((PanelWidth() - 44) / scale));
            bool fits = lines.Count() * (TextFont.GetHeight() + 4) * scale
                <= CaelumNarrativeArtwork.TEXT_BOTTOM - CaelumNarrativeArtwork.TEXT_TOP;
            lines.Destroy();
            if (fits) break;
            scale -= 0.05;
        }
        return scale;
    }

    override void Drawer()
    {
        CaelumNarrativeArtwork.DrawBackground();
        double width = PanelWidth();
        double left = (CaelumNarrativeArtwork.CanvasWidth() - width) / 2;
        CaelumNarrativeArtwork.Rect(left, 24, width, 552, 0x080D15, 0.80);
        CaelumNarrativeArtwork.Rect(left, 24, width, 1, 0xA8B6C8, 0.9);
        CaelumNarrativeArtwork.Text(TitleFont, Font.CR_GOLD, left + 22, 40,
            CaelumNarrativeArtwork.L("CA_INTRO_TITLE"));
        // Se divide el texto completo antes de revelarlo para que las palabras
        // no cambien de renglón mientras se escriben. El escalado sólo afecta UI.
        double scale = TextScale();
        let lines = TextFont.BreakLines(FullText, int((width - 44) / scale));
        int remaining = Revealed ? int.Max : VisibleCharacters;
        double lineHeight = (TextFont.GetHeight() + 4) * scale;
        double y = CaelumNarrativeArtwork.TEXT_TOP;
        for (int row = 0; row < lines.Count(); row++)
        {
            String line = lines.StringAt(row);
            if (remaining > 0)
                CaelumNarrativeArtwork.Text(TextFont, Font.CR_WHITE, left + 22, y,
                    FirstCharacters(line, remaining), scale);
            remaining -= line.CodePointCount() + 1;
            y += lineHeight;
        }
        FullTextDrawn = remaining >= 0;
        lines.Destroy();
        String prompt = CaelumNarrativeArtwork.L(FullTextDrawn ? "CA_INTRO_BEGIN" : "CA_INTRO_REVEAL");
        CaelumNarrativeArtwork.Text(SmallTextFont, Font.CR_GOLD,
            left + (width - SmallTextFont.StringWidth(prompt)) / 2, 552, prompt);
    }

    void Advance()
    {
        if (Started) return;
        if (!FullTextDrawn)
        {
            Revealed = true;
            return;
        }
        Started = true;
        // El borrador validado se consume en el mismo arranque nativo del
        // creador. Las cargas de guardado nunca pasan por esta introducción.
        Menu.StartGameDirect(true, false, "CaelumPlayer", 0, 0);
    }

    // Sin traducción de teclas, Enter/Esc/flechas son pulsaciones únicas y la
    // repetición del teclado no revela y cierra la página de un solo golpe.
    override bool TranslateKeyboardEvents() { return false; }

    override bool OnUIEvent(UIEvent ev)
    {
        if (ev.Type == UIEvent.Type_KeyDown || ev.Type == UIEvent.Type_LButtonDown) Advance();
        return true;
    }

    override bool OnInputEvent(InputEvent ev)
    {
        if (ev.Type == InputEvent.Type_KeyDown) Advance();
        return true;
    }

    override bool MenuEvent(int mkey, bool fromcontroller)
    {
        // A/B del mando no repiten; los ejes sí y no deben saltar la lectura.
        if (mkey == MKEY_Enter || mkey == MKEY_Back) Advance();
        return true;
    }
}
