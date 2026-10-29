// #415: maquinas del mismo encuentro. La resolucion resumida conserva
// tripulantes, carga, municion y golpes sin desplazar piezas ni proyectiles.
class CaelumAbsentStructureHit : Object play
{
    CaelumBreakableGate Gate;
    CaelumHostileMachine Machine;
    Actor Source;
    int Serial;
    double Mass;
    vector3 Velocity;

    void Commit()
    {
        if(Gate==null || Source==null)return;
        vector3 normal=(-Sin(Gate.Angle),Cos(Gate.Angle),0);
        if(normal.X*Velocity.X+normal.Y*Velocity.Y<0)normal=-normal;
        int damage=Gate.ApplySiegeImpact(Source,Serial,Mass,Velocity,normal);
        let cannon=CaelumCannon(Machine);let ram=CaelumBatteringRam(Machine);
        if(cannon!=null){cannon.LastContact=Gate;cannon.LastDamage=damage;cannon.LastContactVelocity=Velocity;cannon.Contacts++;}
        if(ram!=null){ram.LastContact=Gate;ram.LastDamage=damage;ram.LastContactVelocity=Velocity;ram.ImpactCount++;}
    }
}

class CaelumAbsentMachine : Object play
{
    CaelumAbsentBattle Battle;
    CaelumHostileMachine Machine;
    CaelumCannonProjectile InFlight;
    double WorkFraction,RamRemaining;

    void Capture()
    {
        let cannon=CaelumCannon(Machine);let ram=CaelumBatteringRam(Machine);
        if(cannon!=null)InFlight=cannon.ActiveShot;
        if(ram!=null)
        {
            RamRemaining=ram.Phase==CaelumBatteringRam.RECOVERY?double(ram.RecoveryLeft)/TICRATE
                :ram.Phase==CaelumBatteringRam.CONTACT?double(CaelumRamData.RECOVERY_TICS)/TICRATE
                :Ceil(Max(0,(CaelumRamData.EXTENDED_OFFSET-ram.StrokeOffset)*ram.SizeFactor)/CaelumRamData.STRIKE_SPEED)/TICRATE;
        }
        if(Machine.Encounter!=null)Machine.ObserveGuards();
    }

    bool CrewAlive(CaelumCombatActor body)
    {
        return body!=null && body.health>0 && body.AbsentCombatant!=null
            && body.AbsentCombatant.Battle==Battle && body.AbsentCombatant.Alive();
    }

    int Staffing(bool attack=false)
    {
        int count=0;let cannon=CaelumCannon(Machine);
        if(cannon!=null)
        {
            for(int i=0;i<cannon.Operators.Size();i++)
            {
                let body=cannon.Operators[i];
                if(CrewAlive(body) && body.bFriendly==cannon.Defending && (!attack || !CaelumBattleCry.Active(body)))count++;
            }
        }
        else for(int i=0;i<Machine.Crew.Size();i++)
        {
            let entry=Machine.Crew[i];let body=entry!=null?entry.Body:null;
            if(CrewAlive(body) && !body.bFriendly && (!attack || !CaelumBattleCry.Active(body)))count++;
        }
        return count;
    }

    bool Eligible(CaelumCannon cannon,Actor candidate)
    {
        let gate=CaelumBreakableGate(candidate);
        if(gate==null && candidate is 'CaelumGateBlocker')gate=CaelumBreakableGate(candidate.master);
        if(gate!=null)return !cannon.Defending && !gate.Broken && !gate.Opened && gate.health>0;
        let npc=CaelumCombatActor(candidate);
        return CrewAlive(npc) && npc.bFriendly!=cannon.Defending;
    }

    Actor Choose(CaelumCannon cannon)
    {
        if(Eligible(cannon,cannon.IntendedTarget))return cannon.IntendedTarget;
        for(int i=0;i<Battle.Rows.Size();i++)if(Eligible(cannon,Battle.Rows[i].Body))return Battle.Rows[i].Body;
        let port=CaelumPortSiege(Battle.Encounter);
        if(!cannon.Defending && port!=null)
            for(int i=0;i<port.Gates.Size();i++)if(Eligible(cannon,port.Gates[i]))return port.Gates[i];
        return null;
    }

