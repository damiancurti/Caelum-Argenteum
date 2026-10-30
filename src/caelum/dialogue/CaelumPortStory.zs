class CaelumPortStory : Object
{
    static play void Ensure(CaelumPersistentCharacterState record)
    {
        if (record != null && record.PortStoryRevision < CaelumPortStoryData.REVISION)
            record.PortStoryRevision = CaelumPortStoryData.REVISION;
        // No atribuir conversaciones nuevas a pagos o visitas anteriores.
    }

    static play void Arrived(CaelumPlayer user, CaelumAnchoredResident speaker)
    {
        if (!CaelumPlayerAuthority.CanMutate(user) || speaker == null || !speaker.EscortPrisonerPort
            || user.player.ConversationNPC != speaker || !user.HasActiveConversation()) return;
        let record = user.GetPersistentCharacterState(false); if (record == null) return;
        Ensure(record); record.PortArrivalHeardMask |= 1 << speaker.EscortPrisonerId;
    }

    static play CaelumPortDefender GuardSpeaker(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanMutate(user) || user.health <= 0 || !user.HasActiveConversation()
            || user.player.ConversationPC != user) return null;
        let guard = CaelumPortDefender(user.player.ConversationNPC);
        if (guard == null || guard.health <= 0 || guard.ForcedSleepTics > 0
            || guard.CombatLucidityPhysicalStunRemaining > 0 || CaelumTheftWitnesses.HasTarget(guard)
            || user.Distance3D(guard) > CaelumConstants.PALOMO_MERCHANT_SESSION_DISTANCE
            || !user.CheckSight(guard)) return null;
        if (guard.bInCombat && guard.target != null && guard.target.bShootable && guard.target.health > 0
            && !guard.target.bFriendly && (guard.Port == null || !guard.Port.Victory)) return null;
        return guard;
    }

    static play void Guard(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanMutate(user) || !user.HasActiveConversation()
            || level.time % CaelumConstants.PRISONER_WALK_STATE_TICS != 0) return;
        let guard = CaelumPortDefender(user.player.ConversationNPC);
        if (guard == null || GuardSpeaker(user) != null) return;
        guard.bInConversation = false;
        if (user.player.ConversationFaceTalker) guard.Angle = user.player.ConversationNPCAngle;
        user.player.ConversationNPC = null; user.player.ConversationPC = null;
    }

    static play bool Hear(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return false;
        let record = user.GetPersistentCharacterState(false); if (record == null) return false;
        let prisoner = CaelumPortSocial.Speaker(user);
        let guard = GuardSpeaker(user);
        if (prisoner == null && guard == null) return false;
        if (prisoner != null && !record.PrisonerRewardClaimed[prisoner.EscortPrisonerId]) return false;
        Ensure(record);
        if (guard != null) record.PortGuardAccountHeard = true;
        else record.PortPrisonerAccountMask |= 1 << prisoner.EscortPrisonerId;
        let registry=CaelumSiegeEvents(EventHandler.Find("CaelumSiegeEvents"));
        if(registry!=null)registry.SyncPortSurvivors();
        CaelumPortQuests.AccountHeard(user);
        user.RefreshSocialJournalSnapshot();
        return true;
    }

    static ui String Accounts(CaelumPlayer user)
    {
        let record = user == null ? null : CaelumPersistentCharacterState(user.FindInventory("CaelumPersistentCharacterState"));
        if (record == null || (!record.PortGuardAccountHeard && record.PortPrisonerAccountMask == 0))
            return StringTable.Localize("CA_PORT_STORY_NONE", false);
        String names;
        if (record.PortGuardAccountHeard) names = StringTable.Localize("CA_PORT_SOLDIER", false);
        for (int i = 0; i < CaelumConstants.PRISONER_COUNT; i++)
            if (record.PortPrisonerAccountMask & (1 << i))
                names = names .. (names.Length() > 0 ? "; " : "")
                    .. StringTable.Localize(CaelumPortStoryData.NameKey(i), false);
        return StringTable.Localize("CA_PORT_STORY_HEARD", false) .. "\n" .. names;
    }

    static ui String Text(CaelumPlayer user)
    {
        let record = user == null ? null : CaelumPersistentCharacterState(user.FindInventory("CaelumPersistentCharacterState"));
        let speaker = user == null || user.player == null ? null : user.player.ConversationNPC;
        String text = StringTable.Localize(speaker is "CaelumPortDefender"
            ? "CA_PORT_STORY_GUARD" : "CA_PORT_STORY_PRISONER", false);
        text = text .. "\n\n" .. StringTable.Localize(CaelumPortStoryData.SituationKey(record), false);
        text.Replace("%PLACE%", StringTable.Localize(CaelumWorldCatalogue.LocationNameKey(CaelumWorldCatalogue.LOCATION_PORT), false));
        if (record != null && record.PortSiegeNarrativeComplete)
            text = text .. "\n\n" .. Accounts(user);
        return text;
    }
}

class CaelumPortStoryAction : CaelumPalomoDialogueAction
{ override bool Use(bool pickup) { return CaelumPortStory.Hear(CaelumPlayer(Owner)); } }

class CaelumPortStoryMenu : CaelumPortConversationMenu
{
    override void Ticker()
    {
        Super.Ticker();
        if (!Replaying && mCurNode != null && mCurNode.UserData ~== "port_story_account") FormatSpeakerMessage();
    }
    override void FormatSpeakerMessage()
    {
        if (!Replaying && mCurNode != null && mCurNode.UserData ~== "port_story_account")
        {
            let user = mPlayer == null ? null : CaelumPlayer(mPlayer.mo);
            mDialogueLines = displayFont.BreakLines(CaelumPortStory.Text(user), SpeechWidth); return;
        }
        Super.FormatSpeakerMessage();
    }
}
