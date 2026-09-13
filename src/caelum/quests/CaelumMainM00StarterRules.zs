// La selección de Ronnie apunta al catálogo vigente; no define recetas nuevas.
class CaelumMainM00StarterRules : Object
{
    const OPTION_COUNT = 36;
    const SUPPLY_COUNT = 6;

    static bool IsOption(int option) { return option >= 0 && option < OPTION_COUNT; }

    static int GetRecipe(int option)
    {
        if (!IsOption(option)) return -1;
        if (option < CaelumConstants.CRAFTING_NETWORK_PHYSICAL_RECIPE_COUNT) return option;
        return option + CaelumConstants.CRAFTING_NETWORK_ARMOR_RECIPE_COUNT;
    }

    static bool IsWeaponRecipe(int recipe)
    {
        for (int i = 0; i < OPTION_COUNT; i++) if (GetRecipe(i) == recipe) return true;
        return false;
    }

    static int GetWeaponType(int option)
    {
        if (option < 16)
            return CaelumCraftingRules.GetPlayableWeaponType(CaelumCraftingRules.GetStationRecipeWeapon(
                CaelumConstants.CRAFTING_STATION_WORKBENCH, option));
        return CaelumCraftingRules.GetUnifiedEssenceWeaponType(GetRecipe(option));
    }

    static ui String GetName(int option)
    {
        if (!IsOption(option)) return StringTable.Localize("CA_M01_STARTER_NONE", false);
        if (option < 16)
            return StringTable.Localize(CaelumWeaponCatalogue.GetNameKey(
                CaelumCraftingRules.GetStationRecipeWeapon(CaelumConstants.CRAFTING_STATION_WORKBENCH, option)), false);
        return StringTable.Localize(CaelumDisplayNames.GetWeaponKey(GetWeaponType(option)), false)
            .. " - " .. StringTable.Localize(GetElementKey(CaelumCraftingRules.GetUnifiedEssenceType(GetRecipe(option))), false);
    }

    static String GetElementKey(int element)
    {
        if (element == 1) return "CA_ESSENCE_WATER";
        if (element == 2) return "CA_ESSENCE_EARTH";
        if (element == 3) return "CA_ESSENCE_WIND";
        if (element == 4) return "CA_ESSENCE_QUINTESSENCE";
        return "CA_ESSENCE_FIRE";
    }

    static int GetSupplyMaterial(int index)
    {
        if (index >= 0 && index < 5) return CaelumConstants.MATERIAL_RAW_RUBY + index;
        return CaelumConstants.MATERIAL_LEATHER;
    }

    static bool IsSupplyMaterial(int material)
    {
        return material == CaelumConstants.MATERIAL_LEATHER
            || (material >= CaelumConstants.MATERIAL_RAW_RUBY && material <= CaelumConstants.MATERIAL_RAW_OPAL);
    }
}

// Descompone por las mismas funciones que el crafting. El cofre aporta cuero
// ya curtido: su expansión termina allí. Las gemas permanecen en bruto.
// Available sólo es una copia de consulta: nunca reserva ni consume inventario.
class CaelumMainM00StarterMaterials : Object play
{
    int Units[CaelumConstants.MATERIAL_TYPE_COUNT];
    int Available[CaelumConstants.MATERIAL_TYPE_COUNT];
    bool Recipes[CaelumConstants.CRAFTING_NETWORK_PLAYABLE_RECIPE_COUNT];
    int Efficiency;
    bool Valid;

    int ScaleUnits(int units)
    {
        return CaelumCraftingRules.GetEfficiencyAdjustedInputUnits(units, Efficiency);
    }

    int Proportion(int output, int numerator, int denominator)
    {
        return numerator <= 0 ? 0 : int(Ceil(double(output) * numerator / Max(1, denominator)));
    }

