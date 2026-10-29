// #378: conocimiento y progreso por receta/tier; las hojas viven en el libro.
class CaelumRecipeLearning : Object play
{
    const REVISION = 1;
    const TIERS = 3;
    const SLOT_COUNT = CaelumConstants.CRAFTING_NETWORK_PLAYABLE_RECIPE_COUNT * TIERS;
    const MAX_READINGS = 10;
    const EQUIPMENT_PRACTICE = 10;
    const CONSUMABLE_PRACTICE = 1000;
    const SHEET_KG = 0.005;
    const BOOK_KG = 0.100;
    const EQUIPMENT_PRICE_RATIO = 0.10;
    const CONSUMABLE_PRICE_UNITS = 10;
    const CONSUMABLE_READING_UNITS = 10;

    static int Tier(int recipe, int tier)
    {
        if(CaelumLockRules.IsRecipe(recipe))return CaelumLockRules.RecipeTier(recipe);
        if(CaelumCraftingRules.IsSingleTierRecipe(recipe)
            || CaelumCraftingRules.GetRecipeAmmunitionType(recipe)>=0)return 1;
        int kind=CaelumCraftingRules.GetUnifiedRecipeKind(recipe);
        if(kind==CaelumConstants.CRAFTING_RECIPE_KIND_PROCESSING)
            return Max(1,CaelumCraftingRules.GetProcessingOutputTier(recipe));
        if(kind==CaelumConstants.CRAFTING_RECIPE_KIND_COMPONENT)
            return Max(1,CaelumCraftingRules.GetComponentOutputTier(
                CaelumCraftingRules.GetComponentOutputMaterial(recipe),tier));
        return Clamp(tier,1,TIERS);
    }

    static int TierMask(int recipe)
    {
        if(CaelumSupportImplementData.RetiredRecipe(recipe))return 0;
        int mask=0;
        for(int tier=1;tier<=TIERS;tier++)mask|=1<<(Tier(recipe,tier)-1);
        return mask;
    }

    static int Slot(int recipe, int tier)
    {
        if(CaelumSupportImplementData.RetiredRecipe(recipe))return -1;
        if (recipe < 0 || recipe >= CaelumConstants.CRAFTING_NETWORK_PLAYABLE_RECIPE_COUNT
            || tier < 1 || tier > TIERS) return -1;
        return recipe * TIERS + Tier(recipe,tier) - 1;
    }

    static bool Consumable(int recipe)
    {
        int kind = CaelumCraftingRules.GetUnifiedRecipeKind(recipe);
        return kind == CaelumConstants.CRAFTING_RECIPE_KIND_AMMUNITION
            || kind == CaelumConstants.CRAFTING_RECIPE_KIND_PROCESSING
            || kind == CaelumConstants.CRAFTING_RECIPE_KIND_COMPONENT;
    }

    static int PracticeLimit(int recipe)
    { return Consumable(recipe) ? CONSUMABLE_PRACTICE : EQUIPMENT_PRACTICE; }

    static double TimeFactor(int readings, int practice, int recipe, int efficiency)
    {
        double reading = Clamp(double(readings) / MAX_READINGS, 0.0, 1.0);
        double making = Clamp(double(practice) / PracticeLimit(recipe), 0.0, 1.0);
        double first = 10.0 - 9.0 * Max(reading, making);
        double second = 10.0 - 9.0 * making;
        return efficiency <= 0 ? 1.0 : efficiency == 1 ? first : first * second;
    }

