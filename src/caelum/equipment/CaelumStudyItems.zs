// Consulta acotada a los jugadores al intentar mover un mueble en uso.
class CaelumStudyUse : Object play
{
    // Estos contactos nativos pertenecen al mapa, no al mueble transportado.
    static void ClearContacts(Actor body)
    {
        if(body==null)return;
        body.BlockingMobj=null;body.BlockingLine=null;body.MovementBlockingLine=null;
        body.Blocking3DFloor=null;body.BlockingCeiling=null;body.BlockingFloor=null;
    }
    static bool Busy(Actor body)
    {
        for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])
        {
            let user=CaelumPlayer(players[i].mo);let session=CaelumRecipeSession.Get(user);
            if(session!=null && session.Active && session.Open
                && (session.StoredDesk==body || (session.StoredSource!=null && session.StoredSource.Shelf==body)))return true;
        }
        return false;
    }
}

class CaelumPortableReadingDesk : CaelumReadingDesk
{
    CaelumDeskItem PackedItem;
    override bool Used(Actor activator)
    {
        let user=CaelumPlayer(activator);
        if(user!=null && user.player!=null && (user.player.cmd.buttons&BT_CROUCH)!=0)
            return CaelumUseGeometry.AimedAt(user,self) && PackedItem!=null && PackedItem.Carry(user);
        return Super.Used(activator);
    }
    Default {Radius CaelumStudyData.DESK_RADIUS;Height CaelumStudyData.DESK_HEIGHT;+CANPASS}
}

class CaelumDeskItem : CaelumRestFurnitureItem
{
    CaelumPortableReadingDesk Desk;
    override int Variant(){return CaelumRestFurnitureData.FIRST_STUDY_VARIANT;}
    override bool HasBody(){return Desk!=null;}
    override void Park()
    {
        if(Desk==null)return;
        CaelumStudyUse.ClearContacts(Desk);
        Desk.bInvisible=true;Desk.bSolid=false;Desk.A_ChangeLinkFlags(1,1);
        Desk.ChangeStatNum(CaelumRestFurnitureData.PARKED_STAT);
    }
    override bool CanCarry(CaelumPlayer user)
    {
        return CaelumPlayerAuthority.CanMutate(user) && Desk!=null && Owner==Desk
            && !CaelumStudyUse.Busy(Desk) && CaelumRecipeSession.CanReach(user,Desk)
            && CaelumLockRules.SameTitle(LawfulOwner,CaelumLockRules.Character(user));
    }
    override bool Carry(CaelumPlayer user)
    {
        if(!CanCarry(user))return false;
        user.RefreshCarriedInventorySummary();if(!user.CanAddWeightToPersonalInventory(GetUnitWeight()))return false;
        CaelumContaminationObject.LeavingWorld(Desk);DetachFromOwner();AttachToOwner(user);InMagicBox=false;Park();
        user.OnNativeInventoryChanged();user.RefreshFormalInventorySnapshot();return true;
    }
    override bool Place(CaelumPlayer user)
    {
        if(!CaelumPlayerAuthority.CanMutate(user) || Owner!=user || InMagicBox || Amount!=1)return false;
        double radius=CaelumStudyData.Radius(0),height=CaelumStudyData.Height(0);
        vector3 point=user.Pos+(Cos(user.Angle),Sin(user.Angle),0)*(user.Radius+radius+1);
        point=CaelumTarotStar.Point(user,point);
        if(!CaelumTarotStar.Land(user,point,radius) || !CaelumPlacementGeometry.Fits(user,point,radius,height,Desk))return false;
        bool fresh=Desk==null;if(fresh)Desk=CaelumPortableReadingDesk(Actor.Spawn('CaelumPortableReadingDesk',point,NO_REPLACE));
        if(Desk==null)return false;
        CaelumContaminationObject.LeavingWorld(Desk);Desk.A_SetSize(radius,height,false);Desk.Mass=CaelumStudyData.Mass(0);Desk.Angle=user.Angle;
        Desk.A_ChangeLinkFlags(0,0);Desk.SetOrigin(point,false);Desk.bSolid=true;
        if(!Desk.TestMobjLocation() || !user.CheckSight(Desk,SF_IGNOREVISIBILITY))
        {if(fresh){Desk.Destroy();Desk=null;}else Park();return false;}
        Desk.PackedItem=self;Desk.bInvisible=false;Desk.ChangeStatNum(STAT_DEFAULT);
        DetachFromOwner();AttachToOwner(Desk);LawfulOwner=CaelumLockRules.Character(user,true);
        CaelumContaminationObject.Register(Desk);user.OnNativeInventoryChanged();user.RefreshFormalInventorySnapshot();return true;
    }
    override void PreTravelled()
    {
        Super.PreTravelled();if(Desk==null)return;
        CaelumStudyUse.ClearContacts(Desk);
        TravelTID=Desk.TID;Desk.ChangeTid(0);Desk.UnlinkFromWorld();Desk.ChangeStatNum(STAT_TRAVELLING);
        ContentTravelTIDs.Clear();
        for(Inventory i=Desk.Inv;i!=null;i=i.Inv)
        {CaelumStudyUse.ClearContacts(i);ContentTravelTIDs.Push(i.TID);i.ChangeTid(0);i.UnlinkFromWorld();i.ChangeStatNum(STAT_TRAVELLING);}
    }
    override void Travelled()
    {
        Super.Travelled();if(Desk==null || Owner==null)return;
        Desk.SetOrigin(Owner.Pos,false);Desk.FindFloorCeiling();Desk.ChangeTid(TravelTID);TravelTID=0;Park();
        int n=0;for(Inventory i=Desk.Inv;i!=null;i=i.Inv)
        {i.SetOrigin(Owner.Pos,false);i.FindFloorCeiling();i.ChangeStatNum(STAT_INVENTORY);i.LinkToWorld();if(n<ContentTravelTIDs.Size())i.ChangeTid(ContentTravelTIDs[n++]);}
        ContentTravelTIDs.Clear();
    }
    Default {Tag "$CA_READING_DESK";Inventory.Icon "sprites/caelum/rest_furniture/CSDKA0.png";Scale 0.025;}
    States {Spawn:CSDK A -1;Stop;}
}

