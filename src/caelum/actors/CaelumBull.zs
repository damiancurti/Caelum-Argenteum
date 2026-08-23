// Primer monstruo cuadrúpedo de Caelum. El perfil anatómico separa cabeza,
// torso y cuatro piernas; la cabeza sólo se resuelve en el frente del actor.
class CaelumBull : CaelumCombatActor
{
    Default
    {
        Tag "$CA_BULL_NAME";
        Health 9200;
        Radius 15.6;
        Height 51.8;
        Mass 900;
        Speed 7;
        MeleeRange 64;
        MaxTargetRange 1024;
        Monster;
        +FLOORCLIP
    }

    override void PostBeginPlay()
    {
        Super.PostBeginPlay();
        // Físicos 40, técnicos 20, sociales 2 y mentales 2.
        InitializeCombatProfile(40, 40, 40, 20, 20, 20, 2, 2, 2, 2, 2, 2);
        AnatomyProfile.InitializeBullQuadruped();
        // El toro no lleva armadura: conserva las regiones naturales.
        for (int slot = 0; slot < CaelumConstants.ARMOR_SLOT_COUNT; slot++)
        {
            CombatArmor.ArmorType[slot] =
                CaelumConstants.ARMOR_TYPE_BASE_CLOTHING;
            CombatArmor.Durability[slot] = 0;
        }
        RecalculateCombatStatistics();
    }

    States
    {
    Spawn:
        BULL A 10 A_Look;
        Loop;
    See:
        TNT1 A 0 A_JumpIf(
            CombatLucidityPhysicalStunRemaining > 0.0,
            "LucidityStun"
        );
        BULL DE 4 A_Chase;
        Loop;
    LucidityStun:
        BULL A 1;
        Goto See;
    Melee:
        BULL F 5 A_FaceTarget;
        BULL G 0 A_CaelumMeleeAttack(120);
        BULL G 7;
        Goto See;
    Pain:
        BULL H 8 A_Pain;
        Goto See;
    Death:
        BULL I 5 A_Scream;
        BULL JKLM 5;
        BULL N 5 A_NoBlocking;
        BULL N -1;
        Stop;
    }
}
