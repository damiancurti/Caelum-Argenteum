// Regla del mapa actual, sin banderas guardadas ni cambios al resto de mapas.
class CaelumTutorialSafety : Object play
{
    static bool Protects(CaelumPlayer user)
    {
        return user!=null && user.player!=null && user.player.mo==user
            && user.player.playerstate==PST_LIVE
            && level.MapName==CaelumConstants.TUTORIAL_SAFE_MAP;
    }

    static int HealthAfter(CaelumPlayer user,int proposed)
    {
        return Protects(user) ? Max(CaelumConstants.TUTORIAL_MINIMUM_HEALTH,proposed) : proposed;
    }

    static int HealthLoss(CaelumPlayer user,int damage)
    {
        return Protects(user) ? Min(Max(0,damage),Max(0,user.health-CaelumConstants.TUTORIAL_MINIMUM_HEALTH)) : damage;
    }
}
