// Viaje atendido por el reloj real. El salto de calendario usa el mismo paso
// personal y se detiene ANTES de cambiar de mapa, nunca dentro de su bucle.
class CaelumTransportTrip : Object play
{
    static clearscope bool Aboard(CaelumPlayer user)
    {let b=CaelumTransportBooking.Find(user);return b!=null && b.Onboard && b.Ticket!=null
        && level.MapName==CaelumTransportSceneData.Stage(b.Ticket.Route,b.Ticket.Mode);}
    static clearscope double AbsoluteKm(CaelumTransportTicket ticket)
    {
        int first=CaelumTransportData.Origin(ticket.Route),last=CaelumTransportData.Destination(ticket.Route);
        double origin=0;
        for(int i=0;i<first;i++)origin+=CaelumTransportData.SegmentKm(i,ticket.Mode);
        double actual=origin+(last>first?1:-1)*ticket.CoveredKm();
        // Tren/camino comparten la zona regional, no una falsa distancia vial.
        double railway=CaelumTransportData.SegmentKm(0,ticket.Mode)+CaelumTransportData.SegmentKm(1,ticket.Mode);
        double road=CaelumTransportData.SegmentKm(0,CaelumJourneyState.MODE_CART)+CaelumTransportData.SegmentKm(1,CaelumJourneyState.MODE_CART);
        return ticket.Mode==CaelumTransportData.MODE_TRAIN?actual*road/railway:actual;
    }
    static bool Begin(CaelumPlayer user,CaelumTravelVehicle source,int route)
    {
        String stage=CaelumTransportSceneData.Stage(route,source==null?0:source.TravelMode());
        if(!LevelInfo.MapExists(stage) || !CaelumTransportBooking.Buy(user,source,route))return false;
        let b=CaelumTransportBooking.Find(user);
        b.BoardedDays=CaelumWorldClock.Get(user).CompletedDays;
        b.BoardedTics=CaelumWorldClock.Get(user).DayTics;
        b.Onboard=true;b.TransferMap=stage;b.TransferPending=true;b.StopMap="";
        CloseActivities(user);Flush(user);return true;
    }
    static void CloseActivities(CaelumPlayer user)
    {
        CaelumTimeSkipState.FinishSkip(user,"CA_SKIP_CANCELLED",true);CaelumTimeAdvanceState.Halt(user);
        CaelumRestState.Interrupt(user,"CA_REST_MOVED");
        let session=CaelumTransportSession.Find(user);if(session!=null){session.Open=false;session.Source=null;}
        user.CancelCombatBlockMode();user.CancelRangedAim();user.CancelRangedReload();
        user.CancelWeaponCharge();user.CancelPendingStaffCast(false);user.Vel=(0,0,0);
    }
    static void Step(CaelumPlayer user)
    {
        let b=CaelumTransportBooking.Find(user);
        if(b==null || b.Ticket==null || b.TransferPending || !Aboard(user))return;
        if(user.health<=0){b.Ticket.RequestStop(CaelumTransportBooking.Now(user),true,true,false);return;}
        b.Ticket.Observe(CaelumTransportBooking.Now(user));
        if(b.Ticket.Status!=CaelumTransportTicket.COMPLETE && b.Ticket.Status!=CaelumTransportTicket.STOPPED)return;
        int node=-1;
        if(b.Ticket.Status==CaelumTransportTicket.COMPLETE)node=CaelumTransportData.Destination(b.Ticket.Route);
        else if(b.Ticket.Elapsed<=0)node=CaelumTransportData.Origin(b.Ticket.Route);
        else if(b.Ticket.AtPort() && b.Ticket.StopSeconds>0)node=1;
        b.StopMap=node>=0?CaelumTransportData.Map(node):CaelumTransportSceneData.Rural(int(AbsoluteKm(b.Ticket)/CaelumTransportSceneData.RURAL_INTERVAL_KM));
        b.TransferMap=b.StopMap;b.TransferPending=true;b.Onboard=false;
        CloseActivities(user);
    }
    static void Flush(CaelumPlayer user)
    {
        let b=CaelumTransportBooking.Find(user);if(b==null || !b.TransferPending)return;
        let skip=CaelumTimeSkipState.Get(user);let advance=CaelumTimeAdvanceState.Get(user);
        if((skip!=null && skip.Pumping) || (advance!=null && advance.Pumping))return;
        if(!LevelInfo.MapExists(b.TransferMap))return;
        String target=b.TransferMap;
        // La asignacion pendiente vive en el inventario; PostTravelled no la
        // borra. Registrar la llegada solo al cargar el destino esperado.
        b.TransferPending=false;b.ArrivalPending=true;
        user.PersistCharacterState();Level.ChangeLevel(target,0,CHANGELEVEL_NOINTERMISSION);
    }
    static void Loaded(CaelumPlayer user)
    {
        let b=CaelumTransportBooking.Find(user);if(b==null || b.Ticket==null || !b.ArrivalPending || level.MapName!=b.TransferMap)return;
        b.ArrivalPending=false;b.Ticket.Stamp=CaelumTransportBooking.Now(user);
        if(b.Onboard){CaelumTransportSession.Show(user,null);return;}
        if(b.Ticket.Status==CaelumTransportTicket.COMPLETE)
        {
            let journey=CaelumJourneyState.Get(user,true);let clock=CaelumWorldClock.Get(user);
            journey.Sequence++;journey.ConnectionId=b.Ticket.Route;journey.TravelMode=b.Ticket.Mode;
            journey.Status=CaelumJourneyState.STATUS_ARRIVED;journey.Arrivals++;
            journey.HasDepartureTime=true;journey.DepartureDays=b.BoardedDays;journey.DepartureDayTics=b.BoardedTics;
            journey.HasArrivalTime=true;journey.ArrivalDays=clock.CompletedDays;journey.ArrivalDayTics=clock.DayTics;
            journey.DistanceKm=b.Ticket.DistanceKm;journey.WalkingKmh=b.Ticket.SpeedKmh;
            journey.LiveTransport=true;journey.LiveWorldSeconds=b.Ticket.Elapsed;
            journey.WalkTics=journey.SleepTics=journey.FoodConsumed=journey.WaterConsumed=0;journey.ContainerLitersConsumed=0;
            let record=user.GetPersistentCharacterState(false);
            if(record!=null){record.WorldConnectionKnown[b.Ticket.Route]=true;record.WorldConnectionTraversed[b.Ticket.Route]=true;record.WorldPendingConnection=0;}
            CaelumNotifications.Notify(user,StringTable.Localize("CA_JOURNEY_ARRIVED",false));
        }
        user.PersistCharacterState();
    }
    static bool Resume(CaelumPlayer user)
    {
        let b=CaelumTransportBooking.Find(user);
        if(b==null || b.Ticket==null || b.Onboard || b.TransferPending || b.ArrivalPending
            || level.MapName!=b.StopMap || CaelumRestSafety.BlockReason(user).Length()!=0
            || !b.Ticket.Resume(CaelumTransportBooking.Now(user)))return false;
        b.Onboard=true;b.TransferMap=CaelumTransportSceneData.Stage(b.Ticket.Route,b.Ticket.Mode);b.TransferPending=true;
        CloseActivities(user);Flush(user);return true;
    }
    static bool Rebook(CaelumPlayer user)
    {
        let b=CaelumTransportBooking.Find(user);
        if(b==null || b.Ticket==null || b.Onboard || b.TransferPending || b.ArrivalPending
            || b.Ticket.Status!=CaelumTransportTicket.ABANDONED || b.StopMap!=level.MapName
            || CaelumRestSafety.BlockReason(user).Length()!=0)return false;
        int fare=int(Ceil(Max(0,b.Ticket.DistanceKm-b.Ticket.CoveredKm())*CaelumTransportData.FareRate(b.Ticket.Mode)));
        if(fare<=0 || !CaelumPropertyRules.Pay(user,fare))return false;
        b.Ticket.Fare=fare;b.Ticket.Status=CaelumTransportTicket.STOPPED;
        b.Sequence=Min(b.Sequence,2147483646)+1;
        // Un contrato nuevo paga el tramo restante; el contrato abandonado
        // nunca vuelve a estar disponible sin este pago nativo.
        return Resume(user);
    }
    static void RequestExit(CaelumPlayer user)
    {
        let b=CaelumTransportBooking.Find(user);if(!Aboard(user) || b.TransferPending)return;
        // El tren frena antes de desembarcar. No se inventa una duracion de
        // frenado; el destino es un area de servicio con geometria comprobada.
        b.Ticket.RequestStop(CaelumTransportBooking.Now(user),true,true,b.Ticket.AtPort());
        Step(user);Flush(user);
    }
    static void Wait(CaelumPlayer user)
    {
        let b=CaelumTransportBooking.Find(user);if(!Aboard(user) || b.TransferPending)return;
        let session=CaelumTransportSession.Find(user);if(session!=null)session.Open=false;
        if(!CaelumTimeSkipState.OpenMenu(user)){if(session!=null)session.Open=true;return;}
        let skip=CaelumTimeSkipState.Get(user);
        double seconds=Max(0,b.Ticket.Departure-CaelumTransportBooking.Now(user))
            +Max(0,b.Ticket.DurationSeconds-b.Ticket.Elapsed);
        skip.TargetDay=CaelumTimeSkipState.NowDay(user);
        skip.TargetTics=CaelumTimeSkipState.NowTics(user)+int(Ceil(seconds*CaelumWorldClock.TicsPerHour()/3600));
        skip.TargetDay+=skip.TargetTics/CaelumWorldClock.TicsPerDay();skip.TargetTics%=CaelumWorldClock.TicsPerDay();
        skip.UseTaskDefault=false;
    }
}

