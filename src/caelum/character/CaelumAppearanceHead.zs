// Capa visual sin inventario, física, salud ni decisiones de juego propias.
// Las ocho vistas y sus anclajes pertenecen a TEXTURES, no a una cámara local.
class CaelumAppearanceHead : Actor
{
    Default
    {
        +NOBLOCKMAP
        +NOINTERACTION
        +NOGRAVITY
        +MASTERNOSEE
    }

    void UpdateVisual()
    {
        let body=CaelumPlayer(Master);
        // Al volver por un hub pueden restaurarse módulos antiguos cuyo Master
        // se reasigna al viajero. Sólo sobrevive la referencia que éste conserva.
        if(body==null || body.AppearanceHead!=self){Destroy();return;}
        let profile=body.health<=0 && body.AppearanceDeathProfile!=null
            ?body.AppearanceDeathProfile:body.CharacterProfile;
        bInvisible=profile==null || profile.Race==CaelumConstants.RACE_BEAST_MAN || body.bInvisible;
        if(bInvisible)return;
        SetOrigin(body.Pos,true);
        Prev=body.Prev;
        WorldOffset=body.WorldOffset;
        FloorClip=body.FloorClip;
        Angle=body.Angle;
        sprite=CaelumAppearance.HeadSprite(profile.Race,profile.Sex,profile.SkinTone,profile.Face,profile.HairStyle,profile.HairColor);
        int group;Vector2 displacement;
        [group,displacement]=CaelumAppearanceDetailsRegistry.Anchor(profile.Sex,body.AppearanceHasGloves,body.AppearancePose);
        frame=group;
        Scale=body.Scale;
        // Misma compresión que P_CheckPlayerSprite (GZDoom 4.14.2): no duplicar
        // el agachado dibujado ni comprimir cuerpos que ya no son player.mo.
        if(body.player!=null && body.player.mo==body && body.player.crouchfactor<0.75
            && body.player.playerstate!=PST_DEAD
            && !((body.sprite==body.SpawnState.sprite || body.sprite==body.crouchsprite) && body.crouchsprite>0))
            Scale.Y*=0.5;
        SpriteOffset=(displacement.X*Scale.X,displacement.Y*Scale.Y);
        A_SetRenderStyle(body.Alpha,body.GetRenderStyle());
    }

    override void Tick(){Super.Tick();UpdateVisual();}

    States
    {
    Spawn:
        TNT1 A -1;
        Stop;
    }
}
