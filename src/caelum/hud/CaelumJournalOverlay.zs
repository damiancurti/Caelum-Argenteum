// Primera capa definitiva del Diario. La navegación es local y no duplica el
// inventario real; las acciones autoritativas se conectarán por eventos cuando
// cada sección abandone su pantalla provisional.
class CaelumJournalOverlay : EventHandler
{
    const JOURNAL_PAGE_COUNT = 6;

    Font TitleFont;
    Font TextFont;
    Font SmallFont;

    override void OnRegister()
    {
        TitleFont = Font.GetFont("CaelumDisplay");
        TextFont = Font.GetFont("CaelumText");
        SmallFont = Font.GetFont("CaelumSmall");
        SetOrder(100);
    }

    // InputProcess y ConsoleProcess pertenecen al ámbito UI. Los CVars user
    // conservan este estado en el cliente correcto sin eventos de red ni
    // escrituras sobre el EventHandler de ámbito play.
    ui bool IsJournalOpen()
    {
        if (consoleplayer < 0) { return false; }
        CVar openState = CVar.GetCVar(
            "ca_journal_open",
            players[consoleplayer]
        );
        return openState != null && openState.GetBool();
    }

    ui void SetJournalOpen(bool value)
    {
        if (consoleplayer < 0) { return; }
        CVar openState = CVar.GetCVar(
            "ca_journal_open",
            players[consoleplayer]
        );
        if (openState != null) { openState.SetBool(value); }
    }

    ui int GetJournalPage()
    {
        if (consoleplayer < 0) { return 0; }
        CVar pageState = CVar.GetCVar(
            "ca_journal_page",
            players[consoleplayer]
        );
        if (pageState == null) { return 0; }
        return Clamp(pageState.GetInt(), 0, JOURNAL_PAGE_COUNT - 1);
    }

    ui void SetJournalPage(int page)
    {
        if (consoleplayer < 0) { return; }
        CVar pageState = CVar.GetCVar(
            "ca_journal_page",
            players[consoleplayer]
        );
        if (pageState != null)
        {
            pageState.SetInt(Clamp(page, 0, JOURNAL_PAGE_COUNT - 1));
        }
    }

    ui String GetPageKey(int page)
    {
        switch (page)
        {
            case 1: return "CA_JOURNAL_CHARACTER";
            case 2: return "CA_JOURNAL_WORLD";
            case 3: return "CA_JOURNAL_CRAFTS";
            case 4: return "CA_JOURNAL_QUESTS";
            case 5: return "CA_JOURNAL_REPUTATION";
            default: return "CA_JOURNAL_INVENTORY";
        }
    }

    ui String GetPageIcon(int page)
    {
        switch (page)
        {
            case 1: return "graphics/caelum/ui/journal/icons/ca_ui_nav_character.png";
            case 2: return "graphics/caelum/ui/journal/icons/ca_ui_nav_world.png";
            case 3: return "graphics/caelum/ui/journal/icons/ca_ui_nav_crafts.png";
            case 4: return "graphics/caelum/ui/journal/icons/ca_ui_nav_quests.png";
            case 5: return "graphics/caelum/ui/journal/icons/ca_ui_nav_reputation.png";
            default: return "graphics/caelum/ui/journal/icons/ca_ui_nav_inventory.png";
        }
    }

    ui String GetInventoryCategoryIcon(int category)
    {
        switch (category)
        {
            case 1: return "ca_ui_category_weapons.png";
            case 2: return "ca_ui_category_armor.png";
            case 3: return "ca_ui_category_shields.png";
            case 4: return "ca_ui_category_accessories.png";
            case 5: return "ca_ui_category_consumables.png";
            case 6: return "ca_ui_category_materials.png";
            case 7: return "ca_ui_category_ammo.png";
            case 8: return "ca_ui_category_key_items.png";
            default: return "ca_ui_category_all.png";
        }
    }

