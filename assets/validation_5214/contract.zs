// Native menu descriptors and read-only binding/hint assertions.
class CA149Contract : StaticEventHandler
{
    ui int Failures;
    int SlotEvents;
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="c149_ready")
        {
            let user=CaelumPlayerAuthority.FromNetworkPlayer(e.Player);
            if(user.player.ConversationNPC!=null)user.player.ConversationNPC.bInConversation=false;
            user.player.ConversationNPC=null;
        }
        if(e.Name=="c149_station")
        {
            let user=CaelumPlayerAuthority.FromNetworkPlayer(e.Player);
            let it=ThinkerIterator.Create("CaelumCraftingStation");CaelumCraftingStation station;
            while((station=CaelumCraftingStation(it.Next()))!=null)
                if(station.CraftingRoomGroup==5 && station.GetCraftingStationType()==CaelumConstants.CRAFTING_STATION_WORKBENCH)
                {
                    user.SetOrigin(station.Pos+(0,48,0),false);user.Vel=(0,0,0);
                    station.CollectCraftingNetwork(user,user.BeginCraftingNetworkScan());
                    user.OpenCraftingNetwork(station);break;
                }
        }
        if(e.Name=="ca_cycle_weapon_slot_2")SlotEvents++;
        if(e.Name=="ca_skip_open")
        {
            let user=CaelumPlayerAuthority.FromNetworkPlayer(e.Player);
            Console.Printf("CA149 SKIP reason=%s",CaelumTimeSkipRules.BlockReason(user));
            Console.Printf("CA149 STATE combat=%d talk=%d sleep=%d merchant=%d channel=%d staff=%d charge=%d charged=%d reload=%d water=%d ground=%d vel=%f",user.CombatTimeRemaining,user.HasActiveConversation(),user.ForcedSleepTics,user.PalomoMerchantMenuOpen,user.CombatChannelModeActive,user.StaffCastPending,user.WeaponChargeActive,user.WeaponChargedStateActive,user.RangedReloadActive,user.WaterLevel,user.player.onground,user.Vel.Length());
        }
    }
    ui void Check(bool ok,String label)
    {if(!ok)Failures++;Console.Printf("CA149 %s %s",ok?"PASS":"FAIL",label);}
    ui int Count(String menu,String command)
    {
        let desc=OptionMenuDescriptor(MenuDescriptor.GetDescriptor(menu));int n=0;
        if(desc!=null)for(int i=0;i<desc.mItems.Size();i++)
            if(desc.mItems[i].GetAction()==Name(command))n++;
        return n;
    }
    override void ConsoleProcess(ConsoleEvent e)
    {
        if(e.Name=="c149_slots")Check(SlotEvents==e.Args[0],"slot command dispatches exactly one authoritative event");
        if(e.Name=="c149_journal")CaelumLiveMenu.Journal().ToggleJournal();
        if(e.Name=="c149_crafting")
        {CaelumLiveMenu.Journal().SetJournalOpen(true);CaelumLiveMenu.Journal().SetJournalPage(3);}
        if(e.Name=="c149_modal")
        {
            let view=CaelumLiveMenu.Journal();
            let user=CaelumPlayer(players[consoleplayer].mo);
            Check(CaelumJournalInput.SkipOpen(user),"skip open above Journal");
            view.PanelKey(InputEvent.Type_KeyDown,InputEvent.Key_Tab,9,"");
            Check(view.IsJournalOpen(),"Tab cancellation retains parent Journal");
        }
        if(e.Name=="c149_cancelled")
        {
            Check(!CaelumJournalInput.SkipOpen(CaelumPlayer(players[consoleplayer].mo)),"skip cancellation reaches authoritative state");
            Check(CaelumLiveMenu.Journal().IsJournalOpen(),"Journal still open after skip cancellation");
        }
        if(e.Name=="c149_buttons")
        {
            let view=CaelumLiveMenu.Journal();view.SetJournalPage(0);view.SetJournalOpen(true);
            Menu.SetMenu("CaelumLiveMenu");let menu=CaelumLiveMenu(Menu.GetCurrentMenu());
            menu.Stroke(InputEvent.Key_Enter);
            Check(view.IsJournalOpen(),"visual Use ignores Enter remapped to Journal");
            menu.Stroke(InputEvent.Key_Tab);
            Check(!view.IsJournalOpen(),"visual Back ignores Tab remapped to time skip");
            menu.Close();
        }
        if(e.Name=="c149_menus")
        {
            Console.Printf("CA149 PAD %s",KeyBindings.NameKeys(InputEvent.Key_Pad_Y,0));
            Check(Count("CaelumCombatControls","+attack")==1 && Count("ActionControlsMenu","+attack")==0,"combat grouped without duplicate native row");
            Check(Count("CaelumAbilityControls","+user2")==1 && Count("WeaponsControlMenu","+user2")==0,"abilities grouped with original commands");
            Check(Count("MapControlsMenu","togglemap")==1 && Count("OtherControlsMenu","togglemap")==0,"automap access in native map group");
            Check(Count("InventoryControlsMenu","ca_time_skip")==1 && Count("InventoryControlsMenu","ca_journal_toggle")==1,"journal and time grouped");
            Check(Count("CustomizeControls","ca_controls_reset")==1 && Count("CustomizeControls","resetb2defaults")==0,"explicit reset keeps native confirmation with Caelum preset");
            Check(Count("OtherControlsMenu","menu_save")==1 && Count("OtherControlsMenu","menu_load")==1,"native save/load shortcuts retained");
            Check(MenuDescriptor.GetDescriptor("SaveGameMenu").mClass=="SaveMenu" && MenuDescriptor.GetDescriptor("LoadGameMenu").mClass=="LoadMenu","native save/load classes retained");
        }
        if(e.Name=="c149_hints")
        {
            Array<int> keys;Bindings.GetAllKeysForCommand(keys,"+use");
            Check(keys.Size()==e.Args[0],"actual binding count");
            String result=CaelumInputHints.Keys("+use");
            Check(result==(keys.Size()==0?StringTable.Localize("CA_INTRO_UNBOUND",false):KeyBindings.NameAllKeys(keys)),"hint uses all native bindings or localized unbound");
            Check(CaelumInputHints.Resolve("{bind:+use}")==result,"late UI token resolution");
            Check(CaelumInputHints.Resolve(StringTable.Localize("CA_M01_RULO_LESSON",false)).IndexOf("{bind:")<0,"tutorial attack hints resolve");
            Check(CaelumInputHints.Resolve(StringTable.Localize("CA_TAROT_POWER_RULE",false)).IndexOf("{bind:")<0,"Tarot hint resolves before numeric formatting");
            Check(CaelumInputHints.Resolve(StringTable.Localize("CA_MAZE_USE_CHEST",false)).IndexOf(result)>=0,"interaction hint uses current Use binding");
            Console.Printf("CA149 HINT %s",result);
        }
        if(e.Name=="c149_preset")
        {
            Check(CaelumInputHints.Matches(CaelumMenuPointer.KeyScan(109),"togglemap"),"M opens automap");
            Check(AutomapBindings.GetBinding(CaelumMenuPointer.KeyScan(109))=="","native mark does not consume M in full automap");
            Check(CaelumInputHints.Matches(InputEvent.Key_Tab,"ca_journal_toggle"),"Tab opens Journal");
            Check(CaelumInputHints.Matches(CaelumMenuPointer.KeyScan(116),"+user3"),"T activates Tarot");
            Check(CaelumInputHints.Matches(CaelumMenuPointer.KeyScan(98),"+user2") && CaelumInputHints.Matches(CaelumMenuPointer.KeyScan(114),"+reload")
                && CaelumInputHints.Matches(CaelumMenuPointer.KeyScan(102),"+zoom") && CaelumInputHints.Matches(CaelumMenuPointer.KeyScan(121),"ca_time_skip"),"B/R/F/Y accepted defaults");
            Check(CVar.GetCVar("snd_mastervolume").GetFloat()<0.051 && CVar.GetCVar("cl_run").GetBool(),"control reset preserves unrelated preferences");
        }
        if(e.Name=="c149_focus")
        {
            let view=CaelumLiveMenu.Journal();
            view.SetJournalOpen(true);
            Menu.SetMenu("CaelumLiveMenu");
            let menu=CaelumLiveMenu(Menu.GetCurrentMenu());
            Check(menu!=null && menu.Context==1,"native live Journal owns inventory focus");
            if(menu!=null)
            {
                Check(CaelumMenuPointer.KeyScan(UIEvent.Key_F5)==InputEvent.Key_F5,"function key maps to native scan");
                menu.Key(InputEvent.Type_KeyDown,InputEvent.Key_F5,0,"");
                Check(!view.IsJournalOpen(),"remapped F5 closes Journal");
                menu.Close();
                view.SetJournalOpen(true);Menu.SetMenu("CaelumLiveMenu");
                menu=CaelumLiveMenu(Menu.GetCurrentMenu());
                menu.Key(InputEvent.Type_KeyDown,InputEvent.Key_Mouse3,0,"");
                Check(!view.IsJournalOpen(),"remapped middle mouse closes Journal through contextual handler");
                menu.Close();
                view.SetJournalOpen(true);Menu.SetMenu("CaelumLiveMenu");
                menu=CaelumLiveMenu(Menu.GetCurrentMenu());
                menu.Key(InputEvent.Type_KeyDown,InputEvent.Key_Pad_Y,0,"");
                Check(!view.IsJournalOpen(),"remapped native Pad button closes Journal through contextual handler");
                menu.Close();
            }
        }
        if(e.Name=="c149_preserved")
        {
            Check(CaelumInputHints.Matches(CaelumMenuPointer.KeyScan(106),"ca_journal_toggle"),"custom Journal key survives restart/load");
            Check(CaelumInputHints.Matches(CaelumMenuPointer.KeyScan(113),"+attack"),"custom attack key survives restart/load");
            Check(CaelumInputHints.Matches(InputEvent.Key_F5,"ca_time_skip"),"custom time key survives restart/load");
            Check(CaelumInputHints.Keys("+use")==StringTable.Localize("CA_INTRO_UNBOUND",false),"cleared Use remains cleared after restart/load");
            Check(AutomapBindings.GetBinding(CaelumMenuPointer.KeyScan(110))=="am_setmark","custom automap binding survives restart/load");
        }
        if(e.Name=="c149_open")Menu.SetMenu(e.Args[0]==0?"CustomizeControls":e.Args[0]==1?"CaelumCombatControls":e.Args[0]==2?"CaelumAbilityControls":"InventoryControlsMenu");
        if(e.Name=="c149_intro")
        {
            Menu.SetMenu("CaelumIntroductionMenu");
            let intro=CaelumIntroductionMenu(Menu.GetCurrentMenu());
            intro.Revealed=true;intro.VisibleCharacters=100000;
        }
        if(e.Name=="c149_close")while(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();
        if(e.Name=="c149_done")Console.Printf("CA149 DONE failures=%d",Failures);
    }
}
