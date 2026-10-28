// #502: sólo los objetos físicos expuestos poseen un planificador ambiental.
// Los eventos crean el enlace; no se busca el conjunto de actores por tic.
class CaelumContaminationObject : Thinker
{
    Actor Body;
    int Revision;
    transient bool Ready;
    transient int NextUpdate;
    transient double Stamp,Ambient,Rain;
    // Revisión 4 conserva el intervalo de un sello y lo cierra al salir;
    // el mapa ausente continúa sólo con su clima natural.
    bool HistoryReady;
    double HistoryStamp,HistoryAmbient,HistoryArea;
    bool HistoryVariable,HistoryCovered;
    int HistoryProfile,HistoryRegion,HistorySeed,HistoryShelter;
    double HistoryReference,HistoryCivilOffset;
    double HistoryRain;
    double HistoryNaturalAmbient;
    bool HistoryTemporaryClimate,HistoryNaturalVariable;
    transient double NaturalAmbient;
    transient bool SampleReady,SampleTemporaryClimate,SampleNaturalVariable;

    static bool Eligible(Actor body)
    {
        if(body==null || body.bDestroyed || body is 'CaelumPlayer' || body is 'CaelumCombatActor' || body.bMissile)return false;
        let desk=CaelumPortableReadingDesk(body);
        if(desk!=null && desk.PackedItem!=null && desk.PackedItem.Owner!=body)return false;
        let shelf=CaelumPortableReadingShelf(body);
        if(shelf!=null && shelf.Storage!=null && shelf.Storage.Cargo!=null)return false;
        if(body is 'CaelumPortableBookcaseStorage')return false;
        let rest=CaelumRestFurniture(body);
        if(rest!=null && rest.PackedItem!=null && rest.PackedItem.Owner!=body)return false;
        let sofa=CaelumSofa(body);
        if(sofa!=null && sofa.PackedItem!=null && sofa.PackedItem.Owner!=body)return false;
        if(body is 'CaelumSofaSeat')return false;
        let vendor=CaelumCityMerchant(body);if(vendor!=null && vendor.DomesticMarketParked)return false;
        let item=Inventory(body);
        if(item!=null)return item is 'CaelumEquipmentItem' && item.Owner==null;
        // Una silla ocupada presta su colisión al jugador, pero sigue siendo
        // un mueble expuesto. Su configuración física de clase no desaparece.
        return (body is 'CaelumPhysicalScenery' || body.bSolid || GetDefaultByType(body.GetClass()).bSolid)
            && body.Radius>0 && body.Height>0;
    }
    static double Area(Actor body)
    {
        let seat=CaelumSofaSeat(body);if(seat!=null && seat.Sofa!=null)return Area(seat.Sofa);
        let item=CaelumEquipmentItem(body);
        if(item==null)return CaelumContaminationRules.CylinderArea(body.Radius,body.Height);
        if(item.EquipmentKind==CaelumConstants.EQUIPMENT_KIND_WEAPON)
            return CaelumContaminationRules.WeaponArea(item.ItemType,item.EquipmentSize);
        if(item.EquipmentKind==CaelumConstants.EQUIPMENT_KIND_SHIELD)
            return CaelumContaminationRules.ShieldArea(item.ItemType,item.EquipmentSize);
        if(item.EquipmentKind==CaelumConstants.EQUIPMENT_KIND_ARMOR || item.EquipmentKind==CaelumConstants.EQUIPMENT_KIND_CLOTHING)
            return CaelumContaminationRules.GarmentArea(item.ArmorSlot,item.EquipmentSize);
        return CaelumContaminationRules.CylinderArea(body.Radius,body.Height);
    }
    static void Register(Actor body)
    {
        if(!Eligible(body))return;
        let entry=CaelumContaminationStorage.Get(body,true);if(entry==null || entry.Exposure!=null)return;
        let node=new('CaelumContaminationObject');node.Body=body;node.Revision=4;entry.Exposure=node;
    }
    static void LeavingWorld(Actor body)
    {
        let entry=CaelumContaminationStorage.Get(body);
        if(entry==null || entry.Exposure==null)return;
        let node=entry.Exposure;node.Advance();node.Release();
    }
    void Release()
    {
        let entry=Body!=null && !Body.bDestroyed?CaelumContaminationStorage.Get(Body):null;
        if(entry!=null && entry.Exposure==self)entry.Exposure=null;
        Body=null;Destroy();
    }
    void Sample(CaelumThermalWorld world)
    {
        Ambient=NaturalAmbient=-1;Rain=0;SampleReady=false;SampleTemporaryClimate=false;SampleNaturalVariable=false;HistoryVariable=false;
        let weather=world.ReferenceWeather;
        if(weather==null || weather.Outside==null || !weather.Outside.Available)return;
        bool roof=CaelumThermalShelter.Roof(Body);
        int shelter=CaelumThermalEnvironment.ClimateShelter(weather.Profile,roof,CaelumThermalShelter.WindBlocked(Body));
        let local=world.LocalSample(weather,shelter);if(local==null || !local.Available)return;
        roof=roof || CaelumCampShelter.Find(Body)!=null;
        Rain=roof?0:local.PrecipitationMmPerHour;
        double heat=0,humidity=0,wind=0,direction=0;
        [heat,humidity,wind,direction]=CaelumSealClimate.Delta(Body,0,0,true);
        SampleTemporaryClimate=heat!=0 || humidity!=0;
        double reference=CaelumContaminationEnvironment.ReferenceAt(Body);
        if(reference>=0)
        {
            NaturalAmbient=CaelumContaminationRules.Ambient(reference,local.AirTemperatureC,local.RelativeHumidityPercent,Rain,!roof);
            Ambient=SampleTemporaryClimate?CaelumContaminationRules.Ambient(reference,local.AirTemperatureC+heat,
                Clamp(local.RelativeHumidityPercent+humidity,0.0,100.0),Rain,!roof):NaturalAmbient;
        }
        SampleReady=Ambient>=0;
        if(!SampleReady || weather.Profile==CaelumWeatherRules.PROFILE_LIMBO)return;
        let calendar=world.ReferenceCalendar;let clock=world.ReferenceClock;
        if(calendar==null || clock==null || calendar.DateSerial(clock)<0)
        {SampleReady=false;return;}
        SampleNaturalVariable=true;HistoryVariable=!SampleTemporaryClimate;HistoryCovered=roof;
        HistoryProfile=weather.Profile;HistoryRegion=weather.Region;HistorySeed=weather.Seed;
        HistoryShelter=shelter;HistoryReference=reference;
        HistoryCivilOffset=double(calendar.DateSerial(clock))*86400
            +double(calendar.CivilDayTics(clock))*3600/CaelumWorldClock.TicsPerHour()
            -CaelumThermalRuntime.Stamp(clock);
    }
    double Replay(double value,double now)
    {
        if(Revision<3 || !HistoryVariable)
            return CaelumContaminationObjectBalance.Evolve(value,HistoryAmbient,Revision>=4?HistoryRain:0,HistoryArea,now-HistoryStamp);
        let world=CaelumContaminationWorld.Get();
        if(world==null)return value;
        if(world.HistoryWeather==null)world.HistoryWeather=new('CaelumContaminationWeatherCache');
        CaelumContaminationWeatherDay sample;
        double stamp=HistoryStamp;
        while(stamp<now)
        {
            double civil=stamp+HistoryCivilOffset;
            int day=int(Floor(civil/86400.0));
            int minute=int(Floor((civil-double(day)*86400.0)/60.0));
            double end=Min(now,double(day)*86400+(minute+1)*60.0-HistoryCivilOffset);
            if(end<=stamp)end=now;
            if(sample==null || sample.Day!=day)sample=world.HistoryWeather.GetDay(self,day);
            sample.Sample(minute);
            if(sample.Ambient[minute]>=0)value=CaelumContaminationObjectBalance.Evolve(
                value,sample.Ambient[minute],sample.Rain[minute],HistoryArea,end-stamp);
            stamp=end;
        }
        return value;
    }
    void SettleNow()
    {
        if(!Eligible(Body))return;
        if(!Ready){if(HistoryReady)Advance();return;}
        let world=CaelumThermalWorld.Get();
        if(world!=null && world.ReferenceClock!=null)Settle(CaelumThermalRuntime.Stamp(world.ReferenceClock));
    }
    // Lecturas/contactos cierran sólo el intervalo: la geometría/clima actuales
    // siguen muestreándose a la cadencia escalonada, no por cada consulta.
    bool Settle(double now)
    {
        if(Revision>=2 && HistoryReady && now<HistoryStamp)return false;
        if(Revision>=2 && HistoryReady && now>HistoryStamp)
        {
            let stored=CaelumContaminationStorage.Get(Body);
            double value=stored!=null?stored.Concentration:0;
            double next=Replay(value,now);
            if(stored!=null && next!=value)stored.Concentration=Clamp(next,0.0,CaelumFoodData.MAX_CONTAMINATION);
        }
        else if(Ready && now>Stamp && Ambient>=0)
        {
            let stored=CaelumContaminationStorage.Get(Body);
            double value=stored!=null?stored.Concentration:0;
            double next=CaelumContaminationObjectBalance.Evolve(value,Ambient,Rain,Area(Body),now-Stamp);
            if(stored!=null && next!=value)stored.Concentration=Clamp(next,0.0,CaelumFoodData.MAX_CONTAMINATION);
        }
        Stamp=now;if(HistoryReady)HistoryStamp=now;
        return true;
    }
    void Advance()
    {
        if(!Eligible(Body))return;
        let world=CaelumThermalWorld.Get();
        if(world==null || world.ReferenceClock==null){Ready=false;return;}
        double now=CaelumThermalRuntime.Stamp(world.ReferenceClock);
        if(!Settle(now)){Ready=false;return;}
        Sample(world);
        // Las partidas previas empiezan aquí: no se inventa una fecha histórica
        // ni se borra la concentración ya guardada. Repetir no cobra dos veces.
        RecordSample(now);
        if(!Ready)NextUpdate=level.maptime+1+world.NextPhase++%TICRATE;
        else NextUpdate=level.maptime+TICRATE;
        Ready=true;
    }
    void RecordSample(double now)
    {
        Revision=4;HistoryReady=SampleReady;HistoryStamp=now;
        HistoryAmbient=Ambient;HistoryRain=Rain;HistoryArea=Area(Body);
        HistoryTemporaryClimate=SampleTemporaryClimate;
        HistoryNaturalAmbient=NaturalAmbient;HistoryNaturalVariable=SampleNaturalVariable;
    }
    void Depart()
    {
        if(!HistoryTemporaryClimate || !Eligible(Body))return;
        let world=CaelumThermalWorld.Get();if(world==null || world.ReferenceClock==null)return;
        double now=CaelumThermalRuntime.Stamp(world.ReferenceClock);
        if(!Settle(now))return;
        // La muestra ya conserva abrigo, región y clima base. No repetir mil
        // trazas geométricas durante la transición ni prolongar el sello.
        HistoryTemporaryClimate=false;HistoryVariable=HistoryNaturalVariable;
        HistoryAmbient=HistoryNaturalAmbient;HistoryStamp=now;
        Ambient=HistoryAmbient;SampleTemporaryClimate=false;Ready=true;
    }
    override void Tick()
    {
        if(!Eligible(Body)){Release();return;}
        if(!Ready || level.maptime>=NextUpdate)Advance();
    }
}

