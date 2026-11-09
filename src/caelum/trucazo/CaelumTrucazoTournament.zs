// #446: cuadro local aprobado por todos; no servicio externo, premios ni sustitutos.
class CaelumTrucazoTournament : Object play
{
    enum StateKind { PROPOSAL, ACTIVE, COMPLETE, CANCELLED }
    enum RequestKind { ACCEPT, CANCEL_PROPOSAL, NEXT_MATCH, CLOSE_VIEW }
    int Revision,Serial,Phase,Tier,Accepted,Round,Cursor,Champion;
    CaelumDiningTable Table;
    Array<CaelumPlayer> Members;
    Array<int> Slots,Remaining,NextRound,PlayedA,PlayedB,Victors;
    Array<String> Profiles;
    CaelumCardDuel Match;
    bool MatchRecorded;
    String Status;
    clearscope int Count() const {return int(Members.Size());}
    clearscope int Side(CaelumPlayer user) const
    {for(int i=0;i<Count();i++)if(user!=null && Members[i]==user)return i;return -1;}
    clearscope int FullMask() const {return (1<<Count())-1;}
    bool HasDeck()
    {for(int i=0;i<Count();i++)if(Connected(i) && CaelumCardSeat.Table(Members[i])==Table && CaelumTarotService.HasPhysicalDeck(Members[i]))return true;return false;}
    clearscope bool Connected(int seat) const
    {
        if(seat<0 || seat>=Count())return false;let user=Members[seat];int slot=Slots[seat];
        if(user==null || slot<0 || slot>=MAXPLAYERS || !playeringame[slot] || players[slot].mo!=user || !CaelumPlayerAuthority.CanRead(user) || user.ProfileDeparted)return false;
        let record=CaelumPersistentCharacterState(user.FindInventory('CaelumPersistentCharacterState'));
        return Profiles[seat]=="" || (record!=null && record.ExternalProfileId==Profiles[seat]);
    }
    clearscope bool InCompetition(int seat) const
    {
        if(Phase==PROPOSAL)return seat>=0 && seat<Count();
        if(Phase!=ACTIVE)return false;
        for(int i=Cursor*2;i<int(Remaining.Size());i++)if(Remaining[i]==seat)return true;
        for(int i=0;i<int(NextRound.Size());i++)if(NextRound[i]==seat)return true;
        return false;
    }
    clearscope int NextSeat(bool second) const
    {int index=Cursor*2+(second?1:0);return Phase==ACTIVE && index<int(Remaining.Size())?Remaining[index]:-1;}
    clearscope bool Pair(CaelumPlayer a,CaelumPlayer b) const
    {int first=NextSeat(false),second=NextSeat(true);return first>=0 && second>=0 && a==Members[first] && b==Members[second];}
    static clearscope bool Available(CaelumPlayer user,CaelumDiningTable table,int tier)
    {
        if(user==null || user is 'CaelumStandalonePlayer' || !CaelumPlayerAuthority.CanRead(user) || CaelumCardSeat.Table(user)!=table)return false;
        let link=CaelumCardSeat.Read(user);if(link!=null && (link.Duel!=null || link.Tournament!=null))return false;
        let truco=CaelumTrucoMatch(user.FindInventory('CaelumTrucoMatch'));let trucazo=CaelumTrucazoMatch(user.FindInventory('CaelumTrucazoMatch'));
        return (truco==null || !truco.Active()) && (trucazo==null || !trucazo.Active()) && CaelumTrucazoCompetitive.Rating(user)>=CaelumTrucazoData.TournamentThreshold(tier);
    }
    static bool Create(CaelumPlayer user,int size,int tier,int expectedSerial)
    {
        let own=CaelumCardSeat.Read(user);let table=CaelumCardSeat.Table(user);
        if(!multiplayer || own==null || !own.Open || own.LastSerial!=expectedSerial || table==null || (size!=4 && size!=8) || tier<0 || tier>1 || !Available(user,table,tier))return false;
        Array<CaelumPlayer> chosen;chosen.Push(user);
        for(int i=0;i<MAXPLAYERS && int(chosen.Size())<size;i++)if(playeringame[i])
        {let other=CaelumPlayer(players[i].mo);if(other!=user && Available(other,table,tier))chosen.Push(other);}
        if(int(chosen.Size())!=size){CaelumTarotService.Feedback(user,"CA_TC4_NEED_ENTRANTS");return false;}
        let t=new('CaelumTrucazoTournament');t.Revision=CaelumTrucazoData.TOURNAMENT_REVISION;t.Table=table;t.Tier=tier;t.Champion=-1;t.Members.Copy(chosen);
        for(int i=0;i<size;i++)
        {
            let member=chosen[i];let record=member.GetPersistentCharacterState(true);record.EnsureTrucazoRating();
            t.Slots.Push(member.PlayerNumber());t.Profiles.Push(record.ExternalProfileId);t.Remaining.Push(i);
            let link=CaelumCardSeat.Get(member);t.Serial=Max(t.Serial,link.LastSerial);link.Tournament=t;link.Open=true;
        }
        t.Advance();return true;
    }
    void Advance()
    {
        Serial++;
        for(int i=0;i<Count();i++)
        {let link=CaelumCardSeat.Read(Members[i]);if(link!=null && link.Tournament==self)link.LastSerial=Max(link.LastSerial,Serial);}
    }
    bool OpenMatch()
    {
        if(Phase!=ACTIVE || (Match!=null && !MatchRecorded))return false;
        int first=NextSeat(false),second=NextSeat(true);
        if(!Connected(first) || !Connected(second) || CaelumCardSeat.Table(Members[first])!=Table || CaelumCardSeat.Table(Members[second])!=Table)return false;
        let a=Members[first];let b=Members[second];let link=CaelumCardSeat.Get(a);
        if(!CaelumCardDuel.Invite(a,b,link.LastSerial,self))return false;
        Match=link.Duel;MatchRecorded=false;Match.Game=CaelumCardDuel.GAME_TRUCAZO;Match.Ranked=true;Match.Consequences=true;Match.Wagers=CaelumTrucazoWagers.Create(Match);
        Match.AdvanceSerial();return true;
    }
    void MatchEnded(CaelumCardDuel duel)
    {
        if(Phase!=ACTIVE || Match!=duel || MatchRecorded || !duel.Finished())return;
        int a=NextSeat(false),b=NextSeat(true);if(a<0 || b<0)return;
        int winner=duel.Advanced.Winner==0?a:b;PlayedA.Push(a);PlayedB.Push(b);Victors.Push(winner);NextRound.Push(winner);MatchRecorded=true;Cursor++;
        if(Cursor*2>=int(Remaining.Size()))
        {
            Remaining.Copy(NextRound);NextRound.Clear();Cursor=0;Round++;
            if(Remaining.Size()==1){Champion=Remaining[0];Phase=COMPLETE;}
        }
        Advance();
    }
    bool Request(CaelumPlayer user,int operation,int expectedSerial)
    {
        int seat=Side(user);let own=CaelumCardSeat.Read(user);
        if(seat<0 || own==null || own.Tournament!=self || expectedSerial!=Serial || !Connected(seat))return false;
        if(operation==CLOSE_VIEW)
        {own.Open=false;if(!InCompetition(seat))own.Tournament=null;return true;}
        if(operation==CANCEL_PROPOSAL && Phase==PROPOSAL)
        {
            Phase=CANCELLED;
            for(int i=0;i<Count();i++){let link=CaelumCardSeat.Read(Members[i]);if(link!=null && link.Tournament==self){link.Tournament=null;link.Open=false;link.LastSerial++;}}
            return true;
        }
        if(operation==ACCEPT && Phase==PROPOSAL)
        {
            if((Accepted&(1<<seat))!=0)return false;Accepted|=1<<seat;
            if(Accepted==FullMask())
            {
                for(int i=0;i<Count();i++)if(!Connected(i) || CaelumCardSeat.Table(Members[i])!=Table || CaelumTrucazoCompetitive.Rating(Members[i])<CaelumTrucazoData.TournamentThreshold(Tier))
                {Accepted=0;Status="CA_TC4_RECHECK";Advance();return false;}
                Phase=ACTIVE;OpenMatch();
            }
        }
        else if(operation==NEXT_MATCH && Phase==ACTIVE && (seat==NextSeat(false) || seat==NextSeat(true)))
        {if(!OpenMatch()){Status="CA_TC4_RETURN_TABLE";Advance();return false;}}
        else return false;
        Status="";Advance();return true;
    }
}
