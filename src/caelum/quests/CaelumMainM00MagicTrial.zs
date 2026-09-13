// Rama de Caella. El Inventory viajero es la única autoridad del progreso.
// Reutiliza el catálogo y las acciones reales; no sustituye el combate por
// pulsaciones ficticias ni incorpora valores nuevos de daño o eficiencia.
class CaelumMainM00MagicTrial : Object play
{
    static bool IsActive(CaelumPlayer user)
    {
        if (user == null || user.player == null || user.health <= 0
            || level.MapName != "MAP01" || !user.CharacterCreationComplete
            || user.CreationWizardOpen || (user.player.cheats & CF_PREDICTING)) return false;
        let record = user.GetPersistentCharacterState(true);
        return record != null && record.IsMainM00MagicActive();
    }

    static void Feedback(CaelumPlayer user, String key, bool error = false)
    {
        if (user == null) return;
        user.A_Print(StringTable.Localize(key, false));
        user.A_StartSound(error ? "caelum/ui/menu_move" : "caelum/ui/menu_select",
            CHAN_7, CHANF_LOCAL | CHANF_UI, 0.65, ATTN_NONE);
    }

    static CaelumEquipmentItem FindImplement(CaelumPlayer user)
    {
        for (Inventory cursor = user.Inv; cursor != null; cursor = cursor.Inv)
        {
            let item = CaelumEquipmentItem(cursor);
            if (item == null || item.InMagicBox || item.Durability <= 0
                || item.EquipmentKind != CaelumConstants.EQUIPMENT_KIND_WEAPON
                || !CaelumEconomyRules.IsEssenceWeaponType(item.ItemType)) continue;
            double tierCost = item.Tier >= 3 ? 2.5 : item.Tier == 2 ? 1.6 : 1.0;
            if (user.WeaponModel.GetAnimaCostFor(item.ItemType) * tierCost
                * user.DerivedStats.StaffAnimaCost / CaelumConstants.DEBUG_STAFF_ANIMA_COST <= user.DerivedStats.MaximumAnima)
                return item;
        }
        return null;
    }

    static bool PrepareEquipment(CaelumPlayer user)
    {
        if (!IsActive(user) || user.WeaponModel == null || user.DerivedStats == null) return false;
        let record = user.GetPersistentCharacterState(true);
        user.SyncActiveModelsToNativeInventory();
        let implement = FindImplement(user);
        if (implement == null)
        {
            implement = CaelumEquipmentItem(user.FindInventory("CA_LimboMagicImplement"));
            if (implement == null)
            {
                implement = CaelumEquipmentItem(Actor.Spawn("CA_LimboMagicImplement", user.Pos, NO_REPLACE));
                if (implement == null) return false;
                implement.EquipmentKind = CaelumConstants.EQUIPMENT_KIND_WEAPON;
                implement.ItemType = CaelumConstants.WEAPON_TYPE_STAFF;
                implement.ArmorSlot = -1;
                implement.Tier = 1;
                implement.EquipmentSize = user.CharacterProfile != null
                    ? CaelumEquipmentRules.GetDefaultSizeForCharacterTier(user.CharacterProfile.GetSizeTier())
                    : user.WeaponModel.Size;
                implement.EssenceType = CaelumConstants.ESSENCE_FIRE;
                implement.UnitWeight = user.WeaponModel.GetWeightFor(implement.ItemType, 1, implement.EquipmentSize);
                implement.PickupDataInitialized = true;
                implement.ItemFlags = CaelumConstants.CA_ITEMFLAG_LIMBO_TEMP;
                implement.AttachToOwner(user);
                user.EnsureEquipmentItemId(implement);
                record.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_MAGIC_IMPLEMENT_GIVEN);
            }
            // El préstamo roto se repone sobre la MISMA instancia e ItemId.
            implement.Durability = user.WeaponModel.GetMaximumDurabilityFor(
                implement.ItemType, implement.Tier, implement.EquipmentSize);
        }
        implement.Equipped = true;
        implement.InMagicBox = false;
        user.ActivateExactEquippedWeapon(implement);