// Caché transitoria por fecha y lugar; no contiene concentraciones ni modifica
// los intervalos. La cota sólo limita memoria: una expulsión vuelve a calcular
// el mismo clima determinista y jamás descarta tiempo de exposición.
class CaelumContaminationWeatherCache : Object play
{
    const MAX_DAYS=32;
    Array<CaelumContaminationWeatherDay> Days;
    double Sequence;
    CaelumContaminationWeatherDay GetDay(CaelumContaminationObject n,int date)
    {
        int oldest=0;
        for(int i=0;i<Days.Size();i++)
        {
            let d=Days[i];
            if(d.Day==date && d.Profile==n.HistoryProfile && d.Region==n.HistoryRegion
                && d.Seed==n.HistorySeed && d.Shelter==n.HistoryShelter
                && d.Reference==n.HistoryReference && d.Covered==n.HistoryCovered)
            {d.Used=++Sequence;return d;}
            if(d.Used<Days[oldest].Used)oldest=i;
        }
        let d=new('CaelumContaminationWeatherDay');
        d.Day=date;d.Profile=n.HistoryProfile;d.Region=n.HistoryRegion;d.Seed=n.HistorySeed;
        d.Shelter=n.HistoryShelter;d.Reference=n.HistoryReference;d.Covered=n.HistoryCovered;
        d.Used=++Sequence;d.Outside=new('CaelumWeatherSample');d.Local=new('CaelumWeatherSample');
        if(Days.Size()<MAX_DAYS)Days.Push(d);else Days[oldest]=d;
        return d;
    }
}
class CaelumContaminationWeatherDay : Object play
{
    int Day,Profile,Region,Seed,Shelter;
    double Reference,Used;
    bool Covered;
    bool Ready[1440];
    double Ambient[1440],Rain[1440];
    CaelumWeatherSample Outside,Local;
    void Sample(int minute)
    {
        if(Ready[minute])return;
        Outside.EvaluateRegion(Region,Day,minute*(CaelumWorldClock.TicsPerHour()/60),Seed);
        Local.ApplyShelter(Outside,Shelter,Profile);
        Rain[minute]=Covered?0:Local.PrecipitationMmPerHour;
        Ambient[minute]=Local.Available?CaelumContaminationRules.Ambient(Reference,
            Local.AirTemperatureC,Local.RelativeHumidityPercent,Rain[minute],!Covered):-1;
        Ready[minute]=true;
    }
}

