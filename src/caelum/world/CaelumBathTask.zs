// Baño atendido: cada paso conserva la misma proporción de agua, jabón y depuración.
class CaelumBathTask : Inventory
{
    int Revision;
    String OriginMap;
    CaelumDomesticFixture Fixture;
    Sector WaterModel;
    double RemainingDegrees,RemovedDegrees,SpentWater,SpentSoap;
    static clearscope CaelumBathTask Find(CaelumPlayer user)
    {return user==null?null:CaelumBathTask(user.FindInventory('CaelumBathTask'));}
    static clearscope bool Active(CaelumPlayer user)
    {return user!=null && user.CraftingTaskActive && user.CraftingTaskKind==CaelumConstants.CRAFTING_TASK_BATH;}
    static void Clear(CaelumPlayer user)
    {
        let task=Find(user);if(task==null)return;
        let advance=CaelumTimeAdvanceState.Get(user);
        if(advance!=null && advance.Active && (advance.Station==task.Fixture || advance.Station==user))CaelumTimeAdvanceState.Halt(user);
        if(user.ActiveCraftingStationActor==task.Fixture || user.ActiveCraftingStationActor==user)user.ActiveCraftingStationActor=null;
        task.Fixture=null;task.WaterModel=null;
    }
    static void Cancel(CaelumPlayer user)
    {if(Active(user)){user.CancelCraftingTask();CaelumNotifications.Notify(user,StringTable.Localize("CA_BATH_CANCELLED",false));}}
    static bool SourceValid(CaelumPlayer user,CaelumDomesticFixture fixture,Sector waterModel)
    {
        if(!CaelumPlayerAuthority.CanMutate(user) || user.health<=0 || user.isFrozen())return false;
        if(fixture!=null)return fixture.SuppliesWater() && fixture.CanReach(user) && fixture.WaterSafe(user);
        return waterModel!=null && CaelumWaterQuality.Model(user)==waterModel && CaelumWaterQuality.Source(user)==CaelumWaterQuality.POTABLE;
    }
    static double WaterAvailable(CaelumPlayer user,CaelumDomesticFixture fixture,Sector waterModel)
    {
        if(!SourceValid(user,fixture,waterModel))return 0;
        if(fixture!=null)return fixture.AvailableWater(user);
        let installation=CaelumConnectedWaterMap.Get();if(installation!=null)installation.Sync(CaelumWorldClock.Get(user));
        int index=installation==null?-1:installation.Index(waterModel);
        return index<0?double.max:installation.Available(index);
    }
    static bool SpendWater(CaelumPlayer user,CaelumDomesticFixture fixture,Sector waterModel,double liters)
    {
        if(liters<0 || WaterAvailable(user,fixture,waterModel)+0.000000001<liters)return false;
        if(fixture!=null)return fixture.SpendWater(user,liters);
        let installation=CaelumConnectedWaterMap.Get();int index=installation==null?-1:installation.Index(waterModel);
        return index<0 || installation.Withdraw(index,liters)+0.000000001>=liters;
    }
    static double Affordable(CaelumPlayer user,CaelumDomesticFixture fixture,Sector waterModel)
    {
        if(user==null || user.DerivedStats==null)return 0;
        double waterPer=CaelumContaminationRules.BathWaterLiters(1,user.DerivedStats.BaseMass);
        if(waterPer<=0)return 0;
        return Max(0.0,Min(CaelumFoodIllness.Value(user),Min(WaterAvailable(user,fixture,waterModel)/waterPer,
            CaelumSoapSupply.Available(user)/CaelumContaminationRules.SoapGrams(waterPer))));
    }
    static bool Attended(CaelumPlayer user)
    {
        let task=Find(user);let pose=CaelumHygienePose.Find(user);
        return Active(user) && task!=null && task.Revision==1 && task.OriginMap==level.MapName
            && SourceValid(user,task.Fixture,task.WaterModel) && user.player!=null && user.player.playerstate==PST_LIVE
            && user.CombatTimeRemaining<=0 && !user.HasActiveConversation() && !CaelumSleepRules.IsSleeping(user)
            && !user.PalomoMerchantMenuOpen && (pose==null || !pose.Engaged || pose.Valid(user));
    }
    static bool Begin(CaelumPlayer user,CaelumDomesticFixture fixture,Sector waterModel,double degrees)
    {
        if(!CaelumCampTask.Available(user) || degrees<=0 || degrees>Affordable(user,fixture,waterModel)+0.000000001)return false;
        // Guardar la fuente antes de liberar la postura anterior; la nueva sesión vuelve a acostarse.
        user.ClearCraftingTaskData();
        let task=Find(user);if(task==null)task=CaelumBathTask(user.GiveInventoryType('CaelumBathTask'));
        if(task==null)return false;
        if(fixture is 'CaelumDomesticBathtub' && !CaelumHygienePose.Begin(user,fixture,true))return false;
        task.Revision=1;task.OriginMap=level.MapName;task.Fixture=fixture;task.WaterModel=waterModel;
        task.RemainingDegrees=degrees;task.RemovedDegrees=0;task.SpentWater=0;task.SpentSoap=0;
        user.ActiveCraftingStationActor=user;if(fixture!=null)user.ActiveCraftingStationActor=fixture;
        user.StartPreparedCraftingTask(CaelumConstants.CRAFTING_TASK_BATH,degrees*CaelumContaminationData.BATH_SECONDS_DEGREE);
        user.CraftingTaskRecipeIndex=-1;user.CraftingTaskNetworkCapabilities=0;
        user.EquipmentMenuOpen=false;user.CraftingMenuOpen=false;user.PersistCharacterState();
        CaelumNotifications.Notify(user,StringTable.Localize("CA_BATH_STARTED",false));return true;
    }
    static void Advance(CaelumPlayer user,double seconds)
    {
        if(!Attended(user)){Cancel(user);return;}
        let task=Find(user);double wanted=Min(task.RemainingDegrees,Max(0.0,seconds)/CaelumContaminationData.BATH_SECONDS_DEGREE);
        double dose=Min(wanted,Affordable(user,task.Fixture,task.WaterModel));
        if(dose>0)
        {
            double liters=CaelumContaminationRules.BathWaterLiters(dose,user.DerivedStats.BaseMass);
            double soap=CaelumContaminationRules.SoapGrams(liters);
            // Las precondiciones se comprueban juntas; no hay otra acción de juego entre ambos débitos.
            if(!SpendWater(user,task.Fixture,task.WaterModel,liters) || !CaelumSoapSupply.Spend(user,soap))
            {Cancel(user);return;}
            CaelumFoodIllness.Get(user).Contamination=Max(0.0,CaelumFoodIllness.Value(user)-dose);
            task.RemainingDegrees=Max(0.0,task.RemainingDegrees-dose);task.RemovedDegrees+=dose;
            task.SpentWater+=liters;task.SpentSoap+=soap;
            user.RefreshCarriedInventorySummary();
        }
        user.CraftingTaskRemainingSeconds=task.RemainingDegrees*CaelumContaminationData.BATH_SECONDS_DEGREE;
        if(task.RemainingDegrees<0.000000001 || CaelumFoodIllness.Value(user)<=0)
        {user.CraftingTaskRemainingSeconds=0;user.CompleteCraftingTask();}
        else if(dose<wanted || dose<=0)Cancel(user);
    }
    override void PreTravelled(){Cancel(CaelumPlayer(Owner));Super.PreTravelled();}
    Default {Inventory.Amount 1;Inventory.MaxAmount 1;Inventory.InterHubAmount 1;
        +INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE +INVENTORY.KEEPDEPLETED -INVENTORY.INVBAR}
    States {Spawn:TNT1 A -1;Stop;}
}

