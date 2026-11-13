// #20: estado local optativo. El mapa registra su fuerza existente; no la crea.
// Una referencia perdida no es una muerte. Sólo el evento nativo la confirma.
class CaelumSiegeCombatant : Object play
{
    CaelumCombatActor Body;
    CaelumSiegeEncounter Encounter;
    CaelumHostileMachine CrewMachine;
    CaelumSiegeRouteNode ExitNode;
    bool ConfirmedDead;
    bool Withdrawing;
    bool Exited;
    int NearbyMachines;
    int CommandPriority;
    int StableIdentity;
    int CommandGroup;
    CaelumSiegeCombatant CommandLeader;
    CaelumCommandCandidates GroupCandidates;
    // Caché de percepción del puerto; revisión propia en CaelumPortSiege.
    Actor CombatTarget;
    int TargetRefreshTic;
    // Caché del mando; la revisión del puerto reconstruye sólo estos datos.
    Actor SharedTarget;
    int NextSharedTargetTic;
    bool SharedTargetValid;
    bool SharedTargetWasPresent;
    transient Actor SharedTargetSubscription;
    Actor NavigationTarget;
    vector3 CrewOffset;
    int CrewSlot;
    int Lane;

    vector3 CrewPost()
    {
        let ram=CaelumBatteringRam(CrewMachine);
        if(ram!=null && ram.CrewLayoutRevision>0)return ram.CrewPosition(CrewSlot);
        return CrewMachine!=null?CrewMachine.Pos+CrewOffset:Body!=null?Body.Pos:(0,0,0);
    }

    static void ConfirmDeath(CaelumCombatActor body)
    {
        if(body==null || body.health>0 || body.SiegeCombatant==null)return;
        let entry=body.SiegeCombatant;
        if(entry.ConfirmedDead)return;
        let encounter=entry.Encounter;
        if(encounter!=null && !body.bFriendly)
            for(int i=0;i<encounter.Machines.Size();i++)
            {
                let machine=encounter.Machines[i];
                if(machine!=null && machine.Armed && !machine.Neutralized
                    && (body.Pos-machine.Pos).Length()<=machine.GuardRadius)
                    machine.RememberGuard(entry);
            }
        entry.ConfirmedDead=true;
        if(encounter is "CaelumPortSiege")CaelumPortSiege(encounter).CommandDirty=true;
    }

    void WithdrawTick()
    {
        if (Body == null || ConfirmedDead || Exited || Body.health <= 0) return;
        if(CaelumCommunication.SeekHelp(Body))return;
        if (Encounter is "CaelumPortSiege")
        {
            CaelumPortSiege(Encounter).Withdraw(self);
            return;
        }
        Body.target = null;
        Body.Vel.X = 0; Body.Vel.Y = 0;
        if (ExitNode == null) return;
        vector2 offset = ExitNode.Pos.XY - Body.Pos.XY;
        // La frontera debe alcanzarse físicamente, a la misma altura.
        if (offset.Length() <= ExitNode.Radius
            && Abs(Body.Pos.Z - ExitNode.Pos.Z) <= Body.MaxStepHeight)
        {
            if (ExitNode.IsExit)
            {
                Exited = true;
                Body.Destroy(); // No Die, daño, botín ni recompensa por muerte.
                return;
            }
            ExitNode = ExitNode.NextNode;
            return;
        }
        double direction = VectorAngle(offset.X, offset.Y);
        double speed = Min(Body.Speed, offset.Length());
        Body.Angle = direction;
        Body.Vel.X = Cos(direction) * speed;
        Body.Vel.Y = Sin(direction) * speed;
    }
}

class CaelumSiegeRouteNode : Actor
{
    CaelumSiegeRouteNode NextNode;
    bool IsExit;
    Default { Radius 8; Height 1; +NOBLOCKMAP +NOGRAVITY }
    States { Spawn: TNT1 A -1; Stop; }
}

class CaelumSiegeEncounter : Actor
{
    Array<CaelumSiegeCombatant> Attackers;
    Array<CaelumHostileMachine> Machines;
    CaelumSiegeCombatant Boss;
    bool RosterSealed;
    bool Victory;
    bool BossRetreated;
    int DefeatStateRevision;
    CaelumAbsentBattle AbsentBattle;
    int VictoryCount;
    int NeutralizedCount;