// El área de objetos pequeños puede hacer que el lavado supere la exposición.
// Integra ambas tasas a la vez, sin sumar/substraer por orden de los tics.
class CaelumContaminationObjectBalance : Object play
{
    static double Travel(double start,double end,double rate,double wash)
    {
        if(Max(start,end)*wash/rate<=0.125)
            return CaelumContaminationTile.ExposureTime(start,end,rate,wash);
        double ratio=(rate-wash*end)/(rate-wash*start);
        if(ratio<=0)return 1e100;
        return (start-end)/wash-rate/(wash*wash)*Log(ratio);
    }
    static double Evolve(double value,double ambient,double rain,double area,double seconds)
    {
        if(seconds<=0 || area<=0 || ambient<0)return value;
        double wash=CaelumContaminationRules.RainReduction(rain)/CaelumContaminationData.RAIN_WASH_SECONDS;
        if(wash<=0)return CaelumContaminationRules.AfterContact(value,ambient,area,seconds);
        double rate=CaelumContaminationData.CONTACT_DEGREES_M2_SECOND*ambient*area;
        // Por encima del ambiente sólo lava; no aumenta la fuente ambiental.
        if(value>ambient)
        {
            double step=Min(seconds,(value-ambient)/wash);value-=step*wash;seconds-=step;
        }
        if(seconds<=0)return value;
        if(ambient<=0)return Max(0.0,value-wash*seconds);
        if(value>=ambient && rate/Max(ambient,1.0)>=wash)return ambient;
        if(value<1)
        {
            double speed=rate-wash;
            if(speed<=0)return Max(0.0,value+speed*seconds);
            double limit=Min(1.0,ambient),step=Min(seconds,(limit-value)/speed);
            value+=speed*step;seconds-=step;
        }
        if(seconds<=0 || (value>=ambient && rate/Max(ambient,1.0)>=wash))return value;
        double equilibrium=rate/wash;
        if(Abs(value-equilibrium)<1e-12)return value;
        bool rising=value<equilibrium;
        double limit=rising?Min(ambient,equilibrium):Max(1.0,equilibrium);
        if(limit!=equilibrium)
        {
            double step=Travel(value,limit,rate,wash);
            if(seconds>=step)
            {
                if(rising)return limit;
                return Max(0.0,limit+(rate-wash)*(seconds-step));
            }
        }
        double lo=Min(value,limit),hi=Max(value,limit);
        for(int i=0;i<44;i++)
        {
            double mid=(lo+hi)*0.5,elapsed=Travel(value,mid,rate,wash);
            if((elapsed<seconds)==rising)lo=mid;else hi=mid;
        }
        return (lo+hi)*0.5;
    }
}
