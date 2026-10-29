class CA416MusicChecks : EventHandler
{
    ui bool Checked;
    override void UiTick()
    {
        if(Checked || level.MapName!="CABAIRES" || level.maptime<140)return;
        Checked=true;
        bool ok=musplaying.name=="music/CA_MUS_CIUDAD.ogg" && System.MusicEnabled();
        Console.Printf("CA416M %s Buenos Aires active music=%s",ok?"PASS":"FAIL",musplaying.name);
        Console.Printf("CA416M RESULT checked");
    }
}
