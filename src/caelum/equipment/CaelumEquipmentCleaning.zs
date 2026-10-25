// Agua propia y superficies ya aprobadas: ninguna estación ni material nuevo.
class CaelumCleaningSupplies : Object play
{
    static double Area(CaelumEquipmentItem item)
    {
        if(item==null)return 0;
        if(item.EquipmentKind==CaelumConstants.EQUIPMENT_KIND_WEAPON)return CaelumContaminationRules.WeaponArea(item.ItemType,item.EquipmentSize);
        if(item.EquipmentKind==CaelumConstants.EQUIPMENT_KIND_SHIELD)return CaelumContaminationRules.ShieldArea(item.ItemType,item.EquipmentSize);
        if(item.EquipmentKind==CaelumConstants.EQUIPMENT_KIND_ARMOR || item.EquipmentKind==CaelumConstants.EQUIPMENT_KIND_CLOTHING)
            return CaelumContaminationRules.GarmentArea(Clamp(item.ArmorSlot,0,3),item.EquipmentSize);
        return 0;
    }
    static bool Cloth(CaelumPlayer user)
    {let cloth=user==null?null:user.FindNativeSpecialItem(CaelumConstants.EQUIPMENT_KIND_KEY_ITEM,CaelumHygieneData.CLOTH_KEY,0);return cloth!=null && cloth.Amount>0;}
    static bool WaterUsable(CaelumPlayer user,CaelumWaterContainer water)
    {return water!=null && water.Owner==user && water.Amount==1 && !water.InMagicBox && water.IsPotable()
        && !CaelumWaterBoiling.Locked(water) && water.WaterLiters>0;}
    static double Water(CaelumPlayer user)
    {
        double liters=0;if(user==null)return 0;
        for(Inventory item=user.Inv;item!=null;item=item.Inv)
        {let water=CaelumWaterContainer(item);if(WaterUsable(user,water))liters+=water.WaterLiters;}
        return liters;
    }
    static bool SpendWater(CaelumPlayer user,double liters)
    {
        if(liters<0 || Water(user)+0.000000001<liters)return false;
        for(Inventory item=user.Inv;item!=null && liters>0;item=item.Inv)
        {
            let water=CaelumWaterContainer(item);if(!WaterUsable(user,water))continue;
            double take=Min(liters,water.WaterLiters);water.WaterLiters=Max(0.0,water.WaterLiters-take);liters-=take;
        }
        return liters<0.000000001;
    }
    static bool CanClean(CaelumPlayer user,CaelumEquipmentItem item)
    {
        if(item==null || item.Owner!=user || item.Amount<=0 || item.ItemId<=0 || Area(item)<=0
            || CaelumContaminationStorage.Value(item)<=0 || !Cloth(user))return false;
        double water=CaelumContaminationRules.EquipmentWaterLiters(Area(item));
        return Water(user)+0.000000001>=water && CaelumSoapSupply.Available(user)+0.000000001>=CaelumContaminationRules.SoapGrams(water);
    }
}

