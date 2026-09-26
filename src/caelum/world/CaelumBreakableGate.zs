// Cada controlador posee ambas hojas visuales y todos sus pequeños bloques.
// args: 0=grupo (0 independiente), 1=material, 2=permite Use, 3=LOCKDEFS.
// Sólo esta clase opta por destrucción; las puertas existentes no se convierten.
class CaelumBreakableGate : Actor
{
    Actor GateVisual;
    Array<CaelumGateBlocker> Blocks;
    CaelumFactionCondition AccessCondition;
    double Toughness;
    double Constitution;
    double RetainedDamage;
    int StructuralMaximum;
    int BreakCount;
    int HoldTimer;
    bool Initialized;
    bool Broken;
    bool Opened;
    // Una explosión puede alcanzar muchos bloques. Guardar el máximo de cada
    // explosión, no sumar sus muestras ni perder otra explosión del mismo tic.
    Array<Actor> ExplosionSources;
    Array<int> ExplosionDamage;
    int ExplosionTick;
    Array<Actor> ImpactSources;
    Array<int> ImpactSerials;

    override void PostBeginPlay()
    {
        Super.PostBeginPlay();
        ExplosionTick = -1;
    }

    void InitializeGate()
    {
        if (Initialized) return;
        Initialized = true;
        Mass = CaelumGateData.MovingMass(args[1]);
        // Invertir exactamente Tipo 4; conservar fracciones y permitir >100.
        double reduction = CaelumGateData.Reduction(args[1]);
        Toughness = (Sqrt(1.0 + 20200.0 * reduction / (1.0 - reduction)) - 1.0) / 2.0;
        Constitution = Toughness;
        let stats = new("CaelumDerivedStats");
        RetainedDamage = 100.0 / stats.CalculateType4Percent(Toughness);
        StructuralMaximum = Max(1, int(CaelumConstants.HEALTH_ANIMA_DAMAGE_SCALE
            * stats.CalculateType1Percent(Constitution) * (Mass / 100.0)));
        health = StructuralMaximum;
        GateVisual = Spawn(CaelumGateData.VisualClass(args[1]), Pos, NO_REPLACE);
        if (GateVisual != null) { GateVisual.master = self; GateVisual.Angle = Angle; }
        // Espaciado menor que el diámetro: cobertura continua aun en diagonal.
        double radius = CaelumGateData.THICKNESS / 2.0;
        int count = int(Ceil(CaelumGateData.WIDTH / radius));
        for (int i = 0; i < count; i++)
        {
            double along = -CaelumGateData.WIDTH / 2.0 + radius
                + i * (CaelumGateData.WIDTH - 2.0 * radius) / (count - 1);
            vector3 position = Pos + (Cos(Angle) * along, Sin(Angle) * along, 0);
            let block = CaelumGateBlocker(Spawn("CaelumGateBlocker", position, NO_REPLACE));
            if (block == null) continue;
            block.master = self;
            block.Mass = Mass;
            block.A_SetSize(radius, CaelumGateData.HEIGHT);
            Blocks.Push(block);
        }
    }

    bool IsPeer(CaelumBreakableGate other)
    {
        return other == self || (other != null && args[0] > 0 && args[0] == other.args[0]);
    }

    override int GetMaxHealth(bool withupgrades) const
    {
        return Initialized ? StructuralMaximum : Super.GetMaxHealth(withupgrades);
    }

    void RefreshPassage()
    {
        bool closed = !Broken && !Opened;
        for (int i = 0; i < Blocks.Size(); i++)
        {
            if (Blocks[i] == null) continue;
            Blocks[i].bSolid = closed;
            Blocks[i].bShootable = closed;
        }
        if (GateVisual != null)
        {
            if (Broken || Opened) GateVisual.SetStateLabel("Broken");
            else if (health < StructuralMaximum) GateVisual.SetStateLabel("Damaged");
            else GateVisual.SetStateLabel("Intact");
        }
    }

