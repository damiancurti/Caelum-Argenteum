// Diagnostic inputs intentionally isolate capacity from anatomy and defenses.
class CA211Checks : StaticEventHandler
{
    int Age, Passes, Failures;
    CaelumPlayer User;
    void Check(String label,double actual,double expected,double tolerance=0.000001)
    {
        bool ok=Abs(actual-expected)<=tolerance;
        if(ok)Passes++;else Failures++;
        Console.Printf("CA282 %s %s actual=%.9f expected=%.9f",ok?"PASS":"FAIL",label,actual,expected);
    }
    override void UiTick(){if(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();}
    void Reset()
    {
        User.LucidityPhysicalStunRemaining=0;User.PainImmobilizationRemaining=0;
        User.ForcedSleepTics=0;User.CombatChannelModeActive=false;
        User.health=User.player.health=User.CaelumMaximumHealth=10000000;
    }
    void Hit(String label,double delta,int kind,double expected,bool stationary=false,Actor source=null,Vector3 normal=(0,0,0))
    {
        Reset();
        User.ReceiveCaelumImpact(delta,kind,source,1,80,80,delta,80*delta,0,1,stationary,1000,null,normal);
        Check(label,User.LastImpactCushionedJoules,expected);
        Check("raw assigned energy preserved",User.LastImpactReceivedJoules,1000);
    }
    override void WorldTick()
    {
        Age++;if(Age!=5)return;
        User=CaelumPlayer(players[0].mo);
        User.CreationWizardOpen=false;User.CharacterCreationComplete=true;User.bInvulnerable=false;
        User.Attributes.Toughness=0;User.Attributes.Agility=0;
        User.DerivedStats.BaseMass=80;User.DerivedStats.TotalMass=80;
        User.CombatBlockModeActive=false;User.DebugShieldBlocking=false;
        User.WeaponModel.Equipped=false;User.ShieldModel.Equipped=false;
        User.ArmorModel.InitializeDefaults();User.ElementalStatus=new("CaelumElementalStatus");
        User.IsCrouching=true;Reset();
        User.EffectiveJumpHeightPercent=100;User.ApplyPhysicalMovement();
        double jump=Sqrt(20.0)*32/35;
        Check("agility zero native jump",User.JumpZ,jump);
        Check("agility zero horizontal capacity nonzero",User.GetImpactAgilityAbsorptionSpeed(CaelumConstants.IMPACT_KIND_WALL),1.5*jump);
        User.DerivedStats.TotalMass=160;User.ApplyPhysicalMovement();
        Check("load reduces jump",User.JumpZ,jump/Sqrt(2.0));
        Check("load reduces horizontal capacity",User.GetImpactAgilityAbsorptionSpeed(CaelumConstants.IMPACT_KIND_WALL),1.5*jump/Sqrt(2.0));
        User.EffectiveJumpHeightPercent=50;User.ApplyPhysicalMovement();
        Check("health jump modifier reused",User.GetImpactAgilityAbsorptionSpeed(CaelumConstants.IMPACT_KIND_WALL),0.75*jump/Sqrt(2.0));
        User.ElementalStatus.FreezeRemaining=5;User.ElementalStatus.FreezePowerPercent=50;User.ApplyPhysicalMovement();
        Check("elemental jump modifier reused",User.GetImpactAgilityAbsorptionSpeed(CaelumConstants.IMPACT_KIND_WALL),0.375*jump/Sqrt(2.0));
        User.ElementalStatus.FreezeRemaining=0;User.JumpZ=4;
        Hit("below capacity",2,CaelumConstants.IMPACT_KIND_WALL,0);
        Hit("at capacity",6,CaelumConstants.IMPACT_KIND_WALL,0);
        Hit("above capacity residual squared",10,CaelumConstants.IMPACT_KIND_WALL,160);
        Hit("zero delta guard",0,CaelumConstants.IMPACT_KIND_WALL,1000);
        Hit("landing now 150 percent",10,CaelumConstants.IMPACT_KIND_FLOOR,160);
        Hit("crush unchanged",10,CaelumConstants.IMPACT_KIND_CRUSH,360);
        Hit("stationary scenery",10,CaelumConstants.IMPACT_KIND_ENVIRONMENT,160,true);
        Hit("moving scenery excluded",10,CaelumConstants.IMPACT_KIND_ENVIRONMENT,1000);
        Hit("incoming body excluded",10,CaelumConstants.IMPACT_KIND_ACTOR,1000);
        User.IsCrouching=false;
        Hit("idle wall excluded",10,CaelumConstants.IMPACT_KIND_WALL,1000);
        User.ShieldModel.Equipped=true;User.ShieldModel.Durability=100;
        User.ShieldModel.ShieldType=CaelumConstants.SHIELD_TYPE_BUCKLER;User.CombatBlockModeActive=true;
        Hit("buckler actor capacity",20,CaelumConstants.IMPACT_KIND_ACTOR,160);
        User.IsCrouching=true;
        Hit("buckler and movement do not stack",20,CaelumConstants.IMPACT_KIND_WALL,160);
        Hit("buckler landing now 150 percent",20,CaelumConstants.IMPACT_KIND_FLOOR,160);
        Reset();User.LucidityPhysicalStunRemaining=5;
        Check("stun suppresses ordinary and buckler",User.GetImpactAgilityAbsorptionSpeed(CaelumConstants.IMPACT_KIND_WALL),0);
        Reset();User.CombatChannelModeActive=true;
        Check("channel immobilization",User.GetImpactAgilityAbsorptionSpeed(CaelumConstants.IMPACT_KIND_WALL),0);
        Reset();User.JumpZ=0;
        Hit("zero jump no absorption",10,CaelumConstants.IMPACT_KIND_WALL,1000);
        User.JumpZ=4;Reset();
        let rock=Actor.Spawn("CaelumHazardRock",User.Pos+(256,0,0));
        Check("hazard pressure retains old fractional rule",CaelumImpactEnergy.CushionWork(User,rock,1000,1600,80),250);
        Hit("vertical falling rock active buckler",20,CaelumConstants.IMPACT_KIND_ENVIRONMENT,160,false,rock,(0,0,1));
        Hit("hazard crush diagnostic and energy remain old",20,CaelumConstants.IMPACT_KIND_CRUSH,250,false,rock,(1,0,0));
        User.CombatBlockModeActive=false;
        Check("incoming hazard work no ordinary allowance",CaelumImpactEnergy.CushionWork(User,rock,1000,1600,80),1000);
        Check("body crush work unchanged",CaelumImpactEnergy.CushionWork(User,null,1000,800,80),360);
        rock.Destroy();
        let bull=CaelumBull(Actor.Spawn("CaelumBull",(512,512,0)));
        bull.Mass=900;bull.CombatAgility=0;bull.BullChargeActive=true;bull.CombatLucidityPhysicalStunRemaining=0;
        double capacity=1.5*CaelumPhysicsUnits.JumpVelocity(900,900,0);
        Check("bull agility zero capacity",bull.ImpactAbsorptionSpeed(100,CaelumConstants.IMPACT_KIND_ACTOR,(1,0,0)),capacity);
        Check("bull at capacity",bull.RetainImpactEnergy(1000,capacity,CaelumConstants.IMPACT_KIND_ACTOR,(1,0,0)),0);
        Check("bull twice capacity retains quarter",bull.RetainImpactEnergy(1000,2*capacity,CaelumConstants.IMPACT_KIND_ACTOR,(1,0,0)),250);
        Check("bull floor now 150 percent",bull.RetainImpactEnergy(1000,2*capacity,CaelumConstants.IMPACT_KIND_FLOOR,(0,0,1)),250);
        Check("bull crush unchanged",bull.RetainImpactEnergy(1000,2*capacity,CaelumConstants.IMPACT_KIND_CRUSH,(1,0,0)),1000*4.0/9);
        Check("bull vertical actor excluded",bull.RetainImpactEnergy(1000,2*capacity,CaelumConstants.IMPACT_KIND_ACTOR,(0,0,1)),1000);
        bull.CombatLucidityPhysicalStunRemaining=5;
        Check("bull stun uses landing suppression",bull.RetainImpactEnergy(1000,capacity,CaelumConstants.IMPACT_KIND_ACTOR,(1,0,0)),1000);
        bull.CombatLucidityPhysicalStunRemaining=0;bull.BullChargeActive=false;
        Check("bull inactive excluded",bull.RetainImpactEnergy(1000,capacity,CaelumConstants.IMPACT_KIND_ACTOR,(1,0,0)),1000);
        bull.BullChargeActive=true;bull.ElementalStatus=new("CaelumElementalStatus");
        bull.ElementalStatus.FreezeRemaining=5;bull.ElementalStatus.FreezePowerPercent=100;
        Check("bull frozen charge excluded",bull.RetainImpactEnergy(1000,capacity,CaelumConstants.IMPACT_KIND_ACTOR,(1,0,0)),1000);
        bull.ElementalStatus.FreezeRemaining=0;bull.CombatAgility=20;bull.CombatHealthPerformanceMultiplier=1;
        rock=Actor.Spawn("CaelumHazardRock",bull.Pos+(256,0,0));
        Check("NPC hazard pressure samples remain uncushioned",CaelumImpactEnergy.CushionWork(bull,rock,1000,9000,900),1000);
        bull.ReceiveCaelumImpact(10,CaelumConstants.IMPACT_KIND_CRUSH,rock,1,900,38170,10,9000,0,1,false,1000,null,(1,0,0));
        Check("bull hazard direct fallback retains old energy",bull.LastImpactCushionedJoules,598.492890584,0.00001);
        bull.BullChargeActive=true;bull.CombatHealthPerformanceMultiplier=1;
        bull.ReceiveCaelumImpact(10,CaelumConstants.IMPACT_KIND_CRUSH,rock,1,900,38170,10,9000,0,1,false,1000,null,(1,0,0),1000);
        Check("bull hazard captured work not cushioned twice",bull.LastImpactCushionedJoules,1000);
        Check("bull pressure diagnostics use old fraction",bull.LastImpactBiologicalAbsorptionSpeed,2.26376777273,0.00001);
        rock.Destroy();
        bull.Destroy();
        let npc=CaelumCombatActor(Actor.Spawn("CaelumRulo",(1000,1000,0)));
        npc.CombatLucidityPhysicalStunRemaining=0;
        double normalJump=CaelumPhysicsUnits.JumpVelocity(npc.Mass,npc.Mass+npc.GetAttackCarriedWeight(),npc.CombatAgility);
        Check("ordinary NPC landing now 150 percent",npc.RetainImpactEnergy(1000,3*normalJump,CaelumConstants.IMPACT_KIND_FLOOR,(0,0,1)),250);
        Check("ordinary NPC crush unchanged",npc.RetainImpactEnergy(1000,3*normalJump,CaelumConstants.IMPACT_KIND_CRUSH,(1,0,0)),1000*4.0/9);
        Check("ordinary NPC horizontal remains excluded",npc.RetainImpactEnergy(1000,3*normalJump,CaelumConstants.IMPACT_KIND_ACTOR,(1,0,0)),1000);
        npc.Destroy();
        Console.Printf("CA282 DONE passes=%d failures=%d",Passes,Failures);
    }
}
