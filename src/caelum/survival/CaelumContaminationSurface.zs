// #502: registro disperso persistente; sólo se consultan las zonas tocadas.
class CaelumContaminationTile : Object play
{
    int Kind,Surface,Side,X,Y,Next;
    double Concentration,Stamp,Reference;
    int Profile,Region,Seed,Shelter;
    bool Covered;
    transient bool WeatherReady;
    transient int WeatherDay,WeatherMinute;
    transient double Ambient,Rain;

    CaelumContaminationTile Copy()
    {
        let c=new('CaelumContaminationTile');
        c.Kind=Kind;c.Surface=Surface;c.Side=Side;c.X=X;c.Y=Y;c.Next=Next;
        c.Concentration=Concentration;c.Stamp=Stamp;c.Reference=Reference;
        c.Profile=Profile;c.Region=Region;c.Seed=Seed;c.Shelter=Shelter;c.Covered=Covered;
        return c;
    }
    static double ExposureTime(double start,double end,double rate,double wash)
    {
        // Integral de C/(rate-wash*C). La serie evita la cancelación del
        // logaritmo cuando empieza/termina una llovizna casi nula. Con las
        // tasas aprobadas wash*C/rate <=1/9; doce términos acotan el error.
        double first=1,last=1,total=0;
        for(int n=0;n<12;n++)
        {total+=(end*end*last-start*start*first)/(n+2);first*=wash*start/ rate;last*=wash*end/rate;}
        return total/rate;
    }
    // Exposición y lavado simultáneos. La lluvia no borra contactos guardados
    // ni se vuelve a cobrar al leer dos veces la misma fecha.
    static double Evolve(double value,double ambient,double rain,double seconds)
    {
        if(seconds<=0)return value;
        double wash=CaelumContaminationRules.RainReduction(rain)/CaelumContaminationData.RAIN_WASH_SECONDS;
        if(wash<=0)return CaelumContaminationRules.AfterContact(value,ambient,1,seconds);
        ambient=Max(0.0,ambient);
        double rate=CaelumContaminationData.CONTACT_DEGREES_M2_SECOND*ambient;
        if(value>=ambient)
        {
            double step=Min(seconds,(value-ambient)/wash);value-=step*wash;seconds-=step;
            if(ambient>=1 || rate>=wash)return value;
            return Max(0.0,value+(rate-wash)*seconds);
        }
        if(value<1)
        {
            double speed=rate-wash;
            if(speed<=0)return Max(0.0,value+speed*seconds);
            double limit=Min(1.0,ambient),step=Min(seconds,(limit-value)/speed);
            value+=speed*step;seconds-=step;
        }
        if(seconds<=0 || value>=ambient)return value;
        // Para C>=1: dC/dt=rate/C-wash. El lavado aprobado es menor
        // que la exposición en C=ambient; la raíz queda entre C y ambient.
        if(seconds>=ExposureTime(value,ambient,rate,wash))return ambient;
        double lo=value,hi=ambient;
        for(int i=0;i<36;i++)
        {
            double mid=(lo+hi)*0.5;
            double elapsed=ExposureTime(value,mid,rate,wash);
            if(elapsed<seconds)lo=mid;else hi=mid;
        }
        return (lo+hi)*0.5;
    }
    void Sync(double now,double civilOffset,CaelumWeatherSample outside,CaelumWeatherSample local)
    {
        if(now<=Stamp)return;
        if(Reference<0 || !CaelumWeatherRules.IsProfile(Profile)){Stamp=now;return;}
        // Limbo no cambia su clima; cerrar años allí cuesta lo mismo que un tic.
        if(Profile==CaelumWeatherRules.PROFILE_LIMBO)
        {
            local.Evaluate(Profile,CaelumCalendarRules.DaysBeforeYear(CaelumCalendarRules.CAMPAIGN_START_YEAR),0,Seed);
            Concentration=Evolve(Concentration,CaelumContaminationRules.Ambient(Reference,
                local.AirTemperatureC,local.RelativeHumidityPercent,0,!Covered),0,now-Stamp);
            Stamp=now;return;
        }
        // Mismo muestreo por minuto civil que el clima normal. El intervalo
        // pendiente se evalúa al volver, sin recorrer actores ni todas las zonas.
        while(Stamp<now)
        {
            double civil=Stamp+civilOffset;
            int day=int(Floor(civil/86400.0));
            int minute=int(Floor((civil-double(day)*86400.0)/60.0));
            double end=Min(now,(double(day)*86400.0+(minute+1)*60.0)-civilOffset);
            if(end<=Stamp)end=now;
            if(!WeatherReady || WeatherDay!=day || WeatherMinute!=minute)
            {
                outside.EvaluateRegion(Region,day,minute*(CaelumWorldClock.TicsPerHour()/60),Seed);
                local.ApplyShelter(outside,Shelter,Profile);
                Rain=Covered?0:local.PrecipitationMmPerHour;
                Ambient=local.Available?CaelumContaminationRules.Ambient(Reference,
                    local.AirTemperatureC,local.RelativeHumidityPercent,Rain,!Covered):-1;
                WeatherDay=day;WeatherMinute=minute;WeatherReady=true;
            }
            if(Ambient>=0)Concentration=Evolve(Concentration,Ambient,Rain,end-Stamp);
            Stamp=end;
        }
    }
    void Contact(Actor body,double area,double seconds)
    {
        if(body==null || CaelumContaminationStorage.IsShielded(body))return;
        if(CaelumContaminationStack.Eligible(Inventory(body)))
        {
            let source=new('CaelumContaminationState');source.Ensure();source.Concentration=Concentration;
            CaelumContaminationCombat.Transfer(CaelumContaminationCombat.ActorPoint(body),
                CaelumContaminationCombat.ModelPoint(source),area,seconds);
            Concentration=source.Concentration;return;
        }
        double other=CaelumContaminationStorage.Value(body);
        if(Concentration>other)CaelumContaminationStorage.Set(body,CaelumContaminationRules.AfterContact(
            other,Concentration,area,seconds,CaelumContaminationStorage.Dose(body)));
        else Concentration=CaelumContaminationRules.AfterContact(Concentration,other,area,seconds);
    }
}

