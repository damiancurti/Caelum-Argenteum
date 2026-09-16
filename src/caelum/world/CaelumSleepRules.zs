// Regla común del sueño voluntario y del inducido. Las tasas se expresan en
// segundos de simulación, igual que los demás efectos y habilidades.
class CaelumSleepRules : Object play
{
    const LUCIDITY_PER_SECOND = 10.0;
    const SPELL_SECONDS = 10;
    const REUSE_SECONDS = 60.0;
    const BASE_ANIMA_COST = 1000.0; // Coste base confirmado por el autor.

    static bool IsSleeping(CaelumPlayer user)
    { return user != null && (user.ForcedSleepTics > 0 || CaelumRestState.IsSleeping(user)); }

    static double Drain(double value)
    { return Max(0.0, value - LUCIDITY_PER_SECOND / TICRATE); }

    static void AdvancePlayer(CaelumPlayer user)
    {
        if (!user.LucidityResourceInitialized || user.health <= 0) return;
        if (IsSleeping(user)) user.CurrentLucidity = Drain(user.CurrentLucidity);
        else user.CurrentLucidity = Min(CaelumConstants.MAXIMUM_LUCIDITY,
            user.CurrentLucidity + CaelumConstants.MAXIMUM_LUCIDITY
                / CaelumConstants.LUCIDITY_FULL_RECOVERY_SECONDS / TICRATE);
        user.UpdateLucidityState();
    }

    static bool Apply(Actor victim, int duration = 350)
    {
        if (victim == null || victim.health <= 0 || duration <= 0) return false;
        let user = CaelumPlayer(victim);
        if (user != null)
        {
            CaelumTimeAdvanceState.Halt(user);
            user.CloseCraftingStationSession();
            user.ForcedSleepTics = Max(user.ForcedSleepTics, duration);
            user.CancelCombatBlockMode(); user.CancelRangedReload(); user.CancelWeaponCharge();
            user.Vel = (0,0,0);
            return true;
        }
        let combat = CaelumCombatActor(victim);
        if (combat == null) return false;
        if (combat.ForcedSleepTics <= 0) combat.SleepSavedTics = combat.tics;
        combat.ForcedSleepTics = Max(combat.ForcedSleepTics, duration);
        combat.tics = -1; combat.Vel = (0,0,0);
        return true;
    }

    static bool Cast(CaelumPlayer user)
    {
        if (user == null || user.player == null || user.health <= 0
            || user.CharacterProfile == null || !user.CharacterCreationComplete
            || user.CharacterProfile.GetProfession() != CaelumConstants.PROFESSION_ARCANIST
            || user.DerivedStats == null || user.IsPhysicallyImmobilized()
            || CaelumRestState.IsActive(user) || user.CraftingMenuOpen
            || user.HasActiveConversation() || user.PalomoMerchantMenuOpen
            || user.ClassSleepCooldownRemaining > 0) return false;
        double cost = BASE_ANIMA_COST * (1.0 - user.DerivedStats.AnimaCostReductionPercent / 100.0);
        if (user.CurrentAnima < cost) return false;
        // Las habilidades de clase comparten el radio base de los sellos.
        double radius = CaelumConstants.CLASS_ABILITY_BASE_RADIUS
            * user.DerivedStats.AbilityRangePercent / 100.0;
        let it = ThinkerIterator.Create("Actor"); Actor victim;
        int count = 0;
        while ((victim = Actor(it.Next())) != null)
        {
            if (victim == user || victim.health <= 0
                || (victim.Pos-user.Pos).Length() > radius
                || !user.CheckSight(victim, SF_IGNOREVISIBILITY)) continue;
            if (Apply(victim, SPELL_SECONDS*TICRATE)) count++;
        }
        user.CurrentAnima -= cost;
        user.ClassSleepCooldownRemaining = REUSE_SECONDS;
        user.A_Print(String.Format(StringTable.Localize("CA_SLEEP_CAST", false), count));
        user.PersistCharacterState();
        return true;
    }
}
