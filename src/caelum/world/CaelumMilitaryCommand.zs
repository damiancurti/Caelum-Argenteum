// El mando militar conserva su formación de cien; nunca adopta la del jugador.
class CaelumMilitaryGroup : Object play
{
    CaelumPortSiege Port;
    CaelumFormation Formation;
    int Order,Serial,Recipients;
    vector3 Point;

    void Receive(CaelumPortDefender body)
    {
        body.MilitaryOrderKind=Order;body.MilitaryOrderPoint=Point;body.MilitaryOrderSerial=Serial;
        if(Order==CaelumMilitaryData.HOLD)body.MilitaryHoldPoint=body.Pos;
    }

    bool Linked(CaelumPortDefender body)
    {return CaelumFormation.Capable(body) && Formation.Leader!=null && Formation.Leader.Body!=null
        && body.Distance3D(Formation.Leader.Body)<=CaelumPortData.COMMAND_LINK_RADIUS;}

    void SetOrder(int order,vector3 point,bool collapse=false)
    {
        self.Order=order;self.Point=point;Serial++;Recipients=0;
        Formation.SetShape(Formation.Shape,true);
        for(int i=0;i<Formation.Members.Size();i++)
        {
            let body=CaelumPortDefender(Formation.Members[i].Body);
            if(body!=null && (collapse || Linked(body))){Receive(body);Recipients++;}
        }
    }

    void Refresh()
    {
        Formation.Refresh();
        if(Formation.Retreat && Formation.Members.Size()>0 && Order!=CaelumMilitaryData.WITHDRAW)
            SetOrder(CaelumMilitaryData.WITHDRAW,Point,true);
    }

    static CaelumMilitaryGroup Find(CaelumPortDefender soldier)
    {
        if(soldier==null || soldier.MilitaryGroup==null || soldier.Formation==null
            || soldier.Formation.Group!=soldier.MilitaryGroup.Formation
            || CaelumRedemption.PreviouslyRaised(soldier)
            || (soldier.Companion!=null && soldier.Companion.Enlisted))return null;
        return soldier.MilitaryGroup;
    }

    vector3 Post(CaelumPortDefender soldier)
    {
        Formation.Refresh();
        if(soldier.MilitaryOrderKind==CaelumMilitaryData.HOLD)return soldier.MilitaryHoldPoint;
        Formation.RecoverShape();
        if(soldier.MilitaryOrderSerial==Serial && Formation.Leader!=null && Formation.Leader.Body!=soldier)
            return Formation.Destination(soldier.Formation);
        vector3 point=soldier.MilitaryOrderPoint;
        if(Formation.Leader!=null && Formation.Leader.Body==soldier && (point.XY-soldier.Pos.XY).Length()>0)
            Formation.Heading=VectorAngle(point.X-soldier.Pos.X,point.Y-soldier.Pos.Y);
        return point;
    }

    bool Withdraw(CaelumPortDefender soldier)
    {
        if(soldier.MilitaryOrderKind!=CaelumMilitaryData.WITHDRAW)return false;
        if(!CaelumFormation.Capable(soldier))return true;
        if(soldier.MilitarySerial!=soldier.MilitaryOrderSerial)
        {
            soldier.MilitarySerial=soldier.MilitaryOrderSerial;soldier.MilitaryCrewStep=-1;
            soldier.MilitaryReturnStep=soldier.HomeRevision>0?CaelumPropertyRoutes.Count(soldier.HomeIdentity)-1:-1;
            if(soldier.Gun!=null && soldier.HomeRevision>0 && soldier.Pos.Z>soldier.MaxStepHeight)
            {
                for(int i=6;i<Port.Guns.Size();i++)if(Port.Guns[i]==soldier.Gun)
                {
                    soldier.CrewRouteGun=i-6;double best=1e30;
                    for(int step=0;step<CaelumPortData.CrewRouteCount(i-6);step++)
                    {
                        vector3 p=CaelumPortData.CrewRoutePoint(i-6,step);
                        if(Abs(p.Z-soldier.Pos.Z)>soldier.MaxStepHeight)continue;
                        double distance=(p-soldier.Pos).Length();
                        if(distance<best){best=distance;soldier.MilitaryCrewStep=step;}
                    }
                    break;
                }
            }
        }
        vector3 point=soldier.Station;
        double reach=soldier.Radius;
        if(soldier.HomeRevision>0)
        {
            int house=CaelumPropertyData.ResidentHouse(soldier.HomeIdentity);
            if(soldier.MilitaryCrewStep>=0)
                point=CaelumPortData.CrewRoutePoint(soldier.CrewRouteGun,soldier.MilitaryCrewStep);
            else if(soldier.MilitaryReturnStep>=0)
            {point=CaelumPropertyRoutes.Point(soldier.HomeIdentity,soldier.MilitaryReturnStep);reach=Max(reach,CaelumCityData.TRANSIT_WAYPOINT_REACH);}
            else if(soldier.MilitaryReturnStep==-1)point=CaelumCityData.HouseRoad(house);
            // El cuartel es un hub privado: la tropa queda en su acceso real,
            // visible en la ciudad, sin desaparecer ni atravesar una pared.
            else {point=CaelumCityData.DoorOutside(house);reach=Max(reach,CaelumCityData.TRANSIT_WAYPOINT_REACH);}
        }
        if((soldier.Pos.XY-point.XY).Length()<=reach && Abs(soldier.Pos.Z-point.Z)<=soldier.MaxStepHeight)
        {
            if(soldier.MilitaryCrewStep>=0)soldier.MilitaryCrewStep--;
            else if(soldier.HomeRevision>0 && soldier.MilitaryReturnStep>=-1)soldier.MilitaryReturnStep--;
            soldier.target=null;soldier.Vel.X=0;soldier.Vel.Y=0;return true;
        }
        if(soldier.NavigationTarget==null)soldier.NavigationTarget=Actor.Spawn('CaelumSewerEscapeTarget',point);
        if(!soldier.InStateSequence(soldier.CurState,soldier.SeeState)){soldier.SetState(soldier.SeeState);return true;}
        soldier.MilitaryMoving=true;
        CaelumPortSiege.WalkTo(soldier,soldier.NavigationTarget,point);
        soldier.MilitaryMoving=false;
        return true;
    }
}

