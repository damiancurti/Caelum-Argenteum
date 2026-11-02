// #241: datos aprobados; las conversiones físicas siguen la escala común SI.
class CaelumTelekinesisRules : Object play
{
    const REVISION=1;
    const FORCE_NEWTONS=1000.0;
    const ANIMA_PER_KG_SECOND=1.0;

    static Vector3 Eye(CaelumPlayer user)
    {return user.Pos+(0,0,user.player.viewheight);}

    static double Range(CaelumPlayer user)
    {return CaelumConstants.SEAL_CHANNEL_BASE_RADIUS*user.DerivedStats.AbilityRangePercent/100.0;}

    static double MassKg(Actor body)
    {
        // La masa virtual de un escudo sólo pertenece al choque, no al peso.
        let user=CaelumPlayer(body);let npc=CaelumCombatActor(body);
        return user!=null && user.DerivedStats!=null ? user.DerivedStats.TotalMass
            : npc!=null ? double(npc.Mass)+Max(0.0,npc.GetAttackCarriedWeight())
            : double(body.Mass);
    }

    static CaelumTelekinesisEffect Binding(Actor body)
    {
        let user=CaelumPlayer(body);let npc=CaelumCombatActor(body);let prop=CaelumMovableProp(body);
        return user!=null?user.TelekinesisBinding:npc!=null?npc.TelekinesisBinding
            :prop!=null?prop.TelekinesisBinding:null;
    }

    static bool Held(Actor body)
    {
        let effect=Binding(body);
        return effect!=null && effect.Body==body && effect.Caster!=null
            && effect.Caster.RacialAbility==effect && effect.Caster.RacialAbilityActive
            && effect.MapName==level.MapName && body.health>0;
    }

    static void Bind(Actor body,CaelumTelekinesisEffect effect)
    {
        let user=CaelumPlayer(body);let npc=CaelumCombatActor(body);let prop=CaelumMovableProp(body);
        if(user!=null)user.TelekinesisBinding=effect;
        else if(npc!=null)npc.TelekinesisBinding=effect;
        else if(prop!=null)prop.TelekinesisBinding=effect;
    }

    static bool Eligible(CaelumPlayer user,Actor body)
    {
        if(body==null || body==user || body.health<=0 || body.bDORMANT
            || body.bNOCLIP || body.bNOINTERACTION || MassKg(body)<=0)return false;
        if(body is "CaelumPlayer" || body is "CaelumCombatActor")return body.bSHOOTABLE;
        let prop=CaelumMovableProp(body);
        if(prop!=null && prop.TarotLift!=null)return false;
        let environment=CaelumEnvironmentProp(body);
        if(environment!=null)return environment.IsEnvironmentMovable();
        return prop!=null && prop.GetRequiredPhysicalPower()>0;
    }

    static void Physics(Actor body)
    {
        if(!Held(body))return;
        let effect=Binding(body);
        // La comprobación precede al impulso, aunque el blanco piense primero.
        CaelumRacialAbilityRules.Guard(effect.Caster);
        if(Held(body))effect.MoveBody();
    }
}

class CaelumTelekinesisEffect : CaelumRacialAbilityEffect
{
    int HoldRevision;
    CaelumPlayer Caster;
    Actor Body;
    String MapName;
    Vector3 GrabOffset;
    double CaptureDistance;

    override bool CanStart(CaelumPlayer user)
    {
        if(CaelumBattleCry.Active(user))return false;
        vector3 eye=CaelumTelekinesisRules.Eye(user);FLineTraceData hit;
        if(!user.LineTrace(user.Angle,CaelumTelekinesisRules.Range(user),user.Pitch,
            TRF_ABSPOSITION|TRF_SOLIDACTORS,eye.Z,eye.X,eye.Y,hit)
            || !CaelumTelekinesisRules.Eligible(user,hit.HitActor)
            || CaelumTelekinesisRules.Held(hit.HitActor))
        {CaelumNotifications.Notify(user,StringTable.Localize("CA_TELEKINESIS_TARGET",false));return false;}
        Caster=user;Body=hit.HitActor;MapName=level.MapName;
        HoldRevision=CaelumTelekinesisRules.REVISION;
        GrabOffset=hit.HitLocation-Body.Pos;
        CaptureDistance=(hit.HitLocation-eye).Length();
        return true;
    }

