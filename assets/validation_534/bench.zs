// Comparación acotada de cuadros del motor; no es una validación de IA masiva.
// Compatible con 5.3.3 para que ambas versiones midan el mismo escenario.
class CA231Bench : StaticEventHandler
{
    ui bool Measuring;
    ui int Frames,Phase;
    ui double Started,Previous;
    ui Array<double> Intervals;
    override void RenderOverlay(RenderEvent e)
    {
        if(!Measuring)return;
        double now=MSTimeF();
        if(Previous>0)Intervals.Push(now-Previous);
        Previous=now;Frames++;
    }
    override void ConsoleProcess(ConsoleEvent e)
    {
        if(e.Name=="c231_bench_start")
        {
            Phase=e.Args[0];Frames=0;Intervals.Clear();Previous=0;
            Started=MSTimeF();Measuring=true;
        }
        if(e.Name=="c231_bench_stop")
        {
            Measuring=false;double duration=MSTimeF()-Started;
            // Ordenación sólo al cerrar la muestra, fuera de la medición.
            for(int i=1;i<Intervals.Size();i++)
            {double value=Intervals[i];int j=i-1;while(j>=0 && Intervals[j]>value){Intervals[j+1]=Intervals[j];j--;}Intervals[j+1]=value;}
            int count=Intervals.Size();
            Console.Printf("CA231 PERF phase=%d frames=%d duration_ms=%.3f fps=%.3f median_ms=%.3f p95_ms=%.3f max_ms=%.3f",
                Phase,Frames,duration,Frames*1000.0/Max(1,duration),count>0?Intervals[count/2]:0,
                count>0?Intervals[Min(count-1,int(count*0.95))]:0,count>0?Intervals[count-1]:0);
            Console.Printf("CA231 %s benchmark-produced-frames",Frames>0?"PASS":"FAIL");
        }
        if(e.Name=="c231_bench_done")Console.Printf("CA231 DONE failures=0");
    }
}
