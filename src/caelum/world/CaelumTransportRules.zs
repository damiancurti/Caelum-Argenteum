// Catalogo puro. El calendario y el pago se aplican en la transaccion de viaje.
class CaelumTransportRules : Object
{
    static clearscope bool Route(int id)
    {return CaelumTransportData.Origin(id)>=0 && CaelumTransportData.Destination(id)>=0;}
    static clearscope bool Mode(int mode)
    {return CaelumTransportData.SpeedKmh(mode)>0;}
    static clearscope double DistanceKm(int route,int mode)
    {
        if(!Route(route) || !Mode(mode))return 0;
        int first=CaelumTransportData.Origin(route),last=CaelumTransportData.Destination(route);
        double distance=0;
        for(int segment=Min(first,last);segment<Max(first,last);segment++)
            distance+=CaelumTransportData.SegmentKm(segment,mode);
        return distance;
    }
    static clearscope bool ThroughBarracas(int route)
    {return Route(route) && Abs(CaelumTransportData.Origin(route)-CaelumTransportData.Destination(route))==2;}
    static clearscope double Hours(int route,int mode)
    {
        if(!Route(route) || !Mode(mode))return 0;
        double moving=DistanceKm(route,mode)/CaelumTransportData.SpeedKmh(mode);
        if(mode==CaelumJourneyState.MODE_CART || mode==CaelumTransportData.MODE_HORSE)
            return moving+Floor(Max(0,moving-.000000001)/CaelumTransportData.LAND_MOVING_HOURS)
                *(24-CaelumTransportData.LAND_MOVING_HOURS);
        return moving+(ThroughBarracas(route)?CaelumTransportData.StopHours(mode):0);
    }
    static clearscope double MovingHours(int route,int mode,double elapsed)
    {
        if(!Route(route) || !Mode(mode) || elapsed<=0)return 0;
        double moving=elapsed;
        if(mode==CaelumJourneyState.MODE_CART || mode==CaelumTransportData.MODE_HORSE)
            moving=Floor(elapsed/24)*CaelumTransportData.LAND_MOVING_HOURS
                +Min(elapsed-Floor(elapsed/24)*24,CaelumTransportData.LAND_MOVING_HOURS);
        else if(ThroughBarracas(route))
        {
            int first=CaelumTransportData.Origin(route)==0?0:1;
            double stopAt=CaelumTransportData.SegmentKm(first,mode)/CaelumTransportData.SpeedKmh(mode);
            moving-=Clamp(elapsed-stopAt,0.0,CaelumTransportData.StopHours(mode));
        }
        return Min(moving,DistanceKm(route,mode)/CaelumTransportData.SpeedKmh(mode));
    }
    static clearscope int Fare(int route,int mode,int travelers)
    {
        if(travelers<=0 || !Route(route) || !Mode(mode))return 0;
        return int(Ceil(DistanceKm(route,mode)*CaelumTransportData.FareRate(mode)*travelers));
    }
    static clearscope double NextDeparture(int route,int mode,double now,double epoch)
    {
        if(!Route(route) || !Mode(mode))return -1;
        double period=CaelumTransportData.PeriodHours(mode)*3600;
        if(period<=0)return now;
        double offset=CaelumTransportData.TerminalDepartureHours(mode);
        if(CaelumTransportData.Origin(route)==1)
        {
            int segment=CaelumTransportData.Destination(route)==0?1:0;
            offset+=CaelumTransportData.SegmentKm(segment,mode)/CaelumTransportData.SpeedKmh(mode)
                +CaelumTransportData.StopHours(mode);
        }
        double first=epoch+offset*3600;
        return first+Ceil((now-first)/period)*period;
    }
}
