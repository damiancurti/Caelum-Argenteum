// Actual seat transactions and production network events; isolated native saves.
class CA590NetworkProbe : EventHandler
{
    const MAGIC = 0;
    int Phase,Stamp,SerialBefore,ClockBefore,UsedBefore;
    bool Reloaded,Complete;
    ui int SentPhase;
    ui bool Saved;
    CaelumPortableSmallTable Table;
    CaelumCardDuel Duel;
    String HandBefore;
    void Check(bool okay,String label){Console.Printf("CA590 %s %s",okay?"PASS":"FAIL",label);}
    String HandState()
    {
        if(MAGIC)
        {
        let m=Duel.Trucazo;
        String s=String.Format("%d/%d/%d/%d/%d/%d",m.HandNumber,m.Turn,m.Phase,m.Sides[0].Health,m.Sides[1].Health,m.Drawn);
        for(int side=0;side<2;side++)for(int i=0;i<int(m.Sides[side].Hand.Size());i++)
            s=s..String.Format("/%d:%d",m.Sides[side].Hand[i],int(m.Sides[side].Used[i]));
        for(int i=0;i<int(m.Deck.Size());i++)s=s..String.Format("/%d",m.Deck[i]);
        return s;
        }
        let m=Duel.Truco;
        String s=String.Format("%d/%d/%d/%d/%d/%d",m.HandNumber,m.Turn,m.Phase,m.Score[0],m.Score[1],m.Drawn);
        for(int side=0;side<2;side++)for(int i=0;i<int(m.Sides[side].Hand.Size());i++)
            s=s..String.Format("/%d:%d",m.Sides[side].Hand[i],int(m.Sides[side].Used[i]));
        for(int i=0;i<int(m.Deck.Size());i++)s=s..String.Format("/%d",m.Deck[i]);
        return s;
    }
    clearscope int Turn(){return MAGIC?Duel.Trucazo.Turn:Duel.Truco.Turn;}
    override void WorldLoaded(WorldEvent e){if(e.IsSaveGame)Reloaded=true;}
    override void NetworkProcess(ConsoleEvent e)
    {if(e.Name=="ca590_verify_reload" && e.Player==0)Reloaded=true;}
    override void UiTick()
    {
        if(gamestate!=GS_LEVEL || consoleplayer<0)return;
        let user=CaelumPlayer(players[consoleplayer].mo);if(user==null)return;
        if(!Reloaded && Phase==6 && consoleplayer==0 && !Saved)
        {Saved=true;SavegameManager.GetManager().DoSave(0,"CA590 active human hand");}
        if(Reloaded || SentPhase==Phase)return;
        let link=CaelumCardSeat.Read(user);if(link==null)return;
        if(Phase==10 && consoleplayer==0)
        {SentPhase=Phase;SendNetworkEvent("ca_card_table",CaelumCardDuel.SELECT_GAME,0,link.LastSerial);}
        else if(Phase==1 && consoleplayer==0)
        {SentPhase=Phase;SendNetworkEvent("ca_card_table",CaelumCardDuel.CONSENT,1,link.LastSerial);}
        else if(Phase==2 && consoleplayer==0)
        {SentPhase=Phase;SendNetworkEvent("ca_card_table",CaelumCardDuel.CONSENT,0,link.LastSerial);}
        else if(Phase==3 && consoleplayer==1)
        {SentPhase=Phase;SendNetworkEvent("ca_card_table",CaelumCardDuel.CONSENT,0,link.LastSerial);}
        else if(Phase==4 && Duel!=null && Turn()==Duel.Side(user))
        {SentPhase=Phase;SendNetworkEvent(MAGIC?"ca_trucazo":"ca_truco",CaelumTrucoRules.PLAY_CARD,0,Duel.Serial);}
    }
    override void WorldTick()
    {
        if(Complete || level.time<TICRATE*3)return;
        let a=CaelumPlayer(players[0].mo);let b=CaelumPlayer(players[1].mo);
        if(!CaelumWorldClockTicker.Ready(a) || !CaelumWorldClockTicker.Ready(b))return;
        if(Reloaded && Phase==6)
        {
            Check(CaelumCardSeat.Session(a)==Duel && CaelumCardSeat.Session(b)==Duel,"shared human session survives common restart");
            Check(Duel.Started && !Duel.Suspended && Duel.Serial==SerialBefore,"match revision and active status survive restart");
            Check(HandState()==HandBefore,"exact deck hands turn used cards and score survive restart");
            Check(CaelumCardSeat.Table(a)==Table && CaelumCardSeat.Table(b)==Table,"actual table and occupied seats survive restart");
            Check(CaelumRestState.IsActive(a) && CaelumRestState.IsActive(b),"both native rest sessions remain active");
            Check(!Duel.Dispatch(a,Duel.Game,CaelumTrucoRules.PLAY_CARD,0,SerialBefore-1),"pre-save replay cannot act after restart");
            int side=Turn();
            int operation=(MAGIC?Duel.Trucazo.Phase:Duel.Truco.Phase)==CaelumTrucoRules.PLAYING?CaelumTrucoRules.PLAY_CARD:CaelumTrucoRules.ADVANCE;
            Check(Duel.Dispatch(Duel.Participants[side],Duel.Game,operation,1,Duel.Serial),"next human turn remains playable after restart");
            CaelumRestState.Cancel(b);Duel.Tick();
            Check(MAGIC?(Duel.Trucazo.Abandoned && Duel.Trucazo.Winner==0):(Duel.Truco.Abandoned && Duel.Truco.Winner==0),"ordinary standing forfeits only the standing player");
            Check(CaelumRestState.IsActive(a) && !CaelumRestState.IsActive(b),"other occupant remains seated after forfeit");
            Complete=true;Console.Printf("CA590 RESULT peer=%d restored",consoleplayer);return;
        }
        if(Phase==0)
        {
            Table=CaelumPortableSmallTable(Actor.Spawn('CaelumPortableSmallTable',(0,512,0),NO_REPLACE));
            Check(Table!=null && Table.ConfigureParts(),"ordinary portable table builds its real chairs");
            if(Table==null || Table.Chairs[1]==null)return;
            for(int i=0;i<2;i++)
            {
                let user=CaelumPlayer(players[i].mo);let chair=Table.Chairs[i];
                user.SetOrigin(chair.Pos+(0,i==0?-48:48,0),false);user.Vel=(0,0,0);
                user.CurrentHunger=100;user.CurrentThirst=100;user.CurrentSleep=100;
                Check(CaelumRestState.Begin(user,CaelumRestRules.MODE_WAIT,60,chair),"ordinary sitting succeeds for native player");
                Check(CaelumCardSeat.Interact(user),"seated interaction opens participant picker");
            }
            Check(Table.Chairs[1].DiningSeat==1,"portable chair records distinct seat index");
            Table.Chairs[1].DiningSeat=0;
            Check(CaelumCardSeat.Table(b)==Table,"legacy portable chair index resolves by existing references");
            b.GiveInventoryType('CaelumTarotDeck');
            ClockBefore=CaelumWorldClock.Get(a).DayTics;Phase=1;Stamp=level.time;return;
        }
        if(Phase==1 && CaelumCardSeat.Session(a)!=null)
        {
            Duel=CaelumCardSeat.Session(a);
            Check(Duel==CaelumCardSeat.Session(b) && !Duel.Started,"native invitation opens shared unstarted lobby");
            Phase=MAGIC?10:2;return;
        }
        if(Phase==10 && Duel.Game==CaelumCardDuel.GAME_TRUCAZO){Phase=2;return;}
        if(Phase==2 && Duel.Accepted==1)
        {Check(!Duel.Started,"first native acceptance waits for the other player");Phase=3;return;}
        if(Phase==3 && Duel.Started)
        {
            Check((MAGIC?Duel.Trucazo!=null:Duel.Truco!=null) && Duel.Accepted==3,"second native acceptance starts the agreed human game");
            Check(a.FindInventory('CaelumTarotDeck')==null && b.FindInventory('CaelumTarotDeck').Amount==1,"guest deck is retained without transfer or consumption");
            SerialBefore=Duel.Serial;Phase=4;return;
        }
        if(Phase==4 && Duel.Serial>SerialBefore)
        {
            Check(MAGIC?(Duel.Trucazo.Sides[0].Used[0] || Duel.Trucazo.Sides[1].Used[0]):(Duel.Truco.Sides[0].Used[0] || Duel.Truco.Sides[1].Used[0]),"production action event plays one human card");
            Phase=5;Stamp=level.time;return;
        }
        if(Phase==5 && level.time>=Stamp+TICRATE*2)
        {
            Check(CaelumWorldClock.Get(a).DayTics>ClockBefore,"world clock advances with both card menus open");
            Check(CaelumWorldClock.Get(a).DayTics==CaelumWorldClock.Get(b).DayTics,"card players retain a shared clock");
            Check(CaelumRestState.IsActive(a) && CaelumRestState.IsActive(b),"actual seats persist through native menu tics");
            HandBefore=HandState();SerialBefore=Duel.Serial;Phase=6;
            Console.Printf("CA590 RESULT peer=%d fresh",consoleplayer);
        }
    }
}
