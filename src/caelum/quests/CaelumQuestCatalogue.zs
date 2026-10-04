// #35: catálogo de presentación. No escribe progreso ni entrega recompensas.
class CaelumQuestCatalogue : Object
{
    static bool IsMain(int id)
    { return id == CaelumConstants.QUEST_MAIN_M00_THE_FOOL || id == CaelumConstants.QUEST_GUARD_CAPTAIN; }
    static bool IsRescue(int id)
    { return id >= CaelumConstants.QUEST_RESCUE_FIRST
        && id < CaelumConstants.QUEST_RESCUE_FIRST + CaelumConstants.PRISONER_COUNT; }

    static String TitleKey(int id)
    {
        switch (id)
        {
            case 0: return "CA_Q_M01_TITLE";
            case 1: return "CA_Q_SIDE_ROUTE_TITLE";
            case 2: return "CA_Q_SIDE_WAIT_TITLE";
            case 3: return "CA_DEMO_PORT_TITLE";
            case 4: return "CA_Q_SEWER_TITLE";
            case 5: return "CA_Q_RESCUE_0";
            case 6: return "CA_Q_RESCUE_1";
            case 7: return "CA_Q_RESCUE_2";
            case 8: return "CA_Q_RESCUE_3";
            case CaelumConstants.QUEST_GUARD_CAPTAIN: return "CA_Q_GUARD_CAPTAIN_TITLE";
        }
        return "CA_JOURNAL_QUESTS";
    }

    // Filtros independientes: tipo 0/todos, 1/principal, 2/secundaria;
    // estado 0/todos, 1/activa, 2/completa, 3/otros estados ya existentes.
    static bool Matches(int id, int state, int kind, int status)
    {
        if (id < 0 || id >= CaelumConstants.QUEST_DEFINED_COUNT
            || state == CaelumConstants.QUEST_STATE_UNDISCOVERED) return false;
        if (kind == 1 && !IsMain(id) || kind == 2 && IsMain(id)) return false;
        if (status == 1) return state == CaelumConstants.QUEST_STATE_ACTIVE;
        if (status == 2) return state == CaelumConstants.QUEST_STATE_COMPLETED;
        if (status == 3) return state != CaelumConstants.QUEST_STATE_ACTIVE
            && state != CaelumConstants.QUEST_STATE_COMPLETED;
        return true;
    }

    static play int State(CaelumPersistentCharacterState record, int id)
    {
        if (record == null || id < 0 || id >= CaelumConstants.QUEST_DEFINED_COUNT) return 0;
        if (id < CaelumConstants.QUEST_SEWERS || id == CaelumConstants.QUEST_GUARD_CAPTAIN)
            return record.QuestState[id];
        if (id == CaelumConstants.QUEST_SEWERS)
        {
            // La carta es evidencia admitida por #33 para guardados antiguos.
            if (record.SewerZupayDefeated || record.HasTarotCard(CaelumConstants.TAROT_CUPS_ACE))
                return CaelumConstants.QUEST_STATE_COMPLETED;
            return record.WorldLocationVisited[CaelumWorldCatalogue.LOCATION_SEWERS]
                ? CaelumConstants.QUEST_STATE_ACTIVE : CaelumConstants.QUEST_STATE_UNDISCOVERED;
        }
        int prisoner = id - CaelumConstants.QUEST_RESCUE_FIRST;
        int outcome = record.PrisonerRescueState[prisoner];
        if (record.PrisonerRewardClaimed[prisoner] || outcome == CaelumConstants.PRISONER_STATE_EXTRACTED)
            return CaelumConstants.QUEST_STATE_COMPLETED;
        if (outcome == CaelumConstants.PRISONER_STATE_FOLLOWING) return CaelumConstants.QUEST_STATE_ACTIVE;
        // Sólo presenta la muerte ya registrada; no añade reglas de fracaso.
        if (outcome == CaelumConstants.PRISONER_STATE_DEAD) return CaelumConstants.QUEST_STATE_FAILED;
        return CaelumConstants.QUEST_STATE_UNDISCOVERED;
    }

    static play void RefreshObserved(CaelumPlayer user)
    {
        let record = user.GetPersistentCharacterState(false);
        if (record == null) return;
        for (int id = CaelumConstants.QUEST_SEWERS; id < CaelumConstants.QUEST_DEFINED_COUNT; id++)
            if (user.JournalQuestState[id] != State(record, id)
                || (IsRescue(id) && user.JournalQuestRewardClaimed[id]
                    != record.PrisonerRewardClaimed[id - CaelumConstants.QUEST_RESCUE_FIRST]))
            { user.RefreshSocialJournalSnapshot(); return; }
    }
}