    static double WorkSeconds(CaelumPlayer user, int recipe, int tier,
        int employedUnits, int complexityTics, int efficiency, int outputUnits=0, int fixedBatch=-1)
    {
        if(CaelumMealData.IsRecipe(recipe))return CaelumCookingData.Seconds(recipe);
        if(CaelumChemistryData.IsRecipe(recipe))return CaelumChemistryData.Seconds(recipe)
            *(CaelumChemistryData.IsFermentation(recipe)?1:Ceil(Max(1,outputUnits)/double(CaelumChemistryData.OutputUnits(recipe))))
            *(CaelumChemistryData.UsesDexterity(recipe)?100.0/user.GetCraftingDexterityPercent():1);
        let record = user.GetPersistentCharacterState(false);
        int slot = Slot(recipe, tier);
        int readings = record != null && slot >= 0 ? record.RecipeRereadings[slot] : 0;
        int practice = record != null && slot >= 0 ? record.RecipePractice[slot] : 0;
        // Comparar la misma salida: al 25% se emplea cuatro veces su material.
        // El yodo tiene tiempo base aprobado; conserva aprendizaje y Destreza.
        if(recipe==CaelumMarineData.IODINE_RECIPE)
            return Max(0,employedUnits)*double(CaelumMarineData.WORK_SECONDS)/CaelumMarineData.INPUT_GRAMS
                *TimeFactor(readings,practice,recipe,efficiency)*100.0/user.GetCraftingDexterityPercent();
        double baselineUnits = Max(0, employedUnits)
            * CaelumCraftingRules.GetCraftingEfficiencyPercent(efficiency) / 25.0;
        // La aleacion proporcional redondea cada entrada por separado. Un lote
        // fijo conserva su tiempo al 25% y lo normaliza por su salida real.
        int kind=CaelumCraftingRules.GetUnifiedRecipeKind(recipe);
        if(outputUnits>0 && kind==CaelumConstants.CRAFTING_RECIPE_KIND_PROCESSING)
        {
            if(fixedBatch>=0)
                baselineUnits=double(employedUnits)*outputUnits/Max(1,
                    CaelumCraftingRules.GetProcessingOutputUnitsAtEfficiency(recipe,fixedBatch,0));
            else
            {
                int at25=CaelumCraftingRules.GetEfficiencyAdjustedInputUnits(outputUnits,0);
                int batch=Max(1,CaelumCraftingRules.GetProcessingOutputUnits(recipe,0));
                baselineUnits=user.GetRoundedUpProportionalUnits(at25,
                    CaelumCraftingRules.GetProcessingInputOneUnits(recipe,0),batch)
                    +user.GetRoundedUpProportionalUnits(at25,
                    CaelumCraftingRules.GetProcessingInputTwoUnits(recipe,0),batch);
            }
        }
        else if(outputUnits>0 && kind==CaelumConstants.CRAFTING_RECIPE_KIND_COMPONENT)
            baselineUnits=fixedBatch>=0 ? double(employedUnits)*outputUnits/Max(1,
                CaelumCraftingRules.GetComponentOutputUnits(fixedBatch,0))
                : CaelumCraftingRules.GetEfficiencyAdjustedInputUnits(outputUnits,0);
        return baselineUnits * Clamp(complexityTics,
            CaelumConstants.CRAFTING_SIMPLE_TICS_PER_MATERIAL,
            CaelumConstants.CRAFTING_COMPLEX_TICS_PER_MATERIAL) / TICRATE
            * TimeFactor(readings, practice, recipe, efficiency)
            * 100.0 / user.GetCraftingDexterityPercent();
    }

    static void Practice(CaelumPlayer user, int recipe, int tier, int amount)
    {
        let record = user.GetPersistentCharacterState(false);
        int slot = Slot(recipe, tier);
        if (record == null || slot < 0 || amount <= 0) return;
        record.RecipePractice[slot] = Min(PracticeLimit(recipe), record.RecipePractice[slot] + amount);
    }

    static void CapturePractice(CaelumPlayer user)
    {
        let record=user.GetPersistentCharacterState(true);
        record.RecipeClaimSlots.Clear();record.RecipeClaimAmounts.Clear();
        if(user.CraftingTaskKind==CaelumConstants.CRAFTING_TASK_REPAIR
            || user.CraftingTaskKind==CaelumConstants.CRAFTING_TASK_DISMANTLE)return;
        int recipe=user.CraftingTaskRecipeIndex;
        int amount=CaelumCraftingRules.GetRecipeAmmunitionBatch(recipe);
        if(amount<=0)amount=Consumable(recipe)?Max(1,user.CraftingOutputAmount):1;
        record.RecipeClaimSlots.Push(Slot(recipe,user.CraftingTaskTier));
        record.RecipeClaimAmounts.Push(amount);
        if(!user.CraftingTaskUsesDirectPlan)return;
        for(int step=0;step<user.CraftingDirectPlanStepCount;step++)
        {
            record.RecipeClaimSlots.Push(Slot(user.CraftingPlanStepRecipe[step],user.CraftingPlanStepTier[step]));
            record.RecipeClaimAmounts.Push(user.CraftingPlanStepOutputUnits[step]);
        }
    }

