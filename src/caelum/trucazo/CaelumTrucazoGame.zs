// #443: estado separado del contrato de práctica; no sustituye inventarios antiguos.
class CaelumTrucazoSeatState : Object
{
    CaelumTrucazoSide Cards;
    bool Selected[22],Spent[22],Active[22];
    bool WorldSpent,SenseSpent,AutoPass,PlayedEmperor,PlayedChariot,PlayedMoon;
    double Insight;
    int BaseEnvido,Played;
    String PrivateKey;
    int PrivateTarget,PrivateCard;
}

class CaelumTrucazoEffect : Object
{
    int Seat,Card,Argument;
}

class CaelumTrucazoChoice : Inventory
{
    bool Selected[22];
    int Revision;
    static clearscope CaelumTrucazoChoice Read(CaelumPlayer user)
    {return user==null?null:CaelumTrucazoChoice(user.FindInventory('CaelumTrucazoChoice'));}
    static CaelumTrucazoChoice Get(CaelumPlayer user)
    {
        let choice=Read(user);
        if(choice==null)choice=CaelumTrucazoChoice(user.GiveInventoryType('CaelumTrucazoChoice'));
        if(choice!=null && choice.Revision==0)
        {
            let record=user.GetPersistentCharacterState(false);
            for(int i=0;i<22;i++)choice.Selected[i]=CaelumTarotService.HasTarotCard(record,i) && record.TarotSelected[i];
            choice.Revision=CaelumTrucazoData.REVISION;
        }
        return choice;
    }
    clearscope int Count() const
    {int n=0;for(int i=0;i<22;i++)if(Selected[i])n++;return n;}
    bool Toggle(CaelumPlayer user,int card)
    {
        let record=user.GetPersistentCharacterState(false);
        if(card<0 || card>=22 || !CaelumTarotService.HasTarotCard(record,card))return false;
        if(!Selected[card] && Count()>=CaelumTarotLoadout.Capacity(record))return false;
        Selected[card]=!Selected[card];return true;
    }
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE -INVENTORY.INVBAR}
}

class CaelumTrucazoGame : Object play
{
    enum PhaseKind { PREPARATION, PLAYING, TRICK_RESULT, HAND_RESULT, MATCH_DONE }
    enum ExtraAction { PASS=100, AUTO_PASS, SENSE, ANSWER_YES, ANSWER_NO, MAJOR_BASE=200 }
    int Revision,Serial,Phase,Mano,Turn,Trick,HandNumber,Winner,HandWinner;
    CaelumCardDuel Duel;
    Array<CaelumTrucazoSeatState> Seats;
    Array<int> Deck,Discards;
    int Drawn;
    double Health[2],Maximum[2];
    int Points[2],Tricks[2],Damage[2];
    int TrucoValue,TrucoRight,Pending,Caller,Responder,Bid,RefusalPoints,EnvidoCount;
    int SuspendedCaller,SuspendedBid,SuspendedRefusal;
    bool RealCalled,EnvidoSettled,Abandoned,MagicEnabled,SensesEnabled;
    bool Window,Justice;
    int Priority,PassMask,RootSeat,RootOperation,RootArgument;
    Array<CaelumTrucazoEffect> Stack;
    int QuerySeat,QueryTarget,QueryCard,QueryReturnPriority;
    String PublicKey;
    int PublicSeat,PublicCard,PublicAnswer;

