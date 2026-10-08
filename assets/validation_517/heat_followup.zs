// Isolated observer of a copied author save; never packaged in production.
class CA136HeatFollowup : StaticEventHandler
{
    int Elapsed,Rescues;
    override void WorldLoaded(WorldEvent e) {Elapsed=0;Rescues=0;}
    override void WorldTick()
    {
        let u=CaelumPlayer(players[0].mo);if(u==null)return;
        let t=CaelumThermalBody.Get(u);if(t==null)return;
        Elapsed++;
        int mode=CVar.GetCVar("ca136_heat_mode").GetInt();
        bool motion=mode==1;
        if((motion || mode==6) && Elapsed==1)
        {
            t.Exposure=0;t.ActivityWatts=0;t.ActivityJoules=0;t.ActionJoules=0;t.AppliedDamageHP=0;
            u.health=u.CaelumMaximumHealth;u.player.health=u.health;
            u.SetOrigin((1600,0,0),false);u.Angle=90;u.Pitch=0;u.Vel=(0,0,0);
            if(mode==6)for(int slot=0;slot<4;slot++)CaelumThermalBody.SetWater(u,t,slot,0);
            Console.Printf("CA136 HEAT PROFILE jumpJ=%.6f swimW=%.6f",t.ReferenceJumpHeat,CaelumThermalEffects.EffortWatts(u,CaelumConstants.RUN_AIR_COST_PER_SECOND*u.DerivedStats.AirConsumptionMultiplier));
        }
        if(mode==2 && Elapsed==1)
        {
            t.Exposure=0;t.ActivityWatts=0;t.ActivityJoules=0;t.ActionJoules=0;t.AppliedDamageHP=0;
            for(int slot=0;slot<4;slot++)CaelumThermalBody.SetWater(u,t,slot,0);
            u.health=u.CaelumMaximumHealth;u.player.health=u.health;
            u.Angle=45;u.Pitch=0;
        }
        if(mode==5 && Elapsed==1)
        {
            t.Exposure=0;t.ActivityWatts=0;t.ActivityJoules=0;t.ActionJoules=0;t.AppliedDamageHP=0;
            u.health=u.CaelumMaximumHealth;u.player.health=u.health;
            u.SetOrigin((3000,0,-100),false);u.Angle=0;u.Pitch=0;u.Vel=(0,0,0);
        }
        if(mode==5)
        {
            // Keep the controlled swimmer in real pool geometry; replenish
            // breath only to separate exercise heat from drowning damage.
            u.SetOrigin((u.Pos.X,u.Pos.Y,-100),false);u.Vel.Z=0;
            if(u.Pos.X>3250)u.Angle=180;if(u.Pos.X<2800)u.Angle=0;
            u.CurrentAir=u.DerivedStats.MaximumAir;
        }
        if(Elapsed==1)Console.Printf("CA136 HEAT original exposure=%.6f activity=%.6f hp=%d revision=%d",t.Exposure,t.ActivityWatts,u.health,t.Revision);
        if(mode==4 && Elapsed==2)
            Console.Printf("CA136 HEAT RELOAD %s",t.Revision==7 && t.ActivityWatts==0 ? "PASS" : "FAIL");
        // Preserve exposure/resources. Replenish only HP to observe lethal flux.
        if(u.health<500){u.health=u.CaelumMaximumHealth;u.player.health=u.health;Rescues++;}
        if(mode<2 && Elapsed==350){u.SetOrigin((3000,0,-180),false);u.Vel=(0,0,0);u.bNOGRAVITY=true;}
        if(motion && Elapsed==700){u.SetOrigin((2480,0,-152),false);u.Angle=180;u.Vel=(0,0,0);u.bNOGRAVITY=false;}
        if(mode<2 && Elapsed==1050){u.SetOrigin((2031,504,0),false);u.Vel=(0,0,0);u.bNOGRAVITY=false;}
        if(Elapsed%35==0 || Elapsed==1)
            Console.Printf("CA136 HEAT sec=%.3f E=%.6f activity=%.6f pending=%.6f airC=%.3f waterC=%.3f water=%d wet=%.3f G=%.6f B=%.6f net=%.6f actionJ=%.3f motionJ=%.3f input=%d,%d,%d vel=%.3f,%.3f own=%.3f,%.3f pos=%.3f,%.3f,%.3f hp=%d damage=%.3f rescues=%d",
                Elapsed/35.0,t.Exposure,t.ActivityWatts,t.PendingActivityJoules,t.AirC,t.WaterC,u.WaterLevel,t.WetnessPercent,t.Conductance,t.Imbalance,t.Imbalance-t.Conductance*t.Exposure+t.ActivityWatts,t.ActionJoules,t.ActivityJoules,u.player.cmd.forwardmove,u.player.cmd.sidemove,u.player.cmd.upmove,u.Vel.X,u.Vel.Y,t.PropelledVelocity.X,t.PropelledVelocity.Y,u.Pos.X,u.Pos.Y,u.Pos.Z,u.health,t.AppliedDamageHP,Rescues);
        if(Elapsed==1750)Console.Printf("CA136 HEAT COMPLETE");
    }
}
