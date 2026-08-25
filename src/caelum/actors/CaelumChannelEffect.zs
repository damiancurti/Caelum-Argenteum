// Actor central de la Canalizacion mediante Sello. No colisiona ni participa
// en la arquitectura: selecciona combatientes, cadaveres y proyectiles.
class CaelumChannelEffect : Actor
{
    CaelumPlayer ChannelOwner;
    int SealType;
    int SealTier;
    double EffectRadius;
    double PulseAccumulator;
    double TrappedMass;

    Default
    {
        +NOBLOCKMAP
        +NOSECTOR
        +NOGRAVITY
        +NOCLIP
        +INVISIBLE
        Radius 1;
        Height 1;
    }

    void ConfigureChannel(CaelumPlayer owner, int sealType,
        int sealTier, double radius)
    {
        ChannelOwner = owner;
        Target = owner;
        SealType = Clamp(sealType, 0, CaelumConstants.SEAL_TYPE_COUNT - 1);
        SealTier = Clamp(sealTier, 1, 3);
        EffectRadius = Max(1.0, radius);
        PulseAccumulator = 0.0;
        TrappedMass = 0.0;
    }

    bool IsAuthorizedTarget(Actor candidate)
    {
        if (candidate == null || candidate == self || candidate == ChannelOwner
            || Inventory(candidate) != null) return false;
        // Las estaciones, puertas, pickups y arquitectura no cumplen esto.
        return candidate.bMISSILE || candidate.bSHOOTABLE || candidate.bCORPSE
            || candidate.player != null;
    }

    bool IsInside(Actor candidate, Vector3 center, double radius)
    {
        Vector3 candidateCenter = candidate.Pos
            + (0.0, 0.0, candidate.Height * 0.5);
        return (candidateCenter - center).Length() <= radius;
    }

    double GetActorMass(Actor candidate)
    {
        CaelumPlayer playerTarget = CaelumPlayer(candidate);
        if (playerTarget != null && playerTarget.DerivedStats != null)
            return Max(1.0, playerTarget.DerivedStats.TotalMass);
        return Max(1.0, double(candidate.Mass));
    }

    void ApplyRadialVelocity(Actor candidate, double speed, bool inward)
    {
        Vector3 offset = candidate.Pos
            + (0.0, 0.0, candidate.Height * 0.5) - Pos;
        double distance = Max(0.001, offset.Length());
        Vector3 direction = offset / distance;
        if (inward) direction = -direction;
        candidate.Vel += direction * speed;
    }

    void ApplyPersistentElement(Actor candidate, bool fire)
    {
        int damage = Max(1, int((ChannelOwner != null
            && ChannelOwner.DerivedStats != null
                ? ChannelOwner.DerivedStats.DebugStaffDamage : 120.0)
            + 0.5));
        int effect = fire ? CaelumConstants.ELEMENTAL_EFFECT_BURN
            : CaelumConstants.ELEMENTAL_EFFECT_POISON;
        CaelumPlayer playerTarget = CaelumPlayer(candidate);
        if (playerTarget != null && playerTarget.ElementalStatus != null)
        {
            playerTarget.ElementalStatus.ApplyDamageOverTime(
                effect, 1.1, 1.0, damage, ChannelOwner);
            if (!fire)
            {
                playerTarget.ElementalStatus.ApplyControlEffect(
                    CaelumConstants.ELEMENTAL_EFFECT_FREEZE, 1.1, 75.0);
                playerTarget.ElementalStatus.ApplyControlEffect(
                    CaelumConstants.ELEMENTAL_EFFECT_DAZZLE, 1.1, 50.0);
            }
            return;
        }
        CaelumCombatActor combatTarget = CaelumCombatActor(candidate);
        if (combatTarget != null && combatTarget.ElementalStatus != null)
        {
            combatTarget.ElementalStatus.ApplyDamageOverTime(
                effect, 1.1, 1.0, damage, ChannelOwner);
            if (!fire)
            {
                combatTarget.ElementalStatus.ApplyControlEffect(
                    CaelumConstants.ELEMENTAL_EFFECT_FREEZE, 1.1, 75.0);
                combatTarget.ElementalStatus.ApplyControlEffect(
                    CaelumConstants.ELEMENTAL_EFFECT_DAZZLE, 1.1, 50.0);
            }
        }
        else if (candidate.health > 0)
            candidate.DamageMobj(self, ChannelOwner, damage,
                fire ? 'Fire' : 'Poison', DMG_NO_ARMOR, 0.0);
    }

