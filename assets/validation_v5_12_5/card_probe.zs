// Isolated rules/ownership tests. Seat state is a fixture, not #436 acceptance.
class CA590NetworkProbe : EventHandler
{
    int Received[MAXPLAYERS];
    int TotalRequests;
    bool Complete;
    ui bool Sent;
    CaelumDiningTable Table;
    CaelumRestChair Chairs[2];

    void Check(bool okay,String label)
    {Console.Printf("CA590 %s %s",okay?"PASS":"FAIL",label);}
    void Seats()
    {
        Table=CaelumDiningTable(Actor.Spawn("CaelumDiningTableSmall",(0,512,0),NO_REPLACE));
        for(int i=0;i<2;i++)
        {
            let user=CaelumPlayer(players[i].mo);
            Chairs[i]=CaelumRestChair(Actor.Spawn("CaelumRestChair",(i*128,640,0),NO_REPLACE));
            Table.Chairs[i]=Chairs[i];Chairs[i].DiningTable=Table;Chairs[i].DiningSeat=i;Chairs[i].Occupant=user;
            let rest=CaelumRestState.Get(user,true);
            rest.Status=CaelumRestRules.STATUS_ACTIVE;rest.Mode=CaelumRestRules.MODE_WAIT;rest.Furniture=Chairs[i];
            CaelumCardSeat.Get(user);
        }
    }
    void Rules()
    {
        let a=CaelumPlayer(players[0].mo);let b=CaelumPlayer(players[1].mo);
        if(a==null || b==null){Check(false,"both native peers still connected");return;}
        Seats();
        let own=CaelumCardSeat.Read(a);let guest=CaelumCardSeat.Read(b);
        Check(CaelumCardSeat.Table(a)==Table && CaelumCardSeat.Table(b)==Table,"same table identity");
        Chairs[1].Occupant=null;
        Check(!CaelumCardDuel.Invite(a,b,own.LastSerial),"unseated invite rejected");
        Chairs[1].Occupant=b;
        Chairs[1].DiningTable=null;
        Check(!CaelumCardDuel.Invite(a,b,own.LastSerial),"unrelated chair rejected");
        let otherTable=CaelumDiningTable(Actor.Spawn("CaelumDiningTableSmall",(512,512,0),NO_REPLACE));
        Chairs[1].DiningTable=otherTable;otherTable.Chairs[1]=Chairs[1];
        Check(!CaelumCardDuel.Invite(a,b,own.LastSerial),"different occupied tables rejected");
        otherTable.Chairs[1]=null;otherTable.Destroy();Chairs[1].DiningTable=Table;
        int before=own.LastSerial;
        Check(CaelumCardDuel.Invite(a,b,before),"two seated players invite");
        let duel=own.Duel;
        Check(duel!=null && guest.Duel==duel,"one shared session");
        if(duel==null)return;
        Check(!CaelumCardDuel.Invite(a,b,before),"duplicate invite rejected");
        int serial=duel.Serial;
        Check(!duel.Lobby(b,CaelumCardDuel.SELECT_GAME,serial),"guest cannot change agreed offer");
        Check(duel.Lobby(a,CaelumCardDuel.CONSENT,serial) && !duel.Started,"first consent does not start");
        Check(!duel.Lobby(b,CaelumCardDuel.CONSENT,serial),"stale consent rejected");
        Check(duel.Lobby(b,CaelumCardDuel.CONSENT,duel.Serial) && !duel.Started,"no deck cannot start");
        b.GiveInventoryType("CaelumTarotDeck");
        duel.Lobby(a,CaelumCardDuel.CONSENT,duel.Serial);
        duel.Lobby(a,CaelumCardDuel.SELECT_FLOR,duel.Serial);
        Check(duel.Accepted==0 && duel.Flor,"option change clears consent");
        duel.Lobby(a,CaelumCardDuel.SELECT_FLOR,duel.Serial);
        duel.Lobby(a,CaelumCardDuel.CONSENT,duel.Serial);
        duel.Lobby(b,CaelumCardDuel.CONSENT,duel.Serial);
        Check(duel.Started && duel.Truco!=null,"guest deck starts shared Truco");
        let match=duel.Truco;
        if(match==null)return;
        Check(CaelumTrucoMatch.View(a)==match && CaelumTrucoMatch.View(b)==match,"both views resolve shared match");
        Check(match.Sides[0].Hand.Size()==3 && match.Sides[1].Hand.Size()==3,"three private cards each");
        serial=duel.Serial;
        Check(!duel.Dispatch(a,CaelumCardDuel.GAME_TRUCAZO,CaelumTrucoRules.PLAY_CARD,0,serial),"wrong game rejected");
        Check(!duel.Dispatch(a,CaelumCardDuel.GAME_TRUCO,CaelumTrucoRules.NPC_STEP,0,serial),"NPC action disabled in PvP");
        int side=match.Turn;
        Check(!duel.Dispatch(duel.Participants[1-side],CaelumCardDuel.GAME_TRUCO,CaelumTrucoRules.PLAY_CARD,0,serial),"wrong turn rejected");
        Check(duel.Dispatch(duel.Participants[side],CaelumCardDuel.GAME_TRUCO,CaelumTrucoRules.PLAY_CARD,0,serial),"current human plays");
        Check(!duel.Dispatch(duel.Participants[side],CaelumCardDuel.GAME_TRUCO,CaelumTrucoRules.PLAY_CARD,0,serial),"replayed card rejected");
        int steps=0;
        while(match.Active() && steps<1500)
        {
            steps++;
            int actorSide=match.Pending!=0?1-match.Caller:match.Turn;
            int operation=CaelumTrucoRules.PLAY_CARD,index=0;
            if(match.Phase!=CaelumTrucoRules.PLAYING){actorSide=steps%2;operation=CaelumTrucoRules.ADVANCE;}
            else if(match.Pending!=0)operation=CaelumTrucoRules.ACCEPT;
            else
                while(index<int(match.Sides[actorSide].Hand.Size()) && match.Sides[actorSide].Used[index])index++;
            if(!duel.Dispatch(duel.Participants[actorSide],CaelumCardDuel.GAME_TRUCO,operation,index,duel.Serial))break;
        }
        Check(!match.Active() && (match.Score[0]>=30 || match.Score[1]>=30),"human Truco reaches thirty points");
        match.Start();duel.AdvanceSerial();
        serial=duel.Serial;
        Check(duel.Dispatch(b,CaelumCardDuel.GAME_TRUCO,CaelumTrucoRules.FORFEIT,0,serial)
            && match.Winner==0 && match.Abandoned,"guest forfeit selects host winner");
        duel.Dispatch(b,CaelumCardDuel.GAME_TRUCO,CaelumTrucoRules.CLOSE,0,duel.Serial);
        Check(!guest.Open && own.Open && CaelumTrucoMatch.View(b)==null,"closing result affects only own view");
        duel.Dispatch(a,CaelumCardDuel.GAME_TRUCO,CaelumTrucoRules.CLOSE,0,duel.Serial);
        Check(own.Duel==null && guest.Duel==null,"both close releases session");
        Check(!CaelumCardDuel.Invite(a,b,before),"old invitation cannot reopen newer session");
        CaelumCardDuel.Invite(a,b,own.LastSerial);duel=own.Duel;
        duel.Lobby(a,CaelumCardDuel.SELECT_GAME,duel.Serial);
        duel.Lobby(a,CaelumCardDuel.CONSENT,duel.Serial);
        duel.Lobby(b,CaelumCardDuel.CONSENT,duel.Serial);
        let magic=duel.Trucazo;
        Check(magic!=null && magic.Sides[1].MaximumHealth==CaelumTrucazoRules.Health(b.Attributes.Patience),"Trucazo uses guest Patience");
        if(playeringame[2])Check(!duel.Dispatch(CaelumPlayer(players[2].mo),CaelumCardDuel.GAME_TRUCAZO,
            CaelumTrucazoRules.FORFEIT,0,duel.Serial),"nonparticipant cannot act");
        steps=0;
        while(magic.Active() && steps<1500)
        {
            steps++;
            int actorSide=magic.Pending!=0?1-magic.Caller:magic.Turn;
            int operation=CaelumTrucazoRules.PLAY_CARD,index=0;
            if(magic.Phase!=CaelumTrucazoRules.PLAYING){actorSide=steps%2;operation=CaelumTrucazoRules.ADVANCE;}
            else if(magic.Pending!=0)operation=CaelumTrucazoRules.ACCEPT;
            else if(magic.CanTruco(actorSide))operation=CaelumTrucazoRules.TRUCO;
            else while(index<int(magic.Sides[actorSide].Hand.Size()) && magic.Sides[actorSide].Used[index])index++;
            if(!duel.Dispatch(duel.Participants[actorSide],CaelumCardDuel.GAME_TRUCAZO,operation,index,duel.Serial))break;
        }
        Check(!magic.Active() && (magic.Sides[0].Health<=0 || magic.Sides[1].Health<=0),"human Trucazo reaches match KO");
        magic.Start();duel.AdvanceSerial();
        int hpA=a.health,hpB=b.health;
        magic.Sides[0].Points=100;magic.Sides[1].Points=100;
        magic.FinishHand(0,100);
        Check(a.health==hpA && b.health==hpB,"card damage never changes world health");
        if(!magic.Active())magic.Start();
        duel.Participants[1]=null;duel.Tick();duel.Participants[1]=b;
        Check(duel.Suspended && magic.Active() && !magic.Abandoned,"missing participant suspends without defeat");
        Check(!duel.Dispatch(a,CaelumCardDuel.GAME_TRUCAZO,CaelumTrucazoRules.FORFEIT,0,duel.Serial),"suspended match cannot be forfeited");
        Check(duel.Dispatch(b,CaelumCardDuel.GAME_TRUCAZO,CaelumTrucazoRules.CLOSE,0,duel.Serial)
            && !guest.Open && own.Open,"interrupted guest can close own UI");
        duel.Suspended=false;guest.Open=true; // Fixture resumes for the independent stand-up check.
        Chairs[1].Occupant=null;duel.Tick();
        Check(magic.Abandoned && magic.Winner==0,"standing guest forfeits");
        duel.Release();Chairs[1].Occupant=b;
        // The fixture restores the original rest state before the normal tick.
        for(int i=0;i<2;i++)
        {
            let rest=CaelumRestState.Get(CaelumPlayer(players[i].mo));rest.Status=0;rest.Furniture=null;
            Chairs[i].Occupant=null;Chairs[i].Destroy();
        }
        Table.Destroy();
    }
    override void UiTick()
    {
        if(gamestate!=GS_LEVEL || consoleplayer<0)return;
        if(!Sent && level.time>=TICRATE && players[consoleplayer].mo)
        {Sent=true;SendNetworkEvent("ca590_native_probe",consoleplayer,590,1);}
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!="ca590_native_probe")return;
        Received[e.Player]++;TotalRequests++;
        Console.Printf("CA590 EVENT peer=%d sender=%d serial=%d",consoleplayer,e.Player,TotalRequests);
    }
    override void WorldTick()
    {
        if(Complete || level.time<TICRATE*3)return;
        for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i] && Received[i]==0)return;
        Complete=true;Rules();Console.Printf("CA590 RESULT peer=%d requests=%d",consoleplayer,TotalRequests);
    }
}