class CaelumTransportSession : Inventory
{
    bool Open;
    String OriginMap;
    int SelectedRoute;
    CaelumTravelVehicle Source;
    Actor Access;
    static clearscope CaelumTransportSession Find(CaelumPlayer user)
    {return user==null?null:CaelumTransportSession(user.FindInventory('CaelumTransportSession'));}
    static bool Show(CaelumPlayer user,CaelumTravelVehicle source,Actor access=null)
    {
        if(!CaelumPlayerAuthority.CanMutate(user) || user.health<=0)return false;
        let booking=CaelumTransportBooking.Find(user);
        bool current=booking!=null && booking.Ticket!=null && (booking.Ticket.Active() || booking.Ticket.Status==CaelumTransportTicket.ABANDONED)
            && (CaelumTransportTrip.Aboard(user) || level.MapName==booking.StopMap);
        if(!current && (source==null || !source.CanBoard(user)))return false;
        let s=Find(user);if(s==null)s=CaelumTransportSession(user.GiveInventoryType('CaelumTransportSession'));
        s.Open=true;s.Source=source;s.Access=access;s.OriginMap=level.MapName;s.SelectedRoute=0;
        for(int i=10;i<=20;i++)if(CaelumTransportRules.Route(i)
            && CaelumTransportData.Map(CaelumTransportData.Origin(i))==level.MapName){s.SelectedRoute=i;break;}
        return true;
    }
    bool Valid(CaelumPlayer user)
    {
        if(!Open || OriginMap!=level.MapName || user==null || user.health<=0)return false;
        let b=CaelumTransportBooking.Find(user);
        return CaelumTransportTrip.Aboard(user) || (b!=null && b.Ticket!=null && b.StopMap==level.MapName
            && (b.Ticket.Active() || b.Ticket.Status==CaelumTransportTicket.ABANDONED)
            && Access!=null && !Access.bDestroyed && user.Distance2D(Access)<=user.UseRange && user.CheckSight(Access,SF_IGNOREVISIBILITY))
            || (Source!=null && !Source.bDestroyed && Source.CanBoard(user));
    }
    void Act(CaelumPlayer user,int choice)
    {
        if(!Valid(user)){Open=false;return;}
        if(choice==0){Open=false;return;}
        let b=CaelumTransportBooking.Find(user);
        if(b!=null && b.Ticket!=null && b.Ticket.Status==CaelumTransportTicket.ABANDONED && b.StopMap==level.MapName && Source==null)
        {if(choice==1 && !CaelumTransportTrip.Rebook(user))CaelumNotifications.Notify(user,StringTable.Localize("CA_TRANSPORT_UNAVAILABLE",false));return;}
        if(b!=null && b.Ticket!=null && b.Ticket.Active())
        {
            if(choice==1){if(b.Onboard)CaelumTransportTrip.Wait(user);else CaelumTransportTrip.Resume(user);}
            if(choice==3)CaelumTransportTrip.RequestExit(user);
            if(choice==4 && !b.Onboard){b.Ticket.Abandon(CaelumTransportBooking.Now(user));user.PersistCharacterState();}
            return;
        }
        if(choice==2)
        {
            int first=SelectedRoute;
            for(int j=0;j<11;j++)
            {SelectedRoute=SelectedRoute==20?10:SelectedRoute+1;
                if(CaelumTransportRules.Route(SelectedRoute) && CaelumTransportData.Map(CaelumTransportData.Origin(SelectedRoute))==level.MapName)break;}
        }
        if(choice==1 && Source!=null && !CaelumTransportTrip.Begin(user,Source,SelectedRoute))
            CaelumNotifications.Notify(user,StringTable.Localize("CA_TRANSPORT_UNAVAILABLE",false));
    }
    override void Tick(){Super.Tick();if(Open && !Valid(CaelumPlayer(Owner)))Open=false;}
    override void PreTravelled(){Open=false;Source=null;Access=null;Super.PreTravelled();}
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE -INVENTORY.INVBAR}
    States {Spawn:TNT1 A -1;Stop;}
}

