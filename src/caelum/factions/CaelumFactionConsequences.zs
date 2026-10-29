// #420: recibos por personaje; los informes explícitos son los únicos que
// comparten conocimiento con una facción. No hay búsquedas de testigos aquí.
class CaelumFactionAidEvent : Object play
{
    String Key;
    int Beneficiary, Gain, InformedMask;
}

class CaelumFactionConsequences : Object play
{
    const REVISION = 1;

    static void Ensure(CaelumPersistentCharacterState record)
    {
        if (record == null || record.FactionConsequencesRevision >= REVISION) return;
        record.EnsureFactionStateInitialized();
        for (int i = 0; i < CaelumConstants.FACTION_COUNT; i++)
            if (record.FactionMember[i] && record.FactionMembershipEpoch[i] == 0)
                record.FactionMembershipEpoch[i] = 1;
        // No inventar informes ni sancionar ayudas anteriores a este esquema.
        record.FactionConsequencesRevision = REVISION;
    }

    static CaelumFactionAidEvent Find(CaelumPersistentCharacterState record, String key)
    {
        if (record == null || key == "") return null;
        for (int i = 0; i < record.FactionAidEvents.Size(); i++)
            if (record.FactionAidEvents[i].Key == key) return record.FactionAidEvents[i];
        return null;
    }

    static bool GrantAid(CaelumPersistentCharacterState record, String key, int beneficiary, int gain)
    {
        if (record == null || key == "" || gain <= 0
            || !CaelumFactionRules.IsValidFactionId(beneficiary)) return false;
        Ensure(record);
        if (Find(record, key) != null) return false;
        let receipt = new("CaelumFactionAidEvent");
        receipt.Key = key; receipt.Beneficiary = beneficiary;
        int before = record.FactionReputation[beneficiary];
        record.ChangeFactionReputation(beneficiary, gain);
        receipt.Gain = record.FactionReputation[beneficiary] - before;
        record.FactionAidEvents.Push(receipt);
        return true;
    }

    static bool ReportAid(CaelumPersistentCharacterState record, String key, int informed)
    {
        if (record == null || !CaelumFactionRules.IsValidFactionId(informed)) return false;
        Ensure(record);
        let receipt = Find(record, key);
        if (receipt == null || (receipt.InformedMask & (1 << informed)) != 0) return false;
        receipt.InformedMask |= 1 << informed;
        if (CaelumFactionData.EnemyPair(informed, receipt.Beneficiary) && receipt.Gain > 0)
            record.ChangeFactionReputation(informed, -receipt.Gain);
        return true;
    }

    static bool ReportMembership(CaelumPersistentCharacterState record, int informed, int revealed, int epoch)
    {
        if (record == null || !CaelumFactionRules.IsValidFactionId(informed)
            || !CaelumFactionRules.IsValidFactionId(revealed) || informed == revealed || epoch <= 0) return false;
        Ensure(record);
        int slot = informed * CaelumConstants.FACTION_COUNT + revealed;
        if (record.FactionMembershipKnownEpoch[slot] >= epoch
            || epoch != record.FactionMembershipEpoch[revealed]) return false;
        record.FactionMembershipKnownEpoch[slot] = epoch;
        if (record.FactionMember[informed] && record.FactionMember[revealed])
        {
            record.SetFactionMembership(informed, false);
            record.ChangeFactionReputation(informed, -CaelumFactionData.DISCLOSURE_PENALTY);
        }
        return true;
    }
}
