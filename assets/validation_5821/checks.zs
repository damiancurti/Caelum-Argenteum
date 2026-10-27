class CA411CookingChecks : CA410CookingChecks
{
    CaelumCampFire Fire;
    double SavedRemaining;
    double FastFuel;
    double TravelFuel;
    void CampResult(){Console.Printf("CA411C RESULT passed=%d failed=%d",Passed,Failed);}
    void PrepareCamp(CaelumPlayer u,int recipe)
    {
        Setup(u);u.CancelCraftingTask();u.CloseCraftingStationSession();u.SetCraftingJournalState(false);
        u.SetOrigin((64,64,0),false);u.Vel=(0,0,0);u.Angle=90;u.CurrentHunger=100;u.CurrentThirst=100;
        if(Fire!=null)Fire.Destroy();
        Fire=CaelumCampFire(Actor.Spawn('CaelumCampFire',(64,128,0),NO_REPLACE));Fire.Prepare();
        Fire.Title=CaelumLockRules.Character(u,true);Fire.Advance();Fire.Fuel.FuelGrams=10000;Fire.Fuel.Lit=true;
        for(int slot=0;CaelumCookingData.InputMaterial(recipe,slot)>=0;slot++)
        {
            int id=CaelumCookingData.InputMaterial(recipe,slot);if(id==CaelumConstants.MATERIAL_COAL)continue;
            Material(u,id,CaelumCookingData.InputGrams(recipe,slot)+100,slot==0?30:10);
        }
        Water(u);Material(u,CaelumConstants.MATERIAL_WOOD,20000);u.OnNativeInventoryChanged();
        u.GetPersistentCharacterState(true).LearnCraftingRecipe(recipe,1);
        if(recipe==208)
        {
            let pot=CaelumCampPot(u.GiveInventoryType('CaelumCampPot'));pot.Amount=1;pot.InMagicBox=false;pot.WaterLiters=0;
            Check(Fire.MountPot(u,pot),"empty puchero pot mounts through native interaction");
        }
    }
    void Burn(CaelumPlayer u,double seconds)
    {Fire.Advance();Fire.Stamp-=seconds;Fire.Advance();u.UpdateCraftingTask();}
    void CoreCamp(CaelumPlayer u)
    {
        for(int recipe=206;recipe<=208;recipe++)
        {
            PrepareCamp(u,recipe);
            int first=CaelumCookingData.InputMaterial(recipe,0);int quantity=u.CountRawCraftingMaterial(first,1);
            int coal=u.CountRawCraftingMaterial(CaelumConstants.MATERIAL_COAL,1);let water=Water(u);
            Check(CaelumCampCooking.Begin(u,Fire,recipe),"learned camp recipe starts with real wood and no stove");
            Check(CaelumCampCooking.Active(u) && Fire.Busy==u && Near(u.CraftingTaskRemainingSeconds,CaelumCookingData.Seconds(recipe)),"camp task owns fire and retains approved duration");
            Check(u.CountRawCraftingMaterial(first,1)==quantity && Near(water.WaterLiters,2),"food and carried water stay reserved until completion");
            Check(u.GetReservedCraftingMaterialUnits(CaelumConstants.MATERIAL_COAL,1)==0,"camp recipe reserves no mineral coal");
            double fuel=Fire.Fuel.FuelGrams;Burn(u,60);
            Check(Near(fuel-Fire.Fuel.FuelGrams,32) && Near(u.CraftingTaskRemainingSeconds,CaelumCookingData.Seconds(recipe)-60),"sixty actual burning seconds consume32g and advance sixty seconds");
            let food=u.FindNativeSpecialItem(CaelumConstants.EQUIPMENT_KIND_MATERIAL,first,1);
            CaelumFoodClock.Get(food).Stamp-=600;u.CancelCraftingTask();CaelumFoodInventory.Reconcile(food);
            Check(food.Amount==quantity && CaelumFoodInventory.GetLots(food).OldestContamination()>30,"cancel retains exact ingredients and accumulated age");
            Check(Fire.Busy==null && Near(Fire.Fuel.FuelGrams,fuel-32) && Near(water.WaterLiters,2),"cancel releases fire without refunding burned wood or spending water");
            Check(CaelumCampCooking.Begin(u,Fire,recipe),"cancelled batch can be restarted with retained ingredients");
            double contamination;Check(CaelumCookingCrafting.FoodContamination(u,recipe,contamination),"inherited food contamination is calculated from actual ingredients");
            fuel=Fire.Fuel.FuelGrams;Burn(u,CaelumCookingData.Seconds(recipe));
            let output=CaelumConsumableItem(u.FindInventory(CaelumMealData.ItemClass(CaelumCookingData.Meal(recipe))));
            Check(!u.CraftingTaskActive && output!=null && output.Amount==10,"real fuel-time completion produces ten portions");
            Check(output!=null && Near(output.FoodLots.OldestContamination(),contamination),"camp output retains food contamination");
            Check(Near(fuel-Fire.Fuel.FuelGrams,CaelumCampPhysics.FuelGrams(CaelumCookingData.Seconds(recipe))) && u.CountRawCraftingMaterial(CaelumConstants.MATERIAL_COAL,1)==coal,"completed batch spends approved wood only");
            Check(food.Amount==100 && Near(water.WaterLiters,2-CaelumCookingData.WaterLiters(recipe)),"exact recipe ingredients and carried potable water consumed once");
            Check(Fire.Busy==null && !CaelumCookingCrafting.Complete(u),"completed fire unlocks and cannot duplicate output");
            if(output!=null)output.Destroy();
        }
        CampResult();
    }
    void Interrupted(CaelumPlayer u,bool seed=false)
    {
        PrepareCamp(u,207);Fire.Fuel.FuelGrams=100;
        Check(CaelumCampCooking.Begin(u,Fire,207),"short fuel starts a saveable batch");
        Burn(u,300);SavedRemaining=1800-CaelumCampPhysics.SecondsFromFuel(100);
        Check(!Fire.Fuel.Lit && Near(Fire.Fuel.FuelGrams,0) && Near(u.CraftingTaskRemainingSeconds,SavedRemaining),"fuel exhaustion credits only actual burning time and retains remaining progress");
        u.UpdateCraftingTask();Check(CaelumCampCooking.Active(u) && Near(u.CraftingTaskRemainingSeconds,SavedRemaining),"empty fire pauses without cancelling or progressing");
        Check(CaelumCampFireSession.Show(u,Fire),"owner can open fuel controls during paused cooking");
        let session=CaelumCampFireSession.Find(u);session.Act(u,16);session.Selected=3000;session.Act(u,7);
        Check(Near(Fire.Fuel.FuelGrams,3000) && Near(u.CraftingTaskRemainingSeconds,SavedRemaining),"native menu refuels existing batch without restarting it");
        session.Act(u,1);let task=CaelumCookingTaskState.FindCooking(u);
        Check(Near(task.IgnitionSeconds,60) && !Fire.Fuel.Lit && Near(u.CraftingTaskRemainingSeconds,SavedRemaining),"native relight preserves cooking time and starts one minute");
        u.UpdateCraftingTask();Check(Near(task.IgnitionSeconds,60-CaelumThermalRuntime.WorldTicSeconds()) && Near(u.CraftingTaskRemainingSeconds,SavedRemaining),"relighting counts world time without cooking progress");
        if(seed){task.IgnitionSeconds=30;CampResult();return;}
        task.IgnitionSeconds=CaelumThermalRuntime.WorldTicSeconds();u.UpdateCraftingTask();
        Check(Fire.Fuel.Lit && task.IgnitionSeconds==0 && Near(u.CraftingTaskRemainingSeconds,SavedRemaining),"relight completes without spending its minute as heat");
        Burn(u,SavedRemaining);let output=CaelumConsumableItem(u.FindInventory('CaelumRoastFish'));
        Check(!u.CraftingTaskActive && output!=null && output.Amount==10,"resumed batch finishes without losing prior progress");
        CampResult();
    }
    void ResumeCamp(CaelumPlayer u)
    {
        let task=CaelumCookingTaskState.FindCooking(u);
        Check(CaelumCampCooking.Active(u) && task.Fire==Fire && Fire.Busy==u && task.CampRevision==1,"saved cooking restores exact fire and revision");
        Check(Near(u.CraftingTaskRemainingSeconds,SavedRemaining) && task.IgnitionSeconds>28 && task.IgnitionSeconds<=30,"save preserves paused cooking and relight phase");
        Check(u.GetReservedCraftingMaterialUnits(CaelumKitchenData.RAW_FISH,1)==1330,"saved native ingredient reservations remain active");
        task.IgnitionSeconds=CaelumThermalRuntime.WorldTicSeconds();u.UpdateCraftingTask();Burn(u,SavedRemaining);
        let output=CaelumConsumableItem(u.FindInventory('CaelumRoastFish'));
        Check(!u.CraftingTaskActive && output!=null && output.Amount==10,"saved batch resumes and completes once");CampResult();
    }
    void Guards(CaelumPlayer u)
    {
        PrepareCamp(u,208);let pot=Fire.Pot;
        Check(Fire.TakePot(u) && !CaelumCampCooking.Begin(u,Fire,208),"puchero rejects a carried pot instead of a mounted one");
        pot.InMagicBox=true;Check(!Fire.MountPot(u,pot),"boxed pot cannot be mounted");pot.InMagicBox=false;
        pot.WaterLiters=1;Check(Fire.MountPot(u,pot) && !CaelumCampCooking.Begin(u,Fire,208),"puchero rejects water already in the mounted pot");
        pot.WaterLiters=0;let water=Water(u);water.WaterQuality=CaelumWaterQuality.BIOLOGICAL;
        Check(!CaelumCampCooking.Begin(u,Fire,208) && Fire.Busy==null,"dirty carried water rejects the batch without claiming fire");
        water.WaterQuality=0;Check(CaelumCampCooking.Begin(u,Fire,208),"empty mounted pot and carried potable water permit puchero");
        Check(!Fire.TakePot(u) && !CaelumCampFireWork.Begin(u,Fire,CaelumCampFireWork.REMOVE_FIRE),"active cooking locks pot and fire dismantling");
        Check(!CaelumCookingCrafting.Complete(u),"completion cannot bypass remaining cooking time");u.CancelCraftingTask();
        PrepareCamp(u,206);Check(!CaelumCampCooking.Begin(u,Fire,205),"bread always requires an oven");
        Check(CaelumCampCooking.Begin(u,Fire,206),"beef cooks without any pot");
        double remaining=u.CraftingTaskRemainingSeconds,fuel=Fire.Fuel.FuelGrams;
        u.SetOrigin((500,500,0),false);Burn(u,60);
        Check(Near(Fire.Fuel.FuelGrams,fuel-32) && Near(u.CraftingTaskRemainingSeconds,remaining),"unattended fire burns wood but gives no cooking progress");
        u.SetOrigin((64,64,0),false);Burn(u,60);
        Check(Near(u.CraftingTaskRemainingSeconds,remaining-60),"returning within reach resumes attended heat");u.CancelCraftingTask();
        pot=CaelumCampPot(u.GiveInventoryType('CaelumCampPot'));pot.Amount=1;pot.InMagicBox=false;pot.WaterLiters=2;
        pot.WaterTemperatureC=20;pot.WaterTemperatureRevision=CaelumWaterThermalData.REVISION;
        Check(Fire.MountPot(u,pot) && CaelumCampCooking.Begin(u,Fire,206),"roast may use fire with a mounted water pot");
        double temperature=pot.WaterTemperatureC;Burn(u,60);
        Check(pot.WaterTemperatureC<temperature+1 && Near(pot.WaterLiters,2),"cooking does not heat or evaporate additional pot water");
        u.CancelCraftingTask();temperature=pot.WaterTemperatureC;Burn(u,60);
        Check(pot.WaterTemperatureC>temperature+10,"cancelling releases the same useful power back to water heating");
        CampResult();
    }
    void FastCamp(CaelumPlayer u)
    {
        PrepareCamp(u,207);u.CurrentSleep=100;
        FastStartStamp=CaelumFermentationService.Now(u);FastFuel=Fire.Fuel.FuelGrams;
        Check(CaelumCampCooking.Begin(u,Fire,207),"real clock camp batch starts");
        Check(Near(CaelumTimeSkipState.TaskSeconds(u)*CaelumThermalRuntime.WorldTicSeconds()*TICRATE,1800),"camp wait forecast retains full thirty world minutes");
        Check(CaelumTimeAdvanceState.Toggle(u),"native attended acceleration accepts camp cooking");CampResult();
    }
    void FastCampDone(CaelumPlayer u)
    {
        Fire.Advance();double elapsed=CaelumFermentationService.Now(u)-FastStartStamp;
        let output=CaelumConsumableItem(u.FindInventory('CaelumRoastFish'));
        Console.Printf("CA411C FAST active=%d output=%d remaining=%.6f elapsed=%.6f fuel=%.6f reason=%s",u.CraftingTaskActive,output!=null?output.Amount:-1,u.CraftingTaskRemainingSeconds,elapsed,Fire.Fuel.FuelGrams,CaelumTimeAdvanceState.Get(u).LastReason);
        Check(!u.CraftingTaskActive && output!=null && (output.Amount==10 || (output.Amount==9 && u.FindInventory('CaelumHungerRegeneration')!=null)),"full accelerated camp cooking completes ten portions including any automatically eaten portion");
        Check(elapsed>=1800 && elapsed<1830,"actual world clock completes thirty-minute recipe without injected progress");
        Check(Abs(FastFuel-Fire.Fuel.FuelGrams-CaelumCampPhysics.FuelGrams(elapsed))<0.1,"real clock consumes wood exactly once for elapsed burning time");
        Check(Fire.Busy==null && !CaelumTimeAdvanceState.Get(u).Active,"completed batch releases fire and accelerated clock");CampResult();
    }
    void ViewCamp(CaelumPlayer u,bool progress)
    {
        if(progress)Interrupted(u,true);
        else PrepareCamp(u,208);
        Check(CaelumCampFireSession.Show(u,Fire),"camp menu opens for visual review");
        let session=CaelumCampFireSession.Find(u);session.CookingPage=true;u.Pitch=30;CampResult();
    }
    void InputSetup(CaelumPlayer u)
    {
        PrepareCamp(u,207);u.Pitch=30;Check(CaelumCampFireSession.Show(u,Fire),"live input starts at the fire controls");CampResult();
    }
    void InputAudit(CaelumPlayer u)
    {
        Check(CaelumCampCooking.Active(u) && CaelumCookingTaskState.FindCooking(u).Recipe==207,"real menu keyboard starts selected fish cooking");
        Check(Fire.Used(u) && CaelumCampFireSession.Find(u).CookingPage,"native Use reopens current cooking progress");CampResult();
    }
    void HubSeed(CaelumPlayer u)
    {
        PrepareCamp(u,207);Check(CaelumCampCooking.Begin(u,Fire,207),"travel cooking starts");Burn(u,60);
        Fire.Advance();TravelFuel=Fire.Fuel.FuelGrams;CampResult();
    }
    void HubReturn(CaelumPlayer u)
    {
        if(Fire!=null)Console.Printf("CA411C HUB busy=%d lit=%d fuel=%.6f expected=%.6f",Fire.Busy!=null,Fire.Fuel.Lit,Fire.Fuel.FuelGrams,TravelFuel);
        Check(!CaelumCampCooking.Active(u) && !u.CraftingTaskActive,"map travel cancels attended cooking reservation");
        Check(Fire!=null && Fire.Busy==null && !Fire.Fuel.Lit && Abs(Fire.Fuel.FuelGrams-TravelFuel)<1,"return retains extinguished fire and unburned wood");
        Check(u.CountRawCraftingMaterial(CaelumKitchenData.RAW_FISH,1)==1430 && u.FindInventory('CaelumRoastFish')==null,"travel preserves ingredients and produces no unattended food");
        CampResult();
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=="ca411c_core")CoreCamp(u);
        else if(e.Name=="ca411c_interrupt")Interrupted(u);
        else if(e.Name=="ca411c_seed")Interrupted(u,true);
        else if(e.Name=="ca411c_resume")ResumeCamp(u);
        else if(e.Name=="ca411c_guards")Guards(u);
        else if(e.Name=="ca411c_fast")FastCamp(u);
        else if(e.Name=="ca411c_fastdone")FastCampDone(u);
        else if(e.Name=="ca411c_view")ViewCamp(u,e.Args[0]!=0);
        else if(e.Name=="ca411c_input")InputSetup(u);
        else if(e.Name=="ca411c_audit")InputAudit(u);
        else if(e.Name=="ca411c_hubseed")HubSeed(u);
        else if(e.Name=="ca411c_hubreturn")HubReturn(u);
        else Super.NetworkProcess(e);
    }
}
