    void Restored()
    {
        let user=CaelumPlayer(players[0].mo);let record=user.GetPersistentCharacterState(false);
        Check(CaelumBattleTactics.Get(user)==null,"old save acquires no invented preparation or reward");
        let tactics=CaelumBattleTactics.Get(user,true);
        Check(tactics!=null && tactics.Revision==1 && !tactics.IntelligenceDelivered && tactics.Delivery==null,"new campaign schema initializes once with no retroactive outcomes");
        Check(CaelumBattleTactics.Get(user,true)==tactics,"campaign migration is idempotent");
        Check(Gun.health==SavedHealth && Gun.OwnerFaction==0 && !Gun.CapturedIntact,"old captured damage and ownership remain unchanged");
        Check(CaelumMachineWork.Active(user) && CaelumMachineWork.Find(user).Paused && user.CraftingTaskRemainingSeconds==SavedWork,"old interrupted work and native reservations remain unchanged");
        Check(CaelumPoiKnowledge.Find(record,"MAP03",CaelumBattleRouteData.Id(0))==null,"migration never invents route discovery");
        Console.Printf("CA450 RESULT %s failures=%d",Failures==0?"PASS":"FAIL",Failures);
    }
