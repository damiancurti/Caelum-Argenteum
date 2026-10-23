// Un único propietario nativo para las vistas que mantienen viva la simulación.
class CaelumLiveMenu : ListMenu
{
    enum ContextType { CTX_SKIP=100, CTX_JOURNEY, CTX_REST, CTX_MERCHANT, CTX_CALENDAR, CTX_EQUIPMENT, CTX_CHEST, CTX_CREATION, CTX_RECIPES };
    CaelumPlayer Subject;
    String OriginMap;
    int Context;
    CaelumMenuPointer Pointer;
    CaelumLiveMenuControls Controls;
    bool OrbitHeld;
    Vector2 OrbitPoint;

    static bool InputAllowed() {return menuactive==Menu.Off || CaelumLiveMenu(Menu.GetCurrentMenu())!=null;}
    static CaelumJournalOverlay Journal() {return CaelumJournalOverlay(EventHandler.Find("CaelumJournalOverlay"));}
    static int Wanted(CaelumPlayer user)
    {
        if(gamestate!=GS_LEVEL || user==null || user.health<=0 || user.player==null || (user.player.ConversationNPC!=null && user.player.ConversationNPC.bInConversation))return 0;
        let truco=CaelumTrucoMatch(user.FindInventory("CaelumTrucoMatch"));
        let trucazo=CaelumTrucazoMatch(user.FindInventory("CaelumTrucazoMatch"));
        if((truco!=null && truco.Visible) || (trucazo!=null && trucazo.Visible))return 0;
        if(user.CreationWizardOpen)return CTX_CREATION;
        let recipes=CaelumRecipeSession(user.FindInventory("CaelumRecipeSession"));
        if(recipes!=null && recipes.Open)return CaelumJournalInput.SkipOpen(user)?CTX_SKIP:CTX_RECIPES;
        let storage=CaelumContainerSession(user.FindInventory("CaelumContainerSession"));
        if(storage!=null && storage.Chest!=null)return CTX_CHEST;
        let preview=CaelumChestPreviewState(user.FindInventory("CaelumChestPreviewState"));
        if(preview!=null && preview.IsOpen())return CTX_CHEST;
        if(user.EquipmentMenuOpen)return CTX_EQUIPMENT;
        if(CaelumJournalInput.SkipOpen(user))return CTX_SKIP;
        let journey=CaelumJourneyPlan(user.FindInventory("CaelumJourneyPlan"));
        if(journey!=null && journey.Open && journey.Available!=null)return CTX_JOURNEY;
        let rest=CaelumRestState(user.FindInventory("CaelumRestState"));
        if(rest!=null && rest.Status==CaelumRestRules.STATUS_ACTIVE)return CTX_REST;
        if(user.PalomoMerchantMenuOpen)return CTX_MERCHANT;
        let view=Journal();
        if(view==null || !view.IsJournalOpen())return 0;
        if(view.GetJournalPage()==2 && CaelumScheduleCalendar.IsOpen())return CTX_CALENDAR;
        return view.GetJournalPage()+1;
    }
    override void Init(Menu parent,ListMenuDescriptor desc)
    {
        Super.Init(parent,desc);DontDim=true;DontBlur=true;
        Subject=consoleplayer>=0?CaelumPlayer(players[consoleplayer].mo):null;
        OriginMap=level.MapName;Context=Wanted(Subject);
        Controls=new("CaelumLiveMenuControls");
        Pointer=CaelumJournalInput.PointerFor(Context);Pointer.Reset();
        menuactive=Menu.OnNoPause;
    }
    void ResetPointer() {Pointer.Reset();OrbitHeld=false;SetCapture(false);}
    void ResetInput()
    {
        ResetPointer();
        let journal=Journal();if(journal!=null){journal.QuestTrackHeld=false;journal.FermentationDiscardHeld=false;}
        CaelumScheduleCalendar.Set("ca_journal_tarot_select_held",0);
        CaelumScheduleCalendar.Set("ca_journal_quest_abandon_held",0);
    }
    override void OnReturn(){ResetInput();if(GetCurrentMenu()==self)menuactive=Menu.OnNoPause;}
    override void Ticker()
    {
        if(GetCurrentMenu()!=self)return;
        if(consoleplayer<0 || players[consoleplayer].mo!=Subject || OriginMap!=level.MapName || Wanted(Subject)==0)
        {ResetInput();Close();return;}
        int wanted=Wanted(Subject);
        if(wanted!=Context){ResetInput();Context=wanted;Pointer=CaelumJournalInput.PointerFor(Context);}
        if(ConsoleState!=c_up)ResetInput();
        menuactive=Menu.OnNoPause;
    }
    int Revision()
    {
        // Identidad seleccionada, no los valores de supervivencia que cambian cada tic.
        let view=Journal();
        int result=Context*100000;
        if(Context==CTX_REST)
        {let rest=CaelumRestState(Subject.FindInventory("CaelumRestState"));if(rest!=null)result+=rest.Mode*4+(CaelumDiningSession.HasMealSupport(Subject)?1:0)+(CaelumExhaustion.Locked(Subject)?2:0);}
        if(Context==1 || Context==CTX_EQUIPMENT)result+=Subject.EquipmentSelectionItemId*31+Subject.EquipmentSelectionKind*7+Subject.EquipmentSelectionTier
            +Subject.FormalInventorySelectionIndex*97+Subject.FormalInventoryFilter*503;
        if(Context==5)result+=view.GetVisibleQuestId(Subject)*2+(view.IsQuestDetailOpen()?1:0);
        if(Context==7)result+=view.GetTarotSelection(Subject)+2;
        if(Context==CTX_CALENDAR)result+=CaelumScheduleCalendar.SelectedDay(Subject)*31+CaelumScheduleCalendar.Setting("ca_calendar_event")*2+CaelumScheduleCalendar.Setting("ca_calendar_detail");
        if(Context==CTX_MERCHANT)result+=Subject.PalomoMerchantSelection*10+Subject.PalomoMerchantMode
            +Subject.PalomoMerchantSelectedQuantity*71+Subject.PalomoMerchantSelectedLotPrice*31
            +(Subject.CityTrade==null?0:Subject.CityTrade.Selection*97+Subject.CityTrade.CategoryFilter*131);
        if(Context==CTX_RECIPES){let recipes=CaelumRecipeSession(Subject.FindInventory("CaelumRecipeSession"));if(recipes!=null)result+=recipes.Selection+recipes.Filter*1000;}
        if(Context==CTX_CHEST)
        {
            let storage=CaelumContainerSession(Subject.FindInventory("CaelumContainerSession"));
            if(storage!=null && storage.Chest!=null)
                result+=1000+storage.Selection*31+storage.QuantityIndex*7+int(storage.Depositing)*503;
            else {let preview=CaelumChestPreviewState(Subject.FindInventory("CaelumChestPreviewState"));if(preview!=null)result+=preview.Page;}
        }
        return result;
    }
    override void Drawer()
    {
        if(Subject==null || Wanted(Subject)!=Context)return;
        let debug=CaelumDebugOverlay(EventHandler.Find("CaelumDebugOverlay"));
        if(Context==CTX_CREATION || Context==CTX_EQUIPMENT)Screen.Dim(0x05070A,0.92,0,0,Screen.GetWidth(),Screen.GetHeight());
        CaelumPresentation.BeginMenu();
        if(Context==CTX_CREATION)debug.DrawCreationWizard(Subject);
        else if(Context==CTX_EQUIPMENT)debug.DrawEquipmentMenu(Subject);
        else if(Context==CTX_CHEST)CaelumChestPreview.Draw();
        else if(Context==CTX_RECIPES)CaelumRecipeEvents.Draw(Subject);
        else Journal().DrawMenu();
        Controls.Layout(self,true);
        CaelumPresentation.End();
        if(Context==CTX_REST && GetCurrentMenu()==self && menuactive==Menu.OnNoPause)
            CaelumNotifications.DrawRestFeedback(Subject,Journal().TextFont);
    }
    bool Key(int type,int scan,int character,String keyString,bool physical=true)
    {
        if(Wanted(Subject)!=Context)return true;
        if(type==InputEvent.Type_KeyDown)ResetPointer();
        if(scan==InputEvent.Key_Grave)return false;
        if(physical && Context>=1 && Context<=7 && CaelumExplorationNavigation.Shortcut(type,scan))return true;
        if(Context>=1 && Context<=7 && keyString~=="n"
            && (!physical || (!CaelumInputHints.Matches(scan,"ca_journal_toggle") && !CaelumInputHints.Matches(scan,"ca_time_skip"))))
        {if(type==InputEvent.Type_KeyDown){ResetInput();Menu.SetMenu("CaelumNavigationMenu");}return true;}
        if(Context>=1 && Context<=7 && keyString~=="l"
            && (!physical || (!CaelumInputHints.Matches(scan,"ca_journal_toggle") && !CaelumInputHints.Matches(scan,"ca_time_skip"))))
        {if(type==InputEvent.Type_KeyDown)Menu.SetMenu("CaelumNotificationMenu");return true;}
        if(scan==InputEvent.Key_Escape || scan==InputEvent.Key_Pad_Start)
        {
            if(type==InputEvent.Type_KeyDown){ResetInput();menuactive=Menu.On;Menu.SetMenu("MainMenu");}
            return true;
        }
        if(Context==CTX_EQUIPMENT || Context==CTX_CREATION)
            return CaelumDebugOverlay(EventHandler.Find("CaelumDebugOverlay")).PanelKey(type,scan,character,keyString);
        if(Context==CTX_CHEST)
            return CaelumChestPreview.PanelKey(Subject,type,scan,keyString);
        if(Context==CTX_RECIPES)return CaelumRecipeEvents.Key(Subject,type,scan,keyString);
        // Las acciones del panel y sus accesos remapeados preceden a la salida
        // por controles de juego: F/G/T pueden compartir +zoom/+user1/+user3.
        bool restAction=keyString~=="f" || keyString~=="g" || keyString~=="t"
            || character==102 || character==70 || character==103 || character==71
            || character==116 || character==84
            || CaelumInputHints.Matches(scan,"ca_journal_toggle")
            || CaelumInputHints.Matches(scan,"ca_time_skip");
        if(physical && Context==CTX_REST && type==InputEvent.Type_KeyDown && !restAction)
        {
            String binding=Bindings.GetBinding(scan);
            if(binding~=="+forward" || binding~=="+back" || binding~=="+moveleft" || binding~=="+moveright"
                || binding~=="+attack" || binding~=="+altattack" || binding~=="+use" || binding~=="+jump"
                || binding~=="+crouch" || binding~=="+zoom" || binding~=="+reload" || binding~=="+moveup" || binding~=="+movedown"
                || binding~=="+user1" || binding~=="+user2" || binding~=="+user3" || binding~=="+user4")
            {
                // La tecla que inició el descanso debe soltarse antes de cancelar.
                let rest=CaelumRestState(Subject.FindInventory("CaelumRestState"));
                if(rest!=null && rest.InputArmed)EventHandler.SendNetworkEvent("ca_rest_cancel");
                return true;
            }
        }
        return Journal().PanelKey(type,scan,character,keyString,physical);
    }
    void Stroke(int scan,int character=0,String keyString="")
    {
        // Botones y navegación nativa son acciones de contexto, no teclas físicas.
        Key(InputEvent.Type_KeyDown,scan,character,keyString,false);
        Key(InputEvent.Type_KeyUp,scan,character,keyString,false);
    }
    override bool MenuEvent(int key,bool fromcontroller)
    {
        int scan=0;
        if(key==MKEY_Up)scan=InputEvent.Key_UpArrow;
        else if(key==MKEY_Down)scan=InputEvent.Key_DownArrow;
        else if(key==MKEY_Left)scan=InputEvent.Key_LeftArrow;
        else if(key==MKEY_Right)scan=InputEvent.Key_RightArrow;
        else if(key==MKEY_PageUp)scan=InputEvent.Key_PgUp;
        else if(key==MKEY_PageDown)scan=InputEvent.Key_PgDn;
        else if(key==MKEY_Enter)scan=InputEvent.Key_Enter;
        else if(key==MKEY_Clear)scan=InputEvent.Key_Backspace;
        else if(key==MKEY_Back)scan=fromcontroller?InputEvent.Key_Pad_B:InputEvent.Key_Escape;
        if(scan!=0)Stroke(scan);
        return true;
    }
    override bool OnInputEvent(InputEvent e)
    {
        if(Context>=1 && Context<=7 && CaelumExplorationNavigation.IsShortcut(Bindings.GetBinding(e.KeyScan)))
            return Key(e.Type,e.KeyScan,e.KeyChar,e.KeyString);
        if(CaelumInputHints.Matches(e.KeyScan,"ca_journal_toggle") || CaelumInputHints.Matches(e.KeyScan,"ca_time_skip"))
            return Key(e.Type,e.KeyScan,e.KeyChar,e.KeyString);
        if(e.KeyScan==InputEvent.Key_Pad_A || e.KeyScan==InputEvent.Key_Pad_B || e.KeyScan==InputEvent.Key_Pad_X || e.KeyScan==InputEvent.Key_Pad_Y
            || e.KeyScan==InputEvent.Key_Pad_LShoulder || e.KeyScan==InputEvent.Key_Pad_RShoulder
            || e.KeyScan==InputEvent.Key_Pad_LTrigger || e.KeyScan==InputEvent.Key_Pad_RTrigger)
            return Key(e.Type,e.KeyScan,e.KeyChar,e.KeyString);
        return false;
    }
    override bool OnUIEvent(UIEvent e)
    {
        int mouseScan=0;bool down=false;
        if(e.Type==UIEvent.Type_FwdButtonDown || e.Type==UIEvent.Type_FwdButtonUp)
        {mouseScan=InputEvent.Key_Mouse5;down=e.Type==UIEvent.Type_FwdButtonDown;}
        if(e.Type==UIEvent.Type_MButtonDown || e.Type==UIEvent.Type_MButtonUp)
        {mouseScan=InputEvent.Key_Mouse3;down=e.Type==UIEvent.Type_MButtonDown;}
        if(mouseScan!=0 && (CaelumInputHints.Matches(mouseScan,"ca_journal_toggle") || CaelumInputHints.Matches(mouseScan,"ca_time_skip")
            || (Context>=1 && Context<=7 && CaelumExplorationNavigation.IsShortcut(Bindings.GetBinding(mouseScan)))))
            return Key(down?InputEvent.Type_KeyDown:InputEvent.Type_KeyUp,mouseScan,0,"");
        if(e.Type==UIEvent.Type_KeyDown || e.Type==UIEvent.Type_KeyUp)
        {
            int scan=CaelumMenuPointer.KeyScan(e.KeyChar);
            String keyString=e.KeyChar>=32 && e.KeyChar<127?String.Format("%c",e.KeyChar):e.KeyString;
            return Key(e.Type==UIEvent.Type_KeyDown?InputEvent.Type_KeyDown:InputEvent.Type_KeyUp,scan,e.KeyChar,keyString);
        }
        if(OrbitInput(e.Type,e.MouseX,e.MouseY))return true;
        if(e.Type==UIEvent.Type_WheelUp || e.Type==UIEvent.Type_WheelDown)
        {Controls.Wheel(self,e.Type==UIEvent.Type_WheelDown?1:-1,CaelumMenuPointer.JournalPoint(e.MouseX,e.MouseY));return true;}
        return Super.OnUIEvent(e);
    }
    bool OrbitInput(int type,int x,int y)
    {
        if(GetCurrentMenu()!=self || Wanted(Subject)!=Context){ResetPointer();return false;}
        if(type==UIEvent.Type_RButtonDown && Context==CTX_REST)
        {ResetInput();OrbitHeld=true;OrbitPoint=(x,y);SetCapture(true);return true;}
        if(type==UIEvent.Type_RButtonUp)
        {OrbitHeld=false;SetCapture(false);return true;}
        if(type==UIEvent.Type_MouseMove && OrbitHeld && Context==CTX_REST)
        {
            Vector2 point=(x,y),delta=(point-OrbitPoint)*360.0/Screen.GetWidth();OrbitPoint=point;
            delta.X*=CVar.GetCVar("m_sensitivity_x").GetFloat()*CVar.GetCVar("m_yaw").GetFloat();
            delta.Y*=CVar.GetCVar("m_sensitivity_y").GetFloat()*CVar.GetCVar("m_pitch").GetFloat();
            if(CVar.GetCVar("invertmousex").GetBool())delta.X=-delta.X;
            if(CVar.GetCVar("invertmouse").GetBool())delta.Y=-delta.Y;
            EventHandler.SendNetworkEvent("ca_rest_camera",int(-delta.X*1000),int(delta.Y*1000));return true;
        }
        if(OrbitHeld)return true;
        return false;
    }
    override bool MouseEvent(int type,int x,int y)
    {
        if(Wanted(Subject)!=Context || OrbitHeld)return true;
        Vector2 point=CaelumMenuPointer.JournalPoint(x,y);
        return PointerInput(type,point);
    }
    bool PointerInput(int type,Vector2 point)
    {
        if(Wanted(Subject)!=Context)return true;
        int eventType=type==MOUSE_Click?UIEvent.Type_LButtonDown:type==MOUSE_Release?UIEvent.Type_LButtonUp:UIEvent.Type_MouseMove;
        if(Context==CTX_SKIP)return CaelumTimeSkipPanel.PointerInput(Journal(),Subject,eventType,point);
        if(Context==4 && !(point.Y>=36 && point.Y<101 && point.X>=26 && point.X<614)
            && !CaelumMenuPointer.Inside(point,(508,15),(100,18))
            && !CaelumMenuPointer.Inside(point,(32,15),(104,18)))
            return CaelumCraftingUI.Mouse(Journal(),Subject,eventType,point);
        Controls.Layout(self,false);Pointer.Move(point);
        if(type==MOUSE_Click)Pointer.Press(Revision());
        else if(type==MOUSE_Release)
        {int id=Pointer.Release(Revision());if(id!=0)Controls.Activate(self,id);}
        return true;
    }
}