        let seal = user.GetEquippedSeal();
        if (seal == null)
        {
            for (Inventory cursor = user.Inv; cursor != null; cursor = cursor.Inv)
            {
                let candidate = CaelumEquipmentItem(cursor);
                if (candidate != null && !candidate.InMagicBox
                    && candidate.EquipmentKind == CaelumConstants.EQUIPMENT_KIND_SEAL)
                { seal = candidate; break; }
            }
        }
        if (seal == null)
        {
            seal = CaelumEquipmentItem(Actor.Spawn("CA_LimboMagicSeal", user.Pos, NO_REPLACE));
            if (seal == null) return false;
            seal.EquipmentKind = CaelumConstants.EQUIPMENT_KIND_SEAL;
            seal.ItemType = CaelumConstants.SEAL_FIRE;
            seal.EssenceType = seal.ItemType;
            seal.ArmorSlot = -1;
            seal.Tier = 1;
            seal.EquipmentSize = CaelumConstants.EQUIPMENT_SIZE_M;
            seal.UnitWeight = CaelumCraftingRules.GetJewelryWeight(1);
            seal.PickupDataInitialized = true;
            seal.ItemFlags = CaelumConstants.CA_ITEMFLAG_LIMBO_TEMP;
            seal.AttachToOwner(user);
            user.EnsureEquipmentItemId(seal);
            record.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_MAGIC_SEAL_GIVEN);
        }
        seal.Equipped = true;
        user.EquippedSealItemId = seal.ItemId;
        user.ApplyCharacterProfile();
        user.EnsureWeaponFamilySelectors();
        user.PersistCharacterState();
        user.RefreshEquipmentSelectionPreview();
        return true;
    }

    static void ReturnLoans(CaelumPlayer user)
    {
        if (user == null) return;
        bool removed = false;
        bool removedActive = false;
        for (Inventory cursor = user.Inv; cursor != null;)
        {
            Inventory next = cursor.Inv;
            let item = CaelumEquipmentItem(cursor);
            if (item != null && (item is "CA_LimboMagicImplement" || item is "CA_LimboMagicSeal"))
            {
                if (user.ActiveWeaponItemId == item.ItemId)
                { user.ActiveWeaponItemId = 0; user.WeaponModel.Equipped = false; removedActive = true; }
                if (user.EquippedSealItemId == item.ItemId)
                { user.StopSealChannel(true); user.EquippedSealItemId = 0; }
                item.Destroy();
                removed = true;
            }
            cursor = next;
        }
        if (!removed) return;
        let record = user.GetPersistentCharacterState(true);
        let previous = user.FindNativeEquipmentItemById(record.MainM00PreviousWeaponId);
        if (removedActive && previous != null && previous.Equipped && !previous.InMagicBox)
            user.ActivateExactEquippedWeapon(previous);
        else if (removedActive) user.ActivateFirstEquippedWeapon();
        let seal = user.FindNativeEquipmentItemById(record.MainM00PreviousSealId);
        if (user.EquippedSealItemId == 0 && seal != null && !seal.InMagicBox)
        { seal.Equipped = true; user.EquippedSealItemId = seal.ItemId; }
        user.ApplyCharacterProfile();
        user.EnsureWeaponFamilySelectors();
        user.PersistCharacterState();
        user.RefreshEquipmentSelectionPreview();
    }

    static bool Begin(CaelumPlayer user)
    {
        if (user == null || user.player == null || user.health <= 0
            || user.player.playerstate != PST_LIVE || !user.CharacterCreationComplete
            || user.CreationWizardOpen || (user.player.cheats & CF_PREDICTING)
            || level.MapName != "MAP01") return false;
        let speaker = CaelumCaella(user.player.ConversationNPC);
        if (speaker == null || !speaker.StoryAnchored) return false;
        let record = user.GetPersistentCharacterState(true);
        if (!record.BeginMainM00Caella()) return false;
        record.MainM00PreviousWeaponId = user.ActiveWeaponItemId;
        record.MainM00PreviousSealId = user.EquippedSealItemId;
        PrepareEquipment(user);
        Sync(user);
        return true;
    }

    static bool Complete(CaelumPlayer user)
    {
        if (!IsActive(user)) return false;
        let speaker = CaelumCaella(user.player.ConversationNPC);
        if (speaker == null || !speaker.StoryAnchored) return false;
        let record = user.GetPersistentCharacterState(true);
        if (!record.CompleteMainM00Caella()) return false;
        ReturnLoans(user);
        Sync(user);
        return true;
    }

    static void RecordCast(CaelumPlayer user, bool secondary, double spent)
    {
        if (!IsActive(user)) return;
        let record = user.GetPersistentCharacterState(true);
        bool changed = record.SetMainM00Flag(secondary
            ? CaelumConstants.MAIN_M00_FLAG_MAGIC_SECONDARY_USED
            : CaelumConstants.MAIN_M00_FLAG_MAGIC_PRIMARY_USED);
        if (spent > 0.0)
        {
            changed = record.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_MAGIC_ANIMA_SPENT) || changed;
            record.MainM00AnimaAfterCast = user.CurrentAnima;
        }
        if (changed)
        {
            Sync(user);
            Feedback(user, secondary ? "CA_M01_MAGIC_SECONDARY_DONE" : "CA_M01_MAGIC_PRIMARY_DONE");
        }
    }

    static bool CanPrepareChannel(CaelumPlayer user, CaelumEquipmentItem seal)
    {
        if (!IsActive(user) || seal == null || user.DerivedStats == null) return false;
        let record = user.GetPersistentCharacterState(false);
        return !record.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_MAGIC_CHANNEL_USED)
            && user.DerivedStats.MaximumAdrenaline >= user.GetSealChannelAdrenalinePerTic(seal.Tier);
    }

    static void PrepareChannel(CaelumPlayer user, CaelumEquipmentItem seal)
    {
        if (!CanPrepareChannel(user, seal)) return;
        // La demostración no exige herir a nadie: sólo aporta la reserva para
        // un segundo del coste NATIVO del Sello. Se agota al validar User2.
        double reserve = user.GetSealChannelAdrenalinePerTic(seal.Tier) * TICRATE;
        user.AddAdrenaline(Max(0.0, reserve - user.CurrentAdrenaline));
    }

    static void RecordChannel(CaelumPlayer user)
    {
        if (!IsActive(user)) return;
        let record = user.GetPersistentCharacterState(true);
        if (!record.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_MAGIC_CHANNEL_USED)) return;
        Sync(user);
        Feedback(user, "CA_M01_MAGIC_CHANNEL_DONE");
    }

    static void Update(CaelumPlayer user)
    {
        if (user == null) return;
        let record = user.GetPersistentCharacterState(false);
        if (record == null) return;
        if (level.MapName != "MAP01" || record.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_CAELLA_COMPLETE))
        { ReturnLoans(user); return; }
        if (!IsActive(user)) return;
        if (record.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_MAGIC_ANIMA_SPENT)
            && !record.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_MAGIC_ANIMA_RECOVERED)
            && user.CurrentAnima > record.MainM00AnimaAfterCast + 0.01)
        {
            record.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_MAGIC_ANIMA_RECOVERED);
            Sync(user);
            Feedback(user, "CA_M01_MAGIC_RECOVERY_DONE");
        }
    }

    static bool UseRune(CaelumPlayer user, int element)
    {
        if (!IsActive(user)) return false;
        let record = user.GetPersistentCharacterState(true);
        if (!record.IsMainM00MagicPracticeComplete())
        { Feedback(user, "CA_M01_MAGIC_PRACTICE_FIRST", true); return true; }
        if (user.WeaponModel == null || !user.WeaponModel.Equipped
            || !CaelumEconomyRules.IsEssenceWeaponType(user.WeaponModel.WeaponType)
            || user.WeaponModel.Durability <= 0)
        { Feedback(user, "CA_M01_MAGIC_NEED_IMPLEMENT", true); return true; }
        // La interacción conduce el elemento de la runa mediante el implemento;
        // no transforma el arma propia ni obliga a fabricar cuatro variantes.
        int result = record.ActivateMainM00Rune(element);
        if (result == 0) return false;
        Sync(user);
        if (result < 0)
        {
            Feedback(user, record.MainM00RuneErrors >= 4 ? "CA_DLG_M01_MAGIC_HINT_2"
                : record.MainM00RuneErrors >= 2 ? "CA_DLG_M01_MAGIC_HINT_1"
                : "CA_M01_MAGIC_RUNE_RESET", true);
        }
        else if (result == 2)
        {
            Feedback(user, "CA_M01_MAGIC_RUNES_READY");
        }
        else Feedback(user, "CA_M01_MAGIC_RUNE_OK");
        return true;
    }

    static void Sync(CaelumPlayer user)
    {
        let record = user.GetPersistentCharacterState(true);
        record.RefreshMainM00MagicObjective();
        CaelumMainM00SealCrafting.Sync(user);
        user.SetPalomoDialogueToken("CaelumM00MagicStartedToken", record.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_CAELLA_STARTED));
        user.SetPalomoDialogueToken("CaelumM00MagicPracticeToken", record.IsMainM00MagicPracticeComplete());
        user.SetPalomoDialogueToken("CaelumM00MagicRunesReadyToken", record.MainM00RuneSequenceIndex == 4);
        user.SetPalomoDialogueToken("CaelumM00MagicCompleteToken", record.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_CAELLA_COMPLETE));
        user.SetPalomoDialogueToken("CaelumM00MagicHint1Token", record.MainM00RuneErrors >= 2);
        user.SetPalomoDialogueToken("CaelumM00MagicHint2Token", record.MainM00RuneErrors >= 4);
        user.MainM00MagicPracticeSnapshot = record.CountMainM00MagicPractice();
        user.MainM00RuneSequenceSnapshot = record.MainM00RuneSequenceIndex;
        user.RefreshSocialJournalSnapshot();
        user.PersistCharacterState();
    }
}

