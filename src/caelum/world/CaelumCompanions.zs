// #430: el registro guarda cuerpos e inventarios reales, nunca copias de botin.
class CaelumCompanionItemRecord : Object play
{
    Inventory Item;
    CaelumCompanionBond Bond;
    bool Loan,Credited,Refused;
    double RefusedTrust;
    int RefusedStage;
}

class CaelumCompanionBond : Object play
{
    CaelumCompanionParty Party;
    CaelumCombatActor Body;
    int Identity,Order,Revision,DeathDay,DeathTic,OriginalTID;
    bool Enlisted,DeathRecorded,SlotReleased,Parked,TravelPending;
    double Trust;
    String SourceMap;
    vector3 Position;
    double Facing;
    bool Invisible,Solid,Shootable,NoInteraction,NoBlock,NoSector;
    Array<CaelumCompanionItemRecord> Items;
    CaelumCompanionLoadout Loadout;
    CaelumCompanionMotion Motion;
    transient bool PulseReady;
    transient int PulseTic;

    CaelumPlayer Leader(){return Party!=null ? CaelumPlayer(Party.Owner) : null;}

    void RecordDeath()
    {
        if(DeathRecorded)return;
        let clock=CaelumWorldClock.Get(Leader(),true);
        DeathRecorded=true;DeathDay=clock!=null ? clock.CompletedDays : 0;
        DeathTic=clock!=null ? clock.DayTics : 0;
        if(Body!=null && Body.Formation!=null)Body.Formation.Group.Remove(Body.Formation);
    }

    void Reconcile()
    {
        if(Body==null)return;
        if(Body.health<=0)
        {
            RecordDeath();let clock=CaelumWorldClock.Get(Leader());
            if(clock!=null && (double(clock.CompletedDays)-DeathDay
                +(clock.DayTics-DeathTic)/double(CaelumWorldClock.TicsPerDay()))>CaelumCompanionData.DEAD_SLOT_DAYS)
                SlotReleased=true;
            return;
        }
        if(DeathRecorded)
        {
            DeathRecorded=false;
            // Una resurreccion no desplaza a otro miembro ni vuelve a regalar equipo.
            if(SlotReleased && Party.Occupied()>=CaelumFormationData.PARTY_CAPACITY)
            {Enlisted=false;Order=CaelumCompanionData.DISMISSED;}
            SlotReleased=false;
        }
    }

    CaelumCompanionItemRecord ItemRecord(Inventory item,bool create=false)
    {
        for(int i=0;i<Items.Size();i++)if(Items[i].Item==item)return Items[i];
        if(!create)return null;
        let row=CaelumCompanionItemRecord(new("CaelumCompanionItemRecord"));row.Item=item;Items.Push(row);return row;
    }

    void Suspend()
    {
        if(Body==null || Parked)return;
        if(Body.health<=0)CaelumCorpseArchive.Recall(Body);
        SourceMap=level.MapName;Position=Body.Pos;Facing=Body.Angle;OriginalTID=Body.TID;
        Invisible=Body.bInvisible;Solid=Body.bSolid;Shootable=Body.bShootable;
        NoInteraction=Body.bNoInteraction;NoBlock=Body.bNoBlockmap;NoSector=Body.bNoSector;
        CaelumContaminationAbsence.Capture(Body,Leader());
        Body.bInvisible=true;Body.bSolid=false;Body.bShootable=false;Body.bNoInteraction=true;
        Body.A_ChangeLinkFlags(1,1);Body.Vel=(0,0,0);Body.A_StopAllSounds();
        Body.target=null;Body.LastEnemy=null;Body.ChangeTID(0);Parked=true;
    }

    bool Resume(vector3 point)
    {
        if(Body==null || !Parked)return Body!=null;
        if(Body.health>0)
        {
            let probe=Actor.Spawn("CaelumSummoningProbe",point,NO_REPLACE);
            if(probe==null)return false;
            probe.A_SetSize(Body.Radius,Body.Height);bool fits=probe.TestMobjLocation();probe.Destroy();
            if(!fits)return false;
        }
        Body.SetOrigin(point,false);Body.FindFloorCeiling();Body.ClearInterpolation();
        Body.ResetMaintenanceForTravel();Body.Angle=Facing;
        Body.bInvisible=Invisible;Body.bSolid=Solid;Body.bShootable=Shootable;Body.bNoInteraction=NoInteraction;
        Body.A_ChangeLinkFlags(NoBlock?1:0,NoSector?1:0);
        Body.ChangeStatNum(Thinker.STAT_DEFAULT);
        for(Inventory item=Body.Inv;item!=null;item=item.Inv)
        {item.ChangeStatNum(Thinker.STAT_INVENTORY);item.SetOrigin(point,false);}
        if(SourceMap==level.MapName)Body.ChangeTID(OriginalTID);
        Parked=false;TravelPending=false;SourceMap=level.MapName;
        // La proteccion de la mansion no se exporta a la campana.
        let resident=CaelumAnchoredResident(Body);
        if(resident!=null)
        {
            Body.bBuddha=resident.IsProtectedStoryResident();
            if(!resident.IsProtectedStoryResident())Body.bInvulnerable=false;
            if(resident.IsEscortPrisoner() && level.MapName=="MAP03")
            {resident.MarkEscortPrisonerExtracted(Leader());resident.EscortPrisonerPort=true;}
        }
        let world=CaelumMainM00QuestController(EventHandler.Find("CaelumMainM00QuestController"));
        if(world!=null && resident!=null)world.RegisterResident(resident);
        let port=CaelumSiegeEvents(EventHandler.Find("CaelumSiegeEvents"));
        if(port!=null && resident!=null)port.RegisterPortPerson(resident);
        CaelumContaminationAbsence.Restore(Body,Leader());Reconcile();return true;
    }
}

