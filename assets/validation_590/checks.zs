// Diagnóstico nativo aislado: no añade misiones de campaña ni recompensas.
class CA418Checks : EventHandler
{
    int Failures, Checks;
    int RegistryInitial;
    CaelumSiegeEncounter RegistryProbe;
    ui Array<double> FrameTimes;
    ui double LastFrame;

    override void RenderOverlay(RenderEvent e)
    {
        double now = MSTimeF();
        if (LastFrame > 0 && FrameTimes.Size() < 4096) FrameTimes.Push(now - LastFrame);
        LastFrame = now;
    }

    override void ConsoleProcess(ConsoleEvent e)
    {
        if (e.Name != "ca418_frames" || FrameTimes.Size() == 0) return;
        double sum = 0;
        for (int i = 0; i < FrameTimes.Size(); i++)
        {
            sum += FrameTimes[i];
            for (int j = i; j > 0 && FrameTimes[j] < FrameTimes[j-1]; j--)
            { double t = FrameTimes[j]; FrameTimes[j] = FrameTimes[j-1]; FrameTimes[j-1] = t; }
        }
        int count = FrameTimes.Size();
        Console.Printf("CA418 FRAMES callbacks=%d mean_ms=%.6f p95_ms=%.6f p99_ms=%.6f max_ms=%.6f",
            count, sum/count, FrameTimes[int((count-1)*.95)], FrameTimes[int((count-1)*.99)], FrameTimes[count-1]);
    }

    void Benchmark()
    {
        let registry = CaelumSiegeEvents(EventHandler.Find("CaelumSiegeEvents"));
        double worst = 0;
        Check(level.MapName != "MAP03" || CaelumPortSiege.Get() != null,
            "campaign port lookup retains its unsealed controller");
        for (int i = 0; i < 20; i++)
        {
            registry.NarrativeRegistryRevision = 0;
            double start = MSTimeF(); registry.EnsureNarrativeRegistry();
            worst = Max(worst, MSTimeF() - start);
        }
        double start = MSTimeF();
        int hits = 0;
        for (int i = 0; i < 10000; i++) if (registry.NarrativeEncounter() != null) hits++;
        double reads = MSTimeF() - start;
        let population = CaelumPopulationState.Get();
        Console.Printf("CA418 TIMING encounters=%d living_combatants=%d migration_worst_ms=%.6f reads_10000_ms=%.6f hits=%d",
            registry.NarrativeEncounters.Size(), population != null ? population.LivingCombatants : -1, worst, reads, hits);
        Check(registry.NarrativeRegistryRevision == 1, "bounded registry benchmark completed");
    }
    void Check(bool value, String label)
    { Checks++; if (!value) Failures++; Console.Printf("CA418 %s %s", value ? "PASS" : "FAIL", label); }

    CaelumQuestRequirements Term(int kind, int subject, int value, int objective = 0)
    {
        let term = new("CaelumQuestRequirements");
        term.Kind = kind; term.Subject = subject; term.Value = value; term.Objective = objective;
        return term;
    }

    void Seed(CaelumPlayer user)
    {
        user.player.cheats |= CF_GODMODE;
        let record = user.GetPersistentCharacterState(true);
        record.InitializeNewQuestState(); record.EnsureQuestStateInitialized();
        CaelumSideQuestRules.EnableTrial(user);
        Check(!CaelumSideQuestRules.CanStart(record, 2), "chain locked before prerequisite");
        Check(CaelumSideQuestRules.Start(user, 1), "start offered quest");
        Check(!CaelumSideQuestRules.Start(user, 1), "start is idempotent");
        Check(!CaelumSideQuestRules.Complete(record, 1), "incomplete objectives reject completion");
        Check(CaelumSideQuestRules.Progress(record, 1, 0, 1), "objective progress");
        Check(CaelumSideQuestRules.Complete(record, 1), "complete predecessor");
        Check(CaelumSideQuestRules.Claim(user, 1), "native reward grant");
        Check(!CaelumSideQuestRules.Claim(user, 1), "reward cannot repeat");
        Check(CaelumSideQuestRules.CanStart(record, 2), "chain unlocks from authoritative progress");
        record.QuestObjectiveKnown[7] = true; // Hito futuro oculto, no descubierto.
        let legacyEncounter = Actor.Spawn("CaelumSiegeEncounter", (-128,128,0));
        legacyEncounter.health = 418;
        user.RefreshSocialJournalSnapshot(); user.PersistCharacterState();
    }

    void Preserved(CaelumPlayer user)
    {
        let record = user.GetPersistentCharacterState(false);
        Check(record != null && record.QuestState[1] == CaelumConstants.QUEST_STATE_COMPLETED,
            "completed predecessor survives load or travel");
        Check(record.QuestRewardClaimed[1] && user.FindInventory("CaelumQuestRouteReceipt") != null,
            "native reward and claim receipt preserved");
        Check(!CaelumSideQuestRules.Claim(user, 1), "load or travel cannot grant twice");
        Check(CaelumSideQuestRules.CanStart(record, 2), "offered successor preserved");
        Check(!CaelumQuestCatalogue.KnownObjective(record, 0, 7), "future objective stays hidden");
        let registry = CaelumSiegeEvents(EventHandler.Find("CaelumSiegeEvents"));
        registry.EnsureNarrativeRegistry();
        Check(registry.NarrativeRegistryRevision == 1, "restored registry revision is current");
        if (level.MapName == "CA418A")
            Check(registry.NarrativeEncounters.Size() == 1 && registry.NarrativeEncounters[0].health == 418,
                "serialized encounter identity survives migration and hub return");
    }

