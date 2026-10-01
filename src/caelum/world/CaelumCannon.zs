// #21: control explícito del escenario; sin selección autónoma de blancos.
class CaelumCannonFrame : Actor
{
    Default { +NOBLOCKMAP +NOGRAVITY }
    States { Spawn: CCFR A -1; Stop; }
}
class CaelumCannonBarrel : Actor
{
    Default { +NOBLOCKMAP +NOGRAVITY }
    States { Spawn: CCBR A -1; Stop; Loading: CCBR B -1; Stop; }
}
class CaelumCannonBlock : Actor
{
    Default { Radius 4; Height 12; +SOLID +NOGRAVITY +NOBLOOD +NODAMAGETHRUST }
    States { Spawn: TNT1 A -1; Stop; }
}
class CaelumCannonFlash : Actor
{
    Default { +NOBLOCKMAP +NOGRAVITY RenderStyle "Add"; }
    States { Spawn: CCFL A 2 Bright; Stop; }
}

class CaelumCannon : CaelumHostileMachine
{
    enum CannonPhase { LOADING, LOADED, LAUNCH, RECOVERY }
    Array<CaelumCombatActor> Operators;
    Array<CaelumCannonBlock> Blocks;
    CaelumCannonFrame Frame;
    CaelumCannonBarrel Barrel;
    CaelumCannonProjectile ActiveShot;
    bool Initialized, Defending, Requested;
    bool UnlimitedAmmunition;
    int CycleRevision;
    int Phase, Work, Ammunition, ShotSerial, Shots, Contacts, LastDamage;
    vector3 AimPoint, LastContactVelocity, LastLaunchVelocity;
    Actor IntendedTarget, LastContact, LastOperator;
    double Elevation;

    override bool CountsAsHostileObjective() { return !Defending; }

    void InitializeCannon(bool defender=false)
    {
        if(Initialized)return;
        Initialized=true; Defending=defender; bFriendly=defender; CycleRevision=1;
        Mass=CaelumCannonData.MACHINE_MASS;
        GuardRadius=CaelumCannonData.GUARD_RADIUS;
        RequiredCrew=CaelumCannonData.CREW;
        Phase=LOADING;
        Frame=CaelumCannonFrame(Spawn("CaelumCannonFrame",Pos));
        Barrel=CaelumCannonBarrel(Spawn("CaelumCannonBarrel",Pos));
        Frame.master=self; Barrel.master=self;
        // Cajas finitas de ruedas, eje, cola y tubo elevado.
        for(int i=0;i<18;i++)
        {
            let block=CaelumCannonBlock(Spawn("CaelumCannonBlock",Pos));
            block.master=self; Blocks.Push(block);
        }
        PlaceComponents();
    }

    bool AssignOperator(CaelumCombatActor body)
    {
        if(!Initialized || body==null || body.health<=0 || Neutralized)return false;
        if(body.bFriendly!=Defending)return false;
        if(!Defending && (body.SiegeCombatant==null || body.SiegeCombatant.Encounter!=Encounter))return false;
        for(int i=0;i<Operators.Size();i++)if(Operators[i]==body)return true;
        if(Operators.Size()>=CaelumCannonData.CREW)return false;
        // Un mismo operador no abastece dos máquinas a la vez.
        let it=ThinkerIterator.Create("CaelumCannon"); CaelumCannon other;
        while((other=CaelumCannon(it.Next()))!=null)
            for(int i=0;other!=self && i<other.Operators.Size();i++)if(other.Operators[i]==body)return false;
        if(body.SiegeCombatant!=null && body.SiegeCombatant.CrewMachine!=null)return false;
        Operators.Push(body);
        if(!Defending)body.SiegeCombatant.CrewMachine=self;
        return true;
    }

    int OperatorsPresent()
    {
        int count=0;
        for(int i=0;i<Operators.Size();i++)
        {
            let body=Operators[i];
            if(body!=null && body.health>0 && body.bFriendly==Defending
                && (body.Pos-Pos).Length()<=GuardRadius)count++;
        }
        return count;
    }

