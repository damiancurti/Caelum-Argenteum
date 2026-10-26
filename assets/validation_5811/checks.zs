class CA410BProof : Inventory
{
    double Water,Stamp,OtherWater,OtherStamp;
    CaelumDomesticWaterState Reserve;
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA410BChecks : EventHandler
{
    int Passed,Failed;
    void Check(bool ok,String label)
    {if(ok)Passed++;else Failed++;Console.Printf("CA410B %s %s",ok?"PASS":"FAIL",label);}
    bool Near(double a,double b){return Abs(a-b)<0.000001;}
    CaelumBathroomInstallation Room()
    {let it=ThinkerIterator.Create('CaelumBathroomInstallation');return CaelumBathroomInstallation(it.Next());}
    void Aim(CaelumPlayer u,CaelumDomesticFixture fixture)
    {
        bool west=fixture.Kind()!=0;
        u.SetOrigin(fixture.Pos+(west?-56:56,0,0),false);u.Vel=(0,0,0);u.Angle=west?0:180;
        u.Pitch=ATan2(u.ViewHeight-fixture.Height/2,56);
    }
    void Core()
    {
        let water=new('CaelumDomesticWaterState');
        Check(water.Withdraw(10)==0 && !water.Spend(10),"uninitialized reserve cannot provide water");
        water.Sync(1000);Check(water.Revision==1 && water.Liters==200,"new household starts with200L");
        Check(water.Withdraw(0.125)==0.125 && water.Liters==199.875,"fractional withdrawal exact");
        water.Sync(1000);Check(water.Liters==199.875,"repeated initialization does not refill");
        water.Sync(1030);Check(water.Liters==200,"refill respects200L cap");
        Check(water.Spend(150) && water.Liters==50,"atomic complete spend");
        Check(!water.Spend(51) && water.Liters==50,"insufficient full payment leaves reserve unchanged");
        Check(!water.Spend(0) && !water.Spend(-1) && water.Withdraw(-5)==0 && water.Liters==50,"nonpositive requests rejected");
        water.Sync(1150);Check(water.Liters==52,"two worldminutes restore2L");
        water.Sync(1100);Check(water.Stamp==1150 && water.Liters==52,"backward clock cannot gift water");
        Check(water.Withdraw(100)==52 && water.Liters==0,"partial withdrawal cannot overdraw");
        water.Sync(1165);Check(water.Liters==0.25,"quarterminute restores250mL");
        water.Sync(100000);Check(water.Liters==200,"long absence caps at capacity");
        Check(CaelumDomesticWater.Get(-1)==null && CaelumDomesticWater.Get(160)==null,"invalid house IDs rejected");
    }
    void House(CaelumPlayer u)
    {
        int house=CaelumHouseHubData.HouseForMap(level.MapName);
        Check(house>=0 && CaelumBathroomInstallation.Prepare(house),"production house installation ready");
        let room=Room();Check(room!=null && room.Revision==1,"one revisioned installation");if(room==null)return;
        for(int kind=0;kind<3;kind++)
        {
            let fixture=room.Fixtures[kind];Check(fixture!=null,"fixture exists");if(fixture==null)continue;
            Check(fixture.House==house && fixture.Kind()==kind && fixture.Pos==CaelumCityData.HouseOrigin(house)+CaelumDomesticFixtureData.Offset(kind),"fixture identity and approved placement");
            Check(fixture.TestMobjLocation(),"fixture fits actual map collision");
            Aim(u,fixture);Check(u.TestMobjLocation(),"player can approach fixture");
            Check(CaelumUseGeometry.AimedAt(u,fixture),"fixture aim resolves at reachable height");
            Check(fixture.CanReach(u)==CaelumPropertyRules.ResidenceAllowed(u),"fixture obeys residence permission");
        }
        vector3 doorway=CaelumCityData.HouseOrigin(house)+(192,864,0);bool doorwayClear=true;
        for(int i=0;i<3;i++)if(room.Fixtures[i]!=null && (room.Fixtures[i].Pos-doorway).Length()<room.Fixtures[i].Radius+u.Radius)doorwayClear=false;
        Check(doorwayClear,"fixtures leave existing bathroom doorway clear");
        CaelumBathroomInstallation.Prepare(house);let it=ThinkerIterator.Create('CaelumBathroomInstallation');int count=0;while(it.Next()!=null)count++;
        Check(count==1 && Room()==room,"repeated preparation retains one installation");
        let actors=ThinkerIterator.Create('CaelumDomesticFixture');count=0;while(actors.Next()!=null)count++;
        Check(count==3,"exactly three fixed fixtures without duplicates");
    }
    void Fill(CaelumPlayer u)
    {
        let room=Room();Check(room!=null && room.Fixtures[0]!=null && room.Fixtures[1]!=null,"real sink and bathtub available");if(room==null)return;
        let sink=room.Fixtures[0];let tub=room.Fixtures[1];let reserve=CaelumDomesticWater.Get(sink.House);
        let other=CaelumDomesticWater.Get((sink.House+1)%160);double otherBefore=other.Liters;
        let bottle=CaelumWaterContainer(u.GiveInventoryType('CaelumBottleNormal'));bottle.InMagicBox=false;bottle.WaterLiters=0;bottle.WaterQuality=0;
        u.DerivedStats.CarryCapacity=1000;u.DerivedStats.CarriedWeight=0;
        Aim(u,sink);Check(CaelumDomesticFixture.SourceFor(u)==sink && sink.Used(u),"aimed source and Use notification work");
        double before=reserve.Liters;
        Check(bottle.FillFromSource(u) && bottle.WaterLiters==2.5 && bottle.IsPotable() && Near(reserve.Liters,before-2.5),"inventory collection withdraws real potable volume");
        Check(!bottle.FillFromSource(u) && Near(reserve.Liters,before-2.5),"full container cannot spend reserve");
        bottle.WaterLiters=0;Aim(u,tub);before=reserve.Liters;
        Check(bottle.FillFromSource(u) && Near(reserve.Liters,before-2.5),"bathtub shares sink reserve");
        Check(other.Liters==otherBefore && other!=reserve,"another household remains independent");
        bottle.WaterLiters=0;reserve.Liters=0.125;
        Check(bottle.FillFromSource(u) && bottle.WaterLiters==0.125 && reserve.Liters==0,"nearly empty reserve supplies partial fill");
        Check(!bottle.FillFromSource(u) && reserve.Liters==0,"empty reserve cannot duplicate water");
        reserve.Liters=10;bottle.WaterLiters=0;bottle.InMagicBox=true;
        Check(!bottle.FillFromSource(u) && reserve.Liters==10,"Box-contained recipient cannot collect");bottle.InMagicBox=false;
        u.Angle=180;Check(CaelumDomesticFixture.SourceFor(u)==null && !bottle.FillFromSource(u) && reserve.Liters==10,"looking away cannot collect from fixture");
        Aim(u,tub);u.DerivedStats.CarryCapacity=0;
        Check(!bottle.FillFromSource(u) && reserve.Liters==10 && bottle.WaterLiters==0,"overweight rejection preserves reserve and container");u.DerivedStats.CarryCapacity=1000;
        let brew=CaelumWaterBoilingState(u.GiveInventoryType('CaelumWaterBoilingState'));brew.Container=bottle;
        u.CraftingTaskActive=true;u.CraftingTaskKind=CaelumConstants.CRAFTING_TASK_BOIL;
        Check(!bottle.FillFromSource(u) && reserve.Liters==10,"reserved boiling recipient cannot steal water");
        u.CraftingTaskActive=false;brew.Container=null;
        bottle.WaterLiters=1;bottle.WaterQuality=CaelumWaterQuality.BIOLOGICAL;
        Check(bottle.FillFromSource(u) && !bottle.IsPotable() && bottle.WaterQuality==CaelumWaterQuality.BIOLOGICAL,"potable refill never purifies existing contamination");
        before=reserve.Liters;u.SetOrigin(CaelumCityData.HouseOrigin(sink.House)+(192,640,0),false);
        Check(!sink.Fill(u,bottle) && reserve.Liters==before,"distance and wall reject direct source request");
        let clock=CaelumWorldClock.Get(u,true);double start=reserve.Liters;
        clock.DayTics+=CaelumWorldClock.TicsPerHour();
        Check(Near(CaelumDomesticWater.Get(sink.House).Liters,Min(200,start+60)),"production calendar advances lazy household refill");
    }
    void Seed(CaelumPlayer u)
    {
        let reserve=CaelumDomesticWater.Get(0);reserve.Liters=77.125;
        let other=CaelumDomesticWater.Get(1);other.Liters=33.25;
        let proof=CA410BProof(u.GiveInventoryType('CA410BProof'));
        proof.Reserve=reserve;proof.Water=reserve.Liters;proof.Stamp=reserve.Stamp;proof.OtherWater=other.Liters;proof.OtherStamp=other.Stamp;
        Check(true,"seed independent household reserves and travelling identity");
    }
    void Verify(CaelumPlayer u)
    {
        let proof=CA410BProof(u.FindInventory('CA410BProof'));Check(proof!=null,"travelling proof retained");if(proof==null)return;
        let reserve=CaelumDomesticWater.Get(0);let other=CaelumDomesticWater.Get(1);
        Check(reserve==proof.Reserve,"saved shared water identity retained");
        Check(Near(reserve.Liters,Min(200,proof.Water+(reserve.Stamp-proof.Stamp)/60)),"save or map absence adds only elapsed refill");
        Check(Near(other.Liters,Min(200,proof.OtherWater+(other.Stamp-proof.OtherStamp)/60)),"second household keeps independent saved amount");
    }
    void Retry(CaelumPlayer u)
    {
        int house=CaelumHouseHubData.HouseForMap(level.MapName);let room=Room();
        let water=CaelumDomesticWater.Get(house);water.Liters=99.125;
        let retained=room.Fixtures[1];vector3 point=room.Fixtures[0].Pos;
        room.Fixtures[0].Destroy();room.Fixtures[0]=null;
        let blocker=Actor.Spawn('CaelumDomesticSink',point,NO_REPLACE);
        blocker.A_SetSize(32,32);
        Check(!CaelumBathroomInstallation.Prepare(house) && room.Fixtures[0]==null,"occupied fixture footprint postpones installation");
        Check(room.Fixtures[1]==retained && water.Liters==99.125,"retry preserves other furniture and water");
        blocker.Destroy();Check(CaelumBathroomInstallation.Prepare(house) && room.Fixtures[0]!=null,"freed footprint installs missing fixture");
        Check(water.Liters==99.125,"successful retry never replenishes reserve");
        double total=0,worst=0;int count=0;let it=ThinkerIterator.Create('Actor');while(it.Next()!=null)count++;
        for(int i=0;i<1000;i++)
        {double start=MSTimeF();CaelumBathroomInstallation.Prepare(house);double elapsed=MSTimeF()-start;total+=elapsed;worst=Max(worst,elapsed);}
        Console.Printf("CA410B TIMING ready-prepare calls=1000 actors=%d mean_ms=%.6f worst_ms=%.6f",count,total/1000,worst);
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Player<0 || e.Player>=MAXPLAYERS)return;let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=='ca410b_core')Core();
        else if(e.Name=='ca410b_house')House(u);
        else if(e.Name=='ca410b_fill')Fill(u);
        else if(e.Name=='ca410b_seed')Seed(u);
        else if(e.Name=='ca410b_verify')Verify(u);
        else if(e.Name=='ca410b_retry')Retry(u);
        else if(e.Name=='ca410b_view')
        {u.SetOrigin(CaelumCityData.HouseOrigin(CaelumHouseHubData.HouseForMap(level.MapName))+(192,948,0),false);u.Angle=65;u.Pitch=20;u.Vel=(0,0,0);Check(true,"manual bathroom viewpoint");}
        else if(e.Name=='ca410b_close')
        {let room=Room();if(room!=null){Aim(u,room.Fixtures[Clamp(e.Args[0],0,2)]);Check(true,"close fixture viewpoint");}}
        else if(e.Name=='ca410b_manual')
        {
            let bottle=CaelumWaterContainer(u.FindInventory('CaelumBottleNormal'));
            if(bottle==null)bottle=CaelumWaterContainer(u.GiveInventoryType('CaelumBottleNormal'));
            bottle.InMagicBox=false;bottle.EmptyWater(u);
            let room=Room();if(room!=null)Aim(u,room.Fixtures[0]);
            Check(true,"empty test bottle prepared without altering household water");
        }
        else if(e.Name=='ca410b_legacy')
        {
            let bottle=CaelumWaterContainer(u.FindInventory('CaelumBottleNormal'));
            Check(bottle!=null && bottle.WaterLiters==0.75 && bottle.WaterQuality==3,"legacy inventory retains water volume and contamination");
            Check(Room()!=null && CaelumDomesticWater.Get(0).Liters==200,"legacy house installs fixtures and initializes new reserve");
            House(u);let water=CaelumDomesticWater.Get(0);water.Withdraw(17.5);
            CaelumBathroomInstallation.Prepare(0);Check(CaelumDomesticWater.Get(0).Liters==182.5,"legacy installation retry never resets water");
        }
        else return;
        Console.Printf("CA410B RESULT passes=%d failures=%d",Passed,Failed);
    }
}
