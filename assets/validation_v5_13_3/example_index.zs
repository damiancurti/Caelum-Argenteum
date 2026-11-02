// Sólo diagnóstico: amplifica la reconstrucción única para medir su coste.
class CA440ExampleColdIndex : Actor
{
    override void Tick(){CaelumTarotExamples.Initialize();}
    Default {+NOINTERACTION +NOBLOCKMAP +NOGRAVITY}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA440ExampleWarmIndex : Actor
{
    override void Tick(){let cached=CaelumTarotExamples.Get();}
    Default {+NOINTERACTION +NOBLOCKMAP +NOGRAVITY}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA440IndexLedger : Inventory
{
    int Phase;
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE -INVENTORY.INVBAR}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA440Probe : StaticEventHandler
{
    override void WorldTick()
    {
        let user=CaelumPlayer(players[0].mo),other=CaelumPlayer(players[1].mo);
        if(!CaelumWorldClockTicker.Ready(user) || !CaelumWorldClockTicker.Ready(other))return;
        let ledger=CA440IndexLedger(user.FindInventory('CA440IndexLedger'));
        if(ledger==null)
        {
            ledger=CA440IndexLedger(user.GiveInventoryType('CA440IndexLedger'));
            ledger.Phase=1;Level.ChangeLevel("MAP01",0,CHANGELEVEL_NOINTERMISSION);return;
        }
        if(ledger.Phase==1 && level.MapName=="MAP01")
        {
            let room=CaelumTarotExamples.Get();
            if(room==null || room.Revision!=2){Console.Printf("CA440B FAIL missing current controller");return;}
            Actor.Spawn('CA440ExampleColdIndex',(0,0,0),NO_REPLACE);
            Actor.Spawn('CA440ExampleWarmIndex',(0,0,0),NO_REPLACE);
            Console.Printf("CA440B PASS native mansion controller exists with current apparatus");
            ledger.Phase=2;Console.Printf("CA440B RESULT capture");
        }
    }
}
