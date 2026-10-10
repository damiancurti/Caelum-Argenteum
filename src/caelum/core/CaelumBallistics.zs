// Solución de baja elevación una vez al disparar. La corrección discreta
// distingue Actor (mover, luego gravedad) de FastProjectile (gravedad, mover).
class CaelumBallistics : Object
{
    const ITERATIONS = 6;
    const EPSILON = 0.00000001;

    static clearscope vector3 Velocity(vector3 delta,double speed,double gravity,bool gravityFirst=false)
    {
        double horizontal=delta.XY.Length();
        if(speed<=0 || delta.Length()<=EPSILON)return (0,0,0);
        if(gravity<=EPSILON)return delta.Unit()*speed;
        double square=speed*speed;
        double discriminant=square*square-gravity*(gravity*horizontal*horizontal+2*delta.Z*square);
        if(discriminant<0)return (0,0,0);
        if(horizontal<=EPSILON)return (0,0,delta.Z>=0 ? speed : -speed);
        double tangent=(square-Sqrt(discriminant))/(gravity*horizontal);
        double time=horizontal*Sqrt(1+tangent*tangent)/speed;
        double sign=gravityFirst ? 1.0 : -1.0;
        for(int i=0;i<ITERATIONS;i++)
        {
            double rise=delta.Z+gravity*time*(time+sign)/2;
            double error=horizontal*horizontal+rise*rise-square*time*time;
            double slope=2*rise*gravity*(time+sign/2)-2*square*time;
            if(Abs(slope)<=EPSILON)break;
            time=Max(horizontal/speed,time-error/slope);
        }
        double vertical=delta.Z/time+gravity*(time+sign)/2;
        vector3 solution=(delta.X/time,delta.Y/time,vertical);
        if(Abs(solution.Length()-speed)>Max(EPSILON,speed*EPSILON))return (0,0,0);
        return solution;
    }

    static play bool AimProjectile(Actor projectile,vector3 targetPoint,double yawOffset=0,double pitchOffset=0,bool gravityFirst=false)
    {
        if(projectile==null)return false;
        double speed=projectile.Vel.Length();
        vector3 solution=Velocity(targetPoint-projectile.Pos,speed,projectile.GetGravity(),gravityFirst);
        // El blanco inalcanzable conserva el disparo directo anterior; no se
        // añade homing ni se altera la política de selección de enemigos.
        if(solution.Length()<=EPSILON)return false;
        double yaw=VectorAngle(solution.X,solution.Y)+yawOffset;
        double pitch=-VectorAngle(solution.XY.Length(),solution.Z)+pitchOffset;
        projectile.Angle=yaw;projectile.Pitch=pitch;
        vector3 direction=(Cos(pitch)*Cos(yaw),Cos(pitch)*Sin(yaw),-Sin(pitch));
        projectile.Vel=direction.Unit()*speed;
        return true;
    }
}