    bool PassageOccupied()
    {
        // Incluye NPC, cadáveres sólidos y objetos, no solamente jugadores.
        let it = BlockThingsIterator.Create(self, CaelumGateData.WIDTH);
        while (it.Next())
        {
            Actor body = it.thing;
            if (body == self || body.master == self || !body.bSolid || body.bNoClip) continue;
            if (body.Pos.Z >= Pos.Z + CaelumGateData.HEIGHT || body.Pos.Z + body.Height <= Pos.Z) continue;
            vector2 offset = body.Pos.XY - Pos.XY;
            double along = Abs(offset.X * Cos(Angle) + offset.Y * Sin(Angle));
            double across = Abs(-offset.X * Sin(Angle) + offset.Y * Cos(Angle));
            // La proyección de una caja nativa depende del ángulo de la puerta.
            double extent = body.Radius * (Abs(Cos(Angle)) + Abs(Sin(Angle)));
            if (along <= CaelumGateData.WIDTH / 2.0 + extent
                && across <= CaelumGateData.THICKNESS / 2.0 + extent) return true;
        }
        return false;
    }

    override bool Used(Actor user)
    {
        InitializeGate();
        if (Broken || user == null || user.health <= 0
            || (user.player != null && (user.player.cheats & CF_PREDICTING))
            || user.Pos.Z >= Pos.Z + CaelumGateData.HEIGHT
            || user.Pos.Z + user.Height <= Pos.Z || !user.CheckSight(self, SF_IGNOREVISIBILITY)) return false;
        let check = ThinkerIterator.Create("CaelumBreakableGate");
        CaelumBreakableGate peer;
        while ((peer = CaelumBreakableGate(check.Next())) != null)
        {
            if (!IsPeer(peer) || peer.Broken) continue;
            if (peer.args[2] == 0) return false;
            if (peer.args[3] > 0 && !user.CheckKeys(peer.args[3], false)) return false;
            if (!CaelumFactionCondition.Require(CaelumPlayer(user), peer.AccessCondition)) return false;
        }
        check = ThinkerIterator.Create("CaelumBreakableGate");
        while ((peer = CaelumBreakableGate(check.Next())) != null)
        {
            if (!IsPeer(peer) || peer.Broken) continue;
            peer.InitializeGate();
            peer.Opened = true;
            peer.HoldTimer = CaelumGateData.HOLD_TICS;
            peer.RefreshPassage();
        }
        A_StartSound("caelum/world/door_large_open", CHAN_BODY);
        return true;
    }

    void BreakGroup()
    {
        if (Broken) return;
        let it = ThinkerIterator.Create("CaelumBreakableGate");
        CaelumBreakableGate peer;
        while ((peer = CaelumBreakableGate(it.Next())) != null)
        {
            if (!IsPeer(peer) || peer.Broken) continue;
            peer.InitializeGate();
            peer.Broken = true;
            peer.Opened = true;
            peer.health = 0;
            peer.HoldTimer = 0;
            peer.BreakCount++;
            peer.RefreshPassage();
        }
        // Sin escombros físicos ni recompensas: no quedan paredes invisibles.
    }

    override void Die(Actor source, Actor inflictor, int dmgflags, Name meansOfDeath)
    {
        InitializeGate();
        BreakGroup();
    }

