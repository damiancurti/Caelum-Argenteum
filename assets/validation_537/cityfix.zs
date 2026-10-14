// Regresión sobre los portones y puestos existentes; la posición diagnóstica
// no certifica el recorrido ordinario ni otorga permisos de campaña.
class CA234Cityfix : StaticEventHandler
{
    ui int Failures;
    bool HadUse;
    override void WorldTick()
    {
        let user=CaelumPlayer(players[consoleplayer].mo);if(user==null || user.player==null)return;
        bool held=(user.player.cmd.buttons & BT_USE)!=0;
        if(held && !HadUse)Console.Printf("CA234 INPUT USE pos=%.0f,%.0f angle=%.0f profile=%d wizard=%d crafting=%d",user.Pos.X,user.Pos.Y,user.Angle,user.CharacterCreationComplete,user.CreationWizardOpen,user.CraftingMenuOpen);
        HadUse=held;
    }
    ui void Check(bool ok,String label)
    {if(!ok)Failures++;Console.Printf("CA234 %s %s",ok?"PASS":"FAIL",label);}
    CaelumCraftingStation Station(int index)
    {
        let it=ThinkerIterator.Create("CaelumCraftingStation");CaelumCraftingStation station;
        while((station=CaelumCraftingStation(it.Next()))!=null)
            if(station.SpawnPoint==CA234CitySites.Position(index))return station;
        return null;
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let user=CaelumPlayer(players[e.Player].mo);if(user==null)return;
        let port=CaelumPortSiege.Get();if(port==null)return;
        if(e.Name=="c234_city_gate")
        {
            let gate=port.Gates[0];gate.args[2]=0;gate.Opened=false;gate.HoldTimer=0;gate.RefreshPassage();
            user.SetOrigin(gate.Pos+(0,64,0),false);user.Vel=(0,0,0);user.Angle=270;user.Pitch=0;
        }
        if(e.Name=="c234_city_allow")port.Gates[0].args[2]=1;
        if(e.Name=="c234_city_denied")port.Gates[0].Used(user);
        if(e.Name=="c234_city_remote")
        {port.Gates[0].Opened=false;port.Gates[0].HoldTimer=0;port.Gates[0].RefreshPassage();}
        if(e.Name=="c234_city_station")
        {
            user.CloseCraftingStationSession();user.SetCraftingJournalState(false);
            let station=Station(e.Args[0]);if(station==null){Console.Printf("CA234 FAIL missing-existing-station");return;}
            user.SetOrigin(station.Pos+(0,-80,0),false);user.Vel=(0,0,0);user.Angle=90;user.Pitch=0;
        }
        if(e.Name=="c234_city_catalogue")
            for(int i=0;i<CA234CitySites.COUNT;i++)
                CaelumPoiKnowledge.RecordUse(user,Station(i),CaelumPoiData.STATION);
        if(e.Name=="c234_city_release")
        {user.CloseCraftingStationSession();user.SetCraftingJournalState(false);}
    }
    ui void Marker(CaelumKnownPoi fact,String path)
    {
        if(fact==null)return;
        let it=ThinkerIterator.Create("CaelumKnownPoiMarker");CaelumKnownPoiMarker marker;int count=0;
        while((marker=CaelumKnownPoiMarker(it.Next()))!=null)
            if(marker.PoiId==fact.PoiId)
            {
                count++;Check(!marker.bDormant,"actual-marker-visible");
                Check(marker.Pos==fact.ObservedPosition,"actual-marker-position");
                Check(marker.picnum==TexMan.CheckForTexture(path,TexMan.Type_Any),"actual-marker-correct-artwork");
            }
        Check(count==1,"one-marker-per-stable-id");
    }
    override void ConsoleProcess(ConsoleEvent e)
    {
        if(e.Name=="c234_city_done"){Console.Printf("CA234 DONE failures=%d",Failures);return;}
        let user=CaelumPlayer(players[consoleplayer].mo);if(user==null)return;
        let record=CaelumPersistentCharacterState(user.FindInventory("CaelumPersistentCharacterState"));
        let port=CaelumPortSiege(ThinkerIterator.Create("CaelumPortSiege").Next());if(record==null || port==null)return;
        if(e.Name=="c234_city_position")Console.Printf("CA234 POSITION %.1f %.1f %.1f angle=%.1f wizard=%d profile=%d menu=%d latch=%d map=%d",user.Pos.X,user.Pos.Y,user.Pos.Z,user.Angle,user.CreationWizardOpen,record.ProfileCommitted,user.CraftingMenuOpen,user.CraftingStationUseLatched,automapactive);
        if(e.Name=="c234_city_empty")Check(record.KnownPois.Size()==0,"city-starts-with-no-known-services");
        if(e.Name=="c234_city_closed" || e.Name=="c234_city_open" || e.Name=="c234_city_remembered")
        {
            bool open=e.Name!="c234_city_closed";
            let fact=CaelumPoiKnowledge.Find(record,level.MapName,"port-r3-gate-0");
            Check(fact!=null,"native-gate-use-recorded");
            Check(fact!=null && fact.ObservedAccess==(open?2:1),"gate-observation-matches-last-use");
            Check(record.KnownPois.Size()==1,"other-gates-and-services-not-revealed");
            Marker(fact,open?"graphics/caelum/ui/journal/icons/ca_ui_action_unlocked.png":"graphics/caelum/ui/journal/icons/ca_ui_action_locked.png");
            if(e.Name=="c234_city_remembered")Check(!port.Gates[0].Opened,"remote-close-does-not-reobserve");
            else Check(port.Gates[0].Opened==open,"native-gate-access-result");
        }
        if(e.Name=="c234_city_station_check")
        {
            let fact=CaelumPoiKnowledge.Find(record,level.MapName,CA234CitySites.Id(e.Args[0]));
            Check(fact!=null,"native-station-use-recorded");
            Check(user.CraftingMenuOpen,"native-station-menu-open");
            Check(record.KnownPois.Size()==e.Args[1],"using-one-station-does-not-reveal-network");
            Marker(fact,"graphics/caelum/ui/journal/icons/ca_ui_nav_crafts.png");
        }
        if(e.Name=="c234_city_catalogue_check")
        {
            int valid=0;
            for(int i=0;i<CA234CitySites.COUNT;i++)
            {
                let fact=CaelumPoiKnowledge.Find(record,level.MapName,CA234CitySites.Id(i));
                if(fact!=null && fact.Category==CaelumPoiData.STATION && fact.ObservedPosition==CA234CitySites.Position(i)
                    && fact.NameKey!="CA_CRAFTING_STATION_NONE" && fact.ObservedAccess==0)valid++;
            }
            Check(valid==CA234CitySites.COUNT,"all-authored-factory-stations-registered");
            Check(record.KnownPois.Size()==CA234CitySites.COUNT+1,"catalogue-stable-no-extra-discoveries");
            Check(record.LocalKnowledgeRevision==2,"existing-save-schema-preserved");
        }
        if(e.Name=="c234_city_exit_icons")
        {
            Check(CaelumPoiData.IconPath(CaelumPoiData.EXIT)=="graphics/caelum/ui/journal/icons/ca_ui_action_use.png","ordinary-exit-and-manual-note-icon-unchanged");
            Check(CaelumPoiData.IconPath(CaelumPoiData.GRATE,2)=="graphics/caelum/ui/journal/icons/ca_ui_action_unlocked.png","accepted-grate-icon-preserved");
        }
        if(e.Name=="c234_city_saved_services")
        {
            Check(record.KnownPois.Size()==2,"reload-retains-only-used-services");
            let gateFact=CaelumPoiKnowledge.Find(record,level.MapName,"port-r3-gate-0");
            Check(gateFact!=null && gateFact.ObservedAccess==2,"reload-retains-observed-gate-state");
            Marker(gateFact,"graphics/caelum/ui/journal/icons/ca_ui_action_unlocked.png");
            for(int i=0;i<1;i++)
            {
                let fact=CaelumPoiKnowledge.Find(record,level.MapName,CA234CitySites.Id(i));
                Check(fact!=null,"reload-retains-used-station");
                Marker(fact,"graphics/caelum/ui/journal/icons/ca_ui_nav_crafts.png");
            }
        }
        if(e.Name=="c234_city_old_save")
        {
            let fact=CaelumPoiKnowledge.Find(record,level.MapName,"port-r3-gate-0");
            Check(record.KnownPois.Size()==1 && fact!=null && fact.ObservedAccess==0,"old-save-keeps-unknown-access-without-inference");
            Check(record.LocalKnowledgeRevision==2,"old-save-revision-preserved");
        }
    }
}
