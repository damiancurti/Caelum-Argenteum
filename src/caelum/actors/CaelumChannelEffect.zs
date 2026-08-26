// Actor central de la Canalizacion mediante Sello. No colisiona ni participa
// en la arquitectura: selecciona combatientes, cadaveres y proyectiles.
class CaelumChannelEffect : Actor
{
    CaelumPlayer ChannelOwner;
    CaelumEquipmentItem ChannelSeal;
    int SealType;
    int SealTier;
    double EffectRadius;
    double PulseAccumulator;
    double TrappedMass;
    Array<Actor> GravityTargets;
    Array<int> GravityOriginalFlags;

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

    void ConfigureChannel(CaelumPlayer owner, CaelumEquipmentItem seal,
        double radius)
    {
        ChannelOwner = owner;
        ChannelSeal = seal;
        Target = owner;
        SealType = Clamp(seal.ItemType, 0,
            CaelumConstants.SEAL_TYPE_COUNT - 1);
        SealTier = Clamp(seal.Tier, 1, 3);
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
        Vector3 offset = candidateCenter - center;
        double safeRadius = Max(0.0, radius);
        // La canalizacion consulta miles de actores por tic. Comparar
        // distancias al cuadrado evita una raiz por actor sin alterar el radio.
        return offset.X * offset.X + offset.Y * offset.Y
            + offset.Z * offset.Z <= safeRadius * safeRadius;
    }

    double GetActorMass(Actor candidate)
    {
        CaelumPlayer playerTarget = CaelumPlayer(candidate);
        if (playerTarget != null && playerTarget.DerivedStats != null)
            return Max(1.0, playerTarget.DerivedStats.TotalMass);
        return Max(1.0, double(candidate.Mass));
    }

    // Fuerza constante: la aceleración resultante es inversamente
    // proporcional a la masa del cuerpo afectado.
    double GetMassAdjustedContinuousSpeed(Actor candidate, double force)
    {
        return Max(0.0, force) / GetActorMass(candidate);
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

    // El giro horario visto desde arriba representa la convención de las
    // tormentas del hemisferio sur. La componente vertical usa la misma
    // potencia que la tangencial para no introducir otro valor de balance.
    void ApplySouthernTornadoVelocity(Actor candidate, double speed)
    {
        Vector2 offset = (candidate.Pos.X - Pos.X, candidate.Pos.Y - Pos.Y);
        double distance = Max(0.001, offset.Length());
        Vector2 radial = offset / distance;
        Vector2 clockwiseTangent = (radial.Y, -radial.X);
        candidate.Vel.X += clockwiseTangent.X * speed;
        candidate.Vel.Y += clockwiseTangent.Y * speed;
        candidate.Vel.Z += speed;
    }

    void SuppressTargetGravity(Actor candidate)
    {
        GravityTargets.Push(candidate);
        GravityOriginalFlags.Push(candidate.bNOGRAVITY ? 1 : 0);
        candidate.bNOGRAVITY = true;
    }

    void RestoreTargetGravity()
    {
        for (int index = GravityTargets.Size() - 1; index >= 0; index--)
        {
            Actor candidate = GravityTargets[index];
            if (candidate != null)
                candidate.bNOGRAVITY = GravityOriginalFlags[index] != 0;
            GravityTargets.Delete(index);
            GravityOriginalFlags.Delete(index);
        }
    }

    // Caída por potencia cuadrática: 100% en el centro, 50% a mitad del
    // radio y 0% en el borde, sin discontinuidades entre ambas mitades.
    double GetRadialPenaltyPercent(Actor candidate)
    {
        Vector3 center = candidate.Pos
            + (0.0, 0.0, candidate.Height * 0.5);
        double ratio = Clamp((center - Pos).Length() / EffectRadius, 0.0, 1.0);
        double intensity;
        if (ratio <= 0.5)
        {
            double inner = 1.0 - ratio * 2.0;
            intensity = 0.5 + 0.5 * inner * inner;
        }
        else
        {
            double outer = 2.0 - ratio * 2.0;
            intensity = 0.5 * outer * outer;
        }
        return Clamp(intensity * 100.0, 0.0, 100.0);
    }

    void ApplyPersistentElement(Actor candidate, bool fire,
        double penaltyPercent)
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
                playerTarget.ElementalStatus.ApplyEarthPenalty(
                    1.1, penaltyPercent);
            return;
        }
        CaelumCombatActor combatTarget = CaelumCombatActor(candidate);
        if (combatTarget != null && combatTarget.ElementalStatus != null)
        {
            combatTarget.ElementalStatus.ApplyDamageOverTime(
                effect, 1.1, 1.0, damage, ChannelOwner);
            if (!fire)
                combatTarget.ElementalStatus.ApplyEarthPenalty(
                    1.1, penaltyPercent);
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
        // Se restaura y reconstruye la lista una vez por tic. Así la búsqueda
        // permanece O(n) incluso durante la prueba de 15.000 actores.
        RestoreTargetGravity();
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
            double massAdjustedSpeed =
                GetMassAdjustedContinuousSpeed(candidate, combinedPower);
            if (SealType == CaelumConstants.SEAL_AIR)
            {
                SuppressTargetGravity(candidate);
                ApplySouthernTornadoVelocity(candidate, massAdjustedSpeed);
            }
            else if (SealType == CaelumConstants.SEAL_QUINTESSENCE)
            {
                SuppressTargetGravity(candidate);
                TrappedMass += GetActorMass(candidate);
                ApplyRadialVelocity(candidate, massAdjustedSpeed, true);
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
                    SealType == CaelumConstants.SEAL_FIRE,
                    SealType == CaelumConstants.SEAL_EARTH
                        ? GetRadialPenaltyPercent(candidate) : 100.0);
        }
    }

    void ReleaseChannel()
    {
        RestoreTargetGravity();
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
        if (ChannelOwner == null || ChannelSeal == null
            || !ChannelSeal.Equipped
            || ChannelSeal.EquipmentKind != CaelumConstants.EQUIPMENT_KIND_SEAL
            || ChannelOwner.GetEquippedSeal() != ChannelSeal
            || !ChannelOwner.CombatChannelModeActive)
        {
            RestoreTargetGravity();
            Destroy();
            return;
        }
        // El tipo se toma del objeto exacto que inició la canalización. Así
        // ningún actor de efecto anterior puede conservar el tipo Fuego.
        SealType = Clamp(ChannelSeal.ItemType, 0,
            CaelumConstants.SEAL_TYPE_COUNT - 1);
        vector3 epicenter = ChannelOwner.Pos;
        if (SealType == CaelumConstants.SEAL_QUINTESSENCE)
            epicenter.Z +=
                CaelumConstants.SEAL_QUINTESSENCE_EPICENTER_HEIGHT;
        SetOrigin(epicenter, false);
        ApplyContinuousEffect();
        PulseAccumulator += 1.0 / TICRATE;
        if (PulseAccumulator >= CaelumConstants.SEAL_CHANNEL_PULSE_SECONDS)
        {
            PulseAccumulator -= CaelumConstants.SEAL_CHANNEL_PULSE_SECONDS;
            ApplyOneSecondPulse();
        }
    }
}
