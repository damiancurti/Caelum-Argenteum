class CaelumMilitarySession : Inventory
{
    bool Open,Ready;
    CaelumPortDefender Contact;
    CaelumMilitaryGroup Group;
    String SourceMap,Status,Denial;
    int Selection;
    Array<CaelumKnownPoi> Points;

    static CaelumMilitarySession Find(CaelumPlayer user)
    {return user==null?null:CaelumMilitarySession(user.FindInventory('CaelumMilitarySession'));}

    static bool Reach(CaelumPlayer user,CaelumPortDefender contact)
    {
        return CaelumPlayerAuthority.CanMutate(user) && user.health>0 && contact!=null && contact.health>0
            && CaelumFormation.Capable(contact) && user.Distance3D(contact)<=CaelumPortData.COMMAND_LINK_RADIUS
            && user.CheckSight(contact) && !CaelumTheftWitnesses.HasTarget(contact);
    }

    static bool Show(CaelumPlayer user,CaelumPortDefender contact)
    {
        if(!Reach(user,contact) || contact.Port==null || level.MapName!="MAP03")return false;
        let session=Find(user);
        if(session==null)session=CaelumMilitarySession(user.GiveInventoryType('CaelumMilitarySession'));
        if(session==null)return false;
        contact.Port.EnsureMilitary();
        user.EquipmentMenuOpen=false;user.ClosePalomoMerchant();user.CloseCraftingStationSession();
        session.Open=true;session.Contact=contact;session.Group=CaelumMilitaryGroup.Find(contact);
        session.SourceMap=level.MapName;session.Selection=0;session.Status="";
        session.Points.Clear();session.Points.Push(null);
        let record=user.GetPersistentCharacterState(false);
        if(record!=null)for(int i=0;i<record.KnownPois.Size();i++)
        {let point=record.KnownPois[i];if(point!=null && point.MapId==level.MapName)session.Points.Push(point);}
        session.Refresh();return true;
    }

    void Refresh()
    {
        let user=CaelumPlayer(Owner);Ready=false;
        if(!Open)return;
        if(SourceMap!=level.MapName || user==null || user.health<=0){Open=false;return;}
        Denial=CaelumMilitaryCommand.Access(user);
        if(Denial!="")return;
        if(Contact==null || Contact.Port==null || !Contact.Port.SiegeStarted){Denial="CA_MILITARY_WAIT";return;}
        if(Group==null || Group.Port!=Contact.Port){Denial="CA_MILITARY_UNAVAILABLE";return;}
        Group.Refresh();
        // La sucesión conserva el grupo y traslada el contacto al mando capaz.
        if(Group.Formation.Leader!=null)Contact=CaelumPortDefender(Group.Formation.Leader.Body);
        if(!Reach(user,Contact)){Denial="CA_MILITARY_RANGE";return;}
        if(CaelumMilitaryGroup.Find(Contact)!=Group){Denial="CA_MILITARY_UNAVAILABLE";return;}
        Ready=true;
    }

    void Act(int choice)
    {
        let user=CaelumPlayer(Owner);
        if(!Open || !CaelumPlayerAuthority.CanMutate(user))return;
        if(choice==0){Open=false;return;}
        Refresh();if(!Open)return;
        if(choice==6 || choice==7)
        {Selection=Clamp(Selection+(choice==6?-1:1),0,Max(0,Points.Size()-1));return;}
        if(!Ready || choice<1 || choice>5)return;
        if(choice==5)
        {
            let roster=CaelumHouseResidents.Get();let port=Group.Port;
            if(roster==null || !roster.DeploymentPending){Status="CA_MILITARY_NO_RESERVES";return;}
            if(!CaelumCityWorld.SiegeDue() || port.LivingDefendingPopulation()>=CaelumFormationData.SIDE_CAPACITY)
            {Status="CA_MILITARY_RESERVE_WAIT";return;}
            roster.DeploymentOpportunity(port,CaelumBattleDirector.CivilNow(port));
            Status="CA_MILITARY_RESERVE_REQUEST";return;
        }
        vector3 point=Contact.Pos;
        if(choice==CaelumMilitaryData.ADVANCE)
        {
            point=user.Pos;
            if(Selection>0 && Selection<Points.Size())
            {
                let fact=Points[Selection];let record=user.GetPersistentCharacterState(false);
                if(fact==null || fact.MapId!=level.MapName
                    || CaelumPoiKnowledge.Find(record,fact.MapId,fact.PoiId)!=fact){Status="CA_MILITARY_UNKNOWN";return;}
                point=fact.ObservedPosition;
            }
        }
        Group.SetOrder(choice,point);Status="CA_MILITARY_SENT";
    }

    override void Tick()
    {Super.Tick();if(Open)Refresh();}
    Default { Inventory.MaxAmount 1; +INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE }
}
