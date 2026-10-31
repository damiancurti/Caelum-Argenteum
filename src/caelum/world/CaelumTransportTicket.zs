// Billete guardable: conserva los valores contratados aunque cambie despues
// el catalogo. El reloj del viaje no avanza mientras el pasajero esta fuera.
class CaelumTransportTicket : Object play
{
    enum TravelStatus { WAITING=1, TRAVELLING, STOPPED, COMPLETE, ABANDONED };
    int Revision, Route, Mode, Fare, Travelers, Status;
    double Departure, Stamp, Elapsed, DistanceKm, SpeedKmh, DurationSeconds;
    double LandMovingHours, StopAtSeconds, StopSeconds;
    bool ExitRequested;
    // Billetes cooperativos comparten sólo trayecto/incidentes; el pago es personal.
    bool Shared,TransferDeclined;

    static CaelumTransportTicket Create(int route,int mode,int travelers,double now,double epoch)
    {
        if(!CaelumTransportRules.Route(route) || !CaelumTransportRules.Mode(mode) || travelers<=0)return null;
        let ticket=new('CaelumTransportTicket');
        ticket.Revision=CaelumTransportData.REVISION;ticket.Route=route;ticket.Mode=mode;
        ticket.Travelers=travelers;ticket.Fare=CaelumTransportRules.Fare(route,mode,travelers);
        ticket.DistanceKm=CaelumTransportRules.DistanceKm(route,mode);
        ticket.SpeedKmh=CaelumTransportData.SpeedKmh(mode);
        ticket.DurationSeconds=CaelumTransportRules.Hours(route,mode)*3600;
        ticket.Departure=CaelumTransportRules.NextDeparture(route,mode,now,epoch);
        ticket.Stamp=now;ticket.Status=WAITING;
        if(mode==CaelumJourneyState.MODE_CART || mode==CaelumTransportData.MODE_HORSE)
            ticket.LandMovingHours=CaelumTransportData.LAND_MOVING_HOURS;
        else if(CaelumTransportRules.ThroughBarracas(route))
        {
            int first=CaelumTransportData.Origin(route)==0?0:1;
            ticket.StopAtSeconds=CaelumTransportData.SegmentKm(first,mode)/ticket.SpeedKmh*3600;
            ticket.StopSeconds=CaelumTransportData.StopHours(mode)*3600;
        }
        return ticket;
    }
    clearscope bool Active(){return Status>=WAITING && Status<=STOPPED;}
    clearscope double DistanceAt(double seconds)
    {
        double hours=Max(0,seconds)/3600;
        if(LandMovingHours>0)
            hours=Floor(hours/24)*LandMovingHours+Min(hours-Floor(hours/24)*24,LandMovingHours);
        else if(StopSeconds>0)hours-=Clamp(seconds-StopAtSeconds,0.0,StopSeconds)/3600;
        return Min(DistanceKm,Max(0,hours)*SpeedKmh);
    }
    clearscope double CoveredKm(){return DistanceAt(Elapsed);}
    clearscope bool AtPort()
    {
        return Elapsed<=0 || Elapsed>=DurationSeconds
            || (StopSeconds>0 && Elapsed>=StopAtSeconds && Elapsed<=StopAtSeconds+StopSeconds);
    }
    clearscope double NextPortSeconds()
    {
        if(AtPort())return Elapsed;
        return StopSeconds>0 && Elapsed<StopAtSeconds?StopAtSeconds:DurationSeconds;
    }
    void Observe(double now)
    {
        if(now<=Stamp)return;
        if(Status==WAITING)
        {
            if(now<Departure){Stamp=now;return;}
            Stamp=Max(Stamp,Departure);Status=TRAVELLING;
        }
        if(Status==TRAVELLING)
        {
            double next=Min(DurationSeconds,Elapsed+Max(0,now-Stamp));
            if(ExitRequested && Mode==CaelumJourneyState.MODE_SHIP)
            {
                double portBoundary=NextPortSeconds();
                if(next>=portBoundary){next=portBoundary;Status=STOPPED;ExitRequested=false;}
            }
            Elapsed=next;
            if(Elapsed>=DurationSeconds)Status=COMPLETE;
        }
        Stamp=now;
    }
    bool RequestStop(double now,bool safeGround,bool vehicleStopped,bool reachablePort)
    {
        Observe(now);
        if(!Active())return false;
        if(Mode==CaelumJourneyState.MODE_SHIP)
        {
            if(!AtPort() || !reachablePort){ExitRequested=true;return false;}
        }
        else if(!safeGround || (Mode==CaelumTransportData.MODE_TRAIN && !vehicleStopped))return false;
        Status=STOPPED;ExitRequested=false;return true;
    }
    bool Resume(double now)
    {
        if(Status!=STOPPED || now<Stamp)return false;
        Stamp=now;Status=now<Departure?WAITING:TRAVELLING;ExitRequested=false;return true;
    }
    bool Abandon(double now)
    {
        if(Status!=STOPPED && Status!=WAITING)return false;
        Stamp=Max(Stamp,now);Status=ABANDONED;ExitRequested=false;return true;
    }
}

