// Focused native travel transaction checks; fixture state never ships in src.
class CA436TravelLedger : Inventory
{
    int Day,Time,Expected,ProposedSerial;
    double Hunger;
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA436ClockProbe : EventHandler
{
    int Phase,Started,TotalRequests;
    ui bool Sent;
    ui int VoteSent;
    CaelumCooperativeTravel Proposal;
    void Check(bool okay,String label){Console.Printf("CA436 %s %s",okay?"PASS":"FAIL",label);}
    override void UiTick()
    {
        if(gamestate!=GS_LEVEL || consoleplayer<0)return;
        if(!Sent && level.time>=TICRATE && players[consoleplayer].mo)
        {Sent=true;SendNetworkEvent("ca436_native_probe",consoleplayer);}
        if((Phase==2 || Phase==4) && Proposal!=null && Proposal.Opened && VoteSent!=Proposal.Serial)
        {VoteSent=Proposal.Serial;SendNetworkEvent("ca_cooperative_travel",CaelumCooperativeTravel.ACCEPT,Proposal.Serial);}
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!="ca436_native_probe")return;
        Console.Printf("CA436 EVENT peer=%d sender=%d serial=%d",consoleplayer,e.Player,++TotalRequests);
    }
    override void WorldTick()
    {
        if(Phase==3 || level.time<TICRATE*3)return;
        let a=CaelumPlayer(players[0].mo);let b=CaelumPlayer(players[1].mo);
        if(!CaelumWorldClockTicker.Ready(a) || !CaelumWorldClockTicker.Ready(b))return;
        if(level.MapName=="CAH000")
        {
            Check(true,"native household destination loaded for the group");
            Check(CaelumCooperativeTravel.View(a)==null && CaelumCooperativeTravel.View(b)==null,"household consent released on arrival");
            Check(a.FindInventory('CA436TravelLedger')!=null && b.FindInventory('CA436TravelLedger')!=null,"house doorway preserves individual inventories");
            Check(CaelumWorldClock.Get(a).DayTics==CaelumWorldClock.Get(b).DayTics,"house doorway preserves synchronized clock");
            Phase=3;Console.Printf("CA436 RESULT peer=%d traveled",consoleplayer);return;
        }
        if(level.MapName=="MAP03" && Phase==0)
        {
            bool all=true,clock=true,cost=true,once=true,closed=true;
            for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])
            {
                let user=CaelumPlayer(players[i].mo);let j=CaelumJourneyState.Get(user);
                let ledger=CA436TravelLedger(user.FindInventory('CA436TravelLedger'));
                let time=CaelumWorldClock.Get(user);
                all=all && j!=null && j.Status==CaelumJourneyState.STATUS_ARRIVED && ledger!=null;
                if(ledger==null)continue;
                int spent=(time.CompletedDays-ledger.Day)*CaelumWorldClock.TicsPerDay()+time.DayTics-ledger.Time;
                clock=clock && spent>=ledger.Expected && spent<ledger.Expected+TICRATE*20;
                cost=cost && user.CurrentHunger<ledger.Hunger;
                once=once && j!=null && j.Sequence==1 && j.Arrivals==1;
                closed=closed && CaelumCooperativeTravel.View(user)==null;
            }
            Check(all,"all native players arrive with their own journey record");
            Check(clock,"group travel advances world clock once");
            Check(cost,"each native body pays its own journey resources");
            Check(once,"one departure and arrival per character");
            Check(closed,"travel consent released after native map transition");
            Check(CaelumWorldClock.Get(a).DayTics==CaelumWorldClock.Get(b).DayTics,"clock replicas remain equal at destination");
            a.Angle=0;a.Pitch=0;
            let portal=CaelumHousePortal(Actor.Spawn('CaelumHousePortal',a.Pos+(64,0,0),NO_REPLACE));
            portal.args[0]=0;portal.args[1]=0;
            let audio=CaelumMenuAudio(StaticEventHandler.Find('CaelumMenuAudio'));
            Check(audio!=null && audio.RequestHouseDoor(a,portal),"ordinary house-door entry creates unanimous proposal on every peer");
            Proposal=CaelumCooperativeTravel.View(a);
            Check(Proposal!=null && Proposal.Destination=="CAH000" && !Proposal.Committed,"house destination fixed before anyone accepts");
            Phase=4;return;
        }
        if(Phase==0)
        {
            Check(level.MapName=="TRESERV","travel probe starts in source map");
            double original=b.Speed;b.Speed=original*0.5;
            double slow=Min(CaelumJourneyRules.WalkingKmh(a),CaelumJourneyRules.WalkingKmh(b));
            Check(CaelumTravelService.Begin(a,8,CaelumJourneyState.MODE_FOOT),"ordinary travel entry creates group proposal");
            Proposal=CaelumCooperativeTravel.View(a);
            if(Proposal==null){Phase=3;return;}
            Check(Proposal.Opened && !Proposal.Committed && Proposal.Accepted==0,"proposal does not depart or silently accept");
            Check(Abs(Proposal.Pace-slow)<0.000001,"walking proposal uses slowest native pace");
            Check(Proposal.Plans[0]!=Proposal.Plans[1] && Proposal.Plans[0].Available!=Proposal.Plans[1].Available,"personal forecasts do not share resource state");
            Check(Proposal.Plans[0].TotalTics()==Proposal.Plans[1].TotalTics(),"both travelers plan the same elapsed time");
            Check(!CaelumCooperativeTime.Open(a),"time skip cannot overlap a travel proposal");
            Check(!Proposal.Request(a,CaelumCooperativeTravel.ACCEPT,Proposal.Serial-1),"stale travel consent rejected");
            Check(Proposal.Request(a,CaelumCooperativeTravel.ACCEPT,Proposal.Serial) && !Proposal.Committed,"one consent does not move group");
            Check(!Proposal.Request(a,CaelumCooperativeTravel.ACCEPT,Proposal.Serial),"duplicate travel consent rejected");
            Check(Proposal.Request(b,CaelumCooperativeTravel.CANCEL,Proposal.Serial) && !Proposal.Committed,"other participant can reject without departing");
            Check(CaelumJourneyState.Get(a)==null && CaelumJourneyState.Get(b)==null,"cancel creates no personal departure records");
            b.Speed=original;
            Check(CaelumTravelService.Begin(a,8,CaelumJourneyState.MODE_FOOT),"proposal for resource revalidation opens");
            Proposal=CaelumCooperativeTravel.View(a);int prior=Proposal.Serial;b.Speed=original*0.9;
            for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])Proposal.Request(CaelumPlayer(players[i].mo),CaelumCooperativeTravel.ACCEPT,prior);
            Check(Proposal.Opened && !Proposal.Committed && Proposal.Accepted==0 && Proposal.Serial!=prior,"changed pace clears every consent before charging");
            Proposal.Finish("CA_COOP_TRAVEL_CANCELLED");b.Speed=original;
            int health=a.health;double hunger=a.CurrentHunger,thirst=a.CurrentThirst;
            a.health=1;a.player.health=1;a.CurrentHunger=0;a.CurrentThirst=0;
            Check(CaelumTravelService.Begin(a,8,CaelumJourneyState.MODE_FOOT),"lethal journey can still be previewed without spending");
            Proposal=CaelumCooperativeTravel.View(a);
            Check(Proposal!=null && Proposal.Interrupted && Proposal.Plans[0].Available.Health<=0,"forecast detects first traveler death");
            Check(Proposal!=null && Proposal.Plans[0].Available.ElapsedTics==Proposal.Plans[1].Available.ElapsedTics,"survivor forecast stops at the same fatal instant");
            if(Proposal!=null)Proposal.Finish("CA_COOP_TRAVEL_CANCELLED");
            a.health=health;a.player.health=health;a.CurrentHunger=hunger;a.CurrentThirst=thirst;
            Check(CaelumTravelService.Begin(a,8,CaelumJourneyState.MODE_FOOT),"new proposal can follow cancellation");
            Proposal=CaelumCooperativeTravel.View(a);Started=level.time;Phase=1;return;
        }
        if(Phase==1 && level.time-Started>=TICRATE*2)
        {
            Check(Proposal.Opened && !Proposal.Committed && level.MapName=="TRESERV","silence keeps group in source map");
            for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])
            {
                let user=CaelumPlayer(players[i].mo);let ledger=CA436TravelLedger(user.GiveInventoryType('CA436TravelLedger'));
                let clock=CaelumWorldClock.Get(user);ledger.Day=clock.CompletedDays;ledger.Time=clock.DayTics;
                ledger.Expected=Proposal.Elapsed;ledger.Hunger=user.CurrentHunger;
            }
            Phase=2;
        }
    }
}
