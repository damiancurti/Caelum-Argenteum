// #119: una implementación de Tarot, sin una segunda copia del estado.
// El Inventory viajero conserva campos y revisiones; el servicio recibe al propietario.
class CaelumTarotService : Object play
{
    const REVISION = 1;

    static void EnsureRevision(CaelumPersistentCharacterState record)
    {
        if (record == null || record.TarotPowerRevision >= REVISION) return;
        // Los saves anteriores no tenían carta equipada: no interpretar el
        // cero predeterminado ni el cursor local como una elección de El loco.
        for (int i = 0; i < CaelumConstants.TAROT_CARD_COUNT; i++)
        { record.TarotSelected[i] = false; record.TarotActive[i] = false; }
        record.TarotEffectTics = 0;
        record.TarotCooldownTics = 0;
        record.TarotPowerRevision = REVISION;
    }

    static bool ValidUser(CaelumPlayer user)
    {
        return user != null && user.player != null && user.health > 0
            && user.player.playerstate == PST_LIVE
            && user.CharacterCreationComplete && !user.CreationWizardOpen
            && !(user.player.cheats & CF_PREDICTING);
    }

    static void Feedback(CaelumPlayer user, String key)
    {
        if (user != null) CaelumNotifications.Notify(user, StringTable.Localize(key, false));
    }

    static clearscope bool Implemented(int card)
    {
        return card == CaelumConstants.TAROT_THE_FOOL
            || (card >= CaelumConstants.TAROT_MAJOR_COUNT && card < CaelumConstants.TAROT_CARD_COUNT);
    }

    static clearscope int SelectedCount(CaelumPersistentCharacterState record)
    {
        int count = 0;
        if (record != null)
            for (int i = 0; i < CaelumConstants.TAROT_CARD_COUNT; i++)
                if (record.TarotSelected[i]) count++;
        return count;
    }

    static bool Select(CaelumPlayer user, int card)
    {
        if (!ValidUser(user)) return false;
        let record = user.GetPersistentCharacterState(false);
        EnsureRevision(record);
        if (record == null || !HasTarotCard(record, card))
        { Feedback(user, "CA_TAROT_POWER_UNOWNED"); return false; }
        if (!record.TarotSelected[card] && !Implemented(card))
        { Feedback(user, "CA_TAROT_POWER_UNIMPLEMENTED"); return false; }
        if (!record.TarotSelected[card] && SelectedCount(record) >= CaelumConstants.TAROT_SELECTED_LIMIT)
        { Feedback(user, "CA_TAROT_POWER_LIMIT"); return false; }
        record.TarotSelected[card] = !record.TarotSelected[card];
        user.RefreshSocialJournalSnapshot();
        user.PersistCharacterState();
        Feedback(user, record.TarotSelected[card] ? "CA_TAROT_POWER_SELECTED" : "CA_TAROT_POWER_REMOVED");
        return true;
    }

    static bool Activate(CaelumPlayer user)
    {
        if (!ValidUser(user)) return false;
        let record = user.GetPersistentCharacterState(false);
        EnsureRevision(record);
        if (record == null || SelectedCount(record) == 0)
        { Feedback(user, "CA_TAROT_POWER_NONE"); return false; }
        if (SelectedCount(record) > CaelumConstants.TAROT_SELECTED_LIMIT)
        { Feedback(user, "CA_TAROT_POWER_LIMIT"); return false; }
        for (int i = 0; i < CaelumConstants.TAROT_CARD_COUNT; i++)
        {
            if (!record.TarotSelected[i]) continue;
            if (!HasTarotCard(record, i))
            { Feedback(user, "CA_TAROT_POWER_UNOWNED"); return false; }
            if (!Implemented(i))
            { Feedback(user, "CA_TAROT_POWER_UNIMPLEMENTED"); return false; }
        }
        // La misma validación protege tanto User3 como futuras interfaces.
        if (user.HasActiveConversation() || user.EquipmentMenuOpen || user.CraftingMenuOpen
            || user.PalomoMerchantMenuOpen || user.CraftingTaskActive || user.CombatChannelModeActive
            || user.StaffCastPending || user.ForcedSleepTics > 0 || CaelumRestState.IsActive(user)
            || CaelumTimeSkipState.IsOpen(user) || (user.player.cheats & CF_TOTALLYFROZEN))
        { Feedback(user, "CA_TAROT_POWER_CONTEXT"); return false; }
        if (record.TarotCooldownTics > 0 || record.TarotEffectTics > 0)
        { Feedback(user, "CA_TAROT_POWER_COOLDOWN"); return false; }
        if (user.CurrentAnima < CaelumConstants.TAROT_ACTIVATION_ANIMA)
        { Feedback(user, "CA_TAROT_POWER_ANIMA"); return false; }
        // Preparar la única instancia nativa que puede fallar antes del pago.
        if (record.TarotSelected[CaelumConstants.TAROT_THE_FOOL]
            && user.GiveInventoryType("CaelumTarotFlight") == null) return false;
        user.CurrentAnima -= CaelumConstants.TAROT_ACTIVATION_ANIMA;
        record.TarotEffectTics = CaelumConstants.TAROT_EFFECT_SECONDS * TICRATE;
        record.TarotCooldownTics = CaelumConstants.TAROT_COOLDOWN_SECONDS * TICRATE;
        for (int i = 0; i < CaelumConstants.TAROT_CARD_COUNT; i++)
            record.TarotActive[i] = record.TarotSelected[i];
        user.ApplyCharacterProfile();
        user.RefreshSocialJournalSnapshot();
        user.PersistCharacterState();
        Feedback(user, "CA_TAROT_POWER_ACTIVATED");
        return true;
    }

