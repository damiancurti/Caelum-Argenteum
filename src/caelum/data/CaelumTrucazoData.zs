// #443: reglamento aprobado por el autor el 08/11/2026; valores fuera de la lógica.
class CaelumTrucazoData : Object
{
    const REVISION=1;
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