    void ApplyLightningPulse()
    {
        Actor anchors[256];
        int anchorCount = 0;
        ThinkerIterator search = ThinkerIterator.Create("Actor");
        Thinker entry;
        while ((entry = search.Next()) != null && anchorCount < 256)
        {
            Actor candidate = Actor(entry);
            if (IsAuthorizedTarget(candidate)
                && IsInside(candidate, Pos, EffectRadius))
                anchors[anchorCount++] = candidate;
        }
        if (anchorCount <= 0) return;
        Actor anchor = anchors[Random[CaelumChannelLightning](0, anchorCount - 1)];
        Vector3 impactCenter = anchor.Pos
            + (0.0, 0.0, anchor.Height * 0.5);
        double radius = CaelumConstants.ESSENCE_EXPLOSION_BASE_RADIUS
            * CaelumConstants.SEAL_LIGHTNING_RADIUS_STATUETTE_MULTIPLIER
            * (ChannelOwner != null && ChannelOwner.DerivedStats != null
                ? ChannelOwner.DerivedStats.AbilityRangePercent / 100.0 : 1.0);
        Actor victims[256];
        int victimCount = 0;
        ThinkerIterator area = ThinkerIterator.Create("Actor");
        while ((entry = area.Next()) != null && victimCount < 256)
        {
            Actor candidate = Actor(entry);
            if (IsAuthorizedTarget(candidate)
                && IsInside(candidate, impactCenter, radius))
                victims[victimCount++] = candidate;
        }
        if (victimCount <= 0) return;
        double damageScale = ChannelOwner != null
            && ChannelOwner.DerivedStats != null
            ? ChannelOwner.DerivedStats.DebugStaffDamage
                / CaelumConstants.DEBUG_STAFF_BASE_DAMAGE : 1.0;
        int damage = Max(1, int(
            CaelumConstants.SEAL_LIGHTNING_BASE_TOTAL_DAMAGE
                * damageScale / victimCount + 0.5));
        for (int index = 0; index < victimCount; index++)
        {
            Actor lightningVisual = Spawn(
                "CaelumLightningImpactVisual",
                victims[index].Pos,
                ALLOW_REPLACE
            );
            if (lightningVisual != null)
                lightningVisual.master = victims[index];
            if (victims[index].health > 0)
                victims[index].DamageMobj(self, ChannelOwner, damage,
                    'Electric', 0, 0.0);
        }
    }

    void ApplyContinuousEffect()
    {
        TrappedMass = 0.0;
        int affectedCount = 0;
        ThinkerIterator iterator = ThinkerIterator.Create("Actor");
        Thinker entry;
        while ((entry = iterator.Next()) != null)
        {
            Actor candidate = Actor(entry);
            if (!IsAuthorizedTarget(candidate)
                || !IsInside(candidate, Pos, EffectRadius)) continue;
            affectedCount++;
            double combinedPower = ChannelOwner != null
                && ChannelOwner.DerivedStats != null
                ? ChannelOwner.DerivedStats.PhysicalPushMultiplier
                    + ChannelOwner.DerivedStats.MagicalPushMultiplier : 2.0;
            if (SealType == CaelumConstants.SEAL_AIR)
                ApplyRadialVelocity(candidate, combinedPower, false);
            else if (SealType == CaelumConstants.SEAL_QUINTESSENCE)
            {
                TrappedMass += GetActorMass(candidate);
                ApplyRadialVelocity(candidate, combinedPower, true);
            }
        }
        if (ChannelOwner != null)
            ChannelOwner.HUDChannelAffectedCount = affectedCount;
    }

    void ApplyOneSecondPulse()
    {
        if (SealType == CaelumConstants.SEAL_WATER)
        {
            ApplyLightningPulse();
            return;
        }
        if (SealType != CaelumConstants.SEAL_FIRE
            && SealType != CaelumConstants.SEAL_EARTH) return;
        ThinkerIterator iterator = ThinkerIterator.Create("Actor");
        Thinker entry;
        while ((entry = iterator.Next()) != null)
        {
            Actor candidate = Actor(entry);
            if (IsAuthorizedTarget(candidate)
                && IsInside(candidate, Pos, EffectRadius))
                ApplyPersistentElement(candidate,
                    SealType == CaelumConstants.SEAL_FIRE);
        }
    }

    void ReleaseChannel()
    {
        if (SealType == CaelumConstants.SEAL_QUINTESSENCE
            && TrappedMass > 0.0)
        {
            ThinkerIterator iterator = ThinkerIterator.Create("Actor");
            Thinker entry;
            while ((entry = iterator.Next()) != null)
            {
                Actor candidate = Actor(entry);
                if (!IsAuthorizedTarget(candidate)
                    || !IsInside(candidate, Pos, EffectRadius)) continue;
                double speed =
                    CaelumConstants.SEAL_QUINTESSENCE_BASE_EXPULSION_SPEED
                    * TrappedMass / GetActorMass(candidate);
                ApplyRadialVelocity(candidate, speed, false);
            }
        }
        Destroy();
    }

    override void Tick()
    {
        Super.Tick();
        if (ChannelOwner == null || !ChannelOwner.CombatChannelModeActive)
        {
            Destroy();
            return;
        }
        SetOrigin(ChannelOwner.Pos, false);
        ApplyContinuousEffect();
        PulseAccumulator += 1.0 / TICRATE;
        if (PulseAccumulator >= CaelumConstants.SEAL_CHANNEL_PULSE_SECONDS)
        {
            PulseAccumulator -= CaelumConstants.SEAL_CHANNEL_PULSE_SECONDS;
            ApplyOneSecondPulse();
        }
    }
}