    ui String GetWeaponNameKey(int weaponType)
    {
        switch (weaponType)
        {
            case CaelumConstants.WEAPON_TYPE_DAGGER: return "CA_WEAPON_DAGGER";
            case CaelumConstants.WEAPON_TYPE_HATCHET: return "CA_WEAPON_HATCHET";
            case CaelumConstants.WEAPON_TYPE_MACHETE: return "CA_WEAPON_MACHETE";
            case CaelumConstants.WEAPON_TYPE_JAVELIN: return "CA_WEAPON_JAVELIN";
            case CaelumConstants.WEAPON_TYPE_SWORD: return "CA_WEAPON_SWORD";
            case CaelumConstants.WEAPON_TYPE_AXE: return "CA_WEAPON_AXE";
            case CaelumConstants.WEAPON_TYPE_FLAIL: return "CA_WEAPON_FLAIL";
            case CaelumConstants.WEAPON_TYPE_SPEAR: return "CA_WEAPON_SPEAR";
            case CaelumConstants.WEAPON_TYPE_GREATSWORD: return "CA_WEAPON_GREATSWORD";
            case CaelumConstants.WEAPON_TYPE_WAR_AXE: return "CA_WEAPON_WAR_AXE";
            case CaelumConstants.WEAPON_TYPE_HALBERD: return "CA_WEAPON_HALBERD";
            case CaelumConstants.WEAPON_TYPE_GIANT_GAUNTLETS:
                return "CA_WEAPON_GIANT_GAUNTLETS";
            case CaelumConstants.WEAPON_TYPE_STANDARD_BOW:
                return "CA_WEAPON_STANDARD_BOW";
            case CaelumConstants.WEAPON_TYPE_LONGBOW: return "CA_WEAPON_LONGBOW";
            case CaelumConstants.WEAPON_TYPE_CROSSBOW: return "CA_WEAPON_CROSSBOW";
            case CaelumConstants.WEAPON_TYPE_CARBINE: return "CA_WEAPON_CARBINE";
            case CaelumConstants.WEAPON_TYPE_STAFF: return "CA_WEAPON_STAFF";
            case CaelumConstants.WEAPON_TYPE_BELL: return "CA_WEAPON_BELL";
            case CaelumConstants.WEAPON_TYPE_BOOK: return "CA_WEAPON_BOOK";
            default: return "CA_HUD_UNARMED";
        }
    }

    ui void DrawTexture(String path, double x, double y, double width,
        double height, double alpha = 1.0)
    {
        TextureID texture = TexMan.CheckForTexture(path, TexMan.Type_MiscPatch);
        if (!texture.IsValid()) { return; }
        Screen.DrawTexture(
            texture, true, x, y,
            DTA_VIRTUALWIDTHF, 640.0,
            DTA_VIRTUALHEIGHTF, 360.0,
            DTA_DESTWIDTHF, width,
            DTA_DESTHEIGHTF, height,
            DTA_ALPHA, alpha,
            DTA_KEEPRATIO, true
        );
    }

    ui void DrawTextLine(Font font, int color, double x, double y, String text)
    {
        if (font == null) { return; }
        Screen.DrawText(
            font, color, x, y, text,
            DTA_VIRTUALWIDTHF, 640.0,
            DTA_VIRTUALHEIGHTF, 360.0,
            DTA_KEEPRATIO, true,
            DTA_SHADOW, true
        );
    }

    ui void DrawCenteredText(Font font, int color, double centerX,
        double y, String text)
    {
        if (font == null) { return; }
        DrawTextLine(font, color, centerX - font.StringWidth(text) * 0.5, y, text);
    }

    ui void DrawPanel(double x, double y, double width, double height)
    {
        double corner = 32.0;
        String root = "graphics/caelum/ui/hud/components/";

        DrawTexture(root .. "ca_ui_panel_center.png", x + corner, y + corner,
            width - corner * 2.0, height - corner * 2.0);
        DrawTexture(root .. "ca_ui_panel_top.png", x + corner, y,
            width - corner * 2.0, corner);
        DrawTexture(root .. "ca_ui_panel_bottom.png", x + corner,
            y + height - corner, width - corner * 2.0, corner);
        DrawTexture(root .. "ca_ui_panel_left.png", x, y + corner,
            corner, height - corner * 2.0);
        DrawTexture(root .. "ca_ui_panel_right.png", x + width - corner,
            y + corner, corner, height - corner * 2.0);
        DrawTexture(root .. "ca_ui_panel_top_left.png", x, y, corner, corner);
        DrawTexture(root .. "ca_ui_panel_top_right.png", x + width - corner,
            y, corner, corner);
        DrawTexture(root .. "ca_ui_panel_bottom_left.png", x,
            y + height - corner, corner, corner);
        DrawTexture(root .. "ca_ui_panel_bottom_right.png",
            x + width - corner, y + height - corner, corner, corner);
    }

