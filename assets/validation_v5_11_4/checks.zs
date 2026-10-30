class CA430Token : Inventory
{
    Default { Inventory.MaxAmount 100; +INVENTORY.UNDROPPABLE }
    States { Spawn: TNT1 A -1; Stop; }
}
class CA430Checks : EventHandler
{
    CaelumCompanionParty Party;
    CaelumCompanionBond First;
    int Passes,Failures,SeedTic,RosterTic;
    CaelumAnchoredResident Prisoners[4];
    CaelumCompanionSubcaptain Captain;
    bool ShowPanel;
    override void UiTick()
    {
        let current=Menu.GetCurrentMenu();
        if(ShowPanel && ConversationMenu(current)!=null)current.MenuEvent(Menu.MKEY_Back,false);
    }
    override void WorldTick()
    {
        if(SeedTic>0 && level.time>=SeedTic){SeedTic=0;FinishSeed();}
        if(RosterTic>0 && level.time>=RosterTic){RosterTic=0;FinishRoster();}
    }

    void StartRoster()
    {
        let user=CaelumPlayer(players[0].mo);
        let world=CaelumMainM00QuestController(EventHandler.Find("CaelumMainM00QuestController"));
        world.EnsureResidentRegistry();
        for(int i=0;i<4;i++)
            Check(world.StoryResidents[i]!=null && Party.Recruit(world.StoryResidents[i]),
                String.Format("authored mansion resident %d recruits without a fee",i));
        for(int i=0;i<4;i++)
        {
            user.SetPlayerPrisonerRescueState(i,CaelumConstants.PRISONER_STATE_FOLLOWING);
            Name type=i==0 ? 'CaelumPrisonerUnitario' : i==1 ? 'CaelumPrisonerFederal'
                : i==2 ? 'CaelumPrisonerTarot' : 'CaelumPrisonerBestia';
            Prisoners[i]=CaelumAnchoredResident(Actor.Spawn(type,user.Pos+(300+i*80,160,0),NO_REPLACE));
        }
        RosterTic=level.time+2;
    }

