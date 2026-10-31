// Un vehículo compartido conserva un trayecto y un sorteo de incidentes.
// Cada viajero paga desde su propio inventario sólo tras validar a todos.
class CaelumCooperativeTransport : Object play
{
    static bool Board(CaelumPlayer user,CaelumTravelVehicle vehicle,int route)
    {
        if(vehicle==null || !vehicle.CanBoard(user) || !CaelumTransportRules.Route(route))return false;
        String target=CaelumTransportSceneData.Stage(route,vehicle.TravelMode());
        if(!LevelInfo.MapExists(target))return false;
        let vote=CaelumCooperativeTravel.Draft(user);if(vote==null)return false;
        vote.Kind=CaelumCooperativeTravel.BOARD;vote.Vehicle=vehicle;vote.Connection=route;
        vote.Mode=vehicle.TravelMode();vote.Destination=target;vote.Entry=0;
        bool okay,changed;[okay,changed]=Prepare(vote,false);
        return okay && vote.Publish();
    }
    static bool SourceValid(CaelumCooperativeTravel vote)
    {
        let user=CaelumPlayer(vote.Owner);
        if(vote.Kind==CaelumCooperativeTravel.BOARD)return vote.Vehicle!=null && !vote.Vehicle.bDestroyed
            && vote.Vehicle.TravelMode()==vote.Mode && vote.Vehicle.CanBoard(user);
        for(int i=0;i<MAXPLAYERS;i++)if(vote.Members[i]!=null)
        {
            let b=CaelumTransportBooking.Find(vote.Members[i]);
            if(b==null || b.Ticket!=vote.Ride || !b.Ticket.Shared)return false;
            if(vote.Kind==CaelumCooperativeTravel.DISEMBARK)
            {if(!b.TransferPending || b.TransferMap!=vote.Destination)return false;}
            else if(b.Onboard || b.TransferPending || b.StopMap!=level.MapName)return false;
        }
        return vote.Ride!=null && (vote.Kind==CaelumCooperativeTravel.DISEMBARK
            || vote.Ride.Status==CaelumTransportTicket.STOPPED || vote.Ride.Status==CaelumTransportTicket.ABANDONED);
    }
    static bool,bool Prepare(CaelumCooperativeTravel vote,bool compare)
    {
        let user=CaelumPlayer(vote.Owner);
        if(!SourceValid(vote))return false,false;
        if(vote.Kind==CaelumCooperativeTravel.DISEMBARK || vote.Kind==CaelumCooperativeTravel.ABANDON)return true,false;
        let ride=vote.Ride;int fare=0;
        if(vote.Kind==CaelumCooperativeTravel.RESUME && (ride==null || CaelumTransportBooking.Now(user)<ride.Stamp))return false,false;
        if(vote.Kind==CaelumCooperativeTravel.BOARD)
        {
            double now=CaelumTransportBooking.Now(user);if(now<0)return false,false;
            ride=CaelumTransportTicket.Create(vote.Connection,vote.Mode,1,now,CaelumTransportBooking.Epoch());
            if(ride==null)return false,false;fare=ride.Fare;
        }
        else if(ride.Status==CaelumTransportTicket.ABANDONED)
            fare=int(Ceil(Max(0,ride.DistanceKm-ride.CoveredKm())*CaelumTransportData.FareRate(ride.Mode)));
        for(int i=0;i<MAXPLAYERS;i++)if(vote.Members[i]!=null)
        {
            let member=vote.Members[i];let previous=CaelumTransportBooking.Find(member);
            if(vote.Kind==CaelumCooperativeTravel.BOARD && previous!=null && previous.Ticket!=null && previous.Ticket.Active())return false,false;
            if((vote.AliveMask&(1<<i))==0)continue;
            if(vote.Kind==CaelumCooperativeTravel.BOARD)
            {
                if(!vote.Vehicle.CanBoard(member) || !CaelumTravelService.CanDepart(member,vote.Connection,true)
                    || CaelumJourneyRules.BlockReason(member)!="")return false,false;
            }
            else if(!CaelumTravelIncidents.MayResume(member,previous))return false,false;
            if(!CaelumCooperativeFare.CanPay(member,fare))
            {CaelumNotifications.Notify(member,StringTable.Localize("CA_COOP_TRAVEL_FUNDS",false));return false,false;}
        }
        bool changed=compare && (vote.Fare!=fare || (vote.Kind==CaelumCooperativeTravel.BOARD
            && (vote.Mode==CaelumJourneyState.MODE_SHIP || vote.Mode==CaelumTransportData.MODE_TRAIN)
            && vote.Ride!=null && vote.Ride.Departure!=ride.Departure));
        vote.Ride=ride;vote.Fare=fare;return true,changed;
    }
    static bool Commit(CaelumCooperativeTravel vote)
    {
        if(!SourceValid(vote))return false;
        let ride=vote.Ride;if(ride==null)return false;
        CaelumCooperativeFare payments[MAXPLAYERS];CaelumTransportBooking bookings[MAXPLAYERS];
        bool valid=true;
        for(int i=0;i<MAXPLAYERS;i++)if(vote.Members[i]!=null)
        {
            let member=vote.Members[i];bookings[i]=CaelumTransportBooking.Find(member);
            if(bookings[i]==null)bookings[i]=CaelumTransportBooking(member.GiveInventoryType('CaelumTransportBooking'));
            if(bookings[i]==null){valid=false;break;}
            if(vote.Fare>0 && (vote.AliveMask&(1<<i))!=0)
            {payments[i]=CaelumCooperativeFare.Prepare(member,vote.Fare);if(payments[i]==null){valid=false;break;}}
        }
        if(!valid){for(int i=0;i<MAXPLAYERS;i++)if(payments[i]!=null)payments[i].Cancel();return false;}
        // Desde aquí no hay asignaciones fallables ni espera entre pagos.
        for(int i=0;i<MAXPLAYERS;i++)if(payments[i]!=null)payments[i].Apply();
        CaelumTravelIncidents incidents=null;
        if(vote.Kind==CaelumCooperativeTravel.BOARD)
        {ride.Shared=true;incidents=new('CaelumTravelIncidents');incidents.Initialize(ride);}
        if(vote.Kind==CaelumCooperativeTravel.RESUME)
        {if(vote.Fare>0)ride.Fare=vote.Fare;ride.Status=CaelumTransportTicket.STOPPED;ride.Resume(CaelumTransportBooking.Now(CaelumPlayer(vote.Owner)));}
        if(vote.Kind==CaelumCooperativeTravel.ABANDON)ride.Abandon(CaelumTransportBooking.Now(CaelumPlayer(vote.Owner)));
        ride.TransferDeclined=false;
        for(int i=0;i<MAXPLAYERS;i++)if(bookings[i]!=null)
        {
            let member=vote.Members[i];let b=bookings[i];CaelumTransportTrip.CloseActivities(member);
            if(vote.Kind==CaelumCooperativeTravel.BOARD)
            {
                b.Revision=2;b.Sequence=Min(b.Sequence,2147483646)+1;b.Ticket=ride;b.Incidents=incidents;
                let clock=CaelumWorldClock.Get(member);b.BoardedDays=clock.CompletedDays;b.BoardedTics=clock.DayTics;
                b.StopMap="";
            }
            else if(vote.Kind==CaelumCooperativeTravel.RESUME && vote.Fare>0)b.Sequence=Min(b.Sequence,2147483646)+1;
            b.Onboard=vote.Kind==CaelumCooperativeTravel.BOARD || vote.Kind==CaelumCooperativeTravel.RESUME;
            if(vote.Kind!=CaelumCooperativeTravel.ABANDON)
            {b.TransferMap=vote.Destination;b.TransferPending=false;b.ArrivalPending=true;}
            member.PersistCharacterState();
        }
        return true;
    }
    static bool Resume(CaelumPlayer user,bool abandon=false)
    {
        let b=CaelumTransportBooking.Find(user);
        if(b==null || b.Ticket==null || !b.Ticket.Shared)return false;
        let vote=CaelumCooperativeTravel.Draft(user);if(vote==null)return false;
        vote.Kind=abandon?CaelumCooperativeTravel.ABANDON:CaelumCooperativeTravel.RESUME;
        vote.Ride=b.Ticket;vote.Mode=b.Ticket.Mode;vote.Connection=b.Ticket.Route;
        vote.Destination=abandon?level.MapName:CaelumTransportSceneData.Stage(vote.Connection,vote.Mode);vote.Entry=0;
        bool okay,changed;[okay,changed]=Prepare(vote,false);return okay && vote.Publish();
    }
    static bool OfferExit(CaelumPlayer user,bool explicitRequest=false)
    {
        let b=CaelumTransportBooking.Find(user);
        if(b==null || b.Ticket==null || !b.Ticket.Shared || !b.TransferPending)return false;
        let ride=b.Ticket;
        if(explicitRequest)ride.TransferDeclined=false;
        if(ride.TransferDeclined || CaelumCooperativeTravel.View(user)!=null)return false;
        let time=CaelumCooperativeTime.View(user);
        if(time!=null && time.Opened)time.FinishVote("CA_COOP_TIME_CANCELLED");
        // Las réplicas consultan el mismo ticket. Reunir sus llegadas antes de
        // ofrecer el mapa evita que el primer Tick traslade al resto por su cuenta.
        for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])
        {
            let member=CaelumPlayer(players[i].mo);let other=CaelumTransportBooking.Find(member);
            if(other==null || other.Ticket!=ride)return false;
            CaelumTransportTrip.Step(member);
            if(!other.TransferPending || other.TransferMap!=b.TransferMap)return false;
        }
        let vote=CaelumCooperativeTravel.Draft(user);if(vote==null)return false;
        vote.Kind=CaelumCooperativeTravel.DISEMBARK;vote.Ride=ride;
        vote.Connection=ride.Route;vote.Mode=ride.Mode;vote.Destination=b.TransferMap;vote.Entry=0;
        return SourceValid(vote) && vote.Publish();
    }
}
