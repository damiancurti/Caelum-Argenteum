// #376: políticas de planificación y sesión; el estado vive en el jugador.
// Las reservas y entregas usan exclusivamente CaelumInventoryService.
class CaelumCraftingCoordinator : Object play
{
    static double GetCraftingDexterityPercent(CaelumPlayer user)
    {
        if (user.RecipeQuoteActive || user.DerivedStats == null || user.Attributes == null) { return 100.0; }
        return Max(
            100.0,
            user.DerivedStats.CalculateType1Percent(user.Attributes.Dexterity)
        );
    }

    static double GetCraftingMaterialWorkSeconds(CaelumPlayer user, int employedMaterialUnits, int complexityTics, int efficiencyIndex)
    {
        return CaelumCraftingRules.GetMaterialWorkSeconds(
            employedMaterialUnits,
            complexityTics,
            user.GetCraftingDexterityPercent(),
            efficiencyIndex
        );
    }

    static int GetCurrentCraftingInputUnits(CaelumPlayer user)
    {
        return Max(0, user.CraftingBasicRequired)
            + Max(0, user.CraftingTierRequired)
            + Max(0, user.CraftingSilverRequired)
            + Max(0, user.CraftingGoldRequired);
    }

    static void ResetCraftingLayerChoices(CaelumPlayer user)
    {
        user.CraftingLayerChoiceCount = 0;
        user.CraftingBlueprintSelectedNode = 0;
        for (int slot = 0;
            slot < CaelumConstants.CRAFTING_LAYER_CHOICE_SLOT_COUNT; slot++)
        {
            user.CraftingLayerChoiceRecipe[slot] = -1;
            user.CraftingLayerChoiceTier[slot] = 1;
            user.CraftingLayerChoiceEfficiency[slot] = 0;
        }
    }

    static void EnsureCraftingLayerChoiceRoot(CaelumPlayer user)
    {
        if (user.CraftingLayerChoiceRootRecipe == user.CraftingSelectionRecipe
            && user.CraftingLayerChoiceRootTier == user.CraftingSelectionTier
            && user.CraftingLayerChoiceRootSize == user.CraftingSelectionSize)
        {
            return;
        }
        user.CraftingLayerChoiceRootRecipe = user.CraftingSelectionRecipe;
        user.CraftingLayerChoiceRootTier = user.CraftingSelectionTier;
        user.CraftingLayerChoiceRootSize = user.CraftingSelectionSize;
        user.ResetCraftingLayerChoices();
    }

    static int FindCraftingLayerChoice(CaelumPlayer user, int recipeIndex, int materialTier)
    {
        int resolvedTier = Clamp(materialTier, 1, 3);
        for (int slot = 0; slot < user.CraftingLayerChoiceCount; slot++)
        {
            if (user.CraftingLayerChoiceRecipe[slot] == recipeIndex
                && user.CraftingLayerChoiceTier[slot] == resolvedTier)
            {
                return slot;
            }
        }
        return -1;
    }

    static int GetOrCreateCraftingLayerChoice(CaelumPlayer user, int recipeIndex, int materialTier)
    {
        int existing = user.FindCraftingLayerChoice(recipeIndex, materialTier);
        if (existing >= 0) { return existing; }
        if (user.CraftingLayerChoiceCount
            >= CaelumConstants.CRAFTING_LAYER_CHOICE_SLOT_COUNT)
        {
            return -1;
        }
        int slot = user.CraftingLayerChoiceCount++;
        user.CraftingLayerChoiceRecipe[slot] = recipeIndex;
        user.CraftingLayerChoiceTier[slot] = Clamp(materialTier, 1, 3);
        user.CraftingLayerChoiceEfficiency[slot] = Clamp(
            user.CraftingEfficiencyIndex, 0,
            CaelumConstants.CRAFTING_EFFICIENCY_OPTION_COUNT - 1
        );
        return slot;
    }

    static int GetCraftingLayerEfficiencyIndex(CaelumPlayer user, int recipeIndex, int materialTier)
    {
        int choice = user.GetOrCreateCraftingLayerChoice(
            recipeIndex, materialTier
        );
        return choice >= 0
            ? user.CraftingLayerChoiceEfficiency[choice]
            : user.CraftingEfficiencyIndex;
    }

    static void SetCraftingLayerEfficiencyIndex(CaelumPlayer user, int recipeIndex, int materialTier, int efficiencyIndex)
    {
        int choice = user.GetOrCreateCraftingLayerChoice(
            recipeIndex, materialTier
        );
        if (choice < 0) { return; }
        user.CraftingLayerChoiceEfficiency[choice] = Clamp(
            efficiencyIndex, 0,
            CaelumConstants.CRAFTING_EFFICIENCY_OPTION_COUNT - 1
        );
    }

    static void ClearCraftingBlueprint(CaelumPlayer user)
    {
        user.CraftingBlueprintNodeCount = 0;
        user.CraftingBlueprintFullSeconds = 0.0;
        for (int slot = 0;
            slot < CaelumConstants.CRAFTING_BLUEPRINT_NODE_SLOT_COUNT; slot++)
        {
            user.CraftingBlueprintNodeKind[slot] =
                CaelumConstants.CRAFTING_BLUEPRINT_NODE_RAW;
            user.CraftingBlueprintNodeDepth[slot] = 0;
            user.CraftingBlueprintNodeRecipe[slot] = -1;
            user.CraftingBlueprintNodeMaterialType[slot] = -1;
            user.CraftingBlueprintNodeMaterialTier[slot] = 1;
            user.CraftingBlueprintNodeUnits[slot] = 0;
            user.CraftingBlueprintNodeOwnedUnits[slot] = 0;
            user.CraftingBlueprintNodeInputUnits[slot] = 0;
            user.CraftingBlueprintNodeEfficiency[slot] = -1;
            user.CraftingBlueprintNodeComplexityTics[slot] = 0;
            user.CraftingBlueprintNodeSeconds[slot] = 0.0;
            user.CraftingBlueprintNodeExecuted[slot] = false;
        }
    }

    static int FindCraftingBlueprintNode(CaelumPlayer user, int nodeKind, int recipeIndex, int materialType, int materialTier)
    {
        int resolvedTier = CaelumMaterialRules.ResolveTier(
            materialType, materialTier
        );
        for (int node = 1; node < user.CraftingBlueprintNodeCount; node++)
        {
            if (user.CraftingBlueprintNodeKind[node] != nodeKind) { continue; }
            if (nodeKind == CaelumConstants.CRAFTING_BLUEPRINT_NODE_RECIPE)
            {
                if (user.CraftingBlueprintNodeRecipe[node] == recipeIndex
                    && user.CraftingBlueprintNodeMaterialTier[node]
                        == resolvedTier)
                {
                    return node;
                }
            }
            else if (user.CraftingBlueprintNodeMaterialType[node] == materialType
                && user.CraftingBlueprintNodeMaterialTier[node] == resolvedTier)
            {
                return node;
            }
        }
        return -1;
    }

    static int AddOrAccumulateCraftingBlueprintNode(CaelumPlayer user, int nodeKind, int depth, int recipeIndex, int materialType, int materialTier, int units)
    {
        if (units <= 0) { return -1; }
        int resolvedTier = CaelumMaterialRules.ResolveTier(
            materialType, materialTier
        );
        int existing = user.FindCraftingBlueprintNode(
            nodeKind, recipeIndex, materialType, resolvedTier
        );
        if (existing >= 0)
        {
            user.CraftingBlueprintNodeUnits[existing] += units;
            user.CraftingBlueprintNodeDepth[existing] = Min(
                user.CraftingBlueprintNodeDepth[existing], depth
            );
            return existing;
        }
        if (user.CraftingBlueprintNodeCount
            >= CaelumConstants.CRAFTING_BLUEPRINT_NODE_SLOT_COUNT)
        {
            return -1;
        }
        int node = user.CraftingBlueprintNodeCount++;
        user.CraftingBlueprintNodeKind[node] = nodeKind;
        user.CraftingBlueprintNodeDepth[node] = Clamp(depth, 0, 8);
        user.CraftingBlueprintNodeRecipe[node] = recipeIndex;
        user.CraftingBlueprintNodeMaterialType[node] = materialType;
        user.CraftingBlueprintNodeMaterialTier[node] = resolvedTier;
        user.CraftingBlueprintNodeUnits[node] = units;
        if (nodeKind == CaelumConstants.CRAFTING_BLUEPRINT_NODE_RECIPE)
        {
            user.CraftingBlueprintNodeEfficiency[node] =
                user.GetCraftingLayerEfficiencyIndex(recipeIndex, resolvedTier);
            user.CraftingBlueprintNodeComplexityTics[node] =
                CaelumCraftingRules.GetRecipeComplexityTics(recipeIndex);
        }
        return node;
    }

