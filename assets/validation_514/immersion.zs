class CA140Immersion : StaticEventHandler
{
    CaelumPlayer User;
    int Failures;
    void Verify(bool ok,String label)
    {if(!ok)Failures++;Console.Printf("CA140 %s %s",ok ? "PASS" : "FAIL",label);}
    override void WorldTick()
    {
        if(level.time==1)
        {
            User=CaelumPlayer(players[0].mo);User.InitializeDirectMapCharacter();User.CreationWizardOpen=false;
            User.bNOGRAVITY=true;User.SetOrigin((14000,0,40),false);User.Vel=(0,0,0);
        }
        if(User==null)return;
        User.CurrentAir=0.05*User.DerivedStats.MaximumAir;
        if(level.time==10)
        {
            let s=CaelumThermalBody.Get(User,true);CaelumThermalBody.Refresh(User,s);
            CaelumBreathing.UpdateSound(User);
            Verify(User.WaterLevel==3,"native 3D water fully submerges player");
            Verify(!s.CanBreathe && CaelumBreathing.ActorFactor(User)==1,"submersion disables ventilation boost");
            Verify(!CaelumBreathing.Playing(User),"no audible panting underwater");
            double air=User.CurrentAir;User.IsSpendingRunningAir=false;
            CaelumPlayerResources.ApplyAirRegeneration(User);Verify(User.CurrentAir==air,"no ordinary Air regeneration underwater");
            User.SetOrigin((-14000,-4000,0),false);User.Vel=(0,0,0);
        }
        if(level.time==20)
        {
            let s=CaelumThermalBody.Get(User,true);CaelumThermalBody.Refresh(User,s);CaelumBreathing.UpdateSound(User);
            Verify(User.WaterLevel==0 && s.CanBreathe && CaelumBreathing.ActorFactor(User)==2,"surfacing restores fatigued ventilation");
            Verify(CaelumBreathing.Playing(User),"surfacing resumes native panting");
            Console.Printf("CA140 IMMERSION_COMPLETE checks=6 failures=%d",Failures);
        }
    }
}
