// Base de combate compartida por los actores originales de Caelum.
// Gestiona anatomia, armadura localizada, refuerzo, durabilidad, resistencias,
// evasion, dolor, adrenalina y efectos de los estados de salud.
class CaelumCombatActor : Actor
{
    bool NextRangedSecondaryElement;
    Actor CaelumRecognitionTarget;

    CaelumAnatomyProfile AnatomyProfile;
    CaelumArmorModel CombatArmor;
    CaelumElementalStatus ElementalStatus;
    int CombatMaximumHealth;
    int CombatToughness;
    int CombatResilience;
    int CombatAgility;
    int CombatPatience;
    int CombatDexterity;
    int CombatInsight;
    int CombatEffectiveDexterity;
    int CombatEffectiveInsight;
    int CombatStrength;
    int CombatConstitution;
    int CombatIntelligence;
    int CombatEffectiveIntelligence;
    int CombatCharisma;
    int CombatEmpathy;
    int CombatEloquence;
    double CurrentCombatAnima;
    double MaximumCombatAnima;
    double CombatAnimaRegenerationPerSecond;
    double CurrentCombatAir;
    double MaximumCombatAir;
    double CombatAirRegenerationPerSecond;
    bool CombatAirSpending;
    bool CombatProfileInitialized;
    double CombatBaseSpeed;
    double CombatPhysicalPowerMultiplier;
    double CombatPhysicalPushMultiplier;
    double CombatMagicalPushMultiplier;

    // V4.25.1 — física de colisión compartida con el jugador.
    double CollisionDamageMultiplier;
    double CollisionEffectiveMassMultiplier;
    int LastImpactKind;
    double LastImpactDeltaSpeed;
    double LastImpactEquivalentTics;
    double LastImpactDamagePercent;
    int LastImpactBaseDamage;
    double LastImpactEffectiveMass;
    double LastImpactOtherEffectiveMass;
    double LastImpactClosingSpeed;
    double LastImpactImpulse;
    double LastImpactToughnessMultiplier;
    double LastImpactArmorDefensePercent;
    int LastImpactFinalDamage;

    bool ImpactGroundTrackingInitialized;
    bool ImpactWasGroundedLastTick;
    double LastImpactFallingVelocityZ;
    bool ImpactWasWallBlockedLastTick;
    int ImpactStaticClearTics;
    double LastImpactToughnessPercent;
    double LastImpactPostToughnessPercent;
    double LastImpactWeightedVulnerabilityMultiplier;
    double LastImpactWeightedArmorDefensePercent;
    double LastImpactHeadContactWeight;
    double LastImpactLucidityLoss;
    double LastImpactContactMinimumHeightRatio;
    double LastImpactContactMaximumHeightRatio;
    Array<ImpactContactState> ImpactContacts;
    bool DisableCaelumImpactContacts;
    bool CaelumDiagnosticPassiveAI;
    int ImpactDiagnosticCollisionCallbacks;
    int ImpactDiagnosticUniquePairTicks;
    int ImpactDiagnosticDuplicateCallbacks;
    int ImpactDiagnosticRestingCallbacks;
    int ImpactDiagnosticContactsCreated;
    int ImpactDiagnosticContactsRemoved;
    int ImpactDiagnosticAttackAttempts;
    int ImpactDiagnosticSuppressedAttacks;
    int ImpactDiagnosticDeferredAttacks;
    int ImpactDiagnosticFriendlyFirePrevented;
    int ImpactDiagnosticChaseAttempts;
    int ImpactDiagnosticChaseUpdates;
    int ImpactDiagnosticChaseDeferred;
    int ImpactDiagnosticChasePhaseDeferred;
    int ImpactDiagnosticChaseBudgetDeferred;
    int ImpactDiagnosticChaseDisabled;
    int ImpactDiagnosticLookAttempts;
    int ImpactDiagnosticLookUpdates;
    int ImpactDiagnosticLookDeferred;
    int ImpactDiagnosticLookPhaseDeferred;
    int ImpactDiagnosticLookBudgetDeferred;
    int ImpactDiagnosticLookDisabled;
    int ImpactDiagnosticProjectilesSpawned;
    int ImpactDiagnosticProjectileSpawnFailures;
    int ImpactDiagnosticProjectileImpacts;
    int ImpactDiagnosticProjectilesExpired;
    int ImpactDiagnosticProjectilesDestroyed;
    ImpactBody ImpactSelfBodyScratch;
    ImpactBody ImpactOtherBodyScratch;
    ImpactResult ImpactResultScratch;
    double LastImpactRawDeltaSpeed;
    double LastImpactBiologicalAbsorptionSpeed;

    // El campo masivo conserva fases deterministas por actor y lee los ajustes
    // efectivos desde un único coordinador. Sólo el coordinador consulta CVars.
    bool CaelumMassAIScheduleActive;
    bool CaelumMassAttacksEnabled;
    bool CaelumMassLookEnabled;
    bool CaelumMassChaseEnabled;
    int CaelumMassLookInterval;
    int CaelumMassChaseInterval;
    int CaelumMassLookBudgetPerTic;
    int CaelumMassChaseBudgetPerTic;
    int CaelumMassSquadSize;
    bool CaelumMassFollowerMovementEnabled;
    double CaelumMassFollowerSpeedScale;
    int CaelumMassAttackInterval;
    int CaelumMassLookPhaseKey;
    int CaelumMassChasePhaseKey;
    int CaelumMassAttackPhaseKey;
    bool CaelumMassSquadLeader;
    CaelumMassAIScheduler CaelumMassScheduler;

    int ImpactDiagnosticFollowerPulses;
    int ImpactDiagnosticFollowerMoveUpdates;
    int ImpactDiagnosticFollowerMoveStops;
    int ImpactDiagnosticSharedTargetAdoptions;

    double CurrentCombatAdrenaline;
    double MaximumCombatAdrenaline;
    double CombatTimeRemaining;
    double EffectiveCombatEvasionChance;
    double CombatHealthPerformanceMultiplier;
    double CombatHealthPainMultiplier;
    double CombatAdrenalineGainMultiplier;
    double CurrentCombatLucidity;
    int CombatLucidityState;
    double CombatLucidityAccuracyMultiplier;
    double CombatLucidityPhysicalStunRemaining;
    int CombatHealthState;
    double CombatPhysicalAccuracyPercent;
    double CombatMagicalAccuracyPercent;
    double CombatPhysicalCriticalChancePercent;
    double CombatMagicalCriticalChancePercent;

    bool LastCombatEvasionAttempted;
    bool LastCombatEvasionSucceeded;
    double LastCombatEvasionChancePercent;
    double LastCombatEvasionRollPercent;
    double LastCombatHealthLossPercent;
    double LastCombatToughnessDamageMultiplier;
    double LastCombatPainChancePercent;
    bool LastCombatPainTriggered;
    int LastAnatomyLocation;
    int LastAnatomyNaturalVulnerabilityGrade;
    int LastAnatomyVulnerabilityGrade;
    double LastAnatomyHeightRatio;
    double LastAnatomyLateralRatio;
    int LastCombatArmorSlot;
    int LastCombatArmorDefensePercent;
    double LastCombatArmorIncomingDamage;
    double LastCombatArmorAbsorbedDamage;
    double LastCombatArmorPostDefenseDamage;
    int LastCombatArmorDurabilityLoss;
    double LastCombatArmorDurabilityChancePercent;
    double LastCombatArmorDurabilityRollPercent;
    bool PendingLocalizedImpact;
    bool PendingLocalizedCriticalHit;
    double LastCombatLucidityLoss;
    double LastCombatLucidityCriticalFactor;
    bool LastCombatAttackAttempted;
    bool LastCombatAttackMagical;
    bool LastCombatAttackAccuracySucceeded;
    double LastCombatAttackAccuracyChancePercent;
    double LastCombatAttackAccuracyRollPercent;
    bool LastCombatAttackCriticalHit;
    double LastCombatAttackCriticalChancePercent;
    double LastCombatAttackCriticalRollPercent;
    int LastCombatAttackBaseDamage;
    int LastCombatAttackCalculatedDamage;
    double LastCombatPushForce;
    bool PendingCombatCriticalDelivery;
    bool CombatAreaExplosionActive;
    double CombatAreaExplosionRadius;
    bool CombatAreaExplosionCriticalHit;

    Default
    {
        // El dolor nativo se desactiva para usar un unico calculo de Caelum.
        PainChance 0;
        // El retroceso se calcula despues de confirmar dano fisico real.
        +NODAMAGETHRUST
    }

    override void PostBeginPlay()
    {
        Super.PostBeginPlay();
        CollisionDamageMultiplier = 1.0;
        CollisionEffectiveMassMultiplier = 1.0;
        CombatBaseSpeed = Speed;
        CombatPhysicalPowerMultiplier = Max(0.0, Mass / 100.0);
        CombatMaximumHealth = Max(1, health);
        CombatHealthPerformanceMultiplier = 1.0;
        CombatHealthPainMultiplier = 1.0;
        CombatAdrenalineGainMultiplier = 1.0;
        LastCombatToughnessDamageMultiplier = 1.0;
        CurrentCombatLucidity = CaelumConstants.MAXIMUM_LUCIDITY;
        CombatLucidityState = CaelumConstants.LUCIDITY_STATE_NORMAL;
        CombatLucidityAccuracyMultiplier = 1.0;
        LastCombatLucidityCriticalFactor = 1.0;

        // Los miles de actores exclusivos del estrés no necesitan tres objetos
        // auxiliares permanentes ni toda la simulación RPG por tic. Si alguno
        // recibe daño real, las rutas normales crean su anatomía bajo demanda.
        bool massDiagnostic = IsCaelumMassDiagnosticActor();
        bool lightweightDiagnostic = massDiagnostic
            || CaelumDiagnosticPassiveAI;
        if (massDiagnostic)
        {
            Species = 'CaelumMassDiagnosticCrowd';
            bTHRUSPECIES = true;
            bTHRUACTORS = true;
            InitializeCaelumMassAISchedule();
        }

        if (!lightweightDiagnostic && AnatomyProfile == null)
        {
            AnatomyProfile = CaelumAnatomyProfile(new("CaelumAnatomyProfile"));
            AnatomyProfile.InitializeHumanoid();
        }
        if (!lightweightDiagnostic && ElementalStatus == null)
            ElementalStatus = CaelumElementalStatus(new("CaelumElementalStatus"));
        LastAnatomyLocation = CaelumConstants.HIT_LOCATION_NONE;
        LastAnatomyNaturalVulnerabilityGrade = CaelumConstants.VULNERABILITY_NEUTRAL_POINT;
        LastAnatomyVulnerabilityGrade = CaelumConstants.VULNERABILITY_NEUTRAL_POINT;
        LastCombatArmorSlot = CaelumConstants.ARMOR_SLOT_BODY;
        if (!lightweightDiagnostic && CombatArmor == null)
        {
            CombatArmor = CaelumArmorModel(new("CaelumArmorModel"));
            CombatArmor.InitializeUniformLoadout(
                CaelumConstants.ARMOR_TYPE_MAGIC,
                1
            );
        }
        RecalculateCombatStatistics();
        UpdateActorLucidityState();
    }

    virtual String GetCaelumRecognitionSound()
    {
        return "";
    }

    void UpdateCaelumRecognitionSound()
    {
        // La alerta sólo marca la transición hacia un objetivo jugador. Perder
        // el objetivo rearma una futura alerta; conservarlo no repite el audio.
        if (target == null || target.player == null)
        {
            CaelumRecognitionTarget = null;
            return;
        }
        if (CaelumRecognitionTarget == target) { return; }

        String recognitionSound = GetCaelumRecognitionSound();
        if (recognitionSound != "")
        {
            A_StartSound(recognitionSound, CHAN_VOICE);
        }
        CaelumRecognitionTarget = target;
    }

    void InitializeCaelumMassAISchedule()
    {
        CaelumMassAIScheduleActive = true;

        // SpawnPoint permanece estable aunque A_Chase mueva al actor. Dividir
        // por la separación de la matriz evita que todas las coordenadas
        // múltiplas de 96 caigan en la misma fase.
        int gridX = int(SpawnPoint.X / 96.0);
        int gridY = int(SpawnPoint.Y / 96.0);
        CaelumMassLookPhaseKey = Abs(
            gridX * 19 + gridY * 23 + int(Mass) * 11
        );
        CaelumMassChasePhaseKey = Abs(
            gridX * 29 + gridY * 31 + int(Mass) * 17
        );
        CaelumMassAttackPhaseKey = Abs(
            gridX * 31 + gridY * 17 + int(Mass) * 13
        );

        // Find se ejecuta una sola vez al aparecer. El camino caliente usa la
        // referencia cacheada y nunca recorre actores ni handlers.
        CaelumMassScheduler = CaelumMassAIScheduler(
            EventHandler.Find("CaelumMassAIScheduler")
        );
        if (CaelumMassScheduler != null
            && !CaelumMassScheduler.SettingsInitialized)
        {
            CaelumMassScheduler.RefreshSettings();
        }
        SyncCaelumMassAISchedule();
        CaelumMassSquadLeader =
            (CaelumMassChasePhaseKey % Max(1, CaelumMassSquadSize)) == 0;
    }

    void SyncCaelumMassAISchedule()
    {
        if (CaelumMassScheduler == null)
        {
            CaelumMassScheduler = CaelumMassAIScheduler(
                EventHandler.Find("CaelumMassAIScheduler")
            );
        }

        if (CaelumMassScheduler == null)
        {
            // Valores seguros si un guardado antiguo no contiene el handler.
            CaelumMassAttacksEnabled = false;
            CaelumMassLookEnabled = false;
            CaelumMassChaseEnabled = false;
            CaelumMassAttackInterval = 64;
            CaelumMassLookInterval = 7;
            CaelumMassChaseInterval = 13;
            CaelumMassLookBudgetPerTic = 20;
            CaelumMassChaseBudgetPerTic = 10;
            CaelumMassSquadSize = 16;
            CaelumMassFollowerMovementEnabled = false;
            CaelumMassFollowerSpeedScale = 0.25;
            return;
        }

        CaelumMassAttacksEnabled =
            CaelumMassScheduler.MassAttacksEnabled;
        CaelumMassLookEnabled = CaelumMassScheduler.MassLookEnabled;
        CaelumMassChaseEnabled = CaelumMassScheduler.MassChaseEnabled;
        CaelumMassAttackInterval = CaelumMassScheduler.MassAttackInterval;
        CaelumMassLookInterval = CaelumMassScheduler.MassLookInterval;
        CaelumMassChaseInterval = CaelumMassScheduler.MassChaseInterval;
        CaelumMassLookBudgetPerTic =
            CaelumMassScheduler.MassLookBudgetPerTic;
        CaelumMassChaseBudgetPerTic =
            CaelumMassScheduler.MassChaseBudgetPerTic;
        CaelumMassSquadSize = CaelumMassScheduler.MassSquadSize;
        CaelumMassFollowerMovementEnabled =
            CaelumMassScheduler.MassFollowerMovementEnabled;
        CaelumMassFollowerSpeedScale =
            CaelumMassScheduler.MassFollowerSpeedScale;
    }