    static void Advance(CaelumPlayer user, int elapsedTics = 1)
    {
        let record = user.GetPersistentCharacterState(false);
        if (record == null || elapsedTics <= 0
            || (user.player != null && (user.player.cheats & CF_PREDICTING))) return;
        EnsureRevision(record);
        record.TarotCooldownTics = Max(0, record.TarotCooldownTics - elapsedTics);
        if (record.TarotEffectTics > 0)
        {
            record.TarotEffectTics = Max(0, record.TarotEffectTics - elapsedTics);
            if (record.TarotEffectTics == 0)
            {
                for (int i = 0; i < CaelumConstants.TAROT_CARD_COUNT; i++) record.TarotActive[i] = false;
                let flight = user.FindInventory("CaelumTarotFlight");
                if (flight != null) flight.Destroy();
                user.ApplyCharacterProfile();
                user.RefreshSocialJournalSnapshot();
                Feedback(user, "CA_TAROT_POWER_EXPIRED");
            }
        }
        RestoreNativeEffect(user);
    }

    static clearscope bool HasTarotCard(CaelumPersistentCharacterState record, int card)
    {
        return card >= 0 && card < CaelumConstants.TAROT_CARD_COUNT && record.TarotOwned[card];
    }

    static clearscope int CountTarotCards(CaelumPersistentCharacterState record)
    {
        int count = 0;
        for (int card = 0; card < CaelumConstants.TAROT_CARD_COUNT; card++)
            if (record.TarotOwned[card]) count++;
        return count;
    }

    static clearscope int GetTarotAttributeBonusPercent(CaelumPersistentCharacterState record)
    {
        int percent = 0;
        for (int card = 0; card < CaelumConstants.TAROT_CARD_COUNT; card++)
            if (record.TarotOwned[card]) percent += card < CaelumConstants.TAROT_MAJOR_COUNT
                ? CaelumConstants.TAROT_MAJOR_ATTRIBUTE_PERCENT : CaelumConstants.TAROT_MINOR_ATTRIBUTE_PERCENT;
        return percent;
    }

    static clearscope double GetTarotMinorBaseBonus(CaelumPersistentCharacterState record, int attribute)
    {
        int tenths = 0;
        for (int card = CaelumConstants.TAROT_MAJOR_COUNT; card < CaelumConstants.TAROT_CARD_COUNT; card++)
        {
            if (!HasTarotCard(record, card)) continue;
            int contribution = MinorTenths(card, attribute);
            tenths += contribution;
            if (record.TarotEffectTics > 0 && record.TarotActive[card]) tenths += contribution;
        }
        return tenths / 10.0;
    }

