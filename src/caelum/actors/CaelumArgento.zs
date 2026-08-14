// Argento is the first hostile humanoid test enemy. His values reproduce one
// legal newly-created Southern Federal Warrior profile rather than borrowing
// Doom's monster balance.
class CaelumArgento : CaelumCombatActor
{
    Default
    {
        Tag "$CA_ARGENTO_NAME";
        Health 3100;
        Radius 21;
        Height 72;
        Mass 80;
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
        // Southern Federal Warrior test profile: Toughness 20,
        // Resilience/Agility 16, and Patience 5.
        InitializeCombatProfile(20, 16, 16, 5, 16, 5);
        InitializeCombatArmor(CaelumConstants.ARMOR_TYPE_LIGHT, 1);
    }

    States
    {
    Spawn:
        ARGO A 10 A_Look;
        Loop;
    See:
        TNT1 A 0 A_JumpIf(CombatLucidityPhysicalStunRemaining > 0.0, "LucidityStun");
        ARGO CA 4 A_Chase;
        Loop;
    LucidityStun:
        ARGO A 1;
        Goto See;
    Melee:
        ARGO B 7 A_FaceTarget;
        ARGO B 0 A_CaelumMeleeAttack(372);
        ARGO B 11;
        Goto See;
    Missile:
        ARGO D 7 A_FaceTarget;
        ARGO D 0 A_CaelumSpawnProjectile(
            "CaelumArgentoMagicBolt", 40,
            CaelumConstants.TEST_ACTOR_RANGED_DAMAGE, true
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
