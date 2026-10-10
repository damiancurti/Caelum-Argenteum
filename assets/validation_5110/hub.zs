class CA154Hub : StaticEventHandler
{
    int Elapsed,Visits;
    override void WorldLoaded(WorldEvent e){Elapsed=0;Visits++;}
    override void WorldTick()
    {
        Elapsed++;let u=CaelumPlayer(players[0].mo);if(u==null || u.DerivedStats==null)return;
        int mode=CVar.GetCVar("ca154_stage").GetInt();
        if(Elapsed==20)
        {
            if(!u.CharacterCreationComplete)u.InitializeDirectMapCharacter();u.bNOTARGET=true;
            double expected=u.AttributeBalanceVersion>=4 ? 205.008979591837 : 800;
            int markers=0;
            if(u.AttributeBalanceVersion>=4)
            {let it=ThinkerIterator.Create("Actor");Actor marker;while((marker=Actor(it.Next()))!=null)if(marker.GetClassName()=="CaelumPhysicsMapState")markers++;}
            Console.Printf("CA154 HUB %s mode=%d visit=%d map=%s gravity=%.12f markers=%d balance=%d hp=%.9f anima=%.9f air=%.9f",Abs(level.gravity-expected)<0.000001 && (u.AttributeBalanceVersion<4 || markers==1) ? "PASS" : "FAIL",mode,Visits,level.MapName,level.gravity,markers,u.AttributeBalanceVersion,double(u.health)/u.CaelumMaximumHealth,u.CurrentAnima/u.DerivedStats.MaximumAnima,u.CurrentAir/u.DerivedStats.MaximumAir);
        }
        if(Elapsed==40 && Visits<(mode==0 ? 2 : 3))
        {
            u.PersistCharacterState();
            Level.ChangeLevel(level.MapName=="MAP02" ? "MAP03" : "MAP02",0,CHANGELEVEL_NOINTERMISSION,-1);
        }
    }
}