    static void ExpandCraftingBlueprintMaterial(CaelumPlayer user, int materialType, int materialTier, int requiredUnits, int depth = 1)
    {
        // La merma modifica las cantidades transmitidas a cada subreceta. El
        // tiempo de una operacion usa solo la eficiencia elegida en ese nodo.
        if (requiredUnits <= 0 || depth > 8) { return; }
        int resolvedTier = CaelumMaterialRules.ResolveTier(
            materialType, materialTier
        );
        int recipeIndex =
            CaelumCraftingRules.FindComponentRecipeForOutput(materialType);
        bool componentRecipe = recipeIndex >= 0;
        if (!componentRecipe)
        {
            recipeIndex = CaelumCraftingRules.FindProcessingRecipeForOutput(
                materialType, resolvedTier
            );
        }
        if (recipeIndex < 0)
        {
            user.AddOrAccumulateCraftingBlueprintNode(
                CaelumConstants.CRAFTING_BLUEPRINT_NODE_RAW,
                depth, -1, materialType, resolvedTier, requiredUnits
            );
            return;
        }

        int node = user.AddOrAccumulateCraftingBlueprintNode(
            CaelumConstants.CRAFTING_BLUEPRINT_NODE_RECIPE,
            depth, recipeIndex, materialType, resolvedTier, requiredUnits
        );
        if (node < 0) { return; }
        int efficiencyIndex = user.GetCraftingLayerEfficiencyIndex(
            recipeIndex, resolvedTier
        );
        int efficiencyAdjustedOutput =
            CaelumCraftingRules.GetEfficiencyAdjustedInputUnits(
                requiredUnits, efficiencyIndex
            );
        if (componentRecipe)
        {
            user.CraftingBlueprintNodeInputUnits[node] +=
                efficiencyAdjustedOutput;
            user.CraftingBlueprintNodeSeconds[node] +=
                CaelumRecipeLearning.WorkSeconds(user, recipeIndex, resolvedTier,
                    efficiencyAdjustedOutput,
                    user.CraftingBlueprintNodeComplexityTics[node],
                    efficiencyIndex, requiredUnits
                );
            user.ExpandCraftingBlueprintMaterial(
                CaelumCraftingRules.GetComponentBaseMaterial(
                    materialType, resolvedTier
                ),
                CaelumCraftingRules.GetComponentBaseTier(
                    materialType, resolvedTier
                ),
                efficiencyAdjustedOutput,
                depth + 1
            );
            return;
        }

        int theoreticalOutput = Max(
            1,
            CaelumCraftingRules.GetProcessingOutputUnits(recipeIndex, 0)
        );
        int inputOneUnits = user.GetRoundedUpProportionalUnits(
            efficiencyAdjustedOutput,
            CaelumCraftingRules.GetProcessingInputOneUnits(recipeIndex, 0),
            theoreticalOutput
        );
        int inputTwoUnits = user.GetRoundedUpProportionalUnits(
            efficiencyAdjustedOutput,
            CaelumCraftingRules.GetProcessingInputTwoUnits(recipeIndex, 0),
            theoreticalOutput
        );
        user.CraftingBlueprintNodeInputUnits[node] +=
            inputOneUnits + inputTwoUnits;
        user.CraftingBlueprintNodeSeconds[node] +=
            CaelumRecipeLearning.WorkSeconds(user, recipeIndex, 1,
                inputOneUnits + inputTwoUnits,
                user.CraftingBlueprintNodeComplexityTics[node],
                efficiencyIndex, requiredUnits
            );
        user.ExpandCraftingBlueprintMaterial(
            CaelumCraftingRules.GetProcessingInputOneMaterial(recipeIndex),
            CaelumCraftingRules.GetProcessingInputOneTier(recipeIndex),
            inputOneUnits,
            depth + 1
        );
        int inputTwoMaterial =
            CaelumCraftingRules.GetProcessingInputTwoMaterial(recipeIndex);
        if (inputTwoMaterial >= 0 && inputTwoUnits > 0)
        {
            user.ExpandCraftingBlueprintMaterial(
                inputTwoMaterial,
                CaelumCraftingRules.GetProcessingInputTwoTier(recipeIndex),
                inputTwoUnits,
                depth + 1
            );
        }
    }

    static void BuildCraftingBlueprint(CaelumPlayer user)
    {
        user.EnsureCraftingLayerChoiceRoot();
        user.ClearCraftingBlueprint();
        int rootInputs = user.GetCurrentCraftingInputUnits();
        int rootComplexity = CaelumCraftingRules.GetRecipeComplexityTics(
            user.CraftingSelectionRecipe
        );

        user.CraftingBlueprintNodeCount = 1;
        user.CraftingBlueprintNodeKind[0] =
            CaelumConstants.CRAFTING_BLUEPRINT_NODE_FINAL;
        user.CraftingBlueprintNodeDepth[0] = 0;
        user.CraftingBlueprintNodeRecipe[0] = user.CraftingSelectionRecipe;
        user.CraftingBlueprintNodeMaterialType[0] = user.CraftingOutputMaterialType;
        user.CraftingBlueprintNodeMaterialTier[0] = user.CraftingOutputMaterialTier;
        user.CraftingBlueprintNodeUnits[0] = 1;
        user.CraftingBlueprintNodeInputUnits[0] = rootInputs;
        user.CraftingBlueprintNodeEfficiency[0] = user.CraftingEfficiencyIndex;
        user.CraftingBlueprintNodeComplexityTics[0] = rootComplexity;
        user.CraftingBlueprintNodeSeconds[0] = CaelumRecipeLearning.WorkSeconds(user, user.CraftingSelectionRecipe, user.CraftingSelectionTier,
            rootInputs, rootComplexity, user.CraftingEfficiencyIndex,
            user.CraftingOutputAmount, user.CraftingProcessingBatchIndex
        );
        user.CraftingBlueprintNodeExecuted[0] = true;

        user.ExpandCraftingBlueprintMaterial(
            user.CraftingBasicMaterialType,
            user.CraftingBasicMaterialTier,
            user.CraftingBasicRequired
        );
        user.ExpandCraftingBlueprintMaterial(
            user.CraftingTierMaterialType,
            user.CraftingTierMaterialTier,
            user.CraftingTierRequired
        );
        user.ExpandCraftingBlueprintMaterial(
            CaelumClothing.ThirdMaterial(user),
            CaelumClothing.ThirdTier(user),
            user.CraftingSilverRequired
        );
        user.ExpandCraftingBlueprintMaterial(
            CaelumConstants.MATERIAL_GOLD_INGOT,
            1,
            user.CraftingGoldRequired
        );

        user.CraftingBlueprintFullSeconds = user.CraftingBlueprintNodeSeconds[0];
        for (int node = 1; node < user.CraftingBlueprintNodeCount; node++)
        {
            user.CraftingBlueprintNodeOwnedUnits[node] = user.CountCraftingMaterial(
                user.CraftingBlueprintNodeMaterialType[node],
                user.CraftingBlueprintNodeMaterialTier[node]
            );
            if (user.CraftingBlueprintNodeKind[node]
                != CaelumConstants.CRAFTING_BLUEPRINT_NODE_RECIPE)
            {
                continue;
            }
            user.CraftingBlueprintFullSeconds +=
                user.CraftingBlueprintNodeSeconds[node];
        }
        user.CraftingBlueprintSelectedNode = Clamp(
            user.CraftingBlueprintSelectedNode,
            0, Max(0, user.CraftingBlueprintNodeCount - 1)
        );
        if (user.CraftingBlueprintNodeKind[user.CraftingBlueprintSelectedNode]
            == CaelumConstants.CRAFTING_BLUEPRINT_NODE_RAW)
        {
            user.CraftingBlueprintSelectedNode = 0;
        }
    }

    static void CycleCraftingBlueprintSelection(CaelumPlayer user, int direction)
    {
        user.RefreshCraftingPreview();
        if (user.CraftingBlueprintNodeCount <= 1) { return; }
        int step = direction < 0 ? -1 : 1;
        int candidate = user.CraftingBlueprintSelectedNode;
        for (int attempt = 0;
            attempt < user.CraftingBlueprintNodeCount; attempt++)
        {
            candidate = (candidate + step + user.CraftingBlueprintNodeCount)
                % user.CraftingBlueprintNodeCount;
            if (user.CraftingBlueprintNodeKind[candidate]
                != CaelumConstants.CRAFTING_BLUEPRINT_NODE_RAW)
            {
                user.CraftingBlueprintSelectedNode = candidate;
                return;
            }
        }
    }

    static void MarkCraftingBlueprintStepExecuted(CaelumPlayer user, int recipeIndex, int materialTier)
    {
        int resolvedTier = Clamp(materialTier, 1, 3);
        for (int node = 1; node < user.CraftingBlueprintNodeCount; node++)
        {
            if (user.CraftingBlueprintNodeKind[node]
                    == CaelumConstants.CRAFTING_BLUEPRINT_NODE_RECIPE
                && user.CraftingBlueprintNodeRecipe[node] == recipeIndex
                && user.CraftingBlueprintNodeMaterialTier[node] == resolvedTier)
            {
                user.CraftingBlueprintNodeExecuted[node] = true;
                return;
            }
        }
    }

    static bool ReserveCurrentCraftingPreview(CaelumPlayer user)
    {
        if (!user.AddCraftingTaskReservation(
                user.CraftingBasicMaterialType,
                user.CraftingBasicMaterialTier,
                user.CraftingBasicRequired
            )
            || !user.AddCraftingTaskReservation(
                user.CraftingTierMaterialType,
                user.CraftingTierMaterialTier,
                user.CraftingTierRequired
            )
            || !user.AddCraftingTaskReservation(
                CaelumClothing.ThirdMaterial(user),
                CaelumClothing.ThirdTier(user),
                user.CraftingSilverRequired
            )
            || !user.AddCraftingTaskReservation(
                CaelumConstants.MATERIAL_GOLD_INGOT,
                1,
                user.CraftingGoldRequired
            ))
        {
            return false;
        }
        return user.ValidateCraftingTaskReservations();
    }

    static void ClearDirectCraftingPlan(CaelumPlayer user)
    {
        user.CraftingDirectPlanAvailable = false;
        user.CraftingDirectPlanUsed = false;
        user.CraftingDirectPlanStepCount = 0;
        user.CraftingPreparedEquipmentInputUnits = 0;
        for (int slot = 0;
            slot < CaelumConstants.CRAFTING_TASK_MATERIAL_SLOT_COUNT; slot++)
        {
            user.CraftingPlanReservedType[slot] = -1;
            user.CraftingPlanReservedTier[slot] = 1;
            user.CraftingPlanReservedUnits[slot] = 0;
        }
        for (int step = 0;
            step < CaelumConstants.CRAFTING_DIRECT_STEP_SLOT_COUNT; step++)
        {
            user.CraftingPlanStepRecipe[step] = -1;
            user.CraftingPlanStepTier[step] = 1;
            user.CraftingPlanStepEfficiency[step] = 0;
            user.CraftingPlanStepInputUnits[step] = 0;
            user.CraftingPlanStepOutputUnits[step] = 0;
            user.CraftingPlanStepComplexityTics[step] = 0;
            user.CraftingPlanStepSeconds[step] = 0.0;
        }
    }

    static int GetDirectPlanReservedUnits(CaelumPlayer user, int materialType, int materialTier)
    {
        int resolvedTier = CaelumMaterialRules.ResolveTier(
            materialType, materialTier
        );
        int reserved = 0;
        for (int slot = 0;
            slot < CaelumConstants.CRAFTING_TASK_MATERIAL_SLOT_COUNT; slot++)
        {
            if (user.CraftingPlanReservedUnits[slot] > 0
                && user.CraftingPlanReservedType[slot] == materialType
                && user.CraftingPlanReservedTier[slot] == resolvedTier)
            {
                reserved += user.CraftingPlanReservedUnits[slot];
            }
        }
        return reserved;
    }

