class CA502MetabolicProof : Inventory
{
    double Capacity;
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA502MetabolicChecks : CA502WashChecks
{
    void Metabolism(CaelumPlayer u)
    {
        Reset(u,1000,40);Bare(u);u.DerivedStats.HealthRegenerationPerSecond=0;
        let illness=CaelumFoodIllness.Get(u);illness.ToiletCapacity=0;
        illness.Satiation(10);illness.Satiation(10);
        Check(illness.ToiletCapacity==1,"Hunger and Hydration contributions combine at20-to-one");
        illness.Satiation(5);
        Check(illness.ToiletCapacity==1.25,"fractional capacity retained");
        illness.Satiation(-50);Check(illness.ToiletCapacity==1.25,"resource losses do not earn or consume credit");
        illness.Satiation(1000);Check(illness.ToiletCapacity==20,"stored capacity caps at20");
        Check(illness.ToiletDepurate()==20 && illness.Contamination==20 && illness.ToiletCapacity==0,"one use spends only earned capacity");
        Check(illness.ToiletDepurate()==0 && illness.Contamination==20,"repeat use cannot cleanse without fresh capacity");
        illness.Satiation(200);illness.Contamination=2.5;
        Check(illness.ToiletDepurate()==2.5 && illness.ToiletCapacity==7.5 && illness.Contamination==0,"small contamination preserves unused capacity");
        Check(illness.ToiletAmount()==0 && illness.ToiletCapacity==7.5,"clean body offers no effective use");
        illness.DamageFraction=0.375;illness.Contamination=40;illness.MetabolismRevision=0;illness.ToiletCapacity=5;illness.Ensure();
        Check(illness.Contamination==40 && illness.DamageFraction==0.375 && illness.ToiletCapacity==0,"additive migration preserves disease without retrospective credit");
        illness.Satiation(25);illness.Ensure();
        Check(illness.ToiletCapacity==1.25,"migration idempotent after earning capacity");
        let copy=illness.Copy();copy.Satiation(20);
        Check(copy.ToiletCapacity==2.25 && illness.ToiletCapacity==1.25,"forecast capacity copies independently");
        illness.ToiletCapacity=0;u.CurrentHunger=90;u.CurrentThirst=90;
        u.ApplyConsumableRegenerationPulse(CaelumConstants.CONSUMABLE_FOOD_RATION,15);
        Check(u.CurrentHunger==100 && illness.ToiletCapacity==0.5,"ration credits only actual Hunger gain");
        u.ApplyConsumableRegenerationPulse(CaelumConstants.CONSUMABLE_FOOD_RATION,15);
        Check(illness.ToiletCapacity==0.5,"full Hunger cannot earn excess-food credit");
        let water=CaelumRegenerationPower(u.GiveInventoryType('CaelumThirstRegeneration'));
        water.WaterRecoveryPerPulse=15;water.PulseTics=TICRATE-1;water.DoEffect();
        Check(u.CurrentThirst==100 && illness.ToiletCapacity==1,"water power credits only actual Hydration gain");
        water.PulseTics=TICRATE-1;water.DoEffect();
        Check(illness.ToiletCapacity==1,"full Hydration cannot earn excess-water credit");water.Destroy();
        u.CurrentThirst=99.5;u.ApplyConsumableRegenerationPulse(CaelumConstants.CONSUMABLE_WATER_RATION);
        Check(Near(illness.ToiletCapacity,1.025),"legacy direct water pulse credits capped actual recovery");
        let mate=CaelumMateRecovery(u.GiveInventoryType('CaelumMateRecovery'));
        u.CurrentThirst=90;mate.AddDose(20,0);for(int i=0;i<350;i++)mate.DoEffect();
        Check(u.CurrentThirst==100 && Near(illness.ToiletCapacity,1.525),"mate hydration earns metabolic credit even without Life healing");
        mate.AddDose(20,0);for(int i=0;i<350;i++)mate.DoEffect();
        Check(Near(illness.ToiletCapacity,1.525),"mate at full Hydration earns no additional credit");mate.Destroy();
        double before=illness.ToiletCapacity;
        CaelumFoodIllness.Recover(u,u.CaelumMaximumHealth);CaelumContaminationStorage.Treatment(u,0.1);
        Check(illness.ToiletCapacity==before,"natural depuration and treatments do not create or spend metabolic credit");
    }
    void Forecasts(CaelumPlayer u)
    {
        Reset(u,1000,0);Bare(u);let illness=CaelumFoodIllness.Get(u);illness.ToiletCapacity=2;
        u.CurrentHunger=99;u.CurrentThirst=99;
        let model=new('CaelumJourneyModel');model.Capture(u,false);
        model.FoodPulse=2;model.WaterPulse=2;model.FoodEffectTics=35;model.WaterEffectTics=35;
        for(int i=0;i<35;i++)model.Pulses();
        Check(Near(model.FoodIllness.ToiletCapacity,2.1) && illness.ToiletCapacity==2,"journey projects actual food/water credit independently");
        let plan=CaelumJourneyPlan.Get(u,true);plan.Available=model;plan.Apply(u);
        illness=CaelumFoodIllness.Get(u);
        Check(Near(illness.ToiletCapacity,2.1) && illness!=model.FoodIllness,"journey commits independent metabolic capacity");
        model.FoodIllness.ToiletCapacity=10;
        Check(Near(illness.ToiletCapacity,2.1),"later preview mutation cannot change committed capacity");
        u.CurrentHunger=99;u.CurrentThirst=99;illness.ToiletCapacity=3;
        let wait=new('CaelumTimeSkipModel');wait.CaptureSkip(u,false);wait.HasChair=false;
        wait.FoodPulse=2;wait.WaterPulse=2;wait.FoodEffectTics=35;wait.WaterEffectTics=35;
        for(int i=0;i<35;i++)wait.Pulses();
        Check(wait.ProvisionRevision==12 && Near(wait.FoodIllness.ToiletCapacity,3.1),"new wait projection credits real gains without overflow");
        Check(illness.ToiletCapacity==3,"waiting preview leaves live capacity unchanged");
    }
    void PoolWait(CaelumPlayer u)
    {
        let t=CaelumThermalBody.Get(u);CaelumThermalEnvironment.Sample(u,t);t.Exposure=0;
        u.CurrentThirst=80;u.CurrentHunger=80;u.CurrentSleep=80;
        let illness=CaelumFoodIllness.Get(u);illness.ToiletCapacity=0;
        Check(u.IsSubmergedInPotableWater(),"real potable immersion enables passive drinking");
        let model=new('CaelumTimeSkipModel');model.CaptureSkip(u,false);model.RequiredTics=35;
        int batches=0;while(!model.Done && batches++<100)model.RunBatch();
        for(int i=0;i<35;i++)CaelumTimeAdvanceState.SimulatePersonalTic(u);
        Console.Printf("CA502 METABOLISM water live=%.12f forecast=%.12f capacity=%.12f/%.12f",u.CurrentThirst,model.Thirst,illness.ToiletCapacity,model.FoodIllness.ToiletCapacity);
        Check(Near(model.Thirst,u.CurrentThirst),"potable waiting hydration matches native drinking");
        Check(Near(model.FoodIllness.ToiletCapacity,illness.ToiletCapacity) && illness.ToiletCapacity>0,"potable waiting metabolic capacity matches native drinking");
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!='ca502_metabolism' && e.Name!='ca502_metabolic_forecast' && e.Name!='ca502_metabolic_pool'
            && e.Name!='ca502_metabolic_seed' && e.Name!='ca502_metabolic_load')
        {Super.NetworkProcess(e);return;}
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=='ca502_metabolism')Metabolism(u);
        else if(e.Name=='ca502_metabolic_forecast')Forecasts(u);
        else if(e.Name=='ca502_metabolic_pool')PoolWait(u);
        else if(e.Name=='ca502_metabolic_seed')
        {
            Regional(u);u.SetOrigin((128,320,192),false);
            let illness=CaelumFoodIllness.Get(u);illness.ToiletCapacity=7.125;
            let proof=CA502MetabolicProof(u.GiveInventoryType('CA502MetabolicProof'));proof.Capacity=illness.ToiletCapacity;
            u.PersistCharacterState();Check(true,"seed fractional capacity and independent travelling proof");
        }
        else
        {
            let proof=CA502MetabolicProof(u.FindInventory('CA502MetabolicProof'));
            Check(proof!=null && CaelumFoodIllness.Get(u).ToiletCapacity==proof.Capacity,"save or hub retains fractional capacity exactly");
        }
        Console.Printf("CA502 RESULT passes=%d failures=%d",Passed,Failed);
    }
}