    void Expand(int material, int amount, int depth = 0)
    {
        if (amount <= 0) return;
        if (material < 0 || material >= CaelumConstants.MATERIAL_TYPE_COUNT || depth > 8)
        { Valid = false; return; }
        int held = Min(amount, Available[material]);
        Available[material] -= held;
        amount -= held;
        if (amount <= 0) return;
        int component = CaelumCraftingRules.FindComponentRecipeForOutput(material);
        if (component >= 0)
        {
            Recipes[component] = true;
            Expand(CaelumCraftingRules.GetComponentBaseMaterial(material, 1), ScaleUnits(amount), depth + 1);
            return;
        }
        int processing = CaelumCraftingRules.FindProcessingRecipeForOutput(material, 1);
        if (processing >= 0 && material != CaelumConstants.MATERIAL_LEATHER)
        {
            Recipes[processing] = true;
            int output = CaelumCraftingRules.GetProcessingOutputUnits(processing, 0);
            int adjusted = ScaleUnits(amount);
            Expand(CaelumCraftingRules.GetProcessingInputOneMaterial(processing),
                Proportion(adjusted, CaelumCraftingRules.GetProcessingInputOneUnits(processing, 0), output), depth + 1);
            int second = CaelumCraftingRules.GetProcessingInputTwoMaterial(processing);
            if (second >= 0)
                Expand(second, Proportion(adjusted, CaelumCraftingRules.GetProcessingInputTwoUnits(processing, 0), output), depth + 1);
            return;
        }
        Units[material] += amount;
    }

    bool Build(int option, int size, int requestedEfficiency = 0, CaelumPlayer user = null)
    {
        Valid = CaelumMainM00StarterRules.IsOption(option);
        Efficiency = Clamp(requestedEfficiency, 0, 2);
        for (int i = 0; i < CaelumConstants.MATERIAL_TYPE_COUNT; i++)
        {
            Units[i] = 0;
            Available[i] = user == null ? 0 : user.CountRawCraftingMaterial(i, 1);
        }
        for (int i = 0; i < CaelumConstants.CRAFTING_NETWORK_PLAYABLE_RECIPE_COUNT; i++) Recipes[i] = false;
        if (!Valid) return false;
        AddWeapon(option, size);
        return Valid;
    }

    void AddWeapon(int option, int size, double conditionFraction = 1.0)
    {
        int recipe = CaelumMainM00StarterRules.GetRecipe(option);
        Recipes[recipe] = true;
        if (option < 16)
        {
            int weapon = CaelumCraftingRules.GetStationRecipeWeapon(CaelumConstants.CRAFTING_STATION_WORKBENCH, option);
            double weight = CaelumCraftingRules.GetCraftedWeaponWeight(
                CaelumCraftingRules.GetPlayableTierOneWeight(weapon), 1, size);
            Expand(CaelumCraftingRules.GetBasicMaterial(weapon), ScaleUnits(
                CaelumCraftingRules.GetProportionalInputUnits(
                    CaelumCraftingRules.GetRequiredBasicMaterialUnits(weapon, weight), conditionFraction)));
            Expand(CaelumCraftingRules.GetTierMaterial(weapon), ScaleUnits(
                CaelumCraftingRules.GetProportionalInputUnits(
                    CaelumCraftingRules.GetRequiredTierMaterialUnits(weapon, weight), conditionFraction)));
        }
        else
        {
            int weaponType = CaelumMainM00StarterRules.GetWeaponType(option);
            double weight = CaelumCraftingRules.GetCraftedWeaponWeight(
                CaelumCraftingRules.GetEssenceTierOneWeight(weaponType), 1, size);
            Expand(CaelumCraftingRules.GetEssenceBaseMaterial(weaponType), ScaleUnits(
                CaelumCraftingRules.GetProportionalInputUnits(
                    CaelumCraftingRules.GetRequiredEssenceBaseUnits(weight), conditionFraction)));
            Expand(CaelumCraftingRules.GetEssenceMaterial(CaelumCraftingRules.GetUnifiedEssenceType(recipe)),
                ScaleUnits(CaelumCraftingRules.GetProportionalInputUnits(
                    CaelumCraftingRules.GetRequiredEssenceUnits(weight), conditionFraction)));
        }
    }

