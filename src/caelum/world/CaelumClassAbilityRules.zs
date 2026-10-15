// #238: ciclo compartido; cada profesión conserva su efecto en su propio issue.
class CaelumClassAbilityRules : Object play
{
    const REVISION=1;
    const BASE_COST=1000.0;
    const EFFECT_SECONDS=10.0;
    const REUSE_SECONDS=60.0;

    static double Cost(CaelumPlayer user)
    {
        return user==null || user.DerivedStats==null ? BASE_COST
            : BASE_COST*(1-user.DerivedStats.AnimaCostReductionPercent/100.0);
    }

    static double Radius(CaelumPlayer user)
    {return CaelumConstants.CLASS_ABILITY_BASE_RADIUS*user.DerivedStats.AbilityRangePercent/100.0;}

    static double HarmfulPower(CaelumPlayer user)
    {return user.DerivedStats.DebuffPowerPercent/100.0;}

    static double BeneficialPower(CaelumPlayer user)
    {return user.DerivedStats.BuffPowerPercent/100.0;}

    static void Ensure(CaelumPlayer user)
    {
        // Los nuevos campos se inicializan a cero al cargar un save anterior.
        // No convertir el reloj del prototipo visual en una habilidad pagada.
        if(user.ClassCastRevision<REVISION)user.ClassCastRevision=REVISION;
    }

    static void Cancel(CaelumPlayer user)
    {
        user.ClassCastActive=false;
        user.ClassPreparationTics=0;
        // El total pagado se conserva como diagnóstico, nunca como devolución.
    }

    static bool Begin(CaelumPlayer user)
    {
        if(user==null || user.ClassCastActive || CaelumClassCastView.Active(user)
            || !CaelumSleepRules.CanCast(user))return false;
        Ensure(user);
        user.ClassCastProfession=user.CharacterProfile.GetProfession();
        user.ClassCastCost=Cost(user);
        user.ClassCastPaid=0;
        user.ClassCastActive=true;
        CaelumClassCastView.Begin(user);
        user.CancelRangedAim();
        user.player.PendingWeapon=WP_NOCHANGE;
        return true;
    }

    static void Input(CaelumPlayer user)
    {
        if(user.ClassSleepInputLatched)return;
        user.ClassSleepInputLatched=true;
        if(user.ClassCastActive){Cancel(user);return;}
        Begin(user);
    }

    static void FilterInput(CaelumPlayer user)
    {
        if(user.player==null || !CaelumClassCastView.Active(user))return;
        // User4 debe poder cancelar también al abrir una interfaz que quite
        // los botones antes de que los reciba el arma nativa.
        if((user.player.cmd.buttons & BT_USER4) && !user.ClassSleepInputLatched)
            Input(user);
        user.player.PendingWeapon=WP_NOCHANGE;
        user.player.cmd.buttons &= ~(BT_ATTACK|BT_ALTATTACK|BT_ZOOM|BT_RELOAD
            |BT_USER1|BT_USER2|BT_USER3);
    }

    static void Advance(CaelumPlayer user)
    {
        Ensure(user);
        if(!user.ClassCastActive){CaelumClassCastView.Advance(user);return;}
        if(user.health<=0 || user.player==null || user.player.playerstate!=PST_LIVE
            || user.IsPhysicallyImmobilized())
        {Cancel(user);return;}
        int total=CaelumClassCastLayout.SECONDS*TICRATE;
        int elapsed=total-user.ClassPreparationTics+1;
        // Cobro acumulado uniforme: evita deriva y cobra exactamente el total
        // al tic 105, aunque se guarde/cargue entre dos pagos.
        double paid=user.ClassCastCost*Clamp(elapsed,0,total)/total;
        double due=Max(0.0,paid-user.ClassCastPaid);
        if(user.CurrentAnima+1e-8<due){Cancel(user);return;}
        user.CurrentAnima=Max(0.0,user.CurrentAnima-due);
        user.ClassCastPaid=paid;
        CaelumClassCastView.Advance(user);
        if(user.ClassPreparationTics>0)return;
        user.ClassCastActive=false;
        if(user.ClassCastProfession==CaelumConstants.PROFESSION_ARCANIST)
            CaelumSleepRules.Release(user);
        user.ClassSleepCooldownRemaining=REUSE_SECONDS;
        user.PersistCharacterState();
    }
}