    override int DamageMobj(Actor inflictor, Actor source, int damage, Name mod, int flags, double hitAngle)
    {
        InitializeGate();
        if (Broken || Opened || damage <= 0) return 0;
        int retained = mod == 'CaelumImpact' ? damage : Max(1, int(damage * RetainedDamage + 0.5));
        if (flags & DMG_EXPLOSION)
        {
            if (ExplosionTick != level.maptime)
            {
                ExplosionSources.Clear(); ExplosionDamage.Clear(); ExplosionTick = level.maptime;
            }
            int entry = -1;
            for (int i = 0; i < ExplosionSources.Size(); i++)
                if (ExplosionSources[i] == inflictor) { entry = i; break; }
            if (entry < 0) { ExplosionSources.Push(inflictor); ExplosionDamage.Push(retained); }
            else
            {
                int previous = ExplosionDamage[entry];
                ExplosionDamage[entry] = Max(previous, retained);
                retained = Max(0, retained - previous);
            }
        }
        int lost = Min(health, retained);
        health -= lost;
        if (health <= 0) BreakGroup();
        else if (lost > 0) RefreshPassage();
        return lost;
    }

    // Contrato para #20/#21: masa de la pieza móvil, velocidad real MU/tic y
    // normal de contacto. El emisor incrementa serial una vez por golpe/disparo.
    // No usar masa de chasis ni velocidad nominal; no volver a aplicar Tipo 4.
    int ApplySiegeImpact(Actor movingSource, int serial, double movingMass,
        vector3 contactVelocity, vector3 normal)
    {
        InitializeGate();
        if (Broken || Opened || movingSource == null || serial < 0 || movingMass <= 0) return 0;
        int entry = -1;
        for (int i = ImpactSources.Size() - 1; i >= 0; i--)
        {
            if (ImpactSources[i] == null) { ImpactSources.Delete(i); ImpactSerials.Delete(i); }
        }
        for (int i = 0; i < ImpactSources.Size(); i++)
            if (ImpactSources[i] == movingSource) { entry = i; break; }
        if (entry >= 0 && serial <= ImpactSerials[entry]) return 0;
        let body = new("ImpactBody");
        body.Mass = Mass; body.Height = CaelumGateData.HEIGHT;
        body.Position = Pos; body.Velocity = (0, 0, 0);
        body.Restitution = CaelumConstants.IMPACT_RESTITUTION; body.SurfaceMultiplier = 1.0;
        let result = new("ImpactResult");
        ImpactPhysics.ResolveExternal(body, movingMass, contactVelocity, normal,
            CaelumConstants.IMPACT_RESTITUTION, result);
        if (!result.Valid) return 0;
        if (entry < 0) { ImpactSources.Push(movingSource); ImpactSerials.Push(serial); }
        else ImpactSerials[entry] = serial;
        return ReceiveStructuralImpact(movingSource, movingSource.target, result.TargetEnergyPercent, 1.0);
    }

    int ReceiveStructuralImpact(Actor source, Actor instigator, double energyPercent, double surfaceMultiplier)
    {
        double percent = Max(0.0, energyPercent * surfaceMultiplier - Toughness);
        int damage = int(StructuralMaximum * percent / 100.0 + 0.5);
        return DamageMobj(source, instigator, damage, 'CaelumImpact', DMG_NO_ARMOR, Angle);
    }

