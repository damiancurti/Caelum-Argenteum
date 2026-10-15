// #283: clase optativa para el piloto. No reemplaza al jugador normal.
// La simulación, estados, ataques y muebles siguen siendo los de CaelumPlayer.
class CaelumDomingoPilotPlayer : CaelumPlayer
{
    int PilotRevision;
    bool PilotOriginalSprites;
    bool PilotDeathPresentation;
    CaelumDomingoPilotBody PilotBody;

    bool UpdatePilotVisual()
    {
        if(CurState==null || CharacterProfile==null)return false;
        if(PilotRevision<1)PilotRevision=1;
        bool supported=CharacterProfile.Race==CaelumConstants.RACE_HUMAN
            && CharacterProfile.Sex==CaelumConstants.SEX_MALE
            && WeaponModel!=null && WeaponModel.Equipped
            && WeaponModel.WeaponType==CaelumConstants.WEAPON_TYPE_SWORD
            && ShieldModel!=null && ShieldModel.Equipped;
        // La limpieza posterior del equipo no cambia el cadáver ya presentado.
        if(health>0)PilotDeathPresentation=supported;
        else supported=PilotDeathPresentation || supported || (PilotBody!=null && !PilotBody.bInvisible);
        supported=supported && !(CurState.sprite==GetSpriteIndex('RSDO') && CurState.Frame>=2);
        // Las variantes sin geometría propia conservan la apariencia vigente.
        if(!supported)
        {
            if(PilotBody!=null)PilotBody.bInvisible=true;
            return false;
        }
        if(AppearanceHead!=null){AppearanceHead.Destroy();AppearanceHead=null;}
        if(DerivedStats!=null)Scale=CaelumAppearance.ScaleFor(0,0,0,DerivedStats.ActorHeight);
        if(PilotOriginalSprites)
        {
            sprite=CurState.sprite;frame=CurState.Frame;
            if(PilotBody!=null)PilotBody.bInvisible=true;
            return true;
        }
        if(PilotBody==null)
        {
            PilotBody=CaelumDomingoPilotBody(Actor.Spawn('CaelumDomingoPilotBody',Pos,NO_REPLACE));
            if(PilotBody!=null)PilotBody.Master=self;
        }
        if(PilotBody!=null)
        {
            PilotBody.bInvisible=bInvisible;
            PilotBody.UpdateVisual();
            sprite=GetSpriteIndex('TNT1');frame=0;
            return true;
        }
        return false;
    }

    override bool ApplyCustomWorldVisual(){return UpdatePilotVisual();}
    override void PreTravelled()
    {
        Super.PreTravelled();
        // La presentación local se reconstruye; no viaja un actor del hub viejo.
        if(PilotBody!=null){PilotBody.Destroy();PilotBody=null;}
    }
}

class CaelumDomingoPilotBody : CaelumDomingoPilotFrames
{
    int Pose,Elapsed,ModelFrame;

    int NativeElapsed(CaelumPlayer user,State beginning)
    {
        State cursor=beginning;int elapsed=0;
        // El tiempo procede de los estados nativos, no de otro reloj de combate.
        for(int count=0;count<=Duration(Pose);count++)
        {
            if(cursor==null)return 0;
            if(cursor==user.CurState)
                return elapsed+(cursor.Tics>0?Max(0,cursor.Tics-user.tics):0);
            if(cursor.Tics<0)return elapsed;
            elapsed+=cursor.Tics;cursor=cursor.NextState;
        }
        return 0;
    }

    void UpdateVisual()
    {
        let user=CaelumDomingoPilotPlayer(Master);
        if(user==null || user.PilotBody!=self){Destroy();return;}
        if(bInvisible || user.CurState==null)return;
        SetOrigin(user.Pos,true);Prev=user.Prev;WorldOffset=user.WorldOffset;
        // Volumen de dibujo para el culling; NOINTERACTION conserva al dueño
        // como único cuerpo físico y no participa en la colisión de este actor.
        if(Radius!=user.Radius || Height!=user.Height)A_SetSize(user.Radius,user.Height,false);
        FloorClip=user.FloorClip;Angle=user.Angle;Scale=user.Scale;
        A_SetRenderStyle(user.Alpha,user.GetRenderStyle());
        int source=user.CurState.sprite,frame=user.CurState.Frame;
        Pose=IDLEBREATHING;Elapsed=level.time%Duration(IDLEBREATHING);
        if(source==GetSpriteIndex('DOWK')){Pose=WALK;Elapsed=NativeElapsed(user,user.SeeState);}
        else if(source==GetSpriteIndex('DORN')){Pose=RUN;Elapsed=NativeElapsed(user,user.FindState('Run'));}
        else if(source==GetSpriteIndex('RSDO'))
        {Pose=frame==0?SEATED:frame==1?SLEEPING:CROUCH;Elapsed=level.time%Duration(Pose);}
        else if(source==GetSpriteIndex('DOMI'))
        {
            if(frame>=18)
            {
                Pose=user.health<=0?DEATH:RAISE;
                Elapsed=NativeElapsed(user,Pose==DEATH?user.FindState('Death'):user.FindState('Raise'));
            }
            else if(frame>=10){Pose=MELEE;Elapsed=NativeElapsed(user,user.MeleeState);}
            else if(frame>=2){Pose=MISSILE;Elapsed=NativeElapsed(user,user.MissileState);}
            else{Pose=PAIN;Elapsed=NativeElapsed(user,user.FindState('Pain'));}
        }
        ModelFrame=FrameFor(Pose,Elapsed);
        let wanted=FindStateByString(String.Format('F%d',ModelFrame));
        if(CurState!=wanted)SetState(wanted);
        if(tics>0)tics=Max(1,CurState.Tics-(Elapsed-Sample(ModelFrame)));
    }

    override void Tick(){Super.Tick();UpdateVisual();}
    Default
    {
        +NOBLOCKMAP +NOINTERACTION +NOGRAVITY +MASTERNOSEE
    }
}
