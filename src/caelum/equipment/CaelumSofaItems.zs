// El conjunto transporta el mismo sofÃ¡ y sus plazas; no genera asientos de repuesto.
class CaelumSofaItem : CaelumRestFurnitureItem abstract
{
    CaelumSofa Sofa;
    Array<Actor> TravellingParts;
    Array<int> PartTIDs;
    override bool HasBody(){return Sofa!=null;}
    void ParkActor(Actor part)
    {
        if(part==null)return;
        part.bInvisible=true;part.bSolid=false;part.A_ChangeLinkFlags(1,1);
        part.ChangeStatNum(CaelumRestFurnitureData.PARKED_STAT);
    }
    override void Park()
    {
        if(Sofa==null)return;
        ParkActor(Sofa);
        for(int i=0;i<3;i++)ParkActor(Sofa.Seats[i]);
    }
    override bool CanCarry(CaelumPlayer user)
    {
        if(!CaelumPlayerAuthority.CanMutate(user) || Sofa==null || Owner!=Sofa
            || !CaelumLockRules.SameTitle(LawfulOwner,CaelumLockRules.Character(user))
            || user.Distance2D(Sofa)>user.UseRange+Sofa.Radius || Abs(user.Pos.Z-Sofa.Pos.Z)>8
            || !user.CheckSight(Sofa))return false;
        for(int i=0;i<3;i++)if(Sofa.Seats[i]!=null && Sofa.Seats[i].Occupant!=null)return false;
        return true;
    }
    override bool Carry(CaelumPlayer user)
    {
        if(!CanCarry(user))return false;
        int route=CaelumTarotStar.CarryRoute(user,self,GetUnitWeight());if(route<0)return false;
        CaelumContaminationObject.LeavingWorld(Sofa);
        DetachFromOwner();AttachToOwner(user);InMagicBox=route==1;Park();
        user.OnNativeInventoryChanged();user.RefreshFormalInventorySnapshot();return true;
    }
    override bool Place(CaelumPlayer user)
    {
        if(!CaelumPlayerAuthority.CanMutate(user) || Owner!=user || InMagicBox || Amount!=1)return false;
        double radius=CaelumRestFurnitureData.Radius(Variant()),height=CaelumRestFurnitureData.Height(Variant());
        vector3 point=user.Pos+(Cos(user.Angle),Sin(user.Angle),0)*(user.Radius+radius+1);
        point=CaelumTarotStar.Point(user,point);
        if(!CaelumTarotStar.Land(user,point,radius)
            || !CaelumPlacementGeometry.Fits(user,point,radius,height,Sofa))return false;
        bool fresh=Sofa==null;
        if(fresh)Sofa=CaelumSofa(Actor.Spawn(CaelumRestFurnitureData.BodyClass(Variant()),point,NO_REPLACE));
        if(Sofa==null)return false;
        CaelumContaminationObject.LeavingWorld(Sofa);
        Sofa.Configure();Sofa.Angle=user.Angle;Sofa.A_ChangeLinkFlags(0,0);Sofa.SetOrigin(point,false);
        bool fits=CaelumMansionSofas.Fits(Sofa) && user.CheckSight(Sofa,SF_IGNOREVISIBILITY);
        for(int i=0;i<CaelumSofaData.Seats(Sofa.Kind()) && fits;i++)
            fits=CaelumTarotStar.Land(user,Sofa.SeatPosition(i),CaelumSofaData.SEAT_RADIUS)
                && CaelumPlacementGeometry.Fits(user,Sofa.SeatPosition(i),CaelumSofaData.SEAT_RADIUS,height,Sofa);
        if(!fits){if(fresh){Sofa.Destroy();Sofa=null;}else Park();return false;}
        Sofa.SeatsReady=false;Sofa.PrepareSeats();
        if(!Sofa.SeatsReady){if(fresh){Sofa.Destroy();Sofa=null;}else Park();return false;}
        Sofa.PackedItem=self;Sofa.bInvisible=false;Sofa.ChangeStatNum(STAT_DEFAULT);
        for(int i=0;i<CaelumSofaData.Seats(Sofa.Kind());i++)
        {
            let seat=Sofa.Seats[i];seat.Sofa=Sofa;seat.Angle=Sofa.Angle;
            seat.A_ChangeLinkFlags(0,0);seat.SetOrigin(Sofa.SeatPosition(i),false);
            seat.bInvisible=false;seat.bSolid=true;seat.ChangeStatNum(STAT_DEFAULT);
        }
        DetachFromOwner();AttachToOwner(Sofa);LawfulOwner=CaelumLockRules.Character(user,true);
        CaelumContaminationObject.Register(Sofa);
        user.OnNativeInventoryChanged();user.RefreshFormalInventorySnapshot();return true;
    }
    void TravelPart(Actor part)
    {
        if(part==null)return;
        TravellingParts.Push(part);PartTIDs.Push(part.TID);part.ChangeTid(0);
        part.UnlinkFromWorld();part.ChangeStatNum(STAT_TRAVELLING);
    }
    void TravelMember(Actor part)
    {
        if(part==null)return;
        TravelPart(part);
        for(Inventory i=part.Inv;i!=null;i=i.Inv)TravelPart(i);
    }
    override void PreTravelled()
    {
        Super.PreTravelled();TravellingParts.Clear();PartTIDs.Clear();if(Sofa==null)return;
        TravelMember(Sofa);
        for(int i=0;i<3;i++)TravelMember(Sofa.Seats[i]);
    }
    override void Travelled()
    {
        Super.Travelled();if(Owner==null)return;
        for(int i=0;i<TravellingParts.Size();i++)
        {
            let part=TravellingParts[i];if(part==null)continue;
            part.ChangeTid(PartTIDs[i]);part.SetOrigin(Owner.Pos,false);
            if(part is 'Inventory'){part.ChangeStatNum(STAT_INVENTORY);part.LinkToWorld();}
            else ParkActor(part);
        }
        TravellingParts.Clear();PartTIDs.Clear();Park();
    }
}
class CaelumTwoSeatSofaItem : CaelumSofaItem
{
    override int Variant(){return CaelumRestFurnitureData.FIRST_SOFA_VARIANT;}
    Default {Tag "$CA_SOFAS_TWO";Inventory.Icon "sprites/caelum/rest_furniture/CSF2A0.png";Scale 0.025;}
    States {Spawn:CSF2 A -1;Stop;}
}
class CaelumThreeSeatSofaItem : CaelumSofaItem
{
    override int Variant(){return CaelumRestFurnitureData.FIRST_SOFA_VARIANT+1;}
    Default {Tag "$CA_SOFAS_THREE";Inventory.Icon "sprites/caelum/rest_furniture/CSF3A0.png";Scale 0.025;}
    States {Spawn:CSF3 A -1;Stop;}
}
