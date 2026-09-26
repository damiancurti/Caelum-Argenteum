// Peligros físicos 4.36.0b. Los mecanismos conservan su estado en el mapa/hub.
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

// Roca esférica de 96 MU de diámetro. Masa a 32 MU/m y granito de 2700 kg/m³.
// args[0]: impulso horizontal en MU/tic; cero suelta verticalmente la roca.
class CaelumHazardRock : CaelumRockGraniteHalf
{
    const GALLERY_ROLL_SPEED = 32;
    bool BoulderSizeReady;
    CaelumHazardRockVisual BoulderVisual;
    bool Released;
    vector3 BeforeMove;
    vector3 BeforeVelocity;
    Actor LastVerticalVictim;
    int VerticalImpactCount;
    double LastVerticalImpulse;

    override bool IsEnvironmentMovable() { return Released; }

    double GetReleaseSpeed()
    {
        // Recupera la galería antigua sin relanzar una roca ya liberada.
        // Otros mapas y velocidades elegidas por el mapeador se conservan.
        if (level.MapName == "MAP08" && tid == 43602 && args[0] == 8)
            return GALLERY_ROLL_SPEED;
        return Max(0, args[0]);
    }

    bool Release()
    {
        if (Released) return false;
        Released = true;
        bNoGravity = false;
        double speed = GetReleaseSpeed();
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
        // Al cargar un bloque antiguo junto a un obstáculo, esperar a que
        // quepa antes de ampliar su colisión. No desplazar ni relanzar la roca.
        if (!BoulderSizeReady && A_SetSize(48, 96, true))
        {
            Mass = 38170;
            BoulderSizeReady = true;
        }
        A_SetRenderStyle(1.0, STYLE_None);
        if (BoulderVisual == null)
        {
            BoulderVisual = CaelumHazardRockVisual(Spawn("CaelumHazardRockVisual", Pos, NO_REPLACE));
            if (BoulderVisual != null) BoulderVisual.master = self;
        }
        BeforeMove = Pos; BeforeVelocity = Vel;
        Super.Tick();
        if (!Released) { UpdateRollingSound(false); return; }
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
        bool rolling = traveled > 0.01 && Vel.XY.Length() > 0.01
            && Abs(Vel.Z) < 0.01 && (Pos.Z <= floorz + 0.5 || bOnMobj);
        if (rolling) Roll -= traveled / Radius * 57.295779513;
        UpdateRollingSound(rolling);
    }

    void UpdateRollingSound(bool rolling)
    {
        // La consulta nativa recupera el bucle al cargar y evita reiniciarlo
        // cada tic. CHAN_5 queda reservado a la fricción de esta roca.
        if (rolling)
        {
            if (!IsActorPlayingSound(CHAN_5, "caelum/world/rock_roll"))
                A_StartSound("caelum/world/rock_roll", CHAN_5, CHANF_LOOP);
        }
        else A_StopSound(CHAN_5);
    }

    override void OnDestroy()
    {
        A_StopSound(CHAN_5);
        if (BoulderVisual != null) BoulderVisual.Destroy();
        Super.OnDestroy();
    }

    override bool TryPushFrom(Actor pusher, double physicalPower, double pushForce)
    {
        return Released && Super.TryPushFrom(pusher, physicalPower, pushForce);
    }

    Default
    {
        // La base pequeña permite recuperar guardados antiguos sin encajarlos.
        // Tick amplía a 48/96 y 38170 kg sólo cuando cabe.
        RenderStyle "None";
        +NOGRAVITY
        +CANPASS
        +NOFRICTION
        // Rodadura sin motor: un solo impulso; la pared detiene la roca.
        Friction 1.0;
    }
}