class CaelumCompanionParty : Inventory
{
    int Revision,MaintenanceTic;
    Array<CaelumCompanionBond> Roster;
    CaelumFormation Formation;

    static CaelumCompanionParty Get(CaelumPlayer user,bool create=false)
    {
        if(user==null)return null;
        let party=CaelumCompanionParty(user.FindInventory("CaelumCompanionParty"));
        if(party==null && create)party=CaelumCompanionParty(user.GiveInventoryType("CaelumCompanionParty"));
        if(party!=null && party.Revision<CaelumCompanionData.REVISION)party.Revision=CaelumCompanionData.REVISION;
        return party;
    }

    int Occupied()
    {
        int count=1;
        for(int i=0;i<Roster.Size();i++)if(Roster[i].Enlisted && !Roster[i].SlotReleased)count++;
        return count;
    }

    CaelumCompanionBond Find(int identity)
    {for(int i=0;i<Roster.Size();i++)if(Roster[i].Identity==identity)return Roster[i];return null;}

    void EnsureFormation()
    {
        if(Formation==null){Formation=new("CaelumFormation");Formation.SetPlayerLeader(CaelumPlayer(Owner));}
        Formation.PlayerLeader=CaelumPlayer(Owner);
    }

    bool Recruit(CaelumCombatActor body)
    {
        let user=CaelumPlayer(Owner);
        if(!CaelumCompanions.CanRecruit(user,body))return false;
        for(int i=0;i<Roster.Size();i++)Roster[i].Reconcile();
        let bond=body.Companion;
        if(bond!=null && bond.Enlisted && bond.Party==self)return SetOrder(bond,CaelumCompanionData.FOLLOW);
        if(Occupied()>=CaelumFormationData.PARTY_CAPACITY)return false;
        if(bond==null)
        {
            int identity=CaelumCompanions.Identity(body);
            if(Find(identity)!=null || Roster.Size()>=CaelumCompanionData.ROSTER_COUNT)return false;
            bond=new("CaelumCompanionBond");bond.Identity=identity;bond.Body=body;bond.Party=self;
            bond.Revision=CaelumCompanionData.REVISION;Roster.Push(bond);body.Companion=bond;
        }
        if(bond.Party!=self)return false;
        if(bond.Loadout==null){bond.Loadout=new("CaelumCompanionLoadout");bond.Loadout.Initialize(body);}
        bond.Enlisted=true;bond.SlotReleased=false;bond.SourceMap=level.MapName;
        body.bFriendly=true;body.SetFriendPlayer(user.player);body.master=user;
        if(body.Formation!=null)body.Formation.Group.Remove(body.Formation);
        return SetOrder(bond,CaelumCompanionData.FOLLOW);
    }

    bool SetOrder(CaelumCompanionBond bond,int order)
    {
        if(bond==null || bond.Party!=self || bond.Body==null || bond.Body.health<=0 || bond.Parked)return false;
        if(order<CaelumCompanionData.FOLLOW || order>CaelumCompanionData.DISMISSED)return false;
        if(order!=CaelumCompanionData.DISMISSED && !bond.Enlisted)return false;
        bond.Order=order;
        if(order==CaelumCompanionData.DISMISSED)bond.Enlisted=false;
        bond.Position=bond.Body.Pos;bond.Facing=bond.Body.Angle;bond.SourceMap=level.MapName;
        if(bond.Body.Formation!=null)bond.Body.Formation.Group.Remove(bond.Body.Formation);
        if(order==CaelumCompanionData.FOLLOW)
        {EnsureFormation();Formation.Add(bond.Body,CaelumFormation.RoleFor(bond.Body),0);}
        bond.Body.target=null;bond.Body.LastEnemy=null;bond.Body.Vel.X=0;bond.Body.Vel.Y=0;
        return true;
    }