    static void CommitPractice(CaelumPlayer user)
    {
        let record=user.GetPersistentCharacterState(false);
        if(record==null)return;
        for(int i=0;i<record.RecipeClaimSlots.Size();i++)
        {
            int slot=record.RecipeClaimSlots[i];
            if(slot>=0)Practice(user,slot/TIERS,slot%TIERS+1,record.RecipeClaimAmounts[i]);
        }
        record.RecipeClaimSlots.Clear();record.RecipeClaimAmounts.Clear();
    }

    static void DeliverPending(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return;
        let record = user.GetPersistentCharacterState(false);
        if (record == null) return;
        record.EnsureTierRecipeBook();
        if (!record.HasPendingRecipeSheets) return;
        record.HasPendingRecipeSheets = false;
        for (int recipe = 0; recipe < CaelumConstants.CRAFTING_NETWORK_PLAYABLE_RECIPE_COUNT; recipe++)
        {
            int pending = record.PendingRecipeSheets[recipe];
            if (pending == 0) continue;
            for (int tier = 1; tier <= TIERS; tier++)
            {
                int bit = 1 << (tier - 1);
                if ((pending & bit) == 0) continue;
                if (!Receive(user, recipe, tier)) { record.HasPendingRecipeSheets = true; return; }
                record.PendingRecipeSheets[recipe] &= ~bit;
                record.IssuedRecipeSheets[recipe] |= bit;
            }
        }
    }

    static bool Receive(CaelumPlayer user, int recipe, int tier)
    {
        if (!CaelumPlayerAuthority.CanMutate(user) || Slot(recipe, tier) < 0) return false;
        let quote = new("CaelumRecipeQuote");
        quote.Build(user, recipe, tier);
        if (quote.Sheets.Size() == 0) return false;
        let book = CaelumRecipeBook(user.FindInventory("CaelumRecipeBook"));
        int extra = 0;
        for (int i = 0; i < quote.Sheets.Size(); i++)
            if (book == null || !book.Sheets[quote.Sheets[i]]) extra++;
        if (extra == 0) return true;
        double weight = extra * SHEET_KG + (book == null ? BOOK_KG : 0.0);
        user.RefreshCarriedInventorySummary();
        if (book != null && book.InMagicBox)
        {
            if (!user.CanAddRawWeightToMagicBox(weight)) return false;
        }
        else if (!user.CanAddWeightToPersonalInventory(weight)) return false;
        if (book == null)
        {
            book = CaelumRecipeBook(Actor.Spawn("CaelumRecipeBook", user.Pos, NO_REPLACE));
            if (book == null) return false;
            book.AttachToOwner(user);
        }
        for (int i = 0; i < quote.Sheets.Size(); i++) book.Sheets[quote.Sheets[i]] = true;
        CaelumNotifications.Notify(user, String.Format(StringTable.Localize("CA_RECIPE_RECEIVED", false),
            CaelumCraftingBrowser.RecipeName(recipe, tier), tier));
        user.OnNativeInventoryChanged();
        return true;
    }
}

