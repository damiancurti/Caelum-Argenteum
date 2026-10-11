// Creador de personaje previo a la partida. Es un menú real de GZDoom: no
// necesita que MAP01 exista ni que CaelumPlayer haya nacido para editar el
// borrador. La confirmación copia datos validados a CVars user y arranca el
// único episodio/dificultad tras la introducción manual de #103.
class CaelumCharacterCreationMenu : ListMenu
{
    CaelumMenuPointer Pointer;
    int Page;
    int Race;
    int FirstClass;
    int SecondClass;
    int Sex;
    int HeightChoice;
    int Personality[4];
    int LayerBonus[4];
    int AttributeBonus[12];
    int SelectedLayer;
    int SelectedAttribute;
    Font TitleFont;
    Font TextFont;
    Font SmallTextFont;
    bool Confirmed;

    override void Init(Menu parent, ListMenuDescriptor desc)
    {
        Super.Init(parent, desc);
        Pointer=new("CaelumMenuPointer");
        Page = CaelumConstants.CREATION_PAGE_RACE;
        Race = CaelumConstants.RACE_HUMAN;
        FirstClass = CaelumConstants.CLASS_WARRIOR;
        SecondClass = CaelumConstants.CLASS_MAGE;
        Sex = CaelumConstants.SEX_MALE;
        HeightChoice = CaelumConstants.HEIGHT_NORMAL;
        for(int i=0;i<4;i++)Personality[i]=1;
        SelectedLayer = 0;
        SelectedAttribute = 0;
        ResetAllocations();
        LoadSessionDraft();
        TitleFont = Font.GetFont("CaelumDisplay");
        TextFont = Font.GetFont("CaelumText");
        SmallTextFont = Font.GetFont("CaelumSmall");
        DontDim = true;
        DontBlur = true;
        MenuSound("caelum/ui/menu_open");
    }

    void LoadSessionDraft()
    {
        let settings = CaelumCharacterSettings(StaticEventHandler.Find("CaelumCharacterSettings"));
        if (settings == null || settings.Draft == null) return;
        let draft = settings.Draft;
        Page = draft.Page;
        Race = draft.Race;
        FirstClass = draft.FirstClass;
        SecondClass = draft.SecondClass;
        Sex = draft.Sex;
        HeightChoice = draft.HeightChoice;
        for(int i=0;i<4;i++)Personality[i]=draft.Personality[i];
        SelectedLayer = draft.SelectedLayer;
        SelectedAttribute = draft.SelectedAttribute;
        for (int i = 0; i < 4; i++) LayerBonus[i] = draft.LayerBonus[i];
        for (int i = 0; i < 12; i++) AttributeBonus[i] = draft.AttributeBonus[i];
    }

    void StoreSessionDraft()
    {
        let settings = CaelumCharacterSettings(StaticEventHandler.Find("CaelumCharacterSettings"));
        if (settings == null) return;
        if (settings.Draft == null) settings.Draft = new("CaelumCreationDraft");
        let draft = settings.Draft;
        draft.Page = Page;
        draft.Race = Race;
        draft.FirstClass = FirstClass;
        draft.SecondClass = SecondClass;
        draft.Sex = Sex;
        draft.HeightChoice = HeightChoice;
        for(int i=0;i<4;i++)draft.Personality[i]=Personality[i];
        draft.SelectedLayer = SelectedLayer;
        draft.SelectedAttribute = SelectedAttribute;
        for (int i = 0; i < 4; i++) draft.LayerBonus[i] = LayerBonus[i];
        for (int i = 0; i < 12; i++) draft.AttributeBonus[i] = AttributeBonus[i];
    }

    override void OnDestroy()
    {
        if (!Confirmed) StoreSessionDraft();
        Super.OnDestroy();
    }

    void ResetAllocations()
    {
        let profile = new("CaelumCharacterProfile");
        profile.Race = Race; profile.FirstClass = FirstClass; profile.SecondClass = SecondClass;
        let allocation = new("CaelumCharacterAllocation");
        allocation.Recommend(profile);
        for (int i = 0; i < 4; i++) LayerBonus[i] = allocation.LayerBonus[i];
        for (int i = 0; i < 12; i++) AttributeBonus[i] = allocation.AttributeBonus[i];
    }

