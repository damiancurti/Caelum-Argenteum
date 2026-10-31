// Ida y vuelta nativa antes de exportar: los niveles inactivos siguen siendo mundo.
class CA434ProfileProbe : StaticEventHandler
{
    int Stage,InitialMoney;
    bool Done;
    ui bool Saved;
    void Check(bool value,String label){Console.Printf("CA434 %s %s",value?"PASS":"FAIL",label);}
    override void UiTick()
    {
        if(Done && !Saved && consoleplayer==0)
        {
            Saved=true;let manager=SavegameManager.GetManager();manager.ReadSaveStrings();
            manager.InsertNewSaveNode();manager.DoSave(0,"CA434 native hub checkpoint");manager.RemoveNewSaveNode();
        }
    }
    override void WorldTick()
    {
        if(Done || level.time<105)return;
        let user=CaelumPlayer(players[0].mo);if(!CaelumWorldClockTicker.Ready(user))return;
        if(Stage==0)
        {
            Check(level.MapName=="MAP03","native hub starts in source campaign");Stage=1;
            InitialMoney=user.GetOwnedMoneyCopperValue();
            level.ChangeLevel("MAP01",0,CHANGELEVEL_NOINTERMISSION,-1);return;
        }
        if(Stage==1 && level.MapName=="MAP01")
        {
            Check(user.GetOwnedMoneyCopperValue()==InitialMoney,"native mansion arrival preserves wallet");
            Stage=2;level.ChangeLevel("MAP03",0,CHANGELEVEL_NOINTERMISSION,-1);return;
        }
        if(Stage==2 && level.MapName=="MAP03")
        {
            let table=CaelumDiningSetItem(user.FindInventory('CaelumSmallDiningSetItem'));
            Check(table!=null && table.Table!=null && table.Table.PackedItem==table,"restored native hub keeps packed furniture ownership");
            let world=CaelumCooperativeQuests.Get(user);
            Check(world.Rescue[0]!=null && world.Rescue[0].Contains(user.GetPersistentCharacterState(false)),"restored native hub keeps earned reward eligibility");
            Done=true;Console.Printf("CA434 RESULT hub peer=%d",consoleplayer);
        }
    }
}
