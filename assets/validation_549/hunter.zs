// #239: cuerpos y recursos controlados; no se empaquetan en producción.
class CA239Body : CaelumCombatActor
{
    override void Tick() { }
    Default { +SOLID +SHOOTABLE +NOGRAVITY Radius 16; Height 96; Mass 100; Health 100000; }
    States { Spawn: TNT1 A -1; Stop; }
}
class CA239Equipment : CA259Session
{
    override int Kind(){return Choice==9?CaelumConstants.WEAPON_TYPE_JAVELIN:Super.Kind();}
}
class CA239ManualBody : CaelumMandinga
{
    int LastLoss,Hits;
    bool LastCritical,LastEligible;
    override void Tick() { }
    override void PostBeginPlay()
    {Super.PostBeginPlay();health=CombatMaximumHealth=100000;bBuddha=true;}
    override int DamageMobj(Actor inflictor,Actor source,int damage,Name mod,int flags,double angle)
    {
        int before=health;int result=Super.DamageMobj(inflictor,source,damage,mod,flags,angle);
        let shot=CaelumActorProjectile(inflictor);
        if(shot!=null){LastLoss=before-health;LastCritical=shot.CaelumCriticalHit;LastEligible=shot.CaelumHunterEligible;Hits++;}
        return result;
    }
}
class CA239Probe : StaticEventHandler
{
    CaelumPlayer User;
    CA239Equipment Equipment;
    Array<CA239Body> Bodies;
    Array<Actor> SeenShots;
    int Passed,Failed,ObservedShots;
    double BeforeAnima,NoiseRange;
    bool Pin,Observe;
    bool Manual;
    CA239ManualBody ManualBody;
    void Check(bool ok,String label)
    {if(ok)Passed++;else Failed++;Console.Printf("CA239 %s %s",ok?"PASS":"FAIL",label);}
    void Stats()
    {
        User.DerivedStats.StealthPercent=20;
        User.DerivedStats.AnimaCostReductionPercent=0;User.DerivedStats.AnimaRegenerationPerSecond=0;
        User.DerivedStats.HealthRegenerationPerSecond=0;
        if(Manual)
        {
            User.DerivedStats.MaximumAnima=10000;
            User.DerivedStats.PhysicalAccuracyPercent=100000;User.DerivedStats.MagicalAccuracyPercent=100000;
        }
    }
    void Reset()
    {
        CaelumRacialAbilityRules.Deactivate(User);CaelumSleepRules.Wake(User);CaelumClassAbilityRules.Cancel(User);
        User.CharacterProfile.Race=CaelumConstants.RACE_BEAST_MAN;
        User.CharacterCreationComplete=true;User.CreationWizardOpen=false;User.ApplyCharacterProfile();
        User.CurrentAnima=1000;User.CurrentAir=1000;User.CurrentSleep=100;User.CurrentLucidity=100;
        User.health=User.CaelumMaximumHealth;User.player.health=User.health;User.player.playerstate=PST_LIVE;
        User.bInvulnerable=true;User.LucidityPhysicalStunRemaining=0;User.PainImmobilizationRemaining=0;
        User.RacialAbilityInputLatched=false;User.EquipmentMenuOpen=false;User.CombatChannelModeActive=false;
        User.player.ConversationNPC=null;User.player.ConversationPC=null;
        User.player.crouchfactor=1;User.SetOrigin((0,0,0),false);User.Angle=0;User.Pitch=0;User.Vel=(0,0,0);
        Pin=true;Stats();
        for(int i=0;i<Bodies.Size();i++)if(Bodies[i]!=null)Bodies[i].Destroy();Bodies.Clear();
        for(int i=0;i<8;i++)
        {
            let body=CA239Body(Actor.Spawn("CA239Body",(256,i*112,0),NO_REPLACE));
            body.Angle=0;body.ChangeTid(2390+i);Bodies.Push(body);
        }
        Equipment=new("CA239Equipment");Equipment.Tier=1;
    }
    void Activate()
    {Check(CaelumRacialAbilityRules.Begin(User),"Beast Man factory admits effect");CaelumRacialAbilityRules.Advance(User);}
    CaelumActorProjectile Shot(bool magic,double chance,double roll,bool revision=true)
    {
        let shot=CaelumActorProjectile(Actor.Spawn(magic?"CaelumPlayerMagicProjectile":"CaelumCarbineProjectile",(220,0,48),NO_REPLACE));
        shot.Target=User;shot.StoreCaelumAttackResult(100,true,roll<chance,magic,0);
        if(revision)shot.StoreCaelumCriticalRoll(chance,roll);
        return shot;
    }
    void Contracts()
    {
        let body=Bodies[0];
        Check(CaelumHuntersInstinct.Chance(User,body,20)==20,"inactive rear retains base chance");
        Activate();Check(Abs(User.CurrentAnima-(1000-10.0/35))<1e-7,"ten Anima per second shared payment");
        Check(CaelumHuntersInstinct.Chance(User,body,20)==60,"rear current chance times three");
        body.Angle=180;Check(CaelumHuntersInstinct.Chance(User,body,20)==20,"front has no bonus");
        body.Angle=90;Check(CaelumHuntersInstinct.Chance(User,body,20)==20,"exact lateral boundary has no bonus");body.Angle=0;
        Check(CaelumHuntersInstinct.Chance(User,body,60)==100,"critical cap applied after stacking");
        User.UpdateCrouchEffects();Check(User.EffectiveStealthPercent==60 && Abs(User.MovementNoiseMultiplier-0.4)<1e-8,"real movement-noise input receives current stealth times three");
        User.player.crouchfactor=0.5;User.UpdateCrouchEffects();
        Check(User.EffectiveStealthPercent==Clamp(60.0*CaelumConstants.CROUCH_STEALTH_MULTIPLIER,0.0,100.0),"existing crouch factor retained before cap");
        User.DerivedStats.StealthPercent=60;User.UpdateCrouchEffects();
        Check(User.EffectiveStealthPercent==100 && User.MovementNoiseMultiplier==0,"stealth cap produces silent movement");
        User.player.crouchfactor=1;Stats();
        for(int magic=0;magic<2;magic++)
        {
            let shot=Shot(magic!=0,10,20);CaelumRacialAbilityRules.Deactivate(User);
            shot.ResolveCaelumCritical(body);Check(shot.CaelumCriticalHit,"paid launch retains potential bonus after switching off");
            body.Angle=180;shot.ResolveCaelumCritical(body);Check(!shot.CaelumCriticalHit,"turning target before impact removes rear bonus");body.Angle=0;
            User.SetOrigin((512,0,0),false);shot.ResolveCaelumCritical(body);Check(!shot.CaelumCriticalHit,"caster position at impact determines rear half");User.SetOrigin((0,0,0),false);
            shot.Destroy();shot=Shot(magic!=0,10,20);Activate();shot.ResolveCaelumCritical(body);
            Check(!shot.CaelumCriticalHit,"activation after firing gives no retroactive bonus");shot.Destroy();
        }
        let old=Shot(false,100,20,false);old.ResolveCaelumCritical(body);
        Check(old.CaelumCriticalHit && old.CaelumCriticalRevision==0,"old in-flight result preserved without reroll");old.Destroy();
        User.DerivedStats.AnimaCostReductionPercent=50;
        Check(Abs(CaelumRacialAbilityRules.TicCost(User,User.RacialAbility)-5.0/35)<1e-8,"normal Anima reduction once");
        CaelumRacialAbilityRules.Deactivate(User);Stats();User.UpdateCrouchEffects();
        Check(User.EffectiveStealthPercent==20 && CaelumHuntersInstinct.Chance(User,body,20)==20,"end restores stealth and chance without changing attributes");
        User.CurrentAnima=0.01;Check(!CaelumRacialAbilityRules.Begin(User) && User.CurrentAnima==0.01,"unaffordable first tic spends nothing");
        User.CurrentAnima=0.3;Activate();double rest=User.CurrentAnima;CaelumRacialAbilityRules.Advance(User);
        Check(!CaelumHuntersInstinct.Active(User) && User.CurrentAnima==rest,"sub-second effect preserves unpaid fraction");
        User.CurrentAnima=1000;Activate();User.PainImmobilizationRemaining=1;CaelumRacialAbilityRules.Guard(User);
        Check(!CaelumHuntersInstinct.Active(User),"immobilization ends racial");User.PainImmobilizationRemaining=0;
    }
    int Hit(CA239Body victim,bool magic,bool boosted,bool certain,int flags=0)
    {
        CaelumRacialAbilityRules.Deactivate(User);if(boosted)Activate();
        let shot=Shot(magic,certain?100:10,20);shot.SetOrigin(victim.Pos+(-8,0,48),false);shot.Angle=0;
        CaelumRacialAbilityRules.Deactivate(User);
        int before=victim.health;
        victim.DamageMobj(shot,User,100,magic?'CaelumMagicTest':'CaelumRangedTest',flags|DMG_THRUSTLESS);
        int lost=before-victim.health;shot.Destroy();return lost;
    }
    void Damage()
    {
        for(int magic=0;magic<2;magic++)
        {
            int boosted=Hit(Bodies[magic*3],magic!=0,true,false);
            int certain=Hit(Bodies[magic*3+1],magic!=0,false,true);
            int ordinary=Hit(Bodies[magic*3+2],magic!=0,false,false);
            Console.Printf("CA239 DAMAGE magic=%d boosted=%d certain=%d ordinary=%d",magic,boosted,certain,ordinary);
            Check(boosted>ordinary && boosted==certain,"native damage matches ordinary critical damage, not times-three damage");
        }
        int areaBoosted=Hit(Bodies[6],true,true,false,DMG_EXPLOSION);
        int areaCertain=Hit(Bodies[7],true,false,true,DMG_EXPLOSION);
        Check(areaBoosted>0 && areaBoosted==areaCertain,"native area defense resolves the same saved roll per receiver");
    }
    void Melee()
    {
        Equipment.Choice=4;Equipment.Equip(User);
        User.DerivedStats.CarryCapacity=100000;User.DerivedStats.PhysicalCriticalChance=15;
        User.DerivedStats.PhysicalAccuracyPercent=100000;User.EffectivePhysicalAccuracyPercent=100000;
        User.DerivedStats.AttackDurationMultiplier=1;User.CurrentAir=100000;
        User.Pitch=20;let body=Bodies[0];body.SetOrigin((64,0,0),false);body.Angle=0;
        double ordinary=User.PhysicalCriticalChanceFor(CaelumConstants.CATALOGUE_WEAPON_SWORD);
        User.PerformDebugSwordAttack(false);
        Check(User.LastMeleeHit && User.LastMeleeCriticalChancePercent==ordinary,"real sword impact uses ordinary chance while inactive");
        Activate();User.PerformDebugSwordAttack(false);
        Check(User.LastMeleeHit && User.LastMeleeCriticalChancePercent==Clamp(ordinary*3,0.0,100.0),"real sword rear impact receives times-three chance");
        body.Angle=180;User.PerformDebugSwordAttack(false);
        Check(User.LastMeleeHit && User.LastMeleeCriticalChancePercent==ordinary,"real sword front impact retains ordinary chance");
        body.Angle=0;body.bISMONSTER=true;User.WeaponModel.WeaponType=CaelumConstants.WEAPON_TYPE_GREATSWORD;
        ordinary=User.PhysicalCriticalChanceFor(CaelumConstants.CATALOGUE_WEAPON_GREATSWORD);
        User.PerformDebugSwordAttack(false,true);
        Check(User.LastMeleeSweepHitCount>0 && User.LastMeleeCriticalChancePercent==Clamp(ordinary*3,0.0,100.0),"real large-weapon sweep resolves rear chance per victim");
    }
    override void WorldTick()
    {
        User=CaelumPlayer(players[0].mo);if(User==null)return;if(Pin)Stats();
        if(!Observe)return;
        let it=ThinkerIterator.Create("CaelumActorProjectile");CaelumActorProjectile shot;
        while((shot=CaelumActorProjectile(it.Next()))!=null)
        {
            if(shot.Target!=User || SeenShots.Find(shot)<SeenShots.Size())continue;
            SeenShots.Push(shot);ObservedShots++;
            if(Manual)
            {
                // Únicamente el ensayo: 20% base, tirada 50%, vuelo lento para alternar F.
                shot.CaelumCriticalBaseChance=20;shot.CaelumCriticalRollPercent=50;shot.CaelumCriticalHit=false;
                shot.Vel*=0.1;
                // El vuelo ralentizado no debe caer antes de alcanzar el blanco de ensayo.
                shot.bNoGravity=true;
                if(shot is "CaelumCarbineProjectile" && shot.tics>0)shot.tics*=10;
                Console.Printf("CA239 MANUAL shot=%s pos=(%.2f,%.2f,%.2f) vel=(%.2f,%.2f,%.2f) eligible=%d",
                    shot.GetClassName(),shot.Pos.X,shot.Pos.Y,shot.Pos.Z,shot.Vel.X,shot.Vel.Y,shot.Vel.Z,shot.CaelumHunterEligible);
            }
            else Check(shot.CaelumCriticalRevision==1 && shot.CaelumHunterEligible,"real weapon stores its original roll and active-launch eligibility");
        }
        if(Manual)User.SetRangedMagazineCount(Equipment.Kind(),User.GetRangedMagazineCapacity(Equipment.Kind()));
    }
    override void RenderOverlay(RenderEvent e)
    {
        let user=CaelumPlayer(players[consoleplayer].mo);if(!Manual || user==null)return;
        String line=String.Format("Instinto %s | Anima %.1f | Sigilo %.0f%%",CaelumHuntersInstinct.Active(user)?"ON":"OFF",user.CurrentAnima,user.EffectiveStealthPercent);
        Screen.DrawText(SmallFont,Font.CR_WHITE,88,8,line,DTA_VIRTUALWIDTHF,640.0,DTA_VIRTUALHEIGHTF,360.0);
        Screen.DrawText(SmallFont,Font.CR_WHITE,88,20,"F activar/apagar | F6 girar blanco | F7 arma | F8 agotar | F9 reiniciar",DTA_VIRTUALWIDTHF,640.0,DTA_VIRTUALHEIGHTF,360.0);
        Screen.DrawText(SmallFont,Font.CR_WHITE,88,32,"Ensayo: probabilidad base 20%, tirada fija 50%, vuelo lento",DTA_VIRTUALWIDTHF,640.0,DTA_VIRTUALHEIGHTF,360.0);
        if(ManualBody!=null)
        {
            line=String.Format("Detras: %s | Impactos %d | Critico: %s | Activa al disparar: %s",
                CaelumHuntersInstinct.Behind(user,ManualBody)?"SI":"NO",ManualBody.Hits,ManualBody.LastCritical?"SI":"NO",ManualBody.LastEligible?"SI":"NO");
            Screen.DrawText(SmallFont,Font.CR_WHITE,88,44,line,DTA_VIRTUALWIDTHF,640.0,DTA_VIRTUALHEIGHTF,360.0);
        }
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        User=CaelumPlayer(players[e.Player].mo);if(User==null)return;
        if(e.Name=="c239_setup")Reset();
        if(e.Name=="c239_manual")
        {
            Manual=true;Reset();User.CurrentAnima=10000;
            for(int i=0;i<Bodies.Size();i++)Bodies[i].Destroy();Bodies.Clear();
            if(ManualBody!=null)ManualBody.Destroy();
            ManualBody=CA239ManualBody(Actor.Spawn("CA239ManualBody",(512,0,0),NO_REPLACE));ManualBody.Angle=0;
            Equipment.Choice=0;Equipment.Equip(User);Stats();User.CurrentAnima=10000;Observe=true;SeenShots.Clear();
            Console.Printf("CA239 DONE failures=0 MANUAL_SEED_ONLY");
        }
        if(e.Name=="c239_turn" && ManualBody!=null)ManualBody.Angle+=180;
        if(e.Name=="c239_weapon" && Manual)
        {
            double reserve=User.CurrentAnima;Equipment.Choice=Equipment.Choice==0?5:0;
            Equipment.Equip(User);Stats();User.CurrentAnima=reserve;
        }
        if(e.Name=="c239_low")User.CurrentAnima=0.01;
        if(e.Name=="c239_manual_check")
        {
            Console.Printf("CA239 MANUAL observed=%d fired=%d air=%d ammo=%d accuracy=%.2f target=(%.2f,%.2f,%.2f) height=%.2f radius=%.2f",
                ObservedShots,User.LastCarbineFired,User.LastCarbineHadEnoughAir,User.LastCarbineHadAmmo,User.LastCarbineAccuracyPercent,
                ManualBody.Pos.X,ManualBody.Pos.Y,ManualBody.Pos.Z,ManualBody.Height,ManualBody.Radius);
            Check(ManualBody!=null && ManualBody.Hits>0 && ManualBody.LastCritical,"manual slow projectile reaches real target with controlled rear critical");
        }
        if(e.Name=="c239_contract")Contracts();
        if(e.Name=="c239_damage")Damage();
        if(e.Name=="c239_melee")Melee();
        if(e.Name=="c239_on")Check(CaelumHuntersInstinct.Active(User),"native User1 or hub retains active effect");
        if(e.Name=="c239_off")Check(!CaelumHuntersInstinct.Active(User),"native second press ends effect");
        if(e.Name=="c239_noise")
        {
            if(!e.Args[0]){NoiseRange=User.LastMovementNoiseEventRange;Check(NoiseRange>0,"native movement emits a real SoundAlert range");}
            else Check(User.LastMovementNoiseEventRange>0 && User.LastMovementNoiseEventRange<NoiseRange,"native movement noise range decreases with racial");
        }
        if(e.Name=="c239_equipment")
        {
            Observe=false;Equipment.Choice=e.Args[0];Equipment.Equip(User);
            User.CurrentAir=100000;User.CurrentAnima=100000;
            User.SetRangedMagazineCount(Equipment.Kind(),User.GetRangedMagazineCapacity(Equipment.Kind()));
            SeenShots.Clear();ObservedShots=0;Observe=true;
        }
        if(e.Name=="c239_shots"){Check(ObservedShots==e.Args[0],"native weapon emits expected projectile count");Observe=false;}
        if(e.Name=="c239_loaded")
        {Pin=true;Stats();Check(CaelumHuntersInstinct.Active(User) && User.CurrentAnima<1000 && User.CurrentAnima>800,"saved active effect preserves payment");BeforeAnima=User.CurrentAnima;}
        if(e.Name=="c239_payment")Check(Abs(BeforeAnima-User.CurrentAnima-10)<0.3,"reload charges once per tic");
        if(e.Name=="c239_save_shot")
        {
            let shot=Shot(true,10,20);shot.ChangeTid(2399);shot.tics=-1;shot.bMissile=false;shot.Vel=(0,0,0);
            Check(shot.CaelumHunterEligible,"save captures launch eligibility");
        }
        if(e.Name=="c239_load_shot")
        {
            let shot=CaelumActorProjectile(ActorIterator.Create(2399).Next());
            let victim=ActorIterator.Create(2390).Next();CaelumRacialAbilityRules.Deactivate(User);
            Check(shot!=null && shot.CaelumCriticalRevision==1 && shot.CaelumHunterEligible
                && shot.CaelumCriticalBaseChance==10 && shot.CaelumCriticalRollPercent==20,"saved projectile retains original chance roll and eligibility");
            if(shot!=null){shot.ResolveCaelumCritical(victim);Check(shot.CaelumCriticalHit,"reloaded projectile keeps its paid rear bonus with racial off");}
        }
        if(e.Name=="c239_return")
        {
            let shot=CaelumActorProjectile(ActorIterator.Create(2399).Next());
            Check(User.RacialAbility==null && !User.RacialAbilityActive,"rollback return stays inactive");
            Check(shot!=null && shot.CaelumCriticalRevision==0 && !shot.CaelumCriticalHit,"rollback flight retains its legacy outcome without invented metadata");
        }
        if(e.Name=="c239_done")Console.Printf("CA239 DONE failures=%d passed=%d",Failed,Passed);
    }
}
