// Este fixture compila tanto con 5.5.8a como con el paquete revisado.
class CA381LegacyCheckpoint : Inventory
{
    CaelumStashChest Prototype;
    CaelumMazeChest Maze;
    Inventory Entries[5];
    Inventory Removed;
    int Identity, Wear;
    Default { +INVENTORY.UNDROPPABLE Inventory.MaxAmount 1; }
}
class CA381LegacyChecks : StaticEventHandler
{
    int Passed, Failed;
    void Check(bool ok,String name)
    {
        if(ok)Passed++;else Failed++;
        Console.Printf("CA381 %s %s",ok ? "PASS" : "FAIL",name);
    }
    void Prepare(CaelumPlayer u)
    {
        u.bInvulnerable=true;u.DebugAttributesAt100=true;u.ApplyCharacterProfile();
        u.CreationWizardOpen=false;
        let mark=CA381LegacyCheckpoint(Actor.Spawn("CA381LegacyCheckpoint",u.Pos,NO_REPLACE));
        mark.AttachToOwner(u);
        mark.Prototype=CaelumStashChest(Actor.Spawn("CaelumLockedStashChest",u.Pos+(48,0,0),NO_REPLACE));
        mark.Prototype.ChestUnlocked=true;mark.Prototype.ChestOpen=true;
        mark.Prototype.RefreshChestVisual();mark.Prototype.ChangeTid(1382);
        mark.Maze=CaelumMazeChest(Actor.Spawn("CaelumMazeChest",u.Pos+(0,100,0),NO_REPLACE));
        mark.Maze.EnsureLoot();mark.Maze.ChangeTid(1383);
        mark.Removed=mark.Maze.Loot[0];mark.Maze.RemoveInventory(mark.Removed);
        mark.Removed.AttachToOwner(u);mark.Maze.Loot[0]=null;
        let equipment=CaelumEquipmentItem(mark.Removed);
        equipment.AcquisitionResolved=true;equipment.Durability=19;u.EnsureEquipmentItemId(equipment);
        mark.Identity=equipment.ItemId;mark.Wear=equipment.Durability;
        for(int i=0;i<5;i++)mark.Entries[i]=mark.Maze.Loot[i];
        u.PersistCharacterState();
        Verify(u);
    }
    void Verify(CaelumPlayer u)
    {
        let mark=CA381LegacyCheckpoint(u.FindInventory("CA381LegacyCheckpoint"));
        Check(mark!=null,"legacy checkpoint survives");if(mark==null)return;
        Check(mark.Prototype!=null && mark.Prototype.ChestUnlocked && mark.Prototype.ChestOpen
            && mark.Prototype.Radius==32 && mark.Prototype.Height==60,"legacy prototype open unlocked geometry");
        Check(mark.Prototype.Inv==null,"legacy prototype remains empty");
        Check(mark.Maze!=null && mark.Maze.Stocked && mark.Maze.Seeded==5,"legacy maze initialization preserved");
        Check(mark.Maze.Loot[0]==null,"legacy looted gap not reseeded");
        for(int i=1;i<5;i++)
            Check(mark.Maze.Loot[i]==mark.Entries[i] && (mark.Entries[i]==null || mark.Entries[i].Owner==mark.Maze),
                String.Format("legacy exact remaining entry %d",i));
        let equipment=CaelumEquipmentItem(mark.Removed);
        Check(equipment!=null && equipment.Owner==u && equipment.ItemId==mark.Identity
            && equipment.Durability==mark.Wear,"legacy acquired item retains identity and wear");
        Console.Printf("CA381 LEGACY passed=%d failed=%d map=%s",Passed,Failed,level.MapName);
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[0].mo);if(u==null)return;
        if(e.Name=="ca381_legacy_save")Prepare(u);
        if(e.Name=="ca381_legacy_verify")Verify(u);
    }
}
