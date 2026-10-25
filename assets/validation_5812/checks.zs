class CA502HProof : Inventory
{
    double Water,Stamp,Capacity,Contamination,Remaining;
    CaelumDomesticWaterState Reserve;
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA502HChecks : EventHandler
{
    int Passed,Failed;
    void Check(bool ok,String label)
    {if(ok)Passed++;else Failed++;Console.Printf("CA502H %s %s",ok?"PASS":"FAIL",label);}
    bool Near(double a,double b){return Abs(a-b)<0.00001;}
    CaelumDomesticToilet Toilet(CaelumPlayer u)
    {
        CaelumBathroomInstallation.Prepare(CaelumHouseHubData.HouseForMap(level.MapName));
        let it=ThinkerIterator.Create('CaelumBathroomInstallation');let room=CaelumBathroomInstallation(it.Next());
        return room==null?null:CaelumDomesticToilet(room.Fixtures[2]);
    }
    void Aim(CaelumPlayer u,CaelumDomesticFixture fixture)
    {u.SetOrigin(fixture.Pos+(-56,0,0),false);u.Vel=(0,0,0);u.Angle=0;u.Pitch=ATan2(u.ViewHeight-fixture.Height/2,56);}
    void Reset(CaelumPlayer u,double contamination=40,double capacity=20)
    {
        CaelumHygieneTask.Cancel(u);CaelumTimeAdvanceState.Halt(u);
        u.CombatTimeRemaining=0;u.EquipmentMenuOpen=false;u.CraftingMenuOpen=false;u.PalomoMerchantMenuOpen=false;
        u.Attributes.Toughness=100;u.ApplyCharacterProfile();u.health=u.CaelumMaximumHealth;u.player.health=u.health;
        u.PainImmobilizationRemaining=0;u.RestNonPeriodicPainRemaining=0;u.RestPeriodicPainRemaining=0;
        u.CurrentHunger=100;u.CurrentThirst=100;u.CurrentSleep=100;
        let illness=CaelumFoodIllness.Get(u);illness.Contamination=contamination;illness.ToiletCapacity=capacity;illness.DamageFraction=0;
        let fixture=Toilet(u);if(fixture!=null){Aim(u,fixture);let water=CaelumDomesticWater.Get(fixture.House);water.Liters=100;}
    }
    void Core(CaelumPlayer u)
    {
        Reset(u);let fixture=Toilet(u);let illness=CaelumFoodIllness.Get(u);let water=CaelumDomesticWater.Get(fixture.House);
        Check(u.TestMobjLocation() && fixture.CanReach(u) && CaelumUseGeometry.AimedAt(u,fixture),"production toilet physically reachable");
        Check(fixture.Used(u) && CaelumHygieneTask.Active(u),"native Use starts session");
        Check(Near(u.CraftingTaskRemainingSeconds,60) && Near(water.Liters,100) && Near(illness.Contamination,40) && Near(illness.ToiletCapacity,20),"start reserves no resources and uses60 worldseconds");
        Check(!CaelumHygieneTask.Complete(u) && Near(water.Liters,100),"early completion cannot charge or cleanse");
        double step=CaelumThermalRuntime.WorldTicSeconds();u.UpdateCraftingTask();
        Check(Near(u.CraftingTaskRemainingSeconds,60-step),"ordinary task advances by actual world tic");
        Check(fixture.Used(u) && !CaelumHygieneTask.Active(u) && Near(water.Liters,100) && Near(illness.Contamination,40),"second Use cancels without spending");
        Check(fixture.Used(u),"restart after cancellation");
        u.SetOrigin(u.Pos+(-200,0,0),false);u.UpdateCraftingTask();
        Check(!CaelumHygieneTask.Active(u) && Near(water.Liters,100),"walking away cancels without spending");
        Aim(u,fixture);Check(fixture.Used(u),"restart on return");
        int ticks=int(Ceil(60/step-0.000001));for(int i=0;i<ticks;i++)u.UpdateCraftingTask();
        Console.Printf("CA502H completion active=%d remaining=%.12f C=%.12f capacity=%.12f water=%.12f ticks=%d",CaelumHygieneTask.Active(u),u.CraftingTaskRemainingSeconds,illness.Contamination,illness.ToiletCapacity,water.Liters,ticks);
        Check(!CaelumHygieneTask.Active(u) && Near(illness.Contamination,20) && Near(illness.ToiletCapacity,0) && Near(water.Liters,90),"completion spends10L and20 capacity exactly once");
        u.UpdateCraftingTask();u.CompleteCraftingTask();Check(Near(water.Liters,90) && Near(illness.Contamination,20),"repeated completion cannot duplicate effects");
        Reset(u,3.25,20);Check(fixture.Used(u),"fractional cleansing begins");u.CraftingTaskRemainingSeconds=0;u.CompleteCraftingTask();
        Check(Near(illness.Contamination,0) && Near(illness.ToiletCapacity,16.75) && Near(water.Liters,90),"only actual3.25 capacity spent; fixed10L");
        Check(!fixture.Used(u) && Near(water.Liters,90),"clean body cannot spend water");
        Reset(u,40,0);Check(!fixture.Used(u) && Near(water.Liters,100),"zero metabolic capacity blocks start");
        Reset(u);water.Liters=9.99;Check(!fixture.Used(u) && Near(water.Liters,9.99),"insufficient water blocks start atomically");
        water.Liters=10;Check(fixture.Used(u),"exact10L permits start");water.Liters=9;u.CraftingTaskRemainingSeconds=0;u.CompleteCraftingTask();
        Check(!CaelumHygieneTask.Active(u) && Near(water.Liters,9) && Near(illness.ToiletCapacity,20) && Near(illness.Contamination,40),"late shared water shortage spends nothing");
        Reset(u);fixture.Used(u);illness.Contamination=0;u.CraftingTaskRemainingSeconds=0;u.CompleteCraftingTask();
        Check(Near(water.Liters,100) && Near(illness.ToiletCapacity,20),"late cure spends no water or credit");
        Reset(u);fixture.Used(u);int beforeDisease=u.health;u.DamageMobj(null,null,1,'CaelumDiseaseDOT',DMG_NO_ARMOR,0);
        Check(CaelumHygieneTask.Active(u) && u.health<beforeDisease,"disease still removes Life without cancelling hygiene");
        u.DamageMobj(null,null,1,'Drowning',DMG_NO_ARMOR,0);
        Check(!CaelumHygieneTask.Active(u) && Near(water.Liters,100),"external damage cancels without spending");
        Reset(u);fixture.Used(u);u.CraftingTaskRemainingSeconds=0;let other=CaelumDomesticWater.Get(1);double otherLiters=other.Liters;u.CompleteCraftingTask();
        Check(Near(other.Liters,otherLiters),"other household reserve unchanged");
        Reset(u);fixture.Used(u);let task=CaelumHygieneTask.Find(u);task.OriginMap="CAH001";u.UpdateCraftingTask();
        Check(!CaelumHygieneTask.Active(u) && Near(water.Liters,100),"foreign-map session cancels on revalidation");
    }
    void Seed(CaelumPlayer u)
    {
        Reset(u);let fixture=Toilet(u);Check(fixture.Used(u),"saved task begins");
        for(int i=0;i<5;i++)u.UpdateCraftingTask();
        let proof=CA502HProof(u.FindInventory('CA502HProof'));if(proof==null)proof=CA502HProof(u.GiveInventoryType('CA502HProof'));
        proof.Reserve=CaelumDomesticWater.Get(fixture.House);proof.Water=proof.Reserve.Liters;proof.Stamp=proof.Reserve.Stamp;
        proof.Contamination=CaelumFoodIllness.Value(u);proof.Capacity=CaelumFoodIllness.Get(u).ToiletCapacity;proof.Remaining=u.CraftingTaskRemainingSeconds;
        Check(CaelumHygieneTask.Attended(u) && proof.Remaining>0,"partial session serializable");
    }
    void Load(CaelumPlayer u)
    {
        let proof=CA502HProof(u.FindInventory('CA502HProof'));Check(proof!=null,"saved proof restored");if(proof==null)return;
        let task=CaelumHygieneTask.Find(u);Check(task!=null && task.Revision==1 && task.Fixture==Toilet(u),"saved fixture identity restored");
        Check(CaelumHygieneTask.Attended(u) && u.CraftingTaskRemainingSeconds<=proof.Remaining && u.CraftingTaskRemainingSeconds>0,"saved partial duration retained");
        Check(Near(CaelumFoodIllness.Get(u).ToiletCapacity,proof.Capacity),"no capacity spent by save/load");
        u.CraftingTaskRemainingSeconds=0;u.CompleteCraftingTask();
        Check(!CaelumHygieneTask.Active(u) && Near(CaelumFoodIllness.Get(u).ToiletCapacity,0),"loaded task finishes once");
        let water=CaelumDomesticWater.Get(Toilet(u).House);
        Check(water==proof.Reserve && Near(water.Liters,proof.Water+(water.Stamp-proof.Stamp)/60-10),"saved reserve identity/refill and single payment");
    }
    void LiveBegin(CaelumPlayer u)
    {Seed(u);Console.Printf("CA502H live remaining=%f worldtic=%f",u.CraftingTaskRemainingSeconds,CaelumThermalRuntime.WorldTicSeconds());}
    void LiveEnd(CaelumPlayer u)
    {
        let proof=CA502HProof(u.FindInventory('CA502HProof'));let water=CaelumDomesticWater.Get(Toilet(u).House);
        Check(!CaelumHygieneTask.Active(u) && Near(CaelumFoodIllness.Get(u).ToiletCapacity,0),"real unpaused engine tics finish action");
        Check(Near(water.Liters,proof.Water+(water.Stamp-proof.Stamp)/60-10),"real world clock replenishment and10L debit agree");
    }
    void Forecast(CaelumPlayer u)
    {
        Reset(u,70,20);let fixture=Toilet(u);fixture.Used(u);
        for(Inventory item=u.Inv;item!=null;item=item.Inv)if(Powerup(item)!=null)Console.Printf("CA502H power %s",item.GetClassName());
        let thermal=CaelumThermalBody.Get(u);thermal.Exposure=0; // Aislar el adaptador de la exposición térmica, no modelada por la previsión.
        let model=new('CaelumTimeSkipModel');model.CaptureSkip(u,false);
        Console.Printf("CA502H climate=%d water=%d",model.ContaminationWeather.DynamicClimate,model.Contamination.DynamicWater);
        Console.Printf("CA502H forecast reason=%s toilet=%d active=%d",model.Reason,model.ToiletTask,CaelumHygieneTask.Active(u));
        Check(model.Reason.Length()==0 && model.ToiletTask,"hygiene captured in independent forecast");
        for(int i=0;i<1000 && !model.Done;i++)model.RunBatch();
        Check(model.Done && model.Reason.Length()==0 && !model.ToiletTask && Near(model.FoodIllness.ToiletCapacity,0),"forecast applies cleansing on completion");
        Check(Near(CaelumFoodIllness.Get(u).ToiletCapacity,20) && Near(CaelumDomesticWater.Get(fixture.House).Liters,100),"forecast leaves live credit and water untouched");
        CaelumHygieneTask.Cancel(u);
        Reset(u,40,1);u.CurrentHunger=90;u.DerivedStats.HealthRegenerationPerSecond=0;
        let food=CaelumRegenerationPower(u.GiveInventoryType('CaelumHungerRegeneration'));
        food.FoodRecoveryPerPulse=1;food.PulseTics=TICRATE-1;food.EffectTics=35;
        fixture.Used(u);u.CraftingTaskRemainingSeconds=CaelumThermalRuntime.WorldTicSeconds();thermal.Exposure=0;
        model=new('CaelumTimeSkipModel');model.CaptureSkip(u,false);model.RunBatch();
        CaelumTimeAdvanceState.SimulatePersonalTic(u);
        Check(model.ElapsedTics==1 && Near(model.FoodIllness.ToiletCapacity,CaelumFoodIllness.Get(u).ToiletCapacity)
            && Near(model.FoodIllness.Contamination,CaelumFoodIllness.Value(u)),"completion includes same-tic nutrition credit; native forecast parity");
        food.Destroy();
    }
    void Legacy(CaelumPlayer u)
    {
        let proof=CA502HProof(u.FindInventory('CA502HProof'));Check(proof!=null,"pre-feature proof loads");if(proof==null)return;
        let illness=CaelumFoodIllness.Get(u);let water=CaelumDomesticWater.Get(0);
        Check(!CaelumHygieneTask.Active(u) && CaelumHygieneTask.Find(u)==null,"old save creates no phantom session");
        Check(water==proof.Reserve && Near(water.Liters,proof.Water+(water.Stamp-proof.Stamp)/60),"old saved reserve identity and amount preserved");
        Check(Near(illness.ToiletCapacity,proof.Capacity) && illness.Contamination>33 && illness.Contamination<=33.5,"existing disease and metabolic capacity preserved");
        let fixture=Toilet(u);Aim(u,fixture);Check(fixture.Used(u),"old campaign can start new toilet action");
        u.CraftingTaskRemainingSeconds=0;u.CompleteCraftingTask();
        Check(Near(illness.ToiletCapacity,0),"old campaign spends only its original credit");
    }
    void Hub(CaelumPlayer u)
    {
        let proof=CA502HProof(u.FindInventory('CA502HProof'));Check(proof!=null,"proof travels between houses");if(proof==null)return;
        let water=CaelumDomesticWater.Get(0);let illness=CaelumFoodIllness.Get(u);
        Check(!CaelumHygieneTask.Active(u),"leaving the house cancels its pending session");
        Check(water==proof.Reserve && Near(water.Liters,proof.Water+(water.Stamp-proof.Stamp)/60),"map travel spends no toilet water");
        Check(Near(illness.ToiletCapacity,proof.Capacity),"map travel spends no metabolic credit");
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=='ca502h_core')Core(u);
        else if(e.Name=='ca502h_seed')Seed(u);
        else if(e.Name=='ca502h_load')Load(u);
        else if(e.Name=='ca502h_live_begin')LiveBegin(u);
        else if(e.Name=='ca502h_live_end')LiveEnd(u);
        else if(e.Name=='ca502h_forecast')Forecast(u);
        else if(e.Name=='ca502h_legacy')Legacy(u);
        else if(e.Name=='ca502h_hub')Hub(u);
        else if(e.Name=='ca502h_manual'){Reset(u);Console.Printf("CA502H manual: contamination40 capacity20 household100L; USE toilet, F1 reset, F6 console.");}
        else return;
        Console.Printf("CA502H RESULT passed=%d failures=%d",Passed,Failed);
    }
}
