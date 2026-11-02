// Decoración sin descanso ni bonificaciones. El inventario conserva el cuerpo
// real y su título; el cuadro usa pared estable, la escultura suelo permitido.
class CaelumDecorBody : CaelumPhysicalScenery abstract
{
    CaelumDecorItem PackedItem;
    bool CanReach(CaelumPlayer user)
    {
        return CaelumPlayerAuthority.CanMutate(user) && user.health>0
            && user.Distance2D(self)<=user.UseRange+Radius
            && CaelumUseGeometry.AimedAt(user,self) && user.CheckSight(self,SF_IGNOREVISIBILITY);
    }
    override bool Used(Actor activator)
    {
        let user=CaelumPlayer(activator);
        return CanReach(user) && PackedItem!=null && (user.player.cmd.buttons&BT_CROUCH)!=0 && PackedItem.Carry(user);
    }
    Default {+NOGRAVITY +CANNOTPUSH +DONTTHRUST +INVULNERABLE +CANPASS}
}
class CaelumLandscapePainting : CaelumDecorBody
{
    Default {Radius CaelumDecorData.PICTURE_RADIUS;Height CaelumDecorData.PICTURE_HEIGHT;Tag "$CA_DECOR_PAINTING";}
    States {Spawn:COAP A -1;Stop;}
}
class CaelumOrnamentalStatue : CaelumDecorBody
{
    Default {Radius CaelumDecorData.STATUE_RADIUS;Height CaelumDecorData.STATUE_HEIGHT;+SOLID Tag "$CA_DECOR_STATUE";}
    States {Spawn:COAS A -1;Stop;}
}

class CaelumDecorPlacement : Object play
{
    vector3 ResultPoint;
    double ResultAngle;
    bool StaticWall(Line wall,vector3 bottom,double height)
    {
        if(wall==null || wall.special!=0 || wall.frontsector==null
            || wall.frontsector.floordata!=null || wall.frontsector.ceilingdata!=null)return false;
        if(wall.backsector==null)return true;
        let back=wall.backsector;let front=wall.frontsector;
        if(back.floordata!=null || back.ceilingdata!=null)return false;
        double low=Max(front.floorplane.ZatPoint(bottom.XY),back.floorplane.ZatPoint(bottom.XY));
        double high=Min(front.ceilingplane.ZatPoint(bottom.XY),back.ceilingplane.ZatPoint(bottom.XY));
        return high<=low || bottom.Z+height<=low || bottom.Z>=high;
    }
    bool Covered(Actor probe,vector3 hit,vector2 tangent,vector2 normal,double half,double height)
    {
        // Un cuadro grande puede cruzar segmentos contiguos de la misma pared.
        // Consulta local al colocar: la unión debe cubrir todo el ancho, sin huecos.
        Array<double> starts,ends;
        let nearby=BlockLinesIterator.Create(probe,half+1);
        while(nearby.Next())
        {
            let wall=nearby.CurLine;
            if(!StaticWall(wall,probe.Pos,height))continue;
            vector2 a=wall.v1.p-hit.XY,b=wall.v2.p-hit.XY;
            if(Abs(a.X*normal.X+a.Y*normal.Y)>.125 || Abs(b.X*normal.X+b.Y*normal.Y)>.125)continue;
            double lo=a.X*tangent.X+a.Y*tangent.Y,hi=b.X*tangent.X+b.Y*tangent.Y;
            starts.Push(Min(lo,hi));ends.Push(Max(lo,hi));
        }
        double covered=-half;
        for(int pass=0;pass<starts.Size() && covered<half;pass++)
        {
            double previous=covered;
            for(int i=0;i<starts.Size();i++)
                if(starts[i]<=covered+.0001 && ends[i]>covered)covered=ends[i];
            if(covered==previous)return false;
        }
        return covered>=half;
    }
    bool Wall(CaelumPlayer user,Actor ignored,int kind=0)
    {
        vector3 eye=user.Pos+(0,0,user.ViewHeight);
        vector3 direction=(Cos(user.Angle)*Cos(user.Pitch),Sin(user.Angle)*Cos(user.Pitch),-Sin(user.Pitch));
        let trace=new('CaelumTargetTrace');
        if(!trace.Trace(eye,user.CurSector,direction,user.UseRange,TRACE_PortalRestrict,
            Line.ML_BLOCKING|Line.ML_BLOCKEVERYTHING|Line.ML_BLOCKHITSCAN,false,user))return false;
        let line=trace.Results.HitLine;
        if(!StaticWall(line,trace.Results.HitPos-(0,0,CaelumDecorData.Height(kind)/2),CaelumDecorData.Height(kind)))return false;
        vector2 tangent=line.v2.p-line.v1.p;double length=tangent.Length();if(length<=0)return false;
        tangent/=length;vector2 normal=(-tangent.Y,tangent.X);
        vector3 hit=trace.Results.HitPos;
        if((eye.X-hit.X)*normal.X+(eye.Y-hit.Y)*normal.Y<0)normal=-normal;
        double half=CaelumDecorData.Width(kind)/2;
        vector3 point=hit+(normal.X,normal.Y,0)*(CaelumDecorData.Depth(kind)/2+.125)-(0,0,CaelumDecorData.Height(kind)/2);
        ResultPoint=point;ResultAngle=VectorAngle(normal.X,normal.Y);
        if(!CaelumCampLand.AllowsFurniture(user,point,CaelumDecorData.Depth(kind)))return false;
        // Nueve muestras mantienen el marco entero delante de una misma pared,
        // dentro del volumen libre. No se coloca sobre ventanas ni puertas.
        let probe=CaelumPlacementProbe(Actor.Spawn('CaelumPlacementProbe',point,NO_REPLACE));if(probe==null)return false;
        bool fits=Covered(probe,hit,tangent,normal,half,CaelumDecorData.Height(kind));
        for(int x=-1;x<=1 && fits;x++)for(int z=0;z<=2 && fits;z++)
        {
            vector3 sample=point+(tangent.X,tangent.Y,0)*(half*x)+(0,0,CaelumDecorData.Height(kind)*z/2);
            probe.A_SetSize(.125,.125,false);probe.SetOrigin(sample,false);probe.FindFloorCeiling();
            fits=probe.TestMobjLocation() && sample.Z>=probe.FloorZ && sample.Z+.125<probe.CeilingZ;
        }
        probe.SetOrigin(point,false);
        let things=BlockThingsIterator.Create(probe,CaelumDecorData.Radius(kind)+user.Radius);
        while(things.Next() && fits)
        {
            let other=things.thing;
            if(other==probe || other==ignored || other==user || other.bNoBlockmap || other.bInvisible)continue;
            if(other.Pos.Z>=point.Z+CaelumDecorData.Height(kind) || other.Pos.Z+other.Height<=point.Z)continue;
            if(!other.bSolid && !(other is 'CaelumDecorBody') && !(other is 'CaelumHousePortal'))continue;
            vector2 delta=other.Pos.XY-point.XY;
            fits=Abs(delta.X*tangent.X+delta.Y*tangent.Y)>=half+other.Radius
                || Abs(delta.X*normal.X+delta.Y*normal.Y)>=CaelumDecorData.Depth(kind)+other.Radius;
        }
        probe.Destroy();return fits;
    }
}

