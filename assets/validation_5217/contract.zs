// Isolated native fixture; never included in the production package.
class CA207Target : Actor
{
    Default {Health 100;Radius 8;Height 24;+SHOOTABLE;+NOGRAVITY;}
    States {Spawn:TNT1 A -1;Stop;}
}

class CA207Contract : StaticEventHandler
{
    int Failures,Passes,PlayerDeaths;
    bool Nested;
    CaelumPlayer User;
    CaelumCharacterProfile Profile;
    CaelumAppearanceHead Head;

    void Check(bool ok,String label)
    {
        if(ok)Passes++;else Failures++;
        Console.Printf("CA207 %s %s",ok?"PASS":"FAIL",label);
    }
    override void UiTick(){if(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();}
    override void WorldThingDied(WorldEvent e){if(e.Thing==players[0].mo)PlayerDeaths++;}
    override void WorldThingDamaged(WorldEvent e)
    {
        if(Nested && e.Thing==User)
        {
            Nested=false;
            User.DamageMobj(null,null,100,'CaelumImpact',DMG_NO_ARMOR,0);
            Check((User.player.cheats & CF_BUDDHA2)!=0,"nested call preserves outer protection bit");
        }
    }
    void Health(int value){User.health=value;User.player.health=value;}
    void Prepare()
    {
        User=CaelumPlayer(players[0].mo);Profile=CaelumCharacterIdentity.Profile(User);
        User.CreationWizardOpen=false;User.CharacterCreationComplete=true;
        Profile.Race=CaelumConstants.RACE_CAELITH;Profile.Sex=CaelumConstants.SEX_FEMALE;
        Profile.SkinTone=2;Profile.Face=3;Profile.HairStyle=2;Profile.HairColor=5;
        Profile.AppearanceRevision=CaelumAppearance.REVISION;
        User.ApplyCharacterProfile();User.EffectiveEvasionChance=0;
        User.bInvulnerable=false;User.player.cheats=0;
        User.CombatBlockModeActive=false;User.DebugShieldBlocking=false;
        User.ArmorModel=new("CaelumArmorModel");User.ArmorModel.InitializeDefaults();
        User.ShieldModel.Equipped=false;Health(50);
        Console.Printf("CA207 READY map=%s health=%d",level.MapName,User.health);
    }
    void Identity()
    {
        User=CaelumPlayer(players[0].mo);
        let profile=User.CharacterProfile;
        Check(profile!=null && profile.Race==CaelumConstants.RACE_CAELITH
            && profile.Sex==CaelumConstants.SEX_FEMALE && profile.SkinTone==2
            && profile.Face==3 && profile.HairStyle==2 && profile.HairColor==5,
            "nondefault identity and cosmetics retained");
        Check(User.player.playerstate==PST_LIVE && !User.bCorpse && User.health>=1
            && User.health==User.player.health,"living synchronized pawn");
        Check(!(User.player.cheats & CF_BUDDHA2),"no protection bit persisted");
    }
    void Floor(String label,int damage,Name kind,int flags=0,Actor inflictor=null)
    {
        Health(5);int beforeCheats=User.player.cheats;
        int lost=User.DamageMobj(inflictor,null,damage,kind,flags,0);
        Check(User.health==1 && User.player.health==1 && lost==4,label);
        Check(User.player.cheats==beforeCheats,"temporary bit restored: "..label);
    }
    void Contract()
    {
        Health(50);
        Head=User.AppearanceHead;int startingDeaths=PlayerDeaths;
        int result=User.DamageMobj(null,null,7,'CaelumImpact',DMG_NO_ARMOR,0);
        Check(result==7 && User.health==43,"nonlethal impact unchanged");
        Floor("lethal impact",1000,'CaelumImpact',DMG_NO_ARMOR);
        for(int i=0;i<12;i++)
            Check(User.DamageMobj(null,null,10000000,'CaelumImpact',DMG_NO_ARMOR,0)==0
                && User.health==1,"repeated lethal damage at floor");
        Floor("native telefrag",1000000,'Telefrag',DMG_NO_ARMOR);
        Floor("forced lethal damage",1000000,'None',DMG_FORCED|DMG_NO_ARMOR);
        Health(50);result=User.DamageMobj(null,null,7,'None',DMG_FORCED|DMG_NO_ARMOR,0);
        Check(result==7 && User.health==43,"forced nonlethal unarmored damage unchanged");
        Floor("drowning",1000,'Drowning',DMG_NO_ARMOR);
        Floor("continuous pressure",1000,'CaelumPressure',DMG_NO_ARMOR);
        Floor("elemental DOT route",1000,'CaelumElementalDOT',DMG_NO_ARMOR);
        let source=Actor.Spawn("CA207Target",User.Pos+(64,0,0));
        Floor("native crush/telefrag",1000000,'Crush',DMG_NO_ARMOR);
        Health(5);result=User.ApplyRealCombatDefense(source,source,100000,'Hitscan',0,0);
        Check(User.health==1 && result==4,"directed defense reaches floor after its calculations");
        Health(5);source.SetOrigin(User.Pos,false);
        result=User.ApplyExplosionDefense(source,source,100000,'Fire',DMG_EXPLOSION,0);
        Check(User.health==1 && result==4,"explosion defense reaches floor after its calculations");

        let armor=BasicArmor(User.FindInventory("BasicArmor"));
        if(armor==null){armor=BasicArmor(Actor.Spawn("BasicArmor"));armor.AttachToOwner(User);}
        armor.Amount=100;armor.SavePercent=0.9;
        Health(5);result=User.DamageMobj(null,null,10,'None',0,0);
        Check(User.health==4 && result==1 && armor.Amount==91,"native armor resolves before health floor");
        armor.Amount=100;Health(5);result=User.DamageMobj(null,null,10,'None',DMG_FORCED,0);
        Check(User.health==4 && result==1 && armor.Amount==91,"protected forced hit follows native Buddha2 armor semantics");
        armor.Destroy();
        Health(5);User.player.cheats|=CF_BUDDHA2;
        User.DamageMobj(null,null,100,'CaelumImpact',DMG_NO_ARMOR,0);
        Check((User.player.cheats & CF_BUDDHA2)!=0,"preexisting Buddha2 bit retained");
        User.player.cheats&=~CF_BUDDHA2;
        Health(5);Nested=true;User.DamageMobj(null,null,100,'CaelumImpact',DMG_NO_ARMOR,0);
        Check(!Nested && User.health==1 && !(User.player.cheats & CF_BUDDHA2),"nested damage restores introduced bit");
        Health(50);Nested=true;result=User.DamageMobj(null,null,7,'CaelumImpact',DMG_NO_ARMOR,0);
        Check(!Nested && User.health==1 && result==7 && !(User.player.cheats & CF_BUDDHA2),
            "nonlethal outer hit does not report nested damage twice");

        Health(2);User.HungerState=CaelumConstants.SURVIVAL_STATE_CRITICAL;
        User.SurvivalDamageAccumulator=100;
        CaelumPlayerResources.ApplyCriticalSurvivalDamage(User);
        Check(User.health==1 && User.player.health==1 && User.SurvivalDamageAccumulator<1,
            "survival floor consumes accumulated damage");
        User.SurvivalDamageAccumulator=100;CaelumPlayerResources.ApplyCriticalSurvivalDamage(User);
        Check(User.health==1 && User.SurvivalDamageAccumulator<1,"survival has no blocked damage debt");
        User.HungerState=0;
        let thermal=new("CaelumThermalState");thermal.Toughness=0;thermal.DamageRemainder=100;
        Health(2);CaelumThermalService.ApplyDamage(User,thermal,0);
        Check(User.health==1 && thermal.AppliedDamageHP==1 && thermal.DamageRemainder<1,
            "thermal floor counts only actual HP lost");
        thermal.DamageRemainder=100;CaelumThermalService.ApplyDamage(User,thermal,0);
        Check(User.health==1 && thermal.AppliedDamageHP==1 && thermal.DamageRemainder<1,
            "thermal has no blocked damage debt");

        let plan=CaelumJourneyPlan.Get(User,true);plan.Available=new("CaelumJourneyModel");
        plan.Available.Capture(User,false);plan.Available.Health=0;plan.Apply(User);
        Check(User.health==1 && User.player.health==1,"projected travel commit preserves MAP01 health floor");
        Health(0);User.Die(null,null,DMG_FORCED,'None');
        Check(User.health==1 && User.player.playerstate==PST_LIVE && PlayerDeaths==startingDeaths,
            "direct scripted death never enters native death");
        Check(User.CharacterProfile==Profile && User.AppearanceHead==Head
            && User.AppearanceDeathProfile==null && !User.bCorpse,"same profile and appearance actors retained");
        source.health=5;source.DamageMobj(null,null,1000000,'Telefrag',DMG_FORCED,0);
        Check(source.health<=0,"NPC remains mortal in MAP01");
        Identity();
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="c207_prepare")Prepare();
        if(e.Name=="c207_contract")Contract();
        if(e.Name=="c207_identity")Identity();
        if(e.Name=="c207_regression")
        {Floor("MAP01 lethal regression",1000,'CaelumImpact',DMG_NO_ARMOR);}
        if(e.Name=="c207_outside")
        {
            User=CaelumPlayer(players[0].mo);Health(5);
            if(e.Args[0]==0)User.DamageMobj(null,null,1000000,'Telefrag',DMG_FORCED,0);
            else if(e.Args[0]==1)
            {User.HungerState=CaelumConstants.SURVIVAL_STATE_CRITICAL;User.SurvivalDamageAccumulator=100;CaelumPlayerResources.ApplyCriticalSurvivalDamage(User);}
            else
            {let thermal=new("CaelumThermalState");thermal.DamageRemainder=100;CaelumThermalService.ApplyDamage(User,thermal,0);}
            Check(User.health<=0 && User.player.playerstate==PST_DEAD,"player mortality outside MAP01");
        }
        if(e.Name=="c207_done")Console.Printf("CA207 DONE failures=%d passes=%d",Failures,Passes);
    }
}