// La espera usa copias de las dos zonas de contacto. Ni su preparación ni el
// pronóstico pueden adelantar la contaminación del mapa vivo.
class CaelumContaminationSurfaceForecast : Object play
{
    CaelumContaminationMap Sheet;
    CaelumContaminationTile Floor,Wall;
    double Stamp;
    void Capture(CaelumPlayer user,CaelumThermalState thermal)
    {
        Sheet=new('CaelumContaminationMap');Stamp=CaelumContaminationSurfaces.Now(user);
        let ledger=CaelumContaminationSurfaces.Get(false);CaelumContaminationMap existing;
        if(ledger!=null)for(int i=0;i<ledger.Maps.Size();i++)
            if(ledger.Maps[i].Map==level.MapName){existing=ledger.Maps[i];break;}
        let clock=CaelumWorldClock.Get(user);let calendar=CaelumCalendarState.Get(user);
        Sheet.Epoch=existing!=null?existing.Epoch:Stamp;
        Sheet.CivilOffset=existing!=null?existing.CivilOffset:
            double(calendar.DateSerial(clock))*86400+double(calendar.CivilDayTics(clock))*3600/CaelumWorldClock.TicsPerHour()-Stamp;
        Floor=CaelumContaminationSurfaceContact.FloorTile(user,existing,false);
        Wall=CaelumContaminationSurfaceContact.WallTile(user,existing,false);
        Floor=Floor!=null?Floor.Copy():CaelumContaminationSurfaceContact.FloorTile(user,Sheet,true);
        Wall=Wall!=null?Wall.Copy():CaelumContaminationSurfaceContact.WallTile(user,Sheet,true);
        if(Floor!=null){if(Floor.Profile==0)CaelumContaminationSurfaceContact.Configure(user,thermal,Floor);Sheet.Sync(Floor,Stamp);CaelumContaminationSurfaceContact.Configure(user,thermal,Floor,true);}
        if(Wall!=null){if(Wall.Profile==0)CaelumContaminationSurfaceContact.Configure(user,thermal,Wall);Sheet.Sync(Wall,Stamp);CaelumContaminationSurfaceContact.Configure(user,thermal,Wall,true);}
    }
    void Contact(CaelumContaminationTile tile,CaelumContaminationExposure exposure,CaelumFoodIllness illness,int slot,double area,double seconds,double ambient,double rain)
    {
        if(tile==null)return;
        Sheet.SyncContact(tile,Stamp,seconds,ambient,tile.Covered?0:rain);
        int index=exposure.Armor[slot]>=0?exposure.Armor[slot]:exposure.Clothes[slot];
        double value=index>=0?exposure.Items[index].Concentration:illness.Contamination;
        if(value>tile.Concentration)
            tile.Concentration=CaelumContaminationRules.AfterContact(tile.Concentration,value,area,seconds);
        else value=CaelumContaminationRules.AfterContact(value,tile.Concentration,area,seconds,
            index>=0?1:CaelumContaminationRules.BodyDoseFactor(exposure.BodyKg));
        if(index>=0)exposure.Items[index].Concentration=value;else illness.Contamination=value;
    }
    void Advance(CaelumContaminationExposure exposure,CaelumFoodIllness illness,double seconds,double ambient,double rain)
    {
        if(exposure==null || illness==null)return;Stamp+=seconds;
        Contact(Floor,exposure,illness,CaelumConstants.ARMOR_SLOT_FEET,CaelumContaminationData.FOOT_CONTACT_M2,seconds,ambient,rain);
        Contact(Wall,exposure,illness,CaelumConstants.ARMOR_SLOT_BODY,CaelumContaminationData.BODY_CONTACT_M2,seconds,ambient,rain);
    }
}

