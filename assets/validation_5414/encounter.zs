// #253: observar el encuentro real sin alterar recursos del Toro/residentes.
class CA253Probe : StaticEventHandler
{
    int Age,FloorTic,Passed,Failed;
    bool Loaded;
    CaelumPlayer User;
    CaelumM00Bull Bull;
    CaelumAnchoredResident Residents[4];
    vector3 LastPosition[4];
    double TravelAfterFloor[4];
    void Check(bool ok,String label)
    {if(ok)Passed++;else Failed++;Console.Printf("CA253 %s %s",ok?"PASS":"FAIL",label);}
    void Find()
    {
        User=CaelumPlayer(players[0].mo);Bull=CaelumMainM00RuloTrial.GetBull();
        Class<CaelumAnchoredResident> types[]={"CaelumRulo","CaelumRonnie","CaelumArgento","CaelumCaella"};
        for(int i=0;i<4;i++)Residents[i]=CaelumAnchoredResident(ThinkerIterator.Create(types[i]).Next());
    }
    override void WorldLoaded(WorldEvent e){Loaded=e.IsSaveGame;Age=0;}
    override void UiTick(){if(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();}
    void Trace()
    {
        Console.Printf("CA253 TRACE age=%d player=%d state=%d floor=%d bull=%d released=%d grace=%d targetPlayer=%d",Age,
            User.health,User.player.playerstate,FloorTic,Bull==null?0:Bull.health,Bull!=null && Bull.TrialReleased,
            Bull==null?0:Bull.TrialGraceTicks,Bull!=null && Bull.Target==User);
        for(int i=0;i<4;i++)
        {
            let n=Residents[i];if(n==null)continue;let k=n.ResidentTools;
            Console.Printf("CA253 NPC i=%d hp=%d mode=%d down=%d fighting=%d targetBull=%d recovery=%d phase=%d melee=%d ice=%d bolas=%d air=%.2f anima=%.2f stun=%.3f sleep=%d hurt=%d pos=%.1f,%.1f travel=%.1f",
                i,n.health,n.RuloPartyMode,n.RuloPartyDowned,n.IsRuloPartyFighting(),n.Target==Bull,n.ResourceRecoveryActive(),k.Phase,k.MeleeUses,k.IcePaidTics,k.BolasThrows,
                n.CurrentCombatAir,n.CurrentCombatAnima,n.CombatLucidityPhysicalStunRemaining,n.ForcedSleepTics,n.InStateSequence(n.CurState,n.FindState("Pain")),n.Pos.X,n.Pos.Y,TravelAfterFloor[i]);
            Console.Printf("CA253 MOVE i=%d speed=%.3f vel=%.3f dir=%d count=%d tics=%d see=%d tool=%d just=%d massAI=%d bolasOwner=%d bolasDistance=%.1f targetDistance=%.1f",
                i,n.Speed,n.Vel.Length(),n.MoveDir,n.MoveCount,n.tics,n.InStateSequence(n.CurState,n.SeeState),n.InStateSequence(n.CurState,n.FindState("ResidentToolUse")),
                n.bJustAttacked,n.CaelumMassAIScheduleActive,k.Bolas!=null && k.Bolas.Owner!=null,k.Bolas==null?-1:n.Distance3D(k.Bolas),Bull==null?-1:n.Distance3D(Bull));
            Console.Printf("CA253 SPEED i=%d base=%.3f health=%.3f thermal=%.3f elemental=%.3f",i,n.CombatBaseSpeed,n.CombatHealthPerformanceMultiplier,CaelumThermalEffects.Speed(n),n.ElementalStatus.GetMovementMultiplier());
        }
    }
    override void WorldTick()
    {
        Age++;
        if(Loaded && Age==1){Find();FloorTic=1;for(int i=0;i<4;i++)LastPosition[i]=Residents[i].Pos;}
        if(!Loaded && Age==20)
        {
            User=CaelumPlayer(players[0].mo);User.CreationWizardOpen=false;User.CharacterCreationComplete=true;
            Bull=CaelumMainM00RuloTrial.GetBull();
            Class<CaelumAnchoredResident> types[]={"CaelumRulo","CaelumRonnie","CaelumArgento","CaelumCaella"};
            for(int i=0;i<4;i++)Residents[i]=CaelumAnchoredResident(ThinkerIterator.Create(types[i]).Next());
            let r=User.GetPersistentCharacterState(true);r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_RULO_STARTED);
            r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_BULL_STARTED);
            CaelumMainM00RuloTrial.StartFight(User,Bull);
            Console.Printf("CA253 START native assisted encounter; player is vulnerable");
            for(int i=0;i<4;i++)Check(Residents[i].CombatBaseSpeed==GetDefaultByType(Residents[i].GetClass()).Speed,"fresh resident captures authored positive base");
        }
        if((!Loaded && Age<21) || User==null)return;
        bool first=FloorTic==0 && User.health==1;
        if(first)FloorTic=Age;
        for(int i=0;i<4;i++)if(Residents[i]!=null)
        {
            if(FloorTic>0)TravelAfterFloor[i]+=(Residents[i].Pos-LastPosition[i]).Length();
            LastPosition[i]=Residents[i].Pos;
        }
        if(first || Age%175==0)Trace();
        if(Age==2100)
        {
            Console.Printf("CA253 OBSERVED floor=%d victory=%d",FloorTic,User.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_BULL_DEFEATED));
        }
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="c253_check")
        {
            bool won=User.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_BULL_DEFEATED);
            Check(FloorTic>0 && User.health>0 && User.player.playerstate==PST_LIVE,"native floor encounter retains living player");
            Check(won || (Bull!=null && Bull.TrialFighter==User && Bull.TrialReleased),"encounter stays active until actual victory");
            for(int i=0;i<4;i++)
            {
                let n=Residents[i];Check(n!=null && n.RuloPartyBull==Bull && n.RuloPartyTraveler==User && n.RuloPartyMode==(won?3:2),"same resident retains encounter ownership");
                Check(TravelAfterFloor[i]>0,"resident physically moves after player reaches floor");
                if(n.RuloPartyDowned)Check(!n.bShootable && !n.bSolid && n.Target==null,"genuine resident downing remains excluded");
                else Check((won || n.IsRuloPartyFighting()) && n.CombatBaseSpeed>0,"eligible resident retains movement through combat or victory");
            }
        }
        if(e.Name=="c253_win")
        {
            // Sólo fuerza el desenlace para comprobar progresión; no cuenta como victoria autónoma.
            if(Bull!=null && Bull.health>0)Bull.DamageMobj(User,User,10000000,'Telefrag',DMG_FORCED,0);
        }
        if(e.Name=="c253_won")
        {
            Check(User.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_BULL_DEFEATED),"victory records its native quest flag");
            for(int i=0;i<4;i++)Check(Residents[i]!=null && Residents[i].RuloPartyMode==3 && !Residents[i].RuloPartyDowned && Residents[i].health>0,"same residents enter existing post-victory interaction");
        }
        if(e.Name=="c253_saved")
        {Check(FloorTic>0 && User.health>0 && Bull!=null && Bull.TrialFighter==User,"native combat checkpoint follows real protected floor damage");Console.Printf("CA253 DONE failures=%d passed=%d",Failed,Passed);}
        if(e.Name=="c253_done")Console.Printf("CA253 DONE failures=%d passed=%d",Failed,Passed);
    }
    override void RenderOverlay(RenderEvent e)
    {
        if(User==null)return;
        String line=String.Format("MAP01 #253 | Salud %d | F7 termina al Toro (prueba) | Habitantes conservan recursos",User.health);
        Screen.DrawText(SmallFont,Font.CR_WHITE,80,8,line,DTA_VIRTUALWIDTHF,640.0,DTA_VIRTUALHEIGHTF,360.0);
        for(int i=0;i<4;i++)if(Residents[i]!=null)
        {
            let n=Residents[i];line=String.Format("%s: salud %d | velocidad %.1f | caido %d",n.GetTag(),n.health,n.Speed,n.RuloPartyDowned);
            Screen.DrawText(SmallFont,Font.CR_WHITE,80,20+i*10,line,DTA_VIRTUALWIDTHF,640.0,DTA_VIRTUALHEIGHTF,360.0);
        }
    }
}
