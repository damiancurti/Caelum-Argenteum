// Actores exclusivos de MAP02. Cada variante elimina una sola capa del
// comportamiento para que las pruebas de rendimiento sean comparables.

class CaelumDiagnosticLookRat : CaelumGiantRat
{
    States
    {
    Spawn:
        RATG A 10 A_Look;
        Loop;
    See:
        RATG A 10 A_FaceTarget;
        Loop;
    Melee:
        TNT1 A 0;
        Goto See;
    Missile:
        TNT1 A 0;
        Goto See;
    }
}

class CaelumDiagnosticChaseRat : CaelumGiantRat
{
    States
    {
    Spawn:
        RATG A 10 A_Look;
        Loop;
    See:
        TNT1 A 0 A_JumpIf(
            CombatLucidityPhysicalStunRemaining > 0.0,
            "LucidityStun"
        );
        RATG BC 4 A_Chase;
        Loop;
    Melee:
        TNT1 A 0;
        Goto See;
    Missile:
        TNT1 A 0;
        Goto See;
    }
}

// Conserva A_Chase y la colision solida nativa, pero omite solamente la
// resolucion de impulso/contactos de Caelum.
class CaelumDiagnosticNativeChaseRat : CaelumDiagnosticChaseRat
{
    override void PostBeginPlay()
    {
        Super.PostBeginPlay();
        DisableCaelumImpactContacts = true;
    }
}

class CaelumDiagnosticImpactChaseRat : CaelumDiagnosticChaseRat
{
}

// Tres variantes pasivas idénticas permiten aislar el coste de Quintaesencia
// sin mezclar A_Look, A_Chase ni ataques. Sólo cambia la capa de colisión.
class CaelumDiagnosticQuintessenceFullRat : CaelumPassiveGiantRat
{
    Default
    {
        // Los tres recintos de Quintaesencia sí conservan blockmap y colisión.
        -NOBLOCKMAP
        Species "CaelumDiagnosticQuintessenceRat";
    }
}

class CaelumDiagnosticQuintessenceNativeRat
    : CaelumDiagnosticQuintessenceFullRat
{
    override void PostBeginPlay()
    {
        Super.PostBeginPlay();
        DisableCaelumImpactContacts = true;
    }
}

class CaelumDiagnosticQuintessencePassThroughRat
    : CaelumDiagnosticQuintessenceNativeRat
{
    Default
    {
        +THRUSPECIES
    }
}

// Misma ruta recta, velocidad, alcance y payload que el proyectil elemental
// de los NPC masivos. Esta clase nombra explicitamente el lado simple del A/B.
class CaelumDiagnosticNonExplosiveProjectile
    : CaelumActorSimpleElementalProjectile
{
}

class CaelumDiagnosticNonExplosiveShooter : CaelumArgento
{
    States
    {
    Spawn:
        ARGO A 10 A_Look;
        Loop;
    See:
        ARGO A 4 A_FaceTarget;
        Goto Missile;
    Melee:
        TNT1 A 0;
        Goto Missile;
    Missile:
        ARGO E 7 A_FaceTarget;
        ARGO E 0 A_CaelumSpawnSimpleElementalProjectile(
            "CaelumDiagnosticNonExplosiveProjectile", 40,
            325, CaelumConstants.ESSENCE_FIRE
        );
        ARGO A 11;
        Goto See;
    }
}

class CaelumDiagnosticExplosiveShooter : CaelumArgento
{
    States
    {
    Spawn:
        ARGO A 10 A_Look;
        Loop;
    See:
        ARGO A 4 A_FaceTarget;
        Goto Missile;
    Melee:
        TNT1 A 0;
        Goto Missile;
    Missile:
        ARGO E 7 A_FaceTarget;
        ARGO E 0 A_CaelumSpawnExplosiveElementalProjectile(
            "CaelumActorExplosiveElementalProjectile", 40,
            325, CaelumConstants.ESSENCE_FIRE
        );
        ARGO A 11;
        Goto See;
    }
}

