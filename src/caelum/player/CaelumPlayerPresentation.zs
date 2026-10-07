// Proyección de estado de juego para HUD/Diario. El pawn conserva los campos.
// Se mantienen los puntos de llamada y las inicializaciones heredadas.
class CaelumPlayerPresentation : Object play
{
    static void RefreshSocialJournalSnapshot(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return;
        user.JournalReputationTrialEnabled = user.FindInventory("CaelumReputationTrialState") != null;
        CaelumPersistentCharacterState persistentState =
            user.GetPersistentCharacterState(true);
        user.MainM00SwimLessonStartedSnapshot = persistentState != null && persistentState.MainM00SwimLessonStarted;
        user.MainM00SwimLessonSubmergedSnapshot = persistentState != null && persistentState.MainM00SwimLessonSubmerged;
        user.MainM00SwimLessonCompleteSnapshot = persistentState != null && persistentState.MainM00SwimLessonComplete;
        user.MainM00LoadLessonStartedSnapshot = persistentState != null && persistentState.MainM00LoadLessonStarted;
        user.MainM00LoadLessonCompleteSnapshot = persistentState != null && persistentState.MainM00LoadLessonComplete;
        user.MainM00LoadWeightSnapshot = user.DerivedStats == null ? 0 : user.DerivedStats.CarriedWeight;
        user.MainM00LoadCapacitySnapshot = user.DerivedStats == null ? 0 : user.DerivedStats.CarryCapacity;
        user.MainM00LoadAirFactorSnapshot = user.DerivedStats == null ? 1 : user.DerivedStats.CalculateLoadAirMultiplier(user.DerivedStats.LoadRatio);
        user.MainM00AirLessonStartedSnapshot = persistentState != null && persistentState.MainM00AirLessonStarted;
        user.MainM00AirLessonRanSnapshot = persistentState != null && persistentState.MainM00AirLessonRan;
        user.MainM00AirLessonCompleteSnapshot = persistentState != null && persistentState.MainM00AirLessonComplete;
        user.MainM00NeedsLessonStartedSnapshot = persistentState != null && persistentState.MainM00NeedsLessonStarted;
        user.MainM00NeedsFoodUsedSnapshot = persistentState != null && persistentState.MainM00NeedsFoodUsed;
        user.MainM00NeedsWaterUsedSnapshot = persistentState != null && persistentState.MainM00NeedsWaterUsed;
        user.MainM00RepairLessonOfferedSnapshot = persistentState != null && persistentState.MainM00RepairLessonOffered;
        user.MainM00RepairLessonCompleteSnapshot = persistentState != null && persistentState.MainM00RepairLessonComplete;
        user.JournalKnownQuestCount = 0;
        if (persistentState == null) { return; }

        persistentState.EnsureQuestStateInitialized();
        persistentState.EnsureFactionStateInitialized();
        for (int questId = 0;
            questId < CaelumConstants.QUEST_DEFINED_COUNT; questId++)
        {
            user.JournalQuestRewardClaimed[questId] = persistentState.QuestRewardClaimed[questId];
            user.JournalQuestCanStart[questId] = CaelumSideQuestRules.CanStart(persistentState, questId);
            user.JournalQuestReady[questId] = CaelumSideQuestRules.ObjectivesComplete(persistentState, questId);
            user.JournalQuestState[questId] =
                CaelumQuestCatalogue.State(persistentState, questId);
            user.JournalQuestStage[questId] = questId < CaelumConstants.QUEST_SEWERS
                ? persistentState.QuestStage[questId] : user.JournalQuestState[questId];
            if (CaelumQuestCatalogue.IsRescue(questId))
                user.JournalQuestRewardClaimed[questId] = persistentState.PrisonerRewardClaimed[
                    questId - CaelumConstants.QUEST_RESCUE_FIRST];
            if (user.JournalQuestState[questId]
                != CaelumConstants.QUEST_STATE_UNDISCOVERED)
            {
                user.JournalKnownQuestCount++;
            }
        }
        for (int objective = 0;
            objective
                < CaelumConstants.QUEST_JOURNAL_OBJECTIVE_STORAGE_COUNT;
            objective++)
        {
            user.JournalQuestObjectiveKnown[objective] =
                objective < CaelumConstants.QUEST_SEWERS * CaelumConstants.QUEST_OBJECTIVE_CAPACITY
                    && persistentState.QuestObjectiveKnown[objective];
            user.JournalQuestObjectiveProgress[objective] =
                persistentState.QuestObjectiveProgress[objective];
            user.JournalQuestObjectiveTarget[objective] =
                persistentState.QuestObjectiveTarget[objective];
        }
        CaelumTarotService.RefreshJournalSnapshot(user, persistentState);
        user.JournalPalomoPlacement = persistentState.ResolvePalomoPlacement();
        user.JournalMainM00ArgentoStarted = persistentState.HasMainM00Flag(
            CaelumConstants.MAIN_M00_FLAG_ARGENTO_STARTED);
        user.MainM00ConvincedCountSnapshot = persistentState.CountMainM00ConvincedResidents();
        user.MainM00MagicPracticeSnapshot = persistentState.CountMainM00MagicPractice();
        user.MainM00RuneSequenceSnapshot = persistentState.MainM00RuneSequenceIndex;
        CaelumMainM00SealCrafting.EnsureMigration(user);
        user.MainM00SealRecipesSnapshot = persistentState.MainM00SealRecipesLearned;
        user.MainM00WaterGivenSnapshot = persistentState.MainM00WaterContainerGiven;
        user.MainM00WaterFilledSnapshot = persistentState.MainM00WaterFilled;
        user.MainM00WaterDrankSnapshot = persistentState.MainM00WaterDrank;
        user.MainM00ChosenSealSnapshot = persistentState.MainM00SealChoice - 1;
        user.MainM00ChosenAmuletSnapshot = persistentState.MainM00AmuletChoice - 1;
        user.MainM00AmuletPreparedSnapshot = persistentState.MainM00AmuletPrepared;
        user.MainM00SealsPreparedSnapshot = 0;
        for (int element = 0; element < CaelumConstants.SEAL_TYPE_COUNT; element++)
            if (persistentState.MainM00SealsPrepared[element] && persistentState.MainM00SealChoice == element + 1) user.MainM00SealsPreparedSnapshot++;
        user.MainM00ArmorTypeSnapshot = persistentState.MainM00ArmorChosen ? persistentState.MainM00ArmorType : -1;
        user.MainM00ArmorPiecesSnapshot = 0;
        for (int slot = 0; slot < 4; slot++) if (persistentState.MainM00ArmorCrafted[slot]) user.MainM00ArmorPiecesSnapshot++;
        user.MainM00StarterOptionSnapshot = persistentState.MainM00StarterChosen ? persistentState.MainM00StarterOption : -1;
        user.MainM00StarterSizeSnapshot = persistentState.MainM00StarterSize;
        user.MainM00StarterWeaponSnapshot = persistentState.MainM00StarterWeaponId;
        user.MainM00RonnieFinishedSnapshot = persistentState.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_RONNIE_COMPLETE);
        for (int i = 0; i < CaelumConstants.MATERIAL_TYPE_COUNT; i++)
            user.MainM00StarterRequiredSnapshot[i] = persistentState.MainM00StarterRequired[i];
        for (int i = 0; i < 6; i++) user.MainM00SupplySnapshot[i] = persistentState.MainM00SupplyRemaining[i];
        user.JournalMainM00MagicPracticeDone[0] = persistentState.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_MAGIC_PRIMARY_USED);
        user.JournalMainM00MagicPracticeDone[1] = persistentState.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_MAGIC_SECONDARY_USED);
        user.JournalMainM00MagicPracticeDone[2] = persistentState.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_MAGIC_CHANNEL_USED);
        user.JournalMainM00MagicPracticeDone[3] = persistentState.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_MAGIC_ANIMA_SPENT);
        user.JournalMainM00MagicPracticeDone[4] = persistentState.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_MAGIC_ANIMA_RECOVERED);
        for (int factionId = 0;
            factionId < CaelumConstants.FACTION_COUNT; factionId++)
        {
            user.JournalFactionMember[factionId] =
                persistentState.FactionMember[factionId];
            user.JournalFactionReputation[factionId] =
                persistentState.FactionReputation[factionId];
        }
    }

    static void SyncHUDActiveWeaponState(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return;
        user.HUDHasEquippedSeal = false;
        user.HUDSealChannelAvailable = user.CombatChannelModeActive || user.CanStartSealChannel();
        user.HUDEquippedSealType = CaelumConstants.SEAL_FIRE;
        user.HUDEquippedSealTier = 0;
        for (Inventory sealCursor = user.Inv; sealCursor != null;
            sealCursor = sealCursor.Inv)
        {
            CaelumEquipmentItem equippedSeal =
                CaelumEquipmentItem(sealCursor);
            if (equippedSeal != null && equippedSeal.Equipped
                && equippedSeal.EquipmentKind
                    == CaelumConstants.EQUIPMENT_KIND_SEAL)
            {
                user.HUDHasEquippedSeal = true;
                user.HUDEquippedSealType = Clamp(equippedSeal.ItemType, 0,
                    CaelumConstants.SEAL_TYPE_COUNT - 1);
                user.HUDEquippedSealTier = Clamp(equippedSeal.Tier, 1, 3);
                break;
            }
        }
        bool hasActiveWeapon = user.WeaponModel != null
            && user.WeaponModel.Equipped
            && user.WeaponModel.Durability > 0
            && user.HasEquippedNativeWeaponType(user.WeaponModel.WeaponType)
            && !(user.player != null && user.player.ReadyWeapon is "CaelumUnarmedWeapon");
        int activeType = hasActiveWeapon ? user.WeaponModel.WeaponType : -1;
        int activeTier = hasActiveWeapon ? user.WeaponModel.Tier : 0;
        int activeSize = hasActiveWeapon
            ? user.WeaponModel.Size : CaelumConstants.EQUIPMENT_SIZE_M;
        int activeEssenceType = hasActiveWeapon
            ? Clamp(
                user.WeaponModel.EssenceType,
                0,
                CaelumConstants.ESSENCE_TYPE_COUNT - 1
            )
            : CaelumConstants.ESSENCE_FIRE;
        int activeItemId = hasActiveWeapon ? user.ActiveWeaponItemId : 0;

        bool changed = !user.HUDActiveWeaponStateInitialized
            || user.HUDHasActiveWeapon != hasActiveWeapon
            || user.HUDActiveWeaponType != activeType
            || user.HUDActiveWeaponTier != activeTier
            || user.HUDActiveWeaponSize != activeSize
            || user.HUDActiveWeaponEssenceType != activeEssenceType
            || user.HUDActiveWeaponItemId != activeItemId;

        user.HUDHasActiveWeapon = hasActiveWeapon;
        user.HUDActiveWeaponType = activeType;
        user.HUDActiveWeaponTier = activeTier;
        user.HUDActiveWeaponSize = activeSize;
        user.HUDActiveWeaponEssenceType = activeEssenceType;
        user.HUDActiveWeaponItemId = activeItemId;
        user.HUDActiveWeaponIsRanged = hasActiveWeapon
            && user.IsRangedWeaponType(activeType);
        user.HUDRangedMagazineCount = user.HUDActiveWeaponIsRanged
            ? user.GetRangedMagazineCount(activeType) : 0;
        user.HUDRangedMagazineCapacity = user.HUDActiveWeaponIsRanged
            ? user.GetRangedMagazineCapacity(activeType) : 0;
        user.HUDRangedReserveCount = user.HUDActiveWeaponIsRanged
            ? user.GetEquippedRangedReserveCount() : 0;
        user.HUDHasActiveBlockSource = user.HasActiveBlockSource();
        user.HUDCombatBlockActive = user.CombatBlockModeActive && user.HUDHasActiveBlockSource;
        user.HUDCombatBlockUsesGauntlets = user.HUDCombatBlockActive
            && user.IsGiantGauntletsBlockSource();
        user.HUDActiveShieldType = user.HUDCombatBlockActive
            && !user.HUDCombatBlockUsesGauntlets && user.ShieldModel != null
            ? user.ShieldModel.ShieldType : CaelumConstants.SHIELD_TYPE_BUCKLER;

        if (changed)
        {
            user.HUDActiveWeaponNoticeRemaining =
                CaelumConstants.ACTIVE_WEAPON_NOTICE_SECONDS;
            user.HUDActiveWeaponStateInitialized = true;
        }
        else
        {
            user.HUDActiveWeaponNoticeRemaining = Max(
                0.0,
                user.HUDActiveWeaponNoticeRemaining - 1.0 / TICRATE
            );
        }
    }

    static void SyncHUDLoadState(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return;
        if (user.DerivedStats == null)
        {
            user.HUDCarriedWeight = 0.0;
            user.HUDCarryCapacity = 0.0;
            user.HUDLoadRatio = 0.0;
            return;
        }
        user.HUDCarriedWeight = user.DerivedStats.CarriedWeight;
        user.HUDCarryCapacity = user.DerivedStats.CarryCapacity;
        user.HUDLoadRatio = user.DerivedStats.LoadRatio;
    }

}
