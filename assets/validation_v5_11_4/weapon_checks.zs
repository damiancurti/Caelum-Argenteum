class CA430WeaponTarget : CaelumCombatActor
{
    Default { Health 100000; Radius 24; Height 56; Mass 80; Monster; +COUNTKILL }
    States { Spawn: TNT1 A -1; Stop; }
    override void PostBeginPlay()
    {
        Super.PostBeginPlay();InitializeCombatProfile(0,0,0,0,0,0,0,0,0,0,0,0);
        CombatMaximumHealth=100000;health=100000;bBuddha=true;
    }
}
class CA430WeaponCompanion : CaelumCompanionSubcaptain
{
    States { TestIdle: DOMI A -1; Stop; See: DOMI A -1; Stop; }
}
class CA430WeaponChecks : EventHandler
{
    CA430WeaponCompanion Body;
    CA430WeaponTarget Victim;
    CaelumCompanionLoadout Loadout;
    CaelumEquipmentItem Item;
    Inventory Ammo;
    int Type,Stage,Start,ShotStart,FinishTic,Failures,Passes;
    double ReloadSeconds,OriginalSpeed,BeforeAnima,MagicCost;
    bool MagicMode,VictimDied;
    bool ToolMode,ToolPaidAir,ToolPaidAnima,ToolAppliedEffect;
    double ToolInitialAir;
    int ToolDiagnostic;
    override void WorldThingDied(WorldEvent e){if(e.Thing==Victim)VictimDied=true;}
    void Check(bool ok,String label)
    {if(ok){Passes++;Console.Printf("CA430 PASS %s",label);}else{Failures++;Console.Printf("CA430 FAIL %s",label);}}
    void Begin(int kind)
    {
        Type=kind;let user=CaelumPlayer(players[0].mo);
        Body=CA430WeaponCompanion(Actor.Spawn("CA430WeaponCompanion",user.Pos+(0,160,0),NO_REPLACE));
        Victim=CA430WeaponTarget(Actor.Spawn("CA430WeaponTarget",user.Pos+(300,0,0),NO_REPLACE));
        Start=level.time;Stage=1;
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=='ca430_magicsnapshot')
        {
            Check(Loadout!=null && Loadout.Magic!=null && Loadout.Magic.Pending==Item
                && Loadout.Magic.Remaining>0 && Loadout.Magic.Releases==0,
                "snapshot captures an unpaid spell during its native preparation");
            Console.Printf("CA430 RESULT pending magic snapshot failures=%d",Failures);
        }
        if(e.Name=='ca430_magicreload')
        {
            let party=CaelumCompanionParty.Get(CaelumPlayer(players[0].mo));let bond=party!=null ? party.Find(8) : null;
            let gear=bond!=null ? bond.Loadout : null;
            Check(gear!=null && gear.Magic!=null && gear.Magic.Releases==1 && gear.Magic.Pending==null
                && gear.SelectedWeapon.Owner==bond.Body,"loading a prepared spell completes it once with the same native weapon");
            Console.Printf("CA430 RESULT magic reload complete failures=%d",Failures);
        }
        if(e.Name=='ca430_player_support')PlayerSupport();
        if(e.Name=='ca430_seek')SeekComparison();
        if(e.Name=='ca430_weaponreload')
        {
            let party=CaelumCompanionParty.Get(CaelumPlayer(players[0].mo));let bond=party!=null ? party.Find(8) : null;
            let gear=bond!=null ? bond.Loadout : null;
            Check(gear!=null && gear.SelectedWeapon!=null && gear.SelectedWeapon.Owner==bond.Body,
                "save restores the same owned selected ranged object");
            Check(gear!=null && gear.Ranged!=null && gear.Ranged.Shots==2 && gear.Ranged.Reloads==1
                && gear.Ranged.Ammunition()==null && gear.Ranged.Magazine[gear.Ranged.Slot(gear.SelectedWeapon.ItemType)]==0,
                "save preserves completed shots and an exhausted finite reserve without reloading it");
            Check(gear!=null && gear.SelectedWeapon.Durability<100,"save preserves wear caused by real projectile impacts");
            Console.Printf("CA430 RESULT ranged reload complete failures=%d",Failures);
        }
        if(e.Name=='ca430_staff'){MagicMode=true;Begin(CaelumConstants.WEAPON_TYPE_STAFF);}
        if(e.Name=='ca430_bell'){MagicMode=true;Begin(CaelumConstants.WEAPON_TYPE_BELL);}
        if(e.Name=='ca430_scepter'){MagicMode=true;Begin(CaelumConstants.WEAPON_TYPE_SCEPTER);}
        if(e.Name=='ca430_orb'){MagicMode=true;Begin(CaelumConstants.WEAPON_TYPE_ORB);}
        if(e.Name=='ca430_book'){MagicMode=true;Begin(CaelumConstants.WEAPON_TYPE_SUPPORT_BOOK);}
        if(e.Name=='ca430_censer'){MagicMode=true;Begin(CaelumConstants.WEAPON_TYPE_CENSER);}
        if(e.Name=='ca430_statuette'){MagicMode=true;Begin(CaelumConstants.WEAPON_TYPE_SUPPORT_STATUETTE);}
        if(e.Name=='ca430_effigy'){MagicMode=true;Begin(CaelumConstants.WEAPON_TYPE_EFFIGY);}
        if(e.Name=='ca430_carbine')Begin(CaelumConstants.WEAPON_TYPE_CARBINE);
        if(e.Name=='ca430_shotgun')Begin(CaelumConstants.WEAPON_TYPE_SHOTGUN);
        if(e.Name=='ca430_bow')Begin(CaelumConstants.WEAPON_TYPE_LONGBOW);
        if(e.Name=='ca430_crossbow')Begin(CaelumConstants.WEAPON_TYPE_CROSSBOW);
        if(e.Name=='ca430_sword'){ToolMode=true;Begin(CaelumConstants.WEAPON_TYPE_SWORD);}
        if(e.Name=='ca430_bolas'){ToolMode=true;Begin(CaelumConstants.WEAPON_TYPE_BOLAS);}
        if(e.Name=='ca430_utility'){ToolMode=true;Begin(CaelumConstants.WEAPON_TYPE_UTILITY_STAFF);}
    }
    void PlayerSupport()
    {
        let user=CaelumPlayer(players[0].mo);
        let opponent=Actor.Spawn("CA430WeaponTarget",user.Pos+(300,0,0),NO_REPLACE);
        for(int role=0;role<CaelumSupportImplementData.ROLE_COUNT;role++)
        {
            bool benefit=CaelumSupportImplementData.Beneficial(role);Actor receiver=benefit ? Actor(user) : opponent;
            Check(CaelumSupportMagic.Eligible(user,user,role)==benefit
                && CaelumSupportMagic.Eligible(user,opponent,role)!=benefit,"player support keeps its authored ally/enemy restrictions");
            Check(CaelumSupportMagic.Apply(user,receiver,role),"player support still applies each shared effect");
            let status=CaelumSupportMagic.Status(receiver);
            Check(status!=null && status.Sources[role]==user && status.Effects[role].Active(),"shared effect retains its actual player caster");
        }
        opponent.Destroy();
        Console.Printf("CA430 RESULT player support regression failures=%d",Failures);
    }
    void SeekComparison()
    {
        let user=CaelumPlayer(players[0].mo);
        Actor.Spawn("CA430WeaponTarget",user.Pos+(300,0,0),NO_REPLACE);
        Actor.Spawn("CA430WeaponTarget",user.Pos+(250,50,0),NO_REPLACE);
        Actor.Spawn("CA430WeaponTarget",user.Pos+(400,-100,0),NO_REPLACE);
        let shot=CaelumHomingMagicProjectile(Actor.Spawn("CaelumHomingMagicProjectile",user.Pos+(32,0,28),NO_REPLACE));
        shot.Target=user;shot.ConfigureCaelumSeeking(1024,0,0,45);
        // One diagnostic-only old census per comparison, never a production consumer.
        Actor oldBest;let old=ThinkerIterator.Create("Actor");Thinker entry;int count=0;
        while(count<2048 && (entry=old.Next())!=null){count++;oldBest=shot.BetterSeekTarget(Actor(entry),oldBest);}
        Check(count<2048,"diagnostic old census remains inside its explicit actor bound");
        Console.Printf("CA430 SEEK old=%s new=%s",oldBest!=null ? oldBest.GetClassName() : 'none',shot.Tracer!=null ? shot.Tracer.GetClassName() : 'none');
        Check(oldBest!=null && shot.Tracer==oldBest,"local homing acquisition agrees with the old native census on this scene");
        shot.SetOrigin(shot.Pos+(64,0,0),false);
        Check(shot.FindBestCaelumSeekTarget()==oldBest,"moving projectile keeps the original acquisition sphere");
        Console.Printf("CA430 SEEK oracle census actors=%d",count);shot.Destroy();
        Console.Printf("CA430 RESULT homing regression failures=%d",Failures);
    }
    override void WorldTick()
    {
        if(Stage==0)return;
        if(level.time-Start>700){Check(false,"ranged fixture reached its bounded deadline");Stage=0;return;}
        if(Stage==1)
        {
            if(level.time<Start+2)return;
            let party=CaelumCompanionParty.Get(CaelumPlayer(players[0].mo),true);
            Check(party.Recruit(Body),"real subcaptain bond accepts the ranged test loadout");
            party.SetOrder(Body.Companion,CaelumCompanionData.WAIT);
            Body.SetStateLabel("TestIdle");Body.target=Victim;Body.Angle=Body.AngleTo(Victim);
            Loadout=Body.Companion.Loadout;
            let model=new("CaelumWeaponModel");model.InitializeDefaults();
            Item=Loadout.MakeItem("CaelumWeaponPickup",CaelumConstants.EQUIPMENT_KIND_WEAPON,Type,1,
                CaelumConstants.EQUIPMENT_SIZE_M,100,model.GetWeightFor(Type,1,CaelumConstants.EQUIPMENT_SIZE_M),null);
            if(MagicMode)
            {
                Item.EssenceType=CaelumSupportImplementData.IsSupport(Type) ? CaelumConstants.ESSENCE_QUINTESSENCE : CaelumConstants.ESSENCE_FIRE;
                // Diagnostic-only intellect forces guaranteed wear, independently of the random remainder.
                Body.CombatIntelligence=1000;Body.UpdateActorOffensiveStatistics();Body.bBuddha=true;
            }
            Check(Loadout.Toggle(Item),"native weapon equipment can be selected");Stage=ToolMode ? 20 : MagicMode ? 10 : 2;
        }
        if(Stage==20)
        {
            Body.SetStateLabel("TestIdle");Victim.SetOrigin(Body.Pos+(Type==CaelumConstants.WEAPON_TYPE_BOLAS?-120:-64,0,0),false);
            Body.Angle=Body.AngleTo(Victim);Body.target=Victim;
            if(!CaelumVisualPerception.Identify(Body,Victim))return;
            Body.CurrentCombatAir=0;Body.CurrentCombatAnima=0;
            Check(!Loadout.TryAttack(),"selected tool cannot act with empty resources");
            Body.CurrentCombatAir=Body.MaximumCombatAir;Body.CurrentCombatAnima=Body.MaximumCombatAnima;
            BeforeAnima=Body.CurrentCombatAnima;double air=Body.CurrentCombatAir;
            Check(Loadout.TryAttack() && Body.CombatActiveTool==Item,"selected tool begins its native actor action");
            Check(!Loadout.CanChange(),"equipment cannot be replaced during a tool action");
            ToolInitialAir=air;
            Body.SetStateLabel("TestIdle");FinishTic=level.time+100;Stage=21;
        }
        if(Stage==21)
        {
            if(Type==CaelumConstants.WEAPON_TYPE_UTILITY_STAFF && ToolDiagnostic++<3)
                Console.Printf("CA430 ICE phase=%d anima=%.3f cost=%.3f equipped=%d owner=%d health=%d interrupted=%d valid=%d target=%s sight=%d",Loadout.Tools.Phase,Body.CurrentCombatAnima,CaelumUtilityStaff.ActorCostPerSecond(Body)/TICRATE,Item.Equipped,Item.Owner==Body,Body.health,CaelumBolas.Interrupted(Body),Loadout.Tools.BattleActive(),Body.target!=null?Body.target.GetClassName():'none',Body.CheckSight(Victim));
            if(Body.CurrentCombatAir<ToolInitialAir)ToolPaidAir=true;
            if(Body.CurrentCombatAnima<BeforeAnima)ToolPaidAnima=true;
            if(Victim.ElementalStatus!=null && Victim.ElementalStatus.FreezeRemaining>0)ToolAppliedEffect=true;
            Body.SetStateLabel("TestIdle");
            if(level.time<FinishTic)return;
            Console.Printf("CA430 TOOL type=%d phase=%d uses=%d air=%d hp=%d raw=%.3f damage=%d distance=%.3f",Type,Loadout.Tools.Phase,Loadout.Tools.MeleeUses,ToolPaidAir,Victim!=null?Victim.health:-1,Loadout.Tools.LastStrikeRawDamage,Loadout.Tools.LastStrikeDamage,Victim!=null?Body.Distance2D(Victim):-1);
            if(Victim!=null)Console.Printf("CA430 DEFENSE post=%.3f grade=%d armor=%.3f invuln=%d evasion=%d",Victim.LastCombatPostToughnessDamage,Victim.LastAnatomyVulnerabilityGrade,Victim.LastCombatArmorDefenseExactPercent,Victim.bInvulnerable,Victim.LastCombatEvasionSucceeded);
            if(Victim!=null)Console.Printf("CA430 BIO mass=%.1f toughness=%d reduction=%.3f incoming=%.3f",double(Victim.Mass),Victim.CombatToughness,CaelumToughnessRules.ActorReduction(Victim,CaelumToughnessRules.Effective(Victim)),Victim.LastCombatArmorIncomingDamage);
            FLineTraceData trace;Body.LineTrace(Body.Angle,Loadout.Tools.MeleeRange(false),Body.Pitch,TRF_ABSPOSITION,Body.Pos.Z+Body.Height/2,Body.Pos.X,Body.Pos.Y,trace);
            Console.Printf("CA430 TRACE receiver=%s expected=%s yaw=%.2f pitch=%.2f range=%.2f",trace.HitActor!=null?trace.HitActor.GetClassName():'none',Victim.GetClassName(),Body.Angle,Body.Pitch,Loadout.Tools.MeleeRange(false));
            if(Type==CaelumConstants.WEAPON_TYPE_SWORD)
                Check(ToolPaidAir && Loadout.Tools.MeleeUses==1 && (VictimDied || Victim.health<100000),"native selected melee cycle damages the real opponent once");
            else if(Type==CaelumConstants.WEAPON_TYPE_BOLAS)
                Check(Loadout.Tools.BolasThrows==1 && CaelumBolas.Restrained(Victim),"native companion bolas physically bind the opponent");
            else Check(Loadout.Tools.IcePaidTics>0 && ToolPaidAnima
                && ToolAppliedEffect,"utility staff uses paid native elemental contact");
            Loadout.Tools.Cancel();Check(Body.CombatActiveTool==null,"tool action releases its equipment reservation");
            Console.Printf("CA430 RESULT selected tool passes=%d failures=%d",Passes,Failures);Stage=0;
        }
        if(Stage==10)
        {
            Body.target=Victim;if(!CaelumVisualPerception.Identify(Body,Victim))return;
            Body.CurrentCombatAnima=0;
            Check(!Loadout.TryAttack() && Loadout.Magic.Pending==null,"an empty Anima reserve cannot begin a spell");
            Body.CurrentCombatAnima=Body.MaximumCombatAnima;BeforeAnima=Body.CurrentCombatAnima;
            Check(Loadout.TryAttack() && Loadout.Magic.Pending==Item && Loadout.Magic.Remaining>0,
                "native magic begins its shared preparation before applying an effect");
            Check(Body.CurrentCombatAnima==BeforeAnima,"preparation does not prematurely spend Anima");
            Body.CombatLucidityPhysicalStunRemaining=1;Loadout.Magic.Tick();Body.CombatLucidityPhysicalStunRemaining=0;
            Check(Loadout.Magic.Pending==null && Body.CombatActiveTool==null && Body.CurrentCombatAnima==BeforeAnima,
                "physical interruption cancels preparation without applying or charging the spell");
            Body.target=Victim;Loadout.TryAttack();Body.SetStateLabel("TestIdle");
            ReloadSeconds=Loadout.Magic.Remaining;MagicCost=Loadout.Magic.Cost;ShotStart=level.time;Stage=11;
        }
        if(Stage==11 && Loadout.Magic.Releases>0)
        {
            Check(level.time-ShotStart>=int(ReloadSeconds*TICRATE)-1,"magic release waits for the shared casting duration");
            Check(Body.CurrentCombatAnima<BeforeAnima && MagicCost>0,"completed native magic spends real Anima");
            Check(Body.CombatActiveTool==null && Loadout.Magic.Pending==null,"completed spell releases its equipment reservation");
            if(CaelumSupportImplementData.IsSupport(Type))
            {
                int role=CaelumSupportImplementData.RoleForWeapon(Type);
                Actor recipient=Victim;if(CaelumSupportImplementData.Beneficial(role))recipient=Body;
                let status=CaelumSupportMagic.Status(recipient);
                Check(status!=null && status.Effects[role]!=null && status.Sources[role]==Body
                    && status.Effects[role].Active(),"support uses the real recipient and shared timed effect");
                if(CaelumSupportImplementData.Beneficial(role))
                    Check(!CaelumSupportMagic.Eligible(Body,Victim,role),"beneficial magic cannot buff an enemy");
                else Check(!CaelumSupportMagic.Eligible(Body,Body,role),"hostile magic cannot curse its own caster");
                FinishTic=level.time+1;
            }
            else FinishTic=level.time+TICRATE;
            Stage=12;
        }
        if(Stage==12 && level.time>=FinishTic)
        {
            if(!CaelumSupportImplementData.IsSupport(Type))
            {
                Check(VictimDied || (Victim!=null && Victim.health<100000),"native magic projectile or explosion damages the actual target");
                Check(Item.Durability<100,"native magic impact wears the exact equipped item");
            }
            Check(Loadout.Magic.Releases==1,"one preparation commits exactly one spell");
            Console.Printf("CA430 MAGIC type=%d health=%d durability=%d cost=%.6f",Type,Victim!=null ? Victim.health : -1,Item.Durability,MagicCost);
            Console.Printf("CA430 RESULT magic complete passes=%d failures=%d",Passes,Failures);Stage=0;
        }
        if(Stage==2)
        {
            Body.target=Victim;
            if(!CaelumVisualPerception.Identify(Body,Victim))return;
            Check(!Loadout.TryAttack(),"no ammunition means no shot or invented reserve");
            Name ammoType=CaelumInventoryService.GetAmmunitionClassName(null,CaelumRangedRules.AmmoType(Type));
            Ammo=Inventory(Actor.Spawn(ammoType,Body.Pos,NO_REPLACE));Ammo.Amount=2;Ammo.AttachToOwner(Body);
            Check(Loadout.TryAttack() && Loadout.Ranged.ReloadRemaining>0 && Loadout.Ranged.Shots==0,
                "an empty magazine starts the shared timed reload before firing");
            OriginalSpeed=Body.CombatBaseSpeed*CaelumSupportMagic.Factor(Body)*Body.CombatHealthPerformanceMultiplier*CaelumThermalEffects.Speed(Body);
            Body.UpdateCombatHealthEffects();double speed=Body.Speed;Body.UpdateCombatHealthEffects();
            Check(Abs(speed-OriginalSpeed*CaelumConstants.RELOAD_MOVEMENT_AND_PROGRESS_MULTIPLIER)<0.000001
                && Abs(Body.Speed-speed)<0.000001,"cached movement preserves exactly one reload speed modifier");
            Check(Loadout.Toggle(Item) && Loadout.Ranged.ReloadRemaining==0 && Ammo.Amount==2,
                "changing equipment cancels a reload without consuming its reserve");
            Check(Loadout.Toggle(Item) && Loadout.TryAttack(),"the same weapon can restart its cancelled reload");
            ReloadSeconds=Loadout.Ranged.ReloadRemaining;ShotStart=level.time;Stage=3;
        }
        if(Stage==3)
        {
            Body.target=Victim;int shots=Loadout.Ranged.Shots;double air=Body.CurrentCombatAir;
            Loadout.TryAttack();
            if(Loadout.Ranged.Shots>shots)
            {
                Check(Body.CurrentCombatAir<air,"a committed native shot spends the companion's actual Air");
                if(shots==0)
                {
                    Check(level.time-ShotStart>=int(ReloadSeconds*TICRATE)-1,"first shot waits for the complete shared reload duration");
                    Check(Ammo.Amount==1 && Loadout.Ranged.Magazine[Loadout.Ranged.Slot(Type)]==1,
                        "one shot removes one actual projectile and one magazine reference");
                }
            }
            if(Loadout.Ranged.Shots>=2){Stage=4;FinishTic=level.time+15;}
        }
        if(Stage==4 && level.time>=FinishTic)
        {
            Check(Loadout.Ranged.Shots==2 && Loadout.Ranged.Ammunition()==null
                && !Loadout.TryAttack(),"exhausted ammunition cannot fire a third projectile");
            Check(Victim.health<100000,"shared projectile collision applies real damage to the target");
            Check(Loadout.Ranged.Reloads==1,"cancelled reload never creates a completed reload");
            Console.Printf("CA430 WEAPON type=%d shots=%d health=%d durability=%d",Type,Loadout.Ranged.Shots,Victim.health,Item.Durability);
            Console.Printf("CA430 RESULT ranged complete passes=%d failures=%d",Passes,Failures);Stage=0;
        }
    }
}
