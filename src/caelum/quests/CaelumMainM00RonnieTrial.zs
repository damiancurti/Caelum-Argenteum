// Recolección de Ronnie: autoridad en el Inventory viajero, presentación
// reconstruible y crafting nativo. No hay un segundo sistema de fabricación.
class CaelumMainM00RonnieTrial : Object play
{
    static bool CanInteract(CaelumPlayer user)
    {
        return user != null && user.player != null && user.health > 0
            && user.player.playerstate == PST_LIVE && user.CharacterCreationComplete
            && !user.CreationWizardOpen && !(user.player.cheats & CF_PREDICTING)
            && level.MapName == "MAP01";
    }

    static bool IsStarted(CaelumPlayer user)
    {
        if (user == null) return false;
        let record = user.GetPersistentCharacterState(false);
        return record != null && record.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_RONNIE_STARTED);
    }

    static bool IsRonnie(CaelumPlayer user)
    {
        if (!CanInteract(user)) return false;
        let speaker = CaelumRonnie(user.player.ConversationNPC);
        return speaker != null && speaker.StoryAnchored;
    }

    // Ampliación opcional: observar la reparación nativa, sin otra tarea,
    // otro coste ni un requisito nuevo para completar la misión principal.
    static bool OfferRepairLesson(CaelumPlayer user)
    {
        if (!IsRonnie(user)) return false;
        let r = user.GetPersistentCharacterState(false);
        if (r == null || !r.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_RONNIE_COMPLETE)
            || r.MainM00StarterWeaponId <= 0 || r.QuestStage[0] >= CaelumConstants.MAIN_M00_STATE_EXIT_CONFIRMED)
            return false;
        r.MainM00RepairLessonOffered = true;
        CaelumMainM00SupplyRules.PrepareRepairSupply(user);
        user.PersistCharacterState();
        return true;
    }

    static void RecordRepairLesson(CaelumPlayer user, CaelumEquipmentItem item, int previousDurability)
    {
        if (!CanInteract(user) || item == null || item.Owner != user
            || item.EquipmentKind != CaelumConstants.EQUIPMENT_KIND_WEAPON
            || !user.CraftingTaskActive || !user.CraftingTaskCompleting
            || user.CraftingTaskKind != CaelumConstants.CRAFTING_TASK_REPAIR
            || user.CraftingTaskTargetItemId != item.ItemId
            || previousDurability >= item.Durability) return;
        let r = user.GetPersistentCharacterState(false);
        if (r == null || !r.MainM00RepairLessonOffered || r.MainM00RepairLessonComplete
            || !r.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_RONNIE_COMPLETE)
            || r.MainM00StarterWeaponId != item.ItemId) return;
        r.MainM00RepairLessonComplete = true;
        // CompleteCraftingTask persiste después de cerrar reservas y tarea.
        user.RefreshSocialJournalSnapshot();
    }

    // La confirmación prepara una demostración segura una sola vez. No cura
    // estados previos bajos ni vuelve a reducir necesidades al reabrir.
    static bool StartNeedsLesson(CaelumPlayer user)
    {
        if (!IsRonnie(user)) return false;
        let r = user.GetPersistentCharacterState(false);
        if (r == null || !r.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_RONNIE_COMPLETE)
            || r.QuestStage[0] >= CaelumConstants.MAIN_M00_STATE_EXIT_CONFIRMED) return false;
        if (!r.MainM00NeedsLessonStarted)
        {
            r.MainM00NeedsLessonStarted = true;
            user.CurrentHunger = Min(user.CurrentHunger, 90.0);
            user.CurrentThirst = Min(user.CurrentThirst, 90.0);
            user.UpdateSurvivalStates();
        }
        // Flags independientes: si la carga impide recibir una ración, volver
        // a confirmar sólo reintenta esa entrega. Nunca duplica la otra.
        if (!r.MainM00NeedsFoodGiven)
            r.MainM00NeedsFoodGiven = user.GiveInventoryType("CaelumFoodRation") != null;
        if (!r.MainM00NeedsWaterGiven)
            r.MainM00NeedsWaterGiven = user.GiveInventoryType("CaelumWaterRation") != null;
        user.OnNativeInventoryChanged();
        user.PersistCharacterState();
        return true;
    }

    static void RecordNeedsUse(CaelumPlayer user, int kind)
    {
        if (!CanInteract(user)) return;
        let r = user.GetPersistentCharacterState(false);
        if (r == null || !r.MainM00NeedsLessonStarted
            || r.QuestStage[0] >= CaelumConstants.MAIN_M00_STATE_EXIT_CONFIRMED) return;
        if (kind == CaelumConstants.CONSUMABLE_FOOD_RATION
            && user.CurrentHunger < CaelumConstants.SURVIVAL_MAXIMUM)
            r.MainM00NeedsFoodUsed = true;
        if (kind == CaelumConstants.CONSUMABLE_WATER_RATION
            && user.CurrentThirst < CaelumConstants.SURVIVAL_MAXIMUM)
            r.MainM00NeedsWaterUsed = true;
        user.PersistCharacterState();
    }

    static bool StartAirLesson(CaelumPlayer user)
    {
        if (!IsRonnie(user) || user.DerivedStats == null) return false;
        let r = user.GetPersistentCharacterState(false);
        if (r == null || !r.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_RONNIE_COMPLETE)
            || r.QuestStage[0] >= CaelumConstants.MAIN_M00_STATE_EXIT_CONFIRMED
            || user.DerivedStats.MaximumAir <= 0) return false;
        if (!r.MainM00AirLessonStarted)
        {
            r.MainM00AirLessonStarted = true;
            r.MainM00AirLessonTarget = user.DerivedStats.MaximumAir * 0.01;
        }
        user.PersistCharacterState();
        return true;
    }

    // Observa los dos puntos nativos: gasto al correr y recuperación natural.
    // El registro Inventory se serializa con la partida; no duplica el reloj.
    static void RecordAirLesson(CaelumPlayer user, double amount, bool running)
    {
        if (!CanInteract(user) || amount <= 0 || user.player.ConversationNPC != null) return;
        let r = user.GetPersistentCharacterState(false);
        if (r == null || !r.MainM00AirLessonStarted || r.MainM00AirLessonComplete
            || r.MainM00AirLessonTarget <= 0
            || r.QuestStage[0] >= CaelumConstants.MAIN_M00_STATE_EXIT_CONFIRMED) return;
        if (running)
        {
            if (r.MainM00AirLessonRan || !user.IsRunningOnGround()
                || user.Vel.X * user.Vel.X + user.Vel.Y * user.Vel.Y < 0.01) return;
            r.MainM00AirLessonSpent = Min(r.MainM00AirLessonTarget, r.MainM00AirLessonSpent + amount);
            if (r.MainM00AirLessonSpent >= r.MainM00AirLessonTarget)
            {
                r.MainM00AirLessonRan = true;
                user.RefreshSocialJournalSnapshot();
            }
        }
        else if (r.MainM00AirLessonRan)
        {
            r.MainM00AirLessonRecovered = Min(r.MainM00AirLessonTarget, r.MainM00AirLessonRecovered + amount);
            if (r.MainM00AirLessonRecovered >= r.MainM00AirLessonTarget)
            {
                r.MainM00AirLessonComplete = true;
                user.RefreshSocialJournalSnapshot();
            }
        }
    }

    static bool StartLoadLesson(CaelumPlayer user)
    {
        if (!IsRonnie(user)) return false;
        let r = user.GetPersistentCharacterState(false);
        if (r == null || !r.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_RONNIE_COMPLETE)
            || r.QuestStage[0] >= CaelumConstants.MAIN_M00_STATE_EXIT_CONFIRMED) return false;
        r.MainM00LoadLessonStarted = true;
        user.RefreshCarriedInventorySummary();
        user.PersistCharacterState();
        return true;
    }

    // Sólo observa guardar/soltar mediante el inventario: consumir, fabricar,
    // subir atributos o retirar peso de depuración no completan la práctica.
    static void RecordLoadLesson(CaelumPlayer user, double previousWeight, int selectedId)
    {
        if (!CanInteract(user) || user.DerivedStats == null) return;
        let r = user.GetPersistentCharacterState(false);
        if (r == null || !r.MainM00LoadLessonStarted || r.MainM00LoadLessonComplete
            || r.QuestStage[0] >= CaelumConstants.MAIN_M00_STATE_EXIT_CONFIRMED
            || (selectedId > 0 && selectedId == r.MainM00StarterWeaponId)) return;
        if (user.LastEquipmentAction != CaelumConstants.EQUIPMENT_ACTION_DROPPED
            && user.LastEquipmentAction != CaelumConstants.EQUIPMENT_ACTION_STORED_IN_MAGIC_BOX) return;
        user.RefreshCarriedInventorySummary();
        if (user.DerivedStats.CarriedItemWeight >= previousWeight - 0.000001) return;
        r.MainM00LoadLessonComplete = true;
        user.PersistCharacterState();
    }

    static bool StartSwimLesson(CaelumPlayer user)
    {
        if (!IsRonnie(user) || user.DerivedStats == null || user.WaterLevel >= 3) return false;
        let r = user.GetPersistentCharacterState(false);
        if (r == null || !r.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_RONNIE_COMPLETE)
            || r.QuestStage[0] >= CaelumConstants.MAIN_M00_STATE_EXIT_CONFIRMED
            || user.DerivedStats.MaximumAir <= 0) return false;
        r.MainM00SwimLessonStarted = true;
        user.PersistCharacterState();
        return true;
    }

    // Observa el gasto submarino y su devolución nativa; no agrega un reloj
    // ni modifica costes. Sólo la piscina de MAP01 acredita la inmersión.
    static void RecordSwimLesson(CaelumPlayer user, double amount, bool submerged)
    {
        if (!CanInteract(user) || amount <= 0 || user.player.ConversationNPC != null) return;
        let r = user.GetPersistentCharacterState(false);
        if (r == null || !r.MainM00SwimLessonStarted || r.MainM00SwimLessonComplete
            || r.QuestStage[0] >= CaelumConstants.MAIN_M00_STATE_EXIT_CONFIRMED) return;
        if (submerged)
        {
            if (r.MainM00SwimLessonSubmerged || !user.IsSubmergedInPotableWater()
                || !user.UnderwaterWithoutOxygen || user.HasUnderwaterAirExemption()
                || user.UnderwaterNoBreathTics < TICRATE) return;
            r.MainM00SwimLessonSubmerged = true;
        }
        else
        {
            if (!r.MainM00SwimLessonSubmerged || user.WaterLevel >= 3
                || user.UnderwaterWithoutOxygen || !user.UnderwaterAirRecoveryAppliedThisTick
                || user.UnderwaterAirRecoveryDebt > 0.000001
                || user.UnderwaterAirRecoveryTicsRemaining > 0) return;
            r.MainM00SwimLessonComplete = true;
        }
        // El Inventory y los contadores submarinos ya viajan y se guardan.
        user.RefreshSocialJournalSnapshot();
    }

    static void Feedback(CaelumPlayer user, String key)
    {
        if (user != null) user.A_Print(StringTable.Localize(key, false));
    }

    static CaelumEquipmentItem FindLoan(CaelumPlayer user)
    {
        if (user == null) return null;
        let record = user.GetPersistentCharacterState(false);
        if (record == null) return null;
        let loan = user.FindNativeEquipmentItemById(record.MainM00RonnieSwordId);
        return loan != null && loan.IsLimboTemporary() ? loan : null;
    }

    static bool PrepareLoan(CaelumPlayer user, bool forRepair = false)
    {
        if (!CanInteract(user) || !IsStarted(user) || user.WeaponModel == null) return false;
        let record = user.GetPersistentCharacterState(true);
        if (record.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_RONNIE_COMPLETE))
        {
            let first = user.FindNativeEquipmentItemById(record.MainM00StarterWeaponId);
            if (!forRepair || !record.MainM00RepairLessonOffered || record.MainM00RepairLessonComplete
                || record.QuestStage[0] >= CaelumConstants.MAIN_M00_STATE_EXIT_CONFIRMED
                || first == null || first.Durability >= user.GetEquipmentTaskMaximumDurability(first)) return false;
        }
        user.SyncActiveModelsToNativeInventory();
        let loan = FindLoan(user);
        if (loan == null)
        {
            // Migra la espada antigua sin sustituir su instancia ni su ItemId.
            for (Inventory cursor = user.Inv; cursor != null; cursor = cursor.Inv)
            {
                if (cursor is "CaelumM01SwordPickup") { loan = CaelumEquipmentItem(cursor); break; }
            }
            if (loan == null)
                loan = CaelumEquipmentItem(Actor.Spawn("CA_LimboRonnieSword", user.Pos, NO_REPLACE));
            if (loan == null) return false;
            if (loan.Owner == null)
            {
                loan.EquipmentKind = CaelumConstants.EQUIPMENT_KIND_WEAPON;
                loan.ItemType = CaelumConstants.WEAPON_TYPE_SWORD;
                loan.Tier = 1;
                loan.EquipmentSize = record.MainM00StarterSize;
                loan.ArmorSlot = -1;
                loan.EssenceType = CaelumConstants.ESSENCE_FIRE;
                loan.UnitWeight = user.WeaponModel.GetWeightFor(loan.ItemType, 1, loan.EquipmentSize);
                loan.PickupDataInitialized = true;
                if (forRepair && !user.CanAddWeightToPersonalInventory(loan.UnitWeight + CaelumConstants.MATERIAL_UNIT_WEIGHT))
                { loan.Destroy(); Feedback(user, "CA_M01_REPAIR_LOAN_NO_ROOM"); return false; }
                loan.AttachToOwner(user);
                user.EnsureEquipmentItemId(loan);
            }
            loan.ItemFlags |= CaelumConstants.CA_ITEMFLAG_LIMBO_TEMP;
            record.MainM00RonnieSwordId = loan.ItemId;
        }
        // Igual que el préstamo de Caella: revisar el préstamo restaura la
        // misma pieza; no concede armas ni materiales repetidos.
        loan.Durability = user.WeaponModel.GetMaximumDurabilityFor(loan.ItemType, loan.Tier, loan.EquipmentSize);
        loan.InMagicBox = false;
        loan.Equipped = true;
        user.ActivateExactEquippedWeapon(loan);
        user.ApplyCharacterProfile();
        user.EnsureWeaponFamilySelectors();
        user.PersistCharacterState();
        user.RefreshEquipmentSelectionPreview();
        return true;
    }

    static void ReturnLoan(CaelumPlayer user)
    {
        let loan = FindLoan(user);
        if (loan == null) return;
        let record = user.GetPersistentCharacterState(true);
        bool active = user.ActiveWeaponItemId == loan.ItemId;
        if (active) { user.ActiveWeaponItemId = 0; user.WeaponModel.Equipped = false; }
        loan.Destroy();
        if (active)
        {
            let first = user.FindNativeEquipmentItemById(record.MainM00StarterWeaponId);
            if (first != null && !first.InMagicBox)
            { first.Equipped = true; user.ActivateExactEquippedWeapon(first); }
            else user.ActivateFirstEquippedWeapon();
        }
        user.ApplyCharacterProfile();
        user.EnsureWeaponFamilySelectors();
        user.PersistCharacterState();
        user.RefreshEquipmentSelectionPreview();
    }

    static bool Choose(CaelumPlayer user, int option)
    {
        if (!IsRonnie(user) || !CaelumMainM00StarterRules.IsOption(option)) return false;
        let record = user.GetPersistentCharacterState(true);
        if (!record.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_CAELLA_COMPLETE)
            || record.MainM00StarterChosen || record.MainM00StarterWeaponId > 0) return false;
        int size = CaelumEquipmentRules.GetDefaultSizeForCharacterTier(user.CharacterProfile.GetSizeTier());
        let requirements = new("CaelumMainM00StarterMaterials");
        if (!requirements.Build(option, size, 2)) return false;
        if (!record.TryAdvanceMainM00State(CaelumConstants.MAIN_M00_STATE_CAELLA_COMPLETE,
            CaelumConstants.MAIN_M00_STATE_RONNIE_ACTIVE)) return false;
        record.MainM00StarterChosen = true;
        record.MainM00StarterOption = option;
        record.MainM00StarterSize = size;
        record.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_RONNIE_STARTED);
        for (int i = 0; i < CaelumConstants.MATERIAL_TYPE_COUNT; i++)
        {
            record.MainM00StarterRequired[i] = requirements.Units[i];
            user.MainM00StarterMissingSnapshot[i] = requirements.Units[i];
        }
        for (int i = 0; i < CaelumConstants.CRAFTING_NETWORK_PLAYABLE_RECIPE_COUNT; i++)
            if (requirements.Recipes[i]) record.LearnCraftingRecipe(i);
        EnsureSupplies(user);
        PrepareLoan(user);
        // Lleva al catálogo conocido sin abrir una estación a distancia.
        user.CraftingSelectionRecipe = CaelumMainM00StarterRules.GetRecipe(option);
        user.CraftingSelectionTier = 1;
        user.CraftingSelectionSize = size;
        user.CraftingEfficiencyIndex = 2;
        user.ResetCraftingLayerChoices();
        Sync(user);
        return true;
    }

    static void TeachStarterAmmunition(CaelumPlayer user)
    {
        if (user == null) return;
        let record = user.GetPersistentCharacterState(false);
        if (record == null || !record.MainM00StarterChosen) return;
        int recipe = record.MainM00StarterOption == 15 ? CaelumConstants.CRAFTING_BOLT_RECIPE
            : (record.MainM00StarterOption == 12 || record.MainM00StarterOption == 14)
            ? CaelumConstants.CRAFTING_ARROW_RECIPE : -1;
        if (recipe < 0 || record.KnowsCraftingRecipe(recipe)) return;
        record.LearnCraftingRecipe(recipe);
        let dependencies = new("CaelumMainM00StarterMaterials");
        dependencies.Build(record.MainM00StarterOption, record.MainM00StarterSize);
        double weight = user.GetAmmunitionUnitWeight(CaelumCraftingRules.GetRecipeAmmunitionType(recipe))
            * CaelumCraftingRules.GetRecipeAmmunitionBatch(recipe);
        dependencies.Expand(CaelumConstants.MATERIAL_SHAFT, dependencies.ScaleUnits(
            CaelumCraftingRules.GetRoundedMaterialUnits(weight, 0.7)));
        dependencies.Expand(CaelumConstants.MATERIAL_POINT, dependencies.ScaleUnits(
            CaelumCraftingRules.GetRoundedMaterialUnits(weight, 0.3)));
        for (int i = 0; i < CaelumConstants.CRAFTING_NETWORK_PLAYABLE_RECIPE_COUNT; i++)
            if (dependencies.Recipes[i]) record.LearnCraftingRecipe(i);
        user.RefreshCraftingRecipeBookSummary();
    }

    static void EnsureSupplies(CaelumPlayer user)
    {
        if (!IsStarted(user)) return;
        let record = user.GetPersistentCharacterState(true);
        CaelumMainM00SupplyRules.Ensure(user);
        CaelumMainM00SupplyRules.RefreshChest(user);
    }

    static bool OpenChest(CaelumPlayer user, CaelumMainM00SupplyChest chest)
    {
        if (!CanInteract(user) || chest == null) return false;
        if (!IsStarted(user)) { Feedback(user, "CA_M01_CHEST_RONNIE_FIRST"); return true; }
        EnsureSupplies(user);
        Sync(user);
        user.EquipmentMenuOpen = false;
        user.CloseCraftingStationSession();
        user.SetCraftingJournalState(false);
        Level.ExecuteSpecial(CaelumConstants.GZDOOM_THING_SET_CONVERSATION_SPECIAL,
            chest, null, false, 0, 43315);
        return chest.HasConversation() && chest.StartConversation(user, true, true);
    }

    static bool UseSupply(CaelumPlayer user, int slot)
    {
        if (!CanInteract(user) || !IsStarted(user)
            || !(user.player.ConversationNPC is "CaelumMainM00SupplyChest")) return false;
        EnsureSupplies(user);
        let record = user.GetPersistentCharacterState(true);
        if (slot < 0)
        {
            for (int i = 5; i < CaelumMainM00StarterRules.SUPPLY_COUNT; i++)
            {
                let item = user.FindNativeSpecialItem(CaelumConstants.EQUIPMENT_KIND_MATERIAL,
                    CaelumMainM00StarterRules.GetSupplyMaterial(i), 1);
                if (item == null) continue;
                int returned = Min(item.Amount, item.LimboSupplyUnits);
                returned = Min(returned, Max(0, item.Amount - user.GetReservedCraftingMaterialUnits(
                    CaelumMainM00StarterRules.GetSupplyMaterial(i), 1)));
                returned = Min(returned, record.MainM00SupplyInitial[i] - record.MainM00SupplyRemaining[i]);
                if (returned <= 0) continue;
                record.MainM00SupplyIssued[CaelumMainM00StarterRules.GetSupplyMaterial(i)] = Max(0,
                    record.MainM00SupplyIssued[CaelumMainM00StarterRules.GetSupplyMaterial(i)] - returned);
                item.LimboSupplyUnits -= returned;
                item.LimboQuestUnits = Max(0, item.LimboQuestUnits - returned);
                item.Amount -= returned;
                if (item.Amount <= 0) item.Destroy();
            }
        }
        else
        {
            if (slot != 5) return false;
            user.RefreshCarriedInventorySummary();
            int capacity = CaelumMainM00SupplyRules.CarryRoom(user);
            int amount = Min(capacity, record.MainM00SupplyRemaining[slot]);
            int material = CaelumMainM00StarterRules.GetSupplyMaterial(slot);
            // El cupo ya incluye arma, conjunto elegido y todo lo retirado.
            amount = Min(amount, CaelumMainM00SupplyRules.Remaining(user, material));
            if (amount <= 0) { Feedback(user, "CA_M01_CHEST_NO_TRANSFER"); return true; }
            let item = user.FindNativeSpecialItem(CaelumConstants.EQUIPMENT_KIND_MATERIAL, material, 1);
            if (item == null)
            {
                item = user.CreateDetachedMaterialStack(material, 1, amount);
                if (item == null) return false;
                item.InMagicBox = false;
                item.AttachToOwner(user);
            }
            else
            {
                if (item.InMagicBox) { Feedback(user, "CA_M01_CHEST_NO_TRANSFER"); return true; }
                item.Amount += amount;
            }
            item.LimboQuestUnits += amount;
            item.LimboSupplyUnits += amount;
            CaelumMainM00SupplyRules.Issue(user, material, amount);
        }
        CaelumMainM00SupplyRules.RefreshChest(user);
        user.OnNativeInventoryChanged();
        Sync(user);
        return true;
    }

    static bool CanUsePersonalCraftingOutput(CaelumPlayer user)
    {
        return CanInteract(user) && IsStarted(user) && user.CraftingSelectionTier == 1
            && (CaelumMainM00StarterRules.IsWeaponRecipe(user.CraftingSelectionRecipe)
                || CaelumMainM00SupplyRules.IsChosenArmorRecipe(user));
    }

    static void RecordCraft(CaelumPlayer user, CaelumEquipmentItem result)
    {
        if (!CanUsePersonalCraftingOutput(user) || result == null
            || result.EquipmentKind != CaelumConstants.EQUIPMENT_KIND_WEAPON) return;
        let record = user.GetPersistentCharacterState(true);
        if (record.MainM00StarterWeaponId > 0)
        {
            result.ItemFlags |= CaelumConstants.CA_ITEMFLAG_LIMBO_TEMP;
            Feedback(user, "CA_M01_STARTER_EXTRA");
            return;
        }
        result.ItemFlags |= CaelumConstants.CA_ITEMFLAG_LIMBO_PRESERVABLE;
        record.MainM00StarterWeaponId = result.ItemId;
        record.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_MATERIALS_COMPLETE);
        record.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_STARTER_WEAPON_CRAFTED);
        record.TryAdvanceMainM00State(CaelumConstants.MAIN_M00_STATE_RONNIE_ACTIVE,
            CaelumConstants.MAIN_M00_STATE_RONNIE_COMPLETE);
        record.TryAdvanceMainM00State(CaelumConstants.MAIN_M00_STATE_RONNIE_COMPLETE,
            CaelumConstants.MAIN_M00_STATE_WEAPON_READY);
        record.SetQuestObjectiveProgress(CaelumConstants.QUEST_MAIN_M00_THE_FOOL,
            CaelumConstants.MAIN_M00_OBJECTIVE_GATHER_MATERIALS, 1, 1);
        record.SetQuestObjectiveProgress(CaelumConstants.QUEST_MAIN_M00_THE_FOOL,
            CaelumConstants.MAIN_M00_OBJECTIVE_PREPARE_WEAPON, 1, 1);
        Sync(user);
        Feedback(user, "CA_M01_STARTER_CREATED");
    }

    static bool Finish(CaelumPlayer user)
    {
        if (!IsRonnie(user)) return false;
        let record = user.GetPersistentCharacterState(true);
        let first = user.FindNativeEquipmentItemById(record.MainM00StarterWeaponId);
        if (first == null || !record.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_STARTER_WEAPON_CRAFTED)) return false;
        if (!record.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_RONNIE_COMPLETE)) return false;
        ReturnLoan(user);
        Sync(user);
        return true;
    }

    static void Sync(CaelumPlayer user)
    {
        if (user == null) return;
        let record = user.GetPersistentCharacterState(false);
        if (record == null) return;
        TeachStarterAmmunition(user);
        CaelumMainM00SupplyRules.Ensure(user);
        user.SetPalomoDialogueToken("CaelumM00ArmorChosenToken", record.MainM00ArmorChosen);
        user.SetPalomoDialogueToken("CaelumM00RonnieStartedToken", record.MainM00StarterChosen);
        user.SetPalomoDialogueToken("CaelumM00StarterCraftedToken", record.MainM00StarterWeaponId > 0);
        user.SetPalomoDialogueToken("CaelumM00RonnieFinishedToken",
            record.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_RONNIE_COMPLETE));
        user.RefreshSocialJournalSnapshot();
        user.PersistCharacterState();
    }

    static void Update(CaelumPlayer user)
    {
        if (!IsStarted(user)) return;
        // El conocimiento pendiente también se incorpora al cargar fuera del
        // Limbo; no concede munición, materiales ni vuelve a prestar la espada.
        if (level.time % TICRATE == 0) TeachStarterAmmunition(user);
        if (level.MapName != "MAP01")
        {
            if (level.time % TICRATE != 0) return;
            if (user.CraftingTaskActive && user.CraftingTaskUsesLimboMaterials)
                user.CancelCraftingTask();
            ReturnLoan(user);
            bool changed = false;
            bool lostActiveWeapon = false;
            // Sólo retira cantidades/instancias temporales; conserva cualquier
            // stock anterior del jugador aunque comparta el tipo de material.
            for (Inventory cursor = user.Inv; cursor != null;)
            {
                Inventory next = cursor.Inv;
                let item = CaelumSpecialInventoryItem(cursor);
                if (item != null && item.LimboQuestUnits > 0)
                {
                    changed = true;
                    item.Amount -= Min(item.Amount, item.LimboQuestUnits);
                    item.LimboQuestUnits = 0; item.LimboSupplyUnits = 0;
                    if (item.Amount <= 0) item.Destroy();
                }
                let equipment = CaelumEquipmentItem(cursor);
                if (equipment != null && equipment.IsLimboTemporary()
                    && !(equipment is "CA_LimboMagicImplement") && !(equipment is "CA_LimboMagicSeal"))
                {
                    changed = true;
                    if (user.ActiveWeaponItemId == equipment.ItemId)
                    {
                        lostActiveWeapon = true;
                        user.ActiveWeaponItemId = 0;
                        if (user.WeaponModel != null) user.WeaponModel.Equipped = false;
                    }
                    equipment.Destroy();
                }
                cursor = next;
            }
            if (lostActiveWeapon)
            {
                let record = user.GetPersistentCharacterState(true);
                let first = user.FindNativeEquipmentItemById(record.MainM00StarterWeaponId);
                if (first != null && !first.InMagicBox)
                { first.Equipped = true; user.ActivateExactEquippedWeapon(first); }
                else user.ActivateFirstEquippedWeapon();
            }
            if (changed) { user.OnNativeInventoryChanged(); Sync(user); }
            return;
        }
        if (!CanInteract(user) || level.time % TICRATE != 0) return;
        let record = user.GetPersistentCharacterState(true);
        if (record.MainM00StarterWeaponId == 0)
        {
            let requirements = new("CaelumMainM00StarterMaterials");
            requirements.Build(record.MainM00StarterOption, record.MainM00StarterSize, 2, user);
            bool ready = requirements.IsSatisfied();
            record.SetQuestObjectiveProgress(CaelumConstants.QUEST_MAIN_M00_THE_FOOL,
                CaelumConstants.MAIN_M00_OBJECTIVE_GATHER_MATERIALS, ready ? 1 : 0, 1);
            record.SetQuestObjectiveProgress(CaelumConstants.QUEST_MAIN_M00_THE_FOOL,
                CaelumConstants.MAIN_M00_OBJECTIVE_PREPARE_WEAPON, 0, 1);
            for (int i = 0; i < CaelumConstants.MATERIAL_TYPE_COUNT; i++)
                user.MainM00StarterMissingSnapshot[i] = requirements.Units[i];
        }
        Sync(user);
    }
}

