class CA421Checks : EventHandler
{
    int Checks, Failures;
    CaelumAnchoredResident Representative;
    CaelumPortDefender Defender;
    override void ConsoleProcess(ConsoleEvent e)
    {
        if(e.Name=="ca421_enter")
        {
            let menu=CaelumPortConversationMenu(Menu.GetCurrentMenu());
            if(menu==null){Console.Printf("CA421 FAIL native story menu absent");return;}
            menu.MenuEvent(Menu.MKEY_Enter,false);
        }
        if(e.Name=="ca421_text")
        {
            let u=CaelumPlayer(players[consoleplayer].mo);
            String text=CaelumPortStory.Accounts(u);
            Console.Printf("CA421 %s heard-only account names", text.IndexOf(StringTable.Localize("CA_PRISONER_UNITARIO_NAME",false))>=0
                && text.IndexOf(StringTable.Localize("CA_PRISONER_FEDERAL_NAME",false))<0 ? "PASS":"FAIL");
        }
    }
    void Check(bool ok,String label)
    {Checks++;if(!ok)Failures++;Console.Printf("CA421 %s %s",ok?"PASS":"FAIL",label);}
    void Seed(CaelumPlayer u)
    {
        u.player.cheats|=CF_GODMODE;
        let r=u.GetPersistentCharacterState(true);r.DemoNarrativeRevision=1;r.DemoNarrativeDelivered=2047;
        r.MarkPrisonerRewardClaimed(0);r.SetPrisonerRescueState(0,CaelumConstants.PRISONER_STATE_EXTRACTED);
        Representative=CaelumAnchoredResident(Actor.Spawn("CaelumPrisonerUnitario",(96,0,0)));
        Defender=CaelumPortDefender(Actor.Spawn("CaelumPortDefender",(0,48,0)));
        Check(Representative!=null&&Defender!=null,"real prisoner and defender spawned");
    }
    void Open(CaelumPlayer u)
    {
        Representative.EscortPrisonerPort=true;u.Angle=0;u.Pitch=0;
        Check(CaelumPrisonerRescue.OpenDialogue(u,Representative),"native prisoner conversation opens");
    }
    void Close(CaelumPlayer u)
    {
        if(u.player.ConversationNPC!=null)u.player.ConversationNPC.bInConversation=false;
        u.player.ConversationNPC=null;u.player.ConversationPC=null;
    }
    void Rules(CaelumPlayer u)
    {
        let r=u.GetPersistentCharacterState(false);
        CaelumPortStory.Ensure(r);CaelumPortStory.Ensure(r);
        Check(r.PortStoryRevision==1&&r.PortPrisonerAccountMask==0&&!r.PortGuardAccountHeard,"legacy migration invents no testimony");
        r.PrisonerRewardClaimed[0]=false;
        Check(!CaelumPortStory.Hear(u)&&r.PortPrisonerAccountMask==0,"unpaid account cannot be recorded");
        r.PrisonerRewardClaimed[0]=true;
        Check(CaelumPortStory.Hear(u)&&r.PortPrisonerAccountMask==1,"paid current speaker supplies private account");
        Check(CaelumPortStory.Hear(u)&&r.PortPrisonerAccountMask==1,"repeat account is idempotent");
        Check(CaelumPortStoryData.SituationKey(r)=="CA_PRISONER_SIEGE_PENDING","preparation uses actual unstarted state");
        r.PortSiegeNarrativeStarted=true;
        Check(CaelumPortStoryData.SituationKey(r)=="CA_PRISONER_SIEGE_ACTIVE","started unresolved encounter remains active");
        r.PortSiegeNarrativeComplete=true;
        Check(CaelumPortStoryData.SituationKey(r)=="CA_PRISONER_SIEGE_COMPLETE","only actual victory enables aftermath");
        Close(u);Open(u);
        Check(r.PortArrivalHeardMask==1,"opening extended port dialogue confirms arrival");
        Close(u);Defender.SetOrigin(u.Pos+(0,48,0),false);u.Angle=u.AngleTo(Defender);u.Pitch=0;
        Check(CaelumGuardCaptainDialogue.Open(u,Defender),"real guard recognition entry opens in MAP03");
        Check(r.QuestState[CaelumConstants.QUEST_GUARD_CAPTAIN]==CaelumConstants.QUEST_STATE_COMPLETED,"recognition preserves existing captain clue");
        Check(CaelumPortStory.Hear(u)&&r.PortGuardAccountHeard,"guard account records only when selected");
        Defender.ForcedSleepTics=1;
        Check(!CaelumPortStory.Hear(u),"sleeping guard cannot answer stale action");
        Defender.ForcedSleepTics=0;
        let other=CaelumPersistentCharacterState(Actor.Spawn("CaelumPersistentCharacterState"));CaelumPortStory.Ensure(other);
        Check(other.PortPrisonerAccountMask==0&&!other.PortGuardAccountHeard,"another character learns nothing");other.Destroy();
        Close(u);Check(!CaelumPortStory.Hear(u),"absent conversation cannot grant knowledge");
        Open(u);u.PersistCharacterState();
    }
    void Preserved(CaelumPlayer u)
    {
        let r=u.GetPersistentCharacterState(false);
        Check(r.PortStoryRevision==1&&r.PortArrivalHeardMask==1,"arrival and additive revision survive save or travel");
        Check(r.PortPrisonerAccountMask==1&&r.PortGuardAccountHeard,"exact selected accounts survive save or travel");
        Check(r.PrisonerRewardClaimed[0]&&r.PortSiegeNarrativeComplete,"existing reward and actual victory preserved");
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=="ca421_seed")Seed(u);
        if(e.Name=="ca421_open")Open(u);
        if(e.Name=="ca421_rules")Rules(u);
        if(e.Name=="ca421_preserved")Preserved(u);
        if(e.Name=="ca421_ui")Check(u.GetPersistentCharacterState(false).PortPrisonerAccountMask==1,"native choice records actual testimony");
        if(e.Name=="ca421_all"){let r=u.GetPersistentCharacterState(false);r.PortPrisonerAccountMask=15;r.PortGuardAccountHeard=true;r.PortSiegeNarrativeStarted=true;r.PortSiegeNarrativeComplete=true;}
        if(e.Name=="ca421_guard"){Close(u);u.Angle=u.AngleTo(Defender);u.Pitch=0;Check(CaelumGuardCaptainDialogue.Open(u,Defender),"native guard dialogue opens for visual inspection");}
        if(e.Name=="ca421_guard_ui")Check(u.GetPersistentCharacterState(false).PortGuardAccountHeard,"native guard reply records account");
        if(e.Name=="ca421_done")Console.Printf("CA421 RESULT checks=%d failures=%d",Checks,Failures);
    }
}
