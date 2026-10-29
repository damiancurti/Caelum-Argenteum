// Un controlador guardado por instalación. El ticker existente conserva la
// referencia; sólo mapas con metadatos de instalación recorren sus sectores.
class CaelumConnectedWaterMap : Actor
{
    int Revision;
    CaelumConnectedWaterState Water;
    Sector Models[2];
    Sector GateModel;
    bool ClockReady;
    double Stamp;
    CaelumWaterGateSwitch GateControl;
    Default { +NOINTERACTION +NOGRAVITY }
    States { Spawn: TNT1 A -1; Stop; }

    void Bind()
    {
        if(Revision>=CaelumConnectedWaterData.REVISION)return;
        for(int i=0;i<level.Sectors.Size();i++)
        {
            let sector=level.Sectors[i];int id=sector.GetUDMFInt('user_ca_connected_water_id');
            if(id==1 || id==2)Models[id-1]=sector;
            if(sector.GetUDMFInt('user_ca_connected_water_gate')==1)GateModel=sector;
        }
        if(Models[0]==null || Models[1]==null)return;
        Water=new('CaelumConnectedWaterState');Water.Initialize();
        Revision=CaelumConnectedWaterData.REVISION;
        ApplyLevels();
    }
    static clearscope CaelumConnectedWaterMap Get()
    {
        let ticker=CaelumWorldClockTicker(StaticEventHandler.Find('CaelumWorldClockTicker'));
        return ticker!=null ? ticker.WaterMap : null;
    }
    static void Initialize()
    {
        let ticker=CaelumWorldClockTicker(StaticEventHandler.Find('CaelumWorldClockTicker'));
        if(ticker==null)return;
        ticker.WaterMap=null;
        if(level.Sectors.Size()==0 || level.Sectors[0].GetUDMFInt('user_ca_connected_water')!=1)return;
        let iterator=ThinkerIterator.Create('CaelumConnectedWaterMap');
        let installation=CaelumConnectedWaterMap(iterator.Next());
        if(installation==null)installation=CaelumConnectedWaterMap(Actor.Spawn('CaelumConnectedWaterMap',(0,0,0),NO_REPLACE));
        if(installation==null)return;
        installation.Bind();ticker.WaterMap=installation;
        if(installation.GateControl==null && level.Sectors[0].GetUDMFInt('user_ca_water_switch')!=0)
        {
            let metadata=level.Sectors[0];
            vector3 position=(metadata.GetUDMFFloat('user_ca_water_switch_x'),metadata.GetUDMFFloat('user_ca_water_switch_y'),metadata.GetUDMFFloat('user_ca_water_switch_z'));
            installation.GateControl=CaelumWaterGateSwitch(Actor.Spawn('CaelumWaterGateSwitch',position,NO_REPLACE));
            if(installation.GateControl!=null)installation.GateControl.Angle=metadata.GetUDMFFloat('user_ca_water_switch_angle');
        }
    }
    static double ClockStamp(CaelumWorldClock clock)
    {
        return double(clock.CompletedDays)*CaelumThermalData.WORLD_DAY_SECONDS
            +double(clock.DayTics)*3600.0/CaelumWorldClock.TicsPerHour()+double(clock.LimboSubTics)/TICRATE;
    }
    void Sync(CaelumWorldClock clock)
    {
        if(clock==null || Water==null)return;
        double now=ClockStamp(clock);
        if(!ClockReady){Stamp=now;ClockReady=true;}
        if(now<Stamp)return;
        Water.Advance(now-Stamp);Stamp=now;ApplyLevels();
    }
    void ApplyLevels()
    {
        if(Water==null)return;
        vector2 height=Water.Heights(Water.Liters);
        for(int i=0;i<2;i++)
        {
            let sector=Models[i];if(sector==null)continue;
            double current=sector.CenterCeiling();
            double target=sector.CenterFloor()+(i==0?height.X:height.Y)*CaelumPhysicsUnits.MAP_UNITS_PER_METER;
            if(target==current)continue;
            sector.MoveCeiling(Abs(target-current),sector.ceilingplane.PointToDist((0,0),target),-1,target>current?1:-1,false);
        }
        if(GateModel!=null)
        {
            double current=GateModel.CenterCeiling();
            double target=GateModel.CenterFloor()+(Water.Open?0:Water.DiameterM*CaelumPhysicsUnits.MAP_UNITS_PER_METER);
            if(target!=current)GateModel.MoveCeiling(Abs(target-current),GateModel.ceilingplane.PointToDist((0,0),target),-1,target>current?1:-1,false);
        }
    }
    clearscope int Index(Sector source)
    {for(int i=0;i<2;i++)if(Models[i]==source)return i;return -1;}
    clearscope int Quality(int index)
    {return Water==null || index<0 || index>1 ? CaelumWaterQuality.UNIDENTIFIED : index==0?Water.QualityA:Water.QualityB;}
    clearscope double Available(int index)
    {return Water==null || Water.PendingSeconds>0 || index<0 || index>1 ? 0 : index==0?Water.Liters.X:Water.Liters.Y;}
    double Withdraw(int index,double liters)
    {if(Water==null)return 0;double taken=Water.Withdraw(index,liters);ApplyLevels();return taken;}
    bool Toggle(CaelumPlayer user)
    {
        Sync(CaelumWorldClock.Get(user));
        if(Water==null || Water.PendingSeconds>0)return false;
        Water.Open=!Water.Open;Water.NextStepSeconds=1;ApplyLevels();return true;
    }
}

// Reutiliza la palanca existente; su estado representa la compuerta del agua.
class CaelumWaterGateSwitch : CaelumHazardReleaseSwitch
{
    override void Tick()
    {
        let installation=CaelumConnectedWaterMap.Get();
        Spent=installation!=null && installation.Water!=null && installation.Water.Open;
        Super.Tick();
    }
    override bool Used(Actor activator)
    {
        let user=CaelumPlayer(activator);
        if(!CaelumPlayerAuthority.CanMutate(user) || user.health<=0 || !user.CharacterCreationComplete
            || user.CreationWizardOpen || !CaelumUseGeometry.AimedAt(user,self)
            || !user.CheckSight(self,SF_IGNOREVISIBILITY))return false;
        let installation=CaelumConnectedWaterMap.Get();
        if(installation==null || !installation.Toggle(user))return false;
        Spent=installation.Water.Open;
        A_StartSound("caelum/world/lever_activate",CHAN_BODY);
        CaelumNotifications.Notify(user,StringTable.Localize(Spent?'CA_CONNECTED_WATER_OPENED':'CA_CONNECTED_WATER_CLOSED',false));
        return true;
    }
    Default { Tag "$CA_CONNECTED_WATER_GATE"; }
}
