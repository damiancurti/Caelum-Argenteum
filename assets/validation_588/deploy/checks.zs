class CA411DeployRecord : Inventory
{
    CaelumCampTent Item;
    CaelumDeployedTent Tent;
    bool ManualStarted;
    Default {Inventory.MaxAmount 1;+INVENTORY.UNDROPPABLE}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA411DeployObstacle : Actor
{Default {Radius 16;Height 40;+SOLID +NOGRAVITY} States {Spawn:TNT1 A -1;Stop;}}
class CA411DeployChecks : EventHandler
{
    int Passed,Failed;
    void Check(bool yes,String label){if(yes)Passed++;else Failed++;Console.Printf("CA411D %s %s",yes?"PASS":"FAIL",label);}
    void Result(){Console.Printf("CA411D RESULT passes=%d failures=%d",Passed,Failed);}
    bool Near(double a,double b){return Abs(a-b)<0.000001;}
    void Setup(CaelumPlayer u)
    {
        if(u.player.ConversationNPC!=null)u.player.ConversationNPC.bInConversation=false;
        u.CharacterCreationComplete=true;u.CreationWizardOpen=false;u.bInvulnerable=true;
        u.CombatTimeRemaining=0;u.SetOrigin((64,128,0),false);u.Vel=(0,0,0);u.Angle=0;
        u.DerivedStats.CarryCapacity=1000;u.CurrentHunger=100;u.CurrentThirst=100;u.CurrentSleep=100;
        CaelumWorldClock.Get(u,true);
        let persistent=u.GetPersistentCharacterState(true);persistent.ProfileCommitted=true;persistent.WorldPendingConnection=0;
    }
    CaelumCampTent Give(CaelumPlayer u)
    {let item=CaelumCampTent(Actor.Spawn('CaelumCampTent',u.Pos,NO_REPLACE));item.AttachToOwner(u);item.Amount=1;return item;}
    void Finish(CaelumPlayer u)
    {u.CraftingTaskRemainingSeconds=CaelumThermalRuntime.WorldTicSeconds();u.UpdateCraftingTask();}
    void Core(CaelumPlayer u)
    {
        Setup(u);let item=Give(u);
        Check(CaelumCampLand.Allows(u,(128,128,0),32),"mansion garden allowed");
        Check(!CaelumCampLand.Allows(u,(384,128,0),32),"mansion paving denied");
        Check(!CaelumCampLand.Allows(u,(240,128,0),32),"whole footprint rejects paving boundary");
        Check(CaelumCampLandData.Countryside("MAP03",(-30000,0,0)),"known countryside allowed");
        Check(!CaelumCampLandData.Countryside("MAP03",(0,0,0)),"city is not countryside");
        Check(!CaelumCampLandData.Countryside("TCOAST",(0,0,0)),"unknown land has no implicit grant");
        Check(CaelumCampTask.BeginSetup(u,item),"real setup begins");
        Check(Near(u.CraftingTaskRemainingSeconds,600),"approved setup duration");
        Check(Near(CaelumTimeSkipState.TaskSeconds(u),600),"Limbo wait predicts 600 personal seconds");
        u.Attributes.Dexterity=100;u.UpdateCraftingTask();
        Check(Near(u.CraftingTaskRemainingSeconds,600-1.0/TICRATE),"world time without Dexterity shortening");
        Check(CaelumWaterBoiling.Locked(item),"camp item reserved against transfers");
        CaelumCampInventory.Drop(u,item);Check(item.Owner==u && item.Amount==1,"drop cannot duplicate reserved tent");
        u.CancelCraftingTask();Check(item.Owner==u && !CaelumCampTask.Active(u) && !CaelumWaterBoiling.Locked(item),"cancel preserves original item");
        Check(CaelumCampTask.BeginSetup(u,item),"setup restarts");
        let task=CaelumCampTask.Find(u);let obstacle=Actor.Spawn('CA411DeployObstacle',task.Point,NO_REPLACE);
        Finish(u);Check(item.Owner==u && !u.CraftingTaskActive,"completion rechecks occupied ground atomically");obstacle.Destroy();
        Check(CaelumCampTask.BeginSetup(u,item),"valid setup after obstruction removed");
        u.CombatTimeRemaining=1;double before=u.CraftingTaskRemainingSeconds;u.UpdateCraftingTask();
        Check(Near(before,u.CraftingTaskRemainingSeconds),"combat pauses setup");u.CombatTimeRemaining=0;
        u.SetOrigin((700,128,0),false);u.UpdateCraftingTask();Check(Near(before,u.CraftingTaskRemainingSeconds),"distance pauses setup");
        u.SetOrigin((64,128,0),false);Finish(u);
        let tent=CaelumDeployedTent(item.Owner);
        Check(tent!=null && tent.Ready && tent.Item==item && item.Amount==1,"deployed structure holds same inventory identity");
        if(tent==null){Result();return;}
        Check(tent.Parts.Size()==80,"bounded local solid structure");
        Check(CaelumCampWorld.Get().Tents.Size()==1,"event registry owns one deployed tent");
        let body=Actor.Spawn('CA411DeployObstacle',tent.Pos+tent.LocalOffset((16,0,0)),NO_REPLACE);
        body.A_SetSize(u.Radius,u.Height/2,false);
        Check(body.TestMobjLocation(),"native crouched body fits through entrance");
        body.SetOrigin(tent.Pos,false);Check(body.TestMobjLocation(),"native crouched body fits under ridge");
        Console.Printf("CA411D body radius=%.3f height=%.3f",body.Radius,body.Height);body.Destroy();
        let probe=Actor.Spawn('CA411DeployObstacle',tent.Pos,NO_REPLACE);probe.bSolid=false;probe.A_SetSize(8,28,false);
        Check(tent.Covers(probe) && CaelumCampShelter.Find(probe)==tent,"local shelter query finds crouched body");
        probe.SetOrigin(tent.Pos+(0,40,0),false);Check(!tent.Covers(probe),"outside body receives no tent shelter");
        probe.SetOrigin(tent.Pos+(0,0,tent.Height),false);Check(!tent.Covers(probe),"standing on roof receives no shelter");probe.Destroy();
        Check(CaelumCampTask.BeginPack(u,tent),"owner can pack");Check(Near(u.CraftingTaskRemainingSeconds,300),"approved packing duration");
        u.CancelCraftingTask();Check(tent.Ready && tent.Item==item && item.Owner==tent,"cancel packing preserves deployed item");
        Check(CaelumCampTask.BeginPack(u,tent),"packing restarts");Finish(u);
        Check(item.Owner==u && item.Amount==1 && !u.CraftingTaskActive,"packing returns original object once");
        Check(CaelumCampWorld.Get().Tents.Size()==0,"packing clears shelter registry");
        for(int quadrant=0;quadrant<4;quadrant++)
        {
            u.SetOrigin((128,128,0),false);u.Angle=quadrant*90;
            bool began=CaelumCampTask.BeginSetup(u,item);if(began)Finish(u);
            let rotated=CaelumDeployedTent(item.Owner);
            Check(began && rotated!=null && Near(rotated.Angle,((quadrant+2)%4)*90),String.Format("entrance faces user at quadrant %d",quadrant));
            if(rotated!=null)
            {
                let body=Actor.Spawn('CA411DeployObstacle',rotated.Pos+rotated.LocalOffset((16,0,0)),NO_REPLACE);
                body.A_SetSize(u.Radius,u.Height/2,false);
                Check(body.TestMobjLocation() && rotated.Covers(body),String.Format("rotated native entrance and shelter %d",quadrant));body.Destroy();
                if(CaelumCampTask.BeginPack(u,rotated))Finish(u);
            }
        }
        Result();
    }
    void Seed(CaelumPlayer u)
    {
        Setup(u);let record=CA411DeployRecord(u.GiveInventoryType('CA411DeployRecord'));record.Item=Give(u);record.Item.args[0]=411;
        Check(CaelumCampTask.BeginSetup(u,record.Item),"saved setup starts");Finish(u);
        record.Tent=CaelumDeployedTent(record.Item.Owner);
        Check(record.Tent!=null && record.Tent.Ready,"saved tent deployed");Result();
    }
    void Loaded(CaelumPlayer u)
    {
        let record=CA411DeployRecord(u.FindInventory('CA411DeployRecord'));
        Check(record!=null,"carried proof survives save or hub");if(record==null)return;
        if(level.MapName=="MAP01")
        {
            let it=BlockThingsIterator.CreateFromPos(113,128,0,64,64,false);
            CaelumDeployedTent tent;
            while(it.Next()){let candidate=CaelumDeployedTent(it.thing);if(candidate!=null){tent=candidate;break;}}
            Check(tent!=null && tent.Ready && tent.Item!=null && tent.Item.Owner==tent,"deployed ownership survives save or hub");
            if(tent==null)return;
            Check(tent.Item.args[0]==411 && tent.Item.Amount==1,"original item marker and quantity survive");
            Check(tent.Parts.Size()==80 && tent.Parts[0].Structure==tent,"native parts remain linked");
            Check(CaelumCampWorld.Get().Tents.Find(tent)<CaelumCampWorld.Get().Tents.Size(),"load and hub rebuild typed shelter registry");
            Setup(u);Check(CaelumCampTask.BeginPack(u,tent),"packing permitted after return");u.CancelCraftingTask();
        }
        else Check(u.FindInventory('CaelumCampTent')==null,"travel does not clone deployed inventory");
        Result();
    }
    void WaitCheck(CaelumPlayer u)
    {
        Setup(u);let item=Give(u);Check(CaelumCampTask.BeginSetup(u,item),"wait setup starts");
        let thermal=CaelumThermalBody.Get(u);if(thermal!=null){Console.Printf("CA411D initial exposure=%g",thermal.Exposure);thermal.Exposure=0;}
        Console.Printf("CA411D WAIT guard=%s attended=%d",CaelumTimeSkipRules.BlockReason(u),CaelumCampTask.Attended(u));
        Console.Printf("CA411D flags talk=%d shop=%d equip=%d channel=%d staff=%d charge=%d charged=%d reload=%d block=%d debug=%d immobile=%d cheats=%d",u.HasActiveConversation(),u.PalomoMerchantMenuOpen,u.EquipmentMenuOpen,u.CombatChannelModeActive,u.StaffCastPending,u.WeaponChargeActive,u.WeaponChargedStateActive,u.RangedReloadActive,u.CombatBlockModeActive,u.DebugShieldBlocking,u.IsPhysicallyImmobilized(CaelumRestSafety.PeriodicPainOnly(u)),u.player.cheats);
        let rec=u.GetPersistentCharacterState(false);let journey=CaelumJourneyState.Get(u);
        Console.Printf("CA411D record commit=%d pending=%d journey=%d",rec.ProfileCommitted,rec.WorldPendingConnection,journey!=null?journey.Status:-1);
        Check(CaelumTimeSkipState.OpenMenu(u),"native wait panel opens for camp");
        let skip=CaelumTimeSkipState.Get(u);
        if(skip==null){Result();return;}
        for(int i=0;i<8 && skip.Forecast!=null && !skip.Forecast.Done;i++)skip.Forecast.RunBatch();
        Console.Printf("CA411D FORECAST reason=%s",skip.Forecast!=null?skip.Forecast.Reason:"missing");
        Check(skip.Forecast!=null && skip.Forecast.Done && skip.Forecast.Reason=="","camp wait forecast completes");
        if(skip.Forecast!=null){skip.TargetDay=skip.Forecast.EndDay;skip.TargetTics=skip.Forecast.EndTics;}
        Check(CaelumTimeSkipState.Start(u,true),"native wait begins");
        for(int i=0;i<8 && skip.Active;i++){skip.LastPumpTic=-1;CaelumTimeSkipState.Pump(u);}
        Check(!u.CraftingTaskActive && item.Owner is 'CaelumDeployedTent',"native wait deploys tent");
        Check(skip.WorkTics>=21000 && skip.WorkTics<=21001,"600 world seconds of work in Limbo");
        CaelumTimeSkipState.FinishSkip(u,"",true);Result();
    }
    void Climate(CaelumPlayer u)
    {
        Setup(u);let clock=CaelumWorldClock.Get(u);let calendar=CaelumCalendarState.Get(u);
        let weather=CaelumWeatherState.Get(u,true);CaelumWeatherState.Sync(u,clock,calendar);
        // Aislar una muestra ambiental estable; no inventa una region del juego.
        weather.Profile=5;weather.Outside.Available=true;weather.Outside.AirTemperatureC=26;
        weather.Outside.RelativeHumidityPercent=62;weather.Outside.WindSpeedKmh=18;
        weather.Outside.PrecipitationMmPerHour=4;
        let body=u;body.SetOrigin((128,128,0),false);body.A_SetSize(body.Radius,28,false);
        let thermal=CaelumThermalBody.Get(body,true);
        let world=CaelumThermalWorld.Get();world.ReferenceWeather=weather;
        CaelumThermalEnvironment.Sample(body,thermal);
        double air=thermal.AirC,humidity=thermal.Humidity,wind=thermal.AmbientWindKmh;
        let tent=CaelumDeployedTent(Actor.Spawn('CaelumDeployedTent',body.Pos,NO_REPLACE));Check(tent.Prepare(),"climate fixture structure");
        Check(CaelumThermalEnvironment.Sample(body,thermal),"thermal sample under tent");
        Check(Near(thermal.AirC,air) && Near(thermal.Humidity,humidity),"tent preserves existing ambient air and humidity");
        Check(thermal.Roof && Near(thermal.RainMmHour,0),"tent excludes rain");
        Check(Near(thermal.AmbientWindKmh,wind*0.1),"tent reduces ambient wind by approved factor");
        // Weather projection starts from Outside each time, so the factor cannot compound.
        u.A_SetSize(u.Radius,28,false);u.SetOrigin(tent.Pos,false);
        weather.SourceMap=level.MapName;weather.Revision=CaelumWeatherRules.REVISION;
        weather.Profile=1;weather.Region=0;weather.SampleDate=calendar.DateSerial(clock);
        weather.SampleMinute=calendar.CivilDayTics(clock)/(CaelumWorldClock.TicsPerHour()/60);
        weather.SamplePosition=u.Pos;weather.GeometryCheckedTic=level.maptime;
        weather.Shelter=CaelumWeatherRules.OPEN;weather.WindSheltered=false;weather.CampShelter=tent;
        CaelumWeatherState.Sync(u,clock,calendar);
        Check(Near(weather.Current.WindSpeedKmh,1.8) && Near(weather.Current.PrecipitationMmPerHour,0),"native weather applies wind and rain shelter");
        Check(Near(weather.Current.AirTemperatureC,26) && Near(weather.Current.RelativeHumidityPercent,62),"native weather keeps temperature and humidity");
        CaelumWeatherState.Sync(u,clock,calendar);Check(Near(weather.Current.WindSpeedKmh,1.8),"weather wind factor does not compound");
        u.SetOrigin((64,128,0),false);weather.SamplePosition=u.Pos;CaelumWeatherState.Sync(u,clock,calendar);
        Check(Near(weather.Current.WindSpeedKmh,18) && Near(weather.Current.PrecipitationMmPerHour,4),"leaving restores rain and wind before cache refresh");
        tent.Destroy();Result();
    }
    void LandContracts(CaelumPlayer u)
    {
        Setup(u);let record=CaelumPropertyRules.Find(CaelumPropertyData.CENTRAL_HOUSE,true);
        Check(!CaelumCampLand.OwnedHouse(u,CaelumPropertyData.CENTRAL_HOUSE),"unacquired home grants no camp permission");
        record.Holder=CaelumLockRules.Character(u,true);record.PaidUntil=CaelumScheduleState.Now(u)+CaelumWorldClock.TicsPerDay();
        Check(CaelumCampLand.OwnedHouse(u,record.House),"current rent grants camp permission");
        record.PaidUntil=CaelumScheduleState.Now(u);Check(!CaelumCampLand.OwnedHouse(u,record.House),"expired rent withdraws new placement permission");
        record.Purchased=true;Check(CaelumCampLand.OwnedHouse(u,record.House),"purchase grants lasting permission");Result();
    }
    void TaskSeed(CaelumPlayer u)
    {
        Setup(u);let item=Give(u);item.args[0]=412;
        Check(CaelumCampTask.BeginSetup(u,item),"pending setup seeded");u.CraftingTaskRemainingSeconds=450;Result();
    }
    void TaskLoaded(CaelumPlayer u)
    {
        if(level.MapName=="MAP01")
        {
            Check(CaelumCampTask.Active(u),"setup task survives save");let task=CaelumCampTask.Find(u);
            Check(task!=null && task.Item!=null && task.Item.args[0]==412 && task.Item.Owner==u,"pending setup keeps original inventory");
            Check(u.CraftingTaskRemainingSeconds>449 && u.CraftingTaskRemainingSeconds<=450,"pending duration survives save");
            Check(task!=null && task.Anchor!=null && CaelumTimeSkipState.TaskAnchor(u)==task.Anchor,"wait anchor survives save");
        }
        else
        {
            Check(!u.CraftingTaskActive,"map departure cancels unfinished attended assembly");
            let item=CaelumCampTent(u.FindInventory('CaelumCampTent'));Check(item!=null && item.args[0]==412,"cancelled journey keeps original item");
        }
        Result();
    }
    void Measure(CaelumPlayer u)
    {
        Setup(u);let world=CaelumCampWorld.Get();Array<CaelumDeployedTent> tents;
        for(int i=0;i<20;i++)
        {let t=CaelumDeployedTent(Actor.Spawn('CaelumDeployedTent',(2048+(i%5)*128,1024+(i/5)*128,0),NO_REPLACE));t.Prepare();tents.Push(t);}
        double total=0,worst=0;
        for(int i=0;i<100;i++){double start=MSTimeF();world.Rebuild();double ms=MSTimeF()-start;total+=ms;worst=Max(worst,ms);}
        Check(world.Tents.Size()==20,"one-time census matches twenty diagnostic shelters");
        Console.Printf("CA411D PERF one-time typed load census: tents=20 parts=1600 repeats=100 mean_ms=%.6f max_ms=%.6f",total/100,worst);
        for(int i=0;i<tents.Size();i++)tents[i].Destroy();
        Check(world.Tents.Size()==0 && CaelumCampShelter.Find(u)==null,"empty map skips shelter block query");Result();
    }
    void Select(CaelumPlayer u,Inventory item)
    {
        u.FormalInventoryFilter=0;u.RefreshFormalInventorySnapshot();
        for(int i=0;i<u.FormalInventoryEntryCount;i++)if(u.GetFormalInventoryEntryAt(i)==item){u.FormalInventorySelectionIndex=i;break;}
        u.RefreshFormalInventorySnapshot();
    }
    void Manual(CaelumPlayer u)
    {
        Setup(u);let record=CA411DeployRecord(u.FindInventory('CA411DeployRecord'));
        if(record==null)record=CA411DeployRecord(u.GiveInventoryType('CA411DeployRecord'));
        if(!record.ManualStarted){record.Item=Give(u);record.Item.args[0]=414;record.ManualStarted=true;}
        Console.Printf("CA411D RESULT manual room ready: inventory tent, F3 paving, F4 garden, F5 accelerated work");
    }
    void Handoff(CaelumPlayer u)
    {
        Manual(u);Manual(u);let record=CA411DeployRecord(u.FindInventory('CA411DeployRecord'));
        int count=0;for(Inventory item=u.Inv;item!=null;item=item.Inv)if(item is 'CaelumCampTent')count+=item.Amount;
        Check(count==1,"manual preparation cannot duplicate tent");Select(u,record.Item);
        u.ActivateFormalInventorySelection();Check(CaelumCampTask.Active(u),"normal inventory action starts assembly");
        u.ActivateFormalInventorySelection();Check(!u.CraftingTaskActive && record.Item.Owner==u,"normal inventory action cancels assembly");
        u.ActivateFormalInventorySelection();Check(CaelumTimeAdvanceState.Toggle(u),"accelerated attended work starts without exact forecast");
        let advance=CaelumTimeAdvanceState.Get(u);
        for(int i=0;i<250 && advance.Active;i++){advance.LastPumpTic=-1;CaelumTimeAdvanceState.Pump(u);}
        let tent=CaelumDeployedTent(record.Item.Owner);
        Check(tent!=null && !u.CraftingTaskActive && !advance.Active,"native acceleration completes assembly and stops");
        if(tent!=null)
        {
            Check(tent.Used(u) && CaelumCampTask.Active(u),"native use starts packing");
            Check(tent.Used(u) && CaelumCampTask.Active(u),"held use cannot immediately cancel packing");
            Check(CaelumTimeAdvanceState.Toggle(u),"accelerated packing begins");
            for(int i=0;i<150 && advance.Active;i++){advance.LastPumpTic=-1;CaelumTimeAdvanceState.Pump(u);}
            Check(record.Item.Owner==u && !u.CraftingTaskActive && !advance.Active,"native acceleration packs original item and stops");
        }
        Result();
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Player<0 || e.Player>=MAXPLAYERS)return;let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=='ca411d_core')Core(u);else if(e.Name=='ca411d_seed')Seed(u);else if(e.Name=='ca411d_loaded')Loaded(u);else if(e.Name=='ca411d_wait')WaitCheck(u);
        else if(e.Name=='ca411d_climate')Climate(u);else if(e.Name=='ca411d_land')LandContracts(u);
        else if(e.Name=='ca411d_taskseed')TaskSeed(u);else if(e.Name=='ca411d_taskload')TaskLoaded(u);else if(e.Name=='ca411d_measure')Measure(u);
        else if(e.Name=='ca411d_manual')Manual(u);else if(e.Name=='ca411d_handoff')Handoff(u);
        else if(e.Name=='ca411d_fast')CaelumTimeAdvanceState.Toggle(u);
        else if(e.Name=='ca411d_paving'){u.SetOrigin((384,128,16),false);u.Angle=0;}
        else if(e.Name=='ca411d_garden'){u.SetOrigin((64,128,0),false);u.Angle=0;}
        else if(e.Name=='ca411d_report'){Console.Printf("CA411D RESULT task=%d remaining=%.2f shelters=%d",u.CraftingTaskActive,u.CraftingTaskRemainingSeconds,CaelumCampWorld.Get().Tents.Size());}
    }
}
