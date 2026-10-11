// Matriz aislada: receptores sin IA; todas las reglas probadas son producción.
class CA188Target : CaelumCombatActor
{
    override void Tick() {}
    Default {Radius 16;Height 56;Mass 80;Health 100000;+SHOOTABLE;+NOGRAVITY;}
    States {Spawn: TNT1 A -1; Stop;}
}

class CA188Native : StaticEventHandler
{
    int Age,Passed,Failures;
    CaelumPlayer User;
    CaelumCombatActor TargetBody;
    Actor Attacker;
    double LiveStart;

    void Check(String label,double actual,double expected,double tolerance=0.00001)
    {
        bool ok=Abs(actual-expected)<=tolerance;
        if(ok)Passed++;else Failures++;
        Console.Printf("CA188 %s %s actual=%.9f expected=%.9f",ok?"PASS":"FAIL",label,actual,expected);
    }
    void Truth(String label,bool ok){Check(label,ok?1:0,1);}
    override void UiTick(){if(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();}

    void PlayerState(double toughness=20)
    {
        User.bInvulnerable=false;User.CreationWizardOpen=false;User.CharacterCreationComplete=true;
        User.Attributes.Toughness=toughness;User.DerivedStats.BaseMass=80;
        User.CaelumMaximumHealth=100000;User.health=100000;User.player.health=100000;
        User.EffectiveEvasionChance=0;User.CombatBlockModeActive=false;User.DebugShieldBlocking=false;
        User.CharacterProfile.Race=CaelumConstants.RACE_HUMAN;
        User.ArmorModel=new("CaelumArmorModel");User.ArmorModel.InitializeDefaults();
        User.WeaponModel.Equipped=false;User.ShieldModel.Equipped=false;
    }
    void NPCState(double toughness=20)
    {
        TargetBody.Mass=80;TargetBody.CombatToughness=int(toughness);
        TargetBody.CombatMaximumHealth=100000;TargetBody.health=100000;
        TargetBody.EffectiveCombatEvasionChance=0;TargetBody.bInvulnerable=false;
        TargetBody.CombatArmor=new("CaelumArmorModel");TargetBody.CombatArmor.InitializeDefaults();
        TargetBody.PendingLocalizedImpact=false;TargetBody.PendingLocalizedCriticalHit=false;
    }
    void Formula()
    {
        Check("80kg N0",CaelumToughnessRules.Reduction(80,0),80);
        Check("80kg N20",CaelumToughnessRules.Reduction(80,20),120.32);
        Check("80kg N100",CaelumToughnessRules.Reduction(80,100),640);
        Check("bull physical",CaelumToughnessRules.Reduction(900,20),1353.6);
        Check("bull magical",CaelumToughnessRules.Reduction(900,20,true),676.8);
        Check("Zupay magical",CaelumToughnessRules.Reduction(666,33,true),689.92272);
        for(int i=0;i<3;i++)Check(String.Format("below equal above R %d",i),
            CaelumToughnessRules.AfterDefenses(119.32+i,80,20),i==2?1:0);
        PlayerState();NPCState();
        Check("shared player reduction",CaelumToughnessRules.Apply(User,1000),879.68);
        Check("shared NPC reduction",CaelumToughnessRules.Apply(TargetBody,1000),879.68);
        User.DerivedStats.TotalMass=80000;User.CaelumMaximumHealth=200000;
        TargetBody.CollisionEffectiveMassMultiplier=100;TargetBody.CombatMaximumHealth=200000;
        Check("load and HP do not change R",CaelumToughnessRules.Apply(User,1000),879.68);
        Check("NPC artificial mass and HP do not change R",CaelumToughnessRules.Apply(TargetBody,1000),879.68);
        let bull=CaelumBull(Actor.Spawn("CaelumBull",User.Pos+(1024,0,0)));
        bull.PostBeginPlay();
        Check("real bull natural mass",CaelumToughnessRules.NaturalMass(bull),900);
        Check("real bull effective toughness",CaelumToughnessRules.Effective(bull),20);
        bull.BeginBullCharge();Check("real charge does not increase R",CaelumToughnessRules.Apply(bull,2000),646.4);bull.Destroy();
    }
    void Directed()
    {
        PlayerState();NPCState();
        User.PrepareRealArmorDamage(1000,false,CaelumConstants.ARMOR_SLOT_BODY);
        Check("player body anatomy before armor",User.LastArmorPreDefenseDamage,1600);
        Check("player innate before toughness",User.LastArmorPostDefenseDamage,1480);
        Check("player physical final round",User.LastArmorHealthDamage,1360);
        TargetBody.ResolveActorArmorImpact(1000,false);
        Check("NPC innate before toughness",TargetBody.LastCombatArmorPostDefenseDamage,1480);
        Check("NPC precise remainder",TargetBody.LastCombatPostToughnessDamage,1359.68);
        User.PrepareRealArmorDamage(1000,false,CaelumConstants.ARMOR_SLOT_BODY,true);
        Check("magical final half reduction",User.LastArmorHealthDamage,1420);
        int before=User.health;User.DamageMobj(null,null,1000,'Fire',DMG_NO_ARMOR,0);
        Check("native direct Fire pipeline",before-User.health,1420);
        before=TargetBody.health;TargetBody.DamageMobj(null,Attacker,1000,'Fire',DMG_NO_ARMOR,0);
        Check("native NPC Fire parity",before-TargetBody.health,1420);
        for(int slot=0;slot<4;slot++)
        {
            User.PrepareRealArmorDamage(2000,false,slot);
            double expected=Max(0,2000*User.GetVulnerabilityMultiplier(User.GetEffectiveArmorVulnerability(slot),false)*0.925-120.32);
            Check(String.Format("anatomical slot %d",slot),User.LastArmorHealthDamage,int(expected+0.5));
        }
        PlayerState(150);User.ArmorModel.InitializeUniformLoadout(CaelumConstants.ARMOR_TYPE_HEAVY,3);
        User.DerivedStats.BaseMass=900;
        User.PrepareRealArmorDamage(5000,false,CaelumConstants.ARMOR_SLOT_BODY);
        Truth("armor absorbs before zero-health remainder",User.LastArmorAbsorbedDamage>1000 && User.LastArmorHealthDamage==0);
        Truth("zero health hit still calculates armor wear",User.LastArmorDurabilityLoss>=1);
        PlayerState();User.ArmorModel.InitializeUniformLoadout(CaelumConstants.ARMOR_TYPE_HEAVY,1);
        let shot=CaelumActorProjectile(Actor.Spawn("CaelumActorSimpleElementalProjectile",User.Pos+(128,0,32)));
        shot.Vel=(0,0,0);shot.CaelumWeaponWearPrepared=true;shot.CaelumWearWeaponType=CaelumConstants.WEAPON_TYPE_CARBINE;shot.CaelumWearWeaponTier=1;
        User.PrepareRealArmorDamage(1000,false,CaelumConstants.ARMOR_SLOT_BODY,false,shot);
        Check("bypass preserves innate and flat R",User.LastArmorHealthDamage,int(User.LastArmorPreDefenseDamage*(1-0.075-0.35*0.30)-120.32+0.5));
        shot.CaelumMagicalAttack=true;
        Truth("physical component ignores magical source flag",!CaelumArmorRules.IsMagical(shot,'Hitscan'));
        Truth("direct ice component is magical",CaelumArmorRules.IsMagical(shot,'Ice'));
        Truth("sustained component bypasses flat class",!CaelumArmorRules.IsMagical(shot,'CaelumElementalDOT'));
        shot.Destroy();
        PlayerState();NPCState();
        before=User.health;User.DamageMobj(null,null,100,'Crush',DMG_NO_ARMOR,0);
        Check("native ceiling converts percentage then subtracts once",before-User.health,int(100000-120.32+0.5));
        PlayerState();before=User.health;User.DamageMobj(Attacker,Attacker,200,'CaelumWeight',DMG_NO_ARMOR,0);
        Check("weight final physical mitigation",before-User.health,80);
        before=TargetBody.health;TargetBody.DamageMobj(Attacker,Attacker,200,'CaelumWeight',DMG_NO_ARMOR,0);
        Check("NPC weight parity",before-TargetBody.health,80);
        PlayerState(100);NPCState(100);
        before=User.health;User.DamageMobj(null,Attacker,11,'CaelumElementalDOT',DMG_NO_ARMOR,0);
        Check("player sustained path excludes flat R",before-User.health,11);
        before=TargetBody.health;TargetBody.DamageMobj(null,Attacker,11,'CaelumElementalDOT',DMG_NO_ARMOR,0);
        Check("NPC sustained path excludes armor and R",before-TargetBody.health,11);
        NPCState(100);TargetBody.bInvulnerable=true;before=TargetBody.health;
        TargetBody.DamageMobj(null,null,1000000,'Crush',DMG_NO_ARMOR,0);
        Truth("native forced crush retains invulnerability bypass",TargetBody==null || TargetBody.health<before);
        if(TargetBody==null)TargetBody=CaelumCombatActor(Actor.Spawn("CA188Target",User.Pos+(256,0,0)));
        NPCState();
        PlayerState(0);User.CaelumMaximumHealth=10010;User.health=User.player.health=10010;
        before=User.health;User.DamageMobj(null,null,1,'Crush',DMG_NO_ARMOR,0);
        Check("crush conversion keeps fraction until final HP",before-User.health,20);
    }
    void DefensePaths()
    {
        PlayerState();
        let shield=CaelumEquipmentItem(Actor.Spawn("CaelumShieldPickup",User.Pos));
        shield.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_SHIELD;
        shield.ItemType=CaelumConstants.SHIELD_TYPE_TOWER;shield.Tier=1;shield.EquipmentSize=CaelumConstants.EQUIPMENT_SIZE_M;
        shield.Equipped=true;shield.PickupDataInitialized=true;shield.AcquisitionResolved=true;
        shield.AttachToOwner(User);User.EnsureEquipmentItemId(shield);User.EquippedShieldItemId=shield.ItemId;
        User.ShieldModel.ShieldType=shield.ItemType;User.ShieldModel.Tier=1;
        User.ShieldModel.Equipped=true;User.ShieldModel.Durability=1000;
        User.DebugShieldBlocking=true;User.Angle=User.AngleTo(Attacker);
        Truth("native owned shield participates",User.HasActiveBlockSource());
        double remainder=User.ResolveRealShieldDamage(Attacker,Attacker,1003,'Hitscan');
        Check("partial shield preserves decimals",remainder,200.6);
        User.PrepareRealArmorDamage(remainder,false,CaelumConstants.ARMOR_SLOT_BODY);
        Check("partial block armor then one R",User.LastArmorHealthDamage,177);
        User.ShieldModel.Tier=shield.Tier=3;
        remainder=User.ResolveRealShieldDamage(Attacker,Attacker,5000,'Hitscan');
        Check("full shield zero remainder",remainder,0);
        User.PrepareRealArmorDamage(remainder,false,CaelumConstants.ARMOR_SLOT_BODY);
        Check("full shield never reaches health",User.LastArmorHealthDamage,0);
        User.CommitRealShieldDurability();Check("full shield still wears",User.ShieldModel.Durability,995);
        shield.Destroy();
        PlayerState(150);User.DerivedStats.BaseMass=900;
        User.ArmorModel.InitializeUniformLoadout(CaelumConstants.ARMOR_TYPE_HEAVY,3);
        int oldDurability=0;for(int i=0;i<4;i++)oldDurability+=User.ArmorModel.Durability[i];
        int initial=User.health;
        User.DamageMobj(null,Attacker,5000,'Hitscan',DMG_NO_ARMOR,0);
        Check("real zero remainder retains health",User.health,initial);
        int afterDurability=0;for(int i=0;i<4;i++)afterDurability+=User.ArmorModel.Durability[i];
        Truth("real zero remainder commits armor wear",afterDurability<oldDurability);
        PlayerState();NPCState();
        let blast=CaelumActorProjectile(Actor.Spawn("CaelumActorSimpleElementalProjectile",User.Pos+(0,0,User.Height/2)));
        blast.ConfigureCaelumActorExplosion(101,1024,10000);blast.Vel=(0,0,0);
        initial=User.health;User.ApplyExplosionDefense(blast,Attacker,101,'Hitscan',DMG_NO_ARMOR,0);
        Truth("blast touches several regions",User.LastExplosionTouchedRegionCount>1);
        Check("blast aggregate subtracts R once",initial-User.health,int(Max(0,User.LastArmorPostDefenseDamage-120.32)+0.5));
        blast.Destroy();
        for(int kind=0;kind<3;kind++)
        {
            PlayerState();NPCState();
            int impactKind=kind==0?CaelumConstants.IMPACT_KIND_FLOOR:kind==1?CaelumConstants.IMPACT_KIND_ACTOR:CaelumConstants.IMPACT_KIND_CRUSH;
            initial=User.health;
            User.ReceiveCaelumImpact(8,impactKind,Attacker,1,80,8000,8,100,0,1);
            double postArmor=User.LastImpactDamagePercent*100000/100*User.LastImpactWeightedVulnerabilityMultiplier*0.925;
            Check(String.Format("impact kind%d post armor then R",kind),initial-User.health,int(Max(0,postArmor-120.32)+0.5));
            initial=TargetBody.health;
            TargetBody.ReceiveCaelumImpact(8,impactKind,Attacker,1,80,8000,8,100,0,1);
            postArmor=TargetBody.LastImpactDamagePercent*100000/100*TargetBody.LastImpactWeightedVulnerabilityMultiplier*0.925;
            Check(String.Format("NPC impact kind%d post armor then R",kind),initial-TargetBody.health,int(Max(0,postArmor-120.32)+0.5));
        }
    }
    void StatusMatrix()
    {
        int levels[]={0,20,50,99,100,101,150};
        double responses[]={1,0.928,0.7,0.01792,0,-0.01808,-1.1};
        int effects[]={CaelumConstants.ELEMENTAL_EFFECT_BURN,CaelumConstants.ELEMENTAL_EFFECT_POISON,CaelumConstants.ELEMENTAL_EFFECT_DISEASE};
        for(int person=0;person<2;person++)for(int levelIndex=0;levelIndex<7;levelIndex++)for(int index=0;index<3;index++)
        {
            PlayerState(levels[levelIndex]);NPCState(levels[levelIndex]);
            Actor body=User;if(person!=0)body=TargetBody;body.health=50000;if(person==0)User.player.health=body.health;
            let status=new("CaelumElementalStatus");
            status.ApplyDamageOverTime(effects[index],10,1,100,Attacker,body);
            String label=String.Format("status recipient%d N%d kind%d",person,levels[levelIndex],index);
            Check(label.." duration",status.GetRemaining(index),10*Abs(responses[levelIndex]));
            Check(label.." no instant heal/damage",body.health,50000);
            for(int step=0;step<390;step++)status.TickDamageOverTime(body);
            Check(label.." integrated health",body.health,50000-int(1000*responses[levelIndex]),1);
            Check(label.." ends",status.GetRemaining(index),0);
        }
        PlayerState(20);User.health=User.player.health=50000;
        let status=new("CaelumElementalStatus");status.ApplyDamageOverTime(effects[0],10,2,100,Attacker,User);
        for(int i=0;i<35;i++)status.TickDamageOverTime(User);
        Check("unchanged rate during shortened burn",User.health,49900);
        double base=status.BaseRemaining[0];User.Attributes.Toughness=50;status.RefreshResistance(User);
        Check("attribute change rescales remaining dose",status.BurnRemaining,base*0.7);
        status.RefreshResistance(User);status.RefreshResistance(User);
        Check("refresh never compounds duration",status.BurnRemaining,base*0.7);
        User.Attributes.Toughness=150;status.RefreshResistance(User);
        Check("active effect becomes healing",status.BurnRemaining,base*1.1);
        for(int i=0;i<35;i++)status.TickDamageOverTime(User);
        Check("active healing retains original rate",User.health,50000);
        User.Attributes.Toughness=100;status.RefreshResistance(User);status.TickDamageOverTime(User);
        Check("active immunity ends damaging/healing dose",status.BurnRemaining,0);
        Check("immunity never has a damaging first tick",User.health,50000);
        Truth("immunity keeps independent visual flames",status.BurnVisualRemaining>0);
        PlayerState(150);User.health=User.player.health=99999;
        status=new("CaelumElementalStatus");status.ApplyDamageOverTime(effects[1],1,1,100,Attacker,User);
        for(int i=0;i<35;i++)status.TickDamageOverTime(User);
        Check("healing respects maximum health",User.health,100000);
        PlayerState(50);User.health=User.player.health=50000;
        status=new("CaelumElementalStatus");status.ApplyDamageOverTime(effects[2],1.1,2,100,Attacker,User);
        for(int i=0;i<35;i++)status.TickDamageOverTime(User);
        Check("subsecond disease retains 77 HP dose",User.health,49923);
        status.ApplyDamageOverTime(effects[1],10,2,100,Attacker,User);
        double before=status.PoisonRemaining;
        status.ApplyDamageOverTime(effects[1],100,1,1000,Attacker,User);
        Check("weaker source cannot replace stronger dose",status.PoisonRemaining,before);
        status.ApplyDamageOverTime(effects[1],20,2,100,Attacker,User);
        Check("equal power extends once",status.PoisonRemaining,14);
        status.ApplyDamageOverTime(effects[1],1,3,200,Attacker,User);
        Check("stronger source replaces",status.PoisonRemaining,0.7);
        status=new("CaelumElementalStatus");status.BurnTickAccumulator=0.5;status.BurnDamagePerSecond=100;
        status.PoisonTickAccumulator=0.5;status.PoisonDamagePerSecond=100;
        status.RefreshResistance(User);
        Check("expired legacy effects cannot bank damage",status.HealthFraction[0]+status.HealthFraction[1],0);
        PlayerState(50);User.health=User.player.health=50000;
        status=new("CaelumElementalStatus");
        for(int cycle=0;cycle<10;cycle++)
        {
            status.ApplyDamageOverTime(effects[0],1.1,1,1,Attacker,User);
            for(int tic=0;tic<35;tic++)status.TickDamageOverTime(User);
        }
        Check("fractional repeated subsecond doses accumulate",User.health,49993);
        PlayerState(0);status=new("CaelumElementalStatus");
        status.ApplyDamageOverTime(effects[0],10,1,100,Attacker,User);
        for(int tic=0;tic<34;tic++)status.TickDamageOverTime(User);
        Check("legacy one-second pain pulse preserved",User.health,100000);
        status.TickDamageOverTime(User);Check("whole second delivers original rate",User.health,99900);
    }
    void Gates()
    {
        for(int material=0;material<3;material++)
        {
            let gate=CaelumBreakableGate(Actor.Spawn("CaelumBreakableGate",User.Pos+(2048,material*256,0)));
            gate.args[1]=material;gate.BalanceRevision=-1;gate.Initialized=false;gate.InitializeGate();gate.Opened=false;gate.Broken=false;
            double reduction=material==0?935:material==1?2015:5720;
            double incoming=10000;int initial=gate.health;
            int expected=Min(initial,Max(0,int(incoming*(1-(material+1)*0.1)-reduction+0.5)));
            Check(String.Format("gate mass fixture %d",material),CaelumToughnessRules.Reduction(gate.Mass,gate.Toughness),reduction);
            gate.DamageMobj(Attacker,Attacker,int(incoming),'Hitscan',DMG_NO_ARMOR,0);
            Check(String.Format("gate final defense ordering %d",material),initial-gate.health,expected);gate.Destroy();
        }
    }
    override void WorldTick()
    {
        Age++;if(Age!=40 && Age!=110)return;
        if(Age==40)
        {
            User=CaelumPlayer(players[0].mo);TargetBody=CaelumCombatActor(Actor.Spawn("CA188Target",User.Pos+(256,0,0)));
            Attacker=Actor.Spawn("CA188Target",User.Pos+(128,0,32));User.Angle=User.AngleTo(Attacker);
            Formula();Directed();DefensePaths();StatusMatrix();Gates();
            PlayerState(50);User.ElementalStatus=new("CaelumElementalStatus");
            User.ElementalStatus.ApplyDamageOverTime(CaelumConstants.ELEMENTAL_EFFECT_POISON,10,1,10,Attacker,User);
            LiveStart=User.ElementalStatus.PoisonRemaining;
        }
        else
        {
            Check("unpaused native world advances active dose",User.ElementalStatus.PoisonRemaining,LiveStart-2,0.04);
            Console.Printf("CA188 DONE failures=%d passes=%d",Failures,Passed);
        }
    }
}

