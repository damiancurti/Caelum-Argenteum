// Registro visual: sólo se reconstruye al cargar, con un censo tipado de
// auxiliares. El cierre retira todos antes de que GZDoom guarde el hub.
class CaelumBullModelRegistry : StaticEventHandler
{
    Array<CaelumBullModelBody> Bodies;
    bool Unloading;
    static CaelumBullModelRegistry Get()
    {return CaelumBullModelRegistry(StaticEventHandler.Find("CaelumBullModelRegistry"));}
    void Track(CaelumBullModelBody body)
    {if(Bodies.Find(body)==Bodies.Size())Bodies.Push(body);}
    void Forget(CaelumBullModelBody body)
    {int i=Bodies.Find(body);if(i<Bodies.Size())Bodies.Delete(i);}
    override void WorldLoaded(WorldEvent e)
    {
        Unloading=false;
        Bodies.Clear();let it=ThinkerIterator.Create("CaelumBullModelBody");CaelumBullModelBody body;
        while((body=CaelumBullModelBody(it.Next()))!=null)Bodies.Push(body);
    }
    override void WorldUnloaded(WorldEvent e)
    {
        // Puede quedar un último tic entre este evento y SnapshotLevel.
        // Bloquea la recreación perezosa durante toda esa transición.
        Unloading=true;
        while(Bodies.Size()>0)
        {
            let body=Bodies[Bodies.Size()-1];Bodies.Pop();
            if(body!=null)body.ReleaseOwner();
        }
    }
    override void OnUnregister(){Bodies.Clear();Unloading=false;}
}

// Presentación local del toro: ningún estado visual gobierna su combate.
class CaelumBullModelBody : CaelumBullModelFrames
{
    int Pose,Elapsed,ModelFrame;
    double GaitPhase;
    Vector3 LastOwnerPosition;
    bool HasPosition,DistanceDriven;
    double RecentDistance[4];
    int LastDistanceTic;

    override void PostBeginPlay()
    {Super.PostBeginPlay();let registry=CaelumBullModelRegistry.Get();if(registry!=null)registry.Track(self);}
    override void OnDestroy()
    {let registry=CaelumBullModelRegistry.Get();if(registry!=null)registry.Forget(self);Super.OnDestroy();}

    static bool Enabled()
    {
        let registry=CaelumBullModelRegistry.Get();
        if(registry!=null && registry.Unloading)return false;
        let setting=CVar.GetCVar("ca_bull_3d");
        return setting!=null && setting.GetBool();
    }

    static void RestoreSprite(CaelumBull owner)
    {
        if(owner!=null && owner.CurState!=null)
        {owner.sprite=owner.CurState.sprite;owner.frame=owner.CurState.Frame;}
    }

    void ReleaseOwner()
    {
        let owner=CaelumBull(Master);
        if(owner!=null && owner.BullModel==self)
        {RestoreSprite(owner);owner.BullModel=null;}
        Destroy();
    }

    int NativeElapsed(CaelumBull owner,State beginning)
    {
        State cursor=beginning;int elapsed=0;
        // Recorrido acotado de estados del único dueño, nunca de actores.
        for(int count=0;count<=Duration(DEATH);count++)
        {
            if(cursor==null)return 0;
            if(cursor==owner.CurState)
                return elapsed+(cursor.Tics>0?Max(0,cursor.Tics-owner.tics):0);
            if(cursor.Tics<0)return elapsed;
            elapsed+=Max(0,cursor.Tics);cursor=cursor.NextState;
        }
        return 0;
    }

