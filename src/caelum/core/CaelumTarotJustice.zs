// La pertenencia vive en cada cuerpo; no se busca a los duelistas en el mapa.
class CaelumJusticeLink : Inventory
{
    int Revision;
    CaelumTarotJustice Duel;
    static clearscope CaelumJusticeLink View(Actor body)
    {return body!=null?CaelumJusticeLink(body.FindInventory('CaelumJusticeLink')):null;}
    static CaelumJusticeLink Get(Actor body)
    {
        let link=View(body);
        if(link==null)link=CaelumJusticeLink(body.GiveInventoryType('CaelumJusticeLink'));
        if(link!=null)link.Revision=CaelumMajorArcanaData.JUSTICE_REVISION;
        return link;
    }
    static clearscope bool Bound(Actor body)
    {let link=View(body);return link!=null && link.Duel!=null && !link.Duel.bDestroyed;}
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE -INVENTORY.INVBAR}
    States {Spawn:TNT1 A -1;Stop;}
}

class CaelumTarotJustice : Actor
{
    int Revision,RemainingTics,SearchIndex[2],RetryTics[2],LastReturnTic;
    Actor Bodies[2];
    vector3 Origins[2];
    double Angles[2];
    bool Returned[2],Ending,Warned,CheckedReturn;
    String OriginMap;

