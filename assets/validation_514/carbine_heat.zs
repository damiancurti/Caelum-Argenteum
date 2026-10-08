class CA140CarbineTarget : Actor
{
    int Hits;
    override int DamageMobj(Actor inflictor,Actor source,int damage,Name mod,int flags,double angle)
    {Hits++;return Super.DamageMobj(inflictor,source,damage,mod,flags,angle);}
    Default { Radius 24;Height 80;Health 1000000;+SOLID +SHOOTABLE }
    States { Spawn:DOID A -1;Stop; }
}
class CA140CarbineHeat : EventHandler
{
    CaelumPortDefender Body;
    CA140CarbineTarget Target;
    double Peak,Minimum;
    bool Finished;
    override void WorldTick()
    {
        if(level.time==1)
        {
            let user=CaelumPlayer(players[0].mo);user.InitializeDirectMapCharacter();user.CreationWizardOpen=false;
            user.SetOrigin((2860,3900,0),false);user.Angle=25;
            let climate=Actor.Spawn("CaelumClimateRegion",(0,0,0));climate.args[0]=1;climate.args[1]=5;
            Body=CaelumPortDefender(Actor.Spawn("CaelumPortDefender",(3072,4096,0)));
            Body.HomeRevision=1;Body.Carbine=new("CaelumCityCarbine");Body.Carbine.Initialize(Body);Body.tics=-1;
            Target=CA140CarbineTarget(Actor.Spawn("CA140CarbineTarget",(3584,4096,0)));
        }
        if(Body==null || Finished)return;
        let s=CaelumThermalBody.Get(Body,true);if(s==null)return;
        if(level.time==70)
            Console.Printf("CA140 CARBINE_PROFILE hp=%d maxHP=%d mass=%.6f carried=%.6f toughness=%d maxAir=%.6f threshold=%.6f",
                Body.health,Body.CombatMaximumHealth,Body.Mass,Body.GetAttackCarriedWeight(),Body.CombatToughness,Body.MaximumCombatAir,
                10*CaelumThermalRules.ThresholdScale(s.Toughness));
        if(level.time>=70 && Body.health>0 && level.time%4==0)
            if(!Body.PulseResourceRecovery())Body.Carbine.Attack(Body,Target);
        // Aislar la carabina: conserva Tick, recursos y recarga, pero evita que
        // el estado nativo de persecución se acerque y añada golpes de espada.
        Body.tics=-1;
        Peak=Max(Peak,s.Exposure);Minimum=Min(Minimum,s.Exposure);
        if(level.time%35==0)
            Console.Printf("CA140 CARBINE seconds=%.3f hp=%d air=%.6f hydration=%.6f E=%.6f tier=%d shots=%d reloads=%d hits=%d waiting=%d sweatMl=%.6f actionJ=%.6f respiratoryJ=%.6f thermalHP=%.6f ambient=%.6f humidity=%.6f wind=%.6f",
                level.time/35.0,Body.health,Body.CurrentCombatAir,s.Hydration,s.Exposure,s.Severity,Body.Carbine.ShotCount,
                Body.Carbine.ReloadCount,Target.Hits,Body.AttackResourceWaiting,s.SweatKg*1000,s.ActionJoules,s.RespirationJoules,
                s.AppliedDamageHP,s.AirC,s.Humidity,s.WindMps);
        if(level.time==4200 || Body.health<=0)
        {
            Console.Printf("CA140 CARBINE_COMPLETE seconds=%.6f alive=%d hp=%d shots=%d reloads=%d peak=%.6f minimum=%.6f hydration=%.6f sweatMl=%.6f thermalHP=%.6f",
                level.time/35.0,Body.health>0,Body.health,Body.Carbine.ShotCount,Body.Carbine.ReloadCount,Peak,Minimum,s.Hydration,s.SweatKg*1000,s.AppliedDamageHP);
            Finished=true;
        }
    }
    override void RenderOverlay(RenderEvent event)
    {
        if(Body==null || Body.ThermalState==null || Body.Carbine==null)return;
        let s=Body.ThermalState;let font=Font.GetFont("CaelumMono");
        Screen.DrawText(font,Font.CR_WHITE,12,12,String.Format("SOLDADO | Salud %d/%d | Disparos %d | Recargas %d",Body.health,Body.CombatMaximumHealth,Body.Carbine.ShotCount,Body.Carbine.ReloadCount),DTA_VIRTUALWIDTH,640,DTA_VIRTUALHEIGHT,360,DTA_SHADOW,true);
        Screen.DrawText(font,Font.CR_WHITE,12,25,String.Format("Aire %.1f%% | Hidratacion %.1f | Sudor %.1f ml",100*Body.CurrentCombatAir/Body.MaximumCombatAir,s.Hydration,s.SweatKg*1000),DTA_VIRTUALWIDTH,640,DTA_VIRTUALHEIGHT,360,DTA_SHADOW,true);
        Screen.DrawText(font,Font.CR_WHITE,12,38,String.Format("Exposicion %+.2f | Umbral %.2f | Dano termico %.0f HP",s.Exposure,10*CaelumThermalRules.ThresholdScale(s.Toughness),s.AppliedDamageHP),DTA_VIRTUALWIDTH,640,DTA_VIRTUALHEIGHT,360,DTA_SHADOW,true);
    }
}
