// #411: comprobación local bajo demanda, antes de mover el objeto real.
// La tolerancia de apoyo coincide con CaelumRestBag; no cambia escalas físicas.
class CaelumPlacementProbe : Actor
{
    Default
    {
        Radius 1; Height 1;
        +SOLID +NOBLOCKMAP +NOGRAVITY +THRUACTORS +CANPASS
        RenderStyle "None";
    }
    States { Spawn: TNT1 A -1; Stop; }
}

class CaelumPlacementGeometry : Object play
{
    const SUPPORT_TOLERANCE_MU=1.0;
    // La hoja lateral existente recorre 64 MU; consultar su posición retirada
    // conserva el hueco cerrado sin buscar actores en todo el mapa.
    const SLIDING_DOOR_TRAVEL_MU=64.0;

    // SAT para el rectángulo nativo alineado a los ejes. Incluye extremos y
    // contactos: una línea de acceso sobre el borde no queda libre.
    static clearscope bool CrossesBox(vector2 a,vector2 b,vector2 center,double radius)
    {
        if(Max(a.X,b.X)<center.X-radius || Min(a.X,b.X)>center.X+radius
            || Max(a.Y,b.Y)<center.Y-radius || Min(a.Y,b.Y)>center.Y+radius)return false;
        vector2 edge=b-a,offset=center-a;
        return Abs(edge.X*offset.Y-edge.Y*offset.X)<=radius*(Abs(edge.X)+Abs(edge.Y));
    }
    static bool Supported(CaelumPlacementProbe probe,vector3 point,double height)
    {
        probe.A_SetSize(1,height,false);probe.SetOrigin(point,false);
        if(!probe.TestMobjLocation() || Abs(probe.FloorZ-point.Z)>SUPPORT_TOLERANCE_MU)return false;
        probe.UpdateWaterLevel(false);
        if(probe.WaterLevel>0 || probe.CurSector==null
            || (probe.floorsector!=null && probe.floorsector.floordata!=null))return false;
        let terrain=probe.GetFloorTerrain();
        if(terrain.IsLiquid)return false;
        // El radio del actor puede elegir el suelo vecino a igual altura.
        // El sector del punto conserva las franjas estrechas. No confundirlo
        // con agua situada muy por debajo de un puente o piso 3D seco.
        let pointTerrain=probe.CurSector.GetFloorTerrain(Sector.floor);
        return Abs(probe.CurSector.floorplane.ZatPoint(point.XY)-point.Z)>SUPPORT_TOLERANCE_MU
            || !pointTerrain.IsLiquid;
    }
    static bool Fits(CaelumPlayer user,vector3 point,double radius,double height,Actor ignored=null)
    {
        if(user==null || radius<=0 || height<=0)return false;
        let probe=CaelumPlacementProbe(Actor.Spawn('CaelumPlacementProbe',point,NO_REPLACE));
        if(probe==null)return false;
        probe.A_SetSize(radius,height,false);
        bool fits=probe.TestMobjLocation() && Abs(probe.FloorZ-point.Z)<=SUPPORT_TOLERANCE_MU;
        // Nueve apoyos abarcan el cuadrado completo, no un círculo inscrito.
        for(int x=-1;x<=1 && fits;x++)for(int y=-1;y<=1 && fits;y++)
            fits=Supported(probe,point+(x*radius,y*radius,0),height);
        probe.SetOrigin(point,false);probe.A_SetSize(radius,height,false);
        if(fits)
        {
            let things=BlockThingsIterator.Create(probe,radius+user.Radius+SLIDING_DOOR_TRAVEL_MU);
            while(things.Next() && fits)
            {
                let other=things.thing;
                if(other==probe || other==ignored || other.bNoBlockmap)continue;
                if(other.Pos.Z>=point.Z+height || other.Pos.Z+other.Height<=point.Z)continue;
                bool access=other is 'CaelumSlidingDoorLeaf' || other is 'CaelumHousePortal';
                if(!other.bSolid && !access && !(other is 'CaelumCampFire'))continue;
                double clearance=radius+other.Radius+(access?user.Radius:0);
                if(Abs(other.Pos.X-point.X)<clearance && Abs(other.Pos.Y-point.Y)<clearance)fits=false;
                // La hoja abierta se aparta físicamente de su hueco. Su origen
                // cerrado sigue siendo un acceso que no se debe ocupar.
                let door=CaelumSlidingDoorLeaf(other);
                if(door!=null && Abs(door.ClosedPosition.X-point.X)<clearance
                    && Abs(door.ClosedPosition.Y-point.Y)<clearance)fits=false;
            }
        }
        if(fits)
        {
            let lines=BlockLinesIterator.Create(probe,radius+user.Radius);
            Array<Line> nearbyLines;
            while(lines.Next())nearbyLines.Push(lines.CurLine);
            // TestMobjLocation también consulta el blockmap. Terminar primero
            // el iterador nativo evita que esas consultas omitan sus líneas.
            for(int index=0;index<nearbyLines.Size() && fits;index++)
            {
                let line=nearbyLines[index];
                bool access=CaelumTargetPanelData.DoorSpecial(line.special)
                    || CaelumTargetPanelData.TravelSpecial(line.special);
                if(access && CrossesBox(line.v1.p,line.v2.p,point.XY,radius+user.Radius))
                {
                    double floor=line.frontsector.floorplane.ZatPoint(point.XY);
                    double ceiling=line.frontsector.ceilingplane.ZatPoint(point.XY);
                    if(point.Z+height>floor && point.Z<ceiling)fits=false;
                }
                // Una franja estrecha entre muestras también puede ser escalón.
                if(line.backsector!=null && CrossesBox(line.v1.p,line.v2.p,point.XY,radius))
                {
                    vector2 edge=line.v2.p-line.v1.p;
                    double lengthSquared=edge.X*edge.X+edge.Y*edge.Y;
                    vector2 offset=point.XY-line.v1.p;
                    double along=lengthSquared>0?Clamp((offset.X*edge.X+offset.Y*edge.Y)/lengthSquared,0.0,1.0):0;
                    vector2 sample=line.v1.p+edge*along;
                    // Comprobar ambos lados también detecta pequeñas franjas
                    // de agua o escalones entre muestras. FloorZ conserva el
                    // apoyo 3D real, no el suelo de un sótano situado debajo.
                    if(fits && lengthSquared>0)
                    {
                        vector2 normal=(-edge.Y,edge.X)/Sqrt(lengthSquared)*0.01;
                        for(int side=-1;side<=1 && fits;side+=2)
                        {
                            vector2 p=sample+normal*side;
                            if(Abs(p.X-point.X)<=radius && Abs(p.Y-point.Y)<=radius)
                                fits=Supported(probe,(p.X,p.Y,point.Z),height);
                        }
                    }
                }
            }
        }
        probe.Destroy();return fits;
    }
}
