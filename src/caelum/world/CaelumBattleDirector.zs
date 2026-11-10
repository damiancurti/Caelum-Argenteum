// Una identidad guardada por soldado. Perder una referencia no confirma su muerte.
class CaelumBattleDefender : Object play
{
    CaelumBattleDirector Director;
    CaelumPortDefender Body;
    int ResidentIdentity;
    bool ConfirmedDead;
}

// #447: el encuentro conserva sus actores y reservas; el director coordina hechos.
class CaelumBattleDirector : Object play
{
    CaelumPortSiege Encounter;
    Array<CaelumBattleDefender> Defenders;
    int Revision,Phase,Serial,DefeatCount,VictoryCount,WaveCount;
    bool DefendersDirty,ClockReady,Started,Defeated,Won;
    double StartCivil,LastCivil,NextWaveCivil,DefeatCivil,VictoryCivil;

    static double CivilNow(CaelumPortSiege port)
    {
        if(port!=null && port.AbsentBattle!=null && port.AbsentBattle.Busy)
            return port.AbsentBattle.SimulationTime;
        for(int i=0;i<MAXPLAYERS;i++)
        {
            if(!playeringame[i])continue;
            let user=CaelumPlayer(players[i].mo);if(user==null)continue;
            double now=CaelumHouseAwayWork.Civil(user);
            if(now>=0)return now;
        }
        return -1;
    }

    void RegisterDefender(CaelumPortDefender body)
    {
        if(body==null)return;
        if(body.MilitaryGroup!=null)body.MilitaryGroup.Formation.PulseReady=false;
        let row=body.BattleDefender;
        if(row==null || row.Director!=self)
        {
            row=null;
            // Reanclar una identidad residente tras viajar no crea otro soldado.
            if(body.HomeRevision>0)
                for(int i=0;i<Defenders.Size();i++)
                    if(Defenders[i].ResidentIdentity==body.HomeIdentity){row=Defenders[i];break;}
            if(row==null)
            {
                row=new('CaelumBattleDefender');row.Director=self;
                row.ResidentIdentity=body.HomeRevision>0?body.HomeIdentity:-1;
                Defenders.Push(row);
            }
            body.BattleDefender=row;
        }
        row.Body=body;row.ConfirmedDead=body.health<=0;DefendersDirty=true;
    }

    static void DefenderChanged(CaelumPortDefender body)
    {
        if(body==null)return;
        if(body.MilitaryGroup!=null)body.MilitaryGroup.Formation.PulseReady=false;
        let row=body.BattleDefender;
        if(row==null && body.Port!=null && body.Port.Director!=null)
        {body.Port.Director.RegisterDefender(body);row=body.BattleDefender;}
        if(row==null)return;
        row.ConfirmedDead=body.health<=0;
        if(row.Director!=null)row.Director.DefendersDirty=true;
    }

    void Initialize(CaelumPortSiege port,double now)
    {
        Encounter=port;
        if(Revision>=CaelumBattleData.REVISION)return;
        Revision=CaelumBattleData.REVISION;Phase=CaelumBattleData.PREPARING;
        // Reconstrucción única y acotada desde el plantel propio, nunca del mapa.
        for(int i=0;i<port.Defenders.Size();i++)RegisterDefender(port.Defenders[i]);
        let residents=CaelumHouseResidents.Get();
        if(CaelumHouseHub.IsCity(port) && residents!=null)
            for(int i=0;i<residents.Residents.Size();i++)
            {
                let entry=residents.Residents[i];
                if(!entry.ExcludedFromDeployment)RegisterDefender(entry.Body);
            }
        Started=port.SiegeStarted;
        StartCivil=CaelumCityWorld.SiegeCivilSeconds();
        if(Started)Phase=CaelumBattleData.ACTIVE;
        if(now>=0)
        {
            LastCivil=now;ClockReady=true;
            double delay=port.Reinforcements!=null
                ?Max(0,port.Reinforcements.NextOpportunity-level.time)/double(TICRATE):0;
            NextWaveCivil=Started?now+delay*3600.0/CaelumConstants.REAL_SECONDS_PER_GAME_HOUR:StartCivil;
        }
        if(port.Victory)
        {
            Won=true;Phase=CaelumBattleData.VICTORY;VictoryCount=1;
            // La migración no inventa la fecha exacta de una victoria antigua.
            VictoryCivil=-1;
        }
        DefendersDirty=true;
    }

    void ObserveStart(double now)
    {
        if(Started)return;
        Started=true;Phase=CaelumBattleData.ACTIVE;Serial++;
        if(now>=0){ClockReady=true;LastCivil=now;NextWaveCivil=now;}
        DefendersDirty=true;
    }

    bool Resolved(){return Defeated || Won;}

    void Observe(double now)
    {
        if(now>=0)LastCivil=Max(LastCivil,now);
        if(Encounter.SiegeStarted && !Started)ObserveStart(now);
        if(!Started)return;
        if(Encounter.Victory && !Won)
        {
            Won=true;VictoryCount++;VictoryCivil=now;Serial++;
            Phase=Defeated?CaelumBattleData.LIBERATED:CaelumBattleData.VICTORY;
        }
        if(Resolved())
        {
            if(Encounter.Reinforcements!=null)Encounter.Reinforcements.Stopped=true;
            return;
        }
        if(!DefendersDirty)return;
        let residents=CaelumHouseResidents.Get();
        if(CaelumHouseHub.IsCity(Encounter) && residents!=null && residents.DeploymentPending)return;
        DefendersDirty=false;
        if(Defenders.Size()==0)return;
        for(int i=0;i<Defenders.Size();i++)
        {
            let row=Defenders[i];
            if(row.Body!=null && row.Body.health>0)row.ConfirmedDead=false;
            if(!row.ConfirmedDead)return;
        }
        Defeated=true;DefeatCount++;DefeatCivil=now;Serial++;
        Phase=CaelumBattleData.DEFEAT;
        if(Encounter.Reinforcements!=null)Encounter.Reinforcements.Stopped=true;
    }

    bool WaveDue(double now)
    {
        if(!Started || Resolved() || now<0)return false;
        if(!ClockReady)
        {
            double delay=Encounter.Reinforcements!=null
                ?Max(0,Encounter.Reinforcements.NextOpportunity-level.time)/double(TICRATE):0;
            ClockReady=true;
            NextWaveCivil=now+delay*3600.0/CaelumConstants.REAL_SECONDS_PER_GAME_HOUR;
        }
        return now+CaelumBattleData.CLOCK_EPSILON>=NextWaveCivil;
    }

    void RecordWave(double now)
    {
        // Una oportunidad bloqueada tampoco acumula tandas al volver al mapa.
        ClockReady=true;LastCivil=Max(LastCivil,now);
        NextWaveCivil=now+CaelumBattleData.WaveCivilSeconds();WaveCount++;
    }
}
