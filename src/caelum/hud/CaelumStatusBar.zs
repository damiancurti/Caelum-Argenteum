// Sustituye el status bar heredado de Doom. El HUD permanente se compone en
// CaelumHUDOverlay mientras la migración a BaseStatusBar continúa por módulos.
// Esta clase elimina de inmediato el rostro, las armas y la munición ajenas.
class CaelumStatusBar : BaseStatusBar
{
    override void ShowPop(int popnum)
    {
        // Los comandos heredados llegan a las fuentes propias, sin pantallas Strife.
        if(popnum==POP_Log)CaelumExplorationNavigation.OpenPage(4);
        else if(popnum==POP_Keys)CaelumExplorationNavigation.Command("ca_keys_open");
        else if(popnum==POP_Status)CaelumExplorationNavigation.OpenPage(1);
    }
    override void Init()
    {
        Super.Init();
        SetSize(0, 640, 360);
    }

    override void Draw(int state, double ticFraction)
    {
        // BaseStatusBar conserva la mira nativa, sin barras ni arte de Doom.
        if(state!=HUD_AltHud && CaelumPresentation.CrosshairVisible())Super.Draw(HUD_Fullscreen,ticFraction);
    }
}
