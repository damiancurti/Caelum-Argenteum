// Estado elemental reutilizable para jugadores y actores. Mantener los
// temporizadores en un Object evita duplicar la lógica de prioridad.
class CaelumElementalStatus : Object
{
    const BURN_HEAT_REVISION=1;
    int BurnHeatRevision;
    double BurnHeatWatts,BurnHeatRemaining,BurnHeatPower,PendingBurnHeatJoules;

    play void EnsureBurnHeat()
    {
        if(BurnHeatRevision>=BURN_HEAT_REVISION)return;
        // Un guardado anterior no conserva potencia absorbida de contacto.
        // No se inventa ni se repite calor ya integrado: empieza al próximo contacto.
        BurnHeatWatts=BurnHeatRemaining=BurnHeatPower=PendingBurnHeatJoules=0;
        BurnHeatRevision=BURN_HEAT_REVISION;
    }

    play void ClearBurnHeat()
    {
        EnsureBurnHeat();
        BurnHeatWatts=BurnHeatRemaining=BurnHeatPower=PendingBurnHeatJoules=0;
    }

    bool HasBurnHeat(){return BurnHeatRemaining>0 || PendingBurnHeatJoules>0;}

    play void ApplyBurnHeat(double duration,double power,double absorbedWatts)
    {
        EnsureBurnHeat();
        duration=Max(0.0,duration);power=Max(0.0,power);absorbedWatts=Max(0.0,absorbedWatts);
        if(duration<=0 || absorbedWatts<=0)return;
        // La misma prioridad no acumulativa del estado; Dureza sólo altera vida.
        if(!ShouldReplace(power,duration,BurnHeatPower,BurnHeatRemaining))return;
        BurnHeatRemaining=duration;BurnHeatPower=power;BurnHeatWatts=absorbedWatts;
    }

    play void TickBurnHeat(Actor owner)
    {
        EnsureBurnHeat();
        if(owner==null || owner.health<=0){ClearBurnHeat();return;}
        if(BurnHeatRemaining<=0)return;
        double step=Min(1.0/TICRATE,BurnHeatRemaining);
        // El receptor es el único dueño del calor. La integración térmica normal
        // consume estos julios, sin forzar NPCStep ni repetir armadura por tic.
        PendingBurnHeatJoules+=BurnHeatWatts*step;
        BurnHeatRemaining=Max(0.0,BurnHeatRemaining-step);
        if(BurnHeatRemaining<=0){BurnHeatWatts=0;BurnHeatPower=0;}
    }

    play double TakeBurnHeat()
    {
        EnsureBurnHeat();
        double joules=PendingBurnHeatJoules;PendingBurnHeatJoules=0;return joules;
    }

    double BurnRemaining;
    double BurnPower;
    int BurnDamagePerSecond;
    double BurnTickAccumulator;
    Actor BurnSource;

    double CutRemaining;
    double CutPower;
    int CutDamagePerSecond;
    double CutTickAccumulator;
    Actor CutSource;

    double PoisonRemaining;
    double PoisonPower;
    int PoisonDamagePerSecond;
    double PoisonTickAccumulator;
    Actor PoisonSource;

    // La dosis pendiente conserva progreso sin volver a escalar un guardado.
    int ToughnessRevision;
    double BaseRemaining[3];
    double ResponseFactors[3];
    double HealthFraction[3];
    double PulseSeconds[3];
    double BurnVisualRemaining,PoisonVisualRemaining;
    double DiseaseRemaining,DiseasePower,DiseaseTickAccumulator;
    int DiseaseDamagePerSecond;
    Actor DiseaseSource;

    double FreezeRemaining;
    double FreezePowerPercent;
    double DazzleRemaining;
    double DazzlePowerPercent;
    double EarthPenaltyRemaining;
    double EarthPenaltyPowerPercent;
    double LightningStunRemaining;

    Actor BurnVisual;
    Actor PoisonVisual;
    Actor FreezeVisual;
    Actor LightningVisual;

    bool ShouldReplace(
        double newPower,
        double newDuration,
        double currentPower,
        double currentRemaining
    )
    {
        if (newPower > currentPower + 0.0001) { return true; }
        if (newPower + 0.0001 < currentPower) { return false; }
        return newDuration > currentRemaining;
    }

    double GetRemaining(int index)
    {return index==0 ? BurnRemaining : index==1 ? PoisonRemaining : DiseaseRemaining;}