    bool IsCaelumMassDiagnosticActor()
    {
        // La pared de aislamiento de MAP02 empieza en X=8192. Esta condición
        // excluye los nueve recintos y no afecta ningún mapa de juego normal.
        return level.MapName == "MAP02"
            && Pos.X >= 8192.0
            && Pos.X <= 24576.0
            && Pos.Y >= -8192.0
            && Pos.Y <= 8192.0;
    }

    bool BeginCaelumDiagnosticAttack()
    {
        if (level.MapName != "MAP02") { return true; }
        ImpactDiagnosticAttackAttempts++;
        if (!CaelumMassAIScheduleActive) { return true; }
        if (CaelumMassScheduler == null)
        {
            SyncCaelumMassAISchedule();
        }

        if (!CaelumMassAttacksEnabled)
        {
            ImpactDiagnosticSuppressedAttacks++;
            PendingCombatCriticalDelivery = false;
            return false;
        }

        int stagger = CaelumMassAttackInterval;
        if (stagger > 1)
        {
            int phase = CaelumMassAttackPhaseKey % stagger;
            if (level.time % stagger != phase)
            {
                ImpactDiagnosticSuppressedAttacks++;
                ImpactDiagnosticDeferredAttacks++;
                PendingCombatCriticalDelivery = false;
                return false;
            }
        }
        return true;
    }

    bool BeginCaelumDiagnosticChase()
    {
        if (!CaelumMassAIScheduleActive) { return true; }
        ImpactDiagnosticChaseAttempts++;
        if (CaelumMassScheduler == null)
        {
            SyncCaelumMassAISchedule();
        }

        if (!CaelumMassChaseEnabled)
        {
            ImpactDiagnosticChaseDeferred++;
            ImpactDiagnosticChaseDisabled++;
            return false;
        }

        int stagger = CaelumMassChaseInterval;
        if (stagger > 1)
        {
            // Trece es coprimo con los ciclos de 4, 5, 8 y 10 tics usados por
            // las familias del campo, por lo que ningún actor queda varado.
            int phase = CaelumMassChasePhaseKey % stagger;
            if (level.time % stagger != phase)
            {
                ImpactDiagnosticChaseDeferred++;
                ImpactDiagnosticChasePhaseDeferred++;
                return false;
            }
        }

        // La fase reduce el promedio; el coordinador limita también el peor
        // tic. Si no estuviera registrado, fallar cerrado protege la sesión.
        if (CaelumMassScheduler == null
            || !CaelumMassScheduler.TryAdmitChase())
        {
            ImpactDiagnosticChaseDeferred++;
            ImpactDiagnosticChaseBudgetDeferred++;
            return false;
        }

        ImpactDiagnosticChaseUpdates++;
        return true;
    }

    bool BeginCaelumDiagnosticLook()
    {
        if (!CaelumMassAIScheduleActive) { return true; }
        ImpactDiagnosticLookAttempts++;
        if (CaelumMassScheduler == null)
        {
            SyncCaelumMassAISchedule();
        }

        if (!CaelumMassLookEnabled)
        {
            ImpactDiagnosticLookDeferred++;
            ImpactDiagnosticLookDisabled++;
            return false;
        }

        int stagger = CaelumMassLookInterval;
        if (stagger > 1)
        {
            int phase = CaelumMassLookPhaseKey % stagger;
            if (level.time % stagger != phase)
            {
                ImpactDiagnosticLookDeferred++;
                ImpactDiagnosticLookPhaseDeferred++;
                return false;
            }
        }

        if (CaelumMassScheduler == null
            || !CaelumMassScheduler.TryAdmitLook())
        {
            ImpactDiagnosticLookDeferred++;
            ImpactDiagnosticLookBudgetDeferred++;
            return false;
        }
        ImpactDiagnosticLookUpdates++;
        return true;
    }

    action void A_CaelumBudgetedLook()
    {
        CaelumCombatActor combatActor = CaelumCombatActor(self);
        if (combatActor == null) { return; }

        // El primer miembro que ve al jugador publica el objetivo. Los demás
        // pueden pasar a See mediante una lectura O(1), sin ejecutar otra
        // búsqueda espacial. El campo diagnóstico tiene una sola facción;
        // producción separará este registro por grupo y zona.
        if (combatActor.CaelumMassAIScheduleActive
            && combatActor.CaelumMassScheduler != null)
        {
            Actor sharedTarget =
                combatActor.CaelumMassScheduler.GetSharedMassTarget();
            if (sharedTarget != null)
            {
                combatActor.target = sharedTarget;
                combatActor.CaelumMassScheduler.RecordSharedTargetAdoption();
                combatActor.ImpactDiagnosticSharedTargetAdoptions++;
                State seeState = combatActor.FindState('See');
                if (seeState != null) { combatActor.SetState(seeState); }
                return;
            }
        }
        if (!combatActor.BeginCaelumDiagnosticLook()) { return; }
        combatActor.A_Look();
        if (combatActor.CaelumMassAIScheduleActive
            && combatActor.CaelumMassScheduler != null
            && combatActor.target != null)
        {
            combatActor.CaelumMassScheduler.PublishSharedMassTarget(
                combatActor.target
            );
        }
    }

    action void A_CaelumBudgetedChase()
    {
        CaelumCombatActor combatActor = CaelumCombatActor(self);
        if (combatActor == null) { return; }

        // La prueba de escuadras separa decisión y combate de la consulta
        // espacial nativa. Sólo los líderes entran en A_Chase/TryMove; los
        // seguidores conservan el objetivo y, si la prueba lo habilita, usan
        // velocidad local barata sin A_Chase, TryMove ni búsqueda de vecinos.
        // El ataque queda también en manos del líder durante esta prueba: así
        // ningún CheckMissileRange oculto contamina el aislamiento de TryMove.
        if (combatActor.CaelumMassAIScheduleActive
            && !combatActor.CaelumMassSquadLeader)
        {
            combatActor.RunCaelumMassFollowerPulse();
            return;
        }
        if (!combatActor.BeginCaelumDiagnosticChase()) { return; }
        combatActor.A_Chase();
    }

    void RunCaelumMassFollowerPulse()
    {
        if (target == null || target.health <= 0 || health <= 0)
        {
            if (CaelumMassFollowerMovementEnabled)
            {
                Vel.X = 0.0;
                Vel.Y = 0.0;
                ImpactDiagnosticFollowerMoveStops++;
            }
            return;
        }

        if (CaelumMassFollowerMovementEnabled)
        {
            // Treinta y dos direcciones y cuatro radios producen destinos
            // estables alrededor del objetivo. Es una formación diagnóstica,
            // no una comparación entre seguidores ni navegación definitiva.
            int formationIndex = CaelumMassChasePhaseKey % 128;
            double formationAngle = (formationIndex % 32) * 11.25;
            double formationRadius = 96.0
                + ((formationIndex / 32) % 4) * 48.0;
            double destinationX = target.Pos.X
                + Cos(formationAngle) * formationRadius;
            double destinationY = target.Pos.Y
                + Sin(formationAngle) * formationRadius;
            double offsetX = destinationX - Pos.X;
            double offsetY = destinationY - Pos.Y;
            double distance = Sqrt(offsetX * offsetX + offsetY * offsetY);

            if (distance <= 24.0)
            {
                Vel.X = 0.0;
                Vel.Y = 0.0;
                ImpactDiagnosticFollowerMoveStops++;
                return;
            }

            Angle = VectorAngle(offsetX, offsetY);
            double localSpeed = Max(
                0.0,
                Speed * CaelumMassFollowerSpeedScale
            );
            Vel.X = Cos(Angle) * localSpeed;
            Vel.Y = Sin(Angle) * localSpeed;
            ImpactDiagnosticFollowerMoveUpdates++;
            return;
        }

        // El intervalo de ataque ya está calibrado entre uno y dos segundos
        // (64 tics por defecto) y evita que todos los seguidores giren juntos.
        int stagger = Max(1, CaelumMassAttackInterval);
        if (stagger > 1
            && level.time % stagger != CaelumMassAttackPhaseKey % stagger)
        {
            return;
        }

        ImpactDiagnosticFollowerPulses++;
        A_FaceTarget();
    }

    bool IsCaelumMassDiagnosticAlly(Actor other)
    {
        CaelumCombatActor combatOther = CaelumCombatActor(other);
        return IsCaelumMassDiagnosticActor()
            && combatOther != null
            && combatOther.IsCaelumMassDiagnosticActor();
    }

    void InitializeCombatArmor(int requestedArmorType, int requestedTier)
    {
        if (CaelumMassAIScheduleActive || CaelumDiagnosticPassiveAI)
        {
            return;
        }
        if (CombatArmor == null)
        {
            CombatArmor = CaelumArmorModel(new("CaelumArmorModel"));
        }
        CombatArmor.InitializeUniformLoadout(requestedArmorType, requestedTier);
        // Igual que en el jugador, los atributos derivados se recalculan
        // después de equipar para incorporar las bonificaciones de armadura.
        if (CombatProfileInitialized) { RecalculateCombatStatistics(); }
    }

    void ClearCombatArmorToBaseClothing()
    {
        if (CaelumMassAIScheduleActive || CaelumDiagnosticPassiveAI)
        {
            return;
        }

        // PostBeginPlay equipa armadura mágica a los combatientes históricos.
        // Los personajes sin equipo funcional necesitan un modelo nuevo para
        // que ropa, defensa, peso y bonificaciones queden realmente en cero.
        CombatArmor = CaelumArmorModel(new("CaelumArmorModel"));
        CombatArmor.InitializeDefaults();
        if (CombatProfileInitialized) { RecalculateCombatStatistics(); }
    }

    int GetArmorSlotForLocation(int location)
    {
        switch (location)
        {
            case CaelumConstants.HIT_LOCATION_HEAD:
                return CaelumConstants.ARMOR_SLOT_HEAD;
            case CaelumConstants.HIT_LOCATION_ARMS:
                return CaelumConstants.ARMOR_SLOT_HANDS;
            case CaelumConstants.HIT_LOCATION_LEGS:
                return CaelumConstants.ARMOR_SLOT_FEET;
            default:
                return CaelumConstants.ARMOR_SLOT_BODY;
        }
    }

    int GetEffectiveActorVulnerability(int naturalGrade, int location)
    {
        int reinforcement = 0;
        if (CombatArmor != null)
        {
            reinforcement = CombatArmor.GetReinforcement(
                GetArmorSlotForLocation(location)
            );
        }
        return Min(
            CaelumConstants.VULNERABILITY_ARMORED_POINT,
            naturalGrade + reinforcement
        );
    }

    int RegisterAnatomyImpact(double heightRatio, double lateralRatio)
    {
        LastAnatomyHeightRatio = Clamp(heightRatio, 0.0, 1.0);
        LastAnatomyLateralRatio = Clamp(lateralRatio, 0.0, 1.0);
        if (AnatomyProfile == null)
        {
            AnatomyProfile = CaelumAnatomyProfile(new("CaelumAnatomyProfile"));
            AnatomyProfile.InitializeHumanoid();
        }
        int regionIndex = AnatomyProfile.FindRegion(
            LastAnatomyHeightRatio,
            LastAnatomyLateralRatio
        );
        LastAnatomyLocation = AnatomyProfile.GetLocation(regionIndex);
        LastAnatomyNaturalVulnerabilityGrade = AnatomyProfile.GetVulnerability(regionIndex);
        LastAnatomyVulnerabilityGrade = GetEffectiveActorVulnerability(
            LastAnatomyNaturalVulnerabilityGrade,
            LastAnatomyLocation
        );
        PendingLocalizedImpact = true;
        return LastAnatomyVulnerabilityGrade;
    }

    int RegisterDirectionalAnatomyImpact(
        Actor impactSource,
        double heightRatio
    )
    {
        if (AnatomyProfile == null || !AnatomyProfile.UsesDirectionalRegions
            || impactSource == null)
        {
            return RegisterAnatomyImpact(heightRatio, 0.5);
        }
        Vector2 sourceDirection = impactSource.Pos.XY - Pos.XY;
        double directionLength = sourceDirection.Length();
        if (directionLength <= 0.0)
        {
            return RegisterAnatomyImpact(heightRatio, 0.0);
        }
        sourceDirection /= directionLength;
        Vector2 forward = AngleToVector(Angle, 1.0);
        Vector2 right = AngleToVector(Angle + 90.0, 1.0);
        double forwardRatio = sourceDirection.X * forward.X
            + sourceDirection.Y * forward.Y;
        double lateralRatio = sourceDirection.X * right.X
            + sourceDirection.Y * right.Y;
        int regionIndex = AnatomyProfile.FindDirectionalRegion(
            heightRatio, lateralRatio, forwardRatio
        );
        LastAnatomyHeightRatio = Clamp(heightRatio, 0.0, 1.0);
        LastAnatomyLateralRatio = Clamp(Abs(lateralRatio), 0.0, 1.0);
        LastAnatomyLocation = AnatomyProfile.GetLocation(regionIndex);
        LastAnatomyNaturalVulnerabilityGrade =
            AnatomyProfile.GetVulnerability(regionIndex);
        LastAnatomyVulnerabilityGrade = GetEffectiveActorVulnerability(
            LastAnatomyNaturalVulnerabilityGrade,
            LastAnatomyLocation
        );
        PendingLocalizedImpact = true;
        return LastAnatomyVulnerabilityGrade;
    }

    // La anatomia se registra antes de resolver el critico. Esta marca explicita
    // separa el efecto critico del DamageMobj generico para todo tipo de dano.
    void RegisterPendingCriticalHit(bool criticalHit)
    {
        PendingLocalizedCriticalHit = PendingLocalizedImpact && criticalHit;
    }

