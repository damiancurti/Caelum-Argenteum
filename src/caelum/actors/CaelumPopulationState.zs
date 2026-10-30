// #128: población derivada del mapa, independiente de la cámara y de TACTORS.
class CaelumPopulationState : Object play
{
    int Revision, LivingCombatants;
    int NextMaintenancePhase;
    bool HighDensity;
    double PerceptionMaximumHeight;
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
        PerceptionMaximumHeight=CaelumPerceptionData.REFERENCE_VISIBLE_HEIGHT;
        let it=ThinkerIterator.Create("CaelumCombatActor");
        CaelumCombatActor body;
        while((body=CaelumCombatActor(it.Next()))!=null)
        {
            // Reutilizar el censo autorizado: enlazar cambios de mapa sin otro recorrido.
            if(body.MaintenancePopulation!=self)
            {
                body.ResetMaintenanceForTravel();
                body.MaintenancePopulation=self;
            }
            if(body.health<=0)continue;
            if(body.bShootable){LivingCombatants++;PerceptionMaximumHeight=Max(PerceptionMaximumHeight,body.Height);}
            if(body.bNoBlockmap && body.SiegeCombatant!=null)
                UnlinkedGuards.Push(body.SiegeCombatant);
        }
        for(int p=0;p<MAXPLAYERS;p++)
            if(playeringame[p] && players[p].mo!=null && players[p].mo.health>0
                && players[p].mo.bShootable){LivingCombatants++;PerceptionMaximumHeight=Max(PerceptionMaximumHeight,players[p].mo.Height);}
        HighDensity=LivingCombatants>=CaelumConstants.HIGH_DENSITY_COMBATANTS;
        Revision=1;
    }
}
