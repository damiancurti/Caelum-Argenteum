// Fixtures aislados: no añaden valores a las reglas de producción.
class CA472Checks : EventHandler
{
    int Passed,Failed;
    void Check(bool ok,String label)
    {if(ok)Passed++;else Failed++;Console.Printf("CA472 %s %s",ok?"PASS":"FAIL",label);}
    bool Near(double a,double b,double tolerance=0.000001){return Abs(a-b)<tolerance;}
    void Result(){Console.Printf("CA472 RESULT passed=%d failed=%d map=%s",Passed,Failed,level.MapName);}
    void Material(CaelumPlayer user,int kind,int amount)
    {
        let item=user.FindNativeSpecialItem(CaelumConstants.EQUIPMENT_KIND_MATERIAL,kind,1);
        if(item==null){item=user.CreateDetachedMaterialStack(kind,1,amount);item.AttachToOwner(user);}
        item.Amount=amount;item.InMagicBox=false;
    }
    void Setup(CaelumPlayer user)
    {
        user.bInvulnerable=true;user.CharacterCreationComplete=true;user.CreationWizardOpen=false;
        user.SetOrigin((0,-128,0),false);user.Vel=(0,0,0);user.Angle=90;
        CaelumWorldClock.Get(user,true);
        let thermal=CaelumThermalBody.Get(user,true);thermal.Available=true;thermal.AmbientAirC=20;thermal.AmbientWindKmh=0;
        Material(user,CaelumConstants.MATERIAL_YERBA_MATE,1000);
    }
    void Basics(CaelumPlayer user)
    {
        Setup(user);
        for(int variant=0;variant<CaelumMateData.COUNT;variant++)
        {
            let mate=CaelumMateItem(user.GiveInventoryType(CaelumMateData.ItemClass(variant)));
            Check(mate!=null && mate.GetConsumableType()==17+variant,"native mate identity");
            if(mate==null)continue;
            Check(Near(mate.GetUnitWeight(),CaelumMateData.EmptyMass(variant)),"empty physical mass includes fixed straw");
            Check(mate.LoadYerba(user) && mate.UsesRemaining==20,"fresh yerba load provides twenty uses");
            Check(!mate.LoadYerba(user),"fresh load cannot overwrite existing yerba");
            Check(mate.DiscardYerba(user) && !mate.YerbaLoaded && mate.UsesRemaining==0,"discard does not recover yerba");
            Check(CaelumMatePhysics.Cool(variant,80,20,0,3600,.1)>20
                && CaelumMatePhysics.Cool(variant,80,20,0,3600,.1)<80,"cooling approaches ambient without overshoot");
        }
        Result();
    }