    int Wrap(int value, int count)
    {
        value %= count;
        if (value < 0) { value += count; }
        return value;
    }

    int DistributionValue(int pattern, int layer)
    { return CaelumCharacterProfile.DistributionFor(pattern, layer); }

    int RaceLayerValue(int layer)
    {
        if (Race == CaelumConstants.RACE_BEAST_MAN)
            return DistributionValue(0, layer);
        if (Race == CaelumConstants.RACE_CAELITH)
            return DistributionValue(1, layer);
        if (Race == CaelumConstants.RACE_HUMAN)
            return DistributionValue(2, layer);
        return DistributionValue(3, layer);
    }

    int CombinedLayerValue(int layer)
    {
        return RaceLayerValue(layer)
            + DistributionValue(FirstClass, layer)
            + DistributionValue(SecondClass, layer);
    }

    int FinalLayerValue(int layer)
    {
        return CombinedLayerValue(layer) + LayerBonus[layer];
    }

    int RemainingLayerPoints()
    {
        int spent = 0;
        for (int i = 0; i < 4; i++) { spent += LayerBonus[i]; }
        return CaelumConstants.FREE_LAYER_POINTS - spent;
    }

    int RemainingAttributePoints()
    {
        int spent = 0;
        for (int i = 0; i < 12; i++) { spent += AttributeBonus[i]; }
        return CaelumConstants.INDIVIDUAL_ATTRIBUTE_POINTS - spent;
    }

    int MaximumAttributeBonus(int attribute)
    {
        return Min(
            CaelumConstants.MAX_INDIVIDUAL_BONUS,
            FinalLayerValue(attribute / 3)
        );
    }

    bool IsPersonalityPage(){return Page>=CaelumPersonalityRules.FIRST_PAGE && Page<=CaelumPersonalityRules.LAST_PAGE;}

    void ChangeChoice(int direction)
    {
        if(IsPersonalityPage())
        {int layer=Page-CaelumPersonalityRules.FIRST_PAGE;Personality[layer]=Wrap(Personality[layer]+direction,3);return;}
        if (Page == CaelumConstants.CREATION_PAGE_RACE)
        {
            Race = Wrap(Race + direction, 4);
            ResetAllocations();
        }
        else if (Page == CaelumConstants.CREATION_PAGE_FIRST_CLASS)
        {
            FirstClass = Wrap(FirstClass + direction, 4);
            ResetAllocations();
        }
        else if (Page == CaelumConstants.CREATION_PAGE_SECOND_CLASS)
        {
            SecondClass = Wrap(SecondClass + direction, 4);
            ResetAllocations();
        }
        else if (Page == CaelumConstants.CREATION_PAGE_SEX)
        {
            Sex = Wrap(Sex + direction, 2);
        }
        else if (Page == CaelumConstants.CREATION_PAGE_HEIGHT)
        {
            HeightChoice = Wrap(HeightChoice + direction, 3);
        }
    }

    void ChangeSelectedPoint(int direction)
    {
        if (Page == CaelumConstants.CREATION_PAGE_LAYERS)
        {
            if (direction < 0 && LayerBonus[SelectedLayer] > 0)
            {
                LayerBonus[SelectedLayer]--;
                for (int a = SelectedLayer * 3; a < SelectedLayer * 3 + 3; a++)
                    AttributeBonus[a] = Min(AttributeBonus[a], MaximumAttributeBonus(a));
            }
            else if (direction > 0 && RemainingLayerPoints() > 0
                && FinalLayerValue(SelectedLayer)
                    < CaelumConstants.MAX_LAYER_BASE)
            {
                LayerBonus[SelectedLayer]++;
            }
        }
        else if (Page == CaelumConstants.CREATION_PAGE_ATTRIBUTES)
        {
            if (direction < 0 && AttributeBonus[SelectedAttribute] > 0)
            {
                AttributeBonus[SelectedAttribute]--;
            }
            else if (direction > 0 && RemainingAttributePoints() > 0
                && AttributeBonus[SelectedAttribute]
                    < MaximumAttributeBonus(SelectedAttribute))
            {
                AttributeBonus[SelectedAttribute]++;
            }
        }
    }

