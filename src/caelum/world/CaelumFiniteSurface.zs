// Superficies horizontales finitas para enlaces apilados que cruzan varios
// sectores inferiores sin modificar su topología.
class CaelumFiniteRoofBlocker : Actor
{
    Default
    {
        Radius 8;
        Height 8;
        +SOLID
        +CANPASS
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

class CaelumFiniteFloorPanel : Actor
{
    override void PostBeginPlay()
    {
        Super.PostBeginPlay();
        int panelLength = Max(8, args[0]);
        int panelWidth = Max(8, args[1]);
        Scale.X = panelLength / 128.0;
        Scale.Y = panelWidth / 128.0;
    }

    Default
    {
        +NOINTERACTION
        +NOGRAVITY
        +FLATSPRITE
        RenderStyle "Normal";
    }

    States
    {
    Spawn:
        CSUF A -1;
        Stop;
    }
}

class CaelumFiniteRoofPanel : Actor
{
    override void PostBeginPlay()
    {
        Super.PostBeginPlay();
        int panelLength = Max(8, args[0]);
        int panelWidth = Max(8, args[1]);
        // El techo comparte orientación y escala visual con el piso. La
        // cuadrícula física permanece definida por las mismas dimensiones.
        Scale.X = panelLength / 128.0;
        Scale.Y = panelWidth / 128.0;
        // FLATSPRITE conserva su huella con Angle; SpriteAngle gira solamente
        // el dibujo del cielorraso, que en CSUR esta orientado a 90 grados.
        SpriteAngle = 90.0;

        // Cuadrícula de soportes finitos: forma un techo transitable desde
        // arriba y un cielorraso sólido desde abajo.
        for (int xOffset = -panelLength / 2 + 8;
             xOffset <= panelLength / 2 - 8; xOffset += 16)
        {
            for (int yOffset = -panelWidth / 2 + 8;
                 yOffset <= panelWidth / 2 - 8; yOffset += 16)
            {
                Actor blocker = Spawn(
                    "CaelumFiniteRoofBlocker",
                    Pos + (xOffset, yOffset, 0)
                );
                if (blocker != null) { blocker.master = self; }
            }
        }
    }

    Default
    {
        +NOINTERACTION
        +NOGRAVITY
        +FLATSPRITE
        RenderStyle "Normal";
    }

    States
    {
    Spawn:
        CSUR A -1;
        Stop;
    }
}
