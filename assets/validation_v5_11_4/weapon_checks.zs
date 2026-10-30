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
    States { TestIdle: DOMI A -1; Stop; }
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
    override void WorldThingDied(WorldEvent e){if(e.Thing==Victim)VictimDied=true;}
    void Check(bool ok,String label)
    {if(ok){Passes++;Console.Printf("CA430 PASS %s",label);}else{Failures++;Console.Printf("CA430 FAIL %s",label);}}
    void Begin(int kind)
    {
        Type=kind;let user=CaelumPlayer(players[0].mo);
        Body=CA430WeaponCompanion(Actor.Spawn("CA430WeaponCompanion",user.Pos+(160,0,0),NO_REPLACE));
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
            Check(Loadout.Toggle(Item),"native weapon equipment can be selected");Stage=MagicMode ? 10 : 2;
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
