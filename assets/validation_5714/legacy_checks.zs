class CA472Checks : EventHandler
{
    int Passed,Failed;
    void Check(bool ok,String label){if(ok)Passed++;else Failed++;Console.Printf("CA472 %s %s",ok?"PASS":"FAIL",label);}
    override void NetworkProcess(ConsoleEvent e)
    {
        let user=CaelumPlayerAuthority.FromNetworkPlayer(e.Player);if(user==null)return;
        if(e.Name=="ca472_legacy_seed")
        {
            user.CharacterCreationComplete=true;user.CreationWizardOpen=false;CaelumWorldClock.Get(user,true);
            let record=user.GetPersistentCharacterState(true);record.LearnCraftingRecipe(176,1);record.LearnCraftingRecipe(169,1);
            let water=CaelumWaterContainer(user.GiveInventoryType('CaelumCanteenLarge'));water.WaterLiters=.8;
            let material=user.CreateDetachedMaterialStack(99,1,123);material.AttachToOwner(user);
            Check(record.RecipeBookVersion==13,"original 5.7.13 seed schema");
        }
        if(e.Name=="ca472_legacy_resume")
        {
            let record=user.GetPersistentCharacterState(true);let water=CaelumWaterContainer(user.FindInventory('CaelumCanteenLarge'));
            Check(record.RecipeBookVersion==13 && record.KnowsCraftingRecipe(176,1),"original runtime rollback preserves recipe knowledge");
            Check(water!=null && Abs(water.WaterLiters-.8)<.000001 && user.CountRawCraftingMaterial(99,1)==123,"original runtime rollback preserves inventory");
        }
        Console.Printf("CA472 RESULT passed=%d failed=%d map=%s",Passed,Failed,level.MapName);
    }
}
