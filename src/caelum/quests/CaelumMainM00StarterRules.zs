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

    bool Build(int option, int size, int efficiency = 0, CaelumPlayer user = null)
    {
        Valid = CaelumMainM00StarterRules.IsOption(option);
        Efficiency = Clamp(efficiency, 0, 2);
        for (int i = 0; i < CaelumConstants.MATERIAL_TYPE_COUNT; i++)
        {
            Units[i] = 0;
            Available[i] = user == null ? 0 : user.CountRawCraftingMaterial(i, 1);
        }
        for (int i = 0; i < CaelumConstants.CRAFTING_NETWORK_PLAYABLE_RECIPE_COUNT; i++) Recipes[i] = false;
        if (!Valid) return false;
        int recipe = CaelumMainM00StarterRules.GetRecipe(option);
        Recipes[recipe] = true;
        if (option < 16)
        {
            int weapon = CaelumCraftingRules.GetStationRecipeWeapon(CaelumConstants.CRAFTING_STATION_WORKBENCH, option);
            double weight = CaelumCraftingRules.GetCraftedWeaponWeight(
                CaelumCraftingRules.GetPlayableTierOneWeight(weapon), 1, size);
            Expand(CaelumCraftingRules.GetBasicMaterial(weapon), ScaleUnits(
                CaelumCraftingRules.GetRequiredBasicMaterialUnits(weapon, weight)));
            Expand(CaelumCraftingRules.GetTierMaterial(weapon), ScaleUnits(
                CaelumCraftingRules.GetRequiredTierMaterialUnits(weapon, weight)));
        }
        else
        {
            int weaponType = CaelumMainM00StarterRules.GetWeaponType(option);
            double weight = CaelumCraftingRules.GetCraftedWeaponWeight(
                CaelumCraftingRules.GetEssenceTierOneWeight(weaponType), 1, size);
            Expand(CaelumCraftingRules.GetEssenceBaseMaterial(weaponType), ScaleUnits(
                CaelumCraftingRules.GetRequiredEssenceBaseUnits(weight)));
            Expand(CaelumCraftingRules.GetEssenceMaterial(CaelumCraftingRules.GetUnifiedEssenceType(recipe)),
                ScaleUnits(CaelumCraftingRules.GetRequiredEssenceUnits(weight)));
        }
        return Valid;
    }

    bool IsSatisfied()
    {
        if (!Valid) return false;
        for (int i = 0; i < CaelumConstants.MATERIAL_TYPE_COUNT; i++) if (Units[i] > 0) return false;
        return true;
    }
}
