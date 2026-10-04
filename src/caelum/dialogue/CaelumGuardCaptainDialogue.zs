// #79: el cargo se conoce por otros; la pista nunca devuelve recuerdos ni
// concede clase, reputación, equipo, órdenes o recompensas.
class CaelumGuardCaptainDialogue : Object play
{
    const FIRST_CONVERSATION = 43631;
    const REPEAT_CONVERSATION = 43632;

    static bool Open(CaelumPlayer user, CaelumPortDefender guard)
    {
        if (level.MapName != "MAP06" || user == null || guard == null
            || guard.health <= 0 || guard.ForcedSleepTics > 0
            || guard.CombatLucidityPhysicalStunRemaining > 0
            || !CaelumUseGeometry.AimedAt(user, guard)) return false;
        // Respetar el combate nativo. Una marca INCOMBAT vieja no bloquea a
        // un soldado sin enemigo vivo ni a los supervivientes tras la victoria.
        bool fighting = guard.bInCombat;
        if (fighting && guard.target != null && guard.target.bShootable
            && guard.target.health > 0 && !guard.target.bFriendly
            && (guard.Port == null || !guard.Port.Victory)) return false;
        let record = user.GetPersistentCharacterState(false);
        if (record == null) return false;
        record.EnsureQuestStateInitialized();
        int clue = CaelumConstants.QUEST_GUARD_CAPTAIN;
        int conversation = record.QuestState[clue] == CaelumConstants.QUEST_STATE_UNDISCOVERED
            ? FIRST_CONVERSATION : REPEAT_CONVERSATION;
        guard.bInCombat = false;
        bool opened = CaelumFactionCondition.OpenDialogue(user, guard, conversation);
        guard.bInCombat = fighting;
        if (!opened) return false;
        // Abrir ya revela el cargo, incluso si se sale sin elegir respuesta.
        // Completar esta pista no significa recuperar la memoria ni otra misión.
        record.QuestState[clue] = CaelumConstants.QUEST_STATE_COMPLETED;
        user.RefreshSocialJournalSnapshot();
        return true;
    }
}
