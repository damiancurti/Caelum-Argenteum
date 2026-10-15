// Estado serializado del hechizo; no pertenece al sueño voluntario.
class CaelumSpellSleepState : Object
{
    const SCHEMA_REVISION=1;
    int Revision,HitsRemaining;
    double DamageMultiplier;
    State SavedState;
    State LyingState;
    int SavedTics;
}

// Regla común del sueño voluntario y del inducido. Las tasas se expresan en
// segundos de simulación, igual que los demás efectos y habilidades.
class CaelumSleepRules : Object play
{
    const LUCIDITY_PER_SECOND = 10.0;
    const ENEMY_WAKE_HITS=3;
    const ENEMY_DAMAGE_MULTIPLIER=3.0;

    static CaelumSpellSleepState Status(Actor victim)
    {
        let user=CaelumPlayer(victim);
        if(user!=null)return user.ForcedSleepTics>0 ? user.SpellSleep : null;
        let npc=CaelumCombatActor(victim);
        return npc!=null && npc.ForcedSleepTics>0 ? npc.SpellSleep : null;
    }

    static int ScaleDamage(Actor victim,int damage)
    {
        let status=Status(victim);
        return status==null || damage<=0 ? damage
            : Max(0,int(damage*status.DamageMultiplier+0.5));
    }

    static void Wake(Actor victim)
    {
        let user=CaelumPlayer(victim);
        if(user!=null)
        {
            user.ForcedSleepTics=0;user.SpellSleep=null;
            if(user.health>0 && !CaelumRestState.IsActive(user))user.SetState(user.SpawnState);
            return;
        }
        let npc=CaelumCombatActor(victim);if(npc==null)return;
        let status=npc.SpellSleep;
        npc.ForcedSleepTics=0;npc.SpellSleep=null;
        if(npc.health<=0)return;
        if(status!=null && status.SavedState!=null)
        {
            // No repetir una acción de ataque al restaurar la pose anterior.
            npc.SetState(status.SavedState,true);
            npc.tics=status.SavedTics<0 ? -1 : Max(1,status.SavedTics);
        }
        else npc.tics=Max(1,npc.SleepSavedTics);
    }

    static void HealthLost(Actor victim,int before)
    {
        if(victim.health>=before || before<=0)return;
        let status=Status(victim);
        if(status!=null)
        {
            status.HitsRemaining--;
            if(status.HitsRemaining<=0 || victim.health<=0)Wake(victim);
            else MaintainPose(victim);
        }
        else
        {
            // Saves del hechizo anterior conservan el despertar de un golpe.
            let user=CaelumPlayer(victim);let npc=CaelumCombatActor(victim);
            if((user!=null && user.ForcedSleepTics>0)
                || (npc!=null && npc.ForcedSleepTics>0))Wake(victim);
        }
    }

    static void MaintainPose(Actor victim)
    {
        let status=Status(victim);
        if(status!=null && status.LyingState!=null && victim.health>0)
        {victim.SetState(status.LyingState,true);victim.tics=-1;}
    }

    static bool Enemy(CaelumPlayer caster,Actor victim)
    {
        // La misma identidad nativa que separa amenazas y residentes aliados.
        // No inferir hostilidad de una facción narrativa aún sin relaciones.
        if(victim.player!=null)return deathmatch && !victim.IsTeammate(caster);
        return victim.bIsMonster && !victim.bFriendly;
    }

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

    static bool Apply(Actor victim, int duration = 350, bool enemy=false,double power=1.0)
    {
        if (victim == null || victim.health <= 0 || duration <= 0) return false;
        let user = CaelumPlayer(victim);
        let combat = CaelumCombatActor(victim);
        if(user==null && combat==null)return false;
        let previous=Status(victim);
        let status=new("CaelumSpellSleepState");
        status.Revision=CaelumSpellSleepState.SCHEMA_REVISION;
        status.HitsRemaining=enemy?ENEMY_WAKE_HITS:1;
        status.DamageMultiplier=enemy?ENEMY_DAMAGE_MULTIPLIER*power:1;
        status.SavedState=previous!=null?previous.SavedState:victim.CurState;
        status.SavedTics=previous!=null?previous.SavedTics:victim.tics;
        status.LyingState=victim.FindState("RestLying");
        if (user != null)
        {
            user.SpellSleep=status;
            CaelumTimeAdvanceState.Halt(user);
            user.CloseCraftingStationSession();
            user.ForcedSleepTics = Max(user.ForcedSleepTics, duration);
            user.CancelCombatBlockMode(); user.CancelRangedReload(); user.CancelWeaponCharge();
            user.Vel = (0,0,0);
            return true;
        }
        combat.SpellSleep=status;
        if (combat.ForcedSleepTics <= 0) combat.SleepSavedTics = combat.tics;
        combat.ForcedSleepTics = Max(combat.ForcedSleepTics, duration);
        combat.tics = -1; combat.Vel = (0,0,0);
        MaintainPose(combat);
        return true;
    }

    static double Cost(CaelumPlayer user)
    {return CaelumClassAbilityRules.Cost(user);}

    static bool CanCast(CaelumPlayer user)
    {
        if (user == null || user.player == null || user.health <= 0
            || user.CharacterProfile == null || !user.CharacterCreationComplete
            || user.CharacterProfile.GetProfession() != CaelumConstants.PROFESSION_ARCANIST
            || user.DerivedStats == null || user.IsPhysicallyImmobilized()
            || user.CombatChannelModeActive || user.ClassCastActive
            || user.EquipmentMenuOpen || user.CreationWizardOpen
            || CaelumRestState.IsActive(user) || user.CraftingMenuOpen
            || user.HasActiveConversation() || user.PalomoMerchantMenuOpen
            || user.ClassSleepCooldownRemaining > 0) return false;
        return user.CurrentAnima>=Cost(user);
    }

    static bool Cast(CaelumPlayer user)
    {
        return CaelumClassAbilityRules.Begin(user);
    }

    static bool Release(CaelumPlayer user)
    {
        // Las habilidades de clase comparten el radio base de los sellos.
        double radius = CaelumClassAbilityRules.Radius(user);
        let it = ThinkerIterator.Create("Actor"); Actor victim;
        int count = 0;
        while ((victim = Actor(it.Next())) != null)
        {
            if (victim == user || victim.health <= 0
                || (victim.Pos-user.Pos).Length() > radius
                || !user.CheckSight(victim, SF_IGNOREVISIBILITY)) continue;
            double power=CaelumClassAbilityRules.HarmfulPower(user);
            if (Apply(victim, int(CaelumClassAbilityRules.EFFECT_SECONDS*power*TICRATE+0.5),
                Enemy(user,victim),power)) count++;
        }
        CaelumNotifications.Notify(user,String.Format(StringTable.Localize("CA_SLEEP_CAST", false), count));
        user.PersistCharacterState();
        return true;
    }
}
