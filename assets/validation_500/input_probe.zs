// Mide sólo el recorrido de eventos UI -> play -> UI, sin acción jugable.
// No mide dispositivo, sistema operativo, GPU ni presentación del monitor.
class CA116InputProbe : EventHandler
{
    ui int Sequence;
    ui bool WaitingFrame;
    override void ConsoleProcess(ConsoleEvent e)
    {
        if(e.Name!="ca116_probe") return;
        Sequence++;
        Console.Printf("CA116 PROBE_REQUEST id=%d ms=%.3f",Sequence,MSTimeF());
        SendNetworkEvent("ca116_probe_play",Sequence);
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!="ca116_probe_play") return;
        Console.Printf("CA116 PROBE_PLAY id=%d ms=%.3f tic=%d",e.Args[0],MSTimeF(),level.time);
        SendInterfaceEvent(e.Player,"ca116_probe_ack",e.Args[0]);
    }
    override void InterfaceProcess(ConsoleEvent e)
    {
        if(e.Name!="ca116_probe_ack") return;
        Console.Printf("CA116 PROBE_ACK id=%d ms=%.3f",e.Args[0],MSTimeF());
        WaitingFrame=true;
    }
    override void RenderOverlay(RenderEvent e)
    {
        if(!WaitingFrame) return;
        WaitingFrame=false;
        Console.Printf("CA116 PROBE_FRAME id=%d ms=%.3f",Sequence,MSTimeF());
    }
}
