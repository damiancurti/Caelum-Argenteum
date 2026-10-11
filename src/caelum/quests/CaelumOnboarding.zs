// Estado de la nueva partida y transacciones del tutorial #183.
class CaelumOnboarding : Object play
{
    static void Initialize(CaelumPlayer user)
    {
        if (user == null || !user.CharacterCreationComplete || user.CharacterProfile == null) return;
        let r = user.GetPersistentCharacterState(true);
        if (r.MainM00StarterChosen) return;
        int profession = user.CharacterProfile.GetProfession();
        r.MainM00StarterChosen = true;
        r.MainM00StarterOption = CaelumOnboardingCatalogue.StarterOption(profession);
        r.MainM00StarterSize = CaelumEquipmentRules.GetDefaultSizeForCharacterTier(user.CharacterProfile.GetSizeTier());
        r.MainM00ArmorChosen = true; r.MainM00ArmorType = CaelumOnboardingCatalogue.Armor(profession);
        r.MainM00ArmorSize = r.MainM00StarterSize;
        r.MainM00ShieldChoice = CaelumOnboardingCatalogue.Shield(profession) + 1;
        r.MainM00AmuletChoice = CaelumOnboardingCatalogue.Necklace(user.CharacterProfile.FirstClass) + 1;
    }

    static void RecordRepairBudget(CaelumPlayer user, CaelumEquipmentItem item, int count)
    {
        // Consulta exactamente la misma función que una reparación completa.
        // Los componentes se entregan ya preparados: no hay redondeo recursivo.
        let oldBrowser = user.CraftingBrowser;
        int oldEfficiency = user.CraftingEfficiencyIndex;
        let preview = new("CaelumCraftingBrowser");
        user.CraftingBrowser = preview; user.CraftingEfficiencyIndex = 2;
        bool replacement = item.EquipmentKind == CaelumConstants.EQUIPMENT_KIND_WEAPON
            && item.ItemType == CaelumConstants.WEAPON_TYPE_BOLAS;
        bool valid = CaelumInventoryService.BuildEquipmentTaskMaterials(user, item, 1, false, preview, replacement);
        user.CraftingBrowser = oldBrowser; user.CraftingEfficiencyIndex = oldEfficiency;
        let r = user.GetPersistentCharacterState(true);
        if (valid)
            for (int i = 0; i < preview.MaterialTypes.Size(); i++)
                r.MainM00MazeRepairUnits[preview.MaterialTypes[i]] += count * preview.MaterialUnits[i];
        if (item.EquipmentKind == CaelumConstants.EQUIPMENT_KIND_WEAPON)
        {
            int recipe = item.ItemType == CaelumConstants.WEAPON_TYPE_PICKAXE ? CaelumConstants.CRAFTING_PICKAXE_RECIPE
                : item.ItemType == CaelumConstants.WEAPON_TYPE_UTILITY_STAFF ? CaelumConstants.CRAFTING_UTILITY_STAFF_RECIPE
                : item.ItemType == CaelumConstants.WEAPON_TYPE_BOLAS ? CaelumConstants.CRAFTING_BOLAS_RECIPE
                : CaelumMainM00StarterRules.GetRecipe(r.MainM00StarterOption);
            r.LearnCraftingRecipe(recipe);
        }
        else if (item.EquipmentKind == CaelumConstants.EQUIPMENT_KIND_ARMOR)
            r.LearnCraftingRecipe(CaelumConstants.CRAFTING_NETWORK_PHYSICAL_RECIPE_COUNT
                + item.ItemType * CaelumConstants.ARMOR_SLOT_COUNT + item.ArmorSlot);
    }