// Observador inmóvil de los nuevos recintos de percepción. Ejecuta una sola
// muestra visual por segundo, usa la fórmula documentada y consume cada evento
// de pasos una sola vez. args[0] fija Perspicacia (0..100) y args[1] identifica
// la sala en la telemetría. La convención angular sigue siendo una comparación
// diagnóstica seleccionable por CVar hasta cerrar la interpretación canónica.
class CaelumDiagnosticPerceptionObserver : CaelumPassiveGiantRat
{
    int PerceptionReportAccumulator;
    int LastProcessedNoiseSerial;
    bool NoiseSerialInitialized;
    int VisualSamples;
    int VisualDetections;
    int HeardMovementEvents;

    const MU_PER_METER = 31.111111;
    const REFERENCE_HEIGHT_MU = 56.0;
    const MOVEMENT_SOUND_BASE_MU = 625.0;
    const REPORT_DISTANCE_MU = 1500.0;

    CaelumPlayer FindDiagnosticPlayer()
    {
        for (int playerIndex = 0; playerIndex < MAXPLAYERS; playerIndex++)
        {
            if (!playeringame[playerIndex]
                || players[playerIndex].mo == null)
            {
                continue;
            }
            CaelumPlayer candidate = CaelumPlayer(players[playerIndex].mo);
            if (candidate != null) { return candidate; }
        }
        return null;
    }

    double GetDiagnosticInsight()
    {
        return Clamp(double(args[0]), 0.0, 100.0);
    }

    bool UsesWideHalfAngles()
    {
        CVar setting = CVar.GetCVar(
            "ca_diag_perception_wide_half_angles"
        );
        return setting != null && setting.GetBool();
    }

    double CalculateAngularFactor(Actor candidate, bool wideHalfAngles)
    {
        double coreHalfAngle = wideHalfAngles ? 60.0 : 30.0;
        double limitHalfAngle = wideHalfAngles ? 120.0 : 60.0;
        double offset = Abs(DeltaAngle(Angle, AngleTo(candidate)));
        if (offset <= coreHalfAngle) { return 1.0; }
        if (offset >= limitHalfAngle) { return 0.0; }
        double remaining = 1.0
            - (offset - coreHalfAngle)
                / (limitHalfAngle - coreHalfAngle);
        return remaining * remaining;
    }

    double CalculateVisualChance(
        CaelumPlayer candidate,
        double distanceMU,
        bool lineOfSight,
        bool wideHalfAngles
    )
    {
        if (!lineOfSight) { return 0.0; }

        double distanceMeters = distanceMU / MU_PER_METER;
        double normalizedDistance = distanceMeters / 20.0;
        double baseChance = 1000.0
            / (1.0 + 9.0 * normalizedDistance * normalizedDistance);
        if (baseChance < 1.0) { return 0.0; }

        double currentHeight = candidate.GetImpactReferenceHeight();
        if (candidate.player != null)
        {
            currentHeight *= Clamp(candidate.player.crouchfactor, 0.0, 1.0);
        }
        double heightFactor = Clamp(
            currentHeight / REFERENCE_HEIGHT_MU,
            0.0,
            2.0
        );
        double insightFactor = 1.0 + GetDiagnosticInsight() / 100.0;
        double stealthFactor = Clamp(
            1.0 - candidate.EffectiveStealthPercent / 100.0,
            0.0,
            1.0
        );
        double angularFactor = CalculateAngularFactor(
            candidate,
            wideHalfAngles
        );
        double result = baseChance
            * heightFactor
            * insightFactor
            * stealthFactor
            * angularFactor;
        return result < 1.0 ? 0.0 : Clamp(result, 0.0, 100.0);
    }

    double CalculateAuditoryAllowance()
    {
        double insight = GetDiagnosticInsight();
        return (50.0 + insight)
            * (1.0 + 2.0 * insight * (insight + 1.0) / 10100.0);
    }

