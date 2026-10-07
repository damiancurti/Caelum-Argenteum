class CA131Checks : StaticEventHandler
{
    CaelumPlayer User;
    CaelumCombatActor Demon;
    int Checks,Failures;
    void Verify(bool value,String label)
    {Checks++;if(!value)Failures++;Console.Printf("CA131 %s %s",value?"PASS":"FAIL",label);}
    bool Near(double a,double b){return Abs(a-b)<0.00000001;}
    override void WorldTick()
    {
        if(level.time==1)
        {
            User=CaelumPlayer(players[0].mo);User.InitializeDirectMapCharacter();User.PersistCharacterState();
            let marker=Actor.Spawn("CaelumClimateRegion",(0,0,0),NO_REPLACE);marker.args[0]=1;marker.args[1]=5;
            Demon=CaelumCombatActor(Actor.Spawn("CaelumMandinga",(1800,1800,0),NO_REPLACE));
        }
        if(level.time!=44)return;
        let stats=new("CaelumDerivedStats");let attributes=new("CaelumAttributes");stats.BaseMassMultiplier=2;
        attributes.Constitution=0;attributes.Resilience=100;stats.RefreshSurvivalLossMultipliers(attributes);
        Verify(stats.SleepLossMultiplier==1 && stats.HungerThirstLossMultiplier==2,"Resilience does not reduce Sleep; mass remains Hunger/Thirst-only");
        attributes.Constitution=100;attributes.Resilience=0;stats.RefreshSurvivalLossMultipliers(attributes);
        Verify(Near(stats.SleepLossMultiplier,1.0/3) && Near(stats.HungerThirstLossMultiplier,2.0/3),"Constitution uses the same Type-4 divider for all reserves");
        int levels[5]={0,25,50,100,150};
        for(int i=0;i<5;i++)
        {
            double factor=stats.CalculateType4Percent(levels[i])/100;
            Verify(Near(CaelumThermalRules.Acclimation(0,100,22,86400,factor),factor),"one-day rate follows Type 4");
            Verify(Near(CaelumThermalRules.Acclimation(0,100,22,5*86400,factor),5*factor),"warm limit reached in five world days");
            Verify(Near(CaelumThermalRules.Acclimation(0,-100,22,5*86400,factor),-5*factor),"cold limit reached in five world days");
            Verify(Near(CaelumThermalRules.Acclimation(5*factor,-100,22,10*86400,factor),-5*factor),"opposite limits require ten days");
        }
        Verify(CaelumThermalRules.Acclimation(15,100,22,0,1)==15,"attribute loss does not instantly clamp prior adaptation");
        Verify(CaelumThermalRules.Acclimation(15,100,22,86400,1)==14,"attribute loss returns at the new rate");
        Verify(CaelumThermalRules.Acclimation(15,100,22,10*86400,1)==5,"attribute loss settles at the new limit");
        Verify(CaelumThermalRules.Acclimation(0,24,22,86400,3)==2,"nearby climate stops at actual target");
        let thermal=CaelumThermalBody.Get(User,true);
        thermal.Revision=1;thermal.Exposure=7.25;thermal.Acclimation=14;thermal.BaseWaterKg[0]=0.007;thermal.DamageRemainder=0.4375;
        thermal.Initialize();thermal.Initialize();
        Verify(thermal.Revision==2 && thermal.Exposure==7.25 && thermal.Acclimation==14 && thermal.BaseWaterKg[0]==0.007 && thermal.DamageRemainder==0.4375,"revision 1 migration is idempotent and preserves personal state");
        User.Attributes.Resilience=100;User.Attributes.Constitution=0;CaelumThermalBody.Refresh(User,thermal);
        Verify(thermal.AcclimationMultiplier==3,"player uses current effective Resilience");
        let copy=CaelumThermalService.CaptureForecast(User);
        Verify(copy!=thermal && copy.AcclimationMultiplier==3 && copy.Acclimation==14,"journey copy carries the current adaptation profile");
        Demon.CombatArmor=null;Demon.CombatResilience=100;
        let npc=CaelumThermalBody.Get(Demon,true);CaelumThermalBody.Refresh(Demon,npc);
        Verify(npc!=thermal && npc.AcclimationMultiplier==3,"NPC owns independent adaptation using its effective attributes");
        thermal.Exposure=0;User.CurrentSleep=100;CaelumPlayerResources.UpdateSurvivalResources(User);
        double baseLoss=100-User.CurrentSleep;
        let journey=new("CaelumJourneyModel");journey.Capture(User,true);double baseJourney=journey.SleepLoss;
        User.Attributes.Constitution=100;User.Attributes.Resilience=0;User.CurrentSleep=100;
        CaelumPlayerResources.UpdateSurvivalResources(User);journey.Capture(User,true);
        Verify(baseLoss>0 && Near(100-User.CurrentSleep,baseLoss/3),"native passive Sleep follows Constitution");
        Verify(Near(journey.SleepLoss,baseJourney/3),"journey Sleep follows the same Constitution rule");
        Verify(CaelumThermalHUD.Position(0,0)==0.5 && CaelumThermalHUD.Range(100)==60,"HUD neutral center and Toughness-adjusted range");
        Verify(Near(CaelumThermalHUD.Position(-10,0),1.0/3) && Near(CaelumThermalHUD.Position(20,0),5.0/6),"HUD marks authoritative harmful thresholds");
        Verify(CaelumThermalHUD.Position(-1e12,0)==0 && CaelumThermalHUD.Position(1e12,0)==1,"extreme projection is visually bounded");
        Verify(CaelumThermalRules.Severity(30,0)==2 && CaelumThermalRules.Severity(30.001,0)==3,"exact tier boundary remains unchanged");
        Verify(CaelumThermalHUD.ViewedPlayer(0)==User,"HUD reads the local viewed player");
        let origin=new("CaelumWeatherSample");let destination=new("CaelumWeatherSample");let blended=new("CaelumWeatherSample");
        origin.EvaluateRegion(1,739895,0,116);destination.EvaluateRegion(9,739895,0,116);
        CaelumThermalJourney.BlendRoute(blended,origin,destination,0);
        Verify(blended.Available && blended.AirTemperatureC==origin.AirTemperatureC,"route begins in the actual origin climate");
        CaelumThermalJourney.BlendRoute(blended,origin,destination,1);
        Verify(blended.AirTemperatureC==destination.AirTemperatureC && Near(blended.RelativeHumidityPercent,destination.RelativeHumidityPercent),"route ends in the destination climate");
        CaelumThermalJourney.BlendRoute(blended,origin,destination,0.5);
        Verify(Near(blended.AirTemperatureC,(origin.AirTemperatureC+destination.AirTemperatureC)/2)
            && Near(blended.WindSpeedKmh,(origin.WindSpeedKmh+destination.WindSpeedKmh)/2)
            && Near(blended.PrecipitationMmPerHour,(origin.PrecipitationMmPerHour+destination.PrecipitationMmPerHour)/2),"route blends temperature, humidity and weather by distance");
        int hour=CaelumWorldClock.TicsPerHour();
        Verify(CaelumJourneyRules.MovingTics(16*hour,0)==CaelumJourneyRules.MovingTics(23*hour,0)
            && CaelumJourneyRules.MovingTics(25*hour,0)==17*hour,"sleep changes weather time without advancing walking distance");
        Verify(CaelumJourneyRules.MovingTics(23*hour,CaelumJourneyState.MODE_SHIP)==23*hour,"ship continues through passenger sleep");
        thermal.Exposure=0;thermal.Acclimation=0;thermal.BaseWaterKg[0]=0;thermal.BaseWaterKg[1]=0;
        User.Attributes.Toughness=10000;User.Attributes.Resilience=100;
        let warm=new("CaelumThermalJourney");let cold=new("CaelumThermalJourney");
        bool warmOK=warm.Forecast(User,CaelumJourneyState.MODE_SHIP,24*hour,9.26,1);
        bool coldOK=cold.Forecast(User,CaelumJourneyState.MODE_SHIP,24*hour,9.26,9);
        Console.Printf("CA131 ROUTE origin E=%.9f accl=%.9f air=%.9f destination E=%.9f accl=%.9f air=%.9f",warm.Result.Exposure,warm.Result.Acclimation,warm.Result.AirC,cold.Result.Exposure,cold.Result.Acclimation,cold.Result.AirC);
        Verify(warmOK && coldOK && Abs(warm.Result.Exposure-cold.Result.Exposure)>0.001
            && Abs(warm.Result.Acclimation-cold.Result.Acclimation)>0.001,"destination changes exposure and acclimatization during a full-day forecast");
        Verify(thermal.Exposure==0 && thermal.Acclimation==0 && warm.Result.DamageRemainder==thermal.DamageRemainder,"forecast does not mutate live state or synthesize real-time damage");
        Verify(cold.Result.WindSheltered && cold.Result.Roof && cold.Result.WindMps==0 && cold.Result.RainMmHour==0,"moving climate preserves passenger shelter");
        Verify(!cold.Forecast(User,CaelumJourneyState.MODE_SHIP,hour,9.26,0)
            && cold.Failure=="CA_JOURNEY_THERMAL_UNKNOWN","unknown destination climate blocks the forecast explicitly");
        User.Attributes.Toughness=0;thermal.Exposure=0;
        Verify(!cold.Forecast(User,CaelumJourneyState.MODE_SHIP,24*hour,9.26,9)
            && cold.Failure=="CA_JOURNEY_COLD","unsafe changing-climate route is blocked before departure");
        Console.Printf("CA131 COMPLETE checks=%d failures=%d",Checks,Failures);
    }
}
