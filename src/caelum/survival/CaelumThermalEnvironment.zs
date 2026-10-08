class CaelumThermalShelter : Object play
{
    static bool Roof(Actor body)
    {
        if(CaelumThermalWorld.UnderRoof(body))return true;
        FLineTraceData hit;
        double z=body.Pos.Z+body.Height*0.75;
        bool found=body.LineTrace(0,65536,-90,TRF_THRUACTORS|TRF_ABSPOSITION|TRF_NOSKY,
            z,body.Pos.X,body.Pos.Y,hit);
        return found && hit.HitType!=FLineTraceData.TRACE_HasHitSky;
    }

    static bool SameWall(Line a,Line b)
    {
        if(a==b)return true;
        vector2 da=a.delta,db=b.delta,offset=b.v1.p-a.v1.p;
        double length=Max(0.001,da.Length());
        return Abs(da.X*db.Y-da.Y*db.X)<=0.001*length*Max(0.001,db.Length())
            && Abs(da.X*offset.Y-da.Y*offset.X)<=0.01*length;
    }

    static bool Connected(Line a,Line b)
    {
        return (a.v1.p-b.v1.p).Length()<0.01 || (a.v1.p-b.v2.p).Length()<0.01
            || (a.v2.p-b.v1.p).Length()<0.01 || (a.v2.p-b.v2.p).Length()<0.01;
    }

    static bool WindBlocked(Actor body)
    {
        // UnderRoof reconoce el volumen geométrico del rancho de tres paredes;
        // sus colisiones son actores y por eso no aparecen como HitLine.
        if(CaelumThermalWorld.UnderRoof(body))return true;
        Line walls[8];int count=0;
        double z=body.Pos.Z+body.Height*0.5;
        for(int direction=0;direction<CaelumThermalData.SHELTER_RAYS;direction++)
        {
            FLineTraceData hit;
            if(!body.LineTrace(direction*360.0/CaelumThermalData.SHELTER_RAYS,
                CaelumThermalData.SHELTER_RANGE_MU,0,TRF_THRUACTORS|TRF_ABSPOSITION|TRF_NOSKY,
                z,body.Pos.X,body.Pos.Y,hit) || hit.HitLine==null)continue;
            bool duplicate=false;
            for(int i=0;i<count;i++)if(SameWall(walls[i],hit.HitLine)){duplicate=true;break;}
            if(!duplicate)walls[count++]=hit.HitLine;
        }
        // Tres segmentos arbitrarios no bastan: deben formar un recinto local
        // conectado. Se cuentan planos distintos, no subdivisiones de una pared.
        for(int first=0;first<count;first++)
        {
            bool reached[8];reached[first]=true;int linked=1;
            for(int pass=0;pass<count;pass++)for(int i=0;i<count;i++)
                if(!reached[i])for(int j=0;j<count;j++)
                    if(reached[j] && Connected(walls[i],walls[j]))
                    {reached[i]=true;linked++;break;}
            if(linked>=3)return true;
        }
        return false;
    }
}

