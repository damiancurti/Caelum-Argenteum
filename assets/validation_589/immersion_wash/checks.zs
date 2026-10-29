class CA502WashChecks : CA502ImmersionChecks
{
    double CleanArea(CaelumThermalState t)
    {double area=0;for(int i=0;i<4;i++)area+=t.CleanWaterCoverage[i]*t.SurfaceArea;return area;}
    void Wash(CaelumPlayer u)
    {
        Reset(u,1000,50);Bare(u);u.DerivedStats.BaseMass=80;u.DerivedStats.HealthRegenerationPerSecond=0;
        Check(Near(CaelumContaminationRules.ImmersionWash(50,2,60,80),48),"one point per square metre per world minute");
        Check(Near(CaelumContaminationRules.ImmersionWash(50,2,60,40),46),"half mass doubles removal");
        Check(Near(CaelumContaminationRules.ImmersionWash(50,2,60,160),49),"double mass halves removal");
        Check(CaelumContaminationRules.ImmersionWash(0.01,2,60,80)==0,"cleaning clamps at zero");
        Check(CaelumContaminationRules.ImmersionWash(50,2,-1,80)==50
            && CaelumContaminationRules.ImmersionWash(50,-1,60,80)==50,"invalid time or area cannot create contamination or free cleaning");
        let t=Water(u,3);
        Check(t.CleanWaterRowMask==t.WaterRowMask && t.CleanWaterRowMask==65535,"potable volume identifies every submerged row");
        Check(Near(CleanArea(t),t.SurfaceArea),"full immersion uses actual body surface");
        let model=new('CaelumContaminationExposure');model.Capture(u,t);
        let illness=new('CaelumFoodIllness');illness.Ensure();illness.Contamination=50;
        model.Advance(illness,0,60);
        Check(Near(illness.Contamination,50-t.SurfaceArea),"captured full immersion removes calibrated body dose");
        double together=illness.Contamination;illness.Contamination=50;
        for(int i=0;i<2100;i++)model.Advance(illness,0,1.0/35);
        Check(Near(illness.Contamination,together),"clean-only immersion independent of subdivision");
        Check(CaelumFoodIllness.Value(u)==50,"wash forecast leaves live body unchanged");
        CaelumContaminationRuntime.PlayerStep(u,t,60);
        Check(Near(CaelumFoodIllness.Value(u),50-t.SurfaceArea),"production player step applies immersion washing");
        t=Water(u,5);model.Capture(u,t);illness.Contamination=50;model.Advance(illness,0,60);
        Check(CleanArea(t)>0 && CleanArea(t)<t.SurfaceArea && t.CleanWaterCoverage[0]==0,"partial potable immersion excludes dry head");
        Check(Near(illness.Contamination,50-CleanArea(t)),"partial removal uses submerged anatomical area");
        let copy=t.CopyForForecast();t.CleanWaterCoverage[3]=0;
        Check(copy.CleanWaterCoverage[3]>0,"forecast owns independent clean-water coverage");
        for(int cell=0;cell<5;cell++)if(cell!=2 && cell!=3)
        {
            t=Water(u,cell);model.Capture(u,t);illness.Contamination=50;model.Advance(illness,0,60);
            Check(t.CleanWaterRowMask==0 && CleanArea(t)==0 && illness.Contamination>=50,
                String.Format("salt biological chemical do not wash: cell%d",cell));
        }
        t=Water(u,3);model.Capture(u,t);model.ClearImmersion();illness.Contamination=50;model.Advance(illness,0,60);
        Check(illness.Contamination==50 && model.CleanArea[3]==0,"leaving water stops washing");
        t=Water(u,3);model.Capture(u,t);
        let weapon=CaelumEquipmentItem(Actor.Spawn('CaelumEquipmentItem',u.Pos,NO_REPLACE));
        weapon.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_WEAPON;weapon.ItemType=CaelumConstants.WEAPON_TYPE_SWORD;
        weapon.EquipmentSize=2;weapon.Amount=1;weapon.AttachToOwner(u);u.EnsureEquipmentItemId(weapon);
        CaelumContaminationStorage.Set(weapon,50);model.Capture(u,t);illness.Contamination=50;model.Advance(illness,0,60);model.Commit(u);
        Check(Near(CaelumContaminationStorage.Value(weapon),50),"body washing does not silently replace gear cleaning");
        Bare(u);u.SetOrigin((128,320,192),false);
    }
    void Waiting(CaelumPlayer u)
    {
        Regional(u);let t=Water(u,3);CaelumThermalEnvironment.Sample(u,t);t.Exposure=0;
        CaelumFoodIllness.Get(u).Contamination=40;
        let model=new('CaelumTimeSkipModel');model.CaptureSkip(u,false);model.RequiredTics=35;
        int batches=0;while(!model.Done && batches++<100)model.RunBatch();
        Check(model.ProvisionRevision==11 && model.ElapsedTics==35,"new waiting schema advances35 personal tics");
        Check(CaelumFoodIllness.Value(u)==40 && model.FoodIllness.Contamination<40,"independent waiting forecast includes washing");
        for(int i=0;i<35;i++)CaelumTimeAdvanceState.SimulatePersonalTic(u);
        Console.Printf("CA502 WASH forecast=%.12f native=%.12f",model.FoodIllness.Contamination,CaelumFoodIllness.Value(u));
        Check(Near(model.FoodIllness.Contamination,CaelumFoodIllness.Value(u)),"native world-time washing matches exact waiting prediction");
        let journey=new('CaelumJourneyModel');journey.Capture(u,false);
        let travel=new('CaelumThermalJourney');
        bool ok=travel.Forecast(u,CaelumJourneyState.MODE_CART,35,0,1,journey);
        Check(ok && journey.Contamination.CleanArea[3]==0,"abstract travel clears origin clean-water contact");
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!='ca502_wash' && e.Name!='ca502_wash_wait' && e.Name!='ca502_wash_manual'
            && e.Name!='ca502_wash_partial' && e.Name!='ca502_wash_seed' && e.Name!='ca502_wash_load'
            && e.Name!='ca502_wash_hub' && e.Name!='ca502_wash_dry' && e.Name!='ca502_wash_salt')
        {Super.NetworkProcess(e);return;}
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=='ca502_wash')Wash(u);
        else if(e.Name=='ca502_wash_wait')Waiting(u);
        else if(e.Name=='ca502_wash_dry')
        {u.SetOrigin((128,320,192),false);u.Vel=(0,0,0);Console.Printf("CA502 WASH dry: existing contamination retained; immersion washing stops.");}
        else if(e.Name=='ca502_wash_hub')
        {
            let t=CaelumThermalBody.Get(u,true);
            if(!CaelumThermalEnvironment.Sample(u,t))
            {
                double before=CaelumFoodIllness.Value(u);CaelumContaminationRuntime.PlayerStep(u,t,60);
                Check(CaelumFoodIllness.Value(u)==before,"unavailable arrival climate cannot apply stale immersion");
            }
            double wet=CaelumThermalEnvironment.SampleWater(u,t,20);
            CaelumThermalBody.SampleCoverage(u,t,wet,t.WaterRowMask);
            Check(t.CleanWaterRowMask==0 && CleanArea(t)==0,"dry hub arrival clears washing geometry");
            Check(CaelumFoodIllness.Value(u)>30 && CaelumFoodIllness.Value(u)<40,"hub preserves partially washed body");
            t=Water(u,3);CaelumThermalEnvironment.Sample(u,t);
            Check(t.CleanWaterRowMask!=0 && CleanArea(t)>0,"entering potable water after hub rebuilds washing geometry");
        }
        else if(e.Name=='ca502_wash_load')
        {
            Check(CaelumFoodIllness.Value(u)>35 && CaelumFoodIllness.Value(u)<40,"save retains partially washed contamination");
            let t=CaelumThermalBody.Get(u,true);CaelumThermalEnvironment.Sample(u,t);
            Check(t.CleanWaterRowMask!=0 && CleanArea(t)>0,"clean water is resampled after load");
        }
        else
        {
            Regional(u);u.Attributes.Toughness=100;u.DerivedStats.HealthRegenerationPerSecond=0;
            Water(u,e.Name=='ca502_wash_partial'?5:e.Name=='ca502_wash_salt'?0:3);CaelumFoodIllness.Get(u).Contamination=40;
            if(e.Name=='ca502_wash_seed')
            {
                CaelumContaminationRuntime.PlayerStep(u,CaelumThermalBody.Get(u),60);
                Check(CaelumFoodIllness.Value(u)<40,"seed partially washed body for save");
            }
            else {u.bInvulnerable=true;Console.Printf("CA502 WASH F1 full potable; F2 partial potable; F3 dry; F4 salt; F5 biological; F6 console. Contamination starts at40; compare its gradual reduction. Fixture invulnerability prevents drowning death; production breathing is unchanged.");}
        }
        Console.Printf("CA502 RESULT passes=%d failures=%d",Passed,Failed);
    }
}
