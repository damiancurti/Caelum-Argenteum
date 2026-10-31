// Runs against the preserved pre-reward-ledger package, then saves real native peers.
class CA436ClockProbe : EventHandler
{
    int Phase;
    ui bool Saved;
    void Check(bool okay,String label){Console.Printf("CA436 %s %s",okay?"PASS":"FAIL",label);}
    override void UiTick()
    {
        if(consoleplayer!=0 || gamestate!=GS_LEVEL || Saved || Phase!=9)return;
        Saved=true;SavegameManager.GetManager().DoSave(0,"CA436 legacy rescue eligibility");
    }
    override void WorldTick()
    {
        if(Phase!=0 || level.time<TICRATE*3)return;
        let a=CaelumPlayer(players[0].mo);let b=CaelumPlayer(players[1].mo);
        if(!CaelumWorldClockTicker.Ready(a) || !CaelumWorldClockTicker.Ready(b))return;
        let ar=a.GetPersistentCharacterState(false);let br=b.GetPersistentCharacterState(false);
        ar.SetPrisonerRescueState(0,CaelumConstants.PRISONER_STATE_EXTRACTED);
        br.SetPrisonerRescueState(0,CaelumConstants.PRISONER_STATE_FOLLOWING);
        Check(ar.GetPrisonerRescueState(0)==CaelumConstants.PRISONER_STATE_EXTRACTED && !ar.PrisonerRewardClaimed[0],"legacy owner has an earned unclaimed rescue");
        Check(br.GetPrisonerRescueState(0)==CaelumConstants.PRISONER_STATE_FOLLOWING && !br.PrisonerRewardClaimed[0],"legacy guest retains a pending personal rescue");
        Phase=9;Console.Printf("CA436 RESULT peer=%d legacy-rewards",consoleplayer);
    }
}
