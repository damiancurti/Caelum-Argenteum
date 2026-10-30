class CaelumCompanionUI : Object ui
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
        else if(keyString~=="f")choice=5;
        else if(keyString~=="i")choice=6;
        else if(scan==InputEvent.Key_Enter)choice=7;
        else if(keyString~=="l")choice=8;
        else if(keyString~=="e")choice=11;
        else if(scan==InputEvent.Key_UpArrow)choice=9;
        else if(scan==InputEvent.Key_DownArrow)choice=10;
        if(choice>=0)EventHandler.SendNetworkEvent("ca_companion_action",choice);
        return true;
    }
    static void Draw(CaelumJournalOverlay view,CaelumPlayer user)
    {
        let session=CaelumCompanionSession(user.FindInventory("CaelumCompanionSession"));
        if(session==null || !session.Open || session.Subject==null)return;
        let bond=session.Subject.Companion;
        CaelumPresentation.MenuBackground(0x05070A,0.94);view.DrawPanel(16,12,608,336);
        view.DrawCenteredText(view.TitleFont,Font.CR_GOLD,320,25,session.Subject.GetTag());
        view.DrawTextLine(view.SmallFont,Font.CR_WHITE,36,53,String.Format(StringTable.Localize("CA_COMPANION_TRUST",false),bond!=null ? bond.Trust : 0));
        view.DrawTextLine(view.SmallFont,Font.CR_GOLD,36,74,StringTable.Localize(session.PlayerItems ? "CA_COMPANION_YOUR_ITEMS" : "CA_COMPANION_THEIR_ITEMS",false));
        int first=Max(0,session.Selection-3);
        for(int i=first;i<session.Labels.Size() && i<first+4;i++)
            view.DrawParagraph(view.SmallFont,i==session.Selection ? Font.CR_GREEN : Font.CR_WHITE,
                36,98+(i-first)*27,560,session.Labels[i]);
        if(session.Status!="")view.DrawParagraph(view.SmallFont,Font.CR_GOLD,36,218,560,StringTable.Localize(session.Status,false));
    }
}