    override void PostBeginPlay()
    {
        Super.PostBeginPlay();
        let registry = CaelumSiegeEvents(EventHandler.Find("CaelumSiegeEvents"));
        if (registry != null) registry.RegisterNarrative(self);
    }

    override void OnDestroy()
    {
        let registry = CaelumSiegeEvents(EventHandler.Find("CaelumSiegeEvents"));
        if (registry != null) registry.UnregisterNarrative(self);
        Super.OnDestroy();
    }

    bool BossDefeated()
    {
        return Boss != null && (Boss.ConfirmedDead || BossRetreated);
    }

    void EnsureDefeatRevision()
    {
        if (DefeatStateRevision >= 1) return;
        // El esquema previo sólo confirmaba muertes. No inferir una fuga de
        // referencias ausentes, victoria previa ni cartas ya poseídas.
        BossRetreated = false;
        DefeatStateRevision = 1;
    }

    void ConfirmBossRetreat(CaelumSiegeCombatant entry)
    {
        EnsureDefeatRevision();
        if (entry == null || entry != Boss || entry.Encounter != self
            || entry.Body == null || entry.Body.health <= 0 || entry.ExitNode == null
            || !entry.ExitNode.IsExit) return;
        if ((entry.Body.Pos.XY-entry.ExitNode.Pos.XY).Length() > entry.ExitNode.Radius
            || Abs(entry.Body.Pos.Z-entry.ExitNode.Pos.Z) > entry.Body.MaxStepHeight
            || !entry.Body.CheckSight(entry.ExitNode)) return;
        entry.Exited = true;
        BossRetreated = true;
    }

    virtual bool AllowLateRegistration() { return false; }

    CaelumSiegeCombatant RegisterAttacker(CaelumCombatActor body)
    {
        if (body == null || body.health <= 0 || body.bFriendly
            || (!(body is "CaelumMandinga") && !(body is "CaelumZupayColossus"))) return null;
        for (int i = 0; i < Attackers.Size(); i++)
            if (Attackers[i].Body == body) return Attackers[i];
        if ((RosterSealed && !AllowLateRegistration()) || body.SiegeCombatant != null) return null;
        let entry = new("CaelumSiegeCombatant");
        entry.Body = body; entry.Encounter = self;
        entry.StableIdentity = Attackers.Size();
        entry.CommandPriority = body is "CaelumZupayColossus" ? 1 : 2;
        body.SiegeCombatant = entry;
        Attackers.Push(entry);
        // Un guardia sin blockmap puede registrarse después del censo de este
        // tic. Debe estar disponible antes de observar o neutralizar máquinas.
        if(body.bNoBlockmap)
        {
            let population=CaelumPopulationState.Get();
            if(population!=null)population.UnlinkedGuards.Push(entry);
            CaelumTarotChariot.RegisteredUnlinked(body);
        }
        return entry;
    }

    bool RegisterMachine(CaelumHostileMachine machine)
    {
        if (machine == null || !machine.CountsAsHostileObjective()) return false;
        for (int i = 0; i < Machines.Size(); i++)
            if (Machines[i] == machine) return true;
        if (RosterSealed || Machines.Size()>=12
            || (machine.Encounter != null && machine.Encounter != self)) return false;
        machine.Encounter = self;
        machine.RegistryIndex=Machines.Size();
        Machines.Push(machine);
        return true;
    }

    bool SealRoster()
    {
        // Permite carriles aislados; la victoria sigue exigiendo doce y Zupay.
        // Los cañones defensores nunca se registran.
        if (Machines.Size()==0) return false;
        if (Boss!=null && (Boss.Encounter!=self || Boss.Body==null
            || !(Boss.Body is "CaelumZupayColossus"))) return false;
        RosterSealed = true;
        return true;
    }

    override void Tick()
    {
        Super.Tick();
        ResolveVictory();
    }

    void ResolveVictory(bool summarized=false)
    {
        EnsureDefeatRevision();
        if (!RosterSealed || Victory) return;
        NeutralizedCount = 0;
        for (int i = 0; i < Machines.Size(); i++)
        {
            if (Machines[i] == null) return; // Ausencia no implica neutralización.
            if (Machines[i].ObjectiveNeutralized()) NeutralizedCount++;
        }
        if (NeutralizedCount != 12 || !BossDefeated()) return;
        Victory = true; VictoryCount++;
        for (int i = 0; i < Attackers.Size(); i++)
        {
            let entry = Attackers[i];
            if (entry.ConfirmedDead || entry.Exited || entry.Body == null || entry.Body.health <= 0) continue;
            entry.Withdrawing = true;
            entry.Body.target = null;
            if(!summarized)entry.Body.SetStateLabel("SiegeWithdrawal");
        }
    }

