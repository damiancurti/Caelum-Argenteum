// #454: retirada guardada sobre rutas conocidas, con colision individual.
class CaelumBarracasRetreat : Object play
{
    static void Initialize(CaelumSiegeCombatant entry)
    {
        if(entry.RetreatRevision>=CaelumBarracasRetreatData.REVISION)return;
        entry.RetreatGun=-1;entry.RetreatStep=-1;entry.RetreatPointPending=false;
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
        String direction=CaelumBarracasRetreatData.Direction(entry.Lane,point);
        if(direction=="G")return entry.ExitNode.Pos;
        if(direction!=".")return CaelumBarracasRetreatData.Next(entry.Lane,point);
        // Un escalon bajo puede quedar fuera del campo de suelo. Buscar solo
        // dentro del alcance del navegador local, sin recorrer actores.
        double best=1e30;vector3 found=entry.ExitNode.Pos;
        int radius=int(Ceil(body.Radius*16/CaelumBarracasRetreatData.CELL));
        vector3 centre=CaelumBarracasRetreatData.Centre(point);
        for(int x=-radius;x<=radius;x++)for(int y=-radius;y<=radius;y++)
        {
            vector3 candidate=centre+(x*CaelumBarracasRetreatData.CELL,y*CaelumBarracasRetreatData.CELL,0);
            if(CaelumBarracasRetreatData.Direction(entry.Lane,candidate)==".")continue;
            double distance=(candidate-point).Length();
            if(distance<best){best=distance;found=candidate;}
        }
        return found;
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
        if(!entry.RetreatPointPending || (entry.RetreatPoint-body.Pos).Length()<0.5)
        {entry.RetreatPoint=GroundPoint(entry);entry.RetreatPointPending=true;}
        return entry.RetreatPoint;
    }
}
