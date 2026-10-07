// #16: el comandante tiene identidad y derrota propias. Los campos heredados
// de navegación conservan el esquema del Zupay aceptado en las alcantarillas.
class CaelumPortCommander : CaelumZupayColossus
{
    override bool IsSewerBoss() { return false; }

    override bool IsRetreatBoss()
    {
        return SiegeCombatant != null && SiegeCombatant.Encounter != null
            && SiegeCombatant.Encounter.Boss == SiegeCombatant
            && SiegeCombatant.ExitNode != null;
    }

    override vector3 EscapePosition()
    {
        if (IsRetreatBoss()) return SiegeCombatant.ExitNode.Pos;
        return Pos;
    }

    override double EscapeReach()
    {
        return IsRetreatBoss() ? SiegeCombatant.ExitNode.Radius : 0;
    }

    override bool ReachedEscape()
    {
        if (!IsRetreatBoss()) return false;
        let entry = SiegeCombatant;
        if (!entry.ExitNode.IsExit)
        {
            if (entry.ExitNode.NextNode != null) entry.ExitNode = entry.ExitNode.NextNode;
            return false;
        }
        entry.Encounter.ConfirmBossRetreat(entry);
        return entry.Exited;
    }
}

// Controlador local guardado con MAP06. No recrea población al cargar el hub.
class CaelumPortSiege : CaelumSiegeEncounter
{
    Array<CaelumPortDefender> Defenders;
    Array<CaelumCannon> Guns;
    Array<CaelumBreakableGate> Gates;
    Array<CaelumSiegeRouteNode> Exits;
    Actor AttackingTarget[6];
    Actor DefendingTarget[6];
    int SetupRevision, SetupTick, Groups;
    int TargetingRevision;
    bool CommandDirty, Aftermath;
    bool HighDensity;
    Array<Actor> TargetCandidates;
    int CandidateTic;
    bool CandidatesValid;

    static CaelumPortSiege Get()
    { return CaelumPortSiege(ThinkerIterator.Create("CaelumPortSiege").Next()); }

    CaelumSiegeCombatant AddDemon(vector3 position, int lane)
    {
        let body=CaelumMandinga(Spawn("CaelumMandinga",position,NO_REPLACE));
        let entry=RegisterAttacker(body);
        if(entry!=null){entry.Lane=lane;entry.ExitNode=Exits[lane];}
        return entry;
    }