    static bool AddDirectPlanReservation(CaelumPlayer user, int materialType, int materialTier, int units)
    {
        if (units <= 0) { return true; }
        int resolvedTier = CaelumMaterialRules.ResolveTier(
            materialType, materialTier
        );
        for (int slot = 0;
            slot < CaelumConstants.CRAFTING_TASK_MATERIAL_SLOT_COUNT; slot++)
        {
            if (user.CraftingPlanReservedUnits[slot] > 0
                && user.CraftingPlanReservedType[slot] == materialType
                && user.CraftingPlanReservedTier[slot] == resolvedTier)
            {
                user.CraftingPlanReservedUnits[slot] += units;
                return true;
            }
        }
        for (int slot = 0;
            slot < CaelumConstants.CRAFTING_TASK_MATERIAL_SLOT_COUNT; slot++)
        {
            if (user.CraftingPlanReservedUnits[slot] <= 0)
            {
                user.CraftingPlanReservedType[slot] = materialType;
                user.CraftingPlanReservedTier[slot] = resolvedTier;
                user.CraftingPlanReservedUnits[slot] = units;
                return true;
            }
        }
        return false;
    }

    static int RegisterDirectCraftingStep(CaelumPlayer user, int recipeIndex, int materialTier)
    {
        int resolvedTier = Clamp(materialTier, 1, 3);
        for (int step = 0; step < user.CraftingDirectPlanStepCount; step++)
        {
            if (user.CraftingPlanStepRecipe[step] == recipeIndex
                && user.CraftingPlanStepTier[step] == resolvedTier)
            {
                return step;
            }
        }
        if (user.CraftingDirectPlanStepCount
            >= CaelumConstants.CRAFTING_DIRECT_STEP_SLOT_COUNT)
        {
            return -1;
        }
        int step = user.CraftingDirectPlanStepCount++;
        user.CraftingPlanStepRecipe[step] = recipeIndex;
        user.CraftingPlanStepTier[step] = resolvedTier;
        user.CraftingPlanStepEfficiency[step] =
            user.GetCraftingLayerEfficiencyIndex(recipeIndex, resolvedTier);
        user.CraftingPlanStepComplexityTics[step] =
            CaelumCraftingRules.GetRecipeComplexityTics(recipeIndex);
        return step;
    }

    static void AddDirectCraftingStepWork(CaelumPlayer user, int step, int employedMaterialUnits, int outputUnits=0)
    {
        if (step < 0 || step >= user.CraftingDirectPlanStepCount
            || employedMaterialUnits <= 0)
        {
            return;
        }
        user.CraftingPlanStepInputUnits[step] += employedMaterialUnits;
        user.CraftingPlanStepSeconds[step] += CaelumRecipeLearning.WorkSeconds(user, user.CraftingPlanStepRecipe[step], user.CraftingPlanStepTier[step],
                employedMaterialUnits,
                user.CraftingPlanStepComplexityTics[step],
                user.CraftingPlanStepEfficiency[step], outputUnits
            );
        user.MarkCraftingBlueprintStepExecuted(
            user.CraftingPlanStepRecipe[step], user.CraftingPlanStepTier[step]
        );
    }

    static int GetRoundedUpProportionalUnits(CaelumPlayer user, int requiredOutput, int numerator, int denominator)
    {
        if (requiredOutput <= 0 || numerator <= 0 || denominator <= 0)
        {
            return 0;
        }
        return int(Ceil(
            double(requiredOutput) * double(numerator) / double(denominator)
        ));
    }

    static bool DirectCraftingRecipeKnown(CaelumPlayer user, int recipeIndex, int tier = 1)
    {
        CaelumPersistentCharacterState persistentState =
            user.GetPersistentCharacterState(false);
        return persistentState != null
            && (user.RecipeQuoteActive || persistentState.KnowsCraftingRecipe(recipeIndex, tier));
    }

    static bool RequireDirectCraftingMaterial(CaelumPlayer user, int materialType, int materialTier, int requiredUnits, int depth = 0)
    {
        // La ruta real omite el trabajo de componentes ya existentes. Cada
        // operacion pendiente aplica solo su propia eficiencia temporal.
        if (requiredUnits <= 0) { return true; }
        if (depth > 8) { return false; }

        int resolvedTier = CaelumMaterialRules.ResolveTier(
            materialType, materialTier
        );
        int unreserved = Max(
            0,
            user.CountCraftingMaterial(materialType, resolvedTier)
                - user.GetDirectPlanReservedUnits(materialType, resolvedTier)
        );
        int availableUnits = Min(requiredUnits, unreserved);
        if (availableUnits > 0
            && !user.AddDirectPlanReservation(
                materialType, resolvedTier, availableUnits
            ))
        {
            return false;
        }

        int missingUnits = requiredUnits - availableUnits;
        if (missingUnits <= 0) { return true; }

        int componentRecipe =
            CaelumCraftingRules.FindComponentRecipeForOutput(materialType);
        if (componentRecipe >= 0)
        {
            if (!user.DirectCraftingRecipeKnown(componentRecipe, resolvedTier)) { return false; }
            int missingStation = CaelumCraftingRules.GetMissingComponentStation(
                user.CraftingNetworkCapabilities, resolvedTier, materialType
            );
            if (missingStation != CaelumConstants.CRAFTING_STATION_NONE)
            {
                user.CraftingMissingStationType = missingStation;
                user.CraftingSelectedInfrastructureAvailable = false;
                return false;
            }
            int planStep = user.RegisterDirectCraftingStep(
                componentRecipe, resolvedTier
            );
            if (planStep < 0) { return false; }
            int baseMaterial = CaelumCraftingRules.GetComponentBaseMaterial(
                materialType, resolvedTier
            );
            int baseTier = CaelumCraftingRules.GetComponentBaseTier(
                materialType, resolvedTier
            );
            int baseUnits =
                CaelumCraftingRules.GetEfficiencyAdjustedInputUnits(
                    missingUnits,
                    user.CraftingPlanStepEfficiency[planStep]
                );
            user.AddDirectCraftingStepWork(planStep, baseUnits, missingUnits);
            user.CraftingPlanStepOutputUnits[planStep] += missingUnits;
            return user.RequireDirectCraftingMaterial(
                baseMaterial,
                baseTier,
                baseUnits,
                depth + 1
            );
        }

        int processingRecipe =
            CaelumCraftingRules.FindProcessingRecipeForOutput(
                materialType, resolvedTier
            );
        if (processingRecipe < 0
            || !user.DirectCraftingRecipeKnown(processingRecipe, 1))
        {
            return false;
        }
        int missingStation = CaelumCraftingRules.GetMissingProcessingStation(
            user.CraftingNetworkCapabilities, processingRecipe
        );
        if (missingStation != CaelumConstants.CRAFTING_STATION_NONE)
        {
            user.CraftingMissingStationType = missingStation;
            user.CraftingSelectedInfrastructureAvailable = false;
            return false;
        }
        int planStep = user.RegisterDirectCraftingStep(
            processingRecipe, resolvedTier
        );
        if (planStep < 0) { return false; }

        int efficiencyAdjustedOutput =
            CaelumCraftingRules.GetEfficiencyAdjustedInputUnits(
                missingUnits,
                user.CraftingPlanStepEfficiency[planStep]
            );
        int theoreticalOutput = Max(
            1,
            CaelumCraftingRules.GetProcessingOutputUnits(
                processingRecipe, 0
            )
        );
        int inputOneUnits = user.GetRoundedUpProportionalUnits(
            efficiencyAdjustedOutput,
            CaelumCraftingRules.GetProcessingInputOneUnits(
                processingRecipe, 0
            ),
            theoreticalOutput
        );
        int inputTwoMaterial =
            CaelumCraftingRules.GetProcessingInputTwoMaterial(processingRecipe);
        int inputTwoUnits = user.GetRoundedUpProportionalUnits(
            efficiencyAdjustedOutput,
            CaelumCraftingRules.GetProcessingInputTwoUnits(
                processingRecipe, 0
            ),
            theoreticalOutput
        );
        user.AddDirectCraftingStepWork(
            planStep,
            inputOneUnits + inputTwoUnits, missingUnits
        );
        user.CraftingPlanStepOutputUnits[planStep] += missingUnits;
        if (!user.RequireDirectCraftingMaterial(
            CaelumCraftingRules.GetProcessingInputOneMaterial(processingRecipe),
            CaelumCraftingRules.GetProcessingInputOneTier(processingRecipe),
            inputOneUnits,
            depth + 1
        ))
        {
            return false;
        }
        if (inputTwoMaterial < 0) { return true; }
        return user.RequireDirectCraftingMaterial(
            inputTwoMaterial,
            CaelumCraftingRules.GetProcessingInputTwoTier(processingRecipe),
            inputTwoUnits,
            depth + 1
        );
    }

    static bool IsDirectWeaponCraftingRecipe(CaelumPlayer user)
    {
        return user.CraftingSelectedRecipeKind == CaelumConstants.CRAFTING_RECIPE_KIND_CLOTHING
            || user.CraftingSelectedRecipeKind == CaelumConstants.CRAFTING_RECIPE_KIND_UTILITY
            || user.CraftingSelectedRecipeKind == CaelumConstants.CRAFTING_RECIPE_KIND_AMULET
            || user.CraftingSelectedRecipeKind == CaelumConstants.CRAFTING_RECIPE_KIND_AMMUNITION
            || user.CraftingSelectedRecipeKind == CaelumConstants.CRAFTING_RECIPE_KIND_SEAL
            || user.CraftingSelectedRecipeKind == CaelumConstants.CRAFTING_RECIPE_KIND_ARMOR
            || user.CraftingSelectedRecipeKind == CaelumConstants.CRAFTING_RECIPE_KIND_SHIELD
            || user.CraftingSelectedRecipeKind
                == CaelumConstants.CRAFTING_RECIPE_KIND_PHYSICAL_WEAPON
            || user.CraftingSelectedRecipeKind
                == CaelumConstants.CRAFTING_RECIPE_KIND_ESSENCE_WEAPON;
    }

