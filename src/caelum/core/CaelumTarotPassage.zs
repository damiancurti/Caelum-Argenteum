// Sólo los mapeadores marcan estas hojas; nunca se deducen secretos de paredes
// decorativas ni se recorren todos los sectores al equipar una carta.
class CaelumTarotFalseWall : CaelumSlidingDoorLeaf
{
    static bool Revealed(CaelumPlayer user)
    {return user!=null && CaelumTarotLoadout.Passive(user.GetPersistentCharacterState(false),2);}
}

class CaelumTarotCursedPassage : CaelumSlidingDoorLeaf
{
    int PassageRevision;
    bool Purified;

    override void PostBeginPlay()
    {Super.PostBeginPlay();PassageRevision=CaelumMajorArcanaData.PASSAGE_REVISION;}

    static bool CanPurify(CaelumPlayer user)
    {return CaelumPlayerAuthority.CanMutate(user) && user.health>0
        && CaelumTarotLoadout.Passive(user.GetPersistentCharacterState(false),5);}

    override bool CanOpenPassage(Actor user)
    {
        if(Purified || CanPurify(CaelumPlayer(user)))return true;
        CaelumTarotService.Feedback(CaelumPlayer(user),"CA_TAROT_PASSAGE_REQUIRES");
        return false;
    }

    override void PassageOpened(Actor user)
    {
        // La puerta común ya comprobó cerraduras, escenas y permisos de todo
        // el grupo. No se purifica parcialmente un paso que no puede abrirse.
        if(!Purified && CanPurify(CaelumPlayer(user)))Purified=true;
    }
}
