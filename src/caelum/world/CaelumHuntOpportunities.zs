// #616: registro guardado y finito de los lugares del laberinto.
class CaelumHuntOpportunities : Object play
{
    Actor Bodies[22],Extras[22],Third[22];
    CaelumHuntArcanaMarker Markers[22];
    CaelumHuntWheelRoom WheelRoom;
    transient Array<bool> Navigation;
    bool BodyBlocks(Actor body,vector2 point,double radius)
    {
        if(body==null || body.bDestroyed || body.bInvisible)return false;
        let door=CaelumSlidingDoorLeaf(body);
        if(door!=null)return Abs(point.X-door.Pos.X)<CaelumNativeDoorData.PROGRESS_MAX/2+radius
            && Abs(point.Y-door.Pos.Y)<CaelumNativeDoorData.HALF_THICKNESS+radius;
        let machine=CaelumCannon(body);
        if(machine!=null)
        {
            for(int i=0;i<machine.Blocks.Size();i++)
                if(BodyBlocks(machine.Blocks[i],point,radius))return true;
            return false;
        }
        return body.bSolid && (body.Pos.XY-point).Length()<body.Radius+radius;
    }
    void NavigationBody(Actor body,double radius,double height)
    {
        if(body==null || body.bDestroyed || body.bInvisible)return;
        let cannon=CaelumCannon(body);
        if(cannon!=null){for(int i=0;i<cannon.Blocks.Size();i++)NavigationBody(cannon.Blocks[i],radius,height);return;}
        bool door=body is 'CaelumSlidingDoorLeaf';
        if((!door && !body.bSolid) || body.Pos.Z>=height || body.Pos.Z+body.Height<=0)return;
        double reach=(door?CaelumNativeDoorData.PROGRESS_MAX/2:body.Radius)+radius;
        int left=Max(0,int(Floor((body.Pos.X-reach)/CaelumHuntData.CELL))),right=Min(CaelumHuntData.GRID-1,int(Floor((body.Pos.X+reach)/CaelumHuntData.CELL)));
        int bottom=Max(0,int(Floor((body.Pos.Y-reach)/CaelumHuntData.CELL))),top=Min(CaelumHuntData.GRID-1,int(Floor((body.Pos.Y+reach)/CaelumHuntData.CELL)));
        for(int x=left;x<=right;x++)for(int y=bottom;y<=top;y++)
            if(BodyBlocks(body,((x+0.5)*CaelumHuntData.CELL,(y+0.5)*CaelumHuntData.CELL),radius))Navigation[y*CaelumHuntData.GRID+x]=true;
    }
    void BuildNavigation(double radius,double height)
    {
        // Una vez por ruta (máximo una por segundo): referencias propias,
        // sin censar actores ni repetir consultas por cada nodo explorado.
        // Medio paso extra cubre también las aristas entre centros: un objeto
        // en el límite de dos celdas no debe dejar una ruta que choque al pasar.
        radius+=CaelumHuntData.CELL/2;
        Navigation.Clear();Navigation.Resize(CaelumHuntData.GRID*CaelumHuntData.GRID);
        for(int i=0;i<22;i++){NavigationBody(Bodies[i],radius,height);NavigationBody(Extras[i],radius,height);NavigationBody(Third[i],radius,height);}
        if(WheelRoom!=null){NavigationBody(WheelRoom.Doors[2],radius,height);NavigationBody(WheelRoom.Doors[3],radius,height);}
    }
    bool Blocks(vector2 point)
    {
        int x=int(Floor(point.X/CaelumHuntData.CELL)),y=int(Floor(point.Y/CaelumHuntData.CELL));
        return x>=0 && y>=0 && x<CaelumHuntData.GRID && y<CaelumHuntData.GRID
            && Navigation.Size()>y*CaelumHuntData.GRID+x && Navigation[y*CaelumHuntData.GRID+x];
    }
    Actor Place(class<Actor> kind,int card,vector3 offset=(0,0,0))
    {return Actor.Spawn(kind,CaelumHuntArcanaData.Center(card)+offset,NO_REPLACE);}
    CaelumSlidingDoorLeaf Door(class<Actor> kind,int card)
    {
        let body=CaelumSlidingDoorLeaf(Actor.Spawn(kind,CaelumHuntArcanaData.Door(card),NO_REPLACE));
        if(body!=null){body.Angle=CaelumTarotExampleData.DOOR_VISUAL_ANGLE;body.args[1]=1;}return body;
    }
    void Initialize()
    {
        for(int card=0;card<22;card++)
        {
            let marker=CaelumHuntArcanaMarker(Actor.Spawn('CaelumHuntArcanaMarker',CaelumHuntArcanaData.Marker(card),NO_REPLACE));
            marker.Card=card;marker.sprite=Actor.GetSpriteIndex(CaelumTarotArt.FrontSprite(card));
            marker.SetTag(CaelumTarotArt.DisplayName(card));Markers[card]=marker;
        }
        Bodies[1]=Place('CaelumTarotAutomaton',1);
        Bodies[2]=Door('CaelumTarotFalseWall',2);
        Bodies[3]=Place('CaelumTreePlainsEspinilloYoung',3,(-CaelumHuntData.CELL/2,0,0));
        Extras[3]=Place('CaelumTreePlainsEspinilloYoung',3,(CaelumHuntData.CELL/2,0,0));
        Bodies[4]=Place('CaelumHuntGuardian',4);
        Bodies[5]=Door('CaelumTarotCursedPassage',5);
        Bodies[7]=Place('CaelumHuntFragileRock',7);
        Bodies[8]=Place('CaelumTarotExampleSpirit',8);
        WheelRoom=CaelumHuntWheelRoom(Place('CaelumHuntWheelRoom',10));WheelRoom.PrepareHunt();
        Bodies[11]=Place('CaelumRockGraniteHalf',11);
        Bodies[13]=Place('CaelumTarotLivingObstacle',13);
        Bodies[14]=Place('CaelumHuntFreezingPlate',14,(0,0,0.5));
        Bodies[15]=Place('CaelumHuntFragileRock',15,(-CaelumHuntData.CELL/2,0,0));
        Extras[15]=Place('CaelumTarotLivingObstacle',15,(CaelumHuntData.CELL/2,0,0));
        let machine=CaelumCannon(Place('CaelumCannon',16));machine.InitializeCannon();Bodies[16]=machine;
        Bodies[17]=Place('CaelumHuntGiantBed',17);
        Bodies[19]=Place('CaelumTarotHeatRock',19,(-CaelumHuntData.CELL/2,0,0));
        Extras[19]=Place('CaelumTarotDirtyRock',19,(CaelumHuntData.CELL/2,0,0));
        Bodies[20]=Place('CaelumHuntInformativeSpirit',20);
        Bodies[21]=Door('CaelumTarotCursedPassage',21);
        Extras[21]=Place('CaelumTarotLivingObstacle',21,(0,-CaelumHuntData.CELL/2,0));
        Third[21]=Place('CaelumHuntFragileRock',21,(-CaelumHuntData.CELL/2,-CaelumHuntData.CELL/2,0));
    }
}

