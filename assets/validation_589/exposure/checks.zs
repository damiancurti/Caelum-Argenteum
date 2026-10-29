class CA502ExposureChecks : CA502Checks
{
    CaelumEquipmentItem PersistItem;
    int PersistItemId;
    void Bare(CaelumPlayer u)
    {
        for(Inventory cursor=u.Inv;cursor!=null;cursor=cursor.Inv)
        {
            let item=CaelumEquipmentItem(cursor);
            if(item!=null){item.InMagicBox=true;item.Equipped=false;}
        }
        u.ContaminationExposure=null;
    }
    CaelumThermalState Thermal(CaelumPlayer u)
    {
        let t=CaelumThermalBody.Get(u,true);CaelumThermalBody.Refresh(u,t);
        CaelumThermalBody.SampleCoverage(u,t,0);t.Available=true;
        t.AirC=20;t.AmbientAirC=20;t.Humidity=50;t.AmbientHumidity=50;
        t.SealClimateRevision=CaelumSealClimateData.REVISION;
        return t;
    }
    void Exposure(CaelumPlayer u)
    {
        Reset(u,1000,0);Bare(u);u.DerivedStats.BaseMass=80;
        u.DerivedStats.HealthRegenerationPerSecond=0;
        Check(Near(CaelumContaminationRules.GarmentArea(0,2),0.36590510719245)
            && Near(CaelumContaminationRules.GarmentArea(1,2),0.7318102143849)
            && Near(CaelumContaminationRules.GarmentArea(2,2),0.182952553596225)
            && Near(CaelumContaminationRules.GarmentArea(3,2),0.670826029852825),"approved fixed M garment areas");
        Check(Near(CaelumContaminationRules.GarmentArea(0,0),0.2305058732515),"fixed XS garment geometric conversion");
        let thermal=Thermal(u);
        for(int slot=0;slot<4;slot++)Check(Near(thermal.Coverage[slot],CaelumContaminationData.GarmentCoverage(slot)),"fixed reference matches existing humanoid thermal zone");
        let model=new('CaelumContaminationExposure');model.Capture(u,thermal);
        for(int slot=0;slot<4;slot++){model.BodyArea[slot]=0.5;model.ContactSource[slot]=80;}
        double together=model.BodyContact(20,10),split=20;
        for(int i=0;i<350;i++)split=model.BodyContact(split,1.0/35);
        Check(Near(together,26.8328157299975),"four bare zones integrate as one two-square-meter body");
        Check(Near(together,split),"bare exposure independent of subdivision");
        model.ContactSource[0]=5;model.ContactSource[1]=10;model.ContactSource[2]=40;
        together=model.BodyContact(0,1000);split=0;
        for(int i=0;i<1000;i++)split=model.BodyContact(split,1);
        Check(Near(together,split) && together<=80,"different sources stop contributing at their own concentration");
        model.Capture(u,thermal);
        let illness=new('CaelumFoodIllness');illness.Ensure();
        model.Advance(illness,5,1);
        double expected=CaelumContaminationRules.AfterContact(0,5,thermal.SurfaceArea,1);
        Check(Near(illness.Contamination,expected),"bare ambient dose uses actual physiological surface");
        Check(Near(CaelumFoodIllness.Value(u),0),"projection leaves live contamination unchanged");
        CaelumThermalService.Advance(u,1,0);
        Check(Near(CaelumFoodIllness.Value(u),expected),"production thermal/world step applies environmental dose");
        let garment=CaelumClothing.Create(u,CaelumClothingData.Initial(1),2);
        garment.AttachToOwner(u);u.EnsureEquipmentItemId(garment);CaelumClothing.Equip(u,garment,true);
        CaelumContaminationStorage.Set(garment,0);u.ContaminationExposure=null;
        model.Capture(u,thermal);illness.Contamination=0;model.Advance(illness,80,1);
        int cloth=model.Clothes[1];
        Check(cloth>=0 && model.Items[cloth].Concentration>0,"worn clothing receives ambient contamination");
        Check(CaelumContaminationStorage.Value(garment)==0,"forecast equipment remains independent");
        model.Commit(u);
        Check(CaelumContaminationStorage.Value(garment)>0,"forecast commit applies original equipment state");
        garment.InMagicBox=true;model.Capture(u,thermal);double stored=CaelumContaminationStorage.Value(garment);
        model.Advance(illness,100,100);model.Commit(u);
        Check(Near(CaelumContaminationStorage.Value(garment),stored),"Box excludes automatic environmental exposure");
        let layered=new('CaelumContaminationExposure');layered.BodyKg=80;
        for(int i=0;i<4;i++){layered.Armor[i]=-1;layered.Clothes[i]=-1;}
        layered.BodyArea[1]=1;layered.Armor[1]=0;layered.Clothes[1]=1;
        let armor=new('CaelumContaminationEquipment');armor.Worn=true;layered.Items.Push(armor);
        let under=new('CaelumContaminationEquipment');under.Worn=true;layered.Items.Push(under);
        illness.Contamination=0;layered.Advance(illness,80,1);
        Check(armor.Concentration>under.Concentration && under.Concentration>illness.Contamination
            && illness.Contamination>0,"outer armor then clothing then body contact");
        armor.Concentration=0;under.Concentration=0;illness.Contamination=80;layered.Advance(illness,0,1);
        Check(Near(illness.Contamination,80) && under.Concentration>0,"dirty body contaminates inner clothing without washing body");
        let weather=CaelumWeatherState.Get(u,true);
        weather.Profile=CaelumWeatherRules.PROFILE_LIMBO;weather.Shelter=CaelumWeatherRules.LIMBO;
        if(weather.Current==null)weather.Current=new('CaelumWeatherSample');weather.Current.Available=true;
        let waitWeather=new('CaelumContaminationWaitWeather');waitWeather.Capture(u);
        Check(Near(waitWeather.Sample(0,0),5.25) && Near(waitWeather.Sample(9,0),5.25),"Limbo forecast uses fixed atmosphere across local dates");
        Check(CaelumTimeSkipModel.PROVISION_REVISION==8,"wait schema8 invalidates forecasts without exposure");
        Bare(u);Reset(u,1000,0);u.DerivedStats.HealthRegenerationPerSecond=0;
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!='ca502_exposure' && e.Name!='ca502_exposure_wait' && e.Name!='ca502_exposure_journey'
            && e.Name!='ca502_exposure_wait_equipped' && e.Name!='ca502_exposure_seed'
            && e.Name!='ca502_exposure_loaded' && e.Name!='ca502_exposure_manual' && e.Name!='ca502_exposure_classify'
            && e.Name!='ca502_exposure_journal')
        {Super.NetworkProcess(e);return;}
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=='ca502_exposure')Exposure(u);
        else if(e.Name=='ca502_exposure_wait')Wait(u,false);
        else if(e.Name=='ca502_exposure_wait_equipped')Wait(u,true);
        else if(e.Name=='ca502_exposure_seed')SaveExposure(u);
        else if(e.Name=='ca502_exposure_loaded')LoadExposure(u);
        else if(e.Name=='ca502_exposure_classify')Classify(u);
        else if(e.Name=='ca502_exposure_journal')
        {
            Regional(u);let record=u.GetPersistentCharacterState(true);
            for(int id=1;id<CaelumWorldCatalogue.LOCATION_DEFINED_COUNT;id++)record.WorldLocationVisited[id]=true;
            for(int id=1;id<CaelumWorldCatalogue.CONNECTION_DEFINED_COUNT;id++)
            {record.WorldConnectionKnown[id]=true;record.WorldConnectionTraversed[id]=true;}
        }
        else if(e.Name=='ca502_exposure_manual')
        {Regional(u);Console.Printf("CA502 AMBIENT use the World journal and survival HUD; F2 executes the wait comparison.");}
        else Journey(u);
        Console.Printf("CA502 RESULT passes=%d failures=%d",Passed,Failed);
    }
    void Regional(CaelumPlayer u)
    {
        Reset(u,1000,0);Bare(u);u.DerivedStats.BaseMass=80;u.DerivedStats.HealthRegenerationPerSecond=0;
        let marker=Actor.Spawn('CaelumClimateRegion',u.Pos,NO_REPLACE);marker.args[0]=1;marker.args[1]=5;
        let weather=CaelumWeatherState.Get(u,true);weather.SourceMap="";
        weather.RegionMarker=CaelumClimateRegion(marker);weather.MarkerCheckedTic=level.maptime;weather.Seed=502;
        CaelumWeatherState.Sync(u,CaelumWorldClock.Get(u),CaelumCalendarState.Get(u));
        let t=Thermal(u);t.SourceMap="";t.Exposure=0;
        CaelumThermalEnvironment.Sample(u,t);
    }
    void Wait(CaelumPlayer u,bool equipped)
    {
        Regional(u);
        CaelumEquipmentItem garment;
        if(equipped)
        {
            garment=CaelumClothing.Create(u,CaelumClothingData.Initial(1),2);
            garment.AttachToOwner(u);u.EnsureEquipmentItemId(garment);CaelumClothing.Equip(u,garment,true);
            u.ContaminationExposure=null;
        }
        let model=new('CaelumTimeSkipModel');model.CaptureSkip(u,false);model.RequiredTics=350;
        int batches=0;while(!model.Done && batches++<100)model.RunBatch();
        Check(model.Done && model.ElapsedTics==350,"native wait forecast advances350 personal tics");
        Check(CaelumFoodIllness.Value(u)==0 && model.FoodIllness.Contamination>0,"wait predicts exposure without changing live body");
        for(int i=0;i<350;i++)CaelumTimeAdvanceState.SimulatePersonalTic(u);
        Console.Printf("CA502 WAIT predicted=%.12f actual=%.12f worldSeconds=%.9f",model.FoodIllness.Contamination,CaelumFoodIllness.Value(u),350*CaelumThermalRuntime.WorldTicSeconds());
        Check(Near(model.FoodIllness.Contamination,CaelumFoodIllness.Value(u)),"world-clock waiting matches environmental forecast across minute changes");
        if(garment!=null)
        {
            int index=model.Contamination.Clothes[1];
            Check(index>=0 && Near(model.Contamination.Items[index].Concentration,CaelumContaminationStorage.Value(garment)),
                "native worn equipment exposure equals wait projection");
        }
        // La capa térmica tiene su propio balance; este caso compara la contaminación.
        double total=0,worst=0;let thermal=Thermal(u);
        for(int i=0;i<1000;i++)
        {
            double start=MSTimeF();CaelumContaminationRuntime.PlayerStep(u,thermal,1.0/TICRATE);
            double ms=MSTimeF()-start;total+=ms;worst=Max(worst,ms);
        }
        Console.Printf("CA502 MEASURE player equipped=%d 1000 mean_ms=%.9f maximum_ms=%.9f",equipped,total/1000,worst);
        Reset(u,1000,0);u.DerivedStats.HealthRegenerationPerSecond=0;
    }
    void Journey(CaelumPlayer u)
    {
        Regional(u);let model=new('CaelumJourneyModel');model.Capture(u,false);
        let forecast=new('CaelumThermalJourney');
        bool ok=forecast.Forecast(u,CaelumJourneyState.MODE_CART,350,0,1,model);
        Check(ok && model.ElapsedTics==350 && model.FoodIllness.Contamination>0,"travel forecasts include world-time environmental exposure");
        Check(CaelumFoodIllness.Value(u)==0,"travel preview leaves actual body untouched");
        let plan=CaelumJourneyPlan.Get(u,true);plan.Available=model;plan.ThermalForecast=forecast;
        plan.Apply(u);
        Check(Near(CaelumFoodIllness.Value(u),model.FoodIllness.Contamination),"native travel apply commits projected contamination once");
        Reset(u,1000,0);u.DerivedStats.HealthRegenerationPerSecond=0;
    }
    void SaveExposure(CaelumPlayer u)
    {
        Regional(u);CaelumFoodIllness.Get(u).Contamination=12.5;
        PersistItem=CaelumEquipmentItem(Actor.Spawn('CaelumWeaponPickup',u.Pos+(100,0,0),NO_REPLACE));
        PersistItem.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_WEAPON;
        PersistItem.ItemType=CaelumConstants.WEAPON_TYPE_SWORD;PersistItem.EquipmentSize=2;
        PersistItem.AttachToOwner(u);PersistItemId=u.EnsureEquipmentItemId(PersistItem);
        CaelumContaminationStorage.Set(PersistItem,73.125);
        let plan=CaelumJourneyPlan.Get(u,true);plan.Available=new('CaelumJourneyModel');plan.Available.Capture(u,false);
        plan.Available.FoodIllness.Contamination=25;
        Check(plan.Available.Contamination!=null && plan.Available.Contamination.Items.Size()==1,"save contains independent equipment exposure projection");
        plan.Available.Contamination.Items[0].Concentration=61.75;u.PersistCharacterState();
    }
    void LoadExposure(CaelumPlayer u)
    {
        let plan=CaelumJourneyPlan.Get(u);
        let carried=u.FindNativeEquipmentItemById(PersistItemId);
        Check(Near(CaelumFoodIllness.Value(u),12.5),"save or hub preserves live body exposure");
        Check(carried!=null && Near(CaelumContaminationStorage.Value(carried),73.125),"save or hub preserves original equipment exposure by stable identity");
        bool ok=plan!=null && plan.Available!=null && plan.Available.Contamination!=null;
        Check(ok && Near(plan.Available.FoodIllness.Contamination,25),"save or hub preserves forecast body independently");
        Check(ok && plan.Available.Contamination.Items.Size()==1
            && plan.Available.Contamination.Items[0].Item==carried
            && Near(plan.Available.Contamination.Items[0].Concentration,61.75),"save or hub preserves independent projection linked to original item");
    }
    void Classify(CaelumPlayer u)
    {
        Reset(u,1000,0);
        Check(CaelumContaminationData.MapClass("MAP01")==2 && CaelumContaminationData.MapClass("MAP03")==2
            && CaelumContaminationData.MapClass("MAP02")==4 && CaelumContaminationData.MapClass("TCOAST")==1,
            "campaign urban sewer and coast classifications");
        Check(CaelumContaminationData.Reference(CaelumContaminationData.MapClass("UNKNOWN"))<0,"unknown map does not invent environmental concentration");
        let iterator=ThinkerIterator.Create('CaelumCraftingStation');Actor station;int count=0;bool ok=true;
        while((station=Actor(iterator.Next()))!=null)
            if(station is 'CaelumForgeStation' || station is 'CaelumSawmillStation' || station is 'CaelumAlchemyStation')
            {count++;ok=ok && Near(CaelumContaminationEnvironment.ReferenceAt(station),40);}
        Console.Printf("CA502 INDUSTRY stations=%d",count);
        Check(count>0 && ok,"actual campaign workshop sectors use industrial reference");
        let world=CaelumContaminationWorld.Get();WorldEvent event;
        double sum=0,maximum=0;
        for(int i=0;i<100;i++)
        {double start=MSTimeF();world.WorldLoaded(event);double ms=MSTimeF()-start;sum+=ms;maximum=Max(maximum,ms);}
        Console.Printf("CA502 MEASURE100 actual workshop load censuses mean_ms=%.9f maximum_ms=%.9f",sum/100,maximum);
    }
}
