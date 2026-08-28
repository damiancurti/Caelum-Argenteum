// Caella posee un perfil de combate propio como duende cleriga predefinida.
class CaelumCaella : CaelumCombatActor
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
        // 72/176 conserva la altura visual mundial anterior.
        Scale 0.409091;
        Monster;
        +FLOORCLIP
    }

    override void PostBeginPlay()
    {
        Super.PostBeginPlay();
        // Duende cleriga: fisico 9, tecnico 7, social 11 y mental 18.
        InitializeCombatProfile(9, 9, 9, 7, 7, 7, 11, 11, 11, 18, 18, 18);
        InitializeCombatArmor(CaelumConstants.ARMOR_TYPE_MAGIC, 1);
        ConfigureCombatMagicalRange();
    }

    States
    {
    Spawn:
        CAEL A 10 A_CaelumBudgetedLook;
        Loop;
    See:
        TNT1 A 0 A_JumpIf(CombatLucidityPhysicalStunRemaining > 0.0, "LucidityStun");
        CAEL BCDC 4 A_CaelumBudgetedChase;
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
    }
}
