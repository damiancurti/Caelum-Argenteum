// Los cofres domésticos conservan su inventario nativo fuera del interior.
// No son carga del jugador ni una copia de existencias para simular compras.
class CaelumHouseStoredFood : Object play
{
    Inventory Item;
    CaelumFoodClimate Climate;
    double Stamp;
    bool Ready;
    void Capture(Inventory item)
    {
        self.Item=item;let clock=CaelumFoodClock.Get(item);if(clock==null)return;
        clock.Advance();Climate=clock.Climate!=null?clock.Climate.Copy():null;
        if(Climate!=null){Climate.HeatDelta=0;Climate.HumidityDelta=0;}
        Stamp=clock.Stamp;Ready=clock.Ready;
        let food=CaelumConsumableItem(item);let material=CaelumMaterialPickup(item);
        if(food!=null)food.FoodClock=null;else if(material!=null)material.FoodClock=null;
        clock.Item=null;clock.Destroy();
    }
    void Restore()
    {
        if(Item==null || Item.bDestroyed)return;
        let clock=CaelumFoodClock.Get(Item);if(clock==null)return;
        clock.Climate=Climate;clock.Stamp=Stamp;clock.Ready=Ready;
    }
}

class CaelumHouseStoredProgress : Object play
{
    String Key;
    double Progress,Initial;
    bool Done;
}

class CaelumHouseStorageEntry : Object play
{
    CaelumStashChest Chest;
    int House,TravelTID;
    vector3 Position;
    bool Parked;
    Array<int> ItemTIDs;
    Array<CaelumHouseStoredFood> Foods;
    CaelumFoodClimate Climate;
    double ClimateStamp;
    double DirtStamp,EnvironmentReference,EnvironmentArea;
    bool EnvironmentCovered;
    Array<CaelumHouseStoredProgress> Progress;
    int WorkDay;
    String ActiveKey;
    bool WorkReady;
    int FurnishingRevision;
    bool FurnishingsPending;
    Array<CaelumHouseStoredFurnishing> Furnishings;
    CaelumHouseAwayWork Away;

    double SourceAt(double civil)
    {return Climate!=null && Climate.Ready?ClimateStamp+Max(0.0,civil-Climate.CivilSeconds):ClimateStamp;}
    double SourceNow(CaelumPlayer user)
    {return Climate!=null && Climate.Ready?SourceAt(CaelumHouseAwayWork.Civil(user)):CaelumThermalRuntime.Stamp(CaelumWorldClock.Get(user));}
    void Rebase(CaelumPlayer user)
    {
        if(!Parked || Climate==null || !Climate.Ready)return;
        double shift=CaelumThermalRuntime.Stamp(CaelumWorldClock.Get(user))-SourceNow(user);
        if(Abs(shift)<.000000001)return;
        ClimateStamp+=shift;DirtStamp+=shift;
        for(int i=0;i<Furnishings.Size();i++){Furnishings[i].Stamp+=shift;Furnishings[i].CivilOffset-=shift;}
        let ledger=CaelumContaminationSurfaces.Get();
        if(ledger!=null)for(int i=0;i<ledger.Maps.Size();i++)if(ledger.Maps[i].Map==CaelumHouseHubData.MapName(House))
        {
            let sheet=ledger.Maps[i];sheet.Epoch+=shift;sheet.CivilOffset-=shift;
            for(int j=0;j<sheet.Tiles.Size();j++)sheet.Tiles[j].Stamp+=shift;
        }
        let reserve=CaelumDomesticWater.Raw(House);if(reserve!=null)reserve.Stamp+=shift;
        for(Inventory item=Chest.Inv;item!=null;item=item.Inv)
        {
            let food=CaelumFoodClock.Get(item);if(food!=null && food.Ready)food.Stamp+=shift;
            let water=CaelumWaterContainer(item);if(water!=null && water.TemperatureClockReady)water.TemperatureStamp+=shift;
        }
        for(int i=0;i<Foods.Size();i++)if(Foods[i].Ready)Foods[i].Stamp+=shift;
    }

