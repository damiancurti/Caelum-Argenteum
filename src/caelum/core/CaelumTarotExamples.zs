// El anexo no convierte habitaciones existentes en objetivos del Tarot.
// Un controlador guardado posee las hojas y los dos accesos explícitos.
class CaelumTarotExampleRoom : Actor
{
    int Revision;
    bool Wet;
    CaelumTarotLivingObstacle LivingObstacle;
    CaelumTarotAutomaton Automaton;
    CaelumSlidingDoorLeaf Doors[4];
    CaelumTarotExamplePortal Portals[2];

    void Prepare()
    {
        if(Revision>=CaelumTarotExampleData.REVISION)return;
        if(Revision<1)
        {
            Revision=1;
            for(int i=0;i<4;i++)
            {
                class<Actor> kind;
                if(i==0)kind='CaelumTarotFalseWall';
                else if(i==1)kind='CaelumTarotCursedPassage';
                else kind='CaelumTarotExampleRoute';
                Doors[i]=CaelumSlidingDoorLeaf(Actor.Spawn(kind,CaelumTarotExampleData.Door(i),NO_REPLACE));
                if(Doors[i]!=null)
                {
                    Doors[i].args[1]=CaelumTarotExampleData.Slide(i);
                    Doors[i].Angle=CaelumTarotExampleData.DOOR_VISUAL_ANGLE;
                    let route=CaelumTarotExampleRoute(Doors[i]);
                    if(route!=null){route.Room=self;route.WetRoute=i==3;}
                }
            }
            for(int i=0;i<2;i++)
            {
                Portals[i]=CaelumTarotExamplePortal(Actor.Spawn('CaelumTarotExamplePortal',CaelumTarotExampleData.Portal(i),NO_REPLACE));
                if(Portals[i]!=null){Portals[i].Room=self;Portals[i].Route=i;}
            }
        }
        // La revisión se guarda aunque el árbol se destruya después. No reaparece.
        if(Revision<2)
        {
            LivingObstacle=CaelumTarotLivingObstacle(Actor.Spawn('CaelumTarotLivingObstacle',CaelumTarotExampleData.Living(),NO_REPLACE));
            Revision=2;
        }
        if(Revision<3)
        {
            Automaton=CaelumTarotAutomaton(Actor.Spawn('CaelumTarotAutomaton',CaelumTarotExampleData.Automaton(),NO_REPLACE));
            Revision=3;
        }
        Apply();
    }

    void Apply()
    {
        if(!CaelumTarotExampleData.Present())return;
        // La cara del sprite sigue la abertura; los bloqueadores conservan su eje.
        for(int i=0;i<4;i++)if(Doors[i]!=null)Doors[i].Angle=CaelumTarotExampleData.DOOR_VISUAL_ANGLE;
        let water=level.Sectors[CaelumTarotExampleData.WATER];
        double targetZ=Wet?CaelumTarotExampleData.DEPTH:0,current=water.CenterCeiling();
        if(Abs(targetZ-current)>0.001)
            water.MoveCeiling(Abs(targetZ-current),water.ceilingplane.PointToDist((0,0),targetZ),-1,targetZ>current?1:-1,false);
        int light=Wet?CaelumTarotExampleData.LIGHT_WET:CaelumTarotExampleData.LIGHT_DRY;
        level.Sectors[CaelumTarotExampleData.ROOM].SetLightLevel(light);
        level.Sectors[CaelumTarotExampleData.THRESHOLD].SetLightLevel(light);
    }

    bool Toggle(CaelumPlayer user,bool report=true)
    {
        if(!CaelumPlayerAuthority.CanMutate(user) || !CaelumTarotExampleData.Present()
            || user.CurSector==null || user.CurSector.GetUDMFInt("user_ca_tarot_room")!=1)return false;
        // La salida que estaba abierta no puede cerrarse sobre otro cuerpo.
        let closing=CaelumTarotExampleRoute(Doors[Wet?3:2]);
        if(closing!=null && !closing.ClearToClose())
        {if(report)CaelumTarotService.Feedback(user,"CA_TAROT_ROOM_BLOCKED");return false;}
        Wet=!Wet;Apply();return true;
    }
    Default {+NOINTERACTION +NOGRAVITY}
    States {Spawn:TNT1 A -1;Stop;}
}

