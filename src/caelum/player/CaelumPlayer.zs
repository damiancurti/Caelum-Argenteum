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
    CaelumAnatomyProfile AnatomyProfile;
    bool DebugAttributesAt75;
    bool DebugAttributesAt100;
    int DebugPanelPage;

    // Four independently configured armor pieces provide uniform defense by
    // armor type/tier, slot-specific reinforcement, bonuses, and durability.
    CaelumArmorModel ArmorModel;
    CaelumShieldModel ShieldModel;
    CaelumWeaponModel WeaponModel;
    int OwnedArmorCount;
    int OwnedShieldCount;
    int OwnedWeaponCount;
    bool EquipmentMenuOpen;
    int EquipmentSelectionKind;
    int EquipmentSelectionSlot;
    int EquipmentSelectionArmorType;
    int EquipmentSelectionShieldType;
    int EquipmentSelectionWeaponType;
    int EquipmentSelectionConsumableType;
    int EquipmentSelectionSpecialType;
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
    bool LastEquipmentPickupWasNew;
    bool LastEquipmentPickupWentToMagicBox;
    double EquippedWeaponBaseWeight;
    int EquippedWeaponTier;
    int EquippedWeaponSize;
    bool WeaponWeightInitialized;
    double EquippedWeaponCooldownRemaining;
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
    int LastArmorDurabilityLoss;
    double LastArmorDurabilityChancePercent;
    double LastArmorDurabilityRollPercent;
    double LastLocalizedLucidityLoss;
    bool LastArmorHitWasCritical;
    bool LastIncomingActorCriticalHit;
    double LastIncomingActorCriticalChancePercent;
    double LastIncomingActorCriticalRollPercent;
    bool DebugShieldBlocking;
    int DebugShieldDamageKind;
    int DebugShieldIncomingAngleOffset;
    bool LastShieldWithinCoverage;
    double LastShieldAbsorbedDamage;
    int LastShieldHealthDamage;
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
    double LastMeleeYawOffset;
    double LastMeleePitchOffset;
    double LastAttackPushForce;

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

    int CountNativeMagicBoxSlots()
    {
        int total = 0;
        for (Inventory cursor = Inv; cursor != null; cursor = cursor.Inv)
        {
            CaelumEquipmentItem item = CaelumEquipmentItem(cursor);
            if (item != null && item.InMagicBox) { total++; }
        }
        CaelumCarbineAmmo ammunition = CaelumCarbineAmmo(
            FindInventory("CaelumCarbineAmmo")
        );
        if (ammunition != null && ammunition.Amount > 0
            && ammunition.InMagicBox)
        {
            total++;
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
        if (FindInventory("CaelumCarbineAmmo") != null) { return true; }
        RefreshCarriedInventorySummary();
        ammunition.InMagicBox = false;
        double incomingWeight = ammunition.Amount
            * CaelumConstants.CARBINE_AMMO_UNIT_WEIGHT;
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
            * CaelumConstants.CARBINE_AMMO_UNIT_WEIGHT;
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

    // Los tres actores invisibles ocupan los botones nativos de sus familias:
    // espada 3, carabina 5 y bastón 6. Las piezas reales permanecen visibles
    // en Actor.Inv; estos actores solo permiten cambiar la familia activa.
    void EnsureWeaponFamilySelectors()
    {
        if (!CharacterCreationComplete) { return; }
        if (HasEquippedNativeWeaponType(
            CaelumConstants.WEAPON_TYPE_SWORD
        ) && FindInventory("CaelumSwordWeapon") == null)
        {
            GiveInventoryType("CaelumSwordWeapon");
        }
        else if (!HasEquippedNativeWeaponType(
            CaelumConstants.WEAPON_TYPE_SWORD
        ))
        {
            TakeInventory("CaelumSwordWeapon", 1);
        }
        if (HasEquippedNativeWeaponType(
            CaelumConstants.WEAPON_TYPE_CARBINE
        ) && FindInventory("CaelumCarbineWeapon") == null)
        {
            GiveInventoryType("CaelumCarbineWeapon");
        }
        else if (!HasEquippedNativeWeaponType(
            CaelumConstants.WEAPON_TYPE_CARBINE
        ))
        {
            TakeInventory("CaelumCarbineWeapon", 1);
        }
        if (HasEquippedNativeWeaponType(
            CaelumConstants.WEAPON_TYPE_STAFF
        ) && FindInventory("CaelumStaffWeapon") == null)
        {
            GiveInventoryType("CaelumStaffWeapon");
        }
        else if (!HasEquippedNativeWeaponType(
            CaelumConstants.WEAPON_TYPE_STAFF
        ))
        {
            TakeInventory("CaelumStaffWeapon", 1);
        }
        // El selector único de 4.7 queda retirado al migrar al sistema por
        // familias; la propiedad y durabilidad permanecen en el registro.
        TakeInventory("CaelumEquippedWeapon", 1);
    }

    bool ActivateEquippedWeaponType(int requestedWeaponType)
    {
        if (WeaponModel == null) { return false; }
        int resolvedType = Clamp(
            requestedWeaponType, 0, CaelumConstants.WEAPON_TYPE_COUNT - 1
        );
        if (WeaponModel.Equipped
            && WeaponModel.WeaponType == resolvedType
            && HasEquippedNativeWeaponType(resolvedType))
        {
            return true;
        }
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

    void PerformWeaponFamilySecondaryAction(int weaponType)
    {
        if (ActivateEquippedWeaponType(weaponType))
        {
            PerformEquippedSecondaryHandAction();
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

        CaelumCarbineAmmo carbineAmmo = CaelumCarbineAmmo(
            FindInventory("CaelumCarbineAmmo")
        );
        if (carbineAmmo != null && carbineAmmo.Amount > 0)
        {
            CarbineAmmoCount = carbineAmmo.Amount;
            if (carbineAmmo.InMagicBox)
            {
                MagicBoxUsedSlots++;
            }
            else
            {
                PersonalInventoryItemCount += carbineAmmo.Amount;
                double ammunitionWeight = carbineAmmo.GetCarriedWeight();
                personalInventoryWeight += ammunitionWeight;
                carriedItemWeight += ammunitionWeight;
            }
        }
        else { CarbineAmmoCount = 0; }

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
        EquipmentSelectionConsumableType = Clamp(
            EquipmentSelectionConsumableType,
            0,
            CaelumConstants.CONSUMABLE_TYPE_COUNT - 1
        );
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
            CaelumCarbineAmmo ammunition = CaelumCarbineAmmo(
                FindInventory("CaelumCarbineAmmo")
            );
            EquipmentSelectionOwned = ammunition != null
                && ammunition.Amount > 0;
            EquipmentSelectionInMagicBox = EquipmentSelectionOwned
                && ammunition.InMagicBox;
            EquipmentSelectionSizeCompatible = true;
            EquipmentSelectionStackAmount = EquipmentSelectionOwned
                ? ammunition.Amount : 0;
            EquipmentSelectionWeight = EquipmentSelectionStackAmount
                * CaelumConstants.CARBINE_AMMO_UNIT_WEIGHT;
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

        if (EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_WEAPON)
        {
            CaelumEquipmentItem item = FindNativeEquipmentItem(
                CaelumConstants.EQUIPMENT_KIND_WEAPON,
                EquipmentSelectionWeaponType,
                -1,
                EquipmentSelectionTier,
                EquipmentSelectionSize
            );
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

    void ToggleEquipmentMenu()
    {
        if (CreationWizardOpen) { return; }
        EquipmentMenuOpen = !EquipmentMenuOpen;
        if (!EquipmentMenuOpen) { return; }
        LastEquipmentAction = CaelumConstants.EQUIPMENT_ACTION_NONE;
        PersistCharacterState();

        if (ArmorModel != null)
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
            == CaelumConstants.EQUIPMENT_KIND_AMMUNITION) { return; }
        if (EquipmentSelectionKind >= CaelumConstants.EQUIPMENT_KIND_MATERIAL)
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
            CaelumEquipmentItem weapon = FindNativeEquipmentItem(
                CaelumConstants.EQUIPMENT_KIND_WEAPON,
                WeaponModel.WeaponType, -1,
                WeaponModel.Tier, WeaponModel.Size
            );
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
        if (EquipmentSelectionKind >= CaelumConstants.EQUIPMENT_KIND_MATERIAL)
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
        else
        {
            item.Equipped = true;
            if (!WeaponModel.Equipped)
            {
                WeaponModel.WeaponType = item.ItemType;
                WeaponModel.Tier = item.Tier;
                WeaponModel.Size = item.EquipmentSize;
                WeaponModel.Durability = item.Durability;
                WeaponModel.Equipped = true;
            }
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
            DebugShieldBlocking = false;
        }
        else
        {
            bool wasActive = WeaponModel.Equipped
                && WeaponModel.WeaponType == item.ItemType
                && WeaponModel.Tier == item.Tier
                && WeaponModel.Size == item.EquipmentSize;
            if (wasActive) { WeaponModel.Equipped = false; }
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
            CaelumCarbineAmmo ammunition = CaelumCarbineAmmo(
                FindInventory("CaelumCarbineAmmo")
            );
            if (ammunition == null || ammunition.Amount <= 0) { return; }
            double stackWeight = ammunition.Amount
                * CaelumConstants.CARBINE_AMMO_UNIT_WEIGHT;
            if (ammunition.InMagicBox)
            {
                if (!CanAddWeightToPersonalInventory(stackWeight))
                {
                    LastEquipmentAction =
                        CaelumConstants.EQUIPMENT_ACTION_FAILED_CARRY_CAPACITY;
                    return;
                }
                ammunition.InMagicBox = false;
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
                ammunition.InMagicBox = true;
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
        if (EquipmentSelectionKind >= CaelumConstants.EQUIPMENT_KIND_MATERIAL)
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
            pickup = Spawn("CaelumCarbineAmmo", spawnPos, NO_REPLACE);
            if (pickup != null)
            {
                Inventory(pickup).Amount = 100;
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
        else
        {
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
            CaelumCarbineAmmo ammunition = CaelumCarbineAmmo(
                FindInventory("CaelumCarbineAmmo")
            );
            if (ammunition == null || ammunition.Amount <= 0) { return; }
            ammunition.InMagicBox = false;
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

    // Directed combat damage now uses the complete Caelum defensive order.
    // Environmental and unclassified damage stays on GZDoom's native route.
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
            UpdateHealthStateEffects();
            CalculateAndTriggerPain(
                actualHealthLost,
                adrenalineRatioBeforeDamage
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
            CaelumActorProjectile attackProjectile = CaelumActorProjectile(inflictor);
            if (attackProjectile != null)
            {
                ApplyAttackPushToTarget(
                    self,
                    inflictor.AngleTo(self),
                    attackProjectile.CaelumPushMultiplier
                );
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
            CalculateAndTriggerPain(actualHealthLost, adrenalineRatioBeforeDamage);
            AddCombatAdrenaline(
                CaelumConstants.ADRENALINE_GAIN_ON_DAMAGE,
                CaelumConstants.ADRENALINE_EVENT_DAMAGE
            );
            MarkCombatActivity();
        }
        if (armorPieceBroken) { ApplyCharacterProfile(); }
        return result;
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
        PrepareRealArmorDamage(damageAfterShield, incomingActorCritical);

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
            CaelumActorProjectile attackProjectile = CaelumActorProjectile(inflictor);
            if (attackProjectile != null)
            {
                ApplyAttackPushToTarget(
                    self,
                    inflictor.Angle,
                    attackProjectile.CaelumPushMultiplier
                );
            }
            LastArmorHealthDamage = actualHealthLost;
            ApplyLocalizedLucidityLoss(
                GetBaseVulnerabilityForArmorSlot(ArmorModel.SelectedSlot),
                LastArmorVulnerabilityGrade,
                incomingActorCritical,
                Clamp(ArmorModel.GetDefense(ArmorModel.SelectedSlot) / 100.0, 0.0, 1.0)
            );
            UpdateHealthStateEffects();
            CalculateAndTriggerPain(actualHealthLost, adrenalineRatioBeforeDamage);
            AddCombatAdrenaline(
                CaelumConstants.ADRENALINE_GAIN_ON_DAMAGE,
                CaelumConstants.ADRENALINE_EVENT_DAMAGE
            );
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

    double ResolveRealShieldDamage(
        Actor inflictor,
        Actor source,
        double incomingDamage,
        Name mod
    )
    {
        LastShieldAbsorbedDamage = 0.0;
        LastShieldHealthDamage = Max(0, int(incomingDamage + 0.5));
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
        LastShieldWithinCoverage = ShieldModel != null
            && ShieldModel.Equipped
            && incomingOffset <= ShieldModel.GetCoverageDegrees() / 2.0;
        bool shieldCanBlock = ShieldModel != null
            && ShieldModel.Equipped
            && DebugShieldBlocking
            && ShieldModel.Durability > 0
            && LastShieldWithinCoverage;
        if (!shieldCanBlock) { return incomingDamage; }

        int damageKind = mod == 'CaelumMagicTest'
            ? CaelumConstants.SHIELD_DAMAGE_MAGICAL
            : CaelumConstants.SHIELD_DAMAGE_PHYSICAL;
        double defenseRatio = Clamp(
            ShieldModel.GetDefense(damageKind) / 100.0,
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
            AddCombatAdrenaline(
                CaelumConstants.ADRENALINE_GAIN_ON_SHIELD_BLOCK,
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
        if (ShieldModel == null || LastShieldDurabilityLoss <= 0) { return; }
        LastShieldDurabilityLoss = Min(
            LastShieldDurabilityLoss,
            ShieldModel.Durability
        );
        ShieldModel.Durability -= LastShieldDurabilityLoss;
        if (ShieldModel.Durability <= 0) { DebugShieldBlocking = false; }
    }

    void PrepareRealArmorDamage(double incomingDamage, bool criticalHit)
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

        int slot = ArmorModel.SelectedSlot;
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
        int slot = ArmorModel.SelectedSlot;
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
        double adrenalineRatioBeforeDamage
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
                AddCombatAdrenaline(
                    CaelumConstants.ADRENALINE_GAIN_ON_PAIN,
                    CaelumConstants.ADRENALINE_EVENT_PAIN
                );
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

    // Bloquea las acciones normales mientras el creador ocupa la pantalla.
    // Los comandos del creador viajan por eventos de red independientes.
    override void PlayerThink()
    {
        if ((CreationWizardOpen || EquipmentMenuOpen) && player != null)
        {
            UserCmd creationCommand = player.cmd;
            creationCommand.forwardmove = 0;
            creationCommand.sidemove = 0;
            creationCommand.upmove = 0;
            creationCommand.buttons = 0;
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
        Super.Tick();

        // La creación inicial pausa necesidades, regeneraciones y costes.
        if (CreationWizardOpen)
        {
            IsSpendingRunningAir = false;
            return;
        }

        RefreshEquipmentLoadIfNeeded();

        UpdateHealthStateEffects();

        IsSpendingRunningAir = IsRunningOnGround();
        UpdateCrouchEffects();

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
        UpdateLucidityPhysicalStun();
        UpdatePainImmobilization();
        StaffCastCooldownRemaining = Max(
            0.0,
            StaffCastCooldownRemaining - 1.0 / TICRATE
        );
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

        ApplyAirRegeneration();

        UpdateAirStateEffects();
        ApplyPhysicalMovement();
        DetectAndChargePhysicalJump();
        ConsumeRunningAir();
        ConsumeShieldBlockingAir();
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

        switch (WeaponModel.WeaponType)
        {
            case CaelumConstants.WEAPON_TYPE_STAFF:
                PerformDebugStaffAttack();
                break;
            case CaelumConstants.WEAPON_TYPE_CARBINE:
                PerformCarbineAttack();
                break;
            default:
                PerformDebugSwordAttack();
                if (LastMeleeHadEnoughAir)
                {
                    EquippedWeaponCooldownRemaining =
                        WeaponModel.GetAttackTics() / double(TICRATE);
                }
                break;
        }
    }

    // AltFire prioriza siempre el escudo de la mano secundaria. Si no existe,
    // queda reservado para el futuro ataque secundario propio de cada arma.
    void PerformEquippedSecondaryHandAction()
    {
        if (ShieldModel != null && ShieldModel.Equipped)
        {
            ToggleDebugShieldBlock();
        }
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
            || WeaponModel.WeaponType != CaelumConstants.WEAPON_TYPE_CARBINE
            || WeaponModel.Durability <= 0 || DerivedStats == null)
        {
            return;
        }

        CaelumCarbineAmmo carbineAmmo = CaelumCarbineAmmo(
            FindInventory("CaelumCarbineAmmo")
        );
        LastCarbineHadAmmo = carbineAmmo != null
            && carbineAmmo.Amount > 0
            && !carbineAmmo.InMagicBox;
        if (!LastCarbineHadAmmo) { return; }

        double airCost = -CaelumConstants.CARBINE_AIR_CHANGE
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
        LastCarbineAccuracyPercent = Max(
            1.0,
            EffectivePhysicalAccuracyPercent * movementAccuracyMultiplier
        );
        LastCarbineMinimumSpread = CaelumConstants.CARBINE_MINIMUM_SPREAD_DEGREES
            * 100.0 / LastCarbineAccuracyPercent;
        LastCarbineMaximumSpread = CaelumConstants.CARBINE_MAXIMUM_SPREAD_DEGREES
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
        double criticalChance = Clamp(
            (CaelumConstants.CARBINE_BASE_CRITICAL_CHANCE_PERCENT + criticalBonus)
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
        CaelumCarbineProjectile projectile = CaelumCarbineProjectile(
            Spawn("CaelumCarbineProjectile", spawnPos, NO_REPLACE)
        );
        if (projectile == null) { return; }

        projectile.Target = self;
        projectile.Angle = attackAngle;
        projectile.Pitch = attackPitch;
        projectile.Vel = (
            Cos(attackPitch) * Cos(attackAngle)
                * CaelumConstants.WEAPON_CARBINE_PROJECTILE_SPEED,
            Cos(attackPitch) * Sin(attackAngle)
                * CaelumConstants.WEAPON_CARBINE_PROJECTILE_SPEED,
            -Sin(attackPitch) * CaelumConstants.WEAPON_CARBINE_PROJECTILE_SPEED
        );
        projectile.StoreCaelumAttackResult(
            Max(1, int(LastCarbineDamage + 0.5)),
            true,
            LastCarbineCriticalHit,
            false,
            DerivedStats.PhysicalPushMultiplier
        );

        carbineAmmo.Amount = Max(0, carbineAmmo.Amount - 1);
        CarbineAmmoCount = carbineAmmo.Amount;
        CurrentAir = Max(0.0, CurrentAir - airCost);
        UpdateAirStateEffects();
        LastCarbineFired = true;
        EquippedWeaponCooldownRemaining = WeaponModel.GetAttackTics()
            / double(TICRATE);
        MarkCombatActivity();
    }

    void PerformDebugStaffAttack()
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
        if (DerivedStats == null
            || player == null
            || player.playerstate != PST_LIVE
            || IsPhysicallyImmobilized()
            || StaffCastCooldownRemaining > 0.0)
        {
            return;
        }

        LastStaffCalculatedDamage = DerivedStats.DebugStaffDamage
            * GetEquippedWeaponDamageScale(CaelumConstants.WEAPON_TYPE_STAFF)
            * EffectiveOffensiveDamageMultiplier;
        if (CurrentAnima < DerivedStats.StaffAnimaCost)
        {
            LastStaffInsufficientAnima = true;
            return;
        }

        CurrentAnima -= DerivedStats.StaffAnimaCost;
        StaffCastCooldownRemaining = CaelumConstants.DEBUG_STAFF_CAST_TICS
            * DerivedStats.CastingDurationMultiplier / double(TICRATE);
        UpdateLucidityAccuracyEffects();
        UpdateCrouchEffects();
        LastStaffAccuracyPercent = Max(
            1.0,
            EffectiveMagicalAccuracyPercent * CrouchAccuracyMultiplier
        );
        double maximumAimError = CaelumConstants.DEBUG_SWORD_BASE_INACCURACY_DEGREES
            * 100.0 / LastStaffAccuracyPercent;
        LastStaffYawOffset = Random[CaelumStaffAccuracyYaw](-100000, 100000)
            / 100000.0 * maximumAimError;
        LastStaffPitchOffset = Random[CaelumStaffAccuracyPitch](-100000, 100000)
            / 100000.0 * maximumAimError;
        double attackAngle = Angle + LastStaffYawOffset;
        double attackPitch = Pitch + LastStaffPitchOffset;

        FTranslatedLineTarget targetData;
        Actor detectionPuff;
        int ignoredDamage;
        [detectionPuff, ignoredDamage] = LineAttack(
            attackAngle,
            CaelumConstants.DEBUG_STAFF_TRACE_RANGE,
            attackPitch,
            0,
            'CaelumMagicTest',
            'CaelumNoDamageThrustPuff',
            LAF_NOINTERACT | LAF_NORANDOMPUFFZ,
            targetData
        );
        LastStaffHit = targetData.linetarget != null;
        if (!LastStaffHit) { return; }

        int savedMeleeLocation = LastMeleeHitLocation;
        int savedMeleeGrade = LastMeleeVulnerabilityGrade;
        double savedMeleeHeight = LastMeleeHitHeightRatio;
        double savedMeleeMultiplier = LastMeleeLocationMultiplier;
        CalculateDebugMeleeHitLocation(targetData.linetarget, attackAngle, attackPitch);
        LastStaffVulnerabilityGrade = LastMeleeVulnerabilityGrade;
        LastMeleeHitLocation = savedMeleeLocation;
        LastMeleeVulnerabilityGrade = savedMeleeGrade;
        LastMeleeHitHeightRatio = savedMeleeHeight;
        LastMeleeLocationMultiplier = savedMeleeMultiplier;
        LastStaffCriticalAttempted = true;
        LastStaffCriticalChancePercent = Clamp(
            DerivedStats.StaffCriticalChance * CrouchCriticalChanceMultiplier,
            0.0,
            100.0
        );
        int criticalRoll = Random[CaelumMagicalCritical](0, 999999);
        LastStaffCriticalRollPercent = criticalRoll / 10000.0;
        LastStaffCriticalHit = LastStaffCriticalRollPercent
            < LastStaffCriticalChancePercent;
        CaelumCombatActor staffCombatTarget = CaelumCombatActor(
            targetData.linetarget
        );
        if (staffCombatTarget != null)
        {
            staffCombatTarget.RegisterPendingCriticalHit(
                LastStaffCriticalHit
            );
        }
        LastStaffLocationMultiplier = GetVulnerabilityMultiplier(
            LastStaffVulnerabilityGrade,
            LastStaffCriticalHit
        );
        LastStaffCalculatedDamage = DerivedStats.DebugStaffDamage
            * GetEquippedWeaponDamageScale(CaelumConstants.WEAPON_TYPE_STAFF)
            * EffectiveOffensiveDamageMultiplier
            * LastStaffLocationMultiplier;
        int integerDamage = Max(1, int(LastStaffCalculatedDamage + 0.5));

        Actor puff;
        int actualStaffDamage;
        [puff, actualStaffDamage] = LineAttack(
            attackAngle,
            CaelumConstants.DEBUG_STAFF_TRACE_RANGE,
            attackPitch,
            integerDamage,
            'CaelumMagicTest',
            'CaelumNoDamageThrustPuff',
            0,
            targetData
        );
        LastStaffActualDamage = actualStaffDamage;
        if (LastStaffActualDamage > 0)
        {
            ApplyAttackPushToTarget(
                targetData.linetarget,
                attackAngle,
                DerivedStats.MagicalPushMultiplier
            );
            AddCombatAdrenaline(
                CaelumConstants.ADRENALINE_GAIN_ON_MAGIC_DAMAGE,
                CaelumConstants.ADRENALINE_EVENT_MAGIC_DAMAGE
            );
            MarkCombatActivity();
        }
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

    void UpdateShieldAirCost()
    {
        CurrentShieldAirCostPerSecond = 0.0;
        if (ShieldModel == null || DerivedStats == null) { return; }
        CurrentShieldAirCostPerSecond = ShieldModel.GetWeight()
            * CaelumConstants.SHIELD_AIR_WEIGHT_RATIO_PER_SECOND
            * DerivedStats.AirConsumptionMultiplier;
    }

    void ConsumeShieldBlockingAir()
    {
        UpdateShieldAirCost();
        if (!DebugShieldBlocking || ShieldModel == null
            || !ShieldModel.Equipped
            || ShieldModel.Durability <= 0) { return; }
        if (CurrentAir <= 0.0)
        {
            DebugShieldBlocking = false;
            return;
        }
        CurrentAir = Max(0.0, CurrentAir - CurrentShieldAirCostPerSecond / TICRATE);
        if (CurrentAir <= 0.0) { DebugShieldBlocking = false; }
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
        if (ShieldModel == null || !ShieldModel.Equipped
            || ShieldModel.Durability <= 0 || CurrentAir <= 0.0)
        {
            DebugShieldBlocking = false;
            return;
        }
        DebugShieldBlocking = !DebugShieldBlocking;
        UpdateShieldAirCost();
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
            if (ShieldModel.Durability <= 0) { DebugShieldBlocking = false; }
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

    // Apply the verified effective values to GZDoom's real movement fields.
    // Forward/backward, sideways, swimming, and flight share this movement.
    void ApplyPhysicalMovement()
    {
        double movementFactor = Max(0.0, EffectiveMovementPercent / 100.0);
        double jumpFactor = Max(0.0, EffectiveJumpHeightPercent / 100.0);

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

        ForwardMove1 = CaelumConstants.GZDOOM_BASE_MOVEMENT * movementFactor;
        ForwardMove2 = CaelumConstants.GZDOOM_BASE_MOVEMENT * movementFactor;
        SideMove1 = CaelumConstants.GZDOOM_BASE_MOVEMENT * movementFactor;
        SideMove2 = CaelumConstants.GZDOOM_BASE_MOVEMENT * movementFactor;
        JumpZ = CaelumConstants.GZDOOM_BASE_JUMP_Z * jumpFactor;
    }

    bool IsPhysicallyImmobilized()
    {
        return LucidityPhysicalStunRemaining > 0.0
            || PainImmobilizationRemaining > 0.0;
    }

    // Recalculate base attributes whenever a debug profile choice changes.
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
            if (DebugAttributesAt100)
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
        CalculateAndTriggerPain(testDamage, adrenalineRatioBeforeDamage);
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
    void PerformDebugSwordAttack()
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

        LastMeleeAirCost = CaelumConstants.DEBUG_SWORD_PRIMARY_AIR_COST
            * DerivedStats.AirConsumptionMultiplier;
        if (CurrentAir < LastMeleeAirCost)
        {
            return;
        }

        LastMeleeHadEnoughAir = true;
        CurrentAir = Max(0.0, CurrentAir - LastMeleeAirCost);
        UpdateAirStateEffects();

        LastMeleeCalculatedDamage = DerivedStats.DebugSwordDamage
            * GetEquippedWeaponDamageScale(CaelumConstants.WEAPON_TYPE_SWORD)
            * EffectiveOffensiveDamageMultiplier;
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
        double maximumAimError = CaelumConstants.DEBUG_SWORD_BASE_INACCURACY_DEGREES
            * 100.0 / LastMeleeAccuracyPercent;
        LastMeleeYawOffset = Random[CaelumSwordAccuracyYaw](-100000, 100000)
            / 100000.0 * maximumAimError;
        LastMeleePitchOffset = Random[CaelumSwordAccuracyPitch](-100000, 100000)
            / 100000.0 * maximumAimError;
        double attackAngle = Angle + LastMeleeYawOffset;
        double attackPitch = Pitch + LastMeleePitchOffset;

        // First trace detects the actor under the crosshair without changing it.
        // Using the player's real pitch makes vertical aiming select body zones.
        Actor detectionPuff;
        int ignoredDamage;
        [detectionPuff, ignoredDamage] = LineAttack(
            attackAngle,
            CaelumConstants.DEBUG_SWORD_RANGE,
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
            (DerivedStats.PhysicalCriticalChance
                + (WeaponModel != null && WeaponModel.Equipped
                    && WeaponModel.WeaponType == CaelumConstants.WEAPON_TYPE_SWORD
                        ? 3.0 : 0.0))
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
            * GetEquippedWeaponDamageScale(CaelumConstants.WEAPON_TYPE_SWORD)
            * LastMeleeLocationMultiplier
            * EffectiveOffensiveDamageMultiplier;
        int integerDamage = Max(1, int(LastMeleeCalculatedDamage + 0.5));

        Actor puff;
        int actualDamage;
        [puff, actualDamage] = LineAttack(
            attackAngle,
            CaelumConstants.DEBUG_SWORD_RANGE,
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
            ApplyAttackPushToTarget(
                targetData.linetarget,
                attackAngle,
                DerivedStats.PhysicalPushMultiplier
            );
            AddCombatAdrenaline(
                CaelumConstants.ADRENALINE_GAIN_ON_MELEE_DAMAGE,
                CaelumConstants.ADRENALINE_EVENT_MELEE
            );
            MarkCombatActivity();
        }
    }

    // Calcula la resistencia con la masa total cuando el receptor pertenece a
    // Caelum. Para actores externos usa la masa nativa de GZDoom.
    double GetTargetKnockbackMultiplier(Actor target)
    {
        if (target == null) { return 0.0; }
        CaelumPlayer playerTarget = CaelumPlayer(target);
        if (playerTarget != null && playerTarget.DerivedStats != null)
        {
            return playerTarget.DerivedStats.KnockbackMultiplier;
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
            LastMeleeVulnerabilityGrade = combatTarget.RegisterAnatomyImpact(
                LastMeleeHitHeightRatio,
                lateralRatio
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
            CalculateAndTriggerPain(LastArmorHealthDamage, adrenalineRatioBeforeDamage);
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
            * LucidityAccuracyMultiplier;
        EffectiveMagicalAccuracyPercent = DerivedStats.MagicalAccuracyPercent
            * LucidityAccuracyMultiplier;
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
            EffectiveEvasionChance = DerivedStats.MassAdjustedEvasionChance
                * AirStatePerformanceMultiplier
                * HealthPerformanceMultiplier;
            EffectiveMovementPercent = DerivedStats.MassAdjustedMovementPercent
                * AirStatePerformanceMultiplier
                * SurvivalPerformanceMultiplier
                * HealthPerformanceMultiplier;
            EffectiveJumpHeightPercent = DerivedStats.MassAdjustedJumpHeightPercent
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

        // El personaje comienza realmente sin objetos. Las nueve recogidas se
        // distribuyen delante de él para que el inventario nativo las reciba.
        for (int slot = 0; slot < CaelumConstants.ARMOR_SLOT_COUNT; slot++)
        {
            Actor armor = Spawn(
                "CaelumArmorPickup", GetStartingPickupPosition(slot), NO_REPLACE
            );
            if (armor != null)
            {
                armor.args[0] = slot;
                armor.args[1] = armorType;
                armor.args[2] = 1;
                armor.args[3] = startingSize + 1;
            }
            ArmorModel.ArmorType[slot] =
                CaelumConstants.ARMOR_TYPE_BASE_CLOTHING;
            ArmorModel.Tier[slot] = 1;
            ArmorModel.Size[slot] = CaelumConstants.EQUIPMENT_SIZE_M;
            ArmorModel.Durability[slot] = 0;
        }

        Actor shield = Spawn(
            "CaelumShieldPickup", GetStartingPickupPosition(4), NO_REPLACE
        );
        if (shield != null)
        {
            shield.args[0] = shieldType;
            shield.args[1] = 1;
            shield.args[2] = startingSize + 1;
        }
        ShieldModel.Equipped = false;
        DebugShieldBlocking = false;

        for (int weaponType = 0;
            weaponType < CaelumConstants.WEAPON_TYPE_COUNT;
            weaponType++)
        {
            Actor weapon = Spawn(
                "CaelumWeaponPickup",
                GetStartingPickupPosition(5 + weaponType),
                NO_REPLACE
            );
            if (weapon != null)
            {
                weapon.args[0] = weaponType;
                weapon.args[1] = 1;
                weapon.args[2] = startingSize + 1;
            }
        }
        WeaponModel.Equipped = false;
        EnsureWeaponFamilySelectors();

        Inventory ammunition = Inventory(Spawn(
            "CaelumCarbineAmmo", GetStartingPickupPosition(8), NO_REPLACE
        ));
        if (ammunition != null)
        {
            ammunition.Amount = CaelumConstants.WEAPON_CARBINE_STARTING_AMMO;
        }
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
        for (int weaponType = 0;
            weaponType < CaelumConstants.WEAPON_TYPE_COUNT;
            weaponType++)
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

        if (CreationWizardPage > CaelumConstants.CREATION_PAGE_RACE)
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
