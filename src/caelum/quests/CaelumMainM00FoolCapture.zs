// La aparición es reconstruible; colección, revelación y progreso pertenecen
// al Inventory viajero. El actor sólo conserva la animación en curso.
class CaelumMainM00FoolCapture : Object play
{
    static Vector3 GetSpot() { return (1420, 1050, -370); }

    static bool CanApproach(CaelumPlayer user, CaelumM00FoolEssence essence)
    {
        if (user == null || user.player == null || user.health <= 0
            || !user.CharacterCreationComplete || user.CreationWizardOpen
            || level.MapName != "MAP01" || (user.player.cheats & CF_PREDICTING)
            || essence == null || !essence.StoryPlaced) return false;
        return user.Distance2D(essence) <= 128 && Abs(user.Pos.Z-essence.Pos.Z) <= 48
            && user.CheckSight(essence);
    }

    static bool HasOwnedBox(CaelumPlayer user)
    {
        let record = user.GetPersistentCharacterState(false);
        let box = CaelumMagicBox(user.FindInventory("CaelumMagicBox"));
        return record != null && record.MagicBoxOwned && record.MagicBoxItemId > 0
            && box != null && box.Owner == user && box.ItemId == record.MagicBoxItemId;
    }

    // Diagnóstico explícito: sólo lee el estado; no repara ni entrega objetos.
    static void Report(CaelumPlayer user)
    {
        if (user == null || user.player == null) return;
        let record = user.GetPersistentCharacterState(false);
        Console.Printf("[Caelum 4.35.0d] Diagnóstico de El Loco (1=sí, 0=no)");
        if (record == null)
        {
            Console.Printf("Registro de personaje ausente.");
            return;
        }
        let controller = CaelumMainM00QuestController(EventHandler.Find("CaelumMainM00QuestController"));
        let essence = controller == null ? null : controller.FoolEssence;
        let box = CaelumMagicBox(user.FindInventory("CaelumMagicBox"));
        Console.Printf("Mapa=%s fase=%d estado=%d capturable=%d carta=%d revelada=%d",
            level.MapName, record.QuestStage[0], record.QuestState[0],
            record.CanCaptureMainM00Fool(), record.HasTarotCard(0), record.MainM00FoolRevealed);
        Console.Printf("Caja válida=%d id local=%d id registro=%d",
            HasOwnedBox(user), box == null ? 0 : box.ItemId, record.MagicBoxItemId);
        Console.Printf("Hitos Argento/Caella/Ronnie/Rulo/Caja/captura=%d/%d/%d/%d/%d/%d",
            record.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_ARGENTO_COMPLETE),
            record.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_CAELLA_COMPLETE),
            record.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_RONNIE_COMPLETE),
            record.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_RULO_COMPLETE),
            record.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_MAGIC_BOX_GRANTED),
            record.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_THE_FOOL_CAPTURED));
        Console.Printf("Personaje creado=%d vida=%d estado nativo=%d",
            user.CharacterCreationComplete, user.health, user.player.playerstate);
        Console.Printf("Canal=%d adrenalina=%.2f recarga=%.2f menús creador/equipo/oficios/tienda=%d/%d/%d/%d",
            user.CombatChannelModeActive, user.CurrentAdrenaline, user.CombatChannelCooldownRemaining,
            user.CreationWizardOpen, user.EquipmentMenuOpen, user.CraftingMenuOpen, user.PalomoMerchantMenuOpen);
        Console.Printf("Posición=(%.1f,%.1f,%.1f) rumbo=%.1f inclinación=%.1f alcance Usar=%.1f",
            user.Pos.X, user.Pos.Y, user.Pos.Z, user.Angle, user.Pitch, user.UseRange);
        Console.Printf("Conversación jugador=%d NPC en diálogo=%d",
            user.player.ConversationNPC != null,
            user.player.ConversationNPC != null && user.player.ConversationNPC.bInConversation);
        if (essence == null)
        {
            Console.Printf("Esencia ausente del controlador.");
            return;
        }
        Console.Printf("Esencia colocada=%d accesible=%d distancia=%.1f desnivel=%.1f vista=%d",
            essence.StoryPlaced, CanApproach(user, essence), user.Distance2D(essence),
            Abs(user.Pos.Z - essence.Pos.Z), user.CheckSight(essence));
        Console.Printf("Esencia diálogo=%d capturando=%d tics=%d",
            essence.bInConversation, essence.CaptureUser != null, essence.CaptureTics);
    }

    static void Sync(CaelumPlayer user)
    {
        let record = user.GetPersistentCharacterState(false);
        if (record == null) return;
        if (record.CanCaptureMainM00Fool())
        {
            int objective = record.GetQuestObjectiveStorageIndex(
                CaelumConstants.QUEST_MAIN_M00_THE_FOOL, CaelumConstants.MAIN_M00_OBJECTIVE_CAPTURE_FOOL);
            if (!record.QuestObjectiveKnown[objective])
            {
                record.QuestObjectiveKnown[objective] = true;
                record.QuestObjectiveTarget[objective] = 1;
                user.RefreshSocialJournalSnapshot();
            }
        }
    }

    static bool BeginCapture(CaelumPlayer user)
    {
        if (user == null || user.player == null) return false;
        let essence = CaelumM00FoolEssence(user.player.ConversationNPC);
        if (!CanApproach(user, essence) || !essence.bInConversation
            || essence.CaptureUser != null || !HasOwnedBox(user)) return false;
        let record = user.GetPersistentCharacterState(false);
        if (record == null || !record.CanCaptureMainM00Fool() || !record.MainM00FoolRevealed) return false;
        let image = CaelumM00FoolCaptureImage(Actor.Spawn("CaelumM00FoolCaptureImage", essence.Pos, NO_REPLACE));
        if (image == null) return false;
        essence.CaptureUser = user;
        essence.CaptureImage = image;
        essence.CaptureTics = 0;
        essence.CaptureBoxId = record.MagicBoxItemId;
        image.Anchor = essence;
        // La identidad no se consume al comenzar. Alejarse, morir o perder la
        // Caja interrumpe sin recompensa y permite volver a intentarlo.
        return true;
    }

    static bool CommitCapture(CaelumPlayer user, CaelumM00FoolEssence essence)
    {
        if (!CanApproach(user, essence) || essence.CaptureUser != user
            || essence.CaptureTics < CaelumConstants.MAIN_M00_FOOL_CAPTURE_TICS
            || essence.CaptureImage == null || !HasOwnedBox(user)) return false;
        let record = user.GetPersistentCharacterState(false);
        if (record == null || record.MagicBoxItemId != essence.CaptureBoxId
            || !record.RecordMainM00FoolCapture()) return false;
        user.ApplyCharacterProfile();
        user.RefreshSocialJournalSnapshot();
        user.RefreshFormalInventorySnapshot();
        user.SyncPalomoDialogueTokens();
        user.PersistCharacterState();
        EventHandler.SendInterfaceEvent(user.PlayerNumber(), "ca_tarot_capture");
        user.A_Print(StringTable.Localize("CA_M01_FOOL_OBTAINED", false));
        return true;
    }
}

