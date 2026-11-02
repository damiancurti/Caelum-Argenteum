// #441: el mundo ofrece una captura; nunca entrega la esencia directamente.
class CaelumArcanaSources : Object play
{
    static bool Ready()
    {
        let clock=CaelumWorldClockTicker(StaticEventHandler.Find('CaelumWorldClockTicker'));
        return clock!=null && level.time>clock.ArcanaSourcesReadyAfter;
    }

    static bool AdditionalCard(int card)
    {
        return card > CaelumConstants.TAROT_THE_FOOL && card < CaelumConstants.TAROT_CARD_COUNT
            && card != CaelumConstants.TAROT_CUPS_ACE && card != CaelumConstants.TAROT_WANDS_KNIGHT;
    }

    static CaelumM00FoolEssence Find(int card)
    {
        if(card < 0 || card >= CaelumConstants.TAROT_CARD_COUNT)return null;
        let clock=CaelumWorldClockTicker(StaticEventHandler.Find('CaelumWorldClockTicker'));
        return clock==null?null:clock.ArcanaSources[card];
    }

    static void Register(CaelumM00FoolEssence essence)
    {
        if(essence==null)return;
        int card=essence.CardId();
        if(card<0 || card>=CaelumConstants.TAROT_CARD_COUNT)return;
        let clock=CaelumWorldClockTicker(StaticEventHandler.Find('CaelumWorldClockTicker'));
        if(clock!=null && clock.ArcanaSources[card]==null)clock.ArcanaSources[card]=essence;
    }

    static void Forget(CaelumM00FoolEssence essence)
    {
        if(essence==null)return;
        let clock=CaelumWorldClockTicker(StaticEventHandler.Find('CaelumWorldClockTicker'));
        if(clock==null)return;
        int card=essence.CardId();
        if(card>=0 && card<CaelumConstants.TAROT_CARD_COUNT && clock.ArcanaSources[card]==essence)
            clock.ArcanaSources[card]=null;
    }

    // El llamador aporta una ubicación escrita para su misión. Reintentar o
    // premiar a varios participantes reutiliza la misma instancia del mapa.
    static CaelumRewardEssence PlaceReward(CaelumPlayer user,int card,Vector3 authoredSpot)
    {
        if(!Ready() || !CaelumPlayerAuthority.CanMutate(user) || !AdditionalCard(card))return null;
        let record=user.GetPersistentCharacterState(false);
        if(record==null || record.HasTarotCard(card))return null;
        let source=CaelumRewardEssence(Find(card));
        if(source==null)
        {
            source=CaelumRewardEssence(Actor.Spawn('CaelumRewardEssence',authoredSpot,NO_REPLACE));
            if(source==null)return null;
            source.EssenceCard=card;source.Configured=true;
            source.SetOrigin((authoredSpot.X,authoredSpot.Y,source.FloorZ),false);
            Register(source);
        }
        record.ArcanaAvailable[card]=true;
        CaelumArcanaProgress.UpdateEssence(source);
        user.PersistCharacterState();
        return source;
    }
}

class CaelumRewardEssence : CaelumM00FoolEssence
{
    int EssenceCard;
    bool Configured;
    override int CardId(){return Configured?EssenceCard:-1;}
    override void Tick()
    {
        if(Configured)CaelumArcanaProgress.UpdateEssence(self);
        Super.Tick();
    }
    Default {+INVISIBLE -SOLID}
}
