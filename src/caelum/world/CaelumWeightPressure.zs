// #194: trabajo por fluencia bajo la fuerza que excede la capacidad de carga.
// Mantiene daño en reposo; la compresión es interna y no desplaza al actor.
class CaelumWeightPressure : Inventory
{
    double DamageCarry;
    double SupportedMass;
    double LastDamagePerSecond;
    int ContactTics;
    int EnergyRevision;
    double LastWorkJoules, LastPostToughness;

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

    static double DamageRate(double above, double ownLoad, double capacity)
    {
        if (above<=0 || capacity<=0) return 0;
        double excessMass=Max(0.0,above+Max(0.0,ownLoad)-capacity);
        return excessMass*CaelumPhysicsUnits.EARTH_GRAVITY_MPS2
            *CaelumPhysicsUnits.WEIGHT_CREEP_METERS_PER_SECOND;
    }

    void ApplyWork(Actor victim)
    {
        if (DamageCarry<=0) return;
        LastWorkJoules=DamageCarry; DamageCarry=0;
        LastPostToughness=CaelumToughnessRules.Apply(victim,LastWorkJoules);
        int damage=Max(0,int(LastPostToughness+0.5));
        if (damage>0) victim.DamageMobj(null,null,damage,'CaelumPressure',DMG_NO_ARMOR|DMG_THRUSTLESS);
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
        if (pressure!=null && pressure.EnergyRevision<1)
        { pressure.DamageCarry=0; pressure.ContactTics=0; pressure.EnergyRevision=1; }
        if (above <= 0)
        {
            if (pressure != null)
            {
                pressure.ApplyWork(victim);
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
        pressure.SupportedMass = above;
        pressure.LastDamagePerSecond = DamageRate(above, ownLoad, capacity);
        if (pressure.EnergyRevision<1)
        { pressure.DamageCarry=0; pressure.ContactTics=0; pressure.EnergyRevision=1; }
        // El primer tic registra el apoyo; no vuelve a contar la caída inicial.
        if (pressure.ContactTics++==0) return;
        pressure.DamageCarry+=pressure.LastDamagePerSecond/TICRATE;
        if ((pressure.ContactTics-1)%CaelumConstants.IMPACT_CRUSH_INTERVAL_TICS==0)
            pressure.ApplyWork(victim);

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
