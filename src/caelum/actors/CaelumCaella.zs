// Caella conserva su perfil de combate para pruebas aisladas. En MAP01 se
// coloca con args[0]=1 y adopta el contrato tangible/anclado del residente.
class CaelumCaella : CaelumAnchoredResident
{
    Default
    {
        Tag "$CA_CAELLA_NAME";
        Health 1160;
        Radius 14.2;
        Height 49.8;
        Mass 80;
        Speed 10;
        MeleeRange 64;
        MinMissileChance 96;
        MaxTargetRange 1024;
        Scale 0.409091;
        Monster;
        +FLOORCLIP
    }

    override Sound GetCombatPainSound()
    {
        return "caelum/player/pain_female";
    }

    override void PostBeginPlay()
    {
        Super.PostBeginPlay();
        InitializeCombatProfile(9, 9, 9, 7, 7, 7, 11, 11, 11, 18, 18, 18);
        InitializeCombatArmor(CaelumConstants.ARMOR_TYPE_MAGIC, 1);
        ConfigureCombatMagicalRange();
    }

    // Poses anexadas al final: preservan los índices de estados de guardados previos.
    // No simulan descanso ni cambian la colisión de combate por sí solas.
    States
    {
    Spawn:
        CAID A 10 A_CaelumResidentLook;
        Goto IdleBreathing;
    See:
        TNT1 A 0 A_JumpIf(CombatLucidityPhysicalStunRemaining > 0.0, "LucidityStun");
        CARN ABCD 4 A_CaelumResidentChase;
        Loop;
    LucidityStun:
        CAEL A 1;
        Goto See;
    Melee:
        CAEL E 7 A_FaceTarget;
        CAEL E 0 A_CaelumMeleeAttack(174);
        CAEL A 11;
        Goto See;
    Missile:
        CAEL E 7 A_FaceTarget;
        CAEL E 0 A_CaelumSpawnSimpleElementalProjectile(
            "CaelumActorSimpleElementalProjectile", 40,
            325, CaelumConstants.ESSENCE_WATER
        );
        CAEL A 11;
        Goto See;
    Pain:
        CAEL F 8 A_Pain;
        Goto See;
    Death:
        CAEL G 5 A_Scream;
        CAEL H 5;
        CAEL I 5 A_NoBlocking;
        CAEL JK 5;
        CAEL L -1;
        Stop;
    RestSeated:
        RSCA A -1;
        Stop;
    RestLying:
        RSCA B -1;
        Stop;
    CrouchIdle:
        RSCA C -1;
        Stop;
    CrouchWalk:
        RSCA DEFG 6;
        Loop;

    // Estados nuevos al final: conservan los índices de partidas anteriores.
    IdleBreathing:
        CAID AAA 10 A_CaelumResidentLook;
        CAID BBBB 10 A_CaelumResidentLook;
        Goto Spawn;
    Run:
        Goto See;
    }
}
