// Las hojas conservan su modelo y contrato de interacción. La colisión pertenece
// al PolyObject; sólo una pareja solicitada necesita un pensador de movimiento.
class CaelumPolyDoorEvents : EventHandler
{
    Array<CaelumHingedDoorLeaf> Leaves;

    static CaelumPolyDoorEvents Get()
    { return CaelumPolyDoorEvents(EventHandler.Find("CaelumPolyDoorEvents")); }

    void Register(CaelumHingedDoorLeaf leaf)
    {
        int id=leaf.args[4];
        if(id<=0 || id>CaelumNativeDoorData.LEAF_COUNT)return;
        if(Leaves.Size()<=id)Leaves.Resize(id+1);
        Leaves[id]=leaf;
        let it=level.CreateLineIdIterator(CaelumNativeDoorData.LINE_ID_BASE+id);int index;
        while((index=it.Next())>=0)
        {
            let line=level.lines[index];
            leaf.NativeFaces.Push(line);
            if(leaf.NativeReferenceLine==null)
            {
                leaf.NativeReferenceLine=line;
                vector2 delta=line.v2.p-line.v1.p;
                leaf.NativeClosedAngle=Atan2(delta.Y,delta.X);
            }
            // StartLine ya fue consumida por la inicialización del mapa. Todas
            // las caras ahora pasan por la misma validación, incluso el canto.
            line.special=7;line.args[0]=id;
        }
    }

    CaelumHingedDoorLeaf Peer(CaelumHingedDoorLeaf leaf)
    {
        int id=leaf.args[4];int peer=id%2==1?id+1:id-1;
        return peer>0 && peer<Leaves.Size()?Leaves[peer]:null;
    }

    override void WorldLinePreActivated(WorldEvent e)
    {
        let line=e.ActivatedLine;if(line==null || line.special!=7)return;
        int id=line.args[0];
        if(id<=0 || id>=Leaves.Size() || Leaves[id]==null)return;
        bool owned=false;
        for(int face=0;face<Leaves[id].NativeFaces.Size();face++)
            if(Leaves[id].NativeFaces[face]==line){owned=true;break;}
        if(!owned)return;
        e.ShouldActivate=false;
        Leaves[id].RequestDoorGroup(e.Thing);
    }
}

class CaelumPolyDoors : Object play
{
    static int Progress(CaelumHingedDoorLeaf leaf)
    {
        if(leaf.NativeReferenceLine==null)return leaf.SlideProgress;
        vector2 delta=leaf.NativeReferenceLine.v2.p-leaf.NativeReferenceLine.v1.p;
        double turn=Atan2(delta.Y,delta.X)-leaf.NativeClosedAngle;
        if(turn>180)turn-=360;if(turn< -180)turn+=360;
        return Clamp(int(Round(Abs(turn)*CaelumNativeDoorData.PROGRESS_MAX/CaelumMansionDoorData.OPEN_DEGREES)),0,CaelumNativeDoorData.PROGRESS_MAX);
    }

    static void Pose(CaelumHingedDoorLeaf leaf,int progress)
    {
        if(progress==leaf.SlideProgress && progress==leaf.LastProgress)return;
        leaf.SlideProgress=progress;leaf.LastProgress=progress;
        leaf.Angle=(leaf.args[2]==0?0:90)+(leaf.args[1]>0?180:0)
            -leaf.args[1]*leaf.SwingSide*CaelumMansionDoorData.OPEN_DEGREES*progress/double(CaelumNativeDoorData.PROGRESS_MAX);
        leaf.SetOrigin(leaf.PositionAt(progress,0),true);
    }

    static bool Guarded(CaelumHingedDoorLeaf leaf,Actor user)
    {
        if(leaf.RuloArenaLocked)return false;
        if(leaf.args[3]>0 && !user.CheckKeys(leaf.args[3],false,true))
        {
            if(leaf.LockedSoundCooldown<=0)
            {user.CheckKeys(leaf.args[3],false);leaf.LockedSoundCooldown=7;}
            return false;
        }
        return CaelumFactionCondition.Require(CaelumPlayer(user),leaf.AccessCondition);
    }