    void AddArmor(int armorType, int size, int onlySlot = -1)
    {
        let model = new("CaelumArmorModel");
        for (int slot = 0; slot < CaelumConstants.ARMOR_SLOT_COUNT; slot++)
        {
            if (onlySlot >= 0 && onlySlot != slot) continue;
            Recipes[CaelumConstants.CRAFTING_NETWORK_PHYSICAL_RECIPE_COUNT
                + armorType * CaelumConstants.ARMOR_SLOT_COUNT + slot] = true;
            double weight = model.GetWeightFor(slot, armorType, 1, size);
            Expand(CaelumConstants.MATERIAL_STRAP, ScaleUnits(
                CaelumCraftingRules.GetRequiredArmorBaseUnits(slot, weight)));
            Expand(CaelumCraftingRules.GetArmorTierMaterial(armorType), ScaleUnits(
                CaelumCraftingRules.GetRequiredArmorTierUnits(slot, weight)));
        }
    }

    void AddStarterAmmunition(int option)
    {
        if (option != 12 && option != 14 && option != 15) return;
        Recipes[option == 15 ? CaelumConstants.CRAFTING_BOLT_RECIPE
            : CaelumConstants.CRAFTING_ARROW_RECIPE] = true;
        // Ambos lotes aceptados incorporan 0,5 kg: diez unidades de 50 g.
        Expand(CaelumConstants.MATERIAL_SHAFT, ScaleUnits(350));
        Expand(CaelumConstants.MATERIAL_POINT, ScaleUnits(150));
    }

    bool IsSatisfied()
    {
        if (!Valid) return false;
        for (int i = 0; i < CaelumConstants.MATERIAL_TYPE_COUNT; i++) if (Units[i] > 0) return false;
        return true;
    }
}


// Cupo de práctica por personaje. Se descuenta al generar/retirar, no al
// consumir: fabricar, descartar, guardar o regenerar el árbol no lo repone.
class CaelumMainM00SupplyRules : Object play
{
    static bool IsLimited(CaelumPlayer user)
    {
        return user != null && level.MapName == "MAP01" && user.CharacterCreationComplete
            && user.GetPersistentCharacterState(false) != null;
    }

    static bool IsRawSupply(int material)
    {
        return material == CaelumConstants.MATERIAL_WOOD
            || material == CaelumConstants.MATERIAL_PLANT_FIBER
            || material == CaelumConstants.MATERIAL_LEATHER
            || material == CaelumConstants.MATERIAL_COAL
            || (material >= CaelumConstants.MATERIAL_RAW_COPPER && material <= CaelumConstants.MATERIAL_RAW_GOLD)
            || (material >= CaelumConstants.MATERIAL_RAW_RUBY && material <= CaelumConstants.MATERIAL_RAW_OPAL);
    }

    static void UpdateLimits(CaelumPlayer user)
    {
        let r = user.GetPersistentCharacterState(false);
        if (r == null || !r.MainM00StarterChosen) return;
        let needs = new("CaelumMainM00StarterMaterials");
        needs.Build(r.MainM00StarterOption, r.MainM00StarterSize, 2);
        for (int i = 0; i < CaelumConstants.MATERIAL_TYPE_COUNT; i++)
            r.MainM00StarterRequired[i] = needs.Units[i];
        needs.AddStarterAmmunition(r.MainM00StarterOption);
        if (r.MainM00ArmorChosen) needs.AddArmor(r.MainM00ArmorType, r.MainM00ArmorSize);
        for (int i = 0; i < CaelumConstants.MATERIAL_TYPE_COUNT; i++)
            r.MainM00SupplyLimit[i] = needs.Units[i] + r.MainM00RepairSupply[i];
        RefreshChest(user);
    }

    static void RefreshChest(CaelumPlayer user)
    {
        let r = user.GetPersistentCharacterState(false);
        if (r == null) return;
        for (int slot = 0; slot < 5; slot++)
        { r.MainM00SupplyInitial[slot] = 0; r.MainM00SupplyRemaining[slot] = 0; }
        int material = CaelumConstants.MATERIAL_LEATHER;
        r.MainM00SupplyInitial[5] = r.MainM00SupplyLimit[material];
        r.MainM00SupplyRemaining[5] = Max(0, r.MainM00SupplyLimit[material] - r.MainM00SupplyIssued[material]);
        r.MainM00SuppliesInitialized = true;
        r.MainM00LeatherSuppliesPrepared = true;
    }

