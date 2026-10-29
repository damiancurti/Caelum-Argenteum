// Contrato común para los cuatro residentes narrativos de MAP01. Las
// invocaciones de depuración sin args[0] conservan su IA de combate anterior.
class CaelumAnchoredResident : CaelumCombatActor abstract
{
    const RULO_MOVEMENT_REVISION=1;
    int RuloMovementRevision;

    void EnsureRuloMovement()
    {
        if(!IsProtectedStoryResident() || !CombatProfileInitialized
            || RuloMovementRevision>=RULO_MOVEMENT_REVISION)return;
        // Un save anterior puede haber capturado cero antes del alta nativa.
        // No tocar bases positivas, recursos, bajas ni identidad del residente.
        if(CombatBaseSpeed<=0)CombatBaseSpeed=GetDefaultByType(GetClass()).Speed;
        RuloMovementRevision=RULO_MOVEMENT_REVISION;
        UpdateCombatHealthEffects();
    }

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
    CaelumResidentTools ResidentTools;

    void EnsureResidentTools()
    {
        if(!StoryAnchored || IsEscortPrisoner())return;
        if(ResidentTools==null)ResidentTools=new("CaelumResidentTools");
        ResidentTools.Initialize(self);
    }

    override CaelumWeaponModel GetPossessedSidearm()
    {return ResidentTools!=null ? ResidentTools.GetSidearm() : null;}

    // Estado de escolta de los prisioneros de MAP02. Los residentes de la
    // mansiÃ³n conservan -1 y nunca entran en esta mÃ¡quina.
    int EscortPrisonerId;
    bool EscortPrisonerPort;
    CaelumPlayer EscortPrisonerLeader;
    int EscortPrisonerThreatScanTics;
    double EscortPrisonerHealthRegenAccumulator;
    CaelumPrisonerEscort EscortControl;
    CaelumPlayer FactionTarget;
    bool FactionHostilityActive;

    bool CanBeFactionTarget(CaelumPlayer user)
    {
        return EscortPrisonerPort && user != null && user.player != null
            && user.health > 0 && user.bShootable
            && CaelumFactionRules.HostileReputation(user.GetPersistentCharacterState(false),
                CaelumFactionData.ConfirmedPrisonerFaction(EscortPrisonerId));
    }

    void UpdatePortFactionHostility()
    {
        if (!EscortPrisonerPort || health <= 0
            || CaelumFactionData.ConfirmedPrisonerFaction(EscortPrisonerId) < 0) return;
        if (!CanBeFactionTarget(FactionTarget)) FactionTarget = null;
        // Sólo tres representantes canónicos y MAXPLAYERS; cadencia de su
        // locomoción existente. Nunca recorrer actores ni inferir facción visual.
        if (FactionTarget == null && level.time % CaelumConstants.PRISONER_WALK_STATE_TICS == 0)
        {
            for (int p = 0; p < MAXPLAYERS; p++)
            {
                if (!playeringame[p]) continue;
                let user = CaelumPlayer(players[p].mo);
                if (CanBeFactionTarget(user) && CheckSight(user))
                { FactionTarget = user; break; }
            }
        }
        // La reacción ante robo tiene su propia autoridad y conserva prioridad.
        if (TheftTarget != null) return;
        if (FactionTarget == null)
        {
            if (FactionHostilityActive)
            {
                FactionHostilityActive = false;
                ClearStoryCombatState(); bFriendly = true; bInvulnerable = true;
                SetStateLabel("Spawn");
            }
            return;
        }
        FactionHostilityActive = true; bFriendly = false; bInvulnerable = false;
        Target = FactionTarget; LastEnemy = FactionTarget;
        if (bInConversation) InterruptEscortConversation();
        if (!bInConversation && ForcedSleepTics <= 0
            && CombatLucidityPhysicalStunRemaining <= 0 && !ResourceRecoveryActive()
            && !InEscortCombatState()) SetStateLabel("See");
    }

    bool IsProtectedStoryResident()
    {
        return StoryAnchored && level.MapName == "MAP01";
    }

    void ClearStoryCombatState()
    {
        EndResourceRecovery();
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

        if (level.MapName == "MAP03")
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
        if(EscortControl!=null)
        {EscortControl.ClearTrail();EscortControl.Path=null;EscortControl.Acceleration=0;}
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
        if (marker != null && Distance2D(marker)
            <= CaelumConstants.PRISONER_EXTRACTION_RADIUS)
        {
            return true;
        }
        Actor bossGate = ActorIterator.Create(
            CaelumConstants.PRISONER_BOSS_GATE_TID,
            "CaelumMazeBarredGate").Next();
        return bossGate != null && Distance2D(bossGate)
            <= CaelumConstants.PRISONER_EXTRACTION_RADIUS;
    }

