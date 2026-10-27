class CA410SofaChecks : EventHandler
{
    int Passed,Failed;
    CaelumSofa Two,Three;
    void Check(bool ok,String label){if(ok)Passed++;else Failed++;Console.Printf("CA410SF %s %s",ok?"PASS":"FAIL",label);}
    bool Near(double a,double b){return Abs(a-b)<.000001;}
    void Profile(CaelumPlayer u)
    {
        u.CharacterCreationComplete=true;u.CreationWizardOpen=false;u.bInvulnerable=true;
        u.GetPersistentCharacterState(true).ProfileCommitted=true;
        u.GetPersistentCharacterState(true).SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_UNKNOWN_VOICE_HEARD);
        u.CombatTimeRemaining=0;u.CurrentHunger=100;u.CurrentThirst=100;u.CurrentSleep=100;u.Vel=(0,0,0);
    }
    bool Find(CaelumPlayer u)
    {
        Profile(u);Two=CaelumSofa(ThinkerIterator.Create('CaelumTwoSeatSofa').Next());
        Three=CaelumSofa(ThinkerIterator.Create('CaelumThreeSeatSofa').Next());
        Check(Two!=null && Three!=null,"both authored sofas installed");return Two!=null && Three!=null;
    }
    void Approach(CaelumPlayer u,CaelumSofa sofa,int slot)
    {u.SetOrigin(sofa.SeatPosition(slot)+(64,0,0),false);u.FindFloorCeiling();u.Angle=180;u.Pitch=25;u.Vel=(0,0,0);}
    void StopRest(CaelumPlayer u)
    {let rest=CaelumRestState.Get(u);if(rest!=null)rest.Finish(u,CaelumRestRules.STATUS_CANCELLED,"");}
    void Core(CaelumPlayer u)
    {
        if(!Find(u))return;int bodies=0,seats=0;
        let it=ThinkerIterator.Create('CaelumSofa');while(it.Next()!=null)bodies++;
        it=ThinkerIterator.Create('CaelumSofaSeat');while(it.Next()!=null)seats++;
        Check(bodies==2 && seats==5,"exactly two furniture owners and five seat proxies");
        Check(CaelumMansionSofas.Prepare(),"repeat installation is idempotent");
        Check(Near(Two.Radius,Sqrt(60.16*60.16+19.52*19.52)/2),"two-seat visual envelope retains documented dimensions");
        Check(Near(Three.Height,28.032) && Three.Mass==44,"three-seat height and calculated mass");
        double radius=u.Radius,height=u.Height;vector3 offset=u.WorldOffset;
        for(int kind=0;kind<2;kind++)
        {
            let sofa=kind==0?Two:Three;
            Check(sofa.SeatsReady,"seat links initialized");
            for(int i=0;i<CaelumSofaData.Seats(kind);i++)
            {
                let seat=sofa.Seats[i];Approach(u,sofa,i);
                Check(seat!=null && seat.Sofa==sofa && seat.Slot==i,"each native seat retains parent and index");
                Check(u.TestMobjLocation() && seat.CanReach(u),"approach has full-body clearance and sight");
                Check(CaelumRestState.Begin(u,CaelumRestRules.MODE_WAIT,0,seat),"ordinary rest begins on this seat");
                Check(CaelumRestState.IsSeated(u) && seat.Occupant==u && !seat.bSolid,"one seat lends its collision to its occupant");
                Check(Near(u.Radius,radius) && Near(u.Height,height) && u.TestMobjLocation(),"native player dimensions and collision unchanged");
                Check(CaelumRestState.ResourceFactor(u)==CaelumRestRules.CHAIR_RESOURCE_FACTOR,"existing chair comfort without new bonus");
                Check(sofa.AvailableSeat(u)!=seat,"occupied seat is not offered twice");
                StopRest(u);
                Check(seat.Occupant==null && u.TestMobjLocation() && u.WorldOffset==offset,"standing restores pose and exits safely");
                Check(seat.bSolid,"vacated seat restores its collision");
            }
        }
        CaelumContaminationStorage.Set(Three,37.5);
        Check(CaelumContaminationObject.Eligible(Three) && !CaelumContaminationObject.Eligible(Three.Seats[0]),"one exposure scheduler per logical sofa");
        Check(CaelumContaminationStorage.Get(Three)==CaelumContaminationStorage.Get(Three.Seats[1]),"all seats share actual furniture contamination");
        Check(Near(CaelumContaminationStorage.Value(Three.Seats[2]),37.5),"contact reads the parent concentration");
        Check(Near(CaelumContaminationObject.Area(Three),CaelumContaminationObject.Area(Three.Seats[0])),"proxy cleaning cannot undercharge the furniture surface");
        CaelumContaminationStorage.Set(Three.Seats[1],12.5);
        Check(Near(CaelumContaminationStorage.Value(Three),12.5),"cleaning either proxy changes the same stored concentration");
        let shelf=CaelumReadingShelf(ThinkerIterator.Create('CaelumReadingShelf').Next());
        let desk=CaelumReadingDesk(ThinkerIterator.Create('CaelumReadingDesk').Next());
        Check(shelf!=null && desk!=null && CaelumStoredReading.Adjacent(desk,shelf),"accepted library adjacency preserved");
        u.SetOrigin(desk.Pos+(-64,0,0),false);u.FindFloorCeiling();
        Check(u.TestMobjLocation(),"accepted desk approach remains clear");
    }
    void View(CaelumPlayer u,int kind,int slot)
    {
        if(!Find(u))return;let sofa=kind==0?Two:Three;Approach(u,sofa,slot);
        if(slot>=0){Check(CaelumRestState.Begin(u,CaelumRestRules.MODE_WAIT,0,sofa.Seats[slot]),"seated view begins through production rest");let rest=CaelumRestState.Get(u);rest.CameraYaw=215;rest.CameraPitch=12;}
    }
    void Seed(CaelumPlayer u)
    {
        if(!Find(u))return;CaelumContaminationStorage.Set(Three,42.25);Approach(u,Three,1);
        Check(CaelumRestState.Begin(u,CaelumRestRules.MODE_WAIT,0,Three.Seats[1]),"save starts ordinary occupied seat");
    }
    void Resume(CaelumPlayer u)
    {
        if(!Find(u))return;
        Check(CaelumRestState.IsSeated(u) && Three.Seats[1].Occupant==u,"saved occupied seat and rest identity restored");
        Check(CaelumContaminationStorage.Get(Three)==CaelumContaminationStorage.Get(Three.Seats[1]),"saved proxy contamination still aliases owner");
        Check(CaelumContaminationStorage.Value(Three)>=42.25,"saved furniture dirt is not reset");
        StopRest(u);Check(u.TestMobjLocation(),"saved occupant stands without collision loss");
    }
    void Lifecycle(CaelumPlayer u,int phase)
    {
        if(!Find(u))return;
        if(phase==1)
        {
            Check(!CaelumRestState.IsActive(u),"hub travel ends map-local rest");
            Check(Three.Seats[1].Occupant==null && CaelumContaminationStorage.Value(Three)>=42.25,"hub retains shared dirt and releases occupied proxy");
            int count=0;let it=ThinkerIterator.Create('CaelumSofaSeat');while(it.Next()!=null)count++;
            Check(count==5,"hub restoration does not duplicate seats");return;
        }
        Approach(u,Three,1);vector3 entry=u.Pos;
        let blocker=Actor.Spawn('CaelumRestChair',Three.Seats[1].Pos,NO_REPLACE);
        blocker.A_SetSize(16,56,false);blocker.bSolid=true;blocker.SetOrigin(Three.Seats[1].Pos+(1,0,0),false);
        Check(!CaelumRestState.Begin(u,CaelumRestRules.MODE_WAIT,0,Three.Seats[1]),"occupied physical footprint rejects seating without telefrag");
        Check(u.Pos==entry && Three.Seats[1].Occupant==null,"failed seating leaves position and ownership intact");
        blocker.Destroy();
        u.SetOrigin(Three.Seats[1].Pos+(16,0,0),false);u.FindFloorCeiling();
        Check(CaelumRestState.Begin(u,CaelumRestRules.MODE_WAIT,0,Three.Seats[1]),"cleared footprint accepts ordinary rest");
        Three.Destroy();
    }
    void Destroyed(CaelumPlayer u)
    {
        Check(!CaelumRestState.IsActive(u),"destroyed sofa ends its active rest");
        int count=0;let it=ThinkerIterator.Create('CaelumSofaSeat');while(it.Next()!=null)count++;
        Check(count==2,"destroyed owner removes only its three proxies");
        for(int kind=0;kind<2;kind++)
        {
            class<CaelumRestFurniture> cls=kind==0?'CaelumRestChair':'CaelumRestBed';
            let chair=CaelumRestFurniture(Actor.Spawn(cls,CaelumSofaData.Position(1),NO_REPLACE));
            let blocker=Actor.Spawn('CaelumRestChair',chair.Pos+(1,0,0),NO_REPLACE);
            u.SetOrigin(chair.Pos+(80,0,0),false);u.FindFloorCeiling();vector3 entry=u.Pos;
            Check(!chair.Seat(u) && u.Pos==entry,"existing chair/bed rejects blocked destination before moving player");
            blocker.Destroy();
            Check(chair.Seat(u) && chair.Occupant==u,"existing chair/bed still accepts clear destination");
            chair.Release(u,entry);
            Check(chair.Occupant==null && u.Pos!=chair.Pos,"existing chair/bed releases occupant safely");
            chair.Destroy();
        }
    }
    void Migration(CaelumPlayer u)
    {
        if(!Find(u))return;int count=0;let it=ThinkerIterator.Create('CaelumSofaSeat');while(it.Next()!=null)count++;
        Check(count==5,"older save installs five seat proxies exactly once");
        let reading=CaelumRecipeSession.Get(u);
        Check(reading!=null && reading.Active && reading.Book!=null && Near(reading.RemainingSeconds,321.75),"original saved library task and precise progress preserved");
    }
    void Input(CaelumPlayer u,int phase)
    {
        if(!Find(u))return;
        if(phase==0){Approach(u,Three,1);Check(CaelumUseGeometry.AimedAt(u,Three),"native Use setup aims at visible sofa");return;}
        let guide=CaelumRestGuide(ThinkerIterator.Create('CaelumRestGuide').Next());
        Console.Printf("CA410SF INPUT guide=%d conversation=%d slot=%d",guide!=null,u.HasActiveConversation(),guide!=null && guide.Furniture is 'CaelumSofaSeat'?CaelumSofaSeat(guide.Furniture).Slot:-1);
        Check(guide!=null && guide.Subject==u && guide.Furniture==Three.Seats[1] && u.HasActiveConversation(),"native Use opens nearest available sofa seat dialogue");
    }
    void Target(CaelumPlayer u)
    {
        if(!Find(u))return;Approach(u,Three,1);
        Check(CaelumTargetInfo.CanonicalActor(Three.Seats[1])==Three,"aim panel resolves logical sofa from its hidden seat");
        let targetInfo=new('CaelumTargetInfo');targetInfo.Refresh(u);
        Check(targetInfo.Subject==Three && targetInfo.Title==StringTable.Localize("CA_SOFAS_THREE",false),"native trace shows localized furniture name");
        Check(targetInfo.Actions==StringTable.Localize("CA_USE_CHAIR",false),"aim panel shows existing seated-use action");
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Player<0 || e.Player>=MAXPLAYERS || !playeringame[e.Player])return;
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=='ca410sf_profile'){Profile(u);return;}
        if(e.Name=='ca410sf_core')Core(u);
        else if(e.Name=='ca410sf_view')View(u,e.Args[0],e.Args[1]);
        else if(e.Name=='ca410sf_input')Input(u,e.Args[0]);
        else if(e.Name=='ca410sf_seed')Seed(u);
        else if(e.Name=='ca410sf_resume')Resume(u);
        else if(e.Name=='ca410sf_lifecycle')Lifecycle(u,e.Args[0]);
        else if(e.Name=='ca410sf_destroyed')Destroyed(u);
        else if(e.Name=='ca410sf_migration')Migration(u);
        else if(e.Name=='ca410sf_target')Target(u);
        else return;
        Console.Printf("CA410SF RESULT passed=%d failed=%d",Passed,Failed);
    }
}
