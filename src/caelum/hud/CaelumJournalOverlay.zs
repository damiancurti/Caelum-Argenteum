// Primera capa definitiva del Diario. La navegación es local y no duplica el
// inventario real; las acciones autoritativas se conectarán por eventos cuando
// cada sección abandone su pantalla provisional.
class CaelumJournalOverlay : EventHandler
{
    const JOURNAL_PAGE_COUNT = 7;

    Font TitleFont;
    Font TextFont;
    Font SmallFont;
    Font InventoryFont;

    override void OnRegister()
    {
        TitleFont = Font.GetFont("CaelumDisplay");
        TextFont = Font.GetFont("CaelumText");
        SmallFont = Font.GetFont("CaelumSmall");
        // El inventario comparte exactamente la métrica monoespaciada del HUD.
        InventoryFont = Font.GetFont("CaelumMono");
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
        CaelumScheduleCalendar.Close();
        SetQuestDetailOpen(false);
        if (consoleplayer < 0) { return; }
        let held = CVar.GetCVar("ca_journal_quest_abandon_held", players[consoleplayer]);
        if (held != null) held.SetBool(false);
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
        CaelumScheduleCalendar.Close();
        SetQuestDetailOpen(false);
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

    ui bool IsQuestDetailOpen()
    {
        if (consoleplayer < 0) return false;
        let detailState = CVar.GetCVar("ca_journal_quest_detail", players[consoleplayer]);
        return detailState != null && detailState.GetBool();
    }

    ui void SetQuestDetailOpen(bool value)
    {
        if (consoleplayer < 0) return;
        let detailState = CVar.GetCVar("ca_journal_quest_detail", players[consoleplayer]);
        let scroll = CVar.GetCVar("ca_journal_quest_scroll", players[consoleplayer]);
        let confirm = CVar.GetCVar("ca_journal_quest_abandon", players[consoleplayer]);
        if (confirm != null) confirm.SetInt(-1);
        if (detailState != null) detailState.SetBool(value);
        if (scroll != null) scroll.SetInt(0);
    }

    ui int GetVisibleQuestId(CaelumPlayer localPlayer)
    {
        if (localPlayer == null) return -1;
        let selection = CVar.GetCVar("ca_journal_quest_selected", players[consoleplayer]);
        int chosen = selection == null ? 0 : selection.GetInt();
        if (chosen >= 0 && chosen < CaelumConstants.QUEST_DEFINED_COUNT
            && localPlayer.JournalQuestState[chosen] != CaelumConstants.QUEST_STATE_UNDISCOVERED)
            return chosen;
        for (int id = 0; id < CaelumConstants.QUEST_DEFINED_COUNT; id++)
            if (localPlayer.JournalQuestState[id] != CaelumConstants.QUEST_STATE_UNDISCOVERED) return id;
        return -1;
    }

    ui bool CycleQuest(CaelumPlayer user, int direction, bool leaveAtEdge = false)
    {
        int current = GetVisibleQuestId(user);
        if (current < 0)
        {
            if (leaveAtEdge) CycleJournalPage(direction);
            return false;
        }
        let selection = CVar.GetCVar("ca_journal_quest_selected", players[consoleplayer]);
        if (selection == null) return false;
        for (int step = 1; step <= CaelumConstants.QUEST_DEFINED_COUNT; step++)
        {
            int id = current + direction * step;
            if (leaveAtEdge && (id < 0 || id >= CaelumConstants.QUEST_DEFINED_COUNT))
            {
                CycleJournalPage(direction);
                return false;
            }
            id = (id + CaelumConstants.QUEST_DEFINED_COUNT * 2) % CaelumConstants.QUEST_DEFINED_COUNT;
            if (user.JournalQuestState[id] == CaelumConstants.QUEST_STATE_UNDISCOVERED) continue;
            selection.SetInt(id);
            SetQuestDetailOpen(false);
            return true;
        }
        return false;
    }

    // Cambiar de solapa no depende del filtro ni de la misión seleccionada.
    ui void CycleJournalPage(int direction)
    {
        let user = consoleplayer >= 0 ? CaelumPlayer(players[consoleplayer].mo) : null;
        if (GetJournalPage() == 3 && user != null && user.CraftingMenuOpen)
            SendNetworkEvent("ca_crafting_session_close");
        int nextPage = (GetJournalPage() + direction + JOURNAL_PAGE_COUNT)
            % JOURNAL_PAGE_COUNT;
        SetJournalPage(nextPage);
        SendNetworkEvent(nextPage == 3 ? "ca_crafting_page_turn_sound"
            : "ca_journal_menu_move_sound");
        if (nextPage == 0) SendNetworkEvent("ca_inventory_refresh");
        if (nextPage == 4 || nextPage == 5) SendNetworkEvent("ca_social_refresh");
    }

    // Ruta común de las teclas nativas: solapas, misiones y contexto de Oficios.
    ui bool HandleJournalNavigation(int keyScan)
    {
        bool next = keyScan == InputEvent.Key_PgDn || keyScan == InputEvent.Key_Pad_RShoulder;
        bool previous = keyScan == InputEvent.Key_PgUp || keyScan == InputEvent.Key_Pad_LShoulder;
        if (next || previous)
        {
            CycleJournalPage(next ? 1 : -1);
            return true;
        }
        next = keyScan == InputEvent.Key_RightArrow || keyScan == InputEvent.Key_Pad_DPad_Right;
        previous = keyScan == InputEvent.Key_LeftArrow || keyScan == InputEvent.Key_Pad_DPad_Left;
        if (!next && !previous) return false;
        let user = consoleplayer >= 0 ? CaelumPlayer(players[consoleplayer].mo) : null;
        if (GetJournalPage() == 3 && user != null && user.CraftingMenuOpen) return false;
        if (GetJournalPage() == 0)
        {
            bool atEdge = user == null || (next
                ? user.FormalInventoryFilter >= CaelumPlayer.FORMAL_INVENTORY_FILTER_COUNT - 1
                : user.FormalInventoryFilter <= 0);
            if (atEdge) CycleJournalPage(next ? 1 : -1);
            else
            {
                SendNetworkEvent(next ? "ca_inventory_filter" : "ca_inventory_filter_previous");
                SendNetworkEvent("ca_journal_menu_move_sound");
            }
        }
        else if (GetJournalPage() == 4)
        {
            if (CycleQuest(user, next ? 1 : -1, true))
                SendNetworkEvent("ca_journal_menu_move_sound");
        }
        else CycleJournalPage(next ? 1 : -1);
        return true;
    }

    ui String GetSideQuestHelp(CaelumPlayer user, int id)
    {
        let confirm = CVar.GetCVar("ca_journal_quest_abandon", players[consoleplayer]);
        if (confirm != null && confirm.GetInt() == id) return "CA_Q_SIDE_CONFIRM_ABANDON";
        if (user.JournalQuestState[id] == CaelumConstants.QUEST_STATE_OFFERED)
            return user.JournalQuestCanStart[id] ? "CA_Q_SIDE_ACCEPT" : "CA_Q_SIDE_LOCKED";
        if (user.JournalQuestState[id] == CaelumConstants.QUEST_STATE_ACTIVE)
            return user.JournalQuestReady[id] ? "CA_Q_SIDE_FINISH" : "CA_Q_SIDE_PROGRESS";
        if (user.JournalQuestState[id] == CaelumConstants.QUEST_STATE_COMPLETED)
            return user.JournalQuestRewardClaimed[id] ? "CA_Q_SIDE_REWARDED" : "CA_Q_SIDE_CLAIM";
        return "CA_Q_SIDE_TERMINAL";
    }

    static ui String GetQuestDetailStageKey(CaelumPlayer localPlayer, int questId)
    {
        if (localPlayer.JournalQuestState[questId] == CaelumConstants.QUEST_STATE_COMPLETED)
            return questId == CaelumConstants.QUEST_MAIN_M00_THE_FOOL ? "CA_M01_RETURN_DETAIL_COMPLETE" : "CA_Q_DETAIL_COMPLETE";
        if (localPlayer.JournalQuestState[questId] == CaelumConstants.QUEST_STATE_FAILED)
            return "CA_Q_DETAIL_FAILED";
        if (questId != CaelumConstants.QUEST_MAIN_M00_THE_FOOL)
            return "CA_Q_DETAIL_GENERIC";
        int stage = localPlayer.JournalQuestStage[questId];
        if (stage >= CaelumConstants.MAIN_M00_STATE_EXIT_CONFIRMED) return "CA_M01_RETURN_DETAIL_CROSSING";
        if (stage >= CaelumConstants.MAIN_M00_STATE_FOOL_CAPTURED) return "CA_M01_RETURN_DETAIL_READY";
        if (stage >= CaelumConstants.MAIN_M00_STATE_BOX_RECEIVED) return localPlayer.MainM00FoolRevealedSnapshot
            ? "CA_M01_FOOL_DETAIL_REVEALED" : "CA_M01_FOOL_DETAIL_FIND";
        if (stage >= CaelumConstants.MAIN_M00_STATE_RULO_COMPLETE) return "CA_M01_RULO_DETAIL_DONE";
        if (stage >= CaelumConstants.MAIN_M00_STATE_RULO_ACTIVE)
            return localPlayer.MainM00BullDefeatedSnapshot ? "CA_M01_RULO_DETAIL_RETURN"
                : localPlayer.MainM00BullStartedSnapshot ? "CA_M01_RULO_DETAIL_FIGHT"
                : localPlayer.MainM00RuloPracticeSnapshot < 6 ? "CA_M01_RULO_DETAIL_PRACTICE"
                : localPlayer.MainM00SilverKeySnapshot ? "CA_M01_RULO_DETAIL_DOOR" : "CA_M01_RULO_DETAIL_KEY";
        if (stage >= CaelumConstants.MAIN_M00_STATE_RONNIE_ACTIVE
            && stage < CaelumConstants.MAIN_M00_STATE_RULO_ACTIVE)
            return localPlayer.MainM00RonnieFinishedSnapshot ? "CA_M01_RULO_DETAIL_OFFER"
                : localPlayer.MainM00StarterWeaponSnapshot > 0 ? "CA_M01_DETAIL_READY" : "CA_M01_DETAIL_GATHER";
        if (stage >= CaelumConstants.MAIN_M00_STATE_CAELLA_COMPLETE)
            return stage < CaelumConstants.MAIN_M00_STATE_RONNIE_ACTIVE
                ? "CA_Q_DETAIL_M01_RONNIE" : "CA_Q_DETAIL_GENERIC";
        if (stage >= CaelumConstants.MAIN_M00_STATE_CAELLA_ACTIVE)
            return localPlayer.MainM00RuneSequenceSnapshot == 4 ? "CA_Q_DETAIL_M01_RETURN_CAELLA"
                : localPlayer.MainM00MagicPracticeSnapshot < 5
                ? "CA_Q_DETAIL_M01_PRACTICE" : "CA_Q_DETAIL_M01_RUNES";
        if (stage >= CaelumConstants.MAIN_M00_STATE_ARGENTO_COMPLETE)
            return "CA_Q_DETAIL_M01_CAELLA";
        if (stage >= CaelumConstants.MAIN_M00_STATE_ARGENTO_ACTIVE)
        {
            if (localPlayer.MainM00ConvincedCountSnapshot == CaelumConstants.MAIN_M00_RESIDENT_COUNT)
                return "CA_Q_DETAIL_M01_RETURN_ARGENTO";
            return localPlayer.JournalMainM00ArgentoStarted
                ? "CA_Q_DETAIL_M01_RESIDENTS" : "CA_Q_DETAIL_M01_ARGENTO";
        }
        return "CA_Q_DETAIL_M01_PALOMO";
    }

    // Sólo lee la instantánea del registro. Abrir Detalle no inicia, completa
    // ni concede nada; las indicaciones cambian con el progreso del personaje.
    static ui String GetRuloDefenseKey(CaelumPlayer user, bool checklist = false)
    {
        if (user.HUDActiveWeaponIsRanged)
            return checklist ? "CA_M01_RULO_CHECK_AIM" : "CA_M01_RULO_DEFENSE_AIM";
        if (user.HUDHasActiveBlockSource)
            return checklist ? "CA_M01_RULO_CHECK_BLOCK" : "CA_M01_RULO_DEFENSE_BLOCK";
        if (!checklist && user.HUDHasActiveWeapon
            && user.HUDActiveWeaponType == CaelumConstants.WEAPON_TYPE_GREATSWORD)
            return "CA_M01_RULO_DEFENSE_GREATSWORD";
        return checklist ? "CA_M01_RULO_CHECK_EVADE" : "CA_M01_RULO_DEFENSE_EVADE";
    }

    ui String GetQuestDetailText(CaelumPlayer localPlayer, int questId)
    {
        if (CaelumSideQuestRules.IsDefined(questId))
        {
            int state = localPlayer.JournalQuestState[questId];
            String key = state == CaelumConstants.QUEST_STATE_FAILED ? "CA_Q_SIDE_DETAIL_FAILED"
                : state == CaelumConstants.QUEST_STATE_ABANDONED ? "CA_Q_SIDE_DETAIL_ABANDONED"
                : state == CaelumConstants.QUEST_STATE_COMPLETED ? "CA_Q_SIDE_DETAIL_COMPLETE"
                : questId == CaelumConstants.QUEST_TRIAL_ROUTE ? "CA_Q_SIDE_DETAIL_ROUTE" : "CA_Q_SIDE_DETAIL_WAIT";
            return StringTable.Localize(key, false) .. "\n\n"
                .. StringTable.Localize(GetSideQuestHelp(localPlayer, questId), false)
                .. "\n\n" .. StringTable.Localize("CA_Q_SIDE_REWARD_NOTE", false);
        }
        String text = StringTable.Localize("CA_QUEST_STAGE_LABEL", false) .. ": "
            .. StringTable.Localize(GetQuestDetailStageKey(localPlayer, questId), false);
        text.Replace("%COUNT%", String.Format("%d", localPlayer.MainM00ConvincedCountSnapshot));
        text.Replace("%MAGIC_COUNT%", String.Format("%d", localPlayer.MainM00MagicPracticeSnapshot));
        text.Replace("%RUNES%", String.Format("%d", localPlayer.MainM00RuneSequenceSnapshot));
        text.Replace("%STARTER%", CaelumMainM00StarterRules.GetName(localPlayer.MainM00StarterOptionSnapshot));
        int stage = localPlayer.JournalQuestStage[questId];
        if (questId == CaelumConstants.QUEST_MAIN_M00_THE_FOOL
            && stage == CaelumConstants.MAIN_M00_STATE_RULO_ACTIVE && localPlayer.MainM00RuloPracticeSnapshot < 6)
        {
            for (int n = 0; n < 6; n++)
            {
                String key = n == 0 ? "CA_M01_RULO_CHECK_PRIMARY" : n == 1 ? "CA_M01_RULO_CHECK_SECONDARY"
                    : n == 2 ? GetRuloDefenseKey(localPlayer, true) : n == 3 ? "CA_M01_RULO_CHECK_ADVANCED"
                    : n == 4 ? "CA_M01_RULO_CHECK_AIR" : "CA_M01_RULO_CHECK_RECOVERY";
                text = text .. "\n" .. StringTable.Localize(localPlayer.JournalMainM00RuloPracticeDone[n]
                    ? "CA_Q_DETAIL_DONE" : "CA_Q_DETAIL_PENDING", false) .. ": " .. StringTable.Localize(key, false);
            }
            text = text .. "\n\n" .. StringTable.Localize("CA_M01_RULO_EQUIVALENT_TEXT", false);
        }
        if (questId == CaelumConstants.QUEST_MAIN_M00_THE_FOOL
            && localPlayer.MainM00StarterOptionSnapshot == 15
            && stage >= CaelumConstants.MAIN_M00_STATE_RONNIE_ACTIVE
            && stage < CaelumConstants.MAIN_M00_STATE_EXIT_CONFIRMED)
            text = text .. "\n\n" .. StringTable.Localize("CA_M01_BOLTS_DETAIL", false);
        if (questId == CaelumConstants.QUEST_MAIN_M00_THE_FOOL
            && stage >= CaelumConstants.MAIN_M00_STATE_RONNIE_ACTIVE
            && stage < CaelumConstants.MAIN_M00_STATE_EXIT_CONFIRMED)
        {
            String armorText = StringTable.Localize(localPlayer.MainM00ArmorTypeSnapshot < 0
                ? "CA_M01_ARMOR_DETAIL_CHOOSE" : "CA_M01_ARMOR_DETAIL", false);
            armorText.Replace("%ARMOR%", StringTable.Localize(String.Format("CA_M01_ARMOR_NAME_%d",
                Max(0, localPlayer.MainM00ArmorTypeSnapshot)), false));
            armorText.Replace("%PIECES%", String.Format("%d", localPlayer.MainM00ArmorPiecesSnapshot));
            text = text .. "\n\n" .. armorText;
        }
        if (questId == CaelumConstants.QUEST_MAIN_M00_THE_FOOL
            && stage >= CaelumConstants.MAIN_M00_STATE_CAELLA_COMPLETE
            && stage < CaelumConstants.MAIN_M00_STATE_EXIT_CONFIRMED)
        {
            String sealText = StringTable.Localize("CA_AF_ACCESSORY_DETAIL", false);
            sealText.Replace("%SEAL%", localPlayer.MainM00ChosenSealSnapshot < 0 ? "-"
                : StringTable.Localize(String.Format("CA_AF_SEAL_%d", localPlayer.MainM00ChosenSealSnapshot), false));
            sealText.Replace("%AMULET%", localPlayer.MainM00ChosenAmuletSnapshot < 0 ? "-"
                : StringTable.Localize(String.Format("CA_AF_AMULET_%d", localPlayer.MainM00ChosenAmuletSnapshot), false));
            sealText.Replace("%SEALS%", String.Format("%d", localPlayer.MainM00SealsPreparedSnapshot));
            sealText.Replace("%AMULETDONE%", localPlayer.MainM00AmuletPreparedSnapshot ? "1" : "0");
            text = text .. "\n\n" .. sealText;
            if (localPlayer.MainM00WaterGivenSnapshot)
            {
                String water = StringTable.Localize("CA_WATER_DETAIL", false);
                water.Replace("%FILLED%", localPlayer.MainM00WaterFilledSnapshot ? "1/1" : "0/1");
                water.Replace("%DRANK%", localPlayer.MainM00WaterDrankSnapshot ? "1/1" : "0/1");
                text = text .. "\n\n" .. water;
            }
        }
        bool magicActive = questId == CaelumConstants.QUEST_MAIN_M00_THE_FOOL
            && localPlayer.JournalQuestState[questId] == CaelumConstants.QUEST_STATE_ACTIVE
            && stage >= CaelumConstants.MAIN_M00_STATE_CAELLA_ACTIVE
            && stage < CaelumConstants.MAIN_M00_STATE_CAELLA_COMPLETE;
        if (magicActive)
        {
            text = text .. "\n\n" .. StringTable.Localize("CA_Q_DETAIL_LOCATION", false)
                .. "\n" .. StringTable.Localize("CA_DLG_M01_MAGIC_LOCATION", false)
                .. "\n\n" .. StringTable.Localize("CA_Q_DETAIL_PRACTICE", false);
            for (int practiceAction = 0; practiceAction < 5; practiceAction++)
            {
                String key = practiceAction == 0 ? "CA_Q_DETAIL_PRIMARY"
                    : practiceAction == 1 ? "CA_Q_DETAIL_SECONDARY"
                    : practiceAction == 2 ? "CA_Q_DETAIL_CHANNEL"
                    : practiceAction == 3 ? "CA_Q_DETAIL_ANIMA_SPENT" : "CA_Q_DETAIL_ANIMA_RECOVERED";
                text = text .. "\n" .. StringTable.Localize(
                    localPlayer.JournalMainM00MagicPracticeDone[practiceAction]
                        ? "CA_Q_DETAIL_DONE" : "CA_Q_DETAIL_PENDING", false)
                    .. ": " .. StringTable.Localize(key, false);
            }
            if (localPlayer.MainM00MagicPracticeSnapshot >= 5)
            {
                String riddle = StringTable.Localize("CA_DLG_M01_MAGIC_RIDDLE", false);
                riddle.Replace("%RUNES%", String.Format("%d", localPlayer.MainM00RuneSequenceSnapshot));
                text = text .. "\n\n" .. riddle;
            }
        }
        if (questId == CaelumConstants.QUEST_MAIN_M00_THE_FOOL
            && stage >= CaelumConstants.MAIN_M00_STATE_RONNIE_ACTIVE
            && stage < CaelumConstants.MAIN_M00_STATE_RULO_ACTIVE
            && localPlayer.MainM00StarterWeaponSnapshot == 0)
        {
            text = text .. "\n\n" .. StringTable.Localize("CA_M01_RONNIE_LOCATION", false)
                .. "\n\n" .. StringTable.Localize("CA_M01_DETAIL_MATERIALS", false);
            for (int i = 0; i < CaelumConstants.MATERIAL_TYPE_COUNT; i++)
            {
                if (localPlayer.MainM00StarterRequiredSnapshot[i] <= 0) continue;
                text = text .. "\n" .. StringTable.Localize(CaelumDisplayNames.GetSpecialItemKey(
                    CaelumConstants.EQUIPMENT_KIND_MATERIAL, i), false)
                    .. String.Format(": %d (%s %d)", localPlayer.MainM00StarterRequiredSnapshot[i],
                        StringTable.Localize("CA_M01_DETAIL_MISSING", false), localPlayer.MainM00StarterMissingSnapshot[i]);
            }
            text = text .. "\n\n" .. StringTable.Localize("CA_M01_DETAIL_LOAD", false);
        }
        if (questId == CaelumConstants.QUEST_MAIN_M00_THE_FOOL
            && localPlayer.MainM00RepairLessonOfferedSnapshot
            && (stage < CaelumConstants.MAIN_M00_STATE_EXIT_CONFIRMED
                || localPlayer.MainM00RepairLessonCompleteSnapshot))
        {
            text = text .. "\n\n" .. StringTable.Localize(localPlayer.MainM00RepairLessonCompleteSnapshot
                ? "CA_M01_REPAIR_DETAIL_DONE" : "CA_M01_REPAIR_DETAIL", false);
        }
        if (questId == CaelumConstants.QUEST_MAIN_M00_THE_FOOL
            && localPlayer.MainM00NeedsLessonStartedSnapshot
            && (stage < CaelumConstants.MAIN_M00_STATE_EXIT_CONFIRMED
                || (localPlayer.MainM00NeedsFoodUsedSnapshot && localPlayer.MainM00NeedsWaterUsedSnapshot)))
        {
            text = text .. "\n\n" .. StringTable.Localize("CA_M01_NEEDS_DETAIL", false)
                .. "\n" .. StringTable.Localize(localPlayer.MainM00NeedsFoodUsedSnapshot ? "CA_M01_NEEDS_FOOD_DONE" : "CA_M01_NEEDS_FOOD_WAIT", false)
                .. "\n" .. StringTable.Localize(localPlayer.MainM00NeedsWaterUsedSnapshot ? "CA_M01_NEEDS_WATER_DONE" : "CA_M01_NEEDS_WATER_WAIT", false);
        }
        if (questId == CaelumConstants.QUEST_MAIN_M00_THE_FOOL
            && localPlayer.MainM00AirLessonStartedSnapshot
            && (stage < CaelumConstants.MAIN_M00_STATE_EXIT_CONFIRMED || localPlayer.MainM00AirLessonCompleteSnapshot))
            text = text .. "\n\n" .. StringTable.Localize(localPlayer.MainM00AirLessonCompleteSnapshot
                ? "CA_M01_AIR_DETAIL_DONE" : localPlayer.MainM00AirLessonRanSnapshot
                ? "CA_M01_AIR_DETAIL_RECOVER" : "CA_M01_AIR_DETAIL_RUN", false);
        if (questId == CaelumConstants.QUEST_MAIN_M00_THE_FOOL
            && localPlayer.MainM00LoadLessonStartedSnapshot
            && (stage < CaelumConstants.MAIN_M00_STATE_EXIT_CONFIRMED || localPlayer.MainM00LoadLessonCompleteSnapshot))
            text = text .. "\n\n" .. StringTable.Localize(localPlayer.MainM00LoadLessonCompleteSnapshot
                ? "CA_M01_LOAD_DETAIL_DONE" : "CA_M01_LOAD_DETAIL", false);
        if (questId == CaelumConstants.QUEST_MAIN_M00_THE_FOOL
            && localPlayer.MainM00SwimLessonStartedSnapshot
            && (stage < CaelumConstants.MAIN_M00_STATE_EXIT_CONFIRMED || localPlayer.MainM00SwimLessonCompleteSnapshot))
            text = text .. "\n\n" .. StringTable.Localize(localPlayer.MainM00SwimLessonCompleteSnapshot
                ? "CA_M01_SWIM_DETAIL_DONE" : localPlayer.MainM00SwimLessonSubmergedSnapshot
                ? "CA_M01_SWIM_DETAIL_RECOVER" : "CA_M01_SWIM_DETAIL_DIVE", false);
        text = text .. "\n\n" .. StringTable.Localize("CA_Q_DETAIL_ABOUT", false)
            .. "\n" .. StringTable.Localize(questId == CaelumConstants.QUEST_MAIN_M00_THE_FOOL
                ? "CA_Q_DETAIL_M01_ABOUT" : "CA_Q_DETAIL_GENERIC", false);
        text.Replace("%DEFENSE%", StringTable.Localize(GetRuloDefenseKey(localPlayer), false));
        return text;
    }

    ui int GetQuestDetailLineCount()
    {
        return Max(1, int(134 / Max(12, SmallFont.GetHeight() + 2)));
    }

    ui void ScrollQuestDetail(CaelumPlayer localPlayer, int direction)
    {
        int questId = GetVisibleQuestId(localPlayer);
        if (questId < 0 || SmallFont == null) return;
        let lines = SmallFont.BreakLines(GetQuestDetailText(localPlayer, questId), 512);
        int count = GetQuestDetailLineCount();
        int last = Max(0, (lines.Count() - 1) / count) * count;
        let scroll = CVar.GetCVar("ca_journal_quest_scroll", players[consoleplayer]);
        if (scroll != null) scroll.SetInt(Clamp(scroll.GetInt() + direction * count, 0, last));
    }

    ui void DrawQuestDetail(CaelumPlayer localPlayer)
    {
        int questId = GetVisibleQuestId(localPlayer);
        if (questId < 0) return;
        DrawTextLine(TextFont, Font.CR_GOLD, 64, 132,
            StringTable.Localize("CA_Q_DETAIL_TITLE", false) .. " - "
            .. StringTable.Localize(GetQuestNameKey(questId), false));
        let lines = SmallFont.BreakLines(GetQuestDetailText(localPlayer, questId), 512);
        int count = GetQuestDetailLineCount();
        int pages = Max(1, (lines.Count() + count - 1) / count);
        let scroll = CVar.GetCVar("ca_journal_quest_scroll", players[consoleplayer]);
        int first = Clamp(scroll != null ? scroll.GetInt() : 0, 0, (pages - 1) * count);
        for (int row = 0; row < count && first + row < lines.Count(); row++)
            DrawTextLine(SmallFont, Font.CR_WHITE, 64,
                156 + row * Max(12, SmallFont.GetHeight() + 2), lines.StringAt(first + row));
        DrawCenteredText(SmallFont, Font.CR_GRAY, 320, 298,
            String.Format("%d / %d", first / count + 1, pages));
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
            case 6: return "CA_JOURNAL_TAROT";
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
            case 6: return "graphics/caelum/ui/journal/icons/ca_ui_slot_tarot.png";
            default: return "graphics/caelum/ui/journal/icons/ca_ui_nav_inventory.png";
        }
    }

