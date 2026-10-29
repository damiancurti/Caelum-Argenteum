// Cada registro conserva el cuerpo real, su inventario y su mapa de residencia.
// No reconstruye salud, equipo ni estados de combate al cruzar una puerta.
class CaelumHouseResident : Object play
{
    CaelumPortDefender Body;
    bool Created, Suspended, Emitted, DeploymentResolved, Delegated;
    bool ExcludedFromDeployment, AssignmentInitialized;
    String ResidentMap;
    int GunIndex, GunSlot;
    CaelumBolasFlight Binding;
    bool Invisible, Solid, Shootable, NoInteraction, NoBlock, NoSector;
    vector3 Position, Velocity;
    int ParkTic;

    void Suspend()
    {
        if(Body==null || Suspended)return;
        for(int i=0;i<Body.ImpactContacts.Size();i++)
        {
            let contact=Body.ImpactContacts[i];if(contact==null)continue;
            CaelumImpactEnergy.ConsumeWork(contact);contact.Active=false;
        }
        Body.ImpactContacts.Clear();
        CaelumWeightPressure.Finish(Body);
        ResidentMap=level.MapName;
        Position=Body.Pos;Velocity=Body.Vel;ParkTic=level.time;
        Invisible=Body.bInvisible;Solid=Body.bSolid;Shootable=Body.bShootable;
        NoInteraction=Body.bNoInteraction;NoBlock=Body.bNOBLOCKMAP;NoSector=Body.bNOSECTOR;
        Body.bInvisible=true;Body.bSolid=false;Body.bShootable=false;Body.bNoInteraction=true;
        Body.A_ChangeLinkFlags(1,1);Body.Vel=(0,0,0);Body.A_StopAllSounds();
        // STAT_TRAVELLING conserva OF_JustSpawned hasta PostBeginPlay nativo.
        int parked=Body.CombatProfileInitialized?CaelumHouseResidents.PARKED_STAT:Thinker.STAT_TRAVELLING;
        Body.ChangeStatNum(parked);
        for(Inventory item=Body.Inv;item!=null;item=item.Inv)
            item.ChangeStatNum(parked);
        ParkBinding();
        Suspended=true;
    }

    void ParkBinding()
    {
        Binding=Body.BolasBinding;
        if(Binding!=null && Binding.Phase==1 && Binding.Victim==Body)
        {
            for(int i=0;i<2;i++)
            {
                if(Binding.Ropes[i]!=null){Binding.Ropes[i].Destroy();Binding.Ropes[i]=null;}
                if(Binding.BackRopes[i]!=null){Binding.BackRopes[i].Destroy();Binding.BackRopes[i]=null;}
            }
            Binding.A_ChangeLinkFlags(1,1);Binding.A_StopAllSounds();
            Binding.ChangeStatNum(CaelumHouseResidents.PARKED_STAT);
            for(Inventory item=Binding.Inv;item!=null;item=item.Inv)
                item.ChangeStatNum(CaelumHouseResidents.PARKED_STAT);
        }
        else Binding=null;
    }