    static void RefreshDirectWeaponCraftingPlan(CaelumPlayer user)
    {
        user.ClearDirectCraftingPlan();
        if (!user.IsDirectWeaponCraftingRecipe()
            || !user.CraftingSelectedRecipeKnown
            || !user.CraftingSelectedInfrastructureAvailable)
        {
            return;
        }

        bool valid = user.RequireDirectCraftingMaterial(
                user.CraftingBasicMaterialType,
                user.CraftingBasicMaterialTier,
                user.CraftingBasicRequired
            )
            && user.RequireDirectCraftingMaterial(
                user.CraftingTierMaterialType,
                user.CraftingTierMaterialTier,
                user.CraftingTierRequired
            )
            && user.RequireDirectCraftingMaterial(
                CaelumClothing.ThirdMaterial(user),
                CaelumClothing.ThirdTier(user),
                user.CraftingSilverRequired
            )
            && user.RequireDirectCraftingMaterial(
                CaelumConstants.MATERIAL_GOLD_INGOT,
                1,
                user.CraftingGoldRequired
            );
        user.CraftingDirectPlanAvailable = valid;
        user.CraftingDirectPlanUsed = valid && user.CraftingDirectPlanStepCount > 0;
        if (valid)
        {
            for (int step = 0;
                step < user.CraftingDirectPlanStepCount; step++)
            {
                user.CraftingPreviewSeconds += user.CraftingPlanStepSeconds[step];
            }
        }
        else
        {
            for (int node = 1;
                node < user.CraftingBlueprintNodeCount; node++)
            {
                user.CraftingBlueprintNodeExecuted[node] = false;
            }
        }
    }

    static bool HasSelectedWeaponCraftingMaterials(CaelumPlayer user)
    {
        if (user.CraftingTaskCompleting && user.CraftingTaskUsesDirectPlan)
        {
            return user.ValidateCraftingTaskReservations();
        }
        return user.CraftingBasicOwned >= user.CraftingBasicRequired
            && user.CraftingTierOwned >= user.CraftingTierRequired
            && user.HasCraftingFinishMaterials();
    }

    static bool CanStartCraftingTask(CaelumPlayer user, bool recipeInfrastructure = true)
    {
        if (user.CraftingTaskActive)
        {
            user.LastCraftingAction =
                CaelumConstants.CRAFTING_ACTION_FAILED_TASK_ACTIVE;
            return false;
        }
        if (user.CombatTimeRemaining > 0.0)
        {
            user.LastCraftingAction = CaelumConstants.CRAFTING_ACTION_FAILED_COMBAT;
            return false;
        }
        if (user.player == null || user.player.playerstate != PST_LIVE || user.health <= 0)
        {
            user.LastCraftingAction = CaelumConstants.CRAFTING_ACTION_FAILED_TARGET;
            return false;
        }
        if (!user.RefreshActiveCraftingStationSession(recipeInfrastructure))
        {
            user.LastCraftingAction =
                CaelumConstants.CRAFTING_ACTION_FAILED_INFRASTRUCTURE;
            return false;
        }
        return true;
    }

    static void StartPreparedCraftingTask(CaelumPlayer user, int taskKind, double durationSeconds)
    {
        user.CraftingTaskUsesLimboMaterials = false;
        for (int slot = 0; slot < CaelumConstants.CRAFTING_TASK_MATERIAL_SLOT_COUNT; slot++)
        {
            if (user.CraftingTaskReservedUnits[slot] <= 0) continue;
            let input = user.FindNativeSpecialItem(CaelumConstants.EQUIPMENT_KIND_MATERIAL,
                user.CraftingTaskReservedType[slot], user.CraftingTaskReservedTier[slot]);
            if (input != null && input.LimboQuestUnits > 0) user.CraftingTaskUsesLimboMaterials = true;
        }
        user.CraftingTaskKind = taskKind;
        user.CraftingTaskRecipeIndex = user.CraftingSelectionRecipe;
        user.CraftingTaskTier = user.CraftingSelectionTier;
        user.CraftingTaskSize = user.CraftingSelectionSize;
        user.CraftingTaskBatchIndex = user.CraftingProcessingBatchIndex;
        user.CraftingTaskEfficiencyIndex = user.CraftingEfficiencyIndex;
        user.CraftingTaskNetworkCapabilities = user.CraftingNetworkCapabilities;
        user.CraftingTaskTotalSeconds = Max(0.001, durationSeconds);
        user.CraftingTaskRemainingSeconds = user.CraftingTaskTotalSeconds;
        user.CraftingTaskActive = true;
        CaelumRecipeLearning.CapturePractice(user);
        user.LastCraftingAction = CaelumConstants.CRAFTING_ACTION_TASK_STARTED;
        user.PersistCharacterState();
        user.RefreshFormalInventorySnapshot();
        user.RefreshCraftingPreview();
    }

    static void BeginSelectedCraftingTask(CaelumPlayer user)
    {
        user.RefreshCraftingPreview();
        if (!user.CanStartCraftingTask()) { return; }
        if (CaelumUtilityCrafting.IsRecipe(user.CraftingSelectionRecipe)
            && !CaelumLockRules.IsRecipe(user.CraftingSelectionRecipe)
            && user.FindInventory(CaelumUtilityCrafting.ItemClass(user.CraftingSelectionRecipe)) != null)
        { user.LastCraftingAction = CaelumConstants.CRAFTING_ACTION_FAILED_DUPLICATE; return; }
        if (!user.CraftingSelectedRecipeKnown)
        {
            user.LastCraftingAction =
                CaelumConstants.CRAFTING_ACTION_FAILED_RECIPE_LOCKED;
            return;
        }
        if (!user.CraftingSelectedInfrastructureAvailable)
        {
            user.LastCraftingAction =
                CaelumConstants.CRAFTING_ACTION_FAILED_INFRASTRUCTURE;
            return;
        }

        int taskKind = CaelumConstants.CRAFTING_TASK_ASSEMBLY;
        if (user.CraftingSelectedRecipeKind
            == CaelumConstants.CRAFTING_RECIPE_KIND_PROCESSING)
        {
            taskKind = CaelumConstants.CRAFTING_TASK_PROCESSING;
        }
        else if (user.CraftingSelectedRecipeKind
            == CaelumConstants.CRAFTING_RECIPE_KIND_COMPONENT)
        {
            taskKind = CaelumConstants.CRAFTING_TASK_COMPONENT;
        }

        user.RefreshCarriedInventorySummary();
        if (taskKind == CaelumConstants.CRAFTING_TASK_ASSEMBLY
            && user.CraftingSelectedRecipeKind != CaelumConstants.CRAFTING_RECIPE_KIND_UTILITY
            && user.CraftingSelectedRecipeKind != CaelumConstants.CRAFTING_RECIPE_KIND_AMMUNITION
            && !CaelumMainM00RonnieTrial.CanUsePersonalCraftingOutput(user)
            && user.MagicBoxUsedSlots + 1 > user.MagicBoxMaximumSlots)
        {
            user.LastCraftingAction =
                CaelumConstants.CRAFTING_ACTION_FAILED_BOX_FULL;
            return;
        }

        user.ClearCraftingTaskData();
        bool directWeaponTask = user.IsDirectWeaponCraftingRecipe()
            && user.CraftingDirectPlanAvailable;
        bool reserved = directWeaponTask
            ? user.ReservePreparedDirectCraftingPlan()
            : user.ReserveCurrentCraftingPreview();
        if (!reserved)
        {
            user.ClearCraftingTaskData();
            user.LastCraftingAction =
                CaelumConstants.CRAFTING_ACTION_FAILED_MATERIALS;
            return;
        }
        user.CraftingTaskUsesDirectPlan = directWeaponTask;
        if (taskKind == CaelumConstants.CRAFTING_TASK_PROCESSING
            || taskKind == CaelumConstants.CRAFTING_TASK_COMPONENT)
        {
            if (!user.AddCraftingTaskOutput(
                    user.CraftingOutputMaterialType,
                    user.CraftingOutputMaterialTier,
                    user.CraftingOutputAmount
                ))
            {
                user.ClearCraftingTaskData();
                user.LastCraftingAction =
                    CaelumConstants.CRAFTING_ACTION_FAILED_MATERIALS;
                return;
            }
            user.CraftingTaskReservedBoxSlots = user.GetPreparedMaterialOutputBoxSlots();
            if (user.CraftingTaskReservedBoxSlots < 0)
            {
                user.ClearCraftingTaskData();
                user.LastCraftingAction =
                    CaelumConstants.CRAFTING_ACTION_FAILED_CARRY_CAPACITY;
                return;
            }
        }
        else if (taskKind == CaelumConstants.CRAFTING_TASK_ASSEMBLY)
        {
            user.CraftingTaskReservedBoxSlots = (CaelumUtilityCrafting.IsRecipe(user.CraftingSelectionRecipe) || CaelumCraftingRules.GetRecipeAmmunitionType(user.CraftingSelectionRecipe) >= 0 || CaelumMainM00RonnieTrial.CanUsePersonalCraftingOutput(user)) ? 0 : 1;
            if (!user.CanCompletePreparedEquipmentOutput(user.CraftingFinalWeight))
            {
                user.ClearCraftingTaskData();
                user.LastCraftingAction =
                    CaelumConstants.CRAFTING_ACTION_FAILED_CARRY_CAPACITY;
                return;
            }
        }
        if (user.DerivedStats == null
            || user.CountNativeMagicBoxSlots() + user.CraftingTaskReservedBoxSlots
                > user.DerivedStats.MagicBoxCapacity)
        {
            user.ClearCraftingTaskData();
            user.LastCraftingAction =
                CaelumConstants.CRAFTING_ACTION_FAILED_BOX_FULL;
            return;
        }
        user.StartPreparedCraftingTask(taskKind, user.CraftingPreviewSeconds);
    }

    static void CancelCraftingTask(CaelumPlayer user)
    {
        if (!user.CraftingTaskActive) { return; }
        bool equipmentTask = user.CraftingTaskKind
                == CaelumConstants.CRAFTING_TASK_REPAIR
            || user.CraftingTaskKind
                == CaelumConstants.CRAFTING_TASK_DISMANTLE;
        user.ClearCraftingTaskData();
        user.LastCraftingAction = CaelumConstants.CRAFTING_ACTION_TASK_CANCELLED;
        if (equipmentTask)
        {
            user.LastEquipmentAction =
                CaelumConstants.EQUIPMENT_ACTION_FAILED_CRAFTING_TASK;
        }
        user.PersistCharacterState();
        user.RefreshFormalInventorySnapshot();
        if (user.CraftingMenuOpen) { user.RefreshCraftingPreview(); }
    }

