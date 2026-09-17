// Peligros físicos 4.36.0a. Los mecanismos conservan su estado en el mapa/hub.
// La trampilla necesita un foso real debajo: no altera la geometría ni teleporta.
class CaelumTrapdoorCover : Actor
{
    Default
    {
        +NOINTERACTION
        +NOGRAVITY
        +FLATSPRITE
    }
    States { Spawn: CSUF A -1; Stop; }
}

class CaelumTrapdoor : Actor
{
    CaelumTrapdoorCover Cover;
    bool Opened;
    int ActivationCount;

    override void PostBeginPlay()
    {
        Super.PostBeginPlay();
        // El origen es la cara inferior; la tapa visible coincide con el apoyo.
        Cover = CaelumTrapdoorCover(Spawn("CaelumTrapdoorCover", Pos + (0,0,Height), NO_REPLACE));
        if (Cover != null)
        {
            Cover.Scale = (Radius / 64.0, Radius / 64.0);
            Cover.master = self;
        }
    }

    bool IsStandingOn(Actor body)
    {
        if (Opened || body == null || body.health <= 0 || body.bNoClip
            || body.bNoGravity || !body.bSolid || body.Vel.Z > 0.0) return false;
        let user = CaelumPlayer(body);
        if (user != null)
        {
            if (!user.CharacterCreationComplete || user.CreationWizardOpen
                || (user.player.cheats & CF_PREDICTING) || !user.player.onground) return false;
        }
        else if (CaelumCombatActor(body) == null || !body.bOnMobj) return false;
        return Abs(body.Pos.Z - (Pos.Z + Height)) <= 0.5
            && Abs(body.Pos.X - Pos.X) < Radius
            && Abs(body.Pos.Y - Pos.Y) < Radius;
    }

    bool OpenFor(Actor body)
    {
        if (!IsStandingOn(body)) return false;
        Opened = true;
        ActivationCount++;
        bSolid = false;
        if (Cover != null) { Cover.Destroy(); Cover = null; }
        let user = CaelumPlayer(body);
        if (user != null)
        {
            CaelumTimeAdvanceState.Halt(user);
            CaelumRestState.Interrupt(user, "CA_REST_MOVED");
        }
        A_StartSound("caelum/world/door_open", CHAN_BODY);
        return true;
    }

    override void Tick()
    {
        if (Opened) return;
        Super.Tick();
        // Consulta espacial, no recorre la población completa del mapa.
        let nearby = BlockThingsIterator.Create(self, Radius);
        while (nearby.Next()) if (OpenFor(nearby.thing)) break;
    }

    override void OnDestroy()
    {
        if (Cover != null) Cover.Destroy();
        Super.OnDestroy();
    }

    Default
    {
        Radius 128;
        Height 8;
        +SOLID
        +CANPASS
        +ACTLIKEBRIDGE
        +NOGRAVITY
        +CANNOTPUSH
        +DONTTHRUST
        RenderStyle "None";
    }
    States { Spawn: TNT1 A -1; Stop; }
}

// Conserva dimensiones, masa y arte del granito pequeño existente.
// args[0]: impulso horizontal en MU/tic; cero suelta verticalmente la roca.
class CaelumHazardRock : CaelumRockGraniteHalf
{
    bool Released;
    vector3 BeforeMove;
    vector3 BeforeVelocity;
    Actor LastVerticalVictim;
    int VerticalImpactCount;
    double LastVerticalImpulse;

    override bool IsEnvironmentMovable() { return Released; }

    bool Release()
    {
        if (Released) return false;
        Released = true;
        bNoGravity = false;
        double speed = Max(0, args[0]);
        Vel = (Cos(Angle) * speed, Sin(Angle) * speed, 0);
        return true;
    }

    bool IsDescendingAbove(Actor other)
    {
        return Released && other != null && BeforeVelocity.Z < 0
            && BeforeMove.Z >= other.Pos.Z + other.Height - 0.5;
    }

    void ResolveVerticalLanding(Actor other)
    {
        if (other == null || other == LastVerticalVictim || other.health <= 0
            || !other.bSolid || other.bNoClip || !IsDescendingAbove(other)
            || Abs(Pos.Z - (other.Pos.Z + other.Height)) > 0.5
            || Abs(Pos.X - other.Pos.X) >= Radius + other.Radius
            || Abs(Pos.Y - other.Pos.Y) >= Radius + other.Radius) return;
        let user = CaelumPlayer(other);
        let npc = CaelumCombatActor(other);
        if (user == null && npc == null) return;
        if (npc != null && npc.DisableCaelumImpactContacts) return;
        if (user != null && (!user.CharacterCreationComplete || user.CreationWizardOpen)) return;

        ImpactBody sourceBody = new("ImpactBody");
        sourceBody.Mass = GetEnvironmentMassKg(); sourceBody.Height = Height;
        sourceBody.Position = BeforeMove; sourceBody.Velocity = BeforeVelocity;
        sourceBody.Restitution = CaelumConstants.IMPACT_RESTITUTION;
        ImpactBody receiver = user != null ? user.BuildImpactPhysicsBody() : npc.BuildImpactPhysicsBody();
        ImpactResult result = new("ImpactResult");
        ImpactPhysics.ResolveVerticalBodies(sourceBody, receiver, result);
        if (!result.Valid) return;
        LastVerticalVictim = other;
        VerticalImpactCount++;
        LastVerticalImpulse = result.Impulse;
        // El motor resuelve el apoyo. El receptor biológico recibe una sola
        // transferencia por aterrizaje; no se duplica como choque horizontal.
        if (user != null)
            user.ReceiveCaelumImpact(result.TargetDeltaSpeed, CaelumConstants.IMPACT_KIND_ENVIRONMENT,
                self, GetEnvironmentImpactMultiplier(), receiver.Mass, sourceBody.Mass,
                result.ClosingSpeed, result.Impulse, 1.0, 1.0);
        else
            npc.ReceiveCaelumImpact(result.TargetDeltaSpeed, CaelumConstants.IMPACT_KIND_ENVIRONMENT,
                self, GetEnvironmentImpactMultiplier(), receiver.Mass, sourceBody.Mass,
                result.ClosingSpeed, result.Impulse, 1.0, 1.0);
    }

