// Preferencias personales de presentación; no toca objetivos ni recompensas.
class CaelumQuestTracking : Object play
{
    static void Ensure(CaelumPersistentCharacterState record)
    {
        if(record!=null && record.QuestTrackingRevision<CaelumQuestTrackingData.REVISION)
            record.QuestTrackingRevision=CaelumQuestTrackingData.REVISION;
    }
    static bool Set(CaelumPlayer user,int quest,bool enabled)
    {
        if(!CaelumPlayerAuthority.CanMutate(user) || user.health<=0
            || !user.CharacterCreationComplete || user.CreationWizardOpen
            || user.player.playerstate!=PST_LIVE || quest<0 || quest>=CaelumConstants.QUEST_DEFINED_COUNT)return false;
        let record=user.GetPersistentCharacterState(false);
        if(record==null || !record.ProfileCommitted)return false;
        int state=CaelumQuestCatalogue.State(record,quest);
        if(state==CaelumConstants.QUEST_STATE_UNDISCOVERED
            || (enabled && state!=CaelumConstants.QUEST_STATE_ACTIVE))return false;
        Ensure(record);
        // El estado deseado hace idempotente la repetición de un mismo evento.
        record.QuestTracked[quest]=enabled;
        return true;
    }
    static clearscope bool Selected(CaelumPlayer user,int quest)
    {
        if(user==null || quest<0 || quest>=CaelumConstants.QUEST_DEFINED_COUNT)return false;
        let record=CaelumPersistentCharacterState(user.FindInventory("CaelumPersistentCharacterState"));
        return record!=null && record.QuestTracked[quest];
    }
    static clearscope bool Active(CaelumPlayer user,int quest)
    {return Selected(user,quest) && user.JournalQuestState[quest]==CaelumConstants.QUEST_STATE_ACTIVE;}
}
