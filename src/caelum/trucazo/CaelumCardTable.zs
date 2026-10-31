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
        if(!CaelumPlayerAuthority.CanMutate(user) || user.health<=0)return null;
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
        if(!multiplayer || Table(user)==null)return false;
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
    enum LobbyAction { SELECT_GAME, SELECT_FLOR, CONSENT, CANCEL };
    enum GameKind { GAME_TRUCO, GAME_TRUCAZO };
    CaelumPlayer Participants[2];
    CaelumDiningTable Table;
    CaelumTrucoMatch Truco;
    CaelumTrucazoMatch Trucazo;
    int Game;
    bool Flor;
    int Accepted;
    int Serial;
    bool Started;
    bool Suspended;

    clearscope int Side(CaelumPlayer user) const
    { return user==Participants[0]?0:user==Participants[1]?1:-1; }
    clearscope bool Finished() const
    { return Started && (Game==GAME_TRUCO?Truco!=null && !Truco.Active():Trucazo!=null && !Trucazo.Active()); }
    bool Connected() const
    {
        for(int i=0;i<2;i++)
        {
            let user=Participants[i];
            if(user==null || user.player==null)return false;
            int number=user.PlayerNumber();
            if(number<0 || number>=MAXPLAYERS || !playeringame[number] || players[number].mo!=user)return false;
        }
        return true;
    }
    bool Seated(int side) const
    { return Table!=null && CaelumCardSeat.Table(Participants[side])==Table; }
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
        for(int i=0;i<2;i++)
        {
            let link=CaelumCardSeat.Read(Participants[i]);
            if(link!=null && link.Duel==self)link.LastSerial=Serial;
        }
        if(Truco!=null)Truco.Serial=Serial;
        if(Trucazo!=null)Trucazo.Serial=Serial;
    }
    void Release()
    {
        AdvanceSerial();
        for(int i=0;i<2;i++)
        {
            let link=CaelumCardSeat.Read(Participants[i]);
            if(link!=null && link.Duel==self){link.Duel=null;link.Open=false;}
        }
        if(Truco!=null){Truco.Visible=false;Truco.Duel=null;}
        if(Trucazo!=null){Trucazo.Visible=false;Trucazo.Duel=null;}
        Destroy();
    }
    bool Lobby(CaelumPlayer user,int operation,int expectedSerial)
    {
        int side=Side(user);
        if(side<0 || Started || expectedSerial!=Serial || !Connected() || Suspended)return false;
        if(operation==CANCEL){Release();return true;}
        if(!Seated(0) || !Seated(1)){Release();return false;}
        if(operation==SELECT_GAME && side==0){Game=1-Game;Accepted=0;}
        else if(operation==SELECT_FLOR && side==0 && Game==GAME_TRUCO){Flor=!Flor;Accepted=0;}
        else if(operation==CONSENT)
        {
            if((Accepted & (1<<side))!=0)return false;
            Accepted|=1<<side;
            if(Accepted==3)
            {
                if(!CaelumTarotService.HasPhysicalDeck(Participants[0])
                    && !CaelumTarotService.HasPhysicalDeck(Participants[1]))
                {
                    Accepted=0;
                    for(int i=0;i<2;i++)CaelumTarotService.Feedback(Participants[i],"CA_TC_NEED_DECK");
                }
                else Start();
            }
        }
        else return false;
        AdvanceSerial();return true;
    }
    void Start()
    {
        if(Game==GAME_TRUCO)
        {
            Truco=CaelumTrucoMatch.Get(Participants[0],true);
            Truco.Duel=self;Truco.Opponent=null;Truco.WithFlor=Flor;Truco.Visible=true;Truco.Start();
        }
        else
        {
            Trucazo=CaelumTrucazoMatch.Get(Participants[0],true);
            Trucazo.Duel=self;Trucazo.Opponent=null;Trucazo.Visible=true;Trucazo.Start();
        }
        Started=true;
    }
    bool Dispatch(CaelumPlayer user,int requestedGame,int operation,int index,int expectedSerial)
    {
        int side=Side(user);
        if(side<0 || !Started || requestedGame!=Game || expectedSerial!=Serial)return false;
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
    override void Tick()
    {
        Super.Tick();
        // La desconexión conserva la mano para recuperación común, no es una derrota.
        if(!Connected()){if(!Started)Release();else Suspended=true;return;}
        if(Suspended || Finished())return;
        for(int side=0;side<2;side++)if(!Seated(side))
        {
            if(!Started){Release();return;}
            if(Game==GAME_TRUCO)Truco.Act(side,CaelumTrucoRules.FORFEIT);
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
