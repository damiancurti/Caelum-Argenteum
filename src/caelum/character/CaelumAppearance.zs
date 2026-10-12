// #148: identidad visual pura compartida por el mundo y el visor nativo.
// Los índices guardados son semánticos; nunca se serializan TextureID/sprites.
class CaelumAppearance : Object play
{
    const REVISION=1;
    const PAGE=12;
    const TONE_COUNT=3;
    const FORM_COUNT=4;
    const POSE_COUNT=29;

    static clearscope bool Valid(int tone,int form)
    {return tone>=0 && tone<TONE_COUNT && form>=0 && form<FORM_COUNT;}

    static clearscope int Identity(int race,int sex,int form)
    {
        sex=Clamp(sex,0,1);
        if(race==CaelumConstants.RACE_BEAST_MAN)return 6+Clamp(form,0,3)*2+sex;
        if(race==CaelumConstants.RACE_CAELITH)return 2+sex;
        if(race==CaelumConstants.RACE_GOBLIN)return 4+sex;
        return sex;
    }

    static clearscope int SpriteFor(int race,int sex,int form,int tone,int pose,bool gloved=false)
    {
        int bank=Identity(race,sex,form)*6+Clamp(tone,0,2)*2+Clamp(pose,0,POSE_COUNT-1)/26;
        return RegisteredSprite(String.Format("%s%03d",gloved?"Q":"P",bank));
    }

    static clearscope int RegisteredSprite(String label)
    {
        let registry=GetDefaultByType("CaelumAppearanceRegistry");
        let state=registry.FindStateByString(label,true);
        return state==null?-1:state.sprite;
    }

    static clearscope Vector2 ScaleFor(int race,int sex,int form,double actorHeight,bool gloved=false)
    {
        double scale=actorHeight/CaelumAppearanceRegistry.StandingHeight(Identity(race,sex,form),gloved);
        return (scale,scale);
    }

    static clearscope int PoseFor(int source,int frame)
    {
        if(source==RegisteredSprite("SourceDOWK"))return 2+frame%2;
        if(source==RegisteredSprite("SourceDORN"))return 4+frame%2;
        if(source==RegisteredSprite("SourceRSDO"))return frame==0?16:frame==1?17:frame==2?6:7+frame%2;
        if(source==RegisteredSprite("SourceCAGN"))return frame==0?18:frame<=2?18+frame:frame==3?21:22;
        if(source==RegisteredSprite("SourceCAGC"))return frame==0?26:frame==1?27:28;
        if(source==RegisteredSprite("SourceSHGW"))return frame==3?24:frame>=4?25:23;
        if(source==RegisteredSprite("SourceDOMI"))
        {
            if(frame>=18)return frame==18?12:frame==19?13:frame<=21?14:15;
            if(frame>=2)return frame%8<4?9:10;
            return 11;
        }
        return frame%2;
    }

    static clearscope String FormKey(int form)
    {return String.Format("CA_APPEARANCE_FORM_%d",Clamp(form,0,3));}
    static clearscope String ToneKey(int race,int tone)
    {
        String family=race==CaelumConstants.RACE_CAELITH?"RGB":race==CaelumConstants.RACE_BEAST_MAN?"FUR":"SKIN";
        return String.Format("CA_APPEARANCE_%s_%d",family,Clamp(tone,0,2));
    }

    static void Apply(CaelumPlayer user)
    {
        if(user==null || user.CurState==null || user.CharacterProfile==null)return;
        // El cadáver conserva su propio perfil ligado al morir, aunque ya no
        // sea player.mo. Esto no amplía la autoridad de juego sobre otros cuerpos.
        let profile=user.health<=0 && user.AppearanceDeathProfile!=null?user.AppearanceDeathProfile:user.CharacterProfile;
        int pose=PoseFor(user.sprite,user.frame);
        bool authoredCrouch=user.crouchsprite!=0 && user.crouchsprite==user.sprite;
        user.AppearanceHasGloves=user.health<=0 && user.AppearanceDeathProfile!=null
            ?user.AppearanceDeathGloves:CaelumAppearanceHands.HasGloves(user);
        user.sprite=SpriteFor(profile.Race,profile.Sex,profile.BeastForm,profile.SkinTone,pose,user.AppearanceHasGloves);
        user.frame=pose%26;
        if(user.DerivedStats!=null)
            user.Scale=ScaleFor(profile.Race,profile.Sex,profile.BeastForm,user.DerivedStats.ActorHeight,user.AppearanceHasGloves);
        if(authoredCrouch)user.crouchsprite=user.sprite;
        user.bNoSkin=true;
    }
}