    String RaceKey(int value = -1)
    {
        if (value < 0) value = Race;
        if (value == CaelumConstants.RACE_BEAST_MAN) return "CA_RACE_BEAST_MAN";
        if (value == CaelumConstants.RACE_CAELITH) return "CA_RACE_CAELITH";
        if (value == CaelumConstants.RACE_HUMAN) return "CA_RACE_HUMAN";
        return "CA_RACE_GOBLIN";
    }

    String ClassKey(int value)
    {
        if (value == CaelumConstants.CLASS_WARRIOR) return "CA_CLASS_WARRIOR";
        if (value == CaelumConstants.CLASS_EXPLORER) return "CA_CLASS_EXPLORER";
        if (value == CaelumConstants.CLASS_PRIEST) return "CA_CLASS_PRIEST";
        return "CA_CLASS_MAGE";
    }

    String ActivityKey(int value) { return String.Format("CA_CREATE_ACTIVITY_%d", value); }

    String ProfessionKey(int candidate)
    {
        int profession = CaelumCharacterProfile.ProfessionFor(FirstClass, candidate);
        switch (profession)
        {
            case CaelumConstants.PROFESSION_MERCENARY: return "CA_PROFESSION_MERCENARY";
            case CaelumConstants.PROFESSION_CLERIC: return "CA_PROFESSION_CLERIC";
            case CaelumConstants.PROFESSION_BATTLE_MAGE: return "CA_PROFESSION_BATTLE_MAGE";
            case CaelumConstants.PROFESSION_PILGRIM: return "CA_PROFESSION_PILGRIM";
            case CaelumConstants.PROFESSION_INVESTIGATOR: return "CA_PROFESSION_INVESTIGATOR";
            case CaelumConstants.PROFESSION_ARCANIST: return "CA_PROFESSION_ARCANIST";
            default: return ClassKey(profession);
        }
    }

    String ContextKey()
    {
        if(IsPersonalityPage())return CaelumPersonalityRules.ChoiceKey(Page-CaelumPersonalityRules.FIRST_PAGE,
            Personality[Page-CaelumPersonalityRules.FIRST_PAGE]).."_DESC";
        String key;
        if (Page == CaelumConstants.CREATION_PAGE_RACE) key = RaceKey();
        else if (Page == CaelumConstants.CREATION_PAGE_FIRST_CLASS) key = ClassKey(FirstClass);
        else if (Page == CaelumConstants.CREATION_PAGE_SECOND_CLASS)
        {
            key = ProfessionKey(SecondClass);
            if (CaelumCharacterProfile.ProfessionFor(FirstClass, SecondClass) < 4)
                return "CA_CREATE_PROFESSION_" .. key.Mid(9);
        }
        else if (Page == CaelumConstants.CREATION_PAGE_LAYERS) key = LayerKey(SelectedLayer);
        else if (Page == CaelumConstants.CREATION_PAGE_ATTRIBUTES) key = AttributeKey(SelectedAttribute);
        else return "";
        return "CA_CREATE_" .. key.Mid(3);
    }

    String ContextText()
    {
        String key = ContextKey();
        if (key == "") return "";
        String result = StringTable.Localize(key, false);
        if (Page == CaelumConstants.CREATION_PAGE_RACE)
            result = result .. "\n\n" .. StringTable.Localize("CA_CREATE_RACIAL_PLANNED", false);
        else if (Page == CaelumConstants.CREATION_PAGE_FIRST_CLASS
            || (Page == CaelumConstants.CREATION_PAGE_SECOND_CLASS
                && CaelumCharacterProfile.ProfessionFor(FirstClass, SecondClass) != CaelumConstants.PROFESSION_ARCANIST))
            result = result .. "\n\n" .. StringTable.Localize("CA_CREATE_CLASS_PLANNED", false);
        return result;
    }