    void SetRemaining(int index,double seconds)
    {
        if(index==0)BurnRemaining=seconds;
        else if(index==1)PoisonRemaining=seconds;
        else DiseaseRemaining=seconds;
    }

    play void RefreshResistance(Actor receiver)
    {
        double response=CaelumToughnessRules.StatusResponse(CaelumToughnessRules.Effective(receiver));
        if(ToughnessRevision<CaelumToughnessRules.STATUS_REVISION)
        {
            // Los campos antiguos expresaban segundos sin resistencia. La
            // primera lectura los importa una sola vez; no cambia sus fuentes.
            BurnVisualRemaining=BurnRemaining;PoisonVisualRemaining=PoisonRemaining;
            HealthFraction[0]=BurnRemaining>0 ? BurnTickAccumulator*BurnDamagePerSecond*(response>0 ? 1 : response<0 ? -1 : 0) : 0;
            HealthFraction[1]=PoisonRemaining>0 ? PoisonTickAccumulator*PoisonDamagePerSecond*(response>0 ? 1 : response<0 ? -1 : 0) : 0;
            PulseSeconds[0]=BurnRemaining>0 ? BurnTickAccumulator : 0;
            PulseSeconds[1]=PoisonRemaining>0 ? PoisonTickAccumulator : 0;
            BurnTickAccumulator=0;PoisonTickAccumulator=0;
            for(int i=0;i<3;i++)
            {
                BaseRemaining[i]=GetRemaining(i);
                ResponseFactors[i]=response;
            }
            ToughnessRevision=CaelumToughnessRules.STATUS_REVISION;
        }
        for(int i=0;i<3;i++)
        {
            // La parte pendiente adopta el nuevo sentido al cambiar Dureza.
            if(response*ResponseFactors[i]<0)HealthFraction[i]=-HealthFraction[i];
            ResponseFactors[i]=response;
            if(response==0){BaseRemaining[i]=0;HealthFraction[i]=0;PulseSeconds[i]=0;}
            SetRemaining(i,BaseRemaining[i]*Abs(response));
        }
    }

    play void ApplyDamageOverTime(
        int effect,double duration,double power,int damagePerSecond,Actor source,Actor receiver
    )
    {
        RefreshResistance(receiver);
        duration=Max(0.0,duration);power=Max(0.0,power);damagePerSecond=Max(1,damagePerSecond);
        if(effect==CaelumConstants.ELEMENTAL_EFFECT_CUT)
        {
            if(!ShouldReplace(power,duration,CutPower,CutRemaining))return;
            CutRemaining=duration;CutPower=power;CutDamagePerSecond=damagePerSecond;
            CutTickAccumulator=0;CutSource=source;return;
        }
        int index=effect==CaelumConstants.ELEMENTAL_EFFECT_BURN ? 0
            : effect==CaelumConstants.ELEMENTAL_EFFECT_POISON ? 1
            : effect==CaelumConstants.ELEMENTAL_EFFECT_DISEASE ? 2 : -1;
        if(index<0)return;
        double previousPower=index==0 ? BurnPower : index==1 ? PoisonPower : DiseasePower;
        if(index==0 && ShouldReplace(power,duration,previousPower,BurnVisualRemaining))BurnVisualRemaining=duration;
        if(index==1 && ShouldReplace(power,duration,previousPower,PoisonVisualRemaining))PoisonVisualRemaining=duration;
        if(BaseRemaining[index]>0 && !ShouldReplace(power,duration,previousPower,BaseRemaining[index]))return;
        BaseRemaining[index]=ResponseFactors[index]!=0 ? duration : 0;
        SetRemaining(index,BaseRemaining[index]*Abs(ResponseFactors[index]));
        // Reaplicar nunca reinicia la fracción de vida ya devengada.
        if(index==0){BurnPower=power;BurnDamagePerSecond=damagePerSecond;BurnSource=source;}
        else if(index==1){PoisonPower=power;PoisonDamagePerSecond=damagePerSecond;PoisonSource=source;}
        else {DiseasePower=power;DiseaseDamagePerSecond=damagePerSecond;DiseaseSource=source;}
    }

