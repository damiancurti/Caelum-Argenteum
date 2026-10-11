// Casos controlados sobre los receptores y lanzadores reales de GZDoom.
class CA192Target : CaelumCombatActor
{
    override void Tick(){}
    Default {Radius 16;Height 56;Mass 80;Health 1000000;+SHOOTABLE;+NOGRAVITY;}
    States {Spawn: TNT1 A -1;Stop;}
}
class CA192Native : StaticEventHandler
{
    int Age,Passes,Failures;
    CaelumPlayer User;
    CaelumCombatActor Receiver;
    Actor Attacker;
    void Check(String label,double actual,double expected,double tolerance=0.00001)
    {
        bool ok=Abs(actual-expected)<=tolerance;if(ok)Passes++;else Failures++;
        Console.Printf("CA192 %s %s actual=%.9f expected=%.9f",ok?"PASS":"FAIL",label,actual,expected);
    }
    void Truth(String label,bool value){Check(label,value?1:0,1);}
    override void UiTick(){if(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();}
    void Choices(int a,int b,int c,int d)
    {
        let p=User.CharacterProfile;p.PersonalityRevision=1;
        p.Personality[0]=a;p.Personality[1]=b;p.Personality[2]=c;p.Personality[3]=d;
    }
    void Reset(double attribute=20)
    {
        User.CharacterCreationComplete=true;User.CreationWizardOpen=false;User.bInvulnerable=false;
        User.CharacterProfile.Race=CaelumConstants.RACE_HUMAN;
        Choices(0,0,0,2);User.Attributes.SetAllForDebug(attribute);
        User.DerivedStats.Recalculate(User.Attributes,User.CharacterProfile);
        User.CaelumMaximumHealth=1000000;User.health=User.player.health=1000000;
        User.DerivedStats.BaseMass=80;User.DerivedStats.LoadRatio=0;
        User.ArmorModel=new("CaelumArmorModel");User.ArmorModel.InitializeDefaults();
        User.WeaponModel.Equipped=false;User.ShieldModel.Equipped=false;
        User.DebugShieldBlocking=false;User.CombatBlockModeActive=false;
        User.HealthAdrenalineGainMultiplier=1;User.HealthPerformanceMultiplier=1;
        User.CurrentAir=User.DerivedStats.MaximumAir;User.EffectiveOffensiveDamageMultiplier=1;
        User.CurrentLucidity=100;User.ElementalStatus=new("CaelumElementalStatus");
        Receiver.Mass=80;Receiver.CombatToughness=20;Receiver.CombatMaximumHealth=1000000;Receiver.health=1000000;
        Receiver.EffectiveCombatEvasionChance=0;Receiver.CombatArmor=new("CaelumArmorModel");Receiver.CombatArmor.InitializeDefaults();
    }
    CaelumActorProjectile Shot(int ideology,int weapon,int tier)
    {
        Choices(0,0,0,ideology);
        let shot=CaelumActorProjectile(Actor.Spawn("CaelumActorSimpleElementalProjectile",User.Pos+(128,0,32)));
        shot.target=User;shot.Vel=(0,0,0);
        shot.StoreCaelumAttackResult(1000,true,false,true,1);
        shot.StoreCaelumWeaponWearIdentity(weapon,tier,CaelumConstants.EQUIPMENT_SIZE_M);
        return shot;
    }
    void Options()
    {
        Reset();let p=User.CharacterProfile;
        User.CharacterAllocation.Recommend(p);User.CreationWizardOpen=true;User.CreationWizardPage=6;
        User.AdvanceCreationWizard();Check("legacy wizard enters personality",User.CreationWizardPage,8);
        for(int layer=0;layer<4;layer++)
        {
            int old=p.Personality[layer];User.CycleCurrentCreationChoice();
            Check("legacy wizard changes correct layer",p.Personality[layer],(old+1)%3);User.AdvanceCreationWizard();
        }
        Check("legacy wizard reaches summary",User.CreationWizardPage,7);
        User.GoBackCreationWizard();Check("legacy summary returns to ideology",User.CreationWizardPage,11);
        for(int back=0;back<4;back++)User.GoBackCreationWizard();
        Check("legacy personality returns to allocation",User.CreationWizardPage,6);User.CreationWizardOpen=false;
        double factors[]={1,1.25,1.5};double alternatives[]={1.5,1.25,1};
        for(int layer=0;layer<4;layer++)for(int choice=0;choice<3;choice++)
        {
            Choices(0,0,0,2);p.Personality[layer]=choice;
            Check(String.Format("option %d/%d power",layer,choice),CaelumPersonalityRules.MagicPower(p),layer<3?factors[choice]:1);
            if(layer<3)Check(String.Format("option %d/%d alternative",layer,choice),CaelumPersonalityRules.Alternative(p,layer),alternatives[choice]);
            else
            {
                Check("ideology penetration",CaelumPersonalityRules.Penetration(p),choice==0?0.25:choice==1?0.125:0);
                Check("ideology magical absorption",CaelumPersonalityRules.Absorption(User,true),choice==0?1:choice==1?1.125:1.25);
                Check("ideology no physical absorption bonus",CaelumPersonalityRules.Absorption(User,false),1);
            }
        }
        for(int a=0;a<3;a++)for(int b=0;b<3;b++)for(int c=0;c<3;c++)for(int d=0;d<3;d++)
        {
            Choices(a,b,c,d);double expected=factors[a]*factors[b]*factors[c];
            Check("independent combined power",CaelumPersonalityRules.MagicPower(p),expected);
            let copy=new("CaelumCharacterProfile");copy.CopyFrom(p);
            int packed=CaelumPersonalityRules.Pack(copy);let decoded=new("CaelumCharacterProfile");
            Truth("four choices serialize and copy",CaelumPersonalityRules.Unpack(decoded,packed) && CaelumPersonalityRules.Pack(decoded)==packed);
        }
        Choices(2,2,2,0);Check("max power fixture",CaelumPersonalityRules.MagicPower(p),3.375);
        Choices(1,1,1,1);Check("all normal power fixture",CaelumPersonalityRules.MagicPower(p),1.953125);
        let old=new("CaelumCharacterProfile");old.EnsurePersonality();old.EnsurePersonality();
        Check("legacy explicit normal center once",CaelumPersonalityRules.Pack(old),40);
        Truth("invalid packed choice rejected",!CaelumPersonalityRules.Unpack(old,81) && !CaelumPersonalityRules.Unpack(old,-1));
        for(int choice=0;choice<3;choice++)
        {
            Reset();Choices(choice,choice,choice,1);User.CurrentAdrenaline=0;
            double capacity=User.DerivedStats.MaximumAdrenaline;
            User.AddCombatAdrenaline(10);Check("adrenaline gain factor",User.CurrentAdrenaline,10*alternatives[choice]);
            Check("adrenaline capacity unchanged",User.DerivedStats.MaximumAdrenaline,capacity);
            User.UpdateAirStateEffects();
            Check("evasion probability factor",User.EffectiveEvasionChance,User.DerivedStats.BaseEvasionChance*alternatives[choice]);
        }
    }
    void PowerAndBell()
    {
        Reset(0);Choices(0,0,0,2);let d=User.DerivedStats;d.Recalculate(User.Attributes,User.CharacterProfile);
        double baseDamage=d.DebugStaffDamage,basePush=d.MagicalPushMultiplier,box=d.MagicBoxCapacity;
        double duration=d.DebuffPowerPercent,range=d.AbilityRangePercent,physical=d.DebugSwordDamage;
        Choices(2,2,2,2);d.Recalculate(User.Attributes,User.CharacterProfile);d.Recalculate(User.Attributes,User.CharacterProfile);
        Check("shared damage power once",d.DebugStaffDamage,baseDamage*3.375);
        Check("shared push power once",d.MagicalPushMultiplier,basePush*3.375);
        Check("Box unaffected",d.MagicBoxCapacity,box);Check("duration control unaffected",d.DebuffPowerPercent,duration);
        Check("range unaffected",d.AbilityRangePercent,range);Check("physical damage unaffected",d.DebugSwordDamage,physical);
        let stream=CaelumUtilityStaffStream(Actor.Spawn("CaelumUtilityStaffStream",User.Pos));stream.Emitter=User;
        Check("utility stream energy factor",CaelumElementalStream.ThermalPowerFactor(stream),3.375);stream.Destroy();
        for(int tier=1;tier<=3;tier++)for(int charged=0;charged<2;charged++)for(int secondary=0;secondary<2;secondary++)
        {
            User.WeaponModel.WeaponType=CaelumConstants.WEAPON_TYPE_BELL;User.WeaponModel.Tier=tier;User.WeaponModel.Equipped=true;
            User.WeaponModel.Durability=10000;User.EffectiveOffensiveDamageMultiplier=1;User.LastStaffCriticalHit=false;
            double expected=50*User.WeaponModel.GetTierDamageMultiplierFor(tier)*3.375*(charged?2:1);
            User.ReleasePendingStaffAttack(secondary,CaelumConstants.WEAPON_TYPE_BELL,CaelumConstants.ESSENCE_FIRE,charged);
            int count=0;let it=ThinkerIterator.Create("CaelumPlayerMagicProjectile");CaelumPlayerMagicProjectile shot;
            while((shot=CaelumPlayerMagicProjectile(it.Next()))!=null)
            {
                if(shot.target!=User)continue;count++;
                Check("bell independent per-projectile damage",shot.CaelumPreparedDamage,int(expected+0.5));
                Check("bell per-projectile magical power",shot.CaelumPushMultiplier,3.375);
                Truth("bell individual metadata",shot.CaelumAttackPrepared && shot.CaelumElementalPayloadPrepared && shot.CaelumWearWeaponTier==tier);
                int healthBefore=Receiver.health;
                Receiver.DamageMobj(shot,User,shot.CaelumPreparedDamage,'CaelumMagicTest',DMG_NO_ARMOR,0);
                Check("each bell projectile receives its own half R",healthBefore-Receiver.health,
                    int(Max(0,Receiver.LastCombatArmorPostDefenseDamage-60.16)+0.5));
                shot.Destroy();
            }
            Check(String.Format("bell T%d charged%d secondary%d count",tier,charged,secondary),count,12);
        }
        Check("bell cast base cost unchanged",CaelumConstants.WEAPON_BELL_ANIMA_COST,100);
    }
    void CriticalAndEnergy()
    {
        double multipliers[]={1.5,1.25,1};
        for(int choice=0;choice<3;choice++)
        {
            Reset();Choices(0,choice,0,2);
            User.WeaponModel.WeaponType=CaelumConstants.WEAPON_TYPE_SWORD;User.WeaponModel.Tier=1;
            User.WeaponModel.Equipped=true;User.WeaponModel.Durability=10000;
            User.Angle=0;User.Pitch=0;Receiver.SetOrigin(User.Pos+(40,0,0),false);
            User.PerformDebugSwordAttack(false);
            Truth("native melee reaches critical roll",User.LastMeleeCriticalAttempted);
            int sword=CaelumCraftingRules.GetCatalogueWeaponForPlayableType(CaelumConstants.WEAPON_TYPE_SWORD);
            double expected=(CaelumWeaponCatalogue.GetCriticalChancePercent(sword)
                +Max(0,User.DerivedStats.PhysicalCriticalChance-CaelumConstants.BASE_CRITICAL_CHANCE_PERCENT))*multipliers[choice];
            Check("physical critical multiplies full chance",User.LastMeleeCriticalChancePercent,Min(100,expected));
            User.WeaponModel.WeaponType=CaelumConstants.WEAPON_TYPE_STAFF;
            User.ReleasePendingStaffAttack(false,CaelumConstants.WEAPON_TYPE_STAFF,CaelumConstants.ESSENCE_FIRE,false);
            expected=(User.WeaponModel.GetBaseCriticalChanceFor(CaelumConstants.WEAPON_TYPE_STAFF)
                +Max(0,User.DerivedStats.MagicalCriticalChance-CaelumConstants.BASE_CRITICAL_CHANCE_PERCENT))*multipliers[choice];
            Check("magical critical multiplies full chance",User.LastStaffCriticalChancePercent,Min(100,expected));
            let it=ThinkerIterator.Create("CaelumPlayerMagicProjectile");Actor existing;while((existing=Actor(it.Next()))!=null)existing.Destroy();
        }
        Reset(100);Choices(0,0,0,2);User.WeaponModel.WeaponType=CaelumConstants.WEAPON_TYPE_STAFF;User.WeaponModel.Equipped=true;
        User.ReleasePendingStaffAttack(false,CaelumConstants.WEAPON_TYPE_STAFF,CaelumConstants.ESSENCE_FIRE,false);
        Check("critical capped at final probability boundary",User.LastStaffCriticalChancePercent,100);
        let it=ThinkerIterator.Create("CaelumPlayerMagicProjectile");Actor existing;while((existing=Actor(it.Next()))!=null)existing.Destroy();
        Reset(0);Choices(2,2,2,2);User.DerivedStats.Recalculate(User.Attributes,User.CharacterProfile);
        let shot=Shot(2,CaelumConstants.WEAPON_TYPE_STAFF,1);
        shot.CaelumPushMultiplier=User.DerivedStats.MagicalPushMultiplier;
        shot.StoreCaelumElementalPayload(CaelumConstants.ESSENCE_FIRE,false,100,100);
        let thermal=CaelumThermalBody.Get(User,true);double before=thermal.AbsorbedImpactJoules;
        CaelumThermalMagic.Impact(User,shot,1);
        Check("actual fire impulse follows magical power once",thermal.AbsorbedImpactJoules-before,337.5);
        CaelumThermalMagic.Impact(User,shot,1);
        Check("same projectile cannot repeat thermal impulse",thermal.AbsorbedImpactJoules-before,337.5);
        shot.Destroy();
    }
    CaelumEquipmentItem EquipShield(int tier)
    {
        let item=CaelumEquipmentItem(Actor.Spawn("CaelumShieldPickup",User.Pos));
        item.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_SHIELD;item.ItemType=CaelumConstants.SHIELD_TYPE_TOWER;
        item.Tier=tier;item.EquipmentSize=CaelumConstants.EQUIPMENT_SIZE_M;item.Equipped=true;
        item.PickupDataInitialized=true;item.AcquisitionResolved=true;item.AttachToOwner(User);User.EnsureEquipmentItemId(item);
        User.EquippedShieldItemId=item.ItemId;User.ShieldModel.ShieldType=item.ItemType;User.ShieldModel.Tier=tier;
        User.ShieldModel.Equipped=true;User.ShieldModel.Durability=100000;
        User.WeaponModel.Equipped=false;User.DebugShieldBlocking=true;User.Angle=User.AngleTo(Attacker);
        return item;
    }
    void Defenses()
    {
        Reset();Choices(0,0,0,0);
        let javelin=CaelumActorProjectile(Actor.Spawn("CaelumActorSimpleElementalProjectile",User.Pos+(128,0,32)));
        javelin.target=User;javelin.StoreCaelumAttackResult(100,true,false,false,1);
        Choices(0,0,0,2);User.WeaponModel.WeaponType=CaelumConstants.WEAPON_TYPE_CARBINE;User.WeaponModel.Equipped=true;
        Check("javelin snapshots ideology before weapon switch",CaelumPersonalityRules.AttackPenetration(javelin),0.25);
        Truth("javelin snapshot does not add deferred weapon wear",!javelin.CaelumWeaponWearPrepared);
        javelin.Destroy();Choices(0,0,0,0);
        let channel=CaelumChannelEffect(Actor.Spawn("CaelumChannelEffect",User.Pos));channel.ChannelOwner=User;
        Check("channel retains ideology with a carbine equipped",CaelumPersonalityRules.AttackPenetration(channel,User),0.25);
        channel.Destroy();
        for(int weapon=0;weapon<2;weapon++)for(int tier=1;tier<=3;tier++)for(int ideology=0;ideology<3;ideology++)
        {
            Reset();int type=weapon==0?CaelumConstants.WEAPON_TYPE_CARBINE:CaelumConstants.WEAPON_TYPE_SHOTGUN;
            let shot=Shot(ideology,type,tier);User.WeaponModel.WeaponType=CaelumConstants.WEAPON_TYPE_SWORD;
            Choices(0,0,0,2);
            Check("firearm frozen armor-only bypass",CaelumArmorRules.EquipmentRetention(shot),1-(weapon==0?0.6:0.5)-0.1*tier);
            Check("firearm never gains ideology shield penetration",CaelumPersonalityRules.AttackPenetration(shot),0);
            let shield=EquipShield(1);Check("firearm shield retains full base absorption",User.ResolveRealShieldDamage(shot,Attacker,1000,'Hitscan'),200);
            shield.Destroy();shot.Destroy();
        }
        for(int offense=0;offense<3;offense++)for(int defense=0;defense<3;defense++)for(int magic=0;magic<2;magic++)
        {
            Reset();let shot=Shot(offense,CaelumConstants.WEAPON_TYPE_BELL,1);Choices(0,0,0,defense);
            double pen=offense==0?0.25:offense==1?0.125:0;
            double boost=magic?(defense==0?1:defense==1?1.125:1.25):1;
            User.ArmorModel.InitializeUniformLoadout(CaelumConstants.ARMOR_TYPE_MAGIC,1);
            double equipped=(magic?30:10)*boost*(1-pen);
            Check("equipped defense boost then additive penetration",CaelumArmorRules.EquippedDefense(User.ArmorModel,1,magic,User,shot),equipped);
            Check("innate remains outside personality modifiers",User.GetArmorDefensePercent(1,magic,shot),7.5+equipped);
            let shield=EquipShield(3);double remaining=1000*(1-Min(1,boost*(1-pen)));
            double actual=User.ResolveRealShieldDamage(shot,Attacker,1000,magic?'CaelumMagicTest':'Hitscan');
            Check("100 percent nominal shield clamps after modifiers",actual,remaining);
            User.PrepareRealArmorDamage(actual,false,CaelumConstants.ARMOR_SLOT_BODY,magic,shot);
            Check("sequential shield armor then toughness",User.LastArmorHealthDamage,
                int(Max(0,remaining*User.LastArmorVulnerabilityMultiplier*(1-(7.5+equipped)/100)-120.32*(magic?0.5:1))+0.5));
            shield.Destroy();shot.Destroy();
        }
        for(int tier=1;tier<=3;tier++)
        {
            Reset();Choices(0,0,0,2);User.ArmorModel.InitializeUniformLoadout(CaelumConstants.ARMOR_TYPE_MAGIC,tier);
            Check("conservative magic armor tiers",User.GetArmorDefensePercent(1,true)-7.5,tier==1?37.5:tier==2?56.25:75);
        }
        Reset();let soldier=CaelumPortDefender(Actor.Spawn("CaelumPortDefender",User.Pos+(256,0,0)));
        soldier.Shield=new("CaelumShieldModel");soldier.Shield.InitializeDefaults();
        soldier.Shield.ShieldType=CaelumConstants.SHIELD_TYPE_TOWER;soldier.Shield.Equipped=true;soldier.Shield.Tier=3;
        soldier.Carbine=null;soldier.Angle=soldier.AngleTo(User);soldier.bInvulnerable=false;soldier.health=100000;
        for(int ideology=0;ideology<3;ideology++)for(int firearm=0;firearm<2;firearm++)
        {
            soldier.Shield.Durability=100000;
            let shot=Shot(ideology,firearm?CaelumConstants.WEAPON_TYPE_CARBINE:CaelumConstants.WEAPON_TYPE_BELL,1);
            double pen=firearm?0:ideology==0?0.25:ideology==1?0.125:0;
            Check("NPC 100 percent shield respects ideology and firearm exclusion",soldier.ResolveActorShieldDamage(shot,User,1001,'CaelumMagicTest',0),1001*pen);
            shot.Destroy();
        }
        soldier.Destroy();
    }
    override void WorldTick()
    {
        Age++;if(Age!=40)return;User=CaelumPlayer(players[0].mo);
        Receiver=CaelumCombatActor(Actor.Spawn("CA192Target",User.Pos+(256,0,0)));
        Attacker=Actor.Spawn("CA192Target",User.Pos+(128,0,32));
        Options();PowerAndBell();CriticalAndEnergy();Defenses();
        Console.Printf("CA192 DONE failures=%d passes=%d",Failures,Passes);
    }
}
