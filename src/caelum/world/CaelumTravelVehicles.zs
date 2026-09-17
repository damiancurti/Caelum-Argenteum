// Vehículos estacionados y estructuras persistentes. El viaje usa la misma
// transacción de provisiones, reloj y agenda que las rutas a pie.
class CaelumVehiclePart : Actor
{
    CaelumTravelVehicle Vehicle;
    Actor Structure;
    override bool Used(Actor activator)
    {
        let user=CaelumPlayer(activator);
        return Vehicle!=null && CaelumUseGeometry.AimedAt(user,self) && Vehicle.Board(user);
    }
    override void Tick(){Super.Tick();if(Vehicle==null && Structure==null)Destroy();}
    Default { Radius 24; Height 64; +SOLID +ACTLIKEBRIDGE +NOLIFTDROP +CANPASS +NOGRAVITY +CANNOTPUSH +DONTTHRUST +INVULNERABLE RenderStyle "None"; }
    States { Spawn: TNT1 A -1; Stop; }
}

class CaelumTravelVehicle : Actor
{
    bool Ready;
    CaelumVehiclePart Parts[32];
    vector3 BoardingPoint;
    virtual clearscope int TravelMode(){return CaelumJourneyState.MODE_CART;}
    clearscope int Connection(){return level.MapName=="MAP06"?10:level.MapName=="MAP07"?11:0;}
    bool CanBoard(CaelumPlayer user)
    {
        return Ready && Connection()!=0 && user!=null && user.player!=null && user.health>0
            && (user.Pos-BoardingPoint).Length()<=user.UseRange+48
            && user.CheckSight(self,SF_IGNOREVISIBILITY);
    }
    bool Board(CaelumPlayer user)
    {
        if(!CanBoard(user) || !CaelumTravelService.Begin(user,Connection(),TravelMode()))return false;
        let plan=CaelumJourneyPlan.Get(user);
        if(plan==null || !plan.Open)return false;
        plan.SourceVehicle=self;return true;
    }
    override bool Used(Actor activator)
    {return CaelumUseGeometry.AimedAt(CaelumPlayer(activator),self) && Board(CaelumPlayer(activator));}
    vector3 LocalPoint(double along,double across,double up)
    {return Pos+(Cos(Angle)*along-Sin(Angle)*across,Sin(Angle)*along+Cos(Angle)*across,up);}
    bool Part(int slot,double along,double across,double up,double radius,double tall)
    {
        if(Parts[slot]==null)Parts[slot]=CaelumVehiclePart(Spawn("CaelumVehiclePart",LocalPoint(along,across,up),NO_REPLACE));
        if(Parts[slot]==null)return false;
        Parts[slot].Vehicle=self;Parts[slot].A_SetSize(radius,tall,false);
        Parts[slot].SetOrigin(LocalPoint(along,across,up),false);return true;
    }
    virtual bool Prepare()
    {
        bool ok=true;
        for(int i=0;i<3;i++)if(!Part(i,i*40-40,0,0,27,64))ok=false;
        for(int i=0;i<2;i++)if(!Part(3+i,-12,i==0?-38:38,0,5,58))ok=false;
        for(int i=0;i<3;i++)if(!Part(5+i,72+i*20,0,28,4,8))ok=false;
        BoardingPoint=LocalPoint(70,-48,0);Ready=ok;return ok;
    }
    override void OnDestroy(){for(int i=0;i<32;i++)if(Parts[i]!=null)Parts[i].Destroy();Super.OnDestroy();}
    Default { Radius 1; Height 96; +CANPASS +NOGRAVITY +CANNOTPUSH +DONTTHRUST +INVULNERABLE Tag "$CA_JOURNEY_CART"; }
    States { Spawn: CAHC A -1; Stop; }
}

class CaelumCoveredCart : CaelumTravelVehicle {}

class CaelumMerchantShip : CaelumTravelVehicle
{
    override int TravelMode(){return CaelumJourneyState.MODE_SHIP;}
    override bool Prepare()
    {
        bool ok=true;
        for(int row=0;row<10;row++)
        {
            double along=-144+row*32;
            double width=Abs(along)>128?16:Abs(along)>96?32:48;
            for(int col=0;col<3;col++)
                if(!Part(row*3+col,along,(col-1)*(width-16),-32,16,62))ok=false;
        }
        if(!Part(30,0,-72,24,12,76))ok=false;
        BoardingPoint=LocalPoint(0,-104,24);Ready=ok;return ok;
    }
    Default { Height 312; Tag "$CA_JOURNEY_SHIP"; }
}

