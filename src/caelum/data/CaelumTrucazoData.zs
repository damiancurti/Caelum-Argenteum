// #443: reglamento aprobado por el autor el 08/11/2026; valores fuera de la lógica.
class CaelumTrucazoData : Object
{
    const REVISION=1;
    const ROSTER_REVISION=1;
    const MAX_SEATS=8;
    const WAGER_REVISION=1;
    const REPUTATION_WIN=5;
    const REPUTATION_MAX=1000;
    // Límite técnico de las transacciones enteras nativas, no tope de saldo.
    const MAX_COPPER_OPERATION=2147483647;
    const RATING_REVISION=1;
    const RATING_INITIAL=1000;
    const RATING_K=32;
    const RATING_SCALE=400;
    const RATING_MIN_DELTA=1;
    const RATING_FLOOR=0;
    const RATING_EXPERT=1200;
    const RATING_MASTER=1400;
    const RATING_GRANDMASTER=1600;
    const TOURNAMENT_REVISION=1;
    static clearscope int Rank(double rating)
    {return rating<RATING_INITIAL?0:rating<RATING_EXPERT?1:rating<RATING_MASTER?2:rating<RATING_GRANDMASTER?3:4;}
    static clearscope int TournamentThreshold(int tier)
    {return tier==0?RATING_EXPERT:RATING_GRANDMASTER;}
    const EMPRESS_HEAL=10;
    const EMPEROR_STRENGTH=1;
    const LOVERS_ENVIDO=2;
    const CHARIOT_POINTS=1;
    const STRENGTH_ATTACK=25;
    const DEATH_DEFENSE=25;
    const TEMPERANCE_POINTS=1;
    const DEVIL_COST=5;
    const DEVIL_DAMAGE=25;
    const TOWER_DEFENSE=25;
    const STAR_HEAL=5;
    const SUN_POINTS=1;
    const WORLD_DAMAGE=20;
    const WORLD_DEFENSE=20;
    const SENSE_CHANCE=0.5;
    static clearscope bool Preparation(int card)
    {return card==0 || card==1 || card==10 || card==12 || card==17;}
    static clearscope bool Persistent(int card)
    {return card>=0 && card<22 && card!=0 && card!=1 && card!=5 && card!=9 && card!=10 && card!=12 && card!=17 && card!=20;}
    static clearscope String Name(int card)
    {return CaelumTarotArt.DisplayName(card);}
    static clearscope int Rounded(double value)
    {return int(floor(Max(0.0,value)+0.5));}
}