    // La colisión nativa llega por muchas cajas, pero el contacto pertenece al
    // portón completo. Jugador y NPC conservan sus defensas/masa corporales.
    void ResolveBodyImpact(Actor movingBody, Actor contactSurface)
    {
        InitializeGate();
        if (Broken || Opened || movingBody == null || movingBody.health <= 0) return;
        let user = CaelumPlayer(movingBody);
        let npc = CaelumCombatActor(movingBody);
        if (user == null && (npc == null || npc.DisableCaelumImpactContacts)) return;
        if (movingBody.Pos.Z >= Pos.Z + CaelumGateData.HEIGHT
            || movingBody.Pos.Z + movingBody.Height <= Pos.Z) return;

        ImpactContactState contact = user != null ? user.GetImpactContactState(self)
            : npc.GetImpactContactState(self);
        if (contact != null)
        {
            contact.RegisterCollision(level.time);
            return;
        }
        // Normal del plano: no usar el centro de la caja diminuta golpeada,
        // que cambia con cada hoja y produce impactos laterales ficticios.
        vector3 normal = (-Sin(Angle), Cos(Angle), 0);
        vector2 offset = movingBody.Pos.XY - Pos.XY;
        double side = offset.X * normal.X + offset.Y * normal.Y;
        if (side > 0) normal = -normal;
        let sourceBody = user != null ? user.BuildImpactPhysicsBody() : npc.BuildImpactPhysicsBody();
        let gateBody = new("ImpactBody");
        gateBody.Mass = Mass; gateBody.Height = CaelumGateData.HEIGHT;
        gateBody.Position = Pos; gateBody.Velocity = (0, 0, 0);
        gateBody.Restitution = CaelumConstants.IMPACT_RESTITUTION;
        gateBody.SurfaceMultiplier = 1.0;
        let result = new("ImpactResult");
        ImpactPhysics.ResolveBodies(sourceBody, gateBody, normal, result);
        if (!result.Valid) return;

        contact = user != null ? user.LatchImpactContact(self) : npc.LatchImpactContact(self);
        if (contact == null) return;
        // El radio técnico del controlador es 1: el rearme debe abarcar toda
        // la anchura real, incluso contactos en el extremo de ambas hojas.
        contact.ReleaseDistance = movingBody.Radius
            + Sqrt(CaelumGateData.WIDTH * CaelumGateData.WIDTH
                + CaelumGateData.THICKNESS * CaelumGateData.THICKNESS) / 2.0
            + Min(movingBody.Height, CaelumGateData.HEIGHT)
                * CaelumConstants.IMPACT_CONTACT_REARM_HEIGHT_FRACTION
            + CaelumConstants.IMPACT_CONTACT_RELEASE_MARGIN;
        contact.BeginResolutionTick(level.time);
        contact.LastClosingSpeed = result.ClosingSpeed;
        contact.LastTransmittedImpulse = result.Impulse;
        movingBody.Vel.X -= result.Normal.X * result.SourceDeltaSpeed;
        movingBody.Vel.Y -= result.Normal.Y * result.SourceDeltaSpeed;
        ReceiveStructuralImpact(movingBody, movingBody, result.TargetEnergyPercent, sourceBody.SurfaceMultiplier);
        // El proxy ya declara NODAMAGETHRUST: no sumar empuje nativo al impulso.
        if (user != null)
            user.ReceiveCaelumImpact(result.SourceDeltaSpeed, CaelumConstants.IMPACT_KIND_ACTOR,
                contactSurface, 1.0, sourceBody.Mass, gateBody.Mass, result.ClosingSpeed, result.Impulse,
                result.SourceContactMinimumHeightRatio, result.SourceContactMaximumHeightRatio);
        else
            npc.ReceiveCaelumImpact(result.SourceDeltaSpeed, CaelumConstants.IMPACT_KIND_ACTOR,
                contactSurface, 1.0, sourceBody.Mass, gateBody.Mass, result.ClosingSpeed, result.Impulse,
                result.SourceContactMinimumHeightRatio, result.SourceContactMaximumHeightRatio);
    }

    override void Tick()
    {
        Super.Tick();
        InitializeGate();
        if (Broken || !Opened) return;
        if (HoldTimer > 0) { HoldTimer--; return; }
        let it = ThinkerIterator.Create("CaelumBreakableGate");
        CaelumBreakableGate peer;
        while ((peer = CaelumBreakableGate(it.Next())) != null)
            if (IsPeer(peer) && !peer.Broken && (peer.HoldTimer > 0 || peer.PassageOccupied())) return;
        it = ThinkerIterator.Create("CaelumBreakableGate");
        while ((peer = CaelumBreakableGate(it.Next())) != null)
        {
            if (!IsPeer(peer) || peer.Broken) continue;
            peer.Opened = false;
            peer.RefreshPassage();
        }
    }

