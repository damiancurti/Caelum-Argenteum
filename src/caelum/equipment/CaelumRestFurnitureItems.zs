// La ficha conserva el cuerpo real mientras se transporta; no recrea su estado.
class CaelumRestFurnitureItem : CaelumStorageFurnitureItem abstract
{
    CaelumRestFurniture Body;
    CaelumLawfulIdentity LawfulOwner;
    int TravelTID;
    Array<int> ContentTravelTIDs;
    override int GetSpecialType(){return CaelumRestFurnitureData.FIRST_KEY+Variant();}
    override double GetUnitWeight(){return CaelumRestFurnitureData.Mass(Variant());}
    virtual bool HasBody(){return Body!=null;}
    override Inventory CreateTossable(int count){return HasBody()?null:Super.CreateTossable(count);}
    virtual void Park()
    {
        if(Body==null)return;
        Body.bInvisible=true;Body.bSolid=false;Body.A_ChangeLinkFlags(1,1);
        Body.ChangeStatNum(CaelumRestFurnitureData.PARKED_STAT);
    }
    virtual bool CanCarry(CaelumPlayer user)
    {
        return CaelumPlayerAuthority.CanMutate(user) && Body!=null && Owner==Body && Body.Occupant==null
            && Body.CanReach(user) && Body.DiningTable==null
            && CaelumLockRules.SameTitle(LawfulOwner,CaelumLockRules.Character(user));
    }
    virtual bool Carry(CaelumPlayer user)
    {
        if(!CanCarry(user))return false;
        user.RefreshCarriedInventorySummary();if(!user.CanAddWeightToPersonalInventory(GetUnitWeight()))return false;
        CaelumContaminationObject.LeavingWorld(Body);
        DetachFromOwner();AttachToOwner(user);InMagicBox=false;Park();
        user.OnNativeInventoryChanged();user.RefreshFormalInventorySnapshot();return true;
    }
    override bool Place(CaelumPlayer user)
    {
        if(!CaelumPlayerAuthority.CanMutate(user) || Owner!=user || InMagicBox || Amount!=1)return false;
        double radius=CaelumRestFurnitureData.Radius(Variant()),height=CaelumRestFurnitureData.Height(Variant());
        double offset=user.Radius+radius+1;
        vector3 point=user.Pos+(Cos(user.Angle)*offset,Sin(user.Angle)*offset,0);
        if(!CaelumCampLand.AllowsFurniture(user,point,radius) || !CaelumPlacementGeometry.Fits(user,point,radius,height,Body))return false;
        bool fresh=Body==null;
        if(fresh)Body=CaelumRestFurniture(Actor.Spawn(CaelumRestFurnitureData.BodyClass(Variant()),point,NO_REPLACE));
        if(Body==null)return false;
        CaelumContaminationObject.LeavingWorld(Body);
        Body.A_SetSize(radius,height,false);Body.Angle=user.Angle;Body.ChangeStatNum(STAT_DEFAULT);
        Body.A_ChangeLinkFlags(0,0);Body.SetOrigin(point,false);Body.bSolid=true;
        if(!Body.TestMobjLocation() || !user.CheckSight(Body,SF_IGNOREVISIBILITY))
        {if(fresh){Body.Destroy();Body=null;}else Park();return false;}
        Body.PackedItem=self;Body.bInvisible=false;
        DetachFromOwner();AttachToOwner(Body);LawfulOwner=CaelumLockRules.Character(user,true);
        CaelumContaminationObject.Register(Body);
        user.OnNativeInventoryChanged();user.RefreshFormalInventorySnapshot();return true;
    }
    override void PreTravelled()
    {
        Super.PreTravelled();if(Body==null)return;
        TravelTID=Body.TID;Body.ChangeTid(0);Body.UnlinkFromWorld();Body.ChangeStatNum(STAT_TRAVELLING);
        ContentTravelTIDs.Clear();
        for(Inventory i=Body.Inv;i!=null;i=i.Inv)
        {ContentTravelTIDs.Push(i.TID);i.ChangeTid(0);i.UnlinkFromWorld();i.ChangeStatNum(STAT_TRAVELLING);}
    }
    override void Travelled()
    {
        Super.Travelled();if(Body==null || Owner==null)return;
        Body.SetOrigin(Owner.Pos,false);Body.ChangeTid(TravelTID);TravelTID=0;Park();
        int n=0;for(Inventory i=Body.Inv;i!=null;i=i.Inv)
        {i.ChangeStatNum(STAT_INVENTORY);i.LinkToWorld();if(n<ContentTravelTIDs.Size())i.ChangeTid(ContentTravelTIDs[n++]);}
        ContentTravelTIDs.Clear();
    }
}
class CaelumLuxuryChairItem : CaelumRestFurnitureItem
{
    Default {Tag "$CA_LUXURY_CHAIR";Inventory.Icon "sprites/caelum/rest_furniture/CLICA0.png";Scale 0.025;}
    States {Spawn:CLIC A -1;Stop;}
}
class CaelumLuxuryBedItem : CaelumRestFurnitureItem
{
    override int Variant(){return 1;}
    Default {Tag "$CA_LUXURY_BED";Inventory.Icon "sprites/caelum/rest_furniture/CLIBA0.png";Scale 0.025;}
    States {Spawn:CLIB A -1;Stop;}
}
class CaelumBasicChairItem : CaelumRestFurnitureItem
{
    override int Variant(){return 2;}
    Default {Tag "$CA_BASIC_CHAIR";Inventory.Icon "sprites/caelum/rest_furniture/CBICA0.png";Scale 0.025;}
    States {Spawn:CBIC A -1;Stop;}
}
class CaelumBasicBedItem : CaelumRestFurnitureItem
{
    override int Variant(){return 3;}
    Default {Tag "$CA_BASIC_BED";Inventory.Icon "sprites/caelum/rest_furniture/CBIBA0.png";Scale 0.025;}
    States {Spawn:CBIB A -1;Stop;}
}