    void PlaceWaiting()
    {
        let user=CaelumPlayer(Owner);if(user==null)return;
        for(int i=0;i<Roster.Size();i++)
        {
            let bond=Roster[i];bond.Reconcile();if(!bond.Parked || bond.Body==null)continue;
            bool follows=bond.Enlisted && bond.Order==CaelumCompanionData.FOLLOW && bond.Body.health>0;
            if(follows)
            {
                // Solo la transicion entre mapas admite colocacion junto al lider.
                double radius=user.Radius+bond.Body.Radius+CaelumPhysicsUnits.MapUnits(CaelumFormationData.CLEARANCE_METERS);
                let place=CaelumSummoning.FindPlace(user,user.Pos,radius*CaelumFormationData.PARTY_CAPACITY,bond.Body.Radius,bond.Body.Height);
                if(place.Found && bond.Resume(place.Point))SetOrder(bond,CaelumCompanionData.FOLLOW);
            }
            else if(bond.SourceMap==level.MapName)bond.Resume(bond.Position);
        }
    }

    override void Tick()
    {
        Super.Tick();
        if(++MaintenanceTic<TICRATE)return;MaintenanceTic=0;
        PlaceWaiting();
    }

    override void PreTravelled()
    {
        for(int i=0;i<Roster.Size();i++)
        {
            let bond=Roster[i];if(bond.Body==null)continue;
            bond.Reconcile();bond.Suspend();bond.TravelPending=true;
            let body=bond.Body;
            if(body.Formation!=null)body.Formation.Group.Remove(body.Formation);
            if(body.RecoveryGoal!=null){body.RecoveryGoal.Destroy();body.RecoveryGoal=null;}
            CaelumDemonService.StopBreath(body,false,false);
            let defender=CaelumPortDefender(body);
            if(defender!=null)
            {
                defender.Port=null;defender.Gun=null;defender.HomeDoor=null;defender.CityNavigation=null;
                if(defender.NavigationTarget!=null){defender.NavigationTarget.Destroy();defender.NavigationTarget=null;}
                defender.YieldFor=null;
            }
            let resident=CaelumAnchoredResident(body);
            if(resident!=null && resident.EscortControl!=null)
            {resident.EscortControl.ClearTrail();resident.EscortControl.Path=null;}
            if(body.SiegeCombatant!=null)
            {body.SiegeCombatant.Exited=true;body.SiegeCombatant=null;}
            body.VisualEvidence=null;
            body.ChangeStatNum(STAT_TRAVELLING);
            for(Inventory item=body.Inv;item!=null;item=item.Inv)
            {item.UnlinkFromWorld();item.ChangeStatNum(STAT_TRAVELLING);}
        }
        Formation=null;
    }

    override void Travelled()
    {
        for(int i=0;i<Roster.Size();i++)
        {
            let bond=Roster[i];if(bond.Body==null || !bond.TravelPending)continue;
            // Retirar los viajeros antes de la limpieza nativa, incluso muertos.
            bond.Body.ChangeStatNum(CaelumHouseResidents.PARKED_STAT);
            bond.Body.SetOrigin(Owner.Pos,false);bond.Body.FindFloorCeiling();
            for(Inventory item=bond.Body.Inv;item!=null;item=item.Inv)
            {item.ChangeStatNum(CaelumHouseResidents.PARKED_STAT);item.SetOrigin(Owner.Pos,false);}
        }
        PlaceWaiting();
    }
    Default { Inventory.MaxAmount 1; Inventory.InterHubAmount 1; +INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE }
    States { Spawn: TNT1 A -1; Stop; }
}

class CaelumCompanions : Object play
{
    static bool Dialogue(CaelumPlayer user,CaelumCombatActor body)
    {
        if(!CaelumCompanionSession.Reach(user,body) || !CaelumUseGeometry.AimedAt(user,body))return false;
        if((user.player.cmd.buttons&BT_USE)==0 || user.FolkloreInteractionUseLatched)return true;
        user.FolkloreInteractionUseLatched=true;user.FolkloreInteractionReleaseGuardTics=0;
        Level.ExecuteSpecial(CaelumConstants.GZDOOM_THING_SET_CONVERSATION_SPECIAL,
            body,null,false,0,CaelumCompanionData.CONVERSATION_ID);
        return body.HasConversation() && body.StartConversation(user,true,true);
    }

    static int Identity(CaelumCombatActor body)
    {
        if(body is "CaelumCompanionSubcaptain")return 8;
        let resident=CaelumAnchoredResident(body);if(resident==null)return -1;
        if(resident.IsEscortPrisoner())return 4+resident.EscortPrisonerId;
        return resident.StoryAnchored ? CaelumMainM00SocialDialogue.GetResidentId(body) : -1;
    }

    static bool Superseded(CaelumCombatActor body)
    {
        int identity=Identity(body);if(identity<0)return false;
        for(int n=0;n<MAXPLAYERS;n++)
        {
            if(!playeringame[n])continue;
            let party=CaelumCompanionParty.Get(CaelumPlayer(players[n].mo));if(party==null)continue;
            let bond=party.Find(identity);
            if(bond!=null && bond.Body!=null && bond.Body!=body)return true;
        }
        return false;
    }

