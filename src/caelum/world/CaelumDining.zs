// Cada plato representa una unidad real. Los recipientes conservan su clase
// y litros en el mismo Inventory, guardado como pertenencia de la mesa.
class CaelumDiningDisplay : Actor
{
    CaelumDiningTable Table;
    CaelumConsumableItem Item;
    override void Tick()
    {
        Super.Tick();
        if(Table==null || Item==null || Item.Owner!=Table) {Destroy();return;}
        // Corrige también presentaciones ya guardadas: modelo y altura del
        // actor deben compartir la compensación vertical de MODELDEF.
        double surface=Table.Pos.Z+Table.SurfaceHeight();
        if(Abs(Pos.Z-surface)>0.001)SetOrigin((Pos.X,Pos.Y,surface),false);
    }
    Default { Radius 0; Height 0; +NOBLOCKMAP +NOGRAVITY +NOTARGET }
    States { Spawn: CAHC A -1; Stop; }
}

// Los platos son presentación; la ración real sigue perteneciendo a la mesa.
class CaelumDiningFoodPlate : CaelumDiningDisplay {}
class CaelumDiningWaterCup : CaelumDiningDisplay {}

class CaelumDiningBlock : Actor
{
    CaelumDiningTable Table;
    override bool Used(Actor activator)
    { return Table!=null && CaelumUseGeometry.AimedAt(CaelumPlayer(activator), self)
        && Table.OpenForUser(CaelumPlayer(activator)); }
    override void Tick() { Super.Tick(); if(Table==null)Destroy(); }
    Default { Radius 24; Height 34; +SOLID +NOGRAVITY +CANNOTPUSH +DONTTHRUST +INVULNERABLE +CANPASS RenderStyle "None"; }
    States { Spawn: TNT1 A -1; Stop; }
}

class CaelumDiningTable : Actor
{
    CaelumConsumableItem Items[60];
    CaelumDiningDisplay Displays[60];
    CaelumRestChair Chairs[12];
    CaelumDiningBlock Blocks[32];
    int LayoutSlot;
    bool PresentationReady;
    bool MansionFullFoodPrepared;
    int MansionFoodToSeed;
    virtual clearscope int SeatCount() { return 6; }
    virtual clearscope int Capacity() { return 18; }
    virtual clearscope double LengthMU() { return 192; }
    virtual clearscope double WidthMU() { return 96; }
    virtual clearscope bool RoundTop() { return false; }

    vector3 LocalPoint(double x,double y,double z=0)
    {return Pos+(Cos(Angle)*x-Sin(Angle)*y,Sin(Angle)*x+Cos(Angle)*y,z);}

    double SurfaceHeight()
    {return 34.1*Scale.Y/Max(0.001,level.pixelstretch);}

    bool LayoutOccupied()
    {
        for(int i=0;i<SeatCount();i++)if(Chairs[i]!=null && Chairs[i].Occupant!=null)return true;
        return false;
    }

    void MoveLayout(vector3 destination,double facing)
    {
        vector3 origin=Pos;
        double rotation=facing-Angle;
        SetOrigin(destination,false);Angle=facing;
        for(int i=0;i<32;i++)if(Blocks[i]!=null)
        {
            vector3 d=Blocks[i].Pos-origin;
            Blocks[i].SetOrigin(destination+(d.X*Cos(rotation)-d.Y*Sin(rotation),d.X*Sin(rotation)+d.Y*Cos(rotation),d.Z),false);
        }
        for(int i=0;i<SeatCount();i++)if(Chairs[i]!=null)
        {
            vector3 d=Chairs[i].Pos-origin;
            Chairs[i].SetOrigin(destination+(d.X*Cos(rotation)-d.Y*Sin(rotation),d.X*Sin(rotation)+d.Y*Cos(rotation),d.Z),false);
            Chairs[i].Angle+=rotation;
        }
        RefreshDisplays();
    }

    bool LayoutFits()
    {
        if(!TestMobjLocation() || Abs(FloorZ-Pos.Z)>1)return false;
        for(int i=0;i<32;i++)if(Blocks[i]!=null)
            if(!Blocks[i].TestMobjLocation() || Abs(Blocks[i].FloorZ-Pos.Z)>1)return false;
        for(int i=0;i<SeatCount();i++)
            if(Chairs[i]==null || !Chairs[i].TestMobjLocation() || Abs(Chairs[i].FloorZ-Pos.Z)>1)return false;
        return true;
    }