    void ApplyControlEffect(int effect, double duration, double power)
    {
        duration = Max(0.0, duration);
        power = Max(0.0, power);
        if (effect == CaelumConstants.ELEMENTAL_EFFECT_FREEZE)
        {
            if (!ShouldReplace(
                power, duration, FreezePowerPercent, FreezeRemaining
            )) { return; }
            FreezeRemaining = duration;
            FreezePowerPercent = Clamp(power, 0.0, 100.0);
        }
        else if (effect == CaelumConstants.ELEMENTAL_EFFECT_DAZZLE)
        {
            if (!ShouldReplace(
                power, duration, DazzlePowerPercent, DazzleRemaining
            )) { return; }
            DazzleRemaining = duration;
            DazzlePowerPercent = Clamp(power, 0.0, 100.0);
        }
        else if (effect == CaelumConstants.ELEMENTAL_EFFECT_LIGHTNING_STUN)
        {
            if (duration > LightningStunRemaining)
            {
                LightningStunRemaining = duration;
            }
        }
    }

    // La penalización del Sello de Tierra es mecánica, no Congelación: no
    // activa el estado ni el visual de Hielo y conserva su caída radial.
    void ApplyEarthPenalty(double duration, double power)
    {
        duration = Max(0.0, duration);
        power = Clamp(power, 0.0, 100.0);
        if (!ShouldReplace(
            power, duration, EarthPenaltyPowerPercent, EarthPenaltyRemaining
        )) { return; }
        EarthPenaltyRemaining = duration;
        EarthPenaltyPowerPercent = power;
    }

    // DamageMobj pertenece al alcance jugable del motor. Declarar toda la
    // cadena de actualización como play evita que Object la ejecute desde
    // el alcance de datos en GZDoom 4.14.2.
    play void DealStatusDamage(Actor owner, Actor source, int damage, int visualKind=-1)
    {
        if (owner == null || owner.health <= 0 || damage <= 0) { return; }
        if(visualKind==0)CaelumBolas.FireContact(owner);
        let user=CaelumPlayer(owner);
        int previous=user!=null ? user.PendingDamageVFXKind : 0;
        if(user!=null)user.PendingDamageVFXKind=visualKind+1;
        owner.DamageMobj(
            null,
            source,
            damage,
            'CaelumElementalDOT',
            DMG_NO_ARMOR,
            0.0
        );
        if(user!=null)user.PendingDamageVFXKind=previous;
    }

    play void HealStatus(Actor owner,int amount)
    {
        if(owner==null || owner.health<=0 || amount<=0)return;
        let user=CaelumPlayer(owner);let npc=CaelumCombatActor(owner);
        int maximum=user!=null ? user.CaelumMaximumHealth : npc!=null ? npc.CombatMaximumHealth : owner.GetMaxHealth();
        owner.health=Min(maximum,owner.health+amount);
        if(user!=null){user.player.health=user.health;user.UpdateHealthStateEffects();}
        else if(npc!=null)npc.UpdateCombatHealthEffects();
    }

    play void TickResistantEffect(Actor owner,int index,double ticSeconds)
    {
        double remaining=GetRemaining(index),response=ResponseFactors[index];
        if(remaining<=0 || response==0)return;
        double step=Min(ticSeconds,remaining);
        int rate=index==0 ? BurnDamagePerSecond : index==1 ? PoisonDamagePerSecond : DiseaseDamagePerSecond;
        Actor source=index==0 ? BurnSource : index==1 ? PoisonSource : DiseaseSource;
        // El sello reduce sólo la dosis dañina, antes del acumulador existente.
        // Los restos ya devengados, duración, curación y calor no se reescalan.
        int essence=index==0 ? CaelumConstants.ESSENCE_FIRE
            : index==1 ? CaelumConstants.ESSENCE_EARTH : -1;
        double sealFactor=response>0 ? CaelumSealResistance.ForEssence(owner,essence) : 1;
        HealthFraction[index]+=step*rate*(response>0 ? sealFactor : -1);
        PulseSeconds[index]+=step;
        bool deliver=PulseSeconds[index]+0.0000001>=1 || step+0.0000001>=remaining;
        int whole=deliver ? (HealthFraction[index]>=0 ? int(HealthFraction[index]+0.0000001)
            : -int(-HealthFraction[index]+0.0000001)) : 0;
        if(deliver)PulseSeconds[index]=Max(0,PulseSeconds[index]-1);
        if(whole>0)DealStatusDamage(owner,source,whole,index==0 ? 0 : index==1 ? 5 : -1);
        else if(whole<0)HealStatus(owner,-whole);
        HealthFraction[index]-=whole;
        if(response<0)
        {
            let user=CaelumPlayer(owner);let npc=CaelumCombatActor(owner);
            int maximum=user!=null ? user.CaelumMaximumHealth : npc!=null ? npc.CombatMaximumHealth : owner.GetMaxHealth();
            if(owner.health>=maximum && HealthFraction[index]<0)HealthFraction[index]=0;
        }
        BaseRemaining[index]=Max(0.0,BaseRemaining[index]-step/Abs(response));
        SetRemaining(index,BaseRemaining[index]*Abs(response));
        if(GetRemaining(index)<0.0000001){BaseRemaining[index]=0;SetRemaining(index,0);PulseSeconds[index]=0;}
    }

