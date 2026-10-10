class CA154Checks : StaticEventHandler
{
    int Elapsed,Passed,Failed;
    void Check(String label,double actual,double expected,double tolerance=0.000001)
    {
        bool ok=Abs(actual-expected)<=tolerance;
        if(ok)Passed++;else Failed++;
        Console.Printf("CA154 %s %s actual=%.12f expected=%.12f",ok ? "PASS" : "FAIL",label,actual,expected);
    }
    override void WorldTick()
    {
        Elapsed++;
        if(Elapsed!=20)return;
        let stats=new("CaelumDerivedStats");
        let rat=CaelumGiantRat(Actor.Spawn("CaelumGiantRat",(500,0,0)));
        int levels[]={0,1,10,25,50,75,100,150,200};
        double bonuses[]={0,0.208,2.8,10,30,60,100,210,360};
        let attributes=new("CaelumAttributes");let profile=new("CaelumCharacterProfile");
        profile.InitializeDefaultTestProfile();
        for(int i=0;i<9;i++)
        {
            int n=levels[i];double b=bonuses[i];
            Check(String.Format("bonus N%d",n),CaelumGrowthRules.Bonus(n),b);
            Check(String.Format("old1_to_new3 N%d",n),stats.CalculateType1Percent(n),100+7*b);
            Check(String.Format("old2_to_new1 N%d",n),stats.CalculateType2Percent(n),b);
            Check(String.Format("old4_to_new2 N%d",n),stats.CalculateType4Percent(n),100+3*b);
            Check(String.Format("npc_new3 N%d",n),rat.CalculateActorType1Percent(n),100+7*b);
            Check(String.Format("npc_new1 N%d",n),rat.CalculateActorType2Percent(n),b);
            Check(String.Format("npc_new2 N%d",n),rat.CalculateActorType4Percent(n),100+3*b);
            Check(String.Format("toughness_points N%d",n),CaelumArmorRules.ToughnessReductionPercent(n),b);
            Check(String.Format("thermal_resistance N%d",n),CaelumThermalRules.DamageResistance(n),Min(1.0,b/100));
            Check(String.Format("complement N%d",n),CaelumGrowthRules.Remaining(n),Max(0.0,1-b/100));
            attributes.SetAllForDebug(n);stats.Recalculate(attributes,profile);
            double large=1+7*b/100,moderate=1+3*b/100;
            Check(String.Format("health body mass N%d",n),stats.MaximumHealth,1000*large*stats.BaseMass/100);
            Check(String.Format("anima capacity N%d",n),stats.MaximumAnima,1000*large);
            Check(String.Format("air capacity N%d",n),stats.MaximumAir,1000*moderate);
            Check(String.Format("adrenaline capacity N%d",n),stats.MaximumAdrenaline,1000*moderate);
            Check(String.Format("Box integer capacity N%d",n),stats.MagicBoxCapacity,2+int(2*large));
            Check(String.Format("carrying mass N%d",n),stats.CarryCapacity,stats.BaseMass*moderate);
            Check(String.Format("attack full cycle N%d",n),CaelumAttackRules.Duration(stats.AttackDurationMultiplier,0,0,100),14/moderate);
            Check(String.Format("attack load penalty N%d",n),CaelumAttackRules.Duration(stats.AttackDurationMultiplier,10,5,100),14/moderate/0.85);
            Check(String.Format("attack overloaded N%d",n),CaelumAttackRules.Duration(stats.AttackDurationMultiplier,95,5,100),-1);
            Check(String.Format("physical accuracy N%d",n),stats.PhysicalAccuracyPercent,100*large);
            Check(String.Format("magical accuracy N%d",n),stats.MagicalAccuracyPercent,100*large);
            Check(String.Format("critical capped N%d",n),stats.PhysicalCriticalChance,Min(100.0,CaelumConstants.BASE_CRITICAL_CHANCE_PERCENT+b));
            Check(String.Format("sleep divisor N%d",n),stats.SleepLossMultiplier,1/moderate);
            Check(String.Format("needs preserve mass N%d",n),stats.HungerThirstLossMultiplier,stats.BaseMass/100.0/moderate);
            Check(String.Format("spell cost divisor N%d",n),stats.StaffAnimaCost,CaelumConstants.DEBUG_STAFF_ANIMA_COST/moderate);
            Check(String.Format("health penalty complement N%d",n),stats.HealthPenaltyMultiplier,Max(0.0,1-b/100));
            Check(String.Format("pain and lucidity complement N%d",n),stats.LucidityLossMultiplier,Max(0.0,1-b/100));
            Check(String.Format("dialogue probability bonus N%d",n),stats.DialogueSkillPercent,b);
            Check(String.Format("toughness subtracts HP points N%d",n),CaelumArmorRules.AfterToughnessDamage(500,1000,n),Max(0.0,500-10*b));
            Check(String.Format("thermal threshold additive N%d",n),CaelumThermalRules.ThresholdScale(n),1+b/100);
        }
        Check("efficiency 0",CaelumPhysicsUnits.MuscularEfficiency(0,0),0.25);
        Check("efficiency average before curve",CaelumPhysicsUnits.MuscularEfficiency(0,100),0.325);
        Check("efficiency 100",CaelumPhysicsUnits.MuscularEfficiency(100,100),0.5);
        Check("efficiency cap 200",CaelumPhysicsUnits.MuscularEfficiency(200,200),0.99);
        Check("heat same 300J work 0",CaelumThermalRules.PositiveWorkHeat(300,0.25),900);
        Check("heat same 300J work 100",CaelumThermalRules.PositiveWorkHeat(300,0.5),300);
        Check("negative work not cooling",CaelumThermalRules.PositiveWorkHeat(-300,0.5),0);
        Check("jump 80kg A0 J",CaelumPhysicsUnits.JumpWork(80,0),800);
        Check("jump 80kg A100 J",CaelumPhysicsUnits.JumpWork(80,100),6400);
        Check("jump load retains energy",0.5*160*(CaelumPhysicsUnits.VelocitySI(CaelumPhysicsUnits.JumpVelocity(80,160,0)))**2,800);
        Check("gravity ordinary",CaelumPhysicsUnits.AccelerationSI(rat.GetGravity()),9.81);
        CaelumPhysicsWorld.Initialize();
        Check("gravity idempotence",CaelumPhysicsUnits.AccelerationSI(rat.GetGravity()),9.81);
        Check("swimming heat reduced",CaelumThermalEffects.SwimmingWatts(2,false,0.5),145.5);
        Check("pushing retains isometric heat",CaelumThermalEffects.PushingWatts(2),582);
        Check("blocking retains isometric heat",CaelumThermalEffects.BlockingWatts(80,6),141.264);
        let user=CaelumPlayer(players[0].mo);
        for(int i=0;i<3;i++)
        {
            int n=i==0 ? 0 : i==1 ? 100 : 200;
            user.Attributes.SetAllForDebug(n);user.DerivedStats.Recalculate(user.Attributes,user.CharacterProfile);
            let thermal=CaelumThermalBody.Get(user,true);CaelumThermalBody.Refresh(user,thermal);
            double factor=i==0 ? 3 : i==1 ? 1 : 1.0/0.99-1;
            double before=thermal.ActionJoules;
            CaelumThermalEffects.RecordWeaponAction(user,CaelumConstants.WEAPON_TYPE_GREATSWORD,false,true,true);
            Check(String.Format("charged sweep heat once N%d",n),thermal.ActionJoules-before,300*2*3*factor);
            before=thermal.PendingFirearmJoules;
            CaelumThermalEffects.BeginFirearmReload(user);
            CaelumThermalEffects.RecordReloadProgress(user,0.25,1);
            CaelumThermalEffects.RecordReloadProgress(user,0.75,1);
            Check(String.Format("reload fixed work N%d",n),thermal.PendingFirearmJoules-before,thermal.SurfaceArea*CaelumThermalData.RELOAD_WORK_JOULES_PER_M2*factor);
        }
        Check("same 1m ascent work under Earth gravity",CaelumThermalRules.LocomotionWork(80,2,0.5,false,9.81),80*2*0.5025+80*9.81);
        Check("descent cannot cool",CaelumThermalRules.LocomotionWork(80,2,-1,false,9.81)>0,1);
        Check("floor threshold velocity scaling",ImpactPhysics.EnergyPercent(ImpactPhysics.EquivalentTics(56,2*Sqrt(CaelumPhysicsUnits.GRAVITY_RATIO))*Sqrt(CaelumPhysicsUnits.GRAVITY_RATIO)),ImpactPhysics.EnergyPercent(ImpactPhysics.EquivalentTics(56,2)));
        let weapon=new("CaelumWeaponModel");weapon.InitializeDefaults();
        int types[]={CaelumConstants.WEAPON_TYPE_BOOK,CaelumConstants.WEAPON_TYPE_STATUETTE,CaelumConstants.WEAPON_TYPE_LONGBOW,CaelumConstants.WEAPON_TYPE_CROSSBOW,CaelumConstants.WEAPON_TYPE_SWORD,CaelumConstants.WEAPON_TYPE_CARBINE,CaelumConstants.WEAPON_TYPE_SHOTGUN,CaelumConstants.WEAPON_TYPE_BELL};
        int spreads[]={10,20,20,50,60,70,70,70};
        for(int i=0;i<8;i++)
        {Check(String.Format("dispersion category weapon%d",types[i]),weapon.GetMaximumSpreadFor(types[i]),spreads[i]);Check(String.Format("dispersion minimum weapon%d",types[i]),weapon.GetMinimumSpreadFor(types[i]),spreads[i]/10.0);}
        user.DebugAttributesAt100=true;user.ApplyCharacterProfile();user.PersistCharacterState();
        let record=user.GetPersistentCharacterState(false);record.GrowthRevision=0;
        record.StoredHealth=int(51500*user.DerivedStats.BaseMassMultiplier*0.4);
        record.StoredAnima=51500*0.3;record.StoredAir=3000*0.2;record.StoredAdrenaline=3000*0.1;
        record.StoredUnderwaterAirRecoveryDebt=3000*0.04;
        user.RestorePersistentCharacterState();
        Check("traveler health percentage",double(user.health)/user.CaelumMaximumHealth,0.4,0.0002);
        Check("traveler anima percentage",user.CurrentAnima/user.DerivedStats.MaximumAnima,0.3);
        Check("traveler air percentage",user.CurrentAir/user.DerivedStats.MaximumAir,0.2);
        Check("traveler adrenaline percentage",user.CurrentAdrenaline/user.DerivedStats.MaximumAdrenaline,0.1);
        Check("traveler underwater debt percentage",user.UnderwaterAirRecoveryDebt/user.DerivedStats.MaximumAir,0.04);
        user.RestorePersistentCharacterState();
        Check("traveler migration once",user.CurrentAir/user.DerivedStats.MaximumAir,0.2);
        user.health=100;user.CurrentAnima=100;user.CurrentAir=100;user.CurrentAdrenaline=100;
        user.DebugAttributesAt100=false;user.ApplyCharacterProfile();user.DebugAttributesAt100=true;user.ApplyCharacterProfile();
        Check("ordinary maximum increase does not heal",user.health,100);
        Check("ordinary maximum increase does not refill",user.CurrentAir+user.CurrentAnima+user.CurrentAdrenaline,300);
        user.StaffCastPending=true;user.PendingStaffWeaponType=CaelumConstants.WEAPON_TYPE_BOOK;
        user.PendingStaffWeaponTier=2;user.PendingStaffChargedAttack=true;
        user.PendingStaffAnimaCost=70*1.6/3*2;
        user.StaffCastCooldownRemaining=1.25;user.PendingStaffCastTotalSeconds=2;
        user.AttributeBalanceVersion=3;user.ApplyCharacterProfile();
        Check("pending T2 charged book cost migrates",user.PendingStaffAnimaCost,70*1.6/4*2);
        Check("pending cast progress preserved",user.StaffCastCooldownRemaining,1.25);
        Check("pending cast total preserved",user.PendingStaffCastTotalSeconds,2);
        Check("pending cast remains pending",user.StaffCastPending,1);
        Check("pending cast migration does not spend anima",user.CurrentAnima,100);
        user.PendingStaffAnimaCost+=7;user.ApplyCharacterProfile();
        Check("pending cast is not rebalanced twice",user.PendingStaffAnimaCost,70*1.6/4*2+7);
        user.CancelPendingStaffCast(false);
        user.EffectiveMovementPercent=100;user.ElementalStatus=null;CaelumThermalBody.Get(user,true).Exposure=0;
        Check("fast travel unpenalized walk km/h",CaelumJourneyRules.WalkingKmh(user),14.4);
        user.EffectiveMovementPercent=400;
        Check("fast travel A100 walk km/h",CaelumJourneyRules.WalkingKmh(user),57.6);
        user.EffectiveMovementPercent=200;
        Check("fast travel half load performance",CaelumJourneyRules.WalkingKmh(user),28.8);
        Console.Printf("CA154 CHECKS COMPLETE pass=%d fail=%d",Passed,Failed);
    }
}
