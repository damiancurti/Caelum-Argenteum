class CA410WaterFurnitureChecks : EventHandler
{
    CaelumFountain Fountain;
    CaelumCistern Cistern;
    CaelumWaterContainer Bottle;
    int Passed,Failed;
    double SavedStamp;
    void Check(bool ok,String label){if(ok)Passed++;else Failed++;Console.Printf("CA410WF %s %s",ok?"PASS":"FAIL",label);}
    bool Near(double a,double b){return Abs(a-b)<0.000001;}
    void Profile(CaelumPlayer u)
    {
        u.CharacterCreationComplete=true;u.CreationWizardOpen=false;u.bInvulnerable=true;
        u.GetPersistentCharacterState(true).ProfileCommitted=true;
        u.GetPersistentCharacterState(true).SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_UNKNOWN_VOICE_HEARD);
        u.CombatTimeRemaining=0;u.CurrentHunger=100;u.CurrentThirst=100;u.CurrentSleep=100;
        u.DerivedStats.CarryCapacity=2000;u.Vel=(0,0,0);
    }
    void Find()
    {
        Fountain=CaelumFountain(ThinkerIterator.Create('CaelumFountain').Next());
        Cistern=CaelumCistern(ThinkerIterator.Create('CaelumCistern').Next());
    }
    void Position(CaelumPlayer u,CaelumWaterFurniture source)
    {
        u.SetOrigin(source.Pos+(0,-64,0),false);u.FindFloorCeiling();u.Vel=(0,0,0);
        u.Angle=90;u.Pitch=ATan2(u.ViewHeight-source.Height/2,64);u.player.camera=u;
        u.DerivedStats.CarryCapacity=2000;
    }
    CaelumWaterContainer Container(CaelumPlayer u)
    {
        let bottle=CaelumWaterContainer(Actor.Spawn('CaelumBottleSmall',u.Pos,NO_REPLACE));
        bottle.AttachToOwner(u);bottle.WaterLiters=0;return bottle;
    }
    void Mansion(CaelumPlayer u)
    {
        Profile(u);Find();Check(Fountain!=null && Cistern!=null,"normal mansion controller installs both sources");
        if(Fountain==null || Cistern==null)return;
        for(int kind=0;kind<2;kind++)
        {
            CaelumWaterFurniture source=Fountain;if(kind==1)source=Cistern;Position(u,source);
            Check(source.TestMobjLocation() && source.ClearOfActors(source) && Near(source.FloorZ,source.Pos.Z),"full source envelope fits actual garden");
            Check(u.TestMobjLocation() && source.CanReach(u),"ordinary player can stand at tap");
            Check(CaelumDomesticFixture.SourceFor(u)==source,"normal aimed local source lookup finds fixture");
            Check(source.Used(u),"native Use reports reserve and quality");
        }
        Check(CaelumMansionWaterFurniture.Prepare(),"repeated installation succeeds");
        int count=0;let it=ThinkerIterator.Create('CaelumWaterFurniture');while(it.Next()!=null)count++;
        Check(count==2,"installation does not duplicate sources");
        Check(CaelumMansionBathrooms.Prepare(),"existing mansion bathrooms retained");
        for(int id=101;id<=106;id++)Check(CaelumDiningWorld.Find(id)!=null,"accepted dining table retained");
        for(int id=101;id<=104;id++)Check(CaelumRestFurnitureTrial.Find(id)!=null,"accepted bedroom bed retained");
    }
    void Core(CaelumPlayer u)
    {
        Profile(u);Find();Check(Fountain!=null && Cistern!=null,"sources installed before checks");
        if(Fountain==null || Cistern==null)return;
        Fountain.SyncWater(u);Cistern.SyncWater(u);Bottle=Container(u);
        Check(Near(Fountain.AvailableWater(u),200) && Fountain.WaterSafe(u),"fountain begins with independent potable200L");
        Check(Near(Cistern.AvailableWater(u),0),"cistern begins empty without invented supply");
        Position(u,Fountain);Check(Bottle.FillFromSource(u),"normal refill action draws from fountain");
        Check(Near(Bottle.WaterLiters,1) && Near(Fountain.AvailableWater(u),199),"withdrawal conserves actual liters");
        Check(!Bottle.FillFromSource(u) && Near(Fountain.AvailableWater(u),199),"full container does not spend source water");
        Fountain.RefillStamp-=30;Fountain.SyncWater(u);Check(Near(Fountain.Reserve.WaterLiters,199.5),"30worldseconds replenish half liter");
        Fountain.RefillStamp-=600;Fountain.SyncWater(u);Check(Near(Fountain.Reserve.WaterLiters,200),"refill clamps to approved capacity");
        double now=Fountain.RefillStamp;Fountain.RefillStamp+=600;Fountain.Reserve.WaterLiters=199;
        Fountain.SyncWater(u);Check(Near(Fountain.Reserve.WaterLiters,199) && Near(Fountain.RefillStamp,now+600),"backward clock gives no water and keeps anchor");
        Fountain.RefillStamp=now;
        Position(u,Cistern);Bottle.WaterLiters=.5;Bottle.WaterQuality=CaelumWaterQuality.BIOLOGICAL|CaelumWaterQuality.SALT;
        Check(Cistern.Deposit(u,Bottle),"cistern accepts contaminated carried water");
        Check(Near(Cistern.Reserve.WaterLiters,.5) && Near(Bottle.WaterLiters,0) && Cistern.Reserve.WaterQuality==3,"deposit preserves volume and both quality flags");
        Bottle.AddWater(.5,CaelumWaterQuality.POTABLE,60,true);
        Check(Cistern.Deposit(u,Bottle) && Near(Cistern.Reserve.WaterLiters,1) && Cistern.Reserve.WaterQuality==3,"potable dilution never purifies existing contamination");
        Cistern.RefillStamp-=864000;Cistern.SyncWater(u);
        Check(Near(Cistern.Reserve.WaterLiters,1),"ten days never replenish cistern");
        Check(!CaelumBathTask.SourceValid(u,Cistern,null),"contaminated cistern refuses bathing");
        Check(Bottle.FillFromSource(u) && Near(Bottle.WaterLiters,1) && Bottle.WaterQuality==3,"refilling from cistern retains contaminated quality");
        Check(Near(Cistern.Reserve.WaterLiters,0) && Cistern.Reserve.WaterQuality==0,"fully drained reserve clears only absent water flags");
        Bottle.WaterLiters=1;Bottle.WaterQuality=0;Bottle.InMagicBox=true;
        Check(!Cistern.Deposit(u,Bottle) && Near(Bottle.WaterLiters,1),"Box water cannot be deposited");Bottle.InMagicBox=false;
        let foreign=CaelumWaterContainer(Actor.Spawn('CaelumBottleSmall',u.Pos,NO_REPLACE));foreign.WaterLiters=1;
        Check(!Cistern.Deposit(u,foreign),"unowned container cannot be deposited");foreign.Destroy();
        Cistern.Reserve.WaterLiters=999.75;Cistern.Reserve.WaterQuality=0;
        Check(Cistern.Deposit(u,Bottle) && Near(Cistern.Reserve.WaterLiters,1000) && Near(Bottle.WaterLiters,.75),"partial deposit stops at1000L and retains carried remainder");
        Check(!Cistern.Deposit(u,Bottle) && Near(Bottle.WaterLiters,.75),"full cistern rejects without losses");
        Bottle.WaterLiters=0;Cistern.Reserve.WaterLiters=.25;Cistern.Reserve.WaterQuality=CaelumWaterQuality.CHEMICAL;
        Check(Bottle.FillFromSource(u) && Near(Bottle.WaterLiters,.25) && Bottle.WaterQuality==CaelumWaterQuality.CHEMICAL,"nearly empty source yields only available water");
        Bottle.WaterLiters=0;Cistern.Reserve.WaterLiters=10;Cistern.Reserve.WaterQuality=0;
        Bottle.InMagicBox=true;Check(!Bottle.FillFromSource(u) && Near(Cistern.Reserve.WaterLiters,10),"Box container cannot collect");Bottle.InMagicBox=false;
        u.SetOrigin(u.Pos+(0,-300,0),false);Check(!Cistern.Fill(u,Bottle) && !Cistern.Deposit(u,Bottle),"distant source cannot transfer");
        Position(u,Cistern);u.DerivedStats.CarryCapacity=0;
        Check(!Cistern.Fill(u,Bottle) && Near(Cistern.Reserve.WaterLiters,10),"overweight refusal keeps source reserve intact");
        u.DerivedStats.CarryCapacity=2000;Position(u,Fountain);
        Check(!Fountain.Deposit(u,Bottle),"fountain is not a manual deposit target");
        Position(u,Cistern);Cistern.Reserve.WaterLiters=.5;Cistern.Reserve.WaterQuality=0;
        Cistern.Reserve.WaterTemperatureC=20;Cistern.Reserve.WaterTemperatureRevision=1;
        Cistern.Reserve.StampTemperature(u);Bottle.WaterLiters=.5;Bottle.WaterQuality=0;
        Bottle.WaterTemperatureC=80;Bottle.WaterTemperatureRevision=1;Bottle.StampTemperature(u);
        Check(Cistern.Deposit(u,Bottle) && Near(Cistern.Reserve.WaterTemperatureC,50),"manual transfer mixes temperature by actual water volume");
        Check(Cistern.Mass==int(Ceil(CaelumWaterFurnitureData.EmptyKg(1)+1)),"native source mass includes its actual stored liter");
        Check(Bottle.FillFromSource(u) && Near(Bottle.WaterTemperatureC,50),"collection preserves source water temperature");
        Check(Near(Cistern.Reserve.CoolWater(20,0,0),Cistern.Reserve.WaterTemperatureC),"zero thermal interval preserves temperature");
        Cistern.Reserve.WaterLiters=10;Cistern.Reserve.WaterTemperatureC=80;
        double cooled=Cistern.Reserve.CoolWater(20,0,3600);
        Check(cooled>20 && cooled<80,"approved iron properties cool reservoir toward ambient without overshoot");
        let home=CaelumDomesticWater.Get(CaelumDomesticWaterData.MANSION);double homeBefore=home.Liters;
        Fountain.SpendWater(u,5);Check(Near(home.Liters,homeBefore),"garden source does not debit domestic bath reserve");
    }
    void Bath(CaelumPlayer u)
    {
        Profile(u);Find();if(Cistern==null || Fountain==null){Check(false,"bath sources present");return;}
        Position(u,Cistern);Cistern.SyncWater(u);Cistern.Reserve.WaterLiters=10;Cistern.Reserve.WaterQuality=0;
        let illness=CaelumFoodIllness.Get(u);illness.Contamination=30;
        let soap=u.CreateDetachedMaterialStack(CaelumHygieneData.SOAP,1,100);soap.AttachToOwner(u);
        int buttons=u.player.cmd.buttons;u.player.cmd.buttons=BT_USE|BT_SPEED;
        Check(Cistern.Used(u) && CaelumBathSession.Find(u)!=null && CaelumBathSession.Find(u).Open,"Shift Use opens existing bath selector directly");
        u.player.cmd.buttons=buttons;if(CaelumBathSession.Find(u)!=null)CaelumBathSession.Find(u).Open=false;
        Check(CaelumBathTask.Begin(u,Cistern,null,2),"existing bath task starts at potable cistern");
        let model=new('CaelumTimeSkipModel');model.CaptureSkip(u,false);
        Check(model.BathDomestic && Near(model.BathCapacity,1000) && Near(model.BathRefill,0),"wait forecast uses1000L capacity and no invented refill");
        double before=Cistern.Reserve.WaterLiters;double water=CaelumContaminationRules.BathWaterLiters(1,u.DerivedStats.BaseMass);
        CaelumBathTask.Advance(u,10);
        Check(Near(Cistern.Reserve.WaterLiters,before-water) && Near(illness.Contamination,29),"one bath degree spends actual cistern water");
        Check(Near(CaelumBathTask.Find(u).SpentSoap,CaelumContaminationRules.SoapGrams(water)),"bath soap ratio unchanged");
        CaelumBathTask.Cancel(u);Check(Near(Cistern.Reserve.WaterLiters,before-water),"cancel retains partial bath debit without extra cost");
        Check(CaelumBathTask.Begin(u,Cistern,null,1),"bath can resume after partial cancellation");
        Cistern.Reserve.WaterQuality=CaelumWaterQuality.BIOLOGICAL;double contaminated=illness.Contamination;
        CaelumBathTask.Advance(u,10);
        Check(!CaelumBathTask.Active(u) && Near(illness.Contamination,contaminated),"source contamination during bath cancels before further cleaning");
        Position(u,Fountain);Fountain.SyncWater(u);
        Check(CaelumBathTask.Begin(u,Fountain,null,1),"fountain supports existing soap bath");
        model.CaptureSkip(u,false);Check(Near(model.BathCapacity,200) && Near(model.BathRefill,1),"fountain forecast uses approved refill");
        CaelumBathTask.Cancel(u);
        let bathrooms=CaelumMansionBathrooms.Find();Check(bathrooms!=null,"existing bathroom registry retained");
        if(bathrooms!=null && bathrooms.Fixtures[0]!=null)
        {
            let domestic=bathrooms.Fixtures[0];u.SetOrigin(domestic.Pos+(-48,0,0),false);u.FindFloorCeiling();
            Check(CaelumBathTask.Begin(u,domestic,null,1),"original domestic sink bath still starts");
            model.CaptureSkip(u,false);Check(Near(model.BathCapacity,200) && Near(model.BathRefill,1),"original domestic forecast unchanged");
            double available=domestic.AvailableWater(u);CaelumBathTask.Advance(u,10);
            Check(Near(domestic.AvailableWater(u),available-water),"original domestic bath spends household reserve");
            CaelumBathTask.Cancel(u);
        }
    }
    void Seed(CaelumPlayer u)
    {
        Profile(u);Find();Check(Fountain!=null && Cistern!=null,"save sources installed");if(Fountain==null || Cistern==null)return;
        Fountain.SyncWater(u);Cistern.SyncWater(u);
        Fountain.Reserve.WaterLiters=17;Cistern.Reserve.WaterLiters=15;Cistern.Reserve.WaterQuality=5;
        SavedStamp=Fountain.RefillStamp;Check(Cistern.Reserve.Owner==Cistern,"save preserves actual native reservoir owner");
    }
    void Resume(CaelumPlayer u)
    {
        Profile(u);Find();Check(Fountain!=null && Cistern!=null,"saved sources restored");if(Fountain==null || Cistern==null)return;
        Fountain.SyncWater(u);Cistern.SyncWater(u);
        Check(Near(Cistern.Reserve.WaterLiters,15) && Cistern.Reserve.WaterQuality==5,"save or hub retains actual volume and contamination");
        Check(Near(Fountain.Reserve.WaterLiters,Min(200,17+(Fountain.RefillStamp-SavedStamp)/60)),"fountain catches up elapsed refill exactly once");
        Check(Cistern.Reserve.Owner==Cistern && Fountain.Reserve.Owner==Fountain,"native owners retain their original reservoirs");
        double previous=Fountain.Reserve.WaterLiters;Fountain.SyncWater(u);Check(Near(previous,Fountain.Reserve.WaterLiters),"same time repeated read never refills twice");
    }
    void Legacy(CaelumPlayer u)
    {
        Profile(u);Find();Check(Fountain!=null && Cistern!=null,"old save receives new sources without replacing mansion geometry");
        if(Fountain==null || Cistern==null)return;
        Check(Near(Fountain.AvailableWater(u),200) && Near(Cistern.AvailableWater(u),0),"old save initializes only newly introduced reserves");
        let water=CaelumDomesticWater.Get(CaelumDomesticWaterData.MANSION);
        Check(Near(water.Liters,Min(200,73.123+(water.Stamp-SavedStamp)/60)),"old domestic reserve preserved with normal elapsed refill");
        Check(CaelumMansionBathrooms.Prepare() && ThinkerIterator.Create('CaelumWardrobe').Next()!=null,"old bathrooms and wardrobe preserved");
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=='ca410wf_profile'){Profile(u);return;}
        if(e.Name=='ca410wf_scan')
        {
            Profile(u);Console.Printf("CA410WF INSTALL %d",CaelumMansionWaterFurniture.Prepare());
            for(int x=512;x<=1024;x+=128)for(int y=-768;y>=-1152;y-=128)
            {vector3 p=(x,y,0);let probe=Actor.Spawn('CaelumRestPlacementProbe',p,NO_REPLACE);probe.A_SetSize(24,44,false);
             Console.Printf("CA410WF SITE %d %d fits=%d floor=%.1f ceiling=%.1f",x,y,probe.TestMobjLocation(),probe.FloorZ,probe.CeilingZ);probe.Destroy();}
        }
        if(e.Name=='ca410wf_core')Core(u);
        if(e.Name=='ca410wf_mansion')Mansion(u);
        if(e.Name=='ca410wf_bath')Bath(u);
        if(e.Name=='ca410wf_seed')Seed(u);
        if(e.Name=='ca410wf_resume')Resume(u);
        if(e.Name=='ca410wf_legacyresume')Legacy(u);
        if(e.Name=='ca410wf_locale')
        {
            Check(StringTable.Localize('CA_FURNITURE_FOUNTAIN',false)=="Fuente de agua","Spanish fountain title");
            Check(StringTable.Localize('CA_WATER_DEPOSIT_ACTION',false)=="Guardar","Spanish deposit button");
        }
        if(e.Name=='ca410wf_author')
        {
            Profile(u);Find();Check(Fountain!=null && Cistern!=null,"author sources ready");
            if(Fountain==null || Cistern==null)return;
            Bottle=Container(u);let pot=Actor.Spawn('CaelumCampPot',u.Pos,NO_REPLACE);Inventory(pot).AttachToOwner(u);
            let dirty=CaelumWaterContainer(Actor.Spawn('CaelumCanteenSmall',u.Pos,NO_REPLACE));dirty.AttachToOwner(u);
            dirty.AddWater(1,CaelumWaterQuality.BIOLOGICAL|CaelumWaterQuality.SALT,20,true);
            let soap=u.CreateDetachedMaterialStack(CaelumHygieneData.SOAP,1,100);soap.AttachToOwner(u);
            CaelumFoodIllness.Get(u).Contamination=30;u.OnNativeInventoryChanged();u.RefreshFormalInventorySnapshot();
            Position(u,Fountain);Console.Printf("CA410WF INPUT water-furniture ready");
        }
        if(e.Name=='ca410wf_select')
        {
            if(e.Args[0]!=0)Position(u,Cistern);
            u.RefreshFormalInventorySnapshot();
            for(int i=0;i<u.FormalInventoryEntryCount;i++)if(u.GetFormalInventoryEntryAt(i)==Bottle){u.FormalInventorySelectionIndex=i;break;}
            u.RefreshFormalInventorySnapshot();Check(u.GetFormalInventoryEntryAt(u.FormalInventorySelectionIndex)==Bottle,"ordinary inventory selects actual carried bottle");
        }
        if(e.Name=='ca410wf_verify_action')
        {
            if(e.Args[0]==0)Check(Near(Bottle.WaterLiters,1),"production network collect action fills selected bottle");
            else Check(Near(Bottle.WaterLiters,0) && Near(Cistern.AvailableWater(u),1),"production network deposit action transfers selected bottle");
        }
        if(e.Name=='ca410wf_away'){CaelumWorldClock.Get(u).AdvanceTics(CaelumWorldClock.TicsPerHour());Check(true,"one world hour advanced on another map");}
        if(e.Name=='ca410wf_view')
        {Profile(u);Find();if(Fountain!=null && Cistern!=null){CaelumWaterFurniture source=Fountain;if(e.Args[0]!=0)source=Cistern;Position(u,source);Console.Printf("CA410WF INPUT water sources ready");}}
        Console.Printf("CA410WF RESULT passed=%d failed=%d",Passed,Failed);
    }
}
