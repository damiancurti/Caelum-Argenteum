// Calendario climático del lugar donde queda el alimento. Guarda la región,
// abrigo y fecha civil: volver a un cofre no usa el clima del viajero que vuelve.
class CaelumFoodClimate : Object play
{
    bool Ready;
    int Profile,Region,Seed,Shelter;
    double CivilSeconds,HeatDelta,HumidityDelta;
    transient CaelumWeatherSample Outside,Local;
    transient double CachedMinute;

    CaelumFoodClimate Copy()
    {
        let result=new('CaelumFoodClimate');result.Ready=Ready;
        result.Profile=Profile;result.Region=Region;result.Seed=Seed;result.Shelter=Shelter;
        result.CivilSeconds=CivilSeconds;result.HeatDelta=HeatDelta;result.HumidityDelta=HumidityDelta;
        return result;
    }
    bool Capture(Actor body,CaelumWorldClock clock,CaelumCalendarState calendar,CaelumWeatherState weather)
    {
        if(body==null || clock==null || calendar==null || weather==null || weather.Outside==null)return false;
        int serial=calendar.DateSerial(clock);if(serial<0 || !weather.Outside.Available)return false;
        int oldProfile=Profile,oldRegion=Region,oldSeed=Seed,oldShelter=Shelter;
        Profile=weather.Profile;Region=weather.Region;Seed=weather.Seed;
        let thermal=CaelumThermalBody.Get(body);
        bool roof,wind;
        if(thermal!=null && thermal.SourceMap==level.MapName && thermal.Available)
        {roof=thermal.Roof;wind=thermal.WindSheltered;}
        else {roof=CaelumThermalShelter.Roof(body);wind=CaelumThermalShelter.WindBlocked(body);}
        Shelter=CaelumThermalEnvironment.ClimateShelter(Profile,roof,wind);
        double ignoredWind,ignoredDirection;
        [HeatDelta,HumidityDelta,ignoredWind,ignoredDirection]=CaelumSealClimate.Delta(body,0,0);
        CivilSeconds=double(serial)*86400+double(calendar.CivilDayTics(clock))*3600/CaelumWorldClock.TicsPerHour();
        if(CaelumWorldCatalogue.IsLimboMap(level.MapName))CivilSeconds+=double(clock.LimboSubTics)/TICRATE;
        Ready=true;
        if(oldProfile!=Profile || oldRegion!=Region || oldSeed!=Seed || oldShelter!=Shelter)
        {Outside=null;Local=null;}
        return true;
    }
    double Rate(double when)
    {
        double minute=Floor(when/60);
        if(Outside==null || CachedMinute!=minute)
        {
            if(Outside==null){Outside=new('CaelumWeatherSample');Local=new('CaelumWeatherSample');}
            int day=int(Floor(when/86400));
            int tick=int((minute*60-double(day)*86400)*CaelumWorldClock.TicsPerHour()/3600);
            if(Profile==CaelumWeatherRules.PROFILE_LIMBO)Outside.Evaluate(Profile,day,tick,Seed);
            else Outside.EvaluateRegion(Region,day,tick,Seed);
            Local.ApplyShelter(Outside,Shelter,Profile);CachedMinute=minute;
        }
        return Local.Available?CaelumFoodRules.EnvironmentRate(Local.AirTemperatureC+HeatDelta,
            Clamp(Local.RelativeHumidityPercent+HumidityDelta,0.0,100.0)):0;
    }
    void Advance(CaelumFoodLots lots,double seconds)
    {
        if(seconds<=0)return;
        if(!Ready || lots==null || lots.Lots.Size()==0){CivilSeconds+=seconds;return;}
        double minimum=CaelumFoodData.MAX_CONTAMINATION;
        for(int i=0;i<lots.Lots.Size();i++)minimum=Min(minimum,lots.Contamination(i));
        double needed=CaelumFoodData.MAX_CONTAMINATION-minimum,added=0,start=CivilSeconds,end=start+seconds;
        double factor=CaelumFoodData.MAX_CONTAMINATION/(CaelumFoodData.FreshHours(lots.Kind)*3600);
        // El Limbo ya tiene clima constante en la autoridad climática: no
        // recorrer miles de minutos idénticos al volver tras una ausencia.
        if(Profile==CaelumWeatherRules.PROFILE_LIMBO)
        {lots.Exposure+=Min(needed,factor*seconds*Rate(start));CivilSeconds=end;return;}
        // Se omite todo el intervalo restante cuando incluso el lote más fresco
        // llegó a 100; no hay bucles por tic ni por unidad nativa.
        while(start<end && added<needed)
        {
            double boundary=(Floor(start/60)+1)*60;
            double step=Min(end-start,boundary-start);
            added+=factor*step*Rate(start);start+=step;
        }
        lots.Exposure+=Min(needed,added);CivilSeconds=end;
    }
}

