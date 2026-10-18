// Fixture aislado: la escritura y carga siguen siendo las nativas del motor.
class CA324SaveMark : Inventory
{
    int ClockDays, ClockTics;
    bool RuloCheckpoint;
    CaelumAnchoredResident Follower;
    Default { +INVENTORY.UNDROPPABLE }
}

class CA324Probe : CA282Probe
{
    ui int UIPassed, UIFailed, BeforeRequests;
    ui double BeforeElapsed, WallStart;
    ui bool KeepMenu;

    ui void UIAssert(bool ok, String label)
    { if (ok) UIPassed++; else UIFailed++; Console.Printf("CA282 %s %s", ok?"PASS":"FAIL", label); }

    override void UiTick()
    { if (!KeepMenu) Super.UiTick(); }

    override void WorldTick()
    {
        let user = CaelumPlayer(players[consoleplayer].mo);
        if (user == null) return;
        let mark = CA324SaveMark(user.FindInventory("CA324SaveMark"));
        let clock = CaelumWorldClock.Get(user);
        if (mark != null && clock != null)
        { mark.ClockDays = clock.CompletedDays; mark.ClockTics = clock.DayTics; }
    }

    override void WorldLoaded(WorldEvent e)
    {
        if (!e.IsSaveGame) return;
        User = CaelumPlayer(players[consoleplayer].mo);
        let mark = CA324SaveMark(User.FindInventory("CA324SaveMark"));
        if (mark == null) return;
        if (mark.RuloCheckpoint)
        {
            let bull = CaelumMainM00RuloTrial.GetBull();
            Check(bull != null && bull.TrialFighter == User && bull.RuloPartyPrepared
                && !bull.TrialReleased && bull.TrialGraceTicks > 0,
                "native Rulo autosave retains party and pre-hostility grace");
        }
        let bag = User.FindInventory("CaelumSleepingBag");
        let clock = CaelumWorldClock.Get(User);
        Check(bag != null && bag.Amount == 1 && bag.args[0] == 324, "autosave preserves individual inventory");
        Check(mark.Follower != null && mark.Follower.EscortPrisonerLeader == User
            && mark.Follower.EscortPrisonerId == CaelumConstants.PRISONER_UNITARIO
            && User.GetPrisonerRescueState(CaelumConstants.PRISONER_UNITARIO) == CaelumConstants.PRISONER_STATE_FOLLOWING,
            "autosave preserves released follower identity and owner");
        Check(clock.CompletedDays == mark.ClockDays && clock.DayTics == mark.ClockTics,
            "autosave preserves exact captured calendar clock");
        Check(User.GetPersistentCharacterState(false).HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_PALOMO_MET),
            "autosave preserves mission flag");
    }

    void Seed()
    {
        Setup(); User.PersistCharacterState();
        let bag = User.FindInventory("CaelumSleepingBag");
        if (bag == null) bag = User.GiveInventoryType("CaelumSleepingBag");
        bag.args[0] = 324;
        let mark = CA324SaveMark(User.GiveInventoryType("CA324SaveMark"));
        mark.Follower = CaelumAnchoredResident(Actor.Spawn("CaelumPrisonerUnitario", (160,0,0)));
        mark.Follower.ChangeTid(324);
        User.GetPersistentCharacterState(true).SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_PALOMO_MET);
        CaelumWorldClock.Get(User,true);
    }

    override void NetworkProcess(ConsoleEvent e)
    {
        Super.NetworkProcess(e);
        let owner = CaelumAutosaveEvents.Get();
        if (e.Name == "c324_seed") Seed();
        if (e.Name == "c324_release")
        {
            let mark = CA324SaveMark(User.FindInventory("CA324SaveMark"));
            mark.Follower.ReleaseEscortPrisoner(User);
            Check(mark.Follower.EscortPrisonerLeader == User, "fixture released original follower");
            owner.RestartInterval();
        }
        if (e.Name == "c324_reset") owner.RestartInterval();
        if (e.Name == "c324_checkpoint")
        {
            int before = owner.RequestCount;
            CaelumAutosaveEvents.Checkpoint(User); CaelumAutosaveEvents.Checkpoint(User);
            Check(owner.RequestCount == before+1 && owner.AwaitingNativeCheck, "same-tic checkpoint requests coalesce");
        }
        if (e.Name == "c324_defer")
        {
            int before = owner.RequestCount; User.health = 0; owner.Pending = true;
            Check(!owner.TryRequest(User) && owner.Pending && owner.RequestCount == before,
                "invalid body retains one due request");
        }
        if (e.Name == "c324_queueddeath")
        {
            CaelumAutosaveEvents.Checkpoint(User);
            User.health = 0; User.player.health = 0; User.player.playerstate = PST_DEAD;
        }
        if (e.Name == "c324_rejected")
            Check(owner.Pending && !owner.AwaitingNativeCheck,
                "death before native CHECK preserves one due request");
        if (e.Name == "c324_revive")
        { User.health = 100; User.player.health = 100; User.player.playerstate = PST_LIVE; }
        if (e.Name == "c324_rulo")
        {
            let bull = CaelumMainM00RuloTrial.GetBull();
            Check(bull != null, "real mansion trial bull exists");
            if (bull != null)
            {
                CA324SaveMark(User.FindInventory("CA324SaveMark")).RuloCheckpoint = true;
                CaelumMainM00RuloTrial.StartFight(User,bull);
                Check(bull.TrialFighter == User && bull.TrialGraceTicks > 0 && bull.RuloPartyPrepared,
                    "existing Rulo preparation precedes shared native request");
            }
        }
        if (e.Name == "c324_fast")
        {
            Actor.Spawn("CaelumTimeAdvanceZone",User.Pos);
            User.Vel = (0,0,0); User.CombatTimeRemaining = 0;
            User.CurrentHunger = User.CurrentThirst = User.CurrentSleep = 100;
            Check(CaelumRestState.Begin(User,CaelumRestRules.MODE_SLEEP,30), "native rest starts for acceleration");
            Check(CaelumTimeAdvanceState.Toggle(User), "actual accelerated rest starts");
        }
        if (e.Name == "c324_fastcheck")
        {
            let advance = CaelumTimeAdvanceState.Get(User);
            Check(advance != null && advance.SimulatedTics > 35, "actual accelerated personal ticks ran");
            Console.Printf("CA324 FAST simulated%d",advance == null ? 0 : advance.SimulatedTics);
            CaelumTimeAdvanceState.Halt(User); CaelumRestState.Interrupt(User,"CA_REST_MOVED");
        }
        if (e.Name == "c324_calendar")
        {
            let clock = CaelumWorldClock.Get(User);
            for (int n=0;n<600;n++) clock.AdvanceOneTic();
            Check(true, "calendar advancement uses no autosave timer calls");
        }
    }

    override void ConsoleProcess(ConsoleEvent e)
    {
        let owner = CaelumAutosaveEvents.Get();
        if (e.Name == "c324_arm")
        {
            owner.ActiveMilliseconds = CaelumSaveRules.ACTIVE_INTERVAL_SECONDS*1000-(e.Args[0]>0?e.Args[0]:500);
            owner.HasSample = false; owner.RequestSent = false;
            BeforeRequests = owner.RequestCount; WallStart = MSTimeF();
        }
        if (e.Name == "c324_middle")
        { owner.ActiveMilliseconds = 120000; owner.HasSample = false; }
        if (e.Name == "c324_snapshot")
        { BeforeElapsed = owner.ActiveMilliseconds; BeforeRequests = owner.RequestCount; WallStart = MSTimeF(); }
        if (e.Name == "c324_frozen")
        {
            UIAssert(owner.ActiveMilliseconds == BeforeElapsed, "inactive UI time is excluded exactly");
            UIAssert(owner.RequestCount == BeforeRequests, "inactive interval issues no autosave");
        }
        if (e.Name == "c324_saved")
        {
            UIAssert(owner.RequestCount == BeforeRequests+1 && !owner.Pending, "one due native autosave request");
            UIAssert(owner.ActiveMilliseconds < 10000, "request restarts five-minute interval");
            Console.Printf("CA324 SAVED wallMs%.3f elapsedMs%.3f requests%d", MSTimeF()-WallStart, owner.ActiveMilliseconds, owner.RequestCount);
        }
        if (e.Name == "c324_fasttime")
        {
            UIAssert(owner.RequestCount == BeforeRequests, "accelerated rest produces no save burst");
            UIAssert(owner.ActiveMilliseconds-BeforeElapsed <= MSTimeF()-WallStart+100,
                "autosave elapsed follows real time during accelerated rest");
        }
        if (e.Name == "c324_longcheck")
        {
            UIAssert(MSTimeF()-WallStart >= 300000, "full real five-minute interval elapsed");
            UIAssert(owner.RequestCount == BeforeRequests+1, "one periodic save across full real interval");
            Console.Printf("CA324 LONG wallMs%.3f elapsedMs%.3f requests%d", MSTimeF()-WallStart, owner.ActiveMilliseconds, owner.RequestCount);
        }
        if (e.Name == "c324_travelcheck")
            UIAssert(owner.ActiveMilliseconds >= BeforeElapsed && owner.ActiveMilliseconds < BeforeElapsed+10000,
                "hub travel preserves accumulated active time without loading time");
        if (e.Name == "c324_reloaded")
            UIAssert(owner.ActiveMilliseconds < 10000 && owner.RequestCount == BeforeRequests && !owner.Pending,
                "same-process near-due reload resets without an immediate autosave");
        if (e.Name == "c324_loaded")
            UIAssert(owner.ActiveMilliseconds < 10000 && owner.RequestCount == 0 && !owner.Pending,
                "loaded save starts fresh interval without a save loop");
        if (e.Name == "c324_keepmenu") KeepMenu = true;
        if (e.Name == "c324_closemenu")
        { KeepMenu = false; if (Menu.GetCurrentMenu()!=null) Menu.GetCurrentMenu().Close(); }
        if (e.Name == "c324_done")
            Console.Printf("CA282 DONE passes=%d failures=%d", Passed+UIPassed, Failed+UIFailed);
    }
}
