// El acabado no concede otra recuperación. Cada pieza conserva los controles
// y reglas de silla, cama o mesa; sus dimensiones y masas proceden de la ficha.
class CaelumLuxuryChair : CaelumRestChair
{
    override void PostBeginPlay()
    {
        Super.PostBeginPlay();
        double w=CaelumLuxuryData.Width(0),d=CaelumLuxuryData.Depth(0);
        A_SetSize(Sqrt(w*w+d*d)/2,CaelumLuxuryData.Height(0),false);
        Mass=int(Ceil(CaelumLuxuryData.Weight(0)));
    }
    override vector3 PoseOffsetFor(CaelumPlayer user)
    {
        vector3 offset=PoseOffset();
        offset.Z=CaelumLuxuryData.Surface(0)/Max(.001,level.pixelstretch)
            -CaelumAppearanceRegistry.SeatSupportPixels()*user.Scale.Y;
        return offset;
    }
    Default {Tag "$CA_LUXURY_CHAIR";}
}

class CaelumLuxuryBed : CaelumRestBed
{
    override void PostBeginPlay()
    {
        Super.PostBeginPlay();
        double w=CaelumLuxuryData.Width(1),d=CaelumLuxuryData.Depth(1);
        A_SetSize(Sqrt(w*w+d*d)/2,CaelumLuxuryData.Height(1),false);
        Mass=int(Ceil(CaelumLuxuryData.Weight(1)));
    }
    override vector3 PoseOffsetFor(CaelumPlayer user)
    {return (0,0,CaelumLuxuryData.Surface(1)/Max(.001,level.pixelstretch));}
    Default {Tag "$CA_LUXURY_BED";}
}

class CaelumLuxuryTable : CaelumDiningTable
{
    int LuxuryLayoutRevision;
    override double LengthMU(){return CaelumLuxuryData.Width(2);}
    override double WidthMU(){return CaelumLuxuryData.Depth(2);}
    override double SurfaceHeight(){return CaelumLuxuryData.Surface(2)/Max(.001,level.pixelstretch);}
    override class<CaelumRestChair> ChairClass(){return 'CaelumLuxuryChair';}
    // El límite y las pertenencias siguen siendo 18 unidades. Sólo el plato
    // dibujado adapta su escala a la retícula del tablero histórico más angosto.
    override double ServingScale(){return Min(1,WidthMU()/(3*CaelumLuxuryData.SERVING_DIAMETER));}
    override double DisplayMargin(){return CaelumLuxuryData.SERVING_DIAMETER*ServingScale();}
    // Una pieza fabricada no crea provisiones ni agua al aparecer en la mansión.
    override void SyncLocalDay(int localDay){}
    override void RestockMansion(){}
    override int ForecastDailyTarget(){return 0;}
    override void PostBeginPlay()
    {
        Super.PostBeginPlay();Mass=int(Ceil(CaelumLuxuryData.Weight(2)));
        A_SetSize(1,CaelumLuxuryData.Height(2),false);
    }
    bool PrepareLuxuryLayout()
    {
        int columns=int(Ceil(LengthMU()/CaelumLuxuryData.COLLISION_CELL)),rows=int(Ceil(WidthMU()/CaelumLuxuryData.COLLISION_CELL));
        double cellX=LengthMU()/columns,cellY=WidthMU()/rows;
        for(int x=0;x<columns;x++)for(int y=0;y<rows;y++)
        {
            int index=x*rows+y;if(Blocks[index]!=null)continue;
            let block=CaelumDiningBlock(Spawn('CaelumDiningBlock',LocalPoint(
                -LengthMU()/2+(x+.5)*cellX,-WidthMU()/2+(y+.5)*cellY),NO_REPLACE));
            if(block==null)return false;
            block.Table=self;Blocks[index]=block;
            block.A_SetSize(Min(cellX,cellY)/2,Height,false);
        }
        return CaelumDiningWorld.EnsureSeats(self);
    }
    override void Tick()
    {
        Super.Tick();
        if(LuxuryLayoutRevision<CaelumLuxuryData.LAYOUT_REVISION && PrepareLuxuryLayout())
            LuxuryLayoutRevision=CaelumLuxuryData.LAYOUT_REVISION;
    }
    Default {Tag "$CA_LUXURY_TABLE";}
}
