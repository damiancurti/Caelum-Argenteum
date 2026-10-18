// Conserva una única reproducción de TitleMusic por entrada a la portada.
// Las partidas y sus menús de pausa conservan la música del mapa.
class CaelumMenuAudio : StaticEventHandler
{
    ui bool TitleMusicReady;
    ui bool TravelPresentationPending;
    ui int TravelWipe;
    ui int TravelSound;
    Actor TravelCamera;
    bool CaptureSuspended;
    bool SnapshotWatching;
    ui TextureID TravelSnapshot;
    ui int SnapshotFrames;
    ui int ArrivalFrames;
    ui bool VehicleArrival;
    ui String SnapshotMap;
    CaelumHousePortal PendingHousePortal;
    CaelumPlayer PendingHouseUser;
    String PendingHouseMap,HouseDestinationMap;
    int HouseRequest;
    bool HousePresentationActive,HouseTravelCommitted,HouseArrived;
    ui int HouseCaptureRequest;
    ui bool HouseCapturing,HouseSourceFrozen,HouseArrival;

    play void CancelHouseDoor()
    {
        PendingHousePortal=null;PendingHouseUser=null;
        HousePresentationActive=false;HouseTravelCommitted=false;HouseArrived=false;
        CaptureSuspended=false;SnapshotWatching=false;
        EventHandler.SendInterfaceEvent(consoleplayer,"ca_house_capture_cancel",HouseRequest);
    }

    play bool RequestHouseDoor(CaelumPlayer user,CaelumHousePortal portal)
    {
        if(HousePresentationActive || user!=players[consoleplayer].mo)return false;
        HouseRequest++;PendingHousePortal=portal;PendingHouseUser=user;PendingHouseMap=level.MapName;
        HouseDestinationMap=portal.DestinationMap();
        HousePresentationActive=true;HouseTravelCommitted=false;HouseArrived=false;
        CaptureSuspended=false;SnapshotWatching=true;
        if(!UpdateTravelCamera(user)){CancelHouseDoor();return false;}
        EventHandler.SendInterfaceEvent(consoleplayer,"ca_house_capture_begin",HouseRequest);
        return true;
    }

    override void WorldTick()
    {
        if(consoleplayer<0 || !playeringame[consoleplayer])return;
        let user=CaelumPlayer(players[consoleplayer].mo);
        SnapshotWatching=false;
        if(HousePresentationActive && !HouseTravelCommitted
            && (PendingHouseUser==null || PendingHouseUser.health<=0 || PendingHousePortal==null
                || PendingHouseMap!=level.MapName))CancelHouseDoor();
        if(user==null || CaptureSuspended)return;
        let plan=CaelumJourneyPlan.Get(user);
        SnapshotWatching=HousePresentationActive || (plan!=null && plan.Open && plan.TravelMode!=CaelumJourneyState.MODE_FOOT)
            || (user.player.ConversationNPC is "CaelumCaravanGuide");
        if(!SnapshotWatching)
        {
            let vehicles=ThinkerIterator.Create("CaelumTravelVehicle");CaelumTravelVehicle vehicle;
            while((vehicle=CaelumTravelVehicle(vehicles.Next()))!=null)
                if((user.Pos-vehicle.BoardingPoint).Length()<200)SnapshotWatching=true;
        }
        if(!SnapshotWatching)return;
        UpdateTravelCamera(user);
    }