    static bool CanRecruit(CaelumPlayer user,CaelumCombatActor body)
    {
        if(!CaelumPlayerAuthority.CanMutate(user) || body==null || body.health<=0 || Identity(body)<0)return false;
        if(body.Companion!=null && body.Companion.Party.Owner!=user)return false;
        let resident=CaelumAnchoredResident(body);
        if(resident!=null)
        {
            if(resident.RuloPartyMode!=0 || resident.FactionHostilityActive || resident.TheftTarget!=null)return false;
            if(resident.IsEscortPrisoner())
            {
                int state=user.GetPrisonerRescueState(resident.EscortPrisonerId);
                return state==CaelumConstants.PRISONER_STATE_FOLLOWING || state==CaelumConstants.PRISONER_STATE_EXTRACTED;
            }
            return level.MapName=="MAP01" || body.Companion!=null;
        }
        return body is "CaelumCompanionSubcaptain";
    }

    static bool Controlled(CaelumCombatActor body)
    {
        let bond=body!=null ? body.Companion : null;
        if(bond==null || bond.Parked || body.health<=0)return false;
        let resident=CaelumAnchoredResident(body);
        if(resident!=null && (resident.RuloPartyMode!=0 || resident.FactionHostilityActive))return false;
        // Despedir no cancela la mision de escolta anterior.
        if(!bond.Enlisted && resident!=null && resident.IsEscortPrisoner() && !resident.EscortPrisonerPort)return false;
        return true;
    }

    static bool Pulse(CaelumCombatActor body)
    {
        if(!Controlled(body))return false;
        let bond=body.Companion;
        if(bond.PulseReady && bond.PulseTic==level.time)return true;
        bond.PulseReady=true;bond.PulseTic=level.time;
        if(body.ForcedSleepTics>0 || body.CombatLucidityPhysicalStunRemaining>0 || body.bInConversation
            || CaelumBolas.Restrained(body) || CaelumTelekinesisRules.Held(body))
        {if(body.bInConversation && bond.Motion!=null)bond.Motion.Hold(body);return true;}
        Actor enemy=CaelumVisualPerception.Acquire(body,body.target);
        if(enemy!=null)
        {
            if(bond.Motion!=null)bond.Motion.Yield(body);
            body.target=enemy;
            if(body.Formation!=null && body.Formation.Group.RegroupCombat(body.Formation,enemy))return true;
            if(bond.Loadout!=null && bond.Loadout.ManualWeapon)
            {
                if(!bond.Loadout.TryAttack())body.ThermalChase(null,null);
                return true;
            }
            let resident=CaelumAnchoredResident(body);
            if(resident!=null && resident.ResidentTools!=null && resident.ResidentTools.TryStart())return true;
            body.ThermalChase();return true;
        }
        // Seguir/esperar son ordenes explicitas: una pista anonima conserva
        // la alerta, pero no arrastra al grupo tras sus propios pasos.
        // Un enemigo identificado conserva su busqueda y posicion recordada.
        let memory=CaelumVisualPerception.Evidence(body).GetMemory();memory.ChooseFocus(body);
        body.target=memory.HasFocus(body) ? CaelumVisualPerception.SearchGoal(body) : null;
        if(body.target!=null){if(bond.Motion!=null)bond.Motion.Yield(body);body.ThermalChase();return true;}
        if(bond.Enlisted && bond.Order==CaelumCompanionData.FOLLOW)
        {
            bond.Party.EnsureFormation();
            if(body.Formation==null)bond.Party.Formation.Add(body,CaelumFormation.RoleFor(body),0);
            if(body.Formation!=null)
            {
                if(bond.Motion==null)bond.Motion=new("CaelumCompanionMotion");
                bond.Motion.Step(body);
            }
        }
        else {if(bond.Motion==null)bond.Motion=new("CaelumCompanionMotion");bond.Motion.Hold(body);}
        return true;
    }
}

// El reloj de locomocion es independiente de los cuadros de animacion.
// Se reutilizan colision, aceleracion y rutas locales de la escolta aceptada.
class CaelumCompanionMotion : Object play
{
    CaelumPrisonerEscort Walker;
    String SourceMap;
    bool Direct;
    bool Running;
    int RouteTic;
    bool MansionRoute;
    int MansionNode,MansionEnd;

