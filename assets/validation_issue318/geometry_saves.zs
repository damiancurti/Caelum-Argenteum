// Owned fixture state makes map/hub continuity observable without changing rules.
class CA318GeometrySaveState : Actor
{
    CaelumPortSiege Port;
    CaelumPortDefender First,Last;
    CaelumSlidingDoorLeaf Door;
    int Setup,Defenders,Attackers,DoorGroup;
    vector3 DoorClosed;
    bool SiegeStarted;
    Default { +NOINTERACTION }
    States { Spawn: TNT1 A -1; Stop; }
}
class CA318GeometrySaveProbe : EventHandler
{
    int Checks,Failures;
    override bool InputProcess(InputEvent e){return true;}
    override void UiTick(){if(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();}
    void Check(bool ok,String label)
    {Checks++;if(!ok)Failures++;Console.Printf("CA318 %s %s",ok?"PASS":"FAIL",label);}
    CA318GeometrySaveState State()
    {let it=ThinkerIterator.Create("CA318GeometrySaveState");return CA318GeometrySaveState(it.Next());}
    void Catalogue()
    {
        let user=CaelumPlayer(players[0].mo);vector3 origin=user.Pos;
        let record=user.GetPersistentCharacterState(true);record.ProfileCommitted=true;
        // Sólo la partida aislada del diagnóstico: verificar descubrimiento nuevo.
        record.KnownPois.Clear();record.CartographyMap="";
        for(int i=0;i<4;i++)
        {
            user.SetOrigin(CaelumCartographyCatalogueData.TowerPosition(i),false);
            CaelumAuthoredCartography.Update(user,record);
            Check(CaelumPoiKnowledge.Find(record,"MAP06",String.Format("city-tower-%d",i))!=null,
                String.Format("Authored tower %d discovered on loaded geometry",i));
        }
        vector3 east=CaelumCartographyCatalogueData.EastPosition();
        user.SetOrigin(east-(16,0,0),false);CaelumAuthoredCartography.Update(user,record);
        user.SetOrigin(east+(16,0,0),false);CaelumAuthoredCartography.Update(user,record);
        Check(CaelumPoiKnowledge.Find(record,"MAP06","city-east-exit")!=null,"East crossing discovered on loaded geometry");
        let it=ThinkerIterator.Create("CaelumCraftingStation");CaelumCraftingStation station;bool bound=false;
        while((station=CaelumCraftingStation(it.Next()))!=null)
        {
            String id=CaelumCartographyCatalogueData.CityStationId(station.SpawnPoint);
            if(id.Length()==0)continue;
            CaelumAuthoredCartography.BindSubject(station,CaelumPoiData.STATION);
            let entries=ThinkerIterator.Create("CaelumPoiRegistration");CaelumPoiRegistration entry;
            while((entry=CaelumPoiRegistration(entries.Next()))!=null)
                if(entry.Subject==station && entry.PoiId==id){bound=true;break;}
            break;
        }
        Check(bound,"Factory station catalogue binds on loaded geometry");
        user.SetOrigin(origin,false);
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="c318_seed")
        {
            let user=CaelumPlayer(players[0].mo);
            user.CharacterCreationComplete=true;user.CreationWizardOpen=false;
            user.ApplyCharacterProfile();user.bInvulnerable=true;
            let s=CA318GeometrySaveState(Actor.Spawn("CA318GeometrySaveState",user.Pos));
            s.Port=CaelumPortSiege.Get();
            Check(s.Port!=null,"MAP06 controller present");
            s.Setup=s.Port.SetupRevision;s.Defenders=s.Port.Defenders.Size();s.Attackers=s.Port.Attackers.Size();
            s.First=s.Port.Defenders[0];s.Last=s.Port.Defenders[s.Defenders-1];s.SiegeStarted=s.Port.SiegeStarted;
            let it=ThinkerIterator.Create("CaelumSlidingDoorLeaf");s.Door=CaelumSlidingDoorLeaf(it.Next());
            s.DoorGroup=s.Door.args[0];s.DoorClosed=s.Door.ClosedPosition;
            Check(s.Defenders==CaelumPortData.DefenderCount(),"Authored defender population seeded");
        }
        if(e.Name=="c318_saved")
        {
            let s=State();Check(s!=null,"Saved MAP06 marker restored");
            if(s==null)return;
            Check(CaelumPortSiege.Get()==s.Port,"Controller reference preserved");
            Check(s.Port.SetupRevision==s.Setup,"Population revision preserved");
            Check(s.Port.Defenders.Size()==s.Defenders,"Defender count preserved");
            Check(s.Port.Attackers.Size()==s.Attackers,"Attacker count preserved");
            Check(s.Port.Defenders[0]==s.First && s.Port.Defenders[s.Defenders-1]==s.Last,"Defender identities preserved");
            Check(s.Port.SiegeStarted==s.SiegeStarted,"Siege phase preserved");
            Check(s.Door!=null && s.Door.args[0]==s.DoorGroup && s.Door.ClosedPosition==s.DoorClosed,"Door identity and placement preserved");
            Check(CaelumPlayer(players[0].mo).CharacterCreationComplete,"Player creation state preserved");
        }
        if(e.Name=="c318_hub")Check(level.MapName=="MAP07","Save outside visited MAP06 hub");
        if(e.Name=="c318_catalogue")Catalogue();
        if(e.Name=="c318_done")Console.Printf("CA318 DONE failures=%d checks=%d",Failures,Checks);
    }
}
