// CaelumPlayer is the base class for every playable character.
//
// It currently inherits DoomPlayer so that Doom II's temporary weapons,
// animations, sounds, and inventory remain usable during early development.
// These inherited resources will be replaced by original assets later.
class CaelumPlayer : DoomPlayer
{
    bool ThermalBluntDelivery;
    const FORMAL_INVENTORY_VISIBLE_ROWS = 6;
    const FORMAL_INVENTORY_FILTER_COUNT = 10;

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
    // Total monetario poseído. La Caja Mágica conserva el valor y reduce el
    // peso mediante su cálculo agregado, igual que con cualquier otra pila.
    int HUDCopperCoinCount;
    int HUDSilverCoinCount;
    int HUDGoldCoinCount;
    double HUDTotalMoneyCopperValue;
    // Copias simples para que el HUD pueda leer el arma activa sin invocar
    // funciones de play scope desde el contexto de interfaz.
    bool HUDHasActiveWeapon;
    String HUDInteractionHint;
    int HUDActiveWeaponType;
    int HUDActiveWeaponTier;
    int HUDActiveWeaponSize;
    int HUDActiveWeaponEssenceType;
    bool HUDActiveWeaponIsRanged;
    int HUDRangedMagazineCount;
    int HUDRangedMagazineCapacity;
    int HUDRangedReserveCount;
    bool HUDCombatBlockActive;
    bool HUDHasActiveBlockSource;
    bool HUDCombatBlockUsesGauntlets;
    int HUDActiveShieldType;
    bool HUDHasEquippedSeal;
    bool HUDSealChannelAvailable;
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
    bool MagicBoxOwned;
    bool EquipmentMenuOpen;
    bool CraftingMenuOpen;
    transient CaelumCraftingBrowser CraftingBrowser;
    bool PalomoMerchantMenuOpen;
    CaelumCityTradeSession CityTrade;
    int WorldCarbineShotUntil;
    bool PalomoMerchantDiscountGranted;
    bool PalomoMerchantReputationDiscount;
    CaelumFactionCondition ActivePalomoMerchantRequirement;
    CaelumFactionCondition ActivePalomoMerchantDiscountCondition;
    String PalomoMerchantTitleKey;
    int PalomoDiscountChancePercent;
    int PalomoDiscountLastRoll;
    bool PalomoDiscountAutomaticSuccess;
    Actor ActivePalomoMerchant;
    int PalomoMerchantSessionValidationTics;
    int PalomoMerchantSelection;
    int PalomoMerchantMode;
    int PalomoMerchantQuantityIndex;
    int PalomoMerchantSelectedQuantity;
    int PalomoMerchantSelectedLotPrice;
    int PalomoMerchantWalletCopper;
    int PalomoMerchantStock[CaelumConstants.PALOMO_MERCHANT_ITEM_COUNT];
    int PalomoMerchantPlayerOwned[CaelumConstants.PALOMO_MERCHANT_ITEM_COUNT];
    int PalomoMerchantVisibleItemCount;
    int PalomoMerchantVisibleItems[CaelumConstants.PALOMO_MERCHANT_ITEM_COUNT];
    int LastPalomoMerchantAction;

    // Instantánea simple para el Diario. La interfaz sólo lee estos campos y
    // nunca invoca funciones de inventario de ámbito play durante el render.
    int JournalKnownQuestCount;
    bool JournalQuestRewardClaimed[CaelumConstants.QUEST_DEFINED_COUNT];
    bool JournalQuestCanStart[CaelumConstants.QUEST_DEFINED_COUNT];
    bool JournalQuestReady[CaelumConstants.QUEST_DEFINED_COUNT];
    int JournalQuestState[CaelumConstants.QUEST_DEFINED_COUNT];
    int JournalQuestStage[CaelumConstants.QUEST_DEFINED_COUNT];
    bool JournalQuestObjectiveKnown[
        CaelumConstants.QUEST_JOURNAL_OBJECTIVE_STORAGE_COUNT
    ];
    int JournalQuestObjectiveProgress[
        CaelumConstants.QUEST_JOURNAL_OBJECTIVE_STORAGE_COUNT
    ];
    int JournalQuestObjectiveTarget[
        CaelumConstants.QUEST_JOURNAL_OBJECTIVE_STORAGE_COUNT
    ];
    int JournalPalomoPlacement;
    // Estado transitorio de presentación. El progreso autoritativo vive en
    // CaelumPersistentCharacterState y el controlador lo reconstruye al cargar.
    CaelumDemoVoiceSpeaker DemoVoiceSpeaker;
    String DemoVoiceMap;
    int BullNarrativeSeveritySnapshot[4];
    bool PalomoSleepLessonCompleteSnapshot;
    bool PalomoSleepLessonStartedSnapshot;
    Actor MainM00UnknownVoiceSpeaker;
    int MainM00UnknownVoiceDelayTics;
    bool MainM00AwakeningVisualStarted;
    bool JournalFactionMember[CaelumConstants.FACTION_COUNT];
    int JournalFactionReputation[CaelumConstants.FACTION_COUNT];
    bool JournalReputationTrialEnabled;
    // Plan transaccional temporal. Contiene el saldo físico final por
    // denominación y permite validar peso/slots antes de mutar inventario.
    int PalomoCurrencyPlanAmount[CaelumConstants.CURRENCY_TYPE_COUNT];
    bool PalomoCurrencyPlanInMagicBox[CaelumConstants.CURRENCY_TYPE_COUNT];
    bool PalomoIncomingItemInMagicBox;
    int ActiveCraftingStationType;
    Actor ActiveCraftingStationActor;
    int CraftingSessionValidationTics;
    bool CraftingTaskProgressing;

    // Estado de la red de infraestructura detectada al interactuar.
    int CraftingNetworkCapabilities;
    int CraftingNetworkScanToken;
    bool CraftingSelectedInfrastructureAvailable;
    int CraftingMissingStationType;

    int CraftingSelectionRecipe;
    int CraftingSelectionTier;
    int CraftingSelectionSize;
    int CraftingSelectedWeapon;
    int CraftingRecipeFilter;
    bool CraftingSelectedRecipeKnown;
    int CraftingKnownRecipeCount;
    int CraftingKnownPhysicalRecipeCount;
    int CraftingKnownArmorRecipeCount;
    int CraftingKnownShieldRecipeCount;
    int CraftingKnownEssenceRecipeCount;
    int CraftingKnownAmuletRecipeCount;
    int CraftingKnownSealRecipeCount;
    int CraftingKnownProcessingRecipeCount;
    int CraftingKnownComponentRecipeCount;

    // Estado de la receta unificada actualmente seleccionada.
    int CraftingSelectedRecipeKind;
    int CraftingSelectedArmorType;
    int CraftingSelectedArmorSlot;
    int CraftingSelectedShieldType;
    int CraftingSelectedEssenceWeaponType;
    int CraftingSelectedEssenceType;
    int CraftingSelectedAmuletType;
    int CraftingSelectedSealType;
    int CraftingSelectedProcessingRecipe;
    int CraftingProcessingBatchIndex;
    int CraftingProcessingBatchMultiplier;
    int CraftingEfficiencyIndex;
    int CraftingEfficiencyPercent;
    double CraftingPreviewSeconds;
    bool CraftingDirectPlanAvailable;
    bool CraftingDirectPlanUsed;
    int CraftingDirectPlanStepCount;
    int CraftingPreparedEquipmentInputUnits;
    int CraftingLayerChoiceRootRecipe;
    int CraftingLayerChoiceRootTier;
    int CraftingLayerChoiceRootSize;
    int CraftingLayerChoiceCount;
    int CraftingLayerChoiceRecipe[CaelumConstants.CRAFTING_LAYER_CHOICE_SLOT_COUNT];
    int CraftingLayerChoiceTier[CaelumConstants.CRAFTING_LAYER_CHOICE_SLOT_COUNT];
    int CraftingLayerChoiceEfficiency[CaelumConstants.CRAFTING_LAYER_CHOICE_SLOT_COUNT];
    int CraftingPlanReservedType[CaelumConstants.CRAFTING_TASK_MATERIAL_SLOT_COUNT];
    int CraftingPlanReservedTier[CaelumConstants.CRAFTING_TASK_MATERIAL_SLOT_COUNT];
    int CraftingPlanReservedUnits[CaelumConstants.CRAFTING_TASK_MATERIAL_SLOT_COUNT];
    int CraftingPlanStepRecipe[CaelumConstants.CRAFTING_DIRECT_STEP_SLOT_COUNT];
    int CraftingPlanStepTier[CaelumConstants.CRAFTING_DIRECT_STEP_SLOT_COUNT];
    int CraftingPlanStepEfficiency[CaelumConstants.CRAFTING_DIRECT_STEP_SLOT_COUNT];
    int CraftingPlanStepInputUnits[CaelumConstants.CRAFTING_DIRECT_STEP_SLOT_COUNT];
    int CraftingPlanStepComplexityTics[CaelumConstants.CRAFTING_DIRECT_STEP_SLOT_COUNT];
    double CraftingPlanStepSeconds[CaelumConstants.CRAFTING_DIRECT_STEP_SLOT_COUNT];

    // Árbol de receta aplanado para que UI scope pueda mostrar cada capa sin
    // ejecutar lógica de inventario. El nodo cero es siempre el montaje final.
    int CraftingBlueprintNodeCount;
    int CraftingBlueprintSelectedNode;
    int CraftingBlueprintNodeKind[CaelumConstants.CRAFTING_BLUEPRINT_NODE_SLOT_COUNT];
    int CraftingBlueprintNodeDepth[CaelumConstants.CRAFTING_BLUEPRINT_NODE_SLOT_COUNT];
    int CraftingBlueprintNodeRecipe[CaelumConstants.CRAFTING_BLUEPRINT_NODE_SLOT_COUNT];
    int CraftingBlueprintNodeMaterialType[CaelumConstants.CRAFTING_BLUEPRINT_NODE_SLOT_COUNT];
    int CraftingBlueprintNodeMaterialTier[CaelumConstants.CRAFTING_BLUEPRINT_NODE_SLOT_COUNT];
    int CraftingBlueprintNodeUnits[CaelumConstants.CRAFTING_BLUEPRINT_NODE_SLOT_COUNT];
    int CraftingBlueprintNodeOwnedUnits[CaelumConstants.CRAFTING_BLUEPRINT_NODE_SLOT_COUNT];
    int CraftingBlueprintNodeInputUnits[CaelumConstants.CRAFTING_BLUEPRINT_NODE_SLOT_COUNT];
    int CraftingBlueprintNodeEfficiency[CaelumConstants.CRAFTING_BLUEPRINT_NODE_SLOT_COUNT];
    int CraftingBlueprintNodeComplexityTics[CaelumConstants.CRAFTING_BLUEPRINT_NODE_SLOT_COUNT];
    double CraftingBlueprintNodeSeconds[CaelumConstants.CRAFTING_BLUEPRINT_NODE_SLOT_COUNT];
    bool CraftingBlueprintNodeExecuted[CaelumConstants.CRAFTING_BLUEPRINT_NODE_SLOT_COUNT];
    double CraftingBlueprintFullSeconds;
    int CraftingOutputMaterialType;
    int CraftingOutputMaterialTier;
    int CraftingOutputAmount;
    String CraftingPreviewIconPath;

    int CraftingBasicMaterialType;
    int CraftingBasicMaterialTier;
    int CraftingBasicRequired;
    int CraftingBasicOwned;
    int CraftingTierMaterialType;
    int CraftingTierMaterialTier;
    int CraftingTierRequired;
    int CraftingTierOwned;
    int CraftingSilverRequired;
    int CraftingSilverOwned;
    int CraftingGoldRequired;
    int CraftingGoldOwned;
    double CraftingFinalWeight;
    int LastCraftingAction;

    // Una tarea en curso conserva selección, red, reservas y salidas. Los
    // datos simples son serializables por GZDoom y además se espejan al
    // registro viajero para cambios de mapa.
    bool CraftingTaskActive;
    bool CraftingTaskCompleting;
    int CraftingTaskKind;
    int CraftingTaskRecipeIndex;
    int CraftingTaskTier;
    int CraftingTaskSize;
    int CraftingTaskBatchIndex;
    int CraftingTaskEfficiencyIndex;
    int CraftingTaskTargetItemId;
    int CraftingTaskNetworkCapabilities;
    int CraftingTaskReservedBoxSlots;
    bool CraftingTaskUsesDirectPlan;
    bool CraftingTaskUsesLimboMaterials;
    double CraftingTaskTotalSeconds;
    double CraftingTaskRemainingSeconds;
    int CraftingTaskReservedType[CaelumConstants.CRAFTING_TASK_MATERIAL_SLOT_COUNT];
    int CraftingTaskReservedTier[CaelumConstants.CRAFTING_TASK_MATERIAL_SLOT_COUNT];
    int CraftingTaskReservedUnits[CaelumConstants.CRAFTING_TASK_MATERIAL_SLOT_COUNT];
    int CraftingTaskOutputType[CaelumConstants.CRAFTING_TASK_MATERIAL_SLOT_COUNT];
    int CraftingTaskOutputTier[CaelumConstants.CRAFTING_TASK_MATERIAL_SLOT_COUNT];
    int CraftingTaskOutputUnits[CaelumConstants.CRAFTING_TASK_MATERIAL_SLOT_COUNT];
    // El selector heredado describe una combinación de catálogo. Cuando este
    // campo es mayor que cero, las acciones formales apuntan en cambio a una
    // instancia exacta y no a la primera pieza de igual tipo.
    int EquipmentSelectionItemId;
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
    String MainM00LoadoutDescriptions[49];
    String MainM00LoadoutStats[49];
    String MainM00LoadoutSummary;
    String MainM00NecklaceStatus;
    String MainM00AmuletLessonText;
    transient int MainM00NecklaceMenuRequest;
    transient Actor MainM00NecklaceMenuSpeaker;
    double EquipmentSelectionAirCost;
    double EquipmentSelectionAnimaCost;
    int EquipmentSelectionAttackTics;
    int EquipmentSelectionStackAmount;
    int MagicBoxUsedSlots;
    int MagicBoxMaximumSlots;
    double HUDMagicBoxRawContentWeight;
    double HUDMagicBoxReducedContentWeight;
    double HUDMagicBoxTotalWeight;
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

    // Referencias persistentes a las piezas que alimentan los modelos activos.
    // Evitan que dos objetos idénticos compartan accidentalmente durabilidad.
    int EquippedArmorItemId[4];
    int EquippedShieldItemId;
    int ActiveWeaponItemId;
    int HUDActiveWeaponItemId;
    int EquippedAmuletItemId;
    int EquippedSealItemId;

    // Instantánea plana para la página formal del Diario. La interfaz sólo lee
    // valores simples; toda enumeración y toda mutación permanecen en play.
    int FormalInventoryFilter;
    int FormalInventorySelectionIndex;
    int FormalInventoryEntryCount;
    int FormalInventoryVisibleStart;
    int FormalInventoryRowKind[FORMAL_INVENTORY_VISIBLE_ROWS];
    int FormalInventoryRowType[FORMAL_INVENTORY_VISIBLE_ROWS];
    int FormalInventoryRowArmorSlot[FORMAL_INVENTORY_VISIBLE_ROWS];
    int FormalInventoryRowTier[FORMAL_INVENTORY_VISIBLE_ROWS];
    int FormalInventoryRowSize[FORMAL_INVENTORY_VISIBLE_ROWS];
    int FormalInventoryRowEssenceType[FORMAL_INVENTORY_VISIBLE_ROWS];
    int FormalInventoryRowAmount[FORMAL_INVENTORY_VISIBLE_ROWS];
    int FormalInventoryRowItemId[FORMAL_INVENTORY_VISIBLE_ROWS];
    int FormalInventoryRowDurability[FORMAL_INVENTORY_VISIBLE_ROWS];
    int FormalInventoryRowMaximumDurability[FORMAL_INVENTORY_VISIBLE_ROWS];
    double FormalInventoryRowWeight[FORMAL_INVENTORY_VISIBLE_ROWS];
    bool FormalInventoryRowEquipped[FORMAL_INVENTORY_VISIBLE_ROWS];
    bool FormalInventoryRowInMagicBox[FORMAL_INVENTORY_VISIBLE_ROWS];
    int FormalInventoryRowReservedUnits[FORMAL_INVENTORY_VISIBLE_ROWS];

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

    // Instantáneas de sólo lectura para Diario y conversaciones sociales.
    bool JournalMainM00ArgentoStarted;
    int MainM00ConvincedCountSnapshot;
    int MainM00MagicPracticeSnapshot;
    int MainM00RuneSequenceSnapshot;
    bool MainM00SealRecipesSnapshot;
    int MainM00SealsPreparedSnapshot;
    int MainM00ChosenSealSnapshot;
    int MainM00ChosenAmuletSnapshot;
    bool MainM00AmuletPreparedSnapshot;
    bool MainM00WaterGivenSnapshot;
    bool MainM00WaterFilledSnapshot;
    bool MainM00WaterDrankSnapshot;
    double FormalInventoryRowWaterLiters[FORMAL_INVENTORY_VISIBLE_ROWS];
    int MainM00ArmorTypeSnapshot;
    int MainM00ArmorPiecesSnapshot;
    int MainM00StarterOptionSnapshot;
    int MainM00StarterSizeSnapshot;
    int MainM00StarterWeaponSnapshot;
    bool MainM00RonnieFinishedSnapshot;
    bool MainM00SwimLessonStartedSnapshot;
    bool MainM00SwimLessonSubmergedSnapshot;
    bool MainM00SwimLessonCompleteSnapshot;
    bool MainM00LoadLessonStartedSnapshot;
    bool MainM00LoadLessonCompleteSnapshot;
    double MainM00LoadWeightSnapshot;
    double MainM00LoadCapacitySnapshot;
    double MainM00LoadAirFactorSnapshot;
    bool MainM00AirLessonStartedSnapshot;
    bool MainM00AirLessonRanSnapshot;
    bool MainM00AirLessonCompleteSnapshot;
    bool MainM00NeedsLessonStartedSnapshot;
    bool MainM00NeedsFoodUsedSnapshot;
    bool MainM00NeedsWaterUsedSnapshot;
    bool MainM00RepairLessonOfferedSnapshot;
    bool MainM00RepairLessonCompleteSnapshot;
    int MainM00StarterRequiredSnapshot[CaelumConstants.MATERIAL_TYPE_COUNT];
    int MainM00StarterMissingSnapshot[CaelumConstants.MATERIAL_TYPE_COUNT];
    int MainM00SupplySnapshot[6];
    bool JournalMainM00MagicPracticeDone[5];
    int MainM00SocialChanceSnapshot[CaelumConstants.MAIN_M00_RESIDENT_COUNT];
    double MainM00LabiaSnapshot;
    // Se rearma únicamente tras cerrar toda interacción folclórica y soltar
    // físicamente Use. Evita que Q cierre y reabra a Palomo en el mismo pulso.
    bool FolkloreInteractionUseLatched;
    int FolkloreInteractionReleaseGuardTics;

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
    int StandardBowMagazine; // Legado: las flechas siguen en su pila original.
    int ShotgunRevision,ShotgunLoadedMask,ShotgunLastBarrel;
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
    transient bool RangedAimSecondaryLatched;
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
    int TarotOwnedCountSnapshot;
    bool TarotSelectedSnapshot[CaelumConstants.TAROT_CARD_COUNT];
    int TarotAttributeBonusSnapshot;
    int AttributeBalanceVersion;
    double TarotMinorBaseSnapshot[CaelumConstants.PRIMARY_ATTRIBUTE_COUNT];
    bool TarotFoolOwnedSnapshot;
    bool TarotCupsAceOwnedSnapshot;
    bool TarotOwnedSnapshot[CaelumConstants.TAROT_CARD_COUNT];
    bool MainM00FoolRevealedSnapshot;
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
    int LowHealthHeartbeatTimer;
    bool LowHealthHeartbeatActive;

    // Stored diagnostic values expose the latest real-damage pain calculation
    // without changing its result. They also survive saves with the player.
    double LastHealthLossPercent;
    double LastPainChancePercent;
    bool LastPainTriggered;

    // Latest isolated melee test data shown by the development panel.
    double LastMeleeCalculatedDamage;
    int LastMeleeActualDamage;
    int LastMeleeSweepHitCount;
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
    int ImpactDiagnosticCollisionCallbacks;
    int ImpactDiagnosticUniquePairTicks;
    int ImpactDiagnosticDuplicateCallbacks;
    int ImpactDiagnosticRestingCallbacks;
    int ImpactDiagnosticContactsCreated;
    int ImpactDiagnosticContactsRemoved;
    ImpactBody ImpactSelfBodyScratch;
    ImpactBody ImpactOtherBodyScratch;
    ImpactResult ImpactResultScratch;

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
    int ForcedSleepTics;
    double ClassSleepCooldownRemaining;
    bool ClassSleepInputLatched;
    bool JournalMainM00RuloPracticeDone[6];
    int MainM00RuloPracticeSnapshot;
    bool MainM00BullDefeatedSnapshot;
    bool MainM00BullStartedSnapshot;
    bool MainM00SilverKeySnapshot;

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
    double LastMovementNoiseEventRange;
    double MovementNoiseTimer;
    int LastMovementNoiseEventTic;
    int MovementNoiseEventSerial;
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
    // Estado respiratorio submarino separado de los umbrales normales de
    // cansancio. La deuda recuerda únicamente el Aire perdido sin respirar.
    int UnderwaterNoBreathTics;
    int UnderwaterDrowningTics;
    double UnderwaterAirRecoveryDebt;
    int UnderwaterAirRecoveryTicsRemaining;
    double UnderwaterCurrentBaseCostPerSecond;
    bool UnderwaterWithoutOxygen;
    bool UnderwaterAirRecoveryAppliedThisTick;
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

        // Declara de nuevo los StartItem para reemplazar la lista heredada de
        // DoomPlayer. Entregar y retirar Pistol dentro de GiveDefaultInventory
        // dejaba PendingWeapon en WP_NOCHANGE durante PlayerReborn; el motor
        // copiaba luego ese centinela a ReadyWeapon y lo trataba como un arma.
        Player.StartItem "CaelumUnarmedWeapon";

        // Prefijo facial propio para evitar resolver iconos/rostros heredados de Doom.
        Player.Face "CAF";

        // Domingo reemplaza la apariencia mundial heredada de DoomPlayer. El
        // rango 0,0 conserva su paleta original. "None" elimina PLYC; la
        // locomoción agachada usa los estados RSDO de UpdateCrouchVisual.
        Scale 0.409091;
        Player.CrouchSprite "None";
        Player.ColorRange 0, 0;

