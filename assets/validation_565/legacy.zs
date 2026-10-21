// Compila con 5.6.4 y 5.6.5; guarda un cofre previo y conocimiento existente.
class CA382LegacyCheckpoint : Inventory
{
    CaelumStashChest Chest;
    CaelumRecipeBook Book;
    Inventory Content;
    Default { Inventory.MaxAmount 1; Inventory.InterHubAmount 1; +INVENTORY.UNDROPPABLE }
}
class CA382LegacyChecks : StaticEventHandler
{
    void Verify(CaelumPlayer u)
    {
        let mark=CA382LegacyCheckpoint(u.FindInventory("CA382LegacyCheckpoint"));
        bool ok=mark!=null && mark.Chest!=null && mark.Book!=null && mark.Content!=null;
        if(ok)ok=mark.Chest.StorageTier==0 && mark.Content.Owner==mark.Chest
            && mark.Content.Amount==7 && mark.Chest.GetChestLockNumber()==0
            && mark.Book.Sheets[CaelumConstants.CRAFTING_LARGE_CANTEEN_RECIPE*3];
        let record=u.GetPersistentCharacterState(true);
        if(ok)ok=record.RecipePractice[CaelumConstants.CRAFTING_LARGE_CANTEEN_RECIPE*3]==3
            && record.RecipeRereadings[CaelumConstants.CRAFTING_LARGE_CANTEEN_RECIPE*3]==4;
        Console.Printf("CA382 %s legacy content/book/progress preserved",ok?"PASS":"FAIL");
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[0].mo);if(u==null)return;
        if(e.Name=="ca382_legacy_save")
        {
            u.bInvulnerable=true;u.DebugAttributesAt100=true;u.ApplyCharacterProfile();u.CreationWizardOpen=false;
            let mark=CA382LegacyCheckpoint(Actor.Spawn("CA382LegacyCheckpoint",u.Pos,NO_REPLACE));mark.AttachToOwner(u);
            mark.Chest=CaelumStashChest(Actor.Spawn("CaelumStashChest",u.Pos+(64,0,0),NO_REPLACE));
            mark.Chest.EnsureStorage();mark.Chest.StorageTier=0;mark.Chest.ApplyStorageSize();
            mark.Content=Inventory(Actor.Spawn("CaelumGoldCoin",u.Pos,NO_REPLACE));mark.Content.Amount=7;mark.Content.AttachToOwner(mark.Chest);
            mark.Book=CaelumRecipeBook(Actor.Spawn("CaelumRecipeBook",u.Pos,NO_REPLACE));mark.Book.AttachToOwner(u);
            mark.Book.Sheets[CaelumConstants.CRAFTING_LARGE_CANTEEN_RECIPE*3]=true;
            let record=u.GetPersistentCharacterState(true);record.SetAllCraftingRecipesKnown(true);
            record.RecipePractice[CaelumConstants.CRAFTING_LARGE_CANTEEN_RECIPE*3]=3;
            record.RecipeRereadings[CaelumConstants.CRAFTING_LARGE_CANTEEN_RECIPE*3]=4;
            Verify(u);
        }
        if(e.Name=="ca382_legacy_verify")Verify(u);
    }
}