    // Cada actor carga una vez sus atributos defensivos; puede recalcularlos.
    void InitializeCombatProfile(
        int strength,
        int toughness,
        int constitution,
        int agility,
        int dexterity,
        int resilience,
        int charisma,
        int empathy,
        int eloquence,
        int intelligence,
        int patience,
        int insight
    )
    {
        CombatStrength = Max(0, strength);
        CombatToughness = Max(0, toughness);
        CombatConstitution = Max(0, constitution);
        CombatAgility = Max(0, agility);
        CombatDexterity = Max(0, dexterity);
        CombatResilience = Max(0, resilience);
        CombatCharisma = Max(0, charisma);
        CombatEmpathy = Max(0, empathy);
        CombatEloquence = Max(0, eloquence);
        CombatIntelligence = Max(0, intelligence);
        CombatPatience = Max(0, patience);
        CombatInsight = Max(0, insight);
        CombatProfileInitialized = true;
        // La Salud máxima de actores usa la misma fuente autoritativa que el
        // jugador: Constitución Tipo 1 multiplicada por la masa corporal.
        CombatMaximumHealth = Max(1, int(
            CaelumConstants.HEALTH_ANIMA_DAMAGE_SCALE
            * CalculateActorType1Percent(CombatConstitution)
            * Max(0.01, Mass / 100.0)
        ));
        health = CombatMaximumHealth;
        RecalculateCombatStatistics();
        // Los NPC comienzan con el recurso completo, igual que un personaje
        // jugador recién inicializado; recalcular nunca concede recursos gratis.
        CurrentCombatAnima = MaximumCombatAnima;
        CurrentCombatAir = MaximumCombatAir;
    }

    void RecalculateCombatStatistics()
    {
        int effectivePatience = CombatPatience
            + GetCombatArmorAttributeBonus(CaelumConstants.ATTRIBUTE_PATIENCE);
        MaximumCombatAnima = CaelumConstants.HEALTH_ANIMA_DAMAGE_SCALE
            * CalculateActorType1Percent(effectivePatience);
        CombatAnimaRegenerationPerSecond = MaximumCombatAnima
            / CaelumConstants.ANIMA_FULL_RECOVERY_SECONDS
            * CalculateActorType4Percent(effectivePatience) / 100.0;
        CurrentCombatAnima = Clamp(
            CurrentCombatAnima,
            0.0,
            MaximumCombatAnima
        );
        MaximumCombatAir = CaelumConstants.BASE_AIR_CAPACITY
            * CalculateActorType4Percent(CombatResilience) / 100.0;
        CurrentCombatAir = Clamp(
            CurrentCombatAir,
            0.0,
            MaximumCombatAir
        );
        CombatAirRegenerationPerSecond = MaximumCombatAir
            / CaelumConstants.AIR_FULL_RECOVERY_SECONDS;
        MaximumCombatAdrenaline = 1000.0
            * (100.0 + 2.0 * CombatResilience
                * (CombatResilience + 1) / 101.0) / 100.0;
        CurrentCombatAdrenaline = Clamp(
            CurrentCombatAdrenaline,
            0.0,
            MaximumCombatAdrenaline
        );
        UpdateCombatHealthEffects();
        UpdateActorOffensiveStatistics();
    }

    double CalculateActorType1Percent(int level)
    {
        return 100.0 + level * (level + 1) / 2.0;
    }

    double CalculateActorType2Percent(int level)
    {
        return level * (level + 1) / 101.0;
    }

    double CalculateActorType4Percent(int level)
    {
        return 100.0 + 2.0 * level * (level + 1) / 101.0;
    }

    double GetCombatAbilityRange()
    {
        int effectiveEloquence = CombatEloquence
            + GetCombatArmorAttributeBonus(CaelumConstants.ATTRIBUTE_ELOQUENCE);
        return CaelumConstants.ESSENCE_BASE_RANGE_MAP_UNITS
            * CalculateActorType4Percent(effectiveEloquence) / 100.0;
    }

    void ConfigureCombatMagicalRange()
    {
        MaxTargetRange = GetCombatAbilityRange();
    }

    bool TrySpendCombatAir(double requestedAmount)
    {
        double amount = Max(0.0, requestedAmount);
        if (CurrentCombatAir < amount) { return false; }
        CurrentCombatAir = Max(0.0, CurrentCombatAir - amount);
        return true;
    }

    double GetTierOneMagicBaseDamage(int weaponType)
    {
        if (weaponType == CaelumConstants.WEAPON_TYPE_STATUETTE)
        {
            return CaelumConstants.WEAPON_STATUETTE_TIER_ONE_BASE_DAMAGE;
        }
        return CaelumConstants.WEAPON_STAFF_TIER_ONE_BASE_DAMAGE;
    }

    double GetTierOneMagicBaseAnimaCost(int weaponType)
    {
        if (weaponType == CaelumConstants.WEAPON_TYPE_STATUETTE)
        {
            return CaelumConstants.WEAPON_STATUETTE_TIER_ONE_ANIMA_COST;
        }
        return CaelumConstants.WEAPON_STAFF_TIER_ONE_ANIMA_COST;
    }

    double GetTierOneMagicAnimaCost(int weaponType)
    {
        int effectiveEloquence = CombatEloquence
            + GetCombatArmorAttributeBonus(
                CaelumConstants.ATTRIBUTE_ELOQUENCE
            );
        double reductionPercent = Clamp(
            CalculateActorType2Percent(effectiveEloquence),
            0.0,
            100.0
        );
        return GetTierOneMagicBaseAnimaCost(weaponType)
            * (1.0 - reductionPercent / 100.0);
    }

    bool TrySpendTierOneMagicAnima(int weaponType)
    {
        double cost = Max(0.0, GetTierOneMagicAnimaCost(weaponType));
        if (CurrentCombatAnima < cost) { return false; }
        CurrentCombatAnima = Max(0.0, CurrentCombatAnima - cost);
        return true;
    }

    int GetTierOneMagicDamage(int weaponType)
    {
        int effectiveIntelligence = CombatIntelligence
            + GetCombatArmorAttributeBonus(
                CaelumConstants.ATTRIBUTE_INTELLIGENCE
            );
        return Max(1, int(
            GetTierOneMagicBaseDamage(weaponType)
                * CalculateActorType1Percent(effectiveIntelligence)
                / 100.0
                + 0.5
        ));
    }

    double GetTierOneStatuetteExplosionRadius()
    {
        int effectiveEloquence = CombatEloquence
            + GetCombatArmorAttributeBonus(
                CaelumConstants.ATTRIBUTE_ELOQUENCE
            );
        return CaelumConstants.ESSENCE_EXPLOSION_BASE_RADIUS
            * CalculateActorType4Percent(effectiveEloquence) / 100.0;
    }

    void UpdateActorOffensiveStatistics()
    {
        CombatEffectiveDexterity = CombatDexterity
            + GetCombatArmorAttributeBonus(CaelumConstants.ATTRIBUTE_DEXTERITY);
        CombatEffectiveInsight = CombatInsight
            + GetCombatArmorAttributeBonus(CaelumConstants.ATTRIBUTE_INSIGHT);
        CombatEffectiveIntelligence = CombatIntelligence
            + GetCombatArmorAttributeBonus(CaelumConstants.ATTRIBUTE_INTELLIGENCE);
        CombatPhysicalAccuracyPercent = CalculateActorType1Percent(
            CombatEffectiveDexterity
        );
        CombatMagicalAccuracyPercent = CalculateActorType1Percent(
            CombatEffectiveInsight
        );
        CombatPhysicalCriticalChancePercent = Clamp(
            CaelumConstants.BASE_CRITICAL_CHANCE_PERCENT
                + CalculateActorType2Percent(CombatEffectiveDexterity),
            0.0,
            100.0
        );
        CombatMagicalCriticalChancePercent = Clamp(
            CaelumConstants.BASE_CRITICAL_CHANCE_PERCENT
                + CalculateActorType2Percent(CombatEffectiveInsight),
            0.0,
            100.0
        );
        CombatPhysicalPushMultiplier = Max(0.0, Mass / 100.0)
            * CalculateActorType1Percent(CombatStrength) / 100.0;
        CombatMagicalPushMultiplier = CalculateActorType1Percent(
            CombatEffectiveIntelligence
        ) / 100.0;
    }

    // Entrada ofensiva comun: salud modifica dano, lucidez modifica precision
    // y el atributo propio del ataque determina su probabilidad critica.
    int PrepareActorOutgoingDamage(double baseDamage, bool magicalAttack)
    {
        UpdateCombatHealthEffects();
        UpdateActorOffensiveStatistics();
        double resolvedBaseDamage = Max(0.0, baseDamage);
        LastCombatAttackAttempted = true;
        LastCombatAttackMagical = magicalAttack;
        LastCombatAttackBaseDamage = int(resolvedBaseDamage + 0.5);
        LastCombatAttackAccuracyChancePercent = Clamp(
            (magicalAttack
                ? CombatMagicalAccuracyPercent
                : CombatPhysicalAccuracyPercent)
                * CombatLucidityAccuracyMultiplier
                * (ElementalStatus != null
                    ? ElementalStatus.GetAccuracyMultiplier() : 1.0),
            0.0,
            100.0
        );
        if (CombatLucidityPhysicalStunRemaining > 0.0)
        {
            LastCombatAttackAccuracyChancePercent = 0.0;
        }
        int accuracyRoll = Random[CaelumActorOffensiveAccuracy](0, 999999);
        LastCombatAttackAccuracyRollPercent = accuracyRoll / 10000.0;
        LastCombatAttackAccuracySucceeded =
            LastCombatAttackAccuracyRollPercent
                < LastCombatAttackAccuracyChancePercent;
        LastCombatAttackCriticalChancePercent = magicalAttack
            ? CombatMagicalCriticalChancePercent
            : CombatPhysicalCriticalChancePercent;
        LastCombatAttackCriticalRollPercent = 0.0;
        LastCombatAttackCriticalHit = false;
        PendingCombatCriticalDelivery = false;
        LastCombatAttackCalculatedDamage = 0;
        MarkActorCombatActivity();
        if (!LastCombatAttackAccuracySucceeded) { return 0; }

        int criticalRoll = Random[CaelumActorOffensiveCritical](0, 999999);
        LastCombatAttackCriticalRollPercent = criticalRoll / 10000.0;
        LastCombatAttackCriticalHit = LastCombatAttackCriticalRollPercent
            < LastCombatAttackCriticalChancePercent;
        PendingCombatCriticalDelivery = LastCombatAttackCriticalHit;
        LastCombatAttackCalculatedDamage = Max(
            1,
            int(resolvedBaseDamage
                * (magicalAttack ? 1.0 : CombatPhysicalPowerMultiplier)
                * CombatHealthPerformanceMultiplier + 0.5)
        );
        return LastCombatAttackCalculatedDamage;
    }

    bool ConsumePendingCombatCritical()
    {
        bool result = PendingCombatCriticalDelivery;
        PendingCombatCriticalDelivery = false;
        return result;
    }

    void BeginCombatAreaExplosion(double radius)
    {
        // A_Explode no copia sus argumentos a ExplosionRadius. Esta ventana
        // síncrona permite que la defensa anatómica lea la ficha real sin
        // duplicar el radio en una propiedad nativa separada.
        CombatAreaExplosionActive = true;
        CombatAreaExplosionRadius = Max(1.0, radius);
        CombatAreaExplosionCriticalHit = PendingCombatCriticalDelivery;
    }

    void EndCombatAreaExplosion()
    {
        CombatAreaExplosionActive = false;
        CombatAreaExplosionRadius = 0.0;
        CombatAreaExplosionCriticalHit = false;
    }

    bool GetCombatAreaExplosionCriticalHit()
    {
        return CombatAreaExplosionActive
            && CombatAreaExplosionCriticalHit;
    }

    // La masa corporal genera empuje; la masa total del receptor lo resiste.
    double GetActorKnockbackMultiplier(Actor receiver)
    {
        if (receiver == null) { return 0.0; }

        CaelumPlayer playerReceiver = CaelumPlayer(receiver);
        if (playerReceiver != null && playerReceiver.DerivedStats != null)
        {
            return 100.0 / (playerReceiver.GetCombatMass() + 50.0);
        }

        CaelumCombatActor combatReceiver = CaelumCombatActor(receiver);
        double receiverMass = Max(1.0, receiver.Mass);
        if (combatReceiver != null && combatReceiver.CombatArmor != null)
        {
            receiverMass += combatReceiver.CombatArmor.GetTotalWeight();
        }
        return 100.0 / (receiverMass + 50.0);
    }

    void ApplyActorAttackPush(Actor receiver, double attackAngle, double attackerMultiplier)
    {
        LastCombatPushForce = 0.0;
        if (receiver == null || receiver.health <= 0) { return; }
        LastCombatPushForce = CaelumConstants.BASE_ATTACK_PUSH_FORCE
            * Max(0.0, attackerMultiplier)
            * GetActorKnockbackMultiplier(receiver);
        if (LastCombatPushForce > 0.0)
        {
            receiver.Thrust(LastCombatPushForce, attackAngle);
        }
    }

    action void A_CaelumMeleeAttack(int baseDamage)
    {
        // Las acciones sin alcance explicito son invocables desde estados de
        // monstruo. El casteo recupera el tipo concreto para llamar su logica.
        CaelumCombatActor combatActor = CaelumCombatActor(self);
        if (combatActor == null) { return; }
        if (!combatActor.BeginCaelumDiagnosticAttack()) { return; }
        if (combatActor.IsCaelumMassDiagnosticAlly(combatActor.Target))
        {
            combatActor.ImpactDiagnosticFriendlyFirePrevented++;
            combatActor.PendingCombatCriticalDelivery = false;
            return;
        }
        int calculatedDamage = combatActor.PrepareActorOutgoingDamage(
            baseDamage,
            false
        );
        if (calculatedDamage <= 0) { return; }
        Actor meleeVictim = combatActor.Target;
        int victimHealthBefore = meleeVictim != null ? meleeVictim.health : 0;
        combatActor.A_CustomMeleeAttack(
            calculatedDamage,
            "weapons/swordhit"
        );
        if (meleeVictim != null && meleeVictim.health < victimHealthBefore)
        {
            combatActor.ApplyActorAttackPush(
                meleeVictim,
                combatActor.AngleTo(meleeVictim),
                combatActor.CombatPhysicalPushMultiplier
            );
        }
        // Un impacto consume esta marca sincronicamente en CaelumPlayer.
        // Un fallo no debe dejar un critico pendiente para otro dano posterior.
        combatActor.PendingCombatCriticalDelivery = false;
    }

