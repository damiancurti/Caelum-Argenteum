// Estado reconstruible de la vista. Nunca posee equipo ni reserva materiales.
class CaelumCraftingBrowser : Object play
{
    const CURRENT_REVISION = 1;
    enum Operation { CRAFT, REPAIR, DISMANTLE };
    int Revision, Mode, SelectedWeaponId, Serial, SelectedIndex;
    Array<int> Entries;
    Array<String> Labels;
    Array<int> MaterialTypes, MaterialTiers, MaterialUnits;
    Array<int> ReservedTypes, ReservedTiers, ReservedUnits;
    int BlockReason, MaximumDurability, Durability, Tier, Size, Essence;
    bool Boxed, Equipped, Refreshing;
    double Seconds, Weight;
    String Icon, Title;

    static CaelumCraftingBrowser Get(CaelumPlayer user)
    {
        if (user.CraftingBrowser == null) user.CraftingBrowser = new("CaelumCraftingBrowser");
        let result = user.CraftingBrowser;
        if (result.Revision < CURRENT_REVISION)
        {
            result.Mode = CRAFT; result.SelectedWeaponId = 0;
            result.Entries.Clear(); result.Serial++; result.Revision = CURRENT_REVISION;
        }
        return result;
    }

    static clearscope String RecipeName(int recipe, int tier = 1)
    {
        int kind = CaelumCraftingRules.GetUnifiedRecipeKind(recipe);
        if (kind == CaelumConstants.CRAFTING_RECIPE_KIND_AMMUNITION)
            return StringTable.Localize(recipe == CaelumConstants.CRAFTING_BOLT_RECIPE
                ? "CA_CRAFTING_TEN_BOLTS" : "CA_CRAFTING_TEN_ARROWS", false);
        if (kind == CaelumConstants.CRAFTING_RECIPE_KIND_ARMOR)
            return CaelumDisplayNames.FormatArmorTypeName(CaelumCraftingRules.GetUnifiedArmorType(recipe), tier)
                .. " · " .. StringTable.Localize(CaelumDisplayNames.GetArmorSlotKey(CaelumCraftingRules.GetUnifiedArmorSlot(recipe)), false);
        if (kind == CaelumConstants.CRAFTING_RECIPE_KIND_SHIELD)
            return CaelumDisplayNames.FormatShieldName(CaelumCraftingRules.GetUnifiedShieldType(recipe), tier);
        if (kind == CaelumConstants.CRAFTING_RECIPE_KIND_ESSENCE_WEAPON)
            return CaelumDisplayNames.FormatWeaponName(CaelumCraftingRules.GetUnifiedEssenceWeaponType(recipe), tier)
                .. " · " .. StringTable.Localize(CaelumNotifications.EssenceKey(CaelumCraftingRules.GetUnifiedEssenceType(recipe)), false);
        if (kind == CaelumConstants.CRAFTING_RECIPE_KIND_AMULET)
            return CaelumDisplayNames.FormatAmuletName(CaelumCraftingRules.GetUnifiedAmuletType(recipe), tier);
        if (kind == CaelumConstants.CRAFTING_RECIPE_KIND_SEAL)
            return CaelumDisplayNames.FormatSealName(CaelumCraftingRules.GetUnifiedSealType(recipe), tier);
        if (kind == CaelumConstants.CRAFTING_RECIPE_KIND_PROCESSING || kind == CaelumConstants.CRAFTING_RECIPE_KIND_COMPONENT)
            return StringTable.Localize(CaelumDisplayNames.GetSpecialItemKey(CaelumConstants.EQUIPMENT_KIND_MATERIAL,
                kind == CaelumConstants.CRAFTING_RECIPE_KIND_PROCESSING
                    ? CaelumCraftingRules.GetProcessingOutputMaterial(recipe) : CaelumCraftingRules.GetComponentOutputMaterial(recipe)), false);
        return CaelumDisplayNames.FormatCatalogueWeaponName(CaelumCraftingRules.GetStationRecipeWeapon(
            CaelumConstants.CRAFTING_STATION_WORKBENCH, recipe), tier);
    }

    static clearscope bool Accessible(CaelumPlayer user, CaelumEquipmentItem item)
    {
        return item != null && item.Owner == user && item.Amount > 0 && item.ItemId > 0
            && item.EquipmentKind == CaelumConstants.EQUIPMENT_KIND_WEAPON
            && (!item.InMagicBox || user.MagicBoxOwned);
    }

