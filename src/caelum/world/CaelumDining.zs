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
class CaelumDiningPreparedMeal : CaelumDiningDisplay {}
class CaelumDiningBread : CaelumDiningPreparedMeal {States {Spawn: FBRD A -1;Stop;}}
class CaelumDiningRoastBeef : CaelumDiningPreparedMeal {States {Spawn: FRBF A -1;Stop;}}
class CaelumDiningRoastFish : CaelumDiningPreparedMeal {States {Spawn: FRFS A -1;Stop;}}
class CaelumDiningPuchero : CaelumDiningPreparedMeal {States {Spawn: FPCH A -1;Stop;}}
class CaelumDiningWaterCup : CaelumDiningDisplay {}
class CaelumDiningLargeCanteen : CaelumDiningDisplay
{
    override void PostBeginPlay()
    { Super.PostBeginPlay(); Scale = GetDefaultByType("CaelumCanteenLarge").Scale; }
    States { Spawn: CW5X A -1; Stop; }
}

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
    // Revisión 2: conservar pertenencias y reponer también cada retirada.
    int MansionProvisionRevision;
    int LastMansionRestockDay;
    virtual int ForecastDailyTarget() { return level.MapName=="MAP01"?Capacity()/2:0; }
    virtual void SyncLocalDay(int localDay)
    {
        if(level.MapName!="MAP01" || localDay<0)return;
        if(MansionProvisionRevision>=2 && localDay<=LastMansionRestockDay)return;
        LastMansionRestockDay=localDay;
        RestockMansion();
    }

    void RestockMansion()
    {
        if(level.MapName!="MAP01")return;
        MansionProvisionRevision=2;
        // Retira el saldo del sembrado antiguo, nunca sus objetos. Un guardado
        // no distingue raciones iniciales de las depositadas por el jugador.
        MansionFullFoodPrepared=true;MansionFoodToSeed=0;
        RefreshDisplays();
        int food=0,water=0,target=ForecastDailyTarget();
        for(int i=0;i<Capacity();i++)
        {
            let item=Items[i];if(item==null)continue;
            int kind=item.GetConsumableType();
            if(CaelumFoodData.Prepared(CaelumFoodInventory.Kind(item)))food+=item.Amount;
            else if(kind==CaelumConstants.CONSUMABLE_WATER_RATION)water+=item.Amount;
            let container=CaelumWaterContainer(item);
            if(container!=null)
            {container.AddWater(container.GetCapacityLiters()-container.WaterLiters,CaelumWaterQuality.POTABLE);water++;}
        }
        for(int i=0;i<Capacity();i++)
        {
            if(Items[i]!=null)continue;
            bool needsFood=food<target;
            if(!needsFood && water>=target)break;
            class<CaelumConsumableItem> kind=needsFood?"CaelumFoodRation":"CaelumCanteenLarge";
            let ration=CaelumConsumableItem(Spawn(kind,Pos,NO_REPLACE));
            if(ration==null)break;
            ration.Amount=1;ration.InMagicBox=false;ration.AttachToOwner(self);Items[i]=ration;
            let container=CaelumWaterContainer(ration);
            if(container!=null)container.AddWater(container.GetCapacityLiters(),CaelumWaterQuality.POTABLE);
            if(needsFood)food++;else water++;
        }
        RefreshDisplays();
    }
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
        // Un cambio real de stock permite reintentar los canales agotados.
        for(int p=0;p<MAXPLAYERS;p++)
            if(playeringame[p])CaelumDiningSession.Invalidate(CaelumPlayer(players[p].mo));
        for(int i=0;i<Capacity();i++)
        {
            if(Items[i]==null || Items[i].Owner!=self || Items[i].Amount<=0)
            {
                Items[i]=null;
                if(Displays[i]!=null)Displays[i].Destroy();
                Displays[i]=null;continue;
            }
            class<CaelumDiningDisplay> kind=IsDrink(Items[i])?"CaelumDiningWaterCup":"CaelumDiningFoodPlate";
            if(CaelumMealData.IsMeal(Items[i].GetConsumableType()))kind=CaelumMealData.TableDisplay(Items[i].GetConsumableType());
            if(Items[i] is "CaelumCanteenLarge")kind="CaelumDiningLargeCanteen";
            if(Displays[i]!=null && Displays[i].GetClass()!=kind) {Displays[i].Destroy();Displays[i]=null;}
            if(Displays[i]==null)Displays[i]=CaelumDiningDisplay(Spawn(kind,Pos,NO_REPLACE));
            let visual=Displays[i];if(visual==null)continue;
            visual.Table=self;visual.Item=Items[i];visual.Angle=Angle;
            if(visual is 'CaelumDiningPreparedMeal')
                visual.Scale=GetDefaultByType(Items[i].GetClass()).Scale;
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
            bool match=drink?IsDrink(item):CaelumFoodData.Prepared(CaelumFoodInventory.Kind(item));
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
            Items[i]=null;RestockMansion();RefreshDisplays();user.OnNativeInventoryChanged();user.PersistCharacterState();return true;
        }
        return false;
    }

    bool Consume(CaelumPlayer user,bool drink)
    {
        if(!CanDine(user))return false;
        for(int i=0;i<Capacity();i++)
            if(CaelumDiningSession.Matches(Items[i],drink)
                && CaelumDiningSession.ConsumeItem(user,Items[i],self))return true;
        return ConsumeReserve(user,drink);
    }

    bool ConsumeReserve(CaelumPlayer user,bool drink)
    {return CanDine(user) && CaelumDiningSession.ConsumeReserve(user,drink);}

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
        // El reloj del jugador viaja con el hub. Volver a visitar una mesa
        // sólo completa el día actual, sin acumular los días no observados.
        for(int i=0;i<MAXPLAYERS;i++)
        {
            if(!playeringame[i])continue;
            let clock=CaelumWorldClock.Get(CaelumPlayer(players[i].mo));
            if(clock!=null){SyncLocalDay(clock.LocalDays());return;}
        }
        if(MansionProvisionRevision<2)SyncLocalDay(0);
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
        // TRESERV queda reservado a la galería, incluso desde el diagnóstico.
        if(level.MapName=="TRESERV")return true;
        if(level.MapName=="MAP03")return CaelumCityData.Enabled() ? CaelumCityWorld.Prepare() : Place(601,(-800,800,0),1);
        if(level.MapName=="TCOAST")return Place(701,(-256,1280,0),1);
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
        if(level.MapName!="TRESERV")return true;
        bool a=Place(1,(-600,1000,0));bool b=Place(2,(0,1550,0));bool c=Place(3,(700,2500,0));
        return a && b && c;
    }
}