    play bool UpdateTravelCamera(CaelumPlayer user)
    {
        if(HousePresentationActive)
        {
            // El visor real excluye su propio cuerpo; una cámara auxiliar
            // colocada dentro del personaje puede capturar su modelo.
            TexMan.SetCameraToTexture(user,"CAJVIEW",user.player.FOV);
            return true;
        }
        // Cámara efímera mientras se confirma el viaje. Su textura conserva
        // el último fotograma cuando GZDoom descarga el mapa de origen.
        if(TravelCamera==null)TravelCamera=Actor(ThinkerIterator.Create("CaelumTravelSnapshotCamera").Next());
        if(TravelCamera==null)
            TravelCamera=Actor.Spawn("CaelumTravelSnapshotCamera",user.Pos,NO_REPLACE);
        if(TravelCamera==null)return false;
        TravelCamera.SetOrigin(user.Pos+(0,0,user.ViewHeight),false);
        TravelCamera.Angle=user.Angle;TravelCamera.Pitch=user.Pitch;
        TexMan.SetCameraToTexture(TravelCamera,"CAJVIEW",user.player.FOV);
        return true;
    }

    play bool FreezeHouseSnapshot(CaelumPlayer user)
    {
        if(user==null)return false;
        // No existe una API para desligar la textura; null provoca un fallo
        // nativo. El binding de un actor destruido deja de renderizar sin
        // borrar sus píxeles ni conservar una cámara viva en el hub.
        let retired=Actor.Spawn("CaelumTravelSnapshotCamera",user.Pos,NO_REPLACE);
        if(retired==null)return false;
        TexMan.SetCameraToTexture(retired,"CAJVIEW",user.player.FOV);
        retired.Destroy();
        return true;
    }

