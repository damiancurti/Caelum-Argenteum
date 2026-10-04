// Rescate y escolta de los cuatro prisioneros de MAP02. La autoridad del
// progreso vive en CaelumPersistentCharacterState; estos marcadores y acciones
// son la vista USDF nativa y nunca duplican la recompensa.

class CaelumPrisonerFreed0Token : CaelumPalomoDialogueMarker {}
class CaelumPrisonerFreed1Token : CaelumPalomoDialogueMarker {}
class CaelumPrisonerFreed2Token : CaelumPalomoDialogueMarker {}
class CaelumPrisonerFreed3Token : CaelumPalomoDialogueMarker {}

class CaelumPrisonerClaimed0Token : CaelumPalomoDialogueMarker {}
class CaelumPrisonerClaimed1Token : CaelumPalomoDialogueMarker {}
class CaelumPrisonerClaimed2Token : CaelumPalomoDialogueMarker {}
class CaelumPrisonerClaimed3Token : CaelumPalomoDialogueMarker {}

class CaelumPrisonerReleaseAction : CaelumPalomoDialogueAction
{
    override bool Use(bool pickup)
    {
        CaelumPlayer user = CaelumPlayer(Owner);
        if (user == null || user.player == null) { return false; }
        CaelumAnchoredResident speaker = CaelumAnchoredResident(
            user.player.ConversationNPC
        );
        if (speaker == null || !speaker.IsEscortPrisoner()
            || speaker.EscortPrisonerPort)
        {
            return false;
        }
        speaker.ReleaseEscortPrisoner(user);
        CaelumPrisonerRescue.Sync(user);
        return true;
    }
}

class CaelumPrisonerClaimAction : CaelumPalomoDialogueAction
{
    override bool Use(bool pickup)
    {
        CaelumPlayer user = CaelumPlayer(Owner);
        if (user == null || user.player == null) { return false; }
        CaelumAnchoredResident speaker = CaelumAnchoredResident(
            user.player.ConversationNPC
        );
        if (speaker == null || !speaker.IsEscortPrisoner()
            || !speaker.EscortPrisonerPort)
        {
            return false;
        }
        bool claimed = user.ClaimPrisonerPortReward(
            speaker.EscortPrisonerId,
            CaelumPrisonerRescue.FactionFor(speaker.EscortPrisonerId)
        );
        CaelumPrisonerRescue.Sync(user);
        return claimed;
    }
}

class CaelumPrisonerRescue : Object play
{
    static int FactionFor(int prisonerId)
    {
        switch (prisonerId)
        {
            case CaelumConstants.PRISONER_UNITARIO:
                return CaelumConstants.FACTION_UNITARIOS;
            case CaelumConstants.PRISONER_FEDERAL:
                return CaelumConstants.FACTION_FEDERALS;
            case CaelumConstants.PRISONER_BESTIA:
                return CaelumConstants.FACTION_PUEBLOS_LIBRES;
            case CaelumConstants.PRISONER_TAROT:
                return CaelumConstants.FACTION_CULT_TAROT;
        }
        return -1;
    }

    static class<Inventory> FreedTokenClass(int prisonerId)
    {
        switch (prisonerId)
        {
            case 0: return "CaelumPrisonerFreed0Token";
            case 1: return "CaelumPrisonerFreed1Token";
            case 2: return "CaelumPrisonerFreed2Token";
            case 3: return "CaelumPrisonerFreed3Token";
        }
        return null;
    }

    static class<Inventory> ClaimedTokenClass(int prisonerId)
    {
        switch (prisonerId)
        {
            case 0: return "CaelumPrisonerClaimed0Token";
            case 1: return "CaelumPrisonerClaimed1Token";
            case 2: return "CaelumPrisonerClaimed2Token";
            case 3: return "CaelumPrisonerClaimed3Token";
        }
        return null;
    }