    bool IsNearMap02Boss()
    {
        if (level.MapName != "MAP02") return false;
        Actor boss = ActorIterator.Create(43799, "CaelumZupayColossus").Next();
        if (boss == null || boss.health <= 0) return false;
        // Mientras la reja del norte sigue cerrada, el Zupay no puede
        // hostigar a la escolta; alejarse antes de abrirla impedía que los
        // prisioneros llegaran al punto de extracción previo al jefe.
        CaelumMazeBarredGate gate = CaelumMazeBarredGate(
            ActorIterator.Create(
                CaelumConstants.PRISONER_BOSS_GATE_TID,
                "CaelumMazeBarredGate"
            ).Next()
        );
        if (gate == null || !gate.Opened) return false;
        return Distance2D(boss)
            <= CaelumConstants.PRISONER_BOSS_STAYBACK_RADIUS;
    }

    bool InEscortCombatState()
    {
        State seeState = FindState("See");
        State meleeState = FindState("Melee");
        State missileState = FindState("Missile");
        State painState = FindState("Pain");
        return (seeState != null && InStateSequence(CurState, seeState))
            || (meleeState != null && InStateSequence(CurState, meleeState))
            || (missileState != null && InStateSequence(CurState, missileState))
            || (painState != null && InStateSequence(CurState, painState));
    }

    void RegenerateEscortPrisonerHealth()
    {
        if(IsCombatIdle())return; // El descanso quieto ya usa la recuperación común.
        if (health <= 0 || health >= CombatMaximumHealth) return;
        // La recuperación base de los seguidores reutiliza la tasa natural del
        // jugador: vida máxima por hora real, escalada por Resiliencia Tipo 2.
        double regenPerSecond = Max(0.0, double(CombatMaximumHealth))
            / CaelumConstants.HEALTH_BASE_RECOVERY_REAL_SECONDS
            * CalculateActorType4Percent(CombatResilience) / 100.0;
        EscortPrisonerHealthRegenAccumulator += regenPerSecond / TICRATE;
        int wholeHealth = int(EscortPrisonerHealthRegenAccumulator);
        if (wholeHealth <= 0) return;
        EscortPrisonerHealthRegenAccumulator -= wholeHealth;
        health = Min(CombatMaximumHealth, health + wholeHealth);
    }

    Actor FindEscortThreat()
    {
        if(CaelumTheftWitnesses.HasTarget(self))return TheftTarget;
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

        CaelumPlayer owner = GetEscortOwnerPlayer();
        int rescueState = owner == null
            ? CaelumConstants.PRISONER_STATE_CAPTIVE
            : owner.GetPrisonerRescueState(EscortPrisonerId);
        if (rescueState != CaelumConstants.PRISONER_STATE_FOLLOWING)
        {
            Vel = (0,0,0);
            Target = null;
            bInvulnerable = true;
            ClearStoryCombatState();
            State spawnState = FindState("Spawn");
            State idleState = FindState("IdleBreathing");
            if (!InStateSequence(CurState, spawnState)
                && !InStateSequence(CurState, idleState))
            {
                SetState(spawnState);
            }
            return;
        }

        if(EscortControl==null)EscortControl=new("CaelumPrisonerEscort");
        EscortControl.Observe(self,owner);
        if (bInConversation)
        {
            Actor threat = FindEscortThreat();
            if (threat != null)
            {
                InterruptEscortConversation();
            }
            else
            {
                EscortControl.Hold(self);
                Target = null;
                ClearStoryCombatState();
                return;
            }
        }

        if (owner == null || owner.health <= 0)
        {
            EscortControl.Hold(self);
            Target = null;
            ClearStoryCombatState();
            return;
        }

        if (AtPrisonerExtraction())
        {
            MarkEscortPrisonerExtracted(owner);
            return;
        }

        // Los bloqueos físicos también impiden recuperación y pasos de ruta.
        if(EscortControl.Immobilized(self)){EscortControl.Yield(self);return;}
        if (IsNearMap02Boss())
        {
            EscortControl.Yield(self);
            Target = null;
            ClearStoryCombatState();
            FleeEscortBoss();
            return;
        }

        // Las salidas de historia anteriores prevalecen; el combate común
        // conserva su retirada/descanso sin que el seguimiento lo reinicie.
        if(ResourceRecoveryActive())
        {
            EscortControl.Yield(self);
            // La fase quieta usa poses sin acciones. Comprobar su final aquí;
            // la retirada conserva los pulsos de su estado nativo de cuatro tics.
            if(RecoveryPhase==2 && level.time%CaelumConstants.PRISONER_WALK_STATE_TICS==0)
                PulseResourceRecovery();
            return;
        }
        Actor threat = FindEscortThreat();
        if (threat != null)
        {
            EscortControl.Yield(self);
            Target = threat;
            bInvulnerable = false;
            State seeState = FindState("See");
            // No reiniciar See cada tic: interrumpiría las secuencias Melee,
            // Missile o Pain antes de que ejecuten su ataque o conjuro.
            if (!InEscortCombatState()) { SetState(seeState); }
            return;
        }

        RegenerateEscortPrisonerHealth();
        EscortPrisonerLeader = owner;
        Target = null;
        ClearStoryCombatState();
        EscortControl.Follow(self,owner);
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
        CaelumThermalMotion.SetVelocity(self);
    }

