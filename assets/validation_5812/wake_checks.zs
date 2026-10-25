    CaelumEquipmentItem WakeReset(CaelumPlayer u)
    {
        let rest=CaelumRestState.Get(u);if(rest!=null)rest.Exhaustion=false;
        u.CurrentSleep=100;let item=CleanReset(u);u.CurrentSleep=100;
        for(int slot=0;slot<4;slot++)u.EquippedArmorItemId[slot]=0;
        u.ActiveWeaponItemId=item.ItemId;item.Equipped=true;return item;
    }
    void Collapse(CaelumPlayer u)
    {u.CurrentSleep=0;CaelumExhaustion.Sync(u);}
    void WakeNow(CaelumPlayer u)
    {u.CurrentSleep=CaelumExhaustion.RELEASE_ABOVE+1;CaelumRestState.Cancel(u);}
    void WakeCore(CaelumPlayer u)
    {
        let item=WakeReset(u);double water=CaelumCleaningSupplies.Water(u),soap=CaelumSoapSupply.Available(u);
        Collapse(u);
        Check(CaelumExhaustion.Locked(u) && CaelumRestState.IsSleeping(u) && !CaelumCleaningTask.Active(u),"exhaustion collapses immediately without cleaning first");
        CaelumRestState.Cancel(u);
        Check(CaelumExhaustion.Locked(u) && Near(CaelumCleaningSupplies.Water(u),water) && Near(CaelumSoapSupply.Available(u),soap),"locked wake attempt spends no cleaning resources");
        WakeNow(u);let task=CaelumCleaningTask.Find(u);
        Check(!CaelumRestState.IsActive(u) && CaelumCleaningTask.Active(u) && task.WakeQueue && !task.SleepAfter && task.Target==item,"eligible awakening starts the selected weapon queue while awake");
        Check(Near(CaelumContaminationStorage.Value(item),80) && Near(CaelumCleaningSupplies.Water(u),water),"starting wake cleaning does not charge or clean instantly");
        let forecast=new('CaelumTimeSkipModel');forecast.CaptureSkip(u,false);
        Check(forecast.Done && forecast.Reason=="CA_SKIP_FORECAST_EFFECT","wake queue cannot advertise an unsupported exact-date forecast");
        CaelumCleaningTask.Advance(u,1);double remaining=task.Remaining;
        CaelumRestState.Cancel(u);
        Check(Near(task.Remaining,remaining),"repeated wake callback does not restart active cleaning");
        CaelumCleaningTask.Advance(u,100);
        Check(!CaelumCleaningTask.Active(u) && !CaelumRestState.IsSleeping(u) && !task.WakeQueue && Near(CaelumContaminationStorage.Value(item),0),"completed wake cleanup leaves the character awake");
        Check(Near(CaelumCleaningSupplies.Water(u),water-0.16) && Near(CaelumSoapSupply.Available(u),soap-0.8),"wake cleaning pays approved water and soap once");

        item=WakeReset(u);Soap(u,0);Collapse(u);WakeNow(u);
        Check(!CaelumRestState.IsActive(u) && !CaelumCleaningTask.Active(u) && Near(CaelumContaminationStorage.Value(item),80),"missing supplies never block awakening or clean for free");
        item=WakeReset(u);Collapse(u);u.CombatTimeRemaining=5;WakeNow(u);
        Check(!CaelumRestState.IsActive(u) && !CaelumCleaningTask.Active(u) && Near(CaelumCleaningSupplies.Water(u),5),"combat awakening skips cleaning without spending water");
        item=WakeReset(u);Collapse(u);u.CurrentSleep=CaelumExhaustion.RELEASE_ABOVE+1;
        u.DamageMobj(null,null,1,'None',DMG_NO_ARMOR,0);
        Check(!CaelumRestState.IsActive(u) && !CaelumCleaningTask.Active(u),"external damage awakening cannot immediately start a cleaning task");
        item=WakeReset(u);Collapse(u);WakeNow(u);CaelumCleaningTask.Advance(u,1);double spent=CaelumCleaningSupplies.Water(u);
        CaelumCleaningTask.Cancel(u);CaelumExhaustion.Sync(u);
        Check(!CaelumCleaningTask.Active(u) && !CaelumCleaningTask.Find(u).WakeQueue && Near(CaelumCleaningSupplies.Water(u),spent),"cancelled wake cleaning stays cancelled and retains paid progress");

        item=WakeReset(u);let helmet=Gear(u,902002,CaelumConstants.EQUIPMENT_KIND_ARMOR,0,CaelumConstants.ARMOR_SLOT_HEAD);
        helmet.Equipped=true;u.EquippedArmorItemId[0]=helmet.ItemId;CaelumContaminationStorage.Set(helmet,60);
        u.ArmorModel.ArmorType[0]=helmet.ItemType;u.ArmorModel.Tier[0]=helmet.Tier;
        u.ArmorModel.Size[0]=helmet.EquipmentSize;u.ArmorModel.Durability[0]=helmet.Durability;
        Collapse(u);WakeNow(u);task=CaelumCleaningTask.Find(u);
        CaelumCleaningTask.Advance(u,100);
        Check(task.WakeQueue && task.Target==helmet && Near(CaelumContaminationStorage.Value(item),0),"post-wake queue continues from selected weapon to worn armor");
        CaelumCleaningTask.Advance(u,100);
        Check(!CaelumCleaningTask.Active(u) && !CaelumRestState.IsSleeping(u) && Near(CaelumContaminationStorage.Value(helmet),0),"final worn piece completes without putting the character back to sleep");
        item=WakeReset(u);Collapse(u);WakeNow(u);
        let bottle=CaelumWaterContainer(u.FindInventory('CaelumBottleLarge'));bottle.WaterLiters=0.04;
        CaelumCleaningTask.Advance(u,100);
        Check(!CaelumCleaningTask.Active(u) && !CaelumRestState.IsSleeping(u) && Near(CaelumContaminationStorage.Value(item),60),"late shortage ends wake queue after retaining partial cleaning");

        item=WakeReset(u);CaelumCleaningTask.Begin(u,item);task=CaelumCleaningTask.Find(u);CaelumCleaningTask.Advance(u,1);
        task.Revision=1;remaining=task.Remaining;spent=task.SpentWater;task.EnsureRevision();task.EnsureRevision();
        Check(task.Revision==2 && !task.WakeQueue && task.Target==item && Near(task.Remaining,remaining) && Near(task.SpentWater,spent),"revision1 cleaning migration is idempotent and retains progress and costs");
    }
    void WakeSeed(CaelumPlayer u)
    {
        let item=WakeReset(u);Collapse(u);WakeNow(u);CaelumCleaningTask.Advance(u,1);
        let task=CaelumCleaningTask.Find(u);let proof=CA502HProof(u.GiveInventoryType('CA502HProof'));
        proof.Water=CaelumCleaningSupplies.Water(u);proof.Contamination=CaelumContaminationStorage.Value(item);proof.Remaining=task.Remaining;
        Check(task.WakeQueue && !task.SleepAfter,"saved partial wake queue has an awake destination");
    }
    void WakeLoad(CaelumPlayer u,bool hub=false)
    {
        let task=CaelumCleaningTask.Find(u);let proof=CA502HProof(u.FindInventory('CA502HProof'));
        Check(task!=null && proof!=null,"saved wake queue and proof survive loading");if(task==null || proof==null)return;
        if(hub){Check(!CaelumCleaningTask.Active(u) && !task.WakeQueue && !task.SleepAfter,"map travel cancels wake work without resuming sleep");return;}
        Check(CaelumCleaningTask.Active(u) && task.WakeQueue && !CaelumRestState.IsSleeping(u),"loaded partial wake queue remains awake and active");
        Check(task.Remaining<=proof.Remaining && task.Remaining>0 && CaelumCleaningSupplies.Water(u)<=proof.Water,"load preserves paid work without restarting the piece");
        double expected=task.Remaining/60;
        for(int i=task.Next;i<task.Queue.Size();i++)
            if(task.Queue[i]!=null && task.Queue[i].Owner==u && CaelumContaminationStorage.Value(task.Queue[i])>0)
                expected+=CaelumCleaningSupplies.Area(task.Queue[i]);
        double water=CaelumCleaningSupplies.Water(u),soap=CaelumSoapSupply.Available(u);
        for(int piece=0;piece<9 && CaelumCleaningTask.Active(u);piece++)CaelumCleaningTask.Advance(u,1000);
        Check(!CaelumCleaningTask.Active(u) && !CaelumRestState.IsSleeping(u),"loaded wake queue finishes each remaining piece and stays awake");
        Check(Near(water-CaelumCleaningSupplies.Water(u),expected) && Near(soap-CaelumSoapSupply.Available(u),5*expected),"loaded queue pays only the exact remaining budgets, including exposed clothing");
        water=CaelumCleaningSupplies.Water(u);CaelumRestState.Cancel(u);
        Check(!CaelumCleaningTask.Active(u) && Near(water,CaelumCleaningSupplies.Water(u)),"completed loaded queue cannot charge twice");
    }
    void WakeLiveEnd(CaelumPlayer u)
    {
        let task=CaelumCleaningTask.Find(u);
        Check(task!=null && !CaelumCleaningTask.Active(u) && !task.WakeQueue && !CaelumRestState.IsSleeping(u),"ordinary native world ticks finish the entire wake queue while awake");
        Check(CaelumCleaningSupplies.Water(u)<5 && CaelumSoapSupply.Available(u)<100,"ordinary native wake cleaning consumes actual supplies");
    }
    void WakeLegacyLoad(CaelumPlayer u)
    {
        Check(CaelumExhaustion.Locked(u) && !CaelumCleaningTask.Active(u),"pre-feature exhausted save remains asleep without premature cleaning");
        WakeNow(u);let task=CaelumCleaningTask.Find(u);
        Check(CaelumCleaningTask.Active(u) && task.WakeQueue,"pre-feature exhaustion save gains cleanup only when waking");
    }
    void WakeManual(CaelumPlayer u)
    {
        WakeReset(u);Collapse(u);
        Console.Printf("CA502W Agotamiento real: aun no gasta agua/jabon. F2 permite despertar; F3 informa; F4 prueba sin jabon; F6 consola.");
    }
    void WakeStatus(CaelumPlayer u)
    {
        let task=CaelumCleaningTask.Find(u);let item=u.FindNativeEquipmentItemById(u.ActiveWeaponItemId);
        Console.Printf("CA502W Dormido=%d; limpieza=%d; contaminacion arma=%.4f; agua=%.4f L; jabon=%.4f g",CaelumRestState.IsSleeping(u),CaelumCleaningTask.Active(u),CaelumContaminationStorage.Value(item),CaelumCleaningSupplies.Water(u),CaelumSoapSupply.Available(u));
        if(task!=null && CaelumCleaningTask.Active(u))Console.Printf("CA502W Restan %.4f segundos del mundo; cola al despertar=%d",task.Remaining,task.WakeQueue);
    }