// Una sola transacción para tiempo normal, acelerado y salto temporal.
// F/G pausan el objetivo 100 del descanso, nunca el umbral obligatorio 50.
class CaelumDiningSession : Object play
{
    const ORDINARY_TARGET = 50.0;
    const REST_TARGET = CaelumConstants.SURVIVAL_MAXIMUM;

    static clearscope bool HasMealSupport(CaelumPlayer user)
    {
        let rest=user==null?null:CaelumRestState(user.FindInventory("CaelumRestState"));
        return rest!=null && rest.Status==CaelumRestRules.STATUS_ACTIVE
            && rest.OriginMap==level.MapName
            && (rest.Mode==CaelumRestRules.MODE_SLEEP
                || (rest.Mode==CaelumRestRules.MODE_WAIT && rest.Furniture!=null
                    && rest.UsesFurniture));
    }
    static bool CanServe(CaelumPlayer user)
    {
        return user!=null && user.player!=null && user.health>0
            && user.CharacterCreationComplete && !user.CreationWizardOpen && user.DerivedStats!=null;
    }
    static void Migrate(CaelumRestState rest)
    {
        if(rest==null || rest.ProvisionRevision>=1)return;
        rest.ProvisionRevision=1;rest.ProvisionBlocked=0;
        rest.AutoEating=true;rest.AutoDrinking=true;
    }
    static void Invalidate(CaelumPlayer user)
    {
        let rest=CaelumRestState.Get(user);
        if(rest!=null){rest.ProvisionBlocked=0;rest.ProvisionContext=-1;}
    }
    static double Target(CaelumPlayer user,bool drink)
    {
        if(!CaelumSleepRules.IsSleeping(user) && !CaelumRestState.IsSeated(user))return ORDINARY_TARGET;
        let rest=CaelumRestState.Get(user);
        bool paused=HasMealSupport(user) && !(drink?rest.AutoDrinking:rest.AutoEating);
        return paused?ORDINARY_TARGET:REST_TARGET;
    }
    static bool Matches(CaelumConsumableItem item,bool drink)
    {
        int kind=CaelumTimeSkipRules.Kind(item);
        return kind!=0 && (kind!=1)==drink;
    }
    static bool TableAvailable(CaelumPlayer user,CaelumDiningTable table)
    {
        return table!=null && (CaelumTimeSkipState.IsActive(user)
            ?CaelumTimeSkipRules.Accessible(user,table):table.CanDine(user));
    }
    static bool ConsumeItem(CaelumPlayer user,CaelumConsumableItem item,CaelumDiningTable table=null)
    {
        if(!CanServe(user) || item==null || item.Amount<=0)return false;
        int kind=CaelumTimeSkipRules.Kind(item);if(kind==0)return false;
        bool drink=kind!=1;
        if(user.FindInventory(drink?'CaelumThirstRegeneration':'CaelumHungerRegeneration')!=null
            || (drink?user.CurrentThirst:user.CurrentHunger)>=REST_TARGET)return false;
        let bottle=CaelumWaterContainer(item);
        if(bottle!=null && bottle.WaterLiters<=0.000001)return false;
        if(table!=null)
        {
            if(item.Owner!=table || !TableAvailable(user,table))return false;
            CaelumFoodInventory.Reconcile(item);
            table.RemoveInventory(item);item.AttachToOwner(user);
        }
        else if(!CaelumTimeSkipRules.OwnedAvailable(user,item))return false;
        bool stored=item.InMagicBox;item.InMagicBox=false;
        bool accepted=bottle!=null?bottle.Drink():item.Use(false);
        item.InMagicBox=stored;
        if(table!=null)user.RemoveInventory(item);
        if(accepted && bottle==null)item.Amount--;
        if(item.Amount<=0)
        {
            if(table!=null)
                for(int i=0;i<table.Capacity();i++)if(table.Items[i]==item)table.Items[i]=null;
            item.Destroy();
        }
        else if(table!=null){item.AttachToOwner(table);CaelumFoodInventory.Relocate(item);}
        if(table!=null && accepted){table.RestockMansion();table.RefreshDisplays();}
        if(accepted){user.OnNativeInventoryChanged();user.PersistCharacterState();}
        return accepted;
    }
    static bool ConsumeReserve(CaelumPlayer user,bool drink)
    {
        if(!CanServe(user))return false;
        for(int source=0;source<2;source++)
        {
            if(source==1 && !user.MagicBoxOwned)break;
            for(Inventory cursor=user.Inv;cursor!=null;cursor=cursor.Inv)
            {
                let item=CaelumConsumableItem(cursor);
                if(item!=null && item.InMagicBox==(source==1) && Matches(item,drink)
                    && ConsumeItem(user,item))return true;
            }
        }
        return false;
    }
    static bool Serve(CaelumPlayer user,bool drink)
    {
        if(!CanServe(user))return false;
        if(CaelumTimeSkipState.IsActive(user))
        {
            let it=ThinkerIterator.Create("CaelumDiningTable");CaelumDiningTable table;
            while((table=CaelumDiningTable(it.Next()))!=null)
                if(TableAvailable(user,table))
                    for(int i=0;i<table.Capacity();i++)
                        if(Matches(table.Items[i],drink) && ConsumeItem(user,table.Items[i],table))return true;
        }
        else
        {
            let table=CaelumDiningTable.Nearby(user);
            if(table!=null)return table.Consume(user,drink);
        }
        return ConsumeReserve(user,drink);
    }
    // Llegar al máximo no desarma el siguiente descenso ni cambia la pausa.
    static void Sated(CaelumPlayer user,bool drink) {}