// Snapshot de la selección; las acciones de red vuelven a comprobar recursos y alcance.
class CaelumBathSession : Inventory
{
    bool Open;
    String OriginMap;
    CaelumDomesticFixture Fixture;
    Sector WaterModel;
    double Selected,Maximum,Liters,Soap,Credit,WaterCost,SoapCost;
    static clearscope CaelumBathSession Find(CaelumPlayer user)
    {return user==null?null:CaelumBathSession(user.FindInventory('CaelumBathSession'));}
    static bool Show(CaelumPlayer user)
    {
        if(CaelumBathTask.Active(user)){CaelumBathTask.Cancel(user);return true;}
        if(!CaelumCampTask.Available(user))return false;
        let pose=CaelumHygienePose.Find(user);
        let fixture=CaelumHygienePose.Active(user)?pose.Fixture:CaelumDomesticFixture.SourceFor(user);
        let model=fixture==null?CaelumWaterQuality.Model(user):null;
        if(!CaelumBathTask.SourceValid(user,fixture,model))
        {CaelumNotifications.Notify(user,StringTable.Localize("CA_BATH_NEED_SOURCE",false));return false;}
        let session=Find(user);if(session==null)session=CaelumBathSession(user.GiveInventoryType('CaelumBathSession'));
        if(session==null)return false;
        session.Open=true;session.OriginMap=level.MapName;session.Fixture=fixture;session.WaterModel=model;
        session.Selected=CaelumBathTask.Affordable(user,fixture,model);session.Refresh(user);
        user.EquipmentMenuOpen=false;return true;
    }
    bool Valid(CaelumPlayer user)
    {return OriginMap==level.MapName && CaelumCampTask.Available(user) && CaelumBathTask.SourceValid(user,Fixture,WaterModel);}
    void Refresh(CaelumPlayer user)
    {
        Maximum=CaelumBathTask.Affordable(user,Fixture,WaterModel);Selected=Clamp(Selected,0.0,Maximum);
        Liters=CaelumBathTask.WaterAvailable(user,Fixture,WaterModel);Soap=CaelumSoapSupply.Available(user);Credit=CaelumSoapSupply.Credit(user);
        WaterCost=CaelumContaminationRules.BathWaterLiters(Selected,user.DerivedStats.BaseMass);SoapCost=CaelumContaminationRules.SoapGrams(WaterCost);
    }
    void Act(CaelumPlayer user,int choice)
    {
        if(!Open || !Valid(user)){Open=false;return;}Refresh(user);
        if(choice==0){Open=false;return;}
        if(choice==1){if(CaelumBathTask.Begin(user,Fixture,WaterModel,Selected))Open=false;return;}
        if(choice==2)Selected=Max(0.0,Selected-1);
        if(choice==3)Selected=Min(Maximum,Selected+1);
        if(choice==4)Selected=Max(0.0,Selected-10);
        if(choice==5)Selected=Min(Maximum,Selected+10);
        if(choice==6)Selected=Maximum;
        Refresh(user);
    }
    override void Tick(){Super.Tick();if(Open){let user=CaelumPlayer(Owner);if(!Valid(user))Open=false;else Refresh(user);}}
    override void PreTravelled(){Open=false;CaelumBathTask.Cancel(CaelumPlayer(Owner));Super.PreTravelled();}
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE}
    States {Spawn:TNT1 A -1;Stop;}
}