    void CaptureFurnishings(CaelumHousekeepingWork work,CaelumPlayer user)
    {
        if(work==null || !work.Initialized || user==null)return;
        Furnishings.Clear();FurnishingRevision=1;FurnishingsPending=true;
        double now=CaelumThermalRuntime.Stamp(CaelumWorldClock.Get(user));
        for(int i=0;i<work.Targets.Size();i++)
        {
            let t=work.Targets[i];let body=t.Furniture;
            if(body==null || body.bDestroyed || body==Chest)continue;
            String key=TargetKey(t);if(key=="")continue;
            let row=new('CaelumHouseStoredFurnishing');row.Capture(body,key,now);Furnishings.Push(row);
        }
    }
    void RestoreFurnishings(CaelumHousekeepingWork work,CaelumPlayer user)
    {
        if(FurnishingRevision!=1 || !FurnishingsPending || work==null || !work.Initialized || user==null)return;
        double now=CaelumThermalRuntime.Stamp(CaelumWorldClock.Get(user));
        for(int i=0;i<work.Targets.Size();i++)
        {
            let t=work.Targets[i];if(t.Furniture==null || t.Furniture.bDestroyed || t.Furniture==Chest)continue;
            String key=TargetKey(t);
            for(int j=0;j<Furnishings.Size();j++)if(Furnishings[j].Key==key)
            {Furnishings[j].Restore(t.Furniture,now);break;}
        }
        FurnishingsPending=false;
    }

    String TargetKey(CaelumDomesticCleanTarget target)
    {
        let tile=target.Tile;
        if(tile!=null)return String.Format("floor:%d:%d:%d:%d:%d",tile.Kind,tile.Surface,tile.Side,tile.X,tile.Y);
        Actor body=target.Furniture;if(target.DomesticCoffer)body=Chest;
        if(body==null || body.bDestroyed)return "";
        if(body==Chest)return "coffer";
        // MAP01 queda fuera del hub 434. Sus instalaciones se recrean al
        // regresar: usar su identidad declarada, nunca el orden del censo.
        let fixture=CaelumDomesticFixture(body);
        if(fixture!=null && fixture.Installed)return String.Format("fixture:%d:%d",fixture.House,fixture.Kind());
        let table=CaelumDiningTable(body);
        if(table!=null && !(table is 'CaelumPortableDiningTable') && table.LayoutSlot!=0)
            return String.Format("table:%d",table.LayoutSlot);
        let rest=CaelumRestFurniture(body);
        if(rest!=null && rest.PackedItem==null)
        {
            if(rest.DiningTable!=null && !(rest.DiningTable is 'CaelumPortableDiningTable'))
                return String.Format("seat:%d:%d",rest.DiningTable.LayoutSlot,rest.DiningSeat);
            if(rest.TrialSlot!=0)return String.Format("rest:%d",rest.TrialSlot);
        }
        let record=CaelumContaminationStorage.Get(body,true);if(record==null)return "";
        if(record.DomesticTargetKey==0)
        {let store=CaelumHouseStorage.Get(true);if(store==null)return "";record.DomesticTargetKey=++store.LastTargetKey;}
        return String.Format("object:%d",record.DomesticTargetKey);
    }
    void CaptureProgress(CaelumHousekeepingWork work)
    {
        Progress.Clear();WorkDay=work.Day;ActiveKey="";WorkReady=true;
        for(int i=0;i<work.Targets.Size();i++)
        {
            let t=work.Targets[i];String key=TargetKey(t);if(key=="")continue;
            let row=new('CaelumHouseStoredProgress');row.Key=key;row.Progress=t.Progress;row.Initial=t.Initial;row.Done=t.Done;Progress.Push(row);
            if(i==work.Active)ActiveKey=key;
        }
    }
    int ProgressIndex(String key,int hint)
    {
        // La geometría conserva normalmente el mismo orden. La pista evita
        // comparar toda la cuadrícula para cada celda, sin depender de él.
        if(hint<Progress.Size() && Progress[hint].Key==key)return hint;
        for(int i=0;i<Progress.Size();i++)if(Progress[i].Key==key)return i;
        return -1;
    }
    void RestoreProgress(CaelumHousekeepingWork work)
    {
        for(int i=0;i<work.Targets.Size();i++)
        {
            let target=work.Targets[i];String key=TargetKey(target);if(key=="" || !WorkReady)continue;
            int j=ProgressIndex(key,i);if(j<0)continue;
            target.Progress=Progress[j].Progress;target.Initial=Progress[j].Initial;target.Done=Progress[j].Done;
            if(key==ActiveKey){work.Active=i;if(work.Goal!=null)work.Goal.SetOrigin(target.Position,false);}
        }
        if(WorkReady)work.Day=WorkDay;
    }

