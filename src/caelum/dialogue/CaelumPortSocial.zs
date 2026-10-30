// Conocimiento del interlocutor sobre ESTE personaje; nunca un dato universal.
class CaelumFactionWitnessKnowledge : Object play
{
    int Witness;
    int MembershipEpoch[CaelumConstants.FACTION_COUNT];
    Array<String> AidKeys;
}

class CaelumPortSocial : Object
{
    static clearscope int Stage(CaelumPersistentCharacterState record, int prisoner)
    {
        if (record == null || prisoner < 0 || prisoner >= CaelumConstants.PRISONER_COUNT) return -1;
        if (record.PortSiegeNarrativeComplete) return CaelumPortSocialData.VICTORY;
        if (record.PortSiegeNarrativeStarted) return CaelumPortSocialData.THREAT;
        return record.PrisonerRewardClaimed[prisoner] ? CaelumPortSocialData.PREPARATION : CaelumPortSocialData.ARRIVAL;
    }

    static play void Ensure(CaelumPersistentCharacterState record)
    {
        if (record == null || record.PortSocialRevision >= CaelumPortSocialData.REVISION) return;
        // Los campos nuevos nacen vacíos; no atribuir lecturas o confesiones antiguas.
        record.PortSocialRevision = CaelumPortSocialData.REVISION;
    }

