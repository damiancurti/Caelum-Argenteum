// Instantánea acotada de viajeros y sus compañeros. No toca inventarios,
// cuerpos ni fracciones persistentes hasta confirmar el viaje completo.
class CaelumLoversJourneyRow : Object play
{
    Actor Body;
    CaelumJourneyModel Model;
    CaelumJourneyPlan Plan;
    CaelumThermalJourney Thermal;
    Array<int> Reached;
    double Fraction;
    int InitialHealth;
    bool Aura,Immune,Nonlethal;
}
class CaelumLoversJourney : Object play
{
    Array<CaelumLoversJourneyRow> Rows;
    int Revision,PlayersCount;
    bool Committed;

    static bool Equipped(CaelumPlayer user)
    {return user!=null && CaelumTarotLoadout.Passive(user.GetPersistentCharacterState(false),6);}
    int Index(Actor body)
    {for(int i=0;i<Rows.Size();i++)if(Rows[i].Body==body)return i;return -1;}
    void Add(CaelumPlayer user,CaelumJourneyPlan plan)
    {
        Revision=CaelumMajorArcanaData.LOVERS_REVISION;
        let row=new('CaelumLoversJourneyRow');row.Body=user;row.Plan=plan;Rows.Push(row);PlayersCount++;
    }
    void Policy(CaelumLoversJourneyRow row)
    {
        row.InitialHealth=row.Body.health;
        let remainder=CaelumLoversRemainder(row.Body.FindInventory('CaelumLoversRemainder'));
        row.Fraction=remainder!=null?remainder.DamageFraction:0;
        row.Immune=CaelumTarotLovers.Immune(row.Body,1);
        let user=CaelumPlayer(row.Body);let npc=CaelumCombatActor(row.Body);
        row.Nonlethal=row.Body.bBuddha;
        if(user!=null)row.Nonlethal=row.Nonlethal || CaelumTutorialSafety.Protects(user)
            || (user.player.cheats&(CF_BUDDHA|CF_BUDDHA2))!=0;
        if(npc!=null)
        {
            let policy=new('CaelumContaminationAbsence');policy.NativePolicy(npc);
            row.Immune=row.Immune || policy.Immune;row.Nonlethal=row.Nonlethal || policy.Nonlethal;
        }
    }
    void CaptureLinks()
    {
        // Las distancias/visibilidad son las de salida, como el resto del viaje
        // abstracto. No se inventa movimiento ni se consulta toda la población.
        for(int i=0;i<PlayersCount;i++)
        {
            let user=CaelumPlayer(Rows[i].Body);let party=CaelumCompanionParty.Get(user);
            if(party==null)continue;
            for(int n=0;n<party.Roster.Size();n++)
            {
                let bond=party.Roster[n];
                if(bond==null || !bond.Enlisted || bond.SlotReleased || bond.Parked
                    || bond.Order!=CaelumCompanionData.FOLLOW || !CaelumTarotLovers.Living(bond.Body)
                    || Index(bond.Body)>=0)continue;
                let row=new('CaelumLoversJourneyRow');row.Body=bond.Body;row.Model=new('CaelumJourneyModel');
                row.Model.Health=bond.Body.health;row.Model.MaxHealth=CaelumTarotLovers.MaximumHealth(bond.Body);
                Rows.Push(row);
            }
        }
        for(int i=0;i<Rows.Size();i++)Policy(Rows[i]);
        for(int i=0;i<PlayersCount;i++)
        {
            let row=Rows[i];let caster=CaelumPlayer(row.Body);row.Aura=Equipped(caster);
            if(!row.Aura)continue;
            double radius=CaelumMajorArcanaData.AREA_METERS*CaelumPhysicsUnits.MAP_UNITS_PER_METER
                *Max(0.0,caster.DerivedStats.AbilityRangePercent)/100.0;
            for(int n=0;n<Rows.Size();n++)if(CaelumTarotLovers.Reached(caster,Rows[n].Body,radius))row.Reached.Push(n);
        }
    }
    bool Run(bool needed,int limitTics=0)
    {
        for(int i=0;i<PlayersCount;i++)
        {
            let row=Rows[i];let user=CaelumPlayer(row.Body);let plan=row.Plan;
            row.Model=new('CaelumJourneyModel');row.Model.Capture(user,needed);
            row.Model.Lovers=self;row.Model.LoversIndex=i;row.Thermal=new('CaelumThermalJourney');
            int region=CaelumWeatherRules.RegionForLocation(CaelumWorldCatalogue.ConnectionDestination(plan.ConnectionId));
            if(!row.Thermal.Begin(user,plan.TravelMode,plan.TotalTics(),plan.SpeedKmh,region,row.Model,limitTics))
            {CaelumNotifications.Notify(user,StringTable.Localize(row.Thermal.Failure,false));return false;}
            if(needed)plan.Needed=row.Model;else {plan.Available=row.Model;plan.ThermalForecast=row.Thermal;}
        }
        CaptureLinks();
        int elapsed=0;bool dead=false;
        while(PlayersCount>0 && elapsed<Rows[0].Thermal.End && !dead)
        {
            for(int i=0;i<PlayersCount;i++)
            {
                let row=Rows[i];
                if(row.Model.Health>0)
                {
                    if(!row.Thermal.Next(row.Model))
                    {CaelumNotifications.Notify(CaelumPlayer(row.Body),StringTable.Localize(row.Thermal.Failure,false));return false;}
                }
                else
                {
                    bool sleeping=elapsed%(24*CaelumWorldClock.TicsPerHour())>=CaelumJourneyRules.WALK_HOURS*CaelumWorldClock.TicsPerHour();
                    row.Model.WalkTics+=int(!sleeping || row.Plan.TravelMode==CaelumJourneyState.MODE_SHIP);
                    row.Model.SleepTics+=int(sleeping);
                }
            }
            elapsed++;
            // Una baja interrumpe a todos en el mismo tic, incluso si ocurrió
            // antes de que llegara el turno de otro modelo en este paso.
            for(int i=0;i<PlayersCount;i++)
            {Rows[i].Model.ElapsedTics=elapsed;if(Rows[i].Model.Health<=0)dead=true;}
        }
        return true;
    }
    void Subtract(int index,int amount)
    {
        let row=Rows[index];
        row.Model.Health=Max(row.Nonlethal?1:0,row.Model.Health-amount);
    }
    void Damage(int original,int amount)
    {
        if(amount<=0 || original<0 || original>=Rows.Size())return;
        let source=Rows[original];if(source.Model.Health<=0)return;
        Array<int> recipients;
        if(!source.Immune)for(int c=0;c<PlayersCount;c++)
        {
            let caster=Rows[c];
            if(!caster.Aura || caster.Model.Health<=0 || caster.Reached.Find(original)>=caster.Reached.Size())continue;
            for(int n=0;n<caster.Reached.Size();n++)
            {
                int index=caster.Reached[n];
                if(Rows[index].Model.Health>0 && recipients.Find(index)>=recipients.Size())recipients.Push(index);
            }
        }
        if(recipients.Size()<=1){Subtract(original,amount);return;}
        double portion=double(amount)/recipients.Size();
        for(int i=0;i<recipients.Size();i++)
        {
            int index=recipients[i];let row=Rows[index];if(index!=original && row.Immune)continue;
            double total=row.Fraction+portion;int whole=int(total+1e-8);row.Fraction=Max(0.0,total-whole);
            Subtract(index,whole);
        }
    }
    static bool SameParticipants(CaelumLoversJourney first,CaelumLoversJourney second)
    {
        if(first==null || second==null)return first==second;
        if(first.Rows.Size()!=second.Rows.Size())return false;
        for(int i=0;i<first.Rows.Size();i++)
        {
            let a=first.Rows[i],b=second.Rows[i];
            if(a.Body!=b.Body || a.Aura!=b.Aura || a.Immune!=b.Immune || a.Nonlethal!=b.Nonlethal
                || (a.Model.Health<=0)!=(b.Model.Health<=0) || a.Reached.Size()!=b.Reached.Size())return false;
            for(int n=0;n<a.Reached.Size();n++)if(a.Reached[n]!=b.Reached[n])return false;
        }
        return true;
    }
    void Commit()
    {
        if(Revision<CaelumMajorArcanaData.LOVERS_REVISION)Revision=CaelumMajorArcanaData.LOVERS_REVISION;
        if(Committed)return;Committed=true;
        for(int i=0;i<Rows.Size();i++)
        {
            let row=Rows[i];let body=row.Body;if(body==null || body.bDestroyed)continue;
            let remainder=CaelumLoversRemainder(body.FindInventory('CaelumLoversRemainder'));
            if(remainder==null && row.Fraction>0)remainder=CaelumLoversRemainder(body.GiveInventoryType('CaelumLoversRemainder'));
            if(remainder!=null){remainder.Revision=CaelumMajorArcanaData.LOVERS_REVISION;remainder.DamageFraction=row.Fraction;}
            // Los compañeros conservan la simulación previa del viaje: este
            // adaptador añade sólo su porción recibida, con muerte nativa.
            let npc=CaelumCombatActor(body);
            if(npc!=null && row.InitialHealth>row.Model.Health)
                npc.ApplyLoversDamage(null,null,row.InitialHealth-row.Model.Health,'CaelumSurvival');
        }
    }
}
