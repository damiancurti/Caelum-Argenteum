// Una ronda conserva su orden incluso si se reparte entre varios pulsos de
// carga. Ninguna fase nativa puede actuar mientras el resumen está incompleto.
class CaelumAbsentWork : Object play
{
    CaelumAbsentBattle Battle;
    int Phase,Index;
    double End,WorldSeconds,ActiveSeconds;
    bool Complete;

    void Begin(CaelumAbsentBattle battle,double end,double seconds,bool physiology)
    {
        self.Battle=battle;self.End=end;WorldSeconds=seconds;ActiveSeconds=seconds*battle.ActiveScale;
        Phase=physiology?0:3;Index=0;Complete=false;
    }

    void Next(){Phase++;Index=0;}

    bool Advance(int limit)
    {
        if(Complete || Battle==null)return true;
        limit=Max(1,limit);
        int count=Battle.Rows.Size();
        int boundary=Index+Min(limit,Max(0,count-Index));
        switch(Phase)
        {
        case 0:
            Battle.SimulationTime=End;Battle.DeployResidents(ActiveSeconds);Battle.Reinforce(ActiveSeconds);
            Battle.Engaged=Battle.Opposed();Next();break;
        case 1:
            for(;Index<boundary;Index++)Battle.Rows[Index].Physiology(End,ActiveSeconds);
            if(Index>=count)Next();break;
        case 2:
            Phase=Battle.Opposed() || Battle.MachineWork()?3:20;Index=0;break;
        case 3:
            for(;Index<boundary;Index++)Battle.Rows[Index].ClearPending();
            if(Index>=count)Next();break;
        case 4:
            for(;Index<boundary;Index++)if(Battle.Rows[Index].Alive())Battle.Rows[Index].Recover(ActiveSeconds);
            if(Index>=count)Next();break;
        case 5:
            for(;Index<boundary;Index++)Battle.Rows[Index].BeginRound();
            if(Index>=count)Next();break;
        case 6:
            for(;Index<boundary;Index++)if(Battle.Rows[Index].Alive())Battle.Rows[Index].Act(ActiveSeconds);
            if(Index>=count)Next();break;
        case 7:
            count=Battle.Flights.Size();boundary=Index+Min(limit,Max(0,count-Index));
            for(;Index<boundary;Index++)Battle.Flights[Index].Resolve();
            if(Index>=count)Next();break;
        case 8:
            count=Battle.Machines.Size();boundary=Index+Min(limit,Max(0,count-Index));
            for(;Index<boundary;Index++)Battle.Machines[Index].Advance(ActiveSeconds);
            if(Index>=count)Next();break;
        case 9:
            for(;Index<boundary;Index++)Battle.Rows[Index].Commit();
            if(Index>=count)Next();break;
        case 10:
            count=Battle.Flights.Size();boundary=Index+Min(limit,Max(0,count-Index));
            for(;Index<boundary;Index++)Battle.Flights[Index].CommitWear();
            if(Index>=count){Battle.Flights.Clear();Next();}break;
        case 11:
            count=Battle.StructureHits.Size();boundary=Index+Min(limit,Max(0,count-Index));
            for(;Index<boundary;Index++)Battle.StructureHits[Index].Commit();
            if(Index>=count){Battle.StructureHits.Clear();Next();}break;
        case 12:
            for(;Index<boundary;Index++)Battle.Rows[Index].FinishRound();
            if(Index>=count)Next();break;
        case 13:
            count=Battle.Machines.Size();boundary=Index+Min(limit,Max(0,count-Index));
            for(;Index<boundary;Index++)Battle.Machines[Index].Observe();
            if(Index>=count)Next();break;
        case 14:
            bool won=Battle.Encounter!=null && Battle.Encounter.Victory;
            if(Battle.Encounter!=null)Battle.Encounter.ResolveVictory(true);
            let port=CaelumPortSiege(Battle.Encounter);
            if(port!=null && port.Victory && !won && Battle.SourceMap=="MAP03")port.Calendar(Battle.Observer,Battle.SimulationTime);
            Next();break;
        case 15:
            for(;Index<boundary;Index++)Battle.Rows[Index].FinishRound();
            if(Index>=count)Next();break;
        case 16:
            let controller=CaelumPortSiege(Battle.Encounter);
            if(controller!=null && !controller.Victory)controller.RefillCrews();
            let corpses=CaelumCorpseArchive.Get(true);if(corpses!=null)corpses.Tick();
            Battle.Rounds++;Complete=true;break;
        case 20:
            for(;Index<boundary;Index++)
            {
                let row=Battle.Rows[Index];if(!row.Alive())continue;
                row.Opponent=null;row.Recover(ActiveSeconds);row.FinishRound();row.Body.target=null;
                if(row.Body.ContaminationAbsence!=null)row.Body.ContaminationAbsence.Idle=true;
            }
            if(Index>=count)Complete=true;break;
        }
        return Complete;
    }
}
