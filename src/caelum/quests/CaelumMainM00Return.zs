// Cierre de la mansión. Toda la autoridad permanece en el Inventory viajero;
// puerta y Voz son presentaciones reconstruibles, sin copias del inventario.
class CaelumMainM00Return : Object play
{
    const DOOR_CONVERSATION = 43320;
    const SEWER_CONVERSATION = 43321;
    const FADE_TICS = 18;

    static bool IsReady(CaelumPlayer user)
    {
        if (user == null || user.player == null || user.health <= 0
            || user.player.playerstate != PST_LIVE || !user.CharacterCreationComplete
            || user.CreationWizardOpen || level.MapName != "MAP01"
            || (user.player.cheats & CF_PREDICTING)) return false;
        let r = user.GetPersistentCharacterState(false);
        return r != null && r.QuestState[0] == CaelumConstants.QUEST_STATE_ACTIVE
            && (r.QuestStage[0] == CaelumConstants.MAIN_M00_STATE_FOOL_CAPTURED
                || r.QuestStage[0] == CaelumConstants.MAIN_M00_STATE_EXIT_CONFIRMED)
            && r.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_EXIT_READY)
            && r.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_THE_FOOL_CAPTURED)
            && r.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_RULO_COMPLETE)
            && r.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_STARTER_WEAPON_CRAFTED)
            && r.HasTarotCard(CaelumConstants.TAROT_THE_FOOL)
            && r.MainM00StarterChosen && r.MainM00StarterWeaponId > 0
            && CaelumMainM00FoolCapture.HasOwnedBox(user);
    }

    static bool CanApproach(CaelumPlayer user, CaelumM00ReturnDoor door)
    {
        return IsReady(user) && door != null && door.StoryPlaced
            && user.Distance2D(door) <= 112 && Abs(user.Pos.Z-door.Pos.Z) <= 48
            && user.CheckSight(door);
    }

    static void Feedback(CaelumPlayer user, String key)
    {
        if (user != null) user.A_Print(StringTable.Localize(key, false));
    }

    static bool Begin(CaelumPlayer user)
    {
        if (user == null || user.player == null) return false;
        let door = CaelumM00ReturnDoor(user.player.ConversationNPC);
        if (!CanApproach(user, door) || !door.bInConversation) return false;
        let r = user.GetPersistentCharacterState(true);
        if (r.QuestStage[0] != CaelumConstants.MAIN_M00_STATE_FOOL_CAPTURED) return false;
        if (user.CraftingTaskActive)
        { Feedback(user, "CA_M01_RETURN_FINISH_TASK"); return false; }
        // ChangeLevel mueve la sesión completa. Hasta definir la salida
        // conjunta, no se puede arrastrar a otro jugador ni limpiar sus objetos.
        for (int i = 0; i < MAXPLAYERS; i++)
            if (playeringame[i] && players[i].mo != user)
            { Feedback(user, "CA_M01_RETURN_SOLO"); return false; }
        if (!LevelInfo.MapExists("MAP02"))
        { Feedback(user, "CA_M01_RETURN_ERROR"); return false; }
        r.QuestStage[0] = CaelumConstants.MAIN_M00_STATE_EXIT_CONFIRMED;
        r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_EXIT_CONFIRMED);
        r.MainM00ReturnTics = FADE_TICS;
        r.MainM00ReturnOwnsFreeze = (user.player.cheats & CF_TOTALLYFROZEN) == 0;
        user.player.cheats |= CF_TOTALLYFROZEN;
        user.CancelCombatBlockMode(); user.CancelRangedAim(); user.CancelRangedReload();
        user.CancelWeaponCharge(); user.CancelPendingStaffCast(false); user.StopSealChannel(true);
        user.CloseCraftingStationSession(); user.ClosePalomoMerchant();
        user.SetCraftingJournalState(false); user.EquipmentMenuOpen = false;
        user.Vel = (0,0,0);
        user.PersistCharacterState();
        return true;
    }

    static void ReleaseFreeze(CaelumPlayer user)
    {
        let r = user.GetPersistentCharacterState(false);
        if (r == null) return;
        if (r.MainM00ReturnOwnsFreeze) user.player.cheats &= ~CF_TOTALLYFROZEN;
        r.MainM00ReturnOwnsFreeze = false;
    }

    static void Cancel(CaelumPlayer user)
    {
        let r = user.GetPersistentCharacterState(false);
        if (r == null || r.QuestStage[0] != CaelumConstants.MAIN_M00_STATE_EXIT_CONFIRMED) return;
        ReleaseFreeze(user);
        r.MainM00ReturnTics = 0;
        r.MainM00Flag[CaelumConstants.MAIN_M00_FLAG_EXIT_CONFIRMED] = false;
        r.QuestStage[0] = CaelumConstants.MAIN_M00_STATE_FOOL_CAPTURED;
        user.A_SetBlend("Black", 0.0, 1);
        user.PersistCharacterState();
        Feedback(user, "CA_M01_RETURN_ERROR");
    }

    static CaelumEquipmentItem ResolveStarter(CaelumPlayer user)
    {
        let r = user.GetPersistentCharacterState(false);
        if (r == null || r.MainM00StarterWeaponId <= 0 || !r.MainM00StarterChosen
            || !CaelumMainM00StarterRules.IsOption(r.MainM00StarterOption)) return null;
        let item = user.FindNativeEquipmentItemById(r.MainM00StarterWeaponId);
        if (item != null)
            return item.EquipmentKind == CaelumConstants.EQUIPMENT_KIND_WEAPON ? item : null;
        // Buscar primero la pieza caída: nunca reemplazar una instancia que
        // todavía existe en el mundo. La salida sólo admite una persona.
        let it = ThinkerIterator.Create("CaelumEquipmentItem");
        CaelumEquipmentItem candidate;
        while ((candidate = CaelumEquipmentItem(it.Next())) != null)
        {
            if (candidate.ItemId != r.MainM00StarterWeaponId
                || (candidate.ItemFlags & CaelumConstants.CA_ITEMFLAG_LIMBO_PRESERVABLE) == 0) continue;
            if (candidate.Owner != null || item != null) return null;
            if (candidate.EquipmentKind != CaelumConstants.EQUIPMENT_KIND_WEAPON) return null;
            item = candidate;
        }
        if (item != null) return item;
        // Recuperación excepcional de una pieza destruida, desde la elección
        // guardada; no consume ni reembolsa materiales ni fabrica otra receta.
        item = CaelumEquipmentItem(Actor.Spawn("CaelumWeaponPickup", user.Pos, NO_REPLACE));
        if (item == null) return null;
        item.EquipmentKind = CaelumConstants.EQUIPMENT_KIND_WEAPON;
        item.ItemType = CaelumMainM00StarterRules.GetWeaponType(r.MainM00StarterOption);
        item.Tier = 1; item.EquipmentSize = r.MainM00StarterSize; item.ArmorSlot = -1;
        item.EssenceType = user.WeaponModel.IsMagicalType(item.ItemType)
            ? CaelumCraftingRules.GetUnifiedEssenceType(CaelumMainM00StarterRules.GetRecipe(r.MainM00StarterOption)) : 0;
        item.Durability = r.MainM00StarterConditionKnown ? Max(0, r.MainM00StarterDurability)
            : user.WeaponModel.GetMaximumDurabilityFor(item.ItemType, 1, item.EquipmentSize);
        item.UnitWeight = user.WeaponModel.GetWeightFor(item.ItemType, 1, item.EquipmentSize);
        item.PickupDataInitialized = true; item.ItemId = r.MainM00StarterWeaponId;
        item.ItemFlags = CaelumConstants.CA_ITEMFLAG_LIMBO_PRESERVABLE;
        return item;
    }

    static bool Commit(CaelumPlayer user)
    {
        if (!IsReady(user) || user.CraftingTaskActive || !LevelInfo.MapExists("MAP02")) return false;
        let controller = CaelumMainM00QuestController(EventHandler.Find("CaelumMainM00QuestController"));
        if (controller == null || !CanApproach(user, controller.ReturnDoor)
            || user.HasActiveConversation()) return false;
        for (int i = 0; i < MAXPLAYERS; i++)
            if (playeringame[i] && players[i].mo != user) return false;
        let r = user.GetPersistentCharacterState(false);
        if (r.QuestStage[0] != CaelumConstants.MAIN_M00_STATE_EXIT_CONFIRMED
            || !r.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_EXIT_CONFIRMED)
            || r.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_INVENTORY_SANITIZED)) return false;
        user.SyncActiveModelsToNativeInventory();
        let first = ResolveStarter(user);
        if (first == null) return false;
        // Todas las comprobaciones fallables preceden a la limpieza. Desde
        // aquí no se cede ejecución hasta tener el registro completo.
        if (first.Owner == null) first.AttachToOwner(user);
        first.Equipped = false; first.InMagicBox = true;
        first.ItemFlags &= ~CaelumConstants.CA_ITEMFLAG_LIMBO_TEMP;
        first.ItemFlags |= CaelumConstants.CA_ITEMFLAG_LIMBO_PRESERVABLE;
        user.player.ReadyWeapon = null; user.player.PendingWeapon = WP_NOCHANGE;
        user.A_ClearOverlays(-1, 1000);
        for (Inventory cursor = user.Inv; cursor != null;)
        {
            Inventory next = cursor.Inv;
            if (cursor != first && (cursor is "CaelumEquipmentItem"
                || cursor is "CaelumSpecialInventoryItem" || cursor is "CaelumConsumableItem"
                || cursor is "Ammo" || cursor is "Key" || cursor is "Weapon")) cursor.Destroy();
            cursor = next;
        }
        user.WeaponModel.Equipped = false; user.ActiveWeaponItemId = 0;
        user.ShieldModel.Equipped = false; user.EquippedShieldItemId = 0;
        user.EquippedAmuletItemId = 0; user.EquippedSealItemId = 0;
        for (int slot = 0; slot < CaelumConstants.ARMOR_SLOT_COUNT; slot++)
        {
            user.EquippedArmorItemId[slot] = 0;
            user.ArmorModel.ArmorType[slot] = CaelumConstants.ARMOR_TYPE_BASE_CLOTHING;
            user.ArmorModel.Tier[slot] = 1; user.ArmorModel.Size[slot] = CaelumConstants.EQUIPMENT_SIZE_M;
            user.ArmorModel.Durability[slot] = 0;
        }
        for (int kind = 0; kind < CaelumConstants.WEAPON_TYPE_COUNT; kind++) user.SetRangedMagazineCount(kind, 0);
        r.MainM00AmmoLoanRemaining = 0;
        r.NativeEquipmentMigrationComplete = true;
        r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_STARTER_WEAPON_PRESERVED);
        r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_INVENTORY_SANITIZED);
        r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_COMPLETE);
        r.QuestStage[0] = CaelumConstants.MAIN_M00_STATE_COMPLETE;
        r.SetQuestObjectiveProgress(0, CaelumConstants.MAIN_M00_OBJECTIVE_LEAVE_MANSION, 1, 1);
        r.SetQuestTerminalState(0, CaelumConstants.QUEST_STATE_COMPLETED);
        r.MainM00ReturnTics = 0;
        ReleaseFreeze(user);
        // Se conservan recursos actuales, limitados sólo a sus máximos reales
        // al retirar equipo. No se inventa un loadout ni una curación al salir.
        user.ApplyCharacterProfile(); user.EnsureWeaponFamilySelectors();
        user.PersistCharacterState(); user.RefreshEquipmentSelectionPreview();
        return true;
    }

    static void Update(CaelumPlayer user)
    {
        if (user == null || user.player == null || (user.player.cheats & CF_PREDICTING)) return;
        let r = user.GetPersistentCharacterState(false);
        if (r == null) return;
        if (level.MapName == "MAP01" && r.QuestStage[0] == CaelumConstants.MAIN_M00_STATE_EXIT_CONFIRMED)
        {
            let controller = CaelumMainM00QuestController(EventHandler.Find("CaelumMainM00QuestController"));
            let door = controller != null ? controller.ReturnDoor : null;
            if (door == null) return;
            if (!CanApproach(user, door) || user.CraftingTaskActive) { Cancel(user); return; }
            if (user.HasActiveConversation()) return;
            user.Vel = (0,0,0);
            if (r.MainM00ReturnTics == FADE_TICS) user.A_SetBlend("Black", 0.0, FADE_TICS, "Black", 1.0);
            if (r.MainM00ReturnTics > 0) { r.MainM00ReturnTics--; return; }
            if (!Commit(user)) { Cancel(user); return; }
            CaelumWorldProgress.RecordReturnDeparture(user);
            Level.ChangeLevel("MAP02", 0, CHANGELEVEL_NOINTERMISSION);
        }
        if (level.MapName == "MAP02" && r.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_COMPLETE)
            && !r.MainM00SewerVoiceHeard && user.health > 0 && !user.HasActiveConversation())
        {
            let voice = CaelumUnknownVoiceSpeaker(Actor.Spawn("CaelumUnknownVoiceSpeaker", user.Pos, NO_REPLACE));
            if (voice == null) return;
            Level.ExecuteSpecial(CaelumConstants.GZDOOM_THING_SET_CONVERSATION_SPECIAL,
                voice, null, false, 0, SEWER_CONVERSATION);
            if (!voice.HasConversation() || !voice.StartConversation(user, false, false)) { voice.Destroy(); return; }
            voice.MarkConversationOpened(); r.MainM00SewerVoiceHeard = true;
            user.A_SetBlend("Black", 1.0, TICRATE, "Black", 0.0);
            user.PersistCharacterState();
        }
    }
}

