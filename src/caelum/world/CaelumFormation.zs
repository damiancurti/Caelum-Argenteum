// #429: un grupo posee su lista; los miembros no buscan actores globalmente.
class CaelumFormationMember : Object play
{
    CaelumFormation Group;
    CaelumCombatActor Body;
    int Order,Role,Priority,CombatOrder;
    vector2 Offset;
    Actor Goal;
    transient vector3 RecoveryOrigin;
}

class CaelumFormation : Object play
{
    int Revision,Shape,NextOrder,Capacity,OrderRevision;
    Array<CaelumFormationMember> Members;
    CaelumPortSiege CommandOwner;
    CaelumFormationMember Leader;
    bool SingleFile,Retreat,LayoutDirty;
    double Heading,Spacing;
    transient bool PulseReady;
    transient int LastPulse;
    String SourceMap;
    Actor ClearanceProbe;
    transient vector3 LastRecoveryProbe;
    transient double RecoveryDistance;
    transient bool RecoveryProbeReady;
    Array<double> TrailX,TrailY,TrailZ;
    int TrailSize(){return TrailX.Size();}
    vector3 TrailPoint(int i){return (TrailX[i],TrailY[i],TrailZ[i]);}
    void ClearTrail(){TrailX.Clear();TrailY.Clear();TrailZ.Clear();}
    void PushTrail(vector3 p){TrailX.Push(p.X);TrailY.Push(p.Y);TrailZ.Push(p.Z);}
    void PopTrail(){TrailX.Delete(0);TrailY.Delete(0);TrailZ.Delete(0);}
    Actor TrailLeader;
    CaelumPlayer PlayerLeader;

    Actor Anchor()
    {return CaelumVisualPerception.Living(PlayerLeader) ? Actor(PlayerLeader) : Leader!=null ? Actor(Leader.Body) : null;}

    bool SetPlayerLeader(CaelumPlayer user)
    {
        if(user==null || Members.Size()>=CaelumFormationData.PARTY_CAPACITY)return false;
        Initialize(true);PlayerLeader=user;Capacity=CaelumFormationData.PARTY_CAPACITY;
        Leader=null;Retreat=false;LayoutDirty=true;PulseReady=false;return true;
    }

    static int RoleFor(CaelumCombatActor body)
    {
        let weapon=body.GetPossessedSidearm();
        if(weapon!=null && CaelumSupportImplementData.IsSupport(weapon.WeaponType))return CaelumFormationData.SUPPORT;
        if(weapon!=null && (weapon.IsRangedPhysicalType(weapon.WeaponType)
            || weapon.IsMagicalType(weapon.WeaponType)))return CaelumFormationData.RANGED;
        let defender=CaelumPortDefender(body);
        if(defender!=null && defender.Carbine!=null)return CaelumFormationData.RANGED;
        return CaelumFormationData.MELEE;
    }

    static bool Capable(CaelumCombatActor body)
    {
        return CaelumVisualPerception.Living(body) && body.ForcedSleepTics<=0
            && body.CombatLucidityPhysicalStunRemaining<=0
            && !CaelumBolas.Restrained(body) && !CaelumTelekinesisRules.Held(body)
            && (body.SiegeCombatant==null || (!body.SiegeCombatant.Withdrawing && !body.SiegeCombatant.Exited));
    }

    void Initialize(bool party=false)
    {
        if(OrderRevision<1)OrderRevision=1;
        if(Revision>=CaelumFormationData.REVISION)return;
        Capacity=party ? CaelumFormationData.PARTY_CAPACITY : CaelumFormationData.MILITARY_CAPACITY;
        Shape=CaelumFormationData.LINE;SourceMap=level.MapName;LayoutDirty=true;
        Revision=CaelumFormationData.REVISION;
    }

    CaelumFormationMember Add(CaelumCombatActor body,int role,int priority)
    {
        if(body==null || !CaelumVisualPerception.Living(body))return null;
        Initialize();
        if(body.Formation!=null)return body.Formation.Group==self ? body.Formation : null;
        if(Members.Size()>=Capacity-(PlayerLeader!=null ? 1 : 0))return null;
        let member=new("CaelumFormationMember");member.Group=self;member.Body=body;
        member.Order=NextOrder++;member.Role=Clamp(role,CaelumFormationData.MELEE,CaelumFormationData.RANGED);
        member.Priority=priority;Members.Push(member);body.Formation=member;
        LayoutDirty=true;PulseReady=false;return member;
    }

