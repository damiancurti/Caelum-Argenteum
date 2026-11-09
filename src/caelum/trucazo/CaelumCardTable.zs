// #590: la mesa y sus sillas son la identidad espacial; no se buscan actores globalmente.
class CaelumCardSeat : Inventory
{
    CaelumCardDuel Duel;
    bool Open;
    int LastSerial;

    static clearscope CaelumCardSeat Read(CaelumPlayer user)
    { return user==null?null:CaelumCardSeat(user.FindInventory("CaelumCardSeat")); }
    static CaelumCardSeat Get(CaelumPlayer user)
    {
        let link=Read(user);
        if(link==null && CaelumPlayerAuthority.CanMutate(user))
        {
            link=CaelumCardSeat(Actor.Spawn("CaelumCardSeat",user.Pos,NO_REPLACE));
            if(link!=null)link.AttachToOwner(user);
        }
        return link;
    }
    static clearscope CaelumCardDuel Session(CaelumPlayer user)
    { let link=Read(user);return link==null?null:link.Duel; }
    static clearscope CaelumDiningTable Table(CaelumPlayer user)
    {
        // La UI puede consultar durante predicción; no modifica el asiento.
        if(!CaelumPlayerAuthority.CanRead(user) || user.ProfileDeparted
            || user.SessionIdentityPending || user.health<=0)return null;
        let rest=user==null?null:CaelumRestState(user.FindInventory("CaelumRestState"));
        if(rest==null || rest.Status!=CaelumRestRules.STATUS_ACTIVE
            || rest.Mode!=CaelumRestRules.MODE_WAIT)return null;
        let chair=CaelumRestChair(rest.Furniture);
        if(chair==null || chair.Occupant!=user || chair.DiningTable==null)return null;
        let table=chair.DiningTable;
        int seat=chair.DiningSeat;
        if(seat>=0 && seat<table.SeatCount() && table.Chairs[seat]==chair)return table;
        // Las mesas transportables anteriores no guardaban el índice de plaza.
        // Validar sus referencias reales conserva esos saves sin crear sillas.
        for(int i=0;i<table.SeatCount();i++)if(table.Chairs[i]==chair)return table;
        return null;
    }
    // Usar sentado abre la interacción con las otras plazas de esa mesa.
    static bool Interact(CaelumPlayer user)
    {
        if(!multiplayer || !CaelumPlayerAuthority.CanMutate(user) || Table(user)==null)return false;
        let link=Get(user);
        if(link==null)return false;
        link.Open=true;
        return true;
    }
    Default
    {
        Inventory.MaxAmount 1;
        Inventory.InterHubAmount 1;
        +INVENTORY.UNDROPPABLE
        -INVENTORY.INVBAR
    }
}

class CaelumCardDuel : Inventory
{
    enum LobbyAction { SELECT_GAME, SELECT_FLOR, CONSENT, CANCEL, SELECT_MAJORS, SELECT_SENSES, SELECT_MAJOR, SELECT_TEAM_SIZE, SELECT_CONSEQUENCES };
    enum GameKind { GAME_TRUCO, GAME_TRUCAZO };
    CaelumPlayer Participants[2];
    // Las referencias originales se conservan para guardados y partidas previas.
    Array<CaelumPlayer> Roster;
    Array<int> RosterSlots;
    Array<String> RosterProfiles;
    int RosterRevision,PauseVotes,ResumeVotes;
    bool TeamMode,Paused;
    bool Consequences;
    CaelumTrucazoWagers Wagers;
    CaelumDiningTable Table;
    CaelumTrucoMatch Truco;
    CaelumTrucazoMatch Trucazo;
    int Game;
    bool Flor;
    bool Majors,Senses;
    CaelumTrucazoGame Advanced;
    clearscope int Count() const {return Roster.Size()>=2?int(Roster.Size()):2;}
    clearscope CaelumPlayer Member(int seat) const {return seat<0 || seat>=Count()?null:Roster.Size()>=2?Roster[seat]:Participants[seat];}
    clearscope int FullMask() const {return (1<<Count())-1;}
    clearscope int MemberSlot(int seat) const
    {return seat>=0 && seat<int(RosterSlots.Size())?RosterSlots[seat]:Member(seat)!=null?Member(seat).PlayerNumber():-1;}
    void EnsureRoster()
    {
        if(RosterRevision==0){if(Roster.Size()==0){Roster.Push(Participants[0]);Roster.Push(Participants[1]);}RosterRevision=CaelumTrucazoData.ROSTER_REVISION;}
        if(RosterSlots.Size()!=Roster.Size())
        {
            RosterSlots.Clear();RosterProfiles.Clear();
            for(int i=0;i<int(Roster.Size());i++)
            {
                let user=Roster[i];let record=user==null?null:user.GetPersistentCharacterState(false);
                RosterSlots.Push(user==null?-1:user.PlayerNumber());RosterProfiles.Push(record==null?"":record.ExternalProfileId);
            }
        }
    }
    int Accepted;
    int Serial;
    bool Started;
    bool Suspended;

