    bool CalendarHold;
    String CalendarLine1,CalendarLine2,CalendarLine3,CalendarLine4;
    void CalendarObserve(CaelumPlayer u)
    {
        let s=CaelumTimeSkipState.Get(u);if(s==null)return;
        let r=CaelumRecipeSession.Get(u);
        CalendarLine1=s.SleepCleaning!=null?"LIMPIANDO ANTES DE DORMIR":s.Active && s.Sleeping?"DORMIDO - TRABAJO PAUSADO":s.Active?"DESPIERTO - TRABAJO EN CURSO":"ESPERA CANCELADA";
        CalendarLine2=String.Format("%s pendiente: %.2f s",r!=null && r.Active?"Lectura":"Fabricacion",r!=null && r.Active?r.RemainingSeconds:u.CraftingTaskRemainingSeconds);
        CalendarLine3=String.Format("Agua: %.4f L | Jabon: %.4f g",CaelumCleaningSupplies.Water(u),CaelumSoapSupply.Available(u));
        CalendarLine4=String.Format("Contaminacion arma: %.2f | Durmiendo: %d",CaelumContaminationStorage.Value(u.FindNativeEquipmentItemById(u.ActiveWeaponItemId)),s.Active && s.Sleeping);
    }
    bool CalendarWatch;
    double CalendarObservedWork;
    override void WorldThingDamaged(WorldEvent e)
    {if(CalendarHold && e.Thing==players[0].mo)Console.Printf("CA502C damage %d type=%s source=%s",e.Damage,e.DamageType,e.DamageSource!=null?e.DamageSource.GetClassName():'none');}
    override void WorldTick()
    {
        if(CalendarHold && players[0].mo!=null && level.maptime%7==0)CalendarObserve(CaelumPlayer(players[0].mo));
        if(CalendarWatch && players[0].mo!=null)
        {
            let u=CaelumPlayer(players[0].mo);let s=CaelumTimeSkipState.Get(u);
            if(s!=null && !s.Active && s.Completed){CalendarObservedWork=u.CraftingTaskRemainingSeconds;CalendarWatch=false;}
        }
        if(CalendarHold && players[0].mo!=null)
        {let s=CaelumTimeSkipState.Get(CaelumPlayer(players[0].mo));if(s!=null){if(s.Active && players[0].mo.health!=s.LastHealth)Console.Printf("CA502C health=%d last=%d max=%d",players[0].mo.health,s.LastHealth,CaelumPlayer(players[0].mo).CaelumMaximumHealth);s.LastPumpTic=level.maptime;}}
    }
    CaelumEquipmentItem CalendarReset(CaelumPlayer u)
    {
        CalendarHold=false;CaelumTimeSkipState.FinishSkip(u,"",true);
        let reading=CaelumRecipeSession.Get(u);if(reading!=null){reading.Active=false;reading.Open=false;}
        u.CancelCraftingTask();
        let item=WakeReset(u);u.CurrentLucidity=100;u.player.onground=true;u.UpdateSurvivalStates();
        let s=CaelumTimeSkipState.Get(u,true);s.Sleeping=false;s.Pumping=false;s.SleepCleaning=null;
        return item;
    }
    CaelumTimeSkipState CalendarStart(CaelumPlayer u)
    {
        u.CurrentSleep=CaelumTimeSkipRules.SleepAt();
        Check(CaelumTimeSkipState.OpenMenu(u),"calendar menu opens on the actual eligible task");
        let s=CaelumTimeSkipState.Get(u);s.UseTaskDefault=false;
        s.TargetDay=CaelumTimeSkipState.NowDay(u)+1;s.TargetTics=CaelumTimeSkipState.NowTics(u);
        Check(CaelumTimeSkipState.Start(u),"explicit calendar target starts safely");return s;
    }
    void CalendarFinishQueue(CaelumPlayer u)
    {
        let s=CaelumTimeSkipState.Get(u);
        for(int i=0;i<CaelumCleaningSupplies.EQUIPPED_COUNT+1 && s.Active && s.SleepCleaning!=null;i++)
        {s.SleepCleaning.Advance(u,1000);CaelumTimeSkipState.PrepareStep(u);}
    }
    CaelumCraftingStation CalendarCraft(CaelumPlayer u)
    {
        let station=CaelumCraftingStation(Actor.Spawn('CaelumWorkbenchStation',u.Pos+(48,0,0),NO_REPLACE));
        station.bSolid=false;u.ActiveCraftingStationActor=station;u.ActiveCraftingStationType=station.GetCraftingStationType();
        u.CraftingMenuOpen=true;u.CraftingSessionValidationTics=TICRATE;
        u.StartPreparedCraftingTask(CaelumConstants.CRAFTING_TASK_PROCESSING,600);
        u.CraftingTaskReservedUnits[0]=17;u.CraftingTaskReservedType[0]=CaelumConstants.MATERIAL_WOOD;
        u.CraftingTaskNetworkCapabilities=0;return station;
    }
    CaelumRecipeSession CalendarReading(CaelumPlayer u)
    {
        let book=CaelumRecipeBook(u.GiveInventoryType('CaelumRecipeBook'));
        let shelf=Actor.Spawn('CaelumReadingShelf',u.Pos+(32,0,0),NO_REPLACE);shelf.bSolid=false;
        let r=CaelumRecipeSession.Get(u,true);r.Book=book;r.Anchor=shelf;r.Open=true;r.Active=true;
        r.TotalSeconds=600;r.RemainingSeconds=600;r.TaskSlot=0;r.TaskSheets.Push(0);return r;
    }
    void CalendarCore(CaelumPlayer u)
    {
        let item=CalendarReset(u);let station=CalendarCraft(u);let s=CalendarStart(u);
        Check(s.SleepCleaning!=null && s.SleepCleaning.Target==item && !s.Sleeping && CaelumTimeSkipState.PausesWork(u),"calendar holds sleep and crafting while selected weapon is cleaned");
        double water=CaelumCleaningSupplies.Water(u),soap=CaelumSoapSupply.Available(u);
        int recipe=u.CraftingTaskRecipeIndex;u.UpdateCraftingTask();
        Check(Near(u.CraftingTaskRemainingSeconds,600) && u.ActiveCraftingStationActor==station
            && u.CraftingTaskRecipeIndex==recipe && u.CraftingTaskReservedUnits[0]==17,"paused craft keeps its station recipe reservation and remaining work");
        Check(u.IsEquipmentItemCraftingLocked(item.ItemId),"calendar cleaning target cannot be transferred");
        CaelumTimeSkipState.AfterStep(u);let plan=s.SleepCleaning;
        double step=CaelumThermalRuntime.WorldTicSeconds();
        Check(Near(plan.SpentWater,step/60) && Near(plan.SpentSoap,step/12)
            && Near(water-CaelumCleaningSupplies.Water(u),step/60),"calendar pays one approved progressive cleaning dose per world step");
        CalendarFinishQueue(u);
        Check(s.Active && s.Sleeping && s.SleepCleaning==null && Near(CaelumContaminationStorage.Value(item),0),"finished calendar cleaning enters sleep");
        Check(Near(water-CaelumCleaningSupplies.Water(u),0.16) && Near(soap-CaelumSoapSupply.Available(u),0.8),"calendar sword budget is charged exactly once");
        u.UpdateCraftingTask();Check(Near(u.CraftingTaskRemainingSeconds,600),"original craft remains paused during sleep");
        u.CurrentSleep=100;CaelumTimeSkipState.PrepareStep(u);u.UpdateCraftingTask();
        Check(s.Active && !s.Sleeping && u.CraftingTaskRemainingSeconds<600 && u.CraftingTaskReservedUnits[0]==17,"original craft resumes after sleep without replacing reserved materials");
        CaelumTimeSkipState.FinishSkip(u,"",true);u.CancelCraftingTask();station.Destroy();

        item=CalendarReset(u);let reading=CalendarReading(u);s=CalendarStart(u);
        let book=reading.Book;let anchor=reading.Anchor;reading.Advance();
        Check(Near(reading.RemainingSeconds,600) && reading.Book==book && reading.Anchor==anchor && reading.TaskSheets.Size()==1,"recipe reading retains book sheets anchor and progress while cleaning");
        CalendarFinishQueue(u);reading.Advance();Check(Near(reading.RemainingSeconds,600),"recipe reading stays paused during calendar sleep");
        u.CurrentSleep=100;CaelumTimeSkipState.PrepareStep(u);reading.Advance();
        Check(reading.RemainingSeconds<600 && reading.Active,"reading resumes after calendar awakening");
        CaelumTimeSkipState.FinishSkip(u,"",true);

        item=CalendarReset(u);CaelumCleaningTask.Begin(u,item);CaelumCleaningTask.Advance(u,1);
        water=CaelumCleaningSupplies.Water(u);soap=CaelumSoapSupply.Available(u);
        double remaining=CaelumCleaningTask.Find(u).Remaining;s=CalendarStart(u);
        Check(s.SleepCleaning!=null && s.SleepCleaning.WaitingExisting && !CaelumTimeSkipState.PausesWork(u),"existing manual cleanup continues before automatic sleep preparation");
        CaelumCleaningTask.Advance(u,100);CaelumTimeSkipState.AfterStep(u);CaelumTimeSkipState.PrepareStep(u);
        Check(s.Sleeping && s.SleepCleaning==null && Near(water-CaelumCleaningSupplies.Water(u),remaining/60)
            && Near(soap-CaelumSoapSupply.Available(u),remaining/12),"already cleaned manual piece is not charged again before calendar sleep");
        CaelumTimeSkipState.FinishSkip(u,"",true);

        item=CalendarReset(u);Soap(u,0);s=CalendarStart(u);
        Check(s.Sleeping && s.SleepCleaning==null && Near(CaelumCleaningSupplies.Water(u),5)
            && Near(CaelumContaminationStorage.Value(item),80),"no soap skips calendar cleanup without blocking sleep or spending water");
        CaelumTimeSkipState.FinishSkip(u,"",true);
        item=CalendarReset(u);s=CalendarStart(u);plan=s.SleepCleaning;
        CaelumWaterContainer(u.FindInventory('CaelumBottleLarge')).WaterLiters=0.04;
        plan.Advance(u,100);CaelumTimeSkipState.PrepareStep(u);
        Check(s.Sleeping && Near(CaelumContaminationStorage.Value(item),60) && Near(CaelumCleaningSupplies.Water(u),0),"late water shortage retains partial wash and permits sleep");
        CaelumTimeSkipState.FinishSkip(u,"",true);
        item=CalendarReset(u);s=CalendarStart(u);s.SleepCleaning.Advance(u,1);
        water=CaelumCleaningSupplies.Water(u);double dirt=CaelumContaminationStorage.Value(item);
        CaelumTimeSkipState.FinishSkip(u,"CA_SKIP_CANCELLED",true);
        Check(!s.Active && s.SleepCleaning==null && !CaelumSleepRules.IsSleeping(u)
            && !u.IsEquipmentItemCraftingLocked(item.ItemId) && Near(CaelumCleaningSupplies.Water(u),water)
            && Near(CaelumContaminationStorage.Value(item),dirt),"cancel releases calendar queue and lock while preserving paid progress");
        item=CalendarReset(u);s=CalendarStart(u);water=CaelumCleaningSupplies.Water(u);
        u.DamageMobj(null,null,1,'None',DMG_NO_ARMOR,0);CaelumTimeSkipState.PrepareStep(u);
        Check(!s.Active && s.SleepCleaning==null && Near(CaelumCleaningSupplies.Water(u),water),"external damage cancels calendar cleaning before another charge");
        CalendarReset(u);
    }
    void CalendarForecast(CaelumPlayer u)
    {
        CalendarReset(u);let station=CalendarCraft(u);u.CurrentSleep=CaelumTimeSkipRules.SleepAt();
        CaelumThermalBody.Get(u).Exposure=0;
        let model=new('CaelumTimeSkipModel');model.CaptureSkip(u,false);
        Check(!model.Done && model.NeedsSleepCleaning(),"forecast captures equipped cleaning candidates and own supplies");
        model.RunBatch();
        Check(model.Done && model.Reason=="CA_SKIP_FORECAST_EFFECT" && model.ProductiveTics==0
            && Near(CaelumCleaningSupplies.Water(u),5),"forecast refuses unsupported pre-sleep queue without consuming real supplies");
        u.CancelCraftingTask();station.Destroy();CalendarReset(u);
    }
    void CalendarEdges(CaelumPlayer u)
    {
        let item=CalendarReset(u);let s=CalendarStart(u);int health=u.health;
        u.SleepState=CaelumConstants.SURVIVAL_STATE_CRITICAL;u.SurvivalDamageAccumulator=1;
        CaelumPlayerResources.ApplyCriticalSurvivalDamage(u);CaelumTimeSkipState.AfterStep(u);
        Check(u.health<health && s.Active && s.SleepCleaning!=null,"fatigue still damages during preparation without cancelling automatic sleep");
        CalendarFinishQueue(u);u.CurrentSleep=100;CaelumTimeSkipState.PrepareStep(u);
        CaelumContaminationStorage.Set(item,40);u.CurrentSleep=CaelumTimeSkipRules.SleepAt();CaelumTimeSkipState.PrepareStep(u);
        Check(s.SleepCleaning!=null && s.SleepCleaning.Target==item,"a later sleep cycle captures newly contaminated equipment");
        CaelumTimeSkipState.FinishSkip(u,"",true);
        item=CalendarReset(u);s=CalendarStart(u);u.HungerState=CaelumConstants.SURVIVAL_STATE_CRITICAL;
        u.SurvivalDamageAccumulator=1;CaelumPlayerResources.ApplyCriticalSurvivalDamage(u);CaelumTimeSkipState.AfterStep(u);
        Check(!s.Active,"critical hunger still interrupts preparation");
        item=CalendarReset(u);s=CalendarStart(u);u.SetOrigin(u.Pos+(8,0,0),false);CaelumTimeSkipState.PrepareStep(u);
        Check(!s.Active && s.SleepCleaning==null,"movement cancels preparation");
        item=CalendarReset(u);s=CalendarStart(u);item.InMagicBox=true;
        // Ownership and the active item lock are tested separately from normal UI transfer prevention.
        u.RemoveInventory(item);s.SleepCleaning.Advance(u,1);CaelumTimeSkipState.PrepareStep(u);
        Check(s.Sleeping && Near(CaelumCleaningSupplies.Water(u),5),"missing target never charges water");
        item.AttachToOwner(u);item.InMagicBox=false;CalendarReset(u);
    }
    void CalendarLegacyLoad(CaelumPlayer u)
    {
        let s=CaelumTimeSkipState.Get(u);
        Check(s.Active && s.Sleeping && s.HygieneRevision==1 && s.SleepCleaning==null,"genuine prior-runtime sleep migrates without retroactive cleaning");
        Check(u.CraftingTaskReservedUnits[0]==17 && Near(u.CraftingTaskRemainingSeconds,600),"legacy migration keeps reserved craft");
        u.CurrentSleep=100;CaelumTimeSkipState.PrepareStep(u);
        u.CurrentSleep=CaelumTimeSkipRules.SleepAt();CaelumTimeSkipState.PrepareStep(u);
        Check(s.Active && s.SleepCleaning!=null,"next sleep cycle uses cleaning after legacy migration");
        CaelumTimeSkipState.FinishSkip(u,"",true);
    }
    void CalendarExistingLoad(CaelumPlayer u)
    {
        let s=CaelumTimeSkipState.Get(u);let task=CaelumCleaningTask.Find(u);
        Check(s.Active && s.SleepCleaning!=null && s.SleepCleaning.WaitingExisting && CaelumCleaningTask.Active(u),"save restores calendar waiting for existing manual wash");
        if(s.SleepCleaning==null || task==null)return;
        let item=task.Target;double remaining=task.Remaining,water=CaelumCleaningSupplies.Water(u);
        CaelumCleaningTask.Advance(u,100);
        Check(s.SleepCleaning.WasCleaned(item) && Near(water-CaelumCleaningSupplies.Water(u),remaining/60),"restored existing wash pays only its saved remaining work");
        CaelumTimeSkipState.AfterStep(u);CaelumTimeSkipState.PrepareStep(u);
        Check(s.Sleeping || (s.SleepCleaning!=null && s.SleepCleaning.Target!=item),"restored completed piece is excluded from calendar preparation");
        CalendarFinishQueue(u);Check(s.Sleeping && !CaelumCleaningTask.Active(u),"saved existing cleanup reaches automatic sleep");
        CaelumTimeSkipState.FinishSkip(u,"",true);
    }
    void CalendarManual(CaelumPlayer u,int kind=0)
    {
        let item=CalendarReset(u);
        if(kind==1){CaelumCleaningTask.Begin(u,item);CaelumCleaningTask.Advance(u,1);}
        else if(kind==3)CalendarReading(u);
        else CalendarCraft(u);
        if(kind==2)Soap(u,0);
        CalendarStart(u);CalendarHold=true;CalendarStatus(u);
    }
    void CalendarAccelerated(CaelumPlayer u,bool finish=false)
    {
        if(!finish)
        {
            CalendarManual(u);let s=CaelumTimeSkipState.Get(u);CalendarHold=false;CalendarWatch=true;CalendarObservedWork=-1;
            s.TargetDay=CaelumTimeSkipState.NowDay(u);s.TargetTics=CaelumTimeSkipState.NowTics(u)+CaelumWorldClock.TicsPerHour()/6;
            if(s.TargetTics>=CaelumWorldClock.TicsPerDay()){s.TargetTics-=CaelumWorldClock.TicsPerDay();s.TargetDay++;}
            return;
        }
        let s=CaelumTimeSkipState.Get(u);CalendarStatus(u);
        Check(!s.Active && s.Completed && s.LastReason=="CA_SKIP_COMPLETE" && s.SleepCleaning==null,"normal accelerated calendar reaches its target after cleanup");
        Check(s.SleepTics>0 && Near(CalendarObservedWork,600) && CaelumSoapSupply.Available(u)<100,"accelerated cleanup charges real supplies and pauses original craft during sleep");
        CaelumTimeSkipState.FinishSkip(u,"",true);
    }
    void CalendarWake(CaelumPlayer u)
    {
        let s=CaelumTimeSkipState.Get(u);
        if(s.SleepCleaning!=null){Console.Printf("CA502C Espera a que termine la limpieza antes de F3.");return;}
        u.CurrentSleep=100;CaelumTimeSkipState.PrepareStep(u);u.UpdateCraftingTask();
        let r=CaelumRecipeSession.Get(u);if(r!=null)r.Advance();CalendarStatus(u);
    }
    void CalendarSeed(CaelumPlayer u,bool manual=false)
    {
        CalendarReset(u);CalendarCraft(u);let s=CalendarStart(u);CalendarHold=true;
        if(s.SleepCleaning==null){Check(false,"calendar seed has a serializable cleanup");return;}
        s.SleepCleaning.Advance(u,1);
        let proof=CA502HProof(u.GiveInventoryType('CA502HProof'));
        proof.Water=CaelumCleaningSupplies.Water(u);proof.Remaining=s.SleepCleaning.Remaining;
        proof.Capacity=u.CraftingTaskRemainingSeconds;
        Check(s.Active && s.SleepCleaning.Remaining>0 && Near(proof.Capacity,600),"calendar partial cleaning and original craft ready for save");
        if(manual)CalendarStatus(u);
    }
    void CalendarLoad(CaelumPlayer u,bool hub=false)
    {
        let s=CaelumTimeSkipState.Get(u);let proof=CA502HProof(u.FindInventory('CA502HProof'));
        Check(s!=null && proof!=null,"calendar save restores session and independent proof");if(s==null || proof==null)return;
        if(hub){Check(!s.Active && s.SleepCleaning==null,"map departure cancels saved calendar cleanup");return;}
        Check(s.Active && s.HygieneRevision==1 && s.SleepCleaning!=null && s.SleepCleaning.Revision==1,"saved pre-sleep queue retains schema and active phase");
        if(s.SleepCleaning==null)return;
        Check(Near(u.CraftingTaskRemainingSeconds,proof.Capacity) && u.CraftingTaskReservedUnits[0]==17
            && Near(proof.Water-CaelumCleaningSupplies.Water(u),(proof.Remaining-s.SleepCleaning.Remaining)/60),"save retains original reserved craft and exact paid cleanup progress");
        CalendarFinishQueue(u);Check(s.Sleeping && Near(u.CraftingTaskRemainingSeconds,600),"loaded calendar queue finishes before unchanged craft sleeps");
        u.CurrentSleep=100;CaelumTimeSkipState.PrepareStep(u);u.UpdateCraftingTask();
        Check(u.CraftingTaskRemainingSeconds<600,"loaded original craft resumes after awakening");
        CaelumTimeSkipState.FinishSkip(u,"",true);
    }
    void CalendarLiveEnd(CaelumPlayer u)
    {
        let s=CaelumTimeSkipState.Get(u);
        CalendarStatus(u);
        Console.Printf("CA502C detail reason=%s sleep=%.6f work=%.8f cleanup=%.8f",s.LastReason,u.CurrentSleep,u.CraftingTaskRemainingSeconds,s.SleepCleaning!=null?s.SleepCleaning.Remaining:-1);
        Check(s.Active && s.Sleeping && s.SleepCleaning==null && Near(u.CraftingTaskRemainingSeconds,600),"ordinary unpaused native clock completes cleanup then sleeps with craft paused");
        Check(CaelumCleaningSupplies.Water(u)<5 && CaelumSoapSupply.Available(u)<100,"live calendar cleanup consumes real water and soap");
        u.CurrentSleep=100;CaelumTimeSkipState.PrepareStep(u);u.UpdateCraftingTask();
        Check(!s.Sleeping && u.CraftingTaskRemainingSeconds<600,"live calendar wake resumes original crafting");
        CaelumTimeSkipState.FinishSkip(u,"",true);
    }
    void CalendarStatus(CaelumPlayer u)
    {
        let s=CaelumTimeSkipState.Get(u);
        Console.Printf("CA502C Espera=%d; durmiendo=%d; limpieza previa=%d; tarea original=%.4f s; agua=%.4f L; jabon=%.4f g",s.Active,s.Sleeping,s.SleepCleaning!=null,u.CraftingTaskRemainingSeconds,CaelumCleaningSupplies.Water(u),CaelumSoapSupply.Available(u));
        let r=CaelumRecipeSession.Get(u);if(r!=null && r.Active)Console.Printf("CA502C Lectura pendiente=%.4f s",r.RemainingSeconds);
        Console.Printf("CA502C Contaminacion arma=%.4f; motivo=%s",CaelumContaminationStorage.Value(u.FindNativeEquipmentItemById(u.ActiveWeaponItemId)),s.LastReason);
    }