    static play CaelumAnchoredResident Speaker(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanMutate(user) || user.health <= 0
            || !user.HasActiveConversation() || user.player.ConversationPC != user) return null;
        let speaker = CaelumAnchoredResident(user.player.ConversationNPC);
        if (speaker == null || speaker.health <= 0 || !speaker.EscortPrisonerPort
            || speaker.EscortPrisonerId < 0 || speaker.EscortPrisonerId >= CaelumConstants.PRISONER_COUNT
            || speaker.CanBeFactionTarget(user) || speaker.ForcedSleepTics > 0
            || speaker.CombatLucidityPhysicalStunRemaining > 0
            || user.Distance3D(speaker) > CaelumConstants.PALOMO_MERCHANT_SESSION_DISTANCE
            || !user.CheckSight(speaker)) return null;
        return speaker;
    }

    static play void Guard(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanMutate(user) || !user.HasActiveConversation()
            || level.time % CaelumConstants.PRISONER_WALK_STATE_TICS != 0) return;
        let speaker = CaelumAnchoredResident(user.player.ConversationNPC);
        if (speaker == null || !speaker.EscortPrisonerPort || Speaker(user) != null) return;
        // El interlocutor puede estar detenido por la conversación nativa;
        // validar desde el participante evita depender de su siguiente Chase.
        speaker.bInConversation = false;
        if (user.player.ConversationFaceTalker) speaker.Angle = user.player.ConversationNPCAngle;
        user.player.ConversationNPC = null; user.player.ConversationPC = null;
    }

    static play CaelumFactionWitnessKnowledge Witness(CaelumPersistentCharacterState record, int id, bool create = false)
    {
        if (record == null || id < 0 || id >= CaelumConstants.PRISONER_COUNT) return null;
        for (int i = 0; i < record.FactionWitnesses.Size(); i++)
            if (record.FactionWitnesses[i].Witness == id) return record.FactionWitnesses[i];
        if (!create) return null;
        let witness = new("CaelumFactionWitnessKnowledge"); witness.Witness = id;
        record.FactionWitnesses.Push(witness); return witness;
    }

    static play int Chance(CaelumPlayer user, int prisoner)
    {
        if (user == null || user.Attributes == null || user.DerivedStats == null) return 0;
        let record = user.GetPersistentCharacterState(false);
        int faction = CaelumFactionData.ConfirmedPrisonerFaction(prisoner);
        int reputation = record != null && faction >= 0 ? record.FactionReputation[faction] : 0;
        double ability = user.DerivedStats.CalculateType4Percent(user.Attributes.Empathy);
        return Clamp(int(Floor(ability * 100 / CaelumPortSocialData.DIFFICULTY
            * CaelumPortSocialData.ReputationFactor(reputation) + 0.5)), 0, 100);
    }

    static play void Sync(CaelumPlayer user, CaelumAnchoredResident speaker)
    {
        if (user == null || speaker == null || !speaker.EscortPrisonerPort) return;
        let record = user.GetPersistentCharacterState(false);
        if (record == null) return;
        Ensure(record);
        int id = speaker.EscortPrisonerId;
        int stage = Stage(record, id); if (stage < 0) return;
        int slot = id * CaelumPortSocialData.STAGES + stage;
        user.PortEmotionChance = record.PortEmotionResult[slot] != 0
            ? record.PortEmotionChance[slot] : Chance(user, id);
        user.SetPalomoDialogueToken("CaelumPortEmotionTriedToken", record.PortEmotionResult[slot] != 0);
        user.SetPalomoDialogueToken("CaelumPortRepresentativeToken", CaelumFactionData.ConfirmedPrisonerFaction(id) >= 0);
        for (int faction = 0; faction < CaelumConstants.FACTION_COUNT; faction++)
            user.SetPalomoDialogueToken(MemberToken(faction), record.FactionMember[faction]);
    }

    static play bool Read(CaelumPlayer user)
    {
        let speaker = Speaker(user); if (speaker == null) return false;
        let record = user.GetPersistentCharacterState(false); if (record == null) return false;
        Ensure(record);
        int slot = speaker.EscortPrisonerId * CaelumPortSocialData.STAGES + Stage(record, speaker.EscortPrisonerId);
        if (record.PortEmotionResult[slot] == 0)
        {
            int chance = Chance(user, speaker.EscortPrisonerId);
            int roll = chance >= 100 ? 0 : chance <= 0 ? 101 : Random[CaelumPortEmotion](1, 100);
            record.PortEmotionChance[slot] = chance; record.PortEmotionRoll[slot] = roll;
            record.PortEmotionResult[slot] = roll <= chance ? 2 : 1;
        }
        Sync(user, speaker); return true;
    }

    static play bool Declare(CaelumPlayer user, int faction)
    {
        let speaker = Speaker(user);
        if (speaker == null || CaelumFactionData.ConfirmedPrisonerFaction(speaker.EscortPrisonerId) < 0
            || !CaelumFactionRules.IsValidFactionId(faction)) return false;
        let record = user.GetPersistentCharacterState(false);
        if (record == null || !record.FactionMember[faction]) return false;
        Ensure(record); CaelumFactionConsequences.Ensure(record);
        let witness = Witness(record, speaker.EscortPrisonerId, true);
        witness.MembershipEpoch[faction] = record.FactionMembershipEpoch[faction];
        Sync(user, speaker); return true;
    }

    static play bool DeclareAid(CaelumPlayer user)
    {
        let speaker = Speaker(user);
        if (speaker == null || CaelumFactionData.ConfirmedPrisonerFaction(speaker.EscortPrisonerId) < 0) return false;
        let record = user.GetPersistentCharacterState(false); if (record == null) return false;
        Ensure(record);
        let witness = Witness(record, speaker.EscortPrisonerId, true);
        for (int i = 0; i < record.FactionAidEvents.Size(); i++)
        {
            String key = record.FactionAidEvents[i].Key;
            if (witness.AidKeys.Find(key) == witness.AidKeys.Size()) witness.AidKeys.Push(key);
        }
        return true;
    }

    static play bool Report(CaelumPlayer user)
    {
        let speaker = Speaker(user); if (speaker == null) return false;
        int faction = CaelumFactionData.ConfirmedPrisonerFaction(speaker.EscortPrisonerId);
        if (faction < 0) return false;
        let record = user.GetPersistentCharacterState(false); if (record == null) return false;
        let witness = Witness(record, speaker.EscortPrisonerId);
        if (witness == null) return true;
        for (int other = 0; other < CaelumConstants.FACTION_COUNT; other++)
            CaelumFactionConsequences.ReportMembership(record, faction, other, witness.MembershipEpoch[other]);
        for (int i = 0; i < witness.AidKeys.Size(); i++)
            CaelumFactionConsequences.ReportAid(record, witness.AidKeys[i], faction);
        Sync(user, speaker); user.RefreshSocialJournalSnapshot(); return true;
    }

    static class<Inventory> MemberToken(int faction)
    {
        switch (faction)
        {
            case 0: return "CaelumPortMember0Token";
            case 1: return "CaelumPortMember1Token";
            case 2: return "CaelumPortMember2Token";
            case 3: return "CaelumPortMember3Token";
            case 4: return "CaelumPortMember4Token";
            case 5: return "CaelumPortMember5Token";
        }
        return null;
    }

    static ui String ReadingText(CaelumPlayer user, CaelumPersistentCharacterState record)
    {
        let speaker = user == null || user.player == null ? null : CaelumAnchoredResident(user.player.ConversationNPC);
        if (record == null || speaker == null) return StringTable.Localize("CA_PORT_EMOTION_UNTRIED", false);
        int stage = Stage(record, speaker.EscortPrisonerId);
        if (stage < 0) return "";
        int slot = speaker.EscortPrisonerId * CaelumPortSocialData.STAGES + stage;
        String key = record.PortEmotionResult[slot] == 2 ? CaelumPortSocialData.EmotionKey(stage)
            : record.PortEmotionResult[slot] == 1 ? "CA_PORT_EMOTION_FAILED" : "CA_PORT_EMOTION_UNTRIED";
        String text = StringTable.Localize(key, false);
        if (record.PortEmotionResult[slot] != 0)
            text = text .. "\n\n" .. StringTable.Localize("CA_PORT_EMOTION_PRIVATE", false);
        return text;
    }
}

