// Desvío local acotado: consulta la colisión nativa sin mover el cuerpo.
// La marcha posterior usa TryMove, recursos y cadencia normales.
class CaelumEscortNavigation : Object play
{
    Array<double> PointX,PointY;
    int Cursor, RetryTic;
    vector2 Goal;
    double GoalHeight;
    bool HeightProgress,AllowLateralEscape;
    int SearchBudget;

    void Clear(){PointX.Clear();PointY.Clear();Cursor=0;}
    vector2 Point(int i){return (PointX[i],PointY[i]);}

    vector2 Next(CaelumAnchoredResident body,vector3 goal)
    {
        if((goal.XY-self.Goal).Length()>body.Radius || goal.Z!=GoalHeight){Clear();self.Goal=goal.XY;GoalHeight=goal.Z;}
        while(Cursor<PointX.Size() && (Point(Cursor)-body.Pos.XY).Length()<0.5)Cursor++;
        // Una ruta local puede alcanzar sólo parte de una escalera. Resolver
        // el tramo siguiente desde la altura real alcanzada, sin volver abajo.
        if(Cursor>=PointX.Size() && abs(body.FloorZ-GoalHeight)>body.MaxStepHeight)
        {
            if(level.time>=RetryTic)Build(body,goal);
            if(Cursor>=PointX.Size())return body.Pos.XY;
        }
        return Cursor<PointX.Size() ? Point(Cursor) : goal.XY;
    }

    bool Build(CaelumAnchoredResident body,vector3 goalPoint)
    {
        // Techo total de consultas igual a la cuadrícula fina original (65²),
        // compartido por todas las fases y sus enlaces iniciales.
        SearchBudget=65*65;
        bool found=BuildGrid(body,goalPoint,0);
        if(abs(body.FloorZ-goalPoint.Z)<=body.MaxStepHeight || HeightProgress)return found;
        Array<double> fallbackX,fallbackY;
        if(found)for(int i=0;i<PointX.Size();i++){fallbackX.Push(PointX[i]);fallbackY.Push(PointY[i]);}
        // Una escalera estrecha puede caer entre muestras. Reutilizar la misma
        // cuadrícula acotada con fases desplazadas, sólo si no hubo progreso
        // vertical. No aumentar la ventana ni enumerar actores del mapa.
        for(int phase=1;phase<16 && SearchBudget>0;phase++)
        {
            found=BuildGrid(body,goalPoint,phase);
            if(HeightProgress)return found;
            if(found && fallbackX.Size()==0)
                for(int i=0;i<PointX.Size();i++){fallbackX.Push(PointX[i]);fallbackY.Push(PointY[i]);}
        }
        Clear();
        for(int i=0;i<fallbackX.Size();i++){PointX.Push(fallbackX[i]);PointY.Push(fallbackY[i]);}
        return PointX.Size()>0;
    }

    bool StartLinkFits(CaelumAnchoredResident body,vector2 destination)
    {
        vector2 delta=destination-body.Pos.XY;
        int steps=Max(1,int(Ceil(delta.Length()/Max(1.0,body.Radius/2))));
        double floor=body.FloorZ;
        for(int i=1;i<=steps;i++)
        {
            if(SearchBudget<=0)return false;
            SearchBudget--;FCheckPosition fit;
            if(!body.CheckPosition(body.Pos.XY+delta*i/steps,false,fit)
                || fit.ceilingz-fit.floorz<body.Height
                || fit.floorz-fit.dropoffz>body.MaxDropOffHeight
                || fit.floorz-floor>body.MaxStepHeight || floor-fit.floorz>body.MaxDropOffHeight)return false;
            floor=fit.floorz;
        }
        return true;
    }

