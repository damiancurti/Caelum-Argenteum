// Sonda privada; no se incluye en el paquete normal.
class CA353Probe : EventHandler
{
    int Age;
    CaelumCombatActor CheckBody,CheckOther;
    Array<CaelumCombatActor> Counters;
    override void WorldTick()
    {
        Age++;let user=CaelumPlayer(players[0].mo);if(user==null)return;
        if(Age==5){user.CharacterCreationComplete=true;user.CreationWizardOpen=false;user.ApplyCharacterProfile();user.bInvulnerable=true;}
        if(Age==35)
        {
            CheckBody=CaelumCombatActor(Actor.Spawn("CaelumMandinga",(256,0,0),NO_REPLACE));
            CheckOther=CaelumCombatActor(Actor.Spawn("CaelumMandinga",(-256,0,0),NO_REPLACE));
            CheckBody.bDormant=CheckOther.bDormant=true;
        }
        if(Age==45)Checks();
    }
    void TargetChecks(CaelumCombatActor npc,CaelumCombatActor other)
    {
        let port=CaelumPortSiege(Actor.Spawn("CaelumPortSiege",(10000,10000,0),NO_REPLACE));port.HighDensity=true;port.Groups=1;
        let leader=new("CaelumSiegeCombatant");leader.Body=npc;leader.CommandLeader=leader;
        leader.CommandGroup=0;leader.SharedTarget=other;leader.SharedTargetWasPresent=true;
        leader.SharedTargetValid=true;leader.NextSharedTargetTic=level.time+100;
        Check(port.AttackerTarget(leader)==other,"group reuses live target");
        Check(other.TargetSubscribers!=null && other.TargetSubscribers.Users.Size()==1,"owner-local subscription");
        for(int i=0;i<100;i++)port.AttackerTarget(leader);
        Check(other.TargetSubscribers.Users.Size()==1,"subscriber is not duplicated");
        other.bShootable=false;
        Check(port.AttackerTarget(leader)!=other,"unshootable target refreshed before deadline");
        Check(other.TargetSubscribers.Users.Size()==0,"old subscription removed on switch");
        other.bShootable=true;leader.SharedTarget=other;leader.SharedTargetWasPresent=true;
        leader.SharedTargetValid=true;CaelumTargetSubscriptions.Watch(leader);
        other.Destroy();Check(!leader.SharedTargetValid,"native destruction invalidates subscribed group");
        let user=players[0].mo;leader.SharedTarget=user;leader.SharedTargetWasPresent=true;
        leader.SharedTargetValid=true;CaelumTargetSubscriptions.Watch(leader);
        CaelumTargetSubscriptions.Invalidate(user);Check(!leader.SharedTargetValid,"player target local invalidation");
        port.TargetingRevision=2;port.Attackers.Push(leader);port.EnsureTargetingRevision();
        Check(port.TargetingRevision==3 && !leader.SharedTargetValid && leader.SharedTarget==null,"perception migration clears only derived target");
        Check(leader.Body==npc,"perception migration retains body identity");
        npc.SiegeCombatant=leader;leader.SharedTarget=user;leader.SharedTargetValid=true;
        leader.SharedTargetWasPresent=true;CaelumTargetSubscriptions.Watch(leader);
        Check(CaelumPlayer(user).TargetSubscribers.Users.Size()==1,"leader subscribed before retirement");
        CaelumTargetSubscriptions.Retire(npc);
        Check(CaelumPlayer(user).TargetSubscribers.Users.Size()==0,"retiring leader removes outgoing subscription");
        leader.SharedTarget=user;CaelumTargetSubscriptions.Watch(leader);leader.Withdrawing=true;
        port.ElectCommands();
        Check(CaelumPlayer(user).TargetSubscribers.Users.Size()==0,"withdrawing command unsubscribed during election");
        leader.Withdrawing=false;npc.SiegeCombatant=null;
        let victim=CaelumCombatActor(Actor.Spawn("CA353Counter",(14000,0,0),NO_REPLACE));
        leader.SharedTarget=victim;leader.SharedTargetValid=true;CaelumTargetSubscriptions.Watch(leader);
        victim.DamageMobj(null,null,1000000000,'None',DMG_FORCED);
        Check(victim.health<=0 && !leader.SharedTargetValid,"native death invalidates subscribers");
    }
    void DensityChecks(CaelumCombatActor npc)
    {
        let population=CaelumPopulationState.Get();population.Refresh();
        int existing=population.LivingCombatants;
        Check(existing>0 && existing<499,"small-scene population prerequisite");
        for(int i=existing;i<499;i++)
        {
            let body=CaelumCombatActor(Actor.Spawn("CA353Counter",(20000+(i%100)*16,20000+(i/100)*16,0),NO_REPLACE));
            Counters.Push(body);
        }
        population.Refresh();Check(population.LivingCombatants==499 && !population.HighDensity,"499 below threshold including offscreen actors");
        Check(npc.GetActorMaintenance()==null,"499 original path");
        let last=CaelumCombatActor(Actor.Spawn("CA353Counter",(22000,22000,0),NO_REPLACE));Counters.Push(last);
        population.Refresh();Check(population.LivingCombatants==500 && population.HighDensity,"exactly 500 enables automatically");
        Check(npc.GetActorMaintenance()!=null,"500 cached path");
        int phases[100];
        for(int i=0;i<Counters.Size();i++)phases[Counters[i].GetActorMaintenance().Phase]++;
        int smallest=Counters.Size(),largest=0;
        for(int i=0;i<100;i++){smallest=Min(smallest,phases[i]);largest=Max(largest,phases[i]);}
        Check(largest-smallest<=1,"actual actor allocation distributed across 100 phases");
        last.health=0;population.Refresh();Check(!population.HighDensity,"death lowers population threshold");
        last.health=1;population.Refresh();Check(population.HighDensity,"revival restores population threshold");
        last.bShootable=false;population.Refresh();Check(!population.HighDensity,"unshootable actors excluded");
        last.bShootable=true;population.Refresh();Check(population.HighDensity,"shootability restored");
        last.Destroy();population.Refresh();Check(!population.HighDensity,"destruction lowers population threshold");
        for(int i=0;i<Counters.Size();i++)if(Counters[i]!=null)Counters[i].Destroy();
        population.Refresh();
        Check(population.LivingCombatants==existing,"population restored after fixture");
    }
    int CheckPasses,CheckFailures;
    void Check(bool condition,String label)
    {
        if(condition)CheckPasses++;
        else{CheckFailures++;Console.Printf("CA282 FAIL %s",label);}
    }
    void CheckStats(CaelumCombatActor npc)
    {
        npc.UpdateCombatHealthEffects();npc.UpdateActorOffensiveStatistics();
        double value0=npc.CombatHealthState;
        double value1=npc.CombatHealthPerformanceMultiplier;
        double value2=npc.CombatHealthPainMultiplier;
        double value3=npc.CombatAdrenalineGainMultiplier;
        double value4=npc.EffectiveCombatEvasionChance;
        double value5=npc.Speed;
        double value6=npc.CombatEffectiveDexterity;
        double value7=npc.CombatEffectiveInsight;
        double value8=npc.CombatEffectiveIntelligence;
        double value9=npc.CombatPhysicalAccuracyPercent;
        double value10=npc.CombatMagicalAccuracyPercent;
        double value11=npc.CombatPhysicalCriticalChancePercent;
        double value12=npc.CombatMagicalCriticalChancePercent;
        double value13=npc.CombatPhysicalPushMultiplier;
        double value14=npc.CombatMagicalPushMultiplier;
        npc.CalculateCombatHealthEffects();npc.CalculateActorOffensiveStatistics();
        Check(value0==npc.CombatHealthState,"derived CombatHealthState");
        Check(value1==npc.CombatHealthPerformanceMultiplier,"derived CombatHealthPerformanceMultiplier");
        Check(value2==npc.CombatHealthPainMultiplier,"derived CombatHealthPainMultiplier");
        Check(value3==npc.CombatAdrenalineGainMultiplier,"derived CombatAdrenalineGainMultiplier");
        Check(value4==npc.EffectiveCombatEvasionChance,"derived EffectiveCombatEvasionChance");
        Check(value5==npc.Speed,"derived Speed");
        Check(value6==npc.CombatEffectiveDexterity,"derived CombatEffectiveDexterity");
        Check(value7==npc.CombatEffectiveInsight,"derived CombatEffectiveInsight");
        Check(value8==npc.CombatEffectiveIntelligence,"derived CombatEffectiveIntelligence");
        Check(value9==npc.CombatPhysicalAccuracyPercent,"derived CombatPhysicalAccuracyPercent");
        Check(value10==npc.CombatMagicalAccuracyPercent,"derived CombatMagicalAccuracyPercent");
        Check(value11==npc.CombatPhysicalCriticalChancePercent,"derived CombatPhysicalCriticalChancePercent");
        Check(value12==npc.CombatMagicalCriticalChancePercent,"derived CombatMagicalCriticalChancePercent");
        Check(value13==npc.CombatPhysicalPushMultiplier,"derived CombatPhysicalPushMultiplier");
        Check(value14==npc.CombatMagicalPushMultiplier,"derived CombatMagicalPushMultiplier");
    }
    void WeightCheck(CaelumCombatActor npc,String label)
    {Check(npc.GetAttackCarriedWeight()==npc.CalculateAttackCarriedWeight(),label);}
    void Checks()
    {
        let population=CaelumPopulationState.Get();population.HighDensity=true;
        let npc=CheckBody;let other=CheckOther;
        Check(npc!=null && other!=null,"test bodies");if(npc==null || other==null)return;
        npc.GetActorMaintenance();other.GetActorMaintenance();
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
            potion.Amount=1;CaelumActorMaintenance.InventoryChanged(npc);WeightCheck(npc,"explicit mutation notification");
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
            npc.UpdateCombatResourceRecovery(false);double a=npc.CurrentCombatAnima,b=npc.CurrentCombatAir,c=npc.CurrentCombatLucidity,d=npc.IdleHealthAccumulator;int h=npc.health;
            npc.CurrentCombatAnima=anima;npc.CurrentCombatAir=air;npc.CurrentCombatLucidity=lucidity;npc.IdleHealthAccumulator=idle;npc.health=hp;
            npc.CalculateCombatResourceRecovery(false);
            Check(a==npc.CurrentCombatAnima && b==npc.CurrentCombatAir && c==npc.CurrentCombatLucidity && d==npc.IdleHealthAccumulator && h==npc.health,"resource step equality");
        }
        for(int kind=CaelumConstants.ARMOR_TYPE_MAGIC;kind<=CaelumConstants.ARMOR_TYPE_HEAVY;kind++)
        {
            npc.CombatArmor.InitializeUniformLoadout(kind,3);
            CheckStats(npc);WeightCheck(npc,"effective armor type weight");
            for(int slot=0;slot<CaelumConstants.ARMOR_SLOT_COUNT;slot++)
            {
                int maximum=npc.CombatArmor.GetMaximumDurability(slot);
                double defense=npc.CombatArmor.GetDefense(slot);
                Check(maximum>0 && defense>0,"effective intact armor prerequisite");
                npc.CombatArmor.Durability[slot]=0;
                Check(npc.CombatArmor.GetDefense(slot)==0,"effective broken armor");
                CheckStats(npc);WeightCheck(npc,"broken armor weight");
                npc.CombatArmor.Durability[slot]=maximum;
                Check(npc.CombatArmor.GetDefense(slot)==defense,"effective repaired armor");
                CheckStats(npc);WeightCheck(npc,"repaired armor weight");
                npc.CombatArmor.Tier[slot]=1;CheckStats(npc);WeightCheck(npc,"effective armor tier one");
                npc.CombatArmor.Tier[slot]=3;CheckStats(npc);WeightCheck(npc,"effective armor tier three");
                npc.CombatArmor.Size[slot]=CaelumConstants.EQUIPMENT_SIZE_S;WeightCheck(npc,"effective armor small");
                npc.CombatArmor.Size[slot]=CaelumConstants.EQUIPMENT_SIZE_L;WeightCheck(npc,"effective armor large");
            }
        }

