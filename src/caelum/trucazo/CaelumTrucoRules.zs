// #101: Truco argentino a 30, con Flor opcional. Reutiliza los 40 frentes
// equivalentes del mazo físico; ninguna esencia ni atributo modifica sus valores.
class CaelumTrucoRules : CaelumTrucazoRules
{
    const TARGET = 30;
    const MALAS = 15;
    const HAND_CARDS = 3;
    const FLOR_POINTS = 3;
    const CONTRA_POINTS = 6;
    const FLOR_REFUSAL = 4;
    const EARLY_FOLD_POINTS = 1;
    const FLOR_CALL = 3;
    enum TraditionalAction { TOGGLE_FLOR = 12, FALTA_ENVIDO, FLOR,
        CONTRA_FLOR, FLOR_REST, FOLD };
    enum TraditionalEvent { FALTA_EVENT = 12, FLOR_EVENT, CONTRA_EVENT,
        REST_EVENT, FLOR_RESULT_EVENT, FOLD_EVENT };

    static int Rest(int a,int b)
    { return (Max(a,b)<MALAS?MALAS:TARGET)-Max(a,b); }

    // -2 significa que falta jugar; -1 es parda, nunca una victoria automática.
    static int HandVictor(int a,int b,int c,int played,int mano)
    {
        if(played<2)return -2;
        if(a>=0 && (b==a || b==-1))return a;
        if(a==-1 && b>=0)return b;
        if(played<3)return -2;
        if(c>=0)return c;
        return a>=0?a:b>=0?b:mano;
    }

    static int FlorValue(CaelumTrucazoSide own)
    {
        if(own==null || own.Hand.Size()!=HAND_CARDS)return 0;
        int suit=Suit(own.Hand[0]),total=ENVIDO_SUIT_BONUS;
        for(int i=0;i<HAND_CARDS;i++)
        {
            if(Suit(own.Hand[i])!=suit)return 0;
            total+=EnvidoNumber(own.Hand[i],false);
        }
        return total;
    }
}
