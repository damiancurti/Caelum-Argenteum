// #244: valores fijados sólo para ensayos reproducibles del consumidor real.
class CA244Body : CaelumCombatActor
{
    override void Tick(){Vel=(0,0,0);Super.Tick();}
    Default { Radius 16; Height 96; Mass 100; Health 100000; +SOLID +SHOOTABLE +NOGRAVITY +ISMONSTER }
    States { Spawn: TNT1 A -1; Stop; }
}
class CA244Equipment : CA259Session
{override int Kind(){return Choice==9?CaelumConstants.WEAPON_TYPE_JAVELIN:Super.Kind();}}
class CA244ManualBody : CaelumMandinga
{
    override void Tick() { }
    override void PostBeginPlay(){Super.PostBeginPlay();health=CombatMaximumHealth=100000;bBuddha=true;}
}
class CA244Probe : StaticEventHandler
{
    CaelumPlayer User;
    CA244Body Body;
    CA244Equipment Equipment;
    int Passed,Failed,Shots,Remaining;
    bool Watching,Manual;
    Array<Actor> Seen;
    double BasePhysical,BaseMagic,BaseEvasion,BaseAccuracy,BaseChance,BeforeAnima;
    double ShotChance,ShotDamage,ExpectedMultiplier;
    CA244ManualBody ManualBody;
    void Check(bool ok,String label)
    {if(ok)Passed++;else Failed++;Console.Printf("CA244 %s %s",ok?"PASS":"FAIL",label);}
    void Stats()
    {
        User.DerivedStats.AnimaRegenerationPerSecond=0;User.DerivedStats.MaximumAnima=10000;
        User.DerivedStats.HealthRegenerationPerSecond=0;
        User.DerivedStats.AnimaCostReductionPercent=0;User.DerivedStats.BuffPowerPercent=100;
        User.DerivedStats.PhysicalAccuracyPercent=User.DerivedStats.MagicalAccuracyPercent=100;
        User.DerivedStats.PhysicalCriticalChance=User.DerivedStats.MagicalCriticalChance=15;
        User.DerivedStats.BaseEvasionChance=10;User.DerivedStats.MaximumAdrenaline=10000;
    }
    void Clear()
    {let effect=CaelumSurvivalInstinct.Status(User);if(effect!=null)effect.Destroy();}
    void Refresh()
    {User.UpdateLucidityAccuracyEffects();User.UpdateAirStateEffects();}
    void Reset()
    {
        Clear();CaelumClassAbilityRules.Cancel(User);CaelumSleepRules.Wake(User);CaelumRacialAbilityRules.Deactivate(User);
        User.ClassSleepCooldownRemaining=0;User.ClassSleepInputLatched=false;
        User.CharacterCreationComplete=true;User.CreationWizardOpen=false;
        User.CharacterProfile.FirstClass=User.CharacterProfile.SecondClass=CaelumConstants.CLASS_EXPLORER;
        User.CharacterProfile.Race=CaelumConstants.RACE_BEAST_MAN;User.ApplyCharacterProfile();
        User.LucidityPhysicalStunRemaining=User.PainImmobilizationRemaining=0;
        User.ForcedSleepTics=0;User.CurrentSleep=100;User.CurrentLucidity=100;
        User.health=User.CaelumMaximumHealth;User.player.health=User.health;User.bInvulnerable=true;User.bBuddha=true;
        User.CombatChannelModeActive=false;User.EquipmentMenuOpen=false;User.CraftingMenuOpen=false;
        User.player.ConversationNPC=null;User.player.ConversationPC=null;
        User.SetOrigin((0,0,0),false);User.Angle=0;User.Pitch=0;User.Vel=(0,0,0);
        Stats();User.CurrentAnima=1000;User.CurrentAir=User.DerivedStats.MaximumAir;User.CurrentAdrenaline=0;
        User.HealthPerformanceMultiplier=User.AirStatePerformanceMultiplier=1;
        if(Body!=null)Body.Destroy();Body=CA244Body(Actor.Spawn("CA244Body",(256,0,0),NO_REPLACE));Body.ChangeTid(2440);
        Refresh();
    }
    override void UiTick(){if(!Manual && Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();}
    override void WorldTick()
    {
        if(User==null)return;Stats();
        if(!Watching)return;
        let it=ThinkerIterator.Create("CaelumActorProjectile");CaelumActorProjectile shot;
        while((shot=CaelumActorProjectile(it.Next()))!=null)
            if(shot.Target==User && Seen.Find(shot)>=Seen.Size())
            {Seen.Push(shot);Shots++;ShotChance=shot.CaelumCriticalBaseChance;ShotDamage=shot.Damage;}
    }
    void Arm(int choice)
    {
        Clear();if(Equipment==null)Equipment=new("CA244Equipment");Equipment.Choice=choice;Equipment.Tier=1;Equipment.Equip(User);
        Stats();User.CurrentAnima=10000;User.CurrentAir=User.DerivedStats.MaximumAir;Refresh();
        User.SetRangedMagazineCount(Equipment.Kind(),User.GetRangedMagazineCapacity(Equipment.Kind()));
        bool magical=User.WeaponModel.IsMagicalType(Equipment.Kind());
        BaseChance=magical?User.MagicalCriticalChanceFor(Equipment.Kind())
            :User.PhysicalCriticalChanceFor(CaelumCraftingRules.GetCatalogueWeaponForPlayableType(Equipment.Kind()),User.IsRangedWeaponType(Equipment.Kind()));
        ExpectedMultiplier=1;Observe();
    }
    void Observe()
    {
        let it=ThinkerIterator.Create("CaelumActorProjectile");Actor shot;
        while((shot=Actor(it.Next()))!=null)if(shot.Target==User)shot.Destroy();
        Seen.Clear();Shots=0;ShotChance=ShotDamage=0;Watching=true;
        User.CurrentAnima=10000;User.CurrentAir=User.DerivedStats.MaximumAir;
        if(Equipment!=null)User.SetRangedMagazineCount(Equipment.Kind(),User.GetRangedMagazineCapacity(Equipment.Kind()));
    }
    void Contract()
    {
        Arm(0);Check(CaelumClassAbilityRules.CanCast(User),"Explorer uses shared class admission");
        Check(!CaelumClassAbilityRules.Offensive(CaelumConstants.PROFESSION_EXPLORER),"self benefit is not an attack");
        Refresh();BaseEvasion=User.EffectiveEvasionChance;BaseAccuracy=User.EffectivePhysicalAccuracyPercent;
        BasePhysical=User.PhysicalCriticalChanceFor(CaelumConstants.CATALOGUE_WEAPON_SWORD);BaseMagic=User.MagicalCriticalChanceFor(CaelumConstants.WEAPON_TYPE_STAFF);
        CaelumSurvivalInstinct.Release(User);Refresh();let effect=CaelumSurvivalInstinct.Status(User);
        Check(effect!=null && effect.Revision==1 && effect.RemainingTics==350 && effect.Multiplier==3,"base effect stores ten seconds and factor three");
        Check(Abs(User.EffectiveEvasionChance-BaseEvasion*3)<1e-6,"evasion multiplies current penalties and personality");
        Check(User.EffectivePhysicalAccuracyPercent==BaseAccuracy*3 && User.EffectiveMagicalAccuracyPercent==300,"both accuracy consumers receive factor");
        Check(User.PhysicalCriticalChanceFor(CaelumConstants.CATALOGUE_WEAPON_SWORD)==Min(100,BasePhysical*3)
            && User.MagicalCriticalChanceFor(CaelumConstants.WEAPON_TYPE_STAFF)==Min(100,BaseMagic*3),"physical and magical critical chance scale before limits");
        Check(User.DerivedStats.PhysicalAccuracyPercent==100 && User.DerivedStats.PhysicalCriticalChance==15,"saved derived base values remain unchanged");
        User.CrouchCriticalChanceMultiplier=2;
        Check(User.MagicalCriticalChanceFor(CaelumConstants.WEAPON_TYPE_STAFF)==Min(100,BaseMagic*6),"posture composes with effect");User.CrouchCriticalChanceMultiplier=1;
        Check(CaelumRacialAbilityRules.Begin(User),"Hunter racial can coexist with class effect");
        CaelumRacialAbilityRules.Advance(User);
        Body.Angle=0;
        Check(CaelumHuntersInstinct.Chance(User,Body,User.MagicalCriticalChanceFor(CaelumConstants.WEAPON_TYPE_STAFF))==Min(100,BaseMagic*9),"rear racial composes with current boosted chance");
        CaelumRacialAbilityRules.Deactivate(User);
        double before=User.DerivedStats.PhysicalCriticalChance;User.DerivedStats.PhysicalCriticalChance=1000;
        Check(User.PhysicalCriticalChanceFor(CaelumConstants.CATALOGUE_WEAPON_SWORD)==100,"critical chance retains cap");User.DerivedStats.PhysicalCriticalChance=before;
        User.CurrentAdrenaline=0;User.AddAdrenaline(10);Check(User.CurrentAdrenaline==30,"other ability gains receive factor once");
        User.AddAdrenaline(10,false);Check(User.CurrentAdrenaline==40,"explicit tutorial reserve bypasses effect");
        User.CurrentAdrenaline=0;User.HealthAdrenalineGainMultiplier=1;
        double expected=10*User.HealthAdrenalineGainMultiplier*CaelumPersonalityRules.Adrenaline(User)*3;
        User.AddCombatAdrenaline(10);Check(expected>0 && Abs(User.CurrentAdrenaline-expected)<1e-6 && User.LastAdrenalineFinalGain==expected,"combat gain composes once with health and personality");
        User.CurrentAdrenaline=9999;User.AddAdrenaline(10);Check(User.CurrentAdrenaline==10000,"resource maximum remains authoritative");
        User.DerivedStats.BuffPowerPercent=200;CaelumSurvivalInstinct.Release(User);effect=CaelumSurvivalInstinct.Status(User);
        Check(effect.Multiplier==6 && effect.RemainingTics==700,"Empathy scales entire factor and duration");Stats();
        Check(CaelumSurvivalInstinct.Multiplier(User)==6,"release-time potency is retained independently of current stats");
        CaelumSurvivalInstinct.Release(User);effect=CaelumSurvivalInstinct.Status(User);
        Check(effect.Multiplier==3 && effect.RemainingTics==700,"renewal uses new potency but keeps longer remaining duration");
        User.DerivedStats.BuffPowerPercent=300;CaelumSurvivalInstinct.Release(User);
        Check(effect.Multiplier==9 && effect.RemainingTics==1050,"longer renewal replaces duration without adding factors or clocks");Stats();
        Clear();Refresh();Check(User.EffectivePhysicalAccuracyPercent==100 && Abs(User.EffectiveEvasionChance-BaseEvasion)<1e-6,"ending effect restores ordinary values without division drift");
        CaelumSurvivalInstinct.Release(User);User.LucidityPhysicalStunRemaining=1;
        Check(User.IsPhysicallyImmobilized(),"ability grants no old negative-state immunity");User.LucidityPhysicalStunRemaining=0;
        User.bInvulnerable=false;User.EffectiveEvasionChance=300;int hp=User.health;
        User.DamageMobj(Body,Body,10,'CaelumMeleeTest',0,0);
        Check(User.LastEvasionAttempted && User.LastEvasionSucceeded && User.LastEvasionChancePercent==100 && User.health==hp,"actual damage receiver caps and applies evasion");User.bInvulnerable=true;
        Clear();
    }
    void Combinations()
    {
        Arm(0);let record=User.GetPersistentCharacterState(true);CaelumTarotService.EnsureRevision(record);
        for(int i=0;i<CaelumConstants.TAROT_CARD_COUNT;i++){record.TarotSelected[i]=false;record.TarotActive[i]=false;}
        int card=CaelumConstants.TAROT_MAJOR_COUNT;
        record.TarotOwned[card]=true;record.TarotSelected[card]=true;record.TarotEffectTics=record.TarotCooldownTics=0;
        Check(CaelumTarotService.Activate(User),"real minor Tarot activates before class buff");
        double physical=User.DerivedStats.PhysicalAccuracyPercent,magical=User.DerivedStats.MagicalAccuracyPercent;
        double expected=3*CaelumClassAbilityRules.BeneficialPower(User);
        CaelumSurvivalInstinct.Release(User);Refresh();
        Check(Abs(User.EffectivePhysicalAccuracyPercent-physical*expected)<1e-6
            && Abs(User.EffectiveMagicalAccuracyPercent-magical*expected)<1e-6,"class factor composes with real Tarot-derived precision");
        Clear();Refresh();Check(User.EffectivePhysicalAccuracyPercent==physical && record.TarotEffectTics>0,"class expiry leaves Tarot contribution intact");
        CaelumTarotService.Advance(User,record.TarotEffectTics);Stats();
        for(int choice=0;choice<3;choice++)
        {
            for(int i=0;i<4;i++)User.CharacterProfile.Personality[i]=choice;User.CharacterProfile.PersonalityRevision=1;
            Clear();Refresh();double evasion=User.EffectiveEvasionChance;
            double chance=User.MagicalCriticalChanceFor(CaelumConstants.WEAPON_TYPE_STAFF);
            CaelumSurvivalInstinct.Release(User);Refresh();
            Check(Abs(User.EffectiveEvasionChance-evasion*3)<1e-6 && User.MagicalCriticalChanceFor(CaelumConstants.WEAPON_TYPE_STAFF)==Min(100,chance*3),"personality alternatives compose without replacing their factors");
        }
        Clear();
    }
    void ManualReset()
    {
        Manual=true;Reset();Arm(0);User.CurrentAnima=10000;
        User.health=User.CaelumMaximumHealth/2;User.player.health=User.health;User.UpdateHealthStateEffects();
        Body.SetOrigin((768,768,0),false);
        if(ManualBody!=null)ManualBody.Destroy();
        ManualBody=CA244ManualBody(Actor.Spawn("CA244ManualBody",(256,0,0),NO_REPLACE));
        ManualBody.Angle=180;Watching=false;
        Console.Printf("CA244 MANUAL ready");
    }
    int DamageHit(bool magic,int mode)
    {
        Clear();double ordinary=magic?User.MagicalCriticalChanceFor(CaelumConstants.WEAPON_TYPE_STAFF)
            :User.PhysicalCriticalChanceFor(CaelumConstants.CATALOGUE_WEAPON_CARBINE,true);
        if(mode==1)CaelumSurvivalInstinct.Release(User);
        double chance=magic?User.MagicalCriticalChanceFor(CaelumConstants.WEAPON_TYPE_STAFF)
            :User.PhysicalCriticalChanceFor(CaelumConstants.CATALOGUE_WEAPON_CARBINE,true);
        if(mode==2)chance=100;
        double roll=Min(99.0,ordinary*2);
        let victim=CA244Body(Actor.Spawn("CA244Body",(512,512,0),NO_REPLACE));
        let shot=CaelumActorProjectile(Actor.Spawn(magic?"CaelumPlayerMagicProjectile":"CaelumCarbineProjectile",victim.Pos+(-8,0,48),NO_REPLACE));
        shot.Target=User;shot.StoreCaelumAttackResult(100,true,roll<chance,magic,0);shot.StoreCaelumCriticalRoll(chance,roll);
        Clear();int hp=victim.health;victim.DamageMobj(shot,User,100,magic?'CaelumMagicTest':'CaelumRangedTest',DMG_THRUSTLESS,0);
        int loss=hp-victim.health;shot.Destroy();victim.Destroy();return loss;
    }
    void DamageContracts()
    {
        Arm(0);
        for(int magic=0;magic<2;magic++)
        {
            int ordinary=DamageHit(magic!=0,0),boosted=DamageHit(magic!=0,1),certain=DamageHit(magic!=0,2);
            Console.Printf("CA244 DAMAGE magic=%d ordinary=%d boosted=%d certain=%d",magic,ordinary,boosted,certain);
            Check(boosted>ordinary && boosted==certain,"boosted launch retains ordinary critical damage after effect ends");
        }
        Arm(4);Body.SetOrigin((56,0,0),false);Body.Angle=180;
        User.DerivedStats.PhysicalAccuracyPercent=100000;User.UpdateLucidityAccuracyEffects();
        User.PerformDebugSwordAttack(false,false);
        double chance=User.LastMeleeCriticalChancePercent,accuracy=User.LastMeleeAccuracyPercent;
        CaelumSurvivalInstinct.Release(User);User.PerformDebugSwordAttack(false,false);
        Check(User.LastMeleeCriticalChancePercent==Min(100,chance*3) && Abs(User.LastMeleeAccuracyPercent-accuracy*3)<1e-6,"actual sword consumer combines accuracy and critical multipliers");
    }
    override void RenderOverlay(RenderEvent e)
    {
        let user=CaelumPlayer(players[consoleplayer].mo);if(!Manual || user==null)return;
        let effect=CaelumSurvivalInstinct.Status(user);
        String line=String.Format("Instinto x%.1f | Efecto %.1fs | Reutilizacion %.1fs | Anima %.0f",
            CaelumSurvivalInstinct.Multiplier(user),effect==null?0:effect.RemainingTics/35.0,user.ClassSleepCooldownRemaining,user.CurrentAnima);
        Screen.DrawText(SmallFont,Font.CR_WHITE,88,8,line,DTA_VIRTUALWIDTHF,640.0,DTA_VIRTUALHEIGHTF,360.0);
        line=String.Format("Precision F/M: %.0f / %.0f | Critico F/M: %.1f / %.1f | Evasion %.1f%%",
            user.EffectivePhysicalAccuracyPercent,user.EffectiveMagicalAccuracyPercent,user.HUDPhysicalCriticalChance,user.HUDMagicalCriticalChance,Clamp(user.EffectiveEvasionChance,0,100));
        Screen.DrawText(SmallFont,Font.CR_WHITE,88,20,line,DTA_VIRTUALWIDTHF,640.0,DTA_VIRTUALHEIGHTF,360.0);
        line=String.Format("F lanzar/cancelar | F6 reiniciar | F7 ganar Adrenalina | F8 arma | F9 golpe");
        Screen.DrawText(SmallFont,Font.CR_WHITE,88,32,line,DTA_VIRTUALWIDTHF,640.0,DTA_VIRTUALHEIGHTF,360.0);
        line=String.Format("Ganancia: %.1f | Ultima esquiva: %.1f%% (%s) | Ensayo: valores base fijos, sin regeneracion",
            user.LastAdrenalineFinalGain,user.LastEvasionChancePercent,user.LastEvasionSucceeded?"SI":"NO");
        Screen.DrawText(SmallFont,Font.CR_WHITE,88,44,line,DTA_VIRTUALWIDTHF,640.0,DTA_VIRTUALHEIGHTF,360.0);
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        User=CaelumPlayer(players[e.Player].mo);if(User==null)return;
        if(e.Name=="c244_setup")Reset();
        if(e.Name=="c244_manual")ManualReset();
        if(e.Name=="c244_gain")User.AddCombatAdrenaline(10);
        if(e.Name=="c244_weapon")
        {
            double reserve=User.CurrentAnima;
            Equipment.Choice=Equipment.Choice==0?5:0;Equipment.Equip(User);Stats();User.CurrentAnima=reserve;
            User.SetRangedMagazineCount(Equipment.Kind(),User.GetRangedMagazineCapacity(Equipment.Kind()));Watching=false;
        }
        if(e.Name=="c244_hit")
        {
            int hp=User.health;User.bInvulnerable=false;User.DamageMobj(Body,Body,10,'CaelumMeleeTest',0,0);User.bInvulnerable=true;
            User.health=hp;User.player.health=hp;User.UpdateHealthStateEffects();
            User.LucidityPhysicalStunRemaining=User.PainImmobilizationRemaining=0;
        }
        if(e.Name=="c244_manual_check")
        {
            Check(CaelumSurvivalInstinct.Multiplier(User)==3 && User.EffectivePhysicalAccuracyPercent==300
                && User.EffectiveMagicalAccuracyPercent==300,"manual native release exposes both boosted precision values");
            double gain=10*User.HealthAdrenalineGainMultiplier*CaelumPersonalityRules.Adrenaline(User)*3;
            User.AddCombatAdrenaline(10);Check(gain>0 && User.LastAdrenalineFinalGain==gain,"manual gain uses actual combat consumer");
        }
        if(e.Name=="c244_contract")Contract();
        if(e.Name=="c244_combinations")Combinations();
        if(e.Name=="c244_damage")DamageContracts();
        if(e.Name=="c244_arm")Arm(e.Args[0]);
        if(e.Name=="c244_on"){CaelumSurvivalInstinct.Release(User);ExpectedMultiplier=3;Observe();}
        if(e.Name=="c244_off"){Clear();ExpectedMultiplier=1;Observe();}
        if(e.Name=="c244_shots")
        {
            bool magical=User.WeaponModel.IsMagicalType(Equipment.Kind());
            double accuracy=magical?User.LastStaffAccuracyPercent:User.LastCarbineAccuracyPercent;
            if(Equipment.Choice==9)accuracy=User.EffectivePhysicalAccuracyPercent;
            Check(Shots==e.Args[0],"native weapon preserves projectile count");
            Check(Abs(ShotChance-Min(100,BaseChance*ExpectedMultiplier))<1e-6,"actual projectile snapshots boosted critical chance at firing");
            Check(Abs(accuracy-100*ExpectedMultiplier)<1e-6,"native physical or magical accuracy uses current factor");
            Console.Printf("CA244 SHOT kind=%d count=%d chance=%.3f accuracy=%.3f damage=%.3f",Equipment.Choice,Shots,ShotChance,accuracy,ShotDamage);Watching=false;
        }
        if(e.Name=="c244_partial")Check(User.ClassCastActive && User.ClassCastPaid>0 && User.ClassCastPaid<1000 && User.ClassSleepCooldownRemaining==0,"native preparation progressively pays without reuse");
        if(e.Name=="c244_cancel")Check(!User.ClassCastActive && !CaelumSurvivalInstinct.Active(User) && User.CurrentAnima<1000 && User.ClassSleepCooldownRemaining==0,"native second press cancels with no refund or effect");
        if(e.Name=="c244_release")Check(CaelumSurvivalInstinct.Active(User) && !User.ClassCastActive && User.ClassCastPaid==1000 && User.ClassSleepCooldownRemaining>59,"native release starts effect and cooldown after full payment");
        if(e.Name=="c244_save"){CaelumSurvivalInstinct.Release(User);BeforeAnima=User.CurrentAnima;Check(CaelumSurvivalInstinct.Active(User),"save includes active effect");}
        if(e.Name=="c244_loaded")
        {let effect=CaelumSurvivalInstinct.Status(User);Check(effect!=null && effect.Revision==1 && effect.Multiplier==3 && effect.RemainingTics<350,"loaded effect retains revision potency and remaining time");Remaining=effect==null?0:effect.RemainingTics;BeforeAnima=User.CurrentAnima;}
        if(e.Name=="c244_clock")Check(Remaining-CaelumSurvivalInstinct.Status(User).RemainingTics==35 && User.CurrentAnima==BeforeAnima,"loaded clock advances once with no second payment");
        if(e.Name=="c244_hub")Check(CaelumSurvivalInstinct.Active(User) && CaelumSurvivalInstinct.Multiplier(User)==3,"hub transition retains one effect");
        if(e.Name=="c244_expired"){Refresh();Check(!CaelumSurvivalInstinct.Active(User) && User.EffectivePhysicalAccuracyPercent==100,"native expiry removes benefit");}
        if(e.Name=="c244_dead"){CaelumSurvivalInstinct.Release(User);User.health=0;Check(CaelumSurvivalInstinct.Multiplier(User)==1,"death immediately stops benefit");}
        if(e.Name=="c244_done")Console.Printf("CA244 DONE failures=%d passed=%d",Failed,Passed);
    }
}