class CA_LimboMagicImplement : CaelumWeaponPickup {}
class CA_LimboMagicSeal : CaelumSealPickup {}
class CaelumM00MagicStartedToken : CaelumPalomoDialogueMarker {}
class CaelumM00MagicPracticeToken : CaelumPalomoDialogueMarker {}
class CaelumM00MagicRunesReadyToken : CaelumPalomoDialogueMarker {}
class CaelumM00FinishMagicAction : CaelumPalomoDialogueAction
{
    override bool Use(bool pickup) { return CaelumMainM00MagicTrial.Complete(CaelumPlayer(Owner)); }
}
class CaelumM00MagicCompleteToken : CaelumPalomoDialogueMarker {}
class CaelumM00MagicHint1Token : CaelumPalomoDialogueMarker {}
class CaelumM00MagicHint2Token : CaelumPalomoDialogueMarker {}
class CaelumM00StartMagicAction : CaelumPalomoDialogueAction
{
    override bool Use(bool pickup) { return CaelumMainM00MagicTrial.Begin(CaelumPlayer(Owner)); }
}
class CaelumM00PrepareMagicAction : CaelumPalomoDialogueAction
{
    override bool Use(bool pickup)
    {
        let user = CaelumPlayer(Owner);
        if (user == null || user.player == null || CaelumCaella(user.player.ConversationNPC) == null) return false;
        bool result = CaelumMainM00MagicTrial.PrepareEquipment(user);
        CaelumMainM00MagicTrial.Sync(user);
        return result;
    }
}

