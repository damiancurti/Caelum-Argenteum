// #194: parche plano sobre las caras de las cajas nativas. Los polígonos se
// expresan en coordenadas anatómicas (frente, lateral, altura), pero su área
// se mide en m². Recortar y retirar cada región conserva la prioridad del perfil.
class CaelumImpactPolygon : Object
{
    Array<double> PointsX;
    Array<double> PointsY;
    Array<double> PointsZ;
    void Add(Vector3 point) { PointsX.Push(point.X); PointsY.Push(point.Y); PointsZ.Push(point.Z); }
    Vector3 Point(int index) { return (PointsX[index],PointsY[index],PointsZ[index]); }

    static double Component(Vector3 point, int axis)
    { return axis == 0 ? point.X : axis == 1 ? point.Y : point.Z; }

    CaelumImpactPolygon Clip(int axis, double boundary, bool greater, bool strict=false)
    {
        let result = new("CaelumImpactPolygon");
        if (PointsX.Size() < 3) return result;
        if (strict)
        {
            bool hasInterior=false;
            for (int i=0;i<PointsX.Size();i++)
                if ((Component(Point(i),axis)-boundary)*(greater ? 1 : -1)>0) hasInterior=true;
            if (!hasInterior) return result;
        }
        Vector3 previous = Point(PointsX.Size()-1);
        double previousDistance = (Component(previous,axis)-boundary)*(greater ? 1 : -1);
        for (int i=0; i<PointsX.Size(); i++)
        {
            Vector3 current = Point(i);
            double distance = (Component(current,axis)-boundary)*(greater ? 1 : -1);
            if ((distance >= 0) != (previousDistance >= 0))
                result.Add(previous+(current-previous)*(previousDistance/(previousDistance-distance)));
            if (distance >= 0) result.Add(current);
            previous = current;
            previousDistance = distance;
        }
        return result;
    }

    double Area(double radius, double height)
    {
        if (PointsX.Size()<3) return 0;
        double total=0;
        for (int i=1; i<PointsX.Size()-1; i++)
        {
            Vector3 a=Point(i)-Point(0), b=Point(i+1)-Point(0);
            a=(a.X*radius,a.Y*radius,a.Z*height);
            b=(b.X*radius,b.Y*radius,b.Z*height);
            Vector3 areaVector=(a.Y*b.Z-a.Z*b.Y,a.Z*b.X-a.X*b.Z,a.X*b.Y-a.Y*b.X);
            total+=areaVector.Length()*0.5;
        }
        return total/(CaelumPhysicsUnits.MAP_UNITS_PER_METER**2);
    }
}

class CaelumImpactArea : Object
{
    double RegionArea[16];
    double TotalArea;
    double NeutralArea;

    void AddWorldPoint(CaelumImpactPolygon polygon, Actor receiver, Vector3 point)
    {
        Vector3 offset=point-receiver.Pos;
        double radius=Max(0.0001,receiver.Radius);
        polygon.Add(((offset.X*Cos(receiver.Angle)+offset.Y*Sin(receiver.Angle))/radius,
            (-offset.X*Sin(receiver.Angle)+offset.Y*Cos(receiver.Angle))/radius,
            offset.Z/Max(0.0001,receiver.Height)));
    }

