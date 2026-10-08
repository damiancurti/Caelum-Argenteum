// Snapshot after the original actors Tick; inspect before the first loaded tic.
class CA133DeploymentMarker : Actor
{
    Array<CaelumPortDefender> Bodies;
    Array<int> Identity,Step,Complete,Health,Magazine;
    Array<double> X,Y,Z,PostX,PostY,PostZ,Reload;
    override void Tick()
    {
        let port=CaelumPortSiege.Get();if(port==null)return;
        int count=port.Defenders.Size();
        Bodies.Resize(count);Identity.Resize(count);Step.Resize(count);Complete.Resize(count);Health.Resize(count);Magazine.Resize(count);
        X.Resize(count);Y.Resize(count);Z.Resize(count);PostX.Resize(count);PostY.Resize(count);PostZ.Resize(count);Reload.Resize(count);
        for(int i=0;i<count;i++)
        {
            let b=port.Defenders[i];Bodies[i]=b;if(b==null)continue;
            Identity[i]=b.HomeIdentity;Step[i]=b.DeploymentStep;Complete[i]=b.DeploymentComplete;Health[i]=b.health;
            X[i]=b.Pos.X;Y[i]=b.Pos.Y;Z[i]=b.Pos.Z;PostX[i]=b.Station.X;PostY[i]=b.Station.Y;PostZ[i]=b.Station.Z;
            Magazine[i]=b.Carbine.Magazine;Reload[i]=b.Carbine.ReloadRemaining;
        }
    }
    Default { +NOINTERACTION }
    States { Spawn:TNT1 A -1;Stop; }
}
class CA133DeploymentPersistence : StaticEventHandler
{
    override void WorldTick()
    {
        if(level.MapName=="MAP06" && level.time==75)
        {Actor.Spawn("CA133DeploymentMarker");Console.Printf("CA133 DEPLOYMENT_SEEDED");}
    }
    override void WorldLoaded(WorldEvent e)
    {
        if(level.MapName!="MAP06" || (!e.IsSaveGame && !e.IsReopen))return;
        let marker=CA133DeploymentMarker(ThinkerIterator.Create("CA133DeploymentMarker").Next());
        let port=CaelumPortSiege.Get();int failures=0;
        if(marker==null || port==null || marker.Bodies.Size()!=600 || port.Defenders.Size()!=600)failures++;
        else for(int i=0;i<600;i++)
        {
            let b=port.Defenders[i];
            bool same=b==marker.Bodies[i] && b.HomeIdentity==marker.Identity[i]
                && b.DeploymentStep==marker.Step[i] && b.DeploymentComplete==marker.Complete[i] && b.health==marker.Health[i]
                && b.Pos==(marker.X[i],marker.Y[i],marker.Z[i]) && b.Station==(marker.PostX[i],marker.PostY[i],marker.PostZ[i])
                && b.Carbine.Magazine==marker.Magazine[i] && b.Carbine.ReloadRemaining==marker.Reload[i];
            if(!same){failures++;Console.Printf("CA133 FAIL deployment persistence body=%d",i);}
        }
        Console.Printf("CA133 %s 600 saved actor identities, health, assignments, position, deployment and carbine state",failures==0 ? "PASS" : "FAIL");
        Console.Printf("CA133 DEPLOYMENT_PERSIST_COMPLETE failures=%d save=%d reopen=%d",failures,e.IsSaveGame,e.IsReopen);
    }
}