    String SexKey()
    {
        return Sex == CaelumConstants.SEX_FEMALE
            ? "CA_SEX_FEMALE" : "CA_SEX_MALE";
    }

    String HeightKey()
    {
        if (HeightChoice == CaelumConstants.HEIGHT_SHORT) return "CA_HEIGHT_SHORT";
        if (HeightChoice == CaelumConstants.HEIGHT_TALL) return "CA_HEIGHT_TALL";
        return "CA_HEIGHT_NORMAL";
    }

    String LayerKey(int layer)
    {
        if (layer == 0) return "CA_LAYER_PHYSICAL";
        if (layer == 1) return "CA_LAYER_TECHNICAL";
        if (layer == 2) return "CA_LAYER_SOCIAL";
        return "CA_LAYER_MENTAL";
    }

    String AttributeKey(int attribute)
    {
        switch (attribute)
        {
            case 0: return "CA_ATTRIBUTE_STRENGTH";
            case 1: return "CA_ATTRIBUTE_TOUGHNESS";
            case 2: return "CA_ATTRIBUTE_CONSTITUTION";
            case 3: return "CA_ATTRIBUTE_AGILITY";
            case 4: return "CA_ATTRIBUTE_DEXTERITY";
            case 5: return "CA_ATTRIBUTE_RESILIENCE";
            case 6: return "CA_ATTRIBUTE_CHARISMA";
            case 7: return "CA_ATTRIBUTE_EMPATHY";
            case 8: return "CA_ATTRIBUTE_ELOQUENCE";
            case 9: return "CA_ATTRIBUTE_INTELLIGENCE";
            case 10: return "CA_ATTRIBUTE_PATIENCE";
            default: return "CA_ATTRIBUTE_INSIGHT";
        }
    }

    String PageTitleKey()
    {
        if(IsPersonalityPage())return CaelumPersonalityRules.LayerKey(Page-CaelumPersonalityRules.FIRST_PAGE);
        switch (Page)
        {
            case 0: return "CA_CREATION_TITLE_RACE";
            case 1: return "CA_CREATION_TITLE_FIRST_CLASS";
            case 2: return "CA_CREATION_TITLE_SECOND_CLASS";
            case 3: return "CA_CREATION_TITLE_SEX";
            case 4: return "CA_CREATION_TITLE_HEIGHT";
            case 5: return "CA_CREATION_TITLE_LAYERS";
            case 6: return "CA_CREATION_TITLE_ATTRIBUTES";
            default: return "CA_CREATION_TITLE_SUMMARY";
        }
    }

    String PageHelpKey()
    {
        if(IsPersonalityPage())return "CA_PERSONALITY_HELP";
        switch (Page)
        {
            case 0: return "CA_CREATION_HELP_RACE";
            case 1: return "CA_CREATION_HELP_FIRST_CLASS";
            case 2: return "CA_CREATION_HELP_SECOND_CLASS";
            case 3: return "CA_CREATION_HELP_SEX";
            case 4: return "CA_CREATION_HELP_HEIGHT";
            case 5: return "CA_CREATION_HELP_LAYERS";
            case 6: return "CA_CREATION_HELP_ATTRIBUTES";
            default: return "CA_CREATION_HELP_SUMMARY";
        }
    }

    String CurrentChoice()
    {
        switch (Page)
        {
            case 0: return StringTable.Localize(RaceKey(), false);
            case 1: return StringTable.Localize(ActivityKey(FirstClass), false);
            case 2: return StringTable.Localize(ProfessionKey(SecondClass), false);
            case 3: return StringTable.Localize(SexKey(), false);
            default: return StringTable.Localize(HeightKey(), false);
        }
    }

    // Lienzo adaptable de 600 de alto, igual al de la introducción aceptada.
    // Las medidas sólo distribuyen texto; no calculan atributos ni costes.
    double PanelWidth() { return Min(1040.0, CaelumNarrativeArtwork.CanvasWidth() - 64); }
    double PanelLeft() { return (CaelumNarrativeArtwork.CanvasWidth() - PanelWidth()) / 2; }
    double LeftWidth() { return PanelWidth() * 0.43 - 32; }
    double ContextLeft() { return PanelLeft() + PanelWidth() * 0.43 + 20; }
    double ContextWidth() { return PanelWidth() * 0.57 - 40; }