class CaelumTarotExampleRoute : CaelumSlidingDoorLeaf
{
    CaelumTarotExampleRoom Room;
    bool WetRoute;

    bool OpenRoute(){return Room!=null && Room.Wet==WetRoute;}
    bool ClearToClose()
    {
        // Ocho volúmenes locales iguales a los bloqueadores nativos de la hoja.
        let probe=CaelumSummoningProbe(Actor.Spawn('CaelumSummoningProbe',ClosedPosition,NO_REPLACE));
        if(probe==null)return false;
        int half=CaelumNativeDoorData.HALF_THICKNESS;
        int last=CaelumNativeDoorData.PROGRESS_MAX/2-half;
        probe.A_SetSize(half,Height);bool clear=true;
        for(int offset=-last;offset<=last;offset+=half*2)
        {
            probe.SetOrigin(ClosedPosition+(offset,0,0),false);probe.FindFloorCeiling();
            if(!probe.TestMobjLocation()){clear=false;break;}
        }
        probe.Destroy();return clear;
    }
    override bool CanOpenPassage(Actor user){return OpenRoute();}
    override void Tick()
    {
        RuloArenaLocked=!OpenRoute();
        if(!RuloArenaLocked){DoorRequested=true;HoldTimer=CaelumNativeDoorData.HOLD_TICS;}
        Super.Tick();
    }
}

class CaelumTarotExamplePortal : CaelumPressureTrap
{
    CaelumTarotExampleRoom Room;
    int Route;
    override bool IsPressedBy(Actor body){return false;}
    override bool Used(Actor body)
    {
        let user=CaelumPlayer(body);
        if(Room==null || !CaelumPlayerAuthority.CanMutate(user) || user.health<=0
            || CaelumJusticeLink.Bound(user) || user.Distance3D(self)>user.UseRange+Radius
            || !user.CheckSight(self))return false;
        vector3 arrival=CaelumTarotExampleData.Arrival(Route);
        if(!CaelumTarotJustice.Fits(user,arrival))
        {CaelumTarotService.Feedback(user,"CA_TAROT_EXAMPLES_BLOCKED");return false;}
        CaelumTimeAdvanceState.Halt(user);CaelumRestState.Interrupt(user,"CA_REST_MOVED");
        CaelumTarotJustice.Move(user,arrival,CaelumTarotExampleData.Facing(Route));
        return true;
    }
    Default {Tag "$CA_TAROT_EXAMPLES";}
}

class CaelumTarotExamples : Object play
{
    static CaelumTarotExampleRoom Get()
    {
        let world=CaelumMajorWorldEvents(StaticEventHandler.Find('CaelumMajorWorldEvents'));
        return world!=null?world.Examples:null;
    }
    static void Initialize()
    {
        let world=CaelumMajorWorldEvents(StaticEventHandler.Find('CaelumMajorWorldEvents'));
        if(world==null)return;
        world.Examples=null;
        if(!CaelumTarotExampleData.Present())return;
        // Una reconstrucción tipada por carga, limitada al controlador del anexo.
        let iterator=ThinkerIterator.Create('CaelumTarotExampleRoom');
        world.Examples=CaelumTarotExampleRoom(iterator.Next());
        if(world.Examples==null)
            world.Examples=CaelumTarotExampleRoom(Actor.Spawn('CaelumTarotExampleRoom',CaelumTarotExampleData.Controller(),NO_REPLACE));
        if(world.Examples!=null){world.Examples.Prepare();world.Examples.Apply();}
    }
    static bool Wheel(CaelumPlayer user,bool report=true)
    {
        let room=Get();
        if(room==null || user==null || user.CurSector==null || user.CurSector.GetUDMFInt("user_ca_tarot_room")!=1)
        {if(report)CaelumTarotService.Feedback(user,"CA_TAROT_ROOM_REQUIRED");return false;}
        return room.Toggle(user,report);
    }
}
