// Sustituye el status bar heredado de Doom. El HUD permanente se compone en
// CaelumHUDOverlay mientras la migración a BaseStatusBar continúa por módulos.
// Esta clase elimina de inmediato el rostro, las armas y la munición ajenas.
class CaelumStatusBar : BaseStatusBar
{
    override void Init()
    {
        Super.Init();
        SetSize(0, 640, 360);
    }

    override void Draw(int state, double ticFraction)
    {
        // Intencionalmente vacío: CaelumHUDOverlay dibuja la capa permanente.
    }
}
