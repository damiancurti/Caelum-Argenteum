// Presentación local: toda confirmación vuelve a validar la identidad en play.
class CaelumCraftingUI : Object
{
    static String L(String key) { return StringTable.Localize(key, false); }
    static String ModeKey(int mode)
    {
        return mode == CaelumCraftingBrowser.REPAIR ? "CA_CRAFT_BROWSER_REPAIR"
            : mode == CaelumCraftingBrowser.DISMANTLE ? "CA_CRAFT_BROWSER_DISMANTLE" : "CA_CRAFT_BROWSER_CRAFT";
    }
    static ui int ScrollValue(String key)
    {
        let value = CVar.GetCVar(key, players[consoleplayer]);
        return value == null ? 0 : Max(0, value.GetInt());
    }
    static ui void Scroll(String key, int direction)
    {
        let value = CVar.GetCVar(key, players[consoleplayer]);
        if (value != null) value.SetInt(direction == 0 ? 0 : Max(0, value.GetInt()+direction));
    }
    static ui String Fit(Font font, String text, int width)
    {
        if (font.StringWidth(text) <= width) return text;
        let lines = font.BreakLines(text, width-font.StringWidth("..."));
        String result = lines.StringAt(0) .. "...";
        lines.Destroy();
        return result;
    }
    static ui void Paragraph(CaelumJournalOverlay view, String text, int x, int y, int width, int rows, String scrollKey)
    {
        let lines = view.SmallFont.BreakLines(text, width);
        int total = lines.Count(), offset = Clamp(ScrollValue(scrollKey), 0, Max(0,total-rows));
        let value = CVar.GetCVar(scrollKey, players[consoleplayer]);
        if (value != null && value.GetInt() != offset) value.SetInt(offset);
        for (int row = 0; row < rows && row+offset < total; row++)
            view.DrawTextLine(view.SmallFont, Font.CR_WHITE, x, y+row*12, lines.StringAt(row+offset));
        if (total > rows)
            view.DrawTextLine(view.SmallFont, Font.CR_GOLD, x+width+4, y,
                String.Format("%d\n/\n%d", offset+1, total-rows+1));
        lines.Destroy();
    }
    static ui int ListStart(CaelumCraftingBrowser browser)
    {
        return Clamp(browser.SelectedIndex-1, 0, Max(0, browser.Entries.Size()-4));
    }
    static ui String Blueprint(CaelumJournalOverlay view, CaelumPlayer user)
    {
        String result;
        for (int node = 0; node < user.CraftingBlueprintNodeCount; node++)
        {
            if (node > 0) result = result .. "\n";
            result = result .. view.FormatCraftingBlueprintNodeName(user,node);
            if (user.CraftingBlueprintNodeKind[node] == CaelumConstants.CRAFTING_BLUEPRINT_NODE_FINAL)
                result = result .. String.Format(" · %s: %d u (%.3f kg) · %d%% · %d t/u · %.1f s",
                    L("CA_JOURNAL_CRAFTING_MATERIAL_USED"), user.CraftingBlueprintNodeInputUnits[node],
                    user.CraftingBlueprintNodeInputUnits[node]*CaelumConstants.MATERIAL_UNIT_WEIGHT,
                    view.GetCraftingEfficiencyPercentForIndex(user.CraftingBlueprintNodeEfficiency[node]),
                    user.CraftingBlueprintNodeComplexityTics[node],user.CraftingBlueprintNodeSeconds[node]);
            else
            {
                result = result .. String.Format(" · %d/%d",user.CraftingBlueprintNodeOwnedUnits[node],user.CraftingBlueprintNodeUnits[node]);
                if (user.CraftingBlueprintNodeKind[node] != CaelumConstants.CRAFTING_BLUEPRINT_NODE_RAW)
                    result = result .. String.Format(" · %d%% · %d t/u · %.1f s",
                        view.GetCraftingEfficiencyPercentForIndex(user.CraftingBlueprintNodeEfficiency[node]),
                        user.CraftingBlueprintNodeComplexityTics[node],user.CraftingBlueprintNodeSeconds[node]);
            }
        }
        return result;
    }
    static ui String Materials(CaelumCraftingBrowser browser)
    {
        String result = L(browser.Mode == CaelumCraftingBrowser.REPAIR ? "CA_CRAFT_BROWSER_REQUIRED" : "CA_CRAFT_BROWSER_OUTPUT");
        if (browser.MaterialTypes.Size() == 0) return result .. " " .. L("CA_CRAFT_BROWSER_NO_PREVIEW");
        for (int i = 0; i < browser.MaterialTypes.Size(); i++)
            result = result .. "\n" .. String.Format("%s T%d: %d u (%.3f kg)",
                L(CaelumDisplayNames.GetSpecialItemKey(CaelumConstants.EQUIPMENT_KIND_MATERIAL,browser.MaterialTypes[i])),
                browser.MaterialTiers[i], browser.MaterialUnits[i], browser.MaterialUnits[i]*CaelumConstants.MATERIAL_UNIT_WEIGHT);
        if (browser.ReservedTypes.Size() > 0)
        {
            result = result .. "\n\n" .. L("CA_CRAFT_BROWSER_INPUT");
            for (int i = 0; i < browser.ReservedTypes.Size(); i++)
                result = result .. "\n" .. String.Format("%s T%d: %d u (%.3f kg)",
                    L(CaelumDisplayNames.GetSpecialItemKey(CaelumConstants.EQUIPMENT_KIND_MATERIAL,browser.ReservedTypes[i])),
                    browser.ReservedTiers[i],browser.ReservedUnits[i],browser.ReservedUnits[i]*CaelumConstants.MATERIAL_UNIT_WEIGHT);
        }
        return result;
    }
    static ui String Status(CaelumJournalOverlay view, CaelumPlayer user, CaelumCraftingBrowser browser)
    {
        if (user.CraftingTaskActive)
            return String.Format("%s: %.1f/%.1f s · %s", L("CA_CRAFTING_TASK_ACTIVE"),
                user.CraftingTaskRemainingSeconds,user.CraftingTaskTotalSeconds,
                L(user.CraftingTaskProgressing ? "CA_JOURNAL_CRAFTING_RUNNING" : "CA_JOURNAL_CRAFTING_PAUSED"));
        if (user.LastCraftingAction != CaelumConstants.CRAFTING_ACTION_NONE) return L(view.GetCraftingActionKey(user.LastCraftingAction));
        if (user.LastEquipmentAction != CaelumConstants.EQUIPMENT_ACTION_NONE) return EquipmentStatus(view,user.LastEquipmentAction);
        if (browser.SelectedIndex < 0) return L(browser.Mode == CaelumCraftingBrowser.CRAFT ? "CA_CRAFT_BROWSER_EMPTY_RECIPES" : "CA_CRAFT_BROWSER_EMPTY_WEAPONS");
        if (browser.Mode != CaelumCraftingBrowser.CRAFT && browser.BlockReason != CaelumConstants.EQUIPMENT_ACTION_NONE)
            return EquipmentStatus(view,browser.BlockReason);
        if (!user.CraftingMenuOpen) return L("CA_CRAFT_BROWSER_STATION");
        if (browser.Mode == CaelumCraftingBrowser.CRAFT)
        {
            if (!user.CraftingSelectedInfrastructureAvailable) return L("CA_CRAFTING_ACTION_FAILED_INFRASTRUCTURE");
            if (!user.CraftingDirectPlanAvailable) return L("CA_CRAFTING_ACTION_FAILED_MATERIALS");
        }
        return L("CA_CRAFT_BROWSER_CONFIRM");
    }
    static ui String EquipmentStatus(CaelumJournalOverlay view, int reason)
    {
        return L(reason == CaelumConstants.EQUIPMENT_ACTION_FAILED_RESERVED
            ? "CA_CRAFT_BROWSER_PROTECTED" : view.GetEquipmentActionKey(reason));
    }
    static ui void Draw(CaelumJournalOverlay view, CaelumPlayer user)
    {
        let browser = user.CraftingBrowser;
        int mode = browser == null ? 0 : browser.Mode;
        for (int i = 0; i < 3; i++)
        {
            int x = 64+i*184;
            String state = i == mode ? "selected" : "normal";
            view.DrawTexture("graphics/caelum/ui/journal/components/ca_ui_nav_laurel_" .. state .. ".png",x,108,36,36);
            view.DrawTexture("graphics/caelum/ui/hud/components/ca_ui_icon_frame_" .. state .. ".png",x,108,36,36);
            view.DrawTexture("graphics/caelum/ui/journal/icons/ca_ui_action_"
                .. (i == 0 ? "craft" : i == 1 ? "repair" : "dismantle") .. ".png",x+7,115,22,22);
            view.DrawTextLine(view.TextFont,i == mode ? Font.CR_GOLD : Font.CR_GRAY,x+42,120,
                String.Format("%d %s",i+1,L(ModeKey(i))));
        }
        if (browser == null) return;
        view.DrawTextLine(view.SmallFont,Font.CR_GOLD,48,150,mode == CaelumCraftingBrowser.CRAFT
            ? L(view.GetCraftingFilterKey(user.CraftingRecipeFilter)) : L("CA_CRAFT_BROWSER_OWNED"));
        view.DrawTextLine(view.SmallFont,Font.CR_GRAY,48,274,
            String.Format("<  %d / %d  >",browser.SelectedIndex+1,browser.Entries.Size()));
        int start = ListStart(browser);
        for (int row = 0; row < 4 && start+row < browser.Entries.Size(); row++)
        {
            int index = start+row;
            bool selected = index == browser.SelectedIndex;
            view.DrawTextLine(view.SmallFont,selected ? Font.CR_GOLD : Font.CR_GRAY,48,170+row*25,
                (selected ? "> " : "  ") .. Fit(view.SmallFont,browser.Labels[index],165));
        }
        if (browser.SelectedIndex >= 0)
        {
            bool craft = mode == CaelumCraftingBrowser.CRAFT;
            String icon = craft ? user.CraftingPreviewIconPath : browser.Icon;
            view.DrawTexture("graphics/caelum/ui/hud/components/ca_ui_icon_frame_selected.png",244,150,42,42);
            if (icon != "") view.DrawTexture(icon,250,156,30,30);
            String title = craft ? CaelumCraftingBrowser.RecipeName(user.CraftingSelectionRecipe,user.CraftingSelectionTier) : browser.Title;
            let titleLines = view.SmallFont.BreakLines(title,288);
            for (int row = 0; row < Min(2,titleLines.Count()); row++)
                view.DrawTextLine(view.SmallFont,Font.CR_GOLD,294,152+row*12,titleLines.StringAt(row));
            titleLines.Destroy();
            view.DrawTextLine(view.SmallFont,Font.CR_WHITE,294,179,craft
                ? String.Format("T%d · %s · x%d · %d%%", user.CraftingSelectionTier,
                    L(CaelumDisplayNames.GetEquipmentSizeKey(user.CraftingSelectionSize)),user.CraftingProcessingBatchMultiplier,user.CraftingEfficiencyPercent)
                : String.Format("#%d · %d/%d · %s",browser.SelectedWeaponId,browser.Durability,browser.MaximumDurability,
                    L(browser.Equipped ? "CA_CRAFT_BROWSER_EQUIPPED" : browser.Boxed ? "CA_CRAFT_BROWSER_BOXED" : "CA_CRAFT_BROWSER_CARRIED")));
            view.DrawTextLine(view.SmallFont,Font.CR_CYAN,244,198,craft
                ? String.Format("%s: %.1f s · %s: %.1f s",L("CA_JOURNAL_CRAFTING_TIME"),user.CraftingPreviewSeconds,
                    L("CA_JOURNAL_CRAFTING_FROM_RAW"),user.CraftingBlueprintFullSeconds)
                : String.Format("%s: %s · T%d · %s · %.3f kg",L("CA_JOURNAL_CRAFTING_TIME"),
                    browser.BlockReason == CaelumConstants.EQUIPMENT_ACTION_NONE ? String.Format("%.1f s",browser.Seconds) : "-",browser.Tier,
                    L(CaelumDisplayNames.GetEquipmentSizeKey(browser.Size)),browser.Weight));
            String details = craft ? Blueprint(view,user) : Materials(browser);
            if (mode == CaelumCraftingBrowser.REPAIR) details = String.Format("%d%%\n",user.CraftingEfficiencyPercent) .. details;
            if (!craft && browser.Essence >= 0 && browser.Essence < CaelumConstants.ESSENCE_TYPE_COUNT)
                details = L(CaelumNotifications.EssenceKey(browser.Essence)) .. "\n" .. details;
            Paragraph(view,details,244,216,330,5,"ca_journal_craft_scroll");
        }
        else Paragraph(view,L(mode == CaelumCraftingBrowser.CRAFT ? "CA_CRAFT_BROWSER_EMPTY_RECIPES" : "CA_CRAFT_BROWSER_EMPTY_WEAPONS"),
            244,178,330,5,"ca_journal_craft_scroll");
        let statusLines = view.SmallFont.BreakLines(Status(view,user,browser),544);
        for (int row = 0; row < Min(2,statusLines.Count()); row++)
            view.DrawTextLine(view.SmallFont,Font.CR_GOLD,48,291+row*12,statusLines.StringAt(row));
        statusLines.Destroy();
        view.DrawCenteredText(view.SmallFont,Font.CR_GRAY,320,318,L("CA_CRAFT_BROWSER_HELP"));
        view.DrawCenteredText(view.SmallFont,Font.CR_GRAY,320,330,L(craftModeKey(mode)));
    }
    static String craftModeKey(int mode)
    {
        return mode == CaelumCraftingBrowser.CRAFT ? "CA_CRAFT_BROWSER_CRAFT_HELP" : "CA_CRAFT_BROWSER_EQUIPMENT_HELP";
    }
    static ui void Confirm(CaelumJournalOverlay view, CaelumPlayer user)
    {
        let browser = user.CraftingBrowser;
        if (browser != null && browser.SelectedIndex >= 0)
        {
            view.SendNetworkEvent("ca_crafting_browser_confirm", browser.Mode,browser.Entries[browser.SelectedIndex],browser.Serial);
            view.SendNetworkEvent("ca_journal_menu_select_sound");
        }
    }
    static ui bool Key(CaelumJournalOverlay view,CaelumPlayer user,int scan,int character)
    {
        let browser = user.CraftingBrowser;
        if (browser == null) return true;
        int mode = browser.Mode;
        if (character >= 49 && character <= 51)
        { view.SendNetworkEvent("ca_crafting_browser_mode",character-49); Scroll("ca_journal_craft_scroll",0); }
        else if (scan == InputEvent.Key_LeftArrow || scan == InputEvent.Key_Pad_DPad_Left
            || scan == InputEvent.Key_RightArrow || scan == InputEvent.Key_Pad_DPad_Right)
        { view.SendNetworkEvent("ca_crafting_browser_move",scan == InputEvent.Key_LeftArrow || scan == InputEvent.Key_Pad_DPad_Left ? -1 : 1); Scroll("ca_journal_craft_scroll",0); }
        else if (scan == InputEvent.Key_UpArrow || scan == InputEvent.Key_Pad_DPad_Up) Scroll("ca_journal_craft_scroll",-1);
        else if (scan == InputEvent.Key_DownArrow || scan == InputEvent.Key_Pad_DPad_Down) Scroll("ca_journal_craft_scroll",1);
        else if (scan == InputEvent.Key_Enter || scan == InputEvent.Key_Pad_A || character == 101 || character == 69)
        { Confirm(view,user); return true; }
        else if (character == 102 || character == 70) { view.SendNetworkEvent("ca_crafting_browser_mode",1); Scroll("ca_journal_craft_scroll",0); }
        else if (character == 100 || character == 68) { view.SendNetworkEvent("ca_crafting_browser_mode",2); Scroll("ca_journal_craft_scroll",0); }
        else if ((character == 103 || character == 71 || scan == InputEvent.Key_Pad_Y) && mode == CaelumCraftingBrowser.CRAFT)
        { view.SendNetworkEvent("ca_crafting_filter"); Scroll("ca_journal_craft_scroll",0); }
        else if ((scan == InputEvent.Key_Space || scan == InputEvent.Key_Pad_X) && mode == CaelumCraftingBrowser.CRAFT) view.SendNetworkEvent("ca_crafting_tier");
        else if ((character == 114 || character == 82) && mode == CaelumCraftingBrowser.CRAFT) view.SendNetworkEvent("ca_crafting_size");
        else if ((character == 98 || character == 66) && mode == CaelumCraftingBrowser.CRAFT) view.SendNetworkEvent("ca_crafting_batch");
        else if ((character == 120 || character == 88) && mode != CaelumCraftingBrowser.DISMANTLE) view.SendNetworkEvent("ca_crafting_efficiency");
        else if (character == 99 || character == 67) view.SendNetworkEvent("ca_crafting_cancel_task");
        else return false;
        view.SendNetworkEvent("ca_journal_menu_move_sound");
        return true;
    }
    static ui void Click(CaelumJournalOverlay view,CaelumPlayer user,double x,double y)
    {
        let browser = user.CraftingBrowser;
        if (browser == null) return;
        if (y >= 108 && y < 146 && x >= 52 && x < 600)
        { view.SendNetworkEvent("ca_crafting_browser_mode",Clamp(int((x-52)/184),0,2)); Scroll("ca_journal_craft_scroll",0); }
        else if (x >= 44 && x < 226 && y >= 166 && y < 266)
        { view.SendNetworkEvent("ca_crafting_browser_select",ListStart(browser)+int((y-166)/25),browser.Serial); Scroll("ca_journal_craft_scroll",0); }
        else if (x >= 44 && x < 226 && y >= 269 && y < 288)
        { view.SendNetworkEvent("ca_crafting_browser_move",x < 126 ? -1 : 1); Scroll("ca_journal_craft_scroll",0); }
        else if (y >= 288 && y < 316) { Confirm(view,user); return; }
        else return;
        view.SendNetworkEvent("ca_journal_menu_move_sound");
    }
}
