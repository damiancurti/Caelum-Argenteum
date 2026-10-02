// Palomo registra el plan; Ronnie enseña y habilita los mismos cupos de oficio.
// No se crean objetos por elegir y los campos anteriores siguen siendo la autoridad.
class CaelumMainM00Loadout : Object play
{
    const CONVERSATION = 43630;
    const REVISION = 1;

    static bool IsBorrowed(CaelumEquipmentItem item)
    {
        return item != null && (item is "CA_LimboMagicImplement"
            || item is "CA_LimboMagicSeal" || item is "CA_LimboRonnieSword"
            || item is "CaelumM01SwordPickup");
    }

    static void EnsureMigration(CaelumPlayer user)
    {
        if (user == null || !user.CharacterCreationComplete) return;
        let r = user.GetPersistentCharacterState(false);
        if (r == null || r.MainM00LoadoutRevision >= REVISION) return;
        // Sólo cambia la clasificación del equipo propio existente. La partida
        // original y su paquete permiten volver al comportamiento anterior.
        for (Inventory cursor = user.Inv; cursor != null; cursor = cursor.Inv)
        {
            let item = CaelumEquipmentItem(cursor);
            if (item != null && !IsBorrowed(item))
                item.ItemFlags &= ~CaelumConstants.CA_ITEMFLAG_LIMBO_TEMP;
        }
        r.MainM00LoadoutRevision = REVISION;
    }