    void Line(Font font, int color, double x, double y, String value, double width, double scale = 1.6)
    {
        if (font.StringWidth(value) * scale > width)
            scale = width / Max(1, font.StringWidth(value));
        CaelumNarrativeArtwork.Text(font, color, x, y, value, scale);
    }

    void Center(Font font, int color, double y, String value, double scale = 1.5)
    {
        scale = Min(scale, PanelWidth() / Max(1, font.StringWidth(value)));
        CaelumNarrativeArtwork.Text(font, color,
            (CaelumNarrativeArtwork.CanvasWidth() - font.StringWidth(value) * scale) / 2, y, value, scale);
    }

    double ContextScale()
    {
        double scale = 1.75;
        while (scale > 1.05)
        {
            let lines = TextFont.BreakLines(ContextText(), int(ContextWidth() / scale));
            bool fits = lines.Count() * (TextFont.GetHeight() + 4) * scale <= 340;
            lines.Destroy();
            if (fits) break;
            scale -= 0.05;
        }
        return scale;
    }

    void DrawContext()
    {
        if (ContextKey() == "") return;
        double scale = ContextScale();
        let lines = TextFont.BreakLines(ContextText(), int(ContextWidth() / scale));
        double y = 134;
        for (int i = 0; i < lines.Count(); i++)
        {
            CaelumNarrativeArtwork.Text(TextFont, Font.CR_WHITE,
                ContextLeft(), y, lines.StringAt(i), scale);
            y += (TextFont.GetHeight() + 4) * scale;
        }
        lines.Destroy();
    }

    void DrawBasicPage()
    {
        if (Page > CaelumConstants.CREATION_PAGE_SECOND_CLASS)
        { Center(TextFont, Font.CR_GOLD, 232, "< " .. CurrentChoice() .. " >", 1.6); return; }
        int selected = Page == 0 ? Race : Page == 1 ? FirstClass : SecondClass;
        for (int i = 0; i < 4; i++)
        {
            String key = Page == 0 ? RaceKey(i) : Page == 1 ? ActivityKey(i) : ProfessionKey(i);
            String value = (i == selected ? "> " : "  ") .. StringTable.Localize(key, false);
            Line(TextFont, i == selected ? Font.CR_GOLD : Font.CR_WHITE,
                PanelLeft() + 16, 146 + i * 58, value, LeftWidth());
        }
        if (Page == CaelumConstants.CREATION_PAGE_SECOND_CLASS)
            Line(SmallTextFont, Font.CR_GRAY, PanelLeft() + 16, 411,
                String.Format(StringTable.Localize("CA_CREATE_SECOND_NOTE", false),
                    StringTable.Localize(ClassKey(FirstClass), false)), LeftWidth(), 1.35);
    }

    void DrawLayerPage()
    {
        for (int layer = 0; layer < 4; layer++)
        {
            String row = String.Format("%s %d (+%d)", StringTable.Localize(LayerKey(layer), false),
                FinalLayerValue(layer), LayerBonus[layer]);
            Line(TextFont, layer == SelectedLayer ? Font.CR_GOLD : Font.CR_WHITE,
                PanelLeft() + 16, 146 + layer * 58, row, LeftWidth());
        }
        DrawRemaining(RemainingLayerPoints());
    }

    void DrawRemaining(int remaining)
    {
        Line(SmallTextFont, Font.CR_GREEN, PanelLeft() + 16, 468,
            String.Format("%s: %d", StringTable.Localize("CA_CREATION_POINTS_LEFT", false), remaining), LeftWidth());
    }

    void DrawAttributePage()
    {
        for (int attribute = 0; attribute < 12; attribute++)
        {
            String row = String.Format("%s +%d/%d", StringTable.Localize(AttributeKey(attribute), false),
                AttributeBonus[attribute], MaximumAttributeBonus(attribute));
            Line(SmallTextFont, attribute == SelectedAttribute ? Font.CR_GOLD : Font.CR_WHITE,
                PanelLeft() + 16, 124 + attribute * 27, row, LeftWidth());
        }
        DrawRemaining(RemainingAttributePoints());
    }

