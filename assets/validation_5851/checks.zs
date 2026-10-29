class CA415RoundEncounter : CaelumPortSiege {override void Tick(){}}
class CA415RoundSoldier : CaelumPortDefender {override void Tick(){}}
class CA415RoundDemon : CaelumMandinga {override void Tick(){}}
class CA415RoundBoss : CaelumPortCommander {override void Tick(){}}
class CA415RoundCannon : CaelumCannon {override void Tick(){}}
class CA415RoundRam : CaelumBatteringRam {override void Tick(){}}
class CA415RoundGate : CaelumBreakableGate {override void Tick(){}}
class CA415RoundShot : CaelumCannonProjectile {override void Tick(){}}
class CA415RoundChecks : EventHandler
{
    int Passed,Failed;
    CA415RoundSoldier soldier;CA415RoundDemon target;CA415RoundBoss boss;
    Array<CA415RoundDemon> MachineCrew;
    CA415RoundShot PreparedShot;
    CaelumMandinga Admitted;
    int AdmittedLife;
    void Check(bool yes,String label)
    {if(yes)Passed++;else Failed++;Console.Printf("CA415R %s %s",yes?"PASS":"FAIL",label);}
    bool Near(double a,double b,double tolerance=0.000001){return Abs(a-b)<tolerance;}
    override void WorldTick()
    {
        let user=CaelumPlayer(players[0].mo);if(user==null)return;
        user.CharacterCreationComplete=true;user.CreationWizardOpen=false;user.bInvulnerable=true;
    }
    void Prepare(CaelumPlayer user)
    {
        soldier=CA415RoundSoldier(Actor.Spawn('CA415RoundSoldier',(128,48,0),NO_REPLACE));
        target=CA415RoundDemon(Actor.Spawn('CA415RoundDemon',(128,208,0),NO_REPLACE));
        boss=CA415RoundBoss(Actor.Spawn('CA415RoundBoss',(512,208,0),NO_REPLACE));
    }
    void Math(CaelumPlayer user)
    {
        soldier.Carbine=new('CaelumCityCarbine');soldier.Carbine.Initialize(soldier);
        soldier.target=target;target.target=soldier;
        let attack=new('CaelumAbsentAttack');
        Check(attack.Configure(soldier,true) && attack.Kind==CaelumAbsentAttack.CARBINE,"defender ranged profile uses actual carbine");
        Check(Near(attack.Cycle,Ceil(soldier.GetProfileWeaponDuration(CaelumConstants.WEAPON_TYPE_CARBINE))/TICRATE),"carbine cycle uses current native duration");
        Check(attack.Configure(soldier,false) && attack.Kind==CaelumAbsentAttack.MELEE,"defender close profile uses actual sword");
        Check(attack.Configure(target,true) && attack.Kind==CaelumAbsentAttack.MAGIC,"Mandinga ranged profile uses current magic");
        Check(attack.Configure(target,false) && attack.Fire>0,"Mandinga machete retains fire component");
        Check(attack.Configure(boss,true) && attack.Area==boss.GetTierOneStatuetteExplosionRadius(),"Zupay projectile retains current area");
        Check(attack.Configure(boss,false) && attack.Kind==CaelumAbsentAttack.SLAM,"Zupay melee retains slam");
        for(int mode=0;mode<2;mode++)for(int distance=64;distance<=2048;distance*=2)
        {
            let shape=new('CaelumAbsentAnatomy');vector3 origin=target.Pos+(-distance,0,32);
            shape.Build(target,origin,2,1,10,mode==1);double total=0;
            for(int r=0;r<target.AnatomyProfile.RegionCount;r++)total+=shape.Weights[r];
            double expected=CaelumMeanAim.BodyProbability(origin,target.Pos,target.Radius,target.Height,2,1,10,mode==1);
            Check(Near(total,expected),"anatomical cells partition full shared hit probability");
        }
        int before=target.health;
        target.CombatMaximumHealth=target.health=1000000;target.EffectiveCombatEvasionChance=0;
        target.CombatArmor=null;target.CombatToughness=0;
        target.ThermalState=null;
        for(int critical=0;critical<2;critical++)for(int region=0;region<4;region++)
        {
            double heights[]={0.9,0.35,0.6,0.2};double lateral=region==1?0.75:0;
            int index=target.AnatomyProfile.FindRegion(heights[region],lateral);
            let predicted=new('CaelumAbsentDamage');
            predicted.Region(soldier,target,300,0,target.AnatomyProfile.GetLocation(index),target.AnatomyProfile.GetVulnerability(index),
                critical==1,false,-1,CaelumConstants.WEAPON_TYPE_CARBINE,1,0,1,false);
            let shot=CaelumCarbineProjectile(Actor.Spawn('CaelumCarbineProjectile',target.Pos+(0,-target.Radius,heights[region]*target.Height),NO_REPLACE));
            shot.target=soldier;shot.StoreCaelumAttackResult(300,true,critical==1,false,0);
            shot.StoreCaelumWeaponWearIdentity(CaelumConstants.WEAPON_TYPE_CARBINE,1,CaelumConstants.EQUIPMENT_SIZE_M);
            shot.CaelumDefenseReceiver=target;
            target.RegisterAnatomyImpact(heights[region],lateral);target.RegisterPendingCriticalHit(critical==1);
            int old=target.health;
            target.DamageMobj(shot,soldier,300,'CaelumRangedTest',DMG_NO_ARMOR,0);
            Check(Near(predicted.Life,old-target.health),"mean branch equals deterministic native carbine damage");
            if(!Near(predicted.Life,old-target.health))Console.Printf("CA415R DETAIL branch=%d region=%d expected=%.9f actual=%d",critical,region,predicted.Life,old-target.health);
            shot.Destroy();target.health=1000000;
        }
        Check(Near(CaelumAbsentDamage.Wear(0),0),"zero absorption never wears armor");
        Check(Near(CaelumAbsentDamage.Wear(CaelumConstants.ARMOR_ABSORBED_DAMAGE_PER_GUARANTEED_DURABILITY),1),"full guaranteed durability quantum retained");
    }
    void Rounds(CaelumPlayer user)
    {
        soldier.Carbine=new('CaelumCityCarbine');soldier.Carbine.Initialize(soldier);
        soldier.bFriendly=true;target.bFriendly=false;boss.bFriendly=false;
        soldier.target=target;target.target=soldier;
        soldier.EffectiveCombatEvasionChance=target.EffectiveCombatEvasionChance=0;
        soldier.CombatToughness=target.CombatToughness=0;
        soldier.health=soldier.CombatMaximumHealth=1000000;target.health=target.CombatMaximumHealth=1000000;
        soldier.CombatArmor=null;target.CombatArmor=null;target.CombatIntelligence=100;
        soldier.CurrentCombatAir=soldier.MaximumCombatAir;target.CurrentCombatAir=target.MaximumCombatAir;
        target.CurrentCombatAnima=target.MaximumCombatAnima;
        let battle=new('CaelumAbsentBattle');battle.ActiveScale=1;
        let first=battle.Add(soldier);let second=battle.Add(target);let spare=battle.Add(boss);
        first.Opponent=second;second.Opponent=first;spare.Retreated=true;
        Check(first.Enemy(second) && !first.Enemy(spare),"only living opponents in the same encounter are valid");
        first.Opponent=null;first.Choose();Check(first.Opponent==second,"lost target replaced in stable roster order");
        first.Opponent=second;first.Choose();Check(first.Opponent==second,"valid target retained");
        int initial=soldier.Carbine.Magazine;
        battle.Round();
        Check(first.Shots>0 && second.Shots>0,"both sides execute actions from round-start life");
        Check(soldier.Carbine.Magazine==initial-first.Shots,"carbine consumes real magazine rounds");
        Check(target.CurrentCombatAnima<target.MaximumCombatAnima,"spell spends actual Anima");
        Check(battle.Rounds==1,"one explicit round accounted once");
        Console.Printf("CA415R DETAIL firstShots=%d secondShots=%d life=%d/%d",first.Shots,second.Shots,soldier.health,target.health);
        soldier.health=soldier.CombatMaximumHealth=1;target.health=target.CombatMaximumHealth=1;
        first.Remaining=second.Remaining=0;first.Preparing=second.Preparing=false;
        first.Recovering=second.Recovering=false;
        soldier.CurrentCombatAir=soldier.MaximumCombatAir;target.CurrentCombatAnima=target.MaximumCombatAnima;
        soldier.CombatLucidityPhysicalStunRemaining=target.CombatLucidityPhysicalStunRemaining=0;
        soldier.ForcedSleepTics=target.ForcedSleepTics=0;
        int shotA=first.Shots,shotB=second.Shots;
        battle.Round();
        Check(first.Shots>shotA && second.Shots>shotB,"lethal simultaneous round does not suppress the second actor");
        Check(soldier.health<=0 && target.health<=0,"simultaneous lethal results preserve both casualties");
        Console.Printf("CA415R DETAIL lethal=%d/%d pending=%.9f/%.9f",soldier.health,target.health,first.PendingLife,second.PendingLife);
        int total=first.Shots+second.Shots;
        battle.Round();Check(first.Shots+second.Shots==total,"dead participants cannot act again");
    }
    void Physiology(CaelumPlayer user)
    {
        target.CaelumDiagnosticPassiveAI=true;
        target.health=target.CombatMaximumHealth=1000000;
        target.CombatToughness=0;target.CombatArmor=null;
        let effects=target.ElementalStatus;
        effects.CutRemaining=2;effects.CutDamagePerSecond=7;effects.CutPower=1;
        effects.FreezeRemaining=0.25;effects.FreezePowerPercent=10;
        effects.LightningStunRemaining=0.5;
        effects.ApplyBurnHeat(0.5,1,100);
        int old=target.health;
        effects.Advance(target,0.5);Check(target.health==old,"cut does not pulse before one active second");
        effects.Advance(target,0.5);Check(target.health==old-7,"cut advances with existing one-second damage");
        Check(effects.FreezeRemaining==0 && effects.FreezePowerPercent==0 && effects.LightningStunRemaining==0,"control timers expire during absence");
        Check(Near(effects.PendingBurnHeatJoules,50) && effects.BurnHeatRemaining==0,"burn heat integrates its remaining duration once");
        let support=CaelumSupportStatus(target.GiveInventoryType('CaelumSupportStatus'));
        support.Apply(CaelumSupportImplementData.CENSER,user,0);
        target.health=500000;support.Advance(1);
        Check(target.health>500000 && !support.AnyActive,"support healing completes and expires on absent clock");
        let encounter=CA415RoundEncounter(Actor.Spawn('CA415RoundEncounter',(512,512,0),NO_REPLACE));
        encounter.RegisterAttacker(target);encounter.SiegeStarted=true;encounter.SetupRevision=1;
        target.CombatToughness=100;target.health=1000;target.IdleHealthAccumulator=0;
        CaelumContaminationAbsence.Capture(target,user);
        let absent=target.ContaminationAbsence;
        absent.Exposure=null;absent.RecoveryRate=10;absent.Immune=true;
        effects.CutRemaining=0;
        let battle=new('CaelumAbsentBattle');encounter.AbsentBattle=battle;battle.Capture(encounter,user);
        double start=battle.Stamp;battle.SyncTo(start+3);
        Check(target.health==1030 && Near(absent.Stamp,start+3),"unopposed survivor processes all elapsed recovery without stopping after first second");
        target.CombatToughness=0;target.health=1;absent.Life=1;absent.Immune=false;absent.RecoveryRate=0;
        CaelumContaminationStorage.Get(target,true).Concentration=100;
        battle.SyncTo(start+4);
        Check(target.health<=0 && target.bCorpse && target.SiegeCombatant.ConfirmedDead,"absent disease confirms native death and encounter casualty once");
        int deathState=target.SiegeCombatant.ConfirmedDead;
        battle.SyncTo(start+5);Check(target.SiegeCombatant.ConfirmedDead && deathState==1,"later synchronization retains terminal casualty");
    }
    void MachinePrepare(CaelumPlayer user)
    {
        Prepare(user);
        for(int i=0;i<6;i++)MachineCrew.Push(CA415RoundDemon(Actor.Spawn('CA415RoundDemon',(1024+i*64,128,0),NO_REPLACE)));
        PreparedShot=CA415RoundShot(Actor.Spawn('CA415RoundShot',(768,768,0),NO_REPLACE));
    }
    void MachineChecks(CaelumPlayer user)
    {
        soldier.bFriendly=boss.bFriendly=true;target.bFriendly=false;
        target.health=target.CombatMaximumHealth=10000000;target.CombatArmor=null;target.CombatToughness=0;target.Vel=(0,0,0);
        let encounter=CA415RoundEncounter(Actor.Spawn('CA415RoundEncounter',(512,512,0),NO_REPLACE));
        let battle=new('CaelumAbsentBattle');battle.Encounter=encounter;battle.ActiveScale=1;
        battle.Add(soldier);battle.Add(target);battle.Add(boss);
        let cannon=CA415RoundCannon(Actor.Spawn('CA415RoundCannon',(128,48,0),NO_REPLACE));
        cannon.InitializeCannon(true);cannon.Armed=true;cannon.UnlimitedAmmunition=false;cannon.Ammunition=2;
        cannon.Operators.Push(soldier);cannon.Operators.Push(boss);cannon.IntendedTarget=target;
        battle.AddMachine(cannon);let gun=cannon.AbsentMachine;
        vector3 velocity=(0,CaelumCannonData.SPEED,0);
        gun.CannonContact(cannon,target,1,velocity);
        double predicted=target.AbsentCombatant.PendingLife;
        let shot=PreparedShot;
        shot.SetOrigin(target.Pos+(0,-target.Radius,target.Height/2-CaelumCannonData.RADIUS),false);
        shot.Defending=true;shot.FlightVelocity=velocity;
        target.SiegeCombatant=encounter.RegisterAttacker(target);
        int before=target.health;shot.ResolveContact(target);
        Check(predicted>0 && predicted==before-target.health,"summary cannon impact equals native energy and anatomical damage");
        Console.Printf("CA415R CANNON predicted=%.9f native=%d",predicted,before-target.health);
        shot.Destroy();target.Vel=(0,0,0);target.AbsentCombatant.ClearPending();
        cannon.Phase=CaelumCannon.LOADING;cannon.Work=CaelumCannonData.CYCLE*CaelumCannonData.CREW-1;
        gun.Advance(1.0/TICRATE);
        Check(cannon.Shots==1 && cannon.Ammunition==1,"partial load completes once and spends finite shell");
        int shots=cannon.Shots;
        gun.Advance(double(CaelumCannonData.CYCLE)/TICRATE);
        Check(cannon.Shots==shots+1 && cannon.Ammunition==0,"native cannon loading cadence retains full crew work");
        gun.Advance(2.0*CaelumCannonData.CYCLE/TICRATE);
        Check(cannon.Shots==shots+1,"empty finite cannon cannot fire extra shells");
        cannon.UnlimitedAmmunition=true;gun.Advance(1.0/TICRATE);
        Check(cannon.Shots==shots+2 && cannon.Ammunition==0,"approved unlimited reserve does not invent physical shells");
        cannon.Operators.Clear();int work=cannon.Work;gun.Advance(10);
        Check(cannon.Work==work,"missing cannon operators stop loading");
        let gate=CA415RoundGate(Actor.Spawn('CA415RoundGate',(1024,512,0),NO_REPLACE));gate.Angle=0;gate.InitializeGate();gate.health=100000000;
        let ram=CA415RoundRam(Actor.Spawn('CA415RoundRam',(1024,256,0),NO_REPLACE));ram.InitializeRam();
        ram.Encounter=encounter;ram.TargetGate=gate;ram.FinalAngle=90;ram.Armed=ram.Enabled=true;
        for(int i=0;i<MachineCrew.Size();i++)
        {let entry=encounter.RegisterAttacker(MachineCrew[i]);ram.AssignCrew(entry);battle.Add(MachineCrew[i]);}
        battle.AddMachine(ram);ram.AbsentMachine.RamRemaining=0;
        ram.AbsentMachine.Advance(0.1);
        Check(ram.StrikeSerial==1 && gate.health==100000000 && battle.StructureHits.Size()==1,"ram queues structural impact before simultaneous commit");
        for(int i=0;i<battle.StructureHits.Size();i++)battle.StructureHits[i].Commit();
        int gateLife=gate.health;
        Check(gateLife<100000000 && ram.ImpactCount==1,"ram applies existing structural energy with its actual moving mass");
        battle.StructureHits[0].Commit();Check(gate.health==gateLife,"structural serial prevents duplicate impact damage");
        MachineCrew[0].health=0;int serial=ram.StrikeSerial;ram.AbsentMachine.Advance(100);
        Check(ram.StrikeSerial==serial,"ram requires all living assigned crew");
    }
    void ReserveChecks(CaelumPlayer user)
    {
        let port=CA415RoundEncounter(Actor.Spawn('CA415RoundEncounter',(512,512,0),NO_REPLACE));
        port.Exits.Resize(6);port.Gates.Resize(6);port.SiegeStarted=true;
        port.Reinforcements=new('CaelumSiegeReinforcements');let reserve=port.Reinforcements;
        reserve.Enabled=true;reserve.Revision=CaelumReinforcementData.REVISION;
        reserve.Remaining=100;reserve.Pending=1;
        for(int i=1;i<CaelumReinforcementData.GROUP_SIZE;i++)reserve.Placed[i]=true;
        reserve.QueueCrew(null,(192,128,0),(0,0,0),0);
        let battle=new('CaelumAbsentBattle');port.AbsentBattle=battle;battle.Encounter=port;battle.Observer=user;
        battle.SourceMap=level.MapName;battle.ActiveScale=1;battle.SimulationTime=CaelumContaminationAbsence.Clock(user,level.MapName);
        battle.Busy=true;battle.ReinforcementDelay=0;battle.Reinforce(0);
        Check(reserve.Successful==1 && reserve.Remaining==99 && reserve.Pending==0,"partial reinforcement group uses actual placement and finite reserve");
        Check(port.Attackers.Size()==1 && battle.Rows.Size()==1,"admitted body registered once in encounter and summary");
        if(port.Attackers.Size()==0)return;
        Admitted=CaelumMandinga(port.Attackers[0].Body);Admitted.target=null;
        Check(Admitted.CombatProfileInitialized && Admitted.MandingaBirthInitialized && Admitted.ElementalStatus!=null,"new reserve has complete native combat profile before absent round");
        Check(CaelumDemonService.Potion(Admitted,0)!=null,"new reserve owns actual native supplies");
        AdmittedLife=Admitted.health-5;Admitted.health=AdmittedLife;
        Admitted.ContaminationAbsence.Life=AdmittedLife;
        int opportunities=reserve.Opportunities;battle.Reinforce(1);
        Check(reserve.Opportunities==opportunities,"next reinforcement opportunity retains existing interval");
        port.Victory=true;battle.Reinforce(10);
        Check(reserve.Stopped && reserve.Remaining==99,"victory stops untouched finite reserves");
        battle.Busy=false;Admitted.bDormant=true;Admitted.CaelumDiagnosticPassiveAI=true;
    }
    void ReserveAfter()
    {
        Check(Admitted!=null && Admitted.health==AdmittedLife,"deferred engine PostBeginPlay cannot reset admitted participant Life");
        Check(Admitted!=null && CaelumDemonService.Potion(Admitted,0).Amount==CaelumPotionRules.INITIAL_DEMON_UNITS,"deferred birth cannot duplicate native inventory supplies");
    }
    void PotionChecks(CaelumPlayer user)
    {
        target.CombatMaximumHealth=100000;target.health=10000;
        target.CombatToughness=0;target.CombatArmor=null;
        let item=CaelumDemonService.Potion(target,0);int stock=item.Amount;
        CaelumDemonService.UpdatePotions(target);
        let power=CaelumRegenerationPower(target.FindInventory('CaelumLifeRegeneration'));
        Check(power!=null && item.Amount==stock-1,"absent auto-use spends one actual healing item");
        if(power==null)return;
        int old=target.health;double ratio=power.PotionTotalRatio;
        power.AdvanceAbsent(TICRATE);
        Check(target.health==old+int(100000*ratio/CaelumConstants.CONSUMABLE_REGENERATION_SECONDS),"healing power delivers existing first pulse");
        CaelumDemonService.UpdatePotions(target);
        Check(item.Amount==stock-1,"active healing family does not spend another item");
        power.AdvanceAbsent(9*TICRATE);
        Check(target.health==old+int(100000*ratio) && target.FindInventory('CaelumLifeRegeneration')==null,"full native healing dose completes exactly once and expires");
        target.health=target.CombatMaximumHealth=10000000;
        target.EffectiveCombatEvasionChance=0;target.ThermalState=null;
        for(int critical=0;critical<2;critical++)
        {
            let expected=new('CaelumAbsentDamage');
            expected.Region(soldier,target,300,0,CaelumConstants.HIT_LOCATION_TORSO,CaelumConstants.VULNERABILITY_SENSITIVE_POINT,
                false,true,CaelumConstants.ESSENCE_FIRE,CaelumConstants.WEAPON_TYPE_STAFF,1,0,1,false);
            let shot=CaelumActorSimpleElementalProjectile(Actor.Spawn('CaelumActorSimpleElementalProjectile',target.Pos,NO_REPLACE));
            shot.target=soldier;shot.StoreCaelumAttackResult(300,true,critical==1,true,0);
            shot.StoreCaelumElementalPayload(CaelumConstants.ESSENCE_FIRE,false,100,100);
            old=target.health;target.DamageMobj(shot,soldier,300,'CaelumMagicTest',DMG_NO_ARMOR,0);
            Check(expected.Life==old-target.health,"summary preserves native unlocalized elemental direct damage");
            Console.Printf("CA415R MAGIC critical=%d mean=%.3f native=%d",critical,expected.Life,old-target.health);
            shot.Destroy();
        }
    }
    void Persistence(CaelumPlayer user)
    {
        soldier.Carbine=new('CaelumCityCarbine');soldier.Carbine.Initialize(soldier);
        soldier.bFriendly=true;target.bFriendly=false;
        soldier.target=target;target.target=soldier;
        soldier.health=soldier.CombatMaximumHealth=1000000;target.health=target.CombatMaximumHealth=1000000;
        soldier.CombatArmor=null;target.CombatArmor=null;target.CombatIntelligence=100;
        let encounter=CA415RoundEncounter(Actor.Spawn('CA415RoundEncounter',(512,512,0),NO_REPLACE));
        encounter.SiegeStarted=true;encounter.SetupRevision=1;
        encounter.Defenders.Push(soldier);encounter.RegisterAttacker(target);
        let battle=new('CaelumAbsentBattle');encounter.AbsentBattle=battle;battle.Capture(encounter,user);
        double start=battle.Stamp;
        battle.SyncTo(start+0.4);Check(battle.Rounds==0,"fractional world second does not duplicate a round");
        battle.SyncTo(start+1);Check(battle.Rounds==1,"fractional intervals combine into one world round");
        int rounds=battle.Rounds,shots=soldier.Carbine.ShotCount,life=target.health;
        battle.SyncTo(start+1);Check(battle.Rounds==rounds && soldier.Carbine.ShotCount==shots && target.health==life,"repeated timestamp is idempotent");
        Check(battle.Rows.Size()==2 && soldier.AbsentCombatant.Battle==battle && target.AbsentCombatant.Battle==battle,"actual roster owns one persistent row per body");
        target.SetStateLabel('Missile');
        let row=target.AbsentCombatant;row.Capture();
        Check(row.Preparing && row.Attack.Kind==CaelumAbsentAttack.MAGIC,"capture retains native spell preparation");
        int ticks=target.tics;
        row.ResumeNative();
        Check(target.CurState==target.FindState('AbsentMagicPrepare') && target.tics==ticks,"restore does not restart or repeat spell preparation");
        encounter.ChangeTid(915051);soldier.ChangeTid(915052);target.ChangeTid(915053);
        Console.Printf("CA415R SAVE rounds=%d shots=%d life=%d",battle.Rounds,soldier.Carbine.ShotCount,target.health);
    }
    void Saved()
    {
        let encounter=CA415RoundEncounter(ActorIterator.Create(915051).Next());
        let savedSoldier=CA415RoundSoldier(ActorIterator.Create(915052).Next());
        let savedTarget=CA415RoundDemon(ActorIterator.Create(915053).Next());
        Check(encounter!=null && savedSoldier!=null && savedTarget!=null,"save retains actual encounter bodies");
        if(encounter==null || savedSoldier==null || savedTarget==null)return;
        let battle=encounter.AbsentBattle;
        Check(battle!=null && battle.Rows.Size()==2 && battle.Rounds==1,"save retains processed round and roster");
        Check(savedSoldier.AbsentCombatant.Battle==battle && savedTarget.AbsentCombatant.Battle==battle,"save restores shared encounter identity");
        double now=battle.Stamp;int shots=savedSoldier.Carbine.ShotCount,life=savedTarget.health;
        battle.SyncTo(now);Check(shots==savedSoldier.Carbine.ShotCount && life==savedTarget.health,"loaded synchronization does not replay prior shots");
    }
    void Hub(CaelumPlayer user)
    {
        let encounter=CA415RoundEncounter(ActorIterator.Create(915051).Next());
        let savedSoldier=CA415RoundSoldier(ActorIterator.Create(915052).Next());
        let savedTarget=CA415RoundDemon(ActorIterator.Create(915053).Next());
        Check(encounter!=null && savedSoldier!=null && savedTarget!=null,"hub keeps actual encounter and bodies");
        if(encounter==null || savedSoldier==null || savedTarget==null)return;
        let battle=encounter.AbsentBattle;
        Check(battle!=null && !battle.Away && battle.Rounds>=9,"production return hook resolves elapsed world rounds");
        Check(savedSoldier.AbsentCombatant.Battle==battle && savedTarget.AbsentCombatant.Battle==battle,"hub restores native body references to one encounter");
        Check(savedTarget.health<978007,"off-map attacks change actual returning Life");
        Check(savedSoldier.Carbine.ReloadCount>0,"off-map magazine reload uses existing unlimited reserve policy");
        int shots=savedSoldier.Carbine.ShotCount,life=savedTarget.health,rounds=battle.Rounds;
        CaelumAbsentBattles.Restore(user);
        Check(shots==savedSoldier.Carbine.ShotCount && life==savedTarget.health && rounds==battle.Rounds,"second production synchronization cannot repeat combat");
        Console.Printf("CA415R HUB rounds=%d shots=%d reloads=%d life=%d",battle.Rounds,shots,savedSoldier.Carbine.ReloadCount,life);
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let user=CaelumPlayer(players[e.Player].mo);if(user==null)return;
        if(e.Name=="ca415r_prepare"){Prepare(user);return;}
        if(e.Name=="ca415r_machineprepare"){MachinePrepare(user);return;}
        if(e.Name=="ca415r_machines"){MachineChecks(user);Console.Printf("CA415R RESULT passed=%d failed=%d",Passed,Failed);return;}
        if(e.Name=="ca415r_reserve"){ReserveChecks(user);Console.Printf("CA415R RESULT passed=%d failed=%d",Passed,Failed);return;}
        if(e.Name=="ca415r_reserveafter"){ReserveAfter();Console.Printf("CA415R RESULT passed=%d failed=%d",Passed,Failed);return;}
        if(e.Name=="ca415r_potions"){PotionChecks(user);Console.Printf("CA415R RESULT passed=%d failed=%d",Passed,Failed);return;}
        if(e.Name=="ca415r_away")
        {
            let encounter=CA415RoundEncounter(ActorIterator.Create(915051).Next());
            if(encounter!=null && encounter.AbsentBattle!=null)encounter.AbsentBattle.Away=false;
            level.ChangeLevel("CABS415B",0,CHANGELEVEL_NOINTERMISSION,-1);return;
        }
        if(e.Name=="ca415r_home")
        {
            let clock=CaelumWorldClock.Get(user);clock.LimboDayTics+=14;
            level.ChangeLevel("MAP01",0,CHANGELEVEL_NOINTERMISSION,-1);return;
        }
        if(e.Name=="ca415r_math")Math(user);else if(e.Name=="ca415r_rounds")Rounds(user);else if(e.Name=="ca415r_physiology")Physiology(user);else if(e.Name=="ca415r_persistence")Persistence(user);else if(e.Name=="ca415r_saved")Saved();else if(e.Name=="ca415r_hub")Hub(user);else return;
        Console.Printf("CA415R RESULT passed=%d failed=%d",Passed,Failed);
    }
}