    static void RefreshCraftingPreview(CaelumPlayer user)
    {
        // Los filtros recorren el catálogo global del Banco de Trabajo. Las
        // estaciones especializadas conservan sus índices locales y no deben
        // recibir selecciones pertenecientes a otra familia.
        if (user.ActiveCraftingStationType
            != CaelumConstants.CRAFTING_STATION_WORKBENCH
            && user.ActiveCraftingStationType != CaelumConstants.CRAFTING_STATION_NONE)
        {
            user.CraftingRecipeFilter =
                CaelumConstants.CRAFTING_RECIPE_FILTER_ALL;
        }
        user.CraftingRecipeFilter = CaelumCraftingRules.ResolveRecipeFilter(
            user.CraftingRecipeFilter
        );
        user.RefreshCraftingRecipeBookSummary();
        CaelumPersistentCharacterState persistentState =
            user.GetPersistentCharacterState(false);

        int stationRecipeCount = user.ActiveCraftingStationType == CaelumConstants.CRAFTING_STATION_NONE
            ? CaelumConstants.CRAFTING_NETWORK_PLAYABLE_RECIPE_COUNT
            : CaelumCraftingRules.GetStationRecipeCount(user.ActiveCraftingStationType);
        bool unifiedCatalogue = user.ActiveCraftingStationType == CaelumConstants.CRAFTING_STATION_WORKBENCH
            || user.ActiveCraftingStationType == CaelumConstants.CRAFTING_STATION_NONE;
        int firstKnown = unifiedCatalogue ? user.GetFirstKnownCraftingRecipe() : 0;
        if (firstKnown < 0) stationRecipeCount = 0;
        if (stationRecipeCount <= 0)
        {
            user.CraftingSelectionRecipe = -1;
            user.CraftingSelectedRecipeKnown = false;
            user.CraftingSelectedWeapon = -1;
            user.CraftingSelectedRecipeKind =
                CaelumConstants.CRAFTING_RECIPE_KIND_PHYSICAL_WEAPON;
            user.CraftingSelectedArmorType = CaelumConstants.ARMOR_TYPE_MAGIC;
            user.CraftingSelectedArmorSlot = CaelumConstants.ARMOR_SLOT_HEAD;
            user.CraftingSelectedShieldType = CaelumConstants.SHIELD_TYPE_BUCKLER;
            user.CraftingSelectedEssenceWeaponType = CaelumConstants.WEAPON_TYPE_STAFF;
            user.CraftingSelectedEssenceType = CaelumConstants.ESSENCE_FIRE;
            user.CraftingSelectedProcessingRecipe = -1;
            user.CraftingProcessingBatchMultiplier = 1;
            user.CraftingEfficiencyPercent =
                CaelumConstants.CRAFTING_EFFICIENCY_FAST_PERCENT;
            user.CraftingPreviewSeconds = 0.0;
            user.CraftingOutputMaterialType = 0;
            user.CraftingOutputMaterialTier = 1;
            user.CraftingOutputAmount = 0;
            user.CraftingPreviewIconPath = "";
            user.CraftingBasicMaterialType = 0;
            user.CraftingBasicMaterialTier = 1;
            user.CraftingBasicRequired = 0;
            user.CraftingBasicOwned = 0;
            user.CraftingTierMaterialType = 0;
            user.CraftingTierMaterialTier = 1;
            user.CraftingTierRequired = 0;
            user.CraftingTierOwned = 0;
            user.CraftingSilverRequired = 0;
            user.CraftingSilverOwned = 0;
            user.CraftingGoldRequired = 0;
            user.CraftingGoldOwned = 0;
            user.CraftingFinalWeight = 0.0;
            user.CraftingSelectedInfrastructureAvailable = false;
            user.CraftingMissingStationType =
                CaelumConstants.CRAFTING_STATION_NONE;
            user.ClearCraftingBlueprint();
            user.ClearDirectCraftingPlan();
            user.RefreshCarriedInventorySummary();
            return;
        }

        user.CraftingSelectionRecipe = Clamp(
            user.CraftingSelectionRecipe, 0, stationRecipeCount - 1
        );
        if ((unifiedCatalogue && !user.IsCraftingRecipeKnown(user.CraftingSelectionRecipe)) || !CaelumCraftingRules.RecipeMatchesFilter(
            user.CraftingSelectionRecipe, user.CraftingRecipeFilter
        ))
        {
            user.CraftingSelectionRecipe =
                unifiedCatalogue ? firstKnown : CaelumCraftingRules.GetFirstRecipeMatchingFilter(user.CraftingRecipeFilter);
        }
        user.CraftingSelectionTier = CaelumCraftingRules.IsSingleTierRecipe(user.CraftingSelectionRecipe)
            ? 1 : Clamp(user.CraftingSelectionTier, 1, 3);
        user.CraftingSelectedRecipeKnown = persistentState != null
            && (user.RecipeQuoteActive || persistentState.KnowsCraftingRecipe(user.CraftingSelectionRecipe, user.CraftingSelectionTier));
        user.CraftingSelectionSize = Clamp(
            user.CraftingSelectionSize,
            0,
            CaelumConstants.EQUIPMENT_SIZE_COUNT - 1
        );
        user.CraftingProcessingBatchIndex = Clamp(
            user.CraftingProcessingBatchIndex, 0,
            CaelumConstants.CRAFTING_PROCESSING_BATCH_OPTION_COUNT - 1
        );
        user.CraftingEfficiencyIndex = Clamp(
            user.CraftingEfficiencyIndex, 0,
            CaelumConstants.CRAFTING_EFFICIENCY_OPTION_COUNT - 1
        );
        user.CraftingEfficiencyPercent =
            CaelumCraftingRules.GetCraftingEfficiencyPercent(
                user.CraftingEfficiencyIndex
            );

        user.CraftingSelectedRecipeKind =
            CaelumCraftingRules.GetUnifiedRecipeKind(
                user.CraftingSelectionRecipe
            );
        user.CraftingSelectedWeapon = -1;
        user.CraftingSelectedProcessingRecipe = -1;
        user.CraftingProcessingBatchMultiplier =
            CaelumCraftingRules.GetProcessingBatchMultiplier(
                user.CraftingProcessingBatchIndex
            );
        user.CraftingOutputMaterialType = 0;
        user.CraftingOutputMaterialTier = 1;
        user.CraftingOutputAmount = 0;
        user.CraftingSilverRequired = 0;
        user.CraftingGoldRequired = 0;

        if (user.CraftingSelectedRecipeKind
            == CaelumConstants.CRAFTING_RECIPE_KIND_PHYSICAL_WEAPON)
        {
            int physicalIndex =
                CaelumCraftingRules.GetUnifiedPhysicalRecipeIndex(
                    user.CraftingSelectionRecipe
                );
            user.CraftingSelectedWeapon =
                CaelumCraftingRules.GetStationRecipeWeapon(
                    CaelumConstants.CRAFTING_STATION_WORKBENCH,
                    physicalIndex
                );

            user.CraftingBasicMaterialType =
                CaelumCraftingRules.GetBasicMaterial(
                    user.CraftingSelectedWeapon
                );
            user.CraftingTierMaterialType =
                CaelumCraftingRules.GetTierMaterial(
                    user.CraftingSelectedWeapon
                );
            user.CraftingFinalWeight =
                CaelumCraftingRules.GetCraftedWeaponWeight(
                    CaelumCraftingRules.GetPlayableTierOneWeight(
                        user.CraftingSelectedWeapon
                    ),
                    user.CraftingSelectionTier,
                    user.CraftingSelectionSize
                );
            user.CraftingBasicRequired =
                CaelumCraftingRules.GetRequiredBasicMaterialUnits(
                    user.CraftingSelectedWeapon, user.CraftingFinalWeight
                );
            user.CraftingTierRequired =
                CaelumCraftingRules.GetRequiredTierMaterialUnits(
                    user.CraftingSelectedWeapon, user.CraftingFinalWeight
                );
            user.CraftingMissingStationType =
                CaelumCraftingRules.GetMissingNetworkStation(
                    user.CraftingNetworkCapabilities,
                    user.CraftingSelectionTier,
                    user.CraftingSelectedWeapon
                );
        }
        else if (user.CraftingSelectedRecipeKind
            == CaelumConstants.CRAFTING_RECIPE_KIND_ARMOR)
        {
            user.CraftingSelectedArmorType =
                CaelumCraftingRules.GetUnifiedArmorType(
                    user.CraftingSelectionRecipe
                );
            user.CraftingSelectedArmorSlot =
                CaelumCraftingRules.GetUnifiedArmorSlot(
                    user.CraftingSelectionRecipe
                );

            user.CraftingBasicMaterialType = CaelumConstants.MATERIAL_STRAP;
            user.CraftingTierMaterialType =
                CaelumCraftingRules.GetArmorTierMaterial(
                    user.CraftingSelectedArmorType
                );
            user.CraftingFinalWeight = user.ArmorModel != null
                ? user.ArmorModel.GetWeightFor(
                    user.CraftingSelectedArmorSlot,
                    user.CraftingSelectedArmorType,
                    user.CraftingSelectionTier,
                    user.CraftingSelectionSize
                )
                : 0.0;
            user.CraftingBasicRequired =
                CaelumCraftingRules.GetRequiredArmorBaseUnits(
                    user.CraftingSelectedArmorSlot, user.CraftingFinalWeight
                );
            user.CraftingTierRequired =
                CaelumCraftingRules.GetRequiredArmorTierUnits(
                    user.CraftingSelectedArmorSlot, user.CraftingFinalWeight
                );
            user.CraftingMissingStationType =
                CaelumCraftingRules.GetMissingArmorStation(
                    user.CraftingNetworkCapabilities,
                    user.CraftingSelectionTier,
                    user.CraftingSelectedArmorType
                );
        }
        else if (user.CraftingSelectedRecipeKind
            == CaelumConstants.CRAFTING_RECIPE_KIND_SHIELD)
        {
            user.CraftingSelectedShieldType =
                CaelumCraftingRules.GetUnifiedShieldType(
                    user.CraftingSelectionRecipe
                );

            user.CraftingBasicMaterialType = CaelumConstants.MATERIAL_STRAP;
            user.CraftingTierMaterialType =
                CaelumCraftingRules.GetShieldPlateMaterial(
                    user.CraftingSelectedShieldType
                );
            user.CraftingFinalWeight = user.ShieldModel != null
                ? user.ShieldModel.GetWeightFor(
                    user.CraftingSelectedShieldType,
                    user.CraftingSelectionTier,
                    user.CraftingSelectionSize
                )
                : 0.0;
            user.CraftingBasicRequired =
                CaelumCraftingRules.GetRequiredShieldStrapUnits(
                    user.CraftingFinalWeight
                );
            user.CraftingTierRequired =
                CaelumCraftingRules.GetRequiredShieldPlateUnits(
                    user.CraftingFinalWeight
                );
            user.CraftingMissingStationType =
                CaelumCraftingRules.GetMissingShieldStation(
                    user.CraftingNetworkCapabilities,
                    user.CraftingSelectionTier
                );
        }
        else if (user.CraftingSelectedRecipeKind
            == CaelumConstants.CRAFTING_RECIPE_KIND_ESSENCE_WEAPON)
        {
            user.CraftingSelectedEssenceWeaponType =
                CaelumCraftingRules.GetUnifiedEssenceWeaponType(
                    user.CraftingSelectionRecipe
                );
            user.CraftingSelectedEssenceType =
                CaelumCraftingRules.GetUnifiedEssenceType(
                    user.CraftingSelectionRecipe
                );

            user.CraftingBasicMaterialType =
                CaelumCraftingRules.GetEssenceBaseMaterial(
                    user.CraftingSelectedEssenceWeaponType
                );
            user.CraftingTierMaterialType =
                CaelumCraftingRules.GetEssenceMaterial(
                    user.CraftingSelectedEssenceType
                );
            user.CraftingFinalWeight =
                CaelumCraftingRules.GetCraftedWeaponWeight(
                    CaelumCraftingRules.GetEssenceTierOneWeight(
                        user.CraftingSelectedEssenceWeaponType
                    ),
                    user.CraftingSelectionTier,
                    user.CraftingSelectionSize
                );
            user.CraftingBasicRequired =
                CaelumCraftingRules.GetRequiredEssenceBaseUnits(
                    user.CraftingFinalWeight
                );
            user.CraftingTierRequired =
                CaelumCraftingRules.GetRequiredEssenceUnits(
                    user.CraftingFinalWeight
                );
            user.CraftingMissingStationType =
                CaelumCraftingRules.GetMissingEssenceStation(
                    user.CraftingNetworkCapabilities,
                    user.CraftingSelectionTier
                );
        }

        else if (user.CraftingSelectedRecipeKind
            == CaelumConstants.CRAFTING_RECIPE_KIND_PROCESSING)
        {
            user.CraftingSelectedProcessingRecipe =
                CaelumCraftingRules.GetUnifiedProcessingRecipeIndex(
                    user.CraftingSelectionRecipe
                );
            user.CraftingBasicMaterialType =
                CaelumCraftingRules.GetProcessingInputOneMaterial(
                    user.CraftingSelectionRecipe
                );
            user.CraftingBasicMaterialTier =
                CaelumCraftingRules.GetProcessingInputOneTier(
                    user.CraftingSelectionRecipe
                );
            user.CraftingBasicRequired =
                CaelumCraftingRules.GetProcessingInputOneUnits(
                    user.CraftingSelectionRecipe,
                    user.CraftingProcessingBatchIndex
                );
            user.CraftingTierMaterialType =
                CaelumCraftingRules.GetProcessingInputTwoMaterial(
                    user.CraftingSelectionRecipe
                );
            user.CraftingTierMaterialTier =
                CaelumCraftingRules.GetProcessingInputTwoTier(
                    user.CraftingSelectionRecipe
                );
            user.CraftingTierRequired =
                CaelumCraftingRules.GetProcessingInputTwoUnits(
                    user.CraftingSelectionRecipe,
                    user.CraftingProcessingBatchIndex
                );
            user.CraftingOutputMaterialType =
                CaelumCraftingRules.GetProcessingOutputMaterial(
                    user.CraftingSelectionRecipe
                );
            user.CraftingOutputMaterialTier =
                CaelumCraftingRules.GetProcessingOutputTier(
                    user.CraftingSelectionRecipe
                );
            user.CraftingOutputAmount =
                CaelumCraftingRules.GetProcessingOutputUnitsAtEfficiency(
                    user.CraftingSelectionRecipe,
                    user.CraftingProcessingBatchIndex,
                    user.CraftingEfficiencyIndex
                );
            user.CraftingFinalWeight = user.CraftingOutputAmount
                * CaelumConstants.MATERIAL_UNIT_WEIGHT;
            user.CraftingMissingStationType =
                CaelumCraftingRules.GetMissingProcessingStation(
                    user.CraftingNetworkCapabilities,
                    user.CraftingSelectionRecipe
                );
        }
        else if (user.CraftingSelectedRecipeKind
            == CaelumConstants.CRAFTING_RECIPE_KIND_COMPONENT)
        {
            user.CraftingOutputMaterialType =
                CaelumCraftingRules.GetComponentOutputMaterial(
                    user.CraftingSelectionRecipe
                );
            user.CraftingOutputMaterialTier =
                CaelumCraftingRules.GetComponentOutputTier(
                    user.CraftingOutputMaterialType,
                    user.CraftingSelectionTier
                );
            user.CraftingOutputAmount =
                CaelumCraftingRules.GetComponentOutputUnits(
                    user.CraftingProcessingBatchIndex,
                    user.CraftingEfficiencyIndex
                );
            user.CraftingBasicMaterialType =
                CaelumCraftingRules.GetComponentBaseMaterial(
                    user.CraftingOutputMaterialType,
                    user.CraftingOutputMaterialTier
                );
            user.CraftingBasicMaterialTier =
                CaelumCraftingRules.GetComponentBaseTier(
                    user.CraftingOutputMaterialType,
                    user.CraftingOutputMaterialTier
                );
            user.CraftingBasicRequired =
                CaelumCraftingRules.GetComponentInputUnits(
                    user.CraftingProcessingBatchIndex
                );
            user.CraftingTierMaterialType = 0;
            user.CraftingTierMaterialTier = 1;
            user.CraftingTierRequired = 0;
            user.CraftingFinalWeight = user.CraftingOutputAmount
                * CaelumConstants.MATERIAL_UNIT_WEIGHT;
            user.CraftingMissingStationType =
                CaelumCraftingRules.GetMissingComponentStation(
                    user.CraftingNetworkCapabilities,
                    user.CraftingOutputMaterialTier,
                    user.CraftingOutputMaterialType
                );
        }
        else if (CaelumClothingData.IsRecipe(user.CraftingSelectionRecipe))
        {
            CaelumClothing.Preview(user);
        }
        else if (CaelumLockRules.IsRecipe(user.CraftingSelectionRecipe))
        {
            user.CraftingSelectionTier=CaelumLockRules.RecipeTier(user.CraftingSelectionRecipe);
            user.CraftingFinalWeight=CaelumLockRules.RecipeWeight(user.CraftingSelectionRecipe);
            user.CraftingBasicMaterialType=CaelumConstants.MATERIAL_STEEL_INGOT;
            user.CraftingTierMaterialType=CaelumConstants.MATERIAL_STEEL_INGOT;
            user.CraftingBasicRequired=CaelumCraftingRules.GetRoundedMaterialUnits(user.CraftingFinalWeight,1.0);
            user.CraftingTierRequired=0;
            user.CraftingMissingStationType=CaelumLockRules.MissingStation(user.CraftingSelectionRecipe,user.CraftingNetworkCapabilities);
        }
        else if (user.CraftingSelectedRecipeKind == CaelumConstants.CRAFTING_RECIPE_KIND_UTILITY)
        {
            user.CraftingSelectionTier = 1;
            user.CraftingFinalWeight = CaelumUtilityCrafting.Weight(user.CraftingSelectionRecipe);
            user.CraftingBasicMaterialType = CaelumConstants.MATERIAL_LEATHER;
            user.CraftingTierMaterialType = CaelumConstants.MATERIAL_ROPE;
            user.CraftingBasicRequired = CaelumCraftingRules.GetRoundedMaterialUnits(user.CraftingFinalWeight, CaelumOnboardingCatalogue.LEATHER_SHARE);
            user.CraftingTierRequired = CaelumCraftingRules.GetRoundedMaterialUnits(user.CraftingFinalWeight, CaelumOnboardingCatalogue.ROPE_SHARE);
            user.CraftingMissingStationType = CaelumCraftingRules.NetworkHasStation(user.CraftingNetworkCapabilities,
                CaelumConstants.CRAFTING_STATION_WORKBENCH) ? CaelumConstants.CRAFTING_STATION_NONE : CaelumConstants.CRAFTING_STATION_WORKBENCH;
        }
        else if (user.CraftingSelectedRecipeKind == CaelumConstants.CRAFTING_RECIPE_KIND_AMMUNITION)
        {
            // Flechas y virotes conservan sus masas nativas y comparten la
            // base T1: 70 % asta y 30 % punta. Merma por capa en el bloque común.
            user.CraftingSelectionTier = 1;
            user.CraftingFinalWeight = user.GetAmmunitionUnitWeight(
                CaelumCraftingRules.GetRecipeAmmunitionType(user.CraftingSelectionRecipe))
                * CaelumCraftingRules.GetRecipeAmmunitionBatch(user.CraftingSelectionRecipe);
            user.CraftingBasicMaterialType = CaelumConstants.MATERIAL_SHAFT;
            user.CraftingTierMaterialType = CaelumConstants.MATERIAL_POINT;
            user.CraftingBasicRequired = CaelumCraftingRules.GetRoundedMaterialUnits(user.CraftingFinalWeight, CaelumConstants.AMMUNITION_SHAFT_SHARE);
            user.CraftingTierRequired = CaelumCraftingRules.GetRoundedMaterialUnits(user.CraftingFinalWeight, CaelumConstants.AMMUNITION_POINT_SHARE);
            user.CraftingMissingStationType = CaelumCraftingRules.GetMissingNetworkStation(
                user.CraftingNetworkCapabilities, 1, CaelumConstants.CATALOGUE_WEAPON_LONGBOW);
        }
        else if (user.CraftingSelectedRecipeKind == CaelumConstants.CRAFTING_RECIPE_KIND_AMULET)
        {
            user.CraftingSelectedAmuletType = CaelumCraftingRules.GetUnifiedAmuletType(user.CraftingSelectionRecipe);
            user.CraftingBasicMaterialType = CaelumConstants.MATERIAL_SILVER_CHAIN;
            user.CraftingTierMaterialType = CaelumCraftingRules.GetAmuletTierMaterial(user.CraftingSelectedAmuletType);
            user.CraftingFinalWeight = CaelumCraftingRules.GetJewelryWeight(user.CraftingSelectionTier);
            user.CraftingBasicRequired = CaelumCraftingRules.GetRequiredAmuletBaseUnits(user.CraftingFinalWeight);
            user.CraftingTierRequired = CaelumCraftingRules.GetRequiredAmuletTierUnits(user.CraftingFinalWeight);
            user.CraftingMissingStationType = CaelumCraftingRules.GetMissingJewelryStation(user.CraftingNetworkCapabilities, user.CraftingSelectionTier);
        }
        else if (user.CraftingSelectedRecipeKind
            == CaelumConstants.CRAFTING_RECIPE_KIND_SEAL)
        {
            user.CraftingSelectedSealType = CaelumCraftingRules.GetUnifiedSealType(user.CraftingSelectionRecipe);
            user.CraftingBasicMaterialType = CaelumConstants.MATERIAL_SEAL_BASE;
            user.CraftingTierMaterialType = CaelumCraftingRules.GetSealTierMaterial(user.CraftingSelectedSealType);
            user.CraftingFinalWeight = CaelumCraftingRules.GetJewelryWeight(user.CraftingSelectionTier);
            user.CraftingBasicRequired = CaelumCraftingRules.GetRequiredSealBaseUnits(user.CraftingFinalWeight);
            user.CraftingTierRequired = CaelumCraftingRules.GetRequiredSealTierUnits(user.CraftingFinalWeight);
            user.CraftingMissingStationType = CaelumCraftingRules.GetMissingJewelryStation(user.CraftingNetworkCapabilities, user.CraftingSelectionTier);
        }

        if (user.CraftingSelectedRecipeKind
                != CaelumConstants.CRAFTING_RECIPE_KIND_PROCESSING
            && user.CraftingSelectedRecipeKind
                != CaelumConstants.CRAFTING_RECIPE_KIND_COMPONENT)
        {
            // El material base siempre es estructural y permanece en tier 1.
            user.CraftingBasicMaterialTier = CaelumMaterialRules.ResolveTier(
                user.CraftingBasicMaterialType, 1
            );
            user.CraftingTierMaterialTier = CaelumMaterialRules.ResolveTier(
                user.CraftingTierMaterialType, user.CraftingSelectionTier
            );
            user.CraftingSilverRequired =
                CaelumCraftingRules.GetRequiredSilverDetailUnits(
                    user.CraftingFinalWeight, user.CraftingSelectionTier
                );
            user.CraftingGoldRequired =
                CaelumCraftingRules.GetRequiredGoldDetailUnits(
                    user.CraftingFinalWeight, user.CraftingSelectionTier
                );
            if(CaelumLockRules.IsRecipe(user.CraftingSelectionRecipe))
            {user.CraftingSilverRequired=0;user.CraftingGoldRequired=0;}
            if (user.CraftingSelectedRecipeKind
                == CaelumConstants.CRAFTING_RECIPE_KIND_SEAL)
            {
                user.CraftingBasicMaterialTier = CaelumMaterialRules.ResolveTier(
                    user.CraftingBasicMaterialType, user.CraftingSelectionTier
                );
            }

            if(CaelumClothingData.IsRecipe(user.CraftingSelectionRecipe))CaelumClothing.Preview(user);

            // El montaje y la reparación producen un objeto indivisible. Una
            // eficiencia menor conserva el resultado completo y aumenta cada
            // entrada por separado para representar la merma elegida.
            user.CraftingBasicRequired =
                CaelumCraftingRules.GetEfficiencyAdjustedInputUnits(
                    user.CraftingBasicRequired, user.CraftingEfficiencyIndex
                );
            user.CraftingTierRequired =
                CaelumCraftingRules.GetEfficiencyAdjustedInputUnits(
                    user.CraftingTierRequired, user.CraftingEfficiencyIndex
                );
            user.CraftingSilverRequired =
                CaelumCraftingRules.GetEfficiencyAdjustedInputUnits(
                    user.CraftingSilverRequired, user.CraftingEfficiencyIndex
                );
            user.CraftingGoldRequired =
                CaelumCraftingRules.GetEfficiencyAdjustedInputUnits(
                    user.CraftingGoldRequired, user.CraftingEfficiencyIndex
                );
        }

        user.CraftingBasicOwned = user.CountCraftingMaterial(
            user.CraftingBasicMaterialType, user.CraftingBasicMaterialTier
        );
        user.CraftingTierOwned = user.CraftingTierRequired > 0
            ? user.CountCraftingMaterial(
                user.CraftingTierMaterialType, user.CraftingTierMaterialTier
            ) : 0;
        user.CraftingSilverOwned = user.CraftingSilverRequired > 0
            ? user.CountCraftingMaterial(
                CaelumClothing.ThirdMaterial(user), CaelumClothing.ThirdTier(user)
            ) : 0;
        user.CraftingGoldOwned = user.CraftingGoldRequired > 0
            ? user.CountCraftingMaterial(
                CaelumConstants.MATERIAL_GOLD_INGOT, 1
            ) : 0;

        user.CraftingSelectedInfrastructureAvailable =
            user.CraftingMissingStationType
                == CaelumConstants.CRAFTING_STATION_NONE;

        user.CraftingPreviewSeconds = CaelumRecipeLearning.WorkSeconds(user, user.CraftingSelectionRecipe, user.CraftingSelectionTier,
            user.GetCurrentCraftingInputUnits(),
            CaelumCraftingRules.GetRecipeComplexityTics(
                user.CraftingSelectionRecipe
            ),
            user.CraftingEfficiencyIndex, user.CraftingOutputAmount,
            user.CraftingProcessingBatchIndex
        );

        // El árbol completo permanece visible aunque ya existan componentes;
        // la ruta real añade tiempo sólo por pasos que deban ejecutarse.
        user.BuildCraftingBlueprint();
        user.RefreshDirectWeaponCraftingPlan();
        user.CraftingPreviewIconPath = user.ResolveCraftingPreviewIconPath();
        if (user.CraftingSelectedRecipeKind
                == CaelumConstants.CRAFTING_RECIPE_KIND_PHYSICAL_WEAPON
            || user.CraftingSelectedRecipeKind
                == CaelumConstants.CRAFTING_RECIPE_KIND_ESSENCE_WEAPON
            || user.CraftingSelectedRecipeKind
                == CaelumConstants.CRAFTING_RECIPE_KIND_SHIELD
            || user.CraftingSelectedRecipeKind
                == CaelumConstants.CRAFTING_RECIPE_KIND_ARMOR
            || user.CraftingSelectedRecipeKind
                == CaelumConstants.CRAFTING_RECIPE_KIND_AMULET
            || user.CraftingSelectedRecipeKind
                == CaelumConstants.CRAFTING_RECIPE_KIND_SEAL)
        {
            user.CraftingPreviewIconPath = CaelumIconResolver.ResolveTierPath(
                user.CraftingPreviewIconPath, user.CraftingSelectionTier
            );
        }

        user.RefreshCarriedInventorySummary();
    }

