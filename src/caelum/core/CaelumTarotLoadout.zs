// El orden pertenece al personaje; el cursor nunca decide la secuencia pagada.
class CaelumTarotLoadout : Object play
{
    static void Ensure(CaelumPersistentCharacterState record)
    {
        if(record==null || record.TarotLoadoutRevision>=CaelumMajorArcanaData.LOADOUT_REVISION)return;
        record.TarotOrderCount=0;
        for(int card=0;card<CaelumConstants.TAROT_CARD_COUNT;card++)
        {
            if(record.TarotSelected[card])record.TarotOrder[record.TarotOrderCount++]=card;
            record.TarotRemaining[card]=record.TarotActive[card]?Max(0,record.TarotEffectTics):0;
        }
        record.TarotLoadoutRevision=CaelumMajorArcanaData.LOADOUT_REVISION;
    }

    static clearscope bool Passive(CaelumPersistentCharacterState record,int card)
    {
        return card>=0 && card<CaelumConstants.TAROT_MAJOR_COUNT
            && CaelumTarotService.HasTarotCard(record,card);
    }

    // Los activos siguen dependiendo de la secuencia; El Mundo puede incluirlos.
    static clearscope bool InSequence(CaelumPersistentCharacterState record,int card)
    {
        return Passive(record,card) && (CaelumTarotService.IsSelected(record,card)
            || CaelumTarotService.IsSelected(record,21));
    }

    static clearscope int Capacity(CaelumPersistentCharacterState record,int adding=-1)
    {
        return CaelumConstants.TAROT_SELECTED_LIMIT
            +CaelumMajorArcanaData.EXTRA_TAROT_SLOTS*((Passive(record,9)?1:0)
                +(Passive(record,15)?1:0));
    }

    static clearscope int BoxBonus(CaelumPersistentCharacterState record)
    {return CaelumMajorArcanaData.EXTRA_BOX_SLOTS*((Passive(record,17)?1:0)+(Passive(record,19)?1:0));}

    static bool CanRemove(CaelumPlayer user,CaelumPersistentCharacterState record,int card)
    {
        // Quitar una carta de la secuencia no retira una esencia adquirida.
        return true;
    }

    static void Toggle(CaelumPersistentCharacterState record,int card)
    {
        Ensure(record);
        if(record.TarotSelected[card])
        {
            int write=0;
            for(int i=0;i<record.TarotOrderCount;i++)
                if(record.TarotOrder[i]!=card)record.TarotOrder[write++]=record.TarotOrder[i];
            record.TarotOrderCount=write;
        }
        else record.TarotOrder[record.TarotOrderCount++]=card;
        record.TarotSelected[card]=!record.TarotSelected[card];
    }

    static clearscope int Position(CaelumPersistentCharacterState record,int card)
    {
        if(record==null)return 0;
        for(int i=0;i<record.TarotOrderCount;i++)if(record.TarotOrder[i]==card)return i+1;
        return 0;
    }
}