    CaelumMateItem Fresh(CaelumPlayer user,int variant=0)
    {
        let mate=CaelumMateItem(user.FindInventory(CaelumMateData.ItemClass(variant)));
        if(mate==null)mate=CaelumMateItem(user.GiveInventoryType(CaelumMateData.ItemClass(variant)));
        mate.InMagicBox=false;mate.WaterLiters=0;mate.YerbaLoaded=false;mate.UsesRemaining=0;mate.Amount=1;
        mate.SyncTemperature(user);return mate;
    }
    void Hot(CaelumPlayer user,CaelumMateItem mate,double temp=75)
    {mate.SyncTemperature(user);mate.TemperatureC=temp;mate.WaterLiters=CaelumMateData.WaterCapacity(mate.Variant());}
    void Transactions(CaelumPlayer user)
    {
        Setup(user);
        let water=CaelumWaterContainer(user.GiveInventoryType('CaelumCanteenLarge'));
        water.Amount=1;water.InMagicBox=false;water.WaterLiters=2;water.WaterQuality=0;
        water.AdvanceTemperature(user,0);water.WaterTemperatureC=80;
        let mate=Fresh(user);int yerba=user.CountRawCraftingMaterial(CaelumConstants.MATERIAL_YERBA_MATE,1);
        Check(!mate.Pour(user,water) && Near(water.WaterLiters,2),"pour requires yerba without spending water");
        Check(mate.LoadYerba(user) && user.CountRawCraftingMaterial(CaelumConstants.MATERIAL_YERBA_MATE,1)==yerba-20,"exact approved yerba paid once");
        double old=mate.TemperatureC;
        Check(mate.Pour(user,water) && Near(mate.WaterLiters,.06) && Near(water.WaterLiters,1.94),"pour transfers useful capacity and retains canteen");
        Check(mate.TemperatureC>old && mate.TemperatureC<80 && water.Owner==user && water.Amount==1,"thermal mix warms vessel and retains source identity");
        Check(Near(mate.GetUnitWeight(),CaelumMateData.EmptyMass(0)+.08),"loaded mass includes water and yerba");
        Check(!mate.Pour(user,water) && Near(water.WaterLiters,1.94),"full mate rejects overfill atomically");
        Hot(user,mate,86);user.CurrentThirst=50;
        Check(!mate.Drink(user) && mate.UsesRemaining==20 && Near(mate.WaterLiters,.06),"above 85 degrees blocks drinking without consumption");
        Hot(user,mate,59);
        Check(mate.Drink(user) && mate.UsesRemaining==20 && mate.WaterLiters==0,"cold water hydrates without spending hot use");
        let recovery=CaelumMateRecovery(user.FindInventory('CaelumMateRecovery'));double ratio=0;
        if(recovery==null){Check(false,"native recovery exists");Result();return;}
        for(int i=0;i<CaelumMateRecovery.QUEUE_SIZE;i++)ratio+=recovery.PendingResources[i];
        Check(ratio==0,"cold dose queues hydration only");
        user.CurrentThirst=100;
        for(int i=0;i<20;i++){Hot(user,mate);Check(mate.Drink(user),String.Format("hot use %d succeeds even at full thirst",i+1));}
        Check(mate.UsesRemaining==0 && mate.YerbaLoaded,"twenty hot uses leave washed yerba loaded");
        double before=0;for(int i=0;i<CaelumMateRecovery.QUEUE_SIZE;i++)before+=recovery.PendingResources[i];
        Hot(user,mate);user.CurrentThirst=50;
        Check(mate.Drink(user) && mate.UsesRemaining==0,"washed yerba still permits hydration");
        ratio=0;for(int i=0;i<CaelumMateRecovery.QUEUE_SIZE;i++)ratio+=recovery.PendingResources[i];
        Check(Near(before,ratio),"washed drink adds no resource benefits");
        Check(mate.Pour(user,water) && mate.UsesRemaining==0,"water refill never renews hot uses");
        mate.EmptyWater(user);water.WaterQuality=CaelumWaterQuality.BIOLOGICAL;
        Check(!mate.Pour(user,water) && mate.WaterLiters==0,"biological water rejected");
        water.WaterQuality=CaelumWaterQuality.CHEMICAL;
        Check(!mate.Pour(user,water),"chemical water rejected");water.WaterQuality=0;water.InMagicBox=true;
        Check(!mate.Pour(user,water),"boxed source rejected");water.InMagicBox=false;mate.InMagicBox=true;
        Check(!mate.Pour(user,water) && !mate.Drink(user) && !mate.DiscardYerba(user),"boxed mate cannot be used");mate.InMagicBox=false;
        Check(mate.DiscardYerba(user) && mate.LoadYerba(user) && mate.UsesRemaining==20,"discard then reload renews exactly twenty uses");
        Hot(user,mate);mate.UsesRemaining=7;
        let tossed=CaelumMateItem(mate.CreateTossable(1));
        Check(tossed!=null && tossed.UsesRemaining==7 && tossed.YerbaLoaded && Near(tossed.WaterLiters,.06),"native dropped copy preserves complete contents");
        for(int v=0;v<3;v++)
        {
            Check(CaelumMatePhysics.Cool(v,80,20,5,60,.1)<CaelumMatePhysics.Cool(v,80,20,0,60,.1),"wind speeds cooling");
            Check(Near(CaelumMatePhysics.Cool(v,80,20,0,0,.1),80),"zero elapsed time preserves temperature");
        }
        let prepared=Fresh(user,1);prepared.LoadYerba(user);SelectMate(user,prepared);
        let second=CaelumWaterContainer(user.GiveInventoryType('CaelumBottleLarge'));second.WaterLiters=1;second.WaterQuality=0;second.AdvanceTemperature(user,0);
        water.WaterQuality=0;SelectMate(user,prepared);CaelumMateSession.OpenSelected(user);let session=CaelumMateSession.Find(user);
        let selected=session.Source();selected.InMagicBox=true;double heldWater=water.WaterLiters,heldSecond=second.WaterLiters;
        CaelumMateSession.Act(user,3);
        Check(prepared.WaterLiters==0 && Near(water.WaterLiters,heldWater) && Near(second.WaterLiters,heldSecond),"stale selected source cannot silently consume another bottle");
        session.Open=false;selected.InMagicBox=false;
        prepared.WaterLiters=.15;Hot(user,prepared);user.CurrentThirst=100;
        Check(CaelumQuickUse.Available(user,prepared) && user.UseInventory(prepared),"native quick use drinks hot mate at full thirst");
        Check(prepared.Owner==user && prepared.Amount==1 && prepared.WaterLiters==0,"quick use retains reusable vessel");
        Result();
    }
    void Crafting(CaelumPlayer user)
    {
        Setup(user);user.SetOrigin((0,-64,0),false);
        let bench=CaelumCraftingStation(Actor.Spawn('CaelumWorkbenchStation',(0,0,0),NO_REPLACE));
        let fine=CaelumCraftingStation(Actor.Spawn('CaelumFineToolsBenchStation',(112,0,0),NO_REPLACE));
        let jeweler=CaelumCraftingStation(Actor.Spawn('CaelumJewelerBenchStation',(224,0,0),NO_REPLACE));
        bench.CraftingRoomGroup=472;fine.CraftingRoomGroup=472;jeweler.CraftingRoomGroup=472;
        bench.CollectCraftingNetwork(user,user.BeginCraftingNetworkScan());user.OpenCraftingNetwork(bench);
        let record=user.GetPersistentCharacterState(true);
        Material(user,CaelumMateData.DRY_GOURD,1000);Material(user,CaelumConstants.MATERIAL_BRONZE_INGOT,1000);
        record.LearnCraftingRecipe(198,1);user.CraftingSelectionRecipe=198;user.CraftingSelectionTier=1;
        fine.CraftingRoomGroup=999;bench.CollectCraftingNetwork(user,user.BeginCraftingNetworkScan());user.OpenCraftingNetwork(bench);user.RefreshCraftingPreview();user.BeginSelectedCraftingTask();
        Check(!user.CraftingTaskActive && user.CraftingMissingStationType==CaelumConstants.CRAFTING_STATION_FINE_TOOLS_BENCH,"native crafting requires connected Fine Tools");
        fine.CraftingRoomGroup=472;jeweler.CraftingRoomGroup=999;
        record.LearnCraftingRecipe(199,1);user.CraftingSelectionRecipe=199;
        bench.CollectCraftingNetwork(user,user.BeginCraftingNetworkScan());user.OpenCraftingNetwork(bench);user.CraftingSelectionRecipe=199;user.RefreshCraftingPreview();user.BeginSelectedCraftingTask();
        Check(!user.CraftingTaskActive && user.CraftingMissingStationType==CaelumConstants.CRAFTING_STATION_JEWELER_BENCH,"clad mate requires connected Jeweler Bench");
        jeweler.CraftingRoomGroup=472;bench.CollectCraftingNetwork(user,user.BeginCraftingNetworkScan());user.OpenCraftingNetwork(bench);
        record.LearnCraftingRecipe(176,1);record.RecipeBookVersion=13;record.KnownRecipeTiers[198]=7;record.EnsureTierRecipeBook();
        Check(record.RecipeBookVersion==14 && record.KnowsCraftingRecipe(176,1) && !record.KnowsCraftingRecipe(198,1),"recipe migration keeps chemistry and locks new mates");
        for(int v=0;v<3;v++)
        {
            int recipe=198+v;record.LearnCraftingRecipe(recipe,1);user.CraftingSelectionRecipe=recipe;user.CraftingSelectionTier=1;
            Material(user,CaelumMateData.PrimaryMaterial(v),1000);
            if(CaelumMateData.SecondaryGrams(v)>0)Material(user,CaelumMateData.SecondaryMaterial(v),1000);
            Material(user,CaelumConstants.MATERIAL_BRONZE_INGOT,1000);
            for(int efficiency=0;efficiency<3;efficiency++)
            {
                user.CraftingEfficiencyIndex=efficiency;user.RefreshCraftingPreview();int factor=efficiency==0?4:efficiency==1?2:1;
                Check(user.CraftingBasicRequired==CaelumMateData.PrimaryGrams(v)*factor
                    && user.CraftingTierRequired==CaelumMateData.SecondaryGrams(v)*factor
                    && user.CraftingSilverRequired==CaelumMateData.BronzeGrams(v)*factor,"all efficiency modes apply existing waste once");
            }
            user.CraftingEfficiencyIndex=2;user.RefreshCraftingPreview();
            Check(user.CraftingSelectedInfrastructureAvailable && user.CraftingBasicRequired==CaelumMateData.PrimaryGrams(v)
                && user.CraftingTierRequired==CaelumMateData.SecondaryGrams(v) && user.CraftingSilverRequired==CaelumMateData.BronzeGrams(v),"approved materials at standard efficiency");
            user.BeginSelectedCraftingTask();Check(user.CraftingTaskActive,"native mate craft starts");
            if(!user.CraftingTaskActive){Console.Printf("CA472 DETAIL action=%d missing=%d",user.LastCraftingAction,user.CraftingMissingStationType);continue;}
            user.CancelCraftingTask();Check(user.CountRawCraftingMaterial(CaelumMateData.PrimaryMaterial(v),1)==1000,"cancel does not spend materials");
            user.BeginSelectedCraftingTask();user.CraftingTaskRemainingSeconds=0.000001;user.UpdateCraftingTask();
            let mate=CaelumMateItem(user.FindInventory(CaelumMateData.ItemClass(v)));
            Check(mate!=null && mate.Amount==1 && !user.CraftingTaskActive,"native completion produces one empty mate");
            Check(user.CountRawCraftingMaterial(CaelumMateData.PrimaryMaterial(v),1)==1000-CaelumMateData.PrimaryGrams(v)
                && user.CountRawCraftingMaterial(CaelumConstants.MATERIAL_BRONZE_INGOT,1)==980,"craft pays body and fixed bronze straw once");
            user.BeginSelectedCraftingTask();Check(!user.CraftingTaskActive,"duplicate carried mate cannot consume a second recipe");
        }
        user.CloseCraftingStationSession();user.SetCraftingJournalState(false);Result();
    }
    void Catalogue(CaelumPlayer user)
    {
        Setup(user);let vendor=CaelumCityMerchant(Actor.Spawn('CaelumCityMerchant',(0,-64,0),NO_REPLACE));
        vendor.Category=0;vendor.StockInitialized=true;vendor.CatalogueRevision=1;vendor.RestockRevision=1;
        CaelumMateCatalogue.Ensure(vendor,user);
        Check(vendor.Products.Size()==4,"three mate products and one gourd import");
        vendor.Products[0].Stock.Amount=777;vendor.MateCatalogueRevision=0;CaelumMateCatalogue.Ensure(vendor,user);
        Check(vendor.Products.Size()==4 && vendor.Products[0].Stock.Amount==777,"partial migration retry neither duplicates nor refills stock");
        for(int i=1;i<vendor.Products.Size();i++)
        {
            let p=vendor.Products[i];Check(p.Stock.Amount==3 && p.Recipe==197+i && CaelumShopRestock.Duration(p,user)>0,"mate has three copies and positive recipe restock time");
            let used=CaelumMateItem(Actor.Spawn(p.NativeClass,(0,0,0),NO_REPLACE));used.YerbaLoaded=true;used.UsesRemaining=7;used.WaterLiters=.01;used.AttachToOwner(vendor);
            Check(vendor.Accepts(used) && !p.Matches(used) && CaelumCityTradeSession.Stack(vendor,used)==null,"used mate remains individual and never becomes fresh restock");
        }
        let library=CaelumCityMerchant(Actor.Spawn('CaelumCityMerchant',(0,64,0),NO_REPLACE));library.Category=CaelumShopCatalogue.LIBRARY;
        library.StockInitialized=true;library.CatalogueRevision=1;library.RestockRevision=1;CaelumMateCatalogue.Ensure(library,user);
        bool books=library.Products.Size()==3;for(int i=0;i<library.Products.Size();i++)if(library.Products[i].Stock.Amount!=10)books=false;
        Check(books,"ten copies of each new recipe in library");Result();
    }
    bool RecoveryRunning;
    int RecoveryAge;
    void RecoveryStart(CaelumPlayer user)
    {
        Setup(user);RecoveryRunning=true;RecoveryAge=0;user.SurvivalResourcesInitialized=false;
        user.CaelumMaximumHealth=1000;user.health=500;user.player.health=500;user.CurrentThirst=10;
        user.CurrentAnima=500;user.CurrentAir=500;
        let power=CaelumMateRecovery(user.GiveInventoryType('CaelumMateRecovery'));power.AddDose(20,.02);
    }
    override void WorldTick()
    {
        let user=CaelumPlayer(players[consoleplayer].mo);if(user==null)return;
        if(level.MapName=="CAMATE2" && level.maptime==5)Resume(user,true);
        if(!RecoveryRunning)return;
        user.SurvivalResourcesInitialized=false;user.CaelumMaximumHealth=1000;
        user.DerivedStats.MaximumAnima=1000;user.DerivedStats.MaximumAir=1000;
        user.DerivedStats.HealthRegenerationPerSecond=0;user.DerivedStats.AnimaRegenerationPerSecond=0;user.DerivedStats.AirRegenerationPerSecond=0;
        RecoveryAge++;
        if(RecoveryAge==2){user.health=500;user.player.health=500;user.CurrentAnima=500;user.CurrentAir=500;user.CurrentThirst=10;}
        if(RecoveryAge==176)
        {
            let power=CaelumMateRecovery(user.FindInventory('CaelumMateRecovery'));
            Console.Printf("CA472 DETAIL age=%d cursor=%d health=%d anima=%.6f air=%.6f thirst=%.6f",RecoveryAge,power==null?-1:power.Cursor,user.health,user.CurrentAnima,user.CurrentAir,user.CurrentThirst);
            Check(power!=null && Near(user.CurrentAnima,510),"five of ten first-dose pulses after five real seconds");
            if(power!=null)power.AddDose(40,.04);
        }
        if(RecoveryAge==352)Check(Near(user.CurrentAnima,540),"overlap preserves first dose and adds five second-dose pulses");
        if(RecoveryAge==530)
        {
            Console.Printf("CA472 DETAIL final health=%d anima=%.6f air=%.6f thirst=%.6f",user.health,user.CurrentAnima,user.CurrentAir,user.CurrentThirst);
            Check(user.FindInventory('CaelumMateRecovery')==null,"power expires after last scheduled pulse");
            Check(user.health==560 && Near(user.CurrentAnima,560) && Near(user.CurrentAir,560),"all ten pulses of each dose recover exact resources");
            Check(Near(user.CurrentThirst,70),"both doses hydrate without replacing earlier remainder");
            RecoveryRunning=false;Result();
        }
    }