    Default { Radius 1; Height 1; +NOBLOCKMAP +NOGRAVITY }
    States { Spawn: TNT1 A -1; Stop; }
}

// Base reutilizable por los seis arietes y los seis cañones atacantes (#21).
class CaelumHostileMachine : Actor
{
    int MachineRevision,OwnerFaction,DamageSerial;
    bool Captured,Sabotaged,CapturedIntact;
    CaelumMachineStructure Structure;
    CaelumPlayer Worker;
    Array<Actor> ControlledCrew;

    int MachineKind()
    {let ram=CaelumBatteringRam(self);return ram==null?CaelumMachineData.CANNON:ram.Large?CaelumMachineData.LARGE_RAM:CaelumMachineData.SMALL_RAM;}

    void EnsureMachine()
    {
        if(MachineRevision>=CaelumMachineData.REVISION)return;
        let cannon=CaelumCannon(self);let ram=CaelumBatteringRam(self);
        if((cannon!=null && !cannon.Initialized) || (ram!=null && !ram.Initialized))return;
        MachineRevision=CaelumMachineData.REVISION;
        OwnerFaction=cannon!=null && cannon.Defending?CaelumMilitaryData.GUARD_FACTION:CaelumMachineData.ENEMY_OWNER;
        // La victoria ya ganada no se revoca. Una máquina intacta no se vuelve
        // destruida por las bajas de sus antiguos guardias al migrar.
        if(!TarotDestroyed){Neutralized=false;NeutralizationCount=0;}
        Structure=CaelumMachineStructure(Spawn('CaelumMachineStructure',Pos,NO_REPLACE));
        if(Structure!=null)
        {
            Structure.Machine=self;Structure.Angle=Angle;Structure.InitializeGate();
            if(TarotDestroyed){Structure.Broken=true;Structure.Opened=true;Structure.health=0;}
            health=Structure.health;
        }
        BindStructure();
        let gun=CaelumCannon(self);
        if(gun!=null)for(int i=0;i<gun.Operators.Size();i++)CaelumMachineOperator.Assign(gun.Operators[i],self);
        for(int i=0;i<Crew.Size();i++)if(Crew[i]!=null)CaelumMachineOperator.Assign(Crew[i].Body,self);
    }
    virtual void BindStructure() {}
    bool ObjectiveNeutralized()
    {EnsureMachine();return TarotDestroyed || Captured;}
    bool Operational()
    {return !TarotDestroyed && !Neutralized && !Sabotaged && health>0;}

    int TarotMachineRevision;
    bool TarotDestroyed;

    void EnsureTarotMachine()
    {
        if(TarotMachineRevision>=CaelumMajorArcanaData.MACHINE_REVISION)return;
        TarotDestroyed=false;
        TarotMachineRevision=CaelumMajorArcanaData.MACHINE_REVISION;
    }

    virtual void RemoveMachineParts() {}

    bool DestroyByTarot()
    {
        EnsureTarotMachine();
        if(TarotDestroyed)return false;
        TarotDestroyed=true;
        // El registro de objetivo permanece: null nunca equivale a victoria.
        if(!Neutralized){Neutralized=true;NeutralizationCount++;}
        Armed=false;health=0;Vel=(0,0,0);
        if(Structure!=null){Structure.Broken=true;Structure.Opened=true;Structure.health=0;}
        for(int i=0;i<Crew.Size();i++)
            if(Crew[i]!=null && Crew[i].CrewMachine==self)Crew[i].CrewMachine=null;
        CaelumMachineOwnership.ReleaseCrew(self);RemoveMachineParts();
        if(Encounter!=null)Encounter.ResolveVictory();
        return true;
    }

    CaelumAbsentMachine AbsentMachine;
    virtual bool CountsAsHostileObjective() { return true; }
    CaelumSiegeEncounter Encounter;
    Array<CaelumSiegeCombatant> LocalGuards;
    Array<CaelumSiegeCombatant> Crew;
    double GuardRadius;
    int RequiredCrew;
    bool Armed;
    bool Neutralized;
    int NeutralizationCount;
    int RegistryIndex;

    void RememberGuard(CaelumSiegeCombatant entry)
    {
        int bit=1<<RegistryIndex;
        if ((entry.NearbyMachines & bit)!=0) return;
        entry.NearbyMachines|=bit;
        LocalGuards.Push(entry);
    }

