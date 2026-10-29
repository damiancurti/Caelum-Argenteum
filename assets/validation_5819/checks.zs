class CA410CookingChecks : CA410FoodChecks
{
    CaelumKitchenCounterStation Counter;
    CaelumCraftingStation Cooker;
    double SavedContamination;
    double FastStartStamp;
    double MenuStartStamp;
    void Result(){Console.Printf("CA410C RESULT passed=%d failed=%d",Passed,Failed);}
    CaelumSpecialInventoryItem Material(CaelumPlayer u,int id,int amount,double contamination=0)
    {
        let item=u.FindNativeSpecialItem(CaelumConstants.EQUIPMENT_KIND_MATERIAL,id,1);
        if(item==null){item=u.CreateDetachedMaterialStack(id,1,amount);item.AttachToOwner(u);}
        item.Amount=amount;item.InMagicBox=false;
        if(CaelumFoodInventory.IsFood(item))
        {
            CaelumFoodInventory.SetLots(item,null);
            let lots=CaelumFoodInventory.Prepare(item);lots.Lots[0].BaseContamination=contamination;
        }
        return item;
    }
    CaelumWaterContainer Water(CaelumPlayer u)
    {
        let water=CaelumWaterContainer(u.FindInventory('CaelumCanteenLarge'));
        if(water==null)water=CaelumWaterContainer(u.GiveInventoryType('CaelumCanteenLarge'));
        water.Amount=1;water.InMagicBox=false;water.WaterLiters=2;water.WaterQuality=0;return water;
    }
    void PrepareCooking(CaelumPlayer u,int recipe)
    {
        Setup(u);u.CancelCraftingTask();u.SetOrigin((64,64,0),false);u.Vel=(0,0,0);u.Angle=90;
        if(Cooker!=null)Cooker.Destroy();
        Cooker=CaelumCraftingStation(Actor.Spawn(recipe==205?'CaelumKitchenOvenStation':'CaelumKitchenStoveStation',(64,128,0),NO_REPLACE));
        Cooker.CraftingRoomGroup=410;
        for(int slot=0;CaelumCookingData.InputMaterial(recipe,slot)>=0;slot++)
            Material(u,CaelumCookingData.InputMaterial(recipe,slot),CaelumCookingData.InputGrams(recipe,slot)+100,slot==0?30:10);
        Water(u);u.OnNativeInventoryChanged();
        u.GetPersistentCharacterState(true).LearnCraftingRecipe(recipe,1);
        Cooker.CollectCraftingNetwork(u,u.BeginCraftingNetworkScan());u.OpenCraftingNetwork(Cooker);
        u.CraftingSelectionRecipe=recipe;u.CraftingSelectionTier=1;u.RefreshCraftingPreview();
    }
    void Cooking(CaelumPlayer u)
    {
        for(int recipe=205;recipe<209;recipe++)
        {
            PrepareCooking(u,recipe);
            let water=CaelumWaterContainer(u.FindInventory('CaelumCanteenLarge'));
            int id=CaelumCookingData.InputMaterial(recipe,0),before=u.CountRawCraftingMaterial(id,1);
            Check(u.CraftingSelectedInfrastructureAvailable,"kitchen recipe infrastructure available without Workbench");
            Check(CaelumCookingCrafting.Begin(u),String.Format("recipe %d begins",recipe));
            Check(Near(u.CraftingTaskRemainingSeconds,CaelumCookingData.Seconds(recipe)),"thermal duration uses approved world seconds");
            Check(u.CountRawCraftingMaterial(id,1)==before && Near(water.WaterLiters,2),"reservation consumes nothing at start");
            let input=u.FindNativeSpecialItem(CaelumConstants.EQUIPMENT_KIND_MATERIAL,id,1);
            CaelumFoodClock.Get(input).Stamp-=600;
            u.CancelCraftingTask();CaelumFoodInventory.Reconcile(input);
            Check(input.Amount==before && CaelumFoodInventory.GetLots(input).OldestContamination()>30,"cancel preserves ingredients and elapsed deterioration");
            Check(Near(water.WaterLiters,2) && !CaelumCookingCrafting.Locked(water),"cancel releases unspent water");
            Check(CaelumCookingCrafting.Begin(u),"same supplies can resume cooking");
            double expected;Check(CaelumCookingCrafting.FoodContamination(u,recipe,expected),"food inheritance can be computed before consumption");
            u.CraftingTaskRemainingSeconds=0;u.CompleteCraftingTask();
            let output=CaelumConsumableItem(u.FindInventory(CaelumMealData.ItemClass(CaelumCookingData.Meal(recipe))));
            Check(output!=null && output.Amount==10 && output.FoodLots.Units()==10,"completion delivers ten native portions with ten lots units");
            Check(output!=null && Near(output.FoodLots.OldestContamination(),expected),"finished food retains weighted ingredient deterioration");
            Check(u.CountRawCraftingMaterial(id,1)==100,"completion consumes exact ingredient grams once");
            Check(Near(water.WaterLiters,2-CaelumCookingData.WaterLiters(recipe)),"completion consumes only recipe water and retains canteen");
            Check(!CaelumCookingCrafting.Complete(u),"repeated completion cannot duplicate food");
            if(output!=null)output.Destroy();
        }
        PrepareCooking(u,208);
        let water=CaelumWaterContainer(u.FindInventory('CaelumCanteenLarge'));water.WaterQuality=CaelumWaterQuality.BIOLOGICAL;
        Check(!CaelumCookingCrafting.Begin(u) && !u.CraftingTaskActive,"contaminated water cannot start puchero");
        water.WaterQuality=0;Check(CaelumCookingCrafting.Begin(u),"potable replacement permits cooking");
        u.SetOrigin((700,700,0),false);double remaining=u.CraftingTaskRemainingSeconds;
        u.UpdateCraftingTask();Check(u.CraftingTaskRemainingSeconds==remaining,"unattended cooking cannot progress");
        u.CancelCraftingTask();Result();
    }
    void ProofSeed(CaelumPlayer u)
    {
        Setup(u);u.CancelCraftingTask();u.SetOrigin((64,64,0),false);u.Vel=(0,0,0);
        Counter=CaelumKitchenCounterStation(Actor.Spawn('CaelumKitchenCounterStation',(64,128,0),NO_REPLACE));
        for(int slot=0;slot<3;slot++)Material(u,CaelumMealData.InputMaterial(21,slot),CaelumMealData.InputGrams(21,slot)*2,slot==0?40:0);
        let water=Water(u);u.OnNativeInventoryChanged();
        u.GetPersistentCharacterState(true).LearnCraftingRecipe(205,1);
        Counter.CollectCraftingNetwork(u,u.BeginCraftingNetworkScan());u.OpenCraftingNetwork(Counter);
        Check(CaelumProofingUI.Active(u),"counter opens dedicated shared proofing interface");
        Check(CaelumProofing.Begin(u,Counter),"proofing consumes one approved batch");
        Check(Near(water.WaterLiters,1.58) && water.Amount==1,"proofing uses 420mL and retains canteen");
        Check(Counter.Batch.Lots.Units()==1141 && !u.CraftingTaskActive,"one 1141g batch ferments unattended");
        Check(Near(Counter.Batch.Lots.OldestContamination(),40.0*700/721),"water does not dilute inherited contamination");
        Check(!CaelumProofing.Begin(u,Counter) && !CaelumProofing.Withdraw(u,Counter),"occupied and unready counter rejects duplicate or early collection");
        Check(CaelumTimeSkipState.OpenMenu(u),"calendar wait available at occupied mansion counter");
        CaelumTimeSkipState.FinishSkip(u,"CA_SKIP_CANCELLED",true);
        SavedContamination=Counter.Batch.Lots.OldestContamination();
        u.CloseCraftingStationSession();u.SetCraftingJournalState(false);Result();
    }
    void ProofResume(CaelumPlayer u,bool away=false)
    {
        Setup(u);u.SetOrigin((64,64,0),false);u.Vel=(0,0,0);
        Check(Counter!=null && Counter.Batch!=null && Counter.Batch.Occupied,"native persistence retains counter and batch");
        if(Counter==null || Counter.Batch==null){Result();return;}
        if(!away)CaelumWorldClock.Get(u).AdvanceTics(CaelumWorldClock.TicsPerHour()*2);
        let batch=CaelumProofing.Bind(u,Counter);
        Check(batch.Ready(Counter.MenuNow) && batch.Lots.OldestContamination()>SavedContamination,"world time completes proof and preserves ageing");
        double contamination=batch.Lots.OldestContamination();
        Check(CaelumProofing.Withdraw(u,Counter),"ready batch collected as portable dough");
        let dough=u.FindNativeSpecialItem(CaelumConstants.EQUIPMENT_KIND_MATERIAL,113,1);
        Check(dough!=null && dough.Amount==1141 && Near(CaelumFoodInventory.GetLots(dough).OldestContamination(),contamination),"dough quantity and age transferred exactly");
        Check(!batch.Occupied && !CaelumProofing.Withdraw(u,Counter),"collection frees counter without duplication");
        Check(!CaelumKitchenData.Edible(113) && Near(CaelumMaterialRules.UnitWeight(113)*1141,1.141),"dough is a nonedible 1141g ingredient");
        Check(CaelumProofing.Begin(u,Counter),"free counter accepts remaining ingredients");Result();
    }
    void ProofMenuStart(CaelumPlayer u)
    {
        ProofSeed(u);
        Counter.CollectCraftingNetwork(u,u.BeginCraftingNetworkScan());u.OpenCraftingNetwork(Counter);
        MenuStartStamp=Counter.MenuNow;
        CaelumWorldClock.Get(u).AdvanceTics(CaelumWorldClock.TicsPerHour()*2);
    }
    void ProofMenuDone(CaelumPlayer u)
    {
        Check(CaelumProofingUI.Active(u),"proofing menu remains open during unattended time");
        Check(Counter.MenuNow>=MenuStartStamp+7200 && Counter.Batch.Ready(Counter.MenuNow),
            "open menu refreshes clock and collection readiness without reopening");
        Result();
    }
    void Guards(CaelumPlayer u)
    {
        PrepareCooking(u,208);let water=CaelumWaterContainer(u.FindInventory('CaelumCanteenLarge'));
        Check(CaelumCookingCrafting.Begin(u),"late-failure task begins");
        Check(CaelumWaterBoiling.Locked(water),"native water operations respect cooking reservation");
        water.WaterLiters=0;u.CraftingTaskRemainingSeconds=0;u.CompleteCraftingTask();
        Check(u.FindInventory('CaelumPuchero')==null && u.CountRawCraftingMaterial(109,1)==400,"late water loss cannot consume food or create output");
        PrepareCooking(u,207);Check(CaelumCookingCrafting.Begin(u),"timing task begins");
        double remaining=u.CraftingTaskRemainingSeconds;u.UpdateCraftingTask();
        Check(Near(remaining-u.CraftingTaskRemainingSeconds,CaelumThermalRuntime.WorldTicSeconds()),"native active cooking advances one world tic");
        u.CancelCraftingTask();Result();
    }
    void Fast(CaelumPlayer u)
    {
        PrepareCooking(u,207);u.CurrentHunger=100;u.CurrentThirst=100;u.CurrentSleep=100;
        FastStartStamp=CaelumFermentationService.Now(u);u.BeginSelectedCraftingTask();
        Check(CaelumCookingCrafting.Active(u),"real crafting dispatcher starts selected fish recipe");
        Check(Near(CaelumTimeSkipState.TaskSeconds(u)*CaelumThermalRuntime.WorldTicSeconds()*TICRATE,1800),"wait forecast uses thirty world minutes");
        Check(CaelumTimeAdvanceState.Toggle(u),"existing fast-attended control accepts cooking");Result();
    }
    void FastDone(CaelumPlayer u)
    {
        let output=CaelumConsumableItem(u.FindInventory('CaelumRoastFish'));
        Console.Printf("CA410C FAST active=%d output=%d action=%d remaining=%.4f elapsed=%.4f reason=%s hunger=%.4f",u.CraftingTaskActive,output!=null?output.Amount:-1,u.LastCraftingAction,u.CraftingTaskRemainingSeconds,CaelumFermentationService.Now(u)-FastStartStamp,CaelumTimeAdvanceState.Get(u).LastReason,u.CurrentHunger);
        Check(!u.CraftingTaskActive && output!=null && output.Amount==9 && u.FindInventory('CaelumHungerRegeneration')!=null,
            "accelerated cooking finishes; existing automatic meal service consumes one of ten portions");
        Check(CaelumFermentationService.Now(u)-FastStartStamp>=1800,"full approved cooking time elapsed in world clock");Result();
    }
    void TaskSeed(CaelumPlayer u)
    {
        PrepareCooking(u,208);Check(CaelumCookingCrafting.Begin(u),"saveable cooking task starts");
        u.CraftingTaskRemainingSeconds=900;u.CloseCraftingStationSession();u.SetCraftingJournalState(false);Result();
    }
    void TaskResume(CaelumPlayer u)
    {
        Setup(u);Check(u.CraftingTaskActive && u.CraftingTaskKind==CaelumConstants.CRAFTING_TASK_COOKING,"native save retains active cooking task kind");
        let task=CaelumCookingTaskState.FindCooking(u);
        Check(task!=null && task.Recipe==208 && task.Containers.Size()==1 && Near(u.CraftingTaskRemainingSeconds,900),"save retains ingredients, container references and exact paused duration");
        if(task==null){Result();return;}
        Check(u.ValidateCraftingTaskReservations() && Near(task.Containers[0].WaterLiters,2),"saved reservations do not consume supplies early");
        u.CraftingTaskRemainingSeconds=0;u.CompleteCraftingTask();
        let output=CaelumConsumableItem(u.FindInventory('CaelumPuchero'));
        Check(output!=null && output.Amount==10,"saved task finishes once");Result();
    }
    void Library(CaelumPlayer u)
    {
        Setup(u);let record=u.GetPersistentCharacterState(true);
        record.RecipeBookVersion=16;record.KnownRecipeTiers[204]=1;record.KnownCraftingRecipe[204]=true;
        record.KnownRecipeTiers[205]=7;record.KnownCraftingRecipe[205]=true;record.CookingMaterialSchemaRevision=0;
        record.MainM00RepairSupply[113]=999;record.EnsureRecipeBookInitialized();
        Check(record.RecipeBookVersion==17 && record.KnowsCraftingRecipe(204,1) && !record.KnowsCraftingRecipe(205,1),"additive recipe migration preserves previous learning and clears only new entries");
        Check(record.CookingMaterialSchemaRevision==1 && record.MainM00RepairSupply[113]==0,"new material quest cells initialized once");
        record.LearnCraftingRecipe(205,1);record.EnsureRecipeBookInitialized();
        Check(record.KnowsCraftingRecipe(205,1),"repeated schema migration preserves newly learned bread");
        let vendor=CaelumCityMerchant(Actor.Spawn('CaelumCityMerchant',(200,128,0),NO_REPLACE));vendor.Category=CaelumShopCatalogue.LIBRARY;vendor.EnsureStock(u);
        int count=0;
        for(int i=0;i<vendor.Products.Size();i++)
        {
            let product=vendor.Products[i];if(product.Kind!=CaelumShopProduct.BOOK || !CaelumMealData.IsRecipe(product.Recipe))continue;
            count++;Check(product.Tier==1 && product.Stock!=null && product.Stock.Amount==10,"library stocks ten copies of each cooking recipe");
            if(product.Stock!=null)product.Stock.Amount=3;
        }
        Check(count==4,"exactly four new single-tier cooking books");
        vendor.EnsureStock(u);bool retained=true;
        for(int i=0;i<vendor.Products.Size();i++)
        {let product=vendor.Products[i];if(product.Kind==CaelumShopProduct.BOOK && CaelumMealData.IsRecipe(product.Recipe) && (product.Stock==null || product.Stock.Amount!=3))retained=false;}
        Check(retained,"repeated catalogue synchronization does not refill sold books");Result();
    }
    void Mansion(CaelumPlayer u)
    {
        Setup(u);Check(CaelumMansionKitchen.Prepare(),"three stations fit current mansion geometry");
        for(int id=0;id<3;id++)
        {
            vector3 p=CaelumKitchenFurnitureData.Position(id);
            let it=BlockThingsIterator.CreateFromPos(p.X,p.Y,p.Z,64,64,false);CaelumKitchenStation found;int count=0;
            while(it.Next()){let s=CaelumKitchenStation(it.thing);if(s!=null && s.KitchenKind()==id && (s.Pos-p).Length()<1){found=s;count++;}}
            Check(count==1 && found!=null,"one physical station at planned position");
            if(found==null)continue;
            u.SetOrigin(p+(0,-64,0),false);u.Angle=90;u.Pitch=25;u.Vel=(0,0,0);
            Check(u.TestMobjLocation() && found.CanReachFrom(u),"station approach is clear and visible");
            found.CollectCraftingNetwork(u,u.BeginCraftingNetworkScan());u.OpenCraftingNetwork(found);
            Check(u.CraftingMenuOpen && u.ActiveCraftingStationActor==found,"actual station opens usable interface");
            u.CloseCraftingStationSession();u.SetCraftingJournalState(false);
        }
        Check(CaelumMansionKitchen.Prepare(),"installation repeats idempotently");
        u.SetOrigin((1560,160,0),false);u.Angle=90;u.Pitch=15;u.Vel=(0,0,0);
        let camera=Actor.Spawn('CA410KitchenCamera',(1560,160,60),NO_REPLACE);camera.Angle=90;camera.Pitch=15;u.player.camera=camera;
        Console.Printf("CA410C POSITION %.1f %.1f %.1f floor=%.1f ceiling=%.1f camera=%s",u.Pos.X,u.Pos.Y,u.Pos.Z,u.FloorZ,u.CeilingZ,u.player.camera.GetClassName());Result();
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=="ca410c_core")Cooking(u);
        else if(e.Name=="ca410c_seed")ProofSeed(u);
        else if(e.Name=="ca410c_resume")ProofResume(u,e.Args[0]!=0);
        else if(e.Name=="ca410c_menustart")ProofMenuStart(u);
        else if(e.Name=="ca410c_menudone")ProofMenuDone(u);
        else if(e.Name=="ca410c_away"){CaelumWorldClock.Get(u).AdvanceTics(CaelumWorldClock.TicsPerHour()*2);}
        else if(e.Name=="ca410c_guards")Guards(u);
        else if(e.Name=="ca410c_taskseed")TaskSeed(u);
        else if(e.Name=="ca410c_taskresume")TaskResume(u);
        else if(e.Name=="ca410c_library")Library(u);
        else if(e.Name=="ca410c_mansion")Mansion(u);
        else if(e.Name=="ca410c_fast")Fast(u);
        else if(e.Name=="ca410c_fastdone")FastDone(u);
        else if(e.Name=="ca410c_view"){PrepareCooking(u,208);u.player.camera=u;Result();}
        else Super.NetworkProcess(e);
    }
}
class CA410KitchenCamera : Actor
{
    Default {Radius 1;Height 1;+NOBLOCKMAP +NOGRAVITY +NOINTERACTION}
    States {Spawn:TNT1 A -1;Stop;}
}
