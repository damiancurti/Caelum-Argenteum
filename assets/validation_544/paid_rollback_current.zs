// Current-only behavior, kept outside the old-runtime schema probe.
class CA238PaidRollbackCurrent : CA238PaidRollback
{
    override void CurrentEvent(ConsoleEvent e)
    {
        if(e.Name=="c238_paid_setup")
        {
            User.CreationWizardOpen=false;User.CharacterCreationComplete=true;
            User.CharacterProfile.FirstClass=CaelumConstants.CLASS_PRIEST;
            User.CharacterProfile.SecondClass=CaelumConstants.CLASS_MAGE;
            User.CharacterProfile.Race=CaelumConstants.RACE_HUMAN;
            User.ApplyCharacterProfile();User.Attributes.Eloquence=0;
            User.DerivedStats.Recalculate(User.Attributes,User.CharacterProfile);
            User.DerivedStats.AnimaRegenerationPerSecond=0;
            User.CurrentAnima=1000;User.ClassSleepCooldownRemaining=0;
            User.LucidityPhysicalStunRemaining=0;User.PainImmobilizationRemaining=0;
            User.bInvulnerable=true;User.EnsureUnarmedFallback();
            User.player.PendingWeapon=Weapon(User.FindInventory("CaelumUnarmedWeapon"));
        }
        if(e.Name=="c238_paid_seed")
        {
            Check(User.ClassCastActive && User.ClassPreparationTics>0 && User.ClassCastPaid>0
                && User.ClassCastPaid<1000,"native User4 reached partially paid preparation");
            Check(Abs(User.ClassCastPaid+User.CurrentAnima-1000)<1e-6,"partial payment balance before saving");
            SeedObjects();
        }
        if(e.Name=="c238_cooldown_seed")
        {
            Check(!User.ClassCastActive && User.ClassSleepCooldownRemaining>55
                && User.ClassSleepCooldownRemaining<60 && User.ClassCastPaid==1000,
                "native preparation released once before cooldown save");
            // A zero-rate base object isolates serialization from concrete racial bonuses.
            SeedObjects();
        }
        if(e.Name=="c238_resume_check")
        {
            Check(Loaded,"current runtime loaded bridge or repeated-upgrade save");
            Check(InitialTics>0 && User.ClassPreparationTics<InitialTics
                && User.ClassCastActive==(User.ClassPreparationTics>0),
                "preparation continues from its retained clock");
            Check(User.ClassCastPaid>InitialPaid && Abs(User.CurrentAnima+User.ClassCastPaid-1000)<1e-6,
                "resumed payment uses the original ledger exactly once");
            int remaining=User.ClassPreparationTics;
            double paid=User.ClassCastPaid;
            let racial=User.RacialAbility;
            for(int i=0;i<3;i++)
            {CaelumClassAbilityRules.Ensure(User);CaelumRacialAbilityRules.Ensure(User);}
            Check(User.ClassPreparationTics==remaining && User.ClassCastPaid==paid
                && User.RacialAbility==racial,"schema initialization preserves the current paid state");
        }
        if(e.Name=="c238_resume_final")
        {
            Check(!User.ClassCastActive && User.ClassPreparationTics==0 && User.ClassCastPaid==1000
                && User.CurrentAnima<1e-6,"paid preparation completes with exactly one total cost");
            Check(User.ClassSleepCooldownRemaining>55 && User.ClassSleepCooldownRemaining<60,
                "re-upgraded release starts only one cooldown");
        }
        if(e.Name=="c238_cooldown_check")
        {
            Check(Loaded && InitialTics==0 && InitialCooldown>0
                && User.ClassSleepCooldownRemaining>0 && User.ClassSleepCooldownRemaining<InitialCooldown,
                "cooldown resumes without restarting preparation or reuse");
            Check(!User.ClassCastActive && User.ClassCastPaid==1000 && User.CurrentAnima<1e-6,
                "cooldown load never repays the released cast");
        }
    }
    void SeedObjects()
    {
        let body=CA238RollbackBody(Actor.Spawn("CA238RollbackBody",User.Pos+(256,0,0),NO_REPLACE));
        body.PostBeginPlay();body.InitializeCombatProfile(0,0,0,0,0,0,0,0,0,0,0,0);
        body.health=100000;body.CombatMaximumHealth=100000;
        CaelumSleepRules.Apply(body,350,true,2);
        body.DamageMobj(null,null,5,'CaelumImpact',DMG_NO_ARMOR,0);
        Check(body.SpellSleep!=null && body.SpellSleep.HitsRemaining==2,"real health loss leaves two waking hits");
        if(User.ClassCastActive)
        {
            let racial=new("CaelumRacialAbilityEffect");racial.Revision=1;racial.Race=User.CharacterProfile.Race;
            User.RacialAbilityRevision=1;User.RacialAbility=racial;User.RacialAbilityActive=true;
        }
    }
}
