// Movimiento nativo +forward: sólo el punto inicial y la orientación los fija el ensayo.
class CA450RoutePort : CaelumPortSiege replaces CaelumPortSiege { override void Tick(){} }
class CA450Checks : EventHandler
{
    int Failures,Leg,Mode;
    bool Active,StairsDone,WestDone;
    vector3 Previous;
    double LargestStep;
    void Check(bool pass,String label)
    {if(!pass)Failures++;Console.Printf("CA450 %s %s",pass?"PASS":"FAIL",label);}
    vector3 Point(int step)
    {
        if(Mode==1)return (-30272,-13248,0);
        if(step==0)return (-29664,-1024,256);
        if(step==1)return (-29664,0,256);
        if(step==2)return (-29664,-1024,256);
        return (-28544,-1024,0);
    }
    void Begin(int routeKind)
    {
        let user=CaelumPlayer(players[0].mo);Mode=routeKind;Leg=0;LargestStep=0;Active=true;
        user.SetOrigin(routeKind==0?(-28544,-1024,0):(-30272,-14528,0),false);
        user.Vel=(0,0,0);user.Pitch=0;Previous=user.Pos;
        user.Angle=routeKind==0?180:90;
        Check(user.TestMobjLocation() && !user.bNoClip,"route starts on valid collidable city ground");
    }
    override void WorldTick()
    {
        if(!Active)return;
        let user=CaelumPlayer(players[0].mo);vector3 destination=Point(Leg);
        LargestStep=Max(LargestStep,(user.Pos-Previous).Length());Previous=user.Pos;
        if((user.Pos.XY-destination.XY).Length()<32 && Abs(user.Pos.Z-destination.Z)<17)
        {
            Console.Printf("CA450 WAYPOINT mode=%d leg=%d z=%f",Mode,Leg,user.Pos.Z);
            Leg++;
            if((Mode==0 && Leg==4) || Mode==1)
            {
                Active=false;
                if(Mode==0)StairsDone=true;else WestDone=true;
                Check(LargestStep<64 && user.health>0,"native forward movement traverses the route without teleport or collision trap");
                return;
            }
            destination=Point(Leg);
        }
        user.Angle=VectorAngle(destination.X-user.Pos.X,destination.Y-user.Pos.Y);
        if(level.time%TICRATE==0)Console.Printf("CA450 WALK mode=%d leg=%d at=%f,%f,%f",Mode,Leg,user.Pos.X,user.Pos.Y,user.Pos.Z);
    }
    void Report()
    {
        let user=CaelumPlayer(players[0].mo);let record=user.GetPersistentCharacterState(false);
        Check(StairsDone && WestDone,"both authored routes finish through ordinary native movement");
        Check(CaelumPoiKnowledge.Find(record,"MAP03","battle-route-west_wall_3")!=null,"walking onto the real stair discovers only its entry marker");
        Check(CaelumPoiKnowledge.Find(record,"MAP03","battle-route-west-flank")!=null,"walking the west exterior discovers its observed marker");
        Check(CaelumPoiKnowledge.Find(record,"MAP03","battle-route-north_wall_7")==null,"remote stairs remain undisclosed");
        Console.Printf("CA450 ROUTES %s failures=%d",Failures==0?"PASS":"FAIL",Failures);
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="ca450_initial")Begin(0);
        else if(e.Name=="ca450_west")Begin(1);
        else if(e.Name=="ca450_report")Report();
    }
}