    void SelectMate(CaelumPlayer user,CaelumMateItem mate)
    {user.EquipmentSelectionKind=CaelumConstants.EQUIPMENT_KIND_CONSUMABLE;user.EquipmentSelectionConsumableType=mate.GetConsumableType();user.InvSel=mate;}
    void Preview(CaelumPlayer user,int variant)
    {
        Setup(user);CaelumInventoryService.GrantMagicBoxFromPalomo(user,false);
        for(int i=0;i<3;i++)Fresh(user,i);
        let water=CaelumWaterContainer(user.FindInventory('CaelumCanteenLarge'));
        if(water==null)water=CaelumWaterContainer(user.GiveInventoryType('CaelumCanteenLarge'));
        water.Amount=1;water.InMagicBox=false;water.WaterLiters=2;water.WaterQuality=0;water.AdvanceTemperature(user,0);water.WaterTemperatureC=80;
        let cold=CaelumWaterContainer(user.FindInventory('CaelumBottleLarge'));
        if(cold==null)cold=CaelumWaterContainer(user.GiveInventoryType('CaelumBottleLarge'));
        cold.Amount=1;cold.InMagicBox=false;cold.WaterLiters=1;cold.WaterQuality=0;cold.AdvanceTemperature(user,0);cold.WaterTemperatureC=20;
        let mate=CaelumMateItem(user.FindInventory(CaelumMateData.ItemClass(Clamp(variant,0,2))));
        user.OnNativeInventoryChanged();SelectMate(user,mate);CaelumMateSession.OpenSelected(user);
        Check(CaelumMateSession.Active(user) && CaelumMateSession.Find(user).Sources.Size()==2,"native preparation panel with two potable sources");Result();
    }
    void KeysCheck(CaelumPlayer user,int phase)
    {
        let session=CaelumMateSession.Find(user);let mate=session==null?null:session.Mate;
        if(mate==null){Check(false,"key sequence retains mate");Result();return;}
        if(phase==0)Check(mate.YerbaLoaded && mate.UsesRemaining==20,"R key loads yerba through network action");
        if(phase==1)Check(mate.WaterLiters>0,"F key pours from selected source");
        if(phase==2)Check(mate.YerbaLoaded && session.ConfirmDiscard,"held C cannot discard yerba");
        if(phase==3)Check(!mate.YerbaLoaded && !session.ConfirmDiscard,"second distinct C discards yerba");
        if(phase==4)Check(!CaelumMateSession.Active(user),"Tab returns from mate panel");
        Result();
    }