// Presentación de prueba con los emblemas elementales existentes. La elección
// artística final sigue pendiente; no se añade una fuente gráfica provisional.
class CaelumM00ElementRune : Actor
{
    int Element;
    int SequenceSlot;
    bool Lit;

    override bool Used(Actor user)
    {
        let actorUser = CaelumPlayer(user);
        if (actorUser == null || Distance2D(actorUser) > 96.0
            || Abs(actorUser.Pos.Z - Pos.Z) > 80.0) return false;
        return CaelumMainM00MagicTrial.UseRune(actorUser, Element);
    }

    void Configure(int element, int slot)
    {
        self.Element = element;
        SequenceSlot = slot;
        String visual = element == CaelumConstants.ESSENCE_EARTH ? "SLEA"
            : element == CaelumConstants.ESSENCE_WIND ? "SLAI"
            : element == CaelumConstants.ESSENCE_WATER ? "SLWA" : "SLFI";
        sprite = GetSpriteIndex(visual);
        frame = 0;
    }

    Default
    {
        Radius 9;
        Height 48;
        Scale 0.20;
        +NOGRAVITY
        +SOLID
        RenderStyle "Translucent";
        Alpha 0.45;
    }
    States
    {
    Spawn:
        SLFI A -1 Bright;
        Stop;
    }
}

