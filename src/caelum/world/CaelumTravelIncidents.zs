// El billete es el unico propietario. Los indices se confirman antes del
// sorteo: guardar, salir, reanudar o volver a observar no repiten una tirada.
class CaelumTravelIncidents : Object play
{
    int Revision,AmbushIndex,BreakdownIndex,AmbushRolls,BreakdownRolls;
    int Ambushes,Breakdowns,EncounterSequence;
    bool Storm,AmbushPending,AmbushActive;
    double RepairUntil,AmbushAt;
    String AmbushMap;
    virtual bool RollAmbush(){return Random[CaelumTravelAmbushRoll](0,99)<CaelumTravelIncidentData.AMBUSH_PERCENT;}
    virtual bool RollBreakdown(){return Random[CaelumTravelBreakdownRoll](0,99)<CaelumTravelIncidentData.BREAKDOWN_PERCENT;}

    void Initialize(CaelumTransportTicket ticket)
    {
        if(Revision>=CaelumTravelIncidentData.REVISION || ticket==null)return;
        AmbushIndex=int(Floor(ticket.CoveredKm()/CaelumTravelIncidentData.AMBUSH_KM))+1;
        BreakdownIndex=int(Floor(ticket.CoveredKm()/CaelumTravelIncidentData.BREAKDOWN_KM))+1;
        // Un billete anterior no recibe incidentes retrospectivos.
        Revision=CaelumTravelIncidentData.REVISION;
    }
    static CaelumTravelIncidents Get(CaelumTransportBooking booking)
    {
        if(booking==null || booking.Ticket==null)return null;
        if(booking.Incidents==null)booking.Incidents=new('CaelumTravelIncidents');
        booking.Incidents.Initialize(booking.Ticket);
        if(booking.Incidents.AmbushActive && !booking.Incidents.AmbushPending && booking.Incidents.AmbushMap.Length()==0)
            booking.Incidents.AmbushMap=booking.StopMap;
        return booking.Incidents;
    }
    static clearscope double SecondsAt(CaelumTransportTicket ticket,double km)
    {
        double hours=Clamp(km,0.0,ticket.DistanceKm)/ticket.SpeedKmh;
        if(ticket.LandMovingHours>0)
        {
            double days=Max(0.0,Ceil(hours/ticket.LandMovingHours)-1);
            return (days*24+hours-days*ticket.LandMovingHours)*3600;
        }
        double seconds=hours*3600;
        if(ticket.StopSeconds>0 && seconds>ticket.StopAtSeconds)seconds+=ticket.StopSeconds;
        return seconds;
    }
    // La muestra exterior conserva la tormenta aunque el viajero tenga techo.
    static void Observe(CaelumPlayer user,CaelumTransportBooking booking,double now)
    {
        let incidents=Get(booking);if(incidents==null || !booking.Onboard)return;
        let weather=CaelumWeatherState.Get(user);let outside=weather==null?null:weather.Outside;
        incidents.Advance(booking.Ticket,now,outside!=null && outside.Available?outside.WindSpeedKmh:0,
            outside!=null && outside.Available?outside.PrecipitationMmPerHour:0);
    }
    void Advance(CaelumTransportTicket ticket,double now,double wind,double rain)
    {
        Initialize(ticket);if(ticket==null || now<=ticket.Stamp || !ticket.Active())return;
        if(ticket.Status==CaelumTransportTicket.STOPPED)return;
        Storm=CaelumTravelIncidentData.Storm(wind,rain);
        if(RepairUntil>0)
        {
            if(now<RepairUntil){ticket.Stamp=now;return;}
            ticket.Stamp=Max(ticket.Stamp,RepairUntil);RepairUntil=0;
        }
        if(Storm){ticket.Stamp=now;return;}
        // Cota tecnica: las observaciones ordinarias cruzan como mucho una
        // frontera. Un reloj diagnosticado con un salto grande se drena por
        // callbacks, conservando Stamp para el resto, sin bucle ilimitado.
        for(int guard=0;guard<8 && ticket.Stamp<now && ticket.Active();guard++)
        {
            double ambush=CaelumTravelIncidentData.AmbushMode(ticket.Mode)?AmbushIndex*CaelumTravelIncidentData.AMBUSH_KM:1e30;
            double breakdown=CaelumTravelIncidentData.BreakdownMode(ticket.Mode)?BreakdownIndex*CaelumTravelIncidentData.BREAKDOWN_KM:1e30;
            double boundary=Min(ambush,breakdown);
            if(boundary>=ticket.DistanceKm){ticket.Observe(now);return;}
            double boundarySeconds=SecondsAt(ticket,boundary);
            double at=Max(ticket.Stamp,ticket.Departure)+Max(0.0,boundarySeconds-ticket.Elapsed);
            ticket.Observe(Min(now,at));
            if(ticket.Elapsed+0.00001<boundarySeconds)return;
            bool attack=false,failure=false;
            if(ambush==boundary)
            {AmbushIndex++;AmbushRolls++;attack=RollAmbush();}
            if(breakdown==boundary)
            {BreakdownIndex++;BreakdownRolls++;failure=RollBreakdown();}
            if(failure){Breakdowns++;RepairUntil=at+CaelumTravelIncidentData.REPAIR_SECONDS;}
            if(attack)
            {
                Ambushes++;EncounterSequence++;AmbushAt=at;AmbushPending=true;AmbushActive=true;
                ticket.Elapsed=boundarySeconds;ticket.Stamp=now;ticket.Status=CaelumTransportTicket.STOPPED;ticket.ExitRequested=false;
                return;
            }
            if(failure)
            {
                // Lo transcurrido despues de la averia cuenta para reparar,
                // nunca como distancia. Una observacion posterior reanuda.
                ticket.Stamp=Min(now,RepairUntil);return;
            }
        }
    }
    static bool MayResume(CaelumPlayer user,CaelumTransportBooking booking)
    {
        String reason=CaelumRestSafety.BlockReason(user);
        let incidents=Get(booking);
        return reason.Length()==0 || (reason=="CA_REST_ENEMY" && incidents!=null && incidents.AmbushActive
            && incidents.AmbushMap==level.MapName && booking.StopMap==level.MapName && CaelumTransportSceneData.IsRural(level.MapName));
    }
}
