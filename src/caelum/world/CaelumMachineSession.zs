class CaelumMachineSession : Inventory
{
    bool Open,Building;
    Actor Target,Contact;
    int Faction,Recipe;
    String OriginMap,Status;
    vector3 Point;
    double Facing;
    static CaelumMachineSession Find(CaelumPlayer user,bool create=false)
    {
        if(user==null)return null;
        let session=CaelumMachineSession(user.FindInventory('CaelumMachineSession'));
        if(session==null && create)session=CaelumMachineSession(user.GiveInventoryType('CaelumMachineSession'));
        return session;
    }
    void SelectFaction(CaelumPlayer user,int direction)
    {
        for(int i=1;i<=CaelumConstants.FACTION_COUNT;i++)
        {
            int candidate=(Faction+direction*i+CaelumConstants.FACTION_COUNT*2)%CaelumConstants.FACTION_COUNT;
            if(CaelumMachineOwnership.Member(user,candidate)){Faction=candidate;return;}
        }
        Faction=-1;
    }
    static bool Show(CaelumPlayer user,Actor target,Actor contact)
    {
        if(!CaelumPlayerAuthority.CanMutate(user) || !CaelumMachineWork.Reach(user,contact))return false;
        let machine=CaelumHostileMachine(target);let barrier=CaelumBarricade(target);
        if(machine==null && barrier==null)return false;
        if(machine!=null)machine.EnsureMachine();else barrier.InitializeGate();
        let session=Find(user,true);if(session==null)return false;
        session.Target=target;session.Contact=contact;session.Building=false;session.Open=true;
        session.OriginMap=level.MapName;session.Faction=-1;session.SelectFaction(user,1);session.Status="";
        CloseOtherPanels(user);
        return true;
    }
    static void BuildMenu(CaelumPlayer user)
    {
        let session=Find(user,true);if(session==null)return;
        session.Building=true;session.Open=true;session.Target=null;session.Contact=user.ActiveCraftingStationActor;
        session.Recipe=user.CraftingSelectionRecipe;session.OriginMap=level.MapName;session.Status="";
        session.Faction=-1;session.SelectFaction(user,1);
        session.Facing=user.Angle;
        int kind=session.Recipe-CaelumMachineData.FIRST_RECIPE;
        double distance=CaelumMachineCrafting.Radius(kind)+user.Radius+CaelumPlacementGeometry.SUPPORT_TOLERANCE_MU;
        session.Point=user.Pos+(Cos(user.Angle)*distance,Sin(user.Angle)*distance,0);
        CloseOtherPanels(user);
    }
    static void CloseOtherPanels(CaelumPlayer user)
    {
        user.EquipmentMenuOpen=false;user.ClosePalomoMerchant();user.SetCraftingJournalState(false);
        let military=CaelumMilitarySession(user.FindInventory('CaelumMilitarySession'));if(military!=null)military.Open=false;
        let companion=CaelumCompanionSession(user.FindInventory('CaelumCompanionSession'));if(companion!=null)companion.Open=false;
    }
    void Act(int choice)
    {
        let user=CaelumPlayer(Owner);
        if(!Open || !CaelumPlayerAuthority.CanMutate(user))return;
        if(choice==0){Open=false;if(Building)user.SetCraftingJournalState(true);return;}
        if(OriginMap!=level.MapName){Open=false;return;}
        if(choice==8 || choice==9){SelectFaction(user,choice==8?-1:1);return;}
        if(Building)
        {
            if(choice!=1)return;
            user.CraftingSelectionRecipe=Recipe;
            bool started=CaelumMachineWork.BeginBuild(user,Faction,Point,Facing);
            Status=started?"CA_MACHINE_WORKING":"CA_MACHINE_BUILD_BLOCKED";
            if(started){Open=false;user.SetCraftingJournalState(true);}
            return;
        }
        if(!CaelumMachineWork.Reach(user,Contact)){Status="CA_MACHINE_NEAR";return;}
        let work=CaelumMachineWork.Find(user);
        bool same=work!=null && (work.Machine==Target || work.Structure==Target);
        if(choice==6){if(same)CaelumMachineWork.Resume(user);Status=same && !work.Paused?"CA_MACHINE_WORKING":"CA_MACHINE_BLOCKED";return;}
        if(choice==7){if(same && CaelumMachineWork.Active(user))user.CancelCraftingTask();Status=same?"CA_MACHINE_CANCELLED":"CA_MACHINE_BLOCKED";return;}
        if(choice>=1 && choice<=3)
        {
            Status=CaelumMachineWork.Begin(user,Target,Contact,choice,Faction)?"CA_MACHINE_WORKING":"CA_MACHINE_BLOCKED";
            return;
        }
        let machine=CaelumHostileMachine(Target);
        if(choice==4 && machine!=null)
        {
            if(!CaelumMachineOwnership.Assign(machine,user)){Status="CA_MACHINE_OPERATOR_DENIED";return;}
            let bond=CaelumMachineOperator.Find(user);bond.Contact=Contact;bond.Controlling=true;bond.AttackHeld=true;
            Open=false;CaelumNotifications.Notify(user,StringTable.Localize("CA_MACHINE_CONTROLS",false));return;
        }
        if(choice==5 && machine!=null)
        {
            if(CaelumMilitaryCommand.Access(user)!="" || machine.OwnerFaction!=CaelumMilitaryData.GUARD_FACTION)
            {Status="CA_MACHINE_CREW_DENIED";return;}
            let port=CaelumPortSiege.Get();int assigned=0;
            if(port!=null)for(int i=0;i<port.Defenders.Size();i++)
            {
                let body=port.Defenders[i];
                let bond=CaelumMachineOperator.Find(body);
                if(!CaelumFormation.Capable(body) || body.Gun!=null || (bond!=null && bond.Machine!=null)
                    || body.Distance3D(machine)>machine.GuardRadius)continue;
                if(CaelumMachineOwnership.Assign(machine,body))assigned++;
            }
            Status=assigned>0?"CA_MACHINE_CREW_ASSIGNED":"CA_MACHINE_CREW_NONE";
        }
    }
    override void Tick()
    {
        Super.Tick();let user=CaelumPlayer(Owner);
        if(Open && (user==null || user.health<=0 || OriginMap!=level.MapName))Open=false;
    }
    Default { Inventory.MaxAmount 1; +INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE }
}
