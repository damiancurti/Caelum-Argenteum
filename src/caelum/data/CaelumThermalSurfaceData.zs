// #314: catálogo inicial aprobado el 19-10-2026; sólo la sala de prueba tiene
// ubicaciones diseñadas. Coeficiente y área son una aproximación jugable.
class CaelumThermalSurfaceData : Object
{
    const NONE=0;
    const ICE=1;
    const LAVA=2;
    const ICE_C=-40.0;
    const LAVA_C=1000.0;
    const CONTACT_CONDUCTANCE=CaelumThermalData.WATER_CONVECTION;
    static clearscope bool Valid(int kind){return kind==ICE || kind==LAVA;}
    static clearscope double Temperature(int kind){return kind==ICE ? ICE_C : LAVA_C;}
}
