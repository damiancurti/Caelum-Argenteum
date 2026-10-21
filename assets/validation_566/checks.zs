// Pruebas aisladas de contratos y transacciones, sin alterar la campaña.
class CA386Checks : StaticEventHandler
{
    int Passed,Failed;
    void Check(bool ok,String label)
    {if(ok)Passed++;else Failed++;Console.Printf("CA386 %s %s",ok?"PASS":"FAIL",label);}
    int Count(CaelumPlayer u)
    {int n=0;for(Inventory c=u.Inv;c!=null;c=c.Inv){let p=CaelumEquipmentItem(c);if(p!=null && p.EquipmentKind==CaelumConstants.EQUIPMENT_KIND_CLOTHING)n++;}return n;}
    void Prepare(CaelumPlayer u)
    {u.bInvulnerable=true;u.CreationWizardOpen=false;u.DebugAttributesAt100=true;u.ApplyCharacterProfile();u.CancelCraftingTask();u.CloseCraftingStationSession();u.CombatTimeRemaining=0;CaelumClothing.Migrate(u);}
    void Suite(CaelumPlayer u)
    {
        Prepare(u);let r=u.GetPersistentCharacterState(true);let thermal=CaelumThermalBody.Get(u,true);
        Check(r.ClothingRevision==1 && Count(u)==4,"new player receives exactly four garments");
        int size=CaelumEquipmentRules.GetDefaultSizeForCharacterTier(u.CharacterProfile.GetSizeTier());
        double weight=0;
        for(int slot=0;slot<4;slot++)
        {
            let item=CaelumClothing.Equipped(u,slot);
            Check(item!=null && item.EquipmentSize==size && item.Tier==1 && item.Durability==100,"initial region identity and fit");
            if(item!=null)weight+=item.UnitWeight;
        }
        Check(Abs(weight-1.760*CaelumEquipmentRules.GetSizeWeightMultiplier(size))<0.000001,"initial set approved 1.760 kg at M");
        for(int i=0;i<5;i++)CaelumClothing.Migrate(u);
        Check(Count(u)==4,"migration repeats without granting duplicates");
        Check(Abs(CaelumClothingData.Weight(CaelumClothingData.HF,0)-0.076)<0.000001,"XS hat rounds both ingredients up separately");
        Check(Abs(CaelumClothingData.Value(CaelumClothingData.HF,0)-359.375)<0.000001,"XS hat price uses rounded grams and 25 percent markup");
        Check(Abs(CaelumClothingData.Value(CaelumClothingData.F,2)-8125)<0.000001,"formal M price approved 8125 copper");
        Check(CaelumCraftingRules.GetUnifiedRecipeKind(140)==CaelumConstants.CRAFTING_RECIPE_KIND_UTILITY
            && CaelumClothingData.FIRST_RECIPE==141,"existing recipe identities preserved");
        for(int type=0;type<CaelumClothingData.COUNT;type++)
        {
            int recipe=CaelumClothingData.FIRST_RECIPE+type;
            Check(CaelumRecipeLearning.TierMask(recipe)==1 && CaelumRecipeLearning.PracticeLimit(recipe)==10,"garment has one T1 recipe and equipment practice");
            for(int sz=0;sz<5;sz++)
            {
                let piece=CaelumClothing.Create(u,type,sz);
                Check(piece!=null && piece.PreviewTier()==1 && piece.EquipmentSize==sz
                    && piece.PreviewMaximumDurability(u)==100 && piece.UnitWeight>0,"native garment size and invariant condition");
                if(piece!=null)piece.Destroy();
            }
        }
        let coat=CaelumClothing.Create(u,CaelumClothingData.CW,size);coat.AttachToOwner(u);u.EnsureEquipmentItemId(coat);
        int armorId=u.EquippedArmorItemId[1];
        u.ApplyFormalInventorySelection(coat);u.EquipSelectedNativeEquipment();
        Check(coat.Equipped && CaelumClothing.Equipped(u,1)==coat && u.EquippedArmorItemId[1]==armorId,"clothing equips under unchanged armor identity");
        Check(!u.IsDurabilityTaskEquipment(coat),"clothing cannot repair or dismantle");
        thermal.SurfaceArea=2;for(int s=0;s<4;s++)thermal.Coverage[s]=0.25;
        coat.ThermalWaterKg=0.10;
        u.OnNativeInventoryChanged();
        Check(Abs(u.GetFormalInventoryEntryWeight(coat)-(coat.UnitWeight+0.10))<0.000001,"wet garment carried mass exactly once");
        u.UnequipSelectedNativeEquipment();
        Check(!coat.Equipped && CaelumClothing.Equipped(u,1)==null && coat.ThermalWaterKg==0.10,"unequip retains water on native garment");
        Check(CaelumThermalData.Clo(CaelumThermalBody.Material(u,1))==0,"bare region has zero clothing insulation");
        u.GrantMagicBoxFromPalomo(false);u.ToggleSelectedMagicBox();
        Check(coat.InMagicBox && coat.ThermalWaterKg==0.10,"box stores wet garment without drying");
        u.ToggleSelectedMagicBox();u.EquipSelectedNativeEquipment();
        Check(coat.Equipped && Abs(CaelumThermalData.Clo(CaelumThermalBody.Material(u,1))-1)<0.000001,"winter garment supplies approved insulation");
        let armor=CaelumEquipmentItem(Actor.Spawn("CaelumArmorPickup",u.Pos,NO_REPLACE));
        armor.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_ARMOR;armor.ItemType=CaelumConstants.ARMOR_TYPE_LIGHT;armor.ArmorSlot=1;
        armor.Tier=1;armor.EquipmentSize=size;armor.Durability=100;armor.UnitWeight=u.ArmorModel.GetWeightFor(1,1,1,size);
        armor.PickupDataInitialized=true;armor.AcquisitionResolved=true;armor.AttachToOwner(u);u.EnsureEquipmentItemId(armor);
        u.ApplyFormalInventorySelection(armor);u.EquipSelectedNativeEquipment();
        Check(CaelumThermalBody.Material(u,1)==CaelumThermalData.LEATHER && CaelumThermalData.Clo(CaelumThermalBody.Material(u,1))==1.2,"armor retains complete profile without extra clothing insulation");
        Check(Abs(coat.ThermalWaterKg+armor.ThermalWaterKg-0.1)<0.000001 && thermal.BaseWaterKg[1]==0,"armor transition conserves water without base ledger");
        coat.ThermalWaterKg=1;armor.ThermalWaterKg=1;
        double runoff=thermal.ClothingRunoffKg,latent=thermal.EvaporationJoules;
        CaelumClothing.ReconcileWater(u);
        Check(Abs(coat.ThermalWaterKg+armor.ThermalWaterKg+thermal.ClothingRunoffKg-runoff-2)<0.000001
            && thermal.EvaporationJoules==latent,"excess capacity drains with exact mass and no evaporative cooling");
        u.UnequipSelectedNativeEquipment();armor.Destroy();u.ApplyFormalInventorySelection(coat);u.UnequipSelectedNativeEquipment();
        coat.Destroy();Transfers(u);Trade(u);Craft(u);
        Console.Printf("CA386 RESULT %d PASS %d FAIL",Passed,Failed);
    }
    void Transfers(CaelumPlayer u)
    {
        let chest=CaelumStashChest(Actor.Spawn("CaelumStashChest",u.Pos+(32,0,0),NO_REPLACE));
        if(chest==null){Check(false,"small chest fixture");return;}
        chest.EnsureStorage();chest.StorageTier=CaelumContainerRules.SMALL;chest.ApplyStorageSize();CaelumContainerSession.Open(u,chest);
        let item=CaelumClothing.Create(u,CaelumClothingData.F,2);item.AttachToOwner(u);u.EnsureEquipmentItemId(item);
        int id=item.ItemId;item.ThermalWaterKg=101;
        Check(!CaelumInventoryService.TransferContainerItem(u,chest,item,1,true) && item.Owner==u
            && item.ItemId==id && item.ThermalWaterKg==101,"wet mass exceeding chest capacity rejects complete transfer");
        item.ThermalWaterKg=0.2;
        Check(CaelumInventoryService.TransferContainerItem(u,chest,item,1,true) && item.Owner==chest
            && item.ItemId==id && Abs(chest.StorageWeight(u)-2.0)<0.000001,"chest receives same wet native item and exact mass");
        Check(CaelumInventoryService.TransferContainerItem(u,chest,item,1,false) && item.Owner==u
            && item.ItemId==id && item.ThermalWaterKg==0.2,"withdraw keeps identity size and moisture");
        let copy=CaelumEquipmentItem(item.CreateTossable(1));
        Check(copy!=null && copy.ItemId==id && copy.ItemType==CaelumClothingData.F
            && copy.EquipmentSize==2 && copy.ThermalWaterKg==0.2,"native drop preserves identity and wet data");
        if(copy!=null && copy!=item)copy.Destroy();item.Destroy();chest.Destroy();
        let incoming=CaelumEquipmentItem(Actor.Spawn("CaelumClothingPickup",u.Pos+(64,0,0),NO_REPLACE));
        incoming.args[0]=CaelumClothingData.HF;incoming.args[2]=1;incoming.SizePolicy=CaelumEquipmentRules.FIXED_SIZE;
        Actor toucher=u;
        Check(incoming.TryEquipmentPickup(toucher),"world clothing pickup uses native size resolution");
        let found=u.FindNativeEquipmentItem(CaelumConstants.EQUIPMENT_KIND_CLOTHING,CaelumClothingData.HF,-1,1,0);
        Check(found!=null && Abs(found.UnitWeight-0.076)<0.000001 && found.AcquisitionResolved,"world pickup retains fixed XS and rounded mass");
        if(found!=null)found.Destroy();
        u.OnNativeInventoryChanged();
    }
    bool SelectTrade(CaelumPlayer u,Inventory item,bool selling)
    {
        u.PalomoMerchantMode=selling?CaelumConstants.PALOMO_MERCHANT_MODE_SELL:CaelumConstants.PALOMO_MERCHANT_MODE_BUY;
        u.PalomoMerchantQuantityIndex=0;u.CityTrade.Refresh(u);
        for(int row=0;row<u.CityTrade.Rows.Size();row++)if(u.CityTrade.Rows[row]==item)
        {u.CityTrade.Selection=row;u.CityTrade.Refresh(u);return true;}
        return false;
    }
    void Trade(CaelumPlayer u)
    {
        let vendor=CaelumCityMerchant(Actor.Spawn("CaelumCityMerchant",u.Pos+(48,0,0),NO_REPLACE));
        vendor.StockInitialized=true;vendor.Revision=2;vendor.WalletCopper=200000;
        let item=CaelumClothing.Create(u,CaelumClothingData.CE,2);item.ThermalWaterKg=0.25;
        item.AttachToOwner(u);u.EnsureEquipmentItemId(item);int id=item.ItemId;
        Check(!vendor.Accepts(item),"existing shops receive no automatic clothing assignment");
        vendor.TradesClothing=true;
        CaelumCityTradeSession.Open(u,vendor);
        Check(SelectTrade(u,item,true),"clothing capability selects exact native sale");
        int price=u.PalomoMerchantSelectedLotPrice,money=int(u.GetOwnedMoneyCopperValue());
        u.ExecutePalomoMerchantTransaction();
        Check(item.Owner==vendor && item.ItemId==id && item.ThermalWaterKg==0.25
            && int(u.GetOwnedMoneyCopperValue())==money+price,"sale transfers same wet item and exact price");
        let coins=Inventory(Actor.Spawn("CaelumSilverCoin",u.Pos,NO_REPLACE));coins.Amount=1000;coins.AttachToOwner(u);u.OnNativeInventoryChanged();
        Check(SelectTrade(u,item,false),"sold garment available as same native purchase");
        price=u.PalomoMerchantSelectedLotPrice;money=int(u.GetOwnedMoneyCopperValue());
        u.ExecutePalomoMerchantTransaction();
        Check(item.Owner==u && item.ItemId==id && item.EquipmentSize==2 && item.Durability==100
            && item.ThermalWaterKg==0.25 && int(u.GetOwnedMoneyCopperValue())==money-price,"buyback preserves clothing identity fit condition water and wallet");
        item.Equipped=true;Check(!SelectTrade(u,item,true),"worn garment cannot be sold");item.Equipped=false;
        u.ClosePalomoMerchant();item.Destroy();vendor.Destroy();
    }
    void Craft(CaelumPlayer u)
    {
        u.GrantMagicBoxFromPalomo(false);u.DebugSetAllCraftingRecipesKnown(true);
        let bench=CaelumCraftingStation(Actor.Spawn("CaelumWorkbenchStation",u.Pos+(48,0,0),NO_REPLACE));
        let sewing=CaelumCraftingStation(Actor.Spawn("CaelumSewingMachineStation",u.Pos+(0,48,0),NO_REPLACE));
        bench.CollectCraftingNetwork(u,u.BeginCraftingNetworkScan());u.OpenCraftingNetwork(bench);
        for(int type=0;type<CaelumClothingData.COUNT;type++)
        {
            u.CraftingSelectionRecipe=CaelumClothingData.FIRST_RECIPE+type;u.CraftingSelectionTier=3;u.CraftingSelectionSize=2;
            u.CraftingEfficiencyIndex=2;u.ResetCraftingLayerChoices();u.RefreshCraftingPreview();
            Check(u.CraftingSelectionTier==1 && u.CraftingGoldRequired==0 && u.CraftingSelectedInfrastructureAvailable,"workbench sewing single tier preview");
            for(int i=0;i<3;i++)
            {
                int units=CaelumClothingData.Units(type,2,i);if(units<=0)continue;
                int m=CaelumClothingData.Material(type,i),t=CaelumClothingData.MaterialTier(type,i);
                let material=u.FindNativeSpecialItem(CaelumConstants.EQUIPMENT_KIND_MATERIAL,m,t);
                if(material==null){material=u.CreateDetachedMaterialStack(m,t,units+1);material.AttachToOwner(u);}
                material.Amount=units+1;material.InMagicBox=true;
            }
            u.OnNativeInventoryChanged();u.RefreshCraftingPreview();int before=Count(u);
            u.BeginSelectedCraftingTask();Check(u.CraftingTaskActive,"native task reserves exact garment inputs");
            u.CraftingTaskRemainingSeconds=0;u.CompleteCraftingTask();
            Check(Count(u)==before+1 && u.LastCraftingAction==CaelumConstants.CRAFTING_ACTION_CREATED,"one native garment paid and delivered");
            for(int i=0;i<3;i++)
            {
                if(CaelumClothingData.Units(type,2,i)<=0)continue;
                let material=u.FindNativeSpecialItem(CaelumConstants.EQUIPMENT_KIND_MATERIAL,CaelumClothingData.Material(type,i),CaelumClothingData.MaterialTier(type,i));
                Check(material!=null && material.Amount==1,"recipe spends exact material tier without silver substitute");
            }
            u.CompleteCraftingTask();Check(Count(u)==before+1,"completion cannot duplicate garment");
            Check(u.GetPersistentCharacterState(true).RecipePractice[CaelumRecipeLearning.Slot(CaelumClothingData.FIRST_RECIPE+type,1)]==1,"completion counts exactly one equipment practice");
        }
        u.CloseCraftingStationSession();bench.Destroy();sewing.Destroy();
    }
    void Persistence(CaelumPlayer u,bool setup)
    {
        Prepare(u);let r=u.GetPersistentCharacterState(true);
        let mark=CA386Checkpoint(u.FindInventory("CA386Checkpoint"));
        if(setup)
        {
            mark=CA386Checkpoint(Actor.Spawn("CA386Checkpoint",u.Pos,NO_REPLACE));mark.AttachToOwner(u);
            u.GrantMagicBoxFromPalomo(false);
            let stored=CaelumClothing.Create(u,CaelumClothingData.RW,3);stored.InMagicBox=true;stored.ThermalWaterKg=0.3;
            stored.AttachToOwner(u);u.EnsureEquipmentItemId(stored);mark.StoredId=stored.ItemId;mark.ClothingCount=Count(u);
        }
        if(mark==null){Check(false,"checkpoint present");return;}
        for(int slot=0;slot<4;slot++)
        {
            let item=CaelumClothing.Equipped(u,slot);
            if(setup){mark.ClothingIds[slot]=item!=null?item.ItemId:0;mark.ArmorIds[slot]=u.EquippedArmorItemId[slot];}
            Check(item!=null && item.ItemId==mark.ClothingIds[slot] && u.EquippedArmorItemId[slot]==mark.ArmorIds[slot],"save travel preserves native clothing and armor identities");
        }
        Check(Count(u)==mark.ClothingCount && r.ClothingRevision==1,"save travel does not repeat initial grant");
        let stored=u.FindNativeEquipmentItemById(mark.StoredId);
        Check(stored!=null && stored.InMagicBox && stored.EquipmentSize==3 && stored.ThermalWaterKg==0.3,
            "stored wet garment does not dry or change identity across save travel");
        Console.Printf("CA386 RESULT %d PASS %d FAIL",Passed,Failed);
    }
    void Upgrade(CaelumPlayer u)
    {
        Prepare(u);let mark=CA386Checkpoint(u.FindInventory("CA386Checkpoint"));
        let thermal=CaelumThermalBody.Get(u,true);let record=u.GetPersistentCharacterState(true);
        Check(mark!=null && (mark.BookVersion==8 || mark.BookVersion==9),"fixture originates in actual old engine save");
        for(int slot=0;slot<4 && mark!=null;slot++)
        {
            let item=CaelumClothing.Equipped(u,slot);
            Check(item!=null && thermal.BaseWaterKg[slot]==0 && u.EquippedArmorItemId[slot]==mark.ArmorIds[slot],"upgrade transfers base water ownership and preserves armor");
        }
        Check(record.KnowsCraftingRecipe(0,1) && !record.KnowsCraftingRecipe(141,1)
            && (mark.BookVersion<9 || record.KnowsCraftingRecipe(136,1)),"recipe migration preserves knowledge without granting clothes");
        double water=0;
        for(int slot=0;slot<4;slot++)water+=CaelumThermalBody.Water(u,thermal,slot);
        Check(mark!=null && mark.ArmorIds[1]>0 && Abs(water+thermal.EvaporatedKg-mark.Evaporated
            +thermal.ClothingRunoffKg-mark.TotalWater)<0.00001,"actual wet armored legacy conserves water across migration and evaporation");
        Check(Count(u)==4,"legacy receives initial set once");
        Console.Printf("CA386 RESULT %d PASS %d FAIL",Passed,Failed);
    }
    void Author(CaelumPlayer u)
    {
        Prepare(u);u.GrantMagicBoxFromPalomo(false);u.DebugSetAllCraftingRecipesKnown(true);
        int size=CaelumEquipmentRules.GetDefaultSizeForCharacterTier(u.CharacterProfile.GetSizeTier());
        for(int type=0;type<CaelumClothingData.COUNT;type++)
        {let item=CaelumClothing.Create(u,type,size);item.InMagicBox=true;item.AttachToOwner(u);u.EnsureEquipmentItemId(item);}
        let armor=CaelumEquipmentItem(Actor.Spawn("CaelumArmorPickup",u.Pos,NO_REPLACE));
        armor.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_ARMOR;armor.ItemType=CaelumConstants.ARMOR_TYPE_LIGHT;armor.ArmorSlot=1;
        armor.Tier=1;armor.EquipmentSize=size;armor.UnitWeight=u.ArmorModel.GetWeightFor(1,1,1,size);
        armor.Durability=u.ArmorModel.GetMaximumDurabilityFor(1,1,size);armor.PickupDataInitialized=true;
        armor.AcquisitionResolved=true;armor.InMagicBox=true;armor.AttachToOwner(u);u.EnsureEquipmentItemId(armor);
        let chest=CaelumStashChest(Actor.Spawn("CaelumStashChest",u.Pos+(128,-96,0),NO_REPLACE));
        chest.EnsureStorage();chest.StorageTier=CaelumContainerRules.SMALL;chest.ApplyStorageSize();
        Actor.Spawn("CaelumWorkbenchStation",u.Pos+(128,0,0),NO_REPLACE);
        Actor.Spawn("CaelumSewingMachineStation",u.Pos+(128,64,0),NO_REPLACE);
        for(int m=0;m<5;m++)
        {int type=m<3?CaelumConstants.MATERIAL_FABRIC:m==3?CaelumConstants.MATERIAL_LEATHER:CaelumConstants.MATERIAL_ROPE;
         let mat=u.CreateDetachedMaterialStack(type,m<3?m+1:1,50000);mat.InMagicBox=true;mat.AttachToOwner(u);}
        CaelumRecipeLearning.Receive(u,CaelumClothingData.FIRST_RECIPE,1);
        u.OnNativeInventoryChanged();u.EquipmentMenuOpen=false;u.FormalInventoryFilter=10;u.RefreshFormalInventorySnapshot();
        Console.Printf("CA386 READY: ropa en inventario/Caja; banco y maquina de coser delante. / Clothing ready in inventory/Box.");
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=="ca386_suite")Suite(u);
        if(e.Name=="ca386_save")Persistence(u,true);
        if(e.Name=="ca386_verify")Persistence(u,false);
        if(e.Name=="ca386_upgrade")Upgrade(u);
        if(e.Name=="ca386_author")Author(u);
    }
}