    bool ActivateCannon(int rounds)
    {
        if(!Initialized || Neutralized || rounds<0)return false;
        if(!Defending && !ArmMachine())return false;
        Armed=true;
        // La asignación inicial no se repite durante saves o activación.
        if(Ammunition==0 && Shots==0 && Work==0)Ammunition=rounds;
        return true;
    }

    bool EligibleTarget(Actor victim)
    {
        if(victim==null)return true; // Punto de mira explícito del escenario.
        if(victim.health<=0)return false;
        if(victim is "CaelumGateBlocker" || victim is "CaelumBreakableGate")return !Defending;
        if(victim is "CaelumPlayer")return !Defending;
        let npc=CaelumCombatActor(victim);
        if(npc==null || npc.health<=0)return false;
        if(Defending)return !npc.bFriendly && npc.SiegeCombatant!=null;
        return npc.bFriendly;
    }

    bool RequestShot(vector3 point, Actor intended=null)
    {
        if(!Armed || Neutralized || !EligibleTarget(intended))return false;
        // El tiro pendiente conserva su punto y blanco; no se reasigna a mitad de carga.
        if(Requested)return true;
        AimPoint=point; IntendedTarget=intended; Requested=true;
        return true;
    }

    void CancelShot()
    {
        Requested=false; IntendedTarget=null;
    }

    void PlaceComponents()
    {
        if(Frame==null || Barrel==null)return;
        double recoil=Phase==LAUNCH ? CaelumCannonData.RECOIL : 0;
        vector3 base=Pos-(Cos(Angle)*recoil,Sin(Angle)*recoil,0);
        Frame.SetOrigin(base,false); Frame.Angle=Angle;
        Barrel.SetOrigin(base+(0,0,CaelumCannonData.PIVOT_Z),false);
        Barrel.Angle=Angle; Barrel.Pitch=-Elevation;
        if(Phase==LOADING)Barrel.SetStateLabel("Loading");
        else Barrel.SetStateLabel("Spawn");
        for(int i=0;i<Blocks.Size();i++)
        {
            double x,y,z,h;
            if(i<6)
            {
                x=(i%3-1)*CaelumCannonData.WHEEL_RADIUS*0.7;
                y=(i<3 ? -1 : 1)*CaelumCannonData.HALF_TRACK;
                z=0; h=CaelumCannonData.WHEEL_RADIUS*2;
            }
            else if(i<12)
            {
                x=-(i-6)*CaelumCannonData.TRAIL/5;
                y=0; z=0; h=CaelumCannonData.WHEEL_RADIUS;
            }
            else
            {
                double along=CaelumCannonData.BREECH_X+(i-12)*(CaelumCannonData.MUZZLE_X-CaelumCannonData.BREECH_X)/5;
                x=along*Cos(Elevation);y=0;
                z=CaelumCannonData.PIVOT_Z+along*Sin(Elevation)-4;h=8;
            }
            Blocks[i].Height=h;
            Blocks[i].SetOrigin(base+(Cos(Angle)*x-Sin(Angle)*y,Sin(Angle)*x+Cos(Angle)*y,z),false);
        }
    }

    void Fire()
    {
        if(!Armed || Neutralized || Phase!=LOADED || OperatorsPresent()==0)return;
        if(!EligibleTarget(IntendedTarget)){CancelShot();return;}
        if(ActiveShot!=null || (!UnlimitedAmmunition && Ammunition<=0))return;
        vector3 pivot=Pos+(0,0,CaelumCannonData.PIVOT_Z);
        vector3 delta=AimPoint-pivot;
        if(delta.Length()<CaelumCannonData.LENGTH)return;
        vector3 direction=delta.Unit();
        Angle=VectorAngle(direction.X,direction.Y);
        Elevation=VectorAngle(direction.XY.Length(),direction.Z);
        Phase=LAUNCH; Work=0; Requested=false;
        PlaceComponents();
        pivot=Barrel.Pos;
        // Se barre desde el eje del tubo a la boca, no se teletransporta tras un muro.
        let shot=CaelumCannonProjectile(Spawn("CaelumCannonProjectile",pivot-(0,0,CaelumCannonData.RADIUS)));
        if(shot==null){Phase=LOADED; return;}
        ShotSerial++; Shots++; if(!UnlimitedAmmunition)Ammunition--;
        shot.Launcher=self; shot.target=self; shot.master=self;
        shot.Defending=Defending; shot.Serial=ShotSerial;
        for(int i=0;i<Operators.Size();i++)if(Operators[i]!=null && Operators[i].health>0)LastOperator=Operators[i];
        shot.Operator=LastOperator;
        shot.Vel=direction*CaelumCannonData.SPEED;
        LastLaunchVelocity=shot.Vel;
        shot.FlightVelocity=shot.Vel; shot.Angle=Angle; shot.Pitch=-Elevation;
        ActiveShot=shot;
        shot.SweepMuzzle(direction*(CaelumCannonData.MUZZLE_X+CaelumCannonData.RADIUS));
        if(!shot.Spent)
        {
            let flash=Spawn("CaelumCannonFlash",pivot+direction*CaelumCannonData.MUZZLE_X);
            if(flash!=null){flash.Angle=Angle;flash.Pitch=-Elevation;flash.master=self;}
        }
    }

