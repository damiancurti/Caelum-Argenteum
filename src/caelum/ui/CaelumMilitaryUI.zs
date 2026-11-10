class CaelumMilitaryUI : Object ui
{
    static bool Key(int type,int scan,String keyString)
    {
        if(type!=InputEvent.Type_KeyDown || scan==InputEvent.Key_Grave)return false;
        int choice=-1;
        if(scan==InputEvent.Key_Tab || keyString~=="q")choice=0;
        else if(keyString=="1")choice=1;
        else if(keyString=="2")choice=2;
        else if(keyString=="3")choice=3;
        else if(keyString=="4")choice=4;
        else if(keyString=="5")choice=5;
        else if(scan==InputEvent.Key_LeftArrow)choice=6;
        else if(scan==InputEvent.Key_RightArrow)choice=7;
        if(choice>=0)EventHandler.SendNetworkEvent("ca_military_action",choice);
        return true;
    }

    static void Draw(CaelumJournalOverlay view,CaelumPlayer user)
    {
        let session=CaelumMilitarySession(user.FindInventory('CaelumMilitarySession'));
        if(session==null || !session.Open)return;
        CaelumPresentation.MenuBackground(0x05070A,0.94);view.DrawPanel(16,12,608,336);
        view.DrawCenteredText(view.TitleFont,Font.CR_GOLD,320,25,StringTable.Localize("CA_MILITARY_TITLE",false));
        String status=session.Denial!=""?session.Denial:session.Status;
        if(status!="")view.DrawParagraph(view.SmallFont,Font.CR_GOLD,36,56,560,StringTable.Localize(status,false));
        if(session.Group!=null)
        {
            let group=session.Group.Formation;
            view.DrawTextLine(view.SmallFont,Font.CR_WHITE,36,104,
                String.Format(StringTable.Localize("CA_MILITARY_GROUP",false),group.Members.Size(),group.Capacity,session.Group.Recipients));
            view.DrawTextLine(view.SmallFont,Font.CR_WHITE,36,128,
                StringTable.Localize("CA_MILITARY_ORDER_"..session.Group.Order,false));
        }
        String caption="CA_MILITARY_HERE";
        if(session.Selection>0 && session.Selection<session.Points.Size())caption=session.Points[session.Selection].NameKey;
        view.DrawParagraph(view.SmallFont,Font.CR_WHITE,36,156,560,
            String.Format(StringTable.Localize("CA_MILITARY_DESTINATION",false),StringTable.Localize(caption,false)));
        view.DrawParagraph(view.SmallFont,Font.CR_WHITE,36,198,560,StringTable.Localize("CA_MILITARY_CREWS",false));
    }
}