    static bool Toggle(CaelumPlayer user,bool drink)
    {
        if(!CanServe(user) || !HasMealSupport(user))return false;
        let rest=CaelumRestState.Get(user);Migrate(rest);
        if(drink)rest.AutoDrinking=!rest.AutoDrinking;
        else rest.AutoEating=!rest.AutoEating;
        rest.ProvisionBlocked=0;
        if(!(drink?rest.AutoDrinking:rest.AutoEating))
            CaelumNotifications.Notify(user,StringTable.Localize("CA_TABLE_AUTO_STOP",false));
        return true;
    }
    static void Advance(CaelumPlayer user)
    {
        if(!CanServe(user))return;
        let rest=CaelumRestState.Get(user,true);Migrate(rest);
        int context=int(CaelumSleepRules.IsSleeping(user))*2+int(CaelumRestState.IsSeated(user))
            +int(CaelumTimeSkipState.IsActive(user))*4+int(user.MagicBoxOwned)*8;
        if(rest.ProvisionContext!=context || rest.ProvisionMap!=level.MapName)
        {
            rest.ProvisionBlocked=0;
            rest.DiningTable=(context&1)!=0 && (context&4)==0?CaelumDiningTable.Nearby(user):null;
        }
        rest.ProvisionContext=context;rest.ProvisionMap=level.MapName;
        for(int channel=0;channel<2;channel++)
        {
            bool drink=channel==1;int bit=1<<channel;
            if((drink?user.CurrentThirst:user.CurrentHunger)>=Target(user,drink))
            {rest.ProvisionBlocked&=~bit;continue;}
            if((rest.ProvisionBlocked&bit)!=0
                || user.FindInventory(drink?'CaelumThirstRegeneration':'CaelumHungerRegeneration')!=null)continue;
            if(!Serve(user,drink))rest.ProvisionBlocked|=bit;
        }
    }
}
