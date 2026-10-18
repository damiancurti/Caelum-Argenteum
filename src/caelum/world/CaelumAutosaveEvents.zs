// Un solo dueño del intervalo y de las solicitudes periódicas/checkpoint.
// El reloj UI mide tiempo real; sólo el puente de red puede solicitar la escritura.
class CaelumAutosaveEvents : StaticEventHandler
{
    int WorldSerial, ResetSerial;
    int LastRequestWorld, LastRequestTic, RequestCount;
    int QueueSerial, PendingSerial;
    int LastUnloadedWorld, LastUnloadAction, CompletedWorld, CompletedQueue;
    bool WorldReady, Travelling, Pending;
    bool AwaitingNativeCheck, AwaitingNativeDispatch, Dispatched, InspectArrival;

    ui double ActiveMilliseconds, LastSample;
    ui int SeenWorld, SeenReset;
    ui bool HasSample, WasActive, RequestSent;
    ui bool ReportedDispatch;
    ui int ReportedQueue;

    clearscope static CaelumAutosaveEvents Get()
    { return CaelumAutosaveEvents(StaticEventHandler.Find("CaelumAutosaveEvents")); }

    clearscope static bool Live(CaelumPlayer user)
    {
        return user != null && user.player != null && user.health > 0
            && user.player.playerstate == PST_LIVE && user.CharacterCreationComplete
            && !user.CreationWizardOpen && !(user.player.cheats & CF_PREDICTING);
    }

    void RestartInterval()
    { Pending = false; ResetSerial++; }

    override void WorldUnloaded(WorldEvent e)
    {
        LastUnloadedWorld = WorldSerial; LastUnloadAction = gameaction;
        if (Dispatched)
        {
            if (gameaction == CaelumSaveRules.NATIVE_ACTION_IDLE)
            {
                // El DO ya se ejecutó. Un viaje de red puede preceder al ACK.
                CompletedWorld = WorldSerial; CompletedQueue = QueueSerial;
                ResetSerial++;
            }
            else { Dispatched = false; Pending = true; }
        }
        WorldReady = false; WorldSerial++;
        Travelling = e.NextMap.Length() != 0;
    }

    override void WorldLoaded(WorldEvent e)
    {
        WorldReady = true; WorldSerial++;
        InspectArrival = Travelling && !e.IsSaveGame;
        // Cargar empieza un intervalo nuevo; viajar conserva el tiempo activo.
        // La discontinuidad WorldSerial excluye el tiempo empleado en la carga.
        if (e.IsSaveGame || !Travelling)
        {
            AwaitingNativeCheck = AwaitingNativeDispatch = Dispatched = false;
            QueueSerial++; RestartInterval();
        }
        Travelling = false;
    }

    override void UiTick()
    {
        double now = MSTimeF();
        if (SeenReset != ResetSerial)
        {
            SeenReset = ResetSerial; ActiveMilliseconds = 0; HasSample = false; RequestSent = false;
        }
        if (SeenWorld != WorldSerial)
        {
            SeenWorld = WorldSerial; HasSample = false; RequestSent = false;
        }
        let user = consoleplayer >= 0 ? CaelumPlayer(players[consoleplayer].mo) : null;
        bool active = WorldReady && gamestate == GS_LEVEL && paused == 0
            && menuactive == 0 && Menu.GetCurrentMenu() == null && ConsoleState == c_up
            && gameaction == CaelumSaveRules.NATIVE_ACTION_IDLE && !multiplayer && Live(user);
        double interval = CaelumSaveRules.ACTIVE_INTERVAL_SECONDS
            * CaelumSaveRules.MILLISECONDS_PER_SECOND;
        if (HasSample && WasActive && active)
            ActiveMilliseconds = Min(interval, ActiveMilliseconds + Max(0.0, now - LastSample));
        LastSample = now; HasSample = true; WasActive = active;
        if (active && !RequestSent && ActiveMilliseconds >= interval)
        {
            RequestSent = true;
            EventHandler.SendNetworkEvent("ca_periodic_autosave", WorldSerial, ResetSerial);
        }
    }

    override void PostUiTick()
    {
        // Después de los comandos demorados y de la simulación, ga_autosave
        // se ejecuta al comenzar el próximo G_Ticker, antes de este mensaje.
        // WorldSerial distingue una escritura de un cambio de mapa que la anuló.
        if (gameaction == CaelumSaveRules.NATIVE_ACTION_AUTOSAVE)
        {
            EventHandler.SendNetworkEvent("ca_autosave_finished", WorldSerial, QueueSerial, PendingSerial);
            ReportedDispatch = true; ReportedQueue = QueueSerial;
        }
        else
        {
            // La entrega de red puede demorar varios tics. No reinterpretar una
            // finalización ya enviada como cancelación mientras llega su ACK.
            if (Dispatched && (!ReportedDispatch || ReportedQueue != QueueSerial))
            {
                EventHandler.SendNetworkEvent("ca_autosave_cancelled", WorldSerial, QueueSerial);
                ReportedDispatch = true; ReportedQueue = QueueSerial;
            }
        }
    }

