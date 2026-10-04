// La colección conserva la autoridad de propiedad. El cursor de ilustraciones
// del Diario sólo solicita una selección; nunca concede esencias ni poderes.
class CaelumTarotPowers : Object play
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

    static int SelectedCount(CaelumPersistentCharacterState record)
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
        if (record == null || !record.HasTarotCard(card))
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
            if (!record.HasTarotCard(i))
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

    // El tiempo personal también gobierna recargas/clases y los saltos de
    // descanso. Cargar o cambiar de mapa nunca reinicia estos contadores.
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
    }
}

// El motor proporciona los controles y flags nativos de vuelo. El registro
// personal fija la caducidad incluso en mapas con infinite_flight.
class CaelumTarotFlight : PowerFlight
{
    override void Tick()
    {
        let user = CaelumPlayer(Owner);
        let record = user == null ? null : user.GetPersistentCharacterState(false);
        if (record == null || record.TarotEffectTics <= 0
            || !record.TarotActive[CaelumConstants.TAROT_THE_FOOL])
        { Destroy(); return; }
        EffectTics = record.TarotEffectTics + 1;
        Super.Tick();
    }

    override TextureID GetPowerupIcon()
    { return TexMan.CheckForTexture(CaelumTarotArt.FrontPath(CaelumConstants.TAROT_THE_FOOL)); }
}
