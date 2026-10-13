class CA215Compile : StaticEventHandler
{
    override void ConsoleProcess(ConsoleEvent e)
    {
        if(e.Name=="c215_main")Menu.SetMenu("MainMenu");
        if(e.Name=="c215_options")Menu.SetMenu("OptionsMenu");
        if(e.Name=="c215_creator")Menu.SetMenu("CaelumNewCharacterMenu");
        if(e.Name=="c215_done")Console.Printf("CA215 DONE failures=0");
    }
}