// Preparación opcional posterior a las runas; no modifica sus requisitos.
class CaelumMainM00SealCrafting : Object play
{
    static bool CanLearn(CaelumPlayer user)
    {
        if (!CaelumMainM00RonnieTrial.CanInteract(user)) return false;
        let r = user.GetPersistentCharacterState(false);
        return r != null && r.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_CAELLA_COMPLETE)
            && r.QuestStage[0] < CaelumConstants.MAIN_M00_STATE_EXIT_CONFIRMED;
    }

    static void EnsureMigration(CaelumPlayer user)
    {
        if (user == null) return;
        let r = user.GetPersistentCharacterState(false);
        if (r == null) return;
        if (r.MainM00SealRecipesLearned && r.MainM00SealChoice == 0 && r.MainM00LegacySealTaskRecipe == 0)
        {
            int pending = user.CraftingTaskActive ? user.CraftingTaskRecipeIndex
                : (r.CraftingTaskActive ? r.CraftingTaskRecipeIndex : -1);
            if (pending >= 56 && pending <= 60) r.MainM00LegacySealTaskRecipe = pending + 1;
        }
        if (!r.MainM00AccessoryLimitsUpdated)
        { r.MainM00AccessoryLimitsUpdated = true; CaelumMainM00SupplyRules.UpdateLimits(user); }
    }

    // Compatibilidad de clase para partidas anteriores; no elige por el jugador.
    static bool Learn(CaelumPlayer user) { return false; }

    static bool Choose(CaelumPlayer user, bool amulet, int type)
    {
        if (!CanLearn(user)) return false;
        let speaker = CaelumCaella(user.player.ConversationNPC);
        if (speaker == null || !speaker.StoryAnchored || type < 0
            || type >= (amulet ? CaelumConstants.AMULET_TYPE_COUNT : CaelumConstants.SEAL_TYPE_COUNT)) return false;
        let r = user.GetPersistentCharacterState(false);
        EnsureMigration(user);
        int oldChoice = amulet ? r.MainM00AmuletChoice : r.MainM00SealChoice;
        if (oldChoice > 0) return oldChoice == type + 1;
        CaelumMainM00SupplyRules.Ensure(user);
        bool previousSealLesson = r.MainM00SealRecipesLearned;
        if (amulet) r.MainM00AmuletChoice = type + 1;
        else r.MainM00SealChoice = type + 1;
        r.MainM00SealRecipesLearned = true;
        let needs = new("CaelumMainM00StarterMaterials"); needs.Efficiency = 2;
        if (amulet) needs.AddAmulet(type); else needs.AddSeal(type);
        for (int recipe = 0; recipe < CaelumConstants.CRAFTING_NETWORK_PLAYABLE_RECIPE_COUNT; recipe++)
            if (needs.Recipes[recipe]) r.LearnCraftingRecipe(recipe);
        for (Inventory cursor = user.Inv; cursor != null; cursor = cursor.Inv)
        {
            let item = CaelumEquipmentItem(cursor);
            if (item == null || item.EquipmentKind != (amulet ? CaelumConstants.EQUIPMENT_KIND_AMULET
                : CaelumConstants.EQUIPMENT_KIND_SEAL) || item.Tier != 1 || item.ItemType != type
                || item is "CA_LimboMagicSeal") continue;
            if (amulet) { r.MainM00AmuletPrepared = true; r.MainM00AmuletOwnedAtLearning = true; }
            else
            {
                r.MainM00SealsPrepared[type] = true;
                if (!previousSealLesson) r.MainM00SealOwnedAtLearning[type] = true;
            }
        }
        CaelumMainM00SupplyRules.UpdateLimits(user);
        if (!user.CraftingTaskActive) { user.CraftingEfficiencyIndex = 2; user.ResetCraftingLayerChoices(); }
        user.RefreshCraftingRecipeBookSummary();
        Sync(user); user.RefreshSocialJournalSnapshot(); user.PersistCharacterState();
        return true;
    }

    static bool IsLearnedRecipe(CaelumPlayer user)
    {
        EnsureMigration(user);
        let r = user.GetPersistentCharacterState(false);
        if (r == null || user.CraftingSelectionTier != 1) return false;
        int kind = CaelumCraftingRules.GetUnifiedRecipeKind(user.CraftingSelectionRecipe);
        if (r.MainM00LegacySealTaskRecipe == user.CraftingSelectionRecipe + 1
            && user.CraftingTaskActive && kind == CaelumConstants.CRAFTING_RECIPE_KIND_SEAL) return true;
        return (kind == CaelumConstants.CRAFTING_RECIPE_KIND_SEAL && r.MainM00SealChoice > 0
            && CaelumCraftingRules.GetUnifiedSealType(user.CraftingSelectionRecipe) == r.MainM00SealChoice - 1)
            || (kind == CaelumConstants.CRAFTING_RECIPE_KIND_AMULET && r.MainM00AmuletChoice > 0
            && CaelumCraftingRules.GetUnifiedAmuletType(user.CraftingSelectionRecipe) == r.MainM00AmuletChoice - 1);
    }

    static bool CanGather(CaelumPlayer user)
    {
        if (!CanLearn(user)) return false;
        let r = user.GetPersistentCharacterState(false);
        if (!r.MainM00SealRecipesLearned || !r.MainM00StarterChosen) return false;
        let needs = new("CaelumMainM00StarterMaterials"); needs.Efficiency = 2;
        if (r.MainM00SealChoice > 0 && !r.MainM00SealsPrepared[r.MainM00SealChoice - 1])
            needs.AddSeal(r.MainM00SealChoice - 1);
        if (r.MainM00AmuletChoice > 0 && !r.MainM00AmuletPrepared) needs.AddAmulet(r.MainM00AmuletChoice - 1);
        for (int material = 0; material < CaelumConstants.MATERIAL_TYPE_COUNT; material++)
            if (needs.Units[material] > 0 && CaelumMainM00SupplyRules.Remaining(user, material) > 0) return true;
        return false;
    }

    static void RecordCraft(CaelumPlayer user, CaelumEquipmentItem item)
    {
        if (!CaelumMainM00SupplyRules.IsLimited(user) || !IsLearnedRecipe(user)
            || !user.CraftingTaskCompleting || item == null
            || (item.EquipmentKind != CaelumConstants.EQUIPMENT_KIND_SEAL
                && item.EquipmentKind != CaelumConstants.EQUIPMENT_KIND_AMULET)
            || item.ItemType < 0 || item.ItemType >= CaelumConstants.SEAL_TYPE_COUNT) return;
        let r = user.GetPersistentCharacterState(false);
        if (item.EquipmentKind == CaelumConstants.EQUIPMENT_KIND_AMULET) r.MainM00AmuletPrepared = true;
        else r.MainM00SealsPrepared[item.ItemType] = true;
        item.ItemFlags |= CaelumConstants.CA_ITEMFLAG_LIMBO_TEMP;
        user.RefreshSocialJournalSnapshot();
    }

    static void Sync(CaelumPlayer user)
    {
        let r = user.GetPersistentCharacterState(false);
        if (r == null) return;
        user.SetPalomoDialogueToken("CaelumM00SealsLearnedToken", r.MainM00SealChoice > 0);
        user.SetPalomoDialogueToken("CaelumM00AmuletChosenToken", r.MainM00AmuletChoice > 0);
        EnsureMigration(user);
        user.SetPalomoDialogueToken("CaelumM00SealGatherReadyToken", CanGather(user));
        user.SetPalomoDialogueToken("CaelumM00SealGatherPracticeToken", CanLearn(user)
            && r.MainM00SealRecipesLearned && r.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_RONNIE_COMPLETE));
        user.SetPalomoDialogueToken("CaelumM00GatheringLoanHeldToken", CaelumMainM00RonnieTrial.FindLoan(user) != null);
    }
}
class CaelumM00SealsLearnedToken : CaelumPalomoDialogueMarker {}
class CaelumM00SealGatherReadyToken : CaelumPalomoDialogueMarker {}
class CaelumM00SealGatherPracticeToken : CaelumPalomoDialogueMarker {}
class CaelumM00GatheringLoanHeldToken : CaelumPalomoDialogueMarker {}
class CaelumM00LearnSealsAction : CaelumPalomoDialogueAction
{
    override bool Use(bool pickup) { return CaelumMainM00SealCrafting.Learn(CaelumPlayer(Owner)); }
}
class CaelumM00BorrowSealSwordAction : CaelumPalomoDialogueAction
{
    override bool Use(bool pickup)
    {
        let user = CaelumPlayer(Owner);
        if (!CaelumMainM00RonnieTrial.IsRonnie(user) || !CaelumMainM00SealCrafting.CanGather(user)) return false;
        bool result = CaelumMainM00RonnieTrial.PrepareLoan(user, false, true);
        CaelumMainM00SealCrafting.Sync(user);
        return result;
    }
}

