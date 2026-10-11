// Casos controlados sobre los receptores y lanzadores reales de GZDoom.
class CA192Target : CaelumCombatActor
{
    override void Tick(){}
    Default {Radius 16;Height 56;Mass 80;Health 1000000;+SHOOTABLE;+NOGRAVITY;}
    States {Spawn: TNT1 A -1;Stop;}
}
class CA192Native : StaticEventHandler
{
    int Age,Passes,Failures;
    CaelumPlayer User;
    CaelumCombatActor Receiver;
    Actor Attacker;
    void Check(String label,double actual,double expected,double tolerance=0.00001)
    {
        bool ok=Abs(actual-expected)<=tolerance;if(ok)Passes++;else Failures++;
        Console.Printf("CA192 %s %s actual=%.9f expected=%.9f",ok?"PASS":"FAIL",label,actual,expected);
    }
    void Truth(String label,bool value){Check(label,value?1:0,1);}
    override void UiTick(){if(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();}
    void Choices(int a,int b,int c,int d)
    {
        let p=User.CharacterProfile;p.PersonalityRevision=1;
        p.Personality[0]=a;p.Personality[1]=b;p.Personality[2]=c;p.Personality[3]=d;
    }
    void Reset(double attribute=20)
    {
        User.CharacterCreationComplete=true;User.CreationWizardOpen=false;User.bInvulnerable=false;
        User.CharacterProfile.Race=CaelumConstants.RACE_HUMAN;
        Choices(0,0,0,2);User.Attributes.SetAllForDebug(attribute);
        User.DerivedStats.Recalculate(User.Attributes,User.CharacterProfile);
        User.CaelumMaximumHealth=1000000;User.health=User.player.health=1000000;
        User.DerivedStats.BaseMass=80;User.DerivedStats.LoadRatio=0;
        User.ArmorModel=new("CaelumArmorModel");User.ArmorModel.InitializeDefaults();
        User.WeaponModel.Equipped=false;User.ShieldModel.Equipped=false;
        User.DebugShieldBlocking=false;User.CombatBlockModeActive=false;
        User.HealthAdrenalineGainMultiplier=1;User.HealthPerformanceMultiplier=1;
        User.CurrentAir=User.DerivedStats.MaximumAir;User.EffectiveOffensiveDamageMultiplier=1;
        User.CurrentLucidity=100;User.ElementalStatus=new("CaelumElementalStatus");
        Receiver.Mass=80;Receiver.CombatToughness=20;Receiver.CombatMaximumHealth=1000000;Receiver.health=1000000;
        Receiver.EffectiveCombatEvasionChance=0;Receiver.CombatArmor=new("CaelumArmorModel");Receiver.CombatArmor.InitializeDefaults();
    }
    CaelumActorProjectile Shot(int ideology,int weapon,int tier)
    {
        Choices(0,0,0,ideology);
        let shot=CaelumActorProjectile(Actor.Spawn("CaelumActorSimpleElementalProjectile",User.Pos+(128,0,32)));
        shot.target=User;shot.Vel=(0,0,0);
        shot.StoreCaelumAttackResult(1000,true,false,true,1);
        shot.StoreCaelumWeaponWearIdentity(weapon,tier,CaelumConstants.EQUIPMENT_SIZE_M);
        return shot;
    }
    CaelumEquipmentItem EquipShield(int tier)
    {
        let item=CaelumEquipmentItem(Actor.Spawn("CaelumShieldPickup",User.Pos));
        item.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_SHIELD;item.ItemType=CaelumConstants.SHIELD_TYPE_TOWER;
        item.Tier=tier;item.EquipmentSize=CaelumConstants.EQUIPMENT_SIZE_M;item.Equipped=true;
        item.PickupDataInitialized=true;item.AcquisitionResolved=true;item.AttachToOwner(User);User.EnsureEquipmentItemId(item);
        User.EquippedShieldItemId=item.ItemId;User.ShieldModel.ShieldType=item.ItemType;User.ShieldModel.Tier=tier;
        User.ShieldModel.Equipped=true;User.ShieldModel.Durability=100000;
        User.WeaponModel.Equipped=false;User.DebugShieldBlocking=true;User.Angle=User.AngleTo(Attacker);
        return item;
    }
}