// Caché de referencia climática compartida; nunca posee el estado de un cuerpo.
class CaelumThermalWorld : StaticEventHandler
{
    CaelumWeatherState ReferenceWeather;
    CaelumWorldClock ReferenceClock;
    CaelumCalendarState ReferenceCalendar;
    CaelumWeatherState SampleSource;
    CaelumWeatherSample Samples[5];
    int SampleDate,SampleMinute,SampleSeed,SampleProfile,SampleRegion;
    int NextPhase;
    Array<CaelumThermalFireSource> FireSources;
    Array<CaelumVehicleRanch> Ranches;
    int FireSampleTic;
    override void WorldLoaded(WorldEvent e)
    {
        ReferenceWeather=null;ReferenceClock=null;ReferenceCalendar=null;NextPhase=0;FireSources.Clear();Ranches.Clear();FireSampleTic=-TICRATE;
        SampleSource=null;for(int i=0;i<5;i++)Samples[i]=null;
        // Los mapas descargados no simulan fisiología. Al volver de un hub,
        // conservar el estado personal y reiniciar sólo los relojes locales.
        if(e.IsReopen && !e.IsSaveGame)
        {
            let actors=ThinkerIterator.Create("CaelumCombatActor");CaelumCombatActor body;
            while((body=CaelumCombatActor(actors.Next()))!=null)
                if(body.ThermalState!=null)
                {
                    body.ThermalState.RuntimeReady=false;body.ThermalState.SourceMap="";
                    body.ThermalState.PendingActivityJoules=0;body.ThermalState.PropelledVelocity=(0,0);
                }
        }
    }
    CaelumWeatherSample LocalSample(CaelumWeatherState weather,int shelter)
    {
        if(SampleSource!=weather || SampleDate!=weather.SampleDate || SampleMinute!=weather.SampleMinute
            || SampleSeed!=weather.Seed || SampleProfile!=weather.Profile || SampleRegion!=weather.Region)
        {
            SampleSource=weather;SampleDate=weather.SampleDate;SampleMinute=weather.SampleMinute;
            SampleSeed=weather.Seed;SampleProfile=weather.Profile;SampleRegion=weather.Region;
            for(int i=0;i<5;i++)
            {
                if(Samples[i]==null)Samples[i]=new("CaelumWeatherSample");
                Samples[i].ApplyShelter(weather.Outside,i,weather.Profile);
            }
        }
        return Samples[Clamp(shelter,0,4)];
    }
    override void WorldTick()
    {
        ReferenceWeather=null;ReferenceClock=null;ReferenceCalendar=null;
        if(level.maptime-FireSampleTic>=TICRATE || FireSampleTic>level.maptime)
        {
            FireSources.Clear();FireSampleTic=level.maptime;
            Ranches.Clear();let roofs=ThinkerIterator.Create("CaelumVehicleRanch");CaelumVehicleRanch ranch;
            while((ranch=CaelumVehicleRanch(roofs.Next()))!=null)Ranches.Push(ranch);
            let fires=ThinkerIterator.Create("CaelumThermalFireSource");
            CaelumThermalFireSource source;
            while((source=CaelumThermalFireSource(fires.Next()))!=null)if(source.Watts()>0)FireSources.Push(source);
        }
        for(int i=0;i<MAXPLAYERS;i++)
        {
            if(!playeringame[i])continue;
            let user=CaelumPlayer(players[i].mo);
            if(!CaelumPlayerAuthority.CanMutate(user) || !user.CharacterCreationComplete || user.CreationWizardOpen)continue;
            ReferenceWeather=CaelumWeatherState.Get(user);
            ReferenceClock=CaelumWorldClock.Get(user);
            ReferenceCalendar=CaelumCalendarState.Get(user);
            if(ReferenceWeather!=null)return;
        }
    }
    static bool UnderRoof(Actor body)
    {
        let world=Get();
        if(world==null)return CaelumVehicleWorld.UnderRoof(body);
        for(int i=0;i<world.Ranches.Size();i++)if(world.Ranches[i]!=null && world.Ranches[i].Covers(body))return true;
        return false;
    }
    static CaelumThermalWorld Get()
    {return CaelumThermalWorld(StaticEventHandler.Find("CaelumThermalWorld"));}
}

class CaelumThermalEnvironment : Object play
{
    // Propiedades UDMF del volumen/modelo: user_ca_water_temperature_defined=1
    // y user_ca_water_temperature_c. Permiten expresar también cero grados.
    static double WaterTemperature(Sector volume,double fallback)
    {
        return volume!=null && volume.GetUDMFInt('user_ca_water_temperature_defined')!=0
            ? volume.GetUDMFFloat('user_ca_water_temperature_c') : fallback;
    }

