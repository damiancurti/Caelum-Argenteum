// Tabla central de relaciones V4.33.0a. Es una consulta O(1), apta para que
// la IA la use después de su filtrado espacial; nunca busca actores globales.
class CaelumFactionRules : Object
{
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
