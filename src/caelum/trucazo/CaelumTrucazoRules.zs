// #81: datos del reglamento v2.0 y correcciones del autor del 04/10/2026.
// Los índices son los del Tarot existente; no se crean cartas de inventario.
class CaelumTrucazoRules : Object
{
    const REVISION = 1;
    const INITIAL_CARDS = 5;
    const MINIMUM_PLAYABLE = 3;
    const DECK_SIZE = 56;
    const ROW_BASE = 5;
    const ENVIDO_SUIT_BONUS = 20;
    const NPC_ENVIDO_THRESHOLD = 25;
    const TRICKS_TO_WIN = 2;
    const MAX_TRUCO = 4;
    const ENVIDO_POINTS = 2;
    const REAL_POINTS = 3;
    const MAX_ENVIDOS = 2;

    enum MatchPhase { INTRO, PLAYING, TRICK_RESULT, HAND_RESULT, MATCH_RESULT };
    enum CallType { NO_CALL, TRUCO_CALL, ENVIDO_CALL };
    enum MatchAction { BEGIN, PLAY_CARD, TRUCO, ENVIDO, REAL_ENVIDO, ACCEPT, REFUSE,
        ADVANCE, FORFEIT, CLOSE, NPC_STEP };
    enum PublicEvent { DEAL_EVENT, CARD_EVENT, TRUCO_EVENT, ENVIDO_EVENT, REAL_EVENT,
        ACCEPT_EVENT, REFUSE_EVENT, ENVIDO_RESULT_EVENT, TRICK_EVENT, HAND_EVENT,
        DAMAGE_EVENT, FORFEIT_EVENT };

    static int Suit(int card)
    { return CaelumTarotService.Suit(card); }
    static int Rank(int card)
    { return CaelumTarotService.Rank(card); }
    static bool Minor(int card)
    { return CaelumTarotService.Minor(card); }
    static bool Playable(int card)
    { return Minor(card) && Rank(card)!=7 && Rank(card)!=8 && Rank(card)!=9 && Rank(card)!=12; }

    // Menor número = mayor jerarquía. Los empates los resuelve la mano.
    static int Strength(int card)
    {
        if(!Playable(card))return 0;
        int rank=Rank(card), suit=Suit(card);
        if(rank==0 && suit==CaelumConstants.TAROT_SUIT_SWORDS)return 1;
        if(rank==0 && suit==CaelumConstants.TAROT_SUIT_WANDS)return 2;
        if(rank==6 && suit==CaelumConstants.TAROT_SUIT_SWORDS)return 3;
        if(rank==6 && suit==CaelumConstants.TAROT_SUIT_COINS)return 4;
        static const int ordinary[]={7,6,5,14,13,12,11,0,0,0,9,10,0,8};
        return ordinary[rank];
    }
    static int TrickWinner(int a,int b,int mano)
    {
        int ar=Strength(a),br=Strength(b);
        return ar==br?mano:ar<br?0:1;
    }
    static int Number(int card)
    { return Minor(card) && Rank(card)<10?Rank(card)+1:0; }
    static int EnvidoNumber(int card,bool awake)
    { return Playable(card) && Rank(card)<7?Number(card)*(awake?2:1):0; }
    static double Health(double patience) { return Max(0.0,patience)**2; }
    static int Damage(int attack,int defense,int points,double intelligence)
    {
        if(points<=0)return 0;
        double factor=new("CaelumDerivedStats").CalculateType1Percent(Max(0.0,intelligence))/100.0;
        return int(floor(Max(0,attack*points-defense)*factor+0.5));
    }
    static String CardName(int card)
    {
        if(!Minor(card))return "";
        return String.Format(StringTable.Localize("CA_TC_CARD",false),
            StringTable.Localize(String.Format("CA_TC_RANK_%d",Rank(card)),false),
            StringTable.Localize(String.Format("CA_TC_SUIT_%d",Suit(card)),false));
    }
}

