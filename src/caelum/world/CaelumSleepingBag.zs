// La bolsa sigue siendo el mismo Inventory mientras su modelo se despliega.
// Recogerla al levantarse retira sólo ese modelo: nunca entrega otra copia.
class CaelumSleepingBag : CaelumSpecialInventoryItem
{
    override int GetSpecialCategory() { return CaelumConstants.EQUIPMENT_KIND_KEY_ITEM; }
    override int GetSpecialType() { return CaelumConstants.KEY_ITEM_SLEEPING_BAG; }
    // Peso de dos kilogramos confirmado por el autor.
    override double GetUnitWeight() { return 2.0; }

    bool AvailableTo(CaelumPlayer user)
    { return user != null && Owner == user && Amount == 1 && !InMagicBox; }

    bool Open(CaelumPlayer user)
    {
        if (!AvailableTo(user)) return false;
        return CaelumRestTrial.Open(user, null, self);
    }

    bool BeginRest(CaelumPlayer user, int minutes)
    {
        if (!AvailableTo(user) || CaelumRestState.IsActive(user)) return false;
        String reason = CaelumRestState.BlockReason(user);
        if (reason.Length() != 0)
        { CaelumNotifications.Notify(user,StringTable.Localize(reason, false)); return false; }
        if (!CaelumRestBag.HasRoom(user))
        { CaelumNotifications.Notify(user,StringTable.Localize("CA_SLEEPING_BAG_SPACE", false)); return false; }
        let mat = CaelumRestBag(Actor.Spawn("CaelumRestBag", user.Pos, NO_REPLACE));
        if (mat == null) return false;
        mat.Bag = self;
        mat.Angle = user.Angle;
        if (CaelumRestState.Begin(user, CaelumRestRules.MODE_SLEEP, minutes, mat)) return true;
        mat.Destroy();
        return false;
    }

    override Inventory CreateTossable(int tossAmount)
    {
        let user = CaelumPlayer(Owner);
        let rest = CaelumRestState.Get(user);
        if (rest != null && CaelumRestBag(rest.Furniture) != null
            && CaelumRestBag(rest.Furniture).Bag == self) CaelumRestState.Cancel(user);
        let copy = Super.CreateTossable(tossAmount);
        CaelumOnboarding.TransferUtilityIdentity(self, copy);
        return copy;
    }

    override Inventory CreateCopy(Actor other)
    {
        let copy = Super.CreateCopy(other);
        CaelumOnboarding.TransferUtilityIdentity(self, copy);
        return copy;
    }

    static void PrepareTrial(CaelumPlayer user)
    {
        if (!CaelumSewerTrialSupport.IsTrialMap() || user == null
            || CaelumRestState.IsActive(user)) return;
        String reason = CaelumRestState.BlockReason(user);
        if (reason.Length() != 0 && reason != "CA_REST_NEEDS") return;
        if (user.FindInventory("CaelumSleepingBag") != null)
        { CaelumNotifications.Notify(user,StringTable.Localize("CA_SLEEPING_BAG_OWNED", false)); return; }
        let bag = CaelumSleepingBag(Actor.Spawn("CaelumSleepingBag", user.Pos, NO_REPLACE));
        if (bag == null) return;
        Actor receiver = user;
        if (!bag.TryPickup(receiver))
        {
            bag.Destroy();
            CaelumNotifications.Notify(user,StringTable.Localize("CA_SLEEPING_BAG_CARRY", false));
        }
        user.PersistCharacterState();
    }

    Default
    {
        Tag "$CA_SLEEPING_BAG_NAME";
        Inventory.Icon "graphics/caelum/icons/ca_sleeping_bag.png";
        Inventory.PickupMessage "$CA_SLEEPING_BAG_PICKUP";
        Scale 1;
        Radius 12; Height 16;
    }
    States { Spawn: CSBG A -1; Stop; }
}

class CaelumSleepingBagProbe : Actor
{
    Default
    {
        Radius 46; Height 56;
        +SOLID +NOBLOCKMAP +NOGRAVITY +THRUACTORS +CANPASS
        RenderStyle "None";
    }
    States { Spawn: TNT1 A -1; Stop; }
}

class CaelumRestBag : CaelumRestFurniture
{
    CaelumSleepingBag Bag;
    int ContaminationRevision;
    void SyncContamination()
    {
        if(ContaminationRevision>=1 || Bag==null)return;
        double value=Max(CaelumContaminationStorage.Value(self),CaelumContaminationStorage.Value(Bag));
        CaelumContaminationStorage.Set(self,value);ContaminationRevision=1;
    }
    void RetainContamination()
    {
        if(Bag==null || Bag.bDestroyed)return;SyncContamination();
        CaelumContaminationStorage.Set(Bag,CaelumContaminationStorage.Value(self));
        CaelumContaminationStack.Clock(Bag).ResetBoundary();
    }
    override void OnDestroy(){RetainContamination();Super.OnDestroy();}
    // Cero conserva el comportamiento de los sacos de partidas anteriores.
    int TentEntryRevision,EntryCrouchToggle;
    CaelumDeployedTent Tent;
    vector3 TentEntry;
    String TentEntryMap;
    double EntryCrouch;
    override int RestMode() { return CaelumRestRules.MODE_SLEEP; }
    override int ComfortFactor() { return 3; }
    override vector3 PoseOffset() { return (0, 0, 2); }
    override vector3 PoseOffsetFor(CaelumPlayer user)
    { return (0,0,CaelumAppearanceRegistry.BagSurface()*Scale.Y/Max(.001,level.pixelstretch)); }
    override bool SupportsRest(CaelumPlayer user)
    { return Occupant == user && Bag != null && Bag.AvailableTo(user); }
    override bool Used(Actor activator) { return false; }

