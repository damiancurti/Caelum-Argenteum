class Issue64Checks : Object play
{
    static void Check(bool ok,String label) {Console.Printf("QA64 %s %s",ok?"PASS":"FAIL",label);}
    static int Equipment(CaelumPlayer u)
    {int count=0;for(Inventory i=u.Inv;i!=null;i=i.Inv)if(CaelumEquipmentItem(i)!=null)count++;return count;}
    static int Materials(CaelumPlayer u)
    {
        int count=0;for(Inventory i=u.Inv;i!=null;i=i.Inv)
        {let item=CaelumSpecialInventoryItem(i);if(item!=null && item.GetSpecialCategory()==CaelumConstants.EQUIPMENT_KIND_MATERIAL)count+=item.Amount;}
        return count;
    }
    static void Setup(CaelumPlayer u)
    {
        u.CharacterCreationComplete=true;u.CreationWizardOpen=false;
        let r=u.GetPersistentCharacterState(true);r.EnsureQuestStateInitialized();
        r.DemoNarrativeDelivered=2047;r.DemoNarrativePending=0;r.ProfileCommitted=true;
        r.QuestState[0]=CaelumConstants.QUEST_STATE_ACTIVE;r.QuestStage[0]=CaelumConstants.MAIN_M00_STATE_MET_PALOMO;
        r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_UNKNOWN_VOICE_HEARD);
        u.ApplyCharacterProfile();u.health=u.CaelumMaximumHealth;u.CurrentAir=u.DerivedStats.MaximumAir;
        if(u.player.ConversationNPC!=null)u.player.ConversationNPC.bInConversation=false;
        u.player.ConversationNPC=null;u.GrantMagicBoxFromPalomo(false);
        u.CurrentHunger=100;u.CurrentThirst=100;u.CurrentSleep=100;
        let it=ThinkerIterator.Create("CaelumCraftingStation");CaelumCraftingStation station;
        while((station=CaelumCraftingStation(it.Next()))!=null)
            if(station.CraftingRoomGroup==5 && station.GetCraftingStationType()==CaelumConstants.CRAFTING_STATION_WORKBENCH)
            {u.SetOrigin(station.Pos+(0,48,0),false);u.Vel=(0,0,0);station.CollectCraftingNetwork(u,u.BeginCraftingNetworkScan());u.OpenCraftingNetwork(station);break;}
        u.GiveInventory("CaelumFoodRation",20);u.GiveInventory("CaelumWaterRation",20);
        u.PersistCharacterState();
        Console.Printf("QA64 SETUP pos=(%.0f,%.0f,%.0f)",u.Pos.X,u.Pos.Y,u.Pos.Z);
    }
    static bool Task(CaelumPlayer u,double seconds)
    {
        let r=u.GetPersistentCharacterState(true);
        int recipe=CaelumConstants.CRAFTING_NETWORK_LEGACY_RECIPE_COUNT;
        r.LearnCraftingRecipe(recipe);u.CraftingSelectionRecipe=recipe;u.CraftingSelectionTier=1;
        u.CraftingSelectionSize=CaelumConstants.EQUIPMENT_SIZE_M;u.CraftingEfficiencyIndex=2;u.ResetCraftingLayerChoices();
        u.RefreshCraftingPreview();
        Material(u,u.CraftingBasicMaterialType,u.CraftingBasicMaterialTier,u.CraftingBasicRequired);
        Material(u,u.CraftingTierMaterialType,u.CraftingTierMaterialTier,u.CraftingTierRequired);
        Material(u,CaelumConstants.MATERIAL_SILVER_INGOT,1,u.CraftingSilverRequired);
        Material(u,CaelumConstants.MATERIAL_GOLD_INGOT,1,u.CraftingGoldRequired);
        u.OnNativeInventoryChanged();u.RefreshCraftingPreview();u.BeginSelectedCraftingTask();
        Check(u.CraftingTaskActive,"native shield task reserves materials");
        Console.Printf("QA64 TASK action=%d known=%d infrastructure=%d station=%d menu=%d combat=%.2f conversation=%d velocity=%.4f ground=%d water=%d",u.LastCraftingAction,u.CraftingSelectedRecipeKnown,u.CraftingSelectedInfrastructureAvailable,u.ActiveCraftingStationActor!=null,u.CraftingMenuOpen,u.CombatTimeRemaining,u.HasActiveConversation(),u.Vel.Length(),u.player.onground,u.WaterLevel);
        if(u.CraftingTaskActive)u.CraftingTaskRemainingSeconds=seconds;
        return u.CraftingTaskActive;
    }
    static void Material(CaelumPlayer u,int kind,int tier,int amount)
    {
        if(amount<=0)return;
        let item=u.CreateDetachedMaterialStack(kind,tier,amount);item.InMagicBox=false;item.AttachToOwner(u);
    }
    static void Report(CaelumPlayer u)
    {
        let s=CaelumTimeSkipState.Get(u);let clock=CaelumWorldClock.Get(u);let cal=CaelumCalendarState.Get(u);
        Console.Printf("QA64 STATE local=%s outside=%s hunger=%.8f thirst=%.8f sleep=%.8f task=%d remaining=%.8f",clock.FormatStamp(clock.LocalDays(),clock.LocalTics(),true),cal.FormatDate(clock),u.CurrentHunger,u.CurrentThirst,u.CurrentSleep,u.CraftingTaskActive,u.CraftingTaskRemainingSeconds);
        if(s!=null)Console.Printf("QA64 SKIP open=%d active=%d sleeping=%d elapsed=%d work=%d sleepTics=%d reason=%s target=%d/%d forecast=%s",s.Open,s.Active,s.Sleeping,s.ElapsedTics,s.WorkTics,s.SleepTics,s.LastReason,s.TargetDay,s.TargetTics,s.Forecast!=null?s.Forecast.Reason:"none");
    }
}
class Issue64Setup : CaelumSocialDebugAction
{override bool Use(bool pickup){Issue64Checks.Setup(CaelumPlayer(Owner));return true;}}
class Issue64Report : CaelumSocialDebugAction
{override bool Use(bool pickup){Issue64Checks.Report(CaelumPlayer(Owner));return true;}}
class Issue64Preview : CaelumSocialDebugAction
{
    virtual double InitialSleep(){return 9.9;}
    override bool Use(bool pickup)
    {
        let u=CaelumPlayer(Owner);Issue64Checks.Task(u,120);u.CurrentSleep=InitialSleep();u.CurrentHunger=95;u.CurrentThirst=95;
        Console.Printf("QA64 BLOCK %s",CaelumTimeSkipRules.BlockReason(u));
        let it=ThinkerIterator.Create("Actor");Actor a;
        while((a=Actor(it.Next()))!=null)if(a!=u && (a.bMissile || (a.bIsMonster && a.health>0 && !a.bFriendly)))
            Console.Printf("QA64 THREAT %s distance=%.0f pos=(%.0f,%.0f,%.0f)",a.GetClassName(),a.Distance2D(u),a.Pos.X,a.Pos.Y,a.Pos.Z);
        Issue64Checks.Check(CaelumTimeSkipState.OpenMenu(u),"open explicit destination selector");
        Issue64Checks.Report(u);return true;
    }
}
class Issue64PreviewAwake : Issue64Preview {override double InitialSleep(){return 100;}}
class Issue64Begin : CaelumSocialDebugAction
{
    override bool Use(bool pickup)
    {
        let u=CaelumPlayer(Owner);let watch=Issue64Audit(u.GiveInventoryType("Issue64Audit"));watch.Mode=5;
        watch.Before=Issue64Checks.Equipment(u);let clock=CaelumWorldClock.Get(u);let cal=CaelumCalendarState.Get(u);
        watch.Civil=cal.DateSerial(clock);watch.CivilTics=cal.CivilDayTics(clock);
        watch.MaterialBefore=Issue64Checks.Materials(u);
        for(int i=0;i<CaelumConstants.CRAFTING_TASK_MATERIAL_SLOT_COUNT;i++)
        {
            watch.Reserved+=u.CraftingTaskReservedUnits[i];
            if(u.CraftingTaskReservedUnits[i]>0)Console.Printf("QA64 RESERVED type=%d tier=%d units=%d raw=%d",u.CraftingTaskReservedType[i],u.CraftingTaskReservedTier[i],u.CraftingTaskReservedUnits[i],u.CountRawCraftingMaterial(u.CraftingTaskReservedType[i],u.CraftingTaskReservedTier[i]));
        }
        for(Inventory item=u.Inv;item!=null;item=item.Inv)
            if(CaelumSpecialInventoryItem(item)!=null)Console.Printf("QA64 SPECIAL %s kind=%d amount=%d",item.GetClassName(),CaelumSpecialInventoryItem(item).GetSpecialCategory(),item.Amount);
        Issue64Checks.Check(CaelumTimeSkipState.Start(u),"confirm skip");Issue64Checks.Report(u);return true;
    }
}
class Issue64UIControl : StaticEventHandler
{
    override void UiTick()
    {
        let menu=ConversationMenu(Menu.GetCurrentMenu());
        let u=consoleplayer>=0?CaelumPlayer(players[consoleplayer].mo):null;
        if(menu!=null && u!=null && u.CraftingMenuOpen)menu.Close();
    }
}
class Issue64SleepEight : CaelumSocialDebugAction
{
    override bool Use(bool pickup)
    {
        let u=CaelumPlayer(Owner);if(!Issue64Checks.Task(u,120))return true;
        u.CurrentSleep=0;u.CurrentHunger=95;u.CurrentThirst=95;
        let clock=CaelumWorldClock.Get(u);clock.LimboSubTics=0;
        Issue64Checks.Check(CaelumTimeSkipState.OpenMenu(u),"eight-hour sleep opens");
        let s=CaelumTimeSkipState.Get(u);s.UseTaskDefault=false;
        s.TargetDay=clock.LocalDays();s.TargetTics=clock.LocalTics()+8*CaelumWorldClock.TicsPerHour();
        if(s.TargetTics>=CaelumWorldClock.TicsPerDay()){s.TargetDay++;s.TargetTics-=CaelumWorldClock.TicsPerDay();}
        let watch=Issue64Audit(u.GiveInventoryType("Issue64Audit"));watch.Mode=1;
        watch.Before=Issue64Checks.Equipment(u);watch.Remaining=u.CraftingTaskRemainingSeconds;
        watch.MaterialBefore=Issue64Checks.Materials(u);
        let cal=CaelumCalendarState.Get(u);watch.Civil=cal.DateSerial(clock);watch.CivilTics=cal.CivilDayTics(clock);
        Issue64Checks.Check(CaelumTimeSkipState.Start(u),"eight-hour sleep begins");return true;
    }
}
class Issue64Audit : Inventory
{
    int Mode, Before, MaterialBefore, Civil, CivilTics, Age, Reserved;
    int VerifyTargetTicks, FinishedDay, FinishedTics;
    bool Ordinary;
    double Remaining;
    override void Tick()
    {
        Super.Tick();let u=CaelumPlayer(Owner);if(u==null)return;
        if(Mode==0)
        {
            if(VerifyTargetTicks>0 && --VerifyTargetTicks==0)
            {let ended=CaelumTimeSkipState.Get(u);Issue64Checks.Check(ended!=null && ended.TargetDay==FinishedDay && ended.TargetTics==FinishedTics,"completed destination remains stable while reviewing the result");}
            return;
        }
        let s=CaelumTimeSkipState.Get(u);if(s==null)return;Age++;
        if(s.ConfirmPending)return;
        if(s.Active){if(Ordinary)s.LastPumpTic=level.maptime;if(Age%350==0)Issue64Checks.Report(u);return;}
        let clock=CaelumWorldClock.Get(u);let cal=CaelumCalendarState.Get(u);
        Issue64Checks.Check(s.LastReason=="CA_SKIP_COMPLETE","explicit target reached without unsafe interruption");
        Issue64Checks.Check(clock.LocalDays()==s.TargetDay && clock.LocalTics()==s.TargetTics,"exact target clock at completion");
        Issue64Checks.Check(cal.DateSerial(clock)==Civil && cal.CivilDayTics(clock)==CivilTics,"outside date remains frozen");
        if(Mode==1)
        {
            Issue64Checks.Check(s.SleepTics==8*3600*TICRATE && s.WorkTics==0,"eight local hours sleeping yield zero productive work");
            Issue64Checks.Check(Abs(u.CraftingTaskRemainingSeconds-Remaining)<0.000001 && u.CraftingTaskActive,"sleep preserves pending task duration");
            int materialAfter=Issue64Checks.Materials(u);
            Issue64Checks.Check(materialAfter==MaterialBefore && Issue64Checks.Equipment(u)==Before,"sleep neither spends reserved materials nor creates rewards");
            Issue64Checks.Check(Abs(u.CurrentSleep-100)<0.0001,"eight-hour sleep restores 100 points");
        }
        else if(Mode==2 || Mode==3)
        {
            Issue64Checks.Check(s.ElapsedTics==1400,"comparison interval is exactly 40 local seconds");
            Issue64Checks.Check(s.WorkTics==1400 && Abs(u.CraftingTaskRemainingSeconds-80)<0.00001,"productive work matches elapsed awake interval");
            Console.Printf("QA64 COMPARE ordinary=%d hunger=%.10f thirst=%.10f sleep=%.10f health=%d air=%.10f remaining=%.10f food=%d water=%d",Ordinary,u.CurrentHunger,u.CurrentThirst,u.CurrentSleep,u.health,u.CurrentAir,u.CraftingTaskRemainingSeconds,Count(u,false),Count(u,true));
        }
        else if(Mode==5)
        {
            Issue64Checks.Check(!u.CraftingTaskActive && Issue64Checks.Equipment(u)==Before+1,"task forecast reaches exactly one native crafted output");
            int materialAfter=Issue64Checks.Materials(u);
            Console.Printf("QA64 MATERIALS before=%d reserved=%d after=%d",MaterialBefore,Reserved,materialAfter);
            Issue64Checks.Check(materialAfter==MaterialBefore-Reserved,"task pays its existing material reservation once");
            u.CompleteCraftingTask();Issue64Checks.Check(Issue64Checks.Equipment(u)==Before+1,"repeated completion cannot duplicate output");
        }
        Console.Printf("QA64 AUDIT_DONE mode=%d",Mode);Mode=0;Issue64Checks.Report(u);
        FinishedDay=s.TargetDay;FinishedTics=s.TargetTics;VerifyTargetTicks=5;
    }
    static int Count(CaelumPlayer u,bool drink)
    {
        int count=0;for(Inventory i=u.Inv;i!=null;i=i.Inv)
        {let item=CaelumConsumableItem(i);if(item!=null && item.GetConsumableType()==(drink?CaelumConstants.CONSUMABLE_WATER_RATION:CaelumConstants.CONSUMABLE_FOOD_RATION))count+=item.Amount;}
        let it=ThinkerIterator.Create("CaelumDiningTable");CaelumDiningTable table;
        while((table=CaelumDiningTable(it.Next()))!=null)
            for(int i=0;i<table.Capacity();i++)
            {let item=table.Items[i];if(item!=null && item.GetConsumableType()==(drink?CaelumConstants.CONSUMABLE_WATER_RATION:CaelumConstants.CONSUMABLE_FOOD_RATION))count+=item.Amount;}
        return count;
    }
    Default {Inventory.MaxAmount 1; +INVENTORY.UNDROPPABLE}
    States {Spawn:TNT1 A -1;Stop;}
}
class Issue64Compare : CaelumSocialDebugAction
{
    virtual bool Ordinary() {return false;}
    override bool Use(bool pickup)
    {
        let u=CaelumPlayer(Owner);if(!Issue64Checks.Task(u,120))return true;
        u.CurrentSleep=50;u.CurrentHunger=90;u.CurrentThirst=90;
        let clock=CaelumWorldClock.Get(u);clock.LimboSubTics=0;
        Issue64Checks.Check(CaelumTimeSkipState.OpenMenu(u),"comparison selector opens");
        let s=CaelumTimeSkipState.Get(u);s.UseTaskDefault=false;s.TargetDay=clock.LocalDays();s.TargetTics=clock.LocalTics()+70;
        let watch=Issue64Audit(u.GiveInventoryType("Issue64Audit"));watch.Mode=Ordinary()?2:3;watch.Ordinary=Ordinary();
        let cal=CaelumCalendarState.Get(u);watch.Civil=cal.DateSerial(clock);watch.CivilTics=cal.CivilDayTics(clock);
        Issue64Checks.Check(CaelumTimeSkipState.Start(u),"comparison starts");return true;
    }
}
class Issue64Ordinary : Issue64Compare {override bool Ordinary(){return true;}}

