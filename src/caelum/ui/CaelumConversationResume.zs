// El observador estático recibe la carga incluso al restaurar un guardado
// anterior. No guarda referencias de actores ni modifica registros de misión.
class CaelumConversationResume : StaticEventHandler
{
    bool RestoreSavedConversationPending;
    bool LegacyDialogueLayout[MAXPLAYERS];

    override void WorldLoaded(WorldEvent event)
    {
        // GZDoom guarda al interlocutor activo, pero no el menú USDF.
        // Sólo una carga de partida requiere reconstruir esa presentación.
        RestoreSavedConversationPending = event.IsSaveGame;
        for (int i = 0; i < MAXPLAYERS; i++)
        {
            LegacyDialogueLayout[i] = false;
            let user = playeringame[i] ? CaelumPlayer(players[i].mo) : null;
            let record = user == null ? null : user.GetPersistentCharacterState(false);
            // Capturar la revisión antes de que el controlador migre #34.
            if (event.IsSaveGame && record != null)
                LegacyDialogueLayout[i] = record.DemoNarrativeRevision < CaelumDemoNarrative.REVISION;
        }
    }

    override void WorldTick()
    {
        if (!RestoreSavedConversationPending) return;
        RestoreSavedConversationPending = false;
        for (int i = 0; i < MAXPLAYERS; i++)
        {
            if (!playeringame[i]) continue;
            let user = CaelumPlayer(players[i].mo);
            if (user == null || user.player == null || user.health <= 0
                || !user.CharacterCreationComplete || user.CreationWizardOpen
                || (user.player.cheats & CF_PREDICTING)) continue;
            CaelumJourneyState.Update(user, true);
            let speaker = user.player.ConversationNPC;
            if (speaker == null || !speaker.bInConversation || speaker.health <= 0
                || user.player.ConversationPC != user) continue;
            let voice = CaelumUnknownVoiceSpeaker(speaker);
            if (voice != null) voice.RestoreSavedDialogueLayout();
            else if (LegacyDialogueLayout[i])
            {
                // Otras charlas antiguas se cierran sin responder. Usar otra
                // vez al interlocutor enlaza su ID actual y conserva progreso.
                speaker.bInConversation = false;
                Level.ExecuteSpecial(CaelumConstants.GZDOOM_THING_SET_CONVERSATION_SPECIAL,
                    speaker, null, false, 0, 0);
                if (user.player.ConversationFaceTalker)
                    speaker.Angle = user.player.ConversationNPCAngle;
                user.player.ConversationNPC = null;
                user.player.ConversationPC = null;
                continue;
            }
            if (!speaker.HasConversation()) continue;
            // #96: la pausa del diálogo puede impedir el refresco periódico.
            // Reconstruir texto/tokens nuevos antes de restaurar una página
            // antigua de equipo o de Caella, sin ejecutar la entrega.
            if (speaker is "CaelumPalomo" || speaker is "CaelumCaella")
                CaelumMainM00Loadout.Refresh(user);
            // Conserva el nodo nativo guardado y el ángulo original. No llama
            // a Used ni ejecuta respuestas, recompensas o flags de la misión.
            speaker.StartConversation(user, user.player.ConversationFaceTalker, false);
        }
    }

}