    void Workshop(CaelumPlayer user)
    {
        Setup(user);CaelumInventoryService.GrantMagicBoxFromPalomo(user,false);user.SetOrigin((0,-64,0),false);
        let bench=CaelumCraftingStation(Actor.Spawn('CaelumWorkbenchStation',(0,0,0),NO_REPLACE));
        let fine=CaelumCraftingStation(Actor.Spawn('CaelumFineToolsBenchStation',(112,0,0),NO_REPLACE));
        let jeweler=CaelumCraftingStation(Actor.Spawn('CaelumJewelerBenchStation',(224,0,0),NO_REPLACE));
        bench.CraftingRoomGroup=472;fine.CraftingRoomGroup=472;jeweler.CraftingRoomGroup=472;
        for(int variant=0;variant<3;variant++)
        {
            Material(user,CaelumMateData.PrimaryMaterial(variant),1000);
            Material(user,CaelumMateData.SecondaryMaterial(variant),1000);user.GetPersistentCharacterState(true).LearnCraftingRecipe(198+variant,1);
        }
        Material(user,CaelumConstants.MATERIAL_BRONZE_INGOT,1000);
        bench.CollectCraftingNetwork(user,user.BeginCraftingNetworkScan());user.OpenCraftingNetwork(bench);
        user.CraftingSelectionRecipe=198;user.CraftingSelectionTier=1;user.CraftingEfficiencyIndex=2;user.RefreshCraftingPreview();
        Check(user.CraftingSelectedInfrastructureAvailable,"manual workshop ready with approved recipes");Result();
    }
    void ShopSetup(CaelumPlayer user)
    {
        user.CharacterCreationComplete=true;user.CreationWizardOpen=false;user.bInvulnerable=true;
        CaelumInventoryService.GrantMagicBoxFromPalomo(user,false);let coins=user.GiveInventoryType('CaelumGoldCoin');coins.Amount=100;
        Material(user,CaelumConstants.MATERIAL_YERBA_MATE,1000);
        let water=CaelumWaterContainer(user.GiveInventoryType('CaelumCanteenLarge'));water.WaterLiters=2;water.WaterQuality=0;
        water.AdvanceTemperature(user,0);water.WaterTemperatureC=80;user.OnNativeInventoryChanged();
        Check(water.Owner==user,"MAP03 supplies ready without moving the player");Result();
    }
    void InventoryView(CaelumPlayer user)
    {
        let session=CaelumMateSession.Find(user);let mate=session==null?null:session.Mate;if(mate==null)return;session.Open=false;
        user.FormalInventoryFilter=0;user.RefreshFormalInventorySnapshot();
        for(int i=0;i<user.FormalInventoryEntryCount;i++)
            if(user.GetFormalInventoryEntryAt(i)==mate){user.FormalInventorySelectionIndex=i;break;}
        user.RefreshFormalInventorySnapshot();Check(CaelumMateSession.Selected(user)==mate,"native inventory selects mate details and icon");Result();
    }

