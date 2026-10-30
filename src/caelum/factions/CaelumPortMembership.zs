// #420: la incorporación no revela otras afiliaciones ni cobra recursos.
class CaelumPortMembership : Object
{
    static clearscope bool Eligible(CaelumPersistentCharacterState record, CaelumAnchoredResident speaker)
    {
        if (record == null || speaker == null || !speaker.EscortPrisonerPort || speaker.health <= 0) return false;
        int faction = CaelumFactionData.ConfirmedPrisonerFaction(speaker.EscortPrisonerId);
        return faction >= 0 && !record.FactionMember[faction]
            && CaelumFactionData.Rank(record.FactionReputation[faction]) >= CaelumFactionData.JOIN_MINIMUM_RANK;
    }

    static play bool Join(CaelumPlayer user)
    {
        let speaker = CaelumPortSocial.Speaker(user);
        let record = speaker == null ? null : user.GetPersistentCharacterState(false);
        if (!Eligible(record, speaker)) return false;
        int faction = CaelumFactionData.ConfirmedPrisonerFaction(speaker.EscortPrisonerId);
        if (!user.SetPlayerFactionMembership(faction, true)) return false;
        CaelumPortSocial.Sync(user, speaker);
        user.A_Log(StringTable.Localize("CA_PORT_JOIN_DONE", false));
        return true;
    }
}

class CaelumPortJoinToken : CaelumPalomoDialogueMarker {}
class CaelumPortJoinAction : CaelumPalomoDialogueAction
{ override bool Use(bool pickup) { return CaelumPortMembership.Join(CaelumPlayer(Owner)); } }
