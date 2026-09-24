// Tabla central de relaciones V4.33.0a. Es una consulta O(1), apta para que
// la IA la use después de su filtrado espacial; nunca busca actores globales.
class CaelumFactionRules : Object
{
    static clearscope String GetNameKey(int factionId)
    {
        switch (factionId)
        {
            case CaelumConstants.FACTION_GENDARMERIA: return "CA_FACTION_GENDARMERIA";
            case CaelumConstants.FACTION_SETTLEMENTS: return "CA_FACTION_SETTLEMENTS";
            case CaelumConstants.FACTION_CARAVANS: return "CA_FACTION_CARAVANS";
            case CaelumConstants.FACTION_POLITICAL_ACTORS: return "CA_FACTION_POLITICAL_ACTORS";
            case CaelumConstants.FACTION_UNITARIOS: return "CA_FACTION_UNITARIOS";
            case CaelumConstants.FACTION_FEDERALS: return "CA_FACTION_FEDERALS";
            case CaelumConstants.FACTION_WILD_BEAST_MEN: return "CA_FACTION_WILD_BEAST_MEN";
            case CaelumConstants.FACTION_CULT_TAROT: return "CA_FACTION_CULT_TAROT";
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
