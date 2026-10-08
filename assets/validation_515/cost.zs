class CA135Cost : EventHandler
{
    CaelumCombatActor Bodies[16];
    override void WorldTick()
    {
        let user=CaelumPlayer(players[0].mo);
        int active=CVar.GetCVar("ca135_cost_sources").GetInt();
        if(level.time==1){user.InitializeDirectMapCharacter();user.PersistCharacterState();user.bNOTARGET=true;user.Angle=180;}
        if(level.time==60)for(int i=0;i<16;i++)
        {Bodies[i]=CaelumCombatActor(Actor.Spawn("CaelumMandinga",(4096+i%4*256,4096+i/4*256,0)));Bodies[i].tics=-1;}
        if(level.time>=70 && level.time<=1190)
        {
            for(int i=0;i<16;i++)
            {
                Bodies[i].target=null;Bodies[i].tics=-1;
                Bodies[i].ThermalState.Exposure=i<active ? -15 : 0;
                Bodies[i].ThermalState.Severity=i<active ? 1 : 0;
            }
        }
        if(level.time==140)Console.Printf("CA135 COST_BEGIN active=%d tic=%d",active,level.time);
        if(level.time==1190)Console.Printf("CA135 COST_END active=%d tic=%d",active,level.time);
        if(level.time==1200)Console.Printf("CA135 COMPLETE checks=0 failures=0");
    }
}
