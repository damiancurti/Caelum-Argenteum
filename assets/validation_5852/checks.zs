class CA416Checks : EventHandler
{
    int Passed,Failed;
    int VehicleProbe,VehicleTicks;
    bool ProbingVehicles;
    CaelumTravelVehicle ProbeVehicle;
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
    int Money(CaelumPlayer user)
    {
        int total=0;for(Inventory item=user.Inv;item!=null;item=item.Inv)
        {let coin=CaelumCurrencyItem(item);if(coin!=null)total+=coin.Amount*int(CaelumEconomyRules.GetCurrencyFaceValue(coin.GetCurrencyType()));}
        return total;
    }
    void Tickets(CaelumPlayer user,bool reload=false)
    {
        if(reload)
        {
            let booking=CaelumTransportBooking.Find(user);
            Check(booking!=null && booking.Ticket!=null,"native save restores the actual paid booking");if(booking==null || booking.Ticket==null)return;
            let ticket=booking.Ticket;
            Check(booking.Revision==2 && !booking.Onboard && !booking.TransferPending && !booking.ArrivalPending,"old ledger migrates to inactive travel revision two");
            Check(booking.StopMap==level.MapName,"old paid progress remains at its actual saved place");
            double stamp=ticket.Stamp;String savedStop=booking.StopMap;booking.Ensure(user);
            Check(ticket.Stamp==stamp && booking.StopMap==savedStop,"repeated migration changes no clock or location");
            Check(ticket.Route==18 && ticket.Mode==3 && ticket.Fare==9 && booking.Sequence==1,"contracted route mode fare and transaction sequence persist");
            Check(ticket.Status==ticket.STOPPED && Near(ticket.Elapsed,600) && Near(ticket.CoveredKm(),.5),"saved interrupted progress is retained");
            int money=Money(user);double now=ticket.Stamp+86400;
            Check(ticket.Resume(now),"saved ticket resumes after time spent ashore");ticket.Observe(now+600);
            Check(Near(ticket.Elapsed,1200) && Near(ticket.CoveredKm(),1) && Money(user)==money,"resume neither charges again nor credits the ashore day");
            return;
        }
        let ship=CaelumTransportTicket.Create(19,4,1,0,0);double sail=ship.Departure;
        ship.Observe(sail-1);Check(ship.Status==ship.WAITING && ship.Elapsed==0,"scheduled service does not move before departure");
        ship.Observe(sail+300);Check(ship.Status==ship.TRAVELLING && Near(ship.Elapsed,300),"departure charges only elapsed travel time");
        double firstPort=ship.StopAtSeconds;Check(!ship.RequestStop(sail+300,true,true,false) && ship.ExitRequested,"mid-sea request waits for an accessible port");
        ship.Observe(sail+firstPort+100);Check(ship.Status==ship.STOPPED && Near(ship.Elapsed,firstPort),"pending ship exit stops at Barracas without moving beyond the port");
        double progress=ship.CoveredKm();ship.Observe(sail+firstPort+86400);
        Check(Near(ship.CoveredKm(),progress) && ship.Resume(sail+firstPort+86400),"interruption preserves distance throughout a day ashore");
        ship.Observe(ship.Stamp+ship.StopSeconds);Check(Near(ship.CoveredKm(),progress),"intermediate dwell consumes time without distance");
        Check(!ship.RequestStop(ship.Stamp+1,true,true,false),"port geometry remains required for disembarkation");
        let train=CaelumTransportTicket.Create(19,6,1,0,0);train.Observe(train.Departure+300);
        Check(!train.RequestStop(train.Stamp,true,false,true),"moving train cannot be disembarked");
        Check(train.RequestStop(train.Stamp,true,true,false),"a stopped train with safe footing permits interruption");
        let horse=CaelumTransportTicket.Create(19,5,1,0,0);horse.Observe(9*3600);
        Check(Near(horse.CoveredKm(),64),"horse day retains eight moving hours and rest");
        Check(!horse.RequestStop(horse.Stamp,false,true,false),"land exit requires safe ground");
        Check(horse.RequestStop(horse.Stamp,true,true,false) && horse.Abandon(horse.Stamp),"safe land abandonment closes the contract");
        Check(!horse.Resume(horse.Stamp+1),"abandoned contract cannot be resumed");
        let ended=CaelumTransportTicket.Create(18,6,1,0,0);ended.Observe(ended.Departure+ended.DurationSeconds+100);
        Check(ended.Status==ended.COMPLETE && Near(ended.CoveredKm(),ended.DistanceKm),"arrival clamps progress to the actual destination");
        double stamp=ended.Stamp;ended.Observe(stamp-100);Check(ended.Stamp==stamp,"backward clock observation cannot replay progress");
        Check(CaelumTransportTicket.Create(0,6,1,0,0)==null,"invalid route cannot create a ticket");
        Check(!CaelumWorldCatalogue.IsSewerConnection(17) && CaelumWorldCatalogue.IsTravelConnection(17),"new routes do not create sewer gates");
        user.CharacterCreationComplete=true;user.CreationWizardOpen=false;user.MagicBoxOwned=true;
        let record=user.GetPersistentCharacterState(true);record.ProfileCommitted=true;
        user.SetOrigin((1216,768,0),false);user.Vel=(0,0,0);
        let cart=CaelumCoveredCart(Actor.Spawn('CaelumCoveredCart',user.Pos+(0,128,0),NO_REPLACE));
        cart.Ready=true;cart.BoardingPoint=user.Pos;
        let coin=CaelumCurrencyItem(Actor.Spawn('CaelumCopperCoin',user.Pos,NO_REPLACE));coin.Amount=1000;coin.AttachToOwner(user);user.OnNativeInventoryChanged();
        int before=Money(user);
        Check(CaelumTransportBooking.Buy(user,cart,18),"production booking pays from actual native coin ownership");
        let booking=CaelumTransportBooking.Find(user);
        if(booking==null || booking.Ticket==null){cart.Destroy();return;}
        Check(Money(user)==before-9,"approved complete ticket is debited exactly once");
        Check(!CaelumTransportBooking.Buy(user,cart,18) && Money(user)==before-9,"duplicate confirmation does not charge a second fare");
        let paid=booking.Ticket;paid.Observe(paid.Departure+600);
        Check(paid.RequestStop(paid.Stamp,true,true,false),"paid native booking retains an interrupted journey for save");
        cart.Destroy();
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
        if(id>=10)
        {
            user.bNoGravity=true;user.Vel=(0,0,0);
            if(id==10){user.SetOrigin((1416,640,0),false);user.Angle=180;user.Pitch=0;}
            if(id==11){user.SetOrigin((1100,640,32),false);user.Angle=143;user.Pitch=0;}
            if(id==12){user.SetOrigin((0,650,0),false);user.Angle=273;user.Pitch=0;}
            if(id==13)
            {let cart=CaelumCoveredCart(CaelumVehicleWorld.Find('CaelumCoveredCart'));if(cart!=null){user.SetOrigin(cart.BoardingPoint,false);CaelumTransportSession.Show(user,cart);}}
            return;
        }
        vector3 positions[]={(4544,-128,384),(1216,768,0),(4096,1024,0),(2688,2176,0)};
        double angles[]={145,0,0,180};double pitches[]={18,0,0,0};
        if(id<0 || id>=4)return;
        user.bNoGravity=true;user.bNoClip=true;user.Vel=(0,0,0);user.SetOrigin(positions[id],false);
        user.Angle=angles[id];user.Pitch=pitches[id];
    }
    void Trip(CaelumPlayer user,int phase)
    {
        if(phase==0)
        {
            user.CharacterCreationComplete=true;user.CreationWizardOpen=false;user.MagicBoxOwned=true;
            user.GetPersistentCharacterState(true).ProfileCommitted=true;
            let coin=CaelumCurrencyItem(Actor.Spawn('CaelumCopperCoin',user.Pos,NO_REPLACE));coin.Amount=10000;coin.AttachToOwner(user);user.OnNativeInventoryChanged();
            let cart=CaelumCoveredCart(CaelumVehicleWorld.Find('CaelumCoveredCart'));
            Check(cart!=null && cart.Ready,"production city has a ready cart");if(cart==null)return;
            user.SetOrigin(cart.BoardingPoint,false);user.Vel=(0,0,0);
            let memo=CA416Memo(user.GiveInventoryType('CA416Memo'));memo.Money=Money(user);memo.Hunger=user.CurrentHunger;
            Check(CaelumTransportSession.Show(user,cart),"using the real vehicle opens the destination panel");
            let s=CaelumTransportSession.Find(user);s.SelectedRoute=18;
            Check(CaelumTransportTrip.Begin(user,cart,18),"boarding commits native fare and requests transit map");
            Check(Money(user)==memo.Money-9,"boarding charged only the approved nine copper");
            return;
        }
        let b=CaelumTransportBooking.Find(user);let memo=CA416Memo(user.FindInventory('CA416Memo'));
        Check(b!=null && b.Ticket!=null && memo!=null,"native travel inventory survived the map boundary");
        if(b==null || b.Ticket==null || memo==null)return;
        if(phase==1)
        {
            Check(level.MapName=="CAT318" && CaelumTransportTrip.Aboard(user),"passenger arrived in the paid cart service");
            Check(CaelumWeatherState.Get(user).Profile==5,"transit uses real coastal weather");
            double before=b.Ticket.Elapsed;
            for(int i=0;i<105;i++)CaelumTimeAdvanceState.SimulatePersonalTic(user);
            Check(b.Ticket.Elapsed>before+59 && b.Ticket.CoveredKm()>0,"shared personal tics advance the actual trip");
            Check(user.CurrentHunger<memo.Hunger,"travelling spends actual survival resources");
            CaelumTransportTrip.RequestExit(user);
            Check(b.Ticket.Status==CaelumTransportTicket.STOPPED && b.StopMap=="CAR00","land exit selects a stable geographically keyed stop");
            memo.Progress=b.Ticket.Elapsed;return;
        }
        if(phase==2)
        {
            Check(level.MapName=="CAR00" && !b.Onboard,"interruption reaches playable rural terrain");
            Check(Near(b.Ticket.Elapsed,memo.Progress),"unboarded world time does not add distance");
            Check(CaelumCampLand.Allows(user,(0,512,0),64),"unowned stable countryside permits camp placement");
            Check(!CaelumCampLand.Allows(user,(0,0,0),64),"the road itself remains protected against camp blocking");
            Check(!CaelumCampLand.Allows(user,(0,256,0),64),"arrival and access area cannot be blocked by a camp");
            Check(Money(user)==memo.Money-9,"stopping never charges a second fare");return;
        }
        if(phase==3)
        {
            Check(level.MapName=="CAR00" && Near(b.Ticket.Elapsed,memo.Progress),"saved interrupted progress remains exact");
            Check(CaelumTransportTrip.Resume(user),"resume returns to the paid service");
            Check(Money(user)==memo.Money-9,"resume uses the original ticket without payment");return;
        }
        if(phase==4)
        {
            Check(CaelumTransportTrip.Aboard(user),"resumed service has a real active passenger");
            CaelumTransportTrip.Wait(user);
            Check(CaelumTimeSkipState.IsOpen(user),"travel offers the existing live calendar wait");
            Check(CaelumTimeSkipState.Start(user),"native time acceleration starts with actual resource rules");return;
        }
        if(phase==5)
        {
            Check(level.MapName=="MAP03" && b.Ticket.Status==CaelumTransportTicket.COMPLETE,"full paid trip arrives in Barracas");
            Check(!b.Onboard && !b.ArrivalPending && !b.TransferPending,"arrival commits once and releases the passenger");
            Check(Near(b.Ticket.CoveredKm(),b.Ticket.DistanceKm),"last simulated tic clamps distance at the destination");
            Check(!CaelumTimeSkipState.IsActive(user),"arrival terminates acceleration before further personal tics");
            Check(Money(user)==memo.Money-9,"complete native journey charged only once");
            let j=CaelumJourneyState.Get(user);
            Check(j.Status==CaelumJourneyState.STATUS_ARRIVED && j.ConnectionId==18 && j.HasArrivalTime,"journal records native departure and arrival dates");
        }
    }
    void PortStop(CaelumPlayer user,int phase)
    {
        if(phase==0)
        {
            user.CharacterCreationComplete=true;user.CreationWizardOpen=false;user.MagicBoxOwned=true;
            user.GetPersistentCharacterState(true).ProfileCommitted=true;
            let ship=CaelumMerchantShip(CaelumVehicleWorld.Find('CaelumMerchantShip'));
            user.SetOrigin(ship.BoardingPoint,false);user.Vel=(0,0,0);
            let coin=CaelumCurrencyItem(Actor.Spawn('CaelumCopperCoin',user.Pos,NO_REPLACE));coin.Amount=10000;coin.AttachToOwner(user);user.OnNativeInventoryChanged();
            double now=CaelumTransportBooking.Now(user),departure=CaelumTransportRules.NextDeparture(19,4,now,CaelumTransportBooking.Epoch());
            if(departure-now>120)CaelumWorldClock.Get(user).AdvanceTics(int((departure-now-120)*CaelumWorldClock.TicsPerHour()/3600));
            let memo=CA416Memo(user.GiveInventoryType('CA416Memo'));memo.Money=Money(user);
            Check(CaelumTransportTrip.Begin(user,ship,19),"through ship boards Buenos Aires to Mar del Plata");return;
        }
        let b=CaelumTransportBooking.Find(user);let memo=CA416Memo(user.FindInventory('CA416Memo'));
        Check(b!=null && b.Ticket!=null,"through ticket remains native inventory");if(b==null || b.Ticket==null)return;
        if(phase==1)
        {
            for(int i=0;i<350;i++)CaelumTimeAdvanceState.SimulatePersonalTic(user);
            Check(b.Ticket.Elapsed>0 && !b.Ticket.AtPort(),"ship has actually left port before the exit request");
            CaelumTransportTrip.RequestExit(user);
            Check(CaelumTransportTrip.Aboard(user) && b.Ticket.ExitRequested,"request does not disembark into open water");
            CaelumTransportTrip.Wait(user);Check(CaelumTimeSkipState.Start(user),"waiting towards the next real port uses native personal time");return;
        }
        Check(level.MapName=="MAP03" && b.Ticket.Status==CaelumTransportTicket.STOPPED,"ship disembarks at intermediate Barracas");
        Check(Near(b.Ticket.Elapsed,b.Ticket.StopAtSeconds),"exit boundary stops before the intermediate dwell or later sea leg");
        Check(b.StopMap=="MAP03" && !b.Onboard && !CaelumTimeSkipState.IsActive(user),"intermediate arrival releases the passenger and calendar wait");
        Check(Money(user)==memo.Money-CaelumTransportRules.Fare(19,4,1),"through ticket survives the intermediate exit without another charge");
    }
    void Vehicles(CaelumPlayer user)
    {
        VehicleProbe=VehicleTicks=0;ProbingVehicles=true;
    }
    override void WorldTick()
    {
        let traveler=CaelumPlayer(players[consoleplayer].mo);
        let longMemo=traveler==null?null:CA416Memo(traveler.FindInventory('CA416Memo'));
        if(longMemo!=null && longMemo.LongStarted>0)
        {
            let booking=CaelumTransportBooking.Find(traveler);
            let skip=CaelumTimeSkipState.Get(traveler);
            if(traveler.health<=0 || (skip!=null && !skip.Active && skip.LastReason!="CA_SKIP_COMPLETE" && CaelumTransportTrip.Aboard(traveler)))
            {
                let thermal=CaelumThermalBody.Get(traveler);let illness=CaelumFoodIllness.Get(traveler);
                Console.Printf("CA416 DIAG reason=%s life=%d hunger=%.3f thirst=%.3f sleep=%.3f air=%.3f contamination=%.3f thermal=%.3f elapsed=%.3f",
                    skip==null?"none":skip.LastReason,traveler.health,traveler.CurrentHunger,traveler.CurrentThirst,traveler.CurrentSleep,traveler.CurrentAir,
                    illness==null?0:illness.Contamination,thermal==null?0:thermal.Exposure,booking.Ticket.Elapsed);
                longMemo.LongStarted=0;Console.Printf("CA416 RESULT long passed=0 failed=1");return;
            }
            if(booking!=null && booking.Ticket!=null && booking.Ticket.Status==CaelumTransportTicket.COMPLETE && !booking.ArrivalPending)
            {
                Passed=Failed=0;Service(traveler,6,2,19);
                Console.Printf("CA416 TIMING long_trip_ms=%.3f elapsed_world=%.3f",MSTimeF()-longMemo.LongStarted,booking.Ticket.Elapsed);
                longMemo.LongStarted=0;
                Console.Printf("CA416 RESULT long passed=%d failed=%d",Passed,Failed);
            }
        }
        if(!ProbingVehicles)return;
        let user=CaelumPlayer(players[consoleplayer].mo);if(user==null)return;
        if(VehicleTicks==0)
        {
            class<CaelumTravelVehicle> kinds[]={'CaelumCoveredCart','CaelumMerchantShip','CaelumRidingHorse','CaelumSteamTrain'};
            ProbeVehicle=CaelumTravelVehicle(CaelumVehicleWorld.Find(kinds[VehicleProbe]));
            Check(ProbeVehicle!=null && ProbeVehicle.Ready,"production node installs each service once");
            if(ProbeVehicle!=null){user.SetOrigin(ProbeVehicle.BoardingPoint,false);user.Vel=(0,0,0);}
        }
        VehicleTicks++;
        if(VehicleTicks<35)return;
        if(ProbeVehicle!=null)
        {
            Check(Abs(user.Pos.Z-ProbeVehicle.BoardingPoint.Z)<1 && user.player.onground,
                String.Format("native player stands on actual approach mode=%d z=%.2f floor=%.2f",ProbeVehicle.TravelMode(),user.Pos.Z,user.FloorZ));
            Check(ProbeVehicle.CanBoard(user),String.Format("native sight and reach mode=%d distance=%.2f sight=%d",ProbeVehicle.TravelMode(),(user.Pos-ProbeVehicle.BoardingPoint).Length(),user.CheckSight(ProbeVehicle,SF_IGNOREVISIBILITY)));
        }
        VehicleProbe++;VehicleTicks=0;
        if(VehicleProbe>=4){ProbingVehicles=false;Console.Printf("CA416 RESULT passed=%d failed=%d",Passed,Failed);}
    }
    void Service(CaelumPlayer user,int mode,int phase,int route=18)
    {
        if(phase==0)
        {
            user.CharacterCreationComplete=true;user.CreationWizardOpen=false;user.MagicBoxOwned=true;
            user.GetPersistentCharacterState(true).ProfileCommitted=true;
            class<CaelumTravelVehicle> kinds[]={'CaelumCoveredCart','CaelumMerchantShip','CaelumRidingHorse','CaelumSteamTrain'};
            let vehicle=CaelumTravelVehicle(CaelumVehicleWorld.Find(kinds[mode-3]));
            Check(vehicle!=null && vehicle.Ready,"production service exists");if(vehicle==null)return;
            user.SetOrigin(vehicle.BoardingPoint,false);user.Vel=(0,0,0);
            let coin=CaelumCurrencyItem(Actor.Spawn('CaelumCopperCoin',user.Pos,NO_REPLACE));coin.Amount=10000;coin.AttachToOwner(user);user.OnNativeInventoryChanged();
            double now=CaelumTransportBooking.Now(user);
            double departure=CaelumTransportRules.NextDeparture(route,mode,now,CaelumTransportBooking.Epoch());
            // Preparar una campana situada dos minutos antes de la salida;
            // la espera y el trayecto siguientes usan fisiologia real.
            if(departure-now>120)CaelumWorldClock.Get(user).AdvanceTics(int((departure-now-120)*CaelumWorldClock.TicsPerHour()/3600));
            let memo=CA416Memo(user.GiveInventoryType('CA416Memo'));memo.Money=Money(user);memo.Hunger=user.CurrentHunger;
            if(route==19)
            {
                // Aislar doce horas de transporte de la enfermedad ya probada:
                // Dureza 100 usa la inmunidad aprobada; no se omiten sus tics,
                // contaminacion, consumo, inventario ni efectos climaticos.
                user.CharacterAllocation.AttributeBonus[CaelumConstants.ATTRIBUTE_TOUGHNESS]+=100-user.Attributes.Toughness;
                user.Attributes.Toughness=100;
                let food=CaelumConsumableItem(user.GiveInventoryType('CaelumFoodRation'));food.Amount=20;food.InMagicBox=false;
                let water=CaelumConsumableItem(user.GiveInventoryType('CaelumWaterRation'));water.Amount=80;water.InMagicBox=false;
                user.OnNativeInventoryChanged();
            }
            Check(CaelumTransportTrip.Begin(user,vehicle,route),"native vehicle boards its own mode");
            Check(Money(user)==memo.Money-CaelumTransportRules.Fare(route,mode,1),"each service charges its approved fare");
            return;
        }
        let b=CaelumTransportBooking.Find(user);let memo=CA416Memo(user.FindInventory('CA416Memo'));
        Check(b!=null && b.Ticket!=null && b.Ticket.Mode==mode,"mode and ticket survive hub travel");if(b==null || b.Ticket==null || memo==null)return;
        if(phase==1)
        {
            Check(CaelumTransportTrip.Aboard(user),"native transit map matches the service");
            if(mode==4 || mode==6)Check(b.Ticket.Status==CaelumTransportTicket.WAITING && b.Ticket.Elapsed==0,"passenger waits on the real departure clock");
            CaelumTransportTrip.Wait(user);Check(CaelumTimeSkipState.Start(user),"native wait starts without bypassing personal costs");
            if(route==19)
            {Check(user.Attributes.Toughness>=99.999,"long-route fixture retains its authored disease immunity across travel");memo.LongStarted=MSTimeF();}return;
        }
        Check(level.MapName==CaelumTransportData.Map(CaelumTransportData.Destination(route)) && b.Ticket.Status==CaelumTransportTicket.COMPLETE,"service reaches its real campaign destination");
        Check(!b.Onboard && !b.TransferPending && !b.ArrivalPending,"service finalizes its arrival exactly once");
        Check(Money(user)==memo.Money-CaelumTransportRules.Fare(route,mode,1),"no extra charge during calendar wait or arrival");
        let carriedFood=user.FindInventory('CaelumFoodRation');
        Check(user.CurrentHunger<memo.Hunger || (route==19 && (carriedFood==null || carriedFood.Amount<20)),"on-board waiting spends real Hunger, replenished only by actual carried food");
        if(route==19)
        {
            let food=user.FindInventory('CaelumFoodRation');let water=user.FindInventory('CaelumWaterRation');
            Check(food==null || food.Amount<20 || water==null || water.Amount<80,"long journey consumed actual carried provisions");
            Check(CaelumFoodIllness.Get(user).Contamination>0,"long journey retained exposure instead of freezing survival");
        }
    }
    void Cycle(CaelumPlayer user,int phase)
    {
        let b=CaelumTransportBooking.Find(user);let memo=CA416Memo(user.FindInventory('CA416Memo'));
        Check(b!=null && b.Ticket!=null && memo!=null,"cycle retains native booking and fixture marker");
        if(b==null || b.Ticket==null || memo==null)return;
        if(phase==0)
        {
            Check(level.MapName=="CAR00" && b.Ticket.Status==CaelumTransportTicket.STOPPED,"cycle begins from actual saved roadside interruption");
            let pile=CaelumCurrencyItem(Actor.Spawn('CaelumCopperCoin',(512,512,0),NO_REPLACE));pile.Amount=37;
            let access=CaelumVehicleWorld.Find('CaelumTransportAccess');
            Check(access!=null && CaelumTransportSession.Show(user,null,access),"roadside access opens the retained ticket");
            let session=CaelumTransportSession.Find(user);
            user.SetOrigin((512,-512,0),false);user.Vel=(0,0,0);
            Check(!session.Valid(user),"moving beyond actual service access invalidates its menu");
            user.SetOrigin(CaelumTransportSceneData.RuralEntry(),false);
            int money=Money(user);double progress=b.Ticket.Elapsed;
            Check(b.Ticket.Abandon(CaelumTransportBooking.Now(user)) && Money(user)==money,"abandonment does not refund paid coins");
            int fare=int(Ceil((b.Ticket.DistanceKm-b.Ticket.CoveredKm())*CaelumTransportData.FareRate(b.Ticket.Mode)));
            Check(CaelumTransportTrip.Rebook(user),"remaining route can be bought as a new paid contract");
            Check(Money(user)==money-fare && Near(b.Ticket.Elapsed,progress) && b.Sequence==2,"new contract charges remaining distance exactly once without moving ashore");
            memo.Money=Money(user);return;
        }
        if(phase==1)
        {Check(CaelumTransportTrip.Aboard(user),"paid remaining contract reaches native service");CaelumTransportTrip.Wait(user);Check(CaelumTimeSkipState.Start(user),"remaining journey uses the shared personal clock");return;}
        if(phase==2)
        {
            Check(level.MapName=="MAP03" && b.Ticket.Status==CaelumTransportTicket.COMPLETE,"remaining contract reaches its actual destination");
            Check(Money(user)==memo.Money,"remaining journey charges no arrival supplement");
            let cart=CaelumTravelVehicle(CaelumVehicleWorld.Find('CaelumCoveredCart'));
            Check(cart!=null && cart.Ready,"return route has actual port cart");if(cart==null)return;
            user.SetOrigin(cart.BoardingPoint,false);user.Vel=(0,0,0);
            Check(CaelumTransportTrip.Begin(user,cart,17),"reverse route boards through native port service");
            Check(Money(user)==memo.Money-9,"reverse contract pays its own approved fare");return;
        }
        if(phase==3)
        {
            Check(CaelumTransportTrip.Aboard(user),"reverse route reaches its own transit map");
            for(int i=0;i<105;i++)CaelumTimeAdvanceState.SimulatePersonalTic(user);
            CaelumTransportTrip.RequestExit(user);return;
        }
        Check(level.MapName=="CAR00" && b.Ticket.Status==CaelumTransportTicket.STOPPED,"opposite journeys return to the same fixed geographic roadside map");
        int piles=0;let iterator=ThinkerIterator.Create('CaelumCopperCoin');CaelumCurrencyItem coin;
        while((coin=CaelumCurrencyItem(iterator.Next()))!=null)
            if(coin.Owner==null && coin.Amount==37 && Abs(coin.Pos.X-512)<1 && Abs(coin.Pos.Y-512)<1)piles++;
        Check(piles==1,"native hub preserves the exact dropped pile without moving or duplicating belongings");
        Check(Money(user)==memo.Money-9,"returning to a roadside stop does not pick up distant belongings or recharge the ticket");
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let user=CaelumPlayer(players[consoleplayer].mo);
        if(e.Name=="ca416_camera"){Camera(user,e.Args[0]);return;}
        Passed=Failed=0;
        if(e.Name=="ca416_cycle"){Cycle(user,e.Args[0]);Console.Printf("CA416 RESULT phase=%d passed=%d failed=%d",e.Args[0],Passed,Failed);return;}
        if(e.Name=="ca416_portstop"){PortStop(user,e.Args[0]);Console.Printf("CA416 RESULT phase=%d passed=%d failed=%d",e.Args[0],Passed,Failed);return;}
        if(e.Name=="ca416_service"){Service(user,e.Args[0],e.Args[1],e.Args[2]>0?e.Args[2]:18);Console.Printf("CA416 RESULT mode=%d phase=%d passed=%d failed=%d",e.Args[0],e.Args[1],Passed,Failed);return;}
        if(e.Name=="ca416_vehicles"){Vehicles(user);return;}
        if(e.Name=="ca416_trip"){Trip(user,e.Args[0]);Console.Printf("CA416 RESULT phase=%d passed=%d failed=%d",e.Args[0],Passed,Failed);return;}
        if(e.Name=="ca416_catalogue")Catalogue();else if(e.Name=="ca416_city")City(user);else if(e.Name=="ca416_services")Services(user,e.Args[0]!=0);else if(e.Name=="ca416_tickets")Tickets(user,e.Args[0]!=0);else return;Console.Printf("CA416 RESULT passed=%d failed=%d",Passed,Failed);
    }
}

class CA416Memo : Inventory
{
    int Money;
    double Progress,Hunger,LongStarted;
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE}
    States {Spawn:TNT1 A -1;Stop;}
}
