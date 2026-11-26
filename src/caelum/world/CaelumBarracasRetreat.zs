// #454: retirada guardada sobre rutas conocidas, con colision individual.
class CaelumBarracasRetreat : Object play
{
    static void Initialize(CaelumSiegeCombatant entry)
    {
        if(entry.RetreatRevision>=CaelumBarracasRetreatData.REVISION)return;
        entry.RetreatGun=-1;entry.RetreatStep=-1;entry.RetreatPointPending=false;
        entry.RetreatCellKnown=false;entry.RetreatDistance=-1;entry.RetreatCellDistance=-1;
        entry.RetreatLane=entry.Lane;entry.RetreatExitChosen=false;
        let body=entry.Body;
        if(body.FloorZ>body.MaxStepHeight)
        {
            if(entry.NavigationTarget==null)entry.NavigationTarget=Actor.Spawn('CaelumSewerEscapeTarget',body.Pos);
            double best=1e30;
            // Solo las 36 rutas estaticas de artilleria, una vez por retirada.
            // La vista evita elegir un rellano cercano separado por un muro.
            for(int gun=0;CaelumBarracasSiegeData.CrewRouteCount(gun)>0;gun++)
                for(int step=0;step<CaelumBarracasSiegeData.CrewRouteCount(gun);step++)
                {
                    vector3 point=CaelumBarracasSiegeData.CrewRoutePoint(gun,step);
                    if(Abs(point.Z-body.FloorZ)>body.MaxStepHeight)continue;
                    double distance=(point-body.Pos).Length();
                    if(distance>=best)continue;
                    entry.NavigationTarget.SetOrigin(point,false);
                    if(!body.CheckSight(entry.NavigationTarget))continue;
                    best=distance;entry.RetreatGun=gun;entry.RetreatStep=step;
                }
        }
        entry.RetreatRevision=CaelumBarracasRetreatData.REVISION;
    }

    static vector3 GroundPoint(CaelumSiegeCombatant entry)
    {
        let body=entry.Body;vector3 point=body.Pos;
        String direction=CaelumBarracasRetreatData.Direction(entry.RetreatLane,point);
        if(direction=="G")return entry.ExitNode.Pos;
        if(direction!=".")return CaelumBarracasRetreatData.Next(entry.RetreatLane,point);
        // Un escalon bajo puede quedar fuera del campo de suelo. Buscar solo
        // dentro del alcance del navegador local, sin recorrer actores.
        double best=1e30;vector3 found=entry.ExitNode.Pos;
        int radius=int(Ceil(body.Radius*16/CaelumBarracasRetreatData.CELL));
        vector3 centre=CaelumBarracasRetreatData.Centre(point);
        for(int x=-radius;x<=radius;x++)for(int y=-radius;y<=radius;y++)
        {
            vector3 candidate=centre+(x*CaelumBarracasRetreatData.CELL,y*CaelumBarracasRetreatData.CELL,0);
            if(CaelumBarracasRetreatData.Direction(entry.RetreatLane,candidate)==".")continue;
            double distance=(candidate-point).Length();
            if(distance<best){best=distance;found=candidate;}
        }
        return found;
    }

    static void ChooseExit(CaelumSiegeCombatant entry)
    {
        if(entry.RetreatExitChosen)return;
        let port=CaelumPortSiege(entry.Encounter);if(port==null)return;
        int best=-1,lane=-1;
        // Tres salidas existentes, consultadas una sola vez al llegar al suelo.
        // El frente de asalto sigue en Lane; no obliga a cruzarse con otro
        // ejercito durante la retirada si una salida legal esta mas cerca.
        for(int i=0;i<port.Exits.Size();i+=2)
        {
            int distance=CaelumBarracasRetreatData.Distance(i,entry.Body.Pos);
            if(distance>=0 && (best<0 || distance<best)){best=distance;lane=i;}
        }
        if(lane<0)return; // Un rellano bajo usa primero la aproximacion existente.
        entry.RetreatLane=lane;entry.ExitNode=port.Exits[lane];entry.RetreatExitChosen=true;
        entry.RetreatPointPending=false;entry.RetreatCellKnown=false;
    }

