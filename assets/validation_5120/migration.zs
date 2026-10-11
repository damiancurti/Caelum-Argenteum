class CA173Migration : StaticEventHandler
{
    int Age;
    bool AlreadyComplete;
    override void WorldLoaded(WorldEvent e){Age=0;let p=CaelumPortSiege.Get();AlreadyComplete=p!=null && p.InteriorDoorRevision==1;}
    override void WorldTick()
    {
        Age++;let u=CaelumPlayer(players[0].mo);if(u==null)return;
        let port=CaelumPortSiege.Get();let audit=CA173LegacyAudit(u.FindInventory("CA173LegacyAudit"));
        if(Age==80)
        {
            CA173City.Check(audit!=null && audit.Defenders.Size()==600,"legacy audit persists");
            bool exact=audit.Entrance!=null && port.Defenders.Size()==600;
            for(int i=0;i<audit.Defenders.Size();i++)exact=exact && audit.Defenders[i]==port.Defenders[i];
            CA173City.Check(exact,"legacy soldiers and entrance retain actual instances");
            if(AlreadyComplete)
            {
                CA173City.Check(CA173City.Leaves(true)==640 && port.InteriorDoorRevision==1,"migrated save reload keeps exact door count and revision");
                Console.Printf("CA173 MIGRATION_RELOAD_DONE");return;
            }
            CA173City.Check(CA173City.Leaves(true)==638 && port.InteriorDoorRevision==0,"occupied saved doorway postpones only its pair");
            CA173City.Check(CA173City.FindDoor(0)==null,"migration never traps the saved player in a new leaf");
            u.SetOrigin(CaelumCityData.HouseRoad(0),false);u.Vel=(0,0,0);
        }
        if(Age==125 && !AlreadyComplete)
        {
            CA173City.Check(CA173City.Leaves(true)==640 && port.InteriorDoorRevision==1,"leaving doorway completes migration");
            CaelumCityInteriorDoors.Ensure(port);CaelumCityInteriorDoors.Ensure(port);
            CA173City.Check(CA173City.Leaves(true)==640,"repeated migration creates no duplicates");
            Console.Printf("CA173 MIGRATION_DONE");
        }
    }
}
