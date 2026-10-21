// Verifica el consumo real después de cargar, sin reiniciar el inventario.
class CA380Resume : CA380Checks
{
    void Resume(CaelumPlayer u,bool legacy)
    {
        if(!legacy)Verify(u);
        Bench=CaelumCraftingStation(Actor.Spawn("CaelumWorkbenchStation",u.Pos+(48,0,0),NO_REPLACE));
        Ranged=CaelumCraftingStation(Actor.Spawn("CaelumRangedWorkshopStation",u.Pos+(0,48,0),NO_REPLACE));Open(u);
        let arrows=u.FindInventory('CaelumArrowAmmo');int before=arrows==null?0:arrows.Amount;
        int shotgun=Count(u,1),kits=u.CountRawCraftingMaterial(Kit(1),1);
        Check(u.CraftingTaskActive && u.RefreshActiveCraftingStationSession(),"loaded task reopens at valid station network");
        u.CraftingTaskRemainingSeconds=0;u.CompleteCraftingTask();
        Check(!u.CraftingTaskActive && u.LastCraftingAction==CaelumConstants.CRAFTING_ACTION_CREATED,"loaded task completes successfully");
        if(legacy)
        {
            arrows=u.FindInventory('CaelumArrowAmmo');
            Check(arrows!=null && arrows.Amount==before+10,"actual legacy arrow task grants ten arrows after upgrade");
            u.CompleteCraftingTask();Check(arrows!=null && arrows.Amount==before+10,"legacy completion cannot repeat after load");
            Check(u.GetRangedMagazineCount(2)==7 && u.GetRangedMagazineCount(14)==1,"legacy completion preserves both partial magazines");
        }
        else
        {
            Check(Count(u,1)==shotgun+10 && u.CountRawCraftingMaterial(Kit(1),1)==kits-10,"loaded cartridge task pays exactly ten kits for ten cartridges");
            u.CompleteCraftingTask();Check(Count(u,1)==shotgun+10 && u.CountRawCraftingMaterial(Kit(1),1)==kits-10,"repeated loaded completion is inert");
            Completed(u);
        }
        Result();
    }
    void Completed(CaelumPlayer u)
    {
        let m=CA380Checkpoint(u.FindInventory('CA380Checkpoint'));Check(m!=null,"completed checkpoint present");if(m==null)return;
        Check(!u.CraftingTaskActive && Count(u,1)==m.Ammo[1]+10
            && u.CountRawCraftingMaterial(Kit(1),1)==m.Kits[1]-10,"completed save retains exact output/input counts");
        Check(u.GetPersistentCharacterState(true).RecipePractice[CaelumRecipeLearning.Slot(Recipe(1),1)]==m.Practice[1]+10
            && u.GetReservedCraftingMaterialUnits(Kit(1),1)==0,"completed save retains single practice award and no reservations");
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=='ca380_resume')Resume(u,false);
        if(e.Name=='ca380_resume_legacy')Resume(u,true);
        if(e.Name=='ca380_completed'){Completed(u);Result();}
    }
}
