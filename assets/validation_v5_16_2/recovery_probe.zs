// #454: consultas nativas de los seis retornos y ciclo real de la plataforma.
class CA454RecoveryBody : Actor
{
    Default { Radius 1; Height 1; +NOGRAVITY +THRUACTORS }
    States { Spawn: TNT1 A -1; Stop; }
}
class CA454RecoveryProbe : EventHandler
{
    CaelumPlayer User;
    int Phase,Age;
    bool Started,Done;

    bool BranchesFit()
    {
        let probe=Actor.Spawn("CA454RecoveryBody",CA454RecoveryData.Point(0,0),NO_REPLACE);
        if(probe==null)return false;
        probe.A_SetSize(CA454RecoveryData.RADIUS,CA454RecoveryData.HEIGHT);
        bool ok=true;
        for(int route=0;route<CA454RecoveryData.COUNT && ok;route++)
        {
            probe.SetOrigin(CA454RecoveryData.Point(route,0),false);
            for(int segment=1;segment<CA454RecoveryData.PointCount(route) && ok;segment++)
            {
                vector3 from=probe.Pos,to=CA454RecoveryData.Point(route,segment);
                int steps=Max(1,int(Ceil((to.XY-from.XY).Length()/CA454RecoveryData.STEP)));
                for(int index=1;index<=steps && ok;index++)
                {
                    vector3 point=from+(to-from)*index/steps;
                    FCheckPosition fit;
                    ok=probe.CheckPosition(point.XY,false,fit)
                        && fit.ceilingz-fit.floorz>=probe.Height
                        && Abs(fit.floorz-CA454RecoveryData.FLOOR)<1;
                    if(ok)probe.SetOrigin(point,false);
                    else Console.Printf("CA454 RECOVERY blocked route=%d segment=%d point=(%.1f,%.1f,%.1f) floor=%.1f ceiling=%.1f",
                        route,segment,point.X,point.Y,point.Z,fit.floorz,fit.ceilingz);
                }
            }
            Console.Printf("CA454 RECOVERY route=%d %s",route,ok?"PASS":"FAIL");
        }
        probe.Destroy();return ok;
    }

    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="ca454_recovery_report"){if(!Done)Fail("timeout");return;}
        if(e.Name!="ca454_probe" || Started)return;
        User=CaelumPlayerAuthority.FromNetworkPlayer(e.Player);
        if(User==null || !CaelumMazeLayout.IsRedesigned()){Fail("setup");return;}
        User.bInvulnerable=true;
        let record=User.GetPersistentCharacterState(true);record.DemoNarrativeDelivered=2047;record.DemoNarrativePending=0;
        Started=true;OpenNext();
    }

    void OpenNext()
    {
        for(int index=Phase;index<4;index++)
        {
            let gate=CaelumMazeReturnGrate(ActorIterator.Create(44910+index,"CaelumMazeReturnGrate").Next());
            if(gate==null || gate.Opened){Fail("grates not independent");return;}
        }
        User.SetOrigin(CA454RecoveryData.Exterior(Phase),false);User.FindFloorCeiling();User.Vel=(0,0,0);
        let current=CaelumMazeReturnGrate(ActorIterator.Create(44910+Phase,"CaelumMazeReturnGrate").Next());
        if(current==null || !current.UseReturn(User)){Fail("keyless exterior opening");return;}
        Console.Printf("CA454 RECOVERY grate=%d opened",Phase);Age=0;
    }

    override void WorldTick()
    {
        if(!Started || Done)return;
        Age++;if(Age<(Phase>=4?CA454RecoveryData.TRAVEL_TICS:70))return;
        if(Phase<4)
        {
            Phase++;
            if(Phase<4){OpenNext();return;}
            User.SetOrigin(CA454RecoveryData.Exterior(0),false);User.FindFloorCeiling();User.Vel=(0,0,0);
            let grate=CaelumMazeReturnGrate(ActorIterator.Create(44910,"CaelumMazeReturnGrate").Next());
            if(grate==null || !grate.UseReturn(User)){Fail("call lower landing");return;}
            Age=0;return;
        }
        if(Phase==4)
        {
            // Los trazos de construcción atraviesan también el recinto de la
            // plataforma: comprobarlos después de abrir sus rejas y bajarla.
            if(!BranchesFit()){Fail("branch geometry with opened grates");return;}
            let lift=CaelumMazeReturnElevator(ActorIterator.Create(CaelumMazeLayout.RETURN_ELEVATOR_TAG,"CaelumMazeReturnElevator").Next());
            User.SetOrigin((0,0,CA454RecoveryData.FLOOR),false);User.FindFloorCeiling();User.Vel=(0,0,0);
            if(Abs(User.FloorZ-CA454RecoveryData.FLOOR)>1 || lift==null || !lift.Call(User)){Fail("lower landing/platform activation");return;}
            Phase=5;Age=0;return;
        }
        if(Abs(User.Pos.Z)>1 || Abs(User.FloorZ)>1)
        {
            Console.Printf("CA454 RECOVERY landing z=%.1f floor=%.1f age=%d",User.Pos.Z,User.FloorZ,Age);
            Fail("platform did not carry player to upper floor");return;
        }
        Done=true;Console.Printf("CA454 RECOVERY PASS six_branches four_grates native_lift z=%.1f",User.Pos.Z);
        Console.Printf("CA454 NATIVE PASS map=MAP02");
    }

    void Fail(String reason){Done=true;Console.Printf("CA454 NATIVE FAIL map=MAP02 reason=%s",reason);}
}
