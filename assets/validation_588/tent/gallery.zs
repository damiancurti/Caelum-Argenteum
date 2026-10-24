class CA411TentGalleryModel : Actor
{
    Default {Radius 1;Height 1;+NOGRAVITY Tag "Carpa desplegada";}
    States {Spawn:CPTN A -1;Stop;}
}
class CA411TentGallery : EventHandler
{
    CA411TentGalleryModel Tent;
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Player<0 || e.Player>=MAXPLAYERS)return;
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=='ca411t_setup')
        {
            u.CreationWizardOpen=false;u.bInvulnerable=true;
            Tent=CA411TentGalleryModel(Actor.Spawn('CA411TentGalleryModel',(0,0,0),NO_REPLACE));
            Tent.A_SetSize(CaelumPhysicsUnits.MapUnits(CaelumCampData.TENT_WIDTH_M)/2,
                CaelumPhysicsUnits.MapUnits(CaelumCampData.TENT_HEIGHT_M),false);
            u.SetOrigin((112,-100,0),false);u.Angle=138;u.Pitch=10;
            Console.Printf("CA411T PASS native gallery actor and approved dimensions");
            Console.Printf("CA411T RESULT ready");
        }
        else if(e.Name=='ca411t_view')
        {
            double angle=e.Args[0]*90;
            u.SetOrigin((Cos(angle)*112,Sin(angle)*112,0),false);u.Angle=angle+180;u.Pitch=10;
            Console.Printf("CA411T RESULT view=%d",e.Args[0]);
        }
    }
}