    bool Resume(vector3 point)
    {
        if(Body==null || !Suspended)return Body!=null;
        if(!Body.CombatProfileInitialized)return false;
        Body.ResetMaintenanceForTravel();
        Body.SetOrigin(point,false);Body.FindFloorCeiling();
        // Un acceso ocupado aplaza la colocación; no consume ni duplica al soldado.
        if(Body.health>0)
        {
            let probe=Actor.Spawn("CaelumSummoningProbe",point,NO_REPLACE);
            probe.A_SetSize(Body.Radius,Body.Height);
            bool free=probe.TestMobjLocation();probe.Destroy();if(!free)return false;
        }
        int elapsed=level.time-ParkTic;
        Body.WeaponCycleStartTic+=elapsed;Body.PassageRequestTic+=elapsed;
        if(Body.Carbine!=null)
        {
            Body.Carbine.NextShotTic+=elapsed;Body.Carbine.LastAimTic+=elapsed;
            Body.Carbine.PreviousPosition=point;
        }
        if(Body.ThermalState!=null)
        {Body.ThermalState.RuntimeReady=false;Body.ThermalState.SourceMap="";Body.ThermalState.LastPosition=point;Body.ThermalState.MotionInitialized=false;}
        Body.ImpactGroundTrackingInitialized=false;Body.ImpactWasWallBlockedLastTick=false;
        Body.LastImpactFallingVelocityZ=0;
        Body.bInvisible=Invisible;Body.bSolid=Solid;Body.bShootable=Shootable;
        Body.bNoInteraction=NoInteraction;Body.A_ChangeLinkFlags(NoBlock?1:0,NoSector?1:0);
        Body.FindFloorCeiling();Body.ClearInterpolation();Body.Vel=Velocity;
        bool archived=CaelumCorpseArchive.Suspended(Body);
        Body.ChangeStatNum(archived?CaelumCorpseArchiveData.DORMANT_STAT:Thinker.STAT_DEFAULT);
        for(Inventory item=Body.Inv;item!=null;item=item.Inv)
            item.ChangeStatNum(archived?CaelumCorpseArchiveData.DORMANT_STAT:Thinker.STAT_INVENTORY);
        if(Binding!=null)
        {
            Binding.SetOrigin(point,false);Binding.FindFloorCeiling();Binding.A_ChangeLinkFlags(0,0);
            Binding.ChangeStatNum(Thinker.STAT_DEFAULT);
            for(Inventory item=Binding.Inv;item!=null;item=item.Inv)
                item.ChangeStatNum(Thinker.STAT_INVENTORY);
        }
        Suspended=false;return true;
    }
}

// El inventario nativo del jugador posee el registro entre mapas del hub.
// Sólo recorre sus residentes conocidos durante una transición, nunca actores globales.
class CaelumHouseResidents : Inventory
{
    Array<CaelumDomesticWaterState> HouseWater;
    Array<CaelumPropertyRecord> Properties;
    int PropertyRevision;
    bool PropertyChestScanned;
    CaelumStashChest RelocatingChest;
    int PropertyChestTravelTID;
    Array<int> PropertyContentTravelTIDs;
    bool HouseChestIssued[CaelumCityData.HOUSE_COUNT];
    const PARKED_STAT=Thinker.STAT_FIRST_THINKING-2;
    int Revision, PendingCursor, Unresolved;
    bool Ready, DeploymentPending;
    Array<CaelumHouseResident> Residents;
    Array<int> PlacementPending;