    static bool CanChoose(CaelumPlayer user)
    {
        if (!CaelumMainM00RonnieTrial.CanInteract(user)) return false;
        let speaker = CaelumPalomo(user.player.ConversationNPC);
        let r = user.GetPersistentCharacterState(false);
        return speaker != null && speaker.NarrativeRevealRequired && speaker.DepartureDone
            && speaker.bInConversation && user.HasActiveConversation()
            && user.Distance2D(speaker) <= CaelumConstants.PALOMO_MERCHANT_SESSION_DISTANCE
            && Abs(user.Pos.Z - speaker.Pos.Z) <= 48 && user.CheckSight(speaker)
            && r != null && r.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_PALOMO_MET)
            && r.QuestStage[0] < CaelumConstants.MAIN_M00_STATE_EXIT_CONFIRMED;
    }

    static bool IsComplete(CaelumPersistentCharacterState r)
    {
        return r != null && r.MainM00StarterChosen && r.MainM00ArmorChosen
            && r.MainM00SealChoice > 0 && r.MainM00ShieldChoice > 0;
    }

    static bool Choose(CaelumPlayer user, int kind, int option)
    {
        if (!CanChoose(user)) return false;
        let r = user.GetPersistentCharacterState(false);
        int count = kind == 0 ? CaelumMainM00StarterRules.OPTION_COUNT
            : kind == 1 ? 4 : kind == 2 ? CaelumConstants.SEAL_TYPE_COUNT
            : kind == 3 ? CaelumConstants.SHIELD_TYPE_COUNT : 0;
        if (option < 0 || option >= count) return false;
        EnsureMigration(user);
        if (kind == 0)
        {
            if (r.MainM00StarterChosen) return r.MainM00StarterOption == option;
            r.MainM00StarterChosen = true;
            r.MainM00StarterOption = option;
            r.MainM00StarterSize = CaelumEquipmentRules.GetDefaultSizeForCharacterTier(user.CharacterProfile.GetSizeTier());
        }
        else if (kind == 1)
        {
            if (r.MainM00ArmorChosen) return r.MainM00ArmorType == option;
            r.MainM00ArmorChosen = true; r.MainM00ArmorType = option;
            r.MainM00ArmorSize = r.MainM00StarterChosen ? r.MainM00StarterSize
                : CaelumEquipmentRules.GetDefaultSizeForCharacterTier(user.CharacterProfile.GetSizeTier());
        }
        else if (kind == 2)
        {
            if (r.MainM00SealChoice > 0) return r.MainM00SealChoice == option + 1;
            r.MainM00SealChoice = option + 1;
            for (Inventory cursor = user.Inv; cursor != null; cursor = cursor.Inv)
            {
                let item = CaelumEquipmentItem(cursor);
                if (item == null || IsBorrowed(item) || item.EquipmentKind != CaelumConstants.EQUIPMENT_KIND_SEAL
                    || item.Tier != 1 || item.ItemType != option) continue;
                r.MainM00SealsPrepared[option] = true;
                if (!r.MainM00SealRecipesLearned) r.MainM00SealOwnedAtLearning[option] = true;
            }
        }
        else
        {
            if (r.MainM00ShieldChoice > 0) return r.MainM00ShieldChoice == option + 1;
            r.MainM00ShieldChoice = option + 1;
        }
        // Una partida con Ronnie ya iniciado puede completar una elección
        // nueva sin repetir el inicio, reponer lo gastado ni alterar su tarea.
        if (CaelumMainM00RonnieTrial.IsStarted(user)) TeachPlan(user);
        CaelumMainM00RonnieTrial.Sync(user);
        Refresh(user);
        user.PersistCharacterState();
        return true;
    }

    static void TeachPlan(CaelumPlayer user)
    {
        if (!CaelumMainM00RonnieTrial.IsStarted(user)) return;
        let r = user.GetPersistentCharacterState(false);
        let needs = new("CaelumMainM00StarterMaterials");
        if (!needs.Build(r.MainM00StarterOption, r.MainM00StarterSize, 2)) return;
        if (r.MainM00ArmorChosen) needs.AddArmor(r.MainM00ArmorType, r.MainM00ArmorSize);
        if (r.MainM00SealChoice > 0)
        { needs.AddSeal(r.MainM00SealChoice - 1); r.MainM00SealRecipesLearned = true; }
        if (r.MainM00ShieldChoice > 0) needs.AddShield(r.MainM00ShieldChoice - 1, r.MainM00StarterSize);
        for (int recipe = 0; recipe < CaelumConstants.CRAFTING_NETWORK_PLAYABLE_RECIPE_COUNT; recipe++)
            if (needs.Recipes[recipe]) r.LearnCraftingRecipe(recipe);
        CaelumMainM00SupplyRules.Ensure(user);
        CaelumMainM00SupplyRules.UpdateLimits(user);
        CaelumMainM00RonnieTrial.TeachStarterAmmunition(user);
        user.RefreshCraftingRecipeBookSummary();
    }

    static bool IsChosenShieldRecipe(CaelumPlayer user)
    {
        let r = user.GetPersistentCharacterState(false);
        return r != null && r.MainM00ShieldChoice > 0 && user.CraftingSelectionTier == 1
            && CaelumCraftingRules.GetUnifiedRecipeKind(user.CraftingSelectionRecipe) == CaelumConstants.CRAFTING_RECIPE_KIND_SHIELD
            && CaelumCraftingRules.GetUnifiedShieldType(user.CraftingSelectionRecipe) == r.MainM00ShieldChoice - 1;
    }

    static void RecordShield(CaelumPlayer user, CaelumEquipmentItem item)
    {
        if (!CaelumMainM00RonnieTrial.CanUsePersonalCraftingOutput(user) || !IsChosenShieldRecipe(user) || item == null) return;
        user.GetPersistentCharacterState(false).MainM00ShieldCrafted = true;
        item.ItemFlags &= ~CaelumConstants.CA_ITEMFLAG_LIMBO_TEMP;
    }

    static String Text(String key) { return StringTable.Localize(key, false); }

    static void Refresh(CaelumPlayer user)
    {
        if (user == null || user.WeaponModel == null || user.DerivedStats == null) return;
        EnsureMigration(user);
        let r = user.GetPersistentCharacterState(false);
        if (r == null) return;
        int size = r.MainM00StarterChosen ? r.MainM00StarterSize
            : CaelumEquipmentRules.GetDefaultSizeForCharacterTier(user.CharacterProfile.GetSizeTier());
        user.SetPalomoDialogueToken("CaelumM00LoadoutWeaponToken", r.MainM00StarterChosen);
        user.SetPalomoDialogueToken("CaelumM00ShieldChosenToken", r.MainM00ShieldChoice > 0);
        for (int option = 0; option < CaelumMainM00StarterRules.OPTION_COUNT; option++)
        {
            int weapon = CaelumMainM00StarterRules.GetWeaponType(option);
            int shape = option < 16 ? option : 16 + (option - 16) / CaelumConstants.ESSENCE_TYPE_COUNT;
            String text = CaelumMainM00StarterRules.GetName(option) .. "\n" .. Text(String.Format("CA_LOADOUT_ACTION_%d", shape));
            if (option >= 16)
                text = text .. "\n" .. Text(String.Format("CA_LOADOUT_ESSENCE_%d",
                    CaelumCraftingRules.GetUnifiedEssenceType(CaelumMainM00StarterRules.GetRecipe(option))));
            user.MainM00LoadoutDescriptions[option] = text;
            text = String.Format(Text("CA_LOADOUT_WEIGHT"), user.WeaponModel.GetWeightFor(weapon, 1, size));
            if (option < 16)
            {
                int catalogue = CaelumCraftingRules.GetCatalogueWeaponForPlayableType(weapon);
                if (option == 7 || option >= 12)
                    text = text .. "\n" .. String.Format(Text("CA_LOADOUT_PRIMARY_AIR"),
                        CaelumWeaponCatalogue.GetPrimaryAirCost(catalogue) * user.DerivedStats.AirConsumptionMultiplier);
                else text = text .. "\n" .. String.Format(Text("CA_LOADOUT_AIR"),
                        CaelumWeaponCatalogue.GetPrimaryAirCost(catalogue) * user.DerivedStats.AirConsumptionMultiplier,
                        CaelumWeaponCatalogue.GetSecondaryAirCost(catalogue) * user.DerivedStats.AirConsumptionMultiplier);
            }
            else text = text .. "\n" .. String.Format(Text("CA_LOADOUT_ANIMA"), user.WeaponModel.GetAnimaCostFor(weapon)
                * user.DerivedStats.StaffAnimaCost / CaelumConstants.DEBUG_STAFF_ANIMA_COST);
            user.MainM00LoadoutStats[option] = text .. "\n" .. Text("CA_LOADOUT_HANDLING");
        }
        for (int type = 0; type < 4; type++)
        {
            double weight = 0;
            for (int slot = 0; slot < CaelumConstants.ARMOR_SLOT_COUNT; slot++)
                weight += user.ArmorModel.GetWeightFor(slot, type, 1, r.MainM00ArmorChosen ? r.MainM00ArmorSize : size);
            user.MainM00LoadoutDescriptions[36 + type] = Text(String.Format("CA_M01_ARMOR_DESC_%d", type));
            user.MainM00LoadoutStats[36 + type] = String.Format(Text("CA_LOADOUT_ARMOR_STATS"), weight,
                    CaelumArmorRules.EquipmentDefense(type, 1, false),
                    CaelumArmorRules.EquipmentDefense(type, 1, true));
            let shield = new("CaelumShieldModel");
            shield.ShieldType = type; shield.Tier = 1; shield.Size = size;
            shield.Equipped = true; shield.Durability = shield.GetMaximumDurability();
            user.MainM00LoadoutDescriptions[45 + type] = Text(CaelumDisplayNames.GetShieldKey(type)) .. "\n"
                .. Text(String.Format("CA_LOADOUT_SHIELD_%d", type));
            user.MainM00LoadoutStats[45 + type] = String.Format(Text("CA_LOADOUT_SHIELD_STATS"), shield.GetWeight(),
                    shield.GetDefense(0), shield.GetDefense(1), shield.GetCoverageDegrees())
                .. "\n" .. Text("CA_LOADOUT_SHIELD_USE");
        }
        for (int type = 0; type < CaelumConstants.SEAL_TYPE_COUNT; type++)
        {
            user.MainM00LoadoutDescriptions[40 + type] = Text(CaelumDisplayNames.GetSealKey(type)) .. "\n"
                .. Text(String.Format("CA_LOADOUT_SEAL_%d", type));
            user.MainM00LoadoutStats[40 + type] = String.Format(Text("CA_LOADOUT_SEAL_USE"), CaelumCraftingRules.GetJewelryWeight(1),
                    user.GetSealChannelAdrenalinePerTic(1) * TICRATE, CaelumConstants.SEAL_CHANNEL_COOLDOWN_SECONDS);
        }
        String pending = Text("CA_LOADOUT_UNCHOSEN");
        user.MainM00LoadoutSummary = String.Format(Text("CA_LOADOUT_SUMMARY"),
            r.MainM00StarterChosen ? CaelumMainM00StarterRules.GetName(r.MainM00StarterOption) : pending,
            r.MainM00ArmorChosen ? Text(String.Format("CA_M01_ARMOR_NAME_%d", r.MainM00ArmorType)) : pending,
            r.MainM00SealChoice > 0 ? Text(CaelumDisplayNames.GetSealKey(r.MainM00SealChoice - 1)) : pending,
            r.MainM00ShieldChoice > 0 ? Text(CaelumDisplayNames.GetShieldKey(r.MainM00ShieldChoice - 1)) : pending);
    }
}

