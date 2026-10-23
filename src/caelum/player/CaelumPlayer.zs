// CaelumPlayer is the base class for every playable character.
//
// It currently inherits DoomPlayer so that Doom II's temporary weapons,
// animations, sounds, and inventory remain usable during early development.
// These inherited resources will be replaced by original assets later.
class CaelumPlayer : DoomPlayer
{
    transient CaelumTargetSubscriptions TargetSubscribers;
    override Weapon PickWeapon(int slot, bool checkammo)
    {
        // El dispatcher nativo ya resolvió teclas, aliases y doble clic.
        // La mutación de las instancias equipadas sigue en NetworkProcess.
        if (slot == 2)
        {
            EventHandler.SendNetworkEvent("ca_cycle_weapon_slot_2");
            return null;
        }
        return Super.PickWeapon(slot, checkammo);
    }

    CaelumBolasFlight BolasBinding;
    CaelumTelekinesisEffect TelekinesisBinding;
    int BolasPreparedTics,BolasPreparedItem,BolasReleaseUntil;
    Actor UtilityStaffStream;
    int UtilityStaffRequestedMode;
    bool ThermalBluntDelivery;
    const FORMAL_INVENTORY_VISIBLE_ROWS = 6;
    const FORMAL_INVENTORY_FILTER_COUNT = 11;

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
    bool HUDClassAbilityAvailable;
    int HUDEquippedSealType;
    int HUDEquippedSealTier;
    int HUDChannelAffectedCount;
    double HUDActiveWeaponNoticeRemaining;
    bool HUDActiveWeaponStateInitialized;
    CaelumAnatomyProfile AnatomyProfile;
    CaelumCharacterProfile AppearanceDeathProfile;
    CaelumAppearanceHead AppearanceHead;
    int AppearancePose;
    bool AppearanceHasGloves,AppearanceDeathGloves;
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
    bool RecipeQuoteActive;
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
    int CraftingPlanStepOutputUnits[CaelumConstants.CRAFTING_DIRECT_STEP_SLOT_COUNT];
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
    int EquipmentSelectionClothingType;
    transient bool ClothingMigrationReady;
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
    bool MainM00GoldRewardSnapshot, MainM00LessonsCompleteSnapshot;
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
    int FormalInventoryRowWaterQuality[FORMAL_INVENTORY_VISIBLE_ROWS];
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
    CaelumSocialSession SocialSession;
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
    // Sólo el despegue nativo voluntario abre esta ventana; se guarda con el cuerpo.
    int VoluntaryJumpRevision;
    bool VoluntaryJumpActive;
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
    double MovementAccelerationStep;
    int MovementAccelerationRevision;
    // Un gesto incompleto nunca viaja dentro del guardado.
    transient int MovementTapMask, MovementTapPending, MovementTapLastTic;
    transient int MovementTapTimes[4];
    transient bool MovementTapReady;
    transient String MovementTapMap;
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
    CaelumSpellSleepState SpellSleep;
    double ClassSleepCooldownRemaining;
    bool ClassSleepInputLatched;
    // #238: reloj guardado de preparacion; cero en partidas anteriores.
    int ClassPreparationRevision;
    int ClassPreparationTics;
    int ClassCastRevision,ClassCastProfession;
    bool ClassCastActive;
    double ClassCastCost,ClassCastPaid;
    // #238: estado compartido; los efectos raciales lo activarán en sus issues.
    bool RacialAbilityActive;
    int RacialAbilityRevision;
    bool RacialAbilityInputLatched;
    CaelumRacialAbilityEffect RacialAbility;
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
    int RestDamageRevision;
    double RestPeriodicPainRemaining,RestNonPeriodicPainRemaining;
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
    int MiracleRecoveryRevision;
    double MiracleHealthRemainder;

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
    // Proyección derivada: se reconstruye sin atacar ni conservar muestras.
    double HUDPhysicalCriticalChance, HUDMagicalCriticalChance;
    bool HUDPhysicalCriticalApplies, HUDMagicalCriticalApplies;
    double HUDMagicalDamageFactor;

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
        +NOSKIN

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
        DOID A 10 UpdateWorldCarbineVisual;
        Goto IdleBreathing;
    See:
        DOWK AB 4 UpdateWorldCarbineVisual;
        Loop;
    Missile:
        DOMI CDEFGHIJ 2 UpdateWorldCarbineVisual;
        Goto Spawn;
    Melee:
        DOMI KLMNOPQ 2 UpdateWorldCarbineVisual;
        Goto Spawn;
    Pain:
        DOMI A 4 UpdateWorldCarbineVisual;
        DOMI A 4 { A_Pain(); UpdateWorldCarbineVisual(); }
        Goto Spawn;
    Death:
        DOMI S 8 UpdateWorldCarbineVisual;
        DOMI T 8 { A_PlayerScream(); UpdateWorldCarbineVisual(); }
        DOMI U 8 UpdateWorldCarbineVisual;
        DOMI V 8 { A_NoBlocking(!CaelumRedemption.PreviouslyRaised(self)); UpdateWorldCarbineVisual(); }
        DOMI WXY 8 UpdateWorldCarbineVisual;
        DOMI Z -1 UpdateWorldCarbineVisual;
        Stop;
    XDeath:
        Goto Death;
    Raise:
        DOMI ZYXWVUTS 5 UpdateWorldCarbineVisual;
        Goto Spawn;
    RestSeated:
        RSDO A -1 UpdateWorldCarbineVisual;
        Stop;
    RestLying:
        RSDO B -1 UpdateWorldCarbineVisual;
        Stop;
    CrouchIdle:
        RSDO C -1 UpdateWorldCarbineVisual;
        Stop;
    CrouchWalk:
        RSDO DEFG 6 UpdateWorldCarbineVisual;
        Loop;

    // Estados nuevos al final: conservan los índices de partidas anteriores.
    IdleBreathing:
        DOID AAA 10 UpdateWorldCarbineVisual;
        DOID BBBB 10 UpdateWorldCarbineVisual;
        Goto Spawn;
    Run:
        DORN ABCD 3 UpdateWorldCarbineVisual;
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
        if(persistentState != null && CaelumPlayerAuthority.CanMutate(self)) persistentState.EnsureLandMaterialSchema();
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
        double dialogueSkill = CaelumSocialization.Dialogue(self);
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
        CaelumSocialization.Clear(self);
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
        CaelumCharacterIdentity.Bind(self, persistentState, true);
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
        persistentState.GrowthRevision=AttributeBalanceVersion>=CaelumGrowthRules.PLAYER_BALANCE_VERSION
            ? CaelumGrowthRules.REVISION : 0;
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

