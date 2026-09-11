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
        if (RuloPartyMode != 0 && (!IsRuloPartyFighting()
            || (source != RuloPartyBull && inflictor != RuloPartyBull))) return 0;
        return Super.DamageMobj(inflictor, source, damage, mod, flags, angle);
    }

    override void Die(Actor source, Actor inflictor, int dmgflags, Name MeansOfDeath)
    {
        if (RuloPartyMode == 2 && RuloPartyBull != null && RuloPartyBull.health > 0)
        {
            health = 1; RuloPartyDowned = true; Target = null; Vel = (0,0,0);
            bInvulnerable = true; bShootable = false; bSolid = false;
            SetStateLabel("CrouchIdle");
            return;
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
        bInvulnerable = true; Target = null; Vel = (0,0,0);
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
            target = null;
        }
    }

    override bool Used(Actor user)
    {
        if (!StoryAnchored || level.MapName != "MAP01") { return Super.Used(user); }
        CaelumPlayer traveler = CaelumPlayer(user);
        if (traveler == null || traveler.player == null) { return false; }
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

    override void Tick()
    {
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
