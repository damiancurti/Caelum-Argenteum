// Recorridos físicos aislados: mismo cuerpo y escalón del defensor, sin su IA.
class CA454FortWalker : Actor
{
    int GunIndex, CrewSlot, StepIndex, Age, Stalled;
    bool Running, Finished, Failed;
    Default { +SOLID +THRUACTORS }
    States { Spawn: TNT1 A -1; Stop; }
    void Begin(int index,int slot)
    {
        GunIndex=index;CrewSlot=slot;StepIndex=1;Running=true;
        A_SetSize(GetDefaultByType("CaelumPlayer").Radius,CaelumPortData.DEFENDER_HEIGHT);
        MaxStepHeight=GetDefaultByType("CaelumPortDefender").MaxStepHeight;
        SetOrigin(CA454FortData.Route(index,0),false);
    }
    override void Tick()
    {
        Super.Tick();if(!Running || Finished)return;Age++;
        if(Age>2100){Failed=true;Finished=true;return;}
        int count=CA454FortData.Count(GunIndex);
        if(StepIndex>=count+2){Finished=true;return;}
        vector3 next;
        if(StepIndex<count)next=CA454FortData.Route(GunIndex,StepIndex);
        else
        {
            vector3 gun=CA454FortData.Gun(GunIndex);
            vector3 station=gun+CaelumPortData.OperatorOffset(GunIndex+6,CrewSlot);
            next=station;
            if(StepIndex==count)
            {
                vector3 last=CA454FortData.Route(GunIndex,count-1);
                if(station.X!=gun.X)next.Y=last.Y;else next.X=last.X;
                next.Z=last.Z;
            }
        }
        vector2 delta=next.XY-Pos.XY;
        if(delta.Length()<2 && Abs(next.Z-Pos.Z)<1){StepIndex++;Stalled=0;return;}
        if(delta.Length()>0.1)
        {
            vector2 move=delta.Unit()*Min(8,delta.Length());
            if(!TryMove(Pos.XY+move,true))Stalled++;else Stalled=0;
        }
        if(Stalled>35){Failed=true;Finished=true;}
        if(Failed)Console.Printf("CA454 FORT WALK FAIL gun=%d step=%d pos=(%.1f,%.1f,%.1f) next=(%.1f,%.1f,%.1f)",GunIndex,StepIndex,Pos.X,Pos.Y,Pos.Z,next.X,next.Y,next.Z);
    }
}
class CA454FortProbe : EventHandler
{
    Array<CA454FortWalker> Walkers;
    bool Started, Reported;
    int Failures;
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="ca454_view_nw" || e.Name=="ca454_view_east")
        {
            int index=e.Name=="ca454_view_nw"?8:30;
            let user=players[0].mo;vector3 target=CA454FortData.Gun(index);
            user.bNoGravity=true;user.Vel=(0,0,0);
            double normal=index==8?135:0;
            user.SetOrigin(target+(cos(normal)*512,sin(normal)*512,256),false);
            vector3 delta=target-user.Pos-(0,0,56);
            user.Angle=VectorAngle(delta.X,delta.Y);user.Pitch=-VectorAngle(delta.XY.Length(),delta.Z);
            user.ClearInterpolation();return;
        }
        if((e.Name!="ca454_forts" && e.Name!="ca454_forts_views") || Started)return;Started=true;
        let fit=Actor.Spawn("CA454FortWalker",(0,0,0),NO_REPLACE);
        fit.A_SetSize(GetDefaultByType("CaelumPlayer").Radius,CaelumPortData.DEFENDER_HEIGHT);
        int points=0;
        for(int gun=0;gun<36;gun++)for(int step=0;step<CA454FortData.Count(gun);step++)
        {
            vector3 point=CA454FortData.Route(gun,step);fit.SetOrigin(point,false);fit.FindFloorCeiling();
            FCheckPosition check;points++;
            bool ok=fit.CheckPosition(point.XY,false,check) && Abs(check.floorz-point.Z)<1 && check.ceilingz-point.Z>=fit.Height;
            if(!ok){Failures++;Console.Printf("CA454 FORT FIT FAIL gun=%d step=%d z=%.1f floor=%.1f ceiling=%.1f",gun,step,point.Z,check.floorz,check.ceilingz);}
        }
        for(int i=0;i<528;i++)
        {
            vector3 point=CA454FortData.Guard(i);fit.SetOrigin(point,false);fit.FindFloorCeiling();FCheckPosition check;
            bool ok=fit.CheckPosition(point.XY,false,check) && check.floorz==0 && check.ceilingz>=fit.Height;
            if(!ok){Failures++;Console.Printf("CA454 FORT GUARD FAIL id=%d floor=%.1f ceiling=%.1f",i,check.floorz,check.ceilingz);}
        }
        for(int i=0;i<36;i++)for(int slot=0;slot<2;slot++)
        {
            vector3 point=CA454FortData.Gun(i)+CaelumPortData.OperatorOffset(i+6,slot);
            fit.SetOrigin(point,false);fit.FindFloorCeiling();FCheckPosition check;
            bool ok=fit.CheckPosition(point.XY,false,check) && Abs(check.floorz-point.Z)<1 && check.ceilingz-point.Z>=fit.Height;
            if(!ok){Failures++;Console.Printf("CA454 FORT OPERATOR FAIL gun=%d slot=%d floor=%.1f ceiling=%.1f",i,slot,check.floorz,check.ceilingz);}
        }
        int components=0;
        for(int i=0;i<36;i++)
        {
            let gun=CaelumCannon(Actor.Spawn("CaelumCannon",CA454FortData.Gun(i),NO_REPLACE));
            gun.Angle=CA454FortData.Angle(i);gun.InitializeCannon(true);
            for(int j=0;j<gun.Blocks.Size();j++)
            {
                let block=gun.Blocks[j];fit.A_SetSize(block.Radius,block.Height);
                fit.SetOrigin(block.Pos,false);fit.FindFloorCeiling();FCheckPosition check;components++;
                bool ok=fit.CheckPosition(block.Pos.XY,false,check) && check.floorz<=block.Pos.Z && check.ceilingz-block.Pos.Z>=fit.Height;
                if(j<12)ok=ok && Abs(check.floorz-block.Pos.Z)<1;
                if(!ok){Failures++;Console.Printf("CA454 FORT CANNON FAIL gun=%d block=%d z=%.1f floor=%.1f ceiling=%.1f",i,j,block.Pos.Z,check.floorz,check.ceilingz);}
            }
        }
        fit.Destroy();
        Console.Printf("CA454 FORT FIT points=%d guards=528 operators=72 components=%d failures=%d",points,components,Failures);
        if(e.Name=="ca454_forts_views"){Reported=true;return;}
        for(int gun=0;gun<36;gun++)for(int slot=0;slot<2;slot++)
        {
            let body=CA454FortWalker(Actor.Spawn("CA454FortWalker",CA454FortData.Route(gun,0),NO_REPLACE));
            body.Begin(gun,slot);Walkers.Push(body);
        }
    }
    override void WorldTick()
    {
        if(!Started || Reported)return;int complete=0,failed=0;
        for(int i=0;i<Walkers.Size();i++)
        {
            if(!Walkers[i].Finished)return;
            if(Walkers[i].Failed)failed++;else complete++;
        }
        Reported=true;
        Console.Printf("CA454 FORT %s walked=%d failed=%d fit_failures=%d",failed==0 && Failures==0?"PASS":"FAIL",complete,failed,Failures);
    }
}
