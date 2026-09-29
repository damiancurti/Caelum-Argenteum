// Datos generados desde assets/map01_mansion/DOORS.json y siege_visuals.json.
class CaelumMansionDoorData : Object
{
    const HALF_WIDTH = 32.0;
    const OPEN_DEGREES = 90;
    const SWEEP_RADIUS = 128;
    static int FixedSwingSide(int group)
    {
        if (group == 906) return -1;
        if (group == 907) return 1;
        if (group == 909) return 1;
        return 0;
    }
}
