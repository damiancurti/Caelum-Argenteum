// Isolated diagnostic sampling; no production actors or performance policy change.
class CA318GeometryBody : Actor
{
    Default { +NOGRAVITY +THRUACTORS }
    States { Spawn: TNT1 A -1; Stop; }
}

class CA318GeometryProbe : EventHandler
{
    int Next,Failures;
    bool Running,Completed;
    CA318GeometryBody Body;
    vector3 Location(int i)
    {
@POSITIONS@
        return (0,0,0);
    }
    void Sample(int i)
    {
        vector3 point=Location(i);
        Body.SetOrigin(point,false);
        bool fits=Body.TestMobjLocation();
        Console.Printf("CA318 GEO point=%d fits=%d floor=%.6f ceiling=%.6f roof=%d wind=%d volumes=%d",
            i,fits,Body.FloorZ,Body.CeilingZ,CaelumThermalShelter.Roof(Body),
            CaelumThermalShelter.WindBlocked(Body),Body.CurSector.Get3DFloorCount());
        for(int v=0;v<Body.CurSector.Get3DFloorCount();v++)
        {
            let volume=Body.CurSector.Get3DFloor(v);
            Console.Printf("CA318 VOL point=%d index=%d flags=%d bottom=%.6f top=%.6f",
                i,v,volume.flags,volume.bottom.ZatPoint(point.XY),volume.top.ZatPoint(point.XY));
        }
        for(int ray=0;ray<10;ray++)
        {
            FLineTraceData hit;
            double pitch=ray==8?-90:ray==9?90:0;
            bool found=Body.LineTrace(ray<8?ray*45:0,65536,pitch,
                TRF_THRUACTORS|TRF_ABSPOSITION|TRF_NOSKY,point.Z+Body.Height*0.5,point.X,point.Y,hit);
            Console.Printf("CA318 RAY point=%d ray=%d found=%d type=%d x=%.6f y=%.6f z=%.6f",
                i,ray,found,hit.HitType,hit.HitLocation.X,hit.HitLocation.Y,hit.HitLocation.Z);
        }
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="c318_geometry")
        {
            if(Body==null)Body=CA318GeometryBody(Actor.Spawn("CA318GeometryBody",Location(0),NO_REPLACE));
            let user=players[consoleplayer].mo;
            Body.A_SetSize(user.Radius,user.Height,false);
            Next=0;Running=true;Completed=false;
        }
        if(e.Name=="c318_geometry_saved")
        {
            if(Completed && Next==@COUNT@ && Body!=null)Console.Printf("CA318 PASS saved geometry state restored");
            else {Failures++;Console.Printf("CA318 FAIL saved geometry state missing");}
        }
        if(e.Name=="c318_geometry_done")
        {
            if(!Completed || Next!=@COUNT@){Failures++;Console.Printf("CA318 FAIL sample pass incomplete");}
            Console.Printf("CA318 DONE failures=%d points=%d",Failures,Next);
        }
    }
    override void WorldTick()
    {
        if(!Running)return;
        for(int j=0;j<8 && Next<@COUNT@;j++)Sample(Next++);
        if(Next==@COUNT@){Running=false;Completed=true;}
    }
}
