// Estado nativo aditivo: los saves anteriores no tienen partida. Crear este
// inventario una sola vez basta; nunca se reinicia una mano al cargarla.
class CaelumTrucazoMatch : Inventory
{
    int Revision;
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

    static CaelumTrucazoMatch Get(CaelumPlayer user,bool create=false)
    {
        if(user==null)return null;
        let match=CaelumTrucazoMatch(user.FindInventory("CaelumTrucazoMatch"));
        if(match==null && create)
        {
            match=CaelumTrucazoMatch(Actor.Spawn("CaelumTrucazoMatch",user.Pos,NO_REPLACE));
            match.AttachToOwner(user);
            match.Revision=CaelumTrucazoRules.REVISION;
        }
        return match;
    }
    clearscope bool Active() const
    { return HandNumber>0 && Phase!=CaelumTrucazoRules.MATCH_RESULT; }
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
        if(!CaelumTarotDeckRules.Owned(user))
        { CaelumTarotPowers.Feedback(user,"CA_TC_NEED_DECK");return false; }
        let match=Get(user,true);
        if(!match.Active())
        {
            match.Phase=CaelumTrucazoRules.INTRO;match.HandNumber=0;
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
        let user=CaelumPlayer(Owner);
        for(int side=0;side<2;side++)Sides[side]=new("CaelumTrucazoSide");
        let record=user.GetPersistentCharacterState(false);
        for(int card=CaelumConstants.TAROT_MAJOR_COUNT;card<CaelumConstants.TAROT_CARD_COUNT;card++)
            Sides[0].Awake[card]=record!=null && record.HasTarotCard(card);
        Sides[0].MaximumHealth=CaelumTrucazoRules.Health(user.Attributes.Patience);
        Sides[0].Intelligence=user.Attributes.Intelligence;
        Sides[1].MaximumHealth=CaelumTrucazoRules.Health(Opponent.CombatPatience
            +Opponent.GetCombatArmorAttributeBonus(CaelumConstants.ATTRIBUTE_PATIENCE));
        Sides[1].Intelligence=Opponent.CombatIntelligence
            +Opponent.GetCombatArmorAttributeBonus(CaelumConstants.ATTRIBUTE_INTELLIGENCE);
        for(int side=0;side<2;side++)Sides[side].Health=Sides[side].MaximumHealth;
        Mano=Random[CaelumTrucazo](0,1);HandNumber=0;Abandoned=false;
        Deal();CheckMatchEnd();
    }
    void DrawTo(int side,bool first)
    {
        if(Drawn>=int(Deck.Size()))return;
        int card=Deck[Drawn++];
        if(CaelumTrucazoRules.Playable(card))Sides[side].Hand.Push(card);
        else if(first)Sides[side].FirstRow.Push(card);
        else Sides[side].SecondRow.Push(card);
    }
    void Deal()
    {
        if(HandNumber>0)Mano=1-Mano;
        HandNumber++;Turn=Mano;Trick=0;Phase=CaelumTrucazoRules.PLAYING;
        Played[0]=-1;Played[1]=-1;Winner=-1;
        for(int i=0;i<3;i++)TrickVictors[i]=-1;
        TrucoValue=1;TrucoRight=-1;Pending=CaelumTrucazoRules.NO_CALL;
        EnvidoCount=0;RealCalled=false;EnvidoSettled=false;EnvidoRevealed=false;
        EnvidoWinner=-1;EnvidoAward=0;SuspendedCaller=-1;Bid=0;RefusalPoints=0;
        for(int side=0;side<2;side++)Sides[side].ClearHand();
        Deck.Clear();Drawn=0;
        for(int card=CaelumConstants.TAROT_MAJOR_COUNT;card<CaelumConstants.TAROT_CARD_COUNT;card++)Deck.Push(card);
        for(int i=int(Deck.Size())-1;i>0;i--)
        {
            int j=Random[CaelumTrucazo](0,i),temp=Deck[i];Deck[i]=Deck[j];Deck[j]=temp;
        }
        for(int i=0;i<CaelumTrucazoRules.INITIAL_CARDS;i++)
        {DrawTo(Mano,true);DrawTo(1-Mano,true);}
        for(int side=0;side<2;side++)
        {
            int seat=(Mano+side)%2;
            while(Sides[seat].Hand.Size()<CaelumTrucazoRules.MINIMUM_PLAYABLE && Drawn<int(Deck.Size()))DrawTo(seat,false);
        }
        LogEvent(CaelumTrucazoRules.DEAL_EVENT,Mano,HandNumber);
    }
    clearscope bool CanEnvido(int side) const
    {
        if(Phase!=CaelumTrucazoRules.PLAYING || EnvidoSettled || Trick!=0 || Played[side]>=0)return false;
        if(Pending==CaelumTrucazoRules.ENVIDO_CALL)return side!=Caller && !RealCalled;
        if(Pending==CaelumTrucazoRules.TRUCO_CALL)return side!=Caller;
        return Turn==side;
    }
    clearscope bool CanTruco(int side) const
    {
        if(Phase!=CaelumTrucazoRules.PLAYING || Pending==CaelumTrucazoRules.ENVIDO_CALL)return false;
        if(Pending==CaelumTrucazoRules.TRUCO_CALL)return side!=Caller && Bid<CaelumTrucazoRules.MAX_TRUCO;
        return Turn==side && TrucoValue<CaelumTrucazoRules.MAX_TRUCO && (TrucoRight<0 || TrucoRight==side);
    }
    clearscope bool CanAct(int side,int operation,int index=0) const
    {
        if(side<0 || side>1 || !Visible)return false;
        if(operation==CaelumTrucazoRules.BEGIN)return Phase==CaelumTrucazoRules.INTRO && side==0;
        if(operation==CaelumTrucazoRules.CLOSE)return !Active() && side==0;
        if(operation==CaelumTrucazoRules.FORFEIT)return Active() && side==0;
        if(operation==CaelumTrucazoRules.ADVANCE)return side==0 &&
            (Phase==CaelumTrucazoRules.TRICK_RESULT || Phase==CaelumTrucazoRules.HAND_RESULT);
        if(Phase!=CaelumTrucazoRules.PLAYING)return false;
        if(operation==CaelumTrucazoRules.ACCEPT || operation==CaelumTrucazoRules.REFUSE)
            return Pending!=CaelumTrucazoRules.NO_CALL && side!=Caller;
        if(operation==CaelumTrucazoRules.TRUCO)return CanTruco(side);
        if(operation==CaelumTrucazoRules.ENVIDO)return CanEnvido(side) && EnvidoCount<CaelumTrucazoRules.MAX_ENVIDOS;
        if(operation==CaelumTrucazoRules.REAL_ENVIDO)return CanEnvido(side) && !RealCalled;
        if(operation==CaelumTrucazoRules.PLAY_CARD)
            return Pending==CaelumTrucazoRules.NO_CALL && Turn==side && index>=0
                && index<int(Sides[side].Hand.Size()) && !Sides[side].Used[index] && Played[side]<0;
        return false;
    }
    void CheckMatchEnd()
    {
        if(Sides[0].Health>0 && Sides[1].Health>0)return;
        Winner=Sides[0].Health<=0 && Sides[1].Health<=0?Mano:Sides[0].Health>0?0:1;
        Phase=CaelumTrucazoRules.MATCH_RESULT;Pending=CaelumTrucazoRules.NO_CALL;
    }
    void FinishHand(int victor,int points)
    {
        Sides[victor].Points+=points;Winner=victor;
        LogEvent(CaelumTrucazoRules.HAND_EVENT,victor,points);
        // Daño simultáneo: primero se calculan ambos resultados, después se
        // comprueba KO doble. Resolver un lado antes no cambia al ganador.
        for(int side=0;side<2;side++)Sides[side].LastDamage=CaelumTrucazoRules.Damage(
            Sides[side].RowValue(true),Sides[1-side].RowValue(false),Sides[side].Points,Sides[side].Intelligence);
        for(int side=0;side<2;side++)
        {
            Sides[1-side].Health=Max(0.0,Sides[1-side].Health-Sides[side].LastDamage);
            LogEvent(CaelumTrucazoRules.DAMAGE_EVENT,side,Sides[side].LastDamage);
        }
        Phase=CaelumTrucazoRules.HAND_RESULT;Pending=CaelumTrucazoRules.NO_CALL;
        CheckMatchEnd();
    }
    void ResolveEnvido(int victor,int points,bool reveal)
    {
        Sides[victor].Points+=points;EnvidoSettled=true;EnvidoRevealed=reveal;
        EnvidoWinner=victor;EnvidoAward=points;
        LogEvent(CaelumTrucazoRules.ENVIDO_RESULT_EVENT,victor,points);
        Pending=CaelumTrucazoRules.NO_CALL;
        if(SuspendedCaller>=0)
        {
            Pending=CaelumTrucazoRules.TRUCO_CALL;Caller=SuspendedCaller;
            Bid=SuspendedBid;RefusalPoints=SuspendedRefusal;SuspendedCaller=-1;
        }
    }
    bool Act(int side,int operation,int index=0)
    {
        if(!CanAct(side,operation,index))return false;
        if(operation==CaelumTrucazoRules.BEGIN){Start();return true;}
        if(operation==CaelumTrucazoRules.CLOSE){Visible=false;return true;}
        if(operation==CaelumTrucazoRules.FORFEIT)
        {
            Winner=1;Abandoned=true;Phase=CaelumTrucazoRules.MATCH_RESULT;Pending=0;
            LogEvent(CaelumTrucazoRules.FORFEIT_EVENT,0);return true;
        }
        if(operation==CaelumTrucazoRules.ADVANCE)
        {
            if(Phase==CaelumTrucazoRules.HAND_RESULT)Deal();
            else {Turn=TrickVictors[Trick];Trick++;Played[0]=-1;Played[1]=-1;Phase=CaelumTrucazoRules.PLAYING;}
            return true;
        }
        if(operation==CaelumTrucazoRules.TRUCO)
        {
            if(Pending==CaelumTrucazoRules.TRUCO_CALL)TrucoValue=Bid;
            RefusalPoints=TrucoValue;Bid=TrucoValue+1;Caller=side;Pending=CaelumTrucazoRules.TRUCO_CALL;
            LogEvent(CaelumTrucazoRules.TRUCO_EVENT,side,Bid);return true;
        }
        if(operation==CaelumTrucazoRules.ENVIDO || operation==CaelumTrucazoRules.REAL_ENVIDO)
        {
            if(Pending==CaelumTrucazoRules.TRUCO_CALL)
            {SuspendedCaller=Caller;SuspendedBid=Bid;SuspendedRefusal=RefusalPoints;}
            int previous=Pending==CaelumTrucazoRules.ENVIDO_CALL?Bid:0;
            RefusalPoints=Max(1,previous);
            bool real=operation==CaelumTrucazoRules.REAL_ENVIDO;
            Bid=previous+(real?CaelumTrucazoRules.REAL_POINTS:CaelumTrucazoRules.ENVIDO_POINTS);
            if(real)RealCalled=true;else EnvidoCount++;
            Caller=side;Pending=CaelumTrucazoRules.ENVIDO_CALL;
            LogEvent(real?CaelumTrucazoRules.REAL_EVENT:CaelumTrucazoRules.ENVIDO_EVENT,side,Bid);return true;
        }
        if(operation==CaelumTrucazoRules.ACCEPT || operation==CaelumTrucazoRules.REFUSE)
        {
            bool accept=operation==CaelumTrucazoRules.ACCEPT;
            LogEvent(accept?CaelumTrucazoRules.ACCEPT_EVENT:CaelumTrucazoRules.REFUSE_EVENT,side);
            if(Pending==CaelumTrucazoRules.TRUCO_CALL)
            {
                if(!accept)FinishHand(Caller,RefusalPoints);
                else {TrucoValue=Bid;TrucoRight=side;Pending=CaelumTrucazoRules.NO_CALL;}
            }
            else
            {
                int a=Sides[0].EnvidoValue(),b=Sides[1].EnvidoValue();
                ResolveEnvido(accept?(a==b?Mano:a>b?0:1):Caller,accept?Bid:RefusalPoints,accept);
            }
            return true;
        }
        Sides[side].Used[index]=true;Played[side]=Sides[side].Hand[index];
        LogEvent(CaelumTrucazoRules.CARD_EVENT,side,Played[side]);
        if(Played[1-side]<0)Turn=1-side;
        else
        {
            int victor=CaelumTrucazoRules.TrickWinner(Played[0],Played[1],Mano);
            Sides[victor].Tricks++;TrickVictors[Trick]=victor;
            LogEvent(CaelumTrucazoRules.TRICK_EVENT,victor,Trick+1);
            if(Sides[victor].Tricks>=CaelumTrucazoRules.TRICKS_TO_WIN)FinishHand(victor,TrucoValue);
            else Phase=CaelumTrucazoRules.TRICK_RESULT;
        }
        return true;
    }
    bool NPCAction()
    {
        if(Phase!=CaelumTrucazoRules.PLAYING)return false;
        let own=Sides[1];
        if(Pending!=CaelumTrucazoRules.NO_CALL)
        {
            if(Caller==1)return false;
            if(Pending==CaelumTrucazoRules.ENVIDO_CALL)
            {
                if(CaelumTrucazoNPC.StrongEnvido(own))
                {
                    if(CanAct(1,CaelumTrucazoRules.ENVIDO))return Act(1,CaelumTrucazoRules.ENVIDO);
                    if(CanAct(1,CaelumTrucazoRules.REAL_ENVIDO))return Act(1,CaelumTrucazoRules.REAL_ENVIDO);
                    return Act(1,CaelumTrucazoRules.ACCEPT);
                }
                return Act(1,CaelumTrucazoRules.REFUSE);
            }
            if(CanAct(1,CaelumTrucazoRules.ENVIDO) && CaelumTrucazoNPC.StrongEnvido(own))return Act(1,CaelumTrucazoRules.ENVIDO);
            return Act(1,CaelumTrucazoNPC.StrongTruco(own)?CaelumTrucazoRules.ACCEPT:CaelumTrucazoRules.REFUSE);
        }
        if(Turn!=1)return false;
        if(CanAct(1,CaelumTrucazoRules.ENVIDO) && CaelumTrucazoNPC.StrongEnvido(own))return Act(1,CaelumTrucazoRules.ENVIDO);
        if(CanAct(1,CaelumTrucazoRules.TRUCO) && CaelumTrucazoNPC.StrongTruco(own))return Act(1,CaelumTrucazoRules.TRUCO);
        return Act(1,CaelumTrucazoRules.PLAY_CARD,CaelumTrucazoNPC.ChooseCard(own,Played[0],Mano==1));
    }
    void Dispatch(int operation,int index,int expectedSerial)
    {
        if(expectedSerial!=Serial || !Visible)return;
        if(!ContextValid())
        {
            if(Active())Act(0,CaelumTrucazoRules.FORFEIT);
            Visible=false;Serial++;return;
        }
        if(operation==CaelumTrucazoRules.BEGIN && !CaelumTarotDeckRules.Owned(CaelumPlayer(Owner)))
        {CaelumTarotPowers.Feedback(CaelumPlayer(Owner),"CA_TC_NEED_DECK");Serial++;return;}
        if(operation==CaelumTrucazoRules.NPC_STEP)NPCAction();else Act(0,operation,index);
        // Aun el rechazo confirma recepción: el menú puede corregir su orden
        // sin quedar esperando una revisión que nunca llegará. No usa azar.
        Serial++;
    }
    override void Tick()
    {
        Super.Tick();
        if(Visible && !ContextValid())
        {if(Active())Act(0,CaelumTrucazoRules.FORFEIT);Visible=false;Serial++;}
    }
    Default
    {
        Inventory.MaxAmount 1;
        Inventory.InterHubAmount 1;
        +INVENTORY.UNDROPPABLE
        -INVENTORY.INVBAR
    }
}

class CaelumTrucazoChallengeAction : CaelumPalomoDialogueAction
{
    override bool Use(bool pickup)
    {
        let user=CaelumPlayer(Owner);
        return user!=null && user.player!=null
            && CaelumTrucazoMatch.Open(user,CaelumArgento(user.player.ConversationNPC));
    }
}