    double EdgeDistance(Actor user)
    {
        vector3 d=user.Pos-Pos;
        double x=d.X*Cos(Angle)+d.Y*Sin(Angle);
        double y=-d.X*Sin(Angle)+d.Y*Cos(Angle);
        if(RoundTop())return Max(0,user.Distance2D(self)-WidthMU()/2);
        x=Max(0,Abs(x)-LengthMU()/2);y=Max(0,Abs(y)-WidthMU()/2);
        return Sqrt(x*x+y*y);
    }

    bool CanReach(CaelumPlayer user)
    {
        return user!=null && user.player!=null && user.health>0 && user.CharacterCreationComplete
            && !user.CreationWizardOpen && Abs(user.Pos.Z-Pos.Z)<=8
            && EdgeDistance(user)<=user.UseRange && user.CheckSight(self,SF_IGNOREVISIBILITY);
    }

    bool CanDine(CaelumPlayer user)
    {
        let rest=CaelumRestState.Get(user);
        return CanReach(user) && rest!=null && rest.Status==CaelumRestRules.STATUS_ACTIVE
            && rest.Mode==CaelumRestRules.MODE_WAIT && CaelumRestChair(rest.Furniture)!=null
            && rest.Furniture.SupportsRest(user) && EdgeDistance(rest.Furniture)<=72;
    }

    static CaelumDiningTable Nearby(CaelumPlayer user)
    {
        let it=ThinkerIterator.Create("CaelumDiningTable");CaelumDiningTable table;CaelumDiningTable nearest;
        double best=1e9;
        while((table=CaelumDiningTable(it.Next()))!=null)
            if(table.CanDine(user) && table.EdgeDistance(user)<best)
            {nearest=table;best=table.EdgeDistance(user);}
        return nearest;
    }

    int FreeSlot()
    {for(int i=0;i<Capacity();i++)if(Items[i]==null)return i;return -1;}

    // El conjunto será reutilizable por Trucazo. No activa una partida.
    bool HasSeatLayout(int required)
    {
        int available=0;
        for(int i=0;i<SeatCount();i++)
            if(Chairs[i]!=null && Chairs[i].DiningTable==self
                && Abs(Chairs[i].Pos.Z-Pos.Z)<=1 && EdgeDistance(Chairs[i])<=72)available++;
        return required>0 && available>=required;
    }

    void RefreshDisplays()
    {
        for(int i=0;i<Capacity();i++)
        {
            if(Items[i]==null || Items[i].Owner!=self || Items[i].Amount<=0)
            {
                Items[i]=null;
                if(Displays[i]!=null)Displays[i].Destroy();
                Displays[i]=null;continue;
            }
            class<CaelumDiningDisplay> kind=IsDrink(Items[i])?"CaelumDiningWaterCup":"CaelumDiningFoodPlate";
            if(Displays[i]!=null && Displays[i].GetClass()!=kind) {Displays[i].Destroy();Displays[i]=null;}
            if(Displays[i]==null)Displays[i]=CaelumDiningDisplay(Spawn(kind,Pos,NO_REPLACE));
            let visual=Displays[i];if(visual==null)continue;
            visual.Table=self;visual.Item=Items[i];visual.Angle=Angle;
            int columns=RoundTop()?2:SeatCount()==12?10:6;
            int rows=Capacity()/columns;
            double x=(i%columns-(columns-1)*0.5)*(LengthMU()-40)/Max(1,columns-1);
            double y=(i/columns-(rows-1)*0.5)*(WidthMU()-40)/Max(1,rows-1);
            if(RoundTop()){x=(i%2==0?-14:14);y=(i<2?-14:14);}
            visual.SetOrigin(LocalPoint(x,y,SurfaceHeight()),false);

        }
    }

    static bool IsDrink(CaelumConsumableItem item)
    {return item!=null && (CaelumWaterContainer(item)!=null || item.GetConsumableType()==CaelumConstants.CONSUMABLE_WATER_RATION);}