    void Deploy()
    {
        // La revisión se confirma una vez, antes del sellado y activación.
        for(int lane=0;lane<6;lane++)
        {
            double x=CaelumPortData.GateX(lane);
            let exitNode=CaelumSiegeRouteNode(Spawn("CaelumSiegeRouteNode",(x,CaelumPortData.ExitY(),0)));
            exitNode.IsExit=true;exitNode.A_SetSize(CaelumPortData.ROUTE_RADIUS,1);Exits.Push(exitNode);
            let gate=CaelumBreakableGate(Spawn("CaelumBreakableGate",(x,CaelumPortData.GateY(),0)));
            gate.args[1]=lane%3;gate.args[2]=1;gate.InitializeGate();Gates.Push(gate);
            let ram=CaelumBatteringRam(Spawn("CaelumBatteringRam",(x,CaelumPortData.RamY(),0)));
            ram.Angle=CaelumPortData.AttackAngle();ram.Large=lane==5;ram.InitializeRam();RegisterMachine(ram);
            for(int crew=0;crew<ram.RequiredCrew;crew++)
            {
                vector3 offset=((crew%2==0 ? -1 : 1)*CaelumRamData.TRIAL_CREW_SIDE*ram.SizeFactor,
                    ((crew/2)-(ram.RequiredCrew/2-1)/2.0)*CaelumRamData.TRIAL_CREW_STEP,0);
                let entry=AddDemon(ram.Pos+offset,lane);entry.CrewOffset=offset;ram.AssignCrew(entry);
            }
            ram.SetRoute(gate,CaelumPortData.AttackAngle());
            ram.AddRoutePoint((x,CaelumPortData.GateY()+CaelumPortData.OutsideSign()*CaelumRamData.TRIAL_CONTACT_DISTANCE*ram.SizeFactor,0));
        }
        if(CaelumPortData.IsSouth())for(int extra=0;extra<2;extra++)
        {
            let gate=CaelumBreakableGate(Spawn("CaelumBreakableGate",CaelumPortData.ExtraGate(extra)));
            gate.Angle=CaelumPortData.ExtraGateAngle(extra);gate.args[1]=1;gate.args[2]=1;
            gate.InitializeGate();Gates.Push(gate);
        }
        for(int gunIndex=0;gunIndex<CaelumPortData.GunCount();gunIndex++)
        {
            bool defending=gunIndex>=6;
            int lane=defending ? (gunIndex-6)/2 : gunIndex;
            vector3 spot=CaelumPortData.GunPosition(gunIndex);
            if(CaelumPortData.IsSouth())lane=NearestLane(spot.X);
            let gun=CaelumCannon(Spawn("CaelumCannon",spot));
            gun.Angle=CaelumPortData.GunAngle(gunIndex);gun.InitializeCannon(defending);gun.UnlimitedAmmunition=true;
            if(!defending)RegisterMachine(gun);
            Guns.Push(gun);
            for(int crew=0;crew<CaelumCannonData.CREW;crew++)
            {
                vector3 station=spot+CaelumPortData.OperatorOffset(gunIndex,crew);
                if(defending)
                {
                    let soldier=CaelumPortDefender(Spawn("CaelumPortDefender",station));
                    soldier.Port=self;soldier.Gun=gun;soldier.Station=station;soldier.Lane=lane;
                    Defenders.Push(soldier);gun.AssignOperator(soldier);
                }
                else
                {
                    let entry=AddDemon(station,lane);entry.CrewOffset=station-spot;gun.AssignOperator(entry.Body);
                }
            }
        }
        int infantry=0;
        while(Attackers.Size()<CaelumPortData.MandingaCount())
        {
            vector3 spot=CaelumPortData.FormationPosition(infantry);
            AddDemon(spot,NearestLane(spot.X));infantry++;
        }
        int guard=0;
        while(Defenders.Size()<CaelumPortData.DefenderCount())
        {
            int lane=guard%6;
            vector3 station=CaelumPortData.GuardPosition(guard);
            let soldier=CaelumPortDefender(Spawn("CaelumPortDefender",station));
            soldier.Port=self;soldier.Lane=lane;soldier.Station=station;Defenders.Push(soldier);guard++;
        }
        let commander=CaelumPortCommander(Spawn("CaelumPortCommander",CaelumPortData.BossPosition()));
        Boss=RegisterAttacker(commander);Boss.Lane=NearestLane(commander.Pos.X);Boss.ExitNode=Exits[Boss.Lane];
        SetupRevision=int(CaelumPortData.LayoutRevision());SetupTick=level.time;
        Console.Printf("PORT16 deployed Mandingas=%d commander=1 defenders=%d hostileMachines=%d guns=%d",Attackers.Size()-1,Defenders.Size(),Machines.Size(),Guns.Size());
    }

    static int NearestLane(double x)
    {
        int result=0;
        for(int lane=1;lane<6;lane++)if(Abs(x-CaelumPortData.GateX(lane))<Abs(x-CaelumPortData.GateX(result)))result=lane;
        return result;
    }

    bool ActiveEntry(CaelumSiegeCombatant entry)
    {
        return entry!=null && !entry.ConfirmedDead && !entry.Exited && !entry.Withdrawing
            && entry.Body!=null && entry.Body.health>0 && !entry.Body.bFriendly
            && !(entry==Boss && CaelumPortCommander(entry.Body).SewerFleeing);
    }

