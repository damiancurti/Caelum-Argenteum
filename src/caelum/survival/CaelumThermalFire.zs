// Fuente optativa de mapa. args: perfil 1..4, radio y altura de llama en MU.
// Sin las tres magnitudes declaradas no se inventa potencia desde el sprite.
class CaelumThermalFireSource : Actor
{
    Default
    {
        +NOBLOCKMAP
        +NOGRAVITY
        +NOCLIP
        +INVISIBLE
        Radius 1;
        Height 1;
    }
    double Watts()
    {
        if(args[0]<1 || args[0]>4 || args[1]<=0 || args[2]<=0)return 0;
        return CaelumThermalData.FireWatts(args[0]);
    }
    States { Spawn: TNT1 A -1; Stop; }
}

class CaelumThermalFire : Object play
{
    static double Absorbed(Actor body,CaelumThermalState thermal,CaelumThermalFireSource source)
    {
        if(source==null || source.Watts()<=0)return 0;
        double units=CaelumJourneyRules.MAP_UNITS_PER_METER;
        vector3 origin=source.Pos+(0,0,source.args[2]/2.0);
        vector3 center=body.Pos+(0,0,body.Height/2);
        vector3 offset=origin-center;
        double distance=offset.Length();
        double horizontal=offset.XY.Length();
        double sinAngle=distance>0 ? horizontal/distance : 1;
        double cosAngle=distance>0 ? Abs(offset.Z)/distance : 0;
        double r=body.Radius/units,h=body.Height/units;
        double cylinderArea=2*CaelumThermalData.CIRCLE_PI*r*(r+h);
        if(cylinderArea<=0)return 0;
        double projected=(2*r*h*sinAngle+CaelumThermalData.CIRCLE_PI*r*r*cosAngle)
            *thermal.SurfaceArea/cylinderArea;
        vector2 facing=horizontal>0 ? offset.XY/horizontal : (1,0);
        vector2 lateral=(-facing.Y,facing.X);
        int visible=0;
        int count=CaelumThermalData.FIRE_VISIBILITY_SAMPLES;
        for(int z=0;z<count;z++)for(int side=0;side<count;side++)
        {
            double across=(2.0*(side+0.5)/count-1)*body.Radius;
            vector2 point=body.Pos.XY+lateral*across+facing*Sqrt(Max(0.0,body.Radius*body.Radius-across*across));
            vector3 targetPoint=(point.X,point.Y,body.Pos.Z+body.Height*(z+0.5)/count);
            vector3 ray=targetPoint-origin;
            FLineTraceData hit;
            if(!source.LineTrace(VectorAngle(ray.X,ray.Y),ray.Length(),-VectorAngle(ray.XY.Length(),ray.Z),
                TRF_THRUACTORS|TRF_ABSPOSITION,origin.Z,origin.X,origin.Y,hit))visible++;
        }
        double sourceRadius=Max(source.args[1],source.args[2]/2.0)/units;
        return CaelumThermalRules.FireFlux(source.Watts(),distance/units,sourceRadius)
            *projected*visible/(count*count)*CaelumThermalData.FIRE_ABSORPTIVITY;
    }

    static double Sample(Actor body,CaelumThermalState thermal)
    {
        let world=CaelumThermalWorld.Get();
        if(world==null)return 0;
        double watts=0;
        // Lista compartida sólo de fuentes declaradas; nunca un barrido de
        // todos los combatientes por cada receptor ni un corte térmico oculto.
        for(int i=0;i<world.FireSources.Size();i++)watts+=Absorbed(body,thermal,world.FireSources[i]);
        return watts;
    }
}