    void DrawPersonalityPage()
    {
        int layer=Page-CaelumPersonalityRules.FIRST_PAGE;
        for(int i=0;i<3;i++)
            Line(TextFont,i==Personality[layer]?Font.CR_GOLD:Font.CR_WHITE,
                PanelLeft()+16,146+i*58,(i==Personality[layer]?"> ":"  ")
                ..StringTable.Localize(CaelumPersonalityRules.ChoiceKey(layer,i),false),LeftWidth());
    }

    void DrawSummaryPage()
    {
        Center(TextFont,Font.CR_WHITE,126,StringTable.Localize(RaceKey(),false));
        Center(TextFont,Font.CR_GOLD,174,StringTable.Localize(ProfessionKey(SecondClass),false),1.6);
        Center(SmallTextFont,Font.CR_GRAY,216,StringTable.Localize(ClassKey(FirstClass),false)
            .." + "..StringTable.Localize(ClassKey(SecondClass),false));
        Center(TextFont,Font.CR_WHITE,258,StringTable.Localize(SexKey(),false).." / "..StringTable.Localize(HeightKey(),false));
        for(int i=0;i<4;i++)Center(TextFont,Font.CR_GOLD,320+i*40,
            StringTable.Localize(CaelumPersonalityRules.LayerKey(i),false)..": "
            ..StringTable.Localize(CaelumPersonalityRules.ChoiceKey(i,Personality[i]),false),1.35);
    }

