class CA415RallySoldier : CaelumPortDefender {override void Tick(){}}
class CA415RallyChecks : EventHandler
{
    int Passed,Failed;
    void Check(bool ok,String label){if(ok)Passed++;else Failed++;Console.Printf("CA415R %s %s",ok?"PASS":"FAIL",label);}
    void Verify(CaelumPlayer u)
    {
        let setup=new('CA410ReviewChecks');setup.Profile(u);u.SetOrigin((0,0,0),false);
        Check(CaelumRally.Strongest(u)==null && CaelumRally.Factor(u)==1,"no active cast has neutral factor");
        let effect=CaelumRallyEffect(u.GiveInventoryType('CaelumRallyEffect'));
        effect.Revision=CaelumRally.REVISION;effect.Power=2;effect.Range=128;effect.RemainingTics=35000;effect.PulseTics=35000;
        Check(CaelumRally.Strongest(u)==effect,"active player inventory supplies cast");
        u.CurrentAdrenaline=0;Check(CaelumRally.Factor(u)==2,"zero adrenaline retains cast power");
        u.CurrentAdrenaline=u.DerivedStats.MaximumAdrenaline;Check(CaelumRally.Factor(u)==4,"full adrenaline doubles cast power");
        Check(CaelumRally.DamageFactor(u,null)==.25,"illness keeps current defensive factor");
        let body=CA415RallySoldier(Actor.Spawn('CA415RallySoldier',(64,0,0)));
        body.bFriendly=true;body.FriendPlayer=u.PlayerNumber()+1;body.bIsMonster=true;
        body.MaximumCombatAdrenaline=100;body.CurrentCombatAdrenaline=0;
        Check(CaelumRally.Eligible(effect,body) && CaelumRally.Strongest(body)==effect,"near allied NPC receives same active cast");
        CaelumRally.Pulse(effect);Check(Abs(body.CurrentCombatAdrenaline-20)<.0001,"spatial pulse recovers once");
        body.SetOrigin((300,0,0),false);body.CurrentCombatAdrenaline=0;CaelumRally.Pulse(effect);
        Check(body.CurrentCombatAdrenaline==0 && CaelumRally.Strongest(body)==null,"out of range NPC excluded");
        body.SetOrigin((64,0,0),false);body.A_ChangeLinkFlags(1,0);
        let population=CaelumPopulationState.Get();let entry=new('CaelumSiegeCombatant');entry.Body=body;
        body.SiegeCombatant=entry;population.UnlinkedGuards.Push(entry);
        CaelumRally.Pulse(effect);Check(Abs(body.CurrentCombatAdrenaline-20)<.0001,"unlinked guard retains pulse through shared registry");
        body.health=0;Check(CaelumRally.Strongest(body)==null,"dead body excluded");body.Destroy();
        effect.RemainingTics=0;Check(CaelumRally.Strongest(u)==null,"expired cast excluded");effect.RemainingTics=35000;
        effect.Revision=0;Check(CaelumRally.Strongest(u)==null,"invalid revision excluded");effect.Revision=CaelumRally.REVISION;
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=="ca415rally_checks")Verify(u);
        else if(e.Name=="ca415rally_load")
        {let effect=CaelumRally.Status(u);Check(effect!=null && effect.Power==2 && CaelumRally.Strongest(u)==effect,"native saved cast restores without registry migration");}
        else return;
        Console.Printf("CA415R RESULT passed=%d failed=%d",Passed,Failed);
    }
}
