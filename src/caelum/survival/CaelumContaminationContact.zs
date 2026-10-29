// #502: un enlace por pareja que realmente chocó, sin censos por tic.
// Thinker conserva el enlace al guardar; las listas pertenecen a sus cuerpos.
class CaelumContaminationContacts : Object play
{
    Array<CaelumContaminationContact> Pairs;

    static CaelumContaminationContacts Get(Actor body,bool create=false)
    {
        let user=CaelumPlayer(body);
        if(user!=null)
        {
            if(user.ContaminationContacts==null && create)user.ContaminationContacts=new('CaelumContaminationContacts');
            return user.ContaminationContacts;
        }
        let npc=CaelumCombatActor(body);
        if(npc==null)
        {
            if(body==null)return null;
            let record=CaelumContaminationStorage.Get(body,create);if(record==null)return null;
            if(record.Contacts==null && create)record.Contacts=new('CaelumContaminationContacts');
            return record.Contacts;
        }
        if(npc.ContaminationContacts==null && create)npc.ContaminationContacts=new('CaelumContaminationContacts');
        return npc.ContaminationContacts;
    }
    static bool Eligible(Actor body)
    {
        if(body==null || body.bDestroyed || body.bNoClip || body.bMissile || body.Radius<=0 || body.Height<=0)return false;
        if(!body.bSolid && !CaelumContaminationStack.Eligible(Inventory(body)))return false;
        let user=CaelumPlayer(body);if(user!=null && !CaelumPlayerAuthority.CanMutate(user))return false;
        let item=Inventory(body);
        return item==null || (item.Owner==null && !CaelumContaminationStorage.IsShielded(item));
    }
    static bool Overlap(Actor a,Actor b)
    {
        if(a==null || b==null)return false;
        double reach=a.Radius+b.Radius;
        return Abs(a.Pos.X-b.Pos.X)<=reach+.001 && Abs(a.Pos.Y-b.Pos.Y)<=reach+.001
            && a.Pos.Z<=b.Pos.Z+b.Height+.001 && b.Pos.Z<=a.Pos.Z+a.Height+.001;
    }
    static void PickupContact(Inventory item,Actor toucher)
    {
        // Las transferencias remotas (cofres/comercio) no son contacto corporal.
        if(item!=null && item.Owner==null && Overlap(item,toucher))Collision(toucher,item);
    }
    static void Observe(Inventory item)
    {
        if(item==null || item.Owner!=null || !Eligible(item))return;
        // Consulta local escalonada una vez por segundo activo por pila en suelo.
        // Las parejas reales contin?an por eventos/enlaces; no hay censo global.
        let nearby=BlockThingsIterator.Create(item,item.Radius);
        while(nearby.Next())
        {
            let other=nearby.thing;
            if(other==item || !Eligible(other) || !Overlap(item,other) || !item.CheckSight(other))continue;
            Collision(other,item);
        }
    }
    static void Collision(Actor body,Actor other)
    {
        if(body==other || !Eligible(body) || !Eligible(other))return;
        let user=CaelumPlayer(body);if(user!=null && !CaelumPlayerAuthority.CanMutate(user))return;
        let links=Get(body,true);if(links==null)return;
        for(int i=0;i<links.Pairs.Size();i++)
        {
            let pair=links.Pairs[i];if(pair==null)continue;
            if(CaelumDiningContamination.Owner(pair.First)==CaelumDiningContamination.Owner(other))
            {pair.First=other;pair.LastCollisionTic=level.maptime;return;}
            if(CaelumDiningContamination.Owner(pair.Second)==CaelumDiningContamination.Owner(other))
            {pair.Second=other;pair.LastCollisionTic=level.maptime;return;}
        }
        let pair=new('CaelumContaminationContact');pair.First=body;pair.Second=other;
        pair.LastCollisionTic=level.maptime;pair.Revision=1;pair.Rebase();
        links.Pairs.Push(pair);let opposite=Get(other,true);
        if(opposite!=null)opposite.Pairs.Push(pair);
        // También un roce breve recibe su tic nativo aunque no quede apoyo.
        // Los callbacks activo/pasivo siguientes encuentran el mismo enlace.
        pair.Exchange(CaelumThermalRuntime.WorldTicSeconds());
    }
    static void Remove(Actor body,CaelumContaminationContact pair)
    {
        let links=Get(body);if(links==null)return;
        for(int i=links.Pairs.Size()-1;i>=0;i--)if(links.Pairs[i]==pair || links.Pairs[i]==null)links.Pairs.Delete(i);
    }
    static void Detach(Actor body)
    {
        let links=Get(body);if(links==null)return;
        while(links.Pairs.Size()>0)
        {
            let pair=links.Pairs[links.Pairs.Size()-1];links.Pairs.Delete(links.Pairs.Size()-1);
            if(pair==null)continue;
            Remove(pair.First,pair);Remove(pair.Second,pair);pair.Destroy();
        }
    }
    static bool Active(Actor body)
    {
        let links=Get(body);if(links==null)return false;
        for(int i=0;i<links.Pairs.Size();i++)if(links.Pairs[i]!=null && links.Pairs[i].Touching())return true;
        return false;
    }
}

