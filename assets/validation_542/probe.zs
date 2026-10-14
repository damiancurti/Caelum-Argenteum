// #261: receptores reales con defensas controladas; no pertenece al juego.
class CA261Target : CaelumCombatActor
{
    override void Tick() {}
    Default { Radius 16; Height 56; Mass 80; Health 100000; +SHOOTABLE; +NOGRAVITY; }
    States { Spawn: TNT1 A -1; Stop; }
}
class CA261Shot : CaelumActorProjectile
{
    override void Tick() {}
    Default { Radius 4; Height 8; +NOGRAVITY; }
    States { Spawn: TNT1 A -1; Stop; }
}
class CA261Probe : StaticEventHandler
{
    int Passed,Failed;
    CaelumPlayer User;
    CaelumEquipmentItem Seal;
    void Check(String label,double actual,double expected,double tolerance=0.00001)
    {
        bool ok=Abs(actual-expected)<=tolerance;if(ok)Passed++;else Failed++;
        Console.Printf("CA261 %s %s actual=%.6f expected=%.6f",ok?"PASS":"FAIL",label,actual,expected);
    }
    override void UiTick(){if(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();}
    void Reset()
    {
        User.CreationWizardOpen=false;User.CharacterCreationComplete=true;
        User.bInvulnerable=false;User.EffectiveEvasionChance=0;
        User.Attributes.Toughness=0;User.DerivedStats.BaseMass=80;
        User.CombatBlockModeActive=false;User.DebugShieldBlocking=false;
        User.CaelumMaximumHealth=100000;User.health=100000;User.player.health=100000;
        User.ArmorModel=new("CaelumArmorModel");User.ArmorModel.InitializeDefaults();
        User.ShieldModel.Equipped=false;User.WeaponModel.Equipped=false;
        User.ElementalStatus=new("CaelumElementalStatus");User.CurrentLucidity=100;
    }
    CaelumEquipmentItem GiveSeal(Actor owner)
    {
        let seal=CaelumEquipmentItem(Actor.Spawn("CaelumSealPickup",owner.Pos,NO_REPLACE));
        seal.PickupDataInitialized=true;seal.AcquisitionResolved=true;
        seal.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_SEAL;seal.Tier=1;
        seal.ItemType=0;seal.Equipped=false;seal.AttachToOwner(owner);return seal;
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!="c261_audit")return;
        User=CaelumPlayer(players[e.Player].mo);User.ApplyCharacterProfile();Reset();
        Seal=GiveSeal(User);
        let shot=CA261Shot(Actor.Spawn("CA261Shot",User.Pos+(32,0,User.Height*0.6),NO_REPLACE));
        shot.StoreCaelumAttackResult(1000,true,false,true,1);
        Name types[]={'Fire','Light','Water','Ice','Earth','Poison','Air','Lightning','Quintessence'};
        for(int s=0;s<5;s++)for(int t=1;t<=3;t++)for(int element=0;element<9;element++)
        {
            int essence=element/2;
            double expected=s==4 ? 0.85 : s==essence ? 0.5 : 1;
            Seal.ItemType=s;Seal.Tier=t;Seal.Equipped=true;
            Check(String.Format("named seal%d T%d element%d",s,t,element),
                CaelumSealResistance.ForEssence(User,CaelumSealResistance.Essence(null,types[element])),expected);
            shot.StoreCaelumElementalPayload(essence,(element%2)!=0,100,100);
            Check(String.Format("payload seal%d T%d element%d",s,t,element),
                CaelumSealResistance.ForEssence(User,CaelumSealResistance.Essence(shot,'CaelumMagicTest')),expected);
            Reset();Seal.Equipped=false;
            User.DamageMobj(shot,null,1000,'CaelumMagicTest',0,0);
            double unscaled=User.LastArmorPostDefenseDamage*User.LastToughnessDamageMultiplier;
            Reset();Seal.Equipped=true;
            User.DamageMobj(shot,null,1000,'CaelumMagicTest',0,0);
            Check(String.Format("actual player seal%d T%d element%d",s,t,element),100000-User.health,int(unscaled*expected+0.5));
        }
        Seal.ItemType=0;Seal.Equipped=false;
        Check("owned inactive seal",CaelumSealResistance.ForEssence(User,0),1);
        Seal.Equipped=true;
        Seal.InMagicBox=true;
        Check("boxed seal excludes stale equipped flag",CaelumSealResistance.ForEssence(User,0),1);
        Seal.InMagicBox=false;
        Check("physical metadata excluded",CaelumSealResistance.HealthDamage(User,shot,100,'CaelumImpact'),100);
        Check("unspecified magic not inferred",CaelumSealResistance.HealthDamage(User,null,100,'CaelumTrapMagic'),100);
        Check("zero unchanged",CaelumSealResistance.HealthDamage(User,null,0,'Fire'),0);
        Check("healing unchanged",CaelumSealResistance.HealthDamage(User,null,-10,'Fire'),-10);
        Reset();User.ElementalStatus.ApplyDamageOverTime(CaelumConstants.ELEMENTAL_EFFECT_BURN,2,1,1,null,User);
        for(int tic=0;tic<TICRATE*2;tic++)User.ElementalStatus.TickDamageOverTime(User);
        Check("fractional burn 1 DPS over 2 seconds",100000-User.health,1);
        Check("burn duration unchanged",User.ElementalStatus.BurnRemaining,0);
        Reset();User.ElementalStatus.ApplyDamageOverTime(CaelumConstants.ELEMENTAL_EFFECT_POISON,2,1,1,null,User);
        for(int tic=0;tic<TICRATE*2;tic++)User.ElementalStatus.TickDamageOverTime(User);
        Check("nonmatching poison",100000-User.health,2);
        Reset();User.Attributes.Toughness=150;User.health=90000;User.player.health=90000;
        User.ElementalStatus.ApplyDamageOverTime(CaelumConstants.ELEMENTAL_EFFECT_BURN,2,1,100,null,User);
        double healingDuration=User.ElementalStatus.BurnRemaining;
        for(int tic=0;tic<TICRATE;tic++)User.ElementalStatus.TickDamageOverTime(User);
        Check("healing burn is not reduced",User.health-90000,100);
        Check("healing duration advances normally",User.ElementalStatus.BurnRemaining,healingDuration-1);
        let npc=CA261Target(Actor.Spawn("CA261Target",User.Pos+(128,0,0),NO_REPLACE));
        npc.PostBeginPlay();npc.InitializeCombatProfile(0,0,0,0,0,0,0,0,0,0,0,0);
        npc.CombatArmor=new("CaelumArmorModel");npc.CombatArmor.InitializeDefaults();
        npc.EffectiveCombatEvasionChance=0;
        let npcSeal=GiveSeal(npc);
        for(int s=0;s<5;s++)for(int element=0;element<9;element++)
        {
            double factor=s==4 ? 0.85 : s==element/2 ? 0.5 : 1;
            shot.StoreCaelumElementalPayload(element/2,(element%2)!=0,100,100);
            npc.health=100000;npc.CombatMaximumHealth=100000;npcSeal.ItemType=s;npcSeal.Equipped=true;
            npc.DamageMobj(shot,null,1000,'CaelumMagicTest',0,0);
            Check(String.Format("actual NPC seal%d element%d",s,element),100000-npc.health,int(npc.LastCombatPostToughnessDamage*factor+0.5));
            npc.health=100000;shot.CaelumActorExplosionRadius=128;
            npc.DamageMobj(shot,null,1000,'CaelumMagicTest',DMG_EXPLOSION,0);
            Check(String.Format("actual NPC area seal%d element%d",s,element),100000-npc.health,int(npc.LastCombatPostToughnessDamage*factor+0.5));
            Reset();Seal.ItemType=s;Seal.Equipped=true;
            shot.CaelumActorExplosionRadius=128;
            User.DamageMobj(shot,null,1000,'CaelumMagicTest',DMG_EXPLOSION,0);
            double exact=User.LastArmorPostDefenseDamage*User.LastToughnessDamageMultiplier;
            Check(String.Format("actual player area seal%d element%d",s,element),100000-User.health,int(exact*factor+0.5));
        }
        npc.Destroy();Seal.ItemType=0;
        Reset();User.DamageMobj(shot,null,1000,'CaelumImpact',0,0);
        Check("physical impact HP unchanged",100000-User.health,1000);
        Reset();Seal.ItemType=4;
        User.ElementalStatus.ApplyDamageOverTime(CaelumConstants.ELEMENTAL_EFFECT_BURN,20,1,1,null,User);
        for(int tic=0;tic<TICRATE*20;tic++)User.ElementalStatus.TickDamageOverTime(User);
        Check("fractional quintessence burn 20 seconds",100000-User.health,17);
        Seal.ItemType=0;
        Reset();shot.StoreCaelumElementalPayload(0,false,100,100);Seal.Equipped=false;
        User.DamageMobj(shot,null,1000,'CaelumMagicTest',0,0);
        int originalDPS=User.ElementalStatus.BurnDamagePerSecond;
        Reset();Seal.Equipped=true;
        User.DamageMobj(shot,null,1000,'CaelumMagicTest',0,0);
        Check("burn source dose not reduced twice",User.ElementalStatus.BurnDamagePerSecond,originalDPS);
        for(int factor=1;factor<=2;factor++)
        {
            Reset();User.DamageFactor=factor*0.5;Seal.Equipped=false;
            User.DamageMobj(shot,null,1000,'CaelumMagicTest',0,0);
            int nativeDPS=User.ElementalStatus.BurnDamagePerSecond;
            Reset();Seal.Equipped=true;
            User.DamageMobj(shot,null,1000,'CaelumMagicTest',0,0);
            Check(String.Format("native factor %.1f retains status dose",factor*0.5),User.ElementalStatus.BurnDamagePerSecond,nativeDPS);
        }
        Console.Printf("CA261 DONE failures=%d passes=%d",Failed,Passed);
    }
}
