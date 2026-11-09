// #446: el rating personal es distinto de la reputación; los atributos del mundo no cambian.
class CaelumTrucazoCompetitive : Object play
{
    CaelumCardDuel Duel;
    int Revision;
    bool Applied;
    Array<double> Before,Delta;
    static clearscope double Rating(CaelumPlayer user)
    {
        let record=user==null?null:CaelumPersistentCharacterState(user.FindInventory('CaelumPersistentCharacterState'));
        return record==null || record.TrucazoRatingRevision==0?CaelumTrucazoData.RATING_INITIAL:record.TrucazoRating;
    }
    static clearscope int SelectedCount(CaelumPlayer user)
    {
        let choice=CaelumTrucazoChoice.Read(user);let record=user==null?null:CaelumPersistentCharacterState(user.FindInventory('CaelumPersistentCharacterState'));
        int count=0;for(int c=0;c<22;c++)if(record!=null && (choice!=null?choice.Selected[c]:record.TarotSelected[c]) && CaelumTarotService.HasTarotCard(record,c))count++;
        return count;
    }
    static clearscope int MajorLimit(CaelumCardDuel duel)
    {int limit=22;for(int i=0;i<duel.Count();i++)limit=Min(limit,SelectedCount(duel.Member(i)));return limit;}
    static clearscope bool Eligible(CaelumCardDuel duel)
    {
        if(!duel.Connected() || duel.Game!=CaelumCardDuel.GAME_TRUCAZO)return false;
        int count=MajorLimit(duel);
        for(int i=0;i<duel.Count();i++)
        {
            let user=duel.Member(i);if(user is 'CaelumStandalonePlayer')return false;
            let record=CaelumPersistentCharacterState(user.FindInventory('CaelumPersistentCharacterState'));
            if(record==null)return false;
            if(duel.Majors && (SelectedCount(user)!=count || count>CaelumTarotLoadout.Capacity(record)))return false;
        }
        return true;
    }
    static void Normalize(CaelumTrucazoGame game)
    {
        if(!game.Duel.Ranked)return;
        double patience=game.Member(0).Attributes.Patience,intelligence=game.Member(0).Attributes.Intelligence,insight=game.Member(0).Attributes.Insight;
        for(int i=1;i<game.Count();i++)
        {let user=game.Member(i);patience=Min(patience,user.Attributes.Patience);intelligence=Min(intelligence,user.Attributes.Intelligence);insight=Min(insight,user.Attributes.Insight);}
        game.Maximum[0]=0;game.Maximum[1]=0;
        for(int i=0;i<game.Count();i++)
        {
            let seat=game.Seats[i];seat.Cards.MaximumHealth=CaelumTrucazoRules.Health(patience);seat.Cards.Intelligence=intelligence;seat.Insight=Max(0.0,insight);
            for(int c=22;c<78;c++)seat.Cards.Awake[c]=false;
            game.Maximum[i%2]+=seat.Cards.MaximumHealth;
        }
    }
    static CaelumTrucazoCompetitive Create(CaelumCardDuel duel)
    {
        let result=new('CaelumTrucazoCompetitive');result.Duel=duel;result.Revision=CaelumTrucazoData.RATING_REVISION;
        for(int i=0;i<duel.Count();i++)
        {let record=duel.Member(i).GetPersistentCharacterState(true);record.EnsureTrucazoRating();result.Before.Push(record.TrucazoRating);result.Delta.Push(0);}
        return result;
    }
    static clearscope int Award(double winner,double loser)
    {
        double difference=(loser-winner)/CaelumTrucazoData.RATING_SCALE;
        // Fuera de estos extremos el redondeo entero ya es 32 o 1; evitar desborde exponencial.
        if(difference>=CaelumTrucazoData.RATING_K)return CaelumTrucazoData.RATING_K;
        if(difference<=-CaelumTrucazoData.RATING_K)return CaelumTrucazoData.RATING_MIN_DELTA;
        double expected=1.0/(1.0+10.0**difference);
        return Max(CaelumTrucazoData.RATING_MIN_DELTA,int(floor(CaelumTrucazoData.RATING_K*(1.0-expected)+0.5)));
    }
    void Settle()
    {
        if(Applied || !Duel.Ranked || Duel.Advanced==null || !Duel.Advanced.Finished() || !Duel.Connected())return;
        double means[2];for(int i=0;i<Duel.Count();i++)means[i%2]+=Before[i]/(Duel.Count()/2);
        int winner=Duel.Advanced.Winner,award=Award(means[winner],means[1-winner]);
        for(int i=0;i<Duel.Count();i++)
        {
            let user=Duel.Member(i);let record=user.GetPersistentCharacterState(true);record.EnsureTrucazoRating();
            double previous=record.TrucazoRating;
            record.TrucazoRating=Max(double(CaelumTrucazoData.RATING_FLOOR),previous+(i%2==winner?award:-award));Delta[i]=record.TrucazoRating-previous;
            user.PersistCharacterState();
        }
        Applied=true;
    }
}
