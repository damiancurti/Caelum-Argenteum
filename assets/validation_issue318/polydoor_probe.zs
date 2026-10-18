class CA318PolyBody : Actor
{
    Default { Radius 16; Height 56; +SOLID +NOGRAVITY +CANNOTPUSH +DONTTHRUST }
    States { Spawn: TNT1 A -1; Stop; }
}
class CA318PolyDoorProbe : EventHandler
{
    Actor Body;
    int Start,Failures,Checks;
    bool Started;
    override bool InputProcess(InputEvent e){return true;}
    override void UiTick(){if(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();}
    void Check(bool ok,String label)
    {Checks++;if(!ok)Failures++;Console.Printf("CA318 %s %s",ok?"PASS":"FAIL",label);}
    void Placement(double z)
    {
        Body.SetOrigin((0,0,z),false);
        Console.Printf("CA318 POLY placement z=%.3f fits=%d floor=%.3f ceiling=%.3f",z,Body.TestMobjLocation(),Body.floorz,Body.ceilingz);
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="poly_begin")
        {
            let user=CaelumPlayer(players[0].mo);user.CharacterCreationComplete=true;
            user.CreationWizardOpen=false;user.ApplyCharacterProfile();user.bInvulnerable=true;
            user.SetOrigin((0,-200,0),false);user.Angle=90;user.Pitch=0;
            Body=Actor.Spawn("CA318PolyBody",(0,100,0));
            let it=level.CreateLineIdIterator(10001);int index;
            while((index=it.Next())>=0)
            {
                let line=level.lines[index];bool valid;double top,bottom;
                [valid,top,bottom]=line.GetMidTexturePosition(0);
                Console.Printf("CA318 POLY line=%d a=(%.3f,%.3f) b=(%.3f,%.3f) valid=%d top=%.3f bottom=%.3f",index,line.v1.p.X,line.v1.p.Y,line.v2.p.X,line.v2.p.Y,valid,top,bottom);
                Check(valid && Abs(top-120)<0.001 && Abs(bottom)<0.001,"Native middle texture spans 0 to120");
            }
            Placement(0);Check(!Body.TestMobjLocation(),"Closed native leaf blocks body");
            Placement(119);Placement(120);Placement(121);Placement(184);
            Check(Body.TestMobjLocation(),"Above-roof body passes over finite leaf");
            Body.SetOrigin((0,100,0),false);
            Start=level.time;Started=true;
            Check(Polyobj_RotateRight(1,32,64),"Native rotation starts");
        }
        if(e.Name=="poly_done")Console.Printf("CA318 DONE failures=%d checks=%d",Failures,Checks);
    }
    override void WorldTick()
    {
        if(!Started)return;
        int age=level.time-Start;
        if(age==18)
        {
            Placement(0);Check(Body.TestMobjLocation(),"Open native leaf clears original doorway");
            Body.SetOrigin((0,100,0),false);Check(Polyobj_RotateLeft(1,32,64),"Native close starts");
        }
        if(age==36)
        {
            Placement(0);Check(!Body.TestMobjLocation(),"Native close restores collision");
            Body.SetOrigin((16,24,0),false);Body.Vel=(0,0,0);
            Check(Polyobj_RotateRight(1,32,64),"Obstructed native rotation starts");
        }
        if(age>=36 && age<=60)
            Console.Printf("CA318 POLY body age=%d pos=(%.3f,%.3f,%.3f) vel=(%.3f,%.3f,%.3f)",age,Body.Pos.X,Body.Pos.Y,Body.Pos.Z,Body.Vel.X,Body.Vel.Y,Body.Vel.Z);
        if(age==61)Polyobj_Stop(1);
    }
}