        CaelumCharacterIdentity.Bind(self, persistentState, false);
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
        CaelumGrowthMigration.StoredResources(self,persistentState);
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
        return CaelumMerchantCoordinator.GetPalomoMerchantQuantityForIndex(self, quantityIndex);
    }

    int GetPalomoMerchantConsumableType(int merchantItem)
    {
        return CaelumMerchantCoordinator.GetPalomoMerchantConsumableType(self, merchantItem);
    }

    int GetPalomoMerchantMaterialType(int merchantItem)
    {
        return CaelumMerchantCoordinator.GetPalomoMerchantMaterialType(self, merchantItem);
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
        return CaelumMerchantCoordinator.HasPalomoMerchantReputationDiscount(self);
    }

    void RefreshPalomoMerchantSnapshot()
    {
        CaelumMerchantCoordinator.RefreshPalomoMerchantSnapshot(self);
    }

    bool IsActivePalomoMerchantSessionValid()
    {
        return CaelumMerchantCoordinator.IsActivePalomoMerchantSessionValid(self);
    }

    void OpenPalomoMerchant(Actor merchant, CaelumFactionCondition requirement = null,
        CaelumFactionCondition discount = null, String titleKey = "CA_PALOMO_MERCHANT_TITLE")
    {
        CaelumMerchantCoordinator.OpenPalomoMerchant(self, merchant, requirement, discount, titleKey);
    }

    void ClosePalomoMerchant()
    {
        CaelumMerchantCoordinator.ClosePalomoMerchant(self);
    }

    void UpdatePalomoMerchantSession()
    {
        CaelumMerchantCoordinator.UpdatePalomoMerchantSession(self);
    }

    void CyclePalomoMerchantSelection(int direction)
    {
        CaelumMerchantCoordinator.CyclePalomoMerchantSelection(self, direction);
    }

    void TogglePalomoMerchantMode()
    {
        CaelumMerchantCoordinator.TogglePalomoMerchantMode(self);
    }

    void CyclePalomoMerchantQuantity(int direction)
    {
        CaelumMerchantCoordinator.CyclePalomoMerchantQuantity(self, direction);
    }

    void ExecutePalomoMerchantTransaction()
    {
        CaelumMerchantCoordinator.ExecutePalomoMerchantTransaction(self);
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
            case CaelumConstants.WEAPON_TYPE_BOLAS: return 'CaelumBolasSelectorWeapon';
            case CaelumConstants.WEAPON_TYPE_UTILITY_STAFF:
                return 'CaelumUtilityStaffSelectorWeapon';
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
                return 'CaelumShotgunSelectorWeapon';
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
        if(CaelumClassCastView.Active(self))return;
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
        EnsurePhysicalWeaponSelector(CaelumConstants.WEAPON_TYPE_UTILITY_STAFF, "CaelumUtilityStaffSelectorWeapon");
        EnsurePhysicalWeaponSelector(CaelumConstants.WEAPON_TYPE_BOLAS, "CaelumBolasSelectorWeapon");
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
            "CaelumShotgunSelectorWeapon"
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
    // peso. La Caja Mágica suma 1 gramo y reduce el peso agregado de su contenido
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
        return CaelumCraftingCoordinator.GetCraftingDexterityPercent(self);
    }

    double GetCraftingMaterialWorkSeconds(
        int employedMaterialUnits, int complexityTics,
        int efficiencyIndex
    )
    {
        return CaelumCraftingCoordinator.GetCraftingMaterialWorkSeconds(self, employedMaterialUnits, complexityTics, efficiencyIndex);
    }

    int GetCurrentCraftingInputUnits()
    {
        return CaelumCraftingCoordinator.GetCurrentCraftingInputUnits(self);
    }

    void ResetCraftingLayerChoices()
    {
        CaelumCraftingCoordinator.ResetCraftingLayerChoices(self);
    }

    void EnsureCraftingLayerChoiceRoot()
    {
        CaelumCraftingCoordinator.EnsureCraftingLayerChoiceRoot(self);
    }

    int FindCraftingLayerChoice(int recipeIndex, int materialTier)
    {
        return CaelumCraftingCoordinator.FindCraftingLayerChoice(self, recipeIndex, materialTier);
    }

    int GetOrCreateCraftingLayerChoice(
        int recipeIndex, int materialTier
    )
    {
        return CaelumCraftingCoordinator.GetOrCreateCraftingLayerChoice(self, recipeIndex, materialTier);
    }

    int GetCraftingLayerEfficiencyIndex(
        int recipeIndex, int materialTier
    )
    {
        return CaelumCraftingCoordinator.GetCraftingLayerEfficiencyIndex(self, recipeIndex, materialTier);
    }

    void SetCraftingLayerEfficiencyIndex(
        int recipeIndex, int materialTier, int efficiencyIndex
    )
    {
        CaelumCraftingCoordinator.SetCraftingLayerEfficiencyIndex(self, recipeIndex, materialTier, efficiencyIndex);
    }

    void ClearCraftingBlueprint()
    {
        CaelumCraftingCoordinator.ClearCraftingBlueprint(self);
    }

    int FindCraftingBlueprintNode(
        int nodeKind, int recipeIndex,
        int materialType, int materialTier
    )
    {
        return CaelumCraftingCoordinator.FindCraftingBlueprintNode(self, nodeKind, recipeIndex, materialType, materialTier);
    }

    int AddOrAccumulateCraftingBlueprintNode(
        int nodeKind, int depth, int recipeIndex,
        int materialType, int materialTier, int units
    )
    {
        return CaelumCraftingCoordinator.AddOrAccumulateCraftingBlueprintNode(self, nodeKind, depth, recipeIndex, materialType, materialTier, units);
    }

    void ExpandCraftingBlueprintMaterial(
        int materialType, int materialTier, int requiredUnits,
        int depth = 1
    )
    {
        CaelumCraftingCoordinator.ExpandCraftingBlueprintMaterial(self, materialType, materialTier, requiredUnits, depth);
    }

    void BuildCraftingBlueprint()
    {
        CaelumCraftingCoordinator.BuildCraftingBlueprint(self);
    }

    void CycleCraftingBlueprintSelection(int direction)
    {
        CaelumCraftingCoordinator.CycleCraftingBlueprintSelection(self, direction);
    }

    void MarkCraftingBlueprintStepExecuted(
        int recipeIndex, int materialTier
    )
    {
        CaelumCraftingCoordinator.MarkCraftingBlueprintStepExecuted(self, recipeIndex, materialTier);
    }

    bool ReserveCurrentCraftingPreview()
    {
        return CaelumCraftingCoordinator.ReserveCurrentCraftingPreview(self);
    }

    void ClearDirectCraftingPlan()
    {
        CaelumCraftingCoordinator.ClearDirectCraftingPlan(self);
    }

    int GetDirectPlanReservedUnits(int materialType, int materialTier)
    {
        return CaelumCraftingCoordinator.GetDirectPlanReservedUnits(self, materialType, materialTier);
    }

    bool AddDirectPlanReservation(
        int materialType, int materialTier, int units
    )
    {
        return CaelumCraftingCoordinator.AddDirectPlanReservation(self, materialType, materialTier, units);
    }

    int RegisterDirectCraftingStep(int recipeIndex, int materialTier)
    {
        return CaelumCraftingCoordinator.RegisterDirectCraftingStep(self, recipeIndex, materialTier);
    }

    void AddDirectCraftingStepWork(int step, int employedMaterialUnits, int outputUnits=0)
    {
        CaelumCraftingCoordinator.AddDirectCraftingStepWork(self, step, employedMaterialUnits, outputUnits);
    }

    int GetRoundedUpProportionalUnits(
        int requiredOutput, int numerator, int denominator
    )
    {
        return CaelumCraftingCoordinator.GetRoundedUpProportionalUnits(self, requiredOutput, numerator, denominator);
    }

    bool DirectCraftingRecipeKnown(int recipeIndex, int tier = 1)
    {
        return CaelumCraftingCoordinator.DirectCraftingRecipeKnown(self, recipeIndex, tier);
    }

    bool RequireDirectCraftingMaterial(
        int materialType, int materialTier, int requiredUnits,
        int depth = 0
    )
    {
        return CaelumCraftingCoordinator.RequireDirectCraftingMaterial(self, materialType, materialTier, requiredUnits, depth);
    }

    bool IsDirectWeaponCraftingRecipe()
    {
        return CaelumCraftingCoordinator.IsDirectWeaponCraftingRecipe(self);
    }

    void RefreshDirectWeaponCraftingPlan()
    {
        CaelumCraftingCoordinator.RefreshDirectWeaponCraftingPlan(self);
    }

    bool ReservePreparedDirectCraftingPlan()
    {
        return CaelumInventoryService.ReservePreparedDirectCraftingPlan(self);
    }

    bool HasSelectedWeaponCraftingMaterials()
    {
        return CaelumCraftingCoordinator.HasSelectedWeaponCraftingMaterials(self);
    }

    bool ConsumeSelectedWeaponCraftingMaterials()
    {
        return CaelumInventoryService.ConsumeSelectedWeaponCraftingMaterials(self);
    }

    bool CanStartCraftingTask(bool recipeInfrastructure = true)
    {
        return CaelumCraftingCoordinator.CanStartCraftingTask(self, recipeInfrastructure);
    }

    void StartPreparedCraftingTask(int taskKind, double durationSeconds)
    {
        CaelumCraftingCoordinator.StartPreparedCraftingTask(self, taskKind, durationSeconds);
    }

    void BeginSelectedCraftingTask()
    {
        CaelumCraftingCoordinator.BeginSelectedCraftingTask(self);
    }

    void CancelCraftingTask()
    {
        CaelumCraftingCoordinator.CancelCraftingTask(self);
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
        return RecipeQuoteActive || persistentState.KnowsCraftingRecipe(recipeIndex, 0);
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
                case CaelumConstants.CRAFTING_RECIPE_KIND_UTILITY:
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
            if (persistentState.OfferCraftingRecipe(recipeIndex))
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
            case CaelumConstants.WEAPON_TYPE_UTILITY_STAFF: return "CA_UTILITY_STAFF_ICON";
            case CaelumConstants.WEAPON_TYPE_BOLAS: return "CA_BOLAS_ICON";
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
        if(CaelumClothingData.IsRecipe(CraftingSelectionRecipe))return CaelumClothingData.Icon(CraftingSelectionRecipe-CaelumClothingData.FIRST_RECIPE);
        if (CaelumUtilityCrafting.IsRecipe(CraftingSelectionRecipe))
            return CraftingSelectionRecipe == CaelumConstants.CRAFTING_SLEEPING_BAG_RECIPE
                ? "graphics/caelum/icons/ca_sleeping_bag.png" : "graphics/caelum/icons/water/canteen_large.png";
        if (CraftingSelectionRecipe == CaelumConstants.CRAFTING_CARBINE_CARTRIDGE_RECIPE)
            return "graphics/caelum/icons/ca_carbine_ammo.png";
        if (CraftingSelectionRecipe == CaelumConstants.CRAFTING_SHOTGUN_CARTRIDGE_RECIPE)
            return "CA_SHOTGUN_AMMO";
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
        CaelumCraftingCoordinator.RefreshCraftingPreview(self);
    }

    int BeginCraftingNetworkScan()
    {
        return CaelumCraftingCoordinator.BeginCraftingNetworkScan(self);
    }

    void SetCraftingJournalState(bool shouldOpen)
    {
        CaelumCraftingCoordinator.SetCraftingJournalState(self, shouldOpen);
    }

    void OpenCraftingNetwork(Actor sourceStation)
    {
        CaelumCraftingCoordinator.OpenCraftingNetwork(self, sourceStation);
    }

    void OpenCraftingStation(int stationType)
    {
        CaelumCraftingCoordinator.OpenCraftingStation(self, stationType);
    }

    void CloseCraftingStationSession()
    {
        CaelumCraftingCoordinator.CloseCraftingStationSession(self);
    }

    bool RefreshActiveCraftingStationSession(bool recipeInfrastructure = true)
    {
        return CaelumCraftingCoordinator.RefreshActiveCraftingStationSession(self, recipeInfrastructure);
    }

    void ToggleCraftingMenu()
    {
        CaelumCraftingCoordinator.ToggleCraftingMenu(self);
    }

    void CycleCraftingRecipe(int direction)
    {
        CaelumCraftingCoordinator.CycleCraftingRecipe(self, direction);
    }

    void CycleCraftingRecipeFilter()
    {
        CaelumCraftingCoordinator.CycleCraftingRecipeFilter(self);
    }

    void CycleCraftingTier()
    {
        CaelumCraftingCoordinator.CycleCraftingTier(self);
    }

    void CycleCraftingSize()
    {
        CaelumCraftingCoordinator.CycleCraftingSize(self);
    }

    void CycleCraftingEfficiency()
    {
        CaelumCraftingCoordinator.CycleCraftingEfficiency(self);
    }

    void CycleCraftingBatch()
    {
        CaelumCraftingCoordinator.CycleCraftingBatch(self);
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
        if(CaelumExhaustion.Locked(self)){CaelumExhaustion.NotifyLocked(self);return;}
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
        else if (EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_CLOTHING)
            EquipmentSelectionClothingType=(EquipmentSelectionClothingType+direction+CaelumClothingData.COUNT)%CaelumClothingData.COUNT;
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
        if(EquipmentSelectionKind==CaelumConstants.EQUIPMENT_KIND_CLOTHING)return;
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
            || (EquipmentSelectionKind>=CaelumConstants.EQUIPMENT_KIND_MATERIAL
                && EquipmentSelectionKind!=CaelumConstants.EQUIPMENT_KIND_CLOTHING))
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
        CaelumCraftingCoordinator.AdvanceDebugCraftingTime(self);
    }

    void UpdateCraftingTask()
    {
        CaelumCraftingCoordinator.UpdateCraftingTask(self);
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

    // Solicitud de presentación del próximo cruce; se consume una sola vez.
    int PendingTravelWipe;

    override void PreTravelled()
    {
        CaelumTargetSubscriptions.Invalidate(self);
        VoluntaryJumpActive = false;
        let journey = CaelumJourneyState.Get(self);
        int mode = journey != null && journey.Status == CaelumJourneyState.STATUS_DEPARTED
            ? journey.TravelMode : 0;
        int wipe = PendingTravelWipe;
        int cue = 0;
        if(wipe!=CaelumConstants.TRAVEL_WIPE_HOUSE_DOOR)
        {
            if (mode == CaelumJourneyState.MODE_SHIP) { wipe=1; cue=2; }
            else if (mode == CaelumJourneyState.MODE_CART || mode == CaelumJourneyState.MODE_CARAVAN) { wipe=3; cue=1; }
        }
        EventHandler.SendInterfaceEvent(PlayerNumber(), "ca_map_depart", wipe, cue);
        PendingTravelWipe = 0;
        WorldCarbineShotUntil = 0;
        // La fuente local no debe conservar actores/sectores del mapa anterior.
        StopSealChannel(true,false);
        if(RacialAbility is "CaelumTelekinesisEffect")CaelumRacialAbilityRules.Deactivate(self);
        EquipmentMenuOpen = false;
        CloseCraftingStationSession();
        ClosePalomoMerchant();
        PersistCharacterState();
        Super.PreTravelled();
    }

    override void Travelled()
    {
        Super.Travelled();
        VoluntaryJumpActive = false;
        // level.time pertenece al mapa: ningún destello de daño cruza con él.
        CaelumDamageFeedback.ClearFlash(self);
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

        UpdateWorldCarbineVisual();

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
                    duration, debuffScale, dotDamage, effectSource, self
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
                    duration, debuffScale, dotDamage, effectSource, self
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
                    duration, debuffScale, dotDamage, effectSource, self
                );
            }
        }
        else if (essenceType == CaelumConstants.ESSENCE_QUINTESSENCE
            && secondary)
        {
            if (RollQuintessenceEffect())
                ElementalStatus.ApplyDamageOverTime(
                    CaelumConstants.ELEMENTAL_EFFECT_BURN,
                    duration, debuffScale, dotDamage, effectSource, self
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
                    duration, debuffScale, dotDamage, effectSource, self
                );
            if (RollQuintessenceEffect())
                ElementalStatus.ApplyDamageOverTime(
                    CaelumConstants.ELEMENTAL_EFFECT_CUT,
                    duration, debuffScale, dotDamage, effectSource, self
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



    double GetArmorDefensePercent(int slot, bool magical = false,Actor inflictor=null,Actor source=null)
    {
        int race = CharacterProfile != null ? CharacterProfile.Race : CaelumConstants.RACE_HUMAN;
        return CaelumArmorRules.TotalDefense(CaelumArmorRules.InnateDefense(race, magical), ArmorModel, slot, magical,inflictor,self,source);
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
        if (CaelumFormationBreaker.Dashing(self))
            return GetBiologicalLandingAbsorptionSpeed()*CaelumFormationBreaker.Defense(self);
        if (impactKind == CaelumConstants.IMPACT_KIND_FLOOR)
            return GetBiologicalLandingAbsorptionSpeed();

        // Caminar, correr o agacharse permite ceder ante paredes y escenario
        // quieto. El contacto guarda el reposo previo a transmitir impulso;
        // no concede este beneficio a cuerpos ni rocas que ya venían moviéndose.
        bool jumpWall = VoluntaryJumpRevision == 1 && VoluntaryJumpActive
            && impactKind == CaelumConstants.IMPACT_KIND_WALL;
        bool carefulMovement = (IsCrouching || IsWalkingOnGround() || IsRunningOnGround())
            && (impactKind == CaelumConstants.IMPACT_KIND_WALL
                || (impactKind == CaelumConstants.IMPACT_KIND_ENVIRONMENT
                    && stationarySceneryContact));

        // La rodela conserva su versión más potente y también funciona contra
        // actores. La capacidad de caída incorpora esa mejora una sola vez.
        if (!carefulMovement && !jumpWall && !IsBucklerAcrobaticDefenseActive()) return 0.0;
        return GetBiologicalLandingAbsorptionSpeed();
    }

    void EnsureVoluntaryJumpState()
    {
        if (!CaelumPlayerAuthority.CanMutate(self)) return;
        // Un save previo no permite reconstruir si hubo salto o empujón.
        if (VoluntaryJumpRevision < 1)
        {
            VoluntaryJumpActive = false;
            VoluntaryJumpRevision = 1;
        }
    }

    void UpdateVoluntaryJumpState()
    {
        if (!CaelumPlayerAuthority.CanMutate(self)) return;
        EnsureVoluntaryJumpState();
        // onground sigue reflejando el apoyo previo en el tic del despegue.
        // Tras la física se comprueba el apoyo real, sin acortar el descenso.
        if (health <= 0 || player.playerstate != PST_LIVE || WaterLevel >= 2
            || bNOGRAVITY || CaelumTelekinesisRules.Held(self)
            || bONMOBJ || (Pos.Z <= FloorZ && Vel.Z <= 0))
            VoluntaryJumpActive = false;
    }

    double GetBiologicalJumpAbsorptionSpeed()
    {
        // Un personaje consciente flexiona articulaciones y usa musculatura
        // para absorber un aterrizaje comparable a su propio salto normal.
        // Aturdido/inmovilizado cae rígido: no recibe esta amortiguación.
        if (IsPhysicallyImmobilized()) return 0.0;
        return Max(0.0, JumpZ) * (IsBucklerAcrobaticDefenseActive()
            ? CaelumConstants.SHIELD_BUCKLER_AGILITY_ABSORPTION_MULTIPLIER : 1.0);
    }

    double GetBiologicalLandingAbsorptionSpeed()
    {
        return GetBiologicalJumpAbsorptionSpeed()
            * CaelumConstants.BIOLOGICAL_IMPACT_ABSORPTION_MULTIPLIER;
    }

    double GetHazardPressureAbsorptionSpeed(double deltaSpeed)
    {
        // La presión sostenida de rocas conserva la maniobra anterior de rodela.
        // No es un nuevo impacto ni recibe el 150% aprobado para las caídas.
        if (IsPhysicallyImmobilized() || !IsBucklerAcrobaticDefenseActive()) return 0;
        double baseline = DerivedStats!=null
            ? CaelumPhysicsUnits.JumpVelocity(DerivedStats.BaseMass,DerivedStats.TotalMass,0) : 0;
        double bonus = Max(0.0, Max(0.0,JumpZ)/Max(0.0001,baseline)-1.0);
        return Max(0.0,deltaSpeed)*Clamp(
            bonus*CaelumConstants.SHIELD_BUCKLER_AGILITY_ABSORPTION_MULTIPLIER,
            0.0,CaelumConstants.SHIELD_BUCKLER_PRESSURE_ABSORPTION_MAX_FRACTION);
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
        bool stationarySceneryContact = false,
        double receivedJoules = -1,
        CaelumImpactArea preparedArea = null,
        Vector3 contactNormal = (0,0,0),
        double cushionedJoules = -1
    )
    {
        // El escenario y las rocas del mecanismo son daño ambiental, aunque
        // GZDoom los represente con actores: ni daño ni dolor dan adrenalina.
        bool crushingContact = impactKind == CaelumConstants.IMPACT_KIND_CRUSH;
        if ((CaelumHazardRock(sourceActor) != null && impactKind != CaelumConstants.IMPACT_KIND_FLOOR)
            || (impactKind == CaelumConstants.IMPACT_KIND_ACTOR
                && CaelumEnvironmentProp(sourceActor) != null))
            impactKind = CaelumConstants.IMPACT_KIND_ENVIRONMENT;
        LastImpactKind = impactKind;
        LastImpactRawDeltaSpeed = Max(0.0, deltaSpeed);
        LastImpactBiologicalAbsorptionSpeed = 0.0;
        LastImpactDeltaSpeed = LastImpactRawDeltaSpeed;
        if (crushingContact
            || impactKind == CaelumConstants.IMPACT_KIND_FLOOR)
        {
            LastImpactBiologicalAbsorptionSpeed = Min(
                LastImpactRawDeltaSpeed,
                crushingContact
                    ? (CaelumHazardRock(sourceActor)!=null
                        ? GetHazardPressureAbsorptionSpeed(LastImpactRawDeltaSpeed)
                        : GetBiologicalJumpAbsorptionSpeed())
                    : GetBiologicalLandingAbsorptionSpeed()
            );
            LastImpactDeltaSpeed = Max(
                0.0,
                LastImpactRawDeltaSpeed - LastImpactBiologicalAbsorptionSpeed
            );
        }
        else if (impactKind != CaelumConstants.IMPACT_KIND_FLOOR)
        {
            LastImpactBiologicalAbsorptionSpeed = Min(LastImpactRawDeltaSpeed,
                GetImpactAgilityAbsorptionSpeed(impactKind, stationarySceneryContact));
            LastImpactDeltaSpeed = Max(
                0.0,
                LastImpactRawDeltaSpeed - LastImpactBiologicalAbsorptionSpeed
            );
        }
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
        // #247 multiplica la reducción final, nunca el atributo ni la presión sostenida.
        double collisionReduction=CaelumToughnessRules.ActorReduction(self,impactToughness);
        if(!crushingContact)collisionReduction*=CaelumFormationBreaker.Defense(self);
        LastImpactToughnessPercent = 100.0*collisionReduction/GetImpactMaximumHealth();
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
        double innateDefense=Clamp(CaelumArmorRules.InnateDefense(CharacterProfile!=null ? CharacterProfile.Race : CaelumConstants.RACE_HUMAN)/100.0,0.0,1.0);
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
                int slot = GetArmorSlotForHitLocation(location);
                int reinforcement = ArmorModel != null
                    ? ArmorModel.GetReinforcement(slot) : 0;
                int effectiveGrade = Min(
                    CaelumConstants.VULNERABILITY_ARMORED_POINT,
                    naturalGrade + reinforcement
                );
                double vulnerabilityMultiplier =
                    GetVulnerabilityMultiplier(effectiveGrade, false);
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
                if(ArmorModel!=null && ArmorModel.Durability[slot]>0)
                {
                    wearBySlot[slot]+=surfacedJoules*weight*vulnerabilityMultiplier
                        *CaelumArmorRules.EquippedDefense(ArmorModel,slot,false,self,defenseSource)/100.0;
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
        double postToughness=Max(0.0,postArmor-collisionReduction);
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
            int loss=CaelumToughnessRules.ImpactWear(ArmorModel,slot,wearBySlot[slot],ArmorDurabilityDamageMultiplier);
            if (loss>0 && ArmorModel.Durability[slot]<=0) armorPieceBroken=true;
        }
        if (armorPieceBroken) ApplyCharacterProfile();
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

    bool IsCaelumCollisionBody(Actor other)
    {
        CaelumCombatActor combatActor = CaelumCombatActor(other);
        CaelumEnvironmentProp environment = CaelumEnvironmentProp(other);
        return other != null
            && other != self
            && (other.health>0 || (environment!=null && other.bSolid && !other.bShootable))
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
            CaelumImpactEnergy.RepairLegacyContact(contact);
            contact.UpdateSeparation(
                level.time,
                CaelumConstants.IMPACT_CONTACT_REARM_SEPARATED_TICS
            );
            if (!contact.Active)
            {
                // La muestra guardada conserva el trabajo aunque el otro cuerpo
                // ya haya sido destruido. ConsumeWork omite receptores ausentes.
                CaelumImpactEnergy.ConsumeWork(contact);
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
        body.Mass = Max(1.0, GetCombatMass());
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

    // Los árboles arraigados son actores, pero físicamente se comportan como
    // el límite estático de una pared. Conservamos el actor para modelo, masa
    // y futura recolección sin transmitirle velocidad ni repetir daño mientras
    // el mismo contacto siga activo.
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
            contactMaximum,
            true, -1, null, impact.Normal
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

        // El enlace compartido deduplica ambos callbacks, incluido el pasivo.
        CaelumEnvironmentProp environment = CaelumEnvironmentProp(other);
        if (!IsCaelumCollisionBody(other) || health <= 0)
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

        CaelumImpactEnergy.Pair(self,other,selfBody,otherBody,impact,
            CaelumConstants.IMPACT_KIND_ACTOR,stationarySceneryContact);
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
            1.0, false, -1, null, normal
        );
    }

    void RegisterWorldImpact(
        double deltaSpeed,
        int impactKind
    )
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
            Max(1.0, GetCombatMass()),
            0.0,
            effectiveDeltaSpeed,
            0.0,
            0.0,
            impactKind == CaelumConstants.IMPACT_KIND_FLOOR ? 0.0 : 1.0
        );
    }

    // Defensa final para muertes solicitadas directamente por scripts; no
    // resucitar cadáveres cargados ni crear un nuevo perfil o cuerpo.
    override void Die(Actor source, Actor inflictor, int dmgflags, Name MeansOfDeath)
    {
        if(CaelumTutorialSafety.Protects(self))
        {
            health=CaelumTutorialSafety.HealthAfter(self,health);
            player.health=health;
            UpdateHealthStateEffects();
            return;
        }
        CaelumUtilityStaff.EndEmission(self);
        VoluntaryJumpActive = false;
        let dyingRest=CaelumRestState.Get(self);
        if(dyingRest!=null)dyingRest.Exhaustion=false;
        CaelumRestState.Interrupt(self, "CA_REST_DAMAGE");
        CaelumBreathing.StopAudio(self);
        if(CharacterProfile!=null)
        {
            AppearanceDeathProfile=new("CaelumCharacterProfile");
            AppearanceDeathProfile.CopyFrom(CharacterProfile);
            AppearanceDeathGloves=CaelumAppearanceHands.HasGloves(self);
        }
        Super.Die(source, inflictor, dmgflags, MeansOfDeath);
    }

    // Estado visual individual; el daño real sigue en las mismas rutas de defensa.
    int PendingDamageVFXKind,DamageVFXKind,DamageVFXTic,DamageFeedbackRevision;
    double DamageVFXStrength;

    // Contexto síncrono: capturar antes de ganar Adrenalina por bloqueo o dolor.
    transient double RallyDamageFactor;
    transient int RallyPayloadBaseDamage,RallyResolvedDamage;

    int ApplyNativeHealthDamage(Actor inflictor,Actor source,double preciseDamage,Name mod,int flags,double damageAngle)
    {
        int damage=CaelumSealResistance.HealthDamage(self,inflictor,preciseDamage,mod);
        if(flags & DMG_FORCED)damage=CaelumRally.ScaleDamage(self,CaelumSleepRules.ScaleDamage(self,damage));
        // Buddha2 nativo impide la rama letal incluso ante telefrag/daño forzado,
        // después de las defensas. La bandera existe sólo durante esta llamada.
        bool protect=health>0 && damage>0 && CaelumTutorialSafety.Protects(self);
        bool introduced=protect && !(player.cheats & CF_BUDDHA2);
        int before=health;
        if(introduced)player.cheats|=CF_BUDDHA2;
        int result=Super.DamageMobj(inflictor,source,damage,mod,flags,damageAngle);
        if(introduced)player.cheats&=~CF_BUDDHA2;
        CaelumSleepRules.HealthLost(self,before);
        // No contar HP bloqueado por el piso ni atribuir daño anidado a este golpe.
        return protect ? Max(0,Min(result,before-health)) : result;
    }

    override int TakeSpecialDamage(Actor inflictor,Actor source,int damage,Name mod)
    {
        // Tras las defensas propias y los factores nativos; antes de perder HP.
        return CaelumRally.ScaleDamage(self,
            CaelumSleepRules.ScaleDamage(self,Super.TakeSpecialDamage(inflictor,source,damage,mod)));
    }

    override int DamageMobj(Actor inflictor,Actor source,int damage,Name mod,int flags,double angle)
    {
        if(!CaelumArcaneSun.AllowsDamage(inflictor,self)
            || (!(flags & DMG_FORCED) && !CaelumRedemption.AllowsDamage(source,self,mod)))return 0;
        CaelumBolas.FireAttack(self,inflictor,mod);
        int before=health;
        let shot=CaelumActorProjectile(inflictor);
        Actor previousReceiver=shot!=null?shot.CaelumDefenseReceiver:null;
        double previousRallyFactor=RallyDamageFactor;
        int previousRallyBase=RallyPayloadBaseDamage,previousRallyResolved=RallyResolvedDamage;
        RallyDamageFactor=CaelumRally.DamageFactor(self,source);
        RallyPayloadBaseDamage=RallyResolvedDamage=0;
        int result=ReceiveCaelumDamage(inflictor,source,damage,mod,flags,angle);
        RallyDamageFactor=previousRallyFactor;
        RallyPayloadBaseDamage=previousRallyBase;RallyResolvedDamage=previousRallyResolved;
        if(shot!=null)shot.CaelumDefenseReceiver=previousReceiver;
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
        if (CaelumMainM00RuloTrial.IsPartyMember(source, self)) return 0;
        bool periodic=mod=='CaelumElementalDOT';

        // El mundo no puede dañar al personaje antes de confirmar su creación.
        if (CreationWizardOpen && !CharacterCreationComplete)
        {
            return 0;
        }

        if(!periodic)CaelumRestSafety.Interrupt(self,"CA_REST_DAMAGE");

        // Ahogamiento y aplastamiento nativo actualizan vida, dolor e
        // interrupciones, sin iniciar combate ni otorgar adrenalina.
        if (mod == 'Drowning' || mod == 'Crush' || mod == 'CaelumWeight' || mod == 'CaelumPressure'
            || mod=='CaelumEarthquake' || CaelumToughnessRules.IsSustained(mod))
        {
            // Techo: trabajo medido; ahogamiento/presión ya llegan resueltos.
            // P_DoCrunch envía source e inflictor nulos.
            double preToughnessDamage=damage;
            if (mod == 'Crush' && inflictor == null && source == null)
                preToughnessDamage = damage>=CaelumCrushingDamage.NATIVE_TELEFRAG_THRESHOLD ? damage : CaelumCrushingDamage.NativeWork(self);
            if((mod=='Crush' && damage<CaelumCrushingDamage.NATIVE_TELEFRAG_THRESHOLD) || mod=='CaelumWeight' || mod=='CaelumEarthquake')
                damage=Max(0,int(CaelumToughnessRules.Apply(self,preToughnessDamage)+0.5));
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

            int drowningResult = ApplyNativeHealthDamage(
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
                    false,
                    periodic
                );
            }
            return drowningResult;
        }

        // El receptor de impacto ya resolvió área, armadura y Dureza. Esta
        // entrada sólo aplica HP, dolor e interrupciones, sin repetir defensas.
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

        damage=CaelumActorProjectile.PrepareDefense(self,inflictor,damage,mod,flags);
        if(damage<=0)return 0;
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
        int result = ApplyNativeHealthDamage(
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
        if (CaelumArmorRules.IsMagical(inflictor,mod)) { return true; }
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
            return ApplyNativeHealthDamage(
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

        double toughness = CaelumToughnessRules.Effective(self);

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

            double preDefenseDamage = postAnatomyDamage;
            double defenseRatio = Clamp(GetArmorDefensePercent(slot, magical,inflictor,source) / 100.0, 0.0, 1.0);
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
                double eligibleDamage = preDefenseDamage * CaelumArmorRules.EquippedDefense(ArmorModel,slot,magical,self,inflictor,source)/100.0
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

        double postToughnessDamage=CaelumToughnessRules.AfterActorDefenses(
            self,LastArmorPostDefenseDamage,toughness,magical);
        LastToughnessDamageMultiplier=CaelumToughnessRules.RetainedFraction(LastArmorPostDefenseDamage,postToughnessDamage);
        totalHealthDamage=Max(0,int(postToughnessDamage+0.5));
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
        int result = ApplyNativeHealthDamage(
            inflictor,
            source,
            postToughnessDamage,
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
                        attackProjectile, CaelumSealResistance.PayloadDamage(self,inflictor,
                            postToughnessDamage,CaelumRally.PayloadLoss(self,actualHealthLost),mod)
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
            return ApplyNativeHealthDamage(
                inflictor,
                source,
                incomingDamage,
                mod,
                flags,
                damageAngle
            );
        }
        let mixed=CaelumMixedMeleeDamage.ForHit(self,inflictor,source,mod);
        if(mixed!=null)mixed.PrepareFire(self);
        double damageAfterShield = ResolveRealShieldDamage(
            inflictor,
            source,
            incomingDamage,
            mod,mixed
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
            CaelumArmorRules.IsMagical(inflictor, mod),inflictor,source,mixed
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
        double finalDamage = Max(0.0, LastArmorPostDefenseDamage*LastToughnessDamageMultiplier);
        int result = 0;
        if (finalDamage > 0)
        {
            result = ApplyNativeHealthDamage(
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
            if(mixed!=null)mixed.ApplyBurn(self,healthBeforeDamage);
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
                    attackProjectile, CaelumSealResistance.PayloadDamage(self,inflictor,
                        finalDamage,CaelumRally.PayloadLoss(self,actualHealthLost),mod)
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
        Name mod,
        CaelumMixedMeleeDamage mixed=null
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


        int damageKind = CaelumArmorRules.IsMagical(inflictor,mod)
            ? CaelumConstants.SHIELD_DAMAGE_MAGICAL
            : CaelumConstants.SHIELD_DAMAGE_PHYSICAL;
        double defenseRatio = Clamp(
            GetActiveBlockDefense(damageKind) / 100.0
                * CaelumPersonalityRules.Absorption(self,damageKind==CaelumConstants.SHIELD_DAMAGE_MAGICAL)
                * (1-CaelumPersonalityRules.AttackPenetration(inflictor,source)),
            0.0,
            1.0
        );
        double physicalAbsorbed = incomingDamage * defenseRatio;
        LastShieldAbsorbedDamage = physicalAbsorbed;
        if(mixed!=null)LastShieldAbsorbedDamage+=mixed.BlockFire(self,
            GetActiveBlockDefense(CaelumConstants.SHIELD_DAMAGE_MAGICAL),inflictor,source);
        LastShieldHealthDamage = Max(
            0,
            int(incomingDamage-physicalAbsorbed+(mixed!=null ? mixed.FireAfterShield : 0)+0.5)
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
        // Conservar la fracción hasta terminar armadura y Dureza.
        return Max(0.0,incomingDamage-physicalAbsorbed);
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
        bool magical = false,Actor inflictor=null,Actor source=null,CaelumMixedMeleeDamage mixed=null
    )
    {
        LastLocalizedLucidityLoss = 0.0;
        LastArmorPreDefenseDamage = 0.0;
        LastArmorAbsorbedDamage = 0.0;
        LastArmorPostDefenseDamage = 0.0;
        LastArmorHealthDamage = 0;
        LastToughnessDamageMultiplier = 1.0;
        LastArmorDurabilityLoss = 0;
        LastArmorDurabilityChancePercent = 0.0;
        LastArmorDurabilityRollPercent = 0.0;
        LastArmorHitWasCritical = criticalHit && incomingDamage > 0.0;
        if (incomingDamage <= 0.0 && (mixed==null || mixed.FireAfterShield<=0)) { return; }

        int slot = Clamp(
            incomingSlot, 0, CaelumConstants.ARMOR_SLOT_COUNT - 1
        );
        LastArmorVulnerabilityGrade = GetEffectiveArmorVulnerability(slot);
        LastArmorVulnerabilityMultiplier = GetVulnerabilityMultiplier(
            LastArmorVulnerabilityGrade,
            criticalHit
        );
        double postAnatomyDamage = incomingDamage * LastArmorVulnerabilityMultiplier;
        LastArmorPreDefenseDamage = postAnatomyDamage;
        double defenseRatio = Clamp(
            GetArmorDefensePercent(slot, magical,inflictor,source) / 100.0,
            0.0,
            1.0
        );
        LastArmorAbsorbedDamage = LastArmorPreDefenseDamage * defenseRatio;
        LastArmorPostDefenseDamage = Max(
            0.0,
            LastArmorPreDefenseDamage - LastArmorAbsorbedDamage
        );
        double fireIncoming=mixed!=null ? mixed.FireAfterShield*LastArmorVulnerabilityMultiplier : 0;
        double fireAbsorbed=mixed!=null ? fireIncoming*Clamp(
            GetArmorDefensePercent(slot,true,inflictor,source)/100.0,0.0,1.0) : 0;
        double postToughnessDamage;
        if(mixed!=null)
        {
            postToughnessDamage=mixed.Resolve(self,LastArmorPostDefenseDamage,fireIncoming-fireAbsorbed);
            LastArmorPreDefenseDamage+=fireIncoming;LastArmorAbsorbedDamage+=fireAbsorbed;
            LastArmorPostDefenseDamage=mixed.BeforeToughness;
        }
        else postToughnessDamage=CaelumToughnessRules.Apply(self,LastArmorPostDefenseDamage,magical);
        LastToughnessDamageMultiplier=CaelumToughnessRules.RetainedFraction(LastArmorPostDefenseDamage,postToughnessDamage);
        LastArmorHealthDamage = Max(
            0,
            int(postToughnessDamage + 0.5)
        );

        // El cuerpo absorbe su parte sin desgastar la pieza equipada.
        double eligibleDamage = (postAnatomyDamage
            * CaelumArmorRules.EquippedDefense(ArmorModel,slot,magical,self,inflictor,source)/100.0
            +fireIncoming*CaelumArmorRules.EquippedDefense(ArmorModel,slot,true,self,inflictor,source)/100.0)
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

    // Dolor usa el porcentaje de Salud máxima perdido tras todas las
    // mitigaciones. Diez veces ese porcentaje se reduce por el complemento
    // Tipo 1 de Dureza y por la Adrenalina anterior al golpe.
    void CalculateAndTriggerPain(
        int actualHealthLost,
        double adrenalineRatioBeforeDamage,
        bool grantPainAdrenaline,
        bool periodic=false
    )
    {
        if (actualHealthLost > 0 && !periodic) CaelumRestSafety.Interrupt(self, "CA_REST_DAMAGE");
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
                CaelumRestSafety.RecordPain(self,LastPainAnimationDuration,periodic);
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
        if (CaelumCharacterIdentity.VoiceSex(self) == CaelumConstants.SEX_FEMALE)
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
        bool impulse=CaelumMovementImpulse.Begin(self);
        CaelumFormationBreaker.PrepareMove(self);
        vector3 before=Vel;
        Super.MovePlayer();
        // Compensa sólo la propulsión nativa de este comando. Sin este término,
        // el rozamiento añadiría otra demora a la rampa lineal. No se recorta
        // la velocidad total: choques, empujes y frenado siguen siendo nativos.
        if (CaelumFormationBreaker.Dashing(self)) CaelumFormationBreaker.Drive(self,Vel-before);
        else if (impulse) CaelumMovementImpulse.Finish(self,Vel-before);
        else if (MovementAccelerationStep > 0 && MovementAccelerationFactor > 0
            && !IsPhysicallyImmobilized()
            && (player.onground || (bNOGRAVITY && bFLY) || WaterLevel > 0))
        {
            double friction, moveFactor;
            [friction, moveFactor] = GetFriction();
            if (friction > 0 && friction < 1 && !bNOFRICTION)
                Vel += (Vel-before) * (friction * MovementAccelerationStep
                    / ((1-friction) * MovementAccelerationFactor));
        }
        CaelumThermalMotion.PlayerInput(self,before.XY);
    }

    override void PlayerThink()
    {
        // El cursor evita movimientos nuevos; también hay que neutralizar
        // los giros que estaban retenidos antes de abrir estos paneles.
        let journalOpen=player==null?null:CVar.GetCVar("ca_journal_open",player);
        let preview=CaelumChestPreviewState.Get(self);
        bool readingMenu=(journalOpen!=null && journalOpen.GetBool()) || (preview!=null && preview.IsOpen());
        let journeyPlan = CaelumJourneyPlan.Get(self);
        bool choosingJourney = journeyPlan != null && journeyPlan.Open;
        CaelumMovementImpulse.Observe(self,readingMenu || choosingJourney);
        CaelumFormationBreaker.Guard(self,readingMenu || choosingJourney || CreationWizardOpen
            || EquipmentMenuOpen || CraftingMenuOpen || PalomoMerchantMenuOpen
            || HasActiveConversation() || CaelumTimeSkipState.IsOpen(self)
            || CaelumRestState.IsActive(self) || CombatChannelModeActive);
        if (choosingJourney && (health <= 0 || journeyPlan.OriginMap != level.MapName))
        { CaelumJourneyPlan.Cancel(self); choosingJourney = false; }
        if(player!=null && (readingMenu || choosingJourney || CreationWizardOpen || EquipmentMenuOpen || PalomoMerchantMenuOpen
            || CraftingMenuOpen || CaelumTimeSkipState.IsOpen(self) || CaelumRestState.IsActive(self)))
        {player.cmd.yaw=0;player.cmd.pitch=0;player.cmd.roll=0;}
        CaelumRacialAbilityRules.ObserveInput(self);
        CaelumRestState.HandleInput(self);
        if (player != null && (player.cmd.buttons & BT_USER4) == 0) ClassSleepInputLatched = false;
        CaelumClassAbilityRules.FilterInput(self);
        if(CaelumBattleCry.Active(self) && player!=null)
            player.cmd.buttons &= ~(BT_ATTACK|BT_ALTATTACK);
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
        if ((readingMenu || CreationWizardOpen || EquipmentMenuOpen || CraftingMenuOpen
                || choosingJourney || CaelumTimeSkipState.IsOpen(self) || PalomoMerchantMenuOpen
                || CombatChannelModeActive || CaelumRestState.IsActive(self) || ForcedSleepTics > 0
                || CaelumTelekinesisRules.Held(self))
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

            if(!CaelumExhaustion.Active(self) && !CaelumTelekinesisRules.Held(self))
            {
                Vel.X = 0.0;
                Vel.Y = 0.0;
            }
        }

        Super.PlayerThink();
        CaelumRestState.UpdateViewInput(self);
    }

    // Tick runs once per game tic. GZDoom uses 35 tics per second, so dividing
    // the documented per-second rate by TICRATE produces frame-independent
    // regeneration that also pauses when the game itself is paused.
    override bool UseInventory(Inventory item)
    {
        // La bolsa abre su interacción existente sin consumir el Inventory.
        let bag=CaelumSleepingBag(item);
        if(bag!=null)
            return CaelumPlayerAuthority.CanMutate(self)
                && CaelumQuickUse.Available(self,bag) && bag.Open(self);
        // InvUse y el inventario formal llegan al mismo objeto nativo.
        // Los recipientes conservan su instancia: Drink consume agua, no Amount.
        let consumable=CaelumConsumableItem(item);
        if(consumable!=null)
        {
            if(!CaelumPlayerAuthority.CanMutate(self) || !CaelumQuickUse.Available(self,item))return false;
            let water=CaelumWaterContainer(item);
            if(water!=null)return water.Drink();
        }
        if(item==null || !Super.UseInventory(item))return false;
        if(consumable!=null)OnNativeInventoryChanged();
        return true;
    }

    override void Tick()
    {
        // También repara flags/selección de saves anteriores sin duplicar stock.
        CaelumQuickUse.Reconcile(self);
        CaelumCharacterIdentity.Ensure(self);
        CaelumSocialization.Update(self);
        CaelumRacialAbilityRules.Guard(self);
        CaelumDamageFeedback.EnsureRevision(self);
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
        CaelumTelekinesisRules.Physics(self);
        if(CaelumTelekinesisRules.Held(self))prePhysicsVelocity=Vel;
        Super.Tick();
        UpdateVoluntaryJumpState();
        CaelumUtilityStaff.Update(self);
        CaelumBolas.Update(self);
        CaelumRestState.Validate(self);
        if(!ClothingMigrationReady)CaelumClothing.Migrate(self);
        if (level.time % TICRATE == 0) CaelumRecipeLearning.DeliverPending(self);
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
        CaelumFormationBreaker.AfterPhysics(self,thermalBefore);

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
        CaelumNotifications.Survival(self);
    }

    // Este paso no mueve actores ni llama Super.Tick. Cada intervalo simulado
    // recorre las mismas tasas y umbrales que un tic de juego normal.
    void AdvancePersonalTimeTic(bool realStep=true)
    {
        CaelumThermalRuntime.PlayerStep(self,realStep);
        if(health<=0)return;
        CaelumTarotService.Advance(self);
        if (ElementalStatus != null) { ElementalStatus.Tick(self,realStep); }
        if(health<=0)return;
        IlluminationRemaining = Max(
            0.0, IlluminationRemaining - 1.0 / TICRATE
        );

        UpdateHealthStateEffects();


        // Paciencia conserva la tasa; Constitución/reposo reducen los costes.
        CaelumPlayerResources.ApplyAnimaRegeneration(self);
        CaelumRacialAbilityRules.Advance(self,realStep);

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
        CaelumClassAbilityRules.Advance(self);

        UpdateSurvivalResources();
        ApplyCriticalSurvivalDamage();
        if(health<=0)return;
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
            if (ForcedSleepTics == 0)CaelumSleepRules.Wake(self);
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
        if(CaelumArcaneCloud.Active(self))
        {
            // Sólo postura mundial: el arma y el bloqueo siguen usando sus estados.
            State seated=FindState("RestSeated");
            if(CurState!=seated)SetState(seated);
            return;
        }
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

    // Presentación optativa; una subclase no adquiere autoridad sobre la acción.
    virtual bool ApplyCustomWorldVisual(){return false;}

    void UpdateWorldCarbineVisual()
    {
        if(CurState==null)return;
        sprite=CurState.sprite;
        frame=CurState.Frame;
        // El motor compara crouchsprite con el sprite final, no con el estado.
        crouchsprite=sprite==GetSpriteIndex("RSDO") && frame>=2 ? sprite : 0;
        CaelumCarbineWorld.Apply(self,WeaponModel!=null && WeaponModel.Equipped
            && CaelumRangedRules.IsFirearm(WeaponModel.WeaponType),
            Vel.XY.Length()>0.01,level.time<WorldCarbineShotUntil,
            RangedReloadActive ? RangedReloadRemainingSeconds : 0,RangedReloadTotalSeconds);
        if(!ApplyCustomWorldVisual())CaelumAppearance.Apply(self);
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
            EffectiveStealthPercent = CaelumHuntersInstinct.Stealth(self,
                DerivedStats.StealthPercent * CrouchStealthMultiplier);
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
        if(CaelumBattleCry.Active(self))return false;
        if(CaelumClassCastView.Active(self))return false;
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
        if(!CaelumAirPayment.CanAfford(self,cost))return false;
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

    // Consulta común del combate y de Personaje; no tira dados ni consume recursos.
    double PhysicalCriticalChanceFor(int catalogueWeapon, bool ranged = false)
    {
        if (DerivedStats == null || WeaponModel == null) return 0;
        double baseChance = CaelumWeaponCatalogue.GetCriticalChancePercent(catalogueWeapon);
        if (ranged) baseChance *= GetRangedTierCriticalMultiplier(WeaponModel.Tier);
        return CaelumAttackRules.CriticalChance(baseChance, DerivedStats.PhysicalCriticalChance,
            CrouchCriticalChanceMultiplier, CaelumPersonalityRules.Critical(self)
                * CaelumSurvivalInstinct.Multiplier(self));
    }

    double MagicalCriticalChanceFor(int weaponType)
    {
        if (DerivedStats == null || WeaponModel == null) return 0;
        return CaelumAttackRules.CriticalChance(WeaponModel.GetBaseCriticalChanceFor(weaponType),
            DerivedStats.MagicalCriticalChance, CrouchCriticalChanceMultiplier,
            CaelumPersonalityRules.Critical(self)*CaelumSurvivalInstinct.Multiplier(self));
    }

    void PerformEquippedWeaponPrimaryAttack()
    {
        CaelumCombatDispatch.PerformEquippedWeaponPrimaryAttack(self);
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
        CaelumCombatDispatch.PerformLargeWeaponSweep(self, weaponType);
    }

    // AltFire pertenece exclusivamente al arma activa. El escudo ya no
    // intercepta este input: Block usa el estado nativo Zoom de forma
    // independiente.
    void PerformEquippedWeaponSecondaryAttack()
    {
        CaelumCombatDispatch.PerformEquippedWeaponSecondaryAttack(self);
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
        LastWeaponDurabilityChancePercent = CaelumWeaponUseRules.WearChance(eligibleDamage);
        int roll = Random[CaelumWeaponDurability](0, 999999);
        LastWeaponDurabilityRollPercent = roll / 10000.0;
        LastWeaponDurabilityLoss = CaelumWeaponUseRules.WearLoss(eligibleDamage,
            weapon.Durability,LastWeaponDurabilityRollPercent);
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
        if(CaelumBattleCry.Active(self))return;
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
        if (!CaelumAirPayment.CanAfford(self,airCost)) { return; }

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
            catalogueWeapon, WeaponModel.Tier, CurrentLucidity
        ) * 100.0 / accuracyPercent;
        double maximumSpread = CaelumWeaponCatalogue.GetMaximumSpread(
            catalogueWeapon, WeaponModel.Tier, CurrentLucidity
        ) * 100.0 / accuracyPercent;
        double spreadRoll = Random[CaelumJavelinSpread](0, 100000)
            / 100000.0;
        double spreadMagnitude = minimumSpread
            + (maximumSpread - minimumSpread) * spreadRoll;
        double yawOffset = Random[CaelumJavelinYaw](-100000, 100000)
            / 100000.0 * spreadMagnitude;
        double pitchOffset = Random[CaelumJavelinPitch](-100000, 100000)
            / 100000.0 * spreadMagnitude;

        double criticalChance = PhysicalCriticalChanceFor(catalogueWeapon);
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
        projectile.StoreCaelumCriticalRoll(criticalChance,criticalRoll/10000.0);
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
        CaelumAirPayment.Spend(self,airCost);
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
        // conserva la regla acordada: base / modificador Tipo 2.
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
        if(CaelumClassCastView.Active(self))return;
        if(CaelumBolas.Restrained(self))return; // El flanco de Reload inicia el corte en Update.
        if(requestedWeaponType==CaelumConstants.WEAPON_TYPE_UTILITY_STAFF
            || requestedWeaponType==CaelumConstants.WEAPON_TYPE_BOLAS)return;
        if (PhysicalAttackPending) return;
        if (IsRangedWeaponType(requestedWeaponType))
        {
            RequestRangedReload(requestedWeaponType);
            return;
        }
        if(CaelumBattleCry.Active(self))return;
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

        // Fire con el cargador vacío puede solicitarla otra vez durante la recarga.
        // Conservar el progreso evita reinicios y doble inicio del esfuerzo térmico.
        if (RangedReloadActive && RangedReloadWeaponType == requestedWeaponType) return;

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
        if(CaelumBattleCry.Active(self))return;
        if(CaelumClassCastView.Active(self))return;
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
        LastCarbineHadEnoughAir = CaelumAirPayment.CanAfford(self,airCost);
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
            catalogueWeapon, WeaponModel.Tier, CurrentLucidity
        )
            * 100.0 / LastCarbineAccuracyPercent;
        LastCarbineMaximumSpread = CaelumWeaponCatalogue.GetMaximumSpread(
            catalogueWeapon, WeaponModel.Tier, CurrentLucidity
        )
            * 100.0 / LastCarbineAccuracyPercent;
        double spreadRoll = Random[CaelumCarbineSpread](0, 100000) / 100000.0;
        double spreadMagnitude = LastCarbineMinimumSpread
            + (LastCarbineMaximumSpread - LastCarbineMinimumSpread) * spreadRoll;
        LastCarbineYawOffset = Random[CaelumCarbineYaw](-100000, 100000)
            / 100000.0 * spreadMagnitude;
        LastCarbinePitchOffset = Random[CaelumCarbinePitch](-100000, 100000)
            / 100000.0 * spreadMagnitude;

        double criticalChance = PhysicalCriticalChanceFor(catalogueWeapon, true);
        int criticalRoll = Random[CaelumCarbineCritical](0, 999999);
        LastCarbineCriticalHit = criticalRoll / 10000.0 < criticalChance;
        LastCarbineDamage = WeaponModel.GetDamage()
            * EffectiveOffensiveDamageMultiplier;

        if(WeaponModel.WeaponType==CaelumConstants.WEAPON_TYPE_SHOTGUN)
        {
            if(!CaelumShotgunRules.Fire(self,WeaponModel,LastCarbineDamage,LastCarbineCriticalHit,
                DerivedStats.PhysicalPushMultiplier,LastCarbineMinimumSpread,LastCarbineMaximumSpread,
                criticalChance,criticalRoll/10000.0))return;
            ShotgunLastBarrel=(ShotgunLoadedMask&2)!=0 ? 1 : 0;
        }
        else
        {
            let projectile=CaelumRangedRules.Fire(self,WeaponModel,LastCarbineDamage,
                LastCarbineCriticalHit,DerivedStats.PhysicalPushMultiplier,
                Angle+LastCarbineYawOffset,Pitch+LastCarbinePitchOffset,criticalChance,criticalRoll/10000.0);
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
        CaelumAirPayment.Spend(self,airCost);
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
        if(CaelumBattleCry.Active(self))return;
        if(CaelumClassCastView.Active(self))return;
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
        if(CaelumBattleCry.Active(self))return;
        if(CaelumClassCastView.Active(self))return;
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
        if(CaelumBattleCry.Active(self))return;
        double magicDamageScale = WeaponModel.GetDamage()
            / CaelumConstants.DEBUG_STAFF_BASE_DAMAGE;
        UpdateLucidityAccuracyEffects();
        UpdateCrouchEffects();
        LastStaffAccuracyPercent = Max(
            1.0,
            EffectiveMagicalAccuracyPercent * CrouchAccuracyMultiplier
        );
        double maximumAimError = WeaponModel.GetMaximumSpreadFor(activeMagicType, CurrentLucidity)
            * 100.0 / LastStaffAccuracyPercent;
        double minimumAimError = WeaponModel.GetMinimumSpreadFor(activeMagicType, CurrentLucidity)
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
        LastStaffCriticalChancePercent = MagicalCriticalChanceFor(activeMagicType);
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
            projectile.StoreCaelumCriticalRoll(LastStaffCriticalChancePercent,LastStaffCriticalRollPercent);
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
    double RunningAirCostPerSecond()
    {
        return DerivedStats==null?0:CaelumConstants.RUN_AIR_COST_PER_SECOND
            * DerivedStats.AirConsumptionMultiplier * CaelumThermalEffects.HeatCost(self);
    }

    void ConsumeRunningAir()
    {
        if (!IsSpendingRunningAir || DerivedStats == null)
        {
            return;
        }

        double previousAir = CurrentAir;
        CaelumAirPayment.Spend(self,RunningAirCostPerSecond() / TICRATE);
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
            && !CaelumClassCastView.Active(self)
            && !IsPhysicallyImmobilized()
            && HasActiveBlockSource()
            && CaelumAirPayment.HasSupply(self);
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
        if(CaelumClassCastView.Active(self))return;
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
        return CaelumSealResistance.Equipped(self);
    }

    double GetSealChannelAdrenalinePerTic(int tier)
    {
        if (tier >= 3) return CaelumConstants.SEAL_CHANNEL_T3_ADRENALINE_PER_TIC;
        if (tier == 2) return CaelumConstants.SEAL_CHANNEL_T2_ADRENALINE_PER_TIC;
        return CaelumConstants.SEAL_CHANNEL_T1_ADRENALINE_PER_TIC;
    }

    void StopSealChannel(bool startCooldown,bool releaseAttack=true)
    {
        if (!CombatChannelModeActive && CombatChannelEffectActor == null) return;
        CombatChannelModeActive = false;
        HUDChannelAffectedCount = 0;
        if (CombatChannelEffectActor != null)
        {
            CaelumChannelEffect effect = CaelumChannelEffect(CombatChannelEffectActor);
            if (effect != null) effect.ReleaseChannel(releaseAttack);
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
        if(CaelumBattleCry.Active(self))return false;
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
        if(CaelumClassCastView.Active(self))return;
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

    // Los efectos se incorporan por separado; no activar bonificaciones ficticias.
    virtual CaelumRacialAbilityEffect CreateRacialAbilityEffect(int race)
    {
        if(race==CaelumConstants.RACE_CAELITH)return new("CaelumSupernaturalBreathingEffect");
        if(race==CaelumConstants.RACE_GOBLIN)return new("CaelumTelekinesisEffect");
        if(race==CaelumConstants.RACE_HUMAN)return new("CaelumSocializationEffect");
        if(race==CaelumConstants.RACE_BEAST_MAN)return new("CaelumHuntersInstinctEffect");
        return null;
    }

    void ReserveRacialAbilityInput()
    {
        CaelumRacialAbilityRules.Input(self);
    }

    void ReserveTarotInput()
    {
        if(CaelumClassCastView.Active(self))return;
        if (CombatTarotInputReserved) return;
        CombatTarotInputReserved = true;
        CaelumTarotService.Activate(self);
    }

    void ReserveClassAbilityInput()
    {
        if (ClassCastActive || (CharacterProfile != null
            && CaelumClassAbilityRules.Implemented(CharacterProfile.GetProfession())))
        {
            CaelumClassAbilityRules.Input(self);
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
        if (!CaelumAirPayment.HasSupply(self))
        {
            CancelCombatBlockMode();
            return;
        }
        CaelumAirPayment.Spend(self,CurrentShieldAirCostPerSecond * CaelumThermalEffects.HeatCost(self) / TICRATE);
        if (!CaelumAirPayment.HasSupply(self)) { CancelCombatBlockMode(); }
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
    override void CheckMoveUpDown()
    {
        Super.CheckMoveUpDown();
        // El motor asigna la propulsión vertical por separado de ForwardMove.
        // Se escala sólo el comando nuevo, nunca una caída o un empuje recibido.
        if(player!=null && player.cmd.upmove!=0 && player.cmd.upmove!=-32768
            && CaelumArcaneCloud.Active(self))Vel.Z*=CaelumArcaneCloud.SpeedFactor(self);
    }

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
            if (CaelumPlayerAuthority.CanMutate(self))
            {
                EnsureVoluntaryJumpState();
                VoluntaryJumpActive = true;
            }
            ConsumeJumpAir();
            if(DerivedStats!=null)
                CaelumThermalService.Impulse(self,CaelumThermalRules.JumpHeat(DerivedStats.TotalMass,
                    CaelumPhysicsUnits.VelocitySI(before),CaelumPhysicsUnits.VelocitySI(Vel.Z),
                    CaelumThermalBody.Efficiency(self)),true);
        }
    }

    void UpdateMovementAcceleration()
    {
        // La fracción antigua ya expresa progreso, no segundos. Se conserva
        // al migrar y no se reinterpreta como una velocidad ni un impulso.
        if (MovementAccelerationRevision < 1)
        {
            MovementAccelerationFactor = Clamp(MovementAccelerationFactor, 0.0, 1.0);
            MovementAccelerationRevision = 1;
        }
        MovementAccelerationStep = 0;
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

        if (DerivedStats == null || DerivedStats.TotalMass <= 0) { return; }
        double previousFactor = MovementAccelerationFactor;
        double duration = CaelumConstants.MOVEMENT_ACCELERATION_SECONDS
            * DerivedStats.TotalMass / CaelumConstants.MOVEMENT_ACCELERATION_REFERENCE_KG;
        MovementAccelerationFactor += 1.0 / (duration * TICRATE);
        MovementAccelerationFactor = Clamp(
            MovementAccelerationFactor, 0.0, 1.0
        );
        MovementAccelerationStep = MovementAccelerationFactor - previousFactor;
        MovementAccelerationSeconds += 1.0 / TICRATE;
    }

    // Apply the verified effective values to GZDoom's real movement fields.
    // Forward/backward, sideways, swimming, and flight share this movement.
    void ApplyPhysicalMovement()
    {
        double movementFactor = Max(0.0, EffectiveMovementPercent / 100.0) * CaelumThermalEffects.Speed(self);
        movementFactor*=CaelumArcaneCloud.SpeedFactor(self);
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
            // El agotamiento quita el control, pero conserva caída, empujes y agua.
            if (IsOtherwiseImmobilized() && !CaelumTelekinesisRules.Held(self))
            {
                Vel.X = 0.0;
                Vel.Y = 0.0;
            }
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
        JumpZ = DerivedStats!=null && Attributes!=null
            ? CaelumPhysicsUnits.JumpVelocity(DerivedStats.BaseMass,DerivedStats.TotalMass,Attributes.Agility)*jumpFactor : 0;
    }

    bool IsPhysicallyImmobilized(bool ignorePain=false)
    {
        return CaelumExhaustion.Active(self) || CaelumTelekinesisRules.Held(self) || IsOtherwiseImmobilized(ignorePain);
    }

    bool IsOtherwiseImmobilized(bool ignorePain=false)
    {
        return CaelumBolas.Restrained(self) || CombatChannelModeActive
            || ForcedSleepTics > 0
            || LucidityPhysicalStunRemaining > 0.0
            || (!ignorePain && PainImmobilizationRemaining > 0.0)
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
                for (int family = 0; family < CaelumConstants.ATTRIBUTE_LAYER_COUNT; family++)
                    AddJewelryFamilyBonus(a, family, CaelumEquipmentRules.AmuletFamilyBonus(j.ItemType, family, mult));
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
        CaelumAirPayment.Spend(self,finalCost * CaelumThermalEffects.HeatCost(self));
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
    void AddAdrenaline(double amount, bool applyAbility=true)
    {
        CaelumPlayerResources.AddAdrenaline(self, amount,applyAbility);
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
        AddAdrenaline(CaelumConstants.DEBUG_ADRENALINE_GAIN,false);
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
        if(CaelumBattleCry.Active(self))return;
        if(CaelumClassCastView.Active(self))return;
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
        if (!CaelumAirPayment.CanAfford(self,LastMeleeAirCost))
        {
            return;
        }

        LastMeleeHadEnoughAir = true;
        if (chargedAttack) { ConsumeWeaponChargedState(); }
        CaelumThermalEffects.RecordWeaponAction(self,WeaponModel.WeaponType,secondaryAttack,chargedAttack,areaSweep);
        CaelumAirPayment.Spend(self,LastMeleeAirCost);
        UpdateAirStateEffects();

        double selectedBaseDamage = secondaryAttack
            ? CaelumWeaponCatalogue.GetSecondaryDamage(catalogueWeapon)
            : CaelumWeaponCatalogue.GetPrimaryDamage(catalogueWeapon);
        double physicalWeaponDamageScale = selectedBaseDamage
            * WeaponModel.GetTierDamageMultiplierFor(WeaponModel.Tier)
            / CaelumConstants.DEBUG_SWORD_BASE_DAMAGE;
        LastMeleeCalculatedDamage = CaelumWeaponUseRules.PhysicalDamage(selectedBaseDamage,
            WeaponModel.GetTierDamageMultiplierFor(WeaponModel.Tier),
            DerivedStats.PhysicalPushMultiplier*EffectiveOffensiveDamageMultiplier,chargedAttack);
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
            catalogueWeapon, WeaponModel.Tier, CurrentLucidity
        ) * 100.0 / LastMeleeAccuracyPercent;
        double minimumAimError = CaelumWeaponCatalogue.GetMinimumSpread(
            catalogueWeapon, WeaponModel.Tier, CurrentLucidity
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
        LastMeleeCriticalChancePercent = CaelumHuntersInstinct.Chance(self,targetData.linetarget,
            PhysicalCriticalChanceFor(catalogueWeapon));
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
        LastMeleeCalculatedDamage = CaelumWeaponUseRules.PhysicalDamage(selectedBaseDamage,
            WeaponModel.GetTierDamageMultiplierFor(WeaponModel.Tier),
            DerivedStats.PhysicalPushMultiplier*LastMeleeLocationMultiplier*EffectiveOffensiveDamageMultiplier,chargedAttack);
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
            LastMeleeCriticalChancePercent = CaelumHuntersInstinct.Chance(self,candidate,
                PhysicalCriticalChanceFor(catalogueWeapon));
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
        // Thrust directo no respeta por sí solo la inmovilidad frente a golpes.
        if (target == null || target.health <= 0 || target.bDONTTHRUST) { return; }
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
        LastArmorPreDefenseDamage = postAnatomyDamage;

        double defenseRatio = Clamp(GetArmorDefensePercent(slot) / 100.0, 0.0, 1.0);
        LastArmorAbsorbedDamage = LastArmorPreDefenseDamage * defenseRatio;
        LastArmorPostDefenseDamage = Max(
            0.0,
            LastArmorPreDefenseDamage - LastArmorAbsorbedDamage
        );
        double postToughnessDamage=CaelumToughnessRules.Apply(self,LastArmorPostDefenseDamage);
        LastToughnessDamageMultiplier=CaelumToughnessRules.RetainedFraction(LastArmorPostDefenseDamage,postToughnessDamage);
        int calculatedHealthDamage = Max(
            0,
            int(postToughnessDamage + 0.5)
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

    // Sueño bajo/crítico multiplica la pérdida de Lucidez y el aturdimiento
    // por 2/4. El complemento Tipo 1 de Paciencia mitiga sólo el exceso sobre x1.
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

    // Consumo pasivo según tiempo base, masa corporal y divisor Tipo 2.
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
    // Resiliencia Tipo 2 cura gastando hambre/sed según la vida restaurada.
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
        if(CreationWizardPage>=CaelumPersonalityRules.FIRST_PAGE && CreationWizardPage<=CaelumPersonalityRules.LAST_PAGE)
        {
            int layer=CreationWizardPage-CaelumPersonalityRules.FIRST_PAGE;
            CharacterProfile.Personality[layer]=(CharacterProfile.Personality[layer]+1)%3;
            CharacterProfile.PersonalityRevision=CaelumPersonalityRules.REVISION;
            ApplyCharacterProfile();return;
        }
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

        if (CreationWizardPage != CaelumConstants.CREATION_PAGE_SUMMARY)
        {
            CreationWizardPage=CreationWizardPage==CaelumConstants.CREATION_PAGE_ATTRIBUTES ? CaelumPersonalityRules.FIRST_PAGE
                : CreationWizardPage==CaelumPersonalityRules.LAST_PAGE ? CaelumConstants.CREATION_PAGE_SUMMARY : CreationWizardPage+1;
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
            CreationWizardPage=CreationWizardPage==CaelumConstants.CREATION_PAGE_SUMMARY ? CaelumPersonalityRules.LAST_PAGE
                : CreationWizardPage==CaelumPersonalityRules.FIRST_PAGE ? CaelumConstants.CREATION_PAGE_ATTRIBUTES : CreationWizardPage-1;
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