    static bool Alive(Actor body)
    {return body!=null && !body.bDestroyed && body.health>0;}
    static bool Eligible(Actor body)
    {
        if(!Alive(body) || !body.bShootable || body.bNoInteraction || body.bDormant
            || body.bInConversation || CaelumJusticeLink.Bound(body))return false;
        if(!(body is 'CaelumPlayer') && !(body is 'CaelumCombatActor'))return false;
        if(body is 'CaelumPlayer' && CaelumTarotHunt.Held(CaelumPlayer(body)))return false;
        let resident=CaelumAnchoredResident(body);
        if(resident!=null && resident.IsProtectedStoryResident())return false;
        let palomo=CaelumPalomo(body);
        if(palomo!=null && (palomo.bInvisible || (palomo.NarrativeRevealRequired && !palomo.NarrativeRevealed)
            || (palomo.DepartureStarted && !palomo.DepartureDone)))return false;
        return true;
    }
    static bool Overlap(Actor body,vector3 point,Actor other)
    {
        return other!=null && other!=body && !other.bDestroyed && other.bSolid
            && point.Z<other.Pos.Z+other.Height && point.Z+body.Height>other.Pos.Z
            && (point.XY-other.Pos.XY).Length()<body.Radius+other.Radius;
    }
    static bool UnlinkedClear(Actor body,vector3 point)
    {
        let world=CaelumContaminationWorld.Get();let grid=world!=null?world.ContactGrid():null;
        if(grid==null || grid.Heads.Size()==0)return true;
        double reach=body.Radius+grid.LargestRadius;
        int left=int(Floor((point.X-reach)/grid.CELL)),right=int(Floor((point.X+reach)/grid.CELL));
        int low=int(Floor((point.Y-reach)/grid.CELL)),high=int(Floor((point.Y+reach)/grid.CELL));
        for(int x=left;x<=right;x++)for(int y=low;y<=high;y++)
            for(let row=grid.Heads[grid.Hash(x,y)];row!=null;row=row.GridNext)
                if(row.GridX==x && row.GridY==y && Overlap(body,point,row.GridBody))return false;
        return true;
    }
    static bool Fits(Actor body,vector3 point)
    {
        if(!level.IsPointInLevel(point) || !UnlinkedClear(body,point))return false;
        let probe=CaelumSummoningProbe(Actor.Spawn('CaelumSummoningProbe',point,NO_REPLACE));
        if(probe==null)return false;
        probe.A_SetSize(body.Radius,body.Height);probe.FindFloorCeiling();
        bool okay=probe.TestMobjLocation();probe.Destroy();return okay;
    }
    static void Move(Actor body,vector3 point,double facing)
    {
        CaelumTarotObjectMovement.Release(CaelumPlayer(body));
        body.SetOrigin(point,false);body.Angle=facing;body.Vel=(0,0,0);
        body.FindFloorCeiling();body.ClearInterpolation();
        let world=CaelumContaminationWorld.Get();if(world!=null)world.ContactGrid().Track(body);
        let user=CaelumPlayer(body);if(user!=null)
        {
            CaelumMovementImpulse.Clear(user);
            let vote=CaelumCooperativeTravel.View(user);
            if(vote!=null && vote.Opened && vote.JusticeWaiting && vote.Owner==user)vote.OriginPosition=point;
            let visit=CaelumFoolJourney.View(user);
            if(visit!=null && visit.Active && !visit.Returning && visit.OriginMap==level.MapName)
            {visit.OriginPosition=point;visit.OriginAngle=facing;}
        }
    }
    static bool,vector3 Slot(Actor body,vector3 reserved,double reservedRadius)
    {
        vector3 center=CaelumJusticeGeometry.Center(level.MapName);
        // Dieciséis posiciones geométricas, no plazas o reglas de combate nuevas.
        double pitch=CaelumJusticeGeometry.WIDTH/4;
        for(int i=0;i<MAXPLAYERS*2;i++)
        {
            vector3 point=center+(((i%4)-1.5)*pitch,((i/4)-1.5)*pitch,0);
            if(reservedRadius>0 && (point.XY-reserved.XY).Length()<body.Radius+reservedRadius)continue;
            if(Fits(body,point))return true,point;
        }
        return false,(0,0,0);
    }
    static bool Start(CaelumPlayer user,Actor target,int duration)
    {
        if(duration<=0 || user==target || !Eligible(user) || !Eligible(target)
            || !CaelumMajorTargets.Visible(user,target) || CaelumJusticeGeometry.Get()==null)return false;
        let vote=CaelumCooperativeTravel.View(user);
        if(CaelumJusticeTransit.Active() || (vote!=null && vote.Opened && vote.JusticeWaiting))return false;
        let room=CaelumJusticeGeometry.Get();
        if(user.CurSector==room || target.CurSector==room)return false;
        bool found;vector3 first,second;
        [found,first]=Slot(user,(0,0,0),0);if(!found)return false;
        [found,second]=Slot(target,first,user.Radius);if(!found)return false;
        let own=CaelumJusticeLink.Get(user),other=CaelumJusticeLink.Get(target);
        if(own==null || other==null)return false;
        let duel=CaelumTarotJustice(Actor.Spawn('CaelumTarotJustice',first,NO_REPLACE));
        if(duel==null)return false;
        duel.Revision=CaelumMajorArcanaData.JUSTICE_REVISION;
        duel.OriginMap=level.MapName;duel.RemainingTics=duration;
        duel.Bodies[0]=user;duel.Bodies[1]=target;
        duel.Origins[0]=user.Pos;duel.Origins[1]=target.Pos;
        duel.Angles[0]=user.Angle;duel.Angles[1]=target.Angle;
        own.Duel=other.Duel=duel;
        Move(user,first,user.Angle);Move(target,second,target.Angle);
        CaelumMajorWorldEvents.TimeSourcesChanged();
        return true;
    }
    static bool Segment(Actor body,vector3 from,vector3 point)
    {
        vector3 ray=point-from;if(ray.Length()<0.01)return true;
        FLineTraceData hit;
        return !body.LineTrace(VectorAngle(ray.X,ray.Y),ray.Length(),-VectorAngle(ray.XY.Length(),ray.Z),
            TRF_ABSPOSITION|TRF_THRUACTORS,from.Z,from.X,from.Y,hit)
            || (hit.HitLocation-from).Length()+0.01>=ray.Length();
    }
    static bool ClearSegment(Actor body,vector3 from,vector3 point)
    {
        // Volumen barrido conservador: centro y contorno en tres alturas.
        for(int h=0;h<3;h++)for(int edge=0;edge<9;edge++)
        {
            double angle=(edge-1)*45;
            vector3 offset=edge==0?(0,0,0):(body.Radius*Cos(angle),body.Radius*Sin(angle),0);
            offset.Z=0.01+(body.Height-0.02)*h/2;
            if(!Segment(body,from+offset,point+offset))return false;
        }
        return true;
    }
    bool Reachable(int side,vector3 point){return ClearSegment(Bodies[side],Origins[side],point);}
    bool ReturnSide(int side)
    {
        if(Returned[side])return true;
        let body=Bodies[side];if(!Alive(body)){Returned[side]=true;return true;}
        if(OriginMap!=level.MapName)return false;
        if(RetryTics[side]>0){RetryTics[side]--;return false;}
        vector3 origin=Origins[side];
        if(Fits(body,origin)){Move(body,origin,Angles[side]);Returned[side]=true;return true;}
        double step=Clamp(body.Radius/2,4.0,16.0);
        int extent=int(Ceil(CaelumMajorArcanaData.JUSTICE_RETURN_MU/step)),width=2*extent+1;
        for(int work=0;work<CaelumMajorArcanaData.JUSTICE_SEARCH_BUDGET;work++)
        {
            if(SearchIndex[side]>=width*width)
            {SearchIndex[side]=0;RetryTics[side]=TICRATE;break;}
            int at=SearchIndex[side]++;
            vector3 point=origin+(((at%width)-extent)*step,((at/width)-extent)*step,0);
            if((point-origin).Length()>CaelumMajorArcanaData.JUSTICE_RETURN_MU || !Fits(body,point) || !Reachable(side,point))continue;
            Move(body,point,Angles[side]);Returned[side]=true;return true;
        }
        return false;
    }
    bool ReturnNow()
    {
        Ending=true;
        if(CheckedReturn && LastReturnTic==level.time)return false;
        CheckedReturn=true;LastReturnTic=level.time;
        bool first=ReturnSide(0),second=ReturnSide(1);
        if(first && second){Destroy();return true;}
        if(!Warned)
        {
            Warned=true;
            for(int side=0;side<2;side++)
                CaelumTarotService.Feedback(CaelumPlayer(Bodies[side]),"CA_JUSTICE_RETURN_WAIT");
        }
        return false;
    }
    static bool PrepareTravel()
    {
        bool ready=CaelumSunCargo.PrepareTravel();
        if(!CaelumTarotStar.PrepareTravel())ready=false;
        // A lo sumo un duelo por personaje: sólo los ocho enlaces de sesión.
        for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])
        {
            let link=CaelumJusticeLink.View(players[i].mo);
            if(link!=null && link.Duel!=null && !link.Duel.ReturnNow())ready=false;
        }
        return ready;
    }
    override void Tick()
    {AdvanceEffect();}
    void AdvanceEffect()
    {
        for(int i=0;i<2;i++)
        {let user=CaelumPlayer(Bodies[i]);if(user!=null && user.SessionIdentityPending)return;}
        if(!Alive(Bodies[0]) || !Alive(Bodies[1]) || RemainingTics<=0)Ending=true;
        if(Ending){ReturnNow();return;}
        if(--RemainingTics<=0){Ending=true;ReturnNow();}
    }
    override void OnDestroy()
    {
        for(int i=0;i<2;i++)
        {let link=CaelumJusticeLink.View(Bodies[i]);if(link!=null && link.Duel==self)link.Duel=null;}
        Super.OnDestroy();
    }
    Default {+NOINTERACTION +NOBLOCKMAP +NOGRAVITY}
    States {Spawn:TNT1 A -1;Stop;}
}