    override void WorldUnloaded(WorldEvent e)
    {
        if(HousePresentationActive && (!HouseTravelCommitted || HouseArrived
            || level.MapName!=PendingHouseMap || e.NextMap!=HouseDestinationMap))CancelHouseDoor();
        CaptureSuspended=true;SnapshotWatching=false;
    }

    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Player!=consoleplayer)return;
        if(e.Name=="ca_house_capture_ready" && HousePresentationActive && !HouseTravelCommitted
            && e.Args[0]==HouseRequest)
        {
            let portal=PendingHousePortal;let user=PendingHouseUser;
            PendingHousePortal=null;PendingHouseUser=null;
            // Consumir la solicitud antes de ChangeLevel impide ACK duplicados.
            HouseTravelCommitted=true;CaptureSuspended=true;SnapshotWatching=false;
            if(portal==null || PendingHouseMap!=level.MapName || user!=players[consoleplayer].mo
                || !FreezeHouseSnapshot(user)
                || !portal.CompleteTravel(user))CancelHouseDoor();
        }
        if(e.Name=="ca_house_wipe_done" && HousePresentationActive && HouseTravelCommitted
            && e.Args[0]==HouseRequest)CancelHouseDoor();
        if(e.Name=="ca_vehicle_snapshot_done" && !HousePresentationActive)CaptureSuspended=false;
    }

    override void RenderOverlay(RenderEvent e)
    {
        if(consoleplayer<0 || !playeringame[consoleplayer])return;
        if(!TravelSnapshot.isValid())
            TravelSnapshot=TexMan.CheckForTexture("CAJVIEW",TexMan.Type_Any);
        if(!TravelSnapshot.isValid())return;
        if(HouseCapturing || HouseSourceFrozen)
        {
            TexMan.SetCameraTextureAspectRatio("CAJVIEW",Screen.GetWidth()*9.0/(Screen.GetHeight()*16.0),true);
            if(HouseCapturing)
            {
                Screen.DrawTexture(TravelSnapshot,false,0,0,DTA_DestWidth,1,DTA_DestHeight,1,DTA_Alpha,0.001);
                if(++SnapshotFrames>=2)
                {
                    HouseCapturing=false;HouseSourceFrozen=true;
                    EventHandler.SendNetworkEvent("ca_house_capture_ready",HouseCaptureRequest);
                }
            }
            // El último cuadro del origen ya muestra la misma imagen que se
            // sostiene al llegar: no revela antes el mapa de destino.
            if(HouseSourceFrozen)Screen.DrawTexture(TravelSnapshot,false,0,0,
                DTA_DestWidth,Screen.GetWidth(),DTA_DestHeight,Screen.GetHeight());
            return;
        }
        if(VehicleArrival)
        {
            // g4.14.2 inicia el bloqueo de 35 PRESENTACIONES en ChangeLevel.
            // Sostener el origen otras 35 al llegar cubre cualquier remanente;
            // el wipe explícito posterior mezcla los dos mapas diferentes.
            if(ArrivalFrames<35)
            {
                Screen.DrawTexture(TravelSnapshot,false,0,0,DTA_DestWidth,Screen.GetWidth(),
                    DTA_DestHeight,Screen.GetHeight());
                ArrivalFrames++;
                if(ArrivalFrames==35)ScreenJobRunner.setTransition(TravelWipe);
            }
            else
            {
                VehicleArrival=false;SnapshotFrames=0;
                EventHandler.SendInterfaceEvent(consoleplayer,"ca_vehicle_wipe_visible",TravelWipe);
                if(HouseArrival)EventHandler.SendNetworkEvent("ca_house_wipe_done",HouseCaptureRequest);
                else EventHandler.SendNetworkEvent("ca_vehicle_snapshot_done");
                HouseArrival=false;
            }
            return;
        }
        if(!SnapshotWatching)return;
        if(SnapshotMap!=level.MapName){SnapshotMap=level.MapName;SnapshotFrames=0;}
        TexMan.SetCameraTextureAspectRatio("CAJVIEW",Screen.GetWidth()*9.0/(Screen.GetHeight()*16.0),true);
        // Mantener activa la textura sin añadir una segunda vista al menú.
        Screen.DrawTexture(TravelSnapshot,false,0,0,DTA_DestWidth,1,DTA_DestHeight,1,DTA_Alpha,0.001);
        SnapshotFrames++;
    }


    override void InterfaceProcess(ConsoleEvent e)
    {
        if(e.Name=="ca_house_capture_begin")
        {
            HouseCaptureRequest=e.Args[0];HouseCapturing=true;HouseSourceFrozen=false;HouseArrival=false;
            VehicleArrival=false;SnapshotFrames=0;ArrivalFrames=0;TravelPresentationPending=false;
            SnapshotMap=level.MapName;
        }
        else if(e.Name=="ca_house_capture_cancel" && e.Args[0]==HouseCaptureRequest)
        {
            HouseCapturing=false;HouseSourceFrozen=false;HouseArrival=false;
            VehicleArrival=false;SnapshotFrames=0;TravelPresentationPending=false;
        }
        if (e.Name == "ca_map_depart")
        {
            TravelPresentationPending = true;
            TravelWipe = e.Args[0];
            TravelSound = e.Args[1];
            if(TravelWipe==CaelumConstants.TRAVEL_WIPE_HOUSE_DOOR)
            {
                // Decisión del autor: derretido en ambos sentidos, sin tocar
                // wipetype. La captura pertenece a esta puerta, no al vehículo.
                VehicleArrival=false;ArrivalFrames=0;HouseArrival=true;
                TravelWipe=1;
            }
        }
        else if (e.Name == "ca_tarot_reveal")
        {
            // Acorde de MAP01 al descubrir la carta, independiente de cámara.
            S_StartSound("caelum/tarot/card_capture", CHAN_7, CHANF_UI, 1.0, ATTN_NONE);
        }
        else if (e.Name == "ca_tarot_capture")
        {
            // Sólo tras confirmar la captura y aplicar el bonus persistente.
            S_StartSound("caelum/player/level_up", CHAN_7, CHANF_UI, 0.8, ATTN_NONE);
        }
        else if (e.Name == "ca_map_arrive")
        {
            HouseCapturing=false;HouseSourceFrozen=false;
            if(e.Args[0]!=0){VehicleArrival=false;SnapshotFrames=0;}
            if (TravelPresentationPending && e.Args[0] == 0)
            {
                // Override nativo de una sola transición: no modifica wipetype.
                if((TravelWipe==1 || TravelWipe==3) && SnapshotFrames>=2)
                {
                    // Un Melt inicial de dos imágenes idénticas aún desplaza
                    // sus columnas. Fade mantiene esa captura estable mientras
                    // vence NoWipe; luego se presenta el único Melt visible.
                    if(HouseArrival)ScreenJobRunner.setTransition(3);
                    VehicleArrival=true;ArrivalFrames=0;
                }
                else if (TravelWipe >= 1 && TravelWipe <= 3) ScreenJobRunner.setTransition(TravelWipe);
                // Emisión posterior a la limpieza de audio del mapa anterior.
                Sound cue = TravelSound == 1 ? "caelum/travel/carriage"
                    : TravelSound == 2 ? "caelum/travel/ship" : "caelum/ui/map_transition";
                S_StartSound(cue, CHAN_7, CHANF_UI, 1.0, ATTN_NONE);
            }
            if(!VehicleArrival)EventHandler.SendNetworkEvent("ca_vehicle_snapshot_done");
            TravelPresentationPending = false;
        }
    }

    override void WorldLoaded(WorldEvent e)
    {
        TravelCamera=null;
        let user=consoleplayer>=0?CaelumPlayer(players[consoleplayer].mo):null;
        if(HousePresentationActive)
        {
            if(e.IsSaveGame || !HouseTravelCommitted || HouseArrived || level.MapName!=HouseDestinationMap)
                CancelHouseDoor();
            else if(FreezeHouseSnapshot(user))HouseArrived=true;
            else CancelHouseDoor();
        }
        let journey=CaelumJourneyState.Get(user);
        if(!HousePresentationActive && (e.IsSaveGame || journey==null || (journey.TravelMode!=CaelumJourneyState.MODE_CART
            && journey.TravelMode!=CaelumJourneyState.MODE_CARAVAN && journey.TravelMode!=CaelumJourneyState.MODE_SHIP)))
            CaptureSuspended=false;
        EventHandler.SendInterfaceEvent(consoleplayer, "ca_map_arrive", e.IsSaveGame ? 1 : 0);
    }

    override void NewGame(){if(HousePresentationActive)CancelHouseDoor();}

    override void UiTick()
    {
        if (gamestate != GS_DEMOSCREEN)
        {
            TitleMusicReady = false;
            return;
        }
        TravelPresentationPending = false;
        if (!TitleMusicReady && System.MusicEnabled() && musplaying.name != "")
        {
            // Reutiliza la pieza elegida por MAPINFO; respeta los volúmenes y
            // la prioridad de una lista de reproducción elegida por el usuario.
            TitleMusicReady = S_ChangeMusic(musplaying.name, musplaying.baseorder, false);
        }
    }
}

// El motivo de salida empieza al abrir la confirmación, mientras el audio
// sigue disponible. No se confía sólo en QuitSound durante el cierre del motor.
// Se reenvía en el primer tic, cuando GZDoom ya activó este menú intermediario.
class CaelumExitMenu : ListMenu
{
    bool Forwarded;

    override void Init(Menu parent, ListMenuDescriptor desc)
    {
        Super.Init(parent, desc);
        Forwarded = false;
    }

    override void Ticker()
    {
        if (Forwarded) return;
        Forwarded = true;
        // La confirmación debe volver al menú padre al cancelar, no a este
        // reenvío sin contenido. Close no ejecuta el comando de salida.
        Close();
        Menu.SetMenu("QuitMenu");
        MenuSound("caelum/stock/menu_strings_start");
    }

    override void Drawer() {}
}

// La cámara no tiene colisión, interacción ni estado persistente de viaje.
class CaelumTravelSnapshotCamera : Actor
{
    Default { +NOINTERACTION +NOGRAVITY RenderStyle "None"; }
    States { Spawn: TNT1 A -1; Stop; }
}