class CaelumHazardRockVisual : Actor
{
    override void Tick()
    {
        Super.Tick();
        if (master == null) { Destroy(); return; }
        SetOrigin(master.Pos + (0,0,master.Radius), false);
        Angle = master.Angle; Roll = master.Roll;
        Scale = (master.Radius / 48.0, master.Radius / 48.0 * level.pixelstretch);
    }
    Default { +NOINTERACTION +NOGRAVITY }
    States { Spawn: CARK A -1; Stop; }
}

class CaelumLeverColumn : Actor
{
    Default { +NOINTERACTION +NOGRAVITY }
    States { Spawn: CARK A -1; Stop; }
}

class CaelumLeverFace : Actor
{
    Default { +NOINTERACTION +NOGRAVITY +WALLSPRITE Scale 0.045; }
    States { Spawn: CLVR A -1; Stop; Down: CLVR B -1; Stop; }
}

// args[0]: TID del mecanismo preparado. Sin TID válido no activa otros mecanismos.
class CaelumHazardReleaseSwitch : Actor
{
    bool Spent;
    CaelumLeverColumn ColumnVisual;
    CaelumLeverFace LeverVisual;

    override void Tick()
    {
        Super.Tick();
        // args[1]=1 permite montar sólo la palanca delante de una pared.
        // El modo por defecto incorpora una columna de mampostería.
        A_SetRenderStyle(1.0, STYLE_None);
        Height = 96;
        if (args[1] == 0 && ColumnVisual == null)
            ColumnVisual = CaelumLeverColumn(Spawn("CaelumLeverColumn", Pos, NO_REPLACE));
        if (ColumnVisual != null)
        {
            ColumnVisual.Angle = Angle;
            ColumnVisual.Scale.Y = level.pixelstretch;
        }
        if (LeverVisual == null)
        {
            vector3 offset = args[1] == 0 ? (-Cos(Angle)*16.5, -Sin(Angle)*16.5, 47) : (0,0,47);
            LeverVisual = CaelumLeverFace(Spawn("CaelumLeverFace", Pos + offset, NO_REPLACE));
            if (LeverVisual != null) LeverVisual.Angle = Angle + 180;
        }
        if (LeverVisual != null)
        {
            // Actualiza también la escala serializada de una palanca de 0b.
            LeverVisual.Scale = (0.045, 0.045);
            LeverVisual.frame = Spent ? 1 : 0;
        }
    }

    override void OnDestroy()
    {
        if (ColumnVisual != null) ColumnVisual.Destroy();
        if (LeverVisual != null) LeverVisual.Destroy();
        Super.OnDestroy();
    }

    override bool Used(Actor activator)
    {
        let user = CaelumPlayer(activator);
        if (Spent || user == null || user.health <= 0 || !user.CharacterCreationComplete
            || user.CreationWizardOpen || (user.player.cheats & CF_PREDICTING)
            || args[0] <= 0 || user.Distance2D(self) > user.UseRange + Radius
            || user.Pos.Z >= Pos.Z + Height || user.Pos.Z + user.Height <= Pos.Z
            || !user.CheckSight(self, SF_IGNOREVISIBILITY)) return false;
        let it = ActorIterator.Create(args[0]);
        Actor mechanism;
        bool changed = false;
        while ((mechanism = it.Next()) != null)
        {
            let rock = CaelumHazardRock(mechanism);
            let crusher = CaelumCrusherTrap(mechanism);
            if (rock != null) changed = rock.Release() || changed;
            if (crusher != null) changed = crusher.Release() || changed;
        }
        if (!changed) return false;
        Spent = true;
        if (LeverVisual != null) LeverVisual.frame = 1;
        A_StartSound("caelum/world/lever_activate", CHAN_BODY);
        CaelumNotifications.Notify(user,StringTable.Localize("CA_HAZARD_RELEASED", false));
        return true;
    }
    Default
    {
        Tag "$CA_HAZARD_SWITCH";
        Radius 16;
        Height 96;
        +SOLID
        +NOGRAVITY
        +CANNOTPUSH
        +DONTTHRUST
        RenderStyle "None";
    }
    States { Spawn: CSGT A -1; Stop; }
}

