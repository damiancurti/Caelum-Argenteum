// Generado por generate_fermentation_station.py; editar fermentation_station.json.
class CaelumFermentationData : Object
{
    const REVISION = 1;
    const INTERIOR_CAPACITY_LITERS = 4252.967367;
    const WORKING_CAPACITY_LITERS = 3402;
    static Vector3 Position(String map)
    {
        if(map=="MAP01")return (1200,448,0);
        if(map=="MAP03")return (-584,1472,0);
        return (0,0,0);
    }
    static int Group(String map)
    {
        if(map=="MAP01")return 2;
        if(map=="MAP03")return 0;
        return 0;
    }
    static double Angle(String map)
    {
        if(map=="MAP01")return 270;
        if(map=="MAP03")return 0;
        return 0;
    }
    static bool Supports(String map)
    {
        return map=="MAP01" || map=="MAP03";
    }
}
