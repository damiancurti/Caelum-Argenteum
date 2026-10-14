// Geometría de controles y traducción a las mismas acciones de teclado.
class CaelumLiveMenuControls : Object ui
{
    Array<int> Scans, Characters;
    Array<String> Keys;
    CaelumLiveMenu OwnerMenu;
    bool Drawing;
    double NextX, RowY;
    void Region(int id,double x,double y,double w,double h)
    {
        OwnerMenu.Pointer.Add(id,x,y,w,h);
        if(Drawing && OwnerMenu.Pointer.Positioned && CaelumMenuPointer.Inside(OwnerMenu.Pointer.Position,(x,y),(w,h)))
        {
            Vector2 origin,size;[origin,size]=Screen.VirtualToRealCoords((x,y),(w,h),(640,360),false,false);
            Screen.Dim(0xC8AA64,0.15,int(origin.X),int(origin.Y),int(size.X),int(size.Y));
        }
    }
    void Row(double y)
    {
        NextX=32;RowY=y;
        if(Drawing)
        {
            Vector2 origin,size;[origin,size]=Screen.VirtualToRealCoords((28,y-1),(584,20),(640,360),false,false);
            Screen.Dim(0x080E16,1,int(origin.X),int(origin.Y),int(size.X),int(size.Y));
        }
    }
    void Button(String key,int scan=0,int character=0,String letter="",double width=92,bool enabled=true)
    {
        Scans.Push(scan);Characters.Push(character);Keys.Push(letter);
        String label=StringTable.Localize(key,false);
        if(key=="CA_UI_SKIP")label=CaelumInputHints.Bound(label,"ca_time_skip");
        else
        {
            String allowed=key=="CA_UI_JOURNAL" || (key=="CA_UI_BACK" && OwnerMenu.Context>=1 && OwnerMenu.Context<=7
                && !(OwnerMenu.Context==5 && OwnerMenu.Journal().IsQuestDetailOpen()))?"ca_journal_toggle":"";
            label=allowed!=""?CaelumInputHints.BoundOrFallback(label,allowed,scan):CaelumInputHints.Context(label,scan,character);
        }
        OwnerMenu.Pointer.Button(OwnerMenu.Journal(),Scans.Size(),NextX,RowY,width,label,enabled,false,Drawing);
        NextX+=width+4;
    }
    void PrevNext()
    {Button("CA_UI_PREVIOUS",InputEvent.Key_UpArrow);Button("CA_UI_NEXT",InputEvent.Key_DownArrow);}
    void Back(int scan=InputEvent.Key_Tab) {Button("CA_UI_BACK",scan);}
    void Layout(CaelumLiveMenu host,bool draw)
    {
        OwnerMenu=host;Drawing=draw;Scans.Clear();Characters.Clear();Keys.Clear();host.Pointer.Clear();
        let user=host.Subject;let view=host.Journal();int context=host.Context;
        if(context>=1 && context<=7)
        {
            host.Pointer.Button(view,9000,508,15,100,CaelumNotificationMenu.Link(),true,false,draw);
            for(int i=0;i<7;i++)Region(1000+i,26+i*84,36,84,65);
            if(context==4)return;
            Row(326);
            if(context==1)
            {
                Button("CA_UI_USE",InputEvent.Key_Enter,0,"",108,user.FormalInventoryEntryCount>0);
                Button("CA_UI_BOX",0,99,"c",108,user.FormalInventoryEntryCount>0);
                Button("CA_UI_DROP",0,100,"d",108,user.FormalInventoryEntryCount>0);
                Button("CA_UI_PREVIOUS",InputEvent.Key_UpArrow,0,"",76);
                Button("CA_UI_NEXT",InputEvent.Key_DownArrow,0,"",76);Back();
                for(int i=0;i<CaelumPlayer.FORMAL_INVENTORY_FILTER_COUNT;i++)Region(2000+i,50+i*57,122,40,28);
                for(int i=0;i<CaelumPlayer.FORMAL_INVENTORY_VISIBLE_ROWS;i++)
                    if(user.FormalInventoryRowKind[i]>=0)Region(3000+i,48,168+i*21,360,21);
            }
            else if(context==3)
            {
                Button("CA_UI_CALENDAR",0,102,"f");Button("CA_UI_THERMAL",0,116,"t");
                Button("CA_UI_REST",0,100,"d");
                Button("CA_UI_TRAVEL",0,99,"c",92,CaelumWorldCatalogue.LocationForMap(level.MapName)>=2);
                Button("CA_UI_SKIP",0,121,"y");Back();
                Region(4000,440,104,172,22);
            }
            else if(context==5)
            {
                Button("CA_UI_PREVIOUS",InputEvent.Key_UpArrow,0,"",70);Button("CA_UI_NEXT",InputEvent.Key_DownArrow,0,"",70);
                Button("CA_UI_DETAILS",0,102,"f",84);Button("CA_UI_ACT",InputEvent.Key_Enter,0,"",84);
                Button("CA_UI_ABANDON",0,103,"g",92);Button("CA_UI_FILTER",0,99,"c",70);Back();
                // Los filtros tienen dos ejes independientes.
                Region(4002,320,108,280,18);
            }
            else if(context==7)
            {
                Button("CA_UI_PREVIOUS",InputEvent.Key_LeftArrow);Button("CA_UI_NEXT",InputEvent.Key_RightArrow);
                Button("CA_UI_SELECT",InputEvent.Key_Enter);Button("CA_UI_UP",InputEvent.Key_UpArrow);
                Button("CA_UI_DOWN",InputEvent.Key_DownArrow);Back();Region(4001,64,150,120,160);
            }
            else
            {
                if(context==2)Button("CA_UI_THERMAL",0,116,"t");
                if(context==6 && user.JournalReputationTrialEnabled)Button("CA_UI_TRIAL",0,102,"f");
                Button("CA_UI_PREVIOUS",InputEvent.Key_PgUp);Button("CA_UI_NEXT",InputEvent.Key_PgDn);Back();
            }
        }
        else if(context==host.CTX_SKIP)return;
        else if(context==host.CTX_JOURNEY)
        {Row(326);Button("CA_UI_CONFIRM",InputEvent.Key_Enter,0,"",280);Button("CA_UI_CANCEL",InputEvent.Key_Tab,0,"",280);}
        else if(context==host.CTX_REST)
        {
            Row(145);Button("CA_UI_STAND",0,113,"q");Button("CA_UI_FAST",0,116,"t");Button("CA_UI_SKIP",0,121,"y");
            if(CaelumDiningSession.HasMealSupport(user))
            {Button("CA_UI_EAT",0,102,"f");Button("CA_UI_DRINK",0,103,"g");}
            Button("CA_UI_JOURNAL",InputEvent.Key_Tab);
        }
        else if(context==host.CTX_MERCHANT)
        {
            Row(326);PrevNext();Button("CA_UI_MODE",InputEvent.Key_Space);Button("CA_UI_TRADE",InputEvent.Key_Enter);Back();
            // La cantidad queda junto al total sin tapar el estado de la transacción.
            NextX=440;RowY=275;Button("CA_UI_MINUS",InputEvent.Key_LeftArrow,0,"",32);Button("CA_UI_PLUS",InputEvent.Key_RightArrow,0,"",32);
            if(user.CityTrade!=null)
            {
                int first=user.CityTrade.Selection/5*5;
                for(int i=first;i<Min(first+5,user.CityTrade.Rows.Size());i++)Region(5000+i,40,131+(i-first)*28,400,28);
            }
            else for(int i=0;i<user.PalomoMerchantVisibleItemCount;i++)Region(5000+i,50,140+i*27,290,27);
        }
        else if(context==host.CTX_CALENDAR)
        {
            bool detail=CaelumScheduleCalendar.Setting("ca_calendar_detail")!=0;
            Row(318);
            if(detail){Button("CA_UI_ACT",0,112,"p",184);Button("CA_UI_BACK",0,113,"q",184);}
            else
            {
                Button("CA_UI_MONTH_PREV",InputEvent.Key_PgUp);Button("CA_UI_MONTH_NEXT",InputEvent.Key_PgDn);
                Button("CA_UI_TODAY",InputEvent.Key_Home,104,"h");Button("CA_UI_DETAILS",InputEvent.Key_Enter);
                Button("CA_UI_NEXT",0,101,"e");Button("CA_UI_BACK",0,113,"q");
                int day=CaelumScheduleCalendar.SelectedDay(user);
                int year=CaelumCalendarRules.YearForSerial(day),month=CaelumCalendarRules.MonthForSerial(day);
                int first=CaelumCalendarRules.ToSerial(year,month,1),length=CaelumCalendarRules.DaysInMonth(year,month);
                for(int i=0;i<length;i++){int cell=first%7+i;Region(6000+i,43+cell%7*40,131+cell/7*24,40,24);}
                let agenda=CaelumScheduleState(user.FindInventory("CaelumScheduleState"));
                Array<CaelumScheduledEvent> entries;CaelumScheduleCalendar.EntriesForDay(agenda,day,entries);
                int selected=Clamp(CaelumScheduleCalendar.Setting("ca_calendar_event"),0,Max(0,int(entries.Size())-1));
                int offset=selected/5*5;
                for(int row=0;row<5 && row+offset<entries.Size();row++)Region(7000+row+offset,355,115+row*32,243,32);
            }
        }
        else if(context==host.CTX_CHEST)
        {
            Row(303);Button("CA_UI_COLLECT",InputEvent.Key_Enter,0,"",280);Button("CA_UI_BACK",InputEvent.Key_Tab,0,"",280);
            Row(325);Button("CA_UI_NEXT",0,110,"n");
        }
        else if(context==host.CTX_EQUIPMENT)
        {
            Row(278);Button("CA_UI_CATEGORY",InputEvent.Key_Tab);Button("CA_UI_TYPE_PREV",InputEvent.Key_LeftArrow);
            Button("CA_UI_TYPE_NEXT",InputEvent.Key_RightArrow);Button("CA_UI_TIER",InputEvent.Key_Space);
            Button("CA_UI_SIZE",0,114,"r");Button("CA_UI_BACK",0,113,"q");
            Row(300);Button("CA_UI_USE",InputEvent.Key_Enter);Button("CA_UI_UNEQUIP",InputEvent.Key_Backspace);
            Button("CA_UI_BOX",0,99,"c");Button("CA_UI_DROP",0,100,"d");Button("CA_UI_BREAK",0,98,"b");Button("CA_UI_SPAWN",0,112,"p");
            Row(322);Button("CA_UI_SLOT_PREV",InputEvent.Key_UpArrow);Button("CA_UI_SLOT_NEXT",InputEvent.Key_DownArrow);
        }
        else if(context==host.CTX_CREATION)
        {
            Row(280);Button("CA_UI_NEXT",InputEvent.Key_RightArrow);Button("CA_UI_PLUS",InputEvent.Key_Space);
            Button("CA_UI_CONFIRM",InputEvent.Key_Enter);Button("CA_UI_BACK",InputEvent.Key_Backspace);
        }
    }
    void Activate(CaelumLiveMenu host,int id)
    {
        let view=host.Journal();let user=host.Subject;
        if(id==9000){host.ResetInput();Menu.SetMenu("CaelumNotificationMenu");return;}
        if(id>=7000){CaelumScheduleCalendar.Set("ca_calendar_event",id-7000);return;}
        if(id>=6000)
        {
            int day=CaelumScheduleCalendar.SelectedDay(user);
            CaelumScheduleCalendar.Set("ca_calendar_day",CaelumCalendarRules.ToSerial(CaelumCalendarRules.YearForSerial(day),CaelumCalendarRules.MonthForSerial(day),1)+id-6000);
            CaelumScheduleCalendar.Set("ca_calendar_event",0);return;
        }
        if(id>=5000)
        {
            int selected=user.CityTrade!=null?user.CityTrade.Selection:0;
            if(user.CityTrade==null)for(int i=0;i<user.PalomoMerchantVisibleItemCount;i++)
                if(user.PalomoMerchantVisibleItems[i]==user.PalomoMerchantSelection)selected=i;
            int delta=id-5000-selected;
            for(int i=0;i<Abs(delta);i++)EventHandler.SendNetworkEvent(delta<0?"ca_palomo_merchant_previous":"ca_palomo_merchant_next");
            return;
        }
        if(id==4002){host.Stroke(0,118,"v");return;}
        if(id==4000){host.Stroke(0,116,"t");return;}
        if(id==4001){host.Stroke(InputEvent.Key_Enter);return;}
        if(id>=3000)
        {
            int delta=id-3000+user.FormalInventoryVisibleStart-user.FormalInventorySelectionIndex;
            for(int i=0;i<Abs(delta);i++)EventHandler.SendNetworkEvent(delta<0?"ca_inventory_previous":"ca_inventory_next");return;
        }
        if(id>=2000)
        {
            int delta=id-2000-user.FormalInventoryFilter;
            for(int i=0;i<Abs(delta);i++)EventHandler.SendNetworkEvent(delta<0?"ca_inventory_filter_previous":"ca_inventory_filter");return;
        }
        if(id>=1000)
        {
            int next=id-1000;
            if(view.GetJournalPage()==3 && next!=3)EventHandler.SendNetworkEvent("ca_crafting_session_close");
            view.SetJournalPage(next);host.ResetInput();return;
        }
        if(id>0 && id<=Scans.Size())
        {
            // El botón visual solicita la acción, aunque no tenga tecla asignada.
            if(Keys[id-1]=="y")EventHandler.SendNetworkEvent("ca_skip_open");
            else host.Stroke(Scans[id-1],Characters[id-1],Keys[id-1]);
        }
    }
    void Wheel(CaelumLiveMenu host,int direction,Vector2 point)
    {
        host.ResetPointer();
        if(host.Context==4)CaelumCraftingUI.Mouse(host.Journal(),host.Subject,direction<0?UIEvent.Type_WheelUp:UIEvent.Type_WheelDown,point);
        else if(host.Context==host.CTX_SKIP)CaelumTimeSkipPanel.PointerInput(host.Journal(),host.Subject,direction<0?UIEvent.Type_WheelUp:UIEvent.Type_WheelDown,point);
        else if(host.Context==host.CTX_CALENDAR)host.Stroke(direction<0?InputEvent.Key_PgUp:InputEvent.Key_PgDn);
        else if(host.Context==host.CTX_CHEST)host.Stroke(0,110,"n");
        else host.Stroke(direction<0?InputEvent.Key_UpArrow:InputEvent.Key_DownArrow);
    }
}
