// Contratos guardables: no crean deuda ni vuelven a cobrar por sincronizar.
class CaelumPropertyRecord : Object play
{
    int House;
    CaelumLawfulIdentity Holder;
    bool Purchased;
    double PaidUntil;
    int RentPayments;
    int CooperativeRevision;
    Array<CaelumLawfulIdentity> CoHolders;
    CaelumCooperativeObjective Restitution;
    CaelumLawfulIdentity RefundHolder;
    int RefundCopper;
    bool RefundPaid;
    clearscope bool Current(double now){return Holder!=null && (Purchased || (now>=0 && now<PaidUntil));}
}

class CaelumPropertyRules : Object play
{
    static CaelumPropertyRecord Find(int house,bool create=false)
    {
        let roster=CaelumHouseResidents.Get(create);if(roster==null)return null;
        for(int i=0;i<roster.Properties.Size();i++)if(roster.Properties[i].House==house)return roster.Properties[i];
        if(!create || !CaelumPropertyData.Offered(house))return null;
        let record=new("CaelumPropertyRecord");record.House=house;record.CooperativeRevision=1;
        roster.Properties.Push(record);return record;
    }
    static bool Holds(CaelumPlayer user,CaelumPropertyRecord record)
    {
        if(record==null)return false;
        let title=CaelumLockRules.Character(user);
        if(CaelumLockRules.SameTitle(record.Holder,title))return true;
        for(int i=0;i<record.CoHolders.Size();i++)
            if(CaelumLockRules.SameTitle(record.CoHolders[i],title))return true;
        return false;
    }
    static bool ResidenceAllowed(CaelumPlayer user)
    {
        int house=CaelumHouseHubData.HouseForMap(level.MapName);
        if(!CaelumPropertyData.Offered(house))return true;
        let record=Find(house);return Holds(user,record) && record.Current(CaelumScheduleState.Now(user));
    }
    static bool Acquire(CaelumPlayer user,int house,bool purchase)
    {
        if(!CaelumPlayerAuthority.CanMutate(user) || !CaelumScheduleState.CanTransact(user,true)
            || !CaelumPropertyData.Offered(house))return false;
        double now=CaelumScheduleState.Now(user);if(now<0)return false;
        let record=Find(house,true);if(record==null || record.Purchased)return false;
        // Sin una regla de reasignacion aprobada, un vencimiento no despoja
        // al titular ni entrega sus bienes a otro personaje.
        if(record.Holder!=null && !Holds(user,record))return false;
        int amount=purchase?CaelumPropertyData.PURCHASE_COPPER:CaelumPropertyData.RENT_COPPER;
        if(!Pay(user,amount))return false;
        record.Holder=CaelumLockRules.Character(user,true);
        if(purchase)record.Purchased=true;
        else
        {
            record.PaidUntil=Max(now,record.PaidUntil)+double(CaelumPropertyData.RENT_DAYS)*CaelumWorldClock.TicsPerDay();
            record.RentPayments++;
        }
        return true;
    }
    static bool Pay(CaelumPlayer user,int copper)
    {
        if(copper<=0 || !user.BuildPalomoCurrencyPaymentPlan(copper))return false;
        if(!user.PalomoTransactionCapacityFits(user.GetPalomoCurrencyPlanPersonalWeightDelta(),
            user.GetPalomoCurrencyPlanBoxRawWeightDelta(),user.GetPalomoCurrencyPlanBoxSlotDelta()))return false;
        Array<CaelumCurrencyItem> created;
        for(int currency=0;currency<CaelumConstants.CURRENCY_TYPE_COUNT;currency++)
        {
            CaelumCurrencyItem item=null;
            if(user.PalomoCurrencyPlanAmount[currency]>0 && user.FindNativeCurrency(currency)==null)
                item=CaelumCurrencyItem(Actor.Spawn(CaelumEconomyRules.GetCurrencyClassName(currency),user.Pos,NO_REPLACE));
            created.Push(item);
            if(user.PalomoCurrencyPlanAmount[currency]>0 && user.FindNativeCurrency(currency)==null && item==null)
            {for(int i=0;i<created.Size();i++)if(created[i]!=null)created[i].Destroy();return false;}
        }
        for(int currency=0;currency<CaelumConstants.CURRENCY_TYPE_COUNT;currency++)
        {
            let item=user.FindNativeCurrency(currency);int before=item==null?0:item.Amount;
            if(created[currency]!=null){item=created[currency];item.AttachToOwner(user);}
            if(item==null)continue;
            item.Amount=user.PalomoCurrencyPlanAmount[currency];item.InMagicBox=user.PalomoCurrencyPlanInMagicBox[currency];
            if(item.Amount>before)CaelumNotifications.Acquired(user,item,item.Amount-before);
            if(item.Amount<=0)item.Destroy();
        }
        user.OnNativeInventoryChanged();return true;
    }
}