    static double SampleWater(Actor body,CaelumThermalState thermal,double fallback)
    {
        thermal.WaterC=fallback;thermal.WaterRowMask=0;
        if(body.CurSector==null)return 0;
        Sector sector=body.CurSector;
        let height=sector.GetHeightSec();
        if(height==null && sector.Get3DFloorCount()==0 && body.WaterLevel<=0)return 0;
        int count=CaelumThermalData.SURFACE_SAMPLES,wetRows=0;
        double totalTemperature=0;
        for(int row=0;row<count;row++)
        {
            double z=body.Pos.Z+body.Height*(row+0.5)/count;
            bool wet=height!=null && z<=height.floorplane.ZatPoint(body.Pos.XY);
            double temperature=wet ? WaterTemperature(height,fallback) : fallback;
            bool described=height!=null;
            for(int i=0;i<sector.Get3DFloorCount();i++)
            {
                let volume=sector.Get3DFloor(i);
                if(volume==null || (volume.flags&(F3DFloor.FF_EXISTS|F3DFloor.FF_SWIMMABLE))
                    !=(F3DFloor.FF_EXISTS|F3DFloor.FF_SWIMMABLE))continue;
                described=true;
                if(z>=volume.bottom.ZatPoint(body.Pos.XY) && z<=volume.top.ZatPoint(body.Pos.XY))
                {wet=true;temperature=WaterTemperature(volume.model,fallback);}
            }
            // Sólo una inmersión sin geometría de volumen usa el respaldo total.
            if(!described && body.WaterLevel>=3)wet=true;
            thermal.WaterRowC[row]=temperature;
            if(wet){thermal.WaterRowMask|=1<<row;wetRows++;totalTemperature+=temperature;}
        }
        if(wetRows>0)thermal.WaterC=totalTemperature/wetRows;
        return double(wetRows)/count;
    }

    static bool Sample(Actor body,CaelumThermalState thermal,double localMotionMps=0)
    {
        CaelumThermalCoefficients.Get(thermal).EnvironmentSamples++;
        let user=CaelumPlayer(body);
        let world=CaelumThermalWorld.Get();
        let weather=user!=null ? CaelumWeatherState.Get(user) : world!=null ? world.ReferenceWeather : null;
        if(weather==null || weather.Outside==null || !weather.Outside.Available)
        {thermal.Available=false;return false;}
        thermal.Roof=CaelumThermalShelter.Roof(body);
        thermal.WindSheltered=CaelumThermalShelter.WindBlocked(body);
        int shelter=CaelumWeatherRules.OPEN;
        if(weather.Profile==CaelumWeatherRules.PROFILE_LIMBO)shelter=CaelumWeatherRules.LIMBO;
        else if(thermal.Roof && weather.Profile>=2 && weather.Profile<=4)shelter=CaelumWeatherRules.UNDERGROUND;
        else if(thermal.Roof)shelter=thermal.WindSheltered ? CaelumWeatherRules.INDOOR : CaelumWeatherRules.CANOPY;
        CaelumWeatherSample local;
        if(world!=null)local=world.LocalSample(weather,shelter);
        else {local=new("CaelumWeatherSample");local.ApplyShelter(weather.Outside,shelter,weather.Profile);}
        thermal.Available=local.Available;thermal.AirC=local.AirTemperatureC;
        thermal.ClimateC=local.AirTemperatureC;thermal.Humidity=local.RelativeHumidityPercent;
        thermal.RainMmHour=thermal.Roof ? 0 : local.PrecipitationMmPerHour;
        double exterior=thermal.WindSheltered ? 0 : local.WindSpeedKmh/3.6;
        // Suma cuadrática de magnitudes: aproximación local sin rumbo corporal.
        thermal.WindMps=Sqrt(exterior*exterior+localMotionMps*localMotionMps);
        double immersed=SampleWater(body,thermal,local.GroundTemperatureC);
        CaelumThermalBody.SampleCoverage(body,thermal,immersed,thermal.WaterRowMask);
        thermal.LastEnvironmentTic=level.maptime;thermal.SourceMap=level.MapName;
        return true;
    }
}