// Cada lado conserva su mano original (Envido), sus jugadas y sus dos filas.
class CaelumTrucazoSide : Object
{
    Array<int> Hand;
    Array<int> FirstRow;
    Array<int> SecondRow;
    bool Used[CaelumTrucazoRules.INITIAL_CARDS];
    bool Awake[CaelumConstants.TAROT_CARD_COUNT];
    double Health;
    double MaximumHealth;
    double Intelligence;
    int Tricks;
    int Points;
    int LastDamage;

    void ClearHand()
    {
        Hand.Clear();FirstRow.Clear();SecondRow.Clear();
        for(int i=0;i<CaelumTrucazoRules.INITIAL_CARDS;i++)Used[i]=false;
        Tricks=0;Points=0;LastDamage=0;
    }
    int Remaining() const
    {
        int result=0;
        for(int i=0;i<Hand.Size();i++)if(!Used[i])result++;
        return result;
    }
    int RowValue(bool first) const
    {
        int total=CaelumTrucazoRules.ROW_BASE,queens=0;
        int count=first?FirstRow.Size():SecondRow.Size();
        for(int i=0;i<count;i++)
        {
            int card=first?FirstRow[i]:SecondRow[i];
            int copies=Awake[card]?2:1;
            if(CaelumTrucazoRules.Rank(card)==12)queens+=copies;
            else total+=CaelumTrucazoRules.Number(card)*copies;
        }
        return total*(queens+1);
    }
    int EnvidoValue() const
    {
        int best=0;
        for(int i=0;i<Hand.Size();i++)
        {
            int a=Hand[i];
            int av=CaelumTrucazoRules.EnvidoNumber(a,Awake[a]);
            best=Max(best,av);
            for(int j=i+1;j<Hand.Size();j++)
            {
                int b=Hand[j];
                if(CaelumTrucazoRules.Suit(a)!=CaelumTrucazoRules.Suit(b))continue;
                int bv=CaelumTrucazoRules.EnvidoNumber(b,Awake[b]);
                int left=av,right=bv;
                // La figura despierta copia el valor numérico de su pareja;
                // dos figuras siguen valiendo cero antes de sumar el palo.
                if(CaelumTrucazoRules.Rank(a)>=10 && Awake[a])left=bv;
                if(CaelumTrucazoRules.Rank(b)>=10 && Awake[b])right=av;
                best=Max(best,CaelumTrucazoRules.ENVIDO_SUIT_BONUS+left+right);
            }
        }
        return best;
    }
}

// La política sólo recibe la mano propia y datos públicos, nunca el rival
// ni el mazo. No consulta el estado completo para estimar cartas ocultas.
class CaelumTrucazoNPC : Object
{
    static int ChooseCard(CaelumTrucazoSide own,int publicCard,bool winsTie)
    {
        int best=-1,weakest=-1,winning=-1;
        for(int i=0;i<own.Hand.Size();i++)
        {
            if(own.Used[i])continue;
            int strength=CaelumTrucazoRules.Strength(own.Hand[i]);
            if(best<0 || strength<CaelumTrucazoRules.Strength(own.Hand[best]))best=i;
            if(weakest<0 || strength>CaelumTrucazoRules.Strength(own.Hand[weakest]))weakest=i;
            if(publicCard>=0 && (strength<CaelumTrucazoRules.Strength(publicCard)
                || (winsTie && strength==CaelumTrucazoRules.Strength(publicCard))))
                if(winning<0 || strength>CaelumTrucazoRules.Strength(own.Hand[winning]))winning=i;
        }
        return publicCard<0?best:winning>=0?winning:weakest;
    }
    static bool StrongTruco(CaelumTrucazoSide own)
    {
        if(own.Tricks>0)return true;
        for(int i=0;i<own.Hand.Size();i++)
            if(!own.Used[i] && CaelumTrucazoRules.Strength(own.Hand[i])<=4)return true;
        return false;
    }
    static bool StrongEnvido(CaelumTrucazoSide own)
    { return own.EnvidoValue()>CaelumTrucazoRules.NPC_ENVIDO_THRESHOLD; }
}
