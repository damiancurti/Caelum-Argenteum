// #118: inventario nativo único; los adaptadores conservan campos y firmas.
// Cada operación recibe al propietario; esta clase no guarda estado.
class CaelumInventoryService : Object play
{
    static void SyncLiveMagicBoxOwnershipFromPersistentState(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return;
        CaelumPersistentCharacterState persistentState =
            user.GetPersistentCharacterState(true);
        if (persistentState == null)
        {
            user.MagicBoxOwned = false;
            return;
        }
        persistentState.EnsureMagicBoxOwnershipInitialized();
        user.MagicBoxOwned = persistentState.MagicBoxOwned;
        if (user.MagicBoxOwned) CaelumMagicBox.EnsureOwned(user);
    }

    static void NormalizeUnownedMagicBoxStorage(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return;
        if (user.MagicBoxOwned) { return; }
        for (Inventory cursor = user.Inv; cursor != null; cursor = cursor.Inv)
        {
            CaelumEquipmentItem equipment = CaelumEquipmentItem(cursor);
            if (equipment != null) { equipment.InMagicBox = false; }
            CaelumCarbineAmmo ammunition = CaelumCarbineAmmo(cursor);
            if (ammunition != null) { ammunition.InMagicBox = false; }
            CaelumConsumableItem consumable = CaelumConsumableItem(cursor);
            if (consumable != null) { consumable.InMagicBox = false; }
            CaelumSpecialInventoryItem special =
                CaelumSpecialInventoryItem(cursor);
            if (special != null) { special.InMagicBox = false; }
        }
    }

    static bool GrantMagicBoxFromPalomo(CaelumPlayer user, bool announce = true)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return false;
        CaelumPersistentCharacterState persistentState =
            user.GetPersistentCharacterState(true);
        if (persistentState == null) { return false; }
        persistentState.EnsureMagicBoxOwnershipInitialized();
        user.SyncLiveMagicBoxOwnershipFromPersistentState();
        if (user.MagicBoxOwned)
        {
            return false;
        }
        if (!persistentState.GrantMagicBoxOwnership())
        {
            user.MagicBoxOwned = persistentState.MagicBoxOwned;
            return false;
        }