    static int Grant(CaelumPlayer user, int previousId, int kind, int type, int size, int slot = -1)
    {
        if (previousId > 0) return previousId;
        Class<CaelumEquipmentItem> cls = kind == CaelumConstants.EQUIPMENT_KIND_WEAPON ? "CaelumWeaponPickup"
            : kind == CaelumConstants.EQUIPMENT_KIND_ARMOR ? "CaelumArmorPickup" : "CaelumShieldPickup";
        let item = CaelumEquipmentItem(Actor.Spawn(cls, user.Pos, NO_REPLACE));
        if (item == null) return 0;
        item.EquipmentKind = kind; item.ItemType = type; item.Tier = 1; item.EquipmentSize = size;
        item.ArmorSlot = slot; item.EssenceType = CaelumConstants.ESSENCE_FIRE;
        item.SizePolicy = CaelumEquipmentRules.FIXED_SIZE; item.AcquisitionResolved = true;
        item.PickupDataInitialized = true; item.WeaponDurabilityRevision = CaelumAttackRules.DURABILITY_REVISION;
        if (kind == CaelumConstants.EQUIPMENT_KIND_WEAPON)
        {
            item.UnitWeight = user.WeaponModel.GetWeightFor(type, 1, size);
            item.Durability = user.WeaponModel.GetMaximumDurabilityFor(type, 1, size);
        }
        else if (kind == CaelumConstants.EQUIPMENT_KIND_ARMOR)
        {
            item.UnitWeight = user.ArmorModel.GetWeightFor(slot, type, 1, size);
            item.Durability = user.ArmorModel.GetMaximumDurabilityFor(type, 1, size);
        }
        else
        {
            item.UnitWeight = user.ShieldModel.GetWeightFor(type, 1, size);
            item.Durability = user.ShieldModel.GetMaximumDurabilityFor(type, 1, size);
        }
        if (!user.PrepareNativeEquipmentPickup(item)) { item.Destroy(); return 0; }
        item.AttachToOwner(user); user.EnsureEquipmentItemId(item);
        if (kind == CaelumConstants.EQUIPMENT_KIND_WEAPON)
        {
            item.ItemFlags |= CaelumConstants.CA_ITEMFLAG_LIMBO_PRESERVABLE;
            RecordRepairBudget(user, item, CaelumOnboardingCatalogue.WEAPON_REPAIRS);
            CaelumMainM00Gifts.EquipReceivedWeapon(user, item);
        }
        else if (kind == CaelumConstants.EQUIPMENT_KIND_ARMOR)
            RecordRepairBudget(user, item, CaelumOnboardingCatalogue.ARMOR_REPAIRS);
        CaelumNotifications.Acquired(user, item, 1);
        user.OnNativeInventoryChanged();
        return item.ItemId;
    }

