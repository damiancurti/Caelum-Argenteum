class CaelumBathUI : Object ui
{
    static bool Key(CaelumPlayer user,int type,int scan,String keyString)
    {
        if(type!=InputEvent.Type_KeyDown || scan==InputEvent.Key_Grave)return false;
        int choice=-1;
        if(scan==InputEvent.Key_Enter || scan==InputEvent.Key_Pad_A)choice=1;
        else if(scan==InputEvent.Key_Tab || scan==InputEvent.Key_Pad_B || keyString~=="q")choice=0;
        else if(scan==InputEvent.Key_LeftArrow)choice=2;
        else if(scan==InputEvent.Key_RightArrow)choice=3;
        else if(scan==InputEvent.Key_PgDn)choice=4;
        else if(scan==InputEvent.Key_PgUp)choice=5;
        else if(keyString~=="m")choice=6;
        if(choice==1){let journal=CaelumLiveMenu.Journal();if(journal!=null)journal.SetJournalOpen(false);}
        if(choice>=0)EventHandler.SendNetworkEvent("ca_bath_action",choice);
        return true;
    }
    static void Draw(CaelumJournalOverlay view,CaelumPlayer user)
    {
        let session=CaelumBathSession.Find(user);if(session==null || !session.Open || view==null)return;
        CaelumPresentation.MenuBackground(0x05070A,0.94);view.DrawPanel(16,12,608,336);
        view.DrawCenteredText(view.TitleFont,Font.CR_GOLD,320,28,StringTable.Localize("CA_BATH_TITLE",false));
        view.DrawParagraph(view.TextFont,Font.CR_WHITE,40,78,560,StringTable.Localize("CA_BATH_TERMS",false));
        view.DrawTextLine(view.TextFont,Font.CR_GOLD,40,148,String.Format(StringTable.Localize("CA_BATH_SELECTED",false),session.Selected,session.Maximum));
        view.DrawTextLine(view.SmallFont,Font.CR_WHITE,40,180,String.Format(StringTable.Localize("CA_BATH_COST",false),session.WaterCost,session.SoapCost,session.Selected*CaelumContaminationData.BATH_SECONDS_DEGREE));
        view.DrawTextLine(view.SmallFont,Font.CR_WHITE,40,206,String.Format(StringTable.Localize("CA_BATH_STOCK",false),session.Soap,session.Credit));
    }
}
