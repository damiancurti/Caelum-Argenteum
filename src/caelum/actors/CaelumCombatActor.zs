// Base de combate compartida por los actores originales de Caelum.
// Gestiona anatomia, armadura localizada, refuerzo, durabilidad, resistencias,
// evasion, dolor, adrenalina y efectos de los estados de salud.
class CaelumCombatActor : Actor
{
    int MaintenanceRevision;
    transient CaelumActorMaintenance Maintenance;
    transient CaelumPopulationState MaintenancePopulation;
    transient CaelumTargetSubscriptions TargetSubscribers;

    void ResetMaintenanceForTravel()
    {
        // Los plazos y suscriptores pertenecen al mapa, no al cuerpo trasladado.
        Maintenance=null;MaintenancePopulation=null;
        CaelumTargetSubscriptions.Invalidate(self);
        if(SiegeCombatant!=null)CaelumTargetSubscriptions.Unwatch(SiegeCombatant);
    }

    CaelumActorMaintenance GetActorMaintenance()
    {
        if(MaintenanceRevision<CaelumActorMaintenance.REVISION)
        {
            Maintenance=null;MaintenancePopulation=null;
            MaintenanceRevision=CaelumActorMaintenance.REVISION;
        }
        if(MaintenancePopulation==null)MaintenancePopulation=CaelumPopulationState.Get();
        if(MaintenancePopulation==null || !MaintenancePopulation.HighDensity)
        {
            if(Maintenance!=null)Maintenance.Invalidate();
            return null;
        }
        if(Maintenance==null)
        {
            Maintenance=new("CaelumActorMaintenance");
            Maintenance.Phase=MaintenancePopulation.NextMaintenancePhase;
            MaintenancePopulation.NextMaintenancePhase=(Maintenance.Phase+1)%CaelumConstants.ACTOR_MAINTENANCE_TICS;
        }
        return Maintenance;
    }

    override void AddInventory(Inventory item)
    { Super.AddInventory(item);CaelumActorMaintenance.InventoryChanged(self); }
    override void RemoveInventory(Inventory item)
    { Super.RemoveInventory(item);CaelumActorMaintenance.InventoryChanged(self); }
    override bool UseInventory(Inventory item)
    {
        bool used=Super.UseInventory(item);
        CaelumActorMaintenance.InventoryChanged(self);
        return used;
    }

    // La postura cambia colisión/anatomía, no la talla fisiológica del cuerpo.
    virtual double GetPhysiologicalHeight() { return Height; }
    bool ThermalBluntDelivery;
    // Nulo en campañas anteriores y fuera del encuentro optativo de #20.
    CaelumSiegeCombatant SiegeCombatant;
    bool NextRangedSecondaryElement;
    Actor CaelumRecognitionTarget;

    CaelumAnatomyProfile AnatomyProfile;
    CaelumArmorModel CombatArmor;
    CaelumElementalStatus ElementalStatus;
    CaelumThermalState ThermalState;
    CaelumDemonBreath DemonBreath;
    int CombatMaximumHealth;
    int MiracleRecoveryRevision;
    double MiracleHealthRemainder;

    void ApplyMiraclePulse(double ratio)
    {
        if(health<=0 || CombatMaximumHealth<=0 || ratio<=0)return;
        // La fracción se guarda separada de la curación por reposo.
        if(MiracleRecoveryRevision<CaelumMiracle.REVISION)
        {MiracleRecoveryRevision=CaelumMiracle.REVISION;MiracleHealthRemainder=0;}
        MiracleHealthRemainder+=Max(0,CombatMaximumHealth)*ratio;
        int healing=int(MiracleHealthRemainder+1e-8);
        MiracleHealthRemainder=Max(0.0,MiracleHealthRemainder-healing);
        health=Min(CombatMaximumHealth,health+healing);
        if(health>=CombatMaximumHealth)MiracleHealthRemainder=0;
        CurrentCombatLucidity=Min(CaelumConstants.MAXIMUM_LUCIDITY,
            CurrentCombatLucidity+CaelumConstants.MAXIMUM_LUCIDITY*ratio);
        CurrentCombatAnima=Min(MaximumCombatAnima,CurrentCombatAnima+MaximumCombatAnima*ratio);
        CurrentCombatAir=Min(MaximumCombatAir,CurrentCombatAir+MaximumCombatAir*ratio);
        UpdateCombatHealthEffects();UpdateActorLucidityState();
    }

    int CombatToughness;
    int CombatResilience;
    int CombatAgility;
    int CombatPatience;
    int CombatDexterity;
    int CombatInsight;
    int CombatEffectiveDexterity;
    int CombatEffectiveInsight;
    CaelumBolasFlight BolasBinding;
    CaelumUtilityStaffStream CombatUtilityStaffStream;
    CaelumEquipmentItem CombatActiveTool;
    CaelumCharacterProfile CombatPersonality;
    int CombatPersonalityRevision;
    virtual int GetApprovedPersonality(){return -1;}
    virtual int GetApprovedPersonalityRevision(){return CaelumResidentData.REVISION;}
    transient CaelumMixedMeleeDamage PendingMixedMelee;
    virtual CaelumMixedMeleeDamage PrepareMixedMelee(Actor victim,double baseDamage){return null;}