    override void Tick()
    {
        if(isFrozen())return;
        Super.Tick();
        if(Initialized && CycleRevision<1)
        {
            // Mantiene la fracción de trabajo ya realizada, sin completar ni
            // duplicar un disparo al actualizar una partida de #21.
            Work=int(double(Work)*CaelumCannonData.CYCLE/CaelumCannonData.LEGACY_CYCLE);
            CycleRevision=1;
        }
        if(!Initialized || !Armed || Neutralized)return;
        int staffing=OperatorsPresent();
        if(staffing==0)return;
        if(Phase==LOADED)
        {
            if(Requested)Fire();
            return;
        }
        Work+=staffing;
        if(Phase==LAUNCH){Phase=RECOVERY; PlaceComponents();}
        if(Phase==RECOVERY && Work>=CaelumCannonData.RECOVERY*CaelumCannonData.CREW)
        { Phase=LOADING; PlaceComponents(); }
        if(Work>=CaelumCannonData.CYCLE*CaelumCannonData.CREW)
        { Phase=LOADED; Work=0; PlaceComponents(); if(Requested)Fire(); }
    }

    override void OnDestroy()
    {
        if(Frame!=null)Frame.Destroy(); if(Barrel!=null)Barrel.Destroy();
        for(int i=0;i<Blocks.Size();i++)if(Blocks[i]!=null)Blocks[i].Destroy();
        // Un proyectil liberado continúa aunque desaparezca su lanzador.
        Super.OnDestroy();
    }
    Default { +NOBLOCKMAP }
}

class CaelumCannonProjectile : FastProjectile
{
    CaelumCannon Launcher;
    Actor Operator, Contact;
    bool Defending, Spent;
    int Serial, FlightTics, ContactCount, AppliedDamage;
    vector3 FlightVelocity, ContactVelocity;

    override void PostBeginPlay()
    {
        Super.PostBeginPlay();
        A_SetSize(CaelumCannonData.RADIUS,2*CaelumCannonData.RADIUS);
    }

    bool Eligible(Actor victim)
    {
        if(victim is "CaelumGateBlocker")return !Defending;
        if(victim is "CaelumPlayer")return !Defending;
        let npc=CaelumCombatActor(victim);
        return npc!=null && npc.health>0 && (Defending ? !npc.bFriendly && npc.SiegeCombatant!=null : npc.bFriendly);
    }