        user.MagicBoxOwned = true;
        if (CaelumMagicBox.EnsureOwned(user) == null)
        {
            user.MagicBoxOwned = false;
            persistentState.MagicBoxOwned = false;
            return false;
        }
        user.RefreshSocialJournalSnapshot();
        user.ApplyCharacterProfile();
        user.RefreshCarriedInventorySummary();
        user.RefreshFormalInventorySnapshot();
        user.PersistCharacterState();
        user.A_StartSound("caelum/items/pickup", CHAN_6, CHANF_LOCAL);
        if (announce)
        {
            Console.Printf(
                "%s",
                StringTable.Localize("CA_PALOMO_MAGIC_BOX_RECEIVED", false)
            );
        }
        CaelumNotifications.Acquired(user, user.FindInventory("CaelumMagicBox"), 1);
        return true;
    }

    static CaelumEquipmentItem FindNativeEquipmentItem(CaelumPlayer user, int kind, int itemType, int armorSlot, int tier, int equipmentSize)
    {
        if (!CaelumPlayerAuthority.CanRead(user)) return null;
        for (Inventory cursor = user.Inv; cursor != null; cursor = cursor.Inv)
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

    static CaelumEquipmentItem FindNativeMagicWeaponItem(CaelumPlayer user, int weaponType, int essenceType, int tier, int equipmentSize)
    {
        if (!CaelumPlayerAuthority.CanRead(user)) return null;
        for (Inventory cursor = user.Inv; cursor != null; cursor = cursor.Inv)
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

    static CaelumEquipmentItem FindNativeEquipmentItemById(CaelumPlayer user, int itemId)
    {
        if (!CaelumPlayerAuthority.CanRead(user)) return null;
        if (itemId <= 0) { return null; }
        for (Inventory cursor = user.Inv; cursor != null; cursor = cursor.Inv)
        {
            CaelumEquipmentItem item = CaelumEquipmentItem(cursor);
            if (item != null && item.ItemId == itemId) { return item; }
        }
        return null;
    }

    static CaelumEquipmentItem FindOtherNativeEquipmentItemById(CaelumPlayer user, int itemId, CaelumEquipmentItem excludedItem)
    {
        if (!CaelumPlayerAuthority.CanRead(user)) return null;
        if (itemId <= 0) { return null; }
        for (Inventory cursor = user.Inv; cursor != null; cursor = cursor.Inv)
        {
            CaelumEquipmentItem item = CaelumEquipmentItem(cursor);
            if (item != null && item != excludedItem
                && item.ItemId == itemId)
            {
                return item;
            }
        }
        return null;
    }

    static int EnsureEquipmentItemId(CaelumPlayer user, CaelumEquipmentItem item)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return 0;
        if (item != null && item.Owner != null && item.Owner != user) return 0;
        if (item == null) { return 0; }
        CaelumPersistentCharacterState persistentState =
            user.GetPersistentCharacterState(true);
        if (persistentState == null) { return 0; }

        if (item.ItemId > 0)
        {
            CaelumEquipmentItem collision =
                user.FindOtherNativeEquipmentItemById(item.ItemId, item);
            if (collision == null && (!persistentState.MagicBoxOwned
                || item.ItemId != persistentState.MagicBoxItemId))
            {
                persistentState.ObserveEquipmentItemId(item.ItemId);
                return item.ItemId;
            }
            // Una pieza procedente de otro jugador puede traer un ID que ya
            // existe en este inventario. Su identidad se reasigna al entrar.
            item.ItemId = 0;
        }

        CaelumEquipmentItem allocatedCollision;
        do
        {
            item.ItemId = persistentState.AllocateEquipmentItemId();
            allocatedCollision = user.FindOtherNativeEquipmentItemById(
                item.ItemId, item
            );
        }
        while (allocatedCollision != null);
        return item.ItemId;
    }

    static void EnsureAllEquipmentItemIds(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return;
        for (Inventory cursor = user.Inv; cursor != null; cursor = cursor.Inv)
        {
            CaelumEquipmentItem item = CaelumEquipmentItem(cursor);
            if (item != null) { user.EnsureEquipmentItemId(item); }
        }
    }

    static CaelumEquipmentItem FindEquippedNativeEquipmentItem(CaelumPlayer user, int kind, int itemType, int armorSlot, int tier, int equipmentSize, int essenceType = -1)
    {
        if (!CaelumPlayerAuthority.CanRead(user)) return null;
        for (Inventory cursor = user.Inv; cursor != null; cursor = cursor.Inv)
        {
            CaelumEquipmentItem item = CaelumEquipmentItem(cursor);
            if (item == null || !item.Equipped || item.InMagicBox
                || !item.Matches(
                    kind, itemType, armorSlot, tier, equipmentSize
                ))
            {
                continue;
            }
            if (essenceType >= 0 && item.EssenceType != essenceType)
            {
                continue;
            }
            return item;
        }
        return null;
    }

    static void RepairActiveEquipmentItemReferences(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return;
        user.EnsureAllEquipmentItemIds();
        if (user.ArmorModel != null)
        {
            for (int slot = 0; slot < CaelumConstants.ARMOR_SLOT_COUNT; slot++)
            {
                CaelumEquipmentItem armor =
                    user.FindNativeEquipmentItemById(user.EquippedArmorItemId[slot]);
                if (armor == null || !armor.Equipped
                    || armor.EquipmentKind
                        != CaelumConstants.EQUIPMENT_KIND_ARMOR
                    || !armor.Matches(
                        CaelumConstants.EQUIPMENT_KIND_ARMOR,
                        user.ArmorModel.ArmorType[slot], slot,
                        user.ArmorModel.Tier[slot], user.ArmorModel.Size[slot]
                    ))
                {
                    armor = user.FindEquippedNativeEquipmentItem(
                        CaelumConstants.EQUIPMENT_KIND_ARMOR,
                        user.ArmorModel.ArmorType[slot], slot,
                        user.ArmorModel.Tier[slot], user.ArmorModel.Size[slot]
                    );
                    user.EquippedArmorItemId[slot] =
                        armor != null ? armor.ItemId : 0;
                }
            }
        }

        user.RepairActiveShieldReference();

        CaelumEquipmentItem weapon =
            user.FindNativeEquipmentItemById(user.ActiveWeaponItemId);
        if (weapon == null || !weapon.Equipped
            || user.WeaponModel == null || !weapon.Matches(
                CaelumConstants.EQUIPMENT_KIND_WEAPON,
                user.WeaponModel.WeaponType, -1,
                user.WeaponModel.Tier, user.WeaponModel.Size
            ) || (user.WeaponModel.IsMagicalType(user.WeaponModel.WeaponType)
                && weapon.EssenceType != user.WeaponModel.EssenceType))
        {
            weapon = user.WeaponModel != null && user.WeaponModel.Equipped
                ? user.FindEquippedNativeEquipmentItem(
                    CaelumConstants.EQUIPMENT_KIND_WEAPON,
                    user.WeaponModel.WeaponType, -1,
                    user.WeaponModel.Tier, user.WeaponModel.Size,
                    user.WeaponModel.IsMagicalType(user.WeaponModel.WeaponType)
                        ? user.WeaponModel.EssenceType : -1
                ) : null;
            user.ActiveWeaponItemId = weapon != null ? weapon.ItemId : 0;
        }

        CaelumEquipmentItem amulet =
            user.FindNativeEquipmentItemById(user.EquippedAmuletItemId);
        if (amulet == null || !amulet.Equipped
            || amulet.EquipmentKind != CaelumConstants.EQUIPMENT_KIND_AMULET)
        {
            user.EquippedAmuletItemId = 0;
            for (Inventory amuletCursor = user.Inv; amuletCursor != null;
                amuletCursor = amuletCursor.Inv)
            {
                CaelumEquipmentItem candidate =
                    CaelumEquipmentItem(amuletCursor);
                if (candidate != null && candidate.Equipped
                    && candidate.EquipmentKind
                        == CaelumConstants.EQUIPMENT_KIND_AMULET)
                {
                    user.EquippedAmuletItemId = candidate.ItemId;
                    break;
                }
            }
        }

        CaelumEquipmentItem seal =
            user.FindNativeEquipmentItemById(user.EquippedSealItemId);
        if (seal == null || !seal.Equipped
            || seal.EquipmentKind != CaelumConstants.EQUIPMENT_KIND_SEAL)
        {
            user.EquippedSealItemId = 0;
            for (Inventory sealCursor = user.Inv; sealCursor != null;
                sealCursor = sealCursor.Inv)
            {
                CaelumEquipmentItem candidate = CaelumEquipmentItem(sealCursor);
                if (candidate != null && candidate.Equipped
                    && candidate.EquipmentKind
                        == CaelumConstants.EQUIPMENT_KIND_SEAL)
                {
                    user.EquippedSealItemId = candidate.ItemId;
                    break;
                }
            }
        }
    }

    static bool HasEquippedNativeWeaponType(CaelumPlayer user, int weaponType)
    {
        if (!CaelumPlayerAuthority.CanRead(user)) return false;
        for (Inventory cursor = user.Inv; cursor != null; cursor = cursor.Inv)
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

    static bool HasEquippedNativeMagicWeapon(CaelumPlayer user, int weaponType, int essenceType, int tier)
    {
        if (!CaelumPlayerAuthority.CanRead(user)) return false;
        for (Inventory cursor = user.Inv; cursor != null; cursor = cursor.Inv)
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

    static bool ActivateEquippedMagicWeapon(CaelumPlayer user, int requestedWeaponType, int requestedEssenceType, int requestedTier)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return false;
        if (user.WeaponModel == null) { return false; }

        int weaponType = Clamp(
            requestedWeaponType, 0, CaelumConstants.WEAPON_TYPE_COUNT - 1
        );
        int essenceType = Clamp(
            requestedEssenceType, 0, CaelumConstants.ESSENCE_TYPE_COUNT - 1
        );
        int tier = Clamp(requestedTier, 1, 3);

        if (user.WeaponModel.Equipped
            && (user.WeaponModel.WeaponType != weaponType
                || user.WeaponModel.EssenceType != essenceType
                || user.WeaponModel.Tier != tier))
        {
            user.CancelWeaponCharge();
            if (user.CombatBlockModeActive) { user.CancelCombatBlockMode(); }
        }

        if (user.WeaponModel.Equipped
            && user.WeaponModel.WeaponType == weaponType
            && user.WeaponModel.EssenceType == essenceType
            && user.WeaponModel.Tier == tier
            && user.HasEquippedNativeMagicWeapon(weaponType, essenceType, tier))
        {
            return true;
        }

        if (user.StaffCastPending) { user.CancelPendingStaffCast(false); }

        for (Inventory cursor = user.Inv; cursor != null; cursor = cursor.Inv)
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
                user.WeaponModel.WeaponType = weaponType;
                user.WeaponModel.Tier = tier;
                user.WeaponModel.Size = item.EquipmentSize;
                user.WeaponModel.Durability = item.Durability;
                user.WeaponModel.EssenceType = essenceType;
                user.SelectedEssenceType = essenceType;
                user.WeaponModel.Equipped = true;
                user.ActiveWeaponItemId = item.ItemId;
                user.EquippedWeaponCooldownRemaining = 0.0;
                user.ApplyCharacterProfile();
                user.PersistCharacterState();
                user.RefreshEquipmentSelectionPreview();
                return true;
            }
        }
        return false;
    }

    static int CountNativeMagicBoxSlots(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanRead(user)) return 0;
        if (!user.MagicBoxOwned) { return 0; }
        int total = 0;
        for (Inventory cursor = user.Inv; cursor != null; cursor = cursor.Inv)
        {
            CaelumEquipmentItem item = CaelumEquipmentItem(cursor);
            if (item != null && item.InMagicBox) { total++; }
        }
        for (Inventory cursor = user.Inv; cursor != null; cursor = cursor.Inv)
        {
            CaelumCarbineAmmo ammunition = CaelumCarbineAmmo(cursor);
            if (ammunition != null && ammunition.Amount > 0
                && ammunition.InMagicBox)
            {
                total++;
            }
        }
        for (Inventory cursor = user.Inv; cursor != null; cursor = cursor.Inv)
        {
            CaelumConsumableItem consumable = CaelumConsumableItem(cursor);
            if (consumable != null && consumable.Amount > 0
                && consumable.InMagicBox)
            {
                total++;
            }
        }
        for (Inventory cursor = user.Inv; cursor != null; cursor = cursor.Inv)
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

    static int GetMagicBoxWeightDivisor(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanRead(user)) return 1;
        if (!user.MagicBoxOwned || user.DerivedStats == null) { return 1; }
        return Max(1, user.DerivedStats.MagicBoxCapacity);
    }

    static double CalculateMagicBoxReducedContentWeight(CaelumPlayer user, double rawContentWeight)
    {
        if (!CaelumPlayerAuthority.CanRead(user)) return 0;
        if (!user.MagicBoxOwned) { return 0.0; }
        double precision = CaelumConstants.MAGIC_BOX_WEIGHT_PRECISION;
        double reducedWeight = Max(0.0, rawContentWeight)
            / user.GetMagicBoxWeightDivisor();
        return Floor(reducedWeight / precision + 0.0000001) * precision;
    }

    static double CalculateMagicBoxTotalWeight(CaelumPlayer user, double rawContentWeight)
    {
        if (!CaelumPlayerAuthority.CanRead(user)) return 0;
        if (!user.MagicBoxOwned) { return 0.0; }
        return CaelumConstants.MAGIC_BOX_BASE_WEIGHT
            + user.CalculateMagicBoxReducedContentWeight(rawContentWeight);
    }

    static bool CanApplyInventoryWeightTransition(CaelumPlayer user, double personalDelta, double boxRawDelta)
    {
        if (!CaelumPlayerAuthority.CanRead(user)) return false;
        if (user.DerivedStats == null) { return false; }
        if (!user.MagicBoxOwned && boxRawDelta > 0.0) { return false; }
        double projectedRawWeight = Max(
            0.0, user.HUDMagicBoxRawContentWeight + boxRawDelta
        );
        double projectedCarriedWeight = user.DerivedStats.CarriedWeight
            + personalDelta
            + user.CalculateMagicBoxTotalWeight(projectedRawWeight)
            - user.HUDMagicBoxTotalWeight;
        return projectedCarriedWeight
            <= user.DerivedStats.CarryCapacity + 0.0005;
    }

    static bool CanAddRawWeightToMagicBox(CaelumPlayer user, double rawWeight)
    {
        if (!CaelumPlayerAuthority.CanRead(user)) return false;
        if (!user.MagicBoxOwned) { return false; }
        return user.CanApplyInventoryWeightTransition(
            0.0, Max(0.0, rawWeight)
        );
    }

    static bool CanMoveRawWeightFromMagicBoxToPersonal(CaelumPlayer user, double rawWeight)
    {
        if (!CaelumPlayerAuthority.CanRead(user)) return false;
        if (!user.MagicBoxOwned) { return false; }
        double resolvedWeight = Max(0.0, rawWeight);
        return user.CanApplyInventoryWeightTransition(
            resolvedWeight, -resolvedWeight
        );
    }

    static bool CanMovePersonalStackWithIncomingToMagicBox(CaelumPlayer user, double existingRawWeight, double incomingRawWeight)
    {
        if (!CaelumPlayerAuthority.CanRead(user)) return false;
        double existingWeight = Max(0.0, existingRawWeight);
        double incomingWeight = Max(0.0, incomingRawWeight);
        return user.CanApplyInventoryWeightTransition(
            -existingWeight, existingWeight + incomingWeight
        );
    }

    static bool HasNativeMagicBoxSlotAvailable(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanRead(user)) return false;
        if (!user.MagicBoxOwned || user.DerivedStats == null) { return false; }
        int reserved = user.CraftingTaskCompleting
            ? 0 : user.CraftingTaskReservedBoxSlots;
        return user.CountNativeMagicBoxSlots() + reserved
            < user.DerivedStats.MagicBoxCapacity;
    }

    static CaelumConsumableItem FindNativeConsumableItem(CaelumPlayer user, int consumableType)
    {
        if (!CaelumPlayerAuthority.CanRead(user)) return null;
        for (Inventory cursor = user.Inv; cursor != null; cursor = cursor.Inv)
        {
            CaelumConsumableItem item = CaelumConsumableItem(cursor);
            if (item != null && item.GetConsumableType() == consumableType)
            {
                return item;
            }
        }
        return null;
    }

    static Inventory FindNativeAmmunition(CaelumPlayer user, int ammunitionType)
    {
        if (!CaelumPlayerAuthority.CanRead(user)) return null;
        if (ammunitionType == CaelumConstants.AMMUNITION_ARROW)
        {
            return user.FindInventory("CaelumArrowAmmo");
        }
        if (ammunitionType == CaelumConstants.AMMUNITION_BOLT)
        {
            return user.FindInventory("CaelumBoltAmmo");
        }
        return user.FindInventory("CaelumCarbineAmmo");
    }

    static bool AcquireJavelinAmmunition(CaelumPlayer user, int ammunitionType, int incomingAmount)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return false;
        if (incomingAmount <= 0 || user.DerivedStats == null) { return false; }

        CaelumCarbineAmmo existing = CaelumCarbineAmmo(
            user.FindNativeAmmunition(ammunitionType)
        );
        bool storeInMagicBox = existing != null && existing.InMagicBox;

        if (existing != null)
        {
            if (!user.PrepareNativeAmmoStackPickup(existing, incomingAmount))
            {
                return false;
            }
            storeInMagicBox = existing.InMagicBox;
        }
        else
        {
            user.RefreshCarriedInventorySummary();
            double incomingWeight = incomingAmount
                * user.GetAmmunitionUnitWeight(ammunitionType);
            if (!user.CanAddWeightToPersonalInventory(incomingWeight))
            {
                if (!user.HasNativeMagicBoxSlotAvailable()
                    || !user.CanAddRawWeightToMagicBox(incomingWeight))
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
            Name ammoClass = user.GetAmmunitionClassName(ammunitionType);
            result = CaelumCarbineAmmo(Actor.Spawn(ammoClass, user.Pos, NO_REPLACE));
            if (result == null) { return false; }

            // La clase nace con Amount 1. Sustituimos ese valor por la cantidad
            // que realmente entra antes de adjuntarla al inventario del jugador.
            result.Amount = incomingAmount;
            user.AddInventory(result);
            createdNewStack = true;
        }

        if (result == null || result.Amount <= 0) { return false; }
        result.InMagicBox = storeInMagicBox;
        user.LastEquipmentPickupWasNew = createdNewStack;
        user.LastEquipmentPickupWentToMagicBox = storeInMagicBox;
        user.OnNativeInventoryChanged();
        CaelumNotifications.Acquired(user, result, incomingAmount);
        return true;
    }

    static CaelumSpecialInventoryItem FindNativeSpecialItem(CaelumPlayer user, int specialCategory, int specialType, int specialTier = 0)
    {
        if (!CaelumPlayerAuthority.CanRead(user)) return null;
        for (Inventory cursor = user.Inv; cursor != null; cursor = cursor.Inv)
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

    static CaelumCurrencyItem FindNativeCurrency(CaelumPlayer user, int currencyType)
    {
        if (!CaelumPlayerAuthority.CanRead(user)) return null;
        return CaelumCurrencyItem(user.FindNativeSpecialItem(
            CaelumConstants.EQUIPMENT_KIND_CURRENCY,
            CaelumEconomyRules.ResolveCurrencyType(currencyType)
        ));
    }

    static int GetOwnedCurrencyAmount(CaelumPlayer user, int currencyType)
    {
        if (!CaelumPlayerAuthority.CanRead(user)) return 0;
        CaelumCurrencyItem currency = user.FindNativeCurrency(currencyType);
        return currency != null ? Max(0, currency.Amount) : 0;
    }

    static double GetOwnedMoneyCopperValue(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanRead(user)) return 0;
        double totalValue = 0.0;
        for (int currencyType = 0;
            currencyType < CaelumConstants.CURRENCY_TYPE_COUNT;
            currencyType++)
        {
            totalValue += double(user.GetOwnedCurrencyAmount(currencyType))
                * CaelumEconomyRules.GetCurrencyFaceValue(currencyType);
        }
        return totalValue;
    }

    static Inventory FindPalomoMerchantProduct(CaelumPlayer user, int merchantItem)
    {
        if (!CaelumPlayerAuthority.CanRead(user)) return null;
        int consumableType = user.GetPalomoMerchantConsumableType(merchantItem);
        if (consumableType >= 0)
        { return user.FindNativeConsumableItem(consumableType); }
        int materialType = user.GetPalomoMerchantMaterialType(merchantItem);
        if (materialType < 0) { return null; }
        return user.FindNativeSpecialItem(
            CaelumConstants.EQUIPMENT_KIND_MATERIAL, materialType,
            CaelumMaterialRules.ResolveTier(materialType, 1));
    }

    static bool IsPalomoMerchantProductInMagicBox(CaelumPlayer user, Inventory product)
    {
        CaelumConsumableItem consumable = CaelumConsumableItem(product);
        if (consumable != null) { return consumable.InMagicBox; }
        CaelumSpecialInventoryItem special = CaelumSpecialInventoryItem(product);
        return special != null && special.InMagicBox;
    }

    static int CountPalomoMerchantProduct(CaelumPlayer user, int merchantItem, bool includeReserved)
    {
        if (!CaelumPlayerAuthority.CanRead(user)) return 0;
        int consumableType = user.GetPalomoMerchantConsumableType(merchantItem);
        if (consumableType >= 0)
        {
            CaelumConsumableItem consumable = user.FindNativeConsumableItem(consumableType);
            return consumable != null ? Max(0, consumable.Amount) : 0;
        }
        int materialType = user.GetPalomoMerchantMaterialType(merchantItem);
        if (materialType < 0) { return 0; }
        int tier = CaelumMaterialRules.ResolveTier(materialType, 1);
        return includeReserved ? user.CountRawCraftingMaterial(materialType, tier)
            : user.CountCraftingMaterial(materialType, tier);
    }

    static double GetPalomoMerchantProductUnitWeight(CaelumPlayer user, int merchantItem)
    {
        if (!CaelumPlayerAuthority.CanRead(user)) return 0;
        return user.GetPalomoMerchantConsumableType(merchantItem) >= 0
            ? CaelumConsumableItem.UnitWeightForType(user.GetPalomoMerchantConsumableType(merchantItem))
            : CaelumConstants.MATERIAL_UNIT_WEIGHT;
    }

    static void ResetPalomoCurrencyPlan(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return;
        for (int currencyType = 0;
            currencyType < CaelumConstants.CURRENCY_TYPE_COUNT; currencyType++)
        {
            CaelumCurrencyItem existing = user.FindNativeCurrency(currencyType);
            user.PalomoCurrencyPlanAmount[currencyType] = existing != null
                ? Max(0, existing.Amount) : 0;
            user.PalomoCurrencyPlanInMagicBox[currencyType] = existing != null
                && existing.InMagicBox;
        }
    }

    static bool BuildPalomoCurrencyPaymentPlan(CaelumPlayer user, int copperAmount)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return false;
        if (copperAmount < 0
            || user.GetOwnedMoneyCopperValue() + 0.0001 < copperAmount)
        { return false; }
        user.ResetPalomoCurrencyPlan();
        int remaining = copperAmount;
        for (int currencyType = CaelumConstants.CURRENCY_TYPE_COUNT - 1;
            currencyType >= 0 && remaining > 0; currencyType--)
        {
            int faceValue = CaelumEconomyRules.GetCurrencyFaceValue(currencyType);
            int take = Min(user.PalomoCurrencyPlanAmount[currencyType],
                remaining / faceValue);
            user.PalomoCurrencyPlanAmount[currencyType] -= take;
            remaining -= take * faceValue;
        }

        int change = 0;
        if (remaining > 0)
        {
            for (int currencyType = 0;
                currencyType < CaelumConstants.CURRENCY_TYPE_COUNT; currencyType++)
            {
                int faceValue = CaelumEconomyRules.GetCurrencyFaceValue(currencyType);
                if (user.PalomoCurrencyPlanAmount[currencyType] <= 0
                    || faceValue <= remaining) { continue; }
                user.PalomoCurrencyPlanAmount[currencyType]--;
                change = faceValue - remaining;
                remaining = 0;
                break;
            }
        }
        if (remaining > 0) { return false; }
        for (int currencyType = CaelumConstants.CURRENCY_TYPE_COUNT - 1;
            currencyType >= 0 && change > 0; currencyType--)
        {
            int faceValue = CaelumEconomyRules.GetCurrencyFaceValue(currencyType);
            int returnedCoins = change / faceValue;
            user.PalomoCurrencyPlanAmount[currencyType] += returnedCoins;
            change -= returnedCoins * faceValue;
        }
        return change == 0;
    }

    static bool BuildPalomoCurrencyCreditPlan(CaelumPlayer user, int copperAmount)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return false;
        if (copperAmount < 0) { return false; }
        user.ResetPalomoCurrencyPlan();
        int remaining = copperAmount;
        for (int currencyType = CaelumConstants.CURRENCY_TYPE_COUNT - 1;
            currencyType >= 0 && remaining > 0; currencyType--)
        {
            int faceValue = CaelumEconomyRules.GetCurrencyFaceValue(currencyType);
            int addedCoins = remaining / faceValue;
            if (addedCoins <= 0) { continue; }
            if (user.PalomoCurrencyPlanAmount[currencyType]
                > 2147483647 - addedCoins) { return false; }
            user.PalomoCurrencyPlanAmount[currencyType] += addedCoins;
            remaining -= addedCoins * faceValue;
        }
        return remaining == 0;
    }

    static void RoutePalomoCurrencyGainsToMagicBox(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return;
        if (!user.MagicBoxOwned) { return; }
        for (int currencyType = 0;
            currencyType < CaelumConstants.CURRENCY_TYPE_COUNT; currencyType++)
        {
            if (user.PalomoCurrencyPlanAmount[currencyType]
                > user.GetOwnedCurrencyAmount(currencyType))
            { user.PalomoCurrencyPlanInMagicBox[currencyType] = true; }
        }
    }

    static double GetPalomoCurrencyPlanPersonalWeightDelta(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanRead(user)) return 0;
        double delta = 0.0;
        for (int currencyType = 0;
            currencyType < CaelumConstants.CURRENCY_TYPE_COUNT; currencyType++)
        {
            CaelumCurrencyItem existing = user.FindNativeCurrency(currencyType);
            int oldAmount = existing != null ? Max(0, existing.Amount) : 0;
            if (existing != null && !existing.InMagicBox)
            { delta -= oldAmount * CaelumConstants.CURRENCY_UNIT_WEIGHT; }
            if (user.PalomoCurrencyPlanAmount[currencyType] > 0
                && !user.PalomoCurrencyPlanInMagicBox[currencyType])
            { delta += user.PalomoCurrencyPlanAmount[currencyType]
                    * CaelumConstants.CURRENCY_UNIT_WEIGHT; }
        }
        return delta;
    }

    static double GetPalomoCurrencyPlanBoxRawWeightDelta(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanRead(user)) return 0;
        double delta = 0.0;
        for (int currencyType = 0;
            currencyType < CaelumConstants.CURRENCY_TYPE_COUNT; currencyType++)
        {
            CaelumCurrencyItem existing = user.FindNativeCurrency(currencyType);
            int oldAmount = existing != null ? Max(0, existing.Amount) : 0;
            if (existing != null && existing.InMagicBox)
            { delta -= oldAmount * CaelumConstants.CURRENCY_UNIT_WEIGHT; }
            if (user.PalomoCurrencyPlanAmount[currencyType] > 0
                && user.PalomoCurrencyPlanInMagicBox[currencyType])
            { delta += user.PalomoCurrencyPlanAmount[currencyType]
                    * CaelumConstants.CURRENCY_UNIT_WEIGHT; }
        }
        return delta;
    }

    static int GetPalomoCurrencyPlanBoxSlotDelta(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanRead(user)) return 0;
        int delta = 0;
        for (int currencyType = 0;
            currencyType < CaelumConstants.CURRENCY_TYPE_COUNT; currencyType++)
        {
            CaelumCurrencyItem existing = user.FindNativeCurrency(currencyType);
            bool oldSlot = existing != null && existing.Amount > 0
                && existing.InMagicBox;
            bool newSlot = user.PalomoCurrencyPlanAmount[currencyType] > 0
                && user.PalomoCurrencyPlanInMagicBox[currencyType];
            if (oldSlot && !newSlot) { delta--; }
            else if (!oldSlot && newSlot) { delta++; }
        }
        return delta;
    }

    static bool PalomoTransactionCapacityFits(CaelumPlayer user, double personalDelta, double boxRawDelta, int boxSlotDelta)
    {
        if (!CaelumPlayerAuthority.CanRead(user)) return false;
        if (!user.MagicBoxOwned && (boxRawDelta > 0.0 || boxSlotDelta > 0))
        { return false; }
        int currentSlots = user.CountNativeMagicBoxSlots()
            + (user.CraftingTaskCompleting ? 0 : user.CraftingTaskReservedBoxSlots);
        int projectedSlots = currentSlots + boxSlotDelta;
        int maximumSlots = user.MagicBoxOwned && user.DerivedStats != null
            ? Max(0, user.DerivedStats.MagicBoxCapacity) : 0;
        if (projectedSlots > maximumSlots && projectedSlots > currentSlots)
        { return false; }
        return user.CanApplyInventoryWeightTransition(personalDelta, boxRawDelta);
    }

    static bool PreparePalomoPurchaseCapacity(CaelumPlayer user, int merchantItem, int quantity, int price)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return false;
        Inventory product = user.FindPalomoMerchantProduct(merchantItem);
        bool productAlreadyBoxed = user.IsPalomoMerchantProductInMagicBox(product);
        double unitWeight = user.GetPalomoMerchantProductUnitWeight(merchantItem);
        for (int currencyRoute = 0; currencyRoute < 2; currencyRoute++)
        {
            if (!user.BuildPalomoCurrencyPaymentPlan(price)) { return false; }
            if (currencyRoute == 1)
            {
                if (!user.MagicBoxOwned) { continue; }
                user.RoutePalomoCurrencyGainsToMagicBox();
            }
            for (int productRoute = 0; productRoute < 2; productRoute++)
            {
                bool sendProductToBox = productAlreadyBoxed || productRoute == 1;
                if (sendProductToBox && !user.MagicBoxOwned) { continue; }
                if (productAlreadyBoxed && productRoute == 1) { continue; }
                double personalDelta = user.GetPalomoCurrencyPlanPersonalWeightDelta();
                double boxRawDelta = user.GetPalomoCurrencyPlanBoxRawWeightDelta();
                int boxSlotDelta = user.GetPalomoCurrencyPlanBoxSlotDelta();
                double incomingWeight = quantity * unitWeight;
                if (product == null)
                {
                    if (sendProductToBox)
                    { boxRawDelta += incomingWeight; boxSlotDelta++; }
                    else { personalDelta += incomingWeight; }
                }
                else if (productAlreadyBoxed) { boxRawDelta += incomingWeight; }
                else if (sendProductToBox)
                {
                    double oldWeight = Max(0, product.Amount) * unitWeight;
                    personalDelta -= oldWeight;
                    boxRawDelta += oldWeight + incomingWeight;
                    boxSlotDelta++;
                }
                else { personalDelta += incomingWeight; }
                if (user.PalomoTransactionCapacityFits(
                    personalDelta, boxRawDelta, boxSlotDelta))
                {
                    user.PalomoIncomingItemInMagicBox = sendProductToBox;
                    return true;
                }
            }
        }
        return false;
    }

    static bool PreparePalomoSaleCapacity(CaelumPlayer user, int merchantItem, int quantity, int price)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return false;
        Inventory product = user.FindPalomoMerchantProduct(merchantItem);
        if (product == null || product.Amount < quantity) { return false; }
        bool productBoxed = user.IsPalomoMerchantProductInMagicBox(product);
        double removedWeight = quantity
            * user.GetPalomoMerchantProductUnitWeight(merchantItem);
        for (int currencyRoute = 0; currencyRoute < 2; currencyRoute++)
        {
            if (!user.BuildPalomoCurrencyCreditPlan(price)) { return false; }
            if (currencyRoute == 1)
            {
                if (!user.MagicBoxOwned) { continue; }
                user.RoutePalomoCurrencyGainsToMagicBox();
            }
            double personalDelta = user.GetPalomoCurrencyPlanPersonalWeightDelta();
            double boxRawDelta = user.GetPalomoCurrencyPlanBoxRawWeightDelta();
            int boxSlotDelta = user.GetPalomoCurrencyPlanBoxSlotDelta();
            if (productBoxed)
            {
                boxRawDelta -= removedWeight;
                if (product.Amount == quantity) { boxSlotDelta--; }
            }
            else { personalDelta -= removedWeight; }
            if (user.PalomoTransactionCapacityFits(
                personalDelta, boxRawDelta, boxSlotDelta)) { return true; }
        }
        return false;
    }

    static bool ApplyPalomoCurrencyPlan(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return false;
        for (int currencyType = 0;
            currencyType < CaelumConstants.CURRENCY_TYPE_COUNT; currencyType++)
        {
            CaelumCurrencyItem existing = user.FindNativeCurrency(currencyType);
            int previousAmount=existing==null ? 0 : existing.Amount;
            int finalAmount = user.PalomoCurrencyPlanAmount[currencyType];
            if (finalAmount <= 0)
            {
                if (existing != null) { existing.Destroy(); }
                continue;
            }
            if (existing == null)
            {
                existing = CaelumCurrencyItem(Actor.Spawn(
                    CaelumEconomyRules.GetCurrencyClassName(currencyType),
                    user.Pos, NO_REPLACE));
                if (existing == null) { return false; }
                existing.Amount = finalAmount;
                existing.InMagicBox = user.PalomoCurrencyPlanInMagicBox[currencyType];
                existing.AttachToOwner(user);
            }
            else
            {
                existing.Amount = finalAmount;
                existing.InMagicBox = user.PalomoCurrencyPlanInMagicBox[currencyType];
            }
            CaelumNotifications.Acquired(user, existing, finalAmount-previousAmount);
        }
        return true;
    }

    static bool AddPalomoMerchantProduct(CaelumPlayer user, int merchantItem, int quantity)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return false;
        Inventory existing = user.FindPalomoMerchantProduct(merchantItem);
        if (existing != null)
        {
            existing.Amount += quantity;
            CaelumConsumableItem consumable = CaelumConsumableItem(existing);
            if (consumable != null)
            { consumable.InMagicBox = user.PalomoIncomingItemInMagicBox; }
            CaelumSpecialInventoryItem special = CaelumSpecialInventoryItem(existing);
            if (special != null)
            { special.InMagicBox = user.PalomoIncomingItemInMagicBox; }
            CaelumNotifications.Acquired(user, existing, quantity);
            return true;
        }
        int consumableType = user.GetPalomoMerchantConsumableType(merchantItem);
        if (consumableType >= 0)
        {
            CaelumConsumableItem created = CaelumConsumableItem(Actor.Spawn(
                user.GetConsumableClassName(consumableType), user.Pos, NO_REPLACE));
            if (created == null) { return false; }
            created.Amount = quantity;
            created.InMagicBox = user.PalomoIncomingItemInMagicBox;
            created.AttachToOwner(user);
            CaelumNotifications.Acquired(user, created, quantity);
            return true;
        }
        int materialType = user.GetPalomoMerchantMaterialType(merchantItem);
        if (materialType < 0) { return false; }
        CaelumMaterialPickup material = CaelumMaterialPickup(
            Actor.Spawn("CaelumMaterialPickup", user.Pos, NO_REPLACE));
        if (material == null) { return false; }
        material.args[0] = materialType;
        material.args[1] = CaelumMaterialRules.ResolveTier(materialType, 1);
        material.Amount = quantity;
        material.InMagicBox = user.PalomoIncomingItemInMagicBox;
        material.AttachToOwner(user);
        CaelumNotifications.Acquired(user, material, quantity);
        return true;
    }

    static bool RemovePalomoMerchantProduct(CaelumPlayer user, int merchantItem, int quantity)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return false;
        Inventory product = user.FindPalomoMerchantProduct(merchantItem);
        if (product == null || product.Amount < quantity) { return false; }
        product.Amount -= quantity;
        if (product.Amount <= 0) { product.Destroy(); }
        return true;
    }

    static CaelumWeightedKey FindNativeKey(CaelumPlayer user, int keyType)
    {
        if (!CaelumPlayerAuthority.CanRead(user)) return null;
        for (Inventory cursor = user.Inv; cursor != null; cursor = cursor.Inv)
        {
            CaelumWeightedKey keyItem = CaelumWeightedKey(cursor);
            if (keyItem != null && keyItem.GetKeyType() == keyType)
            {
                return keyItem;
            }
        }
        return null;
    }

    static bool PrepareNativeEquipmentPickup(CaelumPlayer user, CaelumEquipmentItem item)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return false;
        if (item != null && item.Owner != null && item.Owner != user) return false;
        if (item == null || user.DerivedStats == null) { return false; }
        user.RefreshCarriedInventorySummary();
        item.Equipped = false;
        item.InMagicBox = false;
        if (!user.CanAddWeightToPersonalInventory(item.UnitWeight))
        {
            if (!user.HasNativeMagicBoxSlotAvailable()
                || !user.CanAddRawWeightToMagicBox(item.UnitWeight))
            {
                return false;
            }
            item.InMagicBox = true;
        }
        // Sólo una transferencia con capacidad disponible reserva identidad.
        if (user.EnsureEquipmentItemId(item) <= 0) { return false; }
        user.LastEquipmentPickupWasNew = true;
        user.LastEquipmentPickupWentToMagicBox = item.InMagicBox;
        return true;
    }

    static bool PrepareNativeAmmoPickup(CaelumPlayer user, CaelumCarbineAmmo ammunition)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return false;
        if (ammunition != null && ammunition.Owner != null && ammunition.Owner != user) return false;
        if (ammunition == null || user.DerivedStats == null) { return false; }
        // Si ya existe una pila, HandlePickup decide usando el estado de ella.
        for (Inventory cursor = user.Inv; cursor != null; cursor = cursor.Inv)
        {
            CaelumCarbineAmmo existing = CaelumCarbineAmmo(cursor);
            if (existing != null
                && existing.GetAmmoType() == ammunition.GetAmmoType())
            {
                return true;
            }
        }
        user.RefreshCarriedInventorySummary();
        ammunition.InMagicBox = false;
        double incomingWeight = ammunition.Amount * ammunition.GetUnitWeight();
        if (!user.CanAddWeightToPersonalInventory(incomingWeight))
        {
            if (!user.HasNativeMagicBoxSlotAvailable()
                || !user.CanAddRawWeightToMagicBox(incomingWeight))
            {
                return false;
            }
            ammunition.InMagicBox = true;
        }
        user.LastEquipmentPickupWasNew = true;
        user.LastEquipmentPickupWentToMagicBox = ammunition.InMagicBox;
        return true;
    }

    static bool PrepareNativeAmmoStackPickup(CaelumPlayer user, CaelumCarbineAmmo ammunition, int incomingAmount)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return false;
        if (ammunition != null && ammunition.Owner != user) return false;
        if (ammunition == null || user.DerivedStats == null) { return false; }
        user.RefreshCarriedInventorySummary();
        double incomingWeight = Max(0, incomingAmount)
            * ammunition.GetUnitWeight();
        if (ammunition.InMagicBox)
        {
            return user.CanAddRawWeightToMagicBox(incomingWeight);
        }
        if (user.CanAddWeightToPersonalInventory(incomingWeight)) { return true; }
        if (!user.HasNativeMagicBoxSlotAvailable())
        {
            return false;
        }
        double existingWeight = ammunition.Amount
            * ammunition.GetUnitWeight();
        if (!user.CanMovePersonalStackWithIncomingToMagicBox(
                existingWeight, incomingWeight
            ))
        {
            return false;
        }
        // La munición es una sola pila: al desbordar, la pila completa pasa a
        // ocupar un slot y participa del peso agregado reducido de la caja.
        ammunition.InMagicBox = true;
        user.LastEquipmentPickupWentToMagicBox = true;
        return true;
    }

    static bool PrepareNativeConsumablePickup(CaelumPlayer user, CaelumConsumableItem consumable)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return false;
        if (consumable != null && consumable.Owner != null && consumable.Owner != user) return false;
        if (consumable == null || user.DerivedStats == null) { return false; }
        CaelumConsumableItem existing = user.FindNativeConsumableItem(
            consumable.GetConsumableType()
        );
        if (existing != null)
        {
            return user.PrepareNativeConsumableStackPickup(
                existing, consumable.Amount
            );
        }
        user.RefreshCarriedInventorySummary();
        consumable.InMagicBox = false;
        if (!user.CanAddWeightToPersonalInventory(consumable.GetCarriedWeight()))
        {
            double incomingWeight = consumable.Amount
                * consumable.GetUnitWeight();
            if (!user.HasNativeMagicBoxSlotAvailable()
                || !user.CanAddRawWeightToMagicBox(incomingWeight))
            {
                return false;
            }
            consumable.InMagicBox = true;
        }
        user.LastEquipmentPickupWasNew = true;
        user.LastEquipmentPickupWentToMagicBox = consumable.InMagicBox;
        return true;
    }

    static bool PrepareNativeConsumableStackPickup(CaelumPlayer user, CaelumConsumableItem consumable, int incomingAmount)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return false;
        if (consumable != null && consumable.Owner != user) return false;
        if (consumable == null || user.DerivedStats == null) { return false; }
        user.RefreshCarriedInventorySummary();
        double incomingWeight = Max(0, incomingAmount)
            * consumable.GetUnitWeight();
        if (consumable.InMagicBox)
        {
            return user.CanAddRawWeightToMagicBox(incomingWeight);
        }
        if (user.CanAddWeightToPersonalInventory(incomingWeight)) { return true; }
        if (!user.HasNativeMagicBoxSlotAvailable())
        {
            return false;
        }
        double existingWeight = consumable.Amount
            * consumable.GetUnitWeight();
        if (!user.CanMovePersonalStackWithIncomingToMagicBox(
                existingWeight, incomingWeight
            ))
        {
            return false;
        }
        // Una pila completa ocupa un único slot, sin importar su Amount, y su
        // peso real entra una sola vez en el cálculo agregado de la caja.
        consumable.InMagicBox = true;
        user.LastEquipmentPickupWentToMagicBox = true;
        return true;
    }

    static bool PrepareNativeSpecialPickup(CaelumPlayer user, CaelumSpecialInventoryItem specialItem)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return false;
        if (specialItem != null && specialItem.Owner != null && specialItem.Owner != user) return false;
        if (specialItem == null || user.DerivedStats == null) { return false; }
        CaelumSpecialInventoryItem existing = user.FindNativeSpecialItem(
            specialItem.GetSpecialCategory(), specialItem.GetSpecialType(),
            specialItem.GetSpecialTier()
        );
        if (existing != null)
        {
            if (specialItem.GetSpecialCategory()
                    == CaelumConstants.EQUIPMENT_KIND_MATERIAL
                || specialItem.GetSpecialCategory()
                    == CaelumConstants.EQUIPMENT_KIND_CURRENCY)
            {
                return user.PrepareNativeSpecialStackPickup(
                    existing, specialItem.Amount
                );
            }
            return true;
        }
        user.RefreshCarriedInventorySummary();
        specialItem.InMagicBox = false;
        if (!user.CanAddWeightToPersonalInventory(specialItem.GetCarriedWeight()))
        {
            double incomingWeight = specialItem.Amount
                * specialItem.GetUnitWeight();
            if (!user.HasNativeMagicBoxSlotAvailable()
                || !user.CanAddRawWeightToMagicBox(incomingWeight))
            {
                return false;
            }
            specialItem.InMagicBox = true;
        }
        user.LastEquipmentPickupWasNew = true;
        user.LastEquipmentPickupWentToMagicBox = specialItem.InMagicBox;
        return true;
    }

    static bool PrepareNativeSpecialStackPickup(CaelumPlayer user, CaelumSpecialInventoryItem specialItem, int incomingAmount)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return false;
        if (specialItem != null && specialItem.Owner != user) return false;
        if (specialItem == null || user.DerivedStats == null) { return false; }
        user.RefreshCarriedInventorySummary();
        double incomingWeight = Max(0, incomingAmount)
            * specialItem.GetUnitWeight();
        if (specialItem.InMagicBox)
        {
            return user.CanAddRawWeightToMagicBox(incomingWeight);
        }
        if (user.CanAddWeightToPersonalInventory(incomingWeight)) { return true; }
        if (!user.HasNativeMagicBoxSlotAvailable())
        {
            return false;
        }
        double existingWeight = specialItem.Amount
            * specialItem.GetUnitWeight();
        if (!user.CanMovePersonalStackWithIncomingToMagicBox(
                existingWeight, incomingWeight
            ))
        {
            return false;
        }
        specialItem.InMagicBox = true;
        user.LastEquipmentPickupWentToMagicBox = true;
        return true;
    }

    static bool PrepareNativeKeyPickup(CaelumPlayer user, CaelumWeightedKey keyItem)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return false;
        if (keyItem != null && keyItem.Owner != null && keyItem.Owner != user) return false;
        if (keyItem == null || user.DerivedStats == null) { return false; }
        // Key ya impide duplicados por clase. Si existe, el pickup nativo
        // decide el resultado sin reservar peso otra vez.
        if (user.FindNativeKey(keyItem.GetKeyType()) != null) { return true; }
        user.RefreshCarriedInventorySummary();
        if (!user.CanAddWeightToPersonalInventory(keyItem.GetCarriedWeight()))
        {
            return false;
        }
        user.LastEquipmentPickupWasNew = true;
        user.LastEquipmentPickupWentToMagicBox = false;
        return true;
    }

    static void OnNativeInventoryChanged(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return;
        user.ApplyCharacterProfile();
        user.RefreshEquipmentSelectionPreview();
        user.RefreshFormalInventorySnapshot();
        if (user.PalomoMerchantMenuOpen) { user.RefreshPalomoMerchantSnapshot(); }
        if (user.CraftingMenuOpen) { user.RefreshCraftingPreview(); }
        if (user.CraftingBrowser != null) user.CraftingBrowser.Refresh(user);
        user.PersistCharacterState();
    }

    static void OnNativeEquipmentPickedUp(CaelumPlayer user, int pickedItemId, int pickedKind, int pickedType, int pickedTier, int pickedSize, int pickedEssence, bool pickedIntoMagicBox)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return;
        user.ApplyCharacterProfile();
        user.RefreshEquipmentSelectionPreview();

        if (pickedKind != CaelumConstants.EQUIPMENT_KIND_WEAPON
            || pickedIntoMagicBox
            || user.CharacterProfile == null
            || !CaelumEquipmentRules.IsSizeCompatible(
                pickedSize,
                user.CharacterProfile.GetSizeTier()
            ))
        {
            if (user.CraftingMenuOpen) { user.RefreshCraftingPreview(); }
            user.PersistCharacterState();
            return;
        }

        user.EquipmentSelectionKind = CaelumConstants.EQUIPMENT_KIND_WEAPON;
        user.EquipmentSelectionItemId = pickedItemId;
        user.EquipmentSelectionWeaponType = Clamp(
            pickedType, 0, CaelumConstants.WEAPON_TYPE_COUNT - 1
        );
        user.EquipmentSelectionTier = Clamp(pickedTier, 1, 3);
        user.EquipmentSelectionSize = Clamp(
            pickedSize, 0, CaelumConstants.EQUIPMENT_SIZE_COUNT - 1
        );
        user.EquipmentSelectionWeaponEssenceType = Clamp(
            pickedEssence, 0, CaelumConstants.ESSENCE_TYPE_COUNT - 1
        );
        user.RefreshEquipmentSelectionPreview();

        CaelumEquipmentItem pickedItem = user.GetSelectedNativeEquipmentItem();
        if (pickedItem != null && !pickedItem.InMagicBox)
        {
            user.EquipSelectedNativeEquipment();
            user.SelectNativeWeaponConfiguration(
                pickedType, pickedEssence, pickedTier
            );
        }
        else
        {
            user.PersistCharacterState();
        }

        if (user.CraftingMenuOpen) { user.RefreshCraftingPreview(); }
    }

    static void MigrateLegacyEquipmentToNativeInventory(CaelumPlayer user, CaelumPersistentCharacterState persistentState)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return;
        if (!CaelumPlayerAuthority.OwnsRecord(user, persistentState)) return;
        if (persistentState == null
            || persistentState.NativeEquipmentMigrationComplete) { return; }
        for (Inventory cursor = user.Inv; cursor != null; cursor = cursor.Inv)
        {
            if (CaelumEquipmentItem(cursor) != null)
            {
                persistentState.NativeEquipmentMigrationComplete = true;
                return;
            }
        }
        persistentState.EnsureEquipmentSizeInitialized();
        persistentState.MigrateWeaponDurability();
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
                            Actor.Spawn("CaelumArmorPickup", user.Pos, NO_REPLACE)
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
                        item.UnitWeight = user.ArmorModel.GetWeightFor(
                            slot, armorType, tier, equipmentSize
                        );
                        item.Equipped = user.ArmorModel.ArmorType[slot] == armorType
                            && user.ArmorModel.Tier[slot] == tier
                            && user.ArmorModel.Size[slot] == equipmentSize;
                        item.InMagicBox = persistentState.IsArmorInMagicBox(
                            slot, armorType, tier, equipmentSize
                        );
                        item.AttachToOwner(user);
                        user.EnsureEquipmentItemId(item);
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
                        Actor.Spawn("CaelumShieldPickup", user.Pos, NO_REPLACE)
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
                    item.UnitWeight = user.ShieldModel.GetWeightFor(
                        shieldType, tier, equipmentSize
                    );
                    item.Equipped = user.ShieldModel.Equipped
                        && user.ShieldModel.ShieldType == shieldType
                        && user.ShieldModel.Tier == tier
                        && user.ShieldModel.Size == equipmentSize;
                    item.InMagicBox = persistentState.IsShieldInMagicBox(
                        shieldType, tier, equipmentSize
                    );
                    item.AttachToOwner(user);
                    user.EnsureEquipmentItemId(item);
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
                        Actor.Spawn("CaelumWeaponPickup", user.Pos, NO_REPLACE)
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
                    item.UnitWeight = user.WeaponModel.GetWeightFor(
                        weaponType, tier, equipmentSize
                    );
                    item.Equipped = persistentState.IsWeaponEquipped(
                        weaponType, tier, equipmentSize
                    );
                    item.InMagicBox = persistentState.IsWeaponInMagicBox(
                        weaponType, tier, equipmentSize
                    );
                    item.AttachToOwner(user);
                    user.EnsureEquipmentItemId(item);
                }
            }
        }
        persistentState.NativeEquipmentMigrationComplete = true;
    }

    static double GetEquippedWeaponLoadWeight(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanRead(user)) return 0;
        double total = 0.0;
        for (Inventory cursor = user.Inv; cursor != null; cursor = cursor.Inv)
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

    static bool HasEquippedWeaponFamily(CaelumPlayer user, int family)
    {
        if (!CaelumPlayerAuthority.CanRead(user)) return false;
        for (int weaponType = 0;
            weaponType < CaelumConstants.WEAPON_TYPE_COUNT; weaponType++)
        {
            if (user.GetWeaponFamilyForType(weaponType) == family
                && user.HasEquippedNativeWeaponType(weaponType))
            {
                return true;
            }
        }
        return false;
    }

    static bool ActivateEquippedWeaponFamily(CaelumPlayer user, int family)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return false;
        if (user.WeaponModel != null && user.WeaponModel.Equipped
            && user.GetWeaponFamilyForType(user.WeaponModel.WeaponType) == family
            && user.HasEquippedNativeWeaponType(user.WeaponModel.WeaponType))
        {
            return true;
        }
        for (int weaponType = 0;
            weaponType < CaelumConstants.WEAPON_TYPE_COUNT; weaponType++)
        {
            if (user.GetWeaponFamilyForType(weaponType) == family
                && user.ActivateEquippedWeaponType(weaponType))
            {
                return true;
            }
        }
        return false;
    }

    static bool ActivateEquippedWeaponType(CaelumPlayer user, int requestedWeaponType)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return false;
        if (user.WeaponModel == null) { return false; }
        int resolvedType = Clamp(
            requestedWeaponType, 0, CaelumConstants.WEAPON_TYPE_COUNT - 1
        );

        // Cambiar de arma rompe el bloqueo anterior. Si el jugador mantiene
        // Zoom, el arma nueva podrá levantar el escudo nuevamente mediante su
        // propio estado Zoom.
        if (user.WeaponModel.Equipped
            && user.WeaponModel.WeaponType != resolvedType)
        {
            user.CancelRangedAim();
            user.CancelRangedReload();
            user.CancelWeaponCharge();
            if (user.CombatBlockModeActive)
            {
                user.CancelCombatBlockMode();
            }
        }

        if (user.WeaponModel.Equipped
            && user.WeaponModel.WeaponType == resolvedType
            && user.HasEquippedNativeWeaponType(resolvedType))
        {
            return true;
        }
        if (user.StaffCastPending) { user.CancelPendingStaffCast(false); }
        for (Inventory cursor = user.Inv; cursor != null; cursor = cursor.Inv)
        {
            CaelumEquipmentItem item = CaelumEquipmentItem(cursor);
            if (item != null
                && item.EquipmentKind == CaelumConstants.EQUIPMENT_KIND_WEAPON
                && item.ItemType == resolvedType
                && item.Equipped && !item.InMagicBox)
            {
                user.WeaponModel.WeaponType = resolvedType;
                user.WeaponModel.Tier = item.Tier;
                user.WeaponModel.Size = item.EquipmentSize;
                user.WeaponModel.Durability = item.Durability;
                user.WeaponModel.EssenceType = Clamp(
                    item.EssenceType,
                    0,
                    CaelumConstants.ESSENCE_TYPE_COUNT - 1
                );
                user.SelectedEssenceType = user.WeaponModel.EssenceType;
                user.WeaponModel.Equipped = true;
                user.ActiveWeaponItemId = item.ItemId;
                user.EquippedWeaponCooldownRemaining = 0.0;
                user.ApplyCharacterProfile();
                user.PersistCharacterState();
                user.RefreshEquipmentSelectionPreview();
                return true;
            }
        }
        return false;
    }

    static bool ActivateExactEquippedWeapon(CaelumPlayer user, CaelumEquipmentItem item)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return false;
        if (item != null && item.Owner != user) return false;
        if (item == null || user.WeaponModel == null || !item.Equipped
            || item.InMagicBox || item.Durability <= 0
            || item.EquipmentKind != CaelumConstants.EQUIPMENT_KIND_WEAPON)
        {
            return false;
        }
        if (user.ActiveWeaponItemId != item.ItemId)
        {
            user.CancelRangedAim();
            user.CancelRangedReload();
            user.CancelWeaponCharge();
            if (user.CombatBlockModeActive) { user.CancelCombatBlockMode(); }
            if (user.StaffCastPending) { user.CancelPendingStaffCast(false); }
        }
        user.WeaponModel.WeaponType = item.ItemType;
        user.WeaponModel.Tier = item.Tier;
        user.WeaponModel.Size = item.EquipmentSize;
        user.WeaponModel.Durability = item.Durability;
        user.WeaponModel.EssenceType = Clamp(
            item.EssenceType, 0, CaelumConstants.ESSENCE_TYPE_COUNT - 1
        );
        user.SelectedEssenceType = user.WeaponModel.EssenceType;
        user.WeaponModel.Equipped = true;
        user.ActiveWeaponItemId = item.ItemId;
        user.EquippedWeaponCooldownRemaining = 0.0;
        user.SelectNativeWeaponConfiguration(
            item.ItemType, item.EssenceType, item.Tier
        );
        user.ApplyCharacterProfile();
        user.PersistCharacterState();
        user.RefreshEquipmentSelectionPreview();
        return true;
    }

    static bool IsWeaponInNativeSlot(CaelumPlayer user, CaelumEquipmentItem item, int slot)
    {
        if (item == null || item.EquipmentKind
                != CaelumConstants.EQUIPMENT_KIND_WEAPON
            || !item.Equipped || item.InMagicBox || item.Durability <= 0)
        {
            return false;
        }
        int catalogueWeapon =
            CaelumCraftingRules.GetCatalogueWeaponForPlayableType(
                item.ItemType
            );
        return catalogueWeapon >= 0
            && CaelumWeaponCatalogue.GetFamily(catalogueWeapon) == slot;
    }

    static void CycleEquippedWeaponSlot(CaelumPlayer user, int slot)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return;
        CaelumEquipmentItem first;
        bool passedActive = false;
        for (Inventory cursor = user.Inv; cursor != null; cursor = cursor.Inv)
        {
            CaelumEquipmentItem candidate = CaelumEquipmentItem(cursor);
            if (!user.IsWeaponInNativeSlot(candidate, slot)) { continue; }
            if (first == null) { first = candidate; }
            if (passedActive)
            {
                user.ActivateExactEquippedWeapon(candidate);
                return;
            }
            if (candidate.ItemId == user.ActiveWeaponItemId)
            {
                passedActive = true;
            }
        }
        if (first != null) { user.ActivateExactEquippedWeapon(first); }
    }

    static bool ActivateFirstEquippedWeapon(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return false;
        for (int weaponType = 0;
            weaponType < CaelumConstants.WEAPON_TYPE_COUNT;
            weaponType++)
        {
            if (user.ActivateEquippedWeaponType(weaponType)) { return true; }
        }
        if (user.WeaponModel != null) { user.WeaponModel.Equipped = false; }
        user.ActiveWeaponItemId = 0;
        return false;
    }

    static void RefreshCarriedInventorySummary(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return;
        user.SyncLiveMagicBoxOwnershipFromPersistentState();
        user.NormalizeUnownedMagicBoxStorage();
        user.PersonalInventoryItemCount = 0;
        user.OwnedArmorCount = 0;
        user.OwnedShieldCount = 0;
        user.OwnedWeaponCount = 0;
        user.EquippedItemSlotCount = 0;
        user.MagicBoxUsedSlots = 0;
        user.MagicBoxMaximumSlots = user.MagicBoxOwned && user.DerivedStats != null
            ? Max(0, user.DerivedStats.MagicBoxCapacity) : 0;
        user.HUDMagicBoxRawContentWeight = 0.0;
        user.HUDMagicBoxReducedContentWeight = 0.0;
        user.HUDMagicBoxTotalWeight = 0.0;
        user.HUDCopperCoinCount = 0;
        user.HUDSilverCoinCount = 0;
        user.HUDGoldCoinCount = 0;
        user.HUDTotalMoneyCopperValue = 0.0;
        double personalInventoryWeight = 0.0;
        double carriedItemWeight = 0.0;
        double armorWeight = 0.0;
        double shieldWeight = 0.0;
        double weaponWeight = 0.0;
        double magicBoxRawContentWeight = 0.0;

        for (Inventory cursor = user.Inv; cursor != null; cursor = cursor.Inv)
        {
            CaelumEquipmentItem item = CaelumEquipmentItem(cursor);
            if (item == null) { continue; }
            if (item.EquipmentKind == CaelumConstants.EQUIPMENT_KIND_ARMOR)
            {
                user.OwnedArmorCount++;
            }
            else if (item.EquipmentKind == CaelumConstants.EQUIPMENT_KIND_SHIELD)
            {
                user.OwnedShieldCount++;
            }
            else if (item.EquipmentKind == CaelumConstants.EQUIPMENT_KIND_WEAPON)
            {
                user.OwnedWeaponCount++;
            }

            if (item.InMagicBox)
            {
                user.MagicBoxUsedSlots++;
                magicBoxRawContentWeight += Max(0.0, item.UnitWeight)
                    * Max(0, item.Amount);
                continue;
            }

            double itemWeight = item.GetCarriedWeight();
            carriedItemWeight += itemWeight;
            if (item.Equipped)
            {
                user.EquippedItemSlotCount++;
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
                user.PersonalInventoryItemCount++;
                personalInventoryWeight += itemWeight;
            }
        }

        user.CarbineAmmoCount = 0;
        for (Inventory cursor = user.Inv; cursor != null; cursor = cursor.Inv)
        {
            CaelumCarbineAmmo ammunition = CaelumCarbineAmmo(cursor);
            if (ammunition == null || ammunition.Amount <= 0) { continue; }
            if (ammunition.GetAmmoType()
                == CaelumConstants.AMMUNITION_CARBINE)
            {
                user.CarbineAmmoCount = ammunition.Amount;
            }
            if (ammunition.InMagicBox)
            {
                user.MagicBoxUsedSlots++;
                magicBoxRawContentWeight += ammunition.Amount
                    * ammunition.GetUnitWeight();
            }
            else
            {
                user.PersonalInventoryItemCount += ammunition.Amount;
                double ammunitionWeight = ammunition.GetCarriedWeight();
                personalInventoryWeight += ammunitionWeight;
                carriedItemWeight += ammunitionWeight;
            }
        }

        Inventory arrowAmmo = user.FindInventory("CaelumArrowAmmo");
        if (arrowAmmo != null && arrowAmmo.Amount > 0)
        {
            user.PersonalInventoryItemCount += arrowAmmo.Amount;
            double arrowWeight = arrowAmmo.Amount
                * CaelumConstants.ARROW_AMMO_UNIT_WEIGHT;
            personalInventoryWeight += arrowWeight;
            carriedItemWeight += arrowWeight;
        }
        Inventory boltAmmo = user.FindInventory("CaelumBoltAmmo");
        if (boltAmmo != null && boltAmmo.Amount > 0)
        {
            user.PersonalInventoryItemCount += boltAmmo.Amount;
            double boltWeight = boltAmmo.Amount
                * CaelumConstants.BOLT_AMMO_UNIT_WEIGHT;
            personalInventoryWeight += boltWeight;
            carriedItemWeight += boltWeight;
        }

        for (Inventory cursor = user.Inv; cursor != null; cursor = cursor.Inv)
        {
            CaelumConsumableItem consumable = CaelumConsumableItem(cursor);
            if (consumable == null || consumable.Amount <= 0) { continue; }
            if (consumable.InMagicBox)
            {
                user.MagicBoxUsedSlots++;
                magicBoxRawContentWeight += consumable.Amount
                    * consumable.GetUnitWeight();
                continue;
            }
            user.PersonalInventoryItemCount += consumable.Amount;
            double consumableWeight = consumable.GetCarriedWeight();
            personalInventoryWeight += consumableWeight;
            carriedItemWeight += consumableWeight;
        }

        for (Inventory cursor = user.Inv; cursor != null; cursor = cursor.Inv)
        {
            CaelumSpecialInventoryItem specialItem =
                CaelumSpecialInventoryItem(cursor);
            if (specialItem == null || specialItem.Amount <= 0) { continue; }
            if (specialItem.GetSpecialCategory()
                == CaelumConstants.EQUIPMENT_KIND_CURRENCY)
            {
                int coinAmount = Max(0, specialItem.Amount);
                int currencyType = specialItem.GetSpecialType();
                int currencyMetal =
                    CaelumEconomyRules.GetCurrencyMetalType(currencyType);
                if (currencyMetal == CaelumConstants.CURRENCY_METAL_SILVER)
                {
                    user.HUDSilverCoinCount += coinAmount;
                }
                else if (currencyMetal
                    == CaelumConstants.CURRENCY_METAL_GOLD)
                {
                    user.HUDGoldCoinCount += coinAmount;
                }
                else
                {
                    user.HUDCopperCoinCount += coinAmount;
                }
                user.HUDTotalMoneyCopperValue += double(coinAmount)
                    * CaelumEconomyRules.GetCurrencyFaceValue(currencyType);
            }
            if (specialItem.InMagicBox)
            {
                user.MagicBoxUsedSlots++;
                magicBoxRawContentWeight += specialItem.Amount
                    * specialItem.GetUnitWeight();
                continue;
            }
            user.PersonalInventoryItemCount += specialItem.Amount;
            double specialWeight = specialItem.GetCarriedWeight();
            personalInventoryWeight += specialWeight;
            carriedItemWeight += specialWeight;
        }

        for (Inventory cursor = user.Inv; cursor != null; cursor = cursor.Inv)
        {
            CaelumWeightedKey keyItem = CaelumWeightedKey(cursor);
            if (keyItem == null || keyItem.Amount <= 0) { continue; }
            user.PersonalInventoryItemCount++;
            double keyWeight = keyItem.GetCarriedWeight();
            personalInventoryWeight += keyWeight;
            carriedItemWeight += keyWeight;
        }

        user.HUDMagicBoxRawContentWeight = Max(0.0, magicBoxRawContentWeight);
        user.HUDMagicBoxReducedContentWeight =
            user.CalculateMagicBoxReducedContentWeight(
                user.HUDMagicBoxRawContentWeight
            );
        user.HUDMagicBoxTotalWeight = user.MagicBoxOwned
            ? CaelumConstants.MAGIC_BOX_BASE_WEIGHT
                + user.HUDMagicBoxReducedContentWeight
            : 0.0;
        personalInventoryWeight += user.HUDMagicBoxTotalWeight;
        carriedItemWeight += user.HUDMagicBoxTotalWeight;
        if (user.DerivedStats != null)
        {
            user.DerivedStats.SetCarriedLoadBreakdown(
                armorWeight,
                shieldWeight,
                weaponWeight,
                personalInventoryWeight,
                carriedItemWeight
            );
            user.SyncHUDLoadState();
        }
    }

    static bool CanAddWeightToPersonalInventory(CaelumPlayer user, double additionalWeight)
    {
        if (!CaelumPlayerAuthority.CanRead(user)) return false;
        if (user.DerivedStats == null) { return false; }
        return user.DerivedStats.CarriedWeight + Max(0.0, additionalWeight)
            <= user.DerivedStats.CarryCapacity + 0.0005;
    }

    static bool IsSpecialInventoryKind(CaelumPlayer user, int k)
    { return k==CaelumConstants.EQUIPMENT_KIND_MATERIAL || k==CaelumConstants.EQUIPMENT_KIND_KEY || k==CaelumConstants.EQUIPMENT_KIND_KEY_ITEM || k==CaelumConstants.EQUIPMENT_KIND_CURRENCY; }

    static bool IsUniversalJewelryKind(CaelumPlayer user, int k)
    { return k==CaelumConstants.EQUIPMENT_KIND_AMULET || k==CaelumConstants.EQUIPMENT_KIND_SEAL; }

    static int GetFormalInventoryEntryKind(CaelumPlayer user, Inventory entry)
    {
        CaelumEquipmentItem equipment = CaelumEquipmentItem(entry);
        if (equipment != null) { return equipment.EquipmentKind; }
        CaelumConsumableItem consumable = CaelumConsumableItem(entry);
        if (consumable != null)
        {
            return CaelumConstants.EQUIPMENT_KIND_CONSUMABLE;
        }
        CaelumSpecialInventoryItem specialItem =
            CaelumSpecialInventoryItem(entry);
        if (specialItem != null) { return specialItem.GetSpecialCategory(); }
        if (CaelumCarbineAmmo(entry) != null
            || CaelumArrowAmmo(entry) != null
            || CaelumBoltAmmo(entry) != null)
        {
            return CaelumConstants.EQUIPMENT_KIND_AMMUNITION;
        }
        if (CaelumWeightedKey(entry) != null)
        {
            return CaelumConstants.EQUIPMENT_KIND_KEY;
        }
        return -1;
    }

    static int GetFormalInventoryFilterCategory(CaelumPlayer user, int kind)
    {
        if (kind == CaelumConstants.EQUIPMENT_KIND_WEAPON) { return 1; }
        if (kind == CaelumConstants.EQUIPMENT_KIND_ARMOR) { return 2; }
        if (kind == CaelumConstants.EQUIPMENT_KIND_SHIELD) { return 3; }
        if (kind == CaelumConstants.EQUIPMENT_KIND_AMULET
            || kind == CaelumConstants.EQUIPMENT_KIND_SEAL) { return 4; }
        if (kind == CaelumConstants.EQUIPMENT_KIND_CONSUMABLE) { return 5; }
        if (kind == CaelumConstants.EQUIPMENT_KIND_MATERIAL) { return 6; }
        if (kind == CaelumConstants.EQUIPMENT_KIND_AMMUNITION) { return 7; }
        if (kind == CaelumConstants.EQUIPMENT_KIND_KEY
            || kind == CaelumConstants.EQUIPMENT_KIND_KEY_ITEM) { return 8; }
        if (kind == CaelumConstants.EQUIPMENT_KIND_CURRENCY) { return 9; }
        return -1;
    }

    static bool FormalInventoryEntryMatchesFilter(CaelumPlayer user, Inventory entry)
    {
        if (!CaelumPlayerAuthority.CanRead(user)) return false;
        int kind = user.GetFormalInventoryEntryKind(entry);
        if (kind < 0 || entry.Amount <= 0) { return false; }
        return user.FormalInventoryFilter == 0
            || user.GetFormalInventoryFilterCategory(kind)
                == user.FormalInventoryFilter;
    }

    static Inventory GetFormalInventoryEntryAt(CaelumPlayer user, int requestedIndex)
    {
        if (!CaelumPlayerAuthority.CanRead(user)) return null;
        if (requestedIndex < 0) { return null; }
        int currentIndex = 0;
        for (Inventory cursor = user.Inv; cursor != null; cursor = cursor.Inv)
        {
            if (!user.FormalInventoryEntryMatchesFilter(cursor)) { continue; }
            if (currentIndex == requestedIndex) { return cursor; }
            currentIndex++;
        }
        return null;
    }

    static int CountFormalInventoryEntries(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanRead(user)) return 0;
        int total = 0;
        for (Inventory cursor = user.Inv; cursor != null; cursor = cursor.Inv)
        {
            if (user.FormalInventoryEntryMatchesFilter(cursor)) { total++; }
        }
        return total;
    }

    static int GetFormalAmmunitionType(CaelumPlayer user, Inventory entry)
    {
        CaelumCarbineAmmo customAmmo = CaelumCarbineAmmo(entry);
        if (customAmmo != null) { return customAmmo.GetAmmoType(); }
        if (CaelumArrowAmmo(entry) != null)
        {
            return CaelumConstants.AMMUNITION_ARROW;
        }
        if (CaelumBoltAmmo(entry) != null)
        {
            return CaelumConstants.AMMUNITION_BOLT;
        }
        return CaelumConstants.AMMUNITION_CARBINE;
    }

    static double GetFormalInventoryEntryWeight(CaelumPlayer user, Inventory entry)
    {
        CaelumEquipmentItem equipment = CaelumEquipmentItem(entry);
        if (equipment != null) { return Max(0.0, equipment.UnitWeight); }
        CaelumConsumableItem consumable = CaelumConsumableItem(entry);
        if (consumable != null)
        {
            return Max(0, consumable.Amount) * consumable.GetUnitWeight();
        }
        CaelumSpecialInventoryItem specialItem =
            CaelumSpecialInventoryItem(entry);
        if (specialItem != null)
        {
            return Max(0, specialItem.Amount) * specialItem.GetUnitWeight();
        }
        CaelumCarbineAmmo customAmmo = CaelumCarbineAmmo(entry);
        if (customAmmo != null)
        {
            return Max(0, customAmmo.Amount) * customAmmo.GetUnitWeight();
        }
        if (CaelumArrowAmmo(entry) != null)
        {
            return Max(0, entry.Amount)
                * CaelumConstants.ARROW_AMMO_UNIT_WEIGHT;
        }
        if (CaelumBoltAmmo(entry) != null)
        {
            return Max(0, entry.Amount)
                * CaelumConstants.BOLT_AMMO_UNIT_WEIGHT;
        }
        CaelumWeightedKey keyItem = CaelumWeightedKey(entry);
        return keyItem != null ? keyItem.GetCarriedWeight() : 0.0;
    }

    static int GetFormalInventoryMaximumDurability(CaelumPlayer user, CaelumEquipmentItem item)
    {
        if (!CaelumPlayerAuthority.CanRead(user)) return 0;
        if (item == null) { return 0; }
        if (item.EquipmentKind == CaelumConstants.EQUIPMENT_KIND_ARMOR
            && user.ArmorModel != null)
        {
            return user.ArmorModel.GetMaximumDurabilityFor(
                item.ItemType, item.Tier, item.EquipmentSize
            );
        }
        if (item.EquipmentKind == CaelumConstants.EQUIPMENT_KIND_SHIELD
            && user.ShieldModel != null)
        {
            return user.ShieldModel.GetMaximumDurabilityFor(
                item.ItemType, item.Tier, item.EquipmentSize
            );
        }
        if (item.EquipmentKind == CaelumConstants.EQUIPMENT_KIND_WEAPON
            && user.WeaponModel != null)
        {
            return user.WeaponModel.GetMaximumDurabilityFor(
                item.ItemType, item.Tier, item.EquipmentSize
            );
        }
        return 0;
    }

    static void ClearFormalInventoryRow(CaelumPlayer user, int row)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return;
        user.FormalInventoryRowKind[row] = -1;
        user.FormalInventoryRowType[row] = -1;
        user.FormalInventoryRowArmorSlot[row] = -1;
        user.FormalInventoryRowTier[row] = 0;
        user.FormalInventoryRowSize[row] = CaelumConstants.EQUIPMENT_SIZE_M;
        user.FormalInventoryRowEssenceType[row] = CaelumConstants.ESSENCE_FIRE;
        user.FormalInventoryRowAmount[row] = 0;
        user.FormalInventoryRowItemId[row] = 0;
        user.FormalInventoryRowDurability[row] = 0;
        user.FormalInventoryRowMaximumDurability[row] = 0;
        user.FormalInventoryRowWeight[row] = 0.0;
        user.FormalInventoryRowEquipped[row] = false;
        user.FormalInventoryRowInMagicBox[row] = false;
        user.FormalInventoryRowReservedUnits[row] = 0;
    }

    static void FillFormalInventoryRow(CaelumPlayer user, int row, Inventory entry)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return;
        if (entry != null && entry.Owner != user) return;
        user.ClearFormalInventoryRow(row);
        if (entry == null) { return; }
        int kind = user.GetFormalInventoryEntryKind(entry);
        user.FormalInventoryRowKind[row] = kind;
        user.FormalInventoryRowWaterLiters[row] = -1;
        let water = CaelumWaterContainer(entry);
        if (water != null) user.FormalInventoryRowWaterLiters[row] = water.WaterLiters;
        user.FormalInventoryRowAmount[row] = Max(1, entry.Amount);
        user.FormalInventoryRowWeight[row] =
            user.GetFormalInventoryEntryWeight(entry);

        CaelumEquipmentItem equipment = CaelumEquipmentItem(entry);
        if (equipment != null)
        {
            user.FormalInventoryRowType[row] = equipment.ItemType;
            user.FormalInventoryRowArmorSlot[row] = equipment.ArmorSlot;
            user.FormalInventoryRowTier[row] = equipment.Tier;
            user.FormalInventoryRowSize[row] = equipment.EquipmentSize;
            user.FormalInventoryRowEssenceType[row] = equipment.EssenceType;
            user.FormalInventoryRowAmount[row] = 1;
            user.FormalInventoryRowItemId[row] = equipment.ItemId;
            user.FormalInventoryRowDurability[row] = equipment.Durability;
            user.FormalInventoryRowMaximumDurability[row] =
                user.GetFormalInventoryMaximumDurability(equipment);
            user.FormalInventoryRowEquipped[row] = equipment.Equipped;
            user.FormalInventoryRowInMagicBox[row] = equipment.InMagicBox;
            if (user.IsEquipmentItemCraftingLocked(equipment.ItemId))
            {
                user.FormalInventoryRowReservedUnits[row] = 1;
            }
            return;
        }

        CaelumConsumableItem consumable = CaelumConsumableItem(entry);
        if (consumable != null)
        {
            user.FormalInventoryRowType[row] = consumable.GetConsumableType();
            user.FormalInventoryRowInMagicBox[row] = consumable.InMagicBox;
            return;
        }

        CaelumSpecialInventoryItem specialItem =
            CaelumSpecialInventoryItem(entry);
        if (specialItem != null)
        {
            user.FormalInventoryRowType[row] = specialItem.GetSpecialType();
            user.FormalInventoryRowTier[row] = specialItem.GetSpecialTier();
            user.FormalInventoryRowInMagicBox[row] = specialItem.InMagicBox;
            if (kind == CaelumConstants.EQUIPMENT_KIND_MATERIAL)
            {
                user.FormalInventoryRowReservedUnits[row] =
                    user.GetReservedCraftingMaterialUnits(
                        specialItem.GetSpecialType(),
                        specialItem.GetSpecialTier()
                    );
            }
            return;
        }

        if (kind == CaelumConstants.EQUIPMENT_KIND_AMMUNITION)
        {
            user.FormalInventoryRowType[row] = user.GetFormalAmmunitionType(entry);
            CaelumCarbineAmmo customAmmo = CaelumCarbineAmmo(entry);
            user.FormalInventoryRowInMagicBox[row] =
                customAmmo != null && customAmmo.InMagicBox;
            return;
        }

        CaelumWeightedKey keyItem = CaelumWeightedKey(entry);
        if (keyItem != null)
        {
            user.FormalInventoryRowType[row] = keyItem.GetKeyType();
        }
    }

    static void ApplyFormalInventorySelection(CaelumPlayer user, Inventory entry)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return;
        if (entry != null && entry.Owner != user) return;
        user.EquipmentSelectionItemId = 0;
        if (entry == null) { return; }
        int kind = user.GetFormalInventoryEntryKind(entry);
        user.EquipmentSelectionKind = kind;

        CaelumEquipmentItem equipment = CaelumEquipmentItem(entry);
        if (equipment != null)
        {
            user.EquipmentSelectionItemId = equipment.ItemId;
            user.EquipmentSelectionTier = equipment.Tier;
            user.EquipmentSelectionSize = equipment.EquipmentSize;
            if (kind == CaelumConstants.EQUIPMENT_KIND_ARMOR)
            {
                user.EquipmentSelectionArmorType = equipment.ItemType;
                user.EquipmentSelectionSlot = equipment.ArmorSlot;
            }
            else if (kind == CaelumConstants.EQUIPMENT_KIND_SHIELD)
            {
                user.EquipmentSelectionShieldType = equipment.ItemType;
            }
            else if (kind == CaelumConstants.EQUIPMENT_KIND_WEAPON)
            {
                user.EquipmentSelectionWeaponType = equipment.ItemType;
                user.EquipmentSelectionWeaponEssenceType = equipment.EssenceType;
            }
            else if (kind == CaelumConstants.EQUIPMENT_KIND_AMULET)
            {
                user.EquipmentSelectionAmuletType = equipment.ItemType;
            }
            else if (kind == CaelumConstants.EQUIPMENT_KIND_SEAL)
            {
                user.EquipmentSelectionSealType = equipment.ItemType;
            }
        }
        else if (kind == CaelumConstants.EQUIPMENT_KIND_CONSUMABLE)
        {
            user.EquipmentSelectionConsumableType =
                CaelumConsumableItem(entry).GetConsumableType();
        }
        else if (kind == CaelumConstants.EQUIPMENT_KIND_AMMUNITION)
        {
            user.EquipmentSelectionAmmunitionType =
                user.GetFormalAmmunitionType(entry);
        }
        else
        {
            CaelumSpecialInventoryItem specialItem =
                CaelumSpecialInventoryItem(entry);
            if (specialItem != null)
            {
                user.EquipmentSelectionSpecialType = specialItem.GetSpecialType();
                user.EquipmentSelectionTier = specialItem.GetSpecialTier();
            }
            else
            {
                CaelumWeightedKey keyItem = CaelumWeightedKey(entry);
                if (keyItem != null)
                {
                    user.EquipmentSelectionSpecialType = keyItem.GetKeyType();
                }
            }
        }
        user.RefreshEquipmentSelectionPreview();
    }

    static void RefreshFormalInventorySnapshot(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return;
        user.EnsureAllEquipmentItemIds();
        user.FormalInventoryFilter = Clamp(
            user.FormalInventoryFilter, 0, CaelumPlayer.FORMAL_INVENTORY_FILTER_COUNT - 1
        );
        user.FormalInventoryEntryCount = user.CountFormalInventoryEntries();
        for (int row = 0; row < CaelumPlayer.FORMAL_INVENTORY_VISIBLE_ROWS; row++)
        {
            user.ClearFormalInventoryRow(row);
        }

        if (user.FormalInventoryEntryCount <= 0)
        {
            user.FormalInventorySelectionIndex = 0;
            user.FormalInventoryVisibleStart = 0;
            user.EquipmentSelectionItemId = 0;
            return;
        }

        user.FormalInventorySelectionIndex = Clamp(
            user.FormalInventorySelectionIndex, 0,
            user.FormalInventoryEntryCount - 1
        );
        if (user.FormalInventorySelectionIndex < user.FormalInventoryVisibleStart)
        {
            user.FormalInventoryVisibleStart = user.FormalInventorySelectionIndex;
        }
        else if (user.FormalInventorySelectionIndex
            >= user.FormalInventoryVisibleStart + CaelumPlayer.FORMAL_INVENTORY_VISIBLE_ROWS)
        {
            user.FormalInventoryVisibleStart = user.FormalInventorySelectionIndex
                - CaelumPlayer.FORMAL_INVENTORY_VISIBLE_ROWS + 1;
        }
        user.FormalInventoryVisibleStart = Clamp(
            user.FormalInventoryVisibleStart, 0,
            Max(0, user.FormalInventoryEntryCount - CaelumPlayer.FORMAL_INVENTORY_VISIBLE_ROWS)
        );

        for (int row = 0; row < CaelumPlayer.FORMAL_INVENTORY_VISIBLE_ROWS; row++)
        {
            int entryIndex = user.FormalInventoryVisibleStart + row;
            if (entryIndex >= user.FormalInventoryEntryCount) { break; }
            user.FillFormalInventoryRow(row, user.GetFormalInventoryEntryAt(entryIndex));
        }
        user.ApplyFormalInventorySelection(
            user.GetFormalInventoryEntryAt(user.FormalInventorySelectionIndex)
        );
    }

    static void CycleFormalInventorySelection(CaelumPlayer user, int direction)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return;
        user.RefreshFormalInventorySnapshot();
        if (user.FormalInventoryEntryCount <= 0) { return; }
        user.FormalInventorySelectionIndex = (
            user.FormalInventorySelectionIndex + direction
                + user.FormalInventoryEntryCount
        ) % user.FormalInventoryEntryCount;
        user.LastEquipmentAction = CaelumConstants.EQUIPMENT_ACTION_NONE;
        user.RefreshFormalInventorySnapshot();
    }

    static void CycleFormalInventoryFilter(CaelumPlayer user, int direction = 1)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return;
        int step = direction < 0 ? -1 : 1;
        user.FormalInventoryFilter = (
            user.FormalInventoryFilter + step + CaelumPlayer.FORMAL_INVENTORY_FILTER_COUNT
        ) % CaelumPlayer.FORMAL_INVENTORY_FILTER_COUNT;
        user.FormalInventorySelectionIndex = 0;
        user.FormalInventoryVisibleStart = 0;
        user.LastEquipmentAction = CaelumConstants.EQUIPMENT_ACTION_NONE;
        user.RefreshFormalInventorySnapshot();
    }

    static void ActivateFormalInventorySelection(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return;
        Inventory entry =
            user.GetFormalInventoryEntryAt(user.FormalInventorySelectionIndex);
        if (entry == null) { return; }
        user.ApplyFormalInventorySelection(entry);
        let bag = CaelumSleepingBag(entry);
        if (bag != null && !bag.InMagicBox)
        {
            bool menuWasOpen = user.EquipmentMenuOpen;
            user.EquipmentMenuOpen = false;
            if (!bag.Open(user)) user.EquipmentMenuOpen = menuWasOpen;
            user.RefreshFormalInventorySnapshot();
            return;
        }
        CaelumEquipmentItem equipment = CaelumEquipmentItem(entry);
        if (equipment != null)
        {
            if (equipment.InMagicBox) { user.ToggleSelectedMagicBox(); }
            else if (equipment.Equipped) { user.UnequipSelectedNativeEquipment(); }
            else { user.EquipSelectedNativeEquipment(); }
        }
        else if (CaelumConsumableItem(entry) != null
            && !CaelumConsumableItem(entry).InMagicBox)
        {
            user.UseSelectedConsumable();
        }
        else
        {
            user.ToggleSelectedMagicBox();
        }
        user.RefreshFormalInventorySnapshot();
    }

    static void ToggleFormalInventoryStorage(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return;
        Inventory entry =
            user.GetFormalInventoryEntryAt(user.FormalInventorySelectionIndex);
        if (entry == null) { return; }
        user.ApplyFormalInventorySelection(entry);
        user.ToggleSelectedMagicBox();
        user.RefreshFormalInventorySnapshot();
    }

    static void DropFormalInventorySelection(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return;
        Inventory entry =
            user.GetFormalInventoryEntryAt(user.FormalInventorySelectionIndex);
        if (entry == null) { return; }
        user.ApplyFormalInventorySelection(entry);
        user.DropSelectedEquipment();
        user.RefreshFormalInventorySnapshot();
    }

    static void RefreshEquipmentSelectionPreview(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return;
        CaelumEquipmentItem identifiedItem =
            user.FindNativeEquipmentItemById(user.EquipmentSelectionItemId);
        if (user.EquipmentSelectionItemId > 0 && identifiedItem == null)
        {
            user.EquipmentSelectionItemId = 0;
        }
        else if (identifiedItem != null)
        {
            user.EquipmentSelectionKind = identifiedItem.EquipmentKind;
            user.EquipmentSelectionTier = identifiedItem.Tier;
            user.EquipmentSelectionSize = identifiedItem.EquipmentSize;
            if (identifiedItem.EquipmentKind
                == CaelumConstants.EQUIPMENT_KIND_ARMOR)
            {
                user.EquipmentSelectionArmorType = identifiedItem.ItemType;
                user.EquipmentSelectionSlot = identifiedItem.ArmorSlot;
            }
            else if (identifiedItem.EquipmentKind
                == CaelumConstants.EQUIPMENT_KIND_SHIELD)
            {
                user.EquipmentSelectionShieldType = identifiedItem.ItemType;
            }
            else if (identifiedItem.EquipmentKind
                == CaelumConstants.EQUIPMENT_KIND_WEAPON)
            {
                user.EquipmentSelectionWeaponType = identifiedItem.ItemType;
                user.EquipmentSelectionWeaponEssenceType =
                    identifiedItem.EssenceType;
            }
            else if (identifiedItem.EquipmentKind
                == CaelumConstants.EQUIPMENT_KIND_AMULET)
            {
                user.EquipmentSelectionAmuletType = identifiedItem.ItemType;
            }
            else if (identifiedItem.EquipmentKind
                == CaelumConstants.EQUIPMENT_KIND_SEAL)
            {
                user.EquipmentSelectionSealType = identifiedItem.ItemType;
            }
        }
        user.EquipmentSelectionSlot = Clamp(
            user.EquipmentSelectionSlot,
            0,
            CaelumConstants.ARMOR_SLOT_COUNT - 1
        );
        user.EquipmentSelectionArmorType = Clamp(
            user.EquipmentSelectionArmorType,
            0,
            CaelumConstants.ARMOR_EQUIPPABLE_TYPE_COUNT - 1
        );
        user.EquipmentSelectionShieldType = Clamp(
            user.EquipmentSelectionShieldType,
            0,
            CaelumConstants.SHIELD_TYPE_COUNT - 1
        );
        user.EquipmentSelectionWeaponType = Clamp(
            user.EquipmentSelectionWeaponType,
            0,
            CaelumConstants.WEAPON_TYPE_COUNT - 1
        );
        if (user.EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_WEAPON)
            user.EquipmentSelectionTier = CaelumWeaponModel.ResolveTierFor(user.EquipmentSelectionWeaponType, user.EquipmentSelectionTier);
        user.EquipmentSelectionWeaponEssenceType = Clamp(
            user.EquipmentSelectionWeaponEssenceType,
            0,
            CaelumConstants.ESSENCE_TYPE_COUNT - 1
        );
        user.EquipmentSelectionAmmunitionType = Clamp(
            user.EquipmentSelectionAmmunitionType,
            0,
            CaelumConstants.AMMUNITION_TYPE_COUNT - 1
        );
        user.EquipmentSelectionConsumableType = Clamp(
            user.EquipmentSelectionConsumableType,
            0,
            CaelumConstants.CONSUMABLE_TYPE_COUNT - 1
        );
        user.EquipmentSelectionAmuletType = Clamp(user.EquipmentSelectionAmuletType,0,CaelumConstants.AMULET_TYPE_COUNT-1);
        user.EquipmentSelectionSealType = Clamp(user.EquipmentSelectionSealType,0,CaelumConstants.SEAL_TYPE_COUNT-1);
        int specialTypeCount = 1;
        if (user.EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_MATERIAL)
        {
            specialTypeCount = CaelumConstants.MATERIAL_TYPE_COUNT;
        }
        else if (user.EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_KEY)
        {
            specialTypeCount = CaelumConstants.KEY_TYPE_COUNT;
        }
        else if (user.EquipmentSelectionKind
            == CaelumConstants.EQUIPMENT_KIND_KEY_ITEM)
        {
            specialTypeCount = CaelumConstants.KEY_ITEM_TYPE_COUNT;
        }
        else if (user.EquipmentSelectionKind
            == CaelumConstants.EQUIPMENT_KIND_CURRENCY)
        {
            specialTypeCount = CaelumConstants.CURRENCY_TYPE_COUNT;
        }
        int firstSpecialType = 0;
        if (user.EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_MATERIAL)
        {
            firstSpecialType = CaelumConstants.MATERIAL_FIRST_ACTIVE;
        }
        user.EquipmentSelectionSpecialType = Clamp(
            user.EquipmentSelectionSpecialType, firstSpecialType, specialTypeCount - 1
        );
        user.EquipmentSelectionTier = Clamp(user.EquipmentSelectionTier, 1, 3);
        if (user.EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_MATERIAL)
        {
            user.EquipmentSelectionTier = CaelumMaterialRules.ResolveTier(
                user.EquipmentSelectionSpecialType, user.EquipmentSelectionTier
            );
        }
        user.EquipmentSelectionSize = Clamp(
            user.EquipmentSelectionSize,
            0,
            CaelumConstants.EQUIPMENT_SIZE_COUNT - 1
        );
        user.EquipmentSelectionOwned = false;
        user.EquipmentSelectionEquipped = false;
        user.EquipmentSelectionInMagicBox = false;
        user.EquipmentSelectionSizeCompatible = user.CharacterProfile != null
            && CaelumEquipmentRules.IsSizeCompatible(
                user.EquipmentSelectionSize,
                user.CharacterProfile.GetSizeTier()
            );
        user.EquipmentSelectionDurability = 0;
        user.EquipmentSelectionMaximumDurability = 0;
        user.EquipmentSelectionWeight = 0.0;
        user.EquipmentSelectionDamage = 0.0;
        user.EquipmentSelectionAirCost = 0.0;
        user.EquipmentSelectionAnimaCost = 0.0;
        user.EquipmentSelectionAttackTics = 0;
        user.EquipmentSelectionStackAmount = 0;
        user.MagicBoxMaximumSlots = user.MagicBoxOwned && user.DerivedStats != null
            ? user.DerivedStats.MagicBoxCapacity : 0;
        user.RefreshCarriedInventorySummary();

        if (user.EquipmentSelectionKind
            == CaelumConstants.EQUIPMENT_KIND_AMMUNITION)
        {
            Inventory ammunition = user.FindNativeAmmunition(
                user.EquipmentSelectionAmmunitionType
            );
            user.EquipmentSelectionOwned = ammunition != null
                && ammunition.Amount > 0;
            user.EquipmentSelectionInMagicBox = false;
            user.EquipmentSelectionSizeCompatible = true;
            user.EquipmentSelectionStackAmount = user.EquipmentSelectionOwned
                ? ammunition.Amount : 0;
            user.EquipmentSelectionWeight = user.EquipmentSelectionStackAmount
                * user.GetAmmunitionUnitWeight(user.EquipmentSelectionAmmunitionType);
            CaelumCarbineAmmo carbineStack = CaelumCarbineAmmo(ammunition);
            if (carbineStack != null)
            {
                user.EquipmentSelectionInMagicBox = carbineStack.InMagicBox;
                user.EquipmentSelectionWeight = carbineStack.Amount
                    * carbineStack.GetUnitWeight();
            }
            return;
        }

        if (user.EquipmentSelectionKind
            == CaelumConstants.EQUIPMENT_KIND_CONSUMABLE)
        {
            CaelumConsumableItem consumable = user.FindNativeConsumableItem(
                user.EquipmentSelectionConsumableType
            );
            user.EquipmentSelectionOwned = consumable != null
                && consumable.Amount > 0;
            user.EquipmentSelectionInMagicBox = user.EquipmentSelectionOwned
                && consumable.InMagicBox;
            user.EquipmentSelectionSizeCompatible = true;
            user.EquipmentSelectionStackAmount = user.EquipmentSelectionOwned
                ? consumable.Amount : 0;
            double unitWeight = consumable != null
                ? consumable.GetUnitWeight()
                : CaelumConsumableItem.UnitWeightForType(user.EquipmentSelectionConsumableType);
            user.EquipmentSelectionWeight = user.EquipmentSelectionStackAmount
                * unitWeight;
            return;
        }

        if (user.EquipmentSelectionKind
                == CaelumConstants.EQUIPMENT_KIND_MATERIAL
            || user.EquipmentSelectionKind
                == CaelumConstants.EQUIPMENT_KIND_KEY_ITEM
            || user.EquipmentSelectionKind
                == CaelumConstants.EQUIPMENT_KIND_CURRENCY)
        {
            CaelumSpecialInventoryItem specialItem = user.FindNativeSpecialItem(
                user.EquipmentSelectionKind, user.EquipmentSelectionSpecialType,
                user.EquipmentSelectionTier
            );
            user.EquipmentSelectionOwned = specialItem != null
                && specialItem.Amount > 0;
            user.EquipmentSelectionInMagicBox = user.EquipmentSelectionOwned
                && specialItem.InMagicBox;
            user.EquipmentSelectionSizeCompatible = true;
            user.EquipmentSelectionStackAmount = user.EquipmentSelectionOwned
                ? specialItem.Amount : 0;
            user.EquipmentSelectionWeight = user.EquipmentSelectionStackAmount
                * (specialItem != null
                    ? specialItem.GetUnitWeight()
                    : (user.EquipmentSelectionKind
                            == CaelumConstants.EQUIPMENT_KIND_CURRENCY
                        ? CaelumConstants.CURRENCY_UNIT_WEIGHT
                        : CaelumConstants.SPECIAL_ITEM_DEFAULT_WEIGHT));
            return;
        }

        if (user.EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_KEY)
        {
            CaelumWeightedKey keyItem = user.FindNativeKey(
                user.EquipmentSelectionSpecialType
            );
            user.EquipmentSelectionOwned = keyItem != null && keyItem.Amount > 0;
            user.EquipmentSelectionSizeCompatible = true;
            user.EquipmentSelectionStackAmount = user.EquipmentSelectionOwned ? 1 : 0;
            user.EquipmentSelectionWeight = user.EquipmentSelectionOwned
                ? keyItem.GetCarriedWeight()
                : CaelumConstants.SPECIAL_ITEM_DEFAULT_WEIGHT;
            return;
        }

        if (user.EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_AMULET
            || user.EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_SEAL)
        {
            int type = user.EquipmentSelectionKind==CaelumConstants.EQUIPMENT_KIND_AMULET ? user.EquipmentSelectionAmuletType : user.EquipmentSelectionSealType;
            CaelumEquipmentItem item = identifiedItem;
            if (item == null)
            {
                item=user.FindNativeEquipmentItem(user.EquipmentSelectionKind,type,-1,user.EquipmentSelectionTier,CaelumConstants.EQUIPMENT_SIZE_M);
            }
            user.EquipmentSelectionSize=CaelumConstants.EQUIPMENT_SIZE_M; user.EquipmentSelectionSizeCompatible=true;
            user.EquipmentSelectionOwned=item!=null; user.EquipmentSelectionEquipped=item!=null&&item.Equipped;
            user.EquipmentSelectionInMagicBox=item!=null&&item.InMagicBox; user.EquipmentSelectionDurability=0; user.EquipmentSelectionMaximumDurability=0;
            user.EquipmentSelectionWeight=item!=null ? item.UnitWeight : CaelumCraftingRules.GetJewelryWeight(user.EquipmentSelectionTier);
            return;
        }

        if (user.EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_WEAPON)
        {
            CaelumEquipmentItem item = identifiedItem;
            if (item == null && user.WeaponModel != null
                && user.WeaponModel.IsMagicalType(user.EquipmentSelectionWeaponType))
            {
                item = user.FindNativeMagicWeaponItem(
                    user.EquipmentSelectionWeaponType,
                    user.EquipmentSelectionWeaponEssenceType,
                    user.EquipmentSelectionTier,
                    user.EquipmentSelectionSize
                );
            }
            else if (item == null)
            {
                item = user.FindNativeEquipmentItem(
                    CaelumConstants.EQUIPMENT_KIND_WEAPON,
                    user.EquipmentSelectionWeaponType,
                    -1,
                    user.EquipmentSelectionTier,
                    user.EquipmentSelectionSize
                );
            }
            user.EquipmentSelectionOwned = item != null;
            user.EquipmentSelectionDurability = item != null ? item.Durability : 0;
            user.EquipmentSelectionMaximumDurability = user.WeaponModel != null
                ? user.WeaponModel.GetMaximumDurabilityFor(
                    user.EquipmentSelectionWeaponType,
                    user.EquipmentSelectionTier,
                    user.EquipmentSelectionSize
                ) : 0;
            user.EquipmentSelectionWeight = user.WeaponModel != null
                ? user.WeaponModel.GetWeightFor(
                    user.EquipmentSelectionWeaponType,
                    user.EquipmentSelectionTier,
                    user.EquipmentSelectionSize
                ) : 0.0;
            user.EquipmentSelectionDamage = user.WeaponModel != null
                ? user.WeaponModel.GetDamageFor(
                    user.EquipmentSelectionWeaponType,
                    user.EquipmentSelectionTier
                ) : 0.0;
            user.EquipmentSelectionAirCost = user.WeaponModel != null
                ? user.WeaponModel.GetAirCostFor(user.EquipmentSelectionWeaponType) : 0.0;
            user.EquipmentSelectionAnimaCost = user.WeaponModel != null
                ? user.WeaponModel.GetAnimaCostFor(user.EquipmentSelectionWeaponType) : 0.0;
            user.EquipmentSelectionAttackTics = user.WeaponModel != null
                ? user.WeaponModel.GetAttackTicsFor(user.EquipmentSelectionWeaponType) : 0;
            user.EquipmentSelectionEquipped = item != null && item.Equipped;
            user.EquipmentSelectionInMagicBox = item != null && item.InMagicBox;
            if (user.WeaponModel != null
                && user.WeaponModel.IsMagicalType(user.EquipmentSelectionWeaponType))
            {
                user.SelectedEssenceType = user.EquipmentSelectionWeaponEssenceType;
            }
            return;
        }

        if (user.EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_SHIELD)
        {
            CaelumEquipmentItem item = identifiedItem;
            if (item == null)
            {
                item = user.FindNativeEquipmentItem(
                    CaelumConstants.EQUIPMENT_KIND_SHIELD,
                    user.EquipmentSelectionShieldType,
                    -1,
                    user.EquipmentSelectionTier,
                    user.EquipmentSelectionSize
                );
            }
            user.EquipmentSelectionOwned = item != null;
            user.EquipmentSelectionDurability = item != null ? item.Durability : 0;
            user.EquipmentSelectionMaximumDurability = user.ShieldModel != null
                ? user.ShieldModel.GetMaximumDurabilityFor(
                    user.EquipmentSelectionShieldType,
                    user.EquipmentSelectionTier,
                    user.EquipmentSelectionSize
                ) : 0;
            user.EquipmentSelectionWeight = user.ShieldModel != null
                ? user.ShieldModel.GetWeightFor(
                    user.EquipmentSelectionShieldType,
                    user.EquipmentSelectionTier,
                    user.EquipmentSelectionSize
                ) : 0.0;
            user.EquipmentSelectionEquipped = item != null && item.Equipped;
            user.EquipmentSelectionInMagicBox = item != null && item.InMagicBox;
            return;
        }

        CaelumEquipmentItem item = identifiedItem;
        if (item == null)
        {
            item = user.FindNativeEquipmentItem(
                CaelumConstants.EQUIPMENT_KIND_ARMOR,
                user.EquipmentSelectionArmorType,
                user.EquipmentSelectionSlot,
                user.EquipmentSelectionTier,
                user.EquipmentSelectionSize
            );
        }
        user.EquipmentSelectionOwned = item != null;
        user.EquipmentSelectionDurability = item != null ? item.Durability : 0;
        user.EquipmentSelectionMaximumDurability = user.ArmorModel != null
            ? user.ArmorModel.GetMaximumDurabilityFor(
                user.EquipmentSelectionArmorType,
                user.EquipmentSelectionTier,
                user.EquipmentSelectionSize
            ) : 0;
        user.EquipmentSelectionWeight = user.ArmorModel != null
            ? user.ArmorModel.GetWeightFor(
                user.EquipmentSelectionSlot,
                user.EquipmentSelectionArmorType,
                user.EquipmentSelectionTier,
                user.EquipmentSelectionSize
            ) : 0.0;
        user.EquipmentSelectionEquipped = item != null && item.Equipped;
        user.EquipmentSelectionInMagicBox = item != null && item.InMagicBox;
    }

    static bool AcquireArmorPickup(CaelumPlayer user, int slot, int armorType, int tier, int equipmentSize, int encodedDurability)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return false;
        if (user.ArmorModel == null) { return false; }
        int resolvedSlot = Clamp(slot, 0, CaelumConstants.ARMOR_SLOT_COUNT - 1);
        int resolvedType = Clamp(
            armorType, 0, CaelumConstants.ARMOR_EQUIPPABLE_TYPE_COUNT - 1
        );
        int resolvedTier = Clamp(tier, 1, 3);
        int resolvedSize = Clamp(
            equipmentSize, 0, CaelumConstants.EQUIPMENT_SIZE_COUNT - 1
        );
        CaelumPersistentCharacterState persistentState =
            user.GetPersistentCharacterState(true);
        if (persistentState == null) { return false; }
        persistentState.EnsureEquipmentSizeInitialized();
        persistentState.MigrateWeaponDurability();
        user.ApplyCharacterProfile();
        user.RefreshEquipmentSelectionPreview();
        bool alreadyOwned = persistentState.OwnsArmor(
            resolvedSlot, resolvedType, resolvedTier, resolvedSize
        );
        bool sendToMagicBox = false;
        double pickupWeight = user.ArmorModel.GetWeightFor(
            resolvedSlot, resolvedType, resolvedTier, resolvedSize
        );
        if (!alreadyOwned
            && !user.CanAddWeightToPersonalInventory(pickupWeight))
        {
            if (!user.HasNativeMagicBoxSlotAvailable()
                || !user.CanAddRawWeightToMagicBox(pickupWeight))
            {
                return false;
            }
            sendToMagicBox = true;
        }
        int pickupDurability = encodedDurability > 0
            ? encodedDurability - 1
            : user.ArmorModel.GetMaximumDurabilityFor(resolvedType, resolvedTier, resolvedSize);
        user.LastEquipmentPickupWasNew = persistentState.RegisterOwnedArmor(
            resolvedSlot,
            resolvedType,
            resolvedTier,
            resolvedSize,
            pickupDurability
        );
        if (user.LastEquipmentPickupWasNew)
        {
            persistentState.SetArmorInMagicBox(
                resolvedSlot, resolvedType, resolvedTier, resolvedSize,
                sendToMagicBox
            );
        }
        user.LastEquipmentPickupWentToMagicBox = persistentState.IsArmorInMagicBox(
            resolvedSlot, resolvedType, resolvedTier, resolvedSize
        );
        if (user.ArmorModel.ArmorType[resolvedSlot] == resolvedType
            && user.ArmorModel.Tier[resolvedSlot] == resolvedTier
            && user.ArmorModel.Size[resolvedSlot] == resolvedSize)
        {
            user.ArmorModel.Durability[resolvedSlot] = user.ArmorModel.GetMaximumDurabilityFor(
                resolvedType, resolvedTier, resolvedSize
            );
        }
        user.OwnedArmorCount = persistentState.CountOwnedArmor();
        user.ApplyCharacterProfile();
        user.RefreshEquipmentSelectionPreview();
        user.PersistCharacterState();
        return true;
    }

    static bool AcquireShieldPickup(CaelumPlayer user, int shieldType, int tier, int equipmentSize, int encodedDurability)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return false;
        if (user.ShieldModel == null) { return false; }
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
            user.GetPersistentCharacterState(true);
        if (persistentState == null) { return false; }
        persistentState.EnsureEquipmentSizeInitialized();
        persistentState.MigrateWeaponDurability();
        user.ApplyCharacterProfile();
        user.RefreshEquipmentSelectionPreview();
        bool alreadyOwned = persistentState.OwnsShield(
            resolvedType, resolvedTier, resolvedSize
        );
        bool sendToMagicBox = false;
        double pickupWeight = user.ShieldModel.GetWeightFor(
            resolvedType, resolvedTier, resolvedSize
        );
        if (!alreadyOwned
            && !user.CanAddWeightToPersonalInventory(pickupWeight))
        {
            if (!user.HasNativeMagicBoxSlotAvailable()
                || !user.CanAddRawWeightToMagicBox(pickupWeight))
            {
                return false;
            }
            sendToMagicBox = true;
        }
        int pickupDurability = encodedDurability > 0
            ? encodedDurability - 1
            : user.ShieldModel.GetMaximumDurabilityFor(resolvedType, resolvedTier, resolvedSize);
        user.LastEquipmentPickupWasNew = persistentState.RegisterOwnedShield(
            resolvedType,
            resolvedTier,
            resolvedSize,
            pickupDurability
        );
        if (user.LastEquipmentPickupWasNew)
        {
            persistentState.SetShieldInMagicBox(
                resolvedType, resolvedTier, resolvedSize, sendToMagicBox
            );
        }
        user.LastEquipmentPickupWentToMagicBox = persistentState.IsShieldInMagicBox(
            resolvedType, resolvedTier, resolvedSize
        );
        if (user.ShieldModel.Equipped
            && user.ShieldModel.ShieldType == resolvedType
            && user.ShieldModel.Tier == resolvedTier
            && user.ShieldModel.Size == resolvedSize)
        {
            user.ShieldModel.Durability = user.ShieldModel.GetMaximumDurabilityFor(
                resolvedType, resolvedTier, resolvedSize
            );
        }
        user.OwnedShieldCount = persistentState.CountOwnedShields();
        user.ApplyCharacterProfile();
        user.RefreshEquipmentSelectionPreview();
        user.PersistCharacterState();
        return true;
    }

    static bool AcquireWeaponPickup(CaelumPlayer user, int weaponType, int tier, int equipmentSize, int encodedDurability)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return false;
        if (user.WeaponModel == null) { return false; }
        int resolvedType = Clamp(
            weaponType, 0, CaelumConstants.WEAPON_TYPE_COUNT - 1
        );
        int resolvedTier = CaelumWeaponModel.ResolveTierFor(resolvedType, tier);
        int resolvedSize = Clamp(
            equipmentSize, 0, CaelumConstants.EQUIPMENT_SIZE_COUNT - 1
        );
        CaelumPersistentCharacterState persistentState =
            user.GetPersistentCharacterState(true);
        if (persistentState == null) { return false; }
        persistentState.EnsureEquipmentSizeInitialized();
        persistentState.MigrateWeaponDurability();
        user.ApplyCharacterProfile();
        user.RefreshEquipmentSelectionPreview();
        bool alreadyOwned = persistentState.OwnsWeapon(
            resolvedType, resolvedTier, resolvedSize
        );
        bool sendToMagicBox = false;
        double pickupWeight = user.WeaponModel.GetWeightFor(
            resolvedType, resolvedTier, resolvedSize
        );
        if (!alreadyOwned
            && !user.CanAddWeightToPersonalInventory(pickupWeight))
        {
            if (!user.HasNativeMagicBoxSlotAvailable()
                || !user.CanAddRawWeightToMagicBox(pickupWeight))
            {
                return false;
            }
            sendToMagicBox = true;
        }
        int pickupDurability = encodedDurability > 0
            ? encodedDurability - 1
            : user.WeaponModel.GetMaximumDurabilityFor(
                resolvedType, resolvedTier, resolvedSize
            );
        user.LastEquipmentPickupWasNew = persistentState.RegisterOwnedWeapon(
            resolvedType, resolvedTier, resolvedSize, pickupDurability
        );
        if (user.LastEquipmentPickupWasNew)
        {
            persistentState.SetWeaponInMagicBox(
                resolvedType, resolvedTier, resolvedSize, sendToMagicBox
            );
        }
        user.LastEquipmentPickupWentToMagicBox = persistentState.IsWeaponInMagicBox(
            resolvedType, resolvedTier, resolvedSize
        );
        if (user.WeaponModel.Equipped
            && user.WeaponModel.WeaponType == resolvedType
            && user.WeaponModel.Tier == resolvedTier
            && user.WeaponModel.Size == resolvedSize)
        {
            user.WeaponModel.Durability = user.WeaponModel.GetMaximumDurabilityFor(
                resolvedType, resolvedTier, resolvedSize
            );
        }
        user.OwnedWeaponCount = persistentState.CountOwnedWeapons();
        user.ApplyCharacterProfile();
        user.RefreshEquipmentSelectionPreview();
        user.PersistCharacterState();
        return true;
    }

    static int CountCraftingMaterial(CaelumPlayer user, int materialType, int materialTier)
    {
        if (!CaelumPlayerAuthority.CanRead(user)) return 0;
        CaelumSpecialInventoryItem material = user.FindNativeSpecialItem(
            CaelumConstants.EQUIPMENT_KIND_MATERIAL,
            materialType,
            materialTier
        );
        int actual = material != null ? Max(0, material.Amount) : 0;
        if (user.CraftingTaskCompleting) { return actual; }
        return Max(
            0,
            actual - user.GetReservedCraftingMaterialUnits(
                materialType, materialTier
            )
        );
    }

    static int CountRawCraftingMaterial(CaelumPlayer user, int materialType, int materialTier)
    {
        if (!CaelumPlayerAuthority.CanRead(user)) return 0;
        CaelumSpecialInventoryItem material = user.FindNativeSpecialItem(
            CaelumConstants.EQUIPMENT_KIND_MATERIAL,
            materialType,
            materialTier
        );
        return material != null ? Max(0, material.Amount) : 0;
    }

    static int GetReservedCraftingMaterialUnits(CaelumPlayer user, int materialType, int materialTier)
    {
        if (!CaelumPlayerAuthority.CanRead(user)) return 0;
        if (!user.CraftingTaskActive) { return 0; }
        int reserved = 0;
        for (int slot = 0;
            slot < CaelumConstants.CRAFTING_TASK_MATERIAL_SLOT_COUNT; slot++)
        {
            if (user.CraftingTaskReservedUnits[slot] > 0
                && user.CraftingTaskReservedType[slot] == materialType
                && user.CraftingTaskReservedTier[slot] == materialTier)
            {
                reserved += user.CraftingTaskReservedUnits[slot];
            }
        }
        return reserved;
    }

    static bool IsEquipmentItemCraftingLocked(CaelumPlayer user, int itemId)
    {
        if (!CaelumPlayerAuthority.CanRead(user)) return false;
        return user.CraftingTaskActive && user.CraftingTaskTargetItemId > 0
            && user.CraftingTaskTargetItemId == itemId;
    }

    static bool IsSelectedMaterialCraftingLocked(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanRead(user)) return false;
        return user.EquipmentSelectionKind
                == CaelumConstants.EQUIPMENT_KIND_MATERIAL
            && user.GetReservedCraftingMaterialUnits(
                user.EquipmentSelectionSpecialType,
                user.EquipmentSelectionTier
            ) > 0;
    }

    static void ClearCraftingTaskData(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return;
        user.CraftingTaskActive = false;
        user.CraftingTaskCompleting = false;
        user.CraftingTaskKind = CaelumConstants.CRAFTING_TASK_NONE;
        user.CraftingTaskRecipeIndex = 0;
        user.CraftingTaskTier = 1;
        user.CraftingTaskSize = CaelumConstants.EQUIPMENT_SIZE_M;
        user.CraftingTaskBatchIndex = 0;
        user.CraftingTaskEfficiencyIndex = 0;
        user.CraftingTaskTargetItemId = 0;
        user.CraftingTaskNetworkCapabilities = 0;
        user.CraftingTaskReservedBoxSlots = 0;
        user.CraftingTaskUsesDirectPlan = false;
        user.CraftingTaskUsesLimboMaterials = false;
        user.CraftingTaskTotalSeconds = 0.0;
        user.CraftingTaskRemainingSeconds = 0.0;
        for (int slot = 0;
            slot < CaelumConstants.CRAFTING_TASK_MATERIAL_SLOT_COUNT; slot++)
        {
            user.CraftingTaskReservedType[slot] = -1;
            user.CraftingTaskReservedTier[slot] = 1;
            user.CraftingTaskReservedUnits[slot] = 0;
            user.CraftingTaskOutputType[slot] = -1;
            user.CraftingTaskOutputTier[slot] = 1;
            user.CraftingTaskOutputUnits[slot] = 0;
        }
    }

    static bool AddCraftingTaskReservation(CaelumPlayer user, int materialType, int materialTier, int units)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return false;
        if (units <= 0) { return true; }
        int resolvedTier = CaelumMaterialRules.ResolveTier(
            materialType, materialTier
        );
        for (int slot = 0;
            slot < CaelumConstants.CRAFTING_TASK_MATERIAL_SLOT_COUNT; slot++)
        {
            if (user.CraftingTaskReservedUnits[slot] > 0
                && user.CraftingTaskReservedType[slot] == materialType
                && user.CraftingTaskReservedTier[slot] == resolvedTier)
            {
                user.CraftingTaskReservedUnits[slot] += units;
                return true;
            }
        }
        for (int slot = 0;
            slot < CaelumConstants.CRAFTING_TASK_MATERIAL_SLOT_COUNT; slot++)
        {
            if (user.CraftingTaskReservedUnits[slot] <= 0)
            {
                user.CraftingTaskReservedType[slot] = materialType;
                user.CraftingTaskReservedTier[slot] = resolvedTier;
                user.CraftingTaskReservedUnits[slot] = units;
                return true;
            }
        }
        return false;
    }

    static bool AddCraftingTaskOutput(CaelumPlayer user, int materialType, int materialTier, int units)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return false;
        if (units <= 0) { return true; }
        int resolvedTier = CaelumMaterialRules.ResolveTier(
            materialType, materialTier
        );
        for (int slot = 0;
            slot < CaelumConstants.CRAFTING_TASK_MATERIAL_SLOT_COUNT; slot++)
        {
            if (user.CraftingTaskOutputUnits[slot] > 0
                && user.CraftingTaskOutputType[slot] == materialType
                && user.CraftingTaskOutputTier[slot] == resolvedTier)
            {
                user.CraftingTaskOutputUnits[slot] += units;
                return true;
            }
        }
        for (int slot = 0;
            slot < CaelumConstants.CRAFTING_TASK_MATERIAL_SLOT_COUNT; slot++)
        {
            if (user.CraftingTaskOutputUnits[slot] <= 0)
            {
                user.CraftingTaskOutputType[slot] = materialType;
                user.CraftingTaskOutputTier[slot] = resolvedTier;
                user.CraftingTaskOutputUnits[slot] = units;
                return true;
            }
        }
        return false;
    }

    static bool ValidateCraftingTaskReservations(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return false;
        for (int slot = 0;
            slot < CaelumConstants.CRAFTING_TASK_MATERIAL_SLOT_COUNT; slot++)
        {
            if (user.CraftingTaskReservedUnits[slot] <= 0) { continue; }
            if (user.CountRawCraftingMaterial(
                    user.CraftingTaskReservedType[slot],
                    user.CraftingTaskReservedTier[slot]
                ) < user.CraftingTaskReservedUnits[slot])
            {
                return false;
            }
        }
        return true;
    }

    static bool CanCompletePreparedMaterialOutput(CaelumPlayer user, bool outputToMagicBox)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return false;
        if (user.DerivedStats == null) { return false; }
        int outputSlot = -1;
        for (int slot = 0;
            slot < CaelumConstants.CRAFTING_TASK_MATERIAL_SLOT_COUNT; slot++)
        {
            if (user.CraftingTaskOutputUnits[slot] > 0)
            {
                outputSlot = slot;
                break;
            }
        }
        if (outputSlot < 0) { return false; }

        CaelumSpecialInventoryItem existingOutput = user.FindNativeSpecialItem(
            CaelumConstants.EQUIPMENT_KIND_MATERIAL,
            user.CraftingTaskOutputType[outputSlot],
            user.CraftingTaskOutputTier[outputSlot]
        );
        user.RefreshCarriedInventorySummary();
        double personalDelta = 0.0;
        double boxRawDelta = 0.0;
        for (int slot = 0;
            slot < CaelumConstants.CRAFTING_TASK_MATERIAL_SLOT_COUNT; slot++)
        {
            if (user.CraftingTaskReservedUnits[slot] <= 0) { continue; }
            CaelumSpecialInventoryItem inputStack = user.FindNativeSpecialItem(
                CaelumConstants.EQUIPMENT_KIND_MATERIAL,
                user.CraftingTaskReservedType[slot],
                user.CraftingTaskReservedTier[slot]
            );
            if (inputStack == null) { return false; }
            double inputWeight = user.CraftingTaskReservedUnits[slot]
                * CaelumConstants.MATERIAL_UNIT_WEIGHT;
            if (inputStack.InMagicBox)
            {
                boxRawDelta -= inputWeight;
            }
            else
            {
                personalDelta -= inputWeight;
            }
        }

        double outputWeight = user.CraftingTaskOutputUnits[outputSlot]
            * CaelumConstants.MATERIAL_UNIT_WEIGHT;
        if (outputToMagicBox)
        {
            if (existingOutput != null && !existingOutput.InMagicBox)
            {
                int remainingUnits = Max(
                    0,
                    existingOutput.Amount - user.GetReservedCraftingMaterialUnits(
                        user.CraftingTaskOutputType[outputSlot],
                        user.CraftingTaskOutputTier[outputSlot]
                    )
                );
                double remainingWeight = remainingUnits
                    * CaelumConstants.MATERIAL_UNIT_WEIGHT;
                personalDelta -= remainingWeight;
                boxRawDelta += remainingWeight;
            }
            boxRawDelta += outputWeight;
        }
        else
        {
            if (existingOutput != null && existingOutput.InMagicBox)
            {
                boxRawDelta += outputWeight;
            }
            else
            {
                personalDelta += outputWeight;
            }
        }
        return user.CanApplyInventoryWeightTransition(
            personalDelta, boxRawDelta
        );
    }

    static int GetPreparedMaterialOutputBoxSlots(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanRead(user)) return 0;
        int outputSlot = -1;
        for (int slot = 0;
            slot < CaelumConstants.CRAFTING_TASK_MATERIAL_SLOT_COUNT; slot++)
        {
            if (user.CraftingTaskOutputUnits[slot] > 0)
            {
                outputSlot = slot;
                break;
            }
        }
        if (outputSlot < 0) { return -1; }

        CaelumSpecialInventoryItem existingOutput = user.FindNativeSpecialItem(
            CaelumConstants.EQUIPMENT_KIND_MATERIAL,
            user.CraftingTaskOutputType[outputSlot],
            user.CraftingTaskOutputTier[outputSlot]
        );
        if (existingOutput != null && existingOutput.InMagicBox)
        {
            return user.CanCompletePreparedMaterialOutput(true) ? 0 : -1;
        }
        if (user.CanCompletePreparedMaterialOutput(false)) { return 0; }
        return user.CanCompletePreparedMaterialOutput(true) ? 1 : -1;
    }

    static bool CanCompletePreparedEquipmentOutput(CaelumPlayer user, double outputRawWeight)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return false;
        if (user.DerivedStats == null) { return false; }
        user.RefreshCarriedInventorySummary();
        bool personalOutput = CaelumCraftingRules.GetRecipeAmmunitionType(user.CraftingSelectionRecipe) >= 0
            || CaelumMainM00RonnieTrial.CanUsePersonalCraftingOutput(user);
        double personalDelta = personalOutput ? Max(0.0, outputRawWeight) : 0.0;
        double boxRawDelta = personalOutput ? 0.0 : Max(0.0, outputRawWeight);
        for (int slot = 0;
            slot < CaelumConstants.CRAFTING_TASK_MATERIAL_SLOT_COUNT; slot++)
        {
            if (user.CraftingTaskReservedUnits[slot] <= 0) { continue; }
            CaelumSpecialInventoryItem inputStack = user.FindNativeSpecialItem(
                CaelumConstants.EQUIPMENT_KIND_MATERIAL,
                user.CraftingTaskReservedType[slot],
                user.CraftingTaskReservedTier[slot]
            );
            if (inputStack == null) { return false; }
            double inputWeight = user.CraftingTaskReservedUnits[slot]
                * CaelumConstants.MATERIAL_UNIT_WEIGHT;
            if (inputStack.InMagicBox) { boxRawDelta -= inputWeight; }
            else { personalDelta -= inputWeight; }
        }
        return user.CanApplyInventoryWeightTransition(
            personalDelta, boxRawDelta
        );
    }

    static bool ReservePreparedDirectCraftingPlan(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return false;
        if (!user.CraftingDirectPlanAvailable) { return false; }
        for (int slot = 0;
            slot < CaelumConstants.CRAFTING_TASK_MATERIAL_SLOT_COUNT; slot++)
        {
            if (user.CraftingPlanReservedUnits[slot] <= 0) { continue; }
            if (!user.AddCraftingTaskReservation(
                user.CraftingPlanReservedType[slot],
                user.CraftingPlanReservedTier[slot],
                user.CraftingPlanReservedUnits[slot]
            ))
            {
                return false;
            }
        }
        return user.ValidateCraftingTaskReservations();
    }

    static bool ConsumeSelectedWeaponCraftingMaterials(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return false;
        if (user.CraftingTaskCompleting && user.CraftingTaskUsesDirectPlan)
        {
            return user.ConsumeCraftingTaskReservations();
        }
        return user.ConsumeCraftingMaterial(
                user.CraftingBasicMaterialType,
                user.CraftingBasicMaterialTier,
                user.CraftingBasicRequired
            )
            && user.ConsumeCraftingMaterial(
                user.CraftingTierMaterialType,
                user.CraftingTierMaterialTier,
                user.CraftingTierRequired
            )
            && user.ConsumeCraftingFinishMaterials();
    }

    static bool ConsumeCraftingMaterial(CaelumPlayer user, int materialType, int materialTier, int requiredAmount)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return false;
        if (requiredAmount <= 0) { return true; }
        CaelumSpecialInventoryItem material = user.FindNativeSpecialItem(
            CaelumConstants.EQUIPMENT_KIND_MATERIAL,
            materialType,
            materialTier
        );
        if (material == null || material.Amount < requiredAmount)
        {
            return false;
        }
        material.LimboSupplyUnits = Max(0, material.LimboSupplyUnits - requiredAmount);
        material.LimboQuestUnits = Max(0, material.LimboQuestUnits - requiredAmount);
        material.Amount -= requiredAmount;
        if (material.Amount <= 0) { material.Destroy(); }
        return true;
    }

    static bool HasCraftingFinishMaterials(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanRead(user)) return false;
        return user.CraftingSilverOwned >= user.CraftingSilverRequired
            && user.CraftingGoldOwned >= user.CraftingGoldRequired;
    }

    static bool ConsumeCraftingFinishMaterials(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return false;
        return user.ConsumeCraftingMaterial(
                CaelumConstants.MATERIAL_SILVER_INGOT,
                1,
                user.CraftingSilverRequired
            )
            && user.ConsumeCraftingMaterial(
                CaelumConstants.MATERIAL_GOLD_INGOT,
                1,
                user.CraftingGoldRequired
            );
    }

    static void CraftSelectedProcessingRecipe(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return;
        user.RefreshCraftingPreview();
        if (user.CraftingSelectedRecipeKind
                != CaelumConstants.CRAFTING_RECIPE_KIND_PROCESSING
            && user.CraftingSelectedRecipeKind
                != CaelumConstants.CRAFTING_RECIPE_KIND_COMPONENT)
        {
            user.LastCraftingAction = CaelumConstants.CRAFTING_ACTION_FAILED_STATION;
            return;
        }
        if (!user.CraftingSelectedInfrastructureAvailable)
        {
            user.LastCraftingAction =
                CaelumConstants.CRAFTING_ACTION_FAILED_INFRASTRUCTURE;
            return;
        }
        if (user.CraftingBasicOwned < user.CraftingBasicRequired
            || user.CraftingTierOwned < user.CraftingTierRequired
            || !user.HasCraftingFinishMaterials())
        {
            user.LastCraftingAction =
                CaelumConstants.CRAFTING_ACTION_FAILED_MATERIALS;
            return;
        }

        CaelumSpecialInventoryItem existingOutput = user.FindNativeSpecialItem(
            CaelumConstants.EQUIPMENT_KIND_MATERIAL,
            user.CraftingOutputMaterialType,
            user.CraftingOutputMaterialTier
        );
        bool sendOutputToMagicBox = existingOutput != null
            && existingOutput.InMagicBox;
        int outputBoxSlots = user.GetPreparedMaterialOutputBoxSlots();
        if (outputBoxSlots < 0)
        {
            user.LastCraftingAction =
                CaelumConstants.CRAFTING_ACTION_FAILED_CARRY_CAPACITY;
            return;
        }
        if (!sendOutputToMagicBox && outputBoxSlots > 0)
        {
            if (user.DerivedStats == null
                || user.CountNativeMagicBoxSlots()
                    >= user.DerivedStats.MagicBoxCapacity)
            {
                user.LastCraftingAction =
                    CaelumConstants.CRAFTING_ACTION_FAILED_BOX_FULL;
                return;
            }
            sendOutputToMagicBox = true;
        }
        CaelumMaterialPickup detachedOutput;
        if (existingOutput == null)
        {
            detachedOutput = user.CreateDetachedMaterialStack(
                user.CraftingOutputMaterialType,
                user.CraftingOutputMaterialTier,
                user.CraftingOutputAmount
            );
            if (detachedOutput == null)
            {
                user.LastCraftingAction =
                    CaelumConstants.CRAFTING_ACTION_FAILED_MATERIALS;
                return;
            }
        }

        if (!user.ConsumeCraftingMaterial(
                user.CraftingBasicMaterialType,
                user.CraftingBasicMaterialTier,
                user.CraftingBasicRequired
            )
            || !user.ConsumeCraftingMaterial(
                user.CraftingTierMaterialType,
                user.CraftingTierMaterialTier,
                user.CraftingTierRequired
            )
            || !user.ConsumeCraftingFinishMaterials())
        {
            if (detachedOutput != null) { detachedOutput.Destroy(); }
            user.LastCraftingAction =
                CaelumConstants.CRAFTING_ACTION_FAILED_MATERIALS;
            return;
        }

        if (existingOutput != null)
        {
            existingOutput.Amount += user.CraftingOutputAmount;
            if (user.CraftingTaskUsesLimboMaterials) existingOutput.LimboQuestUnits += user.CraftingOutputAmount;
            if (sendOutputToMagicBox) { existingOutput.InMagicBox = true; }
        }
        else
        {
            if (user.CraftingTaskUsesLimboMaterials) detachedOutput.LimboQuestUnits = user.CraftingOutputAmount;
            detachedOutput.InMagicBox = sendOutputToMagicBox;
            detachedOutput.AttachToOwner(user);
        }
        if (existingOutput!=null)
            CaelumNotifications.Acquired(user,existingOutput,user.CraftingOutputAmount);
        else CaelumNotifications.Acquired(user,detachedOutput,user.CraftingOutputAmount);
        user.LastCraftingAction = CaelumConstants.CRAFTING_ACTION_PROCESSED;
        user.ApplyCharacterProfile();
        user.PersistCharacterState();
        user.RefreshEquipmentSelectionPreview();
        user.RefreshCraftingPreview();
    }

    static void CraftSelectedArmorRecipe(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return;
        if (user.ArmorModel == null) { return; }
        user.RefreshCraftingPreview();

        if (user.CraftingSelectedRecipeKind
            != CaelumConstants.CRAFTING_RECIPE_KIND_ARMOR)
        {
            user.LastCraftingAction = CaelumConstants.CRAFTING_ACTION_FAILED_STATION;
            return;
        }
        if (!user.CraftingSelectedInfrastructureAvailable)
        {
            user.LastCraftingAction =
                CaelumConstants.CRAFTING_ACTION_FAILED_INFRASTRUCTURE;
            return;
        }
        if (!CaelumMainM00RonnieTrial.CanUsePersonalCraftingOutput(user) && !user.HasNativeMagicBoxSlotAvailable())
        {
            user.LastCraftingAction =
                CaelumConstants.CRAFTING_ACTION_FAILED_BOX_FULL;
            return;
        }
        if (!user.HasSelectedWeaponCraftingMaterials())
        {
            user.LastCraftingAction =
                CaelumConstants.CRAFTING_ACTION_FAILED_MATERIALS;
            return;
        }

        CaelumEquipmentItem result = CaelumEquipmentItem(
            Actor.Spawn("CaelumArmorPickup", user.Pos, NO_REPLACE)
        );
        if (result == null)
        {
            user.LastCraftingAction =
                CaelumConstants.CRAFTING_ACTION_FAILED_MATERIALS;
            return;
        }

        if (!user.ConsumeSelectedWeaponCraftingMaterials())
        {
            result.Destroy();
            user.LastCraftingAction =
                CaelumConstants.CRAFTING_ACTION_FAILED_MATERIALS;
            return;
        }

        result.EquipmentKind = CaelumConstants.EQUIPMENT_KIND_ARMOR;
        result.ItemType = user.CraftingSelectedArmorType;
        result.ArmorSlot = user.CraftingSelectedArmorSlot;
        result.Tier = user.CraftingSelectionTier;
        result.EquipmentSize = user.CraftingSelectionSize;
        result.Durability = user.ArmorModel.GetMaximumDurabilityFor(
            user.CraftingSelectedArmorType,
            user.CraftingSelectionTier,
            user.CraftingSelectionSize
        );
        result.EssenceType = CaelumConstants.ESSENCE_FIRE;
        result.UnitWeight = user.ArmorModel.GetWeightFor(
            user.CraftingSelectedArmorSlot,
            user.CraftingSelectedArmorType,
            user.CraftingSelectionTier,
            user.CraftingSelectionSize
        );
        result.Equipped = false;
        result.InMagicBox = !CaelumMainM00RonnieTrial.CanUsePersonalCraftingOutput(user);
        result.PickupDataInitialized = true;
        result.AttachToOwner(user);
        user.EnsureEquipmentItemId(result);
        CaelumNotifications.Acquired(user, result, 1);

        CaelumPersistentCharacterState persistentState =
            user.GetPersistentCharacterState(true);
        if (persistentState != null)
        {
            persistentState.RegisterOwnedArmor(
                user.CraftingSelectedArmorSlot,
                user.CraftingSelectedArmorType,
                user.CraftingSelectionTier,
                user.CraftingSelectionSize,
                result.Durability
            );
            persistentState.SetArmorInMagicBox(
                user.CraftingSelectedArmorSlot,
                user.CraftingSelectedArmorType,
                user.CraftingSelectionTier,
                user.CraftingSelectionSize,
                result.InMagicBox
            );
        }

        CaelumMainM00SupplyRules.RecordArmor(user, result);
        user.LastCraftingAction = CaelumConstants.CRAFTING_ACTION_CREATED;
        user.ApplyCharacterProfile();
        user.PersistCharacterState();
        user.RefreshEquipmentSelectionPreview();
        user.RefreshCraftingPreview();
    }

    static void CraftSelectedShieldRecipe(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return;
        if (user.ShieldModel == null) { return; }
        user.RefreshCraftingPreview();

        if (user.CraftingSelectedRecipeKind
            != CaelumConstants.CRAFTING_RECIPE_KIND_SHIELD)
        {
            user.LastCraftingAction = CaelumConstants.CRAFTING_ACTION_FAILED_STATION;
            return;
        }
        if (!user.CraftingSelectedInfrastructureAvailable)
        {
            user.LastCraftingAction =
                CaelumConstants.CRAFTING_ACTION_FAILED_INFRASTRUCTURE;
            return;
        }
        if (!CaelumMainM00RonnieTrial.CanUsePersonalCraftingOutput(user) && !user.HasNativeMagicBoxSlotAvailable())
        {
            user.LastCraftingAction =
                CaelumConstants.CRAFTING_ACTION_FAILED_BOX_FULL;
            return;
        }
        if (!user.HasSelectedWeaponCraftingMaterials())
        {
            user.LastCraftingAction =
                CaelumConstants.CRAFTING_ACTION_FAILED_MATERIALS;
            return;
        }

        CaelumEquipmentItem result = CaelumEquipmentItem(
            Actor.Spawn("CaelumShieldPickup", user.Pos, NO_REPLACE)
        );
        if (result == null || CaelumShieldPickup(result) == null)
        {
            if (result != null) { result.Destroy(); }
            user.LastCraftingAction =
                CaelumConstants.CRAFTING_ACTION_FAILED_STATION;
            return;
        }

        if (!user.ConsumeSelectedWeaponCraftingMaterials())
        {
            result.Destroy();
            user.LastCraftingAction =
                CaelumConstants.CRAFTING_ACTION_FAILED_MATERIALS;
            return;
        }

        result.EquipmentKind = CaelumConstants.EQUIPMENT_KIND_SHIELD;
        result.ItemType = user.CraftingSelectedShieldType;
        result.ArmorSlot = -1;
        result.Tier = user.CraftingSelectionTier;
        result.EquipmentSize = user.CraftingSelectionSize;
        result.Durability = user.ShieldModel.GetMaximumDurabilityFor(
            user.CraftingSelectedShieldType,
            user.CraftingSelectionTier,
            user.CraftingSelectionSize
        );
        result.EssenceType = CaelumConstants.ESSENCE_FIRE;
        result.UnitWeight = user.ShieldModel.GetWeightFor(
            user.CraftingSelectedShieldType,
            user.CraftingSelectionTier,
            user.CraftingSelectionSize
        );
        result.Equipped = false;
        result.InMagicBox = !CaelumMainM00RonnieTrial.CanUsePersonalCraftingOutput(user);
        result.PickupDataInitialized = true;
        result.AttachToOwner(user);
        user.EnsureEquipmentItemId(result);
        CaelumNotifications.Acquired(user, result, 1);

        CaelumPersistentCharacterState persistentState =
            user.GetPersistentCharacterState(true);
        if (persistentState != null)
        {
            persistentState.RegisterOwnedShield(
                user.CraftingSelectedShieldType,
                user.CraftingSelectionTier,
                user.CraftingSelectionSize,
                result.Durability
            );
            persistentState.SetShieldInMagicBox(
                user.CraftingSelectedShieldType,
                user.CraftingSelectionTier,
                user.CraftingSelectionSize,
                result.InMagicBox
            );
        }

        CaelumMainM00Loadout.RecordShield(user, result);
        user.LastCraftingAction = CaelumConstants.CRAFTING_ACTION_CREATED;
        user.ApplyCharacterProfile();
        user.PersistCharacterState();
        user.RefreshEquipmentSelectionPreview();
        user.RefreshCraftingPreview();
    }

    static void CraftSelectedEssenceWeaponRecipe(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return;
        if (user.WeaponModel == null) { return; }
        user.RefreshCraftingPreview();

        if (user.CraftingSelectedRecipeKind
            != CaelumConstants.CRAFTING_RECIPE_KIND_ESSENCE_WEAPON)
        {
            user.LastCraftingAction = CaelumConstants.CRAFTING_ACTION_FAILED_STATION;
            return;
        }
        if (!user.CraftingSelectedInfrastructureAvailable)
        {
            user.LastCraftingAction =
                CaelumConstants.CRAFTING_ACTION_FAILED_INFRASTRUCTURE;
            return;
        }
        if (!CaelumMainM00RonnieTrial.CanUsePersonalCraftingOutput(user) && !user.HasNativeMagicBoxSlotAvailable())
        {
            user.LastCraftingAction =
                CaelumConstants.CRAFTING_ACTION_FAILED_BOX_FULL;
            return;
        }
        if (!user.HasSelectedWeaponCraftingMaterials())
        {
            user.LastCraftingAction =
                CaelumConstants.CRAFTING_ACTION_FAILED_MATERIALS;
            return;
        }

        CaelumEquipmentItem result = CaelumEquipmentItem(
            Actor.Spawn("CaelumWeaponPickup", user.Pos, NO_REPLACE)
        );
        if (result == null)
        {
            user.LastCraftingAction =
                CaelumConstants.CRAFTING_ACTION_FAILED_MATERIALS;
            return;
        }

        if (!user.ConsumeSelectedWeaponCraftingMaterials())
        {
            result.Destroy();
            user.LastCraftingAction =
                CaelumConstants.CRAFTING_ACTION_FAILED_MATERIALS;
            return;
        }

        result.EquipmentKind = CaelumConstants.EQUIPMENT_KIND_WEAPON;
        result.ItemType = user.CraftingSelectedEssenceWeaponType;
        result.ArmorSlot = -1;
        result.Tier = user.CraftingSelectionTier;
        result.EquipmentSize = user.CraftingSelectionSize;
        result.Durability = user.WeaponModel.GetMaximumDurabilityFor(
            user.CraftingSelectedEssenceWeaponType,
            user.CraftingSelectionTier,
            user.CraftingSelectionSize
        );
        result.EssenceType = user.CraftingSelectedEssenceType;
        result.UnitWeight = user.WeaponModel.GetWeightFor(
            user.CraftingSelectedEssenceWeaponType,
            user.CraftingSelectionTier,
            user.CraftingSelectionSize
        );
        result.Equipped = false;
        result.InMagicBox = !CaelumMainM00RonnieTrial.CanUsePersonalCraftingOutput(user);
        result.PickupDataInitialized = true;
        result.AttachToOwner(user);
        user.EnsureEquipmentItemId(result);
        CaelumNotifications.Acquired(user, result, 1);

        CaelumPersistentCharacterState persistentState =
            user.GetPersistentCharacterState(true);
        if (persistentState != null)
        {
            persistentState.RegisterOwnedWeapon(
                user.CraftingSelectedEssenceWeaponType,
                user.CraftingSelectionTier,
                user.CraftingSelectionSize,
                result.Durability
            );
            persistentState.SetWeaponInMagicBox(
                user.CraftingSelectedEssenceWeaponType,
                user.CraftingSelectionTier,
                user.CraftingSelectionSize,
                result.InMagicBox
            );
            persistentState.SetWeaponEquipped(
                user.CraftingSelectedEssenceWeaponType,
                user.CraftingSelectionTier,
                user.CraftingSelectionSize,
                false
            );
        }

        CaelumMainM00RonnieTrial.RecordCraft(user, result);
        user.LastCraftingAction = CaelumConstants.CRAFTING_ACTION_CREATED;
        user.ApplyCharacterProfile();
        user.PersistCharacterState();
        user.RefreshEquipmentSelectionPreview();
        user.RefreshCraftingPreview();
    }

    static void CraftSelectedJewelry(CaelumPlayer user, bool seal)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return;
        user.RefreshCraftingPreview();
        int expected = seal ? CaelumConstants.CRAFTING_RECIPE_KIND_SEAL
            : CaelumConstants.CRAFTING_RECIPE_KIND_AMULET;
        if (user.CraftingSelectedRecipeKind != expected) return;
        if (!user.CraftingSelectedInfrastructureAvailable)
        { user.LastCraftingAction = CaelumConstants.CRAFTING_ACTION_FAILED_INFRASTRUCTURE; return; }
        int kind = seal ? CaelumConstants.EQUIPMENT_KIND_SEAL : CaelumConstants.EQUIPMENT_KIND_AMULET;
        int type = seal ? user.CraftingSelectedSealType : user.CraftingSelectedAmuletType;
        bool personalOutput = CaelumMainM00RonnieTrial.CanUsePersonalCraftingOutput(user);
        if (!personalOutput && !user.HasNativeMagicBoxSlotAvailable())
        { user.LastCraftingAction = CaelumConstants.CRAFTING_ACTION_FAILED_BOX_FULL; return; }
        if (!user.HasSelectedWeaponCraftingMaterials())
        { user.LastCraftingAction = CaelumConstants.CRAFTING_ACTION_FAILED_MATERIALS; return; }

        CaelumEquipmentItem result;
        if (seal)
        {
            result = CaelumEquipmentItem(
                Actor.Spawn("CaelumSealPickup", user.Pos, NO_REPLACE)
            );
        }
        else
        {
            result = CaelumEquipmentItem(
                Actor.Spawn("CaelumAmuletPickup", user.Pos, NO_REPLACE)
            );
        }
        if (result == null) { user.LastCraftingAction = CaelumConstants.CRAFTING_ACTION_FAILED_MATERIALS; return; }
        // La transacción nunca puede degradarse silenciosamente a una pieza de
        // armadura aunque exista una colisión o reemplazo de clases externos.
        if ((seal && CaelumSealPickup(result) == null)
            || (!seal && CaelumAmuletPickup(result) == null))
        {
            result.Destroy();
            user.LastCraftingAction = CaelumConstants.CRAFTING_ACTION_FAILED_STATION;
            return;
        }
        if (!user.ConsumeSelectedWeaponCraftingMaterials())
        { result.Destroy(); user.LastCraftingAction = CaelumConstants.CRAFTING_ACTION_FAILED_MATERIALS; return; }

        result.EquipmentKind=kind; result.ItemType=type; result.ArmorSlot=-1;
        result.Tier=user.CraftingSelectionTier; result.EquipmentSize=CaelumConstants.EQUIPMENT_SIZE_M;
        result.Durability=0; result.EssenceType=seal ? type : CaelumConstants.ESSENCE_FIRE;
        result.UnitWeight=CaelumCraftingRules.GetJewelryWeight(user.CraftingSelectionTier);
        result.Equipped=false; result.InMagicBox=!personalOutput; result.PickupDataInitialized=true; result.AttachToOwner(user);
        user.EnsureEquipmentItemId(result);
        CaelumNotifications.Acquired(user, result, 1);
        CaelumMainM00SealCrafting.RecordCraft(user, result);
        user.LastCraftingAction=CaelumConstants.CRAFTING_ACTION_CREATED;
        user.ApplyCharacterProfile();
        user.PersistCharacterState();
        user.RefreshCraftingPreview();
        // Se aplica al final de la transacción, después de toda sincronización,
        // para que ninguna actualización intermedia restaure Cabeza/Armadura.
        user.EquipmentSelectionKind = kind;
        user.EquipmentSelectionTier = user.CraftingSelectionTier;
        user.EquipmentSelectionSize = CaelumConstants.EQUIPMENT_SIZE_M;
        if (seal) { user.EquipmentSelectionSealType = type; }
        else { user.EquipmentSelectionAmuletType = type; }
        user.RefreshEquipmentSelectionPreview();
    }

    static void CraftSelectedAmmunition(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return;
        if (!user.CraftingTaskCompleting || !user.CraftingSelectedInfrastructureAvailable
            || !user.ValidateCraftingTaskReservations())
        { user.LastCraftingAction = CaelumConstants.CRAFTING_ACTION_FAILED_MATERIALS; return; }
        int ammoType = CaelumCraftingRules.GetRecipeAmmunitionType(user.CraftingSelectionRecipe);
        int batch = CaelumCraftingRules.GetRecipeAmmunitionBatch(user.CraftingSelectionRecipe);
        if (ammoType < 0 || batch <= 0) return;
        Name ammoClass = user.GetAmmunitionClassName(ammoType);
        let ammunition = Inventory(user.FindInventory(ammoClass));
        bool created = ammunition == null;
        if (created) ammunition = Inventory(Actor.Spawn(ammoClass, user.Pos, NO_REPLACE));
        if (ammunition == null) return;
        int oldAmount = created ? 0 : ammunition.Amount;
        if (oldAmount > ammunition.MaxAmount - batch
            || !user.ConsumeCraftingTaskReservations())
        {
            if (created) ammunition.Destroy();
            user.LastCraftingAction = CaelumConstants.CRAFTING_ACTION_FAILED_MATERIALS; return;
        }
        ammunition.Amount = oldAmount + batch;
        if (created) ammunition.AttachToOwner(user);
        CaelumNotifications.Acquired(user, ammunition, batch);
        // Munición no cuenta como primera arma ni sustituye su ItemId.
        user.LastCraftingAction = CaelumConstants.CRAFTING_ACTION_CREATED;
        user.OnNativeInventoryChanged();
    }

    static void CraftSelectedPhysicalWeapon(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return;
        user.RefreshCraftingPreview();

        if (!user.CraftingTaskCompleting)
        {
            user.BeginSelectedCraftingTask();
            return;
        }

        if (!user.CraftingSelectedRecipeKnown)
        {
            user.LastCraftingAction =
                CaelumConstants.CRAFTING_ACTION_FAILED_RECIPE_LOCKED;
            return;
        }

        if (user.CraftingSelectedRecipeKind
                != CaelumConstants.CRAFTING_RECIPE_KIND_PROCESSING
            && user.CraftingSelectedRecipeKind
                != CaelumConstants.CRAFTING_RECIPE_KIND_COMPONENT
            && !user.CanCompletePreparedEquipmentOutput(user.CraftingFinalWeight))
        {
            user.LastCraftingAction =
                CaelumConstants.CRAFTING_ACTION_FAILED_CARRY_CAPACITY;
            return;
        }

        if (user.CraftingSelectedRecipeKind == CaelumConstants.CRAFTING_RECIPE_KIND_AMMUNITION)
        { user.CraftSelectedAmmunition(); return; }
        if (user.CraftingSelectedRecipeKind
            == CaelumConstants.CRAFTING_RECIPE_KIND_ARMOR)
        {
            user.CraftSelectedArmorRecipe();
            return;
        }
        if (user.CraftingSelectedRecipeKind
            == CaelumConstants.CRAFTING_RECIPE_KIND_SHIELD)
        {
            user.CraftSelectedShieldRecipe();
            return;
        }
        if (user.CraftingSelectedRecipeKind
            == CaelumConstants.CRAFTING_RECIPE_KIND_ESSENCE_WEAPON)
        {
            user.CraftSelectedEssenceWeaponRecipe();
            return;
        }
        if (user.CraftingSelectedRecipeKind == CaelumConstants.CRAFTING_RECIPE_KIND_AMULET)
        { user.CraftSelectedJewelry(false); return; }
        if (user.CraftingSelectedRecipeKind == CaelumConstants.CRAFTING_RECIPE_KIND_SEAL)
        { user.CraftSelectedJewelry(true); return; }
        if (user.CraftingSelectedRecipeKind
                == CaelumConstants.CRAFTING_RECIPE_KIND_PROCESSING
            || user.CraftingSelectedRecipeKind
                == CaelumConstants.CRAFTING_RECIPE_KIND_COMPONENT)
        {
            user.CraftSelectedProcessingRecipe();
            return;
        }

        if (user.CraftingSelectedWeapon < 0)
        {
            user.LastCraftingAction = CaelumConstants.CRAFTING_ACTION_FAILED_STATION;
            return;
        }
        if (!CaelumCraftingRules.CanNetworkCraftWeapon(
            user.CraftingNetworkCapabilities,
            user.CraftingSelectionTier,
            user.CraftingSelectedWeapon
        ))
        {
            user.CraftingMissingStationType =
                CaelumCraftingRules.GetMissingNetworkStation(
                    user.CraftingNetworkCapabilities,
                    user.CraftingSelectionTier,
                    user.CraftingSelectedWeapon
                );
            user.CraftingSelectedInfrastructureAvailable = false;
            user.LastCraftingAction =
                CaelumConstants.CRAFTING_ACTION_FAILED_INFRASTRUCTURE;
            return;
        }
        int playableWeaponType = CaelumCraftingRules.GetPlayableWeaponType(
            user.CraftingSelectedWeapon
        );
        if (playableWeaponType < 0 || user.WeaponModel == null) { return; }
        if (!CaelumMainM00RonnieTrial.CanUsePersonalCraftingOutput(user) && !user.HasNativeMagicBoxSlotAvailable())
        {
            user.LastCraftingAction =
                CaelumConstants.CRAFTING_ACTION_FAILED_BOX_FULL;
            return;
        }
        if (!user.HasSelectedWeaponCraftingMaterials())
        {
            user.LastCraftingAction =
                CaelumConstants.CRAFTING_ACTION_FAILED_MATERIALS;
            return;
        }

        CaelumEquipmentItem result = CaelumEquipmentItem(
            Actor.Spawn("CaelumWeaponPickup", user.Pos, NO_REPLACE)
        );
        if (result == null)
        {
            user.LastCraftingAction =
                CaelumConstants.CRAFTING_ACTION_FAILED_MATERIALS;
            return;
        }

        // La validación completa ocurre antes de modificar pilas. Como los
        // componentes de estas recetas son distintos, ambas restas son una
        // única transacción lógica y nunca dejan un crafteo parcial.
        if (!user.ConsumeSelectedWeaponCraftingMaterials())
        {
            result.Destroy();
            user.LastCraftingAction =
                CaelumConstants.CRAFTING_ACTION_FAILED_MATERIALS;
            return;
        }
        result.EquipmentKind = CaelumConstants.EQUIPMENT_KIND_WEAPON;
        result.ItemType = playableWeaponType;
        result.ArmorSlot = -1;
        result.Tier = user.CraftingSelectionTier;
        result.EquipmentSize = user.CraftingSelectionSize;
        result.Durability = user.WeaponModel.GetMaximumDurabilityFor(
            playableWeaponType,
            user.CraftingSelectionTier,
            user.CraftingSelectionSize
        );
        result.EssenceType = CaelumConstants.ESSENCE_FIRE;
        result.UnitWeight = user.WeaponModel.GetWeightFor(
            playableWeaponType,
            user.CraftingSelectionTier,
            user.CraftingSelectionSize
        );
        // La pieza nace con durabilidad actual; no debe migrarse como un save antiguo.
        result.WeaponDurabilityRevision = CaelumAttackRules.DURABILITY_REVISION;
        result.Equipped = false;
        result.InMagicBox = !CaelumMainM00RonnieTrial.CanUsePersonalCraftingOutput(user);
        result.PickupDataInitialized = true;
        result.AttachToOwner(user);
        user.EnsureEquipmentItemId(result);
        CaelumNotifications.Acquired(user, result, 1);

        CaelumPersistentCharacterState persistentState =
            user.GetPersistentCharacterState(true);
        if (persistentState != null)
        {
            persistentState.RegisterOwnedWeapon(
                playableWeaponType,
                user.CraftingSelectionTier,
                user.CraftingSelectionSize,
                result.Durability
            );
            persistentState.SetWeaponInMagicBox(
                playableWeaponType,
                user.CraftingSelectionTier,
                user.CraftingSelectionSize,
                result.InMagicBox
            );
            persistentState.SetWeaponEquipped(
                playableWeaponType,
                user.CraftingSelectionTier,
                user.CraftingSelectionSize,
                false
            );
        }

        CaelumMainM00RonnieTrial.RecordCraft(user, result);
        user.LastCraftingAction = CaelumConstants.CRAFTING_ACTION_CREATED;
        user.ApplyCharacterProfile();
        user.PersistCharacterState();
        user.RefreshEquipmentSelectionPreview();
        user.RefreshCraftingPreview();
    }

    static Name GetConsumableClassName(CaelumPlayer user, int consumableType)
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
            case 5: return 'CaelumBottleSmall';
            case 6: return 'CaelumBottleNormal';
            case 7: return 'CaelumBottleLarge';
            case 8: return 'CaelumCanteenSmall';
            case 9: return 'CaelumCanteenNormal';
            case 10: return 'CaelumCanteenLarge';
            default:
                return 'CaelumLifePotion';
        }
    }

    static double GetAmmunitionUnitWeight(CaelumPlayer user, int ammunitionType)
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

    static Name GetAmmunitionClassName(CaelumPlayer user, int ammunitionType)
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

    static Name GetSpecialItemClassName(CaelumPlayer user, int specialCategory, int specialType)
    {
        if (specialCategory == CaelumConstants.EQUIPMENT_KIND_CURRENCY)
        {
            return CaelumEconomyRules.GetCurrencyClassName(specialType);
        }
        if (specialCategory == CaelumConstants.EQUIPMENT_KIND_KEY)
        {
            if(specialType==1)return 'CaelumMazeSluiceKey';
            if(specialType==2)return 'CaelumMazeCryptKey';
            if(specialType==3)return 'CaelumMazeSanctumKey';
            return 'CaelumSilverKey';
        }
        if (specialCategory == CaelumConstants.EQUIPMENT_KIND_KEY_ITEM)
        {
            if (specialType == CaelumConstants.KEY_ITEM_TAROT_DECK) return 'CaelumTarotDeck';
            if (specialType == CaelumConstants.KEY_ITEM_SLEEPING_BAG) return 'CaelumSleepingBag';
            if (specialType == CaelumConstants.KEY_ITEM_PROCESSING_MANUAL)
            {
                return 'CaelumProcessingManual';
            }
            return 'CaelumSealedLetter';
        }
        if (specialType == CaelumConstants.MATERIAL_IRON_INGOT)
        {
            return 'CaelumIronIngot';
        }
        return 'CaelumMaterialPickup';
    }

    static void UseSelectedConsumable(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return;
        user.LastEquipmentAction = CaelumConstants.EQUIPMENT_ACTION_FAILED_NOT_OWNED;
        CaelumConsumableItem consumable = user.FindNativeConsumableItem(
            user.EquipmentSelectionConsumableType
        );
        if (consumable == null || consumable.Amount <= 0
            || consumable.InMagicBox)
        {
            return;
        }
        let water = CaelumWaterContainer(consumable);
        if (water != null) { if (!water.Drink()) return; }
        else if (!user.UseInventory(consumable)) { return; }
        user.OnNativeInventoryChanged();
        user.LastEquipmentAction = CaelumConstants.EQUIPMENT_ACTION_USED;
    }

    static void SyncActiveModelsToNativeInventory(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return;
        if (user.ArmorModel != null)
        {
            for (int slot = 0; slot < CaelumConstants.ARMOR_SLOT_COUNT; slot++)
            {
                if (user.ArmorModel.ArmorType[slot]
                    == CaelumConstants.ARMOR_TYPE_BASE_CLOTHING)
                {
                    continue;
                }
                CaelumEquipmentItem armor =
                    user.FindNativeEquipmentItemById(user.EquippedArmorItemId[slot]);
                if (armor == null || !armor.Equipped || !armor.Matches(
                    CaelumConstants.EQUIPMENT_KIND_ARMOR,
                    user.ArmorModel.ArmorType[slot], slot,
                    user.ArmorModel.Tier[slot], user.ArmorModel.Size[slot]
                ))
                {
                    armor = user.FindEquippedNativeEquipmentItem(
                        CaelumConstants.EQUIPMENT_KIND_ARMOR,
                        user.ArmorModel.ArmorType[slot], slot,
                        user.ArmorModel.Tier[slot], user.ArmorModel.Size[slot]
                    );
                }
                if (armor != null && armor.Equipped)
                {
                    user.EquippedArmorItemId[slot] = armor.ItemId;
                    armor.Durability = user.ArmorModel.Durability[slot];
                }
            }
        }
        user.RepairActiveShieldReference();
        if (user.ShieldModel != null && user.ShieldModel.Equipped)
        {
            CaelumEquipmentItem shield =
                user.FindNativeEquipmentItemById(user.EquippedShieldItemId);
            if (shield != null && shield.Equipped)
            {
                user.EquippedShieldItemId = shield.ItemId;
                shield.Durability = user.ShieldModel.Durability;
            }
        }
        if (user.WeaponModel != null && user.WeaponModel.Equipped)
        {
            CaelumEquipmentItem weapon =
                user.FindNativeEquipmentItemById(user.ActiveWeaponItemId);
            if (weapon == null || !weapon.Equipped || !weapon.Matches(
                CaelumConstants.EQUIPMENT_KIND_WEAPON,
                user.WeaponModel.WeaponType, -1,
                user.WeaponModel.Tier, user.WeaponModel.Size
            ) || (user.WeaponModel.IsMagicalType(user.WeaponModel.WeaponType)
                && weapon.EssenceType != user.WeaponModel.EssenceType))
            {
                weapon = user.FindEquippedNativeEquipmentItem(
                    CaelumConstants.EQUIPMENT_KIND_WEAPON,
                    user.WeaponModel.WeaponType, -1,
                    user.WeaponModel.Tier, user.WeaponModel.Size,
                    user.WeaponModel.IsMagicalType(user.WeaponModel.WeaponType)
                        ? user.WeaponModel.EssenceType : -1
                );
            }
            if (weapon != null && weapon.Equipped)
            {
                user.ActiveWeaponItemId = weapon.ItemId;
                weapon.Durability = user.WeaponModel.Durability;

            }
        }
    }

    static CaelumEquipmentItem GetSelectedNativeEquipmentItem(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanRead(user)) return null;
        CaelumEquipmentItem identifiedItem =
            user.FindNativeEquipmentItemById(user.EquipmentSelectionItemId);
        if (identifiedItem != null) { return identifiedItem; }
        if (user.EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_WEAPON)
        {
            if (user.WeaponModel != null
                && user.WeaponModel.IsMagicalType(user.EquipmentSelectionWeaponType))
            {
                return user.FindNativeMagicWeaponItem(
                    user.EquipmentSelectionWeaponType,
                    user.EquipmentSelectionWeaponEssenceType,
                    user.EquipmentSelectionTier,
                    user.EquipmentSelectionSize
                );
            }
            return user.FindNativeEquipmentItem(
                CaelumConstants.EQUIPMENT_KIND_WEAPON,
                user.EquipmentSelectionWeaponType, -1,
                user.EquipmentSelectionTier, user.EquipmentSelectionSize
            );
        }
        if (user.EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_SHIELD)
        {
            return user.FindNativeEquipmentItem(
                CaelumConstants.EQUIPMENT_KIND_SHIELD,
                user.EquipmentSelectionShieldType, -1,
                user.EquipmentSelectionTier, user.EquipmentSelectionSize
            );
        }
        if (user.EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_ARMOR)
        {
            return user.FindNativeEquipmentItem(
                CaelumConstants.EQUIPMENT_KIND_ARMOR,
                user.EquipmentSelectionArmorType, user.EquipmentSelectionSlot,
                user.EquipmentSelectionTier, user.EquipmentSelectionSize
            );
        }
        if (user.EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_AMULET)
            return user.FindNativeEquipmentItem(user.EquipmentSelectionKind,user.EquipmentSelectionAmuletType,-1,user.EquipmentSelectionTier,CaelumConstants.EQUIPMENT_SIZE_M);
        if (user.EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_SEAL)
            return user.FindNativeEquipmentItem(user.EquipmentSelectionKind,user.EquipmentSelectionSealType,-1,user.EquipmentSelectionTier,CaelumConstants.EQUIPMENT_SIZE_M);
        return null;
    }

    static void EquipSelectedNativeEquipment(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return;
        user.LastEquipmentAction = CaelumConstants.EQUIPMENT_ACTION_FAILED_NOT_OWNED;
        if (user.EquipmentSelectionKind
            == CaelumConstants.EQUIPMENT_KIND_CONSUMABLE)
        {
            user.UseSelectedConsumable();
            return;
        }
        if (user.EquipmentSelectionKind
            == CaelumConstants.EQUIPMENT_KIND_AMMUNITION)
        {
            return;
        }
        if (user.IsSpecialInventoryKind(user.EquipmentSelectionKind))
        {
            return;
        }
        if (!user.EquipmentSelectionSizeCompatible)
        {
            user.LastEquipmentAction = CaelumConstants.EQUIPMENT_ACTION_FAILED_SIZE;
            return;
        }
        user.SyncActiveModelsToNativeInventory();
        user.RefreshCarriedInventorySummary();
        CaelumEquipmentItem item = user.GetSelectedNativeEquipmentItem();
        if (item == null) { return; }
        if (user.IsEquipmentItemCraftingLocked(item.ItemId))
        {
            user.LastEquipmentAction =
                CaelumConstants.EQUIPMENT_ACTION_FAILED_RESERVED;
            return;
        }
        if (item.InMagicBox
            && !user.CanMoveRawWeightFromMagicBoxToPersonal(item.UnitWeight))
        {
            user.LastEquipmentAction =
                CaelumConstants.EQUIPMENT_ACTION_FAILED_CARRY_CAPACITY;
            return;
        }
        item.InMagicBox = false;

        if (item.EquipmentKind == CaelumConstants.EQUIPMENT_KIND_ARMOR)
        {
            for (Inventory cursor = user.Inv; cursor != null; cursor = cursor.Inv)
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
            user.EquippedArmorItemId[item.ArmorSlot] = item.ItemId;
            user.ArmorModel.ArmorType[item.ArmorSlot] = item.ItemType;
            user.ArmorModel.Tier[item.ArmorSlot] = item.Tier;
            user.ArmorModel.Size[item.ArmorSlot] = item.EquipmentSize;
            user.ArmorModel.Durability[item.ArmorSlot] = item.Durability;
            user.ArmorModel.SelectedSlot = item.ArmorSlot;
        }
        else if (item.EquipmentKind == CaelumConstants.EQUIPMENT_KIND_SHIELD)
        {
            for (Inventory cursor = user.Inv; cursor != null; cursor = cursor.Inv)
            {
                CaelumEquipmentItem other = CaelumEquipmentItem(cursor);
                if (other != null
                    && other.EquipmentKind == CaelumConstants.EQUIPMENT_KIND_SHIELD)
                {
                    other.Equipped = false;
                }
            }
            item.Equipped = true;
            user.EquippedShieldItemId = item.ItemId;
            user.ShieldModel.ShieldType = item.ItemType;
            user.ShieldModel.Tier = item.Tier;
            user.ShieldModel.Size = item.EquipmentSize;
            user.ShieldModel.Durability = item.Durability;
            user.ShieldModel.Equipped = true;
            user.DebugShieldBlocking = false;
        }
        else if (user.IsUniversalJewelryKind(item.EquipmentKind))
        {
            for (Inventory c=user.Inv;c!=null;c=c.Inv)
            {
                CaelumEquipmentItem other=CaelumEquipmentItem(c);
                if (other!=null && other.EquipmentKind==item.EquipmentKind) other.Equipped=false;
            }
            item.Equipped=true;
            if (item.EquipmentKind == CaelumConstants.EQUIPMENT_KIND_AMULET)
            {
                user.EquippedAmuletItemId = item.ItemId;
            }
            else { user.EquippedSealItemId = item.ItemId; }
        }
        else
        {
            // Cada arma física o mágica es una instancia independiente.
            // Equipar Bastón/Fuego no cambia ningún otro Bastón.
            item.Equipped = true;
            user.ActiveWeaponItemId = item.ItemId;
            user.WeaponModel.WeaponType = item.ItemType;
            user.WeaponModel.Tier = item.Tier;
            user.WeaponModel.Size = item.EquipmentSize;
            user.WeaponModel.Durability = item.Durability;
            user.WeaponModel.EssenceType = Clamp(
                item.EssenceType,
                0,
                CaelumConstants.ESSENCE_TYPE_COUNT - 1
            );
            user.SelectedEssenceType = user.WeaponModel.EssenceType;
            user.EquipmentSelectionWeaponEssenceType = user.WeaponModel.EssenceType;
            user.WeaponModel.Equipped = true;
            user.EnsureWeaponFamilySelectors();
            user.EquippedWeaponCooldownRemaining = 0.0;
        }
        user.ApplyCharacterProfile();
        user.PersistCharacterState();
        user.RefreshEquipmentSelectionPreview();
        user.LastEquipmentAction = CaelumConstants.EQUIPMENT_ACTION_EQUIPPED;
    }

    static void UnequipSelectedNativeEquipment(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return;
        user.LastEquipmentAction = CaelumConstants.EQUIPMENT_ACTION_FAILED_NOT_OWNED;
        user.SyncActiveModelsToNativeInventory();
        CaelumEquipmentItem item = user.GetSelectedNativeEquipmentItem();
        if (item == null || !item.Equipped) { return; }
        if (user.IsEquipmentItemCraftingLocked(item.ItemId))
        {
            user.LastEquipmentAction =
                CaelumConstants.EQUIPMENT_ACTION_FAILED_RESERVED;
            return;
        }
        item.Equipped = false;
        if (item.EquipmentKind == CaelumConstants.EQUIPMENT_KIND_ARMOR)
        {
            if (user.EquippedArmorItemId[item.ArmorSlot] == item.ItemId)
            {
                user.EquippedArmorItemId[item.ArmorSlot] = 0;
            }
            user.ArmorModel.ArmorType[item.ArmorSlot] =
                CaelumConstants.ARMOR_TYPE_BASE_CLOTHING;
            user.ArmorModel.Tier[item.ArmorSlot] = 1;
            user.ArmorModel.Size[item.ArmorSlot] = CaelumConstants.EQUIPMENT_SIZE_M;
            user.ArmorModel.Durability[item.ArmorSlot] = 0;
        }
        else if (item.EquipmentKind == CaelumConstants.EQUIPMENT_KIND_SHIELD)
        {
            if (user.EquippedShieldItemId == item.ItemId)
            {
                user.EquippedShieldItemId = 0;
            }
            user.ShieldModel.Equipped = false;
            user.CancelCombatBlockMode();
        }
        else if (user.IsUniversalJewelryKind(item.EquipmentKind))
        {
            if (item.EquipmentKind == CaelumConstants.EQUIPMENT_KIND_AMULET
                && user.EquippedAmuletItemId == item.ItemId)
            {
                user.EquippedAmuletItemId = 0;
            }
            else if (item.EquipmentKind == CaelumConstants.EQUIPMENT_KIND_SEAL
                && user.EquippedSealItemId == item.ItemId)
            {
                user.EquippedSealItemId = 0;
            }
        }
        else
        {
            bool wasActive = user.WeaponModel.Equipped
                && (user.ActiveWeaponItemId > 0
                    ? user.ActiveWeaponItemId == item.ItemId
                    : (user.WeaponModel.WeaponType == item.ItemType
                        && user.WeaponModel.Tier == item.Tier
                        && user.WeaponModel.Size == item.EquipmentSize
                        && (!user.WeaponModel.IsMagicalType(item.ItemType)
                            || user.WeaponModel.EssenceType
                                == item.EssenceType)));
            if (wasActive)
            {
                user.CancelPendingStaffCast(false);
                user.WeaponModel.Equipped = false;
                user.ActiveWeaponItemId = 0;
            }
            user.EnsureWeaponFamilySelectors();
            if (wasActive) { user.ActivateFirstEquippedWeapon(); }
        }
        user.ApplyCharacterProfile();
        user.PersistCharacterState();
        user.RefreshEquipmentSelectionPreview();
        user.LastEquipmentAction = CaelumConstants.EQUIPMENT_ACTION_UNEQUIPPED;
    }

    static void ToggleSelectedMagicBox(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return;
        user.RefreshCarriedInventorySummary();
        double previousWeight = user.DerivedStats == null ? 0 : user.DerivedStats.CarriedItemWeight;
        int selectedId = user.EquipmentSelectionItemId;
        user.ToggleSelectedMagicBoxNative();
        CaelumMainM00RonnieTrial.RecordLoadLesson(user, previousWeight, selectedId);
    }

    static void ToggleSelectedMagicBoxNative(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return;
        if (user.EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_MATERIAL)
        {
            let material = user.FindNativeSpecialItem(user.EquipmentSelectionKind, user.EquipmentSelectionSpecialType, user.EquipmentSelectionTier);
            if (material != null && material.LimboQuestUnits > 0)
            { user.LastEquipmentAction = CaelumConstants.EQUIPMENT_ACTION_FAILED_RESERVED;
              CaelumMainM00RonnieTrial.Feedback(user, "CA_M01_SUPPLY_RESERVED"); return; }
        }

        let loan = user.GetSelectedNativeEquipmentItem();
        if (loan != null && loan.IsLimboTemporary())
        {
            user.LastEquipmentAction = CaelumConstants.EQUIPMENT_ACTION_FAILED_RESERVED;
            CaelumMainM00MagicTrial.Feedback(user, "CA_M01_LOAN_RESERVED", true);
            return;
        }
        user.LastEquipmentAction = CaelumConstants.EQUIPMENT_ACTION_FAILED_NOT_OWNED;
        user.SyncLiveMagicBoxOwnershipFromPersistentState();
        if (!user.MagicBoxOwned)
        {
            user.LastEquipmentAction =
                CaelumConstants.EQUIPMENT_ACTION_FAILED_MAGIC_BOX_UNOWNED;
            return;
        }
        user.RefreshCarriedInventorySummary();
        if (user.IsSelectedMaterialCraftingLocked()
            || user.IsEquipmentItemCraftingLocked(user.EquipmentSelectionItemId))
        {
            user.LastEquipmentAction =
                CaelumConstants.EQUIPMENT_ACTION_FAILED_RESERVED;
            return;
        }
        if (user.EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_KEY)
        {
            user.LastEquipmentAction =
                CaelumConstants.EQUIPMENT_ACTION_FAILED_KEY_STORAGE;
            return;
        }
        if (user.EquipmentSelectionKind
                == CaelumConstants.EQUIPMENT_KIND_MATERIAL
            || user.EquipmentSelectionKind
                == CaelumConstants.EQUIPMENT_KIND_KEY_ITEM
            || user.EquipmentSelectionKind
                == CaelumConstants.EQUIPMENT_KIND_CURRENCY)
        {
            CaelumSpecialInventoryItem specialItem = user.FindNativeSpecialItem(
                user.EquipmentSelectionKind, user.EquipmentSelectionSpecialType,
                user.EquipmentSelectionTier
            );
            if (specialItem == null || specialItem.Amount <= 0) { return; }
            double stackWeight = specialItem.Amount
                * specialItem.GetUnitWeight();
            if (specialItem.InMagicBox)
            {
                if (!user.CanMoveRawWeightFromMagicBoxToPersonal(stackWeight))
                {
                    user.LastEquipmentAction =
                        CaelumConstants.EQUIPMENT_ACTION_FAILED_CARRY_CAPACITY;
                    return;
                }
                specialItem.InMagicBox = false;
                user.LastEquipmentAction =
                    CaelumConstants.EQUIPMENT_ACTION_RETRIEVED_FROM_MAGIC_BOX;
            }
            else
            {
                if (!user.HasNativeMagicBoxSlotAvailable())
                {
                    user.LastEquipmentAction =
                        CaelumConstants.EQUIPMENT_ACTION_FAILED_BOX_FULL;
                    return;
                }
                specialItem.InMagicBox = true;
                user.LastEquipmentAction =
                    CaelumConstants.EQUIPMENT_ACTION_STORED_IN_MAGIC_BOX;
            }
            user.ApplyCharacterProfile();
            user.PersistCharacterState();
            user.RefreshEquipmentSelectionPreview();
            return;
        }
        if (user.EquipmentSelectionKind
            == CaelumConstants.EQUIPMENT_KIND_CONSUMABLE)
        {
            CaelumConsumableItem consumable = user.FindNativeConsumableItem(
                user.EquipmentSelectionConsumableType
            );
            if (consumable == null || consumable.Amount <= 0) { return; }
            double stackWeight = consumable.Amount
                * consumable.GetUnitWeight();
            if (consumable.InMagicBox)
            {
                if (!user.CanMoveRawWeightFromMagicBoxToPersonal(stackWeight))
                {
                    user.LastEquipmentAction =
                        CaelumConstants.EQUIPMENT_ACTION_FAILED_CARRY_CAPACITY;
                    return;
                }
                consumable.InMagicBox = false;
                user.LastEquipmentAction =
                    CaelumConstants.EQUIPMENT_ACTION_RETRIEVED_FROM_MAGIC_BOX;
            }
            else
            {
                if (!user.HasNativeMagicBoxSlotAvailable())
                {
                    user.LastEquipmentAction =
                        CaelumConstants.EQUIPMENT_ACTION_FAILED_BOX_FULL;
                    return;
                }
                consumable.InMagicBox = true;
                user.LastEquipmentAction =
                    CaelumConstants.EQUIPMENT_ACTION_STORED_IN_MAGIC_BOX;
            }
            user.ApplyCharacterProfile();
            user.PersistCharacterState();
            user.RefreshEquipmentSelectionPreview();
            return;
        }
        if (user.EquipmentSelectionKind
            == CaelumConstants.EQUIPMENT_KIND_AMMUNITION)
        {
            Inventory ammunition = user.FindNativeAmmunition(
                user.EquipmentSelectionAmmunitionType
            );
            if (ammunition == null || ammunition.Amount <= 0) { return; }

            // Flechas y virotes son Ammo nativa independiente. De momento
            // permanecen en inventario personal; la Caja Mágica especial sólo
            // se aplica a la pila personalizada de carabina.
            CaelumCarbineAmmo carbineStack = CaelumCarbineAmmo(ammunition);
            if (carbineStack == null)
            {
                user.LastEquipmentAction =
                    CaelumConstants.EQUIPMENT_ACTION_FAILED_STORAGE;
                return;
            }

            double stackWeight = carbineStack.Amount
                * carbineStack.GetUnitWeight();
            if (carbineStack.InMagicBox)
            {
                if (!user.CanMoveRawWeightFromMagicBoxToPersonal(stackWeight))
                {
                    user.LastEquipmentAction =
                        CaelumConstants.EQUIPMENT_ACTION_FAILED_CARRY_CAPACITY;
                    return;
                }
                carbineStack.InMagicBox = false;
                user.LastEquipmentAction =
                    CaelumConstants.EQUIPMENT_ACTION_RETRIEVED_FROM_MAGIC_BOX;
            }
            else
            {
                if (!user.HasNativeMagicBoxSlotAvailable())
                {
                    user.LastEquipmentAction =
                        CaelumConstants.EQUIPMENT_ACTION_FAILED_BOX_FULL;
                    return;
                }
                carbineStack.InMagicBox = true;
                user.LastEquipmentAction =
                    CaelumConstants.EQUIPMENT_ACTION_STORED_IN_MAGIC_BOX;
            }
            user.ApplyCharacterProfile();
            user.PersistCharacterState();
            user.RefreshEquipmentSelectionPreview();
            return;
        }

        CaelumEquipmentItem item = user.GetSelectedNativeEquipmentItem();
        if (item == null) { return; }
        if (item.InMagicBox)
        {
            if (!user.CanMoveRawWeightFromMagicBoxToPersonal(item.UnitWeight))
            {
                user.LastEquipmentAction =
                    CaelumConstants.EQUIPMENT_ACTION_FAILED_CARRY_CAPACITY;
                return;
            }
            item.InMagicBox = false;
            user.LastEquipmentAction =
                CaelumConstants.EQUIPMENT_ACTION_RETRIEVED_FROM_MAGIC_BOX;
        }
        else
        {
            if (!user.HasNativeMagicBoxSlotAvailable())
            {
                user.LastEquipmentAction =
                    CaelumConstants.EQUIPMENT_ACTION_FAILED_BOX_FULL;
                return;
            }
            if (item.Equipped)
            {
                user.UnequipSelectedNativeEquipment();
                item = user.GetSelectedNativeEquipmentItem();
                if (item == null) { return; }
            }
            item.InMagicBox = true;
            user.LastEquipmentAction =
                CaelumConstants.EQUIPMENT_ACTION_STORED_IN_MAGIC_BOX;
        }
        user.ApplyCharacterProfile();
        user.PersistCharacterState();
        user.RefreshEquipmentSelectionPreview();
    }

    static void EquipSelectedEquipment(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return;
        user.EquipSelectedNativeEquipment();
        return;
        user.LastEquipmentAction = CaelumConstants.EQUIPMENT_ACTION_FAILED_NOT_OWNED;
        CaelumPersistentCharacterState persistentState =
            user.GetPersistentCharacterState(false);
        if (persistentState == null) { return; }
        persistentState.EnsureEquipmentSizeInitialized();
        persistentState.MigrateWeaponDurability();
        if (!user.EquipmentSelectionSizeCompatible)
        {
            user.LastEquipmentAction = CaelumConstants.EQUIPMENT_ACTION_FAILED_SIZE;
            return;
        }
        user.ApplyCharacterProfile();
        if (user.EquipmentSelectionInMagicBox
            && !user.CanMoveRawWeightFromMagicBoxToPersonal(
                user.EquipmentSelectionWeight
            ))
        {
            user.LastEquipmentAction =
                CaelumConstants.EQUIPMENT_ACTION_FAILED_CARRY_CAPACITY;
            return;
        }

        if (user.EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_WEAPON)
        {
            if (user.WeaponModel == null || !persistentState.OwnsWeapon(
                user.EquipmentSelectionWeaponType,
                user.EquipmentSelectionTier,
                user.EquipmentSelectionSize
            ))
            {
                return;
            }
            persistentState.SetWeaponEquipped(
                user.EquipmentSelectionWeaponType,
                user.EquipmentSelectionTier,
                user.EquipmentSelectionSize,
                true
            );
            persistentState.SetWeaponInMagicBox(
                user.EquipmentSelectionWeaponType,
                user.EquipmentSelectionTier,
                user.EquipmentSelectionSize,
                false
            );
            // Equipar prepara el arma sin sustituir la activa. Solo se activa
            // inmediatamente cuando el personaje no tenía ninguna en uso.
            if (!user.WeaponModel.Equipped)
            {
                user.ActivateEquippedWeaponType(user.EquipmentSelectionWeaponType);
            }
            user.EnsureWeaponFamilySelectors();
            user.EquippedWeaponCooldownRemaining = 0.0;
        }
        else if (user.EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_SHIELD)
        {
            if (user.ShieldModel == null || !persistentState.OwnsShield(
                user.EquipmentSelectionShieldType,
                user.EquipmentSelectionTier,
                user.EquipmentSelectionSize
            ))
            {
                return;
            }
            if (user.ShieldModel.Equipped)
            {
                persistentState.RegisterOwnedShield(
                    user.ShieldModel.ShieldType,
                    user.ShieldModel.Tier,
                    user.ShieldModel.Size,
                    user.ShieldModel.Durability
                );
                persistentState.StoreOwnedShieldDurability(
                    user.ShieldModel.ShieldType,
                    user.ShieldModel.Tier,
                    user.ShieldModel.Size,
                    user.ShieldModel.Durability
                );
                persistentState.SetShieldInMagicBox(
                    user.ShieldModel.ShieldType,
                    user.ShieldModel.Tier,
                    user.ShieldModel.Size,
                    false
                );
            }
            user.ShieldModel.ShieldType = user.EquipmentSelectionShieldType;
            user.ShieldModel.Tier = user.EquipmentSelectionTier;
            user.ShieldModel.Size = user.EquipmentSelectionSize;
            user.ShieldModel.Durability = persistentState.GetOwnedShieldDurability(
                user.EquipmentSelectionShieldType,
                user.EquipmentSelectionTier,
                user.EquipmentSelectionSize
            );
            user.ShieldModel.Equipped = true;
            persistentState.SetShieldInMagicBox(
                user.EquipmentSelectionShieldType,
                user.EquipmentSelectionTier,
                user.EquipmentSelectionSize,
                false
            );
            user.DebugShieldBlocking = false;
        }
        else
        {
            if (user.ArmorModel == null || !persistentState.OwnsArmor(
                user.EquipmentSelectionSlot,
                user.EquipmentSelectionArmorType,
                user.EquipmentSelectionTier,
                user.EquipmentSelectionSize
            ))
            {
                return;
            }
            if (user.ArmorModel.ArmorType[user.EquipmentSelectionSlot]
                != CaelumConstants.ARMOR_TYPE_BASE_CLOTHING)
            {
                persistentState.RegisterOwnedArmor(
                    user.EquipmentSelectionSlot,
                    user.ArmorModel.ArmorType[user.EquipmentSelectionSlot],
                    user.ArmorModel.Tier[user.EquipmentSelectionSlot],
                    user.ArmorModel.Size[user.EquipmentSelectionSlot],
                    user.ArmorModel.Durability[user.EquipmentSelectionSlot]
                );
                persistentState.StoreOwnedArmorDurability(
                    user.EquipmentSelectionSlot,
                    user.ArmorModel.ArmorType[user.EquipmentSelectionSlot],
                    user.ArmorModel.Tier[user.EquipmentSelectionSlot],
                    user.ArmorModel.Size[user.EquipmentSelectionSlot],
                    user.ArmorModel.Durability[user.EquipmentSelectionSlot]
                );
                persistentState.SetArmorInMagicBox(
                    user.EquipmentSelectionSlot,
                    user.ArmorModel.ArmorType[user.EquipmentSelectionSlot],
                    user.ArmorModel.Tier[user.EquipmentSelectionSlot],
                    user.ArmorModel.Size[user.EquipmentSelectionSlot],
                    false
                );
            }
            user.ArmorModel.ArmorType[user.EquipmentSelectionSlot] =
                user.EquipmentSelectionArmorType;
            user.ArmorModel.Tier[user.EquipmentSelectionSlot] = user.EquipmentSelectionTier;
            user.ArmorModel.Size[user.EquipmentSelectionSlot] = user.EquipmentSelectionSize;
            user.ArmorModel.Durability[user.EquipmentSelectionSlot] =
                persistentState.GetOwnedArmorDurability(
                    user.EquipmentSelectionSlot,
                    user.EquipmentSelectionArmorType,
                    user.EquipmentSelectionTier,
                    user.EquipmentSelectionSize
                );
            user.ArmorModel.SelectedSlot = user.EquipmentSelectionSlot;
            persistentState.SetArmorInMagicBox(
                user.EquipmentSelectionSlot,
                user.EquipmentSelectionArmorType,
                user.EquipmentSelectionTier,
                user.EquipmentSelectionSize,
                false
            );
        }

        user.ApplyCharacterProfile();
        user.PersistCharacterState();
        user.RefreshEquipmentSelectionPreview();
        user.LastEquipmentAction = CaelumConstants.EQUIPMENT_ACTION_EQUIPPED;
    }

    static void UnequipSelectedEquipment(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return;
        user.UnequipSelectedNativeEquipment();
        return;
        user.LastEquipmentAction = CaelumConstants.EQUIPMENT_ACTION_FAILED_NOT_OWNED;
        CaelumPersistentCharacterState persistentState =
            user.GetPersistentCharacterState(true);
        if (persistentState == null) { return; }
        persistentState.EnsureEquipmentSizeInitialized();
        persistentState.MigrateWeaponDurability();

        if (user.EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_WEAPON)
        {
            if (user.WeaponModel == null || !persistentState.IsWeaponEquipped(
                user.EquipmentSelectionWeaponType,
                user.EquipmentSelectionTier,
                user.EquipmentSelectionSize
            )) { return; }
            bool removingActiveWeapon = user.WeaponModel.Equipped
                && user.WeaponModel.WeaponType == user.EquipmentSelectionWeaponType
                && user.WeaponModel.Tier == user.EquipmentSelectionTier
                && user.WeaponModel.Size == user.EquipmentSelectionSize;
            if (removingActiveWeapon)
            {
                persistentState.StoreOwnedWeaponDurability(
                    user.WeaponModel.WeaponType,
                    user.WeaponModel.Tier,
                    user.WeaponModel.Size,
                    user.WeaponModel.Durability
                );
            }
            persistentState.SetWeaponEquipped(
                user.EquipmentSelectionWeaponType,
                user.EquipmentSelectionTier,
                user.EquipmentSelectionSize,
                false
            );
            persistentState.SetWeaponInMagicBox(
                user.EquipmentSelectionWeaponType,
                user.EquipmentSelectionTier,
                user.EquipmentSelectionSize,
                false
            );
            if (removingActiveWeapon) { user.ActivateFirstEquippedWeapon(); }
            user.EnsureWeaponFamilySelectors();
            user.EquippedWeaponCooldownRemaining = 0.0;
        }
        else if (user.EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_SHIELD)
        {
            if (user.ShieldModel == null || !user.ShieldModel.Equipped) { return; }
            persistentState.RegisterOwnedShield(
                user.ShieldModel.ShieldType,
                user.ShieldModel.Tier,
                user.ShieldModel.Size,
                user.ShieldModel.Durability
            );
            persistentState.StoreOwnedShieldDurability(
                user.ShieldModel.ShieldType,
                user.ShieldModel.Tier,
                user.ShieldModel.Size,
                user.ShieldModel.Durability
            );
            persistentState.SetShieldInMagicBox(
                user.ShieldModel.ShieldType,
                user.ShieldModel.Tier,
                user.ShieldModel.Size,
                false
            );
            user.ShieldModel.Equipped = false;
            user.DebugShieldBlocking = false;
        }
        else
        {
            if (user.ArmorModel == null) { return; }
            int slot = user.EquipmentSelectionSlot;
            if (user.ArmorModel.ArmorType[slot]
                == CaelumConstants.ARMOR_TYPE_BASE_CLOTHING)
            {
                return;
            }
            persistentState.RegisterOwnedArmor(
                slot,
                user.ArmorModel.ArmorType[slot],
                user.ArmorModel.Tier[slot],
                user.ArmorModel.Size[slot],
                user.ArmorModel.Durability[slot]
            );
            persistentState.StoreOwnedArmorDurability(
                slot,
                user.ArmorModel.ArmorType[slot],
                user.ArmorModel.Tier[slot],
                user.ArmorModel.Size[slot],
                user.ArmorModel.Durability[slot]
            );
            persistentState.SetArmorInMagicBox(
                slot,
                user.ArmorModel.ArmorType[slot],
                user.ArmorModel.Tier[slot],
                user.ArmorModel.Size[slot],
                false
            );
            user.ArmorModel.ArmorType[slot] = CaelumConstants.ARMOR_TYPE_BASE_CLOTHING;
            user.ArmorModel.Tier[slot] = 1;
            user.ArmorModel.Size[slot] = CaelumConstants.EQUIPMENT_SIZE_M;
            user.ArmorModel.Durability[slot] = 0;
            user.ArmorModel.SelectedSlot = slot;
        }

        user.ApplyCharacterProfile();
        user.PersistCharacterState();
        user.RefreshEquipmentSelectionPreview();
        user.LastEquipmentAction = CaelumConstants.EQUIPMENT_ACTION_UNEQUIPPED;
    }

    static void SpawnSelectedNativePickupOnFloor(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return;
        if (user.player == null || user.player.playerstate != PST_LIVE) { return; }
        Vector3 spawnPos = user.Pos + (
            Cos(user.Angle) * 56.0,
            Sin(user.Angle) * 56.0,
            8.0
        );
        Actor pickup;
        if (user.IsSpecialInventoryKind(user.EquipmentSelectionKind))
        {
            Name specialClass = user.GetSpecialItemClassName(
                user.EquipmentSelectionKind, user.EquipmentSelectionSpecialType
            );
            pickup = Actor.Spawn(specialClass, spawnPos, NO_REPLACE);
            if (pickup != null
                && user.EquipmentSelectionKind
                    == CaelumConstants.EQUIPMENT_KIND_MATERIAL)
            {
                pickup.args[0] = user.EquipmentSelectionSpecialType;
                pickup.args[1] = user.EquipmentSelectionTier;
                Inventory(pickup).Amount = 10;
            }
            else if (pickup != null
                && user.EquipmentSelectionKind
                    == CaelumConstants.EQUIPMENT_KIND_CURRENCY)
            {
                Inventory(pickup).Amount = 100;
            }
        }
        else if (user.EquipmentSelectionKind
            == CaelumConstants.EQUIPMENT_KIND_CONSUMABLE)
        {
            Name consumableClass = user.GetConsumableClassName(
                user.EquipmentSelectionConsumableType
            );
            pickup = Actor.Spawn(consumableClass, spawnPos, NO_REPLACE);
            if (pickup != null) { Inventory(pickup).Amount = 5; }
        }
        else if (user.EquipmentSelectionKind
            == CaelumConstants.EQUIPMENT_KIND_AMMUNITION)
        {
            pickup = Actor.Spawn(
                user.GetAmmunitionClassName(user.EquipmentSelectionAmmunitionType),
                spawnPos,
                NO_REPLACE
            );
            if (pickup != null)
            {
                bool isJavelin = user.EquipmentSelectionAmmunitionType
                    >= CaelumConstants.AMMUNITION_JAVELIN_TIER_ONE;
                Inventory(pickup).Amount = isJavelin ? 5 : 100;
            }
        }
        else if (user.EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_WEAPON)
        {
            pickup = Actor.Spawn("CaelumWeaponPickup", spawnPos, NO_REPLACE);
            if (pickup != null)
            {
                pickup.args[0] = user.EquipmentSelectionWeaponType;
                pickup.args[1] = user.EquipmentSelectionTier;
                pickup.args[2] = user.EquipmentSelectionSize + 1;
                pickup.args[4] = user.SelectedEssenceType + 1;
            }
        }
        else if (user.EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_SHIELD)
        {
            pickup = Actor.Spawn("CaelumShieldPickup", spawnPos, NO_REPLACE);
            if (pickup != null)
            {
                pickup.args[0] = user.EquipmentSelectionShieldType;
                pickup.args[1] = user.EquipmentSelectionTier;
                pickup.args[2] = user.EquipmentSelectionSize + 1;
            }
        }
        else if (user.EquipmentSelectionKind
            == CaelumConstants.EQUIPMENT_KIND_AMULET)
        {
            pickup = Actor.Spawn("CaelumAmuletPickup", spawnPos, NO_REPLACE);
            if (pickup != null)
            {
                pickup.args[0] = user.EquipmentSelectionAmuletType;
                pickup.args[1] = user.EquipmentSelectionTier;
            }
        }
        else if (user.EquipmentSelectionKind
            == CaelumConstants.EQUIPMENT_KIND_SEAL)
        {
            pickup = Actor.Spawn("CaelumSealPickup", spawnPos, NO_REPLACE);
            if (pickup != null)
            {
                pickup.args[0] = user.EquipmentSelectionSealType;
                pickup.args[1] = user.EquipmentSelectionTier;
            }
        }
        else
        {
            // Sólo ARMOR llega a este fallback. Antes Amulet y Seal también
            // caían aquí y la herramienta de desarrollo creaba un casco.
            pickup = Actor.Spawn("CaelumArmorPickup", spawnPos, NO_REPLACE);
            if (pickup != null)
            {
                pickup.args[0] = user.EquipmentSelectionSlot;
                pickup.args[1] = user.EquipmentSelectionArmorType;
                pickup.args[2] = user.EquipmentSelectionTier;
                pickup.args[3] = user.EquipmentSelectionSize + 1;
            }
        }
        let authoredEquipment=CaelumEquipmentItem(pickup);
        if (authoredEquipment!=null)
            authoredEquipment.SizePolicy=CaelumEquipmentRules.FIXED_SIZE;
        user.LastEquipmentAction = pickup != null
            ? CaelumConstants.EQUIPMENT_ACTION_SPAWNED_ON_FLOOR
            : CaelumConstants.EQUIPMENT_ACTION_FAILED_NOT_OWNED;
        user.RefreshEquipmentSelectionPreview();
    }

    static bool IsDurabilityTaskEquipment(CaelumPlayer user, CaelumEquipmentItem item)
    {
        return item != null && !item.IsLimboTemporary()
            && (item.EquipmentKind == CaelumConstants.EQUIPMENT_KIND_WEAPON
                || item.EquipmentKind
                    == CaelumConstants.EQUIPMENT_KIND_ARMOR
                || item.EquipmentKind
                    == CaelumConstants.EQUIPMENT_KIND_SHIELD);
    }

    static int GetEquipmentTaskMaximumDurability(CaelumPlayer user, CaelumEquipmentItem item)
    {
        if (!CaelumPlayerAuthority.CanRead(user)) return 0;
        return user.GetFormalInventoryMaximumDurability(item);
    }

    static double GetEquipmentTaskWeight(CaelumPlayer user, CaelumEquipmentItem item)
    {
        if (!CaelumPlayerAuthority.CanRead(user)) return 0;
        if (item == null) { return 0.0; }
        if (item.EquipmentKind == CaelumConstants.EQUIPMENT_KIND_WEAPON
            && user.WeaponModel != null)
        {
            return user.WeaponModel.GetWeightFor(
                item.ItemType, item.Tier, item.EquipmentSize
            );
        }
        if (item.EquipmentKind == CaelumConstants.EQUIPMENT_KIND_ARMOR
            && user.ArmorModel != null)
        {
            return user.ArmorModel.GetWeightFor(
                item.ArmorSlot, item.ItemType,
                item.Tier, item.EquipmentSize
            );
        }
        if (item.EquipmentKind == CaelumConstants.EQUIPMENT_KIND_SHIELD
            && user.ShieldModel != null)
        {
            return user.ShieldModel.GetWeightFor(
                item.ItemType, item.Tier, item.EquipmentSize
            );
        }
        return item.UnitWeight;
    }

    static bool AddScaledEquipmentTaskMaterial(CaelumPlayer user, int materialType, int materialTier, int fullUnits, double durabilityFraction, bool recovery, CaelumCraftingBrowser preview = null)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return false;
        if (preview != null && preview != user.CraftingBrowser) return false;
        int units = recovery
            ? CaelumCraftingRules.GetRecoveredMaterialUnits(
                fullUnits, durabilityFraction
            )
            : CaelumCraftingRules.GetProportionalInputUnits(
                fullUnits, durabilityFraction
            );
        if (!recovery)
        {
            units = CaelumCraftingRules.GetEfficiencyAdjustedInputUnits(
                units, user.CraftingEfficiencyIndex
            );
        }
        if (preview != null) { preview.AddMaterial(materialType, materialTier, units); return true; }
        if (recovery)
        {
            return user.AddCraftingTaskOutput(
                materialType, materialTier, units
            );
        }
        // Reparar comparte el resolvedor recursivo de fabricacion: primero
        // usa componentes existentes y completa solo lo faltante desde crudos.
        user.CraftingPreparedEquipmentInputUnits += units;
        return user.RequireDirectCraftingMaterial(
            materialType, materialTier, units
        );
    }

    static bool BuildEquipmentTaskMaterials(CaelumPlayer user, CaelumEquipmentItem item, double durabilityFraction, bool recovery, CaelumCraftingBrowser preview = null)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return false;
        if (preview != null && preview != user.CraftingBrowser) return false;
        if (item == null || item.Owner != user) return false;
        if (!user.IsDurabilityTaskEquipment(item)) { return false; }
        double finalWeight = user.GetEquipmentTaskWeight(item);
        int basicType;
        int basicTier = 1;
        int basicUnits;
        int tierType;
        int tierTier;
        int tierUnits;

        if (item.EquipmentKind == CaelumConstants.EQUIPMENT_KIND_WEAPON)
        {
            if (user.WeaponModel != null
                && user.WeaponModel.IsMagicalType(item.ItemType))
            {
                basicType = CaelumCraftingRules.GetEssenceBaseMaterial(
                    item.ItemType
                );
                tierType = CaelumCraftingRules.GetEssenceMaterial(
                    item.EssenceType
                );
                basicUnits =
                    CaelumCraftingRules.GetRequiredEssenceBaseUnits(
                        finalWeight
                    );
                tierUnits = CaelumCraftingRules.GetRequiredEssenceUnits(
                    finalWeight
                );
            }
            else
            {
                int catalogueWeapon =
                    CaelumCraftingRules.GetCatalogueWeaponForPlayableType(
                        item.ItemType
                    );
                if (catalogueWeapon < 0) { return false; }
                basicType = CaelumCraftingRules.GetBasicMaterial(
                    catalogueWeapon
                );
                tierType = CaelumCraftingRules.GetTierMaterial(
                    catalogueWeapon
                );
                basicUnits =
                    CaelumCraftingRules.GetRequiredBasicMaterialUnits(
                        catalogueWeapon, finalWeight
                    );
                tierUnits =
                    CaelumCraftingRules.GetRequiredTierMaterialUnits(
                        catalogueWeapon, finalWeight
                    );
            }
        }
        else if (item.EquipmentKind
            == CaelumConstants.EQUIPMENT_KIND_ARMOR)
        {
            basicType = CaelumConstants.MATERIAL_STRAP;
            tierType = CaelumConstants.MATERIAL_LEATHER;
            basicUnits = CaelumCraftingRules.GetRequiredArmorBaseUnits(
                item.ArmorSlot, finalWeight
            );
            tierUnits = CaelumCraftingRules.GetRequiredArmorTierUnits(
                item.ArmorSlot, finalWeight
            );
        }
        else
        {
            basicType = CaelumConstants.MATERIAL_STRAP;
            tierType = CaelumCraftingRules.GetShieldPlateMaterial(
                item.ItemType
            );
            basicUnits =
                CaelumCraftingRules.GetRequiredShieldStrapUnits(finalWeight);
            tierUnits =
                CaelumCraftingRules.GetRequiredShieldPlateUnits(finalWeight);
        }

        basicTier = CaelumMaterialRules.ResolveTier(basicType, 1);
        tierTier = CaelumMaterialRules.ResolveTier(tierType, item.Tier);
        if (!user.AddScaledEquipmentTaskMaterial(
                basicType, basicTier, basicUnits,
                durabilityFraction, recovery, preview
            )
            || !user.AddScaledEquipmentTaskMaterial(
                tierType, tierTier, tierUnits,
                durabilityFraction, recovery, preview
            )
            || !user.AddScaledEquipmentTaskMaterial(
                CaelumConstants.MATERIAL_SILVER_INGOT, 1,
                CaelumCraftingRules.GetRequiredSilverDetailUnits(
                    finalWeight, item.Tier
                ),
                durabilityFraction, recovery, preview
            )
            || !user.AddScaledEquipmentTaskMaterial(
                CaelumConstants.MATERIAL_GOLD_INGOT, 1,
                CaelumCraftingRules.GetRequiredGoldDetailUnits(
                    finalWeight, item.Tier
                ),
                durabilityFraction, recovery, preview
            ))
        {
            return false;
        }
        return true;
    }

    static int GetMissingEquipmentTaskStation(CaelumPlayer user, CaelumEquipmentItem item)
    {
        if (!CaelumPlayerAuthority.CanRead(user)) return 0;
        if (!user.IsDurabilityTaskEquipment(item))
        {
            return CaelumConstants.CRAFTING_STATION_NONE;
        }
        if (item.EquipmentKind == CaelumConstants.EQUIPMENT_KIND_ARMOR)
        {
            return CaelumCraftingRules.GetMissingArmorStation(
                user.CraftingNetworkCapabilities, item.Tier, item.ItemType
            );
        }
        if (item.EquipmentKind == CaelumConstants.EQUIPMENT_KIND_SHIELD)
        {
            return CaelumCraftingRules.GetMissingShieldStation(
                user.CraftingNetworkCapabilities, item.Tier
            );
        }
        if (user.WeaponModel != null && user.WeaponModel.IsMagicalType(item.ItemType))
        {
            return CaelumCraftingRules.GetMissingEssenceStation(
                user.CraftingNetworkCapabilities, item.Tier
            );
        }
        int catalogueWeapon =
            CaelumCraftingRules.GetCatalogueWeaponForPlayableType(
                item.ItemType
            );
        if (catalogueWeapon < 0)
        {
            return CaelumConstants.CRAFTING_STATION_WORKBENCH;
        }
        return CaelumCraftingRules.GetMissingNetworkStation(
            user.CraftingNetworkCapabilities, item.Tier, catalogueWeapon
        );
    }

    static bool CanCompletePreparedDismantle(CaelumPlayer user, CaelumEquipmentItem target, bool sendOutputsToMagicBox, CaelumCraftingBrowser preview = null)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return false;
        if (preview != null && preview != user.CraftingBrowser) return false;
        if (target == null || user.DerivedStats == null) { return false; }
        user.RefreshCarriedInventorySummary();
        double personalDelta = 0.0;
        double boxRawDelta = 0.0;
        double targetWeight = Max(0.0, target.UnitWeight)
            * Max(0, target.Amount);
        if (target.InMagicBox) { boxRawDelta -= targetWeight; }
        else { personalDelta -= targetWeight; }

        for (int slot = 0;
            slot < CaelumConstants.CRAFTING_TASK_MATERIAL_SLOT_COUNT; slot++)
        {
            if ((preview == null ? user.CraftingTaskOutputUnits[slot] : slot < preview.MaterialUnits.Size() ? preview.MaterialUnits[slot] : 0) <= 0) { continue; }
            CaelumSpecialInventoryItem existing = user.FindNativeSpecialItem(
                CaelumConstants.EQUIPMENT_KIND_MATERIAL,
                (preview == null ? user.CraftingTaskOutputType[slot] : preview.MaterialTypes[slot]),
                (preview == null ? user.CraftingTaskOutputTier[slot] : preview.MaterialTiers[slot])
            );
            double outputWeight = (preview == null ? user.CraftingTaskOutputUnits[slot] : slot < preview.MaterialUnits.Size() ? preview.MaterialUnits[slot] : 0)
                * CaelumConstants.MATERIAL_UNIT_WEIGHT;
            if (sendOutputsToMagicBox)
            {
                if (existing != null && !existing.InMagicBox)
                {
                    double existingWeight = existing.Amount
                        * existing.GetUnitWeight();
                    personalDelta -= existingWeight;
                    boxRawDelta += existingWeight;
                }
                boxRawDelta += outputWeight;
            }
            else if (existing != null && existing.InMagicBox)
            {
                boxRawDelta += outputWeight;
            }
            else
            {
                personalDelta += outputWeight;
            }
        }
        return user.CanApplyInventoryWeightTransition(
            personalDelta, boxRawDelta
        );
    }

    static int GetDismantleNetBoxSlots(CaelumPlayer user, CaelumEquipmentItem target, CaelumCraftingBrowser preview = null)
    {
        if (!CaelumPlayerAuthority.CanRead(user)) return 0;
        if (preview != null && preview != user.CraftingBrowser) return 0;
        if (target == null || user.DerivedStats == null) { return -1; }
        if (user.CanCompletePreparedDismantle(target, false, preview)) { return 0; }
        if (!user.CanCompletePreparedDismantle(target, true, preview)) { return -1; }

        int requiredSlots = 0;
        for (int slot = 0;
            slot < CaelumConstants.CRAFTING_TASK_MATERIAL_SLOT_COUNT; slot++)
        {
            if ((preview == null ? user.CraftingTaskOutputUnits[slot] : slot < preview.MaterialUnits.Size() ? preview.MaterialUnits[slot] : 0) <= 0) { continue; }
            CaelumSpecialInventoryItem existing = user.FindNativeSpecialItem(
                CaelumConstants.EQUIPMENT_KIND_MATERIAL,
                (preview == null ? user.CraftingTaskOutputType[slot] : preview.MaterialTypes[slot]),
                (preview == null ? user.CraftingTaskOutputTier[slot] : preview.MaterialTiers[slot])
            );
            if (existing == null || !existing.InMagicBox) { requiredSlots++; }
        }
        int freedSlots = target.InMagicBox ? 1 : 0;
        return Max(0, requiredSlots - freedSlots);
    }

    static int GetCraftingTaskReservedUnitTotal(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanRead(user)) return 0;
        int total = 0;
        for (int slot = 0;
            slot < CaelumConstants.CRAFTING_TASK_MATERIAL_SLOT_COUNT; slot++)
        {
            total += Max(0, user.CraftingTaskReservedUnits[slot]);
        }
        return total;
    }

    static int GetEquipmentTaskComplexityTics(CaelumPlayer user, CaelumEquipmentItem item)
    {
        if (!CaelumPlayerAuthority.CanRead(user)) return 0;
        if (item == null)
        {
            return CaelumConstants.CRAFTING_SIMPLE_TICS_PER_MATERIAL;
        }
        bool essenceWeapon = item.EquipmentKind
                == CaelumConstants.EQUIPMENT_KIND_WEAPON
            && user.WeaponModel != null
            && user.WeaponModel.IsMagicalType(item.ItemType);
        return CaelumCraftingRules.GetEquipmentComplexityTics(
            item.EquipmentKind, item.ItemType, essenceWeapon
        );
    }

    static double GetEquipmentTaskSeconds(CaelumPlayer user, CaelumEquipmentItem item, int employedMaterialUnits, int efficiencyIndex)
    {
        if (!CaelumPlayerAuthority.CanRead(user)) return 0;
        return user.GetCraftingMaterialWorkSeconds(
            employedMaterialUnits,
            user.GetEquipmentTaskComplexityTics(item),
            efficiencyIndex
        );
    }

    static bool KnowsWeaponRepairRecipe(CaelumPlayer user, CaelumEquipmentItem item)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return false;
        if (item == null || item.EquipmentKind != CaelumConstants.EQUIPMENT_KIND_WEAPON)
            return false;
        int physical = CaelumCraftingRules.GetCatalogueWeaponForPlayableType(item.ItemType);
        if (physical >= 0)
            return user.DirectCraftingRecipeKnown(CaelumCraftingRules.FindUnifiedPhysicalRecipeIndex(physical));
        // La receta del arma completa autoriza la reparación; tener sus
        // componentes no sustituye ese conocimiento. La esencia distingue variantes.
        for (int option = 0; option < CaelumMainM00StarterRules.OPTION_COUNT; option++)
        {
            if (CaelumMainM00StarterRules.GetWeaponType(option) != item.ItemType) continue;
            int recipe = CaelumMainM00StarterRules.GetRecipe(option);
            if (CaelumCraftingRules.GetUnifiedRecipeKind(recipe)
                    == CaelumConstants.CRAFTING_RECIPE_KIND_ESSENCE_WEAPON
                && CaelumCraftingRules.GetUnifiedEssenceType(recipe) != item.EssenceType)
                continue;
            return user.DirectCraftingRecipeKnown(recipe);
        }
        return false;
    }

    static int GetEquipmentTaskBlockReason(CaelumPlayer user, CaelumEquipmentItem target, bool dismantle)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return CaelumConstants.EQUIPMENT_ACTION_FAILED_NOT_OWNED;
        if (target == null || target.Owner != user || !user.IsDurabilityTaskEquipment(target))
            return target != null && target.IsLimboTemporary()
                ? CaelumConstants.EQUIPMENT_ACTION_FAILED_RESERVED : CaelumConstants.EQUIPMENT_ACTION_FAILED_NOT_OWNED;
        if (user.CraftingTaskActive) return CaelumConstants.EQUIPMENT_ACTION_FAILED_CRAFTING_TASK;
        if (user.CombatTimeRemaining > 0) return CaelumConstants.EQUIPMENT_ACTION_FAILED_COMBAT;
        if (!dismantle && target.EquipmentKind == CaelumConstants.EQUIPMENT_KIND_WEAPON && !user.KnowsWeaponRepairRecipe(target))
            return CaelumConstants.EQUIPMENT_ACTION_FAILED_RECIPE_LOCKED;
        if (dismantle && target.IsLimboFirstWeapon()) return CaelumConstants.EQUIPMENT_ACTION_FAILED_RESERVED;
        if (target.Equipped) return CaelumConstants.EQUIPMENT_ACTION_FAILED_EQUIPPED;
        if (!dismantle && (user.GetEquipmentTaskMaximumDurability(target) <= 0 || target.Durability >= user.GetEquipmentTaskMaximumDurability(target)))
            return CaelumConstants.EQUIPMENT_ACTION_FAILED_DURABILITY;
        if (!user.CraftingMenuOpen || user.ActiveCraftingStationType != CaelumConstants.CRAFTING_STATION_WORKBENCH
            || user.GetMissingEquipmentTaskStation(target) != CaelumConstants.CRAFTING_STATION_NONE)
            return CaelumConstants.EQUIPMENT_ACTION_FAILED_INFRASTRUCTURE;
        return CaelumConstants.EQUIPMENT_ACTION_NONE;
    }

    static void BeginRepairSelectedEquipment(CaelumPlayer user, int targetItemId = 0)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return;
        user.LastCraftingAction = CaelumConstants.CRAFTING_ACTION_NONE;
        if (!user.CanStartCraftingTask(false))
        {
            user.LastEquipmentAction = user.CombatTimeRemaining > 0
                ? CaelumConstants.EQUIPMENT_ACTION_FAILED_COMBAT
                : !user.CraftingMenuOpen ? CaelumConstants.EQUIPMENT_ACTION_FAILED_INFRASTRUCTURE
                : CaelumConstants.EQUIPMENT_ACTION_FAILED_CRAFTING_TASK;
            return;
        }
        let target = targetItemId > 0 ? user.FindNativeEquipmentItemById(targetItemId) : user.GetSelectedNativeEquipmentItem();
        user.LastEquipmentAction = user.GetEquipmentTaskBlockReason(target, false);
        if (user.LastEquipmentAction != CaelumConstants.EQUIPMENT_ACTION_NONE) return;
        int maximum = user.GetEquipmentTaskMaximumDurability(target);

        double missingFraction = Clamp(
            (maximum - target.Durability) / double(maximum),
            0.0, 1.0
        );
        user.ClearDirectCraftingPlan();
        user.CraftingMissingStationType = CaelumConstants.CRAFTING_STATION_NONE;
        bool repairPlanReady = user.BuildEquipmentTaskMaterials(
            target, missingFraction, false
        );
        user.CraftingDirectPlanAvailable = repairPlanReady;
        if (!repairPlanReady)
        {
            user.LastEquipmentAction = user.CraftingMissingStationType
                    != CaelumConstants.CRAFTING_STATION_NONE
                ? CaelumConstants.EQUIPMENT_ACTION_FAILED_INFRASTRUCTURE
                : CaelumConstants.EQUIPMENT_ACTION_FAILED_MATERIALS;
            user.ClearDirectCraftingPlan();
            return;
        }
        double repairSeconds = user.GetEquipmentTaskSeconds(
            target,
            user.CraftingPreparedEquipmentInputUnits,
            user.CraftingEfficiencyIndex
        );
        for (int step = 0;
            step < user.CraftingDirectPlanStepCount; step++)
        {
            repairSeconds += user.CraftingPlanStepSeconds[step];
        }
        user.ClearCraftingTaskData();
        if (!user.ReservePreparedDirectCraftingPlan())
        {
            user.ClearCraftingTaskData();
            user.LastEquipmentAction =
                CaelumConstants.EQUIPMENT_ACTION_FAILED_MATERIALS;
            return;
        }
        user.CraftingTaskUsesDirectPlan = true;
        user.CraftingTaskTargetItemId = target.ItemId;
        user.LastEquipmentAction =
            CaelumConstants.EQUIPMENT_ACTION_REPAIR_STARTED;
        user.StartPreparedCraftingTask(
            CaelumConstants.CRAFTING_TASK_REPAIR,
            repairSeconds
        );
    }

    static void BeginDismantleSelectedEquipment(CaelumPlayer user, int targetItemId = 0)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return;
        user.LastCraftingAction = CaelumConstants.CRAFTING_ACTION_NONE;
        if (!user.CanStartCraftingTask(false))
        {
            user.LastEquipmentAction = user.CombatTimeRemaining > 0
                ? CaelumConstants.EQUIPMENT_ACTION_FAILED_COMBAT
                : !user.CraftingMenuOpen ? CaelumConstants.EQUIPMENT_ACTION_FAILED_INFRASTRUCTURE
                : CaelumConstants.EQUIPMENT_ACTION_FAILED_CRAFTING_TASK;
            return;
        }
        let target = targetItemId > 0 ? user.FindNativeEquipmentItemById(targetItemId) : user.GetSelectedNativeEquipmentItem();
        user.LastEquipmentAction = user.GetEquipmentTaskBlockReason(target, true);
        if (user.LastEquipmentAction != CaelumConstants.EQUIPMENT_ACTION_NONE) return;

        int maximum = Max(1, user.GetEquipmentTaskMaximumDurability(target));
        double remainingFraction = Clamp(
            target.Durability / double(maximum), 0.0, 1.0
        );
        user.ClearCraftingTaskData();
        if (!user.BuildEquipmentTaskMaterials(target, remainingFraction, true))
        {
            user.ClearCraftingTaskData();
            user.LastEquipmentAction =
                CaelumConstants.EQUIPMENT_ACTION_FAILED_DISMANTLE_UNSUPPORTED;
            return;
        }
        user.CraftingTaskTargetItemId = target.ItemId;
        user.CraftingTaskReservedBoxSlots = user.GetDismantleNetBoxSlots(target);
        if (user.CraftingTaskReservedBoxSlots < 0)
        {
            user.ClearCraftingTaskData();
            user.LastEquipmentAction =
                CaelumConstants.EQUIPMENT_ACTION_FAILED_CARRY_CAPACITY;
            return;
        }
        user.RefreshCarriedInventorySummary();
        if (user.MagicBoxUsedSlots + user.CraftingTaskReservedBoxSlots
            > user.MagicBoxMaximumSlots)
        {
            user.ClearCraftingTaskData();
            user.LastEquipmentAction =
                CaelumConstants.EQUIPMENT_ACTION_FAILED_STORAGE;
            return;
        }
        user.LastEquipmentAction =
            CaelumConstants.EQUIPMENT_ACTION_DISMANTLE_STARTED;
        user.StartPreparedCraftingTask(
            CaelumConstants.CRAFTING_TASK_DISMANTLE,
            user.GetEquipmentTaskSeconds(
                target,
                CaelumCraftingRules.GetRoundedMaterialUnits(
                    user.GetEquipmentTaskWeight(target), 1.0
                ),
                0
            )
        );
    }

    static bool ConsumeCraftingTaskReservations(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return false;
        if (!user.ValidateCraftingTaskReservations()) { return false; }
        for (int slot = 0;
            slot < CaelumConstants.CRAFTING_TASK_MATERIAL_SLOT_COUNT; slot++)
        {
            if (user.CraftingTaskReservedUnits[slot] <= 0) { continue; }
            if (!user.ConsumeCraftingMaterial(
                user.CraftingTaskReservedType[slot],
                user.CraftingTaskReservedTier[slot],
                user.CraftingTaskReservedUnits[slot]
            ))
            {
                return false;
            }
        }
        return true;
    }

    static bool CompleteRepairTask(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return false;
        CaelumEquipmentItem target = user.FindNativeEquipmentItemById(
            user.CraftingTaskTargetItemId
        );
        if (!user.IsDurabilityTaskEquipment(target) || target.Equipped)
        {
            user.LastEquipmentAction =
                CaelumConstants.EQUIPMENT_ACTION_FAILED_CRAFTING_TASK;
            return false;
        }
        if (!user.ConsumeCraftingTaskReservations())
        {
            user.LastEquipmentAction =
                CaelumConstants.EQUIPMENT_ACTION_FAILED_CRAFTING_TASK;
            return false;
        }
        int previousDurability = target.Durability;
        target.Durability = user.GetEquipmentTaskMaximumDurability(target);
        CaelumMainM00RonnieTrial.RecordRepairLesson(user, target, previousDurability);
        user.LastEquipmentAction = CaelumConstants.EQUIPMENT_ACTION_REPAIRED;
        user.LastCraftingAction = CaelumConstants.CRAFTING_ACTION_REPAIRED;
        user.ApplyCharacterProfile();
        return true;
    }

    static bool CompleteDismantleTask(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return false;
        CaelumEquipmentItem target = user.FindNativeEquipmentItemById(
            user.CraftingTaskTargetItemId
        );
        if (!user.IsDurabilityTaskEquipment(target) || target.Equipped)
        {
            user.LastEquipmentAction =
                CaelumConstants.EQUIPMENT_ACTION_FAILED_CRAFTING_TASK;
            return false;
        }
        int netSlots = user.GetDismantleNetBoxSlots(target);
        if (netSlots < 0)
        {
            user.LastEquipmentAction =
                CaelumConstants.EQUIPMENT_ACTION_FAILED_CARRY_CAPACITY;
            return false;
        }
        user.RefreshCarriedInventorySummary();
        if (user.MagicBoxUsedSlots + netSlots > user.MagicBoxMaximumSlots)
        {
            user.LastEquipmentAction =
                CaelumConstants.EQUIPMENT_ACTION_FAILED_STORAGE;
            return false;
        }

        bool sendToMagicBox =
            !user.CanCompletePreparedDismantle(target, false);

        CaelumPersistentCharacterState persistentState =
            user.GetPersistentCharacterState(false);
        if (persistentState != null)
        {
            if (target.EquipmentKind
                == CaelumConstants.EQUIPMENT_KIND_WEAPON)
            {
                persistentState.RemoveOwnedWeapon(
                    target.ItemType, target.Tier, target.EquipmentSize
                );
            }
            else if (target.EquipmentKind
                == CaelumConstants.EQUIPMENT_KIND_SHIELD)
            {
                persistentState.RemoveOwnedShield(
                    target.ItemType, target.Tier, target.EquipmentSize
                );
            }
            else
            {
                persistentState.RemoveOwnedArmor(
                    target.ArmorSlot, target.ItemType,
                    target.Tier, target.EquipmentSize
                );
            }
        }
        target.Destroy();

        for (int slot = 0;
            slot < CaelumConstants.CRAFTING_TASK_MATERIAL_SLOT_COUNT; slot++)
        {
            if (user.CraftingTaskOutputUnits[slot] <= 0) { continue; }
            CaelumSpecialInventoryItem existing = user.FindNativeSpecialItem(
                CaelumConstants.EQUIPMENT_KIND_MATERIAL,
                user.CraftingTaskOutputType[slot],
                user.CraftingTaskOutputTier[slot]
            );
            CaelumMaterialPickup detached;
            if (existing == null)
            {
                detached = user.CreateDetachedMaterialStack(
                    user.CraftingTaskOutputType[slot],
                    user.CraftingTaskOutputTier[slot],
                    user.CraftingTaskOutputUnits[slot]
                );
            }
            user.AddRecoveredMaterial(
                existing,
                detached,
                user.CraftingTaskOutputUnits[slot],
                sendToMagicBox
            );
        }
        user.EquipmentSelectionItemId = 0;
        user.LastEquipmentAction =
            CaelumConstants.EQUIPMENT_ACTION_DISMANTLED;
        user.LastCraftingAction = CaelumConstants.CRAFTING_ACTION_DISMANTLED;
        user.ApplyCharacterProfile();
        return true;
    }

    static void CompleteCraftingTask(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return;
        if (!user.CraftingTaskActive) { return; }
        int completedKind = user.CraftingTaskKind;
        int oldStation = user.ActiveCraftingStationType;
        int oldCapabilities = user.CraftingNetworkCapabilities;
        bool menuWasOpen = user.CraftingMenuOpen;

        if (completedKind == CaelumConstants.CRAFTING_TASK_REPAIR)
        {
            user.CraftingTaskCompleting = true;
            user.CompleteRepairTask();
            user.CraftingTaskCompleting = false;
        }
        else if (completedKind
            == CaelumConstants.CRAFTING_TASK_DISMANTLE)
        {
            user.CraftingTaskCompleting = true;
            user.CompleteDismantleTask();
            user.CraftingTaskCompleting = false;
        }
        else
        {
            user.CraftingSelectionRecipe = user.CraftingTaskRecipeIndex;
            user.CraftingSelectionTier = user.CraftingTaskTier;
            user.CraftingSelectionSize = user.CraftingTaskSize;
            user.CraftingProcessingBatchIndex = user.CraftingTaskBatchIndex;
            user.CraftingEfficiencyIndex = user.CraftingTaskEfficiencyIndex;
            user.CraftingNetworkCapabilities = user.CraftingTaskNetworkCapabilities;
            user.ActiveCraftingStationType =
                CaelumConstants.CRAFTING_STATION_WORKBENCH;
            user.CraftingTaskCompleting = true;
            user.CraftSelectedPhysicalWeapon();
            user.CraftingTaskCompleting = false;
        }

        user.ClearCraftingTaskData();
        user.CraftingMenuOpen = menuWasOpen;
        user.ActiveCraftingStationType = oldStation;
        user.CraftingNetworkCapabilities = oldCapabilities;
        user.PersistCharacterState();
        user.RefreshEquipmentSelectionPreview();
        user.RefreshFormalInventorySnapshot();
        if (user.CraftingMenuOpen) { user.RefreshCraftingPreview(); }
    }

    static void BreakSelectedNativeEquipment(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return;
        user.LastEquipmentAction = CaelumConstants.EQUIPMENT_ACTION_FAILED_NOT_OWNED;
        if (user.EquipmentSelectionKind
                == CaelumConstants.EQUIPMENT_KIND_CONSUMABLE
            || user.EquipmentSelectionKind
                == CaelumConstants.EQUIPMENT_KIND_AMMUNITION
            || user.EquipmentSelectionKind
                >= CaelumConstants.EQUIPMENT_KIND_MATERIAL) { return; }
        CaelumEquipmentItem item = user.GetSelectedNativeEquipmentItem();
        if (item == null) { return; }
        if (item.EquipmentKind == CaelumConstants.EQUIPMENT_KIND_WEAPON)
        {
            user.DismantleSelectedNativeWeapon();
            return;
        }
        item.Durability = 0;
        if (item.Equipped)
        {
            if (item.EquipmentKind == CaelumConstants.EQUIPMENT_KIND_ARMOR)
            {
                user.ArmorModel.Durability[item.ArmorSlot] = 0;
            }
            else if (item.EquipmentKind == CaelumConstants.EQUIPMENT_KIND_SHIELD)
            {
                user.ShieldModel.Durability = 0;
                user.DebugShieldBlocking = false;
            }
            else if (user.WeaponModel.Equipped
                && user.WeaponModel.WeaponType == item.ItemType
                && user.WeaponModel.Tier == item.Tier
                && user.WeaponModel.Size == item.EquipmentSize)
            {
                user.WeaponModel.Durability = 0;
                user.EquippedWeaponCooldownRemaining = 0.0;
            }
        }
        user.ApplyCharacterProfile();
        user.PersistCharacterState();
        user.RefreshEquipmentSelectionPreview();
        user.LastEquipmentAction = CaelumConstants.EQUIPMENT_ACTION_BROKEN;
    }

    static CaelumMaterialPickup CreateDetachedMaterialStack(CaelumPlayer user, int materialType, int materialTier, int materialAmount)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return null;
        CaelumMaterialPickup material = CaelumMaterialPickup(
            Actor.Spawn("CaelumMaterialPickup", user.Pos, NO_REPLACE)
        );
        if (material == null) { return null; }
        material.args[0] = materialType;
        material.args[1] = materialTier;
        material.Amount = Max(1, materialAmount);
        material.InMagicBox = false;
        return material;
    }

    static void AddRecoveredMaterial(CaelumPlayer user, CaelumSpecialInventoryItem existing, CaelumMaterialPickup detached, int recoveredAmount, bool sendToMagicBox)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return;
        if ((existing != null && existing.Owner != user) || (detached != null && detached.Owner != null && detached.Owner != user)) return;
        if (existing != null)
        {
            existing.Amount += recoveredAmount;
            if (sendToMagicBox) { existing.InMagicBox = true; }
            if (detached != null) { detached.Destroy(); }
            CaelumNotifications.Acquired(user, existing, recoveredAmount);
            return;
        }
        if (detached == null) { return; }
        detached.InMagicBox = sendToMagicBox;
        detached.AttachToOwner(user);
        CaelumNotifications.Acquired(user, detached, detached.Amount);
    }

    static void DismantleSelectedNativeWeapon(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return;
        user.LastEquipmentAction = CaelumConstants.EQUIPMENT_ACTION_FAILED_NOT_OWNED;
        user.LastDismantledBasicUnits = 0;
        user.LastDismantledTierUnits = 0;
        CaelumEquipmentItem weapon = user.GetSelectedNativeEquipmentItem();
        if (weapon == null || weapon.IsLimboTemporary() || weapon.IsLimboFirstWeapon()
            || weapon.EquipmentKind != CaelumConstants.EQUIPMENT_KIND_WEAPON)
        {
            return;
        }
        if (weapon.Equipped)
        {
            user.LastEquipmentAction =
                CaelumConstants.EQUIPMENT_ACTION_FAILED_EQUIPPED;
            return;
        }

        int catalogueWeapon =
            CaelumCraftingRules.GetCatalogueWeaponForPlayableType(
                weapon.ItemType
            );
        if (catalogueWeapon < 0)
        {
            user.LastEquipmentAction =
                CaelumConstants.EQUIPMENT_ACTION_FAILED_DISMANTLE_UNSUPPORTED;
            return;
        }
        double finalWeight = user.WeaponModel.GetWeightFor(
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
        CaelumSpecialInventoryItem existingBasic = user.FindNativeSpecialItem(
            CaelumConstants.EQUIPMENT_KIND_MATERIAL,
            basicType,
            basicTier
        );
        CaelumSpecialInventoryItem existingTier = user.FindNativeSpecialItem(
            CaelumConstants.EQUIPMENT_KIND_MATERIAL,
            tierType,
            tierTier
        );

        user.RefreshCarriedInventorySummary();
        double weaponWeight = Max(0.0, weapon.UnitWeight)
            * Max(0, weapon.Amount);
        double basicWeight = basicAmount
            * CaelumConstants.MATERIAL_UNIT_WEIGHT;
        double tierWeight = tierAmount
            * CaelumConstants.MATERIAL_UNIT_WEIGHT;
        double personalDelta = weapon.InMagicBox ? 0.0 : -weaponWeight;
        double boxRawDelta = weapon.InMagicBox ? -weaponWeight : 0.0;
        if (existingBasic != null && existingBasic.InMagicBox)
        {
            boxRawDelta += basicWeight;
        }
        else { personalDelta += basicWeight; }
        if (existingTier != null && existingTier.InMagicBox)
        {
            boxRawDelta += tierWeight;
        }
        else { personalDelta += tierWeight; }
        bool sendToMagicBox = !user.CanApplyInventoryWeightTransition(
            personalDelta, boxRawDelta
        );

        if (sendToMagicBox)
        {
            personalDelta = weapon.InMagicBox ? 0.0 : -weaponWeight;
            boxRawDelta = weapon.InMagicBox ? -weaponWeight : 0.0;
            if (existingBasic != null && !existingBasic.InMagicBox)
            {
                double existingBasicWeight = existingBasic.Amount
                    * existingBasic.GetUnitWeight();
                personalDelta -= existingBasicWeight;
                boxRawDelta += existingBasicWeight;
            }
            if (existingTier != null && !existingTier.InMagicBox)
            {
                double existingTierWeight = existingTier.Amount
                    * existingTier.GetUnitWeight();
                personalDelta -= existingTierWeight;
                boxRawDelta += existingTierWeight;
            }
            boxRawDelta += basicWeight + tierWeight;
            if (!user.CanApplyInventoryWeightTransition(
                    personalDelta, boxRawDelta
                ))
            {
                user.LastEquipmentAction =
                    CaelumConstants.EQUIPMENT_ACTION_FAILED_CARRY_CAPACITY;
                return;
            }
        }

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
        if (user.MagicBoxUsedSlots - freedBoxSlots + requiredBoxSlots
            > user.MagicBoxMaximumSlots)
        {
            user.LastEquipmentAction =
                CaelumConstants.EQUIPMENT_ACTION_FAILED_STORAGE;
            return;
        }

        CaelumMaterialPickup detachedBasic;
        CaelumMaterialPickup detachedTier;
        if (existingBasic == null)
        {
            detachedBasic = user.CreateDetachedMaterialStack(
                basicType, basicTier, basicAmount
            );
            if (detachedBasic == null)
            {
                user.LastEquipmentAction =
                    CaelumConstants.EQUIPMENT_ACTION_FAILED_STORAGE;
                return;
            }
        }
        if (existingTier == null)
        {
            detachedTier = user.CreateDetachedMaterialStack(
                tierType, tierTier, tierAmount
            );
            if (detachedTier == null)
            {
                if (detachedBasic != null) { detachedBasic.Destroy(); }
                user.LastEquipmentAction =
                    CaelumConstants.EQUIPMENT_ACTION_FAILED_STORAGE;
                return;
            }
        }

        CaelumPersistentCharacterState persistentState =
            user.GetPersistentCharacterState(false);
        if (persistentState != null)
        {
            persistentState.RemoveOwnedWeapon(
                weapon.ItemType, weapon.Tier, weapon.EquipmentSize
            );
        }
        weapon.Destroy();
        user.AddRecoveredMaterial(
            existingBasic, detachedBasic, basicAmount, sendToMagicBox
        );
        user.AddRecoveredMaterial(
            existingTier, detachedTier, tierAmount, sendToMagicBox
        );

        user.LastDismantledBasicMaterialType = basicType;
        user.LastDismantledBasicUnits = basicAmount;
        user.LastDismantledTierMaterialType = tierType;
        user.LastDismantledTierUnits = tierAmount;
        user.LastEquipmentAction = CaelumConstants.EQUIPMENT_ACTION_DISMANTLED;
        user.ApplyCharacterProfile();
        user.PersistCharacterState();
        user.RefreshEquipmentSelectionPreview();
    }

    static void DropSelectedNativeInventoryItem(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return;
        if (user.EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_KEY_ITEM
            && user.EquipmentSelectionSpecialType == CaelumConstants.KEY_ITEM_TAROT_DECK)
        {
            user.LastEquipmentAction = CaelumConstants.EQUIPMENT_ACTION_FAILED_PROTECTED;
            return;
        }
        let training = user.GetPersistentCharacterState(false);
        if (user.EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_AMMUNITION
            && training != null && training.MainM00AmmoLoanRemaining > 0
            && user.EquipmentSelectionAmmunitionType == training.MainM00AmmoLoanType)
        {
            user.LastEquipmentAction = CaelumConstants.EQUIPMENT_ACTION_FAILED_RESERVED;
            CaelumMainM00MagicTrial.Feedback(user, "CA_M01_RULO_AMMO_RESERVED", true);
            return;
        }
        if (user.EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_MATERIAL)
        {
            let material = user.FindNativeSpecialItem(user.EquipmentSelectionKind, user.EquipmentSelectionSpecialType, user.EquipmentSelectionTier);
            if (material != null && material.LimboQuestUnits > 0)
            { user.LastEquipmentAction = CaelumConstants.EQUIPMENT_ACTION_FAILED_RESERVED;
              CaelumMainM00RonnieTrial.Feedback(user, "CA_M01_SUPPLY_RESERVED"); return; }
        }

        let loan = user.GetSelectedNativeEquipmentItem();
        if (loan != null && loan.IsLimboTemporary())
        {
            user.LastEquipmentAction = CaelumConstants.EQUIPMENT_ACTION_FAILED_RESERVED;
            CaelumMainM00MagicTrial.Feedback(user, "CA_M01_LOAN_RESERVED", true);
            return;
        }
        user.LastEquipmentAction = CaelumConstants.EQUIPMENT_ACTION_FAILED_NOT_OWNED;
        if (user.IsSelectedMaterialCraftingLocked()
            || user.IsEquipmentItemCraftingLocked(user.EquipmentSelectionItemId))
        {
            user.LastEquipmentAction =
                CaelumConstants.EQUIPMENT_ACTION_FAILED_RESERVED;
            return;
        }
        Inventory selected;
        if (user.EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_KEY)
        {
            CaelumWeightedKey keyItem = user.FindNativeKey(
                user.EquipmentSelectionSpecialType
            );
            if (keyItem == null || keyItem.Amount <= 0) { return; }
            selected = keyItem.CreateTossable(1);
        }
        else if (user.EquipmentSelectionKind
                == CaelumConstants.EQUIPMENT_KIND_MATERIAL
            || user.EquipmentSelectionKind
                == CaelumConstants.EQUIPMENT_KIND_KEY_ITEM
            || user.EquipmentSelectionKind
                == CaelumConstants.EQUIPMENT_KIND_CURRENCY)
        {
            CaelumSpecialInventoryItem specialItem = user.FindNativeSpecialItem(
                user.EquipmentSelectionKind, user.EquipmentSelectionSpecialType,
                user.EquipmentSelectionTier
            );
            if (specialItem == null || specialItem.Amount <= 0) { return; }
            specialItem.InMagicBox = false;
            selected = specialItem.CreateTossable(specialItem.Amount);
        }
        else if (user.EquipmentSelectionKind
            == CaelumConstants.EQUIPMENT_KIND_CONSUMABLE)
        {
            CaelumConsumableItem consumable = user.FindNativeConsumableItem(
                user.EquipmentSelectionConsumableType
            );
            if (consumable == null || consumable.Amount <= 0) { return; }
            consumable.InMagicBox = false;
            selected = consumable.CreateTossable(consumable.Amount);
        }
        else if (user.EquipmentSelectionKind
            == CaelumConstants.EQUIPMENT_KIND_AMMUNITION)
        {
            Inventory ammunition = user.FindNativeAmmunition(
                user.EquipmentSelectionAmmunitionType
            );
            if (ammunition == null || ammunition.Amount <= 0) { return; }
            CaelumCarbineAmmo carbineStack = CaelumCarbineAmmo(ammunition);
            if (carbineStack != null) { carbineStack.InMagicBox = false; }
            selected = ammunition.CreateTossable(ammunition.Amount);
        }
        else
        {
            CaelumEquipmentItem item = user.GetSelectedNativeEquipmentItem();
            if (item == null) { return; }
            if (item.Equipped)
            {
                user.UnequipSelectedNativeEquipment();
                item = user.GetSelectedNativeEquipmentItem();
                if (item == null) { return; }
            }
            item.InMagicBox = false;
            selected = item.CreateTossable(1);
        }
        if (selected == null) { return; }
        Vector3 spawnPos = user.Pos + (
            Cos(user.Angle) * 48.0,
            Sin(user.Angle) * 48.0,
            8.0
        );
        selected.SetOrigin(spawnPos, false);
        selected.TossItem();

        // Jewelry was visibly launched upward by Inventory.TossItem().
        // Preserve the horizontal toss, but make seals/amulets begin falling
        // immediately from the small +8 MU spawn offset.
        if (user.EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_AMULET
            || user.EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_SEAL)
        {
            selected.Vel.Z = -0.25;
        }

        user.ApplyCharacterProfile();
        user.PersistCharacterState();
        user.RefreshEquipmentSelectionPreview();
        user.LastEquipmentAction = CaelumConstants.EQUIPMENT_ACTION_DROPPED;
    }

    static void BreakSelectedEquipment(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return;
        user.BeginDismantleSelectedEquipment();
        return;
        user.LastEquipmentAction = CaelumConstants.EQUIPMENT_ACTION_FAILED_NOT_OWNED;
        CaelumPersistentCharacterState persistentState =
            user.GetPersistentCharacterState(false);
        if (persistentState == null || !user.EquipmentSelectionOwned) { return; }
        persistentState.EnsureEquipmentSizeInitialized();
        persistentState.MigrateWeaponDurability();
        if (user.EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_WEAPON)
        {
            persistentState.StoreOwnedWeaponDurability(
                user.EquipmentSelectionWeaponType,
                user.EquipmentSelectionTier,
                user.EquipmentSelectionSize,
                0
            );
            if (user.EquipmentSelectionEquipped && user.WeaponModel != null
                && user.WeaponModel.Equipped
                && user.WeaponModel.WeaponType == user.EquipmentSelectionWeaponType
                && user.WeaponModel.Tier == user.EquipmentSelectionTier
                && user.WeaponModel.Size == user.EquipmentSelectionSize)
            {
                user.WeaponModel.Durability = 0;
                user.EquippedWeaponCooldownRemaining = 0.0;
            }
        }
        else if (user.EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_SHIELD)
        {
            persistentState.StoreOwnedShieldDurability(
                user.EquipmentSelectionShieldType,
                user.EquipmentSelectionTier,
                user.EquipmentSelectionSize,
                0
            );
            if (user.EquipmentSelectionEquipped && user.ShieldModel != null)
            {
                user.ShieldModel.Durability = 0;
                user.DebugShieldBlocking = false;
            }
        }
        else
        {
            persistentState.StoreOwnedArmorDurability(
                user.EquipmentSelectionSlot,
                user.EquipmentSelectionArmorType,
                user.EquipmentSelectionTier,
                user.EquipmentSelectionSize,
                0
            );
            if (user.EquipmentSelectionEquipped && user.ArmorModel != null)
            {
                user.ArmorModel.Durability[user.EquipmentSelectionSlot] = 0;
            }
        }
        user.ApplyCharacterProfile();
        user.PersistCharacterState();
        user.RefreshEquipmentSelectionPreview();
        user.LastEquipmentAction = CaelumConstants.EQUIPMENT_ACTION_BROKEN;
    }

    static void DropSelectedEquipment(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return;
        user.RefreshCarriedInventorySummary();
        double previousWeight = user.DerivedStats == null ? 0 : user.DerivedStats.CarriedItemWeight;
        int selectedId = user.EquipmentSelectionItemId;
        user.DropSelectedNativeInventoryItem();
        CaelumMainM00RonnieTrial.RecordLoadLesson(user, previousWeight, selectedId);
        return;
        user.LastEquipmentAction = CaelumConstants.EQUIPMENT_ACTION_FAILED_NOT_OWNED;
        if (!user.EquipmentSelectionOwned) { return; }
        CaelumPersistentCharacterState persistentState =
            user.GetPersistentCharacterState(false);
        if (persistentState == null) { return; }
        // Tirar un objeto equipado primero lo retira de su ranura. Esto evita
        // que el control parezca inactivo y actualiza su peso en el mismo tic.
        if (user.EquipmentSelectionEquipped)
        {
            user.UnequipSelectedEquipment();
            user.RefreshEquipmentSelectionPreview();
            if (user.EquipmentSelectionEquipped || !user.EquipmentSelectionOwned) { return; }
        }
        Vector3 spawnPos = user.Pos + (Cos(user.Angle) * 48.0, Sin(user.Angle) * 48.0, 8.0);
        Actor pickup;
        if (user.EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_WEAPON)
        {
            pickup = Actor.Spawn("CaelumWeaponPickup", spawnPos, NO_REPLACE);
            if (pickup == null) { return; }
            pickup.args[0] = user.EquipmentSelectionWeaponType;
            pickup.args[1] = user.EquipmentSelectionTier;
            pickup.args[2] = user.EquipmentSelectionSize + 1;
            pickup.args[3] = user.EquipmentSelectionDurability + 1;
            persistentState.RemoveOwnedWeapon(
                user.EquipmentSelectionWeaponType,
                user.EquipmentSelectionTier,
                user.EquipmentSelectionSize
            );
        }
        else if (user.EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_SHIELD)
        {
            pickup = Actor.Spawn("CaelumShieldPickup", spawnPos, NO_REPLACE);
            if (pickup == null) { return; }
            pickup.args[0] = user.EquipmentSelectionShieldType;
            pickup.args[1] = user.EquipmentSelectionTier;
            pickup.args[2] = user.EquipmentSelectionSize + 1;
            pickup.args[3] = user.EquipmentSelectionDurability + 1;
            persistentState.RemoveOwnedShield(
                user.EquipmentSelectionShieldType,
                user.EquipmentSelectionTier,
                user.EquipmentSelectionSize
            );
        }
        else
        {
            pickup = Actor.Spawn("CaelumArmorPickup", spawnPos, NO_REPLACE);
            if (pickup == null) { return; }
            pickup.args[0] = user.EquipmentSelectionSlot;
            pickup.args[1] = user.EquipmentSelectionArmorType;
            pickup.args[2] = user.EquipmentSelectionTier;
            pickup.args[3] = user.EquipmentSelectionSize + 1;
            pickup.args[4] = user.EquipmentSelectionDurability + 1;
            persistentState.RemoveOwnedArmor(
                user.EquipmentSelectionSlot,
                user.EquipmentSelectionArmorType,
                user.EquipmentSelectionTier,
                user.EquipmentSelectionSize
            );
        }
        user.OwnedArmorCount = persistentState.CountOwnedArmor();
        user.OwnedShieldCount = persistentState.CountOwnedShields();
        user.OwnedWeaponCount = persistentState.CountOwnedWeapons();
        user.ApplyCharacterProfile();
        user.PersistCharacterState();
        user.RefreshEquipmentSelectionPreview();
        user.LastEquipmentAction = CaelumConstants.EQUIPMENT_ACTION_DROPPED;
    }

    static void MigrateWeaponDurability(CaelumPlayer user, int revision = 1)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return;
        if (user.WeaponModel != null) user.WeaponModel.MigrateDurability(revision);
        let persistent = user.GetPersistentCharacterState(false);
        if (persistent != null) persistent.MigrateWeaponDurability(revision);
        for (Inventory cursor=user.Inv; cursor!=null; cursor=cursor.Inv)
        {
            let item=CaelumEquipmentItem(cursor);
            if (item!=null) item.MigrateWeaponDurability(revision);
        }
    }

    static CaelumMagicBox EnsureOwnedMagicBox(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return null;
        if (user == null) return null;
        let record = user.GetPersistentCharacterState(true);
        if (record == null || !record.MagicBoxOwned) return null;
        let box = CaelumMagicBox(user.FindInventory("CaelumMagicBox"));
        if (box != null && record.MagicBoxItemId > 0 && box.ItemId == record.MagicBoxItemId)
            return box;
        if (box == null)
        {
            box = CaelumMagicBox(Actor.Spawn("CaelumMagicBox", user.Pos, NO_REPLACE));
            if (box == null) return null;
            box.AttachToOwner(user);
        }
        // Migrar una Caja anterior sin tocar el contenido ni sus ItemId.
        user.EnsureAllEquipmentItemIds();
        if (record.MagicBoxItemId <= 0)
            record.MagicBoxItemId = record.AllocateEquipmentItemId();
        record.ObserveEquipmentItemId(record.MagicBoxItemId);
        box.ItemId = record.MagicBoxItemId;
        box.Amount = 1;
        return box;
    }

    static CaelumTarotDeck FindOwnedTarotDeck(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanRead(user)) return null;
        if (user == null) return null;
        let deck = CaelumTarotDeck(user.FindInventory("CaelumTarotDeck"));
        return deck != null && deck.Owner == user && deck.Amount > 0 ? deck : null;
    }

    static bool GrantTarotDeck(CaelumPlayer user, bool explain = true)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return false;
        let record = user.GetPersistentCharacterState(false);
        if (record == null) return false;
        // Una ausencia no autoriza otra entrega de Palomo.
        if (record.TarotDeckGranted) return true;
        let deck = FindOwnedTarotDeck(user);
        if (deck == null)
        {
            bool inBox = CaelumMainM00FoolCapture.HasOwnedBox(user)
                && user.HasNativeMagicBoxSlotAvailable()
                && user.CanAddRawWeightToMagicBox(CaelumConstants.TAROT_DECK_WEIGHT);
            if (!inBox && !user.CanAddWeightToPersonalInventory(CaelumConstants.TAROT_DECK_WEIGHT))
            {
                if (explain) CaelumTarotPowers.Feedback(user, "CA_TAROT_DECK_MAKE_ROOM");
                return false;
            }
            deck = CaelumTarotDeck(Actor.Spawn("CaelumTarotDeck", user.Pos, NO_REPLACE));
            if (deck == null) return false;
            deck.InMagicBox = inBox;
            deck.AttachToOwner(user);
        }
        record.TarotDeckGranted = true;
        record.TarotDeckRevision = CaelumTarotDeckRules.REVISION;
        user.OnNativeInventoryChanged();
        if (explain) CaelumTarotPowers.Feedback(user, "CA_TAROT_DECK_RECEIVED");
        return true;
    }

}
