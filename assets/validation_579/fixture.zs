// Private engine assertions; intentionally excluded from src/.
class CA409Checks : EventHandler
{
    int Passed,Failed;
    CaelumCraftingStation Bench,Alchemy;
    double SavedRemaining;
    int SavedCoal;
    int QualityMode;
    CaelumWaterContainer GroundGlass;
    void Check(bool ok,String label)
    {if(ok)Passed++;else Failed++;Console.Printf("CA409 %s %s",ok?"PASS":"FAIL",label);}
    bool Near(double a,double b){return Abs(a-b)<0.000001;}
    void Setup(CaelumPlayer user)
    {
        user.CancelCraftingTask();user.CombatTimeRemaining=0;
        if(Bench==null)Bench=CaelumCraftingStation(Actor.Spawn("CaelumWorkbenchStation",(72,-40,0),NO_REPLACE));
        if(Alchemy==null)Alchemy=CaelumCraftingStation(Actor.Spawn("CaelumAlchemyStation",(72,40,0),NO_REPLACE));
        let coal=user.FindNativeSpecialItem(CaelumConstants.EQUIPMENT_KIND_MATERIAL,CaelumConstants.MATERIAL_COAL,1);
        if(coal==null){let raw=CaelumMaterialPickup(Actor.Spawn("CaelumMaterialPickup",(160,160,0),NO_REPLACE));raw.args[0]=CaelumConstants.MATERIAL_COAL;raw.args[1]=1;raw.Amount=10000;raw.AttachToOwner(user);}else coal.Amount=10000;
        let thermal=CaelumThermalBody.Get(user,true);
        thermal.Available=true;thermal.AmbientAirC=20;thermal.AmbientWindKmh=0;
    }
    CaelumWaterContainer Water(CaelumPlayer user,Name type='CaelumCanteenSmall')
    {
        let water=CaelumWaterContainer(user.FindInventory(type));
        if(water==null)water=CaelumWaterContainer(user.GiveInventoryType(type));
        water.InMagicBox=false;water.WaterLiters=1;water.WaterQuality=CaelumWaterQuality.BIOLOGICAL;
        water.WaterTemperatureRevision=1;water.WaterTemperatureC=20;water.CoolingSeconds=0;
        return water;
    }
    void Finish(CaelumPlayer user)
    {user.CraftingTaskRemainingSeconds=1.0/TICRATE;user.UpdateCraftingTask();}
    void Checks(CaelumPlayer user)
    {
        Check(Near(CaelumWaterThermalData.Seconds(1,20),460.8),"1 L / 20 C calibration 460.8 s");
        Check(CaelumWaterThermalData.Fuel(1,20)==66,"coal ceil 66 grams");
        Check(Abs(CaelumWaterThermalData.Output(1)-0.973416)<0.000001,"26.584 mL boil loss");
        Check(Near(CaelumWaterThermalData.Seconds(1,100),60),"hot input retains full boiling minute");
        Check(Near(CaelumWaterThermalData.Mix(0.25,100,0.75,20),40),"heat-balanced unequal volumes");
        double cool=CaelumWaterThermalData.Cool(100,20,0,600,1,1,true);
        Check(cool>20 && cool<100,"leather cools gradually");
        Check(CaelumWaterThermalData.Cool(100,20,10,600,1,1,true)<cool,"wind increases cooling");
        Check(Near(CaelumWaterThermalData.Cool(100,20,0,1000000,1,1,true),20),"large interval never overshoots ambient");
        Setup(user);let water=Water(user);
        int coal=user.CountRawCraftingMaterial(CaelumConstants.MATERIAL_COAL,1);
        Check(CaelumWaterBoiling.Begin(user,water),"begin at connected alchemy and workbench");
        Check(user.GetReservedCraftingMaterialUnits(CaelumConstants.MATERIAL_COAL,1)==66,"fuel reserved");
        Check(user.CountRawCraftingMaterial(CaelumConstants.MATERIAL_COAL,1)==coal,"begin spends nothing");
        Check(CaelumWaterBoiling.Locked(water),"target locked");
        Check(!water.EmptyWater(user) && !water.AddWater(0.1,0),"fill and empty cannot bypass reservation");
        Check(water.CreateTossable(1)==null,"native drop cannot bypass reservation");
        Check(!CaelumContainerRules.Allowed(user,water,true),"chest deposit locked");
        Check(!CaelumCityTradeSession.Sellable(user,water),"merchant sale locked");
        Check(!CaelumWaterBoiling.Begin(user,water),"duplicate task rejected");
        user.CraftingTaskRemainingSeconds-=100;user.CancelCraftingTask();
        Check(!CaelumWaterBoiling.Locked(water) && user.GetReservedCraftingMaterialUnits(CaelumConstants.MATERIAL_COAL,1)==0,"cancel releases reservations");
        Check(Near(water.WaterLiters,1) && Near(water.WaterTemperatureC,20) && water.WaterQuality==1
            && user.CountRawCraftingMaterial(CaelumConstants.MATERIAL_COAL,1)==coal,"cancel no spend heat loss or purification");
        for(int quality=0;quality<=7;quality++)
        {
            water=Water(user);water.WaterQuality=quality;
            Check(CaelumWaterBoiling.Begin(user,water),String.Format("begin quality %d",quality));
            Finish(user);
            Check(!user.CraftingTaskActive && water.WaterQuality==(quality&~1),String.Format("biological only quality %d",quality));
            Check(Near(water.WaterLiters,CaelumWaterThermalData.Output(1)) && Near(water.WaterTemperatureC,100),String.Format("volume and temperature quality %d",quality));
            Check(!water.Drink() && !water.IsDrinkable(),String.Format("hot water blocked quality %d",quality));
        }
        Check(user.CountRawCraftingMaterial(CaelumConstants.MATERIAL_COAL,1)==coal-8*66,"exactly one fuel commit per completion");
        user.CompleteCraftingTask();
        Check(user.CountRawCraftingMaterial(CaelumConstants.MATERIAL_COAL,1)==coal-8*66,"retry cannot consume twice");
        water.WaterQuality=0;water.WaterTemperatureC=85;
        Check(water.IsDrinkable(),"85 C inclusive");water.WaterTemperatureC=85.0001;
        Check(!water.IsDrinkable() && CaelumTimeSkipRules.Kind(water)==0,"above 85 C excluded from automatic supplies");
        water=Water(user);water.WaterLiters=0.01;
        Check(!CaelumWaterBoiling.Begin(user,water),"evaporating entire tiny batch rejected");
        water=Water(user);water.InMagicBox=true;
        Check(!CaelumWaterBoiling.Begin(user,water),"Box target rejected");water.InMagicBox=false;
        user.CombatTimeRemaining=1;Check(!CaelumWaterBoiling.Begin(user,water),"combat start rejected");user.CombatTimeRemaining=0;
        Check(CaelumWaterBoiling.Begin(user,water),"resume fixture");
        double remaining=user.CraftingTaskRemainingSeconds;user.CombatTimeRemaining=1;user.UpdateCraftingTask();
        Check(Near(remaining,user.CraftingTaskRemainingSeconds) && user.CraftingTaskActive,"combat pauses without cancelling");user.CombatTimeRemaining=0;
        user.CloseCraftingStationSession();user.UpdateCraftingTask();
        Check(Near(remaining,user.CraftingTaskRemainingSeconds),"closed session pauses");
        int token=user.BeginCraftingNetworkScan();Alchemy.CollectCraftingNetwork(user,token);user.OpenCraftingNetwork(Alchemy);
        Finish(user);Check(!user.CraftingTaskActive && Near(water.WaterTemperatureC,100),"reopened station resumes original task");
        let clock=CaelumWorldClock.Get(user);
        water.StampTemperature(user);
        clock.AdvanceTics(300*TICRATE);water.AdvanceTemperature(user,0);
        Check(water.WaterTemperatureC<85 && water.WaterTemperatureC>0,"world-clock gap cools carried canteen");
        Name types[6]={'CaelumBottleSmall','CaelumBottleNormal','CaelumBottleLarge','CaelumCanteenSmall','CaelumCanteenNormal','CaelumCanteenLarge'};
        for(int i=0;i<6;i++)
        {
            let vessel=Water(user,types[i]);vessel.WaterLiters=vessel.GetCapacityLiters();
            double input=vessel.WaterLiters;
            Check(CaelumWaterBoiling.Begin(user,vessel),String.Format("capacity start %s",types[i]));
            Finish(user);Check(Near(vessel.WaterLiters,CaelumWaterThermalData.Output(input)),String.Format("whole capacity %s",types[i]));
        }
        Console.Printf("CA409 RESULT smoke passed=%d failed=%d",Passed,Failed);
    }
    void GlassChecks(CaelumPlayer user)
    {
        Setup(user);
        Check(Abs(CaelumWaterThermalData.Cool(100,20,0,600,1,1,false)-95.93838671323086)<0.000001,
            "one litre glass independent SI reference after ten minutes");
        double cold=CaelumWaterThermalData.Cool(0,20,0,600,1,1,false);
        Check(cold>0 && cold<20,"glass warms toward hotter ambient without overshoot");
        double still=CaelumWaterThermalData.Cool(100,20,0,600,1,1,false);
        Check(CaelumWaterThermalData.Cool(100,20,10,600,1,1,false)<still,"wind accelerates glass cooling");
        Check(Near(CaelumWaterThermalData.Cool(100,20,0,1000000,1,1,false),20),"large glass clock gap approaches ambient");
        Check(Near(CaelumWaterThermalData.Cool(100,20,0,0,1,1,false),100),"zero elapsed glass interval is inert");
        double half=CaelumWaterThermalData.Cool(100,20,0,300,1,1,false);
        Check(Near(CaelumWaterThermalData.Cool(half,20,0,300,1,1,false),still),"split and combined glass intervals agree");
        Name types[3]={'CaelumBottleSmall','CaelumBottleNormal','CaelumBottleLarge'};
        let clock=CaelumWorldClock.Get(user);
        for(int i=0;i<3;i++)
        {
            let bottle=Water(user,types[i]);bottle.WaterLiters=bottle.GetCapacityLiters();
            Check(CaelumWaterBoiling.Begin(user,bottle),String.Format("glass process starts %s",types[i]));Finish(user);
            double volume=bottle.WaterLiters;
            Check(Near(bottle.WaterTemperatureC,100) && !bottle.IsDrinkable(),"fresh boiled glass water is hot and blocked");
            bottle.StampTemperature(user);clock.AdvanceTics(600*TICRATE);bottle.AdvanceTemperature(user,0);
            Check(bottle.WaterTemperatureC>20 && bottle.WaterTemperatureC<85 && bottle.IsDrinkable(),"cooled glass becomes drinkable");
            Check(Near(bottle.WaterLiters,volume) && bottle.WaterQuality==0,"glass cooling preserves volume and purification");
        }
        let bottle=Water(user,'CaelumBottleSmall');bottle.WaterLiters=0.25;bottle.WaterTemperatureC=100;
        Check(bottle.AddWater(0.75,CaelumWaterQuality.SALT,20,true) && Near(bottle.WaterTemperatureC,40),"native glass refill mixes water temperature");
        Check(bottle.WaterQuality==(CaelumWaterQuality.BIOLOGICAL|CaelumWaterQuality.SALT),"thermal mixing retains contamination union");
        bottle.WaterTemperatureC=100;bottle.InMagicBox=true;bottle.StampTemperature(user);
        clock.AdvanceTics(600*TICRATE);bottle.AdvanceTemperature(user,0);
        Check(bottle.WaterTemperatureC<85 && Near(bottle.WaterLiters,1),"Box glass cooling preserves contents");
        Console.Printf("CA409 RESULT glass passed=%d failed=%d",Passed,Failed);
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let user=CaelumPlayer(players[e.Player].mo);if(user==null)return;
        if(e.Name=="ca409_glass_wait")
        {
            Setup(user);let water=Water(user,'CaelumBottleSmall');water.WaterTemperatureC=100;water.StampTemperature(user);
            user.CurrentThirst=100;user.CurrentHunger=100;user.CurrentSleep=100;
            CaelumThermalBody.Get(user).Exposure=0;
            Actor.Spawn('CaelumTimeAdvanceZone',user.Pos,NO_REPLACE);
            Check(CaelumTimeSkipState.OpenMenu(user),"dated cooling wait opens");
            Check(CaelumTimeSkipState.Start(user),"dated cooling wait starts without task forecast");
        }
        else if(e.Name=="ca409_glass_waitcheck")
        {
            let water=CaelumWaterContainer(user.FindInventory('CaelumBottleSmall'));let skip=CaelumTimeSkipState.Get(user);
            Check(skip!=null && skip.Completed && skip.LastReason=="CA_SKIP_COMPLETE","dated one-hour wait completes");
            Check(water.WaterTemperatureC<85 && water.WaterTemperatureC>0,"actual wait cools hot glass below drinking threshold");
            Check(water.WaterQuality==1 && !water.IsDrinkable(),"cooling alone does not purify contaminated water");
            water.WaterQuality=0;Check(water.IsDrinkable(),"clean water at the cooled temperature is drinkable");
            Console.Printf("CA409 RESULT glass wait passed=%d failed=%d",Passed,Failed);
        }
        else if(e.Name=="ca409_glass")GlassChecks(user);
        else if(e.Name=="ca409_glass_live")
        {
            Setup(user);let water=Water(user,'CaelumBottleSmall');water.WaterTemperatureC=100;water.StampTemperature(user);
            GroundGlass=CaelumWaterContainer(water.CreateTossable(1));
            Check(GroundGlass!=null && Near(GroundGlass.WaterTemperatureC,100),"native glass drop preserves hot water");
            if(GroundGlass!=null)GroundGlass.SetOrigin((160,160,0),false);
            water=Water(user,'CaelumBottleSmall');water.WaterTemperatureC=100;water.StampTemperature(user);
        }
        else if(e.Name=="ca409_glass_tickcheck")
        {
            let water=CaelumWaterContainer(user.FindInventory('CaelumBottleSmall'));
            Check(water!=null && water.WaterTemperatureC<100 && water.WaterTemperatureC>85,"native inventory tics cool glass");
            Check(GroundGlass!=null && GroundGlass.WaterTemperatureC<100 && GroundGlass.WaterTemperatureC>85,"native world tics cool dropped glass");
            Console.Printf("CA409 RESULT glass live passed=%d failed=%d",Passed,Failed);
        }
        else if(e.Name=="ca409_glass_save")
        {
            Setup(user);let water=Water(user,'CaelumBottleSmall');water.WaterTemperatureC=90;water.WaterLiters=0.5;water.WaterQuality=2;water.StampTemperature(user);
            user.PersistCharacterState();Check(!water.IsDrinkable(),"hot glass save prepared");
            Console.Printf("CA409 RESULT glass save passed=%d failed=%d",Passed,Failed);
        }
        else if(e.Name=="ca409_glass_load")
        {
            let water=CaelumWaterContainer(user.FindInventory('CaelumBottleSmall'));
            Check(water!=null && water.WaterTemperatureRevision==1 && water.WaterTemperatureC>85 && water.WaterTemperatureC<90,"saved glass temperature continues cooling without ambient reset");
            Check(water!=null && Near(water.WaterLiters,0.5) && water.WaterQuality==2,"hot glass save retains contents and contamination");
            Console.Printf("CA409 RESULT glass load passed=%d failed=%d",Passed,Failed);
        }
        else if(e.Name=="ca409_checks")Checks(user);
        else if(e.Name=="ca409_save")
        {
            Setup(user);let water=Water(user);Check(CaelumWaterBoiling.Begin(user,water),"persistent start");
            user.CloseCraftingStationSession();SavedRemaining=user.CraftingTaskRemainingSeconds;
            SavedCoal=user.CountRawCraftingMaterial(CaelumConstants.MATERIAL_COAL,1);
            Console.Printf("CA409 RESULT save prepared passed=%d failed=%d",Passed,Failed);
        }
        else if(e.Name=="ca409_load")
        {
            let brew=CaelumWaterBoilingState.Find(user);
            Check(brew!=null && brew.Container!=null && CaelumWaterBoiling.Locked(brew.Container),"saved target identity and lock");
            Check(Near(user.CraftingTaskRemainingSeconds,SavedRemaining),"saved paused time preserved");
            Check(user.CountRawCraftingMaterial(CaelumConstants.MATERIAL_COAL,1)==SavedCoal,"saved fuel not spent");
            int token=user.BeginCraftingNetworkScan();Alchemy.CollectCraftingNetwork(user,token);user.OpenCraftingNetwork(Alchemy);
            Finish(user);
            Check(user.CountRawCraftingMaterial(CaelumConstants.MATERIAL_COAL,1)==SavedCoal-66,"loaded task commits once");
            Console.Printf("CA409 RESULT load passed=%d failed=%d",Passed,Failed);
        }
        else if(e.Name=="ca409_live")
        {
            Setup(user);let water=Water(user);Check(CaelumWaterBoiling.Begin(user,water),"live start");
            user.CraftingTaskRemainingSeconds=2;
        }
        else if(e.Name=="ca409_tickcheck")
        {
            let water=CaelumWaterContainer(user.FindInventory("CaelumCanteenSmall"));
            Check(!user.CraftingTaskActive && water.WaterQuality==0 && water.WaterTemperatureC>85,"native unpaused tics complete transaction");
            Console.Printf("CA409 RESULT live passed=%d failed=%d",Passed,Failed);
        }
        else if(e.Name=="ca409_manual")
        {
            Setup(user);QualityMode=0;Water(user);Water(user,'CaelumBottleSmall');user.CurrentThirst=50;
            Actor.Spawn('CaelumTimeAdvanceZone',user.Pos,NO_REPLACE);
            user.RefreshFormalInventorySnapshot();
            for(int i=0;i<user.FormalInventoryEntryCount;i++)
                if(user.GetFormalInventoryEntryAt(i)==user.FindInventory('CaelumCanteenSmall')){user.FormalInventorySelectionIndex=i;break;}
            user.RefreshFormalInventorySnapshot();
            Console.Printf("CA409 RESULT author fixture ready: inventory water, H to boil, crafting C cancels, wait available.");
        }
        else if(e.Name=="ca409_quality")
        {
            if(user.CraftingTaskActive)return;
            QualityMode=(QualityMode+1)%4;
            Water(user).WaterQuality=1|(QualityMode<<1);Water(user,'CaelumBottleSmall').WaterQuality=1|(QualityMode<<1);
            user.RefreshFormalInventorySnapshot();
            Check(true,"manual quality variant prepared");Console.Printf("CA409 RESULT manual quality=%d",1|(QualityMode<<1));
        }
        else if(e.Name=="ca409_wait")
        {
            Setup(user);let water=Water(user);Check(CaelumWaterBoiling.Begin(user,water),"wait task started");
            let thermal=CaelumThermalBody.Get(user);thermal.Exposure=0;
            Check(CaelumTimeSkipState.OpenMenu(user),"wait menu opens");
            let skip=CaelumTimeSkipState.Get(user);
            if(skip!=null && skip.Forecast!=null)
            {
                skip.Forecast.RunBatch();
                Check(skip.Forecast.Reason=="","thermal task forecast available");
                if(skip.Forecast.Reason!="")Console.Printf("CA409 wait reason %s",skip.Forecast.Reason);
            }
            Check(CaelumTimeSkipState.Start(user),"wait confirms");
        }
        else if(e.Name=="ca409_waitcheck")
        {
            let water=CaelumWaterContainer(user.FindInventory('CaelumCanteenSmall'));
            Check(!user.CraftingTaskActive && water.WaterQuality==0,"wait completes actual water process");
            Check(user.CountRawCraftingMaterial(CaelumConstants.MATERIAL_COAL,1)==9934,"wait commits coal once");
            Console.Printf("CA409 RESULT wait passed=%d failed=%d",Passed,Failed);
        }
    }
}