    void EnsureCombatPersonality()
    {
        if(CombatPersonalityRevision>=GetApprovedPersonalityRevision())return;
        int packed=GetApprovedPersonality();
        if(packed>=0)
        {
            if(CombatPersonality==null)CombatPersonality=new("CaelumCharacterProfile");
            CaelumPersonalityRules.Unpack(CombatPersonality,packed);
        }
        CombatPersonalityRevision=GetApprovedPersonalityRevision();
        UpdateActorOffensiveStatistics();UpdateCombatHealthEffects();
    }
    virtual CaelumWeaponModel GetPossessedSidearm(){return null;}
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
    int GrowthRevision;
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
    CaelumTelekinesisEffect TelekinesisBinding;
    int ForcedSleepTics;
    CaelumSpellSleepState SpellSleep;
    int SleepSavedTics;
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
    double LastCombatPostToughnessDamage;
    double LastCombatPainChancePercent;
    bool LastCombatPainTriggered;
    int LastAnatomyLocation;
    int LastAnatomyNaturalVulnerabilityGrade;
    int LastAnatomyVulnerabilityGrade;
    double LastAnatomyHeightRatio;
    double LastAnatomyLateralRatio;
    int LastCombatArmorSlot;
    int LastCombatArmorDefensePercent; // Campo legado conservado para saves anteriores.
    double LastCombatArmorDefenseExactPercent;
    int ArmorBalanceRevision;
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
        EnsureCombatPersonality();
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
        // La pared de aislamiento de TACTORS empieza en X=8192. Esta condición
        // excluye los nueve recintos y no afecta ningún mapa de juego normal.
        return level.MapName == "TACTORS"
            && Pos.X >= 8192.0
            && Pos.X <= 24576.0
            && Pos.Y >= -8192.0
            && Pos.Y <= 8192.0;
    }

    bool BeginCaelumDiagnosticAttack()
    {
        if(CaelumBattleCry.Active(self))return false;
        if (level.MapName != "TACTORS") { return true; }
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
        if (combatActor.PulseResourceRecovery()) return;
        if (CaelumPortSiege.Pulse(combatActor)) return;

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
        if (combatActor.PulseResourceRecovery()) return;
        if (CaelumPortSiege.Pulse(combatActor)) return;

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
        if(CaelumRedemption.Follow(combatActor))return;
        let summoned=CaelumSummonedZupay(combatActor);
        if(summoned!=null && summoned.FollowCaster())return;
        let resident=CaelumAnchoredResident(combatActor);
        if(resident!=null && resident.IsRuloPartyFighting())
        {
            if(resident is "CaelumRulo" || resident is "CaelumRonnie")combatActor.ThermalChase(null,null);
            else combatActor.ThermalChase(null,"Missile");
        }
        else combatActor.ThermalChase();
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
        CaelumThermalMotion.SetVelocity(self);
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
        GrowthRevision=CaelumGrowthRules.REVISION;
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

    void EnsureGrowthBalance()
    {
        if(!CombatProfileInitialized || GrowthRevision>=CaelumGrowthRules.REVISION)return;
        double healthRatio=CombatMaximumHealth>0 ? double(health)/CombatMaximumHealth : 0;
        double animaRatio=MaximumCombatAnima>0 ? CurrentCombatAnima/MaximumCombatAnima : 0;
        double airRatio=MaximumCombatAir>0 ? CurrentCombatAir/MaximumCombatAir : 0;
        double adrenalineRatio=MaximumCombatAdrenaline>0 ? CurrentCombatAdrenaline/MaximumCombatAdrenaline : 0;
        CombatMaximumHealth=Max(1,int(CaelumConstants.HEALTH_ANIMA_DAMAGE_SCALE
            *CalculateActorType1Percent(CombatConstitution)*Max(0.01,Mass/100.0)));
        if(health>0)health=Max(1,int(CombatMaximumHealth*Clamp(healthRatio,0.0,1.0)+0.5));
        if(self is 'CaelumFolkloreCombatActor')
            CombatBaseSpeed=CaelumConstants.GZDOOM_BASE_MAX_WALK_SPEED*CaelumGrowthRules.Multiplier(CombatAgility,2);
        let bull=CaelumBull(self);
        if(bull!=null)bull.BullRunningSpeed=bull.GetBullRunningSpeed();
        RecalculateCombatStatistics();
        CurrentCombatAnima=Clamp(animaRatio,0.0,1.0)*MaximumCombatAnima;
        CurrentCombatAir=Clamp(airRatio,0.0,1.0)*MaximumCombatAir;
        CurrentCombatAdrenaline=Clamp(adrenalineRatio,0.0,1.0)*MaximumCombatAdrenaline;
        GrowthRevision=CaelumGrowthRules.REVISION;
        UpdateCombatHealthEffects();
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
            * CaelumGrowthRules.Multiplier(CombatResilience,2);
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
        // Adaptador histórico: Tipo 1 antiguo -> Tipo 3 nuevo.
        return CaelumGrowthRules.Percent(level,3);
    }

    double CalculateActorType2Percent(int level)
    {
        return CaelumGrowthRules.Bonus(level);
    }

    double CalculateActorType4Percent(int level)
    {
        return CaelumGrowthRules.Percent(level,2);
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

    bool AttackResourceWaiting;
    // Revisión 1: retirada por agotamiento y descanso hasta completar reservas.
    int RecoveryRevision, RecoveryPhase;
    Actor RecoveryThreat, RecoveryGoal;
    double IdleHealthAccumulator;
    bool AttackResourceMagical;
    double AttackResourceBaseCost;
    int AttackResourceWeapon;
    State AttackResourceResume;
    double WeaponCycleTics;
    int WeaponCyclePreparationTics;
    int WeaponCycleStartTic, WeaponCycleWindFrame;

    void EnsureRecoveryRevision()
    {
        if(RecoveryRevision>=1)return;
        RecoveryPhase=0;RecoveryThreat=null;RecoveryGoal=null;
        IdleHealthAccumulator=0;RecoveryRevision=1;
        // Una espera antigua conserva su coste y se evalúa sin regalar recursos.
    }

    bool WithinAttackRange(bool magical, double spawnHeight=-1)
    {
        if(CaelumBattleCry.Active(self))return false;
        if((CaelumBolas.Restrained(self) || CaelumTelekinesisRules.Held(self)) || target==null || target.health<=0 || !target.bShootable || RecoveryPhase!=0)return false;
        if(!magical)return CheckMeleeRange();
        vector3 origin=Pos+(0,0,spawnHeight>=0 ? spawnHeight : Height*0.65);
        vector3 aim=target.Pos+(0,0,target.Height/2);
        return (aim-origin).Length()<=GetCombatAbilityRange() && CheckSight(target);
    }

    double RecoveryThreatRange()
    {
        let opponent=CaelumCombatActor(RecoveryThreat);
        if(opponent!=null)
            return opponent.MissileState!=null ? Max(opponent.MeleeRange,
                opponent is "CaelumBull" ? opponent.MaxTargetRange : opponent.GetCombatAbilityRange()) : opponent.MeleeRange;
        let user=CaelumPlayer(RecoveryThreat);
        if(user!=null && user.WeaponModel!=null && user.WeaponModel.Equipped)
        {
            let weapon=user.WeaponModel;
            if(weapon.IsMagicalType(weapon.WeaponType))
                return CaelumConstants.ESSENCE_BASE_RANGE_MAP_UNITS*(user.DerivedStats==null ? 1 : user.DerivedStats.AbilityRangePercent/100.0);
            int id=CaelumCraftingRules.GetCatalogueWeaponForPlayableType(weapon.WeaponType);
            if(weapon.IsRangedPhysicalType(weapon.WeaponType))
                return weapon.GetRangedRangeFor(weapon.WeaponType);
            return Max(CaelumWeaponCatalogue.GetPrimaryRange(id),CaelumWeaponCatalogue.GetSecondaryRange(id));
        }
        return RecoveryThreat==null ? 0 : RecoveryThreat.MeleeRange;
    }

    void EndResourceRecovery()
    {
        if(target==RecoveryGoal)target=RecoveryThreat;
        RecoveryPhase=0;RecoveryThreat=null;AttackResourceWaiting=false;
    }

    bool ResourceRecoveryActive()
    {
        EnsureRecoveryRevision();
        if(RecoveryPhase==0)return false;
        State pain=FindState("Pain");
        if(health<=0 || (pain!=null && InStateSequence(CurState,pain)))
        {EndResourceRecovery();return false;}
        let boss=CaelumZupayColossus(self);
        if(!CaelumRedemption.PreviouslyRaised(self)
            && ((SiegeCombatant!=null && SiegeCombatant.Withdrawing) || (boss!=null && boss.SewerFleeing)))
        {EndResourceRecovery();return false;}
        return true;
    }

    bool PulseResourceRecovery()
    {
        if(!ResourceRecoveryActive())return false;
        if(ForcedSleepTics>0 || CombatLucidityPhysicalStunRemaining>0 || CaelumTelekinesisRules.Held(self))return true;
        if(CurrentCombatAir>=MaximumCombatAir && CurrentCombatAnima>=MaximumCombatAnima)
        {
            EndResourceRecovery();SetStateLabel("AttackOutOfRange");return true;
        }
        if(RecoveryPhase==1)
        {
            double reach=RecoveryThreatRange()+Radius;
            // La envolvente horizontal también cubre el alcance melee nativo:
            // una diferencia de altura no debe acortar la retirada por sí sola.
            if(RecoveryThreat==null || RecoveryThreat.health<=0 || Distance2D(RecoveryThreat)>reach)
            {
                RecoveryPhase=2;target=null;LastEnemy=null;Vel.X=0;Vel.Y=0;
                SetState(SpawnState);return true;
            }
            vector2 away=Pos.XY-RecoveryThreat.Pos.XY;
            if(away.Length()==0)away=(Cos(Angle),Sin(Angle));
            vector3 destination=(RecoveryThreat.Pos.XY+away.Unit()*(reach+Speed),Pos.Z);
            if(RecoveryGoal==null)RecoveryGoal=Spawn("CaelumSewerEscapeTarget",destination,NO_REPLACE);
            else RecoveryGoal.SetOrigin(destination,false);
            target=RecoveryGoal;LastEnemy=null;Vel.X=0;Vel.Y=0;
            ThermalChase(null,null,CHF_DONTLOOKALLAROUND);
        }
        else {target=null;LastEnemy=null;Vel.X=0;Vel.Y=0;}
        return true;
    }

    bool IsCombatIdle()
    {
        if(health<=0 || CombatAirSpending || RecoveryPhase==1 || ForcedSleepTics>0 || CaelumTelekinesisRules.Held(self))return false;
        State pain=FindState("Pain");
        if(pain!=null && InStateSequence(CurState,pain))return false;
        if(MeleeState!=null && InStateSequence(CurState,MeleeState))return false;
        if(MissileState!=null && InStateSequence(CurState,MissileState))return false;
        return RecoveryPhase==2 || (target==null && Vel.XY.Length()<=0.01 && Abs(Vel.Z)<=0.01);
    }

    virtual double GetAttackCarriedWeight()
    {
        let cache=GetActorMaintenance();
        if(cache==null)return CalculateAttackCarriedWeight();
        if(cache.WeightChanged(self))
        {
            cache.Weight=CalculateAttackCarriedWeight();cache.InventoryHead=Inv;
            cache.WeightReady=true;cache.WeightDue=cache.NextDue();
        }
        return cache.Weight;
    }

    double CalculateAttackCarriedWeight()
    {
        double weight = CombatArmor == null ? 0 : CombatArmor.GetTotalWeight();
        for (Inventory cursor=Inv; cursor!=null; cursor=cursor.Inv)
        {
            let item=CaelumEquipmentItem(cursor);
            if (item!=null && !item.InMagicBox) weight+=item.UnitWeight*item.Amount;
            let consumable=CaelumConsumableItem(cursor);
            if(consumable!=null)weight+=consumable.GetCarriedWeight();
        }
        return weight;
    }

    double GetEffectiveAttackAir(double baseCost)
    {
        double capacity=Mass*CalculateActorType4Percent(CombatStrength)/100.0;
        double load=capacity>0 ? GetAttackCarriedWeight()/capacity : 0;
        return baseCost*(Mass/100.0)*CaelumDerivedStats.CalculateLoadAirMultiplier(load);
    }

    double GetProfileWeaponDuration(int weaponType)
    {
        let model=new("CaelumWeaponModel");
        double gloves=CombatArmor==null ? 0 : CombatArmor.GetWeight(CaelumConstants.ARMOR_SLOT_HANDS);
        int attribute=model.IsMagicalType(weaponType) ? CombatEloquence : CombatDexterity;
        if(model.IsMagicalType(weaponType)) attribute+=GetCombatArmorAttributeBonus(CaelumConstants.ATTRIBUTE_ELOQUENCE);
        else attribute+=GetCombatArmorAttributeBonus(CaelumConstants.ATTRIBUTE_DEXTERITY);
        double capacity=Mass*CalculateActorType4Percent(CombatStrength)/100.0;
        return CaelumAttackRules.Duration(100.0/CalculateActorType4Percent(attribute),
            model.GetWeightFor(weaponType,1,CaelumConstants.EQUIPMENT_SIZE_M),gloves,capacity)
            / CaelumThermalEffects.Speed(self);
    }

    bool HasAttackResource()
    {
        if(AttackResourceWeapon>=0 && GetProfileWeaponDuration(AttackResourceWeapon)<=0)return false;
        return AttackResourceMagical ? CurrentCombatAnima>=GetTierOneMagicAnimaCost(AttackResourceWeapon)
            : CurrentCombatAir>=GetEffectiveAttackAir(AttackResourceBaseCost)*CaelumThermalEffects.HeatCost(self);
    }

    void WaitForAttackResource()
    {
        EnsureRecoveryRevision();
        AttackResourceWaiting=true;
        let bull=CaelumBull(self);
        if(bull!=null)bull.StopBullCharge();
        CombatAirSpending=false;
        Vel.X=0; Vel.Y=0;
        if(AttackResourceWeapon>=0 && GetProfileWeaponDuration(AttackResourceWeapon)<=0)
        {SetStateLabel("AttackResourceWait");return;}
        if(RecoveryPhase==0)
        {
            RecoveryThreat=target!=RecoveryGoal ? target : RecoveryThreat;
            RecoveryPhase=1;
        }
        SetStateLabel("ResourceRetreat");
    }

    action void A_CaelumWaitAttackResource()
    {
        let actor=CaelumCombatActor(self);
        if(actor==null || actor.health<=0 || CaelumTelekinesisRules.Held(actor))return;
        if(actor.PulseResourceRecovery())return;
        actor.Vel.X=0;actor.Vel.Y=0;
        if(actor.ForcedSleepTics>0)return;
        if(!actor.HasAttackResource()){actor.WaitForAttackResource();return;}
        actor.AttackResourceWaiting=false;
        if(actor.Target==null || actor.Target.health<=0)actor.SetState(actor.SeeState);
        else actor.SetState(actor.AttackResourceResume);
    }

    action void A_CaelumBeginResourceAttack(double baseAir, int weaponType=-1,
        bool magical=false, double preparationFraction=0, bool slam=false)
    {
        let actor=CaelumCombatActor(self);
        if(actor==null)return;
        if(!actor.WithinAttackRange(magical))
        {actor.SetStateLabel("AttackOutOfRange");return;}
        actor.AttackResourceBaseCost=baseAir;
        actor.AttackResourceWeapon=weaponType;
        actor.AttackResourceMagical=magical;
        actor.AttackResourceResume=magical?actor.MissileState:actor.MeleeState;
        if(!actor.HasAttackResource()){actor.WaitForAttackResource();return;}
        actor.AttackResourceWaiting=false;
        if(slam)actor.tics=int(Ceil(CaelumAttackRules.SLAM_PREPARATION_TICS/CaelumThermalEffects.Speed(actor)));
        else if(weaponType>=0)
        {
            actor.WeaponCycleTics=actor.GetProfileWeaponDuration(weaponType);
            if(actor.WeaponCycleTics<=0){actor.WaitForAttackResource();return;}
            actor.WeaponCyclePreparationTics=int(Ceil(actor.WeaponCycleTics*preparationFraction));
            actor.WeaponCycleStartTic=level.time;
            actor.WeaponCycleWindFrame=1;
            actor.tics=actor.WeaponCyclePreparationTics;
        }
        else actor.tics=int(Ceil(actor.tics/CaelumThermalEffects.Speed(actor)));
        actor.A_FaceTarget();
    }

    action void A_CaelumThermalAttackFrame()
    {tics=int(Ceil(tics/CaelumThermalEffects.Speed(self)));}

    action void A_CaelumMagicWindFrame()
    {
        let actor=CaelumCombatActor(self);
        if(actor!=null)
        {
            actor.WeaponCycleWindFrame++;
            actor.SetWeaponPhaseBoundary(actor.WeaponCycleWindFrame*3.0/20.0);
        }
    }

    action void A_CaelumMagicLastFrame()
    {
        let actor=CaelumCombatActor(self);
        if(actor!=null)actor.SetWeaponPhaseBoundary(1.0);
    }

    action void A_CaelumWeaponRecovery()
    {
        let actor=CaelumCombatActor(self);
        if(actor!=null)actor.SetWeaponPhaseBoundary(1.0);
    }

    void SetWeaponPhaseBoundary(double fraction)
    {
        tics=WeaponCycleStartTic+int(Ceil(WeaponCycleTics*fraction))-level.time;
        // Redondear los límites acumulados evita añadir un tic por cada pose.
        if(tics<=0)SetState(CurState.NextState);
    }

    bool SpendPhysicalAttackAir(double baseAir,double workJoules=CaelumThermalData.NATURAL_ATTACK_WORK_JOULES)
    {
        AttackResourceBaseCost=baseAir;AttackResourceMagical=false;AttackResourceWeapon=-1;
        // Una cornada ya preparada no repite la carrera después de esperar.
        AttackResourceResume=self is "CaelumBull" ? CurState : MeleeState;
        if(!TrySpendCombatAir(GetEffectiveAttackAir(baseAir)))
        {WaitForAttackResource();return false;}
        CaelumThermalService.Impulse(self,CaelumThermalRules.PositiveWorkHeat(workJoules,CaelumThermalBody.Efficiency(self)),true);
        return true;
    }

    bool TrySpendCombatAir(double requestedAmount)
    {
        double amount = Max(0.0, requestedAmount)*CaelumThermalEffects.HeatCost(self);
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
    {return GetMagicAnimaCost(GetTierOneMagicBaseAnimaCost(weaponType));}

    double GetMagicAnimaCost(double baseCost)
    {
        int effectiveEloquence = CombatEloquence
            + GetCombatArmorAttributeBonus(
                CaelumConstants.ATTRIBUTE_ELOQUENCE
            );
        return Max(0.0,baseCost) * 100.0
            / CalculateActorType4Percent(Max(0, effectiveEloquence));
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

    bool SpendBasicMagic(int weaponType=CaelumConstants.WEAPON_TYPE_STAFF)
    {
        if(TrySpendTierOneMagicAnima(weaponType))return true;
        AttackResourceMagical=true;AttackResourceWeapon=weaponType;
        AttackResourceResume=MissileState;WaitForAttackResource();return false;
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
        let cache=GetActorMaintenance();
        if(cache!=null && !cache.OffenseChanged(self))
        {
            // Restaurar también asignaciones alteradas por consumidores, como la recarga.
            cache.RestoreOffense(self);return;
        }
        CalculateActorOffensiveStatistics();
        if(cache!=null)cache.StoreOffense(self);
    }

    void CalculateActorOffensiveStatistics()
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
            (CaelumConstants.BASE_CRITICAL_CHANCE_PERCENT
                + CalculateActorType2Percent(CombatEffectiveDexterity))*CaelumPersonalityRules.Critical(self),
            0.0,
            100.0
        );
        CombatMagicalCriticalChancePercent = Clamp(
            (CaelumConstants.BASE_CRITICAL_CHANCE_PERCENT
                + CalculateActorType2Percent(CombatEffectiveInsight))*CaelumPersonalityRules.Critical(self),
            0.0,
            100.0
        );
        CombatPhysicalPushMultiplier = Max(0.0, Mass / 100.0)
            * CalculateActorType1Percent(CombatStrength) / 100.0;
        CombatMagicalPushMultiplier = CalculateActorType1Percent(
            CombatEffectiveIntelligence
        ) / 100.0 * CaelumPersonalityRules.MagicPower(CombatPersonality);
    }

    // Entrada ofensiva comun: salud modifica dano, lucidez modifica precision
    // y el atributo propio del ataque determina su probabilidad critica.
    int PrepareActorOutgoingDamage(double baseDamage, bool magicalAttack, bool weaponAttack=false)
    {
        EnsureCombatPersonality();
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
                * (weaponAttack ? 1.0 : CombatLucidityAccuracyMultiplier)
                * (ElementalStatus != null
                    ? ElementalStatus.GetAccuracyMultiplier() : 1.0),
            0.0,
            100.0
        );
        if ((CaelumBolas.Restrained(self) || CaelumTelekinesisRules.Held(self)) || CombatLucidityPhysicalStunRemaining > 0.0 || ForcedSleepTics > 0)
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
        LastCombatAttackCalculatedDamage = CalculateActorOutgoingDamage(resolvedBaseDamage,magicalAttack);
        return LastCombatAttackCalculatedDamage;
    }

    // Escalado compartido sin otra tirada para componentes del mismo impacto.
    int CalculateActorOutgoingDamage(double baseDamage,bool magicalAttack)
    {
        return Max(1,int(Max(0.0,baseDamage)
            *(magicalAttack ? CaelumPersonalityRules.MagicPower(CombatPersonality) : CombatPhysicalPowerMultiplier)
            *CombatHealthPerformanceMultiplier+0.5));
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

    action void A_CaelumMeleeAttack(int baseDamage,Sound hitSound="weapons/swordhit")
    {
        // Las acciones sin alcance explicito son invocables desde estados de
        // monstruo. El casteo recupera el tipo concreto para llamar su logica.
        CaelumCombatActor combatActor = CaelumCombatActor(self);
        if (combatActor == null) { return; }
        if (!combatActor.BeginCaelumDiagnosticAttack()) { return; }
        if (!combatActor.WithinAttackRange(false)) return;
        if (!combatActor.SpendPhysicalAttackAir(CaelumAttackRules.NaturalAir())) return;
        if (combatActor.IsCaelumMassDiagnosticAlly(combatActor.Target))
        {
            combatActor.ImpactDiagnosticFriendlyFirePrevented++;
            combatActor.PendingCombatCriticalDelivery = false;
            return;
        }
        let sidearm=combatActor.GetPossessedSidearm();
        int calculatedDamage = combatActor.PrepareActorOutgoingDamage(
            baseDamage,
            false, sidearm!=null
        );
        if (calculatedDamage <= 0) { return; }
        if (sidearm!=null && !combatActor.WeaponMeleeAimHits(sidearm))
        { combatActor.PendingCombatCriticalDelivery=false; return; }
        Actor meleeVictim = combatActor.Target;
        int victimHealthBefore = meleeVictim != null ? meleeVictim.health : 0;
        combatActor.A_CustomMeleeAttack(
            calculatedDamage,
            hitSound
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
        if (!combatActor.WithinAttackRange(false)) return;
        double cost=combatActor is "CaelumBull" ? CaelumAttackRules.NaturalAir() : CaelumWeaponCatalogue.GetPrimaryAirCost(CaelumConstants.CATALOGUE_WEAPON_MACHETE);
        double work=combatActor is "CaelumBull" ? CaelumThermalData.NATURAL_ATTACK_WORK_JOULES
            : CaelumThermalData.WeaponWork(CaelumConstants.WEAPON_TYPE_MACHETE);
        if (!combatActor.SpendPhysicalAttackAir(cost,work)) return;
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
            false, !(combatActor is "CaelumBull")
        );
        if (calculatedDamage <= 0) { return; }
        if (!(combatActor is "CaelumBull") && !combatActor.WeaponMeleeAimHits(combatActor.GetPossessedSidearm()))
        { combatActor.PendingCombatCriticalDelivery=false; return; }

        Actor meleeVictim = combatActor.Target;
        int victimHealthBefore = meleeVictim != null ? meleeVictim.health : 0;
        combatActor.PendingMixedMelee=combatActor.PrepareMixedMelee(meleeVictim,authoredBaseDamage);
        combatActor.A_CustomMeleeAttack(
            calculatedDamage,
            "weapons/swordhit"
        );
        combatActor.PendingMixedMelee=null;
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
            let summoned=CaelumSummonedZupay(self);
            if(summoned!=null && !summoned.CanAffect(candidate))continue;
            if(!CaelumRedemption.AllowsDamage(self,candidate))continue;
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
        if (!combatActor.WithinAttackRange(false)) return;
        if (!combatActor.SpendPhysicalAttackAir(CaelumAttackRules.SlamAir(),CaelumThermalData.GROUND_SLAM_WORK_JOULES)) return;

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
        combatActor.ThermalBluntDelivery=true;
        combatActor.BeginCombatAreaExplosion(radius);
        combatActor.LaunchActorsInGroundRadius(radius, verticalSpeed);
        combatActor.A_Explode(
            calculatedDamage,
            radius,
            XF_NOTMISSILE | XF_THRUSTLESS | XF_NOALLIES | XF_CIRCULAR,
            false
        );
        combatActor.EndCombatAreaExplosion();
        combatActor.ThermalBluntDelivery=false;
        combatActor.PendingCombatCriticalDelivery = false;
    }

    // #259: sólo armas con identidad/tier conocidos. Las garras, cuernos y
    // golpes naturales conservan su regla anterior, sin inventarles una ficha.
    double WeaponAimOffset(double minimum, double maximum)
    {
        int roll=Random[CaelumActorWeaponSpread](-100000,100000);
        return (roll<0 ? -1.0 : 1.0)*(minimum+(maximum-minimum)*Abs(roll)/100000.0);
    }

    virtual bool UsesWeaponProjectileDispersion() { return true; }

    void ApplyWeaponProjectileDispersion(CaelumActorProjectile missile,int weaponType)
    {
        if(missile==null || !UsesWeaponProjectileDispersion())return;
        double accuracy=Max(1.0,CombatMagicalAccuracyPercent
            *(ElementalStatus!=null ? ElementalStatus.GetAccuracyMultiplier() : 1.0));
        double minimum=CaelumDispersionRules.EffectiveTier(
            CaelumDispersionRules.MagicBase(weaponType),1,CurrentCombatLucidity)*100.0/accuracy;
        double speed=missile.Vel.Length();
        double yaw=missile.Angle+WeaponAimOffset(minimum,minimum*10.0);
        double pitch=VectorAngle(missile.Vel.XY.Length(),-missile.Vel.Z)
            +WeaponAimOffset(minimum,minimum*10.0);
        missile.Angle=yaw;missile.Pitch=pitch;
        missile.Vel=(Cos(yaw)*Cos(pitch)*speed,Sin(yaw)*Cos(pitch)*speed,-Sin(pitch)*speed);
    }

    bool WeaponMeleeAimHits(CaelumWeaponModel weapon)
    {
        if(Target==null || weapon==null)return false;
        double accuracy=Max(1.0,CombatPhysicalAccuracyPercent
            *(ElementalStatus!=null ? ElementalStatus.GetAccuracyMultiplier() : 1.0));
        double minimum=CaelumWeaponCatalogue.GetMinimumSpread(
            CaelumCraftingRules.GetCatalogueWeaponForPlayableType(weapon.WeaponType),weapon.Tier,CurrentCombatLucidity)*100.0/accuracy;
        vector3 origin=Pos+(0,0,Height/2);
        vector3 aim=Target.Pos+(0,0,Target.Height/2)-origin;
        double yaw=AngleTo(Target)+WeaponAimOffset(minimum,minimum*10.0);
        double pitch=VectorAngle(aim.XY.Length(),-aim.Z)+WeaponAimOffset(minimum,minimum*10.0);
        FLineTraceData hit;
        return LineTrace(yaw,MeleeRange+Target.Radius,pitch,TRF_ABSPOSITION,
            origin.Z,origin.X,origin.Y,hit) && hit.HitActor==Target;
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
        if (!combatActor.WithinAttackRange(true,spawnHeight)) return;
        if (magicalAttack)
        {
            if (!combatActor.SpendBasicMagic()) return;
        }
        else if (!combatActor.SpendPhysicalAttackAir(CaelumAttackRules.NaturalAir())) return;
        int calculatedDamage = combatActor.PrepareActorOutgoingDamage(
            baseDamage,
            magicalAttack, magicalAttack
        );
        if (calculatedDamage <= 0) { return; }

        CaelumActorProjectile missile = CaelumActorProjectile(
            combatActor.A_SpawnProjectile(missileType, spawnHeight)
        );
        if (missile != null)
        {
            if (magicalAttack) combatActor.ApplyWeaponProjectileDispersion(missile,CaelumConstants.WEAPON_TYPE_STAFF);
            missile.ConfigureCaelumTravelDistance(combatActor.GetCombatAbilityRange());
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
        // #195: Luz sigue permitida; sólo se evita la carga real de Fuego.
        let resident=CaelumAnchoredResident(combatActor);
        if(resident!=null && resident.IsRuloPartyFighting() && essenceType==CaelumConstants.ESSENCE_FIRE)
            combatActor.NextRangedSecondaryElement=true;
        if (!combatActor.BeginCaelumDiagnosticAttack()) { return; }
        if (!combatActor.WithinAttackRange(true,spawnHeight) || !combatActor.SpendBasicMagic()) return;
        int calculatedDamage = combatActor.PrepareActorOutgoingDamage(
            baseDamage,
            true, true
        );
        if (calculatedDamage <= 0) { return; }

        CaelumActorProjectile missile = CaelumActorProjectile(
            combatActor.A_SpawnProjectile(missileType, spawnHeight)
        );
        if (missile != null)
        {
            combatActor.ApplyWeaponProjectileDispersion(missile,CaelumConstants.WEAPON_TYPE_STAFF);
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
        if (!combatActor.WithinAttackRange(true,spawnHeight) || !combatActor.SpendBasicMagic(CaelumConstants.WEAPON_TYPE_STATUETTE)) return;
        int calculatedDamage = combatActor.PrepareActorOutgoingDamage(baseDamage, true, true);
        if (calculatedDamage <= 0) { return; }

        CaelumActorProjectile missile = CaelumActorProjectile(
            combatActor.A_SpawnProjectile(missileType, spawnHeight)
        );
        if (missile != null)
        {
            combatActor.ApplyWeaponProjectileDispersion(missile,CaelumConstants.WEAPON_TYPE_STATUETTE);
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
        if (!combatActor.WithinAttackRange(true,combatActor.Height*Max(0.0,spawnHeightRatio))) return;
        if (combatActor.IsCaelumMassDiagnosticAlly(combatActor.Target))
        {
            combatActor.ImpactDiagnosticFriendlyFirePrevented++;
            return;
        }

        // El coste se paga al resolver el ataque aunque la tirada ofensiva
        // falle, como ocurre con el lanzamiento ya iniciado del jugador.
        if (!combatActor.TrySpendTierOneMagicAnima(weaponType))
        {
            combatActor.AttackResourceMagical=true;
            combatActor.AttackResourceWeapon=weaponType;
            combatActor.AttackResourceResume=combatActor.MissileState;
            combatActor.WaitForAttackResource();return;
        }
        int calculatedDamage = combatActor.PrepareActorOutgoingDamage(
            combatActor.GetTierOneMagicDamage(weaponType),
            true, true
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
            combatActor.ApplyWeaponProjectileDispersion(missile,weaponType);
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
        double result = Max(1.0, double(Mass))+Max(0.0,GetAttackCarriedWeight());
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



    virtual int GetArmorRace() { return CaelumConstants.RACE_HUMAN; }

    virtual double GetInnateArmorDefense(bool magical = false)
    {
        return CaelumArmorRules.InnateDefense(GetArmorRace(), magical);
    }

    double GetArmorDefensePercent(int slot, bool magical = false,Actor inflictor=null,Actor source=null)
    {
        return CaelumArmorRules.TotalDefense(GetInnateArmorDefense(magical), CombatArmor, slot, magical,inflictor,self,source);
    }

    double GetImpactArmorDefensePercent()
    {

        double totalDefense = 0.0;
        for (int slot = 0; slot < CaelumConstants.ARMOR_SLOT_COUNT; slot++)
        {
            totalDefense += Clamp(
                GetArmorDefensePercent(slot),
                0.0,
                100.0
            );
        }
        return totalDefense / CaelumConstants.ARMOR_SLOT_COUNT;
    }

    double GetBiologicalJumpAbsorptionSpeed()
    {
        // Escala geométrica de la velocidad segura: la velocidad característica
        // de un cuerpo bajo la misma gravedad crece como sqrt(longitud).
        if (CombatLucidityPhysicalStunRemaining > 0.0)
        {
            return 0.0;
        }

        return CaelumPhysicsUnits.JumpVelocity(Mass,Mass+GetAttackCarriedWeight(),CombatAgility);
    }

    double GetBiologicalLandingAbsorptionSpeed()
    {
        return GetBiologicalJumpAbsorptionSpeed()
            * CaelumConstants.BIOLOGICAL_IMPACT_ABSORPTION_MULTIPLIER;
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

    virtual double GetHorizontalImpactAbsorptionSpeed(){return 0;}
    virtual double GetHazardPressureAbsorptionSpeed(double delta){return 0;}

    double ImpactAbsorptionSpeed(double delta,int kind,Vector3 normal=(0,0,0))
    {
        if(kind==CaelumConstants.IMPACT_KIND_CRUSH)
            return Min(Max(0.0,delta),GetBiologicalJumpAbsorptionSpeed());
        if(kind==CaelumConstants.IMPACT_KIND_FLOOR)
            return Min(Max(0.0,delta),GetBiologicalLandingAbsorptionSpeed());
        return Abs(normal.Z)<0.5 ? Min(Max(0.0,delta),GetHorizontalImpactAbsorptionSpeed()) : 0;
    }

    double RetainImpactEnergy(double joules,double delta,int kind,Vector3 normal=(0,0,0))
    {
        double retained=delta>0 ? Max(0.0,delta-ImpactAbsorptionSpeed(delta,kind,normal))/delta : 1;
        return joules*retained*retained;
    }

    double CalculateImpactEquivalentTics(double deltaSpeed)
    {
        return ImpactPhysics.EquivalentTics(
            GetImpactReferenceHeight(),
            deltaSpeed
        );
    }

    transient CaelumImpactArea CurrentImpactArea;
    double LastImpactReceivedJoules;
    double LastImpactCushionedJoules;

    CaelumImpactArea PrepareImpactArea(Actor sourceActor, double minimumHeight,
        double maximumHeight, Vector3 normal=(0,0,0))
    {
        if (AnatomyProfile==null)
        {
            AnatomyProfile=new("CaelumAnatomyProfile");
            AnatomyProfile.InitializeHumanoid();
        }
        let area=new("CaelumImpactArea");
        area.Build(self,sourceActor,AnatomyProfile,minimumHeight,maximumHeight,normal);
        return area;
    }

    double GetImpactRegionOverlap(int regionIndex, double minimumHeightRatio, double maximumHeightRatio)
    {
        return CurrentImpactArea!=null && regionIndex>=0 && regionIndex<16
            ? CurrentImpactArea.RegionArea[regionIndex] : 0;
    }

    double GetImpactRegionTotalOverlap(double minimumHeightRatio, double maximumHeightRatio)
    { return CurrentImpactArea!=null ? CurrentImpactArea.TotalArea : 0; }

    void ApplyWeightedImpactLucidity(
        double minimumHeightRatio,
        double maximumHeightRatio,
        double totalOverlap,
        Actor inflictor=null
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
            double defenseRatio = Clamp(GetArmorDefensePercent(slot,false,inflictor) / 100.0, 0.0, 1.0);
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
        double contactMaximumHeightRatio,
        bool stationarySceneryContact = false,
        double receivedJoules = -1,
        CaelumImpactArea preparedArea = null,
        Vector3 contactNormal = (0,0,0),
        double cushionedJoules = -1
    )
    {
        // Procedencia explícita: una roca del mecanismo es daño ambiental.
        bool hazardPressure = impactKind == CaelumConstants.IMPACT_KIND_CRUSH
            && CaelumHazardRock(sourceActor) != null;
        if (CaelumHazardRock(sourceActor) != null && impactKind != CaelumConstants.IMPACT_KIND_FLOOR)
            impactKind = CaelumConstants.IMPACT_KIND_ENVIRONMENT;
        LastImpactKind = impactKind;
        LastImpactRawDeltaSpeed = Max(0.0, deltaSpeed);
        LastImpactBiologicalAbsorptionSpeed=hazardPressure
            ? (Abs(contactNormal.Z)<0.5 ? GetHazardPressureAbsorptionSpeed(LastImpactRawDeltaSpeed) : 0)
            : ImpactAbsorptionSpeed(LastImpactRawDeltaSpeed,impactKind,contactNormal);
        LastImpactDeltaSpeed=Max(0.0,LastImpactRawDeltaSpeed-LastImpactBiologicalAbsorptionSpeed);
        LastImpactEquivalentTics = CalculateImpactEquivalentTics(LastImpactDeltaSpeed);
        LastImpactReceivedJoules = receivedJoules>=0 ? receivedJoules
            : CaelumImpactEnergy.Received(selfEffectiveMass,otherEffectiveMass,closingSpeed);
        double retainedSpeed = LastImpactRawDeltaSpeed>0 ? LastImpactDeltaSpeed/LastImpactRawDeltaSpeed : 1;
        LastImpactCushionedJoules = cushionedJoules>=0 ? cushionedJoules
            : LastImpactReceivedJoules*retainedSpeed*retainedSpeed;
        // Porcentajes sólo de diagnóstico: nunca determinan el daño.
        LastImpactDamagePercent = 100.0*LastImpactCushionedJoules/GetImpactMaximumHealth();
        Actor defenseSource = CaelumImpactEnergy.DefenseInflictor(sourceActor);
        CurrentImpactArea = preparedArea!=null ? preparedArea
            : PrepareImpactArea(sourceActor,contactMinimumHeightRatio,contactMaximumHeightRatio,contactNormal);
        LastImpactEffectiveMass = selfEffectiveMass;
        LastImpactOtherEffectiveMass = otherEffectiveMass;
        LastImpactClosingSpeed = closingSpeed;
        LastImpactImpulse = impulse;
        LastImpactBaseDamage = 0;
        LastImpactFinalDamage = 0;
        LastImpactToughnessMultiplier = 1.0;
        double impactToughness=CaelumToughnessRules.Effective(self);
        LastImpactToughnessPercent = 100.0*CaelumToughnessRules.ActorReduction(self,impactToughness)/GetImpactMaximumHealth();
        LastImpactArmorDefensePercent = 0.0;
        LastImpactWeightedVulnerabilityMultiplier = CurrentImpactArea.TotalArea>0
            ? CurrentImpactArea.NeutralArea/CurrentImpactArea.TotalArea : 0.0;
        LastImpactWeightedArmorDefensePercent = 0.0;
        LastImpactHeadContactWeight = 0.0;
        LastImpactLucidityLoss = 0.0;
        LastImpactContactMinimumHeightRatio =
            Clamp(contactMinimumHeightRatio, 0.0, 1.0);
        LastImpactContactMaximumHeightRatio =
            Clamp(contactMaximumHeightRatio, 0.0, 1.0);

        if (LastImpactCushionedJoules <= 0.0 || health <= 0)
        {
            return;
        }

        double surfacedJoules=LastImpactCushionedJoules*Max(0.0,sourceSurfaceMultiplier);
        LastImpactPostToughnessPercent = 0.0;

        if (AnatomyProfile == null)
        {
            AnatomyProfile = CaelumAnatomyProfile(new("CaelumAnatomyProfile"));
            AnatomyProfile.InitializeHumanoid();
        }

        double totalOverlap = GetImpactRegionTotalOverlap(
            LastImpactContactMinimumHeightRatio,
            LastImpactContactMaximumHeightRatio
        );
        double innateDefense=Clamp(GetInnateArmorDefense()/100.0,0.0,1.0);
        double wearBySlot[4];
        double weightedFinalDamage = totalOverlap>0 ? surfacedJoules*CurrentImpactArea.NeutralArea/totalOverlap*(1-innateDefense) : 0.0;
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
                double defenseRatio = Clamp(GetArmorDefensePercent(slot,false,defenseSource) / 100.0, 0.0, 1.0);

                LastImpactWeightedVulnerabilityMultiplier +=
                    weight * vulnerabilityMultiplier;
                LastImpactWeightedArmorDefensePercent +=
                    weight * defenseRatio * 100.0;
                weightedFinalDamage +=
                    surfacedJoules
                    * weight
                    * vulnerabilityMultiplier
                    * (1.0 - defenseRatio);
                if(CombatArmor!=null && CombatArmor.Durability[slot]>0)
                {
                    wearBySlot[slot]+=surfacedJoules*weight*vulnerabilityMultiplier
                        *CaelumArmorRules.EquippedDefense(CombatArmor,slot,false,self,defenseSource)/100.0;
                }
            }
        }
        else
        {
            weightedFinalDamage = surfacedJoules*(1-innateDefense);
            LastImpactWeightedArmorDefensePercent=100*innateDefense;
            LastImpactWeightedVulnerabilityMultiplier = 1.0;
        }

        LastImpactArmorDefensePercent =
            LastImpactWeightedArmorDefensePercent;
        LastImpactBaseDamage = Max(
            0,
            int(
                surfacedJoules
                + 0.5
            )
        );
        double postArmor=weightedFinalDamage;
        double postToughness=CaelumToughnessRules.AfterActorDefenses(
            self,postArmor,impactToughness);
        LastImpactToughnessMultiplier=CaelumToughnessRules.RetainedFraction(postArmor,postToughness);
        LastImpactPostToughnessPercent=100.0*postToughness/GetImpactMaximumHealth();
        LastImpactFinalDamage=Max(0,int(postToughness+0.5));

        if (LastImpactPostToughnessPercent > 0.0)
        {
            ApplyWeightedImpactLucidity(
                LastImpactContactMinimumHeightRatio,
                LastImpactContactMaximumHeightRatio,
                totalOverlap,defenseSource
            );
        }
        // Desgaste posterior al cálculo completo y a la lucidez del mismo golpe.
        bool armorPieceBroken=false;
        for (int slot=0;slot<CaelumConstants.ARMOR_SLOT_COUNT;slot++)
        {
            int loss=CaelumToughnessRules.ImpactWear(CombatArmor,slot,wearBySlot[slot]);
            if (loss>0 && CombatArmor.Durability[slot]<=0) armorPieceBroken=true;
        }
        if (LastImpactFinalDamage <= 0) { return; }

        Actor impactSource = sourceActor;
        if (impactSource == null)
        {
            impactSource = self;
        }
        // El núcleo ya resolvió el impulso; el daño no añade empuje de Doom.
        int impactFlags = DMG_NO_ARMOR | DMG_THRUSTLESS;
        if (impactKind == CaelumConstants.IMPACT_KIND_ENVIRONMENT)
            impactFlags |= DMG_THRUSTLESS;
        DamageMobj(
            impactSource,
            impactSource,
            LastImpactFinalDamage,
            'CaelumImpact',
            impactFlags,
            0.0
        );
    }

    double GetOtherCollisionEffectiveMass(Actor other)
    {
        CaelumEnvironmentProp environment = CaelumEnvironmentProp(other);
        if (environment != null)
        {
            return environment.GetEnvironmentMassKg();
        }

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
        CaelumEnvironmentProp environment = CaelumEnvironmentProp(other);
        if (environment != null)
        {
            return Max(0.0, environment.GetEnvironmentImpactMultiplier());
        }

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
                Actor peer=contact.FirstActor==self ? contact.SecondActor : contact.FirstActor;
                if (peer!=null && contact.PendingWorkJoules>0)
                {
                    Vector3 normal=ImpactPhysics.NormalizeHorizontal(peer.Pos-Pos);
                    if (normal.LengthSquared()==0) normal=(1,0,0);
                    ApplySustainedCrush(peer,normal.X,normal.Y,contact);
                }
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
        CaelumImpactEnergy.AddWork(contact,CaelumImpactEnergy.Work(impulse,closingSpeed),impulse);
        bool applyCrush = contact.RegisterSustainedTransfer(
            level.time,
            closingSpeed,
            impulse,
            CaelumConstants.IMPACT_CRUSH_INTERVAL_TICS,
            CaelumImpactEnergy.Work(impulse,closingSpeed)
        );
        if (applyCrush)
        {
            ApplySustainedCrush(other, normalX, normalY, contact);
        }
    }

    void ApplySustainedCrush(Actor other, double normalX, double normalY, ImpactContactState contact)
    { CaelumImpactEnergy.ConsumeWork(contact); }

    ImpactBody BuildImpactPhysicsBody()
    {
        if (ImpactSelfBodyScratch == null)
        {
            ImpactSelfBodyScratch = ImpactBody(new("ImpactBody"));
        }
        ImpactBody body = ImpactSelfBodyScratch;
        if (body == null) { return null; }
        body.Mass = Max(1.0, GetCollisionEffectiveMass());
        body.Height = Max(0.0001,Height);
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
        body.Height = Max(0.0001,other.Height);
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

    // Los árboles conservan actor y masa descriptiva, pero sus raíces los
    // convierten en un límite estático para la resolución cinemática.
    void ResolveRootedEnvironmentImpact(CaelumEnvironmentProp environment)
    {
        if (environment == null || !environment.bSolid) { return; }

        ImpactContactState contactState = GetImpactContactState(environment);
        if (contactState != null)
        {
            contactState.RegisterCollision(level.time);
            ImpactDiagnosticDuplicateCallbacks++;
            return;
        }

        double dx = environment.Pos.X - Pos.X;
        double dy = environment.Pos.Y - Pos.Y;
        double distanceSquared = dx * dx + dy * dy;
        if (distanceSquared <= 0.00000001)
        {
            ImpactDiagnosticRestingCallbacks++;
            return;
        }

        double distance = Sqrt(distanceSquared);
        double normalX = dx / distance;
        double normalY = dy / distance;
        double closingSpeed = Vel.X * normalX + Vel.Y * normalY;
        if (closingSpeed <= CaelumConstants.IMPACT_MIN_DELTA_SPEED)
        {
            ImpactDiagnosticRestingCallbacks++;
            return;
        }
        ImpactDiagnosticUniquePairTicks++;

        ImpactBody selfBody = BuildImpactPhysicsBody();
        ImpactResult impact = GetImpactResultScratch();
        if (selfBody == null || impact == null) { return; }
        ImpactPhysics.ResolveStatic(
            selfBody,
            (normalX, normalY, 0.0),
            impact
        );
        if (!impact.Valid) { return; }

        contactState = LatchImpactContact(environment);
        if (contactState != null)
        {
            contactState.RegisterCollision(level.time);
            contactState.LastClosingSpeed = impact.ClosingSpeed;
            contactState.LastTransmittedImpulse = impact.Impulse;
        }

        Vel.X -= impact.Normal.X * impact.SourceDeltaSpeed;
        Vel.Y -= impact.Normal.Y * impact.SourceDeltaSpeed;

        double contactMinimum = 0.0;
        double contactMaximum = 1.0;
        double overlapBottom = Max(Pos.Z, environment.Pos.Z);
        double overlapTop = Min(
            Pos.Z + selfBody.Height,
            environment.Pos.Z + Max(1.0, environment.Height)
        );
        if (overlapTop > overlapBottom)
        {
            contactMinimum = Clamp(
                (overlapBottom - Pos.Z) / selfBody.Height,
                0.0,
                1.0
            );
            contactMaximum = Clamp(
                (overlapTop - Pos.Z) / selfBody.Height,
                0.0,
                1.0
            );
        }

        ReceiveCaelumImpact(
            impact.SourceDeltaSpeed,
            CaelumConstants.IMPACT_KIND_ACTOR,
            environment,
            environment.GetEnvironmentImpactMultiplier(),
            selfBody.Mass,
            0.0,
            impact.ClosingSpeed,
            impact.Impulse,
            contactMinimum,
            contactMaximum, true, -1, null, impact.Normal
        );
            CaelumImpactEnergy.Deliver(environment,self,0,CaelumConstants.IMPACT_KIND_ENVIRONMENT,
            CollisionDamageMultiplier,environment.GetEnvironmentMassKg(),selfBody.Mass,
            impact.ClosingSpeed,impact.Impulse,0,1,
            CaelumImpactEnergy.Received(selfBody.Mass,0,impact.ClosingSpeed));
    }

    override void CollidedWith(Actor other, bool passive)
    {
        Super.CollidedWith(other, passive);

        // Las caras que sólo se tocan verticalmente pertenecen al aterrizaje.
        if (other!=null && (Pos.Z>=other.Pos.Z+other.Height-0.001
            || other.Pos.Z>=Pos.Z+Height-0.001)) return;

        // El apoyo desde arriba tiene su propio contacto vertical, una sola vez.
        let hazard = CaelumHazardRock(other);
        if (hazard != null && hazard.IsDescendingAbove(self)) return;

        CaelumCombatActor otherCombatActor = CaelumCombatActor(other);
        CaelumEnvironmentProp environment = CaelumEnvironmentProp(other);
        if (DisableCaelumImpactContacts
            || (otherCombatActor != null
                && otherCombatActor.DisableCaelumImpactContacts)
            || other == null || other == self
            || health <= 0 || (other.health<=0 && (environment==null || other.bShootable))
            || (CaelumPlayer(other) == null
                && CaelumCombatActor(other) == null
                && CaelumTrainingDummy(other) == null
                && environment == null))
        {
            return;
        }
        ImpactDiagnosticCollisionCallbacks++;

        if (environment != null && !environment.IsEnvironmentMovable())
        {
            ResolveRootedEnvironmentImpact(environment);
            return;
        }

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

        CaelumImpactEnergy.Pair(self,other,selfBody,otherBody,impact,
            CaelumConstants.IMPACT_KIND_ACTOR);
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
            1.0, false, -1, null, normal
        );
    }

    void RegisterWorldImpact(double deltaSpeed, int impactKind)
    {
        if (impactKind==CaelumConstants.IMPACT_KIND_FLOOR
            && CaelumImpactEnergy.BodyLanding(self,deltaSpeed)) return;
        double effectiveDeltaSpeed = Max(0.0, deltaSpeed);
        LastImpactRawDeltaSpeed = effectiveDeltaSpeed;
        LastImpactBiologicalAbsorptionSpeed = 0.0;

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

    // Contexto síncrono: capturar antes de ganar Adrenalina por bloqueo o dolor.
    transient double RallyDamageFactor;

    int ApplyNativeHealthDamage(Actor inflictor,Actor source,double damage,Name mod,int flags,double angle)
    {
        int retained=CaelumSealResistance.HealthDamage(self,inflictor,damage,mod);
        if(flags & DMG_FORCED)retained=CaelumRally.ScaleDamage(self,CaelumSleepRules.ScaleDamage(self,retained));
        int before=health;
        int result=Super.DamageMobj(inflictor,source,retained,mod,flags,angle);
        CaelumSleepRules.HealthLost(self,before);
        return result;
    }

    override int TakeSpecialDamage(Actor inflictor,Actor source,int damage,Name mod)
    {
        return CaelumRally.ScaleDamage(self,
            CaelumSleepRules.ScaleDamage(self,Super.TakeSpecialDamage(inflictor,source,damage,mod)));
    }

    override int DamageMobj(Actor inflictor,Actor source,int damage,Name mod,int flags,double angle)
    {
        if(!CaelumArcaneSun.AllowsDamage(inflictor,self)
            || (!(flags & DMG_FORCED) && !CaelumRedemption.AllowsDamage(source,self,mod)))return 0;
        EnsureCombatPersonality();
        let shot=CaelumActorProjectile(inflictor);
        Actor previousReceiver=shot!=null?shot.CaelumDefenseReceiver:null;
        double previousRallyFactor=RallyDamageFactor;
        RallyDamageFactor=CaelumRally.DamageFactor(self,source);
        int result=ReceiveCaelumDamage(inflictor,source,damage,mod,flags,angle);
        RallyDamageFactor=previousRallyFactor;
        if(shot!=null)shot.CaelumDefenseReceiver=previousReceiver;
        return result;
    }

    virtual double ResolveActorShieldDamage(Actor inflictor,Actor source,double damage,Name mod,int flags)
    {return damage;}

    int ReceiveCaelumDamage(
        Actor inflictor,
        Actor source,
        int damage,
        Name mod,
        int flags,
        double angle
    )
    {
        CaelumBolas.FireAttack(self,inflictor,mod);
        if (mod == 'CaelumImpact' || mod == 'Crush' || mod == 'CaelumWeight' || mod == 'CaelumPressure'
            || mod=='CaelumEarthquake' || CaelumToughnessRules.IsSustained(mod))
        {
            // Los impactos y la presión ya están resueltos; el techo convierte
            // trabajo a HP una sola vez, sin depender de la vida máxima.
            double preToughnessDamage=damage;
            if (mod == 'Crush' && inflictor == null && source == null)
                preToughnessDamage = damage>=CaelumCrushingDamage.NATIVE_TELEFRAG_THRESHOLD ? damage : CaelumCrushingDamage.NativeWork(self);
            if((mod=='Crush' && damage<CaelumCrushingDamage.NATIVE_TELEFRAG_THRESHOLD) || mod=='CaelumWeight' || mod=='CaelumEarthquake')
                damage=Max(0,int(CaelumToughnessRules.Apply(self,preToughnessDamage)+0.5));
            if(CaelumToughnessRules.IsSustained(mod))
            {PendingLocalizedImpact=false;PendingLocalizedCriticalHit=false;}
            int healthBeforeImpact = health;
            double adrenalineRatioBeforeImpact = GetCombatAdrenalineRatio();
            int result = ApplyNativeHealthDamage(
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
                    mod == 'CaelumImpact' && LastImpactKind == CaelumConstants.IMPACT_KIND_ACTOR
                );
                if (mod == 'CaelumImpact' && LastImpactKind == CaelumConstants.IMPACT_KIND_ACTOR)
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

        damage=CaelumActorProjectile.PrepareDefense(self,inflictor,damage,mod,flags);
        if(damage<=0){PendingLocalizedImpact=false;PendingLocalizedCriticalHit=false;return 0;}
        damage=CaelumThermalEffects.Incoming(self,inflictor,source,damage,mod);
        let mixed=CaelumMixedMeleeDamage.ForHit(self,inflictor,source,mod);
        if(mixed!=null)mixed.PrepareFire(self);
        double shieldRetained=ResolveActorShieldDamage(inflictor,source,damage,mod,flags);

        if (flags & DMG_EXPLOSION)
        {
            PendingLocalizedImpact = false;
            PendingLocalizedCriticalHit = false;
            return ApplyActorExplosionDefense(
                inflictor,
                source,
                shieldRetained,
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
        bool localizedCriticalHit = mixed!=null ? mixed.Critical : PendingLocalizedCriticalHit;
        ResolveActorArmorImpact(shieldRetained, CaelumArmorRules.IsMagical(inflictor, mod),inflictor,source,mixed);
        PendingLocalizedCriticalHit = false;
        int retainedDamage = Max(
            0,
            int(LastCombatPostToughnessDamage + 0.5)
        );
        if (retainedDamage <= 0) { return 0; }
        int result = ApplyNativeHealthDamage(
            inflictor,
            source,
            LastCombatPostToughnessDamage,
            mod,
            flags | DMG_NO_ARMOR,
            angle
        );

        if (health < healthBeforeDamage)
        {
            int actualHealthLost = healthBeforeDamage - health;
            if(mixed!=null)mixed.ApplyBurn(self,healthBeforeDamage);
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

        let mine = CaelumMagicMine(inflictor);
        if (mine != null) return mine.BlastRadius();

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
        double incomingDamage,
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
            return ApplyNativeHealthDamage(
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
        CaelumThermalMagic.Impact(self,inflictor,CaelumThermalMagic.AreaRetention(self,touchedRegionMask));

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
        LastCombatToughnessDamageMultiplier = 1.0;


        bool magical = CaelumArmorRules.IsMagical(inflictor, mod);
        int totalHealthDamage = 0;
        double toughness=CaelumToughnessRules.Effective(self);
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
            double postAnatomyDamage = incomingDamage * vulnerabilityMultiplier;

            double preDefenseDamage = postAnatomyDamage;
            double defensePercent = GetArmorDefensePercent(slot, magical,inflictor,source);
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
            LastCombatArmorDefenseExactPercent = defensePercent;
            LastCombatArmorDefensePercent = int(defensePercent);
            LastCombatArmorIncomingDamage += preDefenseDamage;
            LastCombatArmorAbsorbedDamage += absorbedDamage;
            LastCombatArmorPostDefenseDamage += postDefenseDamage;


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
                double equippedAbsorbed = preDefenseDamage * CaelumArmorRules.EquippedDefense(CombatArmor,slot,magical,self,inflictor,source)/100.0;
                int durabilityLoss = int(
                    equippedAbsorbed
                        / CaelumConstants.ARMOR_ABSORBED_DAMAGE_PER_GUARANTEED_DURABILITY
                );
                double remainder = equippedAbsorbed
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

        LastCombatPostToughnessDamage=CaelumToughnessRules.AfterActorDefenses(
            self,LastCombatArmorPostDefenseDamage,toughness,magical);
        LastCombatToughnessDamageMultiplier=CaelumToughnessRules.RetainedFraction(
            LastCombatArmorPostDefenseDamage,LastCombatPostToughnessDamage);
        totalHealthDamage=Max(0,int(LastCombatPostToughnessDamage+0.5));
        if (totalHealthDamage <= 0) { return 0; }
        int healthBeforeDamage = health;
        double adrenalineRatioBeforeDamage = GetCombatAdrenalineRatio();
        int result = ApplyNativeHealthDamage(
            inflictor,
            source,
            LastCombatPostToughnessDamage,
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
                LastCombatArmorDefenseExactPercent = lucidityDefensePercent;
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
                mod != 'CaelumTrapMagic'
            );
            if (mod != 'CaelumTrapMagic')
            {
                AddActorCombatAdrenaline(
                    CaelumConstants.ADRENALINE_GAIN_ON_DAMAGE
                );
                MarkActorCombatActivity();
            }
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
            LastCombatArmorDefenseExactPercent / 100.0,
            0.0,
            1.0
        );
        LastCombatLucidityLoss = Min(
            CurrentCombatLucidity,
            CaelumConstants.CRITICAL_POINT_BASE_LUCIDITY_LOSS
                * LastCombatLucidityCriticalFactor
                * (1.0 - defenseRatio)
                * GetActorPainLucidityMultiplier()
        );
        CurrentCombatLucidity = Max(
            0.0,
            CurrentCombatLucidity - LastCombatLucidityLoss
        );
        UpdateActorLucidityState();
    }

    // Dolor y pérdida de Lucidez no adoptan el nuevo divisor de daño.
    double GetActorPainLucidityMultiplier()
    {
        return CaelumGrowthRules.Remaining(CombatToughness);
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

    void ResolveActorArmorImpact(double incomingDamage, bool magical = false,Actor inflictor=null,Actor source=null,CaelumMixedMeleeDamage mixed=null)
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
        let preparedProjectile=CaelumActorProjectile(inflictor);
        bool deferredAnatomy=hadLocalizedImpact && preparedProjectile!=null
            && preparedProjectile.CaelumDefenseReceiver==self;
        double sharedAnatomy=GetActorVulnerabilityMultiplier(LastAnatomyVulnerabilityGrade);
        if(mixed!=null && mixed.Critical)sharedAnatomy*=sharedAnatomy+1;
        if (!hadLocalizedImpact || deferredAnatomy || mixed!=null)
        {
            double anatomy=mixed!=null ? sharedAnatomy : GetActorVulnerabilityMultiplier(LastAnatomyVulnerabilityGrade);
            if(mixed==null && deferredAnatomy && PendingLocalizedCriticalHit)anatomy*=anatomy+1;
            LastCombatArmorIncomingDamage *= anatomy;
            LastCombatArmorPostDefenseDamage = LastCombatArmorIncomingDamage;
        }

        LastCombatArmorSlot = GetArmorSlotForLocation(LastAnatomyLocation);
        CaelumThermalMagic.Impact(self,inflictor,CaelumThermalMagic.ArmorRetention(self,LastCombatArmorSlot));

        LastCombatArmorDefenseExactPercent = GetArmorDefensePercent(LastCombatArmorSlot, magical,inflictor,source);
        LastCombatArmorDefensePercent = int(LastCombatArmorDefenseExactPercent);
        double defenseRatio = Clamp(
            LastCombatArmorDefenseExactPercent / 100.0,
            0.0,
            1.0
        );
        LastCombatArmorAbsorbedDamage =
            LastCombatArmorIncomingDamage * defenseRatio;
        LastCombatArmorPostDefenseDamage = Max(
            0.0,
            LastCombatArmorIncomingDamage - LastCombatArmorAbsorbedDamage
        );

        double physicalIncoming=LastCombatArmorIncomingDamage;
        double fireIncoming=mixed!=null ? mixed.FireAfterShield*sharedAnatomy : 0;
        double fireAbsorbed=mixed!=null ? fireIncoming*Clamp(
            GetArmorDefensePercent(LastCombatArmorSlot,true,inflictor,source)/100.0,0.0,1.0) : 0;
        if(mixed!=null)
        {
            LastCombatPostToughnessDamage=mixed.Resolve(self,LastCombatArmorPostDefenseDamage,fireIncoming-fireAbsorbed);
            LastCombatArmorIncomingDamage+=fireIncoming;LastCombatArmorAbsorbedDamage+=fireAbsorbed;
            LastCombatArmorPostDefenseDamage=mixed.BeforeToughness;
        }
        else LastCombatPostToughnessDamage=CaelumToughnessRules.Apply(self,LastCombatArmorPostDefenseDamage,magical);
        LastCombatToughnessDamageMultiplier=CaelumToughnessRules.RetainedFraction(
            LastCombatArmorPostDefenseDamage,LastCombatPostToughnessDamage);

        if (CombatArmor == null
            || CombatArmor.Durability[LastCombatArmorSlot] <= 0
            || LastCombatArmorAbsorbedDamage <= 0.0)
        {
            return;
        }

        double equippedAbsorbed = physicalIncoming
            * CaelumArmorRules.EquippedDefense(CombatArmor,LastCombatArmorSlot,magical,self,inflictor,source)/100.0
            +fireIncoming*CaelumArmorRules.EquippedDefense(CombatArmor,LastCombatArmorSlot,true,self,inflictor,source)/100.0;
        LastCombatArmorDurabilityLoss = int(
            equippedAbsorbed
                / CaelumConstants.ARMOR_ABSORBED_DAMAGE_PER_GUARANTEED_DURABILITY
        );
        double remainder = equippedAbsorbed
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
                * GetActorPainLucidityMultiplier()
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
                Sound painSound = GetCombatPainSound();
                if (painSound != 0)
                {
                    A_StartSound(painSound, CHAN_VOICE);
                }
                if (grantPainAdrenaline)
                {
                    AddActorCombatAdrenaline(
                        CaelumConstants.ADRENALINE_GAIN_ON_PAIN
                    );
                }
            }
        }
    }

    // El sonido espacial de dolor se resuelve por clase. El valor nulo
    // conserva el dolor silencioso para actores sin perfil seleccionado.
    virtual Sound GetCombatPainSound() { return 0; }

    double GetCombatAdrenalineRatio()
    {
        CaelumSiegeFocus.ApplyToActor(self);
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
        CaelumSiegeFocus.ApplyToActor(self);
        let cache=GetActorMaintenance();
        if(cache!=null && !cache.HealthChanged(self))
        {
            // Restaurar también asignaciones alteradas por consumidores, como la recarga.
            cache.RestoreHealth(self);return;
        }
        CalculateCombatHealthEffects();
        if(cache!=null)cache.StoreHealth(self);
    }

    void CalculateCombatHealthEffects()
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

        int effectiveAgility = CombatAgility
            + GetCombatArmorAttributeBonus(CaelumConstants.ATTRIBUTE_AGILITY);
        double adrenalineRatio = GetCombatAdrenalineRatio();
        if(adrenalineRatio>=1.0)
        {
            // Resultado exacto de la fórmula saturada; conserva heridas y otros efectos.
            CombatHealthPerformanceMultiplier=1.0;
            CombatHealthPainMultiplier=1.0;
        }
        else
        {
            int effectivePatience=CombatPatience
                + GetCombatArmorAttributeBonus(CaelumConstants.ATTRIBUTE_PATIENCE);
            double patienceMultiplier=CaelumGrowthRules.Remaining(effectivePatience);
            double patienceAdjustedPerformance=1.0-(1.0-rawPerformance)*patienceMultiplier;
            CombatHealthPerformanceMultiplier=patienceAdjustedPerformance
                +(1.0-patienceAdjustedPerformance)*adrenalineRatio;
            CombatHealthPainMultiplier=1.0+(rawIntensity-1.0)*patienceMultiplier*(1.0-adrenalineRatio);
        }
        CombatAdrenalineGainMultiplier = rawIntensity*CaelumPersonalityRules.Adrenaline(self);

        double baseEvasion = CaelumGrowthRules.Bonus(effectiveAgility);
        double massMultiplier = 100.0 / (Mass / 2.0 + 50.0);
        EffectiveCombatEvasionChance = baseEvasion
            * massMultiplier
            * CombatHealthPerformanceMultiplier * CaelumPersonalityRules.Evasion(self);
        Speed = CombatBaseSpeed * CombatHealthPerformanceMultiplier * CaelumThermalEffects.Speed(self)
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

    // El estado de muerte conserva su índice; sólo cambia la política de drop.
    action void A_CaelumNoBlocking()
    { A_NoBlocking(!CaelumRedemption.PreviouslyRaised(self)); }

    override int DoSpecialDamage(Actor victim,int damage,Name mod)
    {
        if(!CaelumRedemption.AllowsDamage(self,victim,mod))return 0;
        int retained=Super.DoSpecialDamage(victim,damage,mod);
        // Los objetos sin perfil biológico conservan su receptor nativo único.
        let mixed=CaelumMixedMeleeDamage.ForHit(victim,self,self,mod);
        if(mixed!=null && CaelumPlayer(victim)==null && CaelumCombatActor(victim)==null)
        {
            mixed.PrepareFire(victim);
            retained+=Max(0,int(mixed.FireDamage*CaelumSealResistance.ForEssence(victim,CaelumConstants.ESSENCE_FIRE)+0.5));
        }
        return retained;
    }

    bool MazeDropReleased;
    int DemonSupplyRevision;
    bool DemonDeathLootReleased;

    override void Die(Actor source, Actor inflictor, int dmgflags, Name MeansOfDeath)
    {
        if(CaelumRedemption.PreviouslyRaised(self)){MazeDropReleased=true;DemonDeathLootReleased=true;}
        // La posición seca original recupera incluso bajas en pozos/aplastamientos.
        if(!MazeDropReleased && CaelumMazeLayout.IsCardinal())
        {
            MazeDropReleased=true;
            CaelumMazeLayout.CreateDeathDrop(tid);
        }
        CaelumDemonService.ReleaseLoot(self,CaelumMazeLayout.IsCardinal() && CaelumMazeLayout.HasDeathDrop(tid));
        CaelumDemonService.StopBreath(self);
        CaelumBreathing.StopAudio(self);
        Super.Die(source,inflictor,dmgflags,MeansOfDeath);
        // Los saves previos retienen sus EventHandlers. La misma confirmación
        // idempotente cubre su muerte nativa sin convertir ausencia en muerte.
        if(SiegeCombatant!=null)CaelumSiegeCombatant.ConfirmDeath(self);
        CaelumCorpseArchive.Died(self);
    }

    void ThermalChase(statelabel melee='_a_chase_default',statelabel missile='_a_chase_default',int flags=0)
    {
        if((CaelumBolas.Restrained(self) || CaelumTelekinesisRules.Held(self)))return;
        vector3 before=Pos;
        if(CaelumBattleCry.Active(self)){melee=null;missile=null;}
        A_Chase(melee,missile,flags);
        if(Pos.Z<=FloorZ+0.01)CaelumThermalMotion.Path(self,before,Pos,false);
    }

    bool ThermalTryMove(vector2 destination)
    {
        if((CaelumBolas.Restrained(self) || CaelumTelekinesisRules.Held(self)))return false;
        vector3 before=Pos;
        bool moved=TryMove(destination,0);
        if(moved && Pos.Z<=FloorZ+0.01)CaelumThermalMotion.Path(self,before,Pos,false);
        return moved;
    }

    void UpdateCombatResourceRecovery(bool sleeping)
    {
        let cache=GetActorMaintenance();
        if(cache!=null)
        {
            if(level.maptime<cache.ResourceDue && health>=CombatMaximumHealth
                && CurrentCombatAnima>=MaximumCombatAnima && CurrentCombatAir>=MaximumCombatAir
                && CurrentCombatLucidity>=CaelumConstants.MAXIMUM_LUCIDITY)return;
            cache.ResourceDue=cache.NextDue();
        }
        CalculateCombatResourceRecovery(sleeping);
    }

    void CalculateCombatResourceRecovery(bool sleeping)
    {
        double idleFactor=IsCombatIdle() ? CaelumRestRules.CHAIR_RESOURCE_FACTOR : 1;
        if (idleFactor>1 && health>0 && health<CombatMaximumHealth)
        {
            IdleHealthAccumulator+=CombatMaximumHealth/CaelumConstants.HEALTH_BASE_RECOVERY_REAL_SECONDS
                *CalculateActorType4Percent(CombatResilience)/100.0*idleFactor/TICRATE;
            int recovered=int(IdleHealthAccumulator);
            IdleHealthAccumulator-=recovered;health=Min(CombatMaximumHealth,health+recovered);
        }
        if (health > 0 && CurrentCombatAnima < MaximumCombatAnima)
        {
            CurrentCombatAnima = Min(
                MaximumCombatAnima,
                CurrentCombatAnima
                    + CombatAnimaRegenerationPerSecond * idleFactor / TICRATE
            );
        }
        if (health > 0 && !CombatAirSpending
            && CurrentCombatAir < MaximumCombatAir)
        {
            CurrentCombatAir = Min(
                MaximumCombatAir,
                CurrentCombatAir + CombatAirRegenerationPerSecond * idleFactor * CaelumBreathing.ActorFactor(self) / TICRATE
            );
        }
        if (health > 0 && !sleeping
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
    }

    override void Tick()
    {
        if(CaelumRedemption.Pending(self))return;
        EnsureCombatPersonality();
        EnsureGrowthBalance();
        CaelumDemonService.Initialize(self);
        CaelumSiegeFocus.ApplyToActor(self);
        CaelumBreathing.UpdateSound(self);
        ResourceRecoveryActive();
        CaelumDemonService.UpdateBreath(self);
        // Los valores base quedan intactos: reconstruir evita restas acumuladas.
        if (ArmorBalanceRevision < 1 && CombatProfileInitialized)
        {
            RecalculateCombatStatistics();
            LastCombatArmorDefenseExactPercent = LastCombatArmorDefensePercent;
            ArmorBalanceRevision = 1;
        }
        if (!CaelumRedemption.PreviouslyRaised(self)
            && !(CaelumBolas.Restrained(self) || CaelumTelekinesisRules.Held(self)) && SiegeCombatant != null && SiegeCombatant.Withdrawing && health > 0)
        {
            if (!InStateSequence(CurState,FindState("SiegeWithdrawal")))
                SetStateLabel("SiegeWithdrawal");
            SiegeCombatant.WithdrawTick();
            if (!SiegeCombatant.Exited) { Super.Tick();CaelumThermalRuntime.NPCStep(self); }
            return;
        }
        Vector3 prePhysicsVelocity = Vel;
        vector3 thermalBefore=Pos;
        Sector thermalSector=CurSector;
        let thermalSupport=CaelumThermalMotion.Support(self);
        double thermalSupportHeight=CaelumThermalMotion.SupportHeight(thermalSector,thermalSupport,Pos.XY);
        let thermalMotion=ThermalState;
        vector2 thermalPropulsion=thermalMotion!=null ? thermalMotion.PropelledVelocity : (0,0);
        bool thermalGrounded=Pos.Z<=FloorZ+0.01;
        bool held=CaelumTelekinesisRules.Held(self);
        bool bound=CaelumBolas.Restrained(self);
        int bolasSavedTics=tics;State bolasSavedState=CurState;
        bool bolasFreeze=bound && !CaelumBolas.Interrupted(self);
        if(bound && !held){Vel.X=0;Vel.Y=0;if(bNOGRAVITY)Vel.Z=0;}
        if(bolasFreeze)tics=-1;
        int heldSavedTics=tics;State heldSavedState=CurState;
        bool sleeping = ForcedSleepTics > 0;
        if (sleeping) { CaelumSleepRules.MaintainPose(self);tics = -1; if(!held)Vel = (0,0,0); }
        if(held)tics=-1;
        CaelumTelekinesisRules.Physics(self);
        if(CaelumTelekinesisRules.Held(self))prePhysicsVelocity=Vel;
        Super.Tick();
        if(held && !sleeping && !bolasFreeze && CurState==heldSavedState)tics=heldSavedTics;
        if(bolasFreeze && CurState==bolasSavedState)tics=bolasSavedTics;
        if (sleeping)
        {
            CurrentCombatLucidity = CaelumSleepRules.Drain(CurrentCombatLucidity);
            UpdateActorLucidityState();
            ForcedSleepTics--;
            if (ForcedSleepTics <= 0)CaelumSleepRules.Wake(self);
        }
        UpdateCaelumRecognitionSound();
        CaelumThermalMotion.Physics(self,thermalBefore,prePhysicsVelocity,thermalGrounded,thermalPropulsion,thermalSector,thermalSupport,thermalSupportHeight);
        CaelumThermalRuntime.NPCStep(self);

        CaelumDemonService.UpdatePotions(self);

        // Los actores diagnósticos conservan estados nativos, A_Look, A_Chase
        // y ataques, pero no recalculan estadísticas, estados elementales ni
        // contactos que no forman parte de esta prueba. El juego normal no
        // toma esta salida rápida.
        if (CaelumMassAIScheduleActive || CaelumDiagnosticPassiveAI)
        {
            return;
        }
        if (ElementalStatus != null) ElementalStatus.Tick(self);

        bool groundedNow = bOnMobj || Pos.Z <= FloorZ + 0.01;
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
        UpdateCombatResourceRecovery(sleeping);
        if (CombatLucidityPhysicalStunRemaining > 0.0)
        {
            if(!CaelumTelekinesisRules.Held(self)){Vel.X=0;Vel.Y=0;}
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
        else if (CurrentCombatAdrenaline > 0.0 && !CaelumSiegeFocus.ApplyToActor(self))
        {
            CurrentCombatAdrenaline = Max(
                0.0,
                CurrentCombatAdrenaline
                    - CaelumConstants.ADRENALINE_DECAY_PER_SECOND / TICRATE
            );
        }
    }

    States
    {
    SiegeWithdrawal:
        "####" "#" 4;
        Loop;
    AttackResourceWait:
        "####" "#" 1 A_CaelumWaitAttackResource;
        Loop;
    ResourceRetreat:
        "####" "#" 4 A_CaelumRecoverResources;
        Loop;
    AttackOutOfRange:
        "####" "#" 1;
        "####" "#" 0 A_CaelumResumeCombat;
        Wait;
    }

    action void A_CaelumRecoverResources()
    {
        let actor=CaelumCombatActor(self);
        if(actor!=null)actor.PulseResourceRecovery();
    }

    action void A_CaelumResumeCombat()
    {
        let actor=CaelumCombatActor(self);
        if(actor!=null)actor.SetState(actor.SeeState);
    }

    override void OnDestroy()
    {
        // ClearLevelData también destruye actores: no ejecutar A_Look ni
        // consultar geometría cuando el motor ya desmontó el mundo.
        CaelumDemonService.StopBreath(self,false,false);
        if(RecoveryGoal!=null)RecoveryGoal.Destroy();
        Super.OnDestroy();
    }
}
