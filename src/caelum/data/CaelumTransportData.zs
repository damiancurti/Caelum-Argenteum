// Generado desde assets/transport/network.json; no editar a mano.
// Fuentes, limites y estimaciones estan registrados en el manifiesto.
class CaelumTransportData : Object
{
    const REVISION = 1;
    const NODE_COUNT = 3;
    const MODE_HORSE = 5;
    const MODE_TRAIN = 6;
    const LAND_MOVING_HOURS = 8;
    const LAND_SLEEP_HOURS = 8;
    static clearscope int Origin(int route)
    {
        switch(route)
        {
            case 10: return 1;
            case 11: return 2;
            case 17: return 1;
            case 18: return 0;
            case 19: return 0;
            case 20: return 2;
        }
        return -1;
    }
    static clearscope int Destination(int route)
    {
        switch(route)
        {
            case 10: return 2;
            case 11: return 1;
            case 17: return 0;
            case 18: return 1;
            case 19: return 2;
            case 20: return 0;
        }
        return -1;
    }
    static clearscope int Location(int node)
    {
        int values[] = {9,6,7};
        return node>=0 && node<3 ? values[node] : 0;
    }
    static clearscope String Map(int node)
    {
        String values[] = {"CABAIRES","MAP03","TCOAST"};
        return node>=0 && node<3 ? values[node] : "";
    }
    static clearscope String NameKey(int node)
    {
        String values[] = {"CA_BUENOS_AIRES_NAME","CA_MAP06_NAME","CA_MAR_DEL_PLATA_NAME"};
        return node>=0 && node<3 ? values[node] : "CA_WORLD_UNREGISTERED";
    }
    static clearscope double SegmentKm(int segment,int mode)
    {
        if(segment<0 || segment>1)return 0;
        if(mode==3 || mode==MODE_HORSE)return segment==0?4.005979:390.560257;
        if(mode==4)return segment==0?4.521879:451.444750;
        if(mode==MODE_TRAIN)return segment==0?3.600000:398.736000;
        return 0;
    }
    static clearscope double SpeedKmh(int mode)
    {
        if(mode==3)return 3.000000000;
        if(mode==4)return 9.260000000;
        if(mode==5)return 8.000000000;
        if(mode==6)return 34.241361702;
        return 0;
    }
    static clearscope double FareRate(int mode)
    {
        if(mode==3)return 2.000000000;
        if(mode==4)return 1.000000000;
        if(mode==5)return 3.000000000;
        if(mode==6)return 2.000000000;
        return 0;
    }
    static clearscope double StopHours(int mode)
    {
        if(mode==4)return 1.000000000;
        if(mode==6)return 0.250000000;
        return 0;
    }
    static clearscope double PeriodHours(int mode)
    {
        if(mode==4)return 72.000000000;
        if(mode==6)return 24.000000000;
        return 0;
    }
    static clearscope double TerminalDepartureHours(int mode)
    {
        if(mode==4)return 8.000000000;
        if(mode==6)return 20.500000000;
        return 0;
    }
}
