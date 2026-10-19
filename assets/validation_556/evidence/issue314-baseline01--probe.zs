// Fixture privado compatible con el runtime anterior a #314.
class CA314Probe : EventHandler
{
    CaelumPlayer User;
    double ExpectedExposure;
    int ExpectedHealth,Passed,Failed;
    override void UiTick(){if(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();}
    override void NetworkProcess(ConsoleEvent e)
    {
        User=CaelumPlayer(players[consoleplayer].mo);
        if(e.Name=="c314_setup")
        {
            User.InitializeDirectMapCharacter();User.CharacterCreationComplete=true;
            User.CreationWizardOpen=false;User.ApplyCharacterProfile();User.bNOTARGET=true;
        }
        else if(e.Name=="c314_move"){User.SetOrigin(CA314Data.Position(e.Args[0]),false);User.Vel=(0,0,0);}
        else if(e.Name=="c314_mark")
        {ExpectedExposure=CaelumThermalBody.Get(User).Exposure;ExpectedHealth=User.health;}
        else if(e.Name=="c314_restored")
        {
            bool ok=User.health>0 && Abs(CaelumThermalBody.Get(User).Exposure-ExpectedExposure)<2;
            if(ok)Passed++;else Failed++;
            Console.Printf("CA314 %s baseline schema restores exposure and living pawn",ok?"PASS":"FAIL");
        }
        else if(e.Name=="c314_done")Console.Printf("CA314 DONE passes=%d failures=%d",Passed,Failed);
    }
}
