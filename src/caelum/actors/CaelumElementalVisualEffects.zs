// Efectos puramente visuales. El daño y los temporizadores permanecen en
// CaelumElementalStatus; estos actores sólo siguen al objetivo afectado.
class CaelumAttachedElementalVisual : Actor
{
    int VisualAge;

    int VisualKind()
    {
        if(self is "CaelumPoisonVisual")return 1;
        if(self is "CaelumFreezeVisual")return 2;
        if(self is "CaelumLightningStatusVisual" || self is "CaelumLightningImpactVisual")return 3;
        return 0;
    }

    bool Active()
    {
        if(master==null || master.health<=0)return false;
        if(self is "CaelumLightningImpactVisual")return true;
        let user=CaelumPlayer(master);let npc=CaelumCombatActor(master);
        let status=user!=null ? user.ElementalStatus : npc!=null ? npc.ElementalStatus : null;
        if(status==null)return false;
        switch(VisualKind())
        {
            case 0:return status.BurnRemaining>0;
            case 1:return status.PoisonRemaining>0;
            case 2:return status.FreezeRemaining>0;
            case 3:return status.LightningStunRemaining>0;
        }
        return false;
    }

    override void Tick()
    {
        Super.Tick();
        if(bDestroyed)return;
        if (!Active())
        {
            A_StopSound(CHAN_BODY);
            Destroy();
            return;
        }
        SetOrigin(master.Pos, false);
        double visualScale = Max(0.08, master.Height / 140.0);
        Scale.X = Max(visualScale,master.Radius/40.0);
        Scale.Y = visualScale;
        int kind=VisualKind();
        sprite=GetSpriteIndex(CaelumElementalVFXData.StatusSprite(kind));
        frame=(VisualAge/CaelumElementalVFXData.FRAME_TICS+kind)%4;
        Alpha=0.72;
        if(VisualAge%CaelumElementalVFXData.FRAME_TICS==0)
            CaelumElementalVFX.Light(self,kind==0 ? 0 : kind==1 ? 5 : kind==2 ? 3 : 7);
        VisualAge++;
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
        TNT1 A 0 NoDelay A_StartSound(
            "caelum/world/fire_loop", CHAN_BODY, CHANF_LOOP
        );
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
