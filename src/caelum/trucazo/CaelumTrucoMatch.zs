// Estado nativo aditivo: los saves anteriores no tienen partida. Crear este
// inventario una sola vez basta; nunca se reinicia una mano al cargarla.
class CaelumTrucoMatch : Inventory
{
    int Revision;
    bool WithFlor;
    bool FlorSettled;
    bool FlorRevealed;
    bool FaltaCalled;
    int SideGame;
    int LastCall;
    int Score[2];
    int TrickLeader;
    int Serial;
    bool Visible;
    CaelumArgento Opponent;
    CaelumTrucazoSide Sides[2];
    Array<int> Deck;
    int Drawn;
    int Phase;
    int HandNumber;
    int Mano;
    int Turn;
    int Trick;
    int Played[2];
    int TrickVictors[3];
    int Winner;
    bool Abandoned;
    int TrucoValue;
    int TrucoRight;
    int Pending;
    int Caller;
    int Bid;
    int RefusalPoints;
    int EnvidoCount;
    bool RealCalled;
    bool EnvidoSettled;
    bool EnvidoRevealed;
    int EnvidoWinner;
    int EnvidoAward;
    int SuspendedCaller;
    int SuspendedBid;
    int SuspendedRefusal;
    int EventKind[8];
    int EventSide[8];
    int EventValue[8];
    int EventCount;

