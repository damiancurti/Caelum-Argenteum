class CA502WeatherChecks : EventHandler
{
    Actor Probe;
    CaelumContaminationTile Saved;
    double SavedArea;
    int Passed,Failed;
    override void WorldLoaded(WorldEvent e)
    {
        if(!e.IsSaveGame && !e.IsReopen)
        {let marker=Actor.Spawn('CaelumClimateRegion',(16,16,0),NO_REPLACE);marker.args[0]=1;marker.args[1]=5;}
    }
    override void WorldTick()
    {
        let u=CaelumPlayer(players[0].mo);if(u==null)return;
        u.CharacterCreationComplete=true;u.CreationWizardOpen=false;u.bInvulnerable=true;
        u.GetPersistentCharacterState(true).SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_UNKNOWN_VOICE_HEARD);
        u.A_SetBlend("Black",0,1);
        if(Probe==null)Probe=Actor.Spawn('CA502WeatherProp',(176,128,0),NO_REPLACE);
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=='ca502w_oldseed')
        {
            CaelumContaminationStorage.Set(Probe,77);Saved=new('CaelumContaminationTile');Saved.Concentration=77;
            Console.Printf("CA502W PASS original revision2 package seeds actual exterior actor");
        }
        else if(e.Name=='ca502w_oldcheck')
        {
            bool ok=Probe!=null && Saved!=null && Abs(CaelumContaminationStorage.Value(Probe)-Saved.Concentration)<0.001;
            Console.Printf("CA502W %s original save reopens in unchanged original runtime",ok?"PASS":"FAIL");
        }
        else return;
        Console.Printf("CA502W RESULT legacy");
    }
}
class CA502WeatherProp : Actor
{Default {Radius 8;Height 16;+SOLID +NOGRAVITY} States {Spawn:TNT1 A -1;Stop;}}
