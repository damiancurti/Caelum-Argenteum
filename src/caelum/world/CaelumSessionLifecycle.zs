// La muerte cooperativa conserva el cuerpo; Usar no crea otro personaje.
class CaelumSessionLifecycle : EventHandler
{
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
}

// El puente estático también se instala al abrir guardados anteriores.
// La clase serializada antigua permanece válida y sin callbacks duplicados.
class CaelumSessionLifecycleEvents : StaticEventHandler
{
    bool DeadFoolHeld[MAXPLAYERS];
    bool CheckArrival;
    transient Vector3 ArrivalPlaces[MAXPLAYERS];

    bool ClearOfPlayers(CaelumPlayer body, vector3 spot)
    {
        for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])
        {
            let other=players[i].mo;
            if(other==null || other==body || other.health<=0)continue;
            double width=body.Radius+other.Radius;
            vector3 otherSpot=ArrivalPlaces[i];
            if(spot.Z<otherSpot.Z+other.Height && spot.Z+body.Height>otherSpot.Z
                && Abs(spot.X-otherSpot.X)<width && Abs(spot.Y-otherSpot.Y)<width)return false;
        }
        return true;
    }

    void PlanArrival(int slot,CaelumPlayer body)
    {
        // Sólo corrige un punto inicial compartido. Conserva el del primer puesto.
        bool shared=false;
        for(int i=0;i<slot;i++)if(playeringame[i] && players[i].mo!=null && players[i].mo.Pos==body.Pos)
            shared=true;
        if(!shared)return;
        // Búsqueda local una vez al llegar. Comprobar también el trayecto evita
        // colocar al compañero tras un muro fino o al otro lado de un desnivel.
        for(int ring=1;ring<=MAXPLAYERS;ring++)for(int spoke=0;spoke<8;spoke++)
        {
            double angle=body.Angle+45*(spoke+slot-1);
            double stride=Max(1.,body.Radius*2+1);
            vector2 delta=(cos(angle),sin(angle))*stride*ring;
            FCheckPosition fit;
            bool clear=true;
            double floor=body.FloorZ;
            for(int step=1;step<=4*ring;step++)
            {
                vector2 point=body.Pos.XY+delta*step/(4*ring);
                if(!body.CheckPosition(point,false,fit) || fit.ceilingz-fit.floorz<body.Height
                    || Abs(fit.floorz-floor)>body.MaxStepHeight || fit.floorz-fit.dropoffz>body.MaxDropOffHeight)
                {clear=false;break;}
                floor=fit.floorz;
            }
            vector3 spot=(body.Pos.XY+delta,floor);
            if(clear && ClearOfPlayers(body,spot))
            {ArrivalPlaces[slot]=spot;return;}
        }
    }
    override void WorldLoaded(WorldEvent e)
    {
        for(int i=0;i<MAXPLAYERS;i++)DeadFoolHeld[i]=false;
        CheckArrival=multiplayer && !e.IsSaveGame;
    }
    override void WorldTick()
    {
        if(CheckArrival)
        {
            bool ready=true;
            for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i] && players[i].mo==null)ready=false;
            if(ready)
            {
                CheckArrival=false;
                // Reservar primero todos los destinos: los primeros cuerpos no deben
                // bloquear el trayecto de las últimas plazas durante la búsqueda.
                for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])ArrivalPlaces[i]=players[i].mo.Pos;
                for(int i=1;i<MAXPLAYERS;i++)if(playeringame[i])
                {
                    let body=CaelumPlayer(players[i].mo);
                    if(body!=null && body.health>0 && !(body is 'CaelumStandalonePlayer'))PlanArrival(i,body);
                }
                for(int i=1;i<MAXPLAYERS;i++)if(playeringame[i])
                {
                    let body=players[i].mo;
                    if(body.Pos!=ArrivalPlaces[i] && body.TryMove(ArrivalPlaces[i].XY,false))body.ClearInterpolation();
                }
            }
        }
        for(int i=0;i<MAXPLAYERS;i++)
        {
            if(!playeringame[i]){DeadFoolHeld[i]=false;continue;}
            let user=CaelumPlayer(players[i].mo);
            if(user==null || user.player==null || user is 'CaelumStandalonePlayer')continue;
            bool pressed=(user.player.cmd.buttons&BT_USER3)!=0;
            if(user.health<=0 && pressed && !DeadFoolHeld[i] && CaelumFoolTravel.AllDead())
                CaelumFoolTravel.Propose(user,true);
            DeadFoolHeld[i]=pressed;
        }
    }
    override void PlayerDied(PlayerEvent e)
    {if(multiplayer)CaelumSessionLifecycle.CancelConsent();}
    override void PlayerDisconnected(PlayerEvent e)
    {if(multiplayer)CaelumSessionLifecycle.CancelConsent();}
    override bool PlayerRespawning(PlayerEvent e)
    {
        let user=CaelumPlayer(players[e.PlayerNumber].mo);
        if(user is 'CaelumStandalonePlayer')
        {let match=CaelumStandaloneMatch.View();return match!=null && match.RespawnAllowed(e.PlayerNumber);}
        return !CaelumSessionLifecycle.Waiting(user);
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        // El lanzador de recuperación común invalida consentimientos del
        // proceso anterior después de cargar el guardado acordado.
        if(e.Name=="ca_session_recover" && e.Player==0
            && CaelumPlayerAuthority.FromNetworkPlayer(e.Player,true)!=null)CaelumSessionLifecycle.CancelConsent();
    }
}
