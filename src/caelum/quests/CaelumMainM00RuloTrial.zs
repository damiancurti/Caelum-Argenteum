// Entrenamiento de Rulo. El registro viajero conserva prácticas y préstamos;
// el Toro y las puertas conservan el estado físico del intento al guardar.
class CaelumMainM00RuloTrial : Object play
{
    static CaelumM00TrainingDummy EnsurePracticeTarget()
    {
        if(level.MapName!="MAP01")return null;
        let it=ThinkerIterator.Create("CaelumM00TrainingDummy");
        let dummy=CaelumM00TrainingDummy(it.Next());
        if(dummy!=null)return dummy;
        dummy=CaelumM00TrainingDummy(Actor.Spawn("CaelumM00TrainingDummy",(-290,480,0),NO_REPLACE));
        if(dummy!=null && (!dummy.TestMobjLocation() || Abs(dummy.FloorZ)>1))
        {dummy.Destroy();return null;}
        return dummy;
    }

    static bool IsActive(CaelumPlayer user)
    {
        if (user == null || user.player == null || user.health <= 0
            || level.MapName != "MAP01" || !user.CharacterCreationComplete
            || user.CreationWizardOpen || (user.player.cheats & CF_PREDICTING)) return false;
        let r = user.GetPersistentCharacterState(false);
        return r != null && r.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_RULO_STARTED)
            && !r.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_RULO_COMPLETE);
    }

    static bool NearPractice(CaelumPlayer user)
    {
        return IsActive(user) && user.Pos.X > -460 && user.Pos.X < -130
            && user.Pos.Y > 205 && user.Pos.Y < 530 && Abs(user.Pos.Z) < 48;
    }

    static bool InArena(Actor user)
    {
        return user != null && user.Pos.X > -2440 && user.Pos.X < -1860
            && Abs(user.Pos.Y) < 294 && Abs(user.Pos.Z) < 64;
    }

    static CaelumM00Bull GetBull()
    {
        let controller = CaelumMainM00QuestController(EventHandler.Find("CaelumMainM00QuestController"));
        return controller != null ? controller.TrialBull : null;
    }

    static void GatherParty(CaelumPlayer user, CaelumM00Bull bull)
    {
        let it = ThinkerIterator.Create("CaelumAnchoredResident"); CaelumAnchoredResident resident;
        while ((resident = CaelumAnchoredResident(it.Next())) != null)
            if (resident.StoryAnchored) resident.JoinRuloParty(user, bull);
        if (bull != null) bull.RuloPartyPrepared = true;
    }

    static bool IsPartyMember(Actor member, CaelumPlayer user)
    {
        let resident = CaelumAnchoredResident(member);
        return resident != null && resident.RuloPartyMode != 0 && resident.RuloPartyTraveler == user;
    }

    static int PracticeFlag(int slot)
    {
        return slot < 4 ? CaelumConstants.MAIN_M00_FLAG_COMBAT_PRIMARY_USED + slot
            : slot == 4 ? CaelumConstants.MAIN_M00_FLAG_COMBAT_AIR_SPENT
            : CaelumConstants.MAIN_M00_FLAG_COMBAT_AIR_RECOVERED;
    }

    static void Sync(CaelumPlayer user)
    {
        if (user == null) return;
        let r = user.GetPersistentCharacterState(false);
        if (r == null) return;
        user.MainM00RuloPracticeSnapshot = 0;
        for (int n = 0; n < 6; n++)
        {
            user.JournalMainM00RuloPracticeDone[n] = r.HasMainM00Flag(PracticeFlag(n));
            if (user.JournalMainM00RuloPracticeDone[n]) user.MainM00RuloPracticeSnapshot++;
        }
        user.MainM00BullDefeatedSnapshot = r.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_BULL_DEFEATED);
        user.MainM00BullStartedSnapshot = r.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_BULL_STARTED);
        user.MainM00SilverKeySnapshot = user.FindInventory("CaelumSilverKey") != null;
        user.SetPalomoDialogueToken("CaelumM00RuloStartedToken", r.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_RULO_STARTED));
        user.SetPalomoDialogueToken("CaelumM00RuloPracticeToken", user.MainM00RuloPracticeSnapshot == 6);
        user.SetPalomoDialogueToken("CaelumM00BullDefeatedToken", user.MainM00BullDefeatedSnapshot);
        user.SetPalomoDialogueToken("CaelumM00RuloCompleteToken", r.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_RULO_COMPLETE));
        user.RefreshSocialJournalSnapshot(); user.PersistCharacterState();
    }

    static void RecordPractice(CaelumPlayer user, int flag)
    {
        if (!NearPractice(user)) return;
        let r = user.GetPersistentCharacterState(true);
        if (!r.SetMainM00Flag(flag)) return;
        Sync(user);
        CaelumMainM00MagicTrial.Feedback(user, user.MainM00RuloPracticeSnapshot == 6
            ? "CA_M01_RULO_PRACTICE_READY" : "CA_M01_RULO_PRACTICE_DONE");
    }

    static void RecordHit(CaelumPlayer user, bool secondary, bool charged, bool mobile = false, bool melee = true)
    {
        if (!NearPractice(user) || user.WeaponModel == null) return;
        RecordPractice(user, secondary ? CaelumConstants.MAIN_M00_FLAG_COMBAT_SECONDARY_USED
            : CaelumConstants.MAIN_M00_FLAG_COMBAT_PRIMARY_USED);
        if (charged || mobile) RecordPractice(user, CaelumConstants.MAIN_M00_FLAG_COMBAT_CHARGED_USED);
        int weapon = CaelumCraftingRules.GetCatalogueWeaponForPlayableType(user.WeaponModel.WeaponType);
        // La lanza carece de AltFire dañino: un golpe avanzando es su maniobra.
        if (melee && weapon >= 0 && !user.IsRangedWeaponType(user.WeaponModel.WeaponType)
            && !user.WeaponModel.IsMagicalType(user.WeaponModel.WeaponType)
            && CaelumWeaponCatalogue.GetSecondaryDamage(weapon) <= 0
            && user.player.cmd.forwardmove != 0 && user.Vel.XY.Length() > 0.25)
            RecordPractice(user, CaelumConstants.MAIN_M00_FLAG_COMBAT_SECONDARY_USED);
    }

    static void RecordAim(CaelumPlayer user)
    {
        RecordPractice(user, CaelumConstants.MAIN_M00_FLAG_COMBAT_SECONDARY_USED);
        RecordPractice(user, CaelumConstants.MAIN_M00_FLAG_COMBAT_DEFENSE_USED);
    }

    static void ConsumeLoanRound(CaelumPlayer user, int ammoType)
    {
        let r = user.GetPersistentCharacterState(false);
        if (r != null && r.MainM00AmmoLoanType == ammoType)
            r.MainM00AmmoLoanRemaining = Max(0, r.MainM00AmmoLoanRemaining - 1);
    }

    static void ReturnAmmo(CaelumPlayer user)
    {
        let r = user.GetPersistentCharacterState(false);
        if (r == null || r.MainM00AmmoLoanRemaining <= 0) return;
        let ammo = user.FindNativeAmmunition(r.MainM00AmmoLoanType);
        if (ammo != null) ammo.Amount = Max(0, ammo.Amount - r.MainM00AmmoLoanRemaining);
        r.MainM00AmmoLoanRemaining = 0;
        for (int kind = 0; kind < CaelumConstants.WEAPON_TYPE_COUNT; kind++)
            if (user.IsRangedWeaponType(kind))
            {
                let stack = user.FindNativeAmmunition(user.GetRangedAmmoType(kind));
                user.SetRangedMagazineCount(kind, Min(user.GetRangedMagazineCount(kind), stack != null ? stack.Amount : 0));
            }
        user.OnNativeInventoryChanged();
    }

    static void Prepare(CaelumPlayer user)
    {
        if (!IsActive(user) || user.DerivedStats == null || user.WeaponModel == null) return;
        let r = user.GetPersistentCharacterState(true);
        user.CancelPendingStaffCast(false); user.CancelWeaponCharge();
        user.CancelCombatBlockMode(); user.CancelRangedReload(); user.CancelRangedAim();
        user.health = user.CaelumMaximumHealth; user.player.health = user.health;
        user.CurrentAir = user.DerivedStats.MaximumAir;
        user.CurrentAnima = user.DerivedStats.MaximumAnima;
        user.CurrentLucidity = CaelumConstants.MAXIMUM_LUCIDITY;
        user.PainImmobilizationRemaining = 0; user.LucidityPhysicalStunRemaining = 0;
        user.ElementalStatus = new("CaelumElementalStatus");
        user.UpdateAirStateEffects();
        // Rulo acondiciona el arma inicial; conserva su ItemId, tier y esencia.
        let first = user.FindNativeEquipmentItemById(r.MainM00StarterWeaponId);
        if (first != null && !first.InMagicBox)
        {
            first.Durability = user.WeaponModel.GetMaximumDurabilityFor(first.ItemType, first.Tier, first.EquipmentSize);
            first.Equipped = true; user.ActivateExactEquippedWeapon(first);
        }
        PrepareAmmunition(user);
        r.MainM00PracticeLastAir = user.CurrentAir;
        r.MainM00PracticeLowestAir = user.CurrentAir;
        r.MainM00PracticeLastPosition = user.Pos;
        user.OnNativeInventoryChanged(); Sync(user);
    }

    static void PrepareAmmunition(CaelumPlayer user)
    {
        let r = user.GetPersistentCharacterState(true);
        if (user.IsRangedWeaponType(user.WeaponModel.WeaponType))
        {
            int kind = user.GetRangedAmmoType(user.WeaponModel.WeaponType);
            if (r.MainM00AmmoLoanRemaining > 0 && r.MainM00AmmoLoanType != kind) ReturnAmmo(user);
            int needed = Max(0, 24 - r.MainM00AmmoLoanRemaining);
            user.RefreshCarriedInventorySummary();
            if (needed > 0 && user.CanAddWeightToPersonalInventory(needed * user.GetAmmunitionUnitWeight(kind)))
            {
                let ammo = user.FindNativeAmmunition(kind);
                if (ammo == null)
                {
                    ammo = Inventory(Actor.Spawn(user.GetAmmunitionClassName(kind), user.Pos, NO_REPLACE));
                    if (ammo != null) { ammo.Amount = needed; ammo.AttachToOwner(user); }
                }
                else ammo.Amount += needed;
                if (ammo != null) { r.MainM00AmmoLoanType = kind; r.MainM00AmmoLoanRemaining += needed; }
            }
            else if (needed > 0) CaelumMainM00MagicTrial.Feedback(user, "CA_M01_RULO_AMMO_WEIGHT", true);
        }
        user.OnNativeInventoryChanged();
    }

    static bool Begin(CaelumPlayer user)
    {
        if (user == null || user.player == null || user.health <= 0 || level.MapName != "MAP01"
            || user.CreationWizardOpen || !user.CharacterCreationComplete
            || !(user.player.ConversationNPC is "CaelumRulo")) return false;
        let r = user.GetPersistentCharacterState(true);
        if (!r.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_RONNIE_COMPLETE)
            || !r.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_CAELLA_COMPLETE)
            || !r.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_ARGENTO_COMPLETE)
            || r.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_RULO_COMPLETE)) return false;
        if (!r.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_RULO_STARTED))
        {
            if (!r.TryAdvanceMainM00State(CaelumConstants.MAIN_M00_STATE_WEAPON_READY,
                CaelumConstants.MAIN_M00_STATE_RULO_ACTIVE)) return false;
            r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_RULO_STARTED);
            r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_HEARD_RULO_QUOTE);
            r.SetQuestObjectiveProgress(CaelumConstants.QUEST_MAIN_M00_THE_FOOL,
                CaelumConstants.MAIN_M00_OBJECTIVE_DEFEAT_BULL, 0, 1);
        }
        Prepare(user); Sync(user); return true;
    }

    static bool Complete(CaelumPlayer user)
    {
        if (!IsActive(user) || !(user.player.ConversationNPC is "CaelumRulo")) return false;
        let r = user.GetPersistentCharacterState(true);
        if (!r.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_BULL_DEFEATED)
            || !r.TryAdvanceMainM00State(CaelumConstants.MAIN_M00_STATE_RULO_ACTIVE,
                CaelumConstants.MAIN_M00_STATE_RULO_COMPLETE)) return false;
        r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_RULO_COMPLETE);
        r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_PALOMO_UPSTAIRS_ENABLED);
        r.SetQuestObjectiveProgress(CaelumConstants.QUEST_MAIN_M00_THE_FOOL,
            CaelumConstants.MAIN_M00_OBJECTIVE_DEFEAT_BULL, 1, 1);
        ReturnAmmo(user); Sync(user); return true;
    }

    static void SetArenaDoors(bool locked, bool open = false)
    {
        let it = ThinkerIterator.Create("CaelumSlidingDoorLeaf"); CaelumSlidingDoorLeaf leaf;
        while ((leaf = CaelumSlidingDoorLeaf(it.Next())) != null)
            if (leaf.args[0] == 806)
            {
                leaf.RuloArenaLocked = locked;
                if (locked) { leaf.DoorRequested = false; leaf.HoldTimer = 0; }
                else if (open) { leaf.DoorRequested = true; leaf.HoldTimer = 105; }
            }
    }

    static bool PreventDefeat(CaelumPlayer user)
    {
        // Die recibe salud <= 0; aquí no se usa IsActive por ese motivo.
        if (user == null || user.player == null || level.MapName != "MAP01") return false;
        let r = user.GetPersistentCharacterState(false); let bull = GetBull();
        if (r == null || bull == null || bull.TrialFighter != user || !bull.TrialReleased
            || bull.health <= 0 || r.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_BULL_DEFEATED)) return false;
        if (!r.MainM00BullResetPending) r.MainM00BullFailures++;
        r.MainM00BullResetPending = true;
        user.health = 1; user.player.health = 1;
        user.Vel = (0,0,0); bull.StopBullCharge();
        user.A_SetBlend("Black", 0.8, TICRATE);
        return true;
    }

    static void ResetFight(CaelumPlayer user, CaelumM00Bull bull, bool retry = true)
    {
        let r = user.GetPersistentCharacterState(true);
        r.MainM00BullResetPending = false;
        // Retirar proyectiles del intento evita impactos tardíos y botín al
        // reiniciar. El arma nativa permanece en el inventario del personaje.
        let missiles = ThinkerIterator.Create("CaelumActorProjectile"); CaelumActorProjectile missile;
        while ((missile = CaelumActorProjectile(missiles.Next())) != null)
            if (missile.Target == user || missile.Target == bull || IsPartyMember(missile.Target, user)) missile.Destroy();
        user.SetOrigin((-1900,0,0), false); user.Vel = (0,0,0); user.Angle = 180; user.Pitch = 0;
        Prepare(user);
        bull.ResetAttempt(user);
        GatherParty(user, bull);
        CaelumMainM00MagicTrial.Feedback(user, retry ? "CA_M01_RULO_RETRY" : "CA_M01_RULO_FIGHT_BEGIN");
    }

    static void Update(CaelumPlayer user)
    {
        if (user == null) return;
        let r = user.GetPersistentCharacterState(false); if (r == null) return;
        if (level.MapName != "MAP01" || r.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_RULO_COMPLETE))
        { ReturnAmmo(user); return; }
        if (!IsActive(user)) return;
        let world = CaelumMainM00QuestController(EventHandler.Find("CaelumMainM00QuestController"));
        if (world != null && !world.RuloWorldPrepared)
            world.RuloWorldPrepared = EnsurePracticeTarget() != null;
        if (NearPractice(user))
        {
            if (user.CurrentAir < r.MainM00PracticeLastAir - 0.01)
            {
                RecordPractice(user, CaelumConstants.MAIN_M00_FLAG_COMBAT_AIR_SPENT);
                r.MainM00PracticeLowestAir = user.CurrentAir;
            }
            else if (r.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_COMBAT_AIR_SPENT)
                && user.CurrentAir > r.MainM00PracticeLowestAir + 0.01)
                RecordPractice(user, CaelumConstants.MAIN_M00_FLAG_COMBAT_AIR_RECOVERED);
            Vector3 moved = user.Pos - r.MainM00PracticeLastPosition;
            if (user.player.cmd.sidemove != 0 && moved.Length() < 20)
            {
                r.MainM00PracticeSideDistance += Abs(moved.X * -Sin(user.Angle) + moved.Y * Cos(user.Angle));
                if (r.MainM00PracticeSideDistance >= 48)
                    RecordPractice(user, CaelumConstants.MAIN_M00_FLAG_COMBAT_DEFENSE_USED);
            }
        }
        r.MainM00PracticeLastAir = user.CurrentAir; r.MainM00PracticeLastPosition = user.Pos;
        let bull = GetBull();
        if (r.MainM00BullResetPending && bull != null) ResetFight(user, bull);
        if (r.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_BULL_DEFEATED))
        {
            // También actualizar una victoria 0p que aún espera la charla final.
            let it = ThinkerIterator.Create("CaelumRulo"); let rulo = CaelumRulo(it.Next());
            if (rulo != null && rulo.StoryAnchored && rulo.RuloPartyMode == 0) GatherParty(user, bull);
            if (level.time % TICRATE == 0) Sync(user);
            return;
        }
        if (bull == null || bull.health <= 0) return;
        if (bull.TrialFighter == null)
        {
            // Migra el Toro dormido de 0n/0o sin recrearlo ni soltar cuero.
            bull.TrialReleased = false;
            if (InArena(user) && user.FindInventory("CaelumSilverKey") != null
                && CaelumMainM00SocialDialogue.CanReceiveSilverKey(user))
            {
                r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_BULL_STARTED);
                ResetFight(user, bull, false); SetArenaDoors(true); Sync(user);
            }
        }
        else if (bull.TrialFighter == user)
        {
            // Un guardado 0p en combate conserva el daño al Toro y el registro.
            if (!bull.RuloPartyPrepared)
            {
                bull.StopBullCharge(); bull.TrialGraceTicks = 2 * TICRATE;
                bull.SetStateLabel("TrialIdle");
                GatherParty(user, bull);
                CaelumMainM00MagicTrial.Feedback(user, "CA_M01_RULO_PARTY_JOINED");
            }
            SetArenaDoors(true);
            if (user.IsRangedWeaponType(user.WeaponModel.WeaponType))
            {
                let ammo = user.FindNativeAmmunition(user.GetRangedAmmoType(user.WeaponModel.WeaponType));
                if (r.MainM00AmmoLoanRemaining == 0 || ammo == null || ammo.Amount == 0)
                    PrepareAmmunition(user);
            }
            if (!InArena(user)) { user.SetOrigin((-1900,0,0), false); user.Vel = (0,0,0); }
        }
        if (level.time % TICRATE == 0) Sync(user);
    }
}

