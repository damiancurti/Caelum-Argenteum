// Standalone observations of the author-supplied external city. No CA runtime.
class CA318CityExampleProbe : EventHandler
{
    Actor User;
    Vector3 Anchor;
    bool Fixed;
    double Yaw;
    int Start,End,Warmup,Window,Site,Pitch;
    bool Started,Finished;
    ui bool Flushed;
    Array<double> Ticks;
    Array<int> TickIds;
    ui double LastFrame;
    ui Array<double> Frames,FrameTimes;
    ui Array<int> FrameTics;
    override bool InputProcess(InputEvent e){return true;}
    void Census(String label)
    {
        int actors=0,monsters=0,info=0;let it=ThinkerIterator.Create("Actor");Actor body;
        while((body=Actor(it.Next()))!=null){actors++;if(body.bIsMonster && body.health>0)monsters++;}
        let decor=ThinkerIterator.Create("Actor",Thinker.STAT_INFO);
        while(decor.Next()!=null)info++;
        Console.Printf("CA318 CENSUS %s thinking_actors=%d info_actors=%d living_monsters=%d",label,actors,info,monsters);
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!="ca318_begin")return;
        User=players[0].mo;
        Site=CVar.GetCVar("ca318_site").GetInt();Pitch=CVar.GetCVar("ca318_pitch").GetInt();
        Warmup=CVar.GetCVar("ca318_warmup").GetInt();Window=CVar.GetCVar("ca318_window").GetInt();
        User.bInvulnerable=true;
        Fixed=CVar.GetCVar("ca318_fixed").GetBool();
        if(Fixed)
        {
            double x=CVar.GetCVar("ca318_x").GetFloat(),y=CVar.GetCVar("ca318_y").GetFloat();
            User.SetOrigin((x,y,0),false);
            Anchor=(x,y,User.floorz+CVar.GetCVar("ca318_height").GetFloat());
            User.SetOrigin(Anchor,false);
            Yaw=CVar.GetCVar("ca318_yaw").GetFloat();
            Console.Printf("CA318 FIXED x=%.3f y=%.3f z=%.3f fits=%d ceiling=%.3f",Anchor.X,Anchor.Y,Anchor.Z,User.TestMobjLocation(),User.ceilingz);
        }
        else if(Site==4)
        {
            User.bNoGravity=true;
            double z=Max(User.Pos.Z,Min(1024,User.CurSector.ceilingplane.ZatPoint(User.Pos.XY)-User.Height-1));
            User.SetOrigin((User.Pos.X,User.Pos.Y,z),false);
        }
        Start=level.time;End=Start+Warmup+Window;Started=true;
        Console.Printf("CA318 START tic=%d start=%.6f warmup=%d window=%d",Start,MSTimeF(),Warmup,Window);
        Census("begin");
    }
    override void WorldTick()
    {
        if(!Started)return;
        if(Fixed){User.Vel=(0,0,0);User.SetOrigin(Anchor,false);User.bNoGravity=true;}
        User.Pitch=Pitch;User.Angle=Fixed?Yaw:Site==4?270:270+Site*90;
        if(Finished)return;
        Ticks.Push(MSTimeF());TickIds.Push(level.time);
        if(level.time==Start+Warmup)
        {
            Console.Printf("CA318 CAMERA_WINDOW x=%.3f y=%.3f z=%.3f angle=%.3f pitch=%.3f fits=%d",User.Pos.X,User.Pos.Y,User.Pos.Z,User.Angle,User.Pitch,User.TestMobjLocation());
            Console.Printf("CA318 WINDOW tic=%d ms=%.6f",level.time,MSTimeF());
        }
        if(level.time==End)
        {
            Console.Printf("CA318 CAMERA_END x=%.3f y=%.3f z=%.3f angle=%.3f pitch=%.3f fits=%d",User.Pos.X,User.Pos.Y,User.Pos.Z,User.Angle,User.Pitch,User.TestMobjLocation());
            Finished=true;Census("end");
            for(int i=0;i<Ticks.Size();i++)Console.Printf("CA318 TICK tic=%d ms=%.6f",TickIds[i],Ticks[i]);
            Console.Printf("CA318 DONE failures=0 tic=%d ms=%.6f",level.time,MSTimeF());
        }
    }
    override void RenderOverlay(RenderEvent e)
    {
        double now=MSTimeF();
        if(Started && !Finished)
        {
            if(LastFrame>0){Frames.Push(now-LastFrame);FrameTimes.Push(now);FrameTics.Push(level.time);}
            LastFrame=now;
        }
        if(Finished && !Flushed)
        {
            Flushed=true;
            for(int i=0;i<Frames.Size();i++)Console.Printf("CA318 FRAME tic=%d ms=%.6f interval=%.6f",FrameTics[i],FrameTimes[i],Frames[i]);
        }
    }
}

