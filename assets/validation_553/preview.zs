// Sala visual de diagnóstico: pesos extremos sólo en estos cuerpos de prueba.
class CA312Visible : CA194Moving
{
    double PressureDamage;
    override int DamageMobj(Actor inflictor,Actor source,int damage,Name mod,int flags,double angle)
    {
        int before=health;
        int result=Super.DamageMobj(inflictor,source,damage,mod,flags,angle);
        if(mod=='Crush' || mod=='CaelumWeight' || mod=='CaelumPressure')PressureDamage+=Max(0,before-health);
        return result;
    }
    States { Spawn: CDMY A -1 Bright; Stop; }
}
class CA312Preview : StaticEventHandler
{
    CA312Visible Victim,BaseBody,Top;
    bool Ready;
    override void UiTick(){if(!Ready && Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();}
    override void WorldLoaded(WorldEvent e)
    {
        Ready=e.IsSaveGame;
        Victim=CA312Visible(ActorIterator.Create(45850).Next());
        BaseBody=CA312Visible(ActorIterator.Create(45851).Next());
        Top=CA312Visible(ActorIterator.Create(45852).Next());
    }
    CA312Visible Body(Vector3 position,int id,int mass=80)
    {
        let b=CA312Visible(Actor.Spawn("CA312Visible",position));b.ChangeTid(id);
        b.Mass=mass;b.health=b.CombatMaximumHealth=1000000000;b.CombatToughness=0;b.CombatStrength=0;
        b.CombatLucidityPhysicalStunRemaining=10000;b.CollisionEffectiveMassMultiplier=b.CollisionDamageMultiplier=1;
        b.CombatArmor=new("CaelumArmorModel");b.CombatArmor.InitializeDefaults();
        return b;
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=="c312_preview_setup")
        {
            u.CreationWizardOpen=false;u.CharacterCreationComplete=true;u.bInvulnerable=true;
            u.SetOrigin((2032,1200,0),false);u.Angle=0;u.Pitch=0;u.Vel=(0,0,0);
            if(Victim==null){Victim=Body((2224,1200,0),45850);Victim.bNoGravity=true;}
            Ready=true;Console.Printf("CA194 DONE failures=0 passes=0 preview-setup-only");
        }
        if(e.Name!="c312_preview" || !Ready)return;
        if(e.Args[0]==0)
        {
            u.SetOrigin((2032,1200,0),false);u.Angle=0;u.Pitch=0;u.Vel=(0,0,0);
            let trap=CaelumCrusherTrap(ActorIterator.Create(43613).Next());
            if(Victim!=null)Victim.bNoGravity=false;
            if(trap!=null && trap.Release())Console.Printf("CA312 PREVIEW ceiling started");
        }
        if(e.Args[0]==1)
        {
            if(Top!=null)Top.Destroy();if(BaseBody!=null)BaseBody.Destroy();
            BaseBody=Body((1152,1664,0),45851);Top=Body((1152,1664,56),45852,1000000);
            Top.bOnMobj=true;Top.Vel=(0,0,0);
            u.SetOrigin((960,1664,0),false);u.Angle=0;u.Pitch=20;u.Vel=(0,0,0);
            Console.Printf("CA312 PREVIEW weight placed");
        }
        if(e.Args[0]==2 && Top!=null){Top.Destroy();Top=null;Console.Printf("CA312 PREVIEW weight removed");}
    }
    override void RenderOverlay(RenderEvent e)
    {
        if(!Ready || automapactive || menuactive!=Menu.Off)return;
        let font=Font.GetFont("CaelumText");if(font==null)return;
        let weight=BaseBody!=null?CaelumWeightPressure(BaseBody.FindInventory("CaelumWeightPressure")):null;
        let ceiling=Victim!=null?CaelumCeilingPressure(Victim.FindInventory("CaelumCeilingPressure")):null;
        String lines[]={"#312: PRESION CONTINUA. Tu personaje esta protegido.",
            "F6: bajar techo sobre cuerpo | F7: colocar peso sobre otro cuerpo",
            "F8: retirar peso; el contador de dano debe detenerse. F10: reiniciar sala.",
            "Prueba guardar/cargar con el peso colocado. Pesos extremos solo para esta prueba.",
            String.Format("Dano acumulado por peso: %.0f HP | pendiente %.2f J | ultimo pulso %.2f J",BaseBody!=null?BaseBody.PressureDamage:0,weight!=null?weight.DamageCarry:0,weight!=null?weight.LastWorkJoules:0),
            String.Format("Dano acumulado por techo: %.0f HP | ultimo descenso intentado %.3f m",Victim!=null?Victim.PressureDamage:0,ceiling!=null?ceiling.LastCompressionMeters:0)};
        for(int i=0;i<6;i++)Screen.DrawText(font,Font.CR_WHITE,170,8+i*(font.GetHeight()+2),lines[i],DTA_SHADOW,true,DTA_VIRTUALWIDTH,1280,DTA_VIRTUALHEIGHT,720);
    }
}
