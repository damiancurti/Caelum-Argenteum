class CA502AwayFrames : StaticEventHandler
{
    ui Array<double> Frames;
    ui double Previous;
    ui bool Reported;
    override void RenderOverlay(RenderEvent e)
    {
        if(level.MapName!="MAP03")return;
        if(level.maptime>=175 && level.maptime<875)
        {
            double now=MSTimeF();if(Previous>0)Frames.Push(now-Previous);Previous=now;
        }
        else if(level.maptime>=875 && !Reported)
        {
            Reported=true;
            for(int i=0;i<Frames.Size();i++)Console.Printf("CA502A FRAME %.6f",Frames[i]);
            Console.Printf("CA502A FRAME_END count=%d",Frames.Size());
        }
    }
}
