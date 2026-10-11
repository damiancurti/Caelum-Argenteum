class CA195Encounter : StaticEventHandler
{
    int Age,Failures,Passes,FireSeen,Hits,Downed;
    CaelumM00Bull Bull;
    CaelumPlayer User;
    CaelumAnchoredResident Residents[4];
    int OldHealth;
    double MaxSpeed;
    void Check(String label,bool ok)
    {if(ok)Passes++;else Failures++;Console.Printf("CA195 %s %s",ok?"PASS":"FAIL",label);}
    override void UiTick(){if(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();}
    override void WorldTick()
    {
        Age++;
        if(Age==20)
        {
            User=CaelumPlayer(players[0].mo);User.CreationWizardOpen=false;User.CharacterCreationComplete=true;
            Bull=CaelumMainM00RuloTrial.GetBull();Check("native MAP01 bull exists",Bull!=null);
            Class<CaelumAnchoredResident> types[]={"CaelumRulo","CaelumRonnie","CaelumArgento","CaelumCaella"};
            for(int i=0;i<4;i++)Residents[i]=CaelumAnchoredResident(ThinkerIterator.Create(types[i]).Next());
            let r=User.GetPersistentCharacterState(true);
            r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_RULO_STARTED);
            r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_BULL_STARTED);
            CaelumMainM00RuloTrial.StartFight(User,Bull);OldHealth=Bull.health;
            User.bInvulnerable=true; // Observer takes no actions; residents and bull remain native.
            Check("pre-fight grace",!Bull.TrialReleased && Bull.TrialGraceTicks==70);
            for(int i=0;i<4;i++)Check("same resident joins party",Residents[i].RuloPartyBull==Bull);
        }
        if(Age>20 && Bull!=null)
        {
            if(Bull.health<OldHealth)Hits++;OldHealth=Bull.health;
            if(Bull.BullChargeActive)MaxSpeed=Max(MaxSpeed,Bull.BullChargeSpeed*35/32);
            let it=ThinkerIterator.Create("CaelumActorProjectile");CaelumActorProjectile shot;
            while((shot=CaelumActorProjectile(it.Next()))!=null)
                if(shot.Target is "CaelumAnchoredResident" && shot.CaelumElementalPayloadPrepared
                    && shot.CaelumEssenceType==CaelumConstants.ESSENCE_FIRE && !shot.CaelumSecondaryElement)FireSeen++;
            for(int i=0;i<4;i++)if(Residents[i].RuloPartyDowned)Downed|=1<<i;
            if(Age%175==0)
            {
                Console.Printf("CA195 TRACE encounter t=%.2f bull=%d/%d speed=%.3f bound=%d frozen=%.3f hits=%d",Age/35.0,
                    Bull.health,Bull.CombatMaximumHealth,MaxSpeed,CaelumBolas.Restrained(Bull),Bull.ElementalStatus.FreezeRemaining,Hits);
                for(int i=0;i<4;i++)
                {let npc=Residents[i];let kit=npc.ResidentTools;
                    Console.Printf("CA195 TRACE resident i=%d hp=%d down=%d phase=%d melee=%d charged=%d bolas=%d recovered=%d ice=%d air=%.2f anima=%.2f pos=%.1f,%.1f",
                        i,npc.health,npc.RuloPartyDowned,kit.Phase,kit.MeleeUses,kit.ChargedUses,kit.BolasThrows,kit.BolasRecoveries,
                        kit.IcePaidTics,npc.CurrentCombatAir,npc.CurrentCombatAnima,npc.Pos.X,npc.Pos.Y);
                }
            }
        }
        if(Age==2100)
        {
            Check("native damage occurred",Hits>0);Check("resident fire excluded",FireSeen==0);
            Check("charge respects cap",MaxSpeed<=10.000001);
            for(int i=0;i<4;i++)Check("residents protected from permanent death",Residents[i].health>0);
            Check("victory flag persists after corpse dissipates",User.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_BULL_DEFEATED));
            Console.Printf("CA195 TRACE outcome lastBullHealth=%d hits=%d downedMask=%d fire=%d",OldHealth,Hits,Downed,FireSeen);
            Console.Printf("CA195 DONE failures=%d passes=%d",Failures,Passes);
        }
    }
}
