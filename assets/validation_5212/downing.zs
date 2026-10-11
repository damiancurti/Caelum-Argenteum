class CA195Downing : StaticEventHandler
{
    int Age,Passes,Failures;
    CaelumPlayer User;CaelumM00Bull Bull;CaelumRulo Rulo;
    void Check(String label,bool ok){if(ok)Passes++;else Failures++;Console.Printf("CA195 %s %s",ok?"PASS":"FAIL",label);}
    override void UiTick(){if(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();}
    override void WorldTick()
    {
        Age++;
        if(Age==20)
        {
            User=CaelumPlayer(players[0].mo);User.CreationWizardOpen=false;User.CharacterCreationComplete=true;
            Bull=CaelumMainM00RuloTrial.GetBull();Rulo=CaelumRulo(ThinkerIterator.Create("CaelumRulo").Next());
            let record=User.GetPersistentCharacterState(true);
            record.EnsureQuestStateInitialized();
            record.QuestState[CaelumConstants.QUEST_MAIN_M00_THE_FOOL]=CaelumConstants.QUEST_STATE_ACTIVE;
            record.QuestStage[CaelumConstants.QUEST_MAIN_M00_THE_FOOL]=CaelumConstants.MAIN_M00_STATE_RULO_ACTIVE;
            record.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_RULO_STARTED);
            record.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_BULL_STARTED);
            CaelumMainM00RuloTrial.StartFight(User,Bull);User.bInvulnerable=true;
            int before=Rulo.health;Rulo.DamageMobj(Bull,Bull,100000,'CaelumImpact',DMG_THRUSTLESS,0);
            Check("grace protects residents",Rulo.health==before);
        }
        if(Age==95)
        {
            Rulo.DamageMobj(Bull,Bull,100000,'CaelumImpact',DMG_THRUSTLESS,0);
            Check("lethal bull hit downs original resident",Rulo.health==1 && Rulo.RuloPartyDowned && !Rulo.bShootable && !Rulo.bSolid);
            Rulo.ResidentTools.Tick();Check("downing cancels tool",Rulo.ResidentTools.Phase==0);
            Bull.DamageMobj(User,User,100000,'CaelumImpact',DMG_THRUSTLESS,0);
        }
        if(Age==100)
        {
            Check("victory restores resident",Rulo.health==Rulo.CombatMaximumHealth && !Rulo.RuloPartyDowned && Rulo.bSolid);
            Check("bull victory flag",User.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_BULL_DEFEATED));
            User.player.ConversationNPC=Rulo;
            Check("native completion advances quest",CaelumMainM00RuloTrial.Complete(User));
            Check("completion enables departure",User.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_PALOMO_UPSTAIRS_ENABLED));
            User.player.ConversationNPC=null;
            Console.Printf("CA195 DONE failures=%d passes=%d",Failures,Passes);
        }
    }
}