// La sesion valida nuevamente alcance y contexto al ejecutar cada accion.
class CaelumPropertySession : Inventory
{
    CaelumHousePortal Portal;
    String OriginMap,Status,Expiry;
    double Money;
    bool Owned,Current,PaidThisVisit;
    static CaelumPropertySession Get(CaelumPlayer user,bool create=false)
    {
        if(!CaelumPlayerAuthority.CanMutate(user))return null;
        let session=CaelumPropertySession(user.FindInventory("CaelumPropertySession"));
        if(session==null && create)session=CaelumPropertySession(user.GiveInventoryType("CaelumPropertySession"));
        return session;
    }
    static bool Open(CaelumPlayer user,CaelumHousePortal portal)
    {
        if(user==null || portal==null || !CaelumPropertyData.Offered(portal.args[0])
            || !CaelumUseGeometry.AimedAt(user,portal))return false;
        let session=Get(user,true);if(session==null)return false;
        session.Portal=portal;session.OriginMap=level.MapName;session.Status="";session.PaidThisVisit=false;session.Refresh();return true;
    }
    bool Valid()
    {
        let user=CaelumPlayer(Owner);
        return user!=null && user.health>0 && user.CharacterCreationComplete && Portal!=null
            && OriginMap==level.MapName && user.Distance3D(Portal)<=user.UseRange+Portal.Radius
            && user.CheckSight(Portal,SF_IGNOREVISIBILITY);
    }
    void Refresh()
    {
        let user=CaelumPlayer(Owner);if(user==null || Portal==null)return;
        let record=CaelumPropertyRules.Find(Portal.args[0]);Owned=record!=null && record.Purchased;
        Current=CaelumPropertyRules.Holds(user,record) && record.Current(CaelumScheduleState.Now(user));
        Expiry=record!=null && !record.Purchased && record.Holder!=null?CaelumScheduleRules.DateText(record.PaidUntil):"-";
        Money=user.GetOwnedMoneyCopperValue();
    }
    void Act(int choice)
    {
        if(!Valid()){Portal=null;return;}
        let user=CaelumPlayer(Owner);
        if(choice==0){Portal=null;return;}
        if(choice==1)
        {
            let audio=CaelumMenuAudio(StaticEventHandler.Find("CaelumMenuAudio"));
            if(audio!=null && audio.RequestHouseDoor(user,Portal))Portal=null;
            return;
        }
        if((choice!=2 && choice!=3) || PaidThisVisit)return;
        // La visita previa carga la casa original y permite migrar sus bienes
        // reales antes de ofrecerla; nunca se copia un snapshot del hub.
        if(Portal.args[1]==0){Status="CA_PROPERTY_INSPECT";return;}
        let roster=CaelumHouseResidents.Get();
        if(roster==null || !roster.PropertyChestScanned){Status="CA_PROPERTY_PREPARING";return;}
        PaidThisVisit=CaelumPropertyRules.Acquire(user,Portal.args[0],choice==2);
        Status=PaidThisVisit?"CA_PROPERTY_SUCCESS":"CA_PROPERTY_REJECTED";
        Refresh();
    }
    override void Tick(){Super.Tick();if(Portal!=null){if(!Valid())Portal=null;else Refresh();}}
    override void PreTravelled(){Portal=null;Super.PreTravelled();}
    Default { Inventory.MaxAmount 1; +INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE }
    States { Spawn: TNT1 A -1; Stop; }
}