class CaelumContaminationContact : Thinker
{
    int Revision,LastCollisionTic;
    Actor First,Second;
    transient bool ClockReady;
    transient double LastStamp;
    transient CaelumContaminationContactPoint FirstPoint,SecondPoint;

    bool Duplicate()
    {
        let links=CaelumContaminationContacts.Get(First);
        if(links==null)links=CaelumContaminationContacts.Get(Second);
        if(links==null)return false;
        let a=CaelumDiningContamination.Owner(First),b=CaelumDiningContamination.Owner(Second);
        for(int i=0;i<links.Pairs.Size();i++)
        {
            let prior=links.Pairs[i];if(prior==self)return false;
            if(prior==null)continue;
            let x=CaelumDiningContamination.Owner(prior.First),y=CaelumDiningContamination.Owner(prior.Second);
            if((a==x && b==y) || (a==y && b==x))return true;
        }
        return false;
    }

    bool Touching()
    {
        if(!CaelumContaminationContacts.Eligible(First) || !CaelumContaminationContacts.Eligible(Second))return false;
        // El motor colisiona las cajas horizontales, no círculos. El margen
        // sólo absorbe el redondeo usado por el soporte térmico existente.
        double reach=First.Radius+Second.Radius;
        bool boxes=Abs(First.Pos.X-Second.Pos.X)<=reach+0.001
            && Abs(First.Pos.Y-Second.Pos.Y)<=reach+0.001
            && First.Pos.Z<=Second.Pos.Z+Second.Height+0.001
            && Second.Pos.Z<=First.Pos.Z+First.Height+0.001;
        // Una colisión bloqueada puede detener el movimiento antes del borde.
        // Sólo acredita ese tic nativo; no mantiene contacto a distancia.
        return boxes || LastCollisionTic==level.maptime;
    }
    void Rebase()
    {
        let world=CaelumThermalWorld.Get();
        ClockReady=world!=null && world.ReferenceClock!=null;
        if(ClockReady)LastStamp=CaelumThermalRuntime.Stamp(world.ReferenceClock);
    }
    void Exchange(double seconds)
    {
        int a=CaelumConstants.ARMOR_SLOT_BODY,b=a;
        double area=CaelumContaminationData.BODY_CONTACT_M2;
        if(Abs(First.Pos.Z-(Second.Pos.Z+Second.Height))<=0.001)
        {a=CaelumConstants.ARMOR_SLOT_FEET;b=CaelumConstants.ARMOR_SLOT_HEAD;area=CaelumContaminationData.FOOT_CONTACT_M2;}
        else if(Abs(Second.Pos.Z-(First.Pos.Z+First.Height))<=0.001)
        {b=CaelumConstants.ARMOR_SLOT_FEET;a=CaelumConstants.ARMOR_SLOT_HEAD;area=CaelumContaminationData.FOOT_CONTACT_M2;}
        FirstPoint=CaelumContaminationCombat.Exterior(First,a,FirstPoint);
        SecondPoint=CaelumContaminationCombat.Exterior(Second,b,SecondPoint);
        CaelumContaminationCombat.Transfer(FirstPoint,SecondPoint,area,seconds);
    }
    override void Tick()
    {
        if((!ClockReady && Duplicate()) || !Touching())
        {
            CaelumContaminationContacts.Remove(First,self);CaelumContaminationContacts.Remove(Second,self);
            Destroy();return;
        }
        let world=CaelumThermalWorld.Get();
        if(world==null || world.ReferenceClock==null){ClockReady=false;return;}
        if(!ClockReady){Rebase();return;}
        double now=CaelumThermalRuntime.Stamp(world.ReferenceClock);
        double seconds=Max(0.0,now-LastStamp);LastStamp=now;
        if(seconds>0)Exchange(seconds);
    }
}
