// Complemento aislado de #376; los valores artificiales nunca se incluyen en src.
class CA376Checkpoint : Inventory
{
    String TaskStamp;
    int FirstId, SecondId, FirstWear, SecondWear, KnownRecipe;
    double RawStamp;
    Default { +INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE Inventory.MaxAmount 1; }
}

class CA376Checks : StaticEventHandler
{
    int Passed, Failed;
    CaelumCraftingStation Bench;

    void Check(bool ok, String label)
    {
        if (ok) Passed++; else Failed++;
        Console.Printf("CA376 %s %s", ok ? "PASS" : "FAIL", label);
    }
    String Task(CaelumPlayer u)
    {
        String result = String.Format("%d/%d/%d/%d/%d/%d/%d/%d/%d/%d/%.9f/%.9f",
            u.CraftingTaskActive, u.CraftingTaskKind, u.CraftingTaskRecipeIndex,
            u.CraftingTaskTier, u.CraftingTaskSize, u.CraftingTaskBatchIndex,
            u.CraftingTaskEfficiencyIndex, u.CraftingTaskTargetItemId,
            u.CraftingTaskNetworkCapabilities, u.CraftingTaskReservedBoxSlots,
            u.CraftingTaskTotalSeconds, u.CraftingTaskRemainingSeconds);
        for (int i=0;i<CaelumConstants.CRAFTING_TASK_MATERIAL_SLOT_COUNT;i++)
            result = result .. String.Format(";%d/%d/%d:%d/%d/%d",
                u.CraftingTaskReservedType[i],u.CraftingTaskReservedTier[i],u.CraftingTaskReservedUnits[i],
                u.CraftingTaskOutputType[i],u.CraftingTaskOutputTier[i],u.CraftingTaskOutputUnits[i]);
        return result;
    }
    double Raw(CaelumPlayer u)
    {
        double total=0;
        for (Inventory i=u.Inv;i!=null;i=i.Inv)
        {
            let m=CaelumSpecialInventoryItem(i);
            if(m!=null && m.GetSpecialCategory()==CaelumConstants.EQUIPMENT_KIND_MATERIAL)
                total+=double(m.Amount)*(1+m.GetSpecialType()*4+m.GetSpecialTier());
        }
        return total;
    }
    double Contents(CaelumPlayer u)
    {
        double total=Raw(u);
        for(Inventory i=u.Inv;i!=null;i=i.Inv)
        {
            let e=CaelumEquipmentItem(i);
            if(e!=null)total+=e.ItemId*100000.0+e.Durability;
            else total+=i.Amount;
        }
        return total;
    }
    void Stock(CaelumPlayer u, bool rawOnly=false)
    {
        for(int type=0;type<CaelumConstants.MATERIAL_TYPE_COUNT;type++)
        {
            int tier=CaelumMaterialRules.ResolveTier(type,1);
            let m=u.FindNativeSpecialItem(CaelumConstants.EQUIPMENT_KIND_MATERIAL,type,tier);
            if(m==null)
            {
                m=u.CreateDetachedMaterialStack(type,tier,20000);
                if(m==null)continue;
                m.AttachToOwner(u);
            }
            m.Amount=rawOnly?100000:20000;m.InMagicBox=true;
            if(rawOnly && (CaelumCraftingRules.FindComponentRecipeForOutput(type)>=0
                || CaelumCraftingRules.FindProcessingRecipeForOutput(type,tier)>=0))m.Amount=0;
        }
        u.OnNativeInventoryChanged();
    }
    void Open(CaelumPlayer u)
    {
        u.CombatTimeRemaining=0;
        Bench.CollectCraftingNetwork(u,u.BeginCraftingNetworkScan());
        u.OpenCraftingNetwork(Bench);
    }
    void Setup(CaelumPlayer u)
    {
        u.bInvulnerable=true;
        u.CancelCraftingTask();
        u.DebugAttributesAt100=true;u.ApplyCharacterProfile();
        u.GrantMagicBoxFromPalomo(false);
        u.DebugSetAllCraftingRecipesKnown(true);
        Array<Name> stations;
        stations.Push('CaelumForgeStation');stations.Push('CaelumRangedWorkshopStation');
        stations.Push('CaelumArmorWorkshopStation');stations.Push('CaelumEssenceAltarStation');
        stations.Push('CaelumWorkbenchStation');stations.Push('CaelumAnvilStation');
        stations.Push('CaelumSawmillStation');stations.Push('CaelumSewingMachineStation');
        stations.Push('CaelumGlobeStation');stations.Push('CaelumJewelerBenchStation');
        stations.Push('CaelumFineToolsBenchStation');stations.Push('CaelumMasterBenchStation');
        for(int i=0;i<stations.Size();i++)
        {
            let station=CaelumCraftingStation(Actor.Spawn(stations[i],u.Pos+(48,0,0),NO_REPLACE));
            if(i==4)Bench=station;
        }
        Stock(u);Open(u);
        Check(u.RefreshActiveCraftingStationSession(false),"real station session is reachable");
        double start=Object.MSTimeF();
        for(int i=0;i<100;i++)Bench.CollectCraftingNetwork(u,u.BeginCraftingNetworkScan());
        Console.Printf("CA376 TIMING station_network_100_ms=%.6f",Object.MSTimeF()-start);
    }
    void Select(CaelumPlayer u,int recipe,int efficiency=2)
    {
        u.CraftingSelectionRecipe=recipe;u.CraftingSelectionTier=1;
        u.CraftingSelectionSize=CaelumEquipmentRules.GetDefaultSizeForCharacterTier(u.CharacterProfile.GetSizeTier());
        u.CraftingProcessingBatchIndex=0;u.CraftingEfficiencyIndex=efficiency;
        u.ResetCraftingLayerChoices();u.RefreshCraftingPreview();
    }
    int Recipe(int kind)
    {
        for(int i=0;i<CaelumConstants.CRAFTING_NETWORK_PLAYABLE_RECIPE_COUNT;i++)
            if(CaelumCraftingRules.GetUnifiedRecipeKind(i)==kind)return i;
        return -1;
    }
    CaelumEquipmentItem Weapon(CaelumPlayer u,int wear)
    {
        let e=CaelumEquipmentItem(Actor.Spawn('CaelumWeaponPickup',u.Pos,NO_REPLACE));
        e.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_WEAPON;
        e.ItemType=CaelumConstants.WEAPON_TYPE_LONGBOW;e.Tier=1;
        e.EquipmentSize=CaelumEquipmentRules.GetDefaultSizeForCharacterTier(u.CharacterProfile.GetSizeTier());
        e.Durability=wear;e.WeaponDurabilityRevision=CaelumAttackRules.DURABILITY_REVISION;
        e.UnitWeight=u.WeaponModel.GetWeightFor(e.ItemType,1,e.EquipmentSize);
        e.PickupDataInitialized=true;e.AcquisitionResolved=true;
        e.Amount=1;e.SizePolicy=CaelumEquipmentRules.FIXED_SIZE;
        e.AttachToOwner(u);u.EnsureEquipmentItemId(e);
        return e;
    }
    void Suite(CaelumPlayer u)
    {
        Setup(u);
        for(int kind=0;kind<=CaelumConstants.CRAFTING_RECIPE_KIND_AMMUNITION;kind++)
        {
            Stock(u);Open(u);Select(u,Recipe(kind));
            double raw=Raw(u);
            u.RefreshCraftingPreview();u.RefreshCraftingPreview();
            Check(Raw(u)==raw && u.GetCraftingTaskReservedUnitTotal()==0,"preview reserves and consumes nothing");
            u.BeginSelectedCraftingTask();
            Check(u.CraftingTaskActive,String.Format("recipe family %d starts",kind));
            Console.Printf("CA376 PLAN family=%d recipe=%d reserved=%d seconds=%.9f steps=%d",
                kind,u.CraftingTaskRecipeIndex,u.GetCraftingTaskReservedUnitTotal(),
                u.CraftingTaskTotalSeconds,u.CraftingDirectPlanStepCount);
            String stamp=Task(u);
            u.CycleCraftingRecipe(1);u.CycleCraftingTier();u.CycleCraftingSize();
            u.CycleCraftingEfficiency();u.CycleCraftingBatch();u.CycleCraftingRecipeFilter();
            u.DebugSetAllCraftingRecipesKnown(false);u.RefreshCraftingPreview();
            Check(Task(u)==stamp && Raw(u)==raw,"selection and knowledge cannot rewrite active task");
            u.DebugSetAllCraftingRecipesKnown(true);
            u.CompleteCraftingTask();
            Check(!u.CraftingTaskActive && (u.LastCraftingAction==CaelumConstants.CRAFTING_ACTION_CREATED
                || u.LastCraftingAction==CaelumConstants.CRAFTING_ACTION_PROCESSED),"completion succeeds once");
            double after=Contents(u);u.CompleteCraftingTask();
            Check(Contents(u)==after,"repeated completion cannot consume or grant");
        }
        for(int efficiency=0;efficiency<3;efficiency++)
        {
            Stock(u,true);Open(u);Select(u,33,efficiency);
            u.BeginSelectedCraftingTask();
            Check(u.CraftingTaskActive && u.CraftingTaskUsesDirectPlan && u.CraftingDirectPlanStepCount>0,
                String.Format("recursive plan efficiency %d",efficiency));
            Console.Printf("CA376 LAYERS efficiency=%d steps=%d reserved=%d seconds=%.9f",
                efficiency,u.CraftingDirectPlanStepCount,u.GetCraftingTaskReservedUnitTotal(),u.CraftingTaskTotalSeconds);
            double raw=Raw(u);String stamp=Task(u);
            u.BeginSelectedCraftingTask();
            Check(Task(u)==stamp && Raw(u)==raw,"repeated begin does not reserve twice");
            u.CloseCraftingStationSession();u.UpdateCraftingTask();
            Check(Task(u)==stamp && !u.CraftingTaskProgressing,"closed session pauses exact task");
            Open(u);u.UpdateCraftingTask();
            Check(u.CraftingTaskProgressing && u.CraftingTaskRemainingSeconds<u.CraftingTaskTotalSeconds,"reopened session resumes");
            stamp=Task(u);u.CombatTimeRemaining=1;u.UpdateCraftingTask();
            Check(Task(u)==stamp && !u.CraftingTaskProgressing,"combat pauses without releasing materials");
            u.CombatTimeRemaining=0;
            Vector3 old=Bench.Pos;Bench.SetOrigin(old+(4096,0,0),false);u.UpdateCraftingTask();
            Check(Task(u)==stamp && !u.CraftingMenuOpen,"leaving station pauses exact task");
            Bench.SetOrigin(old,false);Open(u);
            u.health=0;u.UpdateCraftingTask();
            Check(Task(u)==stamp && !u.CraftingMenuOpen,"death closes session without consuming");
            u.health=100;Open(u);u.CancelCraftingTask();
            Check(!u.CraftingTaskActive && u.GetCraftingTaskReservedUnitTotal()==0 && Raw(u)==raw,
                "explicit cancel frees reservation without consumption");
        }
        for(int utility=0;utility<2;utility++)
        {
            Stock(u);Open(u);
            int recipe=utility==0?CaelumConstants.CRAFTING_SLEEPING_BAG_RECIPE:CaelumConstants.CRAFTING_LARGE_CANTEEN_RECIPE;
            Select(u,recipe);u.BeginSelectedCraftingTask();
            Check(u.CraftingTaskActive,"utility uses ordinary task");
            u.CompleteCraftingTask();
            Check(u.FindInventory(CaelumUtilityCrafting.ItemClass(recipe))!=null,"utility creates native item");
            double before=Contents(u);u.BeginSelectedCraftingTask();
            Check(!u.CraftingTaskActive && Contents(u)==before,"duplicate utility rejected");
        }
        Stock(u);Open(u);
        let a=Weapon(u,10);let b=Weapon(u,7);
        u.BeginRepairSelectedEquipment(b.ItemId);
        Check(u.CraftingTaskActive && u.CraftingTaskTargetItemId==b.ItemId,"repair reserves exact duplicate instance");
        Check(u.IsEquipmentItemCraftingLocked(b.ItemId) && !u.IsEquipmentItemCraftingLocked(a.ItemId),"only exact target is locked");
        u.CompleteCraftingTask();
        Check(b.Durability>7 && a.Durability==10,"repair changes only chosen worn copy");
        double after=Contents(u);u.CompleteCraftingTask();
        Check(Contents(u)==after,"repair repeated completion inert");
        int id=b.ItemId;u.BeginDismantleSelectedEquipment(id);
        Check(u.CraftingTaskActive && u.CraftingTaskTargetItemId==id,"dismantle selects exact target");
        u.CompleteCraftingTask();
        Check(u.FindNativeEquipmentItemById(id)==null && a.Owner==u,"dismantle removes only exact target");
        after=Contents(u);u.CompleteCraftingTask();
        Check(Contents(u)==after,"dismantle repeated completion inert");
        Stock(u);Open(u);Select(u,33);
        u.CloseCraftingStationSession();after=Contents(u);u.BeginSelectedCraftingTask();
        Check(!u.CraftingTaskActive && Contents(u)==after,"missing session rejects start without mutation");
        Open(u);u.DebugSetAllCraftingRecipesKnown(false);u.BeginSelectedCraftingTask();
        Check(!u.CraftingTaskActive && Contents(u)==after,"unknown recipe rejects without mutation");
        u.DebugSetAllCraftingRecipesKnown(true);Select(u,33);
        u.BeginSelectedCraftingTask();
        Check(u.CraftingTaskActive,"capacity rejection fixture starts");
        int capacity=u.DerivedStats.MagicBoxCapacity;
        u.DerivedStats.MagicBoxCapacity=0;after=Contents(u);u.CompleteCraftingTask();
        Check(Contents(u)==after,"final Box capacity rejection preserves inputs and output");
        u.DerivedStats.MagicBoxCapacity=capacity;
        Stock(u);Open(u);Select(u,33);u.BeginSelectedCraftingTask();
        Check(u.CraftingTaskActive,"reserved-material rejection fixture starts");
        let reserved=u.FindNativeSpecialItem(CaelumConstants.EQUIPMENT_KIND_MATERIAL,
            u.CraftingTaskReservedType[0],u.CraftingTaskReservedTier[0]);
        u.ApplyFormalInventorySelection(reserved);
        after=Contents(u);String stamp=Task(u);
        u.DropSelectedNativeInventoryItem();
        Check(reserved!=null && reserved.Owner==u && Contents(u)==after && Task(u)==stamp,
            "reserved material drop is rejected without mutation");
        double carry=u.DerivedStats.CarryCapacity;u.DerivedStats.CarryCapacity=0;
        after=Contents(u);u.CompleteCraftingTask();
        Check(Contents(u)==after,"final overweight rejection preserves inputs and output");
        u.DerivedStats.CarryCapacity=carry;
        Stock(u);Open(u);Select(u,33);
        for(Inventory i=u.Inv;i!=null;i=i.Inv)
        {
            let material=CaelumMaterialPickup(i);
            if(material!=null)material.Amount=0;
        }
        u.OnNativeInventoryChanged();after=Contents(u);u.BeginSelectedCraftingTask();
        Check(!u.CraftingTaskActive && Contents(u)==after,"missing materials rejects without consumption");
        Console.Printf("CA376 RESULT passed=%d failed=%d",Passed,Failed);
    }
    void PrepareSave(CaelumPlayer u)
    {
        Setup(u);
        let a=Weapon(u,10);let b=Weapon(u,7);
        u.BeginRepairSelectedEquipment(b.ItemId);
        Check(u.CraftingTaskActive && u.CraftingTaskTargetItemId==b.ItemId,"save contains live repair and exact duplicate");
        u.UpdateCraftingTask();u.CloseCraftingStationSession();
        let marker=CA376Checkpoint(Actor.Spawn('CA376Checkpoint',u.Pos,NO_REPLACE));
        marker.AttachToOwner(u);
        marker.FirstId=a.ItemId;marker.SecondId=b.ItemId;
        marker.FirstWear=a.Durability;marker.SecondWear=b.Durability;
        marker.KnownRecipe=33;marker.RawStamp=Raw(u);marker.TaskStamp=Task(u);
        u.PersistCharacterState();Verify(u);
    }
    void Verify(CaelumPlayer u)
    {
        let m=CA376Checkpoint(u.FindInventory('CA376Checkpoint'));
        Check(m!=null,"native checkpoint restored");if(m==null)return;
        let a=u.FindNativeEquipmentItemById(m.FirstId);let b=u.FindNativeEquipmentItemById(m.SecondId);
        Check(a!=null && b!=null && a!=b,"both exact item identities survive");
        Check(a!=null && b!=null && a.Durability==m.FirstWear && b.Durability==m.SecondWear,"distinct wear survives");
        Check(Task(u)==m.TaskStamp,"remaining time, target, network, reservations and outputs survive");
        Check(Raw(u)==m.RawStamp,"native material quantities survive");
        Check(u.IsCraftingRecipeKnown(m.KnownRecipe),"learned recipe survives");
        Check(!u.CraftingMenuOpen && !u.CraftingTaskProgressing,"session closed and task paused");
        Console.Printf("CA376 PERSIST passed=%d failed=%d map=%s",Passed,Failed,level.MapName);
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[0].mo);if(u==null)return;
        if(e.Name=="ca376_suite")Suite(u);
        if(e.Name=="ca376_save")PrepareSave(u);
        if(e.Name=="ca376_verify")Verify(u);
    }
}
