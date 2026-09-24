// Cuatro prisioneros visuales para MAP02, recolorizados a partir de los
// residentes aceptados. Reutilizan el perfil de combate del personaje fuente,
// pero en las celdas quedan inertes, amistosos y sin contar como bajas.
class CaelumPrisonerUnitario : CaelumCaella
{
    Default
    {
        Tag "$CA_PRISONER_UNITARIO_NAME";
        -COUNTKILL
        +FRIENDLY
        +INVULNERABLE
    }

    override void PostBeginPlay()
    {
        Super.PostBeginPlay();
        BecomeInertPrisoner();
    }

    States
    {
    Spawn:
        PUNI A 10;
        Goto IdleBreathing;
    See:
        TNT1 A 0 A_JumpIf(CombatLucidityPhysicalStunRemaining > 0.0, "LucidityStun");
        PUNC ABCD 4 A_CaelumResidentChase;
        Loop;
    LucidityStun:
        PUNL A 1;
        Goto See;
    Melee:
        PUNL E 7 A_FaceTarget;
        PUNL E 0 A_CaelumMeleeAttack(174);
        PUNL A 11;
        Goto See;
    Missile:
        PUNL E 7 A_FaceTarget;
        PUNL E 0 A_CaelumSpawnSimpleElementalProjectile(
            "CaelumActorSimpleElementalProjectile", 40,
            325, CaelumConstants.ESSENCE_WATER
        );
        PUNL A 11;
        Goto See;
    Pain:
        PUNL F 8 A_Pain;
        Goto See;
    Death:
        PUNL G 5 A_Scream;
        PUNL H 5;
        PUNL I 5 A_NoBlocking;
        PUNL JK 5;
        PUNL L -1;
        Stop;
    RestSeated:
        PUNR A -1;
        Stop;
    RestLying:
        PUNR B -1;
        Stop;
    CrouchIdle:
        PUNR C -1;
        Stop;
    CrouchWalk:
        PUNR DEFG 6;
        Loop;

    IdleBreathing:
        PUNI AAA 10;
        PUNI BBBB 10;
        Goto Spawn;
    Run:
        Goto See;
    }
}

class CaelumPrisonerFederal : CaelumRonnie
{
    Default
    {
        Tag "$CA_PRISONER_FEDERAL_NAME";
        -COUNTKILL
        +FRIENDLY
        +INVULNERABLE
    }

    override void PostBeginPlay()
    {
        Super.PostBeginPlay();
        BecomeInertPrisoner();
    }

    States
    {
    Spawn:
        PFED A 10;
        Goto IdleBreathing;
    See:
        TNT1 A 0 A_JumpIf(CombatLucidityPhysicalStunRemaining > 0.0, "LucidityStun");
        PFEC ABCD 4 A_CaelumResidentChase;
        Loop;
    LucidityStun:
        PFEL A 1;
        Goto See;
    Melee:
        PFEL E 7 A_FaceTarget;
        PFEL E 0 A_CaelumMeleeAttack(372);
        PFEL A 10;
        Goto See;
    Missile:
        PFEL E 7 A_FaceTarget;
        PFEL E 0 A_CaelumSpawnSimpleElementalProjectile(
            "CaelumActorSimpleElementalProjectile", 40,
            154, CaelumConstants.ESSENCE_WIND
        );
        PFEL A 9;
        Goto See;
    Pain:
        PFEL F 8 A_Pain;
        Goto See;
    Death:
        PFEL G 5 A_Scream;
        PFEL H 5;
        PFEL I 5 A_NoBlocking;
        PFEL JK 5;
        PFEL L -1;
        Stop;
    RestSeated:
        PFER A -1;
        Stop;
    RestLying:
        PFER B -1;
        Stop;
    CrouchIdle:
        PFER C -1;
        Stop;
    CrouchWalk:
        PFER DEFG 6;
        Loop;

    IdleBreathing:
        PFED AAA 10;
        PFED BBBB 10;
        Goto Spawn;
    Run:
        Goto See;
    }
}

