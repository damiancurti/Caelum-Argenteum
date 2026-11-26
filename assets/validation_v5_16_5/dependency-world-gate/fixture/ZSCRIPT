version "4.14.2"
// Registros preparados por la prueba; no simula adquisiciones ni diálogos del final.
class CA457EligibilityProbe : EventHandler
{
    int Failures,Checks;
    bool Completed;
    void Check(bool okay,String label)
    {Checks++;if(!okay)Failures++;Console.Printf("CA457 %s %s",okay?"PASS":"FAIL",label);}
    CaelumPersistentCharacterState Record(int slot)
    {return CaelumPlayer(players[slot].mo).GetPersistentCharacterState(false);}
    void Reset(CaelumPersistentCharacterState record)
    {
        for(int card=0;card<CaelumConstants.TAROT_CARD_COUNT;card++)record.TarotOwned[card]=false;
        for(int faction=0;faction<CaelumConstants.FACTION_COUNT;faction++)
        {record.FactionReputation[faction]=0;record.FactionMember[faction]=false;}
    }
    void AllCards(CaelumPersistentCharacterState record)
    {for(int card=0;card<CaelumConstants.TAROT_CARD_COUNT;card++)record.TarotOwned[card]=true;}
    void Test()
    {
        Check(playeringame[0] && playeringame[1],"two native connected participants");
        if(!playeringame[0] || !playeringame[1])return;
        for(int slot=0;slot<2;slot++)
        {
            let user=CaelumPlayer(players[slot].mo);
            user.SessionIdentityPending=false;user.ProfileDeparted=false;
            user.CharacterCreationComplete=true;user.CreationWizardOpen=false;
            let record=user.GetPersistentCharacterState(true);record.ProfileCommitted=true;
            Reset(record);
        }
        let first=Record(0);let second=Record(1);
        Check(!CaelumCampaignEligibility.RecordEligible(null),"absent record rejected");
        Check(!CaelumCampaignEligibility.ParticipantEligible(null),"absent participant rejected");
        Check(CaelumCampaignEligibility.EligibleParticipantMask()==0,"empty personal progress rejected");
        let user=CaelumPlayer(players[0].mo);user.GiveInventoryType('CaelumTarotDeck');
        first.FactionReputation[CaelumConstants.FACTION_UNITARIOS]=CaelumCampaignFinaleData.MINIMUM_REPUTATION;
        Check(!CaelumCampaignEligibility.RecordEligible(first),"physical deck and reputation are insufficient");
        AllCards(first);first.TarotOwned[21]=false;
        Check(!CaelumCampaignEligibility.RecordEligible(first),"77 acquired essences are insufficient");
        AllCards(first);
        for(int i=0;i<CaelumCampaignFinaleData.FACTION_COUNT;i++)
        {
            Reset(first);AllCards(first);int faction=CaelumCampaignFinaleData.Faction(i);
            first.FactionReputation[faction]=CaelumCampaignFinaleData.MINIMUM_REPUTATION-1;
            Check(!CaelumCampaignEligibility.RecordEligible(first),"reputation immediately below threshold rejected");
            first.FactionReputation[faction]++;
            Check(CaelumCampaignEligibility.RecordEligible(first),"exact threshold accepted without membership");
        }
        Reset(first);AllCards(first);
        first.FactionReputation[CaelumConstants.FACTION_CAELITH]=CaelumCampaignFinaleData.MINIMUM_REPUTATION;
        first.FactionReputation[CaelumConstants.FACTION_CULT_TAROT]=CaelumCampaignFinaleData.MINIMUM_REPUTATION;
        Check(!CaelumCampaignEligibility.RecordEligible(first),"unapproved reputation tracks rejected");
        Reset(first);AllCards(first);Reset(second);
        second.FactionReputation[CaelumConstants.FACTION_SUN_WARRIORS]=CaelumCampaignFinaleData.MINIMUM_REPUTATION;
        Check(CaelumCampaignEligibility.EligibleParticipantMask()==0,"requirements cannot be split between participants");
        AllCards(second);
        Check(CaelumCampaignEligibility.EligibleParticipantMask()==2,"one eligible guest satisfies both requirements");
        Reset(second);
        first.FactionReputation[CaelumConstants.FACTION_FEDERALS]=CaelumCampaignFinaleData.MINIMUM_REPUTATION;
        Check(CaelumCampaignEligibility.EligibleParticipantMask()==1,"one eligible host satisfies both requirements");
        user.ProfileDeparted=true;
        Check(CaelumCampaignEligibility.EligibleParticipantMask()==0,"departed profile excluded");user.ProfileDeparted=false;
        user.SessionIdentityPending=true;
        Check(CaelumCampaignEligibility.EligibleParticipantMask()==0,"unadmitted identity excluded");user.SessionIdentityPending=false;
        Reset(first);first.TarotOwned[0]=true;AllCards(second);
        second.FactionReputation[CaelumConstants.FACTION_SUN_WARRIORS]=CaelumCampaignFinaleData.MINIMUM_REPUTATION;
        Completed=true;Audit();
    }
    void Audit()
    {
        Check(Completed,"prepared eligibility state retained");
        if(!Completed)return;
        let first=Record(0);let second=Record(1);
        for(int i=0;i<10;i++)Check(CaelumCampaignEligibility.EligibleParticipantMask()==2,"repeatable guest eligibility query");
        Check(first.CountTarotCards()==1 && second.CountTarotCards()==78,"personal ownership never copied or consumed");
        Check(first.FactionReputation[CaelumConstants.FACTION_SUN_WARRIORS]==0
            && second.FactionReputation[CaelumConstants.FACTION_SUN_WARRIORS]==CaelumCampaignFinaleData.MINIMUM_REPUTATION,
            "personal reputation never copied or consumed");
        Check(!second.FactionMember[CaelumConstants.FACTION_SUN_WARRIORS],"membership remains unnecessary");
        Console.Printf("CA457 RESULT %s checks=%d failures=%d mask=%d",Failures==0?"PASS":"FAIL",Checks,Failures,CaelumCampaignEligibility.EligibleParticipantMask());
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="ca457_test")Test();
        else if(e.Name=="ca457_audit")Audit();
        else if(e.Name=="ca457_left")
        {
            Check(!playeringame[1],"eligible guest actually disconnected");
            Check(CaelumCampaignEligibility.EligibleParticipantMask()==0,"disconnected guest no longer qualifies the roster");
            Console.Printf("CA457 DISCONNECT %s",Failures==0?"PASS":"FAIL");
        }
    }
}