        // Caelum performs one custom pain roll after engine mitigation. This
        // disables DoomPlayer's independent native roll and prevents duplicates.
        PainChance 0;
        // The selected pain cue is emitted once by the custom roll; silence
        // DoomPlayer's inherited gender sound so the two never overlap.
        PainSound "";

    }

    // Las poses sentada/acostada quedan listas para el sistema de descanso.
    States
    {
    Spawn:
        DOID A 10;
        Goto IdleBreathing;
    See:
        DOWK AB 4;
        Loop;
    Missile:
        DOMI CDEFGHIJ 2;
        Goto Spawn;
    Melee:
        DOMI KLMNOPQ 2;
        Goto Spawn;
    Pain:
        DOMI A 4;
        DOMI A 4 A_Pain;
        Goto Spawn;
    Death:
        DOMI S 8;
        DOMI T 8 A_PlayerScream;
        DOMI U 8;
        DOMI V 8 A_NoBlocking;
        DOMI WXY 8;
        DOMI Z -1;
        Stop;
    XDeath:
        Goto Death;
    Raise:
        DOMI ZYXWVUTS 5;
        Goto Spawn;
    RestSeated:
        RSDO A -1;
        Stop;
    RestLying:
        RSDO B -1;
        Stop;
    CrouchIdle:
        RSDO C -1;
        Stop;
    CrouchWalk:
        RSDO DEFG 6;
        Loop;

    // Estados nuevos al final: conservan los índices de partidas anteriores.
    IdleBreathing:
        DOID AAA 10;
        DOID BBBB 10;
        Goto Spawn;
    Run:
        DORN ABCD 3;
        Loop;
    }

    CaelumPersistentCharacterState GetPersistentCharacterState(bool createState)
    {
        if (!CaelumPlayerAuthority.CanRead(self)) return null;
        CaelumPersistentCharacterState persistentState = CaelumPersistentCharacterState(
            FindInventory("CaelumPersistentCharacterState")
        );
        if (persistentState != null && persistentState.Owner != self) return null;
        if (persistentState == null && createState && CaelumPlayerAuthority.CanMutate(self))
        {
            persistentState = CaelumPersistentCharacterState(
                GiveInventoryType("CaelumPersistentCharacterState")
            );
        }
        return persistentState;
    }

    void RefreshSocialJournalSnapshot()
    {
        CaelumPlayerPresentation.RefreshSocialJournalSnapshot(self);
    }

    bool HasMainM00Flag(int flagId)
    {
        CaelumPersistentCharacterState persistentState =
            GetPersistentCharacterState(true);
        if (persistentState == null) { return false; }
        return persistentState.HasMainM00Flag(flagId);
    }

    bool BeginMainM00Prologue()
    {
        CaelumPersistentCharacterState persistentState =
            GetPersistentCharacterState(true);
        if (persistentState == null) { return false; }
        bool changed = persistentState.BeginMainM00Prologue();
        RefreshSocialJournalSnapshot();
        if (changed) { PersistCharacterState(); }
        return changed;
    }

    bool RecordMainM00UnknownVoiceHeard()
    {
        CaelumPersistentCharacterState persistentState =
            GetPersistentCharacterState(true);
        if (persistentState == null) { return false; }
        bool changed = persistentState.RecordMainM00UnknownVoiceHeard();
        RefreshSocialJournalSnapshot();
        if (changed) { PersistCharacterState(); }
        return changed;
    }

    bool RecordMainM00PalomoDialogueFlag(int flagId)
    {
        CaelumPersistentCharacterState persistentState =
            GetPersistentCharacterState(true);
        if (persistentState == null) { return false; }
        bool changed = persistentState.RecordMainM00PalomoDialogueFlag(flagId);
        SyncPalomoDialogueTokens();
        if (changed) { PersistCharacterState(); }
        return changed;
    }

    bool RecordMainM00PalomoMet()
    {
        CaelumPersistentCharacterState persistentState =
            GetPersistentCharacterState(true);
        if (persistentState == null) { return false; }
        bool changed = persistentState.RecordMainM00PalomoMet();
        SyncPalomoDialogueTokens();
        RefreshSocialJournalSnapshot();
        if (changed)
        {
            PersistCharacterState();
            Console.Printf(
                "%s",
                StringTable.Localize("CA_Q_M01_OBJ_TALK_ARGENTO", false)
            );
        }
        return changed;
    }

    bool SetPlayerFactionMembership(int factionId, bool isMember)
    {
        CaelumPersistentCharacterState persistentState =
            GetPersistentCharacterState(true);
        if (persistentState == null) { return false; }
        bool changed = persistentState.SetFactionMembership(
            factionId, isMember
        );
        RefreshSocialJournalSnapshot();
        if (changed) { PersistCharacterState(); }
        return changed;
    }

    bool ChangePlayerFactionReputation(int factionId, int amount)
    {
        CaelumPersistentCharacterState persistentState =
            GetPersistentCharacterState(true);
        if (persistentState == null) { return false; }
        bool changed = persistentState.ChangeFactionReputation(
            factionId, amount
        );
        RefreshSocialJournalSnapshot();
        if (changed) { PersistCharacterState(); }
        return changed;
    }

    int GetPrisonerRescueState(int prisonerId)
    {
        CaelumPersistentCharacterState persistentState =
            GetPersistentCharacterState(true);
        if (persistentState == null) { return CaelumConstants.PRISONER_STATE_CAPTIVE; }
        return persistentState.GetPrisonerRescueState(prisonerId);
    }

    bool SetPlayerPrisonerRescueState(int prisonerId, int nextState)
    {
        CaelumPersistentCharacterState persistentState =
            GetPersistentCharacterState(true);
        if (persistentState == null) { return false; }
        CaelumDemoNarrative.EnsureRevision(persistentState);
        bool changed = persistentState.SetPrisonerRescueState(
            prisonerId, nextState
        );
        if (changed) { PersistCharacterState(); }
        return changed;
    }

    bool IsPlayerPrisonerRewardClaimed(int prisonerId)
    {
        CaelumPersistentCharacterState persistentState =
            GetPersistentCharacterState(true);
        if (persistentState == null) { return false; }
        return persistentState.IsPrisonerRewardClaimed(prisonerId);
    }

    bool ClaimPrisonerPortReward(int prisonerId, int factionId)
    {
        CaelumPersistentCharacterState persistentState =
            GetPersistentCharacterState(true);
        if (persistentState == null || player == null || health <= 0
            || persistentState.GetPrisonerRescueState(prisonerId)
                != CaelumConstants.PRISONER_STATE_EXTRACTED
            || persistentState.IsPrisonerRewardClaimed(prisonerId))
        {
            return false;
        }

        for (int currencyRoute = 0; currencyRoute < 2; currencyRoute++)
        {
            if (!BuildPalomoCurrencyCreditPlan(
                CaelumConstants.PRISONER_RESCUE_COPPER_REWARD))
            {
                return false;
            }
            if (currencyRoute == 1)
            {
                if (!MagicBoxOwned) { continue; }
                RoutePalomoCurrencyGainsToMagicBox();
            }
            double personalDelta = GetPalomoCurrencyPlanPersonalWeightDelta();
            double boxRawDelta = GetPalomoCurrencyPlanBoxRawWeightDelta();
            int boxSlotDelta = GetPalomoCurrencyPlanBoxSlotDelta();
            if (!PalomoTransactionCapacityFits(
                personalDelta, boxRawDelta, boxSlotDelta))
            {
                continue;
            }
            if (!ApplyPalomoCurrencyPlan()) { return false; }
            CaelumDemoNarrative.EnsureRevision(persistentState);
            persistentState.MarkPrisonerRewardClaimed(prisonerId);
            persistentState.ChangeFactionReputation(
                factionId, CaelumConstants.PRISONER_RESCUE_REPUTATION_GAIN);
            RefreshSocialJournalSnapshot();
            PersistCharacterState();
            CaelumNotifications.Notify(self,
                StringTable.Localize("CA_PRISONER_REWARD_RECEIVED", false));
            return true;
        }
        CaelumNotifications.Notify(self,
            StringTable.Localize("CA_PRISONER_REWARD_CAPACITY_FAIL", false));
        return false;
    }

    void ResetPlayerFactionStateForDebug()
    {
        CaelumPersistentCharacterState persistentState =
            GetPersistentCharacterState(true);
        if (persistentState == null) { return; }
        persistentState.InitializeNewFactionState();
        RefreshSocialJournalSnapshot();
        PersistCharacterState();
    }

    void SyncLiveMagicBoxOwnershipFromPersistentState()
    {
        CaelumInventoryService.SyncLiveMagicBoxOwnershipFromPersistentState(self);
    }

    // Un perfil sin la recompensa nunca puede conservar banderas de contenido
    // oculto. También sanea partidas de desarrollo creadas a mitad del cambio.
    void NormalizeUnownedMagicBoxStorage()
    {
        CaelumInventoryService.NormalizeUnownedMagicBoxStorage(self);
    }

    bool GrantMagicBoxFromPalomo(bool announce = true)
    {
        return CaelumInventoryService.GrantMagicBoxFromPalomo(self, announce);
    }

    void SetPalomoDialogueToken(
        class<Inventory> tokenClass, bool shouldHave
    )
    {
        Inventory token = FindInventory(tokenClass);
        if (shouldHave)
        {
            if (token == null) { GiveInventoryType(tokenClass); }
            else if (token.Amount <= 0) { token.Amount = 1; }
        }
        else if (token != null && token.Amount > 0)
        {
            TakeInventory(tokenClass, token.Amount);
        }
    }

    void RefreshPalomoDiscountOdds()
    {
        double dialogueSkill = Attributes == null ? 0.0
            : Attributes.Eloquence * (Attributes.Eloquence + 1) / 101.0;
        if (DerivedStats != null)
        {
            dialogueSkill = DerivedStats.DialogueSkillPercent;
        }
        PalomoDiscountAutomaticSuccess = dialogueSkill
            >= CaelumConstants.PALOMO_DIALOGUE_DIFFICULTY;
        PalomoDiscountChancePercent = PalomoDiscountAutomaticSuccess ? 100
            : Clamp(int(
                dialogueSkill * 100.0
                    / CaelumConstants.PALOMO_DIALOGUE_DIFFICULTY
            ), 0, 100);
    }

    // Mantiene los marcadores invisibles que el USDF nativo usa para sus
    // saltos, requisitos y exclusiones. El estado autoritativo sigue en el
    // registro persistente del personaje, no en el actor de Palomo.
    void SyncPalomoDialogueTokens()
    {
        CaelumPersistentCharacterState persistentState =
            GetPersistentCharacterState(true);
        if (persistentState == null) { return; }
        persistentState.EnsureMagicBoxOwnershipInitialized();
        persistentState.EnsurePalomoDiscountInitialized();
        persistentState.EnsureQuestStateInitialized();
        PalomoMerchantDiscountGranted =
            persistentState.PalomoDiscountGranted;

        SetPalomoDialogueToken(
            "CaelumMagicBoxOwnershipToken", MagicBoxOwned
        );
        SetPalomoDialogueToken("CaelumMainM00MagicBoxGrantedToken",
            persistentState.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_MAGIC_BOX_GRANTED)
                && MagicBoxOwned);
        SetPalomoDialogueToken(
            "CaelumPalomoDiscountGrantedToken",
            PalomoMerchantDiscountGranted
        );
        SetPalomoDialogueToken(
            "CaelumPalomoEloquenceEligibleToken",
            Attributes != null && Attributes.Eloquence
                > CaelumConstants.PALOMO_DISCOUNT_MINIMUM_ELOQUENCE
        );
        SetPalomoDialogueToken(
            "CaelumMainM00PalomoMetToken",
            persistentState.HasMainM00Flag(
                CaelumConstants.MAIN_M00_FLAG_PALOMO_MET
            )
        );
        SetPalomoDialogueToken(
            "CaelumMainM00AskedPalomoWhereToken",
            persistentState.HasMainM00Flag(
                CaelumConstants.MAIN_M00_FLAG_ASKED_PALOMO_WHERE
            )
        );
        SetPalomoDialogueToken(
            "CaelumMainM00AskedPalomoWhatHappenedToken",
            persistentState.HasMainM00Flag(
                CaelumConstants.MAIN_M00_FLAG_ASKED_PALOMO_WHAT_HAPPENED
            )
        );
        SetPalomoDialogueToken(
            "CaelumMainM00NoticedMemoryGapToken",
            persistentState.HasMainM00Flag(
                CaelumConstants.MAIN_M00_FLAG_NOTICED_MEMORY_GAP
            )
        );
        SetPalomoDialogueToken(
            "CaelumMainM00ToldPalomoAboutVoiceToken",
            persistentState.HasMainM00Flag(
                CaelumConstants.MAIN_M00_FLAG_TOLD_PALOMO_ABOUT_VOICE
            )
        );
        RefreshPalomoDiscountOdds();
    }

    bool OpenMainM00UnknownVoiceDialogue()
    {
        if (CreationWizardOpen || health <= 0
            || HasMainM00Flag(
                CaelumConstants.MAIN_M00_FLAG_UNKNOWN_VOICE_HEARD
            ))
        {
            return false;
        }

        Actor voice = Spawn(
            "CaelumUnknownVoiceSpeaker", Pos, NO_REPLACE
        );
        if (voice == null) { return false; }
        Level.ExecuteSpecial(
            CaelumConstants.GZDOOM_THING_SET_CONVERSATION_SPECIAL,
            voice, null, false,
            0, CaelumConstants.MAIN_M00_UNKNOWN_VOICE_CONVERSATION_ID
        );
        if (!voice.HasConversation())
        {
            voice.Destroy();
            return false;
        }
        if (!voice.StartConversation(self, false, false))
        {
            voice.Destroy();
            return false;
        }

        MainM00UnknownVoiceSpeaker = voice;
        CaelumUnknownVoiceSpeaker prologueVoice =
            CaelumUnknownVoiceSpeaker(voice);
        if (prologueVoice != null) { prologueVoice.MarkConversationOpened(); }
        RecordMainM00UnknownVoiceHeard();
        return true;
    }

    // CA_M01QuestController llama a esta reconstrucción sin conservar estado de
    // misión propio. Una carga antes de la Voz reanuda el fundido; una carga
    // posterior nunca repite la conversación ni adelanta otra etapa.
    void UpdateMainM00Prologue()
    {
        if (level.MapName != "MAP01" || !CharacterCreationComplete
            || CreationWizardOpen || player == null
            || player.playerstate != PST_LIVE || health <= 0)
        {
            return;
        }

        CaelumPersistentCharacterState persistentState =
            GetPersistentCharacterState(true);
        if (persistentState == null) { return; }
        persistentState.EnsureQuestStateInitialized();

        if (persistentState.BeginMainM00Prologue())
        {
            RefreshSocialJournalSnapshot();
            PersistCharacterState();
        }

        int questStage = persistentState.QuestStage[
            CaelumConstants.QUEST_MAIN_M00_THE_FOOL
        ];
        if (questStage != CaelumConstants.MAIN_M00_STATE_AWAKENED
            || persistentState.HasMainM00Flag(
                CaelumConstants.MAIN_M00_FLAG_UNKNOWN_VOICE_HEARD
            ))
        {
            return;
        }

        if (!MainM00AwakeningVisualStarted)
        {
            MainM00AwakeningVisualStarted = true;
            MainM00UnknownVoiceDelayTics =
                CaelumConstants.MAIN_M00_UNKNOWN_VOICE_DELAY_TICS;
            A_SetBlend(
                Color(0, 0, 0), 1.0,
                CaelumConstants.MAIN_M00_AWAKEN_FADE_TICS,
                Color(0, 0, 0), 0.0
            );
            A_StartSound(
                "caelum/ui/map_transition", CHAN_7,
                CHANF_LOCAL | CHANF_UI, 0.25, ATTN_NONE
            );
            return;
        }

        if (MainM00UnknownVoiceDelayTics > 0)
        {
            MainM00UnknownVoiceDelayTics--;
            return;
        }
        if (MainM00UnknownVoiceSpeaker == null)
        {
            OpenMainM00UnknownVoiceDialogue();
        }
    }

    // ConversationNPC puede conservar al interlocutor después de cerrar USDF.
    // La referencia por sí sola no significa que el jugador siga dialogando.
    bool HasActiveConversation()
    {
        return player != null && player.ConversationNPC != null
            && player.ConversationNPC.bInConversation;
    }

    bool OpenPalomoDialogue(Actor speaker)
    {
        if (CreationWizardOpen || !CharacterCreationComplete || speaker == null || health <= 0)
        {
            return false;
        }
        CaelumPersistentCharacterState persistentState =
            GetPersistentCharacterState(true);
        if (persistentState == null
            || !persistentState.HasMainM00Flag(
                CaelumConstants.MAIN_M00_FLAG_UNKNOWN_VOICE_HEARD
            ))
        {
            return false;
        }
        let palomo = CaelumPalomo(speaker);
        if (palomo == null || player == null || speaker.bInConversation) return false;
        if (palomo.NarrativeRevealRequired && (Abs(palomo.Pos.Z-Pos.Z) > 48
            || Distance2D(palomo) > CaelumConstants.PALOMO_MERCHANT_SESSION_DISTANCE
            || !CheckSight(palomo))) return false;
        int conversationId = CaelumConstants.PALOMO_CONVERSATION_ID;
        if (palomo.NarrativeRevealRequired && palomo.IsNarrativeFoyerComplete())
        {
            if (!palomo.DepartureDone) return false;
            bool finalStage = persistentState.CanReceiveMainM00MagicBox()
                || persistentState.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_MAGIC_BOX_GRANTED);
            conversationId = persistentState.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_THE_FOOL_CAPTURED)
                && persistentState.HasTarotCard(CaelumConstants.TAROT_THE_FOOL)
                ? CaelumConstants.MAIN_M00_PALOMO_FOOL_CONVERSATION_ID
                : finalStage ? CaelumConstants.MAIN_M00_PALOMO_FINAL_CONVERSATION_ID
                    : CaelumConstants.MAIN_M00_PALOMO_WAIT_CONVERSATION_ID;
        }
        if (conversationId == CaelumConstants.MAIN_M00_PALOMO_WAIT_CONVERSATION_ID)
            conversationId = CaelumMainM00Loadout.CONVERSATION;
        CaelumMainM00Loadout.Refresh(self);
        SyncPalomoDialogueTokens();
        CaelumMainM00RonnieTrial.Sync(self);
        CaelumDemoNarrative.Sync(self);
        if (StaffCastPending) { CancelPendingStaffCast(false); }
        EquipmentMenuOpen = false;
        CloseCraftingStationSession();
        if (PalomoMerchantMenuOpen) { ClosePalomoMerchant(); }
        SetCraftingJournalState(false);

        // Thing_SetConversation asigna temporalmente el USDF registrado sólo
        // a este actor. StartConversation abre luego el menú nativo del motor.
        Level.ExecuteSpecial(
            CaelumConstants.GZDOOM_THING_SET_CONVERSATION_SPECIAL,
            speaker, null, false,
            0, conversationId
        );
        if (!speaker.HasConversation()) { return false; }
        if (!speaker.StartConversation(self, true, true)) { return false; }
        // La primera charla tras seguirlo arriba entrega el mazo, antes de
        // elegir equipo o recibir la Caja. Una charla fallida no da premios.
        // Grant conserva identidad y permite reintentar si falta capacidad.
        if (level.MapName == "MAP01" && palomo.NarrativeRevealRequired
            && palomo.DepartureDone
            && persistentState.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_PALOMO_MET))
            CaelumTarotDeckRules.Grant(self);
        return true;
    }

    bool ResolvePalomoDiscountRequest()
    {
        SyncPalomoDialogueTokens();
        if (PalomoMerchantDiscountGranted) { return true; }
        if (Attributes == null || Attributes.Eloquence
            <= CaelumConstants.PALOMO_DISCOUNT_MINIMUM_ELOQUENCE)
        {
            return false;
        }

        RefreshPalomoDiscountOdds();
        PalomoDiscountLastRoll = PalomoDiscountAutomaticSuccess ? 0
            : Random[CaelumPalomoDiscount](1, 100);
        bool success = PalomoDiscountAutomaticSuccess
            || PalomoDiscountLastRoll <= PalomoDiscountChancePercent;
        if (!success) { return false; }

        CaelumPersistentCharacterState persistentState =
            GetPersistentCharacterState(true);
        if (persistentState == null) { return false; }
        persistentState.EnsurePalomoDiscountInitialized();
        persistentState.PalomoDiscountGranted = true;
        PalomoMerchantDiscountGranted = true;
        SetPalomoDialogueToken(
            "CaelumPalomoDiscountGrantedToken", true
        );
        PersistCharacterState();
        return true;
    }

    int ReadNewCharacterDraft(Name setting, int fallback)
    {
        return CaelumPlayerCharacter.ReadNewCharacterDraft(self, setting, fallback);
    }

    int ReadNewCharacterLayer(int layer)
    {
        return CaelumPlayerCharacter.ReadNewCharacterLayer(self, layer);
    }

    int ReadNewCharacterAttribute(int attribute)
    {
        return CaelumPlayerCharacter.ReadNewCharacterAttribute(self, attribute);
    }

    bool NewCharacterDraftIsReady()
    {
        return CaelumPlayerCharacter.NewCharacterDraftIsReady(self);
    }

    void ClearNewCharacterDraftReady()
    {
        CaelumPlayerCharacter.ClearNewCharacterDraftReady(self);
    }

    bool ValidateLoadedNewCharacterDraft()
    {
        return CaelumPlayerCharacter.ValidateLoadedNewCharacterDraft(self);
    }

    bool ConsumeNewCharacterDraft()
    {
        return CaelumPlayerCharacter.ConsumeNewCharacterDraft(self);
    }

    // `map MAPxx` comienza una partida distinta y no atraviesa el menú. Este
    // perfil completo mantiene las pruebas reproducibles sin volver a abrir un
    // asistente dentro de MAP01 o MAP02.
    void InitializeDirectMapCharacter()
    {
        CaelumPlayerCharacter.InitializeDirectMapCharacter(self);
    }

    void StoreCraftingTaskState(
        CaelumPersistentCharacterState persistentState
    )
    {
        if (persistentState == null) { return; }
        persistentState.CraftingTaskActive = CraftingTaskActive;
        persistentState.CraftingTaskKind = CraftingTaskKind;
        persistentState.CraftingTaskRecipeIndex = CraftingTaskRecipeIndex;
        persistentState.CraftingTaskTier = CraftingTaskTier;
        persistentState.CraftingTaskSize = CraftingTaskSize;
        persistentState.CraftingTaskBatchIndex = CraftingTaskBatchIndex;
        persistentState.CraftingTaskEfficiencyIndex =
            CraftingTaskEfficiencyIndex;
        persistentState.CraftingTaskTargetItemId = CraftingTaskTargetItemId;
        persistentState.CraftingTaskNetworkCapabilities =
            CraftingTaskNetworkCapabilities;
        persistentState.CraftingTaskReservedBoxSlots =
            CraftingTaskReservedBoxSlots;
        persistentState.CraftingTaskUsesDirectPlan =
            CraftingTaskUsesDirectPlan;
        persistentState.CraftingTaskUsesLimboMaterials = CraftingTaskUsesLimboMaterials;
        persistentState.CraftingTaskTotalSeconds = CraftingTaskTotalSeconds;
        persistentState.CraftingTaskRemainingSeconds =
            CraftingTaskRemainingSeconds;
        for (int slot = 0;
            slot < CaelumConstants.CRAFTING_TASK_MATERIAL_SLOT_COUNT; slot++)
        {
            persistentState.CraftingTaskReservedType[slot] =
                CraftingTaskReservedType[slot];
            persistentState.CraftingTaskReservedTier[slot] =
                CraftingTaskReservedTier[slot];
            persistentState.CraftingTaskReservedUnits[slot] =
                CraftingTaskReservedUnits[slot];
            persistentState.CraftingTaskOutputType[slot] =
                CraftingTaskOutputType[slot];
            persistentState.CraftingTaskOutputTier[slot] =
                CraftingTaskOutputTier[slot];
            persistentState.CraftingTaskOutputUnits[slot] =
                CraftingTaskOutputUnits[slot];
        }
    }

    void LoadCraftingTaskState(
        CaelumPersistentCharacterState persistentState
    )
    {
        if (persistentState == null) { return; }
        CraftingTaskActive = persistentState.CraftingTaskActive;
        CraftingTaskKind = persistentState.CraftingTaskKind;
        CraftingTaskRecipeIndex = persistentState.CraftingTaskRecipeIndex;
        CraftingTaskTier = persistentState.CraftingTaskTier;
        CraftingTaskSize = persistentState.CraftingTaskSize;
        CraftingTaskBatchIndex = persistentState.CraftingTaskBatchIndex;
        CraftingTaskEfficiencyIndex =
            persistentState.CraftingTaskEfficiencyIndex;
        CraftingTaskTargetItemId = persistentState.CraftingTaskTargetItemId;
        CraftingTaskNetworkCapabilities =
            persistentState.CraftingTaskNetworkCapabilities;
        CraftingTaskReservedBoxSlots =
            persistentState.CraftingTaskReservedBoxSlots;
        CraftingTaskUsesDirectPlan =
            persistentState.CraftingTaskUsesDirectPlan;
        CraftingTaskUsesLimboMaterials = persistentState.CraftingTaskUsesLimboMaterials;
        CraftingTaskTotalSeconds = persistentState.CraftingTaskTotalSeconds;
        CraftingTaskRemainingSeconds =
            persistentState.CraftingTaskRemainingSeconds;
        for (int slot = 0;
            slot < CaelumConstants.CRAFTING_TASK_MATERIAL_SLOT_COUNT; slot++)
        {
            CraftingTaskReservedType[slot] =
                persistentState.CraftingTaskReservedType[slot];
            CraftingTaskReservedTier[slot] =
                persistentState.CraftingTaskReservedTier[slot];
            CraftingTaskReservedUnits[slot] =
                persistentState.CraftingTaskReservedUnits[slot];
            CraftingTaskOutputType[slot] =
                persistentState.CraftingTaskOutputType[slot];
            CraftingTaskOutputTier[slot] =
                persistentState.CraftingTaskOutputTier[slot];
            CraftingTaskOutputUnits[slot] =
                persistentState.CraftingTaskOutputUnits[slot];
        }
        CraftingTaskCompleting = false;
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
        RepairActiveEquipmentItemReferences();
        CaelumPersistentCharacterState persistentState = GetPersistentCharacterState(true);
        if (persistentState == null) { return; }
        persistentState.EnsureMagicBoxOwnershipInitialized();
        persistentState.MagicBoxOwned = MagicBoxOwned;
        persistentState.EnsurePalomoDiscountInitialized();
        persistentState.PalomoDiscountGranted =
            PalomoMerchantDiscountGranted;
        persistentState.EnsureQuestStateInitialized();
        persistentState.EnsureFactionStateInitialized();
        persistentState.EnsureEquipmentSizeInitialized();
        persistentState.MigrateWeaponDurability();
        persistentState.EnsureRecipeBookInitialized();
        RefreshCraftingRecipeBookSummary();
        StoreCraftingTaskState(persistentState);

        persistentState.ProfileCommitted = true;
        persistentState.Race = CharacterProfile.Race;
        persistentState.FirstClass = CharacterProfile.FirstClass;
        persistentState.SecondClass = CharacterProfile.SecondClass;
        persistentState.Sex = CharacterProfile.Sex;
        persistentState.HeightChoice = CharacterProfile.HeightChoice;
        for (int activeArmorSlot = 0;
            activeArmorSlot < CaelumConstants.ARMOR_SLOT_COUNT;
            activeArmorSlot++)
        {
            persistentState.EquippedArmorItemId[activeArmorSlot] =
                EquippedArmorItemId[activeArmorSlot];
        }
        persistentState.EquippedShieldItemId = EquippedShieldItemId;
        persistentState.ActiveWeaponItemId = ActiveWeaponItemId;
        persistentState.EquippedAmuletItemId = EquippedAmuletItemId;
        persistentState.EquippedSealItemId = EquippedSealItemId;
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
        persistentState.StoredUnderwaterNoBreathTics =
            UnderwaterNoBreathTics;
        persistentState.StoredUnderwaterAirRecoveryDebt =
            UnderwaterAirRecoveryDebt;
        persistentState.StoredUnderwaterAirRecoveryTicsRemaining =
            UnderwaterAirRecoveryTicsRemaining;
        persistentState.StoredAdrenaline = CurrentAdrenaline;
        persistentState.StoredLucidity = CurrentLucidity;
        persistentState.StoredHunger = CurrentHunger;
        persistentState.StoredThirst = CurrentThirst;
        persistentState.StoredSleep = CurrentSleep;
        let starter = FindNativeEquipmentItemById(persistentState.MainM00StarterWeaponId);
        if (starter != null && starter.EquipmentKind == CaelumConstants.EQUIPMENT_KIND_WEAPON)
        {
            persistentState.MainM00StarterConditionKnown = true;
            persistentState.MainM00StarterDurability = starter.Durability;
        }
        RefreshSocialJournalSnapshot();
    }

    bool RestorePersistentCharacterState()
    {
        CaelumPersistentCharacterState persistentState = GetPersistentCharacterState(false);
        if (persistentState == null || !persistentState.ProfileCommitted) { return false; }
        persistentState.EnsureMagicBoxOwnershipInitialized();
        MagicBoxOwned = persistentState.MagicBoxOwned;
        persistentState.EnsurePalomoDiscountInitialized();
        PalomoMerchantDiscountGranted =
            persistentState.PalomoDiscountGranted;
        persistentState.EnsureQuestStateInitialized();
        persistentState.EnsureFactionStateInitialized();
        persistentState.EnsureEquipmentSizeInitialized();
        persistentState.MigrateWeaponDurability();
        persistentState.EnsureRecipeBookInitialized();
        RefreshCraftingRecipeBookSummary();
        LoadCraftingTaskState(persistentState);

        CharacterProfile.Race = persistentState.Race;
        CharacterProfile.FirstClass = persistentState.FirstClass;
        CharacterProfile.SecondClass = persistentState.SecondClass;
        CharacterProfile.Sex = persistentState.Sex;
        CharacterProfile.HeightChoice = persistentState.HeightChoice;
        for (int activeArmorSlot = 0;
            activeArmorSlot < CaelumConstants.ARMOR_SLOT_COUNT;
            activeArmorSlot++)
        {
            EquippedArmorItemId[activeArmorSlot] =
                persistentState.EquippedArmorItemId[activeArmorSlot];
        }
        EquippedShieldItemId = persistentState.EquippedShieldItemId;
        ActiveWeaponItemId = persistentState.ActiveWeaponItemId;
        EquippedAmuletItemId = persistentState.EquippedAmuletItemId;
        EquippedSealItemId = persistentState.EquippedSealItemId;
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
        RepairActiveEquipmentItemReferences();
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
        UnderwaterNoBreathTics = Max(
            0, persistentState.StoredUnderwaterNoBreathTics
        );
        UnderwaterAirRecoveryDebt = Max(
            0.0, persistentState.StoredUnderwaterAirRecoveryDebt
        );
        UnderwaterAirRecoveryTicsRemaining = Max(
            0, persistentState.StoredUnderwaterAirRecoveryTicsRemaining
        );
        UnderwaterCurrentBaseCostPerSecond =
            CaelumConstants.UNDERWATER_AIR_INITIAL_COST_PER_SECOND;
        UnderwaterWithoutOxygen = WaterLevel >= 3;
        UnderwaterAirRecoveryAppliedThisTick = false;
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
        RefreshSocialJournalSnapshot();
        return true;
    }

    CaelumEquipmentItem FindNativeEquipmentItem(
        int kind, int itemType, int armorSlot, int tier, int equipmentSize
    )
    {
        return CaelumInventoryService.FindNativeEquipmentItem(self, kind, itemType, armorSlot, tier, equipmentSize);
    }

    CaelumEquipmentItem FindNativeMagicWeaponItem(
        int weaponType, int essenceType, int tier, int equipmentSize
    )
    {
        return CaelumInventoryService.FindNativeMagicWeaponItem(self, weaponType, essenceType, tier, equipmentSize);
    }

    CaelumEquipmentItem FindNativeEquipmentItemById(int itemId)
    {
        return CaelumInventoryService.FindNativeEquipmentItemById(self, itemId);
    }

    CaelumEquipmentItem FindOtherNativeEquipmentItemById(
        int itemId, CaelumEquipmentItem excludedItem
    )
    {
        return CaelumInventoryService.FindOtherNativeEquipmentItemById(self, itemId, excludedItem);
    }

    int EnsureEquipmentItemId(CaelumEquipmentItem item)
    {
        return CaelumInventoryService.EnsureEquipmentItemId(self, item);
    }

    void EnsureAllEquipmentItemIds()
    {
        CaelumInventoryService.EnsureAllEquipmentItemIds(self);
    }

    CaelumEquipmentItem FindEquippedNativeEquipmentItem(
        int kind, int itemType, int armorSlot, int tier, int equipmentSize,
        int essenceType = -1
    )
    {
        return CaelumInventoryService.FindEquippedNativeEquipmentItem(self, kind, itemType, armorSlot, tier, equipmentSize, essenceType);
    }

    void RepairActiveEquipmentItemReferences()
    {
        CaelumInventoryService.RepairActiveEquipmentItemReferences(self);
    }

    bool HasEquippedNativeWeaponType(int weaponType)
    {
        return CaelumInventoryService.HasEquippedNativeWeaponType(self, weaponType);
    }


    bool HasEquippedNativeMagicWeapon(
        int weaponType, int essenceType, int tier
    )
    {
        return CaelumInventoryService.HasEquippedNativeMagicWeapon(self, weaponType, essenceType, tier);
    }

    bool ActivateEquippedMagicWeapon(
        int requestedWeaponType,
        int requestedEssenceType,
        int requestedTier
    )
    {
        return CaelumInventoryService.ActivateEquippedMagicWeapon(self, requestedWeaponType, requestedEssenceType, requestedTier);
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
        return CaelumInventoryService.CountNativeMagicBoxSlots(self);
    }

    int GetMagicBoxWeightDivisor()
    {
        return CaelumInventoryService.GetMagicBoxWeightDivisor(self);
    }

    // Todo el contenido se suma antes de dividir y truncar. Así dos pilas con
    // el mismo peso total producen exactamente la misma carga que una sola y
    // separar objetos nunca permite aprovechar redondeos independientes.
    double CalculateMagicBoxReducedContentWeight(double rawContentWeight)
    {
        return CaelumInventoryService.CalculateMagicBoxReducedContentWeight(self, rawContentWeight);
    }

    double CalculateMagicBoxTotalWeight(double rawContentWeight)
    {
        return CaelumInventoryService.CalculateMagicBoxTotalWeight(self, rawContentWeight);
    }

    // Evalúa una transición completa sin modificar Actor.Inv. personalDelta
    // describe lo que entra o sale del inventario normal y boxRawDelta el peso
    // real que entra o sale del contenido de la caja.
    bool CanApplyInventoryWeightTransition(
        double personalDelta, double boxRawDelta
    )
    {
        return CaelumInventoryService.CanApplyInventoryWeightTransition(self, personalDelta, boxRawDelta);
    }

    bool CanAddRawWeightToMagicBox(double rawWeight)
    {
        return CaelumInventoryService.CanAddRawWeightToMagicBox(self, rawWeight);
    }

    bool CanMoveRawWeightFromMagicBoxToPersonal(double rawWeight)
    {
        return CaelumInventoryService.CanMoveRawWeightFromMagicBoxToPersonal(self, rawWeight);
    }

    bool CanMovePersonalStackWithIncomingToMagicBox(
        double existingRawWeight, double incomingRawWeight
    )
    {
        return CaelumInventoryService.CanMovePersonalStackWithIncomingToMagicBox(self, existingRawWeight, incomingRawWeight);
    }

    bool HasNativeMagicBoxSlotAvailable()
    {
        return CaelumInventoryService.HasNativeMagicBoxSlotAvailable(self);
    }

    CaelumConsumableItem FindNativeConsumableItem(int consumableType)
    {
        return CaelumInventoryService.FindNativeConsumableItem(self, consumableType);
    }

    Inventory FindNativeAmmunition(int ammunitionType)
    {
        return CaelumInventoryService.FindNativeAmmunition(self, ammunitionType);
    }


    // Añade unidades de jabalina mediante GiveInventoryType sin pasar nunca
    // una pila por Amount = 0. Esta ruta se usa tanto para pickups recuperados
    // como para el generador DEV, y verifica la pila real antes de informar éxito.
    bool AcquireJavelinAmmunition(int ammunitionType, int incomingAmount)
    {
        return CaelumInventoryService.AcquireJavelinAmmunition(self, ammunitionType, incomingAmount);
    }

    CaelumSpecialInventoryItem FindNativeSpecialItem(
        int specialCategory, int specialType, int specialTier = 0
    )
    {
        return CaelumInventoryService.FindNativeSpecialItem(self, specialCategory, specialType, specialTier);
    }

    CaelumCurrencyItem FindNativeCurrency(int currencyType)
    {
        return CaelumInventoryService.FindNativeCurrency(self, currencyType);
    }

    int GetOwnedCurrencyAmount(int currencyType)
    {
        return CaelumInventoryService.GetOwnedCurrencyAmount(self, currencyType);
    }

    double GetOwnedMoneyCopperValue()
    {
        return CaelumInventoryService.GetOwnedMoneyCopperValue(self);
    }

    int GetPalomoMerchantQuantityForIndex(int quantityIndex)
    {
        switch (Clamp(quantityIndex, 0,
            CaelumConstants.PALOMO_MERCHANT_QUANTITY_OPTION_COUNT - 1))
        {
            case 1: return 5;
            case 2: return 20;
            case 3: return 50;
            case 4: return 100;
            default: return 1;
        }
    }

    int GetPalomoMerchantConsumableType(int merchantItem)
    {
        if (merchantItem == CaelumConstants.PALOMO_MERCHANT_ITEM_FOOD)
        { return CaelumConstants.CONSUMABLE_FOOD_RATION; }
        if (merchantItem == CaelumConstants.PALOMO_MERCHANT_ITEM_WATER)
        { return CaelumConstants.CONSUMABLE_WATER_RATION; }
        return -1;
    }

    int GetPalomoMerchantMaterialType(int merchantItem)
    {
        switch (merchantItem)
        {
            case CaelumConstants.PALOMO_MERCHANT_ITEM_WOOD:
                return CaelumConstants.MATERIAL_WOOD;
            case CaelumConstants.PALOMO_MERCHANT_ITEM_RAW_COPPER:
                return CaelumConstants.MATERIAL_RAW_COPPER;
            case CaelumConstants.PALOMO_MERCHANT_ITEM_RAW_TIN:
                return CaelumConstants.MATERIAL_RAW_TIN;
            default: return -1;
        }
    }

    Inventory FindPalomoMerchantProduct(int merchantItem)
    {
        return CaelumInventoryService.FindPalomoMerchantProduct(self, merchantItem);
    }

    bool IsPalomoMerchantProductInMagicBox(Inventory product)
    {
        return CaelumInventoryService.IsPalomoMerchantProductInMagicBox(self, product);
    }

    int CountPalomoMerchantProduct(int merchantItem, bool includeReserved)
    {
        return CaelumInventoryService.CountPalomoMerchantProduct(self, merchantItem, includeReserved);
    }

    double GetPalomoMerchantProductUnitWeight(int merchantItem)
    {
        return CaelumInventoryService.GetPalomoMerchantProductUnitWeight(self, merchantItem);
    }

    void ResetPalomoCurrencyPlan()
    {
        CaelumInventoryService.ResetPalomoCurrencyPlan(self);
    }

    bool BuildPalomoCurrencyPaymentPlan(int copperAmount)
    {
        return CaelumInventoryService.BuildPalomoCurrencyPaymentPlan(self, copperAmount);
    }

    bool BuildPalomoCurrencyCreditPlan(int copperAmount)
    {
        return CaelumInventoryService.BuildPalomoCurrencyCreditPlan(self, copperAmount);
    }

    void RoutePalomoCurrencyGainsToMagicBox()
    {
        CaelumInventoryService.RoutePalomoCurrencyGainsToMagicBox(self);
    }

    double GetPalomoCurrencyPlanPersonalWeightDelta()
    {
        return CaelumInventoryService.GetPalomoCurrencyPlanPersonalWeightDelta(self);
    }

    double GetPalomoCurrencyPlanBoxRawWeightDelta()
    {
        return CaelumInventoryService.GetPalomoCurrencyPlanBoxRawWeightDelta(self);
    }

    int GetPalomoCurrencyPlanBoxSlotDelta()
    {
        return CaelumInventoryService.GetPalomoCurrencyPlanBoxSlotDelta(self);
    }

    bool PalomoTransactionCapacityFits(
        double personalDelta, double boxRawDelta, int boxSlotDelta)
    {
        return CaelumInventoryService.PalomoTransactionCapacityFits(self, personalDelta, boxRawDelta, boxSlotDelta);
    }

    bool PreparePalomoPurchaseCapacity(
        int merchantItem, int quantity, int price)
    {
        return CaelumInventoryService.PreparePalomoPurchaseCapacity(self, merchantItem, quantity, price);
    }

    bool PreparePalomoSaleCapacity(
        int merchantItem, int quantity, int price)
    {
        return CaelumInventoryService.PreparePalomoSaleCapacity(self, merchantItem, quantity, price);
    }

    bool ApplyPalomoCurrencyPlan()
    {
        return CaelumInventoryService.ApplyPalomoCurrencyPlan(self);
    }

    bool AddPalomoMerchantProduct(int merchantItem, int quantity)
    {
        return CaelumInventoryService.AddPalomoMerchantProduct(self, merchantItem, quantity);
    }

    bool RemovePalomoMerchantProduct(int merchantItem, int quantity)
    {
        return CaelumInventoryService.RemovePalomoMerchantProduct(self, merchantItem, quantity);
    }

    bool HasPalomoMerchantReputationDiscount()
    {
        return ActivePalomoMerchantDiscountCondition != null
            && CaelumFactionCondition.Check(self, ActivePalomoMerchantDiscountCondition)
                == CaelumFactionCondition.ALLOWED;
    }

    void RefreshPalomoMerchantSnapshot()
    {
        if(CityTrade!=null){CityTrade.Refresh(self);return;}
        PalomoMerchantSelection = Clamp(PalomoMerchantSelection, 0,
            CaelumConstants.PALOMO_MERCHANT_ITEM_COUNT - 1);
        PalomoMerchantMode = Clamp(PalomoMerchantMode,
            CaelumConstants.PALOMO_MERCHANT_MODE_BUY,
            CaelumConstants.PALOMO_MERCHANT_MODE_SELL);
        PalomoMerchantQuantityIndex = Clamp(PalomoMerchantQuantityIndex, 0,
            CaelumConstants.PALOMO_MERCHANT_QUANTITY_OPTION_COUNT - 1);
        CaelumPersistentCharacterState persistentState =
            GetPersistentCharacterState(true);
        if (persistentState == null) { return; }
        persistentState.EnsurePalomoMerchantInitialized();
        persistentState.EnsurePalomoDiscountInitialized();
        PalomoMerchantDiscountGranted =
            persistentState.PalomoDiscountGranted;
        // Esta rebaja es de la sesión: nunca se guarda como rebaja negociada.
        PalomoMerchantReputationDiscount = HasPalomoMerchantReputationDiscount();
        for (int merchantItem = 0;
            merchantItem < CaelumConstants.PALOMO_MERCHANT_ITEM_COUNT; merchantItem++)
        {
            PalomoMerchantStock[merchantItem] = Max(0,
                persistentState.PalomoMerchantStock[merchantItem]);
            PalomoMerchantPlayerOwned[merchantItem] =
                CountPalomoMerchantProduct(merchantItem, false);
        }
        PalomoMerchantWalletCopper = Max(0,
            persistentState.PalomoMerchantWalletCopper);
        PalomoMerchantVisibleItemCount = 0;
        bool currentSelectionVisible = false;
        for (int merchantItem = 0;
            merchantItem < CaelumConstants.PALOMO_MERCHANT_ITEM_COUNT;
            merchantItem++)
        {
            bool visible = PalomoMerchantMode
                    == CaelumConstants.PALOMO_MERCHANT_MODE_BUY
                || (PalomoMerchantPlayerOwned[merchantItem] > 0
                    && PalomoMerchantWalletCopper
                        >= CaelumEconomyRules.GetPalomoMerchantLotPrice(
                            merchantItem, 1,
                            CaelumConstants.PALOMO_MERCHANT_MODE_SELL,
                            PalomoMerchantDiscountGranted || PalomoMerchantReputationDiscount
                        ));
            if (!visible) { continue; }

            PalomoMerchantVisibleItems[PalomoMerchantVisibleItemCount] =
                merchantItem;
            PalomoMerchantVisibleItemCount++;
            if (merchantItem == PalomoMerchantSelection)
            {
                currentSelectionVisible = true;
            }
        }
        for (int visibleIndex = PalomoMerchantVisibleItemCount;
            visibleIndex < CaelumConstants.PALOMO_MERCHANT_ITEM_COUNT;
            visibleIndex++)
        {
            PalomoMerchantVisibleItems[visibleIndex] = -1;
        }
        if (!currentSelectionVisible && PalomoMerchantVisibleItemCount > 0)
        {
            PalomoMerchantSelection = PalomoMerchantVisibleItems[0];
        }
        PalomoMerchantSelectedQuantity =
            GetPalomoMerchantQuantityForIndex(PalomoMerchantQuantityIndex);
        PalomoMerchantSelectedLotPrice = PalomoMerchantVisibleItemCount > 0
            ? CaelumEconomyRules.GetPalomoMerchantLotPrice(
                PalomoMerchantSelection, PalomoMerchantSelectedQuantity,
                PalomoMerchantMode, PalomoMerchantDiscountGranted || PalomoMerchantReputationDiscount)
            : 0;
        RefreshCarriedInventorySummary();
    }

    bool IsActivePalomoMerchantSessionValid()
    {
        if (!PalomoMerchantMenuOpen || ActivePalomoMerchant == null
            || ActivePalomoMerchant.health <= 0 || health <= 0) { return false; }
        return Distance3D(ActivePalomoMerchant)
            <= CaelumConstants.PALOMO_MERCHANT_SESSION_DISTANCE
            && CaelumFactionCondition.Check(self, ActivePalomoMerchantRequirement)
                == CaelumFactionCondition.ALLOWED;
    }

    void OpenPalomoMerchant(Actor merchant, CaelumFactionCondition requirement = null,
        CaelumFactionCondition discount = null, String titleKey = "CA_PALOMO_MERCHANT_TITLE")
    {
        SyncPalomoDialogueTokens();
        if (CreationWizardOpen || !MagicBoxOwned || merchant == null) { return; }
        if (!CaelumFactionCondition.Require(self, requirement)) return;
        if (StaffCastPending) { CancelPendingStaffCast(false); }
        EquipmentMenuOpen = false;
        CloseCraftingStationSession();
        SetCraftingJournalState(false);
        ActivePalomoMerchant = merchant;
        ActivePalomoMerchantRequirement = requirement;
        ActivePalomoMerchantDiscountCondition = discount;
        PalomoMerchantTitleKey = titleKey;
        PalomoMerchantMenuOpen = true;
        PalomoMerchantSessionValidationTics = 0;
        PalomoMerchantSelection = Clamp(PalomoMerchantSelection, 0,
            CaelumConstants.PALOMO_MERCHANT_ITEM_COUNT - 1);
        PalomoMerchantMode = Clamp(PalomoMerchantMode,
            CaelumConstants.PALOMO_MERCHANT_MODE_BUY,
            CaelumConstants.PALOMO_MERCHANT_MODE_SELL);
        LastPalomoMerchantAction = CaelumConstants.PALOMO_MERCHANT_ACTION_NONE;
        RefreshPalomoMerchantSnapshot();
    }

    void ClosePalomoMerchant()
    {
        CityTrade=null;
        PalomoMerchantMenuOpen = false;
        ActivePalomoMerchant = null;
        ActivePalomoMerchantRequirement = null;
        ActivePalomoMerchantDiscountCondition = null;
        PalomoMerchantReputationDiscount = false;
        PalomoMerchantTitleKey = "";
        PalomoMerchantSessionValidationTics = 0;
        if (FolkloreInteractionUseLatched)
        {
            FolkloreInteractionReleaseGuardTics =
                CaelumConstants.PALOMO_INTERACTION_REARM_GUARD_TICS;
        }
    }

    void UpdatePalomoMerchantSession()
    {
        if (!PalomoMerchantMenuOpen) { return; }
        PalomoMerchantSessionValidationTics++;
        if (PalomoMerchantSessionValidationTics < 4) { return; }
        PalomoMerchantSessionValidationTics = 0;
        if (!IsActivePalomoMerchantSessionValid())
        {
            CaelumFactionCondition.Require(self, ActivePalomoMerchantRequirement);
            LastPalomoMerchantAction =
                CaelumConstants.PALOMO_MERCHANT_ACTION_FAILED_SESSION;
            ClosePalomoMerchant();
        }
        else if (PalomoMerchantReputationDiscount != HasPalomoMerchantReputationDiscount())
        {
            RefreshPalomoMerchantSnapshot();
            LastPalomoMerchantAction = CaelumConstants.PALOMO_MERCHANT_ACTION_PRICE_CHANGED;
        }
    }

    void CyclePalomoMerchantSelection(int direction)
    {
        if (!IsActivePalomoMerchantSessionValid()) { return; }
        if(CityTrade!=null){CityTrade.Cycle(self,direction);return;}
        RefreshPalomoMerchantSnapshot();
        if (PalomoMerchantVisibleItemCount <= 0) { return; }
        int currentVisibleIndex = 0;
        for (int visibleIndex = 0;
            visibleIndex < PalomoMerchantVisibleItemCount; visibleIndex++)
        {
            if (PalomoMerchantVisibleItems[visibleIndex]
                == PalomoMerchantSelection)
            {
                currentVisibleIndex = visibleIndex;
                break;
            }
        }
        currentVisibleIndex = (currentVisibleIndex
            + (direction < 0 ? PalomoMerchantVisibleItemCount - 1 : 1))
            % PalomoMerchantVisibleItemCount;
        PalomoMerchantSelection =
            PalomoMerchantVisibleItems[currentVisibleIndex];
        LastPalomoMerchantAction = CaelumConstants.PALOMO_MERCHANT_ACTION_NONE;
        RefreshPalomoMerchantSnapshot();
    }

    void TogglePalomoMerchantMode()
    {
        if (!IsActivePalomoMerchantSessionValid()) { return; }
        PalomoMerchantMode = PalomoMerchantMode
            == CaelumConstants.PALOMO_MERCHANT_MODE_BUY
            ? CaelumConstants.PALOMO_MERCHANT_MODE_SELL
            : CaelumConstants.PALOMO_MERCHANT_MODE_BUY;
        LastPalomoMerchantAction = CaelumConstants.PALOMO_MERCHANT_ACTION_NONE;
        RefreshPalomoMerchantSnapshot();
    }

    void CyclePalomoMerchantQuantity(int direction)
    {
        if (!IsActivePalomoMerchantSessionValid()) { return; }
        PalomoMerchantQuantityIndex = (PalomoMerchantQuantityIndex
            + (direction < 0
                ? CaelumConstants.PALOMO_MERCHANT_QUANTITY_OPTION_COUNT - 1
                : 1))
            % CaelumConstants.PALOMO_MERCHANT_QUANTITY_OPTION_COUNT;
        LastPalomoMerchantAction = CaelumConstants.PALOMO_MERCHANT_ACTION_NONE;
        RefreshPalomoMerchantSnapshot();
    }

    void ExecutePalomoMerchantTransaction()
    {
        if(CityTrade!=null){CityTrade.Execute(self);return;}
        if (!IsActivePalomoMerchantSessionValid())
        {
            CaelumFactionCondition.Require(self, ActivePalomoMerchantRequirement);
            LastPalomoMerchantAction =
                CaelumConstants.PALOMO_MERCHANT_ACTION_FAILED_SESSION;
            ClosePalomoMerchant();
            return;
        }
        int quotedPrice = PalomoMerchantSelectedLotPrice;
        RefreshCarriedInventorySummary();
        RefreshPalomoMerchantSnapshot();
        if (quotedPrice != PalomoMerchantSelectedLotPrice)
        {
            LastPalomoMerchantAction = CaelumConstants.PALOMO_MERCHANT_ACTION_PRICE_CHANGED;
            return;
        }
        CaelumPersistentCharacterState persistentState =
            GetPersistentCharacterState(true);
        if (persistentState == null) { return; }
        persistentState.EnsurePalomoMerchantInitialized();
        persistentState.EnsurePalomoDiscountInitialized();
        PalomoMerchantDiscountGranted =
            persistentState.PalomoDiscountGranted;
        int merchantItem = PalomoMerchantSelection;
        int quantity = PalomoMerchantSelectedQuantity;
        int price = PalomoMerchantSelectedLotPrice;
        if (PalomoMerchantVisibleItemCount <= 0)
        {
            LastPalomoMerchantAction =
                CaelumConstants.PALOMO_MERCHANT_ACTION_FAILED_PLAYER_STOCK;
            return;
        }
        if (PalomoMerchantMode == CaelumConstants.PALOMO_MERCHANT_MODE_BUY)
        {
            if (persistentState.PalomoMerchantStock[merchantItem] < quantity)
            {
                LastPalomoMerchantAction =
                    CaelumConstants.PALOMO_MERCHANT_ACTION_FAILED_STOCK;
                return;
            }
            if (GetOwnedMoneyCopperValue() + 0.0001 < price)
            {
                LastPalomoMerchantAction =
                    CaelumConstants.PALOMO_MERCHANT_ACTION_FAILED_PLAYER_MONEY;
                return;
            }
            if (!PreparePalomoPurchaseCapacity(merchantItem, quantity, price))
            {
                LastPalomoMerchantAction =
                    CaelumConstants.PALOMO_MERCHANT_ACTION_FAILED_CAPACITY;
                return;
            }
            if (!ApplyPalomoCurrencyPlan()
                || !AddPalomoMerchantProduct(merchantItem, quantity))
            {
                LastPalomoMerchantAction =
                    CaelumConstants.PALOMO_MERCHANT_ACTION_FAILED_SESSION;
                return;
            }
            persistentState.PalomoMerchantStock[merchantItem] -= quantity;
            if (persistentState.PalomoMerchantWalletCopper > 2147483647 - price)
            { persistentState.PalomoMerchantWalletCopper = 2147483647; }
            else { persistentState.PalomoMerchantWalletCopper += price; }
            LastPalomoMerchantAction = CaelumConstants.PALOMO_MERCHANT_ACTION_BOUGHT;
        }
        else
        {
            int available = CountPalomoMerchantProduct(merchantItem, false);
            if (available < quantity)
            {
                int physical = CountPalomoMerchantProduct(merchantItem, true);
                LastPalomoMerchantAction = physical >= quantity
                    ? CaelumConstants.PALOMO_MERCHANT_ACTION_FAILED_RESERVED
                    : CaelumConstants.PALOMO_MERCHANT_ACTION_FAILED_PLAYER_STOCK;
                return;
            }
            if (persistentState.PalomoMerchantWalletCopper < price)
            {
                LastPalomoMerchantAction =
                    CaelumConstants.PALOMO_MERCHANT_ACTION_FAILED_MERCHANT_MONEY;
                return;
            }
            if (!PreparePalomoSaleCapacity(merchantItem, quantity, price))
            {
                LastPalomoMerchantAction =
                    CaelumConstants.PALOMO_MERCHANT_ACTION_FAILED_CAPACITY;
                return;
            }
            if (!RemovePalomoMerchantProduct(merchantItem, quantity)
                || !ApplyPalomoCurrencyPlan())
            {
                LastPalomoMerchantAction =
                    CaelumConstants.PALOMO_MERCHANT_ACTION_FAILED_SESSION;
                return;
            }
            if (persistentState.PalomoMerchantStock[merchantItem]
                > 2147483647 - quantity)
            { persistentState.PalomoMerchantStock[merchantItem] = 2147483647; }
            else { persistentState.PalomoMerchantStock[merchantItem] += quantity; }
            persistentState.PalomoMerchantWalletCopper -= price;
            LastPalomoMerchantAction = CaelumConstants.PALOMO_MERCHANT_ACTION_SOLD;
        }
        ApplyCharacterProfile();
        RefreshCarriedInventorySummary();
        RefreshFormalInventorySnapshot();
        RefreshPalomoMerchantSnapshot();
        PersistCharacterState();
        A_StartSound("caelum/ui/menu_select", CHAN_6, CHANF_LOCAL | CHANF_UI);
    }

    CaelumWeightedKey FindNativeKey(int keyType)
    {
        return CaelumInventoryService.FindNativeKey(self, keyType);
    }

    bool PrepareNativeEquipmentPickup(CaelumEquipmentItem item)
    {
        return CaelumInventoryService.PrepareNativeEquipmentPickup(self, item);
    }

    bool PrepareNativeAmmoPickup(CaelumCarbineAmmo ammunition)
    {
        return CaelumInventoryService.PrepareNativeAmmoPickup(self, ammunition);
    }

    bool PrepareNativeAmmoStackPickup(
        CaelumCarbineAmmo ammunition, int incomingAmount
    )
    {
        return CaelumInventoryService.PrepareNativeAmmoStackPickup(self, ammunition, incomingAmount);
    }

    bool PrepareNativeConsumablePickup(CaelumConsumableItem consumable)
    {
        return CaelumInventoryService.PrepareNativeConsumablePickup(self, consumable);
    }

    bool PrepareNativeConsumableStackPickup(
        CaelumConsumableItem consumable, int incomingAmount
    )
    {
        return CaelumInventoryService.PrepareNativeConsumableStackPickup(self, consumable, incomingAmount);
    }

    bool PrepareNativeSpecialPickup(CaelumSpecialInventoryItem specialItem)
    {
        return CaelumInventoryService.PrepareNativeSpecialPickup(self, specialItem);
    }

    bool PrepareNativeSpecialStackPickup(
        CaelumSpecialInventoryItem specialItem, int incomingAmount
    )
    {
        return CaelumInventoryService.PrepareNativeSpecialStackPickup(self, specialItem, incomingAmount);
    }

    bool PrepareNativeKeyPickup(CaelumWeightedKey keyItem)
    {
        return CaelumInventoryService.PrepareNativeKeyPickup(self, keyItem);
    }

    void OnNativeInventoryChanged()
    {
        CaelumInventoryService.OnNativeInventoryChanged(self);
    }

    // Los pickups de armas que permanecen en el inventario personal se
    // incorporan al equipamiento y pasan a ser el arma activa. Las piezas que
    // desbordan a la Caja Mágica y los talles incompatibles conservan las
    // reglas normales de almacenamiento y no se fuerzan sobre el personaje.
    void OnNativeEquipmentPickedUp(
        int pickedItemId,
        int pickedKind,
        int pickedType,
        int pickedTier,
        int pickedSize,
        int pickedEssence,
        bool pickedIntoMagicBox
    )
    {
        CaelumInventoryService.OnNativeEquipmentPickedUp(self, pickedItemId, pickedKind, pickedType, pickedTier, pickedSize, pickedEssence, pickedIntoMagicBox);
    }

    void MigrateLegacyEquipmentToNativeInventory(
        CaelumPersistentCharacterState persistentState
    )
    {
        CaelumInventoryService.MigrateLegacyEquipmentToNativeInventory(self, persistentState);
    }

    double GetEquippedWeaponLoadWeight()
    {
        return CaelumInventoryService.GetEquippedWeaponLoadWeight(self);
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
        return CaelumInventoryService.HasEquippedWeaponFamily(self, family);
    }

    bool ActivateEquippedWeaponFamily(int family)
    {
        return CaelumInventoryService.ActivateEquippedWeaponFamily(self, family);
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

    Name GetNativeWeaponSelectorClass(
        int weaponType, int essenceType, int tier
    )
    {
        switch (weaponType)
        {
            case CaelumConstants.WEAPON_TYPE_DAGGER:
                return 'CaelumDaggerSelectorWeapon';
            case CaelumConstants.WEAPON_TYPE_HATCHET:
                return 'CaelumHatchetSelectorWeapon';
            case CaelumConstants.WEAPON_TYPE_MACHETE:
                return 'CaelumMacheteSelectorWeapon';
            case CaelumConstants.WEAPON_TYPE_JAVELIN:
                return 'CaelumJavelinSelectorWeapon';
            case CaelumConstants.WEAPON_TYPE_SWORD:
                return 'CaelumSwordSelectorWeapon';
            case CaelumConstants.WEAPON_TYPE_PICKAXE:
                return 'CaelumPickaxeSelectorWeapon';
            case CaelumConstants.WEAPON_TYPE_AXE:
                return 'CaelumAxeSelectorWeapon';
            case CaelumConstants.WEAPON_TYPE_FLAIL:
                return 'CaelumFlailSelectorWeapon';
            case CaelumConstants.WEAPON_TYPE_SPEAR:
                return 'CaelumSpearSelectorWeapon';
            case CaelumConstants.WEAPON_TYPE_GREATSWORD:
                return 'CaelumGreatswordSelectorWeapon';
            case CaelumConstants.WEAPON_TYPE_WAR_AXE:
                return 'CaelumWarAxeSelectorWeapon';
            case CaelumConstants.WEAPON_TYPE_HALBERD:
                return 'CaelumHalberdSelectorWeapon';
            case CaelumConstants.WEAPON_TYPE_GIANT_GAUNTLETS:
                return 'CaelumGiantGauntletsSelectorWeapon';
            case CaelumConstants.WEAPON_TYPE_SHOTGUN:
                return 'CaelumStandardBowSelectorWeapon';
            case CaelumConstants.WEAPON_TYPE_CARBINE:
                return 'CaelumCarbineSelectorWeapon';
            case CaelumConstants.WEAPON_TYPE_LONGBOW:
                return 'CaelumLongbowSelectorWeapon';
            case CaelumConstants.WEAPON_TYPE_CROSSBOW:
                return 'CaelumCrossbowSelectorWeapon';
        }

        String essenceName;
        switch (Clamp(essenceType, 0, CaelumConstants.ESSENCE_TYPE_COUNT - 1))
        {
            case CaelumConstants.ESSENCE_WATER: essenceName = "Water"; break;
            case CaelumConstants.ESSENCE_EARTH: essenceName = "Earth"; break;
            case CaelumConstants.ESSENCE_WIND: essenceName = "Air"; break;
            case CaelumConstants.ESSENCE_QUINTESSENCE:
                essenceName = "Quintessence";
                break;
            default: essenceName = "Fire"; break;
        }

        String implementName;
        switch (weaponType)
        {
            case CaelumConstants.WEAPON_TYPE_STAFF:
                implementName = "Staff";
                break;
            case CaelumConstants.WEAPON_TYPE_BELL:
                implementName = "Bell";
                break;
            case CaelumConstants.WEAPON_TYPE_BOOK:
                implementName = "Book";
                break;
            case CaelumConstants.WEAPON_TYPE_STATUETTE:
                implementName = "Statuette";
                break;
            default: return '';
        }

        return Name(String.Format(
            "Caelum%s%sT%dWeapon",
            essenceName,
            implementName,
            Clamp(tier, 1, 3)
        ));
    }

    void SelectNativeWeaponConfiguration(
        int weaponType, int essenceType, int tier
    )
    {
        if (player == null) { return; }
        Name selectorClass = GetNativeWeaponSelectorClass(
            weaponType, essenceType, tier
        );
        if (selectorClass == '') { return; }
        Weapon selector = Weapon(FindInventory(selectorClass));
        if (selector != null && player.ReadyWeapon != selector)
        {
            player.PendingWeapon = selector;
        }
    }

    // Los selectores físicos conservan sus slots. Las armas mágicas se
    // agrupan por elemento: 6 Fuego, 7 Agua, 8 Tierra, 9 Aire y 0
    // Quintaesencia (el slot 0 representa la décima familia numérica).
    // Puños propios: presencia permanente sin convertirlos en un objeto de Caja.
    void EnsureUnarmedFallback()
    {
        if(player==null || !CharacterCreationComplete || health<=0) return;
        let fists=Weapon(FindInventory("CaelumUnarmedWeapon"));
        if(fists==null)fists=Weapon(GiveInventoryType("CaelumUnarmedWeapon"));
        let legacy=FindInventory("Fist");
        if(legacy!=null)legacy.Destroy();
        bool active=WeaponModel!=null && WeaponModel.Equipped && WeaponModel.Durability>0
            && HasEquippedNativeWeaponType(WeaponModel.WeaponType);
        if(fists!=null && !active && player.ReadyWeapon!=fists
            && (player.PendingWeapon==null || player.PendingWeapon==WP_NOCHANGE
                || player.PendingWeapon.Owner!=self))
            player.PendingWeapon=fists;
    }

    void EnsureWeaponFamilySelectors()
    {
        if (!CharacterCreationComplete) { return; }
        EnsurePhysicalWeaponSelector(CaelumConstants.WEAPON_TYPE_PICKAXE, "CaelumPickaxeSelectorWeapon");
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
            CaelumConstants.WEAPON_TYPE_SHOTGUN,
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
        return CaelumInventoryService.ActivateEquippedWeaponType(self, requestedWeaponType);
    }

    bool ActivateExactEquippedWeapon(CaelumEquipmentItem item)
    {
        return CaelumInventoryService.ActivateExactEquippedWeapon(self, item);
    }

    bool IsWeaponInNativeSlot(CaelumEquipmentItem item, int slot)
    {
        return CaelumInventoryService.IsWeaponInNativeSlot(self, item, slot);
    }

    void CycleEquippedWeaponSlot(int slot)
    {
        CaelumInventoryService.CycleEquippedWeaponSlot(self, slot);
    }

    // Mantiene una instantanea segura para UI y detecta cambios reales del
    // arma activa. Varias armas pueden seguir equipadas simultaneamente.
    void SyncHUDActiveWeaponState()
    {
        CaelumPlayerPresentation.SyncHUDActiveWeaponState(self);
    }

    bool ActivateFirstEquippedWeapon()
    {
        return CaelumInventoryService.ActivateFirstEquippedWeapon(self);
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
    // peso. La Caja Mágica suma 10 kg y reduce el peso agregado de su contenido
    // según la capacidad máxima actual. Las pilas usan Amount.
    void RefreshCarriedInventorySummary()
    {
        CaelumInventoryService.RefreshCarriedInventorySummary(self);
    }

    bool CanAddWeightToPersonalInventory(double additionalWeight)
    {
        return CaelumInventoryService.CanAddWeightToPersonalInventory(self, additionalWeight);
    }

    bool IsSpecialInventoryKind(int k)
    {
        return CaelumInventoryService.IsSpecialInventoryKind(self, k);
    }
    bool IsUniversalJewelryKind(int k)
    {
        return CaelumInventoryService.IsUniversalJewelryKind(self, k);
    }

    int GetFormalInventoryEntryKind(Inventory entry)
    {
        return CaelumInventoryService.GetFormalInventoryEntryKind(self, entry);
    }

    int GetFormalInventoryFilterCategory(int kind)
    {
        return CaelumInventoryService.GetFormalInventoryFilterCategory(self, kind);
    }

    bool FormalInventoryEntryMatchesFilter(Inventory entry)
    {
        return CaelumInventoryService.FormalInventoryEntryMatchesFilter(self, entry);
    }

    Inventory GetFormalInventoryEntryAt(int requestedIndex)
    {
        return CaelumInventoryService.GetFormalInventoryEntryAt(self, requestedIndex);
    }

    int CountFormalInventoryEntries()
    {
        return CaelumInventoryService.CountFormalInventoryEntries(self);
    }

    int GetFormalAmmunitionType(Inventory entry)
    {
        return CaelumInventoryService.GetFormalAmmunitionType(self, entry);
    }

    double GetFormalInventoryEntryWeight(Inventory entry)
    {
        return CaelumInventoryService.GetFormalInventoryEntryWeight(self, entry);
    }

    int GetFormalInventoryMaximumDurability(CaelumEquipmentItem item)
    {
        return CaelumInventoryService.GetFormalInventoryMaximumDurability(self, item);
    }

    void ClearFormalInventoryRow(int row)
    {
        CaelumInventoryService.ClearFormalInventoryRow(self, row);
    }

    void FillFormalInventoryRow(int row, Inventory entry)
    {
        CaelumInventoryService.FillFormalInventoryRow(self, row, entry);
    }

    void ApplyFormalInventorySelection(Inventory entry)
    {
        CaelumInventoryService.ApplyFormalInventorySelection(self, entry);
    }

    void RefreshFormalInventorySnapshot()
    {
        CaelumInventoryService.RefreshFormalInventorySnapshot(self);
    }

    void CycleFormalInventorySelection(int direction)
    {
        CaelumInventoryService.CycleFormalInventorySelection(self, direction);
    }

    void CycleFormalInventoryFilter(int direction = 1)
    {
        CaelumInventoryService.CycleFormalInventoryFilter(self, direction);
    }

    void ActivateFormalInventorySelection()
    {
        CaelumInventoryService.ActivateFormalInventorySelection(self);
    }

    void ToggleFormalInventoryStorage()
    {
        CaelumInventoryService.ToggleFormalInventoryStorage(self);
    }

    void DropFormalInventorySelection()
    {
        CaelumInventoryService.DropFormalInventorySelection(self);
    }

    void RefreshEquipmentSelectionPreview()
    {
        CaelumInventoryService.RefreshEquipmentSelectionPreview(self);
    }

    bool AcquireArmorPickup(
        int slot,
        int armorType,
        int tier,
        int equipmentSize,
        int encodedDurability
    )
    {
        return CaelumInventoryService.AcquireArmorPickup(self, slot, armorType, tier, equipmentSize, encodedDurability);
    }

    bool AcquireShieldPickup(
        int shieldType,
        int tier,
        int equipmentSize,
        int encodedDurability
    )
    {
        return CaelumInventoryService.AcquireShieldPickup(self, shieldType, tier, equipmentSize, encodedDurability);
    }

    bool AcquireWeaponPickup(
        int weaponType,
        int tier,
        int equipmentSize,
        int encodedDurability
    )
    {
        return CaelumInventoryService.AcquireWeaponPickup(self, weaponType, tier, equipmentSize, encodedDurability);
    }

    int CountCraftingMaterial(int materialType, int materialTier)
    {
        return CaelumInventoryService.CountCraftingMaterial(self, materialType, materialTier);
    }

    int CountRawCraftingMaterial(int materialType, int materialTier)
    {
        return CaelumInventoryService.CountRawCraftingMaterial(self, materialType, materialTier);
    }

    int GetReservedCraftingMaterialUnits(int materialType, int materialTier)
    {
        return CaelumInventoryService.GetReservedCraftingMaterialUnits(self, materialType, materialTier);
    }

    bool IsEquipmentItemCraftingLocked(int itemId)
    {
        return CaelumInventoryService.IsEquipmentItemCraftingLocked(self, itemId);
    }

    bool IsSelectedMaterialCraftingLocked()
    {
        return CaelumInventoryService.IsSelectedMaterialCraftingLocked(self);
    }

    void ClearCraftingTaskData()
    {
        CaelumInventoryService.ClearCraftingTaskData(self);
    }

    bool AddCraftingTaskReservation(
        int materialType, int materialTier, int units
    )
    {
        return CaelumInventoryService.AddCraftingTaskReservation(self, materialType, materialTier, units);
    }

    bool AddCraftingTaskOutput(
        int materialType, int materialTier, int units
    )
    {
        return CaelumInventoryService.AddCraftingTaskOutput(self, materialType, materialTier, units);
    }

    bool ValidateCraftingTaskReservations()
    {
        return CaelumInventoryService.ValidateCraftingTaskReservations(self);
    }

    bool CanCompletePreparedMaterialOutput(bool outputToMagicBox)
    {
        return CaelumInventoryService.CanCompletePreparedMaterialOutput(self, outputToMagicBox);
    }

    int GetPreparedMaterialOutputBoxSlots()
    {
        return CaelumInventoryService.GetPreparedMaterialOutputBoxSlots(self);
    }

    bool CanCompletePreparedEquipmentOutput(double outputRawWeight)
    {
        return CaelumInventoryService.CanCompletePreparedEquipmentOutput(self, outputRawWeight);
    }

    double GetCraftingDexterityPercent()
    {
        if (DerivedStats == null || Attributes == null) { return 100.0; }
        return Max(
            100.0,
            DerivedStats.CalculateType1Percent(Attributes.Dexterity)
        );
    }

    double GetCraftingMaterialWorkSeconds(
        int employedMaterialUnits, int complexityTics,
        int efficiencyIndex
    )
    {
        return CaelumCraftingRules.GetMaterialWorkSeconds(
            employedMaterialUnits,
            complexityTics,
            GetCraftingDexterityPercent(),
            efficiencyIndex
        );
    }

    int GetCurrentCraftingInputUnits()
    {
        return Max(0, CraftingBasicRequired)
            + Max(0, CraftingTierRequired)
            + Max(0, CraftingSilverRequired)
            + Max(0, CraftingGoldRequired);
    }

    void ResetCraftingLayerChoices()
    {
        CraftingLayerChoiceCount = 0;
        CraftingBlueprintSelectedNode = 0;
        for (int slot = 0;
            slot < CaelumConstants.CRAFTING_LAYER_CHOICE_SLOT_COUNT; slot++)
        {
            CraftingLayerChoiceRecipe[slot] = -1;
            CraftingLayerChoiceTier[slot] = 1;
            CraftingLayerChoiceEfficiency[slot] = 0;
        }
    }

    void EnsureCraftingLayerChoiceRoot()
    {
        if (CraftingLayerChoiceRootRecipe == CraftingSelectionRecipe
            && CraftingLayerChoiceRootTier == CraftingSelectionTier
            && CraftingLayerChoiceRootSize == CraftingSelectionSize)
        {
            return;
        }
        CraftingLayerChoiceRootRecipe = CraftingSelectionRecipe;
        CraftingLayerChoiceRootTier = CraftingSelectionTier;
        CraftingLayerChoiceRootSize = CraftingSelectionSize;
        ResetCraftingLayerChoices();
    }

    int FindCraftingLayerChoice(int recipeIndex, int materialTier)
    {
        int resolvedTier = Clamp(materialTier, 1, 3);
        for (int slot = 0; slot < CraftingLayerChoiceCount; slot++)
        {
            if (CraftingLayerChoiceRecipe[slot] == recipeIndex
                && CraftingLayerChoiceTier[slot] == resolvedTier)
            {
                return slot;
            }
        }
        return -1;
    }

    int GetOrCreateCraftingLayerChoice(
        int recipeIndex, int materialTier
    )
    {
        int existing = FindCraftingLayerChoice(recipeIndex, materialTier);
        if (existing >= 0) { return existing; }
        if (CraftingLayerChoiceCount
            >= CaelumConstants.CRAFTING_LAYER_CHOICE_SLOT_COUNT)
        {
            return -1;
        }
        int slot = CraftingLayerChoiceCount++;
        CraftingLayerChoiceRecipe[slot] = recipeIndex;
        CraftingLayerChoiceTier[slot] = Clamp(materialTier, 1, 3);
        CraftingLayerChoiceEfficiency[slot] = Clamp(
            CraftingEfficiencyIndex, 0,
            CaelumConstants.CRAFTING_EFFICIENCY_OPTION_COUNT - 1
        );
        return slot;
    }

    int GetCraftingLayerEfficiencyIndex(
        int recipeIndex, int materialTier
    )
    {
        int choice = GetOrCreateCraftingLayerChoice(
            recipeIndex, materialTier
        );
        return choice >= 0
            ? CraftingLayerChoiceEfficiency[choice]
            : CraftingEfficiencyIndex;
    }

    void SetCraftingLayerEfficiencyIndex(
        int recipeIndex, int materialTier, int efficiencyIndex
    )
    {
        int choice = GetOrCreateCraftingLayerChoice(
            recipeIndex, materialTier
        );
        if (choice < 0) { return; }
        CraftingLayerChoiceEfficiency[choice] = Clamp(
            efficiencyIndex, 0,
            CaelumConstants.CRAFTING_EFFICIENCY_OPTION_COUNT - 1
        );
    }

    void ClearCraftingBlueprint()
    {
        CraftingBlueprintNodeCount = 0;
        CraftingBlueprintFullSeconds = 0.0;
        for (int slot = 0;
            slot < CaelumConstants.CRAFTING_BLUEPRINT_NODE_SLOT_COUNT; slot++)
        {
            CraftingBlueprintNodeKind[slot] =
                CaelumConstants.CRAFTING_BLUEPRINT_NODE_RAW;
            CraftingBlueprintNodeDepth[slot] = 0;
            CraftingBlueprintNodeRecipe[slot] = -1;
            CraftingBlueprintNodeMaterialType[slot] = -1;
            CraftingBlueprintNodeMaterialTier[slot] = 1;
            CraftingBlueprintNodeUnits[slot] = 0;
            CraftingBlueprintNodeOwnedUnits[slot] = 0;
            CraftingBlueprintNodeInputUnits[slot] = 0;
            CraftingBlueprintNodeEfficiency[slot] = -1;
            CraftingBlueprintNodeComplexityTics[slot] = 0;
            CraftingBlueprintNodeSeconds[slot] = 0.0;
            CraftingBlueprintNodeExecuted[slot] = false;
        }
    }

    int FindCraftingBlueprintNode(
        int nodeKind, int recipeIndex,
        int materialType, int materialTier
    )
    {
        int resolvedTier = CaelumMaterialRules.ResolveTier(
            materialType, materialTier
        );
        for (int node = 1; node < CraftingBlueprintNodeCount; node++)
        {
            if (CraftingBlueprintNodeKind[node] != nodeKind) { continue; }
            if (nodeKind == CaelumConstants.CRAFTING_BLUEPRINT_NODE_RECIPE)
            {
                if (CraftingBlueprintNodeRecipe[node] == recipeIndex
                    && CraftingBlueprintNodeMaterialTier[node]
                        == resolvedTier)
                {
                    return node;
                }
            }
            else if (CraftingBlueprintNodeMaterialType[node] == materialType
                && CraftingBlueprintNodeMaterialTier[node] == resolvedTier)
            {
                return node;
            }
        }
        return -1;
    }

    int AddOrAccumulateCraftingBlueprintNode(
        int nodeKind, int depth, int recipeIndex,
        int materialType, int materialTier, int units
    )
    {
        if (units <= 0) { return -1; }
        int resolvedTier = CaelumMaterialRules.ResolveTier(
            materialType, materialTier
        );
        int existing = FindCraftingBlueprintNode(
            nodeKind, recipeIndex, materialType, resolvedTier
        );
        if (existing >= 0)
        {
            CraftingBlueprintNodeUnits[existing] += units;
            CraftingBlueprintNodeDepth[existing] = Min(
                CraftingBlueprintNodeDepth[existing], depth
            );
            return existing;
        }
        if (CraftingBlueprintNodeCount
            >= CaelumConstants.CRAFTING_BLUEPRINT_NODE_SLOT_COUNT)
        {
            return -1;
        }
        int node = CraftingBlueprintNodeCount++;
        CraftingBlueprintNodeKind[node] = nodeKind;
        CraftingBlueprintNodeDepth[node] = Clamp(depth, 0, 8);
        CraftingBlueprintNodeRecipe[node] = recipeIndex;
        CraftingBlueprintNodeMaterialType[node] = materialType;
        CraftingBlueprintNodeMaterialTier[node] = resolvedTier;
        CraftingBlueprintNodeUnits[node] = units;
        if (nodeKind == CaelumConstants.CRAFTING_BLUEPRINT_NODE_RECIPE)
        {
            CraftingBlueprintNodeEfficiency[node] =
                GetCraftingLayerEfficiencyIndex(recipeIndex, resolvedTier);
            CraftingBlueprintNodeComplexityTics[node] =
                CaelumCraftingRules.GetRecipeComplexityTics(recipeIndex);
        }
        return node;
    }

    void ExpandCraftingBlueprintMaterial(
        int materialType, int materialTier, int requiredUnits,
        int depth = 1
    )
    {
        // La merma modifica las cantidades transmitidas a cada subreceta. El
        // tiempo de una operacion usa solo la eficiencia elegida en ese nodo.
        if (requiredUnits <= 0 || depth > 8) { return; }
        int resolvedTier = CaelumMaterialRules.ResolveTier(
            materialType, materialTier
        );
        int recipeIndex =
            CaelumCraftingRules.FindComponentRecipeForOutput(materialType);
        bool componentRecipe = recipeIndex >= 0;
        if (!componentRecipe)
        {
            recipeIndex = CaelumCraftingRules.FindProcessingRecipeForOutput(
                materialType, resolvedTier
            );
        }
        if (recipeIndex < 0)
        {
            AddOrAccumulateCraftingBlueprintNode(
                CaelumConstants.CRAFTING_BLUEPRINT_NODE_RAW,
                depth, -1, materialType, resolvedTier, requiredUnits
            );
            return;
        }

        int node = AddOrAccumulateCraftingBlueprintNode(
            CaelumConstants.CRAFTING_BLUEPRINT_NODE_RECIPE,
            depth, recipeIndex, materialType, resolvedTier, requiredUnits
        );
        if (node < 0) { return; }
        int efficiencyIndex = GetCraftingLayerEfficiencyIndex(
            recipeIndex, resolvedTier
        );
        int efficiencyAdjustedOutput =
            CaelumCraftingRules.GetEfficiencyAdjustedInputUnits(
                requiredUnits, efficiencyIndex
            );
        if (componentRecipe)
        {
            CraftingBlueprintNodeInputUnits[node] +=
                efficiencyAdjustedOutput;
            CraftingBlueprintNodeSeconds[node] +=
                GetCraftingMaterialWorkSeconds(
                    efficiencyAdjustedOutput,
                    CraftingBlueprintNodeComplexityTics[node],
                    efficiencyIndex
                );
            ExpandCraftingBlueprintMaterial(
                CaelumCraftingRules.GetComponentBaseMaterial(
                    materialType, resolvedTier
                ),
                CaelumCraftingRules.GetComponentBaseTier(
                    materialType, resolvedTier
                ),
                efficiencyAdjustedOutput,
                depth + 1
            );
            return;
        }

        int theoreticalOutput = Max(
            1,
            CaelumCraftingRules.GetProcessingOutputUnits(recipeIndex, 0)
        );
        int inputOneUnits = GetRoundedUpProportionalUnits(
            efficiencyAdjustedOutput,
            CaelumCraftingRules.GetProcessingInputOneUnits(recipeIndex, 0),
            theoreticalOutput
        );
        int inputTwoUnits = GetRoundedUpProportionalUnits(
            efficiencyAdjustedOutput,
            CaelumCraftingRules.GetProcessingInputTwoUnits(recipeIndex, 0),
            theoreticalOutput
        );
        CraftingBlueprintNodeInputUnits[node] +=
            inputOneUnits + inputTwoUnits;
        CraftingBlueprintNodeSeconds[node] +=
            GetCraftingMaterialWorkSeconds(
                inputOneUnits + inputTwoUnits,
                CraftingBlueprintNodeComplexityTics[node],
                efficiencyIndex
            );
        ExpandCraftingBlueprintMaterial(
            CaelumCraftingRules.GetProcessingInputOneMaterial(recipeIndex),
            CaelumCraftingRules.GetProcessingInputOneTier(recipeIndex),
            inputOneUnits,
            depth + 1
        );
        int inputTwoMaterial =
            CaelumCraftingRules.GetProcessingInputTwoMaterial(recipeIndex);
        if (inputTwoMaterial >= 0 && inputTwoUnits > 0)
        {
            ExpandCraftingBlueprintMaterial(
                inputTwoMaterial,
                CaelumCraftingRules.GetProcessingInputTwoTier(recipeIndex),
                inputTwoUnits,
                depth + 1
            );
        }
    }

    void BuildCraftingBlueprint()
    {
        EnsureCraftingLayerChoiceRoot();
        ClearCraftingBlueprint();
        int rootInputs = GetCurrentCraftingInputUnits();
        int rootComplexity = CaelumCraftingRules.GetRecipeComplexityTics(
            CraftingSelectionRecipe
        );

        CraftingBlueprintNodeCount = 1;
        CraftingBlueprintNodeKind[0] =
            CaelumConstants.CRAFTING_BLUEPRINT_NODE_FINAL;
        CraftingBlueprintNodeDepth[0] = 0;
        CraftingBlueprintNodeRecipe[0] = CraftingSelectionRecipe;
        CraftingBlueprintNodeMaterialType[0] = CraftingOutputMaterialType;
        CraftingBlueprintNodeMaterialTier[0] = CraftingOutputMaterialTier;
        CraftingBlueprintNodeUnits[0] = 1;
        CraftingBlueprintNodeInputUnits[0] = rootInputs;
        CraftingBlueprintNodeEfficiency[0] = CraftingEfficiencyIndex;
        CraftingBlueprintNodeComplexityTics[0] = rootComplexity;
        CraftingBlueprintNodeSeconds[0] = GetCraftingMaterialWorkSeconds(
            rootInputs, rootComplexity, CraftingEfficiencyIndex
        );
        CraftingBlueprintNodeExecuted[0] = true;

        ExpandCraftingBlueprintMaterial(
            CraftingBasicMaterialType,
            CraftingBasicMaterialTier,
            CraftingBasicRequired
        );
        ExpandCraftingBlueprintMaterial(
            CraftingTierMaterialType,
            CraftingTierMaterialTier,
            CraftingTierRequired
        );
        ExpandCraftingBlueprintMaterial(
            CaelumConstants.MATERIAL_SILVER_INGOT,
            1,
            CraftingSilverRequired
        );
        ExpandCraftingBlueprintMaterial(
            CaelumConstants.MATERIAL_GOLD_INGOT,
            1,
            CraftingGoldRequired
        );

        CraftingBlueprintFullSeconds = CraftingBlueprintNodeSeconds[0];
        for (int node = 1; node < CraftingBlueprintNodeCount; node++)
        {
            CraftingBlueprintNodeOwnedUnits[node] = CountCraftingMaterial(
                CraftingBlueprintNodeMaterialType[node],
                CraftingBlueprintNodeMaterialTier[node]
            );
            if (CraftingBlueprintNodeKind[node]
                != CaelumConstants.CRAFTING_BLUEPRINT_NODE_RECIPE)
            {
                continue;
            }
            CraftingBlueprintFullSeconds +=
                CraftingBlueprintNodeSeconds[node];
        }
        CraftingBlueprintSelectedNode = Clamp(
            CraftingBlueprintSelectedNode,
            0, Max(0, CraftingBlueprintNodeCount - 1)
        );
        if (CraftingBlueprintNodeKind[CraftingBlueprintSelectedNode]
            == CaelumConstants.CRAFTING_BLUEPRINT_NODE_RAW)
        {
            CraftingBlueprintSelectedNode = 0;
        }
    }

    void CycleCraftingBlueprintSelection(int direction)
    {
        RefreshCraftingPreview();
        if (CraftingBlueprintNodeCount <= 1) { return; }
        int step = direction < 0 ? -1 : 1;
        int candidate = CraftingBlueprintSelectedNode;
        for (int attempt = 0;
            attempt < CraftingBlueprintNodeCount; attempt++)
        {
            candidate = (candidate + step + CraftingBlueprintNodeCount)
                % CraftingBlueprintNodeCount;
            if (CraftingBlueprintNodeKind[candidate]
                != CaelumConstants.CRAFTING_BLUEPRINT_NODE_RAW)
            {
                CraftingBlueprintSelectedNode = candidate;
                return;
            }
        }
    }

    void MarkCraftingBlueprintStepExecuted(
        int recipeIndex, int materialTier
    )
    {
        int resolvedTier = Clamp(materialTier, 1, 3);
        for (int node = 1; node < CraftingBlueprintNodeCount; node++)
        {
            if (CraftingBlueprintNodeKind[node]
                    == CaelumConstants.CRAFTING_BLUEPRINT_NODE_RECIPE
                && CraftingBlueprintNodeRecipe[node] == recipeIndex
                && CraftingBlueprintNodeMaterialTier[node] == resolvedTier)
            {
                CraftingBlueprintNodeExecuted[node] = true;
                return;
            }
        }
    }

    bool ReserveCurrentCraftingPreview()
    {
        if (!AddCraftingTaskReservation(
                CraftingBasicMaterialType,
                CraftingBasicMaterialTier,
                CraftingBasicRequired
            )
            || !AddCraftingTaskReservation(
                CraftingTierMaterialType,
                CraftingTierMaterialTier,
                CraftingTierRequired
            )
            || !AddCraftingTaskReservation(
                CaelumConstants.MATERIAL_SILVER_INGOT,
                1,
                CraftingSilverRequired
            )
            || !AddCraftingTaskReservation(
                CaelumConstants.MATERIAL_GOLD_INGOT,
                1,
                CraftingGoldRequired
            ))
        {
            return false;
        }
        return ValidateCraftingTaskReservations();
    }

    void ClearDirectCraftingPlan()
    {
        CraftingDirectPlanAvailable = false;
        CraftingDirectPlanUsed = false;
        CraftingDirectPlanStepCount = 0;
        CraftingPreparedEquipmentInputUnits = 0;
        for (int slot = 0;
            slot < CaelumConstants.CRAFTING_TASK_MATERIAL_SLOT_COUNT; slot++)
        {
            CraftingPlanReservedType[slot] = -1;
            CraftingPlanReservedTier[slot] = 1;
            CraftingPlanReservedUnits[slot] = 0;
        }
        for (int step = 0;
            step < CaelumConstants.CRAFTING_DIRECT_STEP_SLOT_COUNT; step++)
        {
            CraftingPlanStepRecipe[step] = -1;
            CraftingPlanStepTier[step] = 1;
            CraftingPlanStepEfficiency[step] = 0;
            CraftingPlanStepInputUnits[step] = 0;
            CraftingPlanStepComplexityTics[step] = 0;
            CraftingPlanStepSeconds[step] = 0.0;
        }
    }

    int GetDirectPlanReservedUnits(int materialType, int materialTier)
    {
        int resolvedTier = CaelumMaterialRules.ResolveTier(
            materialType, materialTier
        );
        int reserved = 0;
        for (int slot = 0;
            slot < CaelumConstants.CRAFTING_TASK_MATERIAL_SLOT_COUNT; slot++)
        {
            if (CraftingPlanReservedUnits[slot] > 0
                && CraftingPlanReservedType[slot] == materialType
                && CraftingPlanReservedTier[slot] == resolvedTier)
            {
                reserved += CraftingPlanReservedUnits[slot];
            }
        }
        return reserved;
    }

    bool AddDirectPlanReservation(
        int materialType, int materialTier, int units
    )
    {
        if (units <= 0) { return true; }
        int resolvedTier = CaelumMaterialRules.ResolveTier(
            materialType, materialTier
        );
        for (int slot = 0;
            slot < CaelumConstants.CRAFTING_TASK_MATERIAL_SLOT_COUNT; slot++)
        {
            if (CraftingPlanReservedUnits[slot] > 0
                && CraftingPlanReservedType[slot] == materialType
                && CraftingPlanReservedTier[slot] == resolvedTier)
            {
                CraftingPlanReservedUnits[slot] += units;
                return true;
            }
        }
        for (int slot = 0;
            slot < CaelumConstants.CRAFTING_TASK_MATERIAL_SLOT_COUNT; slot++)
        {
            if (CraftingPlanReservedUnits[slot] <= 0)
            {
                CraftingPlanReservedType[slot] = materialType;
                CraftingPlanReservedTier[slot] = resolvedTier;
                CraftingPlanReservedUnits[slot] = units;
                return true;
            }
        }
        return false;
    }

    int RegisterDirectCraftingStep(int recipeIndex, int materialTier)
    {
        int resolvedTier = Clamp(materialTier, 1, 3);
        for (int step = 0; step < CraftingDirectPlanStepCount; step++)
        {
            if (CraftingPlanStepRecipe[step] == recipeIndex
                && CraftingPlanStepTier[step] == resolvedTier)
            {
                return step;
            }
        }
        if (CraftingDirectPlanStepCount
            >= CaelumConstants.CRAFTING_DIRECT_STEP_SLOT_COUNT)
        {
            return -1;
        }
        int step = CraftingDirectPlanStepCount++;
        CraftingPlanStepRecipe[step] = recipeIndex;
        CraftingPlanStepTier[step] = resolvedTier;
        CraftingPlanStepEfficiency[step] =
            GetCraftingLayerEfficiencyIndex(recipeIndex, resolvedTier);
        CraftingPlanStepComplexityTics[step] =
            CaelumCraftingRules.GetRecipeComplexityTics(recipeIndex);
        return step;
    }

    void AddDirectCraftingStepWork(int step, int employedMaterialUnits)
    {
        if (step < 0 || step >= CraftingDirectPlanStepCount
            || employedMaterialUnits <= 0)
        {
            return;
        }
        CraftingPlanStepInputUnits[step] += employedMaterialUnits;
        CraftingPlanStepSeconds[step] += GetCraftingMaterialWorkSeconds(
                employedMaterialUnits,
                CraftingPlanStepComplexityTics[step],
                CraftingPlanStepEfficiency[step]
            );
        MarkCraftingBlueprintStepExecuted(
            CraftingPlanStepRecipe[step], CraftingPlanStepTier[step]
        );
    }

    int GetRoundedUpProportionalUnits(
        int requiredOutput, int numerator, int denominator
    )
    {
        if (requiredOutput <= 0 || numerator <= 0 || denominator <= 0)
        {
            return 0;
        }
        return int(Ceil(
            double(requiredOutput) * double(numerator) / double(denominator)
        ));
    }

    bool DirectCraftingRecipeKnown(int recipeIndex)
    {
        CaelumPersistentCharacterState persistentState =
            GetPersistentCharacterState(false);
        return persistentState != null
            && persistentState.KnowsCraftingRecipe(recipeIndex);
    }

    bool RequireDirectCraftingMaterial(
        int materialType, int materialTier, int requiredUnits,
        int depth = 0
    )
    {
        // La ruta real omite el trabajo de componentes ya existentes. Cada
        // operacion pendiente aplica solo su propia eficiencia temporal.
        if (requiredUnits <= 0) { return true; }
        if (depth > 8) { return false; }

        int resolvedTier = CaelumMaterialRules.ResolveTier(
            materialType, materialTier
        );
        int unreserved = Max(
            0,
            CountCraftingMaterial(materialType, resolvedTier)
                - GetDirectPlanReservedUnits(materialType, resolvedTier)
        );
        int availableUnits = Min(requiredUnits, unreserved);
        if (availableUnits > 0
            && !AddDirectPlanReservation(
                materialType, resolvedTier, availableUnits
            ))
        {
            return false;
        }

        int missingUnits = requiredUnits - availableUnits;
        if (missingUnits <= 0) { return true; }

        int componentRecipe =
            CaelumCraftingRules.FindComponentRecipeForOutput(materialType);
        if (componentRecipe >= 0)
        {
            if (!DirectCraftingRecipeKnown(componentRecipe)) { return false; }
            int missingStation = CaelumCraftingRules.GetMissingComponentStation(
                CraftingNetworkCapabilities, resolvedTier, materialType
            );
            if (missingStation != CaelumConstants.CRAFTING_STATION_NONE)
            {
                CraftingMissingStationType = missingStation;
                CraftingSelectedInfrastructureAvailable = false;
                return false;
            }
            int planStep = RegisterDirectCraftingStep(
                componentRecipe, resolvedTier
            );
            if (planStep < 0) { return false; }
            int baseMaterial = CaelumCraftingRules.GetComponentBaseMaterial(
                materialType, resolvedTier
            );
            int baseTier = CaelumCraftingRules.GetComponentBaseTier(
                materialType, resolvedTier
            );
            int baseUnits =
                CaelumCraftingRules.GetEfficiencyAdjustedInputUnits(
                    missingUnits,
                    CraftingPlanStepEfficiency[planStep]
                );
            AddDirectCraftingStepWork(planStep, baseUnits);
            return RequireDirectCraftingMaterial(
                baseMaterial,
                baseTier,
                baseUnits,
                depth + 1
            );
        }

        int processingRecipe =
            CaelumCraftingRules.FindProcessingRecipeForOutput(
                materialType, resolvedTier
            );
        if (processingRecipe < 0
            || !DirectCraftingRecipeKnown(processingRecipe))
        {
            return false;
        }
        int missingStation = CaelumCraftingRules.GetMissingProcessingStation(
            CraftingNetworkCapabilities, processingRecipe
        );
        if (missingStation != CaelumConstants.CRAFTING_STATION_NONE)
        {
            CraftingMissingStationType = missingStation;
            CraftingSelectedInfrastructureAvailable = false;
            return false;
        }
        int planStep = RegisterDirectCraftingStep(
            processingRecipe, resolvedTier
        );
        if (planStep < 0) { return false; }

        int efficiencyAdjustedOutput =
            CaelumCraftingRules.GetEfficiencyAdjustedInputUnits(
                missingUnits,
                CraftingPlanStepEfficiency[planStep]
            );
        int theoreticalOutput = Max(
            1,
            CaelumCraftingRules.GetProcessingOutputUnits(
                processingRecipe, 0
            )
        );
        int inputOneUnits = GetRoundedUpProportionalUnits(
            efficiencyAdjustedOutput,
            CaelumCraftingRules.GetProcessingInputOneUnits(
                processingRecipe, 0
            ),
            theoreticalOutput
        );
        int inputTwoMaterial =
            CaelumCraftingRules.GetProcessingInputTwoMaterial(processingRecipe);
        int inputTwoUnits = GetRoundedUpProportionalUnits(
            efficiencyAdjustedOutput,
            CaelumCraftingRules.GetProcessingInputTwoUnits(
                processingRecipe, 0
            ),
            theoreticalOutput
        );
        AddDirectCraftingStepWork(
            planStep,
            inputOneUnits + inputTwoUnits
        );
        if (!RequireDirectCraftingMaterial(
            CaelumCraftingRules.GetProcessingInputOneMaterial(processingRecipe),
            CaelumCraftingRules.GetProcessingInputOneTier(processingRecipe),
            inputOneUnits,
            depth + 1
        ))
        {
            return false;
        }
        if (inputTwoMaterial < 0) { return true; }
        return RequireDirectCraftingMaterial(
            inputTwoMaterial,
            CaelumCraftingRules.GetProcessingInputTwoTier(processingRecipe),
            inputTwoUnits,
            depth + 1
        );
    }

    bool IsDirectWeaponCraftingRecipe()
    {
        return CraftingSelectedRecipeKind == CaelumConstants.CRAFTING_RECIPE_KIND_AMULET
            || CraftingSelectedRecipeKind == CaelumConstants.CRAFTING_RECIPE_KIND_AMMUNITION
            || CraftingSelectedRecipeKind == CaelumConstants.CRAFTING_RECIPE_KIND_SEAL
            || CraftingSelectedRecipeKind == CaelumConstants.CRAFTING_RECIPE_KIND_ARMOR
            || CraftingSelectedRecipeKind == CaelumConstants.CRAFTING_RECIPE_KIND_SHIELD
            || CraftingSelectedRecipeKind
                == CaelumConstants.CRAFTING_RECIPE_KIND_PHYSICAL_WEAPON
            || CraftingSelectedRecipeKind
                == CaelumConstants.CRAFTING_RECIPE_KIND_ESSENCE_WEAPON;
    }

    void RefreshDirectWeaponCraftingPlan()
    {
        ClearDirectCraftingPlan();
        if (!IsDirectWeaponCraftingRecipe()
            || !CraftingSelectedRecipeKnown
            || !CraftingSelectedInfrastructureAvailable)
        {
            return;
        }

        bool valid = RequireDirectCraftingMaterial(
                CraftingBasicMaterialType,
                CraftingBasicMaterialTier,
                CraftingBasicRequired
            )
            && RequireDirectCraftingMaterial(
                CraftingTierMaterialType,
                CraftingTierMaterialTier,
                CraftingTierRequired
            )
            && RequireDirectCraftingMaterial(
                CaelumConstants.MATERIAL_SILVER_INGOT,
                1,
                CraftingSilverRequired
            )
            && RequireDirectCraftingMaterial(
                CaelumConstants.MATERIAL_GOLD_INGOT,
                1,
                CraftingGoldRequired
            );
        CraftingDirectPlanAvailable = valid;
        CraftingDirectPlanUsed = valid && CraftingDirectPlanStepCount > 0;
        if (valid)
        {
            for (int step = 0;
                step < CraftingDirectPlanStepCount; step++)
            {
                CraftingPreviewSeconds += CraftingPlanStepSeconds[step];
            }
        }
        else
        {
            for (int node = 1;
                node < CraftingBlueprintNodeCount; node++)
            {
                CraftingBlueprintNodeExecuted[node] = false;
            }
        }
    }

    bool ReservePreparedDirectCraftingPlan()
    {
        return CaelumInventoryService.ReservePreparedDirectCraftingPlan(self);
    }

    bool HasSelectedWeaponCraftingMaterials()
    {
        if (CraftingTaskCompleting && CraftingTaskUsesDirectPlan)
        {
            return ValidateCraftingTaskReservations();
        }
        return CraftingBasicOwned >= CraftingBasicRequired
            && CraftingTierOwned >= CraftingTierRequired
            && HasCraftingFinishMaterials();
    }

    bool ConsumeSelectedWeaponCraftingMaterials()
    {
        return CaelumInventoryService.ConsumeSelectedWeaponCraftingMaterials(self);
    }

    bool CanStartCraftingTask(bool recipeInfrastructure = true)
    {
        if (CraftingTaskActive)
        {
            LastCraftingAction =
                CaelumConstants.CRAFTING_ACTION_FAILED_TASK_ACTIVE;
            return false;
        }
        if (CombatTimeRemaining > 0.0)
        {
            LastCraftingAction = CaelumConstants.CRAFTING_ACTION_FAILED_COMBAT;
            return false;
        }
        if (player == null || player.playerstate != PST_LIVE || health <= 0)
        {
            LastCraftingAction = CaelumConstants.CRAFTING_ACTION_FAILED_TARGET;
            return false;
        }
        if (!RefreshActiveCraftingStationSession(recipeInfrastructure))
        {
            LastCraftingAction =
                CaelumConstants.CRAFTING_ACTION_FAILED_INFRASTRUCTURE;
            return false;
        }
        return true;
    }

    void StartPreparedCraftingTask(int taskKind, double durationSeconds)
    {
        CraftingTaskUsesLimboMaterials = false;
        for (int slot = 0; slot < CaelumConstants.CRAFTING_TASK_MATERIAL_SLOT_COUNT; slot++)
        {
            if (CraftingTaskReservedUnits[slot] <= 0) continue;
            let input = FindNativeSpecialItem(CaelumConstants.EQUIPMENT_KIND_MATERIAL,
                CraftingTaskReservedType[slot], CraftingTaskReservedTier[slot]);
            if (input != null && input.LimboQuestUnits > 0) CraftingTaskUsesLimboMaterials = true;
        }
        CraftingTaskKind = taskKind;
        CraftingTaskRecipeIndex = CraftingSelectionRecipe;
        CraftingTaskTier = CraftingSelectionTier;
        CraftingTaskSize = CraftingSelectionSize;
        CraftingTaskBatchIndex = CraftingProcessingBatchIndex;
        CraftingTaskEfficiencyIndex = CraftingEfficiencyIndex;
        CraftingTaskNetworkCapabilities = CraftingNetworkCapabilities;
        CraftingTaskTotalSeconds = Max(0.001, durationSeconds);
        CraftingTaskRemainingSeconds = CraftingTaskTotalSeconds;
        CraftingTaskActive = true;
        LastCraftingAction = CaelumConstants.CRAFTING_ACTION_TASK_STARTED;
        PersistCharacterState();
        RefreshFormalInventorySnapshot();
        RefreshCraftingPreview();
    }

    void BeginSelectedCraftingTask()
    {
        RefreshCraftingPreview();
        if (!CanStartCraftingTask()) { return; }
        if (!CraftingSelectedRecipeKnown)
        {
            LastCraftingAction =
                CaelumConstants.CRAFTING_ACTION_FAILED_RECIPE_LOCKED;
            return;
        }
        if (!CraftingSelectedInfrastructureAvailable)
        {
            LastCraftingAction =
                CaelumConstants.CRAFTING_ACTION_FAILED_INFRASTRUCTURE;
            return;
        }

        int taskKind = CaelumConstants.CRAFTING_TASK_ASSEMBLY;
        if (CraftingSelectedRecipeKind
            == CaelumConstants.CRAFTING_RECIPE_KIND_PROCESSING)
        {
            taskKind = CaelumConstants.CRAFTING_TASK_PROCESSING;
        }
        else if (CraftingSelectedRecipeKind
            == CaelumConstants.CRAFTING_RECIPE_KIND_COMPONENT)
        {
            taskKind = CaelumConstants.CRAFTING_TASK_COMPONENT;
        }

        RefreshCarriedInventorySummary();
        if (taskKind == CaelumConstants.CRAFTING_TASK_ASSEMBLY
            && CraftingSelectedRecipeKind != CaelumConstants.CRAFTING_RECIPE_KIND_AMMUNITION
            && !CaelumMainM00RonnieTrial.CanUsePersonalCraftingOutput(self)
            && MagicBoxUsedSlots + 1 > MagicBoxMaximumSlots)
        {
            LastCraftingAction =
                CaelumConstants.CRAFTING_ACTION_FAILED_BOX_FULL;
            return;
        }

        ClearCraftingTaskData();
        bool directWeaponTask = IsDirectWeaponCraftingRecipe()
            && CraftingDirectPlanAvailable;
        bool reserved = directWeaponTask
            ? ReservePreparedDirectCraftingPlan()
            : ReserveCurrentCraftingPreview();
        if (!reserved)
        {
            ClearCraftingTaskData();
            LastCraftingAction =
                CaelumConstants.CRAFTING_ACTION_FAILED_MATERIALS;
            return;
        }
        CraftingTaskUsesDirectPlan = directWeaponTask;
        if (taskKind == CaelumConstants.CRAFTING_TASK_PROCESSING
            || taskKind == CaelumConstants.CRAFTING_TASK_COMPONENT)
        {
            if (!AddCraftingTaskOutput(
                    CraftingOutputMaterialType,
                    CraftingOutputMaterialTier,
                    CraftingOutputAmount
                ))
            {
                ClearCraftingTaskData();
                LastCraftingAction =
                    CaelumConstants.CRAFTING_ACTION_FAILED_MATERIALS;
                return;
            }
            CraftingTaskReservedBoxSlots = GetPreparedMaterialOutputBoxSlots();
            if (CraftingTaskReservedBoxSlots < 0)
            {
                ClearCraftingTaskData();
                LastCraftingAction =
                    CaelumConstants.CRAFTING_ACTION_FAILED_CARRY_CAPACITY;
                return;
            }
        }
        else if (taskKind == CaelumConstants.CRAFTING_TASK_ASSEMBLY)
        {
            CraftingTaskReservedBoxSlots = (CaelumCraftingRules.GetRecipeAmmunitionType(CraftingSelectionRecipe) >= 0 || CaelumMainM00RonnieTrial.CanUsePersonalCraftingOutput(self)) ? 0 : 1;
            if (!CanCompletePreparedEquipmentOutput(CraftingFinalWeight))
            {
                ClearCraftingTaskData();
                LastCraftingAction =
                    CaelumConstants.CRAFTING_ACTION_FAILED_CARRY_CAPACITY;
                return;
            }
        }
        if (DerivedStats == null
            || CountNativeMagicBoxSlots() + CraftingTaskReservedBoxSlots
                > DerivedStats.MagicBoxCapacity)
        {
            ClearCraftingTaskData();
            LastCraftingAction =
                CaelumConstants.CRAFTING_ACTION_FAILED_BOX_FULL;
            return;
        }
        StartPreparedCraftingTask(taskKind, CraftingPreviewSeconds);
    }

    void CancelCraftingTask()
    {
        if (!CraftingTaskActive) { return; }
        bool equipmentTask = CraftingTaskKind
                == CaelumConstants.CRAFTING_TASK_REPAIR
            || CraftingTaskKind
                == CaelumConstants.CRAFTING_TASK_DISMANTLE;
        ClearCraftingTaskData();
        LastCraftingAction = CaelumConstants.CRAFTING_ACTION_TASK_CANCELLED;
        if (equipmentTask)
        {
            LastEquipmentAction =
                CaelumConstants.EQUIPMENT_ACTION_FAILED_CRAFTING_TASK;
        }
        PersistCharacterState();
        RefreshFormalInventorySnapshot();
        if (CraftingMenuOpen) { RefreshCraftingPreview(); }
    }

    int GetFirstKnownCraftingRecipe()
    {
        for (int recipe = 0; recipe < CaelumConstants.CRAFTING_NETWORK_PLAYABLE_RECIPE_COUNT; recipe++)
            if (IsCraftingRecipeKnown(recipe) && CaelumCraftingRules.RecipeMatchesFilter(recipe, CraftingRecipeFilter)) return recipe;
        return -1;
    }

    bool IsCraftingRecipeKnown(int recipeIndex)
    {
        CaelumPersistentCharacterState persistentState =
            GetPersistentCharacterState(true);
        if (persistentState == null) { return false; }
        return persistentState.KnowsCraftingRecipe(recipeIndex);
    }

    void RefreshCraftingRecipeBookSummary()
    {
        CraftingKnownRecipeCount = 0;
        CraftingKnownPhysicalRecipeCount = 0;
        CraftingKnownArmorRecipeCount = 0;
        CraftingKnownShieldRecipeCount = 0;
        CraftingKnownEssenceRecipeCount = 0;
        CraftingKnownAmuletRecipeCount = 0;
        CraftingKnownSealRecipeCount = 0;
        CraftingKnownProcessingRecipeCount = 0;
        CraftingKnownComponentRecipeCount = 0;

        CaelumPersistentCharacterState persistentState =
            GetPersistentCharacterState(true);
        if (persistentState == null) { return; }
        persistentState.EnsureRecipeBookInitialized();

        for (int recipeIndex = 0;
            recipeIndex < CaelumConstants.CRAFTING_NETWORK_PLAYABLE_RECIPE_COUNT;
            recipeIndex++)
        {
            if (!persistentState.KnowsCraftingRecipe(recipeIndex)) { continue; }
            CraftingKnownRecipeCount++;
            switch (CaelumCraftingRules.GetUnifiedRecipeKind(recipeIndex))
            {
                case CaelumConstants.CRAFTING_RECIPE_KIND_ARMOR:
                    CraftingKnownArmorRecipeCount++;
                    break;
                case CaelumConstants.CRAFTING_RECIPE_KIND_SHIELD:
                    CraftingKnownShieldRecipeCount++;
                    break;
                case CaelumConstants.CRAFTING_RECIPE_KIND_ESSENCE_WEAPON:
                    CraftingKnownEssenceRecipeCount++;
                    break;
                case CaelumConstants.CRAFTING_RECIPE_KIND_AMULET:
                    CraftingKnownAmuletRecipeCount++;
                    break;
                case CaelumConstants.CRAFTING_RECIPE_KIND_SEAL:
                    CraftingKnownSealRecipeCount++;
                    break;
                case CaelumConstants.CRAFTING_RECIPE_KIND_PROCESSING:
                    CraftingKnownProcessingRecipeCount++;
                    break;
                case CaelumConstants.CRAFTING_RECIPE_KIND_AMMUNITION:
                    break;
                case CaelumConstants.CRAFTING_RECIPE_KIND_COMPONENT:
                    CraftingKnownComponentRecipeCount++;
                    break;
                default:
                    CraftingKnownPhysicalRecipeCount++;
                    break;
            }
        }
    }

    bool LearnCraftingRecipe(int recipeIndex)
    {
        CaelumPersistentCharacterState persistentState =
            GetPersistentCharacterState(true);
        if (persistentState == null) { return false; }
        bool learned = persistentState.LearnCraftingRecipe(recipeIndex);
        if (learned)
        {
            RefreshCraftingRecipeBookSummary();
            PersistCharacterState();
            if (CraftingMenuOpen) { RefreshCraftingPreview(); }
            A_StartSound(
                "caelum/ui/recipe_learned",
                CHAN_6,
                CHANF_LOCAL | CHANF_UI,
                1.0,
                ATTN_NONE
            );
        }
        return learned;
    }

    // Punto de integración para el tutorial: el NPC entrega un identificador
    // estable del catálogo y sólo esa receta se incorpora al perfil.
    bool LearnPhysicalWeaponRecipe(int catalogueWeaponId)
    {
        int recipeIndex = CaelumCraftingRules.FindUnifiedPhysicalRecipeIndex(
            catalogueWeaponId
        );
        return recipeIndex >= 0 && LearnCraftingRecipe(recipeIndex);
    }

    void LearnAllProcessingRecipes()
    {
        CaelumPersistentCharacterState persistentState =
            GetPersistentCharacterState(true);
        if (persistentState == null) { return; }
        bool learnedAny = false;
        int processingStart = CaelumCraftingRules.GetProcessingRecipeStart();
        for (int recipeIndex = processingStart;
            recipeIndex < CaelumCraftingRules.GetComponentRecipeStart();
            recipeIndex++)
        {
            if (persistentState.LearnCraftingRecipe(recipeIndex))
            {
                learnedAny = true;
            }
        }
        if (!learnedAny) { return; }
        RefreshCraftingRecipeBookSummary();
        PersistCharacterState();
        if (CraftingMenuOpen) { RefreshCraftingPreview(); }
        A_StartSound(
            "caelum/ui/recipe_learned",
            CHAN_6,
            CHANF_LOCAL | CHANF_UI,
            1.0,
            ATTN_NONE
        );
    }

    void DebugSetAllCraftingRecipesKnown(bool known)
    {
        CaelumPersistentCharacterState persistentState =
            GetPersistentCharacterState(true);
        if (persistentState == null) { return; }
        persistentState.SetAllCraftingRecipesKnown(known);
        RefreshCraftingRecipeBookSummary();
        PersistCharacterState();
        if (CraftingMenuOpen) { RefreshCraftingPreview(); }
        if (known) { A_Log("$CA_DEBUG_CRAFTING_RECIPES_ALL_KNOWN"); }
        else { A_Log("$CA_DEBUG_CRAFTING_RECIPES_FORGOTTEN"); }
    }

    void DebugLearnSelectedCraftingRecipe()
    {
        if (LearnCraftingRecipe(CraftingSelectionRecipe))
        {
            A_Log("$CA_DEBUG_CRAFTING_RECIPE_LEARNED");
        }
        else
        {
            A_Log("$CA_DEBUG_CRAFTING_RECIPE_ALREADY_KNOWN");
        }
    }

    String GetWeaponCraftingPreviewIcon(int weaponType)
    {
        switch (weaponType)
        {
            case CaelumConstants.WEAPON_TYPE_DAGGER: return "graphics/caelum/icons/ca_dagger.png";
            case CaelumConstants.WEAPON_TYPE_HATCHET: return "graphics/caelum/icons/ca_hatchet.png";
            case CaelumConstants.WEAPON_TYPE_MACHETE: return "graphics/caelum/icons/ca_machete.png";
            case CaelumConstants.WEAPON_TYPE_JAVELIN: return "graphics/caelum/icons/ca_javelin.png";
            case CaelumConstants.WEAPON_TYPE_PICKAXE: return "graphics/caelum/icons/ca_pickaxe.png";
            case CaelumConstants.WEAPON_TYPE_AXE: return "graphics/caelum/icons/ca_axe.png";
            case CaelumConstants.WEAPON_TYPE_FLAIL: return "graphics/caelum/icons/ca_flail.png";
            case CaelumConstants.WEAPON_TYPE_SPEAR: return "graphics/caelum/icons/ca_spear.png";
            case CaelumConstants.WEAPON_TYPE_GREATSWORD: return "graphics/caelum/icons/ca_greatsword.png";
            case CaelumConstants.WEAPON_TYPE_WAR_AXE: return "graphics/caelum/icons/ca_war_axe.png";
            case CaelumConstants.WEAPON_TYPE_HALBERD: return "graphics/caelum/icons/ca_halberd.png";
            case CaelumConstants.WEAPON_TYPE_GIANT_GAUNTLETS: return "graphics/caelum/icons/ca_giant_gauntlets.png";
            case CaelumConstants.WEAPON_TYPE_SHOTGUN: return "CA_SHOTGUN_T1";
            case CaelumConstants.WEAPON_TYPE_LONGBOW: return "graphics/caelum/icons/ca_longbow.png";
            case CaelumConstants.WEAPON_TYPE_CROSSBOW: return "graphics/caelum/icons/ca_crossbow.png";
            case CaelumConstants.WEAPON_TYPE_CARBINE: return "graphics/caelum/icons/ca_carbine.png";
            case CaelumConstants.WEAPON_TYPE_STAFF: return "graphics/caelum/icons/ca_staff.png";
            case CaelumConstants.WEAPON_TYPE_BELL: return "graphics/caelum/icons/ca_bell.png";
            case CaelumConstants.WEAPON_TYPE_BOOK: return "graphics/caelum/icons/ca_book.png";
            case CaelumConstants.WEAPON_TYPE_STATUETTE: return "graphics/caelum/icons/ca_statuette.png";
            default: return "graphics/caelum/icons/ca_sword.png";
        }
    }

    String ResolveCraftingPreviewIconPath()
    {
        if (CraftingSelectedRecipeKind == CaelumConstants.CRAFTING_RECIPE_KIND_AMMUNITION)
            return CraftingSelectionRecipe == CaelumConstants.CRAFTING_BOLT_RECIPE
                ? "graphics/caelum/icons/ca_bolt_ammo.png" : "graphics/caelum/icons/ca_arrow_ammo.png";
        if (CraftingSelectedRecipeKind
                == CaelumConstants.CRAFTING_RECIPE_KIND_PROCESSING
            || CraftingSelectedRecipeKind
                == CaelumConstants.CRAFTING_RECIPE_KIND_COMPONENT)
        {
            return CaelumMaterialPickup.GetMaterialIconPathForType(
                CraftingOutputMaterialType
            );
        }
        if (CraftingSelectedRecipeKind
            == CaelumConstants.CRAFTING_RECIPE_KIND_PHYSICAL_WEAPON)
        {
            return GetWeaponCraftingPreviewIcon(
                CaelumCraftingRules.GetPlayableWeaponType(
                    CraftingSelectedWeapon
                )
            );
        }
        if (CraftingSelectedRecipeKind
            == CaelumConstants.CRAFTING_RECIPE_KIND_ESSENCE_WEAPON)
        {
            return GetWeaponCraftingPreviewIcon(
                CraftingSelectedEssenceWeaponType
            );
        }
        if (CraftingSelectedRecipeKind
            == CaelumConstants.CRAFTING_RECIPE_KIND_SHIELD)
        {
            return CaelumIconResolver.GetShieldBasePath(
                CraftingSelectedShieldType
            );
        }
        if (CraftingSelectedRecipeKind
            == CaelumConstants.CRAFTING_RECIPE_KIND_ARMOR)
        {
            return CaelumIconResolver.GetArmorBasePath(
                CraftingSelectedArmorSlot, CraftingSelectedArmorType
            );
        }
        if (CraftingSelectedRecipeKind
            == CaelumConstants.CRAFTING_RECIPE_KIND_AMULET)
        {
            return CaelumIconResolver.GetAmuletBasePath(
                CraftingSelectedAmuletType
            );
        }
        if (CraftingSelectedRecipeKind
            == CaelumConstants.CRAFTING_RECIPE_KIND_SEAL)
        {
            return CaelumIconResolver.GetSealBasePath(
                CraftingSelectedSealType
            );
        }
        return "";
    }

    void RefreshCraftingPreview()
    {
        // Los filtros recorren el catálogo global del Banco de Trabajo. Las
        // estaciones especializadas conservan sus índices locales y no deben
        // recibir selecciones pertenecientes a otra familia.
        if (ActiveCraftingStationType
            != CaelumConstants.CRAFTING_STATION_WORKBENCH
            && ActiveCraftingStationType != CaelumConstants.CRAFTING_STATION_NONE)
        {
            CraftingRecipeFilter =
                CaelumConstants.CRAFTING_RECIPE_FILTER_ALL;
        }
        CraftingRecipeFilter = CaelumCraftingRules.ResolveRecipeFilter(
            CraftingRecipeFilter
        );
        RefreshCraftingRecipeBookSummary();
        CaelumPersistentCharacterState persistentState =
            GetPersistentCharacterState(false);

        int stationRecipeCount = ActiveCraftingStationType == CaelumConstants.CRAFTING_STATION_NONE
            ? CaelumConstants.CRAFTING_NETWORK_PLAYABLE_RECIPE_COUNT
            : CaelumCraftingRules.GetStationRecipeCount(ActiveCraftingStationType);
        bool unifiedCatalogue = ActiveCraftingStationType == CaelumConstants.CRAFTING_STATION_WORKBENCH
            || ActiveCraftingStationType == CaelumConstants.CRAFTING_STATION_NONE;
        int firstKnown = unifiedCatalogue ? GetFirstKnownCraftingRecipe() : 0;
        if (firstKnown < 0) stationRecipeCount = 0;
        if (stationRecipeCount <= 0)
        {
            CraftingSelectionRecipe = -1;
            CraftingSelectedRecipeKnown = false;
            CraftingSelectedWeapon = -1;
            CraftingSelectedRecipeKind =
                CaelumConstants.CRAFTING_RECIPE_KIND_PHYSICAL_WEAPON;
            CraftingSelectedArmorType = CaelumConstants.ARMOR_TYPE_MAGIC;
            CraftingSelectedArmorSlot = CaelumConstants.ARMOR_SLOT_HEAD;
            CraftingSelectedShieldType = CaelumConstants.SHIELD_TYPE_BUCKLER;
            CraftingSelectedEssenceWeaponType = CaelumConstants.WEAPON_TYPE_STAFF;
            CraftingSelectedEssenceType = CaelumConstants.ESSENCE_FIRE;
            CraftingSelectedProcessingRecipe = -1;
            CraftingProcessingBatchMultiplier = 1;
            CraftingEfficiencyPercent =
                CaelumConstants.CRAFTING_EFFICIENCY_FAST_PERCENT;
            CraftingPreviewSeconds = 0.0;
            CraftingOutputMaterialType = 0;
            CraftingOutputMaterialTier = 1;
            CraftingOutputAmount = 0;
            CraftingPreviewIconPath = "";
            CraftingBasicMaterialType = 0;
            CraftingBasicMaterialTier = 1;
            CraftingBasicRequired = 0;
            CraftingBasicOwned = 0;
            CraftingTierMaterialType = 0;
            CraftingTierMaterialTier = 1;
            CraftingTierRequired = 0;
            CraftingTierOwned = 0;
            CraftingSilverRequired = 0;
            CraftingSilverOwned = 0;
            CraftingGoldRequired = 0;
            CraftingGoldOwned = 0;
            CraftingFinalWeight = 0.0;
            CraftingSelectedInfrastructureAvailable = false;
            CraftingMissingStationType =
                CaelumConstants.CRAFTING_STATION_NONE;
            ClearCraftingBlueprint();
            ClearDirectCraftingPlan();
            RefreshCarriedInventorySummary();
            return;
        }

        CraftingSelectionRecipe = Clamp(
            CraftingSelectionRecipe, 0, stationRecipeCount - 1
        );
        if ((unifiedCatalogue && !IsCraftingRecipeKnown(CraftingSelectionRecipe)) || !CaelumCraftingRules.RecipeMatchesFilter(
            CraftingSelectionRecipe, CraftingRecipeFilter
        ))
        {
            CraftingSelectionRecipe =
                unifiedCatalogue ? firstKnown : CaelumCraftingRules.GetFirstRecipeMatchingFilter(CraftingRecipeFilter);
        }
        CraftingSelectedRecipeKnown = persistentState != null
            && persistentState.KnowsCraftingRecipe(CraftingSelectionRecipe);
        CraftingSelectionTier = CraftingSelectionRecipe == CaelumConstants.CRAFTING_PICKAXE_RECIPE
            ? 1 : Clamp(CraftingSelectionTier, 1, 3);
        CraftingSelectionSize = Clamp(
            CraftingSelectionSize,
            0,
            CaelumConstants.EQUIPMENT_SIZE_COUNT - 1
        );
        CraftingProcessingBatchIndex = Clamp(
            CraftingProcessingBatchIndex, 0,
            CaelumConstants.CRAFTING_PROCESSING_BATCH_OPTION_COUNT - 1
        );
        CraftingEfficiencyIndex = Clamp(
            CraftingEfficiencyIndex, 0,
            CaelumConstants.CRAFTING_EFFICIENCY_OPTION_COUNT - 1
        );
        CraftingEfficiencyPercent =
            CaelumCraftingRules.GetCraftingEfficiencyPercent(
                CraftingEfficiencyIndex
            );

        CraftingSelectedRecipeKind =
            CaelumCraftingRules.GetUnifiedRecipeKind(
                CraftingSelectionRecipe
            );
        CraftingSelectedWeapon = -1;
        CraftingSelectedProcessingRecipe = -1;
        CraftingProcessingBatchMultiplier =
            CaelumCraftingRules.GetProcessingBatchMultiplier(
                CraftingProcessingBatchIndex
            );
        CraftingOutputMaterialType = 0;
        CraftingOutputMaterialTier = 1;
        CraftingOutputAmount = 0;
        CraftingSilverRequired = 0;
        CraftingGoldRequired = 0;

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
            == CaelumConstants.CRAFTING_RECIPE_KIND_SHIELD)
        {
            CraftingSelectedShieldType =
                CaelumCraftingRules.GetUnifiedShieldType(
                    CraftingSelectionRecipe
                );

            CraftingBasicMaterialType = CaelumConstants.MATERIAL_STRAP;
            CraftingTierMaterialType =
                CaelumCraftingRules.GetShieldPlateMaterial(
                    CraftingSelectedShieldType
                );
            CraftingFinalWeight = ShieldModel != null
                ? ShieldModel.GetWeightFor(
                    CraftingSelectedShieldType,
                    CraftingSelectionTier,
                    CraftingSelectionSize
                )
                : 0.0;
            CraftingBasicRequired =
                CaelumCraftingRules.GetRequiredShieldStrapUnits(
                    CraftingFinalWeight
                );
            CraftingTierRequired =
                CaelumCraftingRules.GetRequiredShieldPlateUnits(
                    CraftingFinalWeight
                );
            CraftingMissingStationType =
                CaelumCraftingRules.GetMissingShieldStation(
                    CraftingNetworkCapabilities,
                    CraftingSelectionTier
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

        else if (CraftingSelectedRecipeKind
            == CaelumConstants.CRAFTING_RECIPE_KIND_PROCESSING)
        {
            CraftingSelectedProcessingRecipe =
                CaelumCraftingRules.GetUnifiedProcessingRecipeIndex(
                    CraftingSelectionRecipe
                );
            CraftingBasicMaterialType =
                CaelumCraftingRules.GetProcessingInputOneMaterial(
                    CraftingSelectionRecipe
                );
            CraftingBasicMaterialTier =
                CaelumCraftingRules.GetProcessingInputOneTier(
                    CraftingSelectionRecipe
                );
            CraftingBasicRequired =
                CaelumCraftingRules.GetProcessingInputOneUnits(
                    CraftingSelectionRecipe,
                    CraftingProcessingBatchIndex
                );
            CraftingTierMaterialType =
                CaelumCraftingRules.GetProcessingInputTwoMaterial(
                    CraftingSelectionRecipe
                );
            CraftingTierMaterialTier =
                CaelumCraftingRules.GetProcessingInputTwoTier(
                    CraftingSelectionRecipe
                );
            CraftingTierRequired =
                CaelumCraftingRules.GetProcessingInputTwoUnits(
                    CraftingSelectionRecipe,
                    CraftingProcessingBatchIndex
                );
            CraftingOutputMaterialType =
                CaelumCraftingRules.GetProcessingOutputMaterial(
                    CraftingSelectionRecipe
                );
            CraftingOutputMaterialTier =
                CaelumCraftingRules.GetProcessingOutputTier(
                    CraftingSelectionRecipe
                );
            CraftingOutputAmount =
                CaelumCraftingRules.GetProcessingOutputUnitsAtEfficiency(
                    CraftingSelectionRecipe,
                    CraftingProcessingBatchIndex,
                    CraftingEfficiencyIndex
                );
            CraftingFinalWeight = CraftingOutputAmount
                * CaelumConstants.MATERIAL_UNIT_WEIGHT;
            CraftingMissingStationType =
                CaelumCraftingRules.GetMissingProcessingStation(
                    CraftingNetworkCapabilities,
                    CraftingSelectionRecipe
                );
        }
        else if (CraftingSelectedRecipeKind
            == CaelumConstants.CRAFTING_RECIPE_KIND_COMPONENT)
        {
            CraftingOutputMaterialType =
                CaelumCraftingRules.GetComponentOutputMaterial(
                    CraftingSelectionRecipe
                );
            CraftingOutputMaterialTier =
                CaelumCraftingRules.GetComponentOutputTier(
                    CraftingOutputMaterialType,
                    CraftingSelectionTier
                );
            CraftingOutputAmount =
                CaelumCraftingRules.GetComponentOutputUnits(
                    CraftingProcessingBatchIndex,
                    CraftingEfficiencyIndex
                );
            CraftingBasicMaterialType =
                CaelumCraftingRules.GetComponentBaseMaterial(
                    CraftingOutputMaterialType,
                    CraftingOutputMaterialTier
                );
            CraftingBasicMaterialTier =
                CaelumCraftingRules.GetComponentBaseTier(
                    CraftingOutputMaterialType,
                    CraftingOutputMaterialTier
                );
            CraftingBasicRequired =
                CaelumCraftingRules.GetComponentInputUnits(
                    CraftingProcessingBatchIndex
                );
            CraftingTierMaterialType = 0;
            CraftingTierMaterialTier = 1;
            CraftingTierRequired = 0;
            CraftingFinalWeight = CraftingOutputAmount
                * CaelumConstants.MATERIAL_UNIT_WEIGHT;
            CraftingMissingStationType =
                CaelumCraftingRules.GetMissingComponentStation(
                    CraftingNetworkCapabilities,
                    CraftingOutputMaterialTier,
                    CraftingOutputMaterialType
                );
        }
        else if (CraftingSelectedRecipeKind == CaelumConstants.CRAFTING_RECIPE_KIND_AMMUNITION)
        {
            // Flechas y virotes conservan sus masas nativas y comparten la
            // base T1: 70 % asta y 30 % punta. Merma por capa en el bloque común.
            CraftingSelectionTier = 1; CraftingSelectionSize = CaelumConstants.EQUIPMENT_SIZE_M;
            CraftingFinalWeight = GetAmmunitionUnitWeight(
                CaelumCraftingRules.GetRecipeAmmunitionType(CraftingSelectionRecipe))
                * CaelumCraftingRules.GetRecipeAmmunitionBatch(CraftingSelectionRecipe);
            CraftingBasicMaterialType = CaelumConstants.MATERIAL_SHAFT;
            CraftingTierMaterialType = CaelumConstants.MATERIAL_POINT;
            CraftingBasicRequired = CaelumCraftingRules.GetRoundedMaterialUnits(CraftingFinalWeight, CaelumConstants.AMMUNITION_SHAFT_SHARE);
            CraftingTierRequired = CaelumCraftingRules.GetRoundedMaterialUnits(CraftingFinalWeight, CaelumConstants.AMMUNITION_POINT_SHARE);
            CraftingMissingStationType = CaelumCraftingRules.GetMissingNetworkStation(
                CraftingNetworkCapabilities, 1, CaelumConstants.CATALOGUE_WEAPON_LONGBOW);
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
        else if (CraftingSelectedRecipeKind
            == CaelumConstants.CRAFTING_RECIPE_KIND_SEAL)
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

        if (CraftingSelectedRecipeKind
                != CaelumConstants.CRAFTING_RECIPE_KIND_PROCESSING
            && CraftingSelectedRecipeKind
                != CaelumConstants.CRAFTING_RECIPE_KIND_COMPONENT)
        {
            // El material base siempre es estructural y permanece en tier 1.
            CraftingBasicMaterialTier = CaelumMaterialRules.ResolveTier(
                CraftingBasicMaterialType, 1
            );
            CraftingTierMaterialTier = CaelumMaterialRules.ResolveTier(
                CraftingTierMaterialType, CraftingSelectionTier
            );
            CraftingSilverRequired =
                CaelumCraftingRules.GetRequiredSilverDetailUnits(
                    CraftingFinalWeight, CraftingSelectionTier
                );
            CraftingGoldRequired =
                CaelumCraftingRules.GetRequiredGoldDetailUnits(
                    CraftingFinalWeight, CraftingSelectionTier
                );
            if (CraftingSelectedRecipeKind
                == CaelumConstants.CRAFTING_RECIPE_KIND_SEAL)
            {
                CraftingBasicMaterialTier = CaelumMaterialRules.ResolveTier(
                    CraftingBasicMaterialType, CraftingSelectionTier
                );
            }

            // El montaje y la reparación producen un objeto indivisible. Una
            // eficiencia menor conserva el resultado completo y aumenta cada
            // entrada por separado para representar la merma elegida.
            CraftingBasicRequired =
                CaelumCraftingRules.GetEfficiencyAdjustedInputUnits(
                    CraftingBasicRequired, CraftingEfficiencyIndex
                );
            CraftingTierRequired =
                CaelumCraftingRules.GetEfficiencyAdjustedInputUnits(
                    CraftingTierRequired, CraftingEfficiencyIndex
                );
            CraftingSilverRequired =
                CaelumCraftingRules.GetEfficiencyAdjustedInputUnits(
                    CraftingSilverRequired, CraftingEfficiencyIndex
                );
            CraftingGoldRequired =
                CaelumCraftingRules.GetEfficiencyAdjustedInputUnits(
                    CraftingGoldRequired, CraftingEfficiencyIndex
                );
        }

        CraftingBasicOwned = CountCraftingMaterial(
            CraftingBasicMaterialType, CraftingBasicMaterialTier
        );
        CraftingTierOwned = CraftingTierRequired > 0
            ? CountCraftingMaterial(
                CraftingTierMaterialType, CraftingTierMaterialTier
            ) : 0;
        CraftingSilverOwned = CraftingSilverRequired > 0
            ? CountCraftingMaterial(
                CaelumConstants.MATERIAL_SILVER_INGOT, 1
            ) : 0;
        CraftingGoldOwned = CraftingGoldRequired > 0
            ? CountCraftingMaterial(
                CaelumConstants.MATERIAL_GOLD_INGOT, 1
            ) : 0;

        CraftingSelectedInfrastructureAvailable =
            CraftingMissingStationType
                == CaelumConstants.CRAFTING_STATION_NONE;

        CraftingPreviewSeconds = GetCraftingMaterialWorkSeconds(
            GetCurrentCraftingInputUnits(),
            CaelumCraftingRules.GetRecipeComplexityTics(
                CraftingSelectionRecipe
            ),
            CraftingEfficiencyIndex
        );

        // El árbol completo permanece visible aunque ya existan componentes;
        // la ruta real añade tiempo sólo por pasos que deban ejecutarse.
        BuildCraftingBlueprint();
        RefreshDirectWeaponCraftingPlan();
        CraftingPreviewIconPath = ResolveCraftingPreviewIconPath();
        if (CraftingSelectedRecipeKind
                == CaelumConstants.CRAFTING_RECIPE_KIND_PHYSICAL_WEAPON
            || CraftingSelectedRecipeKind
                == CaelumConstants.CRAFTING_RECIPE_KIND_ESSENCE_WEAPON
            || CraftingSelectedRecipeKind
                == CaelumConstants.CRAFTING_RECIPE_KIND_SHIELD
            || CraftingSelectedRecipeKind
                == CaelumConstants.CRAFTING_RECIPE_KIND_ARMOR
            || CraftingSelectedRecipeKind
                == CaelumConstants.CRAFTING_RECIPE_KIND_AMULET
            || CraftingSelectedRecipeKind
                == CaelumConstants.CRAFTING_RECIPE_KIND_SEAL)
        {
            CraftingPreviewIconPath = CaelumIconResolver.ResolveTierPath(
                CraftingPreviewIconPath, CraftingSelectionTier
            );
        }

        RefreshCarriedInventorySummary();
    }

    int BeginCraftingNetworkScan()
    {
        CraftingNetworkCapabilities = 0;
        CraftingNetworkScanToken++;
        if (CraftingNetworkScanToken <= 0) { CraftingNetworkScanToken = 1; }
        return CraftingNetworkScanToken;
    }

    void SetCraftingJournalState(bool shouldOpen)
    {
        if (player == null) { return; }
        CVar openState = CVar.GetCVar("ca_journal_open", player);
        CVar pageState = CVar.GetCVar("ca_journal_page", player);
        if (openState != null) { openState.SetBool(shouldOpen); }
        if (shouldOpen && pageState != null) { pageState.SetInt(3); }
    }

    void OpenCraftingNetwork(Actor sourceStation)
    {
        bool hasPrimaryStation;

        if (!CaelumCraftingRules.NetworkHasStation(
            CraftingNetworkCapabilities,
            CaelumConstants.CRAFTING_STATION_WORKBENCH
        ))
        {
            A_Log("$CA_CRAFTING_NETWORK_MISSING_WORKBENCH");
            CraftingMenuOpen = false;
            ActiveCraftingStationActor = null;
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
            )
            || CaelumCraftingRules.NetworkHasStation(
                CraftingNetworkCapabilities,
                CaelumConstants.CRAFTING_STATION_SEWING_MACHINE
            );

        if (!hasPrimaryStation)
        {
            A_Log("$CA_CRAFTING_NETWORK_MISSING_PRIMARY");
            CraftingMenuOpen = false;
            ActiveCraftingStationActor = null;
            return;
        }

        // Cualquier estación conectada abre el mismo menú central.
        ActiveCraftingStationActor = sourceStation;
        CraftingSessionValidationTics = 0;
        OpenCraftingStation(CaelumConstants.CRAFTING_STATION_WORKBENCH);
    }

    void OpenCraftingStation(int stationType)
    {
        if (CreationWizardOpen) { return; }
        int resolvedStation = CaelumCraftingRules.ResolveStationType(stationType);
        if (resolvedStation == CaelumConstants.CRAFTING_STATION_NONE) { return; }

        if (StaffCastPending) { CancelPendingStaffCast(false); }
        ClosePalomoMerchant();
        EquipmentMenuOpen = false;
        CraftingMenuOpen = true;
        ActiveCraftingStationType = resolvedStation;
        CraftingSelectionRecipe = 0;
        CraftingRecipeFilter = CaelumConstants.CRAFTING_RECIPE_FILTER_ALL;
        if (CraftingSelectionTier <= 0)
        {
            CraftingSelectionTier = 1;
            CraftingSelectionSize = CaelumConstants.EQUIPMENT_SIZE_M;
        }
        LastCraftingAction = CaelumConstants.CRAFTING_ACTION_NONE;
        LastEquipmentAction = CaelumConstants.EQUIPMENT_ACTION_NONE;
        RefreshCraftingPreview();
        SetCraftingJournalState(true);
    }

    void CloseCraftingStationSession()
    {
        CaelumTimeAdvanceState.Halt(self);
        CraftingMenuOpen = false;
        ActiveCraftingStationType = CaelumConstants.CRAFTING_STATION_NONE;
        ActiveCraftingStationActor = null;
        CraftingSessionValidationTics = 0;
        CraftingTaskProgressing = false;
    }

    bool RefreshActiveCraftingStationSession(bool recipeInfrastructure = true)
    {
        CaelumCraftingStation station =
            CaelumCraftingStation(ActiveCraftingStationActor);
        if (!CraftingMenuOpen)
        {
            return false;
        }
        if (station == null || player == null
            || player.playerstate != PST_LIVE || health <= 0)
        {
            CloseCraftingStationSession();
            SetCraftingJournalState(false);
            return false;
        }
        double dx = station.Pos.X - Pos.X;
        double dy = station.Pos.Y - Pos.Y;
        double dz = station.Pos.Z - Pos.Z;
        double maximumDistance =
            CaelumConstants.CRAFTING_ACTIVE_STATION_DISTANCE;
        if (!station.CanReachFrom(self) || dx * dx + dy * dy + dz * dz
            > maximumDistance * maximumDistance)
        {
            CloseCraftingStationSession();
            SetCraftingJournalState(false);
            return false;
        }

        // Entrar en combate no cancela ni libera la reserva. La tarea queda
        // pausada hasta que el personaje vuelva a estar fuera de combate y
        // continúe atendiendo esta misma estación.
        if (CombatTimeRemaining > 0.0)
        {
            return false;
        }

        if (CraftingSessionValidationTics <= 0)
        {
            int scanToken = BeginCraftingNetworkScan();
            station.CollectCraftingNetwork(self, scanToken);
            CraftingSessionValidationTics = TICRATE;
            RefreshCraftingPreview();
        }
        else
        {
            CraftingSessionValidationTics--;
        }
        if (CraftingTaskActive)
        {
            return (CraftingNetworkCapabilities
                & CraftingTaskNetworkCapabilities)
                == CraftingTaskNetworkCapabilities;
        }
        return !recipeInfrastructure || CraftingSelectedInfrastructureAvailable;
    }

    void ToggleCraftingMenu()
    {
        // La tecla de crafteo ya no abre una estación virtual desde cualquier
        // lugar. Sirve para cerrar el menú; la apertura real ocurre usando
        // un actor CaelumCraftingStation del escenario.
        if (CraftingMenuOpen)
        {
            CloseCraftingStationSession();
            SetCraftingJournalState(false);
        }
    }

    void CycleCraftingRecipe(int direction)
    {
        bool unifiedCatalogue = ActiveCraftingStationType == CaelumConstants.CRAFTING_STATION_WORKBENCH
            || ActiveCraftingStationType == CaelumConstants.CRAFTING_STATION_NONE;
        int stationRecipeCount = unifiedCatalogue ? CaelumConstants.CRAFTING_NETWORK_PLAYABLE_RECIPE_COUNT
            : CaelumCraftingRules.GetStationRecipeCount(ActiveCraftingStationType);
        if (stationRecipeCount <= 0) { return; }
        int step = direction < 0 ? -1 : 1;
        for (int offset = 1; offset <= stationRecipeCount; offset++)
        {
            int candidate = (
                CraftingSelectionRecipe + step * offset
                    + stationRecipeCount * 2
            ) % stationRecipeCount;
            if ((!unifiedCatalogue || IsCraftingRecipeKnown(candidate)) && CaelumCraftingRules.RecipeMatchesFilter(
                candidate, CraftingRecipeFilter
            ))
            {
                CraftingSelectionRecipe = candidate;
                break;
            }
        }
        LastCraftingAction = CaelumConstants.CRAFTING_ACTION_NONE;
        RefreshCraftingPreview();
    }

    void CycleCraftingRecipeFilter()
    {
        if (ActiveCraftingStationType
            != CaelumConstants.CRAFTING_STATION_WORKBENCH
            && ActiveCraftingStationType != CaelumConstants.CRAFTING_STATION_NONE)
        {
            CraftingRecipeFilter =
                CaelumConstants.CRAFTING_RECIPE_FILTER_ALL;
            return;
        }
        CraftingRecipeFilter = (CraftingRecipeFilter + 1)
            % CaelumConstants.CRAFTING_RECIPE_FILTER_COUNT;
        CraftingSelectionRecipe =
            GetFirstKnownCraftingRecipe();
        LastCraftingAction = CaelumConstants.CRAFTING_ACTION_NONE;
        RefreshCraftingPreview();
    }

    void CycleCraftingTier()
    {
        RefreshCraftingPreview();
        if (CraftingSelectedRecipeKind
            == CaelumConstants.CRAFTING_RECIPE_KIND_PROCESSING)
        {
            CraftingProcessingBatchIndex = (CraftingProcessingBatchIndex + 1)
                % CaelumConstants.CRAFTING_PROCESSING_BATCH_OPTION_COUNT;
            LastCraftingAction = CaelumConstants.CRAFTING_ACTION_NONE;
            RefreshCraftingPreview();
            return;
        }
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
        if (CraftingSelectedRecipeKind
                == CaelumConstants.CRAFTING_RECIPE_KIND_PROCESSING
            || CraftingSelectedRecipeKind
                == CaelumConstants.CRAFTING_RECIPE_KIND_COMPONENT)
        {
            CycleCraftingEfficiency();
            return;
        }
        CraftingSelectionSize = (CraftingSelectionSize + 1)
            % CaelumConstants.EQUIPMENT_SIZE_COUNT;
        LastCraftingAction = CaelumConstants.CRAFTING_ACTION_NONE;
        RefreshCraftingPreview();
    }

    void CycleCraftingEfficiency()
    {
        RefreshCraftingPreview();
        int selectedNode = Clamp(
            CraftingBlueprintSelectedNode,
            0, Max(0, CraftingBlueprintNodeCount - 1)
        );
        if (selectedNode > 0
            && CraftingBlueprintNodeKind[selectedNode]
                == CaelumConstants.CRAFTING_BLUEPRINT_NODE_RECIPE)
        {
            int recipeIndex = CraftingBlueprintNodeRecipe[selectedNode];
            int materialTier =
                CraftingBlueprintNodeMaterialTier[selectedNode];
            int nextEfficiency =
                (GetCraftingLayerEfficiencyIndex(
                    recipeIndex, materialTier
                ) + 1)
                % CaelumConstants.CRAFTING_EFFICIENCY_OPTION_COUNT;
            SetCraftingLayerEfficiencyIndex(
                recipeIndex, materialTier, nextEfficiency
            );
        }
        else
        {
            CraftingEfficiencyIndex = (CraftingEfficiencyIndex + 1)
                % CaelumConstants.CRAFTING_EFFICIENCY_OPTION_COUNT;
        }
        LastCraftingAction = CaelumConstants.CRAFTING_ACTION_NONE;
        RefreshCraftingPreview();
    }

    void CycleCraftingBatch()
    {
        RefreshCraftingPreview();
        if (CraftingSelectedRecipeKind
                != CaelumConstants.CRAFTING_RECIPE_KIND_PROCESSING
            && CraftingSelectedRecipeKind
                != CaelumConstants.CRAFTING_RECIPE_KIND_COMPONENT)
        {
            return;
        }
        CraftingProcessingBatchIndex = (CraftingProcessingBatchIndex + 1)
            % CaelumConstants.CRAFTING_PROCESSING_BATCH_OPTION_COUNT;
        LastCraftingAction = CaelumConstants.CRAFTING_ACTION_NONE;
        RefreshCraftingPreview();
    }

    bool ConsumeCraftingMaterial(
        int materialType, int materialTier, int requiredAmount
    )
    {
        return CaelumInventoryService.ConsumeCraftingMaterial(self, materialType, materialTier, requiredAmount);
    }

    bool HasCraftingFinishMaterials()
    {
        return CaelumInventoryService.HasCraftingFinishMaterials(self);
    }

    bool ConsumeCraftingFinishMaterials()
    {
        return CaelumInventoryService.ConsumeCraftingFinishMaterials(self);
    }

    void SpawnSelectedCraftingMaterials()
    {
        if (player == null || player.playerstate != PST_LIVE) { return; }
        RefreshCraftingPreview();
        if (!CraftingSelectedRecipeKnown)
        {
            LastCraftingAction =
                CaelumConstants.CRAFTING_ACTION_FAILED_RECIPE_LOCKED;
            return;
        }
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
        if (CraftingTierRequired > 0)
        {
            CaelumMaterialPickup tierMaterial = CaelumMaterialPickup(
                Spawn("CaelumMaterialPickup", Pos + forward + side, NO_REPLACE)
            );
            if (tierMaterial != null)
            {
                tierMaterial.args[0] = CraftingTierMaterialType;
                tierMaterial.args[1] = CraftingTierMaterialTier;
                tierMaterial.Amount = CraftingTierRequired;
            }
        }
        if (CraftingSilverRequired > 0)
        {
            CaelumMaterialPickup silverMaterial = CaelumMaterialPickup(
                Spawn(
                    "CaelumMaterialPickup",
                    Pos + forward - side * 2.0,
                    NO_REPLACE
                )
            );
            if (silverMaterial != null)
            {
                silverMaterial.args[0] =
                    CaelumConstants.MATERIAL_SILVER_INGOT;
                silverMaterial.args[1] = 1;
                silverMaterial.Amount = CraftingSilverRequired;
            }
        }
        if (CraftingGoldRequired > 0)
        {
            CaelumMaterialPickup goldMaterial = CaelumMaterialPickup(
                Spawn(
                    "CaelumMaterialPickup",
                    Pos + forward + side * 2.0,
                    NO_REPLACE
                )
            );
            if (goldMaterial != null)
            {
                goldMaterial.args[0] = CaelumConstants.MATERIAL_GOLD_INGOT;
                goldMaterial.args[1] = 1;
                goldMaterial.Amount = CraftingGoldRequired;
            }
        }
        LastCraftingAction =
            CaelumConstants.CRAFTING_ACTION_MATERIALS_SPAWNED;
    }

    void CraftSelectedProcessingRecipe()
    {
        CaelumInventoryService.CraftSelectedProcessingRecipe(self);
    }

    void CraftSelectedArmorRecipe()
    {
        CaelumInventoryService.CraftSelectedArmorRecipe(self);
    }

    void CraftSelectedShieldRecipe()
    {
        CaelumInventoryService.CraftSelectedShieldRecipe(self);
    }

    void CraftSelectedEssenceWeaponRecipe()
    {
        CaelumInventoryService.CraftSelectedEssenceWeaponRecipe(self);
    }

    void CraftSelectedJewelry(bool seal)
    {
        CaelumInventoryService.CraftSelectedJewelry(self, seal);
    }

    void CraftSelectedAmmunition()
    {
        CaelumInventoryService.CraftSelectedAmmunition(self);
    }

    void CraftSelectedPhysicalWeapon()
    {
        CaelumInventoryService.CraftSelectedPhysicalWeapon(self);
    }

    void ToggleEquipmentMenu()
    {
        if (CreationWizardOpen) { return; }
        EquipmentMenuOpen = !EquipmentMenuOpen;
        if (!EquipmentMenuOpen) { return; }
        if (StaffCastPending) { CancelPendingStaffCast(false); }
        CloseCraftingStationSession();
        LastEquipmentAction = CaelumConstants.EQUIPMENT_ACTION_NONE;
        EquipmentSelectionItemId = 0;
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
        EquipmentSelectionItemId = 0;
        EquipmentSelectionKind = (EquipmentSelectionKind + 1)
            % CaelumConstants.EQUIPMENT_KIND_COUNT;
        RefreshEquipmentSelectionPreview();
    }

    Name GetConsumableClassName(int consumableType)
    {
        return CaelumInventoryService.GetConsumableClassName(self, consumableType);
    }

    double GetAmmunitionUnitWeight(int ammunitionType)
    {
        return CaelumInventoryService.GetAmmunitionUnitWeight(self, ammunitionType);
    }

    Name GetAmmunitionClassName(int ammunitionType)
    {
        return CaelumInventoryService.GetAmmunitionClassName(self, ammunitionType);
    }

    Name GetSpecialItemClassName(int specialCategory, int specialType)
    {
        return CaelumInventoryService.GetSpecialItemClassName(self, specialCategory, specialType);
    }

    void UseSelectedConsumable()
    {
        CaelumInventoryService.UseSelectedConsumable(self);
    }

    void CycleEquipmentSlot(int direction)
    {
        EquipmentSelectionItemId = 0;
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
        EquipmentSelectionItemId = 0;
        if (EquipmentSelectionKind
            == CaelumConstants.EQUIPMENT_KIND_AMMUNITION)
        {
            int index=EquipmentSelectionAmmunitionType==CaelumConstants.AMMUNITION_SHOTGUN ? 3 : EquipmentSelectionAmmunitionType;
            index=(index+direction+4)%4;
            EquipmentSelectionAmmunitionType=index==3 ? CaelumConstants.AMMUNITION_SHOTGUN : index;
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
            else if (EquipmentSelectionKind
                == CaelumConstants.EQUIPMENT_KIND_CURRENCY)
            {
                typeCount = CaelumConstants.CURRENCY_TYPE_COUNT;
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
        EquipmentSelectionItemId = 0;
        if (EquipmentSelectionKind
                == CaelumConstants.EQUIPMENT_KIND_AMMUNITION
            || EquipmentSelectionKind
                == CaelumConstants.EQUIPMENT_KIND_CONSUMABLE
            || EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_KEY
            || EquipmentSelectionKind
                == CaelumConstants.EQUIPMENT_KIND_KEY_ITEM
            || EquipmentSelectionKind
                == CaelumConstants.EQUIPMENT_KIND_CURRENCY) { return; }
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
        EquipmentSelectionItemId = 0;
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
        CaelumInventoryService.SyncActiveModelsToNativeInventory(self);
    }

    CaelumEquipmentItem GetSelectedNativeEquipmentItem()
    {
        return CaelumInventoryService.GetSelectedNativeEquipmentItem(self);
    }

    void EquipSelectedNativeEquipment()
    {
        CaelumInventoryService.EquipSelectedNativeEquipment(self);
    }

    void UnequipSelectedNativeEquipment()
    {
        CaelumInventoryService.UnequipSelectedNativeEquipment(self);
    }

    void ToggleSelectedMagicBox()
    {
        CaelumInventoryService.ToggleSelectedMagicBox(self);
    }

    void ToggleSelectedMagicBoxNative()
    {
        CaelumInventoryService.ToggleSelectedMagicBoxNative(self);
    }

    void EquipSelectedEquipment()
    {
        CaelumInventoryService.EquipSelectedEquipment(self);
    }

    void UnequipSelectedEquipment()
    {
        CaelumInventoryService.UnequipSelectedEquipment(self);
    }

    void SpawnSelectedNativePickupOnFloor()
    {
        CaelumInventoryService.SpawnSelectedNativePickupOnFloor(self);
    }

    bool IsDurabilityTaskEquipment(CaelumEquipmentItem item)
    {
        return CaelumInventoryService.IsDurabilityTaskEquipment(self, item);
    }

    int GetEquipmentTaskMaximumDurability(CaelumEquipmentItem item)
    {
        return CaelumInventoryService.GetEquipmentTaskMaximumDurability(self, item);
    }

    double GetEquipmentTaskWeight(CaelumEquipmentItem item)
    {
        return CaelumInventoryService.GetEquipmentTaskWeight(self, item);
    }

    bool AddScaledEquipmentTaskMaterial(
        int materialType, int materialTier, int fullUnits,
        double durabilityFraction, bool recovery, CaelumCraftingBrowser preview = null
    )
    {
        return CaelumInventoryService.AddScaledEquipmentTaskMaterial(self, materialType, materialTier, fullUnits, durabilityFraction, recovery, preview);
    }

    bool BuildEquipmentTaskMaterials(
        CaelumEquipmentItem item, double durabilityFraction, bool recovery, CaelumCraftingBrowser preview = null
    )
    {
        return CaelumInventoryService.BuildEquipmentTaskMaterials(self, item, durabilityFraction, recovery, preview);
    }

    int GetMissingEquipmentTaskStation(CaelumEquipmentItem item)
    {
        return CaelumInventoryService.GetMissingEquipmentTaskStation(self, item);
    }

    bool CanCompletePreparedDismantle(
        CaelumEquipmentItem target, bool sendOutputsToMagicBox, CaelumCraftingBrowser preview = null
    )
    {
        return CaelumInventoryService.CanCompletePreparedDismantle(self, target, sendOutputsToMagicBox, preview);
    }

    int GetDismantleNetBoxSlots(CaelumEquipmentItem target, CaelumCraftingBrowser preview = null)
    {
        return CaelumInventoryService.GetDismantleNetBoxSlots(self, target, preview);
    }

    int GetCraftingTaskReservedUnitTotal()
    {
        return CaelumInventoryService.GetCraftingTaskReservedUnitTotal(self);
    }

    int GetEquipmentTaskComplexityTics(CaelumEquipmentItem item)
    {
        return CaelumInventoryService.GetEquipmentTaskComplexityTics(self, item);
    }

    double GetEquipmentTaskSeconds(
        CaelumEquipmentItem item, int employedMaterialUnits,
        int efficiencyIndex
    )
    {
        return CaelumInventoryService.GetEquipmentTaskSeconds(self, item, employedMaterialUnits, efficiencyIndex);
    }

    bool KnowsWeaponRepairRecipe(CaelumEquipmentItem item)
    {
        return CaelumInventoryService.KnowsWeaponRepairRecipe(self, item);
    }

    // Misma validación para la vista previa y la transacción autoritativa.
    int GetEquipmentTaskBlockReason(CaelumEquipmentItem target, bool dismantle)
    {
        return CaelumInventoryService.GetEquipmentTaskBlockReason(self, target, dismantle);
    }

    void BeginRepairSelectedEquipment(int targetItemId = 0)
    {
        CaelumInventoryService.BeginRepairSelectedEquipment(self, targetItemId);
    }

    void BeginDismantleSelectedEquipment(int targetItemId = 0)
    {
        CaelumInventoryService.BeginDismantleSelectedEquipment(self, targetItemId);
    }

    bool ConsumeCraftingTaskReservations()
    {
        return CaelumInventoryService.ConsumeCraftingTaskReservations(self);
    }

    bool CompleteRepairTask()
    {
        return CaelumInventoryService.CompleteRepairTask(self);
    }

    bool CompleteDismantleTask()
    {
        return CaelumInventoryService.CompleteDismantleTask(self);
    }

    void CompleteCraftingTask()
    {
        CaelumInventoryService.CompleteCraftingTask(self);
    }

    void AdvanceDebugCraftingTime()
    {
        if (!CraftingTaskActive || CraftingTaskCompleting
            || !RefreshActiveCraftingStationSession())
        {
            LastCraftingAction =
                CaelumConstants.CRAFTING_ACTION_DEBUG_TIME_BLOCKED;
            return;
        }
        CraftingTaskRemainingSeconds = Max(
            0.0,
            CraftingTaskRemainingSeconds
                - CaelumConstants.CRAFTING_DEBUG_ADVANCE_SECONDS
        );
        LastCraftingAction =
            CaelumConstants.CRAFTING_ACTION_DEBUG_TIME_ADVANCED;
        if (CraftingTaskRemainingSeconds <= 0.0)
        {
            CompleteCraftingTask();
            return;
        }
        PersistCharacterState();
        RefreshFormalInventorySnapshot();
        if (CraftingMenuOpen) { RefreshCraftingPreview(); }
    }

    void UpdateCraftingTask()
    {
        CraftingTaskProgressing = false;
        if (CaelumSleepRules.IsSleeping(self)
            || (CaelumTimeSkipState.IsActive(self) && CaelumScheduleState.SiegeActive(self,level.MapName))) return;
        if (!CraftingTaskActive || CraftingTaskCompleting) { return; }
        if (!RefreshActiveCraftingStationSession()) { return; }
        CraftingTaskProgressing = true;
        CaelumTimeSkipState.RecordWork(self);
        CraftingTaskRemainingSeconds = Max(
            0.0,
            CraftingTaskRemainingSeconds - 1.0 / TICRATE
        );
        if (CraftingTaskRemainingSeconds <= 0.0)
        {
            CompleteCraftingTask();
        }
    }

    void BreakSelectedNativeEquipment()
    {
        CaelumInventoryService.BreakSelectedNativeEquipment(self);
    }

    CaelumMaterialPickup CreateDetachedMaterialStack(
        int materialType, int materialTier, int materialAmount
    )
    {
        return CaelumInventoryService.CreateDetachedMaterialStack(self, materialType, materialTier, materialAmount);
    }

    void AddRecoveredMaterial(
        CaelumSpecialInventoryItem existing,
        CaelumMaterialPickup detached,
        int recoveredAmount,
        bool sendToMagicBox
    )
    {
        CaelumInventoryService.AddRecoveredMaterial(self, existing, detached, recoveredAmount, sendToMagicBox);
    }

    void DismantleSelectedNativeWeapon()
    {
        CaelumInventoryService.DismantleSelectedNativeWeapon(self);
    }

    void DropSelectedNativeInventoryItem()
    {
        CaelumInventoryService.DropSelectedNativeInventoryItem(self);
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
        CaelumInventoryService.BreakSelectedEquipment(self);
    }

    void DropSelectedEquipment()
    {
        CaelumInventoryService.DropSelectedEquipment(self);
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
        CaelumPlayerPresentation.SyncHUDLoadState(self);
    }

    // Solicitud de una salida confirmada por tarot; se consume en el cruce.
    int PendingTravelWipe;

    override void PreTravelled()
    {
        let journey = CaelumJourneyState.Get(self);
        int mode = journey != null && journey.Status == CaelumJourneyState.STATUS_DEPARTED
            ? journey.TravelMode : 0;
        int wipe = PendingTravelWipe;
        int cue = 0;
        if (mode == CaelumJourneyState.MODE_SHIP) { wipe=1; cue=2; }
        else if (mode == CaelumJourneyState.MODE_CART || mode == CaelumJourneyState.MODE_CARAVAN) { wipe=3; cue=1; }
        EventHandler.SendInterfaceEvent(PlayerNumber(), "ca_map_depart", wipe, cue);
        PendingTravelWipe = 0;
        WorldCarbineShotUntil = 0;
        EquipmentMenuOpen = false;
        CloseCraftingStationSession();
        ClosePalomoMerchant();
        PersistCharacterState();
        Super.PreTravelled();
    }

    override void Travelled()
    {
        Super.Travelled();
        RestorePersistentCharacterState();
        CaelumTarotService.RestoreNativeEffect(self);
    }

    // PostBeginPlay runs after this player actor has entered the game world.
    // It is a suitable place for first-time initialization of owned objects.
    override void PostBeginPlay()
    {
        Super.PostBeginPlay();
        CollisionDamageMultiplier = 1.0;
        ActiveCraftingStationType = CaelumConstants.CRAFTING_STATION_NONE;
        ActiveCraftingStationActor = null;
        CraftingTaskProgressing = false;

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
        bool initializedNewCharacter = false;
        if (!restoredPersistentState)
        {
            initializedNewCharacter = ConsumeNewCharacterDraft();
            if (!initializedNewCharacter)
            {
                InitializeDirectMapCharacter();
                initializedNewCharacter = true;
            }
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
            "[Caelum] Character creation values loaded. Attribute total: %.2f",
            Attributes.GetTotalPrimaryLevels()
        );
        RefreshEquipmentSelectionPreview();
        RefreshFormalInventorySnapshot();
        RefreshSocialJournalSnapshot();

        if (initializedNewCharacter)
        {
            PersistCharacterState();
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

    double GetImpactToughnessMultiplier(double incomingPercent = 100.0)
    {
        double toughness = Attributes != null ? Max(0.0, Attributes.Toughness) : 0.0;
        if (IsBucklerAcrobaticDefenseActive())
            toughness *= CaelumConstants.SHIELD_BUCKLER_IMPACT_TOUGHNESS_MULTIPLIER;
        return CaelumArmorRules.ToughnessMultiplier(incomingPercent, 100.0, toughness);
    }

    double GetArmorDefensePercent(int slot, bool magical = false,Actor inflictor=null)
    {
        int race = CharacterProfile != null ? CharacterProfile.Race : CaelumConstants.RACE_HUMAN;
        return CaelumArmorRules.TotalDefense(CaelumArmorRules.InnateDefense(race, magical), ArmorModel, slot, magical,inflictor);
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

    double GetImpactAgilityAbsorptionSpeed(int impactKind, bool stationarySceneryContact = false)
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

        // Caminar, correr o agacharse permite ceder ante paredes y escenario
        // quieto. El contacto guarda el reposo previo a transmitir impulso;
        // no concede este beneficio a cuerpos ni rocas que ya venían moviéndose.
        double carefulMovementFraction = 0.0;
        if ((IsCrouching || IsWalkingOnGround() || IsRunningOnGround())
            && (impactKind == CaelumConstants.IMPACT_KIND_WALL
                || (impactKind == CaelumConstants.IMPACT_KIND_ENVIRONMENT
                    && stationarySceneryContact)))
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
        double totalOverlap,
        Actor inflictor=null
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
            double defenseRatio = Clamp(GetArmorDefensePercent(slot,false,inflictor) / 100.0, 0.0, 1.0);
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
        double contactMaximumHeightRatio,
        bool stationarySceneryContact = false
    )
    {
        // El escenario y las rocas del mecanismo son daño ambiental, aunque
        // GZDoom los represente con actores: ni daño ni dolor dan adrenalina.
        if (CaelumHazardRock(sourceActor) != null
            || (impactKind == CaelumConstants.IMPACT_KIND_ACTOR
                && CaelumEnvironmentProp(sourceActor) != null))
            impactKind = CaelumConstants.IMPACT_KIND_ENVIRONMENT;
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
                GetImpactAgilityAbsorptionSpeed(impactKind, stationarySceneryContact);
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
        double impactToughness = 0.0;
        if (Attributes != null)
        {
            impactToughness = Max(
                0.0,
                double(Attributes.Toughness)
            );
            if (IsBucklerAcrobaticDefenseActive())
            {
                impactToughness *=
                    CaelumConstants.SHIELD_BUCKLER_IMPACT_TOUGHNESS_MULTIPLIER;
            }
        }
        LastImpactToughnessPercent = CaelumArmorRules.ToughnessReductionPercent(impactToughness);
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
        LastImpactToughnessMultiplier = GetImpactToughnessMultiplier(surfacedDamagePercent);
        LastImpactPostToughnessPercent = CaelumArmorRules.AfterToughnessPercent(
            surfacedDamagePercent, impactToughness);

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
                double defenseRatio = Clamp(GetArmorDefensePercent(slot,false,sourceActor) / 100.0, 0.0, 1.0);

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
                totalOverlap,sourceActor
            );
        }
        if (LastImpactFinalDamage <= 0) { return; }

        Actor impactSource = sourceActor;
        if (impactSource == null)
        {
            impactSource = self;
        }
        // El núcleo ya resolvió el impulso; el daño no añade empuje de Doom.
        int impactFlags = DMG_NO_ARMOR;
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

    bool IsCaelumCollisionBody(Actor other)
    {
        CaelumCombatActor combatActor = CaelumCombatActor(other);
        CaelumEnvironmentProp environment = CaelumEnvironmentProp(other);
        return other != null
            && other != self
            && other.health > 0
            && (combatActor == null
                || !combatActor.DisableCaelumImpactContacts)
            && (CaelumPlayer(other) != null
                || combatActor != null
                || CaelumTrainingDummy(other) != null
                || environment != null);
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
                ImpactContacts.Delete(index);
                ImpactDiagnosticContactsRemoved++;
            }
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

        // Convierte el impulso acumulado de presion a su velocidad de cierre
        // equivalente, conservando masa, anatomia y la curva universal.
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

    // Los árboles arraigados son actores, pero físicamente se comportan como
    // el límite estático de una pared. Conservamos el actor para modelo, masa
    // y futura recolección sin transmitirle velocidad ni repetir daño mientras
    // el mismo contacto siga activo.
    void ResolveRootedEnvironmentImpact(CaelumEnvironmentProp environment)
    {
        if (environment == null || environment.health <= 0) { return; }

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
            environment.GetEnvironmentMassKg(),
            impact.ClosingSpeed,
            impact.Impulse,
            contactMinimum,
            contactMaximum,
            true
        );
    }

    override void CollidedWith(Actor other, bool passive)
    {
        Super.CollidedWith(other, passive);

        // El apoyo desde arriba tiene su propio contacto vertical, una sola vez.
        let hazard = CaelumHazardRock(other);
        if (hazard != null && hazard.IsDescendingAbove(self)) return;

        // CollidedWith se ejecuta en ambos actores. Normalmente sólo el lado
        // activo resuelve; una roca ambiental no posee receptor biológico, así
        // que el jugador acepta el callback pasivo cuando la roca lo alcanza.
        CaelumEnvironmentProp environment = CaelumEnvironmentProp(other);
        bool resolvePassiveRock = environment != null
            && environment.IsEnvironmentMovable();
        if ((passive && !resolvePassiveRock)
            || !IsCaelumCollisionBody(other) || health <= 0)
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

        // A partir de aquí es un único impacto. Mantener presión contra el
        // mismo cuerpo no vuelve a crear choques hasta separarse físicamente.
        contactState = LatchImpactContact(other);
        if (contactState != null)
        {
            contactState.BeginResolutionTick(level.time);
            contactState.LastClosingSpeed = impact.ClosingSpeed;
            contactState.LastTransmittedImpulse = impact.Impulse;
        }

        // La roca puede empezar a moverse por este mismo choque. Determinar
        // antes del impulso si el jugador encontró un obstáculo en reposo.
        bool stationarySceneryContact = environment != null
            && other.Vel.LengthSquared() == 0.0;
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
            impact.SourceContactMaximumHeightRatio,
            stationarySceneryContact
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

    // El combate tutorial intercepta la muerte antes de los efectos nativos.
    // El reinicio se difiere al WorldTick para terminar primero el daño actual.
    override void Die(Actor source, Actor inflictor, int dmgflags, Name MeansOfDeath)
    {
        CaelumRestState.Interrupt(self, "CA_REST_DAMAGE");
        if (CaelumMainM00RuloTrial.PreventDefeat(self)) return;
        CaelumBreathing.StopAudio(self);
        Super.Die(source, inflictor, dmgflags, MeansOfDeath);
    }

    // Estado visual individual; el daño real sigue en las mismas rutas de defensa.
    int PendingDamageVFXKind,DamageVFXKind,DamageVFXTic,DamageFeedbackRevision;
    double DamageVFXStrength;

    override int DamageMobj(Actor inflictor,Actor source,int damage,Name mod,int flags,double angle)
    {
        int before=health;
        int result=ReceiveCaelumDamage(inflictor,source,damage,mod,flags,angle);
        CaelumDamageFeedback.Record(self,inflictor,mod,Max(0,Max(0,before)-Max(0,health)));
        return result;
    }

    int ReceiveCaelumDamage(
        Actor inflictor,
        Actor source,
        int damage,
        Name mod,
        int flags,
        double angle
    )
    {
        if (damage > 0) ForcedSleepTics = 0;
        CaelumTimeAdvanceState.Halt(self);
        if (CaelumMainM00RuloTrial.IsPartyMember(source, self)) return 0;

        // El mundo no puede dañar al personaje antes de confirmar su creación.
        if (CreationWizardOpen && !CharacterCreationComplete)
        {
            return 0;
        }

        // Ahogamiento y aplastamiento nativo actualizan vida, dolor e
        // interrupciones, sin iniciar combate ni otorgar adrenalina.
        if (mod == 'Drowning' || mod == 'Crush' || mod == 'CaelumWeight')
        {
            // El techo nativo expresa su pulso en porcentaje de vida máxima.
            // Ahogamiento ya llega convertido; otras fuentes Crush conservan
            // sus unidades. P_DoCrunch envía source e inflictor nulos.
            if (mod == 'Crush' && inflictor == null && source == null)
                damage = CaelumCrushingDamage.FromNativePercent(GetImpactMaximumHealth(), damage);
            int healthBeforeDrowning = health;
            double adrenalineRatioBeforeDrowning = 0.0;
            if (DerivedStats != null && DerivedStats.MaximumAdrenaline > 0.0)
            {
                adrenalineRatioBeforeDrowning = Clamp(
                    CurrentAdrenaline / DerivedStats.MaximumAdrenaline,
                    0.0,
                    1.0
                );
            }

            int drowningResult = Super.DamageMobj(
                inflictor,
                source,
                damage,
                mod,
                flags | DMG_NO_ARMOR,
                angle
            );
            if (health < healthBeforeDrowning)
            {
                int actualDrowningHealthLost = healthBeforeDrowning - health;
                TryInterruptPendingStaffCast(
                    actualDrowningHealthLost,
                    adrenalineRatioBeforeDrowning
                );
                UpdateHealthStateEffects();
                CalculateAndTriggerPain(
                    actualDrowningHealthLost,
                    adrenalineRatioBeforeDrowning,
                    false
                );
            }
            return drowningResult;
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

        damage=CaelumThermalEffects.Incoming(self,inflictor,source,damage,mod);

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
        if (mod == 'Electric' && inflictor is 'CaelumChannelEffect') { return true; }
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
        CaelumThermalMagic.Impact(self,inflictor,CaelumThermalMagic.AreaRetention(self,LastExplosionTouchedRegionMask));

        bool magical = CaelumArmorRules.IsMagical(inflictor, mod);
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
        LastToughnessDamageMultiplier = 1.0;
        double totalPostAnatomyDamage = 0.0;
        double toughness = Attributes != null ? Attributes.Toughness : 0.0;

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
            double postAnatomyDamage = incomingDamage * vulnerabilityMultiplier;
            totalPostAnatomyDamage += postAnatomyDamage;
            double preDefenseDamage = CaelumArmorRules.AfterToughnessDamage(
                postAnatomyDamage, GetImpactMaximumHealth(), toughness);
            double defenseRatio = Clamp(GetArmorDefensePercent(slot, magical,inflictor) / 100.0, 0.0, 1.0);
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
                int(postDefenseDamage + 0.5)
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
                double eligibleDamage = preDefenseDamage * ArmorModel.GetDefense(slot, magical) / 100.0*CaelumArmorRules.EquipmentRetention(inflictor)
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

        LastToughnessDamageMultiplier = totalPostAnatomyDamage > 0.0
            ? LastArmorPreDefenseDamage / totalPostAnatomyDamage : 1.0;
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
                mod != 'CaelumTrapMagic'
            );
            if (mod != 'CaelumTrapMagic')
            {
                AddCombatAdrenaline(
                    CaelumConstants.ADRENALINE_GAIN_ON_DAMAGE,
                    CaelumConstants.ADRENALINE_EVENT_DAMAGE
                );
                MarkCombatActivity();
            }
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
        double thermalShield=LastShieldBlockedAttack
            ? 1-Clamp(GetActiveBlockDefense(CaelumConstants.SHIELD_DAMAGE_MAGICAL)/100.0,0.0,1.0) : 1;
        CaelumThermalMagic.Impact(self,inflictor,thermalShield*CaelumThermalMagic.ArmorRetention(self,LastIncomingArmorSlot));
        PrepareRealArmorDamage(
            damageAfterShield,
            incomingActorCritical,
            LastIncomingArmorSlot,
            CaelumArmorRules.IsMagical(inflictor, mod),inflictor
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
                    GetArmorDefensePercent(LastIncomingArmorSlot, CaelumArmorRules.IsMagical(inflictor, mod),inflictor) / 100.0,
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
            // Una explosión de área es síncrona y puede alcanzar a más de un
            // receptor. Todos comparten la misma tirada; consumirla en el
            // primero volvería no críticos a los demás de forma accidental.
            LastIncomingActorCriticalHit = attacker.CombatAreaExplosionActive
                ? attacker.GetCombatAreaExplosionCriticalHit()
                : attacker.ConsumePendingCombatCritical();
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

        // La descarga de canalización ya omitía el escudo antes de #52.
        if (mod == 'Electric' && inflictor is 'CaelumChannelEffect')
        {
            LastShieldWithinCoverage = false;
            return incomingDamage;
        }

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
        int incomingSlot,
        bool magical = false,Actor inflictor=null
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
        if (incomingDamage <= 0.0) { return; }

        int slot = Clamp(
            incomingSlot, 0, CaelumConstants.ARMOR_SLOT_COUNT - 1
        );
        LastArmorVulnerabilityGrade = GetEffectiveArmorVulnerability(slot);
        LastArmorVulnerabilityMultiplier = GetVulnerabilityMultiplier(
            LastArmorVulnerabilityGrade,
            criticalHit
        );
        double postAnatomyDamage = incomingDamage * LastArmorVulnerabilityMultiplier;
        double toughness = Attributes != null ? Attributes.Toughness : 0.0;
        LastToughnessDamageMultiplier = CaelumArmorRules.ToughnessMultiplier(
            postAnatomyDamage, GetImpactMaximumHealth(), toughness);
        LastArmorPreDefenseDamage = CaelumArmorRules.AfterToughnessDamage(
            postAnatomyDamage, GetImpactMaximumHealth(), toughness);
        double defenseRatio = Clamp(
            GetArmorDefensePercent(slot, magical,inflictor) / 100.0,
            0.0,
            1.0
        );
        LastArmorAbsorbedDamage = LastArmorPreDefenseDamage * defenseRatio;
        LastArmorPostDefenseDamage = Max(
            0.0,
            LastArmorPreDefenseDamage - LastArmorAbsorbedDamage
        );
        LastArmorHealthDamage = Max(
            0,
            int(LastArmorPostDefenseDamage + 0.5)
        );

        // El cuerpo absorbe su parte sin desgastar la pieza equipada.
        double eligibleDamage = LastArmorPreDefenseDamage
            * (ArmorModel != null ? ArmorModel.GetDefense(slot, magical) / 100.0 : 0.0)
            * CaelumArmorRules.EquipmentRetention(inflictor)
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
        if (actualHealthLost > 0) CaelumRestState.Interrupt(self, "CA_REST_DAMAGE");
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
                A_StartSound(ResolvePlayerPainSound(), CHAN_VOICE);
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

    // The applicable player voice follows the created character profile:
    // male uses the human/Caelith grunt, female uses its selected counterpart.
    Sound ResolvePlayerPainSound()
    {
        if (CharacterProfile != null
            && CharacterProfile.Sex == CaelumConstants.SEX_FEMALE)
        {
            return "caelum/player/pain_female";
        }
        return "caelum/player/pain_male";
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
    override void MovePlayer()
    {
        vector2 before=Vel.XY;
        Super.MovePlayer();
        CaelumThermalMotion.PlayerInput(self,before);
    }

    override void PlayerThink()
    {
        let journeyPlan = CaelumJourneyPlan.Get(self);
        bool choosingJourney = journeyPlan != null && journeyPlan.Open;
        if (choosingJourney && (health <= 0 || journeyPlan.OriginMap != level.MapName))
        { CaelumJourneyPlan.Cancel(self); choosingJourney = false; }
        CaelumRestState.HandleInput(self);
        if (player != null && (player.cmd.buttons & BT_USER4) == 0) ClassSleepInputLatched = false;
        if (player != null && (player.cmd.buttons & BT_USER3) == 0) CombatTarotInputReserved = false;
        // Usar termina la canalización antes de la interacción nativa. Así
        // no se descarta silenciosamente el intento de capturar/hablar/abrir.
        if (CombatChannelModeActive && player != null)
        {
            bool channelPressed = (player.cmd.buttons & BT_USER2) != 0;
            bool usePressed = (player.cmd.buttons & BT_USE) != 0;
            if (usePressed && !player.usedown)
                StopSealChannel(true);
            else if (channelPressed && !CombatChannelInputLatched)
                RequestCombatChannelInput();
            if (!channelPressed) CombatChannelInputLatched = false;
        }
        if ((CreationWizardOpen || EquipmentMenuOpen || CraftingMenuOpen
                || choosingJourney || CaelumTimeSkipState.IsOpen(self) || PalomoMerchantMenuOpen
                || CombatChannelModeActive || CaelumRestState.IsActive(self) || ForcedSleepTics > 0)
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
        CaelumRestState.UpdateViewInput(self);
    }

    // Tick runs once per game tic. GZDoom uses 35 tics per second, so dividing
    // the documented per-second rate by TICRATE produces frame-independent
    // regeneration that also pauses when the game itself is paused.
    override void Tick()
    {
        CaelumBreathing.UpdateSound(self);
        CaelumCarbineWorld.Restore(self);
        CaelumTarotDeckRules.EnsureLegacy(self);
        EnsureCurrentAttributeBalance();
        MigrateWeaponDurability();
        Vector3 prePhysicsVelocity = Vel;
        vector3 thermalBefore=Pos;
        Sector thermalSector=CurSector;
        let thermalSupport=CaelumThermalMotion.Support(self);
        double thermalSupportHeight=CaelumThermalMotion.SupportHeight(thermalSector,thermalSupport,Pos.XY);
        let thermalMotion=CaelumThermalBody.Get(self);
        vector2 thermalPropulsion=thermalMotion!=null ? thermalMotion.PropelledVelocity : (0,0);
        bool thermalGrounded=player!=null && player.onground;

        // Los saves antiguos pueden conservar el modelo sin su objeto. Se
        // reconcilia antes de actualizar la vista, el peso y el bloqueo.
        RepairActiveShieldReference();
        Super.Tick();
        CaelumRestState.Validate(self);
        UpdateCraftingTask();
        UpdatePalomoMerchantSession();

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

        // PlayerThink borra los botones mientras la tienda está abierta. Por
        // eso este latch no se rearma hasta que el menú ya esté cerrado y el
        // siguiente comando autoritativo confirme que Use fue liberado.
        if (FolkloreInteractionUseLatched
            && !PalomoMerchantMenuOpen
            && player != null)
        {
            if (FolkloreInteractionReleaseGuardTics > 0)
            {
                FolkloreInteractionReleaseGuardTics--;
            }
            else if ((player.cmd.buttons & BT_USE) == 0)
            {
                FolkloreInteractionUseLatched = false;
            }
        }

        // AltFire de jabalina es de una acción por pulsación. Soltar el botón
        // rearma el lanzamiento; mantenerlo no puede crear un bucle por tic.
        if (player != null && (player.cmd.buttons & BT_ALTATTACK) == 0)
        {
            JavelinSecondaryLatched = false;
            RangedAimSecondaryLatched = false;
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
            UpdateLowHealthHeartbeat();
            return;
        }

        RefreshEquipmentLoadIfNeeded();
        EnsureUnarmedFallback();
        HUDInteractionHint=CaelumInteractionHint.Find(self);
        SyncHUDActiveWeaponState();

        CaelumThermalMotion.Physics(self,thermalBefore,prePhysicsVelocity,thermalGrounded,thermalPropulsion,thermalSector,thermalSupport,thermalSupportHeight);
        IsSpendingRunningAir = IsRunningOnGround();
        UpdateCrouchEffects();
        UpdateMovementNoise();
        AdvancePersonalTimeTic();
        UpdateLowHealthHeartbeat();

        UpdateAirStateEffects();
        UpdateMovementAcceleration();
        ApplyPhysicalMovement();
        ConsumeRunningAir();
        ConsumeShieldBlockingAir();
        HUDAbilitySuccessRemaining = Max(
            0.0, HUDAbilitySuccessRemaining - 1.0 / TICRATE
        );
        CaelumRestState.Advance(self);
        CaelumTimeAdvanceState.Pump(self);
        CaelumTimeSkipState.AfterStep(self);
        CaelumTimeSkipState.Pump(self);
    }

    // Este paso no mueve actores ni llama Super.Tick. Cada intervalo simulado
    // recorre las mismas tasas y umbrales que un tic de juego normal.
    void AdvancePersonalTimeTic(bool realStep=true)
    {
        CaelumThermalRuntime.PlayerStep(self,realStep);
        CaelumTarotService.Advance(self);
        if (ElementalStatus != null) { ElementalStatus.Tick(self); }
        IlluminationRemaining = Max(
            0.0, IlluminationRemaining - 1.0 / TICRATE
        );

        UpdateHealthStateEffects();


        // Paciencia conserva la tasa; Constitución/reposo reducen los costes.
        CaelumPlayerResources.ApplyAnimaRegeneration(self);

        UpdateAdrenalineDecay();
        UpdateSealChannel();
        UpdateLucidityPhysicalStun();
        UpdatePainImmobilization();
        if (StaffCastPending && AttackAnimationDurationTics>0 && AttackAnimationMap==level.MapName)
            StaffCastCooldownRemaining=Max(0.0,(AttackAnimationStartTic+AttackAnimationDurationTics-level.time)/TICRATE);
        else StaffCastCooldownRemaining=Max(0.0,StaffCastCooldownRemaining-1.0/TICRATE);
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
        AdvancePhysicalAttackCycle();
        if (AttackAnimationMap!=level.MapName)AttackAnimationDurationTics=0;
        if (AttackAnimationDurationTics>0 && !WeaponModel.IsMagicalType(AttackAnimationKind))
            EquippedWeaponCooldownRemaining=Max(0.0,
                (AttackAnimationStartTic+AttackAnimationDurationTics-level.time)/TICRATE);
        else EquippedWeaponCooldownRemaining=Max(0.0,EquippedWeaponCooldownRemaining-1.0/TICRATE);
        Inventory currentCarbineAmmo = FindInventory("CaelumCarbineAmmo");
        CarbineAmmoCount = currentCarbineAmmo != null
            ? currentCarbineAmmo.Amount : 0;

        CaelumSleepRules.AdvancePlayer(self);
        ClassSleepCooldownRemaining = Max(0.0, ClassSleepCooldownRemaining - 1.0 / TICRATE);

        UpdateSurvivalResources();
        ApplyCriticalSurvivalDamage();
        ApplyNaturalHealthRegeneration();

        UpdateCombatBlockMode();
        UpdateRangedReload();
        UpdateWeaponCharge();
        UpdateUnderwaterAir();
        ApplyAirRegeneration();
        CaelumDiningSession.Advance(self);

        if (ForcedSleepTics > 0)
        {
            ForcedSleepTics--;
            if (ForcedSleepTics == 0 && health > 0 && !CaelumRestState.IsActive(self)) SetState(SpawnState);
        }
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

    bool IsWalkingOnGround()
    {
        if (player == null
            || player.playerstate != PST_LIVE
            || !player.onground
            || IsPhysicallyImmobilized())
        {
            return false;
        }
        return (player.cmd.forwardmove != 0 || player.cmd.sidemove != 0)
            && (player.cmd.buttons & BT_RUN) == 0;
    }

    // Sólo sustituye la locomoción mundial; no interrumpe ataques, dolor,
    // muerte ni las futuras poses de descanso. El motor conserva altura y paso.
    void UpdateCrouchVisual()
    {
        // La pose ya está dibujada agachada: el renderer no debe comprimirla
        // otra vez. En ataques/dolor se vuelve a la compresión nativa normal.
        crouchsprite = 0;
        if (player == null || player.playerstate != PST_LIVE || health <= 0) return;
        if (CaelumRestState.IsActive(self) || ForcedSleepTics > 0)
        {
            // Las ramas literales evitan convertir un String a StateLabel en 4.14.2.
            State restPose = FindState("RestSeated");
            if (CaelumSleepRules.IsSleeping(self)) restPose = FindState("RestLying");
            if (CurState != restPose) SetState(restPose);
            return;
        }
        State idle = FindState("CrouchIdle");
        State walk = FindState("CrouchWalk");
        State runVisual = FindState("Run");
        State breathing = FindState("IdleBreathing");
        bool posed = InStateSequence(CurState, idle) || InStateSequence(CurState, walk);
        if (!posed && !InStateSequence(CurState, SpawnState)
            && !InStateSequence(CurState, SeeState)
            && !InStateSequence(CurState, runVisual)
            && !InStateSequence(CurState, breathing)) return;
        bool moving = Vel.X * Vel.X + Vel.Y * Vel.Y > 0.01;
        State wanted = player.crouchfactor < 0.75 ? moving ? walk : idle
            : moving ? (IsRunningOnGround() ? runVisual : SeeState) : SpawnState;
        if (wanted == idle || wanted == walk) crouchsprite = GetSpriteIndex("RSDO");
        // Spawn era infinito en 0p; reanudar la respiración al cargarlo.
        if (CurState == SpawnState && tics < 0) tics = 10;
        if (wanted == SpawnState && InStateSequence(CurState, breathing)) return;
        if (!InStateSequence(CurState, wanted)) SetState(wanted);
    }

    void UpdateWorldCarbineVisual()
    {
        CaelumCarbineWorld.Apply(self,WeaponModel!=null && WeaponModel.Equipped
            && CaelumRangedRules.IsFirearm(WeaponModel.WeaponType),
            Vel.XY.Length()>0.01,level.time<WorldCarbineShotUntil,
            RangedReloadActive ? RangedReloadRemainingSeconds : 0,RangedReloadTotalSeconds);
    }

    override void PlayAttacking()
    {
        Super.PlayAttacking();
        // El arma nativa puede volver a aplicar Missile después de Tick.
        // La pose depende del disparo real o de la recarga, nunca del botón.
        UpdateWorldCarbineVisual();
    }

    void UpdateCrouchEffects()
    {
        UpdateCrouchVisual();
        UpdateWorldCarbineVisual();
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
            * MovementNoiseMultiplier
            * (DerivedStats != null
                ? Max(0.0, DerivedStats.TotalMass / 100.0)
                : 1.0);

        if (LastMovementNoiseRange > 0.0)
        {
            LastMovementNoiseEventTic = level.time;
            LastMovementNoiseEventRange = LastMovementNoiseRange;
            MovementNoiseEventSerial++;
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
    int AttackAnimationSerial, AttackAnimationStartTic, AttackAnimationItemId;
    int AttackAnimationKind;
    double AttackAnimationDurationTics;
    bool AttackAnimationSecondary, AttackAnimationSweep;
    bool PhysicalAttackPending, PendingPhysicalCharged;
    int PhysicalAttackReleaseTic;
    String AttackAnimationMap;

    void StartAttackAnimation(double duration, bool secondary, bool sweep=false)
    {
        AttackAnimationSerial++;
        AttackAnimationMap=level.MapName;
        AttackAnimationStartTic=level.time;
        AttackAnimationDurationTics=duration;
        AttackAnimationItemId=ActiveWeaponItemId;
        AttackAnimationKind=WeaponModel.WeaponType;
        AttackAnimationSecondary=secondary;
        AttackAnimationSweep=sweep;
    }

    void RefreshWeaponAttackClock()
    {
        if(AttackAnimationDurationTics<=0 || AttackAnimationMap!=level.MapName)return;
        double remaining=Max(0.0,(AttackAnimationStartTic+AttackAnimationDurationTics-level.time)/TICRATE);
        if(WeaponModel.IsMagicalType(AttackAnimationKind))
        {
            if(StaffCastPending)
            {
                StaffCastCooldownRemaining=remaining;
                if(remaining<=0)CompletePendingStaffCast();
            }
        }
        else
        {
            AdvancePhysicalAttackCycle();
            EquippedWeaponCooldownRemaining=remaining;
        }
    }

    bool BeginPhysicalAttackCycle(bool secondary, bool sweep=false)
    {
        RefreshWeaponAttackClock();
        double duration=GetEquippedAttackDurationTics();
        if(duration<=0 || PhysicalAttackPending || EquippedWeaponCooldownRemaining>0 || StaffCastPending
            || WeaponChargeActive || WeaponModel.Durability<=0 || DerivedStats==null) return false;
        int kind=CaelumCraftingRules.GetCatalogueWeaponForPlayableType(WeaponModel.WeaponType);
        if(kind<0)return false;
        bool ranged=IsRangedWeaponType(WeaponModel.WeaponType);
        double cost=(secondary?CaelumWeaponCatalogue.GetSecondaryAirCost(kind):CaelumWeaponCatalogue.GetPrimaryAirCost(kind))
            *DerivedStats.AirConsumptionMultiplier;
        if(sweep)cost*=CaelumConstants.LARGE_SWEEP_AIR_MULTIPLIER;
        if(WeaponChargedStateActive && !ranged)cost*=CaelumConstants.WEAPON_CHARGED_COST_MULTIPLIER;
        cost*=CaelumThermalEffects.HeatCost(self);
        if(CurrentAir<cost)return false;
        if(ranged)
        {
            // El disparo y su retroceso siguen comenzando juntos.
            PerformCarbineAttack();
            if(!LastCarbineFired)return false;
            StartAttackAnimation(duration,false);
            return true;
        }
        StartAttackAnimation(duration,secondary,sweep);
        PendingPhysicalCharged=WeaponChargedStateActive;
        if(PendingPhysicalCharged)ConsumeWeaponChargedState();
        PhysicalAttackPending=true;
        double impact=CaelumAttackRules.IsThrust(WeaponModel.WeaponType,secondary)
            ? CaelumAttackRules.THRUST_IMPACT : CaelumAttackRules.SWING_IMPACT;
        PhysicalAttackReleaseTic=level.time+int(Ceil(duration*impact));
        EquippedWeaponCooldownRemaining=duration/TICRATE;
        MarkCombatActivity();
        return true;
    }

    void AdvancePhysicalAttackCycle()
    {
        if(!PhysicalAttackPending)return;
        bool switching=player!=null && player.PendingWeapon!=null && player.PendingWeapon!=WP_NOCHANGE
            && player.PendingWeapon!=player.ReadyWeapon;
        if(AttackAnimationMap!=level.MapName || health<=0 || WeaponModel==null || !WeaponModel.Equipped || WeaponModel.Durability<=0
            || ActiveWeaponItemId!=AttackAnimationItemId || WeaponModel.WeaponType!=AttackAnimationKind
            || EquipmentMenuOpen || CraftingMenuOpen || CreationWizardOpen || IsPhysicallyImmobilized()
            || switching || CombatBlockModeActive || CombatChannelModeActive)
        {
            PhysicalAttackPending=false;
            AttackAnimationDurationTics=0;
            return;
        }
        if(level.time<PhysicalAttackReleaseTic)return;
        PhysicalAttackPending=false;
        double remaining=EquippedWeaponCooldownRemaining;
        WeaponChargedStateActive=PendingPhysicalCharged;
        if(AttackAnimationSecondary && AttackAnimationKind==CaelumConstants.WEAPON_TYPE_JAVELIN
            && !HasJavelinMeleeFallbackTarget())PerformJavelinThrow();
        else PerformDebugSwordAttack(AttackAnimationSecondary,AttackAnimationSweep);
        WeaponChargedStateActive=false;
        // Los callbacks legados pueden asignar recuperación; el ciclo ya la
        // fijó al empezar y no debe pagar una segunda duración después de golpear.
        EquippedWeaponCooldownRemaining=remaining;
    }

    double GetEquippedAttackDurationTics()
    {
        if (WeaponModel == null || DerivedStats == null || !WeaponModel.Equipped) return -1;
        double gloves = ArmorModel == null ? 0 : ArmorModel.GetWeight(CaelumConstants.ARMOR_SLOT_HANDS);
        // El arma-guante y una pieza de armadura son objetos distintos. No se
        // vuelve a sumar el peso de WeaponModel como si fuera otro guante.
        double factor = WeaponModel.IsMagicalType(WeaponModel.WeaponType)
            ? DerivedStats.CastingDurationMultiplier : DerivedStats.AttackDurationMultiplier;
        return CaelumAttackRules.Duration(factor, WeaponModel.GetWeight(), gloves, DerivedStats.CarryCapacity)
            / CaelumThermalEffects.Speed(self);
    }

    void MigrateWeaponDurability(int revision = 1)
    {
        CaelumInventoryService.MigrateWeaponDurability(self, revision);
    }

    void PerformEquippedWeaponPrimaryAttack()
    {
        RefreshWeaponAttackClock();
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
            BeginPhysicalAttackCycle(false);
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
                BeginPhysicalAttackCycle(false);
                break;
        }
    }

    bool SupportsLargeWeaponSweep(int weaponType)
    {
        return weaponType == CaelumConstants.WEAPON_TYPE_GREATSWORD
            || weaponType == CaelumConstants.WEAPON_TYPE_WAR_AXE
            || weaponType == CaelumConstants.WEAPON_TYPE_HALBERD;
    }

    // Zoom comparte alcance, daño y recuperación con Fire, y paga una vez
    // triple Aire. Los guanteletes siguen usando su bloqueo contextual.
    void PerformLargeWeaponSweep(int weaponType)
    {
        RefreshWeaponAttackClock();
        if (!SupportsLargeWeaponSweep(weaponType)
            || EquipmentMenuOpen || CreationWizardOpen || CraftingMenuOpen
            || CombatChannelModeActive || StaffCastPending || WeaponChargeActive
            || EquippedWeaponCooldownRemaining > 0.0
            || IsPhysicallyImmobilized()
            || !ActivateEquippedWeaponType(weaponType)
            || WeaponModel == null || !WeaponModel.Equipped
            || WeaponModel.Durability <= 0) return;
        CancelCombatBlockMode();
        BeginPhysicalAttackCycle(false,true);
    }

    // AltFire pertenece exclusivamente al arma activa. El escudo ya no
    // intercepta este input: Block usa el estado nativo Zoom de forma
    // independiente.
    void PerformEquippedWeaponSecondaryAttack()
    {
        RefreshWeaponAttackClock();
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
            // AltFire, igual que Zoom, alterna ADS una sola vez por pulsación.
            // El bloqueo es propio de esta tecla y no afecta ataques secundarios.
            if (RangedAimSecondaryLatched) { return; }
            RangedAimSecondaryLatched = true;
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
            BeginPhysicalAttackCycle(true);
            return;
        }

        if (catalogueWeapon >= 0
            && CaelumWeaponCatalogue.GetSecondaryDamage(catalogueWeapon) > 0.0)
        {
            BeginPhysicalAttackCycle(true);
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

        CaelumEquipmentItem weapon =
            FindNativeEquipmentItemById(ActiveWeaponItemId);
        if (weapon == null || !weapon.Equipped || weapon.InMagicBox
            || weapon.EquipmentKind
                != CaelumConstants.EQUIPMENT_KIND_WEAPON
            || weapon.ItemType != weaponType || weapon.Tier != tier
            || weapon.EquipmentSize != equipmentSize)
        {
            weapon = FindEquippedNativeEquipmentItem(
                CaelumConstants.EQUIPMENT_KIND_WEAPON,
                weaponType, -1, tier, equipmentSize,
                WeaponModel != null
                    && WeaponModel.IsMagicalType(weaponType)
                    ? WeaponModel.EssenceType : -1
            );
        }
        if (weapon != null) { ActiveWeaponItemId = weapon.ItemId; }
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
        int equipmentSize,
        CaelumEquipmentItem sourceItem = null,
        bool projectileWear = false
    )
    {
        LastWeaponDurabilityLoss = 0;
        LastWeaponDurabilityChancePercent = 0.0;
        LastWeaponDurabilityRollPercent = 0.0;

        if (dealtDamage <= 0.0)
        {
            return;
        }

        CaelumEquipmentItem weapon = projectileWear ? sourceItem
            : FindNativeEquipmentItemById(ActiveWeaponItemId);
        // Un proyectil viejo sin identidad no debe desgastar otra copia.
        if (weapon == null || weapon.EquipmentKind != CaelumConstants.EQUIPMENT_KIND_WEAPON
            || weapon.ItemType != weaponType || weapon.Tier != tier
            || weapon.EquipmentSize != equipmentSize) return;
        weapon.MigrateWeaponDurability();
        if (weapon.Durability <= 0) return;

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

        bool isActiveWeapon = weapon.Owner == self && weapon.ItemId == ActiveWeaponItemId
            && weapon.Equipped && WeaponModel != null
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
        if (persistentState != null && weapon.Owner == self)
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
        if (GetEquippedAttackDurationTics() <= 0) return;
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
        airCost*=CaelumThermalEffects.HeatCost(self);
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
        projectile.MainM00ChargedPractice = chargedAttack;
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

        CaelumThermalEffects.RecordWeaponAction(self,CaelumConstants.WEAPON_TYPE_JAVELIN,true,chargedAttack);
        CurrentAir = Max(0.0, CurrentAir - airCost);
        UpdateAirStateEffects();
        EquippedWeaponCooldownRemaining = GetEquippedAttackDurationTics()
            / double(TICRATE);
        MarkCombatActivity();
        RefreshCarriedInventorySummary();
    }

    bool IsRangedWeaponType(int weaponType)
    {
        return weaponType == CaelumConstants.WEAPON_TYPE_SHOTGUN
            || weaponType == CaelumConstants.WEAPON_TYPE_LONGBOW
            || weaponType == CaelumConstants.WEAPON_TYPE_CROSSBOW
            || weaponType == CaelumConstants.WEAPON_TYPE_CARBINE;
    }

    int GetRangedMagazineCapacity(int weaponType)
    {
        return CaelumRangedRules.MagazineCapacity(weaponType);
    }

    int GetRangedMagazineCount(int weaponType)
    {
        if (weaponType == CaelumConstants.WEAPON_TYPE_SHOTGUN)
            return (ShotgunLoadedMask&1)+(ShotgunLoadedMask>>1&1);
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
        if (weaponType == CaelumConstants.WEAPON_TYPE_SHOTGUN)
            {
            while(GetRangedMagazineCount(weaponType)>value)ShotgunLoadedMask&=~((ShotgunLoadedMask&2)!=0 ? 2 : 1);
            while(GetRangedMagazineCount(weaponType)<value)ShotgunLoadedMask|=(ShotgunLoadedMask&1)==0 ? 1 : 2;
        }
        else if (weaponType == CaelumConstants.WEAPON_TYPE_LONGBOW)
            LongbowMagazine = value;
        else if (weaponType == CaelumConstants.WEAPON_TYPE_CROSSBOW)
            CrossbowMagazine = value;
        else if (weaponType == CaelumConstants.WEAPON_TYPE_CARBINE)
            CarbineMagazine = value;
    }

    int GetRangedAmmoType(int weaponType)
    {
        if(weaponType==CaelumConstants.WEAPON_TYPE_SHOTGUN)return CaelumConstants.AMMUNITION_SHOTGUN;
        if (weaponType == CaelumConstants.WEAPON_TYPE_CARBINE)
            return CaelumConstants.AMMUNITION_CARBINE;
        if (weaponType == CaelumConstants.WEAPON_TYPE_CROSSBOW)
            return CaelumConstants.AMMUNITION_BOLT;
        return CaelumConstants.AMMUNITION_ARROW;
    }

    double GetRangedBaseReloadSeconds(int weaponType)
    {
        return CaelumRangedRules.BaseReloadSeconds(weaponType);
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
        return CaelumRangedRules.TierCriticalMultiplier(tier);
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
        if (RangedAimModeActive) CaelumMainM00RuloTrial.RecordAim(self);
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
        if (PhysicalAttackPending) return;
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
        if(RangedReloadActive && CaelumRangedRules.IsFirearm(requestedWeaponType))
            CaelumThermalEffects.BeginFirearmReload(self);
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

        if(CaelumRangedRules.IsFirearm(RangedReloadWeaponType))
            CaelumThermalEffects.RecordReloadProgress(self,
                Min(RangedReloadRemainingSeconds,GetReloadProgressMultiplier()/TICRATE),RangedReloadTotalSeconds);
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
        CaelumMainM00RuloTrial.RecordPractice(self, CaelumConstants.MAIN_M00_FLAG_COMBAT_CHARGED_USED);
        CancelRangedReload();
    }

    void PerformCarbineAttack()
    {
        if (GetEquippedAttackDurationTics() <= 0) return;
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
        int requiredAmmoType = GetRangedAmmoType(WeaponModel.WeaponType);
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
        airCost*=CaelumThermalEffects.HeatCost(self);
        LastCarbineHadEnoughAir = CurrentAir >= airCost;
        if (!LastCarbineHadEnoughAir) { return; }

        UpdateLucidityAccuracyEffects();
        UpdateCrouchEffects();
        double movementAccuracyMultiplier = IsCrouching
            ? CrouchAccuracyMultiplier
            : (IsRunningOnGround()
                ? CaelumConstants.RUNNING_ACCURACY_MULTIPLIER
                : 1.0);
        double aimAccuracyMultiplier = RangedAimModeActive ? CaelumConstants.RANGED_AIM_ACCURACY_MULTIPLIER : 1.0;
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

        if(WeaponModel.WeaponType==CaelumConstants.WEAPON_TYPE_SHOTGUN)
        {
            if(!CaelumShotgunRules.Fire(self,WeaponModel,LastCarbineDamage,LastCarbineCriticalHit,
                DerivedStats.PhysicalPushMultiplier,LastCarbineMinimumSpread,LastCarbineMaximumSpread))return;
            ShotgunLastBarrel=(ShotgunLoadedMask&2)!=0 ? 1 : 0;
        }
        else
        {
            let projectile=CaelumRangedRules.Fire(self,WeaponModel,LastCarbineDamage,
                LastCarbineCriticalHit,DerivedStats.PhysicalPushMultiplier,
                Angle+LastCarbineYawOffset,Pitch+LastCarbinePitchOffset);
            if(projectile==null)return;
        }

        if (CaelumRangedRules.IsFirearm(WeaponModel.WeaponType))
        {
            A_StartSound("caelum/weapons/carabine_fire", CHAN_WEAPON);
        }

        // La pila nativa representa el total físico restante y normalmente
        // acompaña al cargador. La comprobación nula preserva un cargador ya
        // cargado aunque la reserva haya cambiado de contenedor.
        if (rangedAmmo != null && rangedAmmo.Amount > 0)
        {
            rangedAmmo.Amount = Max(0, rangedAmmo.Amount - 1);
            CaelumMainM00RuloTrial.ConsumeLoanRound(self, requiredAmmoType);
        }
        SetRangedMagazineCount(
            WeaponModel.WeaponType,
            GetRangedMagazineCount(WeaponModel.WeaponType) - 1
        );
        if (requiredAmmoType == CaelumConstants.AMMUNITION_CARBINE)
        {
            CarbineAmmoCount = CarbineMagazine;
        }
        if(CaelumRangedRules.IsFirearm(WeaponModel.WeaponType))
            CaelumThermalEffects.RecordFirearmShot(self);
        else CaelumThermalEffects.RecordWeaponAction(self,WeaponModel.WeaponType);
        CurrentAir = Max(0.0, CurrentAir - airCost);
        UpdateAirStateEffects();
        LastCarbineFired = true;
        if(CaelumRangedRules.IsFirearm(WeaponModel.WeaponType))
            WorldCarbineShotUntil=level.time+GetEquippedAttackDurationTics();
        UpdateWorldCarbineVisual();
        EquippedWeaponCooldownRemaining = GetEquippedAttackDurationTics()
            / double(TICRATE);
        MarkCombatActivity();
    }

    void CancelPendingStaffCast(bool interrupted)
    {
        if (!StaffCastPending) { return; }
        StaffCastPending = false;
        AttackAnimationDurationTics=0;
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
        CaelumMainM00MagicTrial.RecordAnimaSpent(self, animaCost);
    }

    void PerformDebugStaffAttack(bool secondaryAttack)
    {
        if (GetEquippedAttackDurationTics() <= 0) return;
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
        StaffCastCooldownRemaining = GetEquippedAttackDurationTics() / double(TICRATE);
        PendingStaffCastTotalSeconds = StaffCastCooldownRemaining;
        StartAttackAnimation(PendingStaffCastTotalSeconds*TICRATE,secondaryAttack);
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
            projectile.MainM00ChargedPractice = chargedAttack;
            projectile.MainM00MobilePractice = player.cmd.sidemove != 0
                && Vel.XY.Length() > 0.25;
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
            projectile.ConfigureCaelumTravelDistance(spellRange);
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
        double previousAir = CurrentAir;
        CurrentAir = Max(0.0, CurrentAir - finalCostPerSecond * CaelumThermalEffects.HeatCost(self) / TICRATE);
        CaelumMainM00RonnieTrial.RecordAirLesson(self, previousAir - CurrentAir, true);
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

    CaelumEquipmentItem FindActiveNativeShield()
    {
        if (ShieldModel == null || !ShieldModel.Equipped) { return null; }
        CaelumEquipmentItem shield = FindNativeEquipmentItemById(EquippedShieldItemId);
        if (shield == null || !shield.Equipped || shield.InMagicBox
            || !shield.Matches(CaelumConstants.EQUIPMENT_KIND_SHIELD,
                ShieldModel.ShieldType, -1, ShieldModel.Tier, ShieldModel.Size))
        {
            shield = FindEquippedNativeEquipmentItem(
                CaelumConstants.EQUIPMENT_KIND_SHIELD, ShieldModel.ShieldType,
                -1, ShieldModel.Tier, ShieldModel.Size);
        }
        return shield;
    }

    void RepairActiveShieldReference()
    {
        CaelumEquipmentItem shield = FindActiveNativeShield();
        EquippedShieldItemId = shield != null ? shield.ItemId : 0;
        if (shield == null && ShieldModel != null && ShieldModel.Equipped)
        {
            // Nunca crea equipo para justificar un estado obsoleto. La
            // migración de inventarios antiguos ocurre antes de este paso.
            ShieldModel.Equipped = false;
            if (!IsGiantGauntletsBlockSource()) { CancelCombatBlockMode(); }
        }
    }

    bool HasActiveBlockSource()
    {
        if (IsGiantGauntletsBlockSource()) { return true; }
        return FindActiveNativeShield() != null
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
        CaelumMainM00RuloTrial.RecordPractice(self, CaelumConstants.MAIN_M00_FLAG_COMBAT_DEFENSE_USED);
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
        CaelumMainM00MagicTrial.RecordChannel(self);
        Vel.X = 0.0; Vel.Y = 0.0;
        CancelCombatBlockMode();
        CancelRangedAim();
        CancelRangedReload();
        CancelWeaponCharge();
        CancelPendingStaffCast(false);
        // El actor del canal mantiene su propio epicentro; Quintaesencia lo
        // sitúa por encima del jugador en vez de atravesar su cuerpo.
    }

    // Una única regla alimenta User2 y el icono del HUD, incluida la ayuda
    // inicial de Caella. La consulta no consume ni concede Adrenalina.
    bool CanStartSealChannel()
    {
        if (CombatChannelCooldownRemaining > 0.0 || player == null
            || player.playerstate != PST_LIVE || health <= 0
            || EquipmentMenuOpen || CreationWizardOpen || CraftingMenuOpen
            || IsPhysicallyImmobilized() || StaffCastPending) return false;
        CaelumEquipmentItem seal = GetEquippedSeal();
        if (seal == null) return false;
        return CurrentAdrenaline >= GetSealChannelAdrenalinePerTic(seal.Tier)
            || CaelumMainM00MagicTrial.CanPrepareChannel(self, seal);
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
        if (!CanStartSealChannel()) return;
        CaelumEquipmentItem seal = GetEquippedSeal();
        if (seal == null) return;
        CombatChannelSealType = Clamp(seal.ItemType, 0,
            CaelumConstants.SEAL_TYPE_COUNT - 1);
        CombatChannelSealTier = Clamp(seal.Tier, 1, 3);
        CombatChannelAdrenalinePerTic =
            GetSealChannelAdrenalinePerTic(CombatChannelSealTier);
        CaelumMainM00MagicTrial.PrepareChannel(self, seal);
        if (CurrentAdrenaline < CombatChannelAdrenalinePerTic) return;
        CombatChannelRadius = CaelumConstants.SEAL_CHANNEL_BASE_RADIUS
            * (DerivedStats != null
                ? DerivedStats.AbilityRangePercent / 100.0 : 1.0);
        CaelumChannelEffect effect = CaelumChannelEffect(
            Spawn("CaelumChannelEffect", Pos, ALLOW_REPLACE));
        if (effect == null) return;
        effect.ConfigureChannel(self, seal, CombatChannelRadius);
        CombatChannelEffectActor = effect;
        CombatChannelModeActive = true;
        CombatChannelInputLatched = true;
        CancelCombatBlockMode();
        CancelRangedAim();
        CancelRangedReload();
        CancelWeaponCharge();
        // El propio icono del Sello muestra su estado; no tapa el centro.
    }

    // User1 y las clases distintas del arcanista conservan su reserva
    // hasta que sus respectivos bloques sean implementados.
    void ReserveRacialAbilityInput()
    {
        CombatRacialAbilityInputReserved = true;
        ShowAbilitySuccessMessage();
        CombatRacialAbilityInputReserved = false;
    }

    void ReserveTarotInput()
    {
        if (CombatTarotInputReserved) return;
        CombatTarotInputReserved = true;
        CaelumTarotService.Activate(self);
    }

    void ReserveClassAbilityInput()
    {
        if (CharacterProfile != null && CharacterProfile.GetProfession() == CaelumConstants.PROFESSION_ARCANIST)
        {
            if (!ClassSleepInputLatched) CaelumSleepRules.Cast(self);
            ClassSleepInputLatched = true;
            return;
        }
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
        CurrentAir = Max(0.0, CurrentAir - CurrentShieldAirCostPerSecond * CaelumThermalEffects.HeatCost(self) / TICRATE);
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
        BeginRepairSelectedEquipment();
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
    override void CheckJump()
    {
        double before=Vel.Z;
        bool eligible=player!=null && player.onground && player.jumpTics==0
            && WaterLevel<2 && !bNoGravity && !(player.cheats & CF_PREDICTING);
        Super.CheckJump();
        // Observar el lanzamiento nativo evita depender de que la tecla siga
        // pulsada cuando onground se actualiza en el tic siguiente.
        if(eligible && player.jumpTics==-1 && Vel.Z>before)
        {
            ConsumeJumpAir();
            if(DerivedStats!=null)
                CaelumThermalService.Impulse(self,CaelumThermalRules.BodyJumpHeat(DerivedStats.TotalMass),true);
        }
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
        // NOGRAVITY y el agua usa WaterLevel: ambos son medios con control
        // lateral continuo. Sin esta excepción, al entrar nadando desde el
        // aire el factor permanecía en cero hasta tocar el fondo del vaso.
        if (!player.onground && !bNOGRAVITY && WaterLevel == 0) { return; }

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
        double movementFactor = Max(0.0, EffectiveMovementPercent / 100.0) * CaelumThermalEffects.Speed(self);
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
            || ForcedSleepTics > 0
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

    // Un save anterior puede conservar estadísticas y costes ya calculados.
    // Se reconstruyen una sola vez, sin conceder cartas ni reiniciar recursos.
    void EnsureCurrentAttributeBalance()
    {
        CaelumPlayerCharacter.EnsureCurrentAttributeBalance(self);
    }

    void ApplyCharacterProfile()
    {
        CaelumPlayerCharacter.ApplyCharacterProfile(self);
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
        CurrentAir = Max(0.0, CurrentAir - finalCost * CaelumThermalEffects.HeatCost(self));
        UpdateAirStateEffects();
    }

    // Vacía la reserva sólo para comprobar el daño submarino sin esperar a
    // consumir miles de unidades mediante acciones ordinarias.
    void EmptyDebugAir()
    {
        CurrentAir = 0.0;
        UnderwaterDrowningTics = 0;
        UnderwaterAirRecoveryDebt = 0.0;
        UnderwaterAirRecoveryTicsRemaining = 0;
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
        CaelumPlayerResources.AddAdrenaline(self, amount);
    }

    // Health state multiplies only gameplay-earned adrenaline. The manual
    // development fill control remains exact so resource testing stays useful.
    void AddCombatAdrenaline(
        double amount,
        int eventType = CaelumConstants.ADRENALINE_EVENT_OTHER
    )
    {
        CaelumPlayerResources.AddCombatAdrenaline(self, amount, eventType);
    }

    // Every confirmed combat event restarts the entire thirty-second timer.
    void MarkCombatActivity()
    {
        CaelumPlayerResources.MarkCombatActivity(self);
    }

    // El tiempo de combate siempre avanza, aun cuando una acción no haya
    // otorgado Adrenalina o ésta ya sea cero. Al terminar los treinta segundos,
    // sólo la reserva positiva entra en su decadencia normal de diez por segundo.
    void UpdateAdrenalineDecay()
    {
        CaelumPlayerResources.UpdateAdrenalineDecay(self);
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

    void ApplyConsumableRegenerationPulse(int consumableType, double foodRecovery = -1)
    {
        CaelumPlayerResources.ApplyConsumableRegenerationPulse(self, consumableType, foodRecovery);
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
    void PerformDebugSwordAttack(bool secondaryAttack, bool areaSweep = false)
    {
        if (GetEquippedAttackDurationTics() <= 0) return;
        LastMeleeCalculatedDamage = 0.0;
        LastMeleeActualDamage = 0;
        LastMeleeSweepHitCount = 0;
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
        if (areaSweep && (secondaryAttack || !SupportsLargeWeaponSweep(activeWeaponType))) return;
        LastMeleeAirCost = (secondaryAttack
            ? CaelumWeaponCatalogue.GetSecondaryAirCost(catalogueWeapon)
            : CaelumWeaponCatalogue.GetPrimaryAirCost(catalogueWeapon))
            * DerivedStats.AirConsumptionMultiplier;
        if (areaSweep) LastMeleeAirCost *= CaelumConstants.LARGE_SWEEP_AIR_MULTIPLIER;
        bool chargedAttack = WeaponChargedStateActive;
        if (chargedAttack)
        {
            LastMeleeAirCost *=
                CaelumConstants.WEAPON_CHARGED_COST_MULTIPLIER;
        }
        LastMeleeAirCost*=CaelumThermalEffects.HeatCost(self);
        if (CurrentAir < LastMeleeAirCost)
        {
            return;
        }

        LastMeleeHadEnoughAir = true;
        if (chargedAttack) { ConsumeWeaponChargedState(); }
        CaelumThermalEffects.RecordWeaponAction(self,WeaponModel.WeaponType,secondaryAttack,chargedAttack,areaSweep);
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
        if (areaSweep)
        {
            ResolveLargeWeaponSweepHits(catalogueWeapon, physicalWeaponDamageScale, chargedAttack);
            return;
        }
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

        if (targetData.linetarget is "CaelumM00TrainingDummy")
        {
            CaelumMainM00RuloTrial.RecordHit(self, secondaryAttack, chargedAttack);
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
        ThermalBluntDelivery=(secondaryAttack ? CaelumWeaponCatalogue.GetSecondaryDamageType(catalogueWeapon)
            : CaelumWeaponCatalogue.GetPrimaryDamageType(catalogueWeapon))==CaelumConstants.CATALOGUE_DAMAGE_BLUNT;

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
        ThermalBluntDelivery=false;
        LastMeleeActualDamage = actualDamage;

        int harvestDamageKind = secondaryAttack
            ? CaelumWeaponCatalogue.GetSecondaryDamageType(catalogueWeapon)
            : CaelumWeaponCatalogue.GetPrimaryDamageType(catalogueWeapon);
        CaelumEnvironmentProp resourceTarget = CaelumEnvironmentProp(
            targetData.linetarget
        );
        double extractedResourceUnits = resourceTarget != null
            ? resourceTarget.TryExtractResource(
                self, harvestDamageKind, integerDamage, WeaponModel.WeaponType
            )
            : 0.0;

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
        else if (extractedResourceUnits > 0.0)
        {
            // Una fuente invulnerable no devuelve daño de salud, pero un golpe
            // de extracción válido sí desgasta el arma. Sólo las fuentes
            // declaradas movibles reciben impulso; los árboles están arraigados.
            ApplyWeaponDurabilityFromSuccessfulDamage(
                integerDamage,
                WeaponModel.WeaponType,
                WeaponModel.Tier,
                WeaponModel.Size
            );
            if (resourceTarget.IsEnvironmentMovable())
            {
                ApplyAttackPushToTarget(
                    targetData.linetarget,
                    attackAngle,
                    DerivedStats.PhysicalPushMultiplier
                );
            }
            else
            {
                LastAttackPushForce = 0.0;
            }
        }
    }

    bool IsLargeSweepEnemy(Actor candidate)
    {
        if (candidate == null || candidate == self || candidate.health <= 0
            || !candidate.bSHOOTABLE || candidate.bCORPSE
            || candidate.bFRIENDLY || candidate.player != null
            || candidate is "CaelumAnchoredResident") return false;
        // El blanco es una excepción de entrenamiento, no un objeto extraíble.
        return candidate.bISMONSTER || candidate is "CaelumTrainingDummy"
            || candidate is "CaelumGateBlocker";
    }

    // Filtro espacial nativo y un trazado geométrico por enemigo. Atravesar
    // actores permite alcanzar a todos, pero nunca ignora paredes ni pisos 3D.
    void ResolveLargeWeaponSweepHits(int catalogueWeapon, double damageScale, bool chargedAttack)
    {
        double reach = CaelumWeaponCatalogue.GetPrimaryRange(catalogueWeapon);
        double originZ = Pos.Z + ViewHeight;
        let search = BlockThingsIterator.Create(self, reach);
        int totalDamage = 0;
        Array<Actor> visited;
        while (search.Next())
        {
            Actor candidate = search.thing;
            if (!IsLargeSweepEnemy(candidate)) continue;
            // Las muchas cajas de una puerta representan un solo blanco.
            Actor identity = candidate is "CaelumGateBlocker" ? candidate.master : candidate;
            bool duplicate = false;
            for (int index = 0; index < visited.Size(); index++)
                if (visited[index] == identity) { duplicate = true; break; }
            if (duplicate) continue;
            Vector2 delta = candidate.Pos.XY - Pos.XY;
            double horizontal = delta.Length();
            double contactDistance = Max(0.0, horizontal - candidate.Radius);
            double contactZ = Clamp(originZ, candidate.Pos.Z + 0.1,
                candidate.Pos.Z + Max(0.1, candidate.Height - 0.1));
            double vertical = contactZ - originZ;
            double distance = Sqrt(contactDistance * contactDistance + vertical * vertical);
            if (distance > reach || !CheckSight(candidate, SF_IGNOREVISIBILITY)) continue;
            double attackAngle = horizontal > 0.001 ? VectorAngle(delta.X, delta.Y) : Angle;
            double attackPitch = -VectorAngle(Max(0.001, contactDistance), vertical);
            FLineTraceData trace;
            if (LineTrace(attackAngle, distance + 0.05, attackPitch,
                TRF_THRUACTORS | TRF_ABSPOSITION, originZ, Pos.X, Pos.Y, trace)) continue;
            visited.Push(identity);

            LastMeleeHit = true;
            LastMeleeSweepHitCount++;
            if (candidate is "CaelumM00TrainingDummy")
            {
                CaelumMainM00RuloTrial.RecordHit(self, false, chargedAttack);
                continue;
            }
            CalculateDebugMeleeHitLocation(candidate, attackAngle, attackPitch);
            LastMeleeCriticalAttempted = true;
            LastMeleeCrouchCriticalMultiplier = CrouchCriticalChanceMultiplier;
            LastMeleeCriticalChancePercent = Clamp(
                (CaelumWeaponCatalogue.GetCriticalChancePercent(catalogueWeapon)
                    + Max(0.0, DerivedStats.PhysicalCriticalChance
                        - CaelumConstants.BASE_CRITICAL_CHANCE_PERCENT))
                    * LastMeleeCrouchCriticalMultiplier, 0.0, 100.0);
            LastMeleeCriticalRollPercent = Random[CaelumPhysicalCritical](0, 999999) / 10000.0;
            LastMeleeCriticalHit = LastMeleeCriticalRollPercent < LastMeleeCriticalChancePercent;
            CaelumCombatActor combatTarget = CaelumCombatActor(candidate);
            if (combatTarget != null) combatTarget.RegisterPendingCriticalHit(LastMeleeCriticalHit);
            LastMeleeLocationMultiplier = GetVulnerabilityMultiplier(
                LastMeleeVulnerabilityGrade, LastMeleeCriticalHit);
            LastMeleeCalculatedDamage = DerivedStats.DebugSwordDamage * damageScale
                * LastMeleeLocationMultiplier * EffectiveOffensiveDamageMultiplier
                * (chargedAttack ? CaelumConstants.WEAPON_CHARGED_DAMAGE_MULTIPLIER : 1.0);
            ThermalBluntDelivery=CaelumWeaponCatalogue.GetPrimaryDamageType(catalogueWeapon)==CaelumConstants.CATALOGUE_DAMAGE_BLUNT;
            int actualDamage = candidate.DamageMobj(self, self,
                Max(1, int(LastMeleeCalculatedDamage + 0.5)), 'CaelumMeleeTest',
                DMG_THRUSTLESS | DMG_PLAYERATTACK | DMG_USEANGLE, attackAngle);
            ThermalBluntDelivery=false;
            totalDamage += Max(0, actualDamage);
            if (actualDamage > 0)
                ApplyAttackPushToTarget(candidate, attackAngle, DerivedStats.PhysicalPushMultiplier);
        }
        LastMeleeActualDamage = totalDamage;
        if (totalDamage > 0)
        {
            ApplyWeaponDurabilityFromSuccessfulDamage(totalDamage,
                WeaponModel.WeaponType, WeaponModel.Tier, WeaponModel.Size);
            AddCombatAdrenaline(CaelumConstants.ADRENALINE_GAIN_ON_MELEE_DAMAGE,
                CaelumConstants.ADRENALINE_EVENT_MELEE);
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
        if (target is "CaelumGateBlocker") { return 0.0; }
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
        if (target is "CaelumGateBlocker")
        {
            // Una estructura no tiene cabeza ni puntos anatómicos débiles.
            LastMeleeHitLocation = CaelumConstants.HIT_LOCATION_TORSO;
            LastMeleeVulnerabilityGrade = CaelumConstants.VULNERABILITY_NEUTRAL_POINT;
        }
        else if (combatTarget != null)
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
        BeginRepairSelectedEquipment();
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
        LastToughnessDamageMultiplier = 1.0;
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
        double postAnatomyDamage = incomingDamage * LastArmorVulnerabilityMultiplier;
        double toughness = Attributes != null ? Attributes.Toughness : 0.0;
        LastToughnessDamageMultiplier = CaelumArmorRules.ToughnessMultiplier(
            postAnatomyDamage, GetImpactMaximumHealth(), toughness);
        LastArmorPreDefenseDamage = CaelumArmorRules.AfterToughnessDamage(
            postAnatomyDamage, GetImpactMaximumHealth(), toughness);

        double defenseRatio = Clamp(GetArmorDefensePercent(slot) / 100.0, 0.0, 1.0);
        LastArmorAbsorbedDamage = LastArmorPreDefenseDamage * defenseRatio;
        LastArmorPostDefenseDamage = Max(
            0.0,
            LastArmorPreDefenseDamage - LastArmorAbsorbedDamage
        );
        int calculatedHealthDamage = Max(
            0,
            int(LastArmorPostDefenseDamage + 0.5)
        );
        LastArmorHealthDamage = Min(calculatedHealthDamage, health - 1);

        double durabilityEligibleDamage = LastArmorPreDefenseDamage
            * ArmorModel.GetDefense(slot) / 100.0
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
        CaelumPlayerResources.ApplyLocalizedLucidityLoss(self, naturalVulnerabilityGrade, effectiveVulnerabilityGrade, criticalHit, defenseRatio);
    }

    // Low sleep doubles and critical sleep quadruples lucidity loss and stun
    // duration. Patience Type 3 mitigates only the harmful amount above x1.
    double GetLuciditySleepDebuffMultiplier()
    {
        return CaelumPlayerResources.GetLuciditySleepDebuffMultiplier(self);
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
        CaelumPlayerResources.UpdateLucidityState(self);
    }

    // Lucidity owns one reusable accuracy factor. Both dizzy and stunned
    // states retain 50%; the critical state additionally has its finite
    // physical immobilization when the threshold is crossed.
    void UpdateLucidityAccuracyEffects()
    {
        CaelumPlayerResources.UpdateLucidityAccuracyEffects(self);
    }

    void UpdateLucidityPhysicalStun()
    {
        CaelumPlayerResources.UpdateLucidityPhysicalStun(self);
    }

    void UpdatePainImmobilization()
    {
        CaelumPlayerResources.UpdatePainImmobilization(self);
    }

    int CalculateSurvivalState(double currentValue)
    {
        return CaelumPlayerResources.CalculateSurvivalState(self, currentValue);
    }

    double GetSurvivalStateMultiplier(int state)
    {
        return CaelumPlayerResources.GetSurvivalStateMultiplier(self, state);
    }

    // Sólo un volumen marcado por el mapa puede hidratar. WaterLevel 3 exige
    // que la cabeza también esté bajo el agua y evita que futuros mares o
    // líquidos peligrosos hereden esta propiedad por accidente.
    bool IsSubmergedInPotableWater()
    {
        return CaelumPlayerResources.IsSubmergedInPotableWater(self);
    }

    // Consumo pasivo según tiempo base, masa corporal y divisor Tipo 4.
    void UpdateSurvivalResources()
    {
        CaelumPlayerResources.UpdateSurvivalResources(self);
    }

    void UpdateSurvivalStates()
    {
        CaelumPlayerResources.UpdateSurvivalStates(self);
    }

    void UpdateLowHealthHeartbeat()
    {
        bool shouldPlay = !CreationWizardOpen
            && HealthResourceInitialized
            && HealthState == CaelumConstants.HEALTH_STATE_BADLY_WOUNDED
            && health > 0
            && player != null
            && player.playerstate == PST_LIVE;
        if (!shouldPlay)
        {
            if (LowHealthHeartbeatActive) { A_StopSound(CHAN_5); }
            LowHealthHeartbeatTimer = 0;
            LowHealthHeartbeatActive = false;
            return;
        }

        if (LowHealthHeartbeatTimer > 0)
        {
            LowHealthHeartbeatTimer--;
            return;
        }

        A_StartSound(
            "caelum/player/low_health_heartbeat",
            CHAN_5,
            CHANF_LOCAL | CHANF_UI,
            1.0,
            ATTN_NONE
        );
        LowHealthHeartbeatTimer =
            CaelumConstants.LOW_HEALTH_HEARTBEAT_INTERVAL_TICS;
        LowHealthHeartbeatActive = true;
    }

    // Patience first mitigates the harmful part of wounded states. Adrenaline
    // then restores the same share of the remaining penalty and suppresses
    // pain intensity. Beneficial adrenaline gains remain x2/x4.
    void UpdateHealthStateEffects()
    {
        CaelumPlayerResources.UpdateHealthStateEffects(self);
    }

    // One stored result keeps every present and future offensive action on the
    // same rule. Health and survival are independent penalties, so they multiply.
    void UpdateEffectiveOffensiveDamageMultiplier()
    {
        CaelumPlayerResources.UpdateEffectiveOffensiveDamageMultiplier(self);
    }

    // Cada reserva crítica de Hambre, Sed o Sueño invierte la recuperación base.
    // GZDoom usa vida entera: el daño fraccionario se acumula.
    void ApplyCriticalSurvivalDamage()
    {
        CaelumPlayerResources.ApplyCriticalSurvivalDamage(self);
    }

    // Hambre, Sed o Sueño críticos detienen la recuperación natural.
    // Resiliencia Tipo 4 cura gastando hambre/sed según la vida restaurada.
    void ApplyNaturalHealthRegeneration()
    {
        CaelumPlayerResources.ApplyNaturalHealthRegeneration(self);
    }

    // Recuperar 1% de Aire cuesta de base 0,1 de Hambre y 0,2 de Sed,
    // divididos por Tipo 4 de Constitución. El límite de recuperación usa
    // esos mismos costes para no permitir reservas negativas.
    void ApplyAirRegeneration()
    {
        CaelumPlayerResources.ApplyAirRegeneration(self);
    }

    // Sustituye el contador submarino paralelo de GZDoom. PlayerThink llama
    // esta función virtual cada tic; al reiniciarlo sin sonido evitamos daño
    // nativo y dejamos que CurrentAir sea la única fuente de respiración.
    override void CheckAirSupply()
    {
        ResetAirSupply(false);
    }

    bool HasUnderwaterAirExemption()
    {
        return CaelumPlayerResources.HasUnderwaterAirExemption(self);
    }

    // La velocidad base sube por escalones completos de un segundo: 5 durante
    // los primeros 35 tics, 6 durante los siguientes 35, hasta el máximo 20.
    double GetUnderwaterBaseAirCostPerSecond()
    {
        return CaelumPlayerResources.GetUnderwaterBaseAirCostPerSecond(self);
    }

    // Distribuye la deuda restante entre los tics restantes. Así, incluso si
    // el máximo cambia o se carga una partida a mitad del proceso, el último
    // tic devuelve exactamente el Aire submarino que todavía falta.
    void RecoverUnderwaterAirDebt()
    {
        CaelumPlayerResources.RecoverUnderwaterAirDebt(self);
    }

    // El parámetro separado permite auditar la regla temporal sin depender de
    // una geometría concreta. El juego normal lo obtiene de WaterLevel.
    void UpdateUnderwaterAirForState(bool withoutOxygen)
    {
        CaelumPlayerResources.UpdateUnderwaterAirForState(self, withoutOxygen);
    }

    void UpdateUnderwaterAir()
    {
        CaelumPlayerResources.UpdateUnderwaterAir(self);
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
        CaelumPlayerResources.ConsumeJumpAir(self);
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
            UnderwaterNoBreathTics = 0;
            UnderwaterDrowningTics = 0;
            UnderwaterAirRecoveryDebt = 0.0;
            UnderwaterAirRecoveryTicsRemaining = 0;
            UnderwaterCurrentBaseCostPerSecond =
                CaelumConstants.UNDERWATER_AIR_INITIAL_COST_PER_SECOND;
            UnderwaterWithoutOxygen = false;
            UnderwaterAirRecoveryAppliedThisTick = false;
            UpdateAirStateEffects();
        }
    }

    double GetAirRatio()
    {
        return CaelumPlayerResources.GetAirRatio(self);
    }

    // Store the state and effective evasion in play scope. The UI reads these
    // fields directly, avoiding forbidden play-to-UI function calls.
    void UpdateAirStateEffects()
    {
        CaelumPlayerResources.UpdateAirStateEffects(self);
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
            persistentState.InitializeNewMagicBoxOwnership();
            persistentState.InitializeNewPalomoDiscount();
            persistentState.InitializeNewQuestState();
            persistentState.InitializeNewFactionState();
        }
        MagicBoxOwned = false;
        PalomoMerchantDiscountGranted = false;
        PalomoDiscountChancePercent = 0;
        PalomoDiscountLastRoll = 0;
        PalomoDiscountAutomaticSuccess = false;
        SetPalomoDialogueToken("CaelumMagicBoxOwnershipToken", false);
        SetPalomoDialogueToken(
            "CaelumPalomoDiscountGrantedToken", false
        );
        SetPalomoDialogueToken(
            "CaelumPalomoEloquenceEligibleToken", false
        );
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
        EquippedShieldItemId = 0;
        CancelCombatBlockMode();
        CombatChannelModeActive = false;
        WeaponModel.Equipped = false;
        ActiveWeaponItemId = 0;
        EquippedAmuletItemId = 0;
        EquippedSealItemId = 0;
        for (int startingArmorSlot = 0;
            startingArmorSlot < CaelumConstants.ARMOR_SLOT_COUNT;
            startingArmorSlot++)
        {
            EquippedArmorItemId[startingArmorSlot] = 0;
        }
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
        persistentState.MigrateWeaponDurability();

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
            RefillAir();
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
