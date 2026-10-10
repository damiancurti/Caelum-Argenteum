class CaelumTimeSkipPanel : Object
{
    static ui bool Input(InputEvent e,CaelumPlayer user)
    { return Key(e.Type,e.KeyScan,e.KeyChar,e.KeyString,user); }

    static ui bool Key(int type,int scan,int character,String key,CaelumPlayer user)
    {
        let skip=CaelumTimeSkipState(user.FindInventory("CaelumTimeSkipState"));
        if(skip==null || !skip.Open || menuactive!=0)return false;
        if(type!=InputEvent.Type_KeyDown || scan==InputEvent.Key_Grave
            || scan==InputEvent.Key_Escape || scan==InputEvent.Key_Pad_Start)return false;
        // En la entrada nativa KeyString contiene el scan, no la letra ASCII.
        // Igual que en el Diario, Q/R se resuelven también mediante KeyChar.
        if(character==113 || character==81 || key~=="q" || scan==InputEvent.Key_Tab || scan==InputEvent.Key_Pad_B)
            EventHandler.SendNetworkEvent("ca_skip_cancel");
        else if(!skip.Active && !skip.ConfirmPending)
        {
            if(scan==InputEvent.Key_Enter || scan==InputEvent.Key_Pad_A)
                EventHandler.SendNetworkEvent("ca_skip_start");
            else if(scan==InputEvent.Key_LeftArrow || scan==InputEvent.Key_Pad_DPad_Left)EventHandler.SendNetworkEvent("ca_skip_edit",-1,0);
            else if(scan==InputEvent.Key_RightArrow || scan==InputEvent.Key_Pad_DPad_Right)EventHandler.SendNetworkEvent("ca_skip_edit",1,0);
            else if(scan==InputEvent.Key_UpArrow || scan==InputEvent.Key_Pad_DPad_Up)EventHandler.SendNetworkEvent("ca_skip_edit",0,1);
            else if(scan==InputEvent.Key_DownArrow || scan==InputEvent.Key_Pad_DPad_Down)EventHandler.SendNetworkEvent("ca_skip_edit",0,-1);
            else if(character==114 || character==82 || key~=="r")EventHandler.SendNetworkEvent("ca_skip_forecast");
        }
        return true;
    }
    static ui void Draw(CaelumJournalOverlay view,CaelumPlayer user,CaelumTimeSkipState skip)
    {
        Screen.Dim(0x05070A,0.92,0,0,Screen.GetWidth(),Screen.GetHeight());
        view.DrawPanel(16,12,608,336);
        view.DrawCenteredText(view.TitleFont,Font.CR_GOLD,320,24,StringTable.Localize("CA_SKIP_TITLE",false));
        bool limbo=CaelumWorldCatalogue.IsLimboMap(level.MapName);
        let clock=CaelumWorldClock(user.FindInventory("CaelumWorldClock"));
        let calendar=CaelumCalendarState(user.FindInventory("CaelumCalendarState"));
        view.DrawCenteredText(view.SmallFont,Font.CR_CYAN,320,51,
            StringTable.Localize(limbo?"CA_SKIP_LIMBO":"CA_SKIP_CAMPAIGN",false));
        view.DrawCenteredText(view.TextFont,Font.CR_WHITE,320,73,
            String.Format(StringTable.Localize("CA_SKIP_NOW",false),limbo
                ?CaelumWorldClock.FormatStamp(clock.LocalDays(),clock.LocalTics()):calendar.FormatDate(clock)));
        view.DrawCenteredText(view.TextFont,Font.CR_GOLD,320,104,
            String.Format(StringTable.Localize("CA_SKIP_TARGET",false),
                CaelumTimeSkipState.Stamp(skip.TargetDay,skip.TargetTics,limbo)));
        view.DrawCenteredText(view.SmallFont,Font.CR_GRAY,320,128,
            StringTable.Localize(skip.Field==0?"CA_SKIP_DAY":skip.Field==1?"CA_SKIP_HOUR":"CA_SKIP_MINUTE",false));
        let model=skip.Forecast;
        String forecast=!skip.HadTask?"CA_SKIP_NO_TASK":model==null || !model.Done?"CA_SKIP_CALCULATING"
            :model.Reason.Length()!=0?model.Reason:"CA_SKIP_FORECAST_READY";
        view.DrawParagraph(view.SmallFont,Font.CR_CYAN,44,150,552,StringTable.Localize(forecast,false));
        if(model!=null && model.Done && model.Reason.Length()==0)
            view.DrawCenteredText(view.SmallFont,Font.CR_CYAN,320,179,
                String.Format(StringTable.Localize("CA_SKIP_ESTIMATE",false),
                    CaelumTimeSkipState.Stamp(model.EndDay,model.EndTics,limbo),
                    double(model.SleepTics)/TICRATE/CaelumWorldClock.SecondsPerGameHour(level.MapName)));
        view.DrawCenteredText(view.SmallFont,Font.CR_WHITE,320,209,
            String.Format(StringTable.Localize("CA_REST_RESOURCES",false),user.CurrentSleep,user.CurrentHunger,user.CurrentThirst));
        if(skip.Active || skip.Completed)
            view.DrawCenteredText(view.SmallFont,Font.CR_WHITE,320,227,
                String.Format(StringTable.Localize("CA_SKIP_PROGRESS",false),double(skip.WorkTics)/TICRATE,
                    double(skip.SleepTics)/TICRATE/CaelumWorldClock.SecondsPerGameHour(level.MapName)));
        String status=skip.Active?(skip.Sleeping?"CA_REST_SLEEP":"CA_SKIP_RUNNING"):skip.LastReason;
        if(status.Length()!=0)view.DrawParagraph(view.SmallFont,Font.CR_GOLD,44,247,552,StringTable.Localize(status,false));
        view.DrawCenteredText(view.SmallFont,Font.CR_GRAY,320,298,StringTable.Localize("CA_SKIP_POLICY",false));
        view.DrawCenteredText(view.SmallFont,Font.CR_GOLD,320,322,
            StringTable.Localize(skip.Active?"CA_SKIP_ACTIVE_HELP":"CA_SKIP_HELP",false));
    }
}
