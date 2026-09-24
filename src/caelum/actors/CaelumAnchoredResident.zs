// Contrato común para los cuatro residentes narrativos de MAP01. Las
// invocaciones de depuración sin args[0] conservan su IA de combate anterior.
class CaelumAnchoredResident : CaelumCombatActor abstract
{
    Vector3 StoryHome;
    double StoryHomeAngle;
    bool StoryAnchored;
    bool StoryReturningHome;

    // Estado del mismo residente durante la prueba; serialización nativa.
    // 0: dormitorio, 1: preparación, 2: combate, 3: cierre junto a Rulo.
    int RuloPartyMode;
    bool RuloPartyDowned;
    CaelumPlayer RuloPartyTraveler;
    CaelumM00Bull RuloPartyBull;

    // Estado de escolta de los prisioneros de MAP02. Los residentes de la
    // mansiÃ³n conservan -1 y nunca entran en esta mÃ¡quina.
    int EscortPrisonerId;
    bool EscortPrisonerPort;
    CaelumPlayer EscortPrisonerLeader;
    int EscortPrisonerThreatScanTics;

    bool IsProtectedStoryResident()
    {
        return StoryAnchored && level.MapName == "MAP01";
    }

    void ClearStoryCombatState()
    {
        // A_Chase marca INCOMBAT al disparar. StartConversation lo rechaza
        // incluso con salud completa; no basta con soltar el Target.
        bInCombat = false;
        bJustHit = false;
        bJustAttacked = false;
        Target = null;
        LastEnemy = null;
        // Reparar un cierre interrumpido sin quitarle la conversación a otro
        // jugador que todavía esté hablando con esta misma instancia.
        bool speaking = false;
        for (int n = 0; n < MAXPLAYERS; n++)
            if (playeringame[n] && players[n].ConversationNPC == self)
                speaking = true;
        if (!speaking) bInConversation = false;
    }

    void BecomeInertPrisoner()
    {
        // Aparición visual de MAP02: la identidad es estable, pero el prisionero
        // no hereda anclaje, conversación, inventario ni protección narrativa.
        // #14 implementará escolta/combate; aquí queda amistoso e invulnerable
        // y no cuenta como baja.
        StoryAnchored = false;
        bFriendly = true;
        bInvulnerable = true;
        bCountKill = false;
        Target = null;
        LastEnemy = null;
        Vel = (0,0,0);
    }

    bool IsEscortPrisoner()
    {
        return EscortPrisonerId >= 0;
    }

    CaelumPlayer GetEscortOwnerPlayer()
    {
        for (int n = 0; n < MAXPLAYERS; n++)
            if (playeringame[n] && players[n].mo != null)
                return CaelumPlayer(players[n].mo);
        return null;
    }

    void BecomePrisoner(int prisonerId)
    {
        EscortPrisonerId = prisonerId;
        StoryAnchored = false;
        StoryReturningHome = false;
        RuloPartyMode = 0; RuloPartyBull = null; RuloPartyTraveler = null;
        bFriendly = true;
        bCountKill = false;
        bShootable = true;
        bSolid = true;
        Target = null; LastEnemy = null; Vel = (0,0,0);

        CaelumPlayer owner = GetEscortOwnerPlayer();
        int rescueState = owner == null
            ? CaelumConstants.PRISONER_STATE_CAPTIVE
            : owner.GetPrisonerRescueState(prisonerId);

        if (level.MapName == "MAP06")
        {
            if (rescueState != CaelumConstants.PRISONER_STATE_EXTRACTED)
            {
                Destroy();
                return;
            }
            EscortPrisonerPort = true;
            bInvulnerable = true;
            SetStateLabel("Spawn");
            return;
        }

        if (rescueState == CaelumConstants.PRISONER_STATE_EXTRACTED
            || rescueState == CaelumConstants.PRISONER_STATE_DEAD)
        {
            Destroy();
            return;
        }
        if (rescueState == CaelumConstants.PRISONER_STATE_FOLLOWING)
        {
            BeginEscortFollow();
            return;
        }
        bInvulnerable = true;
        SetStateLabel("Spawn");
    }

    void BeginEscortFollow()
    {
        EscortPrisonerPort = false;
        bFriendly = true;
        bInvulnerable = false;
        bShootable = true;
        bSolid = true;
        bCountKill = false;
        Target = null; LastEnemy = null;
        ClearStoryCombatState();
        EscortPrisonerLeader = GetEscortOwnerPlayer();
        SetStateLabel("EscortFollow");
    }

