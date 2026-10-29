// #502: sólo los objetos físicos expuestos poseen un planificador ambiental.
// Los eventos crean el enlace; no se busca el conjunto de actores por tic.
class CaelumContaminationObject : Thinker
{
    Actor Body;
    int Revision;
    transient bool Ready;
    transient int NextUpdate;
    transient double Stamp,Ambient,Rain;
    // Revisión 2: sólo el clima constante del Limbo permite cerrar la ausencia
    // exactamente con una integración. No prolonga sellos temporales fuera del mapa.
    bool HistoryReady;
    double HistoryStamp,HistoryAmbient,HistoryArea;
    transient bool ConstantSample;

    static bool Eligible(Actor body)
    {
        if(body==null || body.bDestroyed || body is 'CaelumPlayer' || body is 'CaelumCombatActor' || body.bMissile)return false;
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
        let node=new('CaelumContaminationObject');node.Body=body;node.Revision=2;entry.Exposure=node;
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
        Ambient=-1;Rain=0;ConstantSample=false;
        let weather=world.ReferenceWeather;
        if(weather==null || weather.Outside==null || !weather.Outside.Available)return;
        bool roof=CaelumThermalShelter.Roof(Body);
        int shelter=CaelumThermalEnvironment.ClimateShelter(weather.Profile,roof,CaelumThermalShelter.WindBlocked(Body));
        let local=world.LocalSample(weather,shelter);if(local==null || !local.Available)return;
        roof=roof || CaelumCampShelter.Find(Body)!=null;
        Rain=roof?0:local.PrecipitationMmPerHour;
        double heat,humidity,wind,direction;
        [heat,humidity,wind,direction]=CaelumSealClimate.Delta(Body,0,0);
        double reference=CaelumContaminationEnvironment.ReferenceAt(Body);
        if(reference>=0)Ambient=CaelumContaminationRules.Ambient(reference,local.AirTemperatureC+heat,
            Clamp(local.RelativeHumidityPercent+humidity,0.0,100.0),Rain,!roof);
        ConstantSample=Ambient>=0 && weather.Profile==CaelumWeatherRules.PROFILE_LIMBO
            && heat==0 && humidity==0 && Rain==0;
    }
    void Advance()
    {
        if(!Eligible(Body))return;
        let world=CaelumThermalWorld.Get();
        if(world==null || world.ReferenceClock==null){Ready=false;return;}
        double now=CaelumThermalRuntime.Stamp(world.ReferenceClock);
        if(Revision>=2 && HistoryReady && now<HistoryStamp){Ready=false;return;}
        if(Ready && now>Stamp && Ambient>=0)
        {
            let stored=CaelumContaminationStorage.Get(Body);
            double value=stored!=null?stored.Concentration:0;
            double next=CaelumContaminationObjectBalance.Evolve(value,Ambient,Rain,Area(Body),now-Stamp);
            if(stored!=null && next!=value)stored.Concentration=Clamp(next,0.0,CaelumFoodData.MAX_CONTAMINATION);
        }
        else if(!Ready && Revision>=2 && HistoryReady && now>HistoryStamp)
        {
            let stored=CaelumContaminationStorage.Get(Body);
            double value=stored!=null?stored.Concentration:0;
            double next=CaelumContaminationObjectBalance.Evolve(value,HistoryAmbient,0,HistoryArea,now-HistoryStamp);
            if(stored!=null && next!=value)stored.Concentration=Clamp(next,0.0,CaelumFoodData.MAX_CONTAMINATION);
        }
        Stamp=now;Sample(world);
        // Las partidas previas empiezan aquí: no se inventa una fecha histórica
        // ni se borra la concentración ya guardada. Repetir no cobra dos veces.
        Revision=2;HistoryReady=ConstantSample;HistoryStamp=now;
        HistoryAmbient=Ambient;HistoryArea=Area(Body);
        if(!Ready)NextUpdate=level.maptime+1+world.NextPhase++%TICRATE;
        else NextUpdate=level.maptime+TICRATE;
        Ready=true;
    }
    override void Tick()
    {
        if(!Eligible(Body)){Release();return;}
        if(!Ready || level.maptime>=NextUpdate)Advance();
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