    void PointerLayout(bool draw)
    {
        Pointer.Clear();
        bool allocation=Page==CaelumConstants.CREATION_PAGE_LAYERS || Page==CaelumConstants.CREATION_PAGE_ATTRIBUTES;
        int count=IsPersonalityPage()?3:Page==CaelumConstants.CREATION_PAGE_ATTRIBUTES?12:Page==CaelumConstants.CREATION_PAGE_LAYERS?4:
            Page==CaelumConstants.CREATION_PAGE_RACE?4:Page==CaelumConstants.CREATION_PAGE_FIRST_CLASS?4:Page==CaelumConstants.CREATION_PAGE_SECOND_CLASS?4:0;
        for(int i=0;i<count;i++)
        {
            double y=Page==CaelumConstants.CREATION_PAGE_ATTRIBUTES?124+i*27:146+i*58;
            double height=Page==CaelumConstants.CREATION_PAGE_ATTRIBUTES?25:48;
            Pointer.Add(100+i,PanelLeft()+16,y,LeftWidth(),height);
            if(draw && Pointer.Positioned && CaelumMenuPointer.Inside(Pointer.Position,(PanelLeft()+16,y),(LeftWidth(),height)))
                CaelumNarrativeArtwork.Rect(PanelLeft()+16,y,LeftWidth(),height,0xA8B6C8,0.12);
        }
        double left=(CaelumNarrativeArtwork.CanvasWidth()-760)/2;
        for(int i=0;i<4;i++)
        {
            double x=left+i*194;
            Pointer.Add(i+1,x,548,178,36);
            if(!draw)continue;
            bool hover=Pointer.Positioned && CaelumMenuPointer.Inside(Pointer.Position,(x,548),(178,36));
            CaelumNarrativeArtwork.Rect(x,548,178,36,hover?0x806632:0x152029,0.9);
            String key=i==0?"CA_UI_BACK":i==1?allocation?"CA_UI_MINUS":"CA_UI_PREVIOUS":i==2?allocation?"CA_UI_PLUS":"CA_UI_NEXT":"CA_UI_CONFIRM";
            Line(SmallTextFont,hover?Font.CR_GOLD:Font.CR_WHITE,x+12,558,StringTable.Localize(key,false),154,1.4);
        }
    }
    override void OnReturn(){Pointer.Reset();}
    override bool OnUIEvent(UIEvent e)
    {
        if(e.Type==UIEvent.Type_WheelUp || e.Type==UIEvent.Type_WheelDown)
            return MenuEvent(e.Type==UIEvent.Type_WheelUp?MKEY_Up:MKEY_Down,false);
        return Super.OnUIEvent(e);
    }
    override bool MouseEvent(int type,int x,int y)
    {
        PointerLayout(false);Pointer.Move((x*600.0/Screen.GetHeight(),y*600.0/Screen.GetHeight()));
        if(type==MOUSE_Click)Pointer.Press(Page);
        else if(type==MOUSE_Release)
        {
            int id=Pointer.Release(Page);
            if(id>=100)
            {
                int value=id-100;
                if(Page==CaelumConstants.CREATION_PAGE_LAYERS)SelectedLayer=value;
                else if(Page==CaelumConstants.CREATION_PAGE_ATTRIBUTES)SelectedAttribute=value;
                else
                {
                    int current=IsPersonalityPage()?Personality[Page-CaelumPersonalityRules.FIRST_PAGE]:Page==CaelumConstants.CREATION_PAGE_RACE?Race:Page==CaelumConstants.CREATION_PAGE_FIRST_CLASS?FirstClass:SecondClass;
                    if(value!=current)ChangeChoice(value-current);
                }
            }
            else if(id>0)MenuEvent(id==1?MKEY_Back:id==2?MKEY_Left:id==3?MKEY_Right:MKEY_Enter,false);
        }
        return true;
    }
    override void Drawer()
    {
        screen.Dim(0, 0.90, 0, 0, screen.GetWidth(), screen.GetHeight());
        bool contextual = ContextKey() != "";
        if (contextual)
        {
            CaelumNarrativeArtwork.Rect(ContextLeft() - 16, 116, ContextWidth() + 32, 378, 0x152029, 0.85);
            CaelumNarrativeArtwork.Rect(ContextLeft() - 16, 116, 1, 378, 0xA8B6C8, 0.7);
        }
        Center(TitleFont, Font.CR_GOLD, 24, StringTable.Localize("CA_CREATION_MAIN_TITLE", false), 1.65);
        Center(TextFont, Font.CR_WHITE, 74, StringTable.Localize(PageTitleKey(), false), 1.6);
        if(IsPersonalityPage())DrawPersonalityPage();
        else if (Page <= CaelumConstants.CREATION_PAGE_HEIGHT) DrawBasicPage();
        else if (Page == CaelumConstants.CREATION_PAGE_LAYERS) DrawLayerPage();
        else if (Page == CaelumConstants.CREATION_PAGE_ATTRIBUTES) DrawAttributePage();
        else DrawSummaryPage();
        DrawContext();
        Center(SmallTextFont, Font.CR_GRAY, 516, StringTable.Localize(PageHelpKey(), false), 1.4);
        String navigation = Page == CaelumConstants.CREATION_PAGE_SUMMARY
            ? "CA_CREATION_SUMMARY_NAVIGATION_HELP"
            : (Page >= CaelumConstants.CREATION_PAGE_LAYERS
                ? "CA_CREATION_ALLOCATION_NAVIGATION_HELP" : "CA_CREATION_NAVIGATION_HELP");
        PointerLayout(true);
    }

    void SetDraft(Name name, int value)
    {
        if (consoleplayer < 0) { return; }
        CVar draft = CVar.GetCVar(name, players[consoleplayer]);
        if (draft != null) { draft.SetInt(value); }
    }

