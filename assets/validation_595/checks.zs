class CA422Checks : EventHandler
{
    int Checks,Failures;
    CaelumAnchoredResident Representative;
    CaelumPortDefender Defender;
    Actor Agent;
    override void ConsoleProcess(ConsoleEvent e)
    {
        if(e.Name!="ca422_enter")return;
        let menu=CaelumPortConversationMenu(Menu.GetCurrentMenu());
        if(menu==null){Console.Printf("CA422 FAIL native menu absent");return;}
        menu.MenuEvent(Menu.MKEY_Enter,false);
    }
    void Check(bool ok,String label)
    {Checks++;if(!ok)Failures++;Console.Printf("CA422 %s %s",ok?"PASS":"FAIL",label);}
    void Seed(CaelumPlayer u)
    {
        u.player.cheats|=CF_GODMODE;
        let r=u.GetPersistentCharacterState(true);r.DemoNarrativeRevision=1;r.DemoNarrativeDelivered=2047;
        r.SetPrisonerRescueState(0,CaelumConstants.PRISONER_STATE_EXTRACTED);
        Representative=CaelumAnchoredResident(Actor.Spawn("CaelumPrisonerUnitario",(96,0,0)));
        Defender=CaelumPortDefender(Actor.Spawn("CaelumPortDefender",(0,48,0)));
        Check(u.BuildPalomoCurrencyCreditPlan(200000)&&u.ApplyPalomoCurrencyPlan(),"seed real currency for historical contracts");
        Check(CaelumPropertyRules.Acquire(u,69,false)&&CaelumPropertyRules.Acquire(u,69,false)&&CaelumPropertyRules.Acquire(u,69,true),"two rentals and a purchase are paid through existing owner");
        r.QuestState[9]=CaelumConstants.QUEST_STATE_COMPLETED;
        r.QuestState[10]=CaelumConstants.QUEST_STATE_FAILED;
    }
    void Open(CaelumPlayer u)
    {Check(CaelumPrisonerRescue.OpenDialogue(u,Representative),"native legacy prisoner dialogue opens");}
    void Close(CaelumPlayer u)
    {
        if(u.player.ConversationNPC!=null)u.player.ConversationNPC.bInConversation=false;
        u.player.ConversationNPC=null;u.player.ConversationPC=null;
    }
    void Rules(CaelumPlayer u)
    {
        let r=u.GetPersistentCharacterState(false);CaelumPortQuests.Ensure(r);CaelumPortQuests.Ensure(r);
        Check(r.QuestStateVersion==4&&r.QuestState[9]==CaelumConstants.QUEST_STATE_COMPLETED&&r.QuestState[10]==0,"idempotent migration retains captain clue and clears only reserved slots");
        let property=CaelumPropertyRules.Find(69);
        Check(property!=null&&property.Purchased&&property.RentPayments==2,"legacy actual property payments retained");
        Close(u);r.QuestState[9]=0;Agent=Actor.Spawn("CaelumRentalAgent",(-48,0,0));u.Angle=180;u.Pitch=0;
        Check(CaelumRentalAgent.Open(u,CaelumRentalAgent(Agent)),"native rental dialogue starts house investigation");
        Check(r.QuestState[10]==CaelumConstants.QUEST_STATE_ACTIVE&&!CaelumPortQuests.VerifyHouse(u),"guard recognition is required before register proof");
        Check(CaelumPortQuests.Abandon(r,10)&&!CaelumPortQuests.VerifyHouse(u),"abandoned house quest rejects proof");
        Check(CaelumPortQuests.Activate(u,10)&&r.QuestState[10]==1,"journal resumes without losing house record");
        Close(u);u.Angle=u.AngleTo(Defender);
        Check(CaelumGuardCaptainDialogue.Open(u,Defender)&&r.QuestStage[10]==2,"actual guard recognition advances return objective");
        Close(u);u.Angle=180;
        Check(CaelumRentalAgent.Open(u,CaelumRentalAgent(Agent)),"return to rental caretaker");
        double before=u.GetOwnedMoneyCopperValue();
        double capacity=u.DerivedStats.CarryCapacity;bool box=u.MagicBoxOwned;
        u.DerivedStats.CarryCapacity=0;u.MagicBoxOwned=false;
        Check(CaelumPortQuests.VerifyHouse(u),"register confirms original ownership");
        Check(r.HouseRefundPending==102000&&!r.QuestRewardClaimed[10]&&u.GetOwnedMoneyCopperValue()==before,"insufficient carrying space preserves exact refund without spending it");
        u.DerivedStats.CarryCapacity=capacity;u.MagicBoxOwned=box;
        Check(CaelumPortQuests.Activate(u,10),"journal claims pending refund after capacity is available");
        Check(r.HouseRestitutionConfirmed&&property.Purchased&&CaelumPropertyRules.Holds(u,property),"original property owner grants permanent access");
        Check(u.GetOwnedMoneyCopperValue()==before+102000&&r.HouseRefundPending==0&&r.QuestRewardClaimed[10],"exact registered purchase and rentals refunded");
        double after=u.GetOwnedMoneyCopperValue();CaelumPortQuests.VerifyHouse(u);CaelumPortQuests.Activate(u,10);
        Check(u.GetOwnedMoneyCopperValue()==after&&r.QuestState[10]==2,"replayed proof and journal cannot repeat refund");
        Close(u);r.PortGuardAccountHeard=false;r.PortPrisonerAccountMask=0;r.QuestState[11]=0;
        u.Angle=u.AngleTo(Defender);CaelumGuardCaptainDialogue.Open(u,Defender);
        Check(CaelumPortStory.Hear(u)&&r.QuestState[11]==1&&r.PortSurvivorsMask==1,"guard account starts investigation with actual surviving prisoner");
        Check(CaelumPortQuests.Abandon(r,11),"siege investigation can be abandoned");
        Close(u);u.Angle=0;Open(u);
        Check(!CaelumPortStory.Hear(u),"unpaid prisoner still cannot provide required account");
        r.MarkPrisonerRewardClaimed(0);
        Check(CaelumPortStory.Hear(u)&&r.QuestState[11]==5&&r.PortPrisonerAccountMask==1,"testimony is kept while investigation stays abandoned");
        Check(CaelumPortQuests.Activate(u,11)&&r.QuestState[11]==2&&r.PortInvestigationRequiredMask==1,"resume completes from preserved eligible accounts");
        Check(u.GetOwnedMoneyCopperValue()==after,"information reward adds no money");
        u.PersistCharacterState();
    }
    void Preserved(CaelumPlayer u)
    {
        let r=u.GetPersistentCharacterState(false);let p=CaelumPropertyRules.Find(69);
        Check(r.QuestState[10]==2&&r.QuestRewardClaimed[10]&&r.HouseRestitutionConfirmed&&r.HouseRefundPending==0,"house completion and refund receipt persist");
        Check(p!=null&&p.Purchased&&p.RentPayments==2&&CaelumPropertyRules.Holds(u,p),"world property record retains exact original contract history");
        Check(r.QuestState[11]==2&&r.PortPrisonerAccountMask==1&&r.PortGuardAccountHeard,"investigation retains heard accounts");
    }
    void DeathCase(CaelumPlayer u,int step)
    {
        let r=u.GetPersistentCharacterState(false);
        if(step==0)
        {
            Close(u);r.QuestState[11]=1;r.QuestRewardClaimed[11]=false;r.PortPrisonerAccountMask=0;r.PortGuardAccountHeard=true;
            Representative.bInvulnerable=false;Representative.DamageMobj(null,null,1000000,'None');
        }
        else Check(r.PortSurvivorsMask==0&&r.QuestState[11]==2&&r.PortInvestigationRequiredMask==0,"native death allows guard-only completion and records missing testimony");
    }
    void RentalUI(CaelumPlayer u)
    {
        Close(u);Agent=Actor.Spawn("CaelumRentalAgent",(-48,0,0));u.Angle=180;u.Pitch=0;
        Check(CaelumRentalAgent.Open(u,CaelumRentalAgent(Agent)),"native rental UI opens after prior captain recognition");
    }
    void City(CaelumPlayer u)
    {
        let port=CaelumPortSiege.Get();Check(port!=null&&port.RentalAgent!=null,"production city spawns the rental caretaker once");
        if(port==null || port.RentalAgent==null)return;
        Agent=port.RentalAgent;Check(Agent.TestMobjLocation(),"caretaker fits clear of the house entrance");
        u.SetOrigin(Agent.Pos+(-48,0,0),false);u.Angle=0;u.Pitch=0;
        Check(CaelumRentalAgent.Open(u,CaelumRentalAgent(Agent)),"caretaker is reachable beside the real central house");
        let registry=CaelumSiegeEvents(EventHandler.Find("CaelumSiegeEvents"));double worst=0;
        for(int i=0;i<20;i++){registry.PortPeopleRevision=0;double start=MSTimeF();registry.EnsurePortPeople();worst=Max(worst,MSTimeF()-start);}
        double start=MSTimeF();for(int i=0;i<10000;i++)registry.PortSurvivors();
        Console.Printf("CA422 TIMING legacy_registry_worst_ms=%.6f reads_10000_ms=%.6f",worst,MSTimeF()-start);
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=="ca422_seed")Seed(u);
        if(e.Name=="ca422_open")Open(u);
        if(e.Name=="ca422_rules")Rules(u);
        if(e.Name=="ca422_preserved")Preserved(u);
        if(e.Name=="ca422_death")DeathCase(u,e.Args[0]);
        if(e.Name=="ca422_rental")RentalUI(u);
        if(e.Name=="ca422_city")City(u);
        if(e.Name=="ca422_free")
        {
            let r=u.GetPersistentCharacterState(false);r.QuestState[9]=CaelumConstants.QUEST_STATE_COMPLETED;
            CaelumPortQuests.Observe(u);double before=u.GetOwnedMoneyCopperValue();
            Check(CaelumPortQuests.VerifyHouse(u)&&r.HouseRestitutionConfirmed&&r.QuestRewardClaimed[10]
                &&r.HouseRefundPending==0&&u.GetOwnedMoneyCopperValue()==before,"unpaid original home is restored without inventing a refund");
        }
        if(e.Name=="ca422_ui")Check(u.GetPersistentCharacterState(false).HouseRestitutionConfirmed&&u.GetPersistentCharacterState(false).QuestRewardClaimed[10],"native reply restores house and refunds actual contracts");
        if(e.Name=="ca422_done")Console.Printf("CA422 RESULT checks=%d failures=%d",Checks,Failures);
    }
}