    void MapChecks(CaelumPlayer user)
    {
        ShopSetup(user);let vendor=CaelumCityMerchant.Find(0);let library=CaelumCityMerchant.Find(34);
        Check(vendor!=null && library!=null,"authored MAP03 merchants present");
        if(vendor==null || library==null){Result();return;}
        vendor.EnsureStock(user);library.EnsureStock(user);
        for(int variant=0;variant<3;variant++)
        {
            int stock=0,books=0;
            for(Inventory item=vendor.Inv;item!=null;item=item.Inv)if(item.GetClassName()==CaelumMateData.ItemClass(variant))stock+=item.Amount;
            for(Inventory item=library.Inv;item!=null;item=item.Inv){let book=CaelumRecipeOffer(item);if(book!=null && book.Recipe==198+variant)books+=book.Amount;}
            Console.Printf("CA472 DETAIL MAP03 variant=%d stock=%d books=%d categories=%d/%d",variant,stock,books,vendor.Category,library.Category);
            Check(stock==3 && books==10,"authored shops contain exactly approved stock without duplicate seeding");
        }
        let mate=Fresh(user);mate.LoadYerba(user);Hot(user,mate,80);
        let thermal=CaelumThermalBody.Get(user);Check(thermal!=null && thermal.Available,"MAP03 supplies actual ambient climate");
        double ambient=thermal.AmbientAirC;CaelumWorldClock.Get(user).AdvanceTics(CaelumWorldClock.TicsPerHour()/60);mate.SyncTemperature(user);
        Check(mate.TemperatureC<80 && mate.TemperatureC>=ambient,"mate cools against actual MAP03 environment after world-time skip");Result();
    }

