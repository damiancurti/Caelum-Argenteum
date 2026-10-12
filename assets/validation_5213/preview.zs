// Exercise the production UI-only renderer without changing identity or inventory.
class CA148Preview : StaticEventHandler
{
    ui CaelumCharacterPreview Preview;
    ui int Ticks;
    override void UiTick()
    {
        if(Preview==null)Preview=new("CaelumCharacterPreview");
        Preview.Tick();Ticks++;
        if(Ticks==35)Preview.ToggleWalking();
        if(Ticks==70)Preview.Turn(4);
        if(Ticks==105)Console.Printf("CA148 DONE failures=0");
    }
    override void RenderOverlay(RenderEvent e)
    {
        if(Preview!=null)Preview.Draw(CaelumNarrativeArtwork.CanvasWidth()/2,450,3.2);
    }
}