    static bool CanCaptureMainM00Fool(CaelumPersistentCharacterState record)
    {
        record.EnsureQuestStateInitialized();
        return record.MagicBoxOwned && record.MagicBoxItemId > 0
            && record.QuestState[CaelumConstants.QUEST_MAIN_M00_THE_FOOL] == CaelumConstants.QUEST_STATE_ACTIVE
            && record.QuestStage[CaelumConstants.QUEST_MAIN_M00_THE_FOOL] == CaelumConstants.MAIN_M00_STATE_BOX_RECEIVED
            && record.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_MAGIC_BOX_GRANTED)
            && record.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_ARGENTO_COMPLETE)
            && record.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_CAELLA_COMPLETE)
            && record.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_RONNIE_COMPLETE)
            && record.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_RULO_COMPLETE)
            && !record.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_THE_FOOL_CAPTURED)
            && !HasTarotCard(record, CaelumConstants.TAROT_THE_FOOL);
    }

    static bool RecordMainM00FoolCapture(CaelumPersistentCharacterState record)
    {
        if (!CanCaptureMainM00Fool(record) || !record.MainM00FoolRevealed) return false;
        if (!record.TryAdvanceMainM00State(CaelumConstants.MAIN_M00_STATE_BOX_RECEIVED,
            CaelumConstants.MAIN_M00_STATE_FOOL_CAPTURED)) return false;
        record.TarotOwned[CaelumConstants.TAROT_THE_FOOL] = true;
        record.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_THE_FOOL_CAPTURED);
        record.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_EXIT_READY);
        int objective = record.GetQuestObjectiveStorageIndex(CaelumConstants.QUEST_MAIN_M00_THE_FOOL,
            CaelumConstants.MAIN_M00_OBJECTIVE_CAPTURE_FOOL);
        record.QuestObjectiveKnown[objective] = true;
        record.QuestObjectiveTarget[objective] = 1;
        record.QuestObjectiveProgress[objective] = 1;
        return true;
    }

    static clearscope int Suit(int card)
    { return (card-CaelumConstants.TAROT_MAJOR_COUNT)/CaelumConstants.TAROT_MINOR_RANK_COUNT; }

    static clearscope int Rank(int card)
    { return (card-CaelumConstants.TAROT_MAJOR_COUNT)%CaelumConstants.TAROT_MINOR_RANK_COUNT; }

    static clearscope bool Minor(int card)
    { return card>=CaelumConstants.TAROT_MAJOR_COUNT && card<CaelumConstants.TAROT_CARD_COUNT; }

    static clearscope int MinorTenths(int card, int attribute)
    {
        if (!Minor(card) || attribute < 0 || attribute >= CaelumConstants.PRIMARY_ATTRIBUTE_COUNT) return 0;
        int family = attribute / 3;
        int suit = family == CaelumConstants.LAYER_PHYSICAL ? CaelumConstants.TAROT_SUIT_WANDS
            : family == CaelumConstants.LAYER_TECHNICAL ? CaelumConstants.TAROT_SUIT_COINS
            : family == CaelumConstants.LAYER_SOCIAL ? CaelumConstants.TAROT_SUIT_CUPS : CaelumConstants.TAROT_SUIT_SWORDS;
        if (Suit(card) != suit) return 0;
        int rank = Rank(card), position = attribute % 3;
        if (rank == 0) return 10;
        if (rank == 13) return 5;
        if (rank >= 10 && rank - 10 == position) return 6;
        if (rank <= 9 && (rank - 1) / 3 == position) return 3;
        return 0;
    }

    static bool CanCaptureArcana(CaelumPersistentCharacterState record, int card)
    {
        if (record == null || HasTarotCard(record, card)) return false;
        if (card == CaelumConstants.TAROT_CUPS_ACE)
            return level.MapName == "MAP02" && record.SewerZupayDefeated;
        if (card == CaelumConstants.TAROT_WANDS_KNIGHT)
            return level.MapName == "MAP06" && record.ArcanaAvailable[card]
                && CaelumDemoNarrative.PortCardReady(record);
        return false;
    }

    static bool CanApproach(CaelumPlayer user, CaelumM00FoolEssence essence)
    {
        if (user == null || user.player == null || user.health <= 0
            || !user.CharacterCreationComplete || user.CreationWizardOpen
            || (user.player.cheats & CF_PREDICTING)
            || essence == null || !IsAvailable(essence, user)) return false;
        return user.Distance2D(essence) <= 128 && Abs(user.Pos.Z-essence.Pos.Z) <= 48
            && user.CheckSight(essence);
    }

    static bool CommitCapture(CaelumPlayer user, CaelumM00FoolEssence essence)
    {
        if (!CanApproach(user, essence) || essence.CaptureUser != user
            || essence.CaptureTics < CaelumConstants.MAIN_M00_FOOL_CAPTURE_TICS
            || essence.CaptureImage == null || !CaelumMainM00FoolCapture.HasOwnedBox(user)) return false;
        let record = user.GetPersistentCharacterState(false);
        if (record == null || record.MagicBoxItemId != essence.CaptureBoxId
            || !CaelumTarotDeckRules.InOwnedBox(user, true)
            || !RecordCapture(essence, record)) return false;
        user.ApplyCharacterProfile();
        user.RefreshSocialJournalSnapshot();
        user.RefreshFormalInventorySnapshot();
        user.SyncPalomoDialogueTokens();
        user.PersistCharacterState();
        EventHandler.SendInterfaceEvent(user.PlayerNumber(), "ca_tarot_capture");
        CaelumNotifications.Notify(user, String.Format(StringTable.Localize("CA_ARCANA_OBTAINED", false),
            StringTable.Localize(CaelumTarotArt.NameKey(essence.CardId()), false)));
        return true;
    }

    static bool IsAvailable(CaelumM00FoolEssence essence, CaelumPlayer user)
    {
        if (user == null) return false;
        let record = user.GetPersistentCharacterState(false);
        if (record == null || HasTarotCard(record, essence.CardId())) return false;
        if (essence.CardId() == CaelumConstants.TAROT_THE_FOOL)
            return level.MapName == "MAP01" && essence.StoryPlaced && CanCaptureMainM00Fool(record);
        return CanCaptureArcana(record, essence.CardId());
    }

    static bool IsRevealedFor(CaelumM00FoolEssence essence, CaelumPersistentCharacterState record)
    {
        return essence.CardId() == CaelumConstants.TAROT_THE_FOOL
            ? record.MainM00FoolRevealed : record.ArcanaRevealed[essence.CardId()];
    }

    static bool RecordCapture(CaelumM00FoolEssence essence, CaelumPersistentCharacterState record)
    {
        if (!IsRevealedFor(essence, record)) return false;
        if (essence.CardId() == CaelumConstants.TAROT_THE_FOOL) return RecordMainM00FoolCapture(record);
        if (!CanCaptureArcana(record, essence.CardId())) return false;
        record.TarotOwned[essence.CardId()] = true;
        return true;
    }

    // Lecturas comunes para UI, vuelo y viajes: nunca avanzan el reloj.
    static clearscope int EffectTics(CaelumPersistentCharacterState record)
    { return record == null ? 0 : record.TarotEffectTics; }
    static clearscope int CooldownTics(CaelumPersistentCharacterState record)
    { return record == null ? 0 : record.TarotCooldownTics; }
    static clearscope bool IsActive(CaelumPersistentCharacterState record, int card)
    { return EffectTics(record) > 0 && card >= 0 && card < CaelumConstants.TAROT_CARD_COUNT && record.TarotActive[card]; }
    static clearscope bool IsSelected(CaelumPersistentCharacterState record, int card)
    { return record != null && card >= 0 && card < CaelumConstants.TAROT_CARD_COUNT && record.TarotSelected[card]; }

    // La propiedad física sigue perteneciendo al contrato de inventario.
    static bool HasPhysicalDeck(CaelumPlayer user)
    { return CaelumInventoryService.FindOwnedTarotDeck(user) != null; }

    // GZDoom retira PowerFlight al salir de un hub. El registro conserva el
    // efecto pagado: reponer sólo la instancia ausente, sin pagar ni reiniciar.
    static void RestoreNativeEffect(CaelumPlayer user)
    {
        if (user == null || user.player == null || user.health <= 0
            || (user.player.cheats & CF_PREDICTING)) return;
        let record = user.GetPersistentCharacterState(false);
        if (IsActive(record, CaelumConstants.TAROT_THE_FOOL)
            && user.FindInventory("CaelumTarotFlight") == null)
            user.GiveInventoryType("CaelumTarotFlight");
    }

    static void Reveal(CaelumPersistentCharacterState record, int card)
    {
        if (card == CaelumConstants.TAROT_THE_FOOL) record.MainM00FoolRevealed = true;
        else record.ArcanaRevealed[card] = true;
    }
    static void RefreshJournalSnapshot(CaelumPlayer user, CaelumPersistentCharacterState persistentState)
    {
        EnsureRevision(persistentState);
        for (int card = 0; card < CaelumConstants.TAROT_CARD_COUNT; card++)
            user.TarotSelectedSnapshot[card] = persistentState.TarotSelected[card];
        user.TarotOwnedCountSnapshot = CountTarotCards(persistentState);
        user.TarotAttributeBonusSnapshot = GetTarotAttributeBonusPercent(persistentState);
        for (int attribute = 0; attribute < CaelumConstants.PRIMARY_ATTRIBUTE_COUNT; attribute++)
            user.TarotMinorBaseSnapshot[attribute] = GetTarotMinorBaseBonus(persistentState, attribute);
        for (int card = 0; card < CaelumConstants.TAROT_CARD_COUNT; card++)
            user.TarotOwnedSnapshot[card] = HasTarotCard(persistentState, card);
        user.TarotFoolOwnedSnapshot = HasTarotCard(persistentState, CaelumConstants.TAROT_THE_FOOL);
        user.TarotCupsAceOwnedSnapshot = HasTarotCard(persistentState, CaelumSewerMaze.CUPS_ACE);
        user.MainM00FoolRevealedSnapshot = persistentState.MainM00FoolRevealed;
    }
}