    bool PlaceItem(CaelumPlayer user,bool drink)
    {
        if(!CanReach(user) || CaelumRestState.IsActive(user))return false;
        int slot=FreeSlot();if(slot<0)return false;
        CaelumConsumableItem selected;
        for(Inventory cursor=user.Inv;cursor!=null;cursor=cursor.Inv)
        {
            let item=CaelumConsumableItem(cursor);
            if(item==null || item.InMagicBox || item.Amount<=0)continue;
            bool match=drink?IsDrink(item):item.GetConsumableType()==CaelumConstants.CONSUMABLE_FOOD_RATION;
            if(match) {selected=item;break;}
        }
        if(selected==null)return false;
        let placed=CaelumConsumableItem(selected.CreateTossable(1));
        if(placed==null)return false;
        placed.AttachToOwner(self);placed.InMagicBox=false;Items[slot]=placed;
        RefreshDisplays();user.OnNativeInventoryChanged();user.PersistCharacterState();return true;
    }

    bool Withdraw(CaelumPlayer user,bool drink)
    {
        if(!CanReach(user) || CaelumRestState.IsActive(user))return false;
        for(int i=0;i<Capacity();i++)
        {
            let item=Items[i];if(item==null || IsDrink(item)!=drink)continue;
            // TryPickup revalida carga y duplicación de recipientes.
            item.BecomePickup();item.bSpecial=false;
            Actor toucher=user;
            if(!item.CallTryPickup(toucher)) {item.AttachToOwner(self);return false;}
            Items[i]=null;RefreshDisplays();user.OnNativeInventoryChanged();user.PersistCharacterState();return true;
        }
        return false;
    }

    bool Consume(CaelumPlayer user,bool drink)
    {
        if(!CanDine(user) || user.ForcedSleepTics>0)return false;
        Name powerName=drink?'CaelumThirstRegeneration':'CaelumHungerRegeneration';
        // Evita desperdiciar un plato refrescando el mismo efecto aún activo.
        if(user.FindInventory(powerName)!=null || (drink?user.CurrentThirst:user.CurrentHunger)>=100)return false;
        for(int i=0;i<Capacity();i++)
        {
            let item=Items[i];if(item==null || item.Owner!=self || IsDrink(item)!=drink)continue;
            let bottle=CaelumWaterContainer(item);
            if(bottle!=null && bottle.WaterLiters<=0.000001)continue;
            // Préstamo transaccional para reutilizar exactamente el consumo nativo.
            // No hay tic de simulación ni consulta de carga entre ambos pasos.
            RemoveInventory(item);item.AttachToOwner(user);
            bool accepted=bottle!=null?bottle.Drink():item.Use(false);
            user.RemoveInventory(item);
            if(accepted && bottle==null) {Items[i]=null;item.Destroy();}
            else item.AttachToOwner(self);
            RefreshDisplays();user.OnNativeInventoryChanged();user.PersistCharacterState();return accepted;
        }
        return ConsumeReserve(user,drink);
    }

    bool ConsumeReserve(CaelumPlayer user,bool drink)
    {
        if(!CanDine(user) || user.ForcedSleepTics>0)return false;
        Name powerName=drink?'CaelumThirstRegeneration':'CaelumHungerRegeneration';
        if(user.FindInventory(powerName)!=null || (drink?user.CurrentThirst:user.CurrentHunger)>=100)return false;
        // Primero lo llevado a mano; después la reserva propia de la Caja.
        // Sólo se descuenta una unidad aceptada. El resto conserva su ubicación.
        for(int source=0;source<2;source++)
        {
            if(source==1 && !user.MagicBoxOwned)break;
            for(Inventory cursor=user.Inv;cursor!=null;cursor=cursor.Inv)
            {
                let item=CaelumConsumableItem(cursor);
                if(item==null || item.Owner!=user || item.Amount<=0 || item.InMagicBox!=(source==1))continue;
                if(drink?!IsDrink(item):item.GetConsumableType()!=CaelumConstants.CONSUMABLE_FOOD_RATION)continue;
                let bottle=CaelumWaterContainer(item);
                if(bottle!=null && bottle.WaterLiters<=0.000001)continue;
                bool stored=item.InMagicBox;
                item.InMagicBox=false;
                bool accepted=bottle!=null?bottle.Drink():item.Use(false);
                item.InMagicBox=stored;
                if(!accepted)continue;
                if(bottle==null){item.Amount--;if(item.Amount==0)item.Destroy();}
                user.OnNativeInventoryChanged();user.PersistCharacterState();return true;
            }
        }
        return false;
    }

    void Report(CaelumPlayer user)
    {
        int food=0;int water=0;int bottles=0;double liters=0;
        for(int i=0;i<Capacity();i++)
        {
            let item=Items[i];if(item==null)continue;
            let bottle=CaelumWaterContainer(item);
            if(bottle!=null){bottles++;liters+=bottle.WaterLiters;}
            else if(IsDrink(item))water++;else food++;
        }
        CaelumNotifications.Notify(user,String.Format(StringTable.Localize("CA_TABLE_CONTENTS",false),SeatCount(),food+water+bottles,Capacity(),food,water,bottles,liters));
    }

