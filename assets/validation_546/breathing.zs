// #242: pruebas aisladas del consumidor real y de la entrada nativa.
class CA242Equipment : CA259Session
{
    override int Kind()
    {
        if(Choice==9)return CaelumConstants.WEAPON_TYPE_JAVELIN;
        if(Choice==10)return CaelumConstants.WEAPON_TYPE_BOLAS;
        if(Choice==12)return CaelumConstants.WEAPON_TYPE_GIANT_GAUNTLETS;
        return Super.Kind();
    }
}
class CA242Probe : StaticEventHandler
{
    CaelumPlayer User;
    CA242Equipment Equipment;
    int Passed,Failed;
    double BeforeAir,BeforeAnima;
    bool Manual;
    bool PinUnderwater;
    int WaterHealth;
    void Check(bool ok,String label)
    {if(ok)Passed++;else Failed++;Console.Printf("CA242 %s %s",ok?"PASS":"FAIL",label);}
    void Reset()
    {
        CaelumRacialAbilityRules.Deactivate(User);CaelumSleepRules.Wake(User);
        User.CharacterProfile.Race=CaelumConstants.RACE_CAELITH;
        User.CharacterCreationComplete=true;User.CreationWizardOpen=false;
        User.ApplyCharacterProfile();User.CurrentAnima=1000;User.CurrentAir=500;
        User.CurrentLucidity=100;User.CurrentSleep=100;User.UpdateLucidityState();
        User.health=User.CaelumMaximumHealth;User.player.health=User.health;
        User.player.playerstate=PST_LIVE;User.bInvulnerable=false;
        User.LucidityPhysicalStunRemaining=0;User.PainImmobilizationRemaining=0;
        User.RacialAbilityInputLatched=false;User.CombatChannelModeActive=false;
        User.UnderwaterAirRecoveryDebt=0;User.UnderwaterAirRecoveryTicsRemaining=0;
        User.UnderwaterNoBreathTics=0;User.UnderwaterDrowningTics=0;
        User.EquipmentMenuOpen=false;CaelumClassAbilityRules.Cancel(User);
        User.DerivedStats.AnimaCostReductionPercent=50;
        User.DerivedStats.AirRegenerationPerSecond=0;User.DerivedStats.AnimaRegenerationPerSecond=0;
    }
    void Activate()
    {Check(CaelumRacialAbilityRules.Begin(User),"real Caelith factory admits activation");CaelumRacialAbilityRules.Advance(User);}
    void Contracts()
    {
        Reset();double removed=CaelumAirPayment.Spend(User,80);
        Check(removed==80 && User.CurrentAir==420 && User.CurrentAnima==1000,"inactive expenditure uses only Air");
        Reset();Activate();
        Check(User.CurrentAnima==1000 && CaelumAirPayment.Substituting(User),"activation has no initial charge");
        for(int i=0;i<70;i++)CaelumRacialAbilityRules.Advance(User,false);
        Check(User.CurrentAnima==1000,"no flat consumption in two simulated seconds");
        removed=CaelumAirPayment.Spend(User,80);
        Check(removed==0 && User.CurrentAir==500 && User.CurrentAnima==960,"80 Air demand costs 40 Anima at fifty percent reduction");
        User.DerivedStats.AnimaCostReductionPercent=0;CaelumAirPayment.Spend(User,80);
        Check(User.CurrentAir==500 && User.CurrentAnima==880,"one to one before live reduction");
        User.CurrentAnima=39.75;User.DerivedStats.AnimaCostReductionPercent=50;
        removed=CaelumAirPayment.Spend(User,80);
        Check(!User.RacialAbilityActive && User.CurrentAnima==39.75 && User.CurrentAir==420 && removed==80,"unaffordable whole action stops and preserves Anima remainder");
        Reset();Activate();User.CurrentAir=0;
        Check(CaelumAirPayment.CanAfford(User,80),"zero Air does not reject an affordable substituted effort");
        CaelumAirPayment.Spend(User,80);
        Check(User.CurrentAir==0 && User.CurrentAnima==960,"zero Air does not make the required effort free");
        User.CurrentAnima=40;CaelumAirPayment.Spend(User,80);
        Check(User.CurrentAnima==0 && User.CurrentAir==0 && !User.RacialAbilityActive,"exact last payment deactivates without draining Air");
        Reset();Activate();User.CurrentAir=20;User.CurrentAnima=39;
        Check(!CaelumAirPayment.CanAfford(User,80) && !User.RacialAbilityActive && User.CurrentAir==20 && User.CurrentAnima==39,"rejected action with both reserves short spends nothing");
        Reset();Activate();double before=User.CurrentAnima;
        User.ConsumeJumpAir();
        double jump=CaelumConstants.JUMP_AIR_COST*User.DerivedStats.AirConsumptionMultiplier*CaelumThermalEffects.HeatCost(User);
        Check(User.CurrentAir==500 && Abs(User.CurrentAnima-(before-jump/2))<1e-8,"actual jump consumer substitutes after ordinary modifiers");
        Reset();Activate();User.IsSpendingRunningAir=true;User.ConsumeRunningAir();
        double run=CaelumConstants.RUN_AIR_COST_PER_SECOND*User.DerivedStats.AirConsumptionMultiplier*CaelumThermalEffects.HeatCost(User)/TICRATE;
        Check(User.CurrentAir==500 && Abs(User.CurrentAnima-(1000-run/2))<1e-8,"actual running consumer pays Anima only");
        User.IsSpendingRunningAir=false;
        Reset();Activate();User.CurrentAir=0;
        User.UpdateUnderwaterAirForState(true);
        double breath=User.UnderwaterCurrentBaseCostPerSecond*User.DerivedStats.AirConsumptionMultiplier/TICRATE;
        Check(User.CurrentAir==0 && Abs(User.CurrentAnima-(1000-breath/2))<1e-8 && User.UnderwaterDrowningTics==0,"actual underwater consumer pays at zero Air instead of drowning");
        Check(User.UnderwaterAirRecoveryDebt==0,"substituted breathing does not create a free Air refund");
        User.CurrentAir=500;User.CurrentAnima=0.000001;before=User.CurrentAnima;
        User.UpdateUnderwaterAirForState(true);
        breath=User.UnderwaterCurrentBaseCostPerSecond*User.DerivedStats.AirConsumptionMultiplier/TICRATE;
        Check(!User.RacialAbilityActive && User.CurrentAnima==before && Abs(User.CurrentAir-(500-breath))<1e-8 && Abs(User.UnderwaterAirRecoveryDebt-breath)<1e-8,"underwater failure returns whole demand to Air and ordinary debt");
        Reset();Activate();User.PainImmobilizationRemaining=1;CaelumRacialAbilityRules.Guard(User);
        Check(!User.RacialAbilityActive && User.CurrentAnima==1000,"forced immobilization ends this real racial without a fee");
        Reset();User.CharacterProfile.Race=CaelumConstants.RACE_HUMAN;
        Check(!CaelumRacialAbilityRules.Begin(User),"saved race alone selects the ability");
        Reset();
    }
    override void UiTick(){if(!Manual && Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();}
    override void WorldTick()
    {
        let user=CaelumPlayer(players[0].mo);
        if(user!=null && user.DerivedStats!=null)
        {
            user.DerivedStats.AnimaRegenerationPerSecond=0;user.DerivedStats.AirRegenerationPerSecond=0;
            user.DerivedStats.HealthRegenerationPerSecond=0;
            if(!Manual)user.DerivedStats.AnimaCostReductionPercent=50;
            if(PinUnderwater && level.MapName=="MAP97")
            {user.SetOrigin((0,0,0),false);user.Vel=(0,0,0);}
        }
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        User=CaelumPlayer(players[e.Player].mo);if(User==null)return;
        if(e.Name=="c242_setup")
        {Contracts();Equipment=new("CA242Equipment");Equipment.Tier=1;Equipment.Choice=4;Equipment.Equip(User);}
        if(e.Name=="c242_on")Check(CaelumAirPayment.Substituting(User),"native User1 activates the actual Caelith effect");
        if(e.Name=="c242_off")Check(User.RacialAbility==null && !User.RacialAbilityActive,"native second press ends the effect");
        if(e.Name=="c242_equipment")
        {
            User.CancelCombatBlockMode();Equipment.Choice=e.Args[0];
            if(Equipment.Choice==11)
            {
                User.EquipmentSelectionItemId=Equipment.TestItem.ItemId;User.RefreshEquipmentSelectionPreview();
                User.UnequipSelectedNativeEquipment();User.EnsureUnarmedFallback();
                User.player.PendingWeapon=Weapon(User.FindInventory("CaelumUnarmedWeapon"));
            }
            else Equipment.Equip(User);
            int kind=User.WeaponModel.WeaponType;
            if(User.IsRangedWeaponType(kind))User.SetRangedMagazineCount(kind,User.GetRangedMagazineCapacity(kind));
        }
        if(e.Name=="c242_snapshot")
        {User.CurrentAir=500;User.CurrentAnima=1000;BeforeAir=User.CurrentAir;BeforeAnima=User.CurrentAnima;}
        if(e.Name=="c242_action")
        {
            bool active=e.Args[0]!=0;
            Console.Printf("CA242 RESOURCE active=%d air=%.8f anima=%.8f",active,User.CurrentAir,User.CurrentAnima);
            Check(active ? Abs(User.CurrentAir-BeforeAir)<1e-6 && User.CurrentAnima<BeforeAnima
                : User.CurrentAir<BeforeAir && Abs(User.CurrentAnima-BeforeAnima)<1e-6,"native effort uses exactly its selected reserve");
        }
        if(e.Name=="c242_saved" || e.Name=="c242_rollback_return")
        {
            Check(e.Name=="c242_saved" ? CaelumAirPayment.Substituting(User) : User.RacialAbility==null && !User.RacialAbilityActive,"saved/hub or rollback-return effect retains its state");
            Check(Abs(User.CurrentAnima-777)<1e-6 && Abs(User.CurrentAir-333)<1e-6,"saved/hub idle reserves have no fee or refill");
        }
        if(e.Name=="c242_seed_save"){User.CurrentAnima=777;User.CurrentAir=333;}
        if(e.Name=="c242_manual")
        {
            Manual=true;Reset();User.ApplyCharacterProfile();
            User.CurrentAnima=User.DerivedStats.MaximumAnima;User.CurrentAir=User.DerivedStats.MaximumAir;
            Equipment=new("CA242Equipment");Equipment.Tier=1;Equipment.Choice=12;Equipment.Equip(User);
            Console.Printf("CA242 DONE failures=0 MANUAL_SEED_ONLY");
            CaelumNotifications.Notify(User,"#242 | F: racial | F6: reiniciar | F7: agua | F8: poca Anima | F10: tierra");
        }
        if(e.Name=="c242_low_anima")User.CurrentAnima=0.000001;
        if(e.Name=="c242_empty_air"){User.CurrentAir=0;User.UpdateAirStateEffects();}
        if(e.Name=="c242_water_seed")
        {PinUnderwater=true;User.CurrentAir=0;User.CurrentAnima=100;WaterHealth=User.health;}
        if(e.Name=="c242_water_check")
        {
            Check(User.WaterLevel==3 && User.CurrentAir==0 && User.CurrentAnima<100 && User.RacialAbilityActive,"native submerged body uses only Anima");
            Check(User.health==WaterHealth && User.UnderwaterDrowningTics==0 && User.UnderwaterAirRecoveryDebt==0,"native paid breathing prevents drowning without accumulating Air debt");
        }
        if(e.Name=="c242_water_exhaust")
        {User.CurrentAir=3;User.CurrentAnima=0.000001;WaterHealth=User.health;}
        if(e.Name=="c242_water_fallback")
        {
            Check(!User.RacialAbilityActive && User.CurrentAnima==0.000001 && User.CurrentAir==0,"native submerged exhaustion retains Anima remainder then spends Air");
            Check(User.health<WaterHealth && Abs(User.UnderwaterAirRecoveryDebt-3)<1e-6,"ordinary drowning resumes and only actual Air loss becomes debt");
            PinUnderwater=false;
        }
        if(e.Name=="c242_water_surface")Check(Abs(User.CurrentAir-3)<1e-6 && User.UnderwaterAirRecoveryDebt==0,"surfacing refunds exactly the three actual Air points");
        if(e.Name=="c242_done")Console.Printf("CA242 DONE failures=%d passes=%d",Failed,Passed);
    }
}