    bool Valid(){return CaelumHousePurchase.OwnChest(Chest,House);}
    static CaelumHouseStorageEntry Remote(Actor body)
    {
        let chest=CaelumStashChest(body);
        return chest!=null && chest.DomesticStorage!=null && chest.DomesticStorage.Parked
            ?chest.DomesticStorage:null;
    }
    void CaptureClimate(CaelumPlayer user)
    {
        if(Climate==null)Climate=new('CaelumFoodClimate');
        Climate.Capture(Chest,CaelumWorldClock.Get(user),CaelumCalendarState.Get(user),CaelumWeatherState.Get(user));
        Climate.HeatDelta=0;Climate.HumidityDelta=0;
        ClimateStamp=CaelumThermalRuntime.Stamp(CaelumWorldClock.Get(user));
        DirtStamp=ClimateStamp;EnvironmentReference=CaelumContaminationEnvironment.ReferenceAt(Chest);
        EnvironmentArea=CaelumContaminationObject.Area(Chest);EnvironmentCovered=CaelumThermalShelter.Roof(Chest);
    }
    void SyncDirt()
    {
        if(!Parked || Chest==null || Climate==null || !Climate.Ready)return;
        let store=CaelumHouseStorage.Get();if(store==null)return;
        let user=CaelumPlayer(store.Owner);CaelumHouseAway.Sync(user);SyncDirtTo(SourceNow(user));
    }
    void SyncDirtTo(double now)
    {
        if(!Parked || Chest==null || Climate==null || !Climate.Ready)return;
        let record=CaelumContaminationStorage.Get(Chest,true);if(record==null || now<=DirtStamp)return;
        if(EnvironmentReference<0 || EnvironmentArea<=0){DirtStamp=now;return;}
        while(DirtStamp<now)
        {
            double civil=Climate.CivilSeconds+DirtStamp-ClimateStamp;
            double end=Min(now,DirtStamp+(Floor(civil/60)+1)*60-civil);if(end<=DirtStamp)end=now;
            Climate.Rate(civil);
            if(Climate.Local!=null && Climate.Local.Available)
            {
                double rain=EnvironmentCovered?0:Climate.Local.PrecipitationMmPerHour;
                double ambient=CaelumContaminationRules.Ambient(EnvironmentReference,Climate.Local.AirTemperatureC,
                    Climate.Local.RelativeHumidityPercent,rain,!EnvironmentCovered);
                record.Concentration=CaelumContaminationObjectBalance.Evolve(record.Concentration,ambient,rain,EnvironmentArea,end-DirtStamp);
            }
            DirtStamp=end;
        }
    }
    void Cool(CaelumWaterContainer water,double now)
    {
        if(water==null || Climate==null || !Climate.Ready || now<=water.TemperatureStamp)return;
        if(!water.TemperatureClockReady){water.TemperatureStamp=now;water.TemperatureClockReady=true;return;}
        double stamp=water.TemperatureStamp;
        while(stamp<now && water.WaterLiters>0)
        {
            double civil=Climate.CivilSeconds+stamp-ClimateStamp;
            double end=Min(now,stamp+(Floor(civil/60)+1)*60-civil);
            if(end<=stamp)end=now;
            Climate.Rate(civil);
            if(Climate.Local!=null && Climate.Local.Available)
            {
                if(water.WaterTemperatureRevision==0)
                {water.WaterTemperatureC=Climate.Local.AirTemperatureC;water.WaterTemperatureRevision=CaelumWaterThermalData.REVISION;}
                else water.WaterTemperatureC=water.CoolWater(Climate.Local.AirTemperatureC,Climate.Local.WindSpeedKmh/3.6,end-stamp);
            }
            stamp=end;
        }
        water.TemperatureStamp=now;
    }
    void Depart(CaelumPlayer user)
    {
        if(!Valid())return;
        SyncDirt();
        if(!Parked)
        {
            Position=Chest.Pos;CaptureClimate(user);
            let dirt=CaelumContaminationStorage.Get(Chest);
            if(dirt!=null && dirt.Exposure!=null)dirt.Exposure.Settle(ClimateStamp);
            CaelumContaminationObject.LeavingWorld(Chest);Chest.HideCarriedStorage();
        }
        Foods.Clear();ItemTIDs.Clear();
        for(Inventory item=Chest.Inv;item!=null;item=item.Inv)
        {
            if(CaelumFoodInventory.IsFood(item))
            {let food=new('CaelumHouseStoredFood');food.Capture(item);Foods.Push(food);}
            let water=CaelumWaterContainer(item);if(water!=null)water.SyncAmbientTemperature();
            let dining=CaelumDiningSetItem(item);if(dining!=null)dining.PreTravelled();
            CaelumStudyUse.ClearContacts(item);ItemTIDs.Push(item.TID);item.ChangeTid(0);
            item.UnlinkFromWorld();item.ChangeStatNum(Thinker.STAT_TRAVELLING);
        }
        Parked=true;CaelumStudyUse.ClearContacts(Chest);TravelTID=Chest.TID;Chest.ChangeTid(0);
        Chest.UnlinkFromWorld();Chest.ChangeStatNum(Thinker.STAT_TRAVELLING);
        let events=CaelumHouseHubEvents(EventHandler.Find('CaelumHouseHubEvents'));
        if(events!=null && events.Housekeeping!=null && events.Housekeeping.Chest==Chest)
        {
            let work=events.Housekeeping;
            if(Away==null)CaptureProgress(work);
            for(int i=0;i<work.Targets.Size();i++)if(work.Targets[i].Furniture==Chest)
            {work.Targets[i].DomesticCoffer=true;work.Targets[i].Furniture=null;}
            work.Chest=null;work.Worker=null;
        }
    }
    void Arrive(CaelumPlayer user)
    {
        if(Chest==null || Chest.bDestroyed || !Parked)return;
        CaelumStudyUse.ClearContacts(Chest);Chest.SetOrigin(user.Pos,false);Chest.FindFloorCeiling();
        Chest.ChangeTid(TravelTID);Chest.ChangeStatNum(CaelumHouseResidents.PARKED_STAT);
        int index=0;
        for(Inventory item=Chest.Inv;item!=null;item=item.Inv)
        {
            CaelumStudyUse.ClearContacts(item);item.SetOrigin(user.Pos,false);item.FindFloorCeiling();
            if(index<ItemTIDs.Size())item.ChangeTid(ItemTIDs[index++]);
            item.ChangeStatNum(CaelumHouseResidents.PARKED_STAT);
            let dining=CaelumDiningSetItem(item);if(dining!=null)dining.Travelled();
        }
        ItemTIDs.Clear();for(int i=0;i<Foods.Size();i++)Foods[i].Restore();Foods.Clear();
    }
    void Restore(CaelumPlayer user)
    {
        if(!Parked || !Valid() || level.MapName!=CaelumHouseHubData.MapName(House))return;
        CaelumHouseAway.Sync(user,true);SyncDirt();Rebase(user);
        double now=CaelumThermalRuntime.Stamp(CaelumWorldClock.Get(user));
        for(Inventory item=Chest.Inv;item!=null;item=item.Inv)
        {
            CaelumFoodInventory.Reconcile(item);Cool(CaelumWaterContainer(item),now);
            item.SetOrigin(Position,false);item.FindFloorCeiling();item.ChangeStatNum(Thinker.STAT_INVENTORY);item.LinkToWorld();
        }
        Chest.ChangeStatNum(Thinker.STAT_DEFAULT);Chest.RestoreWorldStorage(Position);Chest.FindFloorCeiling();
        Parked=false;CaelumContaminationObject.Register(Chest);
        let store=CaelumHouseStorage.Get();if(store!=null)store.AwayCacheReady=false;
        let events=CaelumHouseHubEvents(EventHandler.Find('CaelumHouseHubEvents'));
        if(events!=null && events.Housekeeping!=null && events.Housekeeping.House==House)
        {
            let work=events.Housekeeping;work.Chest=Chest;
            for(int i=0;i<work.Targets.Size();i++)if(work.Targets[i].DomesticCoffer)work.Targets[i].Furniture=Chest;
            RestoreProgress(work);
        }
    }
}

