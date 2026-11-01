class CA440ClockBody : CaelumCombatActor
{
    int Incoming;
    override int DamageMobj(Actor inflictor,Actor source,int damage,Name mod,int flags,double angle)
    {if(mod=='CaelumTarotPiercing')Incoming+=damage;return Super.DamageMobj(inflictor,source,damage,mod,flags,angle);}
    Default {Health 100000;Radius 12;Height 56;Mass 80;PainChance 0;+SOLID +SHOOTABLE}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA440ClockLedger : Inventory
{
    int Phase,Started;
    CaelumTarotJustice Duel;
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE -INVENTORY.INVBAR}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA440Probe : StaticEventHandler
{
    bool Entered,Reloaded;
    void Check(bool okay,String label){Console.Printf("CA440K %s %s",okay?"PASS":"FAIL",label);}
    override void WorldTick()
    {
        let user=CaelumPlayer(players[0].mo),other=CaelumPlayer(players[1].mo);
        if(!CaelumWorldClockTicker.Ready(user) || !CaelumWorldClockTicker.Ready(other))return;
        let ledger=CA440ClockLedger(user.FindInventory('CA440ClockLedger'));
        if(!Entered){Entered=true;Reloaded=ledger!=null;}
        if(ledger==null)
        {
            ledger=CA440ClockLedger(user.GiveInventoryType('CA440ClockLedger'));
            user.SetOrigin((-600,-600,0),false);other.SetOrigin((-600,-300,0),false);
            user.Angle=90;user.Pitch=0;
            let body=CA440ClockBody(Actor.Spawn('CA440ClockBody',(-400,-600,0),NO_REPLACE));
            let aim=new('CaelumTarotGroundAim');aim.Found=true;aim.Point=(-400,-450,0);aim.Damage=60;aim.RangeMultiplier=1;
            let record=user.GetPersistentCharacterState(false);
            for(int card=0;card<78;card++){record.TarotActive[card]=false;record.TarotRemaining[card]=0;}
            CaelumTarotSequence.ApplyCard(user,record,3,70,body,false,aim);
            let roots=CaelumTarotPlantState(user.FindInventory('CaelumTarotPlantState')).Roots;
            CaelumTarotSequence.ApplyCard(user,record,2,70,null,false,aim);
            let mine=CaelumTarotMineState(user.FindInventory('CaelumTarotMineState')).Mine;
            let cart=CaelumTarotChariot.Launch(user);
            Check(roots!=null && mine!=null && cart!=null,"real sequence creates timed roots, trap and cart");
            Check(CaelumMajorWorldEvents.HasTimeEffects(),"forecast sees active world creations");
            let preview=new('CaelumTimeSkipModel');preview.CaptureSkip(user,false);
            Check(preview.Done && preview.Reason=="CA_SKIP_FORECAST_EFFECT","abstract forecast declines unsimulated world effects");
            CaelumTimeAdvanceState.SimulatePersonalTic(user,false);
            Check(roots.RemainingTics==70 && mine.RemainingTics==70 && cart.Age==0,"personal-only cooperative step never advances world effects");
            CaelumTimeAdvanceState.SimulatePersonalTic(user,true);
            Check(roots.RemainingTics==69 && mine.RemainingTics==69,"ordinary accelerated world path advances creations once");
            Check(cart.Age==1 && cart.Travelled>0,"accelerated step resolves Chariot motion");
            int remaining=roots.RemainingTics;
            user.SessionIdentityPending=true;CaelumMajorWorldEvents.AdvanceSkippedTic();user.SessionIdentityPending=false;
            Check(roots.RemainingTics==remaining && mine.RemainingTics==remaining && cart.Age==1,"pending identity freezes each owned effect");
            for(int i=0;i<34;i++)CaelumMajorWorldEvents.AdvanceSkippedTic();
            Check(roots.RemainingTics==35 && mine.RemainingTics==35,"same-frame substeps preserve each deadline");
            Check(body.Incoming==1,"accelerated piercing pulse retains damage per active second");
            for(int i=0;i<35;i++)CaelumMajorWorldEvents.AdvanceSkippedTic();
            Check(roots.bDestroyed && mine.bDestroyed,"roots and trap expire at their paid duration");
            Check(body.Incoming==2 && !CaelumTarotRooted.Active(body),"final pulse runs once and releases the target");
            CaelumMajorWorldEvents.AdvanceSkippedTic();
            Check(cart.bDestroyed && body.Incoming==2,"completed movement and damage do not replay");
            Check(CaelumTarotMine.Place(user,aim,20),"new source can appear after the cached snapshot");
            let next=CaelumTarotMineState(user.FindInventory('CaelumTarotMineState')).Mine;
            CaelumMajorWorldEvents.AdvanceSkippedTic();
            Check(next.RemainingTics==19,"completed creation invalidates same-frame source snapshot");
            next.Destroy();body.Destroy();
            Check(!CaelumMajorWorldEvents.HasTimeEffects(),"expired sources no longer block forecasting");
            ledger.Phase=1;Level.ChangeLevel("CARING",0,CHANGELEVEL_NOINTERMISSION);return;
        }
        if(level.MapName!="CARING")return;
        if(ledger.Phase==1 && level.time>5)
        {
            user.SetOrigin((64,64,0),false);other.SetOrigin((160,64,0),false);
            Check(CaelumTarotJustice.Start(user,other,70),"two players share one native Justice duel");
            let duel=CaelumJusticeLink.View(user).Duel;
            CaelumMajorWorldEvents.AdvanceSkippedTic();
            Check(duel.RemainingTics==69,"shared duel advances once, not once per participant");
            CaelumTimeAdvanceState.SimulatePersonalTic(user,false);CaelumTimeAdvanceState.SimulatePersonalTic(other,false);
            Check(duel.RemainingTics==69,"two personal cooperative steps do not duplicate the duel clock");
            duel.RemainingTics=1;CaelumMajorWorldEvents.AdvanceSkippedTic();
            Check(!CaelumJusticeLink.Bound(user) && !CaelumJusticeLink.Bound(other),"accelerated expiry safely returns both survivors");
            Check(CaelumTarotJustice.Start(user,other,2100),"fresh paid duel starts after accelerated return");
            ledger.Duel=CaelumJusticeLink.View(user).Duel;
            for(int i=0;i<35;i++)CaelumMajorWorldEvents.AdvanceSkippedTic();
            Check(ledger.Duel.RemainingTics==2065,"new duel joins the current-frame cache exactly once");
            ledger.Started=level.time;ledger.Phase=2;return;
        }
        if(ledger.Phase==2 && !Reloaded && level.time-ledger.Started>=5)
        {
            user.CurrentHunger=user.CurrentThirst=user.CurrentSleep=100;
            other.CurrentHunger=other.CurrentThirst=other.CurrentSleep=100;
            bool opened=CaelumCooperativeTime.Open(user);
            Check(opened,"actual cooperative time request opens during a safe duel");
            let vote=CaelumCooperativeTime.View(user);
            if(opened && vote!=null)
            {
                vote.Request(user,CaelumCooperativeTime.HOUR_DOWN,vote.Serial);
                vote.Request(user,CaelumCooperativeTime.ACCEPT,vote.Serial);
                vote.Request(other,CaelumCooperativeTime.ACCEPT,vote.Serial);
                Check(vote.Running,"unanimous native request starts shared time");
                let clock=CaelumWorldClock.Get(user);int day=clock.CompletedDays,tics=clock.DayTics;
                int remaining=ledger.Duel.RemainingTics;
                vote.Pump();
                int steps=(clock.CompletedDays-day)*CaelumWorldClock.TicsPerDay()+clock.DayTics-tics;
                Check(steps>0 && ledger.Duel.RemainingTics==remaining-steps,"real cooperative pump advances world effects once per shared step");
                vote.FinishVote("CA_COOP_TIME_CANCELLED");
            }
            else Console.Printf("CA440K safety %s",CaelumCooperativeTime.Safety(user));
            ledger.Phase=3;Console.Printf("CA440K RESULT capture");return;
        }
        if(ledger.Phase==3 && Reloaded)
        {
            Check(ledger.Duel!=null && CaelumJusticeLink.View(user).Duel==ledger.Duel && CaelumJusticeLink.View(other).Duel==ledger.Duel,"recovery preserves one pair identity");
            int remaining=ledger.Duel.RemainingTics;
            Check(remaining>0 && remaining<2065,"recovery preserves elapsed duration without resetting it");
            CaelumMajorWorldEvents.AdvanceSkippedTic();
            Check(ledger.Duel.RemainingTics==remaining-1,"transient source snapshot rebuilds without doubled steps");
            ledger.Duel.RemainingTics=1;CaelumMajorWorldEvents.AdvanceSkippedTic();
            Check(!CaelumJusticeLink.Bound(user) && !CaelumJusticeLink.Bound(other),"recovered duel expires through its normal safe return");
            ledger.Phase=4;Console.Printf("CA440K RESULT reload");
        }
    }
}
