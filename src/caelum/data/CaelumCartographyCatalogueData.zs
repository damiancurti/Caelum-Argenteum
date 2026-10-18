// Generado por assets/generators/generate_cartography_catalogue.py.
// La suma nativa identifica la geometrÃ­a cargada, tambiÃ©n en hubs antiguos.
class CaelumCartographyCatalogueData : Object
{
    const MAP01_CHECKSUM = "359c5aa1daa71a0fb91bba6848818f46";
    const MAP02_CHECKSUM = "d8d3ca328f2c155e49f0216c2fea0643";
    const MAP06_CHECKSUM = "8017edf2ae08f3411a3127ed4f512f10";
    const MAP06_FURNISHED_CHECKSUM = "26eb59c84f2028e436acaa4914b42727";
    static bool MatchesCityGeometry(String checksum)
    {
        return checksum==MAP06_CHECKSUM || checksum==MAP06_FURNISHED_CHECKSUM;
    }
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
    static String CityStationId(Vector3 spawnPoint)
    {
        if(spawnPoint==(-27520,-12608,0))return "city-factory-0-workbench";
        if(spawnPoint==(-27424,-12608,0))return "city-factory-0-forge";
        if(spawnPoint==(-27328,-12608,0))return "city-factory-0-anvil";
        if(spawnPoint==(-27232,-12608,0))return "city-factory-0-fine_tools";
        if(spawnPoint==(-25984,-12608,0))return "city-factory-1-workbench";
        if(spawnPoint==(-25888,-12608,0))return "city-factory-1-ranged";
        if(spawnPoint==(-25792,-12608,0))return "city-factory-1-sawmill";
        if(spawnPoint==(-25696,-12608,0))return "city-factory-1-forge";
        if(spawnPoint==(-25600,-12608,0))return "city-factory-1-fine_tools";
        if(spawnPoint==(-24448,-12608,0))return "city-factory-2-workbench";
        if(spawnPoint==(-24352,-12608,0))return "city-factory-2-armor";
        if(spawnPoint==(-24256,-12608,0))return "city-factory-2-sewing";
        if(spawnPoint==(-22912,-12608,0))return "city-factory-3-workbench";
        if(spawnPoint==(-22816,-12608,0))return "city-factory-3-altar";
        if(spawnPoint==(-22720,-12608,0))return "city-factory-3-jeweler";
        if(spawnPoint==(-27520,-10880,0))return "city-factory-18-workbench";
        if(spawnPoint==(-27424,-10880,0))return "city-factory-18-jeweler";
        if(spawnPoint==(-27328,-10880,0))return "city-factory-18-fine_tools";
        if(spawnPoint==(-27232,-10880,0))return "city-factory-18-forge";
        if(spawnPoint==(-27136,-10880,0))return "city-factory-18-altar";
        if(spawnPoint==(-25984,-10880,0))return "city-factory-19-workbench";
        if(spawnPoint==(-25888,-10880,0))return "city-factory-19-sawmill";
        if(spawnPoint==(-25792,-10880,0))return "city-factory-19-sewing";
        if(spawnPoint==(-25696,-10880,0))return "city-factory-19-forge";
        if(spawnPoint==(-24448,-10880,0))return "city-factory-20-workbench";
        if(spawnPoint==(-24352,-10880,0))return "city-factory-20-forge";
        if(spawnPoint==(-24256,-10880,0))return "city-factory-20-anvil";
        if(spawnPoint==(-24160,-10880,0))return "city-factory-20-fine_tools";
        if(spawnPoint==(-22912,-10880,0))return "city-factory-21-workbench";
        if(spawnPoint==(-22816,-10880,0))return "city-factory-21-ranged";
        if(spawnPoint==(-22720,-10880,0))return "city-factory-21-sawmill";
        if(spawnPoint==(-22624,-10880,0))return "city-factory-21-forge";
        if(spawnPoint==(-22528,-10880,0))return "city-factory-21-fine_tools";
        if(spawnPoint==(-27520,-9152,0))return "city-factory-36-workbench";
        if(spawnPoint==(-27424,-9152,0))return "city-factory-36-armor";
        if(spawnPoint==(-27328,-9152,0))return "city-factory-36-sewing";
        if(spawnPoint==(-25984,-9152,0))return "city-factory-37-workbench";
        if(spawnPoint==(-25888,-9152,0))return "city-factory-37-altar";
        if(spawnPoint==(-25792,-9152,0))return "city-factory-37-jeweler";
        if(spawnPoint==(-24448,-9152,0))return "city-factory-38-workbench";
        if(spawnPoint==(-24352,-9152,0))return "city-factory-38-jeweler";
        if(spawnPoint==(-24256,-9152,0))return "city-factory-38-fine_tools";
        if(spawnPoint==(-24160,-9152,0))return "city-factory-38-forge";
        if(spawnPoint==(-24064,-9152,0))return "city-factory-38-altar";
        if(spawnPoint==(-22912,-9152,0))return "city-factory-39-workbench";
        if(spawnPoint==(-22816,-9152,0))return "city-factory-39-sawmill";
        if(spawnPoint==(-22720,-9152,0))return "city-factory-39-sewing";
        if(spawnPoint==(-22624,-9152,0))return "city-factory-39-forge";
        if(spawnPoint==(-27520,-7424,0))return "city-factory-54-workbench";
        if(spawnPoint==(-27424,-7424,0))return "city-factory-54-forge";
        if(spawnPoint==(-27328,-7424,0))return "city-factory-54-anvil";
        if(spawnPoint==(-27232,-7424,0))return "city-factory-54-fine_tools";
        if(spawnPoint==(-25984,-7424,0))return "city-factory-55-workbench";
        if(spawnPoint==(-25888,-7424,0))return "city-factory-55-ranged";
        if(spawnPoint==(-25792,-7424,0))return "city-factory-55-sawmill";
        if(spawnPoint==(-25696,-7424,0))return "city-factory-55-forge";
        if(spawnPoint==(-25600,-7424,0))return "city-factory-55-fine_tools";
        if(spawnPoint==(-24448,-7424,0))return "city-factory-56-workbench";
        if(spawnPoint==(-24352,-7424,0))return "city-factory-56-armor";
        if(spawnPoint==(-24256,-7424,0))return "city-factory-56-sewing";
        if(spawnPoint==(-22912,-7424,0))return "city-factory-57-workbench";
        if(spawnPoint==(-22816,-7424,0))return "city-factory-57-altar";
        if(spawnPoint==(-22720,-7424,0))return "city-factory-57-jeweler";
        if(spawnPoint==(-27520,-5696,0))return "city-factory-72-workbench";
        if(spawnPoint==(-27424,-5696,0))return "city-factory-72-jeweler";
        if(spawnPoint==(-27328,-5696,0))return "city-factory-72-fine_tools";
        if(spawnPoint==(-27232,-5696,0))return "city-factory-72-forge";
        if(spawnPoint==(-27136,-5696,0))return "city-factory-72-altar";
        if(spawnPoint==(-25984,-5696,0))return "city-factory-73-workbench";
        if(spawnPoint==(-25888,-5696,0))return "city-factory-73-sawmill";
        if(spawnPoint==(-25792,-5696,0))return "city-factory-73-sewing";
        if(spawnPoint==(-25696,-5696,0))return "city-factory-73-forge";
        if(spawnPoint==(-24448,-5696,0))return "city-factory-74-workbench";
        if(spawnPoint==(-24352,-5696,0))return "city-factory-74-forge";
        if(spawnPoint==(-24256,-5696,0))return "city-factory-74-anvil";
        if(spawnPoint==(-24160,-5696,0))return "city-factory-74-fine_tools";
        if(spawnPoint==(-22912,-5696,0))return "city-factory-75-workbench";
        if(spawnPoint==(-22816,-5696,0))return "city-factory-75-ranged";
        if(spawnPoint==(-22720,-5696,0))return "city-factory-75-sawmill";
        if(spawnPoint==(-22624,-5696,0))return "city-factory-75-forge";
        if(spawnPoint==(-22528,-5696,0))return "city-factory-75-fine_tools";
        if(spawnPoint==(-27520,-3968,0))return "city-factory-90-workbench";
        if(spawnPoint==(-27424,-3968,0))return "city-factory-90-armor";
        if(spawnPoint==(-27328,-3968,0))return "city-factory-90-sewing";
        if(spawnPoint==(-25984,-3968,0))return "city-factory-91-workbench";
        if(spawnPoint==(-25888,-3968,0))return "city-factory-91-altar";
        if(spawnPoint==(-25792,-3968,0))return "city-factory-91-jeweler";
        if(spawnPoint==(-24448,-3968,0))return "city-factory-92-workbench";
        if(spawnPoint==(-24352,-3968,0))return "city-factory-92-jeweler";
        if(spawnPoint==(-24256,-3968,0))return "city-factory-92-fine_tools";
        if(spawnPoint==(-24160,-3968,0))return "city-factory-92-forge";
        if(spawnPoint==(-24064,-3968,0))return "city-factory-92-altar";
        if(spawnPoint==(-22912,-3968,0))return "city-factory-93-workbench";
        if(spawnPoint==(-22816,-3968,0))return "city-factory-93-sawmill";
        if(spawnPoint==(-22720,-3968,0))return "city-factory-93-sewing";
        if(spawnPoint==(-22624,-3968,0))return "city-factory-93-forge";
        return "";
    }
    static Vector3 EastPosition() { return (768,576,0); }
    static bool CrossesEast(Vector3 before,Vector3 after)
    {
        if((before.X<768)==(after.X<768) || before.X==after.X)return false;
        Vector3 crossing=before+(after-before)*((768-before.X)/(after.X-before.X));
        return crossing.Y>448 && crossing.Y<704 && crossing.Z>=0 && crossing.Z<96;
    }
}