    void UpdateVisual()
    {
        let owner=CaelumBull(Master);
        if(owner==null || owner.BullModel!=self){Destroy();return;}
        // El archivo detiene al cadáver dueño, pero este auxiliar aún recibe
        // el tic necesario para retirarse. Recall lo reconstruye perezosamente.
        if(!Enabled() || (owner.health<=0 && CaelumCorpseArchive.Suspended(owner))){ReleaseOwner();return;}
        bInvisible=owner.bInvisible;
        if(owner.CurState==null)return;
        double distance=HasPosition?(owner.Pos.XY-LastOwnerPosition.XY).Length():0;
        if(distance>=RUN_STRIDE)distance=0;
        int slot=level.time%4;
        if(LastDistanceTic!=level.time){RecentDistance[slot]=0;LastDistanceTic=level.time;}
        RecentDistance[slot]+=distance;
        double recent=(RecentDistance[0]+RecentDistance[1]+RecentDistance[2]+RecentDistance[3])/4;
        LastOwnerPosition=owner.Pos;HasPosition=true;
        SetOrigin(owner.Pos,true);Prev=owner.Prev;WorldOffset=owner.WorldOffset;
        FloorClip=owner.FloorClip;Angle=owner.Angle;Scale=owner.Scale;
        A_SetRenderStyle(owner.Alpha,owner.GetRenderStyle());
        int source=owner.CurState.sprite,frame=owner.CurState.Frame;
        Pose=IDLE;Elapsed=level.time%Duration(IDLE);
        if(owner.health<=0)
        {
            Pose=DEATH;Elapsed=NativeElapsed(owner,owner.FindState('Death'));
            if(source==GetSpriteIndex('BULL') && frame>=13){Pose=CORPSE;Elapsed=0;}
        }
        else if(source==GetSpriteIndex('SLBU')){Pose=REST;Elapsed=level.time%Duration(REST);}
        else if(source==GetSpriteIndex('BULL') && frame==7)
        {Pose=PAIN;Elapsed=NativeElapsed(owner,owner.FindState('Pain'));}
        else if(owner.BullChargeActive)
        {Pose=CHARGE;}
        else if(owner.BullModelGoreUntil>level.time)
        {Pose=GORE;Elapsed=Duration(GORE)-(owner.BullModelGoreUntil-level.time);}
        else if(source==GetSpriteIndex('BULL') && frame==5)
        {
            Pose=owner is 'CaelumM00Bull'?PREPARETRIAL:PREPARE;
            Elapsed=NativeElapsed(owner,owner.MeleeState);
        }
        else if(owner.CombatLucidityPhysicalStunRemaining>0)
        {Pose=STUN;Elapsed=level.time%Duration(STUN);}
        else if(source==GetSpriteIndex('BURN'))
        {Pose=recent*Duration(WALK)<=WALK_STRIDE?WALK:RUN;}
        // La fase sigue distancia real; saltos de posición no generan pasos.
        bool gait=Pose==WALK || Pose==RUN || Pose==CHARGE;
        if(gait)
        {
            double stride=Pose==WALK?WALK_STRIDE:RUN_STRIDE;
            if(distance<stride)GaitPhase+=distance/stride;
            GaitPhase-=Floor(GaitPhase);
            Elapsed=int(GaitPhase*Duration(Pose));
        }
        ModelFrame=FrameFor(Pose,Elapsed);
        // La interpolación temporal nativa adelantaría una pata aunque la
        // distancia esté detenida. Sólo las fases por distancia usan muestras
        // discretas; respirar, preparar, dolor y caída conservan interpolación.
        if(gait!=DistanceDriven)
        {
            if(gait)SetModelFlag(MDL_NOINTERPOLATION);else ClearModelFlag(MDL_NOINTERPOLATION);
            DistanceDriven=gait;
        }
        let wanted=FindStateByString(String.Format('F%d',ModelFrame));
        if(CurState!=wanted)SetState(wanted);
        if(tics>0)tics=Max(1,CurState.Tics-(Elapsed-Sample(ModelFrame)));
        owner.sprite=GetSpriteIndex('TNT1');owner.frame=0;
    }

    override void Tick(){Super.Tick();UpdateVisual();}
    Default
    {
        +NOBLOCKMAP +NOINTERACTION +NOGRAVITY
        Radius VISUAL_RADIUS;
        Height VISUAL_HEIGHT;
    }
}
