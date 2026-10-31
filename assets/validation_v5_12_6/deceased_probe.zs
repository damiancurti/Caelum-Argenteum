// La transferencia conserva la muerte real; únicamente Redención resucita.
class CA434ProfileProbe : StaticEventHandler
{
    bool Done;
    ui bool Saved;
    void Check(bool value,String text){Console.Printf("CA434 %s %s",value?"PASS":"FAIL",text);}
    override void UiTick()
    {
        if(Done && !Saved && consoleplayer==0)
        {
            Saved=true;let manager=SavegameManager.GetManager();manager.ReadSaveStrings();
            manager.InsertNewSaveNode();manager.DoSave(0,"CA434 deceased profile checkpoint");manager.RemoveNewSaveNode();
        }
    }
    override void WorldTick()
    {
        if(Done || level.time<105)return;
        let a=CaelumPlayer(players[0].mo);let b=CaelumPlayer(players[1].mo);
        if(!CaelumPlayerAuthority.CanRead(a) || !CaelumPlayerAuthority.CanRead(b))return;
        let first=a.GetPersistentCharacterState(false);let second=b.GetPersistentCharacterState(false);
        if(first==null || second==null)return;
        if(first.ExternalProfileId.Length()==0)
        {
            if(!CaelumWorldClockTicker.Ready(a) || !CaelumWorldClockTicker.Ready(b))return;
            a.GiveInventory('CaelumCopperCoin',321);
            a.health=a.player.health=0;a.Die(null,null,0,'None');
            a.PersistCharacterState();b.PersistCharacterState();
            Check(a.bCorpse && a.player.playerstate==PST_DEAD,"native death creates a corpse");
            Check(CaelumSessionLifecycle.Waiting(a),"dead character waits without respawn");
            Check(a.GetOwnedMoneyCopperValue()>=321,"corpse retains owned currency");
            Check(b.health>0,"second participant remains alive");
        }
        else if(first.ProfileDeparted)
        {
            Check(a.ProfileDeparted && !CaelumPlayerAuthority.CanMutate(a),"departed corpse cannot act");
            Check(a.FindInventory('CaelumCopperCoin')==null,"source corpse loses transferred currency");
            Check(a.health<=0,"source transfer does not revive the corpse");
            Check(b.health>0,"other source participant remains alive");
        }
        else
        {
            if(second.ProfileImportApplied!=second.ProfileImportSerial || second.ProfileImportSerial==0)return;
            Check(b.health<=0 && b.player.health<=0 && b.bCorpse && b.player.playerstate==PST_DEAD,"import preserves native death");
            Check(CaelumSessionLifecycle.Waiting(b),"imported dead character waits for Limbo");
            Check(b.GetOwnedMoneyCopperValue()>=321,"imported corpse owns its currency");
            Check(a.health<=0,"unrelated destination corpse is not revived");
        }
        Done=true;Console.Printf("CA434 RESULT deceased peer=%d",consoleplayer);
    }
}
