// Same authorized 1,000/600 population; one pending projectile per body.
// Measures the departure-only typed census, not native frame presentation.
class CA415Performance : EventHandler
{
    CA415RoundEncounter Encounter;
    override void WorldTick()
    {
        let user=CaelumPlayer(players[0].mo);if(user==null)return;
        user.CharacterCreationComplete=true;user.CreationWizardOpen=false;user.bInvulnerable=true;
        if(level.maptime==70)
        {
            Encounter=CA415RoundEncounter(Actor.Spawn('CA415RoundEncounter',(0,0,0),NO_REPLACE));
            Encounter.SiegeStarted=true;Encounter.SetupRevision=1;
            for(int i=0;i<1600;i++)
            {
                vector3 point=(-3200+(i%50)*128,-2048+(i/50)*128,0);
                if(i<1000)Encounter.RegisterAttacker(CaelumCombatActor(Actor.Spawn('CA415RoundDemon',point,NO_REPLACE)));
                else Encounter.Defenders.Push(CaelumPortDefender(Actor.Spawn('CA415RoundSoldier',point,NO_REPLACE)));
            }
        }
        if(level.maptime==105)
        {
            let battle=new('CaelumAbsentBattle');Encounter.AbsentBattle=battle;battle.Capture(Encounter,user);
            for(int i=0;i<battle.Rows.Size();i++)
            {
                let row=battle.Rows[i];let body=row.Body;
                row.Preparing=true;row.Remaining=1000;body.CaelumDiagnosticPassiveAI=true;
                let enemy=battle.FirstOpponent(row.Friendly).Body;
                bool magic=!row.Friendly;
                let shot=CaelumActorProjectile(Actor.Spawn(magic?'CaelumActorSimpleElementalProjectile':'CaelumCarbineProjectile',body.Pos+(0,0,body.Height/2),NO_REPLACE));
                shot.target=body;shot.StoreCaelumAttackResult(100,true,false,magic,0);
                shot.StoreSummaryAim(enemy,magic?CaelumConstants.WEAPON_TYPE_STAFF:CaelumConstants.WEAPON_TYPE_CARBINE,1,1,10,magic);
                shot.StoreCaelumElementalPayload(CaelumConstants.ESSENCE_FIRE,false,100,100);
                let soldier=CaelumPortDefender(body);
                if(soldier!=null){soldier.Carbine=new('CaelumCityCarbine');soldier.Carbine.Initialize(soldier);}
            }
            double begin=MSTimeF();CaelumAbsentShot.Capture(battle);
            Console.Printf("CA415P TIMING flight_capture_ms=%.6f rows=%d flights=%d",MSTimeF()-begin,battle.Rows.Size(),battle.Flights.Size());
            begin=MSTimeF();CaelumAbsentShot.Capture(battle);
            Console.Printf("CA415P TIMING duplicate_capture_ms=%.6f flights=%d",MSTimeF()-begin,battle.Flights.Size());
            begin=MSTimeF();battle.Round();
            Console.Printf("CA415P TIMING flight_round_ms=%.6f remaining_flights=%d",MSTimeF()-begin,battle.Flights.Size());
            Console.Printf("CA415P RESULT pending volley complete");
        }
    }
}
