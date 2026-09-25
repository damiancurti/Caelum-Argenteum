// Ronnie conserva su perfil de combate para pruebas aisladas. En MAP01 se
// coloca con args[0]=1 y adopta el contrato tangible/anclado del residente.
class CaelumRonnie : CaelumAnchoredResident
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
        Scale 0.409091;
        Monster;
        +FLOORCLIP
    }

    override Sound GetCombatPainSound()
    {
        return "caelum/player/pain_male";
    }

    override void PostBeginPlay()
    {
        Super.PostBeginPlay();
        InitializeCombatProfile(20, 20, 20, 18, 18, 18, 5, 5, 5, 7, 7, 7);
        InitializeCombatArmor(CaelumConstants.ARMOR_TYPE_MEDIUM, 1);
        ConfigureCombatMagicalRange();
    }

    // Poses anexadas al final: preservan los índices de estados de guardados previos.
    // No simulan descanso ni cambian la colisión de combate por sí solas.
    States
    {
    Spawn:
        ROID A 10 A_CaelumResidentLook;
        Goto IdleBreathing;
    See:
        TNT1 A 0 A_JumpIf(CombatLucidityPhysicalStunRemaining > 0.0, "LucidityStun");
        RORN ABCD 4 A_CaelumResidentChase;
        Loop;
    LucidityStun:
        RONI A 1;
        Goto See;
    Melee:
        RONI E 7 A_FaceTarget;
        RONI E 0 A_CaelumMeleeAttack(372);
        RONI A 10;
        Goto See;
    Missile:
        RONI E 7 A_FaceTarget;
        RONI E 0 A_CaelumSpawnSimpleElementalProjectile(
            "CaelumActorSimpleElementalProjectile", 40,
            154, CaelumConstants.ESSENCE_WIND
        );
        RONI A 9;
        Goto See;
    Pain:
        RONI F 8 A_Pain;
        Goto See;
    Death:
        RONI G 5 A_Scream;
        RONI H 5;
        RONI I 5 A_NoBlocking;
        RONI JK 5;
        RONI L -1;
        Stop;
    RestSeated:
        RSRO A -1;
        Stop;
    RestLying:
        RSRO B -1;
        Stop;
    CrouchIdle:
        RSRO C -1;
        Stop;
    CrouchWalk:
        RSRO DEFG 6;
        Loop;

    // Estados nuevos al final: conservan los índices de partidas anteriores.
    IdleBreathing:
        ROID AAA 10 A_CaelumResidentLook;
        ROID BBBB 10 A_CaelumResidentLook;
        Goto Spawn;
    Run:
        Goto See;
    }
}