    void Remove(CaelumFormationMember member)
    {
        if(member==null || member.Group!=self)return;
        if(member.Body!=null && member.Body.Formation==member)member.Body.Formation=null;
        if(CommandOwner!=null && member.Body!=null && member.Body.SiegeCombatant!=null)
        {
            let entry=member.Body.SiegeCombatant;
            CaelumTargetSubscriptions.Unwatch(entry);entry.CommandLeader=null;entry.CommandGroup=-1;
            if(Leader==member)entry.GroupCandidates=null;
        }
        if(member.Goal!=null)
        {
            if(member.Body!=null && member.Body.target==member.Goal)member.Body.target=null;
            member.Goal.Destroy();member.Goal=null;
        }
        for(int i=Members.Size()-1;i>=0;i--)if(Members[i]==member)Members.Delete(i);
        if(Leader==member)Leader=null;
        member.Group=null;LayoutDirty=true;PulseReady=false;
    }

    void SetShape(int shape,bool regroup=false)
    {
        shape=Clamp(shape,CaelumFormationData.LINE,CaelumFormationData.DISPERSED);
        if(shape==self.Shape && !regroup)return;
        self.Shape=shape;LayoutDirty=true;OrderRevision=Max(1,OrderRevision)+1;
    }

    void SetRole(CaelumFormationMember member,int role)
    {
        if(member==null || member.Group!=self || member.Role==role)return;
        member.Role=Clamp(role,CaelumFormationData.MELEE,CaelumFormationData.RANGED);LayoutDirty=true;
    }

    void Elect()
    {
        if(CaelumVisualPerception.Living(PlayerLeader))
        {if(Leader!=null)LayoutDirty=true;Leader=null;Retreat=false;return;}
        if(Leader!=null && Leader.Group==self && Capable(Leader.Body))return;
        let previous=Leader;Leader=null;
        for(int i=0;i<Members.Size();i++)
        {
            let member=Members[i];if(!Capable(member.Body))continue;
            if(Leader==null || member.Priority<Leader.Priority
                || (member.Priority==Leader.Priority && member.Order<Leader.Order))Leader=member;
        }
        Retreat=Leader==null;
        LayoutDirty=true;
        if(CommandOwner!=null)
        {
            if(previous!=null && previous.Body!=null && previous.Body.SiegeCombatant!=null)
            {CaelumTargetSubscriptions.Unwatch(previous.Body.SiegeCombatant);previous.Body.SiegeCombatant.GroupCandidates=null;}
            if(Leader!=null)
            {
                let command=Leader.Body.SiegeCombatant;
                if(command.GroupCandidates==null)command.GroupCandidates=new('CaelumCommandCandidates');
                command.GroupCandidates.Members.Clear();command.GroupCandidates.Ready=false;
                for(int i=0;i<Members.Size();i++)command.GroupCandidates.Members.Push(Members[i].Body.SiegeCombatant);
            }
        }
        // La sucesion cambia el emisor de ordenes, no inventa memoria nueva.
        for(int i=0;i<Members.Size();i++)
        {
            let body=Members[i].Body;if(body==null || body.SiegeCombatant==null)continue;
            body.SiegeCombatant.CommandLeader=Leader==null ? null : Leader.Body.SiegeCombatant;
            if(Retreat && body.health>0)body.SiegeCombatant.Withdrawing=true;
        }
    }

    void Layout()
    {
        if(!LayoutDirty)return;
        LayoutDirty=false;double radius=PlayerLeader!=null ? PlayerLeader.Radius : 0;
        for(int i=0;i<Members.Size();i++)if(Members[i].Body!=null)radius=Max(radius,Members[i].Body.Radius);
        Spacing=radius*2+CaelumPhysicsUnits.MapUnits(Shape==CaelumFormationData.DISPERSED
            ? CaelumFormationData.DISPERSED_CLEARANCE_METERS : CaelumFormationData.CLEARANCE_METERS);
        int ordinal=1;
        for(int role=CaelumFormationData.MELEE;role<=CaelumFormationData.RANGED;role++)
        {
            int count=PlayerLeader!=null && Leader==null && role==CaelumFormationData.MELEE ? 1 : 0;
            for(int i=0;i<Members.Size();i++)if(Members[i].Role==role)count++;
            int column=0;
            for(int i=0;i<Members.Size();i++)
            {
                let member=Members[i];if(member.Role!=role)continue;
                int index=member==Leader ? 0 : ordinal++;
                if(Shape==CaelumFormationData.COLUMN || SingleFile)member.Offset=(-index*Spacing,0);
                else if(Shape==CaelumFormationData.WEDGE)
                {
                    int rank=(index+1)/2;
                    member.Offset=(-rank*Spacing,(index%2==0 ? 1 : -1)*rank*Spacing);
                }
                else if(PlayerLeader!=null && Leader==null && role==CaelumFormationData.MELEE)
                {
                    int middle=count/2;int place=column>=middle ? column+1 : column;
                    member.Offset=(0,(place-middle)*Spacing);
                }
                else member.Offset=(-role*Spacing,(column-(count-1)/2.0)*Spacing);
                column++;
            }
        }
    }