    void Structure(CaelumBreakableGate gate,Actor source,int serial,double mass,vector3 velocity)
    {
        let hit=new('CaelumAbsentStructureHit');hit.Gate=gate;hit.Machine=Machine;
        hit.Source=source;hit.Serial=serial;hit.Mass=mass;hit.Velocity=velocity;Battle.StructureHits.Push(hit);
    }

    void CannonContact(CaelumCannon cannon,Actor victim,int serial,vector3 velocity)
    {
        let gate=CaelumBreakableGate(victim);
        if(gate==null && victim is 'CaelumGateBlocker')gate=CaelumBreakableGate(victim.master);
        if(gate!=null){Structure(gate,cannon,serial,CaelumCannonData.PROJECTILE_MASS,velocity);return;}
        let npc=CaelumCombatActor(victim);
        if(!CrewAlive(npc) || npc.DisableCaelumImpactContacts)return;
        // El parche del contacto usa el mismo calibre y anatomia que el disparo
        // nativo. Se construye con limites explicitos, sin mover al receptor.
        vector3 direction=velocity.Unit();
        vector3 centre=npc.Pos+(0,0,npc.Height/2)-direction*npc.Radius;
        vector3 normal=Abs(direction.X)>=Abs(direction.Y)?(direction.X>=0?1:-1,0,0):(0,direction.Y>=0?1:-1,0);
        if(Abs(direction.Z)>Max(Abs(direction.X),Abs(direction.Y)))normal=(0,0,direction.Z>=0?1:-1);
        let moving=new('ImpactBody');moving.Mass=CaelumCannonData.PROJECTILE_MASS;
        moving.Height=2*CaelumCannonData.RADIUS;moving.Position=centre-(0,0,CaelumCannonData.RADIUS);
        moving.Velocity=velocity;moving.Restitution=CaelumConstants.IMPACT_RESTITUTION;
        let body=npc.BuildImpactPhysicsBody();let impact=new('ImpactResult');
        ImpactPhysics.ResolveBodies(moving,body,normal,impact);if(!impact.Valid)return;
        let area=new('CaelumImpactArea');
        vector3 half=(CaelumCannonData.RADIUS,CaelumCannonData.RADIUS,CaelumCannonData.RADIUS);
        area.Build(npc,null,npc.AnatomyProfile,impact.TargetContactMinimumHeightRatio,
            impact.TargetContactMaximumHeightRatio,-normal,true,centre-half,centre+half);
        let result=new('CaelumAbsentDamage');
        result.Impact(cannon,npc,CaelumImpactEnergy.Received(body.Mass,moving.Mass,impact.ClosingSpeed),impact.TargetDeltaSpeed,-normal,area);
        npc.AbsentCombatant.QueueMachine(cannon,result);
        cannon.Contacts++;cannon.LastContact=npc;cannon.LastDamage=int(result.Life);
        cannon.LastContactVelocity=velocity;
    }

    void CannonAdvance(CaelumCannon cannon,double seconds)
    {
        if(InFlight!=null)
        {
            // El disparo liberado sobrevive a una baja de su dotacion; se
            // retira una sola vez para no reaparecer al volver al mapa.
            if(!InFlight.Spent)CannonContact(cannon,cannon.IntendedTarget,InFlight.Serial,InFlight.FlightVelocity);
            InFlight.Spent=true;InFlight.Destroy();InFlight=null;cannon.ActiveShot=null;
        }
        if(!cannon.Armed || cannon.Neutralized)return;
        int staff=Staffing();if(staff<=0)return;
        double ticks=seconds*TICRATE;
        while(ticks>0)
        {
            if(cannon.Phase==CaelumCannon.LOADED)
            {
                if(Staffing(true)<=0 || (!cannon.UnlimitedAmmunition && cannon.Ammunition<=0))return;
                Actor victim=Choose(cannon);if(victim==null)return;
                cannon.IntendedTarget=victim;cannon.AimPoint=victim.Pos+(0,0,victim.Height/2);
                if(victim is 'CaelumBreakableGate')cannon.AimPoint.Z=victim.Pos.Z+CaelumCannonData.PIVOT_Z;
                vector3 direction=cannon.AimPoint-cannon.Pos-(0,0,CaelumCannonData.PIVOT_Z);
                if(direction.Length()<=0)return;
                vector3 velocity=direction.Unit()*CaelumCannonData.SPEED;
                cannon.ShotSerial++;cannon.Shots++;if(!cannon.UnlimitedAmmunition)cannon.Ammunition--;
                cannon.LastLaunchVelocity=velocity;cannon.Requested=false;
                CannonContact(cannon,victim,cannon.ShotSerial,velocity);
                cannon.Work=0;WorkFraction=0;cannon.Phase=CaelumCannon.RECOVERY;
            }
            double work=cannon.Work+WorkFraction;
            double spent=Min(ticks,Max(0,(CaelumCannonData.CYCLE*CaelumCannonData.CREW-work)/staff));
            ticks-=spent;work+=spent*staff;cannon.Work=int(work);WorkFraction=work-cannon.Work;
            if(work+0.000000001>=CaelumCannonData.CYCLE*CaelumCannonData.CREW)
            {cannon.Work=0;WorkFraction=0;cannon.Phase=CaelumCannon.LOADED;}
            else cannon.Phase=work>=CaelumCannonData.RECOVERY*CaelumCannonData.CREW?CaelumCannon.LOADING:CaelumCannon.RECOVERY;
        }
    }