    void Gallery(CaelumPlayer user)
    {
        let session=CaelumMateSession.Find(user);if(session!=null)session.Open=false;user.SetOrigin((0,-96,0),false);user.Angle=90;user.Pitch=0;
        for(int variant=0;variant<3;variant++)
        {
            let item=Actor.Spawn(CaelumMateData.ItemClass(variant),(-40+variant*40,0,24),NO_REPLACE);
            item.Scale=(2,2);item.bNoGravity=true;Check(item!=null,String.Format("world mate model %d",variant));
        }
        Result();
    }

    override void ConsoleProcess(ConsoleEvent e)
    {
        if(e.Name!="ca472_keys")return;
        let menu=CaelumLiveMenu(Menu.GetCurrentMenu());if(menu==null)return;int phase=e.Args[0],scan=CaelumMenuPointer.KeyScan(99);
        if(phase==0)menu.Stroke(CaelumMenuPointer.KeyScan(114),114,"r");
        else if(phase==1)menu.Stroke(CaelumMenuPointer.KeyScan(102),102,"f");
        else if(phase==2){menu.Key(InputEvent.Type_KeyDown,scan,99,"c",false);menu.Key(InputEvent.Type_KeyDown,scan,99,"c",false);}
        else if(phase==3){menu.Key(InputEvent.Type_KeyUp,scan,99,"c",false);menu.Stroke(scan,99,"c");}
        else if(phase==4)menu.Stroke(InputEvent.Key_Tab);
    }
    void Transfer(CaelumPlayer user)
    {
        Setup(user);CaelumInventoryService.GrantMagicBoxFromPalomo(user,false);
        let coins=user.GiveInventoryType('CaelumGoldCoin');coins.Amount=100;
        let vendor=CaelumCityMerchant(Actor.Spawn('CaelumCityMerchant',(0,-64,0),NO_REPLACE));vendor.Category=0;vendor.WalletCopper=100000;
        CaelumMerchantCoordinator.OpenCityTrade(user,vendor);let session=user.CityTrade;
        if(session==null){Check(false,"merchant session opens");Result();return;}
        Inventory stock=null;
        for(int i=0;i<session.Rows.Size();i++)if(session.Rows[i] is 'CaelumMateGourd'){stock=session.Rows[i];session.Selection=i;break;}
        if(stock==null){Check(false,"mate listed in native shop");Result();return;}
        session.Refresh(user);session.Execute(user);
        let mate=CaelumMateItem(user.FindInventory('CaelumMateGourd'));
        Console.Printf("CA472 DETAIL purchase stock=%d mate=%d action=%d",stock.Amount,mate==null?-1:mate.Amount,user.LastPalomoMerchantAction);
        Check(mate!=null && mate.Amount==1 && stock.Amount==2,"buy one mate from three without consuming remaining stock");
        if(mate==null){Result();return;}
        mate.InMagicBox=false;mate.LoadYerba(user);Hot(user,mate);mate.UsesRemaining=7;
        user.PalomoMerchantMode=CaelumConstants.PALOMO_MERCHANT_MODE_SELL;session.Refresh(user);session.Selection=session.Rows.Find(mate);session.Refresh(user);session.Execute(user);
        Console.Printf("CA472 DETAIL sale stock=%d owner=%s action=%d",stock.Amount,mate.Owner.GetClassName(),user.LastPalomoMerchantAction);
        Check(mate.Owner==vendor && mate.UsesRemaining==7 && Near(mate.WaterLiters,.06) && stock.Amount==2,"selling retains individual contents without merging fresh stock");
        user.PalomoMerchantMode=CaelumConstants.PALOMO_MERCHANT_MODE_BUY;session.Refresh(user);session.Selection=session.Rows.Find(mate);session.Refresh(user);session.Execute(user);
        Check(mate.Owner==user && mate.YerbaLoaded && mate.UsesRemaining==7 && Near(mate.WaterLiters,.06),"buyback retains original native object and contents");
        user.ClosePalomoMerchant();SelectMate(user,mate);user.ToggleSelectedMagicBox();
        Check(mate.InMagicBox && mate.UsesRemaining==7 && Near(mate.WaterLiters,.06),"native box transfer preserves contents");
        user.ToggleSelectedMagicBox();Check(!mate.InMagicBox,"mate can return from box");
        let chest=CaelumStashChest(Actor.Spawn('CaelumStashChest',(0,-64,0),NO_REPLACE));chest.ChestUnlocked=true;
        CaelumContainerSession.Open(user,chest);
        Check(CaelumInventoryService.TransferContainerItem(user,chest,mate,1,true) && mate.Owner==chest,"native chest deposit retains mate identity");
        Check(CaelumInventoryService.TransferContainerItem(user,chest,mate,1,false) && mate.Owner==user
            && mate.UsesRemaining==7 && Near(mate.WaterLiters,.06),"native chest withdrawal preserves contents");
        CaelumContainerSession.Get(user).Close();Result();
    }
    void Seed(CaelumPlayer user)
    {
        Setup(user);let mate=Fresh(user,1);mate.LoadYerba(user);Hot(user,mate,72);mate.UsesRemaining=7;mate.WaterLiters=.04;
        let power=CaelumMateRecovery(user.GiveInventoryType('CaelumMateRecovery'));power.AddDose(10,.01);
        Check(mate.YerbaLoaded && mate.UsesRemaining==7,"save seed holds partial water and seven uses");Result();
    }
    void Resume(CaelumPlayer user,bool travel)
    {
        let mate=CaelumMateItem(user.FindInventory('CaelumMateSilver'));
        Check(mate!=null && mate.YerbaLoaded && mate.UsesRemaining==7 && Near(mate.WaterLiters,.04),travel?"map travel preserves mate contents":"native save preserves mate contents");
        if(mate==null){Result();return;}
        Check(mate.TemperatureReady && mate.TemperatureC<=72 && mate.TemperatureC>=20,"temperature metadata survives load or travel");
        let power=CaelumMateRecovery(user.FindInventory('CaelumMateRecovery'));
        Check(power!=null,"pending recovery survives load or travel");
        if(power!=null)
        {
            double total=0;for(int i=0;i<CaelumMateRecovery.QUEUE_SIZE;i++)total+=power.PendingHydration[i];
            Check(total>0 && total<=10,"pending doses are retained without duplication");
        }
        let thermal=CaelumThermalBody.Get(user,true);thermal.Available=true;thermal.AmbientAirC=20;thermal.AmbientWindKmh=0;
        double old=mate.TemperatureC;CaelumWorldClock.Get(user).AdvanceTics(CaelumWorldClock.TicsPerHour());mate.SyncTemperature(user);
        Check(mate.TemperatureC<old && mate.TemperatureC>=20 && mate.UsesRemaining==7,"world-time jump cools water without resetting uses");Result();
    }
    void LegacyResume(CaelumPlayer user)
    {
        let record=user.GetPersistentCharacterState(true);let water=CaelumWaterContainer(user.FindInventory('CaelumCanteenLarge'));
        Check(record.KnowsCraftingRecipe(176,1) && record.KnowsCraftingRecipe(169,1),"old chemistry and support knowledge preserved");
        Check(record.RecipeBookVersion==14 && !record.KnowsCraftingRecipe(198,1),"old save migrates new mate recipes locked");
        Check(water!=null && Near(water.WaterLiters,.8),"old water and container preserved");
        Check(user.CountRawCraftingMaterial(99,1)==123,"old chemistry supply preserved");
        record.LearnCraftingRecipe(198,1);record.EnsureTierRecipeBook();record.EnsureMateMaterialSchema();
        Check(record.KnowsCraftingRecipe(198,1),"repeat migration preserves newly learned mate");Result();
    }