    void ElectCommands()
    {
        Groups=0;CommandDirty=false;
        for(int i=0;i<Attackers.Size();i++){Attackers[i].CommandGroup=-1;Attackers[i].CommandLeader=null;}
        Array<CaelumSiegeCombatant> queue;
        for(int seed=0;seed<Attackers.Size();seed++)
        {
            let first=Attackers[seed];
            if(!ActiveEntry(first) || first.CommandGroup>=0)continue;
            queue.Clear();queue.Push(first);first.CommandGroup=Groups;
            CaelumSiegeCombatant leader=first;
            for(int head=0;head<queue.Size();head++)
            {
                let entry=queue[head];
                if(entry.CommandPriority<leader.CommandPriority || (entry.CommandPriority==leader.CommandPriority
                    && entry.StableIdentity<leader.StableIdentity))leader=entry;
                // El límite incluye al mando. Aunque se llene la escuadra,
                // todos los miembros encolados participan en elegir su líder.
                if(queue.Size()>=CaelumPortData.COMMAND_GROUP_LIMIT)continue;
                let neighbors=BlockThingsIterator.Create(entry.Body,CaelumPortData.COMMAND_LINK_RADIUS);
                while(queue.Size()<CaelumPortData.COMMAND_GROUP_LIMIT && neighbors.Next())
                {
                    let body=CaelumCombatActor(neighbors.thing);
                    if(body==null || body.SiegeCombatant==null)continue;
                    let other=body.SiegeCombatant;
                    if(other.Encounter!=self || other.CommandGroup>=0 || !ActiveEntry(other))continue;
                    if((body.Pos-entry.Body.Pos).Length()>CaelumPortData.COMMAND_LINK_RADIUS || !entry.Body.CheckSight(body))continue;
                    other.CommandGroup=Groups;queue.Push(other);
                }
            }
            for(int i=0;i<queue.Size();i++)queue[i].CommandLeader=leader;
            Groups++;
        }
    }

    void RefreshTargets()
    {
        for(int lane=0;lane<6;lane++)
        {
            AttackingTarget[lane]=null;DefendingTarget[lane]=null;
            vector3 gate=(CaelumPortData.GateX(lane),CaelumPortData.GateY(),0);
            double best=1e30;
            for(int i=0;i<Defenders.Size();i++)
            {
                let soldier=Defenders[i];if(soldier==null || soldier.health<=0)continue;
                double distance=(soldier.Pos-gate).Length();
                if(distance<best){best=distance;AttackingTarget[lane]=soldier;}
            }
            best=1e30;
            for(int i=0;i<Attackers.Size();i++)
            {
                let entry=Attackers[i];if(!ActiveEntry(entry))continue;
                double distance=(entry.Body.Pos-gate).Length();
                if(distance<best){best=distance;DefendingTarget[lane]=entry.Body;}
            }
        }
    }

    void EnsureTargetingRevision()
    {
        if(TargetingRevision>=2)return;
        // Sólo se reconstruye la percepción derivada; se conservan las
        // identidades, los puestos, las bajas y los mandos guardados.
        ResetPerception();CommandDirty=true;
        TargetingRevision=2;
    }

    void ResetPerception()
    {
        for(int i=0;i<Attackers.Size();i++)
        {
            let entry=Attackers[i];
            entry.CombatTarget=null;entry.TargetRefreshTic=0;
            entry.SharedTarget=null;entry.SharedTargetValid=false;
            entry.NextSharedTargetTic=0;
        }
        CandidatesValid=false;TargetCandidates.Clear();
        for(int i=0;i<Guns.Size();i++)if(Guns[i]!=null)Guns[i].NextTargetQuery=0;
    }

    void RefreshDensity()
    {
        EnsureTargetingRevision();
        let population=CaelumPopulationState.Get();
        bool active=population!=null && population.HighDensity;
        if(active==HighDensity)return;
        HighDensity=active;ResetPerception();CommandDirty=true;
    }

