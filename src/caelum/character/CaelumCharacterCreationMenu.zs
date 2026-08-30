// Creador de personaje previo a la partida. Es un menú real de GZDoom: no
// necesita que MAP01 exista ni que CaelumPlayer haya nacido para editar el
// borrador. La confirmación copia datos validados a CVars user y arranca el
// único episodio/dificultad del proyecto mediante StartGameDirect.
class CaelumCharacterCreationMenu : ListMenu
{
    int Page;
    int Race;
    int FirstClass;
    int SecondClass;
    int Sex;
    int HeightChoice;
    int LayerBonus[4];
    int AttributeBonus[12];
    int SelectedLayer;
    int SelectedAttribute;
    Font TitleFont;
    Font TextFont;
    Font SmallTextFont;

    override void Init(Menu parent, ListMenuDescriptor desc)
    {
        Super.Init(parent, desc);
        Page = CaelumConstants.CREATION_PAGE_RACE;
        Race = CaelumConstants.RACE_HUMAN;
        FirstClass = CaelumConstants.CLASS_WARRIOR;
        SecondClass = CaelumConstants.CLASS_MAGE;
        Sex = CaelumConstants.SEX_MALE;
        HeightChoice = CaelumConstants.HEIGHT_NORMAL;
        SelectedLayer = 0;
        SelectedAttribute = 0;
        ResetAllocations();
        TitleFont = Font.GetFont("CaelumDisplay");
        TextFont = Font.GetFont("CaelumText");
        SmallTextFont = Font.GetFont("CaelumSmall");
        DontDim = true;
        DontBlur = true;
    }

    void ResetAllocations()
    {
        for (int i = 0; i < 4; i++) { LayerBonus[i] = 0; }
        for (int i = 0; i < 12; i++) { AttributeBonus[i] = 0; }
    }

    int Wrap(int value, int count)
    {
        value %= count;
        if (value < 0) { value += count; }
        return value;
    }

    int DistributionValue(int pattern, int layer)
    {
        if (pattern == 0)
        {
            if (layer == 0) return 5;
            if (layer == 1 || layer == 2) return 3;
            return 1;
        }
        if (pattern == 1)
        {
            if (layer == 0 || layer == 3) return 3;
            if (layer == 1) return 5;
            return 1;
        }
        if (pattern == 2)
        {
            if (layer == 0 || layer == 2) return 3;
            if (layer == 1) return 1;
            return 5;
        }
        if (layer == 0) return 1;
        if (layer == 1 || layer == 2) return 3;
        return 5;
    }

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

    void ChangeChoice(int direction)
    {
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

    String RaceKey()
    {
        if (Race == CaelumConstants.RACE_BEAST_MAN) return "CA_RACE_BEAST_MAN";
        if (Race == CaelumConstants.RACE_CAELITH) return "CA_RACE_CAELITH";
        if (Race == CaelumConstants.RACE_HUMAN) return "CA_RACE_HUMAN";
        return "CA_RACE_GOBLIN";
    }

    String ClassKey(int value)
    {
        if (value == CaelumConstants.CLASS_WARRIOR) return "CA_CLASS_WARRIOR";
        if (value == CaelumConstants.CLASS_EXPLORER) return "CA_CLASS_EXPLORER";
        if (value == CaelumConstants.CLASS_PRIEST) return "CA_CLASS_PRIEST";
        return "CA_CLASS_MAGE";
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
            case 1: return StringTable.Localize(ClassKey(FirstClass), false);
            case 2: return StringTable.Localize(ClassKey(SecondClass), false);
            case 3: return StringTable.Localize(SexKey(), false);
            default: return StringTable.Localize(HeightKey(), false);
        }
    }

    void DrawTextCentered(Font font, int color, int y, String value)
    {
        int x = 160 - font.StringWidth(value) / 2;
        screen.DrawText(
            font, color, x, y, value,
            DTA_320x200, true, DTA_Localize, false
        );
    }

    void DrawBasicPage()
    {
        DrawTextCentered(TextFont, Font.CR_GOLD, 82, "< " .. CurrentChoice() .. " >");
    }

    void DrawLayerPage()
    {
        for (int layer = 0; layer < 4; layer++)
        {
            String row = String.Format(
                "%s  %d (+%d)",
                StringTable.Localize(LayerKey(layer), false),
                FinalLayerValue(layer), LayerBonus[layer]
            );
            int color = layer == SelectedLayer ? Font.CR_GOLD : Font.CR_UNTRANSLATED;
            screen.DrawText(TextFont, color, 80, 62 + layer * 18, row, DTA_320x200, true);
        }
        DrawTextCentered(
            SmallTextFont, Font.CR_GREEN, 142,
            String.Format("%s: %d", StringTable.Localize("CA_CREATION_POINTS_LEFT", false), RemainingLayerPoints())
        );
    }

