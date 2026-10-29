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
    bool Wall(CaelumPlayer user,Actor ignored)
    {
        vector3 eye=user.Pos+(0,0,user.ViewHeight);
        vector3 direction=(Cos(user.Angle)*Cos(user.Pitch),Sin(user.Angle)*Cos(user.Pitch),-Sin(user.Pitch));
        let trace=new('CaelumTargetTrace');
        if(!trace.Trace(eye,user.CurSector,direction,user.UseRange,TRACE_PortalRestrict,
            Line.ML_BLOCKING|Line.ML_BLOCKEVERYTHING|Line.ML_BLOCKHITSCAN,false,user))return false;
        let line=trace.Results.HitLine;
        if(line==null || line.backsector!=null || line.special!=0 || line.frontsector==null
            || line.frontsector.floordata!=null || line.frontsector.ceilingdata!=null)return false;
        vector2 tangent=line.v2.p-line.v1.p;double length=tangent.Length();if(length<=0)return false;
        tangent/=length;vector2 normal=(-tangent.Y,tangent.X);
        vector3 hit=trace.Results.HitPos;
        if((eye.X-hit.X)*normal.X+(eye.Y-hit.Y)*normal.Y<0)normal=-normal;
        double along=(hit.X-line.v1.p.X)*tangent.X+(hit.Y-line.v1.p.Y)*tangent.Y;
        double half=CaelumDecorData.Width(0)/2;
        if(along<half || along>length-half)return false;
        vector3 point=hit+(normal.X,normal.Y,0)*(CaelumDecorData.PICTURE_DEPTH/2+.125)-(0,0,CaelumDecorData.Height(0)/2);
        ResultPoint=point;ResultAngle=VectorAngle(normal.X,normal.Y);
        if(!CaelumCampLand.AllowsFurniture(user,point,CaelumDecorData.PICTURE_DEPTH))return false;
        // Nueve muestras mantienen el marco entero delante de una misma pared,
        // dentro del volumen libre. No se coloca sobre ventanas ni puertas.
        let probe=CaelumPlacementProbe(Actor.Spawn('CaelumPlacementProbe',point,NO_REPLACE));if(probe==null)return false;
        bool fits=true;
        for(int x=-1;x<=1 && fits;x++)for(int z=0;z<=2 && fits;z++)
        {
            vector3 sample=point+(tangent.X,tangent.Y,0)*(half*x)+(0,0,CaelumDecorData.Height(0)*z/2);
            probe.A_SetSize(.125,.125,false);probe.SetOrigin(sample,false);probe.FindFloorCeiling();
            fits=probe.TestMobjLocation() && sample.Z>=probe.FloorZ && sample.Z+.125<probe.CeilingZ;
        }
        probe.SetOrigin(point,false);
        let things=BlockThingsIterator.Create(probe,CaelumDecorData.Radius(0)+user.Radius);
        while(things.Next() && fits)
        {
            let other=things.thing;
            if(other==probe || other==ignored || other==user || other.bNoBlockmap || other.bInvisible)continue;
            if(other.Pos.Z>=point.Z+CaelumDecorData.Height(0) || other.Pos.Z+other.Height<=point.Z)continue;
            if(!other.bSolid && !(other is 'CaelumDecorBody') && !(other is 'CaelumHousePortal'))continue;
            vector2 delta=other.Pos.XY-point.XY;
            fits=Abs(delta.X*tangent.X+delta.Y*tangent.Y)>=half+other.Radius
                || Abs(delta.X*normal.X+delta.Y*normal.Y)>=CaelumDecorData.PICTURE_DEPTH+other.Radius;
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
        user.RefreshCarriedInventorySummary();if(!user.CanAddWeightToPersonalInventory(GetUnitWeight()))return false;
        CaelumContaminationObject.LeavingWorld(Decoration);DetachFromOwner();AttachToOwner(user);InMagicBox=false;Park();
        user.OnNativeInventoryChanged();user.RefreshFormalInventorySnapshot();return true;
    }
    override bool Place(CaelumPlayer user)
    {
        if(!CaelumPlayerAuthority.CanMutate(user) || Owner!=user || InMagicBox || Amount!=1)return false;
        int k=Kind();double radius=CaelumDecorData.Radius(k),height=CaelumDecorData.Height(k),facing=user.Angle;
        vector3 point=user.Pos+(Cos(user.Angle),Sin(user.Angle),0)*(user.Radius+radius+1);
        if(k==0){let mount=new('CaelumDecorPlacement');if(!mount.Wall(user,Decoration))return false;point=mount.ResultPoint;facing=mount.ResultAngle;}
        else if(!CaelumCampLand.AllowsFurniture(user,point,radius) || !CaelumPlacementGeometry.Fits(user,point,radius,height,Decoration))return false;
        bool fresh=Decoration==null;
        if(fresh)Decoration=CaelumDecorBody(Actor.Spawn(CaelumDecorData.BodyClass(k),point,NO_REPLACE));
        if(Decoration==null)return false;
        CaelumContaminationObject.LeavingWorld(Decoration);Decoration.A_SetSize(radius,height,false);
        Decoration.Angle=facing;Decoration.Mass=int(Ceil(GetUnitWeight()));Decoration.ChangeStatNum(STAT_DEFAULT);
        Decoration.A_ChangeLinkFlags(0,0);Decoration.SetOrigin(point,false);Decoration.FindFloorCeiling();Decoration.bSolid=k!=0;
        if(k!=0 && !Decoration.TestMobjLocation())
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
