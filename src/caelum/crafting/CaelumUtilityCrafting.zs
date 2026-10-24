// Las utilidades participan en la reserva, el tiempo y el pago nativos.
class CaelumUtilityCrafting : Object
{
    static bool IsRecipe(int recipe)
    { return CaelumCampData.IsRecipe(recipe) || CaelumMateData.IsRecipe(recipe) || CaelumLockRules.IsRecipe(recipe) || recipe == CaelumConstants.CRAFTING_SLEEPING_BAG_RECIPE || recipe == CaelumConstants.CRAFTING_LARGE_CANTEEN_RECIPE; }
    static Name ItemClass(int recipe)
    { if(CaelumCampData.IsRecipe(recipe))return CaelumCampData.ItemClass(recipe-CaelumCampData.FIRST_RECIPE);
        if(CaelumMateData.IsRecipe(recipe))return CaelumMateData.ItemClass(recipe-CaelumMateData.FIRST_RECIPE);
        return CaelumLockRules.IsRecipe(recipe) ? 'CaelumLockItem' : recipe == CaelumConstants.CRAFTING_SLEEPING_BAG_RECIPE ? 'CaelumSleepingBag' : 'CaelumCanteenLarge'; }
    static clearscope String NameKey(int recipe)
    { if(CaelumCampData.IsRecipe(recipe))return CaelumCampData.NameKey(recipe-CaelumCampData.FIRST_RECIPE);
        if(CaelumMateData.IsRecipe(recipe))return CaelumMateData.NameKey(recipe-CaelumMateData.FIRST_RECIPE);
        return CaelumLockRules.IsRecipe(recipe) ? CaelumLockRules.NameKey(CaelumLockRules.RecipeItem(recipe)) : recipe == CaelumConstants.CRAFTING_SLEEPING_BAG_RECIPE ? "CA_SLEEPING_BAG_NAME" : "CA_WATER_CANTEEN_LARGE"; }
    static play double Weight(int recipe)
    {
        if(CaelumCampData.IsRecipe(recipe))return CaelumCampData.Mass(recipe-CaelumCampData.FIRST_RECIPE);
        if(CaelumMateData.IsRecipe(recipe))return CaelumMateData.EmptyMass(recipe-CaelumMateData.FIRST_RECIPE);
        if (CaelumLockRules.IsRecipe(recipe)) return CaelumLockRules.RecipeWeight(recipe);
        if (recipe == CaelumConstants.CRAFTING_SLEEPING_BAG_RECIPE)
            return GetDefaultByType("CaelumSleepingBag").GetUnitWeight();
        return GetDefaultByType("CaelumCanteenLarge").GetUnitWeight();
    }
    static play void Complete(CaelumPlayer user)
    {
        if (CaelumLockRules.IsRecipe(user.CraftingSelectionRecipe))
        { CaelumLockRules.Complete(user); return; }
        if (!CaelumCampData.IsRecipe(user.CraftingSelectionRecipe) && user.FindInventory(ItemClass(user.CraftingSelectionRecipe)) != null)
        { user.LastCraftingAction = CaelumConstants.CRAFTING_ACTION_FAILED_DUPLICATE; return; }
        if (!user.CraftingTaskCompleting || !user.CraftingSelectedInfrastructureAvailable
            || !user.ValidateCraftingTaskReservations()) return;
        let result = Inventory(Actor.Spawn(ItemClass(user.CraftingSelectionRecipe), user.Pos, NO_REPLACE));
        if (result == null) return;
        if (!user.ConsumeSelectedWeaponCraftingMaterials()) { result.Destroy(); return; }
        result.AttachToOwner(user);
        let r = user.GetPersistentCharacterState(true);
        if (CaelumMainM00RonnieTrial.IsStarted(user) && level.MapName == "MAP01")
        {
            if (result is "CaelumSleepingBag" && r.MainM00CraftedBag == null) r.MainM00CraftedBag = result;
            if (result is "CaelumCanteenLarge" && r.MainM00CraftedCanteen == null) r.MainM00CraftedCanteen = result;
            CaelumOnboarding.UpdateLessons(user);
        }
        CaelumNotifications.Acquired(user, result, 1);
        user.LastCraftingAction = CaelumConstants.CRAFTING_ACTION_CREATED;
        user.OnNativeInventoryChanged();
    }
}