    void Build(Actor receiver, Actor source, CaelumAnatomyProfile profile,
        double minimumHeight, double maximumHeight, Vector3 normal=(0,0,0),
        bool customBounds=false, Vector3 lowerBound=(0,0,0), Vector3 upperBound=(0,0,0))
    {
        for (int i=0;i<16;i++) RegionArea[i]=0;
        TotalArea=0; NeutralArea=0;
        if (receiver==null || profile==null || receiver.Radius<=0 || receiver.Height<=0) return;
        bool vertical=Abs(normal.Z)>Max(Abs(normal.X),Abs(normal.Y));
        if (normal.LengthSquared()==0)
        {
            // Sólo un contacto explícito con base/cima permite inferir una cara vertical.
            vertical=minimumHeight==maximumHeight && (minimumHeight==0 || minimumHeight==1);
            if (source!=null && source!=receiver) normal=source.Pos-receiver.Pos;
            else if (!vertical) return; // Geometría desconocida: neutral, nunca cabeza arbitraria.
        }
        double left=receiver.Pos.X-receiver.Radius, right=receiver.Pos.X+receiver.Radius;
        double bottom=receiver.Pos.Y-receiver.Radius, top=receiver.Pos.Y+receiver.Radius;
        double low=receiver.Pos.Z+Clamp(minimumHeight,0.0,1.0)*receiver.Height;
        double high=receiver.Pos.Z+Clamp(maximumHeight,0.0,1.0)*receiver.Height;
        bool finite=customBounds || (source!=null && source!=receiver);
        if (finite && !customBounds)
        {
            lowerBound=source.Pos-(source.Radius,source.Radius,0);
            upperBound=source.Pos+(source.Radius,source.Radius,source.Height);
        }
        if (finite && !vertical)
        {
            low=Max(low,lowerBound.Z);
            high=Min(high,upperBound.Z);
        }
        let polygon=new("CaelumImpactPolygon");
        if (vertical)
        {
            if (finite)
            {
                left=Max(left,lowerBound.X); right=Min(right,upperBound.X);
                bottom=Max(bottom,lowerBound.Y); top=Min(top,upperBound.Y);
            }
            if (right<=left || top<=bottom) return;
            double z=minimumHeight==0 ? receiver.Pos.Z : receiver.Pos.Z+receiver.Height;
            AddWorldPoint(polygon,receiver,(left,bottom,z)); AddWorldPoint(polygon,receiver,(right,bottom,z));
            AddWorldPoint(polygon,receiver,(right,top,z)); AddWorldPoint(polygon,receiver,(left,top,z));
        }
        else if (Abs(normal.X)>=Abs(normal.Y))
        {
            if (finite) { bottom=Max(bottom,lowerBound.Y); top=Min(top,upperBound.Y); }
            if (top<=bottom || high<=low) return;
            double x=normal.X>=0 ? right : left;
            AddWorldPoint(polygon,receiver,(x,bottom,low)); AddWorldPoint(polygon,receiver,(x,top,low));
            AddWorldPoint(polygon,receiver,(x,top,high)); AddWorldPoint(polygon,receiver,(x,bottom,high));
        }
        else
        {
            if (finite) { left=Max(left,lowerBound.X); right=Min(right,upperBound.X); }
            if (right<=left || high<=low) return;
            double y=normal.Y>=0 ? top : bottom;
            AddWorldPoint(polygon,receiver,(left,y,low)); AddWorldPoint(polygon,receiver,(right,y,low));
            AddWorldPoint(polygon,receiver,(right,y,high)); AddWorldPoint(polygon,receiver,(left,y,high));
        }
        Partition(polygon,profile,receiver.Radius,receiver.Height);
    }

    void Partition(CaelumImpactPolygon polygon, CaelumAnatomyProfile profile, double radius, double height)
    {
        TotalArea=polygon.Area(radius,height);
        Array<CaelumImpactPolygon> remaining;
        remaining.Push(polygon);
        for (int region=0;region<profile.RegionCount;region++)
        {
            int mirrors=profile.UsesDirectionalRegions ? 1 : 2;
            for (int mirror=0;mirror<mirrors;mirror++)
            {
                Array<CaelumImpactPolygon> next;
                double lateralLow=profile.RegionMinimumLateral[region];
                double lateralHigh=profile.RegionMaximumLateral[region];
                if (mirror==1) { double swap=lateralLow; lateralLow=-lateralHigh; lateralHigh=-swap; }
                for (int fragment=0;fragment<remaining.Size();fragment++)
                {
                    CaelumImpactPolygon inside=remaining[fragment];
                    for (int plane=0;plane<6 && inside.PointsX.Size()>=3;plane++)
                    {
                        int axis=plane/2;
                        bool greater=(plane%2)==0;
                        double boundary=axis==0 ? (greater ? profile.RegionMinimumForward[region] : profile.RegionMaximumForward[region])
                            : axis==1 ? (greater ? lateralLow : lateralHigh)
                            : (greater ? profile.RegionMinimumHeight[region] : profile.RegionMaximumHeight[region]);
                        // FindDirectionalRegion limita las coordenadas a [-1,1].
                        if (axis<2 && ((greater && boundary==-1) || (!greater && boundary==1)))
                            boundary=greater ? -1.0e30 : 1.0e30;
                        let outside=inside.Clip(axis,boundary,!greater,true);
                        if (outside.Area(radius,height)>0) next.Push(outside);
                        inside=inside.Clip(axis,boundary,greater);
                    }
                    RegionArea[region]+=inside.Area(radius,height);
                }
                remaining=next;
            }
        }
        NeutralArea=0;
        for (int i=0;i<remaining.Size();i++) NeutralArea+=remaining[i].Area(radius,height);
    }
}