class Issue64BoundaryChecks : CaelumSocialDebugAction
{
    override bool Use(bool pickup)
    {
        let u=CaelumPlayer(Owner);let clock=CaelumWorldClock.Get(u);let cal=CaelumCalendarState.Get(u);
        int civil=cal.DateSerial(clock),civilTics=cal.CivilDayTics(clock);
        clock.EnsureLocalClock();int revision=clock.LocalClockRevision,localDay=clock.LocalDays(),localTics=clock.LocalTics();
        clock.EnsureLocalClock();Issue64Checks.Check(revision==1 && clock.LocalDays()==localDay && clock.LocalTics()==localTics,"local clock migration is idempotent");
        clock.LimboSubTics=0;
        for(int i=0;i<3600*TICRATE;i++)clock.AdvanceOnMap("MAP01");
        int delta=(clock.LocalDays()-localDay)*clock.TicsPerDay()+clock.LocalTics()-localTics;
        Issue64Checks.Check(delta==clock.TicsPerHour(),"126000 active-play tics equal one local Limbo hour");
        Issue64Checks.Check(cal.DateSerial(clock)==civil && cal.CivilDayTics(clock)==civilTics,"normal Limbo hour does not change either civil component");
        localDay=clock.LocalDays();clock.LimboDayTics=clock.TicsPerDay()-1;clock.LimboSubTics=19;
        clock.AdvanceOnMap("MAP01");Issue64Checks.Check(clock.LocalDays()==localDay+1 && clock.LocalTics()==0,"local daily rollover fires at midnight");
        localDay=clock.LocalDays();localTics=clock.LocalTics();clock.AdvanceOnMap("MAP02");
        Issue64Checks.Check(clock.LocalDays()==localDay && clock.LocalTics()==localTics && cal.CivilDayTics(clock)==civilTics+1,"leaving Limbo advances only the exterior calendar from its frozen instant");
        Console.Printf("QA64 BOUNDARY_DONE");return true;
    }
}
class Issue64Interruptions : CaelumSocialDebugAction
{
    override bool Use(bool pickup)
    {
        let u=CaelumPlayer(Owner);u.CurrentSleep=80;u.CurrentHunger=80;u.CurrentThirst=80;
        Issue64Checks.Check(CaelumTimeSkipState.OpenMenu(u),"interrupt fixture opens selector");
        let s=CaelumTimeSkipState.Get(u);s.UseTaskDefault=false;
        Issue64Checks.Check(CaelumTimeSkipState.Start(u),"interrupt fixture begins");
        for(int i=0;i<350;i++){CaelumTimeSkipState.PrepareStep(u);CaelumTimeAdvanceState.SimulatePersonalTic(u);CaelumTimeSkipState.AfterStep(u);}
        int elapsed=s.ElapsedTics;double hunger=u.CurrentHunger;int food=Issue64Audit.Count(u,false);
        CaelumTimeSkipState.FinishSkip(u);
        Issue64Checks.Check(!s.Active && s.ElapsedTics==elapsed && u.CurrentHunger==hunger && food==Issue64Audit.Count(u,false),"cancellation neither rolls back nor duplicates elapsed consumption");
        Issue64Checks.Check(CaelumTimeSkipState.Start(u),"cancelled destination resumes from actual state");
        u.CombatTimeRemaining=1;CaelumTimeSkipState.PrepareStep(u);
        Issue64Checks.Check(!s.Active && s.LastReason=="CA_FAST_UNSAFE","combat interrupts before another simulated tic");u.CombatTimeRemaining=0;
        Issue64Checks.Check(CaelumTimeSkipState.Start(u),"safe resumption after combat clears");
        u.health--;CaelumTimeSkipState.PrepareStep(u);Issue64Checks.Check(!s.Active && s.LastReason=="CA_REST_DAMAGE","damage interrupts and retains injury");
        CaelumTimeSkipState.Start(u);u.SetOrigin(u.Pos+(8,0,0),false);CaelumTimeSkipState.PrepareStep(u);
        Issue64Checks.Check(!s.Active && s.LastReason=="CA_REST_MOVED","displacement interrupts the skip");
        CaelumTimeSkipState.FinishSkip(u,"CA_SKIP_CANCELLED",true);
        Console.Printf("QA64 INTERRUPT_DONE");return true;
    }
}
class Issue64NoSupplies : CaelumSocialDebugAction
{
    override bool Use(bool pickup)
    {
        let u=CaelumPlayer(Owner);
        // Remove only disposable runtime fixtures; no project/save files change.
        let it=ThinkerIterator.Create("CaelumDiningTable");CaelumDiningTable table;
        while((table=CaelumDiningTable(it.Next()))!=null)
            for(int i=0;i<table.Capacity();i++)if(table.Items[i]!=null){table.Items[i].Destroy();table.Items[i]=null;}
        Inventory cursor=u.Inv;while(cursor!=null){Inventory next=cursor.Inv;if(CaelumConsumableItem(cursor)!=null || CaelumRegenerationPower(cursor)!=null)cursor.Destroy();cursor=next;}
        if(!Issue64Checks.Task(u,3600))return true;
        u.CurrentThirst=10.001;u.CurrentHunger=95;u.CurrentSleep=95;
        CaelumTimeSkipState.OpenMenu(u);let s=CaelumTimeSkipState.Get(u);
        for(int i=0;i<4 && !s.Forecast.Done;i++)s.Forecast.RunBatch();
        Issue64Checks.Check(s.Forecast.Done && s.Forecast.Reason=="CA_SKIP_PROVISIONS","forecast refuses completion without enough real water");
        Issue64Checks.Check(!CaelumTimeSkipState.Start(u) && !s.Active,"blocked task default cannot begin as a false completion promise");
        s.UseTaskDefault=false;s.TargetDay=CaelumTimeSkipState.NowDay(u);s.TargetTics=CaelumTimeSkipState.NowTics(u)+105;
        CaelumTimeSkipState.Start(u);s.LastPumpTic=-1;CaelumTimeSkipState.Pump(u);
        Issue64Checks.Check(!s.Active && s.LastReason=="CA_REST_NEEDS" && u.CurrentThirst<=10 && u.CurrentThirst>9.99,"manual destination stops accurately at critical thirst");
        Issue64Checks.Check(Issue64Audit.Count(u,false)==0 && Issue64Audit.Count(u,true)==0,"no provisions are invented");
        Console.Printf("QA64 NO_SUPPLIES_DONE");return true;
    }
}
class Issue64Availability : CaelumSocialDebugAction
{
    override bool Use(bool pickup)
    {
        let u=CaelumPlayer(Owner);let bed=CaelumTimeSkipRules.FindFurniture(u,true);
        Issue64Checks.Check(bed!=null && bed.Distance2D(u)>u.UseRange+bed.Radius,"automatic care finds a real bed beyond interaction reach");
        let it=ThinkerIterator.Create("CaelumRestFurniture");CaelumRestFurniture furniture;
        while((furniture=CaelumRestFurniture(it.Next()))!=null)furniture.Destroy();
        it=ThinkerIterator.Create("CaelumDiningTable");CaelumDiningTable table;
        while((table=CaelumDiningTable(it.Next()))!=null)
            for(int i=0;i<table.Capacity();i++)if(table.Items[i]!=null){table.Items[i].Destroy();table.Items[i]=null;}
        for(Inventory cursor=u.Inv;cursor!=null;cursor=cursor.Inv)
        {let item=CaelumConsumableItem(cursor);if(item!=null)item.InMagicBox=true;}
        u.CurrentHunger=90;u.CurrentThirst=90;u.CurrentSleep=80;
        int food=Issue64Audit.Count(u,false),water=Issue64Audit.Count(u,true);
        Issue64Checks.Check(CaelumTimeSkipState.OpenMenu(u),"care without furniture opens in the safe workshop");
        Issue64Checks.Check(CaelumTimeSkipState.Start(u),"care without furniture begins");
        let s=CaelumTimeSkipState.Get(u);
        Issue64Checks.Check(s.Furniture==null && CaelumRestState.ResourceFactor(u)==1 && !CaelumRestState.IsSeated(u),"missing furniture grants no comfort or seated-meal effect");
        Issue64Checks.Check(Issue64Audit.Count(u,false)==food-1 && Issue64Audit.Count(u,true)==water-1,"one actual food and water serving is taken from the owned Box");
        for(int i=0;i<350;i++){CaelumTimeSkipState.PrepareStep(u);CaelumTimeAdvanceState.SimulatePersonalTic(u);CaelumTimeSkipState.AfterStep(u);}
        Issue64Checks.Check(u.FindInventory("CaelumHungerRegeneration")==null && u.FindInventory("CaelumThirstRegeneration")==null,"standing portions retain ten-second native duration");
        for(Inventory cursor=u.Inv;cursor!=null;cursor=cursor.Inv)
        {let item=CaelumConsumableItem(cursor);if(item!=null)Issue64Checks.Check(item.InMagicBox,"remaining portions keep their Box location");}
        CaelumTimeSkipState.FinishSkip(u,"CA_SKIP_CANCELLED",true);
        u.CurrentSleep=0;u.CurrentHunger=95;u.CurrentThirst=95;
        CaelumTimeSkipState.OpenMenu(u);CaelumTimeSkipState.Start(u);
        Issue64Checks.Check(CaelumTimeSkipState.IsSleeping(u) && CaelumRestState.ResourceFactor(u)==1,"sleep falls back to existing ground comfort when no bed exists");
        for(int i=0;i<1400;i++){CaelumTimeSkipState.PrepareStep(u);CaelumTimeAdvanceState.SimulatePersonalTic(u);CaelumTimeSkipState.AfterStep(u);}
        Issue64Checks.Check(Abs(u.CurrentSleep-100.0/720)<0.000001,"ground sleep uses the same eight-hour recovery rate");
        CaelumTimeSkipState.FinishSkip(u,"CA_SKIP_CANCELLED",true);
        let bag=CaelumSleepingBag(u.GiveInventoryType("CaelumSleepingBag"));
        if(bag!=null)bag.InMagicBox=false;
        u.CurrentSleep=0;CaelumTimeSkipState.OpenMenu(u);CaelumTimeSkipState.Start(u);
        bool fits=CaelumRestBag.HasRoom(u);
        Console.Printf("QA64 BAG available=%d room=%d active=%d factor=%d",bag!=null && bag.AvailableTo(u),fits,s.Active,CaelumRestState.ResourceFactor(u));
        Issue64Checks.Check(bag!=null && bag.AvailableTo(u) && s.Active && CaelumRestState.ResourceFactor(u)==(fits?3:1),"owned sleeping bag respects actual room availability");
        CaelumTimeSkipState.FinishSkip(u,"CA_SKIP_CANCELLED",true);u.CurrentSleep=80;
        let bottle=CaelumWaterContainer(Actor.Spawn("CaelumBottleSmall",u.Pos,NO_REPLACE));
        bottle.WaterLiters=0.05;bottle.InMagicBox=true;bottle.AttachToOwner(u);u.CurrentThirst=90;
        Issue64Checks.Check(CaelumTimeSkipRules.Consume(u,bottle) && bottle.WaterLiters==0 && bottle.Amount==1 && bottle.Owner==u && bottle.InMagicBox,"partial bottled water is consumed once; the empty owned container remains in the Box");
        Console.Printf("QA64 AVAILABILITY_DONE");return true;
    }
}
class Issue64ModelCheck : CaelumSocialDebugAction
{
    virtual int Steps(){return 10000;}
    override bool Use(bool pickup)
    {
        let u=CaelumPlayer(Owner);if(!Issue64Checks.Task(u,10000))return true;
        u.CurrentHunger=85;u.CurrentThirst=85;u.CurrentSleep=70;
        u.health=u.CaelumMaximumHealth/2;u.player.health=u.health;u.CurrentAir=u.DerivedStats.MaximumAir/2;
        u.CurrentAdrenaline=u.DerivedStats.MaximumAdrenaline/2;
        u.NaturalHealthRegenerationAccumulator=0;u.SurvivalDamageAccumulator=0;
        CaelumTimeSkipState.OpenMenu(u);let s=CaelumTimeSkipState.Get(u);s.UseTaskDefault=false;
        let model=new("CaelumTimeSkipModel");model.CaptureSkip(u,false);model.RequiredTics=Steps();model.RunBatch();
        CaelumTimeSkipState.Start(u);
        for(int i=0;i<Steps() && s.Active;i++){CaelumTimeSkipState.PrepareStep(u);CaelumTimeAdvanceState.SimulatePersonalTic(u);CaelumTimeSkipState.AfterStep(u);}
        Console.Printf("QA64 MODEL hunger delta=%.10f thirst delta=%.10f sleep delta=%.10f health=%d/%d air delta=%.10f",u.CurrentHunger-model.Hunger,u.CurrentThirst-model.Thirst,u.CurrentSleep-model.Sleep,u.health,model.Health,u.CurrentAir-model.Air);
        Issue64Checks.Check(Abs(u.CurrentHunger-model.Hunger)<0.000001 && Abs(u.CurrentThirst-model.Thirst)<0.000001 && Abs(u.CurrentSleep-model.Sleep)<0.000001,"forecast matches native needs, meals and healing costs");
        Issue64Checks.Check(u.health==model.Health && Abs(u.CurrentAir-model.Air)<0.000001,"forecast matches native health and Air regeneration");
        CaelumTimeSkipState.FinishSkip(u,"CA_SKIP_CANCELLED",true);Console.Printf("QA64 MODEL_DONE");return true;
    }
}
class Issue64ModelEdge : Issue64ModelCheck {override int Steps(){return 100;}}
class Issue64FastCompare : CaelumSocialDebugAction
{
    virtual bool Fast(){return true;}
    override bool Use(bool pickup)
    {
        let u=CaelumPlayer(Owner);if(!Issue64Checks.Task(u,120))return true;
        u.CurrentHunger=90;u.CurrentThirst=90;u.CurrentSleep=50;
        let clock=CaelumWorldClock.Get(u);clock.LimboSubTics=0;int initialDay=clock.LocalDays(),initialTic=clock.LocalTics();
        if(Fast())
        {
            // Use the same real initial servings, then the public x105 pump.
            let table=CaelumDiningWorld.Find(101);CaelumTimeSkipRules.Consume(u,table.Items[0],table);
            CaelumTimeSkipRules.Consume(u,CaelumConsumableItem(u.FindInventory("CaelumWaterRation")));
            Issue64Checks.Check(CaelumTimeAdvanceState.Toggle(u),"existing fast-forward remains available");
            let fast=CaelumTimeAdvanceState.Get(u);
            for(int i=0;i<20;i++)
            {CaelumTimeAdvanceState.SimulatePersonalTic(u);fast.LastPumpTic=-1;CaelumTimeAdvanceState.Pump(u);}
            Issue64Checks.Check(fast.SimulatedTics==2080,"fast-forward still adds 104 steps to each normal step");
            CaelumTimeAdvanceState.Halt(u);
        }
        else
        {
            CaelumTimeSkipState.OpenMenu(u);let s=CaelumTimeSkipState.Get(u);s.UseTaskDefault=false;
            s.TargetDay=initialDay;s.TargetTics=initialTic+105;CaelumTimeSkipState.Start(u);s.LastPumpTic=-1;CaelumTimeSkipState.Pump(u);
            Issue64Checks.Check(s.ElapsedTics==2100 && s.LastReason=="CA_SKIP_COMPLETE","matching skip advances exactly sixty seconds");
        }
        Console.Printf("QA64 FAST_COMPARE fast=%d hunger=%.10f thirst=%.10f sleep=%.10f remaining=%.10f food=%d water=%d local_delta=%d",Fast(),u.CurrentHunger,u.CurrentThirst,u.CurrentSleep,u.CraftingTaskRemainingSeconds,Issue64Audit.Count(u,false),Issue64Audit.Count(u,true),(clock.LocalDays()-initialDay)*clock.TicsPerDay()+clock.LocalTics()-initialTic);
        Console.Printf("QA64 FAST_DONE");return true;
    }
}
class Issue64FastSkip : Issue64FastCompare {override bool Fast(){return false;}}
class Issue64NativeExit : CaelumSocialDebugAction
{
    override bool Use(bool pickup)
    {
        let u=CaelumPlayer(Owner);CaelumTimeSkipState.FinishSkip(u,"CA_SKIP_CANCELLED",true);u.CancelCraftingTask();
        let r=u.GetPersistentCharacterState(true);
        let item=CaelumEquipmentItem(Actor.Spawn("CaelumWeaponPickup",u.Pos,NO_REPLACE));
        item.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_WEAPON;item.ItemType=CaelumConstants.WEAPON_TYPE_SWORD;
        item.Tier=1;item.EquipmentSize=CaelumConstants.EQUIPMENT_SIZE_M;item.AcquisitionResolved=true;item.PickupDataInitialized=true;
        item.AttachToOwner(u);u.EnsureEquipmentItemId(item);r.MainM00StarterWeaponId=item.ItemId;r.MainM00StarterChosen=true;
        r.QuestStage[0]=CaelumConstants.MAIN_M00_STATE_FOOL_CAPTURED;
        r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_EXIT_READY);r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_THE_FOOL_CAPTURED);
        r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_RULO_COMPLETE);r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_STARTER_WEAPON_CRAFTED);
        r.TarotOwned[CaelumConstants.TAROT_THE_FOOL]=true;
        let controller=CaelumMainM00QuestController(EventHandler.Find("CaelumMainM00QuestController"));controller.PresentReturnDoor(true);
        u.SetOrigin(controller.ReturnDoor.Pos+(48,0,0),false);u.Vel=(0,0,0);u.Angle=180;
        let clock=CaelumWorldClock.Get(u);let cal=CaelumCalendarState.Get(u);
        let audit=Issue64ExitAudit(u.GiveInventoryType("Issue64ExitAudit"));audit.LocalDay=clock.LocalDays();audit.LocalTic=clock.LocalTics();
        audit.Civil=cal.DateSerial(clock);audit.CivilTic=cal.CivilDayTics(clock);
        u.player.ConversationNPC=controller.ReturnDoor;controller.ReturnDoor.bInConversation=true;
        Issue64Checks.Check(CaelumMainM00Return.Begin(u),"native Limbo departure starts");
        controller.ReturnDoor.bInConversation=false;u.player.ConversationNPC=null;return true;
    }
}
class Issue64ExitAudit : Inventory
{
    int LocalDay,LocalTic,Civil,CivilTic;
    bool Done;
    override void Tick()
    {
        Super.Tick();let u=CaelumPlayer(Owner);if(u==null || Done || level.MapName!="MAP02")return;
        let clock=CaelumWorldClock.Get(u);let cal=CaelumCalendarState.Get(u);
        Issue64Checks.Check(clock!=null && cal!=null,"native departure carries both clock records");
        if(clock==null || cal==null)return;
        Issue64Checks.Check(cal.DateSerial(clock)==Civil && cal.CivilDayTics(clock)>=CivilTic && cal.CivilDayTics(clock)<=CivilTic+1,"native exit resumes outside calendar at its frozen instant");
        Issue64Checks.Check(clock.LocalDays()==LocalDay && clock.LocalTics()>=LocalTic && clock.LocalTics()-LocalTic<10,"Limbo clock retains only the departure fade interval");
        Done=true;Console.Printf("QA64 EXIT_DONE outside=%s",cal.FormatDate(clock));
    }
    Default {Inventory.MaxAmount 1; Inventory.InterHubAmount 1; +INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE}
    States {Spawn:TNT1 A -1;Stop;}
}
class Issue64ScheduleEdge : CaelumSocialDebugAction
{
    override bool Use(bool pickup)
    {
        let u=CaelumPlayer(Owner);if(level.MapName=="MAP01"){Issue64Checks.Check(false,"schedule fixture requires exterior");return true;}
        u.CurrentHunger=95;u.CurrentThirst=95;u.CurrentSleep=95;
        Actor.Spawn("CaelumTimeAdvanceZone",u.Pos,NO_REPLACE);
        let agenda=CaelumScheduleState.Get(u,true);
        let entry=agenda.AddAfter(u,"qa64_siege",CaelumScheduleRules.SIEGE,"CA_SKIP_TITLE",level.MapName,1);
        entry.Value=1;
        let model=new("CaelumTimeSkipModel");model.CaptureSkip(u,false);model.RequiredTics=1000;model.RunBatch();
        Issue64Checks.Check(model.Done && model.Reason=="CA_EVENT_SIEGE_INTERRUPT","forecast identifies a scheduled threat before task completion");
        Console.Printf("QA64 SCHEDULE_BLOCK %s conversation=%d ground=%d water=%d velocity=%.4f",CaelumTimeSkipRules.BlockReason(u),u.HasActiveConversation(),u.player.onground,u.WaterLevel,u.Vel.Length());
        if(u.player.ConversationNPC!=null)u.player.ConversationNPC.bInConversation=false;u.player.ConversationNPC=null;
        let nearby=ThinkerIterator.Create("Actor");Actor other;
        while((other=Actor(nearby.Next()))!=null)
            if(other!=u && other.bIsMonster && other.health>0 && !other.bFriendly && other.Distance2D(u)<=CaelumTimeAdvanceState.UNSUPPORTED_ACTOR_RADIUS)
            {Console.Printf("QA64 ISOLATE_THREAT %s distance=%.1f",other.GetClassName(),other.Distance2D(u));other.bFriendly=true;other.target=null;}
        u.CombatTimeRemaining=0;
        Console.Printf("QA64 SCHEDULE_ISOLATED %s cheats=%d",CaelumTimeSkipRules.BlockReason(u),u.player.cheats);
        bool opened=CaelumTimeSkipState.OpenMenu(u);Issue64Checks.Check(opened,"exterior selector opens in an authored safe zone");if(!opened)return true;
        let s=CaelumTimeSkipState.Get(u);s.UseTaskDefault=false;
        Issue64Checks.Check(CaelumTimeSkipState.Start(u),"exterior skip begins before scheduled threat");
        s.LastPumpTic=-1;CaelumTimeSkipState.Pump(u);
        Issue64Checks.Check(!s.Active && s.LastReason=="CA_EVENT_SIEGE_INTERRUPT" && entry.Processed==1,"native calendar event interrupts once at its chronological boundary");
        Issue64Checks.Check(CaelumScheduleState.Now(u)==entry.FirstStamp(),"no simulated time crosses the unresolved siege");
        Console.Printf("QA64 SCHEDULE_DONE");return true;
    }
}
class Issue64Seated : CaelumSocialDebugAction
{
    override bool Use(bool pickup)
    {
        let u=CaelumPlayer(Owner);u.CurrentSleep=80;u.CurrentHunger=90;u.CurrentThirst=90;
        CaelumTimeSkipState.OpenMenu(u);CaelumTimeSkipState.Start(u);
        let s=CaelumTimeSkipState.Get(u);
        Issue64Checks.Check(CaelumRestState.IsSeated(u) && CaelumRestState.ResourceFactor(u)==2,"idle skip uses a real available chair");
        for(int i=0;i<350;i++){CaelumTimeSkipState.PrepareStep(u);CaelumTimeAdvanceState.SimulatePersonalTic(u);CaelumTimeSkipState.AfterStep(u);}
        Issue64Checks.Check(u.FindInventory("CaelumHungerRegeneration")!=null && u.FindInventory("CaelumThirstRegeneration")!=null,"seated effects still run after ten seconds");
        for(int i=350;i<1050;i++){CaelumTimeSkipState.PrepareStep(u);CaelumTimeAdvanceState.SimulatePersonalTic(u);CaelumTimeSkipState.AfterStep(u);}
        Issue64Checks.Check(u.FindInventory("CaelumHungerRegeneration")==null && u.FindInventory("CaelumThirstRegeneration")==null,"seated portions expire after thirty seconds without refreshing");
        CaelumTimeSkipState.FinishSkip(u,"CA_SKIP_CANCELLED",true);Console.Printf("QA64 SEATED_DONE");return true;
    }
}
class Issue64CompletedCheck : CaelumSocialDebugAction
{
    override bool Use(bool pickup)
    {
        let u=CaelumPlayer(Owner);let s=CaelumTimeSkipState.Get(u);
        let audit=Issue64Audit(u.FindInventory("Issue64Audit"));
        Issue64Checks.Check(s!=null && !s.Active && s.LastReason=="CA_SKIP_COMPLETE" && !u.CraftingTaskActive,"completed skip/task remain completed after reload");
        if(audit!=null && s!=null)
        {
            Issue64Checks.Check(s.TargetDay==audit.FinishedDay && s.TargetTics==audit.FinishedTics,"saved destination remains stable after reload");
            int before=Issue64Checks.Equipment(u);u.CompleteCraftingTask();
            Issue64Checks.Check(before==audit.Before+1 && Issue64Checks.Equipment(u)==before,"completed reload cannot award another crafted item");
            Issue64Checks.Check(Issue64Checks.Materials(u)==audit.MaterialBefore-audit.Reserved,"completed reload cannot charge materials again");
        }
        Console.Printf("QA64 COMPLETED_RELOAD_DONE");return true;
    }
}
