// #410: comparación de la previsión con la enfermedad y recuperación nativas.
class CA410JChecks : EventHandler
{
    int Passed,Failed;
    void Check(bool ok,String label)
    {if(ok)Passed++;else Failed++;Console.Printf("CA410J %s %s",ok?"PASS":"FAIL",label);}
    bool Near(double a,double b){return Abs(a-b)<0.000001;}
    void Reset(CaelumPlayer u,int health,double contamination,double toughness=0)
    {
        u.CreationWizardOpen=false;u.bInvulnerable=false;
        u.CaelumMaximumHealth=1000;u.health=health;u.player.health=health;
        u.CurrentHunger=80;u.CurrentThirst=80;u.CurrentSleep=80;u.UpdateSurvivalStates();
        u.CurrentAnima=u.DerivedStats.MaximumAnima;u.CurrentAir=u.DerivedStats.MaximumAir;
        u.NaturalHealthRegenerationAccumulator=0;u.SurvivalDamageAccumulator=0;
        u.DerivedStats.HealthRegenerationPerSecond=TICRATE;
        u.Attributes.Toughness=toughness;
        let illness=CaelumFoodIllness.Get(u);illness.Contamination=contamination;illness.DamageFraction=0;
    }
    void Isolate(CaelumJourneyModel m)
    {
        m.HungerLoss=0;m.ThirstLoss=0;m.SleepLoss=0;m.AirRate=0;m.AnimaRate=0;
        m.FoodStock=0;m.WaterStock=0;m.ContainerStock=0;m.Unlimited=false;
        m.Bag=false;m.Altitude=null;
    }
    void Parity(CaelumPlayer u,int health,double contamination,double toughness,int tics,bool critical=false)
    {
        Reset(u,health,contamination,toughness);
        if(critical){u.CurrentHunger=10;u.UpdateSurvivalStates();}
        let model=new('CaelumJourneyModel');model.Capture(u,false);Isolate(model);
        // Hambre crítica produce daño de supervivencia compartido; se compara
        // también ese paso, no se omite para favorecer el resultado.
        for(int i=0;i<tics && u.health>0 && model.Health>0;i++)
        {
            model.Step(false);
            u.ApplyCriticalSurvivalDamage();
            if(u.health>0)CaelumFoodIllness.Advance(u);
            if(u.health>0)CaelumPlayerResources.ApplyNaturalHealthRegeneration(u);
        }
        let actualIllness=CaelumFoodIllness.Get(u);
        String key=String.Format("life=%d contamination=%.2f toughness=%.0f critical=%d",health,contamination,toughness,critical);
        Console.Printf("CA410J PARITY %s actual=%d model=%d C=%.9f/%.9f H=%.9f/%.9f W=%.9f/%.9f",key,u.health,model.Health,actualIllness.Contamination,model.FoodIllness.Contamination,u.CurrentHunger,model.Hunger,u.CurrentThirst,model.Thirst);
        Check(u.health==model.Health,key.." native Life parity");
        Check(Near(actualIllness.Contamination,model.FoodIllness.Contamination),key.." native depuration parity");
        Check(Near(actualIllness.DamageFraction,model.FoodIllness.DamageFraction),key.." native disease fraction parity");
        Check(Near(u.CurrentHunger,model.Hunger) && Near(u.CurrentThirst,model.Thirst),key.." exact native costs");
        Check(Near(u.NaturalHealthRegenerationAccumulator,model.HealingFraction),key.." healing accumulator parity");
    }
    void Core(CaelumPlayer u)
    {
        Reset(u,1000,60);
        let actual=CaelumFoodIllness.Get(u);actual.DamageFraction=0.375;
        let model=new('CaelumJourneyModel');model.Capture(u,false);Isolate(model);model.HealthRate=0;
        Check(model.FoodIllness!=actual && model.FoodIllness.Contamination==60 && model.FoodIllness.DamageFraction==0.375,"capture copies contamination and pending damage without aliasing");
        for(int i=0;i<TICRATE*2;i++)model.Step(false);
        Check(model.Health==980 && Near(model.FoodIllness.DamageFraction,0.375),"two forecast seconds preserve fractional damage and lose twenty Life");
        Check(u.health==1000 && actual.Contamination==60 && actual.DamageFraction==0.375,"forecast leaves live character unchanged");
        let copy=actual.Copy();copy.Contamination=1;copy.DamageFraction=0;
        Check(actual.Contamination==60 && actual.DamageFraction==0.375,"forecast copies are independent");
        Parity(u,900,0,0,100);
        Parity(u,1000,1,0,100);
        Parity(u,900,2,0,100);
        Parity(u,1000,60,0,100);
        Parity(u,1000,100,100,100);
        Parity(u,1000,100,150,100);
        Parity(u,1100,1,0,100);
        Parity(u,1000,0.0005,0,2);
        Parity(u,1000,60,0,35,true);
        Reset(u,1000,100);model=new('CaelumJourneyModel');model.Capture(u,false);Isolate(model);model.HealthRate=0;
        model.Health=1;model.Step(false);
        Check(model.Health==0 && model.ElapsedTics==1,"lethal disease stops before regeneration");
        Reset(u,1000,60);model=new('CaelumJourneyModel');model.Capture(u,false);Isolate(model);model.HealthRate=0;
        model.FoodToughness=50;for(int i=0;i<TICRATE;i++)model.Step(false);
        Check(model.Health==1000-int(CaelumFoodRules.DamagePerSecond(60,1000,50)+0.0000001),"intermediate Toughness uses the approved resistance curve");
        Reset(u,1000,1);
        let skip=new('CaelumTimeSkipModel');skip.CaptureSkip(u,false);Isolate(skip);
        skip.HasChair=false;skip.FoodTrigger=-1;skip.WaterTrigger=-1;
        for(int i=0;i<100;i++)skip.Step(false);
        Check(skip.ProvisionRevision==6 && Near(skip.FoodIllness.Contamination,0.9),"wait forecast uses full-Life potential depuration and revision six");
        Check(CaelumFoodIllness.Value(u)==1 && u.CurrentHunger==80,"wait forecast is nonmutating");
        Reset(u,1000,0);
    }
    void Commit(CaelumPlayer u)
    {
        Reset(u,1000,60);
        let plan=CaelumJourneyPlan.Get(u,true);plan.Available=new('CaelumJourneyModel');
        plan.Available.Capture(u,false);Isolate(plan.Available);plan.Available.HealthRate=0;
        for(int i=0;i<TICRATE;i++)plan.Available.Step(false);
        plan.Available.FoodIllness.Contamination=59.75;plan.Available.FoodIllness.DamageFraction=0.625;
        plan.ThermalForecast=null;
        plan.Apply(u);
        let illness=CaelumFoodIllness.Get(u);
        Check(u.health==990 && illness.Contamination==59.75 && illness.DamageFraction==0.625,"native travel apply commits forecast Life and illness exactly");
        Check(illness!=plan.Available.FoodIllness,"committed illness does not alias the menu model");
        plan.Available.FoodIllness.Contamination=12;
        Check(illness.Contamination==59.75,"later model mutation cannot change committed illness");
        Reset(u,1000,0);
    }
    void Seed(CaelumPlayer u)
    {
        Reset(u,1000,12.5);u.DerivedStats.HealthRegenerationPerSecond=0;
        let illness=CaelumFoodIllness.Get(u);illness.DamageFraction=0.375;
        let plan=CaelumJourneyPlan.Get(u,true);plan.Available=new('CaelumJourneyModel');
        plan.Available.Capture(u,false);plan.Available.FoodIllness.Contamination=25;
        plan.Available.FoodIllness.DamageFraction=0.625;
        plan.Open=false;u.PersistCharacterState();
        Check(plan.Available.FoodIllness!=illness,"independent live and forecast illness saved");
    }
    void Loaded(CaelumPlayer u)
    {
        let plan=CaelumJourneyPlan.Get(u);let illness=CaelumFoodIllness.Get(u);
        Check(illness!=null && illness.Contamination>12.49 && illness.Contamination<=12.5 && illness.DamageFraction==0.375,"native save or hub preserves live illness");
        Check(plan!=null && plan.Available!=null && plan.Available.FoodIllness!=null
            && plan.Available.FoodIllness.Contamination==25 && plan.Available.FoodIllness.DamageFraction==0.625,"native save or hub preserves independent forecast");
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Player<0 || e.Player>=MAXPLAYERS)return;
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=='ca410j_core')Core(u);
        else if(e.Name=='ca410j_commit')Commit(u);
        else if(e.Name=='ca410j_seed')Seed(u);
        else if(e.Name=='ca410j_loaded')Loaded(u);
        else return;
        Console.Printf("CA410J RESULT passes=%d failures=%d",Passed,Failed);
    }
}
