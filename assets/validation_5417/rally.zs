// Escena aislada #248: los valores controlados no forman parte del balance.
class CA248Body : CaelumMandinga
{
    override void Tick() { }
    override void PostBeginPlay(){Super.PostBeginPlay();EnsureCombatPersonality();bBuddha=true;ResetReserves();}
    void ResetReserves()
    {
        CombatMaximumHealth=100000;health=100000;MaximumCombatAdrenaline=1000;CurrentCombatAdrenaline=0;
        EffectiveCombatEvasionChance=0;CombatAnimaRegenerationPerSecond=CombatAirRegenerationPerSecond=0;
    }
}
class CA248Caster : CaelumPlayer { override void Tick() { } }
class CA248ReactiveBody : CA248Body
{
    bool Nested;
    double BeforeNested,AfterNested,AfterGrant;
    override double ResolveActorShieldDamage(Actor inflictor,Actor source,double damage,Name mod,int flags)
    {
        CurrentCombatAdrenaline=1000;
        AfterGrant=CaelumRally.Factor(self);
        BeforeNested=RallyDamageFactor;
        if(Nested)DamageMobj(null,null,100,'CaelumElementalDOT',DMG_NO_ARMOR,0);
        AfterNested=RallyDamageFactor;
        return damage;
    }
}
class CA248Shot : CaelumActorProjectile
{
    override int DoSpecialDamage(Actor victim,int damage,Name mod) {return 300;}
    Default { +MISSILE +NOGRAVITY +NOBLOCKMAP Radius 4; Height 8; Speed 8; Damage (300); DamageType "CaelumElementalDOT"; }
    States { Spawn: BAL1 AB 4 Bright; Loop; Death: TNT1 A 1; Stop; }
}
class CA248Probe : StaticEventHandler
{
    CaelumPlayer User;
    CA248Body Ally,Enemy,Neutral,Hidden,Far;
    int Passed,Failed,Remaining,Clock,PositionChoice;
    double BeforePaid,LastReserve;
    bool Manual,Stable;
    double ShotFactor;
    String LastKind;
    int LastLoss;
    void Check(bool ok,String label)
    {if(ok)Passed++;else Failed++;Console.Printf("CA248 %s %s",ok?"PASS":"FAIL",label);}
    void Stats()
    {
        User.DerivedStats.MaximumAnima=10000;User.DerivedStats.MaximumAdrenaline=1000;
        User.DerivedStats.HealthRegenerationPerSecond=User.DerivedStats.AnimaRegenerationPerSecond=0;
        User.DerivedStats.AnimaCostReductionPercent=0;User.DerivedStats.BuffPowerPercent=100;
        User.DerivedStats.AbilityRangePercent=100;User.EffectiveEvasionChance=0;
        User.CaelumMaximumHealth=100000;User.CombatTimeRemaining=2;
    }
    CA248Body Body(vector3 pos,bool friendly)
    {let body=CA248Body(Actor.Spawn("CA248Body",pos,NO_REPLACE));body.bFriendly=friendly;return body;}
    void Clear()
    {let effect=CaelumRally.Status(User);if(effect!=null)effect.Destroy();}
    void Reset()
    {
        PositionChoice=0;Clear();CaelumClassAbilityRules.Cancel(User);CaelumSleepRules.Wake(User);
        CaelumRacialAbilityRules.Deactivate(User);User.ClassSleepCooldownRemaining=0;User.ClassSleepInputLatched=false;
        User.CharacterCreationComplete=true;User.CreationWizardOpen=false;
        User.CharacterProfile.FirstClass=CaelumConstants.CLASS_WARRIOR;
        User.CharacterProfile.SecondClass=CaelumConstants.CLASS_PRIEST;
        User.CharacterProfile.Race=CaelumConstants.RACE_HUMAN;User.ApplyCharacterProfile();
        User.LucidityPhysicalStunRemaining=User.PainImmobilizationRemaining=0;User.ForcedSleepTics=0;
        User.CurrentSleep=User.CurrentLucidity=100;User.bInvulnerable=false;User.bBuddha=true;
        User.CombatChannelModeActive=false;User.EquipmentMenuOpen=false;User.CraftingMenuOpen=false;
        User.player.ConversationNPC=null;User.player.ConversationPC=null;
        User.SetOrigin((0,0,0),false);User.Angle=0;User.Pitch=0;User.Vel=(0,0,0);
        Stats();User.CurrentAnima=5000;User.health=User.player.health=100000;User.CurrentAdrenaline=0;
        if(Ally!=null)Ally.Destroy();if(Enemy!=null)Enemy.Destroy();if(Neutral!=null)Neutral.Destroy();
        if(Hidden!=null)Hidden.Destroy();if(Far!=null)Far.Destroy();
        Ally=Body((256,160,0),true);Ally.ChangeTid(2480);
        Enemy=Body((256,-160,0),false);Neutral=Body((-256,0,0),false);Neutral.bIsMonster=false;
        Hidden=Body((768,0,0),true);Far=Body((1800,600,0),true);
        User.UpdateHealthStateEffects();User.UpdateLucidityState();Stable=true;
    }
    override void UiTick(){if(!Manual && Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();}
    override void WorldTick(){if(User!=null && Stable)Stats();}
    void Contract()
    {
        Check(CaelumClassAbilityRules.CanCast(User),"Cleric enters shared lifecycle");
        CaelumRally.Release(User);let effect=CaelumRally.Status(User);
        Check(effect!=null && effect.Revision==1 && effect.RemainingTics==350 && effect.PulseTics==35
            && effect.Power==1 && effect.Range==1280,"base power radius duration and delayed pulse");
        Check(CaelumRally.Eligible(effect,User) && CaelumRally.Eligible(effect,Ally),"caster and friendly combatant eligible");
        Check(!CaelumRally.Affected(Enemy) && !CaelumRally.Affected(Neutral),"enemy and neutral excluded");
        Check(!CaelumRally.Affected(Hidden) && !CaelumRally.Affected(Far),"real wall and distance exclude allies");
        CaelumRally.Pulse(effect);
        Check(User.CurrentAdrenaline==100 && Ally.CurrentCombatAdrenaline==100,"pulse restores ten percent of each current maximum");
        Check(Enemy.CurrentCombatAdrenaline==0 && Neutral.CurrentCombatAdrenaline==0
            && Hidden.CurrentCombatAdrenaline==0 && Far.CurrentCombatAdrenaline==0,"ineligible bars unchanged");
        User.DerivedStats.MaximumAdrenaline=2000;Ally.MaximumCombatAdrenaline=2000;
        CaelumRally.Pulse(effect);
        Check(User.CurrentAdrenaline==300 && Ally.CurrentCombatAdrenaline==300,"changed maxima determine next pulse");
        User.CurrentAdrenaline=Ally.CurrentCombatAdrenaline=1999;CaelumRally.Pulse(effect);
        Check(User.CurrentAdrenaline==2000 && Ally.CurrentCombatAdrenaline==2000,"recovery caps at each maximum");
        Stats();Ally.ResetReserves();User.CurrentAdrenaline=0;
        CaelumSurvivalInstinct.Release(User);CaelumRally.Pulse(effect);
        Check(User.CurrentAdrenaline==300 && Ally.CurrentCombatAdrenaline==100,"Survival Instinct amplifies Rally gain once");
        CaelumSurvivalInstinct.Status(User).Destroy();
        User.CurrentAdrenaline=0;Check(CaelumRally.Factor(User)==1,"empty bar base factor one");
        User.CurrentAdrenaline=500;Check(CaelumRally.Factor(User)==1.5,"half bar base factor one point five");
        User.CurrentAdrenaline=1000;Check(CaelumRally.Factor(User)==2,"full bar base factor two");
        Ally.CurrentCombatAdrenaline=500;Check(CaelumRally.Factor(Ally)==1.5,"ally uses own bar not caster bar");
        Ally.SetOrigin((1800,-600,0),false);Far.SetOrigin((256,160,0),false);
        Check(CaelumRally.Factor(Ally)==1 && CaelumRally.Affected(Far),"damage membership changes immediately on crossing range");
        User.SetOrigin((1600,0,0),false);
        Check(CaelumRally.Factor(Ally)==1.5 && !CaelumRally.Affected(Far),"area moves with caster");User.SetOrigin((0,0,0),false);
        Far.SetOrigin((768,0,0),false);Check(!CaelumRally.Affected(Far),"wall immediately removes damage benefit");
        Far.SetOrigin((256,160,0),false);Far.CurrentCombatAdrenaline=500;
        effect.PulseTics=17;effect.RemainingTics=900;User.DerivedStats.BuffPowerPercent=200;User.DerivedStats.AbilityRangePercent=200;
        CaelumRally.Release(User);
        Check(effect.Power==2 && effect.Range==2560 && effect.RemainingTics==900 && effect.PulseTics==17,"renewal retains longer duration and pulse phase with new power range");
        Check(CaelumRally.Factor(Far)==3,"Empathy scales whole factor");
        User.DerivedStats.BuffPowerPercent=300;CaelumRally.Release(User);
        Check(effect.RemainingTics==1050 && effect.Power==3,"Empathy extends new duration");Stats();
        effect.Power=1;effect.Range=1280;
        let second=CA248Caster(Actor.Spawn("CA248Caster",(0,64,0),NO_REPLACE));second.bFriendly=true;
        let stronger=CaelumRallyEffect(second.GiveInventoryType("CaelumRallyEffect"));
        stronger.Revision=1;stronger.RemainingTics=350;stronger.PulseTics=35;stronger.Range=1280;stronger.Power=2;
        Far.CurrentCombatAdrenaline=0;CaelumRally.Pulse(effect);CaelumRally.Pulse(stronger);
        Check(Far.CurrentCombatAdrenaline==200 && CaelumRally.Factor(Far)==2.4,"only strongest area supplies pulse and full damage factor");
        stronger.Destroy();second.Destroy();Check(CaelumRally.Factor(Far)==1.2,"weaker area resumes when strongest ends");
        Clear();Check(CaelumRally.Factor(User)==1 && CaelumRally.Factor(Far)==1,"cleanup leaves no modifiers");
    }
    int Hurt(Actor victim,Actor source,int amount,Name mod,int flags=0)
    {
        victim.health=100000;let u=CaelumPlayer(victim);if(u!=null)u.player.health=100000;
        int result=victim.DamageMobj(source,source,amount,mod,flags|DMG_THRUSTLESS,0);
        Console.Printf("CA248 DAMAGE %s %s result=%d loss=%d",victim.GetClassName(),mod,result,100000-victim.health);
        return 100000-victim.health;
    }
    void Damage()
    {
        Clear();int baseline=Hurt(Enemy,User,300,'CaelumElementalDOT');
        CaelumRally.Release(User);User.CurrentAdrenaline=500;
        int boosted=Hurt(Enemy,User,300,'CaelumElementalDOT');
        Check(baseline==300 && boosted==450,"outgoing periodic damage uses current attacker half bar");
        User.CurrentAdrenaline=1000;Check(Hurt(Enemy,User,300,'CaelumElementalDOT')==600,"existing periodic effect follows changing bar");
        User.CurrentAdrenaline=500;Check(Hurt(User,Enemy,300,'CaelumElementalDOT')==200,"incoming periodic damage divides final damage");
        User.CurrentAdrenaline=500;Check(Hurt(User,User,300,'CaelumImpact')==200,"self environmental collision only divides");
        User.CurrentAdrenaline=500;Check(Hurt(User,null,300,'Drowning')==200,"unowned environmental hazard divides");
        User.CurrentAdrenaline=500;Check(Hurt(User,Enemy,300,'CaelumElementalDOT',DMG_FORCED)==200,"forced native bypass scales exactly once");
        Ally.CurrentCombatAdrenaline=1000;User.CurrentAdrenaline=500;
        Check(Hurt(Ally,User,300,'CaelumElementalDOT')==225,"attacker and target each use their own pre-hit bar once");
        Clear();Enemy.ResetReserves();baseline=Hurt(Enemy,User,2000,'Melee');
        CaelumRally.Release(User);User.CurrentAdrenaline=500;Enemy.ResetReserves();
        boosted=Hurt(Enemy,User,2000,'Melee');
        Check(baseline>0 && boosted==int(baseline*1.5+0.5),"physical damage multiplied after target Toughness");
        Clear();Enemy.ResetReserves();baseline=Hurt(Enemy,User,2000,'Fire');
        CaelumRally.Release(User);User.CurrentAdrenaline=500;Enemy.ResetReserves();
        boosted=Hurt(Enemy,User,2000,'Fire');
        Check(baseline>0 && boosted==int(baseline*1.5+0.5),"magical damage multiplied after target defenses");
        Check(User.RallyDamageFactor==0 && Enemy.RallyDamageFactor==0,"synchronous factors restore after calls");
    }
    void Cadence(){Clear();Ally.ResetReserves();CaelumRally.Release(User);}
    void Advanced()
    {
        Clear();User.Attributes.Toughness=0;User.ArmorModel=new("CaelumArmorModel");User.ArmorModel.InitializeDefaults();
        User.ShieldModel.Equipped=false;User.WeaponModel.Equipped=false;User.CombatBlockModeActive=false;
        let seal=CaelumEquipmentItem(Actor.Spawn("CaelumSealPickup",User.Pos,NO_REPLACE));
        seal.PickupDataInitialized=true;seal.AcquisitionResolved=true;
        seal.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_SEAL;seal.Tier=1;seal.ItemType=0;seal.Equipped=true;seal.AttachToOwner(User);
        Stats();User.Attributes.Toughness=0;
        let shot=CaelumActorProjectile(Actor.Spawn("CaelumActorProjectile",(64,0,40),NO_REPLACE));
        shot.Target=Enemy;shot.StoreCaelumAttackResult(1000,true,false,true,0);
        shot.StoreCaelumElementalPayload(0,false,100,100);
        User.ElementalStatus=new("CaelumElementalStatus");User.health=User.player.health=100000;
        User.DamageMobj(shot,Enemy,1000,'CaelumMagicTest',0,0);
        int baseline=100000-User.health,rate=User.ElementalStatus.BurnDamagePerSecond;
        CaelumRally.Release(User);User.CurrentAdrenaline=500;User.ElementalStatus=new("CaelumElementalStatus");
        User.health=User.player.health=100000;User.DamageMobj(shot,Enemy,1000,'CaelumMagicTest',0,0);
        Console.Printf("CA248 PAYLOAD base=%d loss=%d rate=%d newrate=%d factor=%.5f anima=%.1f health=%d",baseline,100000-User.health,rate,User.ElementalStatus.BurnDamagePerSecond,CaelumRally.Factor(User),User.CurrentAnima,User.health);
        Check(baseline>0 && 100000-User.health==int(baseline/1.5+0.5),"native fire seal then Rally final division");
        Check(rate>0 && User.ElementalStatus.BurnDamagePerSecond==rate,"initial protected hit does not bake Rally into burn dose");
        User.CurrentAdrenaline=500;User.health=User.player.health=100000;
        for(int i=0;i<TICRATE;i++)User.ElementalStatus.TickDamageOverTime(User);
        Console.Printf("CA248 BURN loss=%d expected=%d remaining=%.3f rate=%d",100000-User.health,int(int(rate*0.5)/1.5+0.5),User.ElementalStatus.BurnRemaining,User.ElementalStatus.BurnDamagePerSecond);
        Check(100000-User.health==int(int(rate*0.5)/1.5+0.5),"burn pulse applies seal and current Rally once");
        User.ElementalStatus=new("CaelumElementalStatus");seal.Destroy();shot.Destroy();
        User.CurrentAdrenaline=500;User.DamageFactor=0.5;
        Check(Hurt(User,Enemy,300,'CaelumElementalDOT')==100,"native DamageFactor resolves before Rally");User.DamageFactor=1;
        Ally.CurrentCombatAdrenaline=1000;
        CaelumSleepRules.Apply(Ally,350,true,1);
        Check(Hurt(Ally,Enemy,100,'CaelumElementalDOT')==150,"Sleep multiplication and Rally division compose once");CaelumSleepRules.Wake(Ally);
        let reactive=CA248ReactiveBody(Actor.Spawn("CA248ReactiveBody",(160,256,0),NO_REPLACE));reactive.bFriendly=true;
        reactive.ResetReserves();
        reactive.CurrentCombatAdrenaline=0;
        int first=Hurt(reactive,Enemy,2000,'Melee');
        Console.Printf("CA248 REACTIVE before=%.6f after=%.6f adrenaline=%.6f maximum=%.6f",reactive.BeforeNested,reactive.AfterNested,reactive.CurrentCombatAdrenaline,reactive.MaximumCombatAdrenaline);
        Check(first>0 && reactive.BeforeNested==1 && reactive.AfterNested==1 && reactive.AfterGrant==2,"hit captures bar before shield callback grants Adrenaline");
        reactive.ResetReserves();reactive.Nested=true;
        int nested=Hurt(reactive,Enemy,2000,'Melee');
        Check(nested==first+50 && reactive.BeforeNested==1 && reactive.AfterNested==1 && reactive.RallyDamageFactor==0,"nested hit uses new bar then restores outer captured factor");reactive.Destroy();
        let dummy=Actor.Spawn("CaelumTrainingDummy",(-128,256,0),NO_REPLACE);User.CurrentAdrenaline=500;
        Check(Hurt(dummy,User,300,'CaelumElementalDOT')==450,"training target receives outgoing factor");dummy.Destroy();
        let gate=CaelumBreakableGate(Actor.Spawn("CaelumBreakableGate",(-500,512,0),NO_REPLACE));
        gate.InitializeGate();gate.StructuralMaximum=gate.health=100000;Clear();
        baseline=gate.DamageMobj(User,User,300,'CaelumElementalDOT',0,0);
        CaelumRally.Release(User);User.CurrentAdrenaline=500;
        int boosted=gate.DamageMobj(User,User,300,'CaelumElementalDOT',0,0);
        Check(baseline==300 && boosted==450,"destructible structure receives final outgoing factor");
        gate.Destroy();
    }
    void Flight()
    {
        Clear();Enemy.ResetReserves();Enemy.SetOrigin((320,0,0),false);Ally.SetOrigin((256,256,0),false);
        let shot=CA248Shot(Actor.Spawn("CA248Shot",(48,0,40),NO_REPLACE));shot.Target=User;shot.Vel=(8,0,0);
        Check(!CaelumRally.Active(User),"native projectile launched before Rally");
    }
    void ManualDamage(bool incoming)
    {
        Actor victim=incoming?Actor(User):Actor(Enemy),source=incoming?Actor(Enemy):Actor(User);
        ShotFactor=CaelumRally.DamageFactor(victim,source);
        LastLoss=Hurt(victim,source,300,'CaelumElementalDOT');
        LastKind=incoming?"Recibido":"Causado";
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        User=CaelumPlayer(players[e.Player].mo);if(User==null)return;
        if(e.Name=="c248_setup")Reset();
        if(e.Name=="c248_contract")Contract();
        if(e.Name=="c248_damage")Damage();
        if(e.Name=="c248_advanced")Advanced();
        if(e.Name=="c248_flight")Flight();
        if(e.Name=="c248_midflight"){CaelumRally.Release(User);User.CurrentAdrenaline=500;}
        if(e.Name=="c248_flight_check")
        {Console.Printf("CA248 FLIGHT loss=%d factor=%.5f bar=%.5f max=%.5f",100000-Enemy.health,CaelumRally.Factor(User),User.CurrentAdrenaline,User.DerivedStats.MaximumAdrenaline);
            Check(100000-Enemy.health==450,"native in-flight projectile gains live post-launch Rally");}
        if(e.Name=="c248_cadence")Cadence();
        if(e.Name=="c248_before")Check(Ally.CurrentCombatAdrenaline==0,"no pulse before one second");
        if(e.Name=="c248_first")Check(Ally.CurrentCombatAdrenaline==100,"first native pulse at one second");
        if(e.Name=="c248_tenth")Check(Ally.CurrentCombatAdrenaline==1000 && !CaelumRally.Active(User),"ten pulses include final second then expire");
        if(e.Name=="c248_after")Check(Ally.CurrentCombatAdrenaline==1000,"no pulse after expiry");
        if(e.Name=="c248_partial")Check(User.ClassCastActive && User.ClassCastPaid>0 && User.ClassCastPaid<1000 && User.ClassSleepCooldownRemaining==0,"native preparation pays progressively without reuse");
        if(e.Name=="c248_cancel")Check(!User.ClassCastActive && !CaelumRally.Active(User) && User.CurrentAnima<5000 && User.ClassSleepCooldownRemaining==0,"second press cancels without refund or effect");
        if(e.Name=="c248_release")Check(CaelumRally.Active(User) && !User.ClassCastActive && User.ClassCastPaid==1000 && User.ClassSleepCooldownRemaining>59,"native release starts one effect after full payment");
        if(e.Name=="c248_save"){Cadence();Check(CaelumRally.Active(User),"active area prepared for save between pulses");}
        if(e.Name=="c248_loaded")
        {
            Stable=true;Ally=CA248Body(ActorIterator.Create(2480).Next());let effect=CaelumRally.Status(User);
            Check(effect!=null && effect.Revision==1 && effect.PulseTics>0 && effect.PulseTics<35 && Ally.CurrentCombatAdrenaline==0,"load preserves area and phase without early pulse");
            Remaining=effect.RemainingTics;Clock=effect.PulseTics;LastReserve=Ally.CurrentCombatAdrenaline;BeforePaid=User.ClassCastPaid;
        }
        if(e.Name=="c248_clock")
        {let effect=CaelumRally.Status(User);Check(Remaining-effect.RemainingTics==35 && Clock==effect.PulseTics && Ally.CurrentCombatAdrenaline==LastReserve+100 && User.ClassCastPaid==BeforePaid,"loaded second advances once with no repayment");}
        if(e.Name=="c248_hub")Check(CaelumRally.Active(User) && CaelumRally.Status(User).Power==1,"hub retains area power and clock");
        if(e.Name=="c248_expired")Check(!CaelumRally.Active(User),"native expiry removes area");
        if(e.Name=="c248_dead"){CaelumRally.Release(User);User.health=0;Check(!CaelumRally.Affected(Ally),"caster death immediately disables benefits");}
        if(e.Name=="c248_manual"){Reset();Manual=true;LastKind="Sin golpe";LastLoss=0;ShotFactor=1;}
        if(e.Name=="c248_position"){PositionChoice=1-PositionChoice;Ally.SetOrigin(PositionChoice?(1800,600,0):(256,160,0),false);}
        if(e.Name=="c248_occlusion")Ally.SetOrigin((768,0,0),false);
        if(e.Name=="c248_incoming")ManualDamage(true);
        if(e.Name=="c248_outgoing")ManualDamage(false);
        if(e.Name=="c248_halfbar")User.CurrentAdrenaline=500;
        if(e.Name=="c248_manual_check")Check(CaelumRally.Active(User) && Ally.CurrentCombatAdrenaline>0 && Enemy.CurrentCombatAdrenaline==0 && Hidden.CurrentCombatAdrenaline==0,"manual native cast restores visible ally only");
        if(e.Name=="c248_done")Console.Printf("CA248 DONE failures=%d passed=%d",Failed,Passed);
    }
    override void RenderOverlay(RenderEvent e)
    {
        let user=CaelumPlayer(players[consoleplayer].mo);if(!Manual || user==null)return;
        let effect=CaelumRally.Status(user);
        String line=String.Format("ARENGA | Efecto %.1fs | Reutilizacion %.1fs | F lanzar/cancelar | F6 reiniciar",
            effect==null?0:effect.RemainingTics/35.0,user.ClassSleepCooldownRemaining);
        Screen.DrawText(SmallFont,Font.CR_WHITE,88,8,line,DTA_VIRTUALWIDTHF,640.0,DTA_VIRTUALHEIGHTF,360.0);
        line=String.Format("Tu adrenalina: %.0f/1000 | Aliado: %.0f/1000 | Enemigo: %.0f/1000",
            user.CurrentAdrenaline,Ally==null?0:Ally.CurrentCombatAdrenaline,Enemy==null?0:Enemy.CurrentCombatAdrenaline);
        Screen.DrawText(SmallFont,Font.CR_WHITE,88,20,line,DTA_VIRTUALWIDTHF,640.0,DTA_VIRTUALHEIGHTF,360.0);
        line=String.Format("Ultimo golpe %s | Base 300 | Factor aplicado %.2f | Salud perdida %d",LastKind,ShotFactor,LastLoss);
        Screen.DrawText(SmallFont,Font.CR_WHITE,88,32,line,DTA_VIRTUALWIDTHF,640.0,DTA_VIRTUALHEIGHTF,360.0);
        Screen.DrawText(SmallFont,Font.CR_WHITE,88,44,"F7 aliado dentro/fuera | F10 aliado tras pared | F8 recibir golpe | F9 causar golpe | F11 barra al 50%",
            DTA_VIRTUALWIDTHF,640.0,DTA_VIRTUALHEIGHTF,360.0);
    }
}
