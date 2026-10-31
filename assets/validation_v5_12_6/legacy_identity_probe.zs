// La actualización nativa crea identidad y registro del mundo sin rehacer bienes.
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
            manager.InsertNewSaveNode();manager.DoSave(0,"CA434 legacy native migration");manager.RemoveNewSaveNode();
        }
    }
    override void WorldTick()
    {
        if(Done || level.time<105)return;
        let user=CaelumPlayer(players[0].mo);if(!CaelumWorldClockTicker.Ready(user))return;
        let record=user.GetPersistentCharacterState(false);let world=CaelumCooperativeQuests.Get(user);
        Check(record.LawfulIdentity!=null && record.LawfulIdentity.Token.Length()>0,"legacy character gains stable native identity");
        Check(world!=null && world.Revision==2,"legacy campaign initializes objective ledger once");
        let coins=user.FindInventory('CaelumCopperCoin');Check(coins!=null && coins.Amount==321,"legacy wallet remains unchanged");
        let table=CaelumDiningSetItem(user.FindInventory('CaelumSmallDiningSetItem'));
        Check(table!=null && table.Table!=null && table.Table.PackedItem==table,"legacy packed furniture retains its real ownership");
        Done=true;Console.Printf("CA434 RESULT legacy identity peer=%d",consoleplayer);
    }
}