class CaelumHuntArcanaMarker : Actor
{
    int Card;
    override bool Used(Actor body)
    {
        let user=CaelumPlayer(body);if(!CaelumPlayerAuthority.CanMutate(user))return false;
        CaelumTarotService.Feedback(user,String.Format("CA_HUNT_USE_%02d",Card));return true;
    }
    Default {Radius 18;Height 88;Scale 0.25;+NOGRAVITY}
    States {Spawn:CTAR A -1 Bright;Stop;}
}

// Mueble real de la partida: el primer portador adquiere su título normal.
// Después conserva las mismas comprobaciones y el mismo cuerpo al guardarlo.
class CaelumHuntGiantBed : CaelumLuxuryBed
{
    override bool Used(Actor activator)
    {
        let user=CaelumPlayer(activator);
        if(CaelumPlayerAuthority.CanMutate(user) && CanReach(user)
            && CaelumUseGeometry.AimedAt(user,self)
            && (user.player.cmd.buttons & (BT_USE|BT_CROUCH))==(BT_USE|BT_CROUCH))
        {
            if(PackedItem==null)
            {
                PackedItem=CaelumRestFurnitureItem(Actor.Spawn('CaelumLuxuryBedItem',Pos,NO_REPLACE));
                if(PackedItem!=null){PackedItem.Body=self;PackedItem.AttachToOwner(self);}
            }
            if(PackedItem!=null && PackedItem.LawfulOwner==null)
            {
                PackedItem.LawfulOwner=CaelumLockRules.Character(user,true);
                bool carried=PackedItem.Carry(user);
                if(!carried)PackedItem.LawfulOwner=null;
                return carried;
            }
        }
        return Super.Used(activator);
    }
}

class CaelumHuntFragileRock : CaelumTarotFragileObstacle
{
    override void PostBeginPlay()
    {
        Super.PostBeginPlay();let shape=GetDefaultByType('CaelumRockGraniteHalf');
        A_SetSize(shape.Radius,shape.Height);Mass=shape.Mass;Scale=shape.Scale;
        sprite=shape.SpawnState.sprite;frame=shape.SpawnState.Frame;
    }
    Default {Tag "$CA_HUNT_FRAGILE";}
    States {Spawn:CARK A -1;Stop;}
}

