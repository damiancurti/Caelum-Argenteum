// #252: datos del autor. El acumulador pertenece al sello, no a los atributos.
class CaelumSealClimateData : Object
{
    const REVISION=1;
    const FIRE_C=1.0;
    const AIR_KMH=2.0;
    const WATER_PERCENT=3.0;
    const EARTH_NEWTONS=1000.0;
    const QUAKE_INTENSITY=1.0;
    const GRAVITY_TICS=35;
}

// La traza nativa omite cuerpos móviles, pero conserva las paredes/pisos
// modelados con actores sólidos, además de la geometría de sectores.
class CaelumSealPath : LineTracer
{
    double Length;
    override ETraceStatus TraceCallback()
    {
        if(Results.Distance>=Length-0.0001)return TRACE_Skip;
        if(Results.HitType==TRACE_HitActor)
        {
            let body=Results.HitActor;
            if(body==null || !body.bSolid || body.player!=null || body is "CaelumCombatActor"
                || body is "Inventory" || body is "CaelumMovableProp")return TRACE_Skip;
        }
        return TRACE_Stop;
    }
}

class CaelumSealClimate : Object play
{
    static bool Active(CaelumChannelEffect effect)
    {
        if(effect==null || effect.bDestroyed || effect.ChannelOwner==null)return false;
        let user=effect.ChannelOwner;
        return user.health>0 && user.CombatChannelModeActive && effect.ChannelSeal!=null
            && effect.ChannelSeal.Equipped && user.GetEquippedSeal()==effect.ChannelSeal;
    }

    static bool ClearPath(CaelumChannelEffect effect,Actor body)
    {
        if(body==effect.ChannelOwner)return true;
        vector3 start=effect.ChannelOwner.Pos+(0,0,effect.ChannelOwner.Height*0.5);
        vector3 delta=body.Pos+(0,0,body.Height*0.5)-start;
        if(delta.Length()==0)return true;
        if(effect.ClimatePath==null)effect.ClimatePath=new("CaelumSealPath");
        effect.ClimatePath.Length=delta.Length();
        return !effect.ClimatePath.Trace(start,level.PointInSector(start.XY),delta/delta.Length(),
            delta.Length(),TRACE_PortalRestrict,Line.ML_BLOCKING|Line.ML_BLOCKEVERYTHING,
            false,effect.ChannelOwner);
    }

    static double,double,double,double Delta(Actor body,double baseWind,double baseDirection)
    {
        double heat=0,humidity=0,wind=0,direction=baseDirection;
        bool calm=baseWind<=0;
        // El iterador tipado recorre solamente sellos, nunca todos los cuerpos
        // por cada muestra térmica. La meteorología regional no se modifica.
        let it=ThinkerIterator.Create("CaelumChannelEffect");CaelumChannelEffect effect;
        while((effect=CaelumChannelEffect(it.Next()))!=null)
        {
            if(!Active(effect) || effect.ClimateTotal<=0
                || !effect.IsInside(body,effect.ChannelOwner.Pos,effect.EffectRadius)
                || !ClearPath(effect,body))continue;
            if(effect.SealType==CaelumConstants.SEAL_FIRE)
                heat+=effect.ClimateTotal*CaelumSealClimateData.FIRE_C;
            else if(effect.SealType==CaelumConstants.SEAL_WATER)
                humidity+=effect.ClimateTotal*CaelumSealClimateData.WATER_PERCENT;
            else if(effect.SealType==CaelumConstants.SEAL_AIR)
            {
                wind+=effect.ClimateTotal*CaelumSealClimateData.AIR_KMH;
                if(calm){direction=effect.CalmWindDirection;calm=false;}
            }
        }
        return heat,humidity,wind,direction;
    }

    static void ApplyWeather(Actor body,CaelumWeatherSample sample)
    {
        if(sample==null || !sample.Available)return;
        double heat,humidity,wind,direction;
        [heat,humidity,wind,direction]=Delta(body,sample.WindSpeedKmh,sample.WindFromDegrees);
        sample.AirTemperatureC+=heat;
        sample.RelativeHumidityPercent=Min(100.0,sample.RelativeHumidityPercent+humidity);
        sample.WindSpeedKmh+=wind;sample.WindFromDegrees=direction;
    }

    static void ApplyThermal(Actor body,CaelumThermalState thermal)
    {
        if(!thermal.Available || thermal.SealClimateRevision<CaelumSealClimateData.REVISION)return;
        double heat,humidity,wind,direction;
        [heat,humidity,wind,direction]=Delta(body,thermal.AmbientWindKmh,0);
        thermal.AirC=thermal.ClimateC=thermal.AmbientAirC+heat;
        thermal.Humidity=Min(100.0,thermal.AmbientHumidity+humidity);
        double exterior=(thermal.AmbientWindKmh+wind)/3.6;
        thermal.WindMps=Sqrt(exterior*exterior+thermal.LocalMotionMps*thermal.LocalMotionMps);
    }

