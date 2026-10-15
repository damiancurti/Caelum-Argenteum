// #246: valores artificiales y contadores de la escena; no se empaqueta en src.
class CA246Body : CaelumMandinga
{
    int Hits;
    bool TickStatus;
    override void Tick(){if(TickStatus)ElementalStatus.TickDamageOverTime(self);}
    override void PostBeginPlay(){Super.PostBeginPlay();ResetBody();}
    void ResetBody()
    {
        health=CombatMaximumHealth=100000;CombatToughness=0;CombatConstitution=10;
        EffectiveCombatEvasionChance=0;ClearCombatArmorToBaseClothing();
        ElementalStatus=new("CaelumElementalStatus");bBuddha=true;
    }
    override int DamageMobj(Actor inflictor,Actor source,int damage,Name mod,int flags,double angle)
    {int before=health;int dealt=Super.DamageMobj(inflictor,source,damage,mod,flags,angle);if(health<before)Hits++;return dealt;}
}
class CA246Probe : StaticEventHandler
{
    CaelumPlayer User;
    CaelumArcaneSunOrb Orb;
    CaelumArcaneSunShot Child;
    CA246Body Enemy,Ally,Neutral,Hidden,Far;
    int Passed,Failed,Explosions,Burst,Directed,Remaining,Clock,Hits;
    double BeforePaid;
    bool Stable,Follow,Manual;
    vector3 Previous,FirstPosition;
    void Check(bool ok,String label)
    {if(ok)Passed++;else Failed++;Console.Printf("CA246 %s %s",ok?"PASS":"FAIL",label);}
    void Stats()
    {
        User.DerivedStats.MaximumAnima=10000;User.DerivedStats.AnimaRegenerationPerSecond=0;
        User.DerivedStats.HealthRegenerationPerSecond=0;User.DerivedStats.AnimaCostReductionPercent=0;
        User.DerivedStats.DebuffPowerPercent=100;User.DerivedStats.BuffPowerPercent=100;
        User.DerivedStats.AbilityRangePercent=100;User.DerivedStats.DebugStaffDamage=100;
        User.DerivedStats.MagicalCriticalChance=0;User.DerivedStats.MagicalPushMultiplier=1;
        User.EffectiveOffensiveDamageMultiplier=1;User.CrouchCriticalChanceMultiplier=0;
    }
    void Clear()
    {
        let it=ThinkerIterator.Create("CaelumArcaneSunShot");Actor shot;
        while((shot=Actor(it.Next()))!=null)shot.Destroy();Orb=null;
        Explosions=Burst=Directed=0;Follow=false;
    }
    CA246Body Body(vector3 pos,bool friendly)
    {let body=CA246Body(Actor.Spawn("CA246Body",pos,NO_REPLACE));body.bFriendly=friendly;body.ResetBody();return body;}
    void Reset()
    {
        Clear();CaelumClassAbilityRules.Cancel(User);CaelumSleepRules.Wake(User);CaelumRacialAbilityRules.Deactivate(User);
        User.ClassSleepCooldownRemaining=0;User.ClassSleepInputLatched=false;
        User.CharacterCreationComplete=true;User.CreationWizardOpen=false;
        User.CharacterProfile.FirstClass=User.CharacterProfile.SecondClass=CaelumConstants.CLASS_MAGE;
        User.CharacterProfile.Race=CaelumConstants.RACE_HUMAN;User.ApplyCharacterProfile();
        User.LucidityPhysicalStunRemaining=User.PainImmobilizationRemaining=0;User.ForcedSleepTics=0;
        User.CurrentSleep=100;User.CurrentLucidity=100;User.bInvulnerable=true;User.bBuddha=true;
        User.CombatChannelModeActive=false;User.EquipmentMenuOpen=false;User.CraftingMenuOpen=false;
        User.player.ConversationNPC=null;User.player.ConversationPC=null;
        User.SetOrigin((0,1000,0),false);User.Angle=0;User.Pitch=0;User.Vel=(0,0,0);
        Stats();User.CurrentAnima=5000;User.CurrentAir=User.DerivedStats.MaximumAir;
        if(Enemy!=null)Enemy.Destroy();if(Ally!=null)Ally.Destroy();if(Neutral!=null)Neutral.Destroy();
        if(Hidden!=null)Hidden.Destroy();if(Far!=null)Far.Destroy();
        Enemy=Body((256,1000,0),false);Enemy.ChangeTid(2460);
        Ally=Body((256,800,0),true);Neutral=Body((-256,1000,0),false);Neutral.bIsMonster=false;
        Hidden=Body((768,0,0),false);Far=Body((3000,3000,0),false);Stable=true;
    }
    void FindOrb()
    {let it=ThinkerIterator.Create("CaelumArcaneSunOrb");Orb=CaelumArcaneSunOrb(it.Next());}
    void Launch(vector3 pos,vector3 velocity)
    {
        Clear();CaelumArcaneSun.Release(User);FindOrb();Orb.SetOrigin(pos,false);Orb.Vel=velocity;
        Orb.CaelumCriticalBaseChance=0;Orb.ChangeTid(2461);FirstPosition=pos;Previous=pos;
    }
    override void UiTick(){if(!Manual && Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();}
    override void WorldTick()
    {
        if(User!=null && Stable)Stats();
        if(Manual && Orb==null)FindOrb();
        if(Orb==null)return;
        Explosions=Orb.Explosions;Burst=Orb.BurstShots;Directed=Orb.DirectedShots;
        if(Follow && !Orb.Finished && Enemy!=null)Enemy.SetOrigin(Orb.Pos+(256,128,-Orb.Pos.Z),false);
    }
    void Contract()
    {
        Check(CaelumClassAbilityRules.CanCast(User) && CaelumClassAbilityRules.Offensive(CaelumConstants.PROFESSION_MAGE),"Mage uses shared offensive class admission");
        Launch((0,1000,64),(20,0,0));
        Check(Orb.Radius==40 && Orb.Height==40 && Orb.Scale.X==10 && Orb.Vel.Length()==20,"orb size and speed match tenfold normal geometry and normal staff speed");
        Check(Orb.NormalDamage==100 && Orb.CaelumPreparedDamage==1000 && Orb.CaelumActorExplosionDamage==1000
            && Orb.BurningDamage==1000,"normal child and tenfold central burn explosion damage snapshot once");
        Check(Orb.RemainingTics==350 && Orb.ShotTics==35 && Orb.AreaRadius==1280
            && Orb.CaelumActorExplosionRadius==1280 && Orb.ChildRange==3200,"base clocks and both authored ranges");
        int allyHP=Ally.health,neutralHP=Neutral.health,userHP=User.health;
        Ally.DamageMobj(Orb,User,1000,'CaelumMagicTest',DMG_EXPLOSION,0);
        Neutral.DamageMobj(Orb,User,1000,'CaelumMagicTest',DMG_EXPLOSION,0);
        User.DamageMobj(Orb,User,1000,'CaelumMagicTest',DMG_EXPLOSION,0);
        Check(Ally.health==allyHP && Neutral.health==neutralHP && User.health==userHP
            && Ally.ElementalStatus.BurnRemaining==0 && Neutral.ElementalStatus.BurnRemaining==0,"allies neutrals and caster reject explosion before health and status effects");
        Orb.SpecialMissileHit(Enemy);int health=Enemy.health;Orb.SpecialMissileHit(Enemy);
        Check(Orb.DirectHits==1 && Enemy.health==health && health<100000 && !Orb.Finished,"one actual direct hit per enemy without exploding");
        Orb.BurnNearby();Check(Enemy.ElementalStatus.BurnDamagePerSecond==1000
            && Enemy.ElementalStatus.BurnPower==10 && Enemy.ElementalStatus.BaseRemaining[0]==3,"aura uses full reference damage and native burn duration");
        Check(Ally.ElementalStatus.BurnRemaining==0 && Neutral.ElementalStatus.BurnRemaining==0,"aura excludes friendly and neutral bodies");
        Orb.SetOrigin((0,0,64),false);Hidden.ElementalStatus=new("CaelumElementalStatus");
        Orb.BurnNearby();Check(Hidden.ElementalStatus.BurnRemaining==0,"real wall blocks burning");
        Orb.SetOrigin((0,1000,64),false);Check(CaelumArcaneSunRules.Nearest(Orb,1280)==Enemy,"nearest visible enemy selected");
        Orb.FireNearest();Check(Orb.DirectedShots==1,"one targeted shot emitted");
        let shots=ThinkerIterator.Create("CaelumArcaneSunShot");CaelumArcaneSunShot shot;int homing=0;
        while((shot=CaelumArcaneSunShot(shots.Next()))!=null)if(!(shot is "CaelumArcaneSunOrb") && shot.Homing)
        {homing++;Check(shot.Tracer==Enemy && shot.CaelumPreparedDamage==100 && shot.Vel.Length()>19.99,"child retains normal damage speed and chosen target");}
        Check(homing==1,"periodic emission is singular");
        Orb.Finish();Orb.Finish();Check(Orb.Explosions==1 && Orb.BurstShots==25,"terminal burst is idempotent and has exactly 25 children");
        shots=ThinkerIterator.Create("CaelumArcaneSunShot");int straight=0,up=0,down=0;vector3 sum=(0,0,0);
        Array<Actor> directions;
        while((shot=CaelumArcaneSunShot(shots.Next()))!=null)if(!(shot is "CaelumArcaneSunOrb") && !shot.Homing)
        {
            straight++;vector3 d=shot.Vel/20.0;sum+=d;if(d.Z>0)up++;if(d.Z<0)down++;
            bool unique=true;for(int i=0;i<directions.Size();i++)if((d-directions[i].Vel/20.0).Length()<0.01)unique=false;
            Check(Abs(d.Length()-1)<1e-6 && unique,"burst direction has normal speed and is distinct");directions.Push(shot);
        }
        Check(straight==25 && up==12 && down==12 && sum.Length()<0.25,"burst covers both hemispheres without polar clustering");
        Clear();User.DerivedStats.DebuffPowerPercent=200;User.DerivedStats.AbilityRangePercent=200;
        CaelumArcaneSun.Release(User);FindOrb();
        Check(Orb.RemainingTics==700 && Orb.AreaRadius==2560 && Orb.BurnDuration==6 && Orb.BurningDamage==2000
            && Orb.CaelumPreparedDamage==1000,"Charisma scales harmful duration and burn; Eloquence range; direct damage unchanged");
        Stats();Clear();
    }
    void ExplosionContract()
    {
        Launch((0,1000,32),(0,0,0));Far.SetOrigin((768,1000,0),false);
        Orb.Finish();Console.Printf("CA246 radial hp near=%d far=%d",Enemy.health,Far.health);
        Check(Enemy.health<Far.health && Far.health<100000,"native explosion falls off with distance");
        Check(Ally.health==100000 && Neutral.health==100000,"actual radial attack leaves allied and neutral health intact");
        Hidden.ResetBody();Launch((0,0,32),(0,0,0));Orb.Finish();
        Check(Hidden.health==100000,"native radial wall protection remains intact");
        Clear();
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        Console.Printf("CA246 event %s player=%d body=%d",e.Name,e.Player,players[e.Player].mo!=null);
        User=CaelumPlayer(players[e.Player].mo);if(User==null)return;
        if(e.Name=="c246_setup")Reset();
        if(e.Name=="c246_contract")Contract();
        if(e.Name=="c246_explosion")ExplosionContract();
        if(e.Name=="c246_contact"){Launch((0,1000,32),(20,0,0));Orb.ShotTics=100000;Ally.SetOrigin((128,1000,0),false);}
        if(e.Name=="c246_passed")
        {Check(Orb!=null && Orb.Pos.X>=500 && Orb.DirectHits==1 && Enemy.Hits==1 && Ally.Hits==0,"native flight crosses ally and enemy with one direct health hit");Orb.Vel=(-20,0,0);}
        if(e.Name=="c246_returned")Check(Orb!=null && Orb.DirectHits==1 && Enemy.Hits==1,"crossing the same enemy again does not repeat direct impact");
        if(e.Name=="c246_guided")
        {Launch((0,1000,64),(0,0,0));Enemy.SetOrigin((500,1500,0),false);Child=Orb.SpawnChild((1,0,0),Enemy);Orb.Destroy();Orb=null;}
        if(e.Name=="c246_turn")
        {Check(Child!=null && Child.Vel.Y>0,"homing turns toward its enemy in native flight");Enemy.health=0;Far.SetOrigin((400,1200,0),false);}
        if(e.Name=="c246_retarget")
        {Check(Child!=null && Child.Tracer==Far,"invalid target reacquires nearest visible enemy");User.health=0;}
        if(e.Name=="c246_dead")
        {Check(Child!=null && Child.bMissile && Child.CaelumTravelledDistance>0,"already launched child continues after caster death");User.health=User.player.health=100;Clear();}
        if(e.Name=="c246_range")
        {Launch((-10000,-10000,1000),(0,0,0));Child=Orb.SpawnChild((1,0,0));Orb.Destroy();Orb=null;}
        if(e.Name=="c246_range_before")Check(Child!=null && Abs(Child.CaelumTravelledDistance-3180)<0.01,"normal staff range counts actual native travel");
        if(e.Name=="c246_range_after")Check(Child==null,"child expires at normal staff range");
        if(e.Name=="c246_burn")
        {Launch((0,1000,64),(0,0,0));Orb.BurnNearby();Enemy.TickStatus=true;Clear();}
        if(e.Name=="c246_burning")Check(Enemy.health<100000 && Enemy.ElementalStatus.BurnRemaining>0,"native periodic health loss continues after leaving the sun");
        if(e.Name=="c246_burn_end")
        {Check(Enemy.ElementalStatus.BurnRemaining==0,"resistant burn eventually expires");Hits=Enemy.health;}
        if(e.Name=="c246_burn_stopped")Check(Enemy.health==Hits,"expired burn does not apply further health loss");
        if(e.Name=="c246_nearwall"){Reset();User.SetOrigin((490,0,0),false);CaelumArcaneSun.Release(User);FindOrb();}
        if(e.Name=="c246_partial")Check(User.ClassCastActive && User.ClassCastPaid>0 && User.ClassCastPaid<1000 && User.ClassSleepCooldownRemaining==0,"native preparation pays progressively without reuse");
        if(e.Name=="c246_cancel"){FindOrb();Check(!User.ClassCastActive && Orb==null && User.CurrentAnima<5000 && User.ClassSleepCooldownRemaining==0,"native second press cancels without refund or release");}
        if(e.Name=="c246_release"){FindOrb();Check(Orb!=null && !Orb.Finished && User.ClassCastPaid==1000 && User.ClassSleepCooldownRemaining>59,"native release creates one paid orb and starts reuse");}
        if(e.Name=="c246_flight"){Launch((0,1000,64),(20,0,0));Follow=true;}
        if(e.Name=="c246_before")Check(Orb.DirectedShots==0 && Abs(Orb.Pos.X-680)<0.01,"straight normal-speed flight with no early targeted shot");
        if(e.Name=="c246_first")Check(Orb.DirectedShots==1,"first targeted shot after one second");
        if(e.Name=="c246_terminal")
        {if(Orb!=null){Explosions=Orb.Explosions;Burst=Orb.BurstShots;Directed=Orb.DirectedShots;}Check(Explosions==1 && Burst==25,"lifetime expiry creates one explosion and 25 outgoing shots");}
        if(e.Name=="c246_children")
        {let it=ThinkerIterator.Create("CaelumArcaneSunShot");Actor shot;int count=0;while((shot=Actor(it.Next()))!=null)if(!(shot is "CaelumArcaneSunOrb"))count++;
            Check(Directed==10 && count>0,"ten timed shots and children survive main orb expiry");}
        if(e.Name=="c246_wall")Launch((0,0,64),(20,0,0));
        if(e.Name=="c246_floor")Launch((0,1000,128),(0,0,-20));
        if(e.Name=="c246_ceiling")Launch((0,1000,3900),(0,0,20));
        if(e.Name=="c246_finished")Check(Explosions==1 && Burst==25,"native scenery impact produces one explosion and 25 shots");
        if(e.Name=="c246_save")
        {Launch((0,1000,64),(20,0,0));Orb.SpecialMissileHit(Enemy);Follow=true;Child=Orb.SpawnChild((1,0,0));Child.SetOrigin((-10000,-10000,1000),false);Child.ChangeTid(2462);Check(Orb!=null,"save includes live orb and child");}
        if(e.Name=="c246_loaded")
        {FindOrb();Enemy=CA246Body(ActorIterator.Create(2460).Next());Stable=true;Follow=true;
            Check(Orb!=null && Orb.Revision==1 && Orb.ShotTics>0 && Orb.ShotTics<35 && Orb.DirectedShots==0,"load preserves mid-period shot clock");
            int hp=Enemy.health;Orb.SpecialMissileHit(Enemy);
            Check(Orb.DirectHits==1 && Enemy.health==hp,"saved per-enemy hit list prevents another direct impact");
            Child=CaelumArcaneSunShot(ActorIterator.Create(2462).Next());
            Check(Child!=null && Child.Revision==1 && Child.CaelumTravelledDistance>0 && Child.CaelumPreparedDamage==100,"child saves its travel and offensive snapshot");
            Remaining=Orb.RemainingTics;Clock=Orb.ShotTics;BeforePaid=User.ClassCastPaid;}
        if(e.Name=="c246_clock")Check(Remaining-Orb.RemainingTics==35 && Clock==Orb.ShotTics && Orb.DirectedShots==1 && User.ClassCastPaid==BeforePaid,"loaded second emits exactly once without repayment");
        if(e.Name=="c246_hub"){FindOrb();Check(Orb!=null && Orb.Revision==1 && !Orb.Finished,"hub round trip retains original map projectile");}
        if(e.Name=="c246_manual"){Reset();Manual=true;Enemy.TickStatus=Hidden.TickStatus=Far.TickStatus=Ally.TickStatus=true;Enemy.SetOrigin((1024,1000,0),false);Ally.SetOrigin((512,800,0),false);}
        if(e.Name=="c246_manual_wall"){Reset();Manual=true;Enemy.TickStatus=Hidden.TickStatus=Far.TickStatus=Ally.TickStatus=true;User.SetOrigin((0,0,0),false);}
        if(e.Name=="c246_done")Console.Printf("CA246 DONE failures=%d passed=%d",Failed,Passed);
    }
    override void RenderOverlay(RenderEvent e)
    {
        if(!Manual)return;let user=CaelumPlayer(players[consoleplayer].mo);if(user==null)return;
        String line=String.Format("SOL ARCANO | F lanzar/cancelar | F6 vuelo libre | F7 pared | Anima %.0f | Reuso %.1fs",user.CurrentAnima,user.ClassSleepCooldownRemaining);
        Screen.DrawText(SmallFont,Font.CR_WHITE,88,8,line,DTA_VIRTUALWIDTHF,640.0,DTA_VIRTUALHEIGHTF,360.0);
        line=String.Format("Explosiones %d | Proyectiles finales %d | Dirigidos %d | Aliado: %d",Explosions,Burst,Directed,Ally==null?0:Ally.health);
        Screen.DrawText(SmallFont,Font.CR_WHITE,88,20,line,DTA_VIRTUALWIDTHF,640.0,DTA_VIRTUALHEIGHTF,360.0);
    }
}