    clearscope int Count() const {return int(Seats.Size());}
    clearscope int Team(int seat) const {return seat%2;}
    clearscope int FullMask() const {return (1<<Count())-1;}
    clearscope bool Finished() const {return Phase==MATCH_DONE;}
    clearscope CaelumPlayer Member(int seat) const {return Duel.Member(seat);}
    clearscope bool HasEffect(int team,int card) const
    {for(int i=0;i<Count();i++)if(Team(i)==team && Seats[i].Active[card])return true;return false;}
    clearscope int NextRival(int seat) const
    {for(int i=1;i<Count();i++)if(Team((seat+i)%Count())!=Team(seat))return (seat+i)%Count();return -1;}
    static CaelumTrucazoGame Create(CaelumCardDuel duel)
    {
        let game=new('CaelumTrucazoGame');game.Duel=duel;game.Revision=CaelumTrucazoData.REVISION;
        game.MagicEnabled=duel.Majors;game.SensesEnabled=duel.Senses;
        for(int i=0;i<duel.Count();i++)
        {
            let seat=new('CaelumTrucazoSeatState');seat.Cards=new('CaelumTrucazoSide');
            let user=duel.Member(i);let record=user.GetPersistentCharacterState(false);let choice=CaelumTrucazoChoice.Get(user);
            seat.Cards.MaximumHealth=CaelumTrucazoRules.Health(user.Attributes.Patience);
            seat.Cards.Intelligence=user.Attributes.Intelligence;seat.Insight=Max(0.0,user.Attributes.Insight);
            for(int c=0;c<22;c++)seat.Selected[c]=choice!=null && choice.Selected[c] && CaelumTarotService.HasTarotCard(record,c);
            for(int c=22;c<78;c++)seat.Cards.Awake[c]=CaelumTarotService.HasTarotCard(record,c);
            game.Seats.Push(seat);game.Maximum[i%2]+=seat.Cards.MaximumHealth;
        }
        for(int t=0;t<2;t++)game.Health[t]=game.Maximum[t];
        game.Mano=Random[CaelumTrucazo](0,game.Count()-1);game.Deal();game.CheckEnd();return game;
    }
    void CheckEnd()
    {
        if(Health[0]>0 && Health[1]>0)return;
        Winner=Health[0]<=0 && Health[1]<=0?Team(Mano):Health[0]>0?0:1;
        Phase=MATCH_DONE;Window=false;Pending=0;Stack.Clear();QuerySeat=-1;
    }
    void DealCard(int seat,bool first)
    {
        if(Drawn>=int(Deck.Size()))return;
        int card=Deck[Drawn++];let own=Seats[seat].Cards;
        if(CaelumTrucazoRules.Playable(card))own.Hand.Push(card);
        else if(first)own.FirstRow.Push(card);else own.SecondRow.Push(card);
    }
    void Deal()
    {
        if(HandNumber>0)Mano=(Mano+1)%Count();
        HandNumber++;Trick=0;Turn=Mano;Winner=-1;HandWinner=-1;
        TrucoValue=1;TrucoRight=-1;Pending=0;EnvidoCount=0;RealCalled=false;EnvidoSettled=false;
        SuspendedCaller=-1;QuerySeat=-1;Stack.Clear();Justice=false;PublicKey="CA_TC2_DEALT";
        for(int t=0;t<2;t++){Points[t]=0;Tricks[t]=0;Damage[t]=0;}
        for(int i=0;i<Count();i++)
        {
            let seat=Seats[i];seat.Cards.ClearHand();seat.Played=-1;seat.SenseSpent=false;
            seat.PlayedEmperor=false;seat.PlayedChariot=false;seat.PlayedMoon=false;seat.PrivateKey="";
            for(int c=0;c<22;c++){seat.Spent[c]=false;seat.Active[c]=false;}
        }
        Deck.Clear();Discards.Clear();Drawn=0;
        for(int c=22;c<78;c++)Deck.Push(c);
        for(int i=int(Deck.Size())-1;i>0;i--)
        {int j=Random[CaelumTrucazo](0,i),v=Deck[i];Deck[i]=Deck[j];Deck[j]=v;}
        for(int c=0;c<CaelumTrucazoRules.INITIAL_CARDS;c++)for(int i=0;i<Count();i++)DealCard((Mano+i)%Count(),true);
        for(int i=0;i<Count();i++)
        {int s=(Mano+i)%Count();while(Seats[s].Cards.Hand.Size()<CaelumTrucazoRules.MINIMUM_PLAYABLE && Drawn<int(Deck.Size()))DealCard(s,false);}
        Phase=PREPARATION;Window=true;Priority=Mano;PassMask=0;RootOperation=-1;
        if(!MagicEnabled)FinishPreparation();else SkipAutomatic();
    }
    void FinishPreparation()
    {
        for(int i=0;i<Count();i++)Seats[i].BaseEnvido=Seats[i].Cards.EnvidoValue();
        Phase=PLAYING;Window=false;Turn=Mano;
    }
    clearscope int Envido(int seat) const
    {return Seats[seat].BaseEnvido+(Seats[seat].Active[6]?CaelumTrucazoData.LOVERS_ENVIDO:0);}
    clearscope int BestEnvidoSeat(int team) const
    {
        int best=-1;
        for(int i=0;i<Count();i++){int s=(Mano+i)%Count();if(Team(s)==team && (best<0 || Envido(s)>Envido(best)))best=s;}
        return best;
    }
    clearscope bool CanEnvido(int seat) const
    {
        if(Phase!=PLAYING || EnvidoSettled || Trick!=0 || Seats[seat].Played>=0)return false;
        if(Pending==CaelumTrucazoRules.ENVIDO_CALL && RealCalled)return false;
        return Pending!=0?seat==Responder:seat==Turn;
    }
    clearscope bool CanNormal(int seat,int operation,int argument=0) const
    {
        if(seat<0 || seat>=Count() || Finished())return false;
        if(operation==CaelumTrucazoRules.FORFEIT)return true;
        if(Window || QuerySeat>=0)return false;
        if(operation==CaelumTrucazoRules.ADVANCE)return Phase==HAND_RESULT || Phase==TRICK_RESULT;
        if(Phase!=PLAYING)return false;
        if(operation==CaelumTrucazoRules.ACCEPT || operation==CaelumTrucazoRules.REFUSE)return Pending!=0 && seat==Responder;
        if(operation==CaelumTrucazoRules.ENVIDO)return CanEnvido(seat) && EnvidoCount<CaelumTrucazoRules.MAX_ENVIDOS;
        if(operation==CaelumTrucazoRules.REAL_ENVIDO)return CanEnvido(seat) && !RealCalled;
        if(operation==CaelumTrucazoRules.TRUCO)
            return Pending==CaelumTrucazoRules.ENVIDO_CALL?false:Pending!=0?seat==Responder && Bid<4:
                seat==Turn && TrucoValue<4 && (TrucoRight<0 || TrucoRight==Team(seat));
        return operation==CaelumTrucazoRules.PLAY_CARD && Pending==0 && seat==Turn && Seats[seat].Played<0
            && argument>=0 && argument<int(Seats[seat].Cards.Hand.Size()) && !Seats[seat].Cards.Used[argument];
    }
    clearscope bool HasCard(int seat,int card) const
    {
        for(int i=0;i<int(Seats[seat].Cards.Hand.Size());i++)if(!Seats[seat].Cards.Used[i] && Seats[seat].Cards.Hand[i]==card)return true;
        return false;
    }
    clearscope bool MayUseMagic(int seat) const
    {
        return seat>=0 && seat<Count() && !Finished() && QuerySeat<0
            && (Phase==PREPARATION || Phase==PLAYING) && (Window?seat==Priority:seat==Turn);
    }
    clearscope bool ValidMajor(int seat,int card,int argument,bool resolving=false) const
    {
        if(!MagicEnabled || seat<0 || seat>=Count() || argument<0 || card<0 || card>=22)return false;
        if(!resolving && (!MayUseMagic(seat) || !Seats[seat].Selected[card]
            || Seats[seat].Spent[card] || (card==21 && Seats[seat].WorldSpent)))return false;
        if(CaelumTrucazoData.Preparation(card) && Phase!=PREPARATION)return false;
        let own=Seats[seat].Cards;int t=Team(seat),a=argument/100,b=argument%100;
        if(card==0)
        {
            if(argument<0 || argument>=int(own.Hand.Size()))return false;
            for(int d=Drawn;d<int(Deck.Size());d++)if(CaelumTrucazoRules.Playable(Deck[d]))return true;
            return false;
        }
        if(card==1)return a>=0 && a<int(own.FirstRow.Size()) && b>=0 && b<int(own.SecondRow.Size());
        if(card==12)return argument>=0 && argument<int(own.FirstRow.Size());
        if(card==5)return Stack.Size()>0 && Team(Stack[Stack.Size()-1].Seat)!=t;
        if(card==9)
        {int target=argument/78,c=argument%78;return target>=0 && target<Count() && Team(target)!=t && CaelumTrucazoRules.Playable(c) && !Seats[target].Active[2];}
        if(card==20)
        {int target=argument/22,c=argument%22;return target>=0 && target<Count() && Team(target)!=t && CaelumTrucazoData.Persistent(c) && Seats[target].Active[c];}
        if(card==17)return Health[t]<Maximum[t];
        if(card==15 && Health[t]<=Max(1,CaelumTrucazoData.Rounded(Maximum[t]*CaelumTrucazoData.DEVIL_COST/100.0)))return false;
        if(card==8)return Phase==PLAYING && !Justice;
        if(card==14)return !HasEffect(t,14) && (TrucoValue>1 || Pending==CaelumTrucazoRules.TRUCO_CALL || (Window && RootOperation==CaelumTrucazoRules.TRUCO));
        if(card==6 || card==19)return !EnvidoSettled;
        if(card==10)return own.FirstRow.Size()>0 || own.SecondRow.Size()>0;
        if(card==3 || card==13 || card==15 || card==16 || card==21)return !HasEffect(t,card);
        return !Seats[seat].Active[card];
    }
    void Heal(int team,int percent)
    {if(Health[team]>0)Health[team]=Min(Maximum[team],Health[team]+CaelumTrucazoData.Rounded(Maximum[team]*percent/100.0));}
    void ApplyMajor(CaelumTrucazoEffect effect)
    {
        int s=effect.Seat,c=effect.Card,arg=effect.Argument,t=Team(s);let own=Seats[s].Cards;
        PublicKey="CA_TC2_EFFECT";PublicSeat=s;PublicCard=c;
        if(c==0)
        {
            // El descarte conserva identidad; el mazo no se reconstruye ni se duplica.
            Discards.Push(own.Hand[arg]);
            while(Drawn<int(Deck.Size()))
            {int drawn=Deck[Drawn++];if(CaelumTrucazoRules.Playable(drawn)){own.Hand[arg]=drawn;break;}own.SecondRow.Push(drawn);}
        }
        else if(c==1){int a=arg/100,b=arg%100,v=own.FirstRow[a];own.FirstRow[a]=own.SecondRow[b];own.SecondRow[b]=v;}
        else if(c==5){if(Stack.Size()>0 && Team(Stack[Stack.Size()-1].Seat)!=t)Stack.Pop();}
        else if(c==9)
        {
            int target=arg/78,card=arg%78;
            Seats[s].PrivateKey=Seats[target].Active[2]?"CA_TC2_BLOCKED":HasCard(target,card)?"CA_TC2_HAS":"CA_TC2_ABSENT";
            Seats[s].PrivateTarget=target;Seats[s].PrivateCard=card;
        }
        else if(c==10)
        {Array<int> temp;temp.Copy(own.FirstRow);own.FirstRow.Copy(own.SecondRow);own.SecondRow.Copy(temp);}
        else if(c==12){own.SecondRow.Push(own.FirstRow[arg]);own.FirstRow.Delete(arg);}
        else if(c==17)Heal(t,CaelumTrucazoData.STAR_HEAL);
        else if(c==20)
        {Seats[arg/22].Active[arg%22]=false;Justice=HasEffect(0,8) || HasEffect(1,8);}
        else
        {
            if(c==15)Health[t]-=Max(1,CaelumTrucazoData.Rounded(Maximum[t]*CaelumTrucazoData.DEVIL_COST/100.0));
            if(c==8)Justice=true;
            Seats[s].Active[c]=true;
        }
    }
    void SkipAutomatic()
    {
        if(QuerySeat>=0)return;
        int inspected=0;
        while(Window && inspected<Count() && Seats[Priority].AutoPass)
        {PassMask|=1<<Priority;Priority=(Priority+1)%Count();inspected++;if(PassMask==FullMask()){ResolveWindow();return;}}
    }
    void ResolveWindow()
    {
        if(Stack.Size()>0)
        {
            let effect=Stack[Stack.Size()-1];Stack.Pop();
            // Revalidar índices y costes tras las respuestas evita referencias vencidas.
            if(ValidMajor(effect.Seat,effect.Card,effect.Argument,true))ApplyMajor(effect);
            else
            {Seats[effect.Seat].Spent[effect.Card]=false;if(effect.Card==21)Seats[effect.Seat].WorldSpent=false;}
            // Cada efecto pendiente recibe su propia ronda de respuesta.
            PassMask=0;Priority=Mano;SkipAutomatic();return;
        }
        Window=false;
        if(Phase==PREPARATION){FinishPreparation();return;}
        if(RootOperation>=0){int s=RootSeat,op=RootOperation,arg=RootArgument;RootOperation=-1;Execute(s,op,arg);}
    }
    bool Act(int seat,int operation,int argument=0)
    {
        if(seat<0 || seat>=Count())return false;
        if(operation==AUTO_PASS){if(Finished())return false;Seats[seat].AutoPass=!Seats[seat].AutoPass;SkipAutomatic();return true;}
        if(operation==ANSWER_YES || operation==ANSWER_NO)
        {
            if(QuerySeat<0 || seat!=QueryTarget)return false;
            int ask=QuerySeat;bool answer=operation==ANSWER_YES,truth=HasCard(seat,QueryCard);
            double chance=Seats[seat].Insight<=0?(Seats[ask].Insight<=0?CaelumTrucazoData.SENSE_CHANCE:1.0)
                :Min(1.0,CaelumTrucazoData.SENSE_CHANCE*Seats[ask].Insight/Seats[seat].Insight);
            bool success=FRandom[CaelumTrucazoSenses](0.0,1.0)<chance;
            Seats[ask].PrivateKey=success?(answer==truth?"CA_TC2_TRUTH":"CA_TC2_LIE"):"CA_TC2_UNCLEAR";
            Seats[ask].PrivateTarget=seat;Seats[ask].PrivateCard=QueryCard;
            PublicKey="CA_TC2_ANSWER";PublicSeat=seat;PublicCard=QueryCard;PublicAnswer=int(answer);QuerySeat=-1;SkipAutomatic();
            return true;
        }
        if(operation==PASS)
        {
            if(!Window || QuerySeat>=0 || seat!=Priority)return false;
            PassMask|=1<<seat;Priority=(Priority+1)%Count();
            if(PassMask==FullMask())ResolveWindow();else SkipAutomatic();return true;
        }
        if(operation>=MAJOR_BASE && operation<MAJOR_BASE+22)
        {
            int c=operation-MAJOR_BASE;if(!ValidMajor(seat,c,argument))return false;
            Seats[seat].Spent[c]=true;if(c==21)Seats[seat].WorldSpent=true;
            let effect=new('CaelumTrucazoEffect');effect.Seat=seat;effect.Card=c;effect.Argument=argument;Stack.Push(effect);
            if(!Window)RootOperation=-1;
            Window=true;Priority=Mano;PassMask=0;SkipAutomatic();return true;
        }
        if(operation==SENSE)
        {
            int target=argument/78,c=argument%78;
            if(!SensesEnabled || !MayUseMagic(seat) || Phase!=PLAYING || Seats[seat].SenseSpent
                || target<0 || target>=Count() || Team(target)==Team(seat) || !CaelumTrucazoRules.Playable(c) || Seats[target].Active[2])return false;
            Seats[seat].SenseSpent=true;QuerySeat=seat;QueryTarget=target;QueryCard=c;
            PublicKey="CA_TC2_QUERY";PublicSeat=seat;PublicCard=c;return true;
        }
        if(!CanNormal(seat,operation,argument))return false;
        if(operation==CaelumTrucazoRules.FORFEIT)
        {Winner=1-Team(seat);Abandoned=true;Phase=MATCH_DONE;Window=false;QuerySeat=-1;Stack.Clear();return true;}
        if(operation==CaelumTrucazoRules.ADVANCE){Execute(seat,operation,argument);return true;}
        if(!MagicEnabled){Execute(seat,operation,argument);return true;}
        RootSeat=seat;RootOperation=operation;RootArgument=argument;Window=true;Priority=Mano;PassMask=0;SkipAutomatic();return true;
    }
    clearscope double Row(int seat,bool attack) const
    {return Seats[seat].Cards.RowValue(attack)*(attack && Seats[seat].Active[11]?1.0+CaelumTrucazoData.STRENGTH_ATTACK/100.0:1.0);}
    clearscope double TeamRow(int team,bool attack) const
    {
        double value=0;for(int i=0;i<Count();i++)if(Team(i)==team)value+=Row(i,attack);
        if(!attack && HasEffect(1-team,16))value*=1.0-CaelumTrucazoData.TOWER_DEFENSE/100.0;return value;
    }
    clearscope double Intelligence(int team) const
    {double n=0,total=0;for(int i=0;i<Count();i++)if(Team(i)==team){n++;total+=Seats[i].Cards.Intelligence;}return total/Max(1.0,n);}
    void FinishHand(int victor,int award)
    {
        if(TrucoValue>1 && HasEffect(1-victor,14))award=Max(1,award-CaelumTrucazoData.TEMPERANCE_POINTS);
        Points[victor]+=award;HandWinner=victor;
        for(int t=0;t<2;t++)
        {
            double factor=new('CaelumDerivedStats').CalculateType1Percent(Max(0.0,Intelligence(t)))/100.0;
            double base=Points[t]<=0?0:Max(0.0,TeamRow(t,true)*Points[t]-TeamRow(1-t,false))*factor;
            int bonus=(HasEffect(t,15)?CaelumTrucazoData.DEVIL_DAMAGE:0)+(HasEffect(t,21)?CaelumTrucazoData.WORLD_DAMAGE:0);
            int defense=(HasEffect(1-t,21)?CaelumTrucazoData.WORLD_DEFENSE:0)+(victor==t && HasEffect(1-t,13)?CaelumTrucazoData.DEATH_DEFENSE:0);
            Damage[t]=CaelumTrucazoData.Rounded(base*Max(0.0,1.0+(bonus-defense)/100.0));
        }
        for(int t=0;t<2;t++)Health[1-t]=Max(0.0,Health[1-t]-Damage[t]);
        if(HasEffect(victor,3))Heal(victor,CaelumTrucazoData.EMPRESS_HEAL);
        Phase=HAND_RESULT;Pending=0;CheckEnd();
    }
    void ResolveEnvido(int victor,int award)
    {
        Points[victor]+=award+(HasEffect(victor,19)?CaelumTrucazoData.SUN_POINTS:0);EnvidoSettled=true;Pending=0;
        if(SuspendedCaller>=0)
        {Caller=SuspendedCaller;Responder=NextRival(Caller);Bid=SuspendedBid;RefusalPoints=SuspendedRefusal;Pending=CaelumTrucazoRules.TRUCO_CALL;SuspendedCaller=-1;}
    }
    void Execute(int seat,int operation,int argument)
    {
        if(operation==CaelumTrucazoRules.ADVANCE)
        {
            if(Phase==HAND_RESULT)Deal();
            else
            {
                Trick++;Phase=PLAYING;Justice=false;
                for(int i=0;i<Count();i++)
                {
                    if(Seats[i].PlayedEmperor)Seats[i].Active[4]=false;
                    if(Seats[i].PlayedChariot)Seats[i].Active[7]=false;
                    if(Seats[i].PlayedMoon)Seats[i].Active[18]=false;
                    Seats[i].Played=-1;Seats[i].PlayedEmperor=false;Seats[i].PlayedChariot=false;Seats[i].PlayedMoon=false;Seats[i].Active[8]=false;
                }
            }
            return;
        }
        if(operation==CaelumTrucazoRules.TRUCO)
        {
            if(Pending==CaelumTrucazoRules.TRUCO_CALL)TrucoValue=Bid;
            RefusalPoints=TrucoValue;Bid=TrucoValue+1;Caller=seat;Responder=NextRival(seat);Pending=CaelumTrucazoRules.TRUCO_CALL;return;
        }
        if(operation==CaelumTrucazoRules.ENVIDO || operation==CaelumTrucazoRules.REAL_ENVIDO)
        {
            if(Pending==CaelumTrucazoRules.TRUCO_CALL){SuspendedCaller=Caller;SuspendedBid=Bid;SuspendedRefusal=RefusalPoints;}
            int previous=Pending==CaelumTrucazoRules.ENVIDO_CALL?Bid:0;RefusalPoints=Max(1,previous);
            bool real=operation==CaelumTrucazoRules.REAL_ENVIDO;Bid=previous+(real?CaelumTrucazoRules.REAL_POINTS:CaelumTrucazoRules.ENVIDO_POINTS);
            if(real)RealCalled=true;else EnvidoCount++;
            Caller=seat;Responder=NextRival(seat);Pending=CaelumTrucazoRules.ENVIDO_CALL;return;
        }
        if(operation==CaelumTrucazoRules.ACCEPT || operation==CaelumTrucazoRules.REFUSE)
        {
            bool accept=operation==CaelumTrucazoRules.ACCEPT;
            if(Pending==CaelumTrucazoRules.TRUCO_CALL)
            {if(!accept)FinishHand(Team(Caller),RefusalPoints);else{TrucoValue=Bid;TrucoRight=Team(seat);Pending=0;}}
            else
            {
                int a=BestEnvidoSeat(0),b=BestEnvidoSeat(1);
                int win=Envido(a)==Envido(b)?Team(Mano):Envido(a)>Envido(b)?0:1;
                ResolveEnvido(accept?win:Team(Caller),accept?Bid:RefusalPoints);
            }
            return;
        }
        let own=Seats[seat];own.Cards.Used[argument]=true;own.Played=own.Cards.Hand[argument];
        own.PlayedEmperor=own.Active[4];own.PlayedChariot=own.Active[7];own.PlayedMoon=own.Active[18];
        for(int i=1;i<=Count();i++){int next=(seat+i)%Count();if(Seats[next].Played<0){Turn=next;return;}}
        int best=-1,strength=100;
        for(int i=0;i<Count();i++)
        {
            int s=(Mano+i)%Count(),power=CaelumTrucazoRules.Strength(Seats[s].Played);
            if(!Justice && Seats[s].PlayedEmperor && Seats[s].Active[4])power=Max(1,power-CaelumTrucazoData.EMPEROR_STRENGTH);
            if(power<strength){best=s;strength=power;}
        }
        int team=Team(best);Tricks[team]++;Turn=best;
        if(Seats[best].PlayedChariot && Seats[best].Active[7])Points[team]+=CaelumTrucazoData.CHARIOT_POINTS;
        if(Tricks[team]>=CaelumTrucazoRules.TRICKS_TO_WIN)FinishHand(team,TrucoValue);else Phase=TRICK_RESULT;
    }
    clearscope bool HiddenPlayed(int seat) const
    {if(!Seats[seat].PlayedMoon || !Seats[seat].Active[18])return false;for(int i=0;i<Count();i++)if(Seats[i].Played<0)return true;return false;}
}
