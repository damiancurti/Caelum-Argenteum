class CA238CompatibilityCurrent : CA238CompatibilityProbe
{
    int InitialPreparation;
    bool InitialRacial;
    bool Legacy;
    override void NetworkProcess(ConsoleEvent e)
    {Super.NetworkProcess(e);if(e.Name=="c238_legacy")Legacy=true;}
    override void WorldLoaded(WorldEvent e)
    {
        let user=CaelumPlayer(players[0].mo);
        InitialPreparation=user==null?-1:user.ClassPreparationTics;
        InitialRacial=user!=null && user.RacialAbilityActive;
        Console.Printf("CA238 LOAD remaining=%d",InitialPreparation);
    }
    override void WorldTick()
    {
        Super.WorldTick();
        if(Age==80)
        {
            let user=CaelumPlayer(players[0].mo);
            Console.Printf("CA238 COMPAT legacy=%d initial=%d current=%d revision=%d",
                Legacy,InitialPreparation,user==null?-1:user.ClassPreparationTics,
                user==null?-1:user.ClassPreparationRevision);
            bool ok=user!=null && (Legacy?InitialPreparation==0:InitialPreparation>0)
                && InitialPreparation<3*TICRATE
                && user.ClassPreparationTics==0 && user.ClassPreparationRevision==CaelumClassCastView.REVISION;
            Console.Printf("CA238 %s saved preparation resumes without restarting",ok?"PASS":"FAIL");
            bool racial=user!=null && !InitialRacial && !user.RacialAbilityActive;
            Console.Printf("CA238 %s older saves keep the new racial display inactive",racial?"PASS":"FAIL");
            Console.Printf("CA238 DONE failures=%d PREPARATION_SAVE_ONLY",(ok?0:1)+(racial?0:1));
        }
    }
}