class CaelumPortableReadingShelf : CaelumReadingShelf
{
    override Name StorageClass(){return 'CaelumPortableBookcaseStorage';}
    Default {+NOGRAVITY +CANNOTPUSH +DONTTHRUST +INVULNERABLE +CANPASS}
    override bool Used(Actor activator)
    {
        let user=CaelumPlayer(activator);
        if(user!=null && user.player!=null && (user.player.cmd.buttons&BT_CROUCH)!=0)
            return CaelumUseGeometry.AimedAt(user,self) && CaelumInventoryService.CarryStorageChest(user,GetStorage());
        return Super.Used(activator);
    }
}

class CaelumPortableBookcaseStorage : CaelumBookcaseStorage
{
    Default {+CANPASS}
    override bool CanCarryAsStorage(){return true;}
    override double EmptyStorageWeight(){return CaelumStudyData.Mass(1);}
    override Name CargoClass(){return 'CaelumBookcaseCargo';}
    override bool Accessible(CaelumPlayer user){return Cargo==null && Super.Accessible(user);}
    override bool CanReachStorage(CaelumPlayer user)
    {return Cargo!=null?CaelumPlayerAuthority.CanMutate(user) && Cargo.Owner==user:Super.CanReachStorage(user);}
    override void HideCarriedStorage()
    {
        CaelumStudyUse.ClearContacts(self);Super.HideCarriedStorage();if(Shelf==null)return;
        CaelumStudyUse.ClearContacts(Shelf);
        CaelumContaminationObject.LeavingWorld(Shelf);
        Shelf.bInvisible=true;Shelf.bSolid=false;Shelf.A_ChangeLinkFlags(1,1);
        Shelf.ChangeStatNum(CaelumRestFurnitureData.PARKED_STAT);
    }
    override void RestoreWorldStorage(vector3 point)
    {
        bInvisible=true;bSolid=false;bNoGravity=true;A_ChangeLinkFlags(1,1);SetOrigin(point,false);
        if(Shelf==null)return;
        Shelf.SetOrigin(point,false);Shelf.Angle=Angle;Shelf.bInvisible=false;Shelf.bSolid=true;
        Shelf.A_ChangeLinkFlags(0,0);Shelf.ChangeStatNum(STAT_DEFAULT);CaelumContaminationObject.Register(Shelf);
    }
    override void Tick()
    {
        if(Shelf!=null && Cargo!=null && Cargo.Owner!=null)Shelf.SetOrigin(Cargo.Owner.Pos,false);
        Super.Tick();
    }
}

