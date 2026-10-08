// Perfil aprobado #135. Las subdivisiones son cuadratura, no más potencia.
class CaelumDemonBreathRules : Object
{
    const ANIMA_PER_SECOND=10.0;
    const RANGE_METERS=4.0;
    const CONE_DEGREES=60.0;
    // Boca del atlas de exhalación: altura/avance medidos en píxeles, antes
    // de la escala común de TEXTURES y de la escala individual del actor.
    const MANDINGA_MOUTH_PIXELS=160.0/0.980468750;
    const MANDINGA_MOUTH_FORWARD=60.0/0.980468750;
    const ZUPAY_MOUTH_PIXELS=147.0/0.600464191;
    const ZUPAY_MOUTH_FORWARD=70.0/0.600464191;
    const SEGMENTS=4;
    const FLAME_PIXEL_WIDTH=115.0;
    const FLAME_PIXEL_HEIGHT=188.0;
    static clearscope double Range(){return RANGE_METERS*CaelumJourneyRules.MAP_UNITS_PER_METER;}
    static clearscope double Watts(){return CaelumThermalData.FireWatts(3);}
}

class CaelumDemonFlameVisual : Actor
{
    Default { +NOINTERACTION +NOGRAVITY +BRIGHT RenderStyle "Add"; }
    States { Spawn: CEFB ABCDEFGHIJKL 3 Bright; Loop; }
}

class CaelumDemonBreath : Actor
{
    CaelumCombatActor Emitter;
    double PaidSeconds,TotalPaidSeconds;
    int NextHeatTic;
    Vector3 Direction;
    Actor FlameVisuals[4];

    Default { +NOBLOCKMAP +NOGRAVITY +NOCLIP +INVISIBLE Radius 1; Height 1; }
    States { Spawn: TNT1 A -1; Stop; }

    static Vector3 Mouth(Actor owner)
    {
        bool boss=owner is "CaelumZupayColossus";
        double height=owner.Scale.Y*(boss ? CaelumDemonBreathRules.ZUPAY_MOUTH_PIXELS : CaelumDemonBreathRules.MANDINGA_MOUTH_PIXELS);
        double forward=owner.Scale.X*(boss ? CaelumDemonBreathRules.ZUPAY_MOUTH_FORWARD : CaelumDemonBreathRules.MANDINGA_MOUTH_FORWARD);
        vector3 point=owner.Pos+(Cos(owner.Angle)*forward,Sin(owner.Angle)*forward,height);
        vector3 center=owner.Pos+(0,0,owner.Height/2),ray=point-center;
        FLineTraceData hit;
        // La cabeza dibujada puede adelantar el cilindro. Nunca se permite
        // que ese ancla salte a través de una pared junto al actor.
        if(owner.LineTrace(VectorAngle(ray.X,ray.Y),ray.Length(),-VectorAngle(ray.XY.Length(),ray.Z),
            TRF_THRUACTORS|TRF_ABSPOSITION,center.Z,center.X,center.Y,hit))return center;
        return point;
    }

    static bool CanReach(Actor owner,Actor victim)
    {
        vector3 delta=victim.Pos+(0,0,victim.Height/2)-Mouth(owner);
        return delta.Length()-victim.Radius<=CaelumDemonBreathRules.Range() && owner.CheckSight(victim);
    }

    bool Visible(Vector3 point)
    {
        vector3 ray=point-Pos;FLineTraceData hit;
        return !LineTrace(VectorAngle(ray.X,ray.Y),ray.Length(),-VectorAngle(ray.XY.Length(),ray.Z),
            TRF_THRUACTORS|TRF_ABSPOSITION,Pos.Z,Pos.X,Pos.Y,hit);
    }

    bool Contact(Actor body)
    {
        if(body==null || body==Emitter || body.health<=0)return false;
        vector2 horizontal=Pos.XY-body.Pos.XY;
        vector2 facing=horizontal.Length()>0 ? horizontal/horizontal.Length() : (1,0);
        // Se muestrea la cara del cilindro real: un centro fuera del cono
        // no excluye una pierna o un torso que sí toca la llama.
        for(int z=0;z<CaelumThermalData.FIRE_VISIBILITY_SAMPLES;z++)
        {
            vector3 point=body.Pos+(facing.X*body.Radius,facing.Y*body.Radius,
                body.Height*(z+0.5)/CaelumThermalData.FIRE_VISIBILITY_SAMPLES);
            vector3 ray=point-Pos;double distance=ray.Length();
            if(distance<=CaelumDemonBreathRules.Range() && (distance<=0
                || (ray dot Direction)/distance>=Cos(CaelumDemonBreathRules.CONE_DEGREES/2)) && Visible(point))return true;
        }
        return false;
    }

    void Burn(Actor body)
    {
        let user=CaelumPlayer(body);let npc=CaelumCombatActor(body);
        let status=user!=null ? user.ElementalStatus : npc!=null ? npc.ElementalStatus : null;
        if(status==null || Emitter==null)return;
        double scale=Emitter.CalculateActorType4Percent(Emitter.CombatCharisma)/100.0;
        int damage=Max(1,int(Emitter.GetTierOneMagicDamage(CaelumConstants.WEAPON_TYPE_STAFF)
            *CaelumConstants.ELEMENTAL_DOT_DAMAGE_RATIO*scale+0.5));
        // Refrescar contacto no reinicia el reloj: de lo contrario una llama
        // continua impediría para siempre alcanzar el pulso de un segundo.
        double clock=status.BurnRemaining>0 ? status.BurnTickAccumulator : 0;
        status.ApplyDamageOverTime(CaelumConstants.ELEMENTAL_EFFECT_BURN,
            CaelumConstants.ELEMENTAL_BASE_DURATION_SECONDS*scale,scale,damage,Emitter);
        status.BurnTickAccumulator=clock;
    }

