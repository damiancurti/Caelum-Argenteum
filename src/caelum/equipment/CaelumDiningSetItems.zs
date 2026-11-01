// Conjunto único: mesa, sillas y pertenencias reales viajan con la misma ficha.
class CaelumPortableDiningTable : CaelumDiningTable abstract
{
    CaelumDiningSetItem PackedItem;
    virtual clearscope int Kind(){return 0;}
    bool Packed(){return PackedItem!=null && PackedItem.Owner!=self;}
    override Actor ContentLocation()
    {
        Actor body=self;if(Packed())body=PackedItem.Owner;
        let chest=CaelumStashChest(body);
        if(chest!=null && chest.Cargo!=null && chest.Cargo.Owner!=null)body=chest.Cargo.Owner;
        if(body==null)body=self;return body;
    }
    override bool CanReach(CaelumPlayer user){return !Packed() && Super.CanReach(user);}
    override bool Interact(CaelumPlayer user)
    {
        if(user!=null && user.player!=null && (user.player.cmd.buttons&BT_CROUCH)!=0)
            return PackedItem!=null && PackedItem.Carry(user);
        return Super.Interact(user);
    }
    override void RestockMansion(){}
    override void SyncLocalDay(int day){}
    override int ForecastDailyTarget(){return 0;}
    override int SeatCount(){return CaelumDiningSetData.Seats(Kind());}
    override int Capacity(){return CaelumDiningSetData.Capacity(Kind());}
    override double LengthMU(){return CaelumDiningSetData.Width(Kind());}
    override double WidthMU(){return CaelumDiningSetData.Depth(Kind());}
    override bool RoundTop(){return Kind()==0;}
    override class<CaelumRestChair> ChairClass(){return Kind()==3?'CaelumLuxuryChair':'CaelumRestChair';}
    override double SurfaceHeight(){return CaelumDiningSetData.Height(Kind())/Max(.001,level.pixelstretch);}
    override double ServingScale()
    {int rows=RoundTop()?2:SeatCount()==12?6:3;return Min(1,WidthMU()/(rows*CaelumLuxuryData.SERVING_DIAMETER));}
    override double DisplayMargin(){return CaelumLuxuryData.SERVING_DIAMETER*ServingScale();}
    override void RefreshDisplays()
    {
        if(Packed())return;
        Super.RefreshDisplays();
        if(RoundTop())for(int i=0;i<Capacity();i++)if(Displays[i]!=null)
            Displays[i].SetOrigin(LocalPoint((i%2==0?-1:1)*LengthMU()/4,
                (i<2?-1:1)*WidthMU()/4,SurfaceHeight()),false);
    }
    vector3 SeatPosition(int index)
    {
        double gap=CaelumDiningSetData.SeatClearance(Kind());
        if(SeatCount()==2)return LocalPoint(0,(index==0?-1:1)*(WidthMU()/2+gap));
        int side=(SeatCount()-2)/2;
        if(index<side*2)return LocalPoint((index%side-(side-1)*.5)*Max(LengthMU()/side,CaelumDiningSetData.SeatSpacing(Kind())),
            (index<side?-1:1)*(WidthMU()/2+gap));
        return LocalPoint((index==side*2?-1:1)*(LengthMU()/2+gap),0);
    }
    double SeatAngle(int index)
    {
        if(SeatCount()==2)return Angle+180+(index==0?90:270);
        int side=(SeatCount()-2)/2;
        return Angle+180+(index<side?90:index<side*2?270:index==side*2?0:180);
    }
    bool ConfigureParts()
    {
        A_SetSize(1,CaelumDiningSetData.Height(Kind()),false);Mass=CaelumDiningSetData.TableMass(Kind());
        int cols=RoundTop()?1:int(Ceil(LengthMU()/CaelumLuxuryData.COLLISION_CELL));
        int rows=RoundTop()?1:int(Ceil(WidthMU()/CaelumLuxuryData.COLLISION_CELL));
        double sx=LengthMU()/cols,sy=WidthMU()/rows;
        for(int x=0;x<cols;x++)for(int y=0;y<rows;y++)
        {
            int n=x*rows+y;vector3 p=LocalPoint((x+.5)*sx-LengthMU()/2,(y+.5)*sy-WidthMU()/2);
            if(Blocks[n]==null)Blocks[n]=CaelumDiningBlock(Spawn('CaelumDiningBlock',p,NO_REPLACE));
            if(Blocks[n]==null)return false;
            let b=Blocks[n];b.Table=self;b.A_SetSize(Min(sx,sy)/2,Height,false);b.SetOrigin(p,false);
        }
        for(int i=0;i<SeatCount();i++)
        {
            if(Chairs[i]==null)Chairs[i]=CaelumRestChair(Spawn(ChairClass(),SeatPosition(i),NO_REPLACE));
            if(Chairs[i]==null)return false;
            let chair=Chairs[i];chair.DiningTable=self;chair.DiningSeat=i;chair.Angle=SeatAngle(i);
            chair.A_SetSize(CaelumDiningSetData.ChairRadius(Kind()),CaelumDiningSetData.FullHeight(Kind()),false);
            chair.SetOrigin(SeatPosition(i),false);
        }
        return true;
    }
    override void Tick(){if(!Packed())Super.Tick();}
    override void OnDestroy()
    {
        for(int i=0;i<SeatCount();i++)if(Chairs[i]!=null){Chairs[i].Destroy();Chairs[i]=null;}
        Super.OnDestroy();
    }
    Default {+CANPASS}
}
class CaelumPortableSmallTable : CaelumPortableDiningTable {Default {Tag "$CA_DINING_SET_SMALL";}}
class CaelumPortableNormalTable : CaelumPortableDiningTable {override int Kind(){return 1;} Default {Tag "$CA_DINING_SET_NORMAL";}}
class CaelumPortableLargeTable : CaelumPortableDiningTable {override int Kind(){return 2;} Default {Tag "$CA_DINING_SET_LARGE";}}
class CaelumPortableLuxuryTable : CaelumPortableDiningTable {override int Kind(){return 3;} Default {Tag "$CA_DINING_SET_LUXURY";}}