    action void A_CaelumProfiledMeleeAttack(double authoredBaseDamage)
    {
        CaelumCombatActor combatActor = CaelumCombatActor(self);
        if (combatActor == null) { return; }
        if (!combatActor.BeginCaelumDiagnosticAttack()) { return; }
        if (combatActor.IsCaelumMassDiagnosticAlly(combatActor.Target))
        {
            combatActor.ImpactDiagnosticFriendlyFirePrevented++;
            combatActor.PendingCombatCriticalDelivery = false;
            return;
        }

        // El valor escrito en la ficha es previo a Fuerza y masa, igual que
        // las armas del jugador. Se redondea una sola vez al entrar en la ruta
        // ofensiva existente del actor.
        double strengthScaledDamage = Max(1.0,
            Max(0.0, authoredBaseDamage)
                * combatActor.CalculateActorType1Percent(
                    combatActor.CombatStrength
                )
                / 100.0
        );
        int calculatedDamage = combatActor.PrepareActorOutgoingDamage(
            strengthScaledDamage,
            false
        );
        if (calculatedDamage <= 0) { return; }

        Actor meleeVictim = combatActor.Target;
        int victimHealthBefore = meleeVictim != null ? meleeVictim.health : 0;
        combatActor.A_CustomMeleeAttack(
            calculatedDamage,
            "weapons/swordhit"
        );
        if (meleeVictim != null && meleeVictim.health < victimHealthBefore)
        {
            combatActor.ApplyActorAttackPush(
                meleeVictim,
                combatActor.AngleTo(meleeVictim),
                combatActor.CombatPhysicalPushMultiplier
            );
        }
        combatActor.PendingCombatCriticalDelivery = false;
    }

    void LaunchActorsInGroundRadius(double radius, double verticalSpeed)
    {
        double resolvedRadius = Max(1.0, radius);
        double resolvedVerticalSpeed = Max(0.0, verticalSpeed);
        BlockThingsIterator iterator = BlockThingsIterator.Create(
            self,
            resolvedRadius
        );

        while (iterator.Next())
        {
            Actor candidate = iterator.thing;
            if (candidate == null
                || candidate == self
                || candidate.health <= 0
                || !candidate.bShootable
                || IsFriend(candidate))
            {
                continue;
            }

            // XF_CIRCULAR usa Distance3D; la elevación comparte exactamente
            // el mismo volumen antes de comprobar la línea de visión.
            if (candidate.Distance3D(self) > resolvedRadius
                || !CheckSight(candidate))
            {
                continue;
            }
            candidate.Vel.Z += resolvedVerticalSpeed;
        }
    }

    action void A_CaelumGroundSlam(
        double authoredBaseDamage,
        double radius,
        double verticalSpeed
    )
    {
        CaelumCombatActor combatActor = CaelumCombatActor(self);
        if (combatActor == null) { return; }
        if (!combatActor.BeginCaelumDiagnosticAttack()) { return; }

        double strengthScaledDamage = Max(1.0,
            Max(0.0, authoredBaseDamage)
                * combatActor.CalculateActorType1Percent(
                    combatActor.CombatStrength
                )
                / 100.0
        );
        int calculatedDamage = combatActor.PrepareActorOutgoingDamage(
            strengthScaledDamage,
            false
        );
        if (calculatedDamage <= 0) { return; }

        // A_Explode aplica caída lineal hasta el radio solicitado. Se elimina
        // su empuje nativo para que la elevación sea exactamente +8 MU/tic y
        // atraviese de forma controlada NODAMAGETHRUST del sistema Caelum.
        combatActor.BeginCombatAreaExplosion(radius);
        combatActor.LaunchActorsInGroundRadius(radius, verticalSpeed);
        combatActor.A_Explode(
            calculatedDamage,
            radius,
            XF_NOTMISSILE | XF_THRUSTLESS | XF_NOALLIES | XF_CIRCULAR,
            false
        );
        combatActor.EndCombatAreaExplosion();
        combatActor.PendingCombatCriticalDelivery = false;
    }

    // El resultado a distancia queda fijado al disparar. Los cambios posteriores
    // del atacante no alteran un proyectil que ya esta viajando por el mundo.
    action void A_CaelumSpawnProjectile(
        class<CaelumActorProjectile> missileType,
        double spawnHeight,
        int baseDamage,
        bool magicalAttack
    )
    {
        CaelumCombatActor combatActor = CaelumCombatActor(self);
        if (combatActor == null) { return; }
        if (!combatActor.BeginCaelumDiagnosticAttack()) { return; }
        int calculatedDamage = combatActor.PrepareActorOutgoingDamage(
            baseDamage,
            magicalAttack
        );
        if (calculatedDamage <= 0) { return; }

        CaelumActorProjectile missile = CaelumActorProjectile(
            combatActor.A_SpawnProjectile(missileType, spawnHeight)
        );
        if (missile != null)
        {
            combatActor.ImpactDiagnosticProjectilesSpawned++;
            missile.StoreCaelumAttackResult(
                calculatedDamage,
                combatActor.LastCombatAttackAccuracySucceeded,
                combatActor.LastCombatAttackCriticalHit,
                magicalAttack,
                magicalAttack
                    ? combatActor.CombatMagicalPushMultiplier
                    : combatActor.CombatPhysicalPushMultiplier
            );
        }
        else
        {
            combatActor.ImpactDiagnosticProjectileSpawnFailures++;
        }
        combatActor.PendingCombatCriticalDelivery = false;
    }

    // Ruta elemental recta para NPC numerosos. Conserva daño, crítico,
    // elemento y alcance, pero no añade guiado, búsqueda radial ni explosión.
    action void A_CaelumSpawnSimpleElementalProjectile(
        class<CaelumActorProjectile> missileType,
        double spawnHeight,
        int baseDamage,
        int essenceType
    )
    {
        CaelumCombatActor combatActor = CaelumCombatActor(self);
        if (combatActor == null) { return; }
        if (!combatActor.BeginCaelumDiagnosticAttack()) { return; }
        int calculatedDamage = combatActor.PrepareActorOutgoingDamage(
            baseDamage,
            true
        );
        if (calculatedDamage <= 0) { return; }

        CaelumActorProjectile missile = CaelumActorProjectile(
            combatActor.A_SpawnProjectile(missileType, spawnHeight)
        );
        if (missile != null)
        {
            combatActor.ImpactDiagnosticProjectilesSpawned++;
            missile.StoreCaelumAttackResult(
                calculatedDamage,
                combatActor.LastCombatAttackAccuracySucceeded,
                combatActor.LastCombatAttackCriticalHit,
                true,
                combatActor.CombatMagicalPushMultiplier
            );
            missile.StoreCaelumElementalPayload(
                essenceType,
                combatActor.NextRangedSecondaryElement,
                100.0,
                100.0
            );
            missile.ConfigureCaelumTravelDistance(
                combatActor.GetCombatAbilityRange()
            );
        }
        else
        {
            combatActor.ImpactDiagnosticProjectileSpawnFailures++;
        }
        combatActor.NextRangedSecondaryElement =
            !combatActor.NextRangedSecondaryElement;
        combatActor.PendingCombatCriticalDelivery = false;
    }

    // Variante elemental explosiva para actores de prueba. Reutiliza la misma
    // metadata ofensiva, radio y payload elemental que la Estatuilla.
    // Cada actor alterna de forma determinista entre su elemento primario y secundario.
    action void A_CaelumSpawnExplosiveElementalProjectile(
        class<CaelumActorProjectile> missileType,
        double spawnHeight,
        int baseDamage,
        int essenceType
    )
    {
        CaelumCombatActor combatActor = CaelumCombatActor(self);
        if (combatActor == null) { return; }
        if (!combatActor.BeginCaelumDiagnosticAttack()) { return; }
        int calculatedDamage = combatActor.PrepareActorOutgoingDamage(baseDamage, true);
        if (calculatedDamage <= 0) { return; }

        CaelumActorProjectile missile = CaelumActorProjectile(
            combatActor.A_SpawnProjectile(missileType, spawnHeight)
        );
        if (missile != null)
        {
            combatActor.ImpactDiagnosticProjectilesSpawned++;
            missile.StoreCaelumAttackResult(
                calculatedDamage,
                combatActor.LastCombatAttackAccuracySucceeded,
                combatActor.LastCombatAttackCriticalHit,
                true,
                combatActor.CombatMagicalPushMultiplier
            );
            missile.StoreCaelumElementalPayload(
                essenceType,
                combatActor.NextRangedSecondaryElement,
                100.0,
                100.0
            );
            missile.ConfigureCaelumActorExplosion(
                calculatedDamage,
                CaelumConstants.ESSENCE_EXPLOSION_BASE_RADIUS,
                combatActor.GetCombatAbilityRange()
            );
        }
        else
        {
            combatActor.ImpactDiagnosticProjectileSpawnFailures++;
        }
        combatActor.NextRangedSecondaryElement = !combatActor.NextRangedSecondaryElement;
        combatActor.PendingCombatCriticalDelivery = false;
    }

    action void A_CaelumSpawnTierOneMagicProjectile(
        class<CaelumActorProjectile> missileType,
        double spawnHeightRatio,
        int weaponType,
        int essenceType,
        bool explosive
    )
    {
        CaelumCombatActor combatActor = CaelumCombatActor(self);
        if (combatActor == null) { return; }
        if (!combatActor.BeginCaelumDiagnosticAttack()) { return; }
        if (combatActor.IsCaelumMassDiagnosticAlly(combatActor.Target))
        {
            combatActor.ImpactDiagnosticFriendlyFirePrevented++;
            return;
        }

        // El coste se paga al resolver el ataque aunque la tirada ofensiva
        // falle, como ocurre con el lanzamiento ya iniciado del jugador.
        if (!combatActor.TrySpendTierOneMagicAnima(weaponType)) { return; }
        int calculatedDamage = combatActor.PrepareActorOutgoingDamage(
            combatActor.GetTierOneMagicDamage(weaponType),
            true
        );
        if (calculatedDamage <= 0)
        {
            combatActor.PendingCombatCriticalDelivery = false;
            return;
        }

        CaelumActorProjectile missile = CaelumActorProjectile(
            combatActor.A_SpawnProjectile(
                missileType,
                combatActor.Height * Max(0.0, spawnHeightRatio)
            )
        );
        if (missile != null)
        {
            combatActor.ImpactDiagnosticProjectilesSpawned++;
            missile.StoreCaelumAttackResult(
                calculatedDamage,
                combatActor.LastCombatAttackAccuracySucceeded,
                combatActor.LastCombatAttackCriticalHit,
                true,
                combatActor.CombatMagicalPushMultiplier
            );
            missile.StoreCaelumElementalPayload(
                essenceType,
                false,
                combatActor.CalculateActorType4Percent(
                    combatActor.CombatCharisma
                ),
                combatActor.CalculateActorType4Percent(
                    combatActor.CombatEmpathy
                )
            );
            if (explosive)
            {
                missile.ConfigureCaelumActorExplosion(
                    calculatedDamage,
                    combatActor.GetTierOneStatuetteExplosionRadius(),
                    combatActor.GetCombatAbilityRange()
                );
            }
            else
            {
                missile.ConfigureCaelumTravelDistance(
                    combatActor.GetCombatAbilityRange()
                );
            }
        }
        else
        {
            combatActor.ImpactDiagnosticProjectileSpawnFailures++;
        }
        combatActor.PendingCombatCriticalDelivery = false;
    }

    double GetCollisionEffectiveMass()
    {
        double result = Max(1.0, double(Mass));
        if (CombatArmor != null)
        {
            result += Max(0.0, CombatArmor.GetTotalWeight());
        }
        return Max(1.0, result * Max(0.0, CollisionEffectiveMassMultiplier));
    }

    double GetImpactMaximumHealth()
    {
        if (CombatMaximumHealth > 0) { return CombatMaximumHealth; }
        return Max(1.0, double(GetMaxHealth()));
    }

    double GetImpactReferenceHeight()
    {
        // Los NPC Caelum tienen una altura física fija definida en su clase.
        return Max(1.0, Height);
    }

    double GetImpactToughnessMultiplier()
    {
        return Clamp(
            1.0 - CombatToughness * (CombatToughness + 1) / 10100.0,
            0.0,
            1.0
        );
    }

    double GetImpactArmorDefensePercent()
    {
        if (CombatArmor == null) { return 0.0; }
        double totalDefense = 0.0;
        for (int slot = 0; slot < CaelumConstants.ARMOR_SLOT_COUNT; slot++)
        {
            totalDefense += Clamp(
                double(CombatArmor.GetDefense(slot)),
                0.0,
                100.0
            );
        }
        return totalDefense / CaelumConstants.ARMOR_SLOT_COUNT;
    }

    double GetBiologicalLandingAbsorptionSpeed()
    {
        // Escala geométrica de la velocidad segura: la velocidad característica
        // de un cuerpo bajo la misma gravedad crece como sqrt(longitud).
        if (CombatLucidityPhysicalStunRemaining > 0.0)
        {
            return 0.0;
        }

        double agilityTypeOnePercent =
            100.0 + CombatAgility * (CombatAgility + 1) / 2.0;
        return CaelumConstants.GZDOOM_BASE_JUMP_Z
            * Sqrt(Max(0.0, agilityTypeOnePercent / 100.0));
    }

    double ApplyBiologicalLandingAbsorption(double rawDeltaSpeed)
    {
        LastImpactRawDeltaSpeed = Max(0.0, rawDeltaSpeed);
        LastImpactBiologicalAbsorptionSpeed =
            GetBiologicalLandingAbsorptionSpeed();
        return Max(
            0.0,
            LastImpactRawDeltaSpeed
                - LastImpactBiologicalAbsorptionSpeed
        );
    }

    double CalculateImpactEquivalentTics(double deltaSpeed)
    {
        return ImpactPhysics.EquivalentTics(
            GetImpactReferenceHeight(),
            deltaSpeed
        );
    }

    double CalculateImpactDamagePercent(double equivalentTics)
    {
        return ImpactPhysics.EnergyPercent(equivalentTics);
    }

    double GetImpactRegionOverlap(
        int regionIndex,
        double minimumHeightRatio,
        double maximumHeightRatio
    )
    {
        if (AnatomyProfile == null
            || regionIndex < 0
            || regionIndex >= AnatomyProfile.RegionCount)
        {
            return 0.0;
        }

        double minimumContact = Clamp(minimumHeightRatio, 0.0, 1.0);
        double maximumContact = Clamp(maximumHeightRatio, 0.0, 1.0);
        if (maximumContact < minimumContact)
        {
            double swap = minimumContact;
            minimumContact = maximumContact;
            maximumContact = swap;
        }
        if (maximumContact - minimumContact <= 0.0001)
        {
            int pointRegion = AnatomyProfile.FindRegion(minimumContact, 0.0);
            return pointRegion == regionIndex ? 1.0 : 0.0;
        }

        double overlapMinimum = Max(
            minimumContact,
            AnatomyProfile.RegionMinimumHeight[regionIndex]
        );
        double overlapMaximum = Min(
            maximumContact,
            AnatomyProfile.RegionMaximumHeight[regionIndex]
        );
        return Max(0.0, overlapMaximum - overlapMinimum);
    }