// Adaptación de unidades del techo nativo; no es presión estática por masa.
class CaelumCrushingDamage : Object
{
    // Umbral interno de GZDoom 4.14.2 (TELEFRAG_DAMAGE), no valor de balance.
    const NATIVE_TELEFRAG_THRESHOLD = 1000000;
    static int FromNativePercent(double maximumHealth,int percent)
    {
        // Mantener las órdenes especiales de daño forzado del motor. Un pulso
        // normal convertido no debe alcanzar el umbral reservado al telefrag.
        if(percent<=0 || percent>=NATIVE_TELEFRAG_THRESHOLD)return percent;
        double scaled=Max(1.0,maximumHealth)*percent/100.0;
        return int(Clamp(scaled+0.5,1.0,double(NATIVE_TELEFRAG_THRESHOLD-1)));
    }
}

class CaelumHazardDiagnostics : Object play
{
    static void Report()
    {
        Console.Printf("[Caelum 4.36.10] Peligros físicos y mágicos: mapa=%s", level.MapName);
        Console.Printf("Techos: args[0] expresa porcentaje de vida máxima por pulso nativo; masa estática: Hmax x 0.10 x max(0, (masa encima+carga)/capacidad-1) por segundo.");
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
        {
            Console.Printf("Roca TID=%d liberada=%d masa=%.1f radio=%.1f altura=%.1f ampliada=%d velocidad=(%.2f,%.2f,%.2f) impactos verticales=%d impulso=%.2f",
                rock.tid, rock.Released, rock.GetEnvironmentMassKg(), rock.Radius, rock.Height, rock.BoulderSizeReady, rock.Vel.X, rock.Vel.Y, rock.Vel.Z,
                rock.VerticalImpactCount, rock.LastVerticalImpulse);
            Console.Printf("  Salida configurada=%.2f MU/tic; peso en reposo: aplica sobrecarga porcentual.", rock.GetReleaseSpeed());
        }
        let switches = ThinkerIterator.Create("CaelumHazardReleaseSwitch"); CaelumHazardReleaseSwitch lever;
        while ((lever = CaelumHazardReleaseSwitch(switches.Next())) != null)
            Console.Printf("Mecanismo destino=%d usado=%d", lever.args[0], lever.Spent);
        for (int p=0; p<MAXPLAYERS; p++)
        {
            if (!playeringame[p]) continue;
            let user = CaelumPlayer(players[p].mo);
            let pressure=user==null?null:CaelumWeightPressure(user.FindInventory("CaelumWeightPressure"));
            if(pressure!=null)Console.Printf("Peso jugador=%d encima=%.3f kg daño/s=%.3f fracción=%.6f",p,pressure.SupportedMass,pressure.LastDamagePerSecond,pressure.DamageCarry);
            if (user != null)
                Console.Printf("Impacto jugador=%d tipo=%d masa fuente=%.1f velocidad cierre=%.2f porcentaje=%.2f Dureza=%.2f postDureza=%.2f armadura=%.2f daño=%d",
                    p, user.LastImpactKind, user.LastImpactOtherEffectiveMass,
                    user.LastImpactClosingSpeed, user.LastImpactDamagePercent,
                    user.LastImpactToughnessPercent, user.LastImpactPostToughnessPercent,
                    user.LastImpactArmorDefensePercent, user.LastImpactFinalDamage);
        }
        CaelumMagicHazardWorld.Report();
        let reset=CaelumHazardResetSwitch(ThinkerIterator.Create("CaelumHazardResetSwitch").Next());
        if(reset!=null)Console.Printf("Reinicio galería TID=%d usos=%d impedimento=%s",reset.tid,reset.ResetCount,CaelumHazardResetSwitch.BlockReason());
        if (count == 0) Console.Printf("La galería de peligros está en MAP08, conectada desde MAP05.");
    }
}