    void RefreshCandidates()
    {
        if(CandidatesValid && CandidateTic==level.time)return;
        TargetCandidates.Clear();
        for(int p=0;p<MAXPLAYERS;p++)
        {
            let candidate=playeringame[p] ? players[p].mo : null;
            if(candidate!=null && candidate.health>0 && candidate.bShootable)
                TargetCandidates.Push(candidate);
        }
        for(int i=0;i<Defenders.Size();i++)
        {
            let candidate=Defenders[i];
            if(candidate!=null && candidate.health>0 && candidate.bShootable)
                TargetCandidates.Push(candidate);
        }
        CandidateTic=level.time;CandidatesValid=true;
    }

    Actor LeaderTarget(CaelumSiegeCombatant leader)
    {
        RefreshCandidates();
        Actor victim;double best=1e30;
        for(int i=0;i<TargetCandidates.Size();i++)
        {
            let candidate=TargetCandidates[i];
            if(candidate==null || candidate.health<=0 || !candidate.bShootable)continue;
            double distance=leader.Body.Distance2D(candidate);
            if(distance<best && leader.Body.CheckSight(candidate))
            {victim=candidate;best=distance;}
        }
        leader.CombatTarget=victim;
        return victim!=null ? victim : AttackingTarget[leader.Lane];
    }

    void UpdateSharedTarget(CaelumSiegeCombatant leader)
    {
        leader.SharedTarget=LeaderTarget(leader);
        leader.SharedTargetValid=true;
        // Se consulta al actuar un miembro; no se mantiene una segunda agenda
        // que haga pensar también a grupos sin actividad de combate.
        leader.NextSharedTargetTic=level.time+CaelumPortData.TARGET_UPDATE_TICS;
    }

    Actor AttackerTarget(CaelumSiegeCombatant entry)
    {
        if(!HighDensity)return IndividualAttackerTarget(entry);
        let leader=entry.CommandLeader;
        if(leader==null || !ActiveEntry(leader))leader=entry;
        if(!leader.SharedTargetValid || level.time>=leader.NextSharedTargetTic)
            UpdateSharedTarget(leader);
        let victim=leader.SharedTarget;
        // Una baja nunca se adopta como blanco vivo entre turnos de percepción.
        return victim!=null && victim.health>0 && victim.bShootable ? victim : null;
    }

    Actor IndividualAttackerTarget(CaelumSiegeCombatant entry)
    {
        EnsureTargetingRevision();
        let body=entry.Body;
        let victim=entry.CombatTarget;
        // La cadencia de percepción ya pertenece a LAYOUT.json. Las bajas
        // y la pérdida de visión invalidan un blanco antes del próximo turno.
        bool valid=victim!=null && victim.health>0 && victim.bShootable && body.CheckSight(victim);
        if(level.time>=entry.TargetRefreshTic || (victim!=null && !valid))
        {
            victim=null;double best=1e30;
            // La orden del mando inicia la búsqueda, sin ocultar un enemigo
            // más cercano al miembro de la escuadra que debe combatirlo.
            let leader=entry.CommandLeader;
            if(leader!=null && leader!=entry && ActiveEntry(leader))
            {
                let ordered=leader.CombatTarget;
                if(ordered!=null && ordered.health>0 && ordered.bShootable && body.CheckSight(ordered))
                {victim=ordered;best=body.Distance2D(ordered);}
            }
            for(int p=0;p<MAXPLAYERS;p++)
            {
                let candidate=playeringame[p] ? players[p].mo : null;
                if(candidate==null || candidate.health<=0 || !candidate.bShootable)continue;
                double distance=body.Distance2D(candidate);
                if(distance<best && body.CheckSight(candidate)){victim=candidate;best=distance;}
            }
            for(int i=0;i<Defenders.Size();i++)
            {
                let candidate=Defenders[i];
                if(candidate==null || candidate.health<=0 || !candidate.bShootable)continue;
                double distance=body.Distance2D(candidate);
                if(distance<best && body.CheckSight(candidate)){victim=candidate;best=distance;}
            }
            entry.CombatTarget=victim;
            entry.TargetRefreshTic=level.time+CaelumPortData.TARGET_UPDATE_TICS
                -(level.time+entry.StableIdentity)%CaelumPortData.TARGET_UPDATE_TICS;
        }
        // Sin contacto visible se mantiene la aproximación al carril; no se
        // considera ese destino oculto al comparar enemigos visibles.
        return victim!=null ? victim : AttackingTarget[entry.Lane];
    }

