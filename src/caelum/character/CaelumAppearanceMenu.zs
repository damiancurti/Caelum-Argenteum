// El editor comparte dibujo/controles con el creador, pero nunca su confirmación
// estructural ni su borrador de sesión. Sólo envía tono, forma y revisión esperada.
class CaelumAppearanceMenu : CaelumCharacterCreationMenu
{
    override void Init(Menu parent,ListMenuDescriptor desc)
    {
        Super.Init(parent,desc);
        AppearanceOnly=true;
        Page=CaelumAppearance.PAGE;
        if(consoleplayer<0 || gamestate!=GS_LEVEL)return;
        EditSubject=CaelumPlayer(players[consoleplayer].mo);
        let profile=CaelumCharacterIdentity.Profile(EditSubject);
        if(profile==null)return;
        EditProfile=profile;
        Race=profile.Race;Sex=profile.Sex;HeightChoice=profile.HeightChoice;
        FirstClass=profile.FirstClass;SecondClass=profile.SecondClass;
        SkinTone=profile.SkinTone;BeastForm=profile.BeastForm;
        EditSerial=profile.AppearanceEditSerial;
    }

    override void Ticker()
    {
        if(EditSubject==null || EditSubject.health<=0){Close();return;}
        Super.Ticker();
    }
}