    void FinishRoster()
    {
        let user=CaelumPlayer(players[0].mo);
        Check(Party.Recruit(Prisoners[0]) && Party.Recruit(Prisoners[1]) && Party.Occupied()==8,
            "player and seven authored companions fill the party");
        Check(!Party.Recruit(Prisoners[2]) && !Party.Recruit(Prisoners[3]) && Party.Occupied()==8,
            "additional eligible recruits cannot exceed eight total members");
        First.Body.bBuddha=false;First.Body.bInvulnerable=false;
        First.Body.DamageMobj(user,user,1000000,'None',DMG_FORCED|DMG_NO_ARMOR,0);
        let clock=CaelumWorldClock.Get(user);clock.CompletedDays+=4;First.Reconcile();
        Check(First.SlotReleased && Party.Recruit(Prisoners[2]) && Party.Occupied()==8,
            "a released dead slot admits another authored companion without deleting its corpse");
        Check(CaelumResurrection.Restore(First.Body,First.Body.Pos),"native revival succeeds even when the party is full");
        First.Reconcile();
        Check(!First.Enlisted && First.Order==CaelumCompanionData.DISMISSED && Party.Occupied()==8
            && First.Body.FindInventory("CA430Token").Amount==7,
            "revival into a full party waits with inventory and displaces nobody");
        Check(!Party.Recruit(First.Body),"full party rejects a revived member until space exists");
        Check(Party.SetOrder(Prisoners[2].Companion,CaelumCompanionData.DISMISSED) && Party.Recruit(First.Body),
            "making room allows the same revived body to rejoin");
        Check(!CaelumCompanions.Controlled(Prisoners[2]),"dismissal leaves an unfinished prisoner's existing escort active");
        Console.Printf("CA430 RESULT roster complete failures=%d",Failures);
    }
    void Check(bool ok,String label)
    {if(ok){Passes++;Console.Printf("CA430 PASS %s",label);}else{Failures++;Console.Printf("CA430 FAIL %s",label);}}
    void Seed()
    {
        let user=CaelumPlayer(players[0].mo);Party=CaelumCompanionParty.Get(user,true);
        Captain=CaelumCompanionSubcaptain(Actor.Spawn("CaelumCompanionSubcaptain",user.Pos+(200,0,0),NO_REPLACE));
        SeedTic=level.time+2;
    }
    void FinishSeed()
    {
        let user=CaelumPlayer(players[0].mo);let captain=Captain;
        Console.Printf("CA430 PROFILE strength=%d agility=%d insight=%d",captain.CombatStrength,captain.CombatAgility,captain.CombatInsight);
        Check(captain.CombatStrength==20 && captain.CombatAgility==20 && captain.CombatInsight==20,
            "subcaptain has authored attributes and Domingo body");
        double originalLoad=captain.GetAttackCarriedWeight();
        Check(Party.Recruit(captain),"free recruitment creates a persistent bond");
        First=captain.Companion;captain.GiveInventory("CA430Token",7);
        Check(Abs(captain.GetAttackCarriedWeight()-originalLoad)<0.000001,
            "native gear binding preserves the exact pre-recruitment carried load");
        let armor=First.Loadout.Armor[0];double load=captain.GetAttackCarriedWeight();
        Check(armor!=null && armor.Owner==captain && armor.Equipped,"existing armor becomes an owned native piece once");
        captain.CombatArmor.Durability[0]=17;First.Loadout.Sync();
        Check(armor.Durability==17,"equipped durability uses the same combat model");
        Check(First.Loadout.Toggle(armor) && !armor.Equipped && captain.CombatArmor.GetDefense(0)==0,
            "removing armor removes defense but retains the native object");
        Check(Abs(captain.GetAttackCarriedWeight()-load)<0.000001,"armor carried weight is not counted twice or lost on removal");
        Check(First.Loadout.Toggle(armor) && captain.CombatArmor.Durability[0]==17,"re-equipping preserves wear and restores the shared model");
        let shield=First.Loadout.ShieldItem;
        Check(shield!=null && First.Loadout.Toggle(shield) && captain.Shield==null && !shield.Equipped,
            "removing a shield disables its native block without losing the item");
        Check(First.Loadout.Toggle(shield) && captain.Shield==First.Loadout.Shield && shield.Equipped,
            "re-equipping a shield restores the same shared blocking rules");
        let sword=First.Loadout.SidearmItem;
        Check(sword!=null && First.Loadout.Toggle(sword) && captain.Sword==null,
            "removing a sidearm prevents the old intrinsic sword attack");
        Check(First.Loadout.Toggle(sword) && First.Loadout.SelectedWeapon==sword && First.Loadout.Tools.Melee==sword,
            "selected melee weapon uses its native item and shared attack catalogue");
        let thermal=CaelumThermalBody.Get(captain,true);CaelumThermalBody.Refresh(captain,thermal);
        let exposure=new("CaelumContaminationNPC");exposure.Capture(captain,thermal);
        int head=exposure.Frame.Armor[0];
        Check(exposure.Count==CaelumConstants.ARMOR_SLOT_COUNT+2 && head>=0
            && exposure.Frame.Items[head].Item==armor
            && exposure.Frame.Items[head].Area==exposure.Frame.BodyArea[0],
            "materialized equipment exposes each piece once with the actual worn body area");
        Check(Party.Recruit(captain) && Party.Roster.Size()==1 && Party.Occupied()==2,"repeat invitation is idempotent");
        Check(Party.SetOrder(First,CaelumCompanionData.WAIT) && captain.Formation==null,"wait removes marching slot without releasing membership");
        Check(Party.SetOrder(First,CaelumCompanionData.FOLLOW) && captain.Formation!=null,"follow rejoins the same formation");
        Check(Party.SetOrder(First,CaelumCompanionData.DISMISSED) && Party.Occupied()==1,"dismissal releases membership without destroying body");
        First.Trust=12.5;Check(Party.Recruit(captain) && First.Trust==12.5,"reinvitations preserve private trust");
        let clock=CaelumWorldClock.Get(user,true);
        captain.health=0;First.RecordDeath();
        clock.CompletedDays=First.DeathDay+3;clock.DayTics=First.DeathTic;First.Reconcile();
        Check(!First.SlotReleased && Party.Occupied()==2,"exactly three days still reserves the dead slot");
        clock.AdvanceTics(1);First.Reconcile();
        Check(First.SlotReleased && Party.Occupied()==1 && captain.health==0,"after three days releases only the slot");
        captain.health=100;First.Reconcile();
        Check(!First.DeathRecorded && !First.SlotReleased && First.Enlisted,"resurrection restores an available reserved membership");
        captain.SetOrigin(user.Pos+(80,0,0),false);
        Check(CaelumCompanionSession.Show(user,captain),"administration opens only for a reachable actor");
        let session=CaelumCompanionSession.Find(user);
        let coins=Inventory(Actor.Spawn(CaelumEconomyRules.GetCurrencyClassName(0),user.Pos,NO_REPLACE));
        coins.Amount=10;coins.AttachToOwner(user);
        session.PlayerItems=true;double before=First.Trust;
        Check(session.Transfer(coins,true) && coins.Owner==captain && First.Trust==before,"loan transfers exact native object without gifting trust");
        session.PlayerItems=false;
        Check(session.Transfer(coins,false) && coins.Owner==user,"loan returns without a social roll");
        session.PlayerItems=true;double value=CaelumEconomyRules.GetInventoryStackBaseValue(coins);
        Check(session.Transfer(coins,false) && Abs(First.Trust-before-value/CaelumCompanionData.TRUST_VALUE)<0.00000001,
            "first committed gift credits fractional base value exactly once");
        let gift=First.ItemRecord(coins);double earned=First.Trust;
        double oldCharisma=user.Attributes.Charisma;user.Attributes.Charisma=1000;session.PlayerItems=false;
        Check(session.Transfer(coins,false),"successful social request returns the original gifted object");
        session.PlayerItems=true;
        Check(session.Transfer(coins,false) && First.Trust==earned,"regifting the identical item cannot farm trust");
        user.Attributes.Charisma=oldCharisma;session.Open=false;First.Trust=12.5;
        Console.Printf("CA430 RESULT core complete passes=%d failures=%d",Passes,Failures);
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=='ca430_seed')Seed();
        if(e.Name=='ca430_roster')StartRoster();
        if(e.Name=='ca430_ui')
        {
            ShowPanel=true;
            let user=CaelumPlayer(players[0].mo);Party=CaelumCompanionParty.Get(user);First=Party.Find(8);
            First.Body.SetOrigin(user.Pos+(80,0,0),false);
            Check(CaelumCompanionSession.Show(user,First.Body),"native party panel opens for the existing companion");
            Console.Printf("CA430 RESULT UI open failures=%d",Failures);
        }
        if(e.Name=='ca430_die')
        {
            let user=CaelumPlayer(players[0].mo);Party=CaelumCompanionParty.Get(user);First=Party.Find(8);
            First.Body.bInvulnerable=false;First.Body.bBuddha=false;
            First.Body.DamageMobj(user,user,1000000,'None',DMG_FORCED|DMG_NO_ARMOR,0);
            Check(First.Body.health<=0 && First.DeathRecorded && First.Enlisted && !First.SlotReleased,
                "native combat death records the exact body and reserves its party slot");
            Console.Printf("CA430 RESULT death complete failures=%d",Failures);
        }
        if(e.Name=='ca430_deadtravel')
        {
            Party=CaelumCompanionParty.Get(CaelumPlayer(players[0].mo));First=Party.Find(8);
            Check(First.Parked && First.Body.health<=0 && First.DeathRecorded,"map travel cannot automatically resurrect a dead companion");
            Check(First.Body.FindInventory("CA430Token").Amount==7,"the parked corpse retains the original native inventory");
            Console.Printf("CA430 RESULT dead travel complete failures=%d",Failures);
        }
        if(e.Name=='ca430_revive')
        {
            Party=CaelumCompanionParty.Get(CaelumPlayer(players[0].mo));First=Party.Find(8);
            Check(!First.Parked && First.Body.health<=0 && First.Body.bCorpse,"return restores the original corpse without automatic recovery");
            Check(CaelumResurrection.Restore(First.Body,First.Body.Pos),"existing resurrection service restores the same body");
            First.Reconcile();
            Check(First.Body.health>0 && !First.DeathRecorded && First.Enlisted
                && First.Body.FindInventory("CA430Token").Amount==7,"revival retains membership and exact inventory without rewards");
            Console.Printf("CA430 RESULT revival complete failures=%d",Failures);
        }
        if(e.Name=='ca430_wait')
        {
            Party=CaelumCompanionParty.Get(CaelumPlayer(players[0].mo));First=Party.Find(8);
            Check(Party.SetOrder(First,CaelumCompanionData.WAIT),"wait order records the current map and position");
        }
        if(e.Name=='ca430_parked')
        {
            Party=CaelumCompanionParty.Get(CaelumPlayer(players[0].mo));First=Party.Find(8);
            Check(First.Parked && First.SourceMap=="MAP01" && First.Body.FindInventory("CA430Token").Amount==7,
                "waiting body stays assigned to its original map with its inventory");
            Console.Printf("CA430 RESULT parked complete failures=%d",Failures);
        }
        if(e.Name=='ca430_return')
        {
            Party=CaelumCompanionParty.Get(CaelumPlayer(players[0].mo));First=Party.Find(8);
            Console.Printf("CA430 RETURN actual=(%.3f,%.3f,%.3f) saved=(%.3f,%.3f,%.3f) floor=%.3f target=%s",
                First.Body.Pos.X,First.Body.Pos.Y,First.Body.Pos.Z,First.Position.X,First.Position.Y,First.Position.Z,
                First.Body.FloorZ,First.Body.target!=null ? First.Body.target.GetClassName() : 'none');
            Check(!First.Parked && First.SourceMap=="MAP01" && First.Order==CaelumCompanionData.WAIT,
                "waiting companion returns only when its source map loads");
            Check((First.Body.Pos.XY-First.Position.XY).Length()<=First.Body.Radius
                && Abs(First.Body.Pos.Z-First.Position.Z)<=First.Body.MaxStepHeight,
                "waiting companion remains within its recorded physical footprint after settling");
            Check(First.Loadout.Armor[0]!=null && First.Loadout.Armor[0].Owner==First.Body
                && First.Body.CombatArmor.Durability[0]==17,"armor ownership and wear survive a hub round trip");
            Console.Printf("CA430 RESULT return complete failures=%d",Failures);
        }
        if(e.Name=='ca430_travel')
        {
            Party=CaelumCompanionParty.Get(CaelumPlayer(players[0].mo));First=Party!=null ? Party.Find(8) : null;
            Check(First!=null && First.Body!=null && First.Body.FindInventory("CA430Token")!=null
                && First.Body.FindInventory("CA430Token").Amount==7,"map travel preserves exact native inventory");
            Check(First!=null && !First.Parked && First.Body.Companion==First && First.Enlisted,
                "same companion resumes in the destination without duplication");
            Check(First!=null && First.Body.CombatStrength==20 && First.Trust==12.5,
                "map travel preserves attributes and private trust");
            Console.Printf("CA430 RESULT travel complete failures=%d",Failures);
        }
        if(e.Name=='ca430_reload')
        {
            Check(Party!=null && First!=null && Party.Find(8)==First,"save preserves native companion identity");
            Check(First.Body!=null && First.Body.Companion==First && First.Trust==12.5,"save preserves body and trust without duplication");
            Console.Printf("CA430 RESULT reload complete failures=%d",Failures);
        }
    }
}
