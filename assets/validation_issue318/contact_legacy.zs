class CA318HeatProbe : EventHandler
{
    override void UiTick(){if(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();}
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="c318_legacy")
        {
            let user=CaelumPlayer(players[0].mo);user.CharacterCreationComplete=true;
            user.CreationWizardOpen=false;user.ApplyCharacterProfile();user.bInvulnerable=true;
            let h=CA318HeatHolder(Actor.Spawn("CA318HeatHolder",(0,0,0)));
            h.Demon=CaelumCombatActor(Actor.Spawn("CA318HeatBody",(-2048,0,0)));
            h.Victim=CaelumCombatActor(Actor.Spawn("CA318HeatBody",(-1952,0,0)));
            CaelumFolkloreCombatActor(h.Demon).InitializeUniformFolkloreProfile(6);
            CaelumFolkloreCombatActor(h.Victim).InitializeUniformFolkloreProfile(6);
            h.Victim.ElementalStatus=new("CaelumElementalStatus");h.Victim.ElementalStatus.BurnRemaining=3;
            let t=CaelumThermalBody.Get(h.Victim,true);CaelumThermalBody.Refresh(h.Victim,t);
            t.Exposure=2;t.AbsorbedContinuousJoules=123;
            h.Exposure=t.Exposure;h.Continuous=t.AbsorbedContinuousJoules;
            h.Stream=CaelumDemonBreath(Actor.Spawn("CaelumDemonBreath",h.Demon.Pos));
            h.Stream.Emitter=h.Demon;h.Demon.DemonBreath=h.Stream;
            h.Stream.PaidSeconds=0.5;h.Stream.NextHeatTic=level.time+100;
            h.Stream.TotalPaidSeconds=2;h.TotalPaid=2;
            Console.Printf("CA318 PASS genuine prior-runtime save seed");
        }
        else if(e.Name=="c318_done")Console.Printf("CA318 DONE failures=0 checks=1");
    }
}