class CaelumVehicleStructure : Actor
{
    bool Ready;
    CaelumVehiclePart Parts[64];
    bool Part(int slot,vector3 offset,double radius,double tall)
    {
        if(Parts[slot]==null)Parts[slot]=CaelumVehiclePart(Spawn("CaelumVehiclePart",Pos+offset,NO_REPLACE));
        if(Parts[slot]==null)return false;
        Parts[slot].Structure=self;Parts[slot].A_SetSize(radius,tall,false);
        Parts[slot].SetOrigin(Pos+offset,false);return true;
    }
    virtual bool Prepare(){return true;}
    override void OnDestroy(){for(int i=0;i<64;i++)if(Parts[i]!=null)Parts[i].Destroy();Super.OnDestroy();}
    Default { Radius 1; Height 1; +NOBLOCKMAP +NOGRAVITY +NOTARGET }
    States { Spawn: CAHC A -1; Stop; }
}

class CaelumVehicleRanch : CaelumVehicleStructure
{
    override bool Prepare()
    {
        bool ok=true;int index=0;
        // Colisiones cuadradas pequeñas siguen las tres paredes del rancho.
        for(int x=-120;x<=120;x+=16)
            for(int side=0;side<2;side++)if(!Part(index++,(x,side==0?-94:94,0),8,124))ok=false;
        for(int y=-80;y<=80;y+=16)if(!Part(index++,(-126,y,0),8,124))ok=false;
        // Techo sólido a 123 MU: se puede pasar debajo sin bloquear la puerta.
        for(int x=-96;x<=96;x+=64)
            for(int y=-64;y<=64;y+=64)if(!Part(index++,(x,y,123),32,8))ok=false;
        Ready=ok;return ok;
    }
    bool Covers(Actor user)
    {return Ready && Abs(user.Pos.X-Pos.X)<128 && Abs(user.Pos.Y-Pos.Y)<94
        && user.Pos.Z>=Pos.Z-1 && user.Pos.Z+user.Height<Pos.Z+123;}
}

class CaelumVehicleDock : CaelumVehicleStructure
{
    override bool Prepare()
    {
        bool ok=true;
        for(int x=0;x<9;x++)
            for(int y=0;y<2;y++)if(!Part(x*2+y,(x*64-256,y==0?-32:32,-4),32,4))ok=false;
        Ready=ok;return ok;
    }
}

class CaelumVehicleWorld : StaticEventHandler
{
    bool Prepared;
    override void WorldLoaded(WorldEvent event){Prepared=false;}
    static Actor Find(class<Actor> kind)
    {let it=ThinkerIterator.Create(kind);return Actor(it.Next());}
    static bool Prepare()
    {
        if(level.MapName!="MAP06" && level.MapName!="MAP07")return true;
        bool port=level.MapName=="MAP06";
        vector3 ranchPos=port?(-640,192,0):(-512,384,0);
        let ranch=CaelumVehicleRanch(Find("CaelumVehicleRanch"));
        if(ranch==null)ranch=CaelumVehicleRanch(Actor.Spawn("CaelumVehicleRanch",ranchPos,NO_REPLACE));
        let cart=CaelumCoveredCart(Find("CaelumCoveredCart"));
        if(cart==null)cart=CaelumCoveredCart(Actor.Spawn("CaelumCoveredCart",ranchPos,NO_REPLACE));
        let ship=CaelumMerchantShip(Find("CaelumMerchantShip"));
        if(ship==null)ship=CaelumMerchantShip(Actor.Spawn("CaelumMerchantShip",port?(1536,768,-24):(1280,1440,-24),NO_REPLACE));
        bool dockReady=true;
        if(!port)
        {
            let dock=CaelumVehicleDock(Find("CaelumVehicleDock"));
            if(dock==null)dock=CaelumVehicleDock(Actor.Spawn("CaelumVehicleDock",(1120,1312,0),NO_REPLACE));
            dockReady=dock!=null && dock.Prepare();
        }
        return ranch!=null && ranch.Prepare() && cart!=null && cart.Prepare()
            && ship!=null && ship.Prepare() && dockReady;
    }
    static bool UnderRoof(Actor user)
    {
        let it=ThinkerIterator.Create("CaelumVehicleRanch");CaelumVehicleRanch ranch;
        while((ranch=CaelumVehicleRanch(it.Next()))!=null)if(ranch.Covers(user))return true;
        return false;
    }
    override void WorldTick(){if(!Prepared)Prepared=Prepare();}
}
