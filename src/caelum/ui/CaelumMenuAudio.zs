// Conserva una única reproducción de TitleMusic por entrada a la portada.
// Las partidas y sus menús de pausa conservan la música del mapa.
class CaelumMenuAudio : StaticEventHandler
{
    ui bool TitleMusicReady;

    override void UiTick()
    {
        if (gamestate != GS_DEMOSCREEN)
        {
            TitleMusicReady = false;
            return;
        }
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