        for(int i=0;i<100;i++)
        {
            npc.Maintenance.Phase=i;int due=npc.Maintenance.NextDue();
            Check(due>level.maptime && due<=level.maptime+100 && due%100==i,"phase deadline bounds");
        }
        let oldCache=npc.Maintenance;double beforeAnima=npc.CurrentCombatAnima;int beforeHP=npc.health;
        npc.ResetMaintenanceForTravel();
        Check(npc.Maintenance==null && npc.MaintenancePopulation==null,"travel discards map cache");
        Check(npc.GetActorMaintenance()!=oldCache && npc.health==beforeHP && npc.CurrentCombatAnima==beforeAnima,"travel preserves actual resources");
        population.HighDensity=false;Check(npc.GetActorMaintenance()==null,"low density uses original paths");
        npc.health--;CheckStats(npc);population.HighDensity=true;CheckStats(npc);
        Check(npc.Maintenance.HealthReady,"cache rebuilt after threshold transition");
        TargetChecks(npc,other);
        DensityChecks(npc);
        Console.Printf("CA353 CHECKS passes=%d failures=%d",CheckPasses,CheckFailures);
        if(CheckFailures==0)Console.Printf("CA282 DONE passes=%d failures=0",CheckPasses);
    }
}

class CA353Counter : CaelumCombatActor
{
    Default { Health 1; +SHOOTABLE +NOBLOCKMAP +NOINTERACTION }
    States { Spawn: TNT1 A -1; Stop; }
}