class CaelumContaminationMap : Object play
{
    String Map;
    int Revision;
    double Epoch,CivilOffset;
    Array<CaelumContaminationTile> Tiles;
    Array<int> Buckets;
    transient CaelumWeatherSample Outside,Local;
    // Tamaño del índice, no un límite de población ni de estado guardado.
    const BUCKET_COUNT=1024;
    static int Hash(int kind,int surface,int side,int x,int y)
    {return ((kind*31+surface*131+side*17+x*37+y*73)&0x7fffffff)%BUCKET_COUNT;}
    void Index()
    {
        if(Buckets.Size()==BUCKET_COUNT)return;
        Buckets.Resize(BUCKET_COUNT);for(int i=0;i<BUCKET_COUNT;i++)Buckets[i]=-1;
        for(int i=0;i<Tiles.Size();i++)
        {let t=Tiles[i];int h=Hash(t.Kind,t.Surface,t.Side,t.X,t.Y);t.Next=Buckets[h];Buckets[h]=i;}
    }
    CaelumContaminationTile Find(int kind,int surface,int side,int x,int y,bool create=false)
    {
        Index();int h=Hash(kind,surface,side,x,y);
        for(int i=Buckets[h];i>=0;i=Tiles[i].Next)
        {let t=Tiles[i];if(t.Kind==kind && t.Surface==surface && t.Side==side && t.X==x && t.Y==y)return t;}
        if(!create)return null;
        let t=new('CaelumContaminationTile');t.Kind=kind;t.Surface=surface;t.Side=side;t.X=x;t.Y=y;
        t.Stamp=Epoch;t.Reference=-1;t.Next=Buckets[h];Buckets[h]=Tiles.Size();Tiles.Push(t);return t;
    }
    void Sync(CaelumContaminationTile tile,double now)
    {
        if(Outside==null)Outside=new('CaelumWeatherSample');
        if(Local==null)Local=new('CaelumWeatherSample');
        tile.Sync(now,CivilOffset,Outside,Local);
    }
    void SyncContact(CaelumContaminationTile tile,double now,double seconds,double ambient,double rain)
    {
        Sync(tile,now-Max(0.0,seconds));
        if(now<=tile.Stamp)return;
        // El intervalo presente usa el microclima real (incluidos sellos).
        // Sólo el tiempo ausente se reconstruye desde el clima regional guardado.
        if(ambient>=0)tile.Concentration=CaelumContaminationTile.Evolve(tile.Concentration,ambient,rain,now-tile.Stamp);
        tile.Stamp=now;
    }
}

