// El observador estático recibe la carga incluso al restaurar un guardado
// anterior. No guarda referencias de actores ni modifica registros de misión.
class CaelumConversationResume : StaticEventHandler
{
    bool RestoreSavedConversationPending;

    override void WorldLoaded(WorldEvent event)
    {
        // GZDoom guarda al interlocutor activo, pero no el menú USDF.
        // Sólo una carga de partida requiere reconstruir esa presentación.
        RestoreSavedConversationPending = event.IsSaveGame;
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
                || !speaker.HasConversation() || user.player.ConversationPC != user) continue;
            // Conserva el nodo nativo guardado y el ángulo original. No llama
            // a Used ni ejecuta respuestas, recompensas o flags de la misión.
            speaker.StartConversation(user, user.player.ConversationFaceTalker, false);
        }
    }

}