// Respaldo central para un traslado ya confirmado, incluida una secuencia de
// El Loco que acaba de activar Justicia. Nunca repite pagos ni otros poderes.
class CaelumJusticeTransit : Inventory
{
    enum DeferredKind { MAP, HOUSE, JOURNEY, TUTORIAL, TRANSPORT }
    bool Pending;
    int Entry,Flags,Mask,Kind,Connection,Mode,Revision;
    Actor Source;
    CaelumJourneyPlan Plan;
    String Destination,OriginMap;
    static clearscope CaelumJusticeTransit View()
    {
        for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i] && players[i].mo!=null)
        {
            let item=CaelumJusticeTransit(players[i].mo.FindInventory('CaelumJusticeTransit'));
            if(item!=null && item.Pending)return item;
        }
        return null;
    }
    static clearscope bool Active(){return View()!=null;}
    static void Queue(String destination,int entry,int flags)
    {
        let owner=CaelumWorldClockTicker.CampaignOwner();if(owner==null)return;
        let item=CaelumJusticeTransit(owner.FindInventory('CaelumJusticeTransit'));
        if(item==null)item=CaelumJusticeTransit(owner.GiveInventoryType('CaelumJusticeTransit'));
        if(item==null || item.Pending)return;
        item.Revision=CaelumMajorArcanaData.JUSTICE_REVISION;item.Kind=MAP;item.Source=null;item.Plan=null;
        item.Pending=true;item.Destination=destination;item.Entry=entry;item.Flags=flags;item.OriginMap=level.MapName;item.Mask=0;
        for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])item.Mask|=1<<i;
    }
    static bool Defer(CaelumPlayer user,int kind,Actor source=null,int connection=0,int mode=0,CaelumJourneyPlan plan=null)
    {
        if(Active())return true;
        if(CaelumTarotJustice.PrepareTravel())return false;
        Queue("",0,0);let item=View();
        if(item!=null){item.Kind=kind;item.Source=source;item.Connection=connection;item.Mode=mode;item.Plan=plan;}
        return true;
    }
    void Cancel()
    {
        Pending=false;let user=CaelumPlayer(Owner);
        if(Kind==MAP)for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])
        {
            let visit=CaelumFoolJourney.View(CaelumPlayer(players[i].mo));
            if(visit==null)continue;
            if(Destination=="MAP01" && visit.Active && visit.OriginMap==level.MapName)visit.Active=false;
            else if(visit.Returning && Destination==visit.OriginMap)visit.Returning=false;
        }
        if(Kind==TUTORIAL)CaelumMainM00Return.Cancel(user);
        if(Kind==TRANSPORT)
        {let booking=CaelumTransportBooking.Find(user);if(booking!=null && booking.Ticket!=null)booking.Ticket.TransferDeclined=true;}
        Source=null;Plan=null;
    }
    override void Tick()
    {
        Super.Tick();if(!Pending)return;
        if(OriginMap!=level.MapName){Cancel();return;}
        for(int i=0;i<MAXPLAYERS;i++)
        {
            if(playeringame[i]!=((Mask&(1<<i))!=0)){Cancel();return;}
            if(playeringame[i] && !CaelumWorldClockTicker.Ready(CaelumPlayer(players[i].mo)))return;
        }
        if(!CaelumTarotJustice.PrepareTravel())return;
        Pending=false;let user=CaelumPlayer(Owner);
        if(Kind==MAP)CaelumDeadTraveler.ChangeMap(Destination,Entry,Flags);
        else if(Kind==HOUSE){let portal=CaelumHousePortal(Source);if(portal!=null)portal.CompleteTravel(user);}
        else if(Kind==JOURNEY)CaelumTravelService.Commit(user,Connection,Mode,Plan);
        else if(Kind==TUTORIAL)CaelumMainM00Return.Update(user);
        else if(Kind==TRANSPORT)CaelumTransportTrip.Flush(user);
        Source=null;Plan=null;
    }
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE -INVENTORY.INVBAR}
    States {Spawn:TNT1 A -1;Stop;}
}
