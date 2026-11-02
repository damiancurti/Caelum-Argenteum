// Una parte geométrica de un volumen autoritativo; caché derivada, nunca calidad duplicada.
class CaelumTarotWaterPart : Object play
{
    Sector Model,Host;
    transient F3DFloor Floor;
    int Kind,Next;
}

class CaelumTarotWaterMap : Actor
{
    int Revision;
    Array<bool> Purified;
    transient bool GeometryReady;
    transient Array<int> Heads;
    transient Array<CaelumTarotWaterPart> Parts;
    int GeometrySectorCount;

    static clearscope CaelumTarotWaterMap Get()
    {
        let ticker=CaelumWorldClockTicker(StaticEventHandler.Find('CaelumWorldClockTicker'));
        return ticker!=null && ticker.TarotWaterMap!=null && !ticker.TarotWaterMap.bDestroyed?ticker.TarotWaterMap:null;
    }
    static void Initialize()
    {
        let ticker=CaelumWorldClockTicker(StaticEventHandler.Find('CaelumWorldClockTicker'));if(ticker==null)return;
        // Un único controlador tipado por mapa; reconstrucción por carga, no por consulta.
        let found=ThinkerIterator.Create('CaelumTarotWaterMap');
        ticker.TarotWaterMap=CaelumTarotWaterMap(found.Next());
    }
    static CaelumTarotWaterMap Ensure()
    {
        let existing=Get();if(existing!=null)return existing;
        let ticker=CaelumWorldClockTicker(StaticEventHandler.Find('CaelumWorldClockTicker'));if(ticker==null)return null;
        existing=CaelumTarotWaterMap(Actor.Spawn('CaelumTarotWaterMap',(0,0,0),NO_REPLACE));
        if(existing!=null){existing.Revision=CaelumMajorArcanaData.WATER_REVISION;ticker.TarotWaterMap=existing;}
        return existing;
    }
    static clearscope int Quality(Sector model,int quality)
    {
        let ledger=Get();int index=model!=null?model.Index():-1;
        return ledger!=null && index>=0 && index<ledger.Purified.Size() && ledger.Purified[index]
            && CaelumWaterQuality.Valid(quality)?quality&CaelumWaterQuality.SALT:quality;
    }
    void Part(Sector model,Sector host,int kind,F3DFloor floor=null)
    {
        if(model==null || host==null)return;
        let part=new('CaelumTarotWaterPart');part.Model=model;part.Host=host;part.Kind=kind;part.Floor=floor;
        int index=model.Index();part.Next=Heads[index];Heads[index]=Parts.Size();Parts.Push(part);
    }
    void Geometry()
    {
        if(GeometryReady)return;
        Heads.Clear();Parts.Clear();Heads.Resize(level.Sectors.Size());
        for(int i=0;i<Heads.Size();i++)Heads[i]=-1;
        // Necesario para comprobar el volumen ENTERO, incluidos huéspedes fuera del radio.
        // Se ejecuta una vez al primer pulso de agua tras cargar. Sólo sectores/volúmenes.
        GeometrySectorCount=level.Sectors.Size();
        for(int i=0;i<level.Sectors.Size();i++)
        {
            let host=level.Sectors[i];
            for(int j=0;j<host.Get3DFloorCount();j++)
            {
                let floor=host.Get3DFloor(j);
                if((floor.flags&(F3DFloor.FF_EXISTS|F3DFloor.FF_SWIMMABLE))==(F3DFloor.FF_EXISTS|F3DFloor.FF_SWIMMABLE))
                    Part(floor.model,host,0,floor);
            }
            let height=host.GetHeightSec();
            if(height!=null)Part(height,host,1);
            else if(host.MoreFlags&Sector.SECMF_UNDERWATERMASK)Part(host,host,2);
        }
        GeometryReady=true;
    }
    vector2 Heights(CaelumTarotWaterPart part,vector2 xy)
    {
        double bottom=part.Host.floorplane.ZatPoint(xy),top=part.Host.ceilingplane.ZatPoint(xy);
        if(part.Kind==0){bottom=Max(bottom,part.Floor.bottom.ZatPoint(xy));top=Min(top,part.Floor.top.ZatPoint(xy));}
        else if(part.Kind==1)top=Min(top,part.Model.floorplane.ZatPoint(xy));
        return (bottom,top);
    }
    bool Contained(Sector model,CaelumTarotContamination pulse)
    {
        int index=model.Index();if(index<0 || index>=Heads.Size() || Heads[index]<0)return false;
        bool volume=false;
        for(int row=Heads[index];row>=0;row=Parts[row].Next)
        {
            let part=Parts[row];
            for(int edge=0;edge<part.Host.lines.Size();edge++)for(int end=0;end<2;end++)
            {
                let line=part.Host.lines[edge];vector2 xy=end==0?line.v1.p:line.v2.p;
                vector2 heights=Heights(part,xy);
                // También se comprueba la envolvente en bordes secos de planos inclinados.
                // Omitir esos vértices podría aceptar una cuña que sale del radio entre ellos.
                if(heights.Y>heights.X)volume=true;
                if(!pulse.VisiblePoint((xy.X,xy.Y,heights.X)) || !pulse.VisiblePoint((xy.X,xy.Y,heights.Y)))return false;
            }
        }
        return volume;
    }
    void Purify(Sector model,CaelumTarotContamination pulse)
    {
        if(model==null || !Contained(model,pulse))return;
        let connected=CaelumConnectedWaterMap.Get();int index=connected!=null?connected.Index(model):-1;
        if(index>=0)
        {
            // El trasvase posterior puede volver a mezclar contaminación: no se deja una inmunidad.
            if(connected.Water==null || connected.Water.PendingSeconds>0)return;
            if(index==0)connected.Water.QualityA&=CaelumWaterQuality.SALT;
            else connected.Water.QualityB&=CaelumWaterQuality.SALT;
            return;
        }
        index=model.Index();if(Purified.Size()<=index)Purified.Resize(index+1);
        Purified[index]=true;
    }
    void Pulse(CaelumTarotContamination pulse)
    {
        let connected=CaelumConnectedWaterMap.Get();if(connected!=null)connected.Sync(CaelumWorldClock.Get(pulse.Caster));
        Geometry();Array<Sector> candidates;
        for(int i=0;i<pulse.Sectors.Size();i++)
        {
            let host=pulse.Sectors[i];
            for(int j=0;j<host.Get3DFloorCount();j++)
            {
                let floor=host.Get3DFloor(j);
                if((floor.flags&(F3DFloor.FF_EXISTS|F3DFloor.FF_SWIMMABLE))==(F3DFloor.FF_EXISTS|F3DFloor.FF_SWIMMABLE))candidates.Push(floor.model);
            }
            let height=host.GetHeightSec();if(height!=null)candidates.Push(height);
            else if(host.MoreFlags&Sector.SECMF_UNDERWATERMASK)candidates.Push(host);
        }
        for(int i=0;i<candidates.Size();i++)
        {
            bool seen=false;for(int j=0;j<i;j++)if(candidates[j]==candidates[i]){seen=true;break;}
            if(!seen)Purify(candidates[i],pulse);
        }
    }
    Default {+NOINTERACTION +NOBLOCKMAP +NOGRAVITY}
    States {Spawn:TNT1 A -1;Stop;}
}