class CaelumM00ReturnDoor : Actor
{
    bool StoryPlaced;
    override bool Used(Actor activator)
    {
        let user = CaelumPlayer(activator);
        if (!CaelumMainM00Return.CanApproach(user, self) || bInConversation
            || user.HasActiveConversation()) return false;
        user.CloseCraftingStationSession(); user.SetCraftingJournalState(false);
        user.EquipmentMenuOpen = false;
        Level.ExecuteSpecial(CaelumConstants.GZDOOM_THING_SET_CONVERSATION_SPECIAL,
            self, null, false, 0, CaelumMainM00Return.DOOR_CONVERSATION);
        return HasConversation() && StartConversation(user, false, true);
    }
    Default
    {
        Radius 12;
        Height 96;
        Scale 0.4;
        +SOLID
        +NOGRAVITY
        +NOBLOOD
        RenderStyle "Add";
        Alpha 0.65;
    }
    States
    {
    Spawn:
        CTAR A -1 Bright;
        Stop;
    }
}

class CaelumM00CrossReturnAction : CaelumPalomoDialogueAction
{
    override bool Use(bool pickup)
    {
        let user = CaelumPlayer(Owner);
        if (user == null) return false;
        CaelumMainM00Return.Begin(user);
        // La petición ya tiene respuesta localizada, incluso si fue rechazada.
        // Consumir la acción evita el mensaje nativo de inventario lleno.
        return true;
    }
}

// Interfaz nativa con la localización compartida; no duplica inventario.
class CaelumReturnConversationMenu : CaelumMainM00ConversationMenu {}
