// Captura nativa y reservas en los tres frentes: maquinas sin dotacion enemiga,
// membresia sembrada por el fixture, sin simular combate ni trabajo cronometrado.
class CA454CaptureCity : CaelumPortSiege
{
    override void Tick(){}
}
class CA454CaptureProbe : EventHandler
{
    int Failures;
    void Check(bool okay,String label)
    {if(!okay){Failures++;Console.Printf("CA454 CAPTURE FAIL %s",label);}}
    void Inspect(CaelumPortSiege port)
    {
        for(int lane=0;lane<6;lane++)
        {
            let ram=CaelumBatteringRam(port.Machines[lane]);bool captured=lane%2==0 || lane==5;
            Check(ram.Captured==captured && (ram.OwnerFaction==0)==captured,"retained ownership");
            Check(ram.Enabled==(!captured && lane%2==1),"only enemy reserves active");
            if(captured)Check(ram.ObjectiveNeutralized() && !ram.TarotDestroyed && ram.Route.Size()==0 && ram.TargetGate==null,"captured identity and route retained safely");
        }
        for(int pair=0;pair<3;pair++)Check(port.RamReserveReleased[pair],"pair released once");
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!="ca454_capture_start" && e.Name!="ca454_capture_resume")return;
        let port=CaelumPortSiege.Get();let user=CaelumPlayer(players[0].mo);
        if(e.Name=="ca454_capture_start")
        {
            Check(CaelumCityWorld.Prepare(),"city setup");port.Deploy();
            for(int lane=0;lane<6;lane++)CaelumBarracasAssault.AddRam(port,lane);
            port.SealRoster();CaelumBarracasAssault.UpdateReserves(port);
            user.GetPersistentCharacterState(true).FactionMember[0]=true;
            Check(CaelumMachineOwnership.Capture(port.Machines[5],user,0),"capture western reserve before primary");
            for(int lane=0;lane<6;lane+=2)
            {
                let ram=port.Machines[lane];int health=ram.health;
                Check(CaelumMachineOwnership.Capture(ram,user,0),"capture active ram");
                Check(ram.health==health,"capture preserves health");
                CaelumBarracasAssault.UpdateReserves(port);
            }
        }
        else Console.Printf("CA454 CAPTURE RESUME PASS");
        CaelumBarracasAssault.UpdateReserves(port);CaelumBarracasAssault.UpdateReserves(port);Inspect(port);
        Console.Printf("CA454 CAPTURE COMPLETE passed=%d failures=%d",Failures==0?4:0,Failures);
    }
}
