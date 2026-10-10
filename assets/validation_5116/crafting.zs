class CA163Crafting : EventHandler
{
    int Passed,Failed;
    void Check(String label,bool ok)
    {if(ok)Passed++;else Failed++;Console.Printf("CA163 %s %s",ok?"PASS":"FAIL",label);}
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
        {let item=CaelumEquipmentItem(i);if(item!=null && item.EquipmentKind==CaelumConstants.EQUIPMENT_KIND_WEAPON && item.ItemType==22)return item;}
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
        u.LearnCraftingRecipe(131);u.LearnCraftingRecipe(133);
        u.ActiveCraftingStationActor=CaelumCraftingStation(ThinkerIterator.Create("CaelumWorkbenchStation").Next());
        u.OpenCraftingStation(CaelumConstants.CRAFTING_STATION_WORKBENCH);
        Check("workbench and forge network available",u.RefreshActiveCraftingStationSession(false));
        for(int size=0;size<5;size++)for(int efficiency=0;efficiency<3;efficiency++)
        {
            SelectRecipe(u,133,size,efficiency);
            double mass=u.WeaponModel.GetWeightFor(22,1,size);
            int bronze=CaelumCraftingRules.GetRequiredTierMaterialUnits(18,mass);
            int leather=CaelumCraftingRules.GetRequiredBasicMaterialUnits(18,mass);
            Check(String.Format("scaled size %d efficiency %d",size,efficiency),u.CraftingSelectionTier==1
                && Abs(u.CraftingFinalWeight-mass)<0.000001
                && u.CraftingBasicRequired==CaelumCraftingRules.GetEfficiencyAdjustedInputUnits(leather,efficiency)
                && u.CraftingTierRequired==CaelumCraftingRules.GetEfficiencyAdjustedInputUnits(bronze,efficiency)
                && u.CraftingSelectedInfrastructureAvailable);
        }
        SelectRecipe(u,133,2,2);
        Stock(u,u.CraftingBasicMaterialType,u.CraftingBasicMaterialTier,u.CraftingBasicRequired*2);
        Stock(u,u.CraftingTierMaterialType,u.CraftingTierMaterialTier,u.CraftingTierRequired*2);
        u.RefreshCraftingPreview();u.CraftSelectedPhysicalWeapon();
        Check("native crafting reserves task",u.CraftingTaskActive && u.CraftingTaskRecipeIndex==133);
        Console.Printf("CA163 CRAFT action=%d missing=%d known=%d available=%d",u.LastCraftingAction,u.CraftingMissingStationType,u.CraftingSelectedRecipeKnown,u.CraftingSelectedInfrastructureAvailable);
        if(u.CraftingTaskActive)u.CompleteCraftingTask();
        let staff=Staff(u);
        Check("native output is T1 M with correct mass and durability",staff!=null && staff.Tier==1 && staff.EquipmentSize==2 && staff.Durability==1 && Abs(staff.UnitWeight-1.018)<0.000001);
        if(staff!=null)
        {
            Check("no per-use repair or salvage task",!u.IsDurabilityTaskEquipment(staff));
            u.EquipmentSelectionKind=CaelumConstants.EQUIPMENT_KIND_WEAPON;
            u.EquipmentSelectionItemId=staff.ItemId;u.EquipmentSelectionWeaponType=22;
            u.DismantleSelectedNativeWeapon();
            Check("legacy inventory dismantle hotkey cannot salvage bolas",staff.Owner==u && !staff.bDestroyed
                && u.LastDismantledBasicUnits==0 && u.LastDismantledTierUnits==0
                && u.LastEquipmentAction==CaelumConstants.EQUIPMENT_ACTION_FAILED_DISMANTLE_UNSUPPORTED);
        }
        Console.Printf("CA163 RESULT passed=%d failed=%d",Passed,Failed);
    }
}
