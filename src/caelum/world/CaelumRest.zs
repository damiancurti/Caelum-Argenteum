// Sesión de descanso. El avance rápido reutiliza sus pasos y sus guardas.
class CaelumRestRules : Object
{
    const MODE_WAIT = 1;
    const MODE_SLEEP = 2;
    const STATUS_NONE = 0;
    const STATUS_ACTIVE = 1;
    const STATUS_COMPLETE = 2;
    const STATUS_CANCELLED = 3;
    const STATUS_INTERRUPTED = 4;
    // Balance provisional para la prueba de V4.35, no un valor autoral cerrado.
    const FULL_SLEEP_GAME_HOURS = 8.0;

    static clearscope int DurationTics(int minutes)
    {
        if (minutes != 5 && minutes != 60 && minutes != 240 && minutes != 480) return 0;
        return minutes * CaelumWorldClock.TicsPerHour() / 60;
    }

    static clearscope double RecoverSleep(double value)
    {
        return Min(CaelumConstants.SURVIVAL_MAXIMUM, Max(0.0, value)
            + CaelumConstants.SURVIVAL_MAXIMUM
                / (FULL_SLEEP_GAME_HOURS * CaelumWorldClock.TicsPerHour()));
    }

    static clearscope String ModeKey(int mode)
    {
        return mode == MODE_SLEEP ? "CA_REST_SLEEP" : "CA_REST_WAIT";
    }
}

class CaelumRestState : Inventory
{
    int Status;
    int Mode;
    int RequestedTics;
    int ElapsedTics;
    String OriginMap;
    vector3 OriginPosition;
    int LastHealth;
    String ResultKey;
    bool InputArmed;
    int LastClockDays;
    int LastClockDayTics;
    CaelumRestFurniture Furniture;
    bool UsesFurniture;
    vector3 EntryPosition;
    double EntryAngle;
    double EntryPitch;
    bool HasEntryView;
    vector3 OriginalWorldOffset;
    vector3 AppliedWorldOffset;
    CaelumRestCamera ViewCamera;
    bool ViewInitialized;
    bool PoseFacingFixed;
    bool Untimed;
    int LastUntimedTic;
    bool AutoEating;
    bool AutoDrinking;
    CaelumDiningTable DiningTable;
    double FacingAngle;
    double OriginalPitch;
    double CameraYaw;
    double CameraPitch;

    static CaelumRestState Get(CaelumPlayer user, bool create = false)
    {
        if (user == null) return null;
        let rest = CaelumRestState(user.FindInventory("CaelumRestState"));
        if (rest == null && create)
            rest = CaelumRestState(user.GiveInventoryType("CaelumRestState"));
        return rest;
    }

    static bool IsActive(CaelumPlayer user)
    {
        let rest = Get(user);
        return rest != null && rest.Status == CaelumRestRules.STATUS_ACTIVE;
    }

    static bool IsSleeping(CaelumPlayer user)
    {
        let rest = Get(user);
        return rest != null && rest.Status == CaelumRestRules.STATUS_ACTIVE
            && rest.Mode == CaelumRestRules.MODE_SLEEP;
    }

    static int ResourceFactor(CaelumPlayer user)
    {
        let rest = Get(user);
        if (rest == null || rest.Status != CaelumRestRules.STATUS_ACTIVE
            || !rest.UsesFurniture || rest.OriginMap != level.MapName
            || rest.Furniture == null || !rest.Furniture.SupportsRest(user)) return 1;
        if (user.health <= 0
            || user.CurrentHunger <= CaelumConstants.SURVIVAL_MAXIMUM * CaelumConstants.SURVIVAL_CRITICAL_THRESHOLD
            || user.CurrentThirst <= CaelumConstants.SURVIVAL_MAXIMUM * CaelumConstants.SURVIVAL_CRITICAL_THRESHOLD) return 1;
        return rest.Furniture.ComfortFactor();
    }

