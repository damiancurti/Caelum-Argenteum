// Argento es un enemigo humanoide de prueba con un perfil inicial valido.
class CaelumArgento : CaelumCombatActor
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
        Monster;
        +FLOORCLIP
    }

    override void PostBeginPlay()
    {
        Super.PostBeginPlay();
        // Humano Mago de Batalla: fisico 9, tecnico 7, social 11 y mental 18.
        InitializeCombatProfile(9, 9, 9, 7, 7, 7, 11, 11, 11, 18, 18, 18);
        InitializeCombatArmor(CaelumConstants.ARMOR_TYPE_LIGHT, 1);
        ConfigureCombatMagicalRange();
    }

    States
    {
    Spawn:
        ARGO A 10 A_Look;
        Loop;
    See:
        TNT1 A 0 A_JumpIf(CombatLucidityPhysicalStunRemaining > 0.0, "LucidityStun");
        ARGO CA 4 A_CaelumBudgetedChase;
        Loop;
    LucidityStun:
        ARGO A 1;
        Goto See;
    Melee:
        ARGO B 7 A_FaceTarget;
        ARGO B 0 A_CaelumMeleeAttack(174);
        ARGO B 11;
        Goto See;
    Missile:
        ARGO D 7 A_FaceTarget;
        ARGO D 0 A_CaelumSpawnSimpleElementalProjectile(
            "CaelumActorSimpleElementalProjectile", 40,
            325, CaelumConstants.ESSENCE_FIRE
        );
        ARGO A 11;
        Goto See;
    Pain:
        ARGO E 8 A_Pain;
        Goto See;
    Death:
        ARGO E 5 A_Scream;
        ARGO F 8 A_NoBlocking;
        ARGO F -1;
        Stop;
    }
}