// Un nodo por pila real, incluso guardada. No explora actores ni inventarios.
class CaelumFoodClock : Thinker
{
    Inventory Item;
    CaelumFoodClimate Climate;
    bool Ready;
    double Stamp;
    transient int NextUpdate;
    static CaelumFoodClock Get(Inventory item)
    {
        if(!CaelumFoodInventory.IsFood(item))return null;
        let food=CaelumConsumableItem(item);let material=CaelumMaterialPickup(item);
        let clock=food!=null?food.FoodClock:material.FoodClock;
        if(clock==null)
        {
            clock=new('CaelumFoodClock');clock.Item=item;
            if(food!=null)food.FoodClock=clock;else material.FoodClock=clock;
        }
        return clock;
    }
    Actor Location()
    {
        Actor body=Item.Owner!=null?Item.Owner:Actor(Item);
        let table=CaelumDiningTable(body);if(table!=null)body=table.ContentLocation();
        let chest=CaelumStashChest(body);
        if(chest!=null && chest.Cargo!=null && chest.Cargo.Owner!=null)body=chest.Cargo.Owner;
        return body;
    }
    void Advance()
    {
        if(Item==null || Item.bDestroyed)return;
        let body=Location();let user=CaelumPlayer(body);let world=CaelumThermalWorld.Get();
        let clock=user!=null?CaelumWorldClock.Get(user):world!=null?world.ReferenceClock:null;
        let calendar=user!=null?CaelumCalendarState.Get(user):world!=null?world.ReferenceCalendar:null;
        let weather=user!=null?CaelumWeatherState.Get(user):world!=null?world.ReferenceWeather:null;
        if(clock==null)return;
        double now=CaelumThermalRuntime.Stamp(clock);let lots=CaelumFoodInventory.Prepare(Item);
        let remote=CaelumHouseStorageEntry.Remote(body);
        if(remote!=null)
        {let store=CaelumHouseStorage.Get();if(store!=null)now=remote.SourceNow(CaelumPlayer(store.Owner));}
        if(Climate==null)Climate=new('CaelumFoodClimate');
        bool commercial=Item.Owner is 'CaelumCityMerchant';
        if(Ready && now>Stamp && !commercial)Climate.Advance(lots,now-Stamp);
        Stamp=now;Ready=true;
        // No inicializar con datos climáticos inventados cuando no hay muestra.
        if(remote==null)Climate.Capture(body,clock,calendar,weather);
        NextUpdate=level.maptime+TICRATE;
    }
    override void Tick()
    {
        if(Item==null || Item.bDestroyed){Destroy();return;}
        if(NextUpdate==0)
        {
            let world=CaelumFoodWorld(StaticEventHandler.Find('CaelumFoodWorld'));
            NextUpdate=level.maptime+1+(world!=null?world.NextPhase++%TICRATE:0);
        }
        if(level.maptime>=NextUpdate)CaelumFoodInventory.Reconcile(Item);
    }
}

class CaelumFoodWorld : StaticEventHandler
{
    int NextPhase;
    override void WorldThingSpawned(WorldEvent e)
    {CaelumFoodClock.Get(Inventory(e.Thing));CaelumContaminationStack.Clock(Inventory(e.Thing));}
    override void WorldLoaded(WorldEvent e)
    {
        NextPhase=0;
        // Censo tipado sólo al cargar para migrar pilas antiguas, incluyendo
        // inventarios guardados. Las altas posteriores usan el evento nativo.
        CaelumConsumableItem food;
        let ground=ThinkerIterator.Create('CaelumConsumableItem');
        while((food=CaelumConsumableItem(ground.Next()))!=null){CaelumFoodClock.Get(food);CaelumContaminationStack.Clock(food);}
        let ingredients=ThinkerIterator.Create('CaelumMaterialPickup');Inventory material;
        while((material=Inventory(ingredients.Next()))!=null){CaelumFoodClock.Get(material);CaelumContaminationStack.Clock(material);}
    }
}
