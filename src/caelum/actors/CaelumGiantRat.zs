// Cuadrupedo pequeno de prueba. Comparte el perfil anatomico del toro, pero
// sus doce atributos son 1 y su masa corporal es de solo 10 kg.
class CaelumGiantRat : CaelumCombatActor
{
    const MOVEMENT_REVISION=1;
    int RatMovementRevision;
    override String GetCaelumRecognitionSound()
    {return health>0 ? "caelum/enemies/rat_alert" : "";}
    override int GetArmorRace() { return CaelumConstants.RACE_BEAST_MAN; }
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
        PainSound "caelum/enemies/rat_pain";
        DeathSound "caelum/enemies/rat_death";
        Monster;
        +FLOORCLIP
        Scale 0.11;
    }

    override void PostBeginPlay()
    {
        // Las consultas previas al alta pueden haber recalculado Speed con
        // CombatBaseSpeed aún vacío. Recuperar sólo ese cero antes de capturarlo.
        if(Speed<=0)Speed=GetDefaultByType(GetClass()).Speed;
        Super.PostBeginPlay();
        InitializeCombatProfile(1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1);
        if (AnatomyProfile != null)
        {
            AnatomyProfile.InitializeBullQuadruped();
        }
        for (int slot = 0; CombatArmor != null
            && slot < CaelumConstants.ARMOR_SLOT_COUNT; slot++)
        {
            CombatArmor.ArmorType[slot] =
                CaelumConstants.ARMOR_TYPE_BASE_CLOTHING;
            CombatArmor.Durability[slot] = 0;
        }
        RecalculateCombatStatistics();
        Speed = CombatBaseSpeed
            * CalculateActorType4Percent(CombatAgility) / 100.0;
        RatMovementRevision=MOVEMENT_REVISION;
    }

    override void Tick()
    {
        // Los saves no repiten PostBeginPlay: reparar sólo una base ausente.
        // No reiniciar salud, estados, objetivos ni drops únicos.
        if(RatMovementRevision<MOVEMENT_REVISION && CombatProfileInitialized)
        {
            if(CombatBaseSpeed<=0)
                CombatBaseSpeed=GetDefaultByType(GetClass()).Speed;
            RatMovementRevision=MOVEMENT_REVISION;
            UpdateCombatHealthEffects();
        }
        Super.Tick();
    }

    States
    {
    Spawn:
        RATG A 10 A_CaelumBudgetedLook;
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
        RATG D 6 A_CaelumBeginResourceAttack(CaelumAttackRules.NaturalAir());
        RATG D 0 A_CaelumMeleeAttack(60,"caelum/enemies/rat_bite");
        RATG A 8 A_CaelumThermalAttackFrame;
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
    // Añadido al final para conservar los índices de estados guardados.
    RestLying:
        SLRT A -1;
        Stop;
    }
}
