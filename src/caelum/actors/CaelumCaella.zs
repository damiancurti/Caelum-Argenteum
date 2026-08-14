// Caella is a visual counterpart to Argento and deliberately inherits his
// complete starting-character-scale combat profile for neutral comparisons.
class CaelumCaella : CaelumArgento
{
    Default
    {
        Tag "$CA_CAELLA_NAME";
    }

    States
    {
    Spawn:
        CAEL A 10 A_Look;
        Loop;
    See:
        TNT1 A 0 A_JumpIf(CombatLucidityPhysicalStunRemaining > 0.0, "LucidityStun");
        CAEL CA 4 A_Chase;
        Loop;
    LucidityStun:
        CAEL A 1;
        Goto See;
    Melee:
        CAEL B 7 A_FaceTarget;
        CAEL B 0 A_CaelumMeleeAttack(372);
        CAEL B 11;
        Goto See;
    Missile:
        CAEL D 7 A_FaceTarget;
        CAEL D 0 A_CaelumSpawnProjectile(
            "CaelumCaellaMagicBolt", 40,
            CaelumConstants.TEST_ACTOR_RANGED_DAMAGE, true
        );
        CAEL A 11;
        Goto See;
    Pain:
        CAEL E 8 A_Pain;
        Goto See;
    Death:
        CAEL E 5 A_Scream;
        CAEL F 8 A_NoBlocking;
        CAEL F -1;
        Stop;
    }
}
