// Efecto instrumental: prueba el controlador sin implementar #239-242.
class CA238RacialTestEffect : CaelumRacialAbilityEffect
{
    int Starts,Steps,Stops,Simulated;
    bool Invalid;
    override double BaseAnimaPerSecond(CaelumPlayer user){return 10;}
    override bool CanContinue(CaelumPlayer user){return !Invalid;}
    override void Started(CaelumPlayer user){Starts++;}
    override void Step(CaelumPlayer user,bool realStep){Steps++;if(!realStep)Simulated++;}
    override void Stopped(CaelumPlayer user){Stops++;}
}
class CA238RacialTestPlayer : CaelumPlayer
{
    int Creations;
    override CaelumRacialAbilityEffect CreateRacialAbilityEffect(int race)
    {
        if(race!=CaelumConstants.RACE_HUMAN)return null;
        Creations++;return new("CA238RacialTestEffect");
    }
}
class CA238RacialProbe : StaticEventHandler
{
    CA238RacialTestPlayer User;
    CA238RacialTestEffect Last;
    CA259Session Equipment;
    int Passed,Failed,NativeStarts,NativeStops;
    void Check(bool ok,String label)
    {if(ok)Passed++;else Failed++;Console.Printf("CA238 %s %s",ok?"PASS":"FAIL",label);}
    override void UiTick(){if(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();}
    void Reset()
    {
        CaelumRacialAbilityRules.Deactivate(User);CaelumSleepRules.Wake(User);
        User.CharacterProfile.Race=CaelumConstants.RACE_HUMAN;
        User.CreationWizardOpen=false;User.CharacterCreationComplete=true;
        User.ApplyCharacterProfile();User.Attributes.Eloquence=0;
        User.DerivedStats.Recalculate(User.Attributes,User.CharacterProfile);
        User.DerivedStats.AnimaRegenerationPerSecond=0;
        User.health=User.CaelumMaximumHealth;User.player.health=User.health;
        User.player.playerstate=PST_LIVE;User.bInvulnerable=true;
        User.RacialAbilityInputLatched=false;User.EquipmentMenuOpen=false;
        User.LucidityPhysicalStunRemaining=0;User.PainImmobilizationRemaining=0;
        User.CurrentLucidity=100;User.CurrentSleep=100;User.UpdateLucidityState();
        User.CurrentAnima=1000;User.CombatChannelModeActive=false;
        CaelumClassAbilityRules.Cancel(User);
    }
    void Contracts()
    {
        Reset();double cost=10.0/TICRATE;
        User.RacialAbilityRevision=0;User.RacialAbilityActive=true;
        CaelumRacialAbilityRules.Ensure(User);CaelumRacialAbilityRules.Ensure(User);
        Check(User.RacialAbilityRevision==1 && !User.RacialAbilityActive && User.RacialAbility==null,"legacy HUD flag migrates idempotently to inactive");
        User.CurrentAnima=cost/2;
        Check(!CaelumRacialAbilityRules.Begin(User) && User.CurrentAnima==cost/2,"less than one tic refuses activation without spending remainder");
        User.CurrentAnima=cost*1.5;double before=User.CurrentAnima;
        Check(CaelumRacialAbilityRules.Begin(User) && !User.RacialAbilityActive && User.CurrentAnima==before,"subsecond admission has no initial fee");
        Last=CA238RacialTestEffect(User.RacialAbility);CaelumRacialAbilityRules.Advance(User);
        Check(User.RacialAbilityActive && Last.Starts==1 && Last.Steps==1 && Abs(User.CurrentAnima-(before-cost))<1e-8,"first paid tic activates exactly once");
        before=User.CurrentAnima;CaelumRacialAbilityRules.Advance(User);CaelumRacialAbilityRules.Deactivate(User);
        Check(!User.RacialAbilityActive && User.RacialAbility==null && User.CurrentAnima==before && Last.Stops==1 && Last.Steps==1,"insufficient next tic keeps fraction and cleans once");
        Reset();User.CurrentAnima=10;CaelumRacialAbilityRules.Begin(User);Last=CA238RacialTestEffect(User.RacialAbility);
        for(int i=0;i<35;i++)CaelumRacialAbilityRules.Advance(User,false);
        Check(Last.Steps==35 && Last.Simulated==35 && Abs(User.CurrentAnima)<1e-8,"35 simulated tics cost exactly one second within numeric tolerance");
        CaelumRacialAbilityRules.Advance(User);
        Check(User.RacialAbility==null && Last.Stops==1,"exhaustion ends without cooldown");
        Reset();User.DerivedStats.AnimaCostReductionPercent=50;CaelumRacialAbilityRules.Begin(User);CaelumRacialAbilityRules.Advance(User);
        Check(Abs(User.CurrentAnima-(1000-cost/2))<1e-8,"live cost modifier is applied once");
        User.DerivedStats.AnimaCostReductionPercent=0;CaelumRacialAbilityRules.Advance(User);
        Check(Abs(User.CurrentAnima-(1000-cost*1.5))<1e-8,"changed cost modifier affects the next tic");
        for(int cause=0;cause<5;cause++)
        {
            Reset();CaelumRacialAbilityRules.Begin(User);CaelumRacialAbilityRules.Advance(User);
            Last=CA238RacialTestEffect(User.RacialAbility);before=User.CurrentAnima;
            if(cause==0)User.ForcedSleepTics=10;
            else if(cause==1)User.LucidityPhysicalStunRemaining=1;
            else if(cause==2)User.PainImmobilizationRemaining=1;
            else if(cause==3)User.health=0;
            else User.CharacterProfile.Race=CaelumConstants.RACE_GOBLIN;
            CaelumRacialAbilityRules.Guard(User);CaelumRacialAbilityRules.Guard(User);
            Check(User.RacialAbility==null && !User.RacialAbilityActive && Last.Stops==1 && User.CurrentAnima==before,
                String.Format("interruption %d stops once before payment",cause));
        }
        Reset();CaelumRacialAbilityRules.Begin(User);CaelumRacialAbilityRules.Advance(User);
        User.CombatChannelModeActive=true;CaelumRacialAbilityRules.Guard(User);
        Check(User.RacialAbilityActive,"voluntary Seal channel is not forced immobilization");
        Reset();User.CharacterProfile.Race=CaelumConstants.RACE_GOBLIN;
        Check(!CaelumRacialAbilityRules.Begin(User) && User.CurrentAnima==1000,"authoritative unsupported saved race cannot activate");
        Reset();User.EquipmentMenuOpen=true;User.player.cmd.buttons|=BT_USER1;
        CaelumRacialAbilityRules.ObserveInput(User);User.EquipmentMenuOpen=false;
        CaelumRacialAbilityRules.Input(User);
        Check(User.RacialAbility==null,"menu-held press cannot leak after closing");
        User.player.cmd.buttons&=~BT_USER1;CaelumRacialAbilityRules.ObserveInput(User);
        Check(!User.RacialAbilityInputLatched,"native release rearms User1");
        Reset();User.ClassPreparationTics=20;User.ClassCastActive=true;
        Check(!CaelumRacialAbilityRules.Begin(User),"class preparation blocks racial admission");
        Reset();CaelumRacialAbilityRules.Begin(User);Last=CA238RacialTestEffect(User.RacialAbility);Last.Invalid=true;
        before=User.CurrentAnima;CaelumRacialAbilityRules.Advance(User);
        Check(User.RacialAbility==null && Last.Stops==1 && Last.Starts==0 && User.CurrentAnima==before,"lost pending target cleans up without activation or payment");
        Reset();CaelumRacialAbilityRules.Begin(User);
        Check(CaelumJourneyRules.BlockReason(User)=="CA_JOURNEY_EFFECT","journey forecast refuses a pending racial effect without mutating it");
        CaelumRacialAbilityRules.Advance(User);
        Check(CaelumJourneyRules.BlockReason(User)=="CA_JOURNEY_EFFECT" && User.RacialAbilityActive,"journey forecast refuses an active racial effect without stopping it");
        Reset();User.ClassPreparationTics=20;User.ClassCastActive=true;
        Check(CaelumJourneyRules.BlockReason(User)=="CA_JOURNEY_EFFECT","journey forecast refuses an unfinished class preparation");
        Reset();
    }
    override void WorldTick()
    {
        // El equipamiento recalcula Eloquencia: fijar la reducción evita asumir
        // un coste sin bonificar mientras el personaje realmente tiene descuento.
        let user=CaelumPlayer(players[0].mo);
        if(user!=null && user.DerivedStats!=null)
        {user.DerivedStats.AnimaRegenerationPerSecond=0;user.DerivedStats.AnimaCostReductionPercent=0;}
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="c238_racial_setup")
        {
            User=CA238RacialTestPlayer(players[e.Player].mo);Contracts();
            Equipment=new("CA259Session");Equipment.Tier=1;Equipment.Choice=0;Equipment.Equip(User);
        }
        if(e.Name=="c238_racial_load" || e.Name=="c238_racial_hub")
        {
            User=CA238RacialTestPlayer(players[e.Player].mo);Last=CA238RacialTestEffect(User.RacialAbility);
            Check(Last!=null && Last.Starts==1 && Last.Steps>0 && User.RacialAbilityActive,"saved/hub racial stays active without restarting");
            Check(Last!=null && Abs(User.CurrentAnima-(1000-Last.Steps*10.0/TICRATE))<1e-6,"saved/hub debit agrees with elapsed paid tics");
        }
        if(User==null)return;
        if(e.Name=="c238_racial_weapon")
        {Reset();Equipment.Choice=e.Args[0];Equipment.Equip(User);}
        if(e.Name=="c238_racial_on")
        {
            Last=CA238RacialTestEffect(User.RacialAbility);
            Check(Last!=null && Last.Starts==1 && Last.Steps>0 && Last.Stops==0 && User.RacialAbilityActive,"native held User1 activates once");NativeStarts++;
        }
        if(e.Name=="c238_racial_off")
        {
            Check(User.RacialAbility==null && !User.RacialAbilityActive && Last!=null && Last.Stops==1,"second native press stops without retriggering while held");NativeStops++;
        }
        if(e.Name=="c238_racial_unarmed")
        {
            Reset();User.EquipmentSelectionItemId=Equipment.TestItem.ItemId;User.RefreshEquipmentSelectionPreview();
            User.UnequipSelectedNativeEquipment();User.EnsureUnarmedFallback();User.player.PendingWeapon=Weapon(User.FindInventory("CaelumUnarmedWeapon"));
        }
        if(e.Name=="c238_racial_save_check")
        {
            Last=CA238RacialTestEffect(User.RacialAbility);
            Console.Printf("CA238 TRACE anima=%.9f max=%.9f steps=%d reduction=%.9f",User.CurrentAnima,User.DerivedStats.MaximumAnima,Last!=null?Last.Steps:-1,User.DerivedStats.AnimaCostReductionPercent);
            Check(Last!=null && Last.Starts==1 && User.RacialAbilityActive,"save contains one paid racial effect");
            Check(Last!=null && Abs(User.CurrentAnima-(1000-Last.Steps*10.0/TICRATE))<1e-6,"pre-save payment follows exact tic count");
        }
        if(e.Name=="c238_racial_done")Console.Printf("CA238 DONE failures=%d passes=%d RACIAL_COMPONENT starts=%d stops=%d",Failed,Passed,NativeStarts,NativeStops);
    }
}
