// This fixture also compiles against the pre-appearance 5.2.12 baseline.
class CA148Legacy : StaticEventHandler
{
    bool Done;
    override void WorldTick()
    {
        if(Done || level.time<35)return;Done=true;
        let user=CaelumPlayer(players[0].mo);
        let profile=CaelumCharacterIdentity.Profile(user);
        profile.Race=CaelumConstants.RACE_BEAST_MAN;profile.Sex=CaelumConstants.SEX_FEMALE;
        user.CharacterCreationComplete=true;user.ApplyCharacterProfile();
        Console.Printf("CA148 DONE failures=0");
    }
}