    double GetImpactRegionTotalOverlap(
        double minimumHeightRatio,
        double maximumHeightRatio
    )
    {
        if (AnatomyProfile == null) { return 0.0; }
        double total = 0.0;
        for (int regionIndex = 0;
            regionIndex < AnatomyProfile.RegionCount;
            regionIndex++)
        {
            total += GetImpactRegionOverlap(
                regionIndex,
                minimumHeightRatio,
                maximumHeightRatio
            );
        }
        return total;
    }

    void ApplyWeightedImpactLucidity(
        double minimumHeightRatio,
        double maximumHeightRatio,
        double totalOverlap
    )
    {
        LastImpactHeadContactWeight = 0.0;
        LastImpactLucidityLoss = 0.0;
        LastCombatLucidityLoss = 0.0;
        if (AnatomyProfile == null || totalOverlap <= 0.0) { return; }

        double weightedLoss = 0.0;
        for (int regionIndex = 0;
            regionIndex < AnatomyProfile.RegionCount;
            regionIndex++)
        {
            double overlap = GetImpactRegionOverlap(
                regionIndex,
                minimumHeightRatio,
                maximumHeightRatio
            );
            if (overlap <= 0.0) { continue; }

            double weight = overlap / totalOverlap;
            int naturalGrade = AnatomyProfile.GetVulnerability(regionIndex);
            if (naturalGrade != CaelumConstants.VULNERABILITY_CRITICAL_POINT)
            {
                continue;
            }

            LastImpactHeadContactWeight += weight;
            int location = AnatomyProfile.GetLocation(regionIndex);
            int slot = GetArmorSlotForLocation(location);
            double defenseRatio = CombatArmor != null
                ? Clamp(CombatArmor.GetDefense(slot) / 100.0, 0.0, 1.0)
                : 0.0;
            weightedLoss +=
                CaelumConstants.CRITICAL_POINT_BASE_LUCIDITY_LOSS
                * weight
                * (1.0 - defenseRatio);
        }

        LastImpactLucidityLoss = Min(
            CurrentCombatLucidity,
            weightedLoss
        );
        LastCombatLucidityLoss = LastImpactLucidityLoss;
        if (LastImpactLucidityLoss > 0.0)
        {
            CurrentCombatLucidity = Max(
                0.0,
                CurrentCombatLucidity - LastImpactLucidityLoss
            );
            UpdateActorLucidityState();
        }
    }

    void ReceiveCaelumImpact(
        double deltaSpeed,

        int impactKind,
        Actor sourceActor,
        double sourceSurfaceMultiplier,
        double selfEffectiveMass,
        double otherEffectiveMass,
        double closingSpeed,
        double impulse,
        double contactMinimumHeightRatio,
        double contactMaximumHeightRatio
    )
    {
        LastImpactKind = impactKind;
        LastImpactRawDeltaSpeed = Max(0.0, deltaSpeed);
        LastImpactBiologicalAbsorptionSpeed = 0.0;
        LastImpactDeltaSpeed = LastImpactRawDeltaSpeed;
        if (impactKind == CaelumConstants.IMPACT_KIND_CRUSH)
        {
            LastImpactBiologicalAbsorptionSpeed = Min(
                LastImpactRawDeltaSpeed,
                GetBiologicalLandingAbsorptionSpeed()
            );
            LastImpactDeltaSpeed = Max(
                0.0,
                LastImpactRawDeltaSpeed - LastImpactBiologicalAbsorptionSpeed
            );
        }
        LastImpactEquivalentTics =
            CalculateImpactEquivalentTics(LastImpactDeltaSpeed);
        LastImpactDamagePercent =
            CalculateImpactDamagePercent(LastImpactEquivalentTics);
        LastImpactEffectiveMass = selfEffectiveMass;
        LastImpactOtherEffectiveMass = otherEffectiveMass;
        LastImpactClosingSpeed = closingSpeed;
        LastImpactImpulse = impulse;
        LastImpactBaseDamage = 0;
        LastImpactFinalDamage = 0;
        LastImpactToughnessMultiplier = 1.0;
        LastImpactToughnessPercent = Max(0.0, double(CombatToughness));
        LastImpactArmorDefensePercent = 0.0;
        LastImpactWeightedVulnerabilityMultiplier = 0.0;
        LastImpactWeightedArmorDefensePercent = 0.0;
        LastImpactHeadContactWeight = 0.0;
        LastImpactLucidityLoss = 0.0;
        LastImpactContactMinimumHeightRatio =
            Clamp(contactMinimumHeightRatio, 0.0, 1.0);
        LastImpactContactMaximumHeightRatio =
            Clamp(contactMaximumHeightRatio, 0.0, 1.0);

        if (LastImpactDamagePercent <= 0.0 || health <= 0)
        {
            return;
        }

        double surfacedDamagePercent =
            LastImpactDamagePercent
                * Max(0.0, sourceSurfaceMultiplier);
        LastImpactPostToughnessPercent = Max(
            0.0,
            surfacedDamagePercent - LastImpactToughnessPercent
        );

        if (AnatomyProfile == null)
        {
            AnatomyProfile = CaelumAnatomyProfile(new("CaelumAnatomyProfile"));
            AnatomyProfile.InitializeHumanoid();
        }

        double totalOverlap = GetImpactRegionTotalOverlap(
            LastImpactContactMinimumHeightRatio,
            LastImpactContactMaximumHeightRatio
        );
        double weightedFinalPercent = 0.0;
        if (totalOverlap > 0.0)
        {
            for (int regionIndex = 0;
                regionIndex < AnatomyProfile.RegionCount;
                regionIndex++)
            {
                double overlap = GetImpactRegionOverlap(
                    regionIndex,
                    LastImpactContactMinimumHeightRatio,
                    LastImpactContactMaximumHeightRatio
                );
                if (overlap <= 0.0) { continue; }

                double weight = overlap / totalOverlap;
                int location = AnatomyProfile.GetLocation(regionIndex);
                int naturalGrade =
                    AnatomyProfile.GetVulnerability(regionIndex);
                int slot = GetArmorSlotForLocation(location);
                int effectiveGrade = GetEffectiveActorVulnerability(
                    naturalGrade,
                    location
                );
                double vulnerabilityMultiplier =
                    GetActorVulnerabilityMultiplier(effectiveGrade);
                double defenseRatio = CombatArmor != null
                    ? Clamp(
                        CombatArmor.GetDefense(slot) / 100.0,
                        0.0, 1.0
                    )
                    : 0.0;

                LastImpactWeightedVulnerabilityMultiplier +=
                    weight * vulnerabilityMultiplier;
                LastImpactWeightedArmorDefensePercent +=
                    weight * defenseRatio * 100.0;
                weightedFinalPercent +=
                    LastImpactPostToughnessPercent
                    * weight
                    * vulnerabilityMultiplier
                    * (1.0 - defenseRatio);
            }
        }
        else
        {
            weightedFinalPercent = LastImpactPostToughnessPercent;
            LastImpactWeightedVulnerabilityMultiplier = 1.0;
        }

        LastImpactArmorDefensePercent =
            LastImpactWeightedArmorDefensePercent;
        LastImpactBaseDamage = Max(
            0,
            int(
                GetImpactMaximumHealth()
                * LastImpactPostToughnessPercent / 100.0
                + 0.5
            )
        );
        LastImpactFinalDamage = Max(
            0,
            int(
                GetImpactMaximumHealth()
                * weightedFinalPercent / 100.0
                + 0.5
            )
        );

        if (LastImpactPostToughnessPercent > 0.0)
        {
            ApplyWeightedImpactLucidity(
                LastImpactContactMinimumHeightRatio,
                LastImpactContactMaximumHeightRatio,
                totalOverlap
            );
        }
        if (LastImpactFinalDamage <= 0) { return; }

        Actor impactSource = sourceActor;
        if (impactSource == null)
        {
            impactSource = self;
        }
        DamageMobj(
            impactSource,
            impactSource,
            LastImpactFinalDamage,
            'CaelumImpact',
            DMG_NO_ARMOR,
            0.0
        );
    }

    double GetOtherCollisionEffectiveMass(Actor other)
    {
        CaelumPlayer otherPlayer = CaelumPlayer(other);
        if (otherPlayer != null) { return otherPlayer.GetCombatMass(); }

        CaelumCombatActor otherActor = CaelumCombatActor(other);
        if (otherActor != null)
        {
            return otherActor.GetCollisionEffectiveMass();
        }

        CaelumTrainingDummy dummy = CaelumTrainingDummy(other);
        if (dummy != null)
        {
            return Max(1.0, double(dummy.Mass));
        }
        return Max(1.0, double(other.Mass));
    }

    double GetOtherCollisionDamageMultiplier(Actor other)
    {
        CaelumPlayer otherPlayer = CaelumPlayer(other);
        if (otherPlayer != null)
        {
            return Max(0.0, otherPlayer.CollisionDamageMultiplier);
        }

        CaelumCombatActor otherActor = CaelumCombatActor(other);
        if (otherActor != null)
        {
            return Max(0.0, otherActor.CollisionDamageMultiplier);
        }
        return 1.0;
    }

    void DeliverImpactToOther(
        Actor other,
        double deltaSpeed,
        double sourceEffectiveMass,
        double targetEffectiveMass,
        double closingSpeed,
        double impulse,
        double targetContactMinimumHeightRatio,
        double targetContactMaximumHeightRatio
    )
    {
        CaelumPlayer otherPlayer = CaelumPlayer(other);
        if (otherPlayer != null)
        {
            otherPlayer.ReceiveCaelumImpact(
                deltaSpeed,
                CaelumConstants.IMPACT_KIND_ACTOR,
                self,
                CollisionDamageMultiplier,
                targetEffectiveMass,
                sourceEffectiveMass,
                closingSpeed,
                impulse,
                targetContactMinimumHeightRatio,
                targetContactMaximumHeightRatio            );
            return;
        }

        CaelumCombatActor otherActor = CaelumCombatActor(other);
        if (otherActor != null)
        {
            otherActor.ReceiveCaelumImpact(
                deltaSpeed,
                CaelumConstants.IMPACT_KIND_ACTOR,
                self,
                CollisionDamageMultiplier,
                targetEffectiveMass,
                sourceEffectiveMass,
                closingSpeed,
                impulse,
                targetContactMinimumHeightRatio,
                targetContactMaximumHeightRatio            );
        }
    }

    ImpactContactState GetImpactContactState(Actor other)
    {
        for (int index = 0; index < ImpactContacts.Size(); index++)
        {
            ImpactContactState contact = ImpactContacts[index];
            if (contact != null && contact.Matches(self, other))
            {
                return contact;
            }
        }
        return null;
    }

    bool IsImpactPairLatched(Actor other)
    {
        return GetImpactContactState(other) != null;
    }

    int GetImpactContactCount()
    {
        int count = 0;
        for (int index = 0; index < ImpactContacts.Size(); index++)
        {
            if (ImpactContacts[index] != null && ImpactContacts[index].Active)
            {
                count++;
            }
        }
        return count;
    }

    double GetOtherImpactReferenceHeight(Actor other)
    {
        if (other == null) { return GetImpactReferenceHeight(); }

        CaelumPlayer otherPlayer = CaelumPlayer(other);
        if (otherPlayer != null)
        {
            return otherPlayer.GetImpactReferenceHeight();
        }

        CaelumCombatActor otherActor = CaelumCombatActor(other);
        if (otherActor != null)
        {
            return otherActor.GetImpactReferenceHeight();
        }

        return Max(1.0, other.Height);
    }

    void AddImpactContactState(ImpactContactState contact)
    {
        if (contact == null || GetImpactContactState(contact.FirstActor == self
            ? contact.SecondActor : contact.FirstActor) != null)
        {
            return;
        }
        ImpactContacts.Push(contact);
        ImpactDiagnosticContactsCreated++;
    }

    ImpactContactState LatchImpactContact(Actor other)
    {
        ImpactContactState existing = GetImpactContactState(other);
        if (existing != null) { return existing; }

        double smallerHeight = Min(
            GetImpactReferenceHeight(),
            GetOtherImpactReferenceHeight(other)
        );
        double releaseDistance = Radius + other.Radius
            + smallerHeight
                * CaelumConstants.IMPACT_CONTACT_REARM_HEIGHT_FRACTION
            + CaelumConstants.IMPACT_CONTACT_RELEASE_MARGIN;

        ImpactContactState contact = new("ImpactContactState");
        if (contact == null) { return null; }
        contact.Initialize(self, other, releaseDistance);
        contact.RegisterCollision(level.time);
        ImpactContacts.Push(contact);
        ImpactDiagnosticContactsCreated++;

        CaelumPlayer otherPlayer = CaelumPlayer(other);
        if (otherPlayer != null)
        {
            otherPlayer.AddImpactContactState(contact);
            return contact;
        }

        CaelumCombatActor otherActor = CaelumCombatActor(other);
        if (otherActor != null) { otherActor.AddImpactContactState(contact); }
        return contact;
    }

    void UpdateImpactContactLatch()
    {
        for (int index = ImpactContacts.Size() - 1; index >= 0; index--)
        {
            ImpactContactState contact = ImpactContacts[index];
            if (contact == null)
            {
                ImpactContacts.Delete(index);
                ImpactDiagnosticContactsRemoved++;
                continue;
            }
            contact.UpdateSeparation(
                level.time,
                CaelumConstants.IMPACT_CONTACT_REARM_SEPARATED_TICS
            );
            if (!contact.Active)
            {
                ImpactContacts.Delete(index);
                ImpactDiagnosticContactsRemoved++;
            }
        }
    }

