class CA598MatchProbe : StaticEventHandler
{
    CaelumStandalonePlayer Victim;
    int DeathTic;
    bool Done,RematchRequested;
    int Respawns;
    override void PlayerRespawned(PlayerEvent e){Respawns++;}
    void Check(bool ok,String label){Console.Printf("CA598 %s %s",ok?"PASS":"FAIL",label);}
    override void WorldTick()
    {
        if(Done)return;
        let match=CaelumStandaloneMatch.View();if(match==null || !match.Started)return;
        let first=CaelumStandalonePlayer(players[0].mo);let second=CaelumStandalonePlayer(players[1].mo);
        if(first==null || second==null)return;
        if(RematchRequested)
        {
            if(match.Finished || first.StandaloneRevision<1 || second.StandaloneRevision<1)return;
            Check(match.Score[0]==0 && match.Score[1]==0 && match.Deaths[0]==0 && match.Deaths[1]==0,"unanimous rematch resets score and deaths");
            Check(match.Elapsed<35 && !match.Finished,"unanimous rematch resets the match clock");
            Check(first.health>0 && second.health>0 && first.WeaponModel.SourceItem!=null && second.WeaponModel.SourceItem!=null,"rematch restores both living and dead participants");
            Console.Printf("CA598 RESULT deathmatch");Done=true;return;
        }
        if(level.time==175)
        {
            Check(match.Members==3 && match.Mode==1,"two native players share one match");
            Check(match.Score[0]==0 && match.Score[1]==0,"new match starts at zero");
            Check(CaelumMajorTargets.Enemy(first,second) && CaelumSleepRules.Enemy(first,second),"offensive abilities recognize the opposing participant");
            Check(!CaelumRedemption.Allied(first,second) && !CaelumTarotLovers.AlliedPlayers(first,second),"support abilities do not treat an opponent as a cooperative ally");
            Victim=second;DeathTic=level.time;
            second.DamageMobj(first,first,10000000,'None',DMG_FORCED|DMG_NO_ARMOR,0);
            Check(second.health<=0 && match.Score[0]==1 && match.Deaths[1]==1,"real player kill gives one frag");
            match.RecordDeath(second,first);
            Check(match.Score[0]==1 && match.Deaths[1]==1,"duplicate death does not award twice");
        }
        if(level.time==DeathTic+2 && DeathTic>0)
        {
            int count=0;for(Inventory item=Victim.Inv;item!=null;item=item.Inv)
            {if(item is 'CaelumEquipmentItem')count++;Console.Printf("CA598 DIAG dead item=%s",item.GetClassName());}
            Check(count==0 && Victim.StandaloneInventoryCleared,"dead equipment cannot become loot");
        }
        if(level.time==DeathTic+CaelumStandaloneData.RESPAWN_TICS-1 && DeathTic>0)
            Check(players[1].mo==Victim && !match.RespawnAllowed(1),"respawn cannot occur before three seconds");
        if(level.time==340)
        {
            Console.Printf("CA598 DIAG same=%d health=%d max=%d rev=%d victimnull=%d",second==Victim,second.health,second.CaelumMaximumHealth,second.StandaloneRevision,Victim==null);
            Check(Respawns>=1 && !second.StandaloneDeathRecorded && second.health>0 && second.StandaloneRevision==1 && match.RespawnAt[1]==0,"native respawn restores the dead participant");
            Check(second.StandalonePreset==1 && second.DerivedStats.BaseMass==140,"respawn restores selected resident");
            Check(second.health==second.CaelumMaximumHealth && second.WeaponModel.SourceItem!=null,"respawn restores health and usable equipment");
            int count=0;for(Inventory item=second.Inv;item!=null;item=item.Inv)if(item is 'CaelumEquipmentItem')count++;
            Check(count==12,"respawn has one initial equipment set");
            second.DamageMobj(second,second,10000000,'None',DMG_FORCED|DMG_NO_ARMOR,0);
            Check(match.Score[1]==-1 && match.Score[0]==1,"suicide subtracts one from its author");
        }
        if(level.time==520)
        {
            // Condición de frontera, sin esperar diez minutos para cada ensayo.
            match.Score[0]=match.Score[1]=2;match.Elapsed=CaelumStandaloneData.TIME_LIMIT_TICS;
            match.Evaluate();Check(!match.Finished,"time limit tie enters overtime");
            second.DamageMobj(first,first,10000000,'None',DMG_FORCED|DMG_NO_ARMOR,0);
        }
        if(level.time==522)
        {
            Check(match.Finished && match.Winner==0 && match.Score[0]==3,"next lead resolves overtime");
            int hp=first.health;first.DamageMobj(second,second,10000000,'None',DMG_FORCED|DMG_NO_ARMOR,0);
            Check(first.health==hp,"finished match rejects later damage");
            match.RecordDeath(first,second);Check(match.Score[1]==2,"finished match rejects late scoring");
            match.VoteRematch(0);Check(match.RematchVotes==1,"one vote cannot restart for everyone");
        }
        if(level.time==560){RematchRequested=true;match.VoteRematch(1);}
    }
}
