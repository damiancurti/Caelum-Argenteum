// Panel de pared finito para sectores apilados. Evita que una pared visual del
// primer piso genere colisión o textura en la planta baja.
class CaelumFiniteWallBlocker : Actor
{
    override void Tick()
    {
        Super.Tick();
        if (master == null)
        {
            Destroy();
            return;
        }

        CaelumFiniteWallPanel panel = CaelumFiniteWallPanel(master);
        if (panel == null)
        {
            Destroy();
            return;
        }

        vector3 blockerPos = panel.Pos;
        if (panel.args[0] == 0) { blockerPos.X += args[0]; }
        else { blockerPos.Y += args[0]; }
        SetOrigin(blockerPos, true);
    }

    Default
    {
        Radius 4;
        Height 120;
        +SOLID
        +NOGRAVITY
        +CANNOTPUSH
        +DONTTHRUST
        RenderStyle "None";
    }

    States
    {
    Spawn:
        TNT1 A -1;
        Stop;
    }
}

class CaelumFiniteWallPanel : Actor
{
    override void PostBeginPlay()
    {
        Super.PostBeginPlay();
        int panelWidth = args[1] > 0 ? args[1] : 64;
        Scale.X = panelWidth / 128.0;
        for (int offset = -panelWidth / 2 + 4;
             offset <= panelWidth / 2 - 4; offset += 8)
        {
            Actor blocker = Spawn("CaelumFiniteWallBlocker", Pos);
            if (blocker != null)
            {
                blocker.master = self;
                blocker.args[0] = offset;
            }
        }
    }

    Default
    {
        Radius 4;
        Height 120;
        XScale 0.5;
        YScale 0.9375;
        +SOLID
        +NOGRAVITY
        +CANNOTPUSH
        +DONTTHRUST
        +WALLSPRITE
        RenderStyle "Normal";
    }

    States
    {
    Spawn:
        CWAL A -1;
        Stop;
    }
}