    override void OnDestroy()
    {
        for (int i = 0; i < Blocks.Size(); i++) if (Blocks[i] != null) Blocks[i].Destroy();
        if (GateVisual != null) GateVisual.Destroy();
        Super.OnDestroy();
    }

    Default
    {
        Radius 1;
        Height 96;
        +NOBLOCKMAP
        +NOGRAVITY
        +NOBLOOD
        +CANNOTPUSH
        +DONTTHRUST
        RenderStyle "None";
    }
    States { Spawn: TNT1 A -1; Stop; }
}

class CaelumGateBlocker : Actor
{
    int ContactFlags;
    double ContactAngle;
    override void CollidedWith(Actor other, bool passive)
    {
        Super.CollidedWith(other, passive);
        let gate = CaelumBreakableGate(master);
        if (gate != null) gate.ResolveBodyImpact(other, self);
    }
    override void Tick()
    {
        // El marco está anclado incluso si otro script intenta dar impulso.
        Vel = (0, 0, 0);
        Super.Tick();
    }
    override bool Used(Actor user)
    {
        let gate = CaelumBreakableGate(master);
        return gate != null && gate.Used(user);
    }
    override int DamageMobj(Actor inflictor, Actor source, int damage, Name mod, int flags, double hitAngle)
    {
        let gate = CaelumBreakableGate(master);
        if (gate == null || gate.Broken || gate.Opened) return 0;
        ContactFlags = flags;
        ContactAngle = hitAngle;
        // El motor debe resolver DoSpecialDamage del proyectil antes de aplicar
        // Dureza. La caja auxiliar nunca muere por separado de su controlador.
        health = gate.StructuralMaximum + 1;
        return Super.DamageMobj(inflictor, source, damage, mod, flags | DMG_THRUSTLESS, hitAngle);
    }
    override int TakeSpecialDamage(Actor inflictor, Actor source, int damage, Name mod)
    {
        let gate = CaelumBreakableGate(master);
        return gate == null ? 0 : gate.DamageMobj(inflictor, source, damage, mod, ContactFlags, ContactAngle);
    }
    override void Die(Actor source, Actor inflictor, int dmgflags, Name meansOfDeath)
    {
        let gate = CaelumBreakableGate(master);
        if (gate != null) gate.Die(source, inflictor, dmgflags, meansOfDeath);
    }
    Default
    {
        Radius 1.28;
        Height 96;
        +SOLID
        +SHOOTABLE
        +NOGRAVITY
        +NOBLOOD
        +CANNOTPUSH
        +DONTTHRUST
        +NODAMAGETHRUST
        RenderStyle "None";
    }
    States { Spawn: TNT1 A -1; Stop; }
}

// Ensayo optativo en la galería ya aceptada: activa solamente sus tres portones
// intactos. No altera los ejemplos dañados/abiertos ni el encuentro de MAP06.
class CaelumDebugGateTrial : CaelumSocialDebugAction
{
    override bool Use(bool pickup)
    {
        if (level.MapName != "MAP03") return false;
        let it = ThinkerIterator.Create("CaelumSiegeGate");
        CaelumSiegeGate visual;
        Array<CaelumSiegeGate> selected;
        while ((visual = CaelumSiegeGate(it.Next())) != null)
            if (visual.master == null && visual.frame == 0) selected.Push(visual);
        for (int i = 0; i < selected.Size(); i++)
        {
            visual = selected[i];
            let gate = CaelumBreakableGate(Actor.Spawn("CaelumBreakableGate", visual.Pos, NO_REPLACE));
            if (gate == null) continue;
            gate.Angle = visual.Angle;
            gate.args[1] = visual is "CaelumSiegeGateArmored" ? CaelumGateData.ARMORED
                : visual is "CaelumSiegeGateReinforced" ? CaelumGateData.REINFORCED : CaelumGateData.WOOD;
            gate.args[2] = 1;
            gate.InitializeGate();
            visual.Destroy();
        }
        return true;
    }
}