    void PaidTick()
    {
        if(Emitter==null)return;
        // Contacto y coste siguen cada tic; la radiación usa la cadencia
        // térmica de un segundo, con fase repartida entre emisores.
        vector3 next=Mouth(Emitter);
        vector3 nextDirection=(Cos(Emitter.Angle),Sin(Emitter.Angle),0);
        if(Emitter.target!=null && CanReach(Emitter,Emitter.target))
        {
            vector3 aim=Emitter.target.Pos+(0,0,Emitter.target.Height/2)-next;
            if(aim.Length()>0)nextDirection=aim/aim.Length();
        }
        SetOrigin(next,false);Direction=nextDirection;
        if(NextHeatTic<=0)NextHeatTic=level.time+1+(Emitter.ThermalState!=null
            ? Emitter.ThermalState.NextUpdateTic%TICRATE : 0);
        PaidSeconds+=1.0/TICRATE;TotalPaidSeconds+=1.0/TICRATE;
        for(int i=0;i<CaelumDemonBreathRules.SEGMENTS;i++)
        {
            double along=CaelumDemonBreathRules.Range()*(i+0.5)/CaelumDemonBreathRules.SEGMENTS;
            vector3 point=Pos+Direction*along;
            if(!Visible(point))
            {if(FlameVisuals[i]!=null){FlameVisuals[i].Destroy();FlameVisuals[i]=null;}continue;}
            if(FlameVisuals[i]==null)FlameVisuals[i]=Spawn("CaelumDemonFlameVisual",point,NO_REPLACE);
            if(FlameVisuals[i]!=null)
            {
                double diameter=2*along*Tan(CaelumDemonBreathRules.CONE_DEGREES/2);
                // CEFB tiene pivote inferior y 115x188 píxeles. El volumen
                // visual se centra sobre el eje, no nace por encima de él.
                FlameVisuals[i].SetOrigin(point-(0,0,diameter/2),false);
                FlameVisuals[i].Scale=(diameter/CaelumDemonBreathRules.FLAME_PIXEL_WIDTH,
                    diameter/CaelumDemonBreathRules.FLAME_PIXEL_HEIGHT);
            }
        }
        let nearby=BlockThingsIterator.Create(Emitter,CaelumDemonBreathRules.Range()+Emitter.Radius);
        while(nearby.Next())if(Contact(nearby.thing))Burn(nearby.thing);
        if(level.time>=NextHeatTic){FlushHeat();NextHeatTic=level.time+TICRATE;}
    }

    double ReceivedWatts(Actor body,CaelumThermalState thermal)
    {
        double watts=0;
        for(int i=0;i<CaelumDemonBreathRules.SEGMENTS;i++)
        {
            double along=CaelumDemonBreathRules.Range()*(i+0.5)/CaelumDemonBreathRules.SEGMENTS;
            vector3 point=Pos+Direction*along;
            if(!Visible(point))continue;
            watts+=CaelumThermalFire.AbsorbedAt(body,thermal,self,point,
                CaelumDemonBreathRules.Watts()/CaelumDemonBreathRules.SEGMENTS,
                along*Tan(CaelumDemonBreathRules.CONE_DEGREES/2)/CaelumJourneyRules.MAP_UNITS_PER_METER);
        }
        return watts;
    }

    void FlushHeat()
    {
        double seconds=PaidSeconds;PaidSeconds=0;
        if(seconds<=0)return;
        Array<Actor> bodies;Array<double> watts;double sum=0;
        // No hay corte de distancia para radiación. Sólo se recorre al cerrar
        // el intervalo pagado o terminar, nunca por NPC inactivo.
        let search=ThinkerIterator.Create("Actor");Thinker entry;
        while((entry=search.Next())!=null)
        {
            let body=Actor(entry);
            if(body.health<=0 || !CaelumThermalBody.Supported(body))continue;
            let thermal=CaelumThermalBody.Get(body,true);
            if(thermal==null)continue;
            if(thermal.SurfaceArea<=0)CaelumThermalBody.Refresh(body,thermal);
            double value=ReceivedWatts(body,thermal);
            if(value<=0)continue;
            bodies.Push(body);watts.Push(value);sum+=value;
        }
        double budget=CaelumDemonBreathRules.Watts()*CaelumThermalData.FIRE_RADIATIVE_FRACTION;
        double scale=sum>budget ? budget/sum : 1;
        for(int i=0;i<bodies.Size();i++)
            CaelumThermalMagic.Continuous(bodies[i],watts[i]*scale,seconds);
    }

    override void Tick()
    {
        Super.Tick();
        if(Emitter==null || Emitter.health<=0 || Emitter.DemonBreath!=self)
        {FlushHeat();Destroy();}
    }

    override void OnDestroy()
    {
        for(int i=0;i<CaelumDemonBreathRules.SEGMENTS;i++)if(FlameVisuals[i]!=null)FlameVisuals[i].Destroy();
        Super.OnDestroy();
    }
}
