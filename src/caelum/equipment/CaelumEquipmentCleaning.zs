// Agua propia y superficies ya aprobadas: ninguna estación ni material nuevo.
class CaelumCleaningSupplies : Object play
{
    const EQUIPPED_COUNT=9;
    static CaelumEquipmentItem EquippedAt(CaelumPlayer user,int index)
    {
        if(user==null || index<0 || index>=EQUIPPED_COUNT)return null;
        if(index==0)return user.FindNativeEquipmentItemById(user.ActiveWeaponItemId);
        int slot=(index-1)/2;
        return (index%2)==1?CaelumThermalBody.EquippedPiece(user,slot):CaelumClothing.Equipped(user,slot);
    }
    // Una misma dosis progresiva para acciones manuales y sueño por calendario.
    static double Progress(CaelumPlayer user,CaelumEquipmentItem item,double remaining,double seconds)
    {
        double rate=CaelumContaminationRules.EquipmentWaterLiters(1)/CaelumContaminationData.EQUIPMENT_SECONDS_M2;
        double affordable=Min(Water(user),CaelumSoapSupply.Available(user)/CaelumContaminationData.SOAP_G_L)/rate;
        double step=Min(Min(remaining,Max(0.0,seconds)),affordable);
        if(step<=0)return 0;
        double liters=step*rate;
        if(!SpendWater(user,liters) || !CaelumSoapSupply.Spend(user,CaelumContaminationRules.SoapGrams(liters)))return -1;
        double value=CaelumContaminationStorage.Value(item);
        CaelumContaminationStorage.Set(item,Max(0.0,value*(1-step/remaining)));
        user.RefreshCarriedInventorySummary();return step;
    }
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
    bool ContinuePlan,SleepAfter,Resuming,WakeQueue;
    CaelumRestFurniture Bed;
    void EnsureRevision()
    {
        // Las colas anteriores conservan destino, costes y progreso; no eran
        // limpiezas posteriores a un desmayo. La migración es idempotente.
        if(Revision<2){WakeQueue=false;Revision=2;}
    }
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
        if(!task.ContinuePlan){task.Queue.Clear();task.Next=0;task.SleepAfter=false;task.WakeQueue=false;task.Bed=null;}
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
        if(task==null || (!task.SleepAfter && !task.WakeQueue)){Cancel(user);return;}
        // Una falta tardía no impide dormir ni devuelve la parte ya gastada.
        task.ContinuePlan=true;user.CancelCraftingTask();
        CaelumNotifications.Notify(user,StringTable.Localize("CA_CLEAN_SKIPPED",false));AfterComplete(user);
    }
    static bool Attended(CaelumPlayer user)
    {
        let task=Find(user);
        if(task!=null)task.EnsureRevision();
        return Active(user) && task!=null && task.Revision==2 && task.OriginMap==level.MapName
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
        if(task!=null){task.Revision=2;task.OriginMap=level.MapName;task.Next=0;task.Queue.Clear();task.SleepAfter=false;task.WakeQueue=false;task.Bed=null;task.ContinuePlan=false;task.Resuming=false;}
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
    void AddEquipped(CaelumPlayer user)
    {
        for(int i=0;i<CaelumCleaningSupplies.EQUIPPED_COUNT;i++)
        {let item=CaelumCleaningSupplies.EquippedAt(user,i);if(item!=null)Queue.Push(item);}
    }
    static void AfterExhaustionWake(CaelumPlayer user,bool interrupted)
    {
        // El desmayo no se retrasa: este punto sólo se alcanza al despertar.
        // Daño/peligro no abre una tarea nueva ni consume suministros.
        if(interrupted || !CaelumCampTask.Available(user))
        {if(user!=null && user.health>0)CaelumNotifications.Notify(user,StringTable.Localize("CA_CLEAN_SKIPPED",false));return;}
        let task=Allocate(user);if(task==null)return;
        task.WakeQueue=true;task.AddEquipped(user);
        if(task.NextPiece(user))return;
        task.Queue.Clear();task.WakeQueue=false;
    }
    static bool BeforeSleep(CaelumPlayer user,int minutes,CaelumRestFurniture bed)
    {
        let existing=Find(user);if(existing!=null && existing.Resuming)return false;
        let task=Allocate(user);if(task==null)return false;
        task.SleepAfter=true;task.Minutes=minutes;task.Bed=bed;task.AddEquipped(user);
        if(task.NextPiece(user))return true;
        task.Queue.Clear();task.SleepAfter=false;task.Bed=null;return false;
    }
    static void Advance(CaelumPlayer user,double seconds)
    {
        if(!Attended(user)){Cancel(user);return;}
        let task=Find(user);
        if(!CaelumCleaningSupplies.Cloth(user)){MissingSupplies(user);return;}
        double step=CaelumCleaningSupplies.Progress(user,task.Target,task.Remaining,seconds);
        if(step<0){Cancel(user);return;}
        if(step<=0){MissingSupplies(user);return;}
        double liters=CaelumContaminationRules.EquipmentWaterLiters(step/CaelumContaminationData.EQUIPMENT_SECONDS_M2);
        double soap=CaelumContaminationRules.SoapGrams(liters);
        task.Remaining=Max(0.0,task.Remaining-step);task.SpentWater+=liters;task.SpentSoap+=soap;
        user.CraftingTaskRemainingSeconds=task.Remaining;
        if(task.Remaining<0.000000001){task.Remaining=0;user.CraftingTaskRemainingSeconds=0;user.CompleteCraftingTask();}
        else if(step<Min(seconds,task.Remaining+step))MissingSupplies(user);
    }
    static bool Complete(CaelumPlayer user)
    {
        let task=Find(user);if(!Attended(user) || task.Remaining>0)return false;
        CaelumContaminationStorage.Set(task.Target,0);task.ContinuePlan=true;
        CaelumTimeSkipState.RecordCleaned(user,task.Target);
        CaelumNotifications.Notify(user,StringTable.Localize("CA_CLEAN_DONE",false));return true;
    }
    static void AfterComplete(CaelumPlayer user)
    {
        let task=Find(user);if(task==null || !task.ContinuePlan)return;
        if(task.NextPiece(user))return;
        bool sleep=task.SleepAfter;int minutes=task.Minutes;let bed=task.Bed;
        task.ContinuePlan=false;task.Queue.Clear();task.SleepAfter=false;task.WakeQueue=false;task.Bed=null;
        if(sleep && !CaelumTimeSkipState.IsPreparingSleep(user)){task.Resuming=true;CaelumRestState.Begin(user,CaelumRestRules.MODE_SLEEP,minutes,bed);task.Resuming=false;}
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

// Fase del calendario: no ocupa ni reemplaza la tarea de fabricación/lectura.
class CaelumCalendarCleaning : Object play
{
    int Revision,Next;
    bool WaitingExisting,Done;
    Array<CaelumEquipmentItem> Queue,AlreadyCleaned;
    CaelumEquipmentItem Target;
    double Remaining,SpentWater,SpentSoap;
    void Capture(CaelumPlayer user)
    {
        Revision=1;WaitingExisting=CaelumCleaningTask.Active(user);
        for(int i=0;i<CaelumCleaningSupplies.EQUIPPED_COUNT;i++)
        {let item=CaelumCleaningSupplies.EquippedAt(user,i);if(item!=null)Queue.Push(item);}
    }
    bool WasCleaned(CaelumEquipmentItem item)
    {for(int i=0;i<AlreadyCleaned.Size();i++)if(AlreadyCleaned[i]==item)return true;return false;}
    void NextPiece(CaelumPlayer user)
    {
        Target=null;
        while(Next<Queue.Size())
        {
            let item=Queue[Next++];
            if(item==null || item.Owner!=user || item.Amount<=0 || WasCleaned(item)
                || CaelumContaminationStorage.Value(item)<=0 || CaelumCleaningSupplies.Area(item)<=0)continue;
            if(!CaelumCleaningSupplies.CanClean(user,item))
            {CaelumNotifications.Notify(user,StringTable.Localize("CA_CLEAN_SKIPPED",false));continue;}
            Target=item;Remaining=CaelumCleaningSupplies.Area(item)*CaelumContaminationData.EQUIPMENT_SECONDS_M2;
            return;
        }
        Done=true;
    }
    void Prepare(CaelumPlayer user)
    {
        if(Done)return;
        if(WaitingExisting && CaelumCleaningTask.Active(user))return;
        WaitingExisting=false;if(Target==null)NextPiece(user);
    }
    void Advance(CaelumPlayer user,double seconds)
    {
        if(Done || WaitingExisting || Target==null)return;
        if(Target.Owner!=user || Target.Amount<=0){NextPiece(user);return;}
        if(!CaelumCleaningSupplies.Cloth(user))
        {CaelumNotifications.Notify(user,StringTable.Localize("CA_CLEAN_SKIPPED",false));NextPiece(user);return;}
        double wanted=Min(Remaining,Max(0.0,seconds));
        double step=CaelumCleaningSupplies.Progress(user,Target,Remaining,seconds);
        if(step<0){Done=true;Target=null;return;}
        Remaining=Max(0.0,Remaining-step);
        double liters=CaelumContaminationRules.EquipmentWaterLiters(step/CaelumContaminationData.EQUIPMENT_SECONDS_M2);
        SpentWater+=liters;SpentSoap+=CaelumContaminationRules.SoapGrams(liters);
        if(Remaining<0.000000001)
        {CaelumContaminationStorage.Set(Target,0);CaelumNotifications.Notify(user,StringTable.Localize("CA_CLEAN_DONE",false));NextPiece(user);}
        else if(step<wanted)
        {CaelumNotifications.Notify(user,StringTable.Localize("CA_CLEAN_SKIPPED",false));NextPiece(user);}
    }
}
