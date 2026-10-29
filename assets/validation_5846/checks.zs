class CA502AbsentPose : Actor {States {Spawn:TNT1 A -1;Stop;}}
class CA502AbsentChecks : CA502NPCChecks
{
    double ProductionStamp;
    Array<CA502NPCSoldier> CaptureBodies;
    void SetUp(double dirt,int toughness=0,int maximum=1000)
    {
        Soldier.CombatMaximumHealth=Soldier.health=maximum;Soldier.CombatToughness=toughness;
        Soldier.CombatResilience=0;Soldier.CombatAirSpending=false;Soldier.RecoveryPhase=0;
        Soldier.target=null;Soldier.Vel=(0,0,0);Soldier.ForcedSleepTics=0;
        Soldier.IdleHealthAccumulator=0;Soldier.SetState(GetDefaultByType("CA502AbsentPose").SpawnState);Soldier.target=null;Soldier.Vel=(0,0,0);
        Soldier.CurrentCombatAdrenaline=Soldier.MaximumCombatAdrenaline;
        CaelumContaminationStorage.Set(Soldier,dirt);
        let entry=CaelumContaminationStorage.Get(Soldier);entry.EnsurePhysiology();entry.DiseaseFraction=0;
        Soldier.ContaminationAbsence=null;
    }
    CaelumContaminationAbsence Row(bool idle)
    {
        let row=new('CaelumContaminationAbsence');row.Revision=1;row.Away=true;
        row.Map="MAP03";row.Stamp=0;row.Civil=0;row.Life=Soldier.health;row.Idle=idle;
        row.RecoveryRate=CaelumContaminationNPC.HealthRate(Soldier);Soldier.ContaminationAbsence=row;return row;
    }
    void Compare(double dirt,int tough,int maximum,double seconds,bool idle)
    {
        SetUp(dirt,tough,maximum);let row=Row(idle);row.Physiology(Soldier,seconds);
        int life=row.Life;double c=CaelumContaminationStorage.Value(Soldier);
        double fraction=CaelumContaminationStorage.Get(Soldier).DiseaseFraction;
        double recovery=Soldier.IdleHealthAccumulator;
        SetUp(dirt,tough,maximum);Soldier.CombatAirSpending=!idle;
        Console.Printf("CA502N IDLE expected=%d actual=%d air=%d force=%d phase=%d velocity=%.9f maximum=%d needs=%d",idle,Soldier.IsCombatIdle(),Soldier.CombatAirSpending,Soldier.ForcedSleepTics,Soldier.RecoveryPhase,Soldier.Vel.Length(),Soldier.CombatMaximumHealth,CaelumContaminationNPC.NeedsRecovery(Soldier));
        for(int i=0;i<int(seconds*TICRATE);i++)
        {
            CaelumContaminationNPC.IllnessStep(Soldier);
            Soldier.CalculateCombatResourceRecovery(false);
        }
        Console.Printf("CA502N COMPARE c=%.3f tough=%d sec=%.3f hp=%d/%d c=%.9f/%.9f f=%.9f/%.9f r=%.9f/%.9f",dirt,tough,seconds,life,Soldier.health,c,CaelumContaminationStorage.Value(Soldier),fraction,CaelumContaminationStorage.Get(Soldier).DiseaseFraction,recovery,Soldier.IdleHealthAccumulator);
        Check(life==Max(0,Soldier.health),"absent Life equals active native disease/recovery");
        Check(Near(c,CaelumContaminationStorage.Value(Soldier)),"absent depuration equals active native effort");
        Check(Near(fraction,CaelumContaminationStorage.Get(Soldier).DiseaseFraction),"absent fractional damage equals active tics");
        Check(Near(recovery,Soldier.IdleHealthAccumulator),"absent fractional recovery equals active tics");
    }
    void PhysiologyChecks()
    {
        Compare(50,0,1000,60,true);Compare(60,0,1000,10,true);Compare(90,0,1000,5,false);
        Compare(100,100,1000,600,true);Compare(80,50,100,10,false);
        SetUp(60);let row=Row(false);row.SyncTo(Soldier,20);
        Check(row.Life==990,"twenty exterior world seconds equal one active second");
        Check(Soldier.health==1000,"deferred outcome does not damage body in destination map");
        SetUp(60);row=Row(false);row.Map="MAP01";row.SyncTo(Soldier,1);
        Check(row.Life==990,"Limbo physiology uses one-to-one seconds");
        SetUp(60,0,100);row=Row(false);row.Physiology(Soldier,17.0/TICRATE);
        row.Physiology(Soldier,18.0/TICRATE);
        Check(row.Life==99 && Near(CaelumContaminationStorage.Get(Soldier).DiseaseFraction,0),"split intervals retain sub-HP damage exactly once");
        SetUp(20);row=Row(true);row.Physiology(Soldier,3600);
        Check(row.Life==1000 && CaelumContaminationStorage.Value(Soldier)<20,"full-Life potential recovery depurates while absent");
        SetUp(100);row=Row(false);row.SyncTo(Soldier,1000);
        Check(row.Life==0 && !Soldier.bKilled,"lethal outcome waits for source-map native death");
        Check(!CaelumContaminationAbsence.Alive(Soldier,2000),"dead absent resident cannot clean household");
    }
    void NativeGuards()
    {
        SetUp(60);Soldier.bInvulnerable=true;let row=Row(false);row.NativePolicy(Soldier);row.Physiology(Soldier,17.0/TICRATE);
        Check(row.Life==1000 && Near(CaelumContaminationStorage.Get(Soldier).DiseaseFraction,6.0/7),"native immunity preserves raw fractional disease accounting");
        Soldier.bInvulnerable=false;SetUp(100);Soldier.bBuddha=true;row=Row(false);row.NativePolicy(Soldier);row.Physiology(Soldier,30);
        Check(row.Life==1,"Buddha story protection prevents absent death");Soldier.bBuddha=false;
        SetUp(90);Soldier.DamageFactor=.5;row=Row(false);row.NativePolicy(Soldier);row.Physiology(Soldier,1);
        int loss=1000-row.Life;SetUp(90);Soldier.DamageFactor=.5;
        for(int i=0;i<TICRATE;i++)CaelumContaminationNPC.IllnessStep(Soldier);
        Check(1000-Soldier.health==loss,"native typed damage factoring preserves per-pulse integer rounding");Soldier.DamageFactor=1;
        SetUp(60);Soldier.bShootable=false;row=Row(false);row.NativePolicy(Soldier);row.Physiology(Soldier,10);
        Check(row.Life==1000,"original non-shootable actors retain native immunity");Soldier.bShootable=true;
        SetUp(60);Soldier.bNoDamage=true;row=Row(false);row.NativePolicy(Soldier);row.Physiology(Soldier,10);
        Check(row.Life==1000,"native NODAMAGE actors retain immunity");Soldier.bNoDamage=false;
    }
    void Seed(CaelumPlayer u)
    {
        SetUp(60,0,100);Soldier.ChangeTid(905046);
        let row=Row(false);row.Map=level.MapName;row.Stamp=CaelumContaminationAbsence.Clock(u,row.Map);
        row.Physiology(Soldier,17.0/TICRATE);
        Check(row.Life==100,"save seed preserves partial illness");
    }
    void ExposureChecks()
    {
        SetUp(0,100);Clean();Soldier.CombatToughness=100;
        let row=Row(false);row.Exposure=new('CaelumContaminationNPC');row.Exposure.Capture(Soldier,Climate());
        row.Reference=15;row.Covered=true;row.Climate=new('CaelumFoodClimate');row.Climate.Ready=true;
        row.Climate.Seed=471;row.Climate.Profile=CaelumWeatherRules.PROFILE_LIMBO;row.Climate.Shelter=CaelumWeatherRules.LIMBO;
        row.SyncTo(Soldier,60);
        Check(CaelumContaminationStorage.Value(Soldier)>0,"absent environmental exposure reaches body through armor");
        Check(CaelumContaminationCombat.Exterior(Soldier,1).Value()>0,"absent armor keeps its own concentration");
        Check(CaelumContaminationCombat.WeaponPoint(Soldier.Sword).Value()>0,"absent sidearm receives exposure");
        Check(CaelumContaminationStorage.Value(Item)>0,"absent original native inventory receives exposure");
        Check(row.Life==1000,"Toughness immunity retained during absent exposure");
        Clean();Item.InMagicBox=true;row.Exposure.Capture(Soldier,Climate());row.SyncTo(Soldier,120);
        Check(CaelumContaminationStorage.Value(Item)==0,"absent boxed gear remains protected");
        SetUp(80,100);row=Row(false);row.Reference=-1;
        let t=Climate();for(int i=0;i<4;i++){t.SubmergedCoverage[i]=.25;t.CleanWaterCoverage[i]=.25;}
        row.Exposure=new('CaelumContaminationNPC');row.Exposure.Capture(Soldier,t);row.SyncTo(Soldier,60);
        Check(CaelumContaminationStorage.Value(Soldier)<80,"captured clean immersion washes during absence");
    }
    void ClockChecks(CaelumPlayer u)
    {
        let clock=CaelumWorldClock.Get(u,true);let calendar=CaelumCalendarState.Get(u,true);calendar.EnsureCampaign(clock);
        double outside=CaelumContaminationAbsence.Clock(u,"MAP03"),limbo=CaelumContaminationAbsence.Clock(u,"MAP01");
        for(int i=0;i<20*TICRATE;i++)clock.AdvanceOnMap("MAP01");
        Check(Near(CaelumContaminationAbsence.Clock(u,"MAP03"),outside),"time in Limbo freezes exterior absence physiology");
        Check(Near(CaelumContaminationAbsence.Clock(u,"MAP01")-limbo,20),"Limbo personal clock advances one-to-one");
        outside=CaelumContaminationAbsence.Clock(u,"MAP03");limbo=CaelumContaminationAbsence.Clock(u,"MAP01");
        clock.AdvanceTics(TICRATE);
        Check(Near(CaelumContaminationAbsence.Clock(u,"MAP03")-outside,20),"exterior travel advances source-world seconds");
        Check(Near(CaelumContaminationAbsence.Clock(u,"MAP01"),limbo),"exterior travel does not advance Limbo clock");
    }
    void Perf()
    {
        Array<double> samples;double total=0;bool alive=true;
        for(int i=0;i<600;i++)
        {
            SetUp(0,100);Clean();Soldier.CombatToughness=100;
            let row=Row(true);row.Exposure=new('CaelumContaminationNPC');row.Exposure.Capture(Soldier,Climate());
            row.Reference=15;row.Covered=true;row.Climate=new('CaelumFoodClimate');row.Climate.Ready=true;
            row.Climate.Seed=471;row.Climate.Profile=CaelumWeatherRules.PROFILE_LIMBO;row.Climate.Shelter=CaelumWeatherRules.LIMBO;
            double start=MSTimeF();row.SyncTo(Soldier,86400);double cost=MSTimeF()-start;
            samples.Push(cost);total+=cost;if(row.Life!=1000)alive=false;
        }
        for(int i=1;i<samples.Size();i++)for(int j=i;j>0 && samples[j]<samples[j-1];j--)
        {double swap=samples[j];samples[j]=samples[j-1];samples[j-1]=swap;}
        Check(alive,"600 independent one-day integrations preserve immune bodies");
        Console.Printf("CA502N TIMING 600_days_total_ms=%.6f mean_ms=%.6f p95_ms=%.6f max_ms=%.6f",total,total/600,samples[569],samples[599]);
    }
    void Resume(CaelumPlayer u)
    {
        Soldier=CA502NPCSoldier(ActorIterator.Create(905046).Next());
        Check(Soldier!=null && Soldier.ContaminationAbsence!=null,"native saved actor owns absence record");
        if(Soldier==null || Soldier.ContaminationAbsence==null)return;
        let row=Soldier.ContaminationAbsence;
        Check(row.Away && Near(CaelumContaminationStorage.Get(Soldier).DiseaseFraction,17.0/TICRATE),"saved fractional damage and pending outcome persist");
        row.Physiology(Soldier,18.0/TICRATE);row.Stamp=CaelumContaminationAbsence.Clock(u,row.Map);
        CaelumContaminationAbsence.Restore(Soldier,u);
        Check(Soldier.health==99 && !row.Away,"restoration applies outcome once");
        CaelumContaminationAbsence.Restore(Soldier,u);Check(Soldier.health==99,"repeated restore does not replay elapsed damage");
    }
    void ProductionSeed(CaelumPlayer u)
    {
        SetUp(60);Clean();CaelumContaminationStorage.Set(Soldier,60);
        Soldier.CombatToughness=0;Soldier.CombatAirSpending=true;Soldier.ChangeTid(905046);
        Soldier.ThermalState=Climate();Soldier.ThermalState.SourceMap=level.MapName;
        ProductionStamp=CaelumContaminationAbsence.Clock(u,level.MapName);
        Check(Soldier.ContaminationAbsence==null,"production seed has no manufactured absence record");
    }
    void ProductionReturn(CaelumPlayer u,bool resident=false)
    {
        if(resident){let roster=CaelumHouseResidents.Get();Soldier=roster!=null?CA502NPCSoldier(roster.Residents[0].Body):null;}
        else Soldier=CA502NPCSoldier(ActorIterator.Create(905046).Next());
        Check(Soldier!=null && Soldier.ContaminationAbsence!=null,"actual WorldUnloaded captured native hub body");
        if(Soldier==null || Soldier.ContaminationAbsence==null)return;
        let row=Soldier.ContaminationAbsence;double now=CaelumContaminationAbsence.Clock(u,row.Map);
        int expected=1000-int(Max(0,row.Stamp-ProductionStamp)/20*10+.0000001);
        Check(!row.Away && row.Map=="CUN502" && !row.Idle,"source-map identity and busy gate survive automatic loading restore");
        Check(row.Exposure==null,"hub loading resolves and releases exposure before first playable tic");
        CaelumContaminationAbsence.Restore(Soldier,u);
        Check(Abs(Soldier.health-expected)<=1 && expected<1000,"actual outside clock resolves absent Life loss within departure command tic");
        Check(Soldier.FindInventory('CaelumWeaponPickup')!=null,"original owned item survives exposure and hub return");
        row.Away=true;row.Life=1;row.Stamp=now;row.SyncTo(Soldier,now+2000);
        Check(row.Life==0 && !Soldier.bKilled,"absent lethal outcome defers native death");
        CaelumContaminationAbsence.Restore(Soldier,u);
        Check(Soldier.health==0 && Soldier.bKilled,"source-map restoration applies native death");
        bool loot=Soldier.NativeDeathLootReleased;
        CaelumContaminationAbsence.Restore(Soldier,u);
        Check(Soldier.bKilled && Soldier.NativeDeathLootReleased==loot,"repeated restoration preserves native once-only death guard");
    }
    void Upgrade(CaelumPlayer u)
    {
        Soldier=CA502NPCSoldier(ActorIterator.Create(905046).Next());
        Check(Soldier!=null,"original-runtime saved body loads");if(Soldier==null)return;
        Check(Soldier.ContaminationAbsence==null && Soldier.health==1000,"original save has no retroactive absent illness");
        Check(Near(CaelumContaminationStorage.Value(Soldier),67),"original body concentration retained");
        Check(Near(CaelumContaminationStorage.Get(Soldier).DiseaseFraction,17.0/TICRATE),"existing physiology fraction retained");
        CaelumContaminationAbsence.Capture(Soldier,u);let row=Soldier.ContaminationAbsence;
        Check(row!=null && row.Revision==CaelumContaminationData.NPC_ABSENCE_REVISION,"migration starts absence only at first captured departure");
        double stamp=row.Stamp;CaelumContaminationAbsence.Capture(Soldier,u);
        Check(row==Soldier.ContaminationAbsence && row.Stamp==stamp,"departure capture is idempotent");
        CaelumContaminationAbsence.Restore(Soldier,u);Check(Soldier.health==1000,"zero elapsed migration does not change health");
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=='ca502u_prepare'){Prepare(u);return;}
        if(e.Name=='ca502u_core')PhysiologyChecks();
        else if(e.Name=='ca502u_exposure')ExposureChecks();
        else if(e.Name=='ca502u_clock')ClockChecks(u);
        else if(e.Name=='ca502u_guards')NativeGuards();
        else if(e.Name=='ca502u_warm'){
            SetUp(0,100);Soldier.ThermalState=null;
            let world=CaelumThermalWorld.Get();let weather=CaelumWeatherState.Get(u,true);
            weather.Profile=CaelumWeatherRules.PROFILE_LIMBO;weather.Seed=471;
            weather.Outside=new('CaelumWeatherSample');weather.Outside.Evaluate(weather.Profile,0,0,471);
            world.ReferenceWeather=weather;world.ReferenceClock=CaelumWorldClock.Get(u,true);
            CaelumContaminationAbsence.Capture(Soldier,u);let row=Soldier.ContaminationAbsence;
            Check(row!=null && row.Exposure!=null,"first departure captures NPC before first scheduled thermal sample");
            Check(row!=null && row.Exposure!=null && row.Exposure.Frame.BodyKg==Soldier.Mass && row.Exposure.Frame.BodyArea[1]>0,"first exposure uses native mass and physical coverage");
        }
        else if(e.Name=='ca502u_perf')Perf();
        else if(e.Name=='ca502u_captureprepare'){
            for(int i=0;i<600;i++){
                let body=CA502NPCSoldier(Actor.Spawn('CA502NPCSoldier',(i%30*32-480,i/30*32-320,0),NO_REPLACE));
                body.bInvisible=true;body.bSolid=false;CaptureBodies.Push(body);
            }
            return;
        }
        else if(e.Name=='ca502u_captureperf'){
            bool ok=true;double total=0,peak=0;
            for(int round=0;round<3;round++){
                for(int i=0;i<CaptureBodies.Size();i++){CaptureBodies[i].ContaminationAbsence=null;CaptureBodies[i].ThermalState=Climate();}
                double start=MSTimeF();int count=0;
                let scan=ThinkerIterator.Create('CaelumCombatActor',Thinker.STAT_DEFAULT);CaelumCombatActor body;
                while((body=CaelumCombatActor(scan.Next()))!=null){CaelumContaminationAbsence.Capture(body,u);count++;}
                double cost=MSTimeF()-start;total+=cost;peak=Max(peak,cost);
                if(count<600)ok=false;
                for(int i=0;i<CaptureBodies.Size();i++)if(CaptureBodies[i].ContaminationAbsence==null || !CaptureBodies[i].ContaminationAbsence.Away)ok=false;
            }
            Check(ok,"departure census captures600 initialized native combatants including offscreen bodies");
            Console.Printf("CA502N TIMING departure600_3runs_mean_ms=%.6f max_ms=%.6f",total/3,peak);
        }
        else if(e.Name=='ca502u_productionseed')ProductionSeed(u);
        else if(e.Name=='ca502u_residentseed'){
            ProductionSeed(u);let roster=CaelumHouseResidents.Get(true);roster.EnsureRecords();
            let resident=roster.Residents[0];resident.Body=Soldier;resident.Created=true;
            resident.ResidentMap=level.MapName;resident.Position=Soldier.Pos;Soldier.Residence=resident;
            roster.Ready=true;Check(Soldier.Residence.Body==Soldier,"travelling resident owns original body");
        }
        else if(e.Name=='ca502u_residentreturn'){
            ProductionReturn(u,true);let roster=CaelumHouseResidents.Get();
            Check(roster!=null && roster.Residents[0].Body==Soldier && !roster.Residents[0].Suspended,"native resident returns without replacing body");
        }
        else if(e.Name=='ca502u_productionreturn')ProductionReturn(u);
        else if(e.Name=='ca502u_upgrade')Upgrade(u);
        else if(e.Name=='ca502u_traveltime'){CaelumWorldClock.Get(u,true).AdvanceTics(TICRATE);return;}
        else if(e.Name=='ca502u_lethaltime'){CaelumWorldClock.Get(u,true).AdvanceTics(200*TICRATE);return;}
        else if(e.Name=='ca502u_lethalreturn'){
            Soldier=CA502NPCSoldier(ActorIterator.Create(905046).Next());
            Check(Soldier!=null && Soldier.health<=0 && Soldier.bKilled,"native loading resolves lethal absence before playable ticks");
            Check(Soldier!=null && Soldier.ContaminationAbsence!=null && !Soldier.ContaminationAbsence.Away,"loaded death consumes its outcome once");
            if(Soldier!=null){CaelumContaminationAbsence.Restore(Soldier,u);Check(Soldier.bKilled,"loaded native death remains idempotent");}
        }
        else if(e.Name=='ca502u_seed')Seed(u);
        else if(e.Name=='ca502u_resume')Resume(u);
        else if(e.Name=='ca502u_away'){Level.ChangeLevel("CUN502B",0,CHANGELEVEL_NOINTERMISSION);return;}
        else if(e.Name=='ca502u_home'){Level.ChangeLevel("CUN502",0,CHANGELEVEL_NOINTERMISSION);return;}
        else return;
        Console.Printf("CA502N RESULT passed=%d failures=%d",Passed,Failed);
    }
}