class CaelumMilitaryCommand : Object play
{
    CaelumPortSiege Port;
    int Revision;
    Array<CaelumMilitaryGroup> Groups;

    void Register(CaelumPortDefender soldier)
    {
        if(soldier==null || soldier.health<=0 || soldier.Formation!=null
            || CaelumRedemption.PreviouslyRaised(soldier)
            || (soldier.Companion!=null && soldier.Companion.Enlisted))return;
        CaelumMilitaryGroup group=null;
        for(int i=0;i<Groups.Size();i++)
            if(Groups[i].Formation.Members.Size()<CaelumFormationData.MILITARY_CAPACITY){group=Groups[i];break;}
        if(group==null)
        {
            group=new('CaelumMilitaryGroup');group.Port=Port;
            group.Formation=new('CaelumFormation');group.Formation.Initialize();Groups.Push(group);
        }
        let member=group.Formation.Add(soldier,CaelumFormation.RoleFor(soldier),
            soldier is 'CaelumCompanionSubcaptain'?CaelumMilitaryData.COMMANDER_PRIORITY:CaelumMilitaryData.MEMBER_PRIORITY);
        if(member!=null)
        {
            soldier.MilitaryGroup=group;
            if(group.Serial>0 && group.Linked(soldier))group.Receive(soldier);
        }
    }

    void Initialize(CaelumPortSiege port)
    {
        if(Revision>=CaelumMilitaryData.REVISION)return;
        self.Port=port;
        if(Revision==1)
        {
            // Conserva los saves del prototipo probado antes de separar recepción por soldado.
            for(int i=0;i<Groups.Size();i++)
                for(int j=0;j<Groups[i].Formation.Members.Size();j++)
                {
                    let body=CaelumPortDefender(Groups[i].Formation.Members[j].Body);
                    if(body!=null)
                    {
                        vector3 held=body.MilitaryHoldPoint;Groups[i].Receive(body);
                        if(body.MilitaryOrderKind==CaelumMilitaryData.HOLD)body.MilitaryHoldPoint=held;
                    }
                }
            Revision=CaelumMilitaryData.REVISION;return;
        }
        Revision=CaelumMilitaryData.REVISION;
        Register(port.Subcaptain);
        // Migración única desde el plantel propio. Los nacimientos posteriores notifican Bind.
        for(int i=0;i<port.Defenders.Size();i++)Register(port.Defenders[i]);
        Tick();
    }

    void Tick()
    {for(int i=0;i<Groups.Size();i++)Groups[i].Refresh();}

    static String Access(CaelumPlayer user)
    {
        if(!CaelumPlayerAuthority.CanMutate(user) || user.health<=0)return "CA_MILITARY_UNAVAILABLE";
        let record=user.GetPersistentCharacterState(false);if(record==null)return "CA_MILITARY_UNAVAILABLE";
        if(!record.FactionMember[CaelumMilitaryData.GUARD_FACTION])return "CA_MILITARY_MEMBERSHIP";
        if(record.QuestState[CaelumConstants.QUEST_GUARD_CAPTAIN]!=CaelumConstants.QUEST_STATE_COMPLETED)return "CA_MILITARY_OFFICE";
        if(record.FactionReputation[CaelumMilitaryData.GUARD_FACTION]<CaelumMilitaryData.MINIMUM_REPUTATION)return "CA_MILITARY_REPUTATION";
        return "";
    }
}
