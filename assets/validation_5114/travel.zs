class CA165Travel : StaticEventHandler
{
    int Elapsed,Visits,Passed,Failed,PriorEffect,PriorCooldown;
    void Check(String label,bool ok)
    {if(ok)Passed++;else Failed++;Console.Printf("CA165 %s visit=%d %s",ok?"PASS":"FAIL",Visits,label);}
    override void WorldLoaded(WorldEvent e){Elapsed=0;Visits++;}
    override void WorldTick()
    {
        Elapsed++;let u=CaelumPlayer(players[0].mo);if(u==null)return;
        let r=u.GetPersistentCharacterState(false);
        if(Elapsed==20)
        {
            Check("arrival has no inherited damage flash",u.DamageVFXStrength==0 && CaelumDamageFeedback.FlashAlpha(u)==0);
            if(Visits==2 || Visits==3)
            {
                Check("paid Fool flight survives map crossing",r.TarotEffectTics>0 && u.FindInventory("CaelumTarotFlight")!=null && u.bNOGRAVITY);
                Check("effect and cooldown are not restarted",r.TarotEffectTics<=PriorEffect && PriorEffect-r.TarotEffectTics<TICRATE && r.TarotCooldownTics-r.TarotEffectTics==PriorCooldown-PriorEffect);
            }
            if(Visits==3 || Visits==5)
                Check("MAP02 arrival remains inside entry geometry",level.MapName=="MAP02" && Abs(u.Pos.X)<32 && Abs(u.Pos.Y)<32 && u.Pos.Z>=u.floorz && u.Pos.Z+u.Height<=u.ceilingz);
            if(Visits>=4)Check("grounded control has no restored flight",r.TarotEffectTics==0 && u.FindInventory("CaelumTarotFlight")==null && !u.bNOGRAVITY);
            if(Visits==5)Console.Printf("CA165 TRAVEL RESULT passed=%d failed=%d",Passed,Failed);
        }
        // Reproduce an actually airborne departure from MAP01, not just a
        // flight power held while standing on the floor.
        if(Visits==2 && Elapsed==25)
        {u.SetOrigin((u.Pos.X,u.Pos.Y,Min(u.ceilingz-u.Height-1,u.floorz+64)),false);u.Vel=(0,0,0);}
        if(Elapsed==40 && Visits<5)
        {
            if(Visits==2)Check("MAP01 departure is airborne",u.bNOGRAVITY && u.Pos.Z>u.floorz+1);
            if(Visits==1)
            {
                // Fixture-only paid-effect state; production restoration must not reset it.
                r.TarotActive[0]=true;r.TarotEffectTics=1000;
                CaelumTarotService.RestoreNativeEffect(u);
            }
            if(Visits==3)
            {
                r.TarotEffectTics=0;r.TarotActive[0]=false;
                let flight=u.FindInventory("CaelumTarotFlight");if(flight!=null)flight.Destroy();
            }
            CaelumDamageFeedback.Record(u,null,'None',10);
            Check("recent flash exists before crossing",CaelumDamageFeedback.FlashAlpha(u)>0);
            PriorEffect=r.TarotEffectTics;PriorCooldown=r.TarotCooldownTics;
            u.PersistCharacterState();u.Vel=(0,0,0);
            Level.ChangeLevel(Visits==1?"MAP01":Visits==3?"MAP03":"MAP02",0,CHANGELEVEL_NOINTERMISSION);
        }
    }
}
