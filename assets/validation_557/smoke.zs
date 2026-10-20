// Fixture privado de compilación: #315 no implementa el modelo futuro.
class CA315Smoke : EventHandler
{
    int Age;
    override void UiTick(){if(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();}
    override void WorldTick()
    {
        Age++;
        if(Age==70)Console.Printf("CA315 PASS final runtime compiles and advances native MAP01");
    }
}