    void ReleaseEscortPrisoner(CaelumPlayer user)
    {
        if (!IsEscortPrisoner() || user == null || EscortPrisonerPort)
            return;
        CaelumPlayer owner = GetEscortOwnerPlayer();
        int state = owner == null
            ? CaelumConstants.PRISONER_STATE_CAPTIVE
            : owner.GetPrisonerRescueState(EscortPrisonerId);
        if (state == CaelumConstants.PRISONER_STATE_CAPTIVE && owner != null)
            owner.SetPlayerPrisonerRescueState(
                EscortPrisonerId, CaelumConstants.PRISONER_STATE_FOLLOWING);
        EscortPrisonerLeader = user;
        BeginEscortFollow();
        CaelumNotifications.Notify(user,
            StringTable.Localize("CA_PRISONER_FREED", false));
    }

    void MarkEscortPrisonerExtracted(CaelumPlayer owner)
    {
        if (!IsEscortPrisoner() || EscortPrisonerPort || owner == null) return;
        if (owner.GetPrisonerRescueState(EscortPrisonerId)
            == CaelumConstants.PRISONER_STATE_FOLLOWING)
        {
            owner.SetPlayerPrisonerRescueState(
                EscortPrisonerId, CaelumConstants.PRISONER_STATE_EXTRACTED);
        }
        CaelumNotifications.Notify(owner,
            StringTable.Localize("CA_PRISONER_EXTRACTED", false));
        Destroy();
    }

    bool AtPrisonerExtraction()
    {
        Actor marker = ActorIterator.Create(
            CaelumConstants.PRISONER_EXTRACTION_TID,
            "CaelumMazeLayoutMarker").Next();
        return marker != null && Distance2D(marker)
            <= CaelumConstants.PRISONER_EXTRACTION_RADIUS;
    }

    bool IsNearMap02Boss()
    {
        if (level.MapName != "MAP02") return false;
        Actor boss = ActorIterator.Create(43799, "CaelumZupayColossus").Next();
        if (boss == null || boss.health <= 0) return false;
        return Distance2D(boss)
            <= CaelumConstants.PRISONER_BOSS_STAYBACK_RADIUS;
    }

    Actor FindEscortThreat()
    {
        BlockThingsIterator iterator = BlockThingsIterator.Create(
            self, CaelumConstants.PRISONER_THREAT_RADIUS);
        while (iterator.Next())
        {
            Actor candidate = iterator.thing;
            if (candidate == null || candidate == self
                || candidate.health <= 0 || !candidate.bShootable
                || !candidate.bIsMonster || IsFriend(candidate)
                || candidate is "CaelumZupayColossus")
            { continue; }
            if (candidate.Distance2D(self)
                > CaelumConstants.PRISONER_THREAT_RADIUS
                || !CheckSight(candidate))
            { continue; }
            return candidate;
        }
        return null;
    }

    void InterruptEscortConversation()
    {
        bool speaking = false;
        for (int n = 0; n < MAXPLAYERS; n++)
        {
            if (playeringame[n] && players[n].ConversationNPC == self)
            {
                players[n].ConversationNPC = null;
                speaking = true;
            }
        }
        if (!speaking) bInConversation = false;
    }

    void UpdateEscortPrisoner()
    {
        if (health <= 0 || EscortPrisonerPort) return;

        if (bInConversation)
        {
            Actor threat = FindEscortThreat();
            if (threat != null)
            {
                InterruptEscortConversation();
            }
            else
            {
                Vel = (0,0,0);
                Target = null;
                ClearStoryCombatState();
                return;
            }
        }

        CaelumPlayer owner = GetEscortOwnerPlayer();
        if (owner == null || owner.health <= 0)
        {
            Vel = (0,0,0);
            Target = null;
            ClearStoryCombatState();
            return;
        }

        if (IsNearMap02Boss())
        {
            Target = null;
            ClearStoryCombatState();
            FleeEscortBoss();
            return;
        }

        if (AtPrisonerExtraction())
        {
            MarkEscortPrisonerExtracted(owner);
            return;
        }

        Actor threat = FindEscortThreat();
        if (threat != null)
        {
            ClearStoryCombatState();
            Target = threat;
            bInvulnerable = false;
            State seeState = FindState("See");
            if (!InStateSequence(CurState, seeState)) { SetState(seeState); }
            return;
        }

        EscortPrisonerLeader = owner;
        Target = null;
        ClearStoryCombatState();
        State followState = FindState("EscortFollow");
        if (!InStateSequence(CurState, followState)) { SetState(followState); }
    }

