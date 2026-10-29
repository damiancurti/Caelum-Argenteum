class CaelumCleaningUI : Object ui
{
    static bool Key(int type,int scan,String keyString)
    {
        if(type!=InputEvent.Type_KeyDown || scan==InputEvent.Key_Grave)return false;
        int choice=-1;
        if(scan==InputEvent.Key_Enter || scan==InputEvent.Key_Pad_A)choice=1;
        else if(scan==InputEvent.Key_Tab || scan==InputEvent.Key_Pad_B || keyString~=="q")choice=0;
        if(choice==1){let journal=CaelumLiveMenu.Journal();if(journal!=null)journal.SetJournalOpen(false);}
        if(choice>=0)EventHandler.SendNetworkEvent("ca_clean_action",choice);return true;
    }
    static void Draw(CaelumJournalOverlay view,CaelumPlayer user)
    {
        let session=CaelumCleaningSession.Find(user);if(session==null || !session.Open || session.Item==null)return;
        let item=session.Item;
        CaelumPresentation.MenuBackground(0x05070A,0.94);view.DrawPanel(16,12,608,336);
        view.DrawCenteredText(view.TitleFont,Font.CR_GOLD,320,28,StringTable.Localize("CA_CLEAN_TITLE",false));
        view.DrawParagraph(view.TextFont,Font.CR_WHITE,40,78,560,view.FormatInventoryEntryName(item.EquipmentKind,item.ItemType,item.ArmorSlot,item.Tier,item.EquipmentSize,item.EssenceType));
        view.DrawTextLine(view.TextFont,Font.CR_GOLD,40,126,String.Format(StringTable.Localize("CA_CLEAN_AREA",false),session.Contamination,session.Area));
        view.DrawTextLine(view.SmallFont,Font.CR_WHITE,40,160,String.Format(StringTable.Localize("CA_BATH_COST",false),session.WaterCost,session.SoapCost,session.Area*CaelumContaminationData.EQUIPMENT_SECONDS_M2));
        view.DrawTextLine(view.SmallFont,Font.CR_WHITE,40,190,String.Format(StringTable.Localize("CA_CLEAN_SUPPLIES",false),session.Water,session.Soap));
        view.DrawParagraph(view.SmallFont,session.HasCloth?Font.CR_GREEN:Font.CR_RED,40,222,560,StringTable.Localize(session.HasCloth?"CA_CLEAN_CLOTH_READY":"CA_CLEAN_CLOTH_MISSING",false));
        view.DrawParagraph(view.SmallFont,Font.CR_GRAY,40,258,560,StringTable.Localize("CA_CLEAN_TERMS",false));
    }
}
