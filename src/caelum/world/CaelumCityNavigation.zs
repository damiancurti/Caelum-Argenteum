// Desvío local acotado: consulta la colisión nativa sin mover el cuerpo.
// La marcha posterior usa TryMove, recursos y cadencia normales.
class CaelumCityNavigation : Object play
{
    Array<double> PointX,PointY;
    int Cursor, RetryTic;
    bool Queued;
    vector2 Goal;
    double GoalHeight;

    void Clear(){PointX.Clear();PointY.Clear();Cursor=0;}
    vector2 Point(int i){return (PointX[i],PointY[i]);}

    vector2 Next(CaelumPortDefender body,vector3 goal)
    {
        if((goal.XY-self.Goal).Length()>1 || goal.Z!=GoalHeight){Clear();self.Goal=goal.XY;GoalHeight=goal.Z;}
        while(Cursor<PointX.Size() && (Point(Cursor)-body.Pos.XY).Length()<0.5)Cursor++;
        return Cursor<PointX.Size() ? Point(Cursor) : goal.XY;
    }

    void Request(CaelumPortDefender body,vector3 goal)
    {
        Clear();self.Goal=goal.XY;GoalHeight=goal.Z;
        if(body.Port==null || Queued || level.time<RetryTic)return;
        body.Port.CityPathQueue.Push(body);Queued=true;
    }

    bool Build(CaelumPortDefender body)
    {
        Clear();Queued=false;vector2 goal=self.Goal;
        RetryTic=level.time+TICRATE;
        // Dieciséis radios a cada lado; medio radio de precisión cerca del
        // destino. No cambia alcance, velocidad ni tamaño del actor.
        double unit=Max(1.0,body.Radius*((goal-body.Pos.XY).Length()<=body.Radius*8 ? 0.5 : 1.0));
        int half=int(16*body.Radius/unit);
        int width=half*2+1;
        int total=width*width;
        Array<int> nodeState,parent,cost,open;
        Array<double> estimate,nodeHeight;
        nodeState.Resize(total);parent.Resize(total);cost.Resize(total);estimate.Resize(total);
        nodeHeight.Resize(total);
        vector2 origin=body.Pos.XY-(unit*half,unit*half);
        int start=half*width+half,best=start;
        double bestDistance=(goal-body.Pos.XY).Length();
        double bestHeight=body.FloorZ;
        bool descending=body.FloorZ>GoalHeight;
        nodeState[start]=1;cost[start]=0;estimate[start]=bestDistance;open.Push(start);
        nodeHeight[start]=body.FloorZ;
        int examined=0;
        while(open.Size()>0 && examined<total)
        {
            int pick=0;
            for(int i=1;i<open.Size();i++)if(estimate[open[i]]<estimate[open[pick]])pick=i;
            int node=open[pick];open.Delete(pick);nodeState[node]=2;examined++;
            vector2 point=origin+(node%width*unit,node/width*unit);
            double distance=(goal-point).Length();
            if((descending && nodeHeight[node]<bestHeight)
                || ((!descending || nodeHeight[node]==bestHeight) && distance<bestDistance))
            {bestDistance=distance;bestHeight=nodeHeight[node];best=node;}
            if(distance<unit && nodeHeight[node]<=GoalHeight){best=node;break;}
            for(int direction=0;direction<4;direction++)
            {
                int nx=node%width+(direction==0 ? 1 : direction==1 ? -1 : 0);
                int ny=node/width+(direction==2 ? 1 : direction==3 ? -1 : 0);
                if(nx<0 || ny<0 || nx>=width || ny>=width)continue;
                int next=ny*width+nx;
                if(nodeState[next]==2 || nodeState[next]==3)continue;
                if(nodeState[next]==0)
                {
                    vector2 candidate=origin+(nx*unit,ny*unit);
                    FCheckPosition fit;
                    // Consultar suelo por nodo, no con la altura actual para
                    // todo el recorrido. El trayecto de calles no debe subir
                    // escaleras por un atajo XY; las de artillería son otra fase.
                    if(!body.CheckPosition(candidate,false,fit)
                        || fit.ceilingz-fit.floorz<body.Height
                        || fit.floorz-fit.dropoffz>body.MaxDropOffHeight)
                    {nodeState[next]=3;continue;}
                    nodeHeight[next]=fit.floorz;
                    if(nodeHeight[next]>Max(GoalHeight,nodeHeight[node])
                        || nodeHeight[next]-nodeHeight[node]>body.MaxStepHeight)continue;
                    cost[next]=total+1;nodeState[next]=1;open.Push(next);
                }
                if(nodeHeight[next]>Max(GoalHeight,nodeHeight[node])
                    || nodeHeight[next]-nodeHeight[node]>body.MaxStepHeight)continue;
                if(cost[node]+1>=cost[next])continue;
                cost[next]=cost[node]+1;parent[next]=node;
                estimate[next]=cost[next]*unit+(goal-(origin+(nx*unit,ny*unit))).Length();
            }
        }
        // Si otro cuerpo ocupa el destino, acercarse infinitesimalmente deja
        // a dos peatones enfrentados para siempre. Buscar espacio lateral real
        // dentro de la misma consulta; el paso posterior conserva la colisión.
        if((!descending || bestHeight>=body.FloorZ) && bestDistance>(goal-body.Pos.XY).Length()-unit)
        {
            vector2 forward=goal-body.Pos.XY;
            if(forward.Length()>0)
            {
                forward=forward.Unit();vector2 side=(-forward.Y,forward.X);
                double choice=1e30;int escape=start;
                for(int pass=0;pass<2 && escape==start;pass++)
                {
                    vector2 destination=body.Pos.XY+side*body.Radius*4*(pass==0 ? 1 : -1);
                    for(int node=0;node<total;node++)
                    {
                        if(nodeState[node]!=2 || cost[node]>int(8*body.Radius/unit))continue;
                        vector2 point=origin+(node%width*unit,node/width*unit);
                        if((point-body.Pos.XY).Length()<body.Radius*2)continue;
                        double distance=(point-destination).Length();
                        if(distance<choice){choice=distance;escape=node;}
                    }
                }
                if(escape!=start)best=escape;
            }
        }
        if(best==start)return false;
        Array<int> reverse;
        for(int node=best;node!=start;node=parent[node])reverse.Push(node);
        for(int i=reverse.Size()-1;i>=0;i--)
        {
            int node=reverse[i];
            // Sólo comprimir segmentos rectos; no cortar esquinas de muros.
            if(i>0 && i<reverse.Size()-1 && reverse[i-1]-node==node-reverse[i+1])continue;
            vector2 point=origin+(node%width*unit,node/width*unit);
            PointX.Push(point.X);PointY.Push(point.Y);
        }
        return PointX.Size()>0;
    }
}
