// #238: entradas nativas y contratos del ciclo; nunca entra en el paquete del juego.
class CA238SleepTarget : CaelumCombatActor
{
    Default { Radius 16; Height 56; Mass 80; Health 100000; +SHOOTABLE; +NOGRAVITY; }
    States { Spawn: TNT1 A -1; Stop; RestLying: TNT1 B -1; Stop; }
}

class CA238LifecycleProbe : StaticEventHandler
{
    CaelumPlayer User;
    CA259Session Equipment;
    CA238SleepTarget TargetBody;
    int Passed,Failed,NativeStarts,NativeReleases,NativeCancels,LastRemaining;
    bool Watching,WasActive;
    Weapon NativeWeapon;
    void Check(bool ok,String label)
    {if(ok)Passed++;else Failed++;Console.Printf("CA238 %s %s",ok?"PASS":"FAIL",label);}
    override void UiTick(){if(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();}
    void Reset()
    {
        CaelumClassAbilityRules.Cancel(User);CaelumSleepRules.Wake(User);
        User.ClassSleepInputLatched=false;User.ClassSleepCooldownRemaining=0;
        User.ClassCastPaid=0;User.CreationWizardOpen=false;User.CharacterCreationComplete=true;
        User.CharacterProfile.FirstClass=CaelumConstants.CLASS_PRIEST;
        User.CharacterProfile.SecondClass=CaelumConstants.CLASS_MAGE;
        User.CharacterProfile.Race=CaelumConstants.RACE_HUMAN;
        User.ApplyCharacterProfile();User.Attributes.Eloquence=0;
        User.DerivedStats.Recalculate(User.Attributes,User.CharacterProfile);
        User.DerivedStats.AnimaRegenerationPerSecond=0;
        User.CurrentAnima=1000;User.CurrentAir=User.DerivedStats.MaximumAir;
        User.LucidityPhysicalStunRemaining=0;User.PainImmobilizationRemaining=0;
        User.bInvulnerable=true;User.CombatChannelModeActive=false;
    }
    override void WorldTick()
    {
        if(User==null)return;
        User.DerivedStats.AnimaRegenerationPerSecond=0;
        if(!Watching)return;
        bool active=User.ClassCastActive;
        if(active && !WasActive){NativeStarts++;NativeWeapon=User.player.ReadyWeapon;Console.Printf("CA238 NATIVE start time=%d remaining=%d",level.time,User.ClassPreparationTics);}
        if(active)
        {
            double expected=User.ClassCastCost*(105-User.ClassPreparationTics)/105;
            Check(Abs(User.ClassCastPaid-expected)<1e-7,"native progressive cumulative debit");
            Check(!User.StaffCastPending && !User.PhysicalAttackPending
                && !User.CombatBlockModeActive,"native attack/block guard");
            Check(User.player.ReadyWeapon==NativeWeapon && !User.CombatChannelModeActive
                && !User.CombatTarotInputReserved,"native weapon/power activation guard");
            if(WasActive)Check(User.ClassPreparationTics==LastRemaining-1,"native clock advances one tic");
        }
        if(!active && WasActive)
        {
            if(User.ClassSleepCooldownRemaining>0)
            {
                NativeReleases++;
                Check(Abs(User.ClassCastPaid-User.ClassCastCost)<1e-7,"release paid the full snapshot cost");
                Check(LastRemaining==1,"native release follows tic 105");
                Console.Printf("CA238 NATIVE release time=%d cooldown=%.8f",level.time,User.ClassSleepCooldownRemaining);
            }
            else NativeCancels++;
        }
        LastRemaining=User.ClassPreparationTics;WasActive=active;
    }
    void Contracts()
    {
        Reset();User.CurrentAnima=999;
        Check(!CaelumClassAbilityRules.Begin(User) && User.CurrentAnima==999,"full modified cost required at admission");
        User.CurrentAnima=1000;
        Check(CaelumClassAbilityRules.Begin(User),"exact full cost admitted");
        for(int tic=0;tic<35;tic++)CaelumClassAbilityRules.Advance(User);
        Check(Abs(User.ClassCastPaid-1000.0/3)<1e-7 && User.ClassPreparationTics==70,"one second spends one third");
        User.DerivedStats.AnimaCostReductionPercent=90;
        for(int tic=0;tic<70;tic++)CaelumClassAbilityRules.Advance(User);
        Check(!User.ClassCastActive && User.ClassCastPaid==1000 && User.CurrentAnima<1e-7
            && User.ClassSleepCooldownRemaining==60,"cost snapshot and exact full debit/release reuse");
        Reset();CaelumClassAbilityRules.Begin(User);
        for(int tic=0;tic<35;tic++)CaelumClassAbilityRules.Advance(User);
        double remaining=User.CurrentAnima;
        CaelumClassAbilityRules.Cancel(User);
        Check(User.CurrentAnima==remaining && User.ClassSleepCooldownRemaining==0,"cancellation retains spent Anima without reuse");
        Reset();CaelumClassAbilityRules.Begin(User);CaelumClassAbilityRules.Advance(User);
        User.CurrentAnima=0;double spent=User.ClassCastPaid;CaelumClassAbilityRules.Advance(User);
        Check(!User.ClassCastActive && User.ClassCastPaid==spent && User.ClassSleepCooldownRemaining==0,"resource exhaustion cancels without refund/reuse");
        Reset();CaelumClassAbilityRules.Begin(User);User.PainImmobilizationRemaining=1;
        CaelumClassAbilityRules.Advance(User);
        Check(!User.ClassCastActive && User.ClassSleepCooldownRemaining==0,"forced immobilization cancels");
        Reset();CaelumClassAbilityRules.Begin(User);User.Vel=(1,0,0);CaelumClassAbilityRules.Advance(User);
        Check(User.ClassCastActive,"movement does not cancel");
        User.ReserveRacialAbilityInput();User.ReserveTarotInput();User.RequestCombatChannelInput();
        Check(!User.CombatChannelModeActive && !User.CombatTarotInputReserved,"other activation paths remain blocked");
        User.EquipmentSelectionItemId=Equipment.TestItem.ItemId;
        User.RefreshEquipmentSelectionPreview();
        User.EquipSelectedNativeEquipment();User.UnequipSelectedNativeEquipment();
        User.ToggleSelectedMagicBoxNative();User.BreakSelectedNativeEquipment();
        User.DropSelectedNativeInventoryItem();User.DismantleSelectedNativeWeapon();
        Check(Equipment.TestItem.Equipped && !Equipment.TestItem.InMagicBox
            && User.FindNativeEquipmentItemById(Equipment.TestItem.ItemId)==Equipment.TestItem,
            "inventory weapon mutations blocked during preparation");
        Reset();
        TargetBody=CA238SleepTarget(Actor.Spawn("CA238SleepTarget",User.Pos+(256,0,0),NO_REPLACE));
        TargetBody.PostBeginPlay();TargetBody.InitializeCombatProfile(0,0,0,0,0,0,0,0,0,0,0,0);
        TargetBody.CombatMaximumHealth=100000;TargetBody.health=100000;
        CaelumSleepRules.Apply(TargetBody,350,true,1);
        for(int hit=0;hit<4;hit++)
        {
            int before=TargetBody.health;
            TargetBody.DamageMobj(null,null,20,'CaelumImpact',DMG_NO_ARMOR,0);
            Check(before-TargetBody.health==(hit<3?60:20),String.Format("enemy HP hit%d includes third multiplier",hit+1));
            Check((TargetBody.ForcedSleepTics>0)==(hit<2),"enemy wakes only after third HP hit");
        }
        CaelumSleepRules.Apply(TargetBody,350,true,2);TargetBody.DamageFactor=0.5;
        int before=TargetBody.health;TargetBody.DamageMobj(null,null,5,'CaelumImpact',DMG_NO_ARMOR,0);
        Check(before-TargetBody.health==12,"scaled x6 follows native factor and integer rounding");
        TargetBody.DamageFactor=0;
        TargetBody.DamageMobj(null,null,100,'CaelumImpact',DMG_NO_ARMOR,0);
        Check(TargetBody.SpellSleep.HitsRemaining==2,"zero actual HP does not count");
        TargetBody.DamageFactor=1;
        CaelumSleepRules.Apply(TargetBody,350,false,2);before=TargetBody.health;
        TargetBody.DamageMobj(null,null,20,'CaelumImpact',DMG_NO_ARMOR,0);
        Check(before-TargetBody.health==20 && TargetBody.ForcedSleepTics==0,"ally/neutral one-hit wake without multiplier");
        CaelumSleepRules.Apply(TargetBody,350,true,1);
        for(int hit=0;hit<3;hit++)TargetBody.DamageMobj(null,null,1,'CaelumElementalDOT',DMG_NO_ARMOR,0);
        Check(TargetBody.ForcedSleepTics==0,"three damaging DOT applications wake");
        CaelumSleepRules.Apply(TargetBody,350,true,2);
        TargetBody.DamageMobj(null,null,1,'CaelumImpact',DMG_NO_ARMOR,0);
        CaelumSleepRules.Apply(TargetBody,700,true,1);
        Check(TargetBody.SpellSleep.HitsRemaining==3 && TargetBody.SpellSleep.DamageMultiplier==3
            && TargetBody.ForcedSleepTics==700,"reapplication resets hits and power, retains longest time");
        CaelumSleepRules.Wake(TargetBody);
        TargetBody.bIsMonster=true;TargetBody.bFriendly=false;
        Check(CaelumSleepRules.Enemy(User,TargetBody),"native hostile monster is an enemy");
        TargetBody.bFriendly=true;Check(!CaelumSleepRules.Enemy(User,TargetBody),"friendly resident is not an enemy");
        TargetBody.bFriendly=false;TargetBody.bIsMonster=false;
        Check(!CaelumSleepRules.Enemy(User,TargetBody),"neutral shootable body is not an enemy");
        CaelumSleepRules.Wake(TargetBody);
        TargetBody.SetState(TargetBody.SpawnState,true);TargetBody.tics=-1;
        CaelumSleepRules.Apply(TargetBody,3,true,1);
        for(int tic=0;tic<3;tic++)TargetBody.Tick();
        Check(TargetBody.ForcedSleepTics==0 && TargetBody.SpellSleep==null,"duration expiry wakes without three hits");
        Check(TargetBody.tics==-1,"wake preserves an indefinite original pose");
        TargetBody.Tick();
        Check(TargetBody!=null && TargetBody.health>0 && TargetBody.CurState==TargetBody.SpawnState,
            "waking an indefinite pose never destroys the living body");
        User.bInvulnerable=false;User.health=10000;User.player.health=10000;
        CaelumSleepRules.Apply(User,350,true,1);
        for(int hit=0;hit<3;hit++)User.DamageMobj(null,null,20,'CaelumImpact',DMG_NO_ARMOR,0);
        Check(User.health==9820 && User.ForcedSleepTics==0,"player receiver final damage and third-hit wake");
        if(TargetBody!=null)TargetBody.Destroy();TargetBody=null;
        Reset();
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="c238_lifecycle_setup")
        {
            User=CaelumPlayer(players[e.Player].mo);Reset();Equipment=new("CA259Session");
            Equipment.Choice=0;Equipment.Tier=1;Equipment.Equip(User);
            Contracts();Watching=true;
        }
        if(User==null)return;
        if(e.Name=="c238_lifecycle_reset"){Watching=false;WasActive=false;Reset();Watching=true;}
        if(e.Name=="c238_native_weapon")
        {
            Watching=false;WasActive=false;Reset();Equipment.Choice=e.Args[0];Equipment.Equip(User);
            Reset();Watching=true;
        }
        if(e.Name=="c238_matrix_done")
        {
            Check(NativeStarts==10 && NativeReleases==10 && NativeCancels==0,
                "native ten-family User4 matrix completes every cycle");
            Console.Printf("CA238 DONE failures=%d passes=%d NATIVE_MATRIX",Failed,Passed);
        }
        if(e.Name=="c238_lifecycle_cancel_check")
            Check(!User.ClassCastActive && User.ClassCastPaid>0 && User.ClassCastPaid<User.ClassCastCost
                && User.ClassSleepCooldownRemaining==0,"second native User4 press cancels");
        if(e.Name=="c238_lifecycle_unarmed")
        {
            Watching=false;WasActive=false;Reset();
            User.EquipmentSelectionItemId=Equipment.TestItem.ItemId;
            User.RefreshEquipmentSelectionPreview();User.UnequipSelectedNativeEquipment();
            User.EnsureUnarmedFallback();User.player.PendingWeapon=Weapon(User.FindInventory("CaelumUnarmedWeapon"));Watching=true;
        }
        if(e.Name=="c238_lifecycle_save")
        {
            Check(User.ClassCastActive && User.ClassCastPaid>0 && User.ClassCastPaid<User.ClassCastCost,"save during partial payment");
            TargetBody=CA238SleepTarget(Actor.Spawn("CA238SleepTarget",User.Pos+(256,0,0),NO_REPLACE));
            TargetBody.PostBeginPlay();TargetBody.InitializeCombatProfile(0,0,0,0,0,0,0,0,0,0,0,0);
            TargetBody.health=100000;TargetBody.CombatMaximumHealth=100000;
            CaelumSleepRules.Apply(TargetBody,350,true,2);
            TargetBody.DamageMobj(null,null,5,'CaelumImpact',DMG_NO_ARMOR,0);
            Console.Printf("CA238 DONE failures=%d passes=%d SAVE",Failed,Passed);
        }
        if(e.Name=="c238_lifecycle_done")
        {
            Check(NativeStarts==3 && NativeReleases==2 && NativeCancels==1,"native armed/unarmed release and cancellation counts");
            Console.Printf("CA238 DONE failures=%d passes=%d starts=%d releases=%d cancels=%d",Failed,Passed,NativeStarts,NativeReleases,NativeCancels);
        }
        if(e.Name=="c238_hub_check")
        {
            Check(User.ClassCastActive && User.ClassCastPaid>0 && User.ClassCastPaid<1000,
                "hub travel retains partially paid cast");
            Check(Abs(User.ClassCastPaid+User.CurrentAnima-1000)<1e-6,
                "hub travel preserves actual Anima and debit");
            if(level.MapName=="MAP02")
            {
                let it=ThinkerIterator.Create("CA238SleepTarget");let body=CA238SleepTarget(it.Next());
                Check(body!=null && body.SpellSleep!=null && body.SpellSleep.HitsRemaining==2
                    && body.SpellSleep.DamageMultiplier==6 && body.ForcedSleepTics>0,
                    "hub return retains NPC Sleep hit count and power");
            }
        }
        if(e.Name=="c238_hub_done")
        {
            Check(NativeStarts==1 && NativeReleases==1 && NativeCancels==0,
                "traveling cast releases once");
            Check(User.ClassSleepCooldownRemaining>55 && User.ClassSleepCooldownRemaining<60,
                "hub release reuse does not refresh");
            Console.Printf("CA238 DONE failures=%d passes=%d HUB",Failed,Passed);
        }
    }
}

