// Prueba manual aislada de preparación; no modifica controles del perfil personal.
class CA238Manual : StaticEventHandler
{
    CaelumPlayer User;
    CA259Session Equipment;
    bool Ready;
    override void UiTick()
    {if(!Ready && Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();}
    override void WorldTick()
    {
        if(!Ready || User==null)return;
        User.DerivedStats.AnimaRegenerationPerSecond=0;
        User.CurrentAir=User.DerivedStats.MaximumAir;
        User.CurrentLucidity=100;User.UpdateLucidityState();
    }
    void Reset()
    {
        CaelumClassAbilityRules.Cancel(User);CaelumSleepRules.Wake(User);
        User.ClassSleepCooldownRemaining=0;User.ClassSleepInputLatched=false;
        User.CurrentAnima=1000;User.LucidityPhysicalStunRemaining=0;
        User.PainImmobilizationRemaining=0;User.CombatChannelModeActive=false;
        CaelumNotifications.Notify(User,"#238 | F: habilidad/cancelar | F6: reiniciar | F7: arma | F8: puños | F9: Ánima insuficiente");
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="c238_manual")
        {
            User=CaelumPlayer(players[e.Player].mo);if(User==null)return;
            User.CreationWizardOpen=false;User.CharacterCreationComplete=true;
            User.CharacterProfile.FirstClass=CaelumConstants.CLASS_PRIEST;
            User.CharacterProfile.SecondClass=CaelumConstants.CLASS_MAGE;
            User.CharacterProfile.Race=CaelumConstants.RACE_HUMAN;
            User.ApplyCharacterProfile();User.Attributes.Eloquence=0;
            User.DerivedStats.Recalculate(User.Attributes,User.CharacterProfile);
            User.bInvulnerable=true;
            Equipment=new("CA259Session");Equipment.Tier=1;Equipment.Choice=0;
            Reset();Equipment.Equip(User);Ready=true;
            Console.Printf("CA238 MANUAL ready profession=%d cost=%.4f weapon=%d",
                User.CharacterProfile.GetProfession(),CaelumSleepRules.Cost(User),User.WeaponModel.WeaponType);
            return;
        }
        if(!Ready || User==null)return;
        if(e.Name=="c238_reset")Reset();
        if(e.Name=="c238_weapon" && !User.ClassCastActive)
        {Equipment.Choice=(Equipment.Choice+1)%9;Equipment.Equip(User);}
        if(e.Name=="c238_unarmed" && !User.ClassCastActive)
        {
            User.EquipmentSelectionItemId=Equipment.TestItem.ItemId;User.RefreshEquipmentSelectionPreview();
            User.UnequipSelectedNativeEquipment();User.EnsureUnarmedFallback();
            User.player.PendingWeapon=Weapon(User.FindInventory("CaelumUnarmedWeapon"));
        }
        if(e.Name=="c238_short"){Reset();User.CurrentAnima=Max(0,CaelumSleepRules.Cost(User)-1);}
        if(e.Name=="c238_manual_check")
            Console.Printf("CA238 DONE failures=%d MANUAL_SEED_ONLY",
                User!=null && User.CharacterProfile.GetProfession()==CaelumConstants.PROFESSION_ARCANIST
                && User.CurrentAnima==1000 && User.player.ReadyWeapon!=null?0:1);
    }
}
