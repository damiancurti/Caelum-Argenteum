// Retorno a la campaña original: título y mundo quedan allí, el equipo vuelve una vez.
class CA434ProfileProbe : StaticEventHandler
{
    bool Done;
    ui bool Saved;
    void Check(bool value,String label){Console.Printf("CA434 %s %s",value?"PASS":"FAIL",label);}
    override void UiTick()
    {
        if(Done && !Saved && consoleplayer==0)
        {
            Saved=true;let manager=SavegameManager.GetManager();manager.ReadSaveStrings();
            manager.InsertNewSaveNode();manager.DoSave(0,"CA434 native return checkpoint");manager.RemoveNewSaveNode();
        }
    }
    override void WorldTick()
    {
        if(Done || level.time<105)return;
        let a=CaelumPlayer(players[0].mo);let b=CaelumPlayer(players[1].mo);
        if(!CaelumPlayerAuthority.CanRead(a) || !CaelumPlayerAuthority.CanRead(b))return;
        let first=a.GetPersistentCharacterState(false);let second=b.GetPersistentCharacterState(false);
        if(first==null || second==null)return;
        if(second.ProfileDeparted)
        {
            Check(b.ProfileDeparted && !CaelumPlayerAuthority.CanMutate(b),"return source cannot act");
            Check(b.FindInventory('CaelumCopperCoin')==null,"return source wallet absent");
            Check(b.FindInventory('CaelumCanteenLarge')==null,"return source vessel absent");
            Check(b.FindInventory('CaelumSmallDiningSetItem')==null,"return source packed furniture absent");
            Check(b.player.ReadyWeapon==null,"return source weapon absent");
            Check(!b.bSolid && !b.bShootable && b.bInvisible,"return source has no collision or combat");
            Check(second.PalomoMerchantStock[0]==91,"second campaign shop retained");
            Check(CaelumPlayerAuthority.CanMutate(a),"other second-campaign participant preserved");
            let world=CaelumCooperativeQuests.Get(a);
            Check(world.Rescue[0]!=null && !world.Rescue[0].Contains(second),"leaving foreign world cannot create eligibility");
            Check(world.PrisonerState[1]==CaelumConstants.PRISONER_STATE_EXTRACTED,"foreign resolved objective stays resolved");
            Check(second.PrisonerRescueState[1]==CaelumConstants.PRISONER_STATE_FOLLOWING,"return departure preserves personal investigation");
            Check(!second.PrisonerRewardClaimed[0],"foreign world never paid the pending source reward");
        }
        else
        {
            if(first.ProfileImportApplied!=3)return;
            Check(CaelumPlayerAuthority.CanMutate(a) && !a.ProfileDeparted,"returned character can act");
            Check(first.ExternalProfileCampaign=="a" && first.ExternalProfileRevision==2,"returned identity advances custody once");
            Check(first.HouseRestitutionConfirmed && first.PalomoMerchantStock[0]==23,"original campaign world restored in place");
            let coins=a.FindInventory('CaelumCopperCoin');Check(coins!=null && coins.Amount==321,"returned wallet exactly once");
            let table=CaelumDiningSetItem(a.FindInventory('CaelumSmallDiningSetItem'));
            Check(table!=null && table.Table!=null && table.Table.PackedItem==table,"returned furniture ownership");
            Check(table!=null && table.Table!=null && table.Table.Items[0]!=null && table.Table.Items[0].Amount==3,"returned packed food");
            Check(a.bSolid && a.bShootable && !a.bInvisible && !a.bCorpse,"returned living body restored");
            Check(a.player.ReadyWeapon!=null && a.player.ReadyWeapon.Owner==a,"returned weapon owner restored");
            let world=CaelumCooperativeQuests.Get(a);
            Check(world.Rescue[0]!=null && world.Rescue[0].Contains(first),"returning reconstructed character retains earned eligibility");
            int money=a.GetOwnedMoneyCopperValue();
            Check(a.ClaimPrisonerPortReward(0,CaelumPrisonerRescue.FactionFor(0)),"original campaign pays pending reward after actual return");
            Check(!a.ClaimPrisonerPortReward(0,CaelumPrisonerRescue.FactionFor(0)) && a.GetOwnedMoneyCopperValue()==money+CaelumConstants.PRISONER_RESCUE_COPPER_REWARD,"return reward paid exactly once");
            Check(first.PrisonerRescueState[1]==CaelumConstants.PRISONER_STATE_FOLLOWING && !CaelumCooperativeQuests.Unavailable(a,CaelumConstants.QUEST_RESCUE_FIRST+1),"original campaign can continue the pending investigation");
        }
        Done=true;Console.Printf("CA434 RESULT return peer=%d",consoleplayer);
    }
}
