class CA502IllLive : CaelumPortDefender
{
    bool Running;
    override void Tick(){if(Running)Super.Tick();}
}
class CA502IllnessChecks : CA502NPCChecks
{
    CA502IllLive LiveNPC;
    double SavedFraction,SavedDirt;
    int SavedHealth,BeginTic;
    override void WorldTick()
    {
        let u=CaelumPlayer(players[0].mo);if(u==null)return;
        u.CharacterCreationComplete=true;u.CreationWizardOpen=false;u.bInvulnerable=true;
        u.GetPersistentCharacterState(true).SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_UNKNOWN_VOICE_HEARD);
    }
    void Calibrate(double dirt,int toughness=0,int maximum=1000)
    {
        Soldier.CombatMaximumHealth=maximum;Soldier.health=maximum;
        Soldier.CombatToughness=toughness;Soldier.CombatResilience=0;
        Soldier.CombatAirSpending=false;Soldier.RecoveryPhase=0;Soldier.target=null;Soldier.Vel=(0,0,0);
        Soldier.ForcedSleepTics=0;Soldier.IdleHealthAccumulator=0;
        Soldier.SetStateLabel("Spawn");Soldier.target=null;
        CaelumContaminationStorage.Set(Soldier,dirt);
        let entry=CaelumContaminationStorage.Get(Soldier);entry.EnsurePhysiology();entry.DiseaseFraction=0;
    }
    void DamageTicks(int count)
    {for(int i=0;i<count;i++)CaelumContaminationNPC.IllnessStep(Soldier);}
    void Illness()
    {
        Calibrate(50);DamageTicks(TICRATE);Check(Soldier.health==1000,"threshold50 causes no illness damage");
        Calibrate(60);DamageTicks(TICRATE);Check(Soldier.health==990,"60 causes1percent maximum per active second");
        Calibrate(89);DamageTicks(TICRATE);Check(Soldier.health==961,"below90 keeps ordinary illness rate");
        Calibrate(90);DamageTicks(TICRATE);Check(Soldier.health==920,"90 doubles progressive illness damage");
        Calibrate(100);DamageTicks(TICRATE);Check(Soldier.health==900,"100 causes10percent maximum per second");
        Calibrate(100,100);DamageTicks(TICRATE);Check(Soldier.health==1000,"Toughness100 is immune");
        Calibrate(100,150);Soldier.health=900;DamageTicks(TICRATE);Check(Soldier.health==900,"Toughness above100 never converts illness to healing");
        Calibrate(80,50);double expected=CaelumFoodRules.DamagePerSecond(80,1000,CaelumToughnessRules.Effective(Soldier));
        DamageTicks(TICRATE);Check(Soldier.health==1000-int(expected+0.0000001),"partial Toughness resistance uses existing status curve once");
        Calibrate(60,0,100);DamageTicks(17);let entry=CaelumContaminationStorage.Get(Soldier);
        Check(Soldier.health==100 && Near(entry.DiseaseFraction,17.0/TICRATE),"subHP damage is retained without early rounding");
        DamageTicks(18);Check(Soldier.health==99 && Near(entry.DiseaseFraction,0),"fractional illness completes exactly oneHP");
        Calibrate(60);double armor=Soldier.CombatArmor.Durability[1];DamageTicks(TICRATE);
        Check(Soldier.CombatArmor.Durability[1]==armor,"illness bypasses physical armor without wear");
        Check(Near(CaelumContaminationStorage.Value(Soldier),60),"illness damage alone does not consume contamination");
        Calibrate(100);Soldier.health=1;DamageTicks(TICRATE);
        Check(Soldier.health<=0,"native disease damage can kill");
        double residue=entry.DiseaseFraction;DamageTicks(TICRATE);
        Check(Near(entry.DiseaseFraction,residue),"dead actors do not accrue more illness");
    }
    void Recovery()
    {
        Calibrate(20);double rate=Soldier.CombatMaximumHealth/CaelumConstants.HEALTH_BASE_RECOVERY_REAL_SECONDS
            *Soldier.CalculateActorType4Percent(Soldier.CombatResilience)/100.0*CaelumRestRules.CHAIR_RESOURCE_FACTOR;
        for(int i=0;i<10*TICRATE;i++)Soldier.CalculateCombatResourceRecovery(false);
        int effort=int(rate*10+0.0000001);
        Console.Printf("CA502N RECOVERY rate=%.8f effort=%d idle=%d life=%d dirt=%.8f fraction=%.8f target=%d",rate,effort,Soldier.IsCombatIdle(),Soldier.health,CaelumContaminationStorage.Value(Soldier),Soldier.IdleHealthAccumulator,Soldier.target!=null);
        Check(Soldier.health==1000 && Near(CaelumContaminationStorage.Value(Soldier),20-effort/1000.0),"full Life uses existing potential natural recovery for depuration");
        Calibrate(20);Soldier.health=900;
        for(int i=0;i<10*TICRATE;i++)Soldier.CalculateCombatResourceRecovery(false);
        Check(Soldier.health==900+effort && Near(CaelumContaminationStorage.Value(Soldier),20-effort/1000.0),"same recovery effort heals and depurates without double counting");
        Calibrate(20);Soldier.CombatAirSpending=true;
        for(int i=0;i<TICRATE;i++)Soldier.CalculateCombatResourceRecovery(false);
        Check(Near(CaelumContaminationStorage.Value(Soldier),20),"busy actor has no idle natural health effort");
        Calibrate(20);Soldier.IdleHealthAccumulator=.99;
        let population=CaelumPopulationState.Get();bool dense=population.HighDensity;population.HighDensity=true;
        let maintenance=Soldier.GetActorMaintenance();maintenance.ResourceDue=level.maptime+1000;
        Soldier.CurrentCombatAnima=Soldier.MaximumCombatAnima;Soldier.CurrentCombatAir=Soldier.MaximumCombatAir;
        Soldier.CurrentCombatLucidity=CaelumConstants.MAXIMUM_LUCIDITY;Soldier.UpdateCombatResourceRecovery(false);population.HighDensity=dense;
        Check(CaelumContaminationStorage.Value(Soldier)<20,"full-resource optimization does not skip needed depuration");
        CaelumContaminationNPC.Recover(Soldier,1000);
        Check(Near(CaelumContaminationStorage.Value(Soldier),18.999),"100percent natural Life effort removes one degree");
        CaelumContaminationNPC.Recover(Soldier,100000);
        Check(CaelumContaminationStorage.Value(Soldier)==0,"depuration clamps at clean");
        Calibrate(20);CaelumContaminationStorage.Treatment(Soldier,.25);
        Check(Near(CaelumContaminationStorage.Value(Soldier),17.5),"medicine treatment retains its separate10percent-per-degree rule");
    }
    void Cache()
    {
        let body=CaelumCombatActor(Actor.Spawn('CA502NPCRat',Soldier.Pos+(0,128,0),NO_REPLACE));
        Check(CaelumContaminationStorage.Get(body)==null && body.ContaminationBodyReady,"clean actor caches absence without allocating inventory");
        CaelumContaminationStorage.Set(body,63);
        let entry=CaelumContaminationStorage.Get(body);
        let carrier=CaelumContaminationCarrier(body.FindInventory('CaelumContaminationCarrier'));
        Check(entry!=null && entry==carrier.State && entry==body.ContaminationBody,"later contact installs one canonical cached body entry");
        body.ContaminationBody=null;body.ContaminationBodyReady=false;
        Check(CaelumContaminationStorage.Get(body)==entry && Near(entry.Concentration,63),"transient cache rebuild preserves identity and dirt");
        entry.PhysiologyRevision=0;entry.DiseaseFraction=.75;entry.EnsurePhysiology();
        Check(entry.PhysiologyRevision==1 && entry.DiseaseFraction==0 && Near(entry.Concentration,63),"new physiology migration starts fraction fresh without clearing body");
        entry.DiseaseFraction=.5;entry.EnsurePhysiology();Check(entry.DiseaseFraction==.5,"repeated physiology migration preserves accrued fraction");
        body.Destroy();
    }
    void Seed(CaelumPlayer u)
    {
        Calibrate(60,0,100);DamageTicks(17);Soldier.ChangeTid(905038);
        SavedDirt=CaelumContaminationStorage.Value(Soldier);SavedHealth=Soldier.health;
        SavedFraction=CaelumContaminationStorage.Get(Soldier).DiseaseFraction;
        Check(Near(SavedFraction,17.0/TICRATE),"save captures a real partial disease tick sequence");
    }
    void Restore(bool legacy=false)
    {
        Soldier=CA502NPCSoldier(ActorIterator.Create(905038).Next());
        Check(Soldier!=null,"native saved or hub body identity restored");if(Soldier==null)return;
        let entry=CaelumContaminationStorage.Get(Soldier);
        Check(Near(entry.Concentration,60) && Soldier.health==100,"saved contamination and Life preserved before tick");
        if(legacy)
        {
            Check(entry.PhysiologyRevision==0,"original runtime save has no new physiology schema");
            entry.EnsurePhysiology();Check(entry.PhysiologyRevision==1 && entry.DiseaseFraction==0 && entry.Concentration==60,"actual prior save starts physiology now without retroactive damage");
            entry.DiseaseFraction=.25;entry.EnsurePhysiology();Check(entry.DiseaseFraction==.25,"actual migrated save is idempotent");
        }
        else
        {
            Check(Near(entry.DiseaseFraction,17.0/TICRATE),"saved fractional disease damage persists");
            DamageTicks(18);Check(Soldier.health==99 && Near(entry.DiseaseFraction,0),"restored fraction contributes once to next native damage");
        }
        let carrier=CaelumContaminationCarrier(Soldier.FindInventory('CaelumContaminationCarrier'));
        Check(carrier.State==Soldier.ContaminationBody && carrier.Owner==Soldier,"cache points at original owned canonical carrier after restoration");
    }
    void StartLive(CaelumPlayer u)
    {
        LiveNPC=CA502IllLive(Actor.Spawn('CA502IllLive',u.Pos+(192,0,0),NO_REPLACE));
        LiveNPC.CaelumDiagnosticPassiveAI=true;LiveNPC.Running=true;
    }
    void MarkLive(CaelumPlayer u,bool accelerated)
    {
        LiveNPC.health=LiveNPC.CombatMaximumHealth=1000;LiveNPC.CombatToughness=0;
        CaelumContaminationStorage.Set(LiveNPC,60);let entry=CaelumContaminationStorage.Get(LiveNPC);entry.EnsurePhysiology();entry.DiseaseFraction=0;
        SavedHealth=LiveNPC.health;BeginTic=level.maptime;
        if(accelerated)
        {
            let clock=CaelumWorldClock.Get(u);clock.CompletedDays++;
        }
    }
    void EndLive()
    {
        LiveNPC.Running=false;int elapsed=level.maptime-BeginTic;
        Check(elapsed>=TICRATE,"native active-time interval elapsed");
        Check(LiveNPC.health==SavedHealth-int(10.0*elapsed/TICRATE+0.0000001),"real production Tick damages once per active tic despite calendar advance");
        Check(Near(CaelumContaminationStorage.Value(LiveNPC),60),"live test kept its concentration fixed");
    }
    void Perf()
    {
        Array<CaelumCombatActor> bodies;
        for(int i=0;i<1000;i++)
        {
            let body=CaelumCombatActor(Actor.Spawn('CA502NPCRat',(-800+(i%40)*40,-800+(i/40)*40,0),NO_REPLACE));
            body.CombatProfileInitialized=true;body.CombatMaximumHealth=body.health=1000;body.CombatToughness=0;CaelumContaminationStorage.Set(body,60);bodies.Push(body);
        }
        Array<double> samples;double elapsed=0;
        for(int t=0;t<TICRATE;t++)
        {
            double begin=MSTimeF();
            for(int i=0;i<bodies.Size();i++)CaelumContaminationNPC.IllnessStep(bodies[i]);
            double cost=MSTimeF()-begin;elapsed+=cost;samples.Push(cost);
        }
        for(int i=1;i<samples.Size();i++)for(int j=i;j>0 && samples[j]<samples[j-1];j--)
        {double swap=samples[j];samples[j]=samples[j-1];samples[j-1]=swap;}
        bool ok=true;
        for(int i=0;i<bodies.Size();i++){if(bodies[i].health!=990)ok=false;bodies[i].Destroy();}
        Check(ok,"1000 individual bodies retain independent illness damage");
        Console.Printf("CA502N TIMING thousand_bodies_35_ticks_ms=%.6f",elapsed);
        Console.Printf("CA502N TIMING thousand_body_callback_mean_ms=%.6f p95_ms=%.6f max_ms=%.6f",elapsed/TICRATE,samples[33],samples[34]);
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=='ca502i_core'){Prepare(u);Illness();}
        else if(e.Name=='ca502i_recovery'){Prepare(u);Recovery();Cache();}
        else if(e.Name=='ca502i_seed'){Prepare(u);Seed(u);}
        else if(e.Name=='ca502i_load')Restore();
        else if(e.Name=='ca502i_legacy')Restore(true);
        else if(e.Name=='ca502i_start')StartLive(u);
        else if(e.Name=='ca502i_mark')MarkLive(u,false);
        else if(e.Name=='ca502i_jump')MarkLive(u,true);
        else if(e.Name=='ca502i_end')EndLive();
        else if(e.Name=='ca502i_perf')Perf();
        else {Super.NetworkProcess(e);return;}
        Console.Printf("CA502N RESULT passed=%d failures=%d",Passed,Failed);
    }
}
