class Issue65Checks : Object play
{
    static void Check(bool ok,String label){Console.Printf("QA65 %s %s",ok?"PASS":"FAIL",label);}
    static int Count(CaelumDiningTable table,int kind)
    {
        int count=0;for(int i=0;i<table.Capacity();i++)
        {let item=table.Items[i];if(item!=null && (kind==0 || item.GetConsumableType()==kind))count+=item.Amount;}
        return count;
    }
    static int Food(CaelumDiningTable t){return Count(t,CaelumConstants.CONSUMABLE_FOOD_RATION);}
    static int Water(CaelumDiningTable t){return Count(t,CaelumConstants.CONSUMABLE_WATER_RATION);}
    static CaelumDiningTable First()
    {let it=ThinkerIterator.Create("CaelumDiningTableSmall");return CaelumDiningTable(it.Next());}
    static void Clear(CaelumDiningTable t)
    {
        for(int i=0;i<t.Capacity();i++)if(t.Items[i]!=null){t.Items[i].Destroy();t.Items[i]=null;}
        t.RefreshDisplays();
    }
    static void CheckDisplays(CaelumDiningTable t)
    {
        bool ok=true;
        for(int i=0;i<t.Capacity();i++)
        {
            let item=t.Items[i];let display=t.Displays[i];
            if(item==null){if(display!=null)ok=false;continue;}
            if(item.Owner!=t || display==null || display.Item!=item || display.Table!=t)ok=false;
            else if(CaelumDiningTable.IsDrink(item)!=(CaelumDiningWaterCup(display)!=null))ok=false;
        }
        Check(ok,"table presentation matches actual owned food/water and empty slots");
    }
    static void Fresh()
    {
        let it=ThinkerIterator.Create("CaelumDiningTable");CaelumDiningTable t;
        int tables=0,slots=0,food=0,water=0;
        while((t=CaelumDiningTable(it.Next()))!=null)
        {
            tables++;slots+=t.Capacity();food+=Food(t);water+=Water(t);
            Check(Food(t)==t.Capacity()/2 && Water(t)==t.Capacity()/2,"each fresh mansion table is half food and half water");
            Check(t.MansionProvisionRevision==1,"table provision migration revision is initialized");CheckDisplays(t);
            Console.Printf("QA65 TABLE capacity=%d food=%d water=%d day=%d",t.Capacity(),Food(t),Water(t),t.LastMansionRestockDay);
        }
        Check(tables==6 && slots==94 && food==47 && water==47,"six mansion tables provide 47 food and 47 water slots");
    }
}
class Issue65Fresh : CaelumSocialDebugAction
{override bool Use(bool pickup){Issue65Checks.Fresh();Console.Printf("QA65 FRESH_DONE");return true;}}
class Issue65Policy : CaelumSocialDebugAction
{
    override bool Use(bool pickup)
    {
        let t=Issue65Checks.First();let u=CaelumPlayer(Owner);if(t==null)return true;
        int day=t.LastMansionRestockDay;
        let kept=t.Items[1];t.Items[0].Destroy();t.Items[0]=null;t.RefreshDisplays();
        t.SyncLocalDay(day);t.SeedMansionFood();
        Issue65Checks.Check(Issue65Checks.Count(t,0)==3 && t.Items[1]==kept,"taking a portion cannot claim another same-day refill");
        t.SyncLocalDay(day+1);
        Issue65Checks.Check(Issue65Checks.Food(t)==2 && Issue65Checks.Water(t)==2 && t.Items[1]==kept,"next day fills only the missing portion");
        Issue65Checks.Clear(t);t.SyncLocalDay(day+2);
        Issue65Checks.Check(Issue65Checks.Food(t)==2 && Issue65Checks.Water(t)==2,"empty table restores both daily targets");
        let full=t.Items[0];t.SyncLocalDay(day+3);
        Issue65Checks.Check(t.Items[0]==full && Issue65Checks.Count(t,0)==4,"full table keeps item identities without accumulating stock");
        Issue65Checks.Clear(t);
        let bottle=CaelumWaterContainer(Spawn("CaelumCanteenNormal",t.Pos,NO_REPLACE));
        if(bottle==null){Issue65Checks.Check(false,"canteen fixture exists");return true;}
        bottle.WaterLiters=0.05;bottle.AttachToOwner(t);t.Items[0]=bottle;
        let own=CaelumConsumableItem(Spawn("CaelumFoodRation",t.Pos,NO_REPLACE));own.Amount=1;own.AttachToOwner(t);t.Items[1]=own;
        t.SyncLocalDay(day+4);
        Issue65Checks.Check(t.Items[0]==bottle && bottle.Owner==t && Abs(bottle.WaterLiters-0.05)<0.000001 && t.Items[1]==own,"daily refill preserves deposited food and a partially filled owned canteen");
        Issue65Checks.Check(Issue65Checks.Count(t,0)==4 && Issue65Checks.Food(t)==2 && Issue65Checks.Water(t)==1,"occupied slot limits target without exceeding table capacity");
        Issue65Checks.CheckDisplays(t);
        t.Items[3].Destroy();t.Items[3]=null;t.RefreshDisplays();
        t.SyncLocalDay(day+4);t.SyncLocalDay(day+3);t.SeedMansionFood();
        Issue65Checks.Check(Issue65Checks.Count(t,0)==3,"repeat, stale day and revisit synchronization cannot duplicate delivery");
        t.SyncLocalDay(day+100);
        Issue65Checks.Check(Issue65Checks.Count(t,0)==4 && t.LastMansionRestockDay==day+100,"missed days refill once to capacity, never accrue supplies");
        Console.Printf("QA65 POLICY_DONE");return true;
    }
}
class Issue65Boundary : CaelumSocialDebugAction
{
    virtual int Mode(){return 1;}
    override bool Use(bool pickup)
    {
        let u=CaelumPlayer(Owner);let t=Issue65Checks.First();let clock=CaelumWorldClock.Get(u);
        Issue65Checks.Clear(t);clock.LimboDayTics=CaelumWorldClock.TicsPerDay()-1;clock.LimboSubTics=19;
        let audit=Issue65BoundaryAudit(u.GiveInventoryType("Issue65BoundaryAudit"));
        audit.Table=t;audit.BeforeDay=clock.LocalDays();audit.Mode=Mode();
        if(Mode()==2)
        {
            Issue64Checks.Task(u,120);CaelumTimeAdvanceState.Toggle(u);
            let fast=CaelumTimeAdvanceState.Get(u);fast.LastPumpTic=-1;CaelumTimeAdvanceState.Pump(u);CaelumTimeAdvanceState.Halt(u);
        }
        else if(Mode()==3)
        {
            CaelumTimeSkipState.OpenMenu(u);let s=CaelumTimeSkipState.Get(u);s.UseTaskDefault=false;
            s.TargetDay=clock.LocalDays()+1;s.TargetTics=0;CaelumTimeSkipState.Start(u);
            s.LastPumpTic=-1;CaelumTimeSkipState.Pump(u);
        }
        return true;
    }
}
class Issue65FastBoundary : Issue65Boundary {override int Mode(){return 2;}}
class Issue65SkipBoundary : Issue65Boundary {override int Mode(){return 3;}}
class Issue65BoundaryAudit : Inventory
{
    CaelumDiningTable Table;int BeforeDay,Mode;
    override void Tick()
    {
        Super.Tick();if(Mode==0)return;let u=CaelumPlayer(Owner);let c=CaelumWorldClock.Get(u);
        if(c.LocalDays()==BeforeDay)return;
        Issue65Checks.Check(c.LocalDays()==BeforeDay+1 && Table.LastMansionRestockDay==c.LocalDays(),"native midnight records exactly the new local day");
        Issue65Checks.Check(Issue65Checks.Food(Table)==2 && Issue65Checks.Water(Table)==2,"normal, fast or skip midnight restores both provision types");
        Issue65Checks.CheckDisplays(Table);Console.Printf("QA65 BOUNDARY_DONE mode=%d",Mode);Mode=0;
    }
    Default {Inventory.MaxAmount 1;+INVENTORY.UNDROPPABLE}
    States {Spawn:TNT1 A -1;Stop;}
}
class Issue65OtherMap : CaelumSocialDebugAction
{
    override bool Use(bool pickup)
    {
        int count=0;let it=ThinkerIterator.Create("CaelumDiningTable");CaelumDiningTable t;
        while((t=CaelumDiningTable(it.Next()))!=null)
        {t.SyncLocalDay(100);t.SeedMansionFood();Issue65Checks.Check(t.ForecastDailyTarget()==0 && Issue65Checks.Count(t,0)==0 && t.MansionProvisionRevision==0,"tables outside MAP01 receive no initial or daily stock");count++;}
        Issue65Checks.Check(count>=1,"other-map test observes actual dining tables");Console.Printf("QA65 OTHER_MAP_DONE count=%d",count);return true;
    }
}
class Issue65Migration : CaelumSocialDebugAction
{
    override bool Use(bool pickup)
    {
        let u=CaelumPlayer(Owner);let r=Issue65LegacyRecord(u.FindInventory("Issue65LegacyRecord"));
        if(r==null){Issue65Checks.Check(false,"legacy record is available");return true;}
        bool kept=true;for(int i=0;i<r.Kept.Size();i++)if(r.Kept[i]==null || CaelumDiningTable(r.Kept[i].Owner)==null)kept=false;
        Issue65Checks.Check(kept && r.Kept.Size()==93,"migration keeps every legacy ration and deposited item");
        Issue65Checks.Check(r.Bottle.Owner==r.FirstTable && Abs(r.Bottle.WaterLiters-0.05)<0.000001,"migration preserves partial canteen identity and liters");
        int food=0,water=0;let it=ThinkerIterator.Create("CaelumDiningTable");CaelumDiningTable t;
        while((t=CaelumDiningTable(it.Next()))!=null)
        {
            int before=Issue65Checks.Count(t,0);t.SyncLocalDay(r.LocalDay);t.SeedMansionFood();
            Issue65Checks.Check(t.MansionProvisionRevision==1 && t.LastMansionRestockDay==r.LocalDay && Issue65Checks.Count(t,0)==before,"migration and reload synchronize a saved table idempotently");
            food+=Issue65Checks.Food(t);water+=Issue65Checks.Water(t);Issue65Checks.CheckDisplays(t);
        }
        Issue65Checks.Check(food==92 && water==1,"full legacy food tables stay intact; only the free slot receives water");
        Console.Printf("QA65 MIGRATION_DONE food=%d water=%d",food,water);return true;
    }
}
class Issue65TimedModel : CaelumTimeSkipModel
{
    int Limit;
    override void Step(bool sleeping){Super.Step(sleeping);if(ElapsedTics>=Limit)Done=true;}
}
class Issue65MultiDay : CaelumSocialDebugAction
{
    override bool Use(bool pickup)
    {
        let u=CaelumPlayer(Owner);if(!Issue64Checks.Task(u,80*3600))return true;
        // Only table supplies participate in this disposable integration case.
        for(Inventory item=u.Inv;item!=null;)
        {Inventory next=item.Inv;if(CaelumConsumableItem(item)!=null)item.Destroy();item=next;}
        u.CurrentHunger=100;u.CurrentThirst=100;u.CurrentSleep=20;
        let clock=CaelumWorldClock.Get(u);clock.LimboDayTics=0;clock.LimboSubTics=0;
        Issue65Checks.Check(CaelumTimeSkipState.OpenMenu(u),"multi-day selector opens");
        let s=CaelumTimeSkipState.Get(u);s.UseTaskDefault=false;s.Forecast=null;
        s.TargetDay=clock.LocalDays()+3;s.TargetTics=0;
        let audit=Issue65MultiAudit(u.GiveInventoryType("Issue65MultiAudit"));
        audit.StartDay=clock.LocalDays();audit.LastDay=audit.StartDay;audit.Phase=1;
        audit.InitialMaterial=Issue64Checks.Materials(u);audit.InitialEquipment=Issue64Checks.Equipment(u);
        audit.Model=new("Issue65TimedModel");audit.Model.Limit=3*CaelumWorldClock.TicsPerDay()*20;
        audit.Model.CaptureSkip(u,false);
        let cal=CaelumCalendarState.Get(u);audit.Civil=cal.DateSerial(clock);audit.CivilTics=cal.CivilDayTics(clock);
        Issue65Checks.Check(CaelumTimeSkipState.Start(u),"three-day skip starts with actual tables only");return true;
    }
}
class Issue65MultiAudit : Inventory
{
    Issue65TimedModel Model;
    int StartDay,LastDay,Phase,InitialMaterial,InitialEquipment,Civil,CivilTics;
    override void Tick()
    {
        Super.Tick();if(Phase==0)return;let u=CaelumPlayer(Owner);let c=CaelumWorldClock.Get(u);let s=CaelumTimeSkipState.Get(u);
        if(!Model.Done)Model.RunBatch();
        if(c.LocalDays()!=LastDay)
        {
            LastDay=c.LocalDays();int food=0,water=0;bool days=true;
            let it=ThinkerIterator.Create("CaelumDiningTable");CaelumDiningTable t;
            while((t=CaelumDiningTable(it.Next()))!=null)
            {days=days && t.LastMansionRestockDay==LastDay;food+=Issue65Checks.Food(t);water+=Issue65Checks.Water(t);}
            Issue65Checks.Check(days && food<=47 && water<=47,"each crossed midnight refills once within both targets");
            Console.Printf("QA65 DAY local=%d food=%d water=%d elapsed=%d sleep=%d work=%d",LastDay,food,water,s.ElapsedTics,s.SleepTics,s.WorkTics);
        }
        if(s.Active)return;
        // Snapshot immediately, before ordinary play resumes after the skip.
        if(Phase==1)
        {
            Issue65Checks.Check(s.LastReason=="CA_SKIP_COMPLETE" && c.LocalDays()==StartDay+3 && s.ElapsedTics==Model.Limit,"three-day target completes exactly");
            Issue65Checks.Check(Model.Done && Model.Reason.Length()==0,"forecast survives chronological daily refills");
            Console.Printf("QA65 MULTI_COMPARE nativeH=%.10f modelH=%.10f nativeT=%.10f modelT=%.10f nativeS=%.10f modelS=%.10f nativeSleep=%d modelSleep=%d nativeWork=%d modelWork=%d meals=%d drinks=%d",u.CurrentHunger,Model.Hunger,u.CurrentThirst,Model.Thirst,u.CurrentSleep,Model.Sleep,s.SleepTics,Model.SleepTics,s.WorkTics,Model.ProductiveTics,Model.FoodSpent,Model.WaterSpent);
            Issue65Checks.Check(Abs(u.CurrentHunger-Model.Hunger)<0.000001 && Abs(u.CurrentThirst-Model.Thirst)<0.000001 && Abs(u.CurrentSleep-Model.Sleep)<0.000001,"three-day native needs and sleep match the numeric forecast");
            Issue65Checks.Check(s.SleepTics==Model.SleepTics && s.WorkTics==Model.ProductiveTics,"three-day sleep and productive work match the forecast");
            int food=0,water=0,stockFood=0,stockWater=0;
            let it=ThinkerIterator.Create("CaelumDiningTable");CaelumDiningTable t;
            while((t=CaelumDiningTable(it.Next()))!=null){food+=Issue65Checks.Food(t);water+=Issue65Checks.Water(t);}
            for(int i=0;i<Model.Supplies.Size();i++)
            {let row=Model.Supplies[i];if(row.Kind==1)stockFood+=row.Count;else if(row.Kind==2)stockWater+=row.Count;}
            Console.Printf("QA65 MULTI_STOCK nativeFood=%d modelFood=%d nativeWater=%d modelWater=%d",food,stockFood,water,stockWater);
            Issue65Checks.Check(food==stockFood && water==stockWater && Model.FoodSpent>0 && Model.WaterSpent>47,"native final stock matches forecast after consuming beyond the initial water supply");
            let cal=CaelumCalendarState.Get(u);
            Issue65Checks.Check(cal.DateSerial(c)==Civil && cal.CivilDayTics(c)==CivilTics,"three local days leave exterior campaign date frozen");
            Issue65Checks.Check(Issue64Checks.Materials(u)==InitialMaterial && Issue64Checks.Equipment(u)==InitialEquipment && u.CraftingTaskActive,"unfinished multi-day task neither pays early nor awards output");
            Console.Printf("QA65 MULTI_DONE food=%d water=%d",food,water);Phase=0;
        }
    }
    Default {Inventory.MaxAmount 1;+INVENTORY.UNDROPPABLE}
    States {Spawn:TNT1 A -1;Stop;}
}
class Issue65TableRecord : Inventory
{
    CaelumWaterContainer Bottle;CaelumConsumableItem Kept;int Day;
    Default {Inventory.MaxAmount 1;+INVENTORY.UNDROPPABLE}
    States {Spawn:TNT1 A -1;Stop;}
}
class Issue65TableSeed : CaelumSocialDebugAction
{
    override bool Use(bool pickup)
    {
        let t=Issue65Checks.First();let r=Issue65TableRecord(t.GiveInventoryType("Issue65TableRecord"));
        t.Items[0].Destroy();t.Items[0]=null;t.Items[1].Destroy();t.Items[1]=null;
        r.Bottle=CaelumWaterContainer(Spawn("CaelumCanteenNormal",t.Pos,NO_REPLACE));
        r.Bottle.WaterLiters=0.05;r.Bottle.AttachToOwner(t);t.Items[1]=r.Bottle;
        r.Kept=t.Items[2];r.Day=t.LastMansionRestockDay;t.RefreshDisplays();
        Console.Printf("QA65 TABLE_SEEDED day=%d stock=%d",r.Day,Issue65Checks.Count(t,0));return true;
    }
}
class Issue65TableSavedCheck : CaelumSocialDebugAction
{
    override bool Use(bool pickup)
    {
        let t=Issue65Checks.First();let r=Issue65TableRecord(t.FindInventory("Issue65TableRecord"));
        Issue65Checks.Check(r!=null,"table-owned record survives native serialization");
        if(r==null)return true;
        t.SyncLocalDay(r.Day);t.SeedMansionFood();
        Issue65Checks.Check(t.LastMansionRestockDay==r.Day && Issue65Checks.Count(t,0)==3 && t.Items[0]==null,"save/load or hub revisit cannot repeat a same-day refill");
        Issue65Checks.Check(t.Items[1]==r.Bottle && r.Bottle.Owner==t && Abs(r.Bottle.WaterLiters-0.05)<0.000001 && t.Items[2]==r.Kept,"serialized table retains deposited container and ration identity");
        Issue65Checks.CheckDisplays(t);Console.Printf("QA65 TABLE_SAVED_DONE");return true;
    }
}
class Issue65SplitSkips : CaelumSocialDebugAction
{
    override bool Use(bool pickup)
    {
        let u=CaelumPlayer(Owner);let t=Issue65Checks.First();int before=Issue65Checks.Count(t,0),day=t.LastMansionRestockDay;
        for(int i=0;i<3;i++)
        {
            CaelumTimeSkipState.OpenMenu(u);let s=CaelumTimeSkipState.Get(u);s.UseTaskDefault=false;
            s.TargetDay=day;s.TargetTics=CaelumTimeSkipState.NowTics(u)+CaelumWorldClock.TicsPerHour()/60;
            bool started=CaelumTimeSkipState.Start(u);
            for(int j=0;j<3 && s.Active;j++){s.LastPumpTic=-1;CaelumTimeSkipState.Pump(u);}
            Issue65Checks.Check(started && !s.Active && s.LastReason=="CA_SKIP_COMPLETE","short skip reaches its target without a daily boundary");
            CaelumTimeSkipState.FinishSkip(u,"CA_SKIP_CANCELLED",true);
        }
        Issue65Checks.Check(t.LastMansionRestockDay==day && Issue65Checks.Count(t,0)==before,"three short same-day skips grant no additional portions");
        Console.Printf("QA65 SPLIT_DONE");return true;
    }
}
class Issue65TableView : CaelumSocialDebugAction
{
    override bool Use(bool pickup)
    {
        let u=CaelumPlayer(Owner);let t=Issue65Checks.First();u.CraftingMenuOpen=false;
        CaelumTimeSkipState.FinishSkip(u,"CA_SKIP_CANCELLED",true);
        u.SetOrigin(t.LocalPoint(-80,0),false);u.Angle=t.Angle;u.Pitch=25;
        Console.Printf("QA65 VIEW table=(%.0f,%.0f,%.0f) angle=%.0f",t.Pos.X,t.Pos.Y,t.Pos.Z,t.Angle);return true;
    }
}