    clearscope int Side(CaelumPlayer user) const
    {if(user!=null)for(int i=0;i<Count();i++)if(user==Member(i))return i;return -1;}
    clearscope bool Finished() const
    { return Started && (Advanced!=null?Advanced.Finished():Game==GAME_TRUCO?Truco!=null && !Truco.Active():Trucazo!=null && !Trucazo.Active()); }
    clearscope bool Connected() const
    {
        for(int i=0;i<Count();i++)
        {
            let user=Member(i);
            if(user==null || user.player==null)return false;
            int number=user.PlayerNumber();
            if(number<0 || number>=MAXPLAYERS || !playeringame[number] || players[number].mo!=user)return false;
            if(RosterSlots.Size()>0 && (number!=RosterSlots[i] || user.ProfileDeparted))return false;
            if(i<int(RosterProfiles.Size()) && RosterProfiles[i]!="")
            {let record=CaelumPersistentCharacterState(user.FindInventory('CaelumPersistentCharacterState'));if(record==null || record.ExternalProfileId!=RosterProfiles[i])return false;}
        }
        return true;
    }
    clearscope bool Seated(int side) const
    { return Table!=null && CaelumCardSeat.Table(Member(side))==Table; }
    clearscope bool AllSeated() const
    {for(int i=0;i<Count();i++)if(!Seated(i))return false;return true;}
    clearscope bool AllClosed() const
    {for(int i=0;i<Count();i++){let link=CaelumCardSeat.Read(Member(i));if(link!=null && link.Open)return false;}return true;}
    clearscope bool Candidate(CaelumPlayer user) const
    {
        if(user==null || user.player==null || !playeringame[user.PlayerNumber()] || CaelumCardSeat.Table(user)!=Table)return false;
        let session=CaelumCardSeat.Session(user);if(session!=null && session!=self)return false;
        let a=CaelumTrucoMatch(user.FindInventory('CaelumTrucoMatch'));let b=CaelumTrucazoMatch(user.FindInventory('CaelumTrucazoMatch'));
        return (a==null || !a.Active()) && (b==null || !b.Active());
    }
    clearscope int Available() const
    {int n=0;for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i] && Candidate(CaelumPlayer(players[i].mo)))n++;return n;}
    bool SetTeamSize(int count)
    {
        if(Started || Game!=GAME_TRUCAZO || count<2 || count>CaelumTrucazoData.MAX_SEATS || count%2!=0 || count>Available())return false;
        Array<CaelumPlayer> chosen;chosen.Push(Participants[0]);chosen.Push(Participants[1]);
        for(int i=0;i<MAXPLAYERS && int(chosen.Size())<count;i++)if(playeringame[i])
        {let user=CaelumPlayer(players[i].mo);if(user!=Participants[0] && user!=Participants[1] && Candidate(user))chosen.Push(user);}
        if(int(chosen.Size())!=count)return false;
        for(int i=0;i<Count();i++)
        {let link=CaelumCardSeat.Read(Member(i));if(link!=null && link.Duel==self){link.LastSerial=Max(link.LastSerial,Serial)+1;link.Duel=null;link.Open=false;}}
        Roster.Copy(chosen);RosterSlots.Clear();RosterProfiles.Clear();RosterRevision=CaelumTrucazoData.ROSTER_REVISION;EnsureRoster();TeamMode=true;Accepted=0;
        if(Wagers!=null)Wagers=CaelumTrucazoWagers.Create(self);
        for(int i=0;i<Count();i++){let link=CaelumCardSeat.Get(Member(i));Serial=Max(Serial,link.LastSerial);link.Duel=self;link.Open=true;}
        return true;
    }
    bool VotePause(int side)
    {
        if(!Started || Advanced==null || Finished() || !Connected() || !AllSeated())return false;
        if(Paused || Suspended)
        {ResumeVotes^=1<<side;if(ResumeVotes==FullMask()){Paused=false;Suspended=false;ResumeVotes=0;PauseVotes=0;}}
        else
        {PauseVotes^=1<<side;if(PauseVotes==FullMask()){Paused=true;PauseVotes=0;ResumeVotes=0;}}
        AdvanceSerial();return true;
    }
    static bool Invite(CaelumPlayer user,CaelumPlayer other,int expectedSerial)
    {
        if(user==other || !multiplayer || !CaelumPlayerAuthority.CanMutate(other))return false;
        let own=CaelumCardSeat.Get(user);let guest=CaelumCardSeat.Get(other);
        let table=CaelumCardSeat.Table(user);
        if(own==null || guest==null || own.LastSerial!=expectedSerial || own.Duel!=null || guest.Duel!=null
            || table==null || CaelumCardSeat.Table(other)!=table)return false;
        let a=CaelumTrucoMatch.Get(user);let b=CaelumTrucazoMatch.Get(user);
        let c=CaelumTrucoMatch.Get(other);let d=CaelumTrucazoMatch.Get(other);
        if((a!=null && a.Active()) || (b!=null && b.Active())
            || (c!=null && c.Active()) || (d!=null && d.Active()))return false;
        let duel=CaelumCardDuel(Actor.Spawn("CaelumCardDuel",user.Pos,NO_REPLACE));
        if(duel==null)return false;
        duel.AttachToOwner(user);duel.Participants[0]=user;duel.Participants[1]=other;
        duel.Table=table;duel.Serial=Max(own.LastSerial,guest.LastSerial);
        own.Duel=duel;guest.Duel=duel;own.Open=true;guest.Open=true;duel.AdvanceSerial();
        return true;
    }
    void AdvanceSerial()
    {
        Serial++;
        for(int i=0;i<Count();i++)
        {
            let link=CaelumCardSeat.Read(Member(i));
            if(link!=null && link.Duel==self)link.LastSerial=Serial;
        }
        if(Truco!=null)Truco.Serial=Serial;
        if(Trucazo!=null)Trucazo.Serial=Serial;
        if(Advanced!=null)Advanced.Serial=Serial;
    }
    void Release()
    {
        if(Wagers!=null && Wagers.Reserved && !Wagers.Settled)return;
        AdvanceSerial();
        for(int i=0;i<Count();i++)
        {
            let link=CaelumCardSeat.Read(Member(i));
            if(link!=null && link.Duel==self){link.Duel=null;link.Open=false;}
        }
        if(Truco!=null){Truco.Visible=false;Truco.Duel=null;}
        if(Trucazo!=null){Trucazo.Visible=false;Trucazo.Duel=null;}
        Destroy();
    }
    bool Lobby(CaelumPlayer user,int operation,int expectedSerial,int argument=0)
    {
        int side=Side(user);
        if(side<0 || Started || expectedSerial!=Serial || !Connected() || Suspended)return false;
        if(operation==CANCEL){Release();return true;}
        if(!AllSeated()){Release();return false;}
        if(operation==SELECT_TEAM_SIZE && side==0){if(!SetTeamSize(argument))return false;}
        else if(operation==SELECT_GAME && side==0 && Count()==2){Game=1-Game;TeamMode=false;Consequences=false;Wagers=null;Accepted=0;}
        else if(operation==SELECT_CONSEQUENCES && side==0 && Game==GAME_TRUCAZO)
        {Consequences=!Consequences;if(Consequences && Wagers==null)Wagers=CaelumTrucazoWagers.Create(self);Accepted=0;}
        else if(operation==SELECT_FLOR && side==0 && Game==GAME_TRUCO){Flor=!Flor;Accepted=0;}
        else if(operation==SELECT_MAJORS && side==0 && Game==GAME_TRUCAZO){Majors=!Majors;Accepted=0;}
        else if(operation==SELECT_SENSES && side==0 && Game==GAME_TRUCAZO){Senses=!Senses;Accepted=0;}
        else if(operation==SELECT_MAJOR && Game==GAME_TRUCAZO)
        {let choice=CaelumTrucazoChoice.Get(user);if(choice==null || !choice.Toggle(user,argument))return false;Accepted=0;}
        else if(operation==CONSENT)
        {
            if((Accepted & (1<<side))!=0)return false;
            Accepted|=1<<side;
            if(Accepted==FullMask())
            {
                bool deck=false;for(int i=0;i<Count();i++)if(CaelumTarotService.HasPhysicalDeck(Member(i)))deck=true;
                if(!deck)
                {
                    Accepted=0;
                    for(int i=0;i<Count();i++)CaelumTarotService.Feedback(Member(i),"CA_TC_NEED_DECK");
                }
                else if(!Start()){Accepted=0;for(int i=0;i<Count();i++)CaelumTarotService.Feedback(Member(i),"CA_TC3_CHANGED");}
            }
        }
        else return false;
        AdvanceSerial();return true;
    }
    bool Start()
    {
        if(Consequences && (Wagers==null || !Wagers.Reserve()))return false;
        if(Game==GAME_TRUCO)
        {
            Truco=CaelumTrucoMatch.Get(Participants[0],true);
            Truco.Duel=self;Truco.Opponent=null;Truco.WithFlor=Flor;Truco.Visible=true;Truco.Start();
        }
        else if(Consequences || TeamMode || Majors || Senses){EnsureRoster();Advanced=CaelumTrucazoGame.Create(self);}
        else
        {
            Trucazo=CaelumTrucazoMatch.Get(Participants[0],true);
            Trucazo.Duel=self;Trucazo.Opponent=null;Trucazo.Visible=true;Trucazo.Start();
        }
        Started=true;return true;
    }
    bool WagerRequest(CaelumPlayer user,int operation,int argument,int expectedSerial,int quantity=0)
    {
        int side=Side(user);let link=CaelumCardSeat.Read(user);
        if(side<0 || link==null || !link.Open || link.Duel!=self || Started || !Consequences || Wagers==null
            || expectedSerial!=Serial || Suspended || !Connected() || !AllSeated())return false;
        bool changed=Wagers.Edit(side,operation,argument,quantity);
        if(changed && operation!=CaelumTrucazoWagers.REFRESH)Accepted=0;
        let view=CaelumTrucazoWagerView.Refresh(user);if(view!=null)view.Status=changed?"":"CA_TC3_CHANGED";
        AdvanceSerial();return changed;
    }
    bool Dispatch(CaelumPlayer user,int requestedGame,int operation,int index,int expectedSerial)
    {
        int side=Side(user);
        if(side<0 || !Started || Advanced!=null || requestedGame!=Game || expectedSerial!=Serial)return false;
        if(!Connected())Suspended=true;
        let link=CaelumCardSeat.Read(user);
        if(link==null || !link.Open || link.Duel!=self)return false;
        if(Suspended)
        {
            if(operation!=CaelumTrucazoRules.CLOSE)return false;
            link.Open=false;AdvanceSerial();return true;
        }
        if(operation==CaelumTrucazoRules.CLOSE && Finished())
        {
            link.Open=false;AdvanceSerial();
            if(!CaelumCardSeat.Read(Participants[1-side]).Open)Release();
            return true;
        }
        if(!Seated(0) || !Seated(1))return false;
        if(operation==CaelumTrucazoRules.NPC_STEP || operation==CaelumTrucazoRules.BEGIN
            || operation==CaelumTrucoRules.TOGGLE_FLOR)return false;
        bool changed=Game==GAME_TRUCO?Truco.Act(side,operation,index):Trucazo.Act(side,operation,index);
        if(changed)AdvanceSerial();
        return changed;
    }
    bool DispatchAdvanced(CaelumPlayer user,int operation,int argument,int expectedSerial)
    {
        int side=Side(user);let link=CaelumCardSeat.Read(user);
        if(side<0 || Advanced==null || !Started || expectedSerial!=Serial || link==null || link.Duel!=self || !link.Open)return false;
        if(!Connected())Suspended=true;
        if(operation==CaelumTrucazoGame.PAUSE_VOTE)return VotePause(side);
        if(operation==CaelumTrucazoRules.CLOSE && (Suspended || Paused || Finished()))
        {
            link.Open=false;AdvanceSerial();
            if(Finished() && AllClosed())Release();return true;
        }
        if(Suspended || Paused || !AllSeated())return false;
        bool changed=Advanced.Act(side,operation,argument);if(changed){if(Wagers!=null)Wagers.Settle();AdvanceSerial();}return changed;
    }
    override void Tick()
    {
        Super.Tick();
        if(Advanced!=null)EnsureRoster();
        if(Wagers!=null)Wagers.Settle();
        // La desconexión conserva la mano para recuperación común, no es una derrota.
        if(!Connected()){if(!Started)Release();else if(!Suspended){Suspended=true;ResumeVotes=0;AdvanceSerial();}return;}
        if(Suspended || Finished())return;
        for(int side=0;side<Count();side++)if(!Seated(side))
        {
            if(!Started){Release();return;}
            if(Advanced!=null){Suspended=true;ResumeVotes=0;}
            else if(Game==GAME_TRUCO)Truco.Act(side,CaelumTrucoRules.FORFEIT);
            else Trucazo.Act(side,CaelumTrucazoRules.FORFEIT);
            AdvanceSerial();return;
        }
    }
    Default
    {
        Inventory.MaxAmount 1;
        Inventory.InterHubAmount 1;
        +INVENTORY.UNDROPPABLE
        -INVENTORY.INVBAR
    }
}
