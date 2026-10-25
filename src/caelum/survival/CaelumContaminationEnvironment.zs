// #502: la categoría pertenece al lugar; no se buscan emisores por tic.
class CaelumContaminationWorld : StaticEventHandler
{
    Array<bool> Industrial;

    void Observe(Actor actor)
    {
        if(!(actor is 'CaelumForgeStation') && !(actor is 'CaelumSawmillStation')
            && !(actor is 'CaelumAlchemyStation'))return;
        let sector=actor.CurSector;if(sector==null)return;
        int index=sector.Index();
        if(index<0)return;
        if(Industrial.Size()<level.Sectors.Size())Industrial.Resize(level.Sectors.Size());
        Industrial[index]=true;
    }
    override void WorldLoaded(WorldEvent e)
    {
        Industrial.Clear();Industrial.Resize(level.Sectors.Size());
        // Censo tipado único al cargar: reconstruye sectores de talleres ya existentes.
        let stations=ThinkerIterator.Create('CaelumCraftingStation');Actor station;
        while((station=Actor(stations.Next()))!=null)Observe(station);
    }
    override void WorldThingSpawned(WorldEvent e){Observe(e.Thing);}
    static CaelumContaminationWorld Get()
    {return CaelumContaminationWorld(StaticEventHandler.Find('CaelumContaminationWorld'));}
}

class CaelumContaminationEnvironment : Object play
{
    static double ReferenceAt(Actor body)
    {
        if(body==null || body.CurSector==null)return -1;
        let sector=body.CurSector;
        int declared=sector.GetUDMFInt('user_ca_contamination_class');
        if(declared>0 && declared<=CaelumContaminationData.ENV_SEWER)
            return CaelumContaminationData.Reference(declared);
        let world=CaelumContaminationWorld.Get();int index=sector.Index();
        if(world!=null && index>=0 && index<world.Industrial.Size() && world.Industrial[index])
            return CaelumContaminationData.INDUSTRIAL_REFERENCE;
        if(CaelumCampLandData.Garden(level.MapName,TexMan.GetName(sector.GetTexture(Sector.floor)))
            || CaelumCampLandData.Countryside(level.MapName,body.Pos))return CaelumContaminationData.NATURAL_REFERENCE;
        return CaelumContaminationData.Reference(CaelumContaminationData.MapClass(level.MapName));
    }
}

// El pronóstico de espera conserva lugar/abrigo y evalúa su calendario futuro.
// No consulta ni modifica el clima o equipo vivos durante la simulación.
class CaelumContaminationWaitWeather : Object play
{
    int Profile,Region,Seed,Shelter,SampleDay,SampleMinute;
    double Reference,Value;
    bool DynamicClimate;
    CaelumWeatherSample Outside,Local;
    void Capture(CaelumPlayer user)
    {
        Reference=CaelumContaminationEnvironment.ReferenceAt(user);SampleDay=-1;SampleMinute=-1;
        let weather=CaelumWeatherState.Get(user);
        if(weather==null || weather.Current==null || !weather.Current.Available){Reference=-1;return;}
        Profile=weather.Profile;Region=weather.Region;Seed=weather.Seed;
        // Usa el mismo abrigo geométrico que el contacto térmico, no la muestra
        // anterior del diario, que puede pertenecer al lugar previo al movimiento.
        Shelter=CaelumThermalEnvironment.ClimateShelter(Profile,CaelumThermalShelter.Roof(user),CaelumThermalShelter.WindBlocked(user));
        double heat,humidity,wind,direction;
        [heat,humidity,wind,direction]=CaelumSealClimate.Delta(user,0,0);
        DynamicClimate=heat!=0 || humidity!=0;
        Outside=new('CaelumWeatherSample');Local=new('CaelumWeatherSample');
    }
    double Sample(int day,int tics)
    {
        if(Reference<0 || Outside==null)return -1;
        int minute=tics/(CaelumWorldClock.TicsPerHour()/60);
        if(SampleDay!=day || SampleMinute!=minute)
        {
            if(Profile==CaelumWeatherRules.PROFILE_LIMBO)Outside.Evaluate(Profile,day,minute*(CaelumWorldClock.TicsPerHour()/60),Seed);
            else Outside.EvaluateRegion(Region,day,minute*(CaelumWorldClock.TicsPerHour()/60),Seed);
            Local.ApplyShelter(Outside,Shelter,Profile);
            Value=Local.Available ? CaelumContaminationRules.Environment(Reference,Local.AirTemperatureC,Local.RelativeHumidityPercent) : -1;
            SampleDay=day;SampleMinute=minute;
        }
        return Value;
    }
}
