class CA429Body : CaelumCombatActor
{
    override void Tick() { }
    Default { Health 100; Radius 16; Height 56; Speed 4; +SHOOTABLE +SOLID +ISMONSTER }
    States { Spawn: TNT1 A -1; Stop; See: TNT1 A -1; Stop; }
}

class CA429Port : CaelumPortSiege
{
    override void Tick() { }
}
class CA429Machine : CaelumHostileMachine
{
    override void Tick() { }
    Default { Health 100; Radius 8; Height 8; +NOBLOCKMAP }
    States { Spawn: TNT1 A -1; Stop; }
}

class CA429Checks : EventHandler
{
    CaelumFormation Group;
    Array<CA429Body> Bodies;
    int Passes,Failures;
    void Check(bool ok,String label)
    {if(ok){Passes++;Console.Printf("CA429 PASS %s",label);}else{Failures++;Console.Printf("CA429 FAIL %s",label);}}
    CA429Body SpawnBody(int index)
    {
        let body=CA429Body(Actor.Spawn("CA429Body",(-1000+(index%20)*60,-1000+(index/20)*60,0),NO_REPLACE));
        body.CombatEffectiveInsight=0;body.CombatAgility=0;
        return body;
    }
    void Seed()
    {
        let user=CaelumPlayer(players[0].mo);
        user.CharacterCreationComplete=true;user.CreationWizardOpen=false;user.ApplyCharacterProfile();
        user.bInvulnerable=true;user.bNoClip=true;user.bShootable=false;user.SetOrigin((-1500,-1500,0),false);
        Group=new("CaelumFormation");Group.Initialize();
        for(int i=0;i<9;i++)
        {let body=SpawnBody(i);body.A_SetSize(8+8*(i%3),56);Bodies.Push(body);Group.Add(body,i/3,i==0 || i==4 ? 1 : 2);}
        Group.Refresh();
        Check(Group.Leader.Body==Bodies[0] && Group.Members.Size()==9,"stable initial leader and membership");
        for(int shape=0;shape<4;shape++)
        {
            Group.SetShape(shape);Group.Layout();bool separated=true;
            Check(Group.Shape==shape,String.Format("select shape %d",shape));
            for(int a=0;a<Group.Members.Size();a++)for(int b=a+1;b<Group.Members.Size();b++)
            {
                let first=Group.Members[a];let second=Group.Members[b];
                double required=first.Body.Radius+second.Body.Radius+CaelumPhysicsUnits.MapUnits(shape==3?1.0:0.5);
                if((first.Offset-second.Offset).Length()+0.000001<required)separated=false;
            }
            Check(separated,String.Format("shape %d collision clearance",shape));
        }
        Group.SetShape(CaelumFormationData.LINE);Group.Layout();
        Check(Bodies[0].Formation.Offset.X>Bodies[3].Formation.Offset.X
            && Bodies[3].Formation.Offset.X>Bodies[6].Formation.Offset.X,"melee support ranged role rows");
        Group.SingleFile=true;Group.LayoutDirty=true;Group.Layout();bool column=true;
        for(int i=0;i<9;i++)if(Bodies[i].Formation.Offset.Y!=0)column=false;
        Check(column && Group.Shape==CaelumFormationData.LINE,"temporary column preserves selected formation");
        Bodies[0].health=0;Group.PulseReady=false;Group.Refresh();
        Check(Group.Leader.Body==Bodies[4] && Group.Members.Size()==8,"death releases formation and successor uses priority");
        Check(!Bodies[0].bDestroyed && Bodies[0].Formation==null,"dead body remains available with belongings");
        Bodies[4].ForcedSleepTics=100;Group.PulseReady=false;Group.Refresh();
        Check(Group.Leader.Body==Bodies[1],"unconscious leader replaced by stable membership order");
        int order=Bodies[2].Formation.Order;
        Group.Remove(Bodies[3].Formation);Group.PulseReady=false;Group.Refresh();
        Check(Bodies[2].Formation.Order==order && Bodies[3].Formation==null,"removal does not renumber surviving identities");
        for(int i=1;i<9;i++)Bodies[i].ForcedSleepTics=100;
        Group.PulseReady=false;Group.Refresh();Check(Group.Retreat && Group.Leader==null,"no capable leader causes retreat");
        for(int i=1;i<9;i++)Bodies[i].ForcedSleepTics=0;
        Group.PulseReady=false;Group.Refresh();Group.SingleFile=false;Group.SetShape(CaelumFormationData.WEDGE);Group.Layout();
        let limited=new("CaelumFormation");limited.Initialize(true);limited.SetPlayerLeader(user);
        for(int i=0;i<9;i++)limited.Add(SpawnBody(20+i),0,2);
        Check(limited.Members.Size()==7 && limited.PlayerLeader==user,"party cap reserves the player and seven companions");
        user.bShootable=true;limited.Refresh();
        for(int shape=0;shape<4;shape++)
        {
            limited.SetShape(shape);limited.Layout();bool fits=true;
            for(int i=0;i<limited.Members.Size();i++)
                if(limited.Members[i].Offset.Length()+0.000001<user.Radius+limited.Members[i].Body.Radius
                    +CaelumPhysicsUnits.MapUnits(shape==3?1.0:0.5))fits=false;
            Check(fits && limited.Anchor()==user,String.Format("party shape %d reserves actual player collision",shape));
        }
        let military=new("CaelumFormation");military.Initialize();
        for(int i=0;i<101;i++)military.Add(SpawnBody(40+i),0,2);
        Check(military.Members.Size()==100,"military formation caps at one hundred");
        Check(CaelumFormationData.SIDE_CAPACITY==1000,"side ceiling uses existing authoritative cap");
        let fighter=Bodies[2];let enemy=SpawnBody(170);
        enemy.SetOrigin((1600,1600,0),false);Group.SingleFile=false;Group.SetShape(CaelumFormationData.LINE,true);
        fighter.SetOrigin(Group.Destination(fighter.Formation),false);
        Check(!Group.RegroupCombat(fighter.Formation,enemy) && fighter.Formation.CombatOrder==Group.OrderRevision,
            "reaching commanded slot resumes individual combat");
        fighter.SetOrigin((-100,100,0),false);
        Check(!Group.RegroupCombat(fighter.Formation,enemy),"ordinary fighting does not continuously pull a member back");
        Group.SetShape(CaelumFormationData.WEDGE,true);enemy.SetOrigin(fighter.Pos+(20,0,0),false);
        int priorOrder=fighter.Formation.CombatOrder;
        Check(!Group.RegroupCombat(fighter.Formation,enemy) && fighter.Formation.CombatOrder==priorOrder,
            "melee engagement defers the new regroup order");
        enemy.SetOrigin((1600,1600,0),false);
        Check(Group.RegroupCombat(fighter.Formation,enemy) && fighter.target==enemy,
            "clear combat interval executes pending order without replacing perceived enemy");
        let port=CA429Port(Actor.Spawn('CA429Port',(-1900,-1900,0),NO_REPLACE));
        for(int i=0;i<3;i++)
        {
            let entry=new('CaelumSiegeCombatant');entry.Body=Bodies[i+1];entry.Encounter=port;
            port.Attackers.Push(entry);
        }
        port.Boss=port.Attackers[0];
        let machine=CA429Machine(Actor.Spawn('CA429Machine',(-1900,-1800,0),NO_REPLACE));
        port.Machines.Push(machine);port.Attackers[1].CrewMachine=machine;
        Check(port.LivingHostilePopulation()==4,"census counts commander crew and machine once each");
        Bodies[3].health=0;
        Check(port.LivingHostilePopulation()==3 && !Bodies[3].bDestroyed,"census releases death without deleting corpse");
        Bodies[3].health=100;port.Attackers[2].Exited=true;
        Check(port.LivingHostilePopulation()==3,"exited body releases its side admission slot");
        let reserve=new('CaelumSiegeReinforcements');reserve.Enabled=true;reserve.Remaining=3;
        port.Reinforcements=reserve;
        reserve.Living=1001;reserve.Admit(port);
        Check(reserve.Successful==0 && reserve.Remaining==3 && !Bodies[1].bDestroyed,
            "legacy over-cap admission preserves existing bodies and reserves");
        for(int lane=0;lane<6;lane++)port.Exits.Push(CaelumSiegeRouteNode(Actor.Spawn('CaelumSiegeRouteNode',(-1900,1900,0),NO_REPLACE)));
        for(int i=0;i<3;i++)reserve.QueueCrew(machine,(-1800+i*128,-1700,0),(0,0,0),0);
        reserve.RefreshLiving(port);reserve.Admit(port);
        Check(reserve.Successful==3 && reserve.Remaining==0 && reserve.Pending==0,
            "finite reserve tail admits fewer than one hundred without duplication");
        Console.Printf("CA429 RESULT formation checks complete passes=%d failures=%d",Passes,Failures);
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="ca429_seed")Seed();
        if(e.Name=="ca429_reload")
        {
            Check(Group!=null && Group.Revision==1 && Group.Shape==CaelumFormationData.WEDGE,"saved formation revision and shape");
            Check(Group.Leader!=null && Group.Leader.Body==Bodies[4],"saved succession retains the capable priority leader after recovery");
            Check(Bodies[2].Formation.Group==Group && Bodies[2].Formation.Order==2,"saved membership preserves identity");
            Group.PulseReady=false;Group.Refresh();
            Check(Group.Members.Size()==7 && Bodies[0].health==0,"reload does not duplicate or revive bodies");
            Console.Printf("CA429 RESULT reload complete passes=%d failures=%d",Passes,Failures);
        }
    }
}
