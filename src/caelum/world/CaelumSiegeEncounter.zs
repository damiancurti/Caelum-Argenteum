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
    }

    void WithdrawTick()
    {
        if (Body == null || ConfirmedDead || Exited || Body.health <= 0) return;
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
    int VictoryCount;
    int NeutralizedCount;

    CaelumSiegeCombatant RegisterAttacker(CaelumCombatActor body)
    {
        if (body == null || body.health <= 0 || body.bFriendly
            || (!(body is "CaelumMandinga") && !(body is "CaelumZupayColossus"))) return null;
        for (int i = 0; i < Attackers.Size(); i++)
            if (Attackers[i].Body == body) return Attackers[i];
        if (RosterSealed || body.SiegeCombatant != null) return null;
        let entry = new("CaelumSiegeCombatant");
        entry.Body = body; entry.Encounter = self;
        body.SiegeCombatant = entry;
        Attackers.Push(entry);
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
        if (!RosterSealed || Victory) return;
        NeutralizedCount = 0;
        for (int i = 0; i < Machines.Size(); i++)
        {
            if (Machines[i] == null) return; // Ausencia no implica neutralización.
            if (Machines[i].Neutralized) NeutralizedCount++;
        }
        if (NeutralizedCount != 12 || Boss==null || !Boss.ConfirmedDead) return;
        Victory = true; VictoryCount++;
        for (int i = 0; i < Attackers.Size(); i++)
        {
            let entry = Attackers[i];
            if (entry.ConfirmedDead || entry.Body == null || entry.Body.health <= 0) continue;
            entry.Withdrawing = true;
            entry.Body.target = null;
            entry.Body.SetStateLabel("SiegeWithdrawal");
        }
    }

    Default { Radius 1; Height 1; +NOBLOCKMAP +NOGRAVITY }
    States { Spawn: TNT1 A -1; Stop; }
}

// Base reutilizable por los seis arietes y los seis cañones atacantes (#21).
class CaelumHostileMachine : Actor
{
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
            || !(entry.Body is "CaelumMandinga") || entry.ConfirmedDead || Neutralized) return false;
        for (int i = 0; i < Crew.Size(); i++) if (Crew[i] == entry) return true;
        if (entry.CrewMachine != null || Crew.Size() >= RequiredCrew) return false;
        entry.CrewMachine = self;
        Crew.Push(entry);
        return true;
    }

    bool IsNearby(CaelumSiegeCombatant entry)
    {
        return entry != null && entry.Body != null && !entry.ConfirmedDead
            && entry.Body.health > 0 && !entry.Body.bFriendly
            && (entry.Body.Pos - Pos).Length() <= GuardRadius;
    }

    bool FullCrewPresent()
    {
        if (RequiredCrew <= 0 || Crew.Size() != RequiredCrew) return false;
        for (int i = 0; i < Crew.Size(); i++) if (!IsNearby(Crew[i])) return false;
        return true;
    }

    bool ArmMachine()
    {
        if (Neutralized || Encounter == null || !Encounter.RosterSealed) return false;
        Armed = true;
        ObserveGuards();
        return true;
    }

    void ObserveGuards()
    {
        if (!Armed || Neutralized || Encounter == null) return;
        for (int i = 0; i < Encounter.Attackers.Size(); i++)
        {
            let entry = Encounter.Attackers[i];
            if (!IsNearby(entry)) continue;
            RememberGuard(entry);
        }
        if (LocalGuards.Size() == 0) return;
        for (int i = 0; i < LocalGuards.Size(); i++)
            if (!LocalGuards[i].ConfirmedDead) return;
        Neutralized = true;
        NeutralizationCount++;
        Vel = (0, 0, 0);
    }

    override void Tick() { Super.Tick(); ObserveGuards(); }
    Default { Radius 1; Height 1; +NOGRAVITY }
    States { Spawn: TNT1 A -1; Stop; }
}

class CaelumSiegeEvents : EventHandler
{
    override void WorldThingDied(WorldEvent e)
    {
        CaelumSiegeCombatant.ConfirmDeath(CaelumCombatActor(e.Thing));
    }
}
