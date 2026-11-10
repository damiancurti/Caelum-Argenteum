// Un vínculo nativo por operador evita buscar todas las máquinas al asignarlo.
class CaelumMachineOperator : Inventory
{
    CaelumHostileMachine Machine;
    Actor Contact;
    bool Controlling,AttackHeld;

    static void FilterInput(CaelumPlayer user)
    {
        let bond=Find(user);if(bond==null || !bond.Controlling || user.player==null)return;
        // La predicción local sólo filtra botones: nunca libera la dotación
        // guardada ni emite una orden que el otro peer no ejecutó.
        if(user.player.cheats&CF_PREDICTING)
        {user.player.cmd.buttons&=~(BT_ATTACK|BT_ALTATTACK);return;}
        if(bond.Machine==null || !CaelumMachineOwnership.Present(bond.Machine,user)
            || !CaelumMachineWork.Reach(user,bond.Contact))
        {bond.Controlling=false;Release(user,bond.Machine);return;}
        bool attack=(user.player.cmd.buttons&BT_ATTACK)!=0;
        bool leave=(user.player.cmd.buttons&BT_ALTATTACK)!=0;
        user.player.cmd.buttons&=~(BT_ATTACK|BT_ALTATTACK);
        if(leave){bond.Controlling=false;Release(user,bond.Machine);return;}
        let session=CaelumMachineSession.Find(user);
        if(attack && !bond.AttackHeld && (session==null || !session.Open))
        {
            vector3 eye=user.Pos+(0,0,user.ViewHeight);
            vector3 direction=(Cos(user.Angle)*Cos(user.Pitch),Sin(user.Angle)*Cos(user.Pitch),-Sin(user.Pitch));
            let trace=new('CaelumMachineAim');trace.Machine=bond.Machine;
            bool found=trace.Trace(eye,level.PointInSector(eye.XY),direction,PLAYERMISSILERANGE,
                TRACE_PortalRestrict,Line.ML_BLOCKING|Line.ML_BLOCKEVERYTHING|Line.ML_BLOCKHITSCAN,false,user);
            vector3 point=eye+direction*(found?trace.Results.Distance:PLAYERMISSILERANGE);
            let cannon=CaelumCannon(bond.Machine);
            if(cannon!=null)cannon.RequestShot(point);
            else
            {
                let ram=CaelumBatteringRam(bond.Machine);
                Actor target=found?trace.Results.HitActor:null;
                let gate=CaelumBreakableGate(target is 'CaelumGateBlocker'?target.master:target);
                if(ram!=null && gate!=null && !(gate is 'CaelumMachineStructure'))
                {
                    double facing=VectorAngle(gate.Pos.X-ram.Pos.X,gate.Pos.Y-ram.Pos.Y);
                    if(ram.SetRoute(gate,facing))
                    {
                        double reach=(CaelumRamData.HEAD_X+CaelumRamData.EXTENDED_OFFSET+CaelumRamData.HEAD_RADIUS)*ram.SizeFactor;
                        ram.AddRoutePoint(gate.Pos-(Cos(facing)*reach,Sin(facing)*reach,0));ram.ActivateRam();
                    }
                }
            }
        }
        bond.AttackHeld=attack;
    }
    static CaelumMachineOperator Find(Actor body)
    {return body==null?null:CaelumMachineOperator(body.FindInventory('CaelumMachineOperator'));}
    static bool Assign(Actor body,CaelumHostileMachine machine)
    {
        if(body==null || machine==null)return false;
        let bond=Find(body);
        if(bond!=null && bond.Machine!=null && bond.Machine!=machine && !bond.Machine.bDestroyed && !bond.Machine.TarotDestroyed)return false;
        if(bond==null)bond=CaelumMachineOperator(body.GiveInventoryType('CaelumMachineOperator'));
        if(bond==null)return false;bond.Machine=machine;return true;
    }
    static void Release(Actor body,CaelumHostileMachine machine)
    {let bond=Find(body);if(bond!=null && bond.Machine==machine){bond.Machine=null;bond.Controlling=false;bond.Contact=null;}}
    override void Tick()
    {
        Super.Tick();
        if(Machine!=null && !CaelumMachineOwnership.Eligible(Machine,Owner))Release(Owner,Machine);
    }
    Default { Inventory.MaxAmount 1; +INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE }
}

class CaelumMachineAim : LineTracer
{
    CaelumHostileMachine Machine;
    override ETraceStatus TraceCallback()
    {
        if(Results.HitType==TRACE_HitActor)
        {
            Actor body=Results.HitActor;
            if(body==Machine || body.master==Machine || CaelumMajorTargets.Machine(body)==Machine)return TRACE_Skip;
            if(!body.bSolid && !body.bShootable)return TRACE_Skip;
        }
        return TRACE_Stop;
    }
}