    static void Sync(CaelumPlayer user)
    {
        if (user == null || user.player == null) { return; }
        CaelumSiegeIntelligence.ObservePayment(user);
        for (int prisonerId = 0;
            prisonerId < CaelumConstants.PRISONER_COUNT; prisonerId++)
        {
            int state = user.GetPrisonerRescueState(prisonerId);
            user.SetPalomoDialogueToken(
                FreedTokenClass(prisonerId),
                state >= CaelumConstants.PRISONER_STATE_FOLLOWING
            );
            user.SetPalomoDialogueToken(
                ClaimedTokenClass(prisonerId),
                user.IsPlayerPrisonerRewardClaimed(prisonerId)
            );
        }
    }

    static bool OpenDialogue(CaelumPlayer user, CaelumAnchoredResident speaker)
    {
        if (user == null || user.player == null || speaker == null
            || !speaker.IsEscortPrisoner())
        {
            return false;
        }
        Sync(user);
        int conversation = speaker.EscortPrisonerPort
            ? CaelumConstants.PRISONER_PORT_CONVERSATION_BASE
                + speaker.EscortPrisonerId
            : CaelumConstants.PRISONER_CONVERSATION_BASE
                + speaker.EscortPrisonerId;
        return CaelumFactionCondition.OpenDialogue(user, speaker, conversation);
    }
}

// #78: presentación compartida; no introduce otro reloj ni un disparador de asedio.
class CaelumSiegeIntelligence : Object
{
    static play void ObservePayment(CaelumPlayer user)
    {
        let record = user.GetPersistentCharacterState(false);
        int quest = CaelumConstants.QUEST_PORT_SIEGE;
        if (record == null || record.QuestState[quest] != CaelumConstants.QUEST_STATE_UNDISCOVERED) return;
        bool paid = false;
        for (int i = 0; i < CaelumConstants.PRISONER_COUNT; i++)
            if (record.PrisonerRewardClaimed[i]) paid = true;
        if (!paid) return;
        // Reconstruye también el acceso en partidas ya pagadas, sin repetir acciones.
        record.QuestState[quest] = record.PortSiegeNarrativeComplete
            ? CaelumConstants.QUEST_STATE_COMPLETED : CaelumConstants.QUEST_STATE_ACTIVE;
        record.QuestStage[quest] = record.PortSiegeNarrativeComplete ? 2
            : record.PortSiegeNarrativeStarted ? 1 : 0;
        for (int objective = 0; objective < 2; objective++)
        {
            int slot = record.GetQuestObjectiveStorageIndex(quest, objective);
            record.QuestObjectiveKnown[slot] = true;
            record.QuestObjectiveTarget[slot] = objective == 0 ? 12 : 1;
        }
        user.RefreshSocialJournalSnapshot();
    }

    static ui String Text(CaelumPlayer user)
    {
        int stage = user == null ? 0 : user.JournalQuestStage[CaelumConstants.QUEST_PORT_SIEGE];
        String key = stage >= 2 ? "CA_PRISONER_SIEGE_COMPLETE"
            : stage == 1 ? "CA_PRISONER_SIEGE_ACTIVE" : "CA_PRISONER_SIEGE_PENDING";
        String text = StringTable.Localize(key, false);
        text.Replace("%PLACE%", StringTable.Localize(
            CaelumWorldCatalogue.LocationNameKey(CaelumWorldCatalogue.LOCATION_PORT), false));
        // Las fechas son las del evento real registrado; no se calculan plazos nuevos.
        let agenda = user == null ? null : CaelumScheduleState(user.FindInventory("CaelumScheduleState"));
        let event = agenda == null ? null : agenda.FindKey(stage >= 2 ? "port16_siege_end" : "port16_siege_start");
        if (stage > 0 && event != null)
            text = text .. "\n" .. StringTable.Localize(stage >= 2
                ? "CA_PRISONER_SIEGE_ENDED_AT" : "CA_PRISONER_SIEGE_STARTED_AT", false)
                .. " " .. CaelumScheduleRules.DateText(event.FirstStamp());
        return text;
    }

    static ui bool IsPaidPage(String page)
    {
        return page ~== "prisoner_unitario_claimed" || page ~== "prisoner_federal_claimed"
            || page ~== "prisoner_bestia_claimed" || page ~== "prisoner_tarot_claimed";
    }
}
