// Isolated engine fixture. No production test hooks or changed combat rules.
class CA215Contract : StaticEventHandler
{
    ui int Failures;
    ui Array<String> SavedTitles;
    override void NetworkProcess(ConsoleEvent e)
    {
        let user=CaelumPlayerAuthority.FromNetworkPlayer(e.Player);if(user==null)return;
        if(e.Name=="c215_ready")
        {
            if(user.player.ConversationNPC!=null)user.player.ConversationNPC.bInConversation=false;
            user.player.ConversationNPC=null;
        }
        if(e.Name=="c215_notices")
        {
            for(int i=0;i<25;i++)
                CaelumNotifications.Inbox(user).Add(String.Format("%02d: %s",i,StringTable.Localize(i%2==0?"CA215_LONG_EN":"CA215_LONG_ES",false)),120*TICRATE);
        }
        if(e.Name=="c215_station")
        {
            user.LearnCraftingRecipe(CaelumConstants.CRAFTING_PICKAXE_RECIPE);user.LearnAllProcessingRecipes();
            let it=ThinkerIterator.Create("CaelumCraftingStation");CaelumCraftingStation station;
            while((station=CaelumCraftingStation(it.Next()))!=null)
                if(station.CraftingRoomGroup==5 && station.GetCraftingStationType()==CaelumConstants.CRAFTING_STATION_WORKBENCH)
                {
                    user.SetOrigin(station.Pos+(0,48,0),false);user.Vel=(0,0,0);
                    station.CollectCraftingNetwork(user,user.BeginCraftingNetworkScan());
                    user.OpenCraftingNetwork(station);break;
                }
        }
        if(e.Name=="c215_dialogue")
        {
            if(user.player.ConversationNPC!=null)user.player.ConversationNPC.bInConversation=false;user.player.ConversationNPC=null;
            let it=ThinkerIterator.Create("CaelumPalomo");let npc=CaelumPalomo(it.Next());
            if(npc!=null){user.SetOrigin(npc.Pos+(48,0,0),false);user.Vel=(0,0,0);user.RecordMainM00UnknownVoiceHeard();user.OpenPalomoDialogue(npc);}
        }
        if(e.Name=="c215_identity")
        {
            let profile=CaelumCharacterIdentity.Profile(user);
            profile.Race=e.Args[0];profile.Sex=e.Args[1];profile.SkinTone=e.Args[2];
            user.CharacterCreationComplete=true;user.ApplyCharacterProfile();
        }
        if(e.Name=="c215_mode")
        {
            let a=CaelumTrucoMatch.Get(user);if(a!=null)a.Visible=false;
            let b=CaelumTrucazoMatch.Get(user);if(b!=null)b.Visible=false;
            if(e.Args[0]!=0)
            {CaelumTimeSkipState.FinishSkip(user,"CA_SKIP_CANCELLED",true);user.CloseCraftingStationSession();}
            if(e.Args[0]==0)CaelumTimeSkipState.OpenMenu(user);
            if(e.Args[0]>0)
            {
                CaelumTarotDeckRules.Grant(user);
                let it=ThinkerIterator.Create("CaelumArgento");let npc=CaelumArgento(it.Next());
                user.player.ConversationNPC=npc;
                if(e.Args[0]==1)CaelumTrucoMatch.Open(user,npc);else CaelumTrucazoMatch.Open(user,npc);
                if(npc!=null)npc.bInConversation=false;user.player.ConversationNPC=null;
            }
        }
    }
    ui void Check(bool ok,String label)
    {if(!ok)Failures++;Console.Printf("CA215 %s %s",ok?"PASS":"FAIL",label);}
    override void ConsoleProcess(ConsoleEvent e)
    {
        let user=consoleplayer>=0?CaelumPlayer(players[consoleplayer].mo):null;
        if(e.Name=="c215_close")
        {CaelumLiveMenu.Journal().SetJournalOpen(false);while(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();}
        if(e.Name=="c215_journal")
        {CaelumLiveMenu.Journal().SetJournalOpen(true);CaelumLiveMenu.Journal().SetJournalPage(e.Args[0]);Menu.SetMenu("CaelumLiveMenu");}
        if(e.Name=="c215_creator")
        {Menu.SetMenu("CaelumNewCharacterMenu");CaelumCharacterCreationMenu(Menu.GetCurrentMenu()).Page=e.Args[0];}
        if(e.Name=="c215_native")
        {
            String names[]={"OptionsMenu","OptionsMenuSimple","SoundOptionsSimple","VideoOptionsSimple","ScalingOptionsSimple","CustomizeControls","CaelumCombatControls","CaelumAbilityControls","CaelumComfortOptions","os_Menu","SaveGameMenu","LoadGameMenu"};
            Menu.SetMenu(names[Clamp(e.Args[0],0,11)]);
            Console.Printf("CA215 MENU %s class=%s",names[Clamp(e.Args[0],0,11)],Menu.GetCurrentMenu().GetClassName());
        }
        if(e.Name=="c215_dialoguecheck")
        {
            let menu=CaelumHistoryConversationMenu(Menu.GetCurrentMenu());Check(menu!=null,"native dialogue opened");
            if(menu!=null)
            {
                bool found=false;for(int i=0;i<menu.mResponseLines.Size();i++)if(menu.mResponseLines[i].IndexOf("(1)")>=0)found=true;
                Check(found,"first native numbered reply has parenthesized key");
                Check(menu.ReplyMap.Size()==menu.mResponses.Size(),"pagination preserves reply map");
            }
        }
        if(e.Name=="c215_search")
        {
            Menu.SetMenu("os_Menu");let menu=os_Menu(Menu.GetCurrentMenu());Check(menu!=null,"search subclass preserves native type");
            if(menu!=null)
            {
                let field=menu.mDesc.mItems[0];Check(field!=null,"native search field exists");
                if(field!=null)
                {
                    field.MenuEvent(Menu.MKEY_Enter,false);let editor=TextEnterMenu(Menu.GetCurrentMenu());
                    String query=CVar.GetCVar("language").GetString()=="es"?(e.Args[0]==0?"sonido":"controles"):(e.Args[0]==0?"sound":"controls");
                    Check(editor!=null,"native search text editor opens");
                    if(editor!=null)
                    {
                        editor.mEnterString=query;
                        menu.MenuEvent(Menu.MKEY_Input,false);editor.Close();
                    }
                    Console.Printf("CA215 SEARCH rows=%d",menu.mDesc.mItems.Size());Check(menu.mDesc.mItems.Size()>4,"typed query finds native results");
                }
                bool clean=true;for(int i=0;i<menu.mDesc.mItems.Size();i++)if(menu.mDesc.mItems[i].mLabel.IndexOf("(Enter)")>=0)clean=false;
                Check(clean,"search source captions contain no decoration");
            }
        }
        if(e.Name=="c215_savecheck")
        {
            let menu=LoadSaveMenu(Menu.GetCurrentMenu());Check(menu!=null,"native save/load menu type retained");
            if(menu!=null)
            {
                if(e.Args[0]==0){SavedTitles.Clear();for(int i=0;i<menu.manager.SavegameCount();i++)SavedTitles.Push(menu.manager.GetSavegame(i).SaveTitle);return;}
                bool same=SavedTitles.Size()==menu.manager.SavegameCount();for(int i=0;i<SavedTitles.Size();i++)if(SavedTitles[i]!=menu.manager.GetSavegame(i).SaveTitle)same=false;
                Check(same,"rendered hints never change stored save names");
            }
        }
        if(e.Name=="c215_keycapture")
        {
            Menu.SetMenu("CaelumCombatControls");let menu=OptionMenu(Menu.GetCurrentMenu());
            for(int i=0;i<menu.mDesc.mItems.Size();i++)if(menu.mDesc.mItems[i].GetAction()=='+reload')menu.mDesc.mSelectedItem=i;
            menu.MenuEvent(Menu.MKEY_Enter,false);let capture=EnterKey(Menu.GetCurrentMenu());
            Check(capture!=null,"Enter opens native key capture");
            if(capture!=null){menuactive=Menu.On;capture.Close();menu.MenuEvent(Menu.MKEY_Abort,false);}
            Check(Menu.GetCurrentMenu()==menu,"aborting key capture restores native control menu");
        }
        if(e.Name=="c215_calendar")
        {CaelumLiveMenu.Journal().SetJournalOpen(true);CaelumLiveMenu.Journal().SetJournalPage(2);CaelumScheduleCalendar.Open(user);}
        if(e.Name=="c215_calendarcheck")
        {
            let menu=CaelumLiveMenu(Menu.GetCurrentMenu());Check(menu!=null && menu.Context==menu.CTX_CALENDAR,"calendar native context");
            Check(CaelumInputHints.ContextKey(0,113)==StringTable.Localize("CA_HINT_MOUSE",false),"calendar Q cannot mask remapped Journal");
        }
        if(e.Name=="c215_reserved")
        {
            Check(CaelumInputHints.MenuKeys("ca_journal_toggle").IndexOf("Enter")<0,"bound navigation key is not advertised for closing");
            Check(CaelumInputHints.BoundOrFallback("Back","ca_journal_toggle",InputEvent.Key_Tab).IndexOf("Tab")>=0,"fallback Tab remains advertised");
        }
        if(e.Name=="c215_consumed")
        {
            Check(CaelumInputHints.MenuKeys("ca_journal_toggle")==StringTable.Localize("CA_HINT_MOUSE",false),"wheel bindings are consumed by menu scrolling");
            Check(CaelumInputHints.MenuKeys("ca_time_skip")==StringTable.Localize("CA_INTRO_UNBOUND",false),"unbound action is identified honestly");
        }
        if(e.Name=="c215_box")
        {
            let box=new("CA215MessageBox");box.Init(Menu.GetCurrentMenu(),"CA215",0,false,'None',null);box.ActivateMenu();
        }
        if(e.Name=="c215_boxcheck")
        {
            let box=CA215MessageBox(Menu.GetCurrentMenu());Check(box!=null,"confirmation test opened");
            if(box!=null)
            {
                box.ClickHint();
                Check(box.Answered && box.Result,"click on appended Yes hint confirms Yes");box.Close();
            }
        }
        if(e.Name=="c215_restore")
        {
            let m=OptionMenu(Menu.GetCurrentMenu());Check(m!=null,"native option menu is open");
            if(m!=null)
            {
                Array<String> labels;for(int i=0;i<m.mDesc.mItems.Size();i++)labels.Push(m.mDesc.mItems[i].mLabel);
                let pass=CaelumNativeMenuHints.Begin(m.mDesc);int hints=0;
                for(int i=0;i<m.mDesc.mItems.Size();i++)if(m.mDesc.mItems[i].mLabel!=labels[i])hints++;
                Check(hints>0,"selectable options receive hints during drawing");pass.End();
                bool restored=true;for(int i=0;i<labels.Size();i++)if(m.mDesc.mItems[i].mLabel!=labels[i])restored=false;
                Check(restored,"native labels restored outside draw pass");
            }
        }
        if(e.Name=="c215_hints")
        {
            Check(CaelumInputHints.Label("Action","K")=="Action (K)","parenthesized formatter");
            Check(CaelumInputHints.Keys("ca_journal_toggle")~=="K","remapped journal hint");
            Check(CaelumInputHints.Keys("ca_time_skip")~=="U","remapped time-skip hint");
            Check(CaelumInputHints.Bound("Skip","ca_time_skip").IndexOf("(")>=0,"command caption contains actual binding");
            Check(CaelumInputHints.ContextKey(0,117)==StringTable.Localize("CA_HINT_MOUSE",false),"shadowed contextual letter advertises click");
            Check(CaelumInputHints.ContextKey(InputEvent.Key_Enter)==CaelumInputHints.KeyName(InputEvent.Key_Enter),"native Enter navigation stays available");
        }

        if(e.Name=="c215_intro")
        {Menu.SetMenu("CaelumIntroductionMenu");CaelumIntroductionMenu(Menu.GetCurrentMenu()).Revealed=true;}
        if(e.Name=="c215_history")Menu.SetMenu("CaelumNotificationMenu");
        if(e.Name=="c215_scale")
        {
            Vector2 hud=CaelumPresentation.HUDScale(), message=CaelumPresentation.MessageScale(), factors=CaelumPresentation.MenuFactors();
            Console.Printf("CA215 SCALE screen=%dx%d ui=%d journal=%.4f creator=%.4f hud=%.4f,%.4f message=%.4f,%.4f",Screen.GetWidth(),Screen.GetHeight(),CaelumPresentation.UIScale(),factors.X,CaelumPresentation.CreatorFactor(),hud.X,hud.Y,message.X,message.Y);
            Vector2 origin,size;[origin,size]=CaelumPresentation.MenuRect((0,0),(640,360));
            Check(origin.X>=-0.01 && origin.Y>=-0.01 && origin.X+size.X<=Screen.GetWidth()+0.01 && origin.Y+size.Y<=Screen.GetHeight()+0.01,"menu viewport bounds");
            Vector2 point=CaelumMenuPointer.JournalPoint(origin.X+size.X*0.8,origin.Y+size.Y*0.2);
            Check(Abs(point.X-512)<0.01 && Abs(point.Y-72)<0.01,"journal drawing/mouse inverse");
            Check(hud.X*640<=Screen.GetWidth()+0.01 && hud.Y*360<=Screen.GetHeight()+0.01,"HUD viewport bounds");
        }
        if(e.Name=="c215_crosshair")Check(CaelumPresentation.CrosshairVisible()==(e.Args[0]!=0),"contextual native crosshair gate");
        if(e.Name=="c215_historycheck")
        {
            let inbox=CaelumNotificationInbox(user.FindInventory("CaelumNotificationInbox"));
            Check(inbox!=null && inbox.HistoryCount==20 && inbox.HistoryRevision==1,"20-entry persistent history");
            if(inbox!=null)Check(inbox.HistoryText[0].IndexOf("05:")==0 && inbox.HistoryText[19].IndexOf("24:")==0,"history chronological retention");
            let menu=CaelumNotificationMenu(Menu.GetCurrentMenu());
            Check(menu!=null && menu.Lines.Size()>20,"history wraps complete long messages");
            if(menu!=null)
            {
                menu.MenuEvent(Menu.MKEY_PageDown,false);Check(menu.Offset>0,"keyboard history scroll");
                menu.Scroll(10000);Check(menu.Offset+menu.VisibleLines==menu.Lines.Size(),"last history line reachable");
                Check(menuactive==Menu.OnNoPause,"history remains unpaused");
            }
        }
        if(e.Name=="c215_pointer")
        {
            let menu=CaelumLiveMenu(Menu.GetCurrentMenu());
            Vector2 origin,size;[origin,size]=CaelumPresentation.MenuRect((508,15),(100,18));
            if(menu!=null)
            {
                menu.MouseEvent(Menu.MOUSE_Click,int(origin.X+size.X/2),int(origin.Y+size.Y/2));
                menu.MouseEvent(Menu.MOUSE_Release,int(origin.X+size.X/2),int(origin.Y+size.Y/2));
            }
            Check(CaelumNotificationMenu(Menu.GetCurrentMenu())!=null,"scaled Journal notice button dispatch");
        }
        if(e.Name=="c215_done")Console.Printf("CA215 DONE failures=%d",Failures);
        if(e.Name=="c215_remap")
        {
            let menu=CaelumLiveMenu(Menu.GetCurrentMenu());
            Check(CaelumNotificationMenu.Link().IndexOf("(L)")<0,"history hint omits conflicting contextual L");
            if(menu!=null)menu.Key(InputEvent.Type_KeyDown,CaelumMenuPointer.KeyScan(108),108,"l",true);
            Check(!CaelumLiveMenu.Journal().IsJournalOpen() && CaelumNotificationMenu(Menu.GetCurrentMenu())==null,"remapped L closes Journal before history shortcut");
        }
        if(e.Name=="c215_creatorclick")
        {
            let menu=CaelumCharacterCreationMenu(Menu.GetCurrentMenu());
            if(menu!=null)
            {
                double factor=CaelumPresentation.CreatorFactor(), base=Screen.GetHeight()/600.0;
                double left=(CaelumNarrativeArtwork.CanvasWidth()-760)/2;
                int x=int((left+2*194+89)*base*factor+Screen.GetWidth()*(1-factor)/2);
                int y=int(566*base*factor+Screen.GetHeight()*(1-factor)/2);
                int before=menu.Race;
                menu.MouseEvent(Menu.MOUSE_Click,x,y);menu.MouseEvent(Menu.MOUSE_Release,x,y);
                Check(menu.Race!=before,"creator scaled Next button dispatch");
            }
            else Check(false,"creator menu exists");
        }
        if(e.Name=="c215_identitycheck")
        {
            let profile=CaelumCharacterIdentity.Profile(user);
            Check(profile.Race==e.Args[0] && profile.Sex==e.Args[1] && profile.SkinTone==e.Args[2],"loaded per-character identity");
            Check(CVar.GetCVar("uiscale").GetInt()==2 && CVar.GetCVar("con_scaletext").GetInt()==3
                && CVar.GetCVar("crosshair").GetInt()==2 && CVar.GetCVar("crosshairon").GetBool()
                && Abs(CVar.GetCVar("crosshairscale").GetFloat()-1.25)<0.001
                && CVar.GetCVar("crosshaircolor").GetString()~=="00 80 ff"
                && Abs(CVar.GetCVar("movebob",user.player).GetFloat()-0.05)<0.001
                && Abs(CVar.GetCVar("stillbob",user.player).GetFloat()-0.1)<0.001
                && Abs(CVar.GetCVar("wbobspeed",user.player).GetFloat()-0.6)<0.001
                && CVar.GetCVar("wbobfire",user.player).GetFloat()==0
                && Abs(CVar.GetCVar("r_quakeintensity").GetFloat()-0.25)<0.001,"global native preferences survive character load/restart");
        }
        if(e.Name=="c215_cardclick")
        {
            let a=CaelumTrucoMenu(Menu.GetCurrentMenu());let b=CaelumTrucazoMenu(Menu.GetCurrentMenu());
            Check(a!=null || b!=null,"native card menu open");int row=-1;
            if(a!=null){a.Choices();for(int i=0;i<a.Operations.Size();i++)if(a.Operations[i]==CaelumTrucoRules.BEGIN)row=i;}
            if(b!=null){b.Choices();for(int i=0;i<b.Operations.Size();i++)if(b.Operations[i]==CaelumTrucazoRules.BEGIN)row=i;}
            Check(row>=0,"begin card action available");
            if(row>=0)
            {
                int x=int(CaelumTrucoMenu.UILeft()+650*CaelumTrucoMenu.UIScale());
                int y=int(CaelumTrucoMenu.UITop()+(120+row*(a!=null?24:27))*CaelumTrucoMenu.UIScale());
                if(a!=null){a.MouseEvent(Menu.MOUSE_Click,x,y);a.MouseEvent(Menu.MOUSE_Release,x,y);}
                else{b.MouseEvent(Menu.MOUSE_Click,x,y);b.MouseEvent(Menu.MOUSE_Release,x,y);}
            }
        }
        if(e.Name=="c215_cardcheck")
        {
            let a=CaelumTrucoMatch(user.FindInventory("CaelumTrucoMatch"));let b=CaelumTrucazoMatch(user.FindInventory("CaelumTrucazoMatch"));
            Check(e.Args[0]==1?a!=null && a.HandNumber>0:b!=null && b.HandNumber>0,"scaled card click begins actual match");
            Check(menuactive==Menu.On,"card game keeps accepted native pause");
        }
    }
}

class CA215MessageBox : CaelumNarrativeMessageBox
{
    void ClickHint()
    {
        String yes=StringTable.Localize("$TXT_YES");
        double x=destWidth/2+textFont.StringWidth(yes.." (Y)")*NotifyFontScale-1;
        Vector2 origin=(x*Screen.GetWidth()/destWidth,(mMouseY+textFont.GetHeight()*NotifyFontScale/2)*Screen.GetHeight()/destHeight);
        MouseEvent(Menu.MOUSE_Click,int(origin.X),int(origin.Y));MouseEvent(Menu.MOUSE_Release,int(origin.X),int(origin.Y));
        Console.Printf("CA215 BOX xy=%f,%f rect=%d,%d,%d virtual=%d,%d scale=%f selection=%d answered=%d result=%d",origin.X,origin.Y,mMouseLeft,mMouseRight,mMouseY,destWidth,destHeight,NotifyFontScale,messageSelection,Answered,Result);
    }
    bool Answered,Result;
    override void HandleResult(bool result){Answered=true;self.Result=result;}
}
