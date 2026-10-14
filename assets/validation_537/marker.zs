// Regresion: comprobar el MapMarker real despues del uso nativo, no solo el dato.
class CA234Marker : StaticEventHandler
{
    ui int Failures;
    ui void Check(bool ok,String label)
    {if(!ok)Failures++;Console.Printf("CA234 %s %s",ok?"PASS":"FAIL",label);}
    override void ConsoleProcess(ConsoleEvent e)
    {
        if(e.Name=="c234_marker_done")Console.Printf("CA234 DONE failures=%d",Failures);
        if(e.Name!="c234_marker_closed" && e.Name!="c234_marker_open" && e.Name!="c234_marker_remote")return;
        let user=CaelumPlayer(players[consoleplayer].mo);
        let record=CaelumPersistentCharacterState(user.FindInventory("CaelumPersistentCharacterState"));
        let fact=CaelumPoiKnowledge.Find(record,level.MapName,"maze-grate-44700");
        bool open=e.Name!="c234_marker_closed";
        Check(fact!=null,"observed-grate-exists");if(fact==null)return;
        Check(record.KnownPois.Size()==1,"other-grates-remain-unknown");
        Check(fact.ObservedAccess==(open?2:1),"observed-access-matches-use");
        Check(CaelumPoiView.Name(fact).IndexOf(StringTable.Localize(open?"CA_POI_OBSERVED_OPEN":"CA_POI_OBSERVED_CLOSED",false))>=0,"label-matches-observation");
        let it=ThinkerIterator.Create("CaelumKnownPoiMarker");CaelumKnownPoiMarker marker;int count=0;
        while((marker=CaelumKnownPoiMarker(it.Next()))!=null)
        {
            if(marker.PoiId!=fact.PoiId)continue;
            count++;
            Check(!marker.bDormant,"known-marker-visible");
            Check(marker.Pos==fact.ObservedPosition,"marker-position-preserved");
            let locked=TexMan.CheckForTexture("graphics/caelum/ui/journal/icons/ca_ui_action_locked.png",TexMan.Type_Any);
            let passage=TexMan.CheckForTexture("graphics/caelum/ui/journal/icons/ca_ui_action_use.png",TexMan.Type_Any);
            Check(locked!=passage,"existing-artwork-distinguishes-access");
            Check(marker.picnum==(open?passage:locked),open?"open-marker-is-passage-not-lock":"closed-marker-is-lock");
        }
        Check(count==1,"one-marker-for-same-stable-id");
        if(e.Name=="c234_marker_remote")
        {
            let gate=CaelumMazeBarredGate(ActorIterator.Create(44700,"CaelumMazeBarredGate").Next());
            Check(gate!=null && !gate.Opened,"remote-state-differs-without-reobserving");
        }
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let user=CaelumPlayer(players[e.Player].mo);if(user==null)return;
        if(e.Name=="c234_marker_key")user.GiveInventory("CaelumMazeSluiceKey",1);
        if(e.Name=="c234_marker_remote_close" || e.Name=="c234_marker_restore")
        {
            let gate=CaelumMazeBarredGate(ActorIterator.Create(44700,"CaelumMazeBarredGate").Next());
            if(gate!=null)gate.Opened=e.Name=="c234_marker_restore";
        }
    }
}
