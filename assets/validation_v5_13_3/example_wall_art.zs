// Se conserva la clase del guardado anterior para comprobar su migración real.
class CA440ExampleRuntimeLedger : Inventory
{
    int Phase,Started;
    CaelumTarotExampleRoom Room;
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE -INVENTORY.INVBAR}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA440WallArtLedger : Inventory
{
    int Phase,Started;
    CaelumTarotFalseWall Wall;
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE -INVENTORY.INVBAR}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA440Probe : StaticEventHandler
{
    bool Entered,Reloaded;
    void Check(bool ok,String label){Console.Printf("CA440V %s %s",ok?"PASS":"FAIL",label);}
    override void WorldTick()
    {
        if(level.time<105)return;
        let user=CaelumPlayer(players[0].mo),other=CaelumPlayer(players[1].mo);
        if(!CaelumWorldClockTicker.Ready(user) || !CaelumWorldClockTicker.Ready(other))return;
        let ledger=CA440WallArtLedger(user.FindInventory('CA440WallArtLedger'));
        if(!Entered){Entered=true;Reloaded=ledger!=null;}
        if(ledger==null)
        {
            let prior=CA440ExampleRuntimeLedger(user.FindInventory('CA440ExampleRuntimeLedger'));
            let room=CaelumTarotExamples.Get();
            Check(prior!=null && prior.Room==room,"loads an actual pre-art apparatus save without replacing its controller");
            if(room==null)return;
            ledger=CA440WallArtLedger(user.GiveInventoryType('CA440WallArtLedger'));
            ledger.Wall=CaelumTarotFalseWall(room.Doors[0]);
            Check(ledger.Wall!=null && ledger.Wall.VisualRevision==1 && ledger.Wall.sprite==ledger.Wall.FindState('Spawn').sprite,"saved wood leaf migrates to the mansion stone sprite");
            Check(ledger.Wall.Radius==4 && ledger.Wall.Height==120 && ledger.Wall.SlideProgress==0,"visual migration preserves closed native collision dimensions");
            user.SetOrigin(ledger.Wall.ClosedPosition+(0,-100,0),false);user.Angle=90;user.Pitch=0;
            other.SetOrigin(ledger.Wall.ClosedPosition+(0,160,0),false);other.Angle=270;other.Pitch=0;
            let record=user.GetPersistentCharacterState(false);record.TarotSelected[2]=true;
            ledger.Started=level.time;ledger.Phase=1;return;
        }
        if(Reloaded && ledger.Phase==2)
        {
            Check(ledger.Wall==CaelumTarotExamples.Get().Doors[0] && ledger.Wall.sprite==ledger.Wall.FindState('Spawn').sprite,"common recovery keeps the exact stone leaf");
            Check(ledger.Wall.VisualRevision==1 && ledger.Wall.SlideProgress==0,"visual migration is idempotent on recovery");
            ledger.Phase=3;Console.Printf("CA440V RESULT reload");return;
        }
        if(ledger.Phase==1 && level.time-ledger.Started>20)
        {
            let record=user.GetPersistentCharacterState(false);
            Check(CaelumTarotFalseWall.Revealed(user),"equipped Priestess still identifies the unchanged secret target");
            record.TarotSelected[2]=false;
            Check(!CaelumTarotFalseWall.Revealed(user),"ordinary viewer still receives no secret identity");
            ledger.Phase=2;Console.Printf("CA440V RESULT capture");
        }
    }
}