class CaelumM00AmuletChosenToken : CaelumPalomoDialogueMarker {}
class CaelumM00ChooseSeal0 : CaelumPalomoDialogueAction
{ override bool Use(bool pickup) { return CaelumMainM00SealCrafting.Choose(CaelumPlayer(Owner), false, 0); } }
class CaelumM00ChooseSeal1 : CaelumPalomoDialogueAction
{ override bool Use(bool pickup) { return CaelumMainM00SealCrafting.Choose(CaelumPlayer(Owner), false, 1); } }
class CaelumM00ChooseSeal2 : CaelumPalomoDialogueAction
{ override bool Use(bool pickup) { return CaelumMainM00SealCrafting.Choose(CaelumPlayer(Owner), false, 2); } }
class CaelumM00ChooseSeal3 : CaelumPalomoDialogueAction
{ override bool Use(bool pickup) { return CaelumMainM00SealCrafting.Choose(CaelumPlayer(Owner), false, 3); } }
class CaelumM00ChooseSeal4 : CaelumPalomoDialogueAction
{ override bool Use(bool pickup) { return CaelumMainM00SealCrafting.Choose(CaelumPlayer(Owner), false, 4); } }
class CaelumM00ChooseAmulet0 : CaelumPalomoDialogueAction
{ override bool Use(bool pickup) { return CaelumMainM00SealCrafting.Choose(CaelumPlayer(Owner), true, 0); } }
class CaelumM00ChooseAmulet1 : CaelumPalomoDialogueAction
{ override bool Use(bool pickup) { return CaelumMainM00SealCrafting.Choose(CaelumPlayer(Owner), true, 1); } }
class CaelumM00ChooseAmulet2 : CaelumPalomoDialogueAction
{ override bool Use(bool pickup) { return CaelumMainM00SealCrafting.Choose(CaelumPlayer(Owner), true, 2); } }
class CaelumM00ChooseAmulet3 : CaelumPalomoDialogueAction
{ override bool Use(bool pickup) { return CaelumMainM00SealCrafting.Choose(CaelumPlayer(Owner), true, 3); } }
