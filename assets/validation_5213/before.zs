// Native baseline observer. No production modifications or preview actors.
class CA148Before : StaticEventHandler
{
    override void ConsoleProcess(ConsoleEvent e)
    {
        if(e.Name=="ca148_view")
        {
            Menu.SetMenu("CaelumNewCharacterMenu");
            let m=CaelumCharacterCreationMenu(Menu.GetCurrentMenu());
            if(m!=null)m.Page=e.Args[0];
        }
        if(e.Name=="ca148_done")Console.Printf("CA148 DONE failures=0");
    }
}
