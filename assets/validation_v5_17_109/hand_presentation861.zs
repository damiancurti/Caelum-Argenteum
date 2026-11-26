class CA861PresentationProbe : CA861HandProbe
{
    bool Measuring;
    double PreviousTime;
    override void WorldTick()
    {
        if(!Measuring)return;
        double now=MSTimeF();
        if(PreviousTime>0)Console.Printf("CA861 TIC %.6f",now-PreviousTime);
        PreviousTime=now;
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        Super.NetworkProcess(e);
        if(e.Name=='ca861benchstart'){Measuring=true;PreviousTime=0;Console.Printf("CA861 BEGIN");}
        if(e.Name=='ca861benchend'){Measuring=false;Console.Printf("CA861 END");Loaded();}
    }
}
