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

        // Sólo la identidad propia está definida. Toda relación cruzada se
        // mantiene neutral hasta recibir la matriz narrativa del autor.
        if (sourceFactionId == targetFactionId)
        {
            return CaelumConstants.FACTION_RELATION_FRIENDLY;
        }
        return CaelumConstants.FACTION_RELATION_NEUTRAL;
    }
}
