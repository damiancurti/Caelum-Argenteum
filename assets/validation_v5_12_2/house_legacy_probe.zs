// Create the pre-cooperative property under the untouched earlier full package.
class CA436ClockProbe : EventHandler
{
    int Phase;
    double Balances[MAXPLAYERS];
    ui bool Saved;
    void Check(bool okay,String label){Console.Printf("CA436 %s %s",okay?"PASS":"FAIL",label);}
    override void UiTick()
    {if(gamestate==GS_LEVEL && consoleplayer==0 && Phase==9 && !Saved){Saved=true;SavegameManager.GetManager().DoSave(0,"CA436 legacy paid house restitution");}}
    override void WorldTick()
    {
        if(Phase!=0 || level.time<TICRATE*3)return;
        let a=CaelumPlayer(players[0].mo);let b=CaelumPlayer(players[1].mo);
        if(!CaelumWorldClockTicker.Ready(a) || !CaelumWorldClockTicker.Ready(b))return;
        for(int i=0;i<2;i++)
        {let user=CaelumPlayer(players[i].mo);if(user.player.ConversationNPC!=null)user.player.ConversationNPC.bInConversation=false;user.player.ConversationNPC=null;user.player.ConversationPC=null;}
        int paid=CaelumPropertyData.PURCHASE_COPPER+2*CaelumPropertyData.RENT_COPPER;
        b.BuildPalomoCurrencyCreditPlan(paid);b.ApplyPalomoCurrencyPlan();Balances[1]=b.GetOwnedMoneyCopperValue();
        // The old public purchase was solo-only. Seed its existing contract
        // shape, but use the real transaction to debit the recorded payment.
        let property=CaelumPropertyRules.Find(CaelumPropertyData.CENTRAL_HOUSE,true);
        property.Holder=CaelumLockRules.Character(b,true);property.RentPayments=2;property.Purchased=true;
        Check(CaelumPropertyRules.Pay(b,paid) && b.GetOwnedMoneyCopperValue()==Balances[1]-paid,"legacy contract records two rents and the purchase with an actual debit");
        let record=b.GetPersistentCharacterState(false);record.QuestState[CaelumConstants.QUEST_FIND_HOUSE]=CaelumConstants.QUEST_STATE_ACTIVE;
        record.QuestState[CaelumConstants.QUEST_GUARD_CAPTAIN]=CaelumConstants.QUEST_STATE_COMPLETED;
        let npc=Actor.Spawn('CaelumRentalAgent',b.Pos+(0,48,0),NO_REPLACE);npc.bInConversation=true;b.player.ConversationNPC=npc;b.player.ConversationPC=b;
        Check(CaelumPortQuests.VerifyHouse(b) && b.GetOwnedMoneyCopperValue()==Balances[1]
            && record.HouseRestitutionConfirmed && record.QuestRewardClaimed[CaelumConstants.QUEST_FIND_HOUSE],"legacy house restores and refunds its sole holder once");
        Phase=9;Console.Printf("CA436 RESULT peer=%d legacy-house",consoleplayer);
    }
}
