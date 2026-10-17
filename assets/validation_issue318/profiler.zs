// Diagnostic instrumentation; never packaged in src.
class CA318Profiler : StaticEventHandler
{
    double Total[256], Own[256], Started[96], Children[96];
    int Calls[256], Keys[96], Depth;
    static CA318Profiler Get(){return CA318Profiler(StaticEventHandler.Find("CA318Profiler"));}
    void Begin(int key)
    {
        if(Depth>=96)ThrowAbortException("CA318 profile stack overflow");
        Keys[Depth]=key;Children[Depth]=0;Started[Depth]=MSTimeF();Depth++;
    }
    void End(int key)
    {
        double now=MSTimeF();Depth--;
        if(Depth<0 || Keys[Depth]!=key)ThrowAbortException("CA318 unbalanced profile stack");
        double elapsed=now-Started[Depth];
        Total[key]+=elapsed;Own[key]+=elapsed-Children[Depth];Calls[key]++;
        if(Depth>0)Children[Depth-1]+=elapsed;
    }
    override void WorldTick()
    {
        for(int i=0;i<256;i++)
        {
            if(Calls[i]>0)Console.Printf("CA318 COST tic=%d id=%d calls=%d inclusive=%.6f exclusive=%.6f",level.time-1,i,Calls[i],Total[i],Own[i]);
            Calls[i]=0;Total[i]=0;Own[i]=0;
        }
    }
}