    override void Tick()
    {
        BeforeMove = Pos; BeforeVelocity = Vel;
        Super.Tick();
        if (!Released) return;
        if (LastVerticalVictim != null
            && (Pos.Z > LastVerticalVictim.Pos.Z + LastVerticalVictim.Height + 2
                || Abs(Pos.X - LastVerticalVictim.Pos.X) > Radius + LastVerticalVictim.Radius + 2
                || Abs(Pos.Y - LastVerticalVictim.Pos.Y) > Radius + LastVerticalVictim.Radius + 2))
            LastVerticalVictim = null;
        if (BeforeVelocity.Z < 0)
        {
            let nearby = BlockThingsIterator.Create(self, Radius);
            while (nearby.Next()) ResolveVerticalLanding(nearby.thing);
        }
        double traveled = (Pos.XY - BeforeMove.XY).Length();
        if (traveled > 0.001) Roll -= traveled / Radius * 57.295779513;
    }

    override bool TryPushFrom(Actor pusher, double physicalPower, double pushForce)
    {
        return Released && Super.TryPushFrom(pusher, physicalPower, pushForce);
    }

    Default
    {
        +NOGRAVITY
        +CANPASS
        +NOFRICTION
        // Rodadura sin motor: un solo impulso; la pared detiene la roca.
        Friction 1.0;
    }
}

// args[0]: TID del bloque preparado. Sin TID válido no activa otros mecanismos.
class CaelumHazardReleaseSwitch : Actor
{
    bool Spent;

    override bool Used(Actor activator)
    {
        let user = CaelumPlayer(activator);
        if (Spent || user == null || user.health <= 0 || !user.CharacterCreationComplete
            || user.CreationWizardOpen || (user.player.cheats & CF_PREDICTING)
            || args[0] <= 0 || user.Distance2D(self) > user.UseRange + Radius
            || user.Pos.Z >= Pos.Z + Height || user.Pos.Z + user.Height <= Pos.Z
            || !user.CheckSight(self)) return false;
        let it = ActorIterator.Create(args[0], "CaelumHazardRock");
        CaelumHazardRock rock;
        bool changed = false;
        while ((rock = CaelumHazardRock(it.Next())) != null) changed = rock.Release() || changed;
        if (!changed) return false;
        Spent = true;
        A_StartSound("caelum/world/door_open", CHAN_BODY);
        user.A_Print(StringTable.Localize("CA_HAZARD_RELEASED", false));
        return true;
    }
    Default
    {
        Tag "$CA_HAZARD_SWITCH";
        Radius 16;
        Height 64;
        +SOLID
        +NOGRAVITY
        +CANNOTPUSH
        +DONTTHRUST
        +WALLSPRITE
        Scale 0.5;
    }
    States { Spawn: CSGT A -1; Stop; }
}

class CaelumHazardDiagnostics : Object play
{
    static void Report()
    {
        Console.Printf("[Caelum 4.36.0a] Peligros físicos: mapa=%s", level.MapName);
        let it = ThinkerIterator.Create("CaelumTrapdoor"); CaelumTrapdoor trap;
        int count = 0;
        while ((trap = CaelumTrapdoor(it.Next())) != null)
        {
            count++;
            Console.Printf("Trampilla TID=%d abierta=%d activaciones=%d soporte=%d tapa=%d z=%.1f",
                trap.tid, trap.Opened, trap.ActivationCount, trap.bSolid, trap.Cover != null, trap.Pos.Z + trap.Height);
        }
        let rocks = ThinkerIterator.Create("CaelumHazardRock"); CaelumHazardRock rock;
        while ((rock = CaelumHazardRock(rocks.Next())) != null)
            Console.Printf("Roca TID=%d liberada=%d masa=%.1f velocidad=(%.2f,%.2f,%.2f) impactos verticales=%d impulso=%.2f",
                rock.tid, rock.Released, rock.GetEnvironmentMassKg(), rock.Vel.X, rock.Vel.Y, rock.Vel.Z,
                rock.VerticalImpactCount, rock.LastVerticalImpulse);
        let switches = ThinkerIterator.Create("CaelumHazardReleaseSwitch"); CaelumHazardReleaseSwitch lever;
        while ((lever = CaelumHazardReleaseSwitch(switches.Next())) != null)
            Console.Printf("Mecanismo destino=%d usado=%d", lever.args[0], lever.Spent);
        if (count == 0) Console.Printf("La galería de peligros está en MAP08, conectada desde MAP05.");
    }
}