    bool AssignCrew(CaelumSiegeCombatant entry)
    {
        if (entry == null || entry.Encounter != Encounter || entry.Body == null
            || !(entry.Body is "CaelumMandinga") || entry.ConfirmedDead || Neutralized
            || OwnerFaction!=CaelumMachineData.ENEMY_OWNER) return false;
        for (int i = 0; i < Crew.Size(); i++) if (Crew[i] == entry) return true;
        if (entry.Body.health <= 0 || entry.Body.bFriendly || entry.CrewMachine != null) return false;
        int vacancy=-1;
        for(int i=0;i<Crew.Size();i++)
            if(Crew[i]==null || Crew[i].ConfirmedDead || Crew[i].Body==null || Crew[i].Body.health<=0)
            {vacancy=i;break;}
        if(vacancy<0 && Crew.Size()>=RequiredCrew)return false;
        if(!CaelumMachineOperator.Assign(entry.Body,self))return false;
        entry.CrewMachine = self;
        if(vacancy<0)Crew.Push(entry);
        else
        {
            // Se libera el puesto, no la memoria de guardias eliminados.
            if(Crew[vacancy]!=null && Crew[vacancy].CrewMachine==self)Crew[vacancy].CrewMachine=null;
            Crew[vacancy]=entry;
        }
        entry.CrewSlot=vacancy<0?Crew.Size()-1:vacancy;
        return true;
    }

    bool IsNearby(CaelumSiegeCombatant entry)
    {
        return entry != null && entry.Body != null && !entry.ConfirmedDead
            && entry.Body.health > 0 && !entry.Body.bFriendly
            && (entry.Body.Pos - Pos).Length() <= GuardRadius;
    }

    bool FullCrewPresent(bool attacking=false)
    {
        if(OwnerFaction>=0)return CaelumMachineOwnership.Staffing(self,attacking)>=RequiredCrew;
        if (RequiredCrew <= 0 || Crew.Size() != RequiredCrew) return false;
        for (int i = 0; i < Crew.Size(); i++)
            if (!IsNearby(Crew[i]) || (attacking && CaelumBattleCry.Active(Crew[i].Body))) return false;
        return true;
    }

    bool HasIntimidatedCrew()
    {
        for(int i=0;i<ControlledCrew.Size();i++)
            if(CaelumMachineOwnership.Reserved(self,ControlledCrew[i]) && CaelumBattleCry.Active(ControlledCrew[i]))return true;
        for(int i=0;i<Crew.Size();i++)
            if(Crew[i]!=null && CaelumBattleCry.Active(Crew[i].Body))return true;
        return false;
    }

    bool ArmMachine()
    {
        if (!Operational() || Encounter == null || !Encounter.RosterSealed) return false;
        Armed = true;
        ObserveGuards();
        return true;
    }

    void ObserveGuards()
    {
        EnsureTarotMachine();
        EnsureMachine();
        // #449 reemplaza expresamente la neutralización por bajas. Se retienen
        // los registros históricos, pero sólo capturar o destruir completa el objetivo.
    }

    override void Tick() { Super.Tick(); ObserveGuards(); }
    Default { Radius 1; Height 1; +NOGRAVITY }
    States { Spawn: TNT1 A -1; Stop; }
}

class CaelumSiegeEvents : EventHandler
{
    // #418: registro del mapa, actualizado por eventos. Sólo al cargar un
    // guardado sin revisión se reconstruye con un recorrido tipado único.
    int NarrativeRegistryRevision;
    Array<CaelumSiegeEncounter> NarrativeEncounters;
    int PortPeopleRevision;
    CaelumAnchoredResident PortPeople[CaelumConstants.PRISONER_COUNT];

