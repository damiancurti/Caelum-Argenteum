// Pruebas aisladas de autoridad y presentación; nunca se empaquetan en src.
class CA232Probe : StaticEventHandler
{
    int Failures;
    ui int UIFailures;
    Actor Sources[5];
    void Check(bool ok,String label)
    {if(!ok)Failures++;Console.Printf("CA232 %s %s",ok?"PASS":"FAIL",label);}
    ui void UICheck(bool ok,String label)
    {if(!ok)UIFailures++;Console.Printf("CA232 %s %s",ok?"PASS":"FAIL",label);}
    static int MarkerCount()
    {
        int count=0;let it=ThinkerIterator.Create("CaelumKnownPoiMarker");CaelumKnownPoiMarker mark;
        while((mark=CaelumKnownPoiMarker(it.Next()))!=null)if(!mark.bDormant)count++;
        return count;
    }
    override void ConsoleProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[consoleplayer].mo);if(u==null)return;
        let r=CaelumPersistentCharacterState(u.FindInventory("CaelumPersistentCharacterState"));if(r==null)return;
        if(e.Name=="c232_ui")
        {
            int count=r.KnownPois.Size(),serial=r.LocalKnowledgeSerial;
            let near=CaelumPoiView.Nearest(u,u.Pos.XY);
            UICheck(near!=null && near.PoiId=="fixture-1","read-only-nearest-known-name");
            UICheck(CaelumPoiView.Name(near).IndexOf(StringTable.Localize("CA_POI_BED",false))==0,"localized-category-name");
            UICheck(CaelumPoiKnowledge.Find(r,level.MapName,"upper-hidden")==null,"same-xy-upper-floor-unknown");
            UICheck(CaelumPoiKnowledge.Find(r,level.MapName,"hidden-room")==null,"hidden-room-still-unknown");
            UICheck(r.KnownPois.Size()==count && r.LocalKnowledgeSerial==serial,"UI-cannot-grant-knowledge");
            Console.Printf("CA232 UI DONE failures=%d",UIFailures);
        }
        if(e.Name=="c232_close")while(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        let r=u.GetPersistentCharacterState(false);if(r==null)return;
        if(e.Name=="c232_core")
        {
            Check(r.LocalKnowledgeRevision==1 && r.KnownPois.Size()==0,"fresh-character-no-inferred-POIs");
            CaelumPoiKnowledge.Ensure(r);CaelumPoiKnowledge.Ensure(r);
            Check(r.KnownPois.Size()==0,"migration-is-idempotent-empty");
            for(int i=0;i<5;i++)
            {
                Sources[i]=Actor.Spawn("MapSpot",u.Pos+(i*96,128,0),NO_REPLACE);
                String id=String.Format("fixture-%d",i+1);
                let entry=CaelumPoiRegistration.Bind(Sources[i],id,i+1,CaelumPoiData.CategoryKey(i+1));
                Check(entry!=null,"category-registration-"..id);
                Check(CaelumPoiRegistration.Bind(Sources[i],id,i+1,CaelumPoiData.CategoryKey(i+1))==entry,"duplicate-binding-idempotent-"..id);
            }
            let hidden=Actor.Spawn("MapSpot",Sources[0].Pos+(0,0,256),NO_REPLACE);
            CaelumPoiRegistration.Bind(hidden,"upper-hidden",CaelumPoiData.BED,"CA_POI_BED");
            let secret=Actor.Spawn("MapSpot",u.Pos+(-512,-512,0),NO_REPLACE);
            CaelumPoiRegistration.Bind(secret,"hidden-room",CaelumPoiData.STATION,"CA_POI_STATION");
            Check(r.KnownPois.Size()==0 && MarkerCount()==0,"registration-sight-and-map-visits-grant-nothing");
            Check(CaelumPoiRegistration.Bind(hidden,"fixture-1",1,"CA_POI_BED")==null,"conflicting-ID-rejected");
            Check(!CaelumPoiKnowledge.RecordUse(u,secret,CaelumPoiData.BED),"wrong-category-rejected");
            Check(CaelumPoiRegistration.Bind(secret,"invalid",99,"CA_POI_BED")==null,"invalid-category-rejected");
            int priorQuest=r.QuestState[0],priorStage=r.QuestStage[0],priorPending=r.WorldPendingConnection;
            for(int i=0;i<5;i++)
            {
                Check(CaelumPoiKnowledge.RecordUse(u,Sources[i],i+1),String.Format("known-category-%d",i+1));
                CaelumPoiKnowledge.RecordUse(u,Sources[i],i+1);
            }
            Check(r.KnownPois.Size()==5,"repeat-events-no-duplicates");
            Check(r.QuestState[0]==priorQuest && r.QuestStage[0]==priorStage && r.WorldPendingConnection==priorPending,"no-unrelated-progression");
            let other=CaelumPersistentCharacterState(Actor.Spawn("CaelumPersistentCharacterState",u.Pos,NO_REPLACE));
            CaelumPoiKnowledge.Ensure(other);
            Check(other.KnownPois.Size()==0 && CaelumPoiKnowledge.Find(other,level.MapName,"fixture-1")==null,"separate-record-has-no-other-character-knowledge");
            other.Destroy();
            Vector3 observed=r.KnownPois[0].ObservedPosition;
            Sources[0].SetOrigin(Sources[0].Pos+(32,0,0),false);
            Check(r.KnownPois[0].ObservedPosition==observed,"hidden-source-movement-not-tracked");
            CaelumPoiKnowledge.RecordUse(u,Sources[0],1);
            Check(r.KnownPois[0].ObservedPosition==Sources[0].Pos,"reuse-updates-observed-position");
            Sources[0].SetOrigin(observed,false);CaelumPoiKnowledge.RecordUse(u,Sources[0],1);
            Sources[1].Destroy();
            Check(CaelumPoiKnowledge.Find(r,level.MapName,"fixture-2")!=null,"destroyed-source-retains-last-known-fact");
            Sources[1]=Actor.Spawn("MapSpot",r.KnownPois[1].ObservedPosition,NO_REPLACE);
            Check(CaelumPoiRegistration.Bind(Sources[1],"fixture-2",2,"CA_POI_STATION")!=null,"absent-source-can-rebind-stable-id");
            CaelumPoiKnowledge.RecordUse(u,Sources[1],2);
            Check(r.KnownPois.Size()==5,"recreated-source-does-not-duplicate-fact");
            Check(CaelumPoiKnowledge.Find(r,"NOT_THIS_MAP","fixture-1")==null,"stable-map-id-is-part-of-identity");
            Check(CaelumPoiKnowledge.Find(r,level.MapName,"upper-hidden")==null,"stacked-floor-does-not-leak");
            u.PersistCharacterState();
        }
        if(e.Name=="c232_markers")Check(MarkerCount()==5,"five-known-native-icons-no-hidden-icons");
        if(e.Name=="c232_loaded")
        {
            Check(r.LocalKnowledgeRevision==1 && r.KnownPois.Size()==5,"five-facts-survive-native-reload");
            for(int i=0;i<5;i++)Check(CaelumPoiKnowledge.Find(r,level.MapName,String.Format("fixture-%d",i+1))!=null,String.Format("saved-category-%d",i+1));
            Check(CaelumPoiKnowledge.Find(r,level.MapName,"upper-hidden")==null,"reload-keeps-hidden-floor-unknown");
        }
        if(e.Name=="c232_legacy")
        {
            Check(r.LocalKnowledgeRevision==1 && r.KnownPois.Size()==0,"genuine-old-save-migrates-without-inferred-discovery");
            CaelumPoiKnowledge.Ensure(r);Check(r.KnownPois.Size()==0,"legacy-migration-repeat-no-discovery");
        }
        if(e.Name=="c232_hubgo")Level.ChangeLevel(e.Args[0]==0?"MAP04":"MAP03",0,CHANGELEVEL_NOINTERMISSION);
        if(e.Name=="c232_hubaway")
        {
            Check(level.MapName=="MAP04" && r.KnownPois.Size()==5,"traveler-retains-other-map-facts");
            Check(MarkerCount()==0 && CaelumPoiKnowledge.Find(r,"MAP04","fixture-1")==null,"other-map-same-id-is-unknown");
            let source=Actor.Spawn("MapSpot",r.KnownPois[0].ObservedPosition,NO_REPLACE);
            CaelumPoiRegistration.Bind(source,"fixture-1",1,"CA_POI_BED");
            CaelumPoiKnowledge.RecordUse(u,source,1);
            Check(r.KnownPois.Size()==6 && CaelumPoiKnowledge.Find(r,"MAP03","fixture-1")!=CaelumPoiKnowledge.Find(r,"MAP04","fixture-1"),"same-coordinates-and-id-are-distinct-per-map");
        }
        if(e.Name=="c232_hubback")
        {
            Check(level.MapName=="MAP03" && r.KnownPois.Size()==6,"hub-return-keeps-both-map-records");
            Check(MarkerCount()==5,"hub-return-reuses-five-native-markers");
            Check(CaelumPoiKnowledge.Find(r,"MAP03","upper-hidden")==null,"hub-return-does-not-invent-hidden-discovery");
        }
        if(e.Name=="c232_privacy")
        {
            int count=0;for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])count++;
            Check(multiplayer || count>1,"native-multiple-participant-fixture-active");
            Check(CaelumPoiKnowledge.MarkerUser()==null && MarkerCount()==0,"native-markers-suppressed-with-multiple-participants");
            Check(r.KnownPois.Size()==5,"private-facts-retained-when-icons-suppressed");
            CaelumPlayer other;
            for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i] && players[i].mo!=u)other=CaelumPlayer(players[i].mo);
            if(other!=null)
            {
                other.CreationWizardOpen=false;other.CharacterCreationComplete=true;other.ApplyCharacterProfile();
                let second=other.GetPersistentCharacterState(true);second.ProfileCommitted=true;
                Check(second!=r && second.KnownPois.Size()==0,"second-native-player-starts-with-own-empty-record");
                let it=ThinkerIterator.Create("CaelumPoiRegistration");CaelumPoiRegistration entry;
                while((entry=CaelumPoiRegistration(it.Next()))!=null)if(entry.PoiId=="upper-hidden")CaelumPoiKnowledge.RecordUse(other,entry.Subject,entry.Category);
                Check(second.KnownPois.Size()==1 && r.KnownPois.Size()==5,"two-native-players-retain-different-exploration");
                Check(CaelumPoiKnowledge.Find(second,level.MapName,"fixture-1")==null && CaelumPoiKnowledge.Find(r,level.MapName,"upper-hidden")==null,"native-player-knowledge-does-not-cross-owners");
            }
        }
        if(e.Name=="c232_done")Console.Printf("CA232 DONE failures=%d",Failures);
    }
}