    override bool Used(Actor activator)
    {
        let user=CaelumPlayer(activator);
        return CaelumUseGeometry.AimedAt(user, self) && OpenForUser(user);
    }

    bool OpenForUser(CaelumPlayer user)
    {
        if(!CanReach(user) || (user.player.cmd.buttons & BT_USE)==0 || CaelumRestState.IsActive(user) || user.HasActiveConversation()
            || user.CraftingMenuOpen || user.PalomoMerchantMenuOpen)return false;
        let guide=CaelumDiningGuide(Spawn("CaelumDiningGuide",user.Pos+(0,0,user.Height*0.5),NO_REPLACE));
        if(guide==null)return false;guide.Table=self;guide.Subject=user;
        if(CaelumFactionCondition.OpenDialogue(user,guide,43514,null,SF_IGNOREVISIBILITY))return true;
        guide.Destroy();return false;
    }

    void SeedMansionFood()
    {
        if(level.MapName!="MAP01")return;
        if(!MansionFullFoodPrepared)
        {
            // Completar toda la capacidad, contando primero la comida ya presente.
            // Se guarda el saldo inicial: consumir nunca vuelve a aumentarlo.
            int food=0;
            for(int i=0;i<Capacity();i++)
                if(Items[i]!=null && Items[i].Owner==self && Items[i].Amount>0
                    && Items[i].GetConsumableType()==CaelumConstants.CONSUMABLE_FOOD_RATION)
                    food+=Items[i].Amount;
            MansionFoodToSeed=Max(0,Capacity()-food);
            MansionFullFoodPrepared=true;
        }
        bool changed=false;
        while(MansionFoodToSeed>0)
        {
            int slot=FreeSlot();
            // Una mesa llena conserva las pertenencias del guardado y no queda
            // esperando huecos para reponer comida después de cada retirada.
            if(slot<0){MansionFoodToSeed=0;break;}
            let ration=CaelumConsumableItem(Spawn("CaelumFoodRation",Pos,NO_REPLACE));
            if(ration==null)break;
            ration.Amount=1; ration.InMagicBox=false;
            ration.AttachToOwner(self); Items[slot]=ration;
            MansionFoodToSeed--; changed=true;
        }
        if(changed)RefreshDisplays();
    }

    override void Tick()
    {
        Super.Tick();
        // Reconstruye también las presentaciones guardadas con 0g.
        if(!PresentationReady){bCanPass=true;RefreshDisplays();PresentationReady=true;}
        SeedMansionFood();
    }

    override void OnDestroy()
    {
        for(int i=0;i<60;i++)
        {
            if(Displays[i]!=null)Displays[i].Destroy();
            if(Items[i]!=null) {Items[i].BecomePickup();Items[i].SetOrigin(Pos+(0,0,36),false);}
        }
        for(int i=0;i<32;i++)if(Blocks[i]!=null)Blocks[i].Destroy();
        for(int i=0;i<12;i++)if(Chairs[i]!=null)Chairs[i].DiningTable=null;
        Super.OnDestroy();
    }
    Default { Radius 1; Height 34; +CANPASS +NOGRAVITY +CANNOTPUSH +DONTTHRUST +INVULNERABLE Tag "$CA_TABLE_NORMAL"; }
    States { Spawn: CAHC A -1; Stop; }
}

class CaelumDiningTableSmall : CaelumDiningTable
{
    override int SeatCount(){return 2;} override int Capacity(){return 4;} override double LengthMU(){return 80;}
    override double WidthMU(){return 80;} override bool RoundTop(){return true;}
    Default { Radius 40; +SOLID Tag "$CA_TABLE_SMALL"; }
}
class CaelumDiningTableLarge : CaelumDiningTable
{
    override int SeatCount(){return 12;} override int Capacity(){return 60;} override double LengthMU(){return 384;}
    override double WidthMU(){return 192;} Default { Tag "$CA_TABLE_LARGE"; }
}

