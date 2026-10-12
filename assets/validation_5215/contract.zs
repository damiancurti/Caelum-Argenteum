// Isolated engine fixture. No production test hooks or changed combat rules.
class CA150Contract : StaticEventHandler
{
    ui int Failures;
    override void NetworkProcess(ConsoleEvent e)
    {
        let user=CaelumPlayerAuthority.FromNetworkPlayer(e.Player);if(user==null)return;
        if(e.Name=="c150_ready")
        {
            if(user.player.ConversationNPC!=null)user.player.ConversationNPC.bInConversation=false;
            user.player.ConversationNPC=null;
        }
        if(e.Name=="c150_notices")
        {
            for(int i=0;i<25;i++)
                CaelumNotifications.Inbox(user).Add(String.Format("%02d: %s",i,StringTable.Localize(i%2==0?"CA150_LONG_EN":"CA150_LONG_ES",false)),120*TICRATE);
        }
        if(e.Name=="c150_station")
        {
            let it=ThinkerIterator.Create("CaelumCraftingStation");CaelumCraftingStation station;
            while((station=CaelumCraftingStation(it.Next()))!=null)
                if(station.CraftingRoomGroup==5 && station.GetCraftingStationType()==CaelumConstants.CRAFTING_STATION_WORKBENCH)
                {
                    user.SetOrigin(station.Pos+(0,48,0),false);user.Vel=(0,0,0);
                    station.CollectCraftingNetwork(user,user.BeginCraftingNetworkScan());
                    user.OpenCraftingNetwork(station);break;
                }
        }
        if(e.Name=="c150_identity")
        {
            let profile=CaelumCharacterIdentity.Profile(user);
            profile.Race=e.Args[0];profile.Sex=e.Args[1];profile.SkinTone=e.Args[2];
            user.CharacterCreationComplete=true;user.ApplyCharacterProfile();
        }
        if(e.Name=="c150_mode")
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
    {if(!ok)Failures++;Console.Printf("CA150 %s %s",ok?"PASS":"FAIL",label);}
    override void ConsoleProcess(ConsoleEvent e)
    {
        let user=consoleplayer>=0?CaelumPlayer(players[consoleplayer].mo):null;
        if(e.Name=="c150_close")
        {CaelumLiveMenu.Journal().SetJournalOpen(false);while(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();}
        if(e.Name=="c150_journal")
        {CaelumLiveMenu.Journal().SetJournalOpen(true);CaelumLiveMenu.Journal().SetJournalPage(e.Args[0]);Menu.SetMenu("CaelumLiveMenu");}
        if(e.Name=="c150_creator")
        {Menu.SetMenu("CaelumNewCharacterMenu");CaelumCharacterCreationMenu(Menu.GetCurrentMenu()).Page=e.Args[0];}
        if(e.Name=="c150_options")Menu.SetMenu("CaelumComfortOptions");
        if(e.Name=="c150_intro")
        {Menu.SetMenu("CaelumIntroductionMenu");CaelumIntroductionMenu(Menu.GetCurrentMenu()).Revealed=true;}
        if(e.Name=="c150_history")Menu.SetMenu("CaelumNotificationMenu");
        if(e.Name=="c150_scale")
        {
            Vector2 hud=CaelumPresentation.HUDScale(), message=CaelumPresentation.MessageScale(), factors=CaelumPresentation.MenuFactors();
            Console.Printf("CA150 SCALE screen=%dx%d ui=%d journal=%.4f creator=%.4f hud=%.4f,%.4f message=%.4f,%.4f",Screen.GetWidth(),Screen.GetHeight(),CaelumPresentation.UIScale(),factors.X,CaelumPresentation.CreatorFactor(),hud.X,hud.Y,message.X,message.Y);
            Vector2 origin,size;[origin,size]=CaelumPresentation.MenuRect((0,0),(640,360));
            Check(origin.X>=-0.01 && origin.Y>=-0.01 && origin.X+size.X<=Screen.GetWidth()+0.01 && origin.Y+size.Y<=Screen.GetHeight()+0.01,"menu viewport bounds");
            Vector2 point=CaelumMenuPointer.JournalPoint(origin.X+size.X*0.8,origin.Y+size.Y*0.2);
            Check(Abs(point.X-512)<0.01 && Abs(point.Y-72)<0.01,"journal drawing/mouse inverse");
            Check(hud.X*640<=Screen.GetWidth()+0.01 && hud.Y*360<=Screen.GetHeight()+0.01,"HUD viewport bounds");
        }
        if(e.Name=="c150_crosshair")Check(CaelumPresentation.CrosshairVisible()==(e.Args[0]!=0),"contextual native crosshair gate");
        if(e.Name=="c150_historycheck")
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
        if(e.Name=="c150_pointer")
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
        if(e.Name=="c150_done")Console.Printf("CA150 DONE failures=%d",Failures);
        if(e.Name=="c150_remap")
        {
            let menu=CaelumLiveMenu(Menu.GetCurrentMenu());
            Check(CaelumNotificationMenu.Link().IndexOf("[L]")<0,"history hint omits conflicting contextual L");
            if(menu!=null)menu.Key(InputEvent.Type_KeyDown,CaelumMenuPointer.KeyScan(108),108,"l",true);
            Check(!CaelumLiveMenu.Journal().IsJournalOpen() && CaelumNotificationMenu(Menu.GetCurrentMenu())==null,"remapped L closes Journal before history shortcut");
        }
        if(e.Name=="c150_creatorclick")
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
        if(e.Name=="c150_identitycheck")
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
        if(e.Name=="c150_cardclick")
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
        if(e.Name=="c150_cardcheck")
        {
            let a=CaelumTrucoMatch(user.FindInventory("CaelumTrucoMatch"));let b=CaelumTrucazoMatch(user.FindInventory("CaelumTrucazoMatch"));
            Check(e.Args[0]==1?a!=null && a.HandNumber>0:b!=null && b.HandNumber>0,"scaled card click begins actual match");
            Check(menuactive==Menu.On,"card game keeps accepted native pause");
        }
    }
}