    play void TickDamageOverTime(Actor owner)
    {
        RefreshResistance(owner);
        double ticSeconds=1.0/TICRATE;
        for(int i=0;i<3;i++)TickResistantEffect(owner,i,ticSeconds);
        BurnVisualRemaining=Max(0.0,BurnVisualRemaining-ticSeconds);
        PoisonVisualRemaining=Max(0.0,PoisonVisualRemaining-ticSeconds);
        if(BurnRemaining<=0)BurnPower=0;
        if(PoisonRemaining<=0)PoisonPower=0;
        if(DiseaseRemaining<=0)DiseasePower=0;
        if(CutRemaining>0)
        {
            CutTickAccumulator+=ticSeconds;
            if(CutTickAccumulator>=1.0)
            {CutTickAccumulator-=1.0;DealStatusDamage(owner,CutSource,CutDamagePerSecond);}
            CutRemaining=Max(0.0,CutRemaining-ticSeconds);
            if(CutRemaining<=0)CutPower=0;
        }
    }

    play Actor UpdateVisual(
        Actor owner,
        Actor visual,
        class<Actor> visualClass,
        bool active
    )
    {
        if (!active || owner == null || owner.health <= 0)
        {
            if (visual != null)
            {
                visual.A_StopSound(CHAN_BODY);
                visual.Destroy();
            }
            return null;
        }
        if (visual == null)
        {
            visual = Actor.Spawn(visualClass, owner.Pos, ALLOW_REPLACE);
            if (visual != null) { visual.master = owner; }
        }
        return visual;
    }

    play void UpdateVisualEffects(Actor owner)
    {
        BurnVisual = UpdateVisual(
            owner, BurnVisual, "CaelumBurnVisual", BurnVisualRemaining > 0.0 || BurnHeatRemaining > 0.0
        );
        PoisonVisual = UpdateVisual(
            owner, PoisonVisual, "CaelumPoisonVisual", PoisonVisualRemaining > 0.0
        );
        FreezeVisual = UpdateVisual(
            owner, FreezeVisual, "CaelumFreezeVisual", FreezeRemaining > 0.0
        );
        LightningVisual = UpdateVisual(
            owner, LightningVisual, "CaelumLightningStatusVisual",
            LightningStunRemaining > 0.0
        );
    }

    play void Tick(Actor owner,bool realStep=true)
    {
        if(realStep)TickBurnHeat(owner);
        TickDamageOverTime(owner);
        double ticSeconds = 1.0 / TICRATE;
        FreezeRemaining = Max(0.0, FreezeRemaining - ticSeconds);
        DazzleRemaining = Max(0.0, DazzleRemaining - ticSeconds);
        EarthPenaltyRemaining = Max(
            0.0, EarthPenaltyRemaining - ticSeconds
        );
        LightningStunRemaining = Max(
            0.0, LightningStunRemaining - ticSeconds
        );
        if (FreezeRemaining <= 0.0) { FreezePowerPercent = 0.0; }
        if (DazzleRemaining <= 0.0) { DazzlePowerPercent = 0.0; }
        if (EarthPenaltyRemaining <= 0.0)
            EarthPenaltyPowerPercent = 0.0;
        UpdateVisualEffects(owner);
    }

    double GetMovementMultiplier()
    {
        double freezeMultiplier = FreezeRemaining > 0.0
            ? 1.0 - FreezePowerPercent / 100.0 : 1.0;
        double earthMultiplier = EarthPenaltyRemaining > 0.0
            ? 1.0 - EarthPenaltyPowerPercent / 100.0 : 1.0;
        return Min(freezeMultiplier, earthMultiplier);
    }

    double GetAccuracyMultiplier()
    {
        double dazzleMultiplier = DazzleRemaining > 0.0
            ? 1.0 - DazzlePowerPercent / 100.0 : 1.0;
        double earthMultiplier = EarthPenaltyRemaining > 0.0
            ? 1.0 - EarthPenaltyPowerPercent / 100.0 : 1.0;
        return Min(dazzleMultiplier, earthMultiplier);
    }

    bool IsLightningStunned()
    {
        return LightningStunRemaining > 0.0;
    }
}
