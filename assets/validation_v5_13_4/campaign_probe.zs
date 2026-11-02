class CA597PresetProbe : StaticEventHandler
{
    bool Done;
    void Check(bool ok,String label){Console.Printf("CA597P %s %s",ok?"PASS":"FAIL",label);}
    override void WorldTick()
    {
        if(Done || level.time<175 || players[0].mo==null || players[1].mo==null)return;
        Done=true;
        for(int slot=0;slot<2;slot++)
        {
            let user=CaelumPlayer(players[slot].mo);
            Check(user!=null && !(user is 'CaelumStandalonePlayer'),"ordinary native launch retains campaign player class");
            if(user==null)continue;
            Check(user.CharacterProfile.Standalone==null,"campaign has no resident snapshot");
            Check(user.CharacterCreationComplete && user.CharacterProfile.Race==CaelumConstants.RACE_HUMAN
                && user.CharacterProfile.FirstClass==CaelumConstants.CLASS_WARRIOR
                && user.CharacterProfile.SecondClass==CaelumConstants.CLASS_MAGE,"ordinary direct-map profile remains unchanged");
            let record=user.GetPersistentCharacterState(false);
            Check(record!=null && record.ProfileCommitted && record.IdentityProfile.Standalone==null,"ordinary personal record remains committed");
            Check(user.health>0 && user.DerivedStats.MaximumHealth>0 && user.CurrentAnima>0,"ordinary physiology initializes");
        }
        Console.Printf("CA597P RESULT presets");
    }
}