    ui void DrawNavigation()
    {
        int currentPage = GetJournalPage();
        for (int page = 0; page < JOURNAL_PAGE_COUNT; page++)
        {
            double centerX = 80.0 + page * 96.0;
            String frame = page == currentPage
                ? "graphics/caelum/ui/hud/components/ca_ui_icon_frame_selected.png"
                : "graphics/caelum/ui/hud/components/ca_ui_icon_frame_normal.png";
            DrawTexture(frame, centerX - 24.0, 38.0, 48.0, 48.0);
            DrawTexture(GetPageIcon(page), centerX - 14.0, 48.0, 28.0, 28.0);
            DrawCenteredText(
                SmallFont,
                page == currentPage ? Font.CR_GOLD : Font.CR_WHITE,
                centerX,
                86.0,
                StringTable.Localize(GetPageKey(page), false)
            );
        }
    }

    ui void DrawInventoryPage(CaelumPlayer localPlayer)
    {
        for (int index = 0; index < 9; index++)
        {
            DrawTexture(
                "graphics/caelum/ui/journal/icons/"
                    .. GetInventoryCategoryIcon(index),
                54.0 + index * 57.0,
                124.0,
                28.0,
                28.0,
                index == 0 ? 1.0 : 0.55
            );
        }

        String weaponName = StringTable.Localize(
            localPlayer.HUDHasActiveWeapon
                ? GetWeaponNameKey(localPlayer.HUDActiveWeaponType)
                : "CA_HUD_UNARMED",
            false
        );
        DrawTextLine(TextFont, Font.CR_WHITE, 56.0, 174.0,
            String.Format("%s: %s",
                StringTable.Localize("CA_HUD_ACTIVE_WEAPON", false),
                weaponName));
        DrawTextLine(TextFont, Font.CR_WHITE, 56.0, 198.0,
            String.Format("%s: %.3f / %.3f",
                StringTable.Localize("CA_HUD_LOAD", false),
                localPlayer.HUDCarriedWeight,
                localPlayer.HUDCarryCapacity));
        DrawTextLine(SmallFont, Font.CR_GRAY, 56.0, 242.0,
            StringTable.Localize("CA_JOURNAL_INVENTORY_FOUNDATION", false));
    }

    ui void DrawCharacterPage(CaelumPlayer localPlayer)
    {
        if (localPlayer.Attributes == null) { return; }
        CaelumAttributes values = localPlayer.Attributes;
        DrawTextLine(TextFont, Font.CR_WHITE, 56.0, 132.0,
            String.Format("%s: %d | %s: %d | %s: %d",
                StringTable.Localize("CA_ATTRIBUTE_STRENGTH", false), values.Strength,
                StringTable.Localize("CA_ATTRIBUTE_TOUGHNESS", false), values.Toughness,
                StringTable.Localize("CA_ATTRIBUTE_CONSTITUTION", false), values.Constitution));
        DrawTextLine(TextFont, Font.CR_WHITE, 56.0, 164.0,
            String.Format("%s: %d | %s: %d | %s: %d",
                StringTable.Localize("CA_ATTRIBUTE_AGILITY", false), values.Agility,
                StringTable.Localize("CA_ATTRIBUTE_DEXTERITY", false), values.Dexterity,
                StringTable.Localize("CA_ATTRIBUTE_RESILIENCE", false), values.Resilience));
        DrawTextLine(TextFont, Font.CR_WHITE, 56.0, 196.0,
            String.Format("%s: %d | %s: %d | %s: %d",
                StringTable.Localize("CA_ATTRIBUTE_CHARISMA", false), values.Charisma,
                StringTable.Localize("CA_ATTRIBUTE_EMPATHY", false), values.Empathy,
                StringTable.Localize("CA_ATTRIBUTE_ELOQUENCE", false), values.Eloquence));
        DrawTextLine(TextFont, Font.CR_WHITE, 56.0, 228.0,
            String.Format("%s: %d | %s: %d | %s: %d",
                StringTable.Localize("CA_ATTRIBUTE_INTELLIGENCE", false), values.Intelligence,
                StringTable.Localize("CA_ATTRIBUTE_PATIENCE", false), values.Patience,
                StringTable.Localize("CA_ATTRIBUTE_INSIGHT", false), values.Insight));
    }