    static bool OverlapsBag(vector3 point,double facing,CaelumRestBag other)
    {
        if(other==null || Abs(point.Z-other.Pos.Z)>=CaelumAppearanceRegistry.BagHeight())return false;
        double l=CaelumAppearanceRegistry.BagHalfLength(),w=CaelumAppearanceRegistry.BagHalfWidth();
        // Ejes separadores de ambos rectángulos, sin volver a una circunferencia.
        for(int i=0;i<4;i++)
        {
            double a=(i<2?facing:other.Angle)+(i%2)*90;
            vector3 delta=point-other.Pos;
            double distance=Abs(delta.X*Cos(a)+delta.Y*Sin(a));
            double extent=l*(Abs(Cos(facing-a))+Abs(Cos(other.Angle-a)))
                +w*(Abs(Sin(facing-a))+Abs(Sin(other.Angle-a)));
            if(distance>=extent)return false;
        }
        return true;
    }

    static CaelumRestBag ReservedBag(CaelumPlayer user)
    {
        if(user==null)return null;
        let rest=CaelumRestState.Get(user);
        if(rest!=null && rest.Status==CaelumRestRules.STATUS_ACTIVE && rest.OriginMap==level.MapName)
            return CaelumRestBag(rest.Furniture);
        let cleaning=CaelumCleaningTask.Find(user);
        if(cleaning!=null && CaelumCleaningTask.KeepsBed(user,cleaning.Bed))return CaelumRestBag(cleaning.Bed);
        let skip=CaelumTimeSkipState.Get(user);
        if(skip!=null && skip.Active && skip.OriginMap==level.MapName)return CaelumRestBag(skip.Furniture);
        return null;
    }

    static bool HasRoom(CaelumPlayer user)
    {
        if(user==null)return false;
        double l=CaelumAppearanceRegistry.BagHalfLength(),w=CaelumAppearanceRegistry.BagHalfWidth();
        double h=CaelumAppearanceRegistry.BagHeight();
        // La cápsula real del personaje sigue siendo obligatoria. No se reduce
        // ni el cuerpo ni el saco para admitirlos bajo el techo de una carpa.
        let probe=Actor.Spawn('CaelumSleepingBagProbe',user.Pos,NO_REPLACE);
        if(probe==null)return false;
        probe.A_SetSize(user.Radius,Max(h,user.Height),false);
        bool fits=probe.TestMobjLocation() && Abs(probe.FloorZ-user.Pos.Z)<=1;
        if(!fits){probe.Destroy();return false;}
        // Celdas que cubren el rectángulo completo: cada círculo circunscribe
        // su celda. La pequeña sobrecobertura es conservadora en los bordes.
        int along=11,across=5;
        double dx=l/along,dy=w/across,radius=Sqrt(dx*dx+dy*dy);
        probe.A_SetSize(radius,h,false);
        for(int x=0;x<along && fits;x++)for(int y=0;y<across && fits;y++)
        {
            double a=-l+(x+0.5)*dx*2,b=-w+(y+0.5)*dy*2;
            probe.SetOrigin(user.Pos+(a*Cos(user.Angle)-b*Sin(user.Angle),
                a*Sin(user.Angle)+b*Cos(user.Angle),0),false);
            fits=probe.TestMobjLocation() && Abs(probe.FloorZ-user.Pos.Z)<=1;
        }
        probe.Destroy();if(!fits)return false;
        let it=BlockThingsIterator.Create(user,Sqrt(l*l+w*w));
        while(it.Next())
        {
            let other=it.thing;
            if(other==user || !other.bSolid || other.bNoBlockmap || other.Pos.Z+other.Height<=user.Pos.Z)continue;
            if(other.Pos.Z<user.Pos.Z+user.Height && user.Distance2D(other)<user.Radius+other.Radius)return false;
            if(other.Pos.Z>=user.Pos.Z+h)continue;
            vector3 delta=other.Pos-user.Pos;
            double a=delta.X*Cos(user.Angle)+delta.Y*Sin(user.Angle);
            double b=-delta.X*Sin(user.Angle)+delta.Y*Cos(user.Angle);
            double da=Max(0,Abs(a)-l),db=Max(0,Abs(b)-w);
            if(da*da+db*db<other.Radius*other.Radius)return false;
        }
        // Los modelos desplegados no están en el blockmap. Sus dueños sí
        // están en la tabla acotada de jugadores, incluso durante la limpieza.
        for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i] && players[i].mo!=user
            && OverlapsBag(user.Pos,user.Angle,ReservedBag(CaelumPlayer(players[i].mo))))return false;
        return true;
    }

    override void Release(CaelumPlayer user, vector3 entry)
    {
        if (Occupant != user) return;
        RetainContamination();CaelumTentRest.Leave(self,user);
        Occupant = null;
        Destroy();
    }

    override void Tick()
    {
        SyncContamination();Super.Tick();
        // Incluye restos de un hub previo: la referencia de sesión manda.
        if (Occupant == null && !CaelumCleaningTask.KeepsBed(Bag==null?null:CaelumPlayer(Bag.Owner),self))
        {CaelumTentRest.Leave(self,Bag==null?null:CaelumPlayer(Bag.Owner));Destroy();}
    }

    Default { Radius 46; Height 8; -SOLID +NOBLOCKMAP Tag "$CA_SLEEPING_BAG_NAME"; }
    States { Spawn: CSBO A -1; Stop; }
}
