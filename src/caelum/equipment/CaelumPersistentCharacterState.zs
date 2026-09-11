// Registro invisible que viaja en el inventario real de GZDoom.
// Conserva el perfil confirmado, los recursos y la propiedad del equipo entre
// mapas sin convertir los controles temporales en objetos visibles todavia.
class CaelumPersistentCharacterState : Inventory
{
    bool ProfileCommitted;
    // V4.32.0b convierte la Caja Magica en una recompensa persistente. Los
    // perfiles confirmados anteriores a esta version la conservan durante la
    // migracion; los personajes nuevos quedan marcados explicitamente sin ella.
    int MagicBoxOwnershipVersion;
    bool MagicBoxOwned;
    // El primer comercio es persistente por personaje. Así Palomo puede ser
    // recolocado por una etapa de misión sin restablecer stock ni dinero y el
    // servidor conserva una autoridad independiente para cada jugador.
    int PalomoMerchantVersion;
    int PalomoMerchantStock[5];
    int PalomoMerchantWalletCopper;
    // La negociación pertenece al personaje, igual que el stock y la caja.
    // Una mudanza o recreación futura del actor no altera el acuerdo logrado.
    int PalomoDiscountVersion;
    bool PalomoDiscountGranted;

    // Estado social V4.33. Los arreglos fijos mantienen índices estables en
    // guardados y viajes; sólo QUEST_DEFINED_COUNT posiciones tienen contenido
    // visible hoy. Cada objetivo conserva conocimiento, progreso y meta para
    // admitir contadores sin guardar texto narrativo dentro de la partida.
    int QuestStateVersion;
    int QuestState[CaelumConstants.QUEST_CAPACITY];
    int QuestStage[CaelumConstants.QUEST_CAPACITY];
    bool QuestObjectiveKnown[
        CaelumConstants.QUEST_OBJECTIVE_STORAGE_COUNT
    ];
    int QuestObjectiveProgress[
        CaelumConstants.QUEST_OBJECTIVE_STORAGE_COUNT
    ];
    int QuestObjectiveTarget[
        CaelumConstants.QUEST_OBJECTIVE_STORAGE_COUNT
    ];
    // La misión principal necesita hechos idempotentes además de su etapa. Esta
    // tabla incluye tanto progreso jugable como conocimiento de diálogo.
    bool MainM00Flag[CaelumConstants.MAIN_M00_FLAG_CAPACITY];
    // CheckOnceKey estables: Rulo=0 y Caella=2. Ronnie no lanza dados.
    // Estos datos viajan con el personaje y no se guardan en el actor del NPC.
    int MainM00SocialVersion;
    int MainM00RuneSequenceIndex;
    int MainM00RuneErrors;
    double MainM00AnimaAfterCast;
    // 0p: progreso y préstamo de munición viajan con el personaje.
    double MainM00PracticeLastAir;
    double MainM00PracticeLowestAir;
    Vector3 MainM00PracticeLastPosition;
    double MainM00PracticeSideDistance;
    int MainM00AmmoLoanType;
    int MainM00AmmoLoanRemaining;
    int MainM00BullFailures;
    bool MainM00BullResetPending;

    int MainM00PreviousWeaponId;
    int MainM00PreviousSealId;
    // La elección, el préstamo y el stock no viven en el NPC/cofre recreable.
    bool MainM00StarterChosen;
    int MainM00StarterOption;
    int MainM00StarterSize;
    int MainM00RonnieSwordId;
    int MainM00StarterWeaponId;
    bool MainM00SuppliesInitialized;
    int MainM00StarterRequired[CaelumConstants.MATERIAL_TYPE_COUNT];
    int MainM00SupplyInitial[6];
    int MainM00SupplyRemaining[6];
    bool MainM00ResidentMet[CaelumConstants.MAIN_M00_RESIDENT_COUNT];
    bool MainM00SocialAdvice[CaelumConstants.MAIN_M00_RESIDENT_COUNT];
    int MainM00SocialResult[CaelumConstants.MAIN_M00_RESIDENT_COUNT];
    int MainM00SocialRoll[CaelumConstants.MAIN_M00_RESIDENT_COUNT];
    int MainM00SocialChance[CaelumConstants.MAIN_M00_RESIDENT_COUNT];

    // Membresía y reputación pertenecen al personaje. Las relaciones entre
    // dominios son una tabla de reglas compartida, no estado duplicado por NPC.
    int FactionStateVersion;
    bool FactionMember[CaelumConstants.FACTION_COUNT];
    int FactionReputation[CaelumConstants.FACTION_COUNT];
    int Race;
    int FirstClass;
    int SecondClass;
    int Sex;
    int HeightChoice;
    int LayerBonus[4];
    int AttributeBonus[12];

    bool EquipmentInitialized;
    int ArmorType[4];
    int ArmorTier[4];
    int ArmorSize[4];
    int ArmorDurability[4];
    int ArmorSelectedSlot;
    int ShieldType;
    int ShieldTier;
    int ShieldSize;
    int ShieldDurability;
    bool ShieldEquipped;
    int WeaponType;
    int WeaponTier;
    int WeaponSize;
    int WeaponDurability;
    int WeaponEssenceType;
    bool WeaponEquipped;
    bool WeaponEquipmentInitialized;
    double EquippedWeaponBaseWeight;
    int EquippedWeaponTier;
    int EquippedWeaponSize;
    bool OwnedArmor[48];
    bool OwnedShield[12];
    int OwnedArmorDurability[48];
    int OwnedShieldDurability[12];
    bool OwnershipDurabilityInitialized;
    // Los registros antiguos se conservan para migrar partidas 4.5 al talle M.
    bool SizedOwnedArmor[300];
    bool SizedOwnedShield[60];
    bool SizedOwnedWeapon[300];
    int SizedOwnedArmorDurability[300];
    int SizedOwnedShieldDurability[60];
    int SizedOwnedWeaponDurability[300];
    int SizedWeaponEssenceType[300];
    bool EquipmentSizeInitialized;
    bool WeaponWeightInitialized;
    // false significa inventario personal o ranura equipada; true lo coloca en
    // la Caja Mágica, cuya contribución reducida se calcula de forma agregada.
    bool SizedArmorInMagicBox[300];
    bool SizedShieldInMagicBox[60];
    bool SizedWeaponInMagicBox[300];
    bool EquipmentStorageInitialized;
    // Equipado y activo son conceptos distintos. Varias armas pueden estar
    // preparadas simultaneamente, pero WeaponType/Tier/Size identifica solo
    // la que responde al boton de familia seleccionado en este momento.
    bool SizedWeaponEquipped[300];
    bool WeaponLoadoutInitialized;
    // Impide que los registros 4.7 vuelvan a crear objetos descartados una
    // vez que la propiedad ya fue transferida al inventario nativo.
    bool NativeEquipmentMigrationComplete;
    bool WeaponEssenceInitialized;

    // Identidad formal 4.29.0bc. Estos campos viajan junto con el registro y
    // evitan que dos piezas iguales compartan selección o durabilidad.
    int NextEquipmentItemId;
    int EquippedArmorItemId[4];
    int EquippedShieldItemId;
    int ActiveWeaponItemId;
    int EquippedAmuletItemId;
    int EquippedSealItemId;

    // El recetario pertenece al perfil y viaja con el mismo Inventory entre
    // mapas y guardados. La versión distingue el catálogo 4.29.0x del libro
    // vacío que usan los personajes creados desde 4.29.0y.
    int RecipeBookVersion;
    bool KnownCraftingRecipe[130];
    bool MainM00LeatherSuppliesPrepared;

    // Instantánea viajera de la única tarea 4.30. Los guardados normales ya
    // serializan al jugador; esta copia adicional conserva el estado durante
    // `changemap` y otros viajes que reconstruyen el pawn.
    bool CraftingTaskActive;
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
    int CraftingTaskReservedType[16];
    int CraftingTaskReservedTier[16];
    int CraftingTaskReservedUnits[16];
    int CraftingTaskOutputType[16];
    int CraftingTaskOutputTier[16];
    int CraftingTaskOutputUnits[16];

