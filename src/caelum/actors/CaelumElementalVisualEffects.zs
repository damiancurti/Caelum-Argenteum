// Efectos puramente visuales. El daño y los temporizadores permanecen en
// CaelumElementalStatus; estos actores sólo siguen al objetivo afectado.
class CaelumAttachedElementalVisual : Actor
{
    override void Tick()
    {
        Super.Tick();
        if (master == null)
        {
            Destroy();
            return;
        }
        SetOrigin(master.Pos, false);
        double visualScale = Max(0.08, master.Height / 140.0);
        Scale.X = visualScale;
        Scale.Y = visualScale;
    }

    Default
    {
        +NOINTERACTION
        +NOGRAVITY
        +BRIGHT
        RenderStyle "Normal";
    }
}

class CaelumBurnVisual : CaelumAttachedElementalVisual
{
    States
    {
    Spawn:
        CEFB ABCDEFGHIJKL 3 Bright;
        Loop;
    }
}

class CaelumPoisonVisual : CaelumAttachedElementalVisual
{
    States
    {
    Spawn:
        CEVP ABCDEFGHIJKL 3 Bright;
        Loop;
    }
}

class CaelumFreezeVisual : CaelumAttachedElementalVisual
{
    States
    {
    Spawn:
        CEFI ABCDEFGHIJKL 3 Bright;
        Loop;
    }
}

class CaelumLightningStatusVisual : CaelumAttachedElementalVisual
{
    Default { RenderStyle "Add"; }

    States
    {
    Spawn:
        CELV ABCDEFGHIJKL 2 Bright;
        Loop;
    }
}

class CaelumLightningImpactVisual : CaelumAttachedElementalVisual
{
    Default { RenderStyle "Add"; }

    States
    {
    Spawn:
        CELV ABCDEFGHIJKL 2 Bright;
        Stop;
    }
}
