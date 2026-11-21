class CA847Views : EventHandler
{
    int View;
    vector3 WalkStart;
    void Place(int index)
    {
        let user=CaelumPlayer(players[0].mo);
        if(user==null || level.MapName!="MAP02"){Console.Printf("CA847 FAIL map/player");return;}
        vector3 point; double angle;
        switch(index) { case 0: point=(0,-4864,0); angle=90; break;
case 1: point=(-160.0,-4256.0,0); angle=45; break;
case 2: point=(-2304.0,-4128.0,0); angle=0; break;
case 3: point=(-3936.0,-3232.0,0); angle=135; break;
case 4: point=(-2912,8160.0,0); angle=180; break;
case 5: point=(768.0,-3104.0,0); angle=0; break;
case 6: point=(-3104.0,-2560.0,0); angle=90; break;
case 7: point=(0,2920.0,0); angle=90; break;
case 8: point=(-1536,-3752.0,0); angle=90; break; default:Console.Printf("CA847 FAIL index");return; }
        user.bInvulnerable=true;user.bNOTARGET=true;
        user.GetPersistentCharacterState(true).DemoNarrativeDelivered=2047;
        user.GetPersistentCharacterState(true).DemoNarrativePending=0;
        user.SetOrigin(point,false);user.FindFloorCeiling();
        user.SetOrigin((point.X,point.Y,user.FloorZ),false);
        user.Angle=angle;user.Pitch=0;user.Vel=(0,0,0);
        Console.Printf("CA847 VIEW %d pos=%.3f,%.3f,%.3f angle=%.3f headroom=%.3f",index,user.Pos.X,user.Pos.Y,user.Pos.Z,user.Angle,user.CeilingZ-user.FloorZ);
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="ca847_next"){Place(View);View++;}
        else if(e.Name=="ca847_walk"){Place(2);WalkStart=players[0].mo.Pos;}
        else if(e.Name=="ca847_done")
        {
            let user=players[0].mo;
            double distance=(user.Pos-WalkStart).Length();
            Console.Printf("CA847 WALK distance=%.3f pos=%.3f,%.3f,%.3f",distance,user.Pos.X,user.Pos.Y,user.Pos.Z);
            Console.Printf("CA847 %s views=%d",View==9 && distance>0?"PASS":"FAIL",View);
        }
    }
}

class CA875CollisionBody : Actor
{
    Default { Radius 21.333333; Height 74.7; +SOLID +NOGRAVITY }
    States { Spawn: TNT1 A -1; Stop; }
}
class CA875CollisionCheck : EventHandler
{
    Array<Actor> Cleared;
    bool Move(Actor body,vector2 goal)
    {
        while(true)
        {
            if(body.TryMove(goal,0))return true;
            let blocker=body.BlockingMobj;
            if(blocker==null || !blocker.bSolid || !(blocker is "CaelumGiantRat" || blocker is "CaelumMandinga"))return false;
            Console.Printf("CA875 CLEAR_ACTOR class=%s pos=%.3f,%.3f,%.3f",blocker.GetClassName(),blocker.Pos.X,blocker.Pos.Y,blocker.Pos.Z);
            Cleared.Push(blocker);blocker.bSolid=false;
        }
        return false;
    }
    override void NetworkProcess(ConsoleEvent event)
    {
        if(event.Name!="ca875_collision")return;
        bool all=true;int moves=0;
        for(int row=0;row<4;row++)
        {
            vector3 start,finish;int axis,bodies;double offset0,offset1;String label;
            switch(row){case 0: start=(232.0,-3104.0,0); finish=(1304.0,-3104.0,0); axis=0; bodies=2; offset0=-24.0; offset1=24.0; label="main_horizontal"; break;
case 1: start=(-3104.0,-2840.0,0); finish=(-3104.0,-2280.0,0); axis=1; bodies=2; offset0=-24.0; offset1=24.0; label="main_vertical"; break;
case 2: start=(0,824.0,0); finish=(0,5016.0,0); axis=1; bodies=2; offset0=-32.0; offset1=32.0; label="service"; break;
case 3: start=(-1536,-3864.0,0); finish=(-1536,-3640.0,0); axis=1; bodies=1; offset0=0; offset1=0; label="maintenance"; break; default:return;}
            Actor body0,body1;body0=null;body1=null;vector3 a=start,b=finish;
            if(axis==0){a.Y+=offset0;b.Y+=offset1;}
            else {a.X+=offset0;b.X+=offset1;}
            body0=Actor.Spawn("CA875CollisionBody",a,NO_REPLACE);
            if(bodies==2)body1=Actor.Spawn("CA875CollisionBody",b,NO_REPLACE);
            bool okay=body0!=null && (bodies==1 || body1!=null);
            int expected=int((finish-start).Length()/4.0);
            if(okay)okay=Move(body0,body0.Pos.XY);
            if(okay && body1!=null)okay=Move(body1,body1.Pos.XY);
            for(int direction=0;direction<2 && okay;direction++)
            {
                vector2 step=(finish.XY-start.XY).Unit()*4.0*(direction==0?1:-1);
                for(int n=0;n<expected && okay;n++)
                {
                    okay=Move(body0,body0.Pos.XY+step);moves++;
                    if(okay && body1!=null){okay=Move(body1,body1.Pos.XY-step);moves++;}
                    if(okay)okay=Abs(body0.Pos.Z-a.Z)<0.000001 && body0.CeilingZ-body0.Pos.Z>=74.7;
                    if(okay && body1!=null)okay=Abs(body1.Pos.Z-b.Z)<0.000001 && body1.CeilingZ-body1.Pos.Z>=74.7;
                }
            }
            if(okay)okay=(body0.Pos-a).Length()<0.000001;
            if(okay && body1!=null)okay=(body1.Pos-b).Length()<0.000001;
            Console.Printf("CA875 COLLISION %s case=%s bodies=%d length=%.3f radius=%.6f height=%.3f",okay?"PASS":"FAIL",label,bodies,(finish-start).Length(),21.333333,74.7);
            if(!okay && body0!=null)Console.Printf("CA875 BODY pos=%.3f,%.3f,%.3f ceiling=%.3f",body0.Pos.X,body0.Pos.Y,body0.Pos.Z,body0.CeilingZ);
            if(!okay && body0!=null && body0.BlockingMobj!=null)Console.Printf("CA875 BLOCKER body=0 class=%s",body0.BlockingMobj.GetClassName());
            if(!okay && body1!=null && body1.BlockingMobj!=null)Console.Printf("CA875 BLOCKER body=1 class=%s",body1.BlockingMobj.GetClassName());
            if(!okay && body0!=null)Console.Printf("CA875 LINEBLOCK body=0 line=%d movement=%d",body0.BlockingLine!=null,body0.MovementBlockingLine!=null);
            if(!okay && body1!=null)Console.Printf("CA875 LINEBLOCK body=1 line=%d movement=%d",body1.BlockingLine!=null,body1.MovementBlockingLine!=null);
            all=all && okay;
            if(body0!=null)body0.Destroy();if(body1!=null)body1.Destroy();
        }
        int restored=0;
        for(int i=0;i<Cleared.Size();i++)if(Cleared[i]!=null){Cleared[i].bSolid=true;restored++;}
        Console.Printf("CA875 COLLISION_COMPLETE %s cases=4 moves=%d cleared=%d restored=%d",all?"PASS":"FAIL",moves,Cleared.Size(),restored);
        Cleared.Clear();
    }
}
