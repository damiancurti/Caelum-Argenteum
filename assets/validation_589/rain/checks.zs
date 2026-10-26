class CA502RainChecks : CA502ExposureChecks
{
    void Rain(CaelumPlayer u)
    {
        Check(Near(CaelumContaminationRules.RainReduction(-1),0),"negative rainfall contributes no reduction");
        Check(Near(CaelumContaminationRules.RainReduction(0),0),"dry weather unchanged");
        Check(Near(CaelumContaminationRules.RainReduction(1),5),"drizzle interpolates first segment");
        Check(Near(CaelumContaminationRules.RainReduction(2),10),"approved two mm per hour reduction");
        Check(Near(CaelumContaminationRules.RainReduction(6),15),"moderate rain interpolates second segment");
        Check(Near(CaelumContaminationRules.RainReduction(10),20),"approved heavy rain reduction");
        Check(Near(CaelumContaminationRules.RainReduction(100),20),"heavy rain cap");
        Check(Near(CaelumContaminationRules.Ambient(15,30,50,2,true),20),"rain subtracts after heat humidity amplification");
        Check(Near(CaelumContaminationRules.Ambient(15,20,50,10,true),0),"ambient concentration cannot become negative");
        Check(Near(CaelumContaminationRules.Ambient(15,30,50,10,false),30),"covered urban interior unchanged");
        Check(Near(CaelumContaminationRules.Ambient(5,30,50,10,true),10),"natural reference unchanged");
        Check(Near(CaelumContaminationRules.Ambient(40,30,50,10,true),80),"industrial reference unchanged");
        Reset(u,1000,0);Bare(u);u.SetOrigin((128,320,192),false);u.DerivedStats.BaseMass=80;
        let t=Thermal(u);t.AirC=30;t.Humidity=50;t.RainMmHour=2;t.Roof=false;
        Check(Near(CaelumContaminationEnvironment.ReferenceAt(u),15),"urban fixture uses real sector metadata");
        CaelumContaminationRuntime.PlayerStep(u,t,1);
        Check(Near(CaelumFoodIllness.Value(u),CaelumContaminationRules.AfterContact(0,20,t.SurfaceArea,1)),"real player exposure uses rain-reduced source");
        CaelumContaminationStorage.Set(u,80);CaelumContaminationRuntime.PlayerStep(u,t,1);
        Check(Near(CaelumFoodIllness.Value(u),80),"rain does not wash the body automatically");
        Regional(u);u.SetOrigin((128,320,192),false);
        let weather=CaelumWeatherState.Get(u);let clock=CaelumWorldClock.Get(u);let calendar=CaelumCalendarState.Get(u);
        int hours=0;
        while(weather.Current.PrecipitationMmPerHour<=0 && hours++<744)
        {clock.AdvanceTics(CaelumWorldClock.TicsPerHour());CaelumWeatherState.Sync(u,clock,calendar);}
        Check(weather.Current.PrecipitationMmPerHour>0 && weather.Shelter==CaelumWeatherRules.OPEN,"deterministic rainy hour on actual uncovered geometry");
        Check(Near(weather.Contamination,CaelumContaminationRules.Ambient(15,weather.Current.AirTemperatureC,
            weather.Current.RelativeHumidityPercent,weather.Current.PrecipitationMmPerHour,true)),"World journal samples same rain rule");
        CaelumThermalEnvironment.Sample(u,t);t.Exposure=0;
        let forecast=new('CaelumTimeSkipModel');forecast.CaptureSkip(u,false);forecast.RequiredTics=35;
        int batches=0;while(!forecast.Done && batches++<100)forecast.RunBatch();
        Check(forecast.ProvisionRevision==10 && forecast.ElapsedTics==35,"updated independent waiting projection runs");
        Check(CaelumFoodIllness.Value(u)==0,"forecast leaves live contamination untouched");
        for(int i=0;i<35;i++)CaelumTimeAdvanceState.SimulatePersonalTic(u);
        Console.Printf("CA502 RAIN mm=%.8f predicted=%.12f actual=%.12f",weather.Current.PrecipitationMmPerHour,forecast.FoodIllness.Contamination,CaelumFoodIllness.Value(u));
        Check(Near(forecast.FoodIllness.Contamination,CaelumFoodIllness.Value(u)),"rainy waiting matches native execution");
        Console.Printf("CA502 RESULT rain passes=%d failures=%d",Passed,Failed);
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Player<0 || !playeringame[e.Player])return;
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=="ca502_rain")Rain(u);else Super.NetworkProcess(e);
    }
}
