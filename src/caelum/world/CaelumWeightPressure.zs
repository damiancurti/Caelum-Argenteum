// Daño estático aprobado: Hmax × 0,10 × max(0, (masa encima + carga) / capacidad - 1).
// No usa velocidad ni reemplaza al impacto único del aterrizaje.
class CaelumWeightPressure : Inventory
{
    double DamageCarry;
    double SupportedMass;
    double LastDamagePerSecond;
    int ContactTics;

    static bool Supports(Actor lower, Actor upper)
    {
        return lower != null && upper != null && lower != upper
            && lower.bSolid && upper.bSolid && !lower.bNoClip && !upper.bNoClip
            && upper.bOnMobj && !upper.bNoGravity && Abs(upper.Vel.Z) < 0.01
            && upper.Pos.Z > lower.Pos.Z + 0.5
            && Abs(upper.Pos.Z - lower.Pos.Z - lower.Height) <= 0.5
            && Abs(upper.Pos.X - lower.Pos.X) < lower.Radius + upper.Radius
            && Abs(upper.Pos.Y - lower.Pos.Y) < lower.Radius + upper.Radius;
    }

    static int SupportCount(Actor upper)
    {
        int count = 0;
        let nearby = BlockThingsIterator.Create(upper, upper.Radius);
        while (nearby.Next()) if (Supports(nearby.thing, upper)) count++;
        return Max(1, count);
    }

    static double BodyMass(Actor body)
    {
        let user = CaelumPlayer(body);
        if (user != null && user.DerivedStats != null)
            return Max(0.0, user.DerivedStats.TotalMass);
        let npc = CaelumCombatActor(body);
        // Masa real, sin multiplicadores exclusivos del choque cinemático.
        return Max(0.0, double(body.Mass))
            + (npc != null && npc.CombatArmor != null ? npc.CombatArmor.GetTotalWeight() : 0.0);
    }

    static double MassAbove(Actor lower)
    {
        double total = 0;
        let nearby = BlockThingsIterator.Create(lower, lower.Radius);
        while (nearby.Next())
        {
            let upper = nearby.thing;
            if (!Supports(lower, upper)) continue;
            // Z crece estrictamente: no existen ciclos. Cada apoyo recibe su
            // fracción; dos caminos desde una pila no duplican su masa total.
            total += (BodyMass(upper) + MassAbove(upper)) / SupportCount(upper);
        }
        return total;
    }

    static double DamageRate(double maximumHealth, double above, double ownLoad, double capacity)
    {
        if (above <= 0 || capacity <= 0) return 0;
        return Max(0.0, maximumHealth) * 0.10
            * Max(0.0, (above + Max(0.0, ownLoad)) / capacity - 1.0);
    }

    static void Update(Actor victim)
    {
        if (victim == null || victim.health <= 0 || !victim.bSolid || victim.bNoClip) return;
        let user = CaelumPlayer(victim);
        let npc = CaelumCombatActor(victim);
        if (user != null && (user.player == null || !user.CharacterCreationComplete
            || user.CreationWizardOpen || user.DerivedStats == null
            || (user.player.cheats & CF_PREDICTING))) return;
        if (user == null && npc == null) return;
        double above = MassAbove(victim);
        let pressure = CaelumWeightPressure(victim.FindInventory("CaelumWeightPressure"));
        if (above <= 0)
        {
            if (pressure != null)
            {
                pressure.SupportedMass = 0; pressure.LastDamagePerSecond = 0;
                pressure.ContactTics = 0;
            }
            return;
        }
        if (pressure == null)
            pressure = CaelumWeightPressure(victim.GiveInventoryType("CaelumWeightPressure"));
        if (pressure == null) return;
        double ownLoad = user != null ? user.DerivedStats.CarriedWeight
            : npc.CombatArmor != null ? npc.CombatArmor.GetTotalWeight() : 0;
        double capacity = user != null ? user.DerivedStats.CarryCapacity
            : Max(1, npc.Mass) * npc.CalculateActorType4Percent(npc.CombatStrength) / 100.0;
        double maximumHealth = user != null ? user.GetImpactMaximumHealth() : npc.GetImpactMaximumHealth();
        pressure.SupportedMass = above;
        pressure.LastDamagePerSecond = DamageRate(maximumHealth, above, ownLoad, capacity);
        // El primer tic sólo registra el apoyo: daño estático desde el siguiente.
        if (pressure.ContactTics++ == 0) return;
        pressure.DamageCarry += pressure.LastDamagePerSecond / TICRATE;
        int damage = int(Min(999999.0, pressure.DamageCarry));
        if (damage <= 0) return;
        pressure.DamageCarry -= damage;
        victim.DamageMobj(null, null, damage, 'CaelumWeight', DMG_NO_ARMOR);
    }

    static void WorldTick()
    {
        for (int i = 0; i < MAXPLAYERS; i++)
            if (playeringame[i]) Update(players[i].mo);
        let actors = ThinkerIterator.Create("CaelumCombatActor");
        Actor victim;
        while ((victim = Actor(actors.Next())) != null) Update(victim);
    }

    Default { Inventory.MaxAmount 1; +INVENTORY.UNDROPPABLE -INVENTORY.INVBAR }
    States { Spawn: TNT1 A -1; Stop; }
}
