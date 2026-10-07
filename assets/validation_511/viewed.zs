class CA131Viewed : StaticEventHandler
{
    bool Tested;
    override void WorldTick()
    {
        let user=CaelumPlayer(players[0].mo);if(user==null)return;
        if(level.time==1){user.InitializeDirectMapCharacter();user.PersistCharacterState();}
        if(level.time<100 || Tested || !playeringame[1])return;
        let other=CaelumPlayer(players[1].mo);if(other==null)return;
        other.InitializeDirectMapCharacter();other.PersistCharacterState();
        let localState=CaelumThermalBody.Get(user,true);let otherState=CaelumThermalBody.Get(other,true);
        localState.Exposure=12;otherState.Exposure=-22;
        let saved=players[0].camera;
        players[0].camera=other;
        bool correct=CaelumThermalHUD.ViewedPlayer(0)==other && localState!=otherState;
        players[0].camera=Actor.Spawn("MapSpot",(0,0,0),NO_REPLACE);
        bool fallback=CaelumThermalHUD.ViewedPlayer(0)==user;
        players[0].camera=saved;
        bool preserved=localState.Exposure==12 && otherState.Exposure==-22;
        Console.Printf("CA131 %s viewed player, cinematic fallback and read-only ownership",correct && fallback && preserved ? "PASS" : "FAIL");
        Console.Printf("CA131 VIEW COMPLETE");Tested=true;
    }
}
