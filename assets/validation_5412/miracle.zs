// #245: escena aislada; no se distribuye con el juego.
class CA245Body : CaelumMandinga
{
    override void Tick() { }
    override void PostBeginPlay(){Super.PostBeginPlay();bBuddha=true;ResetReserves();}
    void ResetReserves()
    {
        CombatMaximumHealth=1000;health=200;MaximumCombatAnima=10000;CurrentCombatAnima=2000;
        MaximumCombatAir=1000;CurrentCombatAir=200;CurrentCombatLucidity=20;MiracleHealthRemainder=0;
        CombatAnimaRegenerationPerSecond=CombatAirRegenerationPerSecond=0;
    }
}
class CA245Caster : CaelumPlayer { override void Tick() { } }
class CA245Probe : StaticEventHandler
{
    CaelumPlayer User;
    CA245Body Ally,Enemy,Neutral,Hidden,Far;
    int Passed,Failed,LastHealth,Remaining,Clock,PositionChoice;
    bool Manual,Stable;
    double BeforeAnima,BeforeLucidity,BeforeAir;
    void Check(bool ok,String label)
    {if(ok)Passed++;else Failed++;Console.Printf("CA245 %s %s",ok?"PASS":"FAIL",label);}
    void Stats()
    {
        User.DerivedStats.MaximumAnima=10000;User.DerivedStats.MaximumAir=1000;
        User.DerivedStats.HealthRegenerationPerSecond=0;User.DerivedStats.AnimaRegenerationPerSecond=0;
        User.DerivedStats.AirRegenerationPerSecond=0;
        User.DerivedStats.AnimaCostReductionPercent=0;User.DerivedStats.BuffPowerPercent=100;
        User.DerivedStats.AbilityRangePercent=100;
        User.CaelumMaximumHealth=1000;
    }
    void Reserves(CA245Body body)
    {body.ResetReserves();}
    CA245Body Body(vector3 pos,bool friendly)
    {let body=CA245Body(Actor.Spawn("CA245Body",pos,NO_REPLACE));body.bFriendly=friendly;Reserves(body);return body;}
    void Clear()
    {let effect=CaelumMiracle.Status(User);if(effect!=null)effect.Destroy();}
    void Reset()
    {
        PositionChoice=0;
        Clear();CaelumClassAbilityRules.Cancel(User);CaelumSleepRules.Wake(User);CaelumRacialAbilityRules.Deactivate(User);
        User.ClassSleepCooldownRemaining=0;User.ClassSleepInputLatched=false;
        User.CharacterCreationComplete=true;User.CreationWizardOpen=false;
        User.CharacterProfile.FirstClass=User.CharacterProfile.SecondClass=CaelumConstants.CLASS_PRIEST;
        User.CharacterProfile.Race=CaelumConstants.RACE_HUMAN;User.ApplyCharacterProfile();
        User.LucidityPhysicalStunRemaining=User.PainImmobilizationRemaining=0;User.ForcedSleepTics=0;
        User.CurrentSleep=100;User.CurrentLucidity=50;User.bInvulnerable=true;User.bBuddha=true;
        User.CombatChannelModeActive=false;User.EquipmentMenuOpen=false;User.CraftingMenuOpen=false;
        User.player.ConversationNPC=null;User.player.ConversationPC=null;
        User.SetOrigin((0,0,0),false);User.Angle=0;User.Pitch=0;User.Vel=(0,0,0);
        Stats();User.CurrentAnima=5000;User.CurrentAir=500;User.health=500;User.player.health=500;
        User.CurrentAdrenaline=0;User.MiracleHealthRemainder=0;User.NaturalHealthRegenerationAccumulator=0;
        if(Ally!=null)Ally.Destroy();if(Enemy!=null)Enemy.Destroy();if(Neutral!=null)Neutral.Destroy();
        if(Hidden!=null)Hidden.Destroy();if(Far!=null)Far.Destroy();
        Ally=Body((256,160,0),true);Ally.ChangeTid(2450);
        Enemy=Body((256,-160,0),false);Neutral=Body((-256,0,0),false);Neutral.bIsMonster=false;
        Hidden=Body((768,0,0),true);Far=Body((1800,600,0),true);
        User.UpdateHealthStateEffects();User.UpdateLucidityState();User.UpdateAirStateEffects();Stable=true;
    }
    override void UiTick(){if(!Manual && Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();}
    override void WorldTick(){if(User!=null && Stable)Stats();}
    void Contract()
    {
        Console.Printf("CA245 INITIAL ally %d max%d luc%.3f anima%.3f air%.3f enemy%d neutral%d hidden%d far%d",Ally.health,Ally.CombatMaximumHealth,Ally.CurrentCombatLucidity,Ally.CurrentCombatAnima,Ally.CurrentCombatAir,Enemy.health,Neutral.health,Hidden.health,Far.health);
        Check(CaelumClassAbilityRules.CanCast(User),"Priest enters shared lifecycle");
        CaelumMiracle.Release(User);let effect=CaelumMiracle.Status(User);
        Check(effect!=null && effect.Revision==1 && effect.RemainingTics==350 && effect.PulseTics==35
            && Abs(effect.RecoveryRatio-0.03)<1e-8 && effect.Range==1280,"release snapshots base rate radius duration and delayed pulse");
        Check(CaelumMiracle.Eligible(effect,User) && CaelumMiracle.Eligible(effect,Ally),"caster and native friendly combatant eligible");
        Check(CaelumMiracle.Affected(User) && CaelumMiracle.Affected(Ally) && !CaelumMiracle.Affected(Enemy),"external timed recovery is visible to travel admission");
        Check(!CaelumMiracle.Eligible(effect,Enemy) && !CaelumMiracle.Eligible(effect,Neutral),"enemy and neutral excluded");
        Check(!CaelumMiracle.Eligible(effect,Hidden) && !CaelumMiracle.Eligible(effect,Far),"real wall and range exclude allies");
        User.CurrentLucidity=50;User.CurrentAnima=5000;User.CurrentAir=500;User.health=500;
        CaelumMiracle.Pulse(effect);
        Console.Printf("CA245 PULSE ally %d max%d luc%.3f anima%.3f air%.3f enemy%d neutral%d hidden%d far%d",Ally.health,Ally.CombatMaximumHealth,Ally.CurrentCombatLucidity,Ally.CurrentCombatAnima,Ally.CurrentCombatAir,Enemy.health,Neutral.health,Hidden.health,Far.health);
        Check(User.health==530 && User.player.health==530 && User.CurrentLucidity==53
            && User.CurrentAnima==5300 && User.CurrentAir==530,"four authoritative player resources restore current maxima");
        Check(Ally.health==230 && Ally.CurrentCombatLucidity==23 && Ally.CurrentCombatAnima==2300
            && Ally.CurrentCombatAir==230,"four NPC resources restore current maxima");
        Check(Enemy.health==200 && Neutral.health==200 && Hidden.health==200 && Far.health==200,"ineligible reserves unchanged");
        Ally.SetOrigin((1800,-600,0),false);Far.SetOrigin((256,160,0),false);CaelumMiracle.Pulse(effect);
        Check(Ally.health==230 && Far.health==230,"membership changes on next pulse");
        User.SetOrigin((1600,0,0),false);CaelumMiracle.Pulse(effect);
        Check(Ally.health==260 && Far.health==230,"area follows caster and original area no longer heals");User.SetOrigin((0,0,0),false);
        User.DerivedStats.MaximumAnima=20000;User.DerivedStats.MaximumAir=2000;User.CaelumMaximumHealth=2000;
        User.health=100;User.CurrentAnima=100;User.CurrentAir=100;User.CurrentLucidity=10;
        CaelumPlayerResources.ApplyMiraclePulse(User,0.03);
        Check(User.health==160 && User.CurrentAnima==700 && User.CurrentAir==160 && User.CurrentLucidity==13,"changed maxima used at pulse time");
        Stats();User.health=999;User.CurrentAnima=9999;User.CurrentAir=999;User.CurrentLucidity=99;
        CaelumPlayerResources.ApplyMiraclePulse(User,0.03);
        Check(User.health==1000 && User.CurrentAnima==10000 && User.CurrentAir==1000 && User.CurrentLucidity==100,"all four player maxima respected");
        Reserves(Ally);Ally.health=999;Ally.CurrentCombatAnima=9999;Ally.CurrentCombatAir=999;Ally.CurrentCombatLucidity=99;Ally.ApplyMiraclePulse(0.03);
        Check(Ally.health==1000 && Ally.CurrentCombatAnima==10000 && Ally.CurrentCombatAir==1000 && Ally.CurrentCombatLucidity==100,"all four NPC maxima respected");
        User.CaelumMaximumHealth=17;User.health=1;User.MiracleHealthRemainder=0;
        for(int i=0;i<10;i++)CaelumPlayerResources.ApplyMiraclePulse(User,0.03);
        Check(User.health==6 && Abs(User.MiracleHealthRemainder-0.1)<1e-6,"fractional HP preserved without one-HP minimum or rounding drift");Stats();
        User.health=500;User.CurrentAnima=5000;User.CurrentAir=500;
        User.DerivedStats.HealthRegenerationPerSecond=35;User.DerivedStats.AnimaRegenerationPerSecond=35;
        User.CurrentHunger=User.CurrentThirst=100;
        CaelumPlayerResources.ApplyNaturalHealthRegeneration(User);CaelumPlayerResources.ApplyAnimaRegeneration(User);
        double hp=User.health,anima=User.CurrentAnima;CaelumPlayerResources.ApplyMiraclePulse(User,0.03);
        Check(hp>500 && anima>5000 && User.health==hp+30 && Abs(User.CurrentAnima-anima-300)<1e-6,"ordinary regeneration and Miracle both contribute");Stats();
        effect.PulseTics=17;effect.RemainingTics=900;User.DerivedStats.BuffPowerPercent=200;User.DerivedStats.AbilityRangePercent=200;
        CaelumMiracle.Release(User);
        Check(effect.RecoveryRatio==0.06 && effect.Range==2560 && effect.RemainingTics==900 && effect.PulseTics==17,"renewal snapshots new power range but preserves longer time and pulse phase");
        User.DerivedStats.BuffPowerPercent=300;CaelumMiracle.Release(User);
        Check(effect.RemainingTics==1050 && effect.RecoveryRatio==0.09,"Empathy scales healing and duration");Stats();
        Reserves(Far);effect.RecoveryRatio=0.03;
        let second=CA245Caster(Actor.Spawn("CA245Caster",(0,64,0),NO_REPLACE));second.bFriendly=true;
        let stronger=CaelumMiracleEffect(second.GiveInventoryType("CaelumMiracleEffect"));
        stronger.Revision=1;stronger.RemainingTics=350;stronger.PulseTics=35;stronger.Range=1280;stronger.RecoveryRatio=0.06;
        Check(CaelumMiracle.Eligible(stronger,Far),"secondary caster fixture covers same ally");
        CaelumMiracle.Pulse(effect);CaelumMiracle.Pulse(stronger);
        Check(Far.health==260,"overlapping auras apply only strongest recovery");
        stronger.Destroy();second.Destroy();Clear();
        User.health=0;double reserve=User.CurrentAnima;CaelumPlayerResources.ApplyMiraclePulse(User,0.03);
        Check(User.health==0 && User.CurrentAnima==reserve,"dead player is not resurrected or restored");User.health=500;User.player.health=500;
    }
    void Cadence()
    {Clear();Reserves(Ally);CaelumMiracle.Release(User);}
    override void NetworkProcess(ConsoleEvent e)
    {
        User=CaelumPlayer(players[e.Player].mo);if(User==null)return;
        if(e.Name=="c245_setup")Reset();
        if(e.Name=="c245_contract")Contract();
        if(e.Name=="c245_cadence")Cadence();
        if(e.Name=="c245_before")Check(Ally.health==200,"no pulse before one second");
        if(e.Name=="c245_first")Check(Ally.health==230,"first native pulse at one second");
        if(e.Name=="c245_tenth")Check(Ally.health==500 && Ally.CurrentCombatLucidity==50
            && Ally.CurrentCombatAnima==5000 && Ally.CurrentCombatAir==500 && !CaelumMiracle.Active(User),"ten native pulses restore all four resources including last effect second");
        if(e.Name=="c245_after")Check(Ally.health==500,"no healing after expiry");
        if(e.Name=="c245_partial")Check(User.ClassCastActive && User.ClassCastPaid>0 && User.ClassCastPaid<1000 && User.ClassSleepCooldownRemaining==0,"native preparation pays progressively without reuse");
        if(e.Name=="c245_cancel")Check(!User.ClassCastActive && !CaelumMiracle.Active(User) && User.CurrentAnima<5000 && User.ClassSleepCooldownRemaining==0,"second press cancels with no refund or effect");
        if(e.Name=="c245_release")Check(CaelumMiracle.Active(User) && !User.ClassCastActive && User.ClassCastPaid==1000 && User.ClassSleepCooldownRemaining>59,"native release starts one effect and reuse after full payment");
        if(e.Name=="c245_save"){Cadence();User.MiracleRecoveryRevision=Ally.MiracleRecoveryRevision=1;
            User.MiracleHealthRemainder=0.625;Ally.MiracleHealthRemainder=0.375;Check(CaelumMiracle.Active(User),"save contains active aura and fractional recovery");}
        if(e.Name=="c245_loaded")
        {
            Stable=true;Ally=CA245Body(ActorIterator.Create(2450).Next());let effect=CaelumMiracle.Status(User);
            Check(effect!=null && effect.Revision==1 && effect.PulseTics>0 && effect.PulseTics<35 && Ally.health==200,"load between pulses retains phase without early healing");
            Check(User.MiracleRecoveryRevision==1 && Ally.MiracleRecoveryRevision==1
                && User.MiracleHealthRemainder==0.625 && Ally.MiracleHealthRemainder==0.375,"player and NPC fractional recovery revisions survive native save");
            Remaining=effect.RemainingTics;Clock=effect.PulseTics;LastHealth=Ally.health;BeforeAnima=User.ClassCastPaid;
        }
        if(e.Name=="c245_clock")
        {let effect=CaelumMiracle.Status(User);Check(Remaining-effect.RemainingTics==35 && Clock==effect.PulseTics && Ally.health==LastHealth+30 && User.ClassCastPaid==BeforeAnima,"loaded second advances once with exactly one pulse and no repayment");}
        if(e.Name=="c245_hub")Check(CaelumMiracle.Active(User) && CaelumMiracle.Status(User).RecoveryRatio==0.03,"hub travel retains aura potency and clock");
        if(e.Name=="c245_expired")Check(!CaelumMiracle.Active(User),"native expiry removes aura");
        if(e.Name=="c245_dead"){CaelumMiracle.Release(User);User.health=0;Check(!CaelumMiracle.Active(User),"caster death immediately disables aura");}
        if(e.Name=="c245_manual"){Reset();Manual=true;}
        if(e.Name=="c245_position"){PositionChoice=1-PositionChoice;Ally.SetOrigin(PositionChoice?(1800,600,0):(256,160,0),false);}
        if(e.Name=="c245_occlusion")Ally.SetOrigin((768,0,0),false);
        if(e.Name=="c245_manual_check")Check(CaelumMiracle.Active(User) && Ally.health>200 && Enemy.health==200 && Hidden.health==200,"manual native cast heals visible ally but not enemy or hidden ally");
        if(e.Name=="c245_done")Console.Printf("CA245 DONE failures=%d passed=%d",Failed,Passed);
    }
    override void RenderOverlay(RenderEvent e)
    {
        let user=CaelumPlayer(players[consoleplayer].mo);if(!Manual || user==null)return;
        let effect=CaelumMiracle.Status(user);
        String line=String.Format("MILAGRO | Efecto %.1fs | Reutilizacion %.1fs | F lanzar/cancelar | F6 reiniciar",
            effect==null?0:effect.RemainingTics/35.0,user.ClassSleepCooldownRemaining);
        Screen.DrawText(SmallFont,Font.CR_WHITE,88,8,line,DTA_VIRTUALWIDTHF,640.0,DTA_VIRTUALHEIGHTF,360.0);
        line=String.Format("Tu: Salud %d/1000 | Lucidez %.1f/100 | Anima %.0f/10000 | Aire %.0f/1000",
            user.health,user.CurrentLucidity,user.CurrentAnima,user.CurrentAir);
        Screen.DrawText(SmallFont,Font.CR_WHITE,88,20,line,DTA_VIRTUALWIDTHF,640.0,DTA_VIRTUALHEIGHTF,360.0);
        if(Ally==null)return;
        line=String.Format("Aliado: Salud %d | Lucidez %.0f | Anima %.0f | Aire %.0f | Enemigo: %d",
            Ally.health,Ally.CurrentCombatLucidity,Ally.CurrentCombatAnima,Ally.CurrentCombatAir,Enemy==null?0:Enemy.health);
        Screen.DrawText(SmallFont,Font.CR_WHITE,88,32,line,DTA_VIRTUALWIDTHF,640.0,DTA_VIRTUALHEIGHTF,360.0);
        Screen.DrawText(SmallFont,Font.CR_WHITE,88,44,"F7 aliado dentro/fuera | F8 aliado tras pared | Aliado a la izquierda, enemigo a la derecha",
            DTA_VIRTUALWIDTHF,640.0,DTA_VIRTUALHEIGHTF,360.0);
    }
}
