// CaelumPlayer is the base class for every playable character.
//
// It currently inherits DoomPlayer so that Doom II's temporary weapons,
// animations, sounds, and inventory remain usable during early development.
// These inherited resources will be replaced by original assets later.
class CaelumPlayer : DoomPlayer
{
    // This object owns the twelve primary attributes for this player.
    // Each player receives a separate instance, including in multiplayer.
    CaelumAttributes Attributes;

    // Raza, dos clases, sexo y altura se guardan en un unico perfil.
    CaelumCharacterProfile CharacterProfile;

    // Stores the four layer points and thirty individual points.
    CaelumCharacterAllocation CharacterAllocation;

    // Derived values are recalculated whenever primary creation data changes.
    CaelumDerivedStats DerivedStats;
    // Copia directa para HUD/UI. Evita que la interfaz conserve una lectura
    // anterior del objeto auxiliar mientras el inventario cambia en play scope.
    double HUDCarriedWeight;
    double HUDCarryCapacity;
    double HUDLoadRatio;
    // Copias simples para que el HUD pueda leer el arma activa sin invocar
    // funciones de play scope desde el contexto de interfaz.
    bool HUDHasActiveWeapon;
    int HUDActiveWeaponType;
    int HUDActiveWeaponTier;
    int HUDActiveWeaponSize;
    int HUDActiveWeaponEssenceType;
    bool HUDActiveWeaponIsRanged;
    int HUDRangedMagazineCount;
    int HUDRangedMagazineCapacity;
    int HUDRangedReserveCount;
    bool HUDCombatBlockActive;
    bool HUDCombatBlockUsesGauntlets;
    int HUDActiveShieldType;
    bool HUDHasEquippedSeal;
    int HUDEquippedSealType;
    int HUDEquippedSealTier;
    int HUDChannelAffectedCount;
    double HUDActiveWeaponNoticeRemaining;
    bool HUDActiveWeaponStateInitialized;
    CaelumAnatomyProfile AnatomyProfile;
    bool DebugAttributesAt75;
    bool DebugAttributesAt100;
    int DebugPanelPage;

    // Four independently configured armor pieces provide uniform defense by
    // armor type/tier, slot-specific reinforcement, bonuses, and durability.
    CaelumArmorModel ArmorModel;
    CaelumShieldModel ShieldModel;
    CaelumWeaponModel WeaponModel;
    CaelumElementalStatus ElementalStatus;
    int SelectedEssenceType;
    double IlluminationRemaining;
    int OwnedArmorCount;
    int OwnedShieldCount;
    int OwnedWeaponCount;
    bool EquipmentMenuOpen;
    bool CraftingMenuOpen;
    int ActiveCraftingStationType;

    // Estado de la red de infraestructura detectada al interactuar.
    int CraftingNetworkCapabilities;
    int CraftingNetworkScanToken;
    bool CraftingSelectedInfrastructureAvailable;
    int CraftingMissingStationType;

    int CraftingSelectionRecipe;
    int CraftingSelectionTier;
    int CraftingSelectionSize;
    int CraftingSelectedWeapon;

    // Estado de la receta unificada actualmente seleccionada.
    int CraftingSelectedRecipeKind;
    int CraftingSelectedArmorType;
    int CraftingSelectedArmorSlot;
    int CraftingSelectedEssenceWeaponType;
    int CraftingSelectedEssenceType;
    int CraftingSelectedAmuletType;
    int CraftingSelectedSealType;

    int CraftingBasicMaterialType;
    int CraftingBasicMaterialTier;
    int CraftingBasicRequired;
    int CraftingBasicOwned;
    int CraftingTierMaterialType;
    int CraftingTierMaterialTier;
    int CraftingTierRequired;
    int CraftingTierOwned;
    double CraftingFinalWeight;
    int LastCraftingAction;
    int EquipmentSelectionKind;
    int EquipmentSelectionSlot;
    int EquipmentSelectionArmorType;
    int EquipmentSelectionShieldType;
    int EquipmentSelectionWeaponType;
    int EquipmentSelectionWeaponEssenceType;
    int EquipmentSelectionAmmunitionType;
    int EquipmentSelectionConsumableType;
    int EquipmentSelectionSpecialType;
    int EquipmentSelectionAmuletType;
    int EquipmentSelectionSealType;
    int EquipmentSelectionTier;
    int EquipmentSelectionSize;
    bool EquipmentSelectionOwned;
    bool EquipmentSelectionEquipped;
    bool EquipmentSelectionInMagicBox;
    bool EquipmentSelectionSizeCompatible;
    int EquipmentSelectionDurability;
    int EquipmentSelectionMaximumDurability;
    double EquipmentSelectionWeight;
    double EquipmentSelectionDamage;
    double EquipmentSelectionAirCost;
    double EquipmentSelectionAnimaCost;
    int EquipmentSelectionAttackTics;
    int EquipmentSelectionStackAmount;
    int MagicBoxUsedSlots;
    int MagicBoxMaximumSlots;
    int PersonalInventoryItemCount;
    int EquippedItemSlotCount;
    int LastEquipmentAction;
    int LastDismantledBasicMaterialType;
    int LastDismantledBasicUnits;
    int LastDismantledTierMaterialType;
    int LastDismantledTierUnits;
    bool LastEquipmentPickupWasNew;
    bool LastEquipmentPickupWentToMagicBox;
    double EquippedWeaponBaseWeight;
    int EquippedWeaponTier;
    int EquippedWeaponSize;
    bool WeaponWeightInitialized;
    double EquippedWeaponCooldownRemaining;

    // Bloquea repeticiones de AltFire de la jabalina mientras el botón sigue
    // pulsado. El motor puede reentrar en AltFire desde WeaponReady cada tic.
    bool JavelinSecondaryLatched;

    // Evita repetir una interacción de empuje cada tic mientras se mantiene
    // pulsada la tecla de uso. El sistema normal de +use sigue funcionando.
    bool MovablePropUseLatched;

    // La estación consume la pulsación de Use que abrió el crafting. No se
    // rearma mientras el menú siga abierto; sólo vuelve a aceptar una nueva
    // activación después de cerrar el menú y detectar Use liberado.
    bool CraftingStationUseLatched;

    // Último resultado del desgaste de arma para depuración y futuras UI.
    int LastWeaponDurabilityLoss;
    double LastWeaponDurabilityChancePercent;
    double LastWeaponDurabilityRollPercent;
    bool LastCarbineFired;
    bool LastCarbineHadEnoughAir;
    bool LastCarbineHadAmmo;
    bool LastCarbineCriticalHit;
    double LastCarbineDamage;
    double LastCarbineAccuracyPercent;
    double LastCarbineMinimumSpread;
    double LastCarbineMaximumSpread;
    double LastCarbineYawOffset;
    double LastCarbinePitchOffset;
    int CarbineAmmoCount;

    // V4.25 ranged architecture.
    int StandardBowMagazine;
    int LongbowMagazine;
    int CrossbowMagazine;
    int CarbineMagazine;
    bool RangedAimModeActive;
    bool RangedReloadActive;
    int RangedReloadWeaponType;
    double RangedReloadRemainingSeconds;
    double RangedReloadTotalSeconds;
    bool WeaponChargeActive;
    bool WeaponChargedStateActive;
    bool WeaponChargeIsMagic;
    int WeaponChargeWeaponType;
    int WeaponChargeWeaponTier;
    int WeaponChargeWeaponSize;
    int WeaponChargeEssenceType;
    double WeaponChargeRemainingSeconds;
    double WeaponChargeTotalSeconds;
    double WeaponChargedRemainingSeconds;

    double ArmorDurabilityDamageMultiplier;
    bool ArmorDurabilityMultiplierInitialized;
    bool DebugArmorCriticalHit;
    int LastArmorVulnerabilityGrade;
    double LastArmorVulnerabilityMultiplier;
    double LastArmorPreDefenseDamage;
    double LastArmorAbsorbedDamage;
    double LastArmorPostDefenseDamage;
    double LastToughnessDamageMultiplier;
    int LastArmorHealthDamage;
    int LastIncomingArmorSlot;
    int LastArmorDurabilityLoss;
    double LastArmorDurabilityChancePercent;
    double LastArmorDurabilityRollPercent;
    double LastLocalizedLucidityLoss;
    bool LastArmorHitWasCritical;
    bool LastIncomingActorCriticalHit;
    double LastIncomingActorCriticalChancePercent;
    double LastIncomingActorCriticalRollPercent;
    bool DebugShieldBlocking;

    // V4.24 combat-state foundation. DebugShieldBlocking remains as a
    // compatibility mirror while existing shield hit/durability code is
    // migrated incrementally.
    bool CombatBlockModeActive;
    int CombatBlockInputGraceTics;
    bool CombatZoomInputLatched;
    bool CombatChannelModeActive;
    Actor CombatChannelEffectActor;
    double CombatChannelCooldownRemaining;
    int CombatChannelSealType;
    int CombatChannelSealTier;
    double CombatChannelAdrenalinePerTic;
    double CombatChannelRadius;
    bool CombatChannelInputLatched;
    bool CombatRacialAbilityInputReserved;
    bool CombatTarotInputReserved;
    bool CombatClassAbilityInputReserved;
    double HUDAbilitySuccessRemaining;

    int DebugShieldDamageKind;
    int DebugShieldIncomingAngleOffset;
    bool LastShieldWithinCoverage;
    double LastShieldAbsorbedDamage;
    int LastShieldHealthDamage;
    bool LastShieldBlockedAttack;
    int LastShieldDurabilityLoss;
    double LastShieldDurabilityChancePercent;
    double LastShieldDurabilityRollPercent;
    double CurrentShieldAirCostPerSecond;
    int LastAdrenalineEvent;
    double LastAdrenalineBaseGain;
    double LastAdrenalineFinalGain;
    int LastExplosionTouchedRegionMask;
    int LastExplosionTouchedRegionCount;
    double LastExplosionRadius;

    // CaelumMaximumHealth is the integer gameplay maximum calculated from
    // Constitution. GZDoom damage still changes the inherited health field.
    int CaelumMaximumHealth;
    bool HealthResourceInitialized;
    int HealthState;
    double HealthRawPerformanceMultiplier;
    double HealthPatienceMitigationMultiplier;
    double HealthPatienceMitigatedPerformanceMultiplier;
    double HealthPerformanceMultiplier;
    double HealthPainMultiplier;
    double HealthAdrenalineGainMultiplier;

    // Stored diagnostic values expose the latest real-damage pain calculation
    // without changing its result. They also survive saves with the player.
    double LastHealthLossPercent;
    double LastPainChancePercent;
    bool LastPainTriggered;

    // Latest isolated melee test data shown by the development panel.
    double LastMeleeCalculatedDamage;
    int LastMeleeActualDamage;
    bool LastMeleeHit;
    int LastMeleeHitLocation;
    int LastMeleeVulnerabilityGrade;
    double LastMeleeHitHeightRatio;
    double LastMeleeLocationMultiplier;
    double LastMeleeAirCost;
    bool LastMeleeHadEnoughAir;
    bool LastMeleeCriticalAttempted;
    bool LastMeleeCriticalHit;
    double LastMeleeCriticalChancePercent;
    double LastMeleeCriticalRollPercent;
    double LastMeleeAccuracyPercent;
    double LastMeleeMovementAccuracyMultiplier;
    double LastMeleeCrouchCriticalMultiplier;
    bool LastStaffHit;
    bool LastStaffCriticalAttempted;
    bool LastStaffCriticalHit;
    bool LastStaffInsufficientAnima;
    double LastStaffCalculatedDamage;
    int LastStaffActualDamage;
    double LastStaffCriticalChancePercent;
    double LastStaffCriticalRollPercent;
    double LastStaffAccuracyPercent;
    double LastStaffYawOffset;
    double LastStaffPitchOffset;
    double LastStaffLocationMultiplier;
    int LastStaffVulnerabilityGrade;
    double StaffCastCooldownRemaining;
    bool StaffCastPending;
    bool PendingStaffSecondaryAttack;
    bool PendingStaffChargedAttack;
    int PendingStaffWeaponType;
    int PendingStaffWeaponTier;
    int PendingStaffWeaponSize;
    int PendingStaffEssenceType;
    double PendingStaffAnimaCost;
    double PendingStaffCastTotalSeconds;
    bool LastStaffCastInterrupted;
    bool LastStaffCastCompleted;
    double LastStaffInterruptionChancePercent;
    double LastStaffInterruptionRollPercent;
    double LastMeleeYawOffset;
    double LastMeleePitchOffset;
    double LastAttackPushForce;

    // V4.25.1 — diagnóstico y estado del último impacto físico.
    double CollisionDamageMultiplier;
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

    // V4.25.3 — aceleración y contacto sostenido.
    double MovementAccelerationFactor;
    double MovementAccelerationSeconds;
    Array<ImpactContactState> ImpactContacts;
    int ImpactContactCountForUI;

    // Amortiguación biológica del último aterrizaje.
    double LastImpactRawDeltaSpeed;
    double LastImpactBiologicalAbsorptionSpeed;

    // El Anima es un recurso persistente separado para magia y armas magicas.
    double CurrentAnima;
    bool AnimaResourceInitialized;

    // Adrenaline begins empty and persists with the player. The combat timer
    // stores how long remains before its automatic decay may begin.
    double CurrentAdrenaline;
    double CombatTimeRemaining;
    bool AdrenalineResourceInitialized;

    // Lucidity is stored independently from health and begins at its fixed
    // maximum. LucidityState is cached so UI code never calls play functions.
    double CurrentLucidity;
    bool LucidityResourceInitialized;
    int LucidityState;
    double LucidityPhysicalStunRemaining;
    double LuciditySleepDebuffMultiplier;
    double LucidityAccuracyMultiplier;
    double EffectivePhysicalAccuracyPercent;
    double EffectiveMagicalAccuracyPercent;
    bool IsCrouching;
    double CrouchAccuracyMultiplier;
    double CrouchCriticalChanceMultiplier;
    double CrouchStealthMultiplier;
    double EffectiveStealthPercent;
    double MovementNoiseMultiplier;
    double LastMovementNoiseRange;
    double MovementNoiseTimer;
    double PainImmobilizationRemaining;
    double LastPainAnimationDuration;

    // Survival values represent the percentage remaining, not accumulated
    // need. All three begin full and decay according to the world-time rules.
    double CurrentHunger;
    double CurrentThirst;
    double CurrentSleep;
    bool SurvivalResourcesInitialized;
    int HungerState;
    int ThirstState;
    int SleepState;
    double SurvivalPerformanceMultiplier;
    double SurvivalRawPerformanceMultiplier;
    double EffectiveOffensiveDamageMultiplier;
    double AdrenalinePenaltyIgnoreRatio;
    double SurvivalDamageAccumulator;
    double NaturalHealthRegenerationAccumulator;

    // CurrentAir is the first live Caelum resource. It is stored on the player
    // actor so ordinary GZDoom saves preserve it automatically.
    double CurrentAir;
    bool AirResourceInitialized;
    int AirState;
    double AirStatePerformanceMultiplier;
    double EffectiveEvasionChance;
    bool LastEvasionAttempted;
    bool LastEvasionSucceeded;
    double LastEvasionChancePercent;
    double LastEvasionRollPercent;
    double EffectiveMovementPercent;
    double EffectiveJumpHeightPercent;

    // Stored in play scope so the UI can report the real running state without
    // calling gameplay functions from UI scope.
    bool IsSpendingRunningAir;

    // Jump tracking detects one grounded-to-rising transition. It prevents a
    // held jump key from spending air repeatedly on consecutive game tics.
    bool JumpTrackingInitialized;
    bool WasGroundedLastTick;

    // Temporary state for the step-by-step character creation interface.
    bool CreationWizardOpen;
    int CreationWizardPage;

    // These backups preserve the last confirmed state while the wizard edits
    // the live preview values.
    CaelumCharacterProfile CreationProfileBackup;
    CaelumCharacterAllocation CreationAllocationBackup;
    bool CharacterCreationComplete;

    Default
    {
        // The $ prefix means that GZDoom obtains the visible name from LANGUAGE.
        // This prevents user-facing text from being hard-coded in ZScript.
        Player.DisplayName "$CA_PLAYER_DISPLAY_NAME";

        // Prefijo facial propio para evitar resolver iconos/rostros heredados de Doom.
        Player.Face "CAF";

        // Caelum performs one custom pain roll after engine mitigation. This
        // disables DoomPlayer's independent native roll and prevents duplicates.
        PainChance 0;
    }

    CaelumPersistentCharacterState GetPersistentCharacterState(bool createState)
    {
        CaelumPersistentCharacterState persistentState = CaelumPersistentCharacterState(
            FindInventory("CaelumPersistentCharacterState")
        );
        if (persistentState == null && createState)
        {
            persistentState = CaelumPersistentCharacterState(
                GiveInventoryType("CaelumPersistentCharacterState")
            );
        }
        return persistentState;
    }

    // Copia el perfil y el equipamiento al inventario viajero antes de salir
    // del mapa. El mismo objeto queda incluido en guardados normales.
    void PersistCharacterState()
    {
        if (!CharacterCreationComplete || CharacterProfile == null
            || CharacterAllocation == null)
        {
            return;
        }
        SyncActiveModelsToNativeInventory();
        CaelumPersistentCharacterState persistentState = GetPersistentCharacterState(true);
        if (persistentState == null) { return; }
        persistentState.EnsureEquipmentSizeInitialized();

        persistentState.ProfileCommitted = true;
        persistentState.Race = CharacterProfile.Race;
        persistentState.FirstClass = CharacterProfile.FirstClass;
        persistentState.SecondClass = CharacterProfile.SecondClass;
        persistentState.Sex = CharacterProfile.Sex;
        persistentState.HeightChoice = CharacterProfile.HeightChoice;
        for (int layer = 0; layer < CaelumConstants.ATTRIBUTE_LAYER_COUNT; layer++)
        {
            persistentState.LayerBonus[layer] = CharacterAllocation.LayerBonus[layer];
        }
        for (int attribute = 0; attribute < CaelumConstants.PRIMARY_ATTRIBUTE_COUNT; attribute++)
        {
            persistentState.AttributeBonus[attribute] = CharacterAllocation.AttributeBonus[attribute];
        }

        if (ArmorModel != null && ShieldModel != null && WeaponModel != null)
        {
            persistentState.EquipmentInitialized = true;
            for (int slot = 0; slot < CaelumConstants.ARMOR_SLOT_COUNT; slot++)
            {
                persistentState.ArmorType[slot] = ArmorModel.ArmorType[slot];
                persistentState.ArmorTier[slot] = ArmorModel.Tier[slot];
                persistentState.ArmorSize[slot] = ArmorModel.Size[slot];
                persistentState.ArmorDurability[slot] = ArmorModel.Durability[slot];
            }
            persistentState.ArmorSelectedSlot = ArmorModel.SelectedSlot;
            persistentState.ShieldType = ShieldModel.ShieldType;
            persistentState.ShieldTier = ShieldModel.Tier;
            persistentState.ShieldSize = ShieldModel.Size;
            persistentState.ShieldDurability = ShieldModel.Durability;
            persistentState.ShieldEquipped = ShieldModel.Equipped;
            persistentState.WeaponType = WeaponModel.WeaponType;
            persistentState.WeaponTier = WeaponModel.Tier;
            persistentState.WeaponSize = WeaponModel.Size;
            persistentState.WeaponDurability = WeaponModel.Durability;
            persistentState.WeaponEssenceType = WeaponModel.EssenceType;
            persistentState.WeaponEquipped = WeaponModel.Equipped;
            persistentState.WeaponEquipmentInitialized = true;
            // Campos antiguos conservados unicamente para migracion regresiva.
            EquippedWeaponBaseWeight = WeaponModel.GetTierOneWeightFor(
                WeaponModel.WeaponType
            );
            EquippedWeaponTier = WeaponModel.Tier;
            EquippedWeaponSize = WeaponModel.Size;
            WeaponWeightInitialized = true;
            persistentState.EquippedWeaponBaseWeight = EquippedWeaponBaseWeight;
            persistentState.EquippedWeaponTier = EquippedWeaponTier;
            persistentState.EquippedWeaponSize = EquippedWeaponSize;
            persistentState.WeaponWeightInitialized = WeaponWeightInitialized;
            persistentState.MarkCurrentEquipmentOwned();
        }

        persistentState.StoredHealth = health;
        persistentState.StoredAnima = CurrentAnima;
        persistentState.StoredAir = CurrentAir;
        persistentState.StoredAdrenaline = CurrentAdrenaline;
        persistentState.StoredLucidity = CurrentLucidity;
        persistentState.StoredHunger = CurrentHunger;
        persistentState.StoredThirst = CurrentThirst;
        persistentState.StoredSleep = CurrentSleep;
    }

    bool RestorePersistentCharacterState()
    {
        CaelumPersistentCharacterState persistentState = GetPersistentCharacterState(false);
        if (persistentState == null || !persistentState.ProfileCommitted) { return false; }
        persistentState.EnsureEquipmentSizeInitialized();

        CharacterProfile.Race = persistentState.Race;
        CharacterProfile.FirstClass = persistentState.FirstClass;
        CharacterProfile.SecondClass = persistentState.SecondClass;
        CharacterProfile.Sex = persistentState.Sex;
        CharacterProfile.HeightChoice = persistentState.HeightChoice;
        for (int layer = 0; layer < CaelumConstants.ATTRIBUTE_LAYER_COUNT; layer++)
        {
            CharacterAllocation.LayerBonus[layer] = persistentState.LayerBonus[layer];
        }
        for (int attribute = 0; attribute < CaelumConstants.PRIMARY_ATTRIBUTE_COUNT; attribute++)
        {
            CharacterAllocation.AttributeBonus[attribute] = persistentState.AttributeBonus[attribute];
        }

        if (persistentState.EquipmentInitialized && ArmorModel != null
            && ShieldModel != null && WeaponModel != null)
        {
            for (int slot = 0; slot < CaelumConstants.ARMOR_SLOT_COUNT; slot++)
            {
                if (persistentState.ArmorType[slot]
                    != CaelumConstants.ARMOR_TYPE_BASE_CLOTHING)
                {
                    persistentState.RegisterOwnedArmor(
                        slot,
                        persistentState.ArmorType[slot],
                        persistentState.ArmorTier[slot],
                        persistentState.ArmorSize[slot],
                        persistentState.ArmorDurability[slot]
                    );
                    persistentState.StoreOwnedArmorDurability(
                        slot,
                        persistentState.ArmorType[slot],
                        persistentState.ArmorTier[slot],
                        persistentState.ArmorSize[slot],
                        persistentState.ArmorDurability[slot]
                    );
                }
                ArmorModel.ArmorType[slot] = persistentState.ArmorType[slot];
                ArmorModel.Tier[slot] = persistentState.ArmorTier[slot];
                ArmorModel.Size[slot] = persistentState.ArmorSize[slot];
                ArmorModel.Durability[slot] = persistentState.ArmorDurability[slot];
            }
            ArmorModel.SelectedSlot = persistentState.ArmorSelectedSlot;
            ArmorModel.Initialized = true;
            ShieldModel.ShieldType = persistentState.ShieldType;
            ShieldModel.Tier = persistentState.ShieldTier;
            ShieldModel.Size = persistentState.ShieldSize;
            ShieldModel.Durability = persistentState.ShieldDurability;
            ShieldModel.Equipped = persistentState.ShieldEquipped;
            if (ShieldModel.Equipped)
            {
                persistentState.RegisterOwnedShield(
                    persistentState.ShieldType,
                    persistentState.ShieldTier,
                    persistentState.ShieldSize,
                    persistentState.ShieldDurability
                );
                persistentState.StoreOwnedShieldDurability(
                    persistentState.ShieldType,
                    persistentState.ShieldTier,
                    persistentState.ShieldSize,
                    persistentState.ShieldDurability
                );
            }
            ShieldModel.Initialized = true;
            WeaponModel.WeaponType = persistentState.WeaponType;
            WeaponModel.Tier = persistentState.WeaponTier;
            WeaponModel.Size = persistentState.WeaponSize;
            WeaponModel.Durability = persistentState.WeaponDurability;
            persistentState.EnsureWeaponEssenceInitialized();
            WeaponModel.EssenceType = Clamp(
                persistentState.WeaponEssenceType,
                0,
                CaelumConstants.ESSENCE_TYPE_COUNT - 1
            );
            WeaponModel.Equipped = persistentState.WeaponEquipped;
            WeaponModel.Initialized = true;
            if (WeaponModel.Equipped)
            {
                persistentState.RegisterOwnedWeapon(
                    WeaponModel.WeaponType,
                    WeaponModel.Tier,
                    WeaponModel.Size,
                    WeaponModel.Durability
                );
                persistentState.StoreOwnedWeaponDurability(
                    WeaponModel.WeaponType,
                    WeaponModel.Tier,
                    WeaponModel.Size,
                    WeaponModel.Durability
                );
                persistentState.SetWeaponInMagicBox(
                    WeaponModel.WeaponType,
                    WeaponModel.Tier,
                    WeaponModel.Size,
                    false
                );
            }
            EquippedWeaponBaseWeight = WeaponModel.GetTierOneWeightFor(
                WeaponModel.WeaponType
            );
            EquippedWeaponTier = WeaponModel.Tier;
            EquippedWeaponSize = WeaponModel.Size;
            WeaponWeightInitialized = true;
        }

        MigrateLegacyEquipmentToNativeInventory(persistentState);
        CharacterCreationComplete = true;
        CreationWizardOpen = false;
        CreationProfileBackup = null;
        CreationAllocationBackup = null;
        ApplyCharacterProfile();
        CaelumMaximumHealth = Max(1, int(DerivedStats.MaximumHealth));
        health = Clamp(persistentState.StoredHealth, 1, CaelumMaximumHealth);
        if (player != null) { player.health = health; }
        CurrentAnima = Clamp(persistentState.StoredAnima, 0.0, DerivedStats.MaximumAnima);
        CurrentAir = Clamp(persistentState.StoredAir, 0.0, DerivedStats.MaximumAir);
        CurrentAdrenaline = Clamp(
            persistentState.StoredAdrenaline, 0.0, DerivedStats.MaximumAdrenaline
        );
        CurrentLucidity = Clamp(
            persistentState.StoredLucidity, 0.0, CaelumConstants.MAXIMUM_LUCIDITY
        );
        CurrentHunger = Clamp(persistentState.StoredHunger, 0.0, CaelumConstants.SURVIVAL_MAXIMUM);
        CurrentThirst = Clamp(persistentState.StoredThirst, 0.0, CaelumConstants.SURVIVAL_MAXIMUM);
        CurrentSleep = Clamp(persistentState.StoredSleep, 0.0, CaelumConstants.SURVIVAL_MAXIMUM);
        HealthResourceInitialized = true;
        AnimaResourceInitialized = true;
        AirResourceInitialized = true;
        AdrenalineResourceInitialized = true;
        LucidityResourceInitialized = true;
        SurvivalResourcesInitialized = true;
        UpdateHealthStateEffects();
        UpdateAirStateEffects();
        UpdateLucidityState();
        UpdateSurvivalStates();
        return true;
    }

    CaelumEquipmentItem FindNativeEquipmentItem(
        int kind, int itemType, int armorSlot, int tier, int equipmentSize
    )
    {
        for (Inventory cursor = Inv; cursor != null; cursor = cursor.Inv)
        {
            CaelumEquipmentItem item = CaelumEquipmentItem(cursor);
            if (item != null && item.Matches(
                kind, itemType, armorSlot, tier, equipmentSize
            ))
            {
                return item;
            }
        }
        return null;
    }

    CaelumEquipmentItem FindNativeMagicWeaponItem(
        int weaponType, int essenceType, int tier, int equipmentSize
    )
    {
        for (Inventory cursor = Inv; cursor != null; cursor = cursor.Inv)
        {
            CaelumEquipmentItem item = CaelumEquipmentItem(cursor);
            if (item != null && item.MatchesMagicWeapon(
                weaponType, essenceType, tier, equipmentSize
            ))
            {
                return item;
            }
        }
        return null;
    }

    bool HasEquippedNativeWeaponType(int weaponType)
    {
        for (Inventory cursor = Inv; cursor != null; cursor = cursor.Inv)
        {
            CaelumEquipmentItem item = CaelumEquipmentItem(cursor);
            if (item != null
                && item.EquipmentKind == CaelumConstants.EQUIPMENT_KIND_WEAPON
                && item.ItemType == weaponType
                && item.Equipped
                && !item.InMagicBox)
            {
                return true;
            }
        }
        return false;
    }


    bool HasEquippedNativeMagicWeapon(
        int weaponType, int essenceType, int tier
    )
    {
        for (Inventory cursor = Inv; cursor != null; cursor = cursor.Inv)
        {
            CaelumEquipmentItem item = CaelumEquipmentItem(cursor);
            if (item != null
                && item.EquipmentKind == CaelumConstants.EQUIPMENT_KIND_WEAPON
                && item.ItemType == weaponType
                && item.EssenceType == essenceType
                && item.Tier == tier
                && item.Equipped
                && !item.InMagicBox)
            {
                return true;
            }
        }
        return false;
    }

    bool ActivateEquippedMagicWeapon(
        int requestedWeaponType,
        int requestedEssenceType,
        int requestedTier
    )
    {
        if (WeaponModel == null) { return false; }

        int weaponType = Clamp(
            requestedWeaponType, 0, CaelumConstants.WEAPON_TYPE_COUNT - 1
        );
        int essenceType = Clamp(
            requestedEssenceType, 0, CaelumConstants.ESSENCE_TYPE_COUNT - 1
        );
        int tier = Clamp(requestedTier, 1, 3);

        if (WeaponModel.Equipped
            && (WeaponModel.WeaponType != weaponType
                || WeaponModel.EssenceType != essenceType
                || WeaponModel.Tier != tier))
        {
            CancelWeaponCharge();
            if (CombatBlockModeActive) { CancelCombatBlockMode(); }
        }

        if (WeaponModel.Equipped
            && WeaponModel.WeaponType == weaponType
            && WeaponModel.EssenceType == essenceType
            && WeaponModel.Tier == tier
            && HasEquippedNativeMagicWeapon(weaponType, essenceType, tier))
        {
            return true;
        }

        if (StaffCastPending) { CancelPendingStaffCast(false); }

        for (Inventory cursor = Inv; cursor != null; cursor = cursor.Inv)
        {
            CaelumEquipmentItem item = CaelumEquipmentItem(cursor);
            if (item != null
                && item.EquipmentKind == CaelumConstants.EQUIPMENT_KIND_WEAPON
                && item.ItemType == weaponType
                && item.EssenceType == essenceType
                && item.Tier == tier
                && item.Equipped
                && !item.InMagicBox)
            {
                WeaponModel.WeaponType = weaponType;
                WeaponModel.Tier = tier;
                WeaponModel.Size = item.EquipmentSize;
                WeaponModel.Durability = item.Durability;
                WeaponModel.EssenceType = essenceType;
                SelectedEssenceType = essenceType;
                WeaponModel.Equipped = true;
                EquippedWeaponCooldownRemaining = 0.0;
                ApplyCharacterProfile();
                PersistCharacterState();
                RefreshEquipmentSelectionPreview();
                return true;
            }
        }
        return false;
    }

    void PerformMagicWeaponPrimaryAttack(
        int weaponType, int essenceType, int tier
    )
    {
        if (ActivateEquippedMagicWeapon(weaponType, essenceType, tier))
        {
            PerformEquippedWeaponPrimaryAttack();
        }
    }

    void PerformMagicWeaponSecondaryAttack(
        int weaponType, int essenceType, int tier
    )
    {
        if (ActivateEquippedMagicWeapon(weaponType, essenceType, tier))
        {
            PerformEquippedWeaponSecondaryAttack();
        }
    }

    int CountNativeMagicBoxSlots()
    {
        int total = 0;
        for (Inventory cursor = Inv; cursor != null; cursor = cursor.Inv)
        {
            CaelumEquipmentItem item = CaelumEquipmentItem(cursor);
            if (item != null && item.InMagicBox) { total++; }
        }
        for (Inventory cursor = Inv; cursor != null; cursor = cursor.Inv)
        {
            CaelumCarbineAmmo ammunition = CaelumCarbineAmmo(cursor);
            if (ammunition != null && ammunition.Amount > 0
                && ammunition.InMagicBox)
            {
                total++;
            }
        }
        for (Inventory cursor = Inv; cursor != null; cursor = cursor.Inv)
        {
            CaelumConsumableItem consumable = CaelumConsumableItem(cursor);
            if (consumable != null && consumable.Amount > 0
                && consumable.InMagicBox)
            {
                total++;
            }
        }
        for (Inventory cursor = Inv; cursor != null; cursor = cursor.Inv)
        {
            CaelumSpecialInventoryItem specialItem =
                CaelumSpecialInventoryItem(cursor);
            if (specialItem != null && specialItem.Amount > 0
                && specialItem.InMagicBox)
            {
                total++;
            }
        }
        return total;
    }

    CaelumConsumableItem FindNativeConsumableItem(int consumableType)
    {
        for (Inventory cursor = Inv; cursor != null; cursor = cursor.Inv)
        {
            CaelumConsumableItem item = CaelumConsumableItem(cursor);
            if (item != null && item.GetConsumableType() == consumableType)
            {
                return item;
            }
        }
        return null;
    }

    Inventory FindNativeAmmunition(int ammunitionType)
    {
        if (ammunitionType == CaelumConstants.AMMUNITION_ARROW)
        {
            return FindInventory("CaelumArrowAmmo");
        }
        if (ammunitionType == CaelumConstants.AMMUNITION_BOLT)
        {
            return FindInventory("CaelumBoltAmmo");
        }
        return FindInventory("CaelumCarbineAmmo");
    }


    // Añade unidades de jabalina mediante GiveInventoryType sin pasar nunca
    // una pila por Amount = 0. Esta ruta se usa tanto para pickups recuperados
    // como para el generador DEV, y verifica la pila real antes de informar éxito.
    bool AcquireJavelinAmmunition(int ammunitionType, int incomingAmount)
    {
        if (incomingAmount <= 0 || DerivedStats == null) { return false; }

        CaelumCarbineAmmo existing = CaelumCarbineAmmo(
            FindNativeAmmunition(ammunitionType)
        );
        bool storeInMagicBox = existing != null && existing.InMagicBox;

        if (existing != null)
        {
            if (!PrepareNativeAmmoStackPickup(existing, incomingAmount))
            {
                return false;
            }
            storeInMagicBox = existing.InMagicBox;
        }
        else
        {
            RefreshCarriedInventorySummary();
            double incomingWeight = incomingAmount
                * GetAmmunitionUnitWeight(ammunitionType);
            if (!CanAddWeightToPersonalInventory(incomingWeight))
            {
                if (CountNativeMagicBoxSlots() >= DerivedStats.MagicBoxCapacity)
                {
                    return false;
                }
                storeInMagicBox = true;
            }
        }

        // IMPORTANTE: no usar GiveInventoryType con las clases de jabalina.
        // Su TryPickup llama nuevamente a AcquireJavelinAmmunition y generaría
        // recursión infinita (stack overflow). Modificamos la pila directamente.
        CaelumCarbineAmmo result = existing;
        bool createdNewStack = false;

        if (result != null)
        {
            result.Amount += incomingAmount;
        }
        else
        {
            Name ammoClass = GetAmmunitionClassName(ammunitionType);
            result = CaelumCarbineAmmo(Spawn(ammoClass, Pos, NO_REPLACE));
            if (result == null) { return false; }

            // La clase nace con Amount 1. Sustituimos ese valor por la cantidad
            // que realmente entra antes de adjuntarla al inventario del jugador.
            result.Amount = incomingAmount;
            AddInventory(result);
            createdNewStack = true;
        }

        if (result == null || result.Amount <= 0) { return false; }
        result.InMagicBox = storeInMagicBox;
        LastEquipmentPickupWasNew = createdNewStack;
        LastEquipmentPickupWentToMagicBox = storeInMagicBox;
        OnNativeInventoryChanged();
        return true;
    }

    CaelumSpecialInventoryItem FindNativeSpecialItem(
        int specialCategory, int specialType, int specialTier = 0
    )
    {
        for (Inventory cursor = Inv; cursor != null; cursor = cursor.Inv)
        {
            CaelumSpecialInventoryItem item =
                CaelumSpecialInventoryItem(cursor);
            if (item != null
                && item.GetSpecialCategory() == specialCategory
                && item.GetSpecialType() == specialType
                && (specialCategory != CaelumConstants.EQUIPMENT_KIND_MATERIAL
                    || item.GetSpecialTier()
                        == CaelumMaterialRules.ResolveTier(
                            specialType, specialTier
                        )))
            {
                return item;
            }
        }
        return null;
    }

    CaelumWeightedKey FindNativeKey(int keyType)
    {
        for (Inventory cursor = Inv; cursor != null; cursor = cursor.Inv)
        {
            CaelumWeightedKey keyItem = CaelumWeightedKey(cursor);
            if (keyItem != null && keyItem.GetKeyType() == keyType)
            {
                return keyItem;
            }
        }
        return null;
    }

    bool PrepareNativeEquipmentPickup(CaelumEquipmentItem item)
    {
        if (item == null || DerivedStats == null) { return false; }
        RefreshCarriedInventorySummary();
        item.Equipped = false;
        item.InMagicBox = false;
        if (!CanAddWeightToPersonalInventory(item.UnitWeight))
        {
            if (CountNativeMagicBoxSlots() >= DerivedStats.MagicBoxCapacity)
            {
                return false;
            }
            item.InMagicBox = true;
        }
        LastEquipmentPickupWasNew = true;
        LastEquipmentPickupWentToMagicBox = item.InMagicBox;
        return true;
    }

    bool PrepareNativeAmmoPickup(CaelumCarbineAmmo ammunition)
    {
        if (ammunition == null || DerivedStats == null) { return false; }
        // Si ya existe una pila, HandlePickup decide usando el estado de ella.
        for (Inventory cursor = Inv; cursor != null; cursor = cursor.Inv)
        {
            CaelumCarbineAmmo existing = CaelumCarbineAmmo(cursor);
            if (existing != null
                && existing.GetAmmoType() == ammunition.GetAmmoType())
            {
                return true;
            }
        }
        RefreshCarriedInventorySummary();
        ammunition.InMagicBox = false;
        double incomingWeight = ammunition.Amount * ammunition.GetUnitWeight();
        if (!CanAddWeightToPersonalInventory(incomingWeight))
        {
            if (CountNativeMagicBoxSlots() >= DerivedStats.MagicBoxCapacity)
            {
                return false;
            }
            ammunition.InMagicBox = true;
        }
        LastEquipmentPickupWasNew = true;
        LastEquipmentPickupWentToMagicBox = ammunition.InMagicBox;
        return true;
    }

    bool PrepareNativeAmmoStackPickup(
        CaelumCarbineAmmo ammunition, int incomingAmount
    )
    {
        if (ammunition == null || DerivedStats == null) { return false; }
        if (ammunition.InMagicBox) { return true; }
        RefreshCarriedInventorySummary();
        double incomingWeight = Max(0, incomingAmount)
            * ammunition.GetUnitWeight();
        if (CanAddWeightToPersonalInventory(incomingWeight)) { return true; }
        if (CountNativeMagicBoxSlots() >= DerivedStats.MagicBoxCapacity)
        {
            return false;
        }
        // La munición es una sola pila: al desbordar, la pila completa pasa a
        // ocupar un slot y todo su Amount queda sin peso.
        ammunition.InMagicBox = true;
        LastEquipmentPickupWentToMagicBox = true;
        return true;
    }

    bool PrepareNativeConsumablePickup(CaelumConsumableItem consumable)
    {
        if (consumable == null || DerivedStats == null) { return false; }
        CaelumConsumableItem existing = FindNativeConsumableItem(
            consumable.GetConsumableType()
        );
        if (existing != null)
        {
            return PrepareNativeConsumableStackPickup(
                existing, consumable.Amount
            );
        }
        RefreshCarriedInventorySummary();
        consumable.InMagicBox = false;
        if (!CanAddWeightToPersonalInventory(consumable.GetCarriedWeight()))
        {
            if (CountNativeMagicBoxSlots() >= DerivedStats.MagicBoxCapacity)
            {
                return false;
            }
            consumable.InMagicBox = true;
        }
        LastEquipmentPickupWasNew = true;
        LastEquipmentPickupWentToMagicBox = consumable.InMagicBox;
        return true;
    }

    bool PrepareNativeConsumableStackPickup(
        CaelumConsumableItem consumable, int incomingAmount
    )
    {
        if (consumable == null || DerivedStats == null) { return false; }
        if (consumable.InMagicBox) { return true; }
        RefreshCarriedInventorySummary();
        double incomingWeight = Max(0, incomingAmount)
            * consumable.GetUnitWeight();
        if (CanAddWeightToPersonalInventory(incomingWeight)) { return true; }
        if (CountNativeMagicBoxSlots() >= DerivedStats.MagicBoxCapacity)
        {
            return false;
        }
        // Una pila completa ocupa un unico slot, sin importar su Amount.
        consumable.InMagicBox = true;
        LastEquipmentPickupWentToMagicBox = true;
        return true;
    }

    bool PrepareNativeSpecialPickup(CaelumSpecialInventoryItem specialItem)
    {
        if (specialItem == null || DerivedStats == null) { return false; }
        CaelumSpecialInventoryItem existing = FindNativeSpecialItem(
            specialItem.GetSpecialCategory(), specialItem.GetSpecialType(),
            specialItem.GetSpecialTier()
        );
        if (existing != null)
        {
            if (specialItem.GetSpecialCategory()
                == CaelumConstants.EQUIPMENT_KIND_MATERIAL)
            {
                return PrepareNativeSpecialStackPickup(
                    existing, specialItem.Amount
                );
            }
            return true;
        }
        RefreshCarriedInventorySummary();
        specialItem.InMagicBox = false;
        if (!CanAddWeightToPersonalInventory(specialItem.GetCarriedWeight()))
        {
            if (CountNativeMagicBoxSlots() >= DerivedStats.MagicBoxCapacity)
            {
                return false;
            }
            specialItem.InMagicBox = true;
        }
        LastEquipmentPickupWasNew = true;
        LastEquipmentPickupWentToMagicBox = specialItem.InMagicBox;
        return true;
    }

    bool PrepareNativeSpecialStackPickup(
        CaelumSpecialInventoryItem specialItem, int incomingAmount
    )
    {
        if (specialItem == null || DerivedStats == null) { return false; }
        if (specialItem.InMagicBox) { return true; }
        RefreshCarriedInventorySummary();
        double incomingWeight = Max(0, incomingAmount)
            * specialItem.GetUnitWeight();
        if (CanAddWeightToPersonalInventory(incomingWeight)) { return true; }
        if (CountNativeMagicBoxSlots() >= DerivedStats.MagicBoxCapacity)
        {
            return false;
        }
        specialItem.InMagicBox = true;
        LastEquipmentPickupWentToMagicBox = true;
        return true;
    }

    bool PrepareNativeKeyPickup(CaelumWeightedKey keyItem)
    {
        if (keyItem == null || DerivedStats == null) { return false; }
        // Key ya impide duplicados por clase. Si existe, el pickup nativo
        // decide el resultado sin reservar peso otra vez.
        if (FindNativeKey(keyItem.GetKeyType()) != null) { return true; }
        RefreshCarriedInventorySummary();
        if (!CanAddWeightToPersonalInventory(keyItem.GetCarriedWeight()))
        {
            return false;
        }
        LastEquipmentPickupWasNew = true;
        LastEquipmentPickupWentToMagicBox = false;
        return true;
    }

    void OnNativeInventoryChanged()
    {
        ApplyCharacterProfile();
        RefreshEquipmentSelectionPreview();
        if (CraftingMenuOpen) { RefreshCraftingPreview(); }
        PersistCharacterState();
    }

    void MigrateLegacyEquipmentToNativeInventory(
        CaelumPersistentCharacterState persistentState
    )
    {
        if (persistentState == null
            || persistentState.NativeEquipmentMigrationComplete) { return; }
        for (Inventory cursor = Inv; cursor != null; cursor = cursor.Inv)
        {
            if (CaelumEquipmentItem(cursor) != null)
            {
                persistentState.NativeEquipmentMigrationComplete = true;
                return;
            }
        }
        persistentState.EnsureEquipmentSizeInitialized();
        for (int slot = 0; slot < CaelumConstants.ARMOR_SLOT_COUNT; slot++)
        {
            for (int armorType = 0;
                armorType < CaelumConstants.ARMOR_EQUIPPABLE_TYPE_COUNT;
                armorType++)
            {
                for (int tier = 1; tier <= 3; tier++)
                {
                    for (int equipmentSize = 0;
                        equipmentSize < CaelumConstants.EQUIPMENT_SIZE_COUNT;
                        equipmentSize++)
                    {
                        if (!persistentState.OwnsArmor(
                            slot, armorType, tier, equipmentSize
                        )) { continue; }
                        CaelumEquipmentItem item = CaelumEquipmentItem(
                            Spawn("CaelumArmorPickup", Pos, NO_REPLACE)
                        );
                        if (item == null) { continue; }
                        item.EquipmentKind = CaelumConstants.EQUIPMENT_KIND_ARMOR;
                        item.ItemType = armorType;
                        item.ArmorSlot = slot;
                        item.Tier = tier;
                        item.EquipmentSize = equipmentSize;
                        item.Durability = persistentState.GetOwnedArmorDurability(
                            slot, armorType, tier, equipmentSize
                        );
                        item.UnitWeight = ArmorModel.GetWeightFor(
                            slot, armorType, tier, equipmentSize
                        );
                        item.Equipped = ArmorModel.ArmorType[slot] == armorType
                            && ArmorModel.Tier[slot] == tier
                            && ArmorModel.Size[slot] == equipmentSize;
                        item.InMagicBox = persistentState.IsArmorInMagicBox(
                            slot, armorType, tier, equipmentSize
                        );
                        item.AttachToOwner(self);
                    }
                }
            }
        }
        for (int shieldType = 0;
            shieldType < CaelumConstants.SHIELD_TYPE_COUNT;
            shieldType++)
        {
            for (int tier = 1; tier <= 3; tier++)
            {
                for (int equipmentSize = 0;
                    equipmentSize < CaelumConstants.EQUIPMENT_SIZE_COUNT;
                    equipmentSize++)
                {
                    if (!persistentState.OwnsShield(
                        shieldType, tier, equipmentSize
                    )) { continue; }
                    CaelumEquipmentItem item = CaelumEquipmentItem(
                        Spawn("CaelumShieldPickup", Pos, NO_REPLACE)
                    );
                    if (item == null) { continue; }
                    item.EquipmentKind = CaelumConstants.EQUIPMENT_KIND_SHIELD;
                    item.ItemType = shieldType;
                    item.ArmorSlot = -1;
                    item.Tier = tier;
                    item.EquipmentSize = equipmentSize;
                    item.Durability = persistentState.GetOwnedShieldDurability(
                        shieldType, tier, equipmentSize
                    );
                    item.UnitWeight = ShieldModel.GetWeightFor(
                        shieldType, tier, equipmentSize
                    );
                    item.Equipped = ShieldModel.Equipped
                        && ShieldModel.ShieldType == shieldType
                        && ShieldModel.Tier == tier
                        && ShieldModel.Size == equipmentSize;
                    item.InMagicBox = persistentState.IsShieldInMagicBox(
                        shieldType, tier, equipmentSize
                    );
                    item.AttachToOwner(self);
                }
            }
        }
        for (int weaponType = 0;
            weaponType < CaelumConstants.WEAPON_TYPE_COUNT;
            weaponType++)
        {
            for (int tier = 1; tier <= 3; tier++)
            {
                for (int equipmentSize = 0;
                    equipmentSize < CaelumConstants.EQUIPMENT_SIZE_COUNT;
                    equipmentSize++)
                {
                    if (!persistentState.OwnsWeapon(
                        weaponType, tier, equipmentSize
                    )) { continue; }
                    CaelumEquipmentItem item = CaelumEquipmentItem(
                        Spawn("CaelumWeaponPickup", Pos, NO_REPLACE)
                    );
                    if (item == null) { continue; }
                    item.EquipmentKind = CaelumConstants.EQUIPMENT_KIND_WEAPON;
                    item.ItemType = weaponType;
                    item.ArmorSlot = -1;
                    item.Tier = tier;
                    item.EquipmentSize = equipmentSize;
                    item.Durability = persistentState.GetOwnedWeaponDurability(
                        weaponType, tier, equipmentSize
                    );
                    item.EssenceType = persistentState.GetWeaponEssenceType(
                        weaponType, tier, equipmentSize
                    );
                    item.UnitWeight = WeaponModel.GetWeightFor(
                        weaponType, tier, equipmentSize
                    );
                    item.Equipped = persistentState.IsWeaponEquipped(
                        weaponType, tier, equipmentSize
                    );
                    item.InMagicBox = persistentState.IsWeaponInMagicBox(
                        weaponType, tier, equipmentSize
                    );
                    item.AttachToOwner(self);
                }
            }
        }
        persistentState.NativeEquipmentMigrationComplete = true;
    }

    double GetEquippedWeaponLoadWeight()
    {
        double total = 0.0;
        for (Inventory cursor = Inv; cursor != null; cursor = cursor.Inv)
        {
            CaelumEquipmentItem item = CaelumEquipmentItem(cursor);
            if (item != null
                && item.EquipmentKind == CaelumConstants.EQUIPMENT_KIND_WEAPON
                && item.Equipped && !item.InMagicBox)
            {
                total += item.UnitWeight;
            }
        }
        return total;
    }

    int GetWeaponFamilyForType(int weaponType)
    {
        if (WeaponModel != null && WeaponModel.IsMagicalType(weaponType))
        {
            return 6;
        }
        int catalogueWeapon =
            CaelumCraftingRules.GetCatalogueWeaponForPlayableType(weaponType);
        if (catalogueWeapon < 0) { return 0; }
        return CaelumWeaponCatalogue.GetFamily(catalogueWeapon);
    }

    bool HasEquippedWeaponFamily(int family)
    {
        for (int weaponType = 0;
            weaponType < CaelumConstants.WEAPON_TYPE_COUNT; weaponType++)
        {
            if (GetWeaponFamilyForType(weaponType) == family
                && HasEquippedNativeWeaponType(weaponType))
            {
                return true;
            }
        }
        return false;
    }

    bool ActivateEquippedWeaponFamily(int family)
    {
        if (WeaponModel != null && WeaponModel.Equipped
            && GetWeaponFamilyForType(WeaponModel.WeaponType) == family
            && HasEquippedNativeWeaponType(WeaponModel.WeaponType))
        {
            return true;
        }
        for (int weaponType = 0;
            weaponType < CaelumConstants.WEAPON_TYPE_COUNT; weaponType++)
        {
            if (GetWeaponFamilyForType(weaponType) == family
                && ActivateEquippedWeaponType(weaponType))
            {
                return true;
            }
        }
        return false;
    }

    void EnsurePhysicalWeaponSelector(
        int weaponType, class<Inventory> selectorClass
    )
    {
        bool shouldExist = HasEquippedNativeWeaponType(weaponType);
        if (shouldExist && FindInventory(selectorClass) == null)
        {
            GiveInventoryType(selectorClass);
        }
        else if (!shouldExist)
        {
            TakeInventory(selectorClass, 1);
        }
    }

    void EnsureMagicWeaponSelector(
        int weaponType,
        int essenceType,
        int tier,
        class<Inventory> selectorClass
    )
    {
        bool shouldExist = HasEquippedNativeMagicWeapon(
            weaponType, essenceType, tier
        );
        if (shouldExist && FindInventory(selectorClass) == null)
        {
            GiveInventoryType(selectorClass);
        }
        else if (!shouldExist)
        {
            TakeInventory(selectorClass, 1);
        }
    }

    // Los selectores físicos conservan sus slots. Las armas mágicas se
    // agrupan por elemento: 6 Fuego, 7 Agua, 8 Tierra, 9 Aire y 0
    // Quintaesencia (el slot 0 representa la décima familia numérica).
    void EnsureWeaponFamilySelectors()
    {
        if (!CharacterCreationComplete) { return; }
        EnsurePhysicalWeaponSelector(
            CaelumConstants.WEAPON_TYPE_DAGGER,
            "CaelumDaggerSelectorWeapon"
        );
        EnsurePhysicalWeaponSelector(
            CaelumConstants.WEAPON_TYPE_HATCHET,
            "CaelumHatchetSelectorWeapon"
        );
        EnsurePhysicalWeaponSelector(
            CaelumConstants.WEAPON_TYPE_MACHETE,
            "CaelumMacheteSelectorWeapon"
        );
        EnsurePhysicalWeaponSelector(
            CaelumConstants.WEAPON_TYPE_JAVELIN,
            "CaelumJavelinSelectorWeapon"
        );
        EnsurePhysicalWeaponSelector(
            CaelumConstants.WEAPON_TYPE_SWORD,
            "CaelumSwordSelectorWeapon"
        );
        EnsurePhysicalWeaponSelector(
            CaelumConstants.WEAPON_TYPE_AXE,
            "CaelumAxeSelectorWeapon"
        );
        EnsurePhysicalWeaponSelector(
            CaelumConstants.WEAPON_TYPE_FLAIL,
            "CaelumFlailSelectorWeapon"
        );
        EnsurePhysicalWeaponSelector(
            CaelumConstants.WEAPON_TYPE_SPEAR,
            "CaelumSpearSelectorWeapon"
        );
        EnsurePhysicalWeaponSelector(
            CaelumConstants.WEAPON_TYPE_GREATSWORD,
            "CaelumGreatswordSelectorWeapon"
        );
        EnsurePhysicalWeaponSelector(
            CaelumConstants.WEAPON_TYPE_WAR_AXE,
            "CaelumWarAxeSelectorWeapon"
        );
        EnsurePhysicalWeaponSelector(
            CaelumConstants.WEAPON_TYPE_HALBERD,
            "CaelumHalberdSelectorWeapon"
        );
        EnsurePhysicalWeaponSelector(
            CaelumConstants.WEAPON_TYPE_GIANT_GAUNTLETS,
            "CaelumGiantGauntletsSelectorWeapon"
        );
        EnsurePhysicalWeaponSelector(
            CaelumConstants.WEAPON_TYPE_STANDARD_BOW,
            "CaelumStandardBowSelectorWeapon"
        );
        EnsurePhysicalWeaponSelector(
            CaelumConstants.WEAPON_TYPE_CARBINE,
            "CaelumCarbineSelectorWeapon"
        );
        EnsurePhysicalWeaponSelector(
            CaelumConstants.WEAPON_TYPE_LONGBOW,
            "CaelumLongbowSelectorWeapon"
        );
        EnsurePhysicalWeaponSelector(
            CaelumConstants.WEAPON_TYPE_CROSSBOW,
            "CaelumCrossbowSelectorWeapon"
        );
        EnsureMagicWeaponSelector(
            CaelumConstants.WEAPON_TYPE_STAFF,
            CaelumConstants.ESSENCE_FIRE,
            1,
            "CaelumFireStaffT1Weapon"
        );
        EnsureMagicWeaponSelector(
            CaelumConstants.WEAPON_TYPE_STAFF,
            CaelumConstants.ESSENCE_FIRE,
            2,
            "CaelumFireStaffT2Weapon"
        );
        EnsureMagicWeaponSelector(
            CaelumConstants.WEAPON_TYPE_STAFF,
            CaelumConstants.ESSENCE_FIRE,
            3,
            "CaelumFireStaffT3Weapon"
        );
        EnsureMagicWeaponSelector(
            CaelumConstants.WEAPON_TYPE_BELL,
            CaelumConstants.ESSENCE_FIRE,
            1,
            "CaelumFireBellT1Weapon"
        );
        EnsureMagicWeaponSelector(
            CaelumConstants.WEAPON_TYPE_BELL,
            CaelumConstants.ESSENCE_FIRE,
            2,
            "CaelumFireBellT2Weapon"
        );
        EnsureMagicWeaponSelector(
            CaelumConstants.WEAPON_TYPE_BELL,
            CaelumConstants.ESSENCE_FIRE,
            3,
            "CaelumFireBellT3Weapon"
        );
        EnsureMagicWeaponSelector(
            CaelumConstants.WEAPON_TYPE_BOOK,
            CaelumConstants.ESSENCE_FIRE,
            1,
            "CaelumFireBookT1Weapon"
        );
        EnsureMagicWeaponSelector(
            CaelumConstants.WEAPON_TYPE_BOOK,
            CaelumConstants.ESSENCE_FIRE,
            2,
            "CaelumFireBookT2Weapon"
        );
        EnsureMagicWeaponSelector(
            CaelumConstants.WEAPON_TYPE_BOOK,
            CaelumConstants.ESSENCE_FIRE,
            3,
            "CaelumFireBookT3Weapon"
        );
        EnsureMagicWeaponSelector(
            CaelumConstants.WEAPON_TYPE_STATUETTE,
            CaelumConstants.ESSENCE_FIRE,
            1,
            "CaelumFireStatuetteT1Weapon"
        );
        EnsureMagicWeaponSelector(
            CaelumConstants.WEAPON_TYPE_STATUETTE,
            CaelumConstants.ESSENCE_FIRE,
            2,
            "CaelumFireStatuetteT2Weapon"
        );
        EnsureMagicWeaponSelector(
            CaelumConstants.WEAPON_TYPE_STATUETTE,
            CaelumConstants.ESSENCE_FIRE,
            3,
            "CaelumFireStatuetteT3Weapon"
        );
        EnsureMagicWeaponSelector(
            CaelumConstants.WEAPON_TYPE_STAFF,
            CaelumConstants.ESSENCE_WATER,
            1,
            "CaelumWaterStaffT1Weapon"
        );
        EnsureMagicWeaponSelector(
            CaelumConstants.WEAPON_TYPE_STAFF,
            CaelumConstants.ESSENCE_WATER,
            2,
            "CaelumWaterStaffT2Weapon"
        );
        EnsureMagicWeaponSelector(
            CaelumConstants.WEAPON_TYPE_STAFF,
            CaelumConstants.ESSENCE_WATER,
            3,
            "CaelumWaterStaffT3Weapon"
        );
        EnsureMagicWeaponSelector(
            CaelumConstants.WEAPON_TYPE_BELL,
            CaelumConstants.ESSENCE_WATER,
            1,
            "CaelumWaterBellT1Weapon"
        );
        EnsureMagicWeaponSelector(
            CaelumConstants.WEAPON_TYPE_BELL,
            CaelumConstants.ESSENCE_WATER,
            2,
            "CaelumWaterBellT2Weapon"
        );
        EnsureMagicWeaponSelector(
            CaelumConstants.WEAPON_TYPE_BELL,
            CaelumConstants.ESSENCE_WATER,
            3,
            "CaelumWaterBellT3Weapon"
        );
        EnsureMagicWeaponSelector(
            CaelumConstants.WEAPON_TYPE_BOOK,
            CaelumConstants.ESSENCE_WATER,
            1,
            "CaelumWaterBookT1Weapon"
        );
        EnsureMagicWeaponSelector(
            CaelumConstants.WEAPON_TYPE_BOOK,
            CaelumConstants.ESSENCE_WATER,
            2,
            "CaelumWaterBookT2Weapon"
        );
        EnsureMagicWeaponSelector(
            CaelumConstants.WEAPON_TYPE_BOOK,
            CaelumConstants.ESSENCE_WATER,
            3,
            "CaelumWaterBookT3Weapon"
        );
        EnsureMagicWeaponSelector(
            CaelumConstants.WEAPON_TYPE_STATUETTE,
            CaelumConstants.ESSENCE_WATER,
            1,
            "CaelumWaterStatuetteT1Weapon"
        );
        EnsureMagicWeaponSelector(
            CaelumConstants.WEAPON_TYPE_STATUETTE,
            CaelumConstants.ESSENCE_WATER,
            2,
            "CaelumWaterStatuetteT2Weapon"
        );
        EnsureMagicWeaponSelector(
            CaelumConstants.WEAPON_TYPE_STATUETTE,
            CaelumConstants.ESSENCE_WATER,
            3,
            "CaelumWaterStatuetteT3Weapon"
        );
        EnsureMagicWeaponSelector(
            CaelumConstants.WEAPON_TYPE_STAFF,
            CaelumConstants.ESSENCE_EARTH,
            1,
            "CaelumEarthStaffT1Weapon"
        );
        EnsureMagicWeaponSelector(
            CaelumConstants.WEAPON_TYPE_STAFF,
            CaelumConstants.ESSENCE_EARTH,
            2,
            "CaelumEarthStaffT2Weapon"
        );
        EnsureMagicWeaponSelector(
            CaelumConstants.WEAPON_TYPE_STAFF,
            CaelumConstants.ESSENCE_EARTH,
            3,
            "CaelumEarthStaffT3Weapon"
        );
        EnsureMagicWeaponSelector(
            CaelumConstants.WEAPON_TYPE_BELL,
            CaelumConstants.ESSENCE_EARTH,
            1,
            "CaelumEarthBellT1Weapon"
        );
        EnsureMagicWeaponSelector(
            CaelumConstants.WEAPON_TYPE_BELL,
            CaelumConstants.ESSENCE_EARTH,
            2,
            "CaelumEarthBellT2Weapon"
        );
        EnsureMagicWeaponSelector(
            CaelumConstants.WEAPON_TYPE_BELL,
            CaelumConstants.ESSENCE_EARTH,
            3,
            "CaelumEarthBellT3Weapon"
        );
        EnsureMagicWeaponSelector(
            CaelumConstants.WEAPON_TYPE_BOOK,
            CaelumConstants.ESSENCE_EARTH,
            1,
            "CaelumEarthBookT1Weapon"
        );
        EnsureMagicWeaponSelector(
            CaelumConstants.WEAPON_TYPE_BOOK,
            CaelumConstants.ESSENCE_EARTH,
            2,
            "CaelumEarthBookT2Weapon"
        );
        EnsureMagicWeaponSelector(
            CaelumConstants.WEAPON_TYPE_BOOK,
            CaelumConstants.ESSENCE_EARTH,
            3,
            "CaelumEarthBookT3Weapon"
        );
        EnsureMagicWeaponSelector(
            CaelumConstants.WEAPON_TYPE_STATUETTE,
            CaelumConstants.ESSENCE_EARTH,
            1,
            "CaelumEarthStatuetteT1Weapon"
        );
        EnsureMagicWeaponSelector(
            CaelumConstants.WEAPON_TYPE_STATUETTE,
            CaelumConstants.ESSENCE_EARTH,
            2,
            "CaelumEarthStatuetteT2Weapon"
        );
        EnsureMagicWeaponSelector(
            CaelumConstants.WEAPON_TYPE_STATUETTE,
            CaelumConstants.ESSENCE_EARTH,
            3,
            "CaelumEarthStatuetteT3Weapon"
        );
        EnsureMagicWeaponSelector(
            CaelumConstants.WEAPON_TYPE_STAFF,
            CaelumConstants.ESSENCE_WIND,
            1,
            "CaelumAirStaffT1Weapon"
        );
        EnsureMagicWeaponSelector(
            CaelumConstants.WEAPON_TYPE_STAFF,
            CaelumConstants.ESSENCE_WIND,
            2,
            "CaelumAirStaffT2Weapon"
        );
        EnsureMagicWeaponSelector(
            CaelumConstants.WEAPON_TYPE_STAFF,
            CaelumConstants.ESSENCE_WIND,
            3,
            "CaelumAirStaffT3Weapon"
        );
        EnsureMagicWeaponSelector(
            CaelumConstants.WEAPON_TYPE_BELL,
            CaelumConstants.ESSENCE_WIND,
            1,
            "CaelumAirBellT1Weapon"
        );
        EnsureMagicWeaponSelector(
            CaelumConstants.WEAPON_TYPE_BELL,
            CaelumConstants.ESSENCE_WIND,
            2,
            "CaelumAirBellT2Weapon"
        );
        EnsureMagicWeaponSelector(
            CaelumConstants.WEAPON_TYPE_BELL,
            CaelumConstants.ESSENCE_WIND,
            3,
            "CaelumAirBellT3Weapon"
        );
        EnsureMagicWeaponSelector(
            CaelumConstants.WEAPON_TYPE_BOOK,
            CaelumConstants.ESSENCE_WIND,
            1,
            "CaelumAirBookT1Weapon"
        );
        EnsureMagicWeaponSelector(
            CaelumConstants.WEAPON_TYPE_BOOK,
            CaelumConstants.ESSENCE_WIND,
            2,
            "CaelumAirBookT2Weapon"
        );
        EnsureMagicWeaponSelector(
            CaelumConstants.WEAPON_TYPE_BOOK,
            CaelumConstants.ESSENCE_WIND,
            3,
            "CaelumAirBookT3Weapon"
        );
        EnsureMagicWeaponSelector(
            CaelumConstants.WEAPON_TYPE_STATUETTE,
            CaelumConstants.ESSENCE_WIND,
            1,
            "CaelumAirStatuetteT1Weapon"
        );
        EnsureMagicWeaponSelector(
            CaelumConstants.WEAPON_TYPE_STATUETTE,
            CaelumConstants.ESSENCE_WIND,
            2,
            "CaelumAirStatuetteT2Weapon"
        );
        EnsureMagicWeaponSelector(
            CaelumConstants.WEAPON_TYPE_STATUETTE,
            CaelumConstants.ESSENCE_WIND,
            3,
            "CaelumAirStatuetteT3Weapon"
        );
        EnsureMagicWeaponSelector(
            CaelumConstants.WEAPON_TYPE_STAFF,
            CaelumConstants.ESSENCE_QUINTESSENCE,
            1,
            "CaelumQuintessenceStaffT1Weapon"
        );
        EnsureMagicWeaponSelector(
            CaelumConstants.WEAPON_TYPE_STAFF,
            CaelumConstants.ESSENCE_QUINTESSENCE,
            2,
            "CaelumQuintessenceStaffT2Weapon"
        );
        EnsureMagicWeaponSelector(
            CaelumConstants.WEAPON_TYPE_STAFF,
            CaelumConstants.ESSENCE_QUINTESSENCE,
            3,
            "CaelumQuintessenceStaffT3Weapon"
        );
        EnsureMagicWeaponSelector(
            CaelumConstants.WEAPON_TYPE_BELL,
            CaelumConstants.ESSENCE_QUINTESSENCE,
            1,
            "CaelumQuintessenceBellT1Weapon"
        );
        EnsureMagicWeaponSelector(
            CaelumConstants.WEAPON_TYPE_BELL,
            CaelumConstants.ESSENCE_QUINTESSENCE,
            2,
            "CaelumQuintessenceBellT2Weapon"
        );
        EnsureMagicWeaponSelector(
            CaelumConstants.WEAPON_TYPE_BELL,
            CaelumConstants.ESSENCE_QUINTESSENCE,
            3,
            "CaelumQuintessenceBellT3Weapon"
        );
        EnsureMagicWeaponSelector(
            CaelumConstants.WEAPON_TYPE_BOOK,
            CaelumConstants.ESSENCE_QUINTESSENCE,
            1,
            "CaelumQuintessenceBookT1Weapon"
        );
        EnsureMagicWeaponSelector(
            CaelumConstants.WEAPON_TYPE_BOOK,
            CaelumConstants.ESSENCE_QUINTESSENCE,
            2,
            "CaelumQuintessenceBookT2Weapon"
        );
        EnsureMagicWeaponSelector(
            CaelumConstants.WEAPON_TYPE_BOOK,
            CaelumConstants.ESSENCE_QUINTESSENCE,
            3,
            "CaelumQuintessenceBookT3Weapon"
        );
        EnsureMagicWeaponSelector(
            CaelumConstants.WEAPON_TYPE_STATUETTE,
            CaelumConstants.ESSENCE_QUINTESSENCE,
            1,
            "CaelumQuintessenceStatuetteT1Weapon"
        );
        EnsureMagicWeaponSelector(
            CaelumConstants.WEAPON_TYPE_STATUETTE,
            CaelumConstants.ESSENCE_QUINTESSENCE,
            2,
            "CaelumQuintessenceStatuetteT2Weapon"
        );
        EnsureMagicWeaponSelector(
            CaelumConstants.WEAPON_TYPE_STATUETTE,
            CaelumConstants.ESSENCE_QUINTESSENCE,
            3,
            "CaelumQuintessenceStatuetteT3Weapon"
        );
        // Los selectores genericos anteriores quedan retirados al migrar al
        // ciclo nativo por arma; la propiedad y durabilidad no se modifican.
        TakeInventory("CaelumStaffWeapon", 1);
        TakeInventory("CaelumBellWeapon", 1);
        TakeInventory("CaelumBookWeapon", 1);
        TakeInventory("CaelumStatuetteWeapon", 1);
        TakeInventory("CaelumLightWeapon", 1);
        TakeInventory("CaelumSwordWeapon", 1);
        TakeInventory("CaelumLargeWeapon", 1);
        TakeInventory("CaelumCarbineWeapon", 1);
        TakeInventory("CaelumEquippedWeapon", 1);
    }

    bool ActivateEquippedWeaponType(int requestedWeaponType)
    {
        if (WeaponModel == null) { return false; }
        int resolvedType = Clamp(
            requestedWeaponType, 0, CaelumConstants.WEAPON_TYPE_COUNT - 1
        );

        // Cambiar de arma rompe el bloqueo anterior. Si el jugador mantiene
        // Zoom, el arma nueva podrá levantar el escudo nuevamente mediante su
        // propio estado Zoom.
        if (WeaponModel.Equipped
            && WeaponModel.WeaponType != resolvedType)
        {
            CancelRangedAim();
            CancelRangedReload();
            CancelWeaponCharge();
            if (CombatBlockModeActive)
            {
                CancelCombatBlockMode();
            }
        }

        if (WeaponModel.Equipped
            && WeaponModel.WeaponType == resolvedType
            && HasEquippedNativeWeaponType(resolvedType))
        {
            return true;
        }
        if (StaffCastPending) { CancelPendingStaffCast(false); }
        for (Inventory cursor = Inv; cursor != null; cursor = cursor.Inv)
        {
            CaelumEquipmentItem item = CaelumEquipmentItem(cursor);
            if (item != null
                && item.EquipmentKind == CaelumConstants.EQUIPMENT_KIND_WEAPON
                && item.ItemType == resolvedType
                && item.Equipped && !item.InMagicBox)
            {
                WeaponModel.WeaponType = resolvedType;
                WeaponModel.Tier = item.Tier;
                WeaponModel.Size = item.EquipmentSize;
                WeaponModel.Durability = item.Durability;
                WeaponModel.EssenceType = Clamp(
                    item.EssenceType,
                    0,
                    CaelumConstants.ESSENCE_TYPE_COUNT - 1
                );
                SelectedEssenceType = WeaponModel.EssenceType;
                WeaponModel.Equipped = true;
                EquippedWeaponCooldownRemaining = 0.0;
                ApplyCharacterProfile();
                PersistCharacterState();
                RefreshEquipmentSelectionPreview();
                return true;
            }
        }
        return false;
    }

    // Mantiene una instantanea segura para UI y detecta cambios reales del
    // arma activa. Varias armas pueden seguir equipadas simultaneamente.
    void SyncHUDActiveWeaponState()
    {
        HUDHasEquippedSeal = false;
        HUDEquippedSealType = CaelumConstants.SEAL_FIRE;
        HUDEquippedSealTier = 0;
        for (Inventory sealCursor = Inv; sealCursor != null;
            sealCursor = sealCursor.Inv)
        {
            CaelumEquipmentItem equippedSeal =
                CaelumEquipmentItem(sealCursor);
            if (equippedSeal != null && equippedSeal.Equipped
                && equippedSeal.EquipmentKind
                    == CaelumConstants.EQUIPMENT_KIND_SEAL)
            {
                HUDHasEquippedSeal = true;
                HUDEquippedSealType = Clamp(equippedSeal.ItemType, 0,
                    CaelumConstants.SEAL_TYPE_COUNT - 1);
                HUDEquippedSealTier = Clamp(equippedSeal.Tier, 1, 3);
                break;
            }
        }
        bool hasActiveWeapon = WeaponModel != null
            && WeaponModel.Equipped
            && WeaponModel.Durability > 0
            && HasEquippedNativeWeaponType(WeaponModel.WeaponType);
        int activeType = hasActiveWeapon ? WeaponModel.WeaponType : -1;
        int activeTier = hasActiveWeapon ? WeaponModel.Tier : 0;
        int activeSize = hasActiveWeapon
            ? WeaponModel.Size : CaelumConstants.EQUIPMENT_SIZE_M;
        int activeEssenceType = hasActiveWeapon
            ? Clamp(
                WeaponModel.EssenceType,
                0,
                CaelumConstants.ESSENCE_TYPE_COUNT - 1
            )
            : CaelumConstants.ESSENCE_FIRE;

        bool changed = !HUDActiveWeaponStateInitialized
            || HUDHasActiveWeapon != hasActiveWeapon
            || HUDActiveWeaponType != activeType
            || HUDActiveWeaponTier != activeTier
            || HUDActiveWeaponSize != activeSize
            || HUDActiveWeaponEssenceType != activeEssenceType;

        HUDHasActiveWeapon = hasActiveWeapon;
        HUDActiveWeaponType = activeType;
        HUDActiveWeaponTier = activeTier;
        HUDActiveWeaponSize = activeSize;
        HUDActiveWeaponEssenceType = activeEssenceType;
        HUDActiveWeaponIsRanged = hasActiveWeapon
            && IsRangedWeaponType(activeType);
        HUDRangedMagazineCount = HUDActiveWeaponIsRanged
            ? GetRangedMagazineCount(activeType) : 0;
        HUDRangedMagazineCapacity = HUDActiveWeaponIsRanged
            ? GetRangedMagazineCapacity(activeType) : 0;
        HUDRangedReserveCount = HUDActiveWeaponIsRanged
            ? GetEquippedRangedReserveCount() : 0;
        HUDCombatBlockActive = CombatBlockModeActive && HasActiveBlockSource();
        HUDCombatBlockUsesGauntlets = HUDCombatBlockActive
            && IsGiantGauntletsBlockSource();
        HUDActiveShieldType = HUDCombatBlockActive
            && !HUDCombatBlockUsesGauntlets && ShieldModel != null
            ? ShieldModel.ShieldType : CaelumConstants.SHIELD_TYPE_BUCKLER;

        if (changed)
        {
            HUDActiveWeaponNoticeRemaining =
                CaelumConstants.ACTIVE_WEAPON_NOTICE_SECONDS;
            HUDActiveWeaponStateInitialized = true;
        }
        else
        {
            HUDActiveWeaponNoticeRemaining = Max(
                0.0,
                HUDActiveWeaponNoticeRemaining - 1.0 / TICRATE
            );
        }
    }

    bool ActivateFirstEquippedWeapon()
    {
        for (int weaponType = 0;
            weaponType < CaelumConstants.WEAPON_TYPE_COUNT;
            weaponType++)
        {
            if (ActivateEquippedWeaponType(weaponType)) { return true; }
        }
        if (WeaponModel != null) { WeaponModel.Equipped = false; }
        return false;
    }

    void PerformWeaponFamilyPrimaryAttack(int weaponType)
    {
        if (ActivateEquippedWeaponType(weaponType))
        {
            PerformEquippedWeaponPrimaryAttack();
        }
    }

    void PerformFamilyPrimaryAttack(int family)
    {
        if (ActivateEquippedWeaponFamily(family))
        {
            PerformEquippedWeaponPrimaryAttack();
        }
    }

    void PerformFamilySecondaryAction(int family)
    {
        if (ActivateEquippedWeaponFamily(family))
        {
            PerformEquippedWeaponSecondaryAttack();
        }
    }

    void PerformWeaponFamilySecondaryAction(int weaponType)
    {
        if (ActivateEquippedWeaponType(weaponType))
        {
            PerformEquippedWeaponSecondaryAttack();
        }
    }

    // Actor.Inv es la fuente única de propiedad y carga. Equipar no cambia el
    // peso; la Caja Mágica sí lo vuelve cero. Las pilas usan Amount.
    void RefreshCarriedInventorySummary()
    {
        PersonalInventoryItemCount = 0;
        OwnedArmorCount = 0;
        OwnedShieldCount = 0;
        OwnedWeaponCount = 0;
        EquippedItemSlotCount = 0;
        MagicBoxUsedSlots = 0;
        double personalInventoryWeight = 0.0;
        double carriedItemWeight = 0.0;
        double armorWeight = 0.0;
        double shieldWeight = 0.0;
        double weaponWeight = 0.0;

        for (Inventory cursor = Inv; cursor != null; cursor = cursor.Inv)
        {
            CaelumEquipmentItem item = CaelumEquipmentItem(cursor);
            if (item == null) { continue; }
            if (item.EquipmentKind == CaelumConstants.EQUIPMENT_KIND_ARMOR)
            {
                OwnedArmorCount++;
            }
            else if (item.EquipmentKind == CaelumConstants.EQUIPMENT_KIND_SHIELD)
            {
                OwnedShieldCount++;
            }
            else if (item.EquipmentKind == CaelumConstants.EQUIPMENT_KIND_WEAPON)
            {
                OwnedWeaponCount++;
            }

            if (item.InMagicBox)
            {
                MagicBoxUsedSlots++;
                continue;
            }

            double itemWeight = item.GetCarriedWeight();
            carriedItemWeight += itemWeight;
            if (item.Equipped)
            {
                EquippedItemSlotCount++;
                if (item.EquipmentKind == CaelumConstants.EQUIPMENT_KIND_ARMOR)
                {
                    armorWeight += itemWeight;
                }
                else if (item.EquipmentKind == CaelumConstants.EQUIPMENT_KIND_SHIELD)
                {
                    shieldWeight += itemWeight;
                }
                else if (item.EquipmentKind == CaelumConstants.EQUIPMENT_KIND_WEAPON)
                {
                    weaponWeight += itemWeight;
                }
            }
            else
            {
                PersonalInventoryItemCount++;
                personalInventoryWeight += itemWeight;
            }
        }

        CarbineAmmoCount = 0;
        for (Inventory cursor = Inv; cursor != null; cursor = cursor.Inv)
        {
            CaelumCarbineAmmo ammunition = CaelumCarbineAmmo(cursor);
            if (ammunition == null || ammunition.Amount <= 0) { continue; }
            if (ammunition.GetAmmoType()
                == CaelumConstants.AMMUNITION_CARBINE)
            {
                CarbineAmmoCount = ammunition.Amount;
            }
            if (ammunition.InMagicBox) { MagicBoxUsedSlots++; }
            else
            {
                PersonalInventoryItemCount += ammunition.Amount;
                double ammunitionWeight = ammunition.GetCarriedWeight();
                personalInventoryWeight += ammunitionWeight;
                carriedItemWeight += ammunitionWeight;
            }
        }

        Inventory arrowAmmo = FindInventory("CaelumArrowAmmo");
        if (arrowAmmo != null && arrowAmmo.Amount > 0)
        {
            PersonalInventoryItemCount += arrowAmmo.Amount;
            double arrowWeight = arrowAmmo.Amount
                * CaelumConstants.ARROW_AMMO_UNIT_WEIGHT;
            personalInventoryWeight += arrowWeight;
            carriedItemWeight += arrowWeight;
        }
        Inventory boltAmmo = FindInventory("CaelumBoltAmmo");
        if (boltAmmo != null && boltAmmo.Amount > 0)
        {
            PersonalInventoryItemCount += boltAmmo.Amount;
            double boltWeight = boltAmmo.Amount
                * CaelumConstants.BOLT_AMMO_UNIT_WEIGHT;
            personalInventoryWeight += boltWeight;
            carriedItemWeight += boltWeight;
        }

        for (Inventory cursor = Inv; cursor != null; cursor = cursor.Inv)
        {
            CaelumConsumableItem consumable = CaelumConsumableItem(cursor);
            if (consumable == null || consumable.Amount <= 0) { continue; }
            if (consumable.InMagicBox)
            {
                MagicBoxUsedSlots++;
                continue;
            }
            PersonalInventoryItemCount += consumable.Amount;
            double consumableWeight = consumable.GetCarriedWeight();
            personalInventoryWeight += consumableWeight;
            carriedItemWeight += consumableWeight;
        }

        for (Inventory cursor = Inv; cursor != null; cursor = cursor.Inv)
        {
            CaelumSpecialInventoryItem specialItem =
                CaelumSpecialInventoryItem(cursor);
            if (specialItem == null || specialItem.Amount <= 0) { continue; }
            if (specialItem.InMagicBox)
            {
                MagicBoxUsedSlots++;
                continue;
            }
            PersonalInventoryItemCount += specialItem.Amount;
            double specialWeight = specialItem.GetCarriedWeight();
            personalInventoryWeight += specialWeight;
            carriedItemWeight += specialWeight;
        }

        for (Inventory cursor = Inv; cursor != null; cursor = cursor.Inv)
        {
            CaelumWeightedKey keyItem = CaelumWeightedKey(cursor);
            if (keyItem == null || keyItem.Amount <= 0) { continue; }
            PersonalInventoryItemCount++;
            double keyWeight = keyItem.GetCarriedWeight();
            personalInventoryWeight += keyWeight;
            carriedItemWeight += keyWeight;
        }
        if (DerivedStats != null)
        {
            DerivedStats.SetCarriedLoadBreakdown(
                armorWeight,
                shieldWeight,
                weaponWeight,
                personalInventoryWeight,
                carriedItemWeight
            );
            SyncHUDLoadState();
        }
    }

    bool CanAddWeightToPersonalInventory(double additionalWeight)
    {
        if (DerivedStats == null) { return false; }
        return DerivedStats.CarriedWeight + Max(0.0, additionalWeight)
            <= DerivedStats.CarryCapacity + 0.0005;
    }

    bool IsSpecialInventoryKind(int k)
    { return k==CaelumConstants.EQUIPMENT_KIND_MATERIAL || k==CaelumConstants.EQUIPMENT_KIND_KEY || k==CaelumConstants.EQUIPMENT_KIND_KEY_ITEM; }
    bool IsUniversalJewelryKind(int k)
    { return k==CaelumConstants.EQUIPMENT_KIND_AMULET || k==CaelumConstants.EQUIPMENT_KIND_SEAL; }

    void RefreshEquipmentSelectionPreview()
    {
        EquipmentSelectionSlot = Clamp(
            EquipmentSelectionSlot,
            0,
            CaelumConstants.ARMOR_SLOT_COUNT - 1
        );
        EquipmentSelectionArmorType = Clamp(
            EquipmentSelectionArmorType,
            0,
            CaelumConstants.ARMOR_EQUIPPABLE_TYPE_COUNT - 1
        );
        EquipmentSelectionShieldType = Clamp(
            EquipmentSelectionShieldType,
            0,
            CaelumConstants.SHIELD_TYPE_COUNT - 1
        );
        EquipmentSelectionWeaponType = Clamp(
            EquipmentSelectionWeaponType,
            0,
            CaelumConstants.WEAPON_TYPE_COUNT - 1
        );
        EquipmentSelectionWeaponEssenceType = Clamp(
            EquipmentSelectionWeaponEssenceType,
            0,
            CaelumConstants.ESSENCE_TYPE_COUNT - 1
        );
        EquipmentSelectionAmmunitionType = Clamp(
            EquipmentSelectionAmmunitionType,
            0,
            CaelumConstants.AMMUNITION_TYPE_COUNT - 1
        );
        EquipmentSelectionConsumableType = Clamp(
            EquipmentSelectionConsumableType,
            0,
            CaelumConstants.CONSUMABLE_TYPE_COUNT - 1
        );
        EquipmentSelectionAmuletType = Clamp(EquipmentSelectionAmuletType,0,CaelumConstants.AMULET_TYPE_COUNT-1);
        EquipmentSelectionSealType = Clamp(EquipmentSelectionSealType,0,CaelumConstants.SEAL_TYPE_COUNT-1);
        int specialTypeCount = 1;
        if (EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_MATERIAL)
        {
            specialTypeCount = CaelumConstants.MATERIAL_TYPE_COUNT;
        }
        else if (EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_KEY)
        {
            specialTypeCount = CaelumConstants.KEY_TYPE_COUNT;
        }
        else if (EquipmentSelectionKind
            == CaelumConstants.EQUIPMENT_KIND_KEY_ITEM)
        {
            specialTypeCount = CaelumConstants.KEY_ITEM_TYPE_COUNT;
        }
        int firstSpecialType = 0;
        if (EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_MATERIAL)
        {
            firstSpecialType = CaelumConstants.MATERIAL_FIRST_ACTIVE;
        }
        EquipmentSelectionSpecialType = Clamp(
            EquipmentSelectionSpecialType, firstSpecialType, specialTypeCount - 1
        );
        EquipmentSelectionTier = Clamp(EquipmentSelectionTier, 1, 3);
        if (EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_MATERIAL)
        {
            EquipmentSelectionTier = CaelumMaterialRules.ResolveTier(
                EquipmentSelectionSpecialType, EquipmentSelectionTier
            );
        }
        EquipmentSelectionSize = Clamp(
            EquipmentSelectionSize,
            0,
            CaelumConstants.EQUIPMENT_SIZE_COUNT - 1
        );
        EquipmentSelectionOwned = false;
        EquipmentSelectionEquipped = false;
        EquipmentSelectionInMagicBox = false;
        EquipmentSelectionSizeCompatible = CharacterProfile != null
            && CaelumEquipmentRules.IsSizeCompatible(
                EquipmentSelectionSize,
                CharacterProfile.GetSizeTier()
            );
        EquipmentSelectionDurability = 0;
        EquipmentSelectionMaximumDurability = 0;
        EquipmentSelectionWeight = 0.0;
        EquipmentSelectionDamage = 0.0;
        EquipmentSelectionAirCost = 0.0;
        EquipmentSelectionAnimaCost = 0.0;
        EquipmentSelectionAttackTics = 0;
        EquipmentSelectionStackAmount = 0;
        MagicBoxMaximumSlots = DerivedStats != null
            ? DerivedStats.MagicBoxCapacity : 0;
        RefreshCarriedInventorySummary();

        if (EquipmentSelectionKind
            == CaelumConstants.EQUIPMENT_KIND_AMMUNITION)
        {
            Inventory ammunition = FindNativeAmmunition(
                EquipmentSelectionAmmunitionType
            );
            EquipmentSelectionOwned = ammunition != null
                && ammunition.Amount > 0;
            EquipmentSelectionInMagicBox = false;
            EquipmentSelectionSizeCompatible = true;
            EquipmentSelectionStackAmount = EquipmentSelectionOwned
                ? ammunition.Amount : 0;
            EquipmentSelectionWeight = EquipmentSelectionStackAmount
                * GetAmmunitionUnitWeight(EquipmentSelectionAmmunitionType);
            CaelumCarbineAmmo carbineStack = CaelumCarbineAmmo(ammunition);
            if (carbineStack != null)
            {
                EquipmentSelectionInMagicBox = carbineStack.InMagicBox;
                EquipmentSelectionWeight = carbineStack.GetCarriedWeight();
            }
            return;
        }

        if (EquipmentSelectionKind
            == CaelumConstants.EQUIPMENT_KIND_CONSUMABLE)
        {
            CaelumConsumableItem consumable = FindNativeConsumableItem(
                EquipmentSelectionConsumableType
            );
            EquipmentSelectionOwned = consumable != null
                && consumable.Amount > 0;
            EquipmentSelectionInMagicBox = EquipmentSelectionOwned
                && consumable.InMagicBox;
            EquipmentSelectionSizeCompatible = true;
            EquipmentSelectionStackAmount = EquipmentSelectionOwned
                ? consumable.Amount : 0;
            double unitWeight = consumable != null
                ? consumable.GetUnitWeight()
                : (EquipmentSelectionConsumableType
                        == CaelumConstants.CONSUMABLE_FOOD_RATION
                    || EquipmentSelectionConsumableType
                        == CaelumConstants.CONSUMABLE_WATER_RATION
                    ? CaelumConstants.CONSUMABLE_RATION_WEIGHT
                    : CaelumConstants.CONSUMABLE_POTION_WEIGHT);
            EquipmentSelectionWeight = EquipmentSelectionStackAmount
                * unitWeight;
            return;
        }

        if (EquipmentSelectionKind
                == CaelumConstants.EQUIPMENT_KIND_MATERIAL
            || EquipmentSelectionKind
                == CaelumConstants.EQUIPMENT_KIND_KEY_ITEM)
        {
            CaelumSpecialInventoryItem specialItem = FindNativeSpecialItem(
                EquipmentSelectionKind, EquipmentSelectionSpecialType,
                EquipmentSelectionTier
            );
            EquipmentSelectionOwned = specialItem != null
                && specialItem.Amount > 0;
            EquipmentSelectionInMagicBox = EquipmentSelectionOwned
                && specialItem.InMagicBox;
            EquipmentSelectionSizeCompatible = true;
            EquipmentSelectionStackAmount = EquipmentSelectionOwned
                ? specialItem.Amount : 0;
            EquipmentSelectionWeight = EquipmentSelectionStackAmount
                * (specialItem != null
                    ? specialItem.GetUnitWeight()
                    : CaelumConstants.SPECIAL_ITEM_DEFAULT_WEIGHT);
            return;
        }

        if (EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_KEY)
        {
            CaelumWeightedKey keyItem = FindNativeKey(
                EquipmentSelectionSpecialType
            );
            EquipmentSelectionOwned = keyItem != null && keyItem.Amount > 0;
            EquipmentSelectionSizeCompatible = true;
            EquipmentSelectionStackAmount = EquipmentSelectionOwned ? 1 : 0;
            EquipmentSelectionWeight = EquipmentSelectionOwned
                ? keyItem.GetCarriedWeight()
                : CaelumConstants.SPECIAL_ITEM_DEFAULT_WEIGHT;
            return;
        }

        if (EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_AMULET
            || EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_SEAL)
        {
            int type = EquipmentSelectionKind==CaelumConstants.EQUIPMENT_KIND_AMULET ? EquipmentSelectionAmuletType : EquipmentSelectionSealType;
            CaelumEquipmentItem item=FindNativeEquipmentItem(EquipmentSelectionKind,type,-1,EquipmentSelectionTier,CaelumConstants.EQUIPMENT_SIZE_M);
            EquipmentSelectionSize=CaelumConstants.EQUIPMENT_SIZE_M; EquipmentSelectionSizeCompatible=true;
            EquipmentSelectionOwned=item!=null; EquipmentSelectionEquipped=item!=null&&item.Equipped;
            EquipmentSelectionInMagicBox=item!=null&&item.InMagicBox; EquipmentSelectionDurability=0; EquipmentSelectionMaximumDurability=0;
            EquipmentSelectionWeight=item!=null ? item.UnitWeight : CaelumCraftingRules.GetJewelryWeight(EquipmentSelectionTier);
            return;
        }

        if (EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_WEAPON)
        {
            CaelumEquipmentItem item;
            if (WeaponModel != null
                && WeaponModel.IsMagicalType(EquipmentSelectionWeaponType))
            {
                item = FindNativeMagicWeaponItem(
                    EquipmentSelectionWeaponType,
                    EquipmentSelectionWeaponEssenceType,
                    EquipmentSelectionTier,
                    EquipmentSelectionSize
                );
            }
            else
            {
                item = FindNativeEquipmentItem(
                    CaelumConstants.EQUIPMENT_KIND_WEAPON,
                    EquipmentSelectionWeaponType,
                    -1,
                    EquipmentSelectionTier,
                    EquipmentSelectionSize
                );
            }
            EquipmentSelectionOwned = item != null;
            EquipmentSelectionDurability = item != null ? item.Durability : 0;
            EquipmentSelectionMaximumDurability = WeaponModel != null
                ? WeaponModel.GetMaximumDurabilityFor(
                    EquipmentSelectionWeaponType,
                    EquipmentSelectionTier,
                    EquipmentSelectionSize
                ) : 0;
            EquipmentSelectionWeight = WeaponModel != null
                ? WeaponModel.GetWeightFor(
                    EquipmentSelectionWeaponType,
                    EquipmentSelectionTier,
                    EquipmentSelectionSize
                ) : 0.0;
            EquipmentSelectionDamage = WeaponModel != null
                ? WeaponModel.GetDamageFor(
                    EquipmentSelectionWeaponType,
                    EquipmentSelectionTier
                ) : 0.0;
            EquipmentSelectionAirCost = WeaponModel != null
                ? WeaponModel.GetAirCostFor(EquipmentSelectionWeaponType) : 0.0;
            EquipmentSelectionAnimaCost = WeaponModel != null
                ? WeaponModel.GetAnimaCostFor(EquipmentSelectionWeaponType) : 0.0;
            EquipmentSelectionAttackTics = WeaponModel != null
                ? WeaponModel.GetAttackTicsFor(EquipmentSelectionWeaponType) : 0;
            EquipmentSelectionEquipped = item != null && item.Equipped;
            EquipmentSelectionInMagicBox = item != null && item.InMagicBox;
            if (WeaponModel != null
                && WeaponModel.IsMagicalType(EquipmentSelectionWeaponType))
            {
                SelectedEssenceType = EquipmentSelectionWeaponEssenceType;
            }
            return;
        }

        if (EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_SHIELD)
        {
            CaelumEquipmentItem item = FindNativeEquipmentItem(
                CaelumConstants.EQUIPMENT_KIND_SHIELD,
                EquipmentSelectionShieldType,
                -1,
                EquipmentSelectionTier,
                EquipmentSelectionSize
            );
            EquipmentSelectionOwned = item != null;
            EquipmentSelectionDurability = item != null ? item.Durability : 0;
            EquipmentSelectionMaximumDurability = ShieldModel != null
                ? ShieldModel.GetMaximumDurabilityFor(
                    EquipmentSelectionShieldType,
                    EquipmentSelectionTier,
                    EquipmentSelectionSize
                ) : 0;
            EquipmentSelectionWeight = ShieldModel != null
                ? ShieldModel.GetWeightFor(
                    EquipmentSelectionShieldType,
                    EquipmentSelectionTier,
                    EquipmentSelectionSize
                ) : 0.0;
            EquipmentSelectionEquipped = item != null && item.Equipped;
            EquipmentSelectionInMagicBox = item != null && item.InMagicBox;
            return;
        }

        CaelumEquipmentItem item = FindNativeEquipmentItem(
            CaelumConstants.EQUIPMENT_KIND_ARMOR,
            EquipmentSelectionArmorType,
            EquipmentSelectionSlot,
            EquipmentSelectionTier,
            EquipmentSelectionSize
        );
        EquipmentSelectionOwned = item != null;
        EquipmentSelectionDurability = item != null ? item.Durability : 0;
        EquipmentSelectionMaximumDurability = ArmorModel != null
            ? ArmorModel.GetMaximumDurabilityFor(
                EquipmentSelectionArmorType,
                EquipmentSelectionTier,
                EquipmentSelectionSize
            ) : 0;
        EquipmentSelectionWeight = ArmorModel != null
            ? ArmorModel.GetWeightFor(
                EquipmentSelectionSlot,
                EquipmentSelectionArmorType,
                EquipmentSelectionTier,
                EquipmentSelectionSize
            ) : 0.0;
        EquipmentSelectionEquipped = item != null && item.Equipped;
        EquipmentSelectionInMagicBox = item != null && item.InMagicBox;
    }

    bool AcquireArmorPickup(
        int slot,
        int armorType,
        int tier,
        int equipmentSize,
        int encodedDurability
    )
    {
        if (ArmorModel == null) { return false; }
        int resolvedSlot = Clamp(slot, 0, CaelumConstants.ARMOR_SLOT_COUNT - 1);
        int resolvedType = Clamp(
            armorType, 0, CaelumConstants.ARMOR_EQUIPPABLE_TYPE_COUNT - 1
        );
        int resolvedTier = Clamp(tier, 1, 3);
        int resolvedSize = Clamp(
            equipmentSize, 0, CaelumConstants.EQUIPMENT_SIZE_COUNT - 1
        );
        CaelumPersistentCharacterState persistentState =
            GetPersistentCharacterState(true);
        if (persistentState == null) { return false; }
        persistentState.EnsureEquipmentSizeInitialized();
        ApplyCharacterProfile();
        RefreshEquipmentSelectionPreview();
        bool alreadyOwned = persistentState.OwnsArmor(
            resolvedSlot, resolvedType, resolvedTier, resolvedSize
        );
        bool sendToMagicBox = false;
        if (!alreadyOwned && !CanAddWeightToPersonalInventory(
            ArmorModel.GetWeightFor(
                resolvedSlot, resolvedType, resolvedTier, resolvedSize
            )
        ))
        {
            if (MagicBoxUsedSlots >= MagicBoxMaximumSlots) { return false; }
            sendToMagicBox = true;
        }
        int pickupDurability = encodedDurability > 0
            ? encodedDurability - 1
            : ArmorModel.GetMaximumDurabilityFor(resolvedType, resolvedTier, resolvedSize);
        LastEquipmentPickupWasNew = persistentState.RegisterOwnedArmor(
            resolvedSlot,
            resolvedType,
            resolvedTier,
            resolvedSize,
            pickupDurability
        );
        if (LastEquipmentPickupWasNew)
        {
            persistentState.SetArmorInMagicBox(
                resolvedSlot, resolvedType, resolvedTier, resolvedSize,
                sendToMagicBox
            );
        }
        LastEquipmentPickupWentToMagicBox = persistentState.IsArmorInMagicBox(
            resolvedSlot, resolvedType, resolvedTier, resolvedSize
        );
        if (ArmorModel.ArmorType[resolvedSlot] == resolvedType
            && ArmorModel.Tier[resolvedSlot] == resolvedTier
            && ArmorModel.Size[resolvedSlot] == resolvedSize)
        {
            ArmorModel.Durability[resolvedSlot] = ArmorModel.GetMaximumDurabilityFor(
                resolvedType, resolvedTier, resolvedSize
            );
        }
        OwnedArmorCount = persistentState.CountOwnedArmor();
        ApplyCharacterProfile();
        RefreshEquipmentSelectionPreview();
        PersistCharacterState();
        return true;
    }

    bool AcquireShieldPickup(
        int shieldType,
        int tier,
        int equipmentSize,
        int encodedDurability
    )
    {
        if (ShieldModel == null) { return false; }
        int resolvedType = Clamp(
            shieldType,
            0,
            CaelumConstants.SHIELD_TYPE_COUNT - 1
        );
        int resolvedTier = Clamp(tier, 1, 3);
        int resolvedSize = Clamp(
            equipmentSize, 0, CaelumConstants.EQUIPMENT_SIZE_COUNT - 1
        );
        CaelumPersistentCharacterState persistentState =
            GetPersistentCharacterState(true);
        if (persistentState == null) { return false; }
        persistentState.EnsureEquipmentSizeInitialized();
        ApplyCharacterProfile();
        RefreshEquipmentSelectionPreview();
        bool alreadyOwned = persistentState.OwnsShield(
            resolvedType, resolvedTier, resolvedSize
        );
        bool sendToMagicBox = false;
        if (!alreadyOwned && !CanAddWeightToPersonalInventory(
            ShieldModel.GetWeightFor(resolvedType, resolvedTier, resolvedSize)
        ))
        {
            if (MagicBoxUsedSlots >= MagicBoxMaximumSlots) { return false; }
            sendToMagicBox = true;
        }
        int pickupDurability = encodedDurability > 0
            ? encodedDurability - 1
            : ShieldModel.GetMaximumDurabilityFor(resolvedType, resolvedTier, resolvedSize);
        LastEquipmentPickupWasNew = persistentState.RegisterOwnedShield(
            resolvedType,
            resolvedTier,
            resolvedSize,
            pickupDurability
        );
        if (LastEquipmentPickupWasNew)
        {
            persistentState.SetShieldInMagicBox(
                resolvedType, resolvedTier, resolvedSize, sendToMagicBox
            );
        }
        LastEquipmentPickupWentToMagicBox = persistentState.IsShieldInMagicBox(
            resolvedType, resolvedTier, resolvedSize
        );
        if (ShieldModel.Equipped
            && ShieldModel.ShieldType == resolvedType
            && ShieldModel.Tier == resolvedTier
            && ShieldModel.Size == resolvedSize)
        {
            ShieldModel.Durability = ShieldModel.GetMaximumDurabilityFor(
                resolvedType, resolvedTier, resolvedSize
            );
        }
        OwnedShieldCount = persistentState.CountOwnedShields();
        ApplyCharacterProfile();
        RefreshEquipmentSelectionPreview();
        PersistCharacterState();
        return true;
    }

    bool AcquireWeaponPickup(
        int weaponType,
        int tier,
        int equipmentSize,
        int encodedDurability
    )
    {
        if (WeaponModel == null) { return false; }
        int resolvedType = Clamp(
            weaponType, 0, CaelumConstants.WEAPON_TYPE_COUNT - 1
        );
        int resolvedTier = Clamp(tier, 1, 3);
        int resolvedSize = Clamp(
            equipmentSize, 0, CaelumConstants.EQUIPMENT_SIZE_COUNT - 1
        );
        CaelumPersistentCharacterState persistentState =
            GetPersistentCharacterState(true);
        if (persistentState == null) { return false; }
        persistentState.EnsureEquipmentSizeInitialized();
        ApplyCharacterProfile();
        RefreshEquipmentSelectionPreview();
        bool alreadyOwned = persistentState.OwnsWeapon(
            resolvedType, resolvedTier, resolvedSize
        );
        bool sendToMagicBox = false;
        if (!alreadyOwned && !CanAddWeightToPersonalInventory(
            WeaponModel.GetWeightFor(resolvedType, resolvedTier, resolvedSize)
        ))
        {
            if (MagicBoxUsedSlots >= MagicBoxMaximumSlots) { return false; }
            sendToMagicBox = true;
        }
        int pickupDurability = encodedDurability > 0
            ? encodedDurability - 1
            : WeaponModel.GetMaximumDurabilityFor(
                resolvedType, resolvedTier, resolvedSize
            );
        LastEquipmentPickupWasNew = persistentState.RegisterOwnedWeapon(
            resolvedType, resolvedTier, resolvedSize, pickupDurability
        );
        if (LastEquipmentPickupWasNew)
        {
            persistentState.SetWeaponInMagicBox(
                resolvedType, resolvedTier, resolvedSize, sendToMagicBox
            );
        }
        LastEquipmentPickupWentToMagicBox = persistentState.IsWeaponInMagicBox(
            resolvedType, resolvedTier, resolvedSize
        );
        if (WeaponModel.Equipped
            && WeaponModel.WeaponType == resolvedType
            && WeaponModel.Tier == resolvedTier
            && WeaponModel.Size == resolvedSize)
        {
            WeaponModel.Durability = WeaponModel.GetMaximumDurabilityFor(
                resolvedType, resolvedTier, resolvedSize
            );
        }
        OwnedWeaponCount = persistentState.CountOwnedWeapons();
        ApplyCharacterProfile();
        RefreshEquipmentSelectionPreview();
        PersistCharacterState();
        return true;
    }

    int CountCraftingMaterial(int materialType, int materialTier)
    {
        CaelumSpecialInventoryItem material = FindNativeSpecialItem(
            CaelumConstants.EQUIPMENT_KIND_MATERIAL,
            materialType,
            materialTier
        );
        return material != null ? Max(0, material.Amount) : 0;
    }

    void RefreshCraftingPreview()
    {
        int stationRecipeCount = CaelumCraftingRules.GetStationRecipeCount(
            ActiveCraftingStationType
        );
        if (stationRecipeCount <= 0)
        {
            CraftingSelectionRecipe = 0;
            CraftingSelectedWeapon = -1;
            CraftingSelectedRecipeKind =
                CaelumConstants.CRAFTING_RECIPE_KIND_PHYSICAL_WEAPON;
            CraftingSelectedArmorType = CaelumConstants.ARMOR_TYPE_MAGIC;
            CraftingSelectedArmorSlot = CaelumConstants.ARMOR_SLOT_HEAD;
            CraftingSelectedEssenceWeaponType = CaelumConstants.WEAPON_TYPE_STAFF;
            CraftingSelectedEssenceType = CaelumConstants.ESSENCE_FIRE;
            CraftingBasicMaterialType = 0;
            CraftingBasicMaterialTier = 1;
            CraftingBasicRequired = 0;
            CraftingBasicOwned = 0;
            CraftingTierMaterialType = 0;
            CraftingTierMaterialTier = 1;
            CraftingTierRequired = 0;
            CraftingTierOwned = 0;
            CraftingFinalWeight = 0.0;
            CraftingSelectedInfrastructureAvailable = false;
            CraftingMissingStationType =
                CaelumConstants.CRAFTING_STATION_NONE;
            RefreshCarriedInventorySummary();
            return;
        }

        CraftingSelectionRecipe = Clamp(
            CraftingSelectionRecipe, 0, stationRecipeCount - 1
        );
        CraftingSelectionTier = Clamp(CraftingSelectionTier, 1, 3);
        CraftingSelectionSize = Clamp(
            CraftingSelectionSize,
            0,
            CaelumConstants.EQUIPMENT_SIZE_COUNT - 1
        );

        CraftingSelectedRecipeKind =
            CaelumCraftingRules.GetUnifiedRecipeKind(
                CraftingSelectionRecipe
            );
        CraftingSelectedWeapon = -1;

        if (CraftingSelectedRecipeKind
            == CaelumConstants.CRAFTING_RECIPE_KIND_PHYSICAL_WEAPON)
        {
            int physicalIndex =
                CaelumCraftingRules.GetUnifiedPhysicalRecipeIndex(
                    CraftingSelectionRecipe
                );
            CraftingSelectedWeapon =
                CaelumCraftingRules.GetStationRecipeWeapon(
                    CaelumConstants.CRAFTING_STATION_WORKBENCH,
                    physicalIndex
                );

            CraftingBasicMaterialType =
                CaelumCraftingRules.GetBasicMaterial(
                    CraftingSelectedWeapon
                );
            CraftingTierMaterialType =
                CaelumCraftingRules.GetTierMaterial(
                    CraftingSelectedWeapon
                );
            CraftingFinalWeight =
                CaelumCraftingRules.GetCraftedWeaponWeight(
                    CaelumCraftingRules.GetPlayableTierOneWeight(
                        CraftingSelectedWeapon
                    ),
                    CraftingSelectionTier,
                    CraftingSelectionSize
                );
            CraftingBasicRequired =
                CaelumCraftingRules.GetRequiredBasicMaterialUnits(
                    CraftingSelectedWeapon, CraftingFinalWeight
                );
            CraftingTierRequired =
                CaelumCraftingRules.GetRequiredTierMaterialUnits(
                    CraftingSelectedWeapon, CraftingFinalWeight
                );
            CraftingMissingStationType =
                CaelumCraftingRules.GetMissingNetworkStation(
                    CraftingNetworkCapabilities,
                    CraftingSelectionTier,
                    CraftingSelectedWeapon
                );
        }
        else if (CraftingSelectedRecipeKind
            == CaelumConstants.CRAFTING_RECIPE_KIND_ARMOR)
        {
            CraftingSelectedArmorType =
                CaelumCraftingRules.GetUnifiedArmorType(
                    CraftingSelectionRecipe
                );
            CraftingSelectedArmorSlot =
                CaelumCraftingRules.GetUnifiedArmorSlot(
                    CraftingSelectionRecipe
                );

            CraftingBasicMaterialType = CaelumConstants.MATERIAL_STRAP;
            CraftingTierMaterialType =
                CaelumCraftingRules.GetArmorTierMaterial(
                    CraftingSelectedArmorType
                );
            CraftingFinalWeight = ArmorModel != null
                ? ArmorModel.GetWeightFor(
                    CraftingSelectedArmorSlot,
                    CraftingSelectedArmorType,
                    CraftingSelectionTier,
                    CraftingSelectionSize
                )
                : 0.0;
            CraftingBasicRequired =
                CaelumCraftingRules.GetRequiredArmorBaseUnits(
                    CraftingSelectedArmorSlot, CraftingFinalWeight
                );
            CraftingTierRequired =
                CaelumCraftingRules.GetRequiredArmorTierUnits(
                    CraftingSelectedArmorSlot, CraftingFinalWeight
                );
            CraftingMissingStationType =
                CaelumCraftingRules.GetMissingArmorStation(
                    CraftingNetworkCapabilities,
                    CraftingSelectionTier,
                    CraftingSelectedArmorType
                );
        }
        else if (CraftingSelectedRecipeKind
            == CaelumConstants.CRAFTING_RECIPE_KIND_ESSENCE_WEAPON)
        {
            CraftingSelectedEssenceWeaponType =
                CaelumCraftingRules.GetUnifiedEssenceWeaponType(
                    CraftingSelectionRecipe
                );
            CraftingSelectedEssenceType =
                CaelumCraftingRules.GetUnifiedEssenceType(
                    CraftingSelectionRecipe
                );

            CraftingBasicMaterialType =
                CaelumCraftingRules.GetEssenceBaseMaterial(
                    CraftingSelectedEssenceWeaponType
                );
            CraftingTierMaterialType =
                CaelumCraftingRules.GetEssenceMaterial(
                    CraftingSelectedEssenceType
                );
            CraftingFinalWeight =
                CaelumCraftingRules.GetCraftedWeaponWeight(
                    CaelumCraftingRules.GetEssenceTierOneWeight(
                        CraftingSelectedEssenceWeaponType
                    ),
                    CraftingSelectionTier,
                    CraftingSelectionSize
                );
            CraftingBasicRequired =
                CaelumCraftingRules.GetRequiredEssenceBaseUnits(
                    CraftingFinalWeight
                );
            CraftingTierRequired =
                CaelumCraftingRules.GetRequiredEssenceUnits(
                    CraftingFinalWeight
                );
            CraftingMissingStationType =
                CaelumCraftingRules.GetMissingEssenceStation(
                    CraftingNetworkCapabilities,
                    CraftingSelectionTier
                );
        }

        else if (CraftingSelectedRecipeKind == CaelumConstants.CRAFTING_RECIPE_KIND_AMULET)
        {
            CraftingSelectedAmuletType = CaelumCraftingRules.GetUnifiedAmuletType(CraftingSelectionRecipe);
            CraftingSelectionSize = CaelumConstants.EQUIPMENT_SIZE_M;
            CraftingBasicMaterialType = CaelumConstants.MATERIAL_SILVER_CHAIN;
            CraftingTierMaterialType = CaelumCraftingRules.GetAmuletTierMaterial(CraftingSelectedAmuletType);
            CraftingFinalWeight = CaelumCraftingRules.GetJewelryWeight(CraftingSelectionTier);
            CraftingBasicRequired = CaelumCraftingRules.GetRequiredAmuletBaseUnits(CraftingFinalWeight);
            CraftingTierRequired = CaelumCraftingRules.GetRequiredAmuletTierUnits(CraftingFinalWeight);
            CraftingMissingStationType = CaelumCraftingRules.GetMissingJewelryStation(CraftingNetworkCapabilities, CraftingSelectionTier);
        }
        else
        {
            CraftingSelectedSealType = CaelumCraftingRules.GetUnifiedSealType(CraftingSelectionRecipe);
            CraftingSelectionSize = CaelumConstants.EQUIPMENT_SIZE_M;
            CraftingBasicMaterialType = CaelumConstants.MATERIAL_SEAL_BASE;
            CraftingTierMaterialType = CaelumCraftingRules.GetSealTierMaterial(CraftingSelectedSealType);
            CraftingFinalWeight = CaelumCraftingRules.GetJewelryWeight(CraftingSelectionTier);
            CraftingBasicRequired = CaelumCraftingRules.GetRequiredSealBaseUnits(CraftingFinalWeight);
            CraftingTierRequired = CaelumCraftingRules.GetRequiredSealTierUnits(CraftingFinalWeight);
            CraftingMissingStationType = CaelumCraftingRules.GetMissingJewelryStation(CraftingNetworkCapabilities, CraftingSelectionTier);
        }

        // El material base siempre es estructural y permanece en tier 1.
        CraftingBasicMaterialTier = CaelumMaterialRules.ResolveTier(
            CraftingBasicMaterialType, 1
        );
        CraftingTierMaterialTier = CaelumMaterialRules.ResolveTier(
            CraftingTierMaterialType, CraftingSelectionTier
        );

        CraftingBasicOwned = CountCraftingMaterial(
            CraftingBasicMaterialType, CraftingBasicMaterialTier
        );
        CraftingTierOwned = CountCraftingMaterial(
            CraftingTierMaterialType, CraftingTierMaterialTier
        );

        CraftingSelectedInfrastructureAvailable =
            CraftingMissingStationType
                == CaelumConstants.CRAFTING_STATION_NONE;

        RefreshCarriedInventorySummary();
    }

    int BeginCraftingNetworkScan()
    {
        CraftingNetworkCapabilities = 0;
        CraftingNetworkScanToken++;
        if (CraftingNetworkScanToken <= 0) { CraftingNetworkScanToken = 1; }
        return CraftingNetworkScanToken;
    }

    void OpenCraftingNetwork()
    {
        bool hasPrimaryStation;

        if (!CaelumCraftingRules.NetworkHasStation(
            CraftingNetworkCapabilities,
            CaelumConstants.CRAFTING_STATION_WORKBENCH
        ))
        {
            A_Log("$CA_CRAFTING_NETWORK_MISSING_WORKBENCH");
            CraftingMenuOpen = false;
            return;
        }

        hasPrimaryStation =
            CaelumCraftingRules.NetworkHasStation(
                CraftingNetworkCapabilities,
                CaelumConstants.CRAFTING_STATION_FORGE
            )
            || CaelumCraftingRules.NetworkHasStation(
                CraftingNetworkCapabilities,
                CaelumConstants.CRAFTING_STATION_BOW_WORKSHOP
            )
            || CaelumCraftingRules.NetworkHasStation(
                CraftingNetworkCapabilities,
                CaelumConstants.CRAFTING_STATION_ARMOR_WORKSHOP
            )
            || CaelumCraftingRules.NetworkHasStation(
                CraftingNetworkCapabilities,
                CaelumConstants.CRAFTING_STATION_ESSENCE_ALTAR
            )
            || CaelumCraftingRules.NetworkHasStation(
                CraftingNetworkCapabilities,
                CaelumConstants.CRAFTING_STATION_JEWELER_BENCH
            );

        if (!hasPrimaryStation)
        {
            A_Log("$CA_CRAFTING_NETWORK_MISSING_PRIMARY");
            CraftingMenuOpen = false;
            return;
        }

        // Cualquier estación conectada abre el mismo menú central.
        OpenCraftingStation(CaelumConstants.CRAFTING_STATION_WORKBENCH);
    }

    void OpenCraftingStation(int stationType)
    {
        if (CreationWizardOpen) { return; }
        int resolvedStation = CaelumCraftingRules.ResolveStationType(stationType);
        if (resolvedStation == CaelumConstants.CRAFTING_STATION_NONE) { return; }

        if (StaffCastPending) { CancelPendingStaffCast(false); }
        EquipmentMenuOpen = false;
        CraftingMenuOpen = true;
        ActiveCraftingStationType = resolvedStation;
        CraftingSelectionRecipe = 0;
        if (CraftingSelectionTier <= 0)
        {
            CraftingSelectionTier = 1;
            CraftingSelectionSize = CaelumConstants.EQUIPMENT_SIZE_M;
        }
        LastCraftingAction = CaelumConstants.CRAFTING_ACTION_NONE;
        RefreshCraftingPreview();
    }

    void ToggleCraftingMenu()
    {
        // La tecla de crafteo ya no abre una estación virtual desde cualquier
        // lugar. Sirve para cerrar el menú; la apertura real ocurre usando
        // un actor CaelumCraftingStation del escenario.
        if (CraftingMenuOpen)
        {
            CraftingMenuOpen = false;
            ActiveCraftingStationType = CaelumConstants.CRAFTING_STATION_NONE;
        }
    }

    void CycleCraftingRecipe(int direction)
    {
        int stationRecipeCount = CaelumCraftingRules.GetStationRecipeCount(
            ActiveCraftingStationType
        );
        if (stationRecipeCount <= 0) { return; }
        CraftingSelectionRecipe = (
            CraftingSelectionRecipe + direction + stationRecipeCount
        ) % stationRecipeCount;
        LastCraftingAction = CaelumConstants.CRAFTING_ACTION_NONE;
        RefreshCraftingPreview();
    }

    void CycleCraftingTier()
    {
        CraftingSelectionTier = CraftingSelectionTier % 3 + 1;
        LastCraftingAction = CaelumConstants.CRAFTING_ACTION_NONE;
        RefreshCraftingPreview();
    }

    void CycleCraftingSize()
    {
        RefreshCraftingPreview();
        if (CraftingSelectedRecipeKind == CaelumConstants.CRAFTING_RECIPE_KIND_AMULET
            || CraftingSelectedRecipeKind == CaelumConstants.CRAFTING_RECIPE_KIND_SEAL)
        {
            CraftingSelectionSize = CaelumConstants.EQUIPMENT_SIZE_M;
            return;
        }
        CraftingSelectionSize = (CraftingSelectionSize + 1)
            % CaelumConstants.EQUIPMENT_SIZE_COUNT;
        LastCraftingAction = CaelumConstants.CRAFTING_ACTION_NONE;
        RefreshCraftingPreview();
    }

    bool ConsumeCraftingMaterial(
        int materialType, int materialTier, int requiredAmount
    )
    {
        CaelumSpecialInventoryItem material = FindNativeSpecialItem(
            CaelumConstants.EQUIPMENT_KIND_MATERIAL,
            materialType,
            materialTier
        );
        if (material == null || material.Amount < requiredAmount)
        {
            return false;
        }
        material.Amount -= requiredAmount;
        if (material.Amount <= 0) { material.Destroy(); }
        return true;
    }

    void SpawnSelectedCraftingMaterials()
    {
        if (player == null || player.playerstate != PST_LIVE) { return; }
        RefreshCraftingPreview();
        if (CraftingSelectedRecipeKind
                == CaelumConstants.CRAFTING_RECIPE_KIND_PHYSICAL_WEAPON
            && CraftingSelectedWeapon < 0)
        {
            LastCraftingAction = CaelumConstants.CRAFTING_ACTION_FAILED_STATION;
            return;
        }
        Vector3 forward = (Cos(Angle) * 56.0, Sin(Angle) * 56.0, 8.0);
        Vector3 side = (-Sin(Angle) * 18.0, Cos(Angle) * 18.0, 0.0);
        CaelumMaterialPickup basicMaterial = CaelumMaterialPickup(
            Spawn("CaelumMaterialPickup", Pos + forward - side, NO_REPLACE)
        );
        if (basicMaterial != null)
        {
            basicMaterial.args[0] = CraftingBasicMaterialType;
            basicMaterial.args[1] = CraftingBasicMaterialTier;
            basicMaterial.Amount = CraftingBasicRequired;
        }
        CaelumMaterialPickup tierMaterial = CaelumMaterialPickup(
            Spawn("CaelumMaterialPickup", Pos + forward + side, NO_REPLACE)
        );
        if (tierMaterial != null)
        {
            tierMaterial.args[0] = CraftingTierMaterialType;
            tierMaterial.args[1] = CraftingTierMaterialTier;
            tierMaterial.Amount = CraftingTierRequired;
        }
        LastCraftingAction =
            CaelumConstants.CRAFTING_ACTION_MATERIALS_SPAWNED;
    }

    void CraftSelectedArmorRecipe()
    {
        if (ArmorModel == null) { return; }
        RefreshCraftingPreview();

        if (CraftingSelectedRecipeKind
            != CaelumConstants.CRAFTING_RECIPE_KIND_ARMOR)
        {
            LastCraftingAction = CaelumConstants.CRAFTING_ACTION_FAILED_STATION;
            return;
        }
        if (!CraftingSelectedInfrastructureAvailable)
        {
            LastCraftingAction =
                CaelumConstants.CRAFTING_ACTION_FAILED_INFRASTRUCTURE;
            return;
        }
        if (FindNativeEquipmentItem(
            CaelumConstants.EQUIPMENT_KIND_ARMOR,
            CraftingSelectedArmorType,
            CraftingSelectedArmorSlot,
            CraftingSelectionTier,
            CraftingSelectionSize
        ) != null)
        {
            LastCraftingAction =
                CaelumConstants.CRAFTING_ACTION_FAILED_DUPLICATE;
            return;
        }
        if (MagicBoxUsedSlots >= MagicBoxMaximumSlots)
        {
            LastCraftingAction =
                CaelumConstants.CRAFTING_ACTION_FAILED_BOX_FULL;
            return;
        }
        if (CraftingBasicOwned < CraftingBasicRequired
            || CraftingTierOwned < CraftingTierRequired)
        {
            LastCraftingAction =
                CaelumConstants.CRAFTING_ACTION_FAILED_MATERIALS;
            return;
        }

        CaelumEquipmentItem result = CaelumEquipmentItem(
            Spawn("CaelumArmorPickup", Pos, NO_REPLACE)
        );
        if (result == null)
        {
            LastCraftingAction =
                CaelumConstants.CRAFTING_ACTION_FAILED_MATERIALS;
            return;
        }

        if (!ConsumeCraftingMaterial(
                CraftingBasicMaterialType,
                CraftingBasicMaterialTier,
                CraftingBasicRequired
            )
            || !ConsumeCraftingMaterial(
                CraftingTierMaterialType,
                CraftingTierMaterialTier,
                CraftingTierRequired
            ))
        {
            result.Destroy();
            LastCraftingAction =
                CaelumConstants.CRAFTING_ACTION_FAILED_MATERIALS;
            return;
        }

        result.EquipmentKind = CaelumConstants.EQUIPMENT_KIND_ARMOR;
        result.ItemType = CraftingSelectedArmorType;
        result.ArmorSlot = CraftingSelectedArmorSlot;
        result.Tier = CraftingSelectionTier;
        result.EquipmentSize = CraftingSelectionSize;
        result.Durability = ArmorModel.GetMaximumDurabilityFor(
            CraftingSelectedArmorType,
            CraftingSelectionTier,
            CraftingSelectionSize
        );
        result.EssenceType = CaelumConstants.ESSENCE_FIRE;
        result.UnitWeight = ArmorModel.GetWeightFor(
            CraftingSelectedArmorSlot,
            CraftingSelectedArmorType,
            CraftingSelectionTier,
            CraftingSelectionSize
        );
        result.Equipped = false;
        result.InMagicBox = true;
        result.PickupDataInitialized = true;
        result.AttachToOwner(self);

        CaelumPersistentCharacterState persistentState =
            GetPersistentCharacterState(true);
        if (persistentState != null)
        {
            persistentState.RegisterOwnedArmor(
                CraftingSelectedArmorSlot,
                CraftingSelectedArmorType,
                CraftingSelectionTier,
                CraftingSelectionSize,
                result.Durability
            );
            persistentState.SetArmorInMagicBox(
                CraftingSelectedArmorSlot,
                CraftingSelectedArmorType,
                CraftingSelectionTier,
                CraftingSelectionSize,
                true
            );
        }

        LastCraftingAction = CaelumConstants.CRAFTING_ACTION_CREATED;
        ApplyCharacterProfile();
        PersistCharacterState();
        RefreshEquipmentSelectionPreview();
        RefreshCraftingPreview();
    }

    void CraftSelectedEssenceWeaponRecipe()
    {
        if (WeaponModel == null) { return; }
        RefreshCraftingPreview();

        if (CraftingSelectedRecipeKind
            != CaelumConstants.CRAFTING_RECIPE_KIND_ESSENCE_WEAPON)
        {
            LastCraftingAction = CaelumConstants.CRAFTING_ACTION_FAILED_STATION;
            return;
        }
        if (!CraftingSelectedInfrastructureAvailable)
        {
            LastCraftingAction =
                CaelumConstants.CRAFTING_ACTION_FAILED_INFRASTRUCTURE;
            return;
        }
        if (FindNativeMagicWeaponItem(
            CraftingSelectedEssenceWeaponType,
            CraftingSelectedEssenceType,
            CraftingSelectionTier,
            CraftingSelectionSize
        ) != null)
        {
            LastCraftingAction =
                CaelumConstants.CRAFTING_ACTION_FAILED_DUPLICATE;
            return;
        }
        if (MagicBoxUsedSlots >= MagicBoxMaximumSlots)
        {
            LastCraftingAction =
                CaelumConstants.CRAFTING_ACTION_FAILED_BOX_FULL;
            return;
        }
        if (CraftingBasicOwned < CraftingBasicRequired
            || CraftingTierOwned < CraftingTierRequired)
        {
            LastCraftingAction =
                CaelumConstants.CRAFTING_ACTION_FAILED_MATERIALS;
            return;
        }

        CaelumEquipmentItem result = CaelumEquipmentItem(
            Spawn("CaelumWeaponPickup", Pos, NO_REPLACE)
        );
        if (result == null)
        {
            LastCraftingAction =
                CaelumConstants.CRAFTING_ACTION_FAILED_MATERIALS;
            return;
        }

        if (!ConsumeCraftingMaterial(
                CraftingBasicMaterialType,
                CraftingBasicMaterialTier,
                CraftingBasicRequired
            )
            || !ConsumeCraftingMaterial(
                CraftingTierMaterialType,
                CraftingTierMaterialTier,
                CraftingTierRequired
            ))
        {
            result.Destroy();
            LastCraftingAction =
                CaelumConstants.CRAFTING_ACTION_FAILED_MATERIALS;
            return;
        }

        result.EquipmentKind = CaelumConstants.EQUIPMENT_KIND_WEAPON;
        result.ItemType = CraftingSelectedEssenceWeaponType;
        result.ArmorSlot = -1;
        result.Tier = CraftingSelectionTier;
        result.EquipmentSize = CraftingSelectionSize;
        result.Durability = WeaponModel.GetMaximumDurabilityFor(
            CraftingSelectedEssenceWeaponType,
            CraftingSelectionTier,
            CraftingSelectionSize
        );
        result.EssenceType = CraftingSelectedEssenceType;
        result.UnitWeight = WeaponModel.GetWeightFor(
            CraftingSelectedEssenceWeaponType,
            CraftingSelectionTier,
            CraftingSelectionSize
        );
        result.Equipped = false;
        result.InMagicBox = true;
        result.PickupDataInitialized = true;
        result.AttachToOwner(self);

        CaelumPersistentCharacterState persistentState =
            GetPersistentCharacterState(true);
        if (persistentState != null)
        {
            persistentState.RegisterOwnedWeapon(
                CraftingSelectedEssenceWeaponType,
                CraftingSelectionTier,
                CraftingSelectionSize,
                result.Durability
            );
            persistentState.SetWeaponInMagicBox(
                CraftingSelectedEssenceWeaponType,
                CraftingSelectionTier,
                CraftingSelectionSize,
                true
            );
            persistentState.SetWeaponEquipped(
                CraftingSelectedEssenceWeaponType,
                CraftingSelectionTier,
                CraftingSelectionSize,
                false
            );
        }

        LastCraftingAction = CaelumConstants.CRAFTING_ACTION_CREATED;
        ApplyCharacterProfile();
        PersistCharacterState();
        RefreshEquipmentSelectionPreview();
        RefreshCraftingPreview();
    }

    void CraftSelectedJewelry(bool seal)
    {
        RefreshCraftingPreview();
        int expected = seal ? CaelumConstants.CRAFTING_RECIPE_KIND_SEAL
            : CaelumConstants.CRAFTING_RECIPE_KIND_AMULET;
        if (CraftingSelectedRecipeKind != expected) return;
        if (!CraftingSelectedInfrastructureAvailable)
        { LastCraftingAction = CaelumConstants.CRAFTING_ACTION_FAILED_INFRASTRUCTURE; return; }
        int kind = seal ? CaelumConstants.EQUIPMENT_KIND_SEAL : CaelumConstants.EQUIPMENT_KIND_AMULET;
        int type = seal ? CraftingSelectedSealType : CraftingSelectedAmuletType;
        if (FindNativeEquipmentItem(kind,type,-1,CraftingSelectionTier,CaelumConstants.EQUIPMENT_SIZE_M) != null)
        { LastCraftingAction = CaelumConstants.CRAFTING_ACTION_FAILED_DUPLICATE; return; }
        if (MagicBoxUsedSlots >= MagicBoxMaximumSlots)
        { LastCraftingAction = CaelumConstants.CRAFTING_ACTION_FAILED_BOX_FULL; return; }
        if (CraftingBasicOwned < CraftingBasicRequired || CraftingTierOwned < CraftingTierRequired)
        { LastCraftingAction = CaelumConstants.CRAFTING_ACTION_FAILED_MATERIALS; return; }

        CaelumEquipmentItem result;
        if (seal)
        {
            result = CaelumEquipmentItem(
                Spawn("CaelumSealPickup", Pos, NO_REPLACE)
            );
        }
        else
        {
            result = CaelumEquipmentItem(
                Spawn("CaelumAmuletPickup", Pos, NO_REPLACE)
            );
        }
        if (result == null) { LastCraftingAction = CaelumConstants.CRAFTING_ACTION_FAILED_MATERIALS; return; }
        // La transacción nunca puede degradarse silenciosamente a una pieza de
        // armadura aunque exista una colisión o reemplazo de clases externos.
        if ((seal && CaelumSealPickup(result) == null)
            || (!seal && CaelumAmuletPickup(result) == null))
        {
            result.Destroy();
            LastCraftingAction = CaelumConstants.CRAFTING_ACTION_FAILED_STATION;
            return;
        }
        if (!ConsumeCraftingMaterial(CraftingBasicMaterialType,CraftingBasicMaterialTier,CraftingBasicRequired)
            || !ConsumeCraftingMaterial(CraftingTierMaterialType,CraftingTierMaterialTier,CraftingTierRequired))
        { result.Destroy(); LastCraftingAction = CaelumConstants.CRAFTING_ACTION_FAILED_MATERIALS; return; }

        result.EquipmentKind=kind; result.ItemType=type; result.ArmorSlot=-1;
        result.Tier=CraftingSelectionTier; result.EquipmentSize=CaelumConstants.EQUIPMENT_SIZE_M;
        result.Durability=0; result.EssenceType=seal ? type : CaelumConstants.ESSENCE_FIRE;
        result.UnitWeight=CaelumCraftingRules.GetJewelryWeight(CraftingSelectionTier);
        result.Equipped=false; result.InMagicBox=true; result.PickupDataInitialized=true; result.AttachToOwner(self);
        LastCraftingAction=CaelumConstants.CRAFTING_ACTION_CREATED;
        ApplyCharacterProfile();
        PersistCharacterState();
        RefreshCraftingPreview();
        // Se aplica al final de la transacción, después de toda sincronización,
        // para que ninguna actualización intermedia restaure Cabeza/Armadura.
        EquipmentSelectionKind = kind;
        EquipmentSelectionTier = CraftingSelectionTier;
        EquipmentSelectionSize = CaelumConstants.EQUIPMENT_SIZE_M;
        if (seal) { EquipmentSelectionSealType = type; }
        else { EquipmentSelectionAmuletType = type; }
        RefreshEquipmentSelectionPreview();
    }

    void CraftSelectedPhysicalWeapon()
    {
        RefreshCraftingPreview();

        if (CraftingSelectedRecipeKind
            == CaelumConstants.CRAFTING_RECIPE_KIND_ARMOR)
        {
            CraftSelectedArmorRecipe();
            return;
        }
        if (CraftingSelectedRecipeKind
            == CaelumConstants.CRAFTING_RECIPE_KIND_ESSENCE_WEAPON)
        {
            CraftSelectedEssenceWeaponRecipe();
            return;
        }
        if (CraftingSelectedRecipeKind == CaelumConstants.CRAFTING_RECIPE_KIND_AMULET)
        { CraftSelectedJewelry(false); return; }
        if (CraftingSelectedRecipeKind == CaelumConstants.CRAFTING_RECIPE_KIND_SEAL)
        { CraftSelectedJewelry(true); return; }

        if (CraftingSelectedWeapon < 0)
        {
            LastCraftingAction = CaelumConstants.CRAFTING_ACTION_FAILED_STATION;
            return;
        }
        if (!CaelumCraftingRules.CanNetworkCraftWeapon(
            CraftingNetworkCapabilities,
            CraftingSelectionTier,
            CraftingSelectedWeapon
        ))
        {
            CraftingMissingStationType =
                CaelumCraftingRules.GetMissingNetworkStation(
                    CraftingNetworkCapabilities,
                    CraftingSelectionTier,
                    CraftingSelectedWeapon
                );
            CraftingSelectedInfrastructureAvailable = false;
            LastCraftingAction =
                CaelumConstants.CRAFTING_ACTION_FAILED_INFRASTRUCTURE;
            return;
        }
        int playableWeaponType = CaelumCraftingRules.GetPlayableWeaponType(
            CraftingSelectedWeapon
        );
        if (playableWeaponType < 0 || WeaponModel == null) { return; }
        if (FindNativeEquipmentItem(
            CaelumConstants.EQUIPMENT_KIND_WEAPON,
            playableWeaponType,
            -1,
            CraftingSelectionTier,
            CraftingSelectionSize
        ) != null)
        {
            LastCraftingAction =
                CaelumConstants.CRAFTING_ACTION_FAILED_DUPLICATE;
            return;
        }
        if (MagicBoxUsedSlots >= MagicBoxMaximumSlots)
        {
            LastCraftingAction =
                CaelumConstants.CRAFTING_ACTION_FAILED_BOX_FULL;
            return;
        }
        if (CraftingBasicOwned < CraftingBasicRequired
            || CraftingTierOwned < CraftingTierRequired)
        {
            LastCraftingAction =
                CaelumConstants.CRAFTING_ACTION_FAILED_MATERIALS;
            return;
        }

        CaelumEquipmentItem result = CaelumEquipmentItem(
            Spawn("CaelumWeaponPickup", Pos, NO_REPLACE)
        );
        if (result == null)
        {
            LastCraftingAction =
                CaelumConstants.CRAFTING_ACTION_FAILED_MATERIALS;
            return;
        }

        // La validación completa ocurre antes de modificar pilas. Como los
        // componentes de estas recetas son distintos, ambas restas son una
        // única transacción lógica y nunca dejan un crafteo parcial.
        if (!ConsumeCraftingMaterial(
                CraftingBasicMaterialType,
                CraftingBasicMaterialTier,
                CraftingBasicRequired
            )
            || !ConsumeCraftingMaterial(
                CraftingTierMaterialType,
                CraftingTierMaterialTier,
                CraftingTierRequired
            ))
        {
            result.Destroy();
            LastCraftingAction =
                CaelumConstants.CRAFTING_ACTION_FAILED_MATERIALS;
            return;
        }
        result.EquipmentKind = CaelumConstants.EQUIPMENT_KIND_WEAPON;
        result.ItemType = playableWeaponType;
        result.ArmorSlot = -1;
        result.Tier = CraftingSelectionTier;
        result.EquipmentSize = CraftingSelectionSize;
        result.Durability = WeaponModel.GetMaximumDurabilityFor(
            playableWeaponType,
            CraftingSelectionTier,
            CraftingSelectionSize
        );
        result.EssenceType = CaelumConstants.ESSENCE_FIRE;
        result.UnitWeight = WeaponModel.GetWeightFor(
            playableWeaponType,
            CraftingSelectionTier,
            CraftingSelectionSize
        );
        result.Equipped = false;
        result.InMagicBox = true;
        result.AttachToOwner(self);

        CaelumPersistentCharacterState persistentState =
            GetPersistentCharacterState(true);
        if (persistentState != null)
        {
            persistentState.RegisterOwnedWeapon(
                playableWeaponType,
                CraftingSelectionTier,
                CraftingSelectionSize,
                result.Durability
            );
            persistentState.SetWeaponInMagicBox(
                playableWeaponType,
                CraftingSelectionTier,
                CraftingSelectionSize,
                true
            );
            persistentState.SetWeaponEquipped(
                playableWeaponType,
                CraftingSelectionTier,
                CraftingSelectionSize,
                false
            );
        }

        LastCraftingAction = CaelumConstants.CRAFTING_ACTION_CREATED;
        ApplyCharacterProfile();
        PersistCharacterState();
        RefreshEquipmentSelectionPreview();
        RefreshCraftingPreview();
    }

    void ToggleEquipmentMenu()
    {
        if (CreationWizardOpen) { return; }
        EquipmentMenuOpen = !EquipmentMenuOpen;
        if (!EquipmentMenuOpen) { return; }
        if (StaffCastPending) { CancelPendingStaffCast(false); }
        CraftingMenuOpen = false;
        ActiveCraftingStationType = CaelumConstants.CRAFTING_STATION_NONE;
        LastEquipmentAction = CaelumConstants.EQUIPMENT_ACTION_NONE;
        PersistCharacterState();

        // Conserva la familia seleccionada. Forzar ARMOR en cada apertura
        // ocultaba el sello o amuleto recién fabricado detrás de un casco.
        if (ArmorModel != null
            && EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_ARMOR)
        {
            EquipmentSelectionKind = CaelumConstants.EQUIPMENT_KIND_ARMOR;
            EquipmentSelectionSlot = ArmorModel.SelectedSlot;
            EquipmentSelectionArmorType = ArmorModel.ArmorType[EquipmentSelectionSlot];
            EquipmentSelectionTier = ArmorModel.Tier[EquipmentSelectionSlot];
            EquipmentSelectionSize = ArmorModel.Size[EquipmentSelectionSlot];
        }
        if (ShieldModel != null)
        {
            EquipmentSelectionShieldType = ShieldModel.ShieldType;
        }
        if (WeaponModel != null)
        {
            EquipmentSelectionWeaponType = WeaponModel.WeaponType;
        }
        RefreshEquipmentSelectionPreview();
    }

    void CycleEquipmentKind()
    {
        EquipmentSelectionKind = (EquipmentSelectionKind + 1)
            % CaelumConstants.EQUIPMENT_KIND_COUNT;
        RefreshEquipmentSelectionPreview();
    }

    Name GetConsumableClassName(int consumableType)
    {
        switch (consumableType)
        {
            case CaelumConstants.CONSUMABLE_ANIMA_POTION:
                return 'CaelumAnimaPotion';
            case CaelumConstants.CONSUMABLE_ENERGY_DRINK:
                return 'CaelumEnergyDrink';
            case CaelumConstants.CONSUMABLE_FOOD_RATION:
                return 'CaelumFoodRation';
            case CaelumConstants.CONSUMABLE_WATER_RATION:
                return 'CaelumWaterRation';
            default:
                return 'CaelumLifePotion';
        }
    }

    double GetAmmunitionUnitWeight(int ammunitionType)
    {
        switch (ammunitionType)
        {
            case CaelumConstants.AMMUNITION_ARROW:
                return CaelumConstants.ARROW_AMMO_UNIT_WEIGHT;
            case CaelumConstants.AMMUNITION_BOLT:
                return CaelumConstants.BOLT_AMMO_UNIT_WEIGHT;
            case CaelumConstants.AMMUNITION_JAVELIN_TIER_ONE:
                return CaelumConstants.JAVELIN_TIER_ONE_AMMO_UNIT_WEIGHT;
            case CaelumConstants.AMMUNITION_JAVELIN_TIER_TWO:
                return CaelumConstants.JAVELIN_TIER_TWO_AMMO_UNIT_WEIGHT;
            case CaelumConstants.AMMUNITION_JAVELIN_TIER_THREE:
                return CaelumConstants.JAVELIN_TIER_THREE_AMMO_UNIT_WEIGHT;
            default:
                return CaelumConstants.CARBINE_AMMO_UNIT_WEIGHT;
        }
    }

    Name GetAmmunitionClassName(int ammunitionType)
    {
        switch (ammunitionType)
        {
            case CaelumConstants.AMMUNITION_ARROW:
                return 'CaelumArrowAmmo';
            case CaelumConstants.AMMUNITION_BOLT:
                return 'CaelumBoltAmmo';
            case CaelumConstants.AMMUNITION_JAVELIN_TIER_ONE:
                return 'CaelumJavelinTierOneAmmo';
            case CaelumConstants.AMMUNITION_JAVELIN_TIER_TWO:
                return 'CaelumJavelinTierTwoAmmo';
            case CaelumConstants.AMMUNITION_JAVELIN_TIER_THREE:
                return 'CaelumJavelinTierThreeAmmo';
            default:
                return 'CaelumCarbineAmmo';
        }
    }

    Name GetSpecialItemClassName(int specialCategory, int specialType)
    {
        if (specialCategory == CaelumConstants.EQUIPMENT_KIND_KEY)
        {
            return 'CaelumSilverKey';
        }
        if (specialCategory == CaelumConstants.EQUIPMENT_KIND_KEY_ITEM)
        {
            return 'CaelumSealedLetter';
        }
        if (specialType == CaelumConstants.MATERIAL_IRON_INGOT)
        {
            return 'CaelumIronIngot';
        }
        return 'CaelumMaterialPickup';
    }

    void UseSelectedConsumable()
    {
        LastEquipmentAction = CaelumConstants.EQUIPMENT_ACTION_FAILED_NOT_OWNED;
        CaelumConsumableItem consumable = FindNativeConsumableItem(
            EquipmentSelectionConsumableType
        );
        if (consumable == null || consumable.Amount <= 0
            || consumable.InMagicBox)
        {
            return;
        }
        if (!UseInventory(consumable)) { return; }
        OnNativeInventoryChanged();
        LastEquipmentAction = CaelumConstants.EQUIPMENT_ACTION_USED;
    }

    void CycleEquipmentSlot(int direction)
    {
        if (EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_WEAPON
            && WeaponModel != null
            && WeaponModel.IsMagicalType(EquipmentSelectionWeaponType))
        {
            // En armas mágicas la dimensión equivalente a "slot" del menú es
            // el elemento. Nunca mutamos EssenceType de otra instancia.
            EquipmentSelectionWeaponEssenceType = (
                EquipmentSelectionWeaponEssenceType + direction
                    + CaelumConstants.ESSENCE_TYPE_COUNT
            ) % CaelumConstants.ESSENCE_TYPE_COUNT;
            SelectedEssenceType = EquipmentSelectionWeaponEssenceType;
            RefreshEquipmentSelectionPreview();
            return;
        }
        if (EquipmentSelectionKind
                == CaelumConstants.EQUIPMENT_KIND_AMMUNITION
            || EquipmentSelectionKind
                == CaelumConstants.EQUIPMENT_KIND_CONSUMABLE
            || EquipmentSelectionKind
                >= CaelumConstants.EQUIPMENT_KIND_MATERIAL) { return; }
        EquipmentSelectionSlot = (
            EquipmentSelectionSlot + direction
                + CaelumConstants.ARMOR_SLOT_COUNT
        ) % CaelumConstants.ARMOR_SLOT_COUNT;
        RefreshEquipmentSelectionPreview();
    }

    void CycleEquipmentType(int direction)
    {
        if (EquipmentSelectionKind
            == CaelumConstants.EQUIPMENT_KIND_AMMUNITION)
        {
            EquipmentSelectionAmmunitionType = (
                EquipmentSelectionAmmunitionType + direction
                    + CaelumConstants.AMMUNITION_TYPE_COUNT
            ) % CaelumConstants.AMMUNITION_TYPE_COUNT;
        }
        else if (IsSpecialInventoryKind(EquipmentSelectionKind))
        {
            int typeCount = CaelumConstants.MATERIAL_TYPE_COUNT;
            int firstType = CaelumConstants.MATERIAL_FIRST_ACTIVE;
            if (EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_KEY)
            {
                typeCount = CaelumConstants.KEY_TYPE_COUNT;
                firstType = 0;
            }
            else if (EquipmentSelectionKind
                == CaelumConstants.EQUIPMENT_KIND_KEY_ITEM)
            {
                typeCount = CaelumConstants.KEY_ITEM_TYPE_COUNT;
                firstType = 0;
            }
            int selectableTypeCount = typeCount - firstType;
            EquipmentSelectionSpecialType = firstType + (
                EquipmentSelectionSpecialType - firstType + direction
                    + selectableTypeCount
            ) % selectableTypeCount;
        }
        else if (EquipmentSelectionKind
            == CaelumConstants.EQUIPMENT_KIND_CONSUMABLE)
        {
            EquipmentSelectionConsumableType = (
                EquipmentSelectionConsumableType + direction
                    + CaelumConstants.CONSUMABLE_TYPE_COUNT
            ) % CaelumConstants.CONSUMABLE_TYPE_COUNT;
        }
        else if (EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_WEAPON)
        {
            EquipmentSelectionWeaponType = (
                EquipmentSelectionWeaponType + direction
                    + CaelumConstants.WEAPON_TYPE_COUNT
            ) % CaelumConstants.WEAPON_TYPE_COUNT;
        }
        else if (EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_SHIELD)
        {
            EquipmentSelectionShieldType = (
                EquipmentSelectionShieldType + direction
                    + CaelumConstants.SHIELD_TYPE_COUNT
            ) % CaelumConstants.SHIELD_TYPE_COUNT;
        }
        else if (EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_AMULET)
            EquipmentSelectionAmuletType=(EquipmentSelectionAmuletType+direction+CaelumConstants.AMULET_TYPE_COUNT)%CaelumConstants.AMULET_TYPE_COUNT;
        else if (EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_SEAL)
            EquipmentSelectionSealType=(EquipmentSelectionSealType+direction+CaelumConstants.SEAL_TYPE_COUNT)%CaelumConstants.SEAL_TYPE_COUNT;
        else
        {
            EquipmentSelectionArmorType = (
                EquipmentSelectionArmorType + direction
                    + CaelumConstants.ARMOR_EQUIPPABLE_TYPE_COUNT
            ) % CaelumConstants.ARMOR_EQUIPPABLE_TYPE_COUNT;
        }
        RefreshEquipmentSelectionPreview();
    }

    void CycleEquipmentTier()
    {
        if (EquipmentSelectionKind
                == CaelumConstants.EQUIPMENT_KIND_AMMUNITION
            || EquipmentSelectionKind
                == CaelumConstants.EQUIPMENT_KIND_CONSUMABLE
            || EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_KEY
            || EquipmentSelectionKind
                == CaelumConstants.EQUIPMENT_KIND_KEY_ITEM) { return; }
        if (EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_MATERIAL
            && !CaelumMaterialRules.HasTier(
                EquipmentSelectionSpecialType
            )) { return; }
        EquipmentSelectionTier++;
        if (EquipmentSelectionTier > 3) { EquipmentSelectionTier = 1; }
        RefreshEquipmentSelectionPreview();
    }

    void CycleEquipmentSize()
    {
        if (EquipmentSelectionKind
                == CaelumConstants.EQUIPMENT_KIND_AMMUNITION
            || EquipmentSelectionKind
                == CaelumConstants.EQUIPMENT_KIND_CONSUMABLE
            || EquipmentSelectionKind
                >= CaelumConstants.EQUIPMENT_KIND_MATERIAL)
        {
            return;
        }
        EquipmentSelectionSize = (EquipmentSelectionSize + 1)
            % CaelumConstants.EQUIPMENT_SIZE_COUNT;
        RefreshEquipmentSelectionPreview();
    }

    // Auditoría reproducible del catálogo: no crea ni consume inventario.
    // Sirve para detectar inmediatamente un material activo sin receta.
    void DebugAuditCraftingCatalogue()
    {
        int unusedMaterials = CaelumCraftingRules.CountUnusedActiveMaterials();
        Console.Printf(
            "[Caelum] Crafting 4.12: %d weapon recipes, %d active materials, %d unused.",
            CaelumConstants.CATALOGUE_PHYSICAL_WEAPON_COUNT,
            CaelumConstants.MATERIAL_TYPE_COUNT
                - CaelumConstants.MATERIAL_FIRST_ACTIVE,
            unusedMaterials
        );
        int swordBasic = CaelumCraftingRules.GetRequiredBasicMaterialUnits(
            CaelumConstants.CATALOGUE_WEAPON_SWORD,
            CaelumConstants.WEAPON_SWORD_TIER_ONE_WEIGHT
        );
        int swordTier = CaelumCraftingRules.GetRequiredTierMaterialUnits(
            CaelumConstants.CATALOGUE_WEAPON_SWORD,
            CaelumConstants.WEAPON_SWORD_TIER_ONE_WEIGHT
        );
        Console.Printf(
            "[Caelum] Sword M T1: basic %d, tier %d, material weight %.3f.",
            swordBasic, swordTier,
            CaelumCraftingRules.GetMaterialWeightForUnits(
                swordBasic + swordTier
            )
        );
        int carbineBasic = CaelumCraftingRules.GetRequiredBasicMaterialUnits(
            CaelumConstants.CATALOGUE_WEAPON_CARBINE,
            CaelumConstants.WEAPON_CARBINE_TIER_ONE_WEIGHT
        );
        int carbineTier = CaelumCraftingRules.GetRequiredTierMaterialUnits(
            CaelumConstants.CATALOGUE_WEAPON_CARBINE,
            CaelumConstants.WEAPON_CARBINE_TIER_ONE_WEIGHT
        );
        Console.Printf(
            "[Caelum] Carbine M T1: basic %d, tier %d, material weight %.3f.",
            carbineBasic, carbineTier,
            CaelumCraftingRules.GetMaterialWeightForUnits(
                carbineBasic + carbineTier
            )
        );
        for (int materialType = CaelumConstants.MATERIAL_FIRST_ACTIVE;
            materialType < CaelumConstants.MATERIAL_TYPE_COUNT;
            materialType++)
        {
            if (!CaelumCraftingRules.IsMaterialUsedByAnyRecipe(materialType))
            {
                Console.Printf("[Caelum] Unused material id: %d", materialType);
            }
        }
    }

    void SyncActiveModelsToNativeInventory()
    {
        if (ArmorModel != null)
        {
            for (int slot = 0; slot < CaelumConstants.ARMOR_SLOT_COUNT; slot++)
            {
                if (ArmorModel.ArmorType[slot]
                    == CaelumConstants.ARMOR_TYPE_BASE_CLOTHING)
                {
                    continue;
                }
                CaelumEquipmentItem armor = FindNativeEquipmentItem(
                    CaelumConstants.EQUIPMENT_KIND_ARMOR,
                    ArmorModel.ArmorType[slot], slot,
                    ArmorModel.Tier[slot], ArmorModel.Size[slot]
                );
                if (armor != null && armor.Equipped)
                {
                    armor.Durability = ArmorModel.Durability[slot];
                }
            }
        }
        if (ShieldModel != null && ShieldModel.Equipped)
        {
            CaelumEquipmentItem shield = FindNativeEquipmentItem(
                CaelumConstants.EQUIPMENT_KIND_SHIELD,
                ShieldModel.ShieldType, -1,
                ShieldModel.Tier, ShieldModel.Size
            );
            if (shield != null && shield.Equipped)
            {
                shield.Durability = ShieldModel.Durability;
            }
        }
        if (WeaponModel != null && WeaponModel.Equipped)
        {
            CaelumEquipmentItem weapon;
            if (WeaponModel.IsMagicalType(WeaponModel.WeaponType))
            {
                weapon = FindNativeMagicWeaponItem(
                    WeaponModel.WeaponType,
                    WeaponModel.EssenceType,
                    WeaponModel.Tier,
                    WeaponModel.Size
                );
            }
            else
            {
                weapon = FindNativeEquipmentItem(
                    CaelumConstants.EQUIPMENT_KIND_WEAPON,
                    WeaponModel.WeaponType, -1,
                    WeaponModel.Tier, WeaponModel.Size
                );
            }
            if (weapon != null && weapon.Equipped)
            {
                weapon.Durability = WeaponModel.Durability;

            }
        }
    }

    CaelumEquipmentItem GetSelectedNativeEquipmentItem()
    {
        if (EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_WEAPON)
        {
            if (WeaponModel != null
                && WeaponModel.IsMagicalType(EquipmentSelectionWeaponType))
            {
                return FindNativeMagicWeaponItem(
                    EquipmentSelectionWeaponType,
                    EquipmentSelectionWeaponEssenceType,
                    EquipmentSelectionTier,
                    EquipmentSelectionSize
                );
            }
            return FindNativeEquipmentItem(
                CaelumConstants.EQUIPMENT_KIND_WEAPON,
                EquipmentSelectionWeaponType, -1,
                EquipmentSelectionTier, EquipmentSelectionSize
            );
        }
        if (EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_SHIELD)
        {
            return FindNativeEquipmentItem(
                CaelumConstants.EQUIPMENT_KIND_SHIELD,
                EquipmentSelectionShieldType, -1,
                EquipmentSelectionTier, EquipmentSelectionSize
            );
        }
        if (EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_ARMOR)
        {
            return FindNativeEquipmentItem(
                CaelumConstants.EQUIPMENT_KIND_ARMOR,
                EquipmentSelectionArmorType, EquipmentSelectionSlot,
                EquipmentSelectionTier, EquipmentSelectionSize
            );
        }
        if (EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_AMULET)
            return FindNativeEquipmentItem(EquipmentSelectionKind,EquipmentSelectionAmuletType,-1,EquipmentSelectionTier,CaelumConstants.EQUIPMENT_SIZE_M);
        if (EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_SEAL)
            return FindNativeEquipmentItem(EquipmentSelectionKind,EquipmentSelectionSealType,-1,EquipmentSelectionTier,CaelumConstants.EQUIPMENT_SIZE_M);
        return null;
    }

    void EquipSelectedNativeEquipment()
    {
        LastEquipmentAction = CaelumConstants.EQUIPMENT_ACTION_FAILED_NOT_OWNED;
        if (EquipmentSelectionKind
            == CaelumConstants.EQUIPMENT_KIND_CONSUMABLE)
        {
            UseSelectedConsumable();
            return;
        }
        if (EquipmentSelectionKind
            == CaelumConstants.EQUIPMENT_KIND_AMMUNITION)
        {
            return;
        }
        if (IsSpecialInventoryKind(EquipmentSelectionKind))
        {
            return;
        }
        if (!EquipmentSelectionSizeCompatible)
        {
            LastEquipmentAction = CaelumConstants.EQUIPMENT_ACTION_FAILED_SIZE;
            return;
        }
        SyncActiveModelsToNativeInventory();
        CaelumEquipmentItem item = GetSelectedNativeEquipmentItem();
        if (item == null) { return; }
        if (item.InMagicBox
            && !CanAddWeightToPersonalInventory(item.UnitWeight))
        {
            LastEquipmentAction =
                CaelumConstants.EQUIPMENT_ACTION_FAILED_CARRY_CAPACITY;
            return;
        }
        item.InMagicBox = false;

        if (item.EquipmentKind == CaelumConstants.EQUIPMENT_KIND_ARMOR)
        {
            for (Inventory cursor = Inv; cursor != null; cursor = cursor.Inv)
            {
                CaelumEquipmentItem other = CaelumEquipmentItem(cursor);
                if (other != null
                    && other.EquipmentKind == CaelumConstants.EQUIPMENT_KIND_ARMOR
                    && other.ArmorSlot == item.ArmorSlot)
                {
                    other.Equipped = false;
                }
            }
            item.Equipped = true;
            ArmorModel.ArmorType[item.ArmorSlot] = item.ItemType;
            ArmorModel.Tier[item.ArmorSlot] = item.Tier;
            ArmorModel.Size[item.ArmorSlot] = item.EquipmentSize;
            ArmorModel.Durability[item.ArmorSlot] = item.Durability;
            ArmorModel.SelectedSlot = item.ArmorSlot;
        }
        else if (item.EquipmentKind == CaelumConstants.EQUIPMENT_KIND_SHIELD)
        {
            for (Inventory cursor = Inv; cursor != null; cursor = cursor.Inv)
            {
                CaelumEquipmentItem other = CaelumEquipmentItem(cursor);
                if (other != null
                    && other.EquipmentKind == CaelumConstants.EQUIPMENT_KIND_SHIELD)
                {
                    other.Equipped = false;
                }
            }
            item.Equipped = true;
            ShieldModel.ShieldType = item.ItemType;
            ShieldModel.Tier = item.Tier;
            ShieldModel.Size = item.EquipmentSize;
            ShieldModel.Durability = item.Durability;
            ShieldModel.Equipped = true;
            DebugShieldBlocking = false;
        }
        else if (IsUniversalJewelryKind(item.EquipmentKind))
        {
            for (Inventory c=Inv;c!=null;c=c.Inv)
            {
                CaelumEquipmentItem other=CaelumEquipmentItem(c);
                if (other!=null && other.EquipmentKind==item.EquipmentKind) other.Equipped=false;
            }
            item.Equipped=true;
        }
        else
        {
            // Cada arma física o mágica es una instancia independiente.
            // Equipar Bastón/Fuego no cambia ningún otro Bastón.
            item.Equipped = true;
            WeaponModel.WeaponType = item.ItemType;
            WeaponModel.Tier = item.Tier;
            WeaponModel.Size = item.EquipmentSize;
            WeaponModel.Durability = item.Durability;
            WeaponModel.EssenceType = Clamp(
                item.EssenceType,
                0,
                CaelumConstants.ESSENCE_TYPE_COUNT - 1
            );
            SelectedEssenceType = WeaponModel.EssenceType;
            EquipmentSelectionWeaponEssenceType = WeaponModel.EssenceType;
            WeaponModel.Equipped = true;
            EnsureWeaponFamilySelectors();
            EquippedWeaponCooldownRemaining = 0.0;
        }
        ApplyCharacterProfile();
        PersistCharacterState();
        RefreshEquipmentSelectionPreview();
        LastEquipmentAction = CaelumConstants.EQUIPMENT_ACTION_EQUIPPED;
    }

    void UnequipSelectedNativeEquipment()
    {
        LastEquipmentAction = CaelumConstants.EQUIPMENT_ACTION_FAILED_NOT_OWNED;
        SyncActiveModelsToNativeInventory();
        CaelumEquipmentItem item = GetSelectedNativeEquipmentItem();
        if (item == null || !item.Equipped) { return; }
        item.Equipped = false;
        if (item.EquipmentKind == CaelumConstants.EQUIPMENT_KIND_ARMOR)
        {
            ArmorModel.ArmorType[item.ArmorSlot] =
                CaelumConstants.ARMOR_TYPE_BASE_CLOTHING;
            ArmorModel.Tier[item.ArmorSlot] = 1;
            ArmorModel.Size[item.ArmorSlot] = CaelumConstants.EQUIPMENT_SIZE_M;
            ArmorModel.Durability[item.ArmorSlot] = 0;
        }
        else if (item.EquipmentKind == CaelumConstants.EQUIPMENT_KIND_SHIELD)
        {
            ShieldModel.Equipped = false;
            CancelCombatBlockMode();
        }
        else if (IsUniversalJewelryKind(item.EquipmentKind))
        {
            // Los bonos se recalculan desde el inventario.
        }
        else
        {
            bool wasActive = WeaponModel.Equipped
                && WeaponModel.WeaponType == item.ItemType
                && WeaponModel.Tier == item.Tier
                && WeaponModel.Size == item.EquipmentSize
                && (!WeaponModel.IsMagicalType(item.ItemType)
                    || WeaponModel.EssenceType == item.EssenceType);
            if (wasActive)
            {
                CancelPendingStaffCast(false);
                WeaponModel.Equipped = false;
            }
            EnsureWeaponFamilySelectors();
            if (wasActive) { ActivateFirstEquippedWeapon(); }
        }
        ApplyCharacterProfile();
        PersistCharacterState();
        RefreshEquipmentSelectionPreview();
        LastEquipmentAction = CaelumConstants.EQUIPMENT_ACTION_UNEQUIPPED;
    }

    void ToggleSelectedMagicBox()
    {
        LastEquipmentAction = CaelumConstants.EQUIPMENT_ACTION_FAILED_NOT_OWNED;
        RefreshCarriedInventorySummary();
        if (EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_KEY)
        {
            LastEquipmentAction =
                CaelumConstants.EQUIPMENT_ACTION_FAILED_KEY_STORAGE;
            return;
        }
        if (EquipmentSelectionKind
                == CaelumConstants.EQUIPMENT_KIND_MATERIAL
            || EquipmentSelectionKind
                == CaelumConstants.EQUIPMENT_KIND_KEY_ITEM)
        {
            CaelumSpecialInventoryItem specialItem = FindNativeSpecialItem(
                EquipmentSelectionKind, EquipmentSelectionSpecialType,
                EquipmentSelectionTier
            );
            if (specialItem == null || specialItem.Amount <= 0) { return; }
            double stackWeight = specialItem.Amount
                * specialItem.GetUnitWeight();
            if (specialItem.InMagicBox)
            {
                if (!CanAddWeightToPersonalInventory(stackWeight))
                {
                    LastEquipmentAction =
                        CaelumConstants.EQUIPMENT_ACTION_FAILED_CARRY_CAPACITY;
                    return;
                }
                specialItem.InMagicBox = false;
                LastEquipmentAction =
                    CaelumConstants.EQUIPMENT_ACTION_RETRIEVED_FROM_MAGIC_BOX;
            }
            else
            {
                if (MagicBoxUsedSlots >= MagicBoxMaximumSlots)
                {
                    LastEquipmentAction =
                        CaelumConstants.EQUIPMENT_ACTION_FAILED_BOX_FULL;
                    return;
                }
                specialItem.InMagicBox = true;
                LastEquipmentAction =
                    CaelumConstants.EQUIPMENT_ACTION_STORED_IN_MAGIC_BOX;
            }
            ApplyCharacterProfile();
            PersistCharacterState();
            RefreshEquipmentSelectionPreview();
            return;
        }
        if (EquipmentSelectionKind
            == CaelumConstants.EQUIPMENT_KIND_CONSUMABLE)
        {
            CaelumConsumableItem consumable = FindNativeConsumableItem(
                EquipmentSelectionConsumableType
            );
            if (consumable == null || consumable.Amount <= 0) { return; }
            double stackWeight = consumable.Amount
                * consumable.GetUnitWeight();
            if (consumable.InMagicBox)
            {
                if (!CanAddWeightToPersonalInventory(stackWeight))
                {
                    LastEquipmentAction =
                        CaelumConstants.EQUIPMENT_ACTION_FAILED_CARRY_CAPACITY;
                    return;
                }
                consumable.InMagicBox = false;
                LastEquipmentAction =
                    CaelumConstants.EQUIPMENT_ACTION_RETRIEVED_FROM_MAGIC_BOX;
            }
            else
            {
                if (MagicBoxUsedSlots >= MagicBoxMaximumSlots)
                {
                    LastEquipmentAction =
                        CaelumConstants.EQUIPMENT_ACTION_FAILED_BOX_FULL;
                    return;
                }
                consumable.InMagicBox = true;
                LastEquipmentAction =
                    CaelumConstants.EQUIPMENT_ACTION_STORED_IN_MAGIC_BOX;
            }
            ApplyCharacterProfile();
            PersistCharacterState();
            RefreshEquipmentSelectionPreview();
            return;
        }
        if (EquipmentSelectionKind
            == CaelumConstants.EQUIPMENT_KIND_AMMUNITION)
        {
            Inventory ammunition = FindNativeAmmunition(
                EquipmentSelectionAmmunitionType
            );
            if (ammunition == null || ammunition.Amount <= 0) { return; }

            // Flechas y virotes son Ammo nativa independiente. De momento
            // permanecen en inventario personal; la Caja Mágica especial sólo
            // se aplica a la pila personalizada de carabina.
            CaelumCarbineAmmo carbineStack = CaelumCarbineAmmo(ammunition);
            if (carbineStack == null)
            {
                LastEquipmentAction =
                    CaelumConstants.EQUIPMENT_ACTION_FAILED_STORAGE;
                return;
            }

            double stackWeight = carbineStack.GetCarriedWeight();
            if (carbineStack.InMagicBox)
            {
                if (!CanAddWeightToPersonalInventory(stackWeight))
                {
                    LastEquipmentAction =
                        CaelumConstants.EQUIPMENT_ACTION_FAILED_CARRY_CAPACITY;
                    return;
                }
                carbineStack.InMagicBox = false;
                LastEquipmentAction =
                    CaelumConstants.EQUIPMENT_ACTION_RETRIEVED_FROM_MAGIC_BOX;
            }
            else
            {
                if (MagicBoxUsedSlots >= MagicBoxMaximumSlots)
                {
                    LastEquipmentAction =
                        CaelumConstants.EQUIPMENT_ACTION_FAILED_BOX_FULL;
                    return;
                }
                carbineStack.InMagicBox = true;
                LastEquipmentAction =
                    CaelumConstants.EQUIPMENT_ACTION_STORED_IN_MAGIC_BOX;
            }
            ApplyCharacterProfile();
            PersistCharacterState();
            RefreshEquipmentSelectionPreview();
            return;
        }

        CaelumEquipmentItem item = GetSelectedNativeEquipmentItem();
        if (item == null) { return; }
        if (item.InMagicBox)
        {
            if (!CanAddWeightToPersonalInventory(item.UnitWeight))
            {
                LastEquipmentAction =
                    CaelumConstants.EQUIPMENT_ACTION_FAILED_CARRY_CAPACITY;
                return;
            }
            item.InMagicBox = false;
            LastEquipmentAction =
                CaelumConstants.EQUIPMENT_ACTION_RETRIEVED_FROM_MAGIC_BOX;
        }
        else
        {
            if (MagicBoxUsedSlots >= MagicBoxMaximumSlots)
            {
                LastEquipmentAction =
                    CaelumConstants.EQUIPMENT_ACTION_FAILED_BOX_FULL;
                return;
            }
            if (item.Equipped)
            {
                UnequipSelectedNativeEquipment();
                item = GetSelectedNativeEquipmentItem();
                if (item == null) { return; }
            }
            item.InMagicBox = true;
            LastEquipmentAction =
                CaelumConstants.EQUIPMENT_ACTION_STORED_IN_MAGIC_BOX;
        }
        ApplyCharacterProfile();
        PersistCharacterState();
        RefreshEquipmentSelectionPreview();
    }

    void EquipSelectedEquipment()
    {
        EquipSelectedNativeEquipment();
        return;
        LastEquipmentAction = CaelumConstants.EQUIPMENT_ACTION_FAILED_NOT_OWNED;
        CaelumPersistentCharacterState persistentState =
            GetPersistentCharacterState(false);
        if (persistentState == null) { return; }
        persistentState.EnsureEquipmentSizeInitialized();
        if (!EquipmentSelectionSizeCompatible)
        {
            LastEquipmentAction = CaelumConstants.EQUIPMENT_ACTION_FAILED_SIZE;
            return;
        }
        ApplyCharacterProfile();
        if (EquipmentSelectionInMagicBox
            && !CanAddWeightToPersonalInventory(EquipmentSelectionWeight))
        {
            LastEquipmentAction =
                CaelumConstants.EQUIPMENT_ACTION_FAILED_CARRY_CAPACITY;
            return;
        }

        if (EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_WEAPON)
        {
            if (WeaponModel == null || !persistentState.OwnsWeapon(
                EquipmentSelectionWeaponType,
                EquipmentSelectionTier,
                EquipmentSelectionSize
            ))
            {
                return;
            }
            persistentState.SetWeaponEquipped(
                EquipmentSelectionWeaponType,
                EquipmentSelectionTier,
                EquipmentSelectionSize,
                true
            );
            persistentState.SetWeaponInMagicBox(
                EquipmentSelectionWeaponType,
                EquipmentSelectionTier,
                EquipmentSelectionSize,
                false
            );
            // Equipar prepara el arma sin sustituir la activa. Solo se activa
            // inmediatamente cuando el personaje no tenía ninguna en uso.
            if (!WeaponModel.Equipped)
            {
                ActivateEquippedWeaponType(EquipmentSelectionWeaponType);
            }
            EnsureWeaponFamilySelectors();
            EquippedWeaponCooldownRemaining = 0.0;
        }
        else if (EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_SHIELD)
        {
            if (ShieldModel == null || !persistentState.OwnsShield(
                EquipmentSelectionShieldType,
                EquipmentSelectionTier,
                EquipmentSelectionSize
            ))
            {
                return;
            }
            if (ShieldModel.Equipped)
            {
                persistentState.RegisterOwnedShield(
                    ShieldModel.ShieldType,
                    ShieldModel.Tier,
                    ShieldModel.Size,
                    ShieldModel.Durability
                );
                persistentState.StoreOwnedShieldDurability(
                    ShieldModel.ShieldType,
                    ShieldModel.Tier,
                    ShieldModel.Size,
                    ShieldModel.Durability
                );
                persistentState.SetShieldInMagicBox(
                    ShieldModel.ShieldType,
                    ShieldModel.Tier,
                    ShieldModel.Size,
                    false
                );
            }
            ShieldModel.ShieldType = EquipmentSelectionShieldType;
            ShieldModel.Tier = EquipmentSelectionTier;
            ShieldModel.Size = EquipmentSelectionSize;
            ShieldModel.Durability = persistentState.GetOwnedShieldDurability(
                EquipmentSelectionShieldType,
                EquipmentSelectionTier,
                EquipmentSelectionSize
            );
            ShieldModel.Equipped = true;
            persistentState.SetShieldInMagicBox(
                EquipmentSelectionShieldType,
                EquipmentSelectionTier,
                EquipmentSelectionSize,
                false
            );
            DebugShieldBlocking = false;
        }
        else
        {
            if (ArmorModel == null || !persistentState.OwnsArmor(
                EquipmentSelectionSlot,
                EquipmentSelectionArmorType,
                EquipmentSelectionTier,
                EquipmentSelectionSize
            ))
            {
                return;
            }
            if (ArmorModel.ArmorType[EquipmentSelectionSlot]
                != CaelumConstants.ARMOR_TYPE_BASE_CLOTHING)
            {
                persistentState.RegisterOwnedArmor(
                    EquipmentSelectionSlot,
                    ArmorModel.ArmorType[EquipmentSelectionSlot],
                    ArmorModel.Tier[EquipmentSelectionSlot],
                    ArmorModel.Size[EquipmentSelectionSlot],
                    ArmorModel.Durability[EquipmentSelectionSlot]
                );
                persistentState.StoreOwnedArmorDurability(
                    EquipmentSelectionSlot,
                    ArmorModel.ArmorType[EquipmentSelectionSlot],
                    ArmorModel.Tier[EquipmentSelectionSlot],
                    ArmorModel.Size[EquipmentSelectionSlot],
                    ArmorModel.Durability[EquipmentSelectionSlot]
                );
                persistentState.SetArmorInMagicBox(
                    EquipmentSelectionSlot,
                    ArmorModel.ArmorType[EquipmentSelectionSlot],
                    ArmorModel.Tier[EquipmentSelectionSlot],
                    ArmorModel.Size[EquipmentSelectionSlot],
                    false
                );
            }
            ArmorModel.ArmorType[EquipmentSelectionSlot] =
                EquipmentSelectionArmorType;
            ArmorModel.Tier[EquipmentSelectionSlot] = EquipmentSelectionTier;
            ArmorModel.Size[EquipmentSelectionSlot] = EquipmentSelectionSize;
            ArmorModel.Durability[EquipmentSelectionSlot] =
                persistentState.GetOwnedArmorDurability(
                    EquipmentSelectionSlot,
                    EquipmentSelectionArmorType,
                    EquipmentSelectionTier,
                    EquipmentSelectionSize
                );
            ArmorModel.SelectedSlot = EquipmentSelectionSlot;
            persistentState.SetArmorInMagicBox(
                EquipmentSelectionSlot,
                EquipmentSelectionArmorType,
                EquipmentSelectionTier,
                EquipmentSelectionSize,
                false
            );
        }

        ApplyCharacterProfile();
        PersistCharacterState();
        RefreshEquipmentSelectionPreview();
        LastEquipmentAction = CaelumConstants.EQUIPMENT_ACTION_EQUIPPED;
    }

    void UnequipSelectedEquipment()
    {
        UnequipSelectedNativeEquipment();
        return;
        LastEquipmentAction = CaelumConstants.EQUIPMENT_ACTION_FAILED_NOT_OWNED;
        CaelumPersistentCharacterState persistentState =
            GetPersistentCharacterState(true);
        if (persistentState == null) { return; }
        persistentState.EnsureEquipmentSizeInitialized();

        if (EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_WEAPON)
        {
            if (WeaponModel == null || !persistentState.IsWeaponEquipped(
                EquipmentSelectionWeaponType,
                EquipmentSelectionTier,
                EquipmentSelectionSize
            )) { return; }
            bool removingActiveWeapon = WeaponModel.Equipped
                && WeaponModel.WeaponType == EquipmentSelectionWeaponType
                && WeaponModel.Tier == EquipmentSelectionTier
                && WeaponModel.Size == EquipmentSelectionSize;
            if (removingActiveWeapon)
            {
                persistentState.StoreOwnedWeaponDurability(
                    WeaponModel.WeaponType,
                    WeaponModel.Tier,
                    WeaponModel.Size,
                    WeaponModel.Durability
                );
            }
            persistentState.SetWeaponEquipped(
                EquipmentSelectionWeaponType,
                EquipmentSelectionTier,
                EquipmentSelectionSize,
                false
            );
            persistentState.SetWeaponInMagicBox(
                EquipmentSelectionWeaponType,
                EquipmentSelectionTier,
                EquipmentSelectionSize,
                false
            );
            if (removingActiveWeapon) { ActivateFirstEquippedWeapon(); }
            EnsureWeaponFamilySelectors();
            EquippedWeaponCooldownRemaining = 0.0;
        }
        else if (EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_SHIELD)
        {
            if (ShieldModel == null || !ShieldModel.Equipped) { return; }
            persistentState.RegisterOwnedShield(
                ShieldModel.ShieldType,
                ShieldModel.Tier,
                ShieldModel.Size,
                ShieldModel.Durability
            );
            persistentState.StoreOwnedShieldDurability(
                ShieldModel.ShieldType,
                ShieldModel.Tier,
                ShieldModel.Size,
                ShieldModel.Durability
            );
            persistentState.SetShieldInMagicBox(
                ShieldModel.ShieldType,
                ShieldModel.Tier,
                ShieldModel.Size,
                false
            );
            ShieldModel.Equipped = false;
            DebugShieldBlocking = false;
        }
        else
        {
            if (ArmorModel == null) { return; }
            int slot = EquipmentSelectionSlot;
            if (ArmorModel.ArmorType[slot]
                == CaelumConstants.ARMOR_TYPE_BASE_CLOTHING)
            {
                return;
            }
            persistentState.RegisterOwnedArmor(
                slot,
                ArmorModel.ArmorType[slot],
                ArmorModel.Tier[slot],
                ArmorModel.Size[slot],
                ArmorModel.Durability[slot]
            );
            persistentState.StoreOwnedArmorDurability(
                slot,
                ArmorModel.ArmorType[slot],
                ArmorModel.Tier[slot],
                ArmorModel.Size[slot],
                ArmorModel.Durability[slot]
            );
            persistentState.SetArmorInMagicBox(
                slot,
                ArmorModel.ArmorType[slot],
                ArmorModel.Tier[slot],
                ArmorModel.Size[slot],
                false
            );
            ArmorModel.ArmorType[slot] = CaelumConstants.ARMOR_TYPE_BASE_CLOTHING;
            ArmorModel.Tier[slot] = 1;
            ArmorModel.Size[slot] = CaelumConstants.EQUIPMENT_SIZE_M;
            ArmorModel.Durability[slot] = 0;
            ArmorModel.SelectedSlot = slot;
        }

        ApplyCharacterProfile();
        PersistCharacterState();
        RefreshEquipmentSelectionPreview();
        LastEquipmentAction = CaelumConstants.EQUIPMENT_ACTION_UNEQUIPPED;
    }

    void SpawnSelectedNativePickupOnFloor()
    {
        if (player == null || player.playerstate != PST_LIVE) { return; }
        Vector3 spawnPos = Pos + (
            Cos(Angle) * 56.0,
            Sin(Angle) * 56.0,
            8.0
        );
        Actor pickup;
        if (IsSpecialInventoryKind(EquipmentSelectionKind))
        {
            Name specialClass = GetSpecialItemClassName(
                EquipmentSelectionKind, EquipmentSelectionSpecialType
            );
            pickup = Spawn(specialClass, spawnPos, NO_REPLACE);
            if (pickup != null
                && EquipmentSelectionKind
                    == CaelumConstants.EQUIPMENT_KIND_MATERIAL)
            {
                pickup.args[0] = EquipmentSelectionSpecialType;
                pickup.args[1] = EquipmentSelectionTier;
                Inventory(pickup).Amount = 10;
            }
        }
        else if (EquipmentSelectionKind
            == CaelumConstants.EQUIPMENT_KIND_CONSUMABLE)
        {
            Name consumableClass = GetConsumableClassName(
                EquipmentSelectionConsumableType
            );
            pickup = Spawn(consumableClass, spawnPos, NO_REPLACE);
            if (pickup != null) { Inventory(pickup).Amount = 5; }
        }
        else if (EquipmentSelectionKind
            == CaelumConstants.EQUIPMENT_KIND_AMMUNITION)
        {
            pickup = Spawn(
                GetAmmunitionClassName(EquipmentSelectionAmmunitionType),
                spawnPos,
                NO_REPLACE
            );
            if (pickup != null)
            {
                bool isJavelin = EquipmentSelectionAmmunitionType
                    >= CaelumConstants.AMMUNITION_JAVELIN_TIER_ONE;
                Inventory(pickup).Amount = isJavelin ? 5 : 100;
            }
        }
        else if (EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_WEAPON)
        {
            pickup = Spawn("CaelumWeaponPickup", spawnPos, NO_REPLACE);
            if (pickup != null)
            {
                pickup.args[0] = EquipmentSelectionWeaponType;
                pickup.args[1] = EquipmentSelectionTier;
                pickup.args[2] = EquipmentSelectionSize + 1;
                pickup.args[4] = SelectedEssenceType + 1;
            }
        }
        else if (EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_SHIELD)
        {
            pickup = Spawn("CaelumShieldPickup", spawnPos, NO_REPLACE);
            if (pickup != null)
            {
                pickup.args[0] = EquipmentSelectionShieldType;
                pickup.args[1] = EquipmentSelectionTier;
                pickup.args[2] = EquipmentSelectionSize + 1;
            }
        }
        else if (EquipmentSelectionKind
            == CaelumConstants.EQUIPMENT_KIND_AMULET)
        {
            pickup = Spawn("CaelumAmuletPickup", spawnPos, NO_REPLACE);
            if (pickup != null)
            {
                pickup.args[0] = EquipmentSelectionAmuletType;
                pickup.args[1] = EquipmentSelectionTier;
            }
        }
        else if (EquipmentSelectionKind
            == CaelumConstants.EQUIPMENT_KIND_SEAL)
        {
            pickup = Spawn("CaelumSealPickup", spawnPos, NO_REPLACE);
            if (pickup != null)
            {
                pickup.args[0] = EquipmentSelectionSealType;
                pickup.args[1] = EquipmentSelectionTier;
            }
        }
        else
        {
            // Sólo ARMOR llega a este fallback. Antes Amulet y Seal también
            // caían aquí y la herramienta de desarrollo creaba un casco.
            pickup = Spawn("CaelumArmorPickup", spawnPos, NO_REPLACE);
            if (pickup != null)
            {
                pickup.args[0] = EquipmentSelectionSlot;
                pickup.args[1] = EquipmentSelectionArmorType;
                pickup.args[2] = EquipmentSelectionTier;
                pickup.args[3] = EquipmentSelectionSize + 1;
            }
        }
        LastEquipmentAction = pickup != null
            ? CaelumConstants.EQUIPMENT_ACTION_SPAWNED_ON_FLOOR
            : CaelumConstants.EQUIPMENT_ACTION_FAILED_NOT_OWNED;
        RefreshEquipmentSelectionPreview();
    }

    void BreakSelectedNativeEquipment()
    {
        LastEquipmentAction = CaelumConstants.EQUIPMENT_ACTION_FAILED_NOT_OWNED;
        if (EquipmentSelectionKind
                == CaelumConstants.EQUIPMENT_KIND_CONSUMABLE
            || EquipmentSelectionKind
                == CaelumConstants.EQUIPMENT_KIND_AMMUNITION
            || EquipmentSelectionKind
                >= CaelumConstants.EQUIPMENT_KIND_MATERIAL) { return; }
        CaelumEquipmentItem item = GetSelectedNativeEquipmentItem();
        if (item == null) { return; }
        if (item.EquipmentKind == CaelumConstants.EQUIPMENT_KIND_WEAPON)
        {
            DismantleSelectedNativeWeapon();
            return;
        }
        item.Durability = 0;
        if (item.Equipped)
        {
            if (item.EquipmentKind == CaelumConstants.EQUIPMENT_KIND_ARMOR)
            {
                ArmorModel.Durability[item.ArmorSlot] = 0;
            }
            else if (item.EquipmentKind == CaelumConstants.EQUIPMENT_KIND_SHIELD)
            {
                ShieldModel.Durability = 0;
                DebugShieldBlocking = false;
            }
            else if (WeaponModel.Equipped
                && WeaponModel.WeaponType == item.ItemType
                && WeaponModel.Tier == item.Tier
                && WeaponModel.Size == item.EquipmentSize)
            {
                WeaponModel.Durability = 0;
                EquippedWeaponCooldownRemaining = 0.0;
            }
        }
        ApplyCharacterProfile();
        PersistCharacterState();
        RefreshEquipmentSelectionPreview();
        LastEquipmentAction = CaelumConstants.EQUIPMENT_ACTION_BROKEN;
    }

    CaelumMaterialPickup CreateDetachedMaterialStack(
        int materialType, int materialTier, int materialAmount
    )
    {
        CaelumMaterialPickup material = CaelumMaterialPickup(
            Spawn("CaelumMaterialPickup", Pos, NO_REPLACE)
        );
        if (material == null) { return null; }
        material.args[0] = materialType;
        material.args[1] = materialTier;
        material.Amount = Max(1, materialAmount);
        material.InMagicBox = false;
        return material;
    }

    void AddRecoveredMaterial(
        CaelumSpecialInventoryItem existing,
        CaelumMaterialPickup detached,
        int recoveredAmount,
        bool sendToMagicBox
    )
    {
        if (existing != null)
        {
            existing.Amount += recoveredAmount;
            if (sendToMagicBox) { existing.InMagicBox = true; }
            if (detached != null) { detached.Destroy(); }
            return;
        }
        if (detached == null) { return; }
        detached.InMagicBox = sendToMagicBox;
        detached.AttachToOwner(self);
    }

    void DismantleSelectedNativeWeapon()
    {
        LastEquipmentAction = CaelumConstants.EQUIPMENT_ACTION_FAILED_NOT_OWNED;
        LastDismantledBasicUnits = 0;
        LastDismantledTierUnits = 0;
        CaelumEquipmentItem weapon = GetSelectedNativeEquipmentItem();
        if (weapon == null
            || weapon.EquipmentKind != CaelumConstants.EQUIPMENT_KIND_WEAPON)
        {
            return;
        }
        if (weapon.Equipped)
        {
            LastEquipmentAction =
                CaelumConstants.EQUIPMENT_ACTION_FAILED_EQUIPPED;
            return;
        }

        int catalogueWeapon =
            CaelumCraftingRules.GetCatalogueWeaponForPlayableType(
                weapon.ItemType
            );
        if (catalogueWeapon < 0)
        {
            LastEquipmentAction =
                CaelumConstants.EQUIPMENT_ACTION_FAILED_DISMANTLE_UNSUPPORTED;
            return;
        }
        double finalWeight = WeaponModel.GetWeightFor(
            weapon.ItemType, weapon.Tier, weapon.EquipmentSize
        );
        int basicType = CaelumCraftingRules.GetBasicMaterial(catalogueWeapon);
        int tierType = CaelumCraftingRules.GetTierMaterial(catalogueWeapon);
        int basicTier = CaelumMaterialRules.ResolveTier(basicType, 1);
        int tierTier = CaelumMaterialRules.ResolveTier(tierType, weapon.Tier);
        int basicAmount = CaelumCraftingRules.GetRecoveredMaterialUnits(
            CaelumCraftingRules.GetRequiredBasicMaterialUnits(
                catalogueWeapon, finalWeight
            )
        );
        int tierAmount = CaelumCraftingRules.GetRecoveredMaterialUnits(
            CaelumCraftingRules.GetRequiredTierMaterialUnits(
                catalogueWeapon, finalWeight
            )
        );
        CaelumSpecialInventoryItem existingBasic = FindNativeSpecialItem(
            CaelumConstants.EQUIPMENT_KIND_MATERIAL,
            basicType,
            basicTier
        );
        CaelumSpecialInventoryItem existingTier = FindNativeSpecialItem(
            CaelumConstants.EQUIPMENT_KIND_MATERIAL,
            tierType,
            tierTier
        );

        RefreshCarriedInventorySummary();
        double personalWeightAfterRemoval = Max(
            0.0,
            HUDCarriedWeight - weapon.GetCarriedWeight()
        );
        double recoveredPersonalWeight = 0.0;
        if (existingBasic == null || !existingBasic.InMagicBox)
        {
            recoveredPersonalWeight += basicAmount
                * CaelumConstants.MATERIAL_UNIT_WEIGHT;
        }
        if (existingTier == null || !existingTier.InMagicBox)
        {
            recoveredPersonalWeight += tierAmount
                * CaelumConstants.MATERIAL_UNIT_WEIGHT;
        }
        bool sendToMagicBox = personalWeightAfterRemoval
                + recoveredPersonalWeight
            > HUDCarryCapacity + 0.0005;

        int requiredBoxSlots = 0;
        if (sendToMagicBox)
        {
            if (existingBasic == null || !existingBasic.InMagicBox)
            {
                requiredBoxSlots++;
            }
            if (existingTier == null || !existingTier.InMagicBox)
            {
                requiredBoxSlots++;
            }
        }
        int freedBoxSlots = weapon.InMagicBox ? 1 : 0;
        if (MagicBoxUsedSlots - freedBoxSlots + requiredBoxSlots
            > MagicBoxMaximumSlots)
        {
            LastEquipmentAction =
                CaelumConstants.EQUIPMENT_ACTION_FAILED_STORAGE;
            return;
        }

        CaelumMaterialPickup detachedBasic;
        CaelumMaterialPickup detachedTier;
        if (existingBasic == null)
        {
            detachedBasic = CreateDetachedMaterialStack(
                basicType, basicTier, basicAmount
            );
            if (detachedBasic == null)
            {
                LastEquipmentAction =
                    CaelumConstants.EQUIPMENT_ACTION_FAILED_STORAGE;
                return;
            }
        }
        if (existingTier == null)
        {
            detachedTier = CreateDetachedMaterialStack(
                tierType, tierTier, tierAmount
            );
            if (detachedTier == null)
            {
                if (detachedBasic != null) { detachedBasic.Destroy(); }
                LastEquipmentAction =
                    CaelumConstants.EQUIPMENT_ACTION_FAILED_STORAGE;
                return;
            }
        }

        CaelumPersistentCharacterState persistentState =
            GetPersistentCharacterState(false);
        if (persistentState != null)
        {
            persistentState.RemoveOwnedWeapon(
                weapon.ItemType, weapon.Tier, weapon.EquipmentSize
            );
        }
        weapon.Destroy();
        AddRecoveredMaterial(
            existingBasic, detachedBasic, basicAmount, sendToMagicBox
        );
        AddRecoveredMaterial(
            existingTier, detachedTier, tierAmount, sendToMagicBox
        );

        LastDismantledBasicMaterialType = basicType;
        LastDismantledBasicUnits = basicAmount;
        LastDismantledTierMaterialType = tierType;
        LastDismantledTierUnits = tierAmount;
        LastEquipmentAction = CaelumConstants.EQUIPMENT_ACTION_DISMANTLED;
        ApplyCharacterProfile();
        PersistCharacterState();
        RefreshEquipmentSelectionPreview();
    }

    void DropSelectedNativeInventoryItem()
    {
        LastEquipmentAction = CaelumConstants.EQUIPMENT_ACTION_FAILED_NOT_OWNED;
        Inventory selected;
        if (EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_KEY)
        {
            CaelumWeightedKey keyItem = FindNativeKey(
                EquipmentSelectionSpecialType
            );
            if (keyItem == null || keyItem.Amount <= 0) { return; }
            selected = keyItem.CreateTossable(1);
        }
        else if (EquipmentSelectionKind
                == CaelumConstants.EQUIPMENT_KIND_MATERIAL
            || EquipmentSelectionKind
                == CaelumConstants.EQUIPMENT_KIND_KEY_ITEM)
        {
            CaelumSpecialInventoryItem specialItem = FindNativeSpecialItem(
                EquipmentSelectionKind, EquipmentSelectionSpecialType,
                EquipmentSelectionTier
            );
            if (specialItem == null || specialItem.Amount <= 0) { return; }
            specialItem.InMagicBox = false;
            selected = specialItem.CreateTossable(specialItem.Amount);
        }
        else if (EquipmentSelectionKind
            == CaelumConstants.EQUIPMENT_KIND_CONSUMABLE)
        {
            CaelumConsumableItem consumable = FindNativeConsumableItem(
                EquipmentSelectionConsumableType
            );
            if (consumable == null || consumable.Amount <= 0) { return; }
            consumable.InMagicBox = false;
            selected = consumable.CreateTossable(consumable.Amount);
        }
        else if (EquipmentSelectionKind
            == CaelumConstants.EQUIPMENT_KIND_AMMUNITION)
        {
            Inventory ammunition = FindNativeAmmunition(
                EquipmentSelectionAmmunitionType
            );
            if (ammunition == null || ammunition.Amount <= 0) { return; }
            CaelumCarbineAmmo carbineStack = CaelumCarbineAmmo(ammunition);
            if (carbineStack != null) { carbineStack.InMagicBox = false; }
            selected = ammunition.CreateTossable(ammunition.Amount);
        }
        else
        {
            CaelumEquipmentItem item = GetSelectedNativeEquipmentItem();
            if (item == null) { return; }
            if (item.Equipped)
            {
                UnequipSelectedNativeEquipment();
                item = GetSelectedNativeEquipmentItem();
                if (item == null) { return; }
            }
            item.InMagicBox = false;
            selected = item.CreateTossable(1);
        }
        if (selected == null) { return; }
        Vector3 spawnPos = Pos + (
            Cos(Angle) * 48.0,
            Sin(Angle) * 48.0,
            8.0
        );
        selected.SetOrigin(spawnPos, false);
        selected.TossItem();

        // Jewelry was visibly launched upward by Inventory.TossItem().
        // Preserve the horizontal toss, but make seals/amulets begin falling
        // immediately from the small +8 MU spawn offset.
        if (EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_AMULET
            || EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_SEAL)
        {
            selected.Vel.Z = -0.25;
        }

        ApplyCharacterProfile();
        PersistCharacterState();
        RefreshEquipmentSelectionPreview();
        LastEquipmentAction = CaelumConstants.EQUIPMENT_ACTION_DROPPED;
    }

    void SpawnDebugEquipmentPickup()
    {
        SpawnSelectedNativePickupOnFloor();
        return;
        // La creacion de desarrollo recorre la misma decision que un pickup:
        // inventario si entra por peso; Caja Magica si la carga se excederia.
        if (player == null || player.playerstate != PST_LIVE) { return; }
        bool created = false;
        if (EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_WEAPON)
        {
            created = AcquireWeaponPickup(
                EquipmentSelectionWeaponType,
                EquipmentSelectionTier,
                EquipmentSelectionSize,
                0
            );
        }
        else if (EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_SHIELD)
        {
            created = AcquireShieldPickup(
                EquipmentSelectionShieldType,
                EquipmentSelectionTier,
                EquipmentSelectionSize,
                0
            );
        }
        else
        {
            created = AcquireArmorPickup(
                EquipmentSelectionSlot,
                EquipmentSelectionArmorType,
                EquipmentSelectionTier,
                EquipmentSelectionSize,
                0
            );
        }
        if (!created)
        {
            LastEquipmentAction = CaelumConstants.EQUIPMENT_ACTION_FAILED_BOX_FULL;
        }
        else if (LastEquipmentPickupWentToMagicBox)
        {
            LastEquipmentAction =
                CaelumConstants.EQUIPMENT_ACTION_CREATED_IN_MAGIC_BOX;
        }
        else
        {
            LastEquipmentAction = CaelumConstants.EQUIPMENT_ACTION_CREATED;
        }
        RefreshEquipmentSelectionPreview();
    }

    // Comprueba exactamente la cerradura declarada en LOCKDEFS sin requerir
    // una linea de mapa. El mensaje de fallo lo produce el propio motor.
    void DebugTestSilverLock()
    {
        if (CheckKeys(CaelumConstants.LOCK_CAELUM_SILVER, true, false))
        {
            Console.Printf(
                "%s", StringTable.Localize("CA_LOCK_TEST_GRANTED", false)
            );
        }
    }

    void BreakSelectedEquipment()
    {
        BreakSelectedNativeEquipment();
        return;
        LastEquipmentAction = CaelumConstants.EQUIPMENT_ACTION_FAILED_NOT_OWNED;
        CaelumPersistentCharacterState persistentState =
            GetPersistentCharacterState(false);
        if (persistentState == null || !EquipmentSelectionOwned) { return; }
        persistentState.EnsureEquipmentSizeInitialized();
        if (EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_WEAPON)
        {
            persistentState.StoreOwnedWeaponDurability(
                EquipmentSelectionWeaponType,
                EquipmentSelectionTier,
                EquipmentSelectionSize,
                0
            );
            if (EquipmentSelectionEquipped && WeaponModel != null
                && WeaponModel.Equipped
                && WeaponModel.WeaponType == EquipmentSelectionWeaponType
                && WeaponModel.Tier == EquipmentSelectionTier
                && WeaponModel.Size == EquipmentSelectionSize)
            {
                WeaponModel.Durability = 0;
                EquippedWeaponCooldownRemaining = 0.0;
            }
        }
        else if (EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_SHIELD)
        {
            persistentState.StoreOwnedShieldDurability(
                EquipmentSelectionShieldType,
                EquipmentSelectionTier,
                EquipmentSelectionSize,
                0
            );
            if (EquipmentSelectionEquipped && ShieldModel != null)
            {
                ShieldModel.Durability = 0;
                DebugShieldBlocking = false;
            }
        }
        else
        {
            persistentState.StoreOwnedArmorDurability(
                EquipmentSelectionSlot,
                EquipmentSelectionArmorType,
                EquipmentSelectionTier,
                EquipmentSelectionSize,
                0
            );
            if (EquipmentSelectionEquipped && ArmorModel != null)
            {
                ArmorModel.Durability[EquipmentSelectionSlot] = 0;
            }
        }
        ApplyCharacterProfile();
        PersistCharacterState();
        RefreshEquipmentSelectionPreview();
        LastEquipmentAction = CaelumConstants.EQUIPMENT_ACTION_BROKEN;
    }

    void DropSelectedEquipment()
    {
        DropSelectedNativeInventoryItem();
        return;
        LastEquipmentAction = CaelumConstants.EQUIPMENT_ACTION_FAILED_NOT_OWNED;
        if (!EquipmentSelectionOwned) { return; }
        CaelumPersistentCharacterState persistentState =
            GetPersistentCharacterState(false);
        if (persistentState == null) { return; }
        // Tirar un objeto equipado primero lo retira de su ranura. Esto evita
        // que el control parezca inactivo y actualiza su peso en el mismo tic.
        if (EquipmentSelectionEquipped)
        {
            UnequipSelectedEquipment();
            RefreshEquipmentSelectionPreview();
            if (EquipmentSelectionEquipped || !EquipmentSelectionOwned) { return; }
        }
        Vector3 spawnPos = Pos + (Cos(Angle) * 48.0, Sin(Angle) * 48.0, 8.0);
        Actor pickup;
        if (EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_WEAPON)
        {
            pickup = Spawn("CaelumWeaponPickup", spawnPos, NO_REPLACE);
            if (pickup == null) { return; }
            pickup.args[0] = EquipmentSelectionWeaponType;
            pickup.args[1] = EquipmentSelectionTier;
            pickup.args[2] = EquipmentSelectionSize + 1;
            pickup.args[3] = EquipmentSelectionDurability + 1;
            persistentState.RemoveOwnedWeapon(
                EquipmentSelectionWeaponType,
                EquipmentSelectionTier,
                EquipmentSelectionSize
            );
        }
        else if (EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_SHIELD)
        {
            pickup = Spawn("CaelumShieldPickup", spawnPos, NO_REPLACE);
            if (pickup == null) { return; }
            pickup.args[0] = EquipmentSelectionShieldType;
            pickup.args[1] = EquipmentSelectionTier;
            pickup.args[2] = EquipmentSelectionSize + 1;
            pickup.args[3] = EquipmentSelectionDurability + 1;
            persistentState.RemoveOwnedShield(
                EquipmentSelectionShieldType,
                EquipmentSelectionTier,
                EquipmentSelectionSize
            );
        }
        else
        {
            pickup = Spawn("CaelumArmorPickup", spawnPos, NO_REPLACE);
            if (pickup == null) { return; }
            pickup.args[0] = EquipmentSelectionSlot;
            pickup.args[1] = EquipmentSelectionArmorType;
            pickup.args[2] = EquipmentSelectionTier;
            pickup.args[3] = EquipmentSelectionSize + 1;
            pickup.args[4] = EquipmentSelectionDurability + 1;
            persistentState.RemoveOwnedArmor(
                EquipmentSelectionSlot,
                EquipmentSelectionArmorType,
                EquipmentSelectionTier,
                EquipmentSelectionSize
            );
        }
        OwnedArmorCount = persistentState.CountOwnedArmor();
        OwnedShieldCount = persistentState.CountOwnedShields();
        OwnedWeaponCount = persistentState.CountOwnedWeapons();
        ApplyCharacterProfile();
        PersistCharacterState();
        RefreshEquipmentSelectionPreview();
        LastEquipmentAction = CaelumConstants.EQUIPMENT_ACTION_DROPPED;
    }

    // Mantiene la barra sincronizada incluso si otro sistema cambia una pieza
    // sin pasar por los botones del menu de equipo.
    void RefreshEquipmentLoadIfNeeded()
    {
        if (DerivedStats == null || Attributes == null || CharacterProfile == null)
        {
            return;
        }
        double previousArmorWeight = DerivedStats.ArmorWeight;
        double previousShieldWeight = DerivedStats.ShieldWeight;
        double previousWeaponWeight = DerivedStats.WeaponWeight;
        double previousInventoryWeight = DerivedStats.InventoryWeight;
        double previousCarriedItemWeight = DerivedStats.CarriedItemWeight;
        RefreshCarriedInventorySummary();
        bool loadChanged = Abs(previousArmorWeight - DerivedStats.ArmorWeight) > 0.0005
            || Abs(previousShieldWeight - DerivedStats.ShieldWeight) > 0.0005
            || Abs(previousWeaponWeight - DerivedStats.WeaponWeight) > 0.0005
            || Abs(previousInventoryWeight - DerivedStats.InventoryWeight) > 0.0005
            || Abs(previousCarriedItemWeight - DerivedStats.CarriedItemWeight) > 0.0005;
        if (loadChanged)
        {
            ApplyCharacterProfile();
        }
        SyncHUDLoadState();
    }

    void SyncHUDLoadState()
    {
        if (DerivedStats == null)
        {
            HUDCarriedWeight = 0.0;
            HUDCarryCapacity = 0.0;
            HUDLoadRatio = 0.0;
            return;
        }
        HUDCarriedWeight = DerivedStats.CarriedWeight;
        HUDCarryCapacity = DerivedStats.CarryCapacity;
        HUDLoadRatio = DerivedStats.LoadRatio;
    }

    override void PreTravelled()
    {
        EquipmentMenuOpen = false;
        CraftingMenuOpen = false;
        ActiveCraftingStationType = CaelumConstants.CRAFTING_STATION_NONE;
        PersistCharacterState();
        Super.PreTravelled();
    }

    override void Travelled()
    {
        Super.Travelled();
        RestorePersistentCharacterState();
    }

    // PostBeginPlay runs after this player actor has entered the game world.
    // It is a suitable place for first-time initialization of owned objects.
    override void PostBeginPlay()
    {
        Super.PostBeginPlay();
        CollisionDamageMultiplier = 1.0;
        ActiveCraftingStationType = CaelumConstants.CRAFTING_STATION_NONE;

        // Create the attribute container only when it does not already exist.
        // This guard helps prevent accidental replacement of stored data.
        if (Attributes == null)
        {
            // new creates a generic Object, and the explicit cast confirms that
            // the new object is specifically a CaelumAttributes container.
            Attributes = CaelumAttributes(new("CaelumAttributes"));
        }

        if (CharacterProfile == null)
        {
            CharacterProfile = CaelumCharacterProfile(new("CaelumCharacterProfile"));
            CharacterProfile.InitializeDefaultTestProfile();
        }

        if (CharacterAllocation == null)
        {
            CharacterAllocation = CaelumCharacterAllocation(new("CaelumCharacterAllocation"));
            CharacterAllocation.ResetAllocations();
        }

        if (DerivedStats == null)
        {
            DerivedStats = CaelumDerivedStats(new("CaelumDerivedStats"));
        }

        if (AnatomyProfile == null)
        {
            AnatomyProfile = CaelumAnatomyProfile(new("CaelumAnatomyProfile"));
            AnatomyProfile.InitializeHumanoid();
        }

        if (ArmorModel == null)
        {
            ArmorModel = CaelumArmorModel(new("CaelumArmorModel"));
        }

        if (ShieldModel == null)
        {
            ShieldModel = CaelumShieldModel(new("CaelumShieldModel"));
            ShieldModel.InitializeDefaults();
        }
        if (WeaponModel == null)
        {
            WeaponModel = CaelumWeaponModel(new("CaelumWeaponModel"));
            WeaponModel.InitializeDefaults();
        }
        if (ElementalStatus == null)
        {
            ElementalStatus = CaelumElementalStatus(
                new("CaelumElementalStatus")
            );
        }
        SelectedEssenceType = Clamp(
            SelectedEssenceType, 0, CaelumConstants.ESSENCE_TYPE_COUNT - 1
        );
        ShieldModel.EnsureEquippedStateInitialized();
        ArmorModel.InitializeDefaults();
        if (!WeaponWeightInitialized)
        {
            // Compatibilidad: los campos antiguos reflejan el arma real.
            EquippedWeaponBaseWeight = WeaponModel.GetTierOneWeightFor(
                WeaponModel.WeaponType
            );
            EquippedWeaponTier = WeaponModel.Tier;
            EquippedWeaponSize = WeaponModel.Size;
            WeaponWeightInitialized = true;
        }
        if (!ArmorDurabilityMultiplierInitialized)
        {
            // Reserved hook for future durability-loss mitigation effects.
            ArmorDurabilityDamageMultiplier = 1.0;
            ArmorDurabilityMultiplierInitialized = true;
        }

        bool restoredPersistentState = RestorePersistentCharacterState();
        if (!restoredPersistentState)
        {
            ApplyCharacterProfile();
        }
        else if (WeaponModel != null && WeaponModel.Equipped)
        {
            SelectedEssenceType = Clamp(
                WeaponModel.EssenceType,
                0,
                CaelumConstants.ESSENCE_TYPE_COUNT - 1
            );
            EnsureWeaponFamilySelectors();
        }

        if (!HealthResourceInitialized)
        {
            // A newly created or respawned player begins at full calculated
            // health. Existing saved players keep their stored current value.
            CaelumMaximumHealth = Max(1, int(DerivedStats.MaximumHealth));
            health = CaelumMaximumHealth;

            if (player != null)
            {
                player.health = health;
            }

            HealthResourceInitialized = true;
        }

        if (!AirResourceInitialized)
        {
            RefillAir();
            AirResourceInitialized = true;
        }

        if (!AnimaResourceInitialized)
        {
            RefillAnima();
            AnimaResourceInitialized = true;
        }

        if (!AdrenalineResourceInitialized)
        {
            CurrentAdrenaline = 0.0;
            CombatTimeRemaining = 0.0;
            AdrenalineResourceInitialized = true;
        }

        if (!LucidityResourceInitialized)
        {
            CurrentLucidity = CaelumConstants.MAXIMUM_LUCIDITY;
            LucidityResourceInitialized = true;
        }

        UpdateLucidityState();
        UpdateHealthStateEffects();

        if (!SurvivalResourcesInitialized)
        {
            RefillSurvivalResources();
            SurvivalResourcesInitialized = true;
        }

        UpdateAirStateEffects();

        if (player != null)
        {
            WasGroundedLastTick = player.onground;
            JumpTrackingInitialized = true;
        }

        // Report the current calculated sum. It begins at 108 before allocating
        // free points and increases as the player customizes the character.
        Console.Printf(
            "[Caelum] Character creation values loaded. Attribute total: %d",
            Attributes.GetTotalPrimaryLevels()
        );
        RefreshEquipmentSelectionPreview();

        // Un personaje nuevo debe completar el creador antes de jugar.
        // El indicador queda guardado junto al actor y evita reabrirlo al cargar.
        if (!CharacterCreationComplete && !CreationWizardOpen)
        {
            BeginCreationWizard();
        }
    }

    // GZDoom calls this virtual function when health pickups and other engine
    // systems need the player's current maximum. Returning the Constitution
    // value makes ordinary Doom healing respect Caelum's dynamic limit.
    override int GetMaxHealth(bool withupgrades) const
    {
        if (CaelumMaximumHealth > 0)
        {
            return CaelumMaximumHealth;
        }

        return Super.GetMaxHealth(withupgrades);
    }

    bool RollQuintessenceEffect()
    {
        return Random[CaelumQuintessenceEffect](0, 999999) / 10000.0
            < CaelumConstants.QUINTESSENCE_EFFECT_CHANCE_PERCENT;
    }

    void ApplyElementalLucidityLoss(double debuffScale)
    {
        if (DerivedStats == null || debuffScale <= 0.0) { return; }
        double loss = CaelumConstants.CRITICAL_POINT_BASE_LUCIDITY_LOSS
            * debuffScale
            * DerivedStats.LucidityLossMultiplier
            * GetLuciditySleepDebuffMultiplier();
        CurrentLucidity = Max(0.0, CurrentLucidity - loss);
        UpdateLucidityState();
    }

    void ApplyIncomingElementalPayload(
        CaelumActorProjectile projectile,
        int actualHealthLost
    )
    {
        if (projectile == null
            || !projectile.CaelumElementalPayloadPrepared
            || actualHealthLost <= 0)
        {
            return;
        }
        if (ElementalStatus == null)
        {
            ElementalStatus = CaelumElementalStatus(
                new("CaelumElementalStatus")
            );
        }

        double debuffScale = Max(
            0.0, projectile.CaelumDebuffPowerPercent / 100.0
        );
        double duration = CaelumConstants.ELEMENTAL_BASE_DURATION_SECONDS
            * debuffScale;
        double controlPower =
            CaelumConstants.ELEMENTAL_BASE_CONTROL_POWER_PERCENT
                * debuffScale;
        int dotDamage = Max(
            1,
            int(actualHealthLost
                * CaelumConstants.ELEMENTAL_DOT_DAMAGE_RATIO
                * debuffScale + 0.5)
        );
        Actor effectSource = projectile.Target;
        int essenceType = projectile.CaelumEssenceType;
        bool secondary = projectile.CaelumSecondaryElement;

        if (essenceType == CaelumConstants.ESSENCE_FIRE)
        {
            if (secondary)
            {
                ElementalStatus.ApplyControlEffect(
                    CaelumConstants.ELEMENTAL_EFFECT_DAZZLE,
                    duration,
                    controlPower
                );
            }
            else
            {
                ElementalStatus.ApplyDamageOverTime(
                    CaelumConstants.ELEMENTAL_EFFECT_BURN,
                    duration, debuffScale, dotDamage, effectSource
                );
            }
        }
        else if (essenceType == CaelumConstants.ESSENCE_WATER && secondary)
        {
            ElementalStatus.ApplyControlEffect(
                CaelumConstants.ELEMENTAL_EFFECT_FREEZE,
                duration,
                controlPower
            );
        }
        else if (essenceType == CaelumConstants.ESSENCE_EARTH)
        {
            if (secondary)
            {
                ElementalStatus.ApplyDamageOverTime(
                    CaelumConstants.ELEMENTAL_EFFECT_POISON,
                    duration, debuffScale, dotDamage, effectSource
                );
            }
            else
            {
                ApplyElementalLucidityLoss(debuffScale);
            }
        }
        else if (essenceType == CaelumConstants.ESSENCE_WIND)
        {
            if (secondary)
            {
                ElementalStatus.ApplyControlEffect(
                    CaelumConstants.ELEMENTAL_EFFECT_LIGHTNING_STUN,
                    CaelumConstants.ELEMENTAL_LIGHTNING_STUN_SECONDS
                        * debuffScale,
                    1.0
                );
            }
            else
            {
                ElementalStatus.ApplyDamageOverTime(
                    CaelumConstants.ELEMENTAL_EFFECT_CUT,
                    duration, debuffScale, dotDamage, effectSource
                );
            }
        }
        else if (essenceType == CaelumConstants.ESSENCE_QUINTESSENCE
            && secondary)
        {
            if (RollQuintessenceEffect())
                ElementalStatus.ApplyDamageOverTime(
                    CaelumConstants.ELEMENTAL_EFFECT_BURN,
                    duration, debuffScale, dotDamage, effectSource
                );
            if (RollQuintessenceEffect())
                ElementalStatus.ApplyControlEffect(
                    CaelumConstants.ELEMENTAL_EFFECT_DAZZLE,
                    duration, controlPower
                );
            if (RollQuintessenceEffect())
                ApplyAttackPushToTarget(
                    self, projectile.Angle,
                    projectile.CaelumPushMultiplier * 1.5
                );
            if (RollQuintessenceEffect())
                ElementalStatus.ApplyControlEffect(
                    CaelumConstants.ELEMENTAL_EFFECT_FREEZE,
                    duration, controlPower
                );
            if (RollQuintessenceEffect())
                ApplyElementalLucidityLoss(debuffScale);
            if (RollQuintessenceEffect())
                ElementalStatus.ApplyDamageOverTime(
                    CaelumConstants.ELEMENTAL_EFFECT_POISON,
                    duration, debuffScale, dotDamage, effectSource
                );
            if (RollQuintessenceEffect())
                ElementalStatus.ApplyDamageOverTime(
                    CaelumConstants.ELEMENTAL_EFFECT_CUT,
                    duration, debuffScale, dotDamage, effectSource
                );
            if (RollQuintessenceEffect())
                ApplyAttackPushToTarget(
                    self, projectile.Angle,
                    projectile.CaelumPushMultiplier * 0.6
                );
            if (RollQuintessenceEffect())
                ElementalStatus.ApplyControlEffect(
                    CaelumConstants.ELEMENTAL_EFFECT_LIGHTNING_STUN,
                    CaelumConstants.ELEMENTAL_LIGHTNING_STUN_SECONDS
                        * debuffScale,
                    1.0
                );
        }
    }

    // Directed combat damage now uses the complete Caelum defensive order.
    // Environmental and unclassified damage stays on GZDoom's native route.
    double GetImpactMaximumHealth()
    {
        if (CaelumMaximumHealth > 0) { return CaelumMaximumHealth; }
        return Max(1.0, double(GetMaxHealth()));
    }

    double GetImpactReferenceHeight()
    {
        // Usa la altura corporal base derivada del tamaño del personaje.
        // No cambia al agacharse ni por estados temporales del cilindro.
        if (DerivedStats != null && DerivedStats.ActorHeight > 0.0)
        {
            return DerivedStats.ActorHeight;
        }
        return Max(1.0, Height);
    }

    double GetImpactToughnessMultiplier()
    {
        if (DerivedStats == null) { return 1.0; }
        return Clamp(DerivedStats.DamageResistanceMultiplier, 0.0, 1.0);
    }

    double GetImpactArmorDefensePercent()
    {
        if (ArmorModel == null) { return 0.0; }

        double totalDefense = 0.0;
        for (int slot = 0; slot < CaelumConstants.ARMOR_SLOT_COUNT; slot++)
        {
            totalDefense += Clamp(
                double(ArmorModel.GetDefense(slot)),
                0.0,
                100.0
            );
        }
        return totalDefense / CaelumConstants.ARMOR_SLOT_COUNT;
    }

    bool IsBucklerAcrobaticDefenseActive()
    {
        return CombatBlockModeActive
            && (IsGiantGauntletsBlockSource()
                || (ShieldModel != null
                    && ShieldModel.Equipped
                    && ShieldModel.Durability > 0
                    && ShieldModel.ShieldType
                        == CaelumConstants.SHIELD_TYPE_BUCKLER));
    }

    double GetImpactAgilityAbsorptionSpeed(int impactKind)
    {
        if (IsPhysicallyImmobilized()) { return 0.0; }

        double baseAbsorption = Max(0.0, JumpZ);

        // La caída conserva la amortiguación directa por JumpZ.
        if (impactKind == CaelumConstants.IMPACT_KIND_FLOOR)
        {
            if (IsBucklerAcrobaticDefenseActive())
            {
                return baseAbsorption
                    * CaelumConstants.SHIELD_BUCKLER_AGILITY_ABSORPTION_MULTIPLIER;
            }
            return baseAbsorption;
        }

        double baseJump = CaelumConstants.GZDOOM_BASE_JUMP_Z;
        double agilityBonusRatio = Max(
            0.0,
            baseAbsorption / Max(0.0001, baseJump) - 1.0
        );

        // Agacharse permite amortiguar choques contra geometría: el personaje
        // se mueve deliberadamente con cuidado y cede ante el contacto.
        double carefulMovementFraction = 0.0;
        if (IsCrouching
            && impactKind == CaelumConstants.IMPACT_KIND_WALL)
        {
            carefulMovementFraction = Clamp(
                agilityBonusRatio,
                0.0,
                CaelumConstants.SHIELD_BUCKLER_HORIZONTAL_ABSORPTION_MAX_FRACTION
            );
        }

        // La rodela conserva su versión más potente y también funciona contra
        // actores. Si ambas condiciones coinciden usamos la mayor, no se apilan.
        double bucklerFraction = 0.0;
        if (IsBucklerAcrobaticDefenseActive())
        {
            bucklerFraction = Clamp(
                agilityBonusRatio
                    * CaelumConstants.SHIELD_BUCKLER_AGILITY_ABSORPTION_MULTIPLIER,
                0.0,
                CaelumConstants.SHIELD_BUCKLER_HORIZONTAL_ABSORPTION_MAX_FRACTION
            );
        }

        return Max(carefulMovementFraction, bucklerFraction);
    }

    double GetBiologicalLandingAbsorptionSpeed()
    {
        // Un personaje consciente flexiona articulaciones y usa musculatura
        // para absorber un aterrizaje comparable a su propio salto normal.
        // Aturdido/inmovilizado cae rígido: no recibe esta amortiguación.
        return GetImpactAgilityAbsorptionSpeed(
            CaelumConstants.IMPACT_KIND_FLOOR
        );
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

        // Point contact (floor, future point-like geometry).
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
        LastLocalizedLucidityLoss = 0.0;
        if (AnatomyProfile == null
            || DerivedStats == null
            || totalOverlap <= 0.0)
        {
            return;
        }

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
            int slot = GetArmorSlotForHitLocation(location);
            double defenseRatio = ArmorModel != null
                ? Clamp(ArmorModel.GetDefense(slot) / 100.0, 0.0, 1.0)
                : 0.0;
            weightedLoss +=
                CaelumConstants.CRITICAL_POINT_BASE_LUCIDITY_LOSS
                * weight
                * (1.0 - defenseRatio);
        }

        LastImpactLucidityLoss = Min(
            CurrentLucidity,
            weightedLoss
                * DerivedStats.LucidityLossMultiplier
                * GetLuciditySleepDebuffMultiplier()
        );
        LastLocalizedLucidityLoss = LastImpactLucidityLoss;
        if (LastImpactLucidityLoss > 0.0)
        {
            CurrentLucidity = Max(
                0.0,
                CurrentLucidity - LastImpactLucidityLoss
            );
            UpdateLucidityState();
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
        else if (impactKind != CaelumConstants.IMPACT_KIND_FLOOR)
        {
            double horizontalAbsorptionFraction =
                GetImpactAgilityAbsorptionSpeed(impactKind);
            LastImpactBiologicalAbsorptionSpeed =
                LastImpactRawDeltaSpeed * horizontalAbsorptionFraction;
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
        LastImpactToughnessPercent = 0.0;
        if (Attributes != null)
        {
            LastImpactToughnessPercent = Max(
                0.0,
                double(Attributes.Toughness)
            );
            if (IsBucklerAcrobaticDefenseActive())
            {
                LastImpactToughnessPercent *=
                    CaelumConstants.SHIELD_BUCKLER_IMPACT_TOUGHNESS_MULTIPLIER;
            }
        }
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

        double surfaceMultiplier = Max(0.0, sourceSurfaceMultiplier);
        double surfacedDamagePercent =
            LastImpactDamagePercent * surfaceMultiplier;
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
                int slot = GetArmorSlotForHitLocation(location);
                int reinforcement = ArmorModel != null
                    ? ArmorModel.GetReinforcement(slot) : 0;
                int effectiveGrade = Min(
                    CaelumConstants.VULNERABILITY_ARMORED_POINT,
                    naturalGrade + reinforcement
                );
                double vulnerabilityMultiplier =
                    GetVulnerabilityMultiplier(effectiveGrade, false);
                double defenseRatio = ArmorModel != null
                    ? Clamp(
                        ArmorModel.GetDefense(slot) / 100.0,
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

    bool IsCaelumCollisionBody(Actor other)
    {
        return other != null
            && other != self
            && other.health > 0
            && (CaelumPlayer(other) != null
                || CaelumCombatActor(other) != null
                || CaelumTrainingDummy(other) != null);
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
        ImpactContacts.Push(contact);

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
                continue;
            }
            contact.UpdateSeparation(
                level.time,
                CaelumConstants.IMPACT_CONTACT_REARM_SEPARATED_TICS
            );
            if (!contact.Active) { ImpactContacts.Delete(index); }
        }
        // La interfaz sólo lee este valor; no llama funciones de contexto play.
        ImpactContactCountForUI = GetImpactContactCount();
    }

    void ResolveSustainedImpactContact(
        Actor other,
        ImpactContactState contact
    )
    {
        if (other == null || contact == null || !contact.Active) { return; }
        double dx = other.Pos.X - Pos.X;
        double dy = other.Pos.Y - Pos.Y;
        double distance = Sqrt(dx * dx + dy * dy);
        if (distance <= 0.0001) { return; }

        double normalX = dx / distance;
        double normalY = dy / distance;
        double closingSpeed = (Vel.X - other.Vel.X) * normalX
            + (Vel.Y - other.Vel.Y) * normalY;
        if (closingSpeed <= 0.0001) { return; }

        double selfMass = Max(1.0, GetCombatMass());
        double otherMass = Max(1.0, GetOtherCollisionEffectiveMass(other));
        double inverseMassSum = 1.0 / selfMass + 1.0 / otherMass;
        if (inverseMassSum <= 0.0) { return; }

        // Restricción inelástica: transmite la presión sin generar otro golpe.
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
            ApplySustainedCrush(other, normalX, normalY);
        }
    }

    double GetImpactWalkingSpeed()
    {
        return CaelumConstants.GZDOOM_BASE_MAX_WALK_SPEED
            * Max(0.0, ForwardMove1);
    }

    void ApplySustainedCrush(Actor other, double normalX, double normalY)
    {
        double walkingSpeed = GetImpactWalkingSpeed();
        if (other == null || walkingSpeed <= 0.0001) { return; }

        ImpactBody sourceBody = BuildImpactPhysicsBody();
        ImpactBody targetBody = BuildOtherImpactPhysicsBody(other);
        ImpactResult crushResult = new("ImpactResult");
        if (sourceBody == null || targetBody == null || crushResult == null)
        {
            return;
        }

        // El daño por segundo equivale a una colisión a velocidad de marcha.
        sourceBody.Velocity = (
            normalX * walkingSpeed,
            normalY * walkingSpeed,
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
        ImpactBody body = new("ImpactBody");
        if (body == null) { return null; }
        body.Mass = Max(1.0, GetCombatMass());
        body.Height = GetImpactReferenceHeight();
        body.Position = Pos;
        body.Velocity = Vel;
        body.Restitution = CaelumConstants.IMPACT_RESTITUTION;
        body.SurfaceMultiplier = CollisionDamageMultiplier;
        return body;
    }

    ImpactBody BuildOtherImpactPhysicsBody(Actor other)
    {
        ImpactBody body = new("ImpactBody");
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

    override void CollidedWith(Actor other, bool passive)
    {
        Super.CollidedWith(other, passive);

        // CollidedWith se ejecuta en ambos actores. Sólo el lado activo
        // resuelve el par para evitar duplicar acción-reacción.
        if (passive || !IsCaelumCollisionBody(other) || health <= 0)
        {
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
        double distance = Sqrt(dx * dx + dy * dy);
        if (distance <= 0.0001) { return; }

        Vector3 collisionNormal = (dx / distance, dy / distance, 0.0);
        ImpactBody selfBody;
        ImpactBody otherBody;
        ImpactResult impact;
        selfBody = BuildImpactPhysicsBody();
        otherBody = BuildOtherImpactPhysicsBody(other);
        impact = new("ImpactResult");
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

        // A partir de aquí es un único impacto. Mantener presión contra el
        // mismo cuerpo no vuelve a crear choques hasta separarse físicamente.
        contactState = LatchImpactContact(other);
        if (contactState != null)
        {
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

        // La dirección realmente perdida por el movimiento del motor funciona
        // como normal efectiva. La geometría estática es el límite M -> infinito.
        Vector3 normal = (
            lostVelocity.X / lostSpeed,
            lostVelocity.Y / lostSpeed,
            0.0
        );

        ImpactBody selfBody;
        ImpactResult impact;
        selfBody = BuildImpactPhysicsBody();
        impact = new("ImpactResult");
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

    void RegisterWorldImpact(
        double deltaSpeed,
        int impactKind
    )
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
            Max(1.0, GetCombatMass()),
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
        // El mundo no puede dañar al personaje antes de confirmar su creación.
        if (CreationWizardOpen && !CharacterCreationComplete)
        {
            return 0;
        }

        // Impacto cinemático: no puede evadirse, bloquearse ni localizarse por
        // armadura. Es trauma global basado en Δv y vida máxima.
        if (mod == 'CaelumImpact')
        {
            int healthBeforeImpact = health;
            double adrenalineRatioBeforeImpact = 0.0;
            if (DerivedStats != null && DerivedStats.MaximumAdrenaline > 0.0)
            {
                adrenalineRatioBeforeImpact = Clamp(
                    CurrentAdrenaline / DerivedStats.MaximumAdrenaline,
                    0.0,
                    1.0
                );
            }

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
                TryInterruptPendingStaffCast(
                    actualHealthLost, adrenalineRatioBeforeImpact
                );
                UpdateHealthStateEffects();
                CalculateAndTriggerPain(
                    actualHealthLost,
                    adrenalineRatioBeforeImpact,
                    LastImpactKind == CaelumConstants.IMPACT_KIND_ACTOR
                );
                if (LastImpactKind == CaelumConstants.IMPACT_KIND_ACTOR)
                {
                    AddCombatAdrenaline(
                        CaelumConstants.ADRENALINE_GAIN_ON_DAMAGE,
                        CaelumConstants.ADRENALINE_EVENT_DAMAGE
                    );
                    MarkCombatActivity();
                }
            }
            return result;
        }

        LastEvasionAttempted = false;
        LastEvasionSucceeded = false;
        LastEvasionChancePercent = 0.0;
        LastEvasionRollPercent = 0.0;

        if (IsEvadableDamage(inflictor, source, damage, mod, flags))
        {
            LastEvasionAttempted = true;
            LastEvasionChancePercent = Clamp(EffectiveEvasionChance, 0.0, 100.0);
            int evasionRoll = Random[CaelumEvasion](0, 999999);
            LastEvasionRollPercent = evasionRoll / 10000.0;
            if (LastEvasionRollPercent < LastEvasionChancePercent)
            {
                LastEvasionSucceeded = true;
                AddCombatAdrenaline(
                    CaelumConstants.ADRENALINE_GAIN_ON_EVASION,
                    CaelumConstants.ADRENALINE_EVENT_EVASION
                );
                MarkCombatActivity();
                return 0;
            }
        }

        if (flags & DMG_EXPLOSION)
        {
            return ApplyExplosionDefense(
                inflictor,
                source,
                damage,
                mod,
                flags,
                angle
            );
        }

        if (IsDirectedCombatDamage(inflictor, source, damage, mod, flags))
        {
            return ApplyRealCombatDefense(
                inflictor,
                source,
                damage,
                mod,
                flags,
                angle
            );
        }

        int healthBeforeDamage = health;
        double adrenalineRatioBeforeDamage = 0.0;
        if (DerivedStats != null && DerivedStats.MaximumAdrenaline > 0.0)
        {
            adrenalineRatioBeforeDamage = Clamp(
                CurrentAdrenaline / DerivedStats.MaximumAdrenaline,
                0.0,
                1.0
            );
        }
        int result = Super.DamageMobj(
            inflictor,
            source,
            damage,
            mod,
            flags,
            angle
        );

        if (health < healthBeforeDamage)
        {
            int actualHealthLost = healthBeforeDamage - health;
            TryInterruptPendingStaffCast(
                actualHealthLost, adrenalineRatioBeforeDamage
            );
            UpdateHealthStateEffects();
            CalculateAndTriggerPain(
                actualHealthLost,
                adrenalineRatioBeforeDamage,
                true
            );
            AddCombatAdrenaline(
                CaelumConstants.ADRENALINE_GAIN_ON_DAMAGE,
                CaelumConstants.ADRENALINE_EVENT_DAMAGE
            );
            MarkCombatActivity();
        }

        return result;
    }

    bool IsDirectedCombatDamage(
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
        if (inflictor != null && inflictor.bMissile) { return true; }
        return source != null
            && (mod == 'Melee'
                || mod == 'Hitscan'
                || mod == 'Bullet'
                || mod == 'CaelumMeleeTest'
                || mod == 'CaelumRangedTest'
                || mod == 'CaelumMagicTest');
    }

    double GetEffectiveExplosionRadius(Actor inflictor, int incomingDamage)
    {
        double resolvedRadius = Max(1.0, double(incomingDamage));
        if (inflictor == null) { return resolvedRadius; }

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

    int GetArmorSlotForHitLocation(int location)
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

    // GZDoom entrega una sola cantidad radial por actor. Caelum reutiliza esa
    // base una vez por cada volumen anatómico alcanzado y suma el resultado
    // recién después de resolver vulnerabilidad, refuerzo y defensa por pieza.
    int ApplyExplosionDefense(
        Actor inflictor,
        Actor source,
        int incomingDamage,
        Name mod,
        int flags,
        double damageAngle
    )
    {
        LastExplosionTouchedRegionMask = 0;
        LastExplosionTouchedRegionCount = 0;
        LastExplosionRadius = GetEffectiveExplosionRadius(inflictor, incomingDamage);
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

        LastExplosionTouchedRegionMask = AnatomyProfile.GetExplosionTouchedRegionMask(
            self,
            inflictor.Pos,
            LastExplosionRadius
        );
        if (LastExplosionTouchedRegionMask == 0) { return 0; }

        bool criticalHit = ResolveIncomingActorCritical(inflictor, source);
        LastArmorPreDefenseDamage = 0.0;
        LastArmorAbsorbedDamage = 0.0;
        LastArmorPostDefenseDamage = 0.0;
        LastArmorHealthDamage = 0;
        LastArmorDurabilityLoss = 0;
        LastArmorDurabilityChancePercent = 0.0;
        LastArmorDurabilityRollPercent = 0.0;
        LastArmorHitWasCritical = criticalHit;
        LastLocalizedLucidityLoss = 0.0;
        LastToughnessDamageMultiplier = DerivedStats != null
            ? Clamp(DerivedStats.DamageResistanceMultiplier, 0.0, 1.0)
            : 1.0;

        int totalHealthDamage = 0;
        bool armorPieceBroken = false;
        int lucidityNaturalGrade = -1;
        int lucidityEffectiveGrade = -1;
        double lucidityDefenseRatio = 0.0;
        for (int regionIndex = 0;
            regionIndex < AnatomyProfile.RegionCount;
            regionIndex++)
        {
            if ((LastExplosionTouchedRegionMask & (1 << regionIndex)) == 0)
            {
                continue;
            }
            LastExplosionTouchedRegionCount++;
            int location = AnatomyProfile.GetLocation(regionIndex);
            int naturalGrade = AnatomyProfile.GetVulnerability(regionIndex);
            int slot = GetArmorSlotForHitLocation(location);
            int reinforcement = ArmorModel != null
                ? ArmorModel.GetReinforcement(slot) : 0;
            int effectiveGrade = Min(
                CaelumConstants.VULNERABILITY_ARMORED_POINT,
                naturalGrade + reinforcement
            );
            double vulnerabilityMultiplier = GetVulnerabilityMultiplier(
                effectiveGrade,
                criticalHit
            );
            double preDefenseDamage = incomingDamage * vulnerabilityMultiplier;
            double defenseRatio = ArmorModel != null
                ? Clamp(ArmorModel.GetDefense(slot) / 100.0, 0.0, 1.0)
                : 0.0;
            double absorbedDamage = preDefenseDamage * defenseRatio;
            double postDefenseDamage = Max(
                0.0,
                preDefenseDamage - absorbedDamage
            );

            LastArmorVulnerabilityGrade = effectiveGrade;
            LastArmorVulnerabilityMultiplier = vulnerabilityMultiplier;
            LastArmorPreDefenseDamage += preDefenseDamage;
            LastArmorAbsorbedDamage += absorbedDamage;
            LastArmorPostDefenseDamage += postDefenseDamage;
            totalHealthDamage += Max(
                0,
                int(postDefenseDamage * LastToughnessDamageMultiplier + 0.5)
            );

            if (naturalGrade == CaelumConstants.VULNERABILITY_CRITICAL_POINT
                && lucidityNaturalGrade < 0)
            {
                lucidityNaturalGrade = naturalGrade;
                lucidityEffectiveGrade = effectiveGrade;
                lucidityDefenseRatio = defenseRatio;
            }

            if (ArmorModel != null
                && ArmorModel.Durability[slot] > 0
                && absorbedDamage > 0.0)
            {
                double eligibleDamage = absorbedDamage
                    * Max(0.0, ArmorDurabilityDamageMultiplier);
                int durabilityLoss = int(
                    eligibleDamage
                        / CaelumConstants.ARMOR_ABSORBED_DAMAGE_PER_GUARANTEED_DURABILITY
                );
                double remainder = eligibleDamage
                    - durabilityLoss
                        * CaelumConstants.ARMOR_ABSORBED_DAMAGE_PER_GUARANTEED_DURABILITY;
                double chancePercent = Clamp(
                    remainder
                        / CaelumConstants.ARMOR_DAMAGE_PER_DURABILITY_CHANCE_PERCENT,
                    0.0,
                    100.0
                );
                double rollPercent = Random[CaelumArmorDurability](0, 999999)
                    / 10000.0;
                if (rollPercent < chancePercent) { durabilityLoss++; }
                durabilityLoss = Min(durabilityLoss, ArmorModel.Durability[slot]);
                ArmorModel.Durability[slot] -= durabilityLoss;
                if (durabilityLoss > 0 && ArmorModel.Durability[slot] <= 0)
                {
                    armorPieceBroken = true;
                }
                LastArmorDurabilityLoss += durabilityLoss;
                LastArmorDurabilityChancePercent = chancePercent;
                LastArmorDurabilityRollPercent = rollPercent;
            }
        }

        LastArmorHealthDamage = totalHealthDamage;
        if (totalHealthDamage <= 0)
        {
            if (armorPieceBroken) { ApplyCharacterProfile(); }
            return 0;
        }

        double adrenalineRatioBeforeDamage = 0.0;
        if (DerivedStats != null && DerivedStats.MaximumAdrenaline > 0.0)
        {
            adrenalineRatioBeforeDamage = Clamp(
                CurrentAdrenaline / DerivedStats.MaximumAdrenaline,
                0.0,
                1.0
            );
        }
        int healthBeforeDamage = health;
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
            LastArmorHealthDamage = actualHealthLost;
            TryInterruptPendingStaffCast(
                actualHealthLost, adrenalineRatioBeforeDamage
            );
            CaelumActorProjectile attackProjectile = CaelumActorProjectile(inflictor);
            if (attackProjectile != null)
            {
                ApplyAttackPushToTarget(
                    self,
                    inflictor.AngleTo(self),
                    attackProjectile.CaelumPushMultiplier
                );
                if (!LastShieldBlockedAttack)
                {
                    ApplyIncomingElementalPayload(
                        attackProjectile, actualHealthLost
                    );
                }
            }
            if (lucidityNaturalGrade >= 0)
            {
                ApplyLocalizedLucidityLoss(
                    lucidityNaturalGrade,
                    lucidityEffectiveGrade,
                    criticalHit,
                    lucidityDefenseRatio
                );
            }
            UpdateHealthStateEffects();
            CalculateAndTriggerPain(
                actualHealthLost,
                adrenalineRatioBeforeDamage,
                true
            );
            AddCombatAdrenaline(
                CaelumConstants.ADRENALINE_GAIN_ON_DAMAGE,
                CaelumConstants.ADRENALINE_EVENT_DAMAGE
            );
            MarkCombatActivity();
        }
        if (armorPieceBroken) { ApplyCharacterProfile(); }
        return result;
    }

    int ResolveIncomingArmorSlot(Actor inflictor, Actor source)
    {
        double impactZ = Pos.Z + Height * 0.60;
        if (inflictor != null)
        {
            impactZ = inflictor.Pos.Z + inflictor.Height * 0.5;
        }
        else if (source != null)
        {
            impactZ = source.Pos.Z + source.Height * 0.60;
        }

        double heightRatio = Height > 0.0
            ? Clamp((impactZ - Pos.Z) / Height, 0.0, 1.0)
            : 0.60;

        if (heightRatio >= CaelumConstants.HIT_HEAD_MINIMUM_RATIO)
            return CaelumConstants.ARMOR_SLOT_HEAD;
        if (heightRatio >= CaelumConstants.HIT_ARMS_MINIMUM_RATIO
            && heightRatio <= CaelumConstants.HIT_ARMS_MAXIMUM_RATIO)
            return CaelumConstants.ARMOR_SLOT_HANDS;
        if (heightRatio >= CaelumConstants.HIT_TORSO_MINIMUM_RATIO)
            return CaelumConstants.ARMOR_SLOT_BODY;
        return CaelumConstants.ARMOR_SLOT_FEET;
    }

    int ApplyRealCombatDefense(
        Actor inflictor,
        Actor source,
        int incomingDamage,
        Name mod,
        int flags,
        double damageAngle
    )
    {
        // Invulnerability must reject the complete hit before block rewards or
        // custom durability are calculated.
        if (bInvulnerable)
        {
            return Super.DamageMobj(
                inflictor,
                source,
                incomingDamage,
                mod,
                flags,
                damageAngle
            );
        }
        double damageAfterShield = ResolveRealShieldDamage(
            inflictor,
            source,
            incomingDamage,
            mod
        );
        bool incomingActorCritical = ResolveIncomingActorCritical(
            inflictor,
            source
        );
        LastIncomingArmorSlot = ResolveIncomingArmorSlot(inflictor, source);
        PrepareRealArmorDamage(
            damageAfterShield,
            incomingActorCritical,
            LastIncomingArmorSlot
        );

        double adrenalineRatioBeforeDamage = 0.0;
        if (DerivedStats != null && DerivedStats.MaximumAdrenaline > 0.0)
        {
            adrenalineRatioBeforeDamage = Clamp(
                CurrentAdrenaline / DerivedStats.MaximumAdrenaline,
                0.0,
                1.0
            );
        }

        int healthBeforeDamage = health;
        int finalDamage = Max(0, LastArmorHealthDamage);
        int result = 0;
        if (finalDamage > 0)
        {
            result = Super.DamageMobj(
                inflictor,
                source,
                finalDamage,
                mod,
                flags | DMG_NO_ARMOR,
                damageAngle
            );
        }

        CommitRealShieldDurability();
        CommitRealArmorDurability();

        if (health < healthBeforeDamage)
        {
            int actualHealthLost = healthBeforeDamage - health;
            TryInterruptPendingStaffCast(
                actualHealthLost, adrenalineRatioBeforeDamage
            );
            CaelumActorProjectile attackProjectile = CaelumActorProjectile(inflictor);
            if (attackProjectile != null)
            {
                ApplyAttackPushToTarget(
                    self,
                    inflictor.Angle,
                    attackProjectile.CaelumPushMultiplier
                );
                ApplyIncomingElementalPayload(
                    attackProjectile, actualHealthLost
                );
            }
            LastArmorHealthDamage = actualHealthLost;
            ApplyLocalizedLucidityLoss(
                GetBaseVulnerabilityForArmorSlot(LastIncomingArmorSlot),
                LastArmorVulnerabilityGrade,
                incomingActorCritical,
                Clamp(
                    ArmorModel.GetDefense(LastIncomingArmorSlot) / 100.0,
                    0.0, 1.0
                )
            );
            UpdateHealthStateEffects();
            CalculateAndTriggerPain(
                actualHealthLost,
                adrenalineRatioBeforeDamage,
                true
            );
            if (!LastShieldBlockedAttack)
            {
                AddCombatAdrenaline(
                    CaelumConstants.ADRENALINE_GAIN_ON_DAMAGE,
                    CaelumConstants.ADRENALINE_EVENT_DAMAGE
                );
            }
            MarkCombatActivity();
        }
        return result;
    }

    // Melee actors deliver their pending critical synchronously. Projectiles
    // carry an immutable copy because the shooter may launch another attack
    // before the first missile reaches its target.
    bool ResolveIncomingActorCritical(Actor inflictor, Actor source)
    {
        LastIncomingActorCriticalHit = false;
        LastIncomingActorCriticalChancePercent = 0.0;
        LastIncomingActorCriticalRollPercent = 0.0;

        CaelumActorProjectile actorProjectile = CaelumActorProjectile(inflictor);
        CaelumCombatActor attacker = CaelumCombatActor(source);
        if (actorProjectile != null)
        {
            LastIncomingActorCriticalHit = actorProjectile.CaelumCriticalHit;
            if (attacker != null)
            {
                LastIncomingActorCriticalChancePercent =
                    attacker.LastCombatAttackCriticalChancePercent;
                LastIncomingActorCriticalRollPercent =
                    attacker.LastCombatAttackCriticalRollPercent;
            }
            return LastIncomingActorCriticalHit;
        }

        if (attacker != null)
        {
            LastIncomingActorCriticalChancePercent =
                attacker.LastCombatAttackCriticalChancePercent;
            LastIncomingActorCriticalRollPercent =
                attacker.LastCombatAttackCriticalRollPercent;
            LastIncomingActorCriticalHit =
                attacker.ConsumePendingCombatCritical();
        }
        return LastIncomingActorCriticalHit;
    }

    void RegisterNativeReflectedShieldBlock(Actor missile)
    {
        if (!CombatBlockModeActive
            || ShieldModel == null
            || !ShieldModel.Equipped
            || ShieldModel.Durability <= 0
            || ShieldModel.ShieldType != CaelumConstants.SHIELD_TYPE_MAGIC)
        {
            return;
        }

        Actor attacker = missile != null ? missile.Target : null;
        double incomingOffset = 180.0;
        if (attacker != null)
        {
            incomingOffset = Abs(DeltaAngle(Angle, AngleTo(attacker)));
        }
        if (incomingOffset > ShieldModel.GetCoverageDegrees() / 2.0)
        {
            return;
        }

        AddCombatAdrenaline(
            CaelumConstants.ADRENALINE_GAIN_ON_SHIELD_BLOCK,
            CaelumConstants.ADRENALINE_EVENT_SHIELD_BLOCK
        );
        MarkCombatActivity();
    }

    double ResolveRealShieldDamage(
        Actor inflictor,
        Actor source,
        double incomingDamage,
        Name mod
    )
    {
        LastShieldAbsorbedDamage = 0.0;
        LastShieldHealthDamage = Max(0, int(incomingDamage + 0.5));
        LastShieldBlockedAttack = false;
        LastShieldDurabilityLoss = 0;
        LastShieldDurabilityChancePercent = 0.0;
        LastShieldDurabilityRollPercent = 0.0;

        Actor attacker = source != null ? source : inflictor;
        double incomingOffset = 180.0;
        if (attacker != null)
        {
            incomingOffset = Abs(DeltaAngle(Angle, AngleTo(attacker)));
        }
        DebugShieldIncomingAngleOffset = int(incomingOffset + 0.5);
        LastShieldWithinCoverage = HasActiveBlockSource()
            && incomingOffset <= GetActiveBlockCoverageDegrees() / 2.0;
        bool shieldCanBlock = HasActiveBlockSource()
            && DebugShieldBlocking
            && LastShieldWithinCoverage;
        if (!shieldCanBlock) { return incomingDamage; }
        LastShieldBlockedAttack = true;


        int damageKind = mod == 'CaelumMagicTest'
            ? CaelumConstants.SHIELD_DAMAGE_MAGICAL
            : CaelumConstants.SHIELD_DAMAGE_PHYSICAL;
        double defenseRatio = Clamp(
            GetActiveBlockDefense(damageKind) / 100.0,
            0.0,
            1.0
        );
        LastShieldAbsorbedDamage = incomingDamage * defenseRatio;
        LastShieldHealthDamage = Max(
            0,
            int(incomingDamage - LastShieldAbsorbedDamage + 0.5)
        );
        if (LastShieldAbsorbedDamage > 0.0)
        {
            double blockAdrenaline =
                CaelumConstants.ADRENALINE_GAIN_ON_SHIELD_BLOCK;
            if (!IsGiantGauntletsBlockSource()
                && ShieldModel.ShieldType == CaelumConstants.SHIELD_TYPE_KITE)
            {
                blockAdrenaline *=
                    CaelumConstants.SHIELD_KITE_BLOCK_ADRENALINE_MULTIPLIER;
            }
            AddCombatAdrenaline(
                blockAdrenaline,
                CaelumConstants.ADRENALINE_EVENT_SHIELD_BLOCK
            );
            MarkCombatActivity();
        }
        CalculateRealShieldDurabilityLoss();
        return LastShieldHealthDamage;
    }

    void CalculateRealShieldDurabilityLoss()
    {
        double eligibleDamage = LastShieldAbsorbedDamage
            * Max(0.0, ArmorDurabilityDamageMultiplier);
        LastShieldDurabilityLoss = int(
            eligibleDamage
                / CaelumConstants.ARMOR_ABSORBED_DAMAGE_PER_GUARANTEED_DURABILITY
        );
        double remainder = eligibleDamage
            - LastShieldDurabilityLoss
                * CaelumConstants.ARMOR_ABSORBED_DAMAGE_PER_GUARANTEED_DURABILITY;
        LastShieldDurabilityChancePercent = Clamp(
            remainder / CaelumConstants.ARMOR_DAMAGE_PER_DURABILITY_CHANCE_PERCENT,
            0.0,
            100.0
        );
        int roll = Random[CaelumShieldDurability](0, 999999);
        LastShieldDurabilityRollPercent = roll / 10000.0;
        if (LastShieldDurabilityRollPercent < LastShieldDurabilityChancePercent)
        {
            LastShieldDurabilityLoss++;
        }
    }

    void CommitRealShieldDurability()
    {
        if (LastShieldDurabilityLoss <= 0) { return; }
        if (IsGiantGauntletsBlockSource())
        {
            LastShieldDurabilityLoss = Min(
                LastShieldDurabilityLoss, WeaponModel.Durability
            );
            WeaponModel.Durability -= LastShieldDurabilityLoss;
            if (WeaponModel.Durability <= 0) { CancelCombatBlockMode(); }
            return;
        }
        if (ShieldModel == null) { return; }
        LastShieldDurabilityLoss = Min(
            LastShieldDurabilityLoss, ShieldModel.Durability
        );
        ShieldModel.Durability -= LastShieldDurabilityLoss;
        if (ShieldModel.Durability <= 0) { CancelCombatBlockMode(); }
    }

    void PrepareRealArmorDamage(
        double incomingDamage,
        bool criticalHit,
        int incomingSlot
    )
    {
        LastLocalizedLucidityLoss = 0.0;
        LastArmorPreDefenseDamage = 0.0;
        LastArmorAbsorbedDamage = 0.0;
        LastArmorPostDefenseDamage = 0.0;
        LastArmorHealthDamage = 0;
        LastArmorDurabilityLoss = 0;
        LastArmorDurabilityChancePercent = 0.0;
        LastArmorDurabilityRollPercent = 0.0;
        LastArmorHitWasCritical = criticalHit && incomingDamage > 0.0;
        if (ArmorModel == null || incomingDamage <= 0.0) { return; }

        int slot = Clamp(
            incomingSlot, 0, CaelumConstants.ARMOR_SLOT_COUNT - 1
        );
        LastArmorVulnerabilityGrade = GetEffectiveArmorVulnerability(slot);
        LastArmorVulnerabilityMultiplier = GetVulnerabilityMultiplier(
            LastArmorVulnerabilityGrade,
            criticalHit
        );
        LastArmorPreDefenseDamage = incomingDamage
            * LastArmorVulnerabilityMultiplier;
        double defenseRatio = Clamp(
            ArmorModel.GetDefense(slot) / 100.0,
            0.0,
            1.0
        );
        LastArmorAbsorbedDamage = LastArmorPreDefenseDamage * defenseRatio;
        LastArmorPostDefenseDamage = Max(
            0.0,
            LastArmorPreDefenseDamage - LastArmorAbsorbedDamage
        );
        LastToughnessDamageMultiplier = DerivedStats != null
            ? Clamp(DerivedStats.DamageResistanceMultiplier, 0.0, 1.0)
            : 1.0;
        LastArmorHealthDamage = Max(
            0,
            int(LastArmorPostDefenseDamage
                * LastToughnessDamageMultiplier + 0.5)
        );

        double eligibleDamage = LastArmorAbsorbedDamage
            * Max(0.0, ArmorDurabilityDamageMultiplier);
        LastArmorDurabilityLoss = int(
            eligibleDamage
                / CaelumConstants.ARMOR_ABSORBED_DAMAGE_PER_GUARANTEED_DURABILITY
        );
        double remainder = eligibleDamage
            - LastArmorDurabilityLoss
                * CaelumConstants.ARMOR_ABSORBED_DAMAGE_PER_GUARANTEED_DURABILITY;
        LastArmorDurabilityChancePercent = Clamp(
            remainder / CaelumConstants.ARMOR_DAMAGE_PER_DURABILITY_CHANCE_PERCENT,
            0.0,
            100.0
        );
        int roll = Random[CaelumArmorDurability](0, 999999);
        LastArmorDurabilityRollPercent = roll / 10000.0;
        if (LastArmorDurabilityRollPercent < LastArmorDurabilityChancePercent)
        {
            LastArmorDurabilityLoss++;
        }
    }

    void CommitRealArmorDurability()
    {
        if (ArmorModel == null || LastArmorDurabilityLoss <= 0) { return; }
        int slot = Clamp(
            LastIncomingArmorSlot, 0, CaelumConstants.ARMOR_SLOT_COUNT - 1
        );
        LastArmorDurabilityLoss = Min(
            LastArmorDurabilityLoss,
            ArmorModel.Durability[slot]
        );
        ArmorModel.Durability[slot] -= LastArmorDurabilityLoss;
        if (ArmorModel.Durability[slot] <= 0) { ApplyCharacterProfile(); }
    }

    // Only directed physical attacks enter the current evasion roll. Missiles,
    // hitscan fire, and melee qualify. Explosions, hazards, floors, drowning,
    // telefrags, and other unclassified damage deliberately bypass evasion.
    bool IsEvadableDamage(
        Actor inflictor,
        Actor source,
        int damage,
        Name mod,
        int flags
    )
    {
        if (health <= 0
            || player == null
            || player.playerstate != PST_LIVE
            || damage <= 0
            || (flags & DMG_EXPLOSION))
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

    // Pain uses the percentage of maximum health actually lost after armor,
    // invulnerability, and every other engine mitigation. Ten times that
    // percentage is reduced multiplicatively by Dureza Type 3 and by the
    // adrenaline percentage that existed before this hit.
    void CalculateAndTriggerPain(
        int actualHealthLost,
        double adrenalineRatioBeforeDamage,
        bool grantPainAdrenaline
    )
    {
        LastHealthLossPercent = 0.0;
        LastPainChancePercent = 0.0;
        LastPainTriggered = false;

        if (actualHealthLost <= 0
            || CaelumMaximumHealth <= 0
            || DerivedStats == null
            || health <= 0)
        {
            return;
        }

        LastHealthLossPercent = 100.0
            * actualHealthLost / CaelumMaximumHealth;
        LastPainChancePercent = Clamp(
            10.0 * LastHealthLossPercent
                * DerivedStats.PainChanceMultiplier
                * HealthPainMultiplier
                * (1.0 - adrenalineRatioBeforeDamage),
            0.0,
            100.0
        );

        // Use a dedicated deterministic random stream for network-safe play.
        int painRoll = Random[CaelumPain](0, 999999);
        if (painRoll < int(LastPainChancePercent * 10000.0))
        {
            State painState = FindState('Pain');
            if (painState != null)
            {
                LastPainAnimationDuration = CalculatePainAnimationDuration(painState);
                PainImmobilizationRemaining = Max(
                    PainImmobilizationRemaining,
                    LastPainAnimationDuration
                );
                SetState(painState);
                LastPainTriggered = true;
                CancelWeaponCharge();
                if (PendingStaffChargedAttack)
                {
                    PendingStaffChargedAttack = false;
                    PendingStaffAnimaCost /=
                        CaelumConstants.WEAPON_CHARGED_COST_MULTIPLIER;
                }
                if (grantPainAdrenaline)
                {
                    AddCombatAdrenaline(
                        CaelumConstants.ADRENALINE_GAIN_ON_PAIN,
                        CaelumConstants.ADRENALINE_EVENT_PAIN
                    );
                }
            }
        }
    }

    // Sum the finite states from Pain until the sequence returns to Spawn.
    // DoomPlayer uses two four-tic pain frames, so its live duration is 8/35 s.
    // Future player actors can use a different animation without duplicating a
    // hard-coded control-lock duration here.
    double CalculatePainAnimationDuration(State painState)
    {
        if (painState == null) { return 0.0; }

        State spawnState = FindState('Spawn');
        State cursor = painState;
        int totalTics = 0;
        for (int stateCount = 0; stateCount < 64; stateCount++)
        {
            if (cursor == null || cursor == spawnState) { break; }
            if (cursor.Tics < 0) { break; }
            totalTics += Max(0, cursor.Tics);
            cursor = cursor.NextState;
        }
        return totalTics / double(TICRATE);
    }

    // Intenta mover un objeto de escenario colocado frente al jugador.
    // La detección reutiliza Player.UseRange, por lo que respeta el alcance
    // nativo configurado para la clase de jugador en vez de duplicar un valor.
    bool TryPushMovablePropInFront()
    {
        if (player == null || player.playerstate != PST_LIVE
            || DerivedStats == null)
        {
            return false;
        }

        FTranslatedLineTarget targetData;
        Actor detectionPuff;
        int ignoredDamage;
        [detectionPuff, ignoredDamage] = LineAttack(
            Angle,
            Max(1.0, UseRange),
            Pitch,
            0,
            'CaelumPropInteraction',
            'CaelumSilentDetectionPuff',
            LAF_NOINTERACT | LAF_NORANDOMPUFFZ,
            targetData
        );

        CaelumMovableProp movable = CaelumMovableProp(targetData.linetarget);
        if (movable == null) { return false; }

        double physicalPower = Max(
            0.0, DerivedStats.PhysicalPushMultiplier
        );
        double pushForce = CaelumConstants.BASE_ATTACK_PUSH_FORCE
            * physicalPower;
        return movable.TryPushFrom(self, physicalPower, pushForce);
    }

    // +use puede mantenerse varios tics. Sólo intentamos un empuje por
    // pulsación para evitar aceleraciones artificiales de 35 impulsos/segundo.
    void UpdateMovablePropUseInteraction()
    {
        if (player == null)
        {
            MovablePropUseLatched = false;
            return;
        }

        bool usePressed = (player.cmd.buttons & BT_USE) != 0;
        if (!usePressed)
        {
            MovablePropUseLatched = false;
            return;
        }

        if (MovablePropUseLatched) { return; }
        MovablePropUseLatched = true;

        // La predicción de cliente no debe aplicar un segundo impulso sobre
        // el mismo actor; el tic autoritativo realiza la interacción real.
        if (player.cheats & CF_PREDICTING) { return; }
        TryPushMovablePropInFront();
    }

    // Bloquea las acciones normales mientras el creador ocupa la pantalla.
    // Los comandos del creador viajan por eventos de red independientes.
    override void PlayerThink()
    {
        // Mientras canaliza se conserva exclusivamente una nueva pulsacion de
        // User2 para permitir la interrupcion manual antes de limpiar acciones.
        if (CombatChannelModeActive && player != null)
        {
            bool channelPressed = (player.cmd.buttons & BT_USER2) != 0;
            if (channelPressed && !CombatChannelInputLatched)
                RequestCombatChannelInput();
            if (!channelPressed) CombatChannelInputLatched = false;
        }
        if ((CreationWizardOpen || EquipmentMenuOpen || CraftingMenuOpen
                || CombatChannelModeActive)
            && player != null)
        {
            UserCmd creationCommand = player.cmd;
            creationCommand.forwardmove = 0;
            creationCommand.sidemove = 0;
            creationCommand.upmove = 0;
            creationCommand.buttons = 0;

            // UserCmd no admite asignación estructural en GZDoom 4.14.2.
            // Limpiamos directamente los campos nativos antes de
            // Super.PlayerThink() para que BT_USE no reactive la estación.
            player.cmd.forwardmove = 0;
            player.cmd.sidemove = 0;
            player.cmd.upmove = 0;
            player.cmd.buttons = 0;

            Vel.X = 0.0;
            Vel.Y = 0.0;
        }

        Super.PlayerThink();
    }

    // Tick runs once per game tic. GZDoom uses 35 tics per second, so dividing
    // the documented per-second rate by TICRATE produces frame-independent
    // regeneration that also pauses when the game itself is paused.
    override void Tick()
    {
        Vector3 prePhysicsVelocity = Vel;

        Super.Tick();

        bool groundedNow = player != null && player.onground;
        if (!ImpactGroundTrackingInitialized)
        {
            ImpactWasGroundedLastTick = groundedNow;
            ImpactGroundTrackingInitialized = true;
        }

        // Mientras cae se conserva la última velocidad vertical descendente.
        if (!groundedNow && Vel.Z < 0.0)
        {
            LastImpactFallingVelocityZ = Vel.Z;
        }

        // El aterrizaje se detecta entre tics, no dentro del mismo Super.Tick.
        if (groundedNow
            && !ImpactWasGroundedLastTick
            && LastImpactFallingVelocityZ < 0.0)
        {
            double landingDeltaSpeed = Abs(LastImpactFallingVelocityZ);
            RegisterWorldImpact(
                landingDeltaSpeed,
                CaelumConstants.IMPACT_KIND_FLOOR
            );
            LastImpactFallingVelocityZ = 0.0;
        }
        ImpactWasGroundedLastTick = groundedNow;

        // Pared: sólo se dispara al comenzar el contacto. Mantener W contra la
        // misma pared no genera un impacto nuevo cada tic.
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

        // No rearmamos la estación mientras crafting siga abierto, aunque
        // PlayerThink haya limpiado temporalmente los botones. Tras cerrar,
        // una lectura real de Use liberado habilita la próxima pulsación.
        if (CraftingStationUseLatched
            && !CraftingMenuOpen
            && player != null
            && (player.cmd.buttons & BT_USE) == 0)
        {
            CraftingStationUseLatched = false;
        }

        // AltFire de jabalina es de una acción por pulsación. Soltar el botón
        // rearma el lanzamiento; mantenerlo no puede crear un bucle por tic.
        if (player != null && (player.cmd.buttons & BT_ALTATTACK) == 0)
        {
            JavelinSecondaryLatched = false;
        }

        // Zoom/ADS/Block se rearma solamente al soltar la tecla. El estado
        // nativo Zoom puede reenviar pulsos mientras se mantiene presionada.
        if (player != null && (player.cmd.buttons & BT_ZOOM) == 0)
        {
            CombatZoomInputLatched = false;
        }

        UpdateMovablePropUseInteraction();

        // La creación inicial pausa necesidades, regeneraciones y costes.
        if (CreationWizardOpen)
        {
            IsSpendingRunningAir = false;
            return;
        }

        RefreshEquipmentLoadIfNeeded();
        SyncHUDActiveWeaponState();

        if (ElementalStatus != null) { ElementalStatus.Tick(self); }
        IlluminationRemaining = Max(
            0.0, IlluminationRemaining - 1.0 / TICRATE
        );

        UpdateHealthStateEffects();

        IsSpendingRunningAir = IsRunningOnGround();
        UpdateCrouchEffects();
        UpdateMovementNoise();

        // El Anima se regenera de forma continua segun Paciencia.
        if (AnimaResourceInitialized
            && DerivedStats != null
            && CurrentAnima < DerivedStats.MaximumAnima)
        {
            CurrentAnima = Min(
                DerivedStats.MaximumAnima,
                CurrentAnima + DerivedStats.AnimaRegenerationPerSecond / TICRATE
            );
        }

        UpdateAdrenalineDecay();
        UpdateSealChannel();
        UpdateLucidityPhysicalStun();
        UpdatePainImmobilization();
        StaffCastCooldownRemaining = Max(
            0.0,
            StaffCastCooldownRemaining - 1.0 / TICRATE
        );
        if (StaffCastPending
            && (player == null || player.playerstate != PST_LIVE
                || health <= 0))
        {
            CancelPendingStaffCast(false);
        }
        if (StaffCastPending && StaffCastCooldownRemaining <= 0.0)
        {
            CompletePendingStaffCast();
        }
        EquippedWeaponCooldownRemaining = Max(
            0.0,
            EquippedWeaponCooldownRemaining - 1.0 / TICRATE
        );
        Inventory currentCarbineAmmo = FindInventory("CaelumCarbineAmmo");
        CarbineAmmoCount = currentCarbineAmmo != null
            ? currentCarbineAmmo.Amount : 0;

        if (LucidityResourceInitialized
            && CurrentLucidity < CaelumConstants.MAXIMUM_LUCIDITY)
        {
            CurrentLucidity = Min(
                CaelumConstants.MAXIMUM_LUCIDITY,
                CurrentLucidity
                    + CaelumConstants.MAXIMUM_LUCIDITY
                    / CaelumConstants.LUCIDITY_FULL_RECOVERY_SECONDS
                    / TICRATE
            );
            UpdateLucidityState();
        }


        UpdateSurvivalResources();
        ApplyCriticalSurvivalDamage();
        ApplyNaturalHealthRegeneration();

        UpdateCombatBlockMode();
        UpdateRangedReload();
        UpdateWeaponCharge();
        ApplyAirRegeneration();

        UpdateAirStateEffects();
        UpdateMovementAcceleration();
        ApplyPhysicalMovement();
        DetectAndChargePhysicalJump();
        ConsumeRunningAir();
        ConsumeShieldBlockingAir();
        HUDAbilitySuccessRemaining = Max(
            0.0, HUDAbilitySuccessRemaining - 1.0 / TICRATE
        );
    }

    // GZDoom exposes the effective run state through BT_RUN after combining
    // the physical speed key with the player's Always Run option. Requiring
    // directional input and ground contact keeps all non-running states free.
    bool IsRunningOnGround()
    {
        if (player == null
            || player.playerstate != PST_LIVE
            || !player.onground
            || IsPhysicallyImmobilized())
        {
            return false;
        }

        bool hasMovementInput = player.cmd.forwardmove != 0
            || player.cmd.sidemove != 0;
        bool runIsActive = (player.cmd.buttons & BT_RUN) != 0;

        return hasMovementInput && runIsActive;
    }

    void UpdateCrouchEffects()
    {
        IsCrouching = player != null && player.crouchfactor < 0.99;
        CrouchAccuracyMultiplier = IsCrouching
            ? CaelumConstants.CROUCH_ACCURACY_MULTIPLIER
            : 1.0;
        CrouchCriticalChanceMultiplier = IsCrouching
            ? CaelumConstants.CROUCH_CRITICAL_CHANCE_MULTIPLIER
            : 1.0;
        CrouchStealthMultiplier = IsCrouching
            ? CaelumConstants.CROUCH_STEALTH_MULTIPLIER
            : 1.0;

        EffectiveStealthPercent = 0.0;
        if (DerivedStats != null)
        {
            EffectiveStealthPercent = Clamp(
                DerivedStats.StealthPercent * CrouchStealthMultiplier,
                0.0,
                100.0
            );
        }
        MovementNoiseMultiplier = Clamp(
            1.0 - EffectiveStealthPercent / 100.0,
            0.0,
            1.0
        );
    }

    void UpdateMovementNoise()
    {
        LastMovementNoiseRange = 0.0;

        if (player == null
            || player.playerstate != PST_LIVE
            || !player.onground
            || IsPhysicallyImmobilized())
        {
            MovementNoiseTimer = 0.0;
            return;
        }

        bool hasMovementInput = player.cmd.forwardmove != 0
            || player.cmd.sidemove != 0;
        if (!hasMovementInput)
        {
            MovementNoiseTimer = 0.0;
            return;
        }

        MovementNoiseTimer += 1.0 / TICRATE;
        if (MovementNoiseTimer
            < CaelumConstants.MOVEMENT_NOISE_INTERVAL_SECONDS)
        {
            return;
        }
        MovementNoiseTimer = 0.0;

        // 100% de Sigilo = ningún ruido de movimiento.
        if (MovementNoiseMultiplier <= 0.0)
        {
            return;
        }

        double movementMultiplier = 1.0;
        if (IsCrouching)
        {
            movementMultiplier =
                CaelumConstants.MOVEMENT_NOISE_CROUCH_MULTIPLIER;
        }
        else if (IsRunningOnGround())
        {
            movementMultiplier =
                CaelumConstants.MOVEMENT_NOISE_RUN_MULTIPLIER;
        }

        LastMovementNoiseRange =
            CaelumConstants.MOVEMENT_NOISE_BASE_RANGE_MU
            * movementMultiplier
            * MovementNoiseMultiplier;

        if (LastMovementNoiseRange > 0.0)
        {
            SoundAlert(self, false, LastMovementNoiseRange);
        }
    }

    void SpawnDebugTrainingDummy()
    {
        if (player == null || player.playerstate != PST_LIVE) { return; }
        Vector3 spawnPos = Pos + (
            Cos(Angle) * 128.0,
            Sin(Angle) * 128.0,
            0.0
        );
        Actor dummy = Spawn("CaelumTrainingDummy", spawnPos, NO_REPLACE);
        if (dummy != null)
        {
            dummy.Angle = Angle + 180.0;
            if (!dummy.TestMobjLocation()) { dummy.Destroy(); }
        }
    }

    void SpawnDebugArgento()
    {
        if (player == null || player.playerstate != PST_LIVE) { return; }
        Vector3 spawnPos = Pos + (
            Cos(Angle) * 192.0,
            Sin(Angle) * 192.0,
            0.0
        );
        Actor argento = Spawn("CaelumArgento", spawnPos, NO_REPLACE);
        if (argento != null)
        {
            argento.Angle = Angle + 180.0;
            if (!argento.TestMobjLocation()) { argento.Destroy(); }
        }
    }

    void SpawnDebugCaella()
    {
        if (player == null || player.playerstate != PST_LIVE) { return; }
        Vector3 spawnPos = Pos + (
            Cos(Angle) * 192.0,
            Sin(Angle) * 192.0,
            0.0
        );
        Actor caella = Spawn("CaelumCaella", spawnPos, NO_REPLACE);
        if (caella != null)
        {
            caella.Angle = Angle + 180.0;
            if (!caella.TestMobjLocation()) { caella.Destroy(); }
        }
    }

    void SpawnDebugRulo()
    {
        if (player == null || player.playerstate != PST_LIVE) { return; }
        Vector3 spawnPos = Pos + (
            Cos(Angle) * 224.0,
            Sin(Angle) * 224.0,
            0.0
        );
        Actor rulo = Spawn("CaelumRulo", spawnPos, NO_REPLACE);
        if (rulo != null)
        {
            rulo.Angle = Angle + 180.0;
            if (!rulo.TestMobjLocation()) { rulo.Destroy(); }
        }
    }

    void SpawnDebugRonnie()
    {
        if (player == null || player.playerstate != PST_LIVE) { return; }
        Vector3 spawnPos = Pos + (
            Cos(Angle) * 192.0,
            Sin(Angle) * 192.0,
            0.0
        );
        Actor ronnie = Spawn("CaelumRonnie", spawnPos, NO_REPLACE);
        if (ronnie != null)
        {
            ronnie.Angle = Angle + 180.0;
            if (!ronnie.TestMobjLocation()) { ronnie.Destroy(); }
        }
    }

    // Functional straight-line staff test. Its trace distance and temporary
    // puff are presentation scaffolding; documented damage, Anima, timing,
    // Intelligence, Insight, critical, and status multipliers are live.
    double GetEquippedWeaponDamageScale(int weaponType)
    {
        if (WeaponModel == null || !WeaponModel.Equipped
            || WeaponModel.WeaponType != weaponType)
        {
            return 1.0;
        }
        double tierOneDamage = WeaponModel.GetTierOneDamageFor(weaponType);
        if (tierOneDamage <= 0.0) { return 1.0; }
        return WeaponModel.GetDamage() / tierOneDamage;
    }

    // Fire se enruta por el objeto realmente equipado en la mano habil.
    void PerformEquippedWeaponPrimaryAttack()
    {
        if (WeaponModel == null || !WeaponModel.Equipped
            || WeaponModel.Durability <= 0
            || EquipmentMenuOpen || CreationWizardOpen
            || EquippedWeaponCooldownRemaining > 0.0
            || IsPhysicallyImmobilized())
        {
            return;
        }

        if (WeaponChargeActive) { return; }

        int catalogueWeapon =
            CaelumCraftingRules.GetCatalogueWeaponForPlayableType(
                WeaponModel.WeaponType
            );

        // Fire rompe Block y continúa con el ataque en la misma pulsación.
        if (CombatBlockModeActive)
        {
            CancelCombatBlockMode();
        }

        if (catalogueWeapon >= 0
            && CaelumWeaponCatalogue.GetFamily(catalogueWeapon)
                == CaelumConstants.CATALOGUE_FAMILY_RANGED)
        {
            PerformCarbineAttack();
            return;
        }
        switch (WeaponModel.WeaponType)
        {
            case CaelumConstants.WEAPON_TYPE_STAFF:
            case CaelumConstants.WEAPON_TYPE_BELL:
            case CaelumConstants.WEAPON_TYPE_BOOK:
            case CaelumConstants.WEAPON_TYPE_STATUETTE:
                PerformDebugStaffAttack(false);
                break;
            default:
                PerformDebugSwordAttack(false);
                if (LastMeleeHadEnoughAir)
                {
                    EquippedWeaponCooldownRemaining =
                        WeaponModel.GetAttackTics() / double(TICRATE);
                }
                break;
        }
    }

    // AltFire pertenece exclusivamente al arma activa. El escudo ya no
    // intercepta este input: Block usa el estado nativo Zoom de forma
    // independiente.
    void PerformEquippedWeaponSecondaryAttack()
    {
        if (WeaponModel == null || !WeaponModel.Equipped
            || WeaponModel.Durability <= 0
            || EquipmentMenuOpen || CreationWizardOpen
            || IsPhysicallyImmobilized()
            || StaffCastPending)
        {
            return;
        }

        if (WeaponChargeActive) { return; }

        int catalogueWeapon =
            CaelumCraftingRules.GetCatalogueWeaponForPlayableType(
                WeaponModel.WeaponType
            );

        if (IsRangedWeaponType(WeaponModel.WeaponType))
        {
            ToggleRangedAim(WeaponModel.WeaponType);
            return;
        }

        if (CombatBlockModeActive)
        {
            CancelCombatBlockMode();
        }

        if (catalogueWeapon == CaelumConstants.CATALOGUE_WEAPON_JAVELIN)
        {
            if (JavelinSecondaryLatched) { return; }
            JavelinSecondaryLatched = true;
        }

        if (EquippedWeaponCooldownRemaining > 0.0
            || StaffCastCooldownRemaining > 0.0)
        {
            return;
        }

        if (WeaponModel.IsMagicalType(WeaponModel.WeaponType))
        {
            PerformDebugStaffAttack(true);
            return;
        }

        if (catalogueWeapon == CaelumConstants.CATALOGUE_WEAPON_JAVELIN
            && !HasJavelinMeleeFallbackTarget())
        {
            PerformJavelinThrow();
            return;
        }

        if (catalogueWeapon >= 0
            && CaelumWeaponCatalogue.GetSecondaryDamage(catalogueWeapon) > 0.0)
        {
            PerformDebugSwordAttack(true);
            if (LastMeleeHadEnoughAir)
            {
                EquippedWeaponCooldownRemaining =
                    WeaponModel.GetAttackTics() / double(TICRATE);
            }
        }
    }

    // Reutiliza exactamente la curva de desgaste de armaduras: por cada
    // 1000 puntos elegibles se pierde 1 de durabilidad garantizado y el
    // remanente aporta 1% de probabilidad por cada 10 puntos. En la jabalina
    // esta misma función se ejecuta al arrojarla, no al recoger munición.
    // Aplica una pérdida fija de durabilidad cuando la regla de diseño no
    // depende del daño. La jabalina arrojada usa esta ruta: cada lanzamiento
    // consume exactamente un punto, mientras sus golpes melee conservan la
    // curva normal basada en daño.
    void ApplyFixedWeaponDurabilityLoss(
        int durabilityLoss,
        int weaponType,
        int tier,
        int equipmentSize
    )
    {
        LastWeaponDurabilityLoss = 0;
        LastWeaponDurabilityChancePercent = 0.0;
        LastWeaponDurabilityRollPercent = 0.0;

        int requestedLoss = Max(0, durabilityLoss);
        if (requestedLoss <= 0) { return; }

        CaelumEquipmentItem weapon;
        if (WeaponModel != null
            && WeaponModel.IsMagicalType(weaponType))
        {
            weapon = FindNativeMagicWeaponItem(
                weaponType,
                WeaponModel.EssenceType,
                tier,
                equipmentSize
            );
        }
        else
        {
            weapon = FindNativeEquipmentItem(
                CaelumConstants.EQUIPMENT_KIND_WEAPON,
                weaponType, -1, tier, equipmentSize
            );
        }
        if (weapon == null || weapon.Durability <= 0 || weapon.InMagicBox)
        {
            return;
        }

        LastWeaponDurabilityLoss = Min(requestedLoss, weapon.Durability);
        weapon.Durability -= LastWeaponDurabilityLoss;

        bool isActiveWeapon = WeaponModel != null
            && WeaponModel.Equipped
            && WeaponModel.WeaponType == weaponType
            && WeaponModel.Tier == tier
            && WeaponModel.Size == equipmentSize;
        if (isActiveWeapon)
        {
            WeaponModel.Durability = weapon.Durability;
            if (WeaponModel.Durability <= 0)
            {
                EquippedWeaponCooldownRemaining = 0.0;
                StaffCastCooldownRemaining = 0.0;
                CancelPendingStaffCast(false);
                LastEquipmentAction = CaelumConstants.EQUIPMENT_ACTION_BROKEN;
            }
        }

        CaelumPersistentCharacterState persistentState =
            GetPersistentCharacterState(false);
        if (persistentState != null)
        {
            persistentState.StoreOwnedWeaponDurability(
                weaponType, tier, equipmentSize, weapon.Durability
            );
        }
        RefreshEquipmentSelectionPreview();
    }

    void ApplyWeaponDurabilityFromSuccessfulDamage(
        double dealtDamage,
        int weaponType,
        int tier,
        int equipmentSize
    )
    {
        LastWeaponDurabilityLoss = 0;
        LastWeaponDurabilityChancePercent = 0.0;
        LastWeaponDurabilityRollPercent = 0.0;

        if (dealtDamage <= 0.0)
        {
            return;
        }

        CaelumEquipmentItem weapon;
        if (WeaponModel != null
            && WeaponModel.IsMagicalType(weaponType))
        {
            weapon = FindNativeMagicWeaponItem(
                weaponType,
                WeaponModel.EssenceType,
                tier,
                equipmentSize
            );
        }
        else
        {
            weapon = FindNativeEquipmentItem(
                CaelumConstants.EQUIPMENT_KIND_WEAPON,
                weaponType, -1, tier, equipmentSize
            );
        }
        if (weapon == null || weapon.Durability <= 0 || weapon.InMagicBox)
        {
            return;
        }

        double eligibleDamage = dealtDamage
            * Max(0.0, ArmorDurabilityDamageMultiplier);
        LastWeaponDurabilityLoss = int(
            eligibleDamage
                / CaelumConstants.ARMOR_ABSORBED_DAMAGE_PER_GUARANTEED_DURABILITY
        );
        double remainder = eligibleDamage
            - LastWeaponDurabilityLoss
                * CaelumConstants.ARMOR_ABSORBED_DAMAGE_PER_GUARANTEED_DURABILITY;
        LastWeaponDurabilityChancePercent = Clamp(
            remainder / CaelumConstants.ARMOR_DAMAGE_PER_DURABILITY_CHANCE_PERCENT,
            0.0,
            100.0
        );
        int roll = Random[CaelumWeaponDurability](0, 999999);
        LastWeaponDurabilityRollPercent = roll / 10000.0;
        if (LastWeaponDurabilityRollPercent < LastWeaponDurabilityChancePercent)
        {
            LastWeaponDurabilityLoss++;
        }

        LastWeaponDurabilityLoss = Min(
            LastWeaponDurabilityLoss,
            weapon.Durability
        );
        if (LastWeaponDurabilityLoss <= 0) { return; }

        weapon.Durability -= LastWeaponDurabilityLoss;

        bool isActiveWeapon = WeaponModel != null
            && WeaponModel.Equipped
            && WeaponModel.WeaponType == weaponType
            && WeaponModel.Tier == tier
            && WeaponModel.Size == equipmentSize;
        if (isActiveWeapon)
        {
            WeaponModel.Durability = weapon.Durability;
            if (WeaponModel.Durability <= 0)
            {
                EquippedWeaponCooldownRemaining = 0.0;
                StaffCastCooldownRemaining = 0.0;
                CancelPendingStaffCast(false);
                LastEquipmentAction = CaelumConstants.EQUIPMENT_ACTION_BROKEN;
            }
        }

        CaelumPersistentCharacterState persistentState =
            GetPersistentCharacterState(false);
        if (persistentState != null)
        {
            persistentState.StoreOwnedWeaponDurability(
                weaponType, tier, equipmentSize, weapon.Durability
            );
        }
        RefreshEquipmentSelectionPreview();
    }

    bool HasJavelinMeleeFallbackTarget()
    {
        FTranslatedLineTarget targetData;
        Actor detectionPuff;
        int ignoredDamage;
        [detectionPuff, ignoredDamage] = LineAttack(
            Angle,
            CaelumWeaponCatalogue.GetPrimaryRange(
                CaelumConstants.CATALOGUE_WEAPON_JAVELIN
            ),
            Pitch,
            0,
            'CaelumMeleeTest',
            'CaelumSilentDetectionPuff',
            LAF_ISMELEEATTACK | LAF_NOINTERACT | LAF_NORANDOMPUFFZ,
            targetData
        );
        return targetData.linetarget != null;
    }

    void PerformJavelinThrow()
    {
        if (WeaponModel == null || !WeaponModel.Equipped
            || WeaponModel.WeaponType != CaelumConstants.WEAPON_TYPE_JAVELIN
            || WeaponModel.Durability <= 0 || DerivedStats == null)
        {
            return;
        }

        int catalogueWeapon = CaelumConstants.CATALOGUE_WEAPON_JAVELIN;
        double airCost = CaelumWeaponCatalogue.GetSecondaryAirCost(
            catalogueWeapon
        ) * DerivedStats.AirConsumptionMultiplier;
        bool chargedAttack = WeaponChargedStateActive;
        if (chargedAttack)
        {
            airCost *= CaelumConstants.WEAPON_CHARGED_COST_MULTIPLIER;
        }
        if (CurrentAir < airCost) { return; }

        UpdateLucidityAccuracyEffects();
        UpdateCrouchEffects();
        double movementAccuracyMultiplier = IsCrouching
            ? CrouchAccuracyMultiplier
            : (IsRunningOnGround()
                ? CaelumConstants.RUNNING_ACCURACY_MULTIPLIER
                : 1.0);
        double accuracyPercent = Max(
            1.0,
            EffectivePhysicalAccuracyPercent * movementAccuracyMultiplier
        );
        double minimumSpread = CaelumWeaponCatalogue.GetMinimumSpread(
            catalogueWeapon
        ) * 100.0 / accuracyPercent;
        double maximumSpread = CaelumWeaponCatalogue.GetMaximumSpread(
            catalogueWeapon
        ) * 100.0 / accuracyPercent;
        double spreadRoll = Random[CaelumJavelinSpread](0, 100000)
            / 100000.0;
        double spreadMagnitude = minimumSpread
            + (maximumSpread - minimumSpread) * spreadRoll;
        double yawOffset = Random[CaelumJavelinYaw](-100000, 100000)
            / 100000.0 * spreadMagnitude;
        double pitchOffset = Random[CaelumJavelinPitch](-100000, 100000)
            / 100000.0 * spreadMagnitude;

        double criticalBonus = Max(
            0.0,
            DerivedStats.PhysicalCriticalChance
                - CaelumConstants.BASE_CRITICAL_CHANCE_PERCENT
        );
        double criticalChance = Clamp(
            (CaelumWeaponCatalogue.GetCriticalChancePercent(catalogueWeapon)
                + criticalBonus) * CrouchCriticalChanceMultiplier,
            0.0,
            100.0
        );
        int criticalRoll = Random[CaelumJavelinCritical](0, 999999);
        bool criticalHit = criticalRoll / 10000.0 < criticalChance;
        double selectedBaseDamage = CaelumWeaponCatalogue.GetSecondaryDamage(
            catalogueWeapon
        );
        double physicalWeaponDamageScale = selectedBaseDamage
            * WeaponModel.GetTierDamageMultiplierFor(WeaponModel.Tier)
            / CaelumConstants.DEBUG_SWORD_BASE_DAMAGE;
        double damage = DerivedStats.DebugSwordDamage
            * physicalWeaponDamageScale
            * EffectiveOffensiveDamageMultiplier;
        if (chargedAttack)
        {
            damage *= CaelumConstants.WEAPON_CHARGED_DAMAGE_MULTIPLIER;
        }

        double attackAngle = Angle + yawOffset;
        double attackPitch = Pitch + pitchOffset;
        Vector3 spawnPos = Pos + (
            Cos(attackAngle) * 32.0,
            Sin(attackAngle) * 32.0,
            Height * 0.65
        );
        CaelumJavelinProjectile projectile = CaelumJavelinProjectile(
            Spawn(
                "CaelumJavelinProjectile",
                spawnPos,
                NO_REPLACE
            )
        );
        if (projectile == null) { return; }
        if (chargedAttack) { ConsumeWeaponChargedState(); }

        projectile.Target = self;
        projectile.Angle = attackAngle;
        projectile.Pitch = attackPitch;
        // La distancia útil del lanzamiento usa la raíz cuadrada de la
        // potencia física. Así conserva el beneficio de Fuerza y masa corporal
        // sin producir alcances absurdos cuando el multiplicador es muy alto.
        double throwPowerScale = Sqrt(
            Max(0.0, DerivedStats.PhysicalPushMultiplier)
        );
        double projectileSpeed = CaelumConstants.PROJECTILE_SPEED_SLOW
            * throwPowerScale;
        projectile.Vel = (
            Cos(attackPitch) * Cos(attackAngle) * projectileSpeed,
            Cos(attackPitch) * Sin(attackAngle) * projectileSpeed,
            -Sin(attackPitch) * projectileSpeed
        );
        projectile.StoreCaelumAttackResult(
            Max(1, int(damage + 0.5)),
            true,
            criticalHit,
            false,
            DerivedStats.PhysicalPushMultiplier
        );
        // Cada lanzamiento representa exactamente un punto de durabilidad.
        // Los materiales recuperados por este proyectil corresponden a la
        // mitad del valor material de ESE punto concreto de durabilidad.
        int maximumDurability = WeaponModel.GetMaximumDurabilityFor(
            WeaponModel.WeaponType, WeaponModel.Tier, WeaponModel.Size
        );
        int durabilityBeforeThrow = Clamp(
            WeaponModel.Durability, 0, maximumDurability
        );
        int durabilityAfterThrow = Max(0, durabilityBeforeThrow - 1);
        double finalWeight = CaelumCraftingRules.GetCraftedWeaponWeight(
            CaelumConstants.WEAPON_JAVELIN_TIER_ONE_WEIGHT,
            WeaponModel.Tier,
            WeaponModel.Size
        );
        int requiredBasicUnits = CaelumCraftingRules.GetRequiredBasicMaterialUnits(
            catalogueWeapon, finalWeight
        );
        int requiredTierUnits = CaelumCraftingRules.GetRequiredTierMaterialUnits(
            catalogueWeapon, finalWeight
        );

        int usedBefore = maximumDurability - durabilityBeforeThrow;
        int usedAfter = maximumDurability - durabilityAfterThrow;
        double recoveryRatio = CaelumConstants.CRAFTING_DISMANTLE_RECOVERY_RATIO;
        int basicRecoveredBefore = int(Floor(
            requiredBasicUnits * recoveryRatio * usedBefore
                / Max(1, maximumDurability) + 0.0000001
        ));
        int basicRecoveredAfter = int(Floor(
            requiredBasicUnits * recoveryRatio * usedAfter
                / Max(1, maximumDurability) + 0.0000001
        ));
        int tierRecoveredBefore = int(Floor(
            requiredTierUnits * recoveryRatio * usedBefore
                / Max(1, maximumDurability) + 0.0000001
        ));
        int tierRecoveredAfter = int(Floor(
            requiredTierUnits * recoveryRatio * usedAfter
                / Max(1, maximumDurability) + 0.0000001
        ));

        projectile.StoreJavelinBreakageConfiguration(
            WeaponModel.Tier,
            WeaponModel.Size,
            Max(0, basicRecoveredAfter - basicRecoveredBefore),
            Max(0, tierRecoveredAfter - tierRecoveredBefore)
        );

        ApplyFixedWeaponDurabilityLoss(
            1,
            WeaponModel.WeaponType,
            WeaponModel.Tier,
            WeaponModel.Size
        );

        CurrentAir = Max(0.0, CurrentAir - airCost);
        UpdateAirStateEffects();
        EquippedWeaponCooldownRemaining = WeaponModel.GetAttackTics()
            / double(TICRATE);
        MarkCombatActivity();
        RefreshCarriedInventorySummary();
    }

    bool IsRangedWeaponType(int weaponType)
    {
        return weaponType == CaelumConstants.WEAPON_TYPE_STANDARD_BOW
            || weaponType == CaelumConstants.WEAPON_TYPE_LONGBOW
            || weaponType == CaelumConstants.WEAPON_TYPE_CROSSBOW
            || weaponType == CaelumConstants.WEAPON_TYPE_CARBINE;
    }

    int GetRangedMagazineCapacity(int weaponType)
    {
        if (weaponType == CaelumConstants.WEAPON_TYPE_CARBINE) { return 10; }
        if (weaponType == CaelumConstants.WEAPON_TYPE_CROSSBOW) { return 20; }
        if (weaponType == CaelumConstants.WEAPON_TYPE_STANDARD_BOW
            || weaponType == CaelumConstants.WEAPON_TYPE_LONGBOW)
        {
            return 50;
        }
        return 0;
    }

    int GetRangedMagazineCount(int weaponType)
    {
        if (weaponType == CaelumConstants.WEAPON_TYPE_STANDARD_BOW)
            return StandardBowMagazine;
        if (weaponType == CaelumConstants.WEAPON_TYPE_LONGBOW)
            return LongbowMagazine;
        if (weaponType == CaelumConstants.WEAPON_TYPE_CROSSBOW)
            return CrossbowMagazine;
        if (weaponType == CaelumConstants.WEAPON_TYPE_CARBINE)
            return CarbineMagazine;
        return 0;
    }

    void SetRangedMagazineCount(int weaponType, int amount)
    {
        int value = Clamp(amount, 0, GetRangedMagazineCapacity(weaponType));
        if (weaponType == CaelumConstants.WEAPON_TYPE_STANDARD_BOW)
            StandardBowMagazine = value;
        else if (weaponType == CaelumConstants.WEAPON_TYPE_LONGBOW)
            LongbowMagazine = value;
        else if (weaponType == CaelumConstants.WEAPON_TYPE_CROSSBOW)
            CrossbowMagazine = value;
        else if (weaponType == CaelumConstants.WEAPON_TYPE_CARBINE)
            CarbineMagazine = value;
    }

    int GetRangedAmmoType(int weaponType)
    {
        if (weaponType == CaelumConstants.WEAPON_TYPE_CARBINE)
            return CaelumConstants.AMMUNITION_CARBINE;
        if (weaponType == CaelumConstants.WEAPON_TYPE_CROSSBOW)
            return CaelumConstants.AMMUNITION_BOLT;
        return CaelumConstants.AMMUNITION_ARROW;
    }

    double GetRangedBaseReloadSeconds(int weaponType)
    {
        if (weaponType == CaelumConstants.WEAPON_TYPE_CARBINE) { return 5.0; }
        if (weaponType == CaelumConstants.WEAPON_TYPE_CROSSBOW) { return 5.0; }
        if (weaponType == CaelumConstants.WEAPON_TYPE_STANDARD_BOW
            || weaponType == CaelumConstants.WEAPON_TYPE_LONGBOW)
        {
            return 3.0;
        }
        return 0.0;
    }

    double GetRangedEffectiveReloadSeconds(int weaponType)
    {
        if (DerivedStats == null || Attributes == null) { return 0.0; }

        // Se calcula desde la Destreza efectiva actual al iniciar Reload.
        // Evita reutilizar una instantanea anterior del multiplicador y
        // conserva la regla acordada: base / modificador Tipo 4.
        double attackSpeedPercent =
            DerivedStats.CalculateType4Percent(Attributes.Dexterity);
        return GetRangedBaseReloadSeconds(weaponType)
            * 100.0 / Max(1.0, attackSpeedPercent);
    }

    double GetRangedTierCriticalMultiplier(int tier)
    {
        if (tier <= 1) { return 1.0; }
        if (tier == 2) { return 1.60; }
        return 2.50;
    }

    void CancelRangedAim()
    {
        RangedAimModeActive = false;
    }

    void ToggleRangedAim(int requestedWeaponType)
    {
        if (!IsRangedWeaponType(requestedWeaponType)
            || WeaponModel == null || !WeaponModel.Equipped
            || WeaponModel.WeaponType != requestedWeaponType
            || RangedReloadActive || CombatBlockModeActive)
        {
            RangedAimModeActive = false;
            return;
        }
        RangedAimModeActive = !RangedAimModeActive;
    }

    void CancelRangedReload()
    {
        RangedReloadActive = false;
        RangedReloadRemainingSeconds = 0.0;
        RangedReloadTotalSeconds = 0.0;
    }

    bool HasReloadMovementInput()
    {
        return player != null
            && (player.cmd.forwardmove != 0 || player.cmd.sidemove != 0);
    }

    double GetReloadProgressMultiplier()
    {
        return HasReloadMovementInput()
            ? CaelumConstants.RELOAD_MOVEMENT_AND_PROGRESS_MULTIPLIER : 1.0;
    }

    bool IsReloadOrChargeActive()
    {
        return RangedReloadActive || WeaponChargeActive;
    }

    void CancelWeaponCharge()
    {
        WeaponChargeActive = false;
        WeaponChargedStateActive = false;
        WeaponChargeRemainingSeconds = 0.0;
        WeaponChargeTotalSeconds = 0.0;
        WeaponChargedRemainingSeconds = 0.0;
    }

    bool ConsumeWeaponChargedState()
    {
        if (!WeaponChargedStateActive) { return false; }
        WeaponChargedStateActive = false;
        WeaponChargedRemainingSeconds = 0.0;
        return true;
    }

    void RequestWeaponReloadOrCharge(int requestedWeaponType, bool isMagic)
    {
        if (IsRangedWeaponType(requestedWeaponType))
        {
            RequestRangedReload(requestedWeaponType);
            return;
        }
        if (WeaponModel == null || !WeaponModel.Equipped
            || WeaponModel.WeaponType != requestedWeaponType
            || DerivedStats == null || CombatBlockModeActive
            || StaffCastPending || IsPhysicallyImmobilized())
        {
            return;
        }

        CancelRangedAim();
        WeaponChargeIsMagic = isMagic;
        WeaponChargeWeaponType = WeaponModel.WeaponType;
        WeaponChargeWeaponTier = WeaponModel.Tier;
        WeaponChargeWeaponSize = WeaponModel.Size;
        WeaponChargeEssenceType = WeaponModel.EssenceType;
        WeaponChargeTotalSeconds = CaelumConstants.WEAPON_CHARGE_BASE_SECONDS
            * (isMagic ? DerivedStats.CastingDurationMultiplier
                : DerivedStats.AttackDurationMultiplier);
        WeaponChargeRemainingSeconds = WeaponChargeTotalSeconds;
        WeaponChargeActive = WeaponChargeRemainingSeconds > 0.0;
        WeaponChargedStateActive = false;
        WeaponChargedRemainingSeconds = 0.0;
    }

    bool DoesWeaponChargeMatchEquippedWeapon()
    {
        return WeaponModel != null && WeaponModel.Equipped
            && WeaponModel.WeaponType == WeaponChargeWeaponType
            && WeaponModel.Tier == WeaponChargeWeaponTier
            && WeaponModel.Size == WeaponChargeWeaponSize
            && WeaponModel.EssenceType == WeaponChargeEssenceType;
    }

    void UpdateWeaponCharge()
    {
        if (WeaponChargeActive)
        {
            if (!DoesWeaponChargeMatchEquippedWeapon()
                || IsPhysicallyImmobilized() || CombatBlockModeActive)
            {
                CancelWeaponCharge();
                return;
            }
            WeaponChargeRemainingSeconds = Max(
                0.0,
                WeaponChargeRemainingSeconds
                    - GetReloadProgressMultiplier() / TICRATE
            );
            if (WeaponChargeRemainingSeconds <= 0.0)
            {
                WeaponChargeActive = false;
                WeaponChargedStateActive = true;
                WeaponChargedRemainingSeconds =
                    CaelumConstants.WEAPON_CHARGED_STATE_SECONDS;
            }
        }
        else if (WeaponChargedStateActive)
        {
            if (!DoesWeaponChargeMatchEquippedWeapon())
            {
                CancelWeaponCharge();
                return;
            }
            WeaponChargedRemainingSeconds = Max(
                0.0, WeaponChargedRemainingSeconds - 1.0 / TICRATE
            );
            if (WeaponChargedRemainingSeconds <= 0.0)
            {
                CancelWeaponCharge();
            }
        }
    }

    void RequestRangedReload(int requestedWeaponType)
    {
        if (!IsRangedWeaponType(requestedWeaponType)
            || WeaponModel == null || !WeaponModel.Equipped
            || WeaponModel.WeaponType != requestedWeaponType
            || DerivedStats == null || CombatBlockModeActive)
        {
            return;
        }

        int ammoType = GetRangedAmmoType(requestedWeaponType);
        Inventory ammo = FindNativeAmmunition(ammoType);
        int available = ammo != null ? ammo.Amount : 0;
        int capacity = GetRangedMagazineCapacity(requestedWeaponType);
        int targetLoad = Min(capacity, available);
        if (targetLoad <= GetRangedMagazineCount(requestedWeaponType))
        {
            return;
        }

        CancelRangedAim();
        RangedReloadWeaponType = requestedWeaponType;
        RangedReloadTotalSeconds =
            GetRangedEffectiveReloadSeconds(requestedWeaponType);
        RangedReloadRemainingSeconds = RangedReloadTotalSeconds;
        RangedReloadActive = RangedReloadRemainingSeconds > 0.0;
    }

    void UpdateRangedReload()
    {
        if (!RangedReloadActive) { return; }

        if (WeaponModel == null || !WeaponModel.Equipped
            || WeaponModel.WeaponType != RangedReloadWeaponType
            || CombatBlockModeActive || IsPhysicallyImmobilized())
        {
            CancelRangedReload();
            return;
        }

        RangedReloadRemainingSeconds = Max(
            0.0,
            RangedReloadRemainingSeconds
                - GetReloadProgressMultiplier() / TICRATE
        );
        if (RangedReloadRemainingSeconds > 0.0) { return; }

        int ammoType = GetRangedAmmoType(RangedReloadWeaponType);
        Inventory ammo = FindNativeAmmunition(ammoType);
        int available = ammo != null ? ammo.Amount : 0;
        SetRangedMagazineCount(
            RangedReloadWeaponType,
            Min(GetRangedMagazineCapacity(RangedReloadWeaponType), available)
        );
        CancelRangedReload();
    }

    void PerformCarbineAttack()
    {
        LastCarbineFired = false;
        LastCarbineHadEnoughAir = false;
        LastCarbineHadAmmo = false;
        LastCarbineCriticalHit = false;
        LastCarbineDamage = 0.0;
        LastCarbineAccuracyPercent = 0.0;
        LastCarbineMinimumSpread = 0.0;
        LastCarbineMaximumSpread = 0.0;
        LastCarbineYawOffset = 0.0;
        LastCarbinePitchOffset = 0.0;
        LastAttackPushForce = 0.0;
        if (WeaponModel == null || !WeaponModel.Equipped
            || WeaponModel.Durability <= 0 || DerivedStats == null)
        {
            return;
        }
        int catalogueWeapon =
            CaelumCraftingRules.GetCatalogueWeaponForPlayableType(
                WeaponModel.WeaponType
            );
        if (catalogueWeapon < 0
            || CaelumWeaponCatalogue.GetFamily(catalogueWeapon)
                != CaelumConstants.CATALOGUE_FAMILY_RANGED)
        {
            return;
        }
        int requiredAmmoType = CaelumConstants.AMMUNITION_ARROW;
        if (WeaponModel.WeaponType == CaelumConstants.WEAPON_TYPE_CARBINE)
        {
            requiredAmmoType = CaelumConstants.AMMUNITION_CARBINE;
        }
        else if (WeaponModel.WeaponType == CaelumConstants.WEAPON_TYPE_CROSSBOW)
        {
            requiredAmmoType = CaelumConstants.AMMUNITION_BOLT;
        }
        Inventory rangedAmmo = FindNativeAmmunition(requiredAmmoType);
        // El cargador es la fuente inmediata del disparo. La reserva se usa
        // al recargar, pero no debe invalidar proyectiles ya cargados si la
        // pila cambia de ubicación o llega a cero después de la recarga.
        bool ammoAvailable =
            GetRangedMagazineCount(WeaponModel.WeaponType) > 0;
        LastCarbineHadAmmo = ammoAvailable;
        if (!LastCarbineHadAmmo)
        {
            if (rangedAmmo != null && rangedAmmo.Amount > 0)
            {
                RequestRangedReload(WeaponModel.WeaponType);
            }
            return;
        }
        if (RangedReloadActive) { return; }

        double airCost = CaelumWeaponCatalogue.GetPrimaryAirCost(
            catalogueWeapon
        )
            * DerivedStats.AirConsumptionMultiplier;
        LastCarbineHadEnoughAir = CurrentAir >= airCost;
        if (!LastCarbineHadEnoughAir) { return; }

        UpdateLucidityAccuracyEffects();
        UpdateCrouchEffects();
        double movementAccuracyMultiplier = IsCrouching
            ? CrouchAccuracyMultiplier
            : (IsRunningOnGround()
                ? CaelumConstants.RUNNING_ACCURACY_MULTIPLIER
                : 1.0);
        double aimAccuracyMultiplier = RangedAimModeActive ? 2.0 : 1.0;
        LastCarbineAccuracyPercent = Max(
            1.0,
            EffectivePhysicalAccuracyPercent
                * movementAccuracyMultiplier
                * aimAccuracyMultiplier
        );
        LastCarbineMinimumSpread = CaelumWeaponCatalogue.GetMinimumSpread(
            catalogueWeapon
        )
            * 100.0 / LastCarbineAccuracyPercent;
        LastCarbineMaximumSpread = CaelumWeaponCatalogue.GetMaximumSpread(
            catalogueWeapon
        )
            * 100.0 / LastCarbineAccuracyPercent;
        double spreadRoll = Random[CaelumCarbineSpread](0, 100000) / 100000.0;
        double spreadMagnitude = LastCarbineMinimumSpread
            + (LastCarbineMaximumSpread - LastCarbineMinimumSpread) * spreadRoll;
        LastCarbineYawOffset = Random[CaelumCarbineYaw](-100000, 100000)
            / 100000.0 * spreadMagnitude;
        LastCarbinePitchOffset = Random[CaelumCarbinePitch](-100000, 100000)
            / 100000.0 * spreadMagnitude;

        double criticalBonus = Max(
            0.0,
            DerivedStats.PhysicalCriticalChance
                - CaelumConstants.BASE_CRITICAL_CHANCE_PERCENT
        );
        double rangedBaseCritical =
            CaelumWeaponCatalogue.GetCriticalChancePercent(catalogueWeapon)
            * GetRangedTierCriticalMultiplier(WeaponModel.Tier);
        double criticalChance = Clamp(
            (rangedBaseCritical + criticalBonus)
                * CrouchCriticalChanceMultiplier,
            0.0,
            100.0
        );
        int criticalRoll = Random[CaelumCarbineCritical](0, 999999);
        LastCarbineCriticalHit = criticalRoll / 10000.0 < criticalChance;
        LastCarbineDamage = WeaponModel.GetDamage()
            * EffectiveOffensiveDamageMultiplier;

        double attackAngle = Angle + LastCarbineYawOffset;
        double attackPitch = Pitch + LastCarbinePitchOffset;
        Vector3 spawnPos = Pos + (
            Cos(attackAngle) * 32.0,
            Sin(attackAngle) * 32.0,
            Height * 0.65
        );
        Name projectileClass = "CaelumCarbineProjectile";
        if (requiredAmmoType == CaelumConstants.AMMUNITION_ARROW)
        {
            projectileClass = "CaelumArrowProjectile";
        }
        else if (requiredAmmoType == CaelumConstants.AMMUNITION_BOLT)
        {
            projectileClass = "CaelumBoltProjectile";
        }

        CaelumCarbineProjectile projectile = CaelumCarbineProjectile(
            Spawn(projectileClass, spawnPos, NO_REPLACE)
        );
        if (projectile == null) { return; }

        projectile.Target = self;
        projectile.Angle = attackAngle;
        projectile.Pitch = attackPitch;
        double rangedProjectileSpeed = WeaponModel.WeaponType
                == CaelumConstants.WEAPON_TYPE_CARBINE
            ? CaelumConstants.WEAPON_CARBINE_PROJECTILE_SPEED
            : CaelumConstants.PROJECTILE_SPEED_VERY_FAST;
        projectile.Vel = (
            Cos(attackPitch) * Cos(attackAngle)
                * rangedProjectileSpeed,
            Cos(attackPitch) * Sin(attackAngle)
                * rangedProjectileSpeed,
            -Sin(attackPitch) * rangedProjectileSpeed
        );
        projectile.StoreCaelumAttackResult(
            Max(1, int(LastCarbineDamage + 0.5)),
            true,
            LastCarbineCriticalHit,
            false,
            DerivedStats.PhysicalPushMultiplier
        );
        projectile.StoreCaelumWeaponWearIdentity(
            WeaponModel.WeaponType,
            WeaponModel.Tier,
            WeaponModel.Size
        );

        // La pila nativa representa el total físico restante y normalmente
        // acompaña al cargador. La comprobación nula preserva un cargador ya
        // cargado aunque la reserva haya cambiado de contenedor.
        if (rangedAmmo != null && rangedAmmo.Amount > 0)
        {
            rangedAmmo.Amount = Max(0, rangedAmmo.Amount - 1);
        }
        SetRangedMagazineCount(
            WeaponModel.WeaponType,
            GetRangedMagazineCount(WeaponModel.WeaponType) - 1
        );
        if (requiredAmmoType == CaelumConstants.AMMUNITION_CARBINE)
        {
            CarbineAmmoCount = CarbineMagazine;
        }
        CurrentAir = Max(0.0, CurrentAir - airCost);
        UpdateAirStateEffects();
        LastCarbineFired = true;
        EquippedWeaponCooldownRemaining = WeaponModel.GetAttackTics()
            / double(TICRATE);
        MarkCombatActivity();
    }

    void CancelPendingStaffCast(bool interrupted)
    {
        if (!StaffCastPending) { return; }
        StaffCastPending = false;
        StaffCastCooldownRemaining = 0.0;
        PendingStaffAnimaCost = 0.0;
        PendingStaffChargedAttack = false;
        if (interrupted)
        {
            LastStaffCastInterrupted = true;
            LastStaffCastCompleted = false;
        }
    }

    void TryInterruptPendingStaffCast(
        int actualHealthLost,
        double adrenalineRatioBeforeDamage
    )
    {
        if (!StaffCastPending || actualHealthLost <= 0
            || CaelumMaximumHealth <= 0 || DerivedStats == null)
        {
            return;
        }

        double lostHealthPercent = 100.0
            * actualHealthLost / CaelumMaximumHealth;
        double patienceResistance = Clamp(
            DerivedStats.InterruptionResistancePercent / 100.0,
            0.0,
            1.0
        );
        LastStaffInterruptionChancePercent = Clamp(
            10.0 * lostHealthPercent
                * DerivedStats.PainChanceMultiplier
                * HealthPainMultiplier
                * (1.0 - Clamp(adrenalineRatioBeforeDamage, 0.0, 1.0))
                * (1.0 - patienceResistance),
            0.0,
            100.0
        );
        int interruptionRoll = Random[CaelumSpellInterruption](0, 999999);
        LastStaffInterruptionRollPercent = interruptionRoll / 10000.0;
        if (LastStaffInterruptionRollPercent
            < LastStaffInterruptionChancePercent)
        {
            CancelPendingStaffCast(true);
        }
    }

    void CompletePendingStaffCast()
    {
        if (!StaffCastPending) { return; }
        bool secondaryAttack = PendingStaffSecondaryAttack;
        int activeMagicType = PendingStaffWeaponType;
        int activeEssenceType = PendingStaffEssenceType;
        double animaCost = PendingStaffAnimaCost;
        bool chargedAttack = PendingStaffChargedAttack;

        StaffCastPending = false;
        StaffCastCooldownRemaining = 0.0;
        PendingStaffAnimaCost = 0.0;
        PendingStaffChargedAttack = false;
        if (DerivedStats == null || WeaponModel == null
            || !WeaponModel.Equipped || WeaponModel.Durability <= 0
            || player == null || player.playerstate != PST_LIVE
            || WeaponModel.WeaponType != activeMagicType
            || WeaponModel.Tier != PendingStaffWeaponTier
            || WeaponModel.Size != PendingStaffWeaponSize)
        {
            return;
        }
        if (CurrentAnima < animaCost)
        {
            LastStaffInsufficientAnima = true;
            return;
        }

        CurrentAnima -= animaCost;
        ReleasePendingStaffAttack(
            secondaryAttack,
            activeMagicType,
            activeEssenceType,
            chargedAttack
        );
        LastStaffCastCompleted = true;
    }

    void PerformDebugStaffAttack(bool secondaryAttack)
    {
        LastStaffHit = false;
        LastStaffCriticalAttempted = false;
        LastStaffCriticalHit = false;
        LastStaffInsufficientAnima = false;
        LastStaffActualDamage = 0;
        LastStaffCriticalRollPercent = 0.0;
        LastStaffLocationMultiplier = 1.0;
        LastAttackPushForce = 0.0;
        LastStaffVulnerabilityGrade = CaelumConstants.VULNERABILITY_NEUTRAL_POINT;
        LastStaffCastInterrupted = false;
        LastStaffCastCompleted = false;
        LastStaffInterruptionChancePercent = 0.0;
        LastStaffInterruptionRollPercent = 0.0;
        if (DerivedStats == null
            || player == null
            || player.playerstate != PST_LIVE
            || IsPhysicallyImmobilized()
            || StaffCastPending
            || StaffCastCooldownRemaining > 0.0
            || CombatBlockModeActive
            || WeaponModel == null
            || !WeaponModel.Equipped
            || !WeaponModel.IsMagicalType(WeaponModel.WeaponType))
        {
            return;
        }

        int activeMagicType = WeaponModel.WeaponType;

        // El coste base estipulado corresponde a T1. T2 consume 160% y T3
        // 250%, antes de aplicar las reducciones/modificadores de Ánima ya
        // existentes en las estadísticas derivadas.
        double magicTierAnimaMultiplier = 1.0;
        if (WeaponModel.Tier == 2) { magicTierAnimaMultiplier = 1.60; }
        else if (WeaponModel.Tier >= 3) { magicTierAnimaMultiplier = 2.50; }

        double animaCost = WeaponModel.GetAnimaCostFor(activeMagicType)
            * magicTierAnimaMultiplier
            * DerivedStats.StaffAnimaCost
            / CaelumConstants.DEBUG_STAFF_ANIMA_COST;
        bool chargedAttack = WeaponChargedStateActive;
        if (chargedAttack)
        {
            animaCost *= CaelumConstants.WEAPON_CHARGED_COST_MULTIPLIER;
        }
        if (CurrentAnima < animaCost)
        {
            LastStaffInsufficientAnima = true;
            return;
        }

        StaffCastPending = true;
        PendingStaffSecondaryAttack = secondaryAttack;
        PendingStaffWeaponType = activeMagicType;
        PendingStaffWeaponTier = WeaponModel.Tier;
        PendingStaffWeaponSize = WeaponModel.Size;
        PendingStaffEssenceType = Clamp(
            WeaponModel.EssenceType,
            0,
            CaelumConstants.ESSENCE_TYPE_COUNT - 1
        );
        PendingStaffAnimaCost = animaCost;
        PendingStaffChargedAttack = chargedAttack;
        if (chargedAttack) { ConsumeWeaponChargedState(); }
        StaffCastCooldownRemaining = WeaponModel.GetAttackTics()
            * DerivedStats.CastingDurationMultiplier / double(TICRATE);
        PendingStaffCastTotalSeconds = StaffCastCooldownRemaining;
        MarkCombatActivity();
    }

    void ReleasePendingStaffAttack(
        bool secondaryAttack,
        int activeMagicType,
        int activeEssenceType,
        bool chargedAttack
    )
    {
        double magicDamageScale = WeaponModel.GetDamage()
            / CaelumConstants.DEBUG_STAFF_BASE_DAMAGE;
        UpdateLucidityAccuracyEffects();
        UpdateCrouchEffects();
        LastStaffAccuracyPercent = Max(
            1.0,
            EffectiveMagicalAccuracyPercent * CrouchAccuracyMultiplier
        );
        double maximumAimError = WeaponModel.GetMaximumSpreadFor(activeMagicType)
            * 100.0 / LastStaffAccuracyPercent;
        double minimumAimError = WeaponModel.GetMinimumSpreadFor(activeMagicType)
            * 100.0 / LastStaffAccuracyPercent;
        int staffYawRoll = Random[CaelumStaffAccuracyYaw](-100000, 100000);
        int staffPitchRoll = Random[CaelumStaffAccuracyPitch](-100000, 100000);
        LastStaffYawOffset = (staffYawRoll < 0 ? -1.0 : 1.0)
            * (minimumAimError + (maximumAimError - minimumAimError)
                * Abs(staffYawRoll) / 100000.0);
        LastStaffPitchOffset = (staffPitchRoll < 0 ? -1.0 : 1.0)
            * (minimumAimError + (maximumAimError - minimumAimError)
                * Abs(staffPitchRoll) / 100000.0);
        double attackAngle = Angle + LastStaffYawOffset;
        double attackPitch = Pitch + LastStaffPitchOffset;

        LastStaffCriticalAttempted = true;
        LastStaffCriticalChancePercent = Clamp(
            (WeaponModel.GetBaseCriticalChanceFor(activeMagicType)
                + Max(0.0, DerivedStats.MagicalCriticalChance
                    - CaelumConstants.BASE_CRITICAL_CHANCE_PERCENT))
                * CrouchCriticalChanceMultiplier,
            0.0,
            100.0
        );
        // La campana resuelve el critico por proyectil. Las demas armas
        // conservan una unica tirada por ataque.
        if (activeMagicType != CaelumConstants.WEAPON_TYPE_BELL)
        {
            int criticalRoll = Random[CaelumMagicalCritical](0, 999999);
            LastStaffCriticalRollPercent = criticalRoll / 10000.0;
            LastStaffCriticalHit = LastStaffCriticalRollPercent
                < LastStaffCriticalChancePercent;
        }
        LastStaffCalculatedDamage = DerivedStats.DebugStaffDamage
            * magicDamageScale
            * EffectiveOffensiveDamageMultiplier;
        if (chargedAttack)
        {
            LastStaffCalculatedDamage *=
                CaelumConstants.WEAPON_CHARGED_DAMAGE_MULTIPLIER;
        }
        int integerDamage = Max(1, int(LastStaffCalculatedDamage + 0.5));
        if (activeEssenceType == CaelumConstants.ESSENCE_QUINTESSENCE
            && !secondaryAttack)
        {
            integerDamage = Max(
                1,
                int(integerDamage
                    * CaelumConstants.QUINTESSENCE_PRIMARY_DAMAGE_MULTIPLIER
                    + 0.5)
            );
            LastStaffCalculatedDamage = integerDamage;
        }

        double elementalPushMultiplier = DerivedStats.MagicalPushMultiplier;
        if (!secondaryAttack
            && activeEssenceType == CaelumConstants.ESSENCE_WATER)
        {
            elementalPushMultiplier *=
                CaelumConstants.ELEMENTAL_EXTREME_PUSH_MULTIPLIER;
        }
        else if (!secondaryAttack
            && activeEssenceType == CaelumConstants.ESSENCE_WIND)
        {
            elementalPushMultiplier *=
                CaelumConstants.ELEMENTAL_MODERATE_PUSH_MULTIPLIER;
        }
        if (secondaryAttack
            && activeEssenceType == CaelumConstants.ESSENCE_FIRE)
        {
            IlluminationRemaining = Max(
                IlluminationRemaining,
                CaelumConstants.ELEMENTAL_BASE_DURATION_SECONDS
                    * DerivedStats.BuffPowerPercent / 100.0
            );
        }

        // El alcance real del hechizo tambien limita el guiado del libro.
        double spellRange = CaelumConstants.ESSENCE_BASE_RANGE_MAP_UNITS
            * DerivedStats.AbilityRangePercent / 100.0;

        int projectileCount = activeMagicType
            == CaelumConstants.WEAPON_TYPE_BELL
                ? CaelumConstants.WEAPON_BELL_PROJECTILE_COUNT : 1;
        for (int projectileIndex = 0;
            projectileIndex < projectileCount; projectileIndex++)
        {
            bool projectileCritical = LastStaffCriticalHit;
            if (activeMagicType == CaelumConstants.WEAPON_TYPE_BELL)
            {
                int bellCriticalRoll = Random[CaelumBellCritical](0, 999999);
                LastStaffCriticalRollPercent = bellCriticalRoll / 10000.0;
                projectileCritical = LastStaffCriticalRollPercent
                    < LastStaffCriticalChancePercent;
                LastStaffCriticalHit = LastStaffCriticalHit
                    || projectileCritical;
            }
            double projectileAngle = attackAngle;
            double projectilePitch = attackPitch;
            if (projectileCount > 1)
            {
                int coneYaw = Random[CaelumBellSpreadYaw](-100000, 100000);
                int conePitch = Random[CaelumBellSpreadPitch](-100000, 100000);
                projectileAngle = Angle + (coneYaw < 0 ? -1.0 : 1.0)
                    * (minimumAimError + (maximumAimError - minimumAimError)
                        * Abs(coneYaw) / 100000.0);
                projectilePitch = Pitch + (conePitch < 0 ? -1.0 : 1.0)
                    * (minimumAimError + (maximumAimError - minimumAimError)
                        * Abs(conePitch) / 100000.0);
            }
            Vector3 spawnPos = Pos + (
                Cos(projectileAngle) * 32.0,
                Sin(projectileAngle) * 32.0,
                Height * 0.65
            );
            CaelumPlayerMagicProjectile projectile;
            if (activeMagicType == CaelumConstants.WEAPON_TYPE_BOOK)
            {
                projectile = CaelumPlayerMagicProjectile(Spawn(
                    chargedAttack
                        ? "CaelumChargedHomingMagicProjectile"
                        : "CaelumHomingMagicProjectile",
                    spawnPos,
                    NO_REPLACE
                ));
            }
            else if (activeMagicType == CaelumConstants.WEAPON_TYPE_STATUETTE)
            {
                projectile = CaelumPlayerMagicProjectile(Spawn(
                    chargedAttack
                        ? "CaelumChargedExplosiveMagicProjectile"
                        : "CaelumExplosiveMagicProjectile",
                    spawnPos,
                    NO_REPLACE
                ));
            }
            else
            {
                projectile = CaelumPlayerMagicProjectile(Spawn(
                    chargedAttack
                        ? "CaelumChargedPlayerMagicProjectile"
                        : "CaelumPlayerMagicProjectile",
                    spawnPos,
                    NO_REPLACE
                ));
            }
            if (projectile == null) { continue; }
            projectile.Target = self;
            projectile.Angle = projectileAngle;
            projectile.Pitch = projectilePitch;
            double projectileSpeed = CaelumConstants.PROJECTILE_SPEED_NORMAL;
            if (activeMagicType == CaelumConstants.WEAPON_TYPE_BOOK)
            {
                projectileSpeed = CaelumConstants.PROJECTILE_SPEED_FAST;
            }
            else if (activeMagicType == CaelumConstants.WEAPON_TYPE_BELL)
            {
                projectileSpeed = CaelumConstants.PROJECTILE_SPEED_SLOW;
            }
            projectile.Vel = (
                Cos(projectilePitch) * Cos(projectileAngle)
                    * projectileSpeed,
                Cos(projectilePitch) * Sin(projectileAngle)
                    * projectileSpeed,
                -Sin(projectilePitch)
                    * projectileSpeed
            );
            projectile.StoreCaelumAttackResult(
                integerDamage, true, projectileCritical, true,
                elementalPushMultiplier
            );
        projectile.StoreCaelumWeaponWearIdentity(
            WeaponModel.WeaponType,
            WeaponModel.Tier,
            WeaponModel.Size
        );
            projectile.StoreCaelumElementalPayload(
                activeEssenceType,
                secondaryAttack,
                DerivedStats.DebuffPowerPercent,
                DerivedStats.BuffPowerPercent
            );
            projectile.UpdateCaelumElementalWorldSprite();
            if (activeMagicType == CaelumConstants.WEAPON_TYPE_BOOK)
            {
                CaelumHomingMagicProjectile homingProjectile =
                    CaelumHomingMagicProjectile(projectile);
                if (homingProjectile != null)
                {
                    // La adquisicion usa la mira original. La dispersion solo
                    // modifica la trayectoria inicial del proyectil.
                    homingProjectile.ConfigureCaelumSeeking(
                        spellRange,
                        Angle,
                        Pitch,
                        maximumAimError
                    );
                }
            }
            if (activeMagicType == CaelumConstants.WEAPON_TYPE_STATUETTE)
            {
                CaelumExplosiveMagicProjectile explosiveProjectile =
                    CaelumExplosiveMagicProjectile(projectile);
                if (explosiveProjectile != null)
                {
                    explosiveProjectile.ConfigureCaelumExplosion(
                        integerDamage,
                        CaelumConstants.ESSENCE_EXPLOSION_BASE_RADIUS
                            * DerivedStats.AbilityRangePercent / 100.0
                            * (chargedAttack
                                ? CaelumConstants.WEAPON_CHARGED_AREA_LINEAR_MULTIPLIER
                                : 1.0)
                    );
                }
            }
        }
        MarkCombatActivity();
    }

    // Convert the documented per-second running cost into a per-tic cost.
    // Regeneration pauses during these tics so the displayed rate is exact.
    void ConsumeRunningAir()
    {
        if (!IsSpendingRunningAir || DerivedStats == null)
        {
            return;
        }

        double finalCostPerSecond = CaelumConstants.RUN_AIR_COST_PER_SECOND
            * DerivedStats.AirConsumptionMultiplier;
        CurrentAir = Max(0.0, CurrentAir - finalCostPerSecond / TICRATE);
        UpdateAirStateEffects();
    }

    // Zoom funciona como interruptor real de Block. Una pulsación activa
    // el modo y otra lo cancela; el estado persiste hasta una cancelación
    // explícita o hasta que deje de cumplirse alguna condición válida.
    bool CanEnterCombatBlockMode()
    {
        return player != null
            && player.playerstate == PST_LIVE
            && !EquipmentMenuOpen
            && !CreationWizardOpen
            && !CraftingMenuOpen
            && !CombatChannelModeActive
            && !StaffCastPending
            && !IsPhysicallyImmobilized()
            && HasActiveBlockSource()
            && CurrentAir > 0.0;
    }

    bool IsGiantGauntletsBlockSource()
    {
        return WeaponModel != null
            && WeaponModel.Equipped
            && WeaponModel.WeaponType
                == CaelumConstants.WEAPON_TYPE_GIANT_GAUNTLETS
            && WeaponModel.Durability > 0;
    }

    bool HasActiveBlockSource()
    {
        if (IsGiantGauntletsBlockSource()) { return true; }
        return ShieldModel != null
            && ShieldModel.Equipped
            && ShieldModel.Durability > 0
            && CanUseShieldWithEquippedWeapon();
    }

    int GetActiveBlockCoverageDegrees()
    {
        if (IsGiantGauntletsBlockSource()) { return 120; }
        return ShieldModel != null ? ShieldModel.GetCoverageDegrees() : 0;
    }

    int GetActiveBlockDefense(int damageKind)
    {
        if (!IsGiantGauntletsBlockSource())
        {
            return ShieldModel != null ? ShieldModel.GetDefense(damageKind) : 0;
        }
        // Los guanteletes usan exactamente la defensa de una rodela del mismo
        // tier: 50/60/70 para daño físico o mágico.
        return 60 + (Clamp(WeaponModel.Tier, 1, 3) - 2) * 10;
    }

    double GetActiveBlockWeight()
    {
        if (!IsGiantGauntletsBlockSource())
        {
            return ShieldModel != null ? ShieldModel.GetWeight() : 0.0;
        }
        return ShieldModel != null ? ShieldModel.GetWeightFor(
            CaelumConstants.SHIELD_TYPE_BUCKLER,
            WeaponModel.Tier,
            WeaponModel.Size
        ) : 0.0;
    }

    bool CanUseShieldWithEquippedWeapon()
    {
        if (WeaponModel == null || !WeaponModel.Equipped) { return true; }
        if (IsRangedWeaponType(WeaponModel.WeaponType)) { return false; }

        int catalogueWeapon =
            CaelumCraftingRules.GetCatalogueWeaponForPlayableType(
                WeaponModel.WeaponType
            );
        if (catalogueWeapon < 0)
        {
            // Las armas de esencia conservan sus reglas de escudo actuales.
            return true;
        }
        return CaelumWeaponCatalogue.UsesOneHandedShieldRules(catalogueWeapon);
    }

    int GetEquippedRangedReserveCount()
    {
        if (WeaponModel == null || !WeaponModel.Equipped
            || !IsRangedWeaponType(WeaponModel.WeaponType))
        {
            return 0;
        }
        Inventory ammo = FindNativeAmmunition(
            GetRangedAmmoType(WeaponModel.WeaponType)
        );
        if (ammo == null) { return 0; }
        return Max(
            0,
            ammo.Amount - GetRangedMagazineCount(WeaponModel.WeaponType)
        );
    }

    void ToggleCombatBlockMode()
    {
        if (CombatBlockModeActive)
        {
            CancelCombatBlockMode();
            return;
        }

        if (!CanEnterCombatBlockMode())
        {
            CancelCombatBlockMode();
            return;
        }

        CancelRangedAim();
        CancelRangedReload();
        CombatBlockInputGraceTics = 0;
        CombatBlockModeActive = true;
        DebugShieldBlocking = true;
        if (WeaponChargedStateActive)
        {
            ConsumeWeaponChargedState();
            PerformChargedBlockDash();
        }
        bool magicReflect = !IsGiantGauntletsBlockSource()
            && ShieldModel != null
            && ShieldModel.ShieldType == CaelumConstants.SHIELD_TYPE_MAGIC;
        bREFLECTIVE = magicReflect;
        bSHIELDREFLECT = magicReflect;
        UpdateShieldAirCost();
    }

    // Al iniciar Block con una carga preparada, impulsa al personaje hacia
    // donde mira al 150% de su velocidad máxima real de carrera. Toggle Block
    // consume el estado cargado inmediatamente antes de producir el impulso.
    void PerformChargedBlockDash()
    {
        if (DerivedStats == null || IsPhysicallyImmobilized()) { return; }
        double movementFactor = Max(0.0, EffectiveMovementPercent / 100.0);
        if (ElementalStatus != null)
        {
            movementFactor *= ElementalStatus.GetMovementMultiplier();
        }
        double maximumRunSpeed =
            CaelumConstants.GZDOOM_BASE_MAX_RUN_SPEED * movementFactor;
        Vector2 dash = AngleToVector(Angle, maximumRunSpeed * 1.5);
        Vel.X = dash.X;
        Vel.Y = dash.Y;
    }

    void CancelCombatBlockMode()
    {
        CombatBlockInputGraceTics = 0;
        CombatBlockModeActive = false;
        DebugShieldBlocking = false;
        bREFLECTIVE = false;
        bSHIELDREFLECT = false;
    }

    void UpdateCombatBlockMode()
    {
        // No reinterpreta el input: sólo valida que un Block ya activo pueda
        // continuar. Esto evita que el estado desaparezca al tic siguiente.
        if (CombatBlockModeActive && !CanEnterCombatBlockMode())
        {
            CancelCombatBlockMode();
        }

        DebugShieldBlocking = CombatBlockModeActive;

        // El escudo mágico usa ahora la reflexión nativa del motor. REFLECTIVE
        // devuelve misiles y SHIELDREFLECT limita el comportamiento al frente.
        bool magicReflect = CombatBlockModeActive
            && !IsGiantGauntletsBlockSource()
            && ShieldModel != null
            && ShieldModel.Equipped
            && ShieldModel.Durability > 0
            && ShieldModel.ShieldType == CaelumConstants.SHIELD_TYPE_MAGIC;
        bREFLECTIVE = magicReflect;
        bSHIELDREFLECT = magicReflect;
    }

    CaelumEquipmentItem GetEquippedSeal()
    {
        for (Inventory cursor = Inv; cursor != null; cursor = cursor.Inv)
        {
            CaelumEquipmentItem seal = CaelumEquipmentItem(cursor);
            if (seal != null && seal.Equipped
                && seal.EquipmentKind == CaelumConstants.EQUIPMENT_KIND_SEAL)
                return seal;
        }
        return null;
    }

    double GetSealChannelAdrenalinePerTic(int tier)
    {
        if (tier >= 3) return CaelumConstants.SEAL_CHANNEL_T3_ADRENALINE_PER_TIC;
        if (tier == 2) return CaelumConstants.SEAL_CHANNEL_T2_ADRENALINE_PER_TIC;
        return CaelumConstants.SEAL_CHANNEL_T1_ADRENALINE_PER_TIC;
    }

    void StopSealChannel(bool startCooldown)
    {
        if (!CombatChannelModeActive && CombatChannelEffectActor == null) return;
        CombatChannelModeActive = false;
        HUDChannelAffectedCount = 0;
        if (CombatChannelEffectActor != null)
        {
            CaelumChannelEffect effect = CaelumChannelEffect(CombatChannelEffectActor);
            if (effect != null) effect.ReleaseChannel();
            else CombatChannelEffectActor.Destroy();
            CombatChannelEffectActor = null;
        }
        if (startCooldown)
            CombatChannelCooldownRemaining = CaelumConstants.SEAL_CHANNEL_COOLDOWN_SECONDS;
    }

    void UpdateSealChannel()
    {
        CombatChannelCooldownRemaining = Max(0.0,
            CombatChannelCooldownRemaining - 1.0 / TICRATE);
        if (!CombatChannelModeActive) return;
        CaelumEquipmentItem seal = GetEquippedSeal();
        bool interrupted = player == null || player.playerstate != PST_LIVE
            || health <= 0 || seal == null
            || seal.ItemType != CombatChannelSealType
            || seal.Tier != CombatChannelSealTier
            || PainImmobilizationRemaining > 0.0
            || LucidityPhysicalStunRemaining > 0.0;
        if (interrupted || CurrentAdrenaline < CombatChannelAdrenalinePerTic)
        {
            StopSealChannel(true);
            return;
        }
        CurrentAdrenaline = Max(0.0,
            CurrentAdrenaline - CombatChannelAdrenalinePerTic);
        Vel.X = 0.0; Vel.Y = 0.0;
        CancelCombatBlockMode();
        CancelRangedAim();
        CancelRangedReload();
        CancelWeaponCharge();
        CancelPendingStaffCast(false);
        if (CombatChannelEffectActor != null)
            CombatChannelEffectActor.SetOrigin(Pos, false);
    }

    // User2 alterna la canalizacion; Reload conserva sus funciones propias.
    void RequestCombatChannelInput()
    {
        if (CombatChannelModeActive)
        {
            CombatChannelInputLatched = true;
            StopSealChannel(true);
            return;
        }
        if (CombatChannelCooldownRemaining > 0.0 || player == null
            || player.playerstate != PST_LIVE || health <= 0
            || EquipmentMenuOpen || CreationWizardOpen || CraftingMenuOpen
            || IsPhysicallyImmobilized() || StaffCastPending) return;
        CaelumEquipmentItem seal = GetEquippedSeal();
        if (seal == null) return;
        CombatChannelSealType = Clamp(seal.ItemType, 0,
            CaelumConstants.SEAL_TYPE_COUNT - 1);
        CombatChannelSealTier = Clamp(seal.Tier, 1, 3);
        CombatChannelAdrenalinePerTic =
            GetSealChannelAdrenalinePerTic(CombatChannelSealTier);
        if (CurrentAdrenaline < CombatChannelAdrenalinePerTic) return;
        CombatChannelRadius = CaelumConstants.ESSENCE_EXPLOSION_BASE_RADIUS
            * CaelumConstants.SEAL_CHANNEL_RADIUS_STATUETTE_MULTIPLIER
            * (DerivedStats != null
                ? DerivedStats.AbilityRangePercent / 100.0 : 1.0);
        CaelumChannelEffect effect = CaelumChannelEffect(
            Spawn("CaelumChannelEffect", Pos, ALLOW_REPLACE));
        if (effect == null) return;
        effect.ConfigureChannel(self, CombatChannelSealType,
            CombatChannelSealTier, CombatChannelRadius);
        CombatChannelEffectActor = effect;
        CombatChannelModeActive = true;
        CombatChannelInputLatched = true;
        CancelCombatBlockMode();
        CancelRangedAim();
        CancelRangedReload();
        CancelWeaponCharge();
        ShowAbilitySuccessMessage();
    }

    // User1/User3/User4 quedan conectados al arma pero no ejecutan mecánicas
    // hasta que sus respectivos bloques sean implementados.
    void ReserveRacialAbilityInput()
    {
        CombatRacialAbilityInputReserved = true;
        ShowAbilitySuccessMessage();
        CombatRacialAbilityInputReserved = false;
    }

    void ReserveTarotInput()
    {
        CombatTarotInputReserved = true;
        ShowAbilitySuccessMessage();
        CombatTarotInputReserved = false;
    }

    void ReserveClassAbilityInput()
    {
        CombatClassAbilityInputReserved = true;
        ShowAbilitySuccessMessage();
        CombatClassAbilityInputReserved = false;
    }

    void ShowAbilitySuccessMessage()
    {
        // El HUD garantiza visibilidad aunque los mensajes de consola estén
        // desactivados por la configuración local del jugador.
        HUDAbilitySuccessRemaining = 2.0;
    }

    void UpdateShieldAirCost()
    {
        CurrentShieldAirCostPerSecond = 0.0;
        if (DerivedStats == null || !HasActiveBlockSource()) { return; }
        CurrentShieldAirCostPerSecond = GetActiveBlockWeight()
            * CaelumConstants.SHIELD_AIR_WEIGHT_RATIO_PER_SECOND
            * DerivedStats.AirConsumptionMultiplier;
    }

    void ConsumeShieldBlockingAir()
    {
        UpdateShieldAirCost();
        if (!DebugShieldBlocking || !HasActiveBlockSource()) { return; }
        if (CurrentAir <= 0.0)
        {
            CancelCombatBlockMode();
            return;
        }
        CurrentAir = Max(0.0, CurrentAir - CurrentShieldAirCostPerSecond / TICRATE);
        if (CurrentAir <= 0.0) { CancelCombatBlockMode(); }
        UpdateAirStateEffects();
    }

    void CycleDebugShieldType()
    {
        if (ShieldModel != null) { PersistCharacterState(); ShieldModel.CycleType(); ApplyCharacterProfile(); UpdateShieldAirCost(); PersistCharacterState(); RefreshEquipmentSelectionPreview(); }
    }

    void CycleDebugShieldTier()
    {
        if (ShieldModel != null) { PersistCharacterState(); ShieldModel.CycleTier(); ApplyCharacterProfile(); PersistCharacterState(); RefreshEquipmentSelectionPreview(); }
    }

    void ToggleDebugShieldBlock()
    {
        ToggleCombatBlockMode();
    }

    void ToggleDebugShieldDamageKind()
    {
        DebugShieldDamageKind = DebugShieldDamageKind == CaelumConstants.SHIELD_DAMAGE_PHYSICAL
            ? CaelumConstants.SHIELD_DAMAGE_MAGICAL
            : CaelumConstants.SHIELD_DAMAGE_PHYSICAL;
    }

    void CycleDebugShieldIncomingAngle()
    {
        DebugShieldIncomingAngleOffset += 10;
        if (DebugShieldIncomingAngleOffset > 180)
        {
            DebugShieldIncomingAngleOffset = 0;
        }
    }

    void RepairDebugShield()
    {
        if (ShieldModel != null) { ShieldModel.Repair(); PersistCharacterState(); RefreshEquipmentSelectionPreview(); }
    }

    void ApplyDebugShieldHit()
    {
        LastShieldAbsorbedDamage = 0.0;
        LastShieldHealthDamage = int(CaelumConstants.DEBUG_SHIELD_HIT_DAMAGE);
        LastShieldDurabilityLoss = 0;
        LastShieldDurabilityChancePercent = 0.0;
        LastShieldDurabilityRollPercent = 0.0;
        LastShieldWithinCoverage = ShieldModel != null
            && ShieldModel.Equipped
            && Abs(DebugShieldIncomingAngleOffset)
                <= ShieldModel.GetCoverageDegrees() / 2.0;
        bool shieldCanBlock = ShieldModel != null
            && ShieldModel.Equipped
            && DebugShieldBlocking
            && ShieldModel.Durability > 0
            && LastShieldWithinCoverage;
        if (shieldCanBlock)
        {
            double defenseRatio = Clamp(
                ShieldModel.GetDefense(DebugShieldDamageKind) / 100.0,
                0.0, 1.0
            );
            LastShieldAbsorbedDamage = CaelumConstants.DEBUG_SHIELD_HIT_DAMAGE
                * defenseRatio;
            LastShieldHealthDamage = int(
                CaelumConstants.DEBUG_SHIELD_HIT_DAMAGE
                    - LastShieldAbsorbedDamage + 0.5
            );
            if (LastShieldAbsorbedDamage > 0.0)
            {
                AddCombatAdrenaline(
                    CaelumConstants.ADRENALINE_GAIN_ON_SHIELD_BLOCK,
                    CaelumConstants.ADRENALINE_EVENT_SHIELD_BLOCK
                );
                MarkCombatActivity();
            }

            double eligibleDamage = LastShieldAbsorbedDamage
                * Max(0.0, ArmorDurabilityDamageMultiplier);
            LastShieldDurabilityLoss = int(
                eligibleDamage
                    / CaelumConstants.ARMOR_ABSORBED_DAMAGE_PER_GUARANTEED_DURABILITY
            );
            double remainder = eligibleDamage
                - LastShieldDurabilityLoss
                    * CaelumConstants.ARMOR_ABSORBED_DAMAGE_PER_GUARANTEED_DURABILITY;
            LastShieldDurabilityChancePercent = Clamp(
                remainder / CaelumConstants.ARMOR_DAMAGE_PER_DURABILITY_CHANCE_PERCENT,
                0.0, 100.0
            );
            int roll = Random[CaelumShieldDurability](0, 999999);
            LastShieldDurabilityRollPercent = roll / 10000.0;
            if (LastShieldDurabilityRollPercent < LastShieldDurabilityChancePercent)
            {
                LastShieldDurabilityLoss++;
            }
            LastShieldDurabilityLoss = Min(
                LastShieldDurabilityLoss,
                ShieldModel.Durability
            );
            ShieldModel.Durability -= LastShieldDurabilityLoss;
            if (ShieldModel.Durability <= 0) { CancelCombatBlockMode(); }
        }

        // The damage not stopped by the shield now enters the selected body
        // region's complete armor, health, lucidity, and pain test pipeline.
        ApplyDebugArmorPipeline(LastShieldHealthDamage);
    }

    // Charge air only after GZDoom confirms a real takeoff: the player was on
    // the ground, is now airborne, is rising, and pressed the jump control.
    // The prediction guard prevents client-side prediction from charging the
    // persistent resource in addition to the authoritative game tic.
    void DetectAndChargePhysicalJump()
    {
        if (player == null || player.playerstate != PST_LIVE)
        {
            return;
        }

        bool isGroundedNow = player.onground;

        if (!JumpTrackingInitialized)
        {
            WasGroundedLastTick = isGroundedNow;
            JumpTrackingInitialized = true;
            return;
        }

        bool jumpPressed = (player.cmd.buttons & BT_JUMP) != 0;
        bool startedRising = WasGroundedLastTick
            && !isGroundedNow
            && Vel.Z > 0.0;

        if (startedRising
            && jumpPressed
            && !(player.cheats & CF_PREDICTING))
        {
            ConsumeJumpAir();
        }

        WasGroundedLastTick = isGroundedNow;
    }

    void UpdateMovementAcceleration()
    {
        if (player == null || player.playerstate != PST_LIVE)
        {
            MovementAccelerationFactor = 0.0;
            MovementAccelerationSeconds = 0.0;
            return;
        }

        bool hasMovementInput = player.cmd.forwardmove != 0
            || player.cmd.sidemove != 0;

        if (!hasMovementInput || IsPhysicallyImmobilized())
        {
            MovementAccelerationFactor = 0.0;
            MovementAccelerationSeconds = 0.0;
            return;
        }

        // En un salto normal se conserva el momentum sin acelerar. Fly usa
        // NOGRAVITY y debe conservar control lateral como soporte continuo.
        if (!player.onground && !bNOGRAVITY) { return; }

        MovementAccelerationFactor +=
            (1.0 - MovementAccelerationFactor)
            * CaelumConstants.MOVEMENT_ACCELERATION_ALPHA_PER_TIC;
        MovementAccelerationFactor = Clamp(
            MovementAccelerationFactor, 0.0, 1.0
        );
        MovementAccelerationSeconds += 1.0 / TICRATE;
    }

    // Apply the verified effective values to GZDoom's real movement fields.
    // Forward/backward, sideways, swimming, and flight share this movement.
    void ApplyPhysicalMovement()
    {
        double movementFactor = Max(0.0, EffectiveMovementPercent / 100.0);
        double jumpFactor = Max(0.0, EffectiveJumpHeightPercent / 100.0);
        if (ElementalStatus != null)
        {
            double elementalMovement = ElementalStatus.GetMovementMultiplier();
            movementFactor *= elementalMovement;
            jumpFactor *= elementalMovement;
        }

        // Crossing the critical lucidity threshold causes one two-second
        // physical stun. Zeroing horizontal velocity prevents residual sliding
        // while movement and jumping are disabled.
        if (IsPhysicallyImmobilized())
        {
            movementFactor = 0.0;
            jumpFactor = 0.0;
            Vel.X = 0.0;
            Vel.Y = 0.0;
        }

        movementFactor *= GetShieldCombatMobilityMultiplier();
        if (IsReloadOrChargeActive() && HasReloadMovementInput())
        {
            movementFactor *=
                CaelumConstants.RELOAD_MOVEMENT_AND_PROGRESS_MULTIPLIER;
        }
        movementFactor *= MovementAccelerationFactor;

        double walkMovement =
            CaelumConstants.GZDOOM_BASE_MOVEMENT * movementFactor;

        // Player.ForwardMove/SideMove son multiplicadores. GZDoom ya duplica
        // internamente la velocidad al correr, por lo que NO debemos volver a
        // multiplicar ForwardMove2 por 2 aquí.
        //
        // Movimiento real normal:
        //   caminar = 1.00 * walkMovement
        //   correr  = 2.00 * walkMovement  (factor nativo del motor)
        //
        // El punto medio real es 1.50 * walkMovement. Como el motor vuelve a
        // multiplicar el valor "run" por 2, el multiplicador que debemos
        // entregar durante Block es 0.75 * walkMovement.
        ForwardMove1 = walkMovement;
        SideMove1 = walkMovement;
        if (CombatBlockModeActive)
        {
            ForwardMove2 = walkMovement * 0.75;
            SideMove2 = walkMovement * 0.75;
        }
        else
        {
            ForwardMove2 = walkMovement;
            SideMove2 = walkMovement;
        }
        JumpZ = CaelumConstants.GZDOOM_BASE_JUMP_Z * jumpFactor;
    }

    bool IsPhysicallyImmobilized()
    {
        return CombatChannelModeActive
            || LucidityPhysicalStunRemaining > 0.0
            || PainImmobilizationRemaining > 0.0
            || (ElementalStatus != null
                && ElementalStatus.IsLightningStunned());
    }

    // Recalculate base attributes whenever a debug profile choice changes.
    void AddJewelryFamilyBonus(CaelumAttributes a, int family, int amount)
    {
        if (family == CaelumConstants.LAYER_PHYSICAL) { a.Strength+=amount; a.Toughness+=amount; a.Constitution+=amount; }
        else if (family == CaelumConstants.LAYER_TECHNICAL) { a.Agility+=amount; a.Dexterity+=amount; a.Resilience+=amount; }
        else if (family == CaelumConstants.LAYER_SOCIAL) { a.Charisma+=amount; a.Empathy+=amount; a.Eloquence+=amount; }
        else { a.Intelligence+=amount; a.Patience+=amount; a.Insight+=amount; }
    }
    void ApplyJewelryAttributeBonuses(CaelumAttributes a)
    {
        // Durante el creador no existe joyería equipable. Evitamos recorrer
        // el inventario provisional y conservamos exactamente la ruta de
        // atributos que ya estaba validada antes de V4.23.4.
        if (a == null || !CharacterCreationComplete) return;

        for (Inventory c=Inv; c!=null; c=c.Inv)
        {
            CaelumEquipmentItem j=CaelumEquipmentItem(c);
            if (j==null || !j.Equipped) continue;
            int mult=Clamp(j.Tier,1,3);
            if (j.EquipmentKind == CaelumConstants.EQUIPMENT_KIND_SEAL)
            {
                int b=CaelumConstants.SEAL_ALL_ATTRIBUTE_BONUS_T1*mult;
                AddJewelryFamilyBonus(a,CaelumConstants.LAYER_PHYSICAL,b);
                AddJewelryFamilyBonus(a,CaelumConstants.LAYER_TECHNICAL,b);
                AddJewelryFamilyBonus(a,CaelumConstants.LAYER_SOCIAL,b);
                AddJewelryFamilyBonus(a,CaelumConstants.LAYER_MENTAL,b);
            }
            else if (j.EquipmentKind == CaelumConstants.EQUIPMENT_KIND_AMULET)
            {
                int main=CaelumConstants.AMULET_MAIN_FAMILY_BONUS_T1*mult;
                int adj=CaelumConstants.AMULET_ADJACENT_FAMILY_BONUS_T1*mult;
                int opp=CaelumConstants.AMULET_OPPOSITE_FAMILY_BONUS_T1*mult;
                if (j.ItemType==CaelumConstants.AMULET_RUBY) {
                    AddJewelryFamilyBonus(a,CaelumConstants.LAYER_PHYSICAL,main); AddJewelryFamilyBonus(a,CaelumConstants.LAYER_TECHNICAL,adj); AddJewelryFamilyBonus(a,CaelumConstants.LAYER_SOCIAL,adj); AddJewelryFamilyBonus(a,CaelumConstants.LAYER_MENTAL,opp);
                } else if (j.ItemType==CaelumConstants.AMULET_SAPPHIRE) {
                    AddJewelryFamilyBonus(a,CaelumConstants.LAYER_MENTAL,main); AddJewelryFamilyBonus(a,CaelumConstants.LAYER_TECHNICAL,adj); AddJewelryFamilyBonus(a,CaelumConstants.LAYER_SOCIAL,adj); AddJewelryFamilyBonus(a,CaelumConstants.LAYER_PHYSICAL,opp);
                } else if (j.ItemType==CaelumConstants.AMULET_EMERALD) {
                    AddJewelryFamilyBonus(a,CaelumConstants.LAYER_TECHNICAL,main); AddJewelryFamilyBonus(a,CaelumConstants.LAYER_PHYSICAL,adj); AddJewelryFamilyBonus(a,CaelumConstants.LAYER_MENTAL,adj); AddJewelryFamilyBonus(a,CaelumConstants.LAYER_SOCIAL,opp);
                } else {
                    AddJewelryFamilyBonus(a,CaelumConstants.LAYER_SOCIAL,main); AddJewelryFamilyBonus(a,CaelumConstants.LAYER_PHYSICAL,adj); AddJewelryFamilyBonus(a,CaelumConstants.LAYER_MENTAL,adj); AddJewelryFamilyBonus(a,CaelumConstants.LAYER_TECHNICAL,opp);
                }
            }
        }
    }

    void ApplyCharacterProfile()
    {
        if (Attributes != null
            && CharacterProfile != null
            && CharacterAllocation != null
            && DerivedStats != null)
        {
            Attributes.InitializeFromCreation(CharacterProfile, CharacterAllocation);
            if (ArmorModel != null)
            {
                ArmorModel.ApplyAttributeBonuses(Attributes);
            }
            ApplyJewelryAttributeBonuses(Attributes);
            if (CharacterProfile.Race == CaelumConstants.RACE_DEBUG)
            {
                // El perfil rápido debe quedar exactamente en 30 incluso si
                // el equipo inicial concede bonificaciones de atributo.
                Attributes.SetAllForDebug(
                    CaelumConstants.DEBUG_CREATION_ATTRIBUTE_LEVEL
                );
            }
            else if (DebugAttributesAt100)
            {
                Attributes.SetAllForDebug(CaelumConstants.DEBUG_ALL_ATTRIBUTES_LEVEL_100);
            }
            else if (DebugAttributesAt75)
            {
                // The probability-test override is deliberately the final
                // value; equipment bonuses remain active only in normal play.
                Attributes.SetAllForDebug(CaelumConstants.DEBUG_ALL_ATTRIBUTES_LEVEL_75);
            }
            RefreshCarriedInventorySummary();
            DerivedStats.Recalculate(Attributes, CharacterProfile);
            SyncHUDLoadState();
            // La masa nativa representa la masa total para que el motor y los
            // ataques externos respeten tambien el peso equipado del jugador.
            Mass = Max(1, int(DerivedStats.TotalMass + 0.5));
            // Radius es readonly en ZScript; A_SetSize actualiza ambas medidas
            // y vuelve a enlazar correctamente al jugador en el mundo.
            A_SetSize(
                DerivedStats.ActorRadius,
                DerivedStats.ActorHeight,
                false
            );
            UpdateLucidityAccuracyEffects();

            // Recalculation never grants free healing. Increasing the maximum
            // leaves current health unchanged; decreasing it only clamps an
            // amount that no longer fits under the new maximum.
            if (HealthResourceInitialized)
            {
                CaelumMaximumHealth = Max(1, int(DerivedStats.MaximumHealth));
                health = Min(health, CaelumMaximumHealth);

                if (player != null)
                {
                    player.health = health;
                }
            }

            // Profile changes never refill Anima for free; they only enforce a
            // newly reduced capacity, matching the health and air behavior.
            if (AnimaResourceInitialized)
            {
                CurrentAnima = Min(CurrentAnima, DerivedStats.MaximumAnima);
            }

            if (AdrenalineResourceInitialized)
            {
                CurrentAdrenaline = Min(
                    CurrentAdrenaline,
                    DerivedStats.MaximumAdrenaline
                );
            }

            // A profile change may lower maximum air. Never leave the current
            // resource above its newly calculated maximum.
            if (AirResourceInitialized)
            {
                CurrentAir = Min(CurrentAir, DerivedStats.MaximumAir);
            }
        }
    }

    // Spend one provisional action cost after applying the current load
    // multiplier. This validates the resource before real actions use it.
    void ConsumeDebugAir()
    {
        if (DerivedStats == null)
        {
            return;
        }

        double finalCost = CaelumConstants.DEBUG_AIR_ACTION_COST
            * DerivedStats.AirConsumptionMultiplier;
        CurrentAir = Max(0.0, CurrentAir - finalCost);
        UpdateAirStateEffects();
    }

    // Consume un costo de Anima de prueba ya expresado en la escala actual.
    void ConsumeDebugAnima()
    {
        CurrentAnima = Max(
            0.0,
            CurrentAnima - CaelumConstants.DEBUG_ANIMA_ACTION_COST
        );
    }

    // Restaura Anima solo mediante el control de desarrollo explicito.
    void RefillAnima()
    {
        if (DerivedStats != null)
        {
            CurrentAnima = DerivedStats.MaximumAnima;
        }
    }

    // Agrega una cantidad positiva sin superar el maximo derivado de Resiliencia.
    void AddAdrenaline(double amount)
    {
        if (DerivedStats != null)
        {
            CurrentAdrenaline = Clamp(
                CurrentAdrenaline + Max(0.0, amount),
                0.0,
                DerivedStats.MaximumAdrenaline
            );
        }
    }

    // Health state multiplies only gameplay-earned adrenaline. The manual
    // development fill control remains exact so resource testing stays useful.
    void AddCombatAdrenaline(
        double amount,
        int eventType = CaelumConstants.ADRENALINE_EVENT_OTHER
    )
    {
        LastAdrenalineEvent = eventType;
        LastAdrenalineBaseGain = Max(0.0, amount);
        LastAdrenalineFinalGain = LastAdrenalineBaseGain
            * HealthAdrenalineGainMultiplier;
        AddAdrenaline(LastAdrenalineFinalGain);
    }

    // Every confirmed combat event restarts the entire thirty-second timer.
    void MarkCombatActivity()
    {
        CombatTimeRemaining = CaelumConstants.COMBAT_TIMEOUT_SECONDS;
    }

    // Wait until combat ends, then remove ten points per second. TICRATE keeps
    // the result independent of rendering speed and pauses it with the game.
    void UpdateAdrenalineDecay()
    {
        if (!AdrenalineResourceInitialized || CurrentAdrenaline <= 0.0)
        {
            CombatTimeRemaining = Max(0.0, CombatTimeRemaining);
            return;
        }

        if (CombatTimeRemaining > 0.0)
        {
            CombatTimeRemaining = Max(
                0.0,
                CombatTimeRemaining - 1.0 / TICRATE
            );
            return;
        }

        CurrentAdrenaline = Max(
            0.0,
            CurrentAdrenaline
                - CaelumConstants.ADRENALINE_DECAY_PER_SECOND / TICRATE
        );
    }

    // Temporary helpers make capacity and timing easy to verify before Tarot
    // cards and the remaining combat event types are programmed.
    void AddDebugAdrenaline()
    {
        AddAdrenaline(CaelumConstants.DEBUG_ADRENALINE_GAIN);
        CombatChannelCooldownRemaining = Max(
            0.0,
            CombatChannelCooldownRemaining
                - CaelumConstants.DEBUG_SEAL_COOLDOWN_REDUCTION_SECONDS
        );
        MarkCombatActivity();
    }

    void ClearDebugAdrenaline()
    {
        CurrentAdrenaline = 0.0;
        CombatTimeRemaining = 0.0;
    }

    void HealDebugHealth()
    {
        if (player == null
            || player.playerstate != PST_LIVE
            || CaelumMaximumHealth <= 0)
        {
            return;
        }

        health = CaelumMaximumHealth;
        player.health = health;
        if (DerivedStats != null)
        {
            CurrentAnima = DerivedStats.MaximumAnima;
            CurrentAir = DerivedStats.MaximumAir;
        }
        NaturalHealthRegenerationAccumulator = 0.0;
        UpdateHealthStateEffects();
        UpdateAirStateEffects();
    }

    void ApplyConsumableRegenerationPulse(int consumableType)
    {
        if (player == null || player.playerstate != PST_LIVE
            || DerivedStats == null)
        {
            return;
        }
        double pulseRatio =
            CaelumConstants.CONSUMABLE_REGENERATION_PERCENT_PER_SECOND;
        switch (consumableType)
        {
            case CaelumConstants.CONSUMABLE_LIFE_POTION:
            {
                int healing = Max(1, int(CaelumMaximumHealth * pulseRatio + 0.5));
                health = Min(CaelumMaximumHealth, health + healing);
                player.health = health;
                UpdateHealthStateEffects();
                break;
            }
            case CaelumConstants.CONSUMABLE_ANIMA_POTION:
                CurrentAnima = Min(
                    DerivedStats.MaximumAnima,
                    CurrentAnima + DerivedStats.MaximumAnima * pulseRatio
                );
                break;
            case CaelumConstants.CONSUMABLE_ENERGY_DRINK:
                CurrentAir = Min(
                    DerivedStats.MaximumAir,
                    CurrentAir + DerivedStats.MaximumAir * pulseRatio
                );
                CurrentSleep = Min(
                    CaelumConstants.SURVIVAL_MAXIMUM,
                    CurrentSleep
                        + CaelumConstants.SURVIVAL_MAXIMUM * pulseRatio
                );
                UpdateAirStateEffects();
                UpdateSurvivalStates();
                break;
            case CaelumConstants.CONSUMABLE_FOOD_RATION:
                CurrentHunger = Min(
                    CaelumConstants.SURVIVAL_MAXIMUM,
                    CurrentHunger
                        + CaelumConstants.SURVIVAL_MAXIMUM * pulseRatio
                );
                UpdateSurvivalStates();
                break;
            case CaelumConstants.CONSUMABLE_WATER_RATION:
                CurrentThirst = Min(
                    CaelumConstants.SURVIVAL_MAXIMUM,
                    CurrentThirst
                        + CaelumConstants.SURVIVAL_MAXIMUM * pulseRatio
                );
                UpdateSurvivalStates();
                break;
        }
        PersistCharacterState();
    }

    void CycleDebugPanelPage()
    {
        DebugPanelPage = (DebugPanelPage + 1) % 6;
    }

    void GrantEnemyKillAdrenaline()
    {
        AddCombatAdrenaline(
            CaelumConstants.ADRENALINE_GAIN_ON_ENEMY_KILL,
            CaelumConstants.ADRENALINE_EVENT_ENEMY_KILL
        );
        MarkCombatActivity();
    }

    void GrantNearbyAllyDeathAdrenaline()
    {
        AddCombatAdrenaline(
            CaelumConstants.ADRENALINE_GAIN_ON_NEARBY_ALLY_DEATH,
            CaelumConstants.ADRENALINE_EVENT_ALLY_DEATH
        );
        MarkCombatActivity();
    }

    // Apply a non-lethal loss equal to five percent of maximum health. Direct
    // subtraction deliberately bypasses provisional Doom armor, then routes
    // through the exact same Caelum pain and adrenaline calculation as a real
    // mitigated hit. Keeping one health point makes repeated testing convenient.
    void ApplyDebugPainDamage()
    {
        if (player == null
            || player.playerstate != PST_LIVE
            || health <= 1
            || CaelumMaximumHealth <= 0)
        {
            return;
        }

        double adrenalineRatioBeforeDamage = 0.0;
        if (DerivedStats != null && DerivedStats.MaximumAdrenaline > 0.0)
        {
            adrenalineRatioBeforeDamage = Clamp(
                CurrentAdrenaline / DerivedStats.MaximumAdrenaline,
                0.0,
                1.0
            );
        }

        int testDamage = Max(
            1,
            int(CaelumMaximumHealth
                * CaelumConstants.DEBUG_PAIN_HEALTH_LOSS_RATIO + 0.5)
        );
        testDamage = Min(testDamage, health - 1);
        health -= testDamage;
        player.health = health;

        UpdateHealthStateEffects();
        CalculateAndTriggerPain(
            testDamage,
            adrenalineRatioBeforeDamage,
            true
        );
        AddCombatAdrenaline(
            CaelumConstants.ADRENALINE_GAIN_ON_DAMAGE,
            CaelumConstants.ADRENALINE_EVENT_DAMAGE
        );
        MarkCombatActivity();
    }

    // Cycle exact health thresholds without simulating an impact. This keeps
    // pain and adrenaline diagnostics separate while testing state penalties.
    void CycleDebugHealthState()
    {
        if (player == null || player.playerstate != PST_LIVE || CaelumMaximumHealth <= 0)
        {
            return;
        }

        if (HealthState == CaelumConstants.HEALTH_STATE_NORMAL)
        {
            health = Max(1, int(CaelumMaximumHealth * 0.50));
        }
        else if (HealthState == CaelumConstants.HEALTH_STATE_WOUNDED)
        {
            health = Max(1, int(CaelumMaximumHealth * 0.10));
        }
        else
        {
            health = CaelumMaximumHealth;
        }
        player.health = health;
        UpdateHealthStateEffects();
        UpdateAirStateEffects();
    }

    // Sends a small directed test hit through DamageMobj so the exact live
    // evasion gate can be repeated without waiting for a monster to attack.
    void ApplyDebugEvasionAttack()
    {
        if (player == null || player.playerstate != PST_LIVE || health <= 1)
        {
            return;
        }

        int testDamage = Max(
            1,
            int(CaelumMaximumHealth * CaelumConstants.DEBUG_EVASION_DAMAGE_RATIO + 0.5)
        );
        DamageMobj(self, self, testDamage, 'Hitscan', DMG_NO_ARMOR, Angle);
    }

    // Perform the documented sword primary attack with simplified localization.
    // LineAttack supplies the actor actually reached and the damage remaining
    // after the target's current engine mitigation. The physical critical roll
    // is live; status effects and the final Caelum armor stage remain separate.
    void PerformDebugSwordAttack(bool secondaryAttack)
    {
        LastMeleeCalculatedDamage = 0.0;
        LastMeleeActualDamage = 0;
        LastMeleeHit = false;
        LastMeleeHitLocation = CaelumConstants.HIT_LOCATION_NONE;
        LastMeleeVulnerabilityGrade = CaelumConstants.VULNERABILITY_NEUTRAL_POINT;
        LastMeleeHitHeightRatio = 0.0;
        LastMeleeLocationMultiplier = 0.0;
        LastMeleeAirCost = 0.0;
        LastMeleeHadEnoughAir = false;
        LastMeleeCriticalAttempted = false;
        LastMeleeCriticalHit = false;
        LastMeleeCriticalChancePercent = 0.0;
        LastMeleeCriticalRollPercent = 0.0;
        LastMeleeAccuracyPercent = 0.0;
        LastMeleeMovementAccuracyMultiplier = 1.0;
        LastMeleeCrouchCriticalMultiplier = 1.0;
        LastMeleeYawOffset = 0.0;
        LastMeleePitchOffset = 0.0;
        LastAttackPushForce = 0.0;

        if (player == null
            || player.playerstate != PST_LIVE
            || DerivedStats == null
            || IsPhysicallyImmobilized())
        {
            return;
        }

        int activeWeaponType = WeaponModel != null
            ? WeaponModel.WeaponType : CaelumConstants.WEAPON_TYPE_SWORD;
        int catalogueWeapon =
            CaelumCraftingRules.GetCatalogueWeaponForPlayableType(
                activeWeaponType
            );
        if (catalogueWeapon < 0) { return; }
        LastMeleeAirCost = (secondaryAttack
            ? CaelumWeaponCatalogue.GetSecondaryAirCost(catalogueWeapon)
            : CaelumWeaponCatalogue.GetPrimaryAirCost(catalogueWeapon))
            * DerivedStats.AirConsumptionMultiplier;
        bool chargedAttack = WeaponChargedStateActive;
        if (chargedAttack)
        {
            LastMeleeAirCost *=
                CaelumConstants.WEAPON_CHARGED_COST_MULTIPLIER;
        }
        if (CurrentAir < LastMeleeAirCost)
        {
            return;
        }

        LastMeleeHadEnoughAir = true;
        if (chargedAttack) { ConsumeWeaponChargedState(); }
        CurrentAir = Max(0.0, CurrentAir - LastMeleeAirCost);
        UpdateAirStateEffects();

        double selectedBaseDamage = secondaryAttack
            ? CaelumWeaponCatalogue.GetSecondaryDamage(catalogueWeapon)
            : CaelumWeaponCatalogue.GetPrimaryDamage(catalogueWeapon);
        double physicalWeaponDamageScale = selectedBaseDamage
            * WeaponModel.GetTierDamageMultiplierFor(WeaponModel.Tier)
            / CaelumConstants.DEBUG_SWORD_BASE_DAMAGE;
        LastMeleeCalculatedDamage = DerivedStats.DebugSwordDamage
            * physicalWeaponDamageScale
            * EffectiveOffensiveDamageMultiplier;
        if (chargedAttack)
        {
            LastMeleeCalculatedDamage *=
                CaelumConstants.WEAPON_CHARGED_DAMAGE_MULTIPLIER;
        }
        FTranslatedLineTarget targetData;
        UpdateLucidityAccuracyEffects();
        // Running applies after attributes and lucidity, retaining 25% of the
        // accuracy available at the instant the attack begins. Walking and
        // standing do not add a movement penalty.
        UpdateCrouchEffects();
        LastMeleeMovementAccuracyMultiplier = IsCrouching
            ? CrouchAccuracyMultiplier
            : (IsRunningOnGround()
                ? CaelumConstants.RUNNING_ACCURACY_MULTIPLIER
                : 1.0);
        LastMeleeAccuracyPercent = Max(
            1.0,
            EffectivePhysicalAccuracyPercent
                * LastMeleeMovementAccuracyMultiplier
        );
        double maximumAimError = CaelumWeaponCatalogue.GetMaximumSpread(
            catalogueWeapon
        ) * 100.0 / LastMeleeAccuracyPercent;
        double minimumAimError = CaelumWeaponCatalogue.GetMinimumSpread(
            catalogueWeapon
        ) * 100.0 / LastMeleeAccuracyPercent;
        int meleeYawRoll = Random[CaelumSwordAccuracyYaw](-100000, 100000);
        int meleePitchRoll = Random[CaelumSwordAccuracyPitch](-100000, 100000);
        LastMeleeYawOffset = (meleeYawRoll < 0 ? -1.0 : 1.0)
            * (minimumAimError + (maximumAimError - minimumAimError)
                * Abs(meleeYawRoll) / 100000.0);
        LastMeleePitchOffset = (meleePitchRoll < 0 ? -1.0 : 1.0)
            * (minimumAimError + (maximumAimError - minimumAimError)
                * Abs(meleePitchRoll) / 100000.0);
        double attackAngle = Angle + LastMeleeYawOffset;
        double attackPitch = Pitch + LastMeleePitchOffset;

        // First trace detects the actor under the crosshair without changing it.
        // Using the player's real pitch makes vertical aiming select body zones.
        Actor detectionPuff;
        int ignoredDamage;
        [detectionPuff, ignoredDamage] = LineAttack(
            attackAngle,
            secondaryAttack
                ? CaelumWeaponCatalogue.GetSecondaryRange(catalogueWeapon)
                : CaelumWeaponCatalogue.GetPrimaryRange(catalogueWeapon),
            attackPitch,
            0,
            'CaelumMeleeTest',
            'CaelumNoDamageThrustPuff',
            LAF_ISMELEEATTACK | LAF_NOINTERACT | LAF_NORANDOMPUFFZ,
            targetData
        );

        LastMeleeHit = targetData.linetarget != null;
        if (!LastMeleeHit)
        {
            return;
        }

        CalculateDebugMeleeHitLocation(
            targetData.linetarget,
            attackAngle,
            attackPitch
        );
        LastMeleeCriticalAttempted = true;
        LastMeleeCrouchCriticalMultiplier = CrouchCriticalChanceMultiplier;
        LastMeleeCriticalChancePercent = Clamp(
            (CaelumWeaponCatalogue.GetCriticalChancePercent(catalogueWeapon)
                + Max(0.0, DerivedStats.PhysicalCriticalChance
                    - CaelumConstants.BASE_CRITICAL_CHANCE_PERCENT))
                * LastMeleeCrouchCriticalMultiplier,
            0.0,
            100.0
        );
        int criticalRoll = Random[CaelumPhysicalCritical](0, 999999);
        LastMeleeCriticalRollPercent = criticalRoll / 10000.0;
        LastMeleeCriticalHit = LastMeleeCriticalRollPercent
            < LastMeleeCriticalChancePercent;
        CaelumCombatActor meleeCombatTarget = CaelumCombatActor(
            targetData.linetarget
        );
        if (meleeCombatTarget != null)
        {
            meleeCombatTarget.RegisterPendingCriticalHit(
                LastMeleeCriticalHit
            );
        }
        LastMeleeLocationMultiplier = GetVulnerabilityMultiplier(
            LastMeleeVulnerabilityGrade,
            LastMeleeCriticalHit
        );
        LastMeleeCalculatedDamage = DerivedStats.DebugSwordDamage
            * physicalWeaponDamageScale
            * LastMeleeLocationMultiplier
            * EffectiveOffensiveDamageMultiplier;
        if (chargedAttack)
        {
            LastMeleeCalculatedDamage *=
                CaelumConstants.WEAPON_CHARGED_DAMAGE_MULTIPLIER;
        }
        int integerDamage = Max(1, int(LastMeleeCalculatedDamage + 0.5));

        Actor puff;
        int actualDamage;
        [puff, actualDamage] = LineAttack(
            attackAngle,
            secondaryAttack
                ? CaelumWeaponCatalogue.GetSecondaryRange(catalogueWeapon)
                : CaelumWeaponCatalogue.GetPrimaryRange(catalogueWeapon),
            attackPitch,
            integerDamage,
            'CaelumMeleeTest',
            'CaelumNoDamageThrustPuff',
            LAF_ISMELEEATTACK,
            targetData
        );
        LastMeleeActualDamage = actualDamage;

        if (LastMeleeHit && LastMeleeActualDamage > 0)
        {
            ApplyWeaponDurabilityFromSuccessfulDamage(
                LastMeleeActualDamage,
                WeaponModel.WeaponType,
                WeaponModel.Tier,
                WeaponModel.Size
            );
            ApplyAttackPushToTarget(
                targetData.linetarget,
                attackAngle,
                DerivedStats.PhysicalPushMultiplier
            );
            if (secondaryAttack
                && catalogueWeapon
                    == CaelumConstants.CATALOGUE_WEAPON_GIANT_GAUNTLETS
                && LastAttackPushForce > 0.0)
            {
                // El uppercut suma el mismo impulso físico en el eje vertical.
                targetData.linetarget.Vel.Z += LastAttackPushForce;
            }
            AddCombatAdrenaline(
                CaelumConstants.ADRENALINE_GAIN_ON_MELEE_DAMAGE,
                CaelumConstants.ADRENALINE_EVENT_MELEE
            );
            MarkCombatActivity();
        }
    }

    double GetShieldCombatMassMultiplier()
    {
        if (!CombatBlockModeActive || !HasActiveBlockSource())
        {
            return 1.0;
        }
        if (IsGiantGauntletsBlockSource()
            || ShieldModel.ShieldType == CaelumConstants.SHIELD_TYPE_BUCKLER)
        {
            return CaelumConstants.SHIELD_BUCKLER_COMBAT_MASS_MULTIPLIER;
        }
        if (ShieldModel.ShieldType == CaelumConstants.SHIELD_TYPE_TOWER)
        {
            return CaelumConstants.SHIELD_TOWER_COMBAT_MASS_MULTIPLIER;
        }
        return 1.0;
    }

    double GetCombatMass()
    {
        if (DerivedStats == null) { return 1.0; }
        return Max(
            1.0,
            DerivedStats.TotalMass * GetShieldCombatMassMultiplier()
        );
    }

    double GetShieldCombatMobilityMultiplier()
    {
        if (DerivedStats == null || !CombatBlockModeActive) { return 1.0; }
        double normalMass = Max(1.0, DerivedStats.TotalMass);
        double combatMass = GetCombatMass();
        double normalDenominator = normalMass / 2.0 + 50.0;
        double combatDenominator = combatMass / 2.0 + 50.0;
        return combatDenominator > 0.0
            ? normalDenominator / combatDenominator
            : 1.0;
    }

    // Calcula la resistencia con la masa efectiva de combate cuando el
    // receptor pertenece a Caelum. Para actores externos usa masa nativa.
    double GetTargetKnockbackMultiplier(Actor target)
    {
        if (target == null) { return 0.0; }
        CaelumPlayer playerTarget = CaelumPlayer(target);
        if (playerTarget != null && playerTarget.DerivedStats != null)
        {
            return 100.0 / (playerTarget.GetCombatMass() + 50.0);
        }
        CaelumCombatActor combatTarget = CaelumCombatActor(target);
        double targetMass = Max(1.0, target.Mass);
        if (combatTarget != null && combatTarget.CombatArmor != null)
        {
            targetMass += combatTarget.CombatArmor.GetTotalWeight();
        }
        return 100.0 / (targetMass + 50.0);
    }

    void ApplyAttackPushToTarget(Actor target, double attackAngle, double attackerMultiplier)
    {
        LastAttackPushForce = 0.0;
        if (target == null || target.health <= 0) { return; }
        LastAttackPushForce = CaelumConstants.BASE_ATTACK_PUSH_FORCE
            * Max(0.0, attackerMultiplier)
            * GetTargetKnockbackMultiplier(target);
        if (LastAttackPushForce > 0.0)
        {
            target.Thrust(LastAttackPushForce, attackAngle);
        }
    }

    // Estimates the ray's contact point on the target cylinder, then asks an
    // original actor's reusable anatomy profile to classify that normalized
    // impact. Other actors retain the humanoid fallback used by the dummy.
    void CalculateDebugMeleeHitLocation(
        Actor target,
        double attackAngle,
        double attackPitch
    )
    {
        if (target == null || target.Height <= 0.0)
        {
            LastMeleeHitLocation = CaelumConstants.HIT_LOCATION_TORSO;
            LastMeleeVulnerabilityGrade = CaelumConstants.VULNERABILITY_SENSITIVE_POINT;
            LastMeleeHitHeightRatio = 0.5;
            LastMeleeLocationMultiplier = GetVulnerabilityMultiplier(LastMeleeVulnerabilityGrade, false);
            return;
        }

        Vector2 toTarget = target.Pos.XY - Pos.XY;
        Vector2 forward = AngleToVector(attackAngle, 1.0);
        Vector2 right = AngleToVector(attackAngle + 90.0, 1.0);
        double forwardDistance = Max(0.0, toTarget.X * forward.X + toTarget.Y * forward.Y);
        double sideOffset = Abs(toTarget.X * right.X + toTarget.Y * right.Y);
        double radius = Max(1.0, target.Radius);
        double radiusForward = Sqrt(Max(0.0, radius * radius - sideOffset * sideOffset));
        double impactDistance = Max(0.0, forwardDistance - radiusForward);
        double impactZ = Pos.Z + ViewHeight - Tan(attackPitch) * impactDistance;
        LastMeleeHitHeightRatio = Clamp((impactZ - target.Pos.Z) / target.Height, 0.0, 1.0);

        double lateralRatio = Clamp(sideOffset / radius, 0.0, 1.0);
        CaelumCombatActor combatTarget = CaelumCombatActor(target);
        if (combatTarget != null)
        {
            LastMeleeVulnerabilityGrade =
                combatTarget.RegisterDirectionalAnatomyImpact(
                    self, LastMeleeHitHeightRatio
                );
            LastMeleeHitLocation = combatTarget.LastAnatomyLocation;
        }
        else if (LastMeleeHitHeightRatio >= CaelumConstants.HIT_HEAD_MINIMUM_RATIO)
        {
            LastMeleeHitLocation = CaelumConstants.HIT_LOCATION_HEAD;
            LastMeleeVulnerabilityGrade = CaelumConstants.VULNERABILITY_CRITICAL_POINT;
        }
        else if (LastMeleeHitHeightRatio >= CaelumConstants.HIT_ARMS_MINIMUM_RATIO
            && LastMeleeHitHeightRatio <= CaelumConstants.HIT_ARMS_MAXIMUM_RATIO
            && lateralRatio >= CaelumConstants.HIT_ARMS_LATERAL_RATIO)
        {
            LastMeleeHitLocation = CaelumConstants.HIT_LOCATION_ARMS;
            LastMeleeVulnerabilityGrade = CaelumConstants.VULNERABILITY_WEAK_POINT;
        }
        else if (LastMeleeHitHeightRatio >= CaelumConstants.HIT_TORSO_MINIMUM_RATIO)
        {
            LastMeleeHitLocation = CaelumConstants.HIT_LOCATION_TORSO;
            LastMeleeVulnerabilityGrade = CaelumConstants.VULNERABILITY_SENSITIVE_POINT;
        }
        else
        {
            LastMeleeHitLocation = CaelumConstants.HIT_LOCATION_LEGS;
            LastMeleeVulnerabilityGrade = CaelumConstants.VULNERABILITY_NEUTRAL_POINT;
        }

        LastMeleeLocationMultiplier = GetVulnerabilityMultiplier(
            LastMeleeVulnerabilityGrade,
            false
        );
    }

    double GetVulnerabilityMultiplier(int grade, bool criticalHit)
    {
        double normalMultiplier = CaelumConstants.VULNERABILITY_NEUTRAL_MULTIPLIER;
        switch (Clamp(grade, 0, CaelumConstants.VULNERABILITY_GRADE_COUNT - 1))
        {
            case CaelumConstants.VULNERABILITY_CRITICAL_POINT:
                normalMultiplier = CaelumConstants.VULNERABILITY_CRITICAL_MULTIPLIER;
                break;
            case CaelumConstants.VULNERABILITY_SENSITIVE_POINT:
                normalMultiplier = CaelumConstants.VULNERABILITY_SENSITIVE_MULTIPLIER;
                break;
            case CaelumConstants.VULNERABILITY_WEAK_POINT:
                normalMultiplier = CaelumConstants.VULNERABILITY_WEAK_MULTIPLIER;
                break;
            case CaelumConstants.VULNERABILITY_STRONG_POINT:
                normalMultiplier = CaelumConstants.VULNERABILITY_STRONG_MULTIPLIER;
                break;
            case CaelumConstants.VULNERABILITY_HARD_POINT:
                normalMultiplier = CaelumConstants.VULNERABILITY_HARD_MULTIPLIER;
                break;
            case CaelumConstants.VULNERABILITY_ARMORED_POINT:
                normalMultiplier = CaelumConstants.VULNERABILITY_ARMORED_MULTIPLIER;
                break;
        }

        // This interpolation reproduces every endpoint of the original
        // critical ranges while accepting the newly fixed normal values.
        if (criticalHit)
        {
            return normalMultiplier * (normalMultiplier + 1.0);
        }
        return normalMultiplier;
    }

    int GetBaseVulnerabilityForArmorSlot(int slot)
    {
        switch (slot)
        {
            case CaelumConstants.ARMOR_SLOT_HEAD:
                return CaelumConstants.VULNERABILITY_CRITICAL_POINT;
            case CaelumConstants.ARMOR_SLOT_BODY:
                return CaelumConstants.VULNERABILITY_SENSITIVE_POINT;
            case CaelumConstants.ARMOR_SLOT_HANDS:
                return CaelumConstants.VULNERABILITY_WEAK_POINT;
            default:
                return CaelumConstants.VULNERABILITY_NEUTRAL_POINT;
        }
    }

    int GetEffectiveArmorVulnerability(int slot)
    {
        if (ArmorModel == null)
        {
            return GetBaseVulnerabilityForArmorSlot(slot);
        }
        return Min(
            CaelumConstants.VULNERABILITY_ARMORED_POINT,
            GetBaseVulnerabilityForArmorSlot(slot) + ArmorModel.GetReinforcement(slot)
        );
    }

    void CycleDebugArmorSlot()
    {
        if (ArmorModel != null) { ArmorModel.CycleSelectedSlot(); }
    }

    void CycleDebugArmorType()
    {
        if (ArmorModel == null) { return; }
        PersistCharacterState();
        ArmorModel.CycleSelectedType();
        ApplyCharacterProfile();
        PersistCharacterState();
        RefreshEquipmentSelectionPreview();
    }

    void CycleDebugArmorTier()
    {
        if (ArmorModel == null) { return; }
        PersistCharacterState();
        ArmorModel.CycleSelectedTier();
        ApplyCharacterProfile();
        PersistCharacterState();
        RefreshEquipmentSelectionPreview();
    }

    void ToggleDebugArmorCritical()
    {
        DebugArmorCriticalHit = !DebugArmorCriticalHit;
    }

    void RepairDebugArmor()
    {
        if (ArmorModel != null)
        {
            ArmorModel.RepairSelectedPiece();
            ApplyCharacterProfile();
            PersistCharacterState();
            RefreshEquipmentSelectionPreview();
        }
    }

    // Applies one confirmed 1000-point hit to the selected humanoid region.
    // Vulnerability and reinforcement resolve first, defense absorbs its
    // percentage next, and only post-defense health loss enters pain logic.
    void ApplyDebugArmorHit()
    {
        ApplyDebugArmorPipeline(CaelumConstants.DEBUG_ARMOR_HIT_DAMAGE);
    }

    void ApplyDebugArmorPipeline(double incomingDamage)
    {
        LastLocalizedLucidityLoss = 0.0;
        LastArmorPreDefenseDamage = 0.0;
        LastArmorAbsorbedDamage = 0.0;
        LastArmorPostDefenseDamage = 0.0;
        LastToughnessDamageMultiplier = DerivedStats != null
            ? DerivedStats.DamageResistanceMultiplier : 1.0;
        LastArmorHealthDamage = 0;
        LastArmorDurabilityLoss = 0;
        LastArmorDurabilityChancePercent = 0.0;
        LastArmorDurabilityRollPercent = 0.0;
        LastArmorHitWasCritical = DebugArmorCriticalHit;
        if (ArmorModel == null
            || player == null
            || player.playerstate != PST_LIVE
            || health <= 1
            || incomingDamage <= 0.0)
        {
            return;
        }

        int slot = ArmorModel.SelectedSlot;
        LastArmorVulnerabilityGrade = GetEffectiveArmorVulnerability(slot);
        LastArmorVulnerabilityMultiplier = GetVulnerabilityMultiplier(
            LastArmorVulnerabilityGrade,
            DebugArmorCriticalHit
        );
        LastArmorPreDefenseDamage = incomingDamage
            * LastArmorVulnerabilityMultiplier;

        double defenseRatio = Clamp(ArmorModel.GetDefense(slot) / 100.0, 0.0, 1.0);
        LastArmorAbsorbedDamage = LastArmorPreDefenseDamage * defenseRatio;
        LastArmorPostDefenseDamage = Max(
            0.0,
            LastArmorPreDefenseDamage - LastArmorAbsorbedDamage
        );
        LastToughnessDamageMultiplier = DerivedStats != null
            ? Clamp(DerivedStats.DamageResistanceMultiplier, 0.0, 1.0)
            : 1.0;
        int calculatedHealthDamage = Max(
            0,
            int(LastArmorPostDefenseDamage
                * LastToughnessDamageMultiplier + 0.5)
        );
        LastArmorHealthDamage = Min(calculatedHealthDamage, health - 1);

        double durabilityEligibleDamage = LastArmorAbsorbedDamage
            * Max(0.0, ArmorDurabilityDamageMultiplier);
        LastArmorDurabilityLoss = int(
            durabilityEligibleDamage
                / CaelumConstants.ARMOR_ABSORBED_DAMAGE_PER_GUARANTEED_DURABILITY
        );
        double remainder = durabilityEligibleDamage
            - LastArmorDurabilityLoss
                * CaelumConstants.ARMOR_ABSORBED_DAMAGE_PER_GUARANTEED_DURABILITY;
        LastArmorDurabilityChancePercent = Clamp(
            remainder / CaelumConstants.ARMOR_DAMAGE_PER_DURABILITY_CHANCE_PERCENT,
            0.0,
            100.0
        );
        int durabilityRoll = Random[CaelumArmorDurability](0, 999999);
        LastArmorDurabilityRollPercent = durabilityRoll / 10000.0;
        if (LastArmorDurabilityRollPercent < LastArmorDurabilityChancePercent)
        {
            LastArmorDurabilityLoss++;
        }
        LastArmorDurabilityLoss = Min(
            LastArmorDurabilityLoss,
            ArmorModel.Durability[slot]
        );
        ArmorModel.Durability[slot] -= LastArmorDurabilityLoss;

        double adrenalineRatioBeforeDamage = 0.0;
        if (DerivedStats != null && DerivedStats.MaximumAdrenaline > 0.0)
        {
            adrenalineRatioBeforeDamage = Clamp(
                CurrentAdrenaline / DerivedStats.MaximumAdrenaline,
                0.0,
                1.0
            );
        }

        if (LastArmorHealthDamage > 0)
        {
            health -= LastArmorHealthDamage;
            player.health = health;
            ApplyLocalizedLucidityLoss(
                GetBaseVulnerabilityForArmorSlot(slot),
                LastArmorVulnerabilityGrade,
                DebugArmorCriticalHit,
                defenseRatio
            );
            UpdateHealthStateEffects();
            CalculateAndTriggerPain(
                LastArmorHealthDamage,
                adrenalineRatioBeforeDamage,
                true
            );
            AddCombatAdrenaline(
                CaelumConstants.ADRENALINE_GAIN_ON_DAMAGE,
                CaelumConstants.ADRENALINE_EVENT_DAMAGE
            );
            MarkCombatActivity();
        }

        if (ArmorModel.Durability[slot] <= 0)
        {
            ApplyCharacterProfile();
        }
    }

    // Any confirmed damage type can call this shared localized rule. Natural
    // anatomy decides eligibility even after reinforcement. Defense absorbs
    // the same percentage of lucidity, while reinforcement reduces a critical
    // hit's relative multiplier through the effective vulnerability grade.
    void ApplyLocalizedLucidityLoss(
        int naturalVulnerabilityGrade,
        int effectiveVulnerabilityGrade,
        bool criticalHit,
        double defenseRatio
    )
    {
        LastLocalizedLucidityLoss = 0.0;
        if (naturalVulnerabilityGrade != CaelumConstants.VULNERABILITY_CRITICAL_POINT
            || DerivedStats == null)
        {
            return;
        }

        double criticalFactor = 1.0;
        if (criticalHit)
        {
            double normalMultiplier = GetVulnerabilityMultiplier(
                effectiveVulnerabilityGrade,
                false
            );
            double criticalMultiplier = GetVulnerabilityMultiplier(
                effectiveVulnerabilityGrade,
                true
            );
            if (normalMultiplier > 0.0)
            {
                criticalFactor = criticalMultiplier / normalMultiplier;
            }
        }

        LastLocalizedLucidityLoss = Min(
            CurrentLucidity,
            CaelumConstants.CRITICAL_POINT_BASE_LUCIDITY_LOSS
                * criticalFactor
                * (1.0 - Clamp(defenseRatio, 0.0, 1.0))
                * DerivedStats.LucidityLossMultiplier
                * GetLuciditySleepDebuffMultiplier()
        );
        CurrentLucidity = Max(0.0, CurrentLucidity - LastLocalizedLucidityLoss);
        UpdateLucidityState();
    }

    // Low sleep doubles and critical sleep quadruples lucidity loss and stun
    // duration. Patience Type 3 mitigates only the harmful amount above x1.
    double GetLuciditySleepDebuffMultiplier()
    {
        double rawMultiplier = 1.0;
        if (SleepState == CaelumConstants.SURVIVAL_STATE_CRITICAL)
        {
            rawMultiplier = CaelumConstants.LUCIDITY_SLEEP_CRITICAL_INTENSITY_MULTIPLIER;
        }
        else if (SleepState == CaelumConstants.SURVIVAL_STATE_LOW)
        {
            rawMultiplier = CaelumConstants.LUCIDITY_SLEEP_LOW_INTENSITY_MULTIPLIER;
        }

        double patienceMultiplier = 1.0;
        if (DerivedStats != null)
        {
            patienceMultiplier = DerivedStats.HealthPenaltyMultiplier;
        }
        return 1.0 + (rawMultiplier - 1.0) * patienceMultiplier;
    }

    // Provisional loss validates regeneration and thresholds. Dureza is shown
    // in the panel but will be applied only to classified real loss sources.
    void LoseDebugLucidity()
    {
        CurrentLucidity = Max(
            0.0,
            CurrentLucidity - CaelumConstants.DEBUG_LUCIDITY_LOSS
        );
        UpdateLucidityState();
    }

    void RefillLucidity()
    {
        CurrentLucidity = CaelumConstants.MAXIMUM_LUCIDITY;
        UpdateLucidityState();
    }

    // Select the exact thresholds needed to inspect accuracy and visual state
    // without waiting for recovery or pressing the ten-point loss key repeatedly.
    void CycleDebugLucidityState()
    {
        if (LucidityState == CaelumConstants.LUCIDITY_STATE_NORMAL)
        {
            CurrentLucidity = CaelumConstants.MAXIMUM_LUCIDITY
                * CaelumConstants.LUCIDITY_DIZZY_THRESHOLD;
        }
        else if (LucidityState == CaelumConstants.LUCIDITY_STATE_DIZZY)
        {
            CurrentLucidity = CaelumConstants.MAXIMUM_LUCIDITY
                * CaelumConstants.LUCIDITY_STUNNED_THRESHOLD;
        }
        else
        {
            CurrentLucidity = CaelumConstants.MAXIMUM_LUCIDITY;
        }
        UpdateLucidityState();
    }

    void UpdateLucidityState()
    {
        int previousState = LucidityState;
        double ratio = CurrentLucidity / CaelumConstants.MAXIMUM_LUCIDITY;

        if (ratio <= CaelumConstants.LUCIDITY_STUNNED_THRESHOLD)
        {
            LucidityState = CaelumConstants.LUCIDITY_STATE_STUNNED;
        }
        else if (ratio <= CaelumConstants.LUCIDITY_DIZZY_THRESHOLD)
        {
            LucidityState = CaelumConstants.LUCIDITY_STATE_DIZZY;
        }
        else
        {
            LucidityState = CaelumConstants.LUCIDITY_STATE_NORMAL;
        }

        UpdateLucidityAccuracyEffects();

        // Trigger once only when entering the critical state from above. The
        // timer does not restart merely because lucidity remains at or below
        // ten percent, and it persists through ordinary saves with the player.
        if (previousState != CaelumConstants.LUCIDITY_STATE_STUNNED
            && LucidityState == CaelumConstants.LUCIDITY_STATE_STUNNED)
        {
            LucidityPhysicalStunRemaining =
                CaelumConstants.LUCIDITY_PHYSICAL_STUN_SECONDS
                    * GetLuciditySleepDebuffMultiplier();
        }
    }

    // Lucidity owns one reusable accuracy factor. Both dizzy and stunned
    // states retain 50%; the critical state additionally has its finite
    // physical immobilization when the threshold is crossed.
    void UpdateLucidityAccuracyEffects()
    {
        LucidityAccuracyMultiplier = LucidityState
            == CaelumConstants.LUCIDITY_STATE_NORMAL
            ? 1.0
            : CaelumConstants.LUCIDITY_DIZZY_ACCURACY_MULTIPLIER;

        if (DerivedStats == null)
        {
            EffectivePhysicalAccuracyPercent = 0.0;
            EffectiveMagicalAccuracyPercent = 0.0;
            return;
        }

        EffectivePhysicalAccuracyPercent = DerivedStats.PhysicalAccuracyPercent
            * LucidityAccuracyMultiplier
            * (ElementalStatus != null
                ? ElementalStatus.GetAccuracyMultiplier() : 1.0);
        EffectiveMagicalAccuracyPercent = DerivedStats.MagicalAccuracyPercent
            * LucidityAccuracyMultiplier
            * (ElementalStatus != null
                ? ElementalStatus.GetAccuracyMultiplier() : 1.0);
    }

    void UpdateLucidityPhysicalStun()
    {
        if (LucidityPhysicalStunRemaining > 0.0)
        {
            LucidityPhysicalStunRemaining = Max(
                0.0,
                LucidityPhysicalStunRemaining - 1.0 / TICRATE
            );
        }
    }

    void UpdatePainImmobilization()
    {
        if (PainImmobilizationRemaining > 0.0)
        {
            PainImmobilizationRemaining = Max(
                0.0,
                PainImmobilizationRemaining - 1.0 / TICRATE
            );
        }
    }

    int CalculateSurvivalState(double currentValue)
    {
        double ratio = currentValue / CaelumConstants.SURVIVAL_MAXIMUM;
        if (ratio <= CaelumConstants.SURVIVAL_CRITICAL_THRESHOLD)
        {
            return CaelumConstants.SURVIVAL_STATE_CRITICAL;
        }
        if (ratio <= CaelumConstants.SURVIVAL_LOW_THRESHOLD)
        {
            return CaelumConstants.SURVIVAL_STATE_LOW;
        }
        return CaelumConstants.SURVIVAL_STATE_NORMAL;
    }

    double GetSurvivalStateMultiplier(int state)
    {
        if (state == CaelumConstants.SURVIVAL_STATE_CRITICAL)
        {
            return CaelumConstants.SURVIVAL_CRITICAL_PERFORMANCE_MULTIPLIER;
        }
        if (state == CaelumConstants.SURVIVAL_STATE_LOW)
        {
            return CaelumConstants.SURVIVAL_LOW_PERFORMANCE_MULTIPLIER;
        }
        return 1.0;
    }

    // Apply base depletion time and the appropriate Type 3 loss multiplier.
    void UpdateSurvivalResources()
    {
        if (!SurvivalResourcesInitialized || DerivedStats == null)
        {
            return;
        }

        CurrentHunger = Max(0.0, CurrentHunger
            - CaelumConstants.SURVIVAL_MAXIMUM
            / (CaelumConstants.HUNGER_EMPTY_GAME_HOURS
                * CaelumConstants.REAL_SECONDS_PER_GAME_HOUR)
            * DerivedStats.HungerThirstLossMultiplier / TICRATE);
        CurrentThirst = Max(0.0, CurrentThirst
            - CaelumConstants.SURVIVAL_MAXIMUM
            / (CaelumConstants.THIRST_EMPTY_GAME_HOURS
                * CaelumConstants.REAL_SECONDS_PER_GAME_HOUR)
            * DerivedStats.HungerThirstLossMultiplier / TICRATE);
        CurrentSleep = Max(0.0, CurrentSleep
            - CaelumConstants.SURVIVAL_MAXIMUM
            / (CaelumConstants.SLEEP_EMPTY_GAME_HOURS
                * CaelumConstants.REAL_SECONDS_PER_GAME_HOUR)
            * DerivedStats.SleepLossMultiplier / TICRATE);
        UpdateSurvivalStates();
    }

    void UpdateSurvivalStates()
    {
        HungerState = CalculateSurvivalState(CurrentHunger);
        ThirstState = CalculateSurvivalState(CurrentThirst);
        SleepState = CalculateSurvivalState(CurrentSleep);
        LuciditySleepDebuffMultiplier = GetLuciditySleepDebuffMultiplier();

        SurvivalRawPerformanceMultiplier = GetSurvivalStateMultiplier(HungerState)
            * GetSurvivalStateMultiplier(ThirstState)
            * GetSurvivalStateMultiplier(SleepState);

        // Adrenaline ignores the same percentage of the missing performance
        // as its current share of maximum. Example: raw x0.50 with 50%
        // adrenaline becomes x0.75.
        AdrenalinePenaltyIgnoreRatio = 0.0;
        if (DerivedStats != null && DerivedStats.MaximumAdrenaline > 0.0)
        {
            AdrenalinePenaltyIgnoreRatio = Clamp(
                CurrentAdrenaline / DerivedStats.MaximumAdrenaline,
                0.0,
                1.0
            );
        }
        SurvivalPerformanceMultiplier = SurvivalRawPerformanceMultiplier
            + (1.0 - SurvivalRawPerformanceMultiplier)
            * AdrenalinePenaltyIgnoreRatio;
        UpdateEffectiveOffensiveDamageMultiplier();
    }

    // Patience first mitigates the harmful part of wounded states. Adrenaline
    // then restores the same share of the remaining penalty and suppresses
    // pain intensity. Beneficial adrenaline gains remain x2/x4.
    void UpdateHealthStateEffects()
    {
        double healthRatio = 1.0;
        if (CaelumMaximumHealth > 0)
        {
            healthRatio = Clamp(double(health) / CaelumMaximumHealth, 0.0, 1.0);
        }

        double rawIntensityMultiplier = 1.0;
        if (healthRatio <= CaelumConstants.HEALTH_BADLY_WOUNDED_THRESHOLD)
        {
            HealthState = CaelumConstants.HEALTH_STATE_BADLY_WOUNDED;
            HealthRawPerformanceMultiplier =
                CaelumConstants.HEALTH_BADLY_WOUNDED_PERFORMANCE_MULTIPLIER;
            rawIntensityMultiplier =
                CaelumConstants.HEALTH_BADLY_WOUNDED_INTENSITY_MULTIPLIER;
        }
        else if (healthRatio <= CaelumConstants.HEALTH_WOUNDED_THRESHOLD)
        {
            HealthState = CaelumConstants.HEALTH_STATE_WOUNDED;
            HealthRawPerformanceMultiplier =
                CaelumConstants.HEALTH_WOUNDED_PERFORMANCE_MULTIPLIER;
            rawIntensityMultiplier =
                CaelumConstants.HEALTH_WOUNDED_INTENSITY_MULTIPLIER;
        }
        else
        {
            HealthState = CaelumConstants.HEALTH_STATE_NORMAL;
            HealthRawPerformanceMultiplier = 1.0;
        }

        double adrenalineRatio = 0.0;
        if (DerivedStats != null && DerivedStats.MaximumAdrenaline > 0.0)
        {
            adrenalineRatio = Clamp(
                CurrentAdrenaline / DerivedStats.MaximumAdrenaline,
                0.0,
                1.0
            );
        }

        HealthPatienceMitigationMultiplier = 1.0;
        if (DerivedStats != null)
        {
            HealthPatienceMitigationMultiplier =
                DerivedStats.HealthPenaltyMultiplier;
        }
        HealthPatienceMitigatedPerformanceMultiplier = 1.0
            - (1.0 - HealthRawPerformanceMultiplier)
                * HealthPatienceMitigationMultiplier;
        HealthPerformanceMultiplier = HealthPatienceMitigatedPerformanceMultiplier
            + (1.0 - HealthPatienceMitigatedPerformanceMultiplier)
                * adrenalineRatio;
        HealthPainMultiplier = 1.0
            + (rawIntensityMultiplier - 1.0)
                * HealthPatienceMitigationMultiplier
                * (1.0 - adrenalineRatio);
        HealthAdrenalineGainMultiplier = rawIntensityMultiplier;
        UpdateEffectiveOffensiveDamageMultiplier();
    }

    // One stored result keeps every present and future offensive action on the
    // same rule. Health and survival are independent penalties, so they multiply.
    void UpdateEffectiveOffensiveDamageMultiplier()
    {
        EffectiveOffensiveDamageMultiplier = Clamp(
            HealthPerformanceMultiplier * SurvivalPerformanceMultiplier,
            0.0,
            1.0
        );
    }

    // Each critical resource inverts the base natural-health recovery rate.
    // Fractional damage is accumulated because GZDoom health is integer-based.
    void ApplyCriticalSurvivalDamage()
    {
        if (player == null || player.playerstate != PST_LIVE || health <= 0)
        {
            return;
        }

        int criticalResourceCount = 0;
        if (HungerState == CaelumConstants.SURVIVAL_STATE_CRITICAL) criticalResourceCount++;
        if (ThirstState == CaelumConstants.SURVIVAL_STATE_CRITICAL) criticalResourceCount++;
        if (SleepState == CaelumConstants.SURVIVAL_STATE_CRITICAL) criticalResourceCount++;
        if (criticalResourceCount <= 0)
        {
            // Do not carry a partial damage point across recovery from every
            // critical state.
            SurvivalDamageAccumulator = 0.0;
            return;
        }

        double baseDamagePerSecond = CaelumMaximumHealth
            / CaelumConstants.HEALTH_BASE_RECOVERY_REAL_SECONDS;
        SurvivalDamageAccumulator += baseDamagePerSecond
            * criticalResourceCount / TICRATE;
        int wholeDamage = int(SurvivalDamageAccumulator);
        if (wholeDamage <= 0) return;

        SurvivalDamageAccumulator -= wholeDamage;
        health -= wholeDamage;
        player.health = health;

        // Direct health loss deliberately bypasses armor and this class's
        // ordinary-damage adrenaline gain. Death still uses GZDoom's pipeline.
        if (health <= 0)
        {
            health = 0;
            player.health = 0;
            Die(self, self, 0, 'CaelumSurvival');
        }
    }

    // Natural recovery is stopped by any critical survival state. Healing uses
    // Resiliencia Tipo 4 y gasta hambre/sed segun la vida restaurada.
    void ApplyNaturalHealthRegeneration()
    {
        if (player == null
            || player.playerstate != PST_LIVE
            || health <= 0
            || health >= CaelumMaximumHealth
            || DerivedStats == null)
        {
            NaturalHealthRegenerationAccumulator = 0.0;
            return;
        }

        if (HungerState == CaelumConstants.SURVIVAL_STATE_CRITICAL
            || ThirstState == CaelumConstants.SURVIVAL_STATE_CRITICAL
            || SleepState == CaelumConstants.SURVIVAL_STATE_CRITICAL)
        {
            NaturalHealthRegenerationAccumulator = 0.0;
            return;
        }

        double hungerCostPerHealth = 100.0 / CaelumMaximumHealth;
        double thirstCostPerHealth = 50.0 / CaelumMaximumHealth;
        double affordableHealth = Min(
            CurrentHunger / hungerCostPerHealth,
            CurrentThirst / thirstCostPerHealth
        );
        if (affordableHealth <= 0.0) return;

        NaturalHealthRegenerationAccumulator += Min(
            DerivedStats.HealthRegenerationPerSecond / TICRATE,
            affordableHealth
        );
        int wholeHealing = int(NaturalHealthRegenerationAccumulator);
        wholeHealing = Min(wholeHealing, CaelumMaximumHealth - health);
        if (wholeHealing <= 0) return;

        NaturalHealthRegenerationAccumulator -= wholeHealing;
        health += wholeHealing;
        player.health = health;
        CurrentHunger = Max(0.0, CurrentHunger - wholeHealing * hungerCostPerHealth);
        CurrentThirst = Max(0.0, CurrentThirst - wholeHealing * thirstCostPerHealth);
        UpdateSurvivalStates();
    }

    // Air recovery consumes survival resources proportionally: restoring one
    // percent of maximum air costs 0.1% hunger and 0.2% thirst. If either
    // resource cannot afford the whole tic, recovery is limited to what it can
    // support instead of allowing a negative survival value.
    void ApplyAirRegeneration()
    {
        if (!AirResourceInitialized
            || DerivedStats == null
            || IsSpendingRunningAir
            || DebugShieldBlocking
            || CurrentAir >= DerivedStats.MaximumAir
            || DerivedStats.MaximumAir <= 0.0)
        {
            return;
        }

        double hungerCostPerAir =
            CaelumConstants.AIR_FULL_RECOVERY_HUNGER_COST
            / DerivedStats.MaximumAir;
        double thirstCostPerAir =
            CaelumConstants.AIR_FULL_RECOVERY_THIRST_COST
            / DerivedStats.MaximumAir;
        double affordableAir = Min(
            CurrentHunger / hungerCostPerAir,
            CurrentThirst / thirstCostPerAir
        );
        if (affordableAir <= 0.0) return;

        double recoveredAir = Min(
            DerivedStats.AirRegenerationPerSecond
                * HealthPerformanceMultiplier / TICRATE,
            DerivedStats.MaximumAir - CurrentAir
        );
        recoveredAir = Min(recoveredAir, affordableAir);
        if (recoveredAir <= 0.0) return;

        CurrentAir += recoveredAir;
        CurrentHunger = Max(
            0.0,
            CurrentHunger - recoveredAir * hungerCostPerAir
        );
        CurrentThirst = Max(
            0.0,
            CurrentThirst - recoveredAir * thirstCostPerAir
        );
        UpdateSurvivalStates();
    }

    void LoseDebugHunger() { CurrentHunger = Max(0.0, CurrentHunger - CaelumConstants.DEBUG_SURVIVAL_LOSS); UpdateSurvivalStates(); }
    void LoseDebugThirst() { CurrentThirst = Max(0.0, CurrentThirst - CaelumConstants.DEBUG_SURVIVAL_LOSS); UpdateSurvivalStates(); }
    void LoseDebugSleep() { CurrentSleep = Max(0.0, CurrentSleep - CaelumConstants.DEBUG_SURVIVAL_LOSS); UpdateSurvivalStates(); }

    void RefillSurvivalResources()
    {
        CurrentHunger = CaelumConstants.SURVIVAL_MAXIMUM;
        CurrentThirst = CaelumConstants.SURVIVAL_MAXIMUM;
        CurrentSleep = CaelumConstants.SURVIVAL_MAXIMUM;
        UpdateSurvivalStates();
    }

    // A successful jump spends five base air units. It uses the same load
    // multiplier as every other physical air-consuming action.
    void ConsumeJumpAir()
    {
        if (DerivedStats == null)
        {
            return;
        }

        double finalCost = CaelumConstants.JUMP_AIR_COST
            * DerivedStats.AirConsumptionMultiplier;
        CurrentAir = Max(0.0, CurrentAir - finalCost);
        UpdateAirStateEffects();
    }

    // Keep the temporary debug control routed through the exact same function
    // so it remains useful when testing air costs without repeatedly jumping.
    void ConsumeDebugJumpAir()
    {
        ConsumeJumpAir();
    }

    // Restore the current resource to the calculated maximum.
    void RefillAir()
    {
        if (DerivedStats != null)
        {
            CurrentAir = DerivedStats.MaximumAir;
            UpdateAirStateEffects();
        }
    }

    double GetAirRatio()
    {
        if (DerivedStats == null || DerivedStats.MaximumAir <= 0.0)
        {
            return 0.0;
        }

        return CurrentAir / DerivedStats.MaximumAir;
    }

    // Store the state and effective evasion in play scope. The UI reads these
    // fields directly, avoiding forbidden play-to-UI function calls.
    void UpdateAirStateEffects()
    {
        double ratio = GetAirRatio();

        if (ratio <= CaelumConstants.AIR_BREATHLESS_THRESHOLD)
        {
            AirState = CaelumConstants.AIR_STATE_BREATHLESS;
            AirStatePerformanceMultiplier = CaelumConstants.BREATHLESS_PERFORMANCE_MULTIPLIER;
        }
        else if (ratio <= CaelumConstants.AIR_TIRED_THRESHOLD)
        {
            AirState = CaelumConstants.AIR_STATE_TIRED;
            AirStatePerformanceMultiplier = CaelumConstants.TIRED_PERFORMANCE_MULTIPLIER;
        }
        else
        {
            AirState = CaelumConstants.AIR_STATE_NORMAL;
            AirStatePerformanceMultiplier = 1.0;
        }

        if (DerivedStats != null)
        {
            // La penalización de carga depende únicamente del porcentaje de
            // capacidad usado. 0% = 100% rendimiento; 50% = 50%;
            // 100% o más = 0%. La masa corporal absoluta no interviene.
            double loadPerformanceMultiplier = 1.0 - Clamp(
                DerivedStats.LoadRatio, 0.0, 1.0
            );

            EffectiveEvasionChance = DerivedStats.BaseEvasionChance
                * loadPerformanceMultiplier
                * AirStatePerformanceMultiplier
                * HealthPerformanceMultiplier;

            EffectiveMovementPercent = DerivedStats.BaseMovementPercent
                * loadPerformanceMultiplier
                * AirStatePerformanceMultiplier
                * SurvivalPerformanceMultiplier
                * HealthPerformanceMultiplier;

            // El salto mantiene sqrt(Tipo 1 de Agilidad), pero la penalización
            // por carga usa la misma regla porcentual nueva que el movimiento.
            double jumpAgilityTypeOnePercent =
                DerivedStats.CalculateType1Percent(Attributes.Agility);
            double jumpAgilityFactor = Sqrt(
                Max(0.0, jumpAgilityTypeOnePercent / 100.0)
            );
            EffectiveJumpHeightPercent = 100.0
                * jumpAgilityFactor
                * loadPerformanceMultiplier
                * AirStatePerformanceMultiplier
                * SurvivalPerformanceMultiplier
                * HealthPerformanceMultiplier;
        }
    }

    void CycleRace()
    {
        CharacterProfile.CycleRace();
        CharacterAllocation.ResetAllocations();
        ApplyCharacterProfile();
    }

    void CycleFirstClass() { CharacterProfile.CycleFirstClass(); CharacterAllocation.ResetAllocations(); ApplyCharacterProfile(); }
    void CycleSecondClass() { CharacterProfile.CycleSecondClass(); CharacterAllocation.ResetAllocations(); ApplyCharacterProfile(); }
    void CycleSex() { CharacterProfile.CycleSex(); ApplyCharacterProfile(); }
    void CycleHeightChoice() { CharacterProfile.CycleHeight(); ApplyCharacterProfile(); }

    void CycleAllocationLayer()
    {
        CharacterAllocation.CycleSelectedLayer();
    }

    void CycleAllocationAttribute()
    {
        CharacterAllocation.CycleSelectedAttribute();
    }

    void AddSelectedLayerPoint()
    {
        if (CharacterAllocation.TryAddSelectedLayerPoint(CharacterProfile))
        {
            ApplyCharacterProfile();
        }
    }

    void AddSelectedAttributePoint()
    {
        if (CharacterAllocation.TryAddSelectedAttributePoint(CharacterProfile))
        {
            ApplyCharacterProfile();
        }
    }

    void ResetCreationAllocations()
    {
        CharacterAllocation.ResetAllocations();
        ApplyCharacterProfile();
    }

    // Toggle a reversible development override. The normal creation profile
    // and point allocation remain untouched and return when toggled off.
    void ToggleDebugAttributes75()
    {
        DebugAttributesAt75 = !DebugAttributesAt75;
        if (DebugAttributesAt75) { DebugAttributesAt100 = false; }
        ApplyCharacterProfile();
        UpdateAirStateEffects();
    }

    // La opcion de 100 es independiente pero excluyente para evitar dos
    // sustituciones simultaneas del mismo perfil.
    void ToggleDebugAttributes100()
    {
        DebugAttributesAt100 = !DebugAttributesAt100;
        if (DebugAttributesAt100) { DebugAttributesAt75 = false; }
        ApplyCharacterProfile();
        UpdateAirStateEffects();
    }

    // Add five provisional weight units and refresh all derived mass values.
    void AddDebugEquipmentWeight()
    {
        if (DerivedStats == null)
        {
            return;
        }

        DerivedStats.AddDebugWeight(CaelumConstants.DEBUG_WEIGHT_STEP);
        ApplyCharacterProfile();
    }

    // Clear provisional equipment weight without changing character creation.
    void ResetDebugEquipmentWeight()
    {
        if (DerivedStats == null)
        {
            return;
        }

        DerivedStats.ResetDebugWeight();
        ApplyCharacterProfile();
    }

    void BeginCreationWizard()
    {
        if (CreationWizardOpen)
        {
            // El creador inicial es obligatorio y no puede cerrarse sin confirmar.
            if (CharacterCreationComplete)
            {
                CancelCreationWizard();
            }
            return;
        }

        CreationProfileBackup = CaelumCharacterProfile(new("CaelumCharacterProfile"));
        CreationProfileBackup.CopyFrom(CharacterProfile);

        CreationAllocationBackup = CaelumCharacterAllocation(new("CaelumCharacterAllocation"));
        CreationAllocationBackup.CopyFrom(CharacterAllocation);

        CreationWizardPage = CaelumConstants.CREATION_PAGE_RACE;
        CreationWizardOpen = true;
    }

    void CancelCreationWizard()
    {
        if (!CharacterCreationComplete)
        {
            return;
        }

        if (CreationProfileBackup != null && CreationAllocationBackup != null)
        {
            CharacterProfile.CopyFrom(CreationProfileBackup);
            CharacterAllocation.CopyFrom(CreationAllocationBackup);
            ApplyCharacterProfile();
        }

        CreationWizardOpen = false;
    }

    // Change the choice represented by the current wizard page.
    void CycleCurrentCreationChoice()
    {
        switch (CreationWizardPage)
        {
            case CaelumConstants.CREATION_PAGE_RACE:
                CycleRace();
                break;
            case CaelumConstants.CREATION_PAGE_FIRST_CLASS:
                CycleFirstClass();
                break;
            case CaelumConstants.CREATION_PAGE_SECOND_CLASS:
                CycleSecondClass();
                break;
            case CaelumConstants.CREATION_PAGE_SEX:
                CycleSex();
                break;
            case CaelumConstants.CREATION_PAGE_HEIGHT:
                CycleHeightChoice();
                break;
            case CaelumConstants.CREATION_PAGE_LAYERS:
                CycleAllocationLayer();
                break;
            case CaelumConstants.CREATION_PAGE_ATTRIBUTES:
                CycleAllocationAttribute();
                break;
        }
    }

    void AddCurrentCreationPoint()
    {
        if (CreationWizardPage == CaelumConstants.CREATION_PAGE_LAYERS)
        {
            AddSelectedLayerPoint();
        }
        else if (CreationWizardPage == CaelumConstants.CREATION_PAGE_ATTRIBUTES)
        {
            AddSelectedAttributePoint();
        }
    }

    int GetStartingArmorTypeForProfession(int profession)
    {
        if (profession == CaelumConstants.PROFESSION_WARRIOR)
        {
            return CaelumConstants.ARMOR_TYPE_HEAVY;
        }
        if (profession == CaelumConstants.PROFESSION_MERCENARY
            || profession == CaelumConstants.PROFESSION_CLERIC
            || profession == CaelumConstants.PROFESSION_BATTLE_MAGE)
        {
            return CaelumConstants.ARMOR_TYPE_MEDIUM;
        }
        if (profession == CaelumConstants.PROFESSION_EXPLORER
            || profession == CaelumConstants.PROFESSION_PILGRIM
            || profession == CaelumConstants.PROFESSION_INVESTIGATOR)
        {
            return CaelumConstants.ARMOR_TYPE_LIGHT;
        }
        return CaelumConstants.ARMOR_TYPE_MAGIC;
    }

    int GetStartingShieldTypeForProfession(int profession)
    {
        if (profession == CaelumConstants.PROFESSION_WARRIOR)
        {
            return CaelumConstants.SHIELD_TYPE_TOWER;
        }
        if (profession == CaelumConstants.PROFESSION_MERCENARY
            || profession == CaelumConstants.PROFESSION_CLERIC
            || profession == CaelumConstants.PROFESSION_BATTLE_MAGE)
        {
            return CaelumConstants.SHIELD_TYPE_KITE;
        }
        if (profession == CaelumConstants.PROFESSION_EXPLORER
            || profession == CaelumConstants.PROFESSION_PILGRIM
            || profession == CaelumConstants.PROFESSION_INVESTIGATOR)
        {
            return CaelumConstants.SHIELD_TYPE_BUCKLER;
        }
        return CaelumConstants.SHIELD_TYPE_MAGIC;
    }

    Vector3 GetStartingPickupPosition(int index)
    {
        int row = index / 3;
        int column = index % 3;
        double forwardDistance = 56.0 + row * 30.0;
        double sideDistance = (column - 1) * 30.0;
        return Pos + (
            Cos(Angle) * forwardDistance
                - Sin(Angle) * sideDistance,
            Sin(Angle) * forwardDistance
                + Cos(Angle) * sideDistance,
            8.0
        );
    }

    void SpawnStartingDevelopmentEquipment()
    {
        CaelumPersistentCharacterState persistentState =
            GetPersistentCharacterState(true);
        if (persistentState != null)
        {
            persistentState.NativeEquipmentMigrationComplete = true;
        }
        int startingSize = CaelumEquipmentRules.GetDefaultSizeForCharacterTier(
            CharacterProfile.GetSizeTier()
        );
        int profession = CharacterProfile.GetProfession();
        int armorType = GetStartingArmorTypeForProfession(profession);
        int shieldType = GetStartingShieldTypeForProfession(profession);

        // La ropa inicial deja de aparecer como pickups al terminar la
        // creación. El modelo interno conserva ropa base neutra hasta que el
        // jugador equipe una pieza real.
        for (int slot = 0; slot < CaelumConstants.ARMOR_SLOT_COUNT; slot++)
        {
            ArmorModel.ArmorType[slot] =
                CaelumConstants.ARMOR_TYPE_BASE_CLOTHING;
            ArmorModel.Tier[slot] = 1;
            ArmorModel.Size[slot] = CaelumConstants.EQUIPMENT_SIZE_M;
            ArmorModel.Durability[slot] = 0;
        }

        // La creación ya no genera equipo físico alrededor del jugador.
        // Armaduras, escudos, armas y munición se obtienen posteriormente
        // mediante pickups, crafting u otras fuentes del mundo.
        ShieldModel.Equipped = false;
        CancelCombatBlockMode();
        CombatChannelModeActive = false;
        WeaponModel.Equipped = false;
        EnsureWeaponFamilySelectors();
        ApplyCharacterProfile();
        RefreshEquipmentSelectionPreview();
    }

    // Compatibilidad con el flujo de confirmación existente.
    void GrantStartingDevelopmentEquipment()
    {
        SpawnStartingDevelopmentEquipment();
        return;
        if (CharacterProfile == null || ArmorModel == null
            || ShieldModel == null || WeaponModel == null)
        {
            return;
        }
        CaelumPersistentCharacterState persistentState =
            GetPersistentCharacterState(true);
        if (persistentState == null) { return; }
        persistentState.EnsureEquipmentSizeInitialized();

        int startingSize = CaelumEquipmentRules.GetDefaultSizeForCharacterTier(
            CharacterProfile.GetSizeTier()
        );
        int profession = CharacterProfile.GetProfession();
        int armorType = GetStartingArmorTypeForProfession(profession);
        int shieldType = GetStartingShieldTypeForProfession(profession);

        for (int slot = 0; slot < CaelumConstants.ARMOR_SLOT_COUNT; slot++)
        {
            ArmorModel.ArmorType[slot] = armorType;
            ArmorModel.Tier[slot] = 1;
            ArmorModel.Size[slot] = startingSize;
            ArmorModel.Durability[slot] = ArmorModel.GetMaximumDurability(slot);
            persistentState.RegisterOwnedArmor(
                slot, armorType, 1, startingSize, ArmorModel.Durability[slot]
            );
            persistentState.SetArmorInMagicBox(
                slot, armorType, 1, startingSize, false
            );
        }
        ArmorModel.SelectedSlot = CaelumConstants.ARMOR_SLOT_HEAD;

        ShieldModel.ShieldType = shieldType;
        ShieldModel.Tier = 1;
        ShieldModel.Size = startingSize;
        ShieldModel.Durability = ShieldModel.GetMaximumDurability();
        ShieldModel.Equipped = true;
        ShieldModel.EquippedStateInitialized = true;
        persistentState.RegisterOwnedShield(
            shieldType, 1, startingSize, ShieldModel.Durability
        );
        persistentState.SetShieldInMagicBox(shieldType, 1, startingSize, false);

        WeaponModel.WeaponType = CaelumConstants.WEAPON_TYPE_SWORD;
        WeaponModel.Tier = 1;
        WeaponModel.Size = startingSize;
        WeaponModel.Durability = WeaponModel.GetMaximumDurability();
        WeaponModel.Equipped = true;
        for (int weaponType = 0; weaponType < 3; weaponType++)
        {
            int durability = WeaponModel.GetMaximumDurabilityFor(
                weaponType, 1, startingSize
            );
            persistentState.RegisterOwnedWeapon(
                weaponType, 1, startingSize, durability
            );
            persistentState.SetWeaponInMagicBox(
                weaponType, 1, startingSize, false
            );
            persistentState.SetWeaponEquipped(
                weaponType, 1, startingSize,
                weaponType == CaelumConstants.WEAPON_TYPE_SWORD
            );
        }
        EnsureWeaponFamilySelectors();
        Inventory carbineAmmo = FindInventory("CaelumCarbineAmmo");
        if (carbineAmmo == null)
        {
            carbineAmmo = GiveInventoryType("CaelumCarbineAmmo");
        }
        if (carbineAmmo != null)
        {
            carbineAmmo.Amount = Min(
                carbineAmmo.MaxAmount,
                CaelumConstants.WEAPON_CARBINE_STARTING_AMMO
            );
        }

        EquippedWeaponBaseWeight = WeaponModel.GetTierOneWeightFor(
            WeaponModel.WeaponType
        );
        EquippedWeaponTier = 1;
        EquippedWeaponSize = startingSize;
        WeaponWeightInitialized = true;
        ApplyCharacterProfile();
        RefreshEquipmentSelectionPreview();
    }

    void AdvanceCreationWizard()
    {
        if (!CreationWizardOpen)
        {
            return;
        }

        // Depuración salta directamente al resumen: 30 en los doce atributos,
        // 1,8 m y 100 kg base, sin asignación manual.
        if (CreationWizardPage == CaelumConstants.CREATION_PAGE_RACE
            && CharacterProfile.Race == CaelumConstants.RACE_DEBUG)
        {
            CreationWizardPage = CaelumConstants.CREATION_PAGE_SUMMARY;
            ApplyCharacterProfile();
            return;
        }

        // Every one of the four free layer points must be assigned.
        if (CreationWizardPage == CaelumConstants.CREATION_PAGE_LAYERS
            && CharacterAllocation.GetRemainingLayerPoints() > 0)
        {
            return;
        }

        // Every one of the thirty individual points must be assigned.
        if (CreationWizardPage == CaelumConstants.CREATION_PAGE_ATTRIBUTES
            && CharacterAllocation.GetRemainingAttributePoints() > 0)
        {
            return;
        }

        if (CreationWizardPage < CaelumConstants.CREATION_PAGE_SUMMARY)
        {
            CreationWizardPage++;
            return;
        }

        // Confirmar por primera vez inicia todos los recursos con el perfil final.
        bool firstConfirmation = !CharacterCreationComplete;
        CharacterCreationComplete = true;
        CreationProfileBackup = null;
        CreationAllocationBackup = null;
        CreationWizardOpen = false;
        ApplyCharacterProfile();

        if (firstConfirmation)
        {
            GrantStartingDevelopmentEquipment();
            CaelumMaximumHealth = Max(1, int(DerivedStats.MaximumHealth));
            health = CaelumMaximumHealth;
            if (player != null) { player.health = health; }
            CurrentAnima = DerivedStats.MaximumAnima;
            CurrentAir = DerivedStats.MaximumAir;
            CurrentAdrenaline = 0.0;
            CurrentLucidity = CaelumConstants.MAXIMUM_LUCIDITY;
            RefillSurvivalResources();
            HealthResourceInitialized = true;
            AnimaResourceInitialized = true;
            AirResourceInitialized = true;
            AdrenalineResourceInitialized = true;
            LucidityResourceInitialized = true;
            UpdateHealthStateEffects();
            UpdateAirStateEffects();
            UpdateLucidityState();
        }
        PersistCharacterState();
        RefreshEquipmentSelectionPreview();
    }

    void GoBackCreationWizard()
    {
        if (!CreationWizardOpen)
        {
            return;
        }

        if (CreationWizardPage == CaelumConstants.CREATION_PAGE_SUMMARY
            && CharacterProfile.Race == CaelumConstants.RACE_DEBUG)
        {
            CreationWizardPage = CaelumConstants.CREATION_PAGE_RACE;
        }
        else if (CreationWizardPage > CaelumConstants.CREATION_PAGE_RACE)
        {
            CreationWizardPage--;
        }
        else
        {
            // En la creación inicial la primera página es el límite de retroceso.
            if (CharacterCreationComplete)
            {
                CancelCreationWizard();
            }
        }
    }
}
