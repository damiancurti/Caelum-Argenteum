// Consulta acotada al preparar rutas, nunca un censo por tic o por víctima.
// Las sondas no mueven al personaje ni abren puertas del mundo real.
class CaelumTheftProbe : CaelumRestSeatProbe
{
    CaelumTheftAccess Query;
    override bool CanCollideWith(Actor other,bool passive)
    {
        if(other==Subject)return false;
        let leaf=CaelumSlidingDoorLeaf(other);
        if(other is 'CaelumSlidingDoorBlocker')leaf=CaelumSlidingDoorLeaf(other.master);
        return Query==null || leaf==null || !Query.DoorAllowed(leaf);
    }
}
class CaelumTheftFloorProbe : Actor
{
    Default { Radius 0; Height 0; +NOGRAVITY +NOBLOCKMAP +NOSECTOR +NOCLIP +INVISIBLE }
    States { Spawn: TNT1 A -1; Stop; }
}
class CaelumTheftTrace : LineTracer
{
    Actor Goal,Subject;
    Array<CaelumSlidingDoorLeaf> AllowedDoors;
    Array<Line> AllowedFaces;
    override ETraceStatus TraceCallback()
    {
        if(Results.HitType==TRACE_HitActor)
        {
            let actor=Results.HitActor;if(actor==Goal || actor==Subject)return TRACE_Skip;
            let leaf=CaelumSlidingDoorLeaf(actor);
            if(actor is 'CaelumSlidingDoorBlocker')leaf=CaelumSlidingDoorLeaf(actor.master);
            if(leaf!=null && AllowedDoors.Find(leaf)<AllowedDoors.Size())return TRACE_Skip;
        }
        if(Results.HitType==TRACE_HitWall && AllowedFaces.Find(Results.HitLine)<AllowedFaces.Size())return TRACE_Skip;
        return TRACE_Stop;
    }
}
class CaelumTheftAccess : Object play
{
    // Límite de trabajo técnico; una ruta no demostrada nunca autoriza un robo.
    const MAX_NODES=4096;
    Array<CaelumSlidingDoorLeaf> Doors;
    CaelumCombatActor Body;
    CaelumTheftProbe Probe;
    CaelumTheftFloorProbe FloorProbe;
    CaelumTheftTrace Sight;
    int Checks;