class CaelumM00FoolEssence : Actor
{
    bool StoryPlaced;
    bool Revealed;
    CaelumPlayer CaptureUser;
    CaelumM00FoolCaptureImage CaptureImage;
    int CaptureTics;
    int CaptureBoxId;

    void SetRevealed(bool value)
    {
        Revealed = value;
        sprite = GetSpriteIndex(value ? "CFLF" : "CTAR");
        frame = 0;
        Scale = value ? (0.25, 0.25) : (0.65, 0.65);
        Alpha = 0.90;
    }

    override bool Used(Actor activator)
    {
        let user = CaelumPlayer(activator);
        if (!CaelumMainM00FoolCapture.CanApproach(user, self) || bInConversation
            || CaptureUser != null || user.HasActiveConversation()) return false;
        let record = user.GetPersistentCharacterState(false);
        if (record == null || !record.CanCaptureMainM00Fool()
            || !CaelumMainM00FoolCapture.HasOwnedBox(user)) return false;
        if (user.StaffCastPending) user.CancelPendingStaffCast(false);
        user.CloseCraftingStationSession();
        user.SetCraftingJournalState(false);
        user.EquipmentMenuOpen = false;
        Level.ExecuteSpecial(CaelumConstants.GZDOOM_THING_SET_CONVERSATION_SPECIAL,
            self, null, false, 0, CaelumConstants.MAIN_M00_FOOL_CONVERSATION_ID);
        if (!HasConversation() || !StartConversation(user, true, true)) return false;
        if (!record.MainM00FoolRevealed)
        {
            record.MainM00FoolRevealed = true;
            user.RefreshSocialJournalSnapshot();
            user.PersistCharacterState();
            user.A_StartSound("caelum/stock/reveal_sting", CHAN_6, CHANF_LOCAL | CHANF_UI, 0.65, ATTN_NONE);
        }
        SetRevealed(true);
        return true;
    }

