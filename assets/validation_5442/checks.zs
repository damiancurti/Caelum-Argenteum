    int CheckPasses,CheckFailures;
    void Check(bool condition,String label)
    {
        if(condition)CheckPasses++;
        else{CheckFailures++;Console.Printf("CA282 FAIL %s",label);}
    }
    void CheckStats(CaelumCombatActor npc)
    {
        npc.UpdateCombatHealthEffects();npc.UpdateActorOffensiveStatistics();
        double speed=npc.Speed,performance=npc.CombatHealthPerformanceMultiplier,pain=npc.CombatHealthPainMultiplier;
        double evasion=npc.EffectiveCombatEvasionChance,accuracy=npc.CombatPhysicalAccuracyPercent;
        npc.CA318ReferenceHealth();npc.CA318RawUpdateActorOffensiveStatistics();
        Check(speed==npc.Speed && performance==npc.CombatHealthPerformanceMultiplier && pain==npc.CombatHealthPainMultiplier && evasion==npc.EffectiveCombatEvasionChance && accuracy==npc.CombatPhysicalAccuracyPercent,"derived equality");
    }
    void WeightCheck(CaelumCombatActor npc,String label)
    {Check(npc.GetAttackCarriedWeight()==npc.CA318RawGetAttackCarriedWeight(),label);}
    CaelumThermalState ThermalSample(int index)
    {
        // Input grid reused from validation_514/checks.zs, without its old solver.
        let s=new("CaelumThermalState");s.Initialize();s.CanBreathe=false;s.CanShiver=false;s.Sweats=index%7!=0;s.Bare=!s.Sweats;s.Available=true;
        s.BodyMassKg=40+40*(index%5);s.HeightMeters=1.2+0.2*(index%5);
        s.SurfaceArea=CaelumThermalRules.Area(s.BodyMassKg,s.HeightMeters);s.Inertia=CaelumThermalRules.Inertia(s.BodyMassKg);
        s.ComfortC=index%3==0?17:index%3==1?22:32;s.ClimateC=s.ComfortC+index%11-5;
        s.AirC=-10+index%61;s.WindMps=(index%6)*1.3;s.Humidity=(index%6)*20;
        s.RainMmHour=index%4;s.Roof=index%2==0;s.Exposure=-35+index%71;s.Toughness=index%101;
        s.Hydration=index%5==0?5:100;s.ActivityWatts=index%4*223.333333333;
        s.Coverage[0]=0.125;s.Coverage[1]=0.375;s.Coverage[2]=0.25;s.Coverage[3]=0.25;
        for(int i=0;i<4;i++){s.Material[i]=index%7==0?-1:(index+i)%5;s.WorkWaterKg[i]=(index%4)*0.02;s.SubmergedCoverage[i]=index%3==0?s.Coverage[i]*0.5:0;s.SubmergedTemperatureC[i]=index%30;}
        return s;
    }
    double ThermalInterval(CaelumThermalState s,int tics,int index,bool fire)
    {
        double dr=double(tics)/TICRATE,dw=tics*CaelumThermalRuntime.WorldTicSeconds(),dose=0;
        int steps=Max(1,int(Ceil(dw/60.0)));
        for(int i=0;i<steps;i++)dose+=CaelumThermalService.Integrate(s,dw/steps,dr/steps,(index%4)*223.333333333,0,fire?800:0,0,index%2==0?116.4:0);
        return dose;
    }
    void ThermalChecks()
    {
        for(int n=0;n<24;n++)
        {
            let a=ThermalSample(n);let b=a.CopyForForecast();int la=0,lb=0;double da=0,db=0,maxGap=0;bool fire=false;
            int firstA=-1,firstB=-1;
            for(int tic=1;tic<=700;tic++)
            {
                bool event=n>=12 && (tic==175 || tic==350 || tic==525);
                if(tic%35==0 || event){da+=ThermalInterval(a,tic-la,n,fire);la=tic;if(firstA<0 && a.Severity>0)firstA=tic;}
                if(tic%100==0 || event){db+=ThermalInterval(b,tic-lb,n,fire);lb=tic;if(firstB<0 && b.Severity>0)firstB=tic;}
                maxGap=Max(maxGap,Abs(a.Exposure-b.Exposure));
                // Flush the old environment before applying a local change to both copies.
                if(event){fire=!fire;a.Roof=!a.Roof;b.Roof=a.Roof;a.WindMps+=0.3;b.WindMps=a.WindMps;for(int k=0;k<4;k++){a.SubmergedCoverage[k]=fire?a.Coverage[k]:0;b.SubmergedCoverage[k]=a.SubmergedCoverage[k];}}
            }
            double water=0;for(int i=0;i<4;i++)water=Max(water,Abs(a.WorkWaterKg[i]-b.WorkWaterKg[i]));
            Console.Printf("STAGGER THERMAL_COMPARE case=%d exposure35=%.12f exposure100=%.12f maxGap=%.12f waterError=%.12f hydrationError=%.12f dose35=%.12f dose100=%.12f activityError=%.12f first35=%d first100=%d",n,a.Exposure,b.Exposure,maxGap,water,Abs(a.Hydration-b.Hydration),da,db,Abs(a.ActivityJoules-b.ActivityJoules),firstA,firstB);
            Check(la==700 && lb==700,"thermal equal elapsed intervals");
        }
    }
    void Checks()
    {
        Mode=7;
        let npc=CheckBody;let other=CheckOther;
        Check(npc!=null && other!=null,"test bodies");if(npc==null || other==null)return;
        Add(npc);Add(other);npc.CA318Work.Audit=true;other.CA318Work.Audit=true;
        npc.bDormant=true;other.bDormant=true;CaelumDemonService.Initialize(npc);CaelumDemonService.Initialize(other);
        Check(npc.CombatMaximumHealth>0 && npc.MaximumCombatAnima>0,"initialized profiles");
        for(int i=0;i<120;i++){CheckStats(npc);WeightCheck(npc,"stable weight");}
        npc.health=Max(1,npc.CombatMaximumHealth/2);CheckStats(npc);
        npc.CurrentCombatAdrenaline=npc.MaximumCombatAdrenaline;CheckStats(npc);
        npc.CurrentCombatAdrenaline=0;CheckStats(npc);
        npc.CombatPatience++;npc.CombatAgility++;npc.Mass++;CheckStats(npc);
        npc.CombatDexterity++;npc.CombatInsight++;npc.CombatStrength++;npc.CombatIntelligence++;CheckStats(npc);
        if(npc.CombatArmor!=null)
        {
            npc.CombatArmor.Durability[2]=0;CheckStats(npc);
            npc.CombatArmor.Durability[2]=npc.CombatArmor.GetMaximumDurability(2);CheckStats(npc);
            npc.CombatArmor.Tier[2]=3;CheckStats(npc);WeightCheck(npc,"armor tier");
            npc.CombatArmor.Size[2]=CaelumConstants.EQUIPMENT_SIZE_L;WeightCheck(npc,"armor size");
        }
        if(npc.CombatPersonality!=null){npc.CombatPersonality.Personality[0]=(npc.CombatPersonality.Personality[0]+1)%3;CheckStats(npc);}
        if(npc.ElementalStatus==null)npc.ElementalStatus=new("CaelumElementalStatus");
        npc.ElementalStatus.FreezeRemaining=1;npc.ElementalStatus.FreezePowerPercent=50;CheckStats(npc);
        npc.ElementalStatus.FreezeRemaining=0;CheckStats(npc);
        let thermal=CaelumThermalBody.Get(npc,true);
        if(thermal!=null){thermal.Exposure=-CaelumThermalData.ExposureThreshold(1);CheckStats(npc);thermal.Exposure=0;CheckStats(npc);}
        // Repeated external Speed multiplication must never accumulate through cache hits.
        npc.UpdateCombatHealthEffects();double normalSpeed=npc.Speed;
        for(int i=0;i<100;i++){npc.Speed*=CaelumConstants.RELOAD_MOVEMENT_AND_PROGRESS_MULTIPLIER;npc.UpdateCombatHealthEffects();Check(npc.Speed==normalSpeed,"speed reset after reload multiplier");}
        let potion=CaelumDemonService.Potion(npc,0);
        Check(potion!=null,"finite inventory");
        if(potion!=null)
        {
            WeightCheck(npc,"initial potion weight");int before=potion.Amount;
            npc.UseInventory(potion);Check(potion.Amount==before-1,"consume unit");WeightCheck(npc,"post-use weight");
            let split=potion.CreateTossable(1);WeightCheck(npc,"split weight");if(split!=null){split.AttachToOwner(other);WeightCheck(other,"transfer weight");}
            let extra=Inventory(Actor.Spawn(potion.GetClassName(),npc.Pos,NO_REPLACE));extra.Amount=2;potion.HandlePickup(extra);WeightCheck(npc,"stack pickup weight");extra.Destroy();
            potion.Amount=1;CA318Work.InventoryChanged(npc);WeightCheck(npc,"explicit mutation notification");
            npc.UseInventory(potion);WeightCheck(npc,"last unit removal");
        }
        // The conservative resource path must reproduce active original steps exactly.
        for(int i=0;i<150;i++)
        {
            npc.health=npc.CombatMaximumHealth;npc.CurrentCombatAnima=npc.MaximumCombatAnima;
            npc.CurrentCombatAir=npc.MaximumCombatAir;npc.CurrentCombatLucidity=CaelumConstants.MAXIMUM_LUCIDITY;
            if(i%3==0)npc.CurrentCombatAnima*=0.5;if(i%5==0)npc.CurrentCombatAir*=0.5;
            if(i%7==0)npc.CurrentCombatLucidity*=0.5;if(i%11==0)npc.health=Max(1,npc.health/2);
            double anima=npc.CurrentCombatAnima,air=npc.CurrentCombatAir,lucidity=npc.CurrentCombatLucidity,idle=npc.IdleHealthAccumulator;int hp=npc.health;
            npc.CA318Resources(false);double a=npc.CurrentCombatAnima,b=npc.CurrentCombatAir,c=npc.CurrentCombatLucidity,d=npc.IdleHealthAccumulator;int h=npc.health;
            npc.CurrentCombatAnima=anima;npc.CurrentCombatAir=air;npc.CurrentCombatLucidity=lucidity;npc.IdleHealthAccumulator=idle;npc.health=hp;
            npc.CA318RawResources(false);
            Check(a==npc.CurrentCombatAnima && b==npc.CurrentCombatAir && c==npc.CurrentCombatLucidity && d==npc.IdleHealthAccumulator && h==npc.health,"resource step equality");
        }
        // Constant maximum adrenaline versus the original formula at the same maximum.
        npc.CA318Work.Mode=103;npc.CurrentCombatAdrenaline=npc.MaximumCombatAdrenaline;
        for(int i=1;i<=100;i++){npc.health=Max(1,npc.CombatMaximumHealth*i/100);CheckStats(npc);Check(npc.CombatHealthPerformanceMultiplier==1 && npc.CombatHealthPainMultiplier==1,"maximum adrenaline wounds");}
        Check(npc.CA318Work.Failures==0 && other.CA318Work.Failures==0,"all cached reads equal originals");
        let user=CaelumPlayer(players[0].mo);user.CA318SiegeFocus=true;
        user.CurrentHunger=0;user.CurrentThirst=0;user.CurrentSleep=CaelumConstants.SURVIVAL_MAXIMUM;
        user.UpdateSurvivalStates();user.UpdateHealthStateEffects();
        Check(user.SurvivalPerformanceMultiplier==1 && user.HealthPerformanceMultiplier==1,"player hunger/thirst and wounds ignore penalties");
        Check(user.HungerState==CaelumConstants.SURVIVAL_STATE_CRITICAL && user.ThirstState==CaelumConstants.SURVIVAL_STATE_CRITICAL,"critical states retained for damage");
        user.AdrenalineResourceInitialized=true;user.CombatTimeRemaining=1;CaelumPlayerResources.UpdateAdrenalineDecay(user);
        Check(user.CombatTimeRemaining<1 && user.CurrentAdrenaline==user.DerivedStats.MaximumAdrenaline,"combat timer advances with maximum adrenaline");
        int beforeHP=user.health;user.SurvivalDamageAccumulator=1;CaelumPlayerResources.ApplyCriticalSurvivalDamage(user);
        Check(user.health<beforeHP,"starvation dehydration damage retained");
        user.CA318SiegeFocus=false;
        let port=CaelumPortSiege.Get();let leader=new("CaelumSiegeCombatant");leader.Body=npc;leader.CommandLeader=leader;leader.CommandGroup=0;leader.SharedTarget=other;leader.SharedTargetValid=true;leader.NextSharedTargetTic=level.time+100;
        port.HighDensity=true;port.CA318Mode=8;
        Check(port.AttackerTarget(leader)==other,"shared target reuse");other.health=0;
        Check(port.AttackerTarget(leader)==null,"dead target rejected before deadline");
        other.CA318TargetUsers.Push(leader);CA318Work.Changed(other,true);Check(!leader.SharedTargetValid,"local target death notification");
        for(int i=0;i<100;i++){npc.CA318Work.Phase=i;int due=npc.CA318Work.NextDue();Check(due>level.time && due<=level.time+100 && due%100==i,"actual deadline bound and phase");}
        ThermalChecks();
        Console.Printf("STAGGER CHECKS passes=%d failures=%d",CheckPasses,CheckFailures);
        if(CheckFailures==0)Console.Printf("CA282 DONE passes=%d failures=0",CheckPasses);
    }
