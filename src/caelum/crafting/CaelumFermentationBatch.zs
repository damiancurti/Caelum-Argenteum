// #471: estado serializable del lote; las recetas suministran sus propios datos.
// El reloj absoluto evita simular barriles ausentes o recorrer actores por tic.
class CaelumFermentationBatch : Object play
{
    const SCHEMA_REVISION = 1;
    int Revision;
    int Generation;
    int Recipe, OutputMaterial, OutputTier;
    int OriginalUnits, RemainingUnits;
    double WorkingLiters, StartedAt, ReadyAt;
    bool Occupied;

    // Un lote nuevo sólo ocupa un barril vacío. El llamador confirma primero
    // ingredientes y agua; este objeto no mantiene una segunda copia de ellos.
    bool Begin(int recipe, int material, int tier, int units,
        double liters, double durationSeconds, double now)
    {
        if (Occupied || recipe < 0 || material < 0 || tier < 1 || units <= 0
            || !(liters > 0) || liters > CaelumFermentationData.WORKING_CAPACITY_LITERS
            || !(durationSeconds > 0) || !(now >= 0)) return false;
        Revision = SCHEMA_REVISION;
        Generation++;
        Recipe = recipe; OutputMaterial = material; OutputTier = tier;
        OriginalUnits = units; RemainingUnits = units;
        WorkingLiters = liters; StartedAt = now; ReadyAt = now + durationSeconds;
        Occupied = true;
        return true;
    }

    clearscope bool Ready(double now)
    { return Occupied && Revision == SCHEMA_REVISION && now >= ReadyAt; }

    clearscope double SecondsLeft(double now)
    { return Occupied ? Max(0.0, ReadyAt - Max(StartedAt, now)) : 0.0; }

    // Se llama después del preflight y antes de entregar el inventario.
    // No recorta silenciosamente una petición inválida ni duplica el producto.
    bool Withdraw(int units, double now)
    {
        if (!Ready(now) || units <= 0 || units > RemainingUnits) return false;
        RemainingUnits -= units;
        if (RemainingUnits == 0) Clear();
        return true;
    }

    // Cancelar descarta el contenido; nunca reconstruye ingredientes.
    void Clear()
    {
        Generation++;
        Revision = SCHEMA_REVISION;
        Occupied = false; Recipe = -1; OutputMaterial = -1; OutputTier = 1;
        OriginalUnits = 0; RemainingUnits = 0;
        WorkingLiters = 0; StartedAt = 0; ReadyAt = 0;
    }
}
