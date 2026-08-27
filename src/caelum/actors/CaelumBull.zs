// Primer monstruo cuadrúpedo de Caelum. El perfil anatómico separa cabeza,
// torso y cuatro piernas; la cabeza sólo se resuelve en el frente del actor.
class CaelumBull : CaelumCombatActor
{
    bool BullChargeActive;
    double BullRunningSpeed;

    double GetBullRunningSpeed()
    {
        double runToWalkRatio =
            CaelumConstants.GZDOOM_BASE_MAX_RUN_SPEED
            / CaelumConstants.GZDOOM_BASE_MAX_WALK_SPEED;
        // Speed ya contiene la marcha base modificada por Agilidad. La
        // embestida conserva sobre ese valor la relación nativa 2:1.
        return Speed * runToWalkRatio;
    }

    double GetBullRunningAirCostPerSecond()
    {
        // El toro no tiene carga de inventario. Su masa corporal conserva el
        // mismo multiplicador base de consumo que un personaje jugador.
        return CaelumConstants.RUN_AIR_COST_PER_SECOND
            * Max(0.0, Mass / 100.0);
    }

    void StopBullCharge()
    {
        BullChargeActive = false;
        CombatAirSpending = false;
        CollisionEffectiveMassMultiplier = 1.0;
        Vel.X = 0.0;
        Vel.Y = 0.0;
    }

    void BeginBullCharge()
    {
        double firstTicCost = GetBullRunningAirCostPerSecond() / TICRATE;
        if (CurrentCombatAir < firstTicCost)
        {
            StopBullCharge();
            return;
        }
        BullChargeActive = true;
        CombatAirSpending = true;
        CollisionEffectiveMassMultiplier =
            CaelumConstants.SHIELD_TOWER_COMBAT_MASS_MULTIPLIER;
        Vel.X = Cos(Angle) * BullRunningSpeed;
        Vel.Y = Sin(Angle) * BullRunningSpeed;
    }

    // Inicia una embestida física en la dirección ya fijada por A_FaceTarget.
    // No aplica daño ni empuje melee: el contacto lo resuelve Impact Physics.
    action void A_CaelumBeginBullCharge()
    {
        CaelumBull bull = CaelumBull(self);
        if (bull == null) { return; }
        if (!bull.BeginCaelumDiagnosticAttack())
        {
            bull.StopBullCharge();
            return;
        }
        bull.BeginBullCharge();
    }

    action void A_CaelumEndBullCharge()
    {
        CaelumBull bull = CaelumBull(self);
        if (bull == null) { return; }
        bull.StopBullCharge();
    }

    Default
    {
        Tag "$CA_BULL_NAME";
        Health 9200;
        Radius 15.6;
        Height 51.8;
        Mass 900;
        Speed 10;
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
        if (AnatomyProfile != null)
        {
            AnatomyProfile.InitializeBullQuadruped();
        }
        // El toro no lleva armadura: conserva las regiones naturales.
        for (int slot = 0; CombatArmor != null
            && slot < CaelumConstants.ARMOR_SLOT_COUNT; slot++)
        {
            CombatArmor.ArmorType[slot] =
                CaelumConstants.ARMOR_TYPE_BASE_CLOTHING;
            CombatArmor.Durability[slot] = 0;
        }
        RecalculateCombatStatistics();
        // La base cuadrúpeda 10 también respeta Agilidad Tipo 4, igual que las
        // estadísticas derivadas que convertirán sus atributos en movimiento.
        Speed = CombatBaseSpeed
            * CalculateActorType4Percent(CombatAgility) / 100.0;
        BullRunningSpeed = GetBullRunningSpeed();
        StopBullCharge();
    }

    override void Tick()
    {
        Super.Tick();
        if (BullChargeActive)
        {
            double ticCost = GetBullRunningAirCostPerSecond() / TICRATE;
            if (!TrySpendCombatAir(ticCost)) { StopBullCharge(); }
        }
    }

    States
    {
    Spawn:
        BULL A 10 A_CaelumBudgetedLook;
        Loop;
    See:
        TNT1 A 0 A_JumpIf(
            CombatLucidityPhysicalStunRemaining > 0.0,
            "LucidityStun"
        );
        BULL DE 4 A_CaelumBudgetedChase;
        Loop;
    LucidityStun:
        BULL A 1;
        Goto See;
    Melee:
        // Conserva el ciclo base de ocho tics, pero la cornada ya no es un
        // ataque directo. Tras apuntar, el toro recorre cinco tics en Charge.
        BULL F 3 A_FaceTarget;
        BULL G 5 A_CaelumBeginBullCharge;
        BULL G 0 A_CaelumEndBullCharge;
        Goto See;
    Pain:
        BULL H 0 A_CaelumEndBullCharge;
        BULL H 8 A_Pain;
        Goto See;
    Death:
        BULL I 0 A_CaelumEndBullCharge;
        BULL I 5 A_Scream;
        BULL JKLM 5;
        BULL N 5 A_NoBlocking;
        BULL N -1;
        Stop;
    }
}
