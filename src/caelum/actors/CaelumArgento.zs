// Argento conserva su perfil de combate para pruebas aisladas. En MAP01 se
// coloca con args[0]=1 y adopta el contrato tangible/anclado del residente.
class CaelumArgento : CaelumAnchoredResident
{
    Default
    {
        Tag "$CA_ARGENTO_NAME";
        Health 1740;
        Radius 17.8;
        Height 62.2;
        Mass 120;
        Speed 10;
        MeleeRange 64;
        MinMissileChance 96;
        MaxTargetRange 1024;
        Scale 0.409091;
        Monster;
        +FLOORCLIP
    }

    override void PostBeginPlay()
    {
        Super.PostBeginPlay();
        InitializeCombatProfile(9, 9, 9, 7, 7, 7, 11, 11, 11, 18, 18, 18);
        InitializeCombatArmor(CaelumConstants.ARMOR_TYPE_LIGHT, 1);
        ConfigureCombatMagicalRange();
    }

    // Poses anexadas al final: preservan los índices de estados de guardados previos.
    // No simulan descanso ni cambian la colisión de combate por sí solas.
    States
    {
    Spawn:
        ARGO A 10 A_CaelumResidentLook;
        Loop;
    See:
        TNT1 A 0 A_JumpIf(CombatLucidityPhysicalStunRemaining > 0.0, "LucidityStun");
        ARGO BCDC 4 A_CaelumResidentChase;
        Loop;
    LucidityStun:
        ARGO A 1;
        Goto See;
    Melee:
        ARGO E 7 A_FaceTarget;
        ARGO E 0 A_CaelumMeleeAttack(174);
        ARGO A 11;
        Goto See;
    Missile:
        ARGO E 7 A_FaceTarget;
        ARGO E 0 A_CaelumSpawnSimpleElementalProjectile(
            "CaelumActorSimpleElementalProjectile", 40,
            325, CaelumConstants.ESSENCE_FIRE
        );
        ARGO A 11;
        Goto See;
    Pain:
        ARGO F 8 A_Pain;
        Goto See;
    Death:
        ARGO G 5 A_Scream;
        ARGO H 5;
        ARGO I 5 A_NoBlocking;
        ARGO JK 5;
        ARGO L -1;
        Stop;
    RestSeated:
        RSAR A -1;
        Stop;
    RestLying:
        RSAR B -1;
        Stop;
    CrouchIdle:
        RSAR C -1;
        Stop;
    CrouchWalk:
        RSAR DEFG 6;
        Loop;
    }
}
