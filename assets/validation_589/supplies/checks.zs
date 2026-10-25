// Pruebas de transacciones reales; no se sustituyen las comprobaciones del jugador.
class CA502SuppliesProof : Inventory
{
    CaelumCityMerchant Vendor;
    CaelumWaterContainer Water;
    Default { +INVENTORY.UNDROPPABLE Inventory.MaxAmount 1; }
    States { Spawn: TNT1 A -1; Stop; }
}
class CA502SuppliesChecks : EventHandler
{
    int Passed,Failed;
    CaelumCraftingStation Bench,Chemistry;
    CaelumCityMerchant AuthorVendor;
    void Check(bool ok,String label){if(ok)Passed++;else Failed++;Console.Printf("CA502 %s supplies %s",ok?"PASS":"FAIL",label);}
    bool Near(double a,double b){return Abs(a-b)<0.000001;}
    void Result(){Console.Printf("CA502 RESULT supplies passes=%d failures=%d",Passed,Failed);}
    void Setup(CaelumPlayer user)
    {
        user.CharacterCreationComplete=true;user.CreationWizardOpen=false;user.bInvulnerable=true;
        user.SetOrigin((128,320,192),false);user.Vel=(0,0,0);user.Angle=90;
        CaelumWorldClock.Get(user,true);user.DerivedStats.CarryCapacity=1000;
    }
    void Material(CaelumPlayer user,int kind,int tier,int amount)
    {
        let item=user.FindNativeSpecialItem(CaelumConstants.EQUIPMENT_KIND_MATERIAL,kind,tier);
        if(item==null){item=user.CreateDetachedMaterialStack(kind,tier,amount);item.AttachToOwner(user);}
        item.Amount=amount;item.InMagicBox=false;
    }
    int Count(Actor owner,Name type)
    {int count=0;for(Inventory item=owner.Inv;item!=null;item=item.Inv)if(item.GetClassName()==type)count+=item.Amount;return count;}
    CaelumCityMerchant Vendor(CaelumPlayer user,int category)
    {
        let v=CaelumCityMerchant(Actor.Spawn('CaelumCityMerchant',(256,320,192),NO_REPLACE));
        v.ChangeTid(50201);
        v.Category=category;v.StockInitialized=true;v.CatalogueRevision=1;v.RestockRevision=1;
        CaelumHygieneCatalogue.Ensure(v,user);return v;
    }
    void Craft(CaelumPlayer user)
    {
        Setup(user);
        let record=user.GetPersistentCharacterState(true);record.LearnCraftingRecipe(201,1);record.RecipeBookVersion=15;
        record.KnownRecipeTiers[203]=7;record.KnownRecipeTiers[204]=7;record.EnsureTierRecipeBook();
        Check(record.RecipeBookVersion==16 && record.KnowsCraftingRecipe(201,1) && !record.KnowsCraftingRecipe(203,1)
            && !record.KnowsCraftingRecipe(204,1),"migration preserves camp and locks only appended recipes");
        Check(!CaelumChemistryData.IsRecipe(198) && !CaelumChemistryData.IsRecipe(201)
            && !CaelumChemistryData.IsRecipe(204) && CaelumChemistryData.IsRecipe(203),"noncontiguous chemistry extension preserves mate camp and cloth");
        Bench=CaelumCraftingStation(Actor.Spawn('CaelumWorkbenchStation',(128,384,192),NO_REPLACE));Bench.CraftingRoomGroup=502;
        Bench.CollectCraftingNetwork(user,user.BeginCraftingNetworkScan());user.OpenCraftingNetwork(Bench);
        for(int id=105;id<=107;id++)
        {
            Material(user,id,1,6000);let item=user.FindNativeSpecialItem(CaelumConstants.EQUIPMENT_KIND_MATERIAL,id,1);
            Check(item.GetSpecialType()==id && Near(item.GetUnitWeight(),0.001),"registered gram material identity and mass");
            Check(TexMan.CheckForTexture(CaelumChemistryData.MaterialIcon(id),TexMan.Type_MiscPatch).IsValid(),"painted material inventory icon resolves");
        }
        Material(user,CaelumConstants.MATERIAL_COAL,1,10000);Material(user,CaelumConstants.MATERIAL_FABRIC,2,1000);
        record.LearnCraftingRecipe(203,1);record.LearnCraftingRecipe(204,1);
        user.CraftingSelectionRecipe=203;user.CraftingEfficiencyIndex=2;user.CraftingProcessingBatchIndex=0;user.RefreshCraftingPreview();
        Check(!user.CraftingSelectedInfrastructureAvailable,"soap rejected without Chemistry");
        Chemistry=CaelumCraftingStation(Actor.Spawn('CaelumAlchemyStation',(240,384,192),NO_REPLACE));Chemistry.CraftingRoomGroup=502;
        Bench.CollectCraftingNetwork(user,user.BeginCraftingNetworkScan());user.OpenCraftingNetwork(Bench);user.CraftingSelectionRecipe=203;user.RefreshCraftingPreview();
        Check(user.CraftingSelectedInfrastructureAvailable && user.CraftingOutputAmount==1000,"connected Chemistry exposes whole soap batch");
        Check(user.CraftingBasicRequired==1000 && user.CraftingTierRequired==135 && user.CraftingSilverRequired==2058,"soap reserves fat soda and coal");
        Check(Near(user.CraftingPreviewSeconds,7200),"soap two world hours without Dexterity shortening");
        let water=CaelumWaterContainer(Actor.Spawn('CaelumCanteenLarge',user.Pos,NO_REPLACE));water.AttachToOwner(user);water.AddWater(1,1,20,true);
        user.BeginSelectedCraftingTask();Check(!user.CraftingTaskActive,"contaminated water cannot start soap");
        water.WaterQuality=0;user.BeginSelectedCraftingTask();
        Check(user.CraftingTaskActive && user.CraftingTaskKind==CaelumConstants.CRAFTING_TASK_CHEMISTRY,"native soap task begins");
        Check(CaelumChemistryCrafting.Locked(water) && Near(water.WaterLiters,1),"water reserved without premature consumption");
        user.CancelCraftingTask();Check(Near(water.WaterLiters,1) && user.CountRawCraftingMaterial(105,1)==6000,"cancel releases water and all ingredients");
        user.BeginSelectedCraftingTask();user.CraftingTaskRemainingSeconds=0.000001;user.UpdateCraftingTask();
        Check(!user.CraftingTaskActive && user.CountRawCraftingMaterial(107,1)==7000,"soap completion adds exactly one kilogram");
        Check(user.CountRawCraftingMaterial(105,1)==5000 && user.CountRawCraftingMaterial(106,1)==5865
            && user.CountRawCraftingMaterial(CaelumConstants.MATERIAL_COAL,1)==7942 && Near(water.WaterLiters,0.7),"completion pays every input exactly once");
        user.CraftingSelectionRecipe=204;user.RefreshCraftingPreview();
        Check(user.CraftingBasicMaterialTier==2 && user.CraftingBasicRequired==100 && user.CraftingTierRequired==0,"cloth uses cotton fabric only");
        Check(user.ResolveCraftingPreviewIconPath()=="graphics/caelum/icons/hygiene/cloth.png","cloth preview keeps its painted icon");
        user.CraftingEfficiencyIndex=0;user.RefreshCraftingPreview();Check(user.CraftingBasicRequired==400,"cloth follows normal fabrication waste");
        user.CraftingEfficiencyIndex=2;user.RefreshCraftingPreview();user.BeginSelectedCraftingTask();
        Check(user.CraftingTaskActive,"normal cloth fabrication starts");user.CancelCraftingTask();
        Check(user.CountRawCraftingMaterial(CaelumConstants.MATERIAL_FABRIC,2)==1000,"cloth cancellation consumes nothing");
        for(int i=0;i<2;i++)
        {
            user.DerivedStats.CarryCapacity=1000;user.BeginSelectedCraftingTask();Check(user.CraftingTaskActive,"another cloth can be crafted");
            user.CraftingTaskRemainingSeconds=0.000001;user.UpdateCraftingTask();
        }
        Check(Count(user,'CaelumCleaningCloth')==2 && user.CountRawCraftingMaterial(CaelumConstants.MATERIAL_FABRIC,2)==800,"two completions each pay100g and give one cloth");
        user.CloseCraftingStationSession();user.SetCraftingJournalState(false);Result();
    }
    void Shop(CaelumPlayer user)
    {
        Setup(user);let v=Vendor(user,0);Check(v.Products.Size()==4,"four hygiene supplies appended once");
        for(int i=0;i<4;i++)
        {
            let p=v.Products[i];int expected=i==0?10000:i==1?1000:i==2?3000:20;
            Check(p.Stock!=null && p.Stock.Amount==expected,"approved provisions stock");
            Check(CaelumShopRestock.Duration(p,user)>0,"restock has positive approved clock");
            p.Stock.Amount=1;
        }
        Check(Near(CaelumEconomyRules.GetMaterialUnitBaseValue(105),0.04) && Near(CaelumEconomyRules.GetMaterialUnitBaseValue(106),0.05),"fat and soda prices per gram");
        double expected=(1000*0.04+135*0.05+2058*CaelumEconomyRules.GetMaterialUnitBaseValue(CaelumConstants.MATERIAL_COAL)
            +0.3*CaelumConstants.ECONOMY_WATER_RATION_VALUE/CaelumConstants.WATER_RATION_LITERS)*1.25/1000;
        Check(Near(CaelumEconomyRules.GetMaterialUnitBaseValue(107),expected),"soap price includes all inputs fuel water and margin");
        Check(Near(CaelumHygieneCrafting.ClothValue(),100*CaelumEconomyRules.GetMaterialUnitBaseValue(CaelumConstants.MATERIAL_FABRIC,2)*1.25),"cloth price uses cotton and margin");
        CaelumShopRestock.Sync(v,user,true);double due=v.Products[2].NextDue;
        v.HygieneCatalogueRevision=0;CaelumHygieneCatalogue.Ensure(v,user);
        Check(v.Products.Size()==4 && v.Products[2].Stock.Amount==1 && Near(v.Products[2].NextDue,due),"migration retry preserves depleted stock and deadline");
        let lib=Vendor(user,CaelumShopCatalogue.LIBRARY);
        Check(lib.Products.Size()==2 && lib.Products[0].Stock.Amount==10 && lib.Products[1].Stock.Amount==10,"library ten copies of both recipes");
        Check(v.Products[2].FindRecipe()==203 && v.Products[3].FindRecipe()==204,"restock rediscovers exact recipe identities");
        Console.Printf("CA502 DETAIL soap duration=%.9f expected=%.9f",CaelumShopRestock.Duration(v.Products[2],user),7200.0*CaelumWorldClock.TicsPerHour()/3600/1000);
        Check(Near(CaelumShopRestock.Duration(v.Products[2],user),7200.0*CaelumWorldClock.TicsPerHour()/3600/1000),"soap replenishment divides full world-time recipe by1000g");
        Check(Near(CaelumShopRestock.Duration(v.Products[0],user),CaelumWorldClock.TicsPerDay()/10),"fat imports ten grams per day");
        Result();
    }
    void Transfer(CaelumPlayer user)
    {
        Setup(user);CaelumInventoryService.GrantMagicBoxFromPalomo(user,false);
        let coins=user.GiveInventoryType('CaelumGoldCoin');coins.Amount=1000;user.OnNativeInventoryChanged();
        let v=CaelumCityMerchant(Actor.Spawn('CaelumCityMerchant',(128,320,192),NO_REPLACE));v.Category=0;v.WalletCopper=1000000;
        CaelumMerchantCoordinator.OpenCityTrade(user,v);let session=user.CityTrade;
        if(session==null){Check(false,"native shop opens");Result();return;}
        Inventory stock=null;
        for(int i=0;i<session.Rows.Size();i++)if(session.Rows[i] is 'CaelumCleaningCloth'){stock=session.Rows[i];session.Selection=i;break;}
        if(stock==null){Check(false,"cloth in native shop");Result();return;}
        session.Refresh(user);session.Execute(user);let cloth=user.FindInventory('CaelumCleaningCloth');
        Check(cloth!=null && stock.Amount==19,"real purchase takes one cloth from20");
        if(cloth==null){Result();return;}
        session.Selection=session.Rows.Find(stock);session.Refresh(user);session.Execute(user);
        Check(Count(user,'CaelumCleaningCloth')==2 && stock.Amount==18,"second cloth purchase succeeds");
        user.PalomoMerchantMode=CaelumConstants.PALOMO_MERCHANT_MODE_SELL;session.Refresh(user);
        session.Selection=session.Rows.Find(cloth);session.Refresh(user);session.Execute(user);
        Check(Count(user,'CaelumCleaningCloth')==1 && stock.Amount==19,"sale returns one reusable cloth");
        user.ClosePalomoMerchant();cloth=user.FindInventory('CaelumCleaningCloth');
        user.FormalInventoryFilter=0;user.RefreshFormalInventorySnapshot();
        for(int i=0;i<user.FormalInventoryEntryCount;i++)if(user.GetFormalInventoryEntryAt(i)==cloth){user.FormalInventorySelectionIndex=i;break;}
        bool boxed=CaelumContainerRules.Boxed(cloth);user.ToggleFormalInventoryStorage();
        Check(CaelumContainerRules.Boxed(cloth)!=boxed,"cloth follows native Box toggle");
        user.ToggleFormalInventoryStorage();Check(CaelumContainerRules.Boxed(cloth)==boxed,"cloth returns from Box without loss");
        let chest=CaelumStashChest(Actor.Spawn('CaelumStashChest',(128,320,192),NO_REPLACE));chest.ChestUnlocked=true;
        CaelumContainerSession.Open(user,chest);
        Check(CaelumInventoryService.TransferContainerItem(user,chest,cloth,1,true),"cloth enters real chest");
        Check(CaelumInventoryService.TransferContainerItem(user,chest,chest.FindInventory('CaelumCleaningCloth'),1,false),"cloth withdrawn from real chest");
        CaelumContainerSession.Get(user).Close();Result();
    }
    void Seed(CaelumPlayer user)
    {
        Setup(user);let proof=CA502SuppliesProof(user.GiveInventoryType('CA502SuppliesProof'));
        proof.Vendor=Vendor(user,0);proof.Vendor.Products[2].Stock.Amount=1234;
        Material(user,107,1,321);user.GiveInventoryType('CaelumCleaningCloth');
        user.GetPersistentCharacterState(true).LearnCraftingRecipe(203,1);
        Check(proof.Vendor.HygieneCatalogueRevision==1,"persistent acquisition fixture ready");Result();
    }
    void Load(CaelumPlayer user)
    {
        let proof=CA502SuppliesProof(user.FindInventory('CA502SuppliesProof'));
        Check(proof!=null,"saved carrier proof survives");
        // Las referencias a actores de otro mapa se limpian al cruzar el hub.
        // El comercio real se recupera por su TID estable al regresar.
        if(proof!=null && proof.Vendor==null)
        {let finder=ActorIterator.Create(50201);proof.Vendor=CaelumCityMerchant(finder.Next());}
        Check(proof!=null && proof.Vendor!=null,"native saved merchant survives map return");
        if(proof!=null && proof.Vendor!=null)
        {
            CaelumHygieneCatalogue.Ensure(proof.Vendor,user);
            Check(proof.Vendor.Products.Size()==4 && proof.Vendor.Products[2].Stock.Amount==1234,"saved depleted soap never refills on migration");
        }
        Check(user.CountRawCraftingMaterial(107,1)==321 && Count(user,'CaelumCleaningCloth')==1,"saved carried supplies survive");
        Check(user.GetPersistentCharacterState(true).KnowsCraftingRecipe(203,1),"new learned recipe survives save and hub");Result();
    }
    void TaskSeed(CaelumPlayer user)
    {
        Setup(user);let proof=CA502SuppliesProof(user.GiveInventoryType('CA502SuppliesProof'));
        Bench=CaelumCraftingStation(Actor.Spawn('CaelumWorkbenchStation',(128,384,192),NO_REPLACE));Bench.CraftingRoomGroup=502;
        Chemistry=CaelumCraftingStation(Actor.Spawn('CaelumAlchemyStation',(240,384,192),NO_REPLACE));Chemistry.CraftingRoomGroup=502;
        Bench.CollectCraftingNetwork(user,user.BeginCraftingNetworkScan());user.OpenCraftingNetwork(Bench);
        Material(user,105,1,1000);Material(user,106,1,135);Material(user,CaelumConstants.MATERIAL_COAL,1,2058);
        proof.Water=CaelumWaterContainer(Actor.Spawn('CaelumCanteenLarge',user.Pos,NO_REPLACE));proof.Water.AttachToOwner(user);proof.Water.AddWater(1,0,20,true);
        user.GetPersistentCharacterState(true).LearnCraftingRecipe(203,1);
        user.CraftingSelectionRecipe=203;user.CraftingEfficiencyIndex=2;user.CraftingProcessingBatchIndex=0;
        user.RefreshCraftingPreview();user.BeginSelectedCraftingTask();
        Check(user.CraftingTaskActive && CaelumChemistryCrafting.Locked(proof.Water),"soap task and water reservation ready for save");Result();
    }
    void TaskLoad(CaelumPlayer user)
    {
        let proof=CA502SuppliesProof(user.FindInventory('CA502SuppliesProof'));
        Check(proof!=null && proof.Water!=null && user.CraftingTaskActive,"saved soap task restored");
        if(proof==null || proof.Water==null){Result();return;}
        Check(CaelumChemistryCrafting.Locked(proof.Water) && Near(proof.Water.WaterLiters,1),"exact unspent water reservation restored");
        user.CraftingTaskRemainingSeconds=0.000001;user.UpdateCraftingTask();
        Check(!user.CraftingTaskActive && user.CountRawCraftingMaterial(107,1)==1000 && Near(proof.Water.WaterLiters,0.7),"loaded soap task pays once and finishes");Result();
    }
    void Author(CaelumPlayer user)
    {
        Setup(user);CaelumInventoryService.GrantMagicBoxFromPalomo(user,false);
        let coins=CaelumCurrencyItem(user.GiveInventoryType('CaelumGoldCoin'));coins.Amount=1000;coins.InMagicBox=true;
        for(int id=105;id<=107;id++)Material(user,id,1,1000);
        Material(user,CaelumConstants.MATERIAL_COAL,1,10000);Material(user,CaelumConstants.MATERIAL_FABRIC,2,2000);
        user.GiveInventoryType('CaelumCleaningCloth');
        let water=CaelumWaterContainer(Actor.Spawn('CaelumCanteenLarge',user.Pos,NO_REPLACE));water.AttachToOwner(user);water.AddWater(1,0,20,true);
        Bench=CaelumCraftingStation(Actor.Spawn('CaelumWorkbenchStation',(128,384,192),NO_REPLACE));Bench.CraftingRoomGroup=502;
        Chemistry=CaelumCraftingStation(Actor.Spawn('CaelumAlchemyStation',(240,384,192),NO_REPLACE));Chemistry.CraftingRoomGroup=502;
        AuthorVendor=CaelumCityMerchant(Actor.Spawn('CaelumCityMerchant',(128,320,192),NO_REPLACE));AuthorVendor.Category=0;AuthorVendor.WalletCopper=1000000;
        let record=user.GetPersistentCharacterState(true);record.LearnCraftingRecipe(203,1);record.LearnCraftingRecipe(204,1);
        user.OnNativeInventoryChanged();Console.Printf("CA502 RESULT supplies author ready: F2 Provisiones, F3 fabricacion, F6 consola.");
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let user=CaelumPlayer(players[e.Player].mo);if(user==null)return;
        if(e.Name=="ca502_supplies_craft")Craft(user);
        if(e.Name=="ca502_supplies_shop")Shop(user);
        if(e.Name=="ca502_supplies_transfer")Transfer(user);
        if(e.Name=="ca502_supplies_seed")Seed(user);
        if(e.Name=="ca502_supplies_load")Load(user);
        if(e.Name=="ca502_supplies_task_seed")TaskSeed(user);
        if(e.Name=="ca502_supplies_task_load")TaskLoad(user);
        if(e.Name=="ca502_supplies_author")Author(user);
        if(e.Name=="ca502_supplies_trade" && AuthorVendor!=null)CaelumMerchantCoordinator.OpenCityTrade(user,AuthorVendor);
        if(e.Name=="ca502_supplies_bench" && Bench!=null)
        {Bench.CollectCraftingNetwork(user,user.BeginCraftingNetworkScan());user.OpenCraftingNetwork(Bench);user.CraftingSelectionRecipe=203;user.RefreshCraftingPreview();}
        if(e.Name=="ca502_supplies_preview")
        {
            Author(user);CaelumMerchantCoordinator.OpenCityTrade(user,AuthorVendor);
            for(int i=0;i<user.CityTrade.Rows.Size();i++)if(user.CityTrade.Rows[i] is 'CaelumCleaningCloth')
            {user.CityTrade.Selection=i;break;}
            user.CityTrade.Refresh(user);
        }
        if(e.Name=="ca502_supplies_inventory")
        {
            user.ClosePalomoMerchant();user.CloseCraftingStationSession();user.FormalInventoryFilter=0;
            user.RefreshFormalInventorySnapshot();let cloth=user.FindInventory('CaelumCleaningCloth');
            for(int i=0;i<user.FormalInventoryEntryCount;i++)if(user.GetFormalInventoryEntryAt(i)==cloth){user.FormalInventorySelectionIndex=i;break;}
            user.RefreshFormalInventorySnapshot();
        }
    }
}