    static void Ensure(CaelumPlayer user)
    {
        if (!IsLimited(user)) return;
        let r = user.GetPersistentCharacterState(false);
        if (!r.MainM00StarterChosen || r.MainM00SupplyQuotaReady) return;
        r.MainM00SupplyQuotaReady = true;
        UpdateLimits(user);
        // Migración: valorar existencias (incluidos componentes) al 100%.
        // Los materiales reservados siguen en Inventory y se cuentan una vez.
        let owned = new("CaelumMainM00StarterMaterials");
        owned.Efficiency = 2;
        for (Inventory cursor = user.Inv; cursor != null; cursor = cursor.Inv)
        {
            let item = CaelumSpecialInventoryItem(cursor);
            if (item != null && item.GetSpecialCategory() == CaelumConstants.EQUIPMENT_KIND_MATERIAL
                && item.GetSpecialTier() == 1) owned.Expand(item.GetSpecialType(), item.Amount);
        }
        if (r.MainM00StarterWeaponId > 0) owned.AddWeapon(r.MainM00StarterOption, r.MainM00StarterSize);
        int ammoType = r.MainM00StarterOption == 15 ? CaelumConstants.AMMUNITION_BOLT : CaelumConstants.AMMUNITION_ARROW;
        let ammunition = user.FindInventory(user.GetAmmunitionClassName(ammoType));
        if (ammunition != null && ammunition.Amount > 0) owned.AddStarterAmmunition(r.MainM00StarterOption);
        for (int i = 0; i < CaelumConstants.MATERIAL_TYPE_COUNT; i++)
            r.MainM00SupplyIssued[i] = owned.Units[i];
        RefreshChest(user);
        if (!user.CraftingTaskActive)
        { user.CraftingEfficiencyIndex = 2; user.ResetCraftingLayerChoices(); }
    }

    static int Remaining(CaelumPlayer user, int material)
    {
        if (!IsLimited(user)) return 2147483647;
        Ensure(user);
        let r = user.GetPersistentCharacterState(false);
        if (!r.MainM00StarterChosen || material < 0 || material >= CaelumConstants.MATERIAL_TYPE_COUNT) return 0;
        return Max(0, r.MainM00SupplyLimit[material] - r.MainM00SupplyIssued[material]);
    }

    static void Issue(CaelumPlayer user, int material, int amount)
    {
        if (!IsLimited(user) || amount <= 0) return;
        let r = user.GetPersistentCharacterState(false);
        r.MainM00SupplyIssued[material] += amount;
        RefreshChest(user);
    }

    static int CarryRoom(CaelumPlayer user)
    {
        if (user == null || user.DerivedStats == null) return 0;
        user.RefreshCarriedInventorySummary();
        // Un gramo de margen evita alcanzar LoadRatio == 1, que inmoviliza.
        return Max(0, int(Floor((user.DerivedStats.CarryCapacity - user.DerivedStats.CarriedWeight)
            / CaelumConstants.MATERIAL_UNIT_WEIGHT + 0.000001)) - 1);
    }

    static void PrepareRepairSupply(CaelumPlayer user)
    {
        let r = user.GetPersistentCharacterState(false);
        if (!IsLimited(user) || r == null || !r.MainM00RepairLessonOffered || r.MainM00RepairLessonComplete) return;
        let weapon = user.FindNativeEquipmentItemById(r.MainM00StarterWeaponId);
        if (weapon == null) return;
        int maximum = user.GetEquipmentTaskMaximumDurability(weapon);
        if (maximum <= 0 || weapon.Durability >= maximum) return;
        Ensure(user);
        let needs = new("CaelumMainM00StarterMaterials"); needs.Efficiency = 2;
        needs.AddWeapon(r.MainM00StarterOption, r.MainM00StarterSize,
            double(maximum - weapon.Durability) / maximum);
        for (int i = 0; i < CaelumConstants.MATERIAL_TYPE_COUNT; i++)
            r.MainM00RepairSupply[i] = Max(r.MainM00RepairSupply[i], needs.Units[i]);
        UpdateLimits(user);
    }

