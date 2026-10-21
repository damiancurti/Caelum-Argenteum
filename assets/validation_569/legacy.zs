// Compatible con 5.5.8a: tarea de flechas y cargadores reales para migración.
class CA380LegacyCheckpoint : Inventory
{
    String TaskStamp;
    int Carbine,Shotgun,Arrows,BookRevision;
    double RawStamp;
    Default { Inventory.MaxAmount 1; Inventory.InterHubAmount 1; +INVENTORY.UNDROPPABLE }
}
class CA380Legacy : CA376Checks
{
    void SaveArrow(CaelumPlayer u)
    {
        Setup(u);Select(u,129,2);
        for(int n=0;n<2;n++)
        {
            Name cls=n==0?'CaelumCarbineAmmo':'CaelumShotgunAmmo';let ammo=u.FindInventory(cls);
            if(ammo==null){ammo=Inventory(Actor.Spawn(cls,u.Pos,NO_REPLACE));ammo.AttachToOwner(u);}
            ammo.Amount=n==0?137:83;
        }
        u.SetRangedMagazineCount(2,7);u.SetRangedMagazineCount(14,1);
        u.BeginSelectedCraftingTask();u.CloseCraftingStationSession();u.PersistCharacterState();
        let m=CA380LegacyCheckpoint(Actor.Spawn('CA380LegacyCheckpoint',u.Pos,NO_REPLACE));m.AttachToOwner(u);
        m.Carbine=137;m.Shotgun=83;let arrows=u.FindInventory('CaelumArrowAmmo');m.Arrows=arrows==null?0:arrows.Amount;
        m.TaskStamp=Task(u);m.RawStamp=Raw(u);m.BookRevision=u.GetPersistentCharacterState(true).RecipeBookVersion;
        Check(u.CraftingTaskActive && u.CraftingTaskRecipeIndex==129,"legacy arrow task created");VerifyArrow(u);
    }
    void VerifyArrow(CaelumPlayer u)
    {
        let m=CA380LegacyCheckpoint(u.FindInventory('CA380LegacyCheckpoint'));Check(m!=null,"legacy arrow checkpoint restored");if(m==null)return;
        let carbine=u.FindInventory('CaelumCarbineAmmo');let shotgun=u.FindInventory('CaelumShotgunAmmo');let arrows=u.FindInventory('CaelumArrowAmmo');
        Check(carbine!=null && shotgun!=null && carbine.Amount==m.Carbine && shotgun.Amount==m.Shotgun,"legacy cartridge quantities preserved");
        Check((arrows==null?0:arrows.Amount)==m.Arrows && Task(u)==m.TaskStamp && Raw(u)==m.RawStamp,"legacy paused arrow task and native inputs preserved");
        Check(u.GetRangedMagazineCount(2)==7 && u.GetRangedMagazineCount(14)==1,"partial magazines preserved");
        Check(u.IsCraftingRecipeKnown(129),"old arrow knowledge preserved");
        Console.Printf("CA376 PERSIST legacy arrow passed=%d failed=%d book=%d",Passed,Failed,u.GetPersistentCharacterState(true).RecipeBookVersion);
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=='ca380_legacy_save')SaveArrow(u);
        if(e.Name=='ca380_legacy_verify')VerifyArrow(u);
    }
}