    ui String GetQuestNameKey(int questId)
    {
        switch (questId)
        {
            case CaelumConstants.QUEST_MAIN_M00_THE_FOOL:
                return "CA_Q_M01_TITLE";
            case CaelumConstants.QUEST_TRIAL_ROUTE: return "CA_Q_SIDE_ROUTE_TITLE";
            case CaelumConstants.QUEST_TRIAL_WAIT: return "CA_Q_SIDE_WAIT_TITLE";
            default: return "CA_JOURNAL_QUESTS";
        }
    }

    ui String GetQuestStateKey(int questState)
    {
        switch (questState)
        {
            case CaelumConstants.QUEST_STATE_COMPLETED:
                return "CA_QUEST_STATUS_COMPLETED";
            case CaelumConstants.QUEST_STATE_FAILED:
                return "CA_QUEST_STATUS_FAILED";
            case CaelumConstants.QUEST_STATE_OFFERED: return "CA_QUEST_STATUS_OFFERED";
            case CaelumConstants.QUEST_STATE_ABANDONED: return "CA_QUEST_STATUS_ABANDONED";
            default: return "CA_QUEST_STATUS_ACTIVE";
        }
    }

    ui String GetQuestStageKey(int questId, int questStage, bool argentoStarted, int residents)
    {
        if (questId != CaelumConstants.QUEST_MAIN_M00_THE_FOOL)
        {
            return "CA_Q_SIDE_STAGE";
        }
        if (questStage >= CaelumConstants.MAIN_M00_STATE_COMPLETE)
            return "CA_Q_M01_STATE_COMPLETE";
        if (questStage >= CaelumConstants.MAIN_M00_STATE_EXIT_CONFIRMED)
            return "CA_Q_M01_STATE_RETURN_TO_BODY";
        if (questStage >= CaelumConstants.MAIN_M00_STATE_FOOL_CAPTURED)
            return "CA_M01_FOOL_STATE_OBTAINED";
        if (questStage >= CaelumConstants.MAIN_M00_STATE_BOX_RECEIVED)
            return "CA_M01_FOOL_STATE_FIND";
        if (questStage >= CaelumConstants.MAIN_M00_STATE_RULO_COMPLETE)
            return "CA_Q_M01_STATE_PALOMO_FINAL";
        if (questStage >= CaelumConstants.MAIN_M00_STATE_RULO_ACTIVE)
            return "CA_Q_M01_STATE_RULO_COMBAT";
        if (questStage >= CaelumConstants.MAIN_M00_STATE_WEAPON_READY)
            return "CA_Q_M01_STATE_PREPARE_WEAPON";
        if (questStage >= CaelumConstants.MAIN_M00_STATE_RONNIE_ACTIVE)
            return "CA_Q_M01_STATE_RONNIE_SURVIVAL";
        if (questStage >= CaelumConstants.MAIN_M00_STATE_CAELLA_COMPLETE)
            return "CA_Q_M01_STATE_TALK_RONNIE";
        if (questStage >= CaelumConstants.MAIN_M00_STATE_CAELLA_ACTIVE)
            return "CA_Q_M01_STATE_CAELLA_MAGIC";
        if (questStage >= CaelumConstants.MAIN_M00_STATE_ARGENTO_COMPLETE)
            return "CA_Q_M01_STATE_TALK_CAELLA";
        if (questStage >= CaelumConstants.MAIN_M00_STATE_ARGENTO_ACTIVE)
        {
            if (residents == CaelumConstants.MAIN_M00_RESIDENT_COUNT)
                return "CA_Q_M01_STATE_RETURN_ARGENTO";
            return argentoStarted ? "CA_Q_M01_STATE_RECRUIT_RESIDENTS"
                : "CA_Q_M01_STATE_ARGENTO_SOCIAL";
        }
        if (questStage >= CaelumConstants.MAIN_M00_STATE_MET_PALOMO)
            return "CA_Q_M01_STATE_MEET_PALOMO";
        if (questStage >= CaelumConstants.MAIN_M00_STATE_AWAKENED)
            return "CA_Q_M01_STATE_AWAKEN";
        return "CA_Q_M01_STATE_INITIALIZE";
    }

    ui String GetQuestObjectiveKey(int questId, int objectiveId)
    {
        if (questId != CaelumConstants.QUEST_MAIN_M00_THE_FOOL)
        {
            return questId == CaelumConstants.QUEST_TRIAL_ROUTE
                ? "CA_Q_SIDE_ROUTE_OBJECTIVE" : "CA_Q_SIDE_WAIT_OBJECTIVE";
        }
        switch (objectiveId)
        {
            case CaelumConstants.MAIN_M00_OBJECTIVE_FIND_HELP:
                return "CA_Q_M01_OBJ_FIND_HELP";
            case CaelumConstants.MAIN_M00_OBJECTIVE_CONVINCE_RESIDENTS:
                return "CA_Q_M01_OBJ_CONVINCE_RESIDENTS";
            case CaelumConstants.MAIN_M00_OBJECTIVE_SOLVE_RIDDLE:
                return "CA_Q_M01_OBJ_SOLVE_RIDDLE";
            case CaelumConstants.MAIN_M00_OBJECTIVE_GATHER_MATERIALS:
                return "CA_Q_M01_OBJ_GATHER_MATERIALS";
            case CaelumConstants.MAIN_M00_OBJECTIVE_PREPARE_WEAPON:
                return "CA_Q_M01_OBJ_PREPARE_WEAPON";
            case CaelumConstants.MAIN_M00_OBJECTIVE_DEFEAT_BULL:
                return "CA_Q_M01_OBJ_DEFEAT_BULL";
            case CaelumConstants.MAIN_M00_OBJECTIVE_CAPTURE_FOOL:
                return "CA_Q_M01_OBJ_CAPTURE_FOOL";
            default: return "CA_Q_M01_OBJ_LEAVE_MANSION";
        }
    }

    ui String GetFactionNameKey(int factionId)
    {
        switch (factionId)
        {
            case CaelumConstants.FACTION_UNITARIOS:
                return "CA_FACTION_UNITARIOS";
            case CaelumConstants.FACTION_FEDERALS:
                return "CA_FACTION_FEDERALS";
            case CaelumConstants.FACTION_PUEBLOS_LIBRES:
                return "CA_FACTION_PUEBLOS_LIBRES";
            case CaelumConstants.FACTION_CAELITH:
                return "CA_FACTION_CAELITH";
            case CaelumConstants.FACTION_CULT_TAROT:
                return "CA_FACTION_CULT_TAROT";
            case CaelumConstants.FACTION_SUN_WARRIORS:
                return "CA_FACTION_SUN_WARRIORS";
            default: return "CA_REP_UNKNOWN_FACTION";
        }
    }

