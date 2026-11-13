// #454: paso de dos cuerpos máximos, guardas y retirada nativa del jefe.
class CA454CollisionBody : Actor
{
    Default { Radius 1; Height 1; +SOLID +NOGRAVITY }
    States { Spawn: TNT1 A -1; Stop; }
}

class CA454BossProbe : EventHandler
{
    bool Started,Done,Passed;
    CaelumPlayer User;
    int Age;

    bool PairPasses()
    {
        let a=Actor.Spawn("CA454CollisionBody",(-2816,-4152,0),NO_REPLACE);
        let b=Actor.Spawn("CA454CollisionBody",(-2560,-4104,0),NO_REPLACE);
        if(a==null || b==null)return false;
        a.A_SetSize(21.333333,74.7);b.A_SetSize(21.333333,74.7);
        bool ok=a.TestMobjLocation() && b.TestMobjLocation();
        for(int step=0;step<64 && ok;step++)
        {
            vector2 nextA=a.Pos.XY+(4,0),nextB=b.Pos.XY+(-4,0);
            ok=a.CheckMove(nextA,0) && b.CheckMove(nextB,0);
            if(ok){a.SetOrigin((nextA.X,nextA.Y,0),false);b.SetOrigin((nextB.X,nextB.Y,0),false);}
        }
        Console.Printf("CA454 PAIR %s A=(%.1f,%.1f) B=(%.1f,%.1f)",ok?"PASS":"FAIL",a.Pos.X,a.Pos.Y,b.Pos.X,b.Pos.Y);
        a.Destroy();b.Destroy();return ok;
    }

    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="ca454_boss_report")
        {
            if(!Done)Fail("retreat timeout");
            return;
        }
        if(e.Name!="ca454_probe" || Started)return;
        User=CaelumPlayerAuthority.FromNetworkPlayer(e.Player);
        if(User==null || !CaelumMazeLayout.IsRedesigned() || !PairPasses()){Fail("setup/pair");return;}
        User.bInvulnerable=true;
        if(CaelumSewerMaze.CanLeave(User)){Fail("departure allowed before boss");return;}
        let gate=CaelumMazeBarredGate(ActorIterator.Create(44703,"CaelumMazeBarredGate").Next());
        let boss=CaelumZupayColossus(ActorIterator.Create(43799,"CaelumZupayColossus").Next());
        if(gate==null || boss==null || gate.Opened){Fail("initial boss gate");return;}
        User.GiveInventoryType("CaelumMazeNorthKey");
        if(!gate.Open(User)){Fail("keyed boss opening");return;}
        boss.SewerFleeing=true;Started=true;
        vector3 destination=boss.EscapePosition();
        Console.Printf("CA454 BOSS retreat started pos=(%.1f,%.1f,%.1f) target=(%.1f,%.1f,%.1f)",
            boss.Pos.X,boss.Pos.Y,boss.Pos.Z,destination.X,destination.Y,destination.Z);
    }

    override void WorldTick()
    {
        if(!Started || Done)return;
        Age++;
        if(CaelumSewerMaze.BossAlive())return;
        let record=User.GetPersistentCharacterState(false);
        let card=CaelumM00FoolEssence(ActorIterator.Create(43798,"CaelumCupsAceEssence").Next());
        if(record==null || !record.SewerZupayDefeated || card==null
            || !CaelumTarotService.CanCaptureArcana(record,CaelumConstants.TAROT_CUPS_ACE)
            || CaelumSewerMaze.CanLeave(User)){Fail("post-retreat flags/card guard");return;}
        User.SetOrigin((card.Pos.X+64,card.Pos.Y,card.FloorZ),false);User.FindFloorCeiling();
        if(!CaelumTarotService.CanApproach(User,card)){Fail("card physically inaccessible");return;}
        Done=true;Passed=true;
        Console.Printf("CA454 BOSS PASS retreat_tics=%d card_reachable=1 departure_requires_card=1",Age);
        Console.Printf("CA454 NATIVE PASS map=MAP02");
    }

    void Fail(String reason)
    {
        Done=true;Passed=false;Console.Printf("CA454 NATIVE FAIL map=MAP02 reason=%s",reason);
    }
}