    void FleeEscortBoss()
    {
        Actor boss = ActorIterator.Create(
            43799, "CaelumZupayColossus").Next();
        if (boss == null) { Vel = (0,0,0); return; }
        Vector2 away = Pos.XY - boss.Pos.XY;
        double awayDistance = away.Length();
        if (awayDistance <= 0.001) { Vel = (0,0,0); return; }
        Angle = VectorAngle(away.X, away.Y);
        double speed = Max(0.0, CombatBaseSpeed
            * CaelumConstants.GZDOOM_BASE_MAX_RUN_SPEED
            / CaelumConstants.GZDOOM_BASE_MAX_WALK_SPEED);
        Vel.X = Cos(Angle) * speed;
        Vel.Y = Sin(Angle) * speed;
    }
    bool UseEscortPrisoner(CaelumPlayer user)
    {
        if (user == null || user.player == null) { return false; }
        return CaelumPrisonerRescue.OpenDialogue(user, self);
    }
    void DownRuloPartyMember()
    {
        health = 1; RuloPartyDowned = true; Target = null; Vel = (0,0,0);
        bInvulnerable = true; bShootable = false; bSolid = false;
        SetStateLabel("CrouchIdle");
    }

    void EnsureStorySurvival()
    {
        if (!IsProtectedStoryResident()) return;
        // También se ejecuta al cargar: los flags nativos se serializan y un
        // guardado anterior todavía no tiene BUDDHA.
        bBuddha = true;
        if (health > 0 && !bCorpse && !bKilled) return;
        // Recuperar el actor original si una partida anterior sí registró
        // muerte. Revive restaura flags/veneno, pero no la altura del cuerpo.
        int monsterTotal = level.total_monsters;
        Revive();
        // Es la reparación de una instancia narrativa, no un monstruo nuevo.
        level.total_monsters = monsterTotal;
        let profile = GetDefaultByType(GetClass());
        A_SetSize(profile.Radius, profile.Height);
        bBuddha = true; bFriendly = true; bInvulnerable = true;
        RestoreRuloPartyHealth();
        if (RuloPartyMode == 2 && RuloPartyBull != null && RuloPartyBull.health > 0)
            DownRuloPartyMember();
        else SetStateLabel("Spawn");
    }

    Vector3 GetRuloPartyPosition()
    {
        if (self is "CaelumRulo") return (-2010,-155,0);
        if (self is "CaelumRonnie") return (-2010,155,0);
        if (self is "CaelumArgento") return (-1900,-220,0);
        return (-1900,220,0);
    }

    void RestoreRuloPartyHealth()
    {
        health = CombatMaximumHealth;
        CurrentCombatAir = MaximumCombatAir;
        CurrentCombatAnima = MaximumCombatAnima;
        CurrentCombatLucidity = CaelumConstants.MAXIMUM_LUCIDITY;
        CombatLucidityPhysicalStunRemaining = 0;
        ElementalStatus = new("CaelumElementalStatus");
        for (int slot = 0; CombatArmor != null && slot < CaelumConstants.ARMOR_SLOT_COUNT; slot++)
            CombatArmor.Durability[slot] = CombatArmor.GetMaximumDurability(slot);
        RuloPartyDowned = false; bSolid = true; bShootable = true;
        ClearStoryCombatState();
        UpdateCombatHealthEffects();
    }

    void JoinRuloParty(CaelumPlayer traveler, CaelumM00Bull bull)
    {
        RuloPartyTraveler = traveler; RuloPartyBull = bull;
        RuloPartyMode = 1; StoryReturningHome = false;
        RestoreRuloPartyHealth();
        // Reunión durante la preparación del encuentro; no crear dobles.
        SetOrigin(GetRuloPartyPosition(), false); Vel = (0,0,0); Angle = 180;
        bFriendly = true; bInvulnerable = true; Target = null;
        SetStateLabel("Spawn");
    }

    bool IsRuloPartyFighting()
    {
        return RuloPartyMode == 2 && !RuloPartyDowned && RuloPartyBull != null
            && RuloPartyBull.health > 0 && RuloPartyBull.TrialGraceTicks == 0;
    }

    override int DamageMobj(Actor inflictor, Actor source, int damage, Name mod, int flags, double angle)
    {
        if (IsProtectedStoryResident()) bBuddha = true;
        if (RuloPartyMode != 0 && (!IsRuloPartyFighting()
            || (source != RuloPartyBull && inflictor != RuloPartyBull))) return 0;
        int received = Super.DamageMobj(inflictor, source, damage, mod, flags, angle);
        if (IsProtectedStoryResident() && RuloPartyMode == 2 && health <= 1)
            DownRuloPartyMember();
        return received;
    }

