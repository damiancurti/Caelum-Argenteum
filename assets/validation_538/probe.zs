// Casos aislados: preparan etapas conocidas, sin certificar recorrido del autor.
class CA235Probe : StaticEventHandler
{
    int Failures;
    CaelumKnownPoi NegativeFact;
    ui int UIFailures;
    void Check(bool value,String name)
    {if(!value)Failures++;Console.Printf("CA235 %s %s",value?"PASS":"FAIL",name);}
    ui void UICheck(bool value,String name)
    {if(!value)UIFailures++;Console.Printf("CA235 %s %s",value?"PASS":"FAIL",name);}
    override void ConsoleProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[consoleplayer].mo);if(u==null)return;
        let r=CaelumPersistentCharacterState(u.FindInventory("CaelumPersistentCharacterState"));
        let journal=CaelumLiveMenu.Journal();
        if(e.Name=="c235_done")Console.Printf("CA235 DONE failures=%d",Failures+UIFailures);
        if(e.Name=="c235_open")
        {
            while(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();
            journal.SetJournalOpen(true);journal.SetJournalPage(4);
            CaelumScheduleCalendar.Set("ca_journal_quest_selected",0);
        }
        if(e.Name=="c235_key")
        {
            let menu=CaelumLiveMenu(Menu.GetCurrentMenu());
            UICheck(menu!=null && menu.Context==5,"native-live-journal-owned");
            if(menu!=null)
            {
                menu.Key(InputEvent.Type_KeyDown,0,116,"t");
                menu.Key(InputEvent.Type_KeyDown,0,116,"t");
                menu.Key(InputEvent.Type_KeyUp,0,0,"");
            }
        }
        if(e.Name=="c235_click")
        {
            let menu=CaelumLiveMenu(Menu.GetCurrentMenu());
            UICheck(menu!=null,"click-has-native-menu");
            if(menu!=null){menu.Controls.Layout(menu,false);menu.Controls.Activate(menu,6);}
        }
        if(e.Name=="c235_detail")journal.SetQuestDetailOpen(true);
        if(e.Name=="c235_hide"){journal.SetJournalOpen(false);while(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();}
        if(e.Name=="c235_ui")
        {
            UICheck(CaelumQuestTrackingView.Objective(u,9)=="","unknown-clue-text-absent");
            UICheck(CaelumQuestTrackingView.Location(u,0).IndexOf(StringTable.Localize("CA_POI_BEDROOM_ARGENTO",false))>=0,"known-room-name-linked");
            UICheck(CaelumQuestTrackingView.Location(u,0).IndexOf(StringTable.Localize("CA_POI_BEDROOM_CAELLA",false))<0,"future-room-name-absent");
            UICheck(CaelumQuestTrackingView.Objective(u,0)==StringTable.Localize("CA_Q_DETAIL_M01_ARGENTO",false),"shared-authored-current-stage-text");
            Array<String> rows;CaelumQuestTrackingView.MapRows(u,journal.SmallFont,360,20,rows);
            UICheck(rows.Size()==6,"three-missions-simultaneously-displayed");
            rows.Clear();CaelumQuestTrackingView.MapRows(u,journal.SmallFont,120,2,rows);
            UICheck(rows.Size()==1,"small-budget-keeps-overflow-count");
            rows.Clear();CaelumQuestTrackingView.MapRows(u,journal.SmallFont,120,5,rows);
            UICheck(rows.Size()==5,"odd-budget-reserves-overflow-row");
            for(int i=0;i<rows.Size();i++)UICheck(journal.SmallFont.StringWidth(rows[i])<=120,"long-text-fits-native-width");
            UICheck(!CaelumQuestTrackingView.Targets(u,0,NegativeFact),"secret-never-becomes-target");
            UICheck(!CaelumQuestTrackingView.Targets(u,-1,NegativeFact),"invalid-target-id-rejected");
            UICheck(CaelumQuestTrackingView.Location(u,4).IndexOf(StringTable.Localize("CA_TRACK_OTHER_MAP",false))>=0,"known-offmap-is-text-only");
            UICheck(CaelumQuestTrackingView.Location(u,4).IndexOf(StringTable.Localize("CA_TRACK_POSITION_UNKNOWN",false))>=0,"sewer-no-invented-boss-position");
        }
        if(e.Name=="c235_unknown_ui")
        {
            UICheck(CaelumQuestTrackingView.Location(u,0).IndexOf(StringTable.Localize("CA_TRACK_POSITION_UNKNOWN",false))>=0,"active-quest-does-not-reveal-precise-location");
            Array<String> rows;CaelumQuestTrackingView.MapRows(u,journal.SmallFont,300,20,rows);
            UICheck(rows.Size()==0,"no-automatic-tracking");
        }
        if(e.Name=="c235_terminal_ui")
        {
            Array<String> rows;CaelumQuestTrackingView.MapRows(u,journal.SmallFont,400,20,rows);
            UICheck(rows.Size()==0,"terminal-missions-leave-map");
            UICheck(journal.GetQuestDetailText(u,5).IndexOf(StringTable.Localize("CA_Q_RESCUE_UNPAID",false))>=0,"extracted-rescue-still-awaits-payment");
            UICheck(journal.GetQuestDetailText(u,9)==StringTable.Localize("CA_Q_GUARD_CAPTAIN_DETAIL",false),"captain-clue-preserved");
            UICheck(CaelumQuestCatalogue.Matches(0,u.JournalQuestState[0],1,2),"main-completed-filter-preserved");
            UICheck(CaelumQuestCatalogue.Matches(6,u.JournalQuestState[6],2,3),"failed-side-other-filter-preserved");
        }
        if(e.Name=="c235_port_ui")
        {
            UICheck(CaelumQuestTrackingView.Objective(u,3)==StringTable.Localize("CA_DEMO_PORT_ACTIVE",false),"port-objective-uses-existing-text");
            UICheck(CaelumQuestTrackingView.Location(u,3).IndexOf(StringTable.Localize("CA_TRACK_POSITION_UNKNOWN",false))>=0,"siege-does-not-reveal-enemies-or-gates");
        }
        if(e.Name=="c235_map_check")
        {
            Console.Printf("CA235 MAPSTATE active=%d menu=%d visible=%d time=%d",automapactive,menuactive,CaelumCartography.Visible(u),level.time);
            UICheck(automapactive && CaelumCartography.Visible(u),"native-map-header-visible-before-capture");
        }
        if(e.Name=="c235_navigation")
        {
            let menu=CaelumLiveMenu(Menu.GetCurrentMenu());
            if(menu!=null)
            {
                menu.Controls.Layout(menu,false);
                menu.Controls.Activate(menu,4003);menu.Controls.Activate(menu,4002);
                UICheck(journal.QuestFilter("ca_journal_quest_kind",2)==1 && journal.QuestFilter("ca_journal_quest_status",3)==1,"both-native-filter-headings-clickable");
                journal.SetQuestDetailOpen(true);menu.Stroke(InputEvent.Key_Tab);
                UICheck(journal.IsJournalOpen() && !journal.IsQuestDetailOpen(),"native-back-detail-to-list");
                menu.Stroke(InputEvent.Key_Tab);UICheck(!journal.IsJournalOpen(),"native-back-list-to-world");
                CaelumScheduleCalendar.Set("ca_journal_quest_kind",0);CaelumScheduleCalendar.Set("ca_journal_quest_status",0);
            }
            else UICheck(false,"navigation-native-menu-present");
        }
        if(e.Name=="c235_remap_click")
        {
            let menu=CaelumLiveMenu(Menu.GetCurrentMenu());
            UICheck(CaelumInputHints.Context(StringTable.Localize("CA_TRACK_STOP",false),0,116).IndexOf(StringTable.Localize("CA_HINT_MOUSE",false))>=0,"reserved-tracking-key-shows-mouse-hint");
            if(menu!=null){menu.Controls.Layout(menu,false);menu.Controls.Activate(menu,6);}
            else UICheck(false,"remap-native-menu-present");
        }
        if(e.Name=="c235_remap_close")
        {
            let menu=CaelumLiveMenu(Menu.GetCurrentMenu());Array<int> keys;
            Bindings.GetAllKeysForCommand(keys,"ca_journal_toggle");
            if(menu!=null && keys.Size()>0)menu.Key(InputEvent.Type_KeyDown,keys[0],116,"t",true);
            UICheck(!journal.IsJournalOpen(),"physical-remapped-journal-key-keeps-priority");
        }
        if(e.Name=="c235_sewer_ui")
        {
            UICheck(CaelumQuestTrackingView.Location(u,4).IndexOf(StringTable.Localize("CA_TRACK_LOCAL",false))>=0,"sewer-objective-local-on-sewer-map");
            UICheck(CaelumQuestTrackingView.Location(u,0).IndexOf(StringTable.Localize("CA_TRACK_OTHER_MAP",false))>=0,"mansion-objective-offmap-after-travel");
        }
        if(e.Name=="c235_stage_ui")
        {
            int stage=u.JournalQuestStage[0];
            if(stage==CaelumConstants.MAIN_M00_STATE_RONNIE_ACTIVE)
            {
                UICheck(CaelumQuestTrackingView.Objective(u,0)==StringTable.Localize("CA_M01_DETAIL_GATHER",false),"stage-change-updates-objective-without-retracking");
                UICheck(u.JournalQuestObjectiveKnown[3] && u.JournalQuestObjectiveKnown[4] && !u.JournalQuestObjectiveKnown[6],"future-fool-objective-filtered-from-diagnostic-known-flags");
            }
            if(stage==CaelumConstants.MAIN_M00_STATE_RULO_ACTIVE)
            {
                UICheck(CaelumQuestTrackingView.Location(u,0).IndexOf(StringTable.Localize("CA_POI_PRACTICE",false))>=0,"practice-objective-links-only-observed-room");
                UICheck(CaelumQuestTrackingView.Location(u,0).IndexOf(StringTable.Localize("CA_POI_BEDROOM_ARGENTO",false))<0,"previous-stage-destination-removed");
            }
            if(stage==CaelumConstants.MAIN_M00_STATE_BOX_RECEIVED)
            {
                UICheck(CaelumQuestTrackingView.Location(u,0).IndexOf(StringTable.Localize("CA_TRACK_POSITION_UNKNOWN",false))>=0,"fool-stage-does-not-create-secret-waypoint");
                UICheck(CaelumQuestTrackingView.Objective(u,0)==StringTable.Localize("CA_M01_FOOL_DETAIL_FIND",false),"unrevealed-fool-uses-existing-search-text");
            }
        }
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        let r=u.GetPersistentCharacterState(false);if(r==null)return;
        if(e.Name=="c235_start")
        {
            Check(!CaelumQuestTracking.Set(u,-1,true) && !CaelumQuestTracking.Set(u,32,true),"invalid-selection-rejected");
            Check(!CaelumQuestTracking.Set(u,0,true),"unstarted-main-cannot-track");
            Check(!u.JournalQuestObjectiveKnown[CaelumConstants.MAIN_M00_OBJECTIVE_GATHER_MATERIALS],"premature-lesson-progress-does-not-reveal-future-objective");
            Check(u.RecordMainM00PalomoMet(),"existing-palomo-guidance-starts-main");
            Check(!u.RecordMainM00PalomoMet(),"repeated-guidance-idempotent");
            r.WorldLocationVisited[1]=false;u.RefreshSocialJournalSnapshot();
        }
        if(e.Name=="c235_prepare")
        {
            NegativeFact=new("CaelumKnownPoi");NegativeFact.MapId="MAP01";NegativeFact.PoiId="secret-room";
            r.WorldLocationVisited[1]=r.WorldLocationVisited[2]=true;
            r.PrisonerRescueState[0]=CaelumConstants.PRISONER_STATE_FOLLOWING;
            u.RefreshSocialJournalSnapshot();
            u.SetOrigin((1000,-400,136),false);u.Vel=(0,0,0);
            if(level.MapName=="MAP01")CaelumWorldProgress.Update(u);
            else CaelumPoiKnowledge.Record(u,"mansion-room-bedroom-argento",CaelumPoiData.ROOM,"CA_POI_BEDROOM_ARGENTO",u.Pos);
            Check(r.QuestState[0]==CaelumConstants.QUEST_STATE_ACTIVE,"main-remains-active");
            Check(!r.QuestTracked[0] && !r.QuestTracked[4] && !r.QuestTracked[5],"migration-does-not-guess-tracking");
        }
        if(e.Name=="c235_track")
        {
            for(int q=0;q<CaelumConstants.QUEST_DEFINED_COUNT;q++)
                if(q==0 || q==4 || q==5)
                {Check(CaelumQuestTracking.Set(u,q,true),"track-active-quest");Check(CaelumQuestTracking.Set(u,q,true),"repeat-desired-state-idempotent");}
            Check(!CaelumQuestTracking.Set(u,9,true),"hidden-clue-cannot-track");
            Check(r.QuestTrackingRevision==1,"revision-one-initialized");
        }
        if(e.Name=="c235_check_off")Check(!r.QuestTracked[0] && r.QuestTracked[4] && r.QuestTracked[5],"native-key-toggles-only-selected-once");
        if(e.Name=="c235_check_on")Check(r.QuestTracked[0] && r.QuestTracked[4] && r.QuestTracked[5],"mouse-action-restores-independent-selection");
        if(e.Name=="c235_reload")
        {
            Check(r.QuestTracked[0] && r.QuestTracked[4] && r.QuestTracked[5],"three-tracked-choices-survive-load-or-hub");
            Check(r.QuestTrackingRevision==1,"tracking-revision-survives");
            Check(r.PrisonerRescueState[0]==CaelumConstants.PRISONER_STATE_FOLLOWING && !r.PrisonerRewardClaimed[0],"rescue-progress-and-payment-unchanged");
        }
        if(e.Name=="c235_migrate")
        {
            int count=0;for(int q=0;q<CaelumConstants.QUEST_CAPACITY;q++)if(r.QuestTracked[q])count++;
            Check(count==0,"genuine-537-save-starts-untracked");
            Check(r.QuestTrackingRevision==1,"genuine-save-revision-migrated");
            CaelumQuestTracking.Ensure(r);Check(r.QuestTrackingRevision==1,"migration-idempotent");
        }
        if(e.Name=="c235_terminal")
        {
            r.QuestState[0]=CaelumConstants.QUEST_STATE_COMPLETED;
            r.SewerZupayDefeated=true;
            r.PrisonerRescueState[0]=CaelumConstants.PRISONER_STATE_EXTRACTED;
            r.PrisonerRescueState[1]=CaelumConstants.PRISONER_STATE_DEAD;
            r.QuestState[9]=CaelumConstants.QUEST_STATE_COMPLETED;
            u.RefreshSocialJournalSnapshot();
            Check(!CaelumQuestTracking.Set(u,0,true) && !CaelumQuestTracking.Set(u,5,true),"finished-records-cannot-start-tracking");
            Check(!CaelumQuestTracking.Active(u,0) && !CaelumQuestTracking.Active(u,4) && !CaelumQuestTracking.Active(u,5),"terminal-selection-is-inactive");
            Check(CaelumQuestTracking.Set(u,0,false),"old-selection-can-be-cleared-in-history");
        }
        if(e.Name=="c235_port")
        {
            u.RefreshSocialJournalSnapshot();
            Check(u.JournalQuestState[3]==CaelumConstants.QUEST_STATE_ACTIVE,"real-registered-siege-is-active");
            Check(CaelumQuestTracking.Set(u,3,true),"existing-siege-can-track");
            Check(r.KnownPois.Size()==0,"tracking-siege-does-not-discover-content");
        }
        if(e.Name=="c235_deploy")
        {
            Check(CaelumQuestCatalogue.State(r,3)==CaelumConstants.QUEST_STATE_UNDISCOVERED,"quiet-city-does-not-reveal-future-siege-quest");
            let port=CaelumPortSiege.Get();Check(port!=null,"actual-city-controller-present");
            // Disparar el mismo despliegue del calendario en esta copia aislada.
            if(port!=null)port.Deploy(true);
        }
        if(e.Name=="c235_stage")
        {
            r.QuestStage[0]=e.Args[0];
            for(int i=0;i<CaelumConstants.QUEST_OBJECTIVE_CAPACITY;i++)r.QuestObjectiveKnown[i]=true;
            if(e.Args[0]==CaelumConstants.MAIN_M00_STATE_RULO_ACTIVE)
                CaelumPoiKnowledge.Record(u,"mansion-room-practice",CaelumPoiData.ROOM,"CA_POI_PRACTICE",CaelumCartographyCatalogueData.MansionPosition(4));
            u.RefreshSocialJournalSnapshot();
            Check(r.QuestTracked[0],"stage-change-retains-tracking-choice");
        }
        if(e.Name=="c235_trial_start")
        {
            CaelumSideQuestRules.EnableTrial(u);
            Check(!CaelumQuestTracking.Set(u,1,true),"offered-trial-cannot-track");
            Check(CaelumSideQuestRules.Activate(u,1),"existing-trial-starts-by-own-action");
            Check(CaelumQuestTracking.Set(u,1,true),"active-trial-can-track");
            Check(!CaelumSideQuestRules.ObjectivesComplete(r,1) && !r.QuestRewardClaimed[1],"tracking-neither-progresses-nor-pays");
            u.SetOrigin(r.QuestTrialOrigin+(128,0,0),false);
        }
        if(e.Name=="c235_trial_complete")
        {
            Check(CaelumSideQuestRules.ObjectivesComplete(r,1),"existing-movement-observer-progressed");
            Check(CaelumSideQuestRules.Activate(u,1),"own-action-completes-and-claims-once");
            Check(!CaelumQuestTracking.Active(u,1),"completed-trial-disappears-from-map");
            Check(!CaelumSideQuestRules.Activate(u,1),"repeated-own-action-does-not-pay-twice");
            Check(u.FindInventory("CaelumQuestRouteReceipt")!=null && r.QuestRewardClaimed[1],"single-native-receipt-preserved");
            Check(CaelumSideQuestRules.Activate(u,2),"prerequisite-allows-wait-trial");
            Check(CaelumQuestTracking.Set(u,2,true),"wait-trial-can-track");
            Check(CaelumSideQuestRules.End(r,2,true),"existing-abandon-action");
            u.RefreshSocialJournalSnapshot();
            Check(!CaelumQuestTracking.Active(u,2) && CaelumQuestCatalogue.Matches(2,u.JournalQuestState[2],2,3),"abandoned-trial-in-other-not-map");
        }
    }
}