    CaelumSiegeCombatant NearestReserve(vector3 station)
    {
        CaelumSiegeCombatant chosen;double best=1e30;
        for(int i=0;i<Attackers.Size();i++)
        {
            let e=Attackers[i];
            if(e==Boss || !ActiveEntry(e) || e.CrewMachine!=null || !(e.Body is "CaelumMandinga"))continue;
            double distance=(e.Body.Pos-station).Length();
            if(distance<best){chosen=e;best=distance;}
        }
        return chosen;
    }

    void RefillCrews()
    {
        // Sólo las bajas liberan puestos. Un tripulante vivo que se alejó
        // conserva su asignación; las máquinas neutralizadas no se reactivan.
        for(int i=0;i<Machines.Size();i++)
        {
            let ram=CaelumBatteringRam(Machines[i]);if(ram==null || ram.Neutralized)continue;
            for(int slot=0;slot<ram.Crew.Size();slot++)
            {
                let old=ram.Crew[slot];
                if(old!=null && !old.ConfirmedDead && old.Body!=null && old.Body.health>0)continue;
                vector3 offset=((slot%2==0 ? -1 : 1)*CaelumRamData.TRIAL_CREW_SIDE*ram.SizeFactor,
                    ((slot/2)-(ram.RequiredCrew/2-1)/2.0)*CaelumRamData.TRIAL_CREW_STEP,0);
                let replacement=NearestReserve(ram.Pos+offset);
                if(replacement!=null && ram.AssignCrew(replacement))
                {replacement.CrewOffset=offset;replacement.Lane=NearestLane(ram.Pos.X);}
            }
        }
        for(int i=0;i<Guns.Size();i++)
        {
            let gun=Guns[i];if(gun==null || gun.Neutralized)continue;
            for(int slot=0;slot<gun.Operators.Size();slot++)
            {
                if(gun.Operators[slot]!=null && gun.Operators[slot].health>0)continue;
                vector3 offset=CaelumPortData.OperatorOffset(i,slot);
                if(!gun.Defending)
                {
                    let replacement=NearestReserve(gun.Pos+offset);
                    if(replacement!=null && gun.AssignOperator(replacement.Body))
                    {replacement.CrewOffset=offset;replacement.Lane=NearestLane(gun.Pos.X);}
                }
                else
                {
                    CaelumPortDefender chosen;double best=1e30;
                    // En la ciudad nueva, la distancia se mide hasta el acceso
                    // físico: estar bajo un cañón no permite atravesar su muro.
                    vector3 approach=CaelumPortData.IsSouth() ? CaelumPortData.CrewRoutePoint(i-6,0) : gun.Pos+offset;
                    for(int d=0;d<Defenders.Size();d++)
                    {
                        let soldier=Defenders[d];if(soldier==null || soldier.health<=0 || !soldier.bFriendly || soldier.Gun!=null)continue;
                        double distance=(soldier.Pos-approach).Length();
                        if(distance<best){chosen=soldier;best=distance;}
                    }
                    if(chosen!=null && gun.AssignOperator(chosen))
                    {chosen.Gun=gun;chosen.Station=gun.Pos+offset;chosen.Lane=NearestLane(gun.Pos.X);chosen.BeginCrewRoute(i-6);}
                }
            }
        }
    }

    static double PhysicalCost(CaelumCombatActor body)
    {
        if(body is "CaelumPortDefender")return CaelumWeaponCatalogue.GetPrimaryAirCost(CaelumConstants.CATALOGUE_WEAPON_SWORD);
        if(body is "CaelumZupayColossus")return CaelumAttackRules.SlamAir();
        return CaelumWeaponCatalogue.GetPrimaryAirCost(CaelumConstants.CATALOGUE_WEAPON_MACHETE);
    }

