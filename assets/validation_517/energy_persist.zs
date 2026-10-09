// This fixture also compiles on the preserved pre-energy runtime.
class CA136EnergyPersist : StaticEventHandler
{
    int Elapsed;
    double Expected,InitialAction,InitialPending;
    bool Complete;
    const MODE=0;
    override void WorldLoaded(WorldEvent e){Elapsed=0;Complete=false;}
    override void WorldTick()
    {
        let u=CaelumPlayer(players[0].mo);if(u==null)return;Elapsed++;
        if(MODE==0 && level.time==1)
        {
            u.InitializeDirectMapCharacter();u.PersistCharacterState();u.bNOTARGET=true;
            let helper=new("CA136Checks");helper.Equip(u,CaelumConstants.WEAPON_TYPE_SHOTGUN);
            let ammo=Inventory(Actor.Spawn("CaelumShotgunAmmo",u.Pos));ammo.Amount=100;ammo.AttachToOwner(u);
            u.OnNativeInventoryChanged();u.SetRangedMagazineCount(CaelumConstants.WEAPON_TYPE_SHOTGUN,0);
        }
        let t=CaelumThermalBody.Get(u,true);if(t==null)return;
        if(MODE==0 && Elapsed==70)
        {
            t.Exposure=2;t.Acclimation=15;u.Attributes.Resilience=100;
            u.RequestRangedReload(CaelumConstants.WEAPON_TYPE_SHOTGUN);
            Console.Printf("CA136 ENERGY SAVE SEED revision=%d duration=%.9f",t.Revision,u.RangedReloadTotalSeconds);
        }
        if(MODE==2 && Elapsed==1)
        {
            Complete=true;
            Console.Printf("CA136 ENERGY ROLLBACK %s E=%.9f acclimation=%.9f actionJ=%.9f pendingJ=%.9f remaining=%.9f revision=%d",t.Revision==7 && t.Acclimation>14.9 && u.RangedReloadActive ? "PASS" : "FAIL",t.Exposure,t.Acclimation,t.ActionJoules,t.PendingFirearmJoules,u.RangedReloadRemainingSeconds,t.Revision);
        }
        if(MODE==1 && Elapsed==1)
        {
            InitialAction=t.ActionJoules;InitialPending=t.PendingFirearmJoules;
            Expected=t.SurfaceArea*327.375*u.RangedReloadRemainingSeconds/u.RangedReloadTotalSeconds;
            Console.Printf("CA136 ENERGY SAVE LOADED E=%.9f acclimation=%.9f actionJ=%.9f pendingJ=%.9f remaining=%.9f total=%.9f futureJ=%.9f revision=%d",t.Exposure,t.Acclimation,InitialAction,InitialPending,u.RangedReloadRemainingSeconds,u.RangedReloadTotalSeconds,Expected,t.Revision);
        }
        if(MODE==1 && Elapsed>1 && !Complete && !u.RangedReloadActive)
        {
            Complete=true;
            // The final progress may remain queued until the next player update.
            double result=t.ActionJoules+t.PendingFirearmJoules-InitialAction-InitialPending;
            Console.Printf("CA136 ENERGY SAVE %s actual=%.9f expected=%.9f acclimation=%.9f multiplier=%.9f",Abs(result-Expected)<0.00001 && t.Acclimation>10 && t.Revision==8 ? "PASS" : "FAIL",result,Expected,t.Acclimation,t.AcclimationMultiplier);
        }
    }
}
