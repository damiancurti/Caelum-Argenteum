// Pruebas aisladas por eventos y handlers nativos; no simulan aceptación humana.
class CA236Probe : StaticEventHandler
{
    int Failures;
    ui int UIFailures, SavedFilter, SavedSelection, SavedPage;
    int FoodBefore, WaterBefore, SequenceBefore;
    double SleepBefore, HungerBefore, ThirstBefore;
    ui Vector2 SavedCenter;
    void Check(bool ok,String name){if(!ok)Failures++;Console.Printf("CA236 %s %s",ok?"PASS":"FAIL",name);}
    ui void UICheck(bool ok,String name){if(!ok)UIFailures++;Console.Printf("CA236 %s %s",ok?"PASS":"FAIL",name);}
    ui void Select(Name requested)
    {
        let nav=CaelumNavigationMenu(Menu.GetCurrentMenu());UICheck(nav!=null,"native-navigation-menu");
        if(nav==null)return;
        let item=nav.GetItem(requested);UICheck(item!=null,"native-command-item");
    }
    override void ConsoleProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[consoleplayer].mo);if(u==null)return;
        let view=CaelumLiveMenu.Journal();
        if(e.Name=="c236_close"){CaelumExplorationNavigation.CloseMenus();view.SetJournalOpen(false);}
        if(e.Name=="c236_done")Console.Printf("CA236 DONE failures=%d",Failures+UIFailures);
        if(e.Name=="c236_save_selection")
        {SavedFilter=u.FormalInventoryFilter;SavedSelection=u.FormalInventorySelectionIndex;SavedPage=view.GetJournalPage();}
        if(e.Name=="c236_selection")
        {UICheck(SavedFilter==u.FormalInventoryFilter && SavedSelection==u.FormalInventorySelectionIndex,"inventory-filter-selection-preserved");}
        if(e.Name=="c236_explore")
        {
            let menu=CaelumLiveMenu(Menu.GetCurrentMenu());UICheck(menu!=null,"journal-native-owner");
            if(menu!=null){menu.Controls.Layout(menu,false);menu.Controls.Activate(menu,9001);}
        }
        if(e.Name=="c236_world")Select('ca_world_open');
        if(e.Name=="c236_inventory")Select('ca_inventory_open');
        if(e.Name=="c236_keys")Select('ca_keys_open');
        if(e.Name=="c236_notes")Select('ca_nav_notes');
        if(e.Name=="c236_local")Select(automapactive?'ca_nav_local':'event ca_nav_local; togglemap');
        if(e.Name=="c236_check_world")
        {UICheck(view.IsJournalOpen() && view.GetJournalPage()==2 && CaelumLiveMenu(Menu.GetCurrentMenu())!=null,"world-journal-destination");UICheck(menuactive==Menu.OnNoPause,"world-live-policy");}
        if(e.Name=="c236_check_inventory")UICheck(view.GetJournalPage()==0 && view.IsJournalOpen(),"inventory-destination");
        if(e.Name=="c236_check_missions")UICheck(view.GetJournalPage()==4 && view.IsJournalOpen(),"native-mission-popup-adapted");
        if(e.Name=="c236_check_character")UICheck(view.GetJournalPage()==1 && view.IsJournalOpen(),"native-status-popup-adapted");
        if(e.Name=="c236_documents")
        {
            let docs=CaelumOwnedDocumentsMenu(Menu.GetCurrentMenu());UICheck(docs!=null,"native-keys-popup-adapted");
            if(docs!=null)
            {
                Array<String> text;docs.CollectText(text);int count=0;
                for(Inventory item=u.Inv;item!=null;item=item.Inv)
                    if(item.Owner==u && item.Amount>0 && docs.Includes(item))count++;
                UICheck(text.Size()==(count==0?1:count*3),"projection-matches-actual-owned-count");
                UICheck(!docs.Includes(u.FindInventory("CaelumPersistentCharacterState")),"record-is-not-a-document");
                UICheck(menuactive==Menu.OnNoPause,"document-view-live");
                docs.MenuEvent(Menu.MKEY_PageDown,false);docs.MenuEvent(Menu.MKEY_PageUp,false);
                UICheck(docs.Offset==0,"native-document-scroll-return");
            }
        }
        if(e.Name=="c236_back")
        {let menu=Menu.GetCurrentMenu();if(menu!=null)menu.MenuEvent(Menu.MKEY_Back,false);}
        if(e.Name=="c236_check_navigation")UICheck(CaelumNavigationMenu(Menu.GetCurrentMenu())!=null && menuactive==Menu.OnNoPause,"back-to-live-navigation");
        if(e.Name=="c236_check_map")UICheck(automapactive && menuactive==Menu.Off && !view.IsJournalOpen(),"local-native-map-no-menu-owner");
        if(e.Name=="c236_capture_center"){SavedCenter=level.GetAutomapPosition();}
        if(e.Name=="c236_same_center")UICheck(SavedCenter==level.GetAutomapPosition(),"native-center-retained");
        if(e.Name=="c236_check_notes")
        {let notes=CaelumMapNoteMenu(Menu.GetCurrentMenu());UICheck(notes!=null && notes.CanPlace,"notes-capture-existing-native-map-center");}
        if(e.Name=="c236_pause")
        {
            let menu=CaelumLiveMenu(Menu.GetCurrentMenu());if(menu!=null)menu.Stroke(InputEvent.Key_Escape);
            UICheck(menuactive==Menu.On,"native-pause-over-journal");Menu.SetMenu("OptionsMenu");
        }
        if(e.Name=="c236_options")
        {UICheck(menuactive==Menu.On && Menu.GetCurrentMenu()!=null,"nested-native-options-paused");Menu.GetCurrentMenu().MenuEvent(Menu.MKEY_Back,false);}
        if(e.Name=="c236_pause_back")
        {Menu.GetCurrentMenu().MenuEvent(Menu.MKEY_Back,false);UICheck(CaelumLiveMenu(Menu.GetCurrentMenu())!=null,"pause-returns-original-journal");}
        if(e.Name=="c236_remap")
        {
            let menu=CaelumLiveMenu(Menu.GetCurrentMenu());
            UICheck(CaelumInputHints.Context(StringTable.Localize("CA_NAV_TITLE",false),0,110).IndexOf(StringTable.Localize("CA_HINT_MOUSE",false))>=0,"reserved-N-hint-points-to-click");
            if(menu!=null)menu.Key(InputEvent.Type_KeyDown,CaelumMenuPointer.KeyScan(110),110,"n",true);
            UICheck(!view.IsJournalOpen(),"remapped-journal-N-precedes-navigation");
        }
        if(e.Name=="c236_unbound")
        {UICheck(CaelumInputHints.Keys("ca_exploration")==StringTable.Localize("CA_INTRO_UNBOUND",false),"unbound-navigation-hint");}
        if(e.Name=="c236_shortcut")
        {
            let menu=CaelumLiveMenu(Menu.GetCurrentMenu());UICheck(menu!=null,"direct-shortcut-native-owner");
            if(menu!=null)
            {
                UICheck(menu.Key(InputEvent.Type_KeyDown,InputEvent.Key_F7,0,"",true),"direct-remapped-shortcut-consumed");
                UICheck(view.GetJournalPage()==2,"direct-remapped-world-destination");
            }
        }
        if(e.Name=="c236_empty")
        {
            let docs=CaelumOwnedDocumentsMenu(Menu.GetCurrentMenu());Array<String> text;
            if(docs!=null)docs.CollectText(text);
            UICheck(text.Size()==1 && text[0]==StringTable.Localize("CA_NAV_NO_DOCUMENTS",false),"consumed-documents-not-owned");
        }
        if(e.Name=="c236_cancel_travel")
        {
            let menu=CaelumLiveMenu(Menu.GetCurrentMenu());
            UICheck(menu!=null && menu.Context==CaelumLiveMenu.CTX_JOURNEY,"original-travel-confirmation-menu");
            UICheck(!CaelumExplorationNavigation.Available(),"navigation-cannot-bypass-travel-modal");
            if(menu!=null)menu.Stroke(InputEvent.Key_Tab);
        }
        if(e.Name=="c236_confirm_travel")
        {
            let menu=CaelumLiveMenu(Menu.GetCurrentMenu());
            UICheck(menu!=null && menu.Context==CaelumLiveMenu.CTX_JOURNEY,"confirmed-original-service-menu");
            if(menu!=null)menu.Stroke(InputEvent.Key_Enter);
        }
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=="c236_seed")
        {
            u.GiveInventoryType("CaelumSilverKey");u.GiveInventoryType("CaelumSealedLetter");u.GiveInventoryType("CaelumProcessingManual");
            let letter=CaelumSpecialInventoryItem(u.FindInventory("CaelumSealedLetter"));if(letter!=null)letter.InMagicBox=true;
            u.RefreshFormalInventorySnapshot();
            Check(u.FindInventory("CaelumSealedLetter")!=null,"fixture-owned-letter");
        }
        if(e.Name=="c236_setup")
        {
            if(u.player.ConversationNPC!=null)u.player.ConversationNPC.bInConversation=false;
            u.player.ConversationNPC=null;u.player.ConversationPC=null;
            u.CreationWizardOpen=false;u.CharacterCreationComplete=true;u.ApplyCharacterProfile();
            let r=u.GetPersistentCharacterState(true);r.ProfileCommitted=true;
            r.DemoNarrativeDelivered=2047;r.DemoNarrativePending=0;u.RecordMainM00UnknownVoiceHeard();
            u.CurrentSleep=50;u.CurrentHunger=u.CurrentThirst=80;u.CombatTimeRemaining=0;u.PersistCharacterState();
        }
        if(e.Name=="c236_remove_documents")
        {
            for(Inventory item=u.Inv;item!=null;)
            {
                Inventory next=item.Inv;
                if(item is "CaelumWeightedKey" || item is "CaelumSealedLetter" || item is "CaelumProcessingManual")item.Destroy();
                item=next;
            }
            u.RefreshFormalInventorySnapshot();
        }
        if(e.Name=="c236_preview")
        {
            let j=CaelumJourneyState.Get(u);SequenceBefore=j==null?0:j.Sequence;
            SleepBefore=u.CurrentSleep;HungerBefore=u.CurrentHunger;ThirstBefore=u.CurrentThirst;
            Check(CaelumTravelService.Begin(u,CaelumWorldCatalogue.CONNECTION_TO_PORT,CaelumJourneyState.MODE_FOOT),"existing-measured-route-preview");
            Check(u.CurrentSleep==SleepBefore && u.CurrentHunger==HungerBefore && u.CurrentThirst==ThirstBefore,"preview-no-immediate-resource-charge");
        }
        if(e.Name=="c236_cancelled")
        {
            let plan=CaelumJourneyPlan.Get(u);let j=CaelumJourneyState.Get(u);
            Check(plan!=null && !plan.Open,"native-cancel-closes-plan");
            Check((j==null?0:j.Sequence)==SequenceBefore,"cancel-does-not-record-journey");
            Check(u.GetPersistentCharacterState(false).WorldPendingConnection==0,"cancel-no-pending-route");
        }
        if(e.Name=="c236_arrival")
        {
            let j=CaelumJourneyState.Get(u);let r=u.GetPersistentCharacterState(false);
            Check(level.MapName=="MAP06" && j!=null && j.Sequence==SequenceBefore+1,"confirmed-original-route-arrives-once");
            Check(r.WorldLocationVisited[CaelumWorldCatalogue.LOCATION_PORT] && r.WorldConnectionTraversed[CaelumWorldCatalogue.CONNECTION_TO_PORT],"confirmed-route-records-actual-arrival");
        }
        if(e.Name=="c236_no_travel")
        {
            let r=u.GetPersistentCharacterState(false);let plan=CaelumJourneyPlan(u.FindInventory("CaelumJourneyPlan"));
            Check(r!=null && r.WorldPendingConnection==0,"browsing-no-pending-world-trip");
            Check(plan==null || !plan.Open,"browsing-no-travel-confirmation");
        }
    }
}