    static CaelumTrucoMatch Get(CaelumPlayer user,bool create=false)
    {
        if(user==null)return null;
        let match=CaelumTrucoMatch(user.FindInventory("CaelumTrucoMatch"));
        if(match==null && create)
        {
            match=CaelumTrucoMatch(Actor.Spawn("CaelumTrucoMatch",user.Pos,NO_REPLACE));
            match.AttachToOwner(user);
            match.Revision=CaelumTrucoRules.REVISION;
        }
        return match;
    }
    clearscope bool Active() const
    { return HandNumber>0 && Phase!=CaelumTrucoRules.MATCH_RESULT; }
    bool ContextValid() const
    {
        let user=CaelumPlayer(Owner);
        return user!=null && user.health>0 && user.player!=null && !multiplayer
            && level.MapName=="MAP01" && Opponent!=null && Opponent.health>0 && Opponent.StoryAnchored;
    }
    static bool Open(CaelumPlayer user,CaelumArgento opponent)
    {
        if(user==null || user.player==null || user.health<=0 || opponent==null
            || user.player.ConversationNPC!=opponent || !opponent.StoryAnchored
            || level.MapName!="MAP01" || multiplayer || CaelumRestState.IsActive(user)
            || CaelumTimeSkipState.IsOpen(user))return false;
        if(!CaelumTarotService.HasPhysicalDeck(user))
        { CaelumTarotService.Feedback(user,"CA_TC_NEED_DECK");return false; }
        let match=Get(user,true);
        if(!match.Active())
        {
            match.Phase=CaelumTrucoRules.INTRO;match.HandNumber=0;
            match.Abandoned=false;match.Winner=-1;match.EventCount=0;
        }
        match.Opponent=opponent;match.Visible=true;match.Serial++;
        return true;
    }
    void LogEvent(int kind,int side,int value=0)
    {
        if(EventCount==8)
        {
            for(int i=0;i<7;i++)
            {EventKind[i]=EventKind[i+1];EventSide[i]=EventSide[i+1];EventValue[i]=EventValue[i+1];}
            EventCount--;
        }
        EventKind[EventCount]=kind;EventSide[EventCount]=side;EventValue[EventCount]=value;EventCount++;
    }
    void Start()
    {
        for(int side=0;side<2;side++){Sides[side]=new("CaelumTrucazoSide");Score[side]=0;}
        Mano=Random[CaelumTruco](0,1);HandNumber=0;Abandoned=false;EventCount=0;
        Deal();
    }
    void DrawTo(int side,bool first)
    { if(Drawn<int(Deck.Size()))Sides[side].Hand.Push(Deck[Drawn++]); }
    void Deal()
    {
        if(HandNumber>0)Mano=1-Mano;
        HandNumber++;Turn=Mano;TrickLeader=Mano;Trick=0;Phase=CaelumTrucoRules.PLAYING;
        Played[0]=-1;Played[1]=-1;Winner=-1;
        for(int i=0;i<3;i++)TrickVictors[i]=-1;
        TrucoValue=1;TrucoRight=-1;Pending=CaelumTrucoRules.NO_CALL;
        FlorSettled=!WithFlor;FlorRevealed=false;FaltaCalled=false;SideGame=0;LastCall=0;
        EnvidoCount=0;RealCalled=false;EnvidoSettled=false;EnvidoRevealed=false;
        EnvidoWinner=-1;EnvidoAward=0;SuspendedCaller=-1;Bid=0;RefusalPoints=0;
        for(int side=0;side<2;side++)Sides[side].ClearHand();
        Deck.Clear();Drawn=0;
        for(int card=CaelumConstants.TAROT_MAJOR_COUNT;card<CaelumConstants.TAROT_CARD_COUNT;card++)
            if(CaelumTrucoRules.Playable(card))Deck.Push(card);
        for(int i=int(Deck.Size())-1;i>0;i--)
        {
            int j=Random[CaelumTruco](0,i),temp=Deck[i];Deck[i]=Deck[j];Deck[j]=temp;
        }
        for(int i=0;i<CaelumTrucoRules.HAND_CARDS;i++)
        {DrawTo(Mano,true);DrawTo(1-Mano,true);}
        LogEvent(CaelumTrucoRules.DEAL_EVENT,Mano,HandNumber);
    }
    clearscope bool CanEnvido(int side) const
    {
        if(Phase!=CaelumTrucoRules.PLAYING || EnvidoSettled || Trick!=0 || Played[side]>=0
            || Pending==CaelumTrucoRules.FLOR_CALL || FaltaCalled)return false;
        if(WithFlor && CaelumTrucoRules.FlorValue(Sides[side])>0)return false;
        if(Pending!=CaelumTrucoRules.NO_CALL)return side!=Caller;
        return Turn==side;
    }
    clearscope bool CanFlor(int side) const
    {
        if(!WithFlor || FlorSettled || Phase!=CaelumTrucoRules.PLAYING || Trick!=0
            || Played[side]>=0 || CaelumTrucoRules.FlorValue(Sides[side])==0)return false;
        return Pending==CaelumTrucoRules.NO_CALL?Turn==side:Caller!=side;
    }
    clearscope bool CanTruco(int side) const
    {
        if(Phase!=CaelumTrucoRules.PLAYING || Pending==CaelumTrucoRules.ENVIDO_CALL
            || Pending==CaelumTrucoRules.FLOR_CALL || CanFlor(side))return false;
        if(Pending==CaelumTrucoRules.TRUCO_CALL)return side!=Caller && Bid<CaelumTrucoRules.MAX_TRUCO;
        return Turn==side && TrucoValue<CaelumTrucoRules.MAX_TRUCO && (TrucoRight<0 || TrucoRight==side);
    }
    clearscope bool CanAct(int side,int operation,int index=0) const
    {
        if(side<0 || side>1 || !Visible)return false;
        if(operation==CaelumTrucoRules.TOGGLE_FLOR)return Phase==CaelumTrucoRules.INTRO && side==0;
        if(operation==CaelumTrucoRules.BEGIN)return Phase==CaelumTrucoRules.INTRO && side==0;
        if(operation==CaelumTrucoRules.CLOSE)return !Active() && side==0;
        if(operation==CaelumTrucoRules.FORFEIT)return Active() && side==0;
        if(operation==CaelumTrucoRules.ADVANCE)return side==0 &&
            (Phase==CaelumTrucoRules.TRICK_RESULT || Phase==CaelumTrucoRules.HAND_RESULT);
        if(Phase!=CaelumTrucoRules.PLAYING)return false;
        if(operation==CaelumTrucoRules.ACCEPT || operation==CaelumTrucoRules.REFUSE)
        {
            if(Pending==CaelumTrucoRules.NO_CALL || side==Caller)return false;
            if(Pending==CaelumTrucoRules.FLOR_CALL)
                return operation==CaelumTrucoRules.REFUSE || (CaelumTrucoRules.FlorValue(Sides[side])>0 && LastCall!=CaelumTrucoRules.FLOR);
            return !CanFlor(side);
        }
        if(operation==CaelumTrucoRules.FLOR)return CanFlor(side) &&
            (Pending!=CaelumTrucoRules.FLOR_CALL || LastCall==CaelumTrucoRules.FLOR);
        if(operation==CaelumTrucoRules.CONTRA_FLOR || operation==CaelumTrucoRules.FLOR_REST)
            return CanFlor(side) && Pending==CaelumTrucoRules.FLOR_CALL && LastCall!=CaelumTrucoRules.FLOR_REST
                && (operation==CaelumTrucoRules.FLOR_REST || LastCall==CaelumTrucoRules.FLOR);
        if(operation==CaelumTrucoRules.FOLD)return Pending==CaelumTrucoRules.NO_CALL && Turn==side && !CanFlor(side);
        if(operation==CaelumTrucoRules.TRUCO)return CanTruco(side);
        if(operation==CaelumTrucoRules.ENVIDO)return CanEnvido(side) && !RealCalled && EnvidoCount<CaelumTrucoRules.MAX_ENVIDOS;
        if(operation==CaelumTrucoRules.REAL_ENVIDO)return CanEnvido(side) && !RealCalled;
        if(operation==CaelumTrucoRules.FALTA_ENVIDO)return CanEnvido(side);
        if(operation==CaelumTrucoRules.PLAY_CARD)
            return Pending==CaelumTrucoRules.NO_CALL && Turn==side && !CanFlor(side) && index>=0
                && index<int(Sides[side].Hand.Size()) && !Sides[side].Used[index] && Played[side]<0;
        return false;
    }
    void CheckMatchEnd()
    {
        if(Score[0]<CaelumTrucoRules.TARGET && Score[1]<CaelumTrucoRules.TARGET)return;
        Winner=Score[0]>=CaelumTrucoRules.TARGET?0:1;
        Phase=CaelumTrucoRules.MATCH_RESULT;Pending=CaelumTrucoRules.NO_CALL;SuspendedCaller=-1;
    }
    void FinishHand(int victor,int points)
    {
        Score[victor]+=points;Sides[victor].Points+=points;Winner=victor;
        LogEvent(CaelumTrucoRules.HAND_EVENT,victor,points);
        Phase=CaelumTrucoRules.HAND_RESULT;Pending=CaelumTrucoRules.NO_CALL;
        CheckMatchEnd();
    }
    void ResolveEnvido(int victor,int points,bool reveal)
    {
        Score[victor]+=points;Sides[victor].Points+=points;EnvidoSettled=true;EnvidoRevealed=reveal;
        EnvidoWinner=victor;EnvidoAward=points;
        LogEvent(SideGame==CaelumTrucoRules.FLOR_CALL?CaelumTrucoRules.FLOR_RESULT_EVENT:CaelumTrucoRules.ENVIDO_RESULT_EVENT,victor,points);
        Pending=CaelumTrucoRules.NO_CALL;
        CheckMatchEnd();
        if(Phase==CaelumTrucoRules.MATCH_RESULT)return;
        if(SuspendedCaller>=0)
        {
            Pending=CaelumTrucoRules.TRUCO_CALL;Caller=SuspendedCaller;
            Bid=SuspendedBid;RefusalPoints=SuspendedRefusal;SuspendedCaller=-1;
        }
    }
    bool Act(int side,int operation,int index=0)
    {
        if(!CanAct(side,operation,index))return false;
        if(operation==CaelumTrucoRules.TOGGLE_FLOR){WithFlor=!WithFlor;return true;}
        if(operation==CaelumTrucoRules.BEGIN){Start();return true;}
        if(operation==CaelumTrucoRules.CLOSE){Visible=false;return true;}
        if(operation==CaelumTrucoRules.FORFEIT)
        {
            Winner=1;Abandoned=true;Phase=CaelumTrucoRules.MATCH_RESULT;Pending=0;
            LogEvent(CaelumTrucoRules.FORFEIT_EVENT,0);return true;
        }
        if(operation==CaelumTrucoRules.ADVANCE)
        {
            if(Phase==CaelumTrucoRules.HAND_RESULT)Deal();
            else {if(TrickVictors[Trick]>=0)TrickLeader=TrickVictors[Trick];Turn=TrickLeader;Trick++;Played[0]=-1;Played[1]=-1;Phase=CaelumTrucoRules.PLAYING;}
            return true;
        }
        if(operation==CaelumTrucoRules.TRUCO)
        {
            if(Pending==CaelumTrucoRules.TRUCO_CALL)TrucoValue=Bid;
            RefusalPoints=TrucoValue;Bid=TrucoValue+1;Caller=side;Pending=CaelumTrucoRules.TRUCO_CALL;
            LogEvent(CaelumTrucoRules.TRUCO_EVENT,side,Bid);return true;
        }
        if(operation==CaelumTrucoRules.FOLD)
        {
            LogEvent(CaelumTrucoRules.FOLD_EVENT,side);
            if(Trick==0 && Played[side]<0 && !EnvidoSettled)
            {SideGame=CaelumTrucoRules.ENVIDO_CALL;ResolveEnvido(1-side,CaelumTrucoRules.EARLY_FOLD_POINTS,false);}
            if(Phase!=CaelumTrucoRules.MATCH_RESULT)FinishHand(1-side,TrucoValue);
            return true;
        }
        if(operation==CaelumTrucoRules.FLOR || operation==CaelumTrucoRules.CONTRA_FLOR || operation==CaelumTrucoRules.FLOR_REST)
        {
            if(Pending==CaelumTrucoRules.TRUCO_CALL)
            {SuspendedCaller=Caller;SuspendedBid=Bid;SuspendedRefusal=RefusalPoints;}
            SideGame=CaelumTrucoRules.FLOR_CALL;EnvidoSettled=true;
            LogEvent(operation==CaelumTrucoRules.FLOR?CaelumTrucoRules.FLOR_EVENT:
                operation==CaelumTrucoRules.CONTRA_FLOR?CaelumTrucoRules.CONTRA_EVENT:CaelumTrucoRules.REST_EVENT,side);
            if(operation==CaelumTrucoRules.FLOR && Pending==CaelumTrucoRules.FLOR_CALL)
            {
                int a=CaelumTrucoRules.FlorValue(Sides[0]),b=CaelumTrucoRules.FlorValue(Sides[1]);
                FlorSettled=true;FlorRevealed=true;ResolveEnvido(a==b?Mano:a>b?0:1,CaelumTrucoRules.CONTRA_POINTS,true);return true;
            }
            LastCall=operation;Pending=CaelumTrucoRules.FLOR_CALL;Caller=side;
            Bid=operation==CaelumTrucoRules.FLOR?CaelumTrucoRules.FLOR_POINTS:
                operation==CaelumTrucoRules.CONTRA_FLOR?CaelumTrucoRules.CONTRA_POINTS:CaelumTrucoRules.Rest(Score[0],Score[1]);
            RefusalPoints=CaelumTrucoRules.FLOR_REFUSAL;return true;
        }
        if(operation==CaelumTrucoRules.ENVIDO || operation==CaelumTrucoRules.REAL_ENVIDO || operation==CaelumTrucoRules.FALTA_ENVIDO)
        {
            if(Pending==CaelumTrucoRules.TRUCO_CALL)
            {SuspendedCaller=Caller;SuspendedBid=Bid;SuspendedRefusal=RefusalPoints;}
            int previous=Pending==CaelumTrucoRules.ENVIDO_CALL?Bid:0;
            RefusalPoints=Max(1,previous);
            bool real=operation==CaelumTrucoRules.REAL_ENVIDO;
            SideGame=CaelumTrucoRules.ENVIDO_CALL;LastCall=operation;
            FaltaCalled=operation==CaelumTrucoRules.FALTA_ENVIDO;
            Bid=FaltaCalled?CaelumTrucoRules.Rest(Score[0],Score[1]):previous+(real?CaelumTrucoRules.REAL_POINTS:CaelumTrucoRules.ENVIDO_POINTS);
            if(real)RealCalled=true;else if(!FaltaCalled)EnvidoCount++;
            Caller=side;Pending=CaelumTrucoRules.ENVIDO_CALL;
            LogEvent(FaltaCalled?CaelumTrucoRules.FALTA_EVENT:real?CaelumTrucoRules.REAL_EVENT:CaelumTrucoRules.ENVIDO_EVENT,side,Bid);return true;
        }
        if(operation==CaelumTrucoRules.ACCEPT || operation==CaelumTrucoRules.REFUSE)
        {
            bool accept=operation==CaelumTrucoRules.ACCEPT;
            LogEvent(accept?CaelumTrucoRules.ACCEPT_EVENT:CaelumTrucoRules.REFUSE_EVENT,side);
            if(Pending==CaelumTrucoRules.TRUCO_CALL)
            {
                if(!accept)FinishHand(Caller,RefusalPoints);
                else {TrucoValue=Bid;TrucoRight=side;Pending=CaelumTrucoRules.NO_CALL;}
            }
            else if(Pending==CaelumTrucoRules.FLOR_CALL)
            {
                int a=CaelumTrucoRules.FlorValue(Sides[0]),b=CaelumTrucoRules.FlorValue(Sides[1]);
                FlorSettled=true;FlorRevealed=accept;
                int refused=CaelumTrucoRules.FlorValue(Sides[side])>0?RefusalPoints:CaelumTrucoRules.FLOR_POINTS;
                ResolveEnvido(accept?(a==b?Mano:a>b?0:1):Caller,accept?Bid:refused,accept);
            }
            else
            {
                int a=Sides[0].EnvidoValue(),b=Sides[1].EnvidoValue();
                ResolveEnvido(accept?(a==b?Mano:a>b?0:1):Caller,accept?Bid:RefusalPoints,accept);
            }
            return true;
        }
        Sides[side].Used[index]=true;Played[side]=Sides[side].Hand[index];
        LogEvent(CaelumTrucoRules.CARD_EVENT,side,Played[side]);
        if(Played[1-side]<0)Turn=1-side;
        else
        {
            int a=CaelumTrucoRules.Strength(Played[0]),b=CaelumTrucoRules.Strength(Played[1]);
            int victor=a==b?-1:a<b?0:1;
            if(victor>=0)Sides[victor].Tricks++;TrickVictors[Trick]=victor;
            LogEvent(CaelumTrucoRules.TRICK_EVENT,victor,Trick+1);
            int handWinner=CaelumTrucoRules.HandVictor(TrickVictors[0],TrickVictors[1],TrickVictors[2],Trick+1,Mano);
            if(handWinner>=0)FinishHand(handWinner,TrucoValue);
            else Phase=CaelumTrucoRules.TRICK_RESULT;
        }
        return true;
    }
    bool NPCAction()
    {
        if(Phase!=CaelumTrucoRules.PLAYING)return false;
        let own=Sides[1];
        if(CanAct(1,CaelumTrucoRules.FLOR))return Act(1,CaelumTrucoRules.FLOR);
        if(Pending==CaelumTrucoRules.FLOR_CALL)
        {
            if(Caller==1)return false;
            return Act(1,CaelumTrucoRules.FlorValue(own)>0?CaelumTrucoRules.ACCEPT:CaelumTrucoRules.REFUSE);
        }
        if(Pending!=CaelumTrucoRules.NO_CALL)
        {
            if(Caller==1)return false;
            if(Pending==CaelumTrucoRules.ENVIDO_CALL)
            {
                if(CaelumTrucazoNPC.StrongEnvido(own))
                {
                    if(CanAct(1,CaelumTrucoRules.ENVIDO))return Act(1,CaelumTrucoRules.ENVIDO);
                    if(CanAct(1,CaelumTrucoRules.REAL_ENVIDO))return Act(1,CaelumTrucoRules.REAL_ENVIDO);
                    return Act(1,CaelumTrucoRules.ACCEPT);
                }
                return Act(1,CaelumTrucoRules.REFUSE);
            }
            if(CanAct(1,CaelumTrucoRules.ENVIDO) && CaelumTrucazoNPC.StrongEnvido(own))return Act(1,CaelumTrucoRules.ENVIDO);
            return Act(1,CaelumTrucazoNPC.StrongTruco(own)?CaelumTrucoRules.ACCEPT:CaelumTrucoRules.REFUSE);
        }
        if(Turn!=1)return false;
        if(CanAct(1,CaelumTrucoRules.ENVIDO) && CaelumTrucazoNPC.StrongEnvido(own))return Act(1,CaelumTrucoRules.ENVIDO);
        if(CanAct(1,CaelumTrucoRules.TRUCO) && CaelumTrucazoNPC.StrongTruco(own))return Act(1,CaelumTrucoRules.TRUCO);
        return Act(1,CaelumTrucoRules.PLAY_CARD,CaelumTrucazoNPC.ChooseCard(own,Played[0],true));
    }
    void Dispatch(int operation,int index,int expectedSerial)
    {
        if(expectedSerial!=Serial || !Visible)return;
        if(!ContextValid())
        {
            if(Active())Act(0,CaelumTrucoRules.FORFEIT);
            Visible=false;Serial++;return;
        }
        if(operation==CaelumTrucoRules.BEGIN && !CaelumTarotService.HasPhysicalDeck(CaelumPlayer(Owner)))
        {CaelumTarotService.Feedback(CaelumPlayer(Owner),"CA_TC_NEED_DECK");Serial++;return;}
        if(operation==CaelumTrucoRules.NPC_STEP)NPCAction();else Act(0,operation,index);
        // Aun el rechazo confirma recepción: el menú puede corregir su orden
        // sin quedar esperando una revisión que nunca llegará. No usa azar.
        Serial++;
    }
    override void Tick()
    {
        Super.Tick();
        if(Visible && !ContextValid())
        {if(Active())Act(0,CaelumTrucoRules.FORFEIT);Visible=false;Serial++;}
    }
    Default
    {
        Inventory.MaxAmount 1;
        Inventory.InterHubAmount 1;
        +INVENTORY.UNDROPPABLE
        -INVENTORY.INVBAR
    }
}

class CaelumTrucoChallengeAction : CaelumPalomoDialogueAction
{
    override bool Use(bool pickup)
    {
        let user=CaelumPlayer(Owner);
        return user!=null && user.player!=null
            && CaelumTrucoMatch.Open(user,CaelumArgento(user.player.ConversationNPC));
    }
}
