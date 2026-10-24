class CA411CampLegacy : EventHandler
{
    override void NetworkProcess(ConsoleEvent e)
    {
        let user=CaelumPlayer(players[e.Player].mo);if(user==null)return;
        if(e.Name=="ca411_camp_legacy_seed")
        {
            let record=user.GetPersistentCharacterState(true);record.LearnCraftingRecipe(198,1);
            let water=CaelumWaterContainer(Actor.Spawn('CaelumBottleNormal',user.Pos,NO_REPLACE));
            water.AddWater(2,7,60,true);water.AttachToOwner(user);
            Console.Printf("CA411 RESULT legacy recipe_version=%d failures=%d",record.RecipeBookVersion,record.RecipeBookVersion==14?0:1);
        }
        else if(e.Name=="ca411_camp_legacy_verify")
        {
            let record=user.GetPersistentCharacterState(true);record.EnsureTierRecipeBook();
            let water=CaelumWaterContainer(user.FindInventory('CaelumBottleNormal'));
            bool ok=record.KnowsCraftingRecipe(198,1) && water!=null && water.WaterLiters==2 && water.WaterQuality==7;
            VERIFY_APPENDED
            Console.Printf("CA411 %s camp old save retains learned recipe and original water",ok?"PASS":"FAIL");
            Console.Printf("CA411 RESULT legacy recipe_version=%d failures=%d",record.RecipeBookVersion,ok?0:1);
        }
    }
}
