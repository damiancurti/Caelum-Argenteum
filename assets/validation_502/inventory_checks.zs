// Datos artificiales de prueba; el complemento no se distribuye en src.
class CA118Marker : Inventory
{
    int FirstItem, SecondItem, NextItem, MaterialUnits, Visits;
    double Money;
    Default { +INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE Inventory.MaxAmount 1; }
}

class CA118Checks : StaticEventHandler
{
    int Checks, Failures;
    void Check(bool ok, String label)
    {
        Checks++;
        if (!ok) { Failures++; Console.Printf("CA118 FAIL %s",label); }
    }
    CaelumEquipmentItem Weapon(CaelumPlayer u, int wear, int type = -1)
    {
        let item=CaelumEquipmentItem(Actor.Spawn("CaelumWeaponPickup",u.Pos));
        item.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_WEAPON;
        item.ItemType=type<0?CaelumConstants.WEAPON_TYPE_STANDARD_BOW:type;
        item.Tier=1; item.EquipmentSize=CaelumEquipmentRules.GetDefaultSizeForCharacterTier(u.CharacterProfile.GetSizeTier());
        item.Durability=wear; item.WeaponDurabilityRevision=CaelumAttackRules.DURABILITY_REVISION;
        item.UnitWeight=u.WeaponModel.GetWeightFor(item.ItemType,1,item.EquipmentSize);
        item.PickupDataInitialized=true; item.AcquisitionResolved=true;
        item.Amount=1; item.SizePolicy=CaelumEquipmentRules.FIXED_SIZE;
        item.AttachToOwner(u); u.EnsureEquipmentItemId(item);
        return item;
    }
    void Select(CaelumPlayer u, Inventory item)
    { u.ApplyFormalInventorySelection(item); u.RefreshEquipmentSelectionPreview(); }
    void Material(CaelumPlayer u, int type, int amount)
    {
        let old=u.FindNativeSpecialItem(CaelumConstants.EQUIPMENT_KIND_MATERIAL,type,1);
        if(old!=null) {old.Amount=amount;return;}
        let item=u.CreateDetachedMaterialStack(type,1,amount);
        u.AddRecoveredMaterial(null,item,amount,false);
    }
    int EquipmentCount(CaelumPlayer u)
    {
        int count=0;
        for(Inventory c=u.Inv;c!=null;c=c.Inv)if(CaelumEquipmentItem(c)!=null)count++;
        return count;
    }
    void Dump(CaelumPlayer u, String label)
    {
        let record=u.GetPersistentCharacterState(false);
        Console.Printf("CA118 VALUE %s equipment=%d entries=%d box=%d slots=%d raw=%.9f weight=%.9f money=%.0f next=%d task=%d target=%d reserved=%d reward=%d",
            label,EquipmentCount(u),u.CountFormalInventoryEntries(),u.MagicBoxOwned,u.CountNativeMagicBoxSlots(),
            u.HUDMagicBoxRawContentWeight,u.DerivedStats.CarriedWeight,u.GetOwnedMoneyCopperValue(),record.NextEquipmentItemId,
            u.CraftingTaskActive,u.CraftingTaskTargetItemId,u.GetCraftingTaskReservedUnitTotal(),record.IsPrisonerRewardClaimed(0));
    }
    void Run(CaelumPlayer u)
    {
        u.bInvulnerable=true;
        u.InitializeDirectMapCharacter(); u.ClearCraftingTaskData();
        let record=u.GetPersistentCharacterState(true);
        // El perfil directo carece de piezas; no se toca el contenido del mapa.
        Check(EquipmentCount(u)==0,"empty direct-map loadout");
        let a=Weapon(u,10); let b=Weapon(u,7);
        Check(a.ItemId>0 && b.ItemId>a.ItemId,"same-catalogue pieces have distinct IDs");
        a.Equipped=true; Check(u.ActivateExactEquippedWeapon(a),"first exact selector");
        b.Equipped=true; Check(u.ActivateExactEquippedWeapon(b),"second exact selector");
        Check(u.ActiveWeaponItemId==b.ItemId && u.WeaponModel.Durability==7,"second exact wear loaded");
        u.WeaponModel.Durability=6; u.SyncActiveModelsToNativeInventory();
        Check(a.Durability==10 && b.Durability==6,"model wear writes only selected ID");
        b.Equipped=false; u.ActivateExactEquippedWeapon(a);
        Check(u.WeaponModel.Durability==10,"switch does not repair duplicate");
        Select(u,b); u.EquipSelectedNativeEquipment();
        Check(b.Equipped,"equipment request from projection");
        u.UnequipSelectedNativeEquipment(); Check(!b.Equipped,"unequip exact item");
        u.ActivateExactEquippedWeapon(a);
        Check(u.GrantMagicBoxFromPalomo(false),"Box grant");
        int boxId=record.MagicBoxItemId, next=record.NextEquipmentItemId;
        Check(!u.GrantMagicBoxFromPalomo(false),"Box grant retry rejected");
        Check(CaelumMagicBox.EnsureOwned(u).ItemId==boxId && record.NextEquipmentItemId==next,"Box identity stable");
        Select(u,b); u.ToggleSelectedMagicBoxNative();
        Check(b.InMagicBox && !b.Equipped && b.Durability==6,"store exact worn piece");
        u.ToggleSelectedMagicBoxNative(); Check(!b.InMagicBox && b.Durability==6,"retrieve exact worn piece");
        Check(CaelumTarotDeckRules.Grant(u,false),"physical deck grant");
        let deck=CaelumTarotDeckRules.Owned(u); Check(deck!=null,"physical deck owned");
        int entries=u.CountFormalInventoryEntries();
        Check(CaelumTarotDeckRules.Grant(u,false) && u.CountFormalInventoryEntries()==entries,"deck retry no duplicate");
        Check(deck.CreateTossable(1)==null,"physical deck cannot be dropped");
        Select(u,deck); u.DropSelectedNativeInventoryItem();
        Check(CaelumTarotDeckRules.Owned(u)==deck,"inventory drop keeps deck");
        record.TarotOwned[CaelumConstants.TAROT_THE_FOOL]=true;
        bool stored=deck.InMagicBox;
        u.ToggleSelectedMagicBoxNative();
        Check(deck.InMagicBox!=stored && record.TarotOwned[CaelumConstants.TAROT_THE_FOOL],"deck storage preserves essences");
        u.ToggleSelectedMagicBoxNative();
        u.RefreshCarriedInventorySummary();
        double capacity=u.DerivedStats.CarryCapacity;
        u.DerivedStats.CarryCapacity=0;
        let incoming=CaelumEquipmentItem(Actor.Spawn("CaelumWeaponPickup",u.Pos));
        incoming.UnitWeight=capacity+100; int beforeId=record.NextEquipmentItemId;
        Check(!u.PrepareNativeEquipmentPickup(incoming) && incoming.ItemId==0 && record.NextEquipmentItemId==beforeId,"capacity failure allocates no identity");
        incoming.Destroy(); u.DerivedStats.CarryCapacity=capacity;
        u.RefreshCarriedInventorySummary();
        int slots=u.CountNativeMagicBoxSlots();
        u.CraftingTaskReservedBoxSlots=u.DerivedStats.MagicBoxCapacity-slots;
        Check(!u.HasNativeMagicBoxSlotAvailable(),"reserved output slots block incoming Box item");
        u.CraftingTaskReservedBoxSlots=0;
        // Transferencia nativa: conserva ID/wear al soltar y recoger la copia.
        Select(u,b); int droppedId=b.ItemId;
        u.DropSelectedNativeInventoryItem();
        Check(u.FindNativeEquipmentItemById(droppedId)==null,"drop removes owned instance");
        let iterator=ThinkerIterator.Create("CaelumEquipmentItem"); CaelumEquipmentItem dropped;
        while((dropped=CaelumEquipmentItem(iterator.Next()))!=null)
            if(dropped.Owner==null && dropped.ItemId==droppedId)break;
        Check(dropped!=null && dropped.Durability==6,"world copy preserves worn identity");
        if(dropped!=null)
        {
            Actor receiver=u; Check(dropped.CallTryPickup(receiver),"native repickup succeeds");
            b=u.FindNativeEquipmentItemById(droppedId);
            Check(b!=null && b.Durability==6,"native pickup returns exact identity");
            b.Equipped=false; u.ActivateExactEquippedWeapon(a);
        }
        // La reserva se valida completa antes de consumir el primer material.
        Material(u,CaelumConstants.MATERIAL_WOOD,8);
        Material(u,CaelumConstants.MATERIAL_IRON_INGOT,1);
        u.AddCraftingTaskReservation(CaelumConstants.MATERIAL_WOOD,1,2);
        u.AddCraftingTaskReservation(CaelumConstants.MATERIAL_IRON_INGOT,1,2);
        u.CraftingTaskActive=true; u.CraftingTaskKind=CaelumConstants.CRAFTING_TASK_REPAIR;
        u.CraftingTaskTargetItemId=b.ItemId;
        Check(u.CountCraftingMaterial(CaelumConstants.MATERIAL_WOOD,1)==6,"available material excludes reservation");
        Select(u,b); u.EquipSelectedNativeEquipment(); Check(!b.Equipped,"reserved target cannot equip");
        u.DropSelectedNativeInventoryItem(); Check(b.Owner==u,"reserved target cannot drop");
        u.ToggleSelectedMagicBoxNative(); Check(!b.InMagicBox,"reserved target cannot move");
        u.CompleteCraftingTask();
        Check(b.Durability==6 && u.CountRawCraftingMaterial(CaelumConstants.MATERIAL_WOOD,1)==8,"failed repair does not consume or heal");
        u.AddCraftingTaskReservation(CaelumConstants.MATERIAL_WOOD,1,2);
        u.CraftingTaskActive=true; u.CraftingTaskKind=CaelumConstants.CRAFTING_TASK_REPAIR;
        u.CraftingTaskTargetItemId=b.ItemId;
        u.CompleteCraftingTask();
        int repaired=u.GetEquipmentTaskMaximumDurability(b);
        Check(b.Durability==repaired && u.CountRawCraftingMaterial(CaelumConstants.MATERIAL_WOOD,1)==6,"repair consumes reserved stock once");
        u.CompleteCraftingTask();
        Check(b.Durability==repaired && u.CountRawCraftingMaterial(CaelumConstants.MATERIAL_WOOD,1)==6,"completed repair retry is inert");
        // Desmontaje: el resultado pertenece al mismo inventario y no se repite.
        let victim=Weapon(u,5); int victimId=victim.ItemId;
        u.AddCraftingTaskOutput(CaelumConstants.MATERIAL_WOOD,1,1);
        u.CraftingTaskActive=true; u.CraftingTaskKind=CaelumConstants.CRAFTING_TASK_DISMANTLE;
        u.CraftingTaskTargetItemId=victimId;
        u.CompleteCraftingTask();
        Check(u.FindNativeEquipmentItemById(victimId)==null && u.CountRawCraftingMaterial(CaelumConstants.MATERIAL_WOOD,1)==7,"dismantle removes target and credits output");
        u.CompleteCraftingTask();
        Check(u.CountRawCraftingMaterial(CaelumConstants.MATERIAL_WOOD,1)==7,"dismantle retry does not duplicate");
        // Planes monetarios comparten el mismo commit que comercio/recompensas.
        Check(u.BuildPalomoCurrencyCreditPlan(1000),"credit plan");
        Check(u.PalomoTransactionCapacityFits(u.GetPalomoCurrencyPlanPersonalWeightDelta(),u.GetPalomoCurrencyPlanBoxRawWeightDelta(),u.GetPalomoCurrencyPlanBoxSlotDelta()),"credit capacity");
        Check(u.ApplyPalomoCurrencyPlan() && u.GetOwnedMoneyCopperValue()==1000,"currency credit");
        Check(!u.BuildPalomoCurrencyPaymentPlan(1001),"insufficient funds plan rejected");
        Check(u.GetOwnedMoneyCopperValue()==1000,"failed payment keeps money");
        Check(u.BuildPalomoCurrencyPaymentPlan(101) && u.ApplyPalomoCurrencyPlan(),"payment with change");
        Check(u.GetOwnedMoneyCopperValue()==899,"payment exact copper value");
        record.SetPrisonerRescueState(0,CaelumConstants.PRISONER_STATE_EXTRACTED);
        u.RefreshCarriedInventorySummary(); capacity=u.DerivedStats.CarryCapacity; u.DerivedStats.CarryCapacity=0;
        Check(!u.ClaimPrisonerPortReward(0,0) && !record.IsPrisonerRewardClaimed(0),"reward capacity failure leaves unclaimed");
        u.DerivedStats.CarryCapacity=capacity;
        Check(u.ClaimPrisonerPortReward(0,0),"reward succeeds after capacity retry");
        double money=u.GetOwnedMoneyCopperValue(); int reputation=record.FactionReputation[0];
        Check(!u.ClaimPrisonerPortReward(0,0) && u.GetOwnedMoneyCopperValue()==money && record.FactionReputation[0]==reputation,"reward exactly once");
        // No reconstrucción desde arrays legados una vez migrado Actor.Inv.
        next=record.NextEquipmentItemId;
        u.MigrateLegacyEquipmentToNativeInventory(record); u.MigrateLegacyEquipmentToNativeInventory(record);
        Check(EquipmentCount(u)==2 && record.NextEquipmentItemId==next,"legacy migration gate idempotent");
        double start=MSTimeF();
        for(int i=0;i<200;i++) {u.RefreshCarriedInventorySummary();u.RefreshFormalInventorySnapshot();}
        Console.Printf("CA118 TIMING inventory-200 ms=%.6f",MSTimeF()-start);
        Check(b.Durability==repaired && record.NextEquipmentItemId==next && u.GetOwnedMoneyCopperValue()==money,"projection refresh changes no owned state");
        b.Durability=7; b.Equipped=false; Select(u,b); u.ToggleSelectedMagicBoxNative();
        u.AddCraftingTaskReservation(CaelumConstants.MATERIAL_WOOD,1,2);
        u.CraftingTaskActive=true; u.CraftingTaskKind=CaelumConstants.CRAFTING_TASK_REPAIR;
        u.CraftingTaskTargetItemId=b.ItemId; u.CraftingTaskRemainingSeconds=1000;
        let marker=CA118Marker(Actor.Spawn("CA118Marker",u.Pos)); marker.AttachToOwner(u);
        marker.FirstItem=a.ItemId; marker.SecondItem=b.ItemId; marker.NextItem=record.NextEquipmentItemId;
        marker.Money=money; marker.MaterialUnits=7;
        u.PersistCharacterState(); u.RefreshCarriedInventorySummary(); Dump(u,"seed");
        Console.Printf("CA118 DONE checks=%d failures=%d",Checks,Failures);
    }
    void Persistence(CaelumPlayer u,String label)
    {
        let marker=CA118Marker(u.FindInventory("CA118Marker")); if(marker==null)return;
        let record=u.GetPersistentCharacterState(false);
        let a=u.FindNativeEquipmentItemById(marker.FirstItem), b=u.FindNativeEquipmentItemById(marker.SecondItem);
        Check(a!=null && b!=null && a!=b && b.Owner==u,"exact owned instances survive");
        Check(b.Durability==7 && b.InMagicBox && !b.Equipped,"worn stored target survives without free repair");
        Check(EquipmentCount(u)==2,"no duplicated equipment on load/travel");
        Check(record.NextEquipmentItemId==marker.NextItem,"stable next item ID");
        Check(u.CraftingTaskActive && u.CraftingTaskTargetItemId==b.ItemId && u.GetCraftingTaskReservedUnitTotal()==2,"reservation and target survive");
        Check(u.CountRawCraftingMaterial(CaelumConstants.MATERIAL_WOOD,1)==marker.MaterialUnits && u.CountCraftingMaterial(CaelumConstants.MATERIAL_WOOD,1)==marker.MaterialUnits-2,"reserved materials survive");
        Check(u.GetOwnedMoneyCopperValue()==marker.Money && record.IsPrisonerRewardClaimed(0),"reward money and claim survive");
        Check(!u.ClaimPrisonerPortReward(0,0) && u.GetOwnedMoneyCopperValue()==marker.Money,"reward retry after load/travel inert");
        Check(CaelumTarotDeckRules.Owned(u)!=null && record.TarotOwned[CaelumConstants.TAROT_THE_FOOL],"physical deck and essences survive");
        Check(CaelumMagicBox.EnsureOwned(u).ItemId==record.MagicBoxItemId,"owned Box survives");
        Dump(u,label); Console.Printf("CA118 PERSIST %s checks=%d failures=%d",label,Checks,Failures);
    }
    void Ownership(CaelumPlayer u)
    {
        let owner=Actor.Spawn("Actor",u.Pos);
        let foreign=CaelumEquipmentItem(Actor.Spawn("CaelumWeaponPickup",u.Pos));
        int id=CA118Marker(u.FindInventory("CA118Marker")).FirstItem;
        foreign.ItemId=id; foreign.Durability=3; foreign.AttachToOwner(owner); foreign.Equipped=true;
        int active=u.ActiveWeaponItemId, next=u.GetPersistentCharacterState(false).NextEquipmentItemId;
        Check(u.EnsureEquipmentItemId(foreign)==0 && foreign.ItemId==id,"foreign ID allocation rejected");
        Check(!u.ActivateExactEquippedWeapon(foreign) && u.ActiveWeaponItemId==active,"foreign activation rejected");
        Check(!u.PrepareNativeEquipmentPickup(foreign) && foreign.Equipped,"foreign pickup preflight has no mutation");
        int selection=u.EquipmentSelectionItemId;
        u.ApplyFormalInventorySelection(foreign); Check(u.EquipmentSelectionItemId==selection,"foreign UI selection rejected");
        Check(foreign.Owner==owner && foreign.Durability==3 && u.GetPersistentCharacterState(false).NextEquipmentItemId==next,"foreign owner and requester unchanged");
        let material=u.CreateDetachedMaterialStack(CaelumConstants.MATERIAL_WOOD,1,1);
        material.AttachToOwner(owner);
        Check(!u.PrepareNativeSpecialStackPickup(material,1) && !material.InMagicBox,"foreign material stack rejected");
        u.AddRecoveredMaterial(material,null,1,true);
        Check(material.Amount==1 && !material.InMagicBox,"foreign output merge rejected");
        material.Destroy(); foreign.Destroy(); owner.Destroy();
        Console.Printf("CA118 OWNERSHIP checks=%d failures=%d",Checks,Failures);
    }
    void Transactions(CaelumPlayer u)
    {
        u.CancelCraftingTask(); u.DebugAttributesAt100=true; u.ApplyCharacterProfile();
        u.DebugSetAllCraftingRecipesKnown(true);
        Array<Name> stations;
        stations.Push('CaelumForgeStation'); stations.Push('CaelumRangedWorkshopStation'); stations.Push('CaelumArmorWorkshopStation');
        stations.Push('CaelumEssenceAltarStation'); stations.Push('CaelumWorkbenchStation'); stations.Push('CaelumAnvilStation'); stations.Push('CaelumSawmillStation');
        stations.Push('CaelumSewingMachineStation'); stations.Push('CaelumGlobeStation'); stations.Push('CaelumJewelerBenchStation'); stations.Push('CaelumFineToolsBenchStation'); stations.Push('CaelumMasterBenchStation');
        CaelumCraftingStation bench;
        for(int i=0;i<stations.Size();i++)
        {
            let station=CaelumCraftingStation(Actor.Spawn(stations[i],u.Pos+(48,0,0),NO_REPLACE));
            if(i==4)bench=station;
        }
        for(int type=0;type<CaelumConstants.MATERIAL_TYPE_COUNT;type++)
        {
            // Las unidades de material son gramos; stock artificial suficiente.
            Material(u,type,20000);
            let material=u.FindNativeSpecialItem(CaelumConstants.EQUIPMENT_KIND_MATERIAL,type,CaelumMaterialRules.ResolveTier(type,1));
            if(material!=null)material.InMagicBox=true;
        }
        u.OnNativeInventoryChanged(); bench.CollectCraftingNetwork(u,u.BeginCraftingNetworkScan()); u.OpenCraftingNetwork(bench);
        for(int kind=0;kind<=CaelumConstants.CRAFTING_RECIPE_KIND_AMMUNITION;kind++)
        {
            int recipe=-1;
            for(int i=0;i<CaelumConstants.CRAFTING_NETWORK_PLAYABLE_RECIPE_COUNT;i++)
                if(CaelumCraftingRules.GetUnifiedRecipeKind(i)==kind){recipe=i;break;}
            Check(recipe>=0,"catalogue family exists"); if(recipe<0)continue;
            u.CraftingSelectionRecipe=recipe; u.CraftingSelectionTier=1;
            u.CraftingSelectionSize=CaelumEquipmentRules.GetDefaultSizeForCharacterTier(u.CharacterProfile.GetSizeTier());
            u.RefreshCraftingPreview();
            u.BeginSelectedCraftingTask();
            Check(u.CraftingTaskActive,"catalogue task starts with real station and materials");
            if(u.CraftingTaskActive)u.CompleteCraftingTask();
            Check(u.LastCraftingAction==CaelumConstants.CRAFTING_ACTION_CREATED || u.LastCraftingAction==CaelumConstants.CRAFTING_ACTION_PROCESSED,"catalogue task commits output");
            Console.Printf("CA118 CRAFT kind=%d recipe=%d action=%d items=%d",kind,recipe,u.LastCraftingAction,EquipmentCount(u));
        }
        u.CloseCraftingStationSession();
        let merchant=Actor.Spawn("Actor",u.Pos+(32,0,0),NO_REPLACE);
        merchant.health=100;
        u.OpenPalomoMerchant(merchant);
        u.RefreshPalomoMerchantSnapshot();
        int product=u.PalomoMerchantSelection, quantity=u.PalomoMerchantSelectedQuantity;
        int stock=u.GetPersistentCharacterState(false).PalomoMerchantStock[product];
        int owned=u.CountPalomoMerchantProduct(product,true),price=u.PalomoMerchantSelectedLotPrice;
        double money=u.GetOwnedMoneyCopperValue();
        u.ExecutePalomoMerchantTransaction();
        Check(u.LastPalomoMerchantAction==CaelumConstants.PALOMO_MERCHANT_ACTION_BOUGHT,"live merchant buy commits");
        Check(u.CountPalomoMerchantProduct(product,true)==owned+quantity && u.GetOwnedMoneyCopperValue()==money-price,"buy goods and payment agree");
        Check(u.GetPersistentCharacterState(false).PalomoMerchantStock[product]==stock-quantity,"buy debits merchant stock");
        u.PalomoMerchantMode=CaelumConstants.PALOMO_MERCHANT_MODE_SELL; u.RefreshPalomoMerchantSnapshot();
        product=u.PalomoMerchantSelection; quantity=u.PalomoMerchantSelectedQuantity;
        owned=u.CountPalomoMerchantProduct(product,true); price=u.PalomoMerchantSelectedLotPrice; money=u.GetOwnedMoneyCopperValue();
        u.ExecutePalomoMerchantTransaction();
        Check(u.LastPalomoMerchantAction==CaelumConstants.PALOMO_MERCHANT_ACTION_SOLD,"live merchant sell commits");
        Check(u.CountPalomoMerchantProduct(product,true)==owned-quantity && u.GetOwnedMoneyCopperValue()==money+price,"sell goods and credit agree");
        u.ClosePalomoMerchant(); merchant.Destroy();
        Console.Printf("CA118 TRANSACTIONS checks=%d failures=%d",Checks,Failures);
    }
    void Pickups(CaelumPlayer u)
    {
        Array<Name> classes;
        classes.Push('CaelumCarbineAmmo'); classes.Push('CaelumFoodRation'); classes.Push('CaelumMaterialPickup');
        for(int kind=0;kind<classes.Size();kind++)
        {
            Inventory owned=kind==2 ? Inventory(u.FindNativeSpecialItem(CaelumConstants.EQUIPMENT_KIND_MATERIAL,CaelumConstants.MATERIAL_WOOD,1)) : u.FindInventory(classes[kind]);
            int initial=owned==null?0:owned.Amount;
            for(int attempt=0;attempt<3;attempt++)
            {
                let incoming=Inventory(Actor.Spawn(classes[kind],u.Pos,NO_REPLACE));
                incoming.Amount=3;
                if(kind==2){incoming.args[0]=CaelumConstants.MATERIAL_WOOD;incoming.args[1]=1;}
                double capacity=u.DerivedStats.CarryCapacity;
                if(attempt==2)u.DerivedStats.CarryCapacity=0;
                Actor receiver=u;
                bool picked=incoming.CallTryPickup(receiver);
                u.DerivedStats.CarryCapacity=capacity;
                Check(picked==(attempt<2),"native stack pickup success/capacity rejection");
                owned=kind==2 ? Inventory(u.FindNativeSpecialItem(CaelumConstants.EQUIPMENT_KIND_MATERIAL,CaelumConstants.MATERIAL_WOOD,1)) : u.FindInventory(classes[kind]);
                Check(owned!=null && owned.Owner==u && owned.Amount==initial+3*Min(attempt+1,2),"native stack has exact amount and owner");
                if(!picked && incoming!=null)incoming.Destroy();
            }
            Console.Printf("CA118 PICKUP kind=%d amount=%d",kind,owned.Amount);
        }
        Console.Printf("CA118 PICKUPS checks=%d failures=%d",Checks,Failures);
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="ca118_ownership")Ownership(CaelumPlayer(players[0].mo));
        if(e.Name=="ca118_transactions")Transactions(CaelumPlayer(players[0].mo));
        if(e.Name=="ca118_pickups")Pickups(CaelumPlayer(players[0].mo));
        if(e.Name=="ca118_ui")
        {
            let u=CaelumPlayer(players[0].mo);
            u.CraftingTaskTotalSeconds=u.CraftingTaskRemainingSeconds;
            u.FormalInventoryFilter=0;
            u.CycleFormalInventoryFilter(1);
            u.CycleFormalInventorySelection(1);
        }
    }
    override void WorldLoaded(WorldEvent e)
    { let u=CaelumPlayer(players[0].mo);if(u!=null)Persistence(u,e.IsSaveGame?"save-load":e.IsReopen?"hub-return":"arrival"); }
    override void WorldUnloaded(WorldEvent e)
    { let u=CaelumPlayer(players[0].mo);if(u!=null)Persistence(u,"departure"); }
    override void WorldTick()
    { let u=CaelumPlayer(players[0].mo);if(u!=null && level.time>=2 && u.FindInventory("CA118Marker")==null)Run(u); }
}
