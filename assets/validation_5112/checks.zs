// Isolated #158 regression on a copy of the author's checkpoint.
class CA158Checks : StaticEventHandler
{
    int Elapsed, Passed, Failed;
    void Check(String label, bool ok)
    {
        if(ok)Passed++;else Failed++;
        Console.Printf("CA158 %s %s",ok?"PASS":"FAIL",label);
    }
    void Select(CaelumPlayer u, int recipe, int size)
    {
        u.CraftingSelectionRecipe=recipe;u.CraftingSelectionSize=size;
        u.CraftingSelectionTier=1;u.CraftingEfficiencyIndex=2;
        u.ResetCraftingLayerChoices();u.RefreshCraftingPreview();
    }
    int Raw(CaelumPlayer u,int material)
    {return u.CountRawCraftingMaterial(material,1);}
    int Equipment(CaelumPlayer u,int kind,int size)
    {
        int count=0;
        for(Inventory i=u.Inv;i!=null;i=i.Inv)
        {
            let item=CaelumEquipmentItem(i);
            if(item!=null && item.EquipmentKind==kind && item.EquipmentSize==size)count++;
        }
        return count;
    }
    override void WorldTick()
    {
        Elapsed++;if(Elapsed!=20)return;
        let u=CaelumPlayer(players[0].mo);if(u==null)return;
        let r=u.GetPersistentCharacterState(false);
        Check("author checkpoint selected M, planned XS",u.CraftingSelectionSize==2 && r.MainM00StarterSize==0 && r.MainM00ArmorSize==0);
        Check("author raw stock intact",Raw(u,42)==1800 && Raw(u,55)==200 && Raw(u,62)==1260 && Raw(u,63)==140 && Raw(u,19)==600);
        // The author saved away from the bench with the menu closed.
        // Reposition only the fixture pawn at the already placed upstairs bench.
        let benches=ThinkerIterator.Create("CaelumWorkbenchStation");
        CaelumCraftingStation bench;
        while((bench=CaelumCraftingStation(benches.Next()))!=null)
            if(bench.Pos.Z>200)break;
        Check("author task inactive and existing bench found",!u.CraftingTaskActive && bench!=null);
        if(bench==null)return;
        u.SetOrigin(bench.Pos+(48,0,0),false);u.Vel=(0,0,0);
        u.ActiveCraftingStationActor=bench;
        u.OpenCraftingStation(CaelumConstants.CRAFTING_STATION_WORKBENCH);
        Check("existing station reachable",u.RefreshActiveCraftingStationSession(false));
        int issued=0;
        for(int i=0;i<CaelumConstants.MATERIAL_TYPE_COUNT;i++)issued+=r.MainM00SupplyIssued[i];
        Select(u,33,2);Check("M staff genuinely exceeds stock",!u.CraftingDirectPlanAvailable);
        Select(u,64,2);Check("M shield genuinely exceeds stock",!u.CraftingDirectPlanAvailable);
        // Teach only the two extra preview recipes, without adding materials.
        u.LearnCraftingRecipe(52);u.LearnCraftingRecipe(129);
        for(int size=0;size<5;size++)
        {
            for(int family=0;family<3;family++)
            {
                int fixedRecipe=family==0?60:family==1?52:129;
                Select(u,33,size);double staffWeight=u.CraftingFinalWeight;
                u.CraftingSelectionRecipe=fixedRecipe;u.RefreshCraftingPreview();
                bool preserved=u.CraftingSelectionSize==size;
                double fixedWeight=u.CraftingFinalWeight;
                u.CycleCraftingSize();preserved=preserved && u.CraftingSelectionSize==size && u.CraftingFinalWeight==fixedWeight;
                u.CraftingSelectionRecipe=33;u.RefreshCraftingPreview();
                Check(String.Format("size %d via fixed recipe %d",size,fixedRecipe),preserved && u.CraftingSelectionSize==size && abs(u.CraftingFinalWeight-staffWeight)<0.000001);
            }
        }
        Check("preview leaves original raw stock untouched",Raw(u,42)==1800 && Raw(u,55)==200 && Raw(u,62)==1260 && Raw(u,63)==140 && Raw(u,19)==600);
        Select(u,33,0);Check("XS staff affordable",u.CraftingDirectPlanAvailable);
        u.CraftSelectedPhysicalWeapon();Check("staff task starts",u.CraftingTaskActive && u.CraftingTaskSize==0);
        // Exercise the production transaction; skip only its waiting duration.
        u.CompleteCraftingTask();
        let staff=u.FindNativeEquipmentItemById(r.MainM00StarterWeaponId);
        Check("XS staff created from original stock",staff!=null && staff.EquipmentSize==0 && abs(staff.UnitWeight-2.0)<0.000001 && Raw(u,42)==0 && Raw(u,55)==0);
        Select(u,64,0);Check("XS shield affordable after staff",u.CraftingDirectPlanAvailable);
        int shields=Equipment(u,CaelumConstants.EQUIPMENT_KIND_SHIELD,0);
        u.CraftSelectedPhysicalWeapon();Check("shield task starts",u.CraftingTaskActive && u.CraftingTaskSize==0);
        u.CompleteCraftingTask();
        Check("XS shield created from original stock",r.MainM00ShieldCrafted && Equipment(u,CaelumConstants.EQUIPMENT_KIND_SHIELD,0)==shields+1 && Raw(u,62)==0 && Raw(u,63)==0 && Raw(u,19)==0);
        int nowIssued=0;
        for(int i=0;i<CaelumConstants.MATERIAL_TYPE_COUNT;i++)nowIssued+=r.MainM00SupplyIssued[i];
        Check("allowance issued counters unchanged",nowIssued==issued);
        // Separate fixed-size completion/save test: seed exactly its immediate inputs.
        Select(u,60,0);
        let basic=u.CreateDetachedMaterialStack(u.CraftingBasicMaterialType,u.CraftingBasicMaterialTier,u.CraftingBasicRequired);basic.AttachToOwner(u);
        let gem=u.CreateDetachedMaterialStack(u.CraftingTierMaterialType,u.CraftingTierMaterialTier,u.CraftingTierRequired);gem.AttachToOwner(u);
        u.RefreshCraftingPreview();u.CraftSelectedPhysicalWeapon();
        Check("fixed-size task starts",u.CraftingTaskActive && u.CraftingTaskRecipeIndex==60);
        // Model a legacy fixed-size task snapshot while retaining a later XL choice.
        u.CraftingTaskSize=2;u.CraftingSelectionSize=4;u.PersistCharacterState();
        Console.Printf("CA158 RESULT passed=%d failed=%d",Passed,Failed);
    }
}
