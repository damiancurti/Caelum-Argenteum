class CA410MBChecks : CA410FoodChecks
{
    double SavedWater,SavedStamp;
    void Result(){Console.Printf("CA410F RESULT mansion-bathrooms passed=%d failed=%d",Passed,Failed);}
    void Position(CaelumPlayer u,CaelumDomesticFixture f)
    {
        double side=f.Pos.Y>0?1:-1;
        vector3 offset=f.Kind()==0?(-64,0,0):(0,side*64,0);
        u.SetOrigin(f.Pos+offset,false);u.FindFloorCeiling();u.Vel=(0,0,0);
        u.Angle=f.Kind()==0?0:side>0?270:90;u.Pitch=ATan2(u.ViewHeight-f.Height/2,64);
    }
    void Rooms(CaelumPlayer u)
    {
        Setup(u);u.CurrentHunger=100;
        Check(CaelumMansionBathrooms.Prepare(),"mansion installs all twelve fixtures");
        let room=CaelumMansionBathrooms.Find();
        Check(room!=null && room.Revision==1,"revisioned map-owned installation exists");if(room==null){Result();return;}
        for(int i=0;i<CaelumMansionBathroomData.COUNT;i++)
        {
            let f=room.Fixtures[i];Check(f!=null,String.Format("fixture %d exists",i));if(f==null)continue;
            Check(f.Installed && f.House==CaelumDomesticWaterData.MANSION && Near(f.Pos.Z,136)
                && Near(f.FloorZ,136),String.Format("fixture %d is assigned to mansion on actual first floor",i));
            Check(f.TestMobjLocation() && f.ClearOfActors(f),String.Format("fixture %d volume is unobstructed",i));
            Position(u,f);Check(u.TestMobjLocation() && f.ClearOfActors(u),String.Format("fixture %d has clear approach",i));
            Check(f.CanReach(u) && CaelumUseGeometry.AimedAt(u,f),String.Format("fixture %d has native aimed reach",i));
            if(f.SuppliesWater())Check(CaelumDomesticFixture.SourceFor(u)==f,String.Format("fixture %d appears as actual water source",i));
            if(f.Kind()>0)
            {
                Check(CaelumHygienePose.Begin(u,f,f.Kind()==1),String.Format("fixture %d admits hygiene posture",i));
                Check(f.Occupant==u && CaelumHygienePose.Active(u),String.Format("fixture %d owns seated or lying player",i));
                CaelumHygienePose.End(u);
                Check(f.Occupant==null && f.bSolid && u.TestMobjLocation() && f.ClearOfActors(u),String.Format("fixture %d releases player to a clear exit",i));
            }
        }
        let before=room.Fixtures[0];Check(CaelumMansionBathrooms.Prepare() && room.Fixtures[0]==before,"repeated installation retains same actors");
        int count=0;let all=ThinkerIterator.Create('CaelumDomesticFixture');CaelumDomesticFixture f;
        while((f=CaelumDomesticFixture(all.Next()))!=null)if(f.House==CaelumDomesticWaterData.MANSION)count++;
        Check(count==13,"exactly twelve bathroom fixtures and existing kitchen sink, no duplicates");Result();
    }
    void Access(CaelumPlayer u)
    {
        Setup(u);u.CurrentHunger=100;u.SetOrigin((496,0,136),false);
        let room=CaelumMansionBathrooms.Find();if(room==null){Check(false,"mansion bathroom installation required");Result();return;}
        int doors=0;let it=ThinkerIterator.Create('CaelumHingedDoorLeaf');CaelumHingedDoorLeaf door;
        while((door=CaelumHingedDoorLeaf(it.Next()))!=null)
        {
            if(Abs(door.ClosedPosition.Z-136)>1)continue;
            doors++;bool clear=true;
            for(int step=0;step<=64;step++)for(int offset=-32;offset<=32;offset+=4)
            {
                vector3 point=door.PositionAt(step,offset);
                for(int i=0;i<CaelumMansionBathroomData.COUNT;i++)
                {
                    let f=room.Fixtures[i];if(f==null)continue;
                    if(Abs(f.Pos.X-point.X)<f.Radius+4 && Abs(f.Pos.Y-point.Y)<f.Radius+4)clear=false;
                }
            }
            Check(clear,String.Format("bedroom door group %d full swept leaf stays clear of fixtures",door.args[0]));
        }
        Check(doors>0,"actual first-floor mansion doors inspected");
        for(int id=101;id<=104;id++)
        {
            let table=CaelumDiningWorld.Find(id);let bed=CaelumRestFurnitureTrial.Find(id);
            if(table!=null && !table.LayoutFits())
            {
                for(int j=0;j<CaelumMansionBathroomData.COUNT;j++)room.Fixtures[j].bSolid=false;
                Console.Printf("CA410F BASELINE table%d without-fixtures=%d pos=(%.1f,%.1f,%.1f) floor=%.1f",id,table.LayoutFits(),table.Pos.X,table.Pos.Y,table.Pos.Z,table.FloorZ);
                for(int j=0;j<table.SeatCount();j++)if(table.Chairs[j]!=null)
                    Console.Printf("CA410F CHAIR %d/%d fits=%d pos=(%.1f,%.1f,%.1f) floor=%.1f",id,j,table.Chairs[j].TestMobjLocation(),table.Chairs[j].Pos.X,table.Chairs[j].Pos.Y,table.Chairs[j].Pos.Z,table.Chairs[j].FloorZ);
                for(int j=0;j<CaelumMansionBathroomData.COUNT;j++)room.Fixtures[j].bSolid=true;
            }
            Check(table!=null && table.LayoutFits(),String.Format("existing bedroom table %d and chairs retain clear layout",id));
            Check(bed!=null && bed.TestMobjLocation(),String.Format("existing bedroom bed %d retains clear volume",id));
        }
        let f=room.Fixtures[0];vector3 position=f.Pos;f.Destroy();room.Fixtures[0]=null;
        let blocker=Actor.Spawn('CA410BathroomBlocker',position,NO_REPLACE);
        Check(!CaelumMansionBathrooms.Prepare() && room.Fixtures[0]==null,"occupied placement waits without retaining overlapping fixture");
        Check(room.Fixtures[1]!=null && room.Fixtures[11]!=null,"retry preserves other completed placements");
        blocker.Destroy();Check(CaelumMansionBathrooms.Prepare() && room.Fixtures[0]!=null,"cleared placement completes on retry");
        Result();
    }
    void Shared(CaelumPlayer u)
    {
        Setup(u);u.CurrentHunger=100;u.CloseCraftingStationSession();u.SetCraftingJournalState(false);
        let room=CaelumMansionBathrooms.Find();Check(room!=null,"real mansion fixtures available");if(room==null){Result();return;}
        let water=CaelumDomesticWater.Get(CaelumDomesticWaterData.MANSION);
        let other=CaelumDomesticWater.Get(0);double otherBefore=other.Liters;
        water.Liters=100;
        let bottle=CaelumWaterContainer(u.GiveInventoryType('CaelumCanteenLarge'));
        bottle.InMagicBox=false;bottle.WaterLiters=0;bottle.WaterQuality=CaelumWaterQuality.POTABLE;
        Position(u,room.Fixtures[0]);double capacity=bottle.GetCapacityLiters();
        Check(room.Fixtures[0].Fill(u,bottle) && Near(water.Liters,100-capacity),"bedroom sink withdraws actual canteen volume");
        let kitchen=CaelumKitchenSink(ThinkerIterator.Create('CaelumKitchenSink').Next());
        Check(kitchen!=null && kitchen.House==room.Fixtures[0].House,"kitchen and bathrooms reference identical reserve");
        let soap=u.CreateDetachedMaterialStack(CaelumHygieneData.SOAP,1,1000);soap.AttachToOwner(u);u.OnNativeInventoryChanged();
        let illness=CaelumFoodIllness.Get(u);illness.Contamination=40;
        Position(u,room.Fixtures[1]);double before=water.Liters,soapBefore=CaelumSoapSupply.Available(u);
        double per=CaelumContaminationRules.BathWaterLiters(1,u.DerivedStats.BaseMass);
        Check(CaelumBathTask.Begin(u,room.Fixtures[1],null,2),"actual bedroom tub starts bath");
        Check(CaelumHygienePose.Active(u) && CaelumHygienePose.Find(u).Lying,"bath uses lying pose");
        CaelumBathTask.Advance(u,20);
        Check(Near(illness.Contamination,38) && Near(water.Liters,before-2*per),"bath removes contamination and spends shared water");
        Check(Near(CaelumSoapSupply.Available(u),soapBefore-2*per*5),"bath spends exact approved soap amount");
        Check(!CaelumBathTask.Active(u) && !CaelumHygienePose.Active(u),"completed bath releases posture");
        Position(u,room.Fixtures[2]);illness.ToiletCapacity=3;before=water.Liters;
        Check(room.Fixtures[2].Used(u) && CaelumHygieneTask.Active(u),"native Use starts mansion toilet");
        Check(CaelumHygienePose.Active(u) && !CaelumHygienePose.Find(u).Lying,"toilet uses seated pose");
        u.CraftingTaskRemainingSeconds=0;u.CompleteCraftingTask();
        Check(Near(illness.Contamination,35) && Near(illness.ToiletCapacity,0) && Near(water.Liters,before-10),"toilet completion commits credit and shared10L once");
        Position(u,room.Fixtures[5]);illness.ToiletCapacity=2;before=water.Liters;
        Check(room.Fixtures[5].Used(u),"other bedroom accesses same toilet supply");
        CaelumHygieneTask.Cancel(u);
        Check(Near(water.Liters,before) && Near(illness.ToiletCapacity,2) && Near(illness.Contamination,35),"cancelled toilet leaves resources unchanged");
        water.Liters=.25;Position(u,room.Fixtures[6]);bottle.WaterLiters=0;
        Check(room.Fixtures[6].Fill(u,bottle) && Near(water.Liters,0) && Near(bottle.WaterLiters,.25),"different bedroom shares finite remainder");
        Position(u,room.Fixtures[9]);Check(!room.Fixtures[9].Fill(u,bottle),"empty supply cannot refill from another bedroom");
        CaelumWorldClock.Get(u).AdvanceTics(CaelumWorldClock.TicsPerHour()/60);
        Check(Near(CaelumDomesticWater.Get(CaelumDomesticWaterData.MANSION).Liters,1),"whole mansion replenishes only1L per world minute");
        Check(Near(CaelumDomesticWater.Get(0).Liters,Min(200,otherBefore+1)),"city-house reserve stays independent");Result();
    }
    void Seed(CaelumPlayer u)
    {Setup(u);u.CurrentHunger=100;let water=CaelumDomesticWater.Get(CaelumDomesticWaterData.MANSION);water.Liters=17;SavedWater=17;SavedStamp=water.Stamp;Check(water!=null,"save fixture retains existing finite mansion reserve");Result();}
    void Resume(CaelumPlayer u)
    {
        Setup(u);u.CurrentHunger=100;let water=CaelumDomesticWater.Get(CaelumDomesticWaterData.MANSION);
        Check(Near(water.Liters,Min(200,SavedWater+(water.Stamp-SavedStamp)/60)) && water.Liters<200,"load or hub return keeps supply plus elapsed refill only");
        Check(CaelumMansionBathrooms.Prepare(),"load or hub return installs or retains fixtures");
        int count=0;let all=ThinkerIterator.Create('CaelumMansionBathrooms');while(all.Next()!=null)count++;
        Check(count==1,"save migration and hub return keep one controller");Result();
    }
    void View(CaelumPlayer u,int room,int pose)
    {
        Setup(u);u.CurrentHunger=100;CaelumHygienePose.Cancel(u);if(u.player.camera!=u)u.player.camera=u;
        let installation=CaelumMansionBathrooms.Find();
        if(installation==null){Check(false,"capture requires completed native installation");Result();return;}
        let f=installation.Fixtures[Clamp(room,0,3)*3+(pose==1?1:pose==2?2:0)];
        if(f==null){Check(false,"capture requires requested fixture");Result();return;}
        Position(u,f);CaelumFoodIllness.Get(u).Contamination=40;CaelumFoodIllness.Get(u).ToiletCapacity=20;
        let soap=u.CreateDetachedMaterialStack(CaelumHygieneData.SOAP,1,500);soap.AttachToOwner(u);
        CaelumDomesticWater.Get(CaelumDomesticWaterData.MANSION).Liters=150;
        if(pose>0)Check(CaelumHygienePose.Begin(u,f,pose==1),"capture uses actual hygiene posture");
        else
        {
            double side=f.Pos.Y>0?1:-1;
            let camera=Actor.Spawn('CA410MansionCamera',(room%2==0?-220:1040,side*408,232),NO_REPLACE);
            vector3 aim=(room%2==0?-300:1040,side*256,160)-camera.Pos;
            camera.Angle=VectorAngle(aim.X,aim.Y);camera.Pitch=-VectorAngle(aim.XY.Length(),aim.Z);u.player.camera=camera;
            Check(camera!=null,"overview camera uses unchanged mansion geometry");
        }
        Result();
    }
    void Manual(CaelumPlayer u,int room)
    {
        Setup(u);u.CurrentHunger=100;u.CurrentThirst=100;
        let installation=CaelumMansionBathrooms.Find();
        if(installation==null){Check(false,"manual setup requires completed native installation");Result();return;}
        let f=installation.Fixtures[Clamp(room,0,3)*3];
        if(f==null){Check(false,"manual setup requires sink");Result();return;}
        Position(u,f);CaelumFoodIllness.Get(u).Contamination=40;CaelumFoodIllness.Get(u).ToiletCapacity=20;
        let soap=u.CreateDetachedMaterialStack(CaelumHygieneData.SOAP,1,500);soap.AttachToOwner(u);
        let bottle=CaelumWaterContainer(u.GiveInventoryType('CaelumCanteenLarge'));bottle.WaterLiters=0;bottle.InMagicBox=false;
        CaelumDomesticWater.Get(CaelumDomesticWaterData.MANSION).Liters=150;
        u.OnNativeInventoryChanged();Check(f.CanReach(u),"manual character has reachable sink and required supplies");
        Console.Printf("CA410F INPUT mansion bathrooms ready");Result();
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=='ca410mb_rooms')Rooms(u);
        else if(e.Name=='ca410mb_access')Access(u);
        else if(e.Name=='ca410mb_shared')Shared(u);
        else if(e.Name=='ca410mb_seed')Seed(u);
        else if(e.Name=='ca410mb_resume')Resume(u);
        else if(e.Name=='ca410mb_away')CaelumWorldClock.Get(u).AdvanceTics(CaelumWorldClock.TicsPerHour()/2);
        else if(e.Name=='ca410mb_view')View(u,e.Args[0],e.Args[1]);
        else if(e.Name=='ca410mb_manual')Manual(u,e.Args[0]);
        else if(e.Name=='ca410mb_turn')
        {let room=CaelumMansionBathrooms.Find();if(room!=null){room.Fixtures[1].Angle=e.Args[0];View(u,0,1);}}
    }
}
class CA410MansionCamera : Actor {Default {+NOGRAVITY +NOINTERACTION} States {Spawn:TNT1 A -1;Stop;}}
class CA410BathroomBlocker : Actor {Default {Radius 16;Height 64;+SOLID +NOGRAVITY} States {Spawn:TNT1 A -1;Stop;}}
