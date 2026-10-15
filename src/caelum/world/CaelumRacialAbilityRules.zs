// #238: contrato guardado del ciclo; cada efecto concreto pertenece a su issue.
class CaelumRacialAbilityEffect : Object play
{
    int Revision, Race;
    virtual bool CanStart(CaelumPlayer user) { return true; }
    virtual bool CanContinue(CaelumPlayer user) { return true; }
    virtual double BaseAnimaPerSecond(CaelumPlayer user) { return 0; }
    virtual void Started(CaelumPlayer user) { }
    virtual void Step(CaelumPlayer user,bool realStep) { }
    virtual void Stopped(CaelumPlayer user) { }
}

class CaelumRacialAbilityRules : Object play
{
    const SCHEMA_REVISION=1;

    static void Ensure(CaelumPlayer user)
    {
        // El antiguo booleano del HUD no representa una habilidad pagada.
        if(user.RacialAbilityRevision<SCHEMA_REVISION)
        {
            user.RacialAbilityRevision=SCHEMA_REVISION;
            user.RacialAbility=null;user.RacialAbilityActive=false;
        }
        if(user.RacialAbility==null)user.RacialAbilityActive=false;
    }

    static void Deactivate(CaelumPlayer user)
    {
        let effect=user.RacialAbility;
        // Limpiar primero: la liberación de un blanco no puede terminar dos veces.
        user.RacialAbility=null;user.RacialAbilityActive=false;
        if(effect!=null)effect.Stopped(user);
    }

    static bool Interrupted(CaelumPlayer user)
    {
        return user.player==null || user.player.playerstate!=PST_LIVE || user.health<=0
            || !user.CharacterCreationComplete || user.CharacterProfile==null || user.DerivedStats==null
            || CaelumSleepRules.IsSleeping(user) || CaelumExhaustion.Active(user)
            || CaelumTelekinesisRules.Held(user)
            || CaelumBolas.Restrained(user) || user.LucidityPhysicalStunRemaining>0
            || user.PainImmobilizationRemaining>0
            || (user.ElementalStatus!=null && user.ElementalStatus.IsLightningStunned());
    }

    static void Guard(CaelumPlayer user)
    {
        Ensure(user);
        if(user.RacialAbility!=null && (Interrupted(user)
            || user.RacialAbility.Race!=user.CharacterProfile.Race
            || !user.RacialAbility.CanContinue(user)))Deactivate(user);
    }

    static bool MenuBlocked(CaelumPlayer user)
    {
        let journal=user.player==null?null:CVar.GetCVar("ca_journal_open",user.player);
        let preview=CaelumChestPreviewState.Get(user);
        let journey=CaelumJourneyPlan.Get(user);
        return (journal!=null && journal.GetBool()) || (preview!=null && preview.IsOpen())
            || (journey!=null && journey.Open) || user.CreationWizardOpen || user.EquipmentMenuOpen
            || user.CraftingMenuOpen || user.PalomoMerchantMenuOpen || user.HasActiveConversation()
            || CaelumTimeSkipState.IsOpen(user) || CaelumRestState.IsActive(user)
            || user.CombatChannelModeActive || CaelumClassCastView.Active(user);
    }

    static void ObserveInput(CaelumPlayer user)
    {
        Guard(user);
        if(user.player==null)return;
        bool pressed=(user.player.cmd.buttons & BT_USER1)!=0;
        if(!pressed)user.RacialAbilityInputLatched=false;
        // Una pulsación absorbida por una interfaz no queda pendiente al cerrarla.
        else if(MenuBlocked(user))user.RacialAbilityInputLatched=true;
    }

    static double ModifiedCost(CaelumPlayer user,double baseCost)
    {return Max(0.0,baseCost)*(1-Clamp(user.DerivedStats.AnimaCostReductionPercent,0.0,100.0)/100.0);}

    static double TicCost(CaelumPlayer user,CaelumRacialAbilityEffect effect)
    {return ModifiedCost(user,effect.BaseAnimaPerSecond(user))/TICRATE;}

    static bool Begin(CaelumPlayer user)
    {
        Ensure(user);
        if(user.RacialAbility!=null || Interrupted(user) || MenuBlocked(user))return false;
        let effect=user.CreateRacialAbilityEffect(user.CharacterProfile.Race);
        if(effect==null)
        {CaelumNotifications.Notify(user,StringTable.Localize("CA_RACIAL_UNAVAILABLE",false));return false;}
        effect.Revision=SCHEMA_REVISION;effect.Race=user.CharacterProfile.Race;
        if(!effect.CanStart(user))return false;
        if(user.CurrentAnima<=0 || user.CurrentAnima+1e-8<TicCost(user,effect))
        {CaelumNotifications.Notify(user,StringTable.Localize("CA_RACIAL_ANIMA",false));return false;}
        // Sin cargo inicial: el primer paso se paga antes de activar el efecto.
        user.RacialAbility=effect;user.RacialAbilityActive=false;
        return true;
    }

    static void Input(CaelumPlayer user)
    {
        Guard(user);
        if(user.RacialAbilityInputLatched)return;
        user.RacialAbilityInputLatched=true;
        if(MenuBlocked(user))return;
        if(user.RacialAbility!=null){Deactivate(user);return;}
        Begin(user);
    }

    static void Advance(CaelumPlayer user,bool realStep=true)
    {
        Guard(user);let effect=user.RacialAbility;if(effect==null)return;
        double cost=TicCost(user,effect);
        // No consumir el resto si no paga el siguiente instante de efecto.
        if(user.CurrentAnima<=0 || user.CurrentAnima+1e-8<cost){Deactivate(user);return;}
        user.CurrentAnima=Max(0.0,user.CurrentAnima-cost);
        if(!user.RacialAbilityActive)
        {user.RacialAbilityActive=true;effect.Started(user);}
        if(user.RacialAbility==effect)effect.Step(user,realStep);
    }
}
