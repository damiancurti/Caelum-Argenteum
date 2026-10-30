// Local author fixtures only; never packaged in the game.
class CA511Manual : EventHandler
{
    CaelumCombatActor Focus;
    bool KitGranted;
    override void UiTick()
    {
        if(level.time>100)return;
        let menu=Menu.GetCurrentMenu();
        if(ConversationMenu(menu)!=null)menu.MenuEvent(Menu.MKEY_Back,false);
    }
    void Visit(CaelumPlayer user,int id)
    {
        let world=CaelumMainM00QuestController(EventHandler.Find("CaelumMainM00QuestController"));
        if(level.MapName=="MAP01")
        {world.EnsureResidentRegistry();Focus=world.StoryResidents[Clamp(id,0,3)];}
        else if(level.MapName=="MAP02")
        {let it=ActorIterator.Create(CaelumConstants.PRISONER_TID_BASE+Clamp(id,0,3));Focus=CaelumCombatActor(it.Next());}
        if(Focus==null)return;
        user.SetOrigin(Focus.Pos+(80,0,0),false);user.Angle=user.AngleTo(Focus);user.Pitch=0;
        Console.Printf("CA511 VISIT %s: Usa el personaje para conversar. F5 abre su panel; Tab lo cierra.",Focus.GetTag());
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let user=CaelumPlayer(players[0].mo);if(user==null)return;
        if(e.Name=='ca511_visit')Visit(user,e.Args[0]);
        if(e.Name=='ca511_panel' && Focus!=null)
        {bool opened=CaelumCompanionSession.Show(user,Focus);Console.Printf("CA511 PANEL opened=%d",opened);}
        if(e.Name=='ca511_release' && Focus!=null)
        {let prisoner=CaelumAnchoredResident(Focus);if(prisoner!=null && prisoner.IsEscortPrisoner())prisoner.ReleaseEscortPrisoner(user);}
        if(e.Name=='ca511_kit' && !KitGranted)
        {
            KitGranted=true;
            let money=Inventory(Actor.Spawn(CaelumEconomyRules.GetCurrencyClassName(0),user.Pos,NO_REPLACE));
            money.Amount=10000;money.AttachToOwner(user);
            let model=new("CaelumWeaponModel");model.InitializeDefaults();
            let item=CaelumEquipmentItem(Actor.Spawn("CaelumWeaponPickup",user.Pos,NO_REPLACE));
            item.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_WEAPON;item.ItemType=CaelumConstants.WEAPON_TYPE_SWORD;
            item.Tier=1;item.EquipmentSize=Focus!=null && Focus.CombatArmor!=null ? Focus.CombatArmor.Size[1] : CaelumConstants.EQUIPMENT_SIZE_M;item.Durability=100;
            item.UnitWeight=model.GetWeightFor(item.ItemType,1,item.EquipmentSize);
            item.PickupDataInitialized=item.AcquisitionResolved=true;item.AttachToOwner(user);
            Console.Printf("CA511 KIT 10000 cobres y espada de prueba disponibles una sola vez.");
        }
        if(e.Name=='ca511_status')
        {
            let party=CaelumCompanionParty.Get(user);
            Console.Printf("CA511 PARTY occupied=%d / 8 (incluye al jugador)",party!=null?party.Occupied():1);
            if(party!=null)for(int i=0;i<party.Roster.Size();i++)
            {let bond=party.Roster[i];Console.Printf("CA511 MEMBER %s health=%d trust=%.3f order=%d parked=%d",bond.Body.GetTag(),bond.Body.health,bond.Trust,bond.Order,bond.Parked);}
        }
        if(e.Name=='ca511_shape')
        {
            let party=CaelumCompanionParty.Get(user);if(party==null)return;
            party.EnsureFormation();party.Formation.SetShape((party.Formation.Shape+1)%4,true);
            Console.Printf("CA511 FORMATION %d",party.Formation.Shape);
        }
        if(e.Name=='ca511_ready')
        {user.bInvulnerable=true;Console.Printf("CA511 RESULT escenario listo. Pruebas locales: no modifican tus partidas de campana.");}
    }
}
