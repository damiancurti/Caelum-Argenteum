// Matriz independiente de los valores de producción; dispara los lanzadores reales.
class CA192Ranged : CA192Native
{
    int Before;
    double ExpectedArmor;
    CaelumCarbineProjectile Launch(int family,int tier,int ideology)
    {
        int types[]={CaelumConstants.WEAPON_TYPE_LONGBOW,CaelumConstants.WEAPON_TYPE_CROSSBOW,
            CaelumConstants.WEAPON_TYPE_CARBINE,CaelumConstants.WEAPON_TYPE_SHOTGUN};
        Choices(0,0,0,ideology);
        User.WeaponModel.WeaponType=types[family];User.WeaponModel.Tier=tier;User.WeaponModel.Equipped=true;
        let shot=CaelumRangedRules.Fire(User,User.WeaponModel,1000,false,1,0,0);
        shot.Vel=(0,0,0);return shot;
    }
    void Matrix()
    {
        double bypass[]={0.2,0.3,0.4,0.4,0.5,0.6,0.7,0.8,0.9,0.6,0.7,0.8};
        for(int family=0;family<4;family++)for(int tier=1;tier<=3;tier++)for(int ideology=0;ideology<3;ideology++)
        {
            Console.Printf("CA192 ROW family=%d tier=%d ideology=%d",family,tier,ideology);
            Reset();User.EffectiveEvasionChance=0;let shot=Launch(family,tier,ideology);
            double retention=1-bypass[family*3+tier-1];
            Check("inherent equipped armor bypass",CaelumArmorRules.EquipmentRetention(shot),retention);
            Check("offensive ideology excluded",CaelumPersonalityRules.AttackPenetration(shot),0);
            Check("launcher keeps raw damage",shot.CaelumPreparedDamage,1000);
            Check("direct weapon identity excluded",CaelumPersonalityRules.AttackPenetration(User),0);
            User.WeaponModel.WeaponType=CaelumConstants.WEAPON_TYPE_SWORD;
            Choices(0,0,0,0);shot.CaelumIdeologyPenetration=0.25;
            Check("old flight snapshot excluded after weapon switch",CaelumPersonalityRules.AttackPenetration(shot),0);
            shot.CaelumPersonalityRevision=0;
            Check("legacy projectile fallback excluded",CaelumPersonalityRules.AttackPenetration(shot),0);
            User.ArmorModel.InitializeUniformLoadout(CaelumConstants.ARMOR_TYPE_HEAVY,1);
            Receiver.CombatArmor.InitializeUniformLoadout(CaelumConstants.ARMOR_TYPE_HEAVY,1);
            Check("35 percent armor example",CaelumArmorRules.EquippedDefense(User.ArmorModel,1,false,User,shot),35*retention);
            Check("racial defense untouched",User.GetArmorDefensePercent(1,false,shot),7.5+35*retention);
            shot.SetOrigin(Receiver.Pos+(0,0,Receiver.Height*0.6),false);
            int before=Receiver.health;Receiver.DamageMobj(shot,User,1,'CaelumRangedTest',0,0);
            Check("NPC full native impact armor then racial",Receiver.LastCombatArmorPostDefenseDamage,
                Receiver.LastCombatArmorIncomingDamage*(1-(7.5+35*retention)/100));
            Check("NPC full native impact then toughness",before-Receiver.health,
                int(Max(0,Receiver.LastCombatArmorPostDefenseDamage-120.32)+0.5));
            for(int defense=0;defense<3;defense++)for(int magic=0;magic<2;magic++)
            {
                Choices(0,0,0,defense);double boost=magic?(defense==0?1:defense==1?1.125:1.25):1;
                User.ArmorModel.InitializeUniformLoadout(CaelumConstants.ARMOR_TYPE_MAGIC,1);
                Check("defensive ideology retained",CaelumArmorRules.EquippedDefense(User.ArmorModel,1,magic,User,shot),
                    (magic?30:10)*boost*retention);
                let shield=EquipShield(1);
                double remaining=User.ResolveRealShieldDamage(shot,Attacker,1000,magic?'CaelumMagicTest':'Hitscan');
                Check("no armor bypass leaks into shield",remaining,1000*(1-Min(1,0.8*boost)));
                User.PrepareRealArmorDamage(remaining,false,CaelumConstants.ARMOR_SLOT_BODY,magic,shot);
                Check("player shield armor racial then physical or half R",User.LastArmorHealthDamage,
                    int(Max(0,remaining*User.LastArmorVulnerabilityMultiplier*(1-(7.5+(magic?30:10)*boost*retention)/100)
                        -120.32*(magic?0.5:1))+0.5));
                shield.Destroy();
            }
            shot.Destroy();
        }
        Reset();
        for(int ideology=0;ideology<3;ideology++)
        {
            double pen=ideology==0?0.25:ideology==1?0.125:0;
            Choices(0,0,0,ideology);User.WeaponModel.Equipped=true;
            User.WeaponModel.WeaponType=CaelumConstants.WEAPON_TYPE_SWORD;
            Check("melee still receives ideology",CaelumPersonalityRules.AttackPenetration(User),pen);
            let spell=Shot(ideology,CaelumConstants.WEAPON_TYPE_BELL,1);
            User.WeaponModel.WeaponType=CaelumConstants.WEAPON_TYPE_LONGBOW;
            Check("spell snapshot unaffected by held bow",CaelumPersonalityRules.AttackPenetration(spell),pen);spell.Destroy();
            let javelin=Shot(ideology,CaelumConstants.WEAPON_TYPE_JAVELIN,1);
            User.WeaponModel.WeaponType=CaelumConstants.WEAPON_TYPE_CROSSBOW;
            Check("javelin snapshot unaffected by held crossbow",CaelumPersonalityRules.AttackPenetration(javelin),pen);javelin.Destroy();
            let channel=CaelumChannelEffect(Actor.Spawn("CaelumChannelEffect",User.Pos));channel.ChannelOwner=User;
            Check("channel unaffected by held crossbow",CaelumPersonalityRules.AttackPenetration(channel),pen);channel.Destroy();
        }
    }
    override void WorldTick()
    {
        Age++;if(Age<40)return;
        if(Age==40)
        {
            User=CaelumPlayer(players[0].mo);User.bNOTARGET=true;
            Receiver=CaelumCombatActor(Actor.Spawn("CA192Target",User.Pos+(256,0,0)));
            Attacker=Actor.Spawn("CA192Target",User.Pos+(128,0,32));Matrix();
        }
        if(Age==45 || Age==65 || Age==85)
        {
            Reset();User.EffectiveEvasionChance=0;User.ArmorModel.InitializeUniformLoadout(CaelumConstants.ARMOR_TYPE_HEAVY,1);
            Receiver.CombatArmor.InitializeUniformLoadout(CaelumConstants.ARMOR_TYPE_HEAVY,1);
            bool playerHit=Age==85;int family=Age==45?0:1;
            Actor victim=playerHit?Actor(User):Actor(Receiver);
            Before=victim.health;ExpectedArmor=family==0?28:21;
            let shot=Launch(family,1,0);if(playerHit)shot.Target=Attacker;
            shot.SetOrigin(victim.Pos+(64,0,victim.Height*0.6),false);shot.Angle=180;shot.Vel=(-20,0,0);
        }
        if(Age==55 || Age==75 || Age==95)
        {
            bool playerHit=Age==95;double post=playerHit?User.LastArmorPostDefenseDamage:Receiver.LastCombatArmorPostDefenseDamage;
            int lost=Before-(playerHit?User.health:Receiver.health);
            Truth("actual flying arrow or bolt collides",lost>0);
            Check("actual flight mitigation preserves toughness",lost,int(Max(0,post-120.32)+0.5));
            if(!playerHit)Check("actual flight racial and equipped absorption",post,
                Receiver.LastCombatArmorIncomingDamage*(1-(7.5+ExpectedArmor)/100));
        }
        if(Age==100)Console.Printf("CA192 DONE failures=%d passes=%d",Failures,Passes);
    }
}
