// Ronnie es el caelith explorador norteno predefinido, veloz y orientado al rango.
class CaelumRonnie : CaelumCombatActor
{
    Default
    {
        Tag "$CA_RONNIE_NAME";
        Health 4340;
        Radius 17.8;
        Height 62.2;
        Mass 140;
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
        // Fisico 20, tecnico 18, social 5 y mental 7.
        InitializeCombatProfile(20, 18, 18, 7, 18, 7);
        InitializeCombatArmor(CaelumConstants.ARMOR_TYPE_MEDIUM, 1);
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
        RONI B 0 A_CaelumMeleeAttack(372);
        RONI A 10;
        Goto See;
    Missile:
        RONI D 7 A_FaceTarget;
        RONI D 0 A_CaelumSpawnProjectile(
            "CaelumRonnieMagicBolt", 40,
            154, true
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
