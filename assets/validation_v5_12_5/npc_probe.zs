// Regression of the unchanged single-player Argento dispatcher.
class CA590NetworkProbe : EventHandler
{
    bool Complete;
    CaelumArgento Opponent;
    void Check(bool okay,String label){Console.Printf("CA590 %s %s",okay?"PASS":"FAIL",label);}
    override void WorldTick()
    {
        if(Complete || level.time<TICRATE*3)return;
        let user=CaelumPlayer(players[0].mo);
        if(!CaelumWorldClockTicker.Ready(user))return;
        if(Opponent==null)
        {
            Opponent=CaelumArgento(Actor.Spawn('CaelumArgento',(512,512,0),NO_REPLACE));
            return; // Let the native PostBeginPlay initialize the combat profile.
        }
        Complete=true;
        let npc=Opponent;
        npc.StoryAnchored=true;user.GiveInventoryType('CaelumTarotDeck');
        int health=user.health;
        {
            let match=CaelumTrucoMatch.Get(user,true);match.Opponent=npc;match.Visible=true;
            Check(match.Duel==null && match.ContextValid(),"Truco retains the single-player Argento context");
            match.Dispatch(CaelumTrucoRules.BEGIN,0,match.Serial);
            Check(match.Active(),"Truco starts through the legacy dispatcher");
            int before=match.Serial;
            match.Dispatch(CaelumTrucoRules.FORFEIT,0,before-1);
            Check(match.Active() && match.Serial==before,"Truco rejects stale legacy request");
            int steps=0,npcSteps=0;
            while(match.Active() && steps<1500)
            {
                steps++;int operation=CaelumTrucoRules.PLAY_CARD,index=0;
                if(match.Phase!=CaelumTrucoRules.PLAYING)operation=CaelumTrucoRules.ADVANCE;
                else if((match.Pending!=0 && match.Caller==0) || (match.Pending==0 && match.Turn==1))
                {operation=CaelumTrucoRules.NPC_STEP;npcSteps++;}
                else if(match.Pending!=0)operation=CaelumTrucoRules.ACCEPT;
                else if(match.CanTruco(0))operation=CaelumTrucoRules.TRUCO;
                else while(index<int(match.Sides[0].Hand.Size()) && match.Sides[0].Used[index])index++;
                match.Dispatch(operation,index,match.Serial);
            }
            Check(!match.Active() && !match.Abandoned && npcSteps>0,"Truco completes with real NPC decisions");
            match.Dispatch(CaelumTrucoRules.CLOSE,0,match.Serial);
            Check(!match.Visible && match.Duel==null,"Truco closes without creating a human session");
        }
        {
            let match=CaelumTrucazoMatch.Get(user,true);match.Opponent=npc;match.Visible=true;
            Check(match.Duel==null && match.ContextValid(),"Trucazo retains the single-player Argento context");
            match.Dispatch(CaelumTrucazoRules.BEGIN,0,match.Serial);
            Console.Printf("CA590 DIAG playerPatience=%f npcPatience=%f phase=%d hand=%d",user.Attributes.Patience,npc.CombatPatience,match.Phase,match.HandNumber);
            Check(match.Active(),"Trucazo starts through the legacy dispatcher");
            int before=match.Serial;
            match.Dispatch(CaelumTrucazoRules.FORFEIT,0,before-1);
            Check(match.Active() && match.Serial==before,"Trucazo rejects stale legacy request");
            int steps=0,npcSteps=0;
            while(match.Active() && steps<1500)
            {
                steps++;int operation=CaelumTrucazoRules.PLAY_CARD,index=0;
                if(match.Phase!=CaelumTrucazoRules.PLAYING)operation=CaelumTrucazoRules.ADVANCE;
                else if((match.Pending!=0 && match.Caller==0) || (match.Pending==0 && match.Turn==1))
                {operation=CaelumTrucazoRules.NPC_STEP;npcSteps++;}
                else if(match.Pending!=0)operation=CaelumTrucazoRules.ACCEPT;
                else if(match.CanTruco(0))operation=CaelumTrucazoRules.TRUCO;
                else while(index<int(match.Sides[0].Hand.Size()) && match.Sides[0].Used[index])index++;
                match.Dispatch(operation,index,match.Serial);
            }
            Check(!match.Active() && !match.Abandoned && npcSteps>0,"Trucazo completes with real NPC decisions");
            match.Dispatch(CaelumTrucazoRules.CLOSE,0,match.Serial);
            Check(!match.Visible && match.Duel==null,"Trucazo closes without creating a human session");
        }
        Check(user.health==health,"neither legacy card game changes world health");
        Check(CaelumCardSeat.Read(user)==null,"legacy games do not require a human seat link");
        Console.Printf("CA590 RESULT peer=0 npc");
    }
}
