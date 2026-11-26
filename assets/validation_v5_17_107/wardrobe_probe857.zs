// First native compilation/JIT probe; equipment behavior is checked separately.
class CA857WardrobeProbe : EventHandler
{
    int Checks,Failures;
    void Check(bool okay,String label)
    {Checks++;if(!okay)Failures++;Console.Printf("CA836 EDGE %s wardrobe: %s",okay?"PASS":"FAIL",label);}
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!='ca857check')return;
        let user=CaelumDomingoPilotPlayer(players[0].mo);
        Check(user!=null,"existing opt-in player class starts natively");
        if(user==null)return;
        let old=user.PilotBody;
        let body=CaelumWardrobePilotBody(Actor.Spawn('CaelumWardrobePilotBody',user.Pos,NO_REPLACE));
        Check(body!=null,"candidate body spawns");
        if(body==null)return;
        body.Master=user;user.PilotBody=body;body.Sync(user);body.UpdateVisual();
        Check(body.WardrobeRevision==1 && body.SnapshotReady && body.BindingsReady,"selection and model-binding functions execute natively");
        user.PilotBody=old;body.Destroy();
        Console.Printf("CA836 EDGE_RESULT checks=%d failures=%d result=%s",Checks,Failures,Failures==0?"PASS":"FAIL");
    }
}
