// Un mueble conserva su aspecto/contaminación; cada plaza presta únicamente
// su colisión a un ocupante, reutilizando la sesión de silla ya aceptada.
class CaelumSofa : CaelumPhysicalScenery abstract
{
    CaelumSofaSeat Seats[3];
    bool SeatsReady;
    virtual int Kind(){return 0;}
    vector3 Lateral(double distance){return (-Sin(Angle)*distance,Cos(Angle)*distance,0);}
    vector3 SeatPosition(int index)
    {return Pos+Lateral((index-(CaelumSofaData.Seats(Kind())-1)/2.0)*CaelumSofaData.SEAT_STRIDE);}
    void Configure()
    {
        double width=CaelumSofaData.Width(Kind()),depth=CaelumSofaData.Depth(Kind());
        A_SetSize(Sqrt(width*width+depth*depth)/2,CaelumSofaData.Height(Kind()),false);
        Mass=int(Ceil(CaelumSofaData.Weight(Kind())));
    }
    override void PostBeginPlay(){Super.PostBeginPlay();Configure();}
    void PrepareSeats()
    {
        for(int i=0;i<CaelumSofaData.Seats(Kind());i++)
        {
            if(Seats[i]!=null && !Seats[i].bDestroyed)continue;
            let seat=CaelumSofaSeat(Spawn('CaelumSofaSeat',SeatPosition(i),NO_REPLACE));
            if(seat==null)return;
            seat.Sofa=self;seat.Slot=i;seat.Angle=Angle;
            seat.A_SetSize(CaelumSofaData.SEAT_RADIUS,Height,false);
            Seats[i]=seat;
        }
        SeatsReady=true;
    }
    CaelumSofaSeat AvailableSeat(CaelumPlayer user)
    {
        CaelumSofaSeat best;
        for(int i=0;i<CaelumSofaData.Seats(Kind());i++)
        {
            let seat=Seats[i];
            if(seat==null || !seat.CanReach(user) || seat.Occupant!=null)continue;
            if(best==null || user.Distance2D(seat)<user.Distance2D(best))best=seat;
        }
        return best;
    }
    override bool Used(Actor activator)
    {
        let user=CaelumPlayer(activator);
        if(user==null || user.player==null || (user.player.cmd.buttons&BT_USE)==0
            || !CaelumUseGeometry.AimedAt(user,self) || !user.CheckSight(self))return false;
        let seat=AvailableSeat(user);
        return seat!=null && CaelumRestTrial.Open(user,seat);
    }
    override void Tick(){Super.Tick();if(!SeatsReady)PrepareSeats();}
    override void OnDestroy()
    {
        for(int i=0;i<3;i++)if(Seats[i]!=null)Seats[i].Destroy();
        Super.OnDestroy();
    }
    Default {+NOGRAVITY +CANNOTPUSH +DONTTHRUST +INVULNERABLE +CANPASS -SOLID}
    States {Spawn:CAHC A -1;Stop;}
}
class CaelumTwoSeatSofa : CaelumSofa
{Default {Tag "$CA_SOFAS_TWO";}}
class CaelumThreeSeatSofa : CaelumSofa
{override int Kind(){return 1;} Default {Tag "$CA_SOFAS_THREE";}}

class CaelumSofaSeat : CaelumRestChair
{
    CaelumSofa Sofa;
    int Slot;
    override Actor SightTarget(){return Sofa;}
    override bool CanReach(CaelumPlayer user)
    {return Sofa!=null && !Sofa.bDestroyed && Super.CanReach(user);}
    override bool SupportsRest(CaelumPlayer user)
    {return Sofa!=null && !Sofa.bDestroyed && Super.SupportsRest(user);}
    override vector3 PoseOffsetFor(CaelumPlayer user)
    {
        if(Sofa==null)return (0,0,0);
        double index=Slot-(CaelumSofaData.Seats(Sofa.Kind())-1)/2.0;
        vector3 offset=Sofa.Lateral(index*(CaelumSofaData.VisualStride(Sofa.Kind())-CaelumSofaData.SEAT_STRIDE));
        offset+=PoseOffset();
        offset.Z=CaelumSofaData.SEAT_SURFACE/Max(.001,level.pixelstretch)
            -CaelumAppearanceRegistry.SeatSupportPixels()*user.Scale.Y;
        return offset;
    }
    override bool Used(Actor activator)
    {
        // El recorrido nativo puede encontrar primero otra plaza: el mueble
        // elige siempre la libre más cercana, no el orden de sus proxies.
        return Sofa!=null && !Sofa.bDestroyed && Sofa.Used(activator);
    }
    override void Tick()
    {
        if(Sofa==null || Sofa.bDestroyed){Destroy();return;}
        Super.Tick();
    }
    Default {RenderStyle "None";}
    States {Spawn:TNT1 A -1;Stop;}
}

class CaelumMansionSofas : Object play
{
    static bool Fits(CaelumSofa sofa)
    {
        sofa.bSolid=true;bool fits=sofa.TestMobjLocation();sofa.bSolid=false;
        if(!fits || sofa.WaterLevel!=0 || Abs(sofa.FloorZ-sofa.Pos.Z)>1)return false;
        let probe=Actor.Spawn('CaelumRestPlacementProbe',sofa.Pos,NO_REPLACE);
        if(probe==null)return false;
        probe.A_SetSize(CaelumSofaData.SEAT_RADIUS,sofa.Height,false);
        for(int i=0;i<CaelumSofaData.Seats(sofa.Kind()) && fits;i++)
        {
            vector3 position=sofa.SeatPosition(i);probe.SetOrigin(position,false);probe.FindFloorCeiling();
            fits=probe.TestMobjLocation() && Abs(probe.FloorZ-position.Z)<=1 && probe.WaterLevel==0;
        }
        probe.Destroy();return fits;
    }
    static bool Prepare()
    {
        if(level.MapName!="MAP01")return true;
        bool found[2];let it=ThinkerIterator.Create('CaelumSofa');CaelumSofa sofa;
        // Sólo durante instalación, una vez por segundo hasta que se libere
        // el lugar; dos tipos. Los muebles guardados se conservan por identidad.
        while((sofa=CaelumSofa(it.Next()))!=null)found[Clamp(sofa.Kind(),0,1)]=true;
        for(int kind=0;kind<2;kind++)
        {
            if(found[kind])continue;
            class<CaelumSofa> type=kind==1?'CaelumThreeSeatSofa':'CaelumTwoSeatSofa';
            sofa=CaelumSofa(Actor.Spawn(type,CaelumSofaData.Position(kind),NO_REPLACE));
            if(sofa==null)return false;
            sofa.Angle=CaelumSofaData.Facing(kind);
            if(!Fits(sofa)){sofa.Destroy();return false;}
            sofa.PrepareSeats();if(!sofa.SeatsReady){sofa.Destroy();return false;}
        }
        return true;
    }
}
