// La muerte cooperativa conserva el cuerpo; Usar no crea otro personaje.
class CaelumSessionLifecycle : EventHandler
{
    bool DeadFoolHeld[MAXPLAYERS];
    override void WorldTick()
    {
        for(int i=0;i<MAXPLAYERS;i++)
        {
            if(!playeringame[i]){DeadFoolHeld[i]=false;continue;}
            let user=CaelumPlayer(players[i].mo);
            if(user==null || user.player==null)continue;
            bool pressed=(user.player.cmd.buttons&BT_USER3)!=0;
            if(user.health<=0 && pressed && !DeadFoolHeld[i] && CaelumFoolTravel.AllDead())
                CaelumFoolTravel.Propose(user,true);
            DeadFoolHeld[i]=pressed;
        }
    }
    static clearscope bool Waiting(CaelumPlayer user)
    {
        return multiplayer && CaelumPlayerAuthority.CanRead(user)
            && (user.health<=0 || user.player.playerstate==PST_DEAD);
    }
    static void CancelConsent()
    {
        // Las propuestas se comparten por referencia. La primera cancelación
        // cierra cada una; las demás réplicas no vuelven a aplicarla.
        for(int i=0;i<MAXPLAYERS;i++)
        {
            let user=CaelumPlayer(players[i].mo);if(user==null)continue;
            let clock=CaelumWorldClock(user.FindInventory('CaelumWorldClock'));if(clock==null)continue;
            if(clock.TimeVote!=null && clock.TimeVote.Opened)clock.TimeVote.FinishVote("CA_COOP_TIME_CANCELLED");
            if(clock.TravelVote!=null && clock.TravelVote.Opened)clock.TravelVote.Finish("CA_COOP_TRAVEL_CANCELLED");
        }
    }
    override void PlayerDied(PlayerEvent e)
    {if(multiplayer)CancelConsent();}
    override void PlayerDisconnected(PlayerEvent e)
    {if(multiplayer)CancelConsent();}
    override bool PlayerRespawning(PlayerEvent e)
    {return !Waiting(CaelumPlayer(players[e.PlayerNumber].mo));}
    override void NetworkProcess(ConsoleEvent e)
    {
        // El lanzador de recuperación común invalida consentimientos del
        // proceso anterior después de cargar el guardado acordado.
        if(e.Name=="ca_session_recover" && e.Player==0
            && CaelumPlayerAuthority.FromNetworkPlayer(e.Player,true)!=null)CancelConsent();
    }
}
