// Valores de laboratorio; no forman parte del balance publicado.
class CA284Body : CaelumMandinga
{
    override void Tick(){}
}
class CA284ReviewCamera : Actor
{
    Default { Radius 1; Height 1; +NOGRAVITY +NOBLOCKMAP +NOINTERACTION }
    States { Spawn: TNT1 A -1; Stop; }
}
class CA284Probe : StaticEventHandler
{
    CaelumPlayer User;
    CaelumMandinga Attacker;
    CA284Body Body;
    int Passed,Failed;
    CaelumZupayColossus Zupay;
    CaelumActorExplosiveElementalProjectile Flight;
    vector3 FlightStart,FlightVelocity;
    bool Manual;
    void Check(bool ok,String text)
    {if(ok)Passed++;else Failed++;Console.Printf("CA284 %s %s",ok?"PASS":"FAIL",text);}
    void Setup()
    {
        User=CaelumPlayer(players[consoleplayer].mo);
        User.CharacterCreationComplete=true;User.CreationWizardOpen=false;User.ApplyCharacterProfile();
        User.bInvulnerable=false;User.bBuddha=true;User.CancelCombatBlockMode();
        User.CombatChannelModeActive=false;User.EquipmentMenuOpen=false;
        User.health=User.player.health=100000;User.CaelumMaximumHealth=100000;
        User.CurrentLucidity=100;User.UpdateLucidityState();User.EffectiveEvasionChance=0;
        User.SetOrigin((0,0,0),false);User.Angle=0;
        Attacker=CaelumMandinga(Actor.Spawn("CaelumMandinga",(48,0,0),NO_REPLACE));
        Attacker.CaelumDiagnosticPassiveAI=true;Attacker.Target=User;
        Body=CA284Body(Actor.Spawn("CA284Body",(0,128,0),NO_REPLACE));
        Body.EffectiveCombatEvasionChance=0;Body.CombatMaximumHealth=Body.health=100000;
        Body.bBuddha=true;
    }
    CaelumMixedMeleeDamage Packet(Actor victim,int physical=500,int fire=700,bool critical=false,bool evasion=false)
    {
        let npc=CaelumCombatActor(victim);let user=CaelumPlayer(victim);
        if(!evasion){if(npc!=null)npc.EffectiveCombatEvasionChance=0;if(user!=null)user.EffectiveEvasionChance=0;}
        let hit=new("CaelumMixedMeleeDamage");hit.Attacker=Attacker;hit.Victim=victim;
        hit.FireDamage=hit.FireAfterShield=fire;hit.Critical=critical;hit.DebuffPower=1;
        Attacker.PendingMixedMelee=hit;Attacker.PendingCombatCriticalDelivery=critical;
        victim.DamageMobj(Attacker,Attacker,physical,'Melee',DMG_THRUSTLESS,0);
        Attacker.PendingMixedMelee=null;return hit;
    }
    void Contract()
    {
        Body.CombatMaximumHealth=Body.health=100000;Body.bBuddha=true;Body.EffectiveCombatEvasionChance=0;
        User.health=User.player.health=100000;User.CaelumMaximumHealth=100000;User.EffectiveEvasionChance=0;
        Check(Attacker.CombatStrength==6 && Attacker.CombatIntelligence==6
            && Attacker.CombatToughness==6 && Attacker.CombatConstitution==6 && Attacker.CombatAgility==6
            && Attacker.CombatDexterity==6 && Attacker.CombatResilience==6 && Attacker.CombatCharisma==6
            && Attacker.CombatEmpathy==6 && Attacker.CombatEloquence==6 && Attacker.CombatPatience==6
            && Attacker.CombatInsight==6,"all twelve Mandinga base attributes remain six");
        Check(CaelumPersonalityRules.Pack(Attacker.CombatPersonality)==6
            && CaelumPersonalityRules.MagicPower(Attacker.CombatPersonality)==1.5,"Mandinga approved personality");
        let z=CaelumZupayColossus(Actor.Spawn("CaelumZupayColossus",(400,0,0),NO_REPLACE));
        z.InitializeUniformFolkloreProfile(CaelumConstants.ZUPAY_ATTRIBUTE_LEVEL);z.EnsureCombatPersonality();
        Check(z.CombatIntelligence==CaelumConstants.ZUPAY_ATTRIBUTE_LEVEL
            && CaelumPersonalityRules.Pack(z.CombatPersonality)==80
            && CaelumPersonalityRules.MagicPower(z.CombatPersonality)==3.375,"Zupay personality preserves base attributes");
        z.Destroy();
        int savedHealth=Attacker.health-10;Attacker.health=savedHealth;
        double anima=Attacker.CurrentCombatAnima*0.4,air=Attacker.CurrentCombatAir*0.3;
        Attacker.CurrentCombatAnima=anima;Attacker.CurrentCombatAir=air;
        Attacker.CombatPersonalityRevision=1;Attacker.CombatPersonality=null;
        Attacker.EnsureCombatPersonality();Attacker.EnsureCombatPersonality();
        Check(Attacker.CombatPersonalityRevision==2 && Attacker.health==savedHealth
            && Attacker.CurrentCombatAnima==anima && Attacker.CurrentCombatAir==air,"personality migration idempotent without healing or refill");
        Attacker.UpdateActorOffensiveStatistics();
        let prepared=Attacker.PrepareMixedMelee(User,CaelumConstants.MANDINGA_MACHETE_BASE_DAMAGE);
        Check(prepared.FireDamage==int(CaelumConstants.MANDINGA_MACHETE_BASE_DAMAGE
            *Attacker.CalculateActorType1Percent(Attacker.CombatEffectiveIntelligence)/100.0
            *1.5*Attacker.CombatHealthPerformanceMultiplier+0.5),"extra fire uses machete base Intelligence personality and health once");
        int before=User.health;let hit=Packet(User);
        Check(before-User.health==int(hit.AfterToughness+0.5) && hit.FireAfterArmor>0,"player loses one combined post-defense amount");
        Check(User.ElementalStatus.BurnRemaining>0 && User.ElementalStatus.BurnSource==Attacker,"player receives ordinary burn ownership");
        before=Body.health;hit=Packet(Body);
        Check(before-Body.health==int(hit.AfterToughness+0.5) && hit.FireAfterArmor>0,"NPC loses combined amount");
        Check(Body.ElementalStatus.BurnRemaining>0,"NPC receives ordinary burn");
        double ordinary=hit.BeforeToughness;
        hit=Packet(Body,500,700,true);
        Check(hit.BeforeToughness>ordinary,"shared physical critical increases both components");
        CaelumSleepRules.Apply(Body,350,true);before=Body.health;hit=Packet(Body);
        Console.Printf("CA284 SLEEP loss=%d expected=%d hits=%d hp=%d",before-Body.health,int(int(hit.AfterToughness+0.5)*3+0.5),Body.SpellSleep!=null?Body.SpellSleep.HitsRemaining:-1,Body.health);
        Check(Body.SpellSleep!=null && Body.SpellSleep.HitsRemaining==2
            && before-Body.health==int(int(hit.AfterToughness+0.5)*3+0.5),"compound impact counts once for Sleep with final multiplier");
        Body.SpellSleep.HitsRemaining=1;before=Body.health;hit=Packet(Body);
        Check(Body.SpellSleep==null && before-Body.health==int(int(hit.AfterToughness+0.5)*3+0.5),"third Sleep impact multiplies both components then wakes");
        Body.EffectiveCombatEvasionChance=100;before=Body.health;hit=Packet(Body,500,700,false,true);
        Check(Body.health==before && Body.LastCombatEvasionSucceeded && hit.BeforeToughness==0,"one successful evasion rejects both components");
        Body.EffectiveCombatEvasionChance=0;
        hit=new("CaelumMixedMeleeDamage");double reduction=CaelumToughnessRules.ActorReduction(Body,CaelumToughnessRules.Effective(Body));
        double result=hit.Resolve(Body,400,600);
        Check(Abs(result-Max(0,1000-reduction*0.7))<0.0001,"Toughness is weighted once after component defenses");
        Check(Attacker.PendingMixedMelee==null,"synchronous compound context cleared");
        // Comparar las defensas de cada tipo antes de descontar Dureza.
        User.ArmorModel.InitializeUniformLoadout(CaelumConstants.ARMOR_TYPE_MAGIC,1);
        User.ShieldModel.Equipped=false;User.WeaponModel.Equipped=false;User.CombatBlockModeActive=false;
        hit=Packet(User);int slot=User.LastIncomingArmorSlot;
        double anatomy=User.LastArmorVulnerabilityMultiplier;
        double physical=500*anatomy*(1-User.GetArmorDefensePercent(slot,false,Attacker,Attacker)/100.0);
        double fire=700*anatomy*(1-User.GetArmorDefensePercent(slot,true,Attacker,Attacker)/100.0);
        Check(Abs(hit.BeforeToughness-physical-fire)<0.001,"distinct physical and magical armor absorption");
        let seal=CaelumEquipmentItem(Actor.Spawn("CaelumEquipmentItem",User.Pos,NO_REPLACE));
        seal.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_SEAL;seal.ItemType=CaelumConstants.SEAL_FIRE;
        seal.Tier=1;seal.Equipped=true;seal.AttachToOwner(User);
        hit=Packet(User);
        Check(Abs(hit.BeforeToughness-physical-fire*0.5)<0.001,"Fire seal reduces only magical component before weighted Toughness");
        seal.Destroy();
        User.ShieldModel.ShieldType=CaelumConstants.SHIELD_TYPE_KITE;User.ShieldModel.Tier=1;
        User.ShieldModel.Durability=150;User.ShieldModel.Equipped=true;
        let shield=CaelumEquipmentItem(Actor.Spawn("CaelumShieldPickup",User.Pos,NO_REPLACE));
        shield.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_SHIELD;shield.ItemType=CaelumConstants.SHIELD_TYPE_KITE;
        shield.Tier=1;shield.EquipmentSize=User.ShieldModel.Size;shield.Equipped=true;
        shield.PickupDataInitialized=true;shield.AcquisitionResolved=true;shield.AttachToOwner(User);
        User.EnsureEquipmentItemId(shield);User.EquippedShieldItemId=shield.ItemId;
        User.CombatBlockModeActive=User.DebugShieldBlocking=true;
        hit=Packet(User);
        Check(User.LastShieldBlockedAttack && hit.FireAfterShield<700 && User.LastShieldAbsorbedDamage>0,
            "one block absorbs physical and fire with their own defenses");
        User.CancelCombatBlockMode();User.ShieldModel.Equipped=false;shield.Destroy();
        User.bInvulnerable=true;before=User.health;hit=Packet(User);
        Check(User.health==before && hit.BeforeToughness==0,"invulnerability rejects combined hit before defense wear");
        User.bInvulnerable=false;
        Body.CombatToughness=10000;CaelumSleepRules.Apply(Body,350,true);before=Body.health;
        Body.ElementalStatus=new("CaelumElementalStatus");hit=Packet(Body);
        Check(Body.health==before && Body.SpellSleep.HitsRemaining==3 && Body.ElementalStatus.BurnRemaining==0,
            "fully absorbed impact neither wakes nor burns");
        Body.CombatToughness=6;CaelumSleepRules.Wake(Body);
        User.CharacterProfile.FirstClass=CaelumConstants.CLASS_WARRIOR;
        User.CharacterProfile.SecondClass=CaelumConstants.CLASS_PRIEST;
        User.DerivedStats.BuffPowerPercent=100;User.DerivedStats.AbilityRangePercent=100;
        User.DerivedStats.MaximumAdrenaline=1000;User.CurrentAdrenaline=500;
        CaelumRally.Release(User);before=User.health;hit=Packet(User);
        Check(before-User.health==int(int(hit.AfterToughness+0.5)/1.5+0.5),
            "Rally uses one pre-impact bar for both components");
        CaelumRally.Status(User).Destroy();
        // Identidad cosm?tica sin reescribir la f?sica del proyectil.
        z=CaelumZupayColossus(Actor.Spawn("CaelumZupayColossus",(400,0,0),NO_REPLACE));
        let rock=CaelumActorExplosiveElementalProjectile(Actor.Spawn("CaelumActorExplosiveElementalProjectile",(0,0,100),NO_REPLACE));
        rock.Target=z;rock.StoreCaelumElementalPayload(CaelumConstants.ESSENCE_EARTH,true,100,100);
        rock.Vel=(7,2,1);double radius=rock.Radius,height=rock.Height;int age=rock.CaelumLifetimeTicks;
        CaelumElementalVFX.Projectile(rock);
        Check(rock.CaelumZupayRockVisual && rock.sprite==Actor.GetSpriteIndex("ZROK")
            && rock.Radius==radius && rock.Height==height && rock.Vel==(7,2,1)
            && rock.CaelumLifetimeTicks==age,"rock migration changes only presentation");
        rock.Target=null;CaelumElementalVFX.Projectile(rock);
        Check(rock.CaelumZupayRockVisual && rock.sprite==Actor.GetSpriteIndex("ZROK"),"rock identity survives owner disappearance");
        rock.Destroy();z.Destroy();
        let ordinaryShot=CaelumActorExplosiveElementalProjectile(Actor.Spawn("CaelumActorExplosiveElementalProjectile",(0,0,100),NO_REPLACE));
        ordinaryShot.Target=Attacker;ordinaryShot.StoreCaelumElementalPayload(CaelumConstants.ESSENCE_EARTH,true,100,100);
        CaelumElementalVFX.Projectile(ordinaryShot);
        Check(!ordinaryShot.CaelumZupayRockVisual && ordinaryShot.sprite!=Actor.GetSpriteIndex("ZROK"),"other casters retain elemental presentation");
        ordinaryShot.Destroy();
        let dummy=Actor.Spawn("CaelumTrainingDummy",(0,400,0),NO_REPLACE);before=dummy.health;
        hit=Packet(dummy);
        Check(before-dummy.health==1200,"generic native prop receives both components in one damage call");dummy.Destroy();
    }
    void NativeMelee()
    {
        if(Attacker==null || Attacker.health<=0)return;
        if(Flight!=null){Flight.Destroy();Flight=null;}
        User.CancelCombatBlockMode();User.health=User.player.health=100000;User.CaelumMaximumHealth=100000;
        User.EffectiveEvasionChance=0;User.ElementalStatus=new("CaelumElementalStatus");
        User.SetOrigin((0,0,0),false);Attacker.SetOrigin((36,0,0),false);Attacker.Target=User;Attacker.Angle=180;
        Attacker.CombatDexterity=Manual ? 6 : 100;Attacker.CurrentCombatLucidity=100;Attacker.UpdateActorLucidityState();
        Attacker.health=Attacker.CombatMaximumHealth;Attacker.UpdateCombatHealthEffects();
        Attacker.CombatLucidityPhysicalStunRemaining=0;Attacker.CurrentCombatAir=Attacker.MaximumCombatAir;
        double anima=Attacker.CurrentCombatAnima,air=Attacker.CurrentCombatAir;int before=User.health;
        Attacker.A_CaelumProfiledMeleeAttack(CaelumConstants.MANDINGA_MACHETE_BASE_DAMAGE);
        Check(User.health<before && User.ElementalStatus.BurnRemaining>0,"authored native machete action delivers physical plus Fire and burn");
        Check(Attacker.CurrentCombatAnima==anima && Attacker.CurrentCombatAir<air
            && Attacker.PendingMixedMelee==null && !Attacker.LastCombatAttackMagical,
            "one physical action retains resource classification and clears compound context");
        Console.Printf("CA284 MELEE total_hp=%d burn_per_second=%d",before-User.health,User.ElementalStatus.BurnDamagePerSecond);
        let cry=CaelumBattleCryEffect(Attacker.GiveInventoryType("CaelumBattleCryEffect"));cry.RemainingTics=35;
        before=User.health;air=Attacker.CurrentCombatAir;
        Attacker.A_CaelumProfiledMeleeAttack(CaelumConstants.MANDINGA_MACHETE_BASE_DAMAGE);
        Check(User.health==before && Attacker.CurrentCombatAir==air,"Battle Cry blocks the complete compound attack");cry.Destroy();
        if(Manual)CaelumNotifications.Notify(User,"Machetazo: impacto fisico + fuego y quemadura. F7: roca; F8: verla de cerca.");
    }
    void PrepareThrow()
    {
        if(Flight!=null){Flight.Destroy();Flight=null;}
        if(Zupay!=null)Zupay.Destroy();
        Zupay=CaelumZupayColossus(Actor.Spawn("CaelumZupayColossus",(800,0,0),NO_REPLACE));
        Zupay.CaelumDiagnosticPassiveAI=true;
        if(Attacker!=null)Attacker.SetOrigin((64,256,0),false);
        if(Body!=null)Body.SetOrigin((128,-256,0),false);
        User.SetOrigin((0,0,0),false);User.Angle=0;User.Pitch=0;User.Vel=(0,0,0);
    }
    void Throw()
    {
        Zupay.Target=User;Zupay.Angle=180;Zupay.CombatInsight=Manual ? CaelumConstants.ZUPAY_ATTRIBUTE_LEVEL : 100;
        Zupay.CurrentCombatLucidity=100;Zupay.UpdateActorLucidityState();Zupay.CombatLucidityPhysicalStunRemaining=0;
        Zupay.CurrentCombatAnima=Zupay.MaximumCombatAnima;
        Zupay.A_CaelumSpawnTierOneMagicProjectile("CaelumActorExplosiveElementalProjectile",0.65,
            CaelumConstants.WEAPON_TYPE_STATUETTE,CaelumConstants.ESSENCE_EARTH,true);
        let it=ThinkerIterator.Create("CaelumActorExplosiveElementalProjectile");CaelumActorExplosiveElementalProjectile shot;
        while((shot=CaelumActorExplosiveElementalProjectile(it.Next()))!=null)if(shot.Target==Zupay){Flight=shot;break;}
        Check(Flight!=null,"native Zupay throw creates original projectile class");
        if(Flight!=null){FlightStart=Flight.Pos;FlightVelocity=Flight.Vel;}
    }
    void FlightCheck()
    {
        Check(Flight!=null && Flight.CaelumZupayRockVisual && Flight.sprite==Actor.GetSpriteIndex("ZROK")
            && Flight.Pos!=FlightStart && (Flight.Vel-FlightVelocity).Length()<0.001,
            "rock model follows actual unchanged native projectile flight");
        if(Flight!=null)Check(Flight.Radius==4 && Flight.Height==4 && Flight.Speed==20
            && Flight.CaelumEssenceType==CaelumConstants.ESSENCE_EARTH && Flight.CaelumActorExplosionDamage>0,
            "throw retains original collision speed Earth and explosion payload");
    }
    void Preview()
    {
        User.SetOrigin((-256,0,0),false);User.Angle=0;User.Pitch=0;User.Vel=(0,0,0);User.player.camera=User;
        if(Flight!=null)Flight.Destroy();
        Flight=CaelumActorExplosiveElementalProjectile(Actor.Spawn("CaelumActorExplosiveElementalProjectile",(0,0,56),NO_REPLACE));
        Flight.Target=Zupay;Flight.StoreCaelumElementalPayload(CaelumConstants.ESSENCE_EARTH,true,100,100);
        Flight.Vel=(0,0,0);CaelumElementalVFX.Projectile(Flight);
        Zupay.SetOrigin((192,0,0),false);Zupay.Target=null;Zupay.Angle=180;Zupay.SetStateLabel("Lift");
        if(Manual)CaelumNotifications.Notify(User,"Roca 3D de cerca. Puedes rodearla; F8 la repone. F7 lanza otra.");
    }
    override void UiTick(){if(!Manual && Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();}
    override void NetworkProcess(ConsoleEvent event)
    {
        if(event.Name=="c284_setup")Setup();
        else if(event.Name=="c284_contract")Contract();
        else if(event.Name=="c284_melee")NativeMelee();
        else if(event.Name=="c284_throw_setup")PrepareThrow();
        else if(event.Name=="c284_throw")Throw();
        else if(event.Name=="c284_flight")FlightCheck();
        else if(event.Name=="c284_preview")Preview();
        else if(event.Name=="c284_side")
        {
            let camera=Actor.Spawn("CA284ReviewCamera",(0,-192,56),NO_REPLACE);
            camera.Angle=90;camera.Pitch=0;User.player.camera=camera;
            Check(Flight!=null && Flight.CaelumZupayRockVisual,"side review retains native rock presentation");
        }
        else if(event.Name=="c284_manual")
        {Manual=true;CaelumNotifications.Notify(User,"Prueba #284: F6 machetazo, F7 roca lanzada, F8 roca de cerca.");}
        else if(event.Name=="c284_done")Console.Printf("CA284 DONE failures=%d passes=%d",Failed,Passed);
    }
}
