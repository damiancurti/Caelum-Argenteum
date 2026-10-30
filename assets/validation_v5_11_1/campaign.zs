class CA429Token : Inventory
{
    Default { Inventory.MaxAmount 100; +INVENTORY.UNDROPPABLE }
}
class CA429Campaign : EventHandler
{
    CaelumCombatActor SavedBody;
    int SavedCount,Failures;
    void Check(bool ok,String label)
    {if(ok)Console.Printf("CA429 PASS %s",label);else{Failures++;Console.Printf("CA429 FAIL %s",label);}}
    override void NetworkProcess(ConsoleEvent e)
    {
        let user=CaelumPlayer(players[0].mo);
        if(e.Name=='ca429_campaign_start')
        {
            user.CharacterCreationComplete=true;user.CreationWizardOpen=false;user.ApplyCharacterProfile();user.bInvulnerable=true;
            let clock=CaelumWorldClock.Get(user,true);let calendar=CaelumCalendarState.Get(user,true);calendar.EnsureCampaign(clock);
            calendar.SetAnchor(clock,CaelumCityWorld.SiegeDay(),CaelumCityData.SIEGE_HOUR*CaelumWorldClock.TicsPerHour()-1,false);
        }
        if(e.Name=='ca429_campaign_save')
        {
            let port=CaelumPortSiege.Get();SavedCount=port.Attackers.Size();SavedBody=port.Attackers[0].Body;
            // Exclude a due reinforcement opportunity from the migration assertion.
            port.Reinforcements.NextOpportunity=level.time+10*TICRATE;
            SavedBody.GiveInventory('CA429Token',7);SavedBody.bInvulnerable=true;
            Check(SavedCount>0 && SavedBody.CountInv('CA429Token')==7,"campaign migration source retains native body and inventory");
            Console.Printf("CA429 RESULT campaign source complete failures=%d",Failures);
        }
        if(e.Name=='ca429_campaign_verify')Verify();
        if(e.Name=='ca429_campaign_due')
        {
            let port=CaelumPortSiege.Get();
            Console.Printf("CA429 DUE source=%d current=%d successful=%d",SavedCount,port.Attackers.Size(),port.Reinforcements.Successful);
            Check(port.Attackers.Size()==port.Reinforcements.Successful+1 && port.Attackers[0].Body==SavedBody,
                "due original reinforcement accounts for the changed active roster");
            Console.Printf("CA429 RESULT due admission diagnostic failures=%d",Failures);
        }
    }
    void Verify()
    {
        let port=CaelumPortSiege.Get();
        Console.Printf("CA429 MIGRATION saved=%d actual=%d first=%d",SavedCount,port.Attackers.Size(),int(port.Attackers[0].Body==SavedBody));
        Check(port!=null && port.Attackers.Size()==SavedCount && port.Attackers[0].Body==SavedBody,
            "migration retains native roster and actor identity");
        Check(SavedBody!=null && SavedBody.CountInv('CA429Token')==7,"migration preserves native inventory exactly once");
        // BEGIN CURRENT
        port.ElectCommands();bool membership=true;
        Array<int> orders;
        for(int i=0;i<port.Attackers.Size();i++)
        {
            let body=port.Attackers[i].Body;
            if(port.ActiveEntry(port.Attackers[i]) && !CaelumRedemption.PreviouslyRaised(body)
                && (body.Formation==null || body.Formation.Group.Members.Size()>100))membership=false;
            orders.Push(body.Formation!=null?body.Formation.Order:-1);
        }
        Check(membership && port.FormationRevision==1,"old campaign builds bounded formations from its existing roster");
        int groups=port.FormationGroups.Size();port.ElectCommands();bool stable=groups==port.FormationGroups.Size();
        for(int i=0;i<port.Attackers.Size();i++)
        {let member=port.Attackers[i].Body.Formation;if((member!=null?member.Order:-1)!=orders[i])stable=false;}
        Check(stable,"repeated reconciliation preserves groups and joining order");
        for(int i=0;i<port.FormationGroups.Size();i++)
        {
            let group=port.FormationGroups[i];if(group.Leader==null || group.Members.Size()<2)continue;
            let previous=group.Leader;previous.Body.ForcedSleepTics=10;
            group.PulseReady=false;group.Refresh();
            Check(group.Leader!=null && group.Leader!=previous
                && group.Leader.Body.SiegeCombatant.GroupCandidates!=null
                && previous.Body.SiegeCombatant.CommandLeader==group.Leader.Body.SiegeCombatant,
                "succession immediately rebinds bounded candidate ownership");
            previous.Body.ForcedSleepTics=0;
            let changed=previous.Body;changed.bFriendly=true;group.PulseReady=false;group.Refresh();
            Check(changed.Formation==null && changed.SiegeCombatant.CommandLeader==null,
                "allegiance change detaches previous military command");
            changed.bFriendly=false;port.ElectCommands();break;
        }
        // END CURRENT
        Console.Printf("CA429 RESULT campaign verification complete failures=%d",Failures);
    }
}