class CaelumContaminationSurfaces : Inventory
{
    int Revision;
    Array<CaelumContaminationMap> Maps;
    transient CaelumContaminationMap Current;
    static CaelumContaminationSurfaces Get(bool create=false)
    {
        // El primer jugador activo posee el estado compartido, como el padrón
        // doméstico; no se crea una copia por usuario de la misma superficie.
        for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i] && players[i].mo!=null)
        {
            let user=CaelumPlayer(players[i].mo);if(!CaelumPlayerAuthority.CanMutate(user))return null;
            let ledger=CaelumContaminationSurfaces(user.FindInventory('CaelumContaminationSurfaces'));
            if(ledger==null && create)ledger=CaelumContaminationSurfaces(user.GiveInventoryType('CaelumContaminationSurfaces'));
            return ledger;
        }
        return null;
    }
    static double Now(CaelumPlayer user)
    {return CaelumConnectedWaterMap.ClockStamp(CaelumWorldClock.Get(user));}
    CaelumContaminationMap MapState(CaelumPlayer user)
    {
        if(Current!=null && Current.Map==level.MapName)return Current;
        for(int i=0;i<Maps.Size();i++)if(Maps[i].Map==level.MapName){Current=Maps[i];return Current;}
        let clock=CaelumWorldClock.Get(user);let calendar=CaelumCalendarState.Get(user);
        if(clock==null || calendar==null || calendar.DateSerial(clock)<0)return null;
        Current=new('CaelumContaminationMap');Current.Map=level.MapName;Current.Epoch=Now(user);
        Current.CivilOffset=double(calendar.DateSerial(clock))*86400.0
            +double(calendar.CivilDayTics(clock))*3600.0/CaelumWorldClock.TicsPerHour()-Current.Epoch;
        Current.Revision=CaelumContaminationData.SURFACE_REVISION;Revision=Current.Revision;
        Maps.Push(Current);return Current;
    }
    static CaelumContaminationMap CurrentMap(CaelumPlayer user)
    {let ledger=Get(true);return ledger==null?null:ledger.MapState(user);}
    override Inventory CreateTossable(int amount){return null;}
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE}
    States {Spawn:TNT1 A -1;Stop;}
}

