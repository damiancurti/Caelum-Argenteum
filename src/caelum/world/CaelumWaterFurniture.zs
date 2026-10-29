// #410: cada fuente conserva su recipiente nativo; no comparte ni reinicia el
// agua de la vivienda. La cisterna acepta traslados, nunca repone ni purifica.
class CaelumWaterFurnitureReservoir : CaelumWaterContainer
{
    int VesselKind;
    override double GetCapacityLiters(){return CaelumWaterFurnitureData.Capacity(VesselKind);}
    override double GetUnitWeight(){return CaelumWaterFurnitureData.EmptyKg(VesselKind)+Max(0.0,WaterLiters);}
    override void Tick()
    {
        let world=CaelumThermalWorld.Get();
        if(TemperatureClockReady && world!=null && world.ReferenceClock!=null
            && CaelumThermalRuntime.Stamp(world.ReferenceClock)<TemperatureStamp)return;
        Super.Tick();
    }
    override double CoolWater(double ambient,double wind,double seconds)
    {
        if(seconds<=0 || WaterLiters<=0)return WaterTemperatureC;
        double film=CaelumThermalRules.AirConvection(wind)+CaelumThermalData.REFERENCE_RADIATION;
        double conductance=CaelumWaterFurnitureData.ThermalArea(VesselKind)
            /(CaelumWaterFurnitureData.WALL_M/CaelumCampData.IRON_K+1/film);
        double capacity=WaterLiters*CaelumWaterThermalData.WATER_CP
            +CaelumWaterFurnitureData.EmptyKg(VesselKind)*CaelumCampData.IRON_CP;
        return ambient+(WaterTemperatureC-ambient)*Exp(-conductance*seconds/capacity);
    }
    Default {+INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE +INVENTORY.UNCLEARABLE}
    States {Spawn:TNT1 A -1;Stop;}
}

