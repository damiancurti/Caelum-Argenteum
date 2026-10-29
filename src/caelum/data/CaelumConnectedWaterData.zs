// #414: dimensiones, caudal y límites aprobados por el autor el 23/10/2026.
class CaelumConnectedWaterData : Object
{
    const REVISION = 1;
    const BASIN_AREA_M2 = 16.0;
    const BASIN_DEPTH_M = 2.0;
    const OPENING_DIAMETER_M = 0.20;
    const DISCHARGE_COEFFICIENT = 0.62;
    const INFLOW_LPS = 1.0;
    const DRAIN_LPS = 1.0;
    const INFLOW_HEIGHT_M = 1.75;
    const DRAIN_HEIGHT_M = 0.25;
    // Tolerancias numéricas; no añaden umbrales de potabilidad ni balance.
    const ERROR_L = 0.000001;
    const STEADY_LPS = 0.000000001;
    const HEIGHT_ROUNDOFF_M = 0.000000000001;
    const STEADY_SEARCH_LPS = 0.001;
    const MIN_STEP_SECONDS = 0.000001;
    const MAX_STEPS_PER_SYNC = 256;
    const PI = 3.141592653589793;
}
