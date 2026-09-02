// Estado elemental reutilizable para jugadores y actores. Mantener los
// temporizadores en un Object evita duplicar la lógica de prioridad.
class CaelumElementalStatus : Object
{
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

    void ApplyDamageOverTime(
        int effect,
        double duration,
        double power,
        int damagePerSecond,
        Actor source
    )
    {
        duration = Max(0.0, duration);
        power = Max(0.0, power);
        damagePerSecond = Max(1, damagePerSecond);
        if (effect == CaelumConstants.ELEMENTAL_EFFECT_BURN)
        {
            if (!ShouldReplace(power, duration, BurnPower, BurnRemaining))
            {
                return;
            }
            BurnRemaining = duration;
            BurnPower = power;
            BurnDamagePerSecond = damagePerSecond;
            BurnTickAccumulator = 0.0;
            BurnSource = source;
        }
        else if (effect == CaelumConstants.ELEMENTAL_EFFECT_CUT)
        {
            if (!ShouldReplace(power, duration, CutPower, CutRemaining))
            {
                return;
            }
            CutRemaining = duration;
            CutPower = power;
            CutDamagePerSecond = damagePerSecond;
            CutTickAccumulator = 0.0;
            CutSource = source;
        }
        else if (effect == CaelumConstants.ELEMENTAL_EFFECT_POISON)
        {
            if (!ShouldReplace(power, duration, PoisonPower, PoisonRemaining))
            {
                return;
            }
            PoisonRemaining = duration;
            PoisonPower = power;
            PoisonDamagePerSecond = damagePerSecond;
            PoisonTickAccumulator = 0.0;
            PoisonSource = source;
        }
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
    play void DealStatusDamage(Actor owner, Actor source, int damage)
    {
        if (owner == null || owner.health <= 0 || damage <= 0) { return; }
        owner.DamageMobj(
            null,
            source,
            damage,
            'CaelumElementalDOT',
            DMG_NO_ARMOR,
            0.0
        );
    }

    play void TickDamageOverTime(Actor owner)
    {
        double ticSeconds = 1.0 / TICRATE;
        if (BurnRemaining > 0.0)
        {
            BurnTickAccumulator += ticSeconds;
            if (BurnTickAccumulator >= 1.0)
            {
                BurnTickAccumulator -= 1.0;
                DealStatusDamage(owner, BurnSource, BurnDamagePerSecond);
            }
            BurnRemaining = Max(0.0, BurnRemaining - ticSeconds);
            if (BurnRemaining <= 0.0) { BurnPower = 0.0; }
        }
        if (CutRemaining > 0.0)
        {
            CutTickAccumulator += ticSeconds;
            if (CutTickAccumulator >= 1.0)
            {
                CutTickAccumulator -= 1.0;
                DealStatusDamage(owner, CutSource, CutDamagePerSecond);
            }
            CutRemaining = Max(0.0, CutRemaining - ticSeconds);
            if (CutRemaining <= 0.0) { CutPower = 0.0; }
        }
        if (PoisonRemaining > 0.0)
        {
            PoisonTickAccumulator += ticSeconds;
            if (PoisonTickAccumulator >= 1.0)
            {
                PoisonTickAccumulator -= 1.0;
                DealStatusDamage(owner, PoisonSource, PoisonDamagePerSecond);
            }
            PoisonRemaining = Max(0.0, PoisonRemaining - ticSeconds);
            if (PoisonRemaining <= 0.0) { PoisonPower = 0.0; }
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
            owner, BurnVisual, "CaelumBurnVisual", BurnRemaining > 0.0
        );
        PoisonVisual = UpdateVisual(
            owner, PoisonVisual, "CaelumPoisonVisual", PoisonRemaining > 0.0
        );
        FreezeVisual = UpdateVisual(
            owner, FreezeVisual, "CaelumFreezeVisual", FreezeRemaining > 0.0
        );
        LightningVisual = UpdateVisual(
            owner, LightningVisual, "CaelumLightningStatusVisual",
            LightningStunRemaining > 0.0
        );
    }

    play void Tick(Actor owner)
    {
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
