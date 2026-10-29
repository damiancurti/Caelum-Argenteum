// #502: acceso resumido autorizado; sÃ³lo se guardan identidades, posiciones y
// valores. Ninguna lÃ­nea, sector ni actor local queda referenciado al viajar.
class CaelumHouseAwayTarget : Object play
{
    CaelumHouseStoredProgress Work;
    CaelumHouseStoredFurnishing Furnishing;
    CaelumContaminationTile Tile;
    vector3 Position;
    double Area;
    Array<int> Workers;
    bool Coffer;
}

class CaelumHouseAwayWork : Object play
{
    int Revision,Active;
    double Stamp,NextDue;
    CaelumContaminationMap Sheet;
    Array<CaelumHouseAwayTarget> Targets;
    Array<int> Residents;
    Array<double> PositionX,PositionY,PositionZ;

    static double Civil(CaelumPlayer user)
    {return CaelumScheduleState.Now(user)*3600.0/CaelumWorldClock.TicsPerHour();}
    static bool KeyAccess(CaelumStashChest chest,CaelumPortDefender body)
    {
        if(chest==null || body==null || chest.GetChestLockNumber()>0)return false;
        if(chest.InstalledPadlock==null || chest.PadlockReleased)return true;
        for(Inventory item=body.Inv;item!=null;item=item.Inv)
        {
            let key=CaelumLockItem(item);
            if(key!=null && key.Amount>0 && key.LockItemType==chest.InstalledPadlock.LockItemType+3
                && CaelumLockRules.SamePair(key.PairIdentity,chest.InstalledPadlock.PairIdentity))return true;
        }
        return false;
    }
    static bool Reachable(CaelumPortDefender body,CaelumDomesticCleanTarget target,Actor goal,CaelumRestSeatProbe probe)
    {
        if(body==null || target==null || goal==null || probe==null)return false;
        goal.SetOrigin(target.Position+(0,0,body.Height*.5),false);goal.FindFloorCeiling();
        if(!body.CheckSight(goal,SF_IGNOREVISIBILITY))return false;
        double reach=body.MeleeRange+(target.Furniture==null?0:target.Furniture.Radius);
        if((target.Position-body.Pos).Length()<=reach)return true;
        vector2 delta=target.Position.XY-body.Pos.XY;
        double distance=delta.Length();if(distance<=0)return false;
        // El recorrido recto es el mismo de Drive; son pruebas nativas sin
        // mover al residente ni abrir puertas durante la captura.
        delta*=Max(0.0,distance-reach)/distance;
        int steps=Max(1,int(Ceil(delta.Length()/Max(1.0,body.Radius*.5))));
        probe.Subject=body;probe.A_SetSize(body.Radius,body.Height);probe.SetOrigin(body.Pos,false);probe.FindFloorCeiling();
        double floor=body.FloorZ;
        for(int i=1;i<=steps;i++)
        {
            FCheckPosition fit;
            if(!probe.CheckPosition(body.Pos.XY+delta*i/steps,false,fit)
                || fit.ceilingz-fit.floorz<body.Height || fit.floorz-fit.dropoffz>body.MaxDropOffHeight
                || fit.floorz-floor>body.MaxStepHeight || floor-fit.floorz>body.MaxDropOffHeight)return false;
            floor=fit.floorz;
        }
        return Abs(target.Position.Z-floor)<=reach;
    }
    void Capture(CaelumHouseStorageEntry entry,CaelumHousekeepingWork work,CaelumPlayer user)
    {
        Revision=1;Stamp=Civil(user);NextDue=Stamp+CaelumContaminationData.EQUIPMENT_SECONDS_M2;
        Active=work.Active;Sheet=work.Sheet;Targets.Clear();Residents.Clear();PositionX.Clear();PositionY.Clear();PositionZ.Clear();
        let roster=CaelumHouseResidents.Get();if(roster==null)return;
        let probe=CaelumRestSeatProbe(Actor.Spawn('CaelumRestSeatProbe',user.Pos,NO_REPLACE));
        if(probe==null)return;
        for(int id=0;id<roster.Residents.Size();id++)
        {
            let body=roster.Residents[id].Body;
            if(!CaelumHousekeepingWork.Free(body,entry.House) || !KeyAccess(entry.Chest,body))continue;
            Residents.Push(id);PositionX.Push(body.Pos.X);PositionY.Push(body.Pos.Y);PositionZ.Push(body.Pos.Z);
        }
        for(int i=0;i<work.Targets.Size();i++)
        {
            let t=work.Targets[i];String key=entry.TargetKey(t);int index=entry.ProgressIndex(key,i);
            let row=new('CaelumHouseAwayTarget');row.Position=t.Position;row.Area=t.Area;row.Tile=t.Tile;
            if(index>=0)row.Work=entry.Progress[index];row.Coffer=t.Furniture==entry.Chest;
            for(int j=0;j<entry.Furnishings.Size();j++)if(entry.Furnishings[j].Key==key)row.Furnishing=entry.Furnishings[j];
            for(int j=0;j<Residents.Size();j++)if(Reachable(roster.Residents[Residents[j]].Body,t,work.Goal,probe))row.Workers.Push(j);
            Targets.Push(row);
        }
        probe.Destroy();
        if(work.Active>=0 && work.Active<work.Targets.Size())work.Goal.SetOrigin(work.Targets[work.Active].Position,false);
    }
    bool Available(CaelumHouseStorageEntry entry,int index)
    {
        let roster=CaelumHouseResidents.Get();if(roster==null || index<0 || index>=Residents.Size())return false;
        int id=Residents[index];if(id<0 || id>=roster.Residents.Size())return false;
        let resident=roster.Residents[id];let body=resident.Body;
        return body!=null && !body.bDestroyed && CaelumContaminationAbsence.Alive(body,Stamp) && resident.Suspended
            && !resident.Emitted && !resident.Delegated && resident.ResidentMap==CaelumHouseHubData.MapName(entry.House)
            && body.ForcedSleepTics<=0 && body.CombatLucidityPhysicalStunRemaining<=0 && !body.ResourceRecoveryActive()
            && (body.target==null || body.target.health<=0) && !CaelumTheftWitnesses.HasTarget(body)
            && KeyAccess(entry.Chest,body);
    }
    int Worker(CaelumHouseStorageEntry entry,CaelumHouseAwayTarget target)
    {for(int i=0;i<target.Workers.Size();i++)if(Available(entry,target.Workers[i]))return target.Workers[i];return -1;}
    void SyncFloor(CaelumContaminationTile tile,double now)
    {
        if(tile==null || now<=tile.Stamp)return;
        let world=CaelumContaminationWorld.Get();
        if(world==null || tile.Profile==CaelumWeatherRules.PROFILE_LIMBO){Sheet.Sync(tile,now);return;}
        if(tile.Reference<0 || !CaelumWeatherRules.IsProfile(tile.Profile)){tile.Stamp=now;return;}
        if(world.HistoryWeather==null)world.HistoryWeather=new('CaelumContaminationWeatherCache');
        CaelumContaminationWeatherDay sample;
        while(tile.Stamp<now)
        {
            double civil=tile.Stamp+Sheet.CivilOffset;int day=int(Floor(civil/86400));
            int minute=int(Floor((civil-double(day)*86400)/60));
            double end=Min(now,double(day)*86400+(minute+1)*60.0-Sheet.CivilOffset);if(end<=tile.Stamp)end=now;
            if(sample==null || sample.Day!=day)sample=world.HistoryWeather.GetTileDay(tile,day);
            sample.Sample(minute);
            if(sample.Ambient[minute]>=0)tile.Concentration=CaelumContaminationTile.Evolve(
                tile.Concentration,sample.Ambient[minute],sample.Rain[minute],end-tile.Stamp);
            tile.Stamp=end;
        }
    }
    double Value(CaelumHouseStorageEntry entry,CaelumHouseAwayTarget target,double now)
    {
        if(target.Tile!=null){SyncFloor(target.Tile,now);return target.Tile.Concentration;}
        if(target.Coffer){entry.SyncDirtTo(now);let dirt=CaelumContaminationStorage.Get(entry.Chest,true);return dirt==null?0:dirt.Concentration;}
        if(target.Furnishing!=null){target.Furnishing.Advance(now);return target.Furnishing.Concentration;}
        return 0;
    }
    void SetValue(CaelumHouseStorageEntry entry,CaelumHouseAwayTarget target,double value)
    {
        if(target.Tile!=null)target.Tile.Concentration=value;
        else if(target.Coffer){let dirt=CaelumContaminationStorage.Get(entry.Chest,true);if(dirt!=null)dirt.Concentration=value;}
        else if(target.Furnishing!=null)target.Furnishing.Concentration=value;
    }
    void Step(CaelumHouseStorageEntry entry,CaelumPlayer user,double end,bool purchase=true)
    {
        double oldDue=NextDue;
        WorkStep(entry,user,end);
        if(!purchase){NextDue=Min(NextDue,oldDue);return;}
        if(!entry.Valid() || end>=double(CaelumCityWorld.SiegeDay())*86400+CaelumCityData.SIEGE_HOUR*3600)return;
        let record=CaelumHousekeepingWork.Record(entry.House,int(Floor(end/86400)));
        if(record==null || record.WorkedSeconds>=CaelumHousekeepingData.DAILY_SECONDS)return;
        for(int i=0;i<Residents.Size();i++)if(Available(entry,i))
        {
            CaelumHousePurchase.ReplenishAt(user,entry.Chest,entry.House,end*CaelumWorldClock.TicsPerHour()/3600.0);
            break;
        }
        if(CaelumHousePurchase.Count(entry.Chest,1)<=0 || CaelumHousekeepingWork.Soap(entry.Chest)<=0)
        {
            bool money=false;
            for(Inventory item=entry.Chest.Inv;item!=null;item=item.Inv)
                if(item is 'CaelumCurrencyItem' && item.Amount>0){money=true;break;}
            if(!money)NextDue=(Floor(end/86400)+1)*86400;
        }
    }
    void WorkStep(CaelumHouseStorageEntry entry,CaelumPlayer user,double end)
    {
        double begin=Stamp;Stamp=end;NextDue=end+CaelumContaminationData.EQUIPMENT_SECONDS_M2;
        if(end<=begin || !entry.Valid())return;
        int day=int(Floor(begin/86400));let record=CaelumHousekeepingWork.Record(entry.House,day);
        if(record==null)return;
        if(entry.WorkDay!=day)
        {
            entry.WorkDay=day;Active=-1;
            for(int i=0;i<Targets.Size();i++)if(Targets[i].Work!=null)
            {if(Targets[i].Work.Done)Targets[i].Work.Progress=0;Targets[i].Work.Done=false;}
        }
        double midnight=(day+1.0)*86400;
        NextDue=Min(NextDue,midnight);
        if(record.WorkedSeconds>=CaelumHousekeepingData.DAILY_SECONDS){NextDue=midnight;return;}
        double siege=double(CaelumCityWorld.SiegeDay())*86400+CaelumCityData.SIEGE_HOUR*3600;
        if(begin>=siege){NextDue=midnight;return;}
        bool available=false;for(int i=0;i<Residents.Size();i++)if(Available(entry,i)){available=true;break;}
        if(!available){NextDue=midnight;return;}
        // El trabajo usa lo que ya habÃ­a al empezar; la compra al cierre queda
        // disponible para el intervalo siguiente, nunca para el pasado.
        let reserve=CaelumDomesticWater.Raw(entry.House);if(reserve==null)return;
        double now=entry.SourceAt(end);reserve.Sync(now);
        if(CaelumHousePurchase.Count(entry.Chest,1)<=0 || CaelumHousekeepingWork.Soap(entry.Chest)<=0 || reserve.Liters<=0)return;
        if(Active>=Targets.Size() || (Active>=0 && (Targets[Active].Work==null || Targets[Active].Work.Done || Worker(entry,Targets[Active])<0)))Active=-1;
        if(Active<0)
        {
            double nearest=1e30;
            for(int i=0;i<Targets.Size();i++)
            {
                let t=Targets[i];if(t.Work==null || t.Work.Done || t.Area<=0)continue;
                int worker=Worker(entry,t);if(worker<0)continue;
                double distance=((PositionX[worker],PositionY[worker],PositionZ[worker])-t.Position).Length();if(distance>=nearest)continue;
                if(Value(entry,t,entry.SourceAt(begin))<=0)continue;
                nearest=distance;Active=i;
            }
            if(Active>=0 && Targets[Active].Work.Progress<=0)Targets[Active].Work.Initial=Value(entry,Targets[Active],entry.SourceAt(begin));
        }
        if(Active<0){NextDue=midnight;return;}
        let target=Targets[Active];let progress=target.Work;
        double duration=target.Area*CaelumContaminationData.EQUIPMENT_SECONDS_M2;
        double step=Min(end-begin,Min(duration-progress.Progress,CaelumHousekeepingData.DAILY_SECONDS-record.WorkedSeconds));
        double rate=CaelumContaminationData.EQUIPMENT_WATER_L_M2/CaelumContaminationData.EQUIPMENT_SECONDS_M2;
        step=Min(step,Min(reserve.Liters/rate,CaelumHousekeepingWork.Soap(entry.Chest)/(rate*CaelumContaminationData.SOAP_G_L)));
        if(step<=0)return;
        double value=Value(entry,target,now),water=step*rate;
        if(!CaelumHousekeepingWork.SpendSoap(entry.Chest,water*CaelumContaminationData.SOAP_G_L))return;
        reserve.Withdraw(water);progress.Progress+=step;record.WorkedSeconds+=step;
        SetValue(entry,target,Max(0.0,value-progress.Initial*step/duration));entry.ActiveKey=progress.Key;
        if(progress.Progress>=duration-.000000001){progress.Done=true;Active=-1;entry.ActiveKey="";}
        if(record.WorkedSeconds>=CaelumHousekeepingData.DAILY_SECONDS)NextDue=midnight;
    }
}

