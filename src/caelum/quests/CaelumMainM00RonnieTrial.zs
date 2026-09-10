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

    static bool PrepareLoan(CaelumPlayer user)
    {
        if (!CanInteract(user) || !IsStarted(user) || user.WeaponModel == null) return false;
        let record = user.GetPersistentCharacterState(true);
        if (record.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_RONNIE_COMPLETE)) return false;
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
        if (!requirements.Build(option, size)) return false;
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
        user.CraftingEfficiencyIndex = 0;
        user.ResetCraftingLayerChoices();
        Sync(user);
        return true;
    }

    static void EnsureSupplies(CaelumPlayer user)
    {
        if (!IsStarted(user)) return;
        let record = user.GetPersistentCharacterState(true);
        if (record.MainM00SuppliesInitialized) return;
        let requirements = new("CaelumMainM00StarterMaterials");
        // Máximo por material para UNA elección, no suma de 36 armas.
        for (int option = 0; option < CaelumMainM00StarterRules.OPTION_COUNT; option++)
        {
            requirements.Build(option, record.MainM00StarterSize);
            for (int slot = 0; slot < CaelumMainM00StarterRules.SUPPLY_COUNT; slot++)
                record.MainM00SupplyInitial[slot] = Max(record.MainM00SupplyInitial[slot],
                    requirements.Units[CaelumMainM00StarterRules.GetSupplyMaterial(slot)]);
        }
        for (int slot = 0; slot < CaelumMainM00StarterRules.SUPPLY_COUNT; slot++)
            record.MainM00SupplyRemaining[slot] = record.MainM00SupplyInitial[slot];
        record.MainM00SuppliesInitialized = true;
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
        let record = user.GetPersistentCharacterState(true);
        if (slot < 0)
        {
            for (int i = 0; i < CaelumMainM00StarterRules.SUPPLY_COUNT; i++)
            {
                let item = user.FindNativeSpecialItem(CaelumConstants.EQUIPMENT_KIND_MATERIAL,
                    CaelumMainM00StarterRules.GetSupplyMaterial(i), 1);
                if (item == null) continue;
                int returned = Min(item.Amount, item.LimboSupplyUnits);
                returned = Min(returned, Max(0, item.Amount - user.GetReservedCraftingMaterialUnits(
                    CaelumMainM00StarterRules.GetSupplyMaterial(i), 1)));
                returned = Min(returned, record.MainM00SupplyInitial[i] - record.MainM00SupplyRemaining[i]);
                if (returned <= 0) continue;
                record.MainM00SupplyRemaining[i] += returned;
                item.LimboSupplyUnits -= returned;
                item.LimboQuestUnits = Max(0, item.LimboQuestUnits - returned);
                item.Amount -= returned;
                if (item.Amount <= 0) item.Destroy();
            }
        }
        else
        {
            if (slot >= CaelumMainM00StarterRules.SUPPLY_COUNT) return false;
            user.RefreshCarriedInventorySummary();
            int capacity = Max(0, int(Floor((user.DerivedStats.CarryCapacity - user.DerivedStats.CarriedWeight)
                / CaelumConstants.MATERIAL_UNIT_WEIGHT)));
            int amount = Min(capacity, record.MainM00SupplyRemaining[slot]);
            int material = CaelumMainM00StarterRules.GetSupplyMaterial(slot);
            // Extrae sólo la falta de la receta elegida. El resto queda en el
            // cofre, visible, y no sobrecarga al jugador con gemas que no usa.
            amount = Min(amount, Max(0, record.MainM00StarterRequired[material]
                - user.CountRawCraftingMaterial(material, 1)));
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
            record.MainM00SupplyRemaining[slot] -= amount;
        }
        user.OnNativeInventoryChanged();
        Sync(user);
        return true;
    }

    static bool CanUsePersonalCraftingOutput(CaelumPlayer user)
    {
        return CanInteract(user) && IsStarted(user) && user.CraftingSelectionTier == 1
            && CaelumMainM00StarterRules.IsWeaponRecipe(user.CraftingSelectionRecipe);
    }

    static void RecordCraft(CaelumPlayer user, CaelumEquipmentItem result)
    {
        if (!CanUsePersonalCraftingOutput(user) || result == null) return;
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
            requirements.Build(record.MainM00StarterOption, record.MainM00StarterSize, 0, user);
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
        Radius 24;
        Height 54;
        Mass 100;
        Scale 0.07;
    }
    States { Spawn: CFBH A -1; Stop; }
}
