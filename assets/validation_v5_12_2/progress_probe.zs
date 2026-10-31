// El mundo conserva el objetivo; una identidad reimportada conserva elegibilidad.
class CA436ClockProbe : EventHandler
{
    bool Done;
    void Check(bool value,String text){Console.Printf("CA436 %s %s",value?"PASS":"FAIL",text);}
    override void WorldTick()
    {
        if(Done || level.time<105)return;
        let user=CaelumPlayer(players[0].mo);if(!CaelumWorldClockTicker.Ready(user))return;
        let record=user.GetPersistentCharacterState(false);
        let clock=CaelumWorldClock.Get(user);let world=CaelumCooperativeQuests.Get(user);
        Check(clock.CampaignQuests!=null && clock.CampaignQuests==world,"campaign owns objectives before any profile transfer");
        Check(record.LawfulIdentity!=null && record.LawfulIdentity.Token.Length()>0,"ready character has a stable existing legal identity");
        bool moved=world.Transition(user,0,CaelumConstants.PRISONER_STATE_FOLLOWING);
        moved=moved && world.Transition(user,0,CaelumConstants.PRISONER_STATE_EXTRACTED);
        Check(moved,"ordinary rescue completion captures the present roster");
        let earned=world.Rescue[0];Check(earned!=null && earned.Contains(record),"original character is eligible");
        let imported=CaelumPersistentCharacterState(Actor.Spawn('CaelumPersistentCharacterState',(0,512,0),NO_REPLACE));
        imported.LawfulIdentity=new('CaelumLawfulIdentity');imported.LawfulIdentity.Token=record.LawfulIdentity.Token;
        Check(earned.Contains(imported),"a reconstructed record retains the same earned eligibility");
        earned.Eligible[0]=null;
        Check(earned.Contains(imported),"eligibility survives a detached historical Inventory record");
        let foreign=CaelumPersistentCharacterState(Actor.Spawn('CaelumPersistentCharacterState',(0,576,0),NO_REPLACE));
        foreign.LawfulIdentity=new('CaelumLawfulIdentity');foreign.LawfulIdentity.Token="diagnostic-unrelated-character";
        Check(!earned.Contains(foreign),"an unrelated identity cannot inherit that eligibility");
        world.Rescue[0]=new('CaelumCooperativeObjective');world.Rescue[0].Eligible.Push(foreign);
        record.PrisonerRescueState[0]=CaelumConstants.PRISONER_STATE_FOLLOWING;
        record.QuestState[CaelumConstants.QUEST_FIND_HOUSE]=CaelumConstants.QUEST_STATE_ACTIVE;
        record.QuestStage[CaelumConstants.QUEST_FIND_HOUSE]=31;
        int money=user.GetOwnedMoneyCopperValue();
        Check(CaelumCooperativeQuests.Unavailable(user,CaelumConstants.QUEST_RESCUE_FIRST),"resolved foreign world marks pending personal rescue unavailable");
        Check(!user.ClaimPrisonerPortReward(0,CaelumPrisonerRescue.FactionFor(0)) && user.GetOwnedMoneyCopperValue()==money,"joining a resolved world grants no retroactive reward");
        Check(record.PrisonerRescueState[0]==CaelumConstants.PRISONER_STATE_FOLLOWING
            && record.QuestStage[CaelumConstants.QUEST_FIND_HOUSE]==31,"unavailable world preserves personal progress");
        world.Rescue[0]=earned;
        Check(user.ClaimPrisonerPortReward(0,CaelumPrisonerRescue.FactionFor(0)),"returning to the eligible campaign allows the pending reward");
        Check(!user.ClaimPrisonerPortReward(0,CaelumPrisonerRescue.FactionFor(0)),"reward receipt prevents a repeated grant");
        Check(user.GetOwnedMoneyCopperValue()==money+CaelumConstants.PRISONER_RESCUE_COPPER_REWARD,"only the eligible owner receives one approved reward");
        Done=true;Console.Printf("CA436 RESULT progress peer=%d",consoleplayer);
    }
}
