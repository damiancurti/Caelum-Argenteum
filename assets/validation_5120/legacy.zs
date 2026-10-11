// Crea un guardado con la ciudad anterior y el jugador en un vano sin puerta.
class CA173LegacyAudit : Inventory
{
    Array<CaelumPortDefender> Defenders;
    CaelumHingedDoorLeaf Entrance;
    Default { Inventory.MaxAmount 1; +INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE }
    States { Spawn: TNT1 A -1; Stop; }
}
class CA173Legacy : StaticEventHandler
{
    int Age;
    override void WorldTick()
    {
        Age++;if(Age!=100)return;let u=CaelumPlayer(players[0].mo);if(u==null)return;
        let r=u.GetPersistentCharacterState(true);r.DemoNarrativeDelivered=2047;r.DemoNarrativePending=0;
        let audit=CA173LegacyAudit(u.GiveInventoryType("CA173LegacyAudit"));
        let port=CaelumPortSiege.Get();
        for(int i=0;i<port.Defenders.Size();i++)audit.Defenders.Push(port.Defenders[i]);
        let it=ThinkerIterator.Create("CaelumHingedDoorLeaf");audit.Entrance=CaelumHingedDoorLeaf(it.Next());
        u.SetOrigin(CaelumCityData.HouseOrigin(0)+(416,384,0),false);u.Vel=(0,0,0);
        Console.Printf("CA173 LEGACY_READY defenders=%d",audit.Defenders.Size());
    }
}