    static bool HasPendingTic(CaelumPlayer user)
    {
        let rest = Get(user);
        let clock = CaelumWorldClock.Get(user);
        return rest != null && rest.Status == CaelumRestRules.STATUS_ACTIVE && clock != null
            && (rest.Untimed ? rest.LastUntimedTic!=level.maptime
                : (clock.CompletedDays != rest.LastClockDays || clock.DayTics != rest.LastClockDayTics));
    }

    // Una sola validación de contexto para la oferta, el inicio diferido y
    // cada tic activo. No considera a la propia sesión una actividad ajena.
    static String BlockReason(CaelumPlayer user,bool allowTimelessFurniture=false)
    {
        if (user == null || user.player == null || user.health <= 0
            || user.player.playerstate != PST_LIVE || !user.CharacterCreationComplete
            || user.CreationWizardOpen || (user.player.cheats & CF_PREDICTING)) return "CA_REST_UNAVAILABLE";
        for (int i = 0; i < MAXPLAYERS; i++)
            if (playeringame[i] && players[i].mo != user) return "CA_M01_RETURN_SOLO";
        let active=Get(user);
        if (CaelumWorldCatalogue.IsTimelessMap(level.MapName) && !allowTimelessFurniture
            && !(active!=null && active.Status==CaelumRestRules.STATUS_ACTIVE && active.Untimed && active.Furniture!=null))
            return "CA_REST_TIMELESS";
        if (user.CombatTimeRemaining > 0.0) return "CA_REST_COMBAT";
        if (user.HasActiveConversation() || user.PalomoMerchantMenuOpen || user.CraftingMenuOpen
            || user.CraftingTaskActive || user.EquipmentMenuOpen || user.CombatChannelModeActive
            || user.StaffCastPending || user.WeaponChargeActive || user.WeaponChargedStateActive
            || user.RangedReloadActive || user.CombatBlockModeActive || user.DebugShieldBlocking
            || (user.IsPhysicallyImmobilized() && !(IsSleeping(user)
                && user.PainImmobilizationRemaining <= 0
                && (user.ElementalStatus == null || !user.ElementalStatus.IsLightningStunned())))
            || (user.player.cheats & (CF_TOTALLYFROZEN | CF_FROZEN)))
            return "CA_REST_BUSY";
        if (!user.player.onground || user.WaterLevel != 0
            || user.Vel.X * user.Vel.X + user.Vel.Y * user.Vel.Y > 0.01
            || Abs(user.Vel.Z) > 0.01) return "CA_REST_GROUND";
        if (!user.SurvivalResourcesInitialized || user.DerivedStats == null) return "CA_REST_UNAVAILABLE";
        let record = user.GetPersistentCharacterState(false);
        let clock = CaelumWorldClock.Get(user);
        let journey = CaelumJourneyState.Get(user);
        if (record == null || !record.ProfileCommitted || record.WorldPendingConnection != 0
            || clock == null || (journey != null && journey.Status == CaelumJourneyState.STATUS_DEPARTED))
            return "CA_REST_BUSY";
        if (user.CurrentHunger <= CaelumConstants.SURVIVAL_MAXIMUM * CaelumConstants.SURVIVAL_CRITICAL_THRESHOLD
            || user.CurrentThirst <= CaelumConstants.SURVIVAL_MAXIMUM * CaelumConstants.SURVIVAL_CRITICAL_THRESHOLD)
            return "CA_REST_NEEDS";
        return "";
    }

