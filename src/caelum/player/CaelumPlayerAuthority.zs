// #120: un receptor explícito y su cuerpo nativo actual; nunca elegir otro jugador.
// No es un servidor nuevo: GZDoom conserva el transporte y la ejecución play.
class CaelumPlayerAuthority : Object play
{
    static clearscope bool CanRead(CaelumPlayer user)
    { return user != null && user.player != null && user.player.mo == user; }

    static clearscope bool CanMutate(CaelumPlayer user)
    { return CanRead(user) && !(user.player.cheats & CF_PREDICTING); }

    static CaelumPlayer FromNetworkPlayer(int number)
    {
        if (number < 0 || number >= MAXPLAYERS || !playeringame[number]) return null;
        let user = CaelumPlayer(players[number].mo);
        return CanMutate(user) && user.PlayerNumber() == number ? user : null;
    }

    static clearscope bool OwnsRecord(CaelumPlayer user, CaelumPersistentCharacterState record)
    {
        return CanMutate(user) && record != null && record.Owner == user
            && user.FindInventory("CaelumPersistentCharacterState") == record;
    }
}