class CaelumBookcaseCargo : CaelumChestCargo
{
    int ShelfTravelTID;
    Array<int> ShelfContentTIDs;
    override void PreTravelled()
    {
        Super.PreTravelled();let storage=CaelumBookcaseStorage(Chest);
        if(storage==null || storage.Shelf==null)return;
        CaelumStudyUse.ClearContacts(storage);
        for(Inventory entry=storage.Inv;entry!=null;entry=entry.Inv)CaelumStudyUse.ClearContacts(entry);
        let shelf=storage.Shelf;ShelfTravelTID=shelf.TID;shelf.ChangeTid(0);
        CaelumStudyUse.ClearContacts(shelf);
        shelf.UnlinkFromWorld();shelf.ChangeStatNum(STAT_TRAVELLING);ShelfContentTIDs.Clear();
        for(Inventory i=shelf.Inv;i!=null;i=i.Inv)
        {CaelumStudyUse.ClearContacts(i);ShelfContentTIDs.Push(i.TID);i.ChangeTid(0);i.UnlinkFromWorld();i.ChangeStatNum(STAT_TRAVELLING);}
    }
    override void Travelled()
    {
        Super.Travelled();let storage=CaelumBookcaseStorage(Chest);
        if(storage==null || storage.Shelf==null || Owner==null)return;
        storage.FindFloorCeiling();for(Inventory entry=storage.Inv;entry!=null;entry=entry.Inv){entry.SetOrigin(Owner.Pos,false);entry.FindFloorCeiling();}
        let shelf=storage.Shelf;shelf.SetOrigin(Owner.Pos,false);shelf.FindFloorCeiling();shelf.ChangeTid(ShelfTravelTID);ShelfTravelTID=0;
        int n=0;for(Inventory i=shelf.Inv;i!=null;i=i.Inv)
        {i.SetOrigin(Owner.Pos,false);i.FindFloorCeiling();i.ChangeStatNum(STAT_INVENTORY);i.LinkToWorld();if(n<ShelfContentTIDs.Size())i.ChangeTid(ShelfContentTIDs[n++]);}
        ShelfContentTIDs.Clear();storage.HideCarriedStorage();
    }
}

class CaelumBookcaseItem : CaelumRestFurnitureItem
{
    override int Variant(){return CaelumRestFurnitureData.FIRST_STUDY_VARIANT+1;}
    override bool Place(CaelumPlayer user)
    {
        if(!CaelumPlayerAuthority.CanMutate(user) || Owner!=user || InMagicBox || Amount!=1)return false;
        let shelf=CaelumPortableReadingShelf(Actor.Spawn('CaelumPortableReadingShelf',user.Pos,NO_REPLACE));
        if(shelf==null)return false;
        let storage=shelf.GetStorage();if(storage==null){shelf.Destroy();return false;}
        double radius=CaelumStudyData.Radius(1),height=CaelumStudyData.Height(1);
        shelf.A_SetSize(radius,height,false);shelf.Mass=CaelumStudyData.Mass(1);storage.A_SetSize(radius,height,false);storage.Angle=user.Angle;
        let cargo=CaelumBookcaseCargo(Actor.Spawn('CaelumBookcaseCargo',user.Pos,NO_REPLACE));
        if(cargo==null){shelf.Destroy();return false;}
        cargo.Chest=storage;storage.Cargo=cargo;cargo.AttachToOwner(user);storage.HideCarriedStorage();
        if(!storage.TryPlaceStorage(user))
        {cargo.Chest=null;storage.Cargo=null;cargo.Destroy();shelf.Destroy();return false;}
        storage.GrantLawfulTitle(user);CaelumContaminationStorage.Set(shelf,CaelumContaminationStorage.Value(self));
        Destroy();user.OnNativeInventoryChanged();user.RefreshFormalInventorySnapshot();return true;
    }
    Default {Tag "$CA_RECIPE_SHELF";Inventory.Icon "sprites/caelum/rest_furniture/CSBKA0.png";Scale 0.025;}
    States {Spawn:CSBK A -1;Stop;}
}