    override void NetworkProcess(ConsoleEvent e)
    {
        if (e.Player != consoleplayer) return;
        if (e.Name == "ca_autosave_finished")
        {
            if ((e.Args[0] == CompletedWorld && e.Args[1] == CompletedQueue)
                || e.Args[0] == WorldSerial || (e.Args[0] == LastUnloadedWorld
                && LastUnloadAction == CaelumSaveRules.NATIVE_ACTION_IDLE))
            {
                // Confirma la ejecución de la acción, no el éxito de IO.
                ResetSerial++;
                if (e.Args[1] == QueueSerial)
                {
                    Dispatched = false;
                    if (e.Args[2] == PendingSerial) Pending = false;
                }
            }
            else if (e.Args[1] == QueueSerial) { Dispatched = false; Pending = true; }
            return;
        }
        if (e.Name == "ca_autosave_cancelled")
        {
            if (e.Args[1] == QueueSerial) { Dispatched = false; Pending = true; }
            return;
        }
        if (e.Name == "ca_autosave_dispatched" && e.Player == consoleplayer
            && AwaitingNativeDispatch && e.Args[0] == QueueSerial)
        { AwaitingNativeDispatch = false; Dispatched = true; Pending = false; return; }
        if (e.Name == "ca_autosave_checked" && e.Player == consoleplayer
            && AwaitingNativeCheck && e.Args[0] == QueueSerial)
        {
            // El mensaje sigue inmediatamente a DEM_CHECKAUTOSAVE en el mismo
            // buffer. No hay simulación entre la comprobación nativa y este ACK.
            // Confirma la cola, nunca la escritura del archivo ni su éxito en disco.
            AwaitingNativeCheck = false;
            bool disabled = multiplayer || demoplayback
                || CVar.FindCVar("disableautosave").GetInt() >= 2
                || CVar.FindCVar("autosavecount").GetInt() == 0;
            if (disabled) RestartInterval();
            else if (players[consoleplayer].playerstate == PST_LIVE)
            {
                Pending = false; AwaitingNativeDispatch = true;
                // DEM_DOAUTOSAVE acaba de entrar en la cola; este segundo ACK
                // marca su despacho, incluso si se viaja entre ambos mensajes.
                EventHandler.SendNetworkEvent("ca_autosave_dispatched", QueueSerial);
            }
            else Pending = true;
            return;
        }
        if (e.Name != "ca_periodic_autosave" || multiplayer || e.Player != consoleplayer
            || e.Args[0] != WorldSerial || e.Args[1] != ResetSerial) return;
        if (AwaitingNativeCheck || AwaitingNativeDispatch || Dispatched
            || gameaction == CaelumSaveRules.NATIVE_ACTION_AUTOSAVE) return;
        Pending = true; PendingSerial++;
    }

    bool TryRequest(CaelumPlayer user)
    {
        if (AwaitingNativeCheck || AwaitingNativeDispatch || Dispatched || !WorldReady || gamestate != GS_LEVEL || gameaction != CaelumSaveRules.NATIVE_ACTION_IDLE
            || !Live(user)) return false;
        if (LastRequestWorld == WorldSerial && LastRequestTic == level.maptime)
        { Pending = false; return true; }
        LastRequestWorld = WorldSerial; LastRequestTic = level.maptime;
        Dispatched = false; AwaitingNativeCheck = true; QueueSerial++;
        user.A_CallSpecial(CaelumSaveRules.NATIVE_AUTOSAVE_SPECIAL);
        EventHandler.SendNetworkEvent("ca_autosave_checked", QueueSerial);
        RequestCount++;
        return true;
    }

    static void Checkpoint(CaelumPlayer user)
    {
        let owner = Get();
        if (owner == null) return;
        owner.Pending = true; owner.PendingSerial++;
        owner.TryRequest(user);
    }

    override void WorldTick()
    {
        if (InspectArrival)
        {
            InspectArrival = false;
            // DAutosaver no expone un tipo ZScript. Una sola consulta global de
            // STAT_DEFAULT por viaje adopta esa solicitud; incluye actores de
            // ese grupo. No vuelve a buscar durante el juego normal.
            let iterator = ThinkerIterator.Create("Thinker", Thinker.STAT_DEFAULT);
            Thinker saver;
            while ((saver = iterator.Next()) != null)
            {
                if (saver.GetClassName() != 'Autosaver') continue;
                saver.Destroy();
                if (!AwaitingNativeCheck && !AwaitingNativeDispatch
                    && gameaction != CaelumSaveRules.NATIVE_ACTION_AUTOSAVE)
                { Pending = true; PendingSerial++; }
            }
        }
        if (Pending && consoleplayer >= 0)
            TryRequest(CaelumPlayer(players[consoleplayer].mo));
    }
}
