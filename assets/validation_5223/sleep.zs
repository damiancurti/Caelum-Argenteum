// Native contract probe. Only the test addon exposes these console events.
class CA219Sleep : StaticEventHandler
{
    int Failures, ClockBefore;
    double SleepBefore;
    CaelumPlayer User;
    CaelumSleepingBag Bag;
    void Check(bool ok,String label)
    {if(!ok)Failures++;Console.Printf("CA219 %s %s",ok?"PASS":"FAIL",label);}
    void Reset()
    {
        CaelumTimeSkipState.FinishSkip(User,"",true);CaelumRestState.Cancel(User);
        User.CombatTimeRemaining=0;User.CurrentHunger=90;User.CurrentThirst=90;User.CurrentSleep=30;
        User.Vel=(0,0,0);Bag.InMagicBox=false;User.CraftingTaskActive=false;
    }
    void BeginSkip()
    {
        Check(Bag.BeginRest(User,480),"begin long bag sleep");
        Check(CaelumTimeSkipState.OpenMenu(User),"Y opens from bag sleep outside zone");
        let s=CaelumTimeSkipState.Get(User);
        Check(s!=null && s.BagSupport && s.Sleeping && s.AnchorFurniture==null,"Y keeps bag support after deployed mat is released");
        Check(!CaelumRestState.IsActive(User),"Y closes previous rest session");
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        User=CaelumPlayer(players[e.Player].mo);if(User==null)return;
        Bag=CaelumSleepingBag(User.FindInventory("CaelumSleepingBag"));
        if(e.Name=="c219_prepare")
        {
            if(User.player.ConversationNPC!=null)User.player.ConversationNPC.bInConversation=false;
            User.player.ConversationNPC=null;User.player.ConversationPC=null;
            User.CreationWizardOpen=false;User.CharacterCreationComplete=true;
            User.ApplyCharacterProfile();User.GetPersistentCharacterState(true).ProfileCommitted=true;
            if(Bag==null)Bag=CaelumSleepingBag(User.GiveInventoryType("CaelumSleepingBag"));
            Reset();User.SetOrigin(CaelumMazeLayout.ArrivalChairPosition()+(128,128,0),false);
            User.UpdateSurvivalStates();User.Angle=0;User.Pitch=0;
        }
        if(e.Name=="c219_fast")
        {
            Check(CaelumRestBag.HasRoom(User),"dry clear floor fits bag");
            Check(!CaelumTimeAdvanceState.InSafeZone(User),"floor is outside authored safe zones");
            Check(Bag.BeginRest(User,5),"five-minute bag sleep begins");
            Check(CaelumTimeAdvanceState.IsSewerBagSleep(User),"only deployed owned bag grants exception");
            Check(CaelumRestState.ResourceFactor(User)==3,"unchanged bag comfort");
            SleepBefore=User.CurrentSleep;ClockBefore=CaelumWorldClock.Get(User).DayTics;
            Check(CaelumTimeAdvanceState.Toggle(User),"T accelerates outside marked zone");
        }
        if(e.Name=="c219_fast_done")
        {
            let rest=CaelumRestState.Get(User);let fast=CaelumTimeAdvanceState.Get(User);
            Check(rest.Status==CaelumRestRules.STATUS_COMPLETE,"five-minute rest completes");
            Check(rest.ElapsedTics>=rest.RequestedTics && fast.SimulatedTics>0,"T simulated actual rest tics");
            Check(User.CurrentSleep>SleepBefore,"sleep recovers during T");
            Check(CaelumWorldClock.Get(User).DayTics>ClockBefore,"MAP02 exterior clock advances normally");
            Check(!fast.Active && rest.Furniture==null && rest.ViewCamera==null,"completion releases acceleration mat and camera");
            Check(Bag.AvailableTo(User) && Bag.Amount==1,"same single owned bag survives rest");
            Reset();
            Check(!CaelumTimeSkipState.OpenMenu(User),"carrying a bag alone does not permit Y outside zone");
            Check(CaelumRestState.Begin(User,CaelumRestRules.MODE_WAIT,5),"ordinary waiting remains available");
            Check(CaelumTimeAdvanceState.BlockReason(User)=="CA_FAST_ZONE","ground waiting cannot accelerate outside zone");
            Reset();User.CraftingTaskActive=true;
            Check(!CaelumTimeAdvanceState.IsSewerBagSleep(User,true),"crafting cannot borrow sleeping exception");
            Check(CaelumTimeAdvanceState.BlockReason(User,false,true)=="CA_FAST_ZONE","crafting cannot bypass zone guard during Y substeps");
            Reset();BeginSkip();
        }
        if(e.Name=="c219_y_start")
        {
            let s=CaelumTimeSkipState.Get(User);
            Check(s!=null && s.Open && s.BagSupport && s.Sleeping,"Y open state retains bag sleep");
            SleepBefore=User.CurrentSleep;ClockBefore=CaelumWorldClock.Get(User).DayTics;
            Check(CaelumTimeSkipState.Start(User),"Y starts actual sleep simulation");
            Check(CaelumTimeSkipState.ResourceFactor(User)==3,"Y retains bag comfort");
        }
        if(e.Name=="c219_y_done")
        {
            let s=CaelumTimeSkipState.Get(User);
            Check(s.Completed && !s.Active && s.LastReason=="CA_SKIP_COMPLETE","Y reaches chosen civil time");
            Check(s.ElapsedTics>0 && s.SleepTics==s.ElapsedTics,"Y only credits simulated sleeping tics");
            Check(User.CurrentSleep>SleepBefore && CaelumWorldClock.Get(User).DayTics>ClockBefore,"Y restores sleep and advances exterior clock");
            Check(Bag.AvailableTo(User) && Bag.Amount==1,"Y preserves single owned bag");
        }
        if(e.Name=="c219_guards")
        {
            Reset();Check(Bag.BeginRest(User,480),"bag rest for guards");
            User.CombatTimeRemaining=1;
            Check(CaelumTimeAdvanceState.BlockReason(User)!="","combat still blocks T");
            Check(CaelumTimeSkipRules.BlockReason(User)!="","combat still blocks Y");
            User.CombatTimeRemaining=0;User.CurrentThirst=0;
            Check(CaelumTimeAdvanceState.BlockReason(User)=="CA_REST_NEEDS","critical thirst still blocks acceleration");
            User.CurrentThirst=90;
            let hostile=Actor.Spawn("CaelumGiantRat",User.Pos+(128,0,0),NO_REPLACE);
            Check(CaelumTimeAdvanceState.BlockReason(User)=="CA_FAST_UNSAFE","nearby hostile still blocks T");
            Check(CaelumTimeSkipRules.BlockReason(User)=="CA_FAST_UNSAFE","nearby hostile still blocks Y");
            hostile.Destroy();
            let obstacle=Actor.Spawn("CaelumRestBed",User.Pos+(30,0,0),NO_REPLACE);
            Check(CaelumTimeAdvanceState.BlockReason(User)=="CA_SLEEPING_BAG_SPACE","new obstacle invalidates sleeping area");
            obstacle.Destroy();
            Bag.InMagicBox=true;
            Check(!CaelumTimeAdvanceState.IsSewerBagSleep(User),"boxed bag loses T exception");
            Reset();BeginSkip();
            Check(CaelumTimeSkipState.Start(User),"Y starts for mid-step checks");
            let s=CaelumTimeSkipState.Get(User);int elapsed=s.ElapsedTics;
            Bag.InMagicBox=true;CaelumTimeSkipState.PrepareStep(User);
            Check(!s.Active && s.LastReason=="CA_FAST_ZONE" && s.ElapsedTics==elapsed,"boxing bag stops Y before next simulated tic");
            Reset();BeginSkip();Check(CaelumTimeSkipState.Start(User),"Y starts for waking check");
            elapsed=s.ElapsedTics;User.CurrentSleep=100;CaelumTimeSkipState.PrepareStep(User);
            Check(!s.Active && !s.Sleeping && s.LastReason=="CA_FAST_ZONE" && s.ElapsedTics==elapsed,"waking stops outside-zone Y before awake time");
            Reset();BeginSkip();Check(CaelumTimeSkipState.Start(User),"Y starts for missing-bag check");
            User.RemoveInventory(Bag);CaelumTimeSkipState.PrepareStep(User);
            Check(!s.Active && s.LastReason=="CA_FAST_ZONE","lost bag stops Y substep");
            Bag.AttachToOwner(User);Reset();
        }
        if(e.Name=="c219_save_rest")
        {Reset();Check(Bag.BeginRest(User,480),"active bag sleep ready to save");}
        if(e.Name=="c219_save_active")
        {
            Reset();BeginSkip();let s=CaelumTimeSkipState.Get(User);s.Shift(User,420);
            Check(CaelumTimeSkipState.Start(User),"long Y sleep starts for active save");
            Console.Printf("CA219 DONE failures=%d",Failures);
        }
        if(e.Name=="c219_load_active")
        {
            let s=CaelumTimeSkipState.Get(User);
            Check(s!=null && s.Open && s.BagSupport,"loaded Y retains open state and bag support");
            Check(s.ElapsedTics>0 && s.SleepTics==s.ElapsedTics,"loaded Y retains simulated sleep totals");
            Check(!s.Active && s.LastReason=="CA_FAST_ZONE" && User.CurrentSleep>=99.9,"loaded Y completes sleep and stops on waking outside zone");
            Check(Bag.AvailableTo(User) && Bag.Amount==1,"active Y save preserves owned bag");
        }
        if(e.Name=="c219_load_rest")
        {
            let rest=CaelumRestState.Get(User);
            Check(rest!=null && rest.Status==CaelumRestRules.STATUS_ACTIVE,"saved bag rest remains active");
            Check(rest.Furniture!=null && rest.Furniture.SupportsRest(User),"saved deployed mat retains occupant and bag");
            Check(CaelumTimeAdvanceState.Toggle(User),"loaded rest can accelerate outside zone");
            CaelumTimeAdvanceState.Halt(User);Reset();BeginSkip();
        }
        if(e.Name=="c219_safe")
        {
            Reset();User.SetOrigin(CaelumMazeLayout.ArrivalBedPosition()+(128,128,0),false);
        }
        if(e.Name=="c219_safe_wake")
        {
            Check(CaelumTimeAdvanceState.InSafeZone(User),"control position lies in authored safe zone");
            Check(CaelumTimeSkipState.OpenMenu(User),"Y still opens normally in safe zone");
            let s=CaelumTimeSkipState.Get(User);s.Sleeping=true;
            Check(CaelumTimeSkipState.Start(User),"safe-zone Y starts");
            User.CurrentSleep=100;CaelumTimeSkipState.PrepareStep(User);
            Check(s.Active && !s.Sleeping,"safe-zone Y may keep waiting after waking");
            CaelumTimeSkipState.FinishSkip(User,"",true);
        }
        if(e.Name=="c219_done")Console.Printf("CA219 DONE failures=%d",Failures);
    }
}
