// Condición optativa y serializable. No define rangos narrativos, relaciones
// ni una fórmula global de precios: cada servicio declara sus requisitos.
class CaelumFactionCondition : Object
{
    const ALLOWED = 0;
    const INVALID = 1;
    const NO_RECORD = 2;
    const MEMBERSHIP_REQUIRED = 3;
    const REPUTATION_REQUIRED = 4;

    bool Configured;
    int FactionId;
    int MinimumReputation;
    bool RequireMembership;

    static CaelumFactionCondition Create(int factionId, int minimum, bool member = false)
    {
        let condition = new("CaelumFactionCondition");
        condition.Configured = true;
        condition.FactionId = factionId;
        condition.MinimumReputation = minimum;
        condition.RequireMembership = member;
        return condition;
    }

    clearscope int Evaluate(int reputation, bool member)
    {
        if (!Configured || !CaelumFactionRules.IsValidFactionId(FactionId)
            || MinimumReputation < CaelumConstants.FACTION_REPUTATION_MINIMUM
            || MinimumReputation > CaelumConstants.FACTION_REPUTATION_MAXIMUM) return INVALID;
        if (RequireMembership && !member) return MEMBERSHIP_REQUIRED;
        return reputation < MinimumReputation ? REPUTATION_REQUIRED : ALLOWED;
    }

    static play int Check(CaelumPlayer user, CaelumFactionCondition condition)
    {
        // null significa que el contenido no declara este requisito.
        if (condition == null) return ALLOWED;
        if (condition.Evaluate(0, false) == INVALID) return INVALID;
        if (user == null || user.player == null || user.health <= 0
            || !user.CharacterCreationComplete || user.CreationWizardOpen
            || (user.player.cheats & CF_PREDICTING)) return NO_RECORD;
        let record = user.GetPersistentCharacterState(false);
        if (record == null || record.FactionStateVersion < 1) return NO_RECORD;
        return condition.Evaluate(record.FactionReputation[condition.FactionId],
            record.FactionMember[condition.FactionId]);
    }

    static play bool Require(CaelumPlayer user, CaelumFactionCondition condition)
    {
        int result = Check(user, condition);
        if (result == ALLOWED) return true;
        if (user != null)
        {
            String key = result == MEMBERSHIP_REQUIRED ? "CA_REP_NEEDS_MEMBER"
                : result == REPUTATION_REQUIRED ? "CA_REP_NEEDS_VALUE" : "CA_REP_UNAVAILABLE";
            String text = StringTable.Localize(key, false);
            if (condition != null)
            {
                text.Replace("%FACTION%", StringTable.Localize(
                    CaelumFactionRules.GetNameKey(condition.FactionId), false));
                text.Replace("%VALUE%", String.Format("%d", condition.MinimumReputation));
            }
            user.A_Print(text);
        }
        return false;
    }

    static play bool OpenDialogue(CaelumPlayer user, Actor speaker, int conversationId,
        CaelumFactionCondition condition = null, int sightFlags = 0)
    {
        if (user == null || user.player == null || user.health <= 0
            || !user.CharacterCreationComplete || user.CreationWizardOpen
            || (user.player.cheats & CF_PREDICTING) || speaker == null
            || speaker.health <= 0 || speaker.bInConversation || user.HasActiveConversation()
            || user.Distance3D(speaker) > CaelumConstants.PALOMO_MERCHANT_SESSION_DISTANCE
            || !user.CheckSight(speaker, sightFlags) || !Require(user, condition)) return false;
        user.ClosePalomoMerchant(); user.CloseCraftingStationSession();
        user.SetCraftingJournalState(false); user.EquipmentMenuOpen = false;
        if (user.StaffCastPending) user.CancelPendingStaffCast(false);
        Level.ExecuteSpecial(CaelumConstants.GZDOOM_THING_SET_CONVERSATION_SPECIAL,
            speaker, null, false, 0, conversationId);
        return speaker.HasConversation() && speaker.StartConversation(user, false, false);
    }
}