class CaelumMachineOwnership : Object play
{
    static bool Reserved(CaelumHostileMachine machine,Actor body)
    {let bond=CaelumMachineOperator.Find(body);return Eligible(machine,body) && bond!=null && bond.Machine==machine;}
    static int Assigned(CaelumHostileMachine machine)
    {
        int count=0;let cannon=CaelumCannon(machine);
        if(cannon!=null)for(int i=0;i<cannon.Operators.Size();i++)if(Reserved(machine,cannon.Operators[i]))count++;
        for(int i=0;i<machine.ControlledCrew.Size();i++)if(Reserved(machine,machine.ControlledCrew[i]))count++;
        return count;
    }
    static void PruneControlled(CaelumHostileMachine machine)
    {
        for(int i=machine.ControlledCrew.Size()-1;i>=0;i--)
            if(!Reserved(machine,machine.ControlledCrew[i]))
            {CaelumMachineOperator.Release(machine.ControlledCrew[i],machine);machine.ControlledCrew.Delete(i);}
    }
    static bool HasPost(CaelumPortDefender soldier)
    {
        let bond=CaelumMachineOperator.Find(soldier);
        return bond!=null && bond.Machine!=null && bond.Machine.OwnerFaction>=0 && Reserved(bond.Machine,soldier)
            && !bond.Machine.TarotDestroyed;
    }
    static vector3 Post(CaelumPortDefender soldier)
    {
        let bond=CaelumMachineOperator.Find(soldier);let machine=bond.Machine;
        let ram=CaelumBatteringRam(machine);
        if(ram==null)return soldier.CrewPost();
        int slot=0;for(int i=0;i<machine.ControlledCrew.Size();i++)if(machine.ControlledCrew[i]==soldier){slot=i;break;}
        vector3 offset=((slot%2==0?-1:1)*CaelumRamData.TRIAL_CREW_SIDE*ram.SizeFactor,
            ((slot/2)-(ram.RequiredCrew/2-1)/2.0)*CaelumRamData.TRIAL_CREW_STEP,0);
        double rotation=machine.Angle-90;
        return machine.Pos+(Cos(rotation)*offset.X-Sin(rotation)*offset.Y,
            Sin(rotation)*offset.X+Cos(rotation)*offset.Y,offset.Z);
    }
    static bool Admission()
    {
        let port=CaelumPortSiege.Get();
        return port==null || !CaelumCityData.Enabled() || port.LivingDefendingPopulation()<CaelumFormationData.SIDE_CAPACITY;
    }
    static bool Member(CaelumPlayer user,int faction)
    {
        if(user==null || faction<0 || faction>=CaelumConstants.FACTION_COUNT)return false;
        let record=user.GetPersistentCharacterState(false);
        return record!=null && record.FactionMember[faction];
    }
    static bool Eligible(CaelumHostileMachine machine,Actor body)
    {
        if(machine==null || body==null || body.health<=0)return false;
        let user=CaelumPlayer(body);
        if(user!=null)return CaelumPlayerAuthority.CanMutate(user) && Member(user,machine.OwnerFaction);
        let npc=CaelumCombatActor(body);if(npc==null)return false;
        if(machine.OwnerFaction==CaelumMachineData.ENEMY_OWNER)
            return !npc.bFriendly && npc.SiegeCombatant!=null && npc.SiegeCombatant.Encounter==machine.Encounter;
        // La guardia es la única tropa con pertenencia explícita de este escenario.
        return machine.OwnerFaction==CaelumMilitaryData.GUARD_FACTION && npc is 'CaelumPortDefender'
            && !CaelumRedemption.PreviouslyRaised(npc);
    }
    static bool Present(CaelumHostileMachine machine,Actor body,bool attacking=false)
    {
        if(!Eligible(machine,body) || body.bDestroyed || (body.Pos-machine.Pos).Length()>machine.GuardRadius)return false;
        let bond=CaelumMachineOperator.Find(body);if(bond==null || bond.Machine!=machine)return false;
        let user=CaelumPlayer(body);
        if(user!=null)return !user.isFrozen() && user.ForcedSleepTics<=0 && !CaelumSleepRules.IsSleeping(user)
            && user.player!=null && user.player.playerstate==PST_LIVE;
        let npc=CaelumCombatActor(body);let guard=CaelumPortDefender(npc);
        return CaelumFormation.Capable(npc) && (!attacking || !CaelumBattleCry.Active(npc))
            && !(guard!=null && guard.Residence!=null && guard.Residence.Suspended);
    }
    static bool EnemyOperators(CaelumHostileMachine machine)
    {
        let cannon=CaelumCannon(machine);
        if(cannon!=null)
            for(int i=0;i<cannon.Operators.Size();i++)if(Present(machine,cannon.Operators[i]))return true;
        for(int i=0;i<machine.Crew.Size();i++)
            if(machine.Crew[i]!=null && Present(machine,machine.Crew[i].Body))return true;
        return false;
    }
    static void ReleaseCrew(CaelumHostileMachine machine)
    {
        let cannon=CaelumCannon(machine);
        if(cannon!=null)
        {
            for(int i=0;i<cannon.Operators.Size();i++)
            {
                let body=cannon.Operators[i];if(body==null)continue;
                CaelumMachineOperator.Release(body,machine);
                let soldier=CaelumPortDefender(body);
                if(soldier!=null && soldier.Gun==machine){soldier.Gun=null;soldier.FollowingCrewRoute=false;soldier.Station=soldier.Pos;}
                if(body.SiegeCombatant!=null && body.SiegeCombatant.CrewMachine==machine)body.SiegeCombatant.CrewMachine=null;
            }
            cannon.Operators.Clear();cannon.OperatorPerception.Clear();cannon.CancelShot();
        }
        for(int i=0;i<machine.Crew.Size();i++)
        {
            let entry=machine.Crew[i];if(entry==null)continue;
            if(entry.CrewMachine==machine)entry.CrewMachine=null;
            CaelumMachineOperator.Release(entry.Body,machine);
        }
        machine.Crew.Clear();
        for(int i=0;i<machine.ControlledCrew.Size();i++)CaelumMachineOperator.Release(machine.ControlledCrew[i],machine);
        machine.ControlledCrew.Clear();
    }
    static bool Capture(CaelumHostileMachine machine,CaelumPlayer user,int faction)
    {
        if(machine==null || !CaelumPlayerAuthority.CanMutate(user) || !Member(user,faction))return false;
        machine.EnsureMachine();
        if(machine.TarotDestroyed || machine.OwnerFaction!=CaelumMachineData.ENEMY_OWNER || EnemyOperators(machine) || !Admission())return false;
        ReleaseCrew(machine);
        machine.OwnerFaction=faction;machine.Captured=true;
        machine.CapturedIntact=machine.Structure!=null && machine.Structure.health==machine.Structure.StructuralMaximum && !machine.Sabotaged;
        machine.bFriendly=true;machine.Armed=machine.Operational();
        let cannon=CaelumCannon(machine);if(cannon!=null){cannon.Defending=true;cannon.LastOperator=null;}
        let ram=CaelumBatteringRam(machine);if(ram!=null){ram.Enabled=false;ram.Route.Clear();ram.TargetGate=null;}
        if(machine.Encounter!=null)machine.Encounter.ResolveVictory();
        return true;
    }
    static int Staffing(CaelumHostileMachine machine,bool attacking=false)
    {
        int count=0;
        for(int i=0;i<machine.ControlledCrew.Size();i++)
            if(Present(machine,machine.ControlledCrew[i],attacking))count++;
        return count;
    }
    static bool Assign(CaelumHostileMachine machine,Actor body)
    {
        if(!Eligible(machine,body) || !machine.Operational() || machine.OwnerFaction<0)return false;
        PruneControlled(machine);
        let cannon=CaelumCannon(machine);let npc=CaelumCombatActor(body);
        if(cannon!=null && npc!=null)
        {
            if(!cannon.AssignOperator(npc))return false;
            let soldier=CaelumPortDefender(npc);
            if(soldier!=null && soldier.Gun==null)
            {
                soldier.Gun=cannon;soldier.FollowingCrewRoute=false;
                int slot=0;for(int i=0;i<cannon.Operators.Size();i++)if(cannon.Operators[i]==npc){slot=i;break;}
                double side=(slot%2==0?-1:1)*(CaelumCannonData.HALF_TRACK+CaelumCannonData.WHEEL_RADIUS+soldier.Radius);
                soldier.Station=cannon.Pos+(-Sin(cannon.Angle)*side,Cos(cannon.Angle)*side,0);
            }
            return true;
        }
        int assigned=0;
        for(int i=0;i<machine.ControlledCrew.Size();i++)
        {
            if(machine.ControlledCrew[i]==body)return CaelumMachineOperator.Assign(body,machine);
            let bond=CaelumMachineOperator.Find(machine.ControlledCrew[i]);
            if(Eligible(machine,machine.ControlledCrew[i]) && bond!=null && bond.Machine==machine)assigned++;
        }
        if(cannon!=null)for(int i=0;i<cannon.Operators.Size();i++)if(Eligible(machine,cannon.Operators[i]))assigned++;
        if(assigned>=machine.RequiredCrew || !CaelumMachineOperator.Assign(body,machine))return false;
        for(int i=machine.ControlledCrew.Size()-1;i>=0;i--)
        {
            let bond=CaelumMachineOperator.Find(machine.ControlledCrew[i]);
            if(!Eligible(machine,machine.ControlledCrew[i]) || bond==null || bond.Machine!=machine)machine.ControlledCrew.Delete(i);
        }
        machine.ControlledCrew.Push(body);machine.Armed=true;return true;
    }
}