    void Refresh()
    {
        Initialize();
        if(PulseReady && LastPulse==level.time)return;
        PulseReady=true;LastPulse=level.time;
        if(CaelumVisualPerception.Living(PlayerLeader))Heading=PlayerLeader.Angle;
        for(int i=Members.Size()-1;i>=0;i--)
        {
            let member=Members[i];let body=member.Body;
            if(body==null || body.bDestroyed || body.health<=0
                || (body.SiegeCombatant!=null && (body.SiegeCombatant.Exited || body.SiegeCombatant.Withdrawing))
                || (CommandOwner!=null && (!CommandOwner.ActiveEntry(body.SiegeCombatant)
                    || CaelumRedemption.PreviouslyRaised(body))))Remove(member);
        }
        RecoveryDistance=0;
        for(int i=0;i<Members.Size();i++)
            RecoveryDistance=Max(RecoveryDistance,(Members[i].Body.Pos-Members[i].RecoveryOrigin).Length());
        Elect();Layout();RememberRoute();
    }

    void RememberRoute()
    {
        let body=Anchor();if(body==null)return;
        if(TrailLeader!=body){ClearTrail();TrailLeader=body;}
        double step=Max(1.0,body.Radius/2);
        if(TrailSize()==0 || (TrailPoint(TrailSize()-1)-body.Pos).Length()>=step)PushTrail(body.Pos);
        // El limite deriva de la longitud del grupo, no de la poblacion del mapa.
        int capacity=int(Ceil(Members.Size()*Spacing/step))+2;
        while(TrailSize()>capacity)PopTrail();
    }

    vector3 RoutePoint(double behind)
    {
        vector3 newer=Anchor().Pos;
        for(int i=TrailSize()-1;i>=0;i--)
        {
            vector3 older=TrailPoint(i);double length=(newer-older).Length();
            if(length>=behind && length>0)return newer+(older-newer)*behind/length;
            behind-=length;newer=older;
        }
        // Mientras no haya rastro suficiente, la marcha conserva su orientacion.
        return newer-(Cos(Heading)*behind,Sin(Heading)*behind,0);
    }

    void RecoverShape()
    {
        if(!SingleFile || Anchor()==null || Members.Size()==0 || Shape==CaelumFormationData.COLUMN)return;
        let body=Anchor();
        if(RecoveryProbeReady && (body.Pos-LastRecoveryProbe).Length()<Spacing
            && RecoveryDistance<Spacing)return;
        LastRecoveryProbe=body.Pos;RecoveryProbeReady=true;RecoveryDistance=0;
        for(int i=0;i<Members.Size();i++)Members[i].RecoveryOrigin=Members[i].Body.Pos;
        if(ClearanceProbe==null)ClearanceProbe=Actor.Spawn("CaelumFormationProbe",body.Pos);
        SingleFile=false;LayoutDirty=true;Layout();
        bool clear=true;
        for(int i=0;i<Members.Size();i++)
        {
            let member=Members[i];if(member.Body==null)continue;
            vector3 point=Destination(member);
            ClearanceProbe.SetOrigin(body.Pos,false);
            ClearanceProbe.A_SetSize(member.Body.Radius,member.Body.Height);
            FCheckPosition fit;
            if(!ClearanceProbe.CheckPosition(point.XY,false,fit)
                || fit.ceilingz-fit.floorz<member.Body.Height
                || Abs(fit.floorz-body.FloorZ)>member.Body.MaxStepHeight){clear=false;break;}
            if(member.Goal==null)member.Goal=Actor.Spawn("CaelumSewerEscapeTarget",point);
            member.Goal.SetOrigin(point,false);
            if(!ClearanceProbe.CheckSight(member.Goal,SF_IGNOREVISIBILITY)
                || !member.Body.CheckSight(member.Goal,SF_IGNOREVISIBILITY)){clear=false;break;}
            // Dos bordes de la trayectoria evitan abrir la fila cuando solo
            // cabe una linea visual por la puerta, pero no el cuerpo completo.
            vector2 direction=point.XY-member.Body.Pos.XY;
            if(direction.Length()>0)
            {
                // La vista puede rozar una esquina por la que no cabe el
                // cilindro. Validar todo el segmento antes de abrir la fila.
                // Una consulta compartida al recuperar forma, acotada a su
                // longitud; no hay barridos de actores por miembro/tic.
                if(direction.Length()>Spacing*(Members.Size()+1)){clear=false;break;}
                int samples=int(Ceil(direction.Length()/Max(1.0,member.Body.Radius)));
                double floor=member.Body.FloorZ;
                for(int sample=1;sample<=samples;sample++)
                {
                    ClearanceProbe.SetOrigin(member.Body.Pos,false);
                    FCheckPosition segment;
                    if(!ClearanceProbe.CheckPosition(member.Body.Pos.XY+direction*sample/samples,false,segment)
                        || segment.ceilingz-segment.floorz<member.Body.Height
                        || Abs(segment.floorz-floor)>member.Body.MaxStepHeight)
                    {clear=false;break;}
                    floor=segment.floorz;
                }
                if(!clear)break;
                vector2 edge=(-direction.Y,direction.X).Unit()*member.Body.Radius;
                for(int sign=-1;sign<=1;sign+=2)
                {
                    ClearanceProbe.SetOrigin(member.Body.Pos+(edge.X*sign,edge.Y*sign,0),false);
                    member.Goal.SetOrigin(point+(edge.X*sign,edge.Y*sign,0),false);
                    if(!ClearanceProbe.CheckSight(member.Goal,SF_IGNOREVISIBILITY)){clear=false;break;}
                }
                member.Goal.SetOrigin(point,false);
                if(!clear)break;
            }
        }
        if(!clear){SingleFile=true;LayoutDirty=true;Layout();}
    }