class CA_LimboRonnieSword : CaelumWeaponPickup {}
class CaelumM00RonnieStartedToken : CaelumPalomoDialogueMarker {}
class CaelumM00StarterCraftedToken : CaelumPalomoDialogueMarker {}
class CaelumM00RonnieFinishedToken : CaelumPalomoDialogueMarker {}

class CaelumM00RepairRonnieLoanAction : CaelumPalomoDialogueAction
{
    override bool Use(bool pickup)
    {
        let user = CaelumPlayer(Owner);
        return CaelumMainM00RonnieTrial.IsRonnie(user) && CaelumMainM00RonnieTrial.PrepareLoan(user);
    }
}
class CaelumM00FinishRonnieAction : CaelumPalomoDialogueAction
{
    override bool Use(bool pickup) { return CaelumMainM00RonnieTrial.Finish(CaelumPlayer(Owner)); }
}

class CaelumMainM00SupplyChest : CaelumStashChest
{
    override bool Used(Actor user)
    {
        if (user == null || Abs(user.Pos.Z - Pos.Z) > 64 || !user.CheckSight(self)) return false;
        if (UseLatched && LastChestUser == user) return true;
        UseLatched = true;
        LastChestUser = user;
        if (CaelumMainM00RonnieTrial.OpenChest(CaelumPlayer(user), self))
        {
            ChestOpen = true;
            RefreshChestVisual();
            A_StartSound("caelum/world/door_open", CHAN_BODY);
        }
        return true;
    }
    Default { Tag "$CA_M01_CHEST_NAME"; }
}

