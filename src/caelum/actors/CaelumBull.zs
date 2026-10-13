// Primer monstruo cuadrúpedo de Caelum. El perfil anatómico separa cabeza,
// torso y cuatro piernas; la cabeza sólo se resuelve en el frente del actor.
class CaelumBull : CaelumCombatActor
{
    override int GetArmorRace() { return CaelumConstants.RACE_BEAST_MAN; }
    bool BullChargeActive;
    double BullRunningSpeed;
    double BullChargeSpeed;
    int BullChargeRevision;

    double GetBullRunningSpeed()
    {
        // Es el máximo final; no vuelve a multiplicarse por Agilidad ni clase.
        return CaelumBullRules.MaximumSpeed();
    }

    bool BullChargeInterrupted()
    {
        return health<=0 || CaelumBolas.Restrained(self) || CaelumBolas.Interrupted(self)
            || (ElementalStatus!=null && ElementalStatus.GetMovementMultiplier()<=0);
    }

    override double GetHorizontalImpactAbsorptionSpeed()
    {
        if(!BullChargeActive || BullChargeInterrupted())return 0;
        return GetBiologicalLandingAbsorptionSpeed();
    }

    override double GetHazardPressureAbsorptionSpeed(double delta)
    {
        // Conserva la ruta anterior de presión sin muestras ponderadas.
        // Las muestras ordinarias de roca siguen sin amortiguación NPC.
        if(!BullChargeActive || BullChargeInterrupted())return 0;
        double total=Mass+GetAttackCarriedWeight();
        double baseline=CaelumPhysicsUnits.JumpVelocity(Mass,total,0);
        double impaired=CaelumPhysicsUnits.JumpVelocity(Mass,total,CombatAgility)
            *CombatHealthPerformanceMultiplier
            *(ElementalStatus!=null ? ElementalStatus.GetMovementMultiplier() : 1);
        return Max(0.0,delta)*Clamp(impaired/Max(0.0001,baseline)-1,0.0,
            CaelumBullRules.HAZARD_PRESSURE_CUSHION_CAP);
    }

    void EnsureBullChargeRevision()
    {
        if(BullChargeRevision>=CaelumBullRules.REVISION)return;
        CollisionEffectiveMassMultiplier=1;
        BullRunningSpeed=GetBullRunningSpeed();
        // Una embestida anterior conserva su avance, limitado al nuevo máximo.
        BullChargeSpeed=BullChargeActive ? Min(BullRunningSpeed,Vel.XY.Length()) : 0;
        if(BullChargeActive && Vel.XY.Length()>BullRunningSpeed)
        {vector2 limited=Vel.XY.Unit()*BullRunningSpeed;Vel.X=limited.X;Vel.Y=limited.Y;}
        BullChargeRevision=CaelumBullRules.REVISION;
        if(BullChargeActive)
        {
            if(BullChargeInterrupted() || target==null || target.health<=0)StopBullCharge();
            else SetStateLabel("BullChargeLoop");
        }
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
        BullChargeSpeed = 0;
        CombatAirSpending = false;
        CollisionEffectiveMassMultiplier = 1.0;
        Vel.X = 0.0;
        Vel.Y = 0.0;
        if(health>0 && InStateSequence(CurState,FindState("BullChargeLoop")))SetState(SeeState);
    }

    void BeginBullCharge()
    {
        EnsureBullChargeRevision();
        if(BullChargeInterrupted()){StopBullCharge();return;}
        double firstTicCost = GetBullRunningAirCostPerSecond() / TICRATE;
        if (CurrentCombatAir < firstTicCost*CaelumThermalEffects.HeatCost(self))
        {
            StopBullCharge();
            AttackResourceMagical=false;AttackResourceWeapon=-1;AttackResourceBaseCost=CaelumAttackRules.NaturalAir();
            WaitForAttackResource();
            return;
        }
        BullChargeActive = true;
        CombatAirSpending = true;
        CollisionEffectiveMassMultiplier = 1;
        BullChargeSpeed=0;
        Vel.X=0;Vel.Y=0;
        CaelumThermalMotion.SetVelocity(self);
        SetStateLabel("BullChargeLoop");
    }

    void FinishBullCharge()
    {
        StopBullCharge();
        if(!BullChargeInterrupted())SetStateLabel("BullChargeFinish");
    }

    action void A_CaelumBullChase()
    {
        let bull=CaelumBull(self);
        if(bull==null || bull.PulseResourceRecovery())return;
        if(!bull.BullChargeInterrupted() && bull.target!=null && bull.target.health>0
            && bull.Distance2D(bull.target)<=bull.MaxTargetRange && bull.CheckSight(bull.target))
        {bull.SetState(bull.MeleeState);return;}
        bull.A_CaelumBudgetedChase();
    }