class CaelumContaminationSurfaceContact : Object play
{
    static int Cell(double coordinate)
    {return int(Floor(coordinate/(CaelumPhysicsUnits.MAP_UNITS_PER_METER*CaelumContaminationData.SURFACE_ZONE_METERS)));}
    static vector2 PlaneCoordinates(vector2 point,vector2 slope)
    {
        double grade=slope.Length();if(grade==0)return point;
        vector2 uphill=slope/grade;
        return ((point.X*uphill.X+point.Y*uphill.Y)*Sqrt(1+grade*grade),
            -point.X*uphill.Y+point.Y*uphill.X);
    }
    static bool Grounded(Actor user)
    {return user!=null && user.CurSector!=null && !user.bNoClip && !user.bNoGravity
        && user.Vel.Z<=0 && Abs(user.Pos.Z-user.FloorZ)<0.01;}
    static CaelumContaminationTile FloorTile(Actor user,CaelumContaminationMap sheet,bool create)
    {
        if(!Grounded(user) || sheet==null)return null;
        let support=CaelumThermalMotion.Support(user);
        let sector=support==null?user.FloorSector:support.model;
        if(sector==null)return null;
        double height=CaelumThermalMotion.SupportHeight(sector,support,user.Pos.XY);
        vector2 slope=(CaelumThermalMotion.SupportHeight(sector,support,user.Pos.XY+(1,0))-height,
            CaelumThermalMotion.SupportHeight(sector,support,user.Pos.XY+(0,1))-height);
        vector2 point=PlaneCoordinates(user.Pos.XY,slope);
        return sheet.Find(support==null?0:1,sector.Index(),0,Cell(point.X),Cell(point.Y),create);
    }
    static CaelumContaminationTile WallTile(Actor user,CaelumContaminationMap sheet,bool create)
    {
        if(user==null || user.bNoClip || sheet==null)return null;
        let lines=BlockLinesIterator.Create(user,user.Radius+0.01);
        Line nearest;vector2 point;double best=user.Radius+0.01;
        while(lines.Next())
        {
            let line=lines.CurLine;vector2 edge=line.delta;double length=edge.Length();if(length<=0)continue;
            vector2 offset=user.Pos.XY-line.v1.p;
            vector2 p=line.v1.p+edge*Clamp((offset.X*edge.X+offset.Y*edge.Y)/(length*length),0.0,1.0);
            double distance=(p-user.Pos.XY).Length();if(distance>best || distance<=0)continue;
            FLineTraceData hit;vector2 ray=p-user.Pos.XY;
            if(!user.LineTrace(VectorAngle(ray.X,ray.Y),distance+0.02,0,TRF_THRUACTORS|TRF_ABSPOSITION,
                user.Pos.Z+user.Height*0.5,user.Pos.X,user.Pos.Y,hit) || hit.HitLine!=line)continue;
            best=distance;nearest=line;point=p;
        }
        if(nearest==null)return null;
        return sheet.Find(2,nearest.Index(),level.PointOnLineSide(user.Pos.XY,nearest),
            Cell((point-nearest.v1.p).Length()),Cell(user.Pos.Z+user.Height*0.5),create);
    }
    static void Configure(CaelumPlayer user,CaelumThermalState thermal,CaelumContaminationTile tile,bool refresh=false)
    {
        if(tile==null || (tile.Profile!=0 && !refresh))return;
        let weather=CaelumWeatherState.Get(user);if(weather==null)return;
        double reference=CaelumContaminationEnvironment.ReferenceAt(user);
        int shelter=CaelumThermalEnvironment.ClimateShelter(weather.Profile,thermal.Roof,thermal.WindSheltered);
        if(tile.Reference!=reference || tile.Profile!=weather.Profile || tile.Region!=weather.Region
            || tile.Seed!=weather.Seed || tile.Covered!=thermal.Roof || tile.Shelter!=shelter)tile.WeatherReady=false;
        tile.Reference=reference;tile.Profile=weather.Profile;
        tile.Region=weather.Region;tile.Seed=weather.Seed;
        tile.Covered=thermal.Roof;
        tile.Shelter=shelter;
    }
    static void ConfigureObject(Actor body,CaelumContaminationTile tile)
    {
        let world=CaelumThermalWorld.Get();if(tile==null || world==null)return;
        let weather=world.ReferenceWeather;if(weather==null)return;
        bool roof=CaelumThermalShelter.Roof(body);
        int shelter=CaelumThermalEnvironment.ClimateShelter(weather.Profile,roof,CaelumThermalShelter.WindBlocked(body));
        double reference=CaelumContaminationEnvironment.ReferenceAt(body);
        if(tile.Reference!=reference || tile.Profile!=weather.Profile || tile.Region!=weather.Region
            || tile.Seed!=weather.Seed || tile.Covered!=roof || tile.Shelter!=shelter)tile.WeatherReady=false;
        tile.Reference=reference;tile.Profile=weather.Profile;tile.Region=weather.Region;
        tile.Seed=weather.Seed;tile.Covered=roof;tile.Shelter=shelter;
    }
    static void StackSupport(Inventory item,double seconds)
    {
        if(item==null || item.Owner!=null || item.bDestroyed || seconds<=0
            || !CaelumContaminationStack.Eligible(item) || CaelumContaminationStorage.IsShielded(item))return;
        let world=CaelumThermalWorld.Get();if(world==null || world.ReferenceClock==null)return;
        let user=CaelumPlayer(world.ReferenceClock.Owner);if(user==null)return;
        let sheet=CaelumContaminationSurfaces.CurrentMap(user);if(sheet==null)return;
        let tile=FloorTile(item,sheet,true);if(tile==null)return;
        double now=CaelumContaminationSurfaces.Now(user);
        if(tile.Profile==0)ConfigureObject(item,tile);sheet.Sync(tile,now);ConfigureObject(item,tile);
        double r=CaelumPhysicsUnits.Meters(item.Radius);
        double area=Min(CaelumStackSurfaceData.PI*r*r,CaelumStackSurfaceData.UnitArea(item)*item.Amount);
        tile.Contact(item,area,seconds);
    }
    static Actor Outer(CaelumPlayer user,int slot)
    {
        let armor=CaelumThermalBody.EquippedPiece(user,slot);if(armor!=null)return armor;
        let cloth=CaelumClothing.Equipped(user,slot);return cloth==null?Actor(user):Actor(cloth);
    }
    static void Step(CaelumPlayer user,CaelumThermalState thermal,double seconds)
    {
        if(user==null || !CaelumPlayerAuthority.CanMutate(user) || user.health<=0 || seconds<=0)return;
        let sheet=CaelumContaminationSurfaces.CurrentMap(user);if(sheet==null)return;
        let floor=FloorTile(user,sheet,true);let wall=WallTile(user,sheet,true);
        double now=CaelumContaminationSurfaces.Now(user);
        double reference=CaelumContaminationEnvironment.ReferenceAt(user);
        double rain=thermal.Roof?0:thermal.RainMmHour;
        double ambient=reference>=0?CaelumContaminationRules.Ambient(reference,thermal.AirC,thermal.Humidity,rain,!thermal.Roof):-1;
        if(floor!=null)
        {Configure(user,thermal,floor);sheet.SyncContact(floor,now,seconds,ambient,rain);Configure(user,thermal,floor,true);floor.Contact(Outer(user,CaelumConstants.ARMOR_SLOT_FEET),CaelumContaminationData.FOOT_CONTACT_M2,seconds);}
        if(wall!=null)
        {Configure(user,thermal,wall);sheet.SyncContact(wall,now,seconds,ambient,rain);Configure(user,thermal,wall,true);wall.Contact(Outer(user,CaelumConstants.ARMOR_SLOT_BODY),CaelumContaminationData.BODY_CONTACT_M2,seconds);}
    }
}
