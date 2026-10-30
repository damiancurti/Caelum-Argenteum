// #426: calibración aprobada por el autor el 2026-10-30.
class CaelumNoiseData : Object
{
    enum Kind { STEP, FIREARM, EXPLOSION, MAGIC, IMPACT, SWING, DOOR, SHOUT }
    const REVISION=1;
    const OBSTACLE_FACTOR=0.25;
    const MAXIMUM_SUSPICION=50.0;
    const METAL_EQUIPMENT_FACTOR=1.5;

    static clearscope double MetersFor(int kind)
    {
        if(kind==FIREARM)return 160;
        if(kind==EXPLOSION)return 250;
        if(kind==MAGIC || kind==SHOUT)return 64;
        if(kind==IMPACT)return 16;
        if(kind==STEP)return CaelumConstants.MOVEMENT_NOISE_BASE_RANGE_MU/CaelumPhysicsUnits.MAP_UNITS_PER_METER;
        return 8;
    }

    static clearscope double TerrainFactor(Name terrain,bool shallow)
    {
        if(shallow || terrain=='CaelumPoolWater')return 1.25;
        if(terrain=='CaelumGrass' || terrain=='CaelumSoil')return 0.5;
        if(terrain=='CaelumMetal')return 1.5;
        return 1; // Piedra/madera y superficies aún sin una clasificación específica.
    }
}