    void RamAdvance(CaelumBatteringRam ram,double seconds)
    {
        if(!ram.Enabled || !ram.Armed || ram.Neutralized || Staffing()<ram.RequiredCrew)return;
        let gate=ram.TargetGate;if(gate==null || gate.Opened || gate.Broken)return;
        double budget=seconds;
        while(budget>0)
        {
            if(RamRemaining>budget){RamRemaining-=budget;break;}
            budget-=RamRemaining;RamRemaining=0;
            if(Staffing(true)<ram.RequiredCrew)return;
            ram.StrikeSerial++;ram.SpentImpact=true;
            vector3 velocity=(Cos(ram.FinalAngle)*CaelumRamData.STRIKE_SPEED,Sin(ram.FinalAngle)*CaelumRamData.STRIKE_SPEED,0);
            Structure(gate,ram.Head,ram.StrikeSerial,ram.AssemblyMass,velocity);
            ram.Phase=CaelumBatteringRam.RECOVERY;
            RamRemaining=(CaelumRamData.RECOVERY_TICS+Ceil((CaelumRamData.EXTENDED_OFFSET-CaelumRamData.RETRACT)*ram.SizeFactor/CaelumRamData.STRIKE_SPEED))/TICRATE;
        }
        ram.RecoveryLeft=Min(CaelumRamData.RECOVERY_TICS,Max(1,int(Ceil(RamRemaining*TICRATE))));
    }

    void Advance(double seconds)
    {
        if(Machine==null || Machine.bDestroyed)return;
        let cannon=CaelumCannon(Machine);let ram=CaelumBatteringRam(Machine);
        if(cannon!=null)CannonAdvance(cannon,seconds);
        else if(ram!=null)RamAdvance(ram,seconds);
    }

    bool CanWork()
    {
        if(Machine==null || Machine.bDestroyed)return false;
        if(InFlight!=null && !InFlight.Spent)return true;
        if(!Machine.Armed || Machine.Neutralized || Staffing()<=0)return false;
        let cannon=CaelumCannon(Machine);let ram=CaelumBatteringRam(Machine);
        if(cannon!=null)return (cannon.UnlimitedAmmunition || cannon.Ammunition>0) && Choose(cannon)!=null;
        return ram!=null && ram.Enabled && ram.TargetGate!=null && !ram.TargetGate.Broken
            && !ram.TargetGate.Opened && Staffing()>=ram.RequiredCrew;
    }

    void Observe()
    {
        if(Machine==null || !Machine.Armed || Machine.Neutralized || Machine.LocalGuards.Size()==0)return;
        for(int i=0;i<Machine.LocalGuards.Size();i++)
        {
            let entry=Machine.LocalGuards[i];
            if(entry!=null && !entry.ConfirmedDead && !(entry==Battle.Encounter.Boss && Battle.Encounter.BossRetreated))return;
        }
        Machine.Neutralized=true;Machine.NeutralizationCount++;Machine.Vel=(0,0,0);
    }
}