    int StoredHealth;
    double StoredAnima;
    double StoredAir;
    int StoredUnderwaterNoBreathTics;
    double StoredUnderwaterAirRecoveryDebt;
    int StoredUnderwaterAirRecoveryTicsRemaining;
    double StoredAdrenaline;
    double StoredLucidity;
    double StoredHunger;
    double StoredThirst;
    double StoredSleep;

    Default
    {
        Inventory.Amount 1;
        Inventory.MaxAmount 1;
        Inventory.InterHubAmount 1;
        +INVENTORY.UNDROPPABLE
        +INVENTORY.UNCLEARABLE
        +INVENTORY.KEEPDEPLETED
    }

    States
    {
    Spawn:
        TNT1 A -1;
        Stop;
    }

    void InitializeNewMagicBoxOwnership()
    {
        MagicBoxOwnershipVersion = 1;
        MagicBoxOwned = false;
    }

    void EnsureMagicBoxOwnershipInitialized()
    {
        if (MagicBoxOwnershipVersion >= 1) { return; }

        // Antes de 4.32.0b todo perfil confirmado poseia la caja de forma
        // implicita. Conservarla evita dejar inaccesible contenido ya guardado.
        MagicBoxOwned = ProfileCommitted;
        MagicBoxOwnershipVersion = 1;
    }

    bool GrantMagicBoxOwnership()
    {
        EnsureMagicBoxOwnershipInitialized();
        if (MagicBoxOwned) { return false; }
        MagicBoxOwned = true;
        return true;
    }

    void EnsurePalomoMerchantInitialized()
    {
        if (PalomoMerchantVersion >= 1) { return; }
        PalomoMerchantStock[CaelumConstants.PALOMO_MERCHANT_ITEM_FOOD] =
            CaelumConstants.PALOMO_MERCHANT_START_FOOD;
        PalomoMerchantStock[CaelumConstants.PALOMO_MERCHANT_ITEM_WATER] =
            CaelumConstants.PALOMO_MERCHANT_START_WATER;
        PalomoMerchantStock[CaelumConstants.PALOMO_MERCHANT_ITEM_WOOD] =
            CaelumConstants.PALOMO_MERCHANT_START_WOOD;
        PalomoMerchantStock[
            CaelumConstants.PALOMO_MERCHANT_ITEM_RAW_COPPER
        ] = CaelumConstants.PALOMO_MERCHANT_START_RAW_COPPER;
        PalomoMerchantStock[
            CaelumConstants.PALOMO_MERCHANT_ITEM_RAW_TIN
        ] = CaelumConstants.PALOMO_MERCHANT_START_RAW_TIN;
        PalomoMerchantWalletCopper =
            CaelumConstants.PALOMO_MERCHANT_START_COPPER;
        PalomoMerchantVersion = 1;
    }

    void InitializeNewPalomoDiscount()
    {
        PalomoDiscountVersion = 1;
        PalomoDiscountGranted = false;
    }

    void EnsurePalomoDiscountInitialized()
    {
        if (PalomoDiscountVersion >= 1) { return; }
        // Las partidas anteriores a 4.32.0d nunca pudieron negociar.
        PalomoDiscountGranted = false;
        PalomoDiscountVersion = 1;
    }

    bool IsValidQuestId(int questId)
    {
        return questId >= 0 && questId < CaelumConstants.QUEST_CAPACITY;
    }

    bool IsValidQuestObjectiveId(int objectiveId)
    {
        return objectiveId >= 0
            && objectiveId < CaelumConstants.QUEST_OBJECTIVE_CAPACITY;
    }

    int GetQuestObjectiveStorageIndex(int questId, int objectiveId)
    {
        if (!IsValidQuestId(questId)
            || !IsValidQuestObjectiveId(objectiveId))
        {
            return -1;
        }
        return questId * CaelumConstants.QUEST_OBJECTIVE_CAPACITY
            + objectiveId;
    }

    void ClearMainM00QuestRecord()
    {
        ResetMainM00SocialState();
        MainM00RuneSequenceIndex = 0;
        MainM00RuneErrors = 0;
        MainM00AnimaAfterCast = 0.0;
        MainM00PreviousWeaponId = 0;
        MainM00PreviousSealId = 0;
        MainM00StarterChosen = false;
        MainM00StarterOption = 0;
        MainM00StarterSize = 0;
        MainM00RonnieSwordId = 0;
        MainM00StarterWeaponId = 0;
        MainM00SuppliesInitialized = false;
        for (int i = 0; i < CaelumConstants.MATERIAL_TYPE_COUNT; i++) MainM00StarterRequired[i] = 0;
        for (int i = 0; i < 6; i++) { MainM00SupplyInitial[i] = 0; MainM00SupplyRemaining[i] = 0; }
        int questId = CaelumConstants.QUEST_MAIN_M00_THE_FOOL;
        QuestState[questId] = CaelumConstants.QUEST_STATE_UNDISCOVERED;
        QuestStage[questId] = CaelumConstants.MAIN_M00_STATE_INITIALIZE;
        for (int objectiveId = 0;
            objectiveId < CaelumConstants.QUEST_OBJECTIVE_CAPACITY;
            objectiveId++)
        {
            int objective = GetQuestObjectiveStorageIndex(
                questId, objectiveId
            );
            QuestObjectiveKnown[objective] = false;
            QuestObjectiveProgress[objective] = 0;
            QuestObjectiveTarget[objective] = 0;
        }
        for (int flagId = 0;
            flagId < CaelumConstants.MAIN_M00_FLAG_CAPACITY; flagId++)
        {
            MainM00Flag[flagId] = false;
        }
    }

    void InitializeNewQuestState()
    {
        ResetMainM00SocialState();
        MainM00RuneSequenceIndex = 0;
        MainM00RuneErrors = 0;
        MainM00AnimaAfterCast = 0.0;
        MainM00PreviousWeaponId = 0;
        MainM00PreviousSealId = 0;
        for (int questId = 0;
            questId < CaelumConstants.QUEST_CAPACITY; questId++)
        {
            QuestState[questId] = CaelumConstants.QUEST_STATE_UNDISCOVERED;
            QuestStage[questId] = 0;
        }
        for (int objective = 0;
            objective < CaelumConstants.QUEST_OBJECTIVE_STORAGE_COUNT;
            objective++)
        {
            QuestObjectiveKnown[objective] = false;
            QuestObjectiveProgress[objective] = 0;
            QuestObjectiveTarget[objective] = 0;
        }
        for (int flagId = 0;
            flagId < CaelumConstants.MAIN_M00_FLAG_CAPACITY; flagId++)
        {
            MainM00Flag[flagId] = false;
        }
        QuestStateVersion = 2;
    }

    void EnsureQuestStateInitialized()
    {
        if (QuestStateVersion >= 2) { return; }

        if (QuestStateVersion < 1)
        {
            InitializeNewQuestState();
            return;
        }

        // V4.33.0a registraba una aventura comercial de prueba en el mismo
        // índice. Esa historia dejó de ser canónica: la migración conserva la
        // Caja y todos sus contenidos, pero reinicia únicamente este registro
        // narrativo para que MAP01 comience por el despertar real.
        ClearMainM00QuestRecord();
        QuestStateVersion = 2;
    }

    bool IsValidMainM00FlagId(int flagId)
    {
        return flagId >= 0
            && flagId < CaelumConstants.MAIN_M00_FLAG_CAPACITY;
    }

    bool HasMainM00Flag(int flagId)
    {
        EnsureQuestStateInitialized();
        return IsValidMainM00FlagId(flagId) && MainM00Flag[flagId];
    }

    bool SetMainM00Flag(int flagId, bool value = true)
    {
        EnsureQuestStateInitialized();
        if (!IsValidMainM00FlagId(flagId)
            || MainM00Flag[flagId] == value)
        {
            return false;
        }
        MainM00Flag[flagId] = value;
        return true;
    }

