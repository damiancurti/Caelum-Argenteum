class CaelumTimeSkipPanel : Object
{
    static ui bool Input(InputEvent e,CaelumPlayer user)
    { return Key(e.Type,e.KeyScan,e.KeyChar,e.KeyString,user); }

    static ui bool Key(int type,int scan,int character,String key,CaelumPlayer user)
    {
        let skip=CaelumTimeSkipState(user.FindInventory("CaelumTimeSkipState"));
        if(skip==null || !skip.Open || !CaelumLiveMenu.InputAllowed())return false;
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
    static ui void Layout(CaelumJournalOverlay view,CaelumTimeSkipState skip,CaelumMenuPointer pointer,bool draw)
    {
        pointer.Clear();bool edit=!skip.Active && !skip.ConfirmPending;
        pointer.Button(view,4,88,126,60,CaelumInputHints.Fixed("-",InputEvent.Key_DownArrow),edit,false,draw);
        for(int i=0;i<3;i++)pointer.Button(view,i+1,156+i*112,126,104,
            CaelumInputHints.Navigation(StringTable.Localize(i==0?"CA_SKIP_DAY":i==1?"CA_SKIP_HOUR":"CA_SKIP_MINUTE",false),true),edit,skip.Field==i,draw);
        pointer.Button(view,5,496,126,60,CaelumInputHints.Fixed("+",InputEvent.Key_UpArrow),edit,false,draw);
        pointer.Button(view,6,44,316,180,CaelumInputHints.Fixed(StringTable.Localize("CA_UI_SKIP_START",false),InputEvent.Key_Enter),edit,false,draw);
        pointer.Button(view,7,232,316,180,CaelumInputHints.Fixed(StringTable.Localize("CA_UI_SKIP_FORECAST",false),CaelumMenuPointer.KeyScan(114)),edit,false,draw);
        pointer.Button(view,8,420,316,176,CaelumInputHints.Fixed(StringTable.Localize(skip.Active?"CA_UI_SKIP_STOP":"CA_UI_BACK",false),InputEvent.Key_Tab),true,false,draw);
    }
    static ui bool Mouse(CaelumJournalOverlay view,CaelumPlayer user,UiEvent e)
    {
        let skip=CaelumTimeSkipState(user.FindInventory("CaelumTimeSkipState"));
        if(skip==null || !skip.Open || !CaelumLiveMenu.InputAllowed())return false;
        let pointer=CaelumJournalInput.PointerFor(100);
        if(e.Type==UiEvent.Type_KeyDown || e.Type==UiEvent.Type_KeyUp)
        {
            pointer.Reset();
            if(e.Type==UiEvent.Type_KeyUp)return false;
            return Key(InputEvent.Type_KeyDown,CaelumMenuPointer.KeyScan(e.KeyChar),e.KeyChar,e.KeyString,user);
        }
        return PointerInput(view,user,e.Type,CaelumMenuPointer.JournalPoint(e.MouseX,e.MouseY));
    }
    static ui bool PointerInput(CaelumJournalOverlay view,CaelumPlayer user,int type,Vector2 point)
    {
        let skip=CaelumTimeSkipState(user.FindInventory("CaelumTimeSkipState"));
        if(skip==null || !skip.Open || !CaelumLiveMenu.InputAllowed())return false;
        let pointer=CaelumJournalInput.PointerFor(100);
        pointer.Move(point);Layout(view,skip,pointer,false);
        int revision=skip.Field+(skip.Active?4:0)+(skip.ConfirmPending?8:0);
        if(type==UiEvent.Type_LButtonDown)pointer.Press(revision);
        else if(type==UiEvent.Type_LButtonUp)
        {
            int control=pointer.Release(revision);
            if(control>=1 && control<=3)EventHandler.SendNetworkEvent("ca_skip_field",control-1);
            else if(control==4 || control==5)Key(InputEvent.Type_KeyDown,control==4?InputEvent.Key_DownArrow:InputEvent.Key_UpArrow,0,"",user);
            else if(control==6)Key(InputEvent.Type_KeyDown,InputEvent.Key_Enter,0,"",user);
            else if(control==7)Key(InputEvent.Type_KeyDown,0,114,"r",user);
            else if(control==8)Key(InputEvent.Type_KeyDown,InputEvent.Key_Tab,0,"",user);
        }
        return true;
    }
    static ui void Draw(CaelumJournalOverlay view,CaelumPlayer user,CaelumTimeSkipState skip)
    {
        CaelumPresentation.MenuBackground(0x05070A,0.92);
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
        view.DrawCenteredText(view.SmallFont,Font.CR_GRAY,320,280,StringTable.Localize("CA_SKIP_HELP",false));
        view.DrawCenteredText(view.SmallFont,Font.CR_GRAY,320,298,StringTable.Localize("CA_SKIP_POLICY",false));
        Layout(view,skip,CaelumJournalInput.PointerFor(100),true);
    }
}
