class CA192Persistence : StaticEventHandler
{
    int Age,Visits,Failures;
    bool Loaded;
    double SavedHP,SavedAnima;
    override void UiTick(){if(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();}
    void Check(bool ok,String text){if(!ok)Failures++;Console.Printf("CA192 %s %s",ok?"PASS":"FAIL",text);}
    override void WorldLoaded(WorldEvent e)
    {
        Age=0;Loaded=e.IsSaveGame;Visits++;
        let u=CaelumPlayer(players[0].mo);if(u==null)return;
        SavedHP=u.health;SavedAnima=u.CurrentAnima;
    }
    override void WorldTick()
    {
        Age++;let u=CaelumPlayer(players[0].mo);if(u==null || u.DerivedStats==null)return;
        int mode=CVar.GetCVar("ca192_stage").GetInt();
        if(Loaded && Age==20 && mode==4)
        {
            double expected=CaelumConstants.DEBUG_STAFF_BASE_DAMAGE*CaelumGrowthRules.Multiplier(u.Attributes.Intelligence,3);
            Check(Abs(u.DerivedStats.DebugStaffDamage-expected)<0.00001,"protected old save rolls back to baseline power");
            Check(u.health<=SavedHP+2 && u.CurrentAnima<=SavedAnima+5,"rollback preserves depleted resources");
            Console.Printf("CA192 DONE failures=%d",Failures);return;
        }
        if(!Loaded && Visits==1 && Age==20)
        {
            u.InitializeDirectMapCharacter();u.bNOTARGET=true;
            u.health=u.player.health=Max(1,u.CaelumMaximumHealth/2);u.CurrentAnima=u.DerivedStats.MaximumAnima/3;
            u.PersistCharacterState();
            // #NEW-BEGIN
            if(mode==3){CaelumPersonalityRules.Unpack(u.CharacterProfile,26);u.ApplyCharacterProfile();u.PersistCharacterState();}
            // #NEW-END
        }
        // #NEW-BEGIN
        if(Loaded && Age==20)
        {
            int expected=mode==1?40:26;
            Check(CaelumPersonalityRules.Pack(u.CharacterProfile)==expected,"saved choices or explicit normal-center migration");
            double factor=mode==1?1.953125:3.375;
            double magic=CaelumConstants.DEBUG_STAFF_BASE_DAMAGE*CaelumGrowthRules.Multiplier(u.Attributes.Intelligence,3)*factor;
            Check(Abs(u.DerivedStats.DebugStaffDamage-magic)<0.00001,"loaded magical power derives once");
            u.ApplyCharacterProfile();u.ApplyCharacterProfile();
            Check(Abs(u.DerivedStats.DebugStaffDamage-magic)<0.00001,"recalculation cannot compound personality");
            Check(u.health<=SavedHP+2 && u.CurrentAnima<=SavedAnima+5,"migration grants no resource refill");
            let r=u.GetPersistentCharacterState(false);
            Check(r.IdentityProfile==u.CharacterProfile && CaelumPersonalityRules.Pack(r.IdentityProfile)==expected,"traveler remains authoritative");
            if(mode==1){CaelumPersonalityRules.Unpack(u.CharacterProfile,26);u.ApplyCharacterProfile();u.PersistCharacterState();}
            Console.Printf("CA192 DONE failures=%d",Failures);
        }
        if(!Loaded && Visits>1 && Age==20)
        {
            Check(CaelumPersonalityRules.Pack(u.CharacterProfile)==26,"map travel retains four selected choices");
            double expected=CaelumConstants.DEBUG_STAFF_BASE_DAMAGE*CaelumGrowthRules.Multiplier(u.Attributes.Intelligence,3)*3.375;
            Check(Abs(u.DerivedStats.DebugStaffDamage-expected)<0.00001,"map travel retains noncompounding power");
            Console.Printf("CA192 DONE failures=%d",Failures);
        }
        // #NEW-END
        if(!Loaded && Visits==1 && Age==40)
        {
            if(mode==3)Level.ChangeLevel("MAP02",0,CHANGELEVEL_NOINTERMISSION,-1);
            else Console.Printf("CA192 DONE failures=0 legacy checkpoint ready");
        }
    }
}
