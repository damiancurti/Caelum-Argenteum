// Consulta explícita del cierre 4.33. Lee los registros y objetos existentes;
// no inicializa, migra, corrige, activa pruebas ni entrega recompensas.
class CaelumIntegrationDiagnostics : Object play
{
    static String QuestStatus(int value)
    {
        switch (value)
        {
            case CaelumConstants.QUEST_STATE_UNDISCOVERED: return "no descubierta";
            case CaelumConstants.QUEST_STATE_ACTIVE: return "activa";
            case CaelumConstants.QUEST_STATE_COMPLETED: return "completada";
            case CaelumConstants.QUEST_STATE_FAILED: return "fallida";
            case CaelumConstants.QUEST_STATE_OFFERED: return "ofrecida";
            case CaelumConstants.QUEST_STATE_ABANDONED: return "abandonada";
        }
        return "desconocido";
    }

    static void ReportCondition(CaelumPlayer user, String label,
        CaelumFactionCondition condition)
    {
        if (condition == null)
        { Console.Printf("%s: sin condición asignada.", label); return; }
        Console.Printf("%s: configurada=%d facción=%d mínimo=%d miembro requerido=%d resultado=%d",
            label, condition.Configured, condition.FactionId,
            condition.MinimumReputation, condition.RequireMembership,
            CaelumFactionCondition.Check(user, condition));
    }

    static void Report(CaelumPlayer user)
    {
        if (user == null || user.player == null) return;
        Console.Printf("[Caelum 4.33.0ao] Integración 4.33 — consulta sin cambios (1=sí, 0=no)");
        Console.Printf("Mapa=%s jugador=%d creado=%d vida=%d conversación activa=%d",
            level.MapName, user.PlayerNumber(), user.CharacterCreationComplete,
            user.health, user.HasActiveConversation());
        let record = user.GetPersistentCharacterState(false);
        if (record == null)
        { Console.Printf("Registro de personaje ausente."); return; }

        Console.Printf("MAIN_M00=%s fase=%d El Loco=%d cartas=%d",
            QuestStatus(record.QuestState[0]), record.QuestStage[0],
            record.HasTarotCard(CaelumConstants.TAROT_THE_FOOL), record.CountTarotCards());
        let box = CaelumMagicBox(user.FindInventory("CaelumMagicBox"));
        let first = user.FindNativeEquipmentItemById(record.MainM00StarterWeaponId);
        Console.Printf("Caja propia válida=%d id objeto/registro=%d/%d; primera arma id=%d presente=%d en Caja=%d",
            CaelumMainM00FoolCapture.HasOwnedBox(user), box == null ? 0 : box.ItemId,
            record.MagicBoxItemId, record.MainM00StarterWeaponId,
            first != null, first != null && first.InMagicBox);
        Console.Printf("Salida confirmada=%d fundido=%d limpieza=%d llegada oída=%d",
            record.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_EXIT_CONFIRMED),
            record.MainM00ReturnTics,
            record.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_INVENTORY_SANITIZED),
            record.MainM00SewerVoiceHeard);
        Console.Printf("Prueba de misiones habilitada=%d", record.QuestTrialEnabled);
        for (int id = CaelumConstants.QUEST_TRIAL_ROUTE;
            id <= CaelumConstants.QUEST_TRIAL_WAIT; id++)
        {
            int slot = record.GetQuestObjectiveStorageIndex(id, 0);
            let receipt = user.FindInventory(CaelumSideQuestRules.RewardType(id));
            Console.Printf("Misión %d=%s objetivo conocido=%d progreso=%d/%d entrega registrada=%d constancia=%d",
                id, QuestStatus(record.QuestState[id]), record.QuestObjectiveKnown[slot],
                record.QuestObjectiveProgress[slot], record.QuestObjectiveTarget[slot],
                record.QuestRewardClaimed[id], receipt == null ? 0 : receipt.Amount);
        }
        Console.Printf("Recorrido: mapa de aceptación=%s; Espera: tics=%d última vida=%d",
            record.QuestTrialMap, record.QuestTrialWaitTics, record.QuestTrialLastHealth);
        for (int faction = 0; faction < CaelumConstants.FACTION_COUNT; faction++)
            Console.Printf("Facción %d (%s): reputación=%d miembro=%d", faction,
                StringTable.Localize(CaelumFactionRules.GetNameKey(faction), false),
                record.FactionReputation[faction], record.FactionMember[faction]);

        Console.Printf("Comercio abierto=%d válido=%d precio mostrado=%d rebaja negociada=%d rebaja de sesión=%d",
            user.PalomoMerchantMenuOpen, user.IsActivePalomoMerchantSessionValid(),
            user.PalomoMerchantSelectedLotPrice, record.PalomoDiscountGranted,
            user.PalomoMerchantReputationDiscount);
        ReportCondition(user, "Condición de comercio", user.ActivePalomoMerchantRequirement);
        ReportCondition(user, "Condición de rebaja", user.ActivePalomoMerchantDiscountCondition);
        Console.Printf("Resultados: 0 permite; 1 configuración inválida; 2 jugador/registro no disponible; 3 falta pertenencia; 4 falta reputación.");
        let trialState = CaelumReputationTrialState.Get(user);
        Console.Printf("Prueba de reputación habilitada=%d", trialState != null);
        if (trialState != null)
        {
            Console.Printf("Presentación: mapa=%s guía=%d dueño correcto=%d acción pendiente=%d puerta=%d",
                trialState.PresentationMap, trialState.Guide != null,
                trialState.Guide != null && trialState.Guide.Subject == user,
                trialState.Guide == null ? 0 : trialState.Guide.QueuedAction,
                trialState.Door != null);
            if (trialState.Door != null)
                ReportCondition(user, "Condición de puerta", trialState.Door.AccessCondition);
        }
        Console.Printf("Canal=%d adrenalina=%.2f recarga=%.2f tarea de fabricación=%d sesión de oficios=%d",
            user.CombatChannelModeActive, user.CurrentAdrenaline,
            user.CombatChannelCooldownRemaining, user.CraftingTaskActive,
            user.CraftingMenuOpen);
        Console.Printf("[Fin de consulta 4.33]");
    }
}