    static CaelumHouseResidents Get(bool create=false)
    {
        for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i] && players[i].mo!=null)
        {
            let user=players[i].mo;
            let roster=CaelumHouseResidents(user.FindInventory("CaelumHouseResidents"));
            if(roster==null && create)roster=CaelumHouseResidents(user.GiveInventoryType("CaelumHouseResidents"));
            if(roster!=null)return roster;
        }
        return null;
    }

    void EnsureRecords()
    {
        while(Residents.Size()<CaelumHouseHubData.RESIDENT_COUNT)
            Residents.Push(new("CaelumHouseResident"));
        Revision=CaelumHouseHubData.REVISION;
        MigratePropertyResidents();
    }

    // Migracion acotada a los cuatro IDs de la vivienda, una vez por registro.
    void MigratePropertyResidents()
    {
        if(PropertyRevision>=CaelumPropertyData.REVISION)return;
        String oldMap=CaelumHouseHubData.MapName(CaelumPropertyData.CENTRAL_HOUSE);
        for(int i=CaelumPropertyData.CENTRAL_HOUSE;i<Residents.Size();i+=CaelumCityData.HOUSE_COUNT)
        {
            let entry=Residents[i];
            if(entry.Created && !entry.Emitted && !entry.Delegated && entry.ResidentMap==oldMap)
            {
                entry.Suspend();entry.ResidentMap=CaelumHouseHubData.MapName(CaelumPropertyData.RELOCATION_HOUSE);
                entry.Position=CaelumPropertyData.ResidentPosition(i);
            }
        }
        PropertyRevision=CaelumPropertyData.REVISION;
    }
    bool RelocatePropertyChest()
    {
        if(!Ready)return false;
        if(PropertyChestScanned)return true;
        // Excepcion de migracion: una unica busqueda tipada al cargar la casa
        // original, necesaria porque el esquema anterior no guardaba su puntero.
        // No se ejecuta en MAP03, por tic, por residente ni tras marcar el esquema.
        let iterator=ThinkerIterator.Create("CaelumStashChest");CaelumStashChest chest;
        String title="house:"..CaelumHouseHubData.MapName(CaelumPropertyData.CENTRAL_HOUSE);
        while((chest=CaelumStashChest(iterator.Next()))!=null)
        {
            if(chest.Cargo!=null || chest.LawfulOwner==null || chest.LawfulOwner.Token!=title)continue;
            RelocatingChest=chest;chest.ChestOpen=false;chest.HideCarriedStorage();
            chest.ChangeStatNum(PARKED_STAT);
            for(Inventory item=chest.Inv;item!=null;item=item.Inv)item.ChangeStatNum(PARKED_STAT);
            break;
        }
        PropertyChestScanned=true;return true;
    }
    bool PlaceRelocatedChest()
    {
        if(RelocatingChest==null)return true;
        let chest=RelocatingChest;vector3 point=CaelumPropertyData.RelocatedChestPosition();
        // Probar el volumen sin activar una copia ni perder el original.
        let probe=Actor.Spawn("CaelumSummoningProbe",point,NO_REPLACE);
        if(probe==null)return false;
        probe.A_SetSize(chest.Radius,chest.Height);bool fits=probe.TestMobjLocation();probe.Destroy();
        if(!fits)return false;
        chest.ChangeStatNum(STAT_DEFAULT);
        for(Inventory item=chest.Inv;item!=null;item=item.Inv)item.ChangeStatNum(STAT_INVENTORY);
        chest.RestoreWorldStorage(point);RelocatingChest=null;return true;
    }
    void TravelPropertyChest(bool arriving)
    {
        let chest=RelocatingChest;if(chest==null)return;
        // Cofre y contenidos reales viajan en el mismo protocolo que los
        // cuerpos residentes; no es carga utilizable ni peso del personaje.
        if(!arriving)
        {
            PropertyChestTravelTID=chest.TID;chest.ChangeTid(0);PropertyContentTravelTIDs.Clear();
            chest.UnlinkFromWorld();chest.ChangeStatNum(STAT_TRAVELLING);
            for(Inventory item=chest.Inv;item!=null;item=item.Inv)
            {
                PropertyContentTravelTIDs.Push(item.TID);item.ChangeTid(0);
                item.UnlinkFromWorld();item.ChangeStatNum(STAT_TRAVELLING);
            }
        }
        else
        {
            chest.ChangeStatNum(PARKED_STAT);chest.SetOrigin(Owner.Pos,false);chest.FindFloorCeiling();
            chest.ChangeTid(PropertyChestTravelTID);PropertyChestTravelTID=0;
            int index=0;
            for(Inventory item=chest.Inv;item!=null;item=item.Inv)
            {
                item.ChangeStatNum(PARKED_STAT);item.SetOrigin(Owner.Pos,false);
                if(index<PropertyContentTravelTIDs.Size())item.ChangeTid(PropertyContentTravelTIDs[index++]);
            }
            PropertyContentTravelTIDs.Clear();
        }
    }

    bool DelegatesTravel(CaelumHouseResident entry)
    {
        let body=entry.Body;if(body==null)return false;
        if(CaelumRedemption.PreviouslyRaised(body))entry.ExcludedFromDeployment=true;
        let bond=CaelumRedemption.Memory(body);
        if(bond==null || bond.Conversion==null || !bond.Conversion.Alive()
            || body.health<=0 || bond.Conversion.Owner.player==null)return false;
        for(int i=0;i<bond.Conversion.Converts.Size();i++)
            if(bond.Conversion.Converts[i]==bond)return true;
        return false;
    }

    CaelumPortDefender CreateResident(int identity,vector3 point)
    {
        let entry=Residents[identity];
        if(entry.Created)return entry.Body;
        entry.Body=CaelumPortDefender(Spawn("CaelumPortDefender",point,NO_REPLACE));
        if(entry.Body==null)return null;
        entry.Created=true;entry.Body.HomeIdentity=identity;
        entry.ResidentMap=level.MapName;entry.Position=point;
        entry.Body.Residence=entry;
        entry.Body.HomeRevision=CaelumCityData.PERSISTENCE_REVISION;
        return entry.Body;
    }

    void Bind(CaelumPortSiege port,int identity)
    {
        let entry=Residents[identity];let body=entry.Body;
        if(body==null || port==null || entry.ExcludedFromDeployment)return;
        body.Port=port;port.Defenders[identity]=body;
        if(!entry.AssignmentInitialized)
        {
            entry.GunIndex=-1;entry.GunSlot=-1;
            if(identity<CaelumCityData.CREW_COUNT)
            {
                entry.GunIndex=6+identity/CaelumCannonData.CREW;
                entry.GunSlot=identity%CaelumCannonData.CREW;
                body.Station=CaelumPortData.GunPosition(entry.GunIndex)+CaelumPortData.OperatorOffset(entry.GunIndex,entry.GunSlot);
                body.Lane=CaelumPortSiege.NearestLane(body.Station.X);
            }
            else
            {
                int guard=identity-CaelumCityData.CREW_COUNT;
                body.Station=CaelumCityData.GuardStation(guard);body.Lane=guard%6;
            }
            entry.AssignmentInitialized=true;
        }
        body.Gun=entry.GunIndex>=0 && entry.GunIndex<port.Guns.Size()?port.Guns[entry.GunIndex]:null;
        if(body.Gun!=null && entry.GunSlot>=0)
        {
            if(body.Gun.Operators.Size()<=entry.GunSlot)body.Gun.Operators.Resize(entry.GunSlot+1);
            body.Gun.Operators[entry.GunSlot]=body;
        }
    }

    void PrepareCity(CaelumPortSiege port)
    {
        EnsureRecords();port.Defenders.Resize(Residents.Size());
        // Los snapshots del hub contienen punteros a copias; reconstruir los puestos.
        for(int g=0;g<port.Guns.Size();g++)
            if(port.Guns[g]!=null && port.Guns[g].Defending)port.Guns[g].Operators.Clear();
        for(int i=0;i<Residents.Size();i++)
        {
            port.Defenders[i]=null;
            let entry=Residents[i];
            if(entry.Body!=null && entry.ResidentMap==level.MapName)
            {
                if(entry.Delegated)continue;
                // Reservar la tripulación aún oculta sin prestarle servicio al cañón.
                if(entry.Emitted && entry.AssignmentInitialized && entry.GunIndex>=0
                    && entry.GunIndex<port.Guns.Size() && entry.GunSlot>=0)
                {
                    let gun=port.Guns[entry.GunIndex];
                    if(gun!=null)
                    {
                        if(gun.Operators.Size()<=entry.GunSlot)gun.Operators.Resize(entry.GunSlot+1);
                        gun.Operators[entry.GunSlot]=entry.Body;
                    }
                }
                if(entry.Resume(entry.Position)){if(entry.Emitted)Bind(port,i);}
                else PlacementPending.Push(i);
            }
        }
    }

    void PrepareHouse(int house)
    {
        EnsureRecords();
        for(int i=0;i<Residents.Size();i++)
        {
            if(CaelumPropertyData.ResidentHouse(i)!=house)continue;
            let entry=Residents[i];if(entry.Emitted || entry.Delegated || entry.ExcludedFromDeployment)continue;
            if(!entry.Created)CreateResident(i,CaelumPropertyData.ResidentPosition(i));
        }
        PrepareOtherMap();
    }

    void PrepareOtherMap()
    {
        for(int i=0;i<Residents.Size();i++)
        {
            let entry=Residents[i];
            if(entry.Body!=null && !entry.Delegated && entry.ResidentMap==level.MapName
                && !entry.Resume(entry.Position))PlacementPending.Push(i);
        }
    }

    void BeginDeployment(CaelumPortSiege port)
    {
        EnsureRecords();PendingCursor=0;Unresolved=0;
        for(int i=0;i<Residents.Size();i++)
        {
            let entry=Residents[i];DelegatesTravel(entry);
            entry.DeploymentResolved=entry.Emitted || entry.ExcludedFromDeployment
                || (entry.Created && (entry.Body==null || entry.Body.health<=0));
            if(!entry.DeploymentResolved)Unresolved++;
        }
        DeploymentPending=Unresolved>0;
    }

    override void Tick()
    {
        Super.Tick();
        if(PropertyRevision<CaelumPropertyData.REVISION){EnsureRecords();Ready=false;}
        if(PlacementPending.Size()>0)
        {
            int identity=PlacementPending[0];PlacementPending.Delete(0);
            let entry=Residents[identity];
            if(entry.Resume(entry.Position))
            {
                if(entry.Emitted && level.MapName=="MAP03")Bind(CaelumPortSiege.Get(),identity);
            }
            else PlacementPending.Push(identity);
        }
        if(!Ready)
        {
            int house=CaelumHouseHubData.HouseForMap(level.MapName);
            let port=CaelumPortSiege.Get();
            if(house>=0){PrepareHouse(house);Ready=true;}
            else if(CaelumHouseHub.IsCity(port) && port.SetupRevision>0)
            {PrepareCity(port);Ready=true;}
            else if(!CaelumHouseHub.IsCity(port)){PrepareOtherMap();Ready=true;}
        }
        if(Ready && !PropertyChestScanned && level.MapName==CaelumHouseHubData.MapName(CaelumPropertyData.CENTRAL_HOUSE))
            RelocatePropertyChest();
        if(RelocatingChest!=null && level.time%TICRATE==0
            && level.MapName==CaelumHouseHubData.MapName(CaelumPropertyData.RELOCATION_HOUSE))PlaceRelocatedChest();
        if(!DeploymentPending || level.MapName!="MAP03")return;
        let port=CaelumPortSiege.Get();if(!CaelumHouseHub.IsCity(port) || !port.SiegeStarted)return;
        // Un intento por tic: presupuesto fijo independiente del total de actores.
        int identity=PendingCursor;PendingCursor=(PendingCursor+1)%Residents.Size();
        let entry=Residents[identity];
        if(entry.DeploymentResolved)return;
        if(entry.Created && (entry.Body==null || entry.Body.health<=0))
        {entry.DeploymentResolved=true;DeploymentPending=--Unresolved>0;return;}
        vector3 point=CaelumCityData.DoorOutside(CaelumPropertyData.ResidentHouse(identity));
        let probe=Spawn("CaelumSummoningProbe",point,NO_REPLACE);
        probe.A_SetSize(GetDefaultByType("CaelumPlayer").Radius,CaelumPortData.DEFENDER_HEIGHT);
        bool free=probe.TestMobjLocation();probe.Destroy();if(!free)return;
        let body=entry.Body;
        if(!entry.Created)body=CreateResident(identity,point);
        else if(!entry.Resume(point))return;
        if(body==null)return;
        entry.Emitted=true;entry.ResidentMap=level.MapName;entry.Position=point;
        entry.DeploymentResolved=true;DeploymentPending=--Unresolved>0;
        body.DeploymentStep=2;Bind(port,identity);
    }

    override void PreTravelled()
    {
        TravelPropertyChest(false);
        for(int i=0;i<Residents.Size();i++)
        {
            let entry=Residents[i];let body=entry.Body;if(body==null)continue;
            // Redención ya posee su protocolo viajero; nunca ocultarlo dos veces.
            entry.Delegated=DelegatesTravel(entry);
            if(entry.Delegated)
            {
                entry.ParkBinding();TravelBinding(entry);continue;
            }
            if(!entry.Suspended && entry.AssignmentInitialized)
            {
                entry.GunIndex=-1;entry.GunSlot=-1;
                if(body.Port!=null && body.Gun!=null)
                {
                    for(int g=0;g<body.Port.Guns.Size();g++)
                        if(body.Port.Guns[g]==body.Gun)entry.GunIndex=g;
                    for(int s=0;s<body.Gun.Operators.Size();s++)
                        if(body.Gun.Operators[s]==body)entry.GunSlot=s;
                }
            }
            entry.Suspend();
            body.Port=null;body.Gun=null;body.HomeDoor=null;body.target=null;body.LastEnemy=null;
            if(body.NavigationTarget!=null){body.NavigationTarget.Destroy();body.NavigationTarget=null;}
            if(body.RecoveryGoal!=null){body.RecoveryGoal.Destroy();body.RecoveryGoal=null;}
            body.CityNavigation=null;
            body.YieldFor=null;
            body.CaelumMassScheduler=null;body.CaelumRecognitionTarget=null;body.RecoveryThreat=null;
            body.ChangeStatNum(STAT_TRAVELLING);
            for(Inventory item=body.Inv;item!=null;item=item.Inv)
            {item.UnlinkFromWorld();item.ChangeStatNum(STAT_TRAVELLING);}
            TravelBinding(entry);
        }
        Ready=false;PlacementPending.Clear();
    }

    void TravelBinding(CaelumHouseResident entry)
    {
        if(entry.Binding==null)return;
        entry.Binding.ChangeStatNum(STAT_TRAVELLING);
        for(Inventory item=entry.Binding.Inv;item!=null;item=item.Inv)
        {item.UnlinkFromWorld();item.ChangeStatNum(STAT_TRAVELLING);}
    }

    override void Travelled()
    {
        TravelPropertyChest(true);
        for(int i=0;i<Residents.Size();i++)
        {
            let entry=Residents[i];let body=entry.Body;if(body==null)continue;
            if(entry.Delegated)
            {
                entry.ResidentMap=level.MapName;
                if(entry.Binding!=null)
                {
                    entry.Binding.ChangeStatNum(STAT_DEFAULT);entry.Binding.SetOrigin(Owner.Pos,false);
                    entry.Binding.FindFloorCeiling();entry.Binding.A_ChangeLinkFlags(0,0);
                    for(Inventory item=entry.Binding.Inv;item!=null;item=item.Inv)
                    {item.ChangeStatNum(STAT_INVENTORY);item.SetOrigin(Owner.Pos,false);}
                }
                continue;
            }
            // Salir de STAT_TRAVELLING antes de la limpieza nativa de viajeros.
            body.ChangeStatNum(body.CombatProfileInitialized?PARKED_STAT:STAT_DEFAULT);
            body.SetOrigin(Owner.Pos,false);body.FindFloorCeiling();
            for(Inventory item=body.Inv;item!=null;item=item.Inv)
            {item.ChangeStatNum(PARKED_STAT);item.SetOrigin(body.Pos,false);}
            if(entry.Binding!=null)
            {
                entry.Binding.ChangeStatNum(PARKED_STAT);entry.Binding.SetOrigin(Owner.Pos,false);
                entry.Binding.FindFloorCeiling();
                for(Inventory item=entry.Binding.Inv;item!=null;item=item.Inv)
                {item.ChangeStatNum(PARKED_STAT);item.SetOrigin(Owner.Pos,false);}
            }
        }
        Ready=false;
    }

    Default { Inventory.MaxAmount 1; +INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE }
    States { Spawn: TNT1 A -1; Stop; }
}
