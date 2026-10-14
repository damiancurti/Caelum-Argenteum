// Actor exclusivo de la prueba visual: no se incluye en src ni define la habilidad.
class CA251CloudPreview : Actor
{
    Default {Radius 1;Height 1;+NOGRAVITY +NOINTERACTION RenderStyle "Translucent";Alpha 0.64;}
    States {Spawn:CARK A -1 Bright;Stop;}
}

class CA251CloudProbe : StaticEventHandler
{
    Actor Cloud;
    int Passed,Failed;
    void Check(bool ok,String label)
    {if(ok)Passed++;else Failed++;Console.Printf("CA251 %s %s",ok?"PASS":"FAIL",label);}
    override void UiTick(){if(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();}
    override void NetworkProcess(ConsoleEvent e)
    {
        let user=CaelumPlayer(players[e.Player].mo);if(user==null)return;
        if(e.Name=="c251_setup")
        {
            user.CreationWizardOpen=false;user.CharacterCreationComplete=true;
            user.ApplyCharacterProfile();user.bInvulnerable=true;
            user.SetOrigin((0,0,0),false);user.Angle=0;user.Pitch=0;
            Cloud=Actor.Spawn("CA251CloudPreview",(192,0,44),ALLOW_REPLACE);
            Check(Cloud!=null,"isolated cloud model actor spawned");
            Check(Cloud!=null && Cloud.Alpha>0 && Cloud.Alpha<1 && !Cloud.bSolid && !Cloud.bShootable,
                "translucent noncombat preview only");
        }
        if(e.Name=="c251_view" && Cloud!=null)
        {
            Cloud.Angle=e.Args[0];
            user.SetOrigin((0,0,e.Args[1]),false);user.bNoGravity=true;user.Vel=(0,0,0);
            user.Angle=0;user.Pitch=e.Args[2];
            Check(Cloud.Angle==e.Args[0],"preview orientation changed");
        }
        if(e.Name=="c251_done")Console.Printf("CA251 DONE failures=%d passes=%d ASSET_ONLY",Failed,Passed);
    }
}
