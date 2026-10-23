// Pruebas de transacciones reales; las cantidades ajenas a la receta son fixtures.
class CA471IntegrationChecks : EventHandler
{
    int Passed,Failed;
    CaelumFermentationStation Barrel;
    CaelumCraftingStation Bench,Chemistry;
    void Check(bool ok,String label)
    {if(ok)Passed++;else Failed++;Console.Printf("CA471B %s %s",ok?"PASS":"FAIL",label);}
    bool Near(double a,double b){return Abs(a-b)<0.000001;}
    void Result(){Console.Printf("CA471B RESULT integration passed=%d failed=%d map=%s",Passed,Failed,level.MapName);}
    void Material(CaelumPlayer user,int id,int amount)
    {
        let item=user.FindNativeSpecialItem(CaelumConstants.EQUIPMENT_KIND_MATERIAL,id,1);
        if(item==null){item=user.CreateDetachedMaterialStack(id,1,amount);item.AttachToOwner(user);}
        item.Amount=amount;item.InMagicBox=false;
    }
    void Setup(CaelumPlayer user)
    {
        user.CancelCraftingTask();user.CombatTimeRemaining=0;user.bInvulnerable=true;
        user.CharacterCreationComplete=true;user.CreationWizardOpen=false;
        user.SetOrigin((224,-64,0),false);user.Vel=(0,0,0);user.Angle=90;
        Barrel=CaelumFermentationStation(Actor.Spawn('CaelumFermentationStation',(224,0,0),NO_REPLACE));
        Bench=CaelumCraftingStation(Actor.Spawn('CaelumWorkbenchStation',(112,0,0),NO_REPLACE));
        Chemistry=CaelumCraftingStation(Actor.Spawn('CaelumAlchemyStation',(0,0,0),NO_REPLACE));
        Barrel.CraftingRoomGroup=471;Bench.CraftingRoomGroup=471;Chemistry.CraftingRoomGroup=471;
        Material(user,95,1000);Material(user,98,20);
        let water=CaelumWaterContainer(user.FindInventory('CaelumCanteenLarge'));
        if(water==null)water=CaelumWaterContainer(user.GiveInventoryType('CaelumCanteenLarge'));
        water.InMagicBox=false;water.Amount=1;water.WaterLiters=2;water.WaterQuality=0;
        user.OnNativeInventoryChanged();CaelumWorldClock.Get(user,true);
        Barrel.CollectCraftingNetwork(user,user.BeginCraftingNetworkScan());user.OpenCraftingNetwork(Barrel);
    }
    void Transactions(CaelumPlayer user)
    {
        Setup(user);
        let record=user.GetPersistentCharacterState(true);
        let water=CaelumWaterContainer(user.FindInventory('CaelumCanteenLarge'));
        record.KnownRecipeTiers[176]=0;record.KnownCraftingRecipe[176]=false;
        Check(!CaelumFermentationService.Begin(user,Barrel,1),"unknown recipe rejects batch");
        record.LearnCraftingRecipe(176,1);
        Check(CaelumFermentationMenu.Active(user),"native barrel opens dedicated menu");
        Check(!CaelumFermentationService.Begin(user,Barrel,0),"zero-litre transaction rejected");
        Check(!CaelumFermentationService.Begin(user,Barrel,3403),"over-capacity transaction rejected");
        water.WaterQuality=CaelumWaterQuality.BIOLOGICAL;
        Check(!CaelumFermentationService.Begin(user,Barrel,1),"nonpotable input rejected");
        water.WaterQuality=0;water.InMagicBox=true;
        Check(!CaelumFermentationService.Begin(user,Barrel,1),"boxed water rejected");water.InMagicBox=false;
        Check(!CaelumFermentationService.Begin(user,Barrel,3),"insufficient water rejects all consumption");
        Check(user.CountRawCraftingMaterial(95,1)==1000 && user.CountRawCraftingMaterial(98,1)==20 && Near(water.WaterLiters,2),"failed starts preserve supplies");
        Chemistry.CraftingRoomGroup=472;
        Check(!CaelumFermentationService.Begin(user,Barrel,1),"starting without Chemistry rejected");
        Chemistry.CraftingRoomGroup=471;
        Check(CaelumFermentationService.Begin(user,Barrel,2),"two litre batch starts");
        let batch=Barrel.Batch;
        Check(batch.RemainingUnits==2000 && batch.WorkingLiters==2 && Near(batch.ReadyAt-batch.StartedAt,259200),"approved recipe scales volume not duration");
        Check(user.CountRawCraftingMaterial(95,1)==500 && user.CountRawCraftingMaterial(98,1)==10 && Near(water.WaterLiters,0.4),"only approved ingredients consumed once");
        Check(water.Owner==user && water.Amount==1 && !user.CraftingTaskActive,"container survives and fermentation is unattended");
        Check(!CaelumFermentationService.Begin(user,Barrel,1) && user.CountRawCraftingMaterial(95,1)==500,"occupied barrel prevents duplicate start");
        Check(!CaelumFermentationService.Withdraw(user,Barrel,1),"early collection rejected");
        Chemistry.CraftingRoomGroup=472;Bench.CraftingRoomGroup=472;user.CraftingSessionValidationTics=0;
        Check(user.RefreshActiveCraftingStationSession(false) && user.CraftingMenuOpen,"disconnected barrel remains accessible");
        let clock=CaelumWorldClock.Get(user);clock.AdvanceTics(CaelumWorldClock.TicsPerDay()*3);
        Check(batch.Ready(CaelumFermentationService.Now(user)),"world-time skip completes disconnected batch");
        Check(!CaelumFermentationService.Withdraw(user,Barrel,2001),"over-withdrawal rejected atomically");
        double capacity=user.DerivedStats.CarryCapacity;user.DerivedStats.CarryCapacity=0;
        Check(!CaelumFermentationService.Withdraw(user,Barrel,1) && batch.RemainingUnits==2000,"capacity failure retains entire output");
        user.DerivedStats.CarryCapacity=capacity;
        Check(CaelumFermentationService.Withdraw(user,Barrel,375),"partial collection without Chemistry or Workbench");
        Check(batch.RemainingUnits==1625 && batch.Occupied && user.CountRawCraftingMaterial(96,1)==375,"exact partial output leaves barrel occupied");
        Check(CaelumFermentationService.Withdraw(user,Barrel,1625),"final collection clears barrel");
        Check(!batch.Occupied && user.CountRawCraftingMaterial(96,1)==2000,"no lost or duplicated output");
        Check(!CaelumFermentationService.Withdraw(user,Barrel,1),"repeated collection cannot duplicate output");
        Check(!CaelumFermentationService.Begin(user,Barrel,1),"empty barrel still requires Chemistry for new batch");
        Chemistry.CraftingRoomGroup=471;Bench.CraftingRoomGroup=471;water.WaterLiters=1;
        Check(CaelumFermentationService.Begin(user,Barrel,1),"second batch starts after reconnect");
        int before=user.CountRawCraftingMaterial(95,1),generation=batch.Generation;
        CaelumFermentationMenu.Act(user,2,0,generation-1);
        Check(batch.Occupied && !user.FermentationMenu.ConfirmDiscard,"stale action cannot discard current batch");
        CaelumFermentationMenu.Act(user,2,0,generation);
        Check(batch.Occupied && user.FermentationMenu.ConfirmDiscard,"discard requires explicit second action");
        CaelumFermentationMenu.Act(user,2,0,generation);
        Check(!batch.Occupied && user.CountRawCraftingMaterial(95,1)==before,"discard returns no ingredients");
        Check(CaelumFermentationService.Bind(user,Barrel)==batch && record.FermentationBatches.Size()==1,"repeated binding shares one ledger object");
        user.CloseCraftingStationSession();user.SetCraftingJournalState(false);Result();
    }
    void Seed(CaelumPlayer user)
    {
        Setup(user);user.GetPersistentCharacterState(true).LearnCraftingRecipe(176,1);
        Check(CaelumFermentationService.Begin(user,Barrel,1),"persistent transaction seed");
        user.CloseCraftingStationSession();user.SetCraftingJournalState(false);Result();
    }
    void Resume(CaelumPlayer user)
    {
        Check(Barrel!=null && Barrel.Batch!=null && Barrel.Batch.Occupied,"native save retains station batch");
        if(Barrel==null || Barrel.Batch==null){Result();return;}
        let batch=CaelumFermentationService.Bind(user,Barrel);
        Check(batch==user.GetPersistentCharacterState(true).FermentationBatches[0].Batch,"native save preserves shared ledger identity");
        Check(batch.RemainingUnits==1000 && user.CountRawCraftingMaterial(95,1)==750,"native save preserves spent ingredients and yield");
        CaelumWorldClock.Get(user).AdvanceTics(CaelumWorldClock.TicsPerDay()*3);
        Chemistry.CraftingRoomGroup=472;
        Check(CaelumFermentationService.Withdraw(user,Barrel,500),"native load can collect partial result");
        Check(batch.RemainingUnits==500 && batch.Occupied,"native load leaves exact remainder");Result();
    }
    void Processes(CaelumPlayer user)
    {
        Setup(user);user.SetOrigin((0,-64,0),false);user.OpenCraftingNetwork(Chemistry);
        let record=user.GetPersistentCharacterState(true);
        let water=CaelumWaterContainer(user.FindInventory('CaelumCanteenLarge'));
        for(int recipe=177;recipe<CaelumChemistryData.FIRST_RECIPE+CaelumChemistryData.RECIPE_COUNT;recipe++)
        {
            user.CancelCraftingTask();record.LearnCraftingRecipe(recipe,1);water.WaterLiters=2;
            for(int slot=0;CaelumChemistryData.InputMaterial(recipe,slot)>=0;slot++)
                Material(user,CaelumChemistryData.InputMaterial(recipe,slot),CaelumChemistryData.InputUnits(recipe,slot));
            user.CraftingSelectionRecipe=recipe;user.CraftingProcessingBatchIndex=0;
            user.CraftingSelectionTier=1;user.CraftingEfficiencyIndex=recipe%3;user.RefreshCraftingPreview();
            let existing=CaelumChemistryCrafting.Existing(user,recipe);int before=existing==null?0:existing.Amount;
            user.BeginSelectedCraftingTask();
            bool started=user.CraftingTaskActive && user.CraftingTaskKind==CaelumConstants.CRAFTING_TASK_CHEMISTRY;
            Check(started,String.Format("recipe %d native task starts",recipe));
            if(!started){Console.Printf("CA471B DETAIL recipe=%d action=%d missing=%d known=%d",recipe,user.LastCraftingAction,user.CraftingMissingStationType,user.CraftingSelectedRecipeKnown);continue;}
            double expected=CaelumChemistryData.Seconds(recipe)*(CaelumChemistryData.UsesDexterity(recipe)?100.0/user.GetCraftingDexterityPercent():1);
            Check(Near(user.CraftingTaskTotalSeconds,expected) && Near(CaelumTimeSkipState.TaskSeconds(user)*CaelumThermalRuntime.WorldTicSeconds()*TICRATE,expected),String.Format("recipe %d approved duration and wait forecast",recipe));
            let brew=CaelumChemistryTaskState.Find(user);
            if(brew.Containers.Size()>0)
            {
                let reserved=brew.Containers[0];double beforeWater=reserved.WaterLiters;
                Check(CaelumWaterBoiling.Locked(reserved) && !reserved.EmptyWater(user) && reserved.CreateTossable(1)==null,String.Format("recipe %d native water guards",recipe));
                Check(Near(beforeWater,reserved.WaterLiters),String.Format("recipe %d start reserves without consuming water",recipe));
            }
            if(recipe==177 || recipe==186)
            {
                user.CancelCraftingTask();
                Check(user.CountRawCraftingMaterial(CaelumChemistryData.InputMaterial(recipe,0),1)==CaelumChemistryData.InputUnits(recipe,0)
                    && Near(water.WaterLiters,2),"cancel releases recipe supplies without spending");
                user.BeginSelectedCraftingTask();
            }
            user.CraftingTaskRemainingSeconds=CaelumThermalRuntime.WorldTicSeconds()/2;user.UpdateCraftingTask();
            existing=CaelumChemistryCrafting.Existing(user,recipe);
            Check(!user.CraftingTaskActive && existing!=null && existing.Amount==before+CaelumChemistryData.OutputUnits(recipe),String.Format("recipe %d exact native output",recipe));
            bool spent=true;
            for(int slot=0;CaelumChemistryData.InputMaterial(recipe,slot)>=0;slot++)
                if(user.CountRawCraftingMaterial(CaelumChemistryData.InputMaterial(recipe,slot),1)!=0)spent=false;
            Check(spent && Near(water.WaterLiters,2-CaelumChemistryData.WaterLiters(recipe)),String.Format("recipe %d exact inputs and water consumption",recipe));
        }
        Check(Near(CaelumMaterialRules.UnitWeight(100),0.01) && Near(CaelumMaterialRules.UnitWeight(102)+0.01,10*CaelumMaterialRules.UnitWeight(79)),"abstract carbine batch mass conserved");
        Check(Near(CaelumMaterialRules.UnitWeight(103)+0.01,10*CaelumMaterialRules.UnitWeight(80)),"abstract shotgun batch mass conserved");
        Check(Near(CaelumEconomyRules.GetConsumableUnitBaseValue(2),Min(CaelumChemistryEconomy.RecipeUnitValue(186),CaelumChemistryEconomy.RecipeUnitValue(189))),"identical energy drink uses cheapest recipe value");
        Check(Near(CaelumEconomyRules.GetMaterialUnitBaseValue(100),25),"abstract charge ingredient value plus 25 percent");
        user.CloseCraftingStationSession();user.SetCraftingJournalState(false);Result();
    }
    void Catalogue(CaelumPlayer user)
    {
        let record=user.GetPersistentCharacterState(true);
        record.LearnCraftingRecipe(168,1);record.LearnCraftingRecipe(169,1);
        record.RecipeBookVersion=12;record.KnownRecipeTiers[176]=7;record.KnownCraftingRecipe[176]=true;
        record.EnsureTierRecipeBook();
        Check(record.KnowsCraftingRecipe(168,1) && record.KnowsCraftingRecipe(169,1),"recipe migration preserves iodine and support knowledge");
        Check(!record.KnowsCraftingRecipe(176,1) && record.RecipeBookVersion==13,"new recipes migrate locked");
        record.LearnCraftingRecipe(176,1);record.EnsureTierRecipeBook();
        Check(record.KnowsCraftingRecipe(176,1),"recipe migration is idempotent");
        let vendor=CaelumCityMerchant(Actor.Spawn('CaelumCityMerchant',(400,120,0),NO_REPLACE));
        vendor.Category=0;vendor.StockInitialized=true;vendor.CatalogueRevision=1;vendor.RestockRevision=1;
        CaelumChemistryCatalogue.Ensure(vendor,user);
        int products=vendor.Products.Size(),imports=0;
        for(int i=0;i<products;i++)
        {
            let p=vendor.Products[i];if(p.Kind!=CaelumShopProduct.MATERIAL)continue;
            imports++;Check(p.Stock!=null && p.Stock.Amount==CaelumChemistryData.ImportStock(p.ItemType),String.Format("material %d approved native import stock",p.ItemType));
            Check(Near(CaelumShopRestock.Duration(p,user),CaelumWorldClock.TicsPerDay()/(p.Target*0.001)),String.Format("material %d approved daily import recovery",p.ItemType));
        }
        Check(imports==7,"exactly seven approved source imports");
        vendor.Products[0].Stock.Amount--;
        CaelumChemistryCatalogue.Ensure(vendor,user);
        Check(vendor.Products.Size()==products && vendor.Products[0].Stock.Amount==vendor.Products[0].Target-1,"repeat catalogue migration neither duplicates nor restocks");
        let library=CaelumCityMerchant(Actor.Spawn('CaelumCityMerchant',(400,-120,0),NO_REPLACE));
        library.Category=CaelumShopCatalogue.LIBRARY;library.StockInitialized=true;library.CatalogueRevision=1;library.RestockRevision=1;
        CaelumChemistryCatalogue.Ensure(library,user);
        bool books=library.Products.Size()==CaelumChemistryData.RECIPE_COUNT;
        for(int i=0;i<library.Products.Size();i++)
        {
            let p=library.Products[i];if(p.Stock==null || p.Stock.Amount!=10 || p.BaseValue<=0 || p.Tier!=1)books=false;
        }
        Check(books,"all twenty-two recipe books have ten copies and positive derived prices");
        CaelumChemistryCatalogue.Ensure(library,user);
        Check(library.Products.Size()==22,"library migration is idempotent");
        Result();
    }
    void Restock(CaelumPlayer user)
    {
        CaelumWorldClock.Get(user,true);
        for(int recipe=176;recipe<198;recipe++)
        {
            let quote=new("CaelumRecipeQuote");quote.Build(user,recipe,1);
            Check(Near(quote.ManufactureSeconds,CaelumChemistryData.Seconds(recipe)),String.Format("recipe %d merchant uses approved base seconds",recipe));
            Check(Near(quote.ManufactureTics,CaelumChemistryData.Seconds(recipe)*CaelumWorldClock.TicsPerHour()/3600.0),String.Format("recipe %d merchant uses world calendar",recipe));
        }
        let vendor=CaelumCityMerchant(Actor.Spawn('CaelumCityMerchant',(400,120,0),NO_REPLACE));
        vendor.Category=0;vendor.EnsureStock(user);
        int potions=0;
        for(int i=0;i<vendor.Products.Size();i++)
        {
            let product=vendor.Products[i];
            if(product.Kind!=CaelumShopProduct.SIMPLE || !CaelumChemistryData.IsRecipe(product.Recipe))continue;
            potions++;product.Stock.Amount=product.Target-1;
        }
        Check(potions==9,"nine existing potion products gain manufacturing recipes");
        CaelumShopRestock.Sync(vendor,user,true);
        double latest=0;
        for(int i=0;i<vendor.Products.Size();i++)
            if(vendor.Products[i].NextDue>latest)latest=vendor.Products[i].NextDue;
        Check(latest>CaelumScheduleState.Now(user),"new production schedules future output without immediate refill");
        CaelumWorldClock.Get(user).AdvanceTics(int(Ceil(latest-CaelumScheduleState.Now(user))));
        CaelumShopRestock.Sync(vendor,user,true);
        bool full=true;
        for(int i=0;i<vendor.Products.Size();i++)
        {
            let product=vendor.Products[i];
            if(product.Kind==CaelumShopProduct.SIMPLE && CaelumChemistryData.IsRecipe(product.Recipe)
                && product.Stock.Amount!=product.Target)full=false;
        }
        Check(full,"calendar catch-up replenishes exactly the missing potion units");
        let arms=CaelumCityMerchant(Actor.Spawn('CaelumCityMerchant',(400,-120,0),NO_REPLACE));
        arms.Category=2;arms.EnsureStock(user);int kits=0;
        for(int i=0;i<arms.Products.Size();i++)
        {
            let product=arms.Products[i];
            if(product.Kind!=CaelumShopProduct.MATERIAL || (product.ItemType!=79 && product.ItemType!=80))continue;
            kits++;Check(product.Recipe>=0 && CaelumShopRestock.Duration(product,user)>0,"kit product has a positive manufactured duration");
            product.Stock.Amount=0;product.Stock=null;
            Check(product.Produce(arms,user,1) && product.Stock!=null && product.Stock.Amount==1,"empty manufactured material can replenish");
        }
        Check(kits==2,"both cartridge kit products migrate");Result();
    }
    void WaterSeed(CaelumPlayer user)
    {
        Setup(user);user.SetOrigin((0,-64,0),false);user.OpenCraftingNetwork(Chemistry);
        int recipe=189;user.GetPersistentCharacterState(true).LearnCraftingRecipe(recipe,1);
        for(int slot=0;CaelumChemistryData.InputMaterial(recipe,slot)>=0;slot++)
            Material(user,CaelumChemistryData.InputMaterial(recipe,slot),CaelumChemistryData.InputUnits(recipe,slot));
        user.CraftingSelectionRecipe=recipe;user.CraftingSelectionTier=1;
        user.CraftingProcessingBatchIndex=0;user.RefreshCraftingPreview();user.BeginSelectedCraftingTask();
        Check(user.CraftingTaskActive && CaelumChemistryTaskState.Find(user).Containers.Size()==1,"water reservation seeded for native save");Result();
    }
    void WaterResume(CaelumPlayer user)
    {
        let brew=CaelumChemistryTaskState.Find(user);
        Check(user.CraftingTaskActive && brew!=null && brew.Recipe==189,"native load restores attended task");
        if(brew==null){Result();return;}
        let water=CaelumWaterContainer(user.FindInventory('CaelumCanteenLarge'));
        Check(brew.Containers.Size()==1 && brew.Containers[0]==water && CaelumWaterBoiling.Locked(water),"native load restores exact reserved container identity");
        Check(Near(water.WaterLiters,2),"saved unfinished task has spent no water");
        let existing=CaelumChemistryCrafting.Existing(user,189);int before=existing==null?0:existing.Amount;
        user.CraftingTaskRemainingSeconds=CaelumThermalRuntime.WorldTicSeconds()/2;user.UpdateCraftingTask();
        existing=CaelumChemistryCrafting.Existing(user,189);
        Check(!user.CraftingTaskActive && existing!=null && existing.Amount==before+1 && Near(water.WaterLiters,1.8),"loaded task completes with exact output and water consumption");
        Check(!CaelumWaterBoiling.Locked(water),"loaded task releases its container");Result();
    }
    void Preview(CaelumPlayer user,int phase)
    {
        if(phase==0){Setup(user);user.GetPersistentCharacterState(true).LearnCraftingRecipe(176,1);}
        else if(phase==1){CaelumFermentationService.Begin(user,Barrel,1);CaelumFermentationMenu.Get(user);}
        else if(phase==2){CaelumWorldClock.Get(user).AdvanceTics(CaelumWorldClock.TicsPerDay()*3);CaelumFermentationMenu.Get(user);}
        else if(phase==3){WaterSeed(user);user.CancelCraftingTask();}
        else if(phase==4)
        {
            user.CloseCraftingStationSession();user.SetCraftingJournalState(false);
            user.SetOrigin((-160,-260,0),false);user.Angle=90;user.Pitch=12;
            for(int i=0;i<4;i++)
            {
                int id=i==0?99:100+i;
                let item=user.CreateDetachedMaterialStack(id,1,1);
                item.SetOrigin((-220+i*40,-160,24),false);item.bNoGravity=true;
                Check(item!=null && item.Scale.X>0,String.Format("native supply model %d",id));
            }
        }
        Check(true,String.Format("preview phase %d ready",phase));Result();
    }
    void Destination(CaelumPlayer user)
    {
        let record=user.GetPersistentCharacterState(true);
        Check(level.MapName=="CABAT2" && record.FermentationBatches.Size()==1,"native travel carries barrel ledger");
        if(record.FermentationBatches.Size()>0)
        {
            let batch=record.FermentationBatches[0].Batch;
            Check(record.FermentationBatches[0].MapName=="CABAT1" && batch.Occupied && batch.RemainingUnits==1000,"away map retains origin batch");
            CaelumWorldClock.Get(user).AdvanceTics(CaelumWorldClock.TicsPerDay()*3);
            Check(batch.Ready(CaelumFermentationService.Now(user)),"batch finishes while source map is absent");
        }
        Result();
    }
    void Returned(CaelumPlayer user)
    {
        user.SetOrigin((224,-64,0),false);user.CombatTimeRemaining=0;
        Barrel=CaelumFermentationStation(Actor.Spawn('CaelumFermentationStation',(224,0,0),NO_REPLACE));
        let batch=CaelumFermentationService.Bind(user,Barrel);
        Check(level.MapName=="CABAT1" && batch.Occupied && batch.RemainingUnits==1000,"reconstructed map restores original barrel contents");
        Check(CaelumFermentationService.Withdraw(user,Barrel,600),"returned character collects without reconstructing Chemistry");
        Check(batch.RemainingUnits==400 && user.CountRawCraftingMaterial(96,1)==600,"travel return keeps exact partial remainder");Result();
    }
    void Shared(CaelumPlayer user)
    {
        Setup(user);user.GetPersistentCharacterState(true).LearnCraftingRecipe(176,1);
        let other=playeringame[1]?CaelumPlayer(players[1].mo):null;
        Check(other!=null,"native second player exists");if(other==null){Result();return;}
        other.SetOrigin((224,64,0),false);other.CombatTimeRemaining=0;other.bInvulnerable=true;
        Check(CaelumFermentationService.Begin(user,Barrel,1),"first player starts shared batch");
        let shared=CaelumFermentationService.Bind(other,Barrel);
        Check(shared==Barrel.Batch && shared==other.GetPersistentCharacterState(true).FermentationBatches[0].Batch,"second player binds same live batch object");
        CaelumWorldClock.Get(user).AdvanceTics(CaelumWorldClock.TicsPerDay()*3);
        Check(CaelumFermentationService.Withdraw(other,Barrel,500),"different player collects shared output");
        Check(shared.RemainingUnits==500 && other.CountRawCraftingMaterial(96,1)==500,"shared output credited exactly once to collector");
        Check(CaelumFermentationService.Discard(other,Barrel) && !Barrel.Batch.Occupied,"different player may discard shared remainder");
        user.CloseCraftingStationSession();user.SetCraftingJournalState(false);Result();
    }
    override void ConsoleProcess(ConsoleEvent e)
    {
        if(e.Name!="ca471i_keys")return;
        let menu=CaelumLiveMenu(Menu.GetCurrentMenu());if(menu==null)return;
        int phase=e.Args[0],scan=CaelumMenuPointer.KeyScan(99);
        if(phase==0)menu.Stroke(CaelumMenuPointer.KeyScan(118),118,"v");
        else if(phase==1){menu.Stroke(InputEvent.Key_Home);menu.Stroke(InputEvent.Key_Enter);}
        else if(phase==2)
        {menu.Key(InputEvent.Type_KeyDown,scan,99,"c",false);menu.Key(InputEvent.Type_KeyDown,scan,99,"c",false);}
        else if(phase==3)
        {menu.Key(InputEvent.Type_KeyUp,scan,99,"c",false);menu.Stroke(scan,99,"c");}
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let user=CaelumPlayerAuthority.FromNetworkPlayer(e.Player);if(user==null)return;
        if(e.Name=="ca471i_transactions")Transactions(user);
        else if(e.Name=="ca471i_seed")Seed(user);
        else if(e.Name=="ca471i_resume")Resume(user);
        else if(e.Name=="ca471i_processes")Processes(user);
        else if(e.Name=="ca471i_catalogue")Catalogue(user);
        else if(e.Name=="ca471i_destination")Destination(user);
        else if(e.Name=="ca471i_returned")Returned(user);
        else if(e.Name=="ca471i_shared")Shared(user);
        else if(e.Name=="ca471i_restock")Restock(user);
        else if(e.Name=="ca471i_water_seed")WaterSeed(user);
        else if(e.Name=="ca471i_water_resume")WaterResume(user);
        else if(e.Name=="ca471i_preview")Preview(user,e.Args[0]);
        else if(e.Name=="ca471i_keycheck")
        {
            int phase=e.Args[0];
            if(phase==0)Check(user.FermentationMenu.Liters==101,"live menu V adds one hundred without opening Explore");
            else if(phase==1)Check(Barrel.Batch.Occupied && Barrel.Batch.WorkingLiters==1,"live menu Home and Enter start one litre");
            else if(phase==2)Check(Barrel.Batch.Occupied && user.FermentationMenu.ConfirmDiscard,"held discard key cannot confirm by autorepeat");
            else if(phase==3)Check(!Barrel.Batch.Occupied,"released and pressed discard key confirms");
            Result();
        }
        else if(e.Name=="ca471i_go")level.ChangeLevel("CABAT2",0,CHANGELEVEL_NOINTERMISSION);
        else if(e.Name=="ca471i_back")level.ChangeLevel("CABAT1",0,CHANGELEVEL_NOINTERMISSION);
    }
}