    override void Tick()
    {
        Super.Tick();
        if (level.MapName != "MAP02") { return; }

        PerceptionReportAccumulator++;
        if (PerceptionReportAccumulator < TICRATE) { return; }
        PerceptionReportAccumulator = 0;

        CaelumPlayer candidate = FindDiagnosticPlayer();
        if (candidate == null || candidate.health <= 0) { return; }
        double distanceMU = Distance2D(candidate);
        if (!NoiseSerialInitialized)
        {
            LastProcessedNoiseSerial = candidate.MovementNoiseEventSerial;
            NoiseSerialInitialized = true;
        }
        if (distanceMU > REPORT_DISTANCE_MU)
        {
            // Un evento emitido fuera de esta sala no debe reaparecer cuando
            // el jugador se teletransporte después junto al observador.
            LastProcessedNoiseSerial = candidate.MovementNoiseEventSerial;
            return;
        }

        bool wideHalfAngles = UsesWideHalfAngles();
        bool lineOfSight = CheckSight(candidate);
        double angularOffset = Abs(DeltaAngle(Angle, AngleTo(candidate)));
        double visualChance = CalculateVisualChance(
            candidate,
            distanceMU,
            lineOfSight,
            wideHalfAngles
        );
        double visualRoll =
            Random[CaelumPerceptionDiagnostic](0, 999999) / 10000.0;
        bool visuallyDetected = visualChance > 0.0
            && visualRoll < visualChance;
        VisualSamples++;
        if (visuallyDetected) { VisualDetections++; }

        bool newNoiseEvent = false;
        newNoiseEvent = candidate.MovementNoiseEventSerial
            != LastProcessedNoiseSerial;
        bool heardMovement = false;
        double hearingRange = 0.0;
        if (newNoiseEvent)
        {
            LastProcessedNoiseSerial = candidate.MovementNoiseEventSerial;
            double sourceMultiplier = candidate.LastMovementNoiseEventRange
                / MOVEMENT_SOUND_BASE_MU;
            hearingRange = (
                MOVEMENT_SOUND_BASE_MU + CalculateAuditoryAllowance()
            ) * sourceMultiplier;
            heardMovement = candidate.LastMovementNoiseEventTic >= 0
                && candidate.LastMovementNoiseEventTic <= level.time
                && distanceMU <= hearingRange;
            if (heardMovement) { HeardMovementEvents++; }
        }

        Console.Printf(
            "[CA-PERCEP] sala=%d perspicacia=%d distancia=%.1fMU angulo=%.1f linea=%d modo=%s visual=%.2f%% tirada=%.2f detectado=%d muestras=%d/%d ruido_nuevo=%d alcance_oido=%.1fMU oido=%d eventos=%d",
            args[1],
            int(GetDiagnosticInsight()),
            distanceMU,
            angularOffset,
            lineOfSight,
            wideHalfAngles ? "semicono_60_120" : "apertura_60_120",
            visualChance,
            visualRoll,
            visuallyDetected,
            VisualDetections,
            VisualSamples,
            newNoiseEvent,
            hearingRange,
            heardMovement,
            HeardMovementEvents
        );
    }
}

// Un monitor colocado una sola vez en MAP02 informa cada segundo. Los
// contactos se guardan como una referencia en cada cuerpo; por eso se divide
// el total por dos para mostrar aristas fisicas aproximadas.
class CaelumPhysicsDiagnosticMonitor : Actor
{
    int ReportAccumulator;

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

    override void PostBeginPlay()
    {
        Super.PostBeginPlay();
        Console.Printf(
            "[CA-PERCEP] Salas: 1 warp 300 2000 0; 2 warp 2900 1500 0; 3 warp 6100 2100 0; 4 warp 300 -2000 0; 5 warp 2900 -1500 0; 6 warp 6100 -2100 0."
        );
        Console.Printf(
            "[CA-AI] Base aceptada: ca_diag_mass_follower_movement false. Movimiento barato: true antes de map map02; después warp 16368 -16 0."
        );
        Console.Printf(
            "[CA-PHYS] Quintaesencia: warp -24000 -18000 0; warp -24000 0 0; warp -24000 18000 0."
        );
    }