    void ResolveSustainedImpactContact(
        Actor other,
        ImpactContactState contact
    )
    {
        if (other == null || contact == null || !contact.Active) { return; }
        if (!contact.BeginResolutionTick(level.time))
        {
            ImpactDiagnosticDuplicateCallbacks++;
            return;
        }
        ImpactDiagnosticUniquePairTicks++;
        double dx = other.Pos.X - Pos.X;
        double dy = other.Pos.Y - Pos.Y;
        double distanceSquared = dx * dx + dy * dy;
        if (distanceSquared <= 0.00000001)
        {
            ImpactDiagnosticRestingCallbacks++;
            return;
        }

        double closingProjection = (Vel.X - other.Vel.X) * dx
            + (Vel.Y - other.Vel.Y) * dy;
        if (closingProjection <= 0.0)
        {
            ImpactDiagnosticRestingCallbacks++;
            return;
        }

        double distance = Sqrt(distanceSquared);
        double normalX = dx / distance;
        double normalY = dy / distance;
        double closingSpeed = closingProjection / distance;
        if (closingSpeed <= CaelumConstants.IMPACT_MIN_DELTA_SPEED)
        {
            ImpactDiagnosticRestingCallbacks++;
            return;
        }

        double selfMass = Max(1.0, GetCollisionEffectiveMass());
        double otherMass = Max(1.0, GetOtherCollisionEffectiveMass(other));
        double inverseMassSum = 1.0 / selfMass + 1.0 / otherMass;
        if (inverseMassSum <= 0.0) { return; }

        // Restricción inelástica: el impulso sostenido atraviesa la isla.
        double impulse = closingSpeed / inverseMassSum;
        double selfDeltaSpeed = impulse / selfMass;
        double otherDeltaSpeed = impulse / otherMass;
        Vel.X -= normalX * selfDeltaSpeed;
        Vel.Y -= normalY * selfDeltaSpeed;
        other.Vel.X += normalX * otherDeltaSpeed;
        other.Vel.Y += normalY * otherDeltaSpeed;
        bool applyCrush = contact.RegisterSustainedTransfer(
            level.time,
            closingSpeed,
            impulse,
            CaelumConstants.IMPACT_CRUSH_INTERVAL_TICS
        );
        if (applyCrush)
        {
            ApplySustainedCrush(other, normalX, normalY, contact);
        }
    }

    void ApplySustainedCrush(
        Actor other,
        double normalX,
        double normalY,
        ImpactContactState contact
    )
    {
        if (other == null || contact == null
            || contact.LastTransmittedImpulse <= 0.0001)
        {
            return;
        }

        ImpactBody sourceBody = BuildImpactPhysicsBody();
        ImpactBody targetBody = BuildOtherImpactPhysicsBody(other);
        ImpactResult crushResult = GetImpactResultScratch();
        if (sourceBody == null || targetBody == null || crushResult == null)
        {
            return;
        }

        // Reconstruye la velocidad de cierre equivalente al impulso realmente
        // transmitido durante el intervalo. ResolveBodies conserva geometria,
        // masa efectiva y las mismas reglas universales de trauma.
        double equivalentClosingSpeed = contact.LastTransmittedImpulse
            * (1.0 / sourceBody.Mass + 1.0 / targetBody.Mass);
        sourceBody.Velocity = (
            normalX * equivalentClosingSpeed,
            normalY * equivalentClosingSpeed,
            0.0
        );
        targetBody.Velocity = (0.0, 0.0, 0.0);
        ImpactPhysics.ResolveBodies(
            sourceBody,
            targetBody,
            (normalX, normalY, 0.0),
            crushResult
        );
        if (!crushResult.Valid) { return; }

        CaelumPlayer otherPlayer = CaelumPlayer(other);
        if (otherPlayer != null)
        {
            otherPlayer.ReceiveCaelumImpact(
                crushResult.TargetDeltaSpeed,
                CaelumConstants.IMPACT_KIND_CRUSH,
                self,
                CollisionDamageMultiplier,
                targetBody.Mass,
                sourceBody.Mass,
                crushResult.ClosingSpeed,
                crushResult.Impulse,
                crushResult.TargetContactMinimumHeightRatio,
                crushResult.TargetContactMaximumHeightRatio
            );
            return;
        }

        CaelumCombatActor otherActor = CaelumCombatActor(other);
        if (otherActor != null)
        {
            otherActor.ReceiveCaelumImpact(
                crushResult.TargetDeltaSpeed,
                CaelumConstants.IMPACT_KIND_CRUSH,
                self,
                CollisionDamageMultiplier,
                targetBody.Mass,
                sourceBody.Mass,
                crushResult.ClosingSpeed,
                crushResult.Impulse,
                crushResult.TargetContactMinimumHeightRatio,
                crushResult.TargetContactMaximumHeightRatio
            );
        }
    }

    ImpactBody BuildImpactPhysicsBody()
    {
        if (ImpactSelfBodyScratch == null)
        {
            ImpactSelfBodyScratch = ImpactBody(new("ImpactBody"));
        }
        ImpactBody body = ImpactSelfBodyScratch;
        if (body == null) { return null; }
        body.Mass = Max(1.0, GetCollisionEffectiveMass());
        body.Height = GetImpactReferenceHeight();
        body.Position = Pos;
        body.Velocity = Vel;
        body.Restitution = CaelumConstants.IMPACT_RESTITUTION;
        body.SurfaceMultiplier = CollisionDamageMultiplier;
        return body;
    }

    ImpactBody BuildOtherImpactPhysicsBody(Actor other)
    {
        if (ImpactOtherBodyScratch == null)
        {
            ImpactOtherBodyScratch = ImpactBody(new("ImpactBody"));
        }
        ImpactBody body = ImpactOtherBodyScratch;
        if (body == null) { return null; }
        body.Mass = Max(1.0, GetOtherCollisionEffectiveMass(other));
        body.Height = GetOtherImpactReferenceHeight(other);
        body.Position = (0.0, 0.0, 0.0);
        body.Velocity = (0.0, 0.0, 0.0);
        if (other != null)
        {
            body.Position = other.Pos;
            body.Velocity = other.Vel;
        }
        body.Restitution = CaelumConstants.IMPACT_RESTITUTION;
        body.SurfaceMultiplier = GetOtherCollisionDamageMultiplier(other);
        return body;
    }

    ImpactResult GetImpactResultScratch()
    {
        if (ImpactResultScratch == null)
        {
            ImpactResultScratch = ImpactResult(new("ImpactResult"));
        }
        if (ImpactResultScratch != null) { ImpactResultScratch.Reset(); }
        return ImpactResultScratch;
    }

    override void CollidedWith(Actor other, bool passive)
    {
        Super.CollidedWith(other, passive);

        CaelumCombatActor otherCombatActor = CaelumCombatActor(other);
        if (passive || DisableCaelumImpactContacts
            || (otherCombatActor != null
                && otherCombatActor.DisableCaelumImpactContacts)
            || other == null || other == self
            || health <= 0 || other.health <= 0
            || (CaelumPlayer(other) == null
                && CaelumCombatActor(other) == null
                && CaelumTrainingDummy(other) == null))
        {
            return;
        }
        ImpactDiagnosticCollisionCallbacks++;
        ImpactContactState contactState = GetImpactContactState(other);
        if (contactState != null)
        {
            ResolveSustainedImpactContact(other, contactState);
            return;
        }

        double dx = other.Pos.X - Pos.X;
        double dy = other.Pos.Y - Pos.Y;
        double distanceSquared = dx * dx + dy * dy;
        if (distanceSquared <= 0.00000001)
        {
            ImpactDiagnosticRestingCallbacks++;
            return;
        }

        double closingProjection = (Vel.X - other.Vel.X) * dx
            + (Vel.Y - other.Vel.Y) * dy;
        if (closingProjection <= 0.0)
        {
            ImpactDiagnosticRestingCallbacks++;
            return;
        }

        double distance = Sqrt(distanceSquared);
        double closingSpeed = closingProjection / distance;
        if (closingSpeed <= CaelumConstants.IMPACT_MIN_DELTA_SPEED)
        {
            ImpactDiagnosticRestingCallbacks++;
            return;
        }
        ImpactDiagnosticUniquePairTicks++;

        Vector3 collisionNormal = (dx / distance, dy / distance, 0.0);
        ImpactBody selfBody;
        ImpactBody otherBody;
        ImpactResult impact;
        selfBody = BuildImpactPhysicsBody();
        otherBody = BuildOtherImpactPhysicsBody(other);
        impact = GetImpactResultScratch();
        if (selfBody == null || otherBody == null || impact == null)
        {
            return;
        }
        ImpactPhysics.ResolveBodies(
            selfBody,
            otherBody,
            collisionNormal,
            impact
        );
        if (!impact.Valid) { return; }

        contactState = LatchImpactContact(other);
        if (contactState != null)
        {
            contactState.BeginResolutionTick(level.time);
            contactState.LastClosingSpeed = impact.ClosingSpeed;
            contactState.LastTransmittedImpulse = impact.Impulse;
        }

        Vel.X -= impact.Normal.X * impact.SourceDeltaSpeed;
        Vel.Y -= impact.Normal.Y * impact.SourceDeltaSpeed;
        other.Vel.X += impact.Normal.X * impact.TargetDeltaSpeed;
        other.Vel.Y += impact.Normal.Y * impact.TargetDeltaSpeed;

        ReceiveCaelumImpact(
            impact.SourceDeltaSpeed,
            CaelumConstants.IMPACT_KIND_ACTOR,
            other,
            otherBody.SurfaceMultiplier,
            selfBody.Mass,
            otherBody.Mass,
            impact.ClosingSpeed,
            impact.Impulse,
            impact.SourceContactMinimumHeightRatio,
            impact.SourceContactMaximumHeightRatio
        );
        DeliverImpactToOther(
            other,
            impact.TargetDeltaSpeed,
            selfBody.Mass,
            otherBody.Mass,
            impact.ClosingSpeed,
            impact.Impulse,
            impact.TargetContactMinimumHeightRatio,
            impact.TargetContactMaximumHeightRatio
        );
    }

    void RegisterStaticImpactFromVelocityLoss(
        Vector3 preImpactVelocity,
        Vector3 postImpactVelocity,
        int impactKind
    )
    {
        Vector3 lostVelocity = (
            preImpactVelocity.X - postImpactVelocity.X,
            preImpactVelocity.Y - postImpactVelocity.Y,
            0.0
        );
        double lostSpeed = Sqrt(
            lostVelocity.X * lostVelocity.X
                + lostVelocity.Y * lostVelocity.Y
        );
        if (lostSpeed <= CaelumConstants.IMPACT_MIN_DELTA_SPEED)
        {
            return;
        }

        double preHorizontalSpeed = Sqrt(
            preImpactVelocity.X * preImpactVelocity.X
                + preImpactVelocity.Y * preImpactVelocity.Y
        );
        if (preHorizontalSpeed <= CaelumConstants.IMPACT_MIN_DELTA_SPEED)
        {
            return;
        }
        double lostSpeedFraction = Clamp(
            lostSpeed / preHorizontalSpeed,
            0.0,
            1.0
        );
        if (lostSpeedFraction
            < CaelumConstants.IMPACT_STATIC_MIN_LOST_SPEED_FRACTION)
        {
            return;
        }

        Vector3 normal = (
            lostVelocity.X / lostSpeed,
            lostVelocity.Y / lostSpeed,
            0.0
        );
        ImpactBody selfBody;
        ImpactResult impact;
        selfBody = BuildImpactPhysicsBody();
        impact = GetImpactResultScratch();
        if (selfBody == null || impact == null) { return; }
        selfBody.Velocity = preImpactVelocity;
        ImpactPhysics.ResolveStatic(
            selfBody,
            normal,
            impact
        );
        if (!impact.Valid) { return; }

        ReceiveCaelumImpact(
            impact.SourceDeltaSpeed,
            impactKind,
            self,
            1.0,
            selfBody.Mass,
            0.0,
            impact.ClosingSpeed,
            impact.Impulse,
            0.0,
            1.0
        );
    }

    void RegisterWorldImpact(double deltaSpeed, int impactKind)
    {
        double effectiveDeltaSpeed = Max(0.0, deltaSpeed);
        LastImpactRawDeltaSpeed = effectiveDeltaSpeed;
        LastImpactBiologicalAbsorptionSpeed = 0.0;

        if (impactKind == CaelumConstants.IMPACT_KIND_FLOOR)
        {
            effectiveDeltaSpeed =
                ApplyBiologicalLandingAbsorption(effectiveDeltaSpeed);
        }

        ReceiveCaelumImpact(
            effectiveDeltaSpeed,
            impactKind,
            self,
            1.0,
            GetCollisionEffectiveMass(),
            0.0,
            effectiveDeltaSpeed,
            0.0,
            0.0,
            impactKind == CaelumConstants.IMPACT_KIND_FLOOR ? 0.0 : 1.0
        );
    }

    override int DamageMobj(
        Actor inflictor,
        Actor source,
        int damage,
        Name mod,
        int flags,
        double angle
    )
    {
        if (mod == 'CaelumImpact')
        {
            int healthBeforeImpact = health;
            double adrenalineRatioBeforeImpact = GetCombatAdrenalineRatio();
            int result = Super.DamageMobj(
                inflictor,
                source,
                damage,
                mod,
                flags | DMG_NO_ARMOR,
                angle
            );
            if (health < healthBeforeImpact)
            {
                int actualHealthLost = healthBeforeImpact - health;
                UpdateCombatHealthEffects();
                CalculateAndTriggerActorPain(
                    actualHealthLost,
                    adrenalineRatioBeforeImpact,
                    LastImpactKind == CaelumConstants.IMPACT_KIND_ACTOR
                );
                if (LastImpactKind == CaelumConstants.IMPACT_KIND_ACTOR)
                {
                    AddActorCombatAdrenaline(
                        CaelumConstants.ADRENALINE_GAIN_ON_DAMAGE
                    );
                    MarkActorCombatActivity();
                }
            }
            return result;
        }

        LastCombatEvasionAttempted = false;
        LastCombatEvasionSucceeded = false;
        LastCombatEvasionChancePercent = 0.0;
        LastCombatEvasionRollPercent = 0.0;

        if (IsCombatDamageEvadable(inflictor, source, damage, mod, flags))
        {
            LastCombatEvasionAttempted = true;
            LastCombatEvasionChancePercent = Clamp(
                EffectiveCombatEvasionChance,
                0.0,
                100.0
            );
            int evasionRoll = Random[CaelumActorEvasion](0, 999999);
            LastCombatEvasionRollPercent = evasionRoll / 10000.0;
            if (LastCombatEvasionRollPercent < LastCombatEvasionChancePercent)
            {
                LastCombatEvasionSucceeded = true;
                PendingLocalizedImpact = false;
                PendingLocalizedCriticalHit = false;
                AddActorCombatAdrenaline(
                    CaelumConstants.ADRENALINE_GAIN_ON_EVASION
                );
                MarkActorCombatActivity();
                return 0;
            }
        }

        if (flags & DMG_EXPLOSION)
        {
            PendingLocalizedImpact = false;
            PendingLocalizedCriticalHit = false;
            return ApplyActorExplosionDefense(
                inflictor,
                source,
                damage,
                mod,
                flags,
                angle
            );
        }

        int healthBeforeDamage = health;
        double adrenalineRatioBeforeDamage = GetCombatAdrenalineRatio();
        bool hadLocalizedImpactForLucidity = PendingLocalizedImpact;
        int naturalVulnerabilityBeforeDamage = hadLocalizedImpactForLucidity
            ? LastAnatomyNaturalVulnerabilityGrade
            : CaelumConstants.VULNERABILITY_SENSITIVE_POINT;
        int effectiveVulnerabilityBeforeDamage = hadLocalizedImpactForLucidity
            ? LastAnatomyVulnerabilityGrade
            : CaelumConstants.VULNERABILITY_SENSITIVE_POINT;
        bool localizedCriticalHit = PendingLocalizedCriticalHit;
        ResolveActorArmorImpact(damage);
        PendingLocalizedCriticalHit = false;
        LastCombatToughnessDamageMultiplier = Clamp(
            1.0 - CombatToughness * (CombatToughness + 1) / 10100.0,
            0.0,
            1.0
        );
        int retainedDamage = Max(
            0,
            int(LastCombatArmorPostDefenseDamage
                * LastCombatToughnessDamageMultiplier + 0.5)
        );
        if (retainedDamage <= 0) { return 0; }
        int result = Super.DamageMobj(
            inflictor,
            source,
            retainedDamage,
            mod,
            flags,
            angle
        );

        if (health < healthBeforeDamage)
        {
            int actualHealthLost = healthBeforeDamage - health;
            CaelumActorProjectile attackProjectile = CaelumActorProjectile(inflictor);
            if (attackProjectile != null)
            {
                ApplyActorAttackPush(
                    self,
                    inflictor.Angle,
                    attackProjectile.CaelumPushMultiplier
                );
            }
            ApplyActorLocalizedLucidityLoss(
                naturalVulnerabilityBeforeDamage,
                effectiveVulnerabilityBeforeDamage,
                localizedCriticalHit
            );
            UpdateCombatHealthEffects();
            CalculateAndTriggerActorPain(
                actualHealthLost,
                adrenalineRatioBeforeDamage,
                true
            );
            AddActorCombatAdrenaline(
                CaelumConstants.ADRENALINE_GAIN_ON_DAMAGE
            );
            MarkActorCombatActivity();
        }

        return result;
    }

