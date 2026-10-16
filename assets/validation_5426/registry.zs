// Compara el indice con la consulta original de 5.4.25, en geometria nativa.
class CA305Probe : CA252Probe
{
    void Verify(bool ok,String label)
    {if(ok)Passed++;else Failed++;Console.Printf("CA305 %s %s",ok?"PASS":"FAIL",label);}

    void Compare(Actor body,double baseWind,double bearing,String label)
    {
        double h,r,w,d,oldH,oldR,oldW,oldD;
        [h,r,w,d]=CaelumSealClimate.Delta(body,baseWind,bearing);
        [oldH,oldR,oldW,oldD]=CA305Golden.Delta(body,baseWind,bearing);
        Verify(abs(h-oldH)<0.00001 && abs(r-oldR)<0.00001
            && abs(w-oldW)<0.00001 && abs(d-oldD)<0.00001,label);
    }

    int ScanCount()
    {
        int count=0;let it=ThinkerIterator.Create("CaelumChannelEffect");
        while(it.Next()!=null)count++;return count;
    }

    void Equivalence()
    {
        let registry=CaelumSealRegistry.Get();Verify(registry!=null,"static registry registered");
        if(registry==null)return;
        let body=Body((128,0,0));let hidden=Body((768,0,0));let outside=Body((3000,0,0));
        Compare(body,0,73,"empty registry preserves ambient result");
        Verify(registry.Channels.Size()==0,"empty registry contains no channel");
        let effect=Start(CaelumConstants.SEAL_FIRE);effect.ClimatePulse();
        Verify(registry.Channels.Size()==1,"native spawn registers before first query");
        registry.Track(effect);registry.Track(effect);
        Verify(registry.Channels.Size()==1,"registration is idempotent");
        Compare(body,12,73,"single Fire matches old scan");
        Compare(hidden,12,73,"native wall exclusion matches old scan");
        Compare(outside,12,73,"radius exclusion matches old scan");
        Compare(User,0,73,"caster receives same overlay");
        effect.ClimatePulse();Compare(body,12,73,"new accumulated power is read immediately");
        body.SetOrigin((3000,0,0),false);Compare(body,0,73,"moving receiver leaves range immediately");
        body.SetOrigin((128,0,0),false);
        User.CombatChannelModeActive=false;Compare(body,0,73,"inactive owner is excluded immediately");
        User.CombatChannelModeActive=true;
        int health=User.health;User.health=0;Compare(body,0,73,"dead owner is excluded immediately");User.health=health;
        Seal.Equipped=false;Compare(body,0,73,"unequipped seal is excluded immediately");Seal.Equipped=true;
        effect.ChannelOwner=null;Compare(body,0,73,"missing owner is excluded immediately");effect.ChannelOwner=User;
        let water=CaelumChannelEffect(Actor.Spawn("CaelumChannelEffect",User.Pos));
        water.ConfigureChannel(User,Seal,effect.EffectRadius);water.SealType=CaelumConstants.SEAL_WATER;water.ClimatePulse();
        let air=CaelumChannelEffect(Actor.Spawn("CaelumChannelEffect",User.Pos));
        air.ConfigureChannel(User,Seal,effect.EffectRadius);air.SealType=CaelumConstants.SEAL_AIR;air.ClimatePulse();air.CalmWindDirection=123;
        Compare(body,0,73,"overlapping elements and calm wind match old scan");
        Compare(body,12,73,"overlap preserves existing wind bearing");
        let secondAir=CaelumChannelEffect(Actor.Spawn("CaelumChannelEffect",User.Pos));
        secondAir.ConfigureChannel(User,Seal,effect.EffectRadius);secondAir.SealType=CaelumConstants.SEAL_AIR;secondAir.ClimatePulse();secondAir.CalmWindDirection=234;
        Compare(body,0,73,"multiple calm-wind sources retain thinker ordering");
        air.Destroy();Compare(body,0,73,"destroyed first wind source immediately leaves registry");
        registry.Channels.Push(null);Compare(body,0,73,"null reference does not truncate enumeration");
        registry.CacheRevision=0;Compare(body,0,73,"revision mismatch reconstructs existing channels");
        Verify(registry.Channels.Size()==ScanCount(),"reconstruction retains each channel exactly once");
        registry.SourceMap="CA305_INVALID";Compare(body,0,73,"map identity mismatch rebuilds index");
        registry.Rebuild();registry.Rebuild();Compare(body,0,73,"repeated rebuilding is idempotent");
        water.Destroy();secondAir.Destroy();User.StopSealChannel(false,false);
        Verify(registry.Channels.Size()==0,"native destruction unregisters all channels");
        Compare(body,0,73,"cancel removes overlays without a delayed refresh");
    }

    void LoadedRegistry()
    {
        Loaded();
        let registry=CaelumSealRegistry.Get();
        Verify(registry!=null && registry.CacheRevision==CaelumSealRegistry.REVISION,"registry reconstructed during saved-world load");
        if(registry==null)return;
        Verify(registry.Channels.Size()==ScanCount() && registry.Channels.Size()==1,"loaded channel is indexed once");
        let checkpoint=CA252Checkpoint(User.FindInventory("CA252Checkpoint"));
        if(checkpoint!=null)Compare(checkpoint.Body,0,0,"saved accumulated climate equals original scan");
    }

    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="c305_equivalence")Equivalence();
        else if(e.Name=="c305_loaded")LoadedRegistry();
        else if(e.Name=="c305_empty")
        {
            User=CaelumPlayer(players[consoleplayer].mo);
            let registry=CaelumSealRegistry.Get();
            Compare(User,0,0,"new or restored hub map has no stale climate overlay");
            Verify(registry!=null && registry.Channels.Size()==ScanCount() && registry.Channels.Size()==0,"map transition clears old registry references");
        }
        else if(e.Name=="c305_done")Console.Printf("CA305 DONE passes=%d failures=%d",Passed,Failed);
        else Super.NetworkProcess(e);
    }
}
