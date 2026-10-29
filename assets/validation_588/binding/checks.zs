// Usa la clase y MODELDEF de producción: ninguna malla de galería sustituta.
class CA411BindingChecks : EventHandler
{
    CaelumDeployedTent Tent;
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Player<0 || e.Player>=MAXPLAYERS)return;
        let user=CaelumPlayer(players[e.Player].mo);if(user==null)return;
        if(e.Name=='ca411b_wide' || e.Name=='ca411b_legacy')
        {
            if(Tent!=null)Tent.Destroy();
            bool legacy=e.Name=='ca411b_legacy';
            user.CreationWizardOpen=false;user.bInvulnerable=true;
            Tent=CaelumDeployedTent(Actor.Spawn('CaelumDeployedTent',(0,0,0),NO_REPLACE));
            bool ok=Tent!=null && Tent.Prepare(legacy);
            Console.Printf("CA411D %s production %s actor initialized",ok?"PASS":"FAIL",legacy?"legacy":"wide");
            user.SetOrigin((112,0,0),false);user.Angle=180;user.Pitch=10;
            Console.Printf("CA411D RESULT production binding view ready");
        }
        else if(e.Name=='ca411b_side')
        {user.SetOrigin((0,140,0),false);user.Angle=270;user.Pitch=10;}
    }
}
