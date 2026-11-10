class CA450Port : CaelumPortSiege replaces CaelumPortSiege { override void Tick() {} }
class CA450Guard : CaelumPortDefender { override void Tick() {} }
class CA450Checks : EventHandler
{
    CA450Port Port;
    CaelumCannon Gun;
    int Failures,Checks;
    int Reputation[MAXPLAYERS];
    CaelumPortDefender Contact;
    void Check(bool passed,String label)
    {Checks++;if(!passed)Failures++;Console.Printf("CA450 %s %s",passed?"PASS":"FAIL",label);}
    void Seed()
    {
        Port=CA450Port(CaelumPortSiege.Get());
        if(Port==null)Port=CA450Port(Actor.Spawn('CA450Port',(0,0,0)));
        Port.Reinforcements=new('CaelumSiegeReinforcements');
        Port.Reinforcements.Enabled=true;Port.Reinforcements.Remaining=CaelumReinforcementData.TOTAL;
        Port.Reinforcements.Revision=CaelumReinforcementData.REVISION;
        for(int lane=0;lane<6;lane++)
        {
            let exitNode=CaelumSiegeRouteNode(Actor.Spawn('CaelumSiegeRouteNode',(CaelumPortData.GateX(lane),CaelumPortData.ExitY(),0)));
            exitNode.IsExit=true;Port.Exits.Push(exitNode);
        }
        Gun=CaelumCannon(Actor.Spawn('CaelumCannon',(0,512,0)));
        Gun.InitializeCannon(false);Port.RegisterMachine(Gun);
        Console.Printf("CA450 SEEDED");
    }
    void Initial()
    {
        let user=CaelumPlayer(players[0].mo);let record=user.GetPersistentCharacterState(true);
        let clock=CaelumWorldClock.Get(user,true);clock.CompletedDays=0;clock.DayTics=0;CaelumWorldClockTicker.Mirror(user);
        record.PortPrisonerAccountMask=0;record.PortSiegeNarrativeStarted=false;
        Check(CaelumBattleTactics.Prepare(user)=="CA_TACTICS_NO_INTELLIGENCE","unheard private accounts cannot prepare the siege");
        record.PortPrisonerAccountMask=1;
        Check(CaelumBattleTactics.Prepare(user)=="CA_TACTICS_PREPARED","actual prisoner knowledge enables pre-battle delivery");
        Check(Port.Reinforcements.Remaining==6500 && Port.Reinforcements.Withheld==100,"preparation subtracts one finite reserve group");
        CaelumBattleTactics.Prepare(user);CaelumBattleTactics.ApplyPreparation(Port);
        Check(Port.Reinforcements.Remaining==6500,"repeated preparation never consumes another group");
        Port.Reinforcements.Successful=200;Port.Reinforcements.Remaining=6300;Port.Reinforcements.Revision=1;
        Port.Reinforcements.Initialize(Port,false);
        Check(Port.Reinforcements.Remaining==6300,"older reserve revision preserves committed arrivals and withheld budget");
        let tactics=CaelumBattleTactics.Get(user);tactics.IntelligenceDelivered=false;Port.SiegeStarted=true;
        Check(CaelumBattleTactics.Prepare(user)=="CA_TACTICS_TOO_LATE" && !tactics.IntelligenceDelivered,"battle start rejects late preparation");
        tactics.IntelligenceDelivered=true;
        Port.Reinforcements.Opportunity(Port);
        Check(Port.Reinforcements.Successful==300 && Port.Reinforcements.Remaining==6200
            && Port.Attackers.Size()==100,"a real admitted wave consumes the prepared finite ledger once");
        // La escena aislada cierra nuevas llegadas; los cien cuerpos siguen vivos.
        Port.Reinforcements.Stopped=true;
        for(int p=0;p<MAXPLAYERS;p++)if(playeringame[p])
        {
            let member=CaelumPlayer(players[p].mo);let r=member.GetPersistentCharacterState(true);
            Reputation[p]=r.FactionReputation[0];r.FactionMember[0]=true;
        }
        Check(CaelumBattleTactics.Deliver(user)=="CA_TACTICS_NO_MACHINE","uncaptured original machine cannot satisfy delivery");
        Check(CaelumMachineOwnership.Capture(Gun,user,0),"capture uses the real ownership operation");
        Gun.Sabotaged=true;
        Check(!CaelumBattleTactics.Deliverable(Gun),"sabotage prevents operational delivery");Gun.Sabotaged=false;
        Gun.Structure.health--;
        Check(!CaelumBattleTactics.Deliverable(Gun),"damage after intact capture prevents delivery");Gun.Structure.health++;
        Gun.OwnerFaction=1;
        Check(!CaelumBattleTactics.Deliverable(Gun),"another faction cannot receive the Unitarian objective");Gun.OwnerFaction=0;
        vector3 position=Gun.Pos;
        Check(CaelumBattleTactics.Deliver(user)=="CA_TACTICS_DELIVERED" && Gun.Pos==position,"report records intact original delivery without transporting the machine");
        for(int p=0;p<MAXPLAYERS;p++)if(playeringame[p])
        {
            let member=CaelumPlayer(players[p].mo);CaelumBattleTactics.Deliver(member);CaelumBattleTactics.Claim(member);
            Check(member.GetPersistentCharacterState(false).FactionReputation[0]==Reputation[p]+50,"each native cooperative participant receives exactly fifty once");
        }
        let stranger=new('CaelumLawfulIdentity');let old=record.LawfulIdentity;record.LawfulIdentity=stranger;
        Check(!tactics.Delivery.Contains(record),"a reused player slot with a new identity is not eligible");record.LawfulIdentity=old;
        Check(CaelumPoiKnowledge.Find(record,"MAP03",CaelumBattleRouteData.Id(0))==null,"unvisited tactical routes remain unknown on a new save");
        Check(CaelumBattleRouteData.Contains(0,(-30272,768,0)) && !CaelumBattleRouteData.Contains(0,(-29504,768,0)),"west route uses the authored exterior ground only");
        Check(CaelumBattleRouteData.Contains(1,(-27776,-13408,16)) && !CaelumBattleRouteData.Contains(1,(-27776,-13408,256)),"stairs require actual entry height rather than remote projection");
        CaelumPoiKnowledge.Record(user,CaelumBattleRouteData.Id(0),CaelumPoiData.TACTICAL_ROUTE,CaelumBattleRouteData.NameKey(0),(-30272,768,0));
        Console.Printf("CA450 CHECKPOINT READY failures=%d",Failures);
    }
    void VerifySaved()
    {
        let user=CaelumPlayer(players[0].mo);let tactics=CaelumBattleTactics.Get(user);
        Check(tactics!=null && tactics.Revision==1 && tactics.IntelligenceDelivered,"shared preparation survives native save and hub lifecycle");
        Check(Port.Reinforcements.Remaining==6200 && Port.Reinforcements.Withheld==100,"spent and withheld reserve never regenerate");
        Check(Gun.CapturedIntact && Gun.OwnerFaction==0,"original captured machine retains its identity and condition");
        Check(CaelumPoiKnowledge.Find(user.GetPersistentCharacterState(false),"MAP03",CaelumBattleRouteData.Id(0))!=null,"known-only route observation survives");
        for(int p=0;p<MAXPLAYERS;p++)if(playeringame[p])
        {
            let member=CaelumPlayer(players[p].mo);CaelumBattleTactics.Claim(member);
            Check(member.GetPersistentCharacterState(false).FactionReputation[0]==Reputation[p]+50,"save and hub return never duplicate individual rewards");
        }
    }
    void Restored(){VerifySaved();Console.Printf("CA450 RESULT %s failures=%d",Failures==0?"PASS":"FAIL",Failures);}
    void LegacyRestored(){}
    void Catchup(){}
    void VerifyTravel(){VerifySaved();Console.Printf("CA450 TRAVEL %s failures=%d",Failures==0?"PASS":"FAIL",Failures);}
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="ca450_seed")Seed();
        else if(e.Name=="ca450_initial")Initial();
        else if(e.Name=="ca450_restored")Restored();
        else if(e.Name=="ca450_travel")Level.ChangeLevel('T450',0,CHANGELEVEL_NOINTERMISSION);
        else if(e.Name=="ca450_return")Level.ChangeLevel('MAP03',0,CHANGELEVEL_NOINTERMISSION);
        else if(e.Name=="ca450_verifytravel")VerifyTravel();
        else if(e.Name=="ca450_dialogue")
        {
            let user=CaelumPlayer(players[0].mo);
            Contact=CaelumPortDefender(Actor.Spawn('CA450Guard',user.Pos+(64,0,0)));
            Contact.Port=Port;user.Angle=0;user.Pitch=0;
            Check(CaelumFactionCondition.OpenDialogue(user,Contact,CaelumPortStoryData.GUARD_REPEAT),"real guard conversation opens with the reporting choices");
        }
        else if(e.Name=="ca450_reportaction")
        {
            let user=CaelumPlayer(players[0].mo);
            Check(CaelumPortStory.GuardSpeaker(user)==Contact,"actual native conversation validates the reporting contact");
            user.GiveInventoryType('CaelumBattleDeliveryAction');
            Check(user.GetPersistentCharacterState(false).FactionReputation[0]==Reputation[0]+50,"native dialogue delivery action cannot duplicate the reward");
            Console.Printf("CA450 DIALOGUE %s failures=%d",Failures==0?"PASS":"FAIL",Failures);
        }
    }
}
