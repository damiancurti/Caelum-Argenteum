// Palomo entrega una pieza T1 del catálogo; Caella conserva su enseñanza.
class CaelumMainM00Necklace : Object play
{
    const REVISION = 1;
    const TIER = 1;
    const CONVERSATION = 43633;

    static int Recipe(int type)
    {
        return CaelumConstants.CRAFTING_NETWORK_PHYSICAL_RECIPE_COUNT
            + CaelumConstants.CRAFTING_NETWORK_ARMOR_RECIPE_COUNT
            + CaelumConstants.CRAFTING_NETWORK_ESSENCE_RECIPE_COUNT + type;
    }

    static CaelumEquipmentItem FindOwned(CaelumPlayer user, int type)
    {
        for (Inventory cursor = user.Inv; cursor != null; cursor = cursor.Inv)
        {
            let item = CaelumEquipmentItem(cursor);
            if (item != null && item.Owner == user && item.Amount > 0 && !item.IsLimboTemporary()
                && item.EquipmentKind == CaelumConstants.EQUIPMENT_KIND_AMULET
                && item.ItemType == type && item.Tier == TIER) return item;
        }
        return null;
    }

    static bool IsBeingCrafted(CaelumPlayer user, int type)
    {
        return user.CraftingTaskActive && user.CraftingTaskRecipeIndex == Recipe(type)
            && user.CraftingTaskTier == TIER;
    }

    static bool EnsureGranted(CaelumPlayer user)
    {
        if (user == null || user.player == null || user.health <= 0 || !user.CharacterCreationComplete
            || user.CreationWizardOpen || user.DerivedStats == null || (user.player.cheats & CF_PREDICTING)) return false;
        let record = user.GetPersistentCharacterState(false);
        if (record == null || record.MainM00AmuletChoice <= 0
            || record.MainM00AmuletChoice > CaelumConstants.AMULET_TYPE_COUNT) return false;
        if (record.MainM00NecklaceRevision >= REVISION) return true;
        int type = record.MainM00AmuletChoice - 1;
        let item = FindOwned(user, type);
        bool created = false;
        // Un trabajo heredado conserva su reserva y produce la pieza que se
        // reconocerá. Nunca regalamos otra mientras se fabrica la misma T1.
        if (item == null && IsBeingCrafted(user, type)) return false;
        if (item == null)
        {
            item = CaelumEquipmentItem(Actor.Spawn("CaelumAmuletPickup", user.Pos, NO_REPLACE));
            if (item == null) return false;
            item.EquipmentKind = CaelumConstants.EQUIPMENT_KIND_AMULET;
            item.ItemType = type; item.Tier = TIER; item.ArmorSlot = -1;
            item.EquipmentSize = CaelumConstants.EQUIPMENT_SIZE_M;
            item.UnitWeight = CaelumCraftingRules.GetJewelryWeight(TIER);
            item.PickupDataInitialized = true;
            if (!user.PrepareNativeEquipmentPickup(item)) { item.Destroy(); return false; }
            item.AcquisitionResolved = true;
            item.SizePolicyRevision = CaelumEquipmentRules.SIZE_POLICY_REVISION;
            item.AttachToOwner(user);
            if (item.Owner != user) { item.Destroy(); return false; }
            created = true;
        }
        user.EnsureEquipmentItemId(item);
        record.MainM00NecklaceItemId = item.ItemId;
        record.MainM00NecklaceRevision = REVISION;
        record.MainM00AmuletPrepared = true;
        // Una receta ya aprendida conserva los cupos/reservas de su partida.
        // Si aún no la aprendió, Caella observará que la pieza ya era propia.
        if (!record.KnowsCraftingRecipe(Recipe(type))) record.MainM00AmuletOwnedAtLearning = true;
        if (created) CaelumNotifications.Acquired(user, item, 1);
        user.OnNativeInventoryChanged();
        Refresh(user);
        user.PersistCharacterState();
        return true;
    }