    void Ensure()
    {
        if(Walker==null || SourceMap!=level.MapName)
        {Walker=new("CaelumPrisonerEscort");SourceMap=level.MapName;Direct=false;RouteTic=0;MansionRoute=false;Running=false;}
    }
    void Hold(CaelumCombatActor body){Ensure();body.CombatAirSpending=false;Walker.Hold(body);}
    void Yield(CaelumCombatActor body)
    {
        Ensure();Running=false;body.CombatAirSpending=false;Walker.Yield(body);
        if(Pose(body))body.SetStateLabel("See");
    }
    static bool Pose(CaelumCombatActor body)
    {
        return body.InStateSequence(body.CurState,body.FindState("CompanionWalk"))
            || body.InStateSequence(body.CurState,body.FindState("CompanionIdle"));
    }
    static void Tick(CaelumCombatActor body)
    {
        if(!CaelumCompanions.Controlled(body))return;
        // No adelantar preparaciones, dolor, recargas ni acciones de herramientas.
        bool ordinary=Pose(body) || (body.target==null && (body.InStateSequence(body.CurState,body.SpawnState)
            || body.InStateSequence(body.CurState,body.SeeState)
            || body.InStateSequence(body.CurState,body.FindState("IdleBreathing"))
            || body.InStateSequence(body.CurState,body.FindState("EscortFollow"))
            || body.InStateSequence(body.CurState,body.FindState("EscortIdle"))));
        if(ordinary)CaelumCompanions.Pulse(body);
    }
    static bool OpenBlockedDoor(Actor body)
    {
        let blocker=CaelumSlidingDoorBlocker(body.BlockingMobj);
        if(blocker!=null && blocker.master!=null)
        {let leaf=CaelumSlidingDoorLeaf(blocker.master);return leaf!=null && leaf.RequestDoorGroup(body);}
        let line=body.MovementBlockingLine!=null ? body.MovementBlockingLine : body.BlockingLine;
        if(line==null || line.special!=7)return false;
        let doors=CaelumPolyDoorEvents.Get();int id=line.args[0];
        if(doors==null || id<=0 || id>=doors.Leaves.Size())return false;
        let leaf=doors.Leaves[id];if(leaf==null || !leaf.NativeDoorCollision())return false;
        for(int face=0;face<leaf.NativeFaces.Size();face++)
            if(leaf.NativeFaces[face]==line)return leaf.RequestDoorGroup(body);
        return false;
    }
    bool MansionGoal(CaelumCombatActor body,CaelumPlayer leader)
    {
        if(level.MapName!="MAP01"){MansionRoute=false;return false;}
        if(!MansionRoute && Abs(body.FloorZ-leader.FloorZ)<=body.MaxStepHeight)return false;
        if(level.time>=RouteTic || !MansionRoute)
        {
            // Los nodos ya recorridos por Palomo conectan ambas escaleras.
            // Se consultan quince puntos de datos, nunca actores del mapa.
            int first=-1,last=-1;double from=1e30,to=1e30,fromHeight=1e30,toHeight=1e30;
            for(int i=1;i<=14;i++)
            {
                vector3 point=CaelumPalomo.GetDepartureWaypoint(i);
                double h=Abs(body.Pos.Z-point.Z),d=(body.Pos.XY-point.XY).Length();
                if(h<fromHeight || (h==fromHeight && d<from)){first=i;from=d;fromHeight=h;}
                h=Abs(leader.Pos.Z-point.Z);d=(leader.Pos.XY-point.XY).Length();
                if(h<toHeight || (h==toHeight && d<to)){last=i;to=d;toHeight=h;}
            }
            RouteTic=level.time+CaelumConstants.PRISONER_WALK_STATE_TICS;
            if(!MansionRoute || MansionEnd!=last)
            {
                // Incorporarse al tramo por delante: quien ya baja una
                // escalera no debe volver al rellano superior para tomarla.
                if(first!=last)
                {
                    int ahead=first+(last>first?1:-1);
                    vector3 start=CaelumPalomo.GetDepartureWaypoint(first);
                    vector3 span=CaelumPalomo.GetDepartureWaypoint(ahead)-start;
                    double along=((body.Pos-start) dot span)/(span dot span);
                    if(along>0 && along<=1 && (body.Pos-(start+span*along)).Length()<=body.Radius*2)first=ahead;
                }
                MansionNode=first;MansionEnd=last;MansionRoute=true;Walker.Path=null;
            }
        }
        return MansionRoute;
    }
    void Step(CaelumCombatActor body)
    {
        Ensure();let leader=body.Companion.Leader();if(leader==null)return;
        Walker.Observe(body,leader);
        double distance=body.Distance3D(leader);
        if(distance>CaelumPhysicsUnits.MapUnits(CaelumCompanionData.RUN_DISTANCE_METERS))Running=true;
        else if(distance<=CaelumPhysicsUnits.MapUnits(CaelumCompanionData.WALK_DISTANCE_METERS))Running=false;
        double cost=body.GetEffectiveAttackAir(CaelumConstants.RUN_AIR_COST_PER_SECOND)/TICRATE;
        if(body.CurrentCombatAir<=body.MaximumCombatAir*CaelumConstants.AIR_BREATHLESS_THRESHOLD
            || body.CurrentCombatAir<cost*CaelumThermalEffects.HeatCost(body)*CaelumAltitudeService.Effort(body))Running=false;
        double speed=Walker.WalkingSpeed(body);
        if(Running)speed*=CaelumConstants.GZDOOM_BASE_MAX_RUN_SPEED/CaelumConstants.GZDOOM_BASE_MAX_WALK_SPEED;
        if(speed<=0 || Walker.Immobilized(body)){Hold(body);return;}
        if(Walker.GiveWay(body,leader,speed))
        {
            body.CombatAirSpending=Running && body.Vel.XY.Length()>0;
            if(body.CombatAirSpending)body.TrySpendCombatAir(cost);
            return;
        }
        if(MansionGoal(body,leader))
        {
            vector3 point=CaelumPalomo.GetDepartureWaypoint(MansionNode);
            bool reached=(point.XY-body.Pos.XY).Length()<=Max(speed,body.Radius/2);
            if(!reached && MansionNode!=MansionEnd && (point.XY-body.Pos.XY).Length()<=body.Radius*2)
            {
                vector3 nextPoint=CaelumPalomo.GetDepartureWaypoint(MansionNode+(MansionEnd>MansionNode?1:-1));
                reached=Walker.ClearSegment(body,nextPoint,0,true);
            }
            if(reached
                && Abs(point.Z-body.FloorZ)<=body.MaxStepHeight)
            {
                if(MansionNode==MansionEnd){MansionRoute=false;Walker.ClearTrail();Walker.PushTrail(leader.Pos);Walker.Path=null;}
                else{MansionNode+=MansionEnd>MansionNode?1:-1;Walker.Path=null;}
            }
            if(MansionRoute)
            {
                point=CaelumPalomo.GetDepartureWaypoint(MansionNode);
                Navigate(body,point,speed);return;
            }
        }
        let group=body.Formation.Group;group.Refresh();group.RecoverShape();
        vector3 slot=group.Destination(body.Formation);
        bool sameFloor=Abs(slot.Z-body.FloorZ)<=body.MaxStepHeight;
        if(level.time>=RouteTic)
        {
            RouteTic=level.time+CaelumConstants.PRISONER_WALK_STATE_TICS;
            Direct=sameFloor && (slot.XY-body.Pos.XY).Length()<=CaelumConstants.PRISONER_FOLLOW_TELEPORT_DISTANCE
                && Walker.ClearSegment(body,slot,0,true);
            if(Direct){Walker.ClearTrail();Walker.PushTrail(leader.Pos);Walker.Path=null;}
        }
        if(Direct && sameFloor)
        {
            if((slot.XY-body.Pos.XY).Length()<=speed){Hold(body);return;}
            if(Move(body,slot.XY,speed))return;
            Direct=false;RouteTic=level.time+TICRATE;
            if(body.MovementBlockingLine!=null || body.BlockingLine!=null)
            {group.SingleFile=true;group.LayoutDirty=true;group.RecoveryProbeReady=false;}
        }
        if(Walker.TrailSize()==0)Walker.PushTrail(leader.Pos);
        vector3 goal=Walker.TrailPoint(0);
        while(Walker.TrailSize()>1 && (goal.XY-body.Pos.XY).Length()<=Max(speed,body.Radius/2)
            && Abs(goal.Z-body.FloorZ)<=body.MaxStepHeight)
        {Walker.PopTrail();Walker.Path=null;goal=Walker.TrailPoint(0);}
        if(Walker.TrailSize()==1 && sameFloor)goal=slot;
        vector2 destination=goal.XY;
        if(Walker.Path!=null)destination=Walker.Path.Next(body,goal);
        if((goal.XY-body.Pos.XY).Length()<=speed && Abs(goal.Z-body.FloorZ)<=body.MaxStepHeight)
        {Hold(body);return;}
        if(!Move(body,destination,speed))
        {
            if(Walker.Path==null)Walker.Path=new("CaelumEscortNavigation");
            Walker.Path.AllowLateralEscape=Walker.LeaderIntendsMove || Walker.TrailSize()>1;
            if(level.time>=Walker.Path.RetryTic)Walker.Path.Build(body,goal);
            Hold(body);
        }
    }
    bool Move(CaelumCombatActor body,vector2 point,double speed)
    {
        if(!Walker.MoveTowards(body,point,speed,-1)){OpenBlockedDoor(body);return false;}
        body.CombatAirSpending=Running;
        if(Running)body.TrySpendCombatAir(body.GetEffectiveAttackAir(CaelumConstants.RUN_AIR_COST_PER_SECOND)/TICRATE);
        return true;
    }
    void Navigate(CaelumCombatActor body,vector3 point,double speed)
    {
        vector2 next=Walker.Path!=null ? Walker.Path.Next(body,point) : point.XY;
        if(Move(body,next,speed))return;
        if(Walker.Path==null)Walker.Path=new("CaelumEscortNavigation");
        Walker.Path.AllowLateralEscape=true;
        if(level.time>=Walker.Path.RetryTic)Walker.Path.Build(body,point);
        Hold(body);
    }
}