// Un objeto nativo contiene sus páginas; no existe otra lista de objetos físicos.
class CaelumRecipeBook : CaelumSpecialInventoryItem
{
    bool Sheets[CaelumRecipeLearning.SLOT_COUNT];
    override bool TryPickup(in out Actor toucher)
    {
        // Conserva el límite existente de objetos clave: un recetario propio.
        if(toucher==null || toucher.FindInventory("CaelumRecipeBook")!=null)return false;
        return Super.TryPickup(toucher);
    }
    override int GetSpecialCategory() { return CaelumConstants.EQUIPMENT_KIND_KEY_ITEM; }
    override int GetSpecialType() { return CaelumConstants.KEY_ITEM_RECIPE_BOOK; }
    override double GetUnitWeight()
    {
        int count = 0;
        for (int i = 0; i < CaelumRecipeLearning.SLOT_COUNT; i++) if (Sheets[i]) count++;
        return CaelumRecipeLearning.BOOK_KG + count * CaelumRecipeLearning.SHEET_KG;
    }
    override bool HandlePickup(Inventory item)
    { return item is "CaelumRecipeBook" ? false : Super.HandlePickup(item); }
    void CopyPages(CaelumRecipeBook target)
    {
        if (target == null || target == self) return;
        for (int i = 0; i < CaelumRecipeLearning.SLOT_COUNT; i++) target.Sheets[i] = Sheets[i];
    }
    override Inventory CreateCopy(Actor other)
    { let copy = Super.CreateCopy(other); CopyPages(CaelumRecipeBook(copy)); return copy; }
    override Inventory CreateTossable(int amount)
    { let copy = Super.CreateTossable(amount); CopyPages(CaelumRecipeBook(copy)); return copy; }
    override bool Use(bool pickup)
    { CaelumRecipeSession.OpenBook(CaelumPlayer(Owner), self); return false; }
    Default
    {
        Tag "$CA_KEY_ITEM_RECIPE_BOOK";
        Inventory.Icon "graphics/caelum/icons/ca_book.png";
    }
    States { Spawn: CBOO A -1; Stop; }
}

