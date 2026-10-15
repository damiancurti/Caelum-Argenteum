// Geometría y transferencia compartidas con el aliento aprobado #135.
// El signo cambia el flujo térmico; jamás convierte julios en daño de salud.
class CaelumElementalStream : Object play
{
    static bool Visible(Actor source, Vector3 point)
    {
        vector3 ray=point-source.Pos; FLineTraceData hit;
        return !source.LineTrace(VectorAngle(ray.X,ray.Y),ray.Length(),
            -VectorAngle(ray.XY.Length(),ray.Z),TRF_THRUACTORS|TRF_ABSPOSITION,
            source.Pos.Z,source.Pos.X,source.Pos.Y,hit);
    }

    static bool Contact(Actor source,Actor emitter,Vector3 direction,Actor body)
    {
        if(body==null || body==emitter || body.health<=0)return false;
        vector2 horizontal=source.Pos.XY-body.Pos.XY;
        vector2 facing=horizontal.Length()>0 ? horizontal/horizontal.Length() : (1,0);
        for(int z=0;z<CaelumThermalData.FIRE_VISIBILITY_SAMPLES;z++)
        {
            vector3 point=body.Pos+(facing.X*body.Radius,facing.Y*body.Radius,
                body.Height*(z+0.5)/CaelumThermalData.FIRE_VISIBILITY_SAMPLES);
            vector3 ray=point-source.Pos; double distance=ray.Length();
            if(distance<=CaelumDemonBreathRules.Range() && (distance<=0
                || (ray dot direction)/distance>=Cos(CaelumDemonBreathRules.CONE_DEGREES/2))
                && Visible(source,point))return true;
        }
        return false;
    }

    static CaelumElementalStatus Status(Actor body)
    {
        let user=CaelumPlayer(body); let npc=CaelumCombatActor(body);
        return user!=null ? user.ElementalStatus : npc!=null ? npc.ElementalStatus : null;
    }

    static double Power(Actor emitter)
    {
        let user=CaelumPlayer(emitter); let npc=CaelumCombatActor(emitter);
        return user!=null && user.DerivedStats!=null ? user.DerivedStats.DebuffPowerPercent/100.0
            : npc!=null ? npc.CalculateActorType4Percent(npc.CombatCharisma)/100.0 : 0;
    }

    static int Damage(Actor emitter)
    {
        let user=CaelumPlayer(emitter); let npc=CaelumCombatActor(emitter);
        return user!=null && user.DerivedStats!=null
            ? Max(1,int(user.DerivedStats.DebugStaffDamage*user.EffectiveOffensiveDamageMultiplier+0.5))
            : npc!=null ? Max(1,int(npc.GetTierOneMagicDamage(CaelumConstants.WEAPON_TYPE_STAFF)
                *CaelumPersonalityRules.MagicPower(npc.CombatPersonality)+0.5)) : 0;
    }

    static void ApplyContact(Actor emitter,Actor body,bool ice=false)
    {
        let summoned=CaelumSummonedZupay(emitter);
        if(summoned!=null && !summoned.CanAffect(body))return;
        if(!CaelumRedemption.AllowsDamage(emitter,body))return;
        let status=Status(body);
        if(status==null || emitter==null)return;
        double power=Power(emitter);
        if(ice)
        {
            status.ApplyControlEffect(CaelumConstants.ELEMENTAL_EFFECT_FREEZE,
                CaelumConstants.ELEMENTAL_BASE_DURATION_SECONDS*power,
                CaelumConstants.ELEMENTAL_BASE_CONTROL_POWER_PERCENT*power);
            return;
        }
        CaelumBolas.FireContact(body);
        int damage=Max(1,int(Damage(emitter)*CaelumConstants.ELEMENTAL_DOT_DAMAGE_RATIO*power+0.5));
        // El procesador conserva la fracción de vida entre contactos.
        status.ApplyDamageOverTime(CaelumConstants.ELEMENTAL_EFFECT_BURN,
            CaelumConstants.ELEMENTAL_BASE_DURATION_SECONDS*power,power,damage,emitter,body);
    }

    static double ThermalPowerFactor(Actor source)
    {
        let stream=CaelumUtilityStaffStream(source);
        return stream!=null ? CaelumPersonalityRules.MagicPower(CaelumPersonalityRules.Profile(stream.Emitter)) : 1;
    }

    static double ReceivedWatts(Actor source,Vector3 direction,Actor body,CaelumThermalState thermal)
    {
        double watts=0;
        for(int i=0;i<CaelumDemonBreathRules.SEGMENTS;i++)
        {
            double along=CaelumDemonBreathRules.Range()*(i+0.5)/CaelumDemonBreathRules.SEGMENTS;
            vector3 point=source.Pos+direction*along;
            if(!Visible(source,point))continue;
            watts+=CaelumThermalFire.AbsorbedAt(body,thermal,source,point,
                CaelumDemonBreathRules.Watts()*ThermalPowerFactor(source)/CaelumDemonBreathRules.SEGMENTS,
                along*Tan(CaelumDemonBreathRules.CONE_DEGREES/2)/CaelumJourneyRules.MAP_UNITS_PER_METER);
        }
        return watts;
    }

    static void Transfer(Actor source,Vector3 direction,double seconds,bool ice=false)
    {
        if(seconds<=0)return;
        Array<Actor> bodies; Array<double> watts; double sum=0;
        let search=ThinkerIterator.Create("Actor"); Thinker entry;
        while((entry=search.Next())!=null)
        {
            let body=Actor(entry);
            let breath=CaelumDemonBreath(source);
            let summoned=breath!=null?CaelumSummonedZupay(breath.Emitter):null;
            if(summoned!=null && !summoned.CanAffect(body))continue;
            if(breath!=null && !CaelumRedemption.AllowsDamage(breath.Emitter,body))continue;
            if(body.health<=0 || !CaelumThermalBody.Supported(body))continue;
            let thermal=CaelumThermalBody.Get(body,true);
            if(thermal==null)continue;
            if(thermal.SurfaceArea<=0)CaelumThermalBody.Refresh(body,thermal);
            double value=ReceivedWatts(source,direction,body,thermal);
            if(value<=0)continue;
            bodies.Push(body); watts.Push(value); sum+=value;
        }
        double budget=CaelumDemonBreathRules.Watts()*ThermalPowerFactor(source)*CaelumThermalData.FIRE_RADIATIVE_FRACTION;
        double scale=sum>budget ? budget/sum : 1;
        for(int i=0;i<bodies.Size();i++)
            CaelumThermalMagic.Continuous(bodies[i],watts[i]*scale*(ice ? -1 : 1),seconds);
    }
}
