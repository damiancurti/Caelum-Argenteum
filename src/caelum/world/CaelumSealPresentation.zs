// La proyección busca piso real y arquitectura sólida, no cuerpos vivos.
class CaelumSealGroundTrace : LineTracer
{
    override ETraceStatus TraceCallback()
    {
        if(Results.HitType==TRACE_HitActor)
        {
            let body=Results.HitActor;
            if(body==null || !body.bSolid || body.player!=null || body is "CaelumCombatActor")
                return TRACE_Skip;
        }
        return TRACE_Stop;
    }
}

// Reutiliza los cinco emblemas propios. No es una trampa ni tiene colisión.
class CaelumChannelSealMark : Actor
{
    CaelumChannelEffect Source;
    transient CaelumSealGroundTrace GroundTrace;
    void UpdateMark()
    {
        if(!CaelumSealClimate.Active(Source)){Destroy();return;}
        static const String names[]={"CMNF","CMNW","CMNE","CMNA","CMNQ"};
        sprite=GetSpriteIndex(names[Clamp(Source.SealType,0,4)]);frame=0;
        let trap=GetDefaultByType("CaelumPressureTrap");
        Scale=trap.Scale*2;
        let user=Source.ChannelOwner;
        vector3 start=user.Pos+(0,0,user.Height/2);
        vector3 ground=(user.Pos.X,user.Pos.Y,user.FloorZ);
        if(GroundTrace==null)GroundTrace=new("CaelumSealGroundTrace");
        if(GroundTrace.Trace(start,level.PointInSector(start.XY),(0,0,-1),
            Max(1.0,start.Z-user.FloorZ+1.0),TRACE_PortalRestrict,
            Line.ML_BLOCKING|Line.ML_BLOCKEVERYTHING,false,user))ground=GroundTrace.Results.HitPos;
        // El dibujo permanece en el suelo aunque el usuario salte o vuele.
        // La pequeña separación evita parpadeo por coplanaridad con el piso.
        SetOrigin(ground+(0,0,0.5),false);
        Angle=user.Angle;Pitch=Roll=0;
        // GZDoom ordena los sprites con alfa por profundidad XY y, al empatar,
        // por creación. El sello nace después del cuerpo y puede tapar sus
        // piernas aunque esté en el suelo. Romper sólo el empate de dibujo
        // hacia el fondo conserva posición física, escala y transparencia.
        let camera=players[consoleplayer].camera;
        vector2 depth=AngleToVector(camera!=null?camera.Angle:user.Angle,0.5);
        WorldOffset=(depth.X,depth.Y,0);
    }
    override void Tick(){UpdateMark();}
    Default {+NOINTERACTION +NOGRAVITY +FLATSPRITE}
    States
    {
    Spawn:CMNF A -1 Bright;Stop;
    // Append-only: GetSpriteIndex requiere registro nativo, no sólo TEXTURES.
    SealFrames:CMNW A -1 Bright;Stop;
    AirFrame:CMNA A -1 Bright;Stop;
    }
}

// Esfera puramente visual: comparte escala/animación con Sol arcano, sin
// heredar daño, proyectiles, calor, colisión ni otra mecánica de esa habilidad.
class CaelumChannelSealOrb : Actor
{
    CaelumChannelEffect Source;
    int VisualAge;
    double VisualHalfHeight;
    void UpdateOrb()
    {
        if(!CaelumSealClimate.Active(Source)){Destroy();return;}
        int kind=Clamp(Source.SealType,0,4)*2;
        sprite=GetSpriteIndex(CaelumElementalVFXData.SpriteName(kind));
        frame=(VisualAge/CaelumElementalVFXData.FRAME_TICS)%4;
        Scale=GetDefaultByType("CaelumArcaneSunOrb").Scale;
        TextureID texture;bool flip;Vector2 textureScale;
        [texture,flip,textureScale]=SpawnState.GetSpriteTexture(0,0,(1,1),sprite,frame);
        Vector2 size=texture.IsValid()?TexMan.GetScaledSize(texture):(0,0);
        VisualHalfHeight=size.Y*Scale.Y/2;
        let user=Source.ChannelOwner;
        SetOrigin(user.Pos+(0,0,user.Height+VisualHalfHeight),false);
        CaelumElementalVFX.Light(self,kind);
    }
    override void Tick(){UpdateOrb();VisualAge++;}
    Default {Radius 0;Height 0;Mass 0;+NOINTERACTION +NOGRAVITY +BRIGHT}
    States {Spawn:VFFR A -1 Bright;Stop;}
}

class CaelumSealPresentation : Object play
{
    static void Update(CaelumChannelEffect effect)
    {
        if(!CaelumSealClimate.Active(effect))return;
        let user=effect.ChannelOwner;
        if(user.player==null)return;
        if(!effect.ChannelCameraCaptured)
        {
            effect.ChannelCameraCaptured=true;
            effect.ChannelWasChase=(user.player.cheats&CF_CHASECAM)!=0;
            effect.ChannelPreviousCamera=user.player.camera;
        }
        user.player.camera=user;user.player.cheats|=CF_CHASECAM;
        if(effect.ChannelMark==null || effect.ChannelMark.bDestroyed)
        {
            effect.ChannelMark=CaelumChannelSealMark(Actor.Spawn("CaelumChannelSealMark",user.Pos,NO_REPLACE));
            if(effect.ChannelMark!=null)effect.ChannelMark.Source=effect;
        }
        if(effect.ChannelMark!=null)effect.ChannelMark.UpdateMark();
        if(effect.ChannelOrb==null || effect.ChannelOrb.bDestroyed)
        {
            effect.ChannelOrb=CaelumChannelSealOrb(Actor.Spawn("CaelumChannelSealOrb",user.Pos,NO_REPLACE));
            if(effect.ChannelOrb!=null)effect.ChannelOrb.Source=effect;
        }
        if(effect.ChannelOrb!=null)effect.ChannelOrb.UpdateOrb();
    }

    static void End(CaelumChannelEffect effect)
    {
        let mark=effect.ChannelMark;effect.ChannelMark=null;if(mark!=null)mark.Destroy();
        let orb=effect.ChannelOrb;effect.ChannelOrb=null;if(orb!=null)orb.Destroy();
        let user=effect.ChannelOwner;
        if(!effect.ChannelCameraCaptured || user==null || user.player==null)return;
        effect.ChannelCameraCaptured=false;
        if(!effect.ChannelWasChase)user.player.cheats&=~CF_CHASECAM;
        if(user.player.camera==user)
            user.player.camera=effect.ChannelPreviousCamera!=null && !effect.ChannelPreviousCamera.bDestroyed
                ? effect.ChannelPreviousCamera : Actor(user);
        effect.ChannelPreviousCamera=null;
    }
}
