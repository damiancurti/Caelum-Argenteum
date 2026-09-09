// Controlador reconstruible de MAP01. No guarda progreso propio: consulta el
// Inventory viajero de cada personaje y sólo ejecuta presentaciones pendientes.
class CaelumMainM00QuestController : EventHandler
{
    override void WorldTick()
    {
        if (level.MapName != "MAP01") { return; }

        for (int playerIndex = 0; playerIndex < MAXPLAYERS; playerIndex++)
        {
            if (!playeringame[playerIndex]) { continue; }
            CaelumPlayer caelumPlayer = CaelumPlayer(players[playerIndex].mo);
            if (caelumPlayer == null || caelumPlayer.player == null
                || (caelumPlayer.player.cheats & CF_PREDICTING))
            {
                continue;
            }
            caelumPlayer.UpdateMainM00Prologue();
        }
    }
}
