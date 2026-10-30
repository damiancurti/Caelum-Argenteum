// #428: tiempos aprobados; el alcance procede de la tabla auditiva compartida.
class CaelumCommunicationData : Object
{
    const REVISION=1;
    const SHOUT_INTERVAL_SECONDS=5;

    static clearscope bool AlliedFactions(int first,int second)
    {
        // La matriz actual no contiene alianzas entre facciones diferentes.
        return first>=0 && first==second;
    }
}
