// #502: el cupo pertenece a la vivienda, no a cada residente ni a cada visita.
class CaelumHouseCleaningRecord : Object play
{
    int Revision,Day;
    double WorkedSeconds;
    void Ensure(int civilDay)
    {
        if(Revision==0 || civilDay>Day){Day=civilDay;WorkedSeconds=0;}
        Revision=CaelumHousekeepingData.REVISION;
    }
}

class CaelumDomesticCleanTarget : Object play
{
    Actor Furniture;
    CaelumContaminationTile Tile;
    vector3 Position;
    double Area,Progress,Initial;
    bool Done,DomesticCoffer;
}

class CaelumDomesticCleaningProbe : Actor
{
    Default {Radius 1;Height 1;+NOGRAVITY +NOBLOCKMAP +NOINTERACTION RenderStyle "None";}
    States {Spawn:TNT1 A -1;Stop;}
}

// Sólo existe en el interior cargado. Los objetivos y cuerpos no se conservan
// como referencias de otro mapa en el inventario viajero del jugador.
class CaelumHousekeepingWork : Object play
{
    Array<CaelumDomesticCleanTarget> Targets;
    CaelumStashChest Chest;
    CaelumPortDefender Worker;
    Actor Goal;
    CaelumContaminationMap Sheet;
    int House,Active,Day,NextTic;
    int VirtualMoveTics;
    bool Initialized;
    transient bool ClockReady;
    double Stamp,NextPurchase;