    double GetActorEffectiveExplosionRadius(Actor inflictor, int incomingDamage)
    {
        double resolvedRadius = Max(1.0, double(incomingDamage));
        if (inflictor == null) { return resolvedRadius; }

        CaelumCombatActor combatInflictor = CaelumCombatActor(inflictor);
        if (combatInflictor != null
            && combatInflictor.CombatAreaExplosionActive)
        {
            return combatInflictor.CombatAreaExplosionRadius;
        }

        CaelumActorProjectile actorProjectile = CaelumActorProjectile(inflictor);
        if (actorProjectile != null
            && actorProjectile.CaelumActorExplosionRadius > 0.0)
        {
            return actorProjectile.CaelumActorExplosionRadius;
        }

        resolvedRadius = inflictor.ExplosionRadius;
        if (resolvedRadius < 0.0)
        {
            resolvedRadius = inflictor.ExplosionDamage;
        }
        if (resolvedRadius <= 0.0)
        {
            resolvedRadius = Max(1.0, double(incomingDamage));
        }
        return resolvedRadius;
    }

    int ApplyActorExplosionDefense(
        Actor inflictor,
        Actor source,
        int incomingDamage,
        Name mod,
        int flags,
        double damageAngle
    )
    {
        if (incomingDamage <= 0 || inflictor == null || AnatomyProfile == null)
        {
            return 0;
        }
        if (bInvulnerable)
        {
            return Super.DamageMobj(
                inflictor, source, incomingDamage, mod, flags, damageAngle
            );
        }

        double explosionRadius = GetActorEffectiveExplosionRadius(
            inflictor,
            incomingDamage
        );
        int touchedRegionMask = AnatomyProfile.GetExplosionTouchedRegionMask(
            self,
            inflictor.Pos,
            explosionRadius
        );
        if (touchedRegionMask == 0) { return 0; }

        CaelumActorProjectile attackProjectile = CaelumActorProjectile(inflictor);
        CaelumCombatActor areaAttacker = CaelumCombatActor(source);
        if (areaAttacker == null)
        {
            areaAttacker = CaelumCombatActor(inflictor);
        }
        bool criticalHit = (attackProjectile != null
                && attackProjectile.CaelumCriticalHit)
            || (areaAttacker != null
                && areaAttacker.GetCombatAreaExplosionCriticalHit());
        LastCombatArmorIncomingDamage = 0.0;
        LastCombatArmorAbsorbedDamage = 0.0;
        LastCombatArmorPostDefenseDamage = 0.0;
        LastCombatArmorDurabilityLoss = 0;
        LastCombatArmorDurabilityChancePercent = 0.0;
        LastCombatArmorDurabilityRollPercent = 0.0;
        LastCombatToughnessDamageMultiplier = Clamp(
            1.0 - CombatToughness * (CombatToughness + 1) / 10100.0,
            0.0,
            1.0
        );

        int totalHealthDamage = 0;
        int lucidityNaturalGrade = -1;
        int lucidityEffectiveGrade = -1;
        double lucidityDefensePercent = 0.0;
        for (int regionIndex = 0;
            regionIndex < AnatomyProfile.RegionCount;
            regionIndex++)
        {
            if ((touchedRegionMask & (1 << regionIndex)) == 0) { continue; }

            int location = AnatomyProfile.GetLocation(regionIndex);
            int naturalGrade = AnatomyProfile.GetVulnerability(regionIndex);
            int effectiveGrade = GetEffectiveActorVulnerability(
                naturalGrade,
                location
            );
            int slot = GetArmorSlotForLocation(location);
            double vulnerabilityMultiplier =
                GetActorVulnerabilityMultiplier(effectiveGrade);
            if (criticalHit)
            {
                vulnerabilityMultiplier *= vulnerabilityMultiplier + 1.0;
            }
            double preDefenseDamage = incomingDamage
                * vulnerabilityMultiplier;
            int defensePercent = CombatArmor != null
                ? CombatArmor.GetDefense(slot) : 0;
            double defenseRatio = Clamp(defensePercent / 100.0, 0.0, 1.0);
            double absorbedDamage = preDefenseDamage * defenseRatio;
            double postDefenseDamage = Max(
                0.0,
                preDefenseDamage - absorbedDamage
            );

            LastAnatomyLocation = location;
            LastAnatomyNaturalVulnerabilityGrade = naturalGrade;
            LastAnatomyVulnerabilityGrade = effectiveGrade;
            LastCombatArmorSlot = slot;
            LastCombatArmorDefensePercent = defensePercent;
            LastCombatArmorIncomingDamage += preDefenseDamage;
            LastCombatArmorAbsorbedDamage += absorbedDamage;
            LastCombatArmorPostDefenseDamage += postDefenseDamage;
            totalHealthDamage += Max(
                0,
                int(postDefenseDamage
                    * LastCombatToughnessDamageMultiplier + 0.5)
            );

            if (naturalGrade == CaelumConstants.VULNERABILITY_CRITICAL_POINT
                && lucidityNaturalGrade < 0)
            {
                lucidityNaturalGrade = naturalGrade;
                lucidityEffectiveGrade = effectiveGrade;
                lucidityDefensePercent = defensePercent;
            }

            if (CombatArmor != null
                && CombatArmor.Durability[slot] > 0
                && absorbedDamage > 0.0)
            {
                int durabilityLoss = int(
                    absorbedDamage
                        / CaelumConstants.ARMOR_ABSORBED_DAMAGE_PER_GUARANTEED_DURABILITY
                );
                double remainder = absorbedDamage
                    - durabilityLoss
                        * CaelumConstants.ARMOR_ABSORBED_DAMAGE_PER_GUARANTEED_DURABILITY;
                double chancePercent = Clamp(
                    remainder
                        / CaelumConstants.ARMOR_DAMAGE_PER_DURABILITY_CHANCE_PERCENT,
                    0.0,
                    100.0
                );
                double rollPercent = Random[CaelumActorArmorDurability](0, 999999)
                    / 10000.0;
                if (rollPercent < chancePercent) { durabilityLoss++; }
                durabilityLoss = Min(
                    durabilityLoss,
                    CombatArmor.Durability[slot]
                );
                CombatArmor.Durability[slot] -= durabilityLoss;
                LastCombatArmorDurabilityLoss += durabilityLoss;
                LastCombatArmorDurabilityChancePercent = chancePercent;
                LastCombatArmorDurabilityRollPercent = rollPercent;
            }
        }

        if (totalHealthDamage <= 0) { return 0; }
        int healthBeforeDamage = health;
        double adrenalineRatioBeforeDamage = GetCombatAdrenalineRatio();
        int result = Super.DamageMobj(
            inflictor,
            source,
            totalHealthDamage,
            mod,
            flags | DMG_NO_ARMOR,
            damageAngle
        );
        if (health < healthBeforeDamage)
        {
            int actualHealthLost = healthBeforeDamage - health;
            if (attackProjectile != null)
            {
                ApplyActorAttackPush(
                    self,
                    inflictor.AngleTo(self),
                    attackProjectile.CaelumPushMultiplier
                );
            }
            if (lucidityNaturalGrade >= 0)
            {
                LastCombatArmorDefensePercent = int(lucidityDefensePercent);
                ApplyActorLocalizedLucidityLoss(
                    lucidityNaturalGrade,
                    lucidityEffectiveGrade,
                    criticalHit
                );
            }
            UpdateCombatHealthEffects();
            CalculateAndTriggerActorPain(
                actualHealthLost,
                adrenalineRatioBeforeDamage,
                true
            );
            AddActorCombatAdrenaline(
                CaelumConstants.ADRENALINE_GAIN_ON_DAMAGE
            );
            MarkActorCombatActivity();
        }
        return result;
    }

    // Natural anatomy decides whether lucidity is affected even when armor
    // reinforcement changes the effective grade. Defense and Toughness reduce
    // the loss; a critical uses the same effective vulnerability relation as
    // the player's localized rule.
    void ApplyActorLocalizedLucidityLoss(
        int naturalVulnerabilityGrade,
        int effectiveVulnerabilityGrade,
        bool criticalHit
    )
    {
        LastCombatLucidityLoss = 0.0;
        LastCombatLucidityCriticalFactor = 1.0;
        if (naturalVulnerabilityGrade
            != CaelumConstants.VULNERABILITY_CRITICAL_POINT)
        {
            return;
        }

        double normalMultiplier = GetActorVulnerabilityMultiplier(
            effectiveVulnerabilityGrade
        );
        if (criticalHit)
        {
            // Critical multiplier = normal * (normal + 1), therefore its
            // relative lucidity factor is normal + 1.
            LastCombatLucidityCriticalFactor = normalMultiplier + 1.0;
        }
        double defenseRatio = Clamp(
            LastCombatArmorDefensePercent / 100.0,
            0.0,
            1.0
        );
        LastCombatLucidityLoss = Min(
            CurrentCombatLucidity,
            CaelumConstants.CRITICAL_POINT_BASE_LUCIDITY_LOSS
                * LastCombatLucidityCriticalFactor
                * (1.0 - defenseRatio)
                * LastCombatToughnessDamageMultiplier
        );
        CurrentCombatLucidity = Max(
            0.0,
            CurrentCombatLucidity - LastCombatLucidityLoss
        );
        UpdateActorLucidityState();
    }

    void UpdateActorLucidityState()
    {
        int previousState = CombatLucidityState;
        double ratio = CurrentCombatLucidity
            / CaelumConstants.MAXIMUM_LUCIDITY;
        if (ratio <= CaelumConstants.LUCIDITY_STUNNED_THRESHOLD)
        {
            CombatLucidityState = CaelumConstants.LUCIDITY_STATE_STUNNED;
        }
        else if (ratio <= CaelumConstants.LUCIDITY_DIZZY_THRESHOLD)
        {
            CombatLucidityState = CaelumConstants.LUCIDITY_STATE_DIZZY;
        }
        else
        {
            CombatLucidityState = CaelumConstants.LUCIDITY_STATE_NORMAL;
        }

        CombatLucidityAccuracyMultiplier = CombatLucidityState
            == CaelumConstants.LUCIDITY_STATE_NORMAL
            ? 1.0
            : CaelumConstants.LUCIDITY_DIZZY_ACCURACY_MULTIPLIER;
        if (previousState != CaelumConstants.LUCIDITY_STATE_STUNNED
            && CombatLucidityState == CaelumConstants.LUCIDITY_STATE_STUNNED)
        {
            CombatLucidityPhysicalStunRemaining =
                CaelumConstants.LUCIDITY_PHYSICAL_STUN_SECONDS;
        }
    }

    void ResolveActorArmorImpact(int incomingDamage)
    {
        bool hadLocalizedImpact = PendingLocalizedImpact;
        LastCombatArmorIncomingDamage = Max(0, incomingDamage);
        LastCombatArmorAbsorbedDamage = 0.0;
        LastCombatArmorPostDefenseDamage = LastCombatArmorIncomingDamage;
        LastCombatArmorDurabilityLoss = 0;
        LastCombatArmorDurabilityChancePercent = 0.0;
        LastCombatArmorDurabilityRollPercent = 0.0;

        if (!PendingLocalizedImpact)
        {
            LastAnatomyLocation = CaelumConstants.HIT_LOCATION_TORSO;
            LastAnatomyNaturalVulnerabilityGrade =
                CaelumConstants.VULNERABILITY_SENSITIVE_POINT;
            LastAnatomyVulnerabilityGrade = GetEffectiveActorVulnerability(
                LastAnatomyNaturalVulnerabilityGrade,
                LastAnatomyLocation
            );
            LastAnatomyHeightRatio = 0.60;
            LastAnatomyLateralRatio = 0.0;
        }
        PendingLocalizedImpact = false;

        // Sword/staff traces already include the authored region multiplier.
        // Damage without contact metadata adopts the sensitive torso fallback
        // here so ordinary attacks still enter the same vulnerability order.
        if (!hadLocalizedImpact)
        {
            LastCombatArmorIncomingDamage *=
                GetActorVulnerabilityMultiplier(LastAnatomyVulnerabilityGrade);
            LastCombatArmorPostDefenseDamage = LastCombatArmorIncomingDamage;
        }

        LastCombatArmorSlot = GetArmorSlotForLocation(LastAnatomyLocation);
        LastCombatArmorDefensePercent = CombatArmor != null
            ? CombatArmor.GetDefense(LastCombatArmorSlot) : 0;
        double defenseRatio = Clamp(
            LastCombatArmorDefensePercent / 100.0,
            0.0,
            1.0
        );
        LastCombatArmorAbsorbedDamage =
            LastCombatArmorIncomingDamage * defenseRatio;
        LastCombatArmorPostDefenseDamage = Max(
            0.0,
            LastCombatArmorIncomingDamage - LastCombatArmorAbsorbedDamage
        );

        if (CombatArmor == null
            || CombatArmor.Durability[LastCombatArmorSlot] <= 0
            || LastCombatArmorAbsorbedDamage <= 0.0)
        {
            return;
        }

        LastCombatArmorDurabilityLoss = int(
            LastCombatArmorAbsorbedDamage
                / CaelumConstants.ARMOR_ABSORBED_DAMAGE_PER_GUARANTEED_DURABILITY
        );
        double remainder = LastCombatArmorAbsorbedDamage
            - LastCombatArmorDurabilityLoss
                * CaelumConstants.ARMOR_ABSORBED_DAMAGE_PER_GUARANTEED_DURABILITY;
        LastCombatArmorDurabilityChancePercent = Clamp(
            remainder / CaelumConstants.ARMOR_DAMAGE_PER_DURABILITY_CHANCE_PERCENT,
            0.0,
            100.0
        );
        int durabilityRoll = Random[CaelumActorArmorDurability](0, 999999);
        LastCombatArmorDurabilityRollPercent = durabilityRoll / 10000.0;
        if (LastCombatArmorDurabilityRollPercent
            < LastCombatArmorDurabilityChancePercent)
        {
            LastCombatArmorDurabilityLoss++;
        }
        LastCombatArmorDurabilityLoss = Min(
            LastCombatArmorDurabilityLoss,
            CombatArmor.Durability[LastCombatArmorSlot]
        );
        CombatArmor.Durability[LastCombatArmorSlot] -=
            LastCombatArmorDurabilityLoss;
    }