    static bool Choose(CaelumPlayer user, int type)
    {
        if (!CaelumMainM00Loadout.CanChoose(user) || type < 0 || type >= CaelumConstants.AMULET_TYPE_COUNT) return false;
        let record = user.GetPersistentCharacterState(false);
        if (record.MainM00AmuletChoice > 0 && record.MainM00AmuletChoice != type + 1) return false;
        record.MainM00AmuletChoice = type + 1;
        EnsureGranted(user);
        // Confirmar fija la elección aunque falte espacio; el estado de entrega
        // se confirma por separado y la página ofrece reintentar sin duplicar.
        user.RefreshSocialJournalSnapshot();
        CaelumMainM00SealCrafting.Sync(user);
        Refresh(user);
        user.PersistCharacterState();
        return true;
    }

    static bool Teach(CaelumPlayer user)
    {
        if (!CaelumMainM00SealCrafting.CanLearn(user)) return false;
        let speaker = CaelumCaella(user.player.ConversationNPC);
        let record = user.GetPersistentCharacterState(false);
        if (speaker == null || !speaker.StoryAnchored || !speaker.bInConversation
            || !user.HasActiveConversation() || record.MainM00AmuletChoice <= 0
            || record.MainM00AmuletChoice > CaelumConstants.AMULET_TYPE_COUNT) return false;
        int type = record.MainM00AmuletChoice - 1;
        if (record.KnowsCraftingRecipe(Recipe(type))) { Refresh(user); return true; }
        CaelumMainM00SealCrafting.EnsureMigration(user);
        CaelumMainM00SupplyRules.Ensure(user);
        let needs = new("CaelumMainM00StarterMaterials"); needs.Efficiency = 2;
        needs.AddAmulet(type);
        for (int recipe = 0; recipe < CaelumConstants.CRAFTING_NETWORK_PLAYABLE_RECIPE_COUNT; recipe++)
            if (needs.Recipes[recipe]) record.LearnCraftingRecipe(recipe);
        record.MainM00SealRecipesLearned = true;
        if (FindOwned(user, type) != null)
        { record.MainM00AmuletPrepared = true; record.MainM00AmuletOwnedAtLearning = true; }
        CaelumMainM00SupplyRules.UpdateLimits(user);
        if (!user.CraftingTaskActive) { user.CraftingEfficiencyIndex = 2; user.ResetCraftingLayerChoices(); }
        user.RefreshCraftingRecipeBookSummary();
        CaelumMainM00SealCrafting.Sync(user);
        Refresh(user);
        user.PersistCharacterState();
        return true;
    }

    static clearscope String Describe(int type)
    {
        return CaelumDisplayNames.FormatAmuletName(type, TIER) .. "\n"
            .. String.Format(StringTable.Localize("CA_PALOMO_NECKLACE_WEIGHT", false),
                CaelumCraftingRules.GetJewelryWeight(TIER)) .. "\n"
            .. String.Format(StringTable.Localize(String.Format("CA_PALOMO_NECKLACE_EFFECT_%d", type), false),
                CaelumConstants.AMULET_MAIN_FAMILY_BONUS_T1, CaelumConstants.AMULET_ADJACENT_FAMILY_BONUS_T1,
                CaelumConstants.AMULET_OPPOSITE_FAMILY_BONUS_T1) .. "\n"
            .. StringTable.Localize("CA_PALOMO_NECKLACE_CONFIRM", false);
    }

    static void Refresh(CaelumPlayer user)
    {
        let record = user.GetPersistentCharacterState(false);
        if (record == null) return;
        int type = record.MainM00AmuletChoice - 1;
        bool chosen = type >= 0 && type < CaelumConstants.AMULET_TYPE_COUNT;
        bool delivered = record.MainM00NecklaceRevision >= REVISION;
        bool learned = chosen && record.KnowsCraftingRecipe(Recipe(type));
        user.SetPalomoDialogueToken("CaelumM00AmuletChosenToken", chosen);
        user.SetPalomoDialogueToken("CaelumM00NecklaceDeliveredToken", delivered);
        user.SetPalomoDialogueToken("CaelumM00AmuletRecipeKnownToken", learned);
        String name = chosen ? CaelumDisplayNames.FormatAmuletName(type, TIER) : "";
        user.MainM00NecklaceStatus = chosen ? name .. "\n" .. StringTable.Localize(delivered
            ? "CA_PALOMO_NECKLACE_DELIVERED" : IsBeingCrafted(user, type)
                ? "CA_PALOMO_NECKLACE_CRAFTING" : "CA_PALOMO_NECKLACE_ROOM", false)
            : StringTable.Localize("CA_PALOMO_NECKLACE_INTRO", false);
        user.MainM00AmuletLessonText = chosen ? name .. "\n" .. StringTable.Localize(learned
            ? "CA_CAELLA_NECKLACE_KNOWN" : "CA_CAELLA_NECKLACE_LESSON", false)
            : StringTable.Localize("CA_CAELLA_NECKLACE_REFERRAL", false);
    }

