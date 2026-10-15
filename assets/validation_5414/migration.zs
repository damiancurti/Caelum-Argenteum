// Datos de diagnóstico persistentes, sólo en copias de partidas de prueba.
class CA253Snapshot : Inventory
{
    CaelumAnchoredResident Bodies[4];
    CaelumResidentTools Kits[4];
    CaelumEquipmentItem Melee[4],Staff[4],Bolas[4];
    int Wear[4];
    States { Spawn: TNT1 A -1; Stop; }
}
class CA253Migration : StaticEventHandler
{
    CaelumPlayer User;
    CA253Snapshot Snap;
    int Passed,Failed;
    void Check(bool ok,String label)
    {if(ok)Passed++;else Failed++;Console.Printf("CA253 %s %s",ok?"PASS":"FAIL",label);}
    override void UiTick(){if(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();}
    override void NetworkProcess(ConsoleEvent e)
    {
        User=CaelumPlayer(players[e.Player].mo);if(User==null)return;
        if(e.Name=="c253_seed")
        {
            User.CreationWizardOpen=false;User.CharacterCreationComplete=true;User.bInvulnerable=true;
            let bull=CaelumMainM00RuloTrial.GetBull();CaelumMainM00RuloTrial.StartFight(User,bull);
            bull.bDormant=true;bull.TrialGraceTicks=0;bull.TrialReleased=true;
            Snap=CA253Snapshot(Actor.Spawn("CA253Snapshot"));Snap.AttachToOwner(User);
            Class<CaelumAnchoredResident> types[]={"CaelumRulo","CaelumRonnie","CaelumArgento","CaelumCaella"};
            for(int i=0;i<4;i++)
            {
                let n=CaelumAnchoredResident(ThinkerIterator.Create(types[i]).Next());
                n.RuloPartyMode=2;n.bDormant=true;n.SetState(n.SpawnState);
                n.health=n.CombatMaximumHealth/2;n.CurrentCombatAir=n.MaximumCombatAir/3;n.CurrentCombatAnima=n.MaximumCombatAnima/4;
                n.CombatBaseSpeed=i==1?13.75:0;n.Speed=0;
                if(i==0){n.ElementalStatus.FreezeRemaining=10;n.ElementalStatus.FreezePowerPercent=50;}
                if(i==3)n.DownRuloPartyMember();
                Snap.Bodies[i]=n;Snap.Kits[i]=n.ResidentTools;
                Snap.Melee[i]=n.ResidentTools.Melee;Snap.Staff[i]=n.ResidentTools.Staff;Snap.Bolas[i]=n.ResidentTools.Bolas;
                n.ResidentTools.Melee.Durability=37+i;Snap.Wear[i]=37+i;
            }
            Console.Printf("CA253 DONE failures=0 passed=1 legacy missing-base checkpoint seeded");
        }
        if(e.Name=="c253_migration")
        {
            Snap=CA253Snapshot(User.FindInventory("CA253Snapshot"));Check(Snap!=null,"saved migration fixture retained");
            for(int i=0;i<4;i++)
            {
                let n=Snap.Bodies[i];let kit=n.ResidentTools;
                Check(n.CombatBaseSpeed==(i==1?13.75:GetDefaultByType(n.GetClass()).Speed),"native load repairs absent base and preserves positive customization");
                Check(kit==Snap.Kits[i] && kit.Melee==Snap.Melee[i] && kit.Staff==Snap.Staff[i] && kit.Bolas==Snap.Bolas[i],"native load retains original finite equipment identities");
                Check(kit.Melee.Durability==Snap.Wear[i],"migration does not replace or replenish worn equipment");
                Check(n.health<n.CombatMaximumHealth && n.CurrentCombatAir<n.MaximumCombatAir*0.6 && n.CurrentCombatAnima<n.MaximumCombatAnima*0.6,"migration does not heal or refill depleted resources");
                Check(n.RuloPartyMode==2 && n.RuloPartyTraveler==User && n.RuloPartyBull==CaelumMainM00RuloTrial.GetBull(),"migration retains encounter references");
                if(i==3)Check(n.RuloPartyDowned && !n.bShootable && !n.bSolid,"saved downed resident remains downed");
                if(i==0)Check(n.Speed>0 && n.Speed<n.CombatBaseSpeed,"repaired movement still applies saved health and elemental impairment");
            }
            Check(!User.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_BULL_DEFEATED),"migration does not award victory");
            Console.Printf("CA253 DONE failures=%d passed=%d",Failed,Passed);
        }
    }
}