class CaelumDiningGuide : Actor
{
    CaelumDiningTable Table;CaelumPlayer Subject;int Choice;
    override void Tick()
    {
        Super.Tick();if(Table==null || Subject==null){Destroy();return;}
        if(bInConversation || Subject.HasActiveConversation())return;
        bool done=false;
        if(Choice==1 || Choice==2)done=Table.PlaceItem(Subject,Choice==2);
        if(Choice==3 || Choice==4)done=Table.Withdraw(Subject,Choice==4);
        if(Choice!=0){Table.Report(Subject);if(!done && Choice!=5)CaelumNotifications.Notify(Subject,StringTable.Localize("CA_TABLE_FAILED",false));}
        Destroy();
    }
    Default { Radius 1;Height 1;+NOBLOCKMAP +NOGRAVITY +INVULNERABLE +NOTARGET RenderStyle "None"; }
    States { Spawn:TNT1 A -1;Stop; }
}
class CaelumDiningAction : CaelumPalomoDialogueAction abstract
{
    virtual int Choice(){return 0;}
    override bool Use(bool pickup)
    {
        let user=CaelumPlayer(Owner);if(user==null || user.player==null)return false;
        let guide=CaelumDiningGuide(user.player.ConversationNPC);
        if(guide==null || guide.Subject!=user || !guide.bInConversation || guide.Choice!=0
            || guide.Table==null || !guide.Table.CanReach(user))return false;
        guide.Choice=Choice();return true;
    }
}
class CaelumDiningPlaceFood : CaelumDiningAction {override int Choice(){return 1;}}
class CaelumDiningPlaceDrink : CaelumDiningAction {override int Choice(){return 2;}}
class CaelumDiningTakeFood : CaelumDiningAction {override int Choice(){return 3;}}
class CaelumDiningTakeDrink : CaelumDiningAction {override int Choice(){return 4;}}
class CaelumDiningInspect : CaelumDiningAction {override int Choice(){return 5;}}

class CaelumDiningWorld : Object play
{
    static CaelumDiningTable Find(int slot)
    {
        let it=ThinkerIterator.Create("CaelumDiningTable");CaelumDiningTable table;
        while((table=CaelumDiningTable(it.Next()))!=null)if(table.LayoutSlot==slot)return table;
        return null;
    }
    static void Zone(vector3 position,int slot)
    {
        let it=ThinkerIterator.Create("CaelumTimeAdvanceZone");Actor zone;
        while((zone=Actor(it.Next()))!=null)if(zone.args[0]==slot)return;
        zone=Actor.Spawn("CaelumTimeAdvanceZone",position,NO_REPLACE);
        if(zone!=null){zone.args[0]=slot;if(slot>1)zone.A_SetSize(320,128,false);}
    }
    static bool EnsureSeats(CaelumDiningTable table)
    {
        bool fits=true;
        int side=table.SeatCount()==12?4:2;
        for(int i=0;i<table.SeatCount();i++)
        {
            if(table.Chairs[i]!=null)continue;
            double x=0;double y=0;
            if(table.RoundTop())x=i==0?-84:84;
            else if(i<side*2)
            { x=-table.LengthMU()/2+(i%side+0.5)*table.LengthMU()/side; y=(i<side?-1:1)*(table.WidthMU()/2+44); }
            else
            { int end=i-side*2; x=(end<(side/2)?-1:1)*(table.LengthMU()/2+44); y=side==4?(end%2==0?-48:48):0; }
            let chair=CaelumRestChair(Actor.Spawn("CaelumRestChair",table.LocalPoint(x,y),NO_REPLACE));
            if(chair==null){fits=false;continue;}
            table.Chairs[i]=chair;chair.DiningTable=table;chair.DiningSeat=i;
            // PoseAngle invierte el modelo: el cuerpo debe mirar al tablero.
            double facing=table.RoundTop()?(i==0?0:180):i<side*2?(i<side?90:270):(x<0?0:180);
            chair.Angle=table.Angle+facing+180;
            if(!chair.TestMobjLocation() || Abs(chair.FloorZ-table.Pos.Z)>1){chair.Destroy();fits=false;}
        }
        return fits;
    }
    static bool Place(int slot,vector3 position,int size=0,double facingAngle=0)
    {
        if(Find(slot)!=null)return true;
        class<CaelumDiningTable> kind="CaelumDiningTable";
        if(size==0)size=slot;
        if(size==1)kind="CaelumDiningTableSmall";
        if(size==3)kind="CaelumDiningTableLarge";
        let table=CaelumDiningTable(Actor.Spawn(kind,position,NO_REPLACE));if(table==null)return false;
        table.LayoutSlot=slot;table.Angle=facingAngle;
        bool fits=table.TestMobjLocation() && Abs(table.FloorZ-position.Z)<=1;
        int block=0;
        if(!table.RoundTop())
            for(double x=-table.LengthMU()/2+24;x<table.LengthMU()/2;x+=48)
                for(double y=-table.WidthMU()/2+24;y<table.WidthMU()/2;y+=48)
                {
                    let body=CaelumDiningBlock(Actor.Spawn("CaelumDiningBlock",table.LocalPoint(x,y),NO_REPLACE));
                    if(body==null){fits=false;continue;}
                    body.Table=table;table.Blocks[block++]=body;
                    if(!body.TestMobjLocation() || Abs(body.FloorZ-position.Z)>1)fits=false;
                }
        if(!EnsureSeats(table))fits=false;
        if(!fits)
        {
            for(int i=0;i<12;i++)if(table.Chairs[i]!=null)table.Chairs[i].Destroy();
            table.Destroy();return false;
        }
        if(level.MapName!="MAP01")Zone(position,slot+1);return true;
    }
    static bool Prepare()
    {
        // MAP03 queda reservado a la galería, incluso desde el diagnóstico.
        if(level.MapName=="MAP03")return true;
        if(level.MapName=="MAP06")return Place(601,(-800,800,0),1);
        if(level.MapName=="MAP07")return Place(701,(-256,1280,0),1);
        if(CaelumMazeLayout.IsCurrent())
        {
            // Habilita los espacios trasladados; enemigos y combate siguen
            // bloqueando el avance mediante las guardas compartidas.
            for(int i=0;i<CaelumMazeLayout.TIME_ADVANCE_ZONE_COUNT;i++)
                Zone(CaelumMazeLayout.TimeAdvanceZonePosition(i),i+1);
            return true;
        }
        if(!CaelumSewerTrialSupport.IsTrialMap())return true;
        Zone(level.MapName=="MAP02"?(-224,160,0):(0,320,0),1);
        if(level.MapName!="MAP03")return true;
        bool a=Place(1,(-600,1000,0));bool b=Place(2,(0,1550,0));bool c=Place(3,(700,2500,0));
        return a && b && c;
    }
}