class CaelumTarotWater : Object play
{
    static void Container(CaelumWaterContainer water,CaelumTarotContamination pulse)
    {
        if(water==null || water.bDestroyed || water.WaterLiters<=0 || CaelumContaminationStorage.IsShielded(water))return;
        Actor carrier=water.Owner;if(carrier==null)carrier=water;
        vector3 center=carrier.Pos+(0,0,carrier.Height/2);
        double radius;
        let fixture=CaelumWaterFurniture(carrier);
        if(fixture!=null)
        {
            // En depósitos fijos, la colisión documentada encierra todo el recipiente.
            double horizontal=(center.XY-pulse.Center.XY).Length()+fixture.Radius;
            double vertical=Abs(center.Z-pulse.Center.Z)+fixture.Height/2;
            if(Sqrt(horizontal*horizontal+vertical*vertical)>pulse.Radius || !pulse.VisiblePoint(center))return;
        }
        else
        {
            // Botellas/cantimploras: esfera térmica existente. Olla: cilindro físico aprobado.
            radius=(water.GetCapacityLiters()/1000*3/(4*CaelumWaterThermalData.PI))**(1.0/3.0);
            if(water is 'CaelumCampPot')
            {
                double r=CaelumCampData.POT_DIAMETER_M/2;
                double h=CaelumCampData.POT_LITERS/1000/(CaelumWaterThermalData.PI*r*r);
                radius=Sqrt(r*r+h*h/4);
            }
            radius*=CaelumPhysicsUnits.MAP_UNITS_PER_METER;
            if((center-pulse.Center).Length()+radius>pulse.Radius || !pulse.VisiblePoint(center))return;
        }
        water.EnsureWaterQuality();
        if(CaelumWaterQuality.Valid(water.WaterQuality))water.WaterQuality&=CaelumWaterQuality.SALT;
    }
}