    bool BeginMainM00Prologue()
    {
        EnsureQuestStateInitialized();
        int questId = CaelumConstants.QUEST_MAIN_M00_THE_FOOL;
        if (QuestState[questId] == CaelumConstants.QUEST_STATE_COMPLETED
            || QuestState[questId] == CaelumConstants.QUEST_STATE_FAILED)
        {
            return false;
        }

        bool changed = false;
        if (QuestState[questId] == CaelumConstants.QUEST_STATE_UNDISCOVERED)
        {
            QuestState[questId] = CaelumConstants.QUEST_STATE_ACTIVE;
            changed = true;
        }
        if (QuestStage[questId]
            == CaelumConstants.MAIN_M00_STATE_INITIALIZE)
        {
            QuestStage[questId] = CaelumConstants.MAIN_M00_STATE_AWAKENED;
            changed = true;
        }
        if (!MainM00Flag[CaelumConstants.MAIN_M00_FLAG_STARTED])
        {
            MainM00Flag[CaelumConstants.MAIN_M00_FLAG_STARTED] = true;
            changed = true;
        }

        int objective = GetQuestObjectiveStorageIndex(
            questId,
            CaelumConstants.MAIN_M00_OBJECTIVE_FIND_HELP
        );
        if (!QuestObjectiveKnown[objective])
        {
            QuestObjectiveKnown[objective] = true;
            QuestObjectiveProgress[objective] = 0;
            QuestObjectiveTarget[objective] = 1;
            changed = true;
        }
        else
        {
            int normalizedProgress = Clamp(
                QuestObjectiveProgress[objective], 0, 1
            );
            if (QuestObjectiveProgress[objective] != normalizedProgress
                || QuestObjectiveTarget[objective] != 1)
            {
                QuestObjectiveProgress[objective] = normalizedProgress;
                QuestObjectiveTarget[objective] = 1;
                changed = true;
            }
        }
        return changed;
    }

    bool TryAdvanceMainM00State(int expectedState, int nextState)
    {
        EnsureQuestStateInitialized();
        int questId = CaelumConstants.QUEST_MAIN_M00_THE_FOOL;
        if (QuestState[questId] != CaelumConstants.QUEST_STATE_ACTIVE
            || QuestStage[questId] != expectedState
            || nextState <= expectedState)
        {
            return false;
        }
        QuestStage[questId] = nextState;
        return true;
    }

    bool RecordMainM00UnknownVoiceHeard()
    {
        EnsureQuestStateInitialized();
        if (MainM00Flag[
                CaelumConstants.MAIN_M00_FLAG_UNKNOWN_VOICE_HEARD
            ])
        {
            return false;
        }
        if (!TryAdvanceMainM00State(
                CaelumConstants.MAIN_M00_STATE_AWAKENED,
                CaelumConstants.MAIN_M00_STATE_MET_PALOMO
            ))
        {
            return false;
        }
        MainM00Flag[
            CaelumConstants.MAIN_M00_FLAG_UNKNOWN_VOICE_HEARD
        ] = true;
        return true;
    }

    bool RecordMainM00PalomoDialogueFlag(int flagId)
    {
        EnsureQuestStateInitialized();
        int questId = CaelumConstants.QUEST_MAIN_M00_THE_FOOL;
        bool supportedFlag = flagId
                == CaelumConstants.MAIN_M00_FLAG_ASKED_PALOMO_WHERE
            || flagId
                == CaelumConstants.MAIN_M00_FLAG_ASKED_PALOMO_WHAT_HAPPENED
            || flagId
                == CaelumConstants.MAIN_M00_FLAG_TOLD_PALOMO_ABOUT_VOICE
            || flagId
                == CaelumConstants.MAIN_M00_FLAG_NOTICED_MEMORY_GAP;
        if (!supportedFlag
            || QuestState[questId] != CaelumConstants.QUEST_STATE_ACTIVE
            || QuestStage[questId] < CaelumConstants.MAIN_M00_STATE_MET_PALOMO
            || QuestStage[questId]
                >= CaelumConstants.MAIN_M00_STATE_ARGENTO_ACTIVE)
        {
            return false;
        }

        bool changed = SetMainM00Flag(flagId);
        if (flagId
            == CaelumConstants.MAIN_M00_FLAG_TOLD_PALOMO_ABOUT_VOICE)
        {
            changed = SetMainM00Flag(
                CaelumConstants.MAIN_M00_FLAG_PALOMO_CALLED_IT_HALLUCINATION
            ) || changed;
        }
        return changed;
    }

    bool RecordMainM00PalomoMet()
    {
        EnsureQuestStateInitialized();
        if (MainM00Flag[CaelumConstants.MAIN_M00_FLAG_PALOMO_MET]
            || !MainM00Flag[
                CaelumConstants.MAIN_M00_FLAG_UNKNOWN_VOICE_HEARD
            ])
        {
            return false;
        }
        if (!TryAdvanceMainM00State(
                CaelumConstants.MAIN_M00_STATE_MET_PALOMO,
                CaelumConstants.MAIN_M00_STATE_ARGENTO_ACTIVE
            ))
        {
            return false;
        }

        MainM00Flag[CaelumConstants.MAIN_M00_FLAG_PALOMO_MET] = true;
        int objective = GetQuestObjectiveStorageIndex(
            CaelumConstants.QUEST_MAIN_M00_THE_FOOL,
            CaelumConstants.MAIN_M00_OBJECTIVE_FIND_HELP
        );
        QuestObjectiveKnown[objective] = true;
        QuestObjectiveProgress[objective] = 1;
        QuestObjectiveTarget[objective] = 1;
        return true;
    }

    void ResetMainM00SocialState()
    {
        for (int i = 0; i < CaelumConstants.MAIN_M00_RESIDENT_COUNT; i++)
        {
            MainM00ResidentMet[i] = false;
            MainM00SocialAdvice[i] = false;
            MainM00SocialResult[i] = CaelumConstants.MAIN_M00_SOCIAL_UNTRIED;
            MainM00SocialRoll[i] = 0;
            MainM00SocialChance[i] = 0;
        }
        MainM00SocialVersion = 1;
    }

    void EnsureMainM00SocialState()
    {
        EnsureQuestStateInitialized();
        // Una partida 0e conserva íntegros prólogo, inventario y geometría.
        if (MainM00SocialVersion < 1) { ResetMainM00SocialState(); }
    }

    bool IsMainM00RecruitmentActive()
    {
        EnsureMainM00SocialState();
        return QuestState[CaelumConstants.QUEST_MAIN_M00_THE_FOOL]
                == CaelumConstants.QUEST_STATE_ACTIVE
            && QuestStage[CaelumConstants.QUEST_MAIN_M00_THE_FOOL]
                == CaelumConstants.MAIN_M00_STATE_ARGENTO_ACTIVE
            && MainM00Flag[CaelumConstants.MAIN_M00_FLAG_ARGENTO_STARTED];
    }

    bool IsValidMainM00Resident(int resident)
    {
        return resident >= 0 && resident < CaelumConstants.MAIN_M00_RESIDENT_COUNT;
    }

