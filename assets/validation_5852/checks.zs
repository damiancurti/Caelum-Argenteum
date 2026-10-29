class CA416Checks : EventHandler
{
    int Passed,Failed;
    void Check(bool value,String label)
    {if(value)Passed++;else Failed++;Console.Printf("CA416 %s %s",value?"PASS":"FAIL",label);}
    bool Near(double a,double b){return Abs(a-b)<.000001;}
    void Catalogue()
    {
        Check(!CaelumTransportRules.Route(0) && !CaelumTransportRules.Route(16),"legacy sewer/campaign identities remain outside the new network");
        Check(!CaelumTransportRules.Mode(1) && !CaelumTransportRules.Mode(2),"new transport catalogue accepts only the four approved vehicle types");
        Check(CaelumTransportData.Map(0)=="CABAIRES" && CaelumTransportData.Map(1)=="MAP03"
            && CaelumTransportData.Map(2)=="TCOAST","network retains the actual existing port/coast map identities");
        Check(Near(CaelumTransportRules.DistanceKm(19,6),402.336),"rail end-to-end distance converts the guidebook 250 miles");
        Check(Near(CaelumTransportRules.Hours(19,6),12),"derived rail running pace and intermediate stop total twelve hours");
        Check(Near(CaelumTransportRules.Hours(18,6)+CaelumTransportRules.Hours(10,6)+.25,12),"rail stop is counted once across the two segments");
        Check(Near(CaelumTransportRules.DistanceKm(17,6),3.6),"Barracas short rail segment retains its secondary-reference mileage");
        Check(CaelumTransportRules.Fare(19,6,1)==805 && CaelumTransportRules.Fare(19,6,2)==1610,
            "approved rail rate charges actual travelers with upward ticket rounding");
        Check(CaelumTransportRules.Fare(17,3,3)==25,"cart rounds the total party ticket instead of each member separately");
        Check(CaelumTransportRules.Fare(19,6,0)==0 && CaelumTransportRules.Fare(0,6,1)==0,"invalid route or empty party has no charge");
        for(int mode=3;mode<=6;mode++)
        {
            Check(Near(CaelumTransportRules.DistanceKm(10,mode),CaelumTransportRules.DistanceKm(11,mode)),"opposite route identities retain equal corridor length");
            Check(Near(CaelumTransportRules.DistanceKm(19,mode),CaelumTransportRules.DistanceKm(18,mode)+CaelumTransportRules.DistanceKm(10,mode)),"direct service follows the approved three-city chain");
            double hours=CaelumTransportRules.Hours(19,mode);
            Check(Near(CaelumTransportRules.MovingHours(19,mode,hours)*CaelumTransportData.SpeedKmh(mode),CaelumTransportRules.DistanceKm(19,mode)),"elapsed duration reaches exactly the paid destination");
            Check(Near(CaelumTransportRules.MovingHours(19,mode,hours+24),CaelumTransportRules.MovingHours(19,mode,hours)),"completed movement never overshoots its destination");
        }
        Check(Near(CaelumTransportRules.MovingHours(19,5,8),8)
            && Near(CaelumTransportRules.MovingHours(19,5,23.9),8)
            && Near(CaelumTransportRules.MovingHours(19,5,25),9),"horse rest intervals do not accumulate extra distance");
        Check(Near(CaelumTransportRules.MovingHours(19,3,24),8),"cart keeps the estimated twenty-four-kilometer working day");
        double firstLeg=CaelumTransportRules.Hours(18,6);
        Check(Near(CaelumTransportRules.MovingHours(19,6,firstLeg+.1),firstLeg),"train remains stationary during its Barracas stop");
        Check(CaelumTransportRules.NextDeparture(18,6,73800,0)==73800
            && CaelumTransportRules.NextDeparture(18,6,73801,0)==160200,"exact daily departure is catchable and the missed departure advances one day");
        Check(Near(CaelumTransportRules.NextDeparture(10,6,0,0),73800+(firstLeg+.25)*3600),"intermediate train departure follows terminal arrival plus its stop");
        Check(CaelumTransportRules.NextDeparture(19,4,28801,0)==28800+3*86400,"ship service follows its explicit estimated three-day timetable");
        Check(CaelumTransportRules.NextDeparture(10,3,12345,0)==12345
            && CaelumTransportRules.NextDeparture(10,5,12345,0)==12345,"cart and horse require no fixed departure schedule");
        Check(CaelumTransportRules.NextDeparture(0,6,12345,0)<0,"invalid service cannot create a timetable");
    }
    void City(CaelumPlayer user)
    {
        Check(level.MapName=="CABAIRES","new map loads under its own save-safe lump identity");
        vector2 doors[]={(896,512),(3968,512),(896,2240),(896,3008),(2176,2176),(2816,2176),(2176,2944),(2816,2944),(4352,2496)};
        let probe=CaelumRestPlacementProbe(Actor.Spawn('CaelumRestPlacementProbe',user.Pos,NO_REPLACE));
        probe.A_SetSize(user.Radius,user.Height);
        for(int i=0;i<9;i++)
        {
            vector2 door=doors[i];FCheckPosition fit;
            probe.SetOrigin((door.X-128,door.Y,0),false);
            Check(probe.CheckPosition(probe.Pos.XY,false,fit) && fit.floorz==0 && fit.ceilingz==(i==8?256:160),
                "full player cylinder fits the native interior below its solid roof");
            bool clear=true;
            for(int x=96;x>=-128;x-=16)
            {probe.SetOrigin((door.X+x,door.Y,0),false);if(!probe.CheckPosition(probe.Pos.XY,false,fit) || fit.floorz!=0)clear=false;}
            Check(clear,"service entrance connects actual street and interior without a step or collision obstruction");
        }
        vector2 routes[]={(1408,768),(2944,768),(1216,1600),(2944,1600),(4544,1600),(1216,3400),(2816,3400),(5632,1024)};
        for(int i=0;i<routes.Size();i++)
        {FCheckPosition fit;probe.SetOrigin((routes[i].X,routes[i].Y,0),false);
         Check(probe.CheckPosition(probe.Pos.XY,false,fit) && fit.floorz==0,"connecting street or pier retains dry, unobstructed player footing");}
        probe.Destroy();
    }
    void Services(CaelumPlayer user,bool reload=false)
    {
        let content=CaelumBuenosAiresContent.Find();
        Check(content!=null && content.Cursor==CaelumBuenosAiresData.COUNT,"all authored service slots installed");
        if(content==null)return;
        Check(CaelumWorldCatalogue.LocationForMap(level.MapName)==CaelumWorldCatalogue.LOCATION_BUENOS_AIRES
            && CaelumWeatherRules.ProfileForLocation(CaelumWorldCatalogue.LOCATION_BUENOS_AIRES)==CaelumWeatherRules.PROFILE_TEMPERATE_TRIAL,"city identity has coastal weather and normal calendar");
        Check(CaelumContaminationData.MapClass(level.MapName)==CaelumContaminationData.ENV_URBAN,"streets use approved urban contamination");
        Check(!CaelumCampLand.Allows(user,(1408,768,0),64),"urban streets do not grant camping permission");
        int merchants=0,stations=0,fixtures=0;bool shopIdentity=true,connected=true,water=true;
        CaelumCraftingStation first=null;
        for(int i=0;i<content.Services.Size();i++)
        {
            let body=content.Services[i];let merchant=CaelumCityMerchant(body);
            if(merchant!=null)
            {
                merchants++;shopIdentity=shopIdentity && CaelumCityMerchant.Find(merchant.ShopIdentity)==merchant;
                merchant.EnsureStock(user);
                Check(merchant.StockInitialized && merchant.Products.Size()>0,"merchant uses the production catalogue and actual inventory owner");
            }
            let station=CaelumCraftingStation(body);
            if(station!=null){stations++;if(first==null)first=station;}
            let fixture=CaelumDomesticFixture(body);
            if(fixture!=null && !(fixture is 'CaelumWaterFurniture'))
            {fixtures++;water=water && CaelumDomesticWater.InCurrentMap(fixture.House) && fixture.AvailableWater(user)>0;}
        }
        Check(merchants==8 && shopIdentity,"eight vendors retain disjoint identities beyond Barracas");
        Check(stations==14,"all fourteen existing workshop stations are present");
        if(first!=null)
        {
            int token=user.BeginCraftingNetworkScan();first.CollectCraftingNetwork(user,token);
            for(int i=0;i<content.Services.Size();i++)
            {let station=CaelumCraftingStation(content.Services[i]);if(station!=null)
                connected=connected && (user.CraftingNetworkCapabilities & CaelumCraftingRules.GetStationCapabilityBit(station.GetCraftingStationType()))!=0;}
        }
        Check(connected,"native proximity network reaches all stations including Chemistry and fermentation");
        Check(fixtures==12 && water,"four homes have three usable fixtures with independent water");
        let one=CaelumDomesticWater.Get(160);let two=CaelumDomesticWater.Get(161);
        Check(one!=null && two!=null && one!=two,"adjacent homes do not share one reservoir");
        if(one!=null && two!=null)
        {
            if(reload)Check(one.Liters<195 && two.Liters==200,"saved household withdrawal survives reload without refilling another home");
            else{double before=two.Liters;Check(one.Spend(10) && two.Liters==before,"spending household water only debits that house");}
        }
        let vendor=CaelumCityMerchant.Find(64);int cursor=content.Cursor;int size=content.Services.Size();
        if(!reload)vendor.WalletCopper=123;
        Check(CaelumBuenosAiresContent.Prepare() && content.Cursor==cursor && content.Services.Size()==size
            && CaelumCityMerchant.Find(64)==vendor && vendor.WalletCopper==123,"repeat installation/save reload preserves actual vendor money and service identities");
    }
    void Camera(CaelumPlayer user,int id)
    {
        vector3 positions[]={(4544,-128,384),(1216,768,0),(4096,1024,0),(2688,2176,0)};
        double angles[]={145,0,0,180};double pitches[]={18,0,0,0};
        if(id<0 || id>=4)return;
        user.bNoGravity=true;user.bNoClip=true;user.Vel=(0,0,0);user.SetOrigin(positions[id],false);
        user.Angle=angles[id];user.Pitch=pitches[id];
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let user=CaelumPlayer(players[consoleplayer].mo);
        if(e.Name=="ca416_camera"){Camera(user,e.Args[0]);return;}
        Passed=Failed=0;
        if(e.Name=="ca416_catalogue")Catalogue();else if(e.Name=="ca416_city")City(user);else if(e.Name=="ca416_services")Services(user,e.Args[0]!=0);else return;Console.Printf("CA416 RESULT passed=%d failed=%d",Passed,Failed);
    }
}