    void Prepare(CaelumCombatActor body,bool census=true)
    {
        self.Body=body;Checks=0;
        if(census)
        {
            Doors.Clear();let search=ThinkerIterator.Create('CaelumSlidingDoorLeaf');CaelumSlidingDoorLeaf leaf;
            while((leaf=CaelumSlidingDoorLeaf(search.Next()))!=null)Doors.Push(leaf);
        }
        Probe=CaelumTheftProbe(Actor.Spawn('CaelumTheftProbe',body.Pos,NO_REPLACE));
        FloorProbe=CaelumTheftFloorProbe(Actor.Spawn('CaelumTheftFloorProbe',body.Pos,NO_REPLACE));
        Probe.Query=self;Probe.Subject=body;Probe.A_SetSize(body.Radius,body.Height);
        FloorProbe.A_SetSize(0,body.Height);Sight=new('CaelumTheftTrace');Sight.Subject=body;
    }
    void Close()
    {if(Probe!=null)Probe.Destroy();if(FloorProbe!=null)FloorProbe.Destroy();Probe=null;FloorProbe=null;}
    bool DoorAllowed(CaelumSlidingDoorLeaf leaf)
    {
        if(leaf==null || Body==null)return false;
        if(leaf.RuloArenaLocked || (leaf.args[3]>0 && !Body.CheckKeys(leaf.args[3],false,true))
            || CaelumFactionCondition.Check(null,leaf.AccessCondition)!=CaelumFactionCondition.ALLOWED)return false;
        for(int i=0;i<Doors.Size();i++)
        {
            let peer=Doors[i];if(peer==null || !leaf.IsGroupPeer(peer))continue;
            if(peer.RuloArenaLocked || (peer.args[3]>0 && !Body.CheckKeys(peer.args[3],false,true))
                || CaelumFactionCondition.Check(null,peer.AccessCondition)!=CaelumFactionCondition.ALLOWED)return false;
        }
        return true;
    }
    bool OpenableFace(Line line)
    {
        if(line==null || line.special!=7)return false;
        let events=CaelumPolyDoorEvents.Get();int id=line.args[0];
        if(events==null || id<=0 || id>=events.Leaves.Size())return false;
        let leaf=events.Leaves[id];if(leaf==null || !DoorAllowed(leaf))return false;
        for(int i=0;i<leaf.NativeFaces.Size();i++)if(leaf.NativeFaces[i]==line)return true;
        return false;
    }
    bool Point(vector3 from,vector2 at,out double floor)
    {
        Checks++;Probe.SetOrigin(from,false);FCheckPosition fit;
        bool clear=Probe.CheckPosition(at,false,fit);
        double ceiling=fit.ceilingz,dropoff=fit.dropoffz;floor=fit.floorz;
        if(!clear)
        {
            // CheckPosition(actorsonly) conserva suelo, techo y pisos 3D
            // nativos; sólo se omiten caras de puertas cuya llave es válida.
            if(!Probe.CheckPosition(at,true,fit))return false;
            floor=fit.floorz;ceiling=fit.ceilingz;dropoff=fit.dropoffz;
            Probe.SetOrigin((at.X,at.Y,from.Z),false);
            bool door=false;let lines=BlockLinesIterator.Create(Probe,Body.Radius);
            while(lines.Next())
            {
                let line=lines.CurLine;
                if(!CaelumPlacementGeometry.CrossesBox(line.v1.p,line.v2.p,at,Body.Radius))continue;
                if(OpenableFace(line)){door=true;continue;}
                if(line.backsector==null || (line.flags&(Line.ML_BLOCKING|Line.ML_BLOCKEVERYTHING|Line.ML_BLOCKMONSTERS|Line.ML_3DMIDTEX))!=0
                    || CaelumTargetPanelData.TravelSpecial(line.special))return false;
            }
            if(!door)return false;
            for(int x=-1;x<=1;x++)for(int y=-1;y<=1;y++)
            {
                FloorProbe.SetOrigin(from,false);
                FCheckPosition sample;FloorProbe.CheckPosition(at+(x*Body.Radius,y*Body.Radius),true,sample);
                floor=Max(floor,sample.floorz);ceiling=Min(ceiling,sample.ceilingz);dropoff=Min(dropoff,sample.floorz);
            }
        }
        return ceiling-floor>=Body.Height && floor-dropoff<=Body.MaxDropOffHeight
            && floor-from.Z<=Body.MaxStepHeight && from.Z-floor<=Body.MaxDropOffHeight;
    }
    bool Segment(vector3 from,vector2 to,out double floor)
    {
        vector2 delta=to-from.XY;floor=from.Z;
        int steps=Max(1,int(Ceil(delta.Length()/Max(1,Body.Radius*.5))));
        for(int i=1;i<=steps;i++)
        {
            double next;
            if(!Point((from.X,from.Y,floor),from.XY+delta*i/steps,next))return false;
            floor=next;
        }
        return true;
    }
    bool HandPath(vector3 from,CaelumStashChest chest)
    {
        vector3 start=from+(0,0,Body.Height*.5);
        vector3 end=chest.Pos+(0,0,Min(chest.Height*.5,Body.Height*.5));
        vector3 delta=end-start;if(delta.Length()==0)return true;
        Sight.Goal=chest;
        return !Sight.Trace(start,level.PointInSector(start.XY),delta/delta.Length(),delta.Length(),
            TRACE_PortalRestrict,Line.ML_BLOCKING|Line.ML_BLOCKEVERYTHING,false,Body);
    }
    bool Reachable(CaelumStashChest chest)
    {
        if(Body==null || Probe==null || chest==null || chest.bDestroyed || !CaelumTheftTransfer.KeyAccess(chest,Body))return false;
        Sight.AllowedDoors.Clear();Sight.AllowedFaces.Clear();
        for(int i=0;i<Doors.Size();i++)if(DoorAllowed(Doors[i]))
        {
            Sight.AllowedDoors.Push(Doors[i]);let hinged=CaelumHingedDoorLeaf(Doors[i]);
            if(hinged!=null)for(int j=0;j<hinged.NativeFaces.Size();j++)Sight.AllowedFaces.Push(hinged.NativeFaces[j]);
        }
        double reach=Body.MeleeRange+chest.Radius;
        vector2 delta=chest.Pos.XY-Body.Pos.XY;double distance=delta.Length();
        if(distance<=reach && Abs(chest.Pos.Z-Body.Pos.Z)<=reach && HandPath(Body.Pos,chest))return true;
        vector2 goal=chest.Pos.XY;double unit=Max(1,Body.Radius*.5),padding=Body.Radius*4;
        vector2 origin=(Min(goal.X,Body.Pos.X)-padding,Min(goal.Y,Body.Pos.Y)-padding);
        double extentX=Abs(delta.X)+padding*2,extentY=Abs(delta.Y)+padding*2;
        int width=int(Ceil(extentX/unit))+1,height=int(Ceil(extentY/unit))+1;
        while(width*double(height)>MAX_NODES)
        {unit*=1.25;width=int(Ceil(extentX/unit))+1;height=int(Ceil(extentY/unit))+1;}
        int count=width*height;
        Array<int> mark,open;Array<double> cost,elevation,estimate;
        mark.Resize(count);cost.Resize(count);elevation.Resize(count);estimate.Resize(count);
        int start=int(Round((Body.Pos.Y-origin.Y)/unit))*width+int(Round((Body.Pos.X-origin.X)/unit));
        vector2 initial=origin+(start%width*unit,start/width*unit);double initialFloor;
        if(!Segment(Body.Pos,initial,initialFloor))return false;
        mark[start]=1;elevation[start]=initialFloor;open.Push(start);
        estimate[start]=(goal-initial).Length();
        while(open.Size()>0)
        {
            int pick=0;for(int i=1;i<open.Size();i++)if(estimate[open[i]]<estimate[open[pick]])pick=i;
            int node=open[pick];open.Delete(pick);mark[node]=2;
            vector2 point=origin+(node%width*unit,node/width*unit);
            if((goal-point).Length()<=reach && Abs(chest.Pos.Z-elevation[node])<=reach
                && HandPath((point.X,point.Y,elevation[node]),chest))return true;
            for(int direction=0;direction<4;direction++)
            {
                int x=node%width+(direction==0?1:direction==1?-1:0);
                int y=node/width+(direction==2?1:direction==3?-1:0);
                if(x<0 || y<0 || x>=width || y>=height)continue;
                int next=y*width+x;if(mark[next]==2 || (mark[next]==1 && cost[next]<=cost[node]+unit))continue;
                vector2 destination=origin+(x*unit,y*unit);double nextFloor;
                if(!Segment((point.X,point.Y,elevation[node]),destination,nextFloor))continue;
                if(mark[next]==0){mark[next]=1;open.Push(next);}
                cost[next]=cost[node]+unit;elevation[next]=nextFloor;
                estimate[next]=cost[next]+(goal-destination).Length();
            }
        }
        return false;
    }
}