    static void Update(CaelumPlayer user)
    {
        Initialize(user);
        if (user == null || level.MapName != "MAP01" || user.health <= 0) return;
        let r = user.GetPersistentCharacterState(false);
        if (r == null || !r.MainM00StarterChosen) return;
        if (r.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_ARGENTO_STARTED))
            r.MainM00ShieldId = Grant(user, r.MainM00ShieldId, CaelumConstants.EQUIPMENT_KIND_SHIELD,
                r.MainM00ShieldChoice - 1, r.MainM00StarterSize);
        if (r.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_RONNIE_STARTED))
        {
            r.MainM00StarterWeaponId = Grant(user, r.MainM00StarterWeaponId, CaelumConstants.EQUIPMENT_KIND_WEAPON,
                CaelumMainM00StarterRules.GetWeaponType(r.MainM00StarterOption), r.MainM00StarterSize);
            GrantStarterAmmo(user);
        }
        if (r.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_RULO_STARTED))
            for (int slot = 0; slot < CaelumConstants.ARMOR_SLOT_COUNT; slot++)
                r.MainM00ArmorIds[slot] = Grant(user, r.MainM00ArmorIds[slot], CaelumConstants.EQUIPMENT_KIND_ARMOR,
                    r.MainM00ArmorType, r.MainM00ArmorSize, slot);
        UpdateLessons(user);
    }

    static void GrantStarterAmmo(CaelumPlayer user)
    {
        let r = user.GetPersistentCharacterState(false);
        int type = CaelumMainM00StarterRules.GetWeaponType(r.MainM00StarterOption);
        if (type != CaelumConstants.WEAPON_TYPE_LONGBOW && type != CaelumConstants.WEAPON_TYPE_CROSSBOW) return;
        int ammo = type == CaelumConstants.WEAPON_TYPE_LONGBOW ? CaelumConstants.AMMUNITION_ARROW : CaelumConstants.AMMUNITION_BOLT;
        int remaining = CaelumOnboardingCatalogue.STARTER_ROUNDS - r.MainM00StarterAmmoIssued;
        user.RefreshCarriedInventorySummary();
        int room = int(Max(0.0, user.DerivedStats.CarryCapacity - user.DerivedStats.CarriedWeight
            - CaelumConstants.MATERIAL_UNIT_WEIGHT) / user.GetAmmunitionUnitWeight(ammo));
        int amount = Min(remaining, room);
        if (amount > 0 && CaelumInventoryService.AcquireDistinctAmmunition(user, ammo, amount))
            r.MainM00StarterAmmoIssued += amount;
    }

    static CaelumMainM00StarterMaterials LessonMaterials(CaelumPlayer user)
    {
        let needs = new("CaelumMainM00StarterMaterials"); needs.Valid = true; needs.Efficiency = 2;
        needs.AddUtility(CaelumConstants.CRAFTING_SLEEPING_BAG_RECIPE);
        needs.AddUtility(CaelumConstants.CRAFTING_LARGE_CANTEEN_RECIPE);
        let r = user.GetPersistentCharacterState(false);
        if (r.MainM00SealChoice > 0) needs.AddSeal(r.MainM00SealChoice - 1);
        return needs;
    }

    static void Teach(CaelumPlayer user)
    {
        let r = user.GetPersistentCharacterState(false);
        let needs = LessonMaterials(user);
        for (int recipe = 0; recipe < CaelumConstants.CRAFTING_NETWORK_PLAYABLE_RECIPE_COUNT; recipe++)
            if (needs.Recipes[recipe]) r.LearnCraftingRecipe(recipe);
        r.MainM00SealRecipesLearned = r.MainM00SealChoice > 0;
        if (!user.CraftingTaskActive) { user.CraftingEfficiencyIndex = 2; user.ResetCraftingLayerChoices(); }
        user.RefreshCraftingRecipeBookSummary();
    }

    static bool ClaimMaterials(CaelumPlayer user)
    {
        if (!CaelumMainM00RonnieTrial.IsRonnie(user) || !CaelumMainM00RonnieTrial.IsStarted(user)) return false;
        let r = user.GetPersistentCharacterState(false);
        if (!r.MainM00GoldRewardStarted)
        {
            int gold = int(CaelumOnboardingCatalogue.GOLD_KG / CaelumConstants.MATERIAL_UNIT_WEIGHT);
            if (user.CraftingTaskActive || user.CountRawCraftingMaterial(CaelumConstants.MATERIAL_RAW_GOLD, 1) < gold) return false;
            if (!user.ConsumeCraftingMaterial(CaelumConstants.MATERIAL_RAW_GOLD, 1, gold)) return false;
            r.MainM00GoldRewardStarted = true;
            r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_MATERIALS_COMPLETE);
        }
        let needs = LessonMaterials(user);
        for (int material = 0; material < CaelumConstants.MATERIAL_TYPE_COUNT; material++)
        {
            int amount = Min(Max(0, needs.Units[material] - r.MainM00SupplyIssued[material]), CaelumMainM00SupplyRules.CarryRoom(user));
            if (amount <= 0) continue;
            let item = CaelumMaterialPickup(Actor.Spawn("CaelumMaterialPickup", user.Pos, NO_REPLACE));
            if (item == null) continue;
            item.args[0] = material; item.args[1] = 1; item.Amount = amount;
            item.LimboQuotaReserved = true; item.LimboQuotaPlayer = user.PlayerNumber();
            item.LimboQuestUnits = amount; item.UpdateMaterialVisuals();
            Actor receiver = user;
            if (!item.CallTryPickup(receiver)) { item.Destroy(); continue; }
            r.MainM00SupplyIssued[material] += amount;
            user.OnNativeInventoryChanged();
        }
        user.PersistCharacterState(); return true;
    }

    static bool LessonsComplete(CaelumPersistentCharacterState r)
    { return r != null && r.MainM00GoldRewardStarted && r.MainM00CraftedBag != null
        && r.MainM00CraftedCanteen != null && r.MainM00CraftedSealId > 0; }

    static void TransferUtilityIdentity(Inventory original, Inventory copy)
    {
        if (copy == null || copy == original) return;
        // El motor puede copiar un Inventory al soltarlo o recogerlo.
        for (int i = 0; i < MAXPLAYERS; i++)
        {
            let user = CaelumPlayer(players[i].mo);
            if (user == null) continue;
            let r = user.GetPersistentCharacterState(false);
            if (r == null) continue;
            if (r.MainM00CraftedBag == original) r.MainM00CraftedBag = copy;
            if (r.MainM00CraftedCanteen == original) r.MainM00CraftedCanteen = copy;
        }
    }

    static bool IsStarterAmmo(CaelumPlayer user, Inventory item)
    {
        let r = user.GetPersistentCharacterState(false);
        int weapon = CaelumMainM00StarterRules.GetWeaponType(r.MainM00StarterOption);
        return (weapon == CaelumConstants.WEAPON_TYPE_LONGBOW && item is "CaelumArrowAmmo")
            || (weapon == CaelumConstants.WEAPON_TYPE_CROSSBOW && item is "CaelumBoltAmmo");
    }

    static bool PackDeparture(CaelumPlayer user)
    {
        let r = user.GetPersistentCharacterState(false);
        if (!LessonsComplete(r) || r.MainM00CraftedBag.Owner != user || r.MainM00CraftedCanteen.Owner != user) return false;
        int ids[11];
        ids[0] = r.MainM00StarterWeaponId; ids[1] = r.MainM00ShieldId;
        ids[2] = r.MainM00NecklaceItemId; ids[3] = r.MainM00CraftedSealId;
        ids[4] = r.MainM00PickaxeId; ids[5] = r.MainM00UtilityStaffId; ids[6] = r.MainM00BolasId;
        for (int slot = 0; slot < CaelumConstants.ARMOR_SLOT_COUNT; slot++) ids[7 + slot] = r.MainM00ArmorIds[slot];
        for (int i = 0; i < 11; i++)
        {
            let piece = user.FindNativeEquipmentItemById(ids[i]);
            if (ids[i] <= 0 || piece == null || piece.Owner != user) return false;
        }
        let deck = CaelumSpecialInventoryItem(user.FindInventory("CaelumTarotDeck"));
        if (deck == null) return false;
        // Las joyas que se guardan ya no aportan Inteligencia a la capacidad.
        let attributes = new("CaelumAttributes");
        attributes.InitializeFromCreation(user.CharacterProfile, user.CharacterAllocation);
        attributes.ApplyTarotMinorBonuses(r); attributes.ApplyTarotBonus(r.GetTarotAttributeBonusPercent());
        int slots = 0;
        for (Inventory cursor = user.Inv; cursor != null; cursor = cursor.Inv)
            if (cursor is "CaelumEquipmentItem" || cursor is "CaelumTarotDeck" || cursor is "CaelumSleepingBag"
                || cursor == r.MainM00CraftedCanteen || IsStarterAmmo(user, cursor)) slots++;
        if (slots > CaelumEquipmentRules.MagicBoxSlots(attributes.Intelligence)) return false;
        // Sin recrear nada: desactiva cada equipo por la operación nativa y
        // conserva la misma instancia, condición, agua y esencia capturada.
        for (Inventory cursor = user.Inv; cursor != null; cursor = cursor.Inv)
        {
            let equipment = CaelumEquipmentItem(cursor);
            if (equipment != null)
            {
                user.EquipmentSelectionItemId = equipment.ItemId;
                if (equipment.Equipped) user.UnequipSelectedNativeEquipment();
                equipment.InMagicBox = true;
            }
            let special = CaelumSpecialInventoryItem(cursor);
            if (special != null && (cursor is "CaelumTarotDeck" || cursor is "CaelumSleepingBag")) special.InMagicBox = true;
            if (cursor == r.MainM00CraftedCanteen) CaelumConsumableItem(cursor).InMagicBox = true;
            if (IsStarterAmmo(user, cursor)) CaelumCarbineAmmo(cursor).InMagicBox = true;
        }
        user.OnNativeInventoryChanged(); return true;
    }

    static void UpdateLessons(CaelumPlayer user)
    {
        let r = user.GetPersistentCharacterState(false);
        if (r == null) return;
        user.MainM00GoldRewardSnapshot = r.MainM00GoldRewardStarted;
        bool complete = LessonsComplete(r);
        user.MainM00LessonsCompleteSnapshot = complete;
        user.SetPalomoDialogueToken("CaelumM00StarterCraftedToken", complete);
        r.SetQuestObjectiveProgress(0, CaelumConstants.MAIN_M00_OBJECTIVE_GATHER_MATERIALS, r.MainM00GoldRewardStarted ? 1 : 0, 1);
        r.SetQuestObjectiveProgress(0, CaelumConstants.MAIN_M00_OBJECTIVE_PREPARE_WEAPON,
            int(r.MainM00CraftedBag != null) + int(r.MainM00CraftedCanteen != null) + int(r.MainM00CraftedSealId > 0), 3);
        if (!complete) return;
        r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_STARTER_WEAPON_CRAFTED);
        r.TryAdvanceMainM00State(CaelumConstants.MAIN_M00_STATE_RONNIE_ACTIVE, CaelumConstants.MAIN_M00_STATE_RONNIE_COMPLETE);
        r.TryAdvanceMainM00State(CaelumConstants.MAIN_M00_STATE_RONNIE_COMPLETE, CaelumConstants.MAIN_M00_STATE_WEAPON_READY);
    }
}

class CaelumM00ClaimLessonMaterials : CaelumPalomoDialogueAction
{ override bool Use(bool pickup) { return CaelumOnboarding.ClaimMaterials(CaelumPlayer(Owner)); } }

class CaelumTutorialGoldVein : CaelumVeinGold
{
    override bool IsFiniteResource() { return true; }
    override void PostBeginPlay()
    { args[4] = CaelumOnboardingCatalogue.GOLD_KG; Super.PostBeginPlay(); }
}