// Consulta acotada de la planificación existente, sin aprender ni reservar.
class CaelumRecipeQuote : Object play
{
    Array<int> Sheets;
    double Seconds,ManufactureSeconds,CompleteManufactureSeconds,ManufactureTics,CompleteManufactureTics;
    int OutputUnits;
    double MasteredNodeSeconds(CaelumPlayer user,int node)
    {
        int recipe=user.CraftingBlueprintNodeRecipe[node];
        if(recipe<0)return 0;
        if(CaelumMealData.IsRecipe(recipe))return user.CraftingBlueprintNodeSeconds[node];
        if(CaelumChemistryData.IsRecipe(recipe))return user.CraftingBlueprintNodeSeconds[node]
            *(CaelumChemistryData.UsesDexterity(recipe)?user.GetCraftingDexterityPercent()/100.0:1);
        int tier=node==0 ? user.CraftingSelectionTier : Max(1,user.CraftingBlueprintNodeMaterialTier[node]);
        int slot=CaelumRecipeLearning.Slot(recipe,tier);
        let record=user.GetPersistentCharacterState(false);
        int readings=record!=null && slot>=0 ? record.RecipeRereadings[slot] : 0;
        int practice=record!=null && slot>=0 ? record.RecipePractice[slot] : 0;
        // Quitar exclusivamente atributos/progreso de la misma duración nativa;
        // el cálculo de cantidades, redondeos y complejidad permanece compartido.
        return user.CraftingBlueprintNodeSeconds[node]*user.GetCraftingDexterityPercent()/100.0
            /CaelumRecipeLearning.TimeFactor(readings,practice,recipe,user.CraftingBlueprintNodeEfficiency[node]);
    }
    double NodeTics(CaelumPlayer user,int node)
    {
        // Cada operación conserva su reloj: Química declara segundos del mundo.
        return MasteredNodeSeconds(user,node)*(CaelumMealData.IsRecipe(user.CraftingBlueprintNodeRecipe[node]) || CaelumChemistryData.IsRecipe(user.CraftingBlueprintNodeRecipe[node])
            ?CaelumWorldClock.TicsPerHour()/3600.0:TICRATE);
    }
    void Build(CaelumPlayer user, int recipe, int tier,int referenceSize=CaelumConstants.EQUIPMENT_SIZE_XL)
    {
        Sheets.Clear(); Seconds = 0;ManufactureSeconds=0;CompleteManufactureSeconds=0;OutputUnits=0;
        ManufactureTics=0;CompleteManufactureTics=0;
        if (user == null || CaelumRecipeLearning.Slot(recipe, tier) < 0) return;
        int oldRecipe=user.CraftingSelectionRecipe, oldTier=user.CraftingSelectionTier;
        int oldSize=user.CraftingSelectionSize, oldEfficiency=user.CraftingEfficiencyIndex;
        int oldBatch=user.CraftingProcessingBatchIndex, oldFilter=user.CraftingRecipeFilter;
        int oldStation=user.ActiveCraftingStationType;
        int oldNode=user.CraftingBlueprintSelectedNode;
        int oldRootRecipe=user.CraftingLayerChoiceRootRecipe, oldRootTier=user.CraftingLayerChoiceRootTier;
        int oldRootSize=user.CraftingLayerChoiceRootSize, oldCount=user.CraftingLayerChoiceCount;
        Array<int> recipes, tiers, efficiencies;
        for(int i=0;i<oldCount;i++)
        { recipes.Push(user.CraftingLayerChoiceRecipe[i]); tiers.Push(user.CraftingLayerChoiceTier[i]); efficiencies.Push(user.CraftingLayerChoiceEfficiency[i]); }
        user.RecipeQuoteActive=true;
        user.CraftingSelectionRecipe=recipe; user.CraftingSelectionTier=tier;
        user.CraftingSelectionSize=referenceSize;
        user.CraftingEfficiencyIndex=2; user.CraftingProcessingBatchIndex=0;
        user.CraftingRecipeFilter=CaelumConstants.CRAFTING_RECIPE_FILTER_ALL;
        user.ActiveCraftingStationType=CaelumConstants.CRAFTING_STATION_WORKBENCH;
        user.ResetCraftingLayerChoices(); user.RefreshCraftingPreview();
        Sheets.Push(CaelumRecipeLearning.Slot(recipe,tier));
        Seconds=user.CraftingBlueprintFullSeconds;
        ManufactureSeconds=MasteredNodeSeconds(user,0);CompleteManufactureSeconds=ManufactureSeconds;
        ManufactureTics=NodeTics(user,0);CompleteManufactureTics=ManufactureTics;
        OutputUnits=CaelumCraftingRules.GetRecipeAmmunitionBatch(recipe);
        if(OutputUnits<=0)OutputUnits=Max(1,user.CraftingOutputAmount);
        for(int i=1;i<user.CraftingBlueprintNodeCount;i++)
        {
            if(user.CraftingBlueprintNodeKind[i]==CaelumConstants.CRAFTING_BLUEPRINT_NODE_RECIPE)
            {
                CompleteManufactureSeconds+=MasteredNodeSeconds(user,i);
                CompleteManufactureTics+=NodeTics(user,i);
            }
            int child=user.CraftingBlueprintNodeRecipe[i];
            int childTier=user.CraftingBlueprintNodeMaterialTier[i];
            if(child<0)continue;
            int slot=CaelumRecipeLearning.Slot(child,Max(1,childTier));
            if(slot>=0 && Sheets.Find(slot)==Sheets.Size())Sheets.Push(slot);
        }
        if(CaelumRecipeLearning.Consumable(recipe))
        {
            int output=CaelumCraftingRules.GetRecipeAmmunitionBatch(recipe);
            if(output<=0)output=user.CraftingOutputAmount;
            Seconds=Seconds*CaelumRecipeLearning.CONSUMABLE_READING_UNITS/Max(1,output);
        }
        user.RecipeQuoteActive=false;
        user.CraftingSelectionRecipe=oldRecipe; user.CraftingSelectionTier=oldTier;
        user.CraftingSelectionSize=oldSize; user.CraftingEfficiencyIndex=oldEfficiency;
        user.CraftingProcessingBatchIndex=oldBatch; user.CraftingRecipeFilter=oldFilter;
        user.ActiveCraftingStationType=oldStation;
        user.CraftingLayerChoiceRootRecipe=oldRootRecipe; user.CraftingLayerChoiceRootTier=oldRootTier;
        user.CraftingLayerChoiceRootSize=oldRootSize; user.CraftingLayerChoiceCount=oldCount;
        for(int i=0;i<oldCount;i++)
        { user.CraftingLayerChoiceRecipe[i]=recipes[i]; user.CraftingLayerChoiceTier[i]=tiers[i]; user.CraftingLayerChoiceEfficiency[i]=efficiencies[i]; }
        user.RefreshCraftingPreview();
        user.CraftingBlueprintSelectedNode=Clamp(oldNode,0,Max(0,user.CraftingBlueprintNodeCount-1));
    }
}