    static bool ReturnSurplus(CaelumPlayer user)
    {
        if (!CaelumMainM00RonnieTrial.CanInteract(user) || !(user.player.ConversationNPC is "CaelumMainM00SupplyChest")) return false;
        Ensure(user);
        let r = user.GetPersistentCharacterState(false);
        // Sólo devuelve excedentes sin reservar de partidas anteriores. El
        // cupo útil queda en el jugador; no se repone lo gastado ni la fuente.
        for (Inventory cursor = user.Inv; cursor != null;)
        {
            Inventory next = cursor.Inv;
            let item = CaelumSpecialInventoryItem(cursor);
            if (item != null && item.GetSpecialCategory() == CaelumConstants.EQUIPMENT_KIND_MATERIAL
                && item.GetSpecialTier() == 1 && IsRawSupply(item.GetSpecialType()))
            {
                int material = item.GetSpecialType();
                int surplus = Min(Max(0, item.Amount - user.GetReservedCraftingMaterialUnits(material, 1)),
                    Max(0, r.MainM00SupplyIssued[material] - r.MainM00SupplyLimit[material]));
                item.Amount -= surplus;
                item.LimboQuestUnits = Min(item.LimboQuestUnits, item.Amount);
                item.LimboSupplyUnits = Min(item.LimboSupplyUnits, item.LimboQuestUnits);
                r.MainM00SupplyIssued[material] -= surplus;
                if (item.Amount <= 0) item.Destroy();
            }
            cursor = next;
        }
        RefreshChest(user); user.OnNativeInventoryChanged(); CaelumMainM00RonnieTrial.Sync(user);
        return true;
    }

    static bool ChooseArmor(CaelumPlayer user, int armorType)
    {
        if (!CaelumMainM00RonnieTrial.IsRonnie(user) || armorType < 0 || armorType >= 4) return false;
        let r = user.GetPersistentCharacterState(false);
        if (r == null || !r.MainM00StarterChosen || r.MainM00ArmorChosen
            || r.QuestStage[0] >= CaelumConstants.MAIN_M00_STATE_EXIT_CONFIRMED) return false;
        Ensure(user);
        r.MainM00ArmorChosen = true;
        r.MainM00ArmorType = armorType;
        r.MainM00ArmorSize = r.MainM00StarterSize;
        let needs = new("CaelumMainM00StarterMaterials");
        needs.Efficiency = 2;
        needs.AddArmor(armorType, r.MainM00ArmorSize);
        for (int i = 0; i < CaelumConstants.CRAFTING_NETWORK_PLAYABLE_RECIPE_COUNT; i++)
            if (needs.Recipes[i]) r.LearnCraftingRecipe(i);
        UpdateLimits(user);
        if (!user.CraftingTaskActive)
        { user.CraftingEfficiencyIndex = 2; user.ResetCraftingLayerChoices(); }
        user.RefreshCraftingRecipeBookSummary();
        CaelumMainM00RonnieTrial.Sync(user);
        return true;
    }

    static bool IsChosenArmorRecipe(CaelumPlayer user)
    {
        let r = user.GetPersistentCharacterState(false);
        return r != null && r.MainM00ArmorChosen && user.CraftingSelectionTier == 1
            && CaelumCraftingRules.GetUnifiedRecipeKind(user.CraftingSelectionRecipe) == CaelumConstants.CRAFTING_RECIPE_KIND_ARMOR
            && CaelumCraftingRules.GetUnifiedArmorType(user.CraftingSelectionRecipe) == r.MainM00ArmorType;
    }

    static void RecordArmor(CaelumPlayer user, CaelumEquipmentItem item)
    {
        if (!IsLimited(user) || !IsChosenArmorRecipe(user) || item == null) return;
        let r = user.GetPersistentCharacterState(false);
        r.MainM00ArmorCrafted[item.ArmorSlot] = true;
        item.ItemFlags |= CaelumConstants.CA_ITEMFLAG_LIMBO_TEMP;
        user.RefreshSocialJournalSnapshot();
    }
}
