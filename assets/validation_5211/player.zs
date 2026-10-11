class CA194Player : CA194Combat
{
    override void WorldTick()
    {
        Age++;if(Age!=5)return;
        let u=CaelumPlayer(players[0].mo);
        u.bInvulnerable=false;u.CreationWizardOpen=false;u.CharacterCreationComplete=true;
        u.Attributes.Toughness=0;u.DerivedStats.BaseMass=80;u.DerivedStats.TotalMass=80;
        u.CaelumMaximumHealth=u.health=u.player.health=10000000;
        u.EffectiveEvasionChance=0;u.CombatBlockModeActive=false;u.DebugShieldBlocking=false;
        u.CharacterProfile.Race=CaelumConstants.RACE_HUMAN;
        u.ArmorModel=new("CaelumArmorModel");u.ArmorModel.InitializeDefaults();
        u.WeaponModel.Equipped=false;u.ShieldModel.Equipped=false;
        u.AnatomyProfile=new("CaelumAnatomyProfile");
        u.AnatomyProfile.AddRegion(CaelumConstants.HIT_LOCATION_TORSO,3,0,1,0,1);
        u.SetOrigin((0,0,0),false);u.Angle=0;
        let source=Fresh(200);source.SetOrigin((32,0,0),false);
        u.LucidityPhysicalStunRemaining=0;u.ForcedSleepTics=0;u.JumpZ=4;
        u.ReceiveCaelumImpact(10,CaelumConstants.IMPACT_KIND_FLOOR,null,1,80,0,10,800,0,0,false,1000);
        Check("player landing energy after speed cushion",u.LastImpactCushionedJoules,360);
        Check("player landing R once",u.LastImpactFinalDamage,253);
        let rock=Actor.Spawn("CaelumHazardRock",u.Pos+(0,0,-96));
        u.ReceiveCaelumImpact(10,CaelumConstants.IMPACT_KIND_FLOOR,rock,1,80,0,10,800,0,0,false,1000);
        Check("landing on hazard rock retains cushioning",u.LastImpactCushionedJoules,360);
        Check("landing on hazard rock remains floor",u.LastImpactKind,CaelumConstants.IMPACT_KIND_FLOOR);
        rock.Destroy();
        u.ReceiveCaelumImpact(10,CaelumConstants.IMPACT_KIND_ENVIRONMENT,source,1,80,200,10,800,0,1,false,1000);
        Check("incoming moving source no walking cushion",u.LastImpactCushionedJoules,1000);
        Check("player body final R once",u.LastImpactFinalDamage,845);
        for(int i=0;i<3;i++)
        {
            u.CharacterProfile.EnsurePersonality();u.CharacterProfile.Personality[3]=i;
            u.WeaponModel.Equipped=true;u.WeaponModel.WeaponType=CaelumConstants.WEAPON_TYPE_SWORD;
            source.CombatArmor.InitializeUniformLoadout(CaelumConstants.ARMOR_TYPE_HEAVY,1);
            source.ReceiveCaelumImpact(10,CaelumConstants.IMPACT_KIND_ACTOR,u,1,200,80,10,800,0,1,false,1000);
            Check("body ideology cannot bypass equipped armor",source.LastImpactFinalDamage,30);
        }
        let shot=CaelumCannonProjectile(Actor.Spawn("CaelumCannonProjectile",(32,0,20)));
        Check("cannon retains full armor",CaelumArmorRules.EquipmentRetention(shot,u),1);
        u.ArmorModel.InitializeUniformLoadout(CaelumConstants.ARMOR_TYPE_HEAVY,1);
        u.ReceiveCaelumImpact(10,CaelumConstants.IMPACT_KIND_ENVIRONMENT,shot,1,80,4.3,10,800,0,1,false,1000);
        Check("cannon armor same as body",u.LastImpactFinalDamage,150);
        source.Destroy();shot.Destroy();
        Console.Printf("CA194 DONE failures=%d passes=%d",Failures,Passes);
    }
}
