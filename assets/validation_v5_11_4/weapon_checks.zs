class CA430WeaponTarget : CaelumCombatActor
{
    Default { Health 100000; Radius 24; Height 56; Mass 80; Monster; }
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
    double ReloadSeconds,OriginalSpeed;
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
        if(e.Name=='ca430_carbine')Begin(CaelumConstants.WEAPON_TYPE_CARBINE);
        if(e.Name=='ca430_shotgun')Begin(CaelumConstants.WEAPON_TYPE_SHOTGUN);
        if(e.Name=='ca430_bow')Begin(CaelumConstants.WEAPON_TYPE_LONGBOW);
        if(e.Name=='ca430_crossbow')Begin(CaelumConstants.WEAPON_TYPE_CROSSBOW);
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
            Check(Loadout.Toggle(Item),"native ranged equipment can be selected");Stage=2;
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