    static bool Movable(Actor body)
    {
        let environment=CaelumEnvironmentProp(body);
        if(environment!=null)return environment.IsEnvironmentMovable();
        let prop=CaelumMovableProp(body);
        return prop!=null && prop.GetRequiredPhysicalPower()>0;
    }

    static bool EarthTarget(CaelumChannelEffect effect,Actor body)
    {
        return body!=null && body!=effect.ChannelOwner && body.Mass>0
            && (effect.IsAuthorizedTarget(body) || Movable(body))
            && !body.bNOGRAVITY && !body.bFly && body.WaterLevel<2
            && (body.Pos.Z<=body.FloorZ || body.bOnMobj)
            && effect.IsInside(body,effect.Pos,effect.EffectRadius) && ClearPath(effect,body);
    }

    static double Falloff(CaelumChannelEffect effect,Actor body)
    {
        return Clamp(1.0-(body.Pos+(0,0,body.Height*0.5)-effect.Pos).Length()
            /effect.EffectRadius,0.0,1.0);
    }

    static void PushEarth(CaelumChannelEffect effect,Actor body)
    {
        vector2 delta=body.Pos.XY-effect.Pos.XY;double distance=delta.Length();
        if(distance<=0 || effect.ClimatePower<=0)return;
        double force=CaelumSealClimateData.EARTH_NEWTONS*effect.ClimatePower*Falloff(effect,body);
        double step=force/Max(1.0,CaelumTelekinesisRules.MassKg(body))
            *CaelumPhysicsUnits.MAP_UNITS_PER_METER/(TICRATE*TICRATE);
        body.Vel.X+=delta.X/distance*step;body.Vel.Y+=delta.Y/distance*step;
    }

    static void DamageEarth(CaelumChannelEffect effect,Actor body)
    {
        if(body.health<=0)return;
        int damage=Max(0,int(effect.ClimatePower*CaelumTelekinesisRules.MassKg(body)
            *Falloff(effect,body)+0.5));
        if(damage>0)body.DamageMobj(effect,effect.ChannelOwner,damage,'CaelumEarthquake',
            DMG_NO_ARMOR|DMG_THRUSTLESS,0);
    }
}

// Un único dueño por cuerpo evita multiplicar/restaurar dos veces la gravedad
// cuando coinciden sellos. No escribe NOGRAVITY ni retira poderes de vuelo.
class CaelumSealGravity : Inventory
{
    int Revision,RemainingTics;
    double NormalGravity,Factor;
    Array<CaelumChannelEffect> Sources;

    static CaelumSealGravity Get(Actor body,bool create=false)
    {
        if(body==null)return null;
        let binding=CaelumSealGravity(body.FindInventory("CaelumSealGravity"));
        if(binding==null && create)
        {
            binding=CaelumSealGravity(body.GiveInventoryType("CaelumSealGravity"));
            if(binding!=null){binding.Revision=CaelumSealClimateData.REVISION;binding.NormalGravity=body.Gravity;binding.Factor=1;}
        }
        return binding;
    }

    void Apply()
    {
        if(Owner!=null)Owner.Gravity=Sources.Size()>0 ? 0
            : NormalGravity*(RemainingTics>0 ? Factor : 1.0);
    }

    void Hold(CaelumChannelEffect effect)
    {
        for(int i=0;i<Sources.Size();i++)if(Sources[i]==effect){Apply();return;}
        Sources.Push(effect);Apply();
    }

    void Release(CaelumChannelEffect effect)
    {
        for(int i=Sources.Size()-1;i>=0;i--)if(Sources[i]==effect)Sources.Delete(i);
        Apply();
    }

    void Amplify(double power)
    {
        Factor=RemainingTics>0 ? Max(Factor,power) : power;
        RemainingTics=Max(RemainingTics,CaelumSealClimateData.GRAVITY_TICS);Apply();
    }

    override void Tick()
    {
        Super.Tick();
        if(Owner==null){Destroy();return;}
        for(int i=Sources.Size()-1;i>=0;i--)
        {
            let source=Sources[i];
            if(!CaelumSealClimate.Active(source)
                || !source.IsInside(Owner,source.Pos,source.EffectRadius))Sources.Delete(i);
        }
        if(RemainingTics>0)RemainingTics--;
        Apply();
        if(Sources.Size()==0 && RemainingTics<=0)Destroy();
    }

    override void PreTravelled(){Sources.Clear();RemainingTics=0;Apply();}
    override void OnDestroy()
    {if(Owner!=null)Owner.Gravity=NormalGravity;Super.OnDestroy();}
    Default {Inventory.MaxAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE}
    States {Spawn:TNT1 A -1;Stop;}
}