class CaelumDiningSetItem : CaelumRestFurnitureItem abstract
{
    CaelumPortableDiningTable Table;
    Array<Actor> TravellingParts;
    Array<int> PartTIDs;
    CaelumFoodClimate TravelClimate[60];
    double FoodStamp[60];
    bool FoodReady[60];
    override bool HasBody(){return Table!=null;}
    override void Tick()
    {
        Super.Tick();if(Table==null || !Table.Packed() || level.maptime%TICRATE!=0)return;
        for(int i=0;i<Table.Capacity();i++)
        {let water=CaelumWaterContainer(Table.Items[i]);if(water!=null)water.SyncAmbientTemperature();}
    }
    override double GetUnitWeight()
    {
        double mass=Super.GetUnitWeight();
        if(Table!=null)for(int i=0;i<Table.Capacity();i++)
            if(Table.Items[i]!=null && Table.Items[i].Owner==Table)mass+=Table.Items[i].Amount*Table.Items[i].GetUnitWeight();
        return mass;
    }
    void ParkActor(Actor part)
    {
        if(part==null)return;
        CaelumStudyUse.ClearContacts(part);CaelumContaminationObject.LeavingWorld(part);
        part.bInvisible=true;part.bSolid=false;part.A_ChangeLinkFlags(1,1);
        part.ChangeStatNum(CaelumRestFurnitureData.PARKED_STAT);
    }
    override void Park()
    {
        if(Table==null)return;
        ParkActor(Table);
        for(int i=0;i<Table.SeatCount();i++)ParkActor(Table.Chairs[i]);
        for(int i=0;i<32;i++)ParkActor(Table.Blocks[i]);
        for(int i=0;i<Table.Capacity();i++)ParkActor(Table.Displays[i]);
    }
    void Wake(Actor part,bool solid)
    {
        if(part==null)return;
        part.bInvisible=false;part.bSolid=solid;part.ChangeStatNum(STAT_DEFAULT);
        part.A_ChangeLinkFlags(0,0);part.FindFloorCeiling();
        if(solid)CaelumContaminationObject.Register(part);
    }
    override bool CanCarry(CaelumPlayer user)
    {
        if(!CaelumPlayerAuthority.CanMutate(user) || Table==null || Owner!=Table || Table.LayoutOccupied()
            || !Table.CanReach(user) || !CaelumLockRules.SameTitle(LawfulOwner,CaelumLockRules.Character(user)))return false;
        // No mover un menú abierto por otro jugador.
        for(int p=0;p<MAXPLAYERS;p++)if(playeringame[p])
        {
            let other=CaelumPlayer(players[p].mo);
            if(other!=null && other!=user && other.HasActiveConversation() && Table.CanReach(other))return false;
        }
        return true;
    }
    void AdvanceFood()
    {if(Table!=null)for(int i=0;i<Table.Capacity();i++)CaelumFoodInventory.Relocate(Table.Items[i]);}
    override bool Carry(CaelumPlayer user)
    {
        if(!CanCarry(user))return false;
        user.RefreshCarriedInventorySummary();if(!user.CanAddWeightToPersonalInventory(GetUnitWeight()))return false;
        // Cerrar la exposición mientras las piezas aún pertenecen al mundo.
        AdvanceFood();Park();DetachFromOwner();AttachToOwner(user);InMagicBox=false;AdvanceFood();
        user.OnNativeInventoryChanged();user.RefreshFormalInventorySnapshot();return true;
    }
    override bool Place(CaelumPlayer user)
    {
        if(!CaelumPlayerAuthority.CanMutate(user) || Owner!=user || InMagicBox || Amount!=1)return false;
        int kind=Variant()-CaelumRestFurnitureData.FIRST_DINING_VARIANT;
        double radius=CaelumDiningSetData.Radius(kind),height=CaelumDiningSetData.FullHeight(kind);
        vector3 point=user.Pos+(Cos(user.Angle),Sin(user.Angle),0)*(user.Radius+radius+1);
        point=CaelumTarotStar.Point(user,point);
        if(!CaelumTarotStar.Land(user,point,radius)
            || !CaelumPlacementGeometry.Fits(user,point,radius,height,Table))return false;
        bool fresh=Table==null;
        if(fresh)Table=CaelumPortableDiningTable(Actor.Spawn(CaelumDiningSetData.BodyClass(kind),point,NO_REPLACE));
        if(Table==null)return false;
        AdvanceFood();Table.PackedItem=self;Table.Angle=user.Angle;Table.SetOrigin(point,false);
        bool fits=Table.ConfigureParts();
        Wake(Table,false);
        for(int i=0;i<32;i++)Wake(Table.Blocks[i],true);
        for(int i=0;i<Table.SeatCount();i++)Wake(Table.Chairs[i],true);
        fits=fits && Table.LayoutFits() && user.CheckSight(Table,SF_IGNOREVISIBILITY);
        for(int i=0;i<Table.SeatCount() && fits;i++)
            fits=CaelumTarotStar.Land(user,Table.Chairs[i].Pos,Table.Chairs[i].Radius);
        if(!fits){if(fresh){Table.Destroy();Table=null;}else Park();return false;}
        DetachFromOwner();AttachToOwner(Table);LawfulOwner=CaelumLockRules.Character(user,true);
        for(int i=0;i<32;i++)CaelumContaminationObject.Register(Table.Blocks[i]);
        for(int i=0;i<Table.SeatCount();i++)CaelumContaminationObject.Register(Table.Chairs[i]);
        for(int i=0;i<Table.Capacity();i++)Wake(Table.Displays[i],false);
        Table.RefreshDisplays();AdvanceFood();
        user.OnNativeInventoryChanged();user.RefreshFormalInventorySnapshot();return true;
    }
    void TravelPart(Actor part)
    {
        if(part==null || part==self)return;
        CaelumStudyUse.ClearContacts(part);TravellingParts.Push(part);PartTIDs.Push(part.TID);
        part.ChangeTid(0);part.UnlinkFromWorld();part.ChangeStatNum(STAT_TRAVELLING);
    }
    void TravelMember(Actor part)
    {if(part!=null){TravelPart(part);for(Inventory i=part.Inv;i!=null;i=i.Inv)TravelPart(i);}}
    override void PreTravelled()
    {
        if(TravellingParts.Size()>0)return;
        Super.PreTravelled();if(Table==null)return;
        AdvanceFood();
        for(int i=0;i<Table.Capacity();i++)
        {
            let food=Table.Items[i];let clock=CaelumFoodClock.Get(food);if(clock==null)continue;
            TravelClimate[i]=clock.Climate!=null?clock.Climate.Copy():null;FoodStamp[i]=clock.Stamp;FoodReady[i]=clock.Ready;
            food.FoodClock=null;clock.Destroy();
        }
        TravelMember(Table);
        for(int i=0;i<Table.SeatCount();i++)TravelMember(Table.Chairs[i]);
        for(int i=0;i<32;i++)TravelMember(Table.Blocks[i]);
        for(int i=0;i<Table.Capacity();i++)TravelMember(Table.Displays[i]);
    }
    override void Travelled()
    {
        Super.Travelled();if(Owner==null || Table==null || TravellingParts.Size()==0)return;
        for(int i=0;i<TravellingParts.Size();i++)
        {
            let part=TravellingParts[i];if(part==null)continue;
            CaelumStudyUse.ClearContacts(part);part.ChangeTid(PartTIDs[i]);part.SetOrigin(Owner.Pos,false);part.FindFloorCeiling();
            if(part is 'Inventory'){part.ChangeStatNum(STAT_INVENTORY);part.LinkToWorld();}else ParkActor(part);
        }
        TravellingParts.Clear();PartTIDs.Clear();
        for(int i=0;i<Table.Capacity();i++)
        {
            let clock=CaelumFoodClock.Get(Table.Items[i]);if(clock==null)continue;
            clock.Climate=TravelClimate[i];clock.Stamp=FoodStamp[i];clock.Ready=FoodReady[i];TravelClimate[i]=null;
        }
        Park();
    }
}
class CaelumSmallDiningSetItem : CaelumDiningSetItem
{override int Variant(){return 8;} Default {Tag "$CA_DINING_SET_SMALL";Inventory.Icon "sprites/caelum/rest_furniture/CDS2A0.png";Scale .025;} States {Spawn:CDS2 A -1;Stop;}}
class CaelumNormalDiningSetItem : CaelumDiningSetItem
{override int Variant(){return 9;} Default {Tag "$CA_DINING_SET_NORMAL";Inventory.Icon "sprites/caelum/rest_furniture/CDS6A0.png";Scale .025;} States {Spawn:CDS6 A -1;Stop;}}
class CaelumLargeDiningSetItem : CaelumDiningSetItem
{override int Variant(){return 10;} Default {Tag "$CA_DINING_SET_LARGE";Inventory.Icon "sprites/caelum/rest_furniture/CD12A0.png";Scale .025;} States {Spawn:CD12 A -1;Stop;}}
class CaelumLuxuryDiningSetItem : CaelumDiningSetItem
{override int Variant(){return 11;} Default {Tag "$CA_DINING_SET_LUXURY";Inventory.Icon "sprites/caelum/rest_furniture/CDLXA0.png";Scale .025;} States {Spawn:CDLX A -1;Stop;}}