    static bool Begin(CaelumPlayer user, int mode, int minutes, CaelumRestFurniture furniture = null)
    {
        bool untimed=minutes==0 && furniture!=null && CaelumWorldCatalogue.IsTimelessMap(level.MapName);
        int duration = CaelumRestRules.DurationTics(minutes);
        if ((duration == 0 && !untimed) || (mode != CaelumRestRules.MODE_WAIT && mode != CaelumRestRules.MODE_SLEEP)
            || IsActive(user)) return false;
        String reason = BlockReason(user,untimed);
        if (reason.Length() != 0)
        {
            if (user != null) user.A_Print(StringTable.Localize(reason, false));
            return false;
        }
        if (furniture != null && (furniture.RestMode() != mode || !furniture.CanReach(user)))
        { user.A_Print(StringTable.Localize("CA_REST_FURNITURE_UNAVAILABLE", false)); return false; }
        let rest = Get(user, true);
        if (rest == null) return false;
        vector3 entry = user.Pos;
        double entryAngle = user.Angle;
        double entryPitch = user.Pitch;
        if (furniture != null && !furniture.Seat(user))
        { user.A_Print(StringTable.Localize("CA_REST_FURNITURE_SPACE", false)); return false; }
        rest.Furniture = furniture;
        rest.UsesFurniture = furniture != null;
        rest.EntryPosition = entry;
        rest.EntryAngle = entryAngle;
        rest.EntryPitch = entryPitch;
        rest.HasEntryView = true;
        rest.OriginalWorldOffset = user.WorldOffset;
        rest.AppliedWorldOffset = user.WorldOffset;
        if (furniture != null)
        {
            rest.AppliedWorldOffset += furniture.PoseOffset();
            user.WorldOffset = rest.AppliedWorldOffset;
            user.Angle = furniture.PoseAngle();
        }
        rest.PoseFacingFixed = true;
        rest.ViewInitialized = false;
        rest.ViewCamera = null;
        rest.Mode = mode;
        rest.Untimed=untimed;rest.LastUntimedTic=level.maptime;
        rest.AutoEating=false;rest.AutoDrinking=false;rest.DiningTable=null;
        rest.RequestedTics = duration;
        rest.ElapsedTics = 0;
        rest.OriginMap = level.MapName;
        rest.OriginPosition = user.Pos;
        rest.LastHealth = user.health;
        let clock = CaelumWorldClock.Get(user);
        rest.LastClockDays = clock.CompletedDays;
        rest.LastClockDayTics = clock.DayTics;
        rest.ResultKey = "";
        rest.InputArmed = false;
        rest.Status = CaelumRestRules.STATUS_ACTIVE;
        // Cada búsqueda recibe una etiqueta literal, no un String condicional.
        if (mode == CaelumRestRules.MODE_SLEEP) user.SetState(user.FindState("RestLying"));
        else user.SetState(user.FindState("RestSeated"));
        rest.EnsureView(user);
        user.PersistCharacterState();
        return true;
    }

    void Finish(CaelumPlayer user, int result, String key)
    {
        // Completar, cancelar o interrumpir es terminal para esta sesión.
        if (Status != CaelumRestRules.STATUS_ACTIVE) return;
        CaelumTimeAdvanceState.Halt(user);
        AutoEating=false;AutoDrinking=false;DiningTable=null;
        Status = result;
        ResultKey = key;
        if (user == null) return;
        ReleaseView(user);
        if (UsesFurniture)
        {
            if (user.WorldOffset == AppliedWorldOffset) user.WorldOffset = OriginalWorldOffset;
            if (Furniture != null && OriginMap == level.MapName) Furniture.Release(user, EntryPosition);
        }
        Furniture = null;
        UsesFurniture = false;
        if (user.health > 0 && (user.InStateSequence(user.CurState, user.FindState("RestLying"))
            || user.InStateSequence(user.CurState, user.FindState("RestSeated"))))
            user.SetState(user.SpawnState);
        user.PersistCharacterState();
        if (key.Length() != 0) user.A_Print(StringTable.Localize(key, false));
    }

    static void Interrupt(CaelumPlayer user, String key)
    {
        if (user != null && user.player != null && (user.player.cheats & CF_PREDICTING)) return;
        let rest = Get(user);
        if (rest != null) rest.Finish(user, CaelumRestRules.STATUS_INTERRUPTED, key);
    }

    static void Cancel(CaelumPlayer user)
    {
        if (user != null && user.player != null && (user.player.cheats & CF_PREDICTING)) return;
        let rest = Get(user);
        if (rest != null) rest.Finish(user, CaelumRestRules.STATUS_CANCELLED, "CA_REST_CANCELLED");
    }

