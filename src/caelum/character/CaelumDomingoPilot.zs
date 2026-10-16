// #283: clase optativa para el piloto. No reemplaza al jugador normal.
// La simulación, estados, ataques y muebles siguen siendo los de CaelumPlayer.
class CaelumDomingoPilotPlayer : CaelumPlayer
{
    int PilotRevision;
    bool PilotOriginalSprites;
    bool PilotDeathPresentation;
    CaelumDomingoPilotBody PilotBody;
    bool PilotJumpPreparing,PilotJumpNeedsRelease,PilotWasAirborne,PilotGroundTracked;
    int PilotJumpStarted,PilotLandingStarted;
    bool PilotLanding;

    void EnsurePilotMotion()
    {
        // Los guardados del prototipo anterior no tienen transiciones pendientes.
        if(PilotRevision<2)
        {
            PilotJumpPreparing=false;PilotJumpNeedsRelease=false;PilotLanding=false;
            PilotGroundTracked=false;PilotWasAirborne=false;PilotRevision=2;
        }
    }

    bool PilotMotionBlocked()
    {
        let journal=player==null?null:CVar.GetCVar("ca_journal_open",player);
        return player==null || health<=0 || player.playerstate!=PST_LIVE
            || IsPhysicallyImmobilized() || CaelumRestState.IsActive(self)
            || CaelumTelekinesisRules.Held(self) || CreationWizardOpen || EquipmentMenuOpen
            || CraftingMenuOpen || PalomoMerchantMenuOpen || HasActiveConversation()
            || CaelumTimeSkipState.IsOpen(self) || (journal!=null && journal.GetBool());
    }

    void CancelPilotJump()
    {
        if(PilotJumpPreparing)PilotJumpNeedsRelease=true;
        PilotJumpPreparing=false;
    }

    override void CheckJump()
    {
        if(player==null){Super.CheckJump();return;}
        bool predicting=(player.cheats&CF_PREDICTING)!=0;
        if(!predicting)
        {
            EnsurePilotMotion();
            if((player.cmd.buttons&BT_JUMP)==0)PilotJumpNeedsRelease=false;
        }
        // Nadar, volar y desagacharse conservan la interpretación nativa de Saltar.
        if(WaterLevel>=2 || bNoGravity || player.crouchoffset!=0)
        {
            if(!predicting)CancelPilotJump();
            Super.CheckJump();return;
        }
        bool eligible=!PilotMotionBlocked() && player.onground && player.jumpTics==0
            && level.IsJumpingAllowed() && JumpZ>0;
        if(PilotJumpPreparing && !eligible)
        {if(!predicting)CancelPilotJump();return;}
        if(!PilotJumpPreparing)
        {
            if(eligible && !PilotJumpNeedsRelease && (player.cmd.buttons&BT_JUMP)!=0 && !predicting)
            {PilotJumpPreparing=true;PilotJumpStarted=level.time;PilotLanding=false;}
            return;
        }
        if(level.time-PilotJumpStarted<CaelumDomingoPilotFrames.Duration(CaelumDomingoPilotFrames.JUMPPREPARE))return;
        // La pulsación queda encolada aunque ya se haya soltado. Sólo el salto
        // nativo modifica velocidad y cobra Aire/calor; no hay segundo impulso.
        int buttons=player.cmd.buttons;
        double before=Vel.Z;
        player.cmd.buttons|=BT_JUMP;
        Super.CheckJump();
        player.cmd.buttons=buttons;
        if(!predicting)
        {
            PilotJumpPreparing=false;
            if(player.jumpTics==-1 && Vel.Z>before)
            {PilotWasAirborne=true;PilotGroundTracked=true;PilotLanding=false;}
        }
    }

    override int DamageMobj(Actor inflictor,Actor source,int damage,Name mod,int flags,double angle)
    {
        int before=health;
        int result=Super.DamageMobj(inflictor,source,damage,mod,flags,angle);
        if(health<before && (player==null || !(player.cheats&CF_PREDICTING)))CancelPilotJump();
        return result;
    }

    override void Tick()
    {
        Super.Tick();
        if(player==null || (player.cheats&CF_PREDICTING))return;
        EnsurePilotMotion();
        if(PilotMotionBlocked() || WaterLevel>0 || bNoGravity)
        {CancelPilotJump();PilotLanding=false;PilotGroundTracked=false;return;}
        bool grounded=player.onground && Vel.Z<=0;
        if(!PilotGroundTracked){PilotWasAirborne=!grounded;PilotGroundTracked=true;}
        else if(grounded && PilotWasAirborne)
        {PilotLanding=true;PilotLandingStarted=level.time;PilotWasAirborne=false;}
        else if(!grounded)PilotWasAirborne=true;
        if(PilotLanding && level.time-PilotLandingStarted>=CaelumDomingoPilotFrames.Duration(CaelumDomingoPilotFrames.LANDING))
            PilotLanding=false;
        if(PilotJumpPreparing && !grounded)CancelPilotJump();
    }

    bool UpdatePilotVisual()
    {
        if(CurState==null || CharacterProfile==null)return false;
        EnsurePilotMotion();
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
        CancelPilotJump();PilotLanding=false;PilotGroundTracked=false;
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
        // Los estados de ataque/dolor/muerte siguen teniendo su presentación.
        // Las transiciones de salto no bloquean las acciones del jugador.
        if(user.health>0 && (Pose==IDLEBREATHING || Pose==WALK || Pose==RUN))
        {
            if(user.PilotJumpPreparing){Pose=JUMPPREPARE;Elapsed=level.time-user.PilotJumpStarted;}
            else if(user.PilotLanding){Pose=LANDING;Elapsed=level.time-user.PilotLandingStarted;}
            else if(user.PilotGroundTracked && user.PilotWasAirborne && user.WaterLevel==0 && !user.bNoGravity)
            {Pose=JUMPAIR;Elapsed=0;}
        }
        if(user.health>0 && user.CombatBlockModeActive && user.HasActiveBlockSource())
        {
            if(Pose==IDLEBREATHING)Pose=GUARDIDLEBREATHING;
            else if(Pose==WALK)Pose=GUARDWALK;
            else if(Pose==RUN)Pose=GUARDRUN;
            else if(Pose==JUMPPREPARE)Pose=GUARDJUMPPREPARE;
            else if(Pose==LANDING)Pose=GUARDLANDING;
            else if(Pose==JUMPAIR)Pose=GUARDJUMPAIR;
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
