// Rulo is the predefined Southern Beast Warrior: a heavy close-range fighter
// whose starting values come directly from the character table.
class CaelumRulo : CaelumCombatActor
{
    Default
    {
        Tag "$CA_RULO_NAME";
        Health 3100;
        Radius 28;
        Height 80;
        Mass 95;
        Speed 8;
        MeleeRange 72;
        MinMissileChance 128;
        MaxTargetRange 768;
        Monster;
        +FLOORCLIP
    }

    override void PostBeginPlay()
    {
        Super.PostBeginPlay();
        // Physical 20, technical 18, social 7, mental 5.
        InitializeCombatProfile(20, 18, 18, 5, 18, 5);
        InitializeCombatArmor(CaelumConstants.ARMOR_TYPE_HEAVY, 1);
    }

    States
    {
    Spawn:
        RULO A 10 A_Look;
        Loop;
    See:
        TNT1 A 0 A_JumpIf(CombatLucidityPhysicalStunRemaining > 0.0, "LucidityStun");
        RULO CA 5 A_Chase;
        Loop;
    LucidityStun:
        RULO A 1;
        Goto See;
    Melee:
        RULO B 9 A_FaceTarget;
        RULO B 0 A_CaelumMeleeAttack(372);
        RULO A 13;
        Goto See;
    Missile:
        RULO D 9 A_FaceTarget;
        RULO D 0 A_CaelumSpawnProjectile(
            "CaelumRuloThrownAxe", 46,
            CaelumConstants.TEST_RULO_RANGED_DAMAGE, false
        );
        RULO A 16;
        Goto See;
    Pain:
        RULO E 8 A_Pain;
        Goto See;
    Death:
        RULO E 5 A_Scream;
        RULO F 8 A_NoBlocking;
        RULO F -1;
        Stop;
    }
}
