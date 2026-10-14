// Cambios de etapa y visitas son preparación diagnóstica, no progreso del autor.
class CA235Targets : StaticEventHandler
{
    int Failures;
    void Check(bool ok,String label)
    {if(!ok)Failures++;Console.Printf("CA235 %s target-%s",ok?"PASS":"FAIL",label);}
    void Marker(CaelumPlayer user,int index,bool tracked)
    {
        String id="mansion-room-"..CaelumCartographyCatalogueData.MansionId(index);
        let record=user.GetPersistentCharacterState(false);
        let fact=CaelumPoiKnowledge.Find(record,level.MapName,id);
        let it=ThinkerIterator.Create("CaelumKnownPoiMarker");CaelumKnownPoiMarker marker,found;int count=0;
        while((marker=CaelumKnownPoiMarker(it.Next()))!=null)if(marker.PoiId==id){found=marker;count++;}
        if(fact==null){Check(count==0,id.."-unknown-absent");return;}
        Check(count==1 && found!=null && !found.bDormant,id.."-one-visible");
        if(found==null)return;
        String icon=tracked?"graphics/caelum/ui/hud/icons/ca_hud_combat_affected_targets.png"
            :CaelumPoiData.IconPath(fact.Category,fact.ObservedAccess);
        Check(found.picnum==TexMan.CheckForTexture(icon,TexMan.Type_Any),id..(tracked?"-objective-symbol":"-ordinary-symbol"));
        Check(found.Pos==fact.ObservedPosition,id.."-observed-position");
        Vector2 size=TexMan.GetScaledSize(found.picnum);
        double expected=tracked?CaelumPoiData.ICON_SIZE+CaelumCartographyLayout.PADDING:CaelumPoiData.ICON_SIZE;
        Check(abs(found.Scale.X*size.X-expected)<0.001,id.."-native-size");
    }
    void Learn(CaelumPlayer user,int index)
    {
        CaelumPoiKnowledge.Record(user,"mansion-room-"..CaelumCartographyCatalogueData.MansionId(index),
            CaelumPoiData.ROOM,CaelumCartographyCatalogueData.MansionName(index),
            CaelumCartographyCatalogueData.MansionPosition(index));
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        let r=u.GetPersistentCharacterState(false);if(r==null)return;
        if(e.Name=="t235_check")
        {
            Marker(u,8,e.Args[0]==1);Marker(u,7,e.Args[0]==2);
            Check(r.QuestTracked[4] && r.QuestTracked[5],"other-mission-selections-preserved");
        }
        if(e.Name=="t235_caella")r.QuestStage[0]=CaelumConstants.MAIN_M00_STATE_ARGENTO_COMPLETE;
        if(e.Name=="t235_argento")r.QuestStage[0]=CaelumConstants.MAIN_M00_STATE_ARGENTO_ACTIVE;
        if(e.Name=="t235_learn")Learn(u,7);
        if(e.Name=="t235_off")Check(CaelumQuestTracking.Set(u,0,false),"untrack");
        if(e.Name=="t235_on")Check(CaelumQuestTracking.Set(u,0,true),"track");
        if(e.Name=="t235_finish")r.QuestState[0]=CaelumConstants.QUEST_STATE_COMPLETED;
        if(e.Name=="t235_both")
        {
            Learn(u,6);Learn(u,9);
            r.QuestStage[0]=CaelumConstants.MAIN_M00_STATE_CAELLA_COMPLETE;
        }
        if(e.Name=="t235_both_check"){Marker(u,6,true);Marker(u,9,true);Marker(u,8,false);Marker(u,7,false);}
        if(e.Name=="t235_other_map")
        {
            let it=ThinkerIterator.Create("CaelumKnownPoiMarker");CaelumKnownPoiMarker marker;int visible=0;
            while((marker=CaelumKnownPoiMarker(it.Next()))!=null)if(!marker.bDormant)visible++;
            Check(level.MapName=="MAP04" && visible==0,"foreign-map-has-no-local-objective-marker");
            Check(r.QuestTracked[0] && r.QuestTracked[4] && r.QuestTracked[5],"hub-keeps-three-choices");
        }
        if(e.Name=="t235_done")Console.Printf("CA235 DONE failures=%d",Failures);
        if(e.Name.Left(5)=="t235_")u.RefreshSocialJournalSnapshot();
    }
}