    override bool CanContinue(CaelumPlayer user)
    {
        if(CaelumBattleCry.Active(user))return false;
        if(Caster!=user || MapName!=level.MapName || HoldRevision!=CaelumTelekinesisRules.REVISION
            || !CaelumTelekinesisRules.Eligible(user,Body))return false;
        let other=CaelumTelekinesisRules.Binding(Body);
        if(other!=null && other!=self && CaelumTelekinesisRules.Held(Body))return false;
        vector3 eye=CaelumTelekinesisRules.Eye(user);
        vector3 ray=Body.Pos+GrabOffset-eye;
        if(ray.Length()>CaelumTelekinesisRules.Range(user))return false;
        FLineTraceData hit;
        return !user.LineTrace(VectorAngle(ray.X,ray.Y),ray.Length(),
            -VectorAngle(ray.XY.Length(),ray.Z),TRF_ABSPOSITION|TRF_THRUACTORS,
            eye.Z,eye.X,eye.Y,hit);
    }

    override double BaseAnimaPerSecond(CaelumPlayer user)
    {return Body==null?0:CaelumTelekinesisRules.MassKg(Body)*CaelumTelekinesisRules.ANIMA_PER_KG_SECOND;}

    override void Started(CaelumPlayer user)
    {
        CaelumTelekinesisRules.Bind(Body,self);
        let victim=CaelumPlayer(Body);let npc=CaelumCombatActor(Body);
        if(victim!=null)
        {
            CaelumClassAbilityRules.Cancel(victim);CaelumRacialAbilityRules.Deactivate(victim);
            victim.StopSealChannel(true);victim.CancelCombatBlockMode();
            victim.CancelRangedAim();victim.CancelRangedReload();victim.CancelWeaponCharge();
        }
        if(npc!=null)CaelumDemonService.StopBreath(npc);
    }

    override void Stopped(CaelumPlayer user)
    {
        if(Body!=null && CaelumTelekinesisRules.Binding(Body)==self)
            CaelumTelekinesisRules.Bind(Body,null);
        // Nunca se cambiaron gravedad, colisión, identidad ni velocidad al soltar.
        Body=null;Caster=null;
    }

    void MoveBody()
    {
        vector3 forward=(Cos(Caster.Pitch)*Cos(Caster.Angle),Cos(Caster.Pitch)*Sin(Caster.Angle),-Sin(Caster.Pitch));
        vector3 error=CaelumTelekinesisRules.Eye(Caster)+forward*CaptureDistance-GrabOffset-Body.Pos;
        double acceleration=CaelumTelekinesisRules.FORCE_NEWTONS*Caster.DerivedStats.MagicalPowerMultiplier
            /CaelumTelekinesisRules.MassKg(Body)*CaelumPhysicsUnits.MAP_UNITS_PER_METER/(TICRATE*TICRATE);
        if(acceleration<=0)return;
        // Frenado cinemático v²=2ad: sin velocidad arbitraria ni teletransporte.
        // Se limita el cambio vectorial completo a F/m por tic. El motor conserva
        // gravedad y rozamiento; si F no sostiene el peso, el cuerpo cae.
        double distance=error.Length();
        vector3 desired=distance>0 ? error.Unit()*Min(distance,Sqrt(2*acceleration*distance)) : (0,0,0);
        vector3 impulse=desired-Body.Vel;
        if(impulse.Length()>acceleration)impulse=impulse.Unit()*acceleration;
        Body.Vel+=impulse;
    }
}
