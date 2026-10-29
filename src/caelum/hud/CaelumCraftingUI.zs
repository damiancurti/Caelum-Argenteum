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
        let lines = font.BreakLines(CaelumInputHints.Resolve(text), width-font.StringWidth("..."));
        String result = lines.StringAt(0) .. "...";
        lines.Destroy();
        return result;
    }
    static ui void Paragraph(CaelumJournalOverlay view, String text, int x, int y, int width, int rows, String scrollKey)
    {
        let lines = view.SmallFont.BreakLines(CaelumInputHints.Resolve(text), width);
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
        if(CaelumMealData.IsRecipe(user.CraftingSelectionRecipe))return CookingDetails(user);
        if(CaelumChemistryData.IsRecipe(user.CraftingSelectionRecipe))return ChemistryDetails(user);
        String result;
        for (int node = 0; node < user.CraftingBlueprintNodeCount; node++)
        {
            if (node > 0) result = result .. "\n";
            result = result .. view.FormatCraftingBlueprintNodeName(user,node);
            if (user.CraftingBlueprintNodeKind[node] == CaelumConstants.CRAFTING_BLUEPRINT_NODE_FINAL)
                result = result .. String.Format(" · %s: %d u (%.3f kg) · %d%% · %d t/u · %.1f s",
                    L("CA_JOURNAL_CRAFTING_MATERIAL_USED"), user.CraftingBlueprintNodeInputUnits[node],
                    user.CraftingBlueprintNodeInputUnits[node]*CaelumMaterialRules.UnitWeight(
                        CaelumCraftingRules.GetRecipeCartridgeKit(user.CraftingBlueprintNodeRecipe[node])),
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
    static ui String CookingDetails(CaelumPlayer user)
    {
        int recipe=user.CraftingSelectionRecipe;
        String result=String.Format(L("CA_CHEMISTRY_OUTPUT"),user.CraftingOutputAmount,user.CraftingFinalWeight);
        for(int slot=0;CaelumCookingData.InputMaterial(recipe,slot)>=0;slot++)
        {
            int material=CaelumCookingData.InputMaterial(recipe,slot),required=CaelumCookingData.InputGrams(recipe,slot);
            int owned=slot==0?user.CraftingBasicOwned:slot==1?user.CraftingTierOwned:slot==2?user.CraftingSilverOwned:user.CraftingGoldOwned;
            result=result.."\n"..String.Format(L("CA_CHEMISTRY_INPUT"),
                L(CaelumDisplayNames.GetSpecialItemKey(CaelumConstants.EQUIPMENT_KIND_MATERIAL,material)),owned,required,
                CaelumMaterialRules.UnitWeight(material)*required);
        }
        if(CaelumCookingData.WaterLiters(recipe)>0)
            result=result.."\n"..String.Format(L("CA_CHEMISTRY_WATER"),user.ChemistryAvailableWater,CaelumCookingData.WaterLiters(recipe));
        return result.."\n"..String.Format(L("CA_CHEMISTRY_TIME"),user.CraftingPreviewSeconds/60).."\n"..L("CA_COOKING_CANCEL");
    }
    static ui String ChemistryDetails(CaelumPlayer user)
    {
        int recipe=user.CraftingSelectionRecipe,batches=user.CraftingProcessingBatchMultiplier;
        String result=String.Format(L("CA_CHEMISTRY_OUTPUT"),user.CraftingOutputAmount,user.CraftingFinalWeight);
        for(int slot=0;CaelumChemistryData.InputMaterial(recipe,slot)>=0;slot++)
        {
            int material=CaelumChemistryData.InputMaterial(recipe,slot);
            int required=CaelumChemistryData.InputUnits(recipe,slot)*batches;
            int owned=slot==0?user.CraftingBasicOwned:slot==1?user.CraftingTierOwned:user.CraftingSilverOwned;
            result=result.."\n"..String.Format(L("CA_CHEMISTRY_INPUT"),
                L(CaelumDisplayNames.GetSpecialItemKey(CaelumConstants.EQUIPMENT_KIND_MATERIAL,material)),
                owned,required,CaelumMaterialRules.UnitWeight(material)*required);
        }
        if(CaelumChemistryData.WaterLiters(recipe)>0)
            result=result.."\n"..String.Format(L("CA_CHEMISTRY_WATER"),user.ChemistryAvailableWater,CaelumChemistryData.WaterLiters(recipe)*batches);
        return result.."\n"..String.Format(L("CA_CHEMISTRY_TIME"),user.CraftingPreviewSeconds/60).."\n"..L("CA_CHEMISTRY_CANCEL");
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
            return String.Format("%s: %.1f/%.1f s · %s", L(user.CraftingTaskKind==CaelumConstants.CRAFTING_TASK_CLEAN?"CA_CLEAN_TITLE":user.CraftingTaskKind==CaelumConstants.CRAFTING_TASK_BATH?"CA_BATH_TITLE":user.CraftingTaskKind==CaelumConstants.CRAFTING_TASK_HYGIENE?"CA_DOMESTIC_TOILET":user.CraftingTaskKind==CaelumConstants.CRAFTING_TASK_BOIL?"CA_WATER_BOIL":"CA_CRAFTING_TASK_ACTIVE"),
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
            if (!MaterialsReady(user)) return L("CA_CRAFTING_ACTION_FAILED_MATERIALS");
        }
        return L("CA_CRAFT_BROWSER_CONFIRM");
    }
    static ui String EquipmentStatus(CaelumJournalOverlay view, int reason)
    {
        return L(reason == CaelumConstants.EQUIPMENT_ACTION_FAILED_RESERVED
            ? "CA_CRAFT_BROWSER_PROTECTED" : view.GetEquipmentActionKey(reason));
    }
    static ui bool MaterialsReady(CaelumPlayer user)
    {
        if(CaelumMealData.IsRecipe(user.CraftingSelectionRecipe) && user.ChemistryAvailableWater+0.0000001
            <CaelumCookingData.WaterLiters(user.CraftingSelectionRecipe))return false;
        if(CaelumChemistryData.IsRecipe(user.CraftingSelectionRecipe) && user.ChemistryAvailableWater+0.0000001
            <CaelumChemistryData.WaterLiters(user.CraftingSelectionRecipe)*user.CraftingProcessingBatchMultiplier)return false;
        return user.CraftingDirectPlanAvailable || (user.CraftingBasicOwned>=user.CraftingBasicRequired
            && user.CraftingTierOwned>=user.CraftingTierRequired && user.CraftingSilverOwned>=user.CraftingSilverRequired
            && user.CraftingGoldOwned>=user.CraftingGoldRequired);
    }
    static ui bool CanConfirm(CaelumPlayer user,CaelumCraftingBrowser browser)
    {
        return browser!=null && browser.SelectedIndex>=0 && user.CraftingMenuOpen && !user.CraftingTaskActive
            && (browser.Mode==CaelumCraftingBrowser.CRAFT
                ? user.CraftingSelectedInfrastructureAvailable && MaterialsReady(user)
                : browser.BlockReason==CaelumConstants.EQUIPMENT_ACTION_NONE);
    }
    // Una sola descripción geométrica alimenta dibujo, resaltado y clics.
    static ui void Layout(CaelumJournalOverlay view,CaelumPlayer user,CaelumMenuPointer pointer,bool draw)
    {
        pointer.Clear();
        let browser=user.CraftingBrowser;if(browser==null)return;
        int mode=browser.Mode;
        for(int i=0;i<3;i++)
        {
            pointer.Button(view,i+1,48+i*184,112,176,CaelumInputHints.Context(L(ModeKey(i)),0,49+i),true,i==mode,draw);
            if(draw)view.DrawTexture("graphics/caelum/ui/journal/icons/ca_ui_action_" .. (i==0?"craft":i==1?"repair":"dismantle") .. ".png",52+i*184,113,16,16);
        }
        bool craft=mode==CaelumCraftingBrowser.CRAFT, selected=browser.SelectedIndex>=0;
        pointer.Button(view,10,44,146,182,craft?CaelumInputHints.Context(L(view.GetCraftingFilterKey(user.CraftingRecipeFilter)),0,103):L("CA_CRAFT_BROWSER_OWNED"),craft,false,draw);
        int start=ListStart(browser);
        for(int row=0;row<4 && start+row<browser.Entries.Size();row++)
            pointer.Button(view,100+start+row,44,170+row*25,182,CaelumInputHints.Navigation(browser.Labels[start+row],true),true,start+row==browser.SelectedIndex,draw);
        pointer.Button(view,15,44,270,64,CaelumInputHints.Context("<",InputEvent.Key_LeftArrow),selected,false,draw);
        pointer.Button(view,16,162,270,64,CaelumInputHints.Context(">",InputEvent.Key_RightArrow),selected,false,draw);
        if(draw)view.DrawCenteredText(view.SmallFont,Font.CR_GRAY,135,273,String.Format("%d / %d",browser.SelectedIndex+1,browser.Entries.Size()));
        if(selected)
        {
            if(craft)
            {
                int kind=user.CraftingSelectedRecipeKind;
                bool batch=(kind==CaelumConstants.CRAFTING_RECIPE_KIND_PROCESSING || kind==CaelumConstants.CRAFTING_RECIPE_KIND_COMPONENT)
                    && !CaelumMealData.IsRecipe(user.CraftingSelectionRecipe);
                bool sized=!batch && kind!=CaelumConstants.CRAFTING_RECIPE_KIND_PROCESSING && kind!=CaelumConstants.CRAFTING_RECIPE_KIND_UTILITY && kind!=CaelumConstants.CRAFTING_RECIPE_KIND_AMULET
                    && kind!=CaelumConstants.CRAFTING_RECIPE_KIND_SEAL && kind!=CaelumConstants.CRAFTING_RECIPE_KIND_AMMUNITION;
                pointer.Button(view,11,244,178,72,CaelumInputHints.Context(String.Format("T%d",user.CraftingSelectionTier),InputEvent.Key_Space),
                    !CaelumCraftingRules.IsSingleTierRecipe(user.CraftingSelectionRecipe) && kind!=CaelumConstants.CRAFTING_RECIPE_KIND_PROCESSING,false,draw);
                pointer.Button(view,12,320,178,112,CaelumInputHints.Context(L(CaelumDisplayNames.GetEquipmentSizeKey(CaelumCraftingRules.GetRecipeEquipmentSize(
                    user.CraftingSelectionRecipe,user.CraftingSelectionSize))),0,114),sized,false,draw);
                pointer.Button(view,13,436,178,68,CaelumInputHints.Context(String.Format("x%d",user.CraftingProcessingBatchMultiplier),0,98),batch,false,draw);
            }
            if(mode!=CaelumCraftingBrowser.DISMANTLE && !CaelumChemistryData.IsRecipe(user.CraftingSelectionRecipe) && !CaelumMealData.IsRecipe(user.CraftingSelectionRecipe))
                pointer.Button(view,14,508,178,84,CaelumInputHints.Context(String.Format("%d%%",user.CraftingEfficiencyPercent),0,120),true,false,draw);
            pointer.Button(view,20,552,218,56,CaelumInputHints.Context("^",InputEvent.Key_UpArrow),true,false,draw);
            pointer.Button(view,21,552,250,56,CaelumInputHints.Context("v",InputEvent.Key_DownArrow),true,false,draw);
        }
        pointer.Button(view,17,44,318,112,CaelumInputHints.Context(L(ModeKey(mode)),InputEvent.Key_Enter),CanConfirm(user,browser),false,draw);
        pointer.Button(view,18,160,318,120,CaelumInputHints.Context(L("CA_UI_CANCEL_TASK"),0,99),user.CraftingTaskActive,false,draw);
        pointer.Button(view,22,284,318,116,CaelumInputHints.Bound(L("CA_UI_TIME_SKIP"),"ca_time_skip"),true,false,draw);
        pointer.Button(view,23,404,318,88,CaelumInputHints.Context("x105",0,116),user.CraftingMenuOpen,false,draw);
        pointer.Button(view,19,496,318,96,CaelumInputHints.BoundOrFallback(L("CA_UI_BACK"),"ca_journal_toggle",InputEvent.Key_Tab),true,false,draw);
    }
    static ui void Draw(CaelumJournalOverlay view,CaelumPlayer user)
    {
        if(CaelumProofingUI.Active(user)){CaelumProofingUI.Draw(view,user);return;}
        if(CaelumFermentationMenu.Active(user)){CaelumFermentationUI.Draw(view,user);return;}
        let browser=user.CraftingBrowser;if(browser==null)return;
        int mode=browser.Mode;
        let boiling=CaelumWaterBoilingState.Find(user);
        if(user.CraftingTaskActive && user.CraftingTaskKind==CaelumConstants.CRAFTING_TASK_BOIL && boiling!=null)
        {
            view.DrawTextLine(view.SmallFont,Font.CR_GOLD,244,149,L("CA_WATER_BOIL"));
            if(boiling.Container!=null)view.DrawTextLine(view.SmallFont,Font.CR_WHITE,244,165,boiling.Container.GetTag());
            Paragraph(view,String.Format("%.3f L / %.1f °C -> %.3f L / %.1f °C\n",boiling.InputLiters,boiling.InputC,
                CaelumWaterThermalData.Output(boiling.InputLiters),CaelumWaterThermalData.BOILING_C)
                ..String.Format(L("CA_WATER_BOIL_PREVIEW"),user.CraftingTaskTotalSeconds,boiling.FuelUnits,
                    CaelumWaterThermalData.Output(boiling.InputLiters)),244,220,300,5,"ca_journal_craft_scroll");
        }
        else if(browser.SelectedIndex>=0)
        {
            bool craft=mode==CaelumCraftingBrowser.CRAFT;
            String icon=craft?user.CraftingPreviewIconPath:browser.Icon;
            if(icon!="")view.DrawTexture(icon,244,148,26,26);
            String title=craft?CaelumCraftingBrowser.RecipeName(user.CraftingSelectionRecipe,user.CraftingSelectionTier):browser.Title;
            let titleLines=view.SmallFont.BreakLines(title,314);
            for(int row=0;row<Min(2,titleLines.Count());row++)view.DrawTextLine(view.SmallFont,Font.CR_GOLD,278,149+row*12,titleLines.StringAt(row));
            titleLines.Destroy();
            if(!craft)view.DrawTextLine(view.SmallFont,Font.CR_WHITE,244,181,String.Format("#%d · %d/%d · %s",browser.SelectedWeaponId,browser.Durability,browser.MaximumDurability,
                L(browser.Equipped?"CA_CRAFT_BROWSER_EQUIPPED":browser.Boxed?"CA_CRAFT_BROWSER_BOXED":"CA_CRAFT_BROWSER_CARRIED")));
            view.DrawTextLine(view.SmallFont,Font.CR_CYAN,244,202,craft
                ? String.Format("%s: %.1f s · %s: %.1f s",L("CA_JOURNAL_CRAFTING_TIME"),user.CraftingPreviewSeconds,L("CA_JOURNAL_CRAFTING_FROM_RAW"),user.CraftingBlueprintFullSeconds)
                : String.Format("%s: %s · T%d · %s · %.3f kg",L("CA_JOURNAL_CRAFTING_TIME"),browser.BlockReason==CaelumConstants.EQUIPMENT_ACTION_NONE?String.Format("%.1f s",browser.Seconds):"-",browser.Tier,
                    L(CaelumDisplayNames.GetEquipmentSizeKey(browser.Size)),browser.Weight));
            String details=craft?Blueprint(view,user):Materials(browser);
            if(!craft && browser.Essence>=0 && browser.Essence<CaelumConstants.ESSENCE_TYPE_COUNT)details=L(CaelumNotifications.EssenceKey(browser.Essence)).."\n"..details;
            Paragraph(view,details,244,220,300,5,"ca_journal_craft_scroll");
        }
        else Paragraph(view,L(mode==CaelumCraftingBrowser.CRAFT?"CA_CRAFT_BROWSER_EMPTY_RECIPES":"CA_CRAFT_BROWSER_EMPTY_WEAPONS"),244,178,330,5,"ca_journal_craft_scroll");
        let statusLines=view.SmallFont.BreakLines(Status(view,user,browser),544);
        for(int row=0;row<Min(2,statusLines.Count());row++)view.DrawTextLine(view.SmallFont,Font.CR_GOLD,48,291+row*12,statusLines.StringAt(row));
        statusLines.Destroy();
        Layout(view,user,CaelumJournalInput.PointerFor(4),true);
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
        if(CaelumProofingUI.Active(user))return CaelumProofingUI.Key(view,user,scan,character);
        if(CaelumFermentationMenu.Active(user))return CaelumFermentationUI.Key(view,user,scan,character);
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
        else if ((character == 114 || character == 82) && mode == CaelumCraftingBrowser.CRAFT && !CaelumMealData.IsRecipe(user.CraftingSelectionRecipe)) view.SendNetworkEvent("ca_crafting_size");
        else if ((character == 98 || character == 66) && mode == CaelumCraftingBrowser.CRAFT && !CaelumMealData.IsRecipe(user.CraftingSelectionRecipe)) view.SendNetworkEvent("ca_crafting_batch");
        else if ((character == 120 || character == 88) && mode != CaelumCraftingBrowser.DISMANTLE && !CaelumChemistryData.IsRecipe(user.CraftingSelectionRecipe) && !CaelumMealData.IsRecipe(user.CraftingSelectionRecipe)) view.SendNetworkEvent("ca_crafting_efficiency");
        else if (character == 99 || character == 67) view.SendNetworkEvent("ca_crafting_cancel_task");
        else return false;
        view.SendNetworkEvent("ca_journal_menu_move_sound");
        return true;
    }
    static ui void Activate(CaelumJournalOverlay view,CaelumPlayer user,int control)
    {
        let browser=user.CraftingBrowser;if(browser==null)return;
        if(control>=100)
        { view.SendNetworkEvent("ca_crafting_browser_select",control-100,browser.Serial);Scroll("ca_journal_craft_scroll",0); }
        else if(control>=1 && control<=3)Key(view,user,0,48+control);
        else if(control==10)Key(view,user,0,103);
        else if(control==11)Key(view,user,InputEvent.Key_Space,32);
        else if(control==12)Key(view,user,0,114);
        else if(control==13)Key(view,user,0,98);
        else if(control==14)Key(view,user,0,120);
        else if(control==15 || control==16)Key(view,user,control==15?InputEvent.Key_LeftArrow:InputEvent.Key_RightArrow,0);
        else if(control==17)Confirm(view,user);
        else if(control==18)Key(view,user,0,99);
        else if(control==19)view.JournalKey(InputEvent.Type_KeyDown,InputEvent.Key_Tab,0,"",user);
        else if(control==20 || control==21)Scroll("ca_journal_craft_scroll",control==20?-1:1);
        else if(control==22)view.SendNetworkEvent("ca_skip_open");
        else if(control==23)view.SendNetworkEvent("ca_time_fast");
    }
    static ui bool Mouse(CaelumJournalOverlay view,CaelumPlayer user,int type,Vector2 point)
    {
        if(CaelumProofingUI.Active(user))return CaelumProofingUI.Mouse(view,user,type,point);
        if(CaelumFermentationMenu.Active(user))return CaelumFermentationUI.Mouse(view,user,type,point);
        let pointer=CaelumJournalInput.PointerFor(4);
        pointer.Move(point);Layout(view,user,pointer,false);
        let browser=user.CraftingBrowser;if(browser==null)return true;
        if(type==UiEvent.Type_LButtonDown)pointer.Press(browser.Serial);
        else if(type==UiEvent.Type_LButtonUp)Activate(view,user,pointer.Release(browser.Serial));
        else if(type==UiEvent.Type_WheelUp || type==UiEvent.Type_WheelDown)
        {
            int direction=type==UiEvent.Type_WheelUp?-1:1;
            if(point.X<232){view.SendNetworkEvent("ca_crafting_browser_move",direction);Scroll("ca_journal_craft_scroll",0);}
            else Scroll("ca_journal_craft_scroll",direction);
            pointer.Reset();
        }
        return true;
    }
}
