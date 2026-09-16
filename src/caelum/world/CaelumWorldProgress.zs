// Registro de observaciones en el Inventory viajero. El regreso narrativo y
// los accesos de alcantarilla conservan sus propias comprobaciones de salida.
class CaelumWorldProgress : Object play
{
    static bool HasReturnEvidence(CaelumPersistentCharacterState record)
    {
        return record != null
            && record.QuestState[0] == CaelumConstants.QUEST_STATE_COMPLETED
            && record.QuestStage[0] == CaelumConstants.MAIN_M00_STATE_COMPLETE
            && record.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_COMPLETE)
            && record.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_INVENTORY_SANITIZED)
            && record.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_STARTER_WEAPON_PRESERVED);
    }

    static void Update(CaelumPlayer user)
    {
        if (user == null || user.player == null || user.health <= 0
            || user.player.playerstate != PST_LIVE || !user.CharacterCreationComplete
            || user.CreationWizardOpen || (user.player.cheats & CF_PREDICTING)) return;
        let record = user.GetPersistentCharacterState(false);
        if (record == null || !record.ProfileCommitted) return;
        int locationId = CaelumWorldCatalogue.LocationForMap(level.MapName);
        if (record.WorldStateVersion == 0)
        {
            // Única inferencia para guardados anteriores: estar en MAP02 con
            // el regreso realmente cerrado. Entrar allí desde consola no basta.
            if (locationId == CaelumWorldCatalogue.LOCATION_SEWERS && HasReturnEvidence(record))
            {
                record.WorldLocationVisited[CaelumWorldCatalogue.LOCATION_MANSION] = true;
                record.WorldConnectionKnown[CaelumWorldCatalogue.CONNECTION_RETURN] = true;
                record.WorldConnectionTraversed[CaelumWorldCatalogue.CONNECTION_RETURN] = true;
            }
            record.WorldStateVersion = 1;
        }
        if (CaelumWorldCatalogue.IsLocation(locationId)) record.WorldLocationVisited[locationId] = true;

        CaelumJourneyState.Update(user);
        int pending = record.WorldPendingConnection;
        if (pending != CaelumWorldCatalogue.CONNECTION_NONE)
        {
            if (!CaelumWorldCatalogue.IsConnection(pending))
                record.WorldPendingConnection = CaelumWorldCatalogue.CONNECTION_NONE;
            else if (locationId != CaelumWorldCatalogue.ConnectionOrigin(pending))
            {
                // La marca sólo se consume en destino; otra llegada descarta
                // el intento. Guardar en origen no lo cuenta como recorrido.
                if (locationId == CaelumWorldCatalogue.ConnectionDestination(pending)
                    && (pending == CaelumWorldCatalogue.CONNECTION_RETURN
                        ? HasReturnEvidence(record) : CaelumWorldCatalogue.IsSewerConnection(pending)))
                {
                    record.WorldConnectionKnown[pending] = true;
                    record.WorldConnectionTraversed[pending] = true;
                }
                record.WorldPendingConnection = CaelumWorldCatalogue.CONNECTION_NONE;
            }
        }
        // Conocer la salida no revela las alcantarillas antes de llegar.
        if (CaelumMainM00Return.IsReady(user))
            record.WorldConnectionKnown[CaelumWorldCatalogue.CONNECTION_RETURN] = true;
        // La señal del acceso revela su destino, pero no lo marca visitado.
        let gates = ThinkerIterator.Create("CaelumSewerTravelGate");
        CaelumSewerTravelGate gate;
        while ((gate = CaelumSewerTravelGate(gates.Next())) != null)
            if (gate.Placed && CaelumWorldCatalogue.IsSewerConnection(gate.ConnectionId)
                && CaelumWorldCatalogue.ConnectionOrigin(gate.ConnectionId) == locationId
                && user.Distance2D(gate) <= 256 && Abs(user.Pos.Z-gate.Pos.Z) <= 64
                && user.CheckSight(gate))
                record.WorldConnectionKnown[gate.ConnectionId] = true;
    }

    static void RecordReturnDeparture(CaelumPlayer user)
    {
        if (user == null || user.player == null || (user.player.cheats & CF_PREDICTING)
            || CaelumWorldCatalogue.LocationForMap(level.MapName) != CaelumWorldCatalogue.LOCATION_MANSION) return;
        let record = user.GetPersistentCharacterState(false);
        if (!HasReturnEvidence(record)) return;
        // Llamado después de Commit y justo antes de ChangeLevel. No crea
        // registros, modifica misiones ni concede cartas/equipo/recompensas.
        record.WorldConnectionKnown[CaelumWorldCatalogue.CONNECTION_RETURN] = true;
        record.WorldPendingConnection = CaelumWorldCatalogue.CONNECTION_RETURN;
    }

    static void Report(CaelumPlayer user)
    {
        if (user == null) return;
        let record = user.GetPersistentCharacterState(false);
        Console.Printf("[Caelum 4.35.0d] Mundo: mapa=%s ubicación=%d registro=%d", level.MapName,
            CaelumWorldCatalogue.LocationForMap(level.MapName), record != null);
        if (record == null) return;
        Console.Printf("Versión=%d conexión pendiente=%d", record.WorldStateVersion, record.WorldPendingConnection);
        for (int id = 1; id < CaelumWorldCatalogue.LOCATION_DEFINED_COUNT; id++)
            Console.Printf("Ubicación %d (%s): visitada=%d", id,
                CaelumWorldCatalogue.MapForLocation(id), record.WorldLocationVisited[id]);
        for (int id = 1; id < CaelumWorldCatalogue.CONNECTION_DEFINED_COUNT; id++)
            Console.Printf("Conexión %d: origen=%d destino=%d conocida=%d recorrida=%d", id,
                CaelumWorldCatalogue.ConnectionOrigin(id), CaelumWorldCatalogue.ConnectionDestination(id),
                record.WorldConnectionKnown[id], record.WorldConnectionTraversed[id]);
    }
}