    bool UseEscortPrisoner(CaelumPlayer user)
    {
        if (user == null || user.player == null) { return false; }
        return CaelumPrisonerRescue.OpenDialogue(user, self);
    }
    void DownRuloPartyMember()
    {
        RecordBullNarrativeSeverity(3);
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
        EndResourceRecovery();
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

    void RecordBullNarrativeSeverity(int severity)
    {
        if (RuloPartyMode != 2 || RuloPartyTraveler == null || RuloPartyBull == null
            || RuloPartyBull.health <= 0 || RuloPartyBull.TrialGraceTicks > 0) return;
        int resident = CaelumMainM00SocialDialogue.GetResidentId(self);
        let record = RuloPartyTraveler.GetPersistentCharacterState(false);
        if (record != null && resident >= 0 && resident < 4)
            record.BullEncounterSeverity[resident] = Max(record.BullEncounterSeverity[resident], severity);
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
            && RuloPartyBull.health > 0 && RuloPartyBull.TrialReleased && RuloPartyBull.TrialGraceTicks == 0;
    }

    override int DamageMobj(Actor inflictor, Actor source, int damage, Name mod, int flags, double angle)
    {
        if (IsProtectedStoryResident()) bBuddha = true;
        if (RuloPartyMode != 0 && (!IsRuloPartyFighting()
            || (source != RuloPartyBull && inflictor != RuloPartyBull))) return 0;
        int received = Super.DamageMobj(inflictor, source, damage, mod, flags, angle);
        if (received > 0 && RuloPartyMode == 2 && (source == RuloPartyBull || inflictor == RuloPartyBull))
        {
            UpdateCombatHealthEffects();
            RecordBullNarrativeSeverity(health <= 1 ? 3 : CombatHealthState);
        }
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
        // Las consultas previas de estadísticas pueden borrar Speed antes de
        // que la base compartida lo capture. Recuperar sólo el valor ausente.
        if(level.MapName=="MAP01" && args[0]==CaelumConstants.STORY_NPC_ANCHORED && Speed<=0)
            Speed=GetDefaultByType(GetClass()).Speed;
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
        if(IsProtectedStoryResident())RuloMovementRevision=RULO_MOVEMENT_REVISION;
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
        if(resident!=null && resident.PulseResourceRecovery())return;
        if (resident != null && resident.StoryAnchored)
        {
            if (resident.IsRuloPartyFighting())
            {
                resident.Target = resident.RuloPartyBull;
                if(resident.ResidentTools!=null && resident.ResidentTools.TryStart())return;
                resident.A_CaelumBudgetedChase();
            }
            else resident.Target = null;
            return;
        }
        A_CaelumBudgetedLook();
    }

    action void A_CaelumResidentChase()
    {
        CaelumAnchoredResident resident = CaelumAnchoredResident(self);
        if(resident!=null && resident.PulseResourceRecovery())return;
        if (resident != null && resident.FactionHostilityActive && resident.TheftTarget == null)
        {
            resident.UpdatePortFactionHostility();
            if (resident.FactionTarget != null)
            { resident.Target = resident.FactionTarget; resident.ThermalChase(); }
            return;
        }
        if (resident != null && resident.StoryAnchored)
        {
            if (resident.IsRuloPartyFighting())
            {
                resident.Target = resident.RuloPartyBull;
                if(resident.ResidentTools!=null && resident.ResidentTools.TryStart())return;
                resident.A_CaelumBudgetedChase();
            }
            else resident.Target = null;
            return;
        }
        A_CaelumBudgetedChase();
    }

    override void Tick()
    {
        if(CaelumRedemption.Pending(self))return;
        EnsureRuloMovement();
        EnsureResidentTools();
        if(ResidentTools!=null)ResidentTools.Tick();
        EnsureStorySurvival();
        if(ResourceRecoveryActive() && IsRuloPartyFighting())
        {Super.Tick();return;}
        if (IsEscortPrisoner())
        {
            UpdatePortFactionHostility();
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
        CaelumThermalMotion.SetVelocity(self);
    }
}
