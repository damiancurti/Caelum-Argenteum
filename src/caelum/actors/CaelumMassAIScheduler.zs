// Coordinador determinista de la IA masiva de MAP02. El EventHandler existe
// una sola vez por partida y permite imponer un techo real a A_Chase sin que
// cada actor tenga que buscar o recorrer a los demas miembros del campo.
class CaelumMassAIScheduler : EventHandler
{
    bool MassAttacksEnabled;
    bool MassLookEnabled;
    bool MassChaseEnabled;
    int MassAttackInterval;
    int MassLookInterval;
    int MassChaseInterval;
    int MassLookBudgetPerTic;
    int MassChaseBudgetPerTic;
    bool SettingsInitialized;

    int LookUpdatesThisTic;
    int PeakLookUpdatesPerTic;
    int LookBudgetDeferralsSinceReport;
    int ChaseUpdatesThisTic;
    int PeakChaseUpdatesPerTic;
    int ChaseBudgetDeferralsSinceReport;

    void RefreshSettings()
    {
        CVar attackSetting = CVar.GetCVar("ca_diag_mass_attacks");
        MassAttacksEnabled = attackSetting == null
            || attackSetting.GetBool();

        CVar lookEnabledSetting = CVar.GetCVar(
            "ca_diag_mass_look_enabled"
        );
        MassLookEnabled = lookEnabledSetting == null
            || lookEnabledSetting.GetBool();

        CVar chaseEnabledSetting = CVar.GetCVar(
            "ca_diag_mass_chase_enabled"
        );
        MassChaseEnabled = chaseEnabledSetting == null
            || chaseEnabledSetting.GetBool();

        CVar attackInterval = CVar.GetCVar(
            "ca_diag_mass_attack_stagger"
        );
        MassAttackInterval = attackInterval == null
            ? 64 : Clamp(attackInterval.GetInt(), 1, 64);

        CVar lookInterval = CVar.GetCVar("ca_diag_mass_look_stagger");
        MassLookInterval = lookInterval == null
            ? 7 : Clamp(lookInterval.GetInt(), 1, 31);

        CVar chaseInterval = CVar.GetCVar(
            "ca_diag_mass_chase_stagger"
        );
        MassChaseInterval = chaseInterval == null
            ? 13 : Clamp(chaseInterval.GetInt(), 1, 31);

        CVar lookBudget = CVar.GetCVar("ca_diag_mass_look_budget");
        MassLookBudgetPerTic = lookBudget == null
            ? 20 : Clamp(lookBudget.GetInt(), 1, 128);

        CVar chaseBudget = CVar.GetCVar("ca_diag_mass_chase_budget");
        MassChaseBudgetPerTic = chaseBudget == null
            ? 20 : Clamp(chaseBudget.GetInt(), 1, 128);

        SettingsInitialized = true;
    }

    override void WorldLoaded(WorldEvent event)
    {
        RefreshSettings();
        LookUpdatesThisTic = 0;
        PeakLookUpdatesPerTic = 0;
        LookBudgetDeferralsSinceReport = 0;
        ChaseUpdatesThisTic = 0;
        PeakChaseUpdatesPerTic = 0;
        ChaseBudgetDeferralsSinceReport = 0;
    }

    override void WorldTick()
    {
        // WorldTick corre antes de los Thinkers. Cerrar aqui el tic anterior
        // mantiene un limite determinista y no depende de los FPS del cliente.
        // La configuración es inmutable durante el mapa: no se consultan CVars
        // 35 veces por segundo ni se propagan cambios parciales entre actores.
        PeakLookUpdatesPerTic = Max(
            PeakLookUpdatesPerTic,
            LookUpdatesThisTic
        );
        LookUpdatesThisTic = 0;
        PeakChaseUpdatesPerTic = Max(
            PeakChaseUpdatesPerTic,
            ChaseUpdatesThisTic
        );
        ChaseUpdatesThisTic = 0;
    }

    bool TryAdmitLook()
    {
        int budget = Max(1, MassLookBudgetPerTic);
        if (LookUpdatesThisTic >= budget)
        {
            LookBudgetDeferralsSinceReport++;
            return false;
        }

        LookUpdatesThisTic++;
        return true;
    }

    bool TryAdmitChase()
    {
        int budget = Max(1, MassChaseBudgetPerTic);
        if (ChaseUpdatesThisTic >= budget)
        {
            ChaseBudgetDeferralsSinceReport++;
            return false;
        }

        ChaseUpdatesThisTic++;
        return true;
    }

    int ReadAndResetPeakChaseUpdates()
    {
        int result = Max(PeakChaseUpdatesPerTic, ChaseUpdatesThisTic);
        // Conservar el parcial actual evita perderlo si el monitor informa en
        // medio del orden de Thinkers de este tic.
        PeakChaseUpdatesPerTic = ChaseUpdatesThisTic;
        return result;
    }

    int ReadAndResetPeakLookUpdates()
    {
        int result = Max(PeakLookUpdatesPerTic, LookUpdatesThisTic);
        PeakLookUpdatesPerTic = LookUpdatesThisTic;
        return result;
    }

    int ReadAndResetLookBudgetDeferrals()
    {
        int result = LookBudgetDeferralsSinceReport;
        LookBudgetDeferralsSinceReport = 0;
        return result;
    }

    int ReadAndResetBudgetDeferrals()
    {
        int result = ChaseBudgetDeferralsSinceReport;
        ChaseBudgetDeferralsSinceReport = 0;
        return result;
    }
}
