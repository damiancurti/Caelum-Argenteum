// Cuadrupedo pequeno de prueba. Comparte el perfil anatomico del toro, pero
// sus doce atributos son 1 y su masa corporal es de solo 10 kg.
class CaelumGiantRat : CaelumCombatActor
{
    Default
    {
        Tag "$CA_GIANT_RAT_NAME";
        Health 10;
        Radius 4.0;
        Height 13.1;
        Mass 10;
        Speed 10;
        MeleeRange 24;
        MaxTargetRange 768;
        Monster;
        +FLOORCLIP
        Scale 0.11;
    }

    override void PostBeginPlay()
    {
        Super.PostBeginPlay();
        InitializeCombatProfile(1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1);
        AnatomyProfile.InitializeBullQuadruped();
        for (int slot = 0; slot < CaelumConstants.ARMOR_SLOT_COUNT; slot++)
        {
            CombatArmor.ArmorType[slot] =
                CaelumConstants.ARMOR_TYPE_BASE_CLOTHING;
            CombatArmor.Durability[slot] = 0;
        }
        RecalculateCombatStatistics();
        Speed = CombatBaseSpeed
            * CalculateActorType4Percent(CombatAgility) / 100.0;
    }

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
        RATG BC 4 A_CaelumBudgetedChase;
        Loop;
    LucidityStun:
        RATG A 1;
        Goto See;
    Melee:
        RATG D 6 A_FaceTarget;
        RATG D 0 A_CaelumMeleeAttack(60);
        RATG A 8;
        Goto See;
    Pain:
        RATG E 6 A_Pain;
        Goto See;
    Death:
        RATG F 4 A_Scream;
        RATG GHIJKL 4;
        RATG M 4 A_NoBlocking;
        RATG M -1;
        Stop;
    }
}