// Reutiliza dureza/extracción de vegetación aceptada. Es un billboard 2D,
// no tiene MODELDEF ni altera la extracción de los árboles existentes.
class CaelumFiberBush : CaelumTreeEnvironmentProp
{
    override int GetResourceMaterialType() { return CaelumConstants.MATERIAL_PLANT_FIBER; }
    Default
    {
        Tag "$CA_M01_FIBER_BUSH";
        // Arbusto mediano (~1.5 m), masa aérea estimada: no cilindro macizo.
        // 10 kg = 10000 unidades; dureza 2.5 heredada de la madera.
        Radius 20;
        Height 48;
        Mass 10;
        Scale 0.05;
    }
    States { Spawn: CFBH A -1; Stop; }
}

class CaelumM00RepairLessonAction : CaelumPalomoDialogueAction
{
    override bool Use(bool pickup)
    {
        return CaelumMainM00RonnieTrial.OfferRepairLesson(CaelumPlayer(Owner));
    }
}

class CaelumM00NeedsLessonAction : CaelumPalomoDialogueAction
{
    override bool Use(bool pickup)
    {
        return CaelumMainM00RonnieTrial.StartNeedsLesson(CaelumPlayer(Owner));
    }
}

class CaelumM00AirLessonAction : CaelumPalomoDialogueAction
{
    override bool Use(bool pickup)
    {
        return CaelumMainM00RonnieTrial.StartAirLesson(CaelumPlayer(Owner));
    }
}