    static void Validate(CaelumPlayer user)
    {
        if (user != null && user.player != null && (user.player.cheats & CF_PREDICTING)) return;
        let rest = Get(user);
        if (rest == null || rest.Status != CaelumRestRules.STATUS_ACTIVE) return;
        String reason = rest.OriginMap != level.MapName ? "CA_REST_MOVED" : BlockReason(user);
        if (reason.Length() == 0 && rest.UsesFurniture
            && (rest.Furniture == null || !rest.Furniture.SupportsRest(user)
                || (rest.Furniture.Pos-rest.OriginPosition).Length() > 1))
            reason = "CA_REST_FURNITURE_UNAVAILABLE";
        vector3 displacement = user.Pos-rest.OriginPosition;
        if (reason.Length() == 0 && displacement.Length() > 4.0) reason = "CA_REST_MOVED";
        let clock = CaelumWorldClock.Get(user);
        if (reason.Length() == 0 && clock != null)
        {
            int days = clock.CompletedDays-rest.LastClockDays;
            int tics = clock.DayTics-rest.LastClockDayTics;
            // Se conserva un pulso por tic del reloj. Un salto externo no
            // concede recuperación retroactiva ni un descanso instantáneo.
            if (days < 0 || days > 1 || days*CaelumWorldClock.TicsPerDay()+tics < 0
                || days*CaelumWorldClock.TicsPerDay()+tics > 1) reason = "CA_REST_TIME_CHANGED";
        }
        if (user.health < rest.LastHealth) reason = "CA_REST_DAMAGE";
        if (reason.Length() != 0) rest.Finish(user, CaelumRestRules.STATUS_INTERRUPTED, reason);
    }

    static void HandleInput(CaelumPlayer user)
    {
        if (user == null || user.player == null || (user.player.cheats & CF_PREDICTING)) return;
        Validate(user);
        if (!IsActive(user)) return;
        int cancelButtons = BT_ATTACK | BT_ALTATTACK | BT_USE | BT_JUMP | BT_CROUCH
            | BT_ZOOM | BT_RELOAD | BT_USER1 | BT_USER2 | BT_USER3 | BT_USER4;
        let rest = Get(user);
        if (!rest.InputArmed)
        {
            // Primero soltar la entrada que confirmó el diálogo. No se
            // modifica usedown: el motor sigue recibiendo la liberación real.
            rest.InputArmed = user.player.cmd.forwardmove == 0 && user.player.cmd.sidemove == 0
                && user.player.cmd.upmove == 0 && (user.player.cmd.buttons & cancelButtons) == 0;
            return;
        }
        if (user.player.cmd.forwardmove != 0 || user.player.cmd.sidemove != 0
            || user.player.cmd.upmove != 0 || (user.player.cmd.buttons & cancelButtons))
            Cancel(user);
    }

    static void Advance(CaelumPlayer user)
    {
        if (user == null || user.player == null || (user.player.cheats & CF_PREDICTING)) return;
        Validate(user);
        let rest = Get(user);
        if (rest == null || rest.Status != CaelumRestRules.STATUS_ACTIVE) return;
        if (!rest.PoseFacingFixed)
        {
            // Migración de una sesión 0f activa, sin reiniciar su progreso.
            if (rest.Furniture != null) { rest.FacingAngle = rest.Furniture.PoseAngle(); user.Angle = rest.FacingAngle; }
            rest.PoseFacingFixed = true;
        }
        rest.EnsureView(user);
        if (!HasPendingTic(user)) return;
        let clock = CaelumWorldClock.Get(user);
        rest.LastClockDays = clock.CompletedDays;
        rest.LastClockDayTics = clock.DayTics;
        rest.LastHealth = user.health;
        rest.LastUntimedTic=level.maptime;
        rest.ElapsedTics++;
        if (!rest.Untimed && rest.ElapsedTics >= rest.RequestedTics)
        {
            rest.ElapsedTics = rest.RequestedTics;
            rest.Finish(user, CaelumRestRules.STATUS_COMPLETE, "CA_REST_COMPLETED");
        }
    }