// Repetición explícita por canal: F y G también permiten detener las próximas
// porciones. La porción ya aplicada termina sus pulsos nativos, sin reembolso.
class CaelumDiningSession : Object play
{
    static void Sated(CaelumPlayer user,bool drink)
    {
        let rest=CaelumRestState.Get(user);if(rest==null)return;
        if(drink)rest.AutoDrinking=false;else rest.AutoEating=false;
    }

    static bool Toggle(CaelumPlayer user,bool drink)
    {
        let rest=CaelumRestState.Get(user);
        if(rest==null || rest.Status!=CaelumRestRules.STATUS_ACTIVE)return false;
        if(drink?rest.AutoDrinking:rest.AutoEating)
        {Sated(user,drink);CaelumNotifications.Notify(user,StringTable.Localize("CA_TABLE_AUTO_STOP",false));return true;}
        let table=CaelumDiningTable.Nearby(user);
        if(table==null || (drink?user.CurrentThirst:user.CurrentHunger)>=100)return false;
        Name power=drink?'CaelumThirstRegeneration':'CaelumHungerRegeneration';
        if(user.FindInventory(power)==null && !table.Consume(user,drink))return false;
        rest.DiningTable=table;
        if(drink)rest.AutoDrinking=true;else rest.AutoEating=true;
        return true;
    }

    static void Advance(CaelumPlayer user)
    {
        let rest=CaelumRestState.Get(user);
        if(rest==null || (!rest.AutoEating && !rest.AutoDrinking))return;
        let table=rest.DiningTable;
        if(rest.Status!=CaelumRestRules.STATUS_ACTIVE || table==null || !table.CanDine(user)
            || user.ForcedSleepTics>0)
        {rest.AutoEating=false;rest.AutoDrinking=false;rest.DiningTable=null;return;}
        if(user.CurrentHunger>=100)rest.AutoEating=false;
        if(user.CurrentThirst>=100)rest.AutoDrinking=false;
        if(rest.AutoEating && user.FindInventory('CaelumHungerRegeneration')==null)
            if(!table.Consume(user,false))rest.AutoEating=false;
        if(rest.AutoDrinking && user.FindInventory('CaelumThirstRegeneration')==null)
            if(!table.Consume(user,true))rest.AutoDrinking=false;
    }
}