    void ResolveContact(Actor victim)
    {
        if(Spent)return;
        Spent=true; Contact=victim; ContactVelocity=FlightVelocity; ContactCount++;
        if(victim!=null && Eligible(victim))
        {
            let blocker=CaelumGateBlocker(victim);
            if(blocker!=null)
            {
                let gate=CaelumBreakableGate(blocker.master);
                if(gate!=null)
                {
                    vector3 normal=(-Sin(gate.Angle),Cos(gate.Angle),0);
                    if(normal.X*FlightVelocity.X+normal.Y*FlightVelocity.Y<0)normal=-normal;
                    AppliedDamage=gate.ApplySiegeImpact(self,Serial,CaelumCannonData.PROJECTILE_MASS,FlightVelocity,normal);
                }
            }
            else
            {
                let user=CaelumPlayer(victim); let npc=CaelumCombatActor(victim);
                if(user!=null || (npc!=null && !npc.DisableCaelumImpactContacts))
                {
                    let body=user!=null ? user.BuildImpactPhysicsBody() : npc.BuildImpactPhysicsBody();
                    let sourceBody=new("ImpactBody");
                    sourceBody.Mass=CaelumCannonData.PROJECTILE_MASS;
                    sourceBody.Height=Height; sourceBody.Position=Pos; sourceBody.Velocity=FlightVelocity;
                    sourceBody.Restitution=CaelumConstants.IMPACT_RESTITUTION;
                    let result=new("ImpactResult");
                    ImpactPhysics.ResolveBodies(sourceBody,body,FlightVelocity,result);
                    if(result.Valid)
                    {
                        int before=victim.health;
                        victim.Vel.X+=result.Normal.X*result.TargetDeltaSpeed;
                        victim.Vel.Y+=result.Normal.Y*result.TargetDeltaSpeed;
                        if(user!=null)user.ReceiveCaelumImpact(result.TargetDeltaSpeed,CaelumConstants.IMPACT_KIND_ENVIRONMENT,self,1,body.Mass,sourceBody.Mass,result.ClosingSpeed,result.Impulse,result.TargetContactMinimumHeightRatio,result.TargetContactMaximumHeightRatio);
                        else npc.ReceiveCaelumImpact(result.TargetDeltaSpeed,CaelumConstants.IMPACT_KIND_ENVIRONMENT,self,1,body.Mass,sourceBody.Mass,result.ClosingSpeed,result.Impulse,result.TargetContactMinimumHeightRatio,result.TargetContactMaximumHeightRatio);
                        AppliedDamage=before-victim.health;
                    }
                }
            }
        }
        if(Launcher!=null)
        {
            Launcher.Contacts++; Launcher.LastDamage=AppliedDamage;
            Launcher.LastContact=victim; Launcher.LastContactVelocity=ContactVelocity;
        }
    }

    override int SpecialMissileHit(Actor victim)
    {
        if(victim==Launcher || (victim is "CaelumCannonBlock" && victim.master==Launcher))return MHIT_PASS;
        if(!victim.bSolid && !victim.bShootable)return MHIT_PASS;
        ResolveContact(victim);
        return 0; // Bloqueo; daño ya resuelto, sin DamageMobj nativo adicional.
    }

    void SweepMuzzle(vector3 offset)
    {
        int steps=int(Ceil(offset.Length()/CaelumCannonData.RADIUS));
        vector3 step=offset/Max(1,steps);
        for(int i=0;i<steps && !Spent;i++)
        {
            if(!TryMove(Pos.XY+step.XY,true))
            { ResolveContact(BlockingMobj); SetStateLabel("Death"); return; }
            AddZ(step.Z);
            if(Pos.Z<=floorz || Pos.Z+Height>=ceilingz)
            { ResolveContact(null); SetStateLabel("Death"); return; }
        }
        if(Spent)SetStateLabel("Death");
    }

    override void Tick()
    {
        if(isFrozen())return;
        if(!Spent)
        {
            FlightTics++;
            if(FlightTics>CaelumCannonData.MAX_FLIGHT_TICS){Destroy();return;}
            // FastProjectile subdivide colisiones, pero no integra gravedad.
            // GetGravity conserva la configuración nativa de nivel/sector/actor.
            Vel.Z-=GetGravity();
            FlightVelocity=Vel;
            Pitch=PitchFromVel();
        }
        Super.Tick();
    }
    action void A_CannonStop()
    {
        let shot=CaelumCannonProjectile(self);
        shot.ResolveContact(shot.BlockingMobj);
        tics=CaelumCannonData.SPENT_TICS;
        Vel=(0,0,0); bMissile=false; bNoGravity=true;
    }
    Default
    {
        Damage 0; Gravity 1;
        -NOGRAVITY +NODAMAGETHRUST +DONTSPLASH +NOBLOOD
    }
    States
    {
    Spawn: CCSH A -1; Stop;
    Death: TNT1 A 1 A_CannonStop; Stop;
    }
}