// Pago nativo exactamente una vez. La presencia del vehiculo y el contexto
// se vuelven a comprobar al confirmar; el menu no autoriza la transaccion.
class CaelumTransportBooking : Inventory
{
    int Revision, Sequence;
    CaelumTransportTicket Ticket;
    CaelumTravelIncidents Incidents;
    bool Onboard, TransferPending, ArrivalPending;
    String TransferMap, StopMap;
    int BoardedDays, BoardedTics;
    static clearscope CaelumTransportBooking Find(CaelumPlayer user)
    {return user==null?null:CaelumTransportBooking(user.FindInventory('CaelumTransportBooking'));}
    void Ensure(CaelumPlayer user)
    {
        if(Revision>=2)return;
        // El prototipo guardaba solo el contrato. Conservar pago/progreso y
        // dejarlo interrumpido en el lugar guardado, sin inventar un traslado.
        Onboard=false;TransferPending=false;ArrivalPending=false;TransferMap="";
        StopMap=level.MapName;
        if(Ticket!=null && Ticket.Active()){Ticket.Status=CaelumTransportTicket.STOPPED;Ticket.Stamp=Max(Ticket.Stamp,Now(user));}
        Revision=2;
    }
    static double Now(CaelumPlayer user)
    {
        let clock=CaelumWorldClock.Get(user);let calendar=CaelumCalendarState.Get(user);
        if(clock==null || calendar==null || calendar.DateSerial(clock)<0)return -1;
        return double(calendar.DateSerial(clock))*86400+double(calendar.CivilDayTics(clock))*3600/CaelumWorldClock.TicsPerHour();
    }
    static double Epoch()
    {
        return double(CaelumCalendarRules.ToSerial(CaelumCalendarRules.CAMPAIGN_START_YEAR,
            CaelumCalendarRules.CAMPAIGN_START_MONTH,CaelumCalendarRules.CAMPAIGN_START_DAY))*86400;
    }
    static bool Buy(CaelumPlayer user,CaelumTravelVehicle source,int route)
    {
        if(multiplayer)return false; // El cobro conjunto se confirma en una única transacción.
        if(!CaelumPlayerAuthority.CanMutate(user) || !user.CharacterCreationComplete || user.health<=0
            || source==null || !source.CanBoard(user) || !CaelumTravelService.CanDepart(user,route,true)
            || CaelumJourneyRules.BlockReason(user).Length()!=0 || !CaelumTransportRules.Route(route)
            || CaelumTransportData.Map(CaelumTransportData.Origin(route))!=level.MapName
            || !LevelInfo.MapExists(CaelumTransportData.Map(CaelumTransportData.Destination(route))))return false;
        // La integracion cooperativa sigue aplazada; no cobra ausentes.
        for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i] && players[i].mo!=user)return false;
        let previous=Find(user);
        if(previous!=null && previous.Ticket!=null && previous.Ticket.Active())return false;
        double now=Now(user);if(now<0)return false;
        let ticket=CaelumTransportTicket.Create(route,source.TravelMode(),1,now,Epoch());
        if(ticket==null)return false;
        let booking=previous;
        if(booking==null)booking=CaelumTransportBooking(user.GiveInventoryType('CaelumTransportBooking'));
        if(booking==null || !CaelumPropertyRules.Pay(user,ticket.Fare))return false;
        booking.Revision=2;booking.Sequence=Min(booking.Sequence,2147483646)+1;booking.Ticket=ticket;
        booking.Incidents=new('CaelumTravelIncidents');booking.Incidents.Initialize(ticket);
        user.PersistCharacterState();return true;
    }
    override void Tick()
    {Super.Tick();let user=CaelumPlayer(Owner);if(user!=null){Ensure(user);CaelumTransportTrip.Loaded(user);CaelumTransportTrip.Step(user);CaelumTransportTrip.Flush(user);}}
    override void PreTravelled()
    {
        // Un traslado ajeno (por ejemplo el retorno magico) no debe acreditar
        // horas a bordo mientras el pasajero permanece en otro mapa.
        if(Onboard && !ArrivalPending && Ticket!=null)
        {CaelumTravelIncidents.Observe(CaelumPlayer(Owner),self,Now(CaelumPlayer(Owner)));Ticket.Status=CaelumTransportTicket.STOPPED;Onboard=false;StopMap=level.MapName;}
        Super.PreTravelled();
    }
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE -INVENTORY.INVBAR}
    States {Spawn:TNT1 A -1;Stop;}
}