class CaelumCompanionSubcaptain : CaelumPortDefender
{
    override int BirthAttribute(){return CaelumCompanionData.SUBCAPTAIN_ATTRIBUTE;}
    override bool Used(Actor user){return CaelumCompanions.Dialogue(CaelumPlayer(user),self);}
    Default { Tag "$CA_COMPANION_SUBCAPTAIN"; }
    States { ResidentToolUse: DOMI K 1; Loop;
        CompanionWalk: DOWK AB 4; Loop;
        CompanionIdle: DOID A -1; Stop; }
}

// La administracion usa el mismo inventario nativo y conserva instancias completas.
class CaelumCompanionSession : Inventory
{
    bool Open,PlayerItems;
    CaelumCombatActor Subject;
    int Selection;
    String Status;
    Array<Inventory> Rows;
    Array<String> Labels;

    static CaelumCompanionSession Find(CaelumPlayer user)
    {return user==null ? null : CaelumCompanionSession(user.FindInventory("CaelumCompanionSession"));}

    static bool Reach(CaelumPlayer user,CaelumCombatActor body)
    {
        return CaelumPlayerAuthority.CanMutate(user) && user.health>0 && body!=null && body.health>0
            && (body.Companion==null || !body.Companion.Parked) && body.ForcedSleepTics<=0
            && body.CombatLucidityPhysicalStunRemaining<=0
            && user.Distance3D(body)<=CaelumConstants.PALOMO_MERCHANT_SESSION_DISTANCE && user.CheckSight(body);
    }

