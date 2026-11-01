class CA598MatchProbe : StaticEventHandler
{
    bool Done,Checked;
    int Respawns;
    void Check(bool ok,String label){Console.Printf("CA598 %s %s",ok?"PASS":"FAIL",label);}
    override void PlayerRespawned(PlayerEvent e){Respawns++;}
    override void WorldTick()
    {
        let match=CaelumStandaloneMatch.View();if(Done || match==null || !match.Started)return;
        if(!Checked)
        {
            Checked=true;
            Check(match.Score[0]==1 && match.Score[1]==0 && match.Deaths[1]==1,"common save preserves in-progress score");
            Check(match.RespawnAt[1]==280 && !match.RespawnAllowed(1),"common save preserves remaining respawn deadline");
            Check(match.Elapsed>175 && match.Elapsed<250,"common save preserves elapsed active time");
            Check(match.Mode==1 && match.Members==3,"common save preserves authoritative mode and roster");
        }
        if(level.time==340)
        {
            let second=CaelumStandalonePlayer(players[1].mo);
            Check(Respawns==1 && second.health>0 && second.StandaloneRevision==1 && match.RespawnAt[1]==0,"recovered death respawns once at original deadline");
            Check(match.Score[0]==1 && match.Deaths[1]==1,"recovery does not score the same death twice");
            int count=0;for(Inventory item=second.Inv;item!=null;item=item.Inv)if(item is 'CaelumEquipmentItem')count++;
            Check(count==12,"recovered respawn grants one preset set");
            Console.Printf("CA598 RESULT deathmatch");Done=true;
        }
    }
}