    static int BeginCraftingNetworkScan(CaelumPlayer user)
    {
        user.CraftingNetworkCapabilities = 0;
        user.CraftingNetworkScanToken++;
        if (user.CraftingNetworkScanToken <= 0) { user.CraftingNetworkScanToken = 1; }
        return user.CraftingNetworkScanToken;
    }

    static void SetCraftingJournalState(CaelumPlayer user, bool shouldOpen)
    {
        if (user.player == null) { return; }
        CVar openState = CVar.GetCVar("ca_journal_open", user.player);
        CVar pageState = CVar.GetCVar("ca_journal_page", user.player);
        if (openState != null) { openState.SetBool(shouldOpen); }
        if (shouldOpen && pageState != null) { pageState.SetInt(3); }
    }

    static void OpenCraftingNetwork(CaelumPlayer user, Actor sourceStation)
    {
        if (!CaelumCraftingRules.NetworkHasStation(
            user.CraftingNetworkCapabilities,
            CaelumConstants.CRAFTING_STATION_WORKBENCH
        ))
        {
            user.A_Log("$CA_CRAFTING_NETWORK_MISSING_WORKBENCH");
            user.CraftingMenuOpen = false;
            user.ActiveCraftingStationActor = null;
            return;
        }

        // Cualquier estación conectada abre el mismo menú central.
        user.ActiveCraftingStationActor = sourceStation;
        user.CraftingSessionValidationTics = 0;
        user.OpenCraftingStation(CaelumConstants.CRAFTING_STATION_WORKBENCH);
    }