    void Conditions(CaelumPlayer user)
    {
        let record = user.GetPersistentCharacterState(false);
        let all = Term(CaelumQuestRequirements.ALL, 0, 0);
        all.Terms.Push(Term(CaelumQuestRequirements.QUEST_STATE, 1, CaelumConstants.QUEST_STATE_COMPLETED));
        let alternatives = Term(CaelumQuestRequirements.ANY, 0, 0);
        alternatives.Terms.Push(Term(CaelumQuestRequirements.KNOWN_OBJECTIVE, 0, 1, 7));
        alternatives.Terms.Push(Term(CaelumQuestRequirements.QUEST_STATE, 2, CaelumConstants.QUEST_STATE_OFFERED));
        all.Terms.Push(alternatives);
        Check(all.Evaluate(record), "composite all and any read canonical facts");
        all.Terms.Push(Term(CaelumQuestRequirements.KNOWN_OBJECTIVE, 0, 1, 7));
        Check(!all.Evaluate(record), "hidden objective cannot satisfy a requirement");
        let invalid = Term(CaelumQuestRequirements.ALL, 0, 0);
        Check(!invalid.Evaluate(record), "empty requirement fails closed");
        invalid.Terms.Push(invalid);
        Check(!invalid.Evaluate(record), "cyclic requirement terminates safely");
        Check(!CaelumQuestRequirements.Matches(record, CaelumQuestRequirements.QUEST_STATE, 32, 2),
            "undefined quest rejected");
        Check(!CaelumQuestRequirements.Matches(record, CaelumQuestRequirements.MEMBERSHIP, 8, 1),
            "invalid faction rejected");
        Check(!CaelumQuestTransitions.ObserveState(record, CaelumConstants.QUEST_SEWERS, 2, 2),
            "world derived quest cannot get a second owner");
        Check(CaelumSideQuestRules.Start(user, 2), "successor starts once");
        Check(CaelumSideQuestRules.End(record, 2, true), "active quest can be abandoned");
        Check(!CaelumSideQuestRules.End(record, 2, false) && !CaelumSideQuestRules.Start(user, 2),
            "terminal abandonment does not restart or change outcome");
        record.QuestState[2] = CaelumConstants.QUEST_STATE_OFFERED;
        Check(CaelumSideQuestRules.Start(user, 2) && CaelumSideQuestRules.End(record, 2, false),
            "authored failure remains available");
        Check(!CaelumSideQuestRules.Complete(record, 2) && !CaelumSideQuestRules.Claim(user, 2),
            "failed quest cannot complete or reward");
        record.QuestState[2] = CaelumConstants.QUEST_STATE_OFFERED;
    }

    void Registry(CaelumPlayer user, int phase)
    {
        let registry = CaelumSiegeEvents(EventHandler.Find("CaelumSiegeEvents"));
        if (phase == 0)
        {
            Check(registry != null && registry.NarrativeRegistryRevision == 1, "native registry initialized");
            RegistryInitial = registry.NarrativeEncounters.Size();
            RegistryProbe = CaelumSiegeEncounter(Actor.Spawn("CaelumSiegeEncounter", (128,128,0)));
            return; // PostBeginPlay se procesa en el siguiente tic nativo.
        }
        if (phase == 2)
        {
            Check(registry.NarrativeEncounters.Size() == RegistryInitial && registry.NarrativeEncounter() == null,
                "destroy unregisters encounter");
            return;
        }
        let encounter = RegistryProbe;
        Check(registry.NarrativeEncounters.Size() == RegistryInitial + 1, "spawn registers encounter");
        Check(registry.NarrativeEncounter() == null, "unsealed encounter is not a story event");
        encounter.RosterSealed = true;
        encounter.Machines.Resize(12);
        encounter.Boss = new("CaelumSiegeCombatant");
        encounter.Boss.Encounter = encounter;
        Check(registry.NarrativeEncounter() == encounter, "sealed encounter becomes visible without world scan");
        Check(CaelumDemoNarrative.ObservePort(user, encounter), "first port observation publishes progress");
        Check(!CaelumDemoNarrative.ObservePort(user, encounter), "unchanged observation does not republish Journal");
        encounter.NeutralizedCount = 7;
        Check(CaelumDemoNarrative.ObservePort(user, encounter), "changed objective publishes once");
        Check(!CaelumDemoNarrative.ObservePort(user, encounter), "duplicate objective does not republish");
        encounter.NeutralizedCount = 12; encounter.Boss.ConfirmedDead = true; encounter.Victory = true;
        Check(CaelumDemoNarrative.ObservePort(user, encounter), "real victory fact completes narrative state");
        Check(!CaelumDemoNarrative.ObservePort(user, encounter), "victory observation is idempotent");
        registry.NarrativeRegistryRevision = 0;
        Check(registry.NarrativeEncounter() == encounter && registry.NarrativeRegistryRevision == 1,
            "legacy registry reconstructs once");
        Check(registry.NarrativeEncounters.Size() == RegistryInitial + 1, "registry migration does not duplicate entries");
        encounter.Destroy();
        let record = user.GetPersistentCharacterState(false);
        record.DemoNarrativeDelivered |= CaelumDemoNarrative.ObservedEvents(record);
        record.DemoNarrativePending = 0;
    }

    override void NetworkProcess(ConsoleEvent e)
    {
        let user = CaelumPlayer(players[e.Player].mo); if (user == null) return;
        if (e.Name == "ca418_seed") Seed(user);
        if (e.Name == "ca418_preserved") Preserved(user);
        if (e.Name == "ca418_check") { Conditions(user); Registry(user, 0); }
        if (e.Name == "ca418_registry") Registry(user, 1);
        if (e.Name == "ca418_destroyed") Registry(user, 2);
        if (e.Name == "ca418_bench") Benchmark();
        if (e.Name == "ca418_done") Console.Printf("CA418 RESULT checks=%d failures=%d", Checks, Failures);
    }
}