class CaelumPrisonerBestia : CaelumRulo
{
    Default
    {
        Tag "$CA_PRISONER_BESTIA_NAME";
        -COUNTKILL
        +FRIENDLY
        +INVULNERABLE
    }

    override void PostBeginPlay()
    {
        Super.PostBeginPlay();
        BecomeInertPrisoner();
    }

    States
    {
    Spawn:
        PBES A 10;
        Goto IdleBreathing;
    See:
        TNT1 A 0 A_JumpIf(CombatLucidityPhysicalStunRemaining > 0.0, "LucidityStun");
        PBRN ABCD 4 A_CaelumResidentChase;
        Loop;
    LucidityStun:
        PBEL A 1;
        Goto See;
    Melee:
        PBEL E 9 A_FaceTarget;
        PBEL E 0 A_CaelumMeleeAttack(372);
        PBEL A 13;
        Goto See;
    Missile:
        PBEL E 9 A_FaceTarget;
        PBEL E 0 A_CaelumSpawnSimpleElementalProjectile(
            "CaelumActorSimpleElementalProjectile", 46,
            372, CaelumConstants.ESSENCE_EARTH
        );
        PBEL A 16;
        Goto See;
    Pain:
        PBEL F 8 A_Pain;
        Goto See;
    Death:
        PBEL G 5 A_Scream;
        PBEL H 5;
        PBEL I 5 A_NoBlocking;
        PBEL JK 5;
        PBEL L -1;
        Stop;
    RestSeated:
        PBER A -1;
        Stop;
    RestLying:
        PBER B -1;
        Stop;
    CrouchIdle:
        PBER C -1;
        Stop;
    CrouchWalk:
        PBER DEFG 6;
        Loop;

    IdleBreathing:
        PBES AAA 10;
        PBES BBBB 10;
        Goto Spawn;
    Run:
        Goto See;
    }
}

class CaelumPrisonerTarot : CaelumArgento
{
    Default
    {
        Tag "$CA_PRISONER_TAROT_NAME";
        -COUNTKILL
        +FRIENDLY
        +INVULNERABLE
    }

    override void PostBeginPlay()
    {
        Super.PostBeginPlay();
        BecomeInertPrisoner();
    }

    States
    {
    Spawn:
        PTAR A 10;
        Goto IdleBreathing;
    See:
        TNT1 A 0 A_JumpIf(CombatLucidityPhysicalStunRemaining > 0.0, "LucidityStun");
        PTRN ABCD 4 A_CaelumResidentChase;
        Loop;
    LucidityStun:
        PTEL A 1;
        Goto See;
    Melee:
        PTEL E 7 A_FaceTarget;
        PTEL E 0 A_CaelumMeleeAttack(174);
        PTEL A 11;
        Goto See;
    Missile:
        PTEL E 7 A_FaceTarget;
        PTEL E 0 A_CaelumSpawnSimpleElementalProjectile(
            "CaelumActorSimpleElementalProjectile", 40,
            325, CaelumConstants.ESSENCE_FIRE
        );
        PTEL A 11;
        Goto See;
    Pain:
        PTEL F 8 A_Pain;
        Goto See;
    Death:
        PTEL G 5 A_Scream;
        PTEL H 5;
        PTEL I 5 A_NoBlocking;
        PTEL JK 5;
        PTEL L -1;
        Stop;
    RestSeated:
        PTER A -1;
        Stop;
    RestLying:
        PTER B -1;
        Stop;
    CrouchIdle:
        PTER C -1;
        Stop;
    CrouchWalk:
        PTER DEFG 6;
        Loop;

    IdleBreathing:
        PTAR AAA 10;
        PTAR BBBB 10;
        Goto Spawn;
    Run:
        Goto See;
    }
}