class CaelumM00LoadoutReadyToken : CaelumPalomoDialogueMarker {}
class CaelumM00LoadoutWeaponToken : CaelumPalomoDialogueMarker {}
class CaelumM00ShieldChosenToken : CaelumPalomoDialogueMarker {}
class CaelumM00StartRonnieAction : CaelumPalomoDialogueAction
{ override bool Use(bool pickup) { return CaelumMainM00RonnieTrial.Start(CaelumPlayer(Owner)); } }
class CaelumM00ChooseShield0 : CaelumPalomoDialogueAction
{ override bool Use(bool pickup) { return CaelumMainM00Loadout.Choose(CaelumPlayer(Owner), 3, 0); } }
class CaelumM00ChooseShield1 : CaelumPalomoDialogueAction
{ override bool Use(bool pickup) { return CaelumMainM00Loadout.Choose(CaelumPlayer(Owner), 3, 1); } }
class CaelumM00ChooseShield2 : CaelumPalomoDialogueAction
{ override bool Use(bool pickup) { return CaelumMainM00Loadout.Choose(CaelumPlayer(Owner), 3, 2); } }
class CaelumM00ChooseShield3 : CaelumPalomoDialogueAction
{ override bool Use(bool pickup) { return CaelumMainM00Loadout.Choose(CaelumPlayer(Owner), 3, 3); } }