class CaelumM00TrainingDummy : CaelumTrainingDummy
{
    Default { +CANPASS }
    override int DamageMobj(Actor inflictor, Actor source, int damage, Name mod, int flags, double angle)
    {
        let shot = CaelumActorProjectile(inflictor);
        if (shot != null && damage > 0)
            CaelumMainM00RuloTrial.RecordHit(CaelumPlayer(source),
                shot.CaelumSecondaryElement || shot is "CaelumJavelinProjectile", shot.MainM00ChargedPractice, shot.MainM00MobilePractice, false);
        // No produce desgaste, adrenalina ni botín por golpear un blanco.
        return 0;
    }
}
class CaelumM00RuloStartedToken : CaelumPalomoDialogueMarker {}
class CaelumM00RuloPracticeToken : CaelumPalomoDialogueMarker {}
class CaelumM00BullDefeatedToken : CaelumPalomoDialogueMarker {}
class CaelumM00RuloCompleteToken : CaelumPalomoDialogueMarker {}
class CaelumM00StartRuloAction : CaelumPalomoDialogueAction
{
    override bool Use(bool pickup) { return CaelumMainM00RuloTrial.Begin(CaelumPlayer(Owner)); }
}
class CaelumM00FinishRuloAction : CaelumPalomoDialogueAction
{
    override bool Use(bool pickup) { return CaelumMainM00RuloTrial.Complete(CaelumPlayer(Owner)); }
}
