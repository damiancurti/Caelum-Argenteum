class CaelumPortQuestView : Object ui
{
    static String Help(CaelumPlayer user,int quest)
    {
        if(user.JournalQuestState[quest]==CaelumConstants.QUEST_STATE_ABANDONED)return "CA_Q_PORT_RESUME";
        if(quest==CaelumConstants.QUEST_FIND_HOUSE && user.JournalQuestState[quest]==CaelumConstants.QUEST_STATE_COMPLETED
            && !user.JournalQuestRewardClaimed[quest])return "CA_Q_SIDE_CLAIM";
        return user.JournalQuestState[quest]==CaelumConstants.QUEST_STATE_COMPLETED ? "CA_Q_SIDE_REWARDED" : "CA_Q_PORT_ACTIVE_HELP";
    }
    static String Objective(CaelumPlayer user,int quest)
    {
        String key;
        if(quest==CaelumConstants.QUEST_FIND_HOUSE)
            key=user.JournalQuestStage[quest]>=3 ? "CA_Q_HOUSE_DONE" : user.JournalQuestStage[quest]>=2 ? "CA_Q_HOUSE_REGISTER" : "CA_Q_HOUSE_GUARD";
        else key=user.JournalQuestState[quest]==CaelumConstants.QUEST_STATE_COMPLETED ? "CA_Q_PORT_DONE" : "CA_Q_PORT_ACCOUNTS";
        return StringTable.Localize(key,false);
    }
    static String Detail(CaelumPlayer user,int quest)
    {
        String text=Objective(user,quest);
        let record=CaelumPersistentCharacterState(user.FindInventory("CaelumPersistentCharacterState"));
        if(record==null)return text;
        if(quest==CaelumConstants.QUEST_INVESTIGATE_SIEGE)
        {
            text=text.."\n\n"..CaelumPortStory.Accounts(user);
            if(record.QuestState[quest]==CaelumConstants.QUEST_STATE_COMPLETED
                && CaelumPortQuestData.Count(record.PortInvestigationRequiredMask)<CaelumConstants.PRISONER_COUNT)
                text=text.."\n\n"..StringTable.Localize("CA_Q_PORT_MISSING",false);
        }
        else if(record.HouseRefundPending>0)
        {
            text=text.."\n\n"..StringTable.Localize("CA_RENTAL_REFUND_PENDING",false);
            text.Replace("%COPPER%",String.Format("%d",record.HouseRefundPending));
        }
        return text.."\n\n"..StringTable.Localize(Help(user,quest),false);
    }
}
