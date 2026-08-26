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

// Los WALLSPRITE se dibujan por una sola cara. Este reverso replica solamente
// la imagen del panel maestro para que la pared también sea visible desde el
// interior, sin añadir un segundo conjunto de bloqueadores ni contactos.
class CaelumFiniteWallBackPanel : Actor
{
    override void Tick()
    {
        Super.Tick();
        if (master == null)
        {
            Destroy();
            return;
        }

        // Evita caras coplanares sin desplazar el reverso a lo largo del ancho.
        // El corrimiento sigue la normal local de la pared y es sólo visual.
        vector3 backPos = master.Pos;
        Vector2 backOffset = AngleToVector(master.Angle + 90.0, 0.25);
        backPos.X += backOffset.X;
        backPos.Y += backOffset.Y;
        SetOrigin(backPos, true);
        Angle = master.Angle + 180.0;
        Scale.X = master.Scale.X;
        Scale.Y = master.Scale.Y;
    }

    Default
    {
        Radius 1;
        Height 120;
        XScale 0.5;
        YScale 0.9375;
        // Debe permanecer enlazado al sector para que el renderer lo dibuje.
        // NOBLOCKMAP evita colisión sin ocultarlo como hacía NOINTERACTION.
        +NOBLOCKMAP
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

class CaelumFiniteWallPanel : Actor
{
    override void PostBeginPlay()
    {
        Super.PostBeginPlay();
        int panelWidth = args[1] > 0 ? args[1] : 64;
        Scale.X = panelWidth / 128.0;

        vector3 backPos = Pos;
        Vector2 backOffset = AngleToVector(Angle + 90.0, 0.25);
        backPos.X += backOffset.X;
        backPos.Y += backOffset.Y;
        Actor backPanel = Spawn("CaelumFiniteWallBackPanel", backPos);
        if (backPanel != null)
        {
            backPanel.master = self;
            backPanel.Angle = Angle + 180.0;
            backPanel.Scale.X = Scale.X;
            backPanel.Scale.Y = Scale.Y;
        }

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
