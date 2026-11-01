// #415: el mismo cono y potencia del aliento, sin emitir sprites ni buscar
// actores globalmente. Los contactos se confirman al final de la ronda.
class CaelumAbsentBreath : Object play
{
    static bool Needed(CaelumAbsentCombatant row)
    {
        let body=row.Body;
        return row.Alive() && CaelumDemonService.Supports(body)
            && (body.DemonBreath!=null || CaelumBolas.Restrained(body)
                || (body.ThermalState!=null && body.ThermalState.Exposure<0 && body.ThermalState.Severity>0));
    }

    static bool Advance(CaelumAbsentCombatant row,double seconds)
    {
        let body=row.Body;
        if(!CaelumDemonService.Supports(body))return false;
        bool ropes=CaelumBolas.Restrained(body);
        bool blocked=CaelumBattleCry.Active(body) || CaelumTelekinesisRules.Held(body)
            || body.health<=0 || body.ForcedSleepTics>0 || body.CombatLucidityPhysicalStunRemaining>0
            || body.RecoveryPhase==1 || row.PainRemaining>0
            || body.CaelumDiagnosticPassiveAI || body.CaelumMassAIScheduleActive
            || (ropes && body.ElementalStatus!=null && body.ElementalStatus.IsLightningStunned())
            || (body.SiegeCombatant!=null && body.SiegeCombatant.Withdrawing && !CaelumRedemption.PreviouslyRaised(body));
        bool cold=body.ThermalState!=null && body.ThermalState.Exposure<0 && body.ThermalState.Severity>0;
        bool combat=!blocked && body.RecoveryPhase==0 && row.Enemy(row.Opponent)
            && row.Opponent.Body.bShootable && CaelumDemonBreath.CanReach(body,row.Opponent.Body);
        if(blocked || (!ropes && !cold && !combat))
        {CaelumDemonService.StopBreath(body,!CaelumBattleCry.Active(body),false);return false;}
        // La preparacion y recuperacion de un ataque ya iniciado se completan.
        if(!ropes && body.DemonBreath==null && (row.Preparing || row.Remaining>0))return false;
        double cost=body.GetMagicAnimaCost(CaelumDemonBreathRules.ANIMA_PER_SECOND);
        double paid=cost>0?Min(seconds,body.CurrentCombatAnima/cost):seconds;
        if(paid<=0){CaelumDemonService.StopBreath(body,true,false);return false;}
        if(combat){row.NextFacing=body.AngleTo(row.Opponent.Body);body.Angle=row.NextFacing;}
        if(body.DemonBreath==null)
        {
            body.DemonBreath=CaelumDemonBreath(Actor.Spawn('CaelumDemonBreath',body.Pos,NO_REPLACE));
            if(body.DemonBreath==null)return false;
            body.DemonBreath.Emitter=body;
        }
        let flame=body.DemonBreath;
        flame.EnsureContactHeat();flame.TotalPaidSeconds+=paid;
        body.CurrentCombatAnima=Max(0.0,body.CurrentCombatAnima-cost*paid);
        flame.SetOrigin(CaelumDemonBreath.Mouth(body),false);
        flame.Direction=(Cos(body.Angle),Sin(body.Angle),0);
        // PaidTick apunta tambien durante el calentamiento por frio, aunque
        // el emisor este descansando y no haya elegido un aliento ofensivo.
        if(row.Enemy(row.Opponent) && CaelumDemonBreath.CanReach(body,row.Opponent.Body))
        {
            vector3 ray=row.Opponent.Body.Pos+(0,0,row.Opponent.Body.Height/2)-flame.Pos;
            if(ray.Length()>0)flame.Direction=ray/ray.Length();
        }
        if(ropes)row.PendingSelfFire=true;
        Array<CaelumAbsentCombatant> touched;Array<double> watts;double sum=0;
        Array<CaelumAbsentCombatant> nearby;
        row.Battle.Nearby(flame.Pos,CaelumDemonBreathRules.Range(),nearby);
        for(int n=0;n<nearby.Size();n++)
        {
            let recipient=nearby[n];let other=recipient.Body;
            if(!flame.Contact(other) || !CaelumRedemption.AllowsDamage(body,other))continue;
            let thermal=CaelumThermalBody.Get(other,true);
            if(thermal!=null && thermal.SurfaceArea<=0)CaelumThermalBody.Refresh(other,thermal);
            double received=thermal!=null?flame.ReceivedWatts(other,thermal):0;
            touched.Push(recipient);watts.Push(received);sum+=received;
        }
        double budget=CaelumDemonBreathRules.Watts()*CaelumThermalData.FIRE_RADIATIVE_FRACTION;
        double scale=sum>budget?budget/sum:1;
        for(int i=0;i<touched.Size();i++)
        {
            touched[i].BreathSources.Push(body);
            touched[i].BreathWatts.Push(watts[i]*scale*CaelumThermalMagic.AreaRetention(touched[i].Body));
        }
        return true;
    }

    static void Commit(CaelumAbsentCombatant row)
    {
        if(row.PendingSelfFire)CaelumBolas.FireContact(row.Body);
        for(int i=0;i<row.BreathSources.Size();i++)
        {
            let source=row.BreathSources[i];
            CaelumElementalStream.ApplyContact(source,row.Body);
            let status=row.Body.ElementalStatus;
            double power=CaelumElementalStream.Power(source);
            if(status!=null)status.ApplyBurnHeat(CaelumConstants.ELEMENTAL_BASE_DURATION_SECONDS*power,
                power,row.BreathWatts[i],row.Body);
        }
    }
}
