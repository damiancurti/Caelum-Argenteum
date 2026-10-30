class CA430LegacyCheck : Object play
{
    static bool EmptyParty()
    {
        let party=CaelumCompanionParty.Get(CaelumPlayer(players[0].mo));
        return party==null || party.Roster.Size()==0;
    }
}