    void EnsureView(CaelumPlayer user)
    {
        if (ViewInitialized || user == null || user.player == null) return;
        ViewInitialized = true;
        // No toma una vista perteneciente a otra escena o sistema.
        if (user.player.camera != null && user.player.camera != user) return;
        ViewCamera = CaelumRestCamera(Actor.Spawn("CaelumRestCamera", user.Pos, NO_REPLACE));
        if (ViewCamera == null) return;
        FacingAngle = user.Angle;
        OriginalPitch = user.Pitch;
        CameraYaw = FacingAngle + (Mode == CaelumRestRules.MODE_SLEEP ? 90 : 35);
        CameraPitch = Mode == CaelumRestRules.MODE_SLEEP ? 10 : 18;
        user.Pitch = 0;
        ViewCamera.Subject = user;
        ViewCamera.UpdateView(self);
        user.player.camera = ViewCamera;
    }

    void ReleaseView(CaelumPlayer user)
    {
        if (ViewCamera != null)
        {
            if (user.player != null && user.player.camera == ViewCamera)
            {
                user.player.camera = user;
                if (user.health > 0 && OriginMap == level.MapName)
                { user.Angle = HasEntryView ? EntryAngle : FacingAngle; user.Pitch = HasEntryView ? EntryPitch : OriginalPitch; }
            }
            ViewCamera.Destroy();
            ViewCamera = null;
        }
    }

    static void UpdateViewInput(CaelumPlayer user)
    {
        if (user == null || user.player == null || (user.player.cheats & CF_PREDICTING)) return;
        let rest = Get(user);
        if (rest == null || rest.Status != CaelumRestRules.STATUS_ACTIVE
            || rest.ViewCamera == null || user.player.camera != rest.ViewCamera) return;
        // El ratón/giro orbita la cámara; el cuerpo conserva su orientación
        // sobre la silla/cama. Las acciones siguen cancelando desde HandleInput.
        rest.CameraYaw += deltaangle(rest.FacingAngle, user.Angle);
        rest.CameraPitch = Clamp(rest.CameraPitch + user.Pitch, -5, 60);
        user.Angle = rest.FacingAngle;
        user.Pitch = 0;
        rest.ViewCamera.UpdateView(rest);
    }

    static void Report(CaelumPlayer user)
    {
        let rest = Get(user);
        Console.Printf("[Caelum 4.35.0h] Descanso: registro=%d mapa=%s factor=%d", rest != null, level.MapName, ResourceFactor(user));
        if (rest == null) return;
        Console.Printf("Estado=%d modo=%d transcurrido=%d/%d tics origen=%s resultado=%s",
            rest.Status, rest.Mode, rest.ElapsedTics, rest.RequestedTics, rest.OriginMap, rest.ResultKey);
        Console.Printf("Mueble=%d cámara propia=%d posición=(%.1f,%.1f,%.1f)",
            rest.UsesFurniture, rest.ViewCamera != null && user.player.camera == rest.ViewCamera,
            user.Pos.X, user.Pos.Y, user.Pos.Z);
        Console.Printf("Sueño=%.4f hambre=%.4f sed=%.4f vida=%d. Recuperar todo el Sueño: %.0f h de juego (provisional).",
            user.CurrentSleep, user.CurrentHunger, user.CurrentThirst, user.health, CaelumRestRules.FULL_SLEEP_GAME_HOURS);
    }

    Default
    {
        Inventory.Amount 1;
        Inventory.MaxAmount 1;
        Inventory.InterHubAmount 1;
        +INVENTORY.UNDROPPABLE
        +INVENTORY.UNCLEARABLE
        +INVENTORY.KEEPDEPLETED
        -INVENTORY.INVBAR
    }
    States { Spawn: TNT1 A -1; Stop; }
}
