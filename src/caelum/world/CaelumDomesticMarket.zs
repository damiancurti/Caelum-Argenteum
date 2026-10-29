// #502: Provisiones conserva un solo actor y sus existencias reales entre mapas.
// El registro no inventa comercios antes de que se haya visitado su ciudad.
class CaelumDomesticVendor : Object play
{
    CaelumCityMerchant Body;
    vector3 Position;
    bool Parked,Invisible,Solid,NoInteraction,NoBlock,NoSector;
    int SavedTID;
    Array<int> ItemTIDs;

    void Depart()
    {
        if(Body==null || Body.bDestroyed)return;
        if(!Parked)
        {
            Position=Body.Pos;Invisible=Body.bInvisible;Solid=Body.bSolid;
            NoInteraction=Body.bNoInteraction;NoBlock=Body.bNOBLOCKMAP;NoSector=Body.bNOSECTOR;
        }
        CaelumContaminationObject.LeavingWorld(Body);
        Body.DomesticMarketParked=true;Parked=true;
        Body.bInvisible=true;Body.bSolid=false;Body.bNoInteraction=true;
        Body.A_ChangeLinkFlags(1,1);Body.Vel=(0,0,0);
        SavedTID=Body.TID;Body.ChangeTid(0);Body.UnlinkFromWorld();
        Body.ChangeStatNum(Thinker.STAT_TRAVELLING);ItemTIDs.Clear();
        for(Inventory item=Body.Inv;item!=null;item=item.Inv)
        {
            ItemTIDs.Push(item.TID);item.ChangeTid(0);item.UnlinkFromWorld();
            item.ChangeStatNum(Thinker.STAT_TRAVELLING);
        }
    }
    void Arrive(Actor owner)
    {
        if(Body==null || Body.bDestroyed)return;
        Body.ChangeStatNum(CaelumHouseResidents.PARKED_STAT);
        Body.SetOrigin(owner.Pos,false);Body.FindFloorCeiling();Body.ChangeTid(SavedTID);
        int i=0;
        for(Inventory item=Body.Inv;item!=null;item=item.Inv)
        {
            item.ChangeStatNum(CaelumHouseResidents.PARKED_STAT);item.SetOrigin(owner.Pos,false);
            if(i<ItemTIDs.Size())item.ChangeTid(ItemTIDs[i++]);
        }
        ItemTIDs.Clear();
    }
    void Restore()
    {
        if(!Parked || Body==null || Body.bDestroyed || level.MapName!="MAP03")return;
        Body.SetOrigin(Position,false);Body.FindFloorCeiling();
        Body.bInvisible=Invisible;Body.bSolid=Solid;Body.bNoInteraction=NoInteraction;
        Body.A_ChangeLinkFlags(NoBlock?1:0,NoSector?1:0);Body.ChangeStatNum(Thinker.STAT_DEFAULT);
        for(Inventory item=Body.Inv;item!=null;item=item.Inv)item.ChangeStatNum(Thinker.STAT_INVENTORY);
        Body.DomesticMarketParked=false;Parked=false;CaelumContaminationObject.Register(Body);
    }
}

class CaelumDomesticMarket : Inventory
{
    int Revision;
    Array<CaelumDomesticVendor> Vendors;
    static CaelumDomesticMarket Get(bool create=false)
    {
        let roster=CaelumHouseResidents.Get(create);if(roster==null)return null;
        let owner=CaelumPlayer(roster.Owner);if(!CaelumPlayerAuthority.CanMutate(owner))return null;
        let market=CaelumDomesticMarket(owner.FindInventory('CaelumDomesticMarket'));
        if(market==null && create)market=CaelumDomesticMarket(owner.GiveInventoryType('CaelumDomesticMarket'));
        return market;
    }
    static CaelumCityMerchant Find(int identity)
    {
        let market=Get();if(market==null)return null;
        for(int i=0;i<market.Vendors.Size();i++)
        {
            let entry=market.Vendors[i];
            if(entry.Body!=null && !entry.Body.bDestroyed && entry.Body.ShopIdentity==identity)return entry.Body;
        }
        return null;
    }
    static void Register(CaelumCityMerchant vendor)
    {
        if(vendor==null || vendor.Category!=0 || level.MapName!="MAP03")return;
        let market=Get(true);if(market==null)return;
        for(int i=0;i<market.Vendors.Size();i++)
            if(market.Vendors[i].Body==vendor){market.Vendors[i].Restore();return;}
        let entry=new('CaelumDomesticVendor');entry.Body=vendor;
        market.Vendors.Push(entry);market.Revision=1;
    }
    static void RebindLoaded()
    {
        if(level.MapName!="MAP03")return;
        let market=Get();
        if(market!=null)for(int i=0;i<market.Vendors.Size();i++)market.Vendors[i].Restore();
        // Migración única al cargar: hasta los comercios ya materializados del
        // mapa. No consulta el universo de actores por tic ni por residente.
        let it=ThinkerIterator.Create('CaelumCityMerchant');CaelumCityMerchant vendor;
        while((vendor=CaelumCityMerchant(it.Next()))!=null)Register(vendor);
    }
    override void PreTravelled()
    {for(int i=0;i<Vendors.Size();i++)Vendors[i].Depart();}
    override void Travelled()
    {for(int i=0;i<Vendors.Size();i++)Vendors[i].Arrive(Owner);}
    override Inventory CreateTossable(int amount){return null;}
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE}
    States {Spawn:TNT1 A -1;Stop;}
}
