class CA871ReferenceMap : Object play
{
    String Map;
    int Revision;
    double Epoch,CivilOffset;
    Array<CaelumContaminationTile> Tiles;
    Array<int> Buckets;
    transient CaelumWeatherSample Outside,Local;
    transient Array<CaelumContaminationTile> Pristine;
    transient int PristineTic;
    transient bool PristineReady;
    // Limite tecnico de resultados derivados por tic, no de zonas guardadas.
    const PRISTINE_CACHE_LIMIT=32;
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
        if(now<=tile.Stamp)return;
        bool freshTile=!tile.RockTouched && tile.Stamp==Epoch && tile.Concentration==0;
        if(freshTile)
        {
            if(!PristineReady || PristineTic!=level.time)
            {Pristine.Clear();PristineTic=level.time;PristineReady=true;}
            for(int i=0;i<Pristine.Size();i++)
            {
                let sample=Pristine[i];
                if(sample.RockTouched || sample.Stamp!=now || sample.Profile!=tile.Profile || sample.Region!=tile.Region
                    || sample.Seed!=tile.Seed || sample.Shelter!=tile.Shelter
                    || sample.EffectiveReference()!=tile.EffectiveReference() || sample.Covered!=tile.Covered)continue;
                // Copia de un resultado determinista desde el mismo origen
                // limpio; nunca comparte concentraciones vivas ni contactos.
                tile.Stamp=sample.Stamp;tile.Concentration=sample.Concentration;
                tile.WeatherReady=sample.WeatherReady;tile.WeatherDay=sample.WeatherDay;
                tile.WeatherMinute=sample.WeatherMinute;tile.Rain=sample.Rain;tile.Ambient=sample.Ambient;
                return;
            }
        }
        if(Outside==null)Outside=new('CaelumWeatherSample');
        if(Local==null)Local=new('CaelumWeatherSample');
        tile.Sync(now,CivilOffset,Outside,Local);
        if(freshTile)
        {
            let sample=tile.Copy();sample.WeatherReady=tile.WeatherReady;sample.WeatherDay=tile.WeatherDay;
            sample.WeatherMinute=tile.WeatherMinute;sample.Rain=tile.Rain;sample.Ambient=tile.Ambient;
            if(Pristine.Size()>=PRISTINE_CACHE_LIMIT)Pristine.Delete(0);
            Pristine.Push(sample);
        }
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
