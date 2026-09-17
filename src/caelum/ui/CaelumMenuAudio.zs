// Conserva una única reproducción de TitleMusic por entrada a la portada.
// Las partidas y sus menús de pausa conservan la música del mapa.
class CaelumMenuAudio : StaticEventHandler
{
    ui bool TitleMusicReady;
    ui bool TravelPresentationPending;
    ui int TravelWipe;

    override void InterfaceProcess(ConsoleEvent e)
    {
        if (e.Name == "ca_map_depart")
        {
            TravelPresentationPending = true;
            TravelWipe = e.Args[0];
        }
        else if (e.Name == "ca_map_arrive")
        {
            if (TravelPresentationPending && e.Args[0] == 0)
            {
                // Override nativo de una sola transición: no modifica wipetype.
                if (TravelWipe == 1) ScreenJobRunner.setTransition(1);
                // Emisión posterior a la limpieza de audio del mapa anterior.
                S_StartSound("caelum/ui/map_transition", CHAN_7, CHANF_UI, 1.0, ATTN_NONE);
            }
            TravelPresentationPending = false;
        }
    }

    override void WorldLoaded(WorldEvent e)
    {
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