// Un Ãºnico orden temporal por fecha y vivienda. Se consulta el registro
// tipado, no actores globales; el prÃ³ximo vencimiento se conserva en cachÃ©.
class CaelumHouseAway : Object play
{
    static void Sync(CaelumPlayer user,bool partial=false)
    {
        let store=CaelumHouseStorage.Get();if(store==null || store.Owner!=user || store.AwayBusy)return;
        double now=CaelumHouseAwayWork.Civil(user);if(now<0)return;
        if(!partial && store.AwayCacheReady && now<store.AwayNextDue)return;
        store.AwayBusy=true;
        while(true)
        {
            CaelumHouseStorageEntry selected;double due=1e30;
            for(int i=0;i<store.Houses.Size();i++)
            {
                let entry=store.Houses[i];let work=entry.Away;
                if(!entry.Parked || work==null || work.Revision!=1)continue;
                double next=partial && work.Stamp<now?Min(work.NextDue,now):work.NextDue;
                if(next<due || (next==due && selected!=null && entry.House<selected.House))
                {selected=entry;due=next;}
            }
            store.AwayNextDue=due;store.AwayCacheReady=true;
            if(selected==null || due>now)break;
            selected.Away.Step(selected,user,due,due>=selected.Away.NextDue);
        }
        store.AwayBusy=false;
    }
}
