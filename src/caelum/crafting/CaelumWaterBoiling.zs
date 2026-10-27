// Estado aditivo del proceso. El recipiente conserva su contenido hasta completar.
class CaelumWaterBoilingState : Inventory
{
    int Revision;
    CaelumWaterContainer Container;
    double InputLiters,InputC;
    int InputQuality,FuelUnits;
    static clearscope CaelumWaterBoilingState Find(CaelumPlayer user)
    {return user==null?null:CaelumWaterBoilingState(user.FindInventory("CaelumWaterBoilingState"));}
    Default
    {
        Inventory.Amount 1; Inventory.MaxAmount 1; Inventory.InterHubAmount 1;
        +INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE +INVENTORY.KEEPDEPLETED -INVENTORY.INVBAR
    }
    States { Spawn: TNT1 A -1; Stop; }
}

class CaelumWaterBoiling : Object
{
    static clearscope bool Locked(Inventory item)
    {
        if(item==null)return false;
        if(CaelumCampTask.Locked(item))return true;
        if(CaelumChemistryCrafting.Locked(item) || CaelumCookingCrafting.Locked(item))return true;
        let user=CaelumPlayer(item.Owner);
        let brew=CaelumWaterBoilingState.Find(user);
        return user!=null && user.CraftingTaskActive
            && user.CraftingTaskKind==CaelumConstants.CRAFTING_TASK_BOIL
            && brew!=null && brew.Container==item;
    }
    static play void Clear(CaelumPlayer user)
    {let brew=CaelumWaterBoilingState.Find(user);if(brew!=null)brew.Container=null;}
    static clearscope int Capabilities()
    {return CaelumCraftingRules.GetStationCapabilityBit(CaelumConstants.CRAFTING_STATION_WORKBENCH)
        |CaelumCraftingRules.GetStationCapabilityBit(CaelumConstants.CRAFTING_STATION_ALCHEMY);}
    // Sólo se busca al solicitar la acción y dentro del alcance de la sesión.
    static play CaelumCraftingStation Nearby(CaelumPlayer user)
    {
        double reach=CaelumConstants.CRAFTING_ACTIVE_STATION_DISTANCE;
        let it=BlockThingsIterator.CreateFromPos(user.Pos.X,user.Pos.Y,user.Pos.Z-reach,user.Height+2*reach,reach,false);
        while(it.Next())
        {
            let station=CaelumCraftingStation(it.thing);
            if(station==null || !station.CanReachFrom(user) || user.Distance3D(station)>reach)continue;
            int token=user.BeginCraftingNetworkScan();station.CollectCraftingNetwork(user,token);
            if((user.CraftingNetworkCapabilities&Capabilities())==Capabilities())return station;
        }
        return null;
    }
    static play bool Begin(CaelumPlayer user,CaelumWaterContainer water)
    {
        if(!CaelumPlayerAuthority.CanMutate(user) || user.health<=0 || user.isFrozen()
            || user.player==null || user.player.playerstate!=PST_LIVE
            || user.CombatTimeRemaining>0 || user.CraftingTaskActive || water==null
            || water.Owner!=user || water.InMagicBox || water.Amount!=1
            || water.WaterLiters<=0 || water.WaterLiters>water.GetCapacityLiters()+0.000001
            || !CaelumWaterQuality.Valid(water.WaterQuality))return false;
        water.EnsureWaterTemperature(user);
        if(water.WaterTemperatureRevision==0)return false;
        if(CaelumWaterThermalData.Output(water.WaterLiters)<=0)return false;
        int fuel=CaelumWaterThermalData.Fuel(water.WaterLiters,water.WaterTemperatureC);
        if(user.CountCraftingMaterial(CaelumConstants.MATERIAL_COAL,1)<fuel)return false;
        let station=Nearby(user);if(station==null)return false;
        let brew=CaelumWaterBoilingState.Find(user);
        if(brew==null)brew=CaelumWaterBoilingState(user.GiveInventoryType("CaelumWaterBoilingState"));
        if(brew==null)return false;
        user.OpenCraftingNetwork(station);
        if(!user.CraftingMenuOpen)return false;
        user.ClearCraftingTaskData();
        if(!user.AddCraftingTaskReservation(CaelumConstants.MATERIAL_COAL,1,fuel))return false;
        brew.Revision=CaelumWaterThermalData.REVISION;brew.Container=water;
        brew.InputLiters=water.WaterLiters;brew.InputC=water.WaterTemperatureC;
        brew.InputQuality=water.WaterQuality;brew.FuelUnits=fuel;
        user.StartPreparedCraftingTask(CaelumConstants.CRAFTING_TASK_BOIL,
            CaelumWaterThermalData.Seconds(brew.InputLiters,brew.InputC));
        user.CraftingTaskNetworkCapabilities=Capabilities();
        user.PersistCharacterState();
        return true;
    }
    static play bool Complete(CaelumPlayer user)
    {
        let brew=CaelumWaterBoilingState.Find(user);
        let water=brew!=null?brew.Container:null;
        if(water==null || water.Owner!=user || water.InMagicBox || water.Amount!=1
            || brew.Revision!=CaelumWaterThermalData.REVISION
            || Abs(water.WaterLiters-brew.InputLiters)>0.000001
            || water.WaterQuality!=brew.InputQuality
            || !user.ValidateCraftingTaskReservations())return false;
        // La única mutación de materiales es atómica: una sola pila de carbón.
        if(!user.ConsumeCraftingTaskReservations())return false;
        water.WaterLiters=CaelumWaterThermalData.Output(brew.InputLiters);
        water.WaterQuality=brew.InputQuality&~CaelumWaterQuality.BIOLOGICAL;
        water.WaterTemperatureRevision=CaelumWaterThermalData.REVISION;
        water.WaterTemperatureC=CaelumWaterThermalData.BOILING_C;
        water.CoolingSeconds=0;water.StampTemperature(user);
        user.OnNativeInventoryChanged();
        user.LastCraftingAction=CaelumConstants.CRAFTING_ACTION_PROCESSED;
        CaelumNotifications.Notify(user,StringTable.Localize("CA_WATER_BOILED",false));
        return true;
    }
    static play void InventoryAction(CaelumPlayer user)
    {
        if(!CaelumPlayerAuthority.CanMutate(user))return;
        let water=CaelumWaterContainer(user.GetFormalInventoryEntryAt(user.FormalInventorySelectionIndex));
        if(!Begin(user,water))CaelumNotifications.Notify(user,StringTable.Localize("CA_WATER_BOIL_FAILED",false));
        user.RefreshFormalInventorySnapshot();
    }
}
