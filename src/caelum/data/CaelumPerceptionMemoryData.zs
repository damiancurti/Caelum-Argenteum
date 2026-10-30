// #427: plazo activo aprobado; el calendario acelerado no lo renueva.
class CaelumPerceptionMemoryData : Object
{
    const REVISION=1;
    const LIFETIME_SECONDS=30;
    static clearscope bool Fresh(int observedTic)
    {return level.time>=observedTic && level.time-observedTic<LIFETIME_SECONDS*TICRATE;}
}
