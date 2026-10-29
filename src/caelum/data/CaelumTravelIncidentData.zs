// #417: decisiones del autor del 25 de octubre; magnitudes del mundo.
class CaelumTravelIncidentData : Object
{
    const REVISION=1;
    const AMBUSH_KM=10;
    const AMBUSH_PERCENT=1;
    const BREAKDOWN_KM=100;
    const BREAKDOWN_PERCENT=2;
    const REPAIR_SECONDS=7200;
    const STORM_WIND_KMH=60;
    const STORM_RAIN_MM_H=20;
    const BANDITS=3;
    const CARTRIDGES=20;
    static clearscope bool AmbushMode(int mode){return mode==3 || mode==5;}
    static clearscope bool BreakdownMode(int mode){return mode==3 || mode==4 || mode==6;}
    static clearscope bool Storm(double wind,double rain)
    {return wind>=STORM_WIND_KMH || rain>=STORM_RAIN_MM_H;}
    // Puntos de aparicion sobre el camino protegido de CARxx, sin nuevas
    // distancias de combate. La colision nativa decide si estan disponibles.
    static clearscope vector3 BanditPoint(int index)
    {
        vector3 points[]={(256,0,0),(-256,0,0),(512,0,0),(-512,0,0),(768,0,0),(-768,0,0)};
        return points[Clamp(index,0,5)];
    }
}
