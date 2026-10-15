// Escenario aislado: poses vivas, tres impactos, tiempo y partidas guardadas.
class CA238PoseProbe : StaticEventHandler
{
    CaelumPlayer User;
    CaelumCombatActor Bodies[4];
    State ExpectedIdle[4];
    int Passed,Failed,Choice;
    bool Ready;
    void Check(bool ok,String label)
    {if(ok)Passed++;else Failed++;Console.Printf("CA238 %s %s",ok?"PASS":"FAIL",label);}
    override void UiTick(){if(!Ready && Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();}
    void Face(int which,int direction)
    {
        Choice=which;let body=Bodies[which];if(body==null)return;
        double distance=which==0?80:which==3?240:160;
        User.SetOrigin(body.Pos+(0,-distance,0),false);User.Angle=90;
        User.Pitch=which==0?25:12;User.Vel=(0,0,0);
        body.Angle=270-direction*45;
    }
    void Prepare(CaelumCombatActor body)
    {
        CaelumSleepRules.Wake(body);body.health=body.CombatMaximumHealth;
        body.SetState(body.SpawnState,true);body.tics=-1;body.target=null;
        body.CurrentCombatLucidity=100;body.UpdateActorLucidityState();
        body.CombatLucidityPhysicalStunRemaining=0;
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="c238_poses_setup")
        {
            User=CaelumPlayer(players[e.Player].mo);
            User.CreationWizardOpen=false;User.CharacterCreationComplete=true;
            User.CharacterProfile.FirstClass=CaelumConstants.CLASS_PRIEST;
            User.CharacterProfile.SecondClass=CaelumConstants.CLASS_MAGE;
            User.ApplyCharacterProfile();User.bInvulnerable=true;User.bNoTarget=true;
            User.Attributes.Eloquence=0;User.Attributes.Charisma=0;
            User.DerivedStats.Recalculate(User.Attributes,User.CharacterProfile);
            User.CurrentAnima=1000;User.DerivedStats.AnimaRegenerationPerSecond=0;
            Bodies[0]=CaelumCombatActor(Actor.Spawn("CaelumGiantRat",(-600,0,0),NO_REPLACE));
            Bodies[1]=CaelumCombatActor(Actor.Spawn("CaelumBull",(-200,0,0),NO_REPLACE));
            Bodies[2]=CaelumCombatActor(Actor.Spawn("CaelumMandinga",(200,0,0),NO_REPLACE));
            Bodies[3]=CaelumCombatActor(Actor.Spawn("CaelumZupayColossus",(600,0,0),NO_REPLACE));
            for(int i=0;i<4;i++){Bodies[i].ChangeTid(23810+i);Bodies[i].SetState(Bodies[i].SpawnState,true);Bodies[i].tics=-1;}
            Ready=true;return;
        }
        if(e.Name=="c238_poses_load")
        {
            User=CaelumPlayer(players[e.Player].mo);Ready=true;
            for(int i=0;i<4;i++)
            {
                Bodies[i]=CaelumCombatActor(ActorIterator.Create(23810+i).Next());
                let b=Bodies[i];Check(b!=null && b.SpellSleep!=null && b.SpellSleep.HitsRemaining==2
                    && b.CurState==b.FindState("RestLying"),String.Format("body %d reload keeps lying/two hits",i));
            }
            return;
        }
        if(!Ready)return;
        if(e.Name=="c238_poses_contract")
        {
            for(int i=0;i<4;i++)
            {
                let b=Bodies[i];Prepare(b);State original=b.CurState;double h=b.Height,r=b.Radius;
                Check(CaelumSleepRules.Apply(b,350,true,1) && b.CurState==b.FindState("RestLying")
                    && b.tics==-1 && b.health>0,String.Format("body %d living RestLying",i));
                Check(b.Height==h && b.Radius==r,String.Format("body %d unchanged collision",i));
                for(int hit=1;hit<=3;hit++)
                {
                    int before=b.health;b.DamageMobj(null,null,1,'CaelumImpact',DMG_FORCED,0);
                    if(hit==3)Console.Printf("CA238 TRACE wake body=%d sleep=%d object=%d original=%d pain=%d tics=%d",i,b.ForcedSleepTics,b.SpellSleep!=null,b.CurState==original,b.CurState==b.FindState("Pain"),b.tics);
                    Check(before-b.health==3,String.Format("body %d hit %d final x3",i,hit));
                    Check(hit==3?b.SpellSleep==null && b.ForcedSleepTics==0
                        && (b.CurState==original || b.CurState==b.FindState("Pain")):
                        b.SpellSleep!=null && b.SpellSleep.HitsRemaining==3-hit && b.CurState==b.FindState("RestLying"),
                        String.Format("body %d hit %d wake/held pose",i,hit));
                }
                Prepare(b);ExpectedIdle[i]=b.CurState;CaelumSleepRules.Apply(b,5,true,1);
            }
        }
        if(e.Name=="c238_poses_expired")
            for(int i=0;i<4;i++)
            {
                let b=Bodies[i];Console.Printf("CA238 TRACE expiry body=%d sleep=%d object=%d original=%d pain=%d idle=%d see=%d tics=%d",i,b.ForcedSleepTics,b.SpellSleep!=null,b.CurState==b.SpawnState,b.CurState==b.FindState("Pain"),b.CurState==b.FindState("IdleBreathing"),b.CurState==b.SeeState,b.tics);
                // Spawn puede contener instrucciones de cero tics; usar el estado real.
                Check(b.SpellSleep==null && b.ForcedSleepTics==0 && b.CurState==ExpectedIdle[i],String.Format("body %d expires into captured idle",i));
            }
        if(e.Name=="c238_pose")
        {
            int which=e.Args[0],dir=e.Args[1];let b=Bodies[which];Prepare(b);
            CaelumSleepRules.Apply(b,3500,true,1);Face(which,dir);
        }
        if(e.Name=="c238_poses_save")
            for(int i=0;i<4;i++)
            {Prepare(Bodies[i]);CaelumSleepRules.Apply(Bodies[i],3500,true,1);Bodies[i].DamageMobj(null,null,1,'CaelumImpact',DMG_FORCED,0);}
        if(e.Name=="c238_poses_done")Console.Printf("CA238 DONE failures=%d passes=%d SLEEP_POSES",Failed,Passed);
        if(e.Name=="c238_poses_cast_check")
        {
            Console.Printf("CA238 TRACE native paid=%.9f cost=%.9f remaining=%.9f reuse=%.3f active=%d",User.ClassCastPaid,User.ClassCastCost,User.CurrentAnima,User.ClassSleepCooldownRemaining,User.ClassCastActive);
            Check(Abs(User.ClassCastPaid-User.ClassCastCost)<0.000001
                && Abs(User.CurrentAnima-(1000-User.ClassCastCost))<0.000001
                && User.ClassSleepCooldownRemaining>0 && !User.ClassCastActive,"native User4 releases paid Sleep");
            for(int i=0;i<4;i++)Check(Bodies[i].ForcedSleepTics>0 && Bodies[i].CurState==Bodies[i].FindState("RestLying"),String.Format("native User4 lays body %d down",i));
        }
        if(e.Name=="c238_poses_reset")
        {
            CaelumClassAbilityRules.Cancel(User);User.ClassSleepCooldownRemaining=0;User.CurrentAnima=1000;
            for(int i=0;i<4;i++)Prepare(Bodies[i]);Face(Choice,0);
        }
        if(e.Name=="c238_poses_next"){Choice=(Choice+1)%4;Face(Choice,0);}
        if(e.Name=="c238_poses_hit")
        {
            let b=Bodies[Choice];int before=b.health;b.DamageMobj(null,null,1,'CaelumImpact',DMG_FORCED,0);
            CaelumNotifications.Notify(User,String.Format("Daño: %d | Golpes restantes: %d",before-b.health,b.SpellSleep==null?0:b.SpellSleep.HitsRemaining));
        }
    }
    override void WorldTick()
    {
        if(!Ready || User==null)return;
        User.DerivedStats.AnimaRegenerationPerSecond=0;
        User.CurrentLucidity=100;User.UpdateLucidityState();
    }
}