    double GetActorVulnerabilityMultiplier(int grade)
    {
        switch (Clamp(grade, 0, CaelumConstants.VULNERABILITY_GRADE_COUNT - 1))
        {
            case CaelumConstants.VULNERABILITY_CRITICAL_POINT:
                return CaelumConstants.VULNERABILITY_CRITICAL_MULTIPLIER;
            case CaelumConstants.VULNERABILITY_SENSITIVE_POINT:
                return CaelumConstants.VULNERABILITY_SENSITIVE_MULTIPLIER;
            case CaelumConstants.VULNERABILITY_WEAK_POINT:
                return CaelumConstants.VULNERABILITY_WEAK_MULTIPLIER;
            case CaelumConstants.VULNERABILITY_STRONG_POINT:
                return CaelumConstants.VULNERABILITY_STRONG_MULTIPLIER;
            case CaelumConstants.VULNERABILITY_HARD_POINT:
                return CaelumConstants.VULNERABILITY_HARD_MULTIPLIER;
            case CaelumConstants.VULNERABILITY_ARMORED_POINT:
                return CaelumConstants.VULNERABILITY_ARMORED_MULTIPLIER;
            default:
                return CaelumConstants.VULNERABILITY_NEUTRAL_MULTIPLIER;
        }
    }

    bool IsCombatDamageEvadable(
        Actor inflictor,
        Actor source,
        int damage,
        Name mod,
        int flags
    )
    {
        if (health <= 0 || damage <= 0 || (flags & DMG_EXPLOSION))
        {
            return false;
        }
        if (inflictor != null && inflictor.bMissile)
        {
            return true;
        }
        return source != null
            && (mod == 'Melee'
                || mod == 'Hitscan'
                || mod == 'Bullet'
                || mod == 'CaelumMeleeTest'
                || mod == 'CaelumRangedTest'
                || mod == 'CaelumMagicTest');
    }

    void CalculateAndTriggerActorPain(
        int actualHealthLost,
        double adrenalineRatioBeforeDamage,
        bool grantPainAdrenaline
    )
    {
        LastCombatHealthLossPercent = 0.0;
        LastCombatPainChancePercent = 0.0;
        LastCombatPainTriggered = false;
        if (actualHealthLost <= 0 || CombatMaximumHealth <= 0 || health <= 0)
        {
            return;
        }

        LastCombatHealthLossPercent = 100.0
            * actualHealthLost / CombatMaximumHealth;
        LastCombatPainChancePercent = Clamp(
            10.0 * LastCombatHealthLossPercent
                * LastCombatToughnessDamageMultiplier
                * CombatHealthPainMultiplier
                * (1.0 - adrenalineRatioBeforeDamage),
            0.0,
            100.0
        );

        int painRoll = Random[CaelumActorPain](0, 999999);
        if (painRoll < int(LastCombatPainChancePercent * 10000.0))
        {
            State painState = FindState('Pain');
            if (painState != null)
            {
                SetState(painState);
                LastCombatPainTriggered = true;
                if (grantPainAdrenaline)
                {
                    AddActorCombatAdrenaline(
                        CaelumConstants.ADRENALINE_GAIN_ON_PAIN
                    );
                }
            }
        }
    }

    double GetCombatAdrenalineRatio()
    {
        if (MaximumCombatAdrenaline <= 0.0) { return 0.0; }
        return Clamp(
            CurrentCombatAdrenaline / MaximumCombatAdrenaline,
            0.0,
            1.0
        );
    }

    void AddActorCombatAdrenaline(double baseAmount)
    {
        CurrentCombatAdrenaline = Clamp(
            CurrentCombatAdrenaline
                + Max(0.0, baseAmount) * CombatAdrenalineGainMultiplier,
            0.0,
            MaximumCombatAdrenaline
        );
        UpdateCombatHealthEffects();
    }

    void MarkActorCombatActivity()
    {
        CombatTimeRemaining = CaelumConstants.COMBAT_TIMEOUT_SECONDS;
    }

    void UpdateCombatHealthEffects()
    {
        double healthRatio = CombatMaximumHealth > 0
            ? Clamp(double(health) / CombatMaximumHealth, 0.0, 1.0)
            : 1.0;
        double rawPerformance = 1.0;
        double rawIntensity = 1.0;
        if (healthRatio <= CaelumConstants.HEALTH_BADLY_WOUNDED_THRESHOLD)
        {
            CombatHealthState = CaelumConstants.HEALTH_STATE_BADLY_WOUNDED;
            rawPerformance =
                CaelumConstants.HEALTH_BADLY_WOUNDED_PERFORMANCE_MULTIPLIER;
            rawIntensity =
                CaelumConstants.HEALTH_BADLY_WOUNDED_INTENSITY_MULTIPLIER;
        }
        else if (healthRatio <= CaelumConstants.HEALTH_WOUNDED_THRESHOLD)
        {
            CombatHealthState = CaelumConstants.HEALTH_STATE_WOUNDED;
            rawPerformance =
                CaelumConstants.HEALTH_WOUNDED_PERFORMANCE_MULTIPLIER;
            rawIntensity =
                CaelumConstants.HEALTH_WOUNDED_INTENSITY_MULTIPLIER;
        }
        else
        {
            CombatHealthState = CaelumConstants.HEALTH_STATE_NORMAL;
        }

        int effectivePatience = CombatPatience
            + GetCombatArmorAttributeBonus(CaelumConstants.ATTRIBUTE_PATIENCE);
        int effectiveAgility = CombatAgility
            + GetCombatArmorAttributeBonus(CaelumConstants.ATTRIBUTE_AGILITY);
        double patienceMultiplier = Clamp(
            1.0 - effectivePatience * (effectivePatience + 1) / 10100.0,
            0.0,
            1.0
        );
        double adrenalineRatio = GetCombatAdrenalineRatio();
        double patienceAdjustedPerformance = 1.0
            - (1.0 - rawPerformance) * patienceMultiplier;
        CombatHealthPerformanceMultiplier = patienceAdjustedPerformance
            + (1.0 - patienceAdjustedPerformance) * adrenalineRatio;
        CombatHealthPainMultiplier = 1.0
            + (rawIntensity - 1.0)
                * patienceMultiplier
                * (1.0 - adrenalineRatio);
        CombatAdrenalineGainMultiplier = rawIntensity;

        double baseEvasion = effectiveAgility * (effectiveAgility + 1) / 101.0;
        double massMultiplier = 100.0 / (Mass / 2.0 + 50.0);
        EffectiveCombatEvasionChance = baseEvasion
            * massMultiplier
            * CombatHealthPerformanceMultiplier;
        Speed = CombatBaseSpeed * CombatHealthPerformanceMultiplier
            * (ElementalStatus != null
                ? ElementalStatus.GetMovementMultiplier() : 1.0);
    }

    void CycleDebugCombatHealthState()
    {
        double healthRatio = CombatMaximumHealth > 0
            ? double(health) / CombatMaximumHealth : 1.0;
        if (healthRatio > CaelumConstants.HEALTH_WOUNDED_THRESHOLD)
        {
            health = Max(1, int(CombatMaximumHealth
                * CaelumConstants.HEALTH_WOUNDED_THRESHOLD));
        }
        else if (healthRatio > CaelumConstants.HEALTH_BADLY_WOUNDED_THRESHOLD)
        {
            health = Max(1, int(CombatMaximumHealth
                * CaelumConstants.HEALTH_BADLY_WOUNDED_THRESHOLD));
        }
        else
        {
            health = CombatMaximumHealth;
        }
        UpdateCombatHealthEffects();
    }

    void CycleDebugCombatLucidityState()
    {
        if (CombatLucidityState == CaelumConstants.LUCIDITY_STATE_NORMAL)
        {
            CurrentCombatLucidity = CaelumConstants.MAXIMUM_LUCIDITY
                * CaelumConstants.LUCIDITY_DIZZY_THRESHOLD;
        }
        else if (CombatLucidityState == CaelumConstants.LUCIDITY_STATE_DIZZY)
        {
            CurrentCombatLucidity = CaelumConstants.MAXIMUM_LUCIDITY
                * CaelumConstants.LUCIDITY_STUNNED_THRESHOLD;
        }
        else
        {
            CurrentCombatLucidity = CaelumConstants.MAXIMUM_LUCIDITY;
        }
        UpdateActorLucidityState();
    }

    int GetCombatArmorAttributeBonus(int attribute)
    {
        if (CombatArmor == null) { return 0; }
        int total = 0;
        for (int slot = 0; slot < CaelumConstants.ARMOR_SLOT_COUNT; slot++)
        {
            if (CombatArmor.GetBonusAttribute(slot) == attribute)
            {
                total += CombatArmor.GetTierBonus(slot);
            }
        }
        return total;
    }

    override void Tick()
    {
        Vector3 prePhysicsVelocity = Vel;

        Super.Tick();
        UpdateCaelumRecognitionSound();

        // Los actores diagnósticos conservan estados nativos, A_Look, A_Chase
        // y ataques, pero no recalculan estadísticas, estados elementales ni
        // contactos que no forman parte de esta prueba. El juego normal no
        // toma esta salida rápida.
        if (CaelumMassAIScheduleActive || CaelumDiagnosticPassiveAI)
        {
            return;
        }
        if (ElementalStatus != null) ElementalStatus.Tick(self);

        bool groundedNow = Pos.Z <= FloorZ + 0.01;
        if (!ImpactGroundTrackingInitialized)
        {
            ImpactWasGroundedLastTick = groundedNow;
            ImpactGroundTrackingInitialized = true;
        }
        if (!groundedNow && Vel.Z < 0.0)
        {
            LastImpactFallingVelocityZ = Vel.Z;
        }
        if (groundedNow
            && !ImpactWasGroundedLastTick
            && LastImpactFallingVelocityZ < 0.0)
        {
            RegisterWorldImpact(
                Abs(LastImpactFallingVelocityZ),
                CaelumConstants.IMPACT_KIND_FLOOR
            );
            LastImpactFallingVelocityZ = 0.0;
        }
        ImpactWasGroundedLastTick = groundedNow;

        // Para NPC se conserva por ahora la escala cruda de pared, pero sólo al
        // iniciar contacto para eliminar daño repetido por presión continua.
        bool wallBlockedNow = BlockingMobj == null
            && (MovementBlockingLine != null || BlockingLine != null);
        if (wallBlockedNow)
        {
            ImpactStaticClearTics = 0;
            if (!ImpactWasWallBlockedLastTick)
            {
                double deltaX = Vel.X - prePhysicsVelocity.X;
                double deltaY = Vel.Y - prePhysicsVelocity.Y;
                double wallDeltaSpeed = Sqrt(
                    deltaX * deltaX + deltaY * deltaY
                );
                if (wallDeltaSpeed > CaelumConstants.IMPACT_MIN_DELTA_SPEED)
                {
                    RegisterStaticImpactFromVelocityLoss(
                        prePhysicsVelocity,
                        Vel,
                        CaelumConstants.IMPACT_KIND_WALL
                    );
                }
            }
            ImpactWasWallBlockedLastTick = true;
        }
        else if (ImpactWasWallBlockedLastTick)
        {
            ImpactStaticClearTics++;
            if (ImpactStaticClearTics
                >= CaelumConstants.IMPACT_STATIC_REARM_CLEAR_TICS)
            {
                ImpactWasWallBlockedLastTick = false;
                ImpactStaticClearTics = 0;
            }
        }
        UpdateImpactContactLatch();

        UpdateCombatHealthEffects();
        UpdateActorOffensiveStatistics();
        if (health > 0 && CurrentCombatAnima < MaximumCombatAnima)
        {
            CurrentCombatAnima = Min(
                MaximumCombatAnima,
                CurrentCombatAnima
                    + CombatAnimaRegenerationPerSecond / TICRATE
            );
        }
        if (health > 0 && !CombatAirSpending
            && CurrentCombatAir < MaximumCombatAir)
        {
            CurrentCombatAir = Min(
                MaximumCombatAir,
                CurrentCombatAir + CombatAirRegenerationPerSecond / TICRATE
            );
        }
        if (health > 0
            && CurrentCombatLucidity < CaelumConstants.MAXIMUM_LUCIDITY)
        {
            CurrentCombatLucidity = Min(
                CaelumConstants.MAXIMUM_LUCIDITY,
                CurrentCombatLucidity
                    + CaelumConstants.MAXIMUM_LUCIDITY
                        / CaelumConstants.LUCIDITY_FULL_RECOVERY_SECONDS
                        / TICRATE
            );
            UpdateActorLucidityState();
        }
        if (CombatLucidityPhysicalStunRemaining > 0.0)
        {
            Vel.X = 0.0;
            Vel.Y = 0.0;
            CombatLucidityPhysicalStunRemaining = Max(
                0.0,
                CombatLucidityPhysicalStunRemaining - 1.0 / TICRATE
            );
        }
        if (CombatTimeRemaining > 0.0)
        {
            CombatTimeRemaining = Max(
                0.0,
                CombatTimeRemaining - 1.0 / TICRATE
            );
        }
        else if (CurrentCombatAdrenaline > 0.0)
        {
            CurrentCombatAdrenaline = Max(
                0.0,
                CurrentCombatAdrenaline
                    - CaelumConstants.ADRENALINE_DECAY_PER_SECOND / TICRATE
            );
        }
    }
}