    static void OpenCraftingStation(CaelumPlayer user, int stationType)
    {
        if (user.CreationWizardOpen) { return; }
        int resolvedStation = CaelumCraftingRules.ResolveStationType(stationType);
        if (resolvedStation == CaelumConstants.CRAFTING_STATION_NONE) { return; }

        if (user.StaffCastPending) { user.CancelPendingStaffCast(false); }
        user.ClosePalomoMerchant();
        user.EquipmentMenuOpen = false;
        user.CraftingMenuOpen = true;
        user.ActiveCraftingStationType = resolvedStation;
        user.CraftingSelectionRecipe = 0;
        user.CraftingRecipeFilter = CaelumConstants.CRAFTING_RECIPE_FILTER_ALL;
        if (user.CraftingSelectionTier <= 0)
        {
            user.CraftingSelectionTier = 1;
            user.CraftingSelectionSize = CaelumConstants.EQUIPMENT_SIZE_M;
        }
        user.LastCraftingAction = CaelumConstants.CRAFTING_ACTION_NONE;
        user.LastEquipmentAction = CaelumConstants.EQUIPMENT_ACTION_NONE;
        user.RefreshCraftingPreview();
        user.SetCraftingJournalState(true);
    }

    static void CloseCraftingStationSession(CaelumPlayer user)
    {
        CaelumTimeAdvanceState.Halt(user);
        user.CraftingMenuOpen = false;
        user.ActiveCraftingStationType = CaelumConstants.CRAFTING_STATION_NONE;
        user.ActiveCraftingStationActor = null;
        user.CraftingSessionValidationTics = 0;
        user.CraftingTaskProgressing = false;
    }

