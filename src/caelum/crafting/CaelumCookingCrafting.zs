// Reserva de cocina aditiva: ingredientes y combustible siguen en el inventario
// nativo hasta terminar, de modo que cancelar no los recrea ni rejuvenece.
class CaelumCookingTaskState : CaelumChemistryTaskState
{
    // Campos aditivos: las tareas anteriores siguen usando horno/cocina.
    int CampRevision;
    bool Camp;
    CaelumCampFire Fire;
    String OriginMap;
    double HeatSeconds,IgnitionSeconds;
    static clearscope CaelumCookingTaskState FindCooking(CaelumPlayer user)
    {return user==null?null:CaelumCookingTaskState(user.FindInventory('CaelumCookingTaskState'));}
}

class CaelumCookingCrafting : Object play
{
    static clearscope bool Active(CaelumPlayer user)
    {return user!=null && user.CraftingTaskActive && user.CraftingTaskKind==CaelumConstants.CRAFTING_TASK_COOKING;}
    static clearscope bool Locked(Inventory item)
    {
        if(item==null)return false;
        let user=CaelumPlayer(item.Owner);let task=CaelumCookingTaskState.FindCooking(user);
        if(!Active(user) || task==null)return false;
        for(int i=0;i<task.Containers.Size();i++)if(task.Containers[i]==item)return true;
        return false;
    }
    static void Clear(CaelumPlayer user)
    {
        let task=CaelumCookingTaskState.FindCooking(user);if(task==null)return;
        CaelumCampCooking.Clear(user,task);
        task.Containers.Clear();task.WaterLiters.Clear();task.Recipe=-1;task.Batches=0;task.OutputUnits=0;
    }
    static CaelumConsumableItem Existing(CaelumPlayer user,int recipe)
    {return CaelumConsumableItem(user.FindInventory(CaelumMealData.ItemClass(CaelumCookingData.Meal(recipe))));}
    static bool Capacity(CaelumPlayer user,CaelumCookingTaskState task,CaelumConsumableItem existing)
    {
        if(existing!=null && existing.Amount>2147483647-task.OutputUnits)return false;
        bool boxed=existing!=null && existing.InMagicBox;if(boxed && !user.MagicBoxOwned)return false;
        double mass=CaelumMealData.PORTION_KG*task.OutputUnits;
        double personal=boxed?0:mass,box=boxed?mass:0;
        for(int slot=0;CaelumCookingData.InputMaterial(task.Recipe,slot)>=0;slot++)
        {
            int id=CaelumCookingData.InputMaterial(task.Recipe,slot);
            if(task.Camp && id==CaelumConstants.MATERIAL_COAL)continue;
            let input=user.FindNativeSpecialItem(CaelumConstants.EQUIPMENT_KIND_MATERIAL,id,1);
            if(input==null)return false;
            double used=CaelumMaterialRules.UnitWeight(id)*CaelumCookingData.InputGrams(task.Recipe,slot);
            if(input.InMagicBox)box-=used;else personal-=used;
        }
        for(int i=0;i<task.WaterLiters.Size();i++)personal-=task.WaterLiters[i];
        user.RefreshCarriedInventorySummary();
        return user.CanApplyInventoryWeightTransition(personal,box);
    }
    static bool Begin(CaelumPlayer user)
    {
        int recipe=user.CraftingSelectionRecipe;
        if(!CaelumPlayerAuthority.CanMutate(user) || user.isFrozen() || !CaelumMealData.IsRecipe(recipe)
            || !user.CanStartCraftingTask() || !user.DirectCraftingRecipeKnown(recipe,1))return false;
        let station=CaelumCraftingStation(user.ActiveCraftingStationActor);
        if(station==null || !station.CanReachFrom(user)
            || user.Distance3D(station)>CaelumConstants.CRAFTING_ACTIVE_STATION_DISTANCE)return false;
        station.CollectCraftingNetwork(user,user.BeginCraftingNetworkScan());
        if(CaelumCookingData.MissingStation(user.CraftingNetworkCapabilities,recipe)!=CaelumConstants.CRAFTING_STATION_NONE)return false;
        let task=Reserve(user,recipe);
        if(task==null)return false;
        user.StartPreparedCraftingTask(CaelumConstants.CRAFTING_TASK_COOKING,CaelumCookingData.Seconds(recipe));
        // Sólo la instalación necesaria, no toda la red que estaba conectada.
        user.CraftingTaskNetworkCapabilities=CaelumCraftingRules.GetStationCapabilityBit(CaelumCookingData.Station(recipe));
        user.PersistCharacterState();return true;
    }
    static CaelumCookingTaskState Reserve(CaelumPlayer user,int recipe,CaelumCampFire fire=null)
    {
        user.ClearCraftingTaskData();
        let task=CaelumCookingTaskState.FindCooking(user);
        if(task==null)task=CaelumCookingTaskState(user.GiveInventoryType('CaelumCookingTaskState'));
        if(task==null)return null;
        task.Revision=CaelumCookingData.REVISION;task.Recipe=recipe;task.Batches=1;
        task.OutputUnits=CaelumMealData.BATCH_PORTIONS;
        task.Camp=fire!=null;task.Fire=fire;task.CampRevision=CaelumCampCooking.REVISION;task.OriginMap=level.MapName;
        bool valid=true;
        for(int slot=0;CaelumCookingData.InputMaterial(recipe,slot)>=0;slot++)
        {
            if(task.Camp && CaelumCookingData.InputMaterial(recipe,slot)==CaelumConstants.MATERIAL_COAL)continue;
            if(!user.AddCraftingTaskReservation(CaelumCookingData.InputMaterial(recipe,slot),1,
                CaelumCookingData.InputGrams(recipe,slot)))valid=false;
        }
        if(!valid || !CaelumChemistryCrafting.CaptureWater(user,task,CaelumCookingData.WaterLiters(recipe))
            || !user.ValidateCraftingTaskReservations() || !Capacity(user,task,Existing(user,recipe)))
        {user.ClearCraftingTaskData();return null;}
        return task;
    }
    static bool FoodContamination(CaelumPlayer user,int recipe,out double contamination)
    {
        contamination=0;double foodGrams=0;
        for(int slot=0;CaelumCookingData.InputMaterial(recipe,slot)>=0;slot++)
        {
            int id=CaelumCookingData.InputMaterial(recipe,slot),grams=CaelumCookingData.InputGrams(recipe,slot);
            if(id==CaelumConstants.MATERIAL_COAL)continue;
            // El agua ya incorporada a la masa tampoco diluye el deterioro.
            double weight=id==CaelumCookingData.DOUGH
                ?CaelumMealData.InputGrams(CaelumMealData.BREAD,0)+CaelumMealData.InputGrams(CaelumMealData.BREAD,1)
                    +CaelumMealData.InputGrams(CaelumMealData.BREAD,2):grams;
            foodGrams+=weight;
            let input=Inventory(user.FindNativeSpecialItem(CaelumConstants.EQUIPMENT_KIND_MATERIAL,id,1));
            if(input==null || input.Amount<grams)return false;
            if(!CaelumFoodInventory.IsFood(input))continue;
            CaelumFoodInventory.Reconcile(input);
            let copy=CaelumFoodInventory.GetLots(input).CopyOldest(grams);
            if(copy==null)return false;
            double part;if(!copy.Consume(grams,part))return false;
            contamination+=part*weight;
        }
        if(foodGrams>0)contamination/=foodGrams;
        return true;
    }
    static bool Complete(CaelumPlayer user)
    {
        let task=CaelumCookingTaskState.FindCooking(user);
        if(!Active(user) || task==null || task.Revision!=CaelumCookingData.REVISION
            || task.Recipe!=user.CraftingTaskRecipeIndex || !CaelumMealData.IsRecipe(task.Recipe)
            || task.OutputUnits!=CaelumMealData.BATCH_PORTIONS || !user.ValidateCraftingTaskReservations())return false;
        if(task.Camp && (!CaelumCampCooking.Attended(user,false) || task.IgnitionSeconds>0
            || user.CraftingTaskRemainingSeconds>0.0000001))return false;
        for(int i=0;i<task.Containers.Size();i++)
        {
            let water=task.Containers[i];
            if(water==null || water.Owner!=user || water.Amount!=1 || water.InMagicBox || !water.IsPotable()
                || water.WaterLiters+0.0000001<task.WaterLiters[i])return false;
        }
        let existing=Existing(user,task.Recipe);
        if(!Capacity(user,task,existing))return false;
        double contamination;if(!FoodContamination(user,task.Recipe,contamination))return false;
        CaelumConsumableItem detached;
        if(existing==null)
        {
            detached=CaelumConsumableItem(Actor.Spawn(CaelumMealData.ItemClass(CaelumCookingData.Meal(task.Recipe)),user.Pos,NO_REPLACE));
            if(detached==null)return false;
            detached.Amount=0;
            CaelumFoodInventory.SetLots(detached,null);
        }
        else CaelumFoodInventory.Reconcile(existing);
        let output=existing!=null?existing:detached;
        let lots=CaelumFoodInventory.Prepare(output);
        if(lots==null || lots.Units()>2147483647-task.OutputUnits)
        {if(detached!=null)detached.Destroy();return false;}
        if(!user.ConsumeCraftingTaskReservations())
        {if(detached!=null)detached.Destroy();return false;}
        for(int i=0;i<task.Containers.Size();i++)task.Containers[i].WaterLiters=Max(0,task.Containers[i].WaterLiters-task.WaterLiters[i]);
        lots.Add(task.OutputUnits,contamination,CaelumFermentationService.Now(user));
        output.Amount+=task.OutputUnits;
        if(detached!=null)detached.AttachToOwner(user);
        CaelumFoodInventory.Relocate(output);
        CaelumNotifications.Acquired(user,output,task.OutputUnits);
        user.LastCraftingAction=CaelumConstants.CRAFTING_ACTION_PROCESSED;
        user.OnNativeInventoryChanged();return true;
    }
}