    void DrawAttributePage()
    {
        for (int attribute = 0; attribute < 12; attribute++)
        {
            int column = attribute / 6;
            int rowIndex = attribute % 6;
            String row = String.Format(
                "%s +%d/%d",
                StringTable.Localize(AttributeKey(attribute), false),
                AttributeBonus[attribute], MaximumAttributeBonus(attribute)
            );
            int color = attribute == SelectedAttribute
                ? Font.CR_GOLD : Font.CR_UNTRANSLATED;
            screen.DrawText(
                SmallTextFont, color, 25 + column * 150, 55 + rowIndex * 15,
                row, DTA_320x200, true
            );
        }
        DrawTextCentered(
            SmallTextFont, Font.CR_GREEN, 151,
            String.Format("%s: %d", StringTable.Localize("CA_CREATION_POINTS_LEFT", false), RemainingAttributePoints())
        );
    }

    void DrawSummaryPage()
    {
        DrawTextCentered(TextFont, Font.CR_UNTRANSLATED, 55,
            StringTable.Localize(RaceKey(), false));
        DrawTextCentered(TextFont, Font.CR_UNTRANSLATED, 72,
            StringTable.Localize(ClassKey(FirstClass), false));
        DrawTextCentered(TextFont, Font.CR_UNTRANSLATED, 89,
            StringTable.Localize(ClassKey(SecondClass), false));
        DrawTextCentered(TextFont, Font.CR_UNTRANSLATED, 106,
            StringTable.Localize(SexKey(), false));
        DrawTextCentered(TextFont, Font.CR_UNTRANSLATED, 123,
            StringTable.Localize(HeightKey(), false));
    }

    override void Drawer()
    {
        screen.Dim(0, 0.76, 0, 0, screen.GetWidth(), screen.GetHeight());
        DrawTextCentered(
            TitleFont, Font.CR_GOLD, 12,
            StringTable.Localize("CA_CREATION_MAIN_TITLE", false)
        );
        DrawTextCentered(
            TextFont, Font.CR_UNTRANSLATED, 35,
            StringTable.Localize(PageTitleKey(), false)
        );

        if (Page <= CaelumConstants.CREATION_PAGE_HEIGHT) DrawBasicPage();
        else if (Page == CaelumConstants.CREATION_PAGE_LAYERS) DrawLayerPage();
        else if (Page == CaelumConstants.CREATION_PAGE_ATTRIBUTES) DrawAttributePage();
        else DrawSummaryPage();

        DrawTextCentered(
            SmallTextFont, Font.CR_GRAY, 164,
            StringTable.Localize(PageHelpKey(), false)
        );
        String navigation = Page == CaelumConstants.CREATION_PAGE_SUMMARY
            ? "CA_CREATION_SUMMARY_NAVIGATION_HELP"
            : (Page >= CaelumConstants.CREATION_PAGE_LAYERS
                ? "CA_CREATION_ALLOCATION_NAVIGATION_HELP"
                : "CA_CREATION_NAVIGATION_HELP");
        DrawTextCentered(
            SmallTextFont, Font.CR_GREEN, 182,
            StringTable.Localize(navigation, false)
        );
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
        Menu.StartGameDirect(true, false, "CaelumPlayer", 0, 0);
    }

    override bool MenuEvent(int mkey, bool fromcontroller)
    {
        if (mkey == MKEY_Up || mkey == MKEY_Down)
        {
            int direction = mkey == MKEY_Up ? -1 : 1;
            if (Page == CaelumConstants.CREATION_PAGE_LAYERS)
                SelectedLayer = Wrap(SelectedLayer + direction, 4);
            else if (Page == CaelumConstants.CREATION_PAGE_ATTRIBUTES)
                SelectedAttribute = Wrap(SelectedAttribute + direction, 12);
            else
                ChangeChoice(direction);
            MenuSound("menu/cursor");
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
            MenuSound("menu/cursor");
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
            Page++;
            MenuSound("menu/advance");
            return true;
        }
        if (mkey == MKEY_Back)
        {
            if (Page > CaelumConstants.CREATION_PAGE_RACE)
            {
                Page--;
                MenuSound("menu/backup");
                return true;
            }
            return Super.MenuEvent(mkey, fromcontroller);
        }
        return true;
    }
}