class CaelumTransportUI : Object ui
{
    static bool Key(int type,int scan,String key)
    {
        if(type!=InputEvent.Type_KeyDown || scan==InputEvent.Key_Grave)return false;
        int choice=-1;
        if(scan==InputEvent.Key_Enter || scan==InputEvent.Key_Pad_A)choice=1;
        else if(scan==InputEvent.Key_RightArrow || scan==InputEvent.Key_LeftArrow)choice=2;
        else if(key~=="d")choice=3;
        else if(key~=="x")choice=4;
        else if(scan==InputEvent.Key_Tab || scan==InputEvent.Key_Pad_B || key~=="q")choice=0;
        if(choice>=0)EventHandler.SendNetworkEvent("ca_transport_action",choice);
        return true;
    }
    static void Draw(CaelumJournalOverlay view,CaelumPlayer user)
    {
        let s=CaelumTransportSession.Find(user);if(s==null || !s.Open || view==null)return;
        let b=CaelumTransportBooking.Find(user);let t=b==null?null:b.Ticket;
        bool active=t!=null && (t.Active() || (t.Status==CaelumTransportTicket.ABANDONED && b.StopMap==level.MapName && s.Source==null));
        int route=active?t.Route:s.SelectedRoute,mode=active?t.Mode:s.Source==null?0:s.Source.TravelMode();
        CaelumPresentation.MenuBackground(0x05070A,0.94);view.DrawPanel(16,12,608,336);
        view.DrawCenteredText(view.TitleFont,Font.CR_GOLD,320,28,StringTable.Localize("CA_TRANSPORT_TITLE",false));
        String destination=StringTable.Localize(CaelumTransportData.NameKey(CaelumTransportData.Destination(route)),false);
        view.DrawParagraph(view.TextFont,Font.CR_WHITE,40,80,560,destination);
        String line=active?String.Format(StringTable.Localize("CA_TRANSPORT_PROGRESS",false),t.CoveredKm(),t.DistanceKm,t.Fare)
            :String.Format(StringTable.Localize("CA_TRANSPORT_PRICE",false),CaelumTransportRules.DistanceKm(route,mode),CaelumTransportRules.Fare(route,mode,1),CaelumTransportRules.Hours(route,mode));
        view.DrawParagraph(view.TextFont,Font.CR_WHITE,40,112,560,line);
        view.DrawParagraph(view.TextFont,Font.CR_WHITE,40,208,560,StringTable.Localize("CA_TRANSPORT_SUPPLIES",false));
        if(active)
        {
            String status=t.Status==CaelumTransportTicket.ABANDONED?"CA_TRANSPORT_ABANDONED":t.Status==CaelumTransportTicket.STOPPED?"CA_TRANSPORT_STOPPED":t.Status==CaelumTransportTicket.WAITING?"CA_TRANSPORT_WAITING":"CA_TRANSPORT_ONBOARD";
            view.DrawParagraph(view.TextFont,Font.CR_GOLD,40,156,560,StringTable.Localize(status,false));
            if(t.ExitRequested)view.DrawParagraph(view.TextFont,Font.CR_WHITE,40,182,560,StringTable.Localize("CA_TRANSPORT_NEXT_PORT",false));
            if(t.Status==CaelumTransportTicket.ABANDONED)view.DrawParagraph(view.TextFont,Font.CR_WHITE,40,182,560,
                String.Format(StringTable.Localize("CA_TRANSPORT_REBOOK_PRICE",false),int(Ceil(Max(0,t.DistanceKm-t.CoveredKm())*CaelumTransportData.FareRate(t.Mode)))));
            else if(!t.ExitRequested)view.DrawParagraph(view.TextFont,Font.CR_WHITE,40,182,560,
                String.Format(StringTable.Localize("CA_TRANSPORT_REMAINING",false),Max(0,t.Departure-t.Stamp)/3600,Max(0,t.DurationSeconds-t.Elapsed)/3600));
        }
    }
}

class CaelumTransportAccess : CaelumTransportSignVisual
{
    override bool Used(Actor activator)
    {
        let user=CaelumPlayer(activator);
        return user!=null && user.Distance2D(self)<=user.UseRange && user.CheckSight(self,SF_IGNOREVISIBILITY)
            && CaelumUseGeometry.AimedAt(user,self) && CaelumTransportSession.Show(user,null,self);
    }
}
