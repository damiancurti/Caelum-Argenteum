class CA502ImmersionChecks : CA502ExposureChecks
{
    CaelumThermalState Water(CaelumPlayer u,int cell)
    {
        u.SetOrigin((128+256*cell,128,0),false);
        let t=Thermal(u);
        double wet=CaelumThermalEnvironment.SampleWater(u,t,20);
        CaelumThermalBody.SampleCoverage(u,t,wet,t.WaterRowMask);
        return t;
    }
    double WetArea(CaelumThermalState t,bool dirty)
    {
        double value=0;
        for(int slot=0;slot<4;slot++)value+=dirty ? t.DirtyWaterCoverage[slot] : t.SubmergedCoverage[slot];
        return value*t.SurfaceArea;
    }
    void WaterChecks(CaelumPlayer u)
    {
        Reset(u,1000,0);Bare(u);u.DerivedStats.BaseMass=80;u.DerivedStats.HealthRegenerationPerSecond=0;
        double split=0;
        for(int i=0;i<350;i++)split=CaelumContaminationRules.TwoSources(split,5,1,100,1,1.0/35);
        Check(Near(split,CaelumContaminationRules.TwoSources(0,5,1,100,1,10)),"simultaneous air and water split-step parity");
        Check(Near(CaelumContaminationRules.TwoSources(0,5,1,100,1,10),Sqrt(200.0+5.0/21.0)),"independent integral changes slope when ambient5 is reached");
        let t=Water(u,0);
        Check(t.WaterRowMask==65535 && t.DirtyWaterRowMask==0,"salt-only volume fully wet without biological contact");
        let model=new('CaelumContaminationExposure');model.Capture(u,t);
        let illness=new('CaelumFoodIllness');illness.Ensure();model.Advance(illness,60,10);
        Check(illness.Contamination==0,"full clean or salt immersion excludes airborne surface exposure");
        illness.Contamination=50;model.Advance(illness,60,10);
        Check(illness.Contamination==50,"clean water contact does not wash existing contamination");
        t=Water(u,1);
        double wet=WetArea(t,true);
        Check(wet>0 && wet<t.SurfaceArea && t.DirtyWaterRowMask==t.WaterRowMask,"partial biological volume uses real 3D-floor rows");
        Check(t.DirtyWaterCoverage[0]==0 && t.DirtyWaterCoverage[3]>0,"partial water reaches legs without touching head");
        model.Capture(u,t);illness.Contamination=0;model.Advance(illness,0,10);
        double expected=CaelumContaminationRules.AfterContact(0,100,wet,10);
        Check(Near(illness.Contamination,expected),"bare biological dose equals submerged anatomical area");
        model.Capture(u,t);illness.Contamination=0;model.Advance(illness,5,10);
        expected=CaelumContaminationRules.TwoSources(0,5,t.SurfaceArea-wet,100,wet,10);
        Check(Near(illness.Contamination,expected),"air and water jointly integrate separate body surface");
        model.BodyKg=160;illness.Contamination=0;model.Advance(illness,0,10);
        Check(Near(illness.Contamination,CaelumContaminationRules.AfterContact(0,100,wet,10,0.5)),"water dose uses inverse body mass");
        model.BodyKg=80;illness.Contamination=0;model.Advance(illness,-1,10);
        Check(illness.Contamination>0,"known water works without an authored ambient category");
        let weapon=CaelumEquipmentItem(Actor.Spawn('CaelumEquipmentItem',u.Pos,NO_REPLACE));
        weapon.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_WEAPON;weapon.ItemType=CaelumConstants.WEAPON_TYPE_SWORD;
        weapon.EquipmentSize=2;weapon.Amount=1;weapon.AttachToOwner(u);u.EnsureEquipmentItemId(weapon);
        model.Capture(u,t);illness.Contamination=0;model.Advance(illness,0,10);model.Commit(u);
        double actual=CaelumContaminationStorage.Value(weapon);
        Check(Near(actual,CaelumContaminationRules.AfterContact(0,100,0.16*wet/t.SurfaceArea,10)),"loose sword uses its fixed area times submerged body fraction");
        weapon.InMagicBox=true;model.Capture(u,t);model.Advance(illness,100,100);model.Commit(u);
        Check(Near(CaelumContaminationStorage.Value(weapon),actual),"Box retains existing concentration while shielding water");
        let garment=CaelumClothing.Create(u,CaelumClothingData.Initial(3),2);
        garment.AttachToOwner(u);u.EnsureEquipmentItemId(garment);CaelumClothing.Equip(u,garment,true);
        CaelumContaminationStorage.Set(garment,0);model.Capture(u,t);illness.Contamination=0;
        model.Advance(illness,0,1);
        int index=model.Clothes[3];
        Check(index>=0 && Near(model.Items[index].Concentration,CaelumContaminationRules.AfterContact(0,100,t.SurfaceArea*t.DirtyWaterCoverage[3],1)),"worn garment uses submerged actual leg surface");
        Check(CaelumContaminationStorage.Value(garment)==0,"water projection leaves original garment untouched");
        let copy=t.CopyForForecast();t.DirtyWaterCoverage[3]=0;
        Check(copy.DirtyWaterCoverage[3]>0,"thermal water projection owns independent coverage");
        model.ClearImmersion();
        Check(model.WetFraction==0 && model.DirtyFraction==0 && model.DirtyArea[3]==0,"journey clears departure water contact");
        Bare(u);t=Water(u,3);Check(t.DirtyWaterRowMask==0,"potable volume remains contact-clean");
        t=Water(u,4);Check(t.DirtyWaterRowMask==65535,"chemical volume is contact100");
        model.Capture(u,t);illness.Contamination=0;model.Advance(illness,0,10);
        Check(Near(illness.Contamination,CaelumContaminationRules.AfterContact(0,100,t.SurfaceArea,10)),"chemical immersion full-body dose");
        t=Water(u,1);model.Capture(u,t);CaelumFoodIllness.Get(u).Contamination=0;u.ContaminationExposure=null;
        CaelumContaminationRuntime.PlayerStep(u,t,1);
        Check(CaelumFoodIllness.Value(u)>0,"production personal step applies water exposure");
        t.DynamicContactWater=true;model.Immersion(t);
        Check(model.DynamicWater,"connected level changes marked as unsupported stationary forecast");
        // La comprobación seca se ejecuta después de que el motor actualice WaterLevel.
        u.SetOrigin((128,320,192),false);
        Reset(u,1000,0);u.DerivedStats.HealthRegenerationPerSecond=0;
    }
    void WaterWait(CaelumPlayer u)
    {
        Regional(u);let t=Water(u,1);CaelumThermalEnvironment.Sample(u,t);t.Exposure=0;
        let model=new('CaelumTimeSkipModel');model.CaptureSkip(u,false);model.RequiredTics=35;
        int batches=0;while(!model.Done && batches++<100)model.RunBatch();
        Console.Printf("CA502 WATER projection ambient=%.12f wet=%.12f mass=%.12f area=%.12f",model.ContaminationWeather.Value,model.Contamination.DirtyFraction,model.Contamination.BodyKg,model.Contamination.BodyArea[3]);
        Check(model.ElapsedTics==35,"stationary water forecast executes35 personal tics");
        Check(CaelumFoodIllness.Value(u)==0 && model.FoodIllness.Contamination>0,"water wait projection independent of live body");
        for(int i=0;i<35;i++)CaelumTimeAdvanceState.SimulatePersonalTic(u);
        Console.Printf("CA502 WATER live ambient=%.12f wet=%.12f mass=%.12f area=%.12f",CaelumContaminationRules.Environment(5,t.AirC,t.Humidity),u.ContaminationExposure.DirtyFraction,u.ContaminationExposure.BodyKg,u.ContaminationExposure.BodyArea[3]);
        Console.Printf("CA502 WATER WAIT predicted=%.12f actual=%.12f",model.FoodIllness.Contamination,CaelumFoodIllness.Value(u));
        Check(Near(model.FoodIllness.Contamination,CaelumFoodIllness.Value(u)),"native world-time water exposure matches wait projection");
    }
    void Connected(CaelumPlayer u)
    {
        Reset(u,1000,0);Bare(u);u.DerivedStats.HealthRegenerationPerSecond=0;
        let installation=CaelumConnectedWaterMap.Get();
        Check(installation!=null && installation.Water!=null,"real mansion connected-water installation present");
        if(installation==null)return;
        installation.Water.QualityA=CaelumWaterQuality.BIOLOGICAL;
        u.SetOrigin((3736,92,-64),false);u.Vel=(0,0,0);
        let t=Thermal(u);CaelumThermalEnvironment.Sample(u,t);t.Exposure=0;
        Check(t.DynamicContactWater && t.DirtyWaterRowMask!=0,"campaign water reads current biological quality and dynamic geometry");
        let model=new('CaelumTimeSkipModel');model.CaptureSkip(u,false);
        Check(model.Done && model.ElapsedTics==0 && model.Reason=="CA_SKIP_FORECAST_EFFECT","changing connected reservoirs reject an exact stationary prediction");
        installation.Water.QualityA=CaelumWaterQuality.SALT;
        CaelumThermalEnvironment.Sample(u,t);
        Check(t.WaterRowMask!=0 && t.DirtyWaterRowMask==0,"current connected salt-only quality replaces earlier dirty rows");
    }
    void WetDeparture(CaelumPlayer u)
    {
        Regional(u);Water(u,1);let model=new('CaelumJourneyModel');model.Capture(u,false);
        Check(model.Contamination.DirtyFraction>0,"departure captures actual immersion");
        let forecast=new('CaelumThermalJourney');
        bool ok=forecast.Forecast(u,CaelumJourneyState.MODE_CART,350,0,1,model);
        Check(ok && model.Contamination.DirtyFraction==0 && model.Contamination.WetFraction==0,"abstract journey does not carry origin water along its route");
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!='ca502_water' && e.Name!='ca502_water_wait' && e.Name!='ca502_water_seed' && e.Name!='ca502_water_load'
            && e.Name!='ca502_water_manual' && e.Name!='ca502_water_salt' && e.Name!='ca502_water_clean'
            && e.Name!='ca502_water_chemical' && e.Name!='ca502_water_dry' && e.Name!='ca502_water_drycheck'
            && e.Name!='ca502_water_connected' && e.Name!='ca502_water_departure')
        {Super.NetworkProcess(e);return;}
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=='ca502_water')WaterChecks(u);
        else if(e.Name=='ca502_water_connected')Connected(u);
        else if(e.Name=='ca502_water_departure')WetDeparture(u);
        else if(e.Name=='ca502_water_drycheck')
        {
            let t=Thermal(u);double wet=CaelumThermalEnvironment.SampleWater(u,t,20);
            CaelumThermalBody.SampleCoverage(u,t,wet,t.WaterRowMask);
            Console.Printf("CA502 WATER dry x=%.2f y=%.2f z=%.2f water=%d row=%d dirty=%d area=%.9f sector=%d available=%d",u.Pos.X,u.Pos.Y,u.Pos.Z,u.WaterLevel,t.WaterRowMask,t.DirtyWaterRowMask,WetArea(t,true),u.CurSector.Index(),t.Available);
            Check(t.WaterRowMask==0 && t.DirtyWaterRowMask==0 && WetArea(t,true)==0,"leaving water clears all sampled contact zones");
        }
        else if(e.Name=='ca502_water_wait')WaterWait(u);
        else if(e.Name=='ca502_water_seed')
        {Regional(u);Water(u,1);CaelumFoodIllness.Get(u).Contamination=25;Check(true,"seed water save with body25");}
        else if(e.Name=='ca502_water_load')
        {
            Check(CaelumFoodIllness.Value(u)>=25,"saved body contamination is retained");
            let t=CaelumThermalBody.Get(u,true);CaelumThermalEnvironment.Sample(u,t);
            if(u.Pos.Y>=256)
            {
                Check(t.DirtyWaterRowMask==0,"dry hub arrival does not retain the old immersion");
                t=Water(u,1);CaelumThermalEnvironment.Sample(u,t);
            }
            Check(t.WaterContactReady && t.DirtyWaterRowMask!=0 && WetArea(t,true)>0,"water geometry rebuilt after save or hub return");
        }
        else
        {
            Regional(u);
            u.Attributes.Toughness=100;
            if(e.Name=='ca502_water_dry')u.SetOrigin((128,320,192),false);
            else Water(u,e.Name=='ca502_water_salt'?0:e.Name=='ca502_water_clean'?3:e.Name=='ca502_water_chemical'?4:1);
            Console.Printf("CA502 WATER F1 biological partial; F2 salt; F3 potable; F4 chemical; F5 dry. Inspect contamination HUD.");
        }
        Console.Printf("CA502 RESULT passes=%d failures=%d",Passed,Failed);
    }
}
