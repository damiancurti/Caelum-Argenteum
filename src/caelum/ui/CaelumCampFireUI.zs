class CaelumCampFireUI : Object ui
{
    static bool Key(int type,int scan,String keyString)
    {
        if(type!=InputEvent.Type_KeyDown || scan==InputEvent.Key_Grave)return false;
        int choice=-1;
        let user=CaelumPlayer(players[consoleplayer].mo);let session=CaelumCampFireSession.Find(user);
        if(session!=null && session.CookingPage)
        {
            if(keyString~=="1")choice=13;
            else if(keyString~=="2")choice=14;
            else if(keyString~=="3")choice=15;
            else if(keyString~=="x")choice=17;
            else if(keyString~=="b" || scan==InputEvent.Key_Tab || scan==InputEvent.Key_Pad_B)choice=16;
            else if(scan==InputEvent.Key_Enter || scan==InputEvent.Key_Pad_A)choice=18;
            if(choice>=0)EventHandler.SendNetworkEvent("ca_camp_fire_action",choice);
            return true;
        }
        if(scan==InputEvent.Key_Enter || scan==InputEvent.Key_Pad_A)choice=1;
        else if(scan==InputEvent.Key_Tab || scan==InputEvent.Key_Pad_B || keyString~=="q")choice=0;
        else if(scan==InputEvent.Key_LeftArrow)choice=2;
        else if(scan==InputEvent.Key_RightArrow)choice=3;
        else if(scan==InputEvent.Key_PgDn)choice=4;
        else if(scan==InputEvent.Key_PgUp)choice=5;
        else if(keyString~=="m")choice=6;
        else if(keyString~=="r")choice=7;
        else if(keyString~=="v")choice=8;
        else if(keyString~=="d")choice=9;
        else if(keyString~=="p")choice=10;
        else if(keyString~=="n")choice=11;
        else if(keyString~=="c")choice=12;
        if(choice>=0)EventHandler.SendNetworkEvent("ca_camp_fire_action",choice);
        return true;
    }
    static void Draw(CaelumJournalOverlay view,CaelumPlayer user)
    {
        let session=CaelumCampFireSession.Find(user);if(session==null || !session.Open || view==null)return;
        CaelumPresentation.MenuBackground(0x05070A,0.94);view.DrawPanel(16,12,608,336);
        view.DrawCenteredText(view.TitleFont,Font.CR_GOLD,320,28,StringTable.Localize("CA_CAMP_FIRE",false));
        if(session.CookingPage)
        {
            view.DrawParagraph(view.TextFont,Font.CR_WHITE,40,60,560,StringTable.Localize("CA_CAMP_COOK_TERMS",false));
            if(CaelumCampCooking.Active(user))
            {
                let task=CaelumCookingTaskState.FindCooking(user);
                view.DrawParagraph(view.TextFont,Font.CR_GOLD,40,122,560,String.Format(StringTable.Localize("CA_CAMP_COOK_PROGRESS",false),
                    StringTable.Localize(CaelumMealData.NameKey(CaelumCookingData.Meal(task.Recipe)),false),user.CraftingTaskRemainingSeconds/60,
                    task.IgnitionSeconds,session.Fire.Fuel.FuelGrams/1000));
                view.DrawParagraph(view.TextFont,Font.CR_WHITE,40,186,560,StringTable.Localize("CA_CAMP_COOK_PAUSE",false));
            }
            else for(int row=0;row<3;row++)view.DrawParagraph(view.TextFont,Font.CR_WHITE,40,142+row*54,560,session.CookingLabels[row]);
            return;
        }
        view.DrawParagraph(view.TextFont,Font.CR_WHITE,40,68,560,StringTable.Localize("CA_CAMP_FIRE_TERMS",false));
        view.DrawTextLine(view.TextFont,Font.CR_GOLD,40,122,String.Format(StringTable.Localize("CA_CAMP_FIRE_SELECTED",false),session.Selected,session.Maximum));
        if(session.Fire!=null)view.DrawTextLine(view.TextFont,Font.CR_WHITE,40,150,String.Format(StringTable.Localize("CA_CAMP_FIRE_STOCK",false),session.Fire.Fuel.FuelGrams/1000.0,StringTable.Localize(session.Fire.Fuel.Lit?"CA_CAMP_FIRE_LIT":"CA_CAMP_FIRE_OUT",false)));
        let pot=session.Fire!=null && session.Fire.Pot!=null?session.Fire.Pot:session.SelectedPot;
        if(pot!=null)view.DrawTextLine(view.TextFont,Font.CR_WHITE,40,174,String.Format(StringTable.Localize("CA_CAMP_FIRE_POT_STATUS",false),pot.WaterLiters,pot.WaterTemperatureC,pot.WaterLabel()));
    }
}
