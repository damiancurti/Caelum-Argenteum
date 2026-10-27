class CA410LuxuryChecks : EventHandler
{
    int Passed,Failed;
    CaelumLuxuryChair Chair;
    CaelumLuxuryBed Bed;
    CaelumLuxuryTable Table;
    void Check(bool ok,String label){if(ok)Passed++;else Failed++;Console.Printf("CA410LX %s %s",ok?"PASS":"FAIL",label);}
    bool Near(double a,double b){return Abs(a-b)<.00001;}
    void Profile(CaelumPlayer u)
    {
        u.CharacterCreationComplete=true;u.CreationWizardOpen=false;u.bInvulnerable=true;
        u.GetPersistentCharacterState(true).ProfileCommitted=true;u.CombatTimeRemaining=0;
        u.CurrentHunger=100;u.CurrentThirst=100;u.CurrentSleep=50;u.Vel=(0,0,0);
    }
    void Setup(CaelumPlayer u)
    {
        Profile(u);
        if(Chair==null)Chair=CaelumLuxuryChair(Actor.Spawn('CaelumLuxuryChair',(-240,0,0)));
        if(Bed==null)Bed=CaelumLuxuryBed(Actor.Spawn('CaelumLuxuryBed',(180,0,0)));
        if(Table==null)Table=CaelumLuxuryTable(Actor.Spawn('CaelumLuxuryTable',(0,320,0)));
        let zone=Actor.Spawn('CaelumTimeAdvanceZone',(0,0,0));zone.A_SetSize(900,256,false);
        Check(Chair!=null && Bed!=null && Table!=null,"all three original furniture actors spawn");
    }
    void StopRest(CaelumPlayer u){let rest=CaelumRestState.Get(u);if(rest!=null)rest.Finish(u,CaelumRestRules.STATUS_CANCELLED,"");}
    void Approach(CaelumPlayer u,CaelumRestFurniture piece)
    {u.SetOrigin(piece.Pos+(-72,0,0),false);u.FindFloorCeiling();u.Vel=(0,0,0);u.Angle=0;u.Pitch=15;}
    void Core(CaelumPlayer u)
    {
        Profile(u);double radius=u.Radius,height=u.Height;
        Check(Chair.ComfortFactor()==CaelumRestRules.CHAIR_RESOURCE_FACTOR && Bed.ComfortFactor()==4,"luxury supplies no new rest bonus");
        Check(Chair.TestMobjLocation() && Bed.TestMobjLocation() && Table.LayoutFits(),"all complete native layouts fit");
        for(int kind=0;kind<2;kind++)
        {
            CaelumRestFurniture piece=Chair;if(kind==1)piece=Bed;Approach(u,piece);
            Check(CaelumRestState.Begin(u,piece.RestMode(),5,piece),"native rest begins");
            Check(piece.Occupant==u && !piece.bSolid,"one real occupant borrows furniture collision");
            Check(Near(radius,u.Radius) && Near(height,u.Height) && u.TestMobjLocation(),"player keeps physical dimensions and clearance");
            vector3 pose=piece.PoseOffsetFor(u);Check(Near(u.WorldOffset.Z,pose.Z),"rest pose aligns with measured surface");
            StopRest(u);Check(piece.Occupant==null,"ordinary cancellation releases occupant");
        }
        Check(Table.HasSeatLayout(6) && Table.Capacity()==18,"table retains six actual seats and eighteen item slots");
        Check(Table.LuxuryLayoutRevision==CaelumLuxuryData.LAYOUT_REVISION && Table.PrepareLuxuryLayout(),"revisioned layout preparation is idempotent");
        for(int i=0;i<6;i++)Check(Table.Chairs[i] is 'CaelumLuxuryChair',"table uses a matching functional chair");
        int count=0;for(int i=0;i<18;i++)if(Table.Items[i]!=null)count++;
        Check(count==0,"new furniture creates no food or water");
        for(int i=0;i<18;i++)
        {let item=CaelumConsumableItem(Actor.Spawn('CaelumFoodRation',Table.Pos));item.Amount=1;item.AttachToOwner(Table);Table.Items[i]=item;}
        Table.RefreshDisplays();
        for(int i=0;i<18;i++)Check(Table.Displays[i]!=null && Table.Displays[i].Item==Table.Items[i]
            && Table.Items[i].Owner==Table,"each serving refers to one real owned item");
        double scale=Table.Displays[0].Scale.X;Table.RefreshDisplays();
        Check(Near(Table.Displays[0].Scale.X,scale),"rebuilding presentation never compounds serving scale");
        Table.MoveLayout((256,320,0),90);
        Check(Table.HasSeatLayout(6) && Table.LayoutFits(),"moving and rotating preserves full chair layout");
        Check(Near(Table.Displays[0].Pos.Z,Table.Pos.Z+Table.SurfaceHeight()),"servings retain tabletop height after rotation");
        Approach(u,Chair);let blocker=Actor.Spawn('CaelumRestChair',Chair.Pos+(1,0,0));blocker.A_SetSize(16,56,false);
        Check(!Chair.Seat(u),"occupied full-body destination rejects sitting");blocker.Destroy();
        Check(Chair.Seat(u),"cleared destination accepts the same body");Chair.Release(u,Chair.Pos+(-72,0,0));
        Check(Chair.Mass==30 && Bed.Mass==136 && Table.Mass==193,"actor mass rounds the exact construction bill upward");
        let ordinary=CaelumDiningTable(Actor.Spawn('CaelumDiningTable',(-512,320,0)));
        let canteen=CaelumWaterContainer(Actor.Spawn('CaelumCanteenLarge',ordinary.Pos));
        canteen.AttachToOwner(ordinary);ordinary.Items[0]=canteen;
        ordinary.RefreshDisplays();ordinary.RefreshDisplays();
        Check(Near(ordinary.Displays[0].Scale.X,GetDefaultByType('CaelumCanteenLarge').Scale.X),"accepted ordinary-table canteen scale remains unchanged");
        Check(Near(ordinary.DisplayMargin(),40) && Near(ordinary.SurfaceHeight(),34.1/level.pixelstretch),"ordinary table retains its original serving layout");
        let standard=CaelumRestChair(Actor.Spawn('CaelumRestChair',(-512,0,0)));
        Approach(u,standard);Check(CaelumRestState.Begin(u,standard.RestMode(),5,standard),"accepted ordinary chair still begins native rest");StopRest(u);
        Check(standard.Occupant==null,"ordinary chair cancellation still releases occupancy");
    }
    void Seed(CaelumPlayer u)
    {
        let item=CaelumConsumableItem(Actor.Spawn('CaelumFoodRation',Table.Pos));item.Amount=1;item.AttachToOwner(Table);Table.Items[4]=item;
        CaelumContaminationStorage.Set(Table,43);Table.RefreshDisplays();
        Check(Table.Items[4].Owner==Table,"saved food is genuinely table-owned");
    }
    void Resume(CaelumPlayer u)
    {
        Profile(u);Check(Chair!=null && Bed!=null && Table!=null,"native save/hub retains original furniture references");
        Check(Table.Items[4]!=null && Table.Items[4].Owner==Table && Table.Items[4].Amount==1,"saved item retained once");
        Check(Table.HasSeatLayout(6),"saved six-seat ownership survives");
        int n=0;let it=ThinkerIterator.Create('CaelumLuxuryTable');while(it.Next()!=null)n++;
        Check(n==1,"save/hub does not duplicate table");
        Check(CaelumContaminationStorage.Value(Table)>40,"save/hub preserves existing furniture contamination");
    }
    void View(CaelumPlayer u,int kind)
    {
        Profile(u);if(kind==0){u.SetOrigin((-300,-55,0),false);u.Angle=42;u.Pitch=24;}
        if(kind==1){u.SetOrigin((75,-110,0),false);u.Angle=45;u.Pitch=2;}
        if(kind==2){u.SetOrigin((-190,120,0),false);u.Angle=45;u.Pitch=12;}
        if(kind==3){Approach(u,Chair);CaelumRestState.Begin(u,Chair.RestMode(),480,Chair);}
        if(kind==4){Approach(u,Bed);CaelumRestState.Begin(u,Bed.RestMode(),480,Bed);}
        if(kind==5)
        {
            for(int i=0;i<18;i++)
            {let item=CaelumConsumableItem(Actor.Spawn('CaelumFoodRation',Table.Pos));item.Amount=1;item.AttachToOwner(Table);Table.Items[i]=item;}
            Table.RefreshDisplays();u.SetOrigin((-110,204,0),false);u.Angle=46;u.Pitch=20;
        }
        u.FindFloorCeiling();Check(u.TestMobjLocation(),"native inspection camera has clearance");
    }
    void Migration(CaelumPlayer u)
    {
        Profile(u);let reading=CaelumRecipeSession.Get(u);
        Check(reading!=null && reading.Active && reading.Book!=null && Near(reading.RemainingSeconds,321.75),"original library task retains its precise progress");
        let table=CaelumDiningWorld.Find(105);Check(table!=null && table.HasSeatLayout(6),"accepted mansion dining layout survives migration");
        Check(ThinkerIterator.Create('CaelumLuxuryTable').Next()==null,"loading an old campaign does not replace or duplicate its furniture");
    }
    void Transactions(CaelumPlayer u)
    {
        Profile(u);u.SetOrigin(Table.LocalPoint(0,-Table.WidthMU()/2-48),false);u.FindFloorCeiling();
        Check(Table.CanReach(u),"normal table interaction is reachable");
        let ration=CaelumConsumableItem(u.GiveInventoryType('CaelumFoodRation'));ration.Amount=2;ration.InMagicBox=false;
        Check(Table.PlaceItem(u,false),"production deposit accepts a carried food unit");
        Check(ration.Amount==1 && ration.Owner==u && Table.Items[0]!=null && Table.Items[0].Owner==Table
            && Table.Items[0].Amount==1,"deposit transfers one unit without duplicating the carried stack");
        Check(Table.Withdraw(u,false),"production withdrawal returns the real food unit");
        int food=0;for(Inventory item=u.Inv;item!=null;item=item.Inv)if(item is 'CaelumFoodRation')food+=item.Amount;
        Check(food==2 && Table.Items[0]==null,"withdrawal restores exact inventory quantity");
        let canteen=CaelumWaterContainer(u.GiveInventoryType('CaelumCanteenLarge'));
        canteen.InMagicBox=false;canteen.AddWater(3.3,CaelumWaterQuality.POTABLE);
        double liters=canteen.WaterLiters;
        Check(Table.PlaceItem(u,true),"production deposit accepts the actual water vessel");
        Check(Table.Items[0]==canteen && canteen.Owner==Table && Near(canteen.WaterLiters,liters),"water deposit retains identity and real liters");
        Check(Table.Withdraw(u,true),"production withdrawal returns the water vessel");
        Check(canteen.Owner==u && Near(canteen.WaterLiters,liters) && Table.Items[0]==null,"water withdrawal neither fills nor clones the vessel");
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        bool handled=true;
        if(e.Name=='ca410lx_setup')Setup(u);
        else if(e.Name=='ca410lx_core')Core(u);
        else if(e.Name=='ca410lx_seed')Seed(u);
        else if(e.Name=='ca410lx_resume')Resume(u);
        else if(e.Name=='ca410lx_view')View(u,e.Args[0]);
        else if(e.Name=='ca410lx_migration')Migration(u);
        else if(e.Name=='ca410lx_transactions')Transactions(u);
        else if(e.Name=='ca410lx_spanish')
        {
            Check(StringTable.Localize("CA_LUXURY_CHAIR",false)=="Sillón de lujo","Spanish armchair title is accented and localized");
            Check(StringTable.Localize("CA_LUXURY_BED",false)=="Cama de lujo","Spanish bed title is localized");
            Check(StringTable.Localize("CA_LUXURY_TABLE",false)=="Mesa de lujo","Spanish table title is localized");
            View(u,0);
        }
        else if(e.Name=='ca410lx_input')
        {
            if(e.Args[0]==0){Profile(u);Approach(u,Chair);}
            else {let guide=CaelumRestGuide(ThinkerIterator.Create('CaelumRestGuide').Next());Check(guide!=null && guide.Subject==u,"real Use input opens this luxury chair");}
        }
        else handled=false;
        if(handled)Console.Printf("CA410LX RESULT passed=%d failed=%d",Passed,Failed);
    }
}