class CaelumDecorItem : CaelumRestFurnitureItem abstract
{
    CaelumDecorBody Decoration;
    override int Variant(){return CaelumRestFurnitureData.FIRST_DECOR_VARIANT;}
    int Kind(){return Variant()-CaelumRestFurnitureData.FIRST_DECOR_VARIANT;}
    override bool HasBody(){return Decoration!=null;}
    override void Park()
    {
        if(Decoration==null)return;
        CaelumStudyUse.ClearContacts(Decoration);Decoration.bInvisible=true;Decoration.bSolid=false;
        Decoration.A_ChangeLinkFlags(1,1);Decoration.ChangeStatNum(CaelumRestFurnitureData.PARKED_STAT);
    }
    override bool CanCarry(CaelumPlayer user)
    {return Decoration!=null && Owner==Decoration && Decoration.CanReach(user)
        && CaelumLockRules.SameTitle(LawfulOwner,CaelumLockRules.Character(user));}
    override bool Carry(CaelumPlayer user)
    {
        if(!CanCarry(user))return false;
        int route=CaelumTarotStar.CarryRoute(user,self,GetUnitWeight());if(route<0)return false;
        CaelumContaminationObject.LeavingWorld(Decoration);DetachFromOwner();AttachToOwner(user);InMagicBox=route==1;Park();
        user.OnNativeInventoryChanged();user.RefreshFormalInventorySnapshot();return true;
    }
    override bool Place(CaelumPlayer user)
    {
        if(!CaelumPlayerAuthority.CanMutate(user) || Owner!=user || InMagicBox || Amount!=1)return false;
        int k=Kind();double radius=CaelumDecorData.Radius(k),height=CaelumDecorData.Height(k),facing=user.Angle;
        vector3 point=user.Pos+(Cos(user.Angle),Sin(user.Angle),0)*(user.Radius+radius+1);
        point=CaelumTarotStar.Point(user,point);
        if(CaelumDecorData.WallMounted(k) && !CaelumTarotStar.Dropping(user)){let mount=new('CaelumDecorPlacement');if(!mount.Wall(user,Decoration,k))return false;point=mount.ResultPoint;facing=mount.ResultAngle;}
        else if(!CaelumTarotStar.Land(user,point,radius) || !CaelumPlacementGeometry.Fits(user,point,radius,height,Decoration))return false;
        bool fresh=Decoration==null;
        if(fresh)Decoration=CaelumDecorBody(Actor.Spawn(CaelumDecorData.BodyClass(k),point,NO_REPLACE));
        if(Decoration==null)return false;
        CaelumContaminationObject.LeavingWorld(Decoration);Decoration.A_SetSize(radius,height,false);
        Decoration.Angle=facing;Decoration.Mass=int(Ceil(GetUnitWeight()));Decoration.ChangeStatNum(STAT_DEFAULT);
        Decoration.A_ChangeLinkFlags(0,0);Decoration.SetOrigin(point,false);Decoration.FindFloorCeiling();Decoration.bSolid=!CaelumDecorData.WallMounted(k);
        if(!CaelumDecorData.WallMounted(k) && !Decoration.TestMobjLocation())
        {if(fresh){Decoration.Destroy();Decoration=null;}else Park();return false;}
        Decoration.PackedItem=self;Decoration.bInvisible=false;DetachFromOwner();AttachToOwner(Decoration);
        LawfulOwner=CaelumLockRules.Character(user,true);CaelumContaminationObject.Register(Decoration);
        user.OnNativeInventoryChanged();user.RefreshFormalInventorySnapshot();return true;
    }
    override void PreTravelled()
    {
        Super.PreTravelled();if(Decoration==null)return;
        CaelumStudyUse.ClearContacts(Decoration);TravelTID=Decoration.TID;Decoration.ChangeTid(0);
        Decoration.UnlinkFromWorld();Decoration.ChangeStatNum(STAT_TRAVELLING);ContentTravelTIDs.Clear();
        for(Inventory i=Decoration.Inv;i!=null;i=i.Inv)
        {CaelumStudyUse.ClearContacts(i);ContentTravelTIDs.Push(i.TID);i.ChangeTid(0);i.UnlinkFromWorld();i.ChangeStatNum(STAT_TRAVELLING);}
    }
    override void Travelled()
    {
        Super.Travelled();if(Decoration==null || Owner==null)return;
        Decoration.SetOrigin(Owner.Pos,false);Decoration.FindFloorCeiling();Decoration.ChangeTid(TravelTID);TravelTID=0;Park();
        int n=0;for(Inventory i=Decoration.Inv;i!=null;i=i.Inv)
        {i.SetOrigin(Owner.Pos,false);i.FindFloorCeiling();i.ChangeStatNum(STAT_INVENTORY);i.LinkToWorld();if(n<ContentTravelTIDs.Size())i.ChangeTid(ContentTravelTIDs[n++]);}
        ContentTravelTIDs.Clear();
    }
}
class CaelumPaintingItem : CaelumDecorItem
{
    Default {Tag "$CA_DECOR_PAINTING";Inventory.Icon "sprites/caelum/ornamental/COTPA0.png";Scale 0.025;}
    States {Spawn:COTP A -1;Stop;}
}
class CaelumStatueItem : CaelumDecorItem
{
    override int Variant(){return CaelumRestFurnitureData.FIRST_DECOR_VARIANT+1;}
    Default {Tag "$CA_DECOR_STATUE";Inventory.Icon "sprites/caelum/ornamental/COTSA0.png";Scale 0.025;}
    States {Spawn:COTS A -1;Stop;}
}

class CaelumLargeLandscapePainting : CaelumLandscapePainting
{
    Default {Radius CaelumDecorData.LARGE_PICTURE_RADIUS;Height CaelumDecorData.LARGE_PICTURE_HEIGHT;Tag "$CA_DECOR_PAINTING_LARGE";}
    States {Spawn:COAL A -1;Stop;}
}
class CaelumLargePaintingItem : CaelumPaintingItem
{
    override int Variant(){return CaelumRestFurnitureData.FIRST_DECOR_VARIANT+2;}
    Default {Tag "$CA_DECOR_PAINTING_LARGE";}
}
