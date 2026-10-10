// #154: datos físicos aprobados. No alterar geometría ni acelerar el reloj
// mecánico con el calendario; los atributos modifican sólo sus consumidores.
class CaelumPhysicsUnits : Object
{
    const WORLD_GRAVITY_REVISION = 1;
    const PROJECTILE_GRAVITY_REVISION = 1;
    const MAP_UNITS_PER_METER = 32.0;
    const EARTH_GRAVITY_MPS2 = 9.81;
    const LEGACY_GRAVITY_ENGINE = 1.0;
    const EARTH_GRAVITY_ENGINE = EARTH_GRAVITY_MPS2*MAP_UNITS_PER_METER/(TICRATE*TICRATE);
    const GRAVITY_RATIO = EARTH_GRAVITY_ENGINE/LEGACY_GRAVITY_ENGINE;
    const WALK_METERS_PER_SECOND = 4.0;
    const RUN_METERS_PER_SECOND = 8.0;
    const JUMP_REFERENCE_MASS_KG = 80.0;
    const JUMP_REFERENCE_JOULES = 800.0;
    const JUMP_MASS_EXPONENT = 0.75;
    const BASE_MUSCULAR_EFFICIENCY = 0.25;
    const MAX_MUSCULAR_EFFICIENCY = 0.99;

    static clearscope double Meters(double mapUnits)
    { return mapUnits/MAP_UNITS_PER_METER; }
    static clearscope double MapUnits(double meters)
    { return meters*MAP_UNITS_PER_METER; }
    static clearscope double VelocitySI(double unitsPerTic)
    { return unitsPerTic*TICRATE/MAP_UNITS_PER_METER; }
    static clearscope double VelocityEngine(double metersPerSecond)
    { return metersPerSecond*MAP_UNITS_PER_METER/TICRATE; }
    static clearscope double AccelerationSI(double unitsPerTicSquared)
    { return unitsPerTicSquared*TICRATE*TICRATE/MAP_UNITS_PER_METER; }

    static clearscope double JumpWork(double biologicalMassKg,double agility)
    {
        return JUMP_REFERENCE_JOULES*(Max(0.0,biologicalMassKg)/JUMP_REFERENCE_MASS_KG)**JUMP_MASS_EXPONENT
            *CaelumGrowthRules.Multiplier(agility,3);
    }
    static clearscope double JumpVelocity(double biologicalMassKg,double totalMassKg,double agility)
    { return VelocityEngine(Sqrt(2.0*JumpWork(biologicalMassKg,agility)/Max(0.001,totalMassKg))); }

    static clearscope double MuscularEfficiency(double agility,double dexterity)
    {
        return Min(MAX_MUSCULAR_EFFICIENCY,BASE_MUSCULAR_EFFICIENCY
            *CaelumGrowthRules.Multiplier((agility+dexterity)/2.0));
    }
}