    void ConfirmAndStart()
    {
        if (RemainingLayerPoints() != 0 || RemainingAttributePoints() != 0)
        {
            MenuSound("menu/clear");
            return;
        }
        SetDraft("ca_newchar_race", Race);
        SetDraft("ca_newchar_first_class", FirstClass);
        SetDraft("ca_newchar_second_class", SecondClass);
        SetDraft("ca_newchar_sex", Sex);
        SetDraft("ca_newchar_height", HeightChoice);
        int packed=0;for(int i=3;i>=0;i--)packed=packed*3+Personality[i];
        SetDraft("ca_newchar_personality",packed);
        SetDraft("ca_newchar_layer0", LayerBonus[0]);
        SetDraft("ca_newchar_layer1", LayerBonus[1]);
        SetDraft("ca_newchar_layer2", LayerBonus[2]);
        SetDraft("ca_newchar_layer3", LayerBonus[3]);
        SetDraft("ca_newchar_attribute0", AttributeBonus[0]);
        SetDraft("ca_newchar_attribute1", AttributeBonus[1]);
        SetDraft("ca_newchar_attribute2", AttributeBonus[2]);
        SetDraft("ca_newchar_attribute3", AttributeBonus[3]);
        SetDraft("ca_newchar_attribute4", AttributeBonus[4]);
        SetDraft("ca_newchar_attribute5", AttributeBonus[5]);
        SetDraft("ca_newchar_attribute6", AttributeBonus[6]);
        SetDraft("ca_newchar_attribute7", AttributeBonus[7]);
        SetDraft("ca_newchar_attribute8", AttributeBonus[8]);
        SetDraft("ca_newchar_attribute9", AttributeBonus[9]);
        SetDraft("ca_newchar_attribute10", AttributeBonus[10]);
        SetDraft("ca_newchar_attribute11", AttributeBonus[11]);
        SetDraft("ca_newchar_ready", 1);
        StoreSessionDraft();
        Confirmed = true;
        MenuSound("caelum/ui/menu_select");
        Menu.SetMenu("CaelumIntroductionMenu");
    }

    override bool MenuEvent(int mkey, bool fromcontroller)
    {
        Pointer.Reset();
        if (mkey == MKEY_Up || mkey == MKEY_Down)
        {
            int direction = mkey == MKEY_Up ? -1 : 1;
            if (Page == CaelumConstants.CREATION_PAGE_LAYERS)
                SelectedLayer = Wrap(SelectedLayer + direction, 4);
            else if (Page == CaelumConstants.CREATION_PAGE_ATTRIBUTES)
                SelectedAttribute = Wrap(SelectedAttribute + direction, 12);
            else
                ChangeChoice(direction);
            MenuSound("caelum/ui/menu_move");
            return true;
        }
        if (mkey == MKEY_Left || mkey == MKEY_Right)
        {
            int direction = mkey == MKEY_Left ? -1 : 1;
            if (Page == CaelumConstants.CREATION_PAGE_LAYERS
                || Page == CaelumConstants.CREATION_PAGE_ATTRIBUTES)
                ChangeSelectedPoint(direction);
            else
                ChangeChoice(direction);
            MenuSound("caelum/ui/menu_move");
            return true;
        }
        if (mkey == MKEY_Enter)
        {
            if (Page == CaelumConstants.CREATION_PAGE_SUMMARY)
            {
                ConfirmAndStart();
                return true;
            }
            if ((Page == CaelumConstants.CREATION_PAGE_LAYERS
                    && RemainingLayerPoints() != 0)
                || (Page == CaelumConstants.CREATION_PAGE_ATTRIBUTES
                    && RemainingAttributePoints() != 0))
            {
                MenuSound("menu/clear");
                return true;
            }
            Page=Page==CaelumConstants.CREATION_PAGE_ATTRIBUTES ? CaelumPersonalityRules.FIRST_PAGE
                : Page==CaelumPersonalityRules.LAST_PAGE ? CaelumConstants.CREATION_PAGE_SUMMARY : Page+1;
            MenuSound("caelum/ui/menu_select");
            return true;
        }
        if (mkey == MKEY_Back)
        {
            if (Page > CaelumConstants.CREATION_PAGE_RACE)
            {
                Page=Page==CaelumConstants.CREATION_PAGE_SUMMARY ? CaelumPersonalityRules.LAST_PAGE
                    : Page==CaelumPersonalityRules.FIRST_PAGE ? CaelumConstants.CREATION_PAGE_ATTRIBUTES : Page-1;
                MenuSound("menu/backup");
                return true;
            }
            return Super.MenuEvent(mkey, fromcontroller);
        }
        return true;
    }
}
