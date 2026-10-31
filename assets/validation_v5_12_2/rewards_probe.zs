// Capture eligibility before claims; native save restores the same character references.
class CA436ClockProbe : EventHandler
{
    int Phase,Mask,Claimed,EligibleMask;
    bool Reloaded,Verified;
    ui bool Sent,Saved;
    CaelumCooperativeQuests World;
    double Balances[MAXPLAYERS];
    void Check(bool okay,String label){Console.Printf("CA436 %s %s",okay?"PASS":"FAIL",label);}
    override void WorldLoaded(WorldEvent e){if(e.IsSaveGame)Reloaded=true;}
    override void UiTick()
    {
        if(gamestate!=GS_LEVEL || consoleplayer<0)return;
        if(Phase==1 && !Sent && !Reloaded)
        {Sent=true;SendNetworkEvent("ca436_reward_claim");}
        if(Phase==2 && !Saved && !Reloaded && consoleplayer==0)
        {Saved=true;SavegameManager.GetManager().DoSave(0,"CA436 individual rescue rewards");}
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="ca436_verify_reload" && e.Player==0){Reloaded=true;return;}
        if(e.Name!="ca436_reward_claim" || Phase!=1 || (Claimed&(1<<e.Player))!=0)return;
        let user=CaelumPlayerAuthority.FromNetworkPlayer(e.Player);if(user==null)return;
        bool eligible=(EligibleMask&(1<<e.Player))!=0;
        int faction=CaelumPrisonerRescue.FactionFor(0);
        bool first=user.ClaimPrisonerPortReward(0,faction),again=user.ClaimPrisonerPortReward(0,faction);
        Check(first==eligible && !again,String.Format("sender %d can claim only its eligible reward once",e.Player));
        double gain=CaelumInventoryService.GetOwnedMoneyCopperValue(user)-Balances[e.Player];
        Check(gain==(eligible?CaelumConstants.PRISONER_RESCUE_COPPER_REWARD:0),String.Format("sender %d receives exactly its own approved payment",e.Player));
        Balances[e.Player]+=gain;Claimed|=1<<e.Player;
    }
    override void WorldTick()
    {
        if(Verified || level.time<TICRATE*3)return;
        let a=CaelumPlayer(players[0].mo);let b=CaelumPlayer(players[1].mo);
        if(!CaelumWorldClockTicker.Ready(a) || !CaelumWorldClockTicker.Ready(b))return;
        if(Reloaded && Phase==9)
        {
            World=CaelumCooperativeQuests.Get(a);
            Check(World!=null && World.Revision==2,"old native save adds the campaign ledger exactly once");
            Check(CaelumCooperativeQuests.Get(b)==World,"legacy migration publishes one object to every peer");
            Check(CaelumCooperativeQuests.CanClaim(a,0) && !CaelumCooperativeQuests.CanClaim(b,0),"legacy eligibility preserves earned reward without widening the roster");
            Check(b.GetPersistentCharacterState(false).GetPrisonerRescueState(0)==CaelumConstants.PRISONER_STATE_FOLLOWING,"legacy pending personal progress is not overwritten");
            Check(a.ClaimPrisonerPortReward(0,CaelumPrisonerRescue.FactionFor(0)) && !a.ClaimPrisonerPortReward(0,CaelumPrisonerRescue.FactionFor(0)),"legacy earned reward remains claimable exactly once");
            Check(!b.ClaimPrisonerPortReward(0,CaelumPrisonerRescue.FactionFor(0)),"legacy migration does not grant retroactive rewards");
            Verified=true;Console.Printf("CA436 RESULT peer=%d legacy-upgraded",consoleplayer);return;
        }
        if(Reloaded)
        {
            bool same=true,identities=true,once=true,money=true,personal=true;
            for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])
            {
                let user=CaelumPlayer(players[i].mo);let record=user.GetPersistentCharacterState(false);
                same=same && CaelumWorldClock.Get(user).CampaignQuests==World;
                identities=identities && World.Rescue[0].Contains(record)==((EligibleMask&(1<<i))!=0);
                once=once && !user.ClaimPrisonerPortReward(0,CaelumPrisonerRescue.FactionFor(0));
                money=money && CaelumInventoryService.GetOwnedMoneyCopperValue(user)==Balances[i];
                personal=personal && record.QuestStage[CaelumConstants.QUEST_FIND_HOUSE]==42+i;
            }
            Check(same,"common save restores one campaign objective object");
            Check(identities,"saved eligibility follows character records, not new slot inference");
            Check(once,"restarted claims cannot repeat or award a late arrival");
            Check(money,"common restart preserves every personal payment exactly");
            Check(personal,"private quest stages survive common restart");
            Check(!World.Transition(a,0,CaelumConstants.PRISONER_STATE_EXTRACTED),"restored objective cannot recapture a new roster");
            Verified=true;Console.Printf("CA436 RESULT peer=%d rewards-restored",consoleplayer);return;
        }
        if(Phase==0)
        {
            int count=0,last=-1;
            for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])
            {
                let user=CaelumPlayer(players[i].mo);if(!CaelumWorldClockTicker.Ready(user))return;
                Mask|=1<<i;count++;last=i;Balances[i]=CaelumInventoryService.GetOwnedMoneyCopperValue(user);
                user.GetPersistentCharacterState(false).QuestStage[CaelumConstants.QUEST_FIND_HOUSE]=42+i;
            }
            World=CaelumCooperativeQuests.Get(a);
            Check(World!=null && CaelumWorldClock.Get(b).CampaignQuests==World,"native replicas reference the same world rescue record");
            Check(World.Revision==2 && a.GetPrisonerRescueState(0)==CaelumConstants.PRISONER_STATE_CAPTIVE,"new rescue migration initializes once without inventing progress");
            Check(b.SetPlayerPrisonerRescueState(0,CaelumConstants.PRISONER_STATE_FOLLOWING),"a non-host can initiate the shared public rescue");
            Check(!a.SetPlayerPrisonerRescueState(0,CaelumConstants.PRISONER_STATE_CAPTIVE),"shared rescue cannot regress to captive");
            let pending=CaelumPlayer(players[last].mo).GetPersistentCharacterState(false);
            if(count>2)pending.ProfileCommitted=false; // A slot without a ready character is not an eligible character.
            EligibleMask=count>2?Mask&~(1<<last):Mask;
            Check(b.SetPlayerPrisonerRescueState(0,CaelumConstants.PRISONER_STATE_EXTRACTED),"objective completion captures the present roster once");
            if(count>2)pending.ProfileCommitted=true;
            Check(World.Rescue[0].Eligible.Size()==count-(count>2?1:0),"eligibility contains only characters present at completion");
            Check(!a.SetPlayerPrisonerRescueState(0,CaelumConstants.PRISONER_STATE_EXTRACTED),"repeating completion cannot widen eligibility");
            if(count>2)
            {
                let late=CaelumPlayer(players[last].mo);let record=late.GetPersistentCharacterState(false);
                late.RefreshSocialJournalSnapshot();
                Check(!CaelumCooperativeQuests.CanClaim(late,0) && record.GetPrisonerRescueState(0)==CaelumConstants.PRISONER_STATE_FOLLOWING,"late character retains pending personal rescue without retroactive reward");
                Check(late.JournalQuestUnavailable[CaelumConstants.QUEST_RESCUE_FIRST],"Journal marks incompatible resolved world without overwriting progress");
            }
            let npc=CaelumAnchoredResident(Actor.Spawn('CaelumCaella',(800,800,0),NO_REPLACE));npc.EscortPrisonerLeader=b;
            Check(npc.GetEscortOwnerPlayer()==b,"escort retains the actual non-host conversation initiator");
            Phase=1;return;
        }
        if(Phase==1 && Claimed==Mask)
        {
            bool personal=true,flags=true;
            for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])
            {
                let record=CaelumPlayer(players[i].mo).GetPersistentCharacterState(false);
                personal=personal && record.QuestStage[CaelumConstants.QUEST_FIND_HOUSE]==42+i;
                flags=flags && record.PrisonerRewardClaimed[0]==((EligibleMask&(1<<i))!=0);
            }
            Check(personal,"public reward never copies unrelated private quest stages");
            Check(flags,"exactly-once flags belong to each eligible character");
            Phase=2;Console.Printf("CA436 RESULT peer=%d rewards",consoleplayer);
        }
    }
}
