class CA580Checks : EventHandler
{
    CaelumRentalAgent Agent;
    CaelumPortDefender Guard;
    int Failures;
    void Check(bool ok,String label)
    {if(ok)Console.Printf("CA580 PASS %s",label);else{Failures++;Console.Printf("CA580 FAIL %s",label);}}
    void Close(CaelumPlayer user)
    {
        if(user.player.ConversationNPC!=null)user.player.ConversationNPC.bInConversation=false;
        user.player.ConversationNPC=null;user.player.ConversationPC=null;
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let user=CaelumPlayer(players[0].mo);if(user==null)return;
        if(e.Name=='ca580_begin')
        {
            user.bInvulnerable=true;user.SetOrigin((0,0,0),false);user.Angle=180;user.Pitch=0;
            let r=user.GetPersistentCharacterState(true);r.EnsureQuestStateInitialized();
            r.QuestState[CaelumConstants.QUEST_GUARD_CAPTAIN]=0;
            r.QuestState[CaelumConstants.QUEST_FIND_HOUSE]=0;
            Agent=CaelumRentalAgent(Actor.Spawn('CaelumRentalAgent',(-48,0,0)));
            Guard=CaelumPortDefender(Actor.Spawn('CaelumPortDefender',(0,48,0)));
            Check(CaelumRentalAgent.Open(user,Agent),"first rental conversation opens and starts investigation");
            Check(Agent.HasConversation() && Agent.bInConversation,"active native dialogue retains its node");
            Check(user.FindInventory('CaelumHouseRecognizedToken')==null,"no guard proof is granted early");
            Close(user);
        }
        if(e.Name=='ca580_guard')
        {
            Check(!Agent.HasConversation(),"closing the rental conversation clears the cached native node");
            user.Angle=user.AngleTo(Guard);
            Check(CaelumGuardCaptainDialogue.Open(user,Guard),"real guard recognizes the protagonist");
            Close(user);user.Angle=180;
        }
        if(e.Name=='ca580_return')
        {
            Check(!Agent.HasConversation(),"return must pass through Used and synchronize requirements");
            Check(CaelumRentalAgent.Open(user,Agent),"rental conversation reopens after guard recognition");
            Check(user.FindInventory('CaelumHouseRecognizedToken')!=null,"registry-check reply is now eligible");
            Check(CaelumPortQuests.VerifyHouse(user),"registry proof restores the property");
            let r=user.GetPersistentCharacterState(false);
            Check(r.HouseRestitutionConfirmed && r.QuestState[CaelumConstants.QUEST_FIND_HOUSE]==CaelumConstants.QUEST_STATE_COMPLETED,
                "house investigation completes");
            double before=user.GetOwnedMoneyCopperValue();CaelumPortQuests.VerifyHouse(user);
            Check(user.GetOwnedMoneyCopperValue()==before,"repeated proof never repeats a refund");
            Console.Printf("CA580 RESULT native dialogue failures=%d",Failures);
        }
        if(e.Name=='ca580_reload')
        {
            let r=user.GetPersistentCharacterState(false);
            Check(r.HouseRestitutionConfirmed && r.QuestState[CaelumConstants.QUEST_FIND_HOUSE]==CaelumConstants.QUEST_STATE_COMPLETED,"restored ownership survives reload");
            Check(Agent.HasConversation() && Agent.bInConversation,"loading an active conversation preserves its current node");
            Close(user);Console.Printf("CA580 RESULT reload failures=%d",Failures);
        }
    }
}