    bool IsMainM00ResidentConvinced(int resident)
    {
        return IsValidMainM00Resident(resident)
            && HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_RULO_CONVINCED + resident);
    }

    int CountMainM00ConvincedResidents()
    {
        int count = 0;
        for (int i = 0; i < CaelumConstants.MAIN_M00_RESIDENT_COUNT; i++)
        {
            if (IsMainM00ResidentConvinced(i)) { count++; }
        }
        return count;
    }

    void RefreshMainM00RecruitmentObjective()
    {
        if (!HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_ARGENTO_STARTED)) { return; }
        int objective = GetQuestObjectiveStorageIndex(
            CaelumConstants.QUEST_MAIN_M00_THE_FOOL,
            CaelumConstants.MAIN_M00_OBJECTIVE_CONVINCE_RESIDENTS);
        QuestObjectiveKnown[objective] = true;
        QuestObjectiveProgress[objective] = CountMainM00ConvincedResidents();
        QuestObjectiveTarget[objective] = CaelumConstants.MAIN_M00_RESIDENT_COUNT;
    }

    bool BeginMainM00Argento()
    {
        EnsureMainM00SocialState();
        if (QuestState[CaelumConstants.QUEST_MAIN_M00_THE_FOOL]
                != CaelumConstants.QUEST_STATE_ACTIVE
            || QuestStage[CaelumConstants.QUEST_MAIN_M00_THE_FOOL]
                != CaelumConstants.MAIN_M00_STATE_ARGENTO_ACTIVE
            || !MainM00Flag[CaelumConstants.MAIN_M00_FLAG_PALOMO_MET]
            || MainM00Flag[CaelumConstants.MAIN_M00_FLAG_ARGENTO_STARTED]) { return false; }
        MainM00Flag[CaelumConstants.MAIN_M00_FLAG_ARGENTO_STARTED] = true;
        MainM00Flag[CaelumConstants.MAIN_M00_FLAG_HEARD_ARGENTO_QUOTE] = true;
        RefreshMainM00RecruitmentObjective();
        return true;
    }

    bool RecordMainM00ResidentMet(int resident)
    {
        if (!IsMainM00RecruitmentActive() || !IsValidMainM00Resident(resident)
            || MainM00ResidentMet[resident]) { return false; }
        MainM00ResidentMet[resident] = true;
        return true;
    }

    bool CanReceiveMainM00Advice(int resident)
    {
        if (!IsMainM00RecruitmentActive() || !IsValidMainM00Resident(resident)
            || !MainM00ResidentMet[resident] || IsMainM00ResidentConvinced(resident)
            || MainM00SocialAdvice[resident]) { return false; }
        return resident == CaelumConstants.MAIN_M00_RESIDENT_RONNIE
            || MainM00SocialResult[resident] == CaelumConstants.MAIN_M00_SOCIAL_FAILURE;
    }

    bool RecordMainM00Advice(int resident)
    {
        if (!CanReceiveMainM00Advice(resident)) { return false; }
        MainM00SocialAdvice[resident] = true;
        return true;
    }

    bool CanAttemptMainM00SocialCheck(int resident)
    {
        return IsMainM00RecruitmentActive() && IsValidMainM00Resident(resident)
            && resident != CaelumConstants.MAIN_M00_RESIDENT_RONNIE
            && MainM00ResidentMet[resident] && !IsMainM00ResidentConvinced(resident)
            && MainM00SocialResult[resident] == CaelumConstants.MAIN_M00_SOCIAL_UNTRIED;
    }

    bool RecordMainM00SocialCheck(int resident, int roll, int chance)
    {
        if (!CanAttemptMainM00SocialCheck(resident)) { return false; }
        MainM00SocialRoll[resident] = Clamp(roll, 0, 101);
        MainM00SocialChance[resident] = Clamp(chance, 0, 100);
        MainM00SocialResult[resident] = MainM00SocialRoll[resident]
            <= MainM00SocialChance[resident]
            ? CaelumConstants.MAIN_M00_SOCIAL_SUCCESS
            : CaelumConstants.MAIN_M00_SOCIAL_FAILURE;
        return true;
    }

    bool ConvinceMainM00Resident(int resident)
    {
        if (!IsMainM00RecruitmentActive() || !IsValidMainM00Resident(resident)
            || IsMainM00ResidentConvinced(resident)) { return false; }
        MainM00Flag[CaelumConstants.MAIN_M00_FLAG_RULO_CONVINCED + resident] = true;
        RefreshMainM00RecruitmentObjective();
        return true;
    }

    bool CompleteMainM00Argento()
    {
        if (!IsMainM00RecruitmentActive()
            || CountMainM00ConvincedResidents() != CaelumConstants.MAIN_M00_RESIDENT_COUNT
            || !TryAdvanceMainM00State(CaelumConstants.MAIN_M00_STATE_ARGENTO_ACTIVE,
                CaelumConstants.MAIN_M00_STATE_ARGENTO_COMPLETE)) { return false; }
        MainM00Flag[CaelumConstants.MAIN_M00_FLAG_ARGENTO_COMPLETE] = true;
        RefreshMainM00RecruitmentObjective();
        return true;
    }

    bool IsMainM00MagicActive()
    {
        EnsureQuestStateInitialized();
        return QuestState[CaelumConstants.QUEST_MAIN_M00_THE_FOOL] == CaelumConstants.QUEST_STATE_ACTIVE
            && QuestStage[CaelumConstants.QUEST_MAIN_M00_THE_FOOL] == CaelumConstants.MAIN_M00_STATE_CAELLA_ACTIVE
            && MainM00Flag[CaelumConstants.MAIN_M00_FLAG_CAELLA_STARTED];
    }

    bool BeginMainM00Caella()
    {
        if (!HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_ARGENTO_COMPLETE)
            || !TryAdvanceMainM00State(CaelumConstants.MAIN_M00_STATE_ARGENTO_COMPLETE,
                CaelumConstants.MAIN_M00_STATE_CAELLA_ACTIVE)) return false;
        SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_CAELLA_STARTED);
        SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_HEARD_CAELLA_QUOTE);
        RefreshMainM00MagicObjective();
        return true;
    }

    int CountMainM00MagicPractice()
    {
        int count = 0;
        for (int flag = CaelumConstants.MAIN_M00_FLAG_MAGIC_PRIMARY_USED;
            flag <= CaelumConstants.MAIN_M00_FLAG_MAGIC_CHANNEL_USED; flag++)
            if (HasMainM00Flag(flag)) count++;
        if (HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_MAGIC_ANIMA_SPENT)) count++;
        if (HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_MAGIC_ANIMA_RECOVERED)) count++;
        return count;
    }

    bool IsMainM00MagicPracticeComplete() { return CountMainM00MagicPractice() == 5; }

    void RefreshMainM00MagicObjective()
    {
        if (!HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_CAELLA_STARTED)) return;
        int index = GetQuestObjectiveStorageIndex(CaelumConstants.QUEST_MAIN_M00_THE_FOOL,
            CaelumConstants.MAIN_M00_OBJECTIVE_SOLVE_RIDDLE);
        QuestObjectiveKnown[index] = true;
        QuestObjectiveTarget[index] = 9;
        QuestObjectiveProgress[index] = CountMainM00MagicPractice() + MainM00RuneSequenceIndex;
    }

    static int GetMainM00RuneElement(int index)
    {
        if (index == 0) return CaelumConstants.ESSENCE_EARTH;
        if (index == 1) return CaelumConstants.ESSENCE_WIND;
        if (index == 2) return CaelumConstants.ESSENCE_FIRE;
        if (index == 3) return CaelumConstants.ESSENCE_WATER;
        return -1;
    }

    // -1: error; 0: intento inválido; 1: avance; 2: volver con Caella.
    int ActivateMainM00Rune(int element)
    {
        if (!IsMainM00MagicActive() || !IsMainM00MagicPracticeComplete()
            || MainM00RuneSequenceIndex < 0 || MainM00RuneSequenceIndex >= 4) return 0;
        if (element != GetMainM00RuneElement(MainM00RuneSequenceIndex))
        {
            MainM00RuneErrors = Min(MainM00RuneErrors + 1, 1000000);
            MainM00RuneSequenceIndex = 0;
            for (int i = 0; i < 4; i++) MainM00Flag[CaelumConstants.MAIN_M00_FLAG_RUNE_EARTH + i] = false;
            RefreshMainM00MagicObjective();
            return -1;
        }
        MainM00Flag[CaelumConstants.MAIN_M00_FLAG_RUNE_EARTH + MainM00RuneSequenceIndex] = true;
        MainM00RuneSequenceIndex++;
        RefreshMainM00MagicObjective();
        if (MainM00RuneSequenceIndex < 4) return 1;
        return 2;
    }

    bool CompleteMainM00Caella()
    {
        if (!IsMainM00MagicActive() || !IsMainM00MagicPracticeComplete()
            || MainM00RuneSequenceIndex != 4) return false;
        if (!TryAdvanceMainM00State(CaelumConstants.MAIN_M00_STATE_CAELLA_ACTIVE,
            CaelumConstants.MAIN_M00_STATE_CAELLA_COMPLETE)) return false;
        SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_SECRET_PASSAGE_OPEN);
        SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_CAELLA_COMPLETE);
        return true;
    }

    bool SetQuestStage(int questId, int stage)
    {
        EnsureQuestStateInitialized();
        if (!IsValidQuestId(questId) || stage < 0) { return false; }
        if (QuestState[questId] == CaelumConstants.QUEST_STATE_UNDISCOVERED)
        {
            QuestState[questId] = CaelumConstants.QUEST_STATE_ACTIVE;
        }
        if (QuestState[questId] != CaelumConstants.QUEST_STATE_ACTIVE
            || stage <= QuestStage[questId])
        {
            return false;
        }
        QuestStage[questId] = stage;
        return true;
    }

    bool SetQuestObjectiveProgress(
        int questId, int objectiveId, int progress, int target
    )
    {
        EnsureQuestStateInitialized();
        int objective = GetQuestObjectiveStorageIndex(
            questId, objectiveId
        );
        if (objective < 0 || target <= 0) { return false; }
        if (QuestState[questId] == CaelumConstants.QUEST_STATE_UNDISCOVERED)
        {
            QuestState[questId] = CaelumConstants.QUEST_STATE_ACTIVE;
        }
        int normalizedProgress = Clamp(progress, 0, target);
        bool changed = !QuestObjectiveKnown[objective]
            || QuestObjectiveProgress[objective] != normalizedProgress
            || QuestObjectiveTarget[objective] != target;
        QuestObjectiveKnown[objective] = true;
        QuestObjectiveProgress[objective] = normalizedProgress;
        QuestObjectiveTarget[objective] = target;
        return changed;
    }

    bool SetQuestTerminalState(int questId, int terminalState)
    {
        EnsureQuestStateInitialized();
        if (!IsValidQuestId(questId)
            || (terminalState != CaelumConstants.QUEST_STATE_COMPLETED
                && terminalState != CaelumConstants.QUEST_STATE_FAILED)
            || QuestState[questId] == CaelumConstants.QUEST_STATE_UNDISCOVERED)
        {
            return false;
        }
        if (QuestState[questId] == terminalState) { return false; }
        QuestState[questId] = terminalState;
        return true;
    }

    // Única fuente de ubicación narrativa. Antes de la Voz, Palomo permanece
    // oculto; ocupa el recibidor durante la fase 20 y vuelve a quedar fuera de
    // vista después de orientar hacia Argento. La fase final ya puede resolver
    // el segundo piso, aunque su traslado físico llegará en otro parche.
    int ResolvePalomoPlacement()
    {
        EnsureQuestStateInitialized();
        int questId = CaelumConstants.QUEST_MAIN_M00_THE_FOOL;
        if (QuestState[questId] == CaelumConstants.QUEST_STATE_UNDISCOVERED
            || QuestStage[questId]
                < CaelumConstants.MAIN_M00_STATE_MET_PALOMO)
        {
            return CaelumConstants.PALOMO_PLACEMENT_HIDDEN;
        }
        if (QuestStage[questId]
            >= CaelumConstants.MAIN_M00_STATE_BOX_RECEIVED)
        {
            return CaelumConstants.PALOMO_PLACEMENT_MANSION_UPSTAIRS;
        }
        if (QuestStage[questId]
            >= CaelumConstants.MAIN_M00_STATE_ARGENTO_ACTIVE)
        {
            return CaelumConstants.PALOMO_PLACEMENT_HIDDEN;
        }
        return CaelumConstants.PALOMO_PLACEMENT_MANSION_FOYER;
    }

    bool IsValidFactionId(int factionId)
    {
        return CaelumFactionRules.IsValidFactionId(factionId);
    }

    void InitializeNewFactionState()
    {
        for (int factionId = 0;
            factionId < CaelumConstants.FACTION_COUNT; factionId++)
        {
            FactionMember[factionId] = false;
            FactionReputation[factionId] = 0;
        }
        FactionStateVersion = 1;
    }

    void EnsureFactionStateInitialized()
    {
        if (FactionStateVersion >= 1) { return; }
        InitializeNewFactionState();
    }

    bool SetFactionMembership(int factionId, bool isMember)
    {
        EnsureFactionStateInitialized();
        if (!IsValidFactionId(factionId)
            || FactionMember[factionId] == isMember)
        {
            return false;
        }
        FactionMember[factionId] = isMember;
        return true;
    }

    bool ChangeFactionReputation(int factionId, int amount)
    {
        EnsureFactionStateInitialized();
        if (!IsValidFactionId(factionId) || amount == 0) { return false; }
        int previous = FactionReputation[factionId];
        int next = previous;
        if (amount > 0)
        {
            int room = CaelumConstants.FACTION_REPUTATION_MAXIMUM - previous;
            next = amount >= room
                ? CaelumConstants.FACTION_REPUTATION_MAXIMUM
                : previous + amount;
        }
        else
        {
            int room = CaelumConstants.FACTION_REPUTATION_MINIMUM - previous;
            next = amount <= room
                ? CaelumConstants.FACTION_REPUTATION_MINIMUM
                : previous + amount;
        }
        FactionReputation[factionId] = next;
        return FactionReputation[factionId] != previous;
    }

    // Consulta O(1): una facción siempre se reconoce como propia y las
    // relaciones cruzadas quedan neutrales hasta que el autor defina la tabla.
    int GetFactionRelation(int sourceFactionId, int targetFactionId)
    {
        return CaelumFactionRules.GetRelation(
            sourceFactionId, targetFactionId
        );
    }

    void ObserveEquipmentItemId(int itemId)
    {
        if (itemId > NextEquipmentItemId)
        {
            NextEquipmentItemId = itemId;
        }
    }

    int AllocateEquipmentItemId()
    {
        NextEquipmentItemId++;
        if (NextEquipmentItemId <= 0) { NextEquipmentItemId = 1; }
        return NextEquipmentItemId;
    }

    int GetArmorOwnershipIndex(int slot, int armorType, int tier)
    {
        return Clamp(slot, 0, 3) * 12
            + Clamp(armorType, 0, 3) * 3
            + Clamp(tier, 1, 3) - 1;
    }

    int GetShieldOwnershipIndex(int shieldType, int tier)
    {
        return Clamp(shieldType, 0, 3) * 3 + Clamp(tier, 1, 3) - 1;
    }

    int GetSizedArmorOwnershipIndex(int slot, int armorType, int tier, int equipmentSize)
    {
        return (((Clamp(slot, 0, 3) * CaelumConstants.ARMOR_TYPE_COUNT
            + Clamp(armorType, 0, CaelumConstants.ARMOR_TYPE_COUNT - 1)) * 3
            + Clamp(tier, 1, 3) - 1) * CaelumConstants.EQUIPMENT_SIZE_COUNT)
            + Clamp(equipmentSize, 0, CaelumConstants.EQUIPMENT_SIZE_COUNT - 1);
    }

    int GetSizedShieldOwnershipIndex(int shieldType, int tier, int equipmentSize)
    {
        return ((Clamp(shieldType, 0, 3) * 3 + Clamp(tier, 1, 3) - 1)
            * CaelumConstants.EQUIPMENT_SIZE_COUNT)
            + Clamp(equipmentSize, 0, CaelumConstants.EQUIPMENT_SIZE_COUNT - 1);
    }

    int GetSizedWeaponOwnershipIndex(int weaponType, int tier, int equipmentSize)
    {
        return ((Clamp(weaponType, 0, CaelumConstants.WEAPON_TYPE_COUNT - 1) * 3
            + Clamp(tier, 1, 3) - 1) * CaelumConstants.EQUIPMENT_SIZE_COUNT)
            + Clamp(equipmentSize, 0, CaelumConstants.EQUIPMENT_SIZE_COUNT - 1);
    }

    // Migra registros creados antes de que cada objeto guardara su propia
    // durabilidad. Solo se ejecuta una vez; después, cero vuelve a significar
    // correctamente que ese objeto está roto.
    void EnsureOwnershipDurabilityInitialized()
    {
        if (OwnershipDurabilityInitialized) { return; }
        // Los registros 4.3 siempre representaban un escudo equipado.
        ShieldEquipped = true;
        for (int index = 0; index < 48; index++)
        {
            if (!OwnedArmor[index]) { continue; }
            int armorType = (index % 12) / 3;
            int tier = index % 3 + 1;
            int baseDurability = 20;
            if (armorType == CaelumConstants.ARMOR_TYPE_LIGHT) { baseDurability = 40; }
            else if (armorType == CaelumConstants.ARMOR_TYPE_MEDIUM) { baseDurability = 60; }
            else if (armorType == CaelumConstants.ARMOR_TYPE_HEAVY) { baseDurability = 100; }
            int multiplier = tier == 1 ? 1 : (tier == 2 ? 3 : 9);
            OwnedArmorDurability[index] = baseDurability * multiplier;
        }
        for (int shieldIndex = 0; shieldIndex < 12; shieldIndex++)
        {
            if (!OwnedShield[shieldIndex]) { continue; }
            int shieldType = shieldIndex / 3;
            int tier = shieldIndex % 3 + 1;
            int baseDurability = 100;
            if (shieldType == CaelumConstants.SHIELD_TYPE_BUCKLER) { baseDurability = 80; }
            else if (shieldType == CaelumConstants.SHIELD_TYPE_KITE) { baseDurability = 150; }
            else if (shieldType == CaelumConstants.SHIELD_TYPE_TOWER) { baseDurability = 250; }
            int multiplier = tier == 1 ? 1 : (tier == 2 ? 3 : 9);
            OwnedShieldDurability[shieldIndex] = baseDurability * multiplier;
        }
        OwnershipDurabilityInitialized = true;
    }

    // Las partidas anteriores no guardaban talle. Todo su equipo pasa a M,
    // que conserva exactamente el peso y la durabilidad documentados entonces.
    void EnsureEquipmentSizeInitialized()
    {
        EnsureOwnershipDurabilityInitialized();
        if (!EquipmentSizeInitialized)
        {
            for (int slot = 0; slot < 4; slot++)
            {
                ArmorSize[slot] = CaelumConstants.EQUIPMENT_SIZE_M;
            }
            ShieldSize = CaelumConstants.EQUIPMENT_SIZE_M;
            for (int oldArmorIndex = 0; oldArmorIndex < 48; oldArmorIndex++)
            {
                if (!OwnedArmor[oldArmorIndex]) { continue; }
                int slot = oldArmorIndex / 12;
                int armorType = (oldArmorIndex % 12) / 3;
                int tier = oldArmorIndex % 3 + 1;
                int newIndex = GetSizedArmorOwnershipIndex(
                    slot, armorType, tier, CaelumConstants.EQUIPMENT_SIZE_M
                );
                SizedOwnedArmor[newIndex] = true;
                SizedOwnedArmorDurability[newIndex] = OwnedArmorDurability[oldArmorIndex];
            }
            for (int oldShieldIndex = 0; oldShieldIndex < 12; oldShieldIndex++)
            {
                if (!OwnedShield[oldShieldIndex]) { continue; }
                int shieldType = oldShieldIndex / 3;
                int tier = oldShieldIndex % 3 + 1;
                int newIndex = GetSizedShieldOwnershipIndex(
                    shieldType, tier, CaelumConstants.EQUIPMENT_SIZE_M
                );
                SizedOwnedShield[newIndex] = true;
                SizedOwnedShieldDurability[newIndex] = OwnedShieldDurability[oldShieldIndex];
            }
            EquipmentSizeInitialized = true;
        }
        EnsureWeaponEquipmentInitialized();
        EnsureEquipmentStorageInitialized();
        EnsureWeaponLoadoutInitialized();
        EnsureWeaponEssenceInitialized();
    }

    void EnsureRecipeBookInitialized()
    {
        if (RecipeBookVersion >= CaelumConstants.CRAFTING_RECIPE_BOOK_VERSION)
        {
            return;
        }

        if (RecipeBookVersion <= 0 && ProfileCommitted)
        {
            // Un perfil anterior a 4.29.0x ya jugable conserva las 61 recetas
            // que entonces estaban abiertas. Los cuatro escudos son nuevos.
            for (int recipeIndex = 0;
                recipeIndex < CaelumConstants.CRAFTING_NETWORK_LEGACY_RECIPE_COUNT;
                recipeIndex++)
            {
                KnownCraftingRecipe[recipeIndex] = true;
            }
        }
        else if (RecipeBookVersion <= 0)
        {
            // Un estado recién creado aún no confirmado comienza sin recetas.
            for (int recipeIndex = 0;
                recipeIndex < CaelumConstants.CRAFTING_NETWORK_PLAYABLE_RECIPE_COUNT;
                recipeIndex++)
            {
                KnownCraftingRecipe[recipeIndex] = false;
            }
        }

        // La versión 2 ya contenía los cuatro escudos de 4.29.0y. Las catorce
        // recetas de procesamiento (v3) y las cincuenta de componentes (v4)
        // se anexan bloqueadas; se aprenderán con sus Arcanos Menores.
        int addedRecipeStart;
        if (RecipeBookVersion >= 3)
        {
            addedRecipeStart = CaelumConstants.CRAFTING_NETWORK_LEGACY_RECIPE_COUNT
                + CaelumConstants.CRAFTING_NETWORK_SHIELD_RECIPE_COUNT
                + CaelumConstants.CRAFTING_NETWORK_PROCESSING_RECIPE_COUNT;
        }
        else if (RecipeBookVersion >= 2)
        {
            addedRecipeStart = CaelumConstants.CRAFTING_NETWORK_LEGACY_RECIPE_COUNT
                + CaelumConstants.CRAFTING_NETWORK_SHIELD_RECIPE_COUNT;
        }
        else
        {
            addedRecipeStart = CaelumConstants.CRAFTING_NETWORK_LEGACY_RECIPE_COUNT;
        }
        for (int recipeIndex = addedRecipeStart;
            recipeIndex < CaelumConstants.CRAFTING_NETWORK_PLAYABLE_RECIPE_COUNT;
            recipeIndex++)
        {
            KnownCraftingRecipe[recipeIndex] = false;
        }
        RecipeBookVersion = CaelumConstants.CRAFTING_RECIPE_BOOK_VERSION;
    }

    bool KnowsCraftingRecipe(int recipeIndex)
    {
        EnsureRecipeBookInitialized();
        if (recipeIndex < 0
            || recipeIndex >= CaelumConstants.CRAFTING_NETWORK_PLAYABLE_RECIPE_COUNT)
        {
            return false;
        }
        return KnownCraftingRecipe[recipeIndex];
    }

    bool LearnCraftingRecipe(int recipeIndex)
    {
        EnsureRecipeBookInitialized();
        if (recipeIndex < 0
            || recipeIndex >= CaelumConstants.CRAFTING_NETWORK_PLAYABLE_RECIPE_COUNT
            || KnownCraftingRecipe[recipeIndex])
        {
            return false;
        }
        KnownCraftingRecipe[recipeIndex] = true;
        return true;
    }

    void SetAllCraftingRecipesKnown(bool known)
    {
        EnsureRecipeBookInitialized();
        for (int recipeIndex = 0;
            recipeIndex < CaelumConstants.CRAFTING_NETWORK_PLAYABLE_RECIPE_COUNT;
            recipeIndex++)
        {
            KnownCraftingRecipe[recipeIndex] = known;
        }
    }

    int CountKnownCraftingRecipes()
    {
        EnsureRecipeBookInitialized();
        int knownCount = 0;
        for (int recipeIndex = 0;
            recipeIndex < CaelumConstants.CRAFTING_NETWORK_PLAYABLE_RECIPE_COUNT;
            recipeIndex++)
        {
            if (KnownCraftingRecipe[recipeIndex]) { knownCount++; }
        }
        return knownCount;
    }

    // Las partidas 4.7.2 trataban todo objeto desequipado como contenido de la
    // Caja Magica. La migracion conserva esa ubicacion y deja fuera solamente
    // las piezas que estaban realmente equipadas.
    void EnsureEquipmentStorageInitialized()
    {
        if (EquipmentStorageInitialized) { return; }
        for (int armorIndex = 0; armorIndex < 300; armorIndex++)
        {
            SizedArmorInMagicBox[armorIndex] = SizedOwnedArmor[armorIndex];
        }
        for (int shieldIndex = 0; shieldIndex < 60; shieldIndex++)
        {
            SizedShieldInMagicBox[shieldIndex] = SizedOwnedShield[shieldIndex];
        }
        for (int weaponIndex = 0;
            weaponIndex < CaelumConstants.WEAPON_OWNERSHIP_COUNT;
            weaponIndex++)
        {
            SizedWeaponInMagicBox[weaponIndex] = SizedOwnedWeapon[weaponIndex];
        }
        if (EquipmentInitialized)
        {
            for (int slot = 0; slot < CaelumConstants.ARMOR_SLOT_COUNT; slot++)
            {
                if (ArmorType[slot] == CaelumConstants.ARMOR_TYPE_BASE_CLOTHING)
                {
                    continue;
                }
                SizedArmorInMagicBox[GetSizedArmorOwnershipIndex(
                    slot, ArmorType[slot], ArmorTier[slot], ArmorSize[slot]
                )] = false;
            }
            if (ShieldEquipped)
            {
                SizedShieldInMagicBox[GetSizedShieldOwnershipIndex(
                    ShieldType, ShieldTier, ShieldSize
                )] = false;
            }
            if (WeaponEquipped)
            {
                SizedWeaponInMagicBox[GetSizedWeaponOwnershipIndex(
                    WeaponType, WeaponTier, WeaponSize
                )] = false;
            }
        }
        EquipmentStorageInitialized = true;
    }

    // Migra las partidas con una sola arma: la antigua arma activa pasa a ser
    // la primera entrada equipada sin modificar las demás propiedades.
    void EnsureWeaponLoadoutInitialized()
    {
        if (WeaponLoadoutInitialized) { return; }
        if (WeaponEquipped)
        {
            SizedWeaponEquipped[GetSizedWeaponOwnershipIndex(
                WeaponType, WeaponTier, WeaponSize
            )] = true;
        }
        WeaponLoadoutInitialized = true;
    }

    void EnsureWeaponEssenceInitialized()
    {
        if (WeaponEssenceInitialized) { return; }
        WeaponEssenceType = CaelumConstants.ESSENCE_FIRE;
        for (int index = 0;
            index < CaelumConstants.WEAPON_OWNERSHIP_COUNT; index++)
        {
            SizedWeaponEssenceType[index] = CaelumConstants.ESSENCE_FIRE;
        }
        WeaponEssenceInitialized = true;
    }

    // Migra el peso provisional de versiones anteriores a un arma real. La
    // espada era el valor normal; 4 identifica baston y 12 identifica carabina.
    void EnsureWeaponEquipmentInitialized()
    {
        if (WeaponEquipmentInitialized) { return; }
        bool migrateExistingWeapon = EquipmentInitialized
            || WeaponWeightInitialized || ProfileCommitted;
        WeaponType = CaelumConstants.WEAPON_TYPE_SWORD;
        WeaponTier = WeaponWeightInitialized ? Clamp(EquippedWeaponTier, 1, 3) : 1;
        WeaponSize = WeaponWeightInitialized
            ? Clamp(EquippedWeaponSize, 0, CaelumConstants.EQUIPMENT_SIZE_COUNT - 1)
            : CaelumConstants.EQUIPMENT_SIZE_M;
        if (WeaponWeightInitialized && EquippedWeaponBaseWeight >= 10.0)
        {
            WeaponType = CaelumConstants.WEAPON_TYPE_CARBINE;
        }
        else if (WeaponWeightInitialized && EquippedWeaponBaseWeight <= 4.5)
        {
            WeaponType = CaelumConstants.WEAPON_TYPE_STAFF;
        }
        WeaponDurability = 100;
        if (WeaponType == CaelumConstants.WEAPON_TYPE_STAFF) { WeaponDurability = 80; }
        else if (WeaponType == CaelumConstants.WEAPON_TYPE_CARBINE) { WeaponDurability = 120; }
        int tierMultiplier = WeaponTier == 1 ? 1 : (WeaponTier == 2 ? 3 : 9);
        WeaponDurability = CaelumEquipmentRules.ScaleDurabilityForSize(
            WeaponDurability * tierMultiplier,
            WeaponSize
        );
        WeaponEquipped = migrateExistingWeapon;
        if (migrateExistingWeapon)
        {
            int weaponIndex = GetSizedWeaponOwnershipIndex(
                WeaponType, WeaponTier, WeaponSize
            );
            SizedOwnedWeapon[weaponIndex] = true;
            SizedOwnedWeaponDurability[weaponIndex] = WeaponDurability;
        }
        WeaponEquipmentInitialized = true;
    }

    void MarkCurrentEquipmentOwned()
    {
        for (int slot = 0; slot < CaelumConstants.ARMOR_SLOT_COUNT; slot++)
        {
            if (ArmorType[slot] == CaelumConstants.ARMOR_TYPE_BASE_CLOTHING)
            {
                continue;
            }
            int armorIndex = GetSizedArmorOwnershipIndex(
                slot,
                ArmorType[slot],
                ArmorTier[slot],
                ArmorSize[slot]
            );
            SizedOwnedArmor[armorIndex] = true;
            SizedOwnedArmorDurability[armorIndex] = ArmorDurability[slot];
        }
        if (ShieldEquipped)
        {
            int shieldIndex = GetSizedShieldOwnershipIndex(
                ShieldType, ShieldTier, ShieldSize
            );
            SizedOwnedShield[shieldIndex] = true;
            SizedOwnedShieldDurability[shieldIndex] = ShieldDurability;
        }
        if (WeaponEquipped)
        {
            int weaponIndex = GetSizedWeaponOwnershipIndex(
                WeaponType, WeaponTier, WeaponSize
            );
            SizedOwnedWeapon[weaponIndex] = true;
            SizedOwnedWeaponDurability[weaponIndex] = WeaponDurability;
            SizedWeaponEquipped[weaponIndex] = true;
            SizedWeaponEssenceType[weaponIndex] = Clamp(
                WeaponEssenceType,
                0,
                CaelumConstants.ESSENCE_TYPE_COUNT - 1
            );
        }
    }

    bool RegisterOwnedArmor(
        int slot,
        int armorType,
        int tier,
        int equipmentSize,
        int durability
    )
    {
        int index = GetSizedArmorOwnershipIndex(slot, armorType, tier, equipmentSize);
        bool newlyOwned = !SizedOwnedArmor[index];
        SizedOwnedArmor[index] = true;
        SizedOwnedArmorDurability[index] = Max(
            SizedOwnedArmorDurability[index],
            Max(0, durability)
        );
        return newlyOwned;
    }

    bool RegisterOwnedShield(int shieldType, int tier, int equipmentSize, int durability)
    {
        int index = GetSizedShieldOwnershipIndex(shieldType, tier, equipmentSize);
        bool newlyOwned = !SizedOwnedShield[index];
        SizedOwnedShield[index] = true;
        SizedOwnedShieldDurability[index] = Max(
            SizedOwnedShieldDurability[index],
            Max(0, durability)
        );
        return newlyOwned;
    }

    bool RegisterOwnedWeapon(int weaponType, int tier, int equipmentSize, int durability)
    {
        int index = GetSizedWeaponOwnershipIndex(weaponType, tier, equipmentSize);
        bool newlyOwned = !SizedOwnedWeapon[index];
        SizedOwnedWeapon[index] = true;
        SizedOwnedWeaponDurability[index] = Max(
            SizedOwnedWeaponDurability[index], Max(0, durability)
        );
        return newlyOwned;
    }

    bool OwnsArmor(int slot, int armorType, int tier, int equipmentSize)
    {
        return SizedOwnedArmor[
            GetSizedArmorOwnershipIndex(slot, armorType, tier, equipmentSize)
        ];
    }

    bool OwnsShield(int shieldType, int tier, int equipmentSize)
    {
        return SizedOwnedShield[
            GetSizedShieldOwnershipIndex(shieldType, tier, equipmentSize)
        ];
    }

    bool OwnsWeapon(int weaponType, int tier, int equipmentSize)
    {
        return SizedOwnedWeapon[
            GetSizedWeaponOwnershipIndex(weaponType, tier, equipmentSize)
        ];
    }

    bool IsArmorInMagicBox(int slot, int armorType, int tier, int equipmentSize)
    {
        return SizedArmorInMagicBox[
            GetSizedArmorOwnershipIndex(slot, armorType, tier, equipmentSize)
        ];
    }

    bool IsShieldInMagicBox(int shieldType, int tier, int equipmentSize)
    {
        return SizedShieldInMagicBox[
            GetSizedShieldOwnershipIndex(shieldType, tier, equipmentSize)
        ];
    }

    bool IsWeaponInMagicBox(int weaponType, int tier, int equipmentSize)
    {
        return SizedWeaponInMagicBox[
            GetSizedWeaponOwnershipIndex(weaponType, tier, equipmentSize)
        ];
    }

    bool IsWeaponEquipped(int weaponType, int tier, int equipmentSize)
    {
        return SizedWeaponEquipped[
            GetSizedWeaponOwnershipIndex(weaponType, tier, equipmentSize)
        ];
    }

    void SetWeaponEquipped(
        int weaponType, int tier, int equipmentSize, bool equipped
    )
    {
        int index = GetSizedWeaponOwnershipIndex(
            weaponType, tier, equipmentSize
        );
        SizedWeaponEquipped[index] = equipped && SizedOwnedWeapon[index];
        if (SizedWeaponEquipped[index]) { SizedWeaponInMagicBox[index] = false; }
    }

    int CountEquippedWeapons()
    {
        int total = 0;
        for (int index = 0;
            index < CaelumConstants.WEAPON_OWNERSHIP_COUNT; index++)
        {
            if (SizedOwnedWeapon[index] && SizedWeaponEquipped[index]) { total++; }
        }
        return total;
    }

    bool HasEquippedWeaponType(int weaponType)
    {
        for (int tier = 1; tier <= 3; tier++)
        {
            for (int equipmentSize = 0;
                equipmentSize < CaelumConstants.EQUIPMENT_SIZE_COUNT;
                equipmentSize++)
            {
                if (IsWeaponEquipped(weaponType, tier, equipmentSize))
                {
                    return true;
                }
            }
        }
        return false;
    }

    void SetArmorInMagicBox(
        int slot, int armorType, int tier, int equipmentSize, bool inMagicBox
    )
    {
        SizedArmorInMagicBox[
            GetSizedArmorOwnershipIndex(slot, armorType, tier, equipmentSize)
        ] = inMagicBox;
    }

    void SetShieldInMagicBox(
        int shieldType, int tier, int equipmentSize, bool inMagicBox
    )
    {
        SizedShieldInMagicBox[
            GetSizedShieldOwnershipIndex(shieldType, tier, equipmentSize)
        ] = inMagicBox;
    }

    void SetWeaponInMagicBox(
        int weaponType, int tier, int equipmentSize, bool inMagicBox
    )
    {
        int index = GetSizedWeaponOwnershipIndex(
            weaponType, tier, equipmentSize
        );
        SizedWeaponInMagicBox[index] = inMagicBox;
        if (inMagicBox) { SizedWeaponEquipped[index] = false; }
    }

    int GetOwnedArmorDurability(int slot, int armorType, int tier, int equipmentSize)
    {
        return SizedOwnedArmorDurability[
            GetSizedArmorOwnershipIndex(slot, armorType, tier, equipmentSize)
        ];
    }

    int GetOwnedShieldDurability(int shieldType, int tier, int equipmentSize)
    {
        return SizedOwnedShieldDurability[
            GetSizedShieldOwnershipIndex(shieldType, tier, equipmentSize)
        ];
    }

    int GetOwnedWeaponDurability(int weaponType, int tier, int equipmentSize)
    {
        return SizedOwnedWeaponDurability[
            GetSizedWeaponOwnershipIndex(weaponType, tier, equipmentSize)
        ];
    }

    int GetWeaponEssenceType(int weaponType, int tier, int equipmentSize)
    {
        EnsureWeaponEssenceInitialized();
        return Clamp(
            SizedWeaponEssenceType[GetSizedWeaponOwnershipIndex(
                weaponType, tier, equipmentSize
            )],
            0,
            CaelumConstants.ESSENCE_TYPE_COUNT - 1
        );
    }

    void SetWeaponEssenceType(
        int weaponType, int tier, int equipmentSize, int essenceType
    )
    {
        EnsureWeaponEssenceInitialized();
        SizedWeaponEssenceType[GetSizedWeaponOwnershipIndex(
            weaponType, tier, equipmentSize
        )] = Clamp(
            essenceType, 0, CaelumConstants.ESSENCE_TYPE_COUNT - 1
        );
    }

    void StoreOwnedArmorDurability(
        int slot,
        int armorType,
        int tier,
        int equipmentSize,
        int durability
    )
    {
        int index = GetSizedArmorOwnershipIndex(slot, armorType, tier, equipmentSize);
        if (SizedOwnedArmor[index])
        {
            SizedOwnedArmorDurability[index] = Max(0, durability);
        }
    }

    void StoreOwnedShieldDurability(
        int shieldType,
        int tier,
        int equipmentSize,
        int durability
    )
    {
        int index = GetSizedShieldOwnershipIndex(shieldType, tier, equipmentSize);
        if (SizedOwnedShield[index])
        {
            SizedOwnedShieldDurability[index] = Max(0, durability);
        }
    }

    void StoreOwnedWeaponDurability(
        int weaponType,
        int tier,
        int equipmentSize,
        int durability
    )
    {
        int index = GetSizedWeaponOwnershipIndex(weaponType, tier, equipmentSize);
        if (SizedOwnedWeapon[index])
        {
            SizedOwnedWeaponDurability[index] = Max(0, durability);
        }
    }

    void RemoveOwnedArmor(int slot, int armorType, int tier, int equipmentSize)
    {
        int index = GetSizedArmorOwnershipIndex(slot, armorType, tier, equipmentSize);
        SizedOwnedArmor[index] = false;
        SizedOwnedArmorDurability[index] = 0;
        SizedArmorInMagicBox[index] = false;
    }

    void RemoveOwnedShield(int shieldType, int tier, int equipmentSize)
    {
        int index = GetSizedShieldOwnershipIndex(shieldType, tier, equipmentSize);
        SizedOwnedShield[index] = false;
        SizedOwnedShieldDurability[index] = 0;
        SizedShieldInMagicBox[index] = false;
    }

    void RemoveOwnedWeapon(int weaponType, int tier, int equipmentSize)
    {
        int index = GetSizedWeaponOwnershipIndex(weaponType, tier, equipmentSize);
        SizedOwnedWeapon[index] = false;
        SizedOwnedWeaponDurability[index] = 0;
        SizedWeaponEssenceType[index] = CaelumConstants.ESSENCE_FIRE;
        SizedWeaponInMagicBox[index] = false;
        SizedWeaponEquipped[index] = false;
    }

    int CountOwnedArmor()
    {
        int total = 0;
        for (int i = 0; i < 300; i++) { if (SizedOwnedArmor[i]) total++; }
        return total;
    }

    int CountOwnedShields()
    {
        int total = 0;
        for (int i = 0; i < 60; i++) { if (SizedOwnedShield[i]) total++; }
        return total;
    }

    int CountOwnedWeapons()
    {
        int total = 0;
        for (int i = 0; i < CaelumConstants.WEAPON_OWNERSHIP_COUNT; i++)
        {
            if (SizedOwnedWeapon[i]) { total++; }
        }
        return total;
    }

    int CountMagicBoxItems()
    {
        int total = 0;
        for (int i = 0; i < 300; i++)
        {
            if (SizedOwnedArmor[i] && SizedArmorInMagicBox[i]) { total++; }
        }
        for (int i = 0; i < 60; i++)
        {
            if (SizedOwnedShield[i] && SizedShieldInMagicBox[i]) { total++; }
        }
        for (int i = 0; i < CaelumConstants.WEAPON_OWNERSHIP_COUNT; i++)
        {
            if (SizedOwnedWeapon[i] && SizedWeaponInMagicBox[i]) { total++; }
        }
        return total;
    }
}