    static bool RequestMenu(CaelumPlayer user, bool back = false)
    {
        if (!CaelumMainM00Loadout.CanChoose(user)) return false;
        user.MainM00NecklaceMenuSpeaker = user.player.ConversationNPC;
        user.MainM00NecklaceMenuRequest = back ? CaelumMainM00Loadout.CONVERSATION : CONVERSATION;
        return true;
    }

    static void Update(CaelumPlayer user)
    {
        if (level.Time % TICRATE == 0) { EnsureGranted(user); Refresh(user); }
        if (user.MainM00NecklaceMenuRequest == 0 || user.HasActiveConversation()) return;
        let speaker = CaelumPalomo(user.MainM00NecklaceMenuSpeaker);
        int conversation = user.MainM00NecklaceMenuRequest;
        user.MainM00NecklaceMenuRequest = 0; user.MainM00NecklaceMenuSpeaker = null;
        if (!CaelumMainM00RonnieTrial.CanInteract(user) || speaker == null || speaker.health <= 0
            || speaker.bInConversation || !speaker.NarrativeRevealRequired || !speaker.DepartureDone
            || user.Distance2D(speaker) > CaelumConstants.PALOMO_MERCHANT_SESSION_DISTANCE
            || Abs(user.Pos.Z-speaker.Pos.Z) > 48 || !user.CheckSight(speaker)) return;
        Refresh(user); CaelumMainM00Loadout.Refresh(user);
        // El subdiálogo está al final de CAPALOMO: no desplaza nodos guardados.
        // Abrir después del cierre nativo evita que éste cierre el menú nuevo.
        Level.ExecuteSpecial(CaelumConstants.GZDOOM_THING_SET_CONVERSATION_SPECIAL,
            speaker, null, false, 0, conversation);
        if (speaker.HasConversation()) speaker.StartConversation(user, true, true);
    }
}

class CaelumM00NecklaceDeliveredToken : CaelumPalomoDialogueMarker {}
class CaelumM00AmuletRecipeKnownToken : CaelumPalomoDialogueMarker {}
class CaelumM00OpenNecklaceAction : CaelumPalomoDialogueAction
{ override bool Use(bool pickup) { return CaelumMainM00Necklace.RequestMenu(CaelumPlayer(Owner)); } }
class CaelumM00NecklaceBackAction : CaelumPalomoDialogueAction
{ override bool Use(bool pickup) { return CaelumMainM00Necklace.RequestMenu(CaelumPlayer(Owner), true); } }
class CaelumM00ReceiveNecklaceAction : CaelumPalomoDialogueAction
{
    override bool Use(bool pickup)
    {
        let user = CaelumPlayer(Owner);
        if (!CaelumMainM00Loadout.CanChoose(user)) return false;
        CaelumMainM00Necklace.EnsureGranted(user); CaelumMainM00Necklace.Refresh(user);
        return true;
    }
}
class CaelumM00LearnAmuletAction : CaelumPalomoDialogueAction
{ override bool Use(bool pickup) { return CaelumMainM00Necklace.Teach(CaelumPlayer(Owner)); } }
class CaelumM00PalomoAmulet0 : CaelumPalomoDialogueAction
{ override bool Use(bool pickup) { return CaelumMainM00Necklace.Choose(CaelumPlayer(Owner), 0); } }
class CaelumM00PalomoAmulet1 : CaelumPalomoDialogueAction
{ override bool Use(bool pickup) { return CaelumMainM00Necklace.Choose(CaelumPlayer(Owner), 1); } }
class CaelumM00PalomoAmulet2 : CaelumPalomoDialogueAction
{ override bool Use(bool pickup) { return CaelumMainM00Necklace.Choose(CaelumPlayer(Owner), 2); } }
class CaelumM00PalomoAmulet3 : CaelumPalomoDialogueAction
{ override bool Use(bool pickup) { return CaelumMainM00Necklace.Choose(CaelumPlayer(Owner), 3); } }
