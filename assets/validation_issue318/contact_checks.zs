class CA318HeatProbe : EventHandler
{
    int Checks,Failures;
    override bool InputProcess(InputEvent e){return true;}
    override void UiTick(){if(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();}
    void Check(bool ok,String label)
    {Checks++;if(!ok)Failures++;Console.Printf("CA318 %s %s",ok?"PASS":"FAIL",label);}
    bool Near(double a,double b){return Abs(a-b)<0.000001;}
    CaelumPlayer User(){return CaelumPlayer(players[0].mo);}
    CA318HeatHolder Holder()
    {let it=ThinkerIterator.Create("CA318HeatHolder");return CA318HeatHolder(it.Next());}
    CaelumCombatActor Body(vector3 point)
    {
        let body=CaelumCombatActor(Actor.Spawn("CA318HeatBody",point,NO_REPLACE));
        CaelumFolkloreCombatActor(body).InitializeUniformFolkloreProfile(6);
        body.CaelumDiagnosticPassiveAI=true;body.bInvulnerable=true;
        body.ElementalStatus=new("CaelumElementalStatus");body.CombatToughness=0;
        body.CombatArmor.InitializeUniformLoadout(CaelumConstants.ARMOR_TYPE_BASE_CLOTHING,1);
        let thermal=CaelumThermalBody.Get(body,true);CaelumThermalBody.Refresh(body,thermal);
        return body;
    }
    void Setup()
    {
        let user=User();user.CharacterCreationComplete=true;user.CreationWizardOpen=false;
        user.ApplyCharacterProfile();user.bInvulnerable=true;
        let h=CA318HeatHolder(Actor.Spawn("CA318HeatHolder",(0,0,0)));
        h.Demon=Body((-2048,0,0));h.Victim=Body((-1952,0,0));
        h.Far=Body((-1792,0,0));h.Side=Body((-2048,96,0));h.Wall=Body((576,0,0));
        h.Demon.Angle=0;h.Demon.target=h.Victim;
        h.Stream=CaelumDemonBreath(Actor.Spawn("CaelumDemonBreath",h.Demon.Pos));
        h.Stream.Emitter=h.Demon;h.Demon.DemonBreath=h.Stream;
    }
    void ContactChecks()
    {
        let h=Holder();let s=h.Victim.ElementalStatus;
        h.Victim.CombatArmor.InitializeUniformLoadout(CaelumConstants.ARMOR_TYPE_HEAVY,1);
        h.Stream.PaidTick();
        double raw=h.Stream.ReceivedWatts(h.Victim,h.Victim.ThermalState);
        double cap=CaelumDemonBreathRules.Watts()*CaelumThermalData.FIRE_RADIATIVE_FRACTION;
        double retention=CaelumThermalMagic.AreaRetention(h.Victim);
        Check(h.Stream.Contact(h.Victim) && s.BurnHeatWatts>0,"accepted direct contact stores positive heat");
        Check(retention>0 && retention<1,"armor control has nontrivial retention");
        Check(Near(s.BurnHeatWatts,Min(raw,cap)*retention),"existing absorption and armor applied once");
        Check(!h.Stream.Contact(h.Far) && !h.Far.ElementalStatus.HasBurnHeat(),"distant body receives no heat");
        Check(!h.Stream.Contact(h.Side) && !h.Side.ElementalStatus.HasBurnHeat(),"outside cone receives no heat");
        Check(!h.Demon.ElementalStatus.HasBurnHeat(),"emitter receives no self radiation");
        Check(Near(s.PendingBurnHeatJoules,0),"contact queues no duplicate immediate heat");
        double watts=s.BurnHeatWatts;
        h.Victim.CombatArmor.InitializeUniformLoadout(CaelumConstants.ARMOR_TYPE_BASE_CLOTHING,1);
        s.TickBurnHeat(h.Victim);
        Check(Near(s.PendingBurnHeatJoules,watts/TICRATE),"stored absorbed heat unaffected by later armor change");
        h.Stream.FlushHeat();
        Check(Near(s.PendingBurnHeatJoules,watts/TICRATE),"stopping emission does not repeat contact heat");
        h.Demon.SetOrigin((480,0,0),false);h.Demon.target=h.Wall;h.Stream.PaidTick();
        Check(!h.Stream.Contact(h.Wall) && !h.Wall.ElementalStatus.HasBurnHeat(),"native wall blocks nearby contact and heat");
        h.Demon.SetOrigin((-2048,0,0),false);h.Demon.target=h.Victim;
        // Deliberately enlarged diagnostic receiving areas force the cap branch.
        h.Side.SetOrigin(h.Victim.Pos+(0,16,0),false);
        s.ClearBurnHeat();h.Side.ElementalStatus.ClearBurnHeat();
        h.Victim.ThermalState.SurfaceArea*=100;h.Side.ThermalState.SurfaceArea*=100;
        h.Stream.PaidTick();
        double rawA=h.Stream.ReceivedWatts(h.Victim,h.Victim.ThermalState);
        double rawB=h.Stream.ReceivedWatts(h.Side,h.Side.ThermalState);
        double sum=rawA+rawB;
        Check(h.Stream.Contact(h.Side) && sum>cap,"two local contacts exercise shared power cap");
        Check(Near(s.BurnHeatWatts,rawA*cap/sum*CaelumThermalMagic.AreaRetention(h.Victim))
            && Near(h.Side.ElementalStatus.BurnHeatWatts,rawB*cap/sum*CaelumThermalMagic.AreaRetention(h.Side)),
            "multiple contacts divide emitted budget proportionally before armor");
        Check(s.BurnHeatWatts+h.Side.ElementalStatus.BurnHeatWatts<=cap+0.000001,
            "aggregate contact power never exceeds emitted budget");
    }
    void StatusChecks()
    {
        let h=Holder();let s=h.Victim.ElementalStatus;
        s.ClearBurnHeat();s.ApplyBurnHeat(1,2,100);s.ApplyBurnHeat(1,2,100);
        Check(Near(s.BurnHeatWatts,100) && Near(s.BurnHeatRemaining,1),"equal contacts do not stack");
        s.ApplyBurnHeat(2,1,200);Check(Near(s.BurnHeatWatts,100),"weaker contact cannot replace stronger heat");
        s.ApplyBurnHeat(1,3,200);Check(Near(s.BurnHeatWatts,200),"stronger contact replaces heat");
        for(int i=0;i<TICRATE;i++)s.TickBurnHeat(h.Victim);
        Check(Near(s.TakeBurnHeat(),200) && Near(s.TakeBurnHeat(),0),"one second conserved and consumed only once");
        s.ClearBurnHeat();s.ApplyBurnHeat(0.5/TICRATE,1,70);s.TickBurnHeat(h.Victim);
        Check(Near(s.TakeBurnHeat(),1) && !s.HasBurnHeat(),"fractional final tic contributes exact energy");
        s.ApplyBurnHeat(1,2,100);s.TickBurnHeat(h.Victim);
        double pending=s.PendingBurnHeatJoules,remaining=s.BurnHeatRemaining;
        s.ApplyDamageOverTime(CaelumConstants.ELEMENTAL_EFFECT_BURN,5,3,1,h.Demon,h.Victim);
        Check(Near(s.PendingBurnHeatJoules,pending) && Near(s.BurnHeatRemaining,remaining),"generic burn neither erases nor extends contact heat");
        h.Victim.CombatToughness=1000000;s.Tick(h.Victim);
        Check(s.BurnHeatWatts>0 && s.PendingBurnHeatJoules>pending,"healing toughness cannot invert thermal energy");
        pending=s.PendingBurnHeatJoules;remaining=s.BurnHeatRemaining;s.Tick(h.Victim,false);
        Check(Near(s.PendingBurnHeatJoules,pending) && Near(s.BurnHeatRemaining,remaining),"logical personal step creates no heat or duration loss");
        s.BurnVisualRemaining=0;s.UpdateVisualEffects(h.Victim);
        Check(s.BurnVisual!=null && CaelumAttachedElementalVisual(s.BurnVisual).Active(),"heat duration retains attached fire visual");
        CaelumResurrection.ClearNegative(h.Victim);
        Check(!s.HasBurnHeat() && Near(s.BurnHeatWatts,0),"resurrection clears active and queued heat");
        let old=new("CaelumElementalStatus");old.BurnRemaining=3;old.EnsureBurnHeat();
        Check(!old.HasBurnHeat() && old.BurnRemaining==3,"legacy burn does not invent contact watts");
        old.ApplyBurnHeat(2,1,100);old.EnsureBurnHeat();
        Check(old.BurnHeatWatts==100 && old.BurnHeatRemaining==2,"migration idempotent after first contact");
        let u=User();u.ElementalStatus.ClearBurnHeat();
        u.ElementalStatus.BurnRemaining=0;
        Check(CaelumTimeAdvanceState.BlockReason(u,false,true)=="","no-heat accelerated-time control is allowed");
        Check(CaelumJourneyRules.BlockReason(u)=="","no-heat journey control is allowed");
        u.ElementalStatus.ApplyBurnHeat(1,1,100);
        Check(CaelumTimeAdvanceState.BlockReason(u,false,true)=="CA_FAST_UNSAFE","heat alone blocks accelerated time");
        Check(CaelumJourneyRules.BlockReason(u)=="CA_JOURNEY_BUSY","heat alone blocks journey forecast");
        u.ElementalStatus.ClearBurnHeat();
    }
    void QueueChecks()
    {
        let h=Holder();let s=h.Victim.ElementalStatus;let t=h.Victim.ThermalState;
        h.Victim.CombatToughness=0;s.ClearBurnHeat();s.ApplyBurnHeat(1,1,100);
        for(int i=0;i<TICRATE;i++)s.TickBurnHeat(h.Victim);
        t.RuntimeReady=true;t.RuntimeMap=level.MapName;t.LastRealTic=level.maptime;
        t.LastWorldStamp=CaelumThermalRuntime.Stamp(CaelumWorldClock.Get(User()));
        double before=t.AbsorbedContinuousJoules;
        CaelumThermalRuntime.NPCStep(h.Victim,true);
        Check(Near(s.PendingBurnHeatJoules,100),"same-tic forced update retains queued heat");
        t.LastRealTic=level.maptime-TICRATE;t.NextUpdateTic=level.maptime+1;
        CaelumThermalRuntime.NPCStep(h.Victim);
        Check(Near(s.PendingBurnHeatJoules,100),"scheduled early return preserves queued heat");
        double exposure=t.Exposure;
        t.NextUpdateTic=level.maptime;
        CaelumThermalRuntime.NPCStep(h.Victim);
        Check(Near(t.AbsorbedContinuousJoules-before,100) && Near(s.PendingBurnHeatJoules,0),"normal thermal integration consumes queued energy once");
        Check(Near(t.Exposure-exposure,100/t.Inertia),"queued contact energy increases body temperature by joules over inertia");
        CaelumThermalRuntime.NPCStep(h.Victim,true);
        Check(Near(t.AbsorbedContinuousJoules-before,100),"repeated thermal update adds no heat");
    }
    void PlayerChecks()
    {
        let u=User();let s=u.ElementalStatus;let t=CaelumThermalBody.Get(u,true);
        s.ClearBurnHeat();s.ApplyBurnHeat(1.0/TICRATE,1,350);s.TickBurnHeat(u);
        double before=t.AbsorbedContinuousJoules;
        CaelumThermalRuntime.PlayerStep(u,false);
        Check(Near(s.PendingBurnHeatJoules,10) && Near(t.AbsorbedContinuousJoules,before),
            "player logical thermal step retains queued contact energy");
        CaelumThermalRuntime.PlayerStep(u,true);
        Check(Near(s.PendingBurnHeatJoules,0) && Near(t.AbsorbedContinuousJoules-before,10),
            "player real thermal step consumes exact queued energy");
        CaelumThermalRuntime.PlayerStep(u,true);
        Check(Near(t.AbsorbedContinuousJoules-before,10),"player repeated thermal step cannot duplicate energy");
    }
    void ConsumeLoaded()
    {
        let h=Holder();let s=h.Victim.ElementalStatus;let t=h.Victim.ThermalState;
        double before=t.AbsorbedContinuousJoules,pending=s.PendingBurnHeatJoules;
        t.RuntimeReady=true;t.RuntimeMap=level.MapName;t.LastRealTic=level.maptime-1;
        t.LastWorldStamp=CaelumThermalRuntime.Stamp(CaelumWorldClock.Get(User()));
        t.NextUpdateTic=level.maptime;
        CaelumThermalRuntime.NPCStep(h.Victim);
        Check(pending>0 && Near(t.AbsorbedContinuousJoules-before,pending) && Near(s.PendingBurnHeatJoules,0),
            "saved pending energy integrates exactly once after load");
    }
    void Seed()
    {
        let h=Holder();let s=h.Victim.ElementalStatus;s.ClearBurnHeat();
        s.ApplyBurnHeat(3,2,100);s.TickBurnHeat(h.Victim);
        h.Watts=s.BurnHeatWatts;h.Remaining=s.BurnHeatRemaining;h.Pending=s.PendingBurnHeatJoules;
        h.Exposure=h.Victim.ThermalState.Exposure;h.Continuous=h.Victim.ThermalState.AbsorbedContinuousJoules;
        h.TotalPaid=h.Stream.TotalPaidSeconds;
        Check(s.HasBurnHeat(),"save seed has active and pending heat");
    }
    void Loaded(bool legacy=false)
    {
        let h=Holder();Check(h!=null && h.Victim!=null && h.Stream!=null,"saved actor ownership survives");
        if(h==null || h.Victim==null || h.Stream==null)return;
        let s=h.Victim.ElementalStatus;
        if(legacy)
        {
            s.EnsureBurnHeat();h.Stream.FlushHeat();h.Stream.FlushHeat();
            Check(!s.HasBurnHeat(),"legacy status migrates without invented watts");
            Check(h.Stream.PaidSeconds==0 && h.Stream.NextHeatTic==0,"legacy residual radiation discarded idempotently");
            Check(Near(h.Stream.TotalPaidSeconds,h.TotalPaid),"legacy paid-resource history preserved");
            Check(Near(h.Victim.ThermalState.Exposure,h.Exposure) && Near(h.Victim.ThermalState.AbsorbedContinuousJoules,h.Continuous),"legacy applied heat history preserved");
        }
        else
        {
            Check(Near(s.BurnHeatWatts,h.Watts) && Near(s.BurnHeatRemaining,h.Remaining),"saved watts and remaining duration exact");
            Check(Near(s.PendingBurnHeatJoules,h.Pending),"saved queued energy retained exactly");
            s.EnsureBurnHeat();Check(Near(s.PendingBurnHeatJoules,h.Pending),"current migration never resets queued energy");
        }
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="c318_setup")Setup();
        else if(e.Name=="c318_contact")ContactChecks();
        else if(e.Name=="c318_status")StatusChecks();
        else if(e.Name=="c318_queue")QueueChecks();
        else if(e.Name=="c318_player")PlayerChecks();
        else if(e.Name=="c318_consume")ConsumeLoaded();
        else if(e.Name=="c318_seed")Seed();
        else if(e.Name=="c318_loaded")Loaded();
        else if(e.Name=="c318_upgrade")Loaded(true);
        else if(e.Name=="c318_done")Console.Printf("CA318 DONE failures=%d checks=%d",Failures,Checks);
    }
}
