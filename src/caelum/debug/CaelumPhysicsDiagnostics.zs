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
        ARGO D 7 A_FaceTarget;
        ARGO D 0 A_CaelumSpawnSimpleElementalProjectile(
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
        ARGO D 7 A_FaceTarget;
        ARGO D 0 A_CaelumSpawnExplosiveElementalProjectile(
            "CaelumActorExplosiveElementalProjectile", 40,
            325, CaelumConstants.ESSENCE_FIRE
        );
        ARGO A 11;
        Goto See;
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
            "[CA-PHYS] Quintaesencia: 7 warp -24000 -18000 0; 8 warp -24000 0 0; 9 warp -24000 18000 0. IA masiva: CVars en vivo; warp 16368 -16 0."
        );
    }

    override void Tick()
    {
        Super.Tick();
        ReportAccumulator++;
        if (ReportAccumulator < TICRATE) { return; }
        ReportAccumulator = 0;

        int combatActors = 0;
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
        int scheduledAttackInterval = 0;
        bool scheduledChaseEnabled = false;
        bool scheduledLookEnabled = false;
        bool scheduledAttacksEnabled = false;
        int lightweightDiagnosticActors = 0;
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
                if (combatActor.CaelumMassAIScheduleActive
                    || combatActor.CaelumDiagnosticPassiveAI)
                {
                    lightweightDiagnosticActors++;
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
                    scheduledAttackInterval =
                        combatActor.CaelumMassAttackInterval;
                    scheduledChaseEnabled =
                        combatActor.CaelumMassChaseEnabled;
                    scheduledLookEnabled =
                        combatActor.CaelumMassLookEnabled;
                    scheduledAttacksEnabled =
                        combatActor.CaelumMassAttacksEnabled;
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
        }

        Console.Printf(
            "[CA-PHYS] actores=%d ia=%d ia_objetivos=%d objetivos=%d proyectiles=%d",
            combatActors,
            activeAIActors,
            activeAITargets,
            targetedActors,
            missiles
        );
        Console.Printf(
            "[CA-PHYS] ligeros=%d auxiliares anatomia=%d armadura=%d estados=%d",
            lightweightDiagnosticActors,
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
