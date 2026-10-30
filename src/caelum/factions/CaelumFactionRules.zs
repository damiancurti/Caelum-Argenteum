// Tabla central de relaciones V4.33.0a. Es una consulta O(1), apta para que
// la IA la use después de su filtrado espacial; nunca busca actores globales.
class CaelumFactionRules : Object
{
    static clearscope String GetNameKey(int factionId)
    {
        switch (factionId)
        {
            case CaelumConstants.FACTION_UNITARIOS: return "CA_FACTION_UNITARIOS";
            case CaelumConstants.FACTION_FEDERALS: return "CA_FACTION_FEDERALS";
            case CaelumConstants.FACTION_PUEBLOS_LIBRES: return "CA_FACTION_PUEBLOS_LIBRES";
            case CaelumConstants.FACTION_CAELITH: return "CA_FACTION_CAELITH";
            case CaelumConstants.FACTION_CULT_TAROT: return "CA_FACTION_CULT_TAROT";
            case CaelumConstants.FACTION_SUN_WARRIORS: return "CA_FACTION_SUN_WARRIORS";
        }
        return "CA_REP_UNKNOWN_FACTION";
    }

    static bool IsValidFactionId(int factionId)
    {
        return factionId >= 0 && factionId < CaelumConstants.FACTION_COUNT;
    }

    static int GetRelation(int sourceFactionId, int targetFactionId)
    {
        if (!IsValidFactionId(sourceFactionId)
            || !IsValidFactionId(targetFactionId))
        {
            return CaelumConstants.FACTION_RELATION_NEUTRAL;
        }

        // Matriz aprobada para #420; no atribuye identidad a ningún actor.
        if (sourceFactionId == targetFactionId)
        {
            return CaelumConstants.FACTION_RELATION_FRIENDLY;
        }
        if (CaelumFactionData.EnemyPair(sourceFactionId, targetFactionId))
            return CaelumConstants.FACTION_RELATION_HOSTILE;
        return CaelumConstants.FACTION_RELATION_NEUTRAL;
    }

    static bool HostileReputation(CaelumPersistentCharacterState record, int faction)
    {
        return record != null && IsValidFactionId(faction)
            && record.FactionReputation[faction] <= CaelumFactionData.HOSTILITY_MAXIMUM;
    }

    static int TradePrice(double value, int amount, bool selling, int reputation)
    {
        double factor = selling ? CaelumFactionData.SaleFactor(reputation)
            : CaelumFactionData.PurchaseFactor(reputation);
        if (factor <= 0 || value <= 0 || amount <= 0) return 0;
        // Redondear una vez, al final del lote, conserva los márgenes nativos.
        return selling ? CaelumEconomyRules.GetPricePaidByMerchant(value * factor, amount)
            : CaelumEconomyRules.GetPriceChargedByMerchant(value * factor, amount);
    }
}
