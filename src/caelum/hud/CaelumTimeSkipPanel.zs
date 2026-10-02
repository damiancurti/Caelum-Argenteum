class CaelumTimeSkipPanel : Object
{
    static ui bool Input(InputEvent e,CaelumPlayer user)
    {
        let skip=CaelumTimeSkipState(user.FindInventory("CaelumTimeSkipState"));
        if(skip==null || !skip.Open || menuactive!=0)return false;
        if(e.Type!=InputEvent.Type_KeyDown || e.KeyScan==InputEvent.Key_Grave
            || e.KeyScan==InputEvent.Key_Escape || e.KeyScan==InputEvent.Key_Pad_Start)return false;
        if(e.KeyString~=="q" || e.KeyScan==InputEvent.Key_Tab || e.KeyScan==InputEvent.Key_Pad_B)
            EventHandler.SendNetworkEvent("ca_skip_cancel");
        else if(!skip.Active && !skip.ConfirmPending)
        {
            if(e.KeyScan==InputEvent.Key_Enter || e.KeyScan==InputEvent.Key_Pad_A)
                EventHandler.SendNetworkEvent("ca_skip_start");
            else if(e.KeyScan==InputEvent.Key_LeftArrow || e.KeyScan==InputEvent.Key_Pad_DPad_Left)EventHandler.SendNetworkEvent("ca_skip_edit",-1,0);
            else if(e.KeyScan==InputEvent.Key_RightArrow || e.KeyScan==InputEvent.Key_Pad_DPad_Right)EventHandler.SendNetworkEvent("ca_skip_edit",1,0);
            else if(e.KeyScan==InputEvent.Key_UpArrow || e.KeyScan==InputEvent.Key_Pad_DPad_Up)EventHandler.SendNetworkEvent("ca_skip_edit",0,1);
            else if(e.KeyScan==InputEvent.Key_DownArrow || e.KeyScan==InputEvent.Key_Pad_DPad_Down)EventHandler.SendNetworkEvent("ca_skip_edit",0,-1);
            else if(e.KeyString~=="r")EventHandler.SendNetworkEvent("ca_skip_forecast");
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
