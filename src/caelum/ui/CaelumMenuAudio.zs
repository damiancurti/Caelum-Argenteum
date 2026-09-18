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

    override void WorldTick()
    {
        if(consoleplayer<0 || !playeringame[consoleplayer])return;
        let user=CaelumPlayer(players[consoleplayer].mo);
        SnapshotWatching=false;
        if(user==null || CaptureSuspended)return;
        let plan=CaelumJourneyPlan.Get(user);
        SnapshotWatching=(plan!=null && plan.Open && plan.TravelMode!=CaelumJourneyState.MODE_FOOT)
            || (user.player.ConversationNPC is "CaelumCaravanGuide");
        if(!SnapshotWatching)
        {
            let vehicles=ThinkerIterator.Create("CaelumTravelVehicle");CaelumTravelVehicle vehicle;
            while((vehicle=CaelumTravelVehicle(vehicles.Next()))!=null)
                if((user.Pos-vehicle.BoardingPoint).Length()<200)SnapshotWatching=true;
        }
        if(!SnapshotWatching)return;
        // Cámara efímera mientras se confirma el viaje. Su textura conserva
        // el último fotograma cuando GZDoom descarga el mapa de origen.
        if(TravelCamera==null)TravelCamera=Actor(ThinkerIterator.Create("CaelumTravelSnapshotCamera").Next());
        if(TravelCamera==null)
            TravelCamera=Actor.Spawn("CaelumTravelSnapshotCamera",user.Pos,NO_REPLACE);
        if(TravelCamera==null)return;
        TravelCamera.SetOrigin(user.Pos+(0,0,user.ViewHeight),false);
        TravelCamera.Angle=user.Angle;TravelCamera.Pitch=user.Pitch;
        TexMan.SetCameraToTexture(TravelCamera,"CAJVIEW",user.player.FOV);
    }

    override void WorldUnloaded(WorldEvent e)
    {CaptureSuspended=true;SnapshotWatching=false;}

    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="ca_vehicle_snapshot_done" && e.Player==consoleplayer)CaptureSuspended=false;
    }

    override void RenderOverlay(RenderEvent e)
    {
        if(consoleplayer<0 || !playeringame[consoleplayer])return;
        if(!TravelSnapshot.isValid())
            TravelSnapshot=TexMan.CheckForTexture("CAJVIEW",TexMan.Type_Any);
        if(!TravelSnapshot.isValid())return;
        if(VehicleArrival)
        {
            // g4.14.2 bloquea las primeras 35 PRESENTACIONES de un hub.
            // Mantener el origen visible durante ese bloqueo permite que el
            // wipe nativo posterior mezcle realmente dos mapas diferentes.
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
                EventHandler.SendNetworkEvent("ca_vehicle_snapshot_done");
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
        if (e.Name == "ca_map_depart")
        {
            TravelPresentationPending = true;
            TravelWipe = e.Args[0];
            TravelSound = e.Args[1];
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
            if(e.Args[0]!=0){VehicleArrival=false;SnapshotFrames=0;}
            if (TravelPresentationPending && e.Args[0] == 0)
            {
                // Override nativo de una sola transición: no modifica wipetype.
                if((TravelWipe==1 || TravelWipe==3) && SnapshotFrames>=2)
                {VehicleArrival=true;ArrivalFrames=0;}
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
        let journey=CaelumJourneyState.Get(user);
        if(e.IsSaveGame || journey==null || (journey.TravelMode!=CaelumJourneyState.MODE_CART
            && journey.TravelMode!=CaelumJourneyState.MODE_CARAVAN && journey.TravelMode!=CaelumJourneyState.MODE_SHIP))
            CaptureSuspended=false;
        EventHandler.SendInterfaceEvent(consoleplayer, "ca_map_arrive", e.IsSaveGame ? 1 : 0);
    }

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