class CaelumHouseStorage : Inventory
{
    int Revision,LastTargetKey;
    transient bool AwayBusy,AwayCacheReady;
    transient double AwayNextDue;
    Array<CaelumHouseStorageEntry> Houses;
    static CaelumHouseStorage Get(bool create=false)
    {
        let roster=CaelumHouseResidents.Get(create);if(roster==null)return null;
        let owner=CaelumPlayer(roster.Owner);if(!CaelumPlayerAuthority.CanMutate(owner))return null;
        let store=CaelumHouseStorage(owner.FindInventory('CaelumHouseStorage'));
        if(store==null && create)store=CaelumHouseStorage(owner.GiveInventoryType('CaelumHouseStorage'));
        return store;
    }
    static void Register(CaelumStashChest chest,int house)
    {
        if(!CaelumHousePurchase.OwnChest(chest,house))return;
        let store=Get(true);if(store==null)return;
        for(int i=0;i<store.Houses.Size();i++)if(store.Houses[i].Chest==chest)
        {chest.DomesticStorage=store.Houses[i];return;}
        let entry=new('CaelumHouseStorageEntry');entry.Chest=chest;entry.House=house;
        chest.DomesticStorage=entry;store.Houses.Push(entry);store.Revision=1;
    }
    static void RestoreCurrent()
    {
        let store=Get();if(store==null)return;let user=CaelumPlayer(store.Owner);if(user==null)return;
        for(int i=0;i<store.Houses.Size();i++)store.Houses[i].Restore(user);
    }
    override void PreTravelled()
    {AwayCacheReady=false;let user=CaelumPlayer(Owner);if(user!=null)for(int i=0;i<Houses.Size();i++)Houses[i].Depart(user);}
    override void Travelled()
    {let user=CaelumPlayer(Owner);if(user!=null)for(int i=0;i<Houses.Size();i++)Houses[i].Arrive(user);}
    override Inventory CreateTossable(int amount){return null;}
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE}
    States {Spawn:TNT1 A -1;Stop;}
}
