// La cámara de ensayo evita la predicción de mirada del jugador de red.
class CA440ArtCamera : Actor
{
    Default {+NOINTERACTION +NOGRAVITY}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA440ArtLedger : Inventory
{
    int Started;
    CaelumTarotChariot Display;
    Actor View;
    Default {Inventory.MaxAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE -INVENTORY.INVBAR}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA440Probe : StaticEventHandler
{
    override void WorldTick()
    {
        let user=CaelumPlayer(players[0].mo);let other=CaelumPlayer(players[1].mo);
        if(!CaelumWorldClockTicker.Ready(user) || !CaelumWorldClockTicker.Ready(other))return;
        let ledger=CA440ArtLedger(user.FindInventory('CA440ArtLedger'));
        if(ledger==null)
        {
            ledger=CA440ArtLedger(user.GiveInventoryType('CA440ArtLedger'));ledger.Started=level.time;
            user.SetOrigin((0,0,0),false);user.Angle=0;
            ledger.Display=CaelumTarotChariot.Launch(user);
            ledger.View=Actor.Spawn('CA440ArtCamera',(180,-180,100),NO_REPLACE);
            players[0].camera=ledger.View;
            user.SetOrigin((-700,-700,0),false);
            other.SetOrigin((-800,-800,0),false);
            Console.Printf("CA440V %s native model display spawned",ledger.Display!=null?"PASS":"FAIL");
            Console.Printf("CA440V RESULT capture");
        }
        if(ledger.Display!=null)
        {
            ledger.Display.Age=0;ledger.Display.Travelled=0;ledger.Display.Direction=(0,0);
            ledger.Display.SetOrigin((0,0,0),false);
        }
        ledger.View.SetOrigin(level.time-ledger.Started<190?(180,-180,100):(-180,180,100),false);
        ledger.View.Angle=VectorAngle(-ledger.View.Pos.X,-ledger.View.Pos.Y);ledger.View.Pitch=12;
    }
}