    vector3 Destination(CaelumFormationMember member)
    {
        Refresh();if(Anchor()==null || member==null)return member!=null && member.Body!=null ? member.Body.Pos : (0,0,0);
        vector2 offset=member.Offset-(Leader!=null ? Leader.Offset : (0,0));
        if((SingleFile || Shape==CaelumFormationData.COLUMN) && offset.X<0)return RoutePoint(-offset.X);
        vector2 forward=(Cos(Heading),Sin(Heading)),side=(-forward.Y,forward.X);
        vector2 result=Anchor().Pos.XY+forward*offset.X+side*offset.Y;
        return (result.X,result.Y,Anchor().Pos.Z);
    }

    bool Follow(CaelumFormationMember member)
    {
        Refresh();if(Retreat || Anchor()==null || member==null || member==Leader || !Capable(member.Body))return false;
        RecoverShape();
        let body=member.Body;vector3 destination=Destination(member);
        if((body.Pos.XY-destination.XY).Length()<=body.Speed && Abs(body.Pos.Z-destination.Z)<=body.MaxStepHeight)
        {body.Vel.X=0;body.Vel.Y=0;return true;}
        if(member.Goal==null)member.Goal=Actor.Spawn("CaelumSewerEscapeTarget",destination);
        member.Goal.SetOrigin(destination,false);body.target=member.Goal;body.LastEnemy=null;
        vector2 delta=destination.XY-body.Pos.XY;
        if(delta.Length()>0)
        {
            body.Angle=VectorAngle(delta.X,delta.Y);
            if(body.ThermalTryMove(body.Pos.XY+delta.Unit()*Min(body.Speed,delta.Length())))return true;
        }
        // La marcha directa evita orbitar una plaza. A_Chase solo esquiva
        // cuando la colision real impide ese paso; nunca se teletransporta.
        if(!SingleFile && (body.MovementBlockingLine!=null || body.BlockingLine!=null))
        {SingleFile=true;LayoutDirty=true;RecoveryProbeReady=false;return true;}
        body.ThermalChase(null,null,CHF_DONTLOOKALLAROUND);
        return true;
    }

    bool RegroupCombat(CaelumFormationMember member,Actor victim)
    {
        Refresh();
        if(member==null || member.Group!=self || member.Body==null || Anchor()==null)return false;
        let body=member.Body;
        if(body==Anchor()){member.CombatOrder=OrderRevision;return false;}
        if(member.CombatOrder==OrderRevision || victim==null || victim.health<=0)return false;
        if(body.Distance2D(victim)<=body.MeleeRange+victim.Radius)return false;
        if((body.MeleeState!=null && body.InStateSequence(body.CurState,body.MeleeState))
            || (body.MissileState!=null && body.InStateSequence(body.CurState,body.MissileState)))return false;
        vector3 destination=Destination(member);
        if((body.Pos.XY-destination.XY).Length()<=body.Speed && Abs(body.Pos.Z-destination.Z)<=body.MaxStepHeight)
        {member.CombatOrder=OrderRevision;return false;}
        // La orden solo mueve hacia una plaza del grupo; el enemigo procede
        // de la percepcion propia. Al llegar se retoma el combate individual.
        bool moved=Follow(member);body.target=victim;return moved;
    }
}

// Solo consulta geometria: nunca mueve ni atraviesa un cuerpo real del grupo.
class CaelumFormationProbe : Actor
{
    Default { +NOBLOCKMAP +NOGRAVITY +THRUACTORS +INVISIBLE }
    States { Spawn: TNT1 A -1; Stop; }
}
