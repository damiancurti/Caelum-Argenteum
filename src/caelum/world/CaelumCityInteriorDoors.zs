// Sólo agrega hojas a los vanos existentes: conserva WAD, vecinos, muebles y
// rutas guardados. Un cuerpo en el vano aplaza esa pareja hasta dejarlo libre.
class CaelumCityInteriorDoors : Object play
{
    static bool Occupied(vector3 center,int axis,Array<Actor> bodies)
    {
        for(int i=0;i<bodies.Size();i++)
        {
            let body=bodies[i];
            if(body.Pos.Z>=center.Z+GetDefaultByType("CaelumHingedDoorLeaf").Height
                || body.Pos.Z+body.Height<=center.Z)continue;
            vector2 delta=body.Pos.XY-center.XY;
            double along=axis==0?Abs(delta.X):Abs(delta.Y);
            double across=axis==0?Abs(delta.Y):Abs(delta.X);
            if(along<2*CaelumMansionDoorData.HALF_WIDTH+body.Radius
                && across<GetDefaultByType("CaelumHingedDoorLeaf").Radius+body.Radius)return true;
        }
        return false;
    }

    static void Ensure(CaelumPortSiege port)
    {
        if(CaelumHouseHub.IsCity(port))return;
        // El mapa nativo ya contiene las seis hojas de cada vivienda.
        if(port!=null && port.args[4]==1)return;
        if(port==null || !CaelumCityData.Enabled()
            || port.InteriorDoorRevision>=CaelumCityData.INTERIOR_DOOR_REVISION
            || level.time%TICRATE!=0)return;
        Array<CaelumHingedDoorLeaf> leaves;
        Array<Actor> bodies;
        let it=ThinkerIterator.Create("Actor");Actor actor;
        while((actor=Actor(it.Next()))!=null)
        {
            let leaf=CaelumHingedDoorLeaf(actor);
            if(leaf!=null)leaves.Push(leaf);
            else if(actor.bSolid && !actor.bNoClip && !(actor is "CaelumSlidingDoorBlocker"))bodies.Push(actor);
        }
        bool complete=true;
        for(int house=0;house<CaelumCityData.HOUSE_COUNT;house++)
            for(int door=0;door<CaelumCityData.INTERIOR_DOOR_COUNT;door++)
            {
                int group=CaelumCityData.InteriorDoorGroup(house,door);
                bool left=false,right=false;
                for(int i=0;i<leaves.Size();i++)if(leaves[i].args[0]==group)
                {if(leaves[i].args[1]<0)left=true;else right=true;}
                if(left && right)continue;
                int axis=CaelumCityData.InteriorDoorAxis(door);
                if(Occupied(CaelumCityData.InteriorDoorCenter(house,door),axis,bodies))
                {complete=false;continue;}
                for(int side=-1;side<=1;side+=2)
                {
                    if(side<0?left:right)continue;
                    let leaf=CaelumHingedDoorLeaf(Actor.Spawn("CaelumHingedDoorLeaf",
                        CaelumCityData.InteriorDoorLeafPosition(house,door,side),NO_REPLACE));
                    if(leaf==null){complete=false;continue;}
                    leaf.args[0]=group;leaf.args[1]=side;leaf.args[2]=axis;
                    // PostBeginPlay nativo aún debe fijar el origen cerrado.
                    leaves.Push(leaf);
                }
            }
        if(complete)port.InteriorDoorRevision=CaelumCityData.INTERIOR_DOOR_REVISION;
    }
}