    override void Tick()
    {
        Super.Tick();
        ReportAccumulator++;
        if (ReportAccumulator < TICRATE) { return; }
        ReportAccumulator = 0;

        int combatActors = 0;
        int massFieldActors = 0;
        int massFieldActiveActors = 0;
        int activeAIActors = 0;
        int activeAITargets = 0;
        int targetedActors = 0;
        int missiles = 0;
        int contactReferences = 0;
        int maximumContacts = 0;
        int collisionCallbacks = 0;
        int uniquePairTicks = 0;
        int duplicateCallbacks = 0;
        int restingCallbacks = 0;
        int createdReferences = 0;
        int removedReferences = 0;
        int channelAffectedActors = 0;
        int attackAttempts = 0;
        int suppressedAttacks = 0;
        int deferredAttacks = 0;
        int friendlyFirePrevented = 0;
        int chaseAttempts = 0;
        int chaseUpdates = 0;
        int chaseDeferred = 0;
        int chasePhaseDeferred = 0;
        int chaseBudgetDeferred = 0;
        int chaseDisabled = 0;
        int lookAttempts = 0;
        int lookUpdates = 0;
        int lookDeferred = 0;
        int lookPhaseDeferred = 0;
        int lookBudgetDeferred = 0;
        int lookDisabled = 0;
        int scheduledLookInterval = 0;
        int scheduledLookBudget = 0;
        int scheduledChaseInterval = 0;
        int scheduledChaseBudget = 0;
        int scheduledSquadSize = 0;
        int scheduledAttackInterval = 0;
        bool scheduledChaseEnabled = false;
        bool scheduledLookEnabled = false;
        bool scheduledAttacksEnabled = false;
        int lightweightDiagnosticActors = 0;
        int lightweightBlockmapActors = 0;
        int lightweightVisualActors = 0;
        int massSquadLeaders = 0;
        int massSquadFollowers = 0;
        int massFollowerPulses = 0;
        int massFollowerMoveUpdates = 0;
        int massFollowerMoveStops = 0;
        int massSharedTargetAdoptions = 0;
        bool scheduledFollowerMovement = false;
        double scheduledFollowerSpeedScale = 0.0;
        int anatomyObjects = 0;
        int armorObjects = 0;
        int elementalStatusObjects = 0;
        int projectilesSpawned = 0;
        int projectileSpawnFailures = 0;
        int projectileImpacts = 0;
        int projectilesExpired = 0;
        int projectilesDestroyed = 0;
        int activeRats = 0;
        int targetedRats = 0;
        int chaseRats = 0;
        int activeRulos = 0;
        int targetedRulos = 0;
        int chaseRulos = 0;
        int activeArgentos = 0;
        int targetedArgentos = 0;
        int chaseArgentos = 0;
        int activeCaellas = 0;
        int targetedCaellas = 0;
        int chaseCaellas = 0;
        int activeRonnies = 0;
        int targetedRonnies = 0;
        int chaseRonnies = 0;
        int activeBulls = 0;
        int targetedBulls = 0;
        int chaseBulls = 0;
        int targetedNear = 0;
        int targetedMiddle = 0;
        int targetedFar = 0;

        ThinkerIterator iterator = ThinkerIterator.Create("Actor");
        Thinker entry;
        while ((entry = iterator.Next()) != null)
        {
            Actor candidate = Actor(entry);
            if (candidate == null || candidate == self) { continue; }
            if (candidate.bMISSILE) { missiles++; }

            CaelumCombatActor combatActor = CaelumCombatActor(candidate);
            if (combatActor != null)
            {
                combatActors++;
                if (combatActor.IsCaelumMassDiagnosticActor())
                {
                    massFieldActors++;
                    if (!combatActor.CaelumDiagnosticPassiveAI
                        && combatActor.health > 0)
                    {
                        massFieldActiveActors++;
                    }
                }
                if (combatActor.CaelumMassAIScheduleActive
                    || combatActor.CaelumDiagnosticPassiveAI)
                {
                    lightweightDiagnosticActors++;
                    if (combatActor.bNOBLOCKMAP)
                    {
                        lightweightVisualActors++;
                    }
                    else
                    {
                        lightweightBlockmapActors++;
                    }
                }
                // La población pasiva comparte la marca de campo para poder
                // auditar su representación, pero no integra escuadras de IA.
                // Contarla aquí ocultaba los 126 líderes y 1.749 seguidores
                // activos que realmente participan en la prueba.
                if (combatActor.CaelumMassAIScheduleActive
                    && !combatActor.CaelumDiagnosticPassiveAI)
                {
                    if (combatActor.CaelumMassSquadLeader)
                    {
                        massSquadLeaders++;
                    }
                    else
                    {
                        massSquadFollowers++;
                    }
                    massFollowerPulses +=
                        combatActor.ImpactDiagnosticFollowerPulses;
                    massFollowerMoveUpdates +=
                        combatActor.ImpactDiagnosticFollowerMoveUpdates;
                    massFollowerMoveStops +=
                        combatActor.ImpactDiagnosticFollowerMoveStops;
                    massSharedTargetAdoptions +=
                        combatActor.ImpactDiagnosticSharedTargetAdoptions;
                }
                if (combatActor.AnatomyProfile != null) { anatomyObjects++; }
                if (combatActor.CombatArmor != null) { armorObjects++; }
                if (combatActor.ElementalStatus != null)
                {
                    elementalStatusObjects++;
                }
                if (!combatActor.CaelumDiagnosticPassiveAI
                    && combatActor.health > 0)
                {
                    activeAIActors++;
                    if (combatActor.target != null) { activeAITargets++; }
                    if (combatActor.IsCaelumMassDiagnosticActor()
                        && CaelumGiantRat(combatActor) != null)
                    {
                        activeRats++;
                        if (combatActor.target != null) { targetedRats++; }
                        chaseRats += combatActor.ImpactDiagnosticChaseUpdates;
                    }
                    else if (combatActor.IsCaelumMassDiagnosticActor()
                        && CaelumRulo(combatActor) != null)
                    {
                        activeRulos++;
                        if (combatActor.target != null) { targetedRulos++; }
                        chaseRulos += combatActor.ImpactDiagnosticChaseUpdates;
                    }
                    else if (combatActor.IsCaelumMassDiagnosticActor()
                        && CaelumArgento(combatActor) != null)
                    {
                        activeArgentos++;
                        if (combatActor.target != null) { targetedArgentos++; }
                        chaseArgentos += combatActor.ImpactDiagnosticChaseUpdates;
                    }
                    else if (combatActor.IsCaelumMassDiagnosticActor()
                        && CaelumCaella(combatActor) != null)
                    {
                        activeCaellas++;
                        if (combatActor.target != null) { targetedCaellas++; }
                        chaseCaellas += combatActor.ImpactDiagnosticChaseUpdates;
                    }
                    else if (combatActor.IsCaelumMassDiagnosticActor()
                        && CaelumRonnie(combatActor) != null)
                    {
                        activeRonnies++;
                        if (combatActor.target != null) { targetedRonnies++; }
                        chaseRonnies += combatActor.ImpactDiagnosticChaseUpdates;
                    }
                    else if (combatActor.IsCaelumMassDiagnosticActor()
                        && CaelumBull(combatActor) != null)
                    {
                        activeBulls++;
                        if (combatActor.target != null) { targetedBulls++; }
                        chaseBulls += combatActor.ImpactDiagnosticChaseUpdates;
                    }

                    if (combatActor.IsCaelumMassDiagnosticActor()
                        && combatActor.target != null)
                    {
                        double distanceX = combatActor.Pos.X
                            - combatActor.target.Pos.X;
                        double distanceY = combatActor.Pos.Y
                            - combatActor.target.Pos.Y;
                        double distanceSquared = distanceX * distanceX
                            + distanceY * distanceY;
                        if (distanceSquared <= 512.0 * 512.0)
                        {
                            targetedNear++;
                        }
                        else if (distanceSquared <= 1024.0 * 1024.0)
                        {
                            targetedMiddle++;
                        }
                        else
                        {
                            targetedFar++;
                        }
                    }
                }
                if (combatActor.target != null) { targetedActors++; }
                int actorContacts = combatActor.GetImpactContactCount();
                contactReferences += actorContacts;
                maximumContacts = Max(maximumContacts, actorContacts);
                collisionCallbacks +=
                    combatActor.ImpactDiagnosticCollisionCallbacks;
                uniquePairTicks +=
                    combatActor.ImpactDiagnosticUniquePairTicks;
                duplicateCallbacks +=
                    combatActor.ImpactDiagnosticDuplicateCallbacks;
                restingCallbacks +=
                    combatActor.ImpactDiagnosticRestingCallbacks;
                createdReferences +=
                    combatActor.ImpactDiagnosticContactsCreated;
                removedReferences +=
                    combatActor.ImpactDiagnosticContactsRemoved;
                attackAttempts +=
                    combatActor.ImpactDiagnosticAttackAttempts;
                suppressedAttacks +=
                    combatActor.ImpactDiagnosticSuppressedAttacks;
                deferredAttacks +=
                    combatActor.ImpactDiagnosticDeferredAttacks;
                friendlyFirePrevented +=
                    combatActor.ImpactDiagnosticFriendlyFirePrevented;
                chaseAttempts +=
                    combatActor.ImpactDiagnosticChaseAttempts;
                chaseUpdates +=
                    combatActor.ImpactDiagnosticChaseUpdates;
                chaseDeferred +=
                    combatActor.ImpactDiagnosticChaseDeferred;
                chasePhaseDeferred +=
                    combatActor.ImpactDiagnosticChasePhaseDeferred;
                chaseBudgetDeferred +=
                    combatActor.ImpactDiagnosticChaseBudgetDeferred;
                chaseDisabled +=
                    combatActor.ImpactDiagnosticChaseDisabled;
                lookAttempts +=
                    combatActor.ImpactDiagnosticLookAttempts;
                lookUpdates +=
                    combatActor.ImpactDiagnosticLookUpdates;
                lookDeferred +=
                    combatActor.ImpactDiagnosticLookDeferred;
                lookPhaseDeferred +=
                    combatActor.ImpactDiagnosticLookPhaseDeferred;
                lookBudgetDeferred +=
                    combatActor.ImpactDiagnosticLookBudgetDeferred;
                lookDisabled +=
                    combatActor.ImpactDiagnosticLookDisabled;
                if (combatActor.CaelumMassAIScheduleActive
                    && scheduledLookInterval == 0)
                {
                    scheduledLookInterval =
                        combatActor.CaelumMassLookInterval;
                    scheduledLookBudget =
                        combatActor.CaelumMassLookBudgetPerTic;
                    scheduledChaseInterval =
                        combatActor.CaelumMassChaseInterval;
                    scheduledChaseBudget =
                        combatActor.CaelumMassChaseBudgetPerTic;
                    scheduledSquadSize =
                        combatActor.CaelumMassSquadSize;
                    scheduledAttackInterval =
                        combatActor.CaelumMassAttackInterval;
                    scheduledChaseEnabled =
                        combatActor.CaelumMassChaseEnabled;
                    scheduledLookEnabled =
                        combatActor.CaelumMassLookEnabled;
                    scheduledAttacksEnabled =
                        combatActor.CaelumMassAttacksEnabled;
                    scheduledFollowerMovement =
                        combatActor.CaelumMassFollowerMovementEnabled;
                    scheduledFollowerSpeedScale =
                        combatActor.CaelumMassFollowerSpeedScale;
                }
                projectilesSpawned +=
                    combatActor.ImpactDiagnosticProjectilesSpawned;
                projectileSpawnFailures +=
                    combatActor.ImpactDiagnosticProjectileSpawnFailures;
                projectileImpacts +=
                    combatActor.ImpactDiagnosticProjectileImpacts;
                projectilesExpired +=
                    combatActor.ImpactDiagnosticProjectilesExpired;
                projectilesDestroyed +=
                    combatActor.ImpactDiagnosticProjectilesDestroyed;
                combatActor.ImpactDiagnosticCollisionCallbacks = 0;
                combatActor.ImpactDiagnosticUniquePairTicks = 0;
                combatActor.ImpactDiagnosticDuplicateCallbacks = 0;
                combatActor.ImpactDiagnosticRestingCallbacks = 0;
                combatActor.ImpactDiagnosticContactsCreated = 0;
                combatActor.ImpactDiagnosticContactsRemoved = 0;
                combatActor.ImpactDiagnosticAttackAttempts = 0;
                combatActor.ImpactDiagnosticSuppressedAttacks = 0;
                combatActor.ImpactDiagnosticDeferredAttacks = 0;
                combatActor.ImpactDiagnosticFriendlyFirePrevented = 0;
                combatActor.ImpactDiagnosticChaseAttempts = 0;
                combatActor.ImpactDiagnosticChaseUpdates = 0;
                combatActor.ImpactDiagnosticChaseDeferred = 0;
                combatActor.ImpactDiagnosticChasePhaseDeferred = 0;
                combatActor.ImpactDiagnosticChaseBudgetDeferred = 0;
                combatActor.ImpactDiagnosticChaseDisabled = 0;
                combatActor.ImpactDiagnosticFollowerPulses = 0;
                combatActor.ImpactDiagnosticFollowerMoveUpdates = 0;
                combatActor.ImpactDiagnosticFollowerMoveStops = 0;
                combatActor.ImpactDiagnosticSharedTargetAdoptions = 0;
                combatActor.ImpactDiagnosticLookAttempts = 0;
                combatActor.ImpactDiagnosticLookUpdates = 0;
                combatActor.ImpactDiagnosticLookDeferred = 0;
                combatActor.ImpactDiagnosticLookPhaseDeferred = 0;
                combatActor.ImpactDiagnosticLookBudgetDeferred = 0;
                combatActor.ImpactDiagnosticLookDisabled = 0;
                combatActor.ImpactDiagnosticProjectilesSpawned = 0;
                combatActor.ImpactDiagnosticProjectileSpawnFailures = 0;
                combatActor.ImpactDiagnosticProjectileImpacts = 0;
                combatActor.ImpactDiagnosticProjectilesExpired = 0;
                combatActor.ImpactDiagnosticProjectilesDestroyed = 0;
                continue;
            }

            CaelumPlayer playerActor = CaelumPlayer(candidate);
            if (playerActor != null)
            {
                int playerContacts = playerActor.GetImpactContactCount();
                contactReferences += playerContacts;
                maximumContacts = Max(maximumContacts, playerContacts);
                collisionCallbacks +=
                    playerActor.ImpactDiagnosticCollisionCallbacks;
                uniquePairTicks +=
                    playerActor.ImpactDiagnosticUniquePairTicks;
                duplicateCallbacks +=
                    playerActor.ImpactDiagnosticDuplicateCallbacks;
                restingCallbacks +=
                    playerActor.ImpactDiagnosticRestingCallbacks;
                channelAffectedActors += playerActor.HUDChannelAffectedCount;
                createdReferences +=
                    playerActor.ImpactDiagnosticContactsCreated;
                removedReferences +=
                    playerActor.ImpactDiagnosticContactsRemoved;
                playerActor.ImpactDiagnosticCollisionCallbacks = 0;
                playerActor.ImpactDiagnosticUniquePairTicks = 0;
                playerActor.ImpactDiagnosticDuplicateCallbacks = 0;
                playerActor.ImpactDiagnosticRestingCallbacks = 0;
                playerActor.ImpactDiagnosticContactsCreated = 0;
                playerActor.ImpactDiagnosticContactsRemoved = 0;
            }
        }

        int peakLookUpdatesPerTic = 0;
        int schedulerLookBudgetDeferred = 0;
        int peakChaseUpdatesPerTic = 0;
        int schedulerBudgetDeferred = 0;
        int sharedTargetPublications = 0;
        int sharedTargetAdoptions = 0;
        CaelumMassAIScheduler massScheduler = CaelumMassAIScheduler(
            EventHandler.Find("CaelumMassAIScheduler")
        );
        if (massScheduler != null)
        {
            peakLookUpdatesPerTic =
                massScheduler.ReadAndResetPeakLookUpdates();
            schedulerLookBudgetDeferred =
                massScheduler.ReadAndResetLookBudgetDeferrals();
            peakChaseUpdatesPerTic =
                massScheduler.ReadAndResetPeakChaseUpdates();
            schedulerBudgetDeferred =
                massScheduler.ReadAndResetBudgetDeferrals();
            sharedTargetPublications =
                massScheduler.ReadAndResetSharedTargetPublications();
            sharedTargetAdoptions =
                massScheduler.ReadAndResetSharedTargetAdoptions();
        }

        Console.Printf(
            "[CA-PHYS] actores=%d campo=%d ia_campo=%d ia=%d ia_objetivos=%d objetivos=%d proyectiles=%d",
            combatActors,
            massFieldActors,
            massFieldActiveActors,
            activeAIActors,
            activeAITargets,
            targetedActors,
            missiles
        );
        Console.Printf(
            "[CA-PHYS] ligeros=%d blockmap=%d visuales=%d auxiliares anatomia=%d armadura=%d estados=%d",
            lightweightDiagnosticActors,
            lightweightBlockmapActors,
            lightweightVisualActors,
            anatomyObjects,
            armorObjects,
            elementalStatusObjects
        );
        Console.Printf(
            "[CA-AI] campo objetivos/activos ratas=%d/%d rulo=%d/%d argento=%d/%d caella=%d/%d ronnie=%d/%d toros=%d/%d",
            targetedRats, activeRats,
            targetedRulos, activeRulos,
            targetedArgentos, activeArgentos,
            targetedCaellas, activeCaellas,
            targetedRonnies, activeRonnies,
            targetedBulls, activeBulls
        );
        Console.Printf(
            "[CA-AI] look activo=%d escalonado=%d cupo/tic=%d pico/tic=%d intentos/s=%d ejecutados/s=%d diferidos/s=%d fase=%d cupo=%d pausa=%d coord=%d",
            scheduledLookEnabled,
            scheduledLookInterval,
            scheduledLookBudget,
            peakLookUpdatesPerTic,
            lookAttempts,
            lookUpdates,
            lookDeferred,
            lookPhaseDeferred,
            lookBudgetDeferred,
            lookDisabled,
            schedulerLookBudgetDeferred
        );
        Console.Printf(
            "[CA-AI] chase activo=%d escalonado=%d cupo/tic=%d pico/tic=%d intentos/s=%d ejecutados/s=%d diferidos/s=%d fase=%d cupo=%d pausa=%d coord=%d",
            scheduledChaseEnabled,
            scheduledChaseInterval,
            scheduledChaseBudget,
            peakChaseUpdatesPerTic,
            chaseAttempts,
            chaseUpdates,
            chaseDeferred,
            chasePhaseDeferred,
            chaseBudgetDeferred,
            chaseDisabled,
            schedulerBudgetDeferred
        );
        Console.Printf(
            "[CA-AI] escuadras tamano=%d lideres=%d seguidores=%d objetivo_publicado=%d adopciones_coord=%d adopciones_actores=%d",
            scheduledSquadSize,
            massSquadLeaders,
            massSquadFollowers,
            sharedTargetPublications,
            sharedTargetAdoptions,
            massSharedTargetAdoptions
        );
        Console.Printf(
            "[CA-AI] seguidores movimiento=%d escala=%.3f actualizaciones/s=%d paradas/s=%d pulsos_pasivos/s=%d",
            scheduledFollowerMovement,
            scheduledFollowerSpeedScale,
            massFollowerMoveUpdates,
            massFollowerMoveStops,
            massFollowerPulses
        );
        Console.Printf(
            "[CA-AI] chase/familia ratas=%d rulo=%d argento=%d caella=%d ronnie=%d toros=%d distancia <=512=%d <=1024=%d >1024=%d",
            chaseRats,
            chaseRulos,
            chaseArgentos,
            chaseCaellas,
            chaseRonnies,
            chaseBulls,
            targetedNear,
            targetedMiddle,
            targetedFar
        );
        Console.Printf(
            "[CA-PHYS] contactos~=%d max/actor=%d callbacks/s=%d unicos=%d duplicados=%d reposo=%d",
            contactReferences / 2,
            maximumContacts,
            collisionCallbacks,
            uniquePairTicks,
            duplicateCallbacks,
            restingCallbacks
        );
        Console.Printf(
            "[CA-PHYS] refs +%d -%d sello_afectados=%d",
            createdReferences,
            removedReferences,
            channelAffectedActors
        );
        Console.Printf(
            "[CA-COMBAT] ataques_masivos=%d escalonado=%d intentos/s=%d anulados/s=%d diferidos/s=%d fuego_amigo=%d proj +%d impacto=%d vencido=%d destruido=%d fallo=%d",
            scheduledAttacksEnabled,
            scheduledAttackInterval,
            attackAttempts,
            suppressedAttacks,
            deferredAttacks,
            friendlyFirePrevented,
            projectilesSpawned,
            projectileImpacts,
            projectilesExpired,
            projectilesDestroyed,
            projectileSpawnFailures
        );
    }
}
