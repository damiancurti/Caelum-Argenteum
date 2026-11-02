class CA440ArtCamera : Actor
{
    Default {+NOINTERACTION +NOGRAVITY}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA440ArtLedger : Inventory
{
    int Started;
    CaelumTarotRoots Display;
    Actor View;
    Default {Inventory.MaxAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE -INVENTORY.INVBAR}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA440Probe : StaticEventHandler
{
    override void WorldTick()
    {
        let user=CaelumPlayer(players[0].mo),other=CaelumPlayer(players[1].mo);
        if(!CaelumWorldClockTicker.Ready(user) || !CaelumWorldClockTicker.Ready(other))return;
        let ledger=CA440ArtLedger(user.FindInventory('CA440ArtLedger'));
        if(ledger==null)
        {
            ledger=CA440ArtLedger(user.GiveInventoryType('CA440ArtLedger'));ledger.Started=level.time;
            user.SetOrigin((-200,0,0),false);other.SetOrigin((0,0,0),false);other.Angle=315;
            let snapshot=CaelumTarotGroundAim.Capture(user);snapshot.Damage=0;
            bool placed=CaelumTarotRoots.Place(user,other,2100,snapshot);
            let holder=CaelumTarotPlantState(user.FindInventory('CaelumTarotPlantState'));
            ledger.Display=holder!=null?holder.Roots:null;
            ledger.View=Actor.Spawn('CA440ArtCamera',(100,-100,65),NO_REPLACE);
            players[0].camera=ledger.View;
            Console.Printf("CA440V %s native thorned plants surround the actual player body",placed?"PASS":"FAIL");
            Console.Printf("CA440V RESULT capture");
        }
        ledger.View.SetOrigin(level.time-ledger.Started<190?(100,-100,65):(-100,100,65),false);
        ledger.View.Angle=VectorAngle(-ledger.View.Pos.X,-ledger.View.Pos.Y);ledger.View.Pitch=15;
    }
}
