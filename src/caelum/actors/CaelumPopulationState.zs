// #128: población derivada del mapa, independiente de la cámara y de CADEV02.
class CaelumPopulationState : Object play
{
    int Revision, LivingCombatants;
    bool HighDensity;
    Array<CaelumSiegeCombatant> UnlinkedGuards;

    static CaelumPopulationState Get()
    {
        let owner=CaelumMassAIScheduler(EventHandler.Find("CaelumMassAIScheduler"));
        return owner!=null ? owner.Population : null;
    }

    void Refresh()
    {
        // Reconstrucción idempotente: también detecta resurrecciones y cambios
        // de flags. El resultado permanece estable durante este tic completo.
        LivingCombatants=0;UnlinkedGuards.Clear();
        let it=ThinkerIterator.Create("CaelumCombatActor");
        CaelumCombatActor body;
        while((body=CaelumCombatActor(it.Next()))!=null)
        {
            if(body.health<=0)continue;
            if(body.bShootable)LivingCombatants++;
            if(body.bNoBlockmap && body.SiegeCombatant!=null)
                UnlinkedGuards.Push(body.SiegeCombatant);
        }
        for(int p=0;p<MAXPLAYERS;p++)
            if(playeringame[p] && players[p].mo!=null && players[p].mo.health>0
                && players[p].mo.bShootable)LivingCombatants++;
        HighDensity=LivingCombatants>=CaelumConstants.HIGH_DENSITY_COMBATANTS;
        Revision=1;
    }
}
