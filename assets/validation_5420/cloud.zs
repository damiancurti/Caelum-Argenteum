// Datos controlados de laboratorio: no modifican el balance del juego.
class CA251Target : CaelumMandinga
{
    bool Initialized;
    int Hits,Raw;
    override void PostBeginPlay(){if(Initialized)return;Super.PostBeginPlay();Initialized=true;}
    override void Tick(){if(ElementalStatus!=null)ElementalStatus.Tick(self);}
    override int DamageMobj(Actor inflictor,Actor source,int damage,Name mod,int flags,double angle)
    {Hits++;Raw=damage;return Super.DamageMobj(inflictor,source,damage,mod,flags,angle);}
}
class CA251Neutral : CA251Target { Default {-ISMONSTER +FRIENDLY} }
class CA251Camera : Actor
{
    override void Tick()
    {
        if(Master==null){Destroy();return;}
        SetOrigin(Master.Pos+(-192,128,48),false);
        vector3 delta=Master.Pos+(0,0,24)-Pos;
        Angle=VectorAngle(delta.X,delta.Y);Pitch=-VectorAngle(delta.XY.Length(),delta.Z);
    }
    Default {+NOGRAVITY +NOINTERACTION}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA251Checkpoint : Inventory
{
    int Remaining,Rain,Phase;
    double Anima;
    Default {Inventory.MaxAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA251Probe : StaticEventHandler
{
    CaelumPlayer User;
    CA251Target Enemy,Ally,Neutral,Hidden;
    int Passed,Failed;
    double Buff,Range,Magic,Debuff,Forward,Vertical;
    bool Pin,Manual;
    void Check(bool ok,String label)
    {if(ok)Passed++;else Failed++;Console.Printf("CA251 %s %s",ok?"PASS":"FAIL",label);}
    void Stats()
    {
        User.DerivedStats.MaximumAnima=10000;User.DerivedStats.AnimaCostReductionPercent=0;
        User.DerivedStats.BuffPowerPercent=Buff;User.DerivedStats.AbilityRangePercent=Range;
        User.DerivedStats.DebugStaffDamage=Magic;User.DerivedStats.DebuffPowerPercent=Debuff;
        User.DerivedStats.AnimaRegenerationPerSecond=0;User.CombatTimeRemaining=2;
    }
    override void WorldTick(){if(Pin && User!=null)Stats();}
    override void UiTick(){if(!Manual && Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();}
    void Clear()
    {
        let effect=CaelumArcaneCloud.Status(User);if(effect!=null)effect.Destroy();
        let it=ThinkerIterator.Create("CA251Target");Actor body;
        while((body=Actor(it.Next()))!=null)body.Destroy();
        Enemy=Ally=Neutral=Hidden=null;
    }
    void Setup()
    {
        User=CaelumPlayer(players[consoleplayer].mo);Clear();
        User.CharacterCreationComplete=true;User.CreationWizardOpen=false;
        User.CharacterProfile.FirstClass=CaelumConstants.CLASS_EXPLORER;
        User.CharacterProfile.SecondClass=CaelumConstants.CLASS_MAGE;
        User.ApplyCharacterProfile();User.SetOrigin((0,0,256),false);User.Vel=(0,0,0);User.Angle=0;User.Pitch=0;
        User.CurrentSleep=User.CurrentLucidity=100;User.bInvulnerable=true;
        User.CurrentAnima=5000;User.ClassSleepCooldownRemaining=0;
        CaelumClassAbilityRules.Cancel(User);User.ClassPreparationTics=0;User.ClassSleepInputLatched=false;
        Buff=Range=Debuff=100;Magic=CaelumConstants.DEBUG_STAFF_BASE_DAMAGE;Pin=true;Stats();
    }
    CA251Target Body(class<CA251Target> type,vector3 pos,bool friendly=false)
    {
        let body=CA251Target(Actor.Spawn(type,pos,NO_REPLACE));body.PostBeginPlay();
        body.bFriendly=friendly;body.health=body.CombatMaximumHealth=10000000;
        body.MaximumCombatAnima=1000;body.CurrentCombatAnima=17;return body;
    }
    void Released()
    {
        Check(CaelumClassAbilityRules.CanCast(User),"Investigator enters shared lifecycle");
        Check(CaelumArcaneCloud.Release(User),"cloud release succeeds");
        let effect=CaelumArcaneCloud.Status(User);
        Check(effect!=null && effect.RemainingTics==350 && effect.RainTics==35 && effect.LightningPhase==0,
            "base duration and independent initial pulse clocks");
        Check(effect.Width==82 && effect.Range==1280 && effect.Power==1,"cart width range and base power");
        Check(effect.LightningDamage==CaelumConstants.SEAL_LIGHTNING_BASE_TOTAL_DAMAGE
            && effect.LightningRadius==CaelumConstants.ESSENCE_EXPLOSION_BASE_RADIUS*2
            && abs(effect.StunDuration-0.3)<0.0001,"Air seal payload and separate staff stun");
        Check(effect.Model!=null && effect.Model.Mass==0 && !effect.Model.bSolid && effect.Model.bNoInteraction,
            "model has no mass or interactive collision body");
        Check(User.bFly && User.bNoGravity && CaelumArcaneCloud.SpeedFactor(User)==2,"native flight and base speed factor");
    }
    void Timing()
    {
        Enemy=Body("CA251Target",(160,0,0));Ally=Body("CA251Target",(0,0,0),true);
        Neutral=Body("CA251Neutral",(160,30,0),true);Hidden=Body("CA251Target",(768,0,0));
        Released();
    }
    void Rain()
    {
        Released();let effect=CaelumArcaneCloud.Status(User);
        Ally=Body("CA251Target",(0,0,0),true);
        Check(CaelumArcaneCloud.RainEligible(effect,Ally),"ally directly below receives rain");
        Enemy=Body("CA251Target",(8,0,0));Neutral=Body("CA251Neutral",(-8,0,0),true);
        Check(!CaelumArcaneCloud.RainEligible(effect,Enemy) && !CaelumArcaneCloud.RainEligible(effect,Neutral),
            "rain excludes enemies and neutrals");
        Enemy.Destroy();Neutral.Destroy();
        CaelumArcaneCloud.Rain(effect);
        Check(Ally.CurrentCombatAnima==27 && User.CurrentAnima==5100,"one percent of current maxima including caster");
        Ally.MaximumCombatAnima=2000;CaelumArcaneCloud.Rain(effect);
        Check(Ally.CurrentCombatAnima==47,"changed recipient maximum is used on next pulse");
        Ally.SetOrigin((0,0,400),false);Check(!CaelumArcaneCloud.RainEligible(effect,Ally),"ally above cloud excluded");
        Ally.SetOrigin((100,0,0),false);Check(!CaelumArcaneCloud.RainEligible(effect,Ally),"ally outside rain footprint excluded");
        Ally.SetOrigin((0,0,0),false);let cover=Body("CA251Target",(0,0,128),true);
        Check(!CaelumArcaneCloud.RainEligible(effect,Ally),"interposed body stops rain before lower ally");
        cover.Destroy();
        Buff=200;Range=200;Debuff=200;Magic*=3;Stats();
        effect.RemainingTics=1000;effect.RainTics=7;effect.LightningPhase=19;
        CaelumArcaneCloud.Release(User);
        Check(effect.RemainingTics==1000 && effect.RainTics==7 && effect.LightningPhase==19,"renewal preserves longer time and pulse phase");
        Check(effect.Power==2 && effect.Width==164 && effect.Range==2560
            && CaelumArcaneCloud.SpeedFactor(User)==4 && effect.LightningDamage==30000
            && abs(effect.StunDuration-.6)<.0001,"Eloquence Empathy Intelligence and Charisma scale distinct results");
        effect.RemainingTics=10;CaelumArcaneCloud.Release(User);
        Check(effect.RemainingTics==700,"renewal can extend remaining duration without stacking");
    }
    void Roof()
    {
        Released();Ally=Body("CA251Target",(0,0,0),true);
        Check(!CaelumArcaneCloud.RainEligible(CaelumArcaneCloud.Status(User),Ally),"solid 3D floor stops restorative rain");
        CaelumArcaneCloud.Rain(CaelumArcaneCloud.Status(User));
        Check(Ally.CurrentCombatAnima==17 && User.CurrentAnima==5100,"roof protects lower ally while caster keeps recovery");
    }
    void Cry()
    {
        Enemy=Body("CA251Target",(160,0,0));Released();
        CaelumBattleCry.Apply(User,100);User.ClassSleepCooldownRemaining=0;
        Check(!CaelumClassAbilityRules.CanCast(User),"War Cry prevents starting a new offensive class cast");
        CaelumArcaneCloud.Lightning(CaelumArcaneCloud.Status(User));
        Check(Enemy.Hits==1 && User.bFly && CaelumArcaneCloud.Active(User),"existing cloud generates new lightning while intimidated");
        Check(Enemy.Raw==10000 && Enemy.ElementalStatus.LightningStunRemaining>0,"one enemy receives full Air-seal damage and staff stun");
        Ally=Body("CA251Target",(180,0,0),true);Neutral=Body("CA251Neutral",(160,20,0),true);
        Hidden=Body("CA251Target",(180,30,0));
        CaelumArcaneCloud.Lightning(CaelumArcaneCloud.Status(User));
        Check(Enemy.Raw==5000 && Hidden.Raw==5000,"Air seal total damage divides between enemy recipients");
        Check(Ally.Hits==0 && Neutral.Hits==0 && User.health>0,"lightning protects allies neutrals and caster");
        Enemy.bInvulnerable=true;Enemy.ElementalStatus.LightningStunRemaining=0;
        CaelumArcaneCloud.Lightning(CaelumArcaneCloud.Status(User));
        Check(Enemy.ElementalStatus.LightningStunRemaining==0,"fully absorbed strike does not add stun");
    }
    void Coexist()
    {
        let record=User.GetPersistentCharacterState(true);
        record.TarotActive[CaelumConstants.TAROT_THE_FOOL]=true;record.TarotEffectTics=1000;
        for(int order=0;order<2;order++)
        {
            CaelumArcaneCloud.Release(User);let cloud=CaelumArcaneCloud.Status(User);
            let tarot=PowerFlight(User.GiveInventoryType("CaelumTarotFlight"));
            User.Vel=(1,2,-3);User.player.centering=false;
            if(order==0)tarot.Destroy();else cloud.Destroy();
            Check(User.bFly && User.bNoGravity && User.Vel==(1,2,-3) && !User.player.centering,
                "real cloud and Tarot preserve survivor without thrust or view change");
            if(order==0)cloud.Destroy();else tarot.Destroy();
            Check(!User.bFly && !User.bNoGravity,"last real flight source restores gravity");
        }
        record.TarotActive[CaelumConstants.TAROT_THE_FOOL]=false;record.TarotEffectTics=0;
    }
    void Stops()
    {
        for(int state=0;state<3;state++)
        {
            CaelumArcaneCloud.Release(User);let effect=CaelumArcaneCloud.Status(User);let model=effect.Model;
            if(state==0)User.ForcedSleepTics=10;
            else if(state==1)User.ElementalStatus.LightningStunRemaining=1;
            else if(state==2)User.PainImmobilizationRemaining=1;
            effect.Tick();
            Check(CaelumArcaneCloud.Status(User)==null && model.bDestroyed && !User.bFly && !User.bNoGravity,
                "sleep stun or immobilization removes cloud and flight");
            User.ForcedSleepTics=0;User.ElementalStatus.LightningStunRemaining=0;
            User.PainImmobilizationRemaining=0;
        }
    }
    void Journey()
    {
        Released();let effect=CaelumArcaneCloud.Status(User);
        let plan=CaelumJourneyPlan(User.GiveInventoryType("CaelumJourneyPlan"));
        plan.Available=new("CaelumJourneyModel");plan.Available.Capture(User,false);
        plan.Available.ElapsedTics=100;plan.Apply(User);
        Check(effect.RemainingTics==250 && effect.RainTics==35 && effect.LightningPhase==0,"short journey consumes duration without pulse burst");
        plan.Available.ElapsedTics=1000;plan.Apply(User);
        Check(CaelumArcaneCloud.Status(User)==null && !User.bNoGravity,"long journey expires cloud");
    }
    void Movement()
    {
        User.ApplyPhysicalMovement();Forward=User.ForwardMove1;
        User.bFly=true;User.bNoGravity=true;User.player.cmd.upmove=256;User.CheckMoveUpDown();Vertical=User.Vel.Z;
        User.bFly=false;User.bNoGravity=false;
        Released();User.ApplyPhysicalMovement();
        Check(abs(User.ForwardMove1-Forward*2)<.0001,"horizontal current-mode multiplier doubles");
        User.CheckMoveUpDown();Check(abs(User.Vel.Z-Vertical*2)<.0001,"native upward command doubles");
        User.player.cmd.upmove=-256;User.CheckMoveUpDown();Check(abs(User.Vel.Z+Vertical*2)<.0001,"native downward command doubles");
        User.player.cmd.upmove=0;User.Vel=(0,0,0);
    }
    void Seed()
    {
        Released();let effect=CaelumArcaneCloud.Status(User);effect.RemainingTics=1000;
        let snapshot=CA251Checkpoint(User.GiveInventoryType("CA251Checkpoint"));
        snapshot.Remaining=effect.RemainingTics;snapshot.Anima=User.CurrentAnima;
        snapshot.Rain=effect.RainTics;snapshot.Phase=effect.LightningPhase;
    }
    void Overlap()
    {
        let second=CaelumPlayer(players[1].mo);
        Check(second!=null && second.player!=null,"native second player exists for overlap test");if(second==null)return;
        second.CharacterCreationComplete=true;second.CreationWizardOpen=false;second.ApplyCharacterProfile();
        second.CurrentSleep=second.CurrentLucidity=100;second.bInvulnerable=true;
        second.DerivedStats.BuffPowerPercent=200;second.DerivedStats.AbilityRangePercent=100;
        User.SetOrigin((-28,0,256),false);User.Vel=(0,0,0);
        second.SetOrigin((28,0,256),false);second.Vel=(0,0,0);
        CaelumArcaneCloud.Release(User);CaelumArcaneCloud.Release(second);
        let weak=CaelumArcaneCloud.Status(User);let strong=CaelumArcaneCloud.Status(second);
        Check(weak!=null && strong!=null,"both native players have independent clouds");if(strong==null)return;
        Ally=Body("CA251Target",(0,0,0),true);
        Check(CaelumArcaneCloud.RainEligible(weak,Ally) && CaelumArcaneCloud.RainEligible(strong,Ally),"both footprints cover common ally");
        CaelumArcaneCloud.Rain(weak);CaelumArcaneCloud.Rain(strong);
        Check(Ally.CurrentCombatAnima==37,"overlapping rain applies strongest source only");
        strong.Power=1;Ally.CurrentCombatAnima=17;
        CaelumArcaneCloud.Rain(strong);CaelumArcaneCloud.Rain(weak);
        Check(Ally.CurrentCombatAnima==27,"equal sources use stable player identity without stacking");
        strong.Destroy();second.SetOrigin((1000,1000,0),false);
    }
    void Loaded()
    {
        User=CaelumPlayer(players[consoleplayer].mo);Pin=true;Buff=Range=Debuff=100;Magic=CaelumConstants.DEBUG_STAFF_BASE_DAMAGE;Stats();
        let effect=CaelumArcaneCloud.Status(User);let snapshot=CA251Checkpoint(User.FindInventory("CA251Checkpoint"));
        Check(effect!=null && snapshot!=null && effect.RemainingTics<snapshot.Remaining
            && effect.RemainingTics>0,"save and travel preserve elapsed remaining duration");
        Check(effect!=null && effect.Model!=null && effect.Model.Source==effect && effect.Model.Pos.XY==User.Pos.XY,
            "save and travel preserve owned cloud presentation");
        Check(User.bFly && User.bNoGravity && User.FindInventory("CaelumArcaneCloudFlight")!=null,"save and travel restore native flight");
        Check(effect.Power==1 && effect.Width==82 && effect.LightningDamage==10000,"saved gameplay snapshot remains unchanged");
        int count=0;let it=ThinkerIterator.Create("CaelumArcaneCloudModel");while(it.Next()!=null)count++;
        Check(count==1,"exactly one cloud model on the current map");
    }
    void ManualSetup()
    {
        Setup();Manual=true;User.SetOrigin((0,0,0),false);User.Vel=(0,0,0);
        Enemy=Body("CA251Target",(256,0,0));Enemy.health=Enemy.CombatMaximumHealth=200000;
        Ally=Body("CA251Target",(0,96,0),true);Ally.MaximumCombatAnima=1000;Ally.CurrentCombatAnima=0;
        Neutral=Body("CA251Neutral",(256,96,0),true);
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="c251_setup")Setup();else if(e.Name=="c251_contract")Released();
        else if(e.Name=="c251_rain")Rain();else if(e.Name=="c251_roof")Roof();
        else if(e.Name=="c251_timing")Timing();else if(e.Name=="c251_early")
            Check(Enemy.Hits==0 && Ally.CurrentCombatAnima==17 && User.CurrentAnima==5000,"no lightning or rain before first scheduled pulse");
        else if(e.Name=="c251_first")Check(Enemy.Hits==1 && Ally.CurrentCombatAnima==17,"first third-second strike precedes rain");
        else if(e.Name=="c251_second")
        {
            Check(Enemy.Hits==3 && Hidden.Hits==0 && Neutral.Hits==0,"three spaced visible-enemy strikes per second");
            Check(Ally.CurrentCombatAnima==27 && User.CurrentAnima==5100,"first rain pulse occurs at one second");
            Check(User.CurState==User.FindState("RestSeated"),"world rider stays seated without rest mode");
            Check(!CaelumRestState.IsActive(User),"cloud does not enter rest mechanics");
        }
        else if(e.Name=="c251_cry")Cry();else if(e.Name=="c251_coexist")Coexist();
        else if(e.Name=="c251_stops")Stops();else if(e.Name=="c251_journey")Journey();
        else if(e.Name=="c251_movement")Movement();else if(e.Name=="c251_seed")Seed();
        else if(e.Name=="c251_loaded")Loaded();else if(e.Name=="c251_manual")ManualSetup();
        else if(e.Name=="c251_overlap")Overlap();
        else if(e.Name=="c251_outside")Level.ChangeLevel("MAP95",0,CHANGELEVEL_NOINTERMISSION);
        else if(e.Name=="c251_view")
        {
            if(User.player.camera!=User)
            {let old=User.player.camera;User.player.camera=User;old.Destroy();return;}
            let camera=Actor.Spawn("CA251Camera",User.Pos+(-192,128,48),NO_REPLACE);
            camera.Master=User;
            vector3 delta=User.Pos+(0,0,24)-camera.Pos;
            camera.Angle=VectorAngle(delta.X,delta.Y);camera.Pitch=-VectorAngle(delta.XY.Length(),delta.Z);
            User.player.camera=camera;
            let effect=CaelumArcaneCloud.Status(User);
            if(effect!=null)Console.Printf("CA251 VISUAL userZ=%.2f scale=%.3f cloudZ=%.2f scale=%.2f",User.Pos.Z,User.Scale.Y,effect.Model.Pos.Z,effect.Model.Scale.Y);
        }
        else if(e.Name=="c251_prep_loaded")
        {
            User=CaelumPlayer(players[consoleplayer].mo);Pin=true;Buff=Range=Debuff=100;Magic=CaelumConstants.DEBUG_STAFF_BASE_DAMAGE;Stats();
            Check(User.ClassCastActive && User.ClassCastPaid>0 && User.ClassCastPaid<1000
                && CaelumArcaneCloud.Status(User)==null,"save preserves partially paid preparation");
        }
        else if(e.Name=="c251_motion_start")
        {User.SetOrigin((400,0,256),false);User.Vel=(0,0,0);CaelumArcaneCloud.Release(User);}
        else if(e.Name=="c251_wall")Check(User.Pos.X>400 && User.Pos.X+User.Radius<=512.1,"cloud movement collides with native wall");
        else if(e.Name=="c251_ceiling_start")
        {User.SetOrigin((0,0,900),false);User.Vel=(0,0,0);CaelumArcaneCloud.Release(User);}
        else if(e.Name=="c251_ceiling")Check(User.Pos.Z>900 && User.Pos.Z+User.Height<=1024.1,"cloud ascent collides with native ceiling");
        else if(e.Name=="c251_ready"){User.CurrentAnima=5000;User.ClassSleepCooldownRemaining=0;}
        else if(e.Name=="c251_intimidate")CaelumBattleCry.Apply(User,350);
        else if(e.Name=="c251_end"){let effect=CaelumArcaneCloud.Status(User);if(effect!=null)effect.Destroy();}
        else if(e.Name=="c251_kill"){User.bInvulnerable=false;User.DamageMobj(null,null,10000000,'None',DMG_FORCED,0);}
        else if(e.Name=="c251_dead")Check(CaelumArcaneCloud.Status(User)==null,"caster death destroys cloud immediately");
        else if(e.Name=="c251_partial")Check(User.ClassCastActive && User.ClassCastPaid>0 && User.ClassCastPaid<1000
            && CaelumArcaneCloud.Status(User)==null,"native User4 prepares and pays progressively");
        else if(e.Name=="c251_cancel")Check(!User.ClassCastActive && User.ClassCastPaid>0 && User.ClassSleepCooldownRemaining==0
            && CaelumArcaneCloud.Status(User)==null,"cancellation retains spent Anima without cooldown");
        else if(e.Name=="c251_cast")Check(!User.ClassCastActive && User.ClassCastPaid==1000 && User.ClassSleepCooldownRemaining>59
            && CaelumArcaneCloud.Status(User)!=null,"native three-second release starts cloud and cooldown");
        else if(e.Name=="c251_expired")Check(CaelumArcaneCloud.Status(User)==null && !User.bFly && !User.bNoGravity,"ordinary expiry removes model and flight");
        else if(e.Name=="c251_done")Console.Printf("CA251 DONE failures=%d passed=%d",Failed,Passed);
    }
    override void RenderOverlay(RenderEvent e)
    {
        let user=CaelumPlayer(players[consoleplayer].mo);if(!Manual || user==null)return;
        let effect=CaelumArcaneCloud.Status(user);
        String line=String.Format("NUBE ARCANA | Efecto %.1fs | F lanzar | F6 reiniciar | F7 recargar",
            effect==null?0:effect.RemainingTics/35.0);
        Screen.DrawText(SmallFont,Font.CR_WHITE,70,8,line,DTA_VIRTUALWIDTHF,640.0,DTA_VIRTUALHEIGHTF,360.0);
        line=String.Format("Rayos %d | Anima aliado %.0f/1000 | F8 Grito de guerra | F9 cambiar mapa",
            effect==null?0:effect.LightningStrikes,Ally==null?0:Ally.CurrentCombatAnima);
        Screen.DrawText(SmallFont,Font.CR_WHITE,70,20,line,DTA_VIRTUALWIDTHF,640.0,DTA_VIRTUALHEIGHTF,360.0);
        Screen.DrawText(SmallFont,Font.CR_WHITE,70,32,"Inicio subir | Fin bajar | F10 tercera persona | F11 terminar | F12 vista lateral",
            DTA_VIRTUALWIDTHF,640.0,DTA_VIRTUALHEIGHTF,360.0);
    }
}
