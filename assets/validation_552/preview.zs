// Los tres cuerpos visibles conservan el Tick y los contactos productivos.
class CA311Visible : CA311Moving
{
    States { Spawn: CDMY A -1 Bright; Stop; }
}
class CA311Preview : StaticEventHandler
{
    Array<CA311Visible> Bodies;
    int LaunchCountdown, Mode;
    bool Ready;
    override void UiTick(){if(!Ready && Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();}
    override void WorldLoaded(WorldEvent e)
    {
        Bodies.Clear();Ready=false;LaunchCountdown=0;
        if(e.IsSaveGame)
        {
            for(int i=0;i<3;i++)Bodies.Push(CA311Visible(ActorIterator.Create(45400+i,"CA311Visible").Next()));
            Ready=Bodies.Size()==3 && Bodies[0]!=null && Bodies[1]!=null && Bodies[2]!=null;
        }
    }
    void ResetBodies()
    {
        for(int i=0;i<Bodies.Size();i++)if(Bodies[i]!=null)Bodies[i].Destroy();
        Bodies.Clear();
        for(int i=0;i<3;i++)
        {
            let b=CA311Visible(Actor.Spawn("CA311Visible",(240,(i-1)*70,0)));
            b.ChangeTid(45400+i);b.CombatMaximumHealth=b.health=10000000;b.CombatToughness=0;
            b.CombatLucidityPhysicalStunRemaining=1000;b.CollisionEffectiveMassMultiplier=b.CollisionDamageMultiplier=1;
            b.bNoGravity=true;b.CombatArmor=new("CaelumArmorModel");b.CombatArmor.InitializeDefaults();
            b.AnatomyProfile=new("CaelumAnatomyProfile");
            b.AnatomyProfile.AddRegion(CaelumConstants.HIT_LOCATION_TORSO,3,0,1,0,1);Bodies.Push(b);
        }
        Ready=true;
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="c311_setup")
        {
            let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
            u.CreationWizardOpen=false;u.CharacterCreationComplete=true;u.bInvulnerable=true;
            u.SetOrigin((0,0,0),false);u.Angle=0;u.Pitch=0;u.Vel=(0,0,0);
            ResetBodies();Console.Printf("CA194 DONE failures=0 passes=0 preview-setup-only");
        }
        if(e.Name!="c311_demo" || !Ready)return;
        Mode=e.Args[0];
        if(Mode!=1)ResetBodies();
        if(Mode==2)
        {
            for(int i=0;i<3;i++)
            {
                Bodies[i].SetOrigin((240,0,i==2?220:i*56),false);
                Bodies[i].bNoGravity=false;Bodies[i].Vel=(0,0,i==2?-8:0);
            }
            return;
        }
        for(int i=0;i<3;i++){Bodies[i].SetOrigin((240,(i-1)*70,0),false);Bodies[i].Vel=(0,0,0);}
        LaunchCountdown=10;
    }
    override void WorldTick()
    {
        if(!Ready || LaunchCountdown<=0)return;
        LaunchCountdown--;
        if(LaunchCountdown==0){Bodies[0].Vel=(0,10,0);Bodies[2].Vel=(0,-10,0);}
    }
    override void RenderOverlay(RenderEvent e)
    {
        if(!Ready || automapactive || menuactive!=Menu.Off)return;
        let font=Font.GetFont("CaelumText");if(font==null)return;
        String lines[]={"#311: tres cuerpos de prueba visibles; tu personaje esta protegido.",
            "F6: choque simultaneo | F7: separar y repetir | F8: caida en pila",
            "Golpes: cada choque nuevo suma; quedarse juntos no debe repetirlos.",
            "Prueba guardar/cargar. F10 reinicia. Cierra GZDoom al terminar.",
            String.Format("Golpes recibidos: %d / %d / %d",Bodies[0]!=null?Bodies[0].ImpactHits:0,
                Bodies[1]!=null?Bodies[1].ImpactHits:0,Bodies[2]!=null?Bodies[2].ImpactHits:0)};
        for(int i=0;i<5;i++)Screen.DrawText(font,Font.CR_WHITE,16,8+i*(font.GetHeight()+2),lines[i],DTA_SHADOW,true);
    }
}
