// Columna izquierda #238: misma proyección y arte reducido al ancho del Tarot.
// Dibujar nunca activa una habilidad ni modifica sus relojes o recursos.
class CaelumAbilityHUD : Object ui
{
    const ICON_SIZE=64.0;
    const ICON_INSET=(CaelumPresentation.POWER_WIDTH-ICON_SIZE)/2.0;
    const LABEL_Y=ICON_INSET+ICON_SIZE+6.0;
    static bool Visible(CaelumPlayer user)
    {
        return user!=null && user.player!=null && user.player.playerstate==PST_LIVE
            && user.CharacterCreationComplete && !user.CreationWizardOpen
            && user.CharacterProfile!=null;
    }

    static double ReservedWidth(CaelumPlayer user)
    {
        Vector2 scale=CaelumPresentation.HUDScale();
        return Visible(user)?(CaelumPresentation.POWER_WIDTH+2*CaelumPresentation.POWER_MARGIN)
            *scale.X:0;
    }

    static void Icon(String path,double y,bool available)
    {
        let icon=TexMan.CheckForTexture(path,TexMan.Type_Any);
        if(!icon.IsValid())return;
        Screen.DrawTexture(icon,false,ICON_INSET,y+ICON_INSET,
            DTA_DESTWIDTHF,ICON_SIZE,DTA_DESTHEIGHTF,ICON_SIZE,
            DTA_LEFTOFFSETF,0.0,DTA_TOPOFFSETF,0.0,DTA_DESATURATE,available?0:255,
            DTA_ALPHA,available?1.0:0.35,DTA_VIRTUALWIDTHF,640.0,DTA_VIRTUALHEIGHTF,360.0,
            DTA_KEEPRATIO,true);
    }

    static void Label(Font font,String text,double y,int color)
    {
        Screen.DrawText(font,color,44.0-font.StringWidth(text)/2.0,y,text,
            DTA_VIRTUALWIDTHF,640.0,DTA_VIRTUALHEIGHTF,360.0,
            DTA_KEEPRATIO,true,DTA_SHADOW,true);
    }

    static void Draw(CaelumPlayer user,Font font)
    {
        if(!Visible(user) || font==null)return;
        Icon("graphics/caelum/ui/hud/icons/ca_hud_combat_charge.png",0,user.HUDClassAbilityAvailable);
        Label(font,StringTable.Localize("CA_HUD_CLASS_ABILITY",false),LABEL_Y,
            user.HUDClassAbilityAvailable?Font.CR_GOLD:Font.CR_GRAY);
        if(user.ClassPreparationTics>0)
            Label(font,StringTable.Localize("CA_HUD_CLASS_PREPARING",false),LABEL_Y+18,Font.CR_GOLD);
        else if(user.ClassSleepCooldownRemaining>0)
            Label(font,String.Format("%ds",Max(1,int(Ceil(user.ClassSleepCooldownRemaining)))),LABEL_Y+18,Font.CR_WHITE);
        if(user.CharacterProfile.Race==CaelumConstants.RACE_DEBUG)return;
        Icon("graphics/caelum/ui/hud/icons/ca_hud_combat_affected_targets.png",130,user.RacialAbilityActive);
        Label(font,StringTable.Localize("CA_HUD_RACIAL_ABILITY",false),130+LABEL_Y,
            user.RacialAbilityActive?Font.CR_CYAN:Font.CR_GRAY);
    }
}
