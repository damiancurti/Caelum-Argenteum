// Generado por assets/generators/generate_cartography_catalogue.py.
// La suma nativa identifica la geometrÃ­a cargada, tambiÃ©n en hubs antiguos.
class CaelumCartographyCatalogueData : Object
{
    const MAP01_CHECKSUM = "359c5aa1daa71a0fb91bba6848818f46";
    const MAP02_CHECKSUM = "d8d3ca328f2c155e49f0216c2fea0643";
    const MAP06_CHECKSUM = "26eb59c84f2028e436acaa4914b42727";
    const MANSION_ROOMS = 10;
    static bool MansionContains(int index,Vector3 point)
    {
        switch(index)
        {
        case 0: return point.X>-561 && point.X<32 && point.Y>100 && point.Y<632 && point.Z>=0 && point.Z<128;
        case 1: return point.X>704 && point.X<1305 && point.Y>100 && point.Y<632 && point.Z>=0 && point.Z<128;
        case 2: return point.X>-561 && point.X<32 && point.Y>-632 && point.Y<-100 && point.Z>=0 && point.Z<128;
        case 3: return point.X>704 && point.X<1305 && point.Y>-632 && point.Y<-100 && point.Z>=0 && point.Z<128;
        case 4: return point.X>40 && point.X<696 && point.Y>88 && point.Y<628 && point.Z>=0 && point.Z<128;
        case 5: return point.X>-465 && point.X<-129 && point.Y>200 && point.Y<536 && point.Z>=136 && point.Z<256;
        case 6: return point.X>865 && point.X<1201 && point.Y>200 && point.Y<536 && point.Z>=136 && point.Z<256;
        case 7: return point.X>-465 && point.X<-129 && point.Y>-536 && point.Y<-200 && point.Z>=136 && point.Z<256;
        case 8: return point.X>865 && point.X<1201 && point.Y>-536 && point.Y<-200 && point.Z>=136 && point.Z<256;
        case 9: return point.X>-363 && point.X<1047 && point.Y>-383 && point.Y<383 && point.Z>=264 && point.Z<392;
        }
        return false;
    }
    static String MansionId(int index)
    {
        switch(index)
        {
        case 0: return "workshop-rulo";
        case 1: return "workshop-ronnie";
        case 2: return "workshop-caella";
        case 3: return "workshop-argento";
        case 4: return "practice";
        case 5: return "bedroom-rulo";
        case 6: return "bedroom-ronnie";
        case 7: return "bedroom-caella";
        case 8: return "bedroom-argento";
        case 9: return "upper-workshop";
        }
        return "";
    }
    static String MansionName(int index)
    {
        switch(index)
        {
        case 0: return "CA_POI_WORKSHOP_RULO";
        case 1: return "CA_POI_WORKSHOP_RONNIE";
        case 2: return "CA_POI_WORKSHOP_CAELLA";
        case 3: return "CA_POI_WORKSHOP_ARGENTO";
        case 4: return "CA_POI_PRACTICE";
        case 5: return "CA_POI_BEDROOM_RULO";
        case 6: return "CA_POI_BEDROOM_RONNIE";
        case 7: return "CA_POI_BEDROOM_CAELLA";
        case 8: return "CA_POI_BEDROOM_ARGENTO";
        case 9: return "CA_POI_UPPER_WORKSHOP";
        }
        return "";
    }
    static Vector3 MansionPosition(int index)
    {
        switch(index)
        {
        case 0: return (-264.5,366,0);
        case 1: return (1004.5,366,0);
        case 2: return (-264.5,-366,0);
        case 3: return (1004.5,-366,0);
        case 4: return (368,358,0);
        case 5: return (-297,368,136);
        case 6: return (1033,368,136);
        case 7: return (-297,-368,136);
        case 8: return (1033,-368,136);
        case 9: return (342,0,264);
        }
        return (0,0,0);
    }
    static bool TowerContains(int index,Vector3 point)
    {
        switch(index)
        {
        case 0: return point.X>-30080 && point.X<-29440 && point.Y>15488 && point.Y<16128 && point.Z>=256 && point.Z<=400;
        case 1: return point.X>512 && point.X<1152 && point.Y>15488 && point.Y<16128 && point.Z>=256 && point.Z<=400;
        case 2: return point.X>-30080 && point.X<-29440 && point.Y>-14592 && point.Y<-13952 && point.Z>=256 && point.Z<=400;
        case 3: return point.X>512 && point.X<1152 && point.Y>-14592 && point.Y<-13952 && point.Z>=256 && point.Z<=400;
        }
        return false;
    }
    static Vector3 TowerPosition(int index)
    {
        switch(index)
        {
        case 0: return (-29760,15808,384);
        case 1: return (832,15808,384);
        case 2: return (-29760,-14272,384);
        case 3: return (832,-14272,384);
        }
        return (0,0,0);
    }
    static Vector3 EastPosition() { return (768,576,0); }
    static bool CrossesEast(Vector3 before,Vector3 after)
    {
        if((before.X<768)==(after.X<768) || before.X==after.X)return false;
        Vector3 crossing=before+(after-before)*((768-before.X)/(after.X-before.X));
        return crossing.Y>448 && crossing.Y<704 && crossing.Z>=0 && crossing.Z<96;
    }
}