// El guardián reutiliza cuerpo, ataques y atributos de la invocación normal.
// Su propietario es el escenario; Emperador conserva su control reversible.
class CaelumHuntGuardian : CaelumSummonedZupay
{
    override void PostBeginPlay(){SummonPower=1;Super.PostBeginPlay();}
    override bool HasValidBinding(){return CaelumTarotHunt.View()!=null;}
    override bool CanAffect(Actor victim)
    {
        if(CaelumTarotEmperor.Blocks(self,victim))return false;
        if(Commander()!=null)return CaelumMajorTargets.Enemy(Commander(),victim);
        let user=CaelumPlayer(victim);let match=CaelumStandaloneMatch.View();
        return user!=null && match!=null && match.Seeker(user.PlayerNumber()) && !CaelumTarotHunt.Held(user);
    }
    Default {-FRIENDLY}
}

class CaelumHuntFreezingPlate : CaelumPressureTrap
{
    int ReadyAt;
    override bool IsPressedBy(Actor body)
    {return body is 'CaelumStandalonePlayer' && !CaelumTarotHunt.HumanHunter(CaelumPlayer(body)) && Super.IsPressedBy(body);}
    override bool Trigger(Actor body)
    {
        if(!IsPressedBy(body))return false;
        let status=CaelumElementalStream.Status(body);if(status==null)return false;
        status.ApplyControlEffect(CaelumConstants.ELEMENTAL_EFFECT_FREEZE,CaelumConstants.ELEMENTAL_BASE_DURATION_SECONDS,
            CaelumConstants.ELEMENTAL_BASE_CONTROL_POWER_PERCENT,body);
        Spent=true;ReadyAt=level.time+CaelumHuntData.REARM_TICS;ActivationCount++;return true;
    }
    override void Tick(){if(Spent && level.time>=ReadyAt)Spent=false;Super.Tick();}
    Default {Tag "$CA_HUNT_FREEZE";}
    States {Spawn:XICE A -1 Bright;Stop;}
}

class CaelumHuntInformativeSpirit : CaelumTarotExampleSpirit
{
    override bool InteractWithCaelumPlayer(CaelumPlayer user)
    {
        if(!CaelumPlayerAuthority.CanMutate(user) || health<=0 || Distance3D(user)>user.UseRange+Radius || !user.CheckSight(self))return false;
        CaelumTarotService.Feedback(user,CanHear(user)?"CA_HUNT_SPIRIT_HINT":"CA_TAROT_SPIRIT_REQUIRES");return true;
    }
}

class CaelumHuntWheelRoom : CaelumTarotExampleRoom
{
    void PrepareHunt()
    {
        for(int i=0;i<2;i++)
        {
            vector3 point=Pos+(i==0?-CaelumHuntData.CELL/2:CaelumHuntData.CELL/2,i==0?-CaelumHuntData.CELL*1.5:CaelumHuntData.CELL*1.5,0);
            let door=CaelumTarotExampleRoute(Actor.Spawn('CaelumTarotExampleRoute',point,NO_REPLACE));
            door.Room=self;door.WetRoute=i==1;door.Angle=CaelumTarotExampleData.DOOR_VISUAL_ANGLE;door.args[1]=1;Doors[i+2]=door;
        }
        Apply();
    }
    override void Apply()
    {
        let water=level.Sectors[CaelumHuntArcanaData.WHEEL_WATER];
        double z=Wet?CaelumTarotExampleData.DEPTH:0,current=water.CenterCeiling();
        if(Abs(z-current)>0.001)water.MoveCeiling(Abs(z-current),water.ceilingplane.PointToDist((0,0),z),-1,z>current?1:-1,false);
        level.Sectors[CaelumHuntArcanaData.WHEEL_ROOM].SetLightLevel(Wet?CaelumTarotExampleData.LIGHT_WET:CaelumTarotExampleData.LIGHT_DRY);
    }
    override bool Toggle(CaelumPlayer user,bool report)
    {
        if(!CaelumPlayerAuthority.CanMutate(user) || user.CurSector==null || user.CurSector.Index()!=CaelumHuntArcanaData.WHEEL_ROOM)
        {if(report)CaelumTarotService.Feedback(user,"CA_TAROT_ROOM_REQUIRED");return false;}
        let closing=CaelumTarotExampleRoute(Doors[Wet?3:2]);
        if(closing!=null && !closing.ClearToClose())
        {if(report)CaelumTarotService.Feedback(user,"CA_TAROT_ROOM_BLOCKED");return false;}
        Wet=!Wet;Apply();return true;
    }
}
