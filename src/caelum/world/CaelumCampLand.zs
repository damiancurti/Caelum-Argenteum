// Consultas explicitas al montar: nunca un censo periodico de actores.
class CaelumCampLand : Object play
{
    static bool OwnedHouse(CaelumPlayer user,int house)
    {
        let record=CaelumPropertyRules.Find(house);
        return CaelumPropertyRules.Holds(user,record) && record.Current(CaelumScheduleState.Now(user));
    }
    static bool Point(CaelumPlayer user,vector3 point,Sector ground,bool interiorFurniture=false)
    {
        if(user==null || ground==null)return false;
        if(interiorFurniture && CaelumCampLandData.FurnitureInterior(level.MapName))return true;
        int house=CaelumHouseHubData.HouseForMap(level.MapName);
        if(house>=0)return OwnedHouse(user,house);
        if(level.MapName=="MAP03")
        {
            house=CaelumCityData.HouseAt(point);
            if(house>=0)return OwnedHouse(user,house);
            return CaelumCampLandData.Countryside(level.MapName,point);
        }
        return CaelumCampLandData.Garden(level.MapName,TexMan.GetName(ground.GetTexture(Sector.floor)));
    }
    static bool AllowsFurniture(CaelumPlayer user,vector3 point,double radius)
    {return Allows(user,point,radius,true);}
    static bool Allows(CaelumPlayer user,vector3 point,double radius,bool interiorFurniture=false)
    {
        if(user==null)return false;
        let probe=CaelumPlacementProbe(Actor.Spawn('CaelumPlacementProbe',point,NO_REPLACE));
        if(probe==null)return false;
        bool allowed=true;
        for(int x=-1;x<=1 && allowed;x++)for(int y=-1;y<=1 && allowed;y++)
        {
            vector3 p=point+(x*radius,y*radius,0);probe.SetOrigin(p,false);
            allowed=Point(user,p,probe.CurSector,interiorFurniture);
        }
        probe.SetOrigin(point,false);
        let lines=BlockLinesIterator.Create(probe,radius);
        while(lines.Next() && allowed)
        {
            let line=lines.CurLine;
            if(line.backsector==null || !CaelumPlacementGeometry.CrossesBox(line.v1.p,line.v2.p,point.XY,radius))continue;
            vector2 edge=line.v2.p-line.v1.p;double len=edge.Length();if(len<=0)continue;
            vector2 offset=point.XY-line.v1.p;
            vector2 p=line.v1.p+edge*Clamp((offset.X*edge.X+offset.Y*edge.Y)/(len*len),0.0,1.0);
            // La decision del jardin se toma para ambos sectores cruzados;
            // no se permiten franjas pavimentadas entre las nueve muestras.
            allowed=Point(user,(p.X,p.Y,point.Z),line.frontsector,interiorFurniture)
                && Point(user,(p.X,p.Y,point.Z),line.backsector,interiorFurniture);
        }
        probe.Destroy();return allowed;
    }
}
