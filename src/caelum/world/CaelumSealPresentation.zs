// Reutiliza los cinco emblemas propios. No es una trampa ni tiene colisión.
class CaelumChannelSealMark : Actor
{
    CaelumChannelEffect Source;
    void UpdateMark()
    {
        if(!CaelumSealClimate.Active(Source)){Destroy();return;}
        static const String names[]={"CMNF","CMNW","CMNE","CMNA","CMNQ"};
        sprite=GetSpriteIndex(names[Clamp(Source.SealType,0,4)]);frame=0;
        let trap=GetDefaultByType("CaelumPressureTrap");
        Scale=trap.Scale*2;
        // La pequeña separación evita parpadeo por coplanaridad con el piso.
        SetOrigin(Source.ChannelOwner.Pos+(0,0,0.5),false);
        Angle=Source.ChannelOwner.Angle;
    }
    override void Tick(){UpdateMark();}
    Default {+NOINTERACTION +NOGRAVITY +FLATSPRITE}
    States {Spawn:CMNF A -1 Bright;Stop;}
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
    }

    static void End(CaelumChannelEffect effect)
    {
        let mark=effect.ChannelMark;effect.ChannelMark=null;if(mark!=null)mark.Destroy();
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
