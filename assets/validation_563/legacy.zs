// Fixture compatible con el paquete original 5.5.8a y el revisado.
class CA378LegacyChecks : StaticEventHandler
{
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!="ca378_legacy_save" && e.Name!="ca378_legacy_verify")return;
        let u=CaelumPlayer(players[0].mo);if(u==null)return;
        int recipe=CaelumCraftingRules.FindUnifiedPhysicalRecipeIndex(CaelumConstants.CATALOGUE_WEAPON_LONGBOW);
        let r=u.GetPersistentCharacterState(true);
        if(e.Name=="ca378_legacy_save")
        {
            u.bInvulnerable=true;u.DebugAttributesAt100=true;u.ApplyCharacterProfile();
            u.CreationWizardOpen=false;r.SetAllCraftingRecipesKnown(false);
            r.LearnCraftingRecipe(recipe);u.PersistCharacterState();
        }
        bool ok=r.KnowsCraftingRecipe(recipe) && !r.KnowsCraftingRecipe(CaelumConstants.CRAFTING_ARROW_RECIPE);
        Console.Printf("CA378 %s original learned and unknown recipe state",ok?"PASS":"FAIL");
        Console.Printf("CA378 RESULT %d PASS %d FAIL",ok?1:0,ok?0:1);
    }
}