class CA238LifecycleLoad : StaticEventHandler
{
    CaelumPlayer User;
    int Passed,Failed;
    void Check(bool ok,String label)
    {if(ok)Passed++;else Failed++;Console.Printf("CA238 %s %s",ok?"PASS":"FAIL",label);}
    override void UiTick(){if(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();}
    override void WorldTick(){if(User!=null)User.DerivedStats.AnimaRegenerationPerSecond=0;}
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="c238_resume")
        {
            User=CaelumPlayer(players[e.Player].mo);
            Check(User.ClassCastActive && User.ClassPreparationTics>0 && User.ClassPreparationTics<105,"saved active cast resumes");
            Check(Abs(User.ClassCastPaid-1000.0*(105-User.ClassPreparationTics)/105)<1e-6
                && Abs(User.CurrentAnima+User.ClassCastPaid-1000)<1e-6,"saved debit and resource remain complementary");
            let it=ThinkerIterator.Create("CA238SleepTarget");let body=CA238SleepTarget(it.Next());
            Check(body!=null && body.ForcedSleepTics>0 && body.SpellSleep!=null
                && body.SpellSleep.HitsRemaining==2 && body.SpellSleep.DamageMultiplier==6,"saved Sleep count, multiplier and remaining duration");
        }
        if(e.Name=="c238_resume_done")
        {
            Check(User!=null && !User.ClassCastActive && User.ClassPreparationTics==0
                && User.ClassCastPaid==1000 && User.CurrentAnima<1e-6
                && User.ClassSleepCooldownRemaining>55 && User.ClassSleepCooldownRemaining<60,"loaded cast releases once without duplicate debit");
            Console.Printf("CA238 DONE failures=%d passes=%d LOAD",Failed,Passed);
        }
    }
}
