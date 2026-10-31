class CA437TravelLedger : Inventory
{
    int Phase,Victim;
    CaelumPlayer Body;
    CaelumPersistentCharacterState Record;
    Inventory Coin;
    vector3 Origin;
    double Wallet;
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA437ClockProbe : EventHandler
{
    bool Reloaded,Done;
    ui bool Saved;
    Inventory SceneToken;
    void Check(bool okay,String label){Console.Printf("CA437 %s %s",okay?"PASS":"FAIL",label);}
    override void WorldLoaded(WorldEvent e){if(e.IsSaveGame){Reloaded=true;Done=false;}}
    override void UiTick()
    {
        if(gamestate!=GS_LEVEL || consoleplayer!=0 || Saved || Reloaded || !Done)return;
        Saved=true;SavegameManager.GetManager().DoSave(0,"CA437 same corpse across hub travel");
    }
    override void NetworkProcess(ConsoleEvent e)
    {if(e.Name=="ca437_verify_reload" && e.Player==0){Reloaded=true;Done=false;}}
    override void WorldTick()
    {
        if(Done || level.time<TICRATE*3)return;
        let a=CaelumPlayer(players[0].mo);if(!CaelumWorldClockTicker.Ready(a))return;
        let ledger=CA437TravelLedger(a.FindInventory('CA437TravelLedger'));
        if(ledger==null)
        {
            if(level.MapName!="MAP03")return;
            for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i] && !CaelumWorldClockTicker.Ready(CaelumPlayer(players[i].mo)))return;
            ledger=CA437TravelLedger(a.GiveInventoryType('CA437TravelLedger'));
            for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])ledger.Victim=i;
            ledger.Body=CaelumPlayer(players[ledger.Victim].mo);
            ledger.Record=ledger.Body.GetPersistentCharacterState(false);
            ledger.Body.GiveInventory('CaelumCopperCoin',7);
            ledger.Coin=ledger.Body.FindInventory('CaelumCopperCoin');ledger.Wallet=ledger.Body.GetOwnedMoneyCopperValue();
            ledger.Origin=ledger.Body.Pos;
            SceneToken=Inventory(Actor.Spawn('CaelumCopperCoin',(500,500,0),NO_REPLACE));SceneToken.Amount=4;
            ledger.Body.health=ledger.Body.player.health=0;ledger.Body.Die(null,null,0,'None');
            Check(ledger.Body.bCorpse && ledger.Body.health<=0,"traveler starts with an actual native corpse");
            ledger.Phase=1;CaelumDeadTraveler.ChangeMap("TRESERV",0,CHANGELEVEL_NOINTERMISSION);return;
        }
        let body=ledger.Body;
        if(Reloaded)
        {
            Check(players[ledger.Victim].mo==body,"save restores the same traveled pawn");
            Check(body.health<=0 && body.player.playerstate==PST_DEAD,"save retains death after round-trip travel");
            Check(body.GetPersistentCharacterState(false)==ledger.Record,"save preserves the personal record");
            Check(body.FindInventory('CaelumCopperCoin')==ledger.Coin && body.GetOwnedMoneyCopperValue()==ledger.Wallet,"save preserves the original currency inventory");
            Check((body.Pos-ledger.Origin).Length()<0.1,"save preserves original corpse location");
            Check(SceneToken!=null && SceneToken.Amount==4,"save preserves original world stock");
            Done=true;Console.Printf("CA437 RESULT peer=%d travel-reload",consoleplayer);return;
        }
        if(level.MapName=="TRESERV" && ledger.Phase==1)
        {
            Check(players[ledger.Victim].mo==body,"map transfer keeps the same dead pawn");
            Check(body.health<=0 && body.player.playerstate==PST_DEAD && body.bCorpse,"destination never revives the traveler");
            Check(body.GetPersistentCharacterState(false)==ledger.Record,"destination keeps the same personal record");
            Check(body.FindInventory('CaelumCopperCoin')==ledger.Coin && body.GetOwnedMoneyCopperValue()==ledger.Wallet,"destination neither replaces nor duplicates owned inventory");
            let savedBody=CaelumDeadTraveler.View(body);
            Check(savedBody!=null && savedBody.Stored && !savedBody.InTransit && savedBody.BodyMap=="MAP03" && body.bInvisible,"absent corpse keeps its original map and remains unavailable");
            ledger.Phase=2;CaelumDeadTraveler.ChangeMap("MAP03",0,CHANGELEVEL_NOINTERMISSION);return;
        }
        if(level.MapName=="MAP03" && ledger.Phase==2)
        {
            Check(players[ledger.Victim].mo==body,"return keeps the original player body");
            Check(body.health<=0 && body.player.playerstate==PST_DEAD && !body.bInvisible,"return restores visible corpse without resurrection");
            Check((body.Pos-ledger.Origin).Length()<0.1,"corpse returns to its actual death location");
            Check(body.FindInventory('CaelumCopperCoin')==ledger.Coin && body.GetOwnedMoneyCopperValue()==ledger.Wallet,"round trip retains the exact original currency item");
            Check(SceneToken!=null && SceneToken.Amount==4,"hub round trip preserves unrelated world stock");
            ledger.Phase=3;Done=true;Console.Printf("CA437 RESULT peer=%d travel",consoleplayer);
        }
    }
}
