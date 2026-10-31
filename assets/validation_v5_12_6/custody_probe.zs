// Verifica ambas campañas nativas antes de publicar el traslado atómico.
class CA434ProfileProbe : StaticEventHandler
{
    bool Done,Logged;
    ui bool Saved;
    void Check(bool value,String label){Console.Printf("CA434 %s %s",value?"PASS":"FAIL",label);}
    override void UiTick()
    {
        if(Done && !Saved && consoleplayer==0)
        {
            Saved=true;let manager=SavegameManager.GetManager();manager.ReadSaveStrings();
            manager.InsertNewSaveNode();manager.DoSave(0,"CA434 custody native checkpoint");manager.RemoveNewSaveNode();
        }
    }
    override void WorldTick()
    {
        if(Done || level.time<105)return;
        let a=CaelumPlayer(players[0].mo);let b=CaelumPlayer(players[1].mo);
        bool diagnostic=!Logged;
        if(!Logged){Logged=true;Console.Printf("CA434 DEBUG time=%d a=%p b=%p ready=%d/%d",level.time,a,b,CaelumPlayerAuthority.CanRead(a),CaelumPlayerAuthority.CanRead(b));}
        if(!CaelumPlayerAuthority.CanRead(a) || !CaelumPlayerAuthority.CanRead(b))return;
        let first=a.GetPersistentCharacterState(false);let second=b.GetPersistentCharacterState(false);
        if(first==null || second==null){Console.Printf("CA434 DEBUG records %p/%p",first,second);Done=true;return;}
        if(diagnostic)Console.Printf("CA434 DEBUG departed=%d/%d id=%s campaign=%s serial=%d applied=%d",first.ProfileDeparted,a.ProfileDeparted,first.ExternalProfileId,second.ExternalProfileCampaign,second.ProfileImportSerial,second.ProfileImportApplied);
        if(first.ProfileDeparted)
        {
            Check(a.ProfileDeparted && !CaelumPlayerAuthority.CanMutate(a),"departed slot cannot act");
            Check(a.FindInventory('CaelumCopperCoin')==null,"departed wallet absent");
            Check(a.FindInventory('CaelumCanteenLarge')==null,"departed vessel absent");
            Check(a.FindInventory('CaelumSmallDiningSetItem')==null,"packed table absent from source owner");
            Check(a.player.ReadyWeapon==null,"departed slot has no usable native weapon");
            Check(!a.bSolid && !a.bShootable && a.bInvisible,"departed body does not block or participate");
            Check(first.HouseRestitutionConfirmed && first.PalomoMerchantStock[0]==23,"source title and shop retained");
            Check(!b.ProfileDeparted && CaelumPlayerAuthority.CanMutate(b),"other source participant remains active");
            let world=CaelumCooperativeQuests.Get(b);
            Check(world.Rescue[0]!=null && world.Rescue[0].Contains(first),"source retains absent character's earned eligibility");
            Check(!first.PrisonerRewardClaimed[0],"departure does not redeem a pending reward");
            Check(world.PrisonerState[1]==CaelumConstants.PRISONER_STATE_FOLLOWING,"source world keeps its unresolved objective");
            Check(first.LawfulIdentity!=null,"historical eligibility keeps the original legal identity");
        }
        else
        {
            if(second.ProfileImportApplied!=2)return;
            Check(!b.ProfileDeparted && CaelumPlayerAuthority.CanMutate(b),"destination can act after import");
            Check(second.ExternalProfileCampaign=="b" && second.ExternalProfileRevision==1,"destination identity and custody revision");
            Check(second.ProfileImportApplied==second.ProfileImportSerial,"native reconciliation completed once");
            let coins=b.FindInventory('CaelumCopperCoin');Check(coins!=null && coins.Amount==321,"wallet transferred exactly");
            let table=CaelumDiningSetItem(b.FindInventory('CaelumSmallDiningSetItem'));
            Check(table!=null && table.Table!=null && table.Table.PackedItem==table,"packed ownership retained");
            Check(table!=null && table.Table!=null && table.Table.Items[0]!=null && table.Table.Items[0].Amount==3,"packed food retained");
            Check(!second.HouseRestitutionConfirmed && second.PalomoMerchantStock[0]==91,"destination world retained");
            Check(b.player.ReadyWeapon!=null && b.player.ReadyWeapon.Owner==b,"destination native weapon restored");
            let world=CaelumCooperativeQuests.Get(b);
            Check(world.Rescue[0]!=null && !world.Rescue[0].Contains(second),"new occupant does not inherit old occupant eligibility");
            int money=b.GetOwnedMoneyCopperValue();
            Check(!b.ClaimPrisonerPortReward(0,CaelumPrisonerRescue.FactionFor(0)) && b.GetOwnedMoneyCopperValue()==money,"foreign campaign gives no retroactive reward");
            Check(second.PrisonerRescueState[1]==CaelumConstants.PRISONER_STATE_FOLLOWING,"incoming personal objective remains pending");
            Check(CaelumCooperativeQuests.Unavailable(b,CaelumConstants.QUEST_RESCUE_FIRST+1),"resolved foreign objective appears unavailable");
        }
        Done=true;Console.Printf("CA434 RESULT custody peer=%d",consoleplayer);
    }
}