// La cola se conserva al completar una pieza; cancelar elimina sólo el trabajo pendiente.
class CaelumCleaningTask : Inventory
{
    int Revision,Next,Minutes;
    String OriginMap;
    CaelumEquipmentItem Target;
    Array<CaelumEquipmentItem> Queue;
    double Area,Remaining,SpentWater,SpentSoap;
    bool ContinuePlan,SleepAfter,Resuming;
    CaelumRestFurniture Bed;
    static clearscope CaelumCleaningTask Find(CaelumPlayer user)
    {return user==null?null:CaelumCleaningTask(user.FindInventory('CaelumCleaningTask'));}
    static clearscope bool Active(CaelumPlayer user)
    {return user!=null && user.CraftingTaskActive && user.CraftingTaskKind==CaelumConstants.CRAFTING_TASK_CLEAN;}
    static bool KeepsBed(CaelumPlayer user,Actor bed)
    {let task=Find(user);return Active(user) && task!=null && task.SleepAfter && task.Bed==bed;}
    static bool Timeless(CaelumPlayer user)
    {let task=Find(user);return Active(user) && task!=null && task.SleepAfter && task.Bed!=null && task.Bed.CanReach(user) && CaelumWorldCatalogue.IsLimboMap(level.MapName);}
    static void Clear(CaelumPlayer user)
    {
        let task=Find(user);if(task==null)return;
        if(Active(user))CaelumTimeAdvanceState.Halt(user);
        task.Target=null;
        if(!task.ContinuePlan){task.Queue.Clear();task.Next=0;task.SleepAfter=false;task.Bed=null;}
    }
    static void Cancel(CaelumPlayer user)
    {
        if(!Active(user))return;
        let task=Find(user);if(task!=null)task.ContinuePlan=false;
        user.CancelCraftingTask();CaelumNotifications.Notify(user,StringTable.Localize("CA_CLEAN_CANCELLED",false));
    }
    static void MissingSupplies(CaelumPlayer user)
    {
        let task=Find(user);
        if(task==null || !task.SleepAfter){Cancel(user);return;}
        // Una falta tardía no impide dormir ni devuelve la parte ya gastada.
        task.ContinuePlan=true;user.CancelCraftingTask();
        CaelumNotifications.Notify(user,StringTable.Localize("CA_CLEAN_SKIPPED",false));AfterComplete(user);
    }
    static bool Attended(CaelumPlayer user)
    {
        let task=Find(user);
        return Active(user) && task!=null && task.Revision==1 && task.OriginMap==level.MapName
            && task.Target!=null && task.Target.Owner==user && task.Target.Amount>0 && user.health>0
            && user.player!=null && user.player.playerstate==PST_LIVE && !user.isFrozen()
            && user.CombatTimeRemaining<=0 && !user.HasActiveConversation() && !CaelumSleepRules.IsSleeping(user)
            && !user.PalomoMerchantMenuOpen;
    }
    static CaelumCleaningTask Allocate(CaelumPlayer user)
    {
        if(!CaelumCampTask.Available(user))return null;
        user.ClearCraftingTaskData();let task=Find(user);
        if(task==null)task=CaelumCleaningTask(user.GiveInventoryType('CaelumCleaningTask'));
        if(task!=null){task.Revision=1;task.OriginMap=level.MapName;task.Next=0;task.Queue.Clear();task.SleepAfter=false;task.Bed=null;task.ContinuePlan=false;task.Resuming=false;}
        return task;
    }
    bool NextPiece(CaelumPlayer user)
    {
        while(Next<Queue.Size())
        {
            let item=Queue[Next++];
            if(item==null || item.Owner!=user || CaelumCleaningSupplies.Area(item)<=0 || CaelumContaminationStorage.Value(item)<=0)continue;
            if(!CaelumCleaningSupplies.CanClean(user,item))
            {CaelumNotifications.Notify(user,StringTable.Localize("CA_CLEAN_SKIPPED",false));continue;}
            ContinuePlan=true;user.ClearCraftingTaskData();ContinuePlan=false;
            Target=item;Area=CaelumCleaningSupplies.Area(item);Remaining=Area*CaelumContaminationData.EQUIPMENT_SECONDS_M2;
            SpentWater=0;SpentSoap=0;
            user.ActiveCraftingStationActor=user;
            user.StartPreparedCraftingTask(CaelumConstants.CRAFTING_TASK_CLEAN,Remaining);
            user.CraftingTaskRecipeIndex=-1;user.CraftingTaskTargetItemId=item.ItemId;user.CraftingTaskNetworkCapabilities=0;
            user.EquipmentMenuOpen=false;user.CraftingMenuOpen=false;user.PersistCharacterState();
            CaelumNotifications.Notify(user,StringTable.Localize("CA_CLEAN_STARTED",false));return true;
        }
        return false;
    }
    static bool Begin(CaelumPlayer user,CaelumEquipmentItem item,bool automatic=false)
    {
        if(!CaelumCleaningSupplies.CanClean(user,item))
        {if(automatic && item!=null && CaelumContaminationStorage.Value(item)>0)CaelumNotifications.Notify(user,StringTable.Localize("CA_CLEAN_SKIPPED",false));return false;}
        let task=Allocate(user);if(task==null)return false;task.Queue.Push(item);return task.NextPiece(user);
    }
    static bool BeforeSleep(CaelumPlayer user,int minutes,CaelumRestFurniture bed)
    {
        let existing=Find(user);if(existing!=null && existing.Resuming)return false;
        let task=Allocate(user);if(task==null)return false;
        task.SleepAfter=true;task.Minutes=minutes;task.Bed=bed;
        let weapon=user.FindNativeEquipmentItemById(user.ActiveWeaponItemId);if(weapon!=null)task.Queue.Push(weapon);
        for(int slot=0;slot<4;slot++)
        {
            let armor=CaelumThermalBody.EquippedPiece(user,slot);if(armor!=null)task.Queue.Push(armor);
            let clothing=CaelumClothing.Equipped(user,slot);if(clothing!=null)task.Queue.Push(clothing);
        }
        if(task.NextPiece(user))return true;
        task.Queue.Clear();task.SleepAfter=false;task.Bed=null;return false;
    }
    static void Advance(CaelumPlayer user,double seconds)
    {
        if(!Attended(user)){Cancel(user);return;}
        let task=Find(user);
        if(!CaelumCleaningSupplies.Cloth(user)){MissingSupplies(user);return;}
        double step=Min(task.Remaining,Max(0.0,seconds));
        double litersPerSecond=CaelumContaminationRules.EquipmentWaterLiters(1)/CaelumContaminationData.EQUIPMENT_SECONDS_M2;
        double affordable=Min(CaelumCleaningSupplies.Water(user),CaelumSoapSupply.Available(user)/CaelumContaminationData.SOAP_G_L)/litersPerSecond;
        step=Min(step,affordable);
        if(step<=0){MissingSupplies(user);return;}
        double liters=step*litersPerSecond,soap=CaelumContaminationRules.SoapGrams(liters);
        if(!CaelumCleaningSupplies.SpendWater(user,liters) || !CaelumSoapSupply.Spend(user,soap)){Cancel(user);return;}
        // La fracción del trabajo restante también retira la exposición acumulada durante la limpieza.
        double value=CaelumContaminationStorage.Value(task.Target);
        CaelumContaminationStorage.Set(task.Target,Max(0.0,value*(1-step/task.Remaining)));
        task.Remaining=Max(0.0,task.Remaining-step);task.SpentWater+=liters;task.SpentSoap+=soap;
        user.CraftingTaskRemainingSeconds=task.Remaining;
        user.RefreshCarriedInventorySummary();
        if(task.Remaining<0.000000001){task.Remaining=0;user.CraftingTaskRemainingSeconds=0;user.CompleteCraftingTask();}
        else if(step<Min(seconds,task.Remaining+step))MissingSupplies(user);
    }
    static bool Complete(CaelumPlayer user)
    {
        let task=Find(user);if(!Attended(user) || task.Remaining>0)return false;
        CaelumContaminationStorage.Set(task.Target,0);task.ContinuePlan=true;
        CaelumNotifications.Notify(user,StringTable.Localize("CA_CLEAN_DONE",false));return true;
    }
    static void AfterComplete(CaelumPlayer user)
    {
        let task=Find(user);if(task==null || !task.ContinuePlan)return;
        if(task.NextPiece(user))return;
        bool sleep=task.SleepAfter;int minutes=task.Minutes;let bed=task.Bed;
        task.ContinuePlan=false;task.Queue.Clear();task.SleepAfter=false;task.Bed=null;
        if(sleep){task.Resuming=true;CaelumRestState.Begin(user,CaelumRestRules.MODE_SLEEP,minutes,bed);task.Resuming=false;}
    }
    override void PreTravelled(){Cancel(CaelumPlayer(Owner));Super.PreTravelled();}
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE -INVENTORY.INVBAR}
    States {Spawn:TNT1 A -1;Stop;}
}

