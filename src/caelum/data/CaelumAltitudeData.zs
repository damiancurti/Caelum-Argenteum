// #413: calibración autoral y atmósfera estándar de NASA Glenn, unidades SI.
class CaelumAltitudeData : Object
{
    const REVISION = 1;
    const ADAPT_DAYS = 5.0;
    const DECAY_DAYS = 14.0;
    const MAX_COMPENSATION = 0.25;
    const CAELITH_PENALTY = 0.5;
    const TROPOSPHERE_TOP_M = 11000.0;
    const LOWER_STRATOSPHERE_TOP_M = 25000.0;
    const SEA_TEMPERATURE_C = 15.04;
    const TROPOSPHERE_LAPSE_C_PER_M = 0.00649;
    const SEA_PRESSURE_KPA = 101.29;
    const KELVIN_OFFSET = 273.1;
    const REFERENCE_TEMPERATURE_K = 288.08;
    const TROPOSPHERE_EXPONENT = 5.256;
    const STRATOSPHERE_PRESSURE_KPA = 22.65;
    const STRATOSPHERE_EXPONENT_OFFSET = 1.73;
    const STRATOSPHERE_EXPONENT_PER_M = 0.000157;
    const UPPER_TEMPERATURE_OFFSET_C = -131.21;
    const UPPER_LAPSE_C_PER_M = 0.00299;
    const UPPER_PRESSURE_KPA = 2.488;
    const UPPER_REFERENCE_K = 216.6;
    const UPPER_EXPONENT = -11.388;

    static clearscope bool NeutralAtmosphere(String mapName)
    { return CaelumWorldCatalogue.IsLimboMap(mapName); }
}