    static CaelumHouseCleaningRecord Record(int house,int day)
    {
        let roster=CaelumHouseResidents.Get(true);if(roster==null)return null;
        while(roster.HouseCleaning.Size()<=house)roster.HouseCleaning.Push(null);
        if(roster.HouseCleaning[house]==null)roster.HouseCleaning[house]=new('CaelumHouseCleaningRecord');
        let record=roster.HouseCleaning[house];record.Ensure(day);return record;
    }
    static bool Free(CaelumPortDefender body,int house)
    {
        return body!=null && !body.bDestroyed && body.health>0 && body.HomeRevision>0
            && CaelumPropertyData.ResidentHouse(body.HomeIdentity)==house
            && body.Residence!=null && !body.Residence.Suspended && !body.Residence.Emitted
            && !body.Residence.Delegated && !body.bInConversation && body.ForcedSleepTics<=0
            && body.CombatLucidityPhysicalStunRemaining<=0 && !body.ResourceRecoveryActive()
            && !CaelumTheftWitnesses.HasTarget(body) && (body.target==null || body.target.health<=0)
            && !CaelumCityWorld.SiegeDue();
    }
    bool HasChestAccess()
    {
        if(!CaelumHousePurchase.OwnChest(Chest,House) || Chest.GetChestLockNumber()>0)return false;
        if(Chest.InstalledPadlock==null || Chest.PadlockReleased)return true;
        let roster=CaelumHouseResidents.Get();if(roster==null)return false;
        for(int group=0;group<2;group++)
        {
            int home=group==0?House:CaelumPropertyData.CENTRAL_HOUSE;
            if(group==1 && House!=CaelumPropertyData.RELOCATION_HOUSE)break;
            for(int i=home;i<roster.Residents.Size();i+=CaelumCityData.HOUSE_COUNT)
            {
                let body=roster.Residents[i].Body;if(!Free(body,House))continue;
                for(Inventory item=body.Inv;item!=null;item=item.Inv)
                {
                    let key=CaelumLockItem(item);
                    if(key!=null && key.Amount>0 && key.LockItemType==Chest.InstalledPadlock.LockItemType+3
                        && CaelumLockRules.SamePair(key.PairIdentity,Chest.InstalledPadlock.PairIdentity))return true;
                }
            }
        }
        return false;
    }
    static double Soap(CaelumStashChest chest)
    {return chest==null?0:CaelumHousePurchase.Count(chest,2)+Max(0.0,chest.DomesticSoapRemainderG);}
    static bool SpendSoap(CaelumStashChest chest,double grams)
    {
        if(grams<0 || grams>Soap(chest)+0.000000001)return false;
        int whole=int(Ceil(Max(0.0,grams-chest.DomesticSoapRemainderG)-0.000000001));
        int remaining=whole;
        for(Inventory item=chest.Inv;item!=null && remaining>0;)
        {
            Inventory next=item.Inv;
            if(CaelumHousePurchase.Supply(item)==2)
            {int take=Min(remaining,Max(0,item.Amount));remaining-=take;item.Amount-=take;if(item.Amount==0)item.Destroy();}
            item=next;
        }
        chest.DomesticSoapRemainderG=Max(0.0,chest.DomesticSoapRemainderG+whole-grams);
        if(grams>0)for(Inventory cloth=chest.Inv;cloth!=null;cloth=cloth.Inv)
            if(CaelumHousePurchase.Supply(cloth)==1){CaelumCleaningSupplies.RinseCloth(cloth);break;}
        return true;
    }
    static bool Furniture(Actor body)
    {return body is 'CaelumDecorBody' || body is 'CaelumRestFurniture' || body is 'CaelumDiningTable' || body is 'CaelumDomesticFixture' || body is 'CaelumStashChest';}
    void Configure(CaelumPlayer user,CaelumContaminationTile tile)
    {
        let weather=CaelumWeatherState.Get(user);if(weather==null)return;
        tile.Reference=CaelumContaminationEnvironment.ReferenceAt(Goal);
        tile.Profile=weather.Profile;tile.Region=weather.Region;tile.Seed=weather.Seed;
        tile.Covered=CaelumThermalShelter.Roof(Goal);
        tile.Shelter=CaelumThermalEnvironment.ClimateShelter(weather.Profile,tile.Covered,CaelumThermalShelter.WindBlocked(Goal));
        tile.WeatherReady=false;
    }
    bool Setup(CaelumPlayer user)
    {
        House=CaelumHouseHubData.HouseForMap(level.MapName);if(House<0 || House==CaelumPropertyData.CENTRAL_HOUSE)return false;
        Sheet=CaelumContaminationSurfaces.CurrentMap(user);if(Sheet==null)return false;
        if(Goal==null)
        {Goal=Actor.Spawn('CaelumDomesticCleaningProbe',user.Pos,NO_REPLACE);return false;}
        Targets.Clear();Chest=null;
        // Geometría estática de este interior, una vez por inicialización. La
        // malla usa las zonas de 1 m2 aprobadas, no coordenadas nuevas de diseño.
        vector2 low=(1e30,1e30),high=(-1e30,-1e30);
        for(int i=0;i<level.lines.Size();i++)
        {
            let line=level.lines[i];
            low.X=Min(low.X,Min(line.v1.p.X,line.v2.p.X));low.Y=Min(low.Y,Min(line.v1.p.Y,line.v2.p.Y));
            high.X=Max(high.X,Max(line.v1.p.X,line.v2.p.X));high.Y=Max(high.Y,Max(line.v1.p.Y,line.v2.p.Y));
        }
        double unit=CaelumPhysicsUnits.MAP_UNITS_PER_METER*CaelumContaminationData.SURFACE_ZONE_METERS;
        vector2 center=(low+high)*0.5;Goal.SetOrigin((center.X,center.Y,user.Pos.Z),false);Goal.FindFloorCeiling();
        let nearby=BlockThingsIterator.Create(Goal,(high-low).Length());
        while(nearby.Next())
        {
            Actor body=nearby.thing;
            if(body.Pos.X<low.X || body.Pos.X>high.X || body.Pos.Y<low.Y || body.Pos.Y>high.Y)continue;
            let candidateChest=CaelumStashChest(body);
            if(CaelumHousePurchase.OwnChest(candidateChest,House)
                && (Chest==null || candidateChest.LawfulOwner.Token==("house:"..level.MapName)))Chest=candidateChest;
            if(!Furniture(body) || body.bDestroyed)continue;
            bool known=false;for(int i=0;i<Targets.Size();i++)if(Targets[i].Furniture==body)known=true;
            if(known)continue;
            let target=new('CaelumDomesticCleanTarget');target.Furniture=body;target.Position=body.Pos;
            target.Area=CaelumContaminationObject.Area(body);Targets.Push(target);
        }
        if(Chest==null){Targets.Clear();return false;}
        CaelumHouseStorage.Register(Chest,House);
        for(int y=CaelumContaminationSurfaceContact.Cell(low.Y);y<=CaelumContaminationSurfaceContact.Cell(high.Y);y++)
            for(int x=CaelumContaminationSurfaceContact.Cell(low.X);x<=CaelumContaminationSurfaceContact.Cell(high.X);x++)
        {
            vector2 p=((x+0.5)*unit,(y+0.5)*unit);let sector=level.PointInSector(p);
            double z=sector.floorplane.ZatPoint(p);Goal.SetOrigin((p.X,p.Y,z),false);Goal.FindFloorCeiling();
            if(!Goal.TestMobjLocation() || !CaelumThermalShelter.Roof(Goal) || Goal.WaterLevel>0)continue;
            let target=new('CaelumDomesticCleanTarget');target.Position=Goal.Pos;target.Area=1;
            target.Tile=Sheet.Find(0,sector.Index(),0,x,y,true);Configure(user,target.Tile);Targets.Push(target);
        }
        Initialized=true;Active=-1;Day=-1;
        if(Chest.DomesticStorage!=null)
        {Chest.DomesticStorage.RestoreProgress(self);Chest.DomesticStorage.RestoreFurnishings(self,user);}
        return true;
    }
    void SelectWorker()
    {
        if(Free(Worker,House))return;
        Worker=null;let roster=CaelumHouseResidents.Get();if(roster==null)return;
        for(int group=0;group<2;group++)
        {
            int home=group==0?House:CaelumPropertyData.CENTRAL_HOUSE;
            if(group==1 && House!=CaelumPropertyData.RELOCATION_HOUSE)break;
            for(int i=home;i<roster.Residents.Size();i+=CaelumCityData.HOUSE_COUNT)
                if(Free(roster.Residents[i].Body,House)){Worker=roster.Residents[i].Body;return;}
        }
    }
    double Value(CaelumDomesticCleanTarget target,double now)
    {
        if(target.Tile!=null){Sheet.Sync(target.Tile,now);return target.Tile.Concentration;}
        if(target.Furniture==null || target.Furniture.bDestroyed)return 0;
        let entry=CaelumContaminationStorage.Get(target.Furniture);
        if(entry!=null && entry.Exposure!=null)entry.Exposure.Advance();
        return CaelumContaminationStorage.Value(target.Furniture);
    }
    void SelectTarget(double now)
    {
        if(Active>=0 || Worker==null)return;
        double nearest=1e30;
        for(int i=0;i<Targets.Size();i++)
        {
            let t=Targets[i];if(t.Done || t.Area<=0)continue;
            if(t.Furniture!=null)t.Position=t.Furniture.Pos;
            double distance=(Worker.Pos-t.Position).Length();if(distance>=nearest)continue;
            Goal.SetOrigin(t.Position+(0,0,Worker.Height*0.5),false);
            if(!Worker.CheckSight(Goal,SF_IGNOREVISIBILITY) || Value(t,now)<=0)continue;
            nearest=distance;Active=i;
        }
        if(Active>=0)
        {
            let t=Targets[Active];Goal.SetOrigin(t.Position,false);
            if(t.Progress<=0)t.Initial=Value(t,now);
            if(!Worker.InStateSequence(Worker.CurState,Worker.SeeState))Worker.SetState(Worker.SeeState);
        }
    }
    bool Reached()
    {
        if(Worker==null || Active<0)return false;
        let t=Targets[Active];double radius=t.Furniture==null?0:t.Furniture.Radius;
        return Worker.Distance3D(Goal)<=Worker.MeleeRange+radius && Worker.CheckSight(Goal,SF_IGNOREVISIBILITY);
    }
    static void Drive(CaelumPortDefender body)
    {
        let events=CaelumHouseHubEvents(EventHandler.Find('CaelumHouseHubEvents'));
        if(events==null || events.Housekeeping==null)return;
        let work=events.Housekeeping;
        if(work.Worker!=body || work.Active<0 || !Free(body,work.House) || work.Reached())return;
        vector2 delta=work.Goal.Pos.XY-body.Pos.XY;if(delta.Length()<=0)return;
        body.Angle=VectorAngle(delta.X,delta.Y);
        if(!body.ThermalTryMove(body.Pos.XY+delta.Unit()*Min(body.Speed,delta.Length())))
        {work.Targets[work.Active].Done=true;work.Active=-1;}
    }
    static bool Pending()
    {
        let events=CaelumHouseHubEvents(EventHandler.Find('CaelumHouseHubEvents'));
        return events!=null && events.Housekeeping!=null && events.Housekeeping.Initialized;
    }
    static void AdvanceSkippedTic(CaelumPlayer user)
    {
        let roster=CaelumHouseResidents.Get();if(roster==null || roster.Owner!=user)return;
        let events=CaelumHouseHubEvents(EventHandler.Find('CaelumHouseHubEvents'));
        if(events==null || events.Housekeeping==null || !events.Housekeeping.Initialized)return;
        let work=events.Housekeeping;
        // La espera conserva los pasos físicos y su cadencia See existente;
        // no teletransporta al trabajador ni cobra tiempo de un mapa ausente.
        if(work.Worker!=null && work.Worker.SeeState!=null)
        {
            work.VirtualMoveTics++;
            if(work.VirtualMoveTics>=Max(1,work.Worker.SeeState.Tics))
            {work.VirtualMoveTics=0;Drive(work.Worker);}
        }
        if(!work.ClockReady || CaelumContaminationSurfaces.Now(user)-work.Stamp
            >=CaelumThermalRuntime.WorldTicSeconds()*TICRATE)
        {work.NextTic=0;work.Tick();}
    }
    void Tick()
    {
        if(level.maptime<NextTic)return;NextTic=level.maptime+TICRATE;
        let roster=CaelumHouseResidents.Get();if(roster==null)return;
        let user=CaelumPlayer(roster.Owner);if(!CaelumPlayerAuthority.CanMutate(user))return;
        if(!Initialized){Setup(user);return;}
        if(Chest!=null && Chest.DomesticStorage==null)
        {CaelumHouseStorage.Register(Chest,House);if(Chest.DomesticStorage!=null)Chest.DomesticStorage.RestoreProgress(self);}
        double now=CaelumContaminationSurfaces.Now(user),elapsed=ClockReady?Max(0.0,now-Stamp):0;
        Stamp=now;ClockReady=true;
        let clock=CaelumWorldClock.Get(user);let calendar=CaelumCalendarState.Get(user);
        int civilDay=calendar.DateSerial(clock);let record=Record(House,civilDay);if(record==null)return;
        if(Day!=record.Day)
        {
            Day=record.Day;NextPurchase=0;elapsed=0;
            for(int i=0;i<Targets.Size();i++)
            {if(Targets[i].Done)Targets[i].Progress=0;Targets[i].Done=false;}
        }
        if(record.WorkedSeconds>=CaelumHousekeepingData.DAILY_SECONDS){Worker=null;Active=-1;return;}
        SelectWorker();if(Worker==null || !HasChestAccess())return;
        if(now>=NextPurchase)
        {CaelumHousePurchase.Replenish(user,Chest,House);NextPurchase=now+CaelumContaminationData.EQUIPMENT_SECONDS_M2;}
        if(CaelumHousePurchase.Count(Chest,1)<=0)return;
        let reserve=CaelumDomesticWater.Get(House);if(reserve==null || reserve.Liters<=0 || Soap(Chest)<=0)return;
        bool hadTarget=Active>=0;SelectTarget(now);if(!hadTarget || !Reached())return;
        let t=Targets[Active];double duration=t.Area*CaelumContaminationData.EQUIPMENT_SECONDS_M2;
        double step=Min(elapsed,Min(duration-t.Progress,CaelumHousekeepingData.DAILY_SECONDS-record.WorkedSeconds));
        double rate=CaelumContaminationData.EQUIPMENT_WATER_L_M2/CaelumContaminationData.EQUIPMENT_SECONDS_M2;
        step=Min(step,Min(reserve.Liters/rate,Soap(Chest)/(rate*CaelumContaminationData.SOAP_G_L)));
        if(step<=0)return;
        double value=Value(t,now),water=step*rate;
        if(!SpendSoap(Chest,water*CaelumContaminationData.SOAP_G_L))return;
        reserve.Withdraw(water);t.Progress+=step;record.WorkedSeconds+=step;
        value=Max(0.0,value-t.Initial*step/duration);
        if(t.Progress+0.000000001>=duration){value=0;t.Done=true;Active=-1;}
        if(t.Tile!=null)t.Tile.Concentration=value;else CaelumContaminationStorage.Set(t.Furniture,value);
    }
}
