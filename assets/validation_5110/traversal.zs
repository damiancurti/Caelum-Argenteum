class CA154Traversal : StaticEventHandler
{
    int Elapsed,Point,Stage;
    bool Done;
    double Distance,Rise,StartHeat,StartMass,Efficiency,StartHP;
    vector3 Previous;
    override void WorldLoaded(WorldEvent e){Elapsed=0;Point=2;Done=false;}
    override void WorldTick()
    {
        Elapsed++;let u=CaelumPlayer(players[0].mo);if(u==null || u.DerivedStats==null)return;
        Stage=CVar.GetCVar("ca154_stage").GetInt();
        let thermal=CaelumThermalBody.Get(u,true);
        if(Elapsed==20)
        {
            u.InitializeDirectMapCharacter();u.bNOTARGET=true;u.bNoGravity=false;
            u.CurrentHunger=100;u.CurrentThirst=100;u.CurrentSleep=100;
            u.CurrentAir=u.DerivedStats.MaximumAir;u.health=u.CaelumMaximumHealth;u.player.health=u.health;
            thermal.Exposure=0;thermal.ActivityJoules=0;thermal.PendingActivityJoules=0;
            CaelumThermalBody.Refresh(u,thermal);StartHeat=0;StartMass=thermal.MovedMassKg;Efficiency=thermal.MuscularEfficiency;StartHP=u.health;
            if(level.MapName=="MAP01"){u.SetOrigin((1360,0,0),false);u.Angle=90;}
            if(level.MapName=="MAP01" && Stage==2){u.SetOrigin((3000,0,-100),false);u.Angle=180;}
            if(level.MapName=="MAP02"){u.SetOrigin((0,0,-160),false);u.Angle=0;}
            u.Vel=(0,0,0);Previous=u.Pos;
            Console.Printf("CA154 TRAVERSAL setup map=%s mass=%.6f eta=%.9f gravity=%.9f",level.MapName,StartMass,Efficiency,u.GetGravity());
        }
        if(Elapsed<=20)return;
        if(level.MapName=="MAP01" && Stage==2)
        {
            if(Elapsed%70==0)Console.Printf("CA154 POOL tic=%d pos=%.6f,%.6f,%.6f water=%d workHeat=%.9f HP=%d",Elapsed,u.Pos.X,u.Pos.Y,u.Pos.Z,u.WaterLevel,thermal.ActivityJoules+thermal.PendingActivityJoules,u.health);
            if(Elapsed==850)Console.Printf("CA154 POOL %s exitX=%.6f z=%.6f water=%d HP=%d",u.Pos.X<2350 && u.Pos.Z>=0 && u.WaterLevel==0 && u.health==StartHP ? "PASS" : "FAIL",u.Pos.X,u.Pos.Z,u.WaterLevel,u.health);
            return;
        }
        if(level.MapName=="MAP01" && !Done)
        {
            Distance+=(u.Pos.XY-Previous.XY).Length();Rise+=Max(0.0,u.Pos.Z-Previous.Z);Previous=u.Pos;
            vector3 goals[]={(1360,260,136),(1456,260,136),(1600,260,136),(1600,0,136),(1848,0,136),(1848,344,136),(1750,344,136),(1750,0,264),(1600,0,264),(1200,0,264)};
            vector3 goal=goals[Point-2];vector2 offset=goal.XY-u.Pos.XY;
            if(offset.Length()<18 && Abs(u.Pos.Z-goal.Z)<20)
            {
                Console.Printf("CA154 TRAVERSAL waypoint=%d pos=%.6f,%.6f,%.6f HP=%d",Point,u.Pos.X,u.Pos.Y,u.Pos.Z,u.health);
                Point++;if(Point==12)
                {
                    Done=true;
                    double measured=thermal.ActivityJoules+thermal.PendingActivityJoules;
                    double expected=(StartMass*0.5025*Distance/32+StartMass*9.81*Rise/32)*(1/Efficiency-1);
                    Console.Printf("CA154 STAIRS %s nativePath=1 height=%.6f distance=%.6f rise=%.6f heat=%.9f predicted=%.9f HP=%d",u.Pos.Z>=264 && u.health==StartHP && Abs(measured-expected)<expected*0.025 ? "PASS" : "FAIL",u.Pos.Z,Distance/32,Rise/32,measured,expected,u.health);
                    return;
                }
                goal=goals[Point-2];offset=goal.XY-u.Pos.XY;
            }
            u.Angle=VectorAngle(offset.X,offset.Y);
            let doors=ThinkerIterator.Create("CaelumSlidingDoorLeaf");CaelumSlidingDoorLeaf door;
            while((door=CaelumSlidingDoorLeaf(doors.Next()))!=null)
                if(door.args[3]==0 && Abs(door.Pos.Z-u.Pos.Z)<32 && u.Distance2D(door)<100)door.RequestDoorGroup(u);
        }
        if(level.MapName=="MAP02")
        {
            if(Elapsed==40)
            {
                let lift=CaelumMazeReturnElevator(ActorIterator.Create(CaelumMazeLayout.RETURN_ELEVATOR_TAG,"CaelumMazeReturnElevator").Next());
                Console.Printf("CA154 ELEVATOR call=%d floor=%.9f playerZ=%.9f",lift!=null && lift.Call(u),u.floorz,u.Pos.Z);
            }
            if(Elapsed==180)
            {
                Console.Printf("CA154 ELEVATOR_DOWN %s z=%.6f floor=%.6f heat=%.9f HP=%d",Abs(u.Pos.Z+160)<0.01 && thermal.ActivityJoules+thermal.PendingActivityJoules==0 && u.health==StartHP ? "PASS" : "FAIL",u.Pos.Z,u.floorz,thermal.ActivityJoules+thermal.PendingActivityJoules,u.health);
                Done=true;
            }
            if(Elapsed==200)
            {let lift=CaelumMazeReturnElevator(ActorIterator.Create(CaelumMazeLayout.RETURN_ELEVATOR_TAG,"CaelumMazeReturnElevator").Next());lift.Call(u);}
            if(Elapsed==350)
                Console.Printf("CA154 ELEVATOR_UP %s z=%.6f heat=%.9f HP=%d",Abs(u.Pos.Z)<0.01 && thermal.ActivityJoules+thermal.PendingActivityJoules==0 && u.health==StartHP ? "PASS" : "FAIL",u.Pos.Z,thermal.ActivityJoules+thermal.PendingActivityJoules,u.health);
        }
        if(Elapsed==1600)Console.Printf("CA154 TRAVERSAL %s map=%s waypoint=%d pos=%.6f,%.6f,%.6f",Done ? "COMPLETE" : "FAIL",level.MapName,Point,u.Pos.X,u.Pos.Y,u.Pos.Z);
    }
}