    static bool RefreshActiveCraftingStationSession(CaelumPlayer user, bool recipeInfrastructure = true)
    {
        CaelumCraftingStation station =
            CaelumCraftingStation(user.ActiveCraftingStationActor);
        if (!user.CraftingMenuOpen)
        {
            return false;
        }
        if (station == null || user.player == null
            || user.player.playerstate != PST_LIVE || user.health <= 0)
        {
            user.CloseCraftingStationSession();
            user.SetCraftingJournalState(false);
            return false;
        }
        double dx = station.Pos.X - user.Pos.X;
        double dy = station.Pos.Y - user.Pos.Y;
        double dz = station.Pos.Z - user.Pos.Z;
        double maximumDistance =
            CaelumConstants.CRAFTING_ACTIVE_STATION_DISTANCE;
        if (!station.CanReachFrom(user) || dx * dx + dy * dy + dz * dz
            > maximumDistance * maximumDistance)
        {
            user.CloseCraftingStationSession();
            user.SetCraftingJournalState(false);
            return false;
        }

        // Entrar en combate no cancela ni libera la reserva. La tarea queda
        // pausada hasta que el personaje vuelva a estar fuera de combate y
        // continúe atendiendo esta misma estación.
        if (user.CombatTimeRemaining > 0.0)
        {
            return false;
        }

        // Durante un lote de salto no avanzan los actores ni la geometría.
        // Pump valida la red antes del lote; cada subpaso conserva las guardas
        // de sesión y capacidades sin reconstruir el mismo grafo inmóvil.
        let skip = CaelumTimeSkipState.Get(user);
        bool sharedBatch = skip != null && skip.Active && skip.Pumping
            && skip.Station == station;
        if (!sharedBatch && user.CraftingSessionValidationTics <= 0)
        {
            int scanToken = user.BeginCraftingNetworkScan();
            station.CollectCraftingNetwork(user, scanToken);
            user.CraftingSessionValidationTics = TICRATE;
            user.RefreshCraftingPreview();
        }
        else if (!sharedBatch)
        {
            user.CraftingSessionValidationTics--;
        }
        if (user.CraftingTaskActive)
        {
            return (user.CraftingNetworkCapabilities
                & user.CraftingTaskNetworkCapabilities)
                == user.CraftingTaskNetworkCapabilities;
        }
        return !recipeInfrastructure || user.CraftingSelectedInfrastructureAvailable;
    }

    static void ToggleCraftingMenu(CaelumPlayer user)
    {
        // La tecla de crafteo ya no abre una estación virtual desde cualquier
        // lugar. Sirve para cerrar el menú; la apertura real ocurre usando
        // un actor CaelumCraftingStation del escenario.
        if (user.CraftingMenuOpen)
        {
            user.CloseCraftingStationSession();
            user.SetCraftingJournalState(false);
        }
    }

    static void CycleCraftingRecipe(CaelumPlayer user, int direction)
    {
        bool unifiedCatalogue = user.ActiveCraftingStationType == CaelumConstants.CRAFTING_STATION_WORKBENCH
            || user.ActiveCraftingStationType == CaelumConstants.CRAFTING_STATION_NONE;
        int stationRecipeCount = unifiedCatalogue ? CaelumConstants.CRAFTING_NETWORK_PLAYABLE_RECIPE_COUNT
            : CaelumCraftingRules.GetStationRecipeCount(user.ActiveCraftingStationType);
        if (stationRecipeCount <= 0) { return; }
        int step = direction < 0 ? -1 : 1;
        for (int offset = 1; offset <= stationRecipeCount; offset++)
        {
            int candidate = (
                user.CraftingSelectionRecipe + step * offset
                    + stationRecipeCount * 2
            ) % stationRecipeCount;
            if ((!unifiedCatalogue || user.IsCraftingRecipeKnown(candidate)) && CaelumCraftingRules.RecipeMatchesFilter(
                candidate, user.CraftingRecipeFilter
            ))
            {
                user.CraftingSelectionRecipe = candidate;
                break;
            }
        }
        user.LastCraftingAction = CaelumConstants.CRAFTING_ACTION_NONE;
        user.RefreshCraftingPreview();
    }

    static void CycleCraftingRecipeFilter(CaelumPlayer user)
    {
        if (user.ActiveCraftingStationType
            != CaelumConstants.CRAFTING_STATION_WORKBENCH
            && user.ActiveCraftingStationType != CaelumConstants.CRAFTING_STATION_NONE)
        {
            user.CraftingRecipeFilter =
                CaelumConstants.CRAFTING_RECIPE_FILTER_ALL;
            return;
        }
        user.CraftingRecipeFilter = (user.CraftingRecipeFilter + 1)
            % CaelumConstants.CRAFTING_RECIPE_FILTER_COUNT;
        user.CraftingSelectionRecipe =
            user.GetFirstKnownCraftingRecipe();
        user.LastCraftingAction = CaelumConstants.CRAFTING_ACTION_NONE;
        user.RefreshCraftingPreview();
    }

    static void CycleCraftingTier(CaelumPlayer user)
    {
        user.RefreshCraftingPreview();
        if (user.CraftingSelectedRecipeKind
            == CaelumConstants.CRAFTING_RECIPE_KIND_PROCESSING)
        {
            user.CraftingProcessingBatchIndex = (user.CraftingProcessingBatchIndex + 1)
                % CaelumConstants.CRAFTING_PROCESSING_BATCH_OPTION_COUNT;
            user.LastCraftingAction = CaelumConstants.CRAFTING_ACTION_NONE;
            user.RefreshCraftingPreview();
            return;
        }
        user.CraftingSelectionTier = user.CraftingSelectionTier % 3 + 1;
        user.LastCraftingAction = CaelumConstants.CRAFTING_ACTION_NONE;
        user.RefreshCraftingPreview();
    }

    static void CycleCraftingSize(CaelumPlayer user)
    {
        user.RefreshCraftingPreview();
        if (user.CraftingSelectedRecipeKind == CaelumConstants.CRAFTING_RECIPE_KIND_UTILITY
            || user.CraftingSelectedRecipeKind == CaelumConstants.CRAFTING_RECIPE_KIND_AMULET
            || user.CraftingSelectedRecipeKind == CaelumConstants.CRAFTING_RECIPE_KIND_SEAL
            || user.CraftingSelectedRecipeKind == CaelumConstants.CRAFTING_RECIPE_KIND_AMMUNITION)
        {
            return;
        }
        if (user.CraftingSelectedRecipeKind
                == CaelumConstants.CRAFTING_RECIPE_KIND_PROCESSING
            || user.CraftingSelectedRecipeKind
                == CaelumConstants.CRAFTING_RECIPE_KIND_COMPONENT)
        {
            user.CycleCraftingEfficiency();
            return;
        }
        user.CraftingSelectionSize = (user.CraftingSelectionSize + 1)
            % CaelumConstants.EQUIPMENT_SIZE_COUNT;
        user.LastCraftingAction = CaelumConstants.CRAFTING_ACTION_NONE;
        user.RefreshCraftingPreview();
    }

    static void CycleCraftingEfficiency(CaelumPlayer user)
    {
        user.RefreshCraftingPreview();
        int selectedNode = Clamp(
            user.CraftingBlueprintSelectedNode,
            0, Max(0, user.CraftingBlueprintNodeCount - 1)
        );
        if (selectedNode > 0
            && user.CraftingBlueprintNodeKind[selectedNode]
                == CaelumConstants.CRAFTING_BLUEPRINT_NODE_RECIPE)
        {
            int recipeIndex = user.CraftingBlueprintNodeRecipe[selectedNode];
            int materialTier =
                user.CraftingBlueprintNodeMaterialTier[selectedNode];
            int nextEfficiency =
                (user.GetCraftingLayerEfficiencyIndex(
                    recipeIndex, materialTier
                ) + 1)
                % CaelumConstants.CRAFTING_EFFICIENCY_OPTION_COUNT;
            user.SetCraftingLayerEfficiencyIndex(
                recipeIndex, materialTier, nextEfficiency
            );
        }
        else
        {
            user.CraftingEfficiencyIndex = (user.CraftingEfficiencyIndex + 1)
                % CaelumConstants.CRAFTING_EFFICIENCY_OPTION_COUNT;
        }
        user.LastCraftingAction = CaelumConstants.CRAFTING_ACTION_NONE;
        user.RefreshCraftingPreview();
    }

    static void CycleCraftingBatch(CaelumPlayer user)
    {
        user.RefreshCraftingPreview();
        if (user.CraftingSelectedRecipeKind
                != CaelumConstants.CRAFTING_RECIPE_KIND_PROCESSING
            && user.CraftingSelectedRecipeKind
                != CaelumConstants.CRAFTING_RECIPE_KIND_COMPONENT)
        {
            return;
        }
        user.CraftingProcessingBatchIndex = (user.CraftingProcessingBatchIndex + 1)
            % CaelumConstants.CRAFTING_PROCESSING_BATCH_OPTION_COUNT;
        user.LastCraftingAction = CaelumConstants.CRAFTING_ACTION_NONE;
        user.RefreshCraftingPreview();
    }

    static void AdvanceDebugCraftingTime(CaelumPlayer user)
    {
        if (!user.CraftingTaskActive || user.CraftingTaskCompleting
            || !user.RefreshActiveCraftingStationSession())
        {
            user.LastCraftingAction =
                CaelumConstants.CRAFTING_ACTION_DEBUG_TIME_BLOCKED;
            return;
        }
        user.CraftingTaskRemainingSeconds = Max(
            0.0,
            user.CraftingTaskRemainingSeconds
                - CaelumConstants.CRAFTING_DEBUG_ADVANCE_SECONDS
        );
        user.LastCraftingAction =
            CaelumConstants.CRAFTING_ACTION_DEBUG_TIME_ADVANCED;
        if (user.CraftingTaskRemainingSeconds <= 0.0)
        {
            user.CompleteCraftingTask();
            return;
        }
        user.PersistCharacterState();
        user.RefreshFormalInventorySnapshot();
        if (user.CraftingMenuOpen) { user.RefreshCraftingPreview(); }
    }

    static void UpdateCraftingTask(CaelumPlayer user)
    {
        user.CraftingTaskProgressing = false;
        if (CaelumSleepRules.IsSleeping(user)
            || (CaelumTimeSkipState.IsActive(user) && CaelumScheduleState.SiegeActive(user,level.MapName))) return;
        if (!user.CraftingTaskActive || user.CraftingTaskCompleting) { return; }
        if (!user.RefreshActiveCraftingStationSession()) { return; }
        user.CraftingTaskProgressing = true;
        CaelumTimeSkipState.RecordWork(user);
        user.CraftingTaskRemainingSeconds = Max(
            0.0,
            user.CraftingTaskRemainingSeconds - 1.0 / TICRATE
        );
        if (user.CraftingTaskRemainingSeconds <= 0.0)
        {
            user.CompleteCraftingTask();
        }
    }

}
