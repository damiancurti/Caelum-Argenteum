// Native shared-vehicle/fare checks with disposable inventories and geometry.
class CA436TransportLedger : Inventory
{
    double Money,Hunger;
    int Fare;
    bool ResumeRequested;
    double StoppedAt;
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA436ClockProbe : EventHandler
{
    const STOP_EARLY = 0;
    const TRAVEL_MODE = 3;
    int Phase,TotalRequests,EntryTic;
    override void WorldLoaded(WorldEvent e){EntryTic=level.time;}
    ui bool Sent;
    ui int VoteSent,TimeSent;
    void Check(bool okay,String label){Console.Printf("CA436 %s %s",okay?"PASS":"FAIL",label);}
    override void UiTick()
    {
        if(gamestate!=GS_LEVEL || consoleplayer<0)return;
        let user=CaelumPlayer(players[consoleplayer].mo);
        if(!Sent && level.time>=TICRATE && user!=null)
        {Sent=true;SendNetworkEvent("ca436_native_probe",consoleplayer);}
        let travel=CaelumCooperativeTravel.View(user);let time=CaelumCooperativeTime.View(user);
        if((Phase==1 || Phase==4) && travel!=null && travel.Opened && VoteSent!=travel.Serial)
        {VoteSent=travel.Serial;SendNetworkEvent("ca_cooperative_travel",CaelumCooperativeTravel.ACCEPT,travel.Serial);}
        if(Phase==2 && time!=null && time.Opened && !time.Running && TimeSent!=time.Serial)
        {TimeSent=time.Serial;SendNetworkEvent("ca_cooperative_time",CaelumCooperativeTime.ACCEPT,time.Serial);}
        if(Phase==3 && consoleplayer==1 && travel!=null && travel.Opened && VoteSent!=travel.Serial)
        {VoteSent=travel.Serial;SendNetworkEvent("ca_cooperative_travel",CaelumCooperativeTravel.CANCEL,travel.Serial);}
    }
    override void NetworkProcess(ConsoleEvent e)
    {if(e.Name=="ca436_native_probe")Console.Printf("CA436 EVENT peer=%d sender=%d serial=%d",consoleplayer,e.Player,++TotalRequests);}
    CaelumCurrencyItem Money(CaelumPlayer user,int amount)
    {
        for(Inventory item=user.Inv;item!=null;)
        {Inventory next=item.Inv;if(item is 'CaelumCurrencyItem')item.Destroy();item=next;}
        let coin=CaelumCurrencyItem(user.GiveInventoryType('CaelumCopperCoin'));
        coin.Amount=amount;user.OnNativeInventoryChanged();return coin;
    }
    override void WorldTick()
    {
        if(Phase==5 || level.time-EntryTic<TICRATE*3)return;
        let a=CaelumPlayer(players[0].mo);let b=CaelumPlayer(players[1].mo);
        if(!CaelumWorldClockTicker.Ready(a) || !CaelumWorldClockTicker.Ready(b))return;
        if(level.MapName=="MAP03" && Phase==0)
        {
            int last=0;for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])
            {
                last=i;let user=CaelumPlayer(players[i].mo);Money(user,200);
                user.SetOrigin((i%4*48-72,i/4*48,0),false);user.Vel=(0,0,0);
            }
            Name vehicleClass=TRAVEL_MODE==4?'CaelumMerchantShip':TRAVEL_MODE==5?'CaelumRidingHorse':TRAVEL_MODE==6?'CaelumSteamTrain':'CaelumTravelVehicle';
            let vehicle=CaelumTravelVehicle(Actor.Spawn(vehicleClass,(0,500,0),NO_REPLACE));
            vehicle.Prepare();
            vector3 boarding=vehicle.BoardingPoint;boarding.Z=0;
            for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])
                players[i].mo.SetOrigin(boarding+(i%4*40-60,-48-i/4*40,0),false);
            if(TRAVEL_MODE==4 || TRAVEL_MODE==6)
            {
                double now=CaelumTransportBooking.Now(a);
                let schedule=CaelumTransportTicket.Create(17,TRAVEL_MODE,1,now,CaelumTransportBooking.Epoch());
                int advance=int(Max(0,schedule.Departure-now-120)*CaelumWorldClock.TicsPerHour()/3600);
                CaelumWorldClock.Get(a).AdvanceTics(advance);CaelumWorldClockTicker.Mirror(a);
            }
            let poorest=CaelumPlayer(players[last].mo);Money(poorest,0);
            Check(!CaelumTransportTrip.Begin(a,vehicle,17),"insufficient fare in one inventory blocks group booking");
            Check(a.GetOwnedMoneyCopperValue()==200 && poorest.GetOwnedMoneyCopperValue()==0,"failed booking charges nobody");
            Money(poorest,200);
            Check(CaelumTransportTrip.Begin(a,vehicle,17),"ordinary vehicle action opens shared fare proposal");
            let vote=CaelumCooperativeTravel.View(a);int fare=CaelumTransportRules.Fare(17,TRAVEL_MODE,1);
            Check(vote!=null && vote.Fare==fare && vote.Destination==CaelumTransportSceneData.Stage(17,TRAVEL_MODE),"proposal quotes individual fare and exact vehicle route");
            Check(!CaelumTransportBooking.Buy(a,vehicle,17),"old solo payment cannot bypass group consent");
            Check(a.GetOwnedMoneyCopperValue()==200,"opening proposal spends no money");
            Money(poorest,0);int serial=vote.Serial;
            for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])vote.Request(CaelumPlayer(players[i].mo),CaelumCooperativeTravel.ACCEPT,serial);
            Check(!vote.Opened && !vote.Committed,"lost funds invalidate final confirmation");
            Check(a.GetOwnedMoneyCopperValue()==200,"one failed payment leaves another wallet untouched");
            Money(poorest,200);
            Check(CaelumTransportTrip.Begin(a,vehicle,17),"booking can be proposed again after resources recover");
            vote=CaelumCooperativeTravel.View(a);
            Check(vote.Request(b,CaelumCooperativeTravel.CANCEL,vote.Serial),"any traveler can reject boarding");
            Check(a.GetOwnedMoneyCopperValue()==200 && b.GetOwnedMoneyCopperValue()==200,"boarding rejection charges neither player");
            Check(CaelumTransportTrip.Begin(a,vehicle,17),"final boarding offer awaits real native consent");
            for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])
            {
                let user=CaelumPlayer(players[i].mo);let ledger=CA436TransportLedger(user.GiveInventoryType('CA436TransportLedger'));
                ledger.Money=user.GetOwnedMoneyCopperValue();ledger.Hunger=user.CurrentHunger;ledger.Fare=fare;
            }
            Phase=1;return;
        }
        if(level.MapName==CaelumTransportSceneData.Stage(17,TRAVEL_MODE))
        {
            let booking=CaelumTransportBooking.Find(a);
            let resumeLedger=CA436TransportLedger(a.FindInventory('CA436TransportLedger'));
            if(STOP_EARLY && resumeLedger.ResumeRequested)
            {
                bool paid=true,aboard=true;
                for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])
                {
                    let user=CaelumPlayer(players[i].mo);let ledger=CA436TransportLedger(user.FindInventory('CA436TransportLedger'));
                    let other=CaelumTransportBooking.Find(user);
                    paid=paid && user.GetOwnedMoneyCopperValue()==ledger.Money-ledger.Fare;
                    aboard=aboard && other.Onboard && other.Ticket==booking.Ticket && !other.ArrivalPending;
                }
                Check(paid,"resuming original ticket never charges again");
                Check(aboard,"all peers reboard original native vehicle scene");
                Check(booking.Ticket.Elapsed>=resumeLedger.StoppedAt,"resume preserves traveled progress");
                Check(CaelumWorldClock.Get(a).DayTics==CaelumWorldClock.Get(b).DayTics,"shared clock survives stopped round trip");
                Phase=5;Console.Printf("CA436 RESULT peer=%d transport",consoleplayer);return;
            }
            if(Phase==0)
            {
                bool paid=true,shared=true,aboard=true;
                for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])
                {
                    let user=CaelumPlayer(players[i].mo);let other=CaelumTransportBooking.Find(user);
                    let ledger=CA436TransportLedger(user.FindInventory('CA436TransportLedger'));
                    paid=paid && ledger!=null && user.GetOwnedMoneyCopperValue()==ledger.Money-ledger.Fare;
                    shared=shared && other!=null && other.Ticket==booking.Ticket && other.Incidents==booking.Incidents;
                    aboard=aboard && other!=null && other.Onboard && !other.ArrivalPending;
                }
                Check(paid,"every traveler pays own ticket exactly once");
                Check(shared,"vehicle progress and incident draws are shared");
                Check(aboard,"all native peers board the same vehicle scene");
                if(STOP_EARLY)CaelumTransportTrip.RequestExit(a);else CaelumTransportTrip.Wait(a);
                Check(STOP_EARLY?booking.Ticket.Status==CaelumTransportTicket.STOPPED:CaelumCooperativeTime.View(a)!=null,
                    "ordinary stop or wait action uses shared vehicle state");
                Phase=2;return;
            }
            let vote=CaelumCooperativeTravel.View(a);
            if(Phase==2 && vote!=null && vote.Kind==CaelumCooperativeTravel.DISEMBARK)
            {
                Check(booking.Ticket.Status==(STOP_EARLY?CaelumTransportTicket.STOPPED:CaelumTransportTicket.COMPLETE),"shared vehicle reaches requested stop or destination");
                Check(CaelumCooperativeTime.View(a)==null,"arrival ends acceleration before changing maps");
                Check(vote.Destination==(STOP_EARLY?"CAR00":"CABAIRES") && !vote.Committed,"arrival still requires exact destination consent");
                Phase=3;return;
            }
            if(Phase==3 && vote==null && booking.Ticket.TransferDeclined)
            {
                Check(level.MapName==CaelumTransportSceneData.Stage(17,TRAVEL_MODE) && booking.TransferPending,"rejected disembarkation leaves group aboard stopped vehicle");
                Check(CaelumTransportSession.Show(a,null),"transport controls remain available after rejecting exit");
                CaelumTransportSession.Find(a).Act(a,1);
                Check(CaelumCooperativeTravel.View(a)!=null,"explicit retry reopens destination vote");
                Phase=4;return;
            }
        }
        if(STOP_EARLY && level.MapName=="CAR00" && Phase==0)
        {
            let booking=CaelumTransportBooking.Find(a);
            Check(booking.Ticket.Status==CaelumTransportTicket.STOPPED && booking.StopMap==level.MapName,"native rural stop preserves ticket and place");
            Check(a.GetOwnedMoneyCopperValue()==200-booking.Ticket.Fare,"stopping does not consume another fare");
            for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])
            {
                let user=CaelumPlayer(players[i].mo);let ledger=CA436TransportLedger(user.FindInventory('CA436TransportLedger'));
                ledger.ResumeRequested=true;ledger.StoppedAt=booking.Ticket.Elapsed;
            }
            Check(CaelumTransportTrip.Resume(a),"resume opens a new unanimous boarding proposal");
            Check(CaelumCooperativeTravel.View(a)!=null && CaelumCooperativeTravel.View(a).Fare==0,"original ticket quotes zero additional fare");
            Phase=1;return;
        }
        if(level.MapName=="CABAIRES")
        {
            bool paid=true,arrived=true,supplies=true;
            for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])
            {
                let user=CaelumPlayer(players[i].mo);let ledger=CA436TransportLedger(user.FindInventory('CA436TransportLedger'));
                let journey=CaelumJourneyState.Get(user);let booking=CaelumTransportBooking.Find(user);
                paid=paid && user.GetOwnedMoneyCopperValue()==ledger.Money-ledger.Fare;
                arrived=arrived && journey!=null && journey.Status==CaelumJourneyState.STATUS_ARRIVED && journey.Arrivals==1 && !booking.Onboard;
                supplies=supplies && user.CurrentHunger<ledger.Hunger;
            }
            Check(paid,"arrival and retry do not charge another ticket");
            Check(arrived,"all travelers record one native transport arrival");
            Check(supplies,"travelers spend individual survival resources during shared ride");
            Check(CaelumWorldClock.Get(a).DayTics==CaelumWorldClock.Get(b).DayTics,"destination clock is synchronized after transport");
            Phase=5;Console.Printf("CA436 RESULT peer=%d transport",consoleplayer);
        }
    }
}
