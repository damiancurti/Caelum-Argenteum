// Ronnie is the predefined Northern Caelith Explorer. His technical and mental
// focus makes him faster and much stronger at range than in a sword exchange.
class CaelumRonnie : CaelumCombatActor
{
    Default
    {
        Tag "$CA_RONNIE_NAME";
        Health 1150;
        Radius 20;
        Height 72;
        Mass 60;
        Speed 12;
        MeleeRange 64;
        MinMissileChance 64;
        MaxTargetRange 1280;
        Monster;
        +FLOORCLIP
    }

    override void PostBeginPlay()
    {
        Super.PostBeginPlay();
        // Physical 5, technical 18, social 7, mental 20.
        InitializeCombatProfile(5, 18, 18, 20, 18, 20);
        InitializeCombatArmor(CaelumConstants.ARMOR_TYPE_LIGHT, 1);
    }

    States
    {
    Spawn:
        RONI A 10 A_Look;
        Loop;
    See:
        TNT1 A 0 A_JumpIf(CombatLucidityPhysicalStunRemaining > 0.0, "LucidityStun");
        RONI CA 4 A_Chase;
        Loop;
    LucidityStun:
        RONI A 1;
        Goto See;
    Melee:
        RONI B 7 A_FaceTarget;
        RONI B 0 A_CaelumMeleeAttack(138);
        RONI A 10;
        Goto See;
    Missile:
        RONI D 7 A_FaceTarget;
        RONI D 0 A_CaelumSpawnProjectile(
            "CaelumRonnieMagicBolt", 40,
            CaelumConstants.TEST_RONNIE_MAGIC_DAMAGE, true
        );
        RONI A 9;
        Goto See;
    Pain:
        RONI E 8 A_Pain;
        Goto See;
    Death:
        RONI E 5 A_Scream;
        RONI F 8 A_NoBlocking;
        RONI F -1;
        Stop;
    }
}
