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
            host.Pointer.Button(view,9001,32,15,104,CaelumInputHints.Context(StringTable.Localize("CA_NAV_TITLE",false),0,110),true,false,draw);
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
                if(CaelumMateSession.Selected(user)!=null)
                {NextX=414;RowY=146;Button("CA_MATE_PREPARE",0,114,"r",192,!CaelumMateSession.Selected(user).InMagicBox);}
                NextX=414;RowY=302;Button("CA_BATH_START",0,104,"h",94);Button("CA_CLEAN_START",0,106,"j",94);
                int row=user.FormalInventorySelectionIndex-user.FormalInventoryVisibleStart;
                if(user.FormalInventoryEntryCount>0 && row>=0 && row<CaelumPlayer.FORMAL_INVENTORY_VISIBLE_ROWS
                    && user.FormalInventoryRowWaterLiters[row]>=0)
                {
                    NextX=414;RowY=146;
                    Button("CA_WATER_COLLECT",0,114,"r",104,!user.FormalInventoryRowInMagicBox[row]);
                    Button("CA_WATER_EMPTY_ACTION",0,118,"v",84,!user.FormalInventoryRowInMagicBox[row]);
                    if(CaelumLiveMenu.InventoryHAction(user)=="ca_inventory_boil")
                    { NextX=414;RowY=302;Button("CA_WATER_BOIL",0,104,"h",192,!user.FormalInventoryRowInMagicBox[row]); }
                }
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
                int quest=view.GetVisibleQuestId(user);
                bool tracked=CaelumQuestTracking.Selected(user,quest);
                Button("CA_UI_PREVIOUS",InputEvent.Key_UpArrow,0,"",70);Button("CA_UI_NEXT",InputEvent.Key_DownArrow,0,"",70);
                Button("CA_UI_DETAILS",0,102,"f",84);Button("CA_UI_ACT",InputEvent.Key_Enter,0,"",80);
                Button("CA_UI_ABANDON",0,103,"g",84);
                Button(tracked?"CA_TRACK_STOP":"CA_TRACK_START",0,116,"t",96,
                    quest>=0 && (tracked || user.JournalQuestState[quest]==CaelumConstants.QUEST_STATE_ACTIVE));
                Button("CA_UI_BACK",InputEvent.Key_Tab,0,"",72);
                // Los filtros tienen dos ejes independientes.
                Region(4002,320,108,280,18);
                Region(4003,40,108,280,18);
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
            bool canStand=!CaelumExhaustion.Locked(user);
            Row(145);Button("CA_UI_STAND",0,113,"q",92,canStand);Button("CA_UI_FAST",0,116,"t");Button("CA_UI_SKIP",0,121,"y",92,canStand);
            if(CaelumDiningSession.HasMealSupport(user))
            {Button("CA_UI_EAT",0,102,"f");Button("CA_UI_DRINK",0,103,"g");}
            Button("CA_UI_JOURNAL",InputEvent.Key_Tab,0,"",92,canStand);
        }
        else if(context==host.CTX_MERCHANT)
        {
            Row(326);PrevNext();Button("CA_UI_MODE",InputEvent.Key_Space);Button("CA_UI_TRADE",InputEvent.Key_Enter);Back();
            // La cantidad queda junto al total sin tapar el estado de la transacción.
            bool library=user.CityTrade!=null && user.CityTrade.Vendor.Category==CaelumShopCatalogue.LIBRARY && !user.CityTrade.Selling;
            NextX=library?520:440;RowY=library?57:275;
            Button(library?"CA_UI_PREVIOUS":"CA_UI_MINUS",InputEvent.Key_LeftArrow,0,"",library?44:32);
            Button(library?"CA_UI_NEXT":"CA_UI_PLUS",InputEvent.Key_RightArrow,0,"",library?44:32);
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
        else if(context==host.CTX_RECIPES)
        {
            let recipes=CaelumRecipeSession(user.FindInventory("CaelumRecipeSession"));
            if(recipes!=null)
            {
                int first=Max(0,recipes.Selection-2);
                for(int i=first;i<Min(first+5,int(recipes.Rows.Size()));i++)Region(10000+i,40,80+(i-first)*21,560,21);
            }
            Row(294);Button("CA_RECIPE_READ",InputEvent.Key_Enter,0,"",136);
            Button("CA_RECIPE_CATEGORY",0,103,"g",136);Button("CA_RECIPE_CANCEL",0,99,"c",136);
            Row(326);PrevNext();Back();Button("CA_UI_FAST",0,116,"t",130);Button("CA_UI_SKIP",0,121,"y",130);
        }
        else if(context==host.CTX_CHEST)
        {
            let storage=CaelumContainerSession(user.FindInventory("CaelumContainerSession"));
            if(storage!=null && storage.Chest!=null)
            {
                Row(278);Button("CA_UI_PREVIOUS",InputEvent.Key_UpArrow,0,"",140);
                Button("CA_UI_NEXT",InputEvent.Key_DownArrow,0,"",140);
                Button("CA_UI_MINUS",InputEvent.Key_LeftArrow,0,"",140);
                Button("CA_UI_PLUS",InputEvent.Key_RightArrow,0,"",140);
                Row(300);Button("CA_CONTAINER_MODE",InputEvent.Key_Space,0,"",188);
                Button("CA_CONTAINER_TRANSFER",InputEvent.Key_Enter,0,"",188);
                Button("CA_CONTAINER_CARRY",0,99,"c",188);
                Row(322);Button("CA_LOCK_TOGGLE",0,108,"l",188);
                Button("CA_UI_BACK",InputEvent.Key_Tab,0,"",188);
                int first=storage.Selection/4*4;double y=104;
                let font=Font.GetFont("CaelumSmall");
                for(int i=first;i<Min(first+4,storage.Labels.Size());i++)
                {
                    let lines=font.BreakLines("> "..storage.Labels[i],550);
                    double height=Min(2,lines.Count())*14+7;lines.Destroy();
                    Region(8000+i,42,y,550,height);y+=height;
                }
            }
            else
            {
                Row(303);Button("CA_UI_COLLECT",InputEvent.Key_Enter,0,"",280);Button("CA_UI_BACK",InputEvent.Key_Tab,0,"",280);
                Row(325);Button("CA_UI_NEXT",0,110,"n");
                Button("CA_CONTAINER_STORAGE",0,100,"d",188);Button("CA_CONTAINER_CARRY",0,99,"c",188);
            }
        }
        else if(context==host.CTX_PROPERTY)
        {
            let property=CaelumPropertySession(user.FindInventory("CaelumPropertySession"));
            bool available=property!=null && property.Portal!=null && property.Portal.args[1]!=0 && !property.Owned && !property.PaidThisVisit;
            Row(298);Button("CA_PROPERTY_BUY",0,98,"b",280,available);Button("CA_PROPERTY_RENT",0,114,"r",280,available);
            Row(326);Button("CA_PROPERTY_CROSS",InputEvent.Key_Enter,0,"",280);Button("CA_UI_BACK",InputEvent.Key_Tab,0,"",280);
        }
        else if(context==host.CTX_CLEAN)
        {
            let session=CaelumCleaningSession.Find(user);
            Row(326);Button("CA_CLEAN_START",InputEvent.Key_Enter,0,"",280,session!=null && session.Ready);Button("CA_UI_BACK",InputEvent.Key_Tab,0,"",280);
        }
        else if(context==host.CTX_BATH)
        {
            Row(250);Button("CA_BATH_MINUS",InputEvent.Key_LeftArrow,0,"",138);Button("CA_BATH_PLUS",InputEvent.Key_RightArrow,0,"",138);
            Button("CA_BATH_MINUS10",InputEvent.Key_PgDn,0,"",138);Button("CA_BATH_PLUS10",InputEvent.Key_PgUp,0,"",138);
            Row(282);Button("CA_BATH_MAX",0,109,"m",560);
            let bath=CaelumBathSession.Find(user);
            Row(326);Button("CA_BATH_START",InputEvent.Key_Enter,0,"",280,bath!=null && bath.Selected>0);Button("CA_UI_BACK",InputEvent.Key_Tab,0,"",280);
        }
        else if(context==host.CTX_CAMP_FIRE)
        {
            Row(206);Button("CA_CAMP_FIRE_MINUS",InputEvent.Key_LeftArrow,0,"",138);Button("CA_CAMP_FIRE_PLUS",InputEvent.Key_RightArrow,0,"",138);
            Button("CA_CAMP_FIRE_MINUS_KG",InputEvent.Key_PgDn,0,"",138);Button("CA_CAMP_FIRE_PLUS_KG",InputEvent.Key_PgUp,0,"",138);
            Row(246);Button("CA_CAMP_FIRE_MAX",0,109,"m",180);Button("CA_CAMP_FIRE_LOAD",0,114,"r",180);Button("CA_CAMP_FIRE_RECOVER",0,118,"v",180);
            Row(286);Button("CA_CAMP_FIRE_TOGGLE",InputEvent.Key_Enter,0,"",276);Button("CA_CAMP_FIRE_REMOVE",0,100,"d",276);
            Row(326);Button("CA_CAMP_FIRE_POT",0,112,"p",180);Button("CA_CAMP_FIRE_NEXT_POT",0,110,"n",180);Button("CA_UI_BACK",InputEvent.Key_Tab,0,"",180);
        }
        else if(context==host.CTX_CAMP_TENT)
        {
            Row(246);Button("CA_TENT_REST",InputEvent.Key_Enter,0,"",276);Button("CA_TENT_PACK",0,100,"d",276);
            Row(286);Button("CA_UI_BACK",InputEvent.Key_Tab,0,"",560);
        }
        else if(context==host.CTX_MATE)
        {
            Row(248);Button("CA_MATE_LOAD",0,114,"r",180);Button("CA_UI_PREVIOUS",InputEvent.Key_LeftArrow,0,"",180);Button("CA_UI_NEXT",InputEvent.Key_RightArrow,0,"",180);
            Row(274);Button("CA_MATE_FILL",0,102,"f",180);Button("CA_MATE_DRINK",InputEvent.Key_Enter,0,"",180);Button("CA_MATE_EMPTY",0,118,"v",180);
            Row(326);Button("CA_MATE_DISCARD",0,99,"c",276);Button("CA_UI_BACK",InputEvent.Key_Tab,0,"",276);
        }
        else if(context==host.CTX_EQUIPMENT)
        {
            Row(278);Button("CA_UI_CATEGORY",InputEvent.Key_Tab);Button("CA_UI_TYPE_PREV",InputEvent.Key_LeftArrow);
            Button("CA_UI_TYPE_NEXT",InputEvent.Key_RightArrow);Button("CA_UI_TIER",InputEvent.Key_Space);
            Button("CA_UI_SIZE",0,114,"r");Button("CA_UI_BACK",0,113,"q");
            Row(300);Button("CA_UI_USE",InputEvent.Key_Enter);Button("CA_UI_UNEQUIP",InputEvent.Key_Backspace);
            Button("CA_UI_BOX",0,99,"c");Button("CA_UI_DROP",0,100,"d");Button("CA_UI_BREAK",0,98,"b");Button("CA_UI_SPAWN",0,112,"p");
            Row(322);Button("CA_UI_SLOT_PREV",InputEvent.Key_UpArrow);Button("CA_UI_SLOT_NEXT",InputEvent.Key_DownArrow);Button("CA_BATH_START",0,104,"h");Button("CA_CLEAN_START",0,106,"j");
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
        if(host.Context==host.CTX_RECIPES && id>=10000)
        {EventHandler.SendNetworkEvent("ca_recipe_select",id-10000);return;}
        if(id==9001){host.ResetInput();Menu.SetMenu("CaelumNavigationMenu");return;}
        if(id==9000){host.ResetInput();Menu.SetMenu("CaelumNotificationMenu");return;}
        if(id>=8000)
        {
            let storage=CaelumContainerSession(user.FindInventory("CaelumContainerSession"));
            if(storage==null || storage.Chest==null)return;
            int delta=id-8000-storage.Selection;
            for(int i=0;i<Abs(delta);i++)EventHandler.SendNetworkEvent("ca_container_move",delta<0 ? -1 : 1);
            return;
        }
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
        if(id==4003){host.Stroke(0,99,"c");return;}
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
        else if(host.Context==host.CTX_CHEST)
        {
            let storage=CaelumContainerSession(host.Subject.FindInventory("CaelumContainerSession"));
            if(storage!=null && storage.Chest!=null)host.Stroke(direction<0?InputEvent.Key_UpArrow:InputEvent.Key_DownArrow);
            else host.Stroke(0,110,"n");
        }
        else host.Stroke(direction<0?InputEvent.Key_UpArrow:InputEvent.Key_DownArrow);
    }
}
