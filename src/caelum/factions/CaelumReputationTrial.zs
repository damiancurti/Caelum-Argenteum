// Prueba explícita de condiciones: no asigna facciones a NPC narrativos ni
// añade ganancias de reputación a la campaña. Usa el registro real del dueño.
class CaelumReputationTrialState : Inventory
{
    CaelumReputationTrialGuide Guide;
    CaelumSlidingDoorLeaf Door;
    String PresentationMap;

    static CaelumReputationTrialState Get(CaelumPlayer user, bool create = false)
    {
        if (user == null) return null;
        let trialState = CaelumReputationTrialState(user.FindInventory("CaelumReputationTrialState"));
        if (trialState == null && create)
            trialState = CaelumReputationTrialState(user.GiveInventoryType("CaelumReputationTrialState"));
        return trialState;
    }

    static bool Open(CaelumPlayer user, bool enable = false)
    {
        if (user == null || user.player == null || user.health <= 0
            || !user.CharacterCreationComplete || user.CreationWizardOpen
            || (user.player.cheats & CF_PREDICTING)) return false;
        if (user.HasActiveConversation())
        { user.A_Print(StringTable.Localize("CA_REP_TRIAL_BUSY", false)); return false; }
        let trialState = Get(user, enable);
        if (trialState == null) return false;
        if (trialState.PresentationMap != level.MapName)
        {
            trialState.Guide = null; trialState.Door = null;
            trialState.PresentationMap = level.MapName;
        }
        if (trialState.Guide == null)
            trialState.Guide = CaelumReputationTrialGuide(Actor.Spawn("CaelumReputationTrialGuide", user.Pos, NO_REPLACE));
        if (trialState.Guide == null || trialState.Guide.QueuedAction != 0) return false;
        trialState.Guide.Subject = user; trialState.Guide.Trial = trialState;
        // El interlocutor invisible queda dentro del espacio del jugador.
        // Sólo esta prueba ignora su invisibilidad, conservando la geometría.
        trialState.Guide.SetOrigin(user.Pos + (Cos(user.Angle)*8,
            Sin(user.Angle)*8, user.Height*0.5), false);
        user.RefreshSocialJournalSnapshot();
        return CaelumFactionCondition.OpenDialogue(user, trialState.Guide, 43322, null, SF_IGNOREVISIBILITY);
    }

    bool PrepareDoor(CaelumPlayer user)
    {
        if (Door != null && Door.Distance2D(user) <= 256
            && Abs(Door.Pos.Z-user.Pos.Z) <= 32 && user.CheckSight(Door)) return true;
        Vector3 where = user.Pos + (Cos(user.Angle)*96, Sin(user.Angle)*96, 0);
        bool slideY = Abs(Cos(user.Angle)) > Abs(Sin(user.Angle));
        Vector3 slide = slideY ? (0,64,0) : (64,0,0);
        let probe = Actor.Spawn("CaelumReputationPlacementProbe", where, NO_REPLACE);
        if (probe == null) return false;
        bool fits = probe.TestMobjLocation();
        probe.SetOrigin(where+slide, false);
        fits = fits && probe.TestMobjLocation();
        probe.Destroy();
        if (!fits)
        { user.A_Print(StringTable.Localize("CA_REP_TRIAL_SPACE", false)); return false; }
        int group = 50000;
        let it = ThinkerIterator.Create("CaelumSlidingDoorLeaf");
        CaelumSlidingDoorLeaf existing;
        while ((existing = CaelumSlidingDoorLeaf(it.Next())) != null)
            group = Max(group, existing.args[0]);
        if (group == 2147483647) return false;
        let replacement = CaelumSlidingDoorLeaf(Actor.Spawn("CaelumSlidingDoorLeaf", where, NO_REPLACE));
        if (replacement == null) return false;
        if (Door != null) Door.Destroy();
        Door = replacement;
        Door.args[0] = group+1; Door.args[1] = 1; Door.args[2] = slideY ? 1 : 0;
        Door.Angle = slideY ? 0 : 90;
        Door.AccessCondition = CaelumFactionCondition.Create(CaelumConstants.FACTION_UNITARIOS, 25, true);
        return true;
    }

    static bool Disable(CaelumPlayer user)
    {
        if (user == null || user.HasActiveConversation() || user.PalomoMerchantMenuOpen) return false;
        let trialState = Get(user);
        if (trialState == null) return false;
        trialState.Destroy(); user.RefreshSocialJournalSnapshot();
        user.A_Print(StringTable.Localize("CA_REP_TRIAL_DISABLED", false));
        return true;
    }

    override void OnDestroy()
    {
        if (Guide != null) Guide.Destroy();
        if (Door != null) Door.Destroy();
        Super.OnDestroy();
    }

    Default
    {
        Inventory.MaxAmount 1;
        +INVENTORY.UNDROPPABLE
        -INVENTORY.INVBAR
    }
    States { Spawn: TNT1 A -1; Stop; }
}

class CaelumReputationPlacementProbe : Actor
{
    Default { Radius 40; Height 120; +SOLID +NOGRAVITY RenderStyle "None"; }
    States { Spawn: TNT1 A -1; Stop; }
}

class CaelumReputationTrialGuide : Actor
{
    CaelumPlayer Subject;
    CaelumReputationTrialState Trial;
    int QueuedAction;

