// #411: superficies y limites de los mapas existentes, sin otorgar terrenos urbanos.
class CaelumCampLandData : Object
{
    const REVISION=1;
    static clearscope bool FurnitureInterior(String map)
    {return map=="MAP01";}
    static clearscope bool Garden(String map,String flat)
    {return map=="MAP01" && flat=="CMGR01A";}
    static clearscope bool Countryside(String map,vector3 p)
    {
        if(map!="MAP03")return false;
        // Rectangulos exteriores de assets/map06_port/CITY.json.
        return (p.X>=-30720 && p.X<=-29824 && p.Y>=-14592 && p.Y<=16640)
            || (p.X>=-29824 && p.X<=896 && p.Y>=16128 && p.Y<=16640);
    }
}
