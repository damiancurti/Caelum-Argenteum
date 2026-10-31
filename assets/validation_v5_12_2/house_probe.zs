class CA436ClockProbe : EventHandler
{
    int Phase,Mask,EligibleMask;
    bool Reloaded,Verified;
    ui bool Sent,Saved;
    CaelumPropertyRecord Property;
    double Balances[MAXPLAYERS];
    void Check(bool okay,String label){Console.Printf("CA436 %s %s",okay?"PASS":"FAIL",label);}
    void Speaker(CaelumPlayer user)
    {
        let npc=Actor.Spawn('CaelumRentalAgent',user.Pos+(0,48,0),NO_REPLACE);
        npc.bInConversation=true;user.player.ConversationNPC=npc;user.player.ConversationPC=user;
    }
    override void WorldLoaded(WorldEvent e){if(e.IsSaveGame)Reloaded=true;}
    override void UiTick()
    {
        if(gamestate!=GS_LEVEL || consoleplayer!=0)return;
        if(Phase==1 && !Sent && !Reloaded){Sent=true;SendNetworkEvent("ca436_house_verify");}
        if(Phase==3 && !Saved && !Reloaded){Saved=true;SavegameManager.GetManager().DoSave(0,"CA436 shared house and unique refund");}
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="ca436_verify_reload" && e.Player==0){Reloaded=true;return;}
        if(e.Name!="ca436_house_verify" || e.Player!=0 || Phase!=1)return;
        let a=CaelumPlayerAuthority.FromNetworkPlayer(e.Player);
        int last=-1,count=0;for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i]){last=i;count++;}
        let pending=CaelumPlayer(players[last].mo).GetPersistentCharacterState(false);
        if(count>2)pending.ProfileCommitted=false;
        Check(CaelumPortQuests.VerifyHouse(a),"actual conversation initiator restores property paid by another participant");
        if(count>2)pending.ProfileCommitted=true;
        Check(Property.Restitution!=null && Property.Restitution.Eligible.Size()==count-(count>2?1:0),"house completion snapshots only ready present characters");
        bool titles=true,walletsMatch=true,completion=true,privateProgress=true;
        for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])
        {
            let user=CaelumPlayer(players[i].mo);let record=user.GetPersistentCharacterState(false);bool eligible=(EligibleMask&(1<<i))!=0;
            titles=titles && CaelumPropertyRules.Holds(user,Property)==eligible;
            walletsMatch=walletsMatch && user.GetOwnedMoneyCopperValue()==Balances[i];
            completion=completion && record.HouseRestitutionConfirmed==eligible;
            privateProgress=privateProgress && record.QuestStage[CaelumConstants.QUEST_INVESTIGATE_SIEGE]==70+i;
        }
        Check(titles && Property.Purchased,"each eligible character receives permanent residence rights");
        Check(walletsMatch,"only the real payer recovers exactly their recorded rent and purchase");
        Check(completion,"each eligible character receives the personal house completion");
        Check(privateProgress,"house reward preserves unrelated personal investigations");
        Check(Property.RefundPaid && Property.RefundCopper==CaelumPropertyData.PURCHASE_COPPER+2*CaelumPropertyData.RENT_COPPER,"world stores one settled refund, not one debt per recipient");
        if(count>2)
        {
            let late=CaelumPlayer(players[last].mo);
            Speaker(late);pending.QuestState[CaelumConstants.QUEST_GUARD_CAPTAIN]=CaelumConstants.QUEST_STATE_COMPLETED;
            Check(!CaelumPortQuests.VerifyHouse(late) && !CaelumPropertyRules.Holds(late,Property),"late recognition cannot recapture house eligibility");
        }
        Check(CaelumPortQuests.VerifyHouse(a) && Property.Restitution.Eligible.Size()==count-(count>2?1:0),"repeated verification preserves the original shared title");
        bool once=true;for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])
        {let user=CaelumPlayer(players[i].mo);once=once && !CaelumPortQuests.ClaimRefund(user) && user.GetOwnedMoneyCopperValue()==Balances[i];}
        Check(once,"repeated individual refund claims cannot create money");
        Phase=2;
    }
    override void WorldTick()
    {
        if(Verified || level.time<TICRATE*3)return;
        let a=CaelumPlayer(players[0].mo);let b=CaelumPlayer(players[1].mo);
        if(!CaelumWorldClockTicker.Ready(a) || !CaelumWorldClockTicker.Ready(b))return;
        if(Reloaded && Phase==9)
        {
            Property=CaelumPropertyRules.Find(CaelumPropertyData.CENTRAL_HOUSE);
            Check(Property!=null && Property.CooperativeRevision==0,"old native property loads with a pending explicit migration");
            CaelumCooperativeHouse.Ensure(Property);
            Check(Property.CooperativeRevision==1 && Property.Restitution.Eligible.Size()==1,"legacy restitution keeps its original sole recipient");
            Check(CaelumPropertyRules.Holds(b,Property) && !CaelumPropertyRules.Holds(a,Property),"legacy upgrade preserves title without retroactive co-owners");
            Check(Property.RefundPaid && Property.RefundCopper==0,"old refunded restitution is not mistaken for a paid purchase");
            Check(!CaelumPortQuests.ClaimRefund(b) && b.GetOwnedMoneyCopperValue()==Balances[1],"legacy upgrade cannot refund the original purchase twice");
            CaelumCooperativeHouse.Ensure(Property);Check(Property.Restitution.Eligible.Size()==1,"property migration is idempotent");
            Verified=true;Console.Printf("CA436 RESULT peer=%d legacy-house-upgraded",consoleplayer);return;
        }
        if(Reloaded)
        {
            bool titles=true,money=true,claims=true,personal=true;
            for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])
            {
                let user=CaelumPlayer(players[i].mo);let record=user.GetPersistentCharacterState(false);
                titles=titles && CaelumPropertyRules.Holds(user,Property)==((EligibleMask&(1<<i))!=0);
                claims=claims && !CaelumPortQuests.ClaimRefund(user);
                money=money && user.GetOwnedMoneyCopperValue()==Balances[i];
                personal=personal && record.QuestStage[CaelumConstants.QUEST_INVESTIGATE_SIEGE]==70+i;
            }
            Check(Property==CaelumPropertyRules.Find(CaelumPropertyData.CENTRAL_HOUSE),"common save restores the same world property record");
            Check(titles,"shared legal titles survive coordinated restart");
            Check(claims,"restored refund cannot be claimed again");
            Check(money,"all personal wallets survive coordinated restart exactly");
            Check(personal,"private investigations survive house reward and restart");
            Check(Property.RefundPaid && Property.CooperativeRevision==1,"settled world refund and revision survive native save");
            Verified=true;Console.Printf("CA436 RESULT peer=%d house-restored",consoleplayer);return;
        }
        if(Phase==2)
        {
            // Let the normal shared-clock tick publish its reference to the
            // newly ready participant before inspecting their UI snapshot.
            if(Mask!=EligibleMask)
            {
                for(int i=0;i<MAXPLAYERS;i++)if((Mask&(1<<i))!=0 && (EligibleMask&(1<<i))==0)
                {
                    let late=CaelumPlayer(players[i].mo);late.RefreshSocialJournalSnapshot();
                    Check(late.JournalQuestUnavailable[CaelumConstants.QUEST_FIND_HOUSE],"late character sees resolved-world conflict without losing progress");
                }
            }
            Phase=3;Console.Printf("CA436 RESULT peer=%d house",consoleplayer);return;
        }
        if(Phase!=0)return;
        int count=0,last=-1;
        for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])
        {
            let user=CaelumPlayer(players[i].mo);if(!CaelumWorldClockTicker.Ready(user))return;
            if(user.player.ConversationNPC!=null)user.player.ConversationNPC.bInConversation=false;
            user.player.ConversationNPC=null;user.player.ConversationPC=null;
            let record=user.GetPersistentCharacterState(false);
            record.QuestState[CaelumConstants.QUEST_FIND_HOUSE]=CaelumConstants.QUEST_STATE_ACTIVE;
            record.QuestStage[CaelumConstants.QUEST_INVESTIGATE_SIEGE]=70+i;
            Mask|=1<<i;count++;last=i;
        }
        EligibleMask=count>2?Mask&~(1<<last):Mask;
        int paid=CaelumPropertyData.PURCHASE_COPPER+2*CaelumPropertyData.RENT_COPPER;
        Check(CaelumPortQuests.CreditRefund(b,paid),"fixture funds the payer through the real currency transaction");
        for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])Balances[i]=CaelumPlayer(players[i].mo).GetOwnedMoneyCopperValue();
        Check(CaelumPropertyRules.Acquire(b,CaelumPropertyData.CENTRAL_HOUSE,false)
            && CaelumPropertyRules.Acquire(b,CaelumPropertyData.CENTRAL_HOUSE,false)
            && CaelumPropertyRules.Acquire(b,CaelumPropertyData.CENTRAL_HOUSE,true),"non-host actually pays two rentals and the purchase");
        Property=CaelumPropertyRules.Find(CaelumPropertyData.CENTRAL_HOUSE);
        if(Property==null){Verified=true;Console.Printf("CA436 FAIL missing fixture contract");return;}
        Check(b.GetOwnedMoneyCopperValue()==Balances[1]-paid,"contract payments debit only their real payer");
        Check(Property.CooperativeRevision==1 && Property.Restitution==null,"new contract distinguishes purchase from restitution");
        Check(!CaelumPortQuests.VerifyHouse(a),"house verification rejects a request without its conversation");
        Speaker(a);a.GetPersistentCharacterState(false).QuestState[CaelumConstants.QUEST_GUARD_CAPTAIN]=CaelumConstants.QUEST_STATE_ACTIVE;
        Check(!CaelumPortQuests.VerifyHouse(a),"house verification still requires the initiating character's recognition");
        a.GetPersistentCharacterState(false).QuestState[CaelumConstants.QUEST_GUARD_CAPTAIN]=CaelumConstants.QUEST_STATE_COMPLETED;
        Phase=1;
    }
}
