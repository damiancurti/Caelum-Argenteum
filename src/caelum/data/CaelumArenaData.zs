// #438: generado desde assets/arenas/VENUES.json.
class CaelumArenaData : Object
{
    const REVISION=1;
    const CONVERSATION=43800;
    static clearscope String Map(int venue) { switch(venue) {
        case 0: return "CARING";
        case 1: return "CASEWER";
    } return ""; }
    static clearscope String NameKey(int venue) { switch(venue) {
        case 0: return "CA_ARENA_RING";
        case 1: return "CA_ARENA_MAZE";
    } return "CA_ARENA_TITLE"; }
    static clearscope bool IsMap(String map) { return map==Map(0) || map==Map(1); }
    static clearscope vector3 Start(int venue,int slot) { switch(venue*MAXPLAYERS+slot) {
        case 0: return (64,64,0);
        case 1: return (192,64,0);
        case 2: return (320,64,0);
        case 3: return (320,192,0);
        case 4: return (320,320,0);
        case 5: return (192,320,0);
        case 6: return (64,320,0);
        case 7: return (64,192,0);
        case 8: return (96,96,0);
        case 9: return (992,96,0);
        case 10: return (1888,96,0);
        case 11: return (1888,992,0);
        case 12: return (1888,1888,0);
        case 13: return (992,1888,0);
        case 14: return (96,1888,0);
        case 15: return (96,992,0);
    } return (0,0,0); }
    static clearscope double Facing(int venue,int slot) { switch(venue*MAXPLAYERS+slot) {
        case 0: return 45;
        case 1: return 90;
        case 2: return 135;
        case 3: return 180;
        case 4: return 225;
        case 5: return 270;
        case 6: return 315;
        case 7: return 0;
        case 8: return 0;
        case 9: return 90;
        case 10: return 180;
        case 11: return 180;
        case 12: return 180;
        case 13: return 270;
        case 14: return 0;
        case 15: return 0;
    } return 0; }
    static clearscope vector3 OrganizerPosition() { return (2368,768,0); }
    const ORGANIZER_ANGLE=180;
    static clearscope String OrganizerMap() { return "CABAIRES"; }
}
