// Isolated fixture: diagnostic positions and timings are not gameplay data.
class CA318NativeBody : Actor
{
    int TeleportAt;
    vector3 Destination;
    override void Tick()
    {
        Super.Tick();
        if(TeleportAt>0 && level.time>=TeleportAt)
        {SetOrigin(Destination,false);Vel=(0,0,0);TeleportAt=0;}
    }
    Default { Radius 16; Height 56; Health 1000; +SOLID +SHOOTABLE +NOGRAVITY +CANNOTPUSH +DONTTHRUST }
    States { Spawn: TNT1 A -1; Stop; }
}
class CA318NativeDoorChecks : EventHandler
{
    CaelumPlayer User;
    CaelumHingedDoorLeaf Door;
    Actor Body;
    int Start,Failures,Checks;
    bool Started;
    int AlignmentSamples;
    double MaxDrift,MaxSpeed;
    vector3 Obstruction;
    override bool InputProcess(InputEvent e){return true;}
    override void UiTick(){if(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();}
    void Check(bool ok,String label)
    {Checks++;if(!ok)Failures++;Console.Printf("CA318 %s %s",ok?"PASS":"FAIL",label);}
    CaelumHingedDoorLeaf Leaf(int id){return CaelumPolyDoorEvents.Get().Leaves[id];}
    void PositionUser(int pair,bool opposite=false)
    {
        vector3 p=(pair*512,0,0);double side=opposite?200:-200;
        if(pair%2==0)p.Y+=side;else p.X+=side;
        User.SetOrigin(p,false);User.Vel=(0,0,0);User.Angle=pair%2==0?(opposite?270:90):(opposite?180:0);
    }
    void Fits(vector3 p,bool expected,String label)
    {Body.SetOrigin(p,false);Check(Body.TestMobjLocation()==expected,label);Body.SetOrigin((-300,300,0),false);}
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="doors_begin")
        {
            User=CaelumPlayer(players[0].mo);User.CharacterCreationComplete=true;
            User.CreationWizardOpen=false;User.ApplyCharacterProfile();User.bInvulnerable=true;
            Body=Actor.Spawn("CA318NativeBody",(-300,300,0));Door=Leaf(1);
            Check(ThinkerIterator.Create("CaelumSlidingDoorBlocker").Next()==null,"No legacy collision actors");
            for(int id=1;id<=8;id++)
            {
                let leaf=Leaf(id);Check(leaf!=null && leaf.NativeFaces.Size()==4 && leaf.NativeReferenceLine!=null,"Native leaf registered");
                for(int f=0;f<leaf.NativeFaces.Size();f++)
                {
                    bool valid;double top,bottom;[valid,top,bottom]=leaf.NativeFaces[f].GetMidTexturePosition(0);
                    Check(valid && top==120 && bottom==0,"Invisible collision has finite height");
                }
            }
            Fits((0,0,0),false,"Closed pair blocks walking body");Fits((0,0,184),true,"Closed pair permits roof flight");
            PositionUser(0);Check(Door.RequestDoorGroup(User),"Front request accepted");
            Start=level.time;Started=true;
        }
        if(e.Name=="doors_touch" || e.Name=="doors_touch_back")
        {
            Check(Door.SlideProgress==0,"Touch test starts with closed door");
            bool back=e.Name=="doors_touch_back";
            // Aim outside the visual actor's radius: only the native line can handle Use.
            User.SetOrigin((-16,(back?1:-1)*(User.Radius+4),0),false);User.Vel=(0,0,0);User.Angle=back?270:90;User.Pitch=0;
        }
        if(e.Name=="doors_touch_check")
        {Check(Door.SlideProgress==64,"Native use opens while player touches closed face");PositionUser(0);}
        if(e.Name=="doors_saved")
        {Check(Door.NativeMotion!=null && Door.SlideProgress>0 && Door.SlideProgress<64,"Save captures active native motion");Console.Printf("CA318 DONE failures=%d checks=%d",Failures,Checks);}
        if(e.Name=="doors_done")
        {Check(AlignmentSamples>5000,"Observed native and visual alignment throughout motion");Console.Printf("CA318 DONE failures=%d checks=%d max_body_drift=%.6f max_body_speed=%.6f",Failures,Checks,MaxDrift,MaxSpeed);}
    }
    override void WorldTick()
    {
        if(!Started)return;int age=level.time-Start;
        // Observe completed native actions before the next tick's guard.
        for(int id=1;id<=8;id++)
        {
            let leaf=Leaf(id);int actual=CaelumPolyDoors.Progress(leaf);
            vector3 expected=leaf.PositionAt(actual,0);
            double expectedAngle=(leaf.args[2]==0?0:90)+(leaf.args[1]>0?180:0)-leaf.args[1]*leaf.SwingSide*90.0*actual/64;
            double angleError=leaf.Angle-expectedAngle;
            while(angleError>180)angleError-=360;while(angleError< -180)angleError+=360;
            AlignmentSamples++;
            if(actual!=leaf.SlideProgress || (leaf.Pos-expected).Length()>0.01 || Abs(angleError)>0.001)
            {Check(false,"Native collision and visual model align");Console.Printf("CA318 ALIGN age=%d id=%d actual=%d visual=%d pos=(%.3f,%.3f,%.3f) expected=(%.3f,%.3f,%.3f) floor=%.3f velz=%.3f",age,id,actual,leaf.SlideProgress,leaf.Pos.X,leaf.Pos.Y,leaf.Pos.Z,expected.X,expected.Y,expected.Z,leaf.floorz,leaf.Vel.Z);}
        }
        if(age==20)
        {Check(Door.SlideProgress==64 && Leaf(2).SlideProgress==64,"Both leaves open in sixteen movement tics");Fits((0,0,0),true,"Open pair clears doorway");Check(Door.RequestDoorGroup(User),"Use refreshes open hold");Check(Door.HoldTimer==105,"Hold reset to existing duration");}
        if(age==145)Check(Door.SlideProgress==0 && Leaf(2).SlideProgress==0 && Door.NativeMotion==null,"Pair closes and retires motion guard");
        if(age==150)
        {PositionUser(0,true);Check(Door.RequestDoorGroup(User),"Opposite request accepted");Check(Door.SwingSide==-1 && Leaf(2).SwingSide==-1,"Both leaves swing away from opposite side");}
        if(age==170)Check(Door.SlideProgress==64,"Opposite swing fully opens");
        if(age==280)
        {Check(Door.NativeMotion!=null && Door.NativeMotion.Closing,"Closing state observed");Check(Door.RequestDoorGroup(User),"Request reverses a closing pair");}
        if(age==305)Check(Door.SlideProgress==64,"Reversed pair reaches fully open");
        if(age==420)
        {
            Check(Door.SlideProgress==0,"Second cycle closes");PositionUser(0);
            Obstruction=(-32,24,0);Body.SetOrigin(Obstruction,false);Body.Vel=(0,0,0);
            Check(Door.RequestDoorGroup(User),"Obstructed opening request accepted");
        }
        if(age>=420 && age<=450)
        {MaxDrift=Max(MaxDrift,(Body.Pos-Obstruction).Length());MaxSpeed=Max(MaxSpeed,Body.Vel.Length());}
        if(age==450)
        {Check(Door.SlideProgress<64,"Solid shootable body arrests opening");Check(MaxDrift<0.001 && MaxSpeed<0.001,"Native motion never pushes obstructing body");Body.SetOrigin((-300,300,0),false);}
        if(age==475)Check(Door.SlideProgress==64,"Removing obstacle resumes opening");
        if(age==480)
        {
            Obstruction=(-32,24,0);
            let mover=CA318NativeBody(Body);mover.Destination=Obstruction;mover.TeleportAt=Start+580;
        }
        if(age>=581 && age<=620)
        {MaxDrift=Max(MaxDrift,(Body.Pos-Obstruction).Length());MaxSpeed=Max(MaxSpeed,Body.Vel.Length());}
        if(age==620)
        {Check(MaxDrift<0.001 && MaxSpeed<0.001,"Closing collision does not push or damage body");Check(Body.health==1000,"Obstruction takes no crushing damage");Body.SetOrigin((-300,300,0),false);}
        if(age==630)
        {
            for(int pair=1;pair<4;pair++)
            {PositionUser(pair,pair>=2);Check(Leaf(pair*2+1).RequestDoorGroup(User),"Other axis and side request accepted");}
        }
        if(age==655)
        {
            for(int pair=1;pair<4;pair++)Check(Leaf(pair*2+1).SlideProgress==64 && Leaf(pair*2+2).SlideProgress==64,"Other axis and side open together");
            PositionUser(1);User.SetOrigin(User.Pos+(0,0,184),false);Check(!Leaf(3).RequestDoorGroup(User),"Roof-level use cannot operate lower door");
        }
    }
}