    ui void DrawPlannedPage(String key)
    {
        DrawCenteredText(TextFont, Font.CR_WHITE, 320.0, 174.0,
            StringTable.Localize(key, false));
        DrawCenteredText(SmallFont, Font.CR_GRAY, 320.0, 210.0,
            StringTable.Localize("CA_JOURNAL_NO_FAKE_DATA", false));
    }

    override bool InputProcess(InputEvent e)
    {
        if (!IsJournalOpen()) { return false; }
        if (e.Type != InputEvent.Type_KeyDown
            && e.Type != InputEvent.Type_KeyUp)
        {
            return false;
        }
        if (e.KeyScan == InputEvent.Key_Grave
            || e.KeyScan == InputEvent.Key_Pad_Start)
        {
            return false;
        }
        if (e.Type == InputEvent.Type_KeyUp) { return true; }

        if (e.KeyScan == InputEvent.Key_Tab
            || e.KeyScan == InputEvent.Key_Escape
            || e.KeyScan == InputEvent.Key_Pad_B)
        {
            SetJournalOpen(false);
        }
        else if (e.KeyScan == InputEvent.Key_RightArrow
            || e.KeyScan == InputEvent.Key_DownArrow
            || e.KeyScan == InputEvent.Key_Pad_DPad_Right
            || e.KeyScan == InputEvent.Key_Pad_DPad_Down)
        {
            SetJournalPage((GetJournalPage() + 1) % JOURNAL_PAGE_COUNT);
        }
        else if (e.KeyScan == InputEvent.Key_LeftArrow
            || e.KeyScan == InputEvent.Key_UpArrow
            || e.KeyScan == InputEvent.Key_Pad_DPad_Left
            || e.KeyScan == InputEvent.Key_Pad_DPad_Up)
        {
            SetJournalPage(
                (GetJournalPage() + JOURNAL_PAGE_COUNT - 1)
                    % JOURNAL_PAGE_COUNT
            );
        }
        return true;
    }

    override void ConsoleProcess(ConsoleEvent e)
    {
        if (e.Name ~== "ca_journal_toggle")
        {
            SetJournalOpen(!IsJournalOpen());
        }
    }

    override void RenderOverlay(RenderEvent event)
    {
        if (!IsJournalOpen() || consoleplayer < 0
            || TitleFont == null || TextFont == null || SmallFont == null)
        {
            return;
        }
        CaelumPlayer localPlayer = CaelumPlayer(players[consoleplayer].mo);
        if (localPlayer == null) { return; }
        int currentPage = GetJournalPage();

        Screen.Dim(0x05070A, 0.92, 0, 0, Screen.GetWidth(), Screen.GetHeight());
        DrawPanel(16.0, 12.0, 608.0, 336.0);
        DrawCenteredText(TitleFont, Font.CR_GOLD, 320.0, 16.0,
            StringTable.Localize("CA_JOURNAL_TITLE", false));
        DrawNavigation();
        DrawCenteredText(TextFont, Font.CR_GOLD, 320.0, 106.0,
            StringTable.Localize(GetPageKey(currentPage), false));

        if (currentPage == 0) { DrawInventoryPage(localPlayer); }
        else if (currentPage == 1) { DrawCharacterPage(localPlayer); }
        else if (currentPage == 2) { DrawPlannedPage("CA_JOURNAL_WORLD_PENDING"); }
        else if (currentPage == 3) { DrawPlannedPage("CA_JOURNAL_CRAFTS_PENDING"); }
        else if (currentPage == 4) { DrawPlannedPage("CA_JOURNAL_QUESTS_PENDING"); }
        else { DrawPlannedPage("CA_JOURNAL_REPUTATION_PENDING"); }

        DrawCenteredText(SmallFont, Font.CR_GRAY, 320.0, 322.0,
            StringTable.Localize("CA_JOURNAL_NAVIGATION_HELP", false));
    }
}