class CaelumPortEmotionTriedToken : CaelumPalomoDialogueMarker {}
class CaelumPortRepresentativeToken : CaelumPalomoDialogueMarker {}
class CaelumPortMember0Token : CaelumPalomoDialogueMarker {}
class CaelumPortMember1Token : CaelumPalomoDialogueMarker {}
class CaelumPortMember2Token : CaelumPalomoDialogueMarker {}
class CaelumPortMember3Token : CaelumPalomoDialogueMarker {}
class CaelumPortMember4Token : CaelumPalomoDialogueMarker {}
class CaelumPortMember5Token : CaelumPalomoDialogueMarker {}

class CaelumPortEmotionAction : CaelumPalomoDialogueAction
{ override bool Use(bool pickup) { return CaelumPortSocial.Read(CaelumPlayer(Owner)); } }
class CaelumPortAidDeclarationAction : CaelumPalomoDialogueAction
{ override bool Use(bool pickup) { return CaelumPortSocial.DeclareAid(CaelumPlayer(Owner)); } }
class CaelumPortFactionReportAction : CaelumPalomoDialogueAction
{ override bool Use(bool pickup) { return CaelumPortSocial.Report(CaelumPlayer(Owner)); } }
class CaelumPortDeclare0Action : CaelumPalomoDialogueAction
{ override bool Use(bool pickup) { return CaelumPortSocial.Declare(CaelumPlayer(Owner), 0); } }
class CaelumPortDeclare1Action : CaelumPalomoDialogueAction
{ override bool Use(bool pickup) { return CaelumPortSocial.Declare(CaelumPlayer(Owner), 1); } }
class CaelumPortDeclare2Action : CaelumPalomoDialogueAction
{ override bool Use(bool pickup) { return CaelumPortSocial.Declare(CaelumPlayer(Owner), 2); } }
class CaelumPortDeclare3Action : CaelumPalomoDialogueAction
{ override bool Use(bool pickup) { return CaelumPortSocial.Declare(CaelumPlayer(Owner), 3); } }
class CaelumPortDeclare4Action : CaelumPalomoDialogueAction
{ override bool Use(bool pickup) { return CaelumPortSocial.Declare(CaelumPlayer(Owner), 4); } }
class CaelumPortDeclare5Action : CaelumPalomoDialogueAction
{ override bool Use(bool pickup) { return CaelumPortSocial.Declare(CaelumPlayer(Owner), 5); } }

class CaelumPortConversationMenu : CaelumPalomoConversationMenu
{
    override void Ticker()
    {
        let user = mPlayer == null ? null : CaelumPlayer(mPlayer.mo);
        if (user == null || user.player == null || user.player.ConversationNPC == null
            || !user.player.ConversationNPC.bInConversation)
        { SendConversationReply(-1, 0); Close(); return; }
        Super.Ticker();
    }
    override int FormatReplies(int activereply)
    {
        int result = Super.FormatReplies(activereply);
        let user = mPlayer == null ? null : CaelumPlayer(mPlayer.mo);
        for (int i = 0; i < mResponseLines.Size(); i++)
            mResponseLines[i].Replace("%CHANCE%", String.Format("%d", user == null ? 0 : user.PortEmotionChance));
        return result;
    }

    override void FormatSpeakerMessage()
    {
        if (mCurNode != null && mCurNode.UserData ~== "port_emotion_result")
        {
            let user = mPlayer == null ? null : CaelumPlayer(mPlayer.mo);
            mDialogueLines = displayFont.BreakLines(CaelumPortSocial.ReadingText(user, History()), SpeechWidth);
            return;
        }
        Super.FormatSpeakerMessage();
    }
}
