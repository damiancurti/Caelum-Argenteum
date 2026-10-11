class CA162Crafting : EventHandler
{
    int Passed,Failed;
    void Check(String label,bool ok)
    {if(ok)Passed++;else Failed++;Console.Printf("CA162 %s %s",ok?"PASS":"FAIL",label);}
    void SelectRecipe(CaelumPlayer u,int recipe,int size,int efficiency)
    {
        u.CraftingSelectionRecipe=recipe;u.CraftingSelectionTier=3;
        u.CraftingSelectionSize=size;u.CraftingEfficiencyIndex=efficiency;
        u.ResetCraftingLayerChoices();u.RefreshCraftingPreview();
    }
    void Stock(CaelumPlayer u,int type,int tier,int amount)
    {let stack=u.CreateDetachedMaterialStack(type,tier,amount);if(stack!=null)stack.AttachToOwner(u);}
    CaelumEquipmentItem Staff(CaelumPlayer u)
    {
        for(Inventory i=u.Inv;i!=null;i=i.Inv)
        {let item=CaelumEquipmentItem(i);if(item!=null && item.EquipmentKind==CaelumConstants.EQUIPMENT_KIND_WEAPON && item.ItemType==21)return item;}
        return null;
    }
    override void WorldTick()
    {
        let u=CaelumPlayer(players[0].mo);
        if(level.time==1)u.InitializeDirectMapCharacter();
        if(level.time==20)
        {
            u.GrantMagicBoxFromPalomo(false);
            Actor.Spawn("CaelumWorkbenchStation",u.Pos+(48,0,0),NO_REPLACE);
            Actor.Spawn("CaelumForgeStation",u.Pos+(0,96,0),NO_REPLACE);
        }
        if(level.time!=60)return;
        u.LearnCraftingRecipe(131);u.LearnCraftingRecipe(132);
        u.ActiveCraftingStationActor=CaelumCraftingStation(ThinkerIterator.Create("CaelumWorkbenchStation").Next());
        u.OpenCraftingStation(CaelumConstants.CRAFTING_STATION_WORKBENCH);
        Check("workbench and forge network available",u.RefreshActiveCraftingStationSession(false));
        for(int size=0;size<5;size++)for(int efficiency=0;efficiency<3;efficiency++)
        {
            SelectRecipe(u,131,size,efficiency);
            double weight=u.CraftingFinalWeight;int basic=u.CraftingBasicRequired,head=u.CraftingTierRequired;
            SelectRecipe(u,132,size,efficiency);
            Check(String.Format("recipe equality size %d efficiency %d",size,efficiency),u.CraftingSelectionTier==1 && u.CraftingFinalWeight==weight
                && u.CraftingBasicRequired==basic && u.CraftingTierRequired==head && u.CraftingSelectedInfrastructureAvailable);
        }
        Check("same forge requirement as Pickaxe",CaelumCraftingRules.GetWeaponPrimaryStation(17)==CaelumCraftingRules.GetWeaponPrimaryStation(16));
        SelectRecipe(u,132,2,2);
        Stock(u,u.CraftingBasicMaterialType,u.CraftingBasicMaterialTier,u.CraftingBasicRequired*2);
        Stock(u,u.CraftingTierMaterialType,u.CraftingTierMaterialTier,u.CraftingTierRequired*2);
        u.RefreshCraftingPreview();u.CraftSelectedPhysicalWeapon();
        Check("native crafting reserves task",u.CraftingTaskActive && u.CraftingTaskRecipeIndex==132);
        Console.Printf("CA162 CRAFT action=%d missing=%d known=%d available=%d",u.LastCraftingAction,u.CraftingMissingStationType,u.CraftingSelectedRecipeKnown,u.CraftingSelectedInfrastructureAvailable);
        if(u.CraftingTaskActive)u.CompleteCraftingTask();
        let staff=Staff(u);
        Check("native output is T1 M with correct mass and durability",staff!=null && staff.Tier==1 && staff.EquipmentSize==2 && staff.Durability==10000 && staff.UnitWeight==8);
        if(staff!=null)
        {
            int id=staff.ItemId;staff.Durability=9000;staff.UtilityStaffContactTics=19;
            u.BeginRepairSelectedEquipment(id);
            Check("known recipe enables repair",u.CraftingTaskActive && u.CraftingTaskTargetItemId==id);
            if(u.CraftingTaskActive)u.CompleteCraftingTask();
            Check("repair preserves exact identity and contact remainder",staff.ItemId==id && staff.Durability==10000 && staff.UtilityStaffContactTics==19);
            u.BeginDismantleSelectedEquipment(id);
            Check("native dismantling starts",u.CraftingTaskActive && u.CraftingTaskTargetItemId==id);
            if(u.CraftingTaskActive)u.CompleteCraftingTask();
            Check("dismantle removes only selected instance",u.FindNativeEquipmentItemById(id)==null);
        }
        Console.Printf("CA162 RESULT passed=%d failed=%d",Passed,Failed);
    }
}
