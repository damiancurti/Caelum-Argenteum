// Rulo es el hombre bestia guerrero sureno predefinido, pesado y cuerpo a cuerpo.
class CaelumRulo : CaelumCombatActor
{
    Default
    {
        Tag "$CA_RULO_NAME";
        Health 6200;
        Radius 21.3;
        Height 74.7;
        Mass 200;
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
        // Fisico 20, tecnico 18, social 6 y mental 2.
        InitializeCombatProfile(20, 18, 18, 2, 18, 2);
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
            372, false
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
