// Valores controlados exclusivos de la prueba #249.
class CA249Target : CaelumMandinga
{
    override void Tick(){}
    override void PostBeginPlay(){Super.PostBeginPlay();health=CombatMaximumHealth=1000000;EffectiveCombatEvasionChance=0;}
}
class CA249Checkpoint : Inventory
{
    Actor Body;
    int Health,Remaining;
    double Anima,Air;
    Default {Inventory.MaxAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA249Probe : StaticEventHandler
{
    CaelumPlayer User;
    CaelumSummonedZupay Before;
    CA249Target Ally,Enemy;
    int Passed,Failed,Remaining,Health,CountBefore;
    double Anima,Air;
    bool Pin,Manual;
    void Check(bool ok,String label)
    {if(ok)Passed++;else Failed++;Console.Printf("CA249 %s %s",ok?"PASS":"FAIL",label);}
    void Stats()
    {
        User.DerivedStats.MaximumAnima=10000;User.DerivedStats.AnimaCostReductionPercent=0;
        User.DerivedStats.BuffPowerPercent=100;User.DerivedStats.AbilityRangePercent=100;
        User.DerivedStats.AnimaRegenerationPerSecond=User.DerivedStats.HealthRegenerationPerSecond=0;
        User.CombatTimeRemaining=2;
    }
    override void WorldTick(){if(Pin && User!=null)Stats();}
    override void UiTick(){if(!Manual && Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();}
    void Reset()
    {
        if(Ally!=null)Ally.Destroy();if(Enemy!=null)Enemy.Destroy();
        User=CaelumPlayer(players[consoleplayer].mo);let old=CaelumSummoning.Status(User);if(old!=null)old.Destroy();
        User.CharacterCreationComplete=true;User.CreationWizardOpen=false;
        User.CharacterProfile.FirstClass=CaelumConstants.CLASS_WARRIOR;User.CharacterProfile.SecondClass=CaelumConstants.CLASS_MAGE;
        User.CharacterProfile.Race=CaelumConstants.RACE_HUMAN;User.ApplyCharacterProfile();
        User.LucidityPhysicalStunRemaining=User.PainImmobilizationRemaining=0;User.ForcedSleepTics=0;
        User.EquipmentMenuOpen=User.CraftingMenuOpen=User.CombatChannelModeActive=false;
        User.player.ConversationNPC=null;User.player.ConversationPC=null;
        User.SetOrigin((0,0,0),false);User.Vel=(0,0,0);User.Angle=0;User.Pitch=30;
        User.CurrentSleep=User.CurrentLucidity=100;User.bInvulnerable=true;
        User.CaelumMaximumHealth=User.health=User.player.health=100000;User.CurrentAnima=5000;
        CaelumClassAbilityRules.Cancel(User);User.ClassPreparationTics=0;User.ClassSleepCooldownRemaining=0;
        User.ClassSleepInputLatched=false;Pin=true;Stats();
    }
    int Count()
    {int n=0;let it=ThinkerIterator.Create("CaelumSummonedZupay");while(it.Next()!=null)n++;return n;}
    void Contract()
    {
        Check(CaelumClassAbilityRules.CanCast(User),"Battle Mage supported by shared native lifecycle");
        Check(CaelumSummoning.Release(User),"aimed floor summon released");
        let effect=CaelumSummoning.Status(User);if(effect==null){Check(false,"effect exists");return;}
        Before=effect.Body;
        Check(Count()==1 && effect.Revision==1 && effect.RemainingTics==350 && effect.Range==1280,"one owned revisioned summon and base clocks/range");
        Check(Before.master==User && Before.bFriendly && Before.IsFriend(User),"native caster ownership and allied identity");
        Check(!Before.IsSewerBoss() && !Before.IsRetreatBoss() && Before.tid==0 && !Before.bCountKill,"no story identity retreat or kill counter");
        Check(Before.TestMobjLocation(),"native body fits without telefrag");
    }
    void Profile()
    {
        let body=CaelumSummoning.Status(User).Body;
        Check(body.CombatStrength==33 && body.CombatEmpathy==33 && body.CombatIntelligence==33,"base profile initialized once");
        Check(body.Radius==GetDefaultByType("CaelumZupayColossus").Radius && body.Mass==666,"existing body size and mass");
        Pin=false;User.DerivedStats.BuffPowerPercent=200;
        Before=body;Health=body.CombatMaximumHealth;body.health=12345;
        Check(CaelumSummoning.Release(User),"recast replaces the existing summon");
        let next=CaelumSummoning.Status(User);
        Check(next.Body!=Before && Count()==1 && next.RemainingTics==700,"replacement never duplicates and uses new duration");
    }
    void Powered()
    {
        let body=CaelumSummoning.Status(User).Body;
        Check(body.CombatStrength==66 && body.CombatConstitution==66 && body.CombatToughness==66
            && body.CombatAgility==66 && body.CombatDexterity==66 && body.CombatResilience==66
            && body.CombatCharisma==66 && body.CombatEmpathy==66 && body.CombatEloquence==66
            && body.CombatIntelligence==66 && body.CombatPatience==66 && body.CombatInsight==66,"Empathy scales all twelve base attributes");
        Console.Printf("CA249 profile health=%d max=%d base=%d",body.health,body.CombatMaximumHealth,Health);
        Check(body.health==body.CombatMaximumHealth && body.health>Health,"fresh replacement has recomputed full Health");
        int left=CaelumSummoning.Status(User).RemainingTics;
        User.Pitch=-45;Check(!CaelumSummoning.Release(User),"invalid aim rejects replacement");
        Check(CaelumSummoning.Status(User).Body==body && Count()==1 && CaelumSummoning.Status(User).RemainingTics==left,"failed recast preserves old body and clock");
        User.Pitch=30;
    }
    void Friendly()
    {
        let body=CaelumSummoning.Status(User).Body;
        Ally=CA249Target(Actor.Spawn("CA249Target",(200,300,0),NO_REPLACE));Ally.bFriendly=true;
        Enemy=CA249Target(Actor.Spawn("CA249Target",(300,300,0),NO_REPLACE));
        Check(!body.CanAffect(User) && !body.CanAffect(Ally) && body.CanAffect(Enemy),"summoned attacks only affect enemies");
        let shot=CaelumActorExplosiveElementalProjectile(Actor.Spawn("CaelumActorExplosiveElementalProjectile",(0,0,200),NO_REPLACE));
        shot.Target=body;shot.StoreCaelumAttackResult(300,true,false,true,1);
        Check(shot.PreventSummoningFriendlyFire(User) && shot.PreventSummoningFriendlyFire(Ally)
            && !shot.PreventSummoningFriendlyFire(Enemy),"projectile captures allegiance policy");
        body.Destroy();
        Check(shot.PreventSummoningFriendlyFire(User) && !shot.PreventSummoningFriendlyFire(Enemy),"projectile protection survives summon disappearance");
        shot.Destroy();Ally.Destroy();Enemy.Destroy();
    }
    void Seed()
    {
        let effect=CaelumSummoning.Status(User);let body=effect.Body;
        body.CaelumDiagnosticPassiveAI=true;body.health=body.CombatMaximumHealth/2;body.CurrentCombatAnima=123;body.CurrentCombatAir=50;
        body.CombatAnimaRegenerationPerSecond=body.CombatAirRegenerationPerSecond=0;
        Before=body;Health=body.health;Anima=body.CurrentCombatAnima;Air=body.CurrentCombatAir;Remaining=effect.RemainingTics;
        let potion=CaelumDemonService.Potion(body,CaelumConstants.CONSUMABLE_LIFE_POTION);potion.Amount=2;
        let saved=CA249Checkpoint(User.GiveInventoryType("CA249Checkpoint"));
        saved.Body=body;saved.Health=Health;saved.Anima=Anima;saved.Air=Air;saved.Remaining=Remaining;
    }
    void Loaded()
    {
        User=CaelumPlayer(players[consoleplayer].mo);let effect=CaelumSummoning.Status(User);
        Check(effect!=null && effect.Body!=null && Count()==1,"reload or hub preserves exactly one summon");
        if(effect==null || effect.Body==null)return;
        let body=effect.Body;
        let saved=CA249Checkpoint(User.FindInventory("CA249Checkpoint"));
        Check(saved!=null,"test checkpoint serialized");if(saved==null)return;
        Console.Printf("CA249 state hp=%d anima=%.6f air=%.6f remaining=%d",body.health,body.CurrentCombatAnima,body.CurrentCombatAir,effect.RemainingTics);
        Check(body==saved.Body && body.master==User && body.Binding==effect,"saved identity and ownership preserved");
        Check(body.health==saved.Health && abs(body.CurrentCombatAnima-saved.Anima)<0.01 && abs(body.CurrentCombatAir-saved.Air)<0.01,"Health and reserves not replenished");
        let potion=CaelumDemonService.Potion(body,CaelumConstants.CONSUMABLE_LIFE_POTION);
        Check(potion!=null && potion.Amount==2,"finite supplies preserved");
        Check(effect.RemainingTics<saved.Remaining && effect.RemainingTics>0,"effect time continues without resetting");
    }
    void Placement()
    {
        let place=CaelumSummoning.FindPlace(User,User.Pos,1280);
        Check(place.Found && (place.Point-User.Pos).Length()<User.Radius+GetDefaultByType("CaelumZupayColossus").Radius+1,"occupied target finds adjacent legal placement");
        place=CaelumSummoning.FindPlace(User,(768,0,0),1280);
        Check(place.Found && (place.Point-(768,0,0)).Length()>1,"occluded target moves to visible space");
        place=CaelumSummoning.FindPlace(User,User.Pos,1);
        Check(!place.Found,"no legal placement does not escape range");
    }
    void Pending()
    {
        User=CaelumPlayer(players[consoleplayer].mo);let effect=CaelumSummoning.Status(User);
        Check(effect!=null && effect.Body!=null,"pending summon survives blocked arrival");
        if(effect==null || effect.Body==null)return;
        let body=effect.Body;
        Check(body.AwaitingPlacement && !body.bSolid && !body.bShootable && body.bInvisible && body.bNoInteraction,"pending body cannot interact or obstruct");
        let miracle=CaelumMiracleEffect(User.GiveInventoryType("CaelumMiracleEffect"));
        miracle.Revision=1;miracle.RemainingTics=350;miracle.Range=1280;
        let rally=CaelumRallyEffect(User.GiveInventoryType("CaelumRallyEffect"));
        rally.Revision=1;rally.RemainingTics=350;rally.Range=1280;
        Check(!CaelumMiracle.Eligible(miracle,body) && !CaelumRally.Eligible(rally,body)
            && CaelumThermalBody.Get(body)==null,"pending body cannot gain aura resources or thermal simulation");
        miracle.Destroy();rally.Destroy();
    }
    void Placed()
    {
        User=CaelumPlayer(players[consoleplayer].mo);let effect=CaelumSummoning.Status(User);
        Check(effect!=null && effect.Body!=null && !effect.Body.AwaitingPlacement
            && effect.Body.bSolid && effect.Body.bShootable && !effect.Body.bNoInteraction
            && effect.Body.TestMobjLocation(),"pending summon restores its body when space returns");
    }
    void Journey()
    {
        let effect=CaelumSummoning.Status(User);let body=effect.Body;int left=effect.RemainingTics;
        let plan=CaelumJourneyPlan(User.GiveInventoryType("CaelumJourneyPlan"));
        plan.Available=new("CaelumJourneyModel");plan.Available.Capture(User,false);
        plan.Available.ElapsedTics=35;plan.Apply(User);
        Check(CaelumSummoning.Status(User)==effect && effect.Body==body && effect.RemainingTics==left-35,"real journey transaction deducts elapsed summon time");
        plan.Available.ElapsedTics=left;plan.Apply(User);
        Check(CaelumSummoning.Status(User)==null && Count()==0,"journey expires summon before arrival");
    }
    void Follow()
    {
        let effect=CaelumSummoning.Status(User);effect.RemainingTics=1400;
        Before=effect.Body;User.SetOrigin((-400,0,0),false);Anima=Before.Distance3D(User);
    }
    void Combat()
    {
        Console.Printf("CA249 follow before=%.3f now=%.3f body=(%.2f %.2f) user=(%.2f %.2f) speed=%.3f target=%s phase=%d sleep=%d stunned=%.3f",Anima,Before.Distance3D(User),Before.Pos.X,Before.Pos.Y,User.Pos.X,User.Pos.Y,Before.Speed,Before.target==null?"none":"present",Before.RecoveryPhase,Before.ForcedSleepTics,Before.CombatLucidityPhysicalStunRemaining);
        Check(Before.Distance3D(User)<Anima,"native friendly movement follows caster");
        Enemy=CA249Target(Actor.Spawn("CA249Target",Before.Pos+(180,0,0),NO_REPLACE));
        Before.Angle=0;Health=1000000;
    }
    void CombatCheck()
    {
        Check(Enemy!=null && Enemy.health<Health,"native AI acquires enemy and deals real damage");
        Enemy.Destroy();
    }
    void Damage()
    {
        let body=CaelumSummoning.Status(User).Body;
        User.bInvulnerable=false;User.EffectiveEvasionChance=0;
        body.SetOrigin((128,0,0),false);User.SetOrigin((0,0,0),false);
        Ally=CA249Target(Actor.Spawn("CA249Target",(128,100,0),NO_REPLACE));Ally.bFriendly=true;
        Enemy=CA249Target(Actor.Spawn("CA249Target",(128,-100,0),NO_REPLACE));
    }
    void DamageCheck()
    {
        let body=CaelumSummoning.Status(User).Body;int userHealth=User.health,allyHealth=Ally.health,enemyHealth=Enemy.health;
        body.A_Explode(10000,256,XF_NOTMISSILE|XF_THRUSTLESS,false);
        Check(User.health==userHealth && Ally.health==allyHealth && Enemy.health<enemyHealth,"real native area damage protects caster and ally");
        CaelumElementalStream.ApplyContact(body,Ally);CaelumElementalStream.ApplyContact(body,User);CaelumElementalStream.ApplyContact(body,Enemy);
        Check(Ally.ElementalStatus.BurnRemaining==0 && User.ElementalStatus.BurnRemaining==0 && Enemy.ElementalStatus.BurnRemaining>0,"breath applies burning only to enemy");
        Ally.Destroy();Enemy.Destroy();User.bInvulnerable=true;
        double adrenaline=User.CurrentAdrenaline;
        body.DamageMobj(null,User,10000000,'None',DMG_FORCED,0);
        Check(Count()==0 && User.CurrentAdrenaline==adrenaline,"lethal hit removes summon without ally-death reward");
    }
    void ManualEnemies()
    {
        if(Ally!=null)Ally.Destroy();if(Enemy!=null)Enemy.Destroy();
        Ally=CA249Target(Actor.Spawn("CA249Target",(240,150,0),NO_REPLACE));Ally.bFriendly=true;
        Enemy=CA249Target(Actor.Spawn("CA249Target",(350,-100,0),NO_REPLACE));
    }
    void Flight()
    {
        let body=CaelumSummoning.Status(User).Body;body.CaelumDiagnosticPassiveAI=true;
        body.SetOrigin((-400,0,0),false);User.SetOrigin((-200,0,0),false);User.bInvulnerable=false;
        Ally=CA249Target(Actor.Spawn("CA249Target",(0,0,0),NO_REPLACE));Ally.bFriendly=true;
        Enemy=CA249Target(Actor.Spawn("CA249Target",(200,0,0),NO_REPLACE));
        Health=User.health;
        let shot=CaelumActorSimpleElementalProjectile(Actor.Spawn("CaelumActorSimpleElementalProjectile",(-300,0,32),NO_REPLACE));
        shot.Target=body;shot.Vel=(20,0,0);shot.StoreCaelumAttackResult(10000,true,false,true,1);
        body.Destroy();
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="c249_setup")Reset();
        else if(e.Name=="c249_contract")Contract();
        else if(e.Name=="c249_profile")Profile();
        else if(e.Name=="c249_powered")Powered();
        else if(e.Name=="c249_friendly")Friendly();
        else if(e.Name=="c249_seed")Seed();
        else if(e.Name=="c249_loaded")Loaded();
        else if(e.Name=="c249_placement")Placement();
        else if(e.Name=="c249_pending")Pending();
        else if(e.Name=="c249_placed")Placed();
        else if(e.Name=="c249_journey")Journey();
        else if(e.Name=="c249_manual"){Reset();User.Pitch=10;Manual=true;}
        else if(e.Name=="c249_look")User.Pitch=0;
        else if(e.Name=="c249_flight")Flight();
        else if(e.Name=="c249_flight_check")Check(User.health==Health && Ally.health==1000000 && Enemy.health<1000000,"native missile passes caster and ally, damaging enemy after summon disappears");
        else if(e.Name=="c249_manual_enemies")ManualEnemies();
        else if(e.Name=="c249_ready"){User.CurrentAnima=5000;User.ClassSleepCooldownRemaining=0;}
        else if(e.Name=="c249_transfer"){if(CaelumSummoning.Status(User)!=null)Seed();}
        else if(e.Name=="c249_long_journey")
        {
            let plan=CaelumJourneyPlan(User.GiveInventoryType("CaelumJourneyPlan"));
            plan.Available=new("CaelumJourneyModel");plan.Available.Capture(User,false);
            plan.Available.ElapsedTics=CaelumWorldClock.TicsPerHour();plan.Apply(User);
        }
        else if(e.Name=="c249_prep_loaded")
        {
            User=CaelumPlayer(players[consoleplayer].mo);Pin=true;Stats();
            Check(User.ClassCastActive && User.ClassCastPaid>0 && User.ClassCastPaid<1000 && Count()==0,"loaded preparation keeps partial payment before release");
        }
        else if(e.Name=="c249_loaded_cast")Check(!User.ClassCastActive && User.ClassCastPaid==1000 && Count()==1,"loaded preparation releases exactly one paid summon");
        else if(e.Name=="c249_kill_caster"){User.health=User.player.health=0;Pin=false;}
        else if(e.Name=="c249_failure")Check(!User.ClassCastActive && User.ClassCastPaid==1000 && User.ClassSleepCooldownRemaining==0 && Count()==0,"blocked release retains paid Anima without cooldown");
        else if(e.Name=="c249_follow")Follow();
        else if(e.Name=="c249_combat")Combat();
        else if(e.Name=="c249_combat_check")CombatCheck();
        else if(e.Name=="c249_damage")Damage();
        else if(e.Name=="c249_damage_check")DamageCheck();
        else if(e.Name=="c249_partial")Check(User.ClassCastActive && abs(User.ClassCastPaid-1000.0/3)<20,"native User4 progressive payment");
        else if(e.Name=="c249_cancel")Check(!User.ClassCastActive && User.ClassCastPaid>0 && User.ClassSleepCooldownRemaining==0 && Count()==0,"native cancellation no refund or cooldown");
        else if(e.Name=="c249_cast")Check(!User.ClassCastActive && User.ClassCastPaid==1000 && User.ClassSleepCooldownRemaining>59 && Count()==1,"native release charges once and starts cooldown");
        else if(e.Name=="c249_expired")Check(CaelumSummoning.Status(User)==null && Count()==0,"expiry removes only owned summon");
        else if(e.Name=="c249_done")Console.Printf("CA249 DONE failures=%d passed=%d",Failed,Passed);
    }
    override void RenderOverlay(RenderEvent e)
    {
        let user=CaelumPlayer(players[consoleplayer].mo);if(!Manual || user==null)return;
        let effect=CaelumSummoning.Status(user);let body=effect!=null?effect.Body:null;
        String line=String.Format("INVOCACION | Efecto %.1fs | Reutilizacion %.1fs | F lanzar/cancelar | F6 reiniciar",
            effect==null?0:effect.RemainingTics/35.0,user.ClassSleepCooldownRemaining);
        Screen.DrawText(SmallFont,Font.CR_WHITE,88,8,line,DTA_VIRTUALWIDTHF,640.0,DTA_VIRTUALHEIGHTF,360.0);
        line=String.Format("Zupay: Salud %d | Anima %.0f | Aire %.0f | %s",body==null?0:body.health,
            body==null?0:body.CurrentCombatAnima,body==null?0:body.CurrentCombatAir,
            body==null?"Sin invocacion":body.AwaitingPlacement?"Esperando espacio":"Presente");
        Screen.DrawText(SmallFont,Font.CR_WHITE,88,20,line,DTA_VIRTUALWIDTHF,640.0,DTA_VIRTUALHEIGHTF,360.0);
        line=String.Format("Aliado: %d | Enemigo: %d | F7 recargar Anima/reutilizacion | F8 crear ambos",
            Ally==null?0:Ally.health,Enemy==null?0:Enemy.health);
        Screen.DrawText(SmallFont,Font.CR_WHITE,88,32,line,DTA_VIRTUALWIDTHF,640.0,DTA_VIRTUALHEIGHTF,360.0);
        Screen.DrawText(SmallFont,Font.CR_WHITE,88,44,"Apunta al suelo. F9: herir Zupay y cambiar mapa | F10: viaje de una hora",
            DTA_VIRTUALWIDTHF,640.0,DTA_VIRTUALHEIGHTF,360.0);
    }
}