    bool BuildGrid(CaelumAnchoredResident body,vector3 goalPoint,int phase)
    {
        Clear();HeightProgress=false;Goal=goalPoint.XY;GoalHeight=goalPoint.Z;vector2 goal=Goal;
        RetryTic=level.time+TICRATE;
        // Dieciséis radios a cada lado; medio radio de precisión cerca del
        // destino. No cambia alcance, velocidad ni tamaño del actor.
        double unit=Max(1.0,body.Radius*((goal-body.Pos.XY).Length()<=body.Radius*8 ? 0.5 : 1.0));
        int half=int(16*body.Radius/unit);
        int width=half*2+1;
        int total=width*width;
        Array<int> nodeState,parent,cost,open,visited;
        Array<double> estimate,nodeHeight;
        nodeState.Resize(total);parent.Resize(total);cost.Resize(total);estimate.Resize(total);
        nodeHeight.Resize(total);
        vector2 origin=body.Pos.XY-(unit*half,unit*half)+(phase%4*unit/4,phase/4*unit/4);
        int start=half*width+half,best=start;
        double bestDistance=(goal-body.Pos.XY).Length();
        double bestHeightError=abs(body.FloorZ-GoalHeight);
        bool differentLevel=bestHeightError>body.MaxStepHeight;
        nodeState[start]=1;cost[start]=0;estimate[start]=bestDistance;open.Push(start);
        nodeHeight[start]=body.FloorZ;
        int examined=0;
        while(open.Size()>0 && examined<total && SearchBudget>0)
        {
            int pick=0;
            for(int i=1;i<open.Size();i++)if(estimate[open[i]]<estimate[open[pick]])pick=i;
            int node=open[pick];open.Delete(pick);nodeState[node]=2;examined++;visited.Push(node);
            vector2 point=node==start ? body.Pos.XY : origin+(node%width*unit,node/width*unit);
            double distance=(goal-point).Length();
            double heightError=abs(nodeHeight[node]-GoalHeight);
            if((differentLevel && heightError<bestHeightError)
                || ((!differentLevel || heightError==bestHeightError) && distance<bestDistance))
            {bestDistance=distance;bestHeightError=heightError;best=node;}
            if(node!=start && distance<unit && heightError<=body.MaxStepHeight){best=node;break;}
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
                    // Conservar suelo y despeje por nodo; cada enlace debe
                    // respetar los escalones y desniveles nativos del cuerpo.
                    if(SearchBudget<=0)break;
                    SearchBudget--;
                    if(!body.CheckPosition(candidate,false,fit)
                        || fit.ceilingz-fit.floorz<body.Height
                        || fit.floorz-fit.dropoffz>body.MaxDropOffHeight)
                    {nodeState[next]=3;continue;}
                    nodeHeight[next]=fit.floorz;
                    if(nodeHeight[next]-nodeHeight[node]>body.MaxStepHeight
                        || nodeHeight[node]-nodeHeight[next]>body.MaxDropOffHeight)continue;
                    if(node==start && phase!=0 && !StartLinkFits(body,candidate))continue;
                    cost[next]=total+1;nodeState[next]=1;open.Push(next);
                }
                if(nodeHeight[next]-nodeHeight[node]>body.MaxStepHeight
                    || nodeHeight[node]-nodeHeight[next]>body.MaxDropOffHeight)continue;
                if(cost[node]+1>=cost[next])continue;
                cost[next]=cost[node]+1;parent[next]=node;
                estimate[next]=cost[next]*unit+(goal-(origin+(nx*unit,ny*unit))).Length();
            }
        }
        // Si otro cuerpo ocupa el destino, acercarse infinitesimalmente deja
        // a dos peatones enfrentados para siempre. Buscar espacio lateral real
        // dentro de la misma consulta; el paso posterior conserva la colisión.
        if((AllowLateralEscape || differentLevel)
            && (!differentLevel || bestHeightError>=abs(body.FloorZ-GoalHeight))
            && bestDistance>(goal-body.Pos.XY).Length()-unit)
        {
            vector2 forward=goal-body.Pos.XY;
            if(forward.Length()>0)
            {
                forward=forward.Unit();vector2 side=(-forward.Y,forward.X);
                double choice=1e30;int escape=start;
                for(int pass=0;pass<2 && escape==start;pass++)
                {
                    vector2 destination=body.Pos.XY+side*body.Radius*4*(pass==0 ? 1 : -1);
                    for(int visit=0;visit<visited.Size();visit++)
                    {
                        int node=visited[visit];
                        if(cost[node]>int(8*body.Radius/unit))continue;
                        vector2 point=origin+(node%width*unit,node/width*unit);
                        if((point-body.Pos.XY).Length()<body.Radius*2)continue;
                        double distance=(point-destination).Length();
                        if(distance<choice || (distance==choice && node<escape)){choice=distance;escape=node;}
                    }
                }
                if(escape!=start)best=escape;
            }
        }
        if(best==start)return false;
        HeightProgress=abs(nodeHeight[best]-GoalHeight)<abs(body.FloorZ-GoalHeight);
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
