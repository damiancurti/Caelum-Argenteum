// Prueba del componente #238; no afirma el ciclo User4 todavía pendiente.
class CA238PresentationProbe : StaticEventHandler
{
    CA259Session Equipment;
    int PinnedTics,ExpectedTics,Passed,Failed,ClockSamples,ClockCycles;
    bool Pinned,Running;
    CaelumPlayer TestUser;
    void Check(bool ok,String label)
    {if(ok)Passed++;else Failed++;Console.Printf("CA238 %s %s",ok?"PASS":"FAIL",label);}
    override void UiTick(){if(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();}
    override void WorldTick()
    {
        if(TestUser==null)return;
        if(Pinned)TestUser.ClassPreparationTics=PinnedTics;
        if(Running)
        {
            ClockSamples++;
            Check(TestUser.ClassPreparationTics==ExpectedTics,"preparation clock advances once per tic");
            if(ExpectedTics>0)
                Check(!TestUser.StaffCastPending && !TestUser.PhysicalAttackPending
                    && TestUser.AttackAnimationDurationTics==0 && !TestUser.CombatBlockModeActive,
                    "native held attack cannot begin while preparing");
            if(ExpectedTics==0){Running=false;ClockCycles++;Console.Printf("CA238 CLOCK COMPLETE");}
            ExpectedTics--;
        }
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let user=CaelumPlayer(players[e.Player].mo);if(user==null)return;
        if(e.Name=="c238_setup")
        {
            TestUser=user;user.CreationWizardOpen=false;user.CharacterCreationComplete=true;
            user.ApplyCharacterProfile();user.bInvulnerable=true;
            user.CurrentAir=user.DerivedStats.MaximumAir;user.CurrentAnima=user.DerivedStats.MaximumAnima;
            Equipment=new("CA259Session");Equipment.Choice=0;Equipment.Tier=1;Equipment.Equip(user);
            Check(user.ClassPreparationTics==0,"default preparation is inactive");
        }
        if(e.Name=="c238_start")
        {
            user.CurrentAir=user.DerivedStats.MaximumAir;user.CurrentAnima=user.DerivedStats.MaximumAnima;
            user.EquippedWeaponCooldownRemaining=0;
            if(user.WeaponModel!=null)
                user.SetRangedMagazineCount(user.WeaponModel.WeaponType,user.GetRangedMagazineCapacity(user.WeaponModel.WeaponType));
            Pinned=false;CaelumClassCastView.Begin(user);
            Check(user.ClassPreparationTics==3*TICRATE,"three-second preparation");
            Check(!user.IsPhysicallyImmobilized(),"preparation does not immobilize movement");
            double air=user.CurrentAir,anima=user.CurrentAnima;
            user.PerformEquippedWeaponPrimaryAttack();user.PerformEquippedWeaponSecondaryAttack();
            user.PerformCarbineAttack();user.PerformDebugStaffAttack(false);user.PerformDebugStaffAttack(true);
            user.PerformDebugSwordAttack(false);user.PerformDebugSwordAttack(true);
            Check(user.CurrentAir==air && user.CurrentAnima==anima && !user.StaffCastPending
                && !user.PhysicalAttackPending && !user.BeginPhysicalAttackCycle(false)
                && !user.CanEnterCombatBlockMode(),"real attack and block entry guards");
            Running=true;ClockSamples=0;ExpectedTics=3*TICRATE;
        }
        if(e.Name=="c238_pose")
        {Pinned=true;PinnedTics=e.Args[0];user.ClassPreparationTics=PinnedTics;}
        if(e.Name=="c238_profile")
        {
            user.CharacterProfile.Race=e.Args[0];user.CharacterProfile.Sex=e.Args[1];
            user.CharacterProfile.BeastForm=e.Args[2];
        }
        if(e.Name=="c238_tone")user.CharacterProfile.SkinTone=e.Args[0];
        if(e.Name=="c238_weapon")
        {Equipment.Choice=e.Args[0];Equipment.Equip(user);}
        if(e.Name=="c238_unarmed")
        {
            user.EquipmentSelectionItemId=Equipment.TestItem.ItemId;
            user.RefreshEquipmentSelectionPreview();user.UnequipSelectedNativeEquipment();
            user.player.PendingWeapon=Weapon(user.FindInventory("CaelumUnarmedWeapon"));
        }
        if(e.Name=="c238_end")
        {
            Pinned=false;user.ClassPreparationTics=0;
            if(ClockSamples>0 || Running)Check(!Running && ClockSamples==3*TICRATE+1,"all clock samples exercised");
            Console.Printf("CA238 DONE failures=%d passes=%d cycles=%d COMPONENT_ONLY",Failed,Passed,ClockCycles);
        }
    }
}
