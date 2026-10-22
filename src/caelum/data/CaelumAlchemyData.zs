// Generado por generate_alchemy_data.py; editar alchemy_station.json.
class CaelumAlchemyData : Object
{
    const REVISION = 1;
    static Vector3 Position(String map)
    {
        if(map == "MAP01") return (1128,448,0);
        if(map == "MAP03") return (-656,1472,0);
        return (0,0,0);
    }
    static int Group(String map)
    {
        if(map == "MAP01") return 2;
        if(map == "MAP03") return 0;
        return 0;
    }
    static double Angle(String map)
    {
        if(map == "MAP01") return 270;
        if(map == "MAP03") return 0;
        return 0;
    }
    static bool Supports(String map)
    {
        return map == "MAP01" || map == "MAP03";
    }
}