    static bool Show(CaelumPlayer user,CaelumCombatActor body)
    {
        if(!Reach(user,body) || CaelumCompanions.Identity(body)<0)return false;
        let session=Find(user);
        if(session==null)session=CaelumCompanionSession(user.GiveInventoryType("CaelumCompanionSession"));
        if(session==null)return false;
        user.EquipmentMenuOpen=false;user.ClosePalomoMerchant();user.CloseCraftingStationSession();
        session.Subject=body;session.Open=true;session.PlayerItems=false;session.Selection=0;session.Status="";
        session.Refresh();return true;
    }

    bool Allowed(Inventory item,bool giving)
    {
        let user=CaelumPlayer(Owner);
        if(item==null || item.Amount<=0 || user.GetFormalInventoryEntryKind(item)<0
            || item is "CaelumMagicBox" || item is "CaelumTarotDeck" || item is "CaelumChestCargo"
            || CaelumWaterBoiling.Locked(item))return false;
        let equipment=CaelumEquipmentItem(item);
        if(equipment!=null && ((giving && equipment.Equipped) || equipment.IsLimboTemporary()
            || equipment.IsLimboFirstWeapon() || (giving && user.IsEquipmentItemCraftingLocked(equipment.ItemId))))return false;
        let special=CaelumSpecialInventoryItem(item);
        if(giving && special!=null && (special.LimboQuestUnits>0
            || (special.GetSpecialCategory()==CaelumConstants.EQUIPMENT_KIND_MATERIAL
                && user.GetReservedCraftingMaterialUnits(special.GetSpecialType(),special.GetSpecialTier())>0)))return false;
        return true;
    }

    void Refresh()
    {
        Rows.Clear();Labels.Clear();let user=CaelumPlayer(Owner);
        if(!Open || !Reach(user,Subject)){Open=false;return;}
        Actor source=PlayerItems ? Actor(user) : Actor(Subject);
        if(Subject.Companion!=null && Subject.Companion.Loadout!=null)Subject.Companion.Loadout.Sync();
        for(Inventory item=source.Inv;item!=null;item=item.Inv)
        {
            if(!Allowed(item,PlayerItems))continue;
            Rows.Push(item);
            String label=CaelumNotifications.Describe(user,item,item.Amount,true);
            let equipment=CaelumEquipmentItem(item);
            if(equipment!=null && equipment.Equipped)
                label=String.Format("%s [%s]",label,StringTable.Localize("CA_COMPANION_EQUIPPED",false));
            Labels.Push(label);
        }
        Selection=Clamp(Selection,0,Max(0,Rows.Size()-1));
    }

    int NarrativeStage()
    {
        let user=CaelumPlayer(Owner);let record=user.GetPersistentCharacterState(false);
        if(record==null)return 0;
        let resident=CaelumAnchoredResident(Subject);
        if(resident!=null && resident.IsEscortPrisoner())return CaelumPortSocial.Stage(record,resident.EscortPrisonerId);
        return record.QuestStage[CaelumConstants.QUEST_MAIN_M00_THE_FOOL];
    }

    int Chance(CaelumCompanionBond bond)
    {
        let user=CaelumPlayer(Owner);
        if(user.Attributes==null || user.DerivedStats==null)return 0;
        double ability=user.DerivedStats.CalculateType4Percent(user.Attributes.Charisma);
        ability=CaelumSocialization.Persuasion(user,ability);
        int faction=CaelumCommunication.Faction(Subject);let record=user.GetPersistentCharacterState(false);
        int reputation=record!=null && faction>=0 ? record.FactionReputation[faction] : 0;
        return Clamp(int(Floor(ability*100/CaelumCompanionData.SOCIAL_DIFFICULTY
            *CaelumPortSocialData.ReputationFactor(reputation)*(1+bond.Trust/100)+0.5)),0,100);
    }

