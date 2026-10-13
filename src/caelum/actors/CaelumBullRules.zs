// #195: velocidad final y aceleración lineal aprobadas por el autor.
class CaelumBullRules : Object
{
    const REVISION=1;
    const MAX_SPEED_MPS=10.0;
    const ACCELERATION_MPS2=10.0;
    const HAZARD_PRESSURE_CUSHION_CAP=0.5;
    static clearscope double MaximumSpeed(){return CaelumPhysicsUnits.VelocityEngine(MAX_SPEED_MPS);}
    static clearscope double SpeedPerTic(){return CaelumPhysicsUnits.VelocityEngine(ACCELERATION_MPS2)/TICRATE;}
}
