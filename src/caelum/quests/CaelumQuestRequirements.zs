// #418: condiciones sin progreso propio. Los hechos siguen en sus registros
// autorizados; una condición nunca descubre objetivos ni entrega recompensas.
class CaelumQuestRequirements : Object play
{
    const ALL = 0;
    const ANY = 1;
    const QUEST_STATE = 2;
    const QUEST_STAGE = 3;
    const KNOWN_OBJECTIVE = 4;
    const MAIN_FLAG = 5;
    const REPUTATION = 6;
    const MEMBERSHIP = 7;
    // Límite de integridad del grafo; no es una regla de balance.
    const MAX_DEPTH = 32;

    int Kind, Subject, Value, Objective;
    Array<CaelumQuestRequirements> Terms;

    static bool Matches(CaelumPersistentCharacterState record, int kind,
        int subject, int value, int objective = 0)
    {
        if (record == null) return false;
        if (kind == REPUTATION || kind == MEMBERSHIP)
        {
            if (!CaelumFactionRules.IsValidFactionId(subject)) return false;
            return kind == REPUTATION ? record.FactionReputation[subject] >= value
                : (value == 0 || value == 1) && record.FactionMember[subject] == (value != 0);
        }
        if (kind == MAIN_FLAG)
            return (value == 0 || value == 1) && subject >= 0
                && subject < CaelumConstants.MAIN_M00_FLAG_CAPACITY
                && record.HasMainM00Flag(subject) == (value != 0);
        if (subject < 0 || subject >= CaelumConstants.QUEST_DEFINED_COUNT) return false;
        if (kind == QUEST_STATE)
            return value >= CaelumConstants.QUEST_STATE_UNDISCOVERED
                && value <= CaelumConstants.QUEST_STATE_ABANDONED
                && CaelumQuestCatalogue.State(record, subject) == value;
        if (kind == QUEST_STAGE)
            return value >= 0 && CaelumQuestCatalogue.State(record, subject)
                != CaelumConstants.QUEST_STATE_UNDISCOVERED && record.QuestStage[subject] >= value;
        if (kind != KNOWN_OBJECTIVE || value < 0
            || !CaelumQuestCatalogue.KnownObjective(record, subject, objective)) return false;
        int slot = record.GetQuestObjectiveStorageIndex(subject, objective);
        return slot >= 0 && record.QuestObjectiveTarget[slot] > 0
            && record.QuestObjectiveProgress[slot] >= value;
    }

    bool Evaluate(CaelumPersistentCharacterState record, int depth = 0)
    {
        if (record == null || depth < 0 || depth >= MAX_DEPTH) return false;
        if (Kind != ALL && Kind != ANY) return Matches(record, Kind, Subject, Value, Objective);
        // Un grupo vacío o una referencia inválida no habilitan contenido.
        if (Terms.Size() == 0) return false;
        bool result = Kind == ALL;
        for (int i = 0; i < Terms.Size(); i++)
        {
            if (Terms[i] == null) return false;
            bool accepted = Terms[i].Evaluate(record, depth + 1);
            if (Kind == ALL) result = result && accepted;
            else result = result || accepted;
        }
        return result;
    }
}

// Escrituras comparadas: repetir una notificación no vuelve a publicar todo el
// Diario. Quien llama conserva la autorización y los desenlaces de su misión.
class CaelumQuestTransitions : Object play
{
    static bool StoredQuest(int id)
    {
        return id >= 0 && id < CaelumConstants.QUEST_DEFINED_COUNT
            && id != CaelumConstants.QUEST_SEWERS && !CaelumQuestCatalogue.IsRescue(id);
    }

    static bool ObserveState(CaelumPersistentCharacterState record, int id, int state, int stage)
    {
        if (record == null || !StoredQuest(id) || stage < 0
            || state < CaelumConstants.QUEST_STATE_UNDISCOVERED
            || state > CaelumConstants.QUEST_STATE_ABANDONED) return false;
        if (record.QuestState[id] == state && record.QuestStage[id] == stage) return false;
        record.QuestState[id] = state;
        record.QuestStage[id] = stage;
        return true;
    }

    static bool TryState(CaelumPersistentCharacterState record, int id,
        int expected, int next, int stage)
    {
        if (record == null || !StoredQuest(id) || expected == next
            || record.QuestState[id] != expected) return false;
        return ObserveState(record, id, next, stage);
    }

    static bool ObserveObjective(CaelumPersistentCharacterState record, int id,
        int objective, int progress, int target)
    {
        if (record == null || !StoredQuest(id) || progress < 0 || target <= 0) return false;
        int slot = record.GetQuestObjectiveStorageIndex(id, objective);
        if (slot < 0) return false;
        progress = Min(progress, target);
        if (record.QuestObjectiveKnown[slot] && record.QuestObjectiveProgress[slot] == progress
            && record.QuestObjectiveTarget[slot] == target) return false;
        record.QuestObjectiveKnown[slot] = true;
        record.QuestObjectiveProgress[slot] = progress;
        record.QuestObjectiveTarget[slot] = target;
        return true;
    }
}