    override void Tick()
    {
        Super.Tick();
        if (Subject == null || Trial == null) { Destroy(); return; }
        if (QueuedAction == 0 || bInConversation || Subject.HasActiveConversation()) return;
        int requestedAction = QueuedAction; QueuedAction = 0;
        if (Subject.health <= 0) return;
        if (requestedAction == 1)
        {
            let condition = CaelumFactionCondition.Create(CaelumConstants.FACTION_UNITARIOS, 25);
            CaelumFactionCondition.OpenDialogue(Subject, self, 43323, condition, SF_IGNOREVISIBILITY);
        }
        else if (requestedAction == 2)
        {
            if (Trial.PrepareDoor(Subject) && Trial.Door.RequestDoorGroup(Subject))
                Subject.A_Print(StringTable.Localize("CA_REP_TRIAL_ACCESS_OK", false));
        }
        else if (requestedAction == 3)
        {
            if (!CaelumMainM00FoolCapture.HasOwnedBox(Subject))
            { Subject.A_Print(StringTable.Localize("CA_REP_TRIAL_BOX", false)); return; }
            Subject.OpenPalomoMerchant(self,
                CaelumFactionCondition.Create(CaelumConstants.FACTION_UNITARIOS, 0),
                CaelumFactionCondition.Create(CaelumConstants.FACTION_UNITARIOS, 25),
                "CA_REP_TRIAL_TRADE_TITLE");
        }
        else if (requestedAction >= 10 && requestedAction <= 14)
        {
            int reputation = requestedAction == 11 || requestedAction == 12 ? 25 : requestedAction == 13 ? -25 : 0;
            bool member = requestedAction >= 12;
            let record = Subject.GetPersistentCharacterState(false);
            if (record == null) return;
            Subject.ChangePlayerFactionReputation(CaelumConstants.FACTION_UNITARIOS,
                reputation-record.FactionReputation[CaelumConstants.FACTION_UNITARIOS]);
            Subject.SetPlayerFactionMembership(CaelumConstants.FACTION_UNITARIOS, member);
            CaelumFactionCondition.OpenDialogue(Subject, self, 43322, null, SF_IGNOREVISIBILITY);
        }
    }

    Default { Radius 1; Height 1; +NOBLOCKMAP +NOGRAVITY +INVULNERABLE +NOTARGET RenderStyle "None"; }
    States { Spawn: TNT1 A -1; Stop; }
}

class CaelumReputationTrialAction : CaelumPalomoDialogueAction abstract
{
    virtual int ActionId() { return 0; }
    override bool Use(bool pickup)
    {
        let user = CaelumPlayer(Owner);
        if (user == null || user.player == null || user.health <= 0) return false;
        let guide = CaelumReputationTrialGuide(user.player.ConversationNPC);
        if (guide == null || guide.Subject != user || !guide.bInConversation
            || guide.Trial != CaelumReputationTrialState.Get(user)
            || guide.QueuedAction != 0) return false;
        guide.QueuedAction = ActionId();
        return true;
    }
}
class CaelumReputationInfoAction : CaelumReputationTrialAction { override int ActionId() { return 1; } }
class CaelumReputationAccessAction : CaelumReputationTrialAction { override int ActionId() { return 2; } }
class CaelumReputationTradeAction : CaelumReputationTrialAction { override int ActionId() { return 3; } }
class CaelumReputationNeutralAction : CaelumReputationTrialAction { override int ActionId() { return 10; } }
class CaelumReputationFavorableAction : CaelumReputationTrialAction { override int ActionId() { return 11; } }
class CaelumReputationMemberAction : CaelumReputationTrialAction { override int ActionId() { return 12; } }
class CaelumReputationAdverseAction : CaelumReputationTrialAction { override int ActionId() { return 13; } }
class CaelumReputationMemberNeutralAction : CaelumReputationTrialAction { override int ActionId() { return 14; } }

class CaelumDebugReputationTrial : CaelumSocialDebugAction
{
    override bool Use(bool pickup) { return CaelumReputationTrialState.Open(CaelumPlayer(Owner), true); }
}
class CaelumDebugReputationTrialOff : CaelumSocialDebugAction
{
    override bool Use(bool pickup) { return CaelumReputationTrialState.Disable(CaelumPlayer(Owner)); }
}

class CaelumReputationConversationMenu : CaelumPalomoConversationMenu
{
    override void FormatSpeakerMessage()
    {
        if (!(mCurNode.UserData ~== "rep_trial_hub"))
        { Super.FormatSpeakerMessage(); return; }
        let user = mPlayer == null ? null : CaelumPlayer(mPlayer.mo);
        String text = StringTable.Localize(mCurNode.Dialogue);
        if (user != null)
        {
            text.Replace("%REP%", String.Format("%d", user.JournalFactionReputation[CaelumConstants.FACTION_UNITARIOS]));
            text.Replace("%MEMBER%", StringTable.Localize(user.JournalFactionMember[CaelumConstants.FACTION_UNITARIOS]
                ? "CA_FACTION_MEMBER_YES" : "CA_FACTION_MEMBER_NO", false));
        }
        mDialogueLines = displayFont.BreakLines(text, SpeechWidth);
    }
}