    static bool Request(CaelumHingedDoorLeaf leaf,Actor user)
    {
        if(user==null || Abs(user.Pos.Z-leaf.Pos.Z)>CaelumNativeDoorData.USE_VERTICAL_DISTANCE
            || user.Pos.Z>=leaf.Pos.Z+leaf.Height || user.Pos.Z+user.Height<=leaf.Pos.Z
            || !user.CheckSight(leaf))return false;
        if(user.player!=null && (user.health<=0 || (user.player.cheats&CF_PREDICTING)))return false;
        let events=CaelumPolyDoorEvents.Get();if(events==null)return false;
        let peer=events.Peer(leaf);
        if(peer==null || leaf.NativeReferenceLine==null || peer.NativeReferenceLine==null
            || !Guarded(leaf,user) || !Guarded(peer,user))return false;
        Pose(leaf,Progress(leaf));Pose(peer,Progress(peer));
        bool already=leaf.DoorRequested || peer.DoorRequested;
        if(leaf.SlideProgress==0 && peer.SlideProgress==0)
        {
            double across=leaf.args[2]==0?user.Pos.Y-leaf.ClosedPosition.Y:leaf.ClosedPosition.X-user.Pos.X;
            leaf.SwingSide=peer.SwingSide=across>0?-1:1;
        }
        leaf.DoorRequested=peer.DoorRequested=true;
        leaf.HoldTimer=peer.HoldTimer=CaelumNativeDoorData.HOLD_TICS;
        let motion=leaf.NativeMotion;
        if(motion==null || motion.Closing)Start(leaf,peer,false);
        if(!already)leaf.A_StartSound("caelum/world/door_large_open",CHAN_BODY);
        return true;
    }

    static void HaltMotion(CaelumHingedDoorLeaf a,CaelumHingedDoorLeaf b)
    {Polyobj_Stop(a.args[4]);Polyobj_Stop(b.args[4]);}

    static bool Rotate(CaelumHingedDoorLeaf leaf,bool closing)
    {
        int target=closing?0:CaelumNativeDoorData.PROGRESS_MAX;
        int remaining=Abs(target-leaf.SlideProgress);
        if(remaining==0)return true;
        // Los argumentos angulares nativos usan 256 unidades por vuelta;
        // speed se divide entre ocho. Derivados: 90 grados en 16 tics.
        int angle=int(remaining*CaelumMansionDoorData.OPEN_DEGREES*256.0/(CaelumNativeDoorData.PROGRESS_MAX*360.0));
        int speed=int(CaelumNativeDoorData.PROGRESS_PER_TIC*CaelumMansionDoorData.OPEN_DEGREES*256.0*8/(CaelumNativeDoorData.PROGRESS_MAX*360.0));
        int direction=-leaf.args[1]*leaf.SwingSide*(closing?-1:1);
        return direction>0?Polyobj_RotateLeft(leaf.args[4],speed,angle):Polyobj_RotateRight(leaf.args[4],speed,angle);
    }

    static void Start(CaelumHingedDoorLeaf a,CaelumHingedDoorLeaf b,bool closing)
    {
        HaltMotion(a,b);
        if(a.NativeMotion!=null)a.NativeMotion.Destroy();
        Pose(a,Progress(a));Pose(b,Progress(b));
        // El guard NUEVO queda inmediatamente antes de ambas acciones en la
        // lista fresh y luego en STAT_DEFAULT. No reutilizar un guard anterior:
        // permitiría que otro cuerpo se moviera entre el control y la rotación.
        let guard=CaelumPolyDoorMotion(Actor.Spawn("CaelumPolyDoorMotion",a.ClosedPosition,NO_REPLACE));
        guard.A=a;guard.B=b;guard.Closing=closing;
        a.NativeMotion=b.NativeMotion=guard;
        if(!Rotate(a,closing) || !Rotate(b,closing))
        {HaltMotion(a,b);guard.Waiting=true;}
    }

