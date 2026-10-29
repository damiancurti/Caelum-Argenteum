    CaelumEquipmentItem Gear(CaelumPlayer u,int id=902001,int kind=0,int type=0,int slot=0)
    {
        let item=u.FindNativeEquipmentItemById(id);
        if(item==null)
        {
            item=CaelumEquipmentItem(Actor.Spawn('CaelumWeaponPickup',u.Pos,NO_REPLACE));
            item.ItemId=id;item.AcquisitionResolved=true;item.PickupDataInitialized=true;item.Amount=1;
            item.EquipmentKind=kind;item.ItemType=type;item.ArmorSlot=slot;item.EquipmentSize=CaelumConstants.EQUIPMENT_SIZE_M;
            item.Tier=1;item.UnitWeight=1;item.Durability=100;item.AttachToOwner(u);
        }
        return item;
    }
    CaelumWaterContainer CleanWater(CaelumPlayer u)
    {
        for(Inventory cursor=u.Inv;cursor!=null;cursor=cursor.Inv)
        {let water=CaelumWaterContainer(cursor);if(water!=null)water.WaterLiters=0;}
        let water=CaelumWaterContainer(u.FindInventory('CaelumBottleLarge'));
        if(water==null)water=CaelumWaterContainer(u.GiveInventoryType('CaelumBottleLarge'));
        water.Amount=1;water.InMagicBox=false;water.WaterLiters=5;water.WaterQuality=CaelumWaterQuality.POTABLE;return water;
    }
    CaelumEquipmentItem CleanReset(CaelumPlayer u)
    {
        CaelumCleaningTask.Cancel(u);CaelumRestState.Cancel(u);BathReset(u,10,100);
        let session=CaelumCleaningSession.Find(u);if(session!=null)session.Open=false;
        for(Inventory cursor=u.Inv;cursor!=null;cursor=cursor.Inv)
            if(cursor is 'CaelumEquipmentItem')CaelumContaminationStorage.Set(cursor,0);
        let item=Gear(u,902001,CaelumConstants.EQUIPMENT_KIND_WEAPON,CaelumConstants.WEAPON_TYPE_SWORD);
        item.Equipped=false;item.InMagicBox=false;CaelumContaminationStorage.Set(item,80);
        CleanWater(u);if(!CaelumCleaningSupplies.Cloth(u))u.GiveInventoryType('CaelumCleaningCloth');
        u.EquipmentSelectionKind=item.EquipmentKind;u.EquipmentSelectionItemId=item.ItemId;
        u.EquipmentSelectionWeaponType=item.ItemType;u.EquipmentSelectionTier=item.Tier;u.EquipmentSelectionSize=item.EquipmentSize;
        return item;
    }
    void CleanCore(CaelumPlayer u)
    {
        let item=CleanReset(u);double body=CaelumFoodIllness.Value(u);
        Check(Near(CaelumCleaningSupplies.Area(item),0.16) && CaelumCleaningSupplies.Cloth(u),"M sword uses approved0.16m2 and native reusable cloth");
        Check(CaelumCleaningSession.Show(u),"selected native inventory item opens cleaning menu");
        let menu=CaelumCleaningSession.Find(u);
        Check(menu.Ready && menu.Item==item && Near(menu.WaterCost,0.16) && Near(menu.SoapCost,0.8),"menu previews exact item resources");
        menu.Act(u,1);let task=CaelumCleaningTask.Find(u);
        Check(CaelumCleaningTask.Attended(u) && !menu.Open && task.Target==item && Near(task.Remaining,9.6),"manual selection starts without station");
        Check(Near(CaelumCleaningSupplies.Water(u),5) && Near(CaelumSoapSupply.Available(u),100),"start has no upfront debit");
        Check(u.IsEquipmentItemCraftingLocked(item.ItemId),"active cleaning locks target identity against transfer");
        CaelumCleaningTask.Advance(u,4.8);
        Check(Near(CaelumContaminationStorage.Value(item),40) && Near(CaelumCleaningSupplies.Water(u),4.92)
            && Near(CaelumSoapSupply.Available(u),99.6) && Near(CaelumSoapSupply.Credit(u),0.6),"half cleaning spends0.08L0.4g and retains opened fraction");
        CaelumCleaningTask.Cancel(u);
        Check(!CaelumCleaningTask.Active(u) && !u.IsEquipmentItemCraftingLocked(item.ItemId) && Near(CaelumContaminationStorage.Value(item),40)
            && Near(CaelumCleaningSupplies.Water(u),4.92),"cancellation keeps paid progress and releases item");
        Check(CaelumCleaningTask.Begin(u,item),"partly dirty item can be cleaned again");CaelumCleaningTask.Advance(u,100);
        Check(!CaelumCleaningTask.Active(u) && Near(CaelumContaminationStorage.Value(item),0)
            && Near(CaelumCleaningSupplies.Water(u),4.76) && Near(CaelumSoapSupply.Available(u),98.8),"completion uses full approved surface budget on restart");
        u.CompleteCraftingTask();Check(Near(CaelumSoapSupply.Available(u),98.8) && !CaelumCleaningTask.Begin(u,item),"clean item and repeated completion spend nothing");
        Check(Near(CaelumFoodIllness.Value(u),body) && CaelumCleaningSupplies.Cloth(u),"equipment wash neither bathes body nor consumes cloth");
        item=CleanReset(u);let water=CaelumWaterContainer(u.FindInventory('CaelumBottleLarge'));water.WaterQuality=CaelumWaterQuality.BIOLOGICAL;
        Check(!CaelumCleaningTask.Begin(u,item) && Near(water.WaterLiters,5),"contaminated water rejected unchanged");
        water.WaterQuality=CaelumWaterQuality.POTABLE;water.InMagicBox=true;
        Check(!CaelumCleaningTask.Begin(u,item),"sealed Box water excluded like chemistry");water.InMagicBox=false;
        water.WaterLiters=0.159;Check(!CaelumCleaningTask.Begin(u,item),"insufficient full-piece water blocks manual start");
        water.WaterLiters=5;Soap(u,0);Check(!CaelumCleaningTask.Begin(u,item),"missing soap blocks start");
        Soap(u,1);CaelumSoapSupply.Spend(u,0.2);Check(u.CountCraftingMaterial(107,1)==0 && CaelumCleaningTask.Begin(u,item),"opened0.8g alone funds a sword");
        CaelumCleaningTask.Advance(u,100);Check(Near(CaelumSoapSupply.Available(u),0) && Near(water.WaterLiters,4.84),"last fractional gram spent exactly");
        item=CleanReset(u);let cloth=u.FindNativeSpecialItem(CaelumConstants.EQUIPMENT_KIND_KEY_ITEM,CaelumHygieneData.CLOTH_KEY);cloth.Destroy();
        Check(!CaelumCleaningTask.Begin(u,item),"missing cloth blocks start");
        item=CleanReset(u);CaelumCleaningTask.Begin(u,item);water=CaelumWaterContainer(u.FindInventory('CaelumBottleLarge'));water.WaterLiters=0.04;
        CaelumCleaningTask.Advance(u,9.6);
        Check(!CaelumCleaningTask.Active(u) && Near(CaelumContaminationStorage.Value(item),60) && Near(water.WaterLiters,0)
            && Near(CaelumSoapSupply.Available(u),99.8),"late water shortage preserves affordable quarter cleaning");
        item=CleanReset(u);CaelumCleaningTask.Begin(u,item);u.DamageMobj(null,null,1,'CaelumDiseaseDOT',DMG_NO_ARMOR,0);
        Check(CaelumCleaningTask.Active(u),"own illness does not interrupt equipment washing");u.DamageMobj(null,null,1,'Drowning',DMG_NO_ARMOR,0);
        Check(!CaelumCleaningTask.Active(u),"external damage interrupts equipment washing");
        item=CleanReset(u);u.GrantMagicBoxFromPalomo(false);item.InMagicBox=true;Check(CaelumCleaningTask.Begin(u,item),"owned stored equipment can be cleaned manually");CaelumCleaningTask.Advance(u,100);
        Check(item.InMagicBox && Near(CaelumContaminationStorage.Value(item),0),"manual washing retains Box location and identity");
        item=CleanReset(u);CaelumCleaningTask.Begin(u,item);double step=CaelumThermalRuntime.WorldTicSeconds();u.UpdateCraftingTask();
        Check(Near(task.Remaining,9.6-step),"native task coordinator uses world seconds");
        Check(CaelumTimeAdvanceState.BlockReason(u,false)=="","ordinary accelerated live waiting available");
        CaelumThermalBody.Get(u).Exposure=0;let projection=new('CaelumTimeSkipModel');projection.CaptureSkip(u,false);
        Check(!projection.Done && projection.CleaningTask,"independent forecast captures active single-piece cleaning");
        double beforeWater=CaelumCleaningSupplies.Water(u),beforeSoap=CaelumSoapSupply.Available(u);
        for(int i=0;i<100 && !projection.Done;i++)projection.RunBatch();
        Check(projection.Done && projection.Reason=="" && !projection.CleaningTask,"single-piece forecast reaches completion");
        Check(Near(CaelumCleaningSupplies.Water(u),beforeWater) && Near(CaelumSoapSupply.Available(u),beforeSoap),"forecast spends no live resources");
        int ticks=projection.ElapsedTics;for(int i=0;i<ticks;i++)CaelumTimeAdvanceState.SimulatePersonalTic(u);
        double forecastWater=0;for(int i=0;i<projection.Supplies.Size();i++)if(projection.Supplies[i].CleaningWater)forecastWater+=projection.Supplies[i].Liters;
        Check(!CaelumCleaningTask.Active(u) && Near(CaelumCleaningSupplies.Water(u),forecastWater)
            && Near(CaelumSoapSupply.Available(u),projection.CleaningSoap),"forecast and real accelerated time match water and soap");
        Check(Near(CaelumContaminationStorage.Value(item),projection.Contamination.Items[projection.CleaningIndex].Concentration)
            && Near(CaelumFoodIllness.Value(u),projection.FoodIllness.Contamination),"forecast and real time match equipment and body contamination");
        item=CleanReset(u);CaelumCleaningTask.Begin(u,item);
        u.FindNativeSpecialItem(CaelumConstants.EQUIPMENT_KIND_KEY_ITEM,CaelumHygieneData.CLOTH_KEY).Destroy();
        CaelumThermalBody.Get(u).Exposure=0;
        projection=new('CaelumTimeSkipModel');projection.CaptureSkip(u,false);
        Check(projection.Done && projection.Reason=="CA_SKIP_PROVISIONS","forecast refuses cleaning after cloth is lost");
        u.UpdateCraftingTask();Check(!CaelumCleaningTask.Active(u) && Near(CaelumCleaningSupplies.Water(u),5),"lost cloth cancels without additional spending");
        CaelumCleaningTask.Cancel(u);
    }
    void CleanSleep(CaelumPlayer u)
    {
        let item=CleanReset(u);u.ActiveWeaponItemId=item.ItemId;item.Equipped=true;
        let helmet=Gear(u,902002,CaelumConstants.EQUIPMENT_KIND_ARMOR,0,CaelumConstants.ARMOR_SLOT_HEAD);
        helmet.Equipped=true;helmet.InMagicBox=false;u.EquippedArmorItemId[0]=helmet.ItemId;CaelumContaminationStorage.Set(helmet,60);
        Check(CaelumRestState.Begin(u,CaelumRestRules.MODE_SLEEP,5),"voluntary sleep request accepted");let task=CaelumCleaningTask.Find(u);
        Check(CaelumCleaningTask.Active(u) && task.Target==item && task.SleepAfter && !CaelumRestState.IsActive(u),"selected weapon is washed before sleeping");
        let forecast=new('CaelumTimeSkipModel');forecast.CaptureSkip(u,false);
        Check(forecast.Done && forecast.Reason=="CA_SKIP_FORECAST_EFFECT","multi-piece sleep queue declines unsupported exact-date forecast");
        CaelumCleaningTask.Advance(u,100);
        Check(CaelumCleaningTask.Active(u) && task.Target==helmet && Near(CaelumContaminationStorage.Value(item),0),"queue continues with equipped head armor");
        double total=0.16+CaelumCleaningSupplies.Area(helmet);CaelumCleaningTask.Advance(u,100);
        Check(!CaelumCleaningTask.Active(u) && CaelumRestState.IsSleeping(u) && Near(CaelumContaminationStorage.Value(helmet),0),"sleep resumes after final equipped piece");
        Check(Near(CaelumCleaningSupplies.Water(u),5-total) && Near(CaelumSoapSupply.Available(u),100-total*5),"automatic queue pays each piece once");
        item=CleanReset(u);u.ActiveWeaponItemId=item.ItemId;item.Equipped=true;Soap(u,0);
        Check(CaelumRestState.Begin(u,CaelumRestRules.MODE_SLEEP,5) && CaelumRestState.IsSleeping(u)
            && Near(CaelumContaminationStorage.Value(item),80),"missing supplies do not block sleep or clean for free");
        item=CleanReset(u);u.ActiveWeaponItemId=item.ItemId;item.Equipped=true;
        Check(CaelumRestState.Begin(u,CaelumRestRules.MODE_SLEEP,5),"late-shortage sleep begins");
        let water=CaelumWaterContainer(u.FindInventory('CaelumBottleLarge'));water.WaterLiters=0.04;CaelumCleaningTask.Advance(u,100);
        Check(CaelumRestState.IsSleeping(u) && Near(CaelumContaminationStorage.Value(item),60),"late shortage also allows sleep after retaining paid progress");
        item=CleanReset(u);u.ActiveWeaponItemId=item.ItemId;item.Equipped=true;
        CaelumRestState.Begin(u,CaelumRestRules.MODE_SLEEP,5);CaelumCleaningTask.Cancel(u);
        Check(!CaelumRestState.IsActive(u) && !CaelumCleaningTask.Find(u).SleepAfter,"explicit cancellation discards pending sleep intent");
        item=CleanReset(u);u.ActiveWeaponItemId=item.ItemId;item.Equipped=true;
        let clothing=CaelumClothing.Equipped(u,0);Check(clothing!=null,"production head clothing available");
        helmet.Equipped=true;u.EquippedArmorItemId[0]=helmet.ItemId;
        CaelumContaminationStorage.Set(helmet,60);if(clothing!=null)CaelumContaminationStorage.Set(clothing,50);
        CaelumRestState.Begin(u,CaelumRestRules.MODE_SLEEP,5);CaelumCleaningTask.Advance(u,100);CaelumCleaningTask.Advance(u,100);
        Check(CaelumCleaningTask.Active(u) && task.Target==clothing,"head garment follows head armor in equipped slot order");
        CaelumCleaningTask.Advance(u,100);Check(CaelumRestState.IsSleeping(u),"clothing queue completes before sleep");
        item.Equipped=false;u.ActiveWeaponItemId=0;helmet.Equipped=false;u.EquippedArmorItemId[0]=0;
    }
    void CleanRepair(CaelumPlayer u)
    {
        let item=CleanReset(u);item.Equipped=false;item.Durability=1;
        u.StartPreparedCraftingTask(CaelumConstants.CRAFTING_TASK_REPAIR,1);u.CraftingTaskTargetItemId=item.ItemId;
        u.CraftingTaskRemainingSeconds=0;u.CompleteCraftingTask();
        Check(item.Durability==u.GetEquipmentTaskMaximumDurability(item) && CaelumCleaningTask.Active(u)
            && CaelumCleaningTask.Find(u).Target==item,"successful native repair completion starts cleaning only repaired item");
        CaelumCleaningTask.Advance(u,100);Check(Near(CaelumContaminationStorage.Value(item),0),"repaired piece completes normal progressive cleaning");
        item=CleanReset(u);Soap(u,0);item.Durability=1;
        u.StartPreparedCraftingTask(CaelumConstants.CRAFTING_TASK_REPAIR,1);u.CraftingTaskTargetItemId=item.ItemId;u.CompleteCraftingTask();
        Check(item.Durability==u.GetEquipmentTaskMaximumDurability(item) && !CaelumCleaningTask.Active(u)
            && Near(CaelumContaminationStorage.Value(item),80),"missing cleaning resources preserve successful repair");
    }
    void CleanSeed(CaelumPlayer u)
    {
        let item=CleanReset(u);CaelumCleaningTask.Begin(u,item);CaelumCleaningTask.Advance(u,1);
        let proof=CA502CleanProof(u.FindInventory('CA502CleanProof'));if(proof==null)proof=CA502CleanProof(u.GiveInventoryType('CA502CleanProof'));
        proof.Item=item;proof.Remaining=CaelumCleaningTask.Find(u).Remaining;proof.Water=CaelumCleaningSupplies.Water(u);proof.Soap=CaelumSoapSupply.Available(u);
        Check(CaelumCleaningTask.Attended(u) && proof.Remaining>0 && CaelumSoapSupply.Credit(u)>0,"partial equipment task and soap remainder ready for save");
    }
    void CleanLoad(CaelumPlayer u,bool hub=false)
    {
        let proof=CA502CleanProof(u.FindInventory('CA502CleanProof'));Check(proof!=null,"cleaning proof restored");if(proof==null)return;
        let task=CaelumCleaningTask.Find(u);
        Check(proof.Item!=null && proof.Item.Owner==u && proof.Item.ItemId==902001,"equipment identity retained by save or hub");
        if(hub)
        {Check(!CaelumCleaningTask.Active(u) && !task.SleepAfter && task.Queue.Size()==0,"hub travel cancels pending work without queued sleep");return;}
        Check(CaelumCleaningTask.Attended(u) && task.Target==proof.Item && task.Remaining>0 && task.Remaining<=proof.Remaining,"partial duration and target restored");
        double water=CaelumCleaningSupplies.Water(u),soap=CaelumSoapSupply.Available(u),remaining=task.Remaining;
        Check(Near(proof.Water-water,(proof.Remaining-remaining)/60) && Near(proof.Soap-soap,(proof.Remaining-remaining)/12),"load continuation has no duplicate resource debit");
        CaelumCleaningTask.Advance(u,100);
        Check(!CaelumCleaningTask.Active(u) && Near(CaelumContaminationStorage.Value(proof.Item),0)
            && Near(CaelumCleaningSupplies.Water(u),water-remaining/60),"loaded task completes exactly remaining budget");
    }
    void CleanStatus(CaelumPlayer u)
    {let item=u.GetSelectedNativeEquipmentItem();if(CaelumCleaningTask.Active(u))item=CaelumCleaningTask.Find(u).Target;Console.Printf("CA502H CLEAN C=%.6f water=%.6fL soap=%.6fg remainder=%.6fg remaining=%.6fs",CaelumContaminationStorage.Value(item),CaelumCleaningSupplies.Water(u),CaelumSoapSupply.Available(u),CaelumSoapSupply.Credit(u),u.CraftingTaskRemainingSeconds);}
    void CleanManual(CaelumPlayer u)
    {
        CleanReset(u);let shield=Gear(u,902003,CaelumConstants.EQUIPMENT_KIND_SHIELD,CaelumConstants.SHIELD_TYPE_TOWER);
        shield.EquipmentSize=CaelumConstants.EQUIPMENT_SIZE_XL;CaelumContaminationStorage.Set(shield,80);
        u.EquipmentSelectionKind=shield.EquipmentKind;u.EquipmentSelectionItemId=shield.ItemId;
        u.EquipmentSelectionShieldType=shield.ItemType;u.EquipmentSelectionSize=shield.EquipmentSize;
        Console.Printf("CA502H manual: tower shield XL gives time to cancel; inventory J or F2; F1 reset F3 status F4 sleep F6 console.");
    }
    void CleanLiveEnd(CaelumPlayer u)
    {
        Check(!CaelumCleaningTask.Active(u) && Near(CaelumCleaningSupplies.Water(u),4.84)
            && Near(CaelumSoapSupply.Available(u),99.2),"unpaused engine tics complete exact sword budget");
        Check(CaelumContaminationStorage.Value(u.FindNativeEquipmentItemById(902001))<20,"ambient exposure resumes after cleaned item");
    }
    void CleanManualSleep(CaelumPlayer u)
    {let item=CleanReset(u);u.ActiveWeaponItemId=item.ItemId;item.Equipped=true;Check(CaelumRestState.Begin(u,CaelumRestRules.MODE_SLEEP,5),"manual sleep queued after washing");}
    void CleanBag(CaelumPlayer u)
    {
        let item=CleanReset(u);u.ActiveWeaponItemId=item.ItemId;item.Equipped=true;
        let bag=CaelumSleepingBag(u.FindInventory('CaelumSleepingBag'));if(bag==null)bag=CaelumSleepingBag(u.GiveInventoryType('CaelumSleepingBag'));
        bag.InMagicBox=false;let mat=CaelumRestBag(Actor.Spawn('CaelumRestBag',u.Pos,NO_REPLACE));mat.Bag=bag;
        Check(CaelumRestState.Begin(u,CaelumRestRules.MODE_SLEEP,5,mat) && CaelumCleaningTask.KeepsBed(u,mat),"sleeping-bag support retained while washing before sleep");
        mat.Tick();Check(mat!=null && CaelumCleaningTask.Find(u).Bed==mat,"unoccupied support survives cleanup tick");
        CaelumCleaningTask.Advance(u,100);
        Check(CaelumRestState.IsSleeping(u) && CaelumRestState.Get(u).Furniture==mat && mat.Occupant==u,"sleep resumes on the same bag support");
        CaelumRestState.Cancel(u);Check(bag.Owner==u && bag.Amount==1,"waking retains exactly the original sleeping bag");
    }
    int HBoil,HBath;
    bool TrackH;
    void CleanSelect(CaelumPlayer u,Inventory selected)
    {
        u.FormalInventoryFilter=0;u.RefreshFormalInventorySnapshot();
        for(int i=0;i<u.FormalInventoryEntryCount;i++)if(u.GetFormalInventoryEntryAt(i)==selected){u.FormalInventorySelectionIndex=i;break;}
        u.RefreshFormalInventorySnapshot();
    }
    void CleanKeySetup(CaelumPlayer u,bool water)
    {
        let item=CleanReset(u);Inventory selected=item;
        if(water)selected=u.FindInventory('CaelumBottleLarge');CleanSelect(u,selected);TrackH=true;HBoil=0;HBath=0;
        Check(CaelumLiveMenu.InventoryHAction(u)==(water?"ca_inventory_boil":"ca_bath_open"),"inventory shortcut matches the selected native item");
    }
    override void ConsoleProcess(ConsoleEvent e)
    {
        if(e.Name=='ca502h_inventory')
        {let view=CaelumLiveMenu.Journal();view.SetJournalPage(0);view.SetJournalOpen(true);}
        else if(e.Name=='ca502h_press_h' || e.Name=='ca502h_press_j')
        {let menu=CaelumLiveMenu(Menu.GetCurrentMenu());if(menu!=null)menu.Stroke(0,e.Name=='ca502h_press_h'?104:106,e.Name=='ca502h_press_h'?"h":"j");else EventHandler.SendNetworkEvent("ca502h_ui_missing");}
    }