    static vector3 Destination(CaelumSiegeCombatant entry)
    {
        Initialize(entry);let body=entry.Body;
        if(body.FloorZ<=body.MaxStepHeight)entry.RetreatStep=-1;
        while(entry.RetreatStep>=0)
        {
            vector3 point=CaelumBarracasSiegeData.CrewRoutePoint(entry.RetreatGun,entry.RetreatStep);
            if((point.XY-body.Pos.XY).Length()>body.Radius || Abs(point.Z-body.Pos.Z)>body.MaxStepHeight)return point;
            entry.RetreatStep--;
        }
        ChooseExit(entry);
        // Un desvio puede cruzar otra celda igualmente cercana a la salida sin
        // pisar el waypoint original. No volver hacia atras por ese centro:
        // el coste BFS precalculado acredita el avance fisico, sin buscar actores.
        vector3 cell=CaelumBarracasRetreatData.Centre(body.Pos);
        if(!entry.RetreatCellKnown || entry.RetreatCell!=cell)
        {
            entry.RetreatCell=cell;entry.RetreatCellKnown=true;
            entry.RetreatCellDistance=CaelumBarracasRetreatData.Distance(entry.RetreatLane,cell);
        }
        int current=entry.RetreatCellDistance,wanted=entry.RetreatDistance;
        if(!entry.RetreatPointPending || (current>=0 && (wanted<0 || current<=wanted))
            || cell==CaelumBarracasRetreatData.Centre(entry.RetreatPoint))
        {
            entry.RetreatPoint=GroundPoint(entry);entry.RetreatPointPending=true;
            entry.RetreatDistance=CaelumBarracasRetreatData.Distance(entry.RetreatLane,entry.RetreatPoint);
        }
        return entry.RetreatPoint;
    }

    static bool FollowQueue(CaelumSiegeCombatant entry,vector3 goal)
    {
        if(!entry.Withdrawing || !entry.RetreatExitChosen || entry.RetreatStep>=0)return false;
        let body=entry.Body;
        if(body.FloorZ>body.MaxStepHeight)return false;
        String direction=CaelumBarracasRetreatData.Direction(entry.RetreatLane,body.Pos);
        if(direction=="." || direction=="G")return false;
        vector2 heading=direction=="N" ? (0,1) : direction=="S" ? (0,-1) : direction=="E" ? (1,0) : (-1,0);
        vector2 delta=goal.XY-body.Pos.XY;
        if(delta.Length()==0)return false;
        vector2 next=body.Pos.XY+delta.Unit()*Min(body.Speed,delta.Length());
        // Solo el volumen del proximo paso: no recorrer el ejercito ni usar un
        // BlockingMobj viejo cuando CheckPosition impidio llamar a TryMove.
        let local=BlockThingsIterator.CreateFromPos(next.X,next.Y,body.Pos.Z,body.Height,body.Radius,false);
        while(local.Next())
        {
            let other=CaelumCombatActor(local.Thing);
            if(other==null || other==body || !other.bSolid || other.health<=0)continue;
            let ahead=other.SiegeCombatant;
            if(ahead==null || ahead.Encounter!=entry.Encounter || !ahead.Withdrawing
                || !ahead.RetreatExitChosen || ahead.RetreatLane!=entry.RetreatLane
                || ahead.Exited || ahead.ConfirmedDead || ahead.RetreatStep>=0)continue;
            if(other.ForcedSleepTics>0 || other.CombatLucidityPhysicalStunRemaining>0
                || CaelumBolas.Restrained(other) || CaelumTelekinesisRules.Held(other)
                || CaelumTarotRooted.Active(other))continue;
            if(other.Pos.Z>=body.Pos.Z+body.Height || other.Pos.Z+other.Height<=body.Pos.Z)continue;
            double radius=body.Radius+other.Radius;
            if(Abs(next.X-other.Pos.X)>=radius || Abs(next.Y-other.Pos.Y)>=radius)continue;
            vector2 separation=other.Pos.XY-body.Pos.XY;
            if(separation.X*heading.X+separation.Y*heading.Y<=0)continue;
            if(CaelumBarracasRetreatData.Direction(ahead.RetreatLane,other.Pos)!=direction)continue;
            // Esperar solo a quien avanza delante por la misma recta. Este
            // orden estricto no crea esperas circulares; esquinas, detenidos y
            // obstaculos ajenos conservan el desvio local y la colision nativa.
            entry.FrontNavigation.Clear();return true;
        }
        return false;
    }
}
