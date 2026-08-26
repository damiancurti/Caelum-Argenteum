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
            "[CA-PHYS] MAP02: norte 1-4; sur 5-9. Quintaesencia: 7 nativa, 8 completa, 9 sin colision entre pares."
        );
    }

    override void Tick()
    {
        Super.Tick();
        ReportAccumulator++;
        if (ReportAccumulator < TICRATE) { return; }
        ReportAccumulator = 0;

        int combatActors = 0;
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
                combatActor.ImpactDiagnosticCollisionCallbacks = 0;
                combatActor.ImpactDiagnosticUniquePairTicks = 0;
                combatActor.ImpactDiagnosticDuplicateCallbacks = 0;
                combatActor.ImpactDiagnosticRestingCallbacks = 0;
                combatActor.ImpactDiagnosticContactsCreated = 0;
                combatActor.ImpactDiagnosticContactsRemoved = 0;
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

        Console.Printf(
            "[CA-PHYS] actores=%d objetivos=%d proyectiles=%d",
            combatActors, targetedActors, missiles
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
    }
}