    void AddMaterial(int material, int tier, int units)
    {
        if (units <= 0) return;
        for (int i = 0; i < MaterialTypes.Size(); i++)
            if (MaterialTypes[i] == material && MaterialTiers[i] == tier)
            { MaterialUnits[i] += units; return; }
        MaterialTypes.Push(material); MaterialTiers.Push(tier); MaterialUnits.Push(units);
    }

    void Refresh(CaelumPlayer user)
    {
        if (Refreshing) return;
        Refreshing = true;
        Array<int> next;
        Labels.Clear();
        if (Mode == CRAFT)
        {
            for (int recipe = 0; recipe < CaelumConstants.CRAFTING_NETWORK_PLAYABLE_RECIPE_COUNT; recipe++)
                if (user.IsCraftingRecipeKnown(recipe) && CaelumCraftingRules.RecipeMatchesFilter(recipe, user.CraftingRecipeFilter))
                    next.Push(recipe);
        }
        else
        {
            user.SyncActiveModelsToNativeInventory();
            for (Inventory cursor = user.Inv; cursor != null; cursor = cursor.Inv)
            {
                let item = CaelumEquipmentItem(cursor);
                if (Accessible(user, item)) next.Push(item.ItemId);
            }
            // Orden estable por identidad, no por el orden de inserción en Inv.
            for (int i = 1; i < next.Size(); i++)
                for (int j = i; j > 0 && next[j] < next[j-1]; j--)
                { int swap = next[j]; next[j] = next[j-1]; next[j-1] = swap; }
        }
        bool changed = next.Size() != Entries.Size();
        if (!changed) for (int i = 0; i < next.Size(); i++) if (next[i] != Entries[i]) changed = true;
        int selected = Mode == CRAFT ? user.CraftingSelectionRecipe : SelectedWeaponId;
        SelectedIndex = -1;
        Entries.Clear();
        for (int i = 0; i < next.Size(); i++)
        {
            Entries.Push(next[i]);
            if (next[i] == selected) SelectedIndex = i;
            if (Mode == CRAFT) Labels.Push(RecipeName(next[i], next[i] == CaelumConstants.CRAFTING_PICKAXE_RECIPE ? 1 : user.CraftingSelectionTier));
            else
            {
                let item = user.FindNativeEquipmentItemById(next[i]);
                Labels.Push(CaelumDisplayNames.FormatWeaponName(item.ItemType, item.Tier) .. String.Format(" #%d", item.ItemId));
            }
        }
        if (SelectedIndex < 0 && Entries.Size() > 0) { SelectedIndex = 0; changed = true; }
        int selection = SelectedIndex < 0 ? -1 : Entries[SelectedIndex];
        if (Mode == CRAFT) user.CraftingSelectionRecipe = selection;
        else SelectedWeaponId = selection;
        if (changed) Serial++;
        MaterialTypes.Clear(); MaterialTiers.Clear(); MaterialUnits.Clear();
        ReservedTypes.Clear(); ReservedTiers.Clear(); ReservedUnits.Clear();
        BlockReason = CaelumConstants.EQUIPMENT_ACTION_NONE;
        Title = ""; Icon = ""; Seconds = 0;
        if (Mode == CRAFT) user.RefreshCraftingPreview();
        else if (selection >= 0) PreviewWeapon(user);
        Refreshing = false;
    }