class CaelumM00LoadLessonAction : CaelumPalomoDialogueAction
{
    override bool Use(bool pickup)
    {
        return CaelumMainM00RonnieTrial.StartLoadLesson(CaelumPlayer(Owner));
    }
}

class CaelumM00SwimLessonAction : CaelumPalomoDialogueAction
{
    override bool Use(bool pickup)
    {
        return CaelumMainM00RonnieTrial.StartSwimLesson(CaelumPlayer(Owner));
    }
}


class CaelumM00BorrowRepairSwordAction : CaelumPalomoDialogueAction
{
    override bool Use(bool pickup)
    {
        let user = CaelumPlayer(Owner);
        if (!CaelumMainM00RonnieTrial.IsRonnie(user)) return false;
        CaelumMainM00SupplyRules.PrepareRepairSupply(user);
        return CaelumMainM00RonnieTrial.PrepareLoan(user, true);
    }
}

class CaelumM00ReturnRepairSwordAction : CaelumPalomoDialogueAction
{
    override bool Use(bool pickup)
    {
        let user = CaelumPlayer(Owner);
        if (!CaelumMainM00RonnieTrial.IsRonnie(user)
            || !user.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_RONNIE_COMPLETE)) return false;
        CaelumMainM00RonnieTrial.ReturnLoan(user);
        return true;
    }
}
