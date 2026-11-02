// Fixture exclusivo: mide reconstrucción en la mansión real, no modifica su paquete.
class CA440WaterColdIndex : Actor
{
    override void Tick()
    {
        let temporary=CaelumTarotWaterMap(Actor.Spawn('CaelumTarotWaterMap',(0,0,0),NO_REPLACE));
        temporary.Geometry();temporary.Destroy();
    }
    Default {+NOINTERACTION +NOBLOCKMAP +NOGRAVITY}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA440WaterWarmIndex : Actor
{
    CaelumTarotWaterMap Cached;
    override void Tick(){if(Cached!=null)Cached.Geometry();}
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
            Actor.Spawn('CA440WaterColdIndex',(0,0,0),NO_REPLACE);
            let warm=CA440WaterWarmIndex(Actor.Spawn('CA440WaterWarmIndex',(0,0,0),NO_REPLACE));
            warm.Cached=CaelumTarotWaterMap(Actor.Spawn('CaelumTarotWaterMap',(0,0,0),NO_REPLACE));
            warm.Cached.Geometry();
            Console.Printf("CA440B PASS native mansion sectors=%d waterParts=%d",warm.Cached.GeometrySectorCount,warm.Cached.Parts.Size());
            ledger.Phase=2;Console.Printf("CA440B RESULT capture");
        }
    }
}