    void EnsurePortPeople()
    {
        if(PortPeopleRevision>=1 || level.MapName!="MAP03")return;
        // Migración única: los cuatro cuerpos antiguos no guardaban un registro.
        // La consulta tipada no se repite al hablar ni por personaje/tic.
        let it=ThinkerIterator.Create("CaelumAnchoredResident");CaelumAnchoredResident body;
        while((body=CaelumAnchoredResident(it.Next()))!=null)
            if(body.EscortPrisonerPort && body.EscortPrisonerId>=0 && body.EscortPrisonerId<CaelumConstants.PRISONER_COUNT)
                PortPeople[body.EscortPrisonerId]=body;
        PortPeopleRevision=1;
    }
    void RegisterPortPerson(CaelumAnchoredResident body)
    {
        if(level.MapName!="MAP03" || body==null || !body.EscortPrisonerPort
            || body.EscortPrisonerId<0 || body.EscortPrisonerId>=CaelumConstants.PRISONER_COUNT)return;
        EnsurePortPeople();PortPeople[body.EscortPrisonerId]=body;
    }
    int PortSurvivors()
    {
        EnsurePortPeople();int mask=0;
        for(int i=0;i<CaelumConstants.PRISONER_COUNT;i++)
            if(PortPeople[i]!=null && PortPeople[i].health>0)mask|=1<<i;
        return mask;
    }
    void SyncPortSurvivors()
    {
        if(level.MapName!="MAP03")return;
        int mask=PortSurvivors();
        for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])
        {
            let user=CaelumPlayer(players[i].mo);if(!CaelumPlayerAuthority.CanMutate(user))continue;
            let record=user.GetPersistentCharacterState(false);if(record==null)continue;
            if(record.PortSurvivorsMask==mask)continue;
            record.PortSurvivorsMask=mask;CaelumPortQuests.Observe(user);
        }
    }

    void EnsureNarrativeRegistry()
    {
        if (NarrativeRegistryRevision >= 1) return;
        NarrativeEncounters.Clear();
        let it = ThinkerIterator.Create("CaelumSiegeEncounter");
        CaelumSiegeEncounter encounter;
        while ((encounter = CaelumSiegeEncounter(it.Next())) != null)
            NarrativeEncounters.Push(encounter);
        NarrativeRegistryRevision = 1;
    }

    CaelumSiegeEncounter NarrativeEncounter()
    {
        EnsureNarrativeRegistry();
        for (int i = 0; i < NarrativeEncounters.Size(); i++)
        {
            let encounter = NarrativeEncounters[i];
            if (encounter != null && encounter.RosterSealed
                && encounter.Machines.Size() == 12 && encounter.Boss != null) return encounter;
        }
        return null;
    }

    CaelumPortSiege PortEncounter()
    {
        EnsureNarrativeRegistry();
        for (int i = 0; i < NarrativeEncounters.Size(); i++)
            if (NarrativeEncounters[i] is "CaelumPortSiege")
                return CaelumPortSiege(NarrativeEncounters[i]);
        return null;
    }

    override void WorldLoaded(WorldEvent e)
    { EnsureNarrativeRegistry();EnsurePortPeople();SyncPortSurvivors(); }

    void RegisterNarrative(CaelumSiegeEncounter encounter)
    {
        if (encounter == null) return;
        EnsureNarrativeRegistry();
        for (int i = 0; i < NarrativeEncounters.Size(); i++)
            if (NarrativeEncounters[i] == encounter) return;
        NarrativeEncounters.Push(encounter);
    }

    void UnregisterNarrative(CaelumSiegeEncounter encounter)
    {
        for (int i = NarrativeEncounters.Size() - 1; i >= 0; i--)
            if (NarrativeEncounters[i] == null || NarrativeEncounters[i] == encounter)
                NarrativeEncounters.Delete(i);
    }

    override void WorldThingDestroyed(WorldEvent e)
    {
        if(e.Thing is "CaelumAnchoredResident")
        {
            for(int i=0;i<CaelumConstants.PRISONER_COUNT;i++)if(PortPeople[i]==e.Thing)PortPeople[i]=null;
            SyncPortSurvivors();
        }
        CaelumTargetSubscriptions.Retire(e.Thing);
        if (!(e.Thing is "CaelumSiegeEncounter")) return;
        UnregisterNarrative(CaelumSiegeEncounter(e.Thing));
    }

    override void WorldTick()
    {
        let archive=CaelumCorpseArchive.Get(true);if(archive!=null)archive.Tick();
    }
    override void WorldThingDied(WorldEvent e)
    {
        CaelumBattleConsequences.MerchantDied(CaelumCityMerchant(e.Thing));
        CaelumBattleDirector.DefenderChanged(CaelumPortDefender(e.Thing));
        if(e.Thing is "CaelumAnchoredResident")SyncPortSurvivors();
        CaelumTargetSubscriptions.Retire(e.Thing);
        CaelumSiegeCombatant.ConfirmDeath(CaelumCombatActor(e.Thing));
        CaelumCorpseArchive.Died(e.Thing);
    }
}