    override void Die(Actor source, Actor inflictor, int dmgflags, Name MeansOfDeath)
    {
        if (IsProtectedStoryResident())
        {
            // Respaldo para daño forzado/telefrag, que omite BUDDHA nativo.
            // No llamar a Die del motor: no cadáver, drop ni evento de muerte.
            health = 1;
            if (RuloPartyMode == 2 && RuloPartyBull != null && RuloPartyBull.health > 0)
                DownRuloPartyMember();
            else
            {
                bInvulnerable = true; bSolid = true; bShootable = true;
                ClearStoryCombatState(); SetStateLabel("Spawn");
            }
            return;
        }
        if (IsEscortPrisoner() && !EscortPrisonerPort)
        {
            CaelumPlayer owner = GetEscortOwnerPlayer();
            if (owner != null && owner.GetPrisonerRescueState(EscortPrisonerId)
                == CaelumConstants.PRISONER_STATE_FOLLOWING)
            {
                owner.SetPlayerPrisonerRescueState(
                    EscortPrisonerId, CaelumConstants.PRISONER_STATE_DEAD);
            }
        }
        Super.Die(source, inflictor, dmgflags, MeansOfDeath);
    }

    void UpdateRuloParty()
    {
        bFriendly = true;
        if (RuloPartyBull != null && RuloPartyBull.health > 0)
        {
            if (RuloPartyDowned) { Vel = (0,0,0); Target = null; return; }
            if (RuloPartyBull.TrialGraceTicks > 0 || !RuloPartyBull.TrialReleased)
            { Vel = (0,0,0); Target = null; bInvulnerable = true; return; }
            if (RuloPartyMode == 1) { RuloPartyMode = 2; Target = RuloPartyBull; SetStateLabel("See"); }
            bInvulnerable = false; Target = RuloPartyBull;
            if (!CaelumMainM00RuloTrial.InArena(self))
            { SetOrigin(GetRuloPartyPosition(), false); Vel = (0,0,0); }
            return;
        }
        if (RuloPartyMode != 3)
        {
            RuloPartyMode = 3; RestoreRuloPartyHealth();
            SetStateLabel("Spawn");
        }
        bInvulnerable = true; ClearStoryCombatState(); Vel = (0,0,0);
        // El cierre se habla aquí. Una vez que el viajero sale y deja de ver
        // al grupo, recuperar los dormitorios y las mismas instancias.
        if (RuloPartyTraveler == null || !RuloPartyTraveler.HasMainM00Flag(
            CaelumConstants.MAIN_M00_FLAG_RULO_COMPLETE)) return;
        for (int n = 0; n < MAXPLAYERS; n++)
            if (playeringame[n] && players[n].mo != null
                && (CaelumMainM00RuloTrial.InArena(players[n].mo) || players[n].mo.CheckSight(self))) return;
        SetOrigin(StoryHome, false); Angle = StoryHomeAngle;
        RuloPartyMode = 0; RuloPartyBull = null; RuloPartyTraveler = null;
        SetStateLabel("Spawn");
    }

    override void PostBeginPlay()
    {
        Super.PostBeginPlay();
        EscortPrisonerId = -1;
        StoryHome = Pos;
        StoryHomeAngle = Angle;
        StoryAnchored = args[0] == CaelumConstants.STORY_NPC_ANCHORED;
        StoryReturningHome = false;

        if (StoryAnchored)
        {
            // Son residentes físicos de la mansión, no encuentros de combate.
            bSolid = true;
            bShootable = true;
            bInvulnerable = true;
            bFriendly = true;
            bBuddha = level.MapName == "MAP01";
            target = null;
        }
    }

    override bool Used(Actor user)
    {
        if (IsEscortPrisoner())
        {
            return UseEscortPrisoner(CaelumPlayer(user));
        }
        if (!StoryAnchored || level.MapName != "MAP01") { return Super.Used(user); }
        CaelumPlayer traveler = CaelumPlayer(user);
        if (traveler == null || traveler.player == null
            || !CaelumUseGeometry.AimedAt(traveler, self)) { return false; }
        if ((traveler.player.cmd.buttons & BT_USE) == 0
            || traveler.FolkloreInteractionUseLatched) { return true; }
        traveler.FolkloreInteractionUseLatched = true;
        traveler.FolkloreInteractionReleaseGuardTics = 0;
        if (RuloPartyMode == 1 || RuloPartyMode == 2) return true;
        return CaelumMainM00SocialDialogue.Open(traveler, self);
    }

