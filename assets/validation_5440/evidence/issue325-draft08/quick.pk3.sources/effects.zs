// Parámetros diagnósticos locales; no modifican los datos de combate.
class CA325Effects : CA325Probe
{
    int Kind,MarkTic,MarkSerial,MarkHealth;
    double MarkRemaining,MarkHeat,MarkThermal;

    double Remaining()
    {
        let s=User.ElementalStatus;
        return Kind==0?s.BurnRemaining:Kind==1?s.CutRemaining:Kind==2?s.PoisonRemaining
            :Kind==3?s.DiseaseRemaining:s.BurnHeatRemaining;
    }

    void Mark()
    {
        MarkTic=level.maptime;MarkSerial=CaelumTimeAdvanceState.StepSerial(User);
        MarkHealth=User.health;MarkRemaining=Remaining();
        let thermal=CaelumThermalBody.Get(User,true);
        MarkHeat=thermal.AbsorbedContinuousJoules+User.ElementalStatus.PendingBurnHeatJoules;
        MarkThermal=thermal.AppliedDamageHP;
    }

    void EffectCheck(bool skipping)
    {
        int steps=level.maptime-MarkTic+CaelumTimeAdvanceState.StepSerial(User)-MarkSerial;
        let thermal=CaelumThermalBody.Get(User,true);
        let advance=CaelumTimeAdvanceState.Get(User);
        let skip=CaelumTimeSkipState.Get(User);
        Console.Printf("CA325 EFFECT kind=%d steps=%d remaining=%.9f->%.9f health=%d->%d heat=%.9f thermal=%.6f T=%d Y=%d",Kind,steps,MarkRemaining,Remaining(),MarkHealth,User.health,thermal.AbsorbedContinuousJoules+User.ElementalStatus.PendingBurnHeatJoules-MarkHeat,thermal.AppliedDamageHP-MarkThermal,advance!=null && advance.Active,skip!=null && skip.Active);
        Check(steps>104,"effect observation includes accelerated personal steps");
        if(Kind<5)Check(Abs(MarkRemaining-Remaining()-double(steps)/TICRATE)<0.000001,"effect duration consumes every native and accelerated personal tic");
        if(Kind<4 || Kind==5)Check(User.health<MarkHealth,"ongoing state causes real health loss during acceleration");
        if(Kind==4)Check(Abs(thermal.AbsorbedContinuousJoules+User.ElementalStatus.PendingBurnHeatJoules-MarkHeat-350.0*steps/TICRATE)<0.00001,"integrated plus pending burn heat accounts for every personal tic once");
        if(Kind==5)Check(thermal.AppliedDamageHP>MarkThermal,"thermal damage continues during accelerated rest");
        Check(skipping ? skip!=null && skip.Completed && skip.LastReason=="CA_SKIP_COMPLETE"
            : advance!=null && advance.Active && CaelumRestState.IsSleeping(User),"periodic state does not interrupt the authorized rest mode");
    }

    override void NetworkProcess(ConsoleEvent e)
    {
        Super.NetworkProcess(e);
        if(e.Name=="c325_effectseed")
        {
            Kind=e.Args[0];User.ElementalStatus=new("CaelumElementalStatus");
            if(Kind<4)User.ElementalStatus.ApplyDamageOverTime(Kind==3?CaelumConstants.ELEMENTAL_EFFECT_DISEASE:Kind,60,1,2,null,User);
            if(Kind==4)User.ElementalStatus.ApplyBurnHeat(60,1,350);
            if(Kind==5)
            {
                let thermal=CaelumThermalBody.Get(User,true);
                thermal.Exposure=CaelumThermalRules.Threshold(2,User.Attributes.Toughness);
            }
            Check(CaelumRestState.BlockReason(User)=="","ongoing state permits beginning rest");
        }
        if(e.Name=="c325_effectmark")Mark();
        if(e.Name=="c325_effectcheck")EffectCheck(e.Args[0]!=0);
        if(e.Name=="c325_newattack")
        {
            let rest=CaelumRestState.Get(User);
            int before=User.health;User.bInvulnerable=true;
            User.DamageMobj(null,null,1,'None',DMG_NO_ARMOR,0);
            Check(User.health==before,"new attack is completely mitigated in this control");
            Check(!CaelumRestState.IsActive(User) && !CaelumTimeAdvanceState.Get(User).Active
                && !CaelumTimeSkipState.IsActive(User),"new attack interrupts rest and acceleration even without HP loss");
            User.bInvulnerable=false;
        }
        if(e.Name=="c325_migratepain")
        {
            CaelumRestState.Cancel(User);CaelumTimeSkipState.FinishSkip(User,"CA_SKIP_CANCELLED",true);
            User.LucidityPhysicalStunRemaining=0;User.PainImmobilizationRemaining=0.2;
            User.RestDamageRevision=0;CaelumRestSafety.EnsureDamageState(User);
            Check(User.RestDamageRevision==1 && User.RestNonPeriodicPainRemaining==0.2 && User.RestPeriodicPainRemaining==0,"legacy unidentified pain migrates conservatively once");
            CaelumRestSafety.RecordPain(User,0.3,true);User.PainImmobilizationRemaining=0.3;
            Check(!CaelumRestSafety.PeriodicPainOnly(User),"longer periodic pain never reclassifies previous physical pain");
            for(int i=0;i<8;i++)CaelumPlayerResources.UpdatePainImmobilization(User);
            Check(CaelumRestSafety.PeriodicPainOnly(User),"periodic pain becomes eligible only after original physical pain expires");
            double remaining=User.RestPeriodicPainRemaining;CaelumRestSafety.EnsureDamageState(User);
            Check(User.RestPeriodicPainRemaining==remaining,"damage migration is idempotent");
        }
        if(e.Name=="c325_die")
        {
            User.health=User.player.health=1;
            if(e.Args[0]==0)User.ElementalStatus.DealStatusDamage(User,null,10);
            else CaelumThermalService.ApplyDamage(User,CaelumThermalBody.Get(User,true),100);
            Check(User.health<=0 && User.player.playerstate!=PST_LIVE,"periodic damage retains native death");
            Check(!CaelumRestState.IsActive(User) && !CaelumTimeAdvanceState.Get(User).Active
                && !CaelumTimeSkipState.IsActive(User),"death terminates all rest and acceleration modes");
        }
    }
}
