// Un único rayo por secuencia dirigida; conserva el objetivo original de El Mundo.
class CaelumMajorTargets : Object play
{
    static double Range(CaelumPlayer user)
    {
        return user!=null && user.DerivedStats!=null
            ? CaelumMajorArcanaData.TARGET_METERS*CaelumPhysicsUnits.MAP_UNITS_PER_METER
                *Max(0.0,user.DerivedStats.AbilityRangePercent)/100.0 : 0;
    }

    static Actor Aim(CaelumPlayer user)
    {
        if(user==null || user.player==null)return null;
        vector3 eye=CaelumTelekinesisRules.Eye(user);FLineTraceData hit;
        if(!user.LineTrace(user.Angle,Range(user),user.Pitch,
            TRF_ABSPOSITION|TRF_SOLIDACTORS,eye.Z,eye.X,eye.Y,hit))return null;
        return hit.HitActor;
    }

    static CaelumHostileMachine Machine(Actor hit)
    {
        if(hit==null)return null;
        if(hit is 'CaelumCannonBlock' || hit is 'CaelumRamBlock')hit=hit.master;
        return hit is 'CaelumCannon' || hit is 'CaelumBatteringRam'
            ? CaelumHostileMachine(hit) : null;
    }

    static bool Tower(Actor hit)
    {
        let machine=Machine(hit);
        return machine!=null && machine.DestroyByTarot();
    }
}
