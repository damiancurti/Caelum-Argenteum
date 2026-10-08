class CA135AbilityMarker : Actor
{
    CaelumCombatActor Body;
    double Paid;
    override void Tick(){if(Body!=null && Body.DemonBreath!=null)Paid=Body.DemonBreath.PaidSeconds;}
    Default { +NOINTERACTION }
    States { Spawn:TNT1 A -1;Stop; }
}
class CA135AbilityProbe : StaticEventHandler
{
    override void WorldLoaded(WorldEvent e)
    {
        if(level.MapName!="CA135" || (!e.IsSaveGame && !e.IsReopen))return;
        let marker=CA135AbilityMarker(ThinkerIterator.Create("CA135AbilityMarker").Next());
        if(marker==null)return;
        let body=marker.Body;let flame=body!=null ? body.DemonBreath : null;
        bool ok=flame!=null && flame.Emitter==body && Abs(flame.PaidSeconds-marker.Paid)<0.0000001
            && body.DemonSupplyRevision==1 && CaelumDemonService.Potion(body,1)==null;
        Console.Printf("CA135 ABILITY_PERSISTENCE saved=%d reopened=%d residual=%.9f failures=%d",e.IsSaveGame,e.IsReopen,
            flame!=null ? flame.PaidSeconds : -1,int(!ok));
    }
}
class CA135Retreat : CaelumZupayColossus
{
    override bool IsSewerBoss(){return false;}
    override bool IsRetreatBoss(){return true;}
    override Vector3 EscapePosition(){return Pos;}
    override double EscapeReach(){return 256;}
    override bool ReachedEscape(){return true;}
}
class CA135Integration : EventHandler
{
    CaelumCombatActor Warm,Control,Boss,WallOwner,WallVictim;
    CA135Retreat Retreat;
    int Checks,Failures;
    double StartAnima;
    double PriorAnima,PriorPaid,ObservedRegeneration;
    CaelumDemonBreath PriorFlame;
    void Check(bool ok,String label)
    {Checks++;if(!ok)Failures++;Console.Printf("CA135 %s %s",ok ? "PASS" : "FAIL",label);}
    CaelumCombatActor Body(Name name,Vector3 point)
    {
        let npc=CaelumCombatActor(Actor.Spawn(name,point,NO_REPLACE));
        npc.tics=-1;npc.target=null;return npc;
    }
    void Empty(CaelumCombatActor body)
    {for(int i=0;i<3;i++){let item=CaelumDemonService.Potion(body,i);if(item!=null)item.Destroy();}}
    int Loot()
    {
        let search=ThinkerIterator.Create("CaelumConsumableItem");Thinker entry;int total=0;
        while((entry=search.Next())!=null){let item=CaelumConsumableItem(entry);if(item.Owner==null)total+=item.Amount;}
        return total;
    }
    override void WorldTick()
    {
        if(level.MapName!="CA135")return;
        let user=CaelumPlayer(players[0].mo);
        if(level.time==1){user.InitializeDirectMapCharacter();user.PersistCharacterState();user.bNOTARGET=true;}
        if(level.time==60)
        {
            Warm=Body('CaelumMandinga',(2048,2048,0));
            Control=Body('CaelumMandinga',(2048,4096,0));
            Boss=Body('CaelumZupayColossus',(4096,2048,0));
            WallOwner=Body('CaelumMandinga',(48,2048,0));WallOwner.Angle=180;
            WallVictim=Body('CaelumMandinga',(-48,2048,0));WallVictim.CaelumDiagnosticPassiveAI=true;
            WallVictim.ElementalStatus=new("CaelumElementalStatus");
            Retreat=CA135Retreat(Body('CA135Retreat',(6000,6000,0)));
        }
        if(level.time==80)
        {
            Empty(Warm);Empty(Control);Empty(Boss);Empty(WallOwner);Empty(WallVictim);
            Warm.ThermalState.Exposure=Control.ThermalState.Exposure=Boss.ThermalState.Exposure=WallOwner.ThermalState.Exposure=-15;
            Warm.ThermalState.Severity=Control.ThermalState.Severity=Boss.ThermalState.Severity=WallOwner.ThermalState.Severity=1;
            StartAnima=Warm.CurrentCombatAnima=Warm.MaximumCombatAnima*0.6;
            let marker=CA135AbilityMarker(Actor.Spawn("CA135AbilityMarker"));marker.Body=Warm;
            Retreat.health=Retreat.CombatMaximumHealth/2;
        }
        if(level.time>=80 && level.time<=430)Control.CurrentCombatAnima=0;
        if(level.time>80 && Warm!=null)
        {
            let flame=Warm.DemonBreath;
            if(flame!=null && flame==PriorFlame)
                ObservedRegeneration+=Warm.CurrentCombatAnima-PriorAnima
                    +(flame.TotalPaidSeconds-PriorPaid)*Warm.GetMagicAnimaCost(10);
            PriorFlame=flame;PriorAnima=Warm.CurrentCombatAnima;
            PriorPaid=flame!=null ? flame.TotalPaidSeconds : 0;
        }
        if(level.time==90)
        {
            Check(Warm.DemonBreath!=null && Boss.DemonBreath!=null,"normal Mandinga and Zupay AI start cold regulation");
            Check(Control.DemonBreath==null,"unfunded cold control cannot emit free flame");
            Check(Retreat==null && Loot()==0,"scripted living Zupay retreat destroys no potion loot");
            let flame=WallOwner.DemonBreath;
            Check(flame!=null && !flame.Contact(WallVictim) && flame.ReceivedWatts(WallVictim,WallVictim.ThermalState)==0,
                "native map wall blocks contact and radiated heat");
        }
        if(level.time==430)
        {
            double warmth=Warm.ThermalState.Exposure-Control.ThermalState.Exposure;
            Check(warmth>0 && Warm.ThermalState.AbsorbedContinuousJoules>0,
                "paid cold regulation warms normal AI above matched unfunded control");
            Check(Boss.ThermalState.AbsorbedContinuousJoules>0,"Zupay receives authoritative racial warmth");
            Check(ObservedRegeneration>0,
                "normal Anima regeneration runs concurrently with sustained spending");
            Check(WallVictim.ThermalState.AbsorbedContinuousJoules==0 && WallVictim.ElementalStatus.BurnRemaining==0,
                "wall victim remains unburned and unheated over ten seconds");
            Console.Printf("CA135 NORMAL warmthDelta=%.9f emitterExposure=%.9f controlExposure=%.9f anima=%.9f/start=%.9f selfJ=%.9f bossJ=%.9f",
                warmth,Warm.ThermalState.Exposure,Control.ThermalState.Exposure,Warm.CurrentCombatAnima,StartAnima,
                Warm.ThermalState.AbsorbedContinuousJoules,Boss.ThermalState.AbsorbedContinuousJoules);
            Console.Printf("CA135 CONCURRENT_REGEN actualAnimaRestoredWhilePaying=%.9f",ObservedRegeneration);
            Console.Printf("CA135 COMPLETE checks=%d failures=%d",Checks,Failures);
        }
    }
}