    ui String GetPalomoPlacementKey(int placement)
    {
        switch (placement)
        {
            case CaelumConstants.PALOMO_PLACEMENT_MANSION_FOYER:
                return "CA_PALOMO_PLACEMENT_MANSION_FOYER";
            case CaelumConstants.PALOMO_PLACEMENT_MANSION_UPSTAIRS:
                return "CA_PALOMO_PLACEMENT_MANSION_UPSTAIRS";
            default: return "CA_PALOMO_PLACEMENT_HIDDEN";
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

    ui String GetInventoryCategoryIconPath(int category)
    {
        if (category == 9)
        {
            return "graphics/caelum/icons/currency/ca_coin_silver.png";
        }
        return "graphics/caelum/ui/journal/icons/"
            .. GetInventoryCategoryIcon(category);
    }

    ui String GetInventoryFilterKey(int category)
    {
        switch (category)
        {
            case 1: return "CA_JOURNAL_FILTER_WEAPONS";
            case 2: return "CA_JOURNAL_FILTER_ARMOR";
            case 3: return "CA_JOURNAL_FILTER_SHIELDS";
            case 4: return "CA_JOURNAL_FILTER_ACCESSORIES";
            case 5: return "CA_JOURNAL_FILTER_CONSUMABLES";
            case 6: return "CA_JOURNAL_FILTER_MATERIALS";
            case 7: return "CA_JOURNAL_FILTER_AMMUNITION";
            case 8: return "CA_JOURNAL_FILTER_KEY_ITEMS";
            case 9: return "CA_JOURNAL_FILTER_CURRENCY";
            default: return "CA_JOURNAL_FILTER_ALL";
        }
    }

    ui String GetCraftingFilterKey(int recipeFilter)
    {
        switch (recipeFilter)
        {
            case CaelumConstants.CRAFTING_RECIPE_FILTER_PHYSICAL_WEAPON:
                return "CA_CRAFTING_FILTER_PHYSICAL_WEAPONS";
            case CaelumConstants.CRAFTING_RECIPE_FILTER_ARMOR:
                return "CA_CRAFTING_FILTER_ARMOR";
            case CaelumConstants.CRAFTING_RECIPE_FILTER_SHIELD:
                return "CA_CRAFTING_FILTER_SHIELDS";
            case CaelumConstants.CRAFTING_RECIPE_FILTER_ESSENCE_WEAPON:
                return "CA_CRAFTING_FILTER_ESSENCE_WEAPONS";
            case CaelumConstants.CRAFTING_RECIPE_FILTER_AMULET:
                return "CA_CRAFTING_FILTER_AMULETS";
            case CaelumConstants.CRAFTING_RECIPE_FILTER_SEAL:
                return "CA_CRAFTING_FILTER_SEALS";
            case CaelumConstants.CRAFTING_RECIPE_FILTER_PROCESSING:
                return "CA_CRAFTING_FILTER_PROCESSING";
            case CaelumConstants.CRAFTING_RECIPE_FILTER_AMMUNITION:
                return "CA_CRAFTING_FILTER_AMMUNITION";
            case CaelumConstants.CRAFTING_RECIPE_FILTER_COMPONENT:
                return "CA_CRAFTING_FILTER_COMPONENTS";
            default: return "CA_CRAFTING_FILTER_ALL";
        }
    }

    ui String GetCraftingActionKey(int craftingAction)
    {
        switch (craftingAction)
        {
            case CaelumConstants.CRAFTING_ACTION_CREATED:
                return "CA_CRAFTING_ACTION_CREATED";
            case CaelumConstants.CRAFTING_ACTION_FAILED_MATERIALS:
                return "CA_CRAFTING_ACTION_FAILED_MATERIALS";
            case CaelumConstants.CRAFTING_ACTION_FAILED_BOX_FULL:
                return "CA_CRAFTING_ACTION_FAILED_BOX_FULL";
            case CaelumConstants.CRAFTING_ACTION_FAILED_DUPLICATE:
                return "CA_CRAFTING_ACTION_FAILED_DUPLICATE";
            case CaelumConstants.CRAFTING_ACTION_MATERIALS_SPAWNED:
                return "CA_CRAFTING_ACTION_MATERIALS_SPAWNED";
            case CaelumConstants.CRAFTING_ACTION_FAILED_STATION:
                return "CA_CRAFTING_ACTION_FAILED_STATION";
            case CaelumConstants.CRAFTING_ACTION_FAILED_INFRASTRUCTURE:
                return "CA_CRAFTING_ACTION_FAILED_INFRASTRUCTURE";
            case CaelumConstants.CRAFTING_ACTION_FAILED_RECIPE_LOCKED:
                return "CA_CRAFTING_ACTION_FAILED_RECIPE_LOCKED";
            case CaelumConstants.CRAFTING_ACTION_PROCESSED:
                return "CA_CRAFTING_ACTION_PROCESSED";
            case CaelumConstants.CRAFTING_ACTION_TASK_STARTED:
                return "CA_CRAFTING_ACTION_TASK_STARTED";
            case CaelumConstants.CRAFTING_ACTION_TASK_CANCELLED:
                return "CA_CRAFTING_ACTION_TASK_CANCELLED";
            case CaelumConstants.CRAFTING_ACTION_FAILED_TASK_ACTIVE:
                return "CA_CRAFTING_ACTION_FAILED_TASK_ACTIVE";
            case CaelumConstants.CRAFTING_ACTION_FAILED_COMBAT:
                return "CA_CRAFTING_ACTION_FAILED_COMBAT";
            case CaelumConstants.CRAFTING_ACTION_FAILED_TARGET:
                return "CA_CRAFTING_ACTION_FAILED_TARGET";
            case CaelumConstants.CRAFTING_ACTION_FAILED_CARRY_CAPACITY:
                return "CA_CRAFTING_ACTION_FAILED_CARRY_CAPACITY";
            case CaelumConstants.CRAFTING_ACTION_REPAIRED:
                return "CA_CRAFTING_ACTION_REPAIRED";
            case CaelumConstants.CRAFTING_ACTION_DISMANTLED:
                return "CA_CRAFTING_ACTION_DISMANTLED";
            case CaelumConstants.CRAFTING_ACTION_DEBUG_TIME_ADVANCED:
                return "CA_CRAFTING_ACTION_DEBUG_TIME_ADVANCED";
            case CaelumConstants.CRAFTING_ACTION_DEBUG_TIME_BLOCKED:
                return "CA_CRAFTING_ACTION_DEBUG_TIME_BLOCKED";
            default: return "CA_CRAFTING_ACTION_NONE";
        }
    }

    ui String GetEssenceKey(int essenceType)
    {
        switch (essenceType)
        {
            case CaelumConstants.ESSENCE_WATER: return "CA_ESSENCE_WATER";
            case CaelumConstants.ESSENCE_EARTH: return "CA_ESSENCE_EARTH";
            case CaelumConstants.ESSENCE_WIND: return "CA_ESSENCE_WIND";
            case CaelumConstants.ESSENCE_QUINTESSENCE:
                return "CA_ESSENCE_QUINTESSENCE";
            default: return "CA_ESSENCE_FIRE";
        }
    }

    ui String GetEquipmentActionKey(int actionCode)
    {
        switch (actionCode)
        {
            case CaelumConstants.EQUIPMENT_ACTION_CREATED:
                return "CA_EQUIPMENT_ACTION_CREATED";
            case CaelumConstants.EQUIPMENT_ACTION_EQUIPPED:
                return "CA_EQUIPMENT_ACTION_EQUIPPED";
            case CaelumConstants.EQUIPMENT_ACTION_UNEQUIPPED:
                return "CA_EQUIPMENT_ACTION_UNEQUIPPED";
            case CaelumConstants.EQUIPMENT_ACTION_BROKEN:
                return "CA_EQUIPMENT_ACTION_BROKEN";
            case CaelumConstants.EQUIPMENT_ACTION_DROPPED:
                return "CA_EQUIPMENT_ACTION_DROPPED";
            case CaelumConstants.EQUIPMENT_ACTION_FAILED_NOT_OWNED:
                return "CA_EQUIPMENT_ACTION_FAILED_NOT_OWNED";
            case CaelumConstants.EQUIPMENT_ACTION_FAILED_SIZE:
                return "CA_EQUIPMENT_ACTION_FAILED_SIZE";
            case CaelumConstants.EQUIPMENT_ACTION_FAILED_BOX_FULL:
                return "CA_EQUIPMENT_ACTION_FAILED_BOX_FULL";
            case CaelumConstants.EQUIPMENT_ACTION_CREATED_IN_MAGIC_BOX:
                return "CA_EQUIPMENT_ACTION_CREATED_IN_MAGIC_BOX";
            case CaelumConstants.EQUIPMENT_ACTION_FAILED_CARRY_CAPACITY:
                return "CA_EQUIPMENT_ACTION_FAILED_CARRY_CAPACITY";
            case CaelumConstants.EQUIPMENT_ACTION_STORED_IN_MAGIC_BOX:
                return "CA_EQUIPMENT_ACTION_STORED_IN_MAGIC_BOX";
            case CaelumConstants.EQUIPMENT_ACTION_RETRIEVED_FROM_MAGIC_BOX:
                return "CA_EQUIPMENT_ACTION_RETRIEVED_FROM_MAGIC_BOX";
            case CaelumConstants.EQUIPMENT_ACTION_USED:
                return "CA_EQUIPMENT_ACTION_USED";
            case CaelumConstants.EQUIPMENT_ACTION_FAILED_KEY_STORAGE:
                return "CA_EQUIPMENT_ACTION_FAILED_KEY_STORAGE";
            case CaelumConstants.EQUIPMENT_ACTION_FAILED_STORAGE:
                return "CA_EQUIPMENT_ACTION_FAILED_STORAGE";
            case CaelumConstants.EQUIPMENT_ACTION_DISMANTLED:
                return "CA_EQUIPMENT_ACTION_DISMANTLED";
            case CaelumConstants.EQUIPMENT_ACTION_FAILED_EQUIPPED:
                return "CA_EQUIPMENT_ACTION_FAILED_EQUIPPED";
            case CaelumConstants.EQUIPMENT_ACTION_FAILED_DISMANTLE_UNSUPPORTED:
                return "CA_EQUIPMENT_ACTION_FAILED_DISMANTLE_UNSUPPORTED";
            case CaelumConstants.EQUIPMENT_ACTION_REPAIR_STARTED:
                return "CA_EQUIPMENT_ACTION_REPAIR_STARTED";
            case CaelumConstants.EQUIPMENT_ACTION_REPAIRED:
                return "CA_EQUIPMENT_ACTION_REPAIRED";
            case CaelumConstants.EQUIPMENT_ACTION_DISMANTLE_STARTED:
                return "CA_EQUIPMENT_ACTION_DISMANTLE_STARTED";
            case CaelumConstants.EQUIPMENT_ACTION_FAILED_CRAFTING_TASK:
                return "CA_EQUIPMENT_ACTION_FAILED_CRAFTING_TASK";
            case CaelumConstants.EQUIPMENT_ACTION_FAILED_COMBAT:
                return "CA_EQUIPMENT_ACTION_FAILED_COMBAT";
            case CaelumConstants.EQUIPMENT_ACTION_FAILED_DURABILITY:
                return "CA_EQUIPMENT_ACTION_FAILED_DURABILITY";
            case CaelumConstants.EQUIPMENT_ACTION_FAILED_INFRASTRUCTURE:
                return "CA_EQUIPMENT_ACTION_FAILED_INFRASTRUCTURE";
            case CaelumConstants.EQUIPMENT_ACTION_FAILED_RESERVED:
                return "CA_EQUIPMENT_ACTION_FAILED_RESERVED";
            case CaelumConstants.EQUIPMENT_ACTION_FAILED_MATERIALS:
                return "CA_EQUIPMENT_ACTION_FAILED_MATERIALS";
            case CaelumConstants.EQUIPMENT_ACTION_FAILED_MAGIC_BOX_UNOWNED:
                return "CA_EQUIPMENT_ACTION_FAILED_MAGIC_BOX_UNOWNED";
            case CaelumConstants.EQUIPMENT_ACTION_FAILED_RECIPE_LOCKED:
                return "CA_CRAFTING_RECIPE_UNKNOWN";
            default: return "CA_EQUIPMENT_ACTION_NONE";
        }
    }

    ui String GetPalomoMerchantItemKey(int merchantItem)
    {
        switch (merchantItem)
        {
            case CaelumConstants.PALOMO_MERCHANT_ITEM_FOOD:
                return "CA_CONSUMABLE_FOOD_RATION";
            case CaelumConstants.PALOMO_MERCHANT_ITEM_WATER:
                return "CA_CONSUMABLE_WATER_RATION";
            case CaelumConstants.PALOMO_MERCHANT_ITEM_WOOD:
                return "CA_MATERIAL_WOOD";
            case CaelumConstants.PALOMO_MERCHANT_ITEM_RAW_COPPER:
                return "CA_MATERIAL_RAW_COPPER";
            case CaelumConstants.PALOMO_MERCHANT_ITEM_RAW_TIN:
                return "CA_MATERIAL_RAW_TIN";
            default:
                return "CA_PALOMO_MERCHANT_UNKNOWN_ITEM";
        }
    }

    ui String GetPalomoMerchantActionKey(int actionCode)
    {
        switch (actionCode)
        {
            case CaelumConstants.PALOMO_MERCHANT_ACTION_BOUGHT:
                return "CA_PALOMO_MERCHANT_ACTION_BOUGHT";
            case CaelumConstants.PALOMO_MERCHANT_ACTION_SOLD:
                return "CA_PALOMO_MERCHANT_ACTION_SOLD";
            case CaelumConstants.PALOMO_MERCHANT_ACTION_FAILED_STOCK:
                return "CA_PALOMO_MERCHANT_ACTION_FAILED_STOCK";
            case CaelumConstants.PALOMO_MERCHANT_ACTION_FAILED_PLAYER_MONEY:
                return "CA_PALOMO_MERCHANT_ACTION_FAILED_PLAYER_MONEY";
            case CaelumConstants.PALOMO_MERCHANT_ACTION_FAILED_PLAYER_STOCK:
                return "CA_PALOMO_MERCHANT_ACTION_FAILED_PLAYER_STOCK";
            case CaelumConstants.PALOMO_MERCHANT_ACTION_FAILED_MERCHANT_MONEY:
                return "CA_PALOMO_MERCHANT_ACTION_FAILED_MERCHANT_MONEY";
            case CaelumConstants.PALOMO_MERCHANT_ACTION_FAILED_CAPACITY:
                return "CA_PALOMO_MERCHANT_ACTION_FAILED_CAPACITY";
            case CaelumConstants.PALOMO_MERCHANT_ACTION_FAILED_RESERVED:
                return "CA_PALOMO_MERCHANT_ACTION_FAILED_RESERVED";
            case CaelumConstants.PALOMO_MERCHANT_ACTION_FAILED_SESSION:
                return "CA_PALOMO_MERCHANT_ACTION_FAILED_SESSION";
            case CaelumConstants.PALOMO_MERCHANT_ACTION_PRICE_CHANGED:
                return "CA_REP_TRADE_PRICE_CHANGED";
            default:
                return "CA_PALOMO_MERCHANT_ACTION_NONE";
        }
    }

    ui String FormatInventoryEntryName(
        int kind, int itemType, int armorSlot, int tier, int equipmentSize,
        int essenceType
    )
    {
        String sizeName = StringTable.Localize(
            CaelumDisplayNames.GetEquipmentSizeKey(equipmentSize), false
        );
        if (kind == CaelumConstants.EQUIPMENT_KIND_WEAPON)
        {
            String weaponName =
                CaelumDisplayNames.FormatWeaponName(itemType, tier);
            if (itemType == CaelumConstants.WEAPON_TYPE_STAFF
                || itemType == CaelumConstants.WEAPON_TYPE_BELL
                || itemType == CaelumConstants.WEAPON_TYPE_BOOK
                || itemType == CaelumConstants.WEAPON_TYPE_STATUETTE)
            {
                return String.Format(
                    "%s · %s · %s", weaponName, sizeName,
                    StringTable.Localize(GetEssenceKey(essenceType), false)
                );
            }
            return String.Format("%s · %s", weaponName, sizeName);
        }
        if (kind == CaelumConstants.EQUIPMENT_KIND_ARMOR)
        {
            return String.Format(
                "%s · %s · %s",
                CaelumDisplayNames.FormatArmorTypeName(itemType, tier),
                StringTable.Localize(
                    CaelumDisplayNames.GetArmorSlotKey(armorSlot), false
                ),
                sizeName
            );
        }
        if (kind == CaelumConstants.EQUIPMENT_KIND_SHIELD)
        {
            return String.Format(
                "%s · %s",
                CaelumDisplayNames.FormatShieldName(itemType, tier), sizeName
            );
        }
        if (kind == CaelumConstants.EQUIPMENT_KIND_AMULET)
        {
            return CaelumDisplayNames.FormatAmuletName(itemType, tier);
        }
        if (kind == CaelumConstants.EQUIPMENT_KIND_SEAL)
        {
            return CaelumDisplayNames.FormatSealName(itemType, tier);
        }
        if (kind == CaelumConstants.EQUIPMENT_KIND_CONSUMABLE)
        {
            return StringTable.Localize(
                CaelumDisplayNames.GetConsumableKey(itemType), false
            );
        }
        if (kind == CaelumConstants.EQUIPMENT_KIND_AMMUNITION)
        {
            return StringTable.Localize(
                CaelumDisplayNames.GetAmmunitionKey(itemType), false
            );
        }
        String specialName = StringTable.Localize(
            CaelumDisplayNames.GetSpecialItemKey(kind, itemType), false
        );
        if (kind == CaelumConstants.EQUIPMENT_KIND_MATERIAL && tier > 0)
        {
            return String.Format("%s · T%d", specialName, tier);
        }
        return specialName;
    }

    ui String GetWeaponNameKey(int weaponType)
    {
        return CaelumDisplayNames.GetWeaponKey(weaponType);
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

    ui void DrawTextLine(Font font, int textColor, double x, double y,
        String text)
    {
        if (font == null) { return; }
        Screen.DrawText(
            font, textColor, x, y, text,
            DTA_VIRTUALWIDTHF, 640.0,
            DTA_VIRTUALHEIGHTF, 360.0,
            DTA_KEEPRATIO, true,
            DTA_SHADOW, true
        );
    }

    ui void DrawParagraph(Font font, int textColor, double x, double y,
        int width, String text)
    {
        if (font == null) return;
        let lines = font.BreakLines(text, width);
        for (int row = 0; row < lines.Count(); row++)
            DrawTextLine(font, textColor, x, y + row * Max(12, font.GetHeight() + 2),
                lines.StringAt(row));
        lines.Destroy();
    }

    ui void DrawCenteredText(Font font, int textColor, double centerX,
        double y, String text)
    {
        if (font == null) { return; }
        DrawTextLine(
            font,
            textColor,
            centerX - font.StringWidth(text) * 0.5,
            y,
            text
        );
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
            double centerX = 68.0 + page * 84.0;
            String laurel = page == currentPage
                ? "graphics/caelum/ui/journal/components/ca_ui_nav_laurel_selected.png"
                : "graphics/caelum/ui/journal/components/ca_ui_nav_laurel_normal.png";
            String frame = page == currentPage
                ? "graphics/caelum/ui/hud/components/ca_ui_icon_frame_selected.png"
                : "graphics/caelum/ui/hud/components/ca_ui_icon_frame_normal.png";
            // El laurel comparte la caja del marco y siempre se compone detrás.
            DrawTexture(laurel, centerX - 24.0, 38.0, 48.0, 48.0);
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
        for (int index = 0;
            index < CaelumPlayer.FORMAL_INVENTORY_FILTER_COUNT; index++)
        {
            DrawTexture(
                GetInventoryCategoryIconPath(index),
                54.0 + index * 57.0,
                124.0,
                28.0,
                28.0,
                index == localPlayer.FormalInventoryFilter ? 1.0 : 0.35
            );
        }
        DrawTextLine(
            InventoryFont, Font.CR_GOLD, 52.0, 151.0,
            String.Format(
                "%s · %d",
                StringTable.Localize(
                    GetInventoryFilterKey(localPlayer.FormalInventoryFilter),
                    false
                ),
                localPlayer.FormalInventoryEntryCount
            )
        );

        int selectedRow = localPlayer.FormalInventorySelectionIndex
            - localPlayer.FormalInventoryVisibleStart;
        for (int row = 0;
            row < CaelumPlayer.FORMAL_INVENTORY_VISIBLE_ROWS; row++)
        {
            int kind = localPlayer.FormalInventoryRowKind[row];
            if (kind < 0) { continue; }
            String entryLabel = FormatInventoryEntryName(
                kind,
                localPlayer.FormalInventoryRowType[row],
                localPlayer.FormalInventoryRowArmorSlot[row],
                localPlayer.FormalInventoryRowTier[row],
                localPlayer.FormalInventoryRowSize[row],
                localPlayer.FormalInventoryRowEssenceType[row]
            );
            if (localPlayer.FormalInventoryRowItemId[row] > 0)
            {
                entryLabel = String.Format(
                    "%s  #%d", entryLabel,
                    localPlayer.FormalInventoryRowItemId[row]
                );
            }
            else
            {
                entryLabel = String.Format(
                    "%s  x%d", entryLabel,
                    localPlayer.FormalInventoryRowAmount[row]
                );
            }
            if (localPlayer.FormalInventoryRowWaterLiters[row] >= 0)
                entryLabel = entryLabel .. String.Format("  %.2f L", localPlayer.FormalInventoryRowWaterLiters[row]);
            if (localPlayer.FormalInventoryRowEquipped[row])
            {
                entryLabel = entryLabel .. "  [E]";
            }
            if (localPlayer.FormalInventoryRowInMagicBox[row])
            {
                entryLabel = entryLabel .. "  [M]";
            }
            if (localPlayer.FormalInventoryRowReservedUnits[row] > 0)
            {
                entryLabel = String.Format(
                    "%s  [R:%d]",
                    entryLabel,
                    localPlayer.FormalInventoryRowReservedUnits[row]
                );
            }
            DrawTextLine(
                InventoryFont,
                row == selectedRow ? Font.CR_GOLD : Font.CR_WHITE,
                52.0,
                170.0 + row * 21.0,
                (row == selectedRow ? "> " : "  ") .. entryLabel
            );
        }

        if (localPlayer.FormalInventoryEntryCount <= 0)
        {
            DrawTextLine(
                InventoryFont, Font.CR_GRAY, 52.0, 190.0,
                StringTable.Localize("CA_JOURNAL_INVENTORY_EMPTY", false)
            );
        }

        DrawTextLine(InventoryFont, Font.CR_WHITE, 414.0, 170.0,
            String.Format("%s: %.3f / %.3f",
                StringTable.Localize("CA_HUD_LOAD", false),
                localPlayer.HUDCarriedWeight,
                localPlayer.HUDCarryCapacity));
        DrawTexture(
            "graphics/caelum/ui/journal/icons/ca_ui_magic_box.png",
            414.0, 188.0, 16.0, 16.0,
            localPlayer.MagicBoxOwned ? 1.0 : 0.35
        );
        if (localPlayer.MagicBoxOwned)
        {
            DrawTextLine(InventoryFont, Font.CR_WHITE, 432.0, 190.0,
                String.Format("%s: %d/%d · %.3f kg",
                    StringTable.Localize("CA_EQUIPMENT_MAGIC_BOX", false),
                    localPlayer.MagicBoxUsedSlots,
                    localPlayer.MagicBoxMaximumSlots,
                    localPlayer.HUDMagicBoxTotalWeight));
        }
        else
        {
            DrawTextLine(InventoryFont, Font.CR_GRAY, 432.0, 190.0,
                String.Format("%s: %s",
                    StringTable.Localize("CA_EQUIPMENT_MAGIC_BOX", false),
                    StringTable.Localize(
                        "CA_MAGIC_BOX_NOT_ACQUIRED", false
                    )));
        }
        DrawTextLine(InventoryFont, Font.CR_GOLD, 414.0, 210.0,
            String.Format("%s: %.0f c",
                StringTable.Localize("CA_ECONOMY_TOTAL_MONEY", false),
                localPlayer.HUDTotalMoneyCopperValue));
        DrawTexture(
            "graphics/caelum/icons/currency/ca_coin_copper.png",
            414.0, 229.0, 16.0, 16.0
        );
        DrawTextLine(
            InventoryFont, Font.CR_WHITE, 432.0, 230.0,
            String.Format("%d", localPlayer.HUDCopperCoinCount)
        );
        DrawTexture(
            "graphics/caelum/icons/currency/ca_coin_silver.png",
            480.0, 229.0, 16.0, 16.0
        );
        DrawTextLine(
            InventoryFont, Font.CR_WHITE, 498.0, 230.0,
            String.Format("%d", localPlayer.HUDSilverCoinCount)
        );
        DrawTexture(
            "graphics/caelum/icons/currency/ca_coin_gold.png",
            546.0, 229.0, 16.0, 16.0
        );
        DrawTextLine(
            InventoryFont, Font.CR_WHITE, 564.0, 230.0,
            String.Format("%d", localPlayer.HUDGoldCoinCount)
        );
        if (selectedRow >= 0
            && selectedRow < CaelumPlayer.FORMAL_INVENTORY_VISIBLE_ROWS
            && localPlayer.FormalInventoryRowKind[selectedRow] >= 0)
        {
            DrawTextLine(InventoryFont, Font.CR_WHITE, 414.0, 258.0,
                String.Format("%s: %.3f",
                    StringTable.Localize(
                        "CA_JOURNAL_INVENTORY_WEIGHT", false
                    ),
                    localPlayer.FormalInventoryRowWeight[selectedRow]));
            if (localPlayer.FormalInventoryRowMaximumDurability[selectedRow]
                > 0)
            {
                DrawTextLine(InventoryFont, Font.CR_WHITE, 414.0, 278.0,
                    String.Format("%s: %d / %d",
                        StringTable.Localize(
                            "CA_JOURNAL_INVENTORY_DURABILITY", false
                        ),
                        localPlayer.FormalInventoryRowDurability[selectedRow],
                        localPlayer.FormalInventoryRowMaximumDurability[
                            selectedRow
                        ]));
            }
        }
        DrawTextLine(
            InventoryFont,
            localPlayer.LastEquipmentAction
                    == CaelumConstants.EQUIPMENT_ACTION_NONE
                ? Font.CR_GRAY : Font.CR_GOLD,
            52.0, 298.0,
            StringTable.Localize(
                GetEquipmentActionKey(localPlayer.LastEquipmentAction), false
            )
        );
        if (localPlayer.CraftingTaskActive)
        {
            DrawTextLine(
                InventoryFont, Font.CR_CYAN, 414.0, 298.0,
                String.Format(
                    "%s: %.1f / %.1f s",
                    StringTable.Localize("CA_CRAFTING_TASK_ACTIVE", false),
                    localPlayer.CraftingTaskRemainingSeconds,
                    localPlayer.CraftingTaskTotalSeconds
                )
            );
        }
    }

    ui void DrawCharacterPage(CaelumPlayer localPlayer)
    {
        if (localPlayer.Attributes == null) { return; }
        CaelumAttributes values = localPlayer.Attributes;
        DrawTextLine(TextFont, Font.CR_WHITE, 56.0, 132.0,
            String.Format("%s: %.2f | %s: %.2f | %s: %.2f",
                StringTable.Localize("CA_ATTRIBUTE_STRENGTH", false), values.Strength,
                StringTable.Localize("CA_ATTRIBUTE_TOUGHNESS", false), values.Toughness,
                StringTable.Localize("CA_ATTRIBUTE_CONSTITUTION", false), values.Constitution));
        DrawTextLine(TextFont, Font.CR_WHITE, 56.0, 164.0,
            String.Format("%s: %.2f | %s: %.2f | %s: %.2f",
                StringTable.Localize("CA_ATTRIBUTE_AGILITY", false), values.Agility,
                StringTable.Localize("CA_ATTRIBUTE_DEXTERITY", false), values.Dexterity,
                StringTable.Localize("CA_ATTRIBUTE_RESILIENCE", false), values.Resilience));
        DrawTextLine(TextFont, Font.CR_WHITE, 56.0, 196.0,
            String.Format("%s: %.2f | %s: %.2f | %s: %.2f",
                StringTable.Localize("CA_ATTRIBUTE_CHARISMA", false), values.Charisma,
                StringTable.Localize("CA_ATTRIBUTE_EMPATHY", false), values.Empathy,
                StringTable.Localize("CA_ATTRIBUTE_ELOQUENCE", false), values.Eloquence));
        DrawTextLine(TextFont, Font.CR_WHITE, 56.0, 228.0,
            String.Format("%s: %.2f | %s: %.2f | %s: %.2f",
                StringTable.Localize("CA_ATTRIBUTE_INTELLIGENCE", false), values.Intelligence,
                StringTable.Localize("CA_ATTRIBUTE_PATIENCE", false), values.Patience,
                StringTable.Localize("CA_ATTRIBUTE_INSIGHT", false), values.Insight));
        DrawTextLine(SmallFont, Font.CR_GOLD, 56.0, 270.0,
            String.Format(StringTable.Localize("CA_TAROT_BONUS", false), localPlayer.TarotAttributeBonusSnapshot));
    }

    ui void DrawTarotPage(CaelumPlayer localPlayer)
    {
        bool owned = localPlayer.TarotFoolOwnedSnapshot;
        DrawTextLine(SmallFont, Font.CR_GOLD, 56, 130,
            String.Format(StringTable.Localize("CA_TAROT_COLLECTION_COUNT", false),
                localPlayer.TarotOwnedCountSnapshot, CaelumConstants.TAROT_CARD_COUNT));
        if (localPlayer.TarotOwnedCountSnapshot <= 0)
        {
            DrawTexture("graphics/caelum/icons/ca_tarot_back.png", 78, 166, 100, 100);
            DrawParagraph(TextFont, Font.CR_WHITE, 226, 170, 330,
                StringTable.Localize("CA_TAROT_COLLECTION_EMPTY", false));
            return;
        }
        // El Diario usa un lienzo virtual 640x360. Encajar la carta sin
        // estirarla cuando la ventana real es 4:3 o ultrapanorámica.
        double ratio = (double(Screen.GetWidth()) / Screen.GetHeight()) / (640.0 / 360.0);
        double cardWidth = 104 / Max(1.0, ratio);
        double cardHeight = 156 * Min(1.0, ratio);
        DrawTexture(owned && !localPlayer.TarotCupsAceOwnedSnapshot ? "graphics/caelum/tarot/ca_tarot_fool.png"
            : "graphics/caelum/icons/ca_tarot_back.png",
            76 + (104-cardWidth)*0.5, 151 + (156-cardHeight)*0.5, cardWidth, cardHeight);
        DrawTextLine(TextFont, Font.CR_GOLD, 210, 157,
            StringTable.Localize(localPlayer.TarotCupsAceOwnedSnapshot ? "CA_MAZE_CUPS_ACE" : owned ? "CA_TAROT_FOOL_NAME" : "CA_TAROT_COLLECTION_LABEL", false));
        bool hasMinorBonus = false;
        for (int attribute = 0; attribute < CaelumConstants.PRIMARY_ATTRIBUTE_COUNT; attribute++)
            if (localPlayer.TarotMinorBaseSnapshot[attribute] > 0.0) hasMinorBonus = true;
        if (hasMinorBonus)
        {
            DrawTextLine(SmallFont, Font.CR_WHITE, 210, 181,
                StringTable.Localize("CA_TAROT_MINOR_ORDER", false));
            for (int family = 0; family < CaelumConstants.ATTRIBUTE_LAYER_COUNT; family++)
            {
                String key = family == CaelumConstants.LAYER_PHYSICAL ? "CA_LAYER_PHYSICAL"
                    : family == CaelumConstants.LAYER_TECHNICAL ? "CA_LAYER_TECHNICAL"
                    : family == CaelumConstants.LAYER_SOCIAL ? "CA_LAYER_SOCIAL" : "CA_LAYER_MENTAL";
                int first = family * 3;
                DrawTextLine(SmallFont, Font.CR_WHITE, 210, 201 + family * 18,
                    String.Format("%s: +%.1f / +%.1f / +%.1f", StringTable.Localize(key, false),
                        localPlayer.TarotMinorBaseSnapshot[first],
                        localPlayer.TarotMinorBaseSnapshot[first + 1],
                        localPlayer.TarotMinorBaseSnapshot[first + 2]));
            }
            DrawParagraph(SmallFont, Font.CR_GOLD, 210, 282, 352,
                String.Format(StringTable.Localize("CA_TAROT_COLLECTION_FACTOR", false),
                    localPlayer.TarotAttributeBonusSnapshot));
            return;
        }
        DrawParagraph(SmallFont, Font.CR_WHITE, 210, 183, 352,
            StringTable.Localize(owned ? "CA_TAROT_FOOL_DESCRIPTION" : "CA_TAROT_COLLECTION_RULE", false));
        DrawParagraph(SmallFont, Font.CR_GOLD, 210, 244, 352,
            String.Format(StringTable.Localize("CA_TAROT_BONUS", false), localPlayer.TarotAttributeBonusSnapshot));
    }

    ui void DrawQuestPage(CaelumPlayer localPlayer)
    {
        if (IsQuestDetailOpen()) { DrawQuestDetail(localPlayer); return; }
        if (localPlayer.JournalKnownQuestCount <= 0)
        {
            DrawCenteredText(
                TextFont, Font.CR_WHITE, 320.0, 164.0,
                StringTable.Localize("CA_JOURNAL_QUESTS_EMPTY", false)
            );
        }
        else
        {
            for (int questId = 0;
                questId < CaelumConstants.QUEST_DEFINED_COUNT; questId++)
            {
                int questState = localPlayer.JournalQuestState[questId];
                if (questState == CaelumConstants.QUEST_STATE_UNDISCOVERED
                    || questId != GetVisibleQuestId(localPlayer))
                {
                    continue;
                }

                DrawTextLine(
                    TextFont, Font.CR_GOLD, 64.0, 132.0,
                    StringTable.Localize(GetQuestNameKey(questId), false)
                );
                DrawTextLine(
                    SmallFont, Font.CR_WHITE, 64.0, 158.0,
                    String.Format(
                        "%s: %s  |  %s: %s",
                        StringTable.Localize("CA_QUEST_STATUS_LABEL", false),
                        StringTable.Localize(
                            GetQuestStateKey(questState), false
                        ),
                        StringTable.Localize("CA_QUEST_STAGE_LABEL", false),
                        StringTable.Localize(
                            GetQuestStageKey(
                                questId,
                                localPlayer.JournalQuestStage[questId],
                                localPlayer.JournalMainM00ArgentoStarted,
                                localPlayer.MainM00ConvincedCountSnapshot
                            ),
                            false
                        )
                    )
                );
                DrawTextLine(
                    SmallFont, Font.CR_GRAY, 64.0, 190.0,
                    StringTable.Localize("CA_QUEST_OBJECTIVES_LABEL", false)
                );

                int objectiveBase = questId
                    * CaelumConstants.QUEST_OBJECTIVE_CAPACITY;
                for (int objectiveId = 0;
                    objectiveId < CaelumConstants.QUEST_OBJECTIVE_CAPACITY;
                    objectiveId++)
                {
                    int objective = objectiveBase + objectiveId;
                    if (objective
                            >= CaelumConstants.QUEST_JOURNAL_OBJECTIVE_STORAGE_COUNT
                        || !localPlayer.JournalQuestObjectiveKnown[objective])
                    {
                        continue;
                    }
                    int progress =
                        localPlayer.JournalQuestObjectiveProgress[objective];
                    int target = Max(
                        1,
                        localPlayer.JournalQuestObjectiveTarget[objective]
                    );
                    DrawTextLine(
                        SmallFont,
                        progress >= target ? Font.CR_GREEN : Font.CR_WHITE,
                        56.0 + (objectiveId / 4)*284.0, 208.0 + (objectiveId % 4)*18.0,
                        String.Format(
                            "[%d/%d] %s",
                            progress, target,
                            StringTable.Localize(
                                questId == CaelumConstants.QUEST_MAIN_M00_THE_FOOL
                                    && objectiveId == CaelumConstants.MAIN_M00_OBJECTIVE_CAPTURE_FOOL
                                    && !localPlayer.MainM00FoolRevealedSnapshot
                                    ? "CA_M01_FOOL_STATE_FIND" : GetQuestObjectiveKey(questId, objectiveId),
                                false
                            )
                        )
                    );
                }
                break;
            }
        }

        int selected = GetVisibleQuestId(localPlayer);
        if (selected >= 0)
        {
            int ordinal = 0;
            for (int id = 0; id <= selected; id++)
                if (localPlayer.JournalQuestState[id] != CaelumConstants.QUEST_STATE_UNDISCOVERED) ordinal++;
            DrawCenteredText(SmallFont, Font.CR_GRAY, 560, 132,
                String.Format("%d/%d", ordinal, localPlayer.JournalKnownQuestCount));
        }
        if (CaelumSideQuestRules.IsDefined(selected))
        {
            DrawCenteredText(SmallFont, Font.CR_WHITE, 320, 288,
                StringTable.Localize(GetSideQuestHelp(localPlayer, selected), false));
            return;
        }
        DrawTextLine(
            SmallFont, Font.CR_WHITE, 56.0, 288.0,
            String.Format(
                "%s: %s",
                StringTable.Localize(
                    "CA_QUEST_PALOMO_LOCATION_LABEL", false
                ),
                StringTable.Localize(
                    GetPalomoPlacementKey(
                        localPlayer.JournalPalomoPlacement
                    ),
                    false
                )
            )
        );
        DrawCenteredText(
            SmallFont, Font.CR_GRAY, 320.0, 304.0,
            StringTable.Localize(localPlayer.TarotFoolOwnedSnapshot
                ? "CA_M01_FOOL_HINT_DONE"
                : localPlayer.JournalQuestStage[CaelumConstants.QUEST_MAIN_M00_THE_FOOL]
                    >= CaelumConstants.MAIN_M00_STATE_BOX_RECEIVED
                    ? "CA_M01_FOOL_HINT_FIND" : "CA_QUEST_FOUNDATION_NOTE", false)
        );
    }

    ui void DrawReputationPage(CaelumPlayer localPlayer)
    {
        for (int factionId = 0;
            factionId < CaelumConstants.FACTION_COUNT; factionId++)
        {
            double rowY = 132.0 + factionId * 40.0;
            DrawTextLine(
                TextFont, Font.CR_GOLD, 64.0, rowY,
                StringTable.Localize(GetFactionNameKey(factionId), false)
            );
            DrawTextLine(
                SmallFont, Font.CR_WHITE, 250.0, rowY + 4.0,
                String.Format(
                    "%s: %s  |  %s: %d",
                    StringTable.Localize(
                        "CA_FACTION_MEMBERSHIP_LABEL", false
                    ),
                    StringTable.Localize(
                        localPlayer.JournalFactionMember[factionId]
                            ? "CA_FACTION_MEMBER_YES"
                            : "CA_FACTION_MEMBER_NO",
                        false
                    ),
                    StringTable.Localize(
                        "CA_REPUTATION_VALUE_LABEL", false
                    ),
                    localPlayer.JournalFactionReputation[factionId]
                )
            );
        }
        DrawCenteredText(
            SmallFont, Font.CR_GRAY, 320.0, 298.0,
            StringTable.Localize(
                localPlayer.JournalReputationTrialEnabled
                    ? "CA_REP_TRIAL_JOURNAL_HINT" : "CA_REPUTATION_FOUNDATION_NOTE", false
            )
        );
    }

    ui void DrawCraftingSummary(CaelumPlayer localPlayer)
    {
        DrawCenteredText(
            TextFont,
            Font.CR_GOLD,
            320.0,
            136.0,
            String.Format(
                "%s: %d / %d",
                StringTable.Localize("CA_CRAFTING_RECIPE_BOOK", false),
                localPlayer.CraftingKnownRecipeCount,
                CaelumConstants.CRAFTING_NETWORK_PLAYABLE_RECIPE_COUNT
            )
        );
        DrawTextLine(TextFont, Font.CR_WHITE, 84.0, 176.0,
            String.Format("%s: %d / %d",
                StringTable.Localize(
                    "CA_CRAFTING_FILTER_PHYSICAL_WEAPONS", false
                ),
                localPlayer.CraftingKnownPhysicalRecipeCount,
                CaelumConstants.CRAFTING_NETWORK_PHYSICAL_RECIPE_COUNT));
        DrawTextLine(TextFont, Font.CR_WHITE, 344.0, 176.0,
            String.Format("%s: %d / %d",
                StringTable.Localize("CA_CRAFTING_FILTER_ARMOR", false),
                localPlayer.CraftingKnownArmorRecipeCount,
                CaelumConstants.CRAFTING_NETWORK_ARMOR_RECIPE_COUNT));
        DrawTextLine(TextFont, Font.CR_WHITE, 84.0, 204.0,
            String.Format("%s: %d / %d",
                StringTable.Localize(
                    "CA_CRAFTING_FILTER_ESSENCE_WEAPONS", false
                ),
                localPlayer.CraftingKnownEssenceRecipeCount,
                CaelumConstants.CRAFTING_NETWORK_ESSENCE_RECIPE_COUNT));
        DrawTextLine(TextFont, Font.CR_WHITE, 344.0, 204.0,
            String.Format("%s: %d / %d",
                StringTable.Localize("CA_CRAFTING_FILTER_AMULETS", false),
                localPlayer.CraftingKnownAmuletRecipeCount,
                CaelumConstants.CRAFTING_NETWORK_AMULET_RECIPE_COUNT));
        DrawTextLine(TextFont, Font.CR_WHITE, 84.0, 232.0,
            String.Format("%s: %d / %d",
                StringTable.Localize("CA_CRAFTING_FILTER_SEALS", false),
                localPlayer.CraftingKnownSealRecipeCount,
                CaelumConstants.CRAFTING_NETWORK_SEAL_RECIPE_COUNT));
        DrawTextLine(TextFont, Font.CR_WHITE, 344.0, 232.0,
            String.Format("%s: %d / %d",
                StringTable.Localize("CA_CRAFTING_FILTER_SHIELDS", false),
                localPlayer.CraftingKnownShieldRecipeCount,
                CaelumConstants.CRAFTING_NETWORK_SHIELD_RECIPE_COUNT));
        DrawTextLine(TextFont, Font.CR_WHITE, 84.0, 260.0,
            String.Format("%s: %d / %d",
                StringTable.Localize(
                    "CA_CRAFTING_FILTER_PROCESSING", false
                ),
                localPlayer.CraftingKnownProcessingRecipeCount,
                CaelumConstants.CRAFTING_NETWORK_PROCESSING_RECIPE_COUNT));
        DrawTextLine(TextFont, Font.CR_WHITE, 344.0, 260.0,
            String.Format("%s: %d / %d",
                StringTable.Localize(
                    "CA_CRAFTING_FILTER_COMPONENTS", false
                ),
                localPlayer.CraftingKnownComponentRecipeCount,
                CaelumConstants.CRAFTING_NETWORK_COMPONENT_RECIPE_COUNT));
        if (localPlayer.CraftingTaskActive)
        {
            DrawCenteredText(
                SmallFont, Font.CR_CYAN, 320.0, 282.0,
                String.Format(
                    "%s: %.1f / %.1f s",
                    StringTable.Localize("CA_CRAFTING_TASK_ACTIVE", false),
                    localPlayer.CraftingTaskRemainingSeconds,
                    localPlayer.CraftingTaskTotalSeconds
                )
            );
        }
        DrawCenteredText(SmallFont, Font.CR_GRAY, 320.0,
            localPlayer.CraftingTaskActive ? 304.0 : 288.0,
            StringTable.Localize("CA_JOURNAL_CRAFTS_STATION_HELP", false));
    }

    ui String FormatCraftingRecipeName(CaelumPlayer localPlayer)
    {
        if (!localPlayer.CraftingSelectedRecipeKnown)
        {
            return StringTable.Localize("CA_CRAFTING_RECIPE_UNKNOWN", false);
        }
        if (localPlayer.CraftingSelectedRecipeKind == CaelumConstants.CRAFTING_RECIPE_KIND_AMMUNITION)
            return StringTable.Localize(localPlayer.CraftingSelectionRecipe == CaelumConstants.CRAFTING_BOLT_RECIPE
                ? "CA_CRAFTING_TEN_BOLTS" : "CA_CRAFTING_TEN_ARROWS", false);
        if (localPlayer.CraftingSelectedRecipeKind
            == CaelumConstants.CRAFTING_RECIPE_KIND_ARMOR)
        {
            return String.Format(
                "%s · %s",
                CaelumDisplayNames.FormatArmorTypeName(
                    localPlayer.CraftingSelectedArmorType,
                    localPlayer.CraftingSelectionTier
                ),
                StringTable.Localize(
                    CaelumDisplayNames.GetArmorSlotKey(
                        localPlayer.CraftingSelectedArmorSlot
                    ),
                    false
                )
            );
        }
        if (localPlayer.CraftingSelectedRecipeKind
            == CaelumConstants.CRAFTING_RECIPE_KIND_SHIELD)
        {
            return CaelumDisplayNames.FormatShieldName(
                localPlayer.CraftingSelectedShieldType,
                localPlayer.CraftingSelectionTier
            );
        }
        if (localPlayer.CraftingSelectedRecipeKind
            == CaelumConstants.CRAFTING_RECIPE_KIND_ESSENCE_WEAPON)
        {
            return String.Format(
                "%s · %s",
                CaelumDisplayNames.FormatWeaponName(
                    localPlayer.CraftingSelectedEssenceWeaponType,
                    localPlayer.CraftingSelectionTier
                ),
                StringTable.Localize(
                    GetEssenceKey(localPlayer.CraftingSelectedEssenceType),
                    false
                )
            );
        }
        if (localPlayer.CraftingSelectedRecipeKind
            == CaelumConstants.CRAFTING_RECIPE_KIND_AMULET)
        {
            return CaelumDisplayNames.FormatAmuletName(
                localPlayer.CraftingSelectedAmuletType,
                localPlayer.CraftingSelectionTier
            );
        }
        if (localPlayer.CraftingSelectedRecipeKind
            == CaelumConstants.CRAFTING_RECIPE_KIND_SEAL)
        {
            return CaelumDisplayNames.FormatSealName(
                localPlayer.CraftingSelectedSealType,
                localPlayer.CraftingSelectionTier
            );
        }
        if (localPlayer.CraftingSelectedRecipeKind
                == CaelumConstants.CRAFTING_RECIPE_KIND_PROCESSING
            || localPlayer.CraftingSelectedRecipeKind
                == CaelumConstants.CRAFTING_RECIPE_KIND_COMPONENT)
        {
            return FormatInventoryEntryName(
                CaelumConstants.EQUIPMENT_KIND_MATERIAL,
                localPlayer.CraftingOutputMaterialType,
                -1,
                localPlayer.CraftingOutputMaterialTier,
                CaelumConstants.EQUIPMENT_SIZE_M,
                CaelumConstants.ESSENCE_FIRE
            );
        }
        return CaelumDisplayNames.FormatCatalogueWeaponName(
            localPlayer.CraftingSelectedWeapon,
            localPlayer.CraftingSelectionTier
        );
    }

    ui int GetCraftingEfficiencyPercentForIndex(int efficiencyIndex)
    {
        if (efficiencyIndex == 1)
        {
            return CaelumConstants.CRAFTING_EFFICIENCY_CAREFUL_PERCENT;
        }
        if (efficiencyIndex == 2)
        {
            return CaelumConstants.CRAFTING_EFFICIENCY_PERFECT_PERCENT;
        }
        return CaelumConstants.CRAFTING_EFFICIENCY_FAST_PERCENT;
    }

    ui String FormatCraftingBlueprintNodeName(
        CaelumPlayer localPlayer, int node
    )
    {
        if (localPlayer.CraftingBlueprintNodeKind[node]
            == CaelumConstants.CRAFTING_BLUEPRINT_NODE_FINAL)
        {
            return StringTable.Localize(
                "CA_JOURNAL_CRAFTING_FINAL_STEP", false
            );
        }
        return FormatInventoryEntryName(
            CaelumConstants.EQUIPMENT_KIND_MATERIAL,
            localPlayer.CraftingBlueprintNodeMaterialType[node],
            -1,
            localPlayer.CraftingBlueprintNodeMaterialTier[node],
            CaelumConstants.EQUIPMENT_SIZE_M,
            CaelumConstants.ESSENCE_FIRE
        );
    }

    ui void DrawCraftingBlueprint(CaelumPlayer localPlayer)
    {
        int visibleRows = 4;
        int nodeCount = localPlayer.CraftingBlueprintNodeCount;
        if (nodeCount <= 0) { return; }
        int selected = Clamp(
            localPlayer.CraftingBlueprintSelectedNode,
            0, nodeCount - 1
        );
        int visibleStart = Clamp(
            selected - 1,
            0, Max(0, nodeCount - visibleRows)
        );

        DrawTextLine(
            SmallFont, Font.CR_GRAY, 52.0, 212.0,
            String.Format(
                "%s  ·  %s %d/%d",
                StringTable.Localize(
                    "CA_JOURNAL_CRAFTING_BREAKDOWN", false
                ),
                StringTable.Localize(
                    "CA_JOURNAL_CRAFTING_SELECTED_STEP", false
                ),
                selected + 1,
                nodeCount
            )
        );

        for (int row = 0; row < visibleRows; row++)
        {
            int node = visibleStart + row;
            if (node >= nodeCount) { break; }
            int nodeKind = localPlayer.CraftingBlueprintNodeKind[node];
            String indentation = "";
            for (int depth = 0;
                depth < Min(4, localPlayer.CraftingBlueprintNodeDepth[node]);
                depth++)
            {
                indentation = indentation .. "  ";
            }
            String nodeName = FormatCraftingBlueprintNodeName(
                localPlayer, node
            );
            String nodeLine;
            if (nodeKind == CaelumConstants.CRAFTING_BLUEPRINT_NODE_RAW)
            {
                nodeLine = String.Format(
                    "%s%s %d/%d",
                    indentation,
                    nodeName,
                    localPlayer.CraftingBlueprintNodeOwnedUnits[node],
                    localPlayer.CraftingBlueprintNodeUnits[node]
                );
            }
            else
            {
                if (nodeKind
                    == CaelumConstants.CRAFTING_BLUEPRINT_NODE_FINAL)
                {
                    nodeLine = String.Format(
                        "%s%s · %s: %d u (%.3f kg) · %d%% · %d t/u · %.1f s",
                        indentation,
                        nodeName,
                        StringTable.Localize(
                            "CA_JOURNAL_CRAFTING_MATERIAL_USED", false
                        ),
                        localPlayer.CraftingBlueprintNodeInputUnits[node],
                        localPlayer.CraftingBlueprintNodeInputUnits[node]
                            * CaelumConstants.MATERIAL_UNIT_WEIGHT,
                        GetCraftingEfficiencyPercentForIndex(
                            localPlayer.CraftingBlueprintNodeEfficiency[node]
                        ),
                        localPlayer.CraftingBlueprintNodeComplexityTics[node],
                        localPlayer.CraftingBlueprintNodeSeconds[node]
                    );
                }
                else
                {
                    nodeLine = String.Format(
                        "%s%s %d/%d · %d%% · %d t/u · %.1f s",
                        indentation,
                        nodeName,
                        localPlayer.CraftingBlueprintNodeOwnedUnits[node],
                        localPlayer.CraftingBlueprintNodeUnits[node],
                        GetCraftingEfficiencyPercentForIndex(
                            localPlayer.CraftingBlueprintNodeEfficiency[node]
                        ),
                        localPlayer.CraftingBlueprintNodeComplexityTics[node],
                        localPlayer.CraftingBlueprintNodeSeconds[node]
                    );
                }
            }
            bool nodeAvailable = nodeKind
                    == CaelumConstants.CRAFTING_BLUEPRINT_NODE_FINAL
                || localPlayer.CraftingBlueprintNodeExecuted[node]
                || localPlayer.CraftingBlueprintNodeOwnedUnits[node]
                    >= localPlayer.CraftingBlueprintNodeUnits[node];
            int color = node == selected
                ? Font.CR_GOLD
                : nodeAvailable ? Font.CR_GREEN : Font.CR_RED;
            DrawTextLine(
                SmallFont, color,
                52.0, 228.0 + row * 14.0,
                nodeLine
            );
        }
    }

    ui void DrawCraftsPage(CaelumPlayer localPlayer)
    {
        if (!localPlayer.CraftingMenuOpen)
        {
            DrawCraftingSummary(localPlayer);
            return;
        }

        DrawTextLine(
            SmallFont, Font.CR_GOLD, 52.0, 126.0,
            String.Format(
                "%s: %s  ·  %s: %d/%d",
                StringTable.Localize("CA_CRAFTING_FILTER", false),
                StringTable.Localize(
                    GetCraftingFilterKey(localPlayer.CraftingRecipeFilter),
                    false
                ),
                StringTable.Localize("CA_CRAFTING_RECIPE_BOOK", false),
                localPlayer.CraftingKnownRecipeCount,
                CaelumConstants.CRAFTING_NETWORK_PLAYABLE_RECIPE_COUNT
            )
        );

        DrawTexture(
            "graphics/caelum/ui/hud/components/ca_ui_icon_frame_selected.png",
            52.0, 150.0, 64.0, 64.0
        );
        if (localPlayer.CraftingPreviewIconPath.Length() > 0)
        {
            DrawTexture(
                localPlayer.CraftingPreviewIconPath,
                60.0, 158.0, 48.0, 48.0
            );
        }

        String recipeName = FormatCraftingRecipeName(localPlayer);
        DrawTextLine(
            TextFont,
            localPlayer.CraftingSelectedRecipeKnown
                ? Font.CR_WHITE : Font.CR_DARKGRAY,
            132.0, 150.0, recipeName
        );
        DrawTextLine(
            SmallFont, Font.CR_WHITE, 132.0, 174.0,
            String.Format(
                "T%d · %s · x%d · %d%%",
                localPlayer.CraftingSelectionTier,
                StringTable.Localize(
                    CaelumDisplayNames.GetEquipmentSizeKey(
                        localPlayer.CraftingSelectionSize
                    ), false
                ),
                localPlayer.CraftingProcessingBatchMultiplier,
                localPlayer.CraftingEfficiencyPercent
            )
        );
        DrawTextLine(
            SmallFont, Font.CR_CYAN, 132.0, 194.0,
            String.Format(
                "%s: %.1f s  ·  %s: %.1f s",
                StringTable.Localize("CA_JOURNAL_CRAFTING_TIME", false),
                localPlayer.CraftingPreviewSeconds,
                StringTable.Localize(
                    "CA_JOURNAL_CRAFTING_FROM_RAW", false
                ),
                localPlayer.CraftingBlueprintFullSeconds
            )
        );

        DrawCraftingBlueprint(localPlayer);
        String magicBoxCraftingSummary = localPlayer.MagicBoxOwned
            ? String.Format(
                "%d/%d",
                localPlayer.MagicBoxUsedSlots,
                localPlayer.MagicBoxMaximumSlots
            )
            : StringTable.Localize("CA_MAGIC_BOX_NOT_ACQUIRED", false);
        DrawTextLine(
            SmallFont,
            localPlayer.CraftingSelectedInfrastructureAvailable
                ? Font.CR_GREEN : Font.CR_RED,
            52.0, 288.0,
            String.Format(
                "%s  ·  %s: %d  ·  %s: %s",
                StringTable.Localize(
                    localPlayer.CraftingSelectedInfrastructureAvailable
                        ? "CA_CRAFTING_INFRASTRUCTURE_READY"
                        : "CA_CRAFTING_INFRASTRUCTURE_MISSING",
                    false
                ),
                StringTable.Localize(
                    "CA_JOURNAL_CRAFTING_DIRECT_STEPS", false
                ),
                localPlayer.CraftingDirectPlanStepCount,
                StringTable.Localize("CA_EQUIPMENT_MAGIC_BOX", false),
                magicBoxCraftingSummary
            )
        );

        if (localPlayer.CraftingTaskActive)
        {
            DrawTextLine(
                SmallFont,
                localPlayer.CraftingTaskProgressing
                    ? Font.CR_CYAN : Font.CR_GOLD,
                52.0, 304.0,
                String.Format(
                    "%s: %.1f/%.1f s · %s | T: >>",
                    StringTable.Localize("CA_CRAFTING_TASK_ACTIVE", false),
                    localPlayer.CraftingTaskRemainingSeconds,
                    localPlayer.CraftingTaskTotalSeconds,
                    StringTable.Localize(
                        localPlayer.CraftingTaskProgressing
                            ? "CA_JOURNAL_CRAFTING_RUNNING"
                            : "CA_JOURNAL_CRAFTING_PAUSED",
                        false
                    )
                )
            );
        }
        else
        {
            bool showEquipmentAction = localPlayer.LastCraftingAction
                    == CaelumConstants.CRAFTING_ACTION_NONE
                && localPlayer.LastEquipmentAction
                    != CaelumConstants.EQUIPMENT_ACTION_NONE;
            DrawTextLine(
                SmallFont,
                !showEquipmentAction
                    && localPlayer.LastCraftingAction
                        == CaelumConstants.CRAFTING_ACTION_NONE
                    ? Font.CR_GRAY : Font.CR_GOLD,
                52.0, 304.0,
                StringTable.Localize(
                    showEquipmentAction
                        ? GetEquipmentActionKey(
                            localPlayer.LastEquipmentAction
                        )
                        : GetCraftingActionKey(
                            localPlayer.LastCraftingAction
                        ),
                    false
                )
            );
        }
    }

    ui void DrawSewerTravelHint(CaelumPlayer localPlayer)
    {
        if (menuactive != 0 || localPlayer.CreationWizardOpen || !localPlayer.CharacterCreationComplete
            || localPlayer.health <= 0 || localPlayer.CraftingMenuOpen
            || (localPlayer.player.ConversationNPC != null && localPlayer.player.ConversationNPC.bInConversation)) return;
        if(localPlayer.HUDInteractionHint!="")
        {
            DrawCenteredText(SmallFont,Font.CR_GOLD,320,214,localPlayer.HUDInteractionHint);
            return;
        }
        let gates = ThinkerIterator.Create("CaelumSewerTravelGate");
        CaelumSewerTravelGate gate;
        CaelumSewerTravelGate nearest;
        double distance = 224;
        while ((gate = CaelumSewerTravelGate(gates.Next())) != null)
        {
            if (!gate.Placed || !CaelumWorldCatalogue.IsSewerConnection(gate.ConnectionId)) continue;
            double candidateDistance = localPlayer.Distance2D(gate);
            vector2 delta = gate.Pos.XY-localPlayer.Pos.XY;
            if (candidateDistance >= distance || Abs(localPlayer.Pos.Z-gate.Pos.Z) > 64
                || delta.X*Cos(localPlayer.Angle)+delta.Y*Sin(localPlayer.Angle) < candidateDistance*0.65
                || (gate.VisibleToPlayers & (1 << consoleplayer)) == 0) continue;
            distance = candidateDistance;
            nearest = gate;
        }
        if (nearest == null) return;
        DrawCenteredText(SmallFont, Font.CR_GOLD, 320, 214,
            String.Format(StringTable.Localize("CA_SEWER_TRAVEL_HINT", false),
                StringTable.Localize(CaelumWorldCatalogue.ConnectionNameKey(nearest.ConnectionId), false)));
    }

    ui void DrawWeather(CaelumPlayer localPlayer, bool trialDate)
    {
        let weather = CaelumWeatherState(localPlayer.FindInventory("CaelumWeatherState"));
        if (weather == null || weather.SourceMap != level.MapName
            || weather.Current == null || !weather.Current.Available)
        {
            DrawTextLine(SmallFont, Font.CR_GRAY, 48, 176,
                StringTable.Localize("CA_WEATHER_UNAVAILABLE", false));
            return;
        }
        let sample = weather.Current;
        DrawTextLine(SmallFont, Font.CR_CYAN, 48, 176,
            String.Format(StringTable.Localize(trialDate ? "CA_WEATHER_CAMPAIGN" : "CA_WEATHER_LOCAL", false),
                StringTable.Localize(CaelumWeatherRules.RegionKey(weather.Region), false),
                sample.AirTemperatureC, sample.RelativeHumidityPercent));
        String wind = sample.WindSpeedKmh < 0.05 ? StringTable.Localize("CA_WEATHER_CALM", false)
            : String.Format(StringTable.Localize("CA_WEATHER_WIND_VALUE", false), sample.WindSpeedKmh,
                StringTable.Localize(CaelumWeatherRules.WindKey(sample.WindFromDegrees), false));
        DrawTextLine(SmallFont, Font.CR_CYAN, 48, 188,
            String.Format(StringTable.Localize("CA_WEATHER_WIND_RAIN", false), wind, sample.PrecipitationMmPerHour,
                StringTable.Localize(CaelumWeatherRules.ShelterKey(weather.Shelter), false)));
    }

    ui void DrawWorldPage(CaelumPlayer localPlayer)
    {
        // Dos columnas para las visitas y las salidas de la ubicación actual.
        // La UI sólo consulta el Inventory; no descubre ni ejecuta viajes.
        let record = CaelumPersistentCharacterState(localPlayer.FindInventory("CaelumPersistentCharacterState"));
        int locationId = CaelumWorldCatalogue.LocationForMap(level.MapName);
        let clock = CaelumWorldClock(localPlayer.FindInventory("CaelumWorldClock"));
        DrawTextLine(TextFont, Font.CR_WHITE, 48, 132,
            String.Format(StringTable.Localize("CA_WORLD_CURRENT", false),
                StringTable.Localize(CaelumWorldCatalogue.LocationNameKey(locationId), false)));
        DrawTextLine(SmallFont, Font.CR_CYAN, 48, 148,
            clock == null ? StringTable.Localize("CA_WORLD_CLOCK_NONE", false)
                : String.Format(StringTable.Localize(CaelumWorldCatalogue.IsLimboMap(level.MapName)
                    ? "CA_WORLD_CLOCK_LIMBO" : "CA_WORLD_CLOCK_RECORDED", false),
                    CaelumWorldClock.FormatStamp(clock.CompletedDays, clock.DayTics)));
        let calendar = CaelumCalendarState(localPlayer.FindInventory("CaelumCalendarState"));
        int dateSerial = calendar == null ? -1 : calendar.DateSerial(clock, calendar.TrialDate);
        String calendarText = StringTable.Localize("CA_CALENDAR_UNSET", false);
        if (dateSerial >= 0)
            calendarText = String.Format(StringTable.Localize(calendar.TrialDate
                    ? "CA_CALENDAR_TRIAL" : "CA_CALENDAR_DATE", false),
                calendar.FormatDate(clock, calendar.TrialDate), StringTable.Localize(CaelumCalendarRules.SeasonKey(
                    CaelumCalendarRules.SouthernSeasonForMonth(
                        CaelumCalendarRules.MonthForSerial(dateSerial))), false));
        else if (calendar != null && calendar.Configured)
            calendarText = StringTable.Localize("CA_CALENDAR_OUT_OF_RANGE", false);
        DrawTextLine(SmallFont, Font.CR_CYAN, 48, 160, calendarText);
        DrawWeather(localPlayer, calendar != null && calendar.TrialDate);
        DrawTextLine(SmallFont, Font.CR_GOLD, 48, 206, StringTable.Localize("CA_WORLD_VISITED", false));
        int visits = 0;
        if(record!=null)for(int id=1;id<CaelumWorldCatalogue.LOCATION_DEFINED_COUNT;id++)
            if(record.WorldLocationVisited[id])visits++;
        int rowStep=visits>5?9:12;
        int row = 0;
        for (int id = 1; id < CaelumWorldCatalogue.LOCATION_DEFINED_COUNT; id++)
        {
            if (record == null || !record.WorldLocationVisited[id]) continue;
            DrawTextLine(SmallFont, id == locationId ? Font.CR_GOLD : Font.CR_WHITE, 56, 220+row*rowStep,
                StringTable.Localize(CaelumWorldCatalogue.LocationNameKey(id), false));
            row++;
        }
        if (row == 0) DrawTextLine(SmallFont, Font.CR_GRAY, 56, 220,
            StringTable.Localize("CA_WORLD_NO_VISITS", false));
        DrawTextLine(SmallFont, Font.CR_GOLD, 310, 206,
            StringTable.Localize("CA_WORLD_LOCAL_CONNECTIONS", false));
        row = 0;
        for (int id = 1; id < CaelumWorldCatalogue.CONNECTION_DEFINED_COUNT; id++)
        {
            if (record == null || !record.WorldConnectionKnown[id]
                || CaelumWorldCatalogue.ConnectionOrigin(id) != locationId) continue;
            DrawTextLine(SmallFont, Font.CR_WHITE, 318, 220+row*22,
                StringTable.Localize(CaelumWorldCatalogue.ConnectionNameKey(id), false));
            DrawTextLine(SmallFont, Font.CR_GRAY, 318, 230+row*22,
                StringTable.Localize(record.WorldConnectionTraversed[id]
                    ? "CA_WORLD_TRAVERSED" : "CA_WORLD_KNOWN", false));
            row++;
        }
        if (row == 0) DrawTextLine(SmallFont, Font.CR_GRAY, 318, 220,
            StringTable.Localize("CA_WORLD_NO_LOCAL_CONNECTIONS", false));
        if (locationId == CaelumWorldCatalogue.LOCATION_MANSION && row > 0)
            DrawTextLine(SmallFont, Font.CR_GRAY, 318, 246,
                String.Format(StringTable.Localize("CA_WORLD_DESTINATION", false),
                    StringTable.Localize(record.WorldLocationVisited[2]
                        ? "CA_MAP02_SEWER_NAME" : "CA_WORLD_UNDISCOVERED", false)));
        let journey = CaelumJourneyState(localPlayer.FindInventory("CaelumJourneyState"));
        if (journey != null)
            DrawTextLine(SmallFont, Font.CR_CYAN, 48, 286,
                String.Format(StringTable.Localize("CA_JOURNEY_LAST", false), journey.Sequence,
                    StringTable.Localize(CaelumJourneyRules.ModeKey(journey.TravelMode), false),
                    StringTable.Localize(CaelumJourneyState.StatusKey(journey.Status), false)));
        if (record != null && record.WorldConnectionTraversed[CaelumWorldCatalogue.CONNECTION_RETURN])
            DrawTextLine(SmallFont, Font.CR_GRAY, 48, 298, StringTable.Localize("CA_WORLD_RETURN_RECORDED", false));
        DrawTextLine(SmallFont, Font.CR_GRAY, 48, 310,
            StringTable.Localize(locationId >= 2 ? "CA_CARAVAN_WORLD_HELP" : "CA_WORLD_USE_EXIT", false));
    }

    ui void DrawPlannedPage(String key)
    {
        DrawCenteredText(TextFont, Font.CR_WHITE, 320.0, 174.0,
            StringTable.Localize(key, false));
        DrawCenteredText(SmallFont, Font.CR_GRAY, 320.0, 210.0,
            StringTable.Localize("CA_JOURNAL_NO_FAKE_DATA", false));
    }

    ui void DrawRest(CaelumPlayer localPlayer, CaelumRestState rest)
    {
        Screen.Dim(0x05070A, 0.12, 0, 0, Screen.GetWidth(), Screen.GetHeight());
        DrawPanel(16.0, 12.0, 608.0, 116.0);
        DrawCenteredText(TextFont, Font.CR_GOLD, 320, 18,
            StringTable.Localize(CaelumRestRules.ModeKey(rest.Mode), false));
        let clock = CaelumWorldClock(localPlayer.FindInventory("CaelumWorldClock"));
        let calendar = CaelumCalendarState(localPlayer.FindInventory("CaelumCalendarState"));
        if (calendar != null)
            DrawCenteredText(SmallFont, Font.CR_CYAN, 170, 32, calendar.FormatDate(clock));
        int minuteTics = CaelumWorldClock.TicsPerHour() / 60;
        int remainingMinutes = (Max(0, rest.RequestedTics-rest.ElapsedTics)+minuteTics-1) / minuteTics;
        DrawCenteredText(SmallFont, Font.CR_WHITE, 460, 32,
            rest.Untimed ? StringTable.Localize("CA_REST_UNTIMED",false)
                : String.Format(StringTable.Localize("CA_REST_REMAINING", false), remainingMinutes));
        DrawCenteredText(SmallFont, Font.CR_WHITE, 320, 45,
            String.Format(StringTable.Localize("CA_REST_RESOURCES", false),
                localPlayer.CurrentSleep, localPlayer.CurrentHunger, localPlayer.CurrentThirst));
        DrawCenteredText(SmallFont, Font.CR_GOLD, 320, 74,
            StringTable.Localize("CA_REST_STOP_HELP", false));
        DrawCenteredText(SmallFont, Font.CR_GRAY, 320, 87,
            StringTable.Localize(rest.ViewCamera != null ? "CA_REST_CAMERA_HELP" : "CA_REST_PAUSE_HELP", false));
        int factor = rest.Furniture != null ? rest.Furniture.ComfortFactor() : 1;
        DrawCenteredText(SmallFont, Font.CR_CYAN, 320, 58,
            String.Format(StringTable.Localize("CA_REST_COMFORT", false), factor, factor));
        let fast = CaelumTimeAdvanceState(localPlayer.FindInventory("CaelumTimeAdvanceState"));
        DrawCenteredText(SmallFont, Font.CR_CYAN, 320, 100,
            StringTable.Localize(rest.Untimed
                ? fast!=null && fast.Active ? "CA_FAST_LIMBO_ON" : "CA_FAST_LIMBO_OFF"
                : fast!=null && fast.Active ? "CA_FAST_HELP_ON" : "CA_FAST_HELP_OFF", false));
        DrawCenteredText(SmallFont, Font.CR_GOLD, 320, 113,
            rest.Mode==CaelumRestRules.MODE_WAIT
                ? String.Format(StringTable.Localize("CA_TABLE_AUTO_HELP",false),rest.AutoEating?"ON":"OFF",rest.AutoDrinking?"ON":"OFF")
                : StringTable.Localize("CA_SLEEP_LUCIDITY_HELP", false));
        if(rest.Mode==CaelumRestRules.MODE_WAIT)
            DrawCenteredText(SmallFont, Font.CR_GRAY, 320, 126, StringTable.Localize("CA_TABLE_RESERVES",false));
    }

    ui void DrawPalomoMerchant(CaelumPlayer localPlayer)
    {
        bool legacyMerchant = localPlayer.PalomoMerchantTitleKey.Length() == 0
            || localPlayer.PalomoMerchantTitleKey == "CA_PALOMO_MERCHANT_TITLE";
        Screen.Dim(0x05070A, 0.92, 0, 0,
            Screen.GetWidth(), Screen.GetHeight());
        DrawPanel(16.0, 12.0, 608.0, 336.0);
        DrawCenteredText(
            TitleFont, Font.CR_GOLD, 320.0, 20.0,
            StringTable.Localize(localPlayer.PalomoMerchantTitleKey.Length() > 0
                ? localPlayer.PalomoMerchantTitleKey : "CA_PALOMO_MERCHANT_TITLE", false)
        );
        if (localPlayer.PalomoMerchantDiscountGranted || localPlayer.PalomoMerchantReputationDiscount)
        {
            DrawCenteredText(
                SmallFont, Font.CR_CYAN, 320.0, 44.0,
                StringTable.Localize(
                    localPlayer.PalomoMerchantReputationDiscount && !localPlayer.PalomoMerchantDiscountGranted
                        ? "CA_REP_TRADE_DISCOUNT" : "CA_PALOMO_MERCHANT_DISCOUNT_ACTIVE", false
                )
            );
        }

        String modeKey = localPlayer.PalomoMerchantMode
                == CaelumConstants.PALOMO_MERCHANT_MODE_SELL
            ? (legacyMerchant ? "CA_PALOMO_MERCHANT_MODE_SELL" : "CA_MERCHANT_MODE_SELL")
            : (legacyMerchant ? "CA_PALOMO_MERCHANT_MODE_BUY" : "CA_MERCHANT_MODE_BUY");
        DrawTextLine(
            TextFont, Font.CR_GOLD, 54.0, 62.0,
            String.Format(
                "%s: %s",
                StringTable.Localize("CA_PALOMO_MERCHANT_MODE", false),
                StringTable.Localize(modeKey, false)
            )
        );
        DrawTextLine(
            InventoryFont, Font.CR_WHITE, 54.0, 88.0,
            String.Format(
                "%s: %.0f c",
                StringTable.Localize("CA_PALOMO_MERCHANT_YOUR_MONEY", false),
                localPlayer.HUDTotalMoneyCopperValue
            )
        );
        DrawTextLine(
            InventoryFont, Font.CR_WHITE, 360.0, 88.0,
            String.Format(
                "%s: %d c",
                StringTable.Localize(legacyMerchant ? "CA_PALOMO_MERCHANT_CASH" : "CA_MERCHANT_CASH", false),
                localPlayer.PalomoMerchantWalletCopper
            )
        );

        DrawTextLine(InventoryFont, Font.CR_GRAY, 54.0, 116.0,
            StringTable.Localize("CA_PALOMO_MERCHANT_ITEM", false));
        DrawTextLine(InventoryFont, Font.CR_GRAY, 346.0, 116.0,
            StringTable.Localize("CA_PALOMO_MERCHANT_STOCK", false));
        DrawTextLine(InventoryFont, Font.CR_GRAY, 432.0, 116.0,
            StringTable.Localize("CA_PALOMO_MERCHANT_YOURS", false));
        DrawTextLine(InventoryFont, Font.CR_GRAY, 518.0, 116.0,
            StringTable.Localize("CA_PALOMO_MERCHANT_UNIT", false));

        for (int visibleRow = 0;
            visibleRow < localPlayer.PalomoMerchantVisibleItemCount;
            visibleRow++)
        {
            int merchantItem = localPlayer.PalomoMerchantVisibleItems[visibleRow];
            bool selected = merchantItem
                == localPlayer.PalomoMerchantSelection;
            double rowY = 142.0 + visibleRow * 27.0;
            String itemName = StringTable.Localize(
                GetPalomoMerchantItemKey(merchantItem), false
            );
            DrawTextLine(
                InventoryFont,
                selected ? Font.CR_GOLD : Font.CR_WHITE,
                54.0, rowY,
                (selected ? "> " : "  ") .. itemName
            );
            DrawTextLine(
                InventoryFont, Font.CR_WHITE, 366.0, rowY,
                String.Format("%d", localPlayer.PalomoMerchantStock[merchantItem])
            );
            DrawTextLine(
                InventoryFont, Font.CR_WHITE, 452.0, rowY,
                String.Format(
                    "%d", localPlayer.PalomoMerchantPlayerOwned[merchantItem]
                )
            );
            DrawTextLine(
                InventoryFont, Font.CR_WHITE, 518.0, rowY,
                String.Format(
                    "%d c",
                    CaelumEconomyRules.GetPalomoMerchantLotPrice(
                        merchantItem, 1, localPlayer.PalomoMerchantMode,
                        localPlayer.PalomoMerchantDiscountGranted || localPlayer.PalomoMerchantReputationDiscount
                    )
                )
            );
        }
        if (localPlayer.PalomoMerchantVisibleItemCount <= 0)
        {
            DrawCenteredText(
                InventoryFont, Font.CR_GRAY, 320.0, 154.0,
                StringTable.Localize(
                    "CA_PALOMO_MERCHANT_NOTHING_TO_SELL", false
                )
            );
        }

        DrawTextLine(
            InventoryFont, Font.CR_CYAN, 54.0, 282.0,
            String.Format(
                "%s: %d  |  %s: %d c",
                StringTable.Localize("CA_PALOMO_MERCHANT_QUANTITY", false),
                localPlayer.PalomoMerchantSelectedQuantity,
                StringTable.Localize("CA_PALOMO_MERCHANT_TOTAL", false),
                localPlayer.PalomoMerchantSelectedLotPrice
            )
        );
        DrawCenteredText(
            InventoryFont,
            localPlayer.LastPalomoMerchantAction
                    == CaelumConstants.PALOMO_MERCHANT_ACTION_NONE
                ? Font.CR_GRAY : Font.CR_GOLD,
            320.0, 306.0,
            StringTable.Localize(
                GetPalomoMerchantActionKey(
                    localPlayer.LastPalomoMerchantAction
                ),
                false
            )
        );
        DrawCenteredText(
            SmallFont, Font.CR_GRAY, 320.0, 329.0,
            StringTable.Localize(legacyMerchant ? "CA_PALOMO_MERCHANT_HELP" : "CA_REP_TRIAL_TRADE_HELP", false)
        );
    }

    ui void DrawJourney(CaelumJourneyPlan plan)
    {
        let available = plan.Available;
        let needed = plan.Needed;
        Screen.Dim(0x05070A, 0.92, 0, 0, Screen.GetWidth(), Screen.GetHeight());
        DrawPanel(16, 12, 608, 336);
        DrawCenteredText(TitleFont, Font.CR_GOLD, 320, 24, StringTable.Localize("CA_JOURNEY_PLAN", false));
        String destination = StringTable.Localize(CaelumWorldCatalogue.LocationNameKey(
            CaelumWorldCatalogue.ConnectionDestination(plan.ConnectionId)), false);
        DrawCenteredText(TextFont, Font.CR_WHITE, 320, 63, destination .. " | "
            .. StringTable.Localize(CaelumJourneyRules.ModeKey(plan.TravelMode),false));
        DrawTextLine(SmallFont, Font.CR_GRAY, 42, 89, String.Format(StringTable.Localize("CA_JOURNEY_PACE_LINE", false),
            CaelumJourneyRules.DistanceKm(plan.ConnectionId), plan.SpeedKmh));
        DrawTextLine(SmallFont, Font.CR_WHITE, 42, 111, String.Format(StringTable.Localize("CA_JOURNEY_TIME_LINE", false),
            CaelumJourneyRules.Duration(plan.TotalTics())));
        DrawTextLine(SmallFont, Font.CR_GRAY, 42, 129, String.Format(StringTable.Localize(
            plan.TravelMode == CaelumJourneyState.MODE_SHIP ? "CA_JOURNEY_ONBOARD_REST" : "CA_JOURNEY_REST_LINE", false),
            CaelumJourneyRules.Duration(plan.PlannedWalkTics), CaelumJourneyRules.Duration(plan.PlannedSleepTics)));
        DrawTextLine(SmallFont, Font.CR_GOLD, 42, 154, StringTable.Localize("CA_JOURNEY_STOCK_TITLE", false));
        DrawTextLine(SmallFont, Font.CR_WHITE, 42, 172, String.Format(StringTable.Localize("CA_JOURNEY_FOOD_LINE", false),
            needed.FoodSpent, available.FoodStock, available.FoodSpent));
        DrawTextLine(SmallFont, Font.CR_WHITE, 42, 190, String.Format(StringTable.Localize("CA_JOURNEY_WATER_LINE", false),
            needed.WaterSpent, available.WaterStock, available.WaterSpent));
        DrawTextLine(SmallFont, Font.CR_GRAY, 42, 208, String.Format(StringTable.Localize("CA_JOURNEY_LITERS_LINE", false),
            available.ContainerSpent, available.ContainerStock));
        DrawTextLine(SmallFont, Font.CR_GRAY, 42, 226, StringTable.Localize(
            plan.TravelMode == CaelumJourneyState.MODE_SHIP
                ? available.Bag ? "CA_JOURNEY_SHIP_BAG" : "CA_JOURNEY_SHIP_DECK"
                : available.Bag ? "CA_JOURNEY_BAG" : "CA_JOURNEY_GROUND", false));
        DrawTextLine(SmallFont, available.Health > 0 ? Font.CR_WHITE : Font.CR_RED, 42, 247,
            available.Health > 0 ? String.Format(StringTable.Localize("CA_JOURNEY_END_LINE", false),
                available.Hunger, available.Thirst, available.Sleep, 100.0 * available.Health / available.MaxHealth)
                : String.Format(StringTable.Localize("CA_JOURNEY_FATAL", false), CaelumJourneyRules.Duration(available.ElapsedTics)));
        DrawTextLine(SmallFont, Font.CR_GRAY, 42, 271, StringTable.Localize(
            plan.TravelMode == CaelumJourneyState.MODE_SHIP ? "CA_JOURNEY_SHIP_NOTE"
                : plan.TravelMode == CaelumJourneyState.MODE_CART ? "CA_JOURNEY_CART_NOTE" : "CA_JOURNEY_FOOT_NOTE", false));
        DrawCenteredText(SmallFont, available.Health > 0 ? Font.CR_GOLD : Font.CR_RED, 320, 310,
            StringTable.Localize(available.Health > 0 ? "CA_JOURNEY_CONFIRM" : "CA_JOURNEY_CONFIRM_FATAL", false));
    }

    override bool InputProcess(InputEvent e)
    {
        // El slot nativo sólo conoce clases de Weapon. Caelum mantiene varias
        // instancias exactas (acabado, tier y durabilidad propios), por lo que
        // el 2 cicla sus objetos equipados antes de que Doom seleccione Pistol.
        bool slotTwo = e.KeyChar == 50 || e.KeyString ~== "2";
        CaelumPlayer localPlayer = consoleplayer >= 0
            ? CaelumPlayer(players[consoleplayer].mo) : null;
        let plan = localPlayer == null ? null : CaelumJourneyPlan(localPlayer.FindInventory("CaelumJourneyPlan"));
        if (plan != null && plan.Open && menuactive == 0)
        {
            // Liberar teclas siempre llega al motor: no deja Use/marcha trabados.
            if (e.Type != InputEvent.Type_KeyDown || e.KeyScan == InputEvent.Key_Grave
                || e.KeyScan == InputEvent.Key_Escape || e.KeyScan == InputEvent.Key_Pad_Start) return false;
            if (e.KeyString ~== "q" || e.KeyChar == 113 || e.KeyChar == 81 || e.KeyScan == InputEvent.Key_Tab
                || e.KeyScan == InputEvent.Key_Pad_B)
                SendNetworkEvent("ca_journey_cancel");
            else if (e.KeyScan == InputEvent.Key_Enter || e.KeyScan == InputEvent.Key_Pad_A)
                SendNetworkEvent("ca_journey_confirm");
            return true;
        }
        let activeRest = localPlayer == null ? null
            : CaelumRestState(localPlayer.FindInventory("CaelumRestState"));
        bool restOpen = activeRest != null && activeRest.Status == CaelumRestRules.STATUS_ACTIVE;
        bool craftOpen = localPlayer != null && localPlayer.CraftingMenuOpen;
        if (menuactive == 0 && (restOpen || craftOpen) && e.Type == InputEvent.Type_KeyDown
            && (e.KeyChar == 116 || e.KeyChar == 84 || e.KeyString ~== "t"))
        { SendNetworkEvent("ca_time_fast"); return true; }
        if (menuactive == 0 && restOpen && e.Type == InputEvent.Type_KeyDown)
        {
            if (e.KeyChar == 102 || e.KeyChar == 70 || e.KeyString ~== "f")
            { SendNetworkEvent("ca_table_eat"); return true; }
            if (e.KeyChar == 103 || e.KeyChar == 71 || e.KeyString ~== "g")
            { SendNetworkEvent("ca_table_drink"); return true; }
        }
        if (menuactive == 0 && activeRest != null && activeRest.Status == CaelumRestRules.STATUS_ACTIVE
            && e.Type == InputEvent.Type_KeyDown)
        {
            if (e.KeyChar == 113 || e.KeyChar == 81 || e.KeyString ~== "q"
                || e.KeyScan == InputEvent.Key_Pad_B)
            {
                SendNetworkEvent("ca_rest_cancel");
                return true;
            }
            // Abrir el Diario levanta al personaje. Escape conserva la pausa
            // nativa; las liberaciones de Use siempre llegan al motor.
            if (e.KeyScan == InputEvent.Key_Tab) SendNetworkEvent("ca_rest_cancel");
        }
        if (localPlayer != null && localPlayer.PalomoMerchantMenuOpen)
        {
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

            if (e.KeyScan == InputEvent.Key_Escape
                || e.KeyScan == InputEvent.Key_Tab
                || e.KeyScan == InputEvent.Key_Pad_B
                || e.KeyChar == 113 || e.KeyChar == 81
                || e.KeyString ~== "q")
            {
                SendNetworkEvent("ca_palomo_merchant_close");
                SendNetworkEvent("ca_journal_menu_select_sound");
            }
            else if (e.KeyScan == InputEvent.Key_DownArrow
                || e.KeyScan == InputEvent.Key_Pad_DPad_Down)
            {
                SendNetworkEvent("ca_palomo_merchant_next");
                SendNetworkEvent("ca_journal_menu_move_sound");
            }
            else if (e.KeyScan == InputEvent.Key_UpArrow
                || e.KeyScan == InputEvent.Key_Pad_DPad_Up)
            {
                SendNetworkEvent("ca_palomo_merchant_previous");
                SendNetworkEvent("ca_journal_menu_move_sound");
            }
            else if (e.KeyScan == InputEvent.Key_LeftArrow
                || e.KeyScan == InputEvent.Key_Pad_DPad_Left)
            {
                SendNetworkEvent("ca_palomo_merchant_quantity_previous");
                SendNetworkEvent("ca_journal_menu_move_sound");
            }
            else if (e.KeyScan == InputEvent.Key_RightArrow
                || e.KeyScan == InputEvent.Key_Pad_DPad_Right)
            {
                SendNetworkEvent("ca_palomo_merchant_quantity_next");
                SendNetworkEvent("ca_journal_menu_move_sound");
            }
            else if (e.KeyScan == InputEvent.Key_Space
                || e.KeyScan == InputEvent.Key_Pad_X)
            {
                SendNetworkEvent("ca_palomo_merchant_mode");
                SendNetworkEvent("ca_journal_menu_move_sound");
            }
            else if (e.KeyScan == InputEvent.Key_Enter
                || e.KeyScan == InputEvent.Key_Pad_A)
            {
                SendNetworkEvent("ca_palomo_merchant_transact");
            }
            return true;
        }
        if (!IsJournalOpen())
        {
            if (menuactive == 0 && slotTwo
                && (e.Type == InputEvent.Type_KeyDown
                    || e.Type == InputEvent.Type_KeyUp))
            {
                if (e.Type == InputEvent.Type_KeyDown)
                {
                    SendNetworkEvent("ca_cycle_weapon_slot_2");
                }
                return true;
            }
            return false;
        }
        if (e.Type != InputEvent.Type_KeyDown
            && e.Type != InputEvent.Type_KeyUp)
        {
            return false;
        }
        if (e.KeyScan == InputEvent.Key_Grave || e.KeyScan == InputEvent.Key_Escape
            || e.KeyScan == InputEvent.Key_Pad_Start)
        {
            return false;
        }
        if (GetJournalPage() == 2 && CaelumScheduleCalendar.Input(e, localPlayer)) return true;
        // Resolver X de Mundo antes del latch de abandono de Misiones: la
        // liberación llegará cuando el Diario ya esté cerrado.
        if (GetJournalPage() == 2 && (e.KeyChar == 100 || e.KeyChar == 68
            || e.KeyString ~== "d" || e.KeyScan == InputEvent.Key_Pad_X))
        {
            if (e.Type == InputEvent.Type_KeyDown)
            {
                SetJournalOpen(false);
                SendNetworkEvent("ca_rest_trial");
            }
            return true;
        }
        bool abandonKey = e.KeyChar == 103 || e.KeyChar == 71 || e.KeyString ~== "g"
            || e.KeyScan == InputEvent.Key_Pad_X;
        let abandonScan = CVar.GetCVar("ca_journal_quest_abandon_scan", players[consoleplayer]);
        if (abandonKey || (e.Type == InputEvent.Type_KeyUp && abandonScan != null
            && e.KeyScan == abandonScan.GetInt()))
        {
            let held = CVar.GetCVar("ca_journal_quest_abandon_held", players[consoleplayer]);
            if (held != null)
            {
                if (e.Type == InputEvent.Type_KeyUp) { held.SetBool(false); return true; }
                if (held.GetBool()) return true;
                held.SetBool(true);
                if (abandonScan != null) abandonScan.SetInt(e.KeyScan);
            }
        }
        if (e.Type == InputEvent.Type_KeyUp)
        {
            // Use abre Oficios antes de que se suelte la tecla. El motor
            // necesita recibir esa liberación para aceptar el próximo uso
            // después de Q; consumirla aquí deja +use retenido internamente.
            return !(Bindings.GetBinding(e.KeyScan) ~== "+use");
        }

        int currentPage = GetJournalPage();
        bool craftingSession = currentPage == 3
            && localPlayer != null && localPlayer.CraftingMenuOpen;

        // Las solapas siempre son accesibles, aun cuando las flechas controlan
        // las misiones o las opciones contextuales de una estación abierta.
        if (currentPage == 2 && (e.KeyString ~== "f" || e.KeyChar == 102 || e.KeyChar == 70
            || e.KeyScan == InputEvent.Key_Pad_RTrigger))
        { CaelumScheduleCalendar.Open(localPlayer); return true; }
        if (HandleJournalNavigation(e.KeyScan)) return true;

        if ((currentPage == 2 && (e.KeyString ~== "q" || e.KeyChar == 113 || e.KeyChar == 81))
            || e.KeyScan == InputEvent.Key_Tab || e.KeyScan == InputEvent.Key_Pad_B)
        {
            if (currentPage == 4 && IsQuestDetailOpen())
            {
                SetQuestDetailOpen(false);
                return true;
            }
            if (craftingSession)
            {
                SendNetworkEvent("ca_crafting_session_close");
                SendNetworkEvent("ca_journal_menu_select_sound");
            }
            SetJournalOpen(false);
        }
        else if (currentPage == 3 && craftingSession
            && (e.KeyChar == 113 || e.KeyChar == 81
                || e.KeyString ~== "q"))
        {
            SendNetworkEvent("ca_crafting_session_close");
            SendNetworkEvent("ca_journal_menu_select_sound");
            SetJournalOpen(false);
        }
        else if (currentPage == 3 && craftingSession
            && (e.KeyChar == 103 || e.KeyChar == 71 || e.KeyString ~== "g"
                || e.KeyScan == InputEvent.Key_Pad_Y))
        {
            SendNetworkEvent("ca_crafting_filter");
            SendNetworkEvent("ca_journal_menu_move_sound");
        }
        else if (currentPage != 3 && e.KeyScan == InputEvent.Key_Tab)
        {
            SetJournalOpen(false);
        }
        else if (currentPage == 2
            && CaelumWorldCatalogue.LocationForMap(level.MapName) >= 2
            && (e.KeyChar == 99 || e.KeyChar == 67 || e.KeyString ~== "c"
                || e.KeyScan == InputEvent.Key_Pad_Y))
        {
            SetJournalOpen(false);
            SendNetworkEvent("ca_caravan_trial");
        }
        else if (currentPage == 5 && localPlayer.JournalReputationTrialEnabled
            && (e.KeyChar == 102 || e.KeyChar == 70 || e.KeyString ~== "f"
                || e.KeyScan == InputEvent.Key_Pad_Y))
        {
            SetJournalOpen(false);
            SendNetworkEvent("ca_reputation_trial");
        }
        else if (currentPage == 4
            && (e.KeyChar == 102 || e.KeyChar == 70 || e.KeyString ~== "f"
                || e.KeyScan == InputEvent.Key_Pad_Y))
        {
            if (GetVisibleQuestId(localPlayer) >= 0)
            {
                SetQuestDetailOpen(!IsQuestDetailOpen());
                SendNetworkEvent("ca_social_refresh");
                SendNetworkEvent("ca_journal_menu_select_sound");
            }
        }
        else if (currentPage == 4 && IsQuestDetailOpen()
            && (e.KeyScan == InputEvent.Key_DownArrow
                || e.KeyScan == InputEvent.Key_Pad_DPad_Down))
        {
            ScrollQuestDetail(localPlayer, 1);
        }
        else if (currentPage == 4 && IsQuestDetailOpen()
            && (e.KeyScan == InputEvent.Key_UpArrow
                || e.KeyScan == InputEvent.Key_Pad_DPad_Up))
        {
            ScrollQuestDetail(localPlayer, -1);
        }
        else if (currentPage == 4 && !IsQuestDetailOpen()
            && (e.KeyScan == InputEvent.Key_DownArrow || e.KeyScan == InputEvent.Key_Pad_DPad_Down))
        {
            CycleQuest(localPlayer, 1);
            SendNetworkEvent("ca_journal_menu_move_sound");
        }
        else if (currentPage == 4 && !IsQuestDetailOpen()
            && (e.KeyScan == InputEvent.Key_UpArrow || e.KeyScan == InputEvent.Key_Pad_DPad_Up))
        {
            CycleQuest(localPlayer, -1);
            SendNetworkEvent("ca_journal_menu_move_sound");
        }
        else if (currentPage == 4
            && (e.KeyScan == InputEvent.Key_Enter || e.KeyScan == InputEvent.Key_Pad_A))
        {
            let confirm = CVar.GetCVar("ca_journal_quest_abandon", players[consoleplayer]);
            if (confirm != null) confirm.SetInt(-1);
            SendNetworkEvent("ca_quest_activate", GetVisibleQuestId(localPlayer));
        }
        else if (currentPage == 4
            && (e.KeyChar == 103 || e.KeyChar == 71 || e.KeyString ~== "g"
                || e.KeyScan == InputEvent.Key_Pad_X))
        {
            int id = GetVisibleQuestId(localPlayer);
            let confirm = CVar.GetCVar("ca_journal_quest_abandon", players[consoleplayer]);
            if (confirm != null && CaelumSideQuestRules.IsDefined(id)
                && localPlayer.JournalQuestState[id] == CaelumConstants.QUEST_STATE_ACTIVE)
            {
                if (confirm.GetInt() == id)
                {
                    confirm.SetInt(-1);
                    SendNetworkEvent("ca_quest_abandon", id);
                }
                else confirm.SetInt(id);
            }
        }
        else if (currentPage == 0
            && (e.KeyScan == InputEvent.Key_DownArrow
                || e.KeyScan == InputEvent.Key_Pad_DPad_Down))
        {
            SendNetworkEvent("ca_inventory_next");
            SendNetworkEvent("ca_journal_menu_move_sound");
        }
        else if (currentPage == 0
            && (e.KeyScan == InputEvent.Key_UpArrow
                || e.KeyScan == InputEvent.Key_Pad_DPad_Up))
        {
            SendNetworkEvent("ca_inventory_previous");
            SendNetworkEvent("ca_journal_menu_move_sound");
        }
        else if (currentPage == 0
            && (e.KeyChar == 102 || e.KeyChar == 70
                || e.KeyScan == InputEvent.Key_Pad_Y))
        {
            SendNetworkEvent("ca_inventory_filter");
            SendNetworkEvent("ca_journal_menu_move_sound");
        }
        else if (currentPage == 0
            && (e.KeyScan == InputEvent.Key_Enter
                || e.KeyScan == InputEvent.Key_Pad_A))
        {
            // La bolsa abre su diálogo después de cerrar la vista de inventario.
            if (localPlayer.EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_KEY_ITEM
                && localPlayer.EquipmentSelectionSpecialType == CaelumConstants.KEY_ITEM_SLEEPING_BAG
                && localPlayer.EquipmentSelectionOwned && !localPlayer.EquipmentSelectionInMagicBox)
                SetJournalOpen(false);
            SendNetworkEvent("ca_inventory_activate");
            SendNetworkEvent("ca_journal_menu_select_sound");
        }
        else if (currentPage == 0
            && (e.KeyChar == 99 || e.KeyChar == 67
                || e.KeyScan == InputEvent.Key_Pad_X))
        {
            SendNetworkEvent("ca_inventory_storage");
            SendNetworkEvent("ca_journal_menu_select_sound");
        }
        else if (currentPage == 0
            && (e.KeyChar == 100 || e.KeyChar == 68))
        {
            SendNetworkEvent("ca_inventory_drop");
            SendNetworkEvent("ca_journal_menu_select_sound");
        }
        else if (currentPage == 3 && craftingSession
            && (e.KeyScan == InputEvent.Key_DownArrow
                || e.KeyScan == InputEvent.Key_Pad_DPad_Down))
        {
            SendNetworkEvent("ca_crafting_step_next");
            SendNetworkEvent("ca_journal_menu_move_sound");
        }
        else if (currentPage == 3 && craftingSession
            && (e.KeyScan == InputEvent.Key_UpArrow
                || e.KeyScan == InputEvent.Key_Pad_DPad_Up))
        {
            SendNetworkEvent("ca_crafting_step_previous");
            SendNetworkEvent("ca_journal_menu_move_sound");
        }
        else if (currentPage == 3 && craftingSession
            && (e.KeyScan == InputEvent.Key_RightArrow
                || e.KeyScan == InputEvent.Key_Pad_DPad_Right))
        {
            SendNetworkEvent("ca_crafting_recipe_next");
            SendNetworkEvent("ca_journal_menu_move_sound");
        }
        else if (currentPage == 3 && craftingSession
            && (e.KeyScan == InputEvent.Key_LeftArrow
                || e.KeyScan == InputEvent.Key_Pad_DPad_Left))
        {
            SendNetworkEvent("ca_crafting_recipe_previous");
            SendNetworkEvent("ca_journal_menu_move_sound");
        }
        else if (currentPage == 3 && craftingSession
            && (e.KeyScan == InputEvent.Key_Space
                || e.KeyScan == InputEvent.Key_Pad_X))
        {
            SendNetworkEvent("ca_crafting_tier");
            SendNetworkEvent("ca_journal_menu_move_sound");
        }
        else if (currentPage == 3 && craftingSession
            && (e.KeyChar == 114 || e.KeyChar == 82))
        {
            SendNetworkEvent("ca_crafting_size");
            SendNetworkEvent("ca_journal_menu_move_sound");
        }
        else if (currentPage == 3 && craftingSession
            && (e.KeyChar == 98 || e.KeyChar == 66))
        {
            SendNetworkEvent("ca_crafting_batch");
            SendNetworkEvent("ca_journal_menu_move_sound");
        }
        else if (currentPage == 3 && craftingSession
            && (e.KeyChar == 120 || e.KeyChar == 88))
        {
            SendNetworkEvent("ca_crafting_efficiency");
            SendNetworkEvent("ca_journal_menu_move_sound");
        }
        else if (currentPage == 3 && craftingSession
            && (e.KeyChar == 99 || e.KeyChar == 67))
        {
            SendNetworkEvent("ca_crafting_cancel_task");
            SendNetworkEvent("ca_journal_menu_select_sound");
        }
        else if (currentPage == 3 && craftingSession
            && (e.KeyChar == 102 || e.KeyChar == 70))
        {
            SendNetworkEvent("ca_crafting_repair_selected");
            SendNetworkEvent("ca_journal_menu_select_sound");
        }
        else if (currentPage == 3 && craftingSession
            && (e.KeyChar == 100 || e.KeyChar == 68))
        {
            SendNetworkEvent("ca_crafting_dismantle_selected");
            SendNetworkEvent("ca_journal_menu_select_sound");
        }
        else if (currentPage == 3 && craftingSession
            && (e.KeyScan == InputEvent.Key_Enter
                || e.KeyScan == InputEvent.Key_Pad_A
                || e.KeyChar == 101 || e.KeyChar == 69))
        {
            SendNetworkEvent("ca_crafting_create");
            SendNetworkEvent("ca_journal_menu_select_sound");
        }
        return true;
    }

    override void ConsoleProcess(ConsoleEvent e)
    {
        if (e.Name ~== "ca_journal_toggle")
        {
            CaelumPlayer localPlayer = consoleplayer >= 0
                ? CaelumPlayer(players[consoleplayer].mo) : null;
            let rest = localPlayer == null ? null
                : CaelumRestState(localPlayer.FindInventory("CaelumRestState"));
            if (rest != null && rest.Status == CaelumRestRules.STATUS_ACTIVE)
                SendNetworkEvent("ca_rest_cancel");
            if (localPlayer != null && localPlayer.PalomoMerchantMenuOpen)
            {
                SendNetworkEvent("ca_palomo_merchant_close");
                return;
            }
            bool opening = !IsJournalOpen();
            if (!opening && GetJournalPage() == 3)
            {
                SendNetworkEvent("ca_crafting_session_close");
            }
            SetJournalOpen(opening);
            if (opening)
            {
                SendNetworkEvent("ca_inventory_refresh");
                SendNetworkEvent("ca_social_refresh");
            }
        }
    }

    override void NetworkProcess(ConsoleEvent e)
    {
        CaelumPlayer requestingPlayer = CaelumPlayer(players[e.Player].mo);
        if (requestingPlayer == null) { return; }
        if (e.Name == "ca_event_action") { CaelumScheduleState.Act(requestingPlayer, e.Args[0]); }
        else if (e.Name == "ca_debug_events_report") { CaelumScheduleState.Report(requestingPlayer); }
        else if (e.Name == "ca_debug_events_trial") { CaelumScheduleTrial.Enable(requestingPlayer); }
        else if (e.Name == "ca_debug_cargo_trial") { CaelumScheduleTrial.Cargo(requestingPlayer); }
        else if (e.Name == "ca_inventory_refresh")
        {
            requestingPlayer.RefreshFormalInventorySnapshot();
        }
        else if (e.Name == "ca_debug_fool_report")
        {
            CaelumMainM00FoolCapture.Report(requestingPlayer);
        }
        else if (e.Name == "ca_debug_door_report")
        {
            CaelumDoorAccessTrial.Report(requestingPlayer);
        }
        else if (e.Name == "ca_journey_confirm") { CaelumJourneyPlan.Confirm(requestingPlayer); }
        else if (e.Name == "ca_journey_cancel") { CaelumJourneyPlan.Cancel(requestingPlayer); }
        else if (e.Name == "ca_caravan_trial")
        {
            CaelumCaravanTrial.Open(requestingPlayer);
        }
        else if (e.Name == "ca_time_fast")
        { CaelumTimeAdvanceState.Toggle(requestingPlayer); }
        else if (e.Name == "ca_table_eat" || e.Name == "ca_table_drink")
        {
            if (!CaelumDiningSession.Toggle(requestingPlayer, e.Name == "ca_table_drink"))
                CaelumNotifications.Notify(requestingPlayer,StringTable.Localize("CA_TABLE_CANNOT_EAT", false));
        }
        else if (e.Name == "ca_debug_dining")
        { CaelumDiningWorld.Prepare(); }
        else if (e.Name == "ca_debug_time_fast_report")
        {
            let fast = CaelumTimeAdvanceState.Get(requestingPlayer);
            Console.Printf("[Caelum 4.35.0j] Avance: activo=%d extra=%d motivo=%s lucidez=%.4f",
                fast != null && fast.Active, fast != null ? fast.SimulatedTics : 0,
                fast != null ? fast.LastReason : "", requestingPlayer.CurrentLucidity);
        }
        else if (e.Name == "ca_rest_trial")
        {
            CaelumRestTrial.Open(requestingPlayer);
        }
        else if (e.Name == "ca_rest_cancel")
        {
            CaelumRestState.Cancel(requestingPlayer);
        }
        else if (e.Name == "ca_debug_rest_report")
        {
            CaelumRestState.Report(requestingPlayer);
        }
        else if (e.Name == "ca_debug_rest_bag")
        {
            CaelumSleepingBag.PrepareTrial(requestingPlayer);
        }
        else if (e.Name == "ca_debug_rest_hit")
        {
            CaelumRestTrial.DebugHit(requestingPlayer);
        }
        else if (e.Name == "ca_debug_travel_report")
        {
            CaelumJourneyState.Report(requestingPlayer);
        }
        else if (e.Name == "ca_debug_world_report")
        {
            CaelumWorldProgress.Report(requestingPlayer);
        }
        else if (e.Name == "ca_debug_time_report")
        {
            CaelumWorldClock.Report(requestingPlayer);
        }
        else if (e.Name == "ca_debug_weather_report")
        {
            CaelumWeatherState.Report(requestingPlayer);
        }
        else if (e.Name == "ca_debug_weather_sample")
        {
            CaelumWeatherState.DebugSample(requestingPlayer, e.Args[0], e.Args[1], e.Args[2]);
        }
        else if (e.Name == "ca_debug_climate_sample")
        {
            CaelumWeatherState.DebugSample(requestingPlayer, e.Args[0], e.Args[1], e.Args[2], true);
        }
        else if (e.Name == "ca_debug_calendar_report")
        {
            CaelumCalendarState.Report(requestingPlayer);
        }
        else if (e.Name == "ca_debug_calendar_set")
        {
            CaelumCalendarState.ConfigureTrial(requestingPlayer, e.Args[0], e.Args[1], e.Args[2]);
        }
        else if (e.Name == "ca_debug_calendar_edge")
        {
            CaelumCalendarState.PrepareMidnightTrial(requestingPlayer);
        }
        else if (e.Name == "ca_debug_calendar_clear")
        {
            CaelumCalendarState.ClearTrial(requestingPlayer);
        }
        else if (e.Name == "ca_debug_integration_report")
        {
            CaelumIntegrationDiagnostics.Report(requestingPlayer);
        }
        else if (e.Name == "ca_social_refresh")
        {
            requestingPlayer.RefreshSocialJournalSnapshot();
        }
        else if (e.Name == "ca_reputation_trial")
        {
            CaelumReputationTrialState.Open(requestingPlayer);
        }
        else if (e.Name == "ca_quest_activate")
        {
            CaelumSideQuestRules.Activate(requestingPlayer, e.Args[0]);
        }
        else if (e.Name == "ca_quest_abandon")
        {
            if (CaelumSideQuestRules.End(requestingPlayer.GetPersistentCharacterState(false), e.Args[0], true))
            {
                requestingPlayer.RefreshSocialJournalSnapshot();
                requestingPlayer.PersistCharacterState();
            }
        }
        else if (e.Name == "ca_inventory_next")
        {
            requestingPlayer.CycleFormalInventorySelection(1);
        }
        else if (e.Name == "ca_inventory_previous")
        {
            requestingPlayer.CycleFormalInventorySelection(-1);
        }
        else if (e.Name == "ca_inventory_filter")
        {
            requestingPlayer.CycleFormalInventoryFilter();
        }
        else if (e.Name == "ca_inventory_filter_previous")
        {
            requestingPlayer.CycleFormalInventoryFilter(-1);
        }
        else if (e.Name == "ca_inventory_activate")
        {
            requestingPlayer.ActivateFormalInventorySelection();
        }
        else if (e.Name == "ca_inventory_storage")
        {
            requestingPlayer.ToggleFormalInventoryStorage();
        }
        else if (e.Name == "ca_inventory_drop")
        {
            requestingPlayer.DropFormalInventorySelection();
        }
        else if (e.Name == "ca_palomo_merchant_close")
        {
            requestingPlayer.ClosePalomoMerchant();
        }
        else if (e.Name == "ca_palomo_merchant_next")
        {
            requestingPlayer.CyclePalomoMerchantSelection(1);
        }
        else if (e.Name == "ca_palomo_merchant_previous")
        {
            requestingPlayer.CyclePalomoMerchantSelection(-1);
        }
        else if (e.Name == "ca_palomo_merchant_mode")
        {
            requestingPlayer.TogglePalomoMerchantMode();
        }
        else if (e.Name == "ca_palomo_merchant_quantity_previous")
        {
            requestingPlayer.CyclePalomoMerchantQuantity(-1);
        }
        else if (e.Name == "ca_palomo_merchant_quantity_next")
        {
            requestingPlayer.CyclePalomoMerchantQuantity(1);
        }
        else if (e.Name == "ca_palomo_merchant_transact")
        {
            requestingPlayer.ExecutePalomoMerchantTransaction();
        }
        else if (e.Name == "ca_journal_menu_move_sound")
        {
            requestingPlayer.A_StartSound(
                "caelum/ui/menu_move",
                CHAN_6,
                CHANF_LOCAL | CHANF_UI
            );
        }
        else if (e.Name == "ca_journal_menu_select_sound")
        {
            requestingPlayer.A_StartSound(
                "caelum/ui/menu_select",
                CHAN_6,
                CHANF_LOCAL | CHANF_UI
            );
        }
        else if (e.Name == "ca_crafting_page_turn_sound")
        {
            requestingPlayer.A_StartSound(
                "caelum/ui/crafting_page_turn",
                CHAN_6,
                CHANF_LOCAL | CHANF_UI
            );
        }
        else if (e.Name == "ca_crafting_session_close")
        {
            requestingPlayer.CloseCraftingStationSession();
        }
        else if (e.Name == "ca_crafting_toggle")
        {
            requestingPlayer.ToggleCraftingMenu();
        }
        else if (e.Name == "ca_crafting_recipe_next")
        {
            requestingPlayer.CycleCraftingRecipe(1);
        }
        else if (e.Name == "ca_crafting_recipe_previous")
        {
            requestingPlayer.CycleCraftingRecipe(-1);
        }
        else if (e.Name == "ca_crafting_filter")
        {
            requestingPlayer.CycleCraftingRecipeFilter();
        }
        else if (e.Name == "ca_crafting_tier")
        {
            requestingPlayer.CycleCraftingTier();
        }
        else if (e.Name == "ca_crafting_size")
        {
            requestingPlayer.CycleCraftingSize();
        }
        else if (e.Name == "ca_crafting_batch")
        {
            requestingPlayer.CycleCraftingBatch();
        }
        else if (e.Name == "ca_crafting_efficiency")
        {
            requestingPlayer.CycleCraftingEfficiency();
        }
        else if (e.Name == "ca_crafting_step_next")
        {
            requestingPlayer.CycleCraftingBlueprintSelection(1);
        }
        else if (e.Name == "ca_crafting_step_previous")
        {
            requestingPlayer.CycleCraftingBlueprintSelection(-1);
        }
        else if (e.Name == "ca_crafting_cancel_task")
        {
            requestingPlayer.CancelCraftingTask();
        }
        else if (e.Name == "ca_crafting_repair_selected")
        {
            requestingPlayer.BeginRepairSelectedEquipment();
        }
        else if (e.Name == "ca_crafting_dismantle_selected")
        {
            requestingPlayer.BeginDismantleSelectedEquipment();
        }
        else if (e.Name == "ca_crafting_create")
        {
            requestingPlayer.CraftSelectedPhysicalWeapon();
        }
        else if (e.Name == "ca_cycle_weapon_slot_2")
        {
            requestingPlayer.CycleEquippedWeaponSlot(2);
        }
    }

    override void RenderOverlay(RenderEvent event)
    {
        if (consoleplayer < 0
            || TitleFont == null || TextFont == null || SmallFont == null
            || InventoryFont == null)
        {
            return;
        }
        CaelumPlayer localPlayer = CaelumPlayer(players[consoleplayer].mo);
        if (localPlayer == null) { return; }
        let plan = CaelumJourneyPlan(localPlayer.FindInventory("CaelumJourneyPlan"));
        if (plan != null && plan.Open && plan.Available != null) { DrawJourney(plan); return; }
        let rest = CaelumRestState(localPlayer.FindInventory("CaelumRestState"));
        if (rest != null && rest.Status == CaelumRestRules.STATUS_ACTIVE)
        {
            DrawRest(localPlayer, rest);
            return;
        }
        if (localPlayer.PalomoMerchantMenuOpen)
        {
            DrawPalomoMerchant(localPlayer);
            return;
        }
        if (!IsJournalOpen()) { DrawSewerTravelHint(localPlayer); return; }
        int currentPage = GetJournalPage();
        if (currentPage == 2 && CaelumScheduleCalendar.IsOpen())
        { CaelumScheduleCalendar.Draw(self, localPlayer); return; }

        Screen.Dim(0x05070A, 0.92, 0, 0, Screen.GetWidth(), Screen.GetHeight());
        DrawPanel(16.0, 12.0, 608.0, 336.0);
        DrawCenteredText(TitleFont, Font.CR_GOLD, 320.0, 16.0,
            StringTable.Localize("CA_JOURNAL_TITLE", false));
        DrawNavigation();
        DrawCenteredText(TextFont, Font.CR_GOLD, 320.0, 106.0,
            StringTable.Localize(GetPageKey(currentPage), false));

        if (currentPage == 0) { DrawInventoryPage(localPlayer); }
        else if (currentPage == 1) { DrawCharacterPage(localPlayer); }
        else if (currentPage == 2) { DrawWorldPage(localPlayer); }
        else if (currentPage == 3) { DrawCraftsPage(localPlayer); }
        else if (currentPage == 4) { DrawQuestPage(localPlayer); }
        else if (currentPage == 5) { DrawReputationPage(localPlayer); }
        else { DrawTarotPage(localPlayer); }

        if (currentPage == 3 && localPlayer.CraftingMenuOpen)
        {
            DrawCenteredText(SmallFont, Font.CR_GRAY, 320.0, 316.0,
                StringTable.Localize("CA_JOURNAL_CRAFTING_HELP", false));
            DrawCenteredText(SmallFont, Font.CR_GRAY, 320.0, 328.0,
                StringTable.Localize("CA_JOURNAL_CRAFTING_HELP_2", false));
        }
        else
        {
            bool hasEdges = currentPage == 0 || currentPage == 4;
            DrawCenteredText(SmallFont, Font.CR_GRAY, 320.0, hasEdges ? 316.0 : 322.0,
                StringTable.Localize(
                    currentPage == 0 ? "CA_JOURNAL_INVENTORY_HELP"
                        : currentPage == 4 && localPlayer.JournalKnownQuestCount > 0
                            ? IsQuestDetailOpen() ? "CA_Q_DETAIL_HELP"
                                : localPlayer.JournalKnownQuestCount == 1
                                    ? "CA_QUEST_SINGLE_HELP" : "CA_QUEST_LIST_HELP"
                            : "CA_JOURNAL_NAVIGATION_HELP",
                    false
                ));
            if (hasEdges)
                DrawCenteredText(SmallFont, Font.CR_GRAY, 320.0, 328.0,
                    StringTable.Localize("CA_JOURNAL_EDGE_HELP", false));
        }
    }
}
