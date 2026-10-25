    void Soap(CaelumPlayer u,int grams)
    {
        let old=u.FindNativeSpecialItem(CaelumConstants.EQUIPMENT_KIND_MATERIAL,CaelumHygieneData.SOAP,1);if(old!=null)old.Destroy();
        let credit=CaelumSoapSupply.Find(u);if(credit!=null)credit.RemainderG=0;
        if(grams>0){let item=CaelumMaterialPickup(Actor.Spawn('CaelumMaterialPickup',u.Pos,NO_REPLACE));item.args[0]=CaelumHygieneData.SOAP;item.args[1]=1;item.Amount=grams;item.AttachToOwner(u);}
        u.RefreshCarriedInventorySummary();
    }
    void BathReset(CaelumPlayer u,double c=40,int grams=100)
    {
        CaelumBathTask.Cancel(u);CaelumHygienePose.End(u);Reset(u,c);u.DerivedStats.BaseMass=80;
        let menu=CaelumBathSession.Find(u);if(menu!=null)menu.Open=false;
        Soap(u,grams);Aim(u,Tub(u));
    }
    void BathCore(CaelumPlayer u)
    {
        BathReset(u);let tub=Tub(u);let water=CaelumDomesticWater.Get(tub.House);let illness=CaelumFoodIllness.Get(u);
        Check(Near(CaelumSoapSupply.Available(u),100),"real soap stock counted");
        double weight=u.DerivedStats.CarriedItemWeight;
        Check(CaelumSoapSupply.Spend(u,0.25) && u.CountCraftingMaterial(107,1)==99 && Near(CaelumSoapSupply.Credit(u),0.75),"quarter gram opens exactly one whole gram");
        u.RefreshCarriedInventorySummary();Check(Near(weight-u.DerivedStats.CarriedItemWeight,0.00025),"opened soap remainder retains its carried mass");
        Check(CaelumSoapSupply.Spend(u,0.5) && u.CountCraftingMaterial(107,1)==99 && Near(CaelumSoapSupply.Credit(u),0.25),"existing fraction spent before another gram");
        Check(!CaelumSoapSupply.Spend(u,101) && Near(CaelumSoapSupply.Available(u),99.25),"insufficient soap atomic");
        BathReset(u);Check(tub.Used(u),"accepted bathtub Use still reclines");
        Check(CaelumBathSession.Show(u),"soap menu opens from lying pose");let menu=CaelumBathSession.Find(u);
        Check(Near(menu.Maximum,40) && Near(menu.WaterCost,20) && Near(menu.SoapCost,100),"real bath menu previews approved80kg costs");
        menu.Selected=1;menu.Act(u,1);let bath=CaelumBathTask.Find(u);
        Check(CaelumBathTask.Attended(u) && CaelumHygienePose.Find(u).Lying && !menu.Open,"selection starts attended reclining bath");
        Check(Near(water.Liters,100) && Near(CaelumSoapSupply.Available(u),100) && Near(illness.Contamination,40),"bath start spends nothing");
        CaelumBathTask.Advance(u,2);
        Check(Near(illness.Contamination,39.8) && Near(water.Liters,99.9) && Near(CaelumSoapSupply.Available(u),99.5) && Near(bath.RemainingDegrees,0.8),"two world seconds cleanse0.2 spend0.1L and0.5g");
        Check(Near(CaelumSoapSupply.Credit(u),0.5),"progress preserves half gram");
        CaelumBathTask.Cancel(u);Check(!CaelumBathTask.Active(u) && !CaelumHygienePose.Active(u) && Near(water.Liters,99.9) && Near(CaelumSoapSupply.Available(u),99.5),"cancellation retains spent resources and fractional remainder");
        Aim(u,tub);Check(CaelumBathTask.Begin(u,tub,null,0.2),"partial restart");CaelumBathTask.Advance(u,2);
        Check(!CaelumBathTask.Active(u) && Near(illness.Contamination,39.6) && Near(CaelumSoapSupply.Credit(u),0) && u.CountCraftingMaterial(107,1)==99,"restart uses remaining half gram exactly once");
        double spent=water.Liters;u.CompleteCraftingTask();Check(Near(water.Liters,spent),"completion cannot double charge");
        BathReset(u);u.DerivedStats.BaseMass=160;Check(Near(CaelumBathTask.Affordable(u,tub,null),20),"160kg doubles per-degree resource costs");
        Check(CaelumBathTask.Begin(u,tub,null,1),"160kg bath begins");CaelumBathTask.Advance(u,10);
        Check(Near(water.Liters,99) && Near(CaelumSoapSupply.Available(u),95) && Near(illness.Contamination,39),"160kg uses1L5g per degree in10 seconds");
        BathReset(u,0);Check(!CaelumBathTask.Begin(u,tub,null,1) && Near(water.Liters,100),"clean body cannot spend resources");
        BathReset(u,40,0);Check(!CaelumBathTask.Begin(u,tub,null,1),"no soap blocks bath");
        BathReset(u);water.Liters=0.25;Check(Near(CaelumBathTask.Affordable(u,tub,null),0.5) && !CaelumBathTask.Begin(u,tub,null,1),"finite shared reserve bounds selection");
        BathReset(u);Check(CaelumBathTask.Begin(u,tub,null,2),"late shortage scenario starts");water.Liters=0.05;
        CaelumBathTask.Advance(u,2);Check(!CaelumBathTask.Active(u) && Near(illness.Contamination,39.9) && Near(water.Liters,0) && Near(CaelumSoapSupply.Available(u),99.75),"late water shortage retains only affordable progressive cleaning");
        BathReset(u);CaelumBathTask.Begin(u,tub,null,2);u.DamageMobj(null,null,1,'CaelumDiseaseDOT',DMG_NO_ARMOR,0);
        Check(CaelumBathTask.Active(u),"own disease continues without cancelling bath");u.DamageMobj(null,null,1,'Drowning',DMG_NO_ARMOR,0);
        Check(!CaelumBathTask.Active(u) && Near(water.Liters,100),"external damage cancels before new spending");
        BathReset(u);CaelumBathTask.Begin(u,tub,null,2);u.SetOrigin(u.Pos+(-200,0,0),false);u.UpdateCraftingTask();
        Check(!CaelumBathTask.Active(u) && Near(water.Liters,100),"leaving source cancels");
        BathReset(u);CaelumBathTask.Begin(u,tub,null,2);CaelumThermalBody.Get(u).Exposure=0;let projection=new('CaelumTimeSkipModel');projection.CaptureSkip(u,false);
        Check(!projection.Done && projection.BathTask && projection.Reason=="","independent bath forecast captures water and soap");
        for(int i=0;i<100 && !projection.Done;i++)projection.RunBatch();
        Check(projection.Done && !projection.BathTask && projection.Reason=="" && Near(projection.BathSoap,95),"forecast applies progressive soap cost");
        Check(Near(CaelumSoapSupply.Available(u),100) && Near(water.Liters,100) && Near(illness.Contamination,40),"forecast does not consume live resources");
        int forecastTicks=projection.ElapsedTics;for(int i=0;i<forecastTicks;i++)CaelumTimeAdvanceState.SimulatePersonalTic(u);
        Check(!CaelumBathTask.Active(u) && Near(illness.Contamination,projection.FoodIllness.Contamination)
            && Near(water.Liters,projection.BathWater) && Near(CaelumSoapSupply.Available(u),projection.BathSoap),"forecast and accelerated native time agree on contamination water soap");
        BathReset(u);CaelumBathTask.Begin(u,tub,null,2);
        Check(CaelumTimeAdvanceState.BlockReason(u,false)=="","ordinary accelerated live waiting remains available");
        double step=CaelumThermalRuntime.WorldTicSeconds();u.UpdateCraftingTask();Check(Near(bath.RemovedDegrees,step/10),"native task coordinator uses real world clock");
        CaelumBathTask.Cancel(u);
        BathReset(u,40,1);CaelumSoapSupply.Spend(u,0.8);Check(u.CountCraftingMaterial(107,1)==0 && Near(CaelumSoapSupply.Credit(u),0.2),"last whole gram can leave usable credit");
        Check(CaelumBathSession.Show(u) && CaelumBathSession.Find(u).Maximum>0,"bath menu remains usable with credit only");
        CaelumBathSession.Find(u).Act(u,0);
    }
    void BathSeed(CaelumPlayer u)
    {
        BathReset(u);let tub=Tub(u);CaelumBathTask.Begin(u,tub,null,10);CaelumBathTask.Advance(u,1);
        let proof=CA502BathProof(u.FindInventory('CA502BathProof'));if(proof==null)proof=CA502BathProof(u.GiveInventoryType('CA502BathProof'));
        proof.Credit=CaelumSoapSupply.Credit(u);proof.Soap=CaelumSoapSupply.Available(u);proof.C=CaelumFoodIllness.Value(u);
        proof.Remaining=CaelumBathTask.Find(u).RemainingDegrees;proof.Removed=CaelumBathTask.Find(u).RemovedDegrees;
        proof.Water=CaelumDomesticWater.Get(tub.House).Liters;proof.Stamp=CaelumDomesticWater.Get(tub.House).Stamp;
        Check(proof.Credit>0 && CaelumBathTask.Attended(u),"partial bath and fraction prepared for save");
    }
    void BathLoad(CaelumPlayer u,bool hub=false)
    {
        let proof=CA502BathProof(u.FindInventory('CA502BathProof'));Check(proof!=null,"bath save proof survives");if(proof==null)return;
        let bath=CaelumBathTask.Find(u);double extra=bath.RemovedDegrees-proof.Removed;
        Check(CaelumSoapSupply.Find(u).Revision==1 && CaelumSoapSupply.Credit(u)>=0 && CaelumSoapSupply.Credit(u)<1,"fractional soap revision and bounds survive save/hub");
        Check(Near(CaelumSoapSupply.Available(u),proof.Soap-extra*2.5),"saved soap total conserved across elapsed bath ticks");
        Check(Near(bath.RemainingDegrees,proof.Remaining-extra),"saved partial progress conserved");
        let water=CaelumDomesticWater.Get(0);Check(Near(water.Liters,proof.Water+(water.Stamp-proof.Stamp)/60-extra*0.5),"saved finite water accounting conserved");
        if(hub){Check(!CaelumBathTask.Active(u) && !CaelumHygienePose.Active(u),"map travel cancels bath and pose without refund");return;}
        Check(CaelumBathTask.Attended(u) && CaelumHygienePose.Find(u).Lying,"loaded bath resumes same reclining source");
        CaelumBathTask.Cancel(u);
    }
    void BathLiveBegin(CaelumPlayer u)
    {BathReset(u);CaelumBathTask.Begin(u,Tub(u),null,4);Check(CaelumBathTask.Attended(u),"unpaused bath begins");}
    void BathLiveEnd(CaelumPlayer u)
    {let bath=CaelumBathTask.Find(u);Check(!CaelumBathTask.Active(u) && Near(bath.RemovedDegrees,4) && Near(bath.SpentWater,2) && Near(bath.SpentSoap,10),"unpaused game clock completes exact bath costs");}
    void BathWaterSeed(CaelumPlayer u)
    {
        u.CombatTimeRemaining=0;u.Attributes.Toughness=100;u.ApplyCharacterProfile();u.health=u.CaelumMaximumHealth;u.player.health=u.health;
        u.DerivedStats.BaseMass=80;Soap(u,100);CaelumFoodIllness.Get(u).Contamination=40;
        let installation=CaelumConnectedWaterMap.Get();Check(installation!=null && installation.Water!=null,"campaign connected source exists");
        if(installation==null)return;installation.Water.QualityA=CaelumWaterQuality.POTABLE;
        u.SetOrigin((3736,92,-64),false);u.Vel=(0,0,0);
    }
    void BathWater(CaelumPlayer u)
    {
        let model=CaelumWaterQuality.Model(u);let installation=CaelumConnectedWaterMap.Get();
        Check(model!=null && u.WaterLevel>=3 && CaelumBathTask.SourceValid(u,null,model),"actual immersion identifies potable campaign source");
        if(model==null || installation==null)return;
        int index=installation.Index(model);double before=CaelumBathTask.WaterAvailable(u,null,model),soap=CaelumSoapSupply.Available(u);
        Check(!CaelumBathSession.Show(u) && u.HasActiveConversation(),"campaign arrival conversation blocks bath");
        if(u.player.ConversationNPC!=null)u.player.ConversationNPC.bInConversation=false;
        bool opened=CaelumBathSession.Show(u);
        Console.Printf("CA502H water index=%d opened=%d available=%d health=%d frozen=%d combat=%f conversation=%d task=%d sleeping=%d",index,opened,CaelumCampTask.Available(u),u.health,u.isFrozen(),u.CombatTimeRemaining,u.HasActiveConversation(),u.CraftingTaskActive,CaelumSleepRules.IsSleeping(u));
        Check(index>=0 && opened,"natural-source menu opens without furniture");if(!opened)return;
        CaelumBathSession.Find(u).Selected=1;CaelumBathSession.Find(u).Act(u,1);
        Check(CaelumBathTask.Attended(u) && !CaelumHygienePose.Active(u),"water bath starts without inventing furniture posture");
        CaelumBathTask.Advance(u,2);
        Console.Printf("CA502H water debit before=%.12f after=%.12f soapbefore=%.12f soapafter=%.12f mass=%f removed=%f active=%d",before,installation.Available(index),soap,CaelumSoapSupply.Available(u),u.DerivedStats.BaseMass,CaelumBathTask.Find(u).RemovedDegrees,CaelumBathTask.Active(u));
        double cost=CaelumContaminationRules.BathWaterLiters(0.2,u.DerivedStats.BaseMass);
        Check(Near(installation.Available(index),before-cost) && Near(CaelumSoapSupply.Available(u),soap-CaelumContaminationRules.SoapGrams(cost)),"connected water bath actually withdraws finite volume");
        installation.Water.QualityA=CaelumWaterQuality.BIOLOGICAL;u.UpdateCraftingTask();
        Check(!CaelumBathTask.Active(u) && Near(CaelumSoapSupply.Available(u),soap-CaelumContaminationRules.SoapGrams(cost)),"changed biological quality stops bath without new cost");
        installation.Water.QualityA=CaelumWaterQuality.SALT;Check(!CaelumBathTask.SourceValid(u,null,model),"salt-only water cannot supply soap bath");
        installation.Water.QualityA=CaelumWaterQuality.CHEMICAL;Check(!CaelumBathTask.SourceValid(u,null,model),"chemical water cannot supply soap bath");
    }
    void BathManual(CaelumPlayer u)
    {BathReset(u,40,100);Tub(u).Used(u);u.EquipmentMenuOpen=true;Console.Printf("CA502H manual: inventory H opens bath; choose points, Enter starts; move cancels; F1 resets, F2 opens bath, F6 console.");}
