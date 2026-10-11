// Colisiones nativas y llamadas DamageMobj completas, sin sustituir solvers.
class CA192Probe : CaelumPlayerMagicProjectile
{
    override int DoSpecialDamage(Actor victim,int damage,Name mod)
    {
        if(CaelumDefenseReceiver==victim)return damage;
        let count=CVar.GetCVar("ca192_stage");count.SetInt(count.GetInt()+1);
        return Super.DoSpecialDamage(victim,damage,mod);
    }
}
class CA192Collision : CA192Native
{
    int Before;
    override void WorldTick()
    {
        Age++;if(Age<40)return;
        if(level.MapName=="CADEV02")
        {
            if(Age!=40)return;
            let owner=CaelumCombatActor(Actor.Spawn("CA192Target",(9000,0,0)));
            let ally=CaelumCombatActor(Actor.Spawn("CA192Target",(9100,0,0)));
            let blast=CaelumActorProjectile(Actor.Spawn("CaelumActorExplosiveElementalProjectile",(9090,0,32)));
            blast.Target=owner;blast.StoreCaelumAttackResult(1000,true,false,true,1);
            int before=ally.health;ally.DamageMobj(blast,owner,500,'CaelumMagicTest',DMG_EXPLOSION,0);
            Check("mass diagnostic explosion preserves allied immunity",before-ally.health,0);
            Check("mass diagnostic friendly-fire counter records once",owner.ImpactDiagnosticFriendlyFirePrevented,1);
            Console.Printf("CA192 DONE failures=%d passes=%d",Failures,Passes);return;
        }
        if(Age==40)
        {
            User=CaelumPlayer(players[0].mo);User.bNOTARGET=true;
            Receiver=CaelumCombatActor(Actor.Spawn("CA192Target",User.Pos+(256,0,0)));
            Attacker=Actor.Spawn("CA192Target",User.Pos+(128,0,32));
            DirectCases();
        }
        if(Age==45 || Age==65)
        {
            Reset();Choices(0,0,0,0);User.EffectiveEvasionChance=0;
            Actor victim=Age==45?Actor(Receiver):Actor(User);
            victim.bINVULNERABLE=false;
            CVar.GetCVar("ca192_stage").SetInt(0);Before=victim.health;
            let shot=CaelumActorProjectile(Actor.Spawn("CA192Probe",victim.Pos+(64,0,victim.Height*0.6)));
            shot.Target=Age==45?Actor(User):Attacker;shot.Angle=180;shot.Vel=(-20,0,0);
            shot.StoreCaelumAttackResult(1000,true,false,true,1);
        }
        if(Age==55 || Age==75)
        {
            int lost=Before-(Age==55?Receiver.health:User.health);
            double post=Age==55?Receiver.LastCombatArmorPostDefenseDamage:User.LastArmorPostDefenseDamage;
            Truth("native flying projectile collides",lost>0);
            Check("native collision applies half R after armor",lost,int(Max(0,post-60.16)+0.5));
            Check("native collision prepares damage once",CVar.GetCVar("ca192_stage").GetInt(),1);
        }
        if(Age==80)Console.Printf("CA192 DONE failures=%d passes=%d",Failures,Passes);
    }
    void DirectCases()
    {
        Reset();Choices(0,0,0,0);
        let shot=CaelumActorProjectile(Actor.Spawn("CA192Probe",Receiver.Pos+(0,0,Receiver.Height*0.6)));
        shot.Target=User;shot.StoreCaelumAttackResult(1000,true,false,true,1);
        for(int mode=0;mode<3;mode++)
        {
            Receiver.bINVULNERABLE=mode==0;Receiver.bDORMANT=mode==1;Receiver.EffectiveCombatEvasionChance=mode==2?100:0;
            int before=Receiver.health;CVar.GetCVar("ca192_stage").SetInt(0);
            Receiver.DamageMobj(shot,User,1,'CaelumMagicTest',0,0);
            Check("rejected hit loses no HP",before-Receiver.health,0);
            Check("rejected hit does not prepare damage or wear",CVar.GetCVar("ca192_stage").GetInt(),0);
            Truth("guard restored after rejection",shot.CaelumDefenseReceiver==null);
        }
        Receiver.bDORMANT=false;Receiver.EffectiveCombatEvasionChance=0;
        shot.StoreCaelumAttackResult(1,true,false,true,1);int before=Receiver.health;
        Receiver.DamageMobj(shot,User,1,'CaelumMagicTest',0,0);
        Check("fully mitigated projectile remains zero",before-Receiver.health,0);
        Truth("guard restored after zero health damage",shot.CaelumDefenseReceiver==null);
        shot.Destroy();
        for(int kind=0;kind<3;kind++)for(int critical=0;critical<2;critical++)
        {
            Reset();class<CaelumActorProjectile> type=kind==0?"CaelumCarbineProjectile":kind==1?"CaelumExplosiveMagicProjectile":"CaelumActorExplosiveElementalProjectile";
            let projectile=CaelumActorProjectile(Actor.Spawn(type,Receiver.Pos+(0,0,Receiver.Height*0.6)));
            projectile.Target=User;projectile.StoreCaelumAttackResult(1000,true,critical,kind!=0,1);
            before=Receiver.health;Receiver.DamageMobj(projectile,User,1,kind==0?'CaelumRangedTest':'CaelumMagicTest',0,0);
            Check("physical and explosive direct pipeline",before-Receiver.health,int(Max(0,Receiver.LastCombatArmorPostDefenseDamage-(kind==0?120.32:60.16))+0.5));
            Truth("guard restored after actual health damage",projectile.CaelumDefenseReceiver==null);
            projectile.Destroy();
        }
        Reset();let explosive=CaelumActorProjectile(Actor.Spawn("CaelumExplosiveMagicProjectile",Receiver.Pos+(32,0,32)));
        explosive.Target=User;explosive.StoreCaelumAttackResult(9000,true,false,true,1);
        let weapon=CaelumEquipmentItem(Actor.Spawn("CaelumWeaponPickup",User.Pos));
        weapon.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_WEAPON;weapon.ItemType=CaelumConstants.WEAPON_TYPE_STATUETTE;
        weapon.Tier=1;weapon.EquipmentSize=CaelumConstants.EQUIPMENT_SIZE_M;
        weapon.PickupDataInitialized=true;weapon.AcquisitionResolved=true;weapon.AttachToOwner(User);User.EnsureEquipmentItemId(weapon);
        weapon.MigrateWeaponDurability();weapon.Durability=10000;User.ActiveWeaponItemId=weapon.ItemId;User.ArmorDurabilityDamageMultiplier=1;
        explosive.StoreCaelumWeaponWearIdentity(weapon.ItemType,1,weapon.EquipmentSize);
        for(int n=0;n<2;n++)
        {
            before=Receiver.health;Receiver.DamageMobj(explosive,User,500,'CaelumMagicTest',DMG_EXPLOSION,0);
            Check("blast uses supplied budget and mitigates each recipient",before-Receiver.health,int(Max(0,Receiver.LastCombatArmorPostDefenseDamage-60.16)+0.5));
            Truth("blast cannot inherit a previous receiver guard",explosive.CaelumDefenseReceiver==null);
            Check("blast-only native owned weapon wears once per callback",weapon.Durability,10000-9*(n+1));
        }
        Check("forced native sentinel skips prepared damage",CaelumActorProjectile.PrepareDefense(Receiver,explosive,1000000,'Telefrag',DMG_FORCED),1000000);
        Check("ordinary telefrag sentinel skips prepared damage",CaelumActorProjectile.PrepareDefense(Receiver,explosive,1000000,'Telefrag',0),1000000);
        explosive.Destroy();weapon.Destroy();
        Reset();let soldier=CaelumPortDefender(Actor.Spawn("CaelumPortDefender",User.Pos+(256,0,0)));
        soldier.Carbine=null;soldier.health=soldier.CombatMaximumHealth=100000;soldier.Mass=80;soldier.CombatToughness=20;
        soldier.EffectiveCombatEvasionChance=0;soldier.Angle=soldier.AngleTo(User);
        soldier.Shield=new("CaelumShieldModel");soldier.Shield.InitializeDefaults();
        soldier.Shield.ShieldType=CaelumConstants.SHIELD_TYPE_TOWER;soldier.Shield.Tier=1;soldier.Shield.Equipped=true;soldier.Shield.Durability=100000;
        soldier.CombatArmor=new("CaelumArmorModel");soldier.CombatArmor.InitializeDefaults();
        Choices(0,0,0,0);let bolt=CaelumActorProjectile(Actor.Spawn("CA192Probe",soldier.Pos+(0,0,soldier.Height*0.6)));
        bolt.Target=User;bolt.StoreCaelumAttackResult(1000,true,false,true,1);before=soldier.health;
        soldier.DamageMobj(bolt,User,1,'CaelumMagicTest',0,0);
        double anatomy=soldier.GetActorVulnerabilityMultiplier(soldier.LastAnatomyVulnerabilityGrade);
        Check("NPC native shield then anatomy uses raw projectile once",soldier.LastCombatArmorIncomingDamage,1000*(1-0.8*0.75)*anatomy);
        Check("NPC native shield armor then R",before-soldier.health,int(Max(0,soldier.LastCombatArmorPostDefenseDamage-60.16)+0.5));
        Truth("NPC shield native wear still occurs",soldier.Shield.Durability<100000);
        bolt.Destroy();soldier.Destroy();
    }
}