    void PreviewWeapon(CaelumPlayer user)
    {
        let item = user.FindNativeEquipmentItemById(SelectedWeaponId);
        if (!Accessible(user, item)) return;
        Title = CaelumDisplayNames.FormatWeaponName(item.ItemType, item.Tier);
        Icon = CaelumIconResolver.ResolveTierPath(CaelumIconResolver.GetWeaponBasePath(item.ItemType), item.Tier);
        Durability = item.Durability; MaximumDurability = user.GetEquipmentTaskMaximumDurability(item);
        Tier = item.Tier; Size = item.EquipmentSize;
        Essence = item.ItemType == CaelumConstants.WEAPON_TYPE_STAFF || item.ItemType == CaelumConstants.WEAPON_TYPE_BELL
            || item.ItemType == CaelumConstants.WEAPON_TYPE_BOOK || item.ItemType == CaelumConstants.WEAPON_TYPE_STATUETTE ? item.EssenceType : -1;
        Boxed = item.InMagicBox; Equipped = item.Equipped; Weight = item.UnitWeight;
        BlockReason = user.GetEquipmentTaskBlockReason(item, Mode == DISMANTLE);
        if (BlockReason != CaelumConstants.EQUIPMENT_ACTION_NONE) return;
        if (Mode == REPAIR)
        {
            double fraction = Clamp((MaximumDurability-Durability)/double(Max(1,MaximumDurability)), 0.0, 1.0);
            user.BuildEquipmentTaskMaterials(item, fraction, false, self);
            user.ClearDirectCraftingPlan();
            user.CraftingMissingStationType = CaelumConstants.CRAFTING_STATION_NONE;
            bool ready = user.BuildEquipmentTaskMaterials(item, fraction, false);
            for (int i = 0; i < CaelumConstants.CRAFTING_TASK_MATERIAL_SLOT_COUNT; i++)
                if (ready && user.CraftingPlanReservedUnits[i] > 0)
                {
                    ReservedTypes.Push(user.CraftingPlanReservedType[i]); ReservedTiers.Push(user.CraftingPlanReservedTier[i]);
                    ReservedUnits.Push(user.CraftingPlanReservedUnits[i]);
                }
            Seconds = user.GetEquipmentTaskSeconds(item, user.CraftingPreparedEquipmentInputUnits, user.CraftingEfficiencyIndex);
            for (int i = 0; i < user.CraftingDirectPlanStepCount; i++) Seconds += user.CraftingPlanStepSeconds[i];
            if (!ready) BlockReason = user.CraftingMissingStationType != CaelumConstants.CRAFTING_STATION_NONE
                ? CaelumConstants.EQUIPMENT_ACTION_FAILED_INFRASTRUCTURE : CaelumConstants.EQUIPMENT_ACTION_FAILED_MATERIALS;
        }
        else
        {
            if (!user.BuildEquipmentTaskMaterials(item, Clamp(Durability/double(Max(1,MaximumDurability)), 0.0, 1.0), true, self))
                BlockReason = CaelumConstants.EQUIPMENT_ACTION_FAILED_DISMANTLE_UNSUPPORTED;
            Seconds = user.GetEquipmentTaskSeconds(item, CaelumCraftingRules.GetRoundedMaterialUnits(user.GetEquipmentTaskWeight(item),1.0),0);
            int slots = user.GetDismantleNetBoxSlots(item, self);
            if (slots < 0) BlockReason = CaelumConstants.EQUIPMENT_ACTION_FAILED_CARRY_CAPACITY;
            else if (user.MagicBoxUsedSlots + slots > user.MagicBoxMaximumSlots)
                BlockReason = CaelumConstants.EQUIPMENT_ACTION_FAILED_STORAGE;
        }
    }

    void SetMode(CaelumPlayer user, int operation)
    {
        operation = Clamp(operation, CRAFT, DISMANTLE);
        if (Mode != operation) { Mode = operation; Serial++; }
        user.LastCraftingAction = CaelumConstants.CRAFTING_ACTION_NONE;
        user.LastEquipmentAction = CaelumConstants.EQUIPMENT_ACTION_NONE;
        Refresh(user);
    }
    void Select(CaelumPlayer user, int index, int expectedSerial)
    {
        Refresh(user);
        if (expectedSerial != Serial || index < 0 || index >= Entries.Size()) return;
        if (Mode == CRAFT) user.CraftingSelectionRecipe = Entries[index];
        else SelectedWeaponId = Entries[index];
        Serial++; user.LastCraftingAction = 0; user.LastEquipmentAction = 0; Refresh(user);
    }
    void Move(CaelumPlayer user, int direction)
    {
        Refresh(user);
        if (Entries.Size() > 0) Select(user, (SelectedIndex + direction + Entries.Size()) % Entries.Size(), Serial);
    }
    void Confirm(CaelumPlayer user, int operation, int identity, int expectedSerial)
    {
        Refresh(user);
        if (Serial != expectedSerial || Mode != operation || SelectedIndex < 0 || Entries[SelectedIndex] != identity) return;
        Serial++;
        if (Mode == CRAFT) user.CraftSelectedPhysicalWeapon();
        else if (Accessible(user, user.FindNativeEquipmentItemById(identity)))
        {
            if (Mode == REPAIR) user.BeginRepairSelectedEquipment(identity);
            else user.BeginDismantleSelectedEquipment(identity);
        }
        Refresh(user);
    }
}