    void CancelCapture(bool feedback = true)
    {
        let user = CaptureUser;
        CaptureUser = null;
        CaptureTics = 0;
        CaptureBoxId = 0;
        if (CaptureImage != null) CaptureImage.Destroy();
        CaptureImage = null;
        SetRevealed(Revealed);
        if (feedback && user != null && user.health > 0)
            CaelumMainM00MagicTrial.Feedback(user, "CA_M01_FOOL_INTERRUPTED", true);
    }

    override void Tick()
    {
        Super.Tick();
        if (CaptureUser == null) return;
        let record = CaptureUser.GetPersistentCharacterState(false);
        if (!CaelumMainM00FoolCapture.CanApproach(CaptureUser, self)
            || !CaelumMainM00FoolCapture.HasOwnedBox(CaptureUser) || record == null
            || !record.CanCaptureMainM00Fool() || record.MagicBoxItemId != CaptureBoxId
            || CaptureImage == null)
        { CancelCapture(); return; }
        // USDF debe soltar el diálogo antes de que empiece la animación.
        if (bInConversation || CaptureUser.HasActiveConversation()) return;
        CaptureTics++;
        double fraction = Clamp(double(CaptureTics) / CaelumConstants.MAIN_M00_FOOL_CAPTURE_TICS, 0.0, 1.0);
        Vector3 destination = CaptureUser.Pos + (Cos(CaptureUser.Angle)*22,
            Sin(CaptureUser.Angle)*22, CaptureUser.Height*0.5);
        CaptureImage.SetOrigin(Pos + (destination-Pos)*fraction, false);
        CaptureImage.Scale = (0.25*(1.0-fraction*0.90), 0.25*(1.0-fraction*0.90));
        CaptureImage.Alpha = 1.0-fraction*0.5;
        Alpha = 0.9*(1.0-fraction*0.80);
        if (CaptureTics < CaelumConstants.MAIN_M00_FOOL_CAPTURE_TICS) return;
        bool committed = CaelumMainM00FoolCapture.CommitCapture(CaptureUser, self);
        CancelCapture(!committed);
        // El controlador comprueba después todos los registros del mapa. No
        // borrar esta instancia antes de confirmar la captura persistente.
    }

    override void OnDestroy()
    {
        if (CaptureImage != null) CaptureImage.Destroy();
        Super.OnDestroy();
    }

    Default
    {
        Radius 18;
        Height 88;
        Scale 0.65;
        +SOLID
        +NOGRAVITY
        +NOBLOOD
        RenderStyle "Translucent";
        Alpha 0.9;
    }
    States
    {
    Spawn:
        CTAR A -1 Bright;
        Stop;
    }
}

// Imagen de captura sin colisión, ni inventario, ni autoridad de recompensa.
class CaelumM00FoolCaptureImage : Actor
{
    CaelumM00FoolEssence Anchor;
    override void Tick()
    {
        Super.Tick();
        if (Anchor == null) Destroy();
    }
    Default
    {
        Radius 1;
        Height 1;
        Scale 0.25;
        +NOBLOCKMAP
        +NOGRAVITY
        RenderStyle "Translucent";
    }
    States
    {
    Spawn:
        CFLF A -1 Bright;
        Stop;
    }
}

class CaelumM00CaptureFoolAction : CaelumPalomoDialogueAction
{
    override bool Use(bool pickup)
    {
        return CaelumMainM00FoolCapture.BeginCapture(CaelumPlayer(Owner));
    }
}

class CaelumFoolConversationMenu : CaelumPalomoConversationMenu
{
    override int Init(StrifeDialogueNode node, PlayerInfo user, int reply)
    {
        int result = Super.Init(node, user, reply);
        // El destructor nativo restituye Level.MusicVolume al cerrar por
        // cualquier vía. No modificar la preferencia de volumen del usuario.
        SetMusicVolume(Level.MusicVolume * 0.25);
        return result;
    }
}