class CaelumCleaningSession : Inventory
{
    bool Open,Ready;
    String OriginMap;
    CaelumEquipmentItem Item;
    double Area,Contamination,Water,Soap,WaterCost,SoapCost;
    bool HasCloth;
    static clearscope CaelumCleaningSession Find(CaelumPlayer user)
    {return user==null?null:CaelumCleaningSession(user.FindInventory('CaelumCleaningSession'));}
    static bool Show(CaelumPlayer user)
    {
        if(CaelumCleaningTask.Active(user)){CaelumCleaningTask.Cancel(user);return true;}
        if(!CaelumCampTask.Available(user))return false;
        let item=user.GetSelectedNativeEquipmentItem();
        if(item==null || item.Owner!=user || CaelumCleaningSupplies.Area(item)<=0)
        {CaelumNotifications.Notify(user,StringTable.Localize("CA_CLEAN_SELECT",false));return false;}
        let session=Find(user);if(session==null)session=CaelumCleaningSession(user.GiveInventoryType('CaelumCleaningSession'));
        if(session==null)return false;session.Item=item;session.Open=true;session.OriginMap=level.MapName;session.Refresh(user);
        user.EquipmentMenuOpen=false;return true;
    }
    bool Valid(CaelumPlayer user)
    {return OriginMap==level.MapName && CaelumCampTask.Available(user) && Item!=null && Item.Owner==user;}
    void Refresh(CaelumPlayer user)
    {
        Area=CaelumCleaningSupplies.Area(Item);Contamination=CaelumContaminationStorage.Value(Item);
        Water=CaelumCleaningSupplies.Water(user);Soap=CaelumSoapSupply.Available(user);HasCloth=CaelumCleaningSupplies.Cloth(user);
        WaterCost=CaelumContaminationRules.EquipmentWaterLiters(Area);SoapCost=CaelumContaminationRules.SoapGrams(WaterCost);
        Ready=CaelumCleaningSupplies.CanClean(user,Item);
    }
    void Act(CaelumPlayer user,int choice)
    {
        if(!Open || !Valid(user)){Open=false;return;}
        if(choice==0)Open=false;
        else if(choice==1 && CaelumCleaningTask.Begin(user,Item))Open=false;
    }
    override void Tick(){Super.Tick();if(Open){let user=CaelumPlayer(Owner);if(!Valid(user))Open=false;else Refresh(user);}}
    override void PreTravelled(){Open=false;Super.PreTravelled();}
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE}
    States {Spawn:TNT1 A -1;Stop;}
}