    override void NetworkProcess(ConsoleEvent e)
    {
        let user=CaelumPlayerAuthority.FromNetworkPlayer(e.Player);if(user==null)return;
        if(e.Name=="ca472_basics")Basics(user);
        if(e.Name=="ca472_preview")Preview(user,e.Args[0]);
        if(e.Name=="ca472_workshop")Workshop(user);
        if(e.Name=="ca472_shop_setup")ShopSetup(user);
        if(e.Name=="ca472_map")MapChecks(user);
        if(e.Name=="ca472_inventory")InventoryView(user);
        if(e.Name=="ca472_gallery")Gallery(user);
        if(e.Name=="ca472_sample"){let session=CaelumMateSession.Find(user);if(session!=null){session.Mate.TemperatureC=e.Args[0];if(e.Args[1]>0)session.Mate.UsesRemaining=e.Args[1];}}
        if(e.Name=="ca472_keys_check")KeysCheck(user,e.Args[0]);
        if(e.Name=="ca472_transfer")Transfer(user);
        if(e.Name=="ca472_seed")Seed(user);
        if(e.Name=="ca472_travel"){Seed(user);level.ChangeLevel("CAMATE2",0,CHANGELEVEL_NOINTERMISSION,-1);}
        if(e.Name=="ca472_resume")Resume(user,false);
        if(e.Name=="ca472_destination")Resume(user,true);
        if(e.Name=="ca472_legacy_resume")LegacyResume(user);
        if(e.Name=="ca472_transactions")Transactions(user);
        if(e.Name=="ca472_crafting")Crafting(user);
        if(e.Name=="ca472_catalogue")Catalogue(user);
        if(e.Name=="ca472_recovery")RecoveryStart(user);
    }
}
