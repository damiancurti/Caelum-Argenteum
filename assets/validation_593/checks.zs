class CA420JChecks : EventHandler
{
    int Checks, Failures;
    CaelumAnchoredResident Representative;
    override void ConsoleProcess(ConsoleEvent e)
    {
        if (e.Name != "ca420j_enter") return;
        let menu = CaelumPortConversationMenu(Menu.GetCurrentMenu());
        if (menu == null) { Console.Printf("CA420J FAIL native port menu absent"); return; }
        menu.MenuEvent(Menu.MKEY_Enter, false);
    }
    void Check(bool ok, String label)
    { Checks++; if (!ok) Failures++; Console.Printf("CA420J %s %s", ok ? "PASS" : "FAIL", label); }
    void Seed(CaelumPlayer user)
    {
        user.player.cheats |= CF_GODMODE;
        let record=user.GetPersistentCharacterState(true); record.InitializeNewFactionState();
        record.SetFactionMembership(5,true);
        Representative=CaelumAnchoredResident(Actor.Spawn("CaelumPrisonerUnitario",(96,0,0)));
        Check(Representative!=null,"representative spawned");
    }
    void Open(CaelumPlayer user)
    {
        Representative.EscortPrisonerPort=true;
        Check(CaelumPrisonerRescue.OpenDialogue(user,Representative),"native representative dialogue opens");
    }
    void Close(CaelumPlayer user)
    {
        if(user.player.ConversationNPC!=null)user.player.ConversationNPC.bInConversation=false;
        user.player.ConversationNPC=null;user.player.ConversationPC=null;
    }
    void Rules(CaelumPlayer user)
    {
        let r=user.GetPersistentCharacterState(false);
        r.FactionReputation[0]=-50;
        Check(!CaelumPortMembership.Join(user)&&!r.FactionMember[0],"distrusted boundary rejects membership");
        r.FactionReputation[0]=-49;
        Representative.EscortPrisonerPort=false;
        Check(!CaelumPortMembership.Join(user),"captive or escort cannot grant membership");
        Representative.EscortPrisonerPort=true;
        Representative.ForcedSleepTics=1;
        Check(!CaelumPortMembership.Join(user),"sleeping speaker rejects stale action");
        Representative.ForcedSleepTics=0;
        Representative.EscortPrisonerId=3;
        Check(!CaelumPortMembership.Join(user),"unconfirmed Leandro cannot grant membership");
        Representative.EscortPrisonerId=0;
        int wallet=user.CountInv("CaelumCopperCoin");
        Check(CaelumPortMembership.Join(user)&&r.FactionMember[0],"neutral lower boundary joins actual faction");
        Check(r.FactionReputation[0]==-49&&user.CountInv("CaelumCopperCoin")==wallet&&!r.PrisonerRewardClaimed[0],"joining changes neither reputation money nor reward claim");
        Check(!CaelumPortMembership.Join(user)&&r.FactionMembershipEpoch[0]==1,"repeat join does not create a new tenure");
        Check(r.FactionMember[5]&&r.FactionWitnesses.Size()==0&&r.FactionMembershipKnownEpoch[5]==0,"hidden other membership remains private");
        for(int id=1;id<3;id++)
        {
            Representative.EscortPrisonerId=id;r.FactionReputation[id]=0;
            Check(CaelumPortMembership.Join(user)&&r.FactionMember[id],"other confirmed representative grants own faction");
        }
        Representative.EscortPrisonerId=0;
        Close(user);
        Check(!CaelumPortMembership.Join(user),"no conversation rejects action");
        user.PersistCharacterState();
    }
    void Preserved(CaelumPlayer user)
    {
        let r=user.GetPersistentCharacterState(false);
        Check(r.FactionMember[0]&&r.FactionMember[1]&&r.FactionMember[2]&&r.FactionMember[5],"memberships survive save and travel");
        Check(r.FactionMembershipEpoch[0]==1&&r.FactionMembershipEpoch[1]==1&&r.FactionMembershipEpoch[2]==1,"tenures remain one after restore");
        Check(r.FactionReputation[0]==-49&&r.FactionWitnesses.Size()==0,"reputation and private knowledge preserved");
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=="ca420j_seed")Seed(u);
        if(e.Name=="ca420j_open")Open(u);
        if(e.Name=="ca420j_rules")Rules(u);
        if(e.Name=="ca420j_preserved")Preserved(u);
        if(e.Name=="ca420j_ui")Check(u.GetPersistentCharacterState(false).FactionMember[0],"native choice grants membership");
        if(e.Name=="ca420j_done")Console.Printf("CA420J RESULT checks=%d failures=%d",Checks,Failures);
    }
}