    override void CollidedWith(Actor other,bool passive)
    {
        bool charging=BullChargeActive;
        Super.CollidedWith(other,passive);
        // Espera a que ambos cuerpos reciban el impacto antes de retirar la defensa.
        if(charging && BullChargeActive && other!=null && other.bSolid)FinishBullCharge();
    }

    // Inicia la carrera; Tick sigue al blanco móvil durante la aceleración.
    // No aplica daño ni empuje melee: el contacto lo resuelve Impact Physics.
    action void A_CaelumBeginBullCharge()
    {
        CaelumBull bull = CaelumBull(self);
        if (bull == null) { return; }
        if(bull.ResourceRecoveryActive() || bull.target==null || bull.target.health<=0
            || bull.Distance2D(bull.target)>bull.MaxTargetRange || !bull.CheckSight(bull.target))return;
        if (!bull.BeginCaelumDiagnosticAttack())
        {
            bull.StopBullCharge();
            return;
        }
        bull.tics=int(Ceil(bull.tics/CaelumThermalEffects.Speed(bull)));
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

    override Sound GetCombatPainSound()
    {
        return "caelum/enemies/bull_pain";
    }

    override void PostBeginPlay()
    {
        Super.PostBeginPlay();
        // Físicos y técnicos 20; sociales y mentales 2.
        InitializeCombatProfile(20, 20, 20, 20, 20, 20, 2, 2, 2, 2, 2, 2);
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
        // La base cuadrúpeda 10 también respeta Agilidad Tipo 2, igual que las
        // estadísticas derivadas que convertirán sus atributos en movimiento.
        Speed = CombatBaseSpeed
            * CalculateActorType4Percent(CombatAgility) / 100.0;
        BullRunningSpeed = GetBullRunningSpeed();
        StopBullCharge();
        BullChargeRevision=CaelumBullRules.REVISION;
    }

    override void Tick()
    {
        EnsureBullChargeRevision();
        if (BullChargeActive)
        {
            if(BullChargeInterrupted() || target==null || target.health<=0
                || Distance2D(target)>MaxTargetRange || !CheckSight(target))
            {StopBullCharge();if(health>0 && !BullChargeInterrupted())SetState(SeeState);}
        }
        if(BullChargeActive)
        {
            double ticCost = GetBullRunningAirCostPerSecond() / TICRATE;
            if (!TrySpendCombatAir(ticCost))
            {
                StopBullCharge();AttackResourceMagical=false;AttackResourceWeapon=-1;
                AttackResourceBaseCost=CaelumAttackRules.NaturalAir();WaitForAttackResource();
            }
            else
            {
                A_FaceTarget();
                BullChargeSpeed=Min(GetBullRunningSpeed(),BullChargeSpeed+CaelumBullRules.SpeedPerTic());
                double impaired=Clamp(CombatHealthPerformanceMultiplier*CaelumThermalEffects.Speed(self)
                    *(ElementalStatus!=null ? ElementalStatus.GetMovementMultiplier() : 1),0.0,1.0);
                double speed=BullChargeSpeed*impaired;
                Vel.X=Cos(Angle)*speed;Vel.Y=Sin(Angle)*speed;
                CaelumThermalMotion.SetVelocity(self);
            }
        }
        Super.Tick();
        if(BullChargeActive && (MovementBlockingLine!=null || BlockingLine!=null))FinishBullCharge();
        if(BullChargeActive && BullChargeInterrupted())StopBullCharge();
    }

    States
    {
    Spawn:
        BUID A 10 A_CaelumBudgetedLook;
        Goto IdleBreathing;
    See:
        TNT1 A 0 A_JumpIf(
            CombatLucidityPhysicalStunRemaining > 0.0,
            "LucidityStun"
        );
        BURN AB 4 A_CaelumBullChase;
        Goto RunSecondHalf;
    LucidityStun:
        BULL A 1;
        Goto See;
    Melee:
        // Conserva la embestida y restaura la cornada directa al final del
        // avance. Sus 45 puntos son la base previa a Fuerza, masa y defensas.
        BULL F 3 A_FaceTarget;
        BULL G 5 A_CaelumBeginBullCharge;
        BULL G 0 A_CaelumProfiledMeleeAttack(
            CaelumConstants.BULL_GORE_BASE_DAMAGE
        );
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

    // Estados nuevos al final: conservan los índices de partidas anteriores.
    IdleBreathing:
        BUID AAA 10 A_CaelumBudgetedLook;
        BUID BBBB 10 A_CaelumBudgetedLook;
        Goto Spawn;
    RunSecondHalf:
        TNT1 A 0 A_JumpIf(CombatLucidityPhysicalStunRemaining > 0.0, "LucidityStun");
        BURN CD 4 A_CaelumBullChase;
        Goto See;
    Run:
        Goto See;
    BullChargeLoop:
        BURN ABCD 4;
        Loop;
    BullChargeFinish:
        BULL G 0 A_CaelumProfiledMeleeAttack(CaelumConstants.BULL_GORE_BASE_DAMAGE);
        Goto See;
    }
}