    bool Transfer(Inventory item,bool loan)
    {
        let user=CaelumPlayer(Owner);let bond=Subject!=null ? Subject.Companion : null;
        if(!Reach(user,Subject) || bond==null || bond.Party.Owner!=user || !bond.Enlisted
            || !Allowed(item,PlayerItems))return false;
        Actor source=PlayerItems ? Actor(user) : Actor(Subject);
        Actor destination=PlayerItems ? Actor(Subject) : Actor(user);
        if(item.Owner!=source)return false;
        let equipment=CaelumEquipmentItem(item);
        if(!PlayerItems && equipment!=null && equipment.Equipped
            && (bond.Loadout==null || !bond.Loadout.CanChange()))return false;
        double weight=CaelumContainerRules.Weight(user,item);
        if(PlayerItems)
        {
            double capacity=Subject.Mass*Subject.CalculateActorType4Percent(Subject.CombatStrength)/100;
            if(Subject.GetAttackCarriedWeight()+weight>capacity)return false;
        }
        else
        {
            user.RefreshCarriedInventorySummary();if(!user.CanAddWeightToPersonalInventory(weight))return false;
        }
        let provenance=CaelumCompanionProvenance.View(item,bond);
        if(!PlayerItems && !provenance.IsLoan())
        {
            int stage=NarrativeStage();
            if(provenance.Refused(bond.Trust,stage))
            {Status="CA_COMPANION_REFUSED";return false;}
            int chance=Chance(bond);
            if(chance<=0 || (chance<100 && Random[CaelumCompanionConsent](1,100)>chance))
            {provenance.Consent(true,bond.Trust,stage);Status="CA_COMPANION_REFUSED";return false;}
            provenance.Consent(false,bond.Trust,stage);
        }
        if(!PlayerItems && equipment!=null && equipment.Equipped && !bond.Loadout.Unequip(equipment))return false;
        CaelumFoodInventory.Reconcile(item);
        double value=CaelumEconomyRules.GetInventoryStackBaseValue(item);
        source.RemoveInventory(item);item.AttachToOwner(destination);
        CaelumContainerRules.SetBoxed(item,false);CaelumFoodInventory.Relocate(item);
        if(PlayerItems)
        {
            bond.Trust=Min(CaelumCompanionData.MAX_TRUST,bond.Trust
                +provenance.Gift(loan,value)/CaelumCompanionData.TRUST_VALUE);
        }
        if(!PlayerItems && equipment!=null)user.EnsureEquipmentItemId(equipment);
        let maintenance=Subject.GetActorMaintenance();if(maintenance!=null)maintenance.WeightReady=false;
        user.OnNativeInventoryChanged();user.RefreshFormalInventorySnapshot();user.PersistCharacterState();
        return true;
    }

    void Act(int choice)
    {
        let user=CaelumPlayer(Owner);
        if(!Open || !Reach(user,Subject)){Open=false;return;}
        if(choice==0){Open=false;return;}
        Status="";let party=CaelumCompanionParty.Get(user,true);bool ok=false;
        if(choice==1)ok=party.Recruit(Subject);
        else if(choice==2 || choice==3 || choice==4)ok=party.SetOrder(Subject.Companion,choice-2);
        else if(choice==5 && Subject.Companion!=null && Subject.Companion.Party==party && Subject.Companion.Enlisted)
        {party.EnsureFormation();party.Formation.SetShape((party.Formation.Shape+1)%4);ok=true;}
        else if(choice==6){PlayerItems=!PlayerItems;Selection=0;ok=true;}
        else if(choice==7 || choice==8)
        {
            Inventory selected=Selection>=0 && Selection<Rows.Size() ? Rows[Selection] : null;
            ok=Transfer(selected,choice==8);
        }
        else if(choice==9 || choice==10){Selection+=choice==9 ? -1 : 1;ok=true;}
        else if(choice==11 && !PlayerItems && Subject.Companion!=null && Subject.Companion.Party==party
            && Subject.Companion.Loadout!=null && Selection>=0 && Selection<Rows.Size())
            ok=Subject.Companion.Loadout.Toggle(CaelumEquipmentItem(Rows[Selection]));
        if(Status=="")Status=ok ? "CA_COMPANION_DONE" : "CA_COMPANION_REJECTED";
        Refresh();
    }

    override void Tick(){Super.Tick();if(Open && !Reach(CaelumPlayer(Owner),Subject))Open=false;}
    override void PreTravelled(){Open=false;Subject=null;Rows.Clear();Labels.Clear();Super.PreTravelled();}
    Default { Inventory.MaxAmount 1; +INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE }
    States { Spawn: TNT1 A -1; Stop; }
}

class CaelumCompanionOpenAction : CaelumPalomoDialogueAction
{
    override bool Use(bool pickup)
    {
        let user=CaelumPlayer(Owner);
        if(user==null || user.player==null || !user.HasActiveConversation())return false;
        return CaelumCompanionSession.Show(user,CaelumCombatActor(user.player.ConversationNPC));
    }
}
