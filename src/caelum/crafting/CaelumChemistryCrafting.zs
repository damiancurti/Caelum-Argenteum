// Reserva aditiva y serializable. Las vasijas no se consumen ni se trasvasan al iniciar.
class CaelumChemistryTaskState : Inventory
{
    int Revision,Recipe,Batches,OutputUnits;
    Array<CaelumWaterContainer> Containers;
    Array<double> WaterLiters;
    static clearscope CaelumChemistryTaskState Find(CaelumPlayer user)
    {return user==null?null:CaelumChemistryTaskState(user.FindInventory('CaelumChemistryTaskState'));}
    Default
    {
        Inventory.Amount 1;Inventory.MaxAmount 1;Inventory.InterHubAmount 1;
        +INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE +INVENTORY.KEEPDEPLETED -INVENTORY.INVBAR
    }
    States {Spawn: TNT1 A -1;Stop;}
}

class CaelumChemistryCrafting : Object play
{
    static clearscope bool Locked(Inventory item)
    {
        if(item==null)return false;
        let user=CaelumPlayer(item.Owner);let brew=CaelumChemistryTaskState.Find(user);
        if(user==null || !user.CraftingTaskActive || user.CraftingTaskKind!=CaelumConstants.CRAFTING_TASK_CHEMISTRY
            || brew==null)return false;
        for(int i=0;i<brew.Containers.Size();i++)if(brew.Containers[i]==item)return true;
        return false;
    }
    static void Clear(CaelumPlayer user)
    {
        let brew=CaelumChemistryTaskState.Find(user);if(brew==null)return;
        brew.Containers.Clear();brew.WaterLiters.Clear();brew.Recipe=-1;brew.OutputUnits=0;brew.Batches=0;
    }
    static clearscope double UnitMass(int recipe)
    {
        int potion=CaelumChemistryData.OutputConsumable(recipe);
        return potion>=0?CaelumConsumableItem.UnitWeightForType(potion)
            :CaelumMaterialRules.UnitWeight(CaelumChemistryData.OutputMaterial(recipe));
    }
    static Inventory Existing(CaelumPlayer user,int recipe)
    {
        int potion=CaelumChemistryData.OutputConsumable(recipe);
        if(potion>=0)return user.FindInventory(CaelumPotionRules.ItemClass(potion));
        return user.FindNativeSpecialItem(CaelumConstants.EQUIPMENT_KIND_MATERIAL,CaelumChemistryData.OutputMaterial(recipe),1);
    }
    static bool Boxed(Inventory item)
    {
        let material=CaelumSpecialInventoryItem(item);let potion=CaelumConsumableItem(item);
        return material!=null?material.InMagicBox:potion!=null && potion.InMagicBox;
    }
    static bool Capacity(CaelumPlayer user,CaelumChemistryTaskState brew,Inventory existing)
    {
        if(existing!=null && existing.Amount>2147483647-brew.OutputUnits)return false;
        bool boxed=Boxed(existing);if(boxed && !user.MagicBoxOwned)return false;
        double mass=UnitMass(brew.Recipe)*brew.OutputUnits;
        double personal=boxed?0:mass,box=boxed?mass:0;
        for(int slot=0;CaelumChemistryData.InputMaterial(brew.Recipe,slot)>=0;slot++)
        {
            int id=CaelumChemistryData.InputMaterial(brew.Recipe,slot);
            let input=user.FindNativeSpecialItem(CaelumConstants.EQUIPMENT_KIND_MATERIAL,id,1);
            if(input==null)return false;
            double used=CaelumMaterialRules.UnitWeight(id)*CaelumChemistryData.InputUnits(brew.Recipe,slot)*brew.Batches;
            if(input.InMagicBox)box-=used;else personal-=used;
        }
        for(int i=0;i<brew.WaterLiters.Size();i++)personal-=brew.WaterLiters[i];
        user.RefreshCarriedInventorySummary();
        return user.CanApplyInventoryWeightTransition(personal,box);
    }
    static bool CaptureWater(CaelumPlayer user,CaelumChemistryTaskState brew,double liters)
    {
        for(Inventory item=user.Inv;item!=null && liters>0;item=item.Inv)
        {
            let water=CaelumWaterContainer(item);
            if(water==null || water.InMagicBox || water.Amount!=1 || !water.IsPotable()
                || CaelumWaterBoiling.Locked(water) || water.WaterLiters<=0)continue;
            double take=Min(water.WaterLiters,liters);
            brew.Containers.Push(water);brew.WaterLiters.Push(take);liters-=take;
        }
        return liters<0.0000001;
    }
    static bool Begin(CaelumPlayer user)
    {
        int recipe=user.CraftingSelectionRecipe;
        if(!CaelumPlayerAuthority.CanMutate(user) || user.isFrozen() || !CaelumChemistryData.IsRecipe(recipe)
            || CaelumChemistryData.IsFermentation(recipe) || !user.CanStartCraftingTask()
            || !user.DirectCraftingRecipeKnown(recipe,1))return false;
        let station=CaelumCraftingStation(user.ActiveCraftingStationActor);
        if(station==null || station is 'CaelumFermentationStation')return false;
        station.CollectCraftingNetwork(user,user.BeginCraftingNetworkScan());
        if(CaelumCraftingRules.GetMissingAlchemyStation(user.CraftingNetworkCapabilities)!=CaelumConstants.CRAFTING_STATION_NONE)return false;
        int batches=user.CraftingProcessingBatchMultiplier;
        if(batches<=0)return false;
        user.ClearCraftingTaskData();
        let brew=CaelumChemistryTaskState.Find(user);
        if(brew==null)brew=CaelumChemistryTaskState(user.GiveInventoryType('CaelumChemistryTaskState'));
        if(brew==null)return false;
        brew.Revision=1;brew.Recipe=recipe;brew.Batches=batches;
        brew.OutputUnits=CaelumChemistryData.OutputUnits(recipe)*batches;
        bool valid=true;
        for(int slot=0;CaelumChemistryData.InputMaterial(recipe,slot)>=0;slot++)
            if(!user.AddCraftingTaskReservation(CaelumChemistryData.InputMaterial(recipe,slot),1,
                CaelumChemistryData.InputUnits(recipe,slot)*batches))valid=false;
        if(!valid || !CaptureWater(user,brew,CaelumChemistryData.WaterLiters(recipe)*batches)
            || !user.ValidateCraftingTaskReservations() || !Capacity(user,brew,Existing(user,recipe)))
        {user.ClearCraftingTaskData();return false;}
        user.StartPreparedCraftingTask(CaelumConstants.CRAFTING_TASK_CHEMISTRY,user.CraftingPreviewSeconds);
        user.CraftingTaskNetworkCapabilities=CaelumWaterBoiling.Capabilities();
        user.PersistCharacterState();return true;
    }
    static bool Complete(CaelumPlayer user)
    {
        let brew=CaelumChemistryTaskState.Find(user);
        if(brew==null || brew.Revision!=1 || brew.Recipe!=user.CraftingTaskRecipeIndex
            || brew.OutputUnits<=0 || !user.ValidateCraftingTaskReservations())return false;
        for(int i=0;i<brew.Containers.Size();i++)
        {
            let water=brew.Containers[i];
            if(water==null || water.Owner!=user || water.Amount!=1 || water.InMagicBox || !water.IsPotable()
                || water.WaterLiters+0.0000001<brew.WaterLiters[i])return false;
        }
        let existing=Existing(user,brew.Recipe);
        if(!Capacity(user,brew,existing))return false;
        Inventory detached;
        if(existing==null)
        {
            int potion=CaelumChemistryData.OutputConsumable(brew.Recipe);
            if(potion>=0)detached=Inventory(Actor.Spawn(CaelumPotionRules.ItemClass(potion),user.Pos,NO_REPLACE));
            else detached=user.CreateDetachedMaterialStack(CaelumChemistryData.OutputMaterial(brew.Recipe),1,brew.OutputUnits);
            if(detached==null)return false;
            detached.Amount=brew.OutputUnits;
        }
        if(!user.ConsumeCraftingTaskReservations())
        {if(detached!=null)detached.Destroy();return false;}
        for(int i=0;i<brew.Containers.Size();i++)
            brew.Containers[i].WaterLiters=Max(0,brew.Containers[i].WaterLiters-brew.WaterLiters[i]);
        if(existing!=null)
        {
            CaelumContaminationStack.Reconcile(existing);existing.Amount+=brew.OutputUnits;
            CaelumContaminationStack.Reconcile(existing);
        }
        else {detached.AttachToOwner(user);existing=detached;}
        CaelumNotifications.Acquired(user,existing,brew.OutputUnits);
        user.LastCraftingAction=CaelumConstants.CRAFTING_ACTION_PROCESSED;
        user.OnNativeInventoryChanged();return true;
    }
}