class CaelumWaterFurniture : CaelumDomesticFixture abstract
{
    int WaterRevision;
    double RefillStamp;
    CaelumWaterFurnitureReservoir Reserve;
    virtual int VesselKind(){return 0;}
    override double WaterCapacity(){return CaelumWaterFurnitureData.Capacity(VesselKind());}
    override double WaterRefillPerMinute(){return CaelumWaterFurnitureData.Refill(VesselKind());}
    override void PostBeginPlay()
    {
        Super.PostBeginPlay();
        A_SetSize(CaelumWaterFurnitureData.Radius(VesselKind()),CaelumWaterFurnitureData.Height(VesselKind()),false);
        RefreshMass();
    }
    override void Tick()
    {
        Super.Tick();
        // Sólo la primera inicialización necesita encontrar al dueño del reloj.
        // Después la reserva se liquida al usarla, como las fuentes domésticas.
        if(WaterRevision>=CaelumWaterFurnitureData.REVISION)return;
        for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])
        {let user=CaelumPlayer(players[i].mo);if(CaelumPlayerAuthority.CanMutate(user)){SyncWater(user);break;}}
    }
    void RefreshMass(){Mass=int(Ceil(CaelumWaterFurnitureData.EmptyKg(VesselKind())+(Reserve==null?0:Reserve.WaterLiters)));}
    void SettleTemperature(CaelumPlayer user,double now)
    {
        if(Reserve==null || (Reserve.TemperatureClockReady && now<=Reserve.TemperatureStamp))return;
        let world=CaelumThermalWorld.Get();if(world==null || world.ReferenceWeather==null)return;
        let weather=world.ReferenceWeather;
        if(weather.Outside==null || !weather.Outside.Available)return;
        int shelter=CaelumThermalEnvironment.ClimateShelter(weather.Profile,CaelumThermalShelter.Roof(self),CaelumThermalShelter.WindBlocked(self));
        let local=world.LocalSample(weather,shelter);if(local==null || !local.Available)return;
        if(Reserve.WaterTemperatureRevision==0)Reserve.WaterTemperatureC=local.AirTemperatureC;
        else if(Reserve.TemperatureClockReady && Reserve.WaterLiters>0)
            Reserve.WaterTemperatureC=Reserve.CoolWater(local.AirTemperatureC,local.WindSpeedKmh/3.6,now-Reserve.TemperatureStamp);
        Reserve.WaterTemperatureRevision=CaelumWaterThermalData.REVISION;
        Reserve.TemperatureStamp=now;Reserve.TemperatureClockReady=true;
    }
    override bool CanReach(CaelumPlayer user)
    {
        return Installed && CaelumPlayerAuthority.CanMutate(user) && user.health>0 && !user.isFrozen()
            && user.Distance3D(self)<=user.UseRange+Radius && user.CheckSight(self)
            && CaelumPropertyRules.ResidenceAllowed(user);
    }
    void SyncWater(CaelumPlayer user)
    {
        let clock=CaelumWorldClock.Get(user);if(clock==null)return;
        double now=CaelumThermalRuntime.Stamp(clock);
        if(Reserve==null)
        {
            Reserve=CaelumWaterFurnitureReservoir(FindInventory('CaelumWaterFurnitureReservoir'));
            if(Reserve==null)
            {
                Reserve=CaelumWaterFurnitureReservoir(Actor.Spawn('CaelumWaterFurnitureReservoir',Pos,NO_REPLACE));
                if(Reserve==null)return;
                Reserve.VesselKind=VesselKind();Reserve.AttachToOwner(self);
            }
        }
        Reserve.VesselKind=VesselKind();SettleTemperature(user,now);
        if(WaterRevision<CaelumWaterFurnitureData.REVISION)
        {
            Reserve.WaterLiters=CaelumWaterFurnitureData.InitialLiters(VesselKind());
            Reserve.WaterQuality=CaelumWaterQuality.POTABLE;Reserve.EnsureWaterQuality();
            RefillStamp=now;WaterRevision=CaelumWaterFurnitureData.REVISION;RefreshMass();return;
        }
        if(now<=RefillStamp)return;
        double added=Min(Max(0.0,WaterCapacity()-Reserve.WaterLiters),(now-RefillStamp)*WaterRefillPerMinute()/60.0);
        if(added>0)
        {
            let world=CaelumThermalWorld.Get();double temperature=Reserve.WaterTemperatureC;
            if(world!=null && world.ReferenceWeather!=null && world.ReferenceWeather.Outside!=null
                && world.ReferenceWeather.Outside.Available)temperature=world.ReferenceWeather.Outside.AirTemperatureC;
            Reserve.AddWater(added,CaelumWaterQuality.POTABLE,temperature,true);
        }
        RefillStamp=now;RefreshMass();
    }
    override bool WaterSafe(CaelumPlayer user)
    {SyncWater(user);return Reserve!=null && Reserve.IsPotable();}
    override double AvailableWater(CaelumPlayer user)
    {SyncWater(user);return Reserve==null?0:Reserve.WaterLiters;}
    override bool SpendWater(CaelumPlayer user,double liters)
    {
        SyncWater(user);
        if(Reserve==null || liters<=0 || liters>Reserve.WaterLiters)return false;
        Reserve.WaterLiters=Max(0.0,Reserve.WaterLiters-liters);
        if(Reserve.WaterLiters<=0)Reserve.WaterQuality=CaelumWaterQuality.POTABLE;
        RefreshMass();
        return true;
    }
    override bool Fill(CaelumPlayer user,CaelumWaterContainer container)
    {
        if(!CanReach(user) || container==null || container.Owner!=user || container.InMagicBox)return false;
        SyncWater(user);if(Reserve==null)return false;
        double liters=Min(Max(0.0,container.GetCapacityLiters()-container.WaterLiters),Reserve.WaterLiters);
        if(liters<=0.000001 || !user.CanAddWeightToPersonalInventory(liters+0.001)
            || !container.AddWater(liters,Reserve.WaterQuality,Reserve.WaterTemperatureC,Reserve.WaterTemperatureRevision>0))return false;
        SpendWater(user,liters);
        let record=user.GetPersistentCharacterState(false);
        if(container.IsPotable() && record!=null && record.MainM00WaterContainerGiven)record.MainM00WaterFilled=true;
        user.OnNativeInventoryChanged();user.PersistCharacterState();return true;
    }
    bool Deposit(CaelumPlayer user,CaelumWaterContainer container)
    {
        if(VesselKind()!=1 || !CanReach(user) || container==null || container.Owner!=user || container.InMagicBox
            || CaelumWaterBoiling.Locked(container))return false;
        SyncWater(user);if(Reserve==null)return false;
        double liters=Min(Max(0.0,WaterCapacity()-Reserve.WaterLiters),container.WaterLiters);
        if(liters<=0.000001)return false;
        container.EnsureWaterTemperature(user);
        if(!Reserve.AddWater(liters,container.WaterQuality,container.WaterTemperatureC,container.WaterTemperatureRevision>0))return false;
        container.WaterLiters=Max(0.0,container.WaterLiters-liters);
        if(container.WaterLiters<=0)container.WaterQuality=CaelumWaterQuality.POTABLE;
        RefreshMass();
        user.OnNativeInventoryChanged();user.PersistCharacterState();return true;
    }
    override bool Used(Actor activator)
    {
        let user=CaelumPlayer(activator);
        if(!CanReach(user) || !CaelumUseGeometry.AimedAt(user,self))return false;
        if(user.player!=null && (user.player.cmd.buttons & BT_SPEED))return CaelumBathSession.Show(user);
        SyncWater(user);if(Reserve==null)return false;
        CaelumNotifications.Notify(user,String.Format(StringTable.Localize('CA_WATER_FURNITURE_STATUS',false),
            Reserve.WaterLiters,WaterCapacity(),CaelumWaterQuality.Label(Reserve.WaterQuality)));
        return true;
    }
    static void InventoryDeposit(CaelumPlayer user)
    {
        if(!CaelumPlayerAuthority.CanMutate(user) || user.health<=0 || user.isFrozen())return;
        let container=CaelumWaterContainer(user.GetFormalInventoryEntryAt(user.FormalInventorySelectionIndex));
        let source=CaelumWaterFurniture(CaelumDomesticFixture.SourceFor(user));
        bool changed=source!=null && source.Deposit(user,container);
        CaelumNotifications.Notify(user,StringTable.Localize(changed?'CA_WATER_DEPOSITED':'CA_WATER_DEPOSIT_REJECTED',false));
        user.RefreshFormalInventorySnapshot();
    }
}
class CaelumFountain : CaelumWaterFurniture
{
    Default {Tag "$CA_FURNITURE_FOUNTAIN";}
    States {Spawn:CWFN A -1;Stop;}
}
class CaelumCistern : CaelumWaterFurniture
{
    override int VesselKind(){return 1;}
    Default {Tag "$CA_FURNITURE_CISTERN";}
    States {Spawn:CWCT A -1;Stop;}
}
class CaelumMansionWaterFurniture : Actor
{
    int Revision;
    CaelumWaterFurniture Fixtures[2];
    static bool Prepare()
    {
        if(level.MapName!='MAP01')return true;
        // Registro tipado sólo durante instalación/migración; dos fuentes.
        let node=CaelumMansionWaterFurniture(ThinkerIterator.Create('CaelumMansionWaterFurniture').Next());
        if(node==null)node=CaelumMansionWaterFurniture(Actor.Spawn('CaelumMansionWaterFurniture',(0,0,0),NO_REPLACE));
        if(node==null)return false;
        bool ready=true;
        for(int kind=0;kind<2;kind++)
        {
            if(node.Fixtures[kind]!=null)continue;
            vector3 position=CaelumWaterFurnitureData.Position(kind);
            let body=CaelumWaterFurniture(Actor.Spawn(kind==0?'CaelumFountain':'CaelumCistern',position,NO_REPLACE));
            if(body==null){ready=false;continue;}
            body.Angle=CaelumWaterFurnitureData.Facing(kind);
            body.A_SetSize(CaelumWaterFurnitureData.Radius(kind),CaelumWaterFurnitureData.Height(kind),false);
            if(!body.TestMobjLocation() || !body.ClearOfActors(body) || Abs(body.FloorZ-position.Z)>1 || body.WaterLevel!=0)
            {body.Destroy();ready=false;continue;}
            body.Installed=true;node.Fixtures[kind]=body;
        }
        if(ready)node.Revision=CaelumWaterFurnitureData.REVISION;
        return ready;
    }
    Default {+NOINTERACTION +NOGRAVITY}
    States {Spawn:TNT1 A -1;Stop;}
}
