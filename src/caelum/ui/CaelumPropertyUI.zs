// Vista de contratos; las acciones se confirman en el estado de juego.
class CaelumPropertyUI : Object ui
{
    static bool Key(CaelumPlayer user,int type,int scan,String keyString)
    {
        if(type!=InputEvent.Type_KeyDown || scan==InputEvent.Key_Grave)return false;
        int choice=-1;
        if(keyString~=="b")choice=2;
        else if(keyString~=="r")choice=3;
        else if(scan==InputEvent.Key_Enter || scan==InputEvent.Key_Pad_A)choice=1;
        else if(scan==InputEvent.Key_Tab || scan==InputEvent.Key_Pad_B || keyString~=="q")choice=0;
        if(choice>=0)EventHandler.SendNetworkEvent("ca_property_action",choice);
        return true;
    }
    static void Draw(CaelumJournalOverlay view,CaelumPlayer user)
    {
        let session=CaelumPropertySession(user.FindInventory("CaelumPropertySession"));
        if(session==null || session.Portal==null || view==null)return;
        CaelumPresentation.MenuBackground(0x05070A,0.94);view.DrawPanel(16,12,608,336);
        view.DrawCenteredText(view.TitleFont,Font.CR_GOLD,320,28,StringTable.Localize("CA_PROPERTY_TITLE",false));
        view.DrawParagraph(view.TextFont,Font.CR_WHITE,40,78,560,StringTable.Localize("CA_PROPERTY_TERMS",false));
        view.DrawTextLine(view.TextFont,session.Current?Font.CR_GREEN:Font.CR_GRAY,40,160,
            StringTable.Localize(session.Owned?"CA_PROPERTY_OWNED":session.Current?"CA_PROPERTY_RENTED":"CA_PROPERTY_INACTIVE",false));
        view.DrawTextLine(view.SmallFont,Font.CR_WHITE,40,192,String.Format(StringTable.Localize("CA_PROPERTY_EXPIRY",false),session.Expiry));
        view.DrawTextLine(view.SmallFont,Font.CR_WHITE,40,214,String.Format(StringTable.Localize("CA_PROPERTY_MONEY",false),session.Money));
        if(session.Status!="")view.DrawParagraph(view.SmallFont,Font.CR_YELLOW,40,240,560,StringTable.Localize(session.Status,false));
    }
}