    static bool SweepOccupied(CaelumHingedDoorLeaf leaf,int next)
    {
        let it=BlockThingsIterator.Create(leaf,CaelumMansionDoorData.SWEEP_RADIUS);
        int step=next>=leaf.SlideProgress?1:-1;
        while(it.Next())
        {
            let body=it.thing;if(!body.bSolid || body.bNoClip)continue;
            // El motor puede tratar el borde superior como escalón. Este margen
            // conservador cubre ese caso sin bloquear los techos de 184 MU.
            if(body.Pos.Z>leaf.ClosedPosition.Z+leaf.Height+body.MaxStepHeight
                || body.Pos.Z+body.Height<leaf.ClosedPosition.Z)continue;
            // El contacto con la pose inicial no impide abrir alejándose del
            // cuerpo apoyado. Sólo se prueban las posiciones por recorrer.
            for(int progress=leaf.SlideProgress+step;progress!=next+step;progress+=step)
            {
                double angle=(leaf.args[2]==0?0:90)-leaf.args[1]*leaf.SwingSide
                    *CaelumMansionDoorData.OPEN_DEGREES*progress/double(CaelumNativeDoorData.PROGRESS_MAX);
                vector2 along=(Cos(angle),Sin(angle)),across=(-Sin(angle),Cos(angle));
                vector3 center=leaf.PositionAt(progress,0);
                vector2 delta=body.Pos.XY-center.XY;
                double half=CaelumMansionDoorData.HALF_WIDTH,thick=CaelumNativeDoorData.HALF_THICKNESS;
                // SAT: el motor comprueba la caja XY del cuerpo contra líneas.
                // Incluir ejes mundiales y ambos ejes de la hoja girada.
                if(Abs(delta.X)>Abs(along.X)*half+Abs(across.X)*thick+body.Radius
                    || Abs(delta.Y)>Abs(along.Y)*half+Abs(across.Y)*thick+body.Radius)continue;
                if(Abs(delta dot along)<=half+body.Radius*(Abs(along.X)+Abs(along.Y))
                    && Abs(delta dot across)<=thick+body.Radius*(Abs(across.X)+Abs(across.Y)))return true;
            }
        }
        return false;
    }
}

class CaelumPolyDoorMotion : Actor
{
    CaelumHingedDoorLeaf A,B;
    bool Closing,Waiting;
    override void Tick()
    {
        Super.Tick();if(A==null || B==null){Destroy();return;}
        CaelumPolyDoors.Pose(A,CaelumPolyDoors.Progress(A));CaelumPolyDoors.Pose(B,CaelumPolyDoors.Progress(B));
        if(A.RuloArenaLocked || B.RuloArenaLocked)
        {CaelumPolyDoors.HaltMotion(A,B);Waiting=true;return;}
        int target=Closing?0:CaelumNativeDoorData.PROGRESS_MAX;
        if(A.SlideProgress==target && B.SlideProgress==target)
        {
            if(Closing)
            {A.DoorRequested=B.DoorRequested=false;A.NativeMotion=B.NativeMotion=null;Destroy();return;}
            if(A.PlayerOccupiesDoorway() || B.PlayerOccupiesDoorway())
                A.HoldTimer=B.HoldTimer=Max(A.HoldTimer,CaelumNativeDoorData.BLOCKED_HOLD_TICS);
            if(A.HoldTimer>0){A.HoldTimer--;B.HoldTimer=A.HoldTimer;return;}
            A.DoorRequested=B.DoorRequested=false;CaelumPolyDoors.Start(A,B,true);return;
        }
        int step=Closing?-CaelumNativeDoorData.PROGRESS_PER_TIC:CaelumNativeDoorData.PROGRESS_PER_TIC;
        int nextA=Clamp(A.SlideProgress+step,0,CaelumNativeDoorData.PROGRESS_MAX);
        int nextB=Clamp(B.SlideProgress+step,0,CaelumNativeDoorData.PROGRESS_MAX);
        bool blocked=CaelumPolyDoors.SweepOccupied(A,nextA) || CaelumPolyDoors.SweepOccupied(B,nextB);
        if(Closing && (blocked || A.PlayerOccupiesDoorway() || B.PlayerOccupiesDoorway()))
        {
            A.DoorRequested=B.DoorRequested=true;
            A.HoldTimer=B.HoldTimer=CaelumNativeDoorData.BLOCKED_HOLD_TICS;
            CaelumPolyDoors.Start(A,B,false);return;
        }
        if(blocked){CaelumPolyDoors.HaltMotion(A,B);Waiting=true;return;}
        if(Waiting){CaelumPolyDoors.Start(A,B,Closing);return;}
        // Ambas acciones contiguas aplicarán este paso después del guard.
        CaelumPolyDoors.Pose(A,nextA);CaelumPolyDoors.Pose(B,nextB);
    }
    Default { +NOINTERACTION }
    States { Spawn: TNT1 A -1; Stop; }
}