    static bool IgnoreAttackResourceLimits(CaelumCombatActor body)
    {
        // Conserva la consulta diagnóstica antigua; la excepción fue retirada.
        return false;
    }

    Actor CannonTarget(CaelumCannon gun)
    {
        Actor chosen;bool chosenCrew=false;double best=1e30;
        int count=gun.Defending ? Attackers.Size() : Defenders.Size();
        for(int i=0;i<count;i++)
        {
            Actor candidate;bool crew=false;
            if(gun.Defending)
            {
                let entry=Attackers[i];if(!ActiveEntry(entry))continue;
                candidate=entry.Body;crew=entry.CrewMachine!=null && !entry.CrewMachine.Neutralized;
            }
            else
            {
                let soldier=Defenders[i];if(soldier==null || soldier.health<=0)continue;
                candidate=soldier;crew=soldier.Gun!=null;
            }
            if(!gun.EligibleTarget(candidate) || gun.Barrel==null)continue;
            double distance=(candidate.Pos-gun.Pos).Length();
            bool competitive=chosen==null || (crew && !chosenCrew) || (crew==chosenCrew && distance<best);
            // CheckSight usa azar con invisibilidad. Sólo se omiten consultas
            // puras de candidatos normales que ya no pueden ganar la selección.
            if(HighDensity && !competitive && candidate.GetRenderStyle()==STYLE_Normal
                && candidate.Alpha>0 && !candidate.bInvisible && !candidate.bMInvisible)continue;
            if(!gun.Barrel.CheckSight(candidate))continue;
            if(chosen==null || (crew && !chosenCrew) || (crew==chosenCrew && distance<best))
            {chosen=candidate;chosenCrew=crew;best=distance;}
        }
        if(chosen!=null)return chosen;
        if(!gun.Defending)
        {
            int lane=NearestLane(gun.Pos.X);
            if(Gates[lane]!=null && !Gates[lane].Broken && !Gates[lane].Opened)return Gates[lane];
            for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i] && players[i].mo!=null && players[i].mo.health>0
                && gun.CheckSight(players[i].mo))return players[i].mo;
        }
        return null;
    }

    void OrderGuns()
    {
        for(int i=0;i<Guns.Size();i++)
        {
            let gun=Guns[i];if(gun==null || gun.Neutralized || !gun.Armed)continue;
            if(gun.Phase!=CaelumCannon.LOADED)continue;
            if(gun.Requested && gun.EligibleTarget(gun.IntendedTarget))continue;
            if(HighDensity && level.time<gun.NextTargetQuery)continue;
            gun.CancelShot();let victim=CannonTarget(gun);
            if(victim==null)
            {
                if(HighDensity)gun.NextTargetQuery=level.time+CaelumPortData.TARGET_UPDATE_TICS;
                continue;
            }
            gun.NextTargetQuery=0;
            vector3 point=victim.Pos+(0,0,victim.Height/2);
            if(victim is "CaelumBreakableGate")point.Z=victim.Pos.Z+CaelumCannonData.PIVOT_Z;
            double t=(point-gun.Pos).Length()/CaelumCannonData.SPEED;
            point.Z+=gun.GetGravity()*t*(t+1)/2;
            gun.RequestShot(point,victim);
        }
    }

    static void WalkTo(CaelumCombatActor body, Actor goal, vector3 point)
    {
        goal.SetOrigin(point,false);body.target=goal;body.LastEnemy=null;
        let soldier=CaelumPortDefender(body);
        if(soldier!=null && soldier.FollowingCrewRoute)
        {
            // Los relevos siguen cada escalón con colisión nativa, a la misma
            // velocidad y cadencia del estado See. No se modifica Z ni se salta
            // un obstáculo; A_Chase conserva el desvío cuando el paso se bloquea.
            vector2 delta=point.XY-body.Pos.XY;
            if(delta.Length()>0)
            {
                body.Angle=VectorAngle(delta.X,delta.Y);
                if(body.ThermalTryMove(body.Pos.XY+delta.Unit()*Min(body.Speed,delta.Length())))return;
            }
            body.ThermalChase(null,null,CHF_DONTLOOKALLAROUND|CHF_NORANDOMTURN|CHF_NOPOSTATTACKTURN);
            return;
        }
        body.ThermalChase(null,null,CHF_DONTLOOKALLAROUND);
    }

    static bool Pulse(CaelumCombatActor body)
    {
        let soldier=CaelumPortDefender(body);
        let entry=body.SiegeCombatant;
        // El menú nativo no pausa el mundo; sólo este guardia detiene su ruta.
        if(soldier!=null && soldier.bInConversation)return true;
        CaelumPortSiege port=soldier!=null ? soldier.Port : entry!=null ? CaelumPortSiege(entry.Encounter) : null;
        if(port==null || !port.RosterSealed)return false;
        if(body.PulseResourceRecovery())return true;
        if(body.health<=0 || body.ForcedSleepTics>0 || body.CombatLucidityPhysicalStunRemaining>0)return true;
        if(port.Victory){body.target=null;return true;}
        Actor victim;Actor goal;vector3 post;bool hasPost=false;
        if(soldier!=null)
        {
            if(soldier.Gun!=null && CaelumPortData.IsSouth() && !soldier.FollowingCrewRoute
                && Abs(soldier.Pos.Z-soldier.Station.Z)>soldier.MaxStepHeight)
                for(int i=6;i<port.Guns.Size();i++)if(port.Guns[i]==soldier.Gun){soldier.BeginCrewRoute(i-6);break;}
            victim=port.DefendingTarget[soldier.Lane];post=soldier.CrewPost();
            hasPost=soldier.Gun!=null || victim==null
                || (victim.Pos-post).Length()>CaelumPortData.COMMAND_LINK_RADIUS;
            if(soldier.NavigationTarget==null)soldier.NavigationTarget=Actor.Spawn("CaelumSewerEscapeTarget",post);
            goal=soldier.NavigationTarget;
        }
        else
        {
            victim=port.AttackerTarget(entry);
            if(entry.CrewMachine!=null && !entry.CrewMachine.Neutralized)
            {hasPost=true;post=entry.CrewMachine.Pos+entry.CrewOffset;}
            if(entry.NavigationTarget==null)entry.NavigationTarget=Actor.Spawn("CaelumSewerEscapeTarget",body.Pos);
            goal=entry.NavigationTarget;
        }
        bool nearEnemy=victim!=null && victim.health>0 && body.Distance2D(victim)<=body.MeleeRange+victim.Radius;
        if(hasPost && !nearEnemy && (body.Pos-post).Length()>body.Radius)
        {WalkTo(body,goal,post);return true;}
        if(victim==null || victim.health<=0){body.target=null;return true;}
        body.target=victim;
        bool canCast=soldier==null;
        if(!body.InStateSequence(body.CurState,body.SeeState))body.SetState(body.SeeState);
        else if(hasPost && !nearEnemy)
        {
            if(soldier!=null)body.ThermalChase(null,null,CHF_DONTMOVE|CHF_DONTLOOKALLAROUND);
            else if(canCast)body.ThermalChase(null,"Missile",CHF_DONTMOVE|CHF_DONTLOOKALLAROUND);
            else body.ThermalChase(null,null,CHF_DONTMOVE|CHF_DONTLOOKALLAROUND);
        }
        else
        {
            if(canCast)body.ThermalChase("Melee","Missile");
            else body.ThermalChase("Melee",null);
        }
        return true;
    }

    void Withdraw(CaelumSiegeCombatant entry)
    {
        let body=entry.Body;let exitNode=entry.ExitNode;
        if(body==null || exitNode==null)return;
        if((body.Pos.XY-exitNode.Pos.XY).Length()<=exitNode.Radius
            && Abs(body.Pos.Z-exitNode.Pos.Z)<=body.MaxStepHeight && body.CheckSight(exitNode))
        {entry.Exited=true;if(entry.NavigationTarget!=null)entry.NavigationTarget.Destroy();body.Destroy();return;}
        vector3 destination=exitNode.Pos;
        if((body.Pos.Y-CaelumPortData.GateY())*CaelumPortData.OutsideSign()<CaelumPortData.ROUTE_RADIUS)
            destination=(CaelumPortData.GateX(entry.Lane),CaelumPortData.GateY()+CaelumPortData.OutsideSign()*CaelumPortData.ROUTE_RADIUS*2,0);
        if(entry.NavigationTarget==null)entry.NavigationTarget=Spawn("CaelumSewerEscapeTarget",destination);
        body.Vel.X=0;body.Vel.Y=0;
        if(level.time%4==entry.StableIdentity%4)WalkTo(body,entry.NavigationTarget,destination);
    }

    void Calendar(CaelumPlayer user)
    {
        let agenda=CaelumScheduleState.Get(user,true);if(agenda==null)return;
        String key=Victory ? "port16_siege_end" : "port16_siege_start";
        if(agenda.FindKey(key)!=null)return;
        let e=agenda.AddAfter(user,key,CaelumScheduleRules.SIEGE,Victory ? "CA_PORT_AFTER" : "CA_PORT_OBJECTIVES","MAP06",0,0,1,"port16_siege");
        if(e!=null)e.Value=Victory ? 0 : 1;
        CaelumScheduleState.Sync(user);
    }

    override void Tick()
    {
        if(SetupRevision==0){Deploy();return;}
        RefreshDensity();
        if(!RosterSealed)
        {
            if(level.time<=SetupTick)return;
            SealRoster();
            for(int i=0;i<Machines.Size();i++)if(Machines[i] is "CaelumBatteringRam")CaelumBatteringRam(Machines[i]).ActivateRam();
            for(int i=0;i<Guns.Size();i++)if(CaelumPortData.ActiveGun(i))Guns[i].ActivateCannon(0);
            CommandDirty=true;
            let zone=Spawn("CaelumTimeAdvanceZone",CaelumPortData.BedPosition());
        }
        Super.Tick();
        if(Victory && !Aftermath)
        {
            Aftermath=true;
            for(int i=0;i<Guns.Size();i++){Guns[i].CancelShot();if(Guns[i].Defending)Guns[i].Armed=false;}
            for(int i=0;i<Gates.Size();i++)if(!Gates[i].Broken){Gates[i].Opened=true;Gates[i].RefreshPassage();}
        }
        if(!Victory)
        {
            if(CommandDirty || level.time%CaelumPortData.COMMAND_UPDATE_TICS==0){RefillCrews();ElectCommands();RefreshTargets();}
            OrderGuns();
        }
        for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i] && players[i].mo!=null)Calendar(CaelumPlayer(players[i].mo));
    }
}

// El punto final no viaja a los mapas de diagnóstico ni entrega otra carta.
class CaelumPortCompletion : Actor
{
    bool Complete;
    override bool Used(Actor activator)
    {
        let user=CaelumPlayer(activator);let port=CaelumPortSiege.Get();
        if(user==null || !CaelumUseGeometry.AimedAt(user,self))return false;
        let record=user.GetPersistentCharacterState(false);
        bool ready=port!=null && port.Victory && record!=null && record.HasTarotCard(CaelumConstants.TAROT_WANDS_KNIGHT);
        CaelumNotifications.Notify(user,StringTable.Localize(ready ? "CA_PORT_END" : "CA_PORT_OBJECTIVES",false));
        if(ready && !Complete){Complete=true;S_ChangeMusic("CA_MUS01");}
        return true;
    }
    Default { Radius 20;Height 128;+SOLID +NOGRAVITY +WALLSPRITE Tag "$CA_PORT_END_SIGN"; }
    States { Spawn: CSGT A -1;Stop; }
}
