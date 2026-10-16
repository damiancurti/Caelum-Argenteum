// Valores controlados de laboratorio: no son balance del juego.
class CA250Target : CaelumMandinga
{
    bool ProbeInitialized;
    override void PostBeginPlay()
    {if(ProbeInitialized)return;Super.PostBeginPlay();ProbeInitialized=true;}
    // Blanco quieto; los daños periódicos sí resuelven su ruta real por tic.
    override void Tick(){if(health<=0)Super.Tick();else if(ElementalStatus!=null)ElementalStatus.Tick(self);}
}
class CA250Drop : Inventory { Default {Inventory.MaxAmount 10;} States {Spawn:TNT1 A -1;Stop;} }
class CA250Large : CaelumZupayColossus
{
    bool ProbeInitialized;
    override void PostBeginPlay()
    {if(ProbeInitialized)return;Super.PostBeginPlay();ProbeInitialized=true;}
    override void Tick(){if(health<=0)Super.Tick();}
}
class CA250LootTarget : CA250Target { Default {DropItem "CA250Drop",255,1;} }
// Cuerpo neutral explícito: el motor sólo asigna CORPSE automáticamente a monstruos.
class CA250Neutral : CA250Target
{
    override void Die(Actor source,Actor inflictor,int flags,Name mod)
    {Super.Die(source,inflictor,flags,mod);bCorpse=true;}
    Default {-ISMONSTER +FRIENDLY}
}
class CA250Checkpoint : Inventory
{
    Actor Body;
    int Health,Remaining;
    double Anima,Air;
    Default {Inventory.MaxAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA250Probe : StaticEventHandler
{
    CaelumPlayer User;
    CaelumCombatActor Hostile,Ally,Neutral,Living,Late,Blocked,Occluded;
    int Passed,Failed,Total,FirstDrops;
    double SavedAdrenaline,Distance,UserReduction,LivingReduction,RaisedReduction;
    bool Pin,Manual;
    void Check(bool ok,String label)
    {if(ok)Passed++;else Failed++;Console.Printf("CA250 %s %s",ok?"PASS":"FAIL",label);}
    void Stats()
    {
        User.DerivedStats.MaximumAnima=10000;User.DerivedStats.AnimaCostReductionPercent=0;
        User.DerivedStats.BuffPowerPercent=100;User.DerivedStats.AbilityRangePercent=100;
        User.DerivedStats.AnimaRegenerationPerSecond=User.DerivedStats.HealthRegenerationPerSecond=0;
        User.CombatTimeRemaining=2;
    }
    override void WorldTick()
    {
        if(Pin && User!=null)Stats();
        if(Manual)
        {UserReduction=CaelumRedemption.ToughnessFactor(User);LivingReduction=CaelumRedemption.ToughnessFactor(Living);
            RaisedReduction=CaelumRedemption.ToughnessFactor(Hostile);}
    }
    override void UiTick(){if(!Manual && Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();}
    void Setup()
    {
        User=CaelumPlayer(players[consoleplayer].mo);
        User.CharacterCreationComplete=true;User.CreationWizardOpen=false;
        User.CharacterProfile.FirstClass=CaelumConstants.CLASS_EXPLORER;
        User.CharacterProfile.SecondClass=CaelumConstants.CLASS_PRIEST;
        User.ApplyCharacterProfile();User.SetOrigin((0,0,0),false);User.Vel=(0,0,0);User.Angle=0;
        User.CurrentSleep=User.CurrentLucidity=100;User.bInvulnerable=true;
        User.CurrentAnima=5000;User.ClassSleepCooldownRemaining=0;
        CaelumClassAbilityRules.Cancel(User);User.ClassPreparationTics=0;
        User.ClassSleepInputLatched=false;Pin=true;Stats();
    }
    CaelumCombatActor Body(class<CaelumCombatActor> type,vector3 point,bool friendly=false)
    {
        let body=CaelumCombatActor(Actor.Spawn(type,point,NO_REPLACE));
        body.PostBeginPlay();
        body.bFriendly=friendly;body.CurrentCombatAnima=17;body.CurrentCombatAir=13;
        body.CurrentCombatLucidity=11;return body;
    }
    void Kill(Actor body)
    {body.DamageMobj(null,null,10000000,'None',DMG_FORCED,0);Check(body.health<=0 && body.bCorpse,"fixture creates a real native corpse");}
    void Corpses()
    {
        Hostile=Body("CA250LootTarget",(160,0,0));Ally=Body("CA250Target",(0,160,0),true);
        Neutral=Body("CA250Neutral",(-160,0,0),true);Living=Body("CA250Target",(0,-160,0),true);
        Occluded=Body("CA250Target",(768,0,0));
        Kill(Hostile);Kill(Ally);Kill(Neutral);Kill(Occluded);
        Total=level.total_monsters;
    }
    int Drops()
    {int n=0;let it=ThinkerIterator.Create("CA250Drop");while(it.Next()!=null)n++;return n;}
    void Released()
    {
        FirstDrops=Drops();
        Check(FirstDrops==1,"original death produces exactly one authored drop");
        Check(CaelumClassAbilityRules.CanCast(User),"Pilgrim enters shared cast lifecycle");
        Check(CaelumRedemption.Release(User),"Redemption release succeeds");
        let effect=CaelumRedemption.Status(User);
        Check(effect!=null && effect.RemainingTics==350 && effect.PulseTics==35 && effect.Range==1280,"base mobile area clocks and range");
        Check(Hostile.health>0 && Ally.health>0 && Neutral.health>0,"immediate resurrection of enemies allies and neutrals");
        Check(Occluded.health<=0,"wall prevents corpse resurrection");
        Check(CaelumRedemption.Commander(Hostile)==User && Hostile.IsFriend(User),"former enemy becomes owned ally");
        Check(CaelumRedemption.Commander(Ally)==null && CaelumRedemption.Commander(Neutral)==null,"original allies and neutrals are permanent");
        Check(Hostile.health==Hostile.CombatMaximumHealth && Hostile.CurrentCombatAnima==Hostile.MaximumCombatAnima
            && Hostile.CurrentCombatAir==Hostile.MaximumCombatAir && Hostile.CurrentCombatLucidity==100,"all four resources restored to current maxima");
        Check(Hostile.Height==GetDefaultByType("CA250LootTarget").Height && Hostile.TestMobjLocation(),"full-size body fits");
        Check(level.total_monsters==Total && !Hostile.bCountKill,"native kill count is not duplicated");
        Check(CaelumRedemption.ToughnessFactor(User)==4 && CaelumRedemption.ToughnessFactor(Living)==4,"caster and already-living ally receive factor four");
        Check(CaelumRedemption.ToughnessFactor(Hostile)==1 && CaelumRedemption.ToughnessFactor(Ally)==1,"this cast excludes its resurrected bodies from Toughness");
        double reduction=CaelumToughnessRules.Reduction(Living.Mass,CaelumToughnessRules.Effective(Living));
        Check(abs(CaelumToughnessRules.Apply(Living,reduction*10)-reduction*6)<0.01,"fixed reduction scales rather than the Toughness attribute");
        Check(abs(CaelumToughnessRules.Apply(Living,reduction*10,true)-reduction*8)<0.01,"magical half reduction also scales");
        Living.SetOrigin((2000,0,0),false);
        Check(CaelumRedemption.ToughnessFactor(Living)==1,"living ally loses benefit outside radius");
        Living.SetOrigin((768,0,0),false);
        Check(CaelumRedemption.ToughnessFactor(Living)==1,"living ally loses benefit behind wall");
        Living.SetOrigin((0,-160,0),false);
        Late=Body("CA250Target",(-160,-160,0));Kill(Late);
    }
    void BeforePulse(){Check(Late.health<=0,"new corpse waits until first one-second pulse");}
    void AfterPulse()
    {
        Check(Late.health>0 && CaelumRedemption.Commander(Late)==User,"next one-second pulse revives a new corpse");
        SavedAdrenaline=User.CurrentAdrenaline;Kill(Hostile);CaelumRedemption.Pulse(CaelumRedemption.Status(User));
        Check(Hostile.health<=0,"same cast never raises the same body twice");
        Check(User.CurrentAdrenaline==SavedAdrenaline,"repeat death grants no kill or ally-death Adrenaline");
    }
    void Expire()
    {
        Check(Drops()==FirstDrops,"repeat death produces no second predefined drop");
        let effect=CaelumRedemption.Status(User);effect.Destroy();
        Check(Late.health<=0 && !Late.bFriendly,"former enemy dies and restores original allegiance on expiry");
        Check(Ally.health>0 && Neutral.health>0,"original allies and neutrals remain alive on expiry");
        Check(CaelumRedemption.ToughnessFactor(User)==1,"expiry removes caster Toughness");
    }
    void Cure()
    {
        Hostile=Body("CA250Target",(160,0,0));Kill(Hostile);
        Hostile.ElementalStatus=new("CaelumElementalStatus");
        let status=Hostile.ElementalStatus;
        status.BurnRemaining=status.PoisonRemaining=status.DiseaseRemaining=8;
        status.CutRemaining=status.FreezeRemaining=status.DazzleRemaining=8;
        status.EarthPenaltyRemaining=status.LightningStunRemaining=8;
        Hostile.ForcedSleepTics=100;Hostile.CombatLucidityPhysicalStunRemaining=9;
        CaelumRedemption.Release(User);
        status=Hostile.ElementalStatus;
        Check(Hostile.health>0 && status.BurnRemaining==0 && status.PoisonRemaining==0 && status.DiseaseRemaining==0
            && status.CutRemaining==0 && status.FreezeRemaining==0 && status.DazzleRemaining==0
            && status.EarthPenaltyRemaining==0 && status.LightningStunRemaining==0,"resurrection clears negative elemental states");
        Check(Hostile.ForcedSleepTics==0 && Hostile.CombatLucidityPhysicalStunRemaining==0,"resurrection clears sleep and stun");
        status.BurnRemaining=8;status.ToughnessRevision=1;status.BaseRemaining[0]=8;status.ResponseFactors[0]=-1;
        Hostile.CombatToughness=125;
        CaelumResurrection.ClearNegative(Hostile);
        Check(status.BurnRemaining>0 && status.ResponseFactors[0]<0,"beneficial inverted dose is preserved");
    }
    void Renew()
    {
        Hostile=Body("CA250Target",(160,0,0));Kill(Hostile);CaelumRedemption.Release(User);
        let effect=CaelumRedemption.Status(User);effect.RemainingTics=900;effect.PulseTics=17;
        Kill(Hostile);Pin=false;User.DerivedStats.BuffPowerPercent=200;CaelumRedemption.Release(User);
        Check(CaelumRedemption.Status(User)==effect && effect.RemainingTics==900 && effect.Power==2
            && effect.PulseTics==17,"recast keeps longest duration and next pulse with new power");
        Check(Hostile.health>0 && effect.Converts.Size()==1 && effect.RaisedThisCast.Size()==1,"new cast can raise same corpse without duplicate ownership");
        Check(CaelumRedemption.ToughnessFactor(User)==8,"Empathy scales complete factor");
        let other=CaelumRedemptionEffect(Actor.Spawn("CaelumRedemptionEffect",User.Pos,NO_REPLACE));
        other.Owner=User;other.Revision=1;other.RemainingTics=500;other.Power=3;other.Range=1280;
        Check(CaelumRedemption.ToughnessFactor(User)==12,"overlapping areas use strongest factor without multiplication");
        other.Owner=null;other.Destroy();
    }
    void Friendly()
    {
        Hostile=Body("CA250Target",(160,0,0));Kill(Hostile);CaelumRedemption.Release(User);
        Living=Body("CA250Target",(0,160,0),true);Late=Body("CA250Target",(-160,0,0));
        int before=Living.health;
        Living.DamageMobj(Hostile,Hostile,100000,'None',0,0);
        Check(Living.health==before && Hostile.DoSpecialDamage(User,100,'None')==0,"converted attacks protect allies and caster");
        Check(Hostile.DoSpecialDamage(Late,100,'None')==100,"converted attacks still damage enemies");
        Check(Hostile.DoSpecialDamage(Hostile,100,'CaelumImpact')==100,"conversion grants no immunity to own collisions");
        CaelumElementalStream.ApplyContact(Hostile,Living);
        Check(Living.ElementalStatus==null || Living.ElementalStatus.BurnRemaining==0,"converted breath does not burn allies");
        let shot=CaelumActorExplosiveElementalProjectile(Actor.Spawn("CaelumActorExplosiveElementalProjectile",(0,0,200),NO_REPLACE));
        shot.Target=Hostile;shot.StoreCaelumAttackResult(100,true,false,true,1);
        Check(shot.PreventSummoningFriendlyFire(User) && !shot.PreventSummoningFriendlyFire(Late),"converted projectile captures enemy-only policy");
        CaelumRedemption.Status(User).Destroy();
        Check(shot.PreventSummoningFriendlyFire(User) && !shot.PreventSummoningFriendlyFire(Late),"projectile protects allies after conversion expires");shot.Destroy();
    }
    void Fit()
    {
        Hostile=Body("CA250Target",(160,0,0));Kill(Hostile);
        Blocked=Body("CA250Target",(160,0,0),true);
        CaelumRedemption.Release(User);
        Check(Hostile.health>0 && Hostile.TestMobjLocation() && (Hostile.Pos-Blocked.Pos).Length()>Hostile.Radius,"blocked corpse moves to nearby valid full-size space");
        let place=CaelumSummoning.FindPlace(User,User.Pos,1,Hostile.Radius,Hostile.Height);
        Check(!place.Found,"no valid fitting place cannot escape range");
    }
    void Seed()
    {
        Hostile=Body("CA250Large",(160,0,0));Kill(Hostile);CaelumRedemption.Release(User);
        Hostile.health=123;Hostile.CurrentCombatAnima=17;Hostile.CurrentCombatAir=13;
        let saved=CA250Checkpoint(User.GiveInventoryType("CA250Checkpoint"));
        saved.Body=Hostile;saved.Health=123;saved.Anima=17;saved.Air=13;
        saved.Remaining=CaelumRedemption.Status(User).RemainingTics;
    }
    void Loaded()
    {
        User=CaelumPlayer(players[consoleplayer].mo);let saved=CA250Checkpoint(User.FindInventory("CA250Checkpoint"));
        let effect=CaelumRedemption.Status(User);
        Check(saved!=null && effect!=null && saved.Body!=null,"effect and body survive save or map travel");
        if(saved==null || effect==null || saved.Body==null)return;
        Hostile=CaelumCombatActor(saved.Body);
        Check(CaelumRedemption.Commander(Hostile)==User && effect.Converts.Size()==1,"identity and conversion ownership survive");
        Check(Hostile.health==123 && Hostile.CurrentCombatAnima==17 && Hostile.CurrentCombatAir==13,"travel and reload preserve resources without healing");
        Check(effect.RemainingTics>0 && effect.RemainingTics<saved.Remaining,"remaining duration continues");
        Check(effect.Raised(Hostile),"per-cast resurrection latch survives");
    }
    void Pending()
    {Check(CaelumRedemption.Pending(Hostile) && !Hostile.bSolid && !Hostile.bShootable,"blocked arrival waits noninteractively");}
    void Placed()
    {Check(!CaelumRedemption.Pending(Hostile) && Hostile.TestMobjLocation() && Hostile.bSolid,"fitting destination restores body interaction");}
    void Journey()
    {
        let plan=CaelumJourneyPlan(User.GiveInventoryType("CaelumJourneyPlan"));
        plan.Available=new("CaelumJourneyModel");plan.Available.Capture(User,false);
        plan.Available.ElapsedTics=35;plan.Apply(User);
        Check(CaelumRedemption.Status(User).RemainingTics==315 && Hostile.health==123,"real short journey transaction consumes duration without healing");
        plan.Available.ElapsedTics=350;plan.Apply(User);
        Check(CaelumRedemption.Status(User)==null && Hostile.health<=0,"real long journey transaction expires and kills temporary ally");
    }
    void KillCaster(){User.bInvulnerable=false;Kill(User);}
    void DeadCaster()
    {Check(User.health<=0 && CaelumRedemption.Status(User)==null && Hostile.health<=0,"caster death terminates area and conversion");}
    void NativeBody()
    {Hostile=CaelumCombatActor(Actor.Spawn("CaelumMandinga",(320,0,0),NO_REPLACE));Hostile.bDormant=true;}
    void Follow()
    {
        Kill(Hostile);CaelumRedemption.Release(User);Hostile.bDormant=false;
        User.SetOrigin((-200,0,0),false);Distance=Hostile.Distance2D(User);
    }
    void Followed()
    {
        Check(Hostile.health>0 && Hostile.Distance2D(User)<Distance-40,"real Mandinga follows caster with native collision and movement");
        Check(Hostile.target==null || Hostile.target!=User,"follower never targets its caster");
        Living=Body("CA250Target",Hostile.Pos+(180,150,0),true);
        Late=Body("CA250Target",Hostile.Pos+(180,0,0));Late.health=Late.CombatMaximumHealth=1000000;
        Late.ClearCombatArmorToBaseClothing();Late.CombatToughness=0;Late.EffectiveCombatEvasionChance=0;
        Total=Late.health;
        Hostile.target=null;Hostile.Angle=0;
        CaelumRedemption.Status(User).RemainingTics=500;
    }
    void Combat()
    {
        Console.Printf("CA250 combat enemy=%d/%d ally=%d/%d distance=%.2f target=%s phase=%d air=%.2f anima=%.2f",
            Late.health,Total,Living.health,Living.CombatMaximumHealth,Hostile.Distance2D(Late),
            Hostile.target==Late?"enemy":Hostile.target==null?"none":"other",Hostile.RecoveryPhase,
            Hostile.CurrentCombatAir,Hostile.CurrentCombatAnima);
        Console.Printf("CA250 attack=%d received=%.2f afterArmor=%.2f afterToughness=%.2f evaded=%d",
            Hostile.LastCombatAttackCalculatedDamage,Late.LastCombatArmorIncomingDamage,Late.LastCombatArmorPostDefenseDamage,
            Late.LastCombatPostToughnessDamage,Late.LastCombatEvasionSucceeded);
        Check(Late.health<Total && Living.health==Living.CombatMaximumHealth,"real converted AI damages enemies without hurting ally");
    }
    void PlayerRestore()
    {
        CaelumRally.Release(User);CaelumMiracle.Release(User);CaelumSurvivalInstinct.Release(User);
        CaelumFormationBreaker.Release(User);User.Pitch=30;
        Check(CaelumSummoning.Release(User) && CaelumFormationBreaker.Status(User)!=null,
            "cleanup fixture has live summon and Formation Breaker before player death");
        let profile=User.CharacterProfile;let inventory=User.GiveInventoryType("CA250Checkpoint");
        User.bInvulnerable=false;Kill(User);
        Check(CaelumResurrection.Restore(User,User.Pos),"production helper revives active dead player");
        Check(User.player.playerstate==PST_LIVE && User.player.mo==User && User.CharacterProfile==profile,
            "player identity profile and live control survive resurrection");
        Check(User.health==User.CaelumMaximumHealth && User.CurrentAnima==User.DerivedStats.MaximumAnima
            && User.CurrentAir==User.DerivedStats.MaximumAir && User.CurrentLucidity==100,"player receives four full resources");
        Check(User.FindInventory("CA250Checkpoint")==inventory,"player resurrection preserves inventory identity");
        Check(CaelumRally.Status(User)==null && CaelumMiracle.Status(User)==null && CaelumSurvivalInstinct.Status(User)==null,
            "same-tic resurrection does not retain effects that end on caster death");
        Check(CaelumSummoning.Status(User)==null && CaelumFormationBreaker.Status(User)==null
            && ThinkerIterator.Create("CaelumSummonedZupay").Next()==null,
            "same-tic resurrection cannot preserve dead caster summon or dash effect");
        Kill(User);
        let other=PlayerPawn(Actor.Spawn("CaelumPlayer",(300,300,0),NO_REPLACE));
        User.player.mo=other;
        Check(!CaelumResurrection.Restore(User,User.Pos) && User.health<=0,"old player corpse cannot duplicate a current different pawn");
        User.player.mo=User;other.Destroy();CaelumResurrection.Restore(User,User.Pos);User.bInvulnerable=true;
    }
    void Defense()
    {
        Living=Body("CA250Target",(160,0,0),true);Living.ClearCombatArmorToBaseClothing();
        Living.EffectiveCombatEvasionChance=0;Living.CombatToughness=11;
        User.ArmorModel=new("CaelumArmorModel");User.ArmorModel.InitializeDefaults();
        User.Attributes.Toughness=11;User.EffectiveEvasionChance=0;User.bInvulnerable=false;
        User.CurrentLucidity=100;CaelumRedemption.Release(User);
        Late=Body("CA250Target",(300,300,0));
        for(int magical=0;magical<2;magical++)
        {
            Name mod=magical?'Fire':'Melee';
            Living.health=100000;Living.CurrentCombatLucidity=100;
            Living.DamageMobj(Late,Late,2000,mod,DMG_THRUSTLESS,0);
            double r=CaelumToughnessRules.Reduction(Living.Mass,11,magical!=0)*4;
            Check(abs(Living.LastCombatPostToughnessDamage-Max(0.0,Living.LastCombatArmorPostDefenseDamage-r))<0.01,
                magical?"native NPC magic defense scales final reduction":"native NPC physical defense scales final reduction");
            User.health=User.player.health=100000;User.CurrentLucidity=100;User.LucidityPhysicalStunRemaining=0;
            User.DamageMobj(Late,Late,2000,mod,DMG_THRUSTLESS,0);
            r=CaelumToughnessRules.Reduction(CaelumToughnessRules.NaturalMass(User),11,magical!=0)*4;
            Check(abs(User.LastToughnessDamageMultiplier-CaelumToughnessRules.RetainedFraction(
                User.LastArmorPostDefenseDamage,Max(0.0,User.LastArmorPostDefenseDamage-r)))<0.0001,
                magical?"native player magic defense scales final reduction":"native player physical defense scales final reduction");
        }
        Living.health=100000;Living.RegisterWorldImpact(50,CaelumConstants.IMPACT_KIND_WALL);
        Check(abs(Living.LastImpactToughnessPercent-100*CaelumToughnessRules.ActorReduction(Living,11)/Living.GetImpactMaximumHealth())<0.01,
            "native NPC collision uses area Toughness");
        double expected=100*CaelumToughnessRules.ActorReduction(User,11)/User.GetImpactMaximumHealth();
        User.health=User.player.health=100000000;User.RegisterWorldImpact(50,CaelumConstants.IMPACT_KIND_WALL);
        Check(abs(User.LastImpactToughnessPercent-expected)<0.01,
            "native player collision uses area Toughness");
    }
    void ManualSetup()
    {
        User=CaelumPlayer(players[consoleplayer].mo);
        let effect=CaelumRedemption.Status(User);if(effect!=null)effect.Destroy();
        let it=ThinkerIterator.Create("CaelumCombatActor");Actor body;
        while((body=Actor(it.Next()))!=null)body.Destroy();
        Setup();Manual=true;User.Pitch=8;
        Hostile=CaelumCombatActor(Actor.Spawn("CaelumMandinga",(240,0,0),NO_REPLACE));Hostile.bDormant=true;
        Ally=Body("CA250Target",(240,160,0),true);
        Living=Body("CA250Target",(240,-160,0),true);
        Late=null;
    }
    void ManualCorpses(){Kill(Hostile);Kill(Ally);}
    void ManualLate()
    {
        if(Late==null)Late=Body("CA250Target",User.Pos+(128,-128,0));
        if(Late.health>0)Kill(Late);
    }
    void ManualJourney()
    {
        let plan=CaelumJourneyPlan(User.GiveInventoryType("CaelumJourneyPlan"));
        plan.Available=new("CaelumJourneyModel");plan.Available.Capture(User,false);
        plan.Available.ElapsedTics=CaelumWorldClock.TicsPerHour();plan.Apply(User);
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="c250_setup")Setup();else if(e.Name=="c250_corpses")Corpses();
        else if(e.Name=="c250_release")Released();else if(e.Name=="c250_before")BeforePulse();
        else if(e.Name=="c250_after")AfterPulse();else if(e.Name=="c250_expire")Expire();
        else if(e.Name=="c250_cure")Cure();else if(e.Name=="c250_renew")Renew();
        else if(e.Name=="c250_friendly")Friendly();else if(e.Name=="c250_fit")Fit();
        else if(e.Name=="c250_seed")Seed();else if(e.Name=="c250_loaded")Loaded();
        else if(e.Name=="c250_pending")Pending();else if(e.Name=="c250_placed")Placed();
        else if(e.Name=="c250_pending_expired")
        {
            Check(CaelumRedemption.Status(User)==null && Hostile.health<=0 && Hostile.bCorpse,
                "blocked arrival expires into the same dead body");
            Check(!CaelumRedemption.Pending(Hostile) && !Hostile.bInvisible && !Hostile.bSolid,
                "expired pending body leaves no invisible interactive orphan");
        }
        else if(e.Name=="c250_journey")Journey();else if(e.Name=="c250_kill_caster")KillCaster();
        else if(e.Name=="c250_dead_caster")DeadCaster();
        else if(e.Name=="c250_native")NativeBody();else if(e.Name=="c250_follow")Follow();
        else if(e.Name=="c250_followed")Followed();else if(e.Name=="c250_combat")Combat();
        else if(e.Name=="c250_player")PlayerRestore();
        else if(e.Name=="c250_defense")Defense();
        else if(e.Name=="c250_manual")ManualSetup();else if(e.Name=="c250_manual_corpses")ManualCorpses();
        else if(e.Name=="c250_manual_late")ManualLate();
        else if(e.Name=="c250_ready"){User.CurrentAnima=5000;User.ClassSleepCooldownRemaining=0;}
        else if(e.Name=="c250_manual_journey")ManualJourney();
        else if(e.Name=="c250_prep_loaded")
        {
            User=CaelumPlayer(players[consoleplayer].mo);Pin=true;Stats();
            Check(User.ClassCastActive && User.ClassCastPaid>0 && User.ClassCastPaid<1000
                && CaelumRedemption.Status(User)==null,"saved preparation retains partial paid cost before release");
        }
        else if(e.Name=="c250_loaded_cast")
            Check(!User.ClassCastActive && User.ClassCastPaid==1000 && CaelumRedemption.Status(User)!=null,
                "saved preparation releases one paid Redemption");
        else if(e.Name=="c250_partial")Check(User.ClassCastActive && User.ClassCastPaid>0 && User.ClassCastPaid<1000
            && CaelumRedemption.Status(User)==null,"native User4 progressively pays before release");
        else if(e.Name=="c250_cancel")Check(!User.ClassCastActive && User.ClassCastPaid>0 && User.ClassSleepCooldownRemaining==0
            && CaelumRedemption.Status(User)==null,"native User4 cancellation retains cost without effect or reuse");
        else if(e.Name=="c250_cast")Check(!User.ClassCastActive && User.ClassCastPaid==1000 && User.ClassSleepCooldownRemaining>59
            && CaelumRedemption.Status(User)!=null && Hostile.health>0,"native three-second release raises corpse and starts reuse");
        else if(e.Name=="c250_done")Console.Printf("CA250 DONE failures=%d passed=%d",Failed,Passed);
    }
    override void RenderOverlay(RenderEvent e)
    {
        let user=CaelumPlayer(players[consoleplayer].mo);if(!Manual || user==null)return;
        let effect=CaelumRedemption.Status(user);
        String line=String.Format("REDENCION | Efecto %.1fs | Reutilizacion %.1fs | F lanzar/cancelar | F6 reiniciar",
            effect==null?0:effect.RemainingTics/35.0,user.ClassSleepCooldownRemaining);
        Screen.DrawText(SmallFont,Font.CR_WHITE,80,8,line,DTA_VIRTUALWIDTHF,640.0,DTA_VIRTUALHEIGHTF,360.0);
        line=String.Format("Enemigo (centro): %d | Aliado revivido (izq.): %d | Aliado vivo (der.): %d",
            Hostile==null?0:Max(0,Hostile.health),Ally==null?0:Max(0,Ally.health),Living==null?0:Max(0,Living.health));
        Screen.DrawText(SmallFont,Font.CR_WHITE,80,20,line,DTA_VIRTUALWIDTHF,640.0,DTA_VIRTUALHEIGHTF,360.0);
        line=String.Format("Reduccion por Dureza: tu x%.1f | aliado vivo x%.1f | resucitado x%.1f",
            UserReduction,LivingReduction,RaisedReduction);
        Screen.DrawText(SmallFont,Font.CR_WHITE,80,32,line,DTA_VIRTUALWIDTHF,640.0,DTA_VIRTUALHEIGHTF,360.0);
        Screen.DrawText(SmallFont,Font.CR_WHITE,80,44,"F7 recargar Anima/reutilizacion | F8 nuevo cadaver; repetir lo mata otra vez",
            DTA_VIRTUALWIDTHF,640.0,DTA_VIRTUALHEIGHTF,360.0);
        Screen.DrawText(SmallFont,Font.CR_WHITE,80,56,"F9 cambiar mapa con los antiguos enemigos | F10 viaje de una hora",
            DTA_VIRTUALWIDTHF,640.0,DTA_VIRTUALHEIGHTF,360.0);
    }
}