    action void A_CaelumResidentLook()
    {
        CaelumAnchoredResident resident = CaelumAnchoredResident(self);
        if (resident != null && resident.StoryAnchored)
        {
            if (resident.IsRuloPartyFighting())
            {
                resident.Target = resident.RuloPartyBull;
                if (resident is "CaelumRulo" || resident is "CaelumRonnie")
                    resident.A_Chase("Melee", null);
                else resident.A_CaelumBudgetedChase();
            }
            else resident.Target = null;
            return;
        }
        A_CaelumBudgetedLook();
    }

    action void A_CaelumResidentChase()
    {
        CaelumAnchoredResident resident = CaelumAnchoredResident(self);
        if (resident != null && resident.StoryAnchored)
        {
            if (resident.IsRuloPartyFighting())
            {
                resident.Target = resident.RuloPartyBull;
                if (resident is "CaelumRulo" || resident is "CaelumRonnie")
                    resident.A_Chase("Melee", null);
                else resident.A_CaelumBudgetedChase();
            }
            else resident.Target = null;
            return;
        }
        A_CaelumBudgetedChase();
    }

    action void A_CaelumPrisonerFollow()
    {
        CaelumAnchoredResident resident = CaelumAnchoredResident(self);
        if (resident == null || resident.EscortPrisonerPort) { return; }
        if (resident.bInConversation)
        {
            resident.Vel = (0,0,0);
            return;
        }
        if (resident.IsNearMap02Boss())
        {
            resident.FleeEscortBoss();
            return;
        }

        CaelumPlayer leader = resident.EscortPrisonerLeader;
        if (leader == null || leader.health <= 0)
        {
            leader = resident.GetEscortOwnerPlayer();
        }
        if (leader == null || leader.health <= 0)
        {
            resident.Vel = (0,0,0);
            return;
        }
        resident.EscortPrisonerLeader = leader;

        if (resident.Distance2D(leader)
            <= CaelumConstants.PRISONER_FOLLOW_DISTANCE)
        {
            resident.Vel = (0,0,0);
            resident.Angle = VectorAngle(
                leader.Pos.X - resident.Pos.X,
                leader.Pos.Y - resident.Pos.Y
            );
            return;
        }

        resident.Target = leader;
        resident.A_Chase(null, null);
    }
    override void Tick()
    {
        EnsureStorySurvival();
        if (IsEscortPrisoner())
        {
            UpdateEscortPrisoner();
            Super.Tick();
            return;
        }
        if (RuloPartyMode != 0)
        {
            UpdateRuloParty();
            Super.Tick();
            if (!bInConversation && HasConversation())
                Level.ExecuteSpecial(CaelumConstants.GZDOOM_THING_SET_CONVERSATION_SPECIAL,
                    self, null, false, 0, 0);
            return;
        }
        Super.Tick();
        if (!StoryAnchored || health <= 0) { return; }
        ClearStoryCombatState();
        // El próximo Use debe reconstruir el nodo desde el personaje que habla.
        if (!bInConversation && HasConversation())
        {
            Level.ExecuteSpecial(CaelumConstants.GZDOOM_THING_SET_CONVERSATION_SPECIAL,
                self, null, false, 0, 0);
        }
        if (bInConversation)
        {
            Vel.X = 0.0;
            Vel.Y = 0.0;
            return;
        }

        target = null;
        bSolid = true;
        bShootable = true;
        bInvulnerable = true;
        bFriendly = true;

        Vector2 homeOffset = StoryHome.XY - Pos.XY;
        double homeDistance = homeOffset.Length();
        if (!StoryReturningHome
            && homeDistance >= CaelumConstants.STORY_NPC_RETURN_DISTANCE)
        {
            StoryReturningHome = true;
            SetState(FindState("See"));
        }

        if (!StoryReturningHome)
        {
            return;
        }

        if (homeDistance <= CaelumConstants.STORY_NPC_HOME_TOLERANCE)
        {
            SetOrigin((StoryHome.X, StoryHome.Y, Pos.Z), true);
            Vel.X = 0.0;
            Vel.Y = 0.0;
            Angle = StoryHomeAngle;
            StoryReturningHome = false;
            SetState(FindState("Spawn"));
            return;
        }

        double returnDirection = VectorAngle(homeOffset.X, homeOffset.Y);
        double returnSpeed = CombatBaseSpeed
            * CaelumConstants.GZDOOM_BASE_MAX_RUN_SPEED
            / CaelumConstants.GZDOOM_BASE_MAX_WALK_SPEED;
        double resolvedSpeed = Min(Max(0.0, returnSpeed), homeDistance);
        Angle = returnDirection;
        Vel.X = Cos(returnDirection) * resolvedSpeed;
        Vel.Y = Sin(returnDirection) * resolvedSpeed;
    }
}
